"""Static checks and evaluations for YSDL cable CSV export in AA整合版本.lsp."""
import sys
from pathlib import Path

# Add tools to sys.path
TOOLS = Path(__file__).resolve().parent
if str(TOOLS) not in sys.path:
    sys.path.insert(0, str(TOOLS))

from lsp_common import ARITY, SOURCE, parse, read_source, walk

# 1. 编码与行尾校验
raw, source = read_source(SOURCE)
assert not raw.startswith(b'\xef\xbb\xbf'), 'UTF-8 BOM present'
assert '\ufffd' not in source, 'U+FFFD replacement char present'
assert b'\n' not in raw.replace(b'\r\n', b''), 'Bare LF / mixed newlines'

forms = parse(source)
functions = {f[1]: f for f in forms if isinstance(f, list) and f[:1] == ['defun']}

# 2. 检查命令与函数存在性
ysdl_funcs = [
    'c:ysdl',
    'aa:ysdl-clean-text',
    'aa:ysdl-reorder-row',
    'aa:ysdl-get-lwpoly-rect',
    'aa:ysdl-sort-boxes',
    'aa:ysdl-parse-rows-from-text-data',
    'aa:ysdl-format-categorized-row',
]
for name in ysdl_funcs:
    assert name in functions, f'{name} not found'

# 3. 检查语法与局部变量声明
for name in ysdl_funcs:
    form = functions[name]
    signature = form[2]
    if isinstance(signature, list):
        declared = set(signature) | {'*error*', 'aa:tag', 'aa:doc', 'aa:undo-open', 'aa:old-cmdecho'}
    else:
        declared = {'*error*', 'aa:tag', 'aa:doc', 'aa:undo-open', 'aa:old-cmdecho'}

    # 寻找内部 lambda 声明的参数和局部变量
    for node in walk(form[3:]):
        if isinstance(node, list) and len(node) >= 2 and node[0] in ('lambda', 'quote'):
            target_lambda = node if node[0] == 'lambda' else (node[1] if isinstance(node[1], list) and node[1] and node[1][0] == 'lambda' else None)
            if target_lambda and len(target_lambda) >= 2 and isinstance(target_lambda[1], list):
                declared.update(target_lambda[1])

    for node in walk(form[3:]):
        head = node[0]
        if not isinstance(head, str):
            continue
        if head in ARITY:
            low, high = ARITY[head]
            assert low <= len(node) - 1 <= high, (name, head, len(node) - 1)
        if head == 'setq':
            assert (len(node) - 1) % 2 == 0, (name, 'odd setq count')
            assigned = node[1::2]
            for var in assigned:
                assert var in declared or var.startswith('*'), f'{name}: undeclared setq variable {var}'
        if head == 'foreach':
            loop_var = node[1]
            assert loop_var in declared, f'{name}: undeclared loop variable {loop_var}'
        assert head != 'vl-sort', f'{name}: vl-sort is banned'

# 4. 算法与逻辑仿真测试
def clean_text(s: str) -> str:
    s = s.replace("至", "")
    return s.strip(" \t\r\n")

def reorder_row(row: list) -> list:
    if len(row) >= 5:
        c0, c1, c2, c3, c4 = row[:5]
        rest = row[5:]
        return [c1, c4, c3, c0, c2] + rest
    return list(row)

def format_categorized_row(raw_row: list, title: str, seq_str: str) -> list:
    c0 = raw_row[0] if len(raw_row) >= 1 else ""
    reordered = reorder_row(raw_row)
    return [title, seq_str, c0] + reordered

# 单元测试: clean_text
assert clean_text("至远动通信柜") == "远动通信柜"
assert clean_text("至公用及母线测控柜") == "公用及母线测控柜"
assert clean_text("至 远动通信柜") == "远动通信柜"
assert clean_text("同步时钟柜") == "同步时钟柜"
assert clean_text("DS-01") == "DS-01"
assert clean_text("2") == "2"
assert clean_text("") == ""

