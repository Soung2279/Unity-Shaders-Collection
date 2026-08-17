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

try:
    sys.stdout.reconfigure(encoding='utf-8')
    sys.stderr.reconfigure(encoding='utf-8')
except AttributeError:
    pass

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

DATA_START_ROW = 5


def to_cell(val):
    return "" if val is None else val


def cell_int(value):
    try:
        return int(float(value)) if value != '' else None
    except (ValueError, TypeError):
        return None


def int_to_str(value):
    return "" if value is None else str(value)


def read_row_data(ws, row):
    return {
        "rowIndex": int_to_str(row + 1),
        "id": int_to_str(cell_int(ws.cell_value(row, 0))),
        "remark": str(ws.cell_value(row, 1)),
        "name": str(ws.cell_value(row, 2)),
        "resource": str(ws.cell_value(row, 3)),
        "vfxType": int_to_str(cell_int(ws.cell_value(row, 4))),
        "rangeSize": int_to_str(cell_int(ws.cell_value(row, 5))),
        "scaleFactor": int_to_str(cell_int(ws.cell_value(row, 6))),
        "attachPoint": int_to_str(cell_int(ws.cell_value(row, 7))),
        "rotationRule": int_to_str(cell_int(ws.cell_value(row, 8))),
        "soundId": int_to_str(cell_int(ws.cell_value(row, 9))),
        "isHit": int_to_str(cell_int(ws.cell_value(row, 10))),
    }


def build_row_values(data):
    return [
        to_cell(data['id']),
        data['remark'],
        data['name'],
        data['resource'],
        to_cell(data['vfxType']),
        to_cell(data['rangeSize']),
        to_cell(data['scaleFactor']),
        to_cell(data['attachPoint']),
        to_cell(data['rotationRule']),
        to_cell(data['soundId']),
        to_cell(data.get('isHit', 0)),
    ]


def get_cell_style(rb, ref_row, col):
    try:
        xf_index = rb.sheet_by_index(0).cell_xf_index(ref_row, col)
    except Exception:
        return XFStyle()

    xf = rb.xf_list[xf_index]
    style = XFStyle()

    try:
        font_rec = rb.font_list[xf.font_index]
        font = Font()
        font.name = font_rec.name
        font.bold = font_rec.bold
        font.italic = font_rec.italic
        font.height = font_rec.height
        font.colour_index = font_rec.colour_index
        font.underline_type = font_rec.underline_type
        style.font = font
    except Exception:
        pass

    try:
        align = Alignment()
        align.horz = xf.alignment.hor_align
        align.vert = xf.alignment.ver_align
        align.wrap = xf.alignment.text_wrapped
        style.alignment = align
    except Exception:
        pass

    try:
        fmt = rb.format_map.get(xf.format_key)
        if fmt and fmt.format_str:
            style.num_format_str = fmt.format_str
    except Exception:
        pass

    try:
        borders = Borders()
        borders.left = xf.border.left_line_type
        borders.right = xf.border.right_line_type
        borders.top = xf.border.top_line_type
        borders.bottom = xf.border.bottom_line_type
        borders.left_colour = xf.border.left_colour_index
        borders.right_colour = xf.border.right_colour_index
        borders.top_colour = xf.border.top_colour_index
        borders.bottom_colour = xf.border.bottom_colour_index
        style.borders = borders
    except Exception:
        pass

    try:
        pattern = Pattern()
        pattern.pattern = xf.background.fill_pattern
        pattern.pattern_fore_colour = xf.background.pattern_colour_index
        pattern.pattern_back_colour = xf.background.background_colour_index
        style.pattern = pattern
    except Exception:
        pass

    return style


def save_workbook(wb, excel_path):
    try:
        wb.save(excel_path)
    except PermissionError:
        print("写入失败：Excel 文件被其他程序占用，请先关闭 Excel 后再保存。")
        sys.exit(3)


def resolve_target_row(ws, data):
    row_index = str(data.get('rowIndex', '')).strip()
    if row_index:
        try:
            target_row = int(row_index) - 1
        except ValueError:
            return None
        if target_row < DATA_START_ROW or target_row >= ws.nrows:
            return None
        return target_row

    target_id = cell_int(data.get('id'))
    if target_id is None:
        return None

    for row in range(DATA_START_ROW, ws.nrows):
        if cell_int(ws.cell_value(row, 0)) == target_id:
            return row
    return None


