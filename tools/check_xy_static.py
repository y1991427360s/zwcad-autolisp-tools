"""Parse XY and evaluate its actual search functions with mocked CAD queries."""
import math
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


def evaluate(node, env):
    if not isinstance(node, list):
        if node.startswith('"'):
            return node[1:-1]
        try:
            return float(node)
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
        branch = 1 if evaluate(args[0], env) else 2
        return evaluate(args[branch], env) if branch < len(args) else None
    if op in ('and', 'or'):
        for arg in args:
            result = evaluate(arg, env)
            if (op == 'and' and not result) or (op == 'or' and result):
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


native = {
    '+': lambda *a: sum(a), '-': lambda a, *b: a - sum(b) if b else -a,
    '*': lambda a, b: a * b, '/': lambda a, b: a / b,
    '<': lambda a, b: a < b, '<=': lambda a, b: a <= b,
    '>=': lambda a, b: a >= b, '=': lambda a, b: a == b, 'eq': lambda a, b: a == b,
    'car': lambda a: a[0], 'cdr': lambda a: a[1] if isinstance(a, tuple) else a[1:],
    'cadr': lambda a: a[1], 'caddr': lambda a: a[2], 'list': lambda *a: list(a),
    'assoc': lambda key, data: next((v for v in data if v[0] == key), None),
    'entget': entities.get, 'ssadd': add, 'ssget': query, 'min': min, 'max': max,
    'trans': lambda p, a, b: p,
    'xy:ss->list': lambda x: x,
    'xy:filter-vertical-lines': lambda x: x,
    'xy:get-vrecs-for-hline-ed': lambda ed, data: records,
}
env = {'*xy-geom-tol*': 0.0001, '*xy-hit-half-width*': 1, '*xy-ray-len*': 20}
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
    'cons': lambda a, b: [a] + b if isinstance(b, list) else (a, b),
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
print(f'PASS: whole-file parse; {len(targets)} XY functions; single/multiple horizontal lines; '
      'remote UP/DOWN labels; deduplication; rotated UCS; red warning extends right endpoint by 200')
