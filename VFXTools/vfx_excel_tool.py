# -*- coding: utf-8 -*-
"""
VFX Excel 写入工具
用法: python vfx_excel_tool.py <excel_path> <json_file_path>

退出码:
  0  成功
  1  id 字段重复
  2  名称字段重复
  3  其他错误
  99 缺少依赖库
"""

import sys
import json
import os

# ── 依赖检查 ──────────────────────────────────────────────────
try:
    import xlrd
except ImportError:
    print("错误：缺少 xlrd 库，请运行: pip install xlrd==1.2.0")
    sys.exit(99)

try:
    from xlwt import XFStyle, Font, Alignment, Borders, Pattern
except ImportError:
    print("错误：缺少 xlwt 库，请运行: pip install xlwt")
    sys.exit(99)

try:
    from xlutils.copy import copy as xl_copy
except ImportError:
    print("错误：缺少 xlutils 库，请运行: pip install xlutils")
    sys.exit(99)

# Excel 前 5 行为表头/元数据，第 6 行（索引 5）起为实际数据
DATA_START_ROW = 5


def to_cell(val):
    """JSON null 经 json.load 后变为 None，写入 Excel 时转为空字符串（真正空单元格）。"""
    return "" if val is None else val


def get_cell_style(rb, ref_row, col):
    """从参考行指定列读取 xlrd XF 记录，重建等效的 xlwt XFStyle。"""
    try:
        xf_index = rb.sheet_by_index(0).cell_xf_index(ref_row, col)
    except Exception:
        return XFStyle()

    xf = rb.xf_list[xf_index]
    style = XFStyle()

    # ── 字体 ──────────────────────────────────────────────────
    try:
        font_rec = rb.font_list[xf.font_index]
        font = Font()
        font.name         = font_rec.name
        font.bold         = font_rec.bold
        font.italic       = font_rec.italic
        font.height       = font_rec.height        # 单位：1/20 磅
        font.colour_index = font_rec.colour_index
        font.underline_type = font_rec.underline_type
        style.font = font
    except Exception:
        pass

    # ── 对齐 ──────────────────────────────────────────────────
    try:
        align = Alignment()
        align.horz = xf.alignment.hor_align
        align.vert = xf.alignment.ver_align
        align.wrap = xf.alignment.text_wrapped
        style.alignment = align
    except Exception:
        pass

    # ── 数字格式 ──────────────────────────────────────────────
    try:
        fmt = rb.format_map.get(xf.format_key)
        if fmt and fmt.format_str:
            style.num_format_str = fmt.format_str
    except Exception:
        pass
    # ── 边框 ───────────────────────────────────────────────
    try:
        borders = Borders()
        borders.left   = xf.border.left_line_type
        borders.right  = xf.border.right_line_type
        borders.top    = xf.border.top_line_type
        borders.bottom = xf.border.bottom_line_type
        borders.left_colour   = xf.border.left_colour_index
        borders.right_colour  = xf.border.right_colour_index
        borders.top_colour    = xf.border.top_colour_index
        borders.bottom_colour = xf.border.bottom_colour_index
        style.borders = borders
    except Exception:
        pass

    # ── 背景填充 ──────────────────────────────────────────
    try:
        pattern = Pattern()
        pattern.pattern             = xf.background.fill_pattern
        pattern.pattern_fore_colour = xf.background.pattern_colour_index
        pattern.pattern_back_colour = xf.background.background_colour_index
        style.pattern = pattern
    except Exception:
        pass
    return style


def cmd_check_id(excel_path, id_str):
    """检查指定 id 是否已存在，若存在则输出该行名称，否则输出 NOT_FOUND。"""
    if not os.path.exists(excel_path):
        print(f"错误：Excel 文件不存在: {excel_path}")
        sys.exit(3)

    try:
        id_val = int(id_str)
    except ValueError:
        print("NOT_FOUND")
        sys.exit(0)

    rb = xlrd.open_workbook(excel_path)
    ws = rb.sheet_by_index(0)

    for r in range(DATA_START_ROW, ws.nrows):
        raw_id = ws.cell_value(r, 0)
        try:
            existing_id = int(float(raw_id)) if raw_id != '' else None
        except (ValueError, TypeError):
            existing_id = None
        if existing_id == id_val:
            name = str(ws.cell_value(r, 2)).strip()
            print(name)
            sys.exit(0)

    print("NOT_FOUND")
    sys.exit(0)


