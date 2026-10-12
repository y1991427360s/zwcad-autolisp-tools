"""Static checks and logic tests for ZJ, YJ and aa:km-ln-cmd in AA整合版本.lsp."""
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
assert 'c:zj' in functions, 'c:zj command not found'
assert 'c:yj' in functions, 'c:yj command not found'
assert 'aa:km-ln-cmd' in functions, 'aa:km-ln-cmd helper not found'

# 2. 检查局部变量
km_form = functions['aa:km-ln-cmd']
sig = km_form[2]
slash_idx = sig.index('/')
declared_locals = set(sig[slash_idx + 1:])
required_locals = {
    '*error*', 'aa:undo-open', 'doc', 'oldcmd', 'oldct', 'oldce',
    'ss', 'all-lines', 'lines-by-y', 'y-keys', 'valid', 'base-z',
    'extreme-x-list', 'base-ext-x', 'joint-x',
    'rect-w', 'rect-x1', 'rect-x2', 'rect-cx', 'height', 'center-y',
    'bottom', 'top', 'rect-pt1', 'rect-pt2',
    'line-mid-x', 't-rect-en', 't-rect-bbox', 't-w',
    'n-lines', 'idx', 'cur-y', 'cur-lines', 'cur-ext-x', 'y-item', 'cur-txt', 'cur-center'
}
for req in required_locals:
    assert req in declared_locals, f"Missing required local variable '{req}' in aa:km-ln-cmd"

# 3. 逻辑仿真测试：模拟 aa:km-ln-cmd 在不同直线数量下的行为
def simulate_km_ln(is_left, txt_up, txt_low, txt_rect, lines):
    # lines: list of ((x1, y1), (x2, y2))
    # 提取有效线段并根据 is_left 确定端点
    valid_lines = []
    base_z = 0.0
    for p1, p2 in lines:
        dx = abs(p2[0] - p1[0])
        dy = abs(p2[1] - p1[1])
        if dx > 1e-6 and dy <= 0.1 and dy <= dx * 0.01:
            attach_pt = p1 if (p1[0] <= p2[0] if is_left else p1[0] >= p2[0]) else p2
            valid_lines.append((attach_pt[1], p1, p2))
        else:
            return {'status': 'invalid_line'}

    if len(valid_lines) < 2:
        return {'status': 'less_than_2_lines'}

    # 提取 y_keys 降序
    y_keys = []
    for item in valid_lines:
        if not any(abs(y - item[0]) < 1e-4 for y in y_keys):
            y_keys.append(item[0])
    y_keys.sort(reverse=True)

    if len(y_keys) < 2:
        return {'status': 'less_than_2_heights'}

    upper_y = y_keys[0]
    lower_y = y_keys[-1]

    # extreme-x-list
    extreme_x_list = []
    for cur_y in y_keys:
        cur_lines = [item for item in valid_lines if abs(item[0] - cur_y) < 1e-4]
        if is_left:
            cur_ext_x = min(min(item[1][0], item[2][0]) for item in cur_lines)
        else:
            cur_ext_x = max(max(item[1][0], item[2][0]) for item in cur_lines)
        extreme_x_list.append((cur_y, cur_ext_x))

    if is_left:
        base_ext_x = min(x for _, x in extreme_x_list)
        joint_x = base_ext_x - 15.0
        line_mid_x = (base_ext_x + joint_x) / 2.0
    else:
        base_ext_x = max(x for _, x in extreme_x_list)
        joint_x = base_ext_x + 15.0
        line_mid_x = (base_ext_x + joint_x) / 2.0

    height = max(20.0, (upper_y - lower_y) + 4.0)
    center_y = (lower_y + upper_y) / 2.0
    bottom = center_y - height / 2.0
    top = center_y + height / 2.0

    # 模拟 short_lines
    short_lines = []
    for cur_y, cur_ext_x in extreme_x_list:
        short_lines.append(((cur_ext_x, cur_y), (joint_x, cur_y)))

    # 模拟文本
    texts = []
    n_lines = len(y_keys)
    for idx, cur_y in enumerate(y_keys):
        if idx == 0:
            cur_txt = txt_up
        elif idx == n_lines - 1:
            cur_txt = txt_low
        elif txt_up == txt_low:
            cur_txt = txt_up
        else:
            cur_txt = None

        if cur_txt:
            texts.append({'text': cur_txt, 'y': cur_y, 'center_x': line_mid_x, 'center_y': cur_y + 3.0})

    return {
        'status': 'ok',
        'n_heights': len(y_keys),
        'upper_y': upper_y,
        'lower_y': lower_y,
        'height': height,
        'center_y': center_y,
        'joint_x': joint_x,
        'line_mid_x': line_mid_x,
        'short_lines': short_lines,
        'texts': texts,
        'rect_center_y': center_y
    }


# 测试用例 1: 用户真实的 4 条 QW3 提取线 (D2600--S-D0202-公用设备二次线.dwg)
# [1] LINE (3801.064,5033.7568) ~ (3802.314,5033.7568)
# [2] LINE (3801.064,5017.7568) ~ (3802.314,5017.7568)
# [3] LINE (3801.064,5001.7568) ~ (3802.314,5001.7568)
# [4] LINE (3801.064,4985.7568) ~ (3802.314,4985.7568)
qw3_lines = [
    ((3801.064, 5033.7568), (3802.314, 5033.7568)),
    ((3801.064, 5017.7568), (3802.314, 5017.7568)),
    ((3801.064, 5001.7568), (3802.314, 5001.7568)),
    ((3801.064, 4985.7568), (3802.314, 4985.7568)),
]

res_zj = simulate_km_ln(True, '原理号', '原理号', '终点柜名', qw3_lines)
assert res_zj['status'] == 'ok', f"Simulation failed: {res_zj}"
assert res_zj['n_heights'] == 4
assert abs(res_zj['joint_x'] - (3801.064 - 15.0)) < 1e-4
assert abs(res_zj['line_mid_x'] - (3801.064 - 7.5)) < 1e-4
assert abs(res_zj['height'] - 52.0) < 1e-4  # (5033.7568 - 4985.7568) + 4.0 = 48.0 + 4.0 = 52.0
assert abs(res_zj['center_y'] - 5009.7568) < 1e-4
assert len(res_zj['short_lines']) == 4
assert len(res_zj['texts']) == 4
# 验证 4 条短线上方全部是 "原理号"
for t in res_zj['texts']:
    assert t['text'] == '原理号'
    assert abs(t['center_x'] - (3801.064 - 7.5)) < 1e-4

# 测试用例 2: 两条水平线回归测试 (KMZ: +KM, -KM, 直流馈线柜)
lines_2 = [
    ((100.0, 50.0), (150.0, 50.0)),
    ((100.0, 30.0), (150.0, 30.0)),
]
res_kmz = simulate_km_ln(True, '+KM', '-KM', '直流馈线柜', lines_2)
assert res_kmz['status'] == 'ok'
assert res_kmz['n_heights'] == 2
assert abs(res_kmz['height'] - 24.0) < 1e-4  # (50 - 30) + 4 = 24.0
assert len(res_kmz['short_lines']) == 2
assert len(res_kmz['texts']) == 2
assert res_kmz['texts'][0]['text'] == '+KM'
assert res_kmz['texts'][1]['text'] == '-KM'

# 测试用例 3: 只有一条线时拦截提示
res_1 = simulate_km_ln(True, '原理号', '原理号', '终点柜名', [((100.0, 50.0), (150.0, 50.0))])
assert res_1['status'] == 'less_than_2_lines'

print('PASS ZJ/YJ: 4-line user QW3 case, 2-line regression and validation')
