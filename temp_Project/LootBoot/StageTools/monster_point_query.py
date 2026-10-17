#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Read-only Stage monster point query helper used by MonsterPointPreviewWindow."""

import argparse
import hashlib
import json
import os
import re
import sys
from typing import Any


def as_text(value: Any) -> str:
    if isinstance(value, float) and value.is_integer():
        return str(int(value))
    return str(value).strip()


def as_int(value: Any, default: int = 0) -> int:
    text = as_text(value)
    if not text:
        return default
    try:
        return int(text) if re.fullmatch(r"[0-9]+", text) else default
    except (TypeError, ValueError):
        return default


def positive_int(value: str) -> int:
    if not re.fullmatch(r"[0-9]+", value.strip()):
        raise ValueError("ID 和数量必须是十进制正整数：" + value)
    result = int(value)
    if not 0 < result <= 2147483647:
        raise ValueError("ID 或数量超出正整数范围：" + value)
    return result


def parse_weighted_ids(value: Any) -> list[int]:
    if not as_text(value):
        return []
    result = []
    for entry in as_text(value).replace(";", "|").split("|"):
        parts = entry.split(":")
        if len(parts) > 2:
            raise ValueError("加权组合格式异常：" + entry)
        result.append(positive_int(parts[0]))
        if len(parts) == 2 and not re.fullmatch(r"[0-9]+(?:\.[0-9]+)?", parts[1].strip()):
            raise ValueError("组合权重格式异常：" + entry)
    return result


def parse_monsters(value: Any) -> list[tuple[int, int]]:
    result = []
    for entry in as_text(value).split("|"):
        parts = entry.split(":")
        if len(parts) != 2:
            continue
        try:
            result.append((positive_int(parts[0]), positive_int(parts[1])))
        except ValueError:
            continue
    return result


def find_malformed_monster_tokens(value: Any) -> list[str]:
    malformed = []
    for entry in as_text(value).split("|"):
        parts = entry.split(":")
        try:
            if len(parts) != 2:
                raise ValueError("invalid token")
            positive_int(parts[0])
            positive_int(parts[1])
        except ValueError:
            malformed.append(entry.strip() or "<空组合>")
    return malformed


def matching_formation_groups(row: list[Any], spawn_type_ids: set[int]) -> list[int]:
    points = as_text(row[3]).split(";")
    formations = as_text(row[4]).split(";")
    if len(points) != len(formations):
        raise ValueError(f"MonsterSpawns {as_text(row[0])} 点位组与阵型组分号分段数量不一致。")
    result = []
    for point_group, formation_group in zip(points, formations):
        if spawn_type_ids.intersection(parse_weighted_ids(point_group)):
            result.extend(parse_weighted_ids(formation_group))
    return list(dict.fromkeys(result))


def load_sheet(excel_dir: str, name: str):
    try:
        import xlrd  # type: ignore
    except ImportError as exc:
        raise RuntimeError(
            "当前 Python 缺少 xlrd，无法读取 .xls。请执行 pip install xlrd，"
            "或为工具提供已打包的 monster_point_query.exe。"
        ) from exc

    path = os.path.join(excel_dir, name + ".xls")
    if not os.path.isfile(path):
        raise RuntimeError(f"找不到表格：{path}")
    book = xlrd.open_workbook(path, on_demand=True)
    try:
        sheet = book.sheet_by_name("Sheet1")
        rows = [sheet.row_values(row) for row in range(5, sheet.nrows)]
    finally:
        book.release_resources()
    return rows


