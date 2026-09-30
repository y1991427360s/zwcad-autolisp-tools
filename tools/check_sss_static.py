"""Offline SSS input and target-height regression; never connects to CAD."""
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
    print('PASS SSS: input/default, preselection before prompt, undo, '
          'six target-height cases and no ZSSS command')


if __name__ == '__main__':
    check()
