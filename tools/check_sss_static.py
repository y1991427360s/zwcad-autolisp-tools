"""Offline SSS input and target-height regression; never connects to CAD."""
import json
from pathlib import Path

from check_zdwi_static import evaluate
from lsp_common import ARITY, defun_forms, parse, read_source, walk


def check():
    _, text = read_source()
    funcs = {f[1]: f for f in defun_forms(parse(text))}
    assert 'c:zsss' not in funcs
    form = funcs['c:sss']
    assert form[2][0] == '/'
    required = {'*error*', 'aa:tag', 'aa:doc', 'aa:undo-open', 'aa:old-cmdecho',
                'target-height'}
    assert required <= set(form[2][1:])
    calls = [n for n in walk(form[3:]) if isinstance(n[0], str)]
    for n in calls:
        if n[0] in ARITY:
            low, high = ARITY[n[0]]
            assert low <= len(n) - 1 <= high, n
    assert ['initget', '6'] in calls, 'Reject zero and negative heights'
    guard = next(n for n in calls if n[:2] == ['if', ['null', 'target-height']])
    prompt_nodes = list(walk(guard))
    assert any(n[:1] == ['getreal'] for n in prompt_nodes), 'Support decimal input'
    assert ['t', '10.0'] in prompt_nodes, 'Enter defaults to 10'
    heads = [n[0] for n in calls]
    assert heads.index('aa:sss-pickfirst-box') < heads.index('getreal')
    assert heads.index('getreal') < heads.index('aa:cmd-begin')
    assert heads.count('aa:cmd-begin') == heads.count('aa:cmd-end') == 1
    assert ['sssetfirst', 'nil', 'nil'] in calls
    delta = ['-', 'target-height', 'old-height']
    assert delta in calls
    commands = [n for n in calls if n[0] == 'command']
    assert len(commands) == 2 and all(n[1] == '"_.STRETCH"' for n in commands)
    assert all(['list', '0.0', 'delta', '0.0'] in list(walk(n)) for n in commands)
    for old, target, expected in ((5, 10, 5), (15, 10, -5), (10, 10, 0),
                                  (5, 12.5, 7.5), (15, 7.25, -7.75),
                                  (10, 0.25, -9.75)):
        value = evaluate(delta, {'old-height': old, 'target-height': target})
        assert value == expected and old + value == target
    # Execute actual geometry helpers with the user's four QW3 LINEs.
    affected = {name: f for name, f in funcs.items() if name.startswith('aa:sss-')}
    for helper in affected.values():
        for node in walk(helper[3:]):
            if isinstance(node[0], str) and node[0] in ARITY:
                low, high = ARITY[node[0]]
                assert low <= len(node) - 1 <= high, node

    def call(name, *args):
        env = {'__functions': affected}
        names = []
        for i, arg in enumerate(args):
            key = 'arg' + str(i)
            env[key] = arg
            names.append(key)
        return evaluate([name] + names, env)

    def line(p, q, layer='TEXT'):
        return {'type': 'LINE', 'layer': layer, 'pts': [p, q]}

    selected = [
        line([-516.8208, 7639.8087], [-566.8208, 7639.8095]),
        line([-566.8208, 7639.8078], [-516.8208, 7639.8087]),
        line([-516.8208, 7639.8087], [-516.8198, 7583.5587]),
        line([-566.8208, 7639.8078], [-566.8198, 7583.5578]),
    ]
    segments = call('aa:sss-horizontal-segments', selected)
    assert len(segments) == 2, segments
    seed = call('aa:sss-lowest-row-line', selected)
    assert seed and abs(seed[0] - 7639.80825) < 1e-8
    # Duplicate top edges alone must never invent a 0.00085-unit row.
    assert call('aa:sss-find-pair', segments, 7639.8087,
                -566.8208, -516.8208) is None
    # A real lower border is required; simulate a nearby border in the scan.
    bottom = line([-566.8198, 7583.5578], [-516.8198, 7583.5587])
    scan = call('aa:sss-horizontal-segments', selected + [bottom])
    for border in (7600.0, seed[0] - 0.02, 7639.8087):
        pair = call('aa:sss-find-pair', scan, border, -566.8208, -516.8208)
        assert pair and abs((pair[0][0] - pair[1][0]) - 56.25) < 0.002
    reversed_lines = [en | {'pts': list(reversed(en['pts']))} for en in selected]
    assert call('aa:sss-horizontal-segments', reversed_lines) == segments
    # Absolute and slope limits both matter; retain ordinary small rows.
    for p, q in (([0, 0], [50, 0.02]), ([0, 0], [0.01, 0.001]),
                 ([0, 0], [50, 10]), ([0, 0], [0, 50])):
        assert not call('aa:sss-horizontal-segments', [line(p, q)])
    exact = [line([0, 10], [50, 10]), line([0, 9.75], [50, 9.75])]
    pair = call('aa:sss-find-pair', call('aa:sss-horizontal-segments', exact),
                9.9, 0, 50)
    assert pair and pair[0][0] - pair[1][0] == 0.25
    # Actual 74-object QW3 table: SQ top, LWK bottom, segmented borders.
    table = json.loads((Path(__file__).resolve().parents[1] /
                        'tests/fixtures/sss_header_74.json').read_text(encoding='utf-8'))
    assert 'aa:sss-header-box' not in funcs, 'Never force a header fallback'
    # Execute actual SSNAMEX decoding, then the actual command with either a
    # crossing polygon or PICKFIRST's method-0 records (polygon unavailable).
    executed = 0
    for border in (2270.0, 2262.0, 2250.0, 2245.0, 2239.0, 2234.0):
        box = [38060.0, border, 38125.0, 2280.0]
        selected = [en for en in table
                    if max(p[1] for p in en.get('pts', en.get('bbox', [[0, 0]]))) > border]
        scan = call('aa:sss-horizontal-segments', table)
        pair = call('aa:sss-find-pair', scan, border, box[0], box[2])
        assert pair, border
        expected_height = pair[0][0] - pair[1][0]
        for keep_polygon in (True, False):
            data = [[3, 'entity', 0, -1], [-1,
                    [0, [box[0], box[1], 0]], [0, [box[2], box[1], 0]],
                    [0, [box[2], box[3], 0]], [0, [box[0], box[3], 0]]]] if keep_polygon else [[0, 'entity', 0]]
            for target in (10.0, 12.5):
                commands, messages, prompts = [], [], []
                env = {'__functions': affected | {'c:sss': form},
                       '__ssget': lambda mode, *args: selected if mode == '_I' else table,
                       '__builtins': {
                           'vl-load-com': lambda: None, 'cadddr': lambda xs: xs[3],
                           'equal': lambda a, b, tol: all(abs(float(x) - float(y)) <= tol for x, y in zip(a, b)) if isinstance(a, list) else abs(a - b) <= tol,
                           'numberp': lambda x: isinstance(x, (int, float)),
                           'listp': lambda x: isinstance(x, list),
                           'vl-catch-all-apply': lambda *args: data,
                           'vl-catch-all-error-p': lambda _: False,
                           'getvar': lambda name: [1.0, 0.0, 0.0] if name == 'UCSXDIR' else [0.0, 1.0, 0.0],
                           'initget': lambda _: None,
                           'getreal': lambda prompt: prompts.append(prompt) or target,
                           'aa:cmd-begin': lambda _: None, 'aa:cmd-end': lambda: None,
                           'command': lambda *args: commands.append(args),
                           'rtos': lambda value, *args: str(value),
                           'sssetfirst': lambda *args: None,
                           'princ': lambda *args: messages.extend(args)}}
                env['selected'] = selected
                recovered = evaluate(['aa:sss-pickfirst-box', 'selected'], env)
                assert recovered == (box if keep_polygon else None), recovered
                evaluate(['c:sss'], env)
                assert len(commands) == 1 and len(prompts) == 1, (commands, messages)
                cmd = commands[0]
                if keep_polygon:
                    assert cmd[:2] == ('_.STRETCH', '_C'), cmd
                    assert cmd[2] == [box[0], border, 0.0], cmd
                    assert cmd[3] == [box[2], box[3], 0.0], cmd
                else:
                    assert cmd[0] == '_.STRETCH' and cmd[1] == selected, cmd
                assert abs(cmd[-1][1] - (target - expected_height)) < 1e-6, cmd
                executed += 1
    # An enclosing window has no crossed row: never silently change the header.
    env['__ssget'] = lambda *args: table
    env['__builtins']['vl-catch-all-apply'] = lambda *args: [[0, 'entity', 0]]
    commands.clear()
    prompts.clear()
    evaluate(['c:sss'], env)
    assert not commands and not prompts, (commands, messages)
    env['__builtins']['vl-catch-all-apply'] = lambda *args: [
        [3, 'entity', 0, -1], [-1, [0, [38060, 2220, 0]],
         [0, [38125, 2220, 0]], [0, [38125, 2280, 0]], [0, [38060, 2280, 0]]]]
    evaluate(['c:sss'], env)
    assert not commands and not prompts
    print('PASS SSS: syntax, undo, decimal/default height, QW3 geometry; '
          f'{executed} actual command paths across six rows with/without polygon; '
          'actual SSNAMEX decoding; whole-table selection never forces header')


if __name__ == '__main__':
    check()