def cmd_check_id(excel_path, id_str):
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

    for row in range(DATA_START_ROW, ws.nrows):
        if cell_int(ws.cell_value(row, 0)) == id_val:
            print(str(ws.cell_value(row, 2)).strip())
            sys.exit(0)

    print("NOT_FOUND")
    sys.exit(0)


def cmd_overwrite(excel_path, json_path):
    if not os.path.exists(excel_path):
        print(f"错误：Excel 文件不存在: {excel_path}")
        sys.exit(3)

    with open(json_path, 'r', encoding='utf-8') as file:
        data = json.load(file)

    rb = xlrd.open_workbook(excel_path, formatting_info=True)
    ws = rb.sheet_by_index(0)
    target_row = resolve_target_row(ws, data)
    if target_row is None:
        print(f"错误：未找到目标行，rowIndex={data.get('rowIndex', '')}，ID={data.get('id', '')}。")
        sys.exit(3)

    wb = xl_copy(rb)
    ws_w = wb.get_sheet(0)
    row_values = build_row_values(data)
    for col, value in enumerate(row_values):
        ws_w.write(target_row, col, value, get_cell_style(rb, target_row, col))

    save_workbook(wb, excel_path)
    print("OK")
    sys.exit(0)


def cmd_overwrite_batch(excel_path, json_path):
    if not os.path.exists(excel_path):
        print(f"错误：Excel 文件不存在: {excel_path}")
        sys.exit(3)

    with open(json_path, 'r', encoding='utf-8') as file:
        rows = json.load(file)

    if not isinstance(rows, list):
        print("错误：批量覆盖参数必须是 JSON 数组。")
        sys.exit(3)

    rb = xlrd.open_workbook(excel_path, formatting_info=True)
    ws = rb.sheet_by_index(0)
    wb = xl_copy(rb)
    ws_w = wb.get_sheet(0)

    for item in rows:
        target_row = resolve_target_row(ws, item)
        if target_row is None:
            print(f"错误：未找到目标行，rowIndex={item.get('rowIndex', '')}，ID={item.get('id', '')}。")
            sys.exit(3)

        row_values = build_row_values(item)
        for col, value in enumerate(row_values):
            ws_w.write(target_row, col, value, get_cell_style(rb, target_row, col))

    save_workbook(wb, excel_path)
    print(f"OK:{len(rows)}")
    sys.exit(0)


def cmd_get_by_id(excel_path, id_str):
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

    for row in range(DATA_START_ROW, ws.nrows):
        if cell_int(ws.cell_value(row, 0)) == id_val:
            print(json.dumps(read_row_data(ws, row), ensure_ascii=False))
            sys.exit(0)

    print("NOT_FOUND")
    sys.exit(1)


def cmd_get_last_id(excel_path):
    if not os.path.exists(excel_path):
        print(f"错误：Excel 文件不存在: {excel_path}")
        sys.exit(3)

    rb = xlrd.open_workbook(excel_path)
    ws = rb.sheet_by_index(0)

    last_id = None
    for row in range(DATA_START_ROW, ws.nrows):
        value = cell_int(ws.cell_value(row, 0))
        if value is not None:
            last_id = value

    print("0" if last_id is None else str(last_id + 10))
    sys.exit(0)


def cmd_get_by_name(excel_path, name_json_path):
    if not os.path.exists(excel_path):
        print(f"错误：Excel 文件不存在: {excel_path}")
        sys.exit(3)
    if not os.path.exists(name_json_path):
        print(f"错误：名称参数文件不存在: {name_json_path}")
        sys.exit(3)

    with open(name_json_path, 'r', encoding='utf-8') as file:
        name_target = json.load(file).get('name', '').strip()

    rb = xlrd.open_workbook(excel_path)
    ws = rb.sheet_by_index(0)
    for row in range(DATA_START_ROW, ws.nrows):
        if str(ws.cell_value(row, 2)).strip() == name_target:
            print(json.dumps(read_row_data(ws, row), ensure_ascii=False))
            sys.exit(0)

    print("NOT_FOUND")
    sys.exit(1)


def cmd_search_by_remark(excel_path, keyword_json_path):
    if not os.path.exists(excel_path):
        print(f"错误：Excel 文件不存在: {excel_path}")
        sys.exit(3)
    if not os.path.exists(keyword_json_path):
        print(f"错误：关键字文件不存在: {keyword_json_path}")
        sys.exit(3)

    with open(keyword_json_path, 'r', encoding='utf-8') as file:
        keyword = json.load(file).get('keyword', '')
    keyword_lower = keyword.lower()

    rb = xlrd.open_workbook(excel_path)
    ws = rb.sheet_by_index(0)
    results = []
    for row in range(DATA_START_ROW, ws.nrows):
        remark = str(ws.cell_value(row, 1))
        if keyword_lower in remark.lower():
            results.append(read_row_data(ws, row))

    print(json.dumps(results, ensure_ascii=False))
    sys.exit(0)


