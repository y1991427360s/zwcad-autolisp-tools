"""Static checks and evaluation tests for HB command in AA整合版本.lsp."""
from pathlib import Path
import re
import sys

from lsp_common import ARITY, SOURCE, parse, read_source, walk

# 1. 验证源码文件编码及行尾
raw, source = read_source(SOURCE)
assert not raw.startswith(b'\xef\xbb\xbf'), 'UTF-8 BOM present'
assert '\ufffd' not in source, 'U+FFFD replacement char present'
assert b'\n' not in raw.replace(b'\r\n', b''), 'Bare LF / mixed newlines'

forms = parse(source)
functions = {f[1]: f for f in forms if isinstance(f, list) and f[:1] == ['defun']}
targets = {k: v for k, v in functions.items() if k.startswith('hb:') or k == 'c:hb'}

# 2. 结构完整性校验
assert 'c:hb' in targets, 'c:hb command not found'
expected_helpers = [
    'hb:extract-target-cable-id',
    'hb:find-core-index',
    'hb:find-cable-index',
    'hb:cluster-rows',
    'hb:parse-row',
    'hb:update-text-content',
    'hb:create-text-matching',
    'hb:move-entity',
    'hb:apply-merge-in-place',
]
for exp in expected_helpers:
    assert exp in targets, f'Helper {exp} not found'

# 3. 语法、参数、局部变量声明与未声明赋值扫描
for name, form in targets.items():
    signature = form[2]
    # signature 可能是形如 (a b / c d) 的列表
    if isinstance(signature, list):
        declared = set(signature) | {'*error*', 'aa:tag', 'aa:doc', 'aa:undo-open', 'aa:old-cmdecho'}
    else:
        declared = {'*error*', 'aa:tag', 'aa:doc', 'aa:undo-open', 'aa:old-cmdecho'}

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
        assert head != 'vl-sort', f'{name}: vl-sort is banned, use aa:merge-sort'

print(f'PASS: {len(targets)} HB functions; signatures, locals, arities, and no vl-sort')


# 4. 核心逻辑仿真单元测试
def py_extract_target_cable_id(s: str) -> str:
    if "并入" in s:
        s = s.replace("并入", "")
        return s.strip(" \t:-：")
    return s


def py_find_core_index(items):
    # items: list of (x, y, text, ename)
    length = len(items)
    for i in range(1, length):
        val_str = items[i][2]
        if val_str.isdigit():
            val = int(val_str)
            rem_cnt = length - 1 - i
            if val > 0 and val == rem_cnt:
                return i
    # fallback
    for i in range(length - 1, 1, -1):
        val_str = items[i][2]
        if val_str.isdigit():
            val = int(val_str)
            if 0 < val <= 200:
                return i
    return None


def py_natural_key(s: str):
    return [int(t) if t.isdigit() else t.lower() for t in re.split(r'(\d+)', s)]


def py_parse_row(items):
    core_idx = py_find_core_index(items)
    assert core_idx is not None and core_idx > 1
    # 查找并入所在列或默认列1
    cable_idx = None
    for i in range(core_idx):
        if "并入" in items[i][2]:
            cable_idx = i
            break
    if cable_idx is None:
        cable_idx = 1 if core_idx >= 2 else 0

    cable_str = items[cable_idx][2]
    is_merge = "并入" in cable_str
    target_id = py_extract_target_cable_id(cable_str)
    core_cnt = int(items[core_idx][2])

    prefix_items = [items[i][2] for i in range(cable_idx)]
    middle_items = [items[i][2] for i in range(cable_idx + 1, core_idx)]
    principles = [items[i][2] for i in range(core_idx + 1, len(items))]

    return {
        'prefix': prefix_items,
        'cable_str': cable_str,
        'target_id': target_id,
        'is_merge': is_merge,
        'middle': middle_items,
        'core_cnt': core_cnt,
        'principles': principles,
        'enames': [itm[3] for itm in items],
    }


def py_merge_rows(parsed_rows):
    rows = [dict(r) for r in parsed_rows]
    merge_count = 0
    i = 0
    while i < len(rows):
        r = rows[i]
        if r['is_merge']:
            target_id = r['target_id']
            base_idx = None
            for idx, b in enumerate(rows):
                if idx != i and not b.get('is_merge') and b.get('status') != 'MERGED':
                    if b['prefix'] == r['prefix'] and b['target_id'] == target_id:
                        base_idx = idx
                        break
            if base_idx is not None:
                b = rows[base_idx]
                b['core_cnt'] += r['core_cnt']
                # 后面的原理号往后堆积 (append)
                merged_prins = b['principles'] + r['principles']
                b['principles'] = merged_prins
                b['enames'] += r['enames']
                r['status'] = 'MERGED'
                merge_count += 1
        i += 1
    final_rows = [r for r in rows if r.get('status') != 'MERGED']
    return final_rows, merge_count