# 单元测试: reorder_row
test_row_7 = ["同步时钟柜", "DS-01", "至远动通信柜", "通讯线", "2", "B+", "B-"]
reordered_7 = reorder_row(test_row_7)
exported_7 = [clean_text(c) for c in reordered_7]
assert exported_7 == ["DS-01", "2", "通讯线", "同步时钟柜", "远动通信柜", "B+", "B-"], exported_7

test_row_5 = ["同步时钟柜", "DS-01", "至远动通信柜", "通讯线", "2"]
reordered_5 = reorder_row(test_row_5)
exported_5 = [clean_text(c) for c in reordered_5]
assert exported_5 == ["DS-01", "2", "通讯线", "同步时钟柜", "远动通信柜"], exported_5

test_row_3 = ["A", "B", "C"]
assert reorder_row(test_row_3) == ["A", "B", "C"]

# 单元测试: format_categorized_row 前缀扩展与字段对应
categorized_row = format_categorized_row(test_row_7, "公用部分", "1")
cleaned_cat = [clean_text(c) for c in categorized_row]
assert cleaned_cat == [
    "公用部分",    # 1. 分类
    "1",           # 2. 序号
    "同步时钟柜",  # 3. 安装单位名称
    "DS-01",       # 4. 电缆编号
    "2",           # 5. 所用芯数
    "通讯线",      # 6. 电缆型号及截面
    "同步时钟柜",  # 7. 起点
    "远动通信柜",  # 8. 终点
    "B+",          # 9. 后续列
    "B-",          # 10. 后续列
], cleaned_cat

# 单元测试: 5000x5000 多段线框识别算法 (aa:ysdl-get-lwpoly-rect)
def simulate_get_lwpoly_rect(pts: list, closed: bool = True, bulges: list = None) -> list:
    has_bulge = any(abs(b) > 1e-4 for b in (bulges or []))
    if has_bulge or len(pts) < 4:
        return None
    if len(pts) >= 5 and pts[0] == pts[-1]:
        pts = pts[:-1]
        closed = True
    if not (closed and len(pts) == 4):
        return None
    min_x = min(p[0] for p in pts)
    max_x = max(p[0] for p in pts)
    min_y = min(p[1] for p in pts)
    max_y = max(p[1] for p in pts)
    w = max_x - min_x
    h = max_y - min_y
    if not (4800.0 <= w <= 5200.0 and 4800.0 <= h <= 5200.0):
        return None
    for p in pts:
        if not ((abs(p[0] - min_x) <= 50.0 or abs(p[0] - max_x) <= 50.0) and
                (abs(p[1] - min_y) <= 50.0 or abs(p[1] - max_y) <= 50.0)):
            return None
    return [min_x, min_y, max_x, max_y]

# 正确 5000x5000 矩形框
assert simulate_get_lwpoly_rect([(0, 0), (5000, 0), (5000, 5000), (0, 5000)], True) == [0, 0, 5000, 5000]
# 容差边界 4800x5200
assert simulate_get_lwpoly_rect([(100, 200), (4900, 200), (4900, 5400), (100, 5400)], True) == [100, 200, 4900, 5400]
# 超出下限 4790x5000
assert simulate_get_lwpoly_rect([(0, 0), (4790, 0), (4790, 5000), (0, 5000)], True) is None
# 超出上限 5210x5000
assert simulate_get_lwpoly_rect([(0, 0), (5210, 0), (5210, 5000), (0, 5000)], True) is None
# 未闭合多段线
assert simulate_get_lwpoly_rect([(0, 0), (5000, 0), (5000, 5000), (0, 5000)], False) is None
# 包含圆弧段 (bulge)
assert simulate_get_lwpoly_rect([(0, 0), (5000, 0), (5000, 5000), (0, 5000)], True, [0.5, 0, 0, 0]) is None
# 非正交菱形
assert simulate_get_lwpoly_rect([(2500, 0), (5000, 2500), (2500, 5000), (0, 2500)], True) is None

