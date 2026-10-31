"""Execute GTY2 AST with mocked CAD calls; never connect to CAD."""
from copy import deepcopy

from check_cable_perf_static import Runner
from lsp_common import defun_forms, parse, read_source, walk


def gty_layout_forms(funcs):
    outer = next(n for n in walk(funcs['c:gty']) if n[:2] == ['if', 'ss'])
    forms = outer[2][1:]
    last = next(i for i, form in enumerate(forms)
                if form[:2] == ['setq', 'sorted-rows'])
    return forms[:last + 1]


def check():
    _, text = read_source()
    funcs = {f[1]: f for f in defun_forms(parse(text))}
    for name in ('c:gty2', 'gty2:layout', 'gty2:locked-layer', 'gty2:make-copies', 'gty2:to-clip'):
        assert name in funcs, name + ' must remain top-level'

    # GTY cannot be refactored, so its sorting stays in two places and must not drift.
    layout = funcs['gty2:layout']
    shared = gty_layout_forms(funcs)
    assert layout[3:] == shared + [['list', 'sorted-rows', 'col-widths', 'col-gap', 'line-height']]
    assert 'vl-sort' not in str(funcs['c:gty2'])
    print('PASS GTY2 layout: every sorting form identical to c:GTY')

    runner = Runner(funcs)
    sources = {f's{i}': {'point': [i * 10., i * -5., 2.], 'layer': '电缆文字',
                        'xdata': ('AA_LINK', 'doc', f'h{i}')} for i in range(4)}
    original = deepcopy(sources)
    entities = deepcopy(sources)
    log = []
    serial = 0
    fail_move_at = None
    clip_result = True
    command_active = 0

    def clone(source):
        nonlocal serial
        name = f'copy{serial}'
        serial += 1
        entities[name] = deepcopy(entities[source])
        return name

    def move(name, _before, after):
        assert name.startswith('copy'), 'Moving an original is forbidden'
        if name == fail_move_at:
            return None
        entities[name]['point'] = after
        log.append(('move', name, after))
        return True

    def delete(name):
        assert name.startswith('copy'), 'Deleting an original is forbidden'
        entities.pop(name, None)
        log.append(('delete', name))

    def trans(point, source, target):
        if source == 0 and target == 1:  # non-default UCS for the native base point
            return [point[0] - 100., point[1] - 200., point[2]]
        return list(point)

    def cmdf(*args):
        assert not selection, 'Pickfirst must be cleared before COPYBASE'
        log.append(('clip', args[0], args[1], args[2], sorted(args[3]), args[4]))
        assert all(name in entities for name in args[3]), 'Copies must exist while copying'
        return clip_result

    selection = {'s0'}
    runner.mocks.update({
        'vlax-ename->vla-object': lambda name: name,
        'vlax-vla-object->ename': lambda name: name,
        'vlax-release-object': lambda name: None,
        'vla-copy': clone, 'vla-delete': delete,
        'aa:gty-move-text-fast': move, 'trans': trans,
        'ssadd': lambda *args: (args[1].append(args[0]) or args[1]) if args else [],
        'vl-cmdf': cmdf, 'setvar': lambda *args: log.append(('setvar',) + args),
        'getvar': lambda name: command_active,
        'command': lambda: log.append(('cancel',)),
        'vl-catch-all-error-p': lambda value: isinstance(value, Exception),
    })

    rows = [[[f's{i}', 'x', sources[f's{i}']['point'], 10.] for i in indices]
            for indices in ((0, 1), (2, 3))]

    # Same grid as GTY, starting exactly at the base point.
    copies = runner.call('gty2:make-copies', [rows, [10., 20.], 10., 5., [1., 2., 3.]],
                         {'copies': None})
    targets = [entry[2] for entry in log if entry[0] == 'move']
    assert targets == [[1., 2., 3.], [21., 2., 3.], [1., -3., 3.], [21., -3., 3.]]
    assert len(copies) == 4 and {k: entities[k] for k in sources} == original
    runner.call('aa:gty-delete-copies', [copies])
    assert entities == original

    # One failed copy leaves nothing behind.
    log.clear()
    fail_move_at = f'copy{serial + 2}'
    assert runner.call('gty2:make-copies', [rows, [10., 20.], 10., 5., [1., 2., 3.]],
                       {'copies': None}) is None
    fail_move_at = None
    assert entities == original
    print('PASS GTY2 copies: same grid as GTY, originals untouched, failure cleans the batch')

    # Clipboard step: base converted to UCS, snapping off, failure reported.
    selection.clear()
    log.clear()
    entities['copy90'] = {}
    assert runner.call('gty2:to-clip', [['copy90'], [1., 2., 3.]]) is True
    assert ('clip', '_.COPYBASE', '_non', [-99., -198., 3.], ['copy90'], '') in log
    clip_result = None
    assert not runner.call('gty2:to-clip', [['copy90'], [1., 2., 3.]])
    clip_result = True
    command_active = 1
    log.clear()
    assert not runner.call('gty2:to-clip', [['copy90'], [1., 2., 3.]])
    assert ('cancel',) in log, 'A stuck COPYBASE must be cancelled'
    command_active = 0
    entities.pop('copy90')

    # Locked layer check.
    layers = {'开': {70: 0}, '锁': {70: 4}, '冻锁': {70: 5}}
    data = {'a': {0: 'TEXT', 8: '开'}, 'b': {0: 'TEXT', 8: '冻锁'}}
    runner.mocks.update({
        'sslength': len, 'ssname': lambda ss, i: ss[i],
        'entget': lambda name: [[8, data[name][8]]],
        'tblsearch': lambda _kind, name: [[70, layers[name][70]]],
        'assoc': lambda key, pairs: next(pair for pair in pairs if pair[0] == key),
        'cdr': lambda pair: pair[1], 'logand': lambda a, b: a & b,
    })
    assert runner.call('gty2:locked-layer', [['a']]) is None
    assert runner.call('gty2:locked-layer', [['a', 'b']]) == '冻锁'
    print('PASS GTY2 clipboard and locked layers: UCS base, no snapping, failures reported')

    # Command structure: order matters and cannot be exercised without CAD.
    command = funcs['c:gty2']
    source = str(command)
    assert ['aa:cmd-begin', '"GTY2"'] in walk_list(command) and ['aa:cmd-end'] in walk_list(command)
    # *error* comes first and mentions delete/sssetfirst, so compare from the cond onward.
    body = source[source.index("'gty2:layout'"):]
    order = [body.index(token) for token in
             ("'gty2:layout'", "'sssetfirst', 'nil', 'nil'", "'gty2:make-copies'",
              "'gty2:to-clip'", "'aa:gty-delete-copies', 'copies'")]
    assert order == sorted(order)
    handler = next(n for n in walk(command) if n[:2] == ['defun', '*error*'])
    assert ['aa:gty-delete-copies', 'copies'] in handler and ['aa:cmd-error', 'msg'] in handler
    assert 'getpoint' not in source, 'Placement belongs to native paste in the target drawing'
    assert funcs['gty2:make-copies'][2].count('copies') == 0, \
        'copies must stay c:GTY2 local so *error* can clean up'
    print('PASS GTY2 structure: pickfirst cleared before COPYBASE, temporary copies always removed; no CAD')


def walk_list(node):
    return [n for n in walk(node) if isinstance(n, list)]


if __name__ == '__main__':
    check()