# 测试1: 用户提供的真实电缆数据合并
row_main = [
    (94970.47, 38650.73, "#*电容器组", "e1"),
    (95020.47, 38650.73, "1(2)-1SR-163", "e2"),
    (95070.47, 38650.73, "至10kV#1(2)-1电容器柜", "e3"),
    (95120.47, 38650.73, "4×2.5", "e4"),
    (95170.47, 38650.73, "3", "e5"),
    (95220.47, 38650.73, "BS03", "e6"),
    (95270.47, 38650.73, "BS04", "e7"),
    (95320.47, 38650.73, "BS01", "e8"),
]

row_sub = [
    (94970.47, 38646.53, "#*电容器组", "e9"),
    (95020.47, 38646.53, "并入1(2)-1SR-163", "e10"),
    (95070.47, 38646.53, "至10kV#1(2)-1电容器柜", "e11"),
    (95120.47, 38646.53, "4×2.5", "e12"),
    (95170.47, 38646.53, "1", "e13"),
    (95220.47, 38646.53, "BS02", "e14"),
]

p_main = py_parse_row(row_main)
p_sub = py_parse_row(row_sub)

assert p_main['target_id'] == "1(2)-1SR-163"
assert p_main['is_merge'] is False
assert p_main['core_cnt'] == 3
assert p_main['principles'] == ["BS03", "BS04", "BS01"]

assert p_sub['target_id'] == "1(2)-1SR-163"
assert p_sub['is_merge'] is True
assert p_sub['core_cnt'] == 1
assert p_sub['principles'] == ["BS02"]

merged_rows, count = py_merge_rows([p_main, p_sub])
assert count == 1, f"Expected 1 merge, got {count}"
assert len(merged_rows) == 1, f"Expected 1 row remaining, got {len(merged_rows)}"
res = merged_rows[0]
assert res['cable_str'] == "1(2)-1SR-163"
assert res['core_cnt'] == 4, f"Expected core count 4, got {res['core_cnt']}"
assert res['principles'] == ["BS03", "BS04", "BS01", "BS02"], f"Unexpected principles: {res['principles']}"
print(f'PASS: Case 1 - Two rows merged: core=4, principles appended in order: {res["principles"]}')

# 测试2: 多行混合测试（含独立行、目标匹配行）
row_other = [
    (94970.47, 38654.93, "#*电容器组", "e01"),
    (95020.47, 38654.93, "1(2)-1SR-161", "e02"),
    (95070.47, 38654.93, "至10kV#1(2)-1电容器柜", "e03"),
    (95120.47, 38654.93, "4×2.5", "e04"),
    (95170.47, 38654.93, "4", "e05"),
    (95220.47, 38654.93, "107", "e06"),
    (95270.47, 38654.93, "107A", "e07"),
    (95320.47, 38654.93, "101", "e08"),
    (95370.47, 38654.93, "133", "e09"),
]
p_other = py_parse_row(row_other)
multi_merged, count = py_merge_rows([p_other, p_main, p_sub])
assert count == 1
assert len(multi_merged) == 2
assert multi_merged[0]['cable_str'] == "1(2)-1SR-161"
assert multi_merged[0]['core_cnt'] == 4
assert multi_merged[1]['cable_str'] == "1(2)-1SR-163"
assert multi_merged[1]['core_cnt'] == 4
print('PASS: Case 2 - Mixed rows with independent and merged lines passed')

# 测试3: 用户实际第二批数据（无规格列，芯数在第4项）
row_no_spec_main = [
    (94756.86, 38530.72, "#1(2)-2电容器组", "e21"),
    (94806.86, 38530.72, "1(2)-2SR-163", "e22"),
    (94856.86, 38530.72, "至10kV#1(2)-2电容器柜", "e23"),
    (94906.86, 38530.72, "3", "e24"),
    (94956.86, 38530.72, "BS03", "e25"),
    (95006.86, 38530.72, "BS04", "e26"),
    (95056.86, 38530.72, "BS01", "e27"),
]

row_no_spec_sub = [
    (94756.86, 38526.52, "#1(2)-2电容器组", "e28"),
    (94806.86, 38526.52, "并入1(2)-2SR-163", "e29"),
    (94856.86, 38526.52, "至10kV#1(2)-2电容器柜", "e30"),
    (94906.86, 38526.52, "1", "e31"),
    (94956.86, 38526.52, "BS02", "e32"),
]

p3_main = py_parse_row(row_no_spec_main)
p3_sub = py_parse_row(row_no_spec_sub)

assert p3_main['target_id'] == "1(2)-2SR-163"
assert p3_main['core_cnt'] == 3
assert p3_main['principles'] == ["BS03", "BS04", "BS01"]

assert p3_sub['target_id'] == "1(2)-2SR-163"
assert p3_sub['is_merge'] is True
assert p3_sub['core_cnt'] == 1
assert p3_sub['principles'] == ["BS02"]

m3_rows, count3 = py_merge_rows([p3_main, p3_sub])
assert count3 == 1
assert len(m3_rows) == 1
res3 = m3_rows[0]
assert res3['cable_str'] == "1(2)-2SR-163"
assert res3['core_cnt'] == 4
assert res3['principles'] == ["BS03", "BS04", "BS01", "BS02"]
print(f'PASS: Case 3 (no spec column) - Merged: core=4, principles={res3["principles"]}')

print('ALL HB STATIC CHECKS PASS')
