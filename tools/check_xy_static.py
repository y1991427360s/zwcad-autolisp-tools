"""Parse XY and evaluate its actual search functions with mocked CAD queries."""
import math
from functools import cmp_to_key
from pathlib import Path
from check_fdx_static import parse, walk, ARITY

SOURCE = Path(__file__).resolve().parents[1] / 'AA整合版本.lsp'
raw = SOURCE.read_bytes()
assert not raw.startswith(b'\xef\xbb\xbf')
source = raw.decode('utf-8', errors='strict')
assert '\ufffd' not in source
assert b'\n' not in raw.replace(b'\r\n', b'')
forms = parse(source)
functions = {f[1]: f for f in forms if isinstance(f, list) and f[:1] == ['defun']}
targets = {k: v for k, v in functions.items() if k.startswith('xy:') or k == 'c:xy'}
assert 'c:xy' in targets
for name, form in targets.items():
    for node in walk(form[3:]):
        head = node[0]
        if not isinstance(head, str):
            continue
        if head in ARITY:
            low, high = ARITY[head]
            assert low <= len(node) - 1 <= high, (name, head)
        if head in targets:
            signature = targets[head][2]
            arity = signature.index('/') if '/' in signature else len(signature)
            assert len(node) - 1 == arity, (name, head)
        if head == 'setq':
            assert len(node) % 2 == 1, (name, 'setq')
            assert all(v in form[2] or v.startswith('*xy-') for v in node[1::2]), name
        if head == 'foreach':
            assert node[1] in form[2], (name, node[1])


def lisp_true(value):
    return value is not None and value is not False and value != []


def evaluate(node, env):
    if not isinstance(node, list):
        if node == 't':
            return True
        if node.startswith('"'):
            return node[1:-1]
        try:
            val = float(node)
            return int(val) if val.is_integer() else val
        except ValueError:
            return env.get(node)
    if not node:
        return None
    op, *args = node
    if op == 'quote':
        return args[0]
    if op == 'setq':
        for key, val in zip(args[::2], args[1::2]):
            env[key] = evaluate(val, env)
        return env[key]
    if op == 'if':
        branch = 1 if lisp_true(evaluate(args[0], env)) else 2
        return evaluate(args[branch], env) if branch < len(args) else None
    if op == 'cond':
        for branch in args:
            test = evaluate(branch[0], env)
            if lisp_true(test) or branch[0] == 't':
                result = test
                for expr in branch[1:]:
                    result = evaluate(expr, env)
                return result
        return None
    if op == 'while':
        while lisp_true(evaluate(args[0], env)):
            for body in args[1:]:
                evaluate(body, env)
        return None
    if op in ('and', 'or'):
        for arg in args:
            result = evaluate(arg, env)
            if (op == 'and' and not lisp_true(result)) or (op == 'or' and lisp_true(result)):
                return result
        return result
    if op == 'foreach':
        for value in evaluate(args[1], env) or []:
            env[args[0]] = value
            for body in args[2:]:
                evaluate(body, env)
        return None
    if op == 'progn':
        result = None
        for arg in args:
            result = evaluate(arg, env)
        return result
    if op == 'mapcar':
        fn, values = [evaluate(a, env) for a in args]
        return [invoke(fn, [v], env) for v in values]
    if op == 'apply':
        fn, values = [evaluate(a, env) for a in args]
        return invoke(fn, values, env)
    return invoke(op, [evaluate(a, env) for a in args], env)


def invoke(name, args, env):
    if isinstance(name, list) and name[0] == 'lambda':
        return evaluate(name[2], dict(env, **dict(zip(name[1], args))))
    if name in native:
        return native[name](*args)
    form = functions[name]
    signature = form[2]
    boundary = signature.index('/') if '/' in signature else len(signature)
    local = dict(env)
    local.update({v: None for v in signature[boundary + 1:]})
    local.update(zip(signature[:boundary], args))
    for body in form[3:]:
        result = evaluate(body, local)
    env.update({k: v for k, v in local.items() if k.startswith('*xy-')})
    return result


