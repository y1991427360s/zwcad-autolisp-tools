"""Execute the actual HWD grouping helper offline; no CAD connection."""
import json
from pathlib import Path
from lsp_common import parse, read_source, defun_forms, walk, ARITY


def check():
    _, source = read_source()
    funcs = {f[1]: f for f in defun_forms(parse(source))}
    for name in ('aa:hwd-rows', 'aa:hwd-make-text', 'c:hwd'):
        assert name in funcs, name
        for node in walk(funcs[name][3:]):
            if isinstance(node[0], str) and node[0] in ARITY:
                lo, hi = ARITY[node[0]]
                assert lo <= len(node) - 1 <= hi, (name, node)
    assert 'key' in funcs['aa:hwd-make-text'][2]
    calls = list(walk(funcs['c:hwd'][3:]))
    assert ['setq', 'y', ['-', 'y', '5.0']] in calls
    assert ['aa:cmd-begin', '"HWD"'] in calls
    assert ['aa:cmd-end'] in calls
    assert not any(n[0] in ('entmod', 'command', 'vl-cmdf') for n in calls)
    assert ['73', '.', '2'] in list(walk(funcs['aa:hwd-make-text']))

    def run(items):
        env = {'items': items, 'rows': []}

        def evaluate(node):
            if not isinstance(node, list):
                return env[node]
            op, *args = node
            if op == 'setq':
                for key, expr in zip(args[::2], args[1::2]):
                    env[key] = evaluate(expr)
                return env[key]
            if op == 'while':
                while evaluate(args[0]):
                    for expr in args[1:]:
                        evaluate(expr)
                return None
            values = [evaluate(a) for a in args]
            return {
                'car': lambda a: a[0], 'cadr': lambda a: a[1],
                'caddr': lambda a: a[2], 'cddr': lambda a: a[2:],
                'list': lambda *a: list(a), 'cons': lambda a, b: [a] + b,
                'reverse': lambda a: a[::-1],
            }[op](*values)

        result = None
        for expression in funcs['aa:hwd-rows'][3:]:
            result = evaluate(expression)
        return result

    root = Path(__file__).resolve().parents[1]
    sample = json.loads((root / 'tests/fixtures/hwd_ring.json').read_text(encoding='utf-8'))
    assert run(sample['input']) == sample['expected']
    for count in (1, 2, 20, 1000):
        items = ['任意柜0']
        expected = []
        for i in range(count):
            code, cabinet = f'任意编号{i}', f'任意柜{i + 1}'
            expected.append([items[-1], code, cabinet])
            items.extend([code, cabinet])
        assert run(items) == expected
    assert run([]) == []
    assert run(['柜A']) == []
    assert run(['同柜', 'X', '同柜', 'X', '同柜']) == [['同柜', 'X', '同柜']] * 2
    print('PASS HWD: actual LISP grouping matches 39-to-57 user sample; arbitrary names, repeated values, 1/2/20/1000 cables; fixed 5-unit rows, left-middle alignment and top-level structure')


if __name__ == '__main__':
    check()
