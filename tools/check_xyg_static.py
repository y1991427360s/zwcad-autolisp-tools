"""Parse XYG and evaluate its core helpers without CAD."""
from pathlib import Path
from check_fdx_static import ARITY, parse, walk

SOURCE = Path(__file__).resolve().parents[1] / 'AA整合版本.lsp'
raw = SOURCE.read_bytes()
assert not raw.startswith(b'\xef\xbb\xbf'), 'UTF-8 BOM present'
source = raw.decode('utf-8', errors='strict')
assert '\ufffd' not in source, 'U+FFFD replacement char present'
assert b'\n' not in raw.replace(b'\r\n', b''), 'Bare LF / mixed newlines'

forms = parse(source)
functions = {f[1]: f for f in forms if isinstance(f, list) and f[:1] == ['defun']}
targets = {k: v for k, v in functions.items() if k.startswith('xyg:') or k == 'c:xyg'}
assert 'c:xyg' in targets, 'c:xyg not found'
assert len(targets) >= 5, f'Expected at least 5 XYG functions, found {len(targets)}'

for name, form in targets.items():
    signature = form[2]
    declared = set(signature) | {'*error*', 'aa:tag', 'aa:doc', 'aa:undo-open', 'aa:old-cmdecho'}
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


# Mock evaluation environment for xyg helpers
def evaluate(node, env):
    if not isinstance(node, list):
        if node == 't':
            return True
        if node == 'nil':
            return None
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
        def strip_quote(v):
            if isinstance(v, list):
                return [strip_quote(x) for x in v]
            if isinstance(v, str) and v.startswith('"') and v.endswith('"'):
                return v[1:-1]
            return v
        return strip_quote(args[0])
    if op == 'setq':
        for key, val in zip(args[::2], args[1::2]):
            env[key] = evaluate(val, env)
        return env[key]
    if op == 'if':
        branch = 1 if evaluate(args[0], env) else 2
        return evaluate(args[branch], env) if branch < len(args) else None
    if op == 'cond':
        for branch in args:
            test = evaluate(branch[0], env)
            if test or branch[0] == 't':
                result = test
                for expr in branch[1:]:
                    result = evaluate(expr, env)
                return result
        return None
    if op == 'while':
        while evaluate(args[0], env):
            for body in args[1:]:
                evaluate(body, env)
        return None
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
    return invoke(op, [evaluate(a, env) for a in args], env)


def invoke(name, args, env):
    if name in native:
        return native[name](*args)
    form = functions[name]
    signature = form[2]
    boundary = signature.index('/') if '/' in signature else len(signature)
    local = dict(env)
    local.update({v: None for v in signature[boundary + 1:]})
    local.update(zip(signature[:boundary], args))
    result = None
    for body in form[3:]:
        result = evaluate(body, local)
    return result


from functools import cmp_to_key

current_env = {}

def lisp_sort(lst, fn):
    if not lst:
        return []
    def cmp(a, b):
        less = invoke(fn, [a, b], current_env) if isinstance(fn, (str, list)) else fn(a, b)
        if less:
            return -1
        less_rev = invoke(fn, [b, a], current_env) if isinstance(fn, (str, list)) else fn(b, a)
        if less_rev:
            return 1
        return 0
    return sorted(lst, key=cmp_to_key(cmp))

entities = {}
native = {
    '+': lambda *a: sum(a), '-': lambda a, *b: a - sum(b) if b else -a,
    '*': lambda a, b: a * b,
    '/': lambda a, b: a // b if isinstance(a, int) and isinstance(b, int) and b != 0 else a / b,
    '<': lambda a, b: a < b, '<=': lambda a, b: a <= b,
    '>': lambda a, b: a > b, '>=': lambda a, b: a >= b,
    '=': lambda a, b: a == b, '/=': lambda a, b: a != b,
    'car': lambda a: a[0] if a else None,
    'cdr': lambda a: (a[1] if isinstance(a, tuple) else a[1:]) if a else None,
    'cadr': lambda a: a[1] if a and len(a) > 1 else None,
    'caddr': lambda a: a[2] if a and len(a) > 2 else None,
    'cadddr': lambda a: a[3] if a and len(a) > 3 else None,
    'assoc': lambda key, data: next((v for v in (data or []) if v[0] == key), None),
    'member': lambda item, lst: lst if lst and item in lst else None,
    'entget': lambda en: entities.get(en),
    'sslength': lambda s: len(s) if s is not None else 0,
    'ssname': lambda s, i: s[i] if s is not None and 0 <= i < len(s) else None,
    '1+': lambda x: x + 1,
    'null': lambda x: not bool(x),
    'list': lambda *a: list(a),
    'cons': lambda a, b: [a] + (b if isinstance(b, list) else [b]) if b is not None else [a],
    'length': lambda x: len(x) if x is not None else 0,
    'mapcar': lambda fn, lst: [invoke(fn, [x], current_env) for x in (lst or [])],
    'min': lambda *a: min(a),
    'max': lambda *a: max(a),
    'abs': lambda x: abs(x),
    'atoi': lambda s: int(s) if s and s.strip().isdigit() else 0,
    'reverse': lambda lst: list(reversed(lst or [])),
    'aa:merge-sort': lisp_sort,
    'xy:get-text-bbox': lambda en: entities[en].get('bbox'),
}