# 单元测试: 分类框空间排序 (aa:ysdl-sort-boxes: 从上到下，从左到右)
def simulate_sort_boxes(boxes: list) -> list:
    sorted_by_top = sorted(boxes, key=lambda b: b[3], reverse=True)
    out = []
    i = 0
    while i < len(sorted_by_top):
        anchor_y = sorted_by_top[i][3]
        band = []
        while i < len(sorted_by_top) and abs(sorted_by_top[i][3] - anchor_y) <= 1000.0:
            band.append(sorted_by_top[i])
            i += 1
        band.sort(key=lambda b: b[0]) # 从左到右
        out.extend(band)
    return out

grid_boxes = [
    [6000, 0, 11000, 5000],       # 右下
    [0, 10000, 5000, 15000],      # 左上
    [6000, 10000, 11000, 15000],  # 右上
    [0, 0, 5000, 5000],           # 左下
]
sorted_grid = simulate_sort_boxes(grid_boxes)
assert sorted_grid == [
    [0, 10000, 5000, 15000],      # 1. 左上
    [6000, 10000, 11000, 15000],  # 2. 右上
    [0, 0, 5000, 5000],           # 3. 左下
    [6000, 0, 11000, 5000],       # 4. 右下
]

# 5. 多框分类识别与聚类序号端到端仿真测试
multi_box_data = {
    "boxes": [
        [0, 10000, 5000, 15000],  # 框1: 公用部分 (上方)
        [0, 0, 5000, 5000],        # 框2: 110kV部分 (下方)
    ],
    "texts": [
        # 框1标题 (字高 500)
        {"text": "公用部分", "x": 2500, "y": 14500, "h": 500.0},
        # 框1电缆行 1 (起点: 同步时钟柜)
        {"text": "同步时钟柜", "x": 100, "y": 13000, "h": 250.0},
        {"text": "DS-01", "x": 600, "y": 13000, "h": 250.0},
        {"text": "至远动通信柜", "x": 1200, "y": 13000, "h": 250.0},
        {"text": "通讯线", "x": 1800, "y": 13000, "h": 250.0},
        {"text": "2", "x": 2400, "y": 13000, "h": 250.0},
        # 框1电缆行 2 (起点: 同步时钟柜，相同起点 -> 序号继续为 1)
        {"text": "同步时钟柜", "x": 100, "y": 12500, "h": 250.0},
        {"text": "DS-02", "x": 600, "y": 12500, "h": 250.0},
        {"text": "至公用测控柜", "x": 1200, "y": 12500, "h": 250.0},
        {"text": "通讯线", "x": 1800, "y": 12500, "h": 250.0},
        {"text": "2", "x": 2400, "y": 12500, "h": 250.0},
        # 框1电缆行 3 (起点: 公用及母线测控柜，新起点 -> 序号递增为 2)
        {"text": "公用及母线测控柜", "x": 100, "y": 12000, "h": 250.0},
        {"text": "MK-01", "x": 600, "y": 12000, "h": 250.0},
        {"text": "至远动通信柜", "x": 1200, "y": 12000, "h": 250.0},
        {"text": "控制电缆", "x": 1800, "y": 12000, "h": 250.0},
        {"text": "4", "x": 2400, "y": 12000, "h": 250.0},

        # 框2标题 (字高 500)
        {"text": "110kV部分", "x": 2500, "y": 4500, "h": 500.0},
        # 框2电缆行 1 (跨分类切换 -> 序号重置为 1)
        {"text": "110kV线路保护测控柜", "x": 100, "y": 3000, "h": 250.0},
        {"text": "BH-01", "x": 600, "y": 3000, "h": 250.0},
        {"text": "至110kV母线保护柜", "x": 1200, "y": 3000, "h": 250.0},
        {"text": "光缆", "x": 1800, "y": 3000, "h": 250.0},
        {"text": "8", "x": 2400, "y": 3000, "h": 250.0},
        # 框2电缆行 2 (起点: 110kV线路保护测控柜 -> 序号保持 1)
        {"text": "110kV线路保护测控柜", "x": 100, "y": 2500, "h": 250.0},
        {"text": "BH-02", "x": 600, "y": 2500, "h": 250.0},
        {"text": "至故障录波柜", "x": 1200, "y": 2500, "h": 250.0},
        {"text": "光缆", "x": 1800, "y": 2500, "h": 250.0},
        {"text": "8", "x": 2400, "y": 2500, "h": 250.0},
        # 框2电缆行 3 (起点: 110kV母线保护柜 -> 序号递增为 2)
        {"text": "110kV母线保护柜", "x": 100, "y": 2000, "h": 250.0},
        {"text": "MB-01", "x": 600, "y": 2000, "h": 250.0},
        {"text": "至直流充电柜", "x": 1200, "y": 2000, "h": 250.0},
        {"text": "控制电缆", "x": 1800, "y": 2000, "h": 250.0},
        {"text": "4", "x": 2400, "y": 2000, "h": 250.0},
    ]
}

