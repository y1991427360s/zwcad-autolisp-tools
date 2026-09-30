"""Offline regression of the actual ZDWI border walker; never connects to CAD."""
import operator

from lsp_common import ARITY, defun_forms, parse, read_source, walk


def quoted(value):
    if isinstance(value, list):
        return [quoted(item) for item in value]
    return value[1:-1] if value.startswith('"') else value


def evaluate(expr, env):
    if not isinstance(expr, list):
        if expr.startswith('"'):
            return expr[1:-1]
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
    if head == 'quote':
        return quoted(args[0])
    if head == 'foreach':
        value = None
        for item in evaluate(args[1], env):
            env[args[0]] = item
            for arg in args[2:]:
                value = evaluate(arg, env)
        return value
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
    if head == 'or':
        return any(evaluate(arg, env) for arg in args)
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
    if head in env.get('__functions', {}):
        form = env['__functions'][head]
        signature = form[2]
        split = signature.index('/')
        scope = env | dict.fromkeys(signature[split + 1:])
        scope.update(zip(signature[:split], values))
        result = None
        for arg in form[3:]:
            result = evaluate(arg, scope)
        return result
    builtins = {
        'sslength': len, 'ssname': lambda ss, i: ss[i],
        'entget': lambda en: {'70': en.get('flags', 0),
                             '0': en.get('type', 'LINE'), '8': en.get('layer', '0')},
        'assoc': lambda key, ed: ed.get(str(key)),
        'aa:zdwi-vertices': lambda en: en.get('pts'),
        'car': lambda xs: xs[0] if xs else None,
        'cdr': lambda xs: xs[1:] if isinstance(xs, list) else xs,
        'cadr': lambda xs: xs[1],
        'caddr': lambda xs: xs[2],
        'caar': lambda xs: xs[0][0], 'caadr': lambda xs: xs[1][0],
        'cadar': lambda xs: xs[0][1], 'cadadr': lambda xs: xs[1][1],
        'nth': lambda i, xs: xs[i],
        'not': lambda x: not x, 'null': lambda x: x is None or x == [],
        'member': lambda x, xs: x in xs,
        'cons': lambda a, b: (a, b),
        'ssget': lambda *args: env['__ssget'](*args),
        'ssadd': lambda *args: [] if not args else add_entity(*args),
        'trans': lambda p, _from, _to: p,
        'aa:safe-get-bbox': lambda _, en: en['bbox'],
        'list': lambda *xs: list(xs), 'append': operator.add,
        'logand': operator.and_, '1+': lambda x: x + 1,
        '=': operator.eq, '>': operator.gt, '<': operator.lt,
        '>=': operator.ge, '<=': operator.le,
        '+': operator.add, '-': operator.sub, 'min': min, 'max': max,
        'equal': lambda a, b, tol: abs(a - b) <= tol,
    }
    assert head in builtins, 'Unsupported call: ' + head
    return builtins[head](*values)


def add_entity(en, ss):
    if en not in ss:
        ss.append(en)
    return ss


def expand(funcs, entities, seed):
    def ssget(_mode, p, q, filters):
        allowed_layer = None
        for record in filters:
            if str(record[0]) == '8':
                allowed_layer = record[-1]
        result = []
        for en in entities:
            if allowed_layer is not None and en['layer'] != allowed_layer:
                continue
            # The first lookup only requests geometry; the second also text.
            if en['type'] == 'TEXT' and 'TEXT' not in str(filters):
                continue
            box = en.get('bbox')
            if box is None:
                pts = en['pts']
                box = [[min(v[0] for v in pts), min(v[1] for v in pts)],
                       [max(v[0] for v in pts), max(v[1] for v in pts)]]
            if (box[0][0] <= q[0] and box[1][0] >= p[0]
                    and box[0][1] <= q[1] and box[1][1] >= p[1]):
                result.append(en)
        return result or None

    # Execute actual seed selection, border walking and expanded-selection code.
    names = ('aa:zdwi-seed', 'aa:zdwi-border-range', 'aa:zdwi-expand-selection')
    env = {'__functions': {name: funcs[name] for name in names}, '__ssget': ssget,
           'aa:zdwi-tol': 0.5, 'selected': seed}
    return evaluate(['aa:zdwi-expand-selection', 'selected'], env)


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
    # Second QW3 case: LINE-layer horizontals, 0-layer outer borders,
    # tiny endpoint offsets, a partial divider and TEXT-layer labels.
    def line(p, q, layer):
        return {'type': 'LINE', 'layer': layer, 'pts': [p, q]}

    top = line([4510.1771, -3133.4611], [4670.0104, -3133.4611], 'LINE')
    bottom = line([4510.1637, -3234.719], [4669.9227, -3234.719], 'LINE')
    left = line([4510.1637, -3133.4611], [4510.1637, -3234.719], '0')
    right = line([4669.9227, -3234.719], [4669.9227, -3133.4611], '0')
    divider = line([4570.5929, -3228.461], [4570.5929, -3133.4611], 'LINE')
    label = {'type': 'TEXT', 'layer': 'TEXT',
             'bbox': [[4512.8403, -3233.0546], [4516.6269, -3230.1254]]}
    inside = [top, bottom, left, right, divider, label]
    outside = line([4510.1637, -3300], [4510.1637, -3295], '0')
    assert expand(funcs, inside + [outside], [top]) == inside
    # A selected whole table and a same-layer table also retain all entities.
    assert expand(funcs, inside, inside) == inside
    same_layer = [en | {'layer': '0'} for en in inside]
    assert expand(funcs, same_layer, [same_layer[0]]) == same_layer
    assert expand(funcs, [top, bottom, divider, label], [top]) is None
    print('PASS ZDWI: command structure, closed/open row borders, reversed vertices, '
          'LINE chains, disconnected frames and mixed-layer selection '
          '(actual LISP functions)')


if __name__ == '__main__':
    check()