queries = []
entities = {'h1': [(0, 'LINE'), (10, [0, 0, 0]), (11, [100, 0, 0])],
            'h2': [(0, 'LINE'), (10, [0, -50, 0]), (11, [100, -50, 0])]}
records = [[20, 'up', [20, 100, 0], 'v1'], [80, 'down', [80, -100, 0], 'v2']]


def add(entity=None, selection=None):
    if selection is None:
        return []
    if entity not in selection:
        selection.append(entity)
    return selection


def query(mode, p1, p2, kind):
    assert mode == '_C' and p1[0] < p2[0] and p1[1] < p2[1]
    queries.append((p1, p2, kind))
    return ['candidate']


layers = {'LAYER_GREEN': [(0, 'LAYER'), (2, 'LAYER_GREEN'), (62, 3)],
          'LAYER_WHITE': [(0, 'LAYER'), (2, 'LAYER_WHITE'), (62, 7)]}

native = {
    '+': lambda *a: sum(a), '-': lambda a, *b: a - sum(b) if b else -a,
    '*': lambda a, b: a * b,
    '/': lambda a, b: a // b if isinstance(a, int) and isinstance(b, int) and b != 0 else a / b,
    '<': lambda a, b: a < b, '<=': lambda a, b: a <= b,
    '>': lambda a, b: a > b, '>=': lambda a, b: a >= b,
    '=': lambda a, b: a == b, '/=': lambda a, b: a != b,
    'eq': lambda a, b: a == b, 'abs': abs,
    'car': lambda a: a[0] if a else None,
    'cdr': lambda a: (a[1] if isinstance(a, tuple) else a[1:]) if a else None,
    'cadr': lambda a: a[1] if a and len(a) > 1 else None,
    'caddr': lambda a: a[2] if a and len(a) > 2 else None,
    'list': lambda *a: list(a),
    'assoc': lambda key, data: next((v for v in (data or []) if v[0] == key), None),
    'entget': entities.get, 'ssadd': add, 'ssget': query, 'min': min, 'max': max,
    'trans': lambda p, a, b: p,
    'not': lambda x: not lisp_true(x), 'null': lambda x: not lisp_true(x),
    '1+': lambda x: x + 1,
    'sslength': lambda s: len(s) if s is not None else 0,
    'ssname': lambda s, i: s[i] if s is not None and 0 <= i < len(s) else None,
    'tblsearch': lambda table, name: layers.get(name),
    'xy:ss->list': lambda x: x,
    'xy:filter-vertical-lines': lambda x: x,
    'length': lambda x: len(x) if x is not None else 0,
    'xy:get-vrecs-for-hline-ed': lambda ed, data: records,
}
env = {'*xy-geom-tol*': 0.0001, '*xy-conn-tol*': 0.05, '*xy-hit-half-width*': 1, '*xy-ray-len*': 20, 'pi': math.pi}
for selected in [['h1'], ['h1', 'h2']]:
    queries.clear()
    invoke('xy:collect-vlines', [selected], env)
    assert len(queries) == len(selected)
    assert all(abs(p2[1] - p1[1] - 2) < 1e-8 for p1, p2, _ in queries)
    queries.clear()
    result = invoke('xy:collect-texts', [selected, []], env)
    assert result == ['candidate'], 'Overlapping searches must deduplicate entities'
    assert len(queries) == 2 * len(selected)
    assert queries[0][0][1] < 100 and queries[0][1][1] > 120
    assert queries[1][0][1] < -120 and queries[1][1][1] > -100

# A rotated UCS requires all four corners, not just two opposite corners.
native['trans'] = lambda p, a, b: [(p[0] - p[1]) / math.sqrt(2),
                                  (p[0] + p[1]) / math.sqrt(2), 0]