def query(excel_dir: str, stage_id: int, point_ids: list[str], include_actors: bool = False) -> dict[str, Any]:
    journal_path = os.path.join(excel_dir, "MonsterFormation.xls.stage-tools-pending.json")
    if os.path.isfile(journal_path):
        with open(journal_path, encoding="utf-8-sig") as stream:
            pending = json.load(stream)
        with open(os.path.join(excel_dir, "MonsterFormation.xls"), "rb") as stream:
            current_hash = hashlib.sha256(stream.read()).hexdigest().upper()
        if current_hash not in (pending.get("oldHash"), pending.get("newHash")):
            raise RuntimeError("检测到未完成的写表提交，请先检查并从备份恢复：" + str(pending.get("backupPath", "")))
    spawn_type_rows = load_sheet(excel_dir, "MonsterSpawnType")
    spawn_rows = load_sheet(excel_dir, "MonsterSpawns")
    formation_rows = load_sheet(excel_dir, "MonsterFormation")
    actor_rows = load_sheet(excel_dir, "Actor")

    actors: dict[int, tuple[str, str, int, int]] = {}
    actor_candidates: list[dict[str, Any]] = []
    for row in actor_rows:
        if len(row) >= 7:
            actor_id = as_int(row[0])
            actor_name = as_text(row[1])
            model_resource = as_text(row[3])
            sub_type = as_int(row[5])
            attack_type = as_int(row[6])
            actors[actor_id] = (actor_name, model_resource, sub_type, attack_type)
            if include_actors and actor_id > 0:
                actor_candidates.append({
                    "actorId": actor_id,
                    "actorName": actor_name,
                    "modelResource": model_resource,
                    "subType": sub_type,
                    "attackType": attack_type,
                })

    formations_by_group: dict[int, list[list[Any]]] = {}
    for row in formation_rows:
        if len(row) >= 6:
            formations_by_group.setdefault(as_int(row[1]), []).append(row)

    results: list[dict[str, Any]] = []
    stage_point_ids = sorted({
        str(as_int(row[2]))
        for row in spawn_type_rows
        if len(row) >= 3 and as_int(row[1], -1) == stage_id
        and 10000 <= as_int(row[2], -1) <= 99999
    })
    for point_id_text in point_ids:
        point_id = as_int(point_id_text, -1)
        item: dict[str, Any] = {
            "stageId": stage_id,
            "pointId": point_id_text,
            "success": False,
            "error": "",
            "spawnTypeIds": [],
            "spawnRows": [],
        }

        matched_spawn_type_ids = [
            as_int(row[0])
            for row in spawn_type_rows
            if len(row) >= 3 and as_int(row[1], -1) == stage_id and as_int(row[2], -1) == point_id
        ]
        item["spawnTypeIds"] = matched_spawn_type_ids
        if not matched_spawn_type_ids:
            item["error"] = f"MonsterSpawnType 未找到关卡 {stage_id}、点位 {point_id_text} 的配置。"
            results.append(item)
            continue

        matched_spawn_rows: list[list[Any]] = []
        spawn_type_id_set = set(matched_spawn_type_ids)
        for row in spawn_rows:
            if len(row) < 6 or as_int(row[1], -1) != stage_id:
                continue
            if spawn_type_id_set.intersection(parse_weighted_ids(row[3])):
                matched_spawn_rows.append(row)

        if not matched_spawn_rows:
            item["error"] = (
                "MonsterSpawns 未找到关卡 " + str(stage_id) + " 且孵化点位池包含 "
                + ", ".join(str(value) for value in matched_spawn_type_ids) + " 的配置。"
            )
            results.append(item)
            continue

        item_errors: list[str] = []
        for row in matched_spawn_rows:
            spawn_data: dict[str, Any] = {
                "spawnId": as_int(row[0]),
                "waveIndex": as_int(row[2]),
                "pointGroupRaw": as_text(row[3]),
                "formationRaw": as_text(row[4]),
                "pointCount": as_int(row[5]),
                "formationVariants": [],
            }
            formation_group_ids = matching_formation_groups(row, spawn_type_id_set)
            for group_id in formation_group_ids:
                formation_matches = formations_by_group.get(group_id, [])
                if not formation_matches:
                    item_errors.append(f"MonsterFormation 未找到唯一组合 {group_id}。")
                    continue
                if len(formation_matches) > 1:
                    item_errors.append(f"MonsterFormation 组合 {group_id} 命中 {len(formation_matches)} 行，不唯一。")
                references = []
                for referenced_row in spawn_rows:
                    if len(referenced_row) >= 6 and group_id in parse_weighted_ids(referenced_row[4]):
                        references.append({
                            "stageId": as_int(referenced_row[1]),
                            "spawnId": as_int(referenced_row[0]),
                            "waveIndex": as_int(referenced_row[2]),
                            "pointGroupRaw": as_text(referenced_row[3]),
                            "formationRaw": as_text(referenced_row[4]),
                        })
                for formation_row in formation_matches:
                    raw_monster_group = as_text(formation_row[3])
                    malformed_tokens = find_malformed_monster_tokens(raw_monster_group)
                    if malformed_tokens:
                        item_errors.append(
                            f"MonsterFormation 组合 {group_id} 的 MonsterGroup 格式异常："
                            + ", ".join(malformed_tokens)
                            + "。要求为 ActorID:数量。"
                        )
                    monsters = []
                    for actor_id, count in parse_monsters(raw_monster_group):
                        actor_name, model_resource, _, _ = actors.get(actor_id, ("", "", 0, 0))
                        monsters.append({
                            "actorId": actor_id,
                            "actorName": actor_name,
                            "modelResource": model_resource,
                            "count": count,
                        })
                        if not actor_name:
                            item_errors.append(f"Actor 未找到怪物 ID {actor_id}。")
                        elif not model_resource:
                            item_errors.append(f"Actor {actor_id}（{actor_name}）没有配置模型资源。")
                    spawn_data["formationVariants"].append({
                        "configId": as_int(formation_row[0]),
                        "groupId": as_int(formation_row[1]),
                        "formationPrefab": as_text(formation_row[2]),
                        "monsterGroupRaw": raw_monster_group,
                        "description": as_text(formation_row[5]),
                        "monsters": monsters,
                        "references": references,
                    })
            item["spawnRows"].append(spawn_data)

        has_formation = any(row["formationVariants"] for row in item["spawnRows"])
        item["success"] = has_formation and not item_errors
        item["error"] = "\n".join(dict.fromkeys(item_errors))
        results.append(item)

    response: dict[str, Any] = {
        "success": True,
        "error": "",
        "items": results,
        "stagePointIds": stage_point_ids,
    }
    if include_actors:
        response["actorCandidates"] = sorted(actor_candidates, key=lambda actor: actor["actorId"])
    return response


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--excel-dir", required=True)
    parser.add_argument("--stage", required=True, type=int)
    parser.add_argument("--points", required=True, help="Comma-separated five-digit point IDs")
    parser.add_argument("--output", required=True)
    parser.add_argument("--include-actors", action="store_true", help="Include categorized Actor candidates")
    args = parser.parse_args()

    output: dict[str, Any]
    try:
        point_ids = list(dict.fromkeys(value.strip() for value in args.points.split(",") if value.strip()))
        if any(not re.fullmatch(r"[1-9][0-9]{4}", point) for point in point_ids):
            raise RuntimeError("点位必须是五位数正整数。")
        output = query(os.path.abspath(args.excel_dir), args.stage, point_ids, args.include_actors)
    except Exception as exc:  # Keep a JSON error contract for the Unity caller.
        output = {"success": False, "error": str(exc), "items": []}

    output_path = os.path.abspath(args.output)
    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    with open(output_path, "w", encoding="utf-8") as stream:
        json.dump(output, stream, ensure_ascii=False, indent=2)

    if output["success"]:
        if sys.stdout is not None:
            print(f"queried {len(output['items'])} point(s)")
        return 0
    if sys.stderr is not None:
        print(output["error"], file=sys.stderr)
    return 1


if __name__ == "__main__":
    raise SystemExit(main())
