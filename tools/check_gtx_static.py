"""Parse GTX and execute its pure helpers without connecting to CAD."""
import itertools
import json
import re
from functools import cmp_to_key
from pathlib import Path

from check_fdx_static import ARITY, parse, walk

ROOT = Path(__file__).resolve().parents[1]
data = (ROOT / 'AA整合版本.lsp').read_bytes()
source = data.decode('utf-8', errors='strict')
assert not data.startswith(b'\xef\xbb\xbf') and '\ufffd' not in source
assert b'\n' not in data.replace(b'\r\n', b'')
forms = parse(source)
functions = {f[1]: f for f in forms if isinstance(f, list) and f[:1] == ['defun']}
targets = {k: v for k, v in functions.items() if k.startswith('aa:gtx-') or k == 'c:gtx'}
assert len(targets) == 8
for name, form in targets.items():
    for node in walk(form[3:]):
        head = node[0]
        if not isinstance(head, str):
            continue
        if head in ARITY:
            lo, hi = ARITY[head]
            assert lo <= len(node) - 1 <= hi, (name, head, node)
        if head == 'setq':
            assert len(node) % 2 == 1, (name, node)
        assert head not in ('vl-sort', 'aa:insert-sort'), (name, head)


def truth(x):
    return x is not None and x is not False and x != []


def invoke(fn, args, parent):
    if isinstance(fn, list):
        form = fn
        signature, body = form[1], form[2:]
    else:
        form = functions[fn]
        signature, body = form[2], form[3:]
    n = signature.index('/') if '/' in signature else len(signature)
    env = dict(parent)
    env.update({x: None for x in signature if x != '/'})
    env.update(zip(signature[:n], args))
    result = None
    for expression in body:
        result = evaluate(expression, env)
    return result


def evaluate(node, env):
    if not isinstance(node, list):
        if node.startswith('"'):
            return json.loads(node)
        if node == 'nil':
            return None
        if node == 't':
            return True
        try:
            return float(node) if any(x in node for x in '.e') else int(node)
        except ValueError:
            return env[node]
    if not node:
        return None
    op, *args = node
    if op == 'quote':
        return args[0]
    if op == 'setq':
        for key, expression in zip(args[::2], args[1::2]):
            env[key] = evaluate(expression, env)
        return env[key]
    if op == 'if':
        return evaluate(args[1], env) if truth(evaluate(args[0], env)) else (
            evaluate(args[2], env) if len(args) == 3 else None)
    if op in ('and', 'or'):
        return (all if op == 'and' else any)(truth(evaluate(x, env)) for x in args)
    if op == 'progn':
        result = None
        for x in args:
            result = evaluate(x, env)
        return result
    if op == 'while':
        count = 0
        while truth(evaluate(args[0], env)):
            count += 1
            assert count < 10000
            for x in args[1:]:
                evaluate(x, env)
        return None
    if op == 'foreach':
        for value in evaluate(args[1], env) or []:
            env[args[0]] = value
            for x in args[2:]:
                evaluate(x, env)
        return None
    values = [evaluate(x, env) for x in args]
    if op == 'aa:merge-sort':
        items, comparator = values
        def compare(a, b):
            if truth(invoke(comparator, [a, b], env)):
                return -1
            return 1 if truth(invoke(comparator, [b, a], env)) else 0
        return sorted(items or [], key=cmp_to_key(compare))
    if op in functions:
        return invoke(op, values, env)
    if re.fullmatch('c[ad]+r', op):
        result = values[0]
        for action in reversed(op[1:-1]):
            result = (result[0] if action == 'a' else result[1:]) if result else None
        return result
    builtins = {
        '=': lambda a, b: a == b, '/=': lambda a, b: a != b,
        '<': lambda a, b: a < b, '>': lambda a, b: a > b,
        '+': lambda a, b: a + b, '-': lambda a, b: a - b,
        'not': lambda x: not truth(x), 'strlen': len,
        'substr': lambda s, i, n=None: s[i-1:] if n is None else s[i-1:i-1+n],
        'strcat': lambda *x: ''.join(x), 'strcase': str.upper,
        'vl-string-trim': lambda chars, s: s.strip(chars),
        'vl-string-left-trim': lambda chars, s: s.lstrip(chars),
        'vl-string-translate': lambda a, b, s: s.translate(str.maketrans(a, b)),
        'wcmatch': lambda s, p: bool(re.fullmatch('[0-9]', s)) if p == '#' else s.startswith(p[:-1]),
        'cons': lambda a, b: [a] + (b or []),
        'list': lambda *x: list(x), 'append': lambda a, b: (a or []) + (b or []),
        'max': max,
        'reverse': lambda x: list(reversed(x or [])), 'nth': lambda n, x: x[n],
    }
    return builtins[op](*values)


items = [[str(i), [i * 20, y, 0], i * 20 + 10, 3, str(i)]
         for i, y in enumerate([0, 0.8, 1.6])]
expected = invoke('aa:gtx-rows', [items, 1.0], {})
assert [len(row) for row in expected] == [2, 1]
for permutation in itertools.permutations(items):
    assert invoke('aa:gtx-rows', [list(permutation), 1.0], {}) == expected
boundary = [items[0], ['edge', [20, 1.0, 0], 30, 3, 'A']]
assert len(invoke('aa:gtx-rows', [boundary, 1.0], {})) == 1
assert len(invoke('aa:gtx-rows', [boundary, 0.0], {})) == 2
assert invoke('aa:gtx-rows', [[], 1.0], {}) == []
for a, b in [('A-2', 'A-10'), ('A-1B2', 'A-1B10'),
             ('A-999999999999999', 'A-1000000000000000'), ('A', 'A-1')]:
    assert invoke('aa:gtx-natural-less', [a, b], {})
    assert not invoke('aa:gtx-natural-less', [b, a], {})
    assert not invoke('aa:gtx-natural-less', [a, a], {})
calls = list(walk(functions['c:gtx']))
assert not any(n[0] in ('getreal', 'getdist', 'getint', 'getkword', 'initget')
               for n in calls if isinstance(n[0], str)), 'GTX tolerances must be automatic'
split = next(n for n in calls if n[:3] == ['foreach', 'line', 'lines']
             and any(x[:2] == ['setq', 'current-item-x'] for x in walk(n)))
for left, expected_count in [(210, 1), (210.01, 2), (5, 1)]:
    row = [['A', [0, 0, 0], 10, 3, '1'], ['B', [left, 0, 0], left + 10, 3, '2']]
    env = {'lines': [row], 'split-groups': None, 'gap-limit': 200}
    evaluate(split, env)
    assert len(env['split-groups']) == expected_count
assert invoke('aa:gtx-key', ['  并入a－2  '], {}) == 'A-2'
assert ['trans', 'pt', '1', '0'] in calls
assert ['aa:ysdl-get-plain-text', 'ent-data'] in calls
assert ['aa:undo-mark-on'] in calls and ['aa:undo-mark-off'] in calls
assert ['aa:gtx-rows', 'text-data', 'row-tol'] in calls
assert ['-', 'current-item-x', 'last-item-x'] in calls
print(f'PASS: {len(forms)} top-level forms; GTX arities, UTF-8 and CRLF')
print('PASS: actual helpers: permutations, boundaries, edge gaps, normalization, natural numbers')