def cmd_overwrite(excel_path, json_path):
    """找到与 id 匹配的行并用新数据覆盖。"""
    if not os.path.exists(excel_path):
        print(f"错误：Excel 文件不存在: {excel_path}")
        sys.exit(3)

    with open(json_path, 'r', encoding='utf-8') as f:
        data = json.load(f)

    new_id = data['id']

    rb = xlrd.open_workbook(excel_path, formatting_info=True)
    ws = rb.sheet_by_index(0)

    target_row = None
    for r in range(DATA_START_ROW, ws.nrows):
        raw_id = ws.cell_value(r, 0)
        try:
            existing_id = int(float(raw_id)) if raw_id != '' else None
        except (ValueError, TypeError):
            existing_id = None
        if existing_id == new_id:
            target_row = r
            break

    if target_row is None:
        print(f"错误：未找到 ID 为 '{new_id}' 的行，无法覆盖。")
        sys.exit(3)

    wb   = xl_copy(rb)
    ws_w = wb.get_sheet(0)

    row_values = [
        to_cell(new_id),
        data['remark'],
        data['name'],
        data['resource'],
        data['vfxType'],
        to_cell(data['rangeSize']),
        to_cell(data['scaleFactor']),
        data['attachPoint'],
        data['rotationRule'],
        to_cell(data['soundId']),
    ]

    for col, val in enumerate(row_values):
        style = get_cell_style(rb, target_row, col)
        ws_w.write(target_row, col, val, style)

    try:
        wb.save(excel_path)
    except PermissionError:
        print("写入失败：Excel 文件被其他程序占用，请先关闭 Excel 后再保存。")
        sys.exit(3)

    print("OK")
    sys.exit(0)


def cmd_get_by_id(excel_path, id_str):
    """根据 id 查找对应行，以 JSON 格式输出行数据（所有字段均为字符串），供 Unity 填回界面。"""
    if not os.path.exists(excel_path):
        print(f"错误：Excel 文件不存在: {excel_path}")
        sys.exit(3)

    try:
        id_val = int(id_str)
    except ValueError:
        print("错误：ID 必须为整数。")
        sys.exit(3)

    rb = xlrd.open_workbook(excel_path)
    ws = rb.sheet_by_index(0)

    def cell_int(v):
        try:
            return int(float(v)) if v != '' else None
        except (ValueError, TypeError):
            return None

    def int_to_str(v):
        """整数 → 字符串，None → 空字符串。"""
        return "" if v is None else str(v)

    for r in range(DATA_START_ROW, ws.nrows):
        raw_id = ws.cell_value(r, 0)
        existing_id = cell_int(raw_id)
        if existing_id == id_val:
            row_data = {
                "id":           int_to_str(cell_int(ws.cell_value(r, 0))),
                "remark":       str(ws.cell_value(r, 1)),
                "name":         str(ws.cell_value(r, 2)),
                "resource":     str(ws.cell_value(r, 3)),
                "vfxType":      int_to_str(cell_int(ws.cell_value(r, 4))),
                "rangeSize":    int_to_str(cell_int(ws.cell_value(r, 5))),
                "scaleFactor":  int_to_str(cell_int(ws.cell_value(r, 6))),
                "attachPoint":  int_to_str(cell_int(ws.cell_value(r, 7))),
                "rotationRule": int_to_str(cell_int(ws.cell_value(r, 8))),
                "soundId":      int_to_str(cell_int(ws.cell_value(r, 9))),
            }
            print(json.dumps(row_data, ensure_ascii=False))
            sys.exit(0)

    print("NOT_FOUND")
    sys.exit(1)


def cmd_get_last_id(excel_path):
    """读取 Excel 最后一行数据的 id，输出 id+10，供自动填写使用。"""
    if not os.path.exists(excel_path):
        print(f"错误：Excel 文件不存在: {excel_path}")
        sys.exit(3)

    rb = xlrd.open_workbook(excel_path)
    ws = rb.sheet_by_index(0)

    last_id = None
    for r in range(DATA_START_ROW, ws.nrows):
        raw_id = ws.cell_value(r, 0)
        try:
            val = int(float(raw_id)) if raw_id != '' else None
        except (ValueError, TypeError):
            val = None
        if val is not None:
            last_id = val

    if last_id is None:
        print("0")
    else:
        print(str(last_id + 10))
    sys.exit(0)


