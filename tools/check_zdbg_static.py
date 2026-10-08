"""Execute the actual ZDBG layout helpers on QW3 coordinates, without CAD."""
import json
import math
import random
from functools import cmp_to_key
from pathlib import Path

from lsp_common import ARITY, defun_forms, parse, read_source, walk


def check():
    _, source = read_source()
    funcs = {f[1]: f for f in defun_forms(parse(source))}
    affected = {n: f for n, f in funcs.items()
                if n.startswith('aa:zdbg-') or n == 'c:zdbg'}
    assert len(affected) == 6
    for name, form in affected.items():
        for node in walk(form[3:]):
            if isinstance(node[0], str) and node[0] in ARITY:
                lo, hi = ARITY[node[0]]
                assert lo <= len(node) - 1 <= hi, (name, node)
            if node[0] == 'setq':
                assert len(node) % 2 == 1, (name, node)

    def truth(value):
        return value is not None and value is not False and value != []

    def invoke(fn, args, parent):
        sig, body = (fn[1], fn[2:]) if isinstance(fn, list) else (funcs[fn][2], funcs[fn][3:])
        split = sig.index('/') if '/' in sig else len(sig)
        env = parent | dict.fromkeys(sig[split + 1:]) | dict(zip(sig[:split], args))
        result = None
        for expression in body:
            result = evaluate(expression, env)
        return result

    def evaluate(node, env):
        if not isinstance(node, list):
            if node == 'nil':
                return None
            if node == 't':
                return True
            try:
                return float(node) if '.' in node or 'e' in node else int(node)
            except ValueError:
                return env[node]
        op, *args = node
        if op == 'quote':
            return args[0]
        if op == 'setq':
            for key, expr in zip(args[::2], args[1::2]):
                env[key] = evaluate(expr, env)
            return env[key]
        if op == 'if':
            return evaluate(args[1], env) if truth(evaluate(args[0], env)) else (
                evaluate(args[2], env) if len(args) == 3 else None)
        if op in ('and', 'or'):
            return (all if op == 'and' else any)(truth(evaluate(a, env)) for a in args)
        if op == 'progn':
            result = None
            for expr in args:
                result = evaluate(expr, env)
            return result
        if op == 'foreach':
            for value in evaluate(args[1], env) or []:
                env[args[0]] = value
                for expr in args[2:]:
                    evaluate(expr, env)
            return None
        if op == 'while':
            while truth(evaluate(args[0], env)):
                for expr in args[1:]:
                    evaluate(expr, env)
            return None
        if op == 'repeat':
            for _ in range(evaluate(args[0], env)):
                for expr in args[1:]:
                    evaluate(expr, env)
            return None
        values = [evaluate(a, env) for a in args]
        if op in funcs and op != 'aa:merge-sort':
            return invoke(op, values, env)
        if op == 'aa:merge-sort':
            items, predicate = values
            def compare(a, b):
                return -1 if truth(invoke(predicate, [a, b], env)) else (
                    1 if truth(invoke(predicate, [b, a], env)) else 0)
            return sorted(items or [], key=cmp_to_key(compare))
        builtins = {
            'nth': lambda i, xs: xs[i], 'car': lambda xs: xs[0],
            'cons': lambda a, xs: [a] + (xs or []), 'list': lambda *xs: list(xs),
            'reverse': lambda xs: list(reversed(xs or [])), 'length': len,
            '+': lambda *xs: sum(xs), '-': lambda a, b: a - b,
            '*': lambda a, b: a * b, '/': lambda a, b: a / b,
            '<': lambda a, b: a < b, '<=': lambda a, b: a <= b,
            '>': lambda a, b: a > b,
            'equal': lambda a, b, tol: abs(a - b) <= tol,
            'abs': abs, 'max': max, '1+': lambda x: x + 1,
            'null': lambda x: not truth(x), 'not': lambda x: not truth(x),
            'member': lambda x, xs: x in (xs or []),
        }
        return builtins[op](*values)

    fixture = json.loads((Path(__file__).parent / 'fixtures/zdbg_qw3.json').read_text(encoding='utf-8'))
    items = [record['item'] for record in fixture]
    expected = invoke('aa:zdbg-plan', [items, 1.8], {})
    moves, xs, ys = expected
    assert len(moves) == 50 and len(xs) == 7 and len(ys) == 10
    assert math.isclose(ys[-1] - ys[0], 45)
    assert all(math.isclose(b - a, 5) for a, b in zip(ys, ys[1:]))
    cols = invoke('aa:zdbg-groups', [items, 1, 1.8], {})
    assert [len(col) for col in cols] == [9, 8, 9, 9, 9, 6]
    for col, a, b in zip(cols, xs, xs[1:]):
        assert math.isclose(b - a, max(item[3] for item in col) + 6)
    by_id = {move[0][0]: move for move in moves}
    for record in fixture:
        item, tx, ty = by_id[record['item'][0]]
        assert tx - item[3] / 2 >= xs[0] + 3 - 1e-7
        assert ty - item[4] / 2 >= ys[0] + 0.5 - 1e-7
        # Bottom header stays below all numbered rows.
        if record['text'] in ('序号', '标  号', '名  称', '型号规格', '数量', '备注'):
            assert math.isclose(ty, ys[0] + 2.5)
    rng = random.Random(7)
    for _ in range(20):
        shuffled = items.copy()
        rng.shuffle(shuffled)
        actual = invoke('aa:zdbg-plan', [shuffled, 1.8], {})
        assert actual[1:] == expected[1:]
        assert sorted(actual[0]) == sorted(expected[0])
    # Two, three and four separate texts in one cell grow only that row.
    for count in (2, 3, 4):
        multiple = [[f'text{i}', 0, i * 0.2, 4, 3, 0] for i in range(count)]
        single = ['other-column', 20, 0.1, 6, 3, 0]
        next_row = ['next-row', 0, 10, 4, 3, 0]
        sample = multiple + [single, next_row]
        actual = invoke('aa:zdbg-plan', [sample, 1.8], {})
        assert [b - a for a, b in zip(actual[2], actual[2][1:])] == [count * 5, 5]
        by_name = {m[0][0]: m for m in actual[0]}
        bottom = actual[2][0]
        assert by_name['other-column'][2] == bottom + count * 2.5
        for i in range(count):
            assert by_name[f'text{i}'][2] == bottom + 2.5 + i * 5
        for _ in range(5):
            rng.shuffle(sample)
            shuffled_plan = invoke('aa:zdbg-plan', [sample, 1.8], {})
            assert shuffled_plan[1:] == actual[1:]
            assert sorted(shuffled_plan[0]) == sorted(actual[0])
    # Tall MTEXT needs sufficient slots, with half a unit of margin per side.
    tall = ['mtext', 0, 0, 8, 11, 0]
    actual = invoke('aa:zdbg-plan', [[tall, ['short', 20, 0, 4, 3, 0]], 1.8], {})
    assert actual[2][-1] - actual[2][0] == 15
    assert all(math.isclose(m[2], actual[2][0] + 7.5) for m in actual[0])
    for height, slots in ((4, 1), (4.0001, 2), (9, 2), (14, 3)):
        assert invoke('aa:zdbg-slots', [['x', 0, 0, 1, height, 0]], {}) == slots
    # User's 183-object drawing: the previous duplicate cell now has height 10.
    new_fixture = json.loads((Path(__file__).parent / 'fixtures/zdbg_multitext_qw3.json').read_text(encoding='utf-8'))
    new_items = [r['item'] for r in new_fixture]
    actual = invoke('aa:zdbg-plan', [new_items, 1.5], {})
    assert len(actual[0]) == 183
    heights = [b - a for a, b in zip(actual[2], actual[2][1:])]
    assert heights.count(10) == 1 and heights.count(5) == 42
    by_name = {m[0][0]: m for m in actual[0]}
    duplicates = [r['item'][0] for r in new_fixture if r['text'] in ('NYD-SSD-III(G)-2005', 'JL1-2.5/2;红色\\\\')]
    assert len(duplicates) == 2
    assert math.isclose(abs(by_name[duplicates[0]][2] - by_name[duplicates[1]][2]), 5)
    for _ in range(10):
        rng.shuffle(new_items)
        shuffled_plan = invoke('aa:zdbg-plan', [new_items, 1.5], {})
        assert shuffled_plan[1:] == actual[1:]
        assert sorted(shuffled_plan[0]) == sorted(actual[0])
    shifted = [[i[0], i[1] - 20000, i[2] - 20000, i[3], i[4], 15] for i in items]
    actual = invoke('aa:zdbg-plan', [shifted, 1.8], {})
    assert all(math.isclose(a - 20000, b) for a, b in zip(xs, actual[1]))
    assert all(math.isclose(a - 20000, b) for a, b in zip(ys, actual[2]))
    move_source = affected['aa:zdbg-move']
    assert ['trans', ['list', 'dx', 'dy', '0.0'], '0', 'en', 't'] in list(walk(move_source))
    assert ['aa:cmd-begin', '"ZDBG"'] in list(walk(affected['c:zdbg']))
    assert ['aa:cmd-end'] in list(walk(affected['c:zdbg']))
    print('PASS ZDBG: actual layout on 50 QW3 texts, 9 rows/6 columns, '
          '5-unit rows, automatic widths, bottom header, 4 empty cells, '
          'selection permutations, translated coordinates; 10/15/20-unit rows, '
          'centered text groups, tall MTEXT and 183-text duplicate-cell regression')


if __name__ == '__main__':
    check()