def cmd_export_all(excel_path, cache_json_path):
    if not os.path.exists(excel_path):
        print(f"错误：Excel 文件不存在: {excel_path}")
        sys.exit(3)

    rb = xlrd.open_workbook(excel_path)
    ws = rb.sheet_by_index(0)
    rows = []
    for row in range(DATA_START_ROW, ws.nrows):
        raw_id = ws.cell_value(row, 0)
        if raw_id == '' or raw_id is None:
            continue
        rows.append(read_row_data(ws, row))

    try:
        os.makedirs(os.path.dirname(os.path.abspath(cache_json_path)), exist_ok=True)
        with open(cache_json_path, 'w', encoding='utf-8') as file:
            json.dump(rows, file, ensure_ascii=False)
    except Exception as exc:
        print(f"错误：写入缓存文件失败: {exc}")
        sys.exit(3)

    print(f"OK:{len(rows)}")
    sys.exit(0)


def main():
    if len(sys.argv) >= 3 and sys.argv[1] == '--get-last-id':
        cmd_get_last_id(sys.argv[2])
        return

    if len(sys.argv) >= 4 and sys.argv[1] == '--check-id':
        cmd_check_id(sys.argv[2], sys.argv[3])
        return

    if len(sys.argv) >= 4 and sys.argv[1] == '--get-by-id':
        cmd_get_by_id(sys.argv[2], sys.argv[3])
        return

    if len(sys.argv) >= 4 and sys.argv[1] == '--get-by-name':
        cmd_get_by_name(sys.argv[2], sys.argv[3])
        return

    if len(sys.argv) >= 4 and sys.argv[1] == '--overwrite':
        cmd_overwrite(sys.argv[2], sys.argv[3])
        return

    if len(sys.argv) >= 4 and sys.argv[1] == '--overwrite-batch':
        cmd_overwrite_batch(sys.argv[2], sys.argv[3])
        return

    if len(sys.argv) >= 4 and sys.argv[1] == '--search-by-remark':
        cmd_search_by_remark(sys.argv[2], sys.argv[3])
        return

    if len(sys.argv) >= 4 and sys.argv[1] == '--export-all':
        cmd_export_all(sys.argv[2], sys.argv[3])
        return

    if len(sys.argv) < 3:
        print("用法: vfx_excel_tool.py <excel_path> <json_file_path>")
        sys.exit(3)

    excel_path = sys.argv[1]
    json_path = sys.argv[2]

    if not os.path.exists(excel_path):
        print(f"错误：Excel 文件不存在: {excel_path}")
        sys.exit(3)
    if not os.path.exists(json_path):
        print(f"错误：JSON 临时文件不存在: {json_path}")
        sys.exit(3)

    with open(json_path, 'r', encoding='utf-8') as file:
        data = json.load(file)

    new_id = data['id']
    new_name = str(data['name']).strip()

    rb = xlrd.open_workbook(excel_path, formatting_info=True)
    ws = rb.sheet_by_index(0)

    for row in range(DATA_START_ROW, ws.nrows):
        existing_id = cell_int(ws.cell_value(row, 0))
        if existing_id is not None and existing_id == new_id:
            row_name = ws.cell_value(row, 2)
            print(f"ID 重复：'{new_id}' 已存在于第 {row + 1} 行（名称：{row_name}）")
            sys.exit(1)

    for row in range(DATA_START_ROW, ws.nrows):
        raw_name = str(ws.cell_value(row, 2)).strip()
        if raw_name and raw_name == new_name:
            row_id = ws.cell_value(row, 0)
            print(f"名称重复：'{new_name}' 已存在于第 {row + 1} 行（ID：{row_id}）")
            sys.exit(2)

    wb = xl_copy(rb)
    ws_w = wb.get_sheet(0)
    new_row = ws.nrows
    row_values = build_row_values(data)

    ref_row = ws.nrows - 1
    for col, value in enumerate(row_values):
        ws_w.write(new_row, col, value, get_cell_style(rb, ref_row, col))

    save_workbook(wb, excel_path)
    print("OK")
    sys.exit(0)


if __name__ == '__main__':
    main()