def cmd_get_by_name(excel_path, name_json_path):
    """根据名称精确查找对应行，以 JSON 格式输出行数据（所有字段均为字符串），供 Unity 填回界面。"""
    if not os.path.exists(excel_path):
        print(f"错误：Excel 文件不存在: {excel_path}")
        sys.exit(3)

    if not os.path.exists(name_json_path):
        print(f"错误：名称参数文件不存在: {name_json_path}")
        sys.exit(3)

    with open(name_json_path, 'r', encoding='utf-8') as f:
        kw_data = json.load(f)
    name_target = kw_data.get('name', '').strip()

    rb = xlrd.open_workbook(excel_path)
    ws = rb.sheet_by_index(0)

    def cell_int(v):
        try:
            return int(float(v)) if v != '' else None
        except (ValueError, TypeError):
            return None

    def int_to_str(v):
        return "" if v is None else str(v)

    for r in range(DATA_START_ROW, ws.nrows):
        row_name = str(ws.cell_value(r, 2)).strip()
        if row_name == name_target:
            row_data = {
                "id":           int_to_str(cell_int(ws.cell_value(r, 0))),
                "remark":       str(ws.cell_value(r, 1)),
                "name":         str(ws.cell_value(r, 2)),
                "resource":     str(ws.cell_value(r, 3)),
                "vfxType":      int_to_str(cell_int(ws.cell_value(r, 4))),
                "rangeSize":    int_to_str(cell_int(ws.cell_value(r, 5))),
                "scaleFactor":  int_to_str(cell_int(ws.cell_value(r, 6))),
                "attachPoint":  int_to_str(cell_int(ws.cell_value(r, 7))),
                "rotationRule": int_to_str(cell_int(ws.cell_value(r, 8))),
                "soundId":      int_to_str(cell_int(ws.cell_value(r, 9))),
            }
            print(json.dumps(row_data, ensure_ascii=False))
            sys.exit(0)

    print("NOT_FOUND")
    sys.exit(1)


def cmd_search_by_remark(excel_path, keyword_json_path):
    """在备注列中模糊搜索关键字（从 JSON 文件读取），返回所有匹配行的 JSON 数组。"""
    if not os.path.exists(excel_path):
        print(f"错误：Excel 文件不存在: {excel_path}")
        sys.exit(3)

    if not os.path.exists(keyword_json_path):
        print(f"错误：关键字文件不存在: {keyword_json_path}")
        sys.exit(3)

    with open(keyword_json_path, 'r', encoding='utf-8') as f:
        kw_data = json.load(f)
    keyword = kw_data.get('keyword', '')
    keyword_lower = keyword.lower()

    rb = xlrd.open_workbook(excel_path)
    ws = rb.sheet_by_index(0)

    def cell_int(v):
        try:
            return int(float(v)) if v != '' else None
        except (ValueError, TypeError):
            return None

    def int_to_str(v):
        return "" if v is None else str(v)

    results = []
    for r in range(DATA_START_ROW, ws.nrows):
        remark = str(ws.cell_value(r, 1))
        if keyword_lower in remark.lower():
            row_data = {
                "id":           int_to_str(cell_int(ws.cell_value(r, 0))),
                "remark":       remark,
                "name":         str(ws.cell_value(r, 2)),
                "resource":     str(ws.cell_value(r, 3)),
                "vfxType":      int_to_str(cell_int(ws.cell_value(r, 4))),
                "rangeSize":    int_to_str(cell_int(ws.cell_value(r, 5))),
                "scaleFactor":  int_to_str(cell_int(ws.cell_value(r, 6))),
                "attachPoint":  int_to_str(cell_int(ws.cell_value(r, 7))),
                "rotationRule": int_to_str(cell_int(ws.cell_value(r, 8))),
                "soundId":      int_to_str(cell_int(ws.cell_value(r, 9))),
            }
            results.append(row_data)

    print(json.dumps(results, ensure_ascii=False))
    sys.exit(0)