queries.clear()
invoke('xy:window-wcs', [0, 0, 10, 10, []], env)
assert queries[0][0][0] < -7 and queries[0][1][0] > 7
modified = []
native.update({
    'cons': lambda a, b: [a] + (b or []) if isinstance(b, list) or b is None else (a, b),
    'subst': lambda new, old, data: [new if v == old else v for v in data],
    'append': lambda a, b: a + b,
    'xy:remove-dxf-codes': lambda data, codes: [v for v in data if str(v[0]) not in codes],
    'entmod': lambda data: modified.append(data) or data,
})
env['*xy-warn-extend-len*'] = 200
for p1, p2, expected_code in [([0, 5, 3], [100, 5, 3], 11),
                              ([100, 5, 3], [0, 5, 3], 10)]:
    entities['warning'] = [(0, 'LINE'), (10, p1), (11, p2), (62, 7), (420, 123)]
    invoke('xy:mark-abnormal-hline', ['warning'], env)
    data = modified[-1]
    assert next(v[1:] for v in data if v[0] == expected_code) == [300, 5, 3]
    assert next(v[1] for v in data if v[0] == 62) == 1
    assert not any(v[0] == 420 for v in data)
    other_code = 10 if expected_code == 11 else 11
    assert next(v[1] for v in data if v[0] == other_code) == [0, 5, 3]
assert 'xy:selection-bounds' not in str(targets['xy:run-xin'])
assert 'xy:selection-bounds' not in str(targets['xy:run-yuan'])

entities.update({
    'line_green_h': [(0, 'LINE'), (8, '0'), (62, 3), (10, [0, 10, 0]), (11, [100, 10, 0])],
    'line_red_h': [(0, 'LINE'), (8, '0'), (62, 1), (10, [0, 10, 0]), (11, [100, 10, 0])],
    'line_green_v': [(0, 'LINE'), (8, '0'), (62, 3), (10, [10, 0, 0]), (11, [10, 100, 0])],
    'line_green_diag': [(0, 'LINE'), (8, '0'), (62, 3), (10, [0, 0, 0]), (11, [10, 100, 0])],
    'line_bylayer_green_h': [(0, 'LINE'), (8, 'LAYER_GREEN'), (10, [0, 20, 0]), (11, [50, 20, 0])],
    'line_bylayer_white_h': [(0, 'LINE'), (8, 'LAYER_WHITE'), (10, [0, 20, 0]), (11, [50, 20, 0])],
    'text_sample': [(0, 'TEXT'), (1, 'HELLO'), (10, [0, 0, 0]), (40, 3.0)],
    'text_v': [(0, 'TEXT'), (1, 'BS01'), (10, [0, 0, 0]), (40, 3.0), (50, math.pi / 2)],
})
assert invoke('xy:is-green-hline-p', ['line_green_h'], env)
assert not invoke('xy:is-green-hline-p', ['line_red_h'], env)
assert invoke('xy:is-green-hline-p', ['line_green_v'], env)
assert not invoke('xy:is-green-hline-p', ['line_green_diag'], env)
assert invoke('xy:is-green-hline-p', ['line_bylayer_green_h'], env)
assert not invoke('xy:is-green-hline-p', ['line_bylayer_white_h'], env)
assert not invoke('xy:is-green-hline-p', ['text_sample'], env)
filtered = invoke('xy:filter-green-hlines', [['line_green_h', 'line_red_h', 'line_green_v', 'line_green_diag', 'line_bylayer_green_h', 'text_sample']], env)
# 选区里有绿色水平线时按横排图处理，绿色竖线不算电缆；只有绿色竖线时才收竖向电缆
assert filtered == ['line_green_h', 'line_bylayer_green_h'], filtered
filtered = invoke('xy:filter-green-hlines', [['line_red_h', 'line_green_v', 'line_green_diag', 'text_sample']], env)
assert filtered == ['line_green_v'], filtered

print(f'PASS: whole-file parse; {len(targets)} XY functions; green horizontal line filter; single/multiple horizontal lines; '
      'remote UP/DOWN labels; deduplication; rotated UCS; red warning extends right endpoint by 200')

