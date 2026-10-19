"""Check FDX source structure without loading a CAD process."""
from lsp_common import ARITY, SOURCE, parse, walk  # re-export for sibling checks


def check():
    source = SOURCE.read_text(encoding='utf-8')
    forms = parse(source)
    targets = [f for f in forms if isinstance(f, list) and f[:1] == ['defun']
               and (f[1].startswith('fdx:') or f[1] == 'c:fdx')]
    assert len(targets) == 12, f'Unexpected FDX function count: {len(targets)}'
    signatures = {f[1]: f[2].index('/') if '/' in f[2] else len(f[2]) for f in targets}
    for form in targets:
        declared = set(form[2]) | {'pending'}
        for node in walk(form[3:]):
            head = node[0]
            if not isinstance(head, str):
                continue
            count = len(node) - 1
            if head in ARITY:
                low, high = ARITY[head]
                assert low <= count <= high, (form[1], head, count)
            if head in signatures:
                assert count == signatures[head], (form[1], head, count)
            if head == 'setq':
                assert count % 2 == 0, (form[1], 'odd setq')
                assert all(n in declared for n in node[1::2]), (form[1], node[1::2])
            if head == 'foreach':
                assert node[1] in declared, (form[1], 'undeclared loop', node[1])
    assert '(defun c:FDX ' in source
    preview = next(f for f in targets if f[1] == 'fdx:show-frame')
    check_horizontal_batch(next(f for f in targets if f[1] == 'fdx:place'))
    check_preview(preview)
    check_frame_order(next(f for f in targets if f[1] == 'fdx:sort-frames'))
    check_pair_rows(next(f for f in forms if isinstance(f, list)
                         and f[:2] == ['defun', 'dx:pair-rows']))
    for form in targets:
        for node in walk(form):
            assert not (node[0] == 'car' and len(node) == 2
                        and isinstance(node[1], list) and node[1][:1] == ['last']), \
                (form[1], 'AutoLISP last returns the element, not a tail list')
    print(f'PASS: {len(targets)} FDX functions; balanced forms, call arities, local assignments')


def check_frame_order(form):
    """Evaluate the actual frame sorting body, including its lambda comparators."""
    from functools import cmp_to_key
    a = [0, 80, 30, 100, 0]
    b = [100, 80, 130, 100, 0]
    c = [200, 80, 230, 100, 0]
    d = [0, 20, 30, 40, 0]
    e = [100, 20, 130, 40, 0]
    f = [200, 20, 230, 40, 0]
    # Input order is deliberately unrelated to row/column order.
    jitter = [100, 79, 130, 99, 0]
    beyond = [100, 77, 130, 97, 0]
    negative = [-100, -80, -70, -60, 5]
    cases = [
        ([], []), ([a], [a]),
        ([f, b, d, c, a, e], [a, b, c, d, e, f]),
        ([e, b, a, d], [a, b, d, e]),
        ([c, a, b], [a, b, c]), ([d, a], [a, d]),
        ([e, jitter, a, d], [a, jitter, d, e]),
        ([beyond, c, a], [a, c, beyond]),
        ([negative, a, d], [a, d, negative]),
    ]
    for rects, expected in cases:
        env = {name: None for name in form[2] if name != '/'}
        env['rects'] = rects

        def evaluate(node):
            if not isinstance(node, list):
                if node in env:
                    return env[node]
                return float(node)
            op, *args = node
            if op == 'quote':
                return args[0]
            if op == 'setq':
                for name, expression in zip(args[::2], args[1::2]):
                    env[name] = evaluate(expression)
                return env[name]
            if op == 'and':
                return all(evaluate(arg) for arg in args)
            if op == 'while':
                iterations = 0
                while evaluate(args[0]):
                    iterations += 1
                    assert iterations <= len(rects)
                    for expression in args[1:]:
                        evaluate(expression)
                return None
            if op == 'foreach':
                for value in evaluate(args[1]):
                    env[args[0]] = value
                    for expression in args[2:]:
                        evaluate(expression)
                return None
            values = [evaluate(arg) for arg in args]
            if op == 'aa:merge-sort':
                items, comparator = values
                assert comparator[0] == 'lambda'
                def compare(left, right):
                    env.update(zip(comparator[1], [left, right]))
                    forward = evaluate(comparator[2])
                    env.update(zip(comparator[1], [right, left]))
                    backward = evaluate(comparator[2])
                    return -1 if forward else (1 if backward else 0)
                return sorted(items or [], key=cmp_to_key(compare))
            functions = {
                'car': lambda x: x[0] if x else None,
                'cdr': lambda x: x[1:] if x else None,
                'cadr': lambda x: x[1],
                'caar': lambda x: x[0][0],
                'nth': lambda i, x: x[int(i)],
                'list': lambda *x: list(x),
                'cons': lambda a, b: [a] + (b or []),
                'reverse': lambda x: list(reversed(x or [])),
                'abs': abs, '-': lambda a, b: a - b,
                '*': lambda a, b: a * b, '<': lambda a, b: a < b,
                '>': lambda a, b: a > b, '<=': lambda a, b: a <= b,
            }
            return functions[op](*values)

        for expression in form[3:]:
            actual = evaluate(expression)
        assert actual == expected, (rects, actual, expected)
    print('PASS: FDX row order; rows left-to-right, jitter, negative coordinates, empty input')