def invoke_enhanced(name, args, env):
    global current_env
    current_env = env
    if isinstance(name, list) and name[0] == 'lambda':
        signature = name[1]
        boundary = signature.index('/') if '/' in signature else len(signature)
        local = dict(env)
        local.update({v: None for v in signature[boundary + 1:]})
        local.update(zip(signature[:boundary], args))
        result = None
        for body in name[2:]:
            result = evaluate(body, local)
        return result
    return invoke_orig(name, args, env)

invoke_orig = invoke
invoke = invoke_enhanced

# Test 1: xyg:find-prefix-text
entities = {
    't_small': [(0, 'TEXT'), (10, [10.0, 50.0, 0.0]), (40, 3.0)],
    't_big_right': [(0, 'TEXT'), (10, [200.0, 100.0, 0.0]), (40, 80.0)],
    't_big_left': [(0, 'MTEXT'), (10, [45.0, 120.0, 0.0]), (40, 85.0)],
}
prefix_result = invoke('xyg:find-prefix-text', [['t_small', 't_big_right', 't_big_left']], {})
assert prefix_result == 't_big_left', f'Expected t_big_left, got {prefix_result}'

# Test 2: xyg:text-in-rect-p
entities = {
    't_in': {'bbox': [140.0, 160.0, 51.0, 53.0], 0: [(0, 'TEXT'), (40, 3.0)]},
    't_out_x': {'bbox': [240.0, 260.0, 51.0, 53.0], 0: [(0, 'TEXT'), (40, 3.0)]},
    't_out_y': {'bbox': [140.0, 160.0, 71.0, 73.0], 0: [(0, 'TEXT'), (40, 3.0)]},
    't_big_in': {'bbox': [140.0, 160.0, 51.0, 53.0], 0: [(0, 'TEXT'), (40, 80.0)]},
    # Edge touching case: center cy=54.2 is outside [50.0, 53.2], but bbox miny=52.5 <= 53.2, touches search box
    't_touch_edge': {'bbox': [90.0, 110.0, 52.5, 56.0], 0: [(0, 'TEXT'), (40, 3.0)]},
}
# Override entget for dict with metadata
native['entget'] = lambda en: entities[en][0]
assert invoke('xyg:text-in-rect-p', ['t_in', 100.0, 200.0, 50.0, 55.0], {})
assert not invoke('xyg:text-in-rect-p', ['t_out_x', 100.0, 200.0, 50.0, 55.0], {})
assert not invoke('xyg:text-in-rect-p', ['t_out_y', 100.0, 200.0, 50.0, 55.0], {})
assert not invoke('xyg:text-in-rect-p', ['t_big_in', 100.0, 200.0, 50.0, 55.0], {})
# Verify touch edge is accepted by AABB overlap
assert invoke('xyg:text-in-rect-p', ['t_touch_edge', 80.0, 120.0, 49.8, 53.2], {})

# Test 3: 5mm line pitch separation (upper line text at y=56.0~58.0 must NOT be included in y=50.0 line search: 49.8~53.2)
entities['t_upper_line'] = {'bbox': [140.0, 160.0, 56.0, 58.0], 0: [(0, 'TEXT'), (40, 3.0)]}
assert not invoke('xyg:text-in-rect-p', ['t_upper_line', 100.0, 200.0, 49.8, 53.2], {})