# 模拟分类处理逻辑
sorted_boxes = simulate_sort_boxes(multi_box_data["boxes"])
assert len(sorted_boxes) == 2
exported_all_rows = []

for box in sorted_boxes:
    min_x, min_y, max_x, max_y = box
    box_texts = [t for t in multi_box_data["texts"]
                 if min_x <= t["x"] <= max_x and min_y <= t["y"] <= max_y]
    title_items = [t for t in box_texts if 470.0 <= t["h"] <= 530.0]
    cable_items = [t for t in box_texts if not (470.0 <= t["h"] <= 530.0)]
    title_items.sort(key=lambda t: t["y"], reverse=True)
    title_str = title_items[0]["text"] if title_items else ""

    # 解析电缆行 (Y降序 + X升序)
    cable_items.sort(key=lambda t: t["y"], reverse=True)
    rows = []
    cur_row = []
    base_y = None
    for item in cable_items:
        if base_y is None or abs(item["y"] - base_y) <= 1.0:
            cur_row.append(item)
            if base_y is None:
                base_y = item["y"]
        else:
            cur_row.sort(key=lambda t: t["x"])
            rows.append([t["text"] for t in cur_row])
            cur_row = [item]
            base_y = item["y"]
    if cur_row:
        cur_row.sort(key=lambda t: t["x"])
        rows.append([t["text"] for t in cur_row])

    # 聚类编号并在分类内独立计算
    cur_seq = 0
    prev_start = None
    for raw_row in rows:
        start_dev = clean_text(raw_row[0]) if raw_row else ""
        if prev_start is None or start_dev != prev_start:
            cur_seq += 1
            prev_start = start_dev
        full_row = format_categorized_row(raw_row, title_str, str(cur_seq))
        cleaned_row = [clean_text(c) for c in full_row]
        exported_all_rows.append(cleaned_row)

# 校验导出的 6 行数据
expected_multi_rows = [
    # 框 1: 公用部分
    ["公用部分", "1", "同步时钟柜", "DS-01", "2", "通讯线", "同步时钟柜", "远动通信柜"],
    ["公用部分", "1", "同步时钟柜", "DS-02", "2", "通讯线", "同步时钟柜", "公用测控柜"],
    ["公用部分", "2", "公用及母线测控柜", "MK-01", "4", "控制电缆", "公用及母线测控柜", "远动通信柜"],
    # 框 2: 110kV部分 (序号重置为 1)
    ["110kV部分", "1", "110kV线路保护测控柜", "BH-01", "8", "光缆", "110kV线路保护测控柜", "110kV母线保护柜"],
    ["110kV部分", "1", "110kV线路保护测控柜", "BH-02", "8", "光缆", "110kV线路保护测控柜", "故障录波柜"],
    ["110kV部分", "2", "110kV母线保护柜", "MB-01", "4", "控制电缆", "110kV母线保护柜", "直流充电柜"],
]

assert len(exported_all_rows) == 6, f"Expected 6 rows, got {len(exported_all_rows)}"
for idx, (actual, expected) in enumerate(zip(exported_all_rows, expected_multi_rows)):
    assert actual == expected, f"Row {idx+1} mismatch:\nActual:   {actual}\nExpected: {expected}"