def check_pair_rows(form):
    """Evaluate the actual pairing body for staggered rows and unequal columns."""
    white = [['w1', 0, 100, 2, 2], ['w2', 0, 90, 2, 2]]
    cyan = [['c1', 0, 40, 2, 2], ['c2', 0, 20, 2, 2]]
    cases = [
        (white, cyan, [[white[0], cyan[0]], [white[1], cyan[1]]]),
        (white, cyan[:1], [[white[0], cyan[0]], [white[1], None]]),
        (white[:1], cyan, [[white[0], cyan[0]], [None, cyan[1]]]),
        ([], cyan, [[None, cyan[0]], [None, cyan[1]]]),
        (white, [], [[white[0], None], [white[1], None]]),
        ([], [], []),
    ]
    for terminals, principles, expected in cases:
        env = {name: None for name in form[2] if name != '/'}
        env.update(terminals=terminals, principles=principles)

        def evaluate(node):
            if not isinstance(node, list):
                return env[node]
            op, *args = node
            if op == 'setq':
                for name, expression in zip(args[::2], args[1::2]):
                    env[name] = evaluate(expression)
                return env[name]
            if op == 'or':
                return any(evaluate(arg) for arg in args)
            if op == 'while':
                iterations = 0
                while evaluate(args[0]):
                    iterations += 1
                    assert iterations <= len(terminals) + len(principles)
                    for expression in args[1:]:
                        evaluate(expression)
                return None
            values = [evaluate(arg) for arg in args]
            functions = {
                'car': lambda x: x[0] if x else None,
                'cdr': lambda x: x[1:] if x else None,
                'list': lambda *x: list(x),
                'cons': lambda a, b: [a] + (b or []),
                'reverse': lambda x: list(reversed(x or [])),
            }
            return functions[op](*values)

        for expression in form[3:]:
            actual = evaluate(expression)
        assert actual == expected, (terminals, principles, actual)
    print('PASS: DX/FDX ordinal pairing; staggered rows, unequal and empty columns')


def check_preview(form):
    """Evaluate only the preview's small expression subset with AutoLISP last semantics."""
    for rect in [[-1119.71, -80.0, -1019.71, 20.0, 0.0],
                 [10.0, 20.0, 40.0, 70.0, 5.0]]:
        env = {'rect': rect}
        lines = []

        def evaluate(node):
            if not isinstance(node, list):
                if node in env:
                    return env[node]
                return float(node)
            op, *args = node
            if op == 'setq':
                for name, expression in zip(args[::2], args[1::2]):
                    env[name] = evaluate(expression)
                return env[name]
            if op == 'foreach':
                for value in evaluate(args[1]):
                    env[args[0]] = value
                    for expression in args[2:]:
                        evaluate(expression)
                return None
            values = [evaluate(arg) for arg in args]
            if op == 'grdraw':
                assert all(isinstance(p, list) and len(p) == 3 for p in values[:2]), values
                lines.append(values[:2])
                return None
            functions = {
                'car': lambda x: x[0], 'cadr': lambda x: x[1],
                'nth': lambda i, x: x[int(i)], 'last': lambda x: x[-1],
                'list': lambda *x: list(x),
            }
            return functions[op](*values)

        for expression in form[3:]:
            evaluate(expression)
        x1, y1, x2, y2, z = rect
        corners = [[x1, y1, z], [x2, y1, z], [x2, y2, z], [x1, y2, z]]
        assert lines == [[corners[i - 1], corners[i]] for i in range(4)], lines
    print('PASS: preview regression, negative coordinates and nonzero elevation')


