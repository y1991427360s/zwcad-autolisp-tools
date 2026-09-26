"""Check CC native drag and cleanup without connecting to CAD."""
import sys
from pathlib import Path
from check_fdx_static import ARITY, parse, walk


def check(path):
    data = path.read_bytes()
    assert not data.startswith(b'\xef\xbb\xbf'), 'UTF-8 BOM'
    source = data.decode('utf-8', errors='strict')
    assert '\ufffd' not in source
    assert b'\n' not in data.replace(b'\r\n', b''), 'Bare LF'
    forms = parse(source)
    targets = [f for f in forms if isinstance(f, list)
               and f[:2] == ['defun', 'c:cc']]
    assert len(targets) == 1, 'CC must be one top-level definition'
    cc = targets[0]
    calls = list(walk(cc[3:]))
    assert cc[3] == ['setq', 'ss', ['ssget', '"_I"']]
    assert cc[-1] == ['aa:cmd-end']
    assert ['aa:cmd-begin', '"CC"'] in calls
    assert ['qe:get-clip-text'] in calls
    limits = dict(ARITY, **{'getpoint': (1, 2), 'vla-copy': (1, 1),
                          'vla-update': (1, 1), 'vla-put-textstring': (2, 2)})
    for node in calls:
        if not isinstance(node[0], str):
            continue
        head, count = node[0], len(node) - 1
        if head in limits:
            low, high = limits[head]
            assert low <= count <= high, (head, count)
        if head == 'setq':
            assert count % 2 == 0, 'Odd setq'
        if head == 'cond':
            assert all(isinstance(x, list) and x for x in node[1:]), 'Bad cond'
        assert head not in ('grread', 'grdraw', 'grvecs', 'osnap', 'vla-move',
                            'zi:to-clip', 'c:qe', 'command-s')
        assert not head.startswith('cc:'), 'Old drag helper must not be called'
        if head == 'setvar':
            assert node[1] not in ('"OSMODE"', '"ORTHOMODE"', '"SNAPMODE"')
    assert len([n for n in calls if n[0] == 'getpoint']) == 1
    copy = ['vla-copy', ['vlax-ename->vla-object', 'src']]
    replace = ['vla-put-textstring', 'copy-obj', 'clip-text']
    update = ['vla-update', 'copy-obj']
    move = ['command', '"_.MOVE"', ['vlax-vla-object->ename', 'copy-obj'],
            '""', '"_non"', 'base']
    assert calls.index(copy) < calls.index(replace) < calls.index(update) < calls.index(move)
    hide = ['redraw', ['vlax-vla-object->ename', 'copy-obj'], '2']
    show = ['redraw', ['vlax-vla-object->ename', 'copy-obj'], '1']
    pause = ['command', 'pause']
    sample_last = ['setq', 'last-pt', ['getvar', '"LASTPOINT"']]
    assert sample_last in calls
    assert calls.index(move) < calls.index(sample_last) < calls.index(hide) < calls.index(pause) < calls.index(show)
    assert not any(n[0] == 'vla-put-visible' for n in calls)
    assert ['while', ['>', ['logand', ['getvar', '"CMDACTIVE"'], '1'], '0'],
            ['command', 'pause']] in calls
    assert ['setvar', '"DRAGMODE"', '2'] in calls
    restore = ['setvar', '"DRAGMODE"', 'old-dragmode']
    release = ['setq', 'old-dragmode', 'nil', 'copy-obj', 'nil']
    assert calls.index(move) < calls.index(restore) < calls.index(release)
    assert calls.index(show) < calls.index(release)
    error = next(n for n in calls if n[:2] == ['defun', '*error*'])
    error_calls = list(walk(error))
    assert ['vl-catch-all-apply', ['quote', 'vla-delete'], ['list', 'copy-obj']] in error_calls
    assert ['vl-catch-all-apply', ['quote', 'setvar'],
            ['list', '"DRAGMODE"', 'old-dragmode']] in error_calls
    assert ['aa:cmd-error', 'msg'] in error_calls
    assert any(n[0] == 'while' and n[1] == 'continue' for n in calls), 'CC must loop continuously'
    assert ['vl-catch-all-apply', ['quote', 'vla-delete'], ['list', 'copy-obj']] in calls
    print(f'PASS: {len(forms)} top-level forms; CC structure and call arities')
    print('PASS: replacement before native MOVE; continuous loop; cleanup and settings')
    print('PASS: UTF-8 without BOM, CRLF')


if __name__ == '__main__':
    check(Path(sys.argv[1]) if len(sys.argv) > 1 else
          Path(__file__).resolve().parents[1] / 'AA整合版本.lsp')
