"""Offline regression of the actual ZDWI border walker; never connects to CAD."""
import operator

from lsp_common import ARITY, defun_forms, parse, read_source, walk


def quoted(value):
    if isinstance(value, list):
        return [quoted(item) for item in value]
    return value[1:-1] if value.startswith('"') else value


def lisp_equal(a, b, tol=0):
    if isinstance(a, (list, tuple)) and isinstance(b, (list, tuple)):
        return len(a) == len(b) and all(lisp_equal(x, y, tol) for x, y in zip(a, b))
    if isinstance(a, (int, float)) and isinstance(b, (int, float)):
        return abs(a - b) <= tol
    return a == b


def truth(value):
    # AutoLISP regards numeric zero as true (including column index zero).
    return value is not None and value is not False and value != []


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
        for item in evaluate(args[1], env) or []:
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
        branch = 1 if truth(evaluate(args[0], env)) else 2
        return evaluate(args[branch], env) if branch < len(args) else None
    if head == 'and':
        return all(truth(evaluate(arg, env)) for arg in args)
    if head == 'or':
        return any(truth(evaluate(arg, env)) for arg in args)
    if head == 'cond':
        for clause in args:
            value = evaluate(clause[0], env)
            if truth(value):
                for arg in clause[1:]:
                    value = evaluate(arg, env)
                return value
        return None
    if head in ('progn', 'while', 'repeat'):
        body = args if head == 'progn' else args[1:]
        count = evaluate(args[0], env) if head == 'repeat' else 1
        value = None
        iterations = 0
        while count > 0 and (head != 'while' or truth(evaluate(args[0], env))):
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
        split = signature.index('/') if '/' in signature else len(signature)
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
        'not': lambda x: not truth(x), 'null': lambda x: not truth(x),
        'member': lambda x, xs: x in xs,
        'cons': lambda a, b: [a] + (b or []) if b is None or isinstance(b, list) else (a, b),
        'ssget': lambda *args: env['__ssget'](*args),
        'ssadd': lambda *args: [] if not args else add_entity(*args),
        'trans': lambda p, _from, _to: p,
        'aa:safe-get-bbox': lambda _, en: en['bbox'],
        'list': lambda *xs: list(xs), 'append': lambda a, b: (a or []) + (b or []),
        'logand': operator.and_, '1+': lambda x: x + 1, '1-': lambda x: x - 1,
        '=': operator.eq, '/=': operator.ne, '>': operator.gt, '<': operator.lt,
        'length': len, 'reverse': lambda xs: list(reversed(xs or [])),
        '>=': operator.ge, '<=': operator.le,
        '+': lambda *xs: sum(xs), '-': operator.sub, '*': operator.mul, '/': operator.truediv,
        'last': lambda xs: xs[-1], 'itoa': str, 'strcat': lambda *xs: ''.join(xs),
        'abs': abs, 'min': min, 'max': max,
        'equal': lisp_equal,
    }
    builtins.update(env.get('__builtins', {}))
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
    # Long labels crossing either outer border must remain in the table.
    overflow_left = label | {'bbox': [[4495, -3200], [4535, -3197]]}
    overflow_right = label | {'bbox': [[4650, -3200], [4690, -3197]]}
    outside_text = label | {'bbox': [[4480, -3200], [4500, -3197]]}
    assert expand(funcs, inside + [overflow_left, overflow_right, outside_text],
                  [top]) == inside + [overflow_left, overflow_right]

    # Reduced QW3 fixture from the 2026-10-12 equipment table. Execute the
    # actual command with CAD reads/writes replaced by offline captures.
    xs = [10403.7177, 10412.4677, 10453.7177, 10499.9677,
          10537.4677, 10547.4677, 10569.9677, 10643.7177]
    frame = {'type': 'LWPOLYLINE', 'flags': 1, 'layer': '0',
             'pts': [[xs[0], -13953.3478], [xs[-1], -13953.3478],
                     [xs[-1], -13880.8478], [xs[0], -13880.8478]]}
    grid = [frame] + [line([x, -13953.3478], [x, -13880.8478], '0')
                      for x in xs[1:-1]]
    extents = [(10406.1994, 10409.986), (10431.1746, 10435.0108),
               (10474.9494, 10478.736), (10516.7913, 10520.6441),
               (10540.5165, 10544.4189), (10555.824, 10561.6114),
               (10604.8171, 10608.8683),
               (10400.1927, 10465.9927),  # 65.8-unit overflowing identifier
               (10500.1677, 10537.2677)]  # 37.1-unit model
    labels = [{'type': 'TEXT', 'layer': '0',
               'bbox': [[a, -13927.5978], [b, -13924.0978]]}
              for a, b in extents]
    selected = expand(funcs, grid + labels, [frame])
    assert selected == grid + labels, 'Overflowing QW3 identifier was lost'
    mapped, moved, undo, centered = [], [], [], []

    def center_table(doc, texts, lines):
        assert undo == ['begin'], 'Centering must share the open ZDWI undo group'
        assert len(mapped) == len(grid) and len(moved) == len(labels)
        centered.append((texts, lines))
        return [len(texts), 0]

    command_env = {
        '__functions': {name: form for name, form in affected.items()
                        if name not in ('aa:zdwi-vertices', 'aa:zdwi-map-entity',
                                        'aa:zdwi-expand-selection')},
        'aa:doc': 'doc',
        '__ssget': lambda *args: selected,
        '__builtins': {
            'vl-load-com': lambda: None, 'princ': lambda *args: None,
            'aa:zdwi-expand-selection': lambda ss: ss,
            'aa:merge-sort': lambda values, comparator: sorted(values),
            'aa:cmd-begin': lambda tag: undo.append('begin'),
            'aa:cmd-end': lambda: undo.append('end'),
            'aa:zdwi-map-entity': lambda en, old, new:
                mapped.append((old, new)) or True,
            'aa:zz-center-texts': center_table,
            'aa:zz-move-text': lambda en, x, y, target, target_y:
                moved.append((en, x, target)) or True,
            'redraw': lambda: None, 'sssetfirst': lambda *args: None,
        },
    }
    evaluate(['c:zdwi'], command_env)
    assert len(mapped) == len(grid) and len(moved) == len(labels)
    assert undo == ['begin', 'end'], undo
    assert centered == [(labels, grid)], 'All table texts must be centered against updated table lines'
    old, new = mapped[0]
    widths = [b - a for a, b in zip(new, new[1:])]
    assert abs(widths[1] - 71.8) < 1e-7, widths
    assert abs(widths[3] - 43.1) < 1e-7, widths
    assert widths[1] > old[2] - old[1]  # Widen identifier.
    assert widths[3] > old[4] - old[3]  # Widen model in the same execution.
    assert widths[2] < old[3] - old[2]  # Narrow name.
    assert widths[6] < old[7] - old[6]  # Narrow remarks.
    for en, center, target in moved:
        col = next(i for i in range(7) if old[i] <= center <= old[i + 1])
        half = (en['bbox'][1][0] - en['bbox'][0][0]) / 2
        assert target - half >= new[col] + 3 - 1e-7
        assert target + half <= new[col + 1] - 3 + 1e-7
    # Execute the shared helper to verify normalization, collection, skipping
    # and grouping. ZZ and ZDWI must both delegate to this same function.
    helper = funcs['aa:zz-center-texts']
    calls = []
    helper_env = {
        '__functions': {'aa:zz-center-texts': helper},
        'doc': 'doc', 'texts': ['a', 'outside', 'b'], 'lines': ['new-grid'],
        '__builtins': {
            'aa:zz-build-spatial-index': lambda lines, tol:
                calls.append(('index', lines)) or 'index',
            'aa:normalize-text-vertical-align': lambda doc, en, mode:
                calls.append(('normalize', en, mode)) or True,
            'aa:zz-text-info': lambda doc, en, tol, index:
                calls.append(('info', en)) or (None if en == 'outside' else [en]),
            'aa:zz-group-by-rect': lambda infos, tol:
                calls.append(('group', infos)) or [infos],
            'aa:zz-apply-group': lambda group: len(group),
        },
    }
    assert evaluate(['aa:zz-center-texts', 'doc', 'texts', 'lines'], helper_env) == [2, 1]
    assert calls == [('index', ['new-grid']), ('normalize', 'a', 3), ('info', 'a'),
                     ('normalize', 'outside', 3), ('info', 'outside'),
                     ('normalize', 'b', 3), ('info', 'b'), ('group', [['a'], ['b']])]
    for name in ('c:zdwi', 'aa:zz-run'):
        assert any(node[0] == 'aa:zz-center-texts' for node in walk(funcs[name][3:]))
    assert not any(node[0] in ('ssget', 'vla-startundomark', 'vla-endundomark',
                             'aa:cmd-begin', 'aa:cmd-end') for node in walk(helper[3:]))
    print('PASS ZDWI/ZZ: shared centering, all table texts, updated lines, one undo group')
    print('PASS ZDWI: command structure, closed/open row borders, reversed vertices, '
          'LINE chains, disconnected frames, mixed-layer selection, overflow '
          'retention and simultaneous column expansion/contraction with margins '
          '(actual LISP functions)')


if __name__ == '__main__':
    check()
