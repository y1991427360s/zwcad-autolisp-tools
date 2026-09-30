"""Offline regression of the actual ZDWI border walker; never connects to CAD."""
import operator

from lsp_common import ARITY, defun_forms, parse, read_source, walk


def evaluate(expr, env):
    if not isinstance(expr, list):
        if expr in env:
            return env[expr]
        if expr == 'nil':
            return None
        if expr == 't':
            return True
        try:
            return float(expr) if '.' in expr or 'e' in expr else int(expr)
        except ValueError:
            raise AssertionError('Unsupported symbol: ' + expr)
    head, *args = expr
    if head == 'setq':
        value = None
        for name, arg in zip(args[::2], args[1::2]):
            value = env[name] = evaluate(arg, env)
        return value
    if head == 'if':
        branch = 1 if evaluate(args[0], env) else 2
        return evaluate(args[branch], env) if branch < len(args) else None
    if head == 'and':
        return all(evaluate(arg, env) for arg in args)
    if head == 'cond':
        for clause in args:
            value = evaluate(clause[0], env)
            if value:
                for arg in clause[1:]:
                    value = evaluate(arg, env)
                return value
        return None
    if head in ('progn', 'while', 'repeat'):
        body = args if head == 'progn' else args[1:]
        count = evaluate(args[0], env) if head == 'repeat' else 1
        value = None
        iterations = 0
        while count > 0 and (head != 'while' or evaluate(args[0], env)):
            iterations += 1
            assert iterations < 10000, 'Unexpected nonterminating loop'
            for arg in body:
                value = evaluate(arg, env)
            if head != 'while':
                count -= 1
        return value
    values = [evaluate(arg, env) for arg in args]
    builtins = {
        'sslength': len, 'ssname': lambda ss, i: ss[i],
        'entget': lambda en: {'70': en.get('flags', 0)},
        'assoc': lambda key, ed: ed.get(str(key)),
        'aa:zdwi-vertices': lambda en: en['pts'],
        'car': lambda xs: xs[0] if xs else None,
        'cdr': lambda xs: xs[1:] if isinstance(xs, list) else xs,
        'cadr': lambda xs: xs[1],
        'list': lambda *xs: list(xs), 'append': operator.add,
        'logand': operator.and_, '1+': lambda x: x + 1,
        '=': operator.eq, '>': operator.gt, '<': operator.lt,
        '>=': operator.ge, '<=': operator.le,
        '+': operator.add, '-': operator.sub, 'min': min, 'max': max,
        'equal': lambda a, b, tol: abs(a - b) <= tol,
    }
    assert head in builtins, 'Unsupported call: ' + head
    return builtins[head](*values)


def check():
    _, text = read_source()
    funcs = {f[1]: f for f in defun_forms(parse(text))}
    affected = {name: f for name, f in funcs.items()
                if name.startswith('aa:zdwi-') or name == 'c:zdwi'}
    assert 'c:zdwi' in affected, 'ZDWI must remain a top-level command'
    for form in affected.values():
        for node in walk(form[3:]):
            if isinstance(node[0], str) and node[0] in ARITY:
                low, high = ARITY[node[0]]
                assert low <= len(node) - 1 <= high, node
    form = funcs['aa:zdwi-border-range']

    def border(ss, x, seed_y):
        env = dict.fromkeys(form[2][form[2].index('/') + 1:])
        env.update(ss=ss, x=x, **{'seed-y': seed_y, 'aa:zdwi-tol': 0.5})
        result = None
        for expr in form[3:]:
            result = evaluate(expr, env)
        return result

    # Ten closed row frames, using the coordinates and vertex order from QW3.
    x1, x2 = 4566.7621, 4884.4786
    ys = [4265.2158, 4270.2158, 4275.2158, 4280.2158, 4285.2158,
          4290.2158, 4305.2158, 4315.2158, 4320.2158, 4325.2158, 4332.7158]
    rows = [{'flags': 1, 'pts': [[x1, a], [x2, a], [x2, b], [x1, b]]}
            for a, b in zip(ys, ys[1:])]
    for seed_y in ys:
        for x in (x1, x2):
            assert border(rows, x, seed_y) == [ys[0], ys[-1]], (x, seed_y)
    # Reversing vertices must retain both implicit borders.
    reversed_rows = [row | {'pts': list(reversed(row['pts']))} for row in rows]
    assert border(reversed_rows, x2, ys[5]) == [ys[0], ys[-1]]
    # An open polyline must not acquire an invented closing edge.
    assert border([rows[0] | {'flags': 0}], x1, ys[0]) is None
    lines = [{'pts': [[x1, a], [x1, b]]} for a, b in zip(ys, ys[1:])]
    assert border(lines, x1, ys[5]) == [ys[0], ys[-1]]
    # A disconnected frame must not extend the connected table range.
    detached = {'flags': 1, 'pts': [[x1, 4400], [x2, 4400],
                                  [x2, 4405], [x1, 4405]]}
    assert border(rows + [detached], x1, ys[5]) == [ys[0], ys[-1]]
    print('PASS ZDWI: command structure, closed/open row borders, reversed vertices, '
          'LINE chains and disconnected frames (actual LISP border function)')


if __name__ == '__main__':
    check()