def check_horizontal_batch(form):
    """Execute delivered placement AST with simulated DXF/COM failure paths; no CAD."""
    from copy import deepcopy
    from check_cable_perf_static import Runner
    class BatchRunner(Runner):
        def eval(self, expr, env):
            if isinstance(expr, (int, float)):
                return expr
            return super().eval(expr, env)
    for scenario in ('success', 'locked', 'normalize-fail', 'bbox-fail', 'overflow', 'arrange-error'):
        original = {
            'a': [(-1, 'a'), (0, 'TEXT'), (8, 'L'), (50, 1.570796)],
            'b': [(-1, 'b'), (0, 'MTEXT'), (8, 'L'), (50, 1.570796), (11, [0., 1., 0.])],
            'c': [(-1, 'c'), (0, 'TEXT'), (8, 'L'), (50, 0.)],
        }
        state = deepcopy(original)
        events = []
        runner = BatchRunner({'fdx:place': form})
        assoc = lambda key, ed: next((pair for pair in ed if pair[0] == key), None)
        def entmod(ed):
            en = assoc(-1, ed)[1]
            events.append(('write', en))
            if scenario == 'normalize-fail' and en == 'b':
                return None
            state[en] = deepcopy(ed)
            return ed
        def bbox(en):
            angle = assoc(50, state[en])[1]
            events.append(('bbox', en, angle))
            if scenario == 'bbox-fail' and angle == 0. and en == 'b':
                return None
            return [[0., 0., 0.], [10., 2. if angle == 0. else 100., 0.]]
        def shift(ed, delta):
            assert assoc(50, ed)[1] == 0., 'Movement must use normalized data'
            events.append(('move', assoc(-1, ed)[1]))
            return ed
        def arrange(doc, ss, rect):
            assert all(assoc(50, ed)[1] == 0. for ed in state.values())
            # MTEXT angle must follow its old direction vector in the entmod input.
            assert state['b'][-1] == (50, 0.)
            events.append(('arrange',))
            if scenario == 'arrange-error':
                raise RuntimeError('simulated arrange failure')
            return [3, 0, 0, 1 if scenario == 'overflow' else 0]
        def restore(records):
            for ed in records:
                state[assoc(-1, ed)[1]] = deepcopy(ed)
            events.append(('restore',))
            return True
        runner.mocks.update({
            'sslength': len, 'ssname': lambda ss, i: ss[i],
            'entget': lambda en: deepcopy(state[en]), 'entmod': entmod,
            'tblsearch': lambda *args: [(70, 4 if scenario == 'locked' else 0)],
            'logand': lambda a, b: a & b, 'vlax-ename->vla-object': lambda en: en,
            'aa:try-get-bbox': bbox, 'vlax-release-object': lambda obj: True,
            'vl-remove': lambda value, items: [x for x in items if x != value],
            'entupd': lambda en: events.append(('update', en)),
            'trans': lambda p, *args: p, 'fdx:shift-data': shift,
            'fdx:arrange': arrange, 'fdx:restore': restore,
            'princ': lambda *args: None, 'redraw': lambda: None,
            'vl-catch-all-error-message': str,
        })
        result = runner.call('fdx:place', [['a', 'b', 'c'], [0., 0., 100., 100., 0.]],
                             {'pending': None, 'aa:doc': 'doc'})
        assert bool(result) == (scenario == 'success'), (scenario, result)
        if scenario != 'success':
            assert state == original, (scenario, 'Original position/direction must be restored')
        else:
            first_move = next(i for i, event in enumerate(events) if event[0] == 'move')
            assert sum(event[0] == 'update' for event in events[:first_move]) == 3
            assert sum(event[0] == 'bbox' and event[2] == 0.
                       for event in events[:first_move]) >= 3
    print('PASS: FDX horizontal TEXT/MTEXT before movement; lock, write/bbox failure, overflow/error rollback')


if __name__ == '__main__':
    check()