# 执行实际交付 AST：近竖直芯线、端点分桶、计数及真实远端文字搜索。
native.pop('xy:filter-vertical-lines')
native.pop('xy:get-vrecs-for-hline-ed')
native.update({
    'atan': lambda x, y: math.atan2(x, y),
    'nth': lambda i, xs: xs[i] if xs and i < len(xs) else None,
    'reverse': lambda xs: list(reversed(xs or [])),
    'fix': math.trunc,
    'cadddr': lambda xs: xs[3] if xs and len(xs) > 3 else None,
    'aa:merge-sort': lambda xs, fn: sorted(xs or [], key=cmp_to_key(
        lambda a, b: -1 if invoke(fn, [a, b], env) else (1 if invoke(fn, [b, a], env) else 0))),
    'itoa': str, 'princ': lambda *args: None, 'strcat': lambda *xs: ''.join(xs),
})
env.update({'*xy-vline-ang-tol*': math.pi / 180, '*xy-vline-bucket-size*': 100,
            '*xy-last-vrec-map*': None, '*xy-vline-buckets*': None})

def line(key, p1, p2):
    entities[key] = [(0, 'LINE'), (5, key), (10, p1), (11, p2)]

line('35D3', [1280.4882, 151.0389, 0], [1782.8264, 151.0389, 0])
line('35DD', [1280.4882, 151.0389, 0], [1280.4882, 231.0008, 0])
line('35D9', [1640.008, 231.0008, 0], [1639.8797, 151.0389, 0])
line('35DB', [1645.1413, 231.0008, 0], [1645.013, 151.0389, 0])
line('slash', [1639.8797, 152.8139, 0], [1641.573, 151.0389, 0])
line('zero', [10, 0, 0], [10, 0, 0])
line('horizontal', [0, 0, 0], [80, 0, 0])
for key in ['slash', 'zero', 'horizontal']:
    assert not invoke('xy:is-vertical-line-ed-p', [entities[key], 0.0001], env), key
for degrees, accepted in [(0, True), (0.99, True), (1.01, False), (45, False)]:
    line('angle', [0, 0, 0], [80 * math.tan(math.radians(degrees)), 80, 0])
    assert bool(invoke('xy:is-vertical-line-ed-p', [entities['angle'], 0.0001], env)) == accepted

selection = ['35DD', '35D9', '35DB', 'slash', 'zero', 'horizontal']
data = invoke('xy:filter-vertical-lines', [selection], env)
assert len(data) == 6  # 每根线的两个端点独立候选，匹配一端后只计一芯。
invoke('xy:build-vline-buckets', [data], env)
recs = invoke('xy:get-vrecs-for-hline-ed', [entities['35D3'], data], env)
assert len(recs) == 3, recs
assert [r[3] for r in recs] == ['35DD', '35D9', '35DB']
assert recs[1][0] == 1639.8797 and recs[1][2] == [1640.008, 231.0008, 0]
assert recs[2][0] == 1645.013 and recs[2][2] == [1645.1413, 231.0008, 0]
# 真实文字外包框，三条原理号都应与各自远端相交。
labels = [
    ['HZ-701', 1278.5094, 1281.5094, 231.8866, 242.7366, math.pi / 2],
    ['HZ-901', 1638.0294, 1641.0294, 232.0169, 242.8669, math.pi / 2],
    ['HZ-903', 1643.0294, 1646.0294, 232.0169, 243.5669, math.pi / 2],
]
assert [invoke('xy:find-text-for-vrec', [labels, r], env) for r in recs] == [x[0] for x in labels]
# 全链路 XIN：实际收集、过滤、分桶、去重及输出，空间查询模拟 CAD 交叉选择。
native['ssget'] = lambda *args: selection
native['trans'] = lambda p, a, b: p
made = []
native['entmake'] = lambda ed: made.append(ed) or ed
native['entlast'] = lambda: 'LAST'
assert invoke('xy:run-xin', [['35D3']], env)
assert next(v[1] for v in made[-1] if v[0] == 1) == '3'
assert env['*xy-last-xin-counts*'] == [('35D3', 3)]
# 正反向端点、UP/DOWN、连接端在桶边界内而远端越界；穿越、端点未接、区间外不计。
for near, far, side in [([99.9, 0, 0], [100.5, 80, 0], 'up'),
                        ([100.1, 0, 0], [99.5, -80, 0], 'down')]:
    for reverse in [False, True]:
        line('edge', far if reverse else near, near if reverse else far)
        edge_data = invoke('xy:filter-vertical-lines', [['edge']], env)
        env['*xy-last-vrec-map*'] = None
        invoke('xy:build-vline-buckets', [edge_data], env)
        hd = [(0, 'LINE'), (10, [near[0] - 0.01, 0, 0]), (11, [near[0] + 0.01, 0, 0])]
        edge_recs = invoke('xy:get-vrecs-for-hline-ed', [hd, edge_data], env)
        assert edge_recs == [[near[0], side, far, 'edge']], edge_recs