def main():
    # 模式一：仅读取最后 id + 10
    # 用法: vfx_excel_tool.py --get-last-id <excel_path>
    if len(sys.argv) >= 3 and sys.argv[1] == '--get-last-id':
        cmd_get_last_id(sys.argv[2])
        return

    # 模式二：检查 id 是否存在
    # 用法: vfx_excel_tool.py --check-id <excel_path> <id>
    if len(sys.argv) >= 4 and sys.argv[1] == '--check-id':
        cmd_check_id(sys.argv[2], sys.argv[3])
        return

    # 模式四：根据 id 查询整行数据（只读）
    # 用法: vfx_excel_tool.py --get-by-id <excel_path> <id>
    if len(sys.argv) >= 4 and sys.argv[1] == '--get-by-id':
        cmd_get_by_id(sys.argv[2], sys.argv[3])
        return

    # 模式六：根据名称查询整行数据（只读）
    # 用法: vfx_excel_tool.py --get-by-name <excel_path> <name>
    if len(sys.argv) >= 4 and sys.argv[1] == '--get-by-name':
        cmd_get_by_name(sys.argv[2], sys.argv[3])
        return

    # 模式三：覆盖写入
    # 用法: vfx_excel_tool.py --overwrite <excel_path> <json_file_path>
    if len(sys.argv) >= 4 and sys.argv[1] == '--overwrite':
        cmd_overwrite(sys.argv[2], sys.argv[3])
        return

    # 模式五：按备注模糊搜索
    # 用法: vfx_excel_tool.py --search-by-remark <excel_path> <keyword_json_file>
    if len(sys.argv) >= 4 and sys.argv[1] == '--search-by-remark':
        cmd_search_by_remark(sys.argv[2], sys.argv[3])
        return

    if len(sys.argv) < 3:
        print("用法: vfx_excel_tool.py <excel_path> <json_file_path>")
        sys.exit(3)

    excel_path = sys.argv[1]
    json_path  = sys.argv[2]

    if not os.path.exists(excel_path):
        print(f"错误：Excel 文件不存在: {excel_path}")
        sys.exit(3)

    if not os.path.exists(json_path):
        print(f"错误：JSON 临时文件不存在: {json_path}")
        sys.exit(3)

    # 读取 JSON 数据
    with open(json_path, 'r', encoding='utf-8') as f:
        data = json.load(f)

    new_id   = data['id']
    new_name = str(data['name']).strip()

    # ── 读取现有 Excel ────────────────────────────────────────
    rb = xlrd.open_workbook(excel_path, formatting_info=True)
    ws = rb.sheet_by_index(0)

    # ── 检查 1：id 重复 ───────────────────────────────────────
    for r in range(DATA_START_ROW, ws.nrows):
        raw_id = ws.cell_value(r, 0)
        try:
            existing_id = int(float(raw_id)) if raw_id != '' else None
        except (ValueError, TypeError):
            existing_id = None

        if existing_id is not None and existing_id == new_id:
            row_name = ws.cell_value(r, 2)
            print(f"ID 重复：'{new_id}' 已存在于第 {r + 1} 行（名称：{row_name}）")
            sys.exit(1)

    # ── 检查 2：名称重复 ──────────────────────────────────────
    for r in range(DATA_START_ROW, ws.nrows):
        raw_name = str(ws.cell_value(r, 2)).strip()
        if raw_name and raw_name == new_name:
            row_id = ws.cell_value(r, 0)
            print(f"名称重复：'{new_name}' 已存在于第 {r + 1} 行（ID：{row_id}）")
            sys.exit(2)

    # ── 写入新行 ──────────────────────────────────────────────
    wb    = xl_copy(rb)
    ws_w  = wb.get_sheet(0)
    new_row = ws.nrows

    row_values = [
        to_cell(new_id),
        data['remark'],
        data['name'],
        data['resource'],
        data['vfxType'],
        to_cell(data['rangeSize']),
        to_cell(data['scaleFactor']),
        data['attachPoint'],
        data['rotationRule'],
        to_cell(data['soundId']),
    ]

    # 以最后一行现有数据为参考，复制每列的单元格样式
    ref_row = ws.nrows - 1
    for col, val in enumerate(row_values):
        style = get_cell_style(rb, ref_row, col)
        ws_w.write(new_row, col, val, style)

    try:
        wb.save(excel_path)
    except PermissionError:
        print("写入失败：Excel 文件被其他程序占用，请先关闭 Excel 后再保存。")
        sys.exit(3)

    print("OK")
    sys.exit(0)


if __name__ == '__main__':
    main()