# Test 4: xyg:find-rect-texts keeps only the rightmost 3 texts if more are found
native['aa:ysdl-get-plain-text'] = lambda ed: ed[1][1]
native['vl-string-trim'] = lambda chars, s: s.strip(chars)
entities = {
    't1': {'bbox': [10.0, 20.0, 51.0, 52.0], 0: [(0, 'TEXT'), (1, 'FAR_LEFT'), (40, 3.0)]},
    't2': {'bbox': [50.0, 60.0, 51.0, 52.0], 0: [(0, 'TEXT'), (1, 'NAME'), (40, 3.0)]},
    't3': {'bbox': [90.0, 100.0, 51.0, 52.0], 0: [(0, 'TEXT'), (1, 'TARGET'), (40, 3.0)]},
    't4': {'bbox': [130.0, 140.0, 51.0, 52.0], 0: [(0, 'TEXT'), (1, 'SPEC'), (40, 3.0)]},
}
right_pt = [150.0, 50.0, 0.0]
all_ss = ['t1', 't2', 't3', 't4']
res_3 = invoke('xyg:find-rect-texts', [right_pt, all_ss], {})
assert res_3 == ['NAME', 'TARGET', 'SPEC'], f'Expected 3 texts, got {res_3}'

# Test 5: xyg:dedup-hlines removes duplicate overlapping lines
entities = {
    'line_a': [(0, 'LINE'), (10, [0.0, 50.0, 0.0]), (11, [150.0, 50.0, 0.0])],
    'line_dup': [(0, 'LINE'), (10, [0.0, 50.0, 0.0]), (11, [150.0, 50.0, 0.0])],
    'line_right': [(0, 'LINE'), (10, [500.0, 50.0, 0.0]), (11, [650.0, 50.0, 0.0])],
    'line_lower': [(0, 'LINE'), (10, [0.0, 45.0, 0.0]), (11, [150.0, 45.0, 0.0])],
}
native['entget'] = lambda en: entities[en]
dedup_res = invoke('xyg:dedup-hlines', [['line_a', 'line_dup', 'line_right', 'line_lower'], 0.5], {})
assert len(dedup_res) == 3, f'Expected 3 lines after deduplication, got {len(dedup_res)}: {dedup_res}'
assert 'line_a' in dedup_res or 'line_dup' in dedup_res
assert 'line_right' in dedup_res and 'line_lower' in dedup_res

# Test 6: xyg:find-right-new-texts handles multiple columns on same row (no duplicate text)
# Row Y=50.0: Line 1 (rightPt=250.0) and Line 5 (rightPt=650.0)
entities = {
    # Line 1's texts
    'rt1_core': [(0, 'TEXT'), (10, [252.0, 50.5, 0.0]), (1, '4')],
    'rt1_p1': [(0, 'TEXT'), (10, [260.0, 50.5, 0.0]), (1, '107')],
    'rt1_p2': [(0, 'TEXT'), (10, [290.0, 50.5, 0.0]), (1, '107A')],
    'rt1_p3': [(0, 'TEXT'), (10, [320.0, 50.5, 0.0]), (1, '101')],
    'rt1_p4': [(0, 'TEXT'), (10, [350.0, 50.5, 0.0]), (1, '133')],
    # Line 5's texts (further to the right on the same Y=50.0 row)
    'rt5_core': [(0, 'TEXT'), (10, [652.0, 50.5, 0.0]), (1, '4')],
    'rt5_p1': [(0, 'TEXT'), (10, [660.0, 50.5, 0.0]), (1, '107')],
    'rt5_p2': [(0, 'TEXT'), (10, [690.0, 50.5, 0.0]), (1, '107A')],
    'rt5_p3': [(0, 'TEXT'), (10, [720.0, 50.5, 0.0]), (1, '101')],
    'rt5_p4': [(0, 'TEXT'), (10, [750.0, 50.5, 0.0]), (1, '133')],
}
native['aa:ysdl-get-plain-text'] = lambda ed: ed[2][1]
all_new_texts = list(entities.keys())

# Case 6a: with limit_x = 495.0 and expected_count = 4
res_6a = invoke('xyg:find-right-new-texts', [[250.0, 50.0, 0.0], all_new_texts, 4, 495.0], {})
assert res_6a == ['4', '107', '107A', '101', '133'], f'Expected 5 texts, got {res_6a}'

# Case 6b: without max_x (relying on gap cutoff and core count truncation)
res_6b = invoke('xyg:find-right-new-texts', [[250.0, 50.0, 0.0], all_new_texts, 4, None], {})
assert res_6b == ['4', '107', '107A', '101', '133'], f'Expected 5 texts, got {res_6b}'

# Case 6c: without max_x and without expected_count (auto-detected from first number "4")
res_6c = invoke('xyg:find-right-new-texts', [[250.0, 50.0, 0.0], all_new_texts, None, None], {})
assert res_6c == ['4', '107', '107A', '101', '133'], f'Expected 5 texts, got {res_6c}'

print(f'PASS: {len(targets)} XYG functions; prefix text detection; 3mm rect filtering & 3-text truncation; hline dedup; right-text cluster/count isolation (no duplicate text across columns); balanced forms and arities')