# 端点连接容差 *xy-conn-tol* = 0.05：允许竖线端点与横线有微小间隙、或略超出横线端点。
for near, far in [([50, 0.001, 0], [50.1, 80, 0]),
                  ([50, -0.049, 0], [50.1, 80, 0]),
                  ([100.01, 0, 0], [99.9, 80, 0]),
                  ([-0.049, 0, 0], [0.05, -80, 0])]:
    line('gap', near, far)
    gap_data = invoke('xy:filter-vertical-lines', [['gap']], env)
    invoke('xy:build-vline-buckets', [gap_data], env)
    actual = invoke('xy:get-vrecs-for-hline-ed', [entities['h1'], gap_data], env)
    side = 'up' if far[1] > 0 else 'down'
    assert actual == [[near[0], side, far, 'gap']], (near, far, actual)
# 穿越横线、间隙或区间外超过 0.05 时不计。
for near, far in [([50, -40, 0], [50.1, 40, 0]),
                  ([50, 0.06, 0], [50.1, 80, 0]),
                  ([100.06, 0, 0], [99.9, 80, 0]),
                  ([-0.06, 0, 0], [0.05, -80, 0])]:
    line('disconnected', near, far)
    bad_data = invoke('xy:filter-vertical-lines', [['disconnected']], env)
    invoke('xy:build-vline-buckets', [bad_data], env)
    actual = invoke('xy:get-vrecs-for-hline-ed', [entities['h1'], bad_data], env)
    assert not actual, (near, far, actual)
# 连接点重合仍去重，但横线两侧的芯线保持独立。
line('dup', [0, 0, 0], [0.1, 80, 0])
line('dup2', [0, 0, 0], [0, 80, 0])
line('down', [0, 0, 0], [-0.1, -80, 0])
dedup_data = invoke('xy:filter-vertical-lines', [['dup', 'dup2', 'down']], env)
invoke('xy:build-vline-buckets', [dedup_data], env)
assert len(invoke('xy:get-vrecs-for-hline-ed', [entities['h1'], dedup_data], env)) == 2
print('PASS: QW3 sample outputs 3 cores; real far-end labels; angle boundaries; reversed endpoints; '
      'UP/DOWN bucket crossing; disconnected/crossing/short-slash rejection; duplicate cores')

# 远端次序与连接端次序相反时，滑动窗口仍找齐，输出仍按连接点排序。
line('left_cross', [10, 0, 0], [11.3, 100, 0])
line('right_cross', [11, 0, 0], [9.7, 100, 0])
cross_data = invoke('xy:filter-vertical-lines', [['left_cross', 'right_cross']], env)
invoke('xy:build-vline-buckets', [cross_data], env)
cross_labels = [['right_label', 9.6, 9.8, 101, 104, math.pi / 2],
                ['left_label', 11.2, 11.4, 101, 104, math.pi / 2]]
copied = []
native['xy:copy-text-horizontal'] = lambda en, pt: copied.append((en, pt)) or True
env.update({'*xy-out-offx*': 10, '*xy-out-offy*': 0.5, '*xy-step-x*': 30,
            '*xy-hit-half-width*': 0.1})
assert invoke('xy:process-one-hline', [entities['h1'], cross_data, cross_labels], env) == [2, 0, 2]
assert [x[0] for x in copied] == ['left_label', 'right_label']
print('PASS: crossing far-end search order; output preserves connection-end order')

