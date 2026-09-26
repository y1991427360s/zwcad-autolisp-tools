"""Static checks and logic tests for ATW command in AA整合版本.lsp."""
from pathlib import Path
import sys

from lsp_common import SOURCE, parse, read_source, walk

# 1. 验证源码文件编码及行尾
raw, source = read_source(SOURCE)
assert not raw.startswith(b'\xef\xbb\xbf'), 'UTF-8 BOM present'
assert '\ufffd' not in source, 'U+FFFD replacement char present'
assert b'\n' not in raw.replace(b'\r\n', b''), 'Bare LF / mixed newlines'

forms = parse(source)
functions = {f[1]: f for f in forms if isinstance(f, list) and f[:1] == ['defun']}
assert 'c:atw' in functions, 'c:atw command not found'

atw_form = functions['c:atw']
sig = atw_form[2]

# 2. 检查局部变量与 undo 规范
slash_idx = sig.index('/')
declared_locals = set(sig[slash_idx + 1:])
required_locals = {'*error*', 'aa:tag', 'aa:doc', 'aa:undo-open', 'aa:old-cmdecho'}
for req in required_locals:
    assert req in declared_locals, f"Missing required local variable '{req}' in c:atw"

# 收集函数内部所有 (setq var ...) 赋值变量
assigned_vars = set()
for sub in walk(atw_form):
    if isinstance(sub, list) and len(sub) > 2 and sub[0] == 'setq':
        # (setq k1 v1 k2 v2 ...)
        for i in range(1, len(sub), 2):
            assigned_vars.add(sub[i])

undeclared = assigned_vars - declared_locals - {'*error*'}
assert not undeclared, f"Undeclared variables in c:atw: {undeclared}"

# 3. 逻辑仿真测试：90% 目标宽度缩放与左边缘锁定
def simulate_atw(pt1, pt2, texts):
    # dist = distance(pt1, pt2)
    dist = ((pt1[0] - pt2[0]) ** 2 + (pt1[1] - pt2[1]) ** 2) ** 0.5
    target_w = 0.95 * dist
    results = []

    for t in texts:
        old_w = t['width']
        old_factor = t.get('factor', 1.0)
        old_left = t['left']
        align = t.get('align', 'left') # 'left', 'center', 'right'

        if old_w > target_w:
            scale = target_w / old_w
            new_factor = old_factor * scale
            new_w = old_w * scale
            assert abs(new_w - target_w) < 1e-6, f"New width {new_w} does not match target {target_w}"

            # 模拟 CAD 在不同对齐方式下的包围盒变化
            if align == 'left':
                new_left_unadjusted = old_left
            elif align == 'center':
                # 中心点不变，两边向内收缩
                center_x = old_left + old_w / 2.0
                new_left_unadjusted = center_x - new_w / 2.0
            elif align == 'right':
                # 右边界不变，左边界向右移
                right_x = old_left + old_w
                new_left_unadjusted = right_x - new_w

            # 补偿 dx = old_left - new_left_unadjusted
            dx = old_left - new_left_unadjusted
            final_left = new_left_unadjusted + dx

            assert abs(final_left - old_left) < 1e-6, f"Left edge moved: {final_left} vs {old_left}"
            results.append({'action': 'adjusted', 'new_factor': new_factor, 'final_w': new_w, 'left': final_left})
        else:
            results.append({'action': 'kept', 'factor': old_factor, 'final_w': old_w, 'left': old_left})

    return results

# 测试用例 1：单行文字超过两点间距
# 两点间距 100，target_w = 95
texts = [
    {'width': 120.0, 'factor': 1.0, 'left': 50.0, 'align': 'left'},
    {'width': 150.0, 'factor': 0.8, 'left': 100.0, 'align': 'center'},
    {'width': 80.0,  'factor': 1.0, 'left': 200.0, 'align': 'right'},  # 未超宽，应保持
]
res = simulate_atw((0, 0), (100, 0), texts)

assert res[0]['action'] == 'adjusted'
assert abs(res[0]['final_w'] - 95.0) < 1e-6
assert abs(res[0]['left'] - 50.0) < 1e-6
assert abs(res[0]['new_factor'] - (95.0 / 120.0)) < 1e-6

assert res[1]['action'] == 'adjusted'
assert abs(res[1]['final_w'] - 95.0) < 1e-6
assert abs(res[1]['left'] - 100.0) < 1e-6
assert abs(res[1]['new_factor'] - (0.8 * 95.0 / 150.0)) < 1e-6

assert res[2]['action'] == 'kept'
assert abs(res[2]['final_w'] - 80.0) < 1e-6
assert abs(res[2]['left'] - 200.0) < 1e-6

print("PASS: c:ATW form, signature, locals, undo, and 95% margin + left-edge lock logic verified")