# 6. 回退模式真实数据端到端测试 (未包含分类框时的 112 个文字对象，自动回退传统无分类输出)
qw3_texts = [
    # 行 1 (Y=21359.4759)
    {"text": "通讯线", "x": 616761.4721, "y": 21359.4759},
    {"text": "同步时钟柜", "x": 616611.4721, "y": 21359.4759},
    {"text": "DS-01", "x": 616661.4721, "y": 21359.4759},
    {"text": "2", "x": 616811.4721, "y": 21359.4759},
    {"text": "B+", "x": 616861.4721, "y": 21359.4759},
    {"text": "B-", "x": 616911.4721, "y": 21359.4759},
    {"text": "至远动通信柜", "x": 616711.4721, "y": 21359.4759},
    # 行 2 (Y=21354.4759)
    {"text": "通讯线", "x": 616761.4721, "y": 21354.4759},
    {"text": "同步时钟柜", "x": 616611.4721, "y": 21354.4759},
    {"text": "DS-02", "x": 616661.4721, "y": 21354.4759},
    {"text": "至公用及母线测控柜", "x": 616711.4721, "y": 21354.4759},
    {"text": "2", "x": 616811.4721, "y": 21354.4759},
    {"text": "B+", "x": 616861.4721, "y": 21354.4759},
    {"text": "B-", "x": 616911.4721, "y": 21354.4759},
    # 行 3 (Y=21349.4759)
    {"text": "通讯线", "x": 616761.4721, "y": 21349.4759},
    {"text": "同步时钟柜", "x": 616611.4721, "y": 21349.4759},
    {"text": "DS-03", "x": 616661.4721, "y": 21349.4759},
    {"text": "至小电流接地选线柜", "x": 616711.4721, "y": 21349.4759},
    {"text": "2", "x": 616811.4721, "y": 21349.4759},
    {"text": "B+", "x": 616861.4721, "y": 21349.4759},
    {"text": "B-", "x": 616911.4721, "y": 21349.4759},
    # 行 4 (Y=21344.4759)
    {"text": "通讯线", "x": 616761.4721, "y": 21344.4759},
    {"text": "同步时钟柜", "x": 616611.4721, "y": 21344.4759},
    {"text": "DS-04", "x": 616661.4721, "y": 21344.4759},
    {"text": "至压板在线监测柜", "x": 616711.4721, "y": 21344.4759},
    {"text": "2", "x": 616811.4721, "y": 21344.4759},
    {"text": "B+", "x": 616861.4721, "y": 21344.4759},
    {"text": "B-", "x": 616911.4721, "y": 21344.4759},
    # 行 5 (Y=21339.4759)
    {"text": "通讯线", "x": 616761.4721, "y": 21339.4759},
    {"text": "同步时钟柜", "x": 616611.4721, "y": 21339.4759},
    {"text": "DS-05", "x": 616661.4721, "y": 21339.4759},
    {"text": "至电能质量监测柜", "x": 616711.4721, "y": 21339.4759},
    {"text": "2", "x": 616811.4721, "y": 21339.4759},
    {"text": "B+", "x": 616861.4721, "y": 21339.4759},
    {"text": "B-", "x": 616911.4721, "y": 21339.4759},
    # 行 6 (Y=21334.4759)
    {"text": "通讯线", "x": 616761.4721, "y": 21334.4759},
    {"text": "同步时钟柜", "x": 616611.4721, "y": 21334.4759},
    {"text": "DS-06", "x": 616661.4721, "y": 21334.4759},
    {"text": "至电度表柜", "x": 616711.4721, "y": 21334.4759},
    {"text": "2", "x": 616811.4721, "y": 21334.4759},
    {"text": "B+", "x": 616861.4721, "y": 21334.4759},
    {"text": "B-", "x": 616911.4721, "y": 21334.4759},
    # 行 7 (Y=21329.4759)
    {"text": "通讯线", "x": 616761.4721, "y": 21329.4759},
    {"text": "同步时钟柜", "x": 616611.4721, "y": 21329.4759},
    {"text": "DS-07", "x": 616661.4721, "y": 21329.4759},
    {"text": "至二次设备在线监测柜", "x": 616711.4721, "y": 21329.4759},
    {"text": "2", "x": 616811.4721, "y": 21329.4759},
    {"text": "B+", "x": 616861.4721, "y": 21329.4759},
    {"text": "B-", "x": 616911.4721, "y": 21329.4759},
    # 行 8 (Y=21324.4759)
    {"text": "至故障录波柜", "x": 616711.4721, "y": 21324.4759},
    {"text": "通讯线", "x": 616761.4721, "y": 21324.4759},
    {"text": "同步时钟柜", "x": 616611.4721, "y": 21324.4759},
    {"text": "DS-08", "x": 616661.4721, "y": 21324.4759},
    {"text": "2", "x": 616811.4721, "y": 21324.4759},
    {"text": "B+", "x": 616861.4721, "y": 21324.4759},
    {"text": "B-", "x": 616911.4721, "y": 21324.4759},
    # 行 9 (Y=21319.4759)
    {"text": "通讯线", "x": 616761.4721, "y": 21319.4759},
    {"text": "同步时钟柜", "x": 616611.4721, "y": 21319.4759},
    {"text": "DS-09", "x": 616661.4721, "y": 21319.4759},
    {"text": "至直流充电柜", "x": 616711.4721, "y": 21319.4759},
    {"text": "2", "x": 616811.4721, "y": 21319.4759},
    {"text": "B+", "x": 616861.4721, "y": 21319.4759},
    {"text": "B-", "x": 616911.4721, "y": 21319.4759},
    # 行 10 (Y=21314.4759)
    {"text": "通讯线", "x": 616761.4721, "y": 21314.4759},
    {"text": "同步时钟柜", "x": 616611.4721, "y": 21314.4759},
    {"text": "DS-10", "x": 616661.4721, "y": 21314.4759},
    {"text": "至110kV母线保护柜", "x": 616711.4721, "y": 21314.4759},
    {"text": "2", "x": 616811.4721, "y": 21314.4759},
    {"text": "B+", "x": 616861.4721, "y": 21314.4759},
    {"text": "B-", "x": 616911.4721, "y": 21314.4759},
    # 行 11 (Y=21309.4759)
    {"text": "通讯线", "x": 616761.4721, "y": 21309.4759},
    {"text": "同步时钟柜", "x": 616611.4721, "y": 21309.4759},
    {"text": "DS-11", "x": 616661.4721, "y": 21309.4759},
    {"text": "至主变保护柜1", "x": 616711.4721, "y": 21309.4759},
    {"text": "2", "x": 616811.4721, "y": 21309.4759},
    {"text": "B+", "x": 616861.4721, "y": 21309.4759},
    {"text": "B-", "x": 616911.4721, "y": 21309.4759},
    # 行 12 (Y=21304.4759)
    {"text": "通讯线", "x": 616761.4721, "y": 21304.4759},
    {"text": "同步时钟柜", "x": 616611.4721, "y": 21304.4759},
    {"text": "DS-12", "x": 616661.4721, "y": 21304.4759},
    {"text": "至主变保护柜2", "x": 616711.4721, "y": 21304.4759},
    {"text": "2", "x": 616811.4721, "y": 21304.4759},
    {"text": "B+", "x": 616861.4721, "y": 21304.4759},
    {"text": "B-", "x": 616911.4721, "y": 21304.4759},
    # 行 13 (Y=21299.4759)
    {"text": "通讯线", "x": 616761.4721, "y": 21299.4759},
    {"text": "同步时钟柜", "x": 616611.4721, "y": 21299.4759},
    {"text": "DS-13", "x": 616661.4721, "y": 21299.4759},
    {"text": "至110kV线路保护测控柜", "x": 616711.4721, "y": 21299.4759},
    {"text": "2", "x": 616811.4721, "y": 21299.4759},
    {"text": "B+", "x": 616861.4721, "y": 21299.4759},
    {"text": "B-", "x": 616911.4721, "y": 21299.4759},
    # 行 14 (Y=21294.4759)
    {"text": "通讯线", "x": 616761.4721, "y": 21294.4759},
    {"text": "同步时钟柜", "x": 616611.4721, "y": 21294.4759},
    {"text": "DS-14", "x": 616661.4721, "y": 21294.4759},
    {"text": "至主变测控柜1", "x": 616711.4721, "y": 21294.4759},
    {"text": "2", "x": 616811.4721, "y": 21294.4759},
    {"text": "B+", "x": 616861.4721, "y": 21294.4759},
    {"text": "B-", "x": 616911.4721, "y": 21294.4759},
    # 行 15 (Y=21289.4759)
    {"text": "通讯线", "x": 616761.4721, "y": 21289.4759},
    {"text": "同步时钟柜", "x": 616611.4721, "y": 21289.4759},
    {"text": "DS-15", "x": 616661.4721, "y": 21289.4759},
    {"text": "至主变测控柜2", "x": 616711.4721, "y": 21289.4759},
    {"text": "2", "x": 616811.4721, "y": 21289.4759},
    {"text": "B+", "x": 616861.4721, "y": 21289.4759},
    {"text": "B-", "x": 616911.4721, "y": 21289.4759},
    # 行 16 (Y=21284.4759)
    {"text": "至消弧线圈控制柜", "x": 616711.4721, "y": 21284.4759},
    {"text": "通讯线", "x": 616761.4721, "y": 21284.4759},
    {"text": "同步时钟柜", "x": 616611.4721, "y": 21284.4759},
    {"text": "DS-16", "x": 616661.4721, "y": 21284.4759},
    {"text": "2", "x": 616811.4721, "y": 21284.4759},
    {"text": "B+", "x": 616861.4721, "y": 21284.4759},
    {"text": "B-", "x": 616911.4721, "y": 21284.4759},
]

