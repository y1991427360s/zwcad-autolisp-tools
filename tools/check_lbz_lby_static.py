"""Offline numbering and shared-command regression; never connects to CAD."""
from check_zdwi_static import evaluate
from lsp_common import ARITY, defun_forms, parse, read_source, walk


def check():
    _, text = read_source()
    funcs = {f[1]: f for f in defun_forms(parse(text))}
    helper = funcs['aa:yd-cmd']
    assert helper[2][:5] == ['tag-name', 'is-left', 'first-label', 'number-prefix', 'cabinet-text']
    nodes = list(walk(helper[3:]))
    assert ['aa:km-create-centered-text', 'doc', 'cabinet-text',
            ['list', 'joint-x', 'center-y', 'base-z']] in nodes
    assert ['strlen', 'cabinet-text'] in nodes
    heads = [n[0] for n in nodes if isinstance(n[0], str)]
    assert heads.count('aa:undo-mark-on') == 1
    assert heads.count('aa:undo-mark-off') == 2  # Error and normal cleanup.
    assert {'aa:doc', 'aa:undo-open', 'en', 'ed', 'p1', 'p2', 'item', 'idx'} <= set(helper[2])
    numbering = next(n for n in nodes if n[:2] == ['if', ['=', 'idx', '0']])
    validation = next(n for n in nodes if n[0] == 'if' and isinstance(n[1], list)
                      and n[1][:3] == ['and', 'p1', 'p2'])
    # Actual QW3 LINE coordinates; TEXTs are excluded by the command filter.
    lines = [
        ([36907.0696, 3460.2887, 0], [36967.0696, 3460.2887, 0]),
        ([36948.0696, 3451.2855, 0], [36966.0696, 3451.2855, 0]),
        ([36948.0696, 3441.2855, 0], [36966.0696, 3441.2855, 0]),
        ([36947.0696, 3431.2749, 0], [36966.0696, 3431.2855, 0]),
        ([36947.0696, 3421.2855, 0], [36966.0696, 3421.2855, 0]),
    ]
    for left in (True, None):
        for reverse in (False, True):
            env = {'is-left': left, 'base-z': None, 'valid': True, 'lines-by-y': None}
            for index, pair in enumerate(lines):
                p1, p2 = pair[::-1] if reverse else pair
                env.update(p1=p1, p2=p2, en=index)
                evaluate(validation, env)
            assert env['valid'] and len(env['lines-by-y']) == 5
            record = next(row for row in env['lines-by-y'] if row[1] == 3)
            assert record[0] == (3431.2749 if left else 3431.2855)
    for delta, z, expected in ((0.049, 0, True), (0.051, 0, False),
                               (1, 0, False), (0, 1, False)):
        env = {'p1': [0, 0, 0], 'p2': [19, delta, z], 'en': 0,
               'is-left': None, 'base-z': 0, 'valid': True, 'lines-by-y': None}
        evaluate(validation, env)
        assert bool(env['valid']) == expected, (delta, z)
    for name, left, first, prefix in (
        ('YDZ', 't', '701', '-9'), ('YDY', 'nil', '701', '-9'),
        ('LBZ', 't', '500', '-5'), ('LBY', 'nil', '500', '-5'),
    ):
        entry = funcs['c:' + name.lower()]
        cabinet = '故障录波柜' if name.startswith('LB') else '公用测控柜'
        assert entry[3:] == [['aa:yd-cmd', '"' + name + '"', left,
                             '"' + first + '"', '"' + prefix + '"', '"' + cabinet + '"']]
        labels = []
        for idx in range(60):
            env = {'idx': idx, 'first-label': first, 'number-prefix': prefix}
            labels.append(evaluate(numbering, env))
        expected = [first] + [prefix + str(2 * i - 1).zfill(2) for i in range(1, 60)]
        assert labels == expected, (name, labels)
    for node in nodes:
        if isinstance(node[0], str) and node[0] in ARITY:
            low, high = ARITY[node[0]]
            assert low <= len(node) - 1 <= high, node
    print('PASS LBZ/LBY: QW3 near-horizontal lines, reversed endpoints, both directions, tolerance/elevation guards, 60 labels per command, undo cleanup')


if __name__ == '__main__':
    check()
