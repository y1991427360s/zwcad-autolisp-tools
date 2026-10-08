"""Offline T checks: parsed command structure and real bbox-anchor evaluation."""
from lsp_common import SOURCE, parse, read_source, walk


def check():
    _, source = read_source(SOURCE)
    forms = parse(source)
    funcs = {f[1]: f for f in forms if isinstance(f, list) and f and f[0] == 'defun'}
    for name in ('c:t', 'txt:run', 'txt:modify-text', 'txt:bbox-anchor'):
        assert name in funcs, name + ' must remain top-level'
    command = funcs['c:t']
    assert command[3:] == [['aa:cmd-begin', '"T"'], ['txt:run'], ['aa:cmd-end']]
    assert ['vl-load-com'] in list(walk(funcs['txt:run']))
    calls = list(walk(funcs['txt:modify-text']))
    assert calls.index(['setq', 'ok', ['entmod', 'edata']]) < calls.index(['entupd', 'ename'])
    assert calls.index(['entupd', 'ename']) < calls.index(['setq', 'newbox', ['aa:safe-get-bbox', 'nil', 'ename']])
    assert ['aa:safe-move-entity', 'ename', 'delta'] in calls
    assert ['entmod', 'original'] in calls
    for code, value in ((7, '"HZ"'), (40, '3.0'), (41, '0.7')):
        assert ['txt:set-dxf', str(code), value, 'edata'] in calls
    for name in ('txt:bbox-anchor', 'txt:modify-text'):
        for call in walk(funcs[name][3:]):
            if call[0] == 'setq':
                assert (len(call) - 1) % 2 == 0
            if call[0] == 'if':
                assert len(call) in (3, 4)
            if call[0] == 'cond':
                assert all(isinstance(branch, list) and branch for branch in call[1:])

    # Evaluate the parsed pure LISP helper, not a Python copy of its formulas.
    def anchor(edata, bbox):
        env = {'edata': edata, 'bbox': bbox, 'nil': None, 't': True}
        def ev(x):
            if not isinstance(x, list):
                try:
                    return float(x)
                except ValueError:
                    return env.get(x)
            op, args = x[0], x[1:]
            if op == 'quote':
                return [float(v) for v in args[0]]
            if op == 'setq':
                for i in range(0, len(args), 2):
                    env[args[i]] = ev(args[i + 1])
                return env[args[-2]]
            if op == 'cond':
                for branch in args:
                    if ev(branch[0]):
                        return ev(branch[1])
                return None
            if op == 'or':
                return any(ev(a) for a in args)
            if op == 'and':
                return all(ev(a) for a in args)
            values = [ev(a) for a in args]
            if op == 'assoc':
                return values[1].get(int(values[0]))
            if op == 'cdr':
                return values[0][1] if values[0] is not None else None
            if op == 'car':
                return values[0][0]
            if op == 'cadr':
                return values[0][1]
            if op == 'caddr':
                return values[0][2]
            if op == 'list':
                return values
            if op == 'not':
                return not values[0]
            if op == '=':
                return values[0] == values[1]
            if op == '+':
                return sum(values)
            if op == '/':
                return values[0] / values[1]
            if op == 'equal':
                a, b, tol = values
                if isinstance(a, list):
                    return all(abs(p - q) <= tol for p, q in zip(a, b))
                return a is not None and abs(a - b) <= tol
            raise AssertionError('Unsupported helper operation: ' + op)
        result = None
        for expr in funcs['txt:bbox-anchor'][3:]:
            result = ev(expr)
        return result

    def data(h, v, angle=0, normal=(0, 0, 1)):
        return {72: (72, h), 73: (73, v), 50: (50, angle), 210: (210, list(normal))}
    old = [[8805.2922, 8365.0112, 0], [8810.3381, 8368.6923, 0]]
    new = [[8805.864, 8335.3007, 0], [8809.7663, 8338.3007, 0]]
    before, after = anchor(data(1, 1), old), anchor(data(1, 1), new)
    delta = [a - b for a, b in zip(before, after)]
    assert abs(delta[0]) < 1e-8
    assert abs(delta[1] - 29.7105) < 1e-8
    box = [[10, 20, 0], [16, 28, 0]]
    for h, v, expected in ((0, 1, [10, 20, 0]), (1, 1, [13, 20, 0]),
                            (2, 3, [16, 28, 0]), (1, 2, [13, 24, 0]),
                            (4, 0, [13, 24, 0]), (3, 0, [13, 20, 0]),
                            (5, 0, [13, 20, 0])):
        assert anchor(data(h, v), box) == expected
    assert anchor(data(2, 3, angle=1.57), box) == [13, 24, 0]
    assert anchor(data(2, 3, normal=(0, 1, 0)), box) == [13, 24, 0]
    assert anchor(data(1, 1), old) == before
    print('PASS T: top-level structure, update ordering, QW3 29.7105 mm compensation, alignment anchors')


if __name__ == '__main__':
    check()