# 竖向绿色电缆线（D0204-110kV系统二次线 QW3 实例）：水平引线 + 水平原理号识别与输出
line('63934F', [68674.2242, 23664.4575, 0.0], [68674.2242, 23224.1392, 0.0])
line('639302', [68684.2242, 23664.4575, 0.0], [68674.2242, 23664.4575, 0.0])
line('639303', [68675.5897, 23664.4575, 0.0], [68674.2242, 23663.1426, 0.0])
line('639304', [68684.2242, 23649.4575, 0.0], [68674.2242, 23649.4575, 0.0])
line('639305', [68675.5897, 23649.4575, 0.0], [68674.2242, 23648.1426, 0.0])
line('639306', [68684.2242, 23534.4575, 0.0], [68674.2242, 23534.4575, 0.0])
line('639307', [68675.5897, 23534.4575, 0.0], [68674.2242, 23533.1426, 0.0])
line('639308', [68684.2242, 23519.4575, 0.0], [68674.2242, 23519.4575, 0.0])
line('639309', [68675.5897, 23519.4575, 0.0], [68674.2242, 23518.1426, 0.0])
v_sel = ['639302', '639303', '639304', '639305', '639306', '639307', '639308', '639309']
v_data = invoke('xy:filter-horizontal-lines', [v_sel], env)
assert len(v_data) == 8  # 4 条水平引线各 2 个端点候选，短斜线全部排除
env['*xy-last-vrec-map*'] = None
invoke('xy:build-vline-buckets', [v_data], env)
v_recs = invoke('xy:get-vrecs-for-hline-ed', [entities['63934F'], v_data], env)
assert len(v_recs) == 4, v_recs
assert [r[3] for r in v_recs] == ['639302', '639304', '639306', '639308']
assert all(r[1] == 'right' for r in v_recs)
v_labels = [
    ['827', 68690.2783, 68695.8783, 23662.9575, 23665.9575, 6 * math.pi],
    ['829', 68690.2783, 68695.8783, 23647.9575, 23650.9575, 6 * math.pi],
    ['831', 68690.6283, 68695.5283, 23532.9575, 23535.9575, 6 * math.pi],
    ['833', 68690.2783, 68695.8783, 23517.9575, 23520.9575, 6 * math.pi],
]
env['*xy-hit-half-width*'] = 1.0
copied_v = []
native['xy:copy-text-vertical'] = lambda en, pt: copied_v.append((en, pt)) or True
assert invoke('xy:process-one-hline', [entities['63934F'], v_data, v_labels], env) == [4, 0, 4]
assert [x[0] for x in copied_v] == ['827', '829', '831', '833']
assert abs(copied_v[0][1][0] - (68674.2242 + 0.5)) < 1e-4
assert abs(copied_v[0][1][1] - (23224.1392 - 10.0)) < 1e-4
assert abs(copied_v[1][1][1] - (23224.1392 - 40.0)) < 1e-4
print('PASS: D0204 vertical green cable line QW3 sample (horizontal core lines + horizontal principle labels)')

# XY/XIN 选线：水平线不限颜色（原有行为）；竖直线只有绿色才当电缆，
# 横向图里框选到的白色竖引线、端子排竖框不得被当成竖向电缆。
native['xy:is-green-ed-p'] = lambda ed: dict((g[0], g[1]) for g in ed).get(62) == 3
cases = [
    ([(0, 'LINE'), (10, [0, 0, 0]), (11, [100, 0, 0]), (62, 7)], True),
    ([(0, 'LINE'), (10, [0, 0, 0]), (11, [100, 0, 0]), (62, 3)], True),
    ([(0, 'LINE'), (10, [0, 0, 0]), (11, [0, -100, 0]), (62, 3)], True),
    ([(0, 'LINE'), (10, [0, 0, 0]), (11, [0, -100, 0]), (62, 7)], False),
    ([(0, 'LINE'), (10, [0, 0, 0]), (11, [0, -100, 0])], False),
    ([(0, 'LINE'), (10, [0, 0, 0]), (11, [60, 80, 0]), (62, 3)], False),
    ([(0, 'TEXT'), (10, [0, 0, 0]), (11, [100, 0, 0]), (62, 3)], False),
]
for ed, expected in cases:
    assert bool(lisp_true(invoke('xy:is-cable-line-ed-p', [ed, 0.0001], env))) == expected, ed
print('PASS: XY cable line selection: horizontal any color, vertical green only')
