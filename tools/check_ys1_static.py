"""Evaluate YS1 geometry offline; never connects to CAD."""
import math
from pathlib import Path
from lsp_common import parse, read_source, defun_forms, walk, ARITY


def run(height=80.0, base=(0.0, 0.0, 0.0)):
    _, source = read_source()
    funcs = {f[1]: f for f in defun_forms(parse(source))}
    selected = {k: v for k, v in funcs.items() if k.startswith('aa:ys1-') or k == 'c:ys1'}
    assert 'c:ys1' in selected
    for name, form in selected.items():
        assert 'defun' not in [n[0] for n in walk(form[3:]) if n]
        for node in walk(form):
            if isinstance(node[0], str) and node[0] in ARITY:
                low, high = ARITY[node[0]]
                assert low <= len(node) - 1 <= high, (name, node)
    env = {'nil': None, 't': True, 'pi': math.pi}
    paths, arcs, leaders = [], [], []
    picks = []

    def ev(node):
        if not isinstance(node, list):
            try:
                return float(node)
            except ValueError:
                return node[1:-1] if node.startswith('"') else env.get(node)
        if not node:
            return None
        op, *args = node
        if op == 'quote':
            def literal(x):
                return [literal(v) for v in x] if isinstance(x, list) else float(x)
            return literal(args[0])
        if op == 'setq':
            for key, value in zip(args[::2], args[1::2]):
                env[key] = height if key == 'h' else ev(value)
            return env[key]
        if op == 'foreach':
            for value in ev(args[1]):
                env[args[0]] = value
                for body in args[2:]:
                    ev(body)
            return None
        if op == 'if':
            if ev(args[0]):
                return ev(args[1])
            return ev(args[2]) if len(args) == 3 else None
        if op == 'progn':
            for body in args:
                result = ev(body)
            return result
        vals = [ev(x) for x in args]
        if op == 'aa:ys-line':
            leaders.append(vals)
            return None
        if op == 'aa:ys1-path':
            points = [(env['origin'] + x + env['base'][0], y + env['base'][1]) for x, y in vals[0]]
            if vals[1]:
                points.append(points[0])
            paths.append(points)
            return None
        if op == 'aa:ys1-arc':
            x, y, r, a, b = vals
            arcs.append((env['origin'] + x + env['base'][0], y + env['base'][1], r, a, b))
            return None
        if op in ('aa:cmd-begin', 'aa:cmd-end', 'redraw', 'princ'):
            return None
        if op == 'getpoint':
            picks.append(vals)
            return [base[0] - 30, base[1] - 20, base[2]] if len(picks) == 1 else list(base)
        builtins = {
            '+': lambda *v: sum(v), '-': lambda a, *v: a - sum(v),
            '*': lambda *v: math.prod(v), '/': lambda a, b: a / b,
            'abs': abs, '<': lambda a, b: a < b, '=': lambda a, b: a == b,
            'list': lambda *v: list(v), 'cons': lambda a, b: [a] + (b or []),
            'reverse': lambda a: list(reversed(a)), 'car': lambda a: a[0],
            'cadr': lambda a: a[1], 'caddr': lambda a: a[2],
            'not': lambda a: not a,
            'equal': lambda a, b, tolerance: math.dist(a, b) <= tolerance,
        }
        if op in builtins:
            return builtins[op](*vals)
        assert op in selected, ('Unsupported call', op)
        form = selected[op]
        names = form[2]
        split = names.index('/') if '/' in names else len(names)
        params, locals_ = names[:split], names[split + 1:]
        assert len(params) == len(vals), op
        previous = env.copy()
        env.update(dict.fromkeys(locals_))
        env.update(zip(params, vals))
        for body in form[3:]:
            result = ev(body)
        for key in params + locals_:
            if key in previous:
                env[key] = previous[key]
            else:
                env.pop(key, None)
        return result

    ev(['c:ys1'])
    assert len(picks) == 2 and len(picks[1]) == 2
    assert leaders == [[[base[0]-30, base[1]-20, base[2]], list(base), 3]]
    assert picks[1][0] == leaders[0][0]
    samples = [p for path in paths for p in path]
    for x, y, r, a, b in arcs:
        assert r > 0
        samples.extend((x + r * math.cos(a + (b-a)*i/60),
                        y + r * math.sin(a + (b-a)*i/60)) for i in range(61))
    bounds = (min(x for x, y in samples), min(y for x, y in samples),
              max(x for x, y in samples), max(y for x, y in samples))
    assert abs((bounds[0] + bounds[2]) / 2 - base[0]) < 1e-8
    assert abs((bounds[1] + bounds[3]) / 2 - base[1]) < 1e-8
    assert abs(bounds[3] - bounds[1] - height) < 1e-8
    assert all(math.dist(a, b) > 1e-8 for path in paths for a, b in zip(path, path[1:]))
    print(f'PASS YS1: H={height}, bounds={bounds}, {len(paths)} paths, {len(arcs)} arcs')
    return paths, arcs, bounds


if __name__ == '__main__':
    paths, arcs, bounds = run()
    scaled, scaled_arcs, _ = run(160, (17, -23, 5))
    assert len(paths) == len(scaled) and len(arcs) == len(scaled_arcs)
    for original, enlarged in zip(paths, scaled):
        for (x, y), (sx, sy) in zip(original, enlarged):
            assert abs(sx - (2*x + 17)) < 1e-8 and abs(sy - (2*y - 23)) < 1e-8
    import matplotlib
    matplotlib.use('Agg')
    import matplotlib.pyplot as plt
    from matplotlib.patches import Arc
    fig, ax = plt.subplots(figsize=(18, 4.3))
    for path in paths:
        ax.plot(*zip(*path), color='#16382a', linewidth=.85)
    for x, y, r, a, b in arcs:
        ax.add_patch(Arc((x, y), 2*r, 2*r, theta1=math.degrees(a),
                         theta2=math.degrees(b), color='#16382a', linewidth=.85))
    ax.set_aspect('equal')
    ax.set_xlim(bounds[0]-5, bounds[2]+5)
    ax.set_ylim(bounds[1]-8, bounds[3]+8)
    ax.axis('off')
    output = Path(__file__).resolve().parents[1] / 'docs' / 'YS1-preview.png'
    fig.savefig(output, dpi=180, bbox_inches='tight', facecolor='white')
    print(output)