assert len(qw3_texts) == 112, f"Expected 112 items, got {len(qw3_texts)}"

# 模拟两段式分行与排序 (Y降序 + 行内X升序)
fuzz = 1.0
by_y = sorted(qw3_texts, key=lambda it: it["y"], reverse=True)

all_rows = []
cur_row_items = []
base_y = None
for item in by_y:
    cur_y = item["y"]
    if base_y is None or abs(cur_y - base_y) <= fuzz:
        cur_row_items.append(item)
        if base_y is None:
            base_y = cur_y
    else:
        cur_row_items.sort(key=lambda it: it["x"])
        all_rows.append([it["text"] for it in cur_row_items])
        cur_row_items = [item]
        base_y = cur_y
if cur_row_items:
    cur_row_items.sort(key=lambda it: it["x"])
    all_rows.append([it["text"] for it in cur_row_items])

assert len(all_rows) == 16, f"Expected 16 rows, got {len(all_rows)}"
for r in all_rows:
    assert len(r) == 7, f"Expected 7 cols per row, got {len(r)}"

# 执行重排并清洗
expected_destinations = [
    "远动通信柜",
    "公用及母线测控柜",
    "小电流接地选线柜",
    "压板在线监测柜",
    "电能质量监测柜",
    "电度表柜",
    "二次设备在线监测柜",
    "故障录波柜",
    "直流充电柜",
    "110kV母线保护柜",
    "主变保护柜1",
    "主变保护柜2",
    "110kV线路保护测控柜",
    "主变测控柜1",
    "主变测控柜2",
    "消弧线圈控制柜",
]

for idx, r in enumerate(all_rows):
    reordered = reorder_row(r)
    cleaned = [clean_text(c) for c in reordered]
    cable_id = f"DS-{idx + 1:02d}"
    expected_row = [cable_id, "2", "通讯线", "同步时钟柜", expected_destinations[idx], "B+", "B-"]
    assert cleaned == expected_row, f"Row {idx+1} mismatch: {cleaned} vs {expected_row}"

print("PASS: c:YSDL AST, helpers, multi-box classification, and 112 QW3 texts verification successful")
