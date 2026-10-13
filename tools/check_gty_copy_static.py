"""Execute GTY copy/output AST with mocked CAD calls; never connect to CAD."""
from copy import deepcopy

from check_cable_perf_static import Runner
from lsp_common import defun_forms, parse, read_source, walk


def check():
    _, text = read_source()
    funcs = {f[1]: f for f in defun_forms(parse(text))}
    runner = Runner(funcs)
    sources = {f's{i}': {'point': [i * 10., i * -5., i * 2.],
                        'text': f'电缆{i}', 'height': 3., 'style': 'HZ',
                        'color': i + 1, 'layer': '电缆文字', 'alignment': i,
                        'extension': {'annotation': '保留'}} for i in range(4)}
    original = deepcopy(sources)
    entities = deepcopy(sources)
    log = []
    serial = 0
    fail_copy_at = None
    fail_move = False

    def clone(source):
        nonlocal serial
        assert source in sources, 'Copy must operate on a source entity'
        if serial == fail_copy_at:
            raise RuntimeError('copy failed')
        name = f'copy{serial}'
        serial += 1
        entities[name] = deepcopy(entities[source])
        log.append(('copy', source, name))
        return name

    def move(name, before, after):
        assert name.startswith('copy'), 'Moving an original is forbidden'
        if fail_move:
            return None
        entities[name]['point'] = after
        log.append(('move', name, before, after))
        return True

    def delete(name):
        assert name.startswith('copy'), 'Deleting an original is forbidden'
        entities.pop(name, None)
        log.append(('delete', name))

    def trans(point, source, target):
        assert target == 0
        if source == 1:  # non-default UCS placement point
            return [point[0] + 100., point[1] + 200., point[2] + 7.]
        assert source in sources
        return list(point)

    runner.mocks.update({
        'vlax-ename->vla-object': lambda name: name,
        'vlax-vla-object->ename': lambda name: name,
        'vlax-release-object': lambda name: log.append(('release', name)),
        'vla-copy': clone, 'vla-delete': delete,
        'aa:gty-move-text-fast': move, 'trans': trans,
        'vla-startundomark': lambda doc: log.append(('undo-start', doc)),
        'vla-endundomark': lambda doc: log.append(('undo-end', doc)),
        'redraw': lambda: log.append(('redraw',)),
        'sssetfirst': lambda *args: None, 'princ': lambda *args: None,
    })
    result = runner.call('aa:gty-copy-text', ['s0', sources['s0']['point'], [30., 40., 50.]])
    assert result == 'copy0' and entities['copy0']['point'] == [30., 40., 50.]
    assert entities['copy0'] | {'point': original['s0']['point']} == original['s0']
    assert entities['s0'] == original['s0']
    runner.call('aa:gty-delete-copies', [[result]])
    assert entities == original

    fail_move = True
    assert runner.call('aa:gty-copy-text', ['s1', sources['s1']['point'], [0., 0., 0.]]) is None
    assert entities == original
    assert ('release', 'copy1') in log and ('delete', 'copy1') in log
    fail_move = False

    command = funcs['c:gty']
    nodes = list(walk(command))
    assert not any(n[:1] == ['aa:gty-move-text-fast'] for n in nodes)
    output = next(n for n in nodes if n[:1] == ['if'] and isinstance(n[1], list)
                  and n[1][:2] == ['setq', 'target-pt'])
    error = next(n for n in nodes if n[:2] == ['defun', '*error*'])
    rows = [[[f's{i}', sources[f's{i}']['text'], sources[f's{i}']['point'], 10.]
             for i in indices] for indices in ((0, 1), (2, 3))]

    def env():
        return {'doc': 'doc', 'sorted-rows': rows, 'col-widths': [10., 20.],
                'col-gap': 10., 'line-height': 5., 'undo-started': None, 'copies': None}

    runner.mocks['getpoint'] = lambda _: None
    log.clear()
    runner.eval(output, env())
    assert not log and entities == original, 'Cancel must not mutate or start undo'

    runner.mocks['getpoint'] = lambda _: [1., 2., 3.]
    log.clear()
    runner.eval(output, env())
    copies = [name for name in entities if name.startswith('copy')]
    assert len(copies) == 4
    targets = [entry[3] for entry in log if entry[0] == 'move']
    assert targets == [[101., 202., 10.], [121., 202., 10.],
                       [101., 197., 10.], [121., 197., 10.]]
    assert [entry[0] for entry in log].count('undo-start') == 1
    assert [entry[0] for entry in log].count('undo-end') == 1
    assert {name: entities[name] for name in sources} == original
    runner.call('aa:gty-delete-copies', [copies])

    # A failed Copy after one success rolls back this batch through the real handler.
    fail_copy_at = serial + 1
    state = env()
    log.clear()
    runner.mocks['quit'] = lambda: (_ for _ in ()).throw(RuntimeError('cancel batch'))
    try:
        runner.eval(output, state)
    except RuntimeError:
        runner.seq(error[3:], state | {'msg': 'copy failed'})
    else:
        raise AssertionError('Expected failed batch')
    assert entities == original
    assert [entry[0] for entry in log].count('undo-start') == 1
    assert [entry[0] for entry in log].count('undo-end') == 1
    print('PASS GTY copy: original properties/coordinates unchanged; copy-only movement; '
          'UCS placement, target elevation, fixed rows/columns, cancel and failure cleanup; no CAD')


if __name__ == '__main__':
    check()
