"""Check the actual CC forms without connecting to CAD."""
import sys
from pathlib import Path

from check_fdx_static import ARITY, parse, walk


def _quoted_strings(node, acc):
    if not isinstance(node, list):
        if isinstance(node, str):
            acc.append(node)
        return
    if node and node[0] == 'quote' and len(node) >= 2:
        if isinstance(node[1], str):
            acc.append(node[1])
        elif isinstance(node[1], list):
            acc.extend(x for x in node[1] if isinstance(x, str))
    for item in node:
        _quoted_strings(item, acc)


def check(path):
    data = path.read_bytes()
    assert not data.startswith(b'\xef\xbb\xbf'), 'UTF-8 BOM'
    source = data.decode('utf-8', errors='strict')
    assert '\ufffd' not in source, 'Replacement character'
    assert b'\n' not in data.replace(b'\r\n', b''), 'Bare LF'
    forms = parse(source)
    targets = [f for f in forms if isinstance(f, list)
               and f[:2] == ['defun', 'c:cc']]
    assert len(targets) == 1, 'CC must be one top-level definition'
    cc = targets[0]
    assert cc[-1] == ['aa:cmd-end'], 'Missing command cleanup'
    limits = dict(ARITY, **{'getpoint': (1, 2), 'vla-copy': (1, 1),
                          'vla-move': (3, 3), 'vla-put-textstring': (2, 2)})
    calls = list(walk(cc[3:]))
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
    assert ['setq', 'ss', ['ssget', '"_I"']] == cc[3], 'Capture preselection first'
    assert ['aa:cmd-begin', '"CC"'] in calls
    assert ['qe:get-clip-text'] in calls
    assert not any(n[0] in ('zi:to-clip', 'c:qe', 'command', 'command-s')
                   for n in calls if isinstance(n[0], str))
    # ghost created after base point, text replaced, then dragged
    assert ['vla-copy', ['vlax-ename->vla-object', 'src']] in calls, 'Copy source after base'
    assert ['vla-put-textstring', 'copy-obj', 'clip-text'] in calls
    assert ['cc:drag-object', 'copy-obj', 'base'] in calls, 'Drag live copy'
    # cancel path deletes ghost (via vl-catch-all-apply 'vla-Delete)
    quoted_cc = []
    _quoted_strings(cc, quoted_cc)
    assert 'vla-delete' in quoted_cc, 'Cancel must delete copy'
    error = next(n for n in calls if n[:2] == ['defun', '*error*'])
    assert ['aa:cmd-error', 'msg'] in list(walk(error))
    quoted_err = []
    _quoted_strings(error, quoted_err)
    assert 'vla-delete' in quoted_err, 'error handler must delete leftover copy'

    helpers = {}
    for form in forms:
        if (isinstance(form, list) and len(form) > 1
                and form[0] == 'defun' and isinstance(form[1], str)
                and form[1].startswith('cc:')):
            helpers[form[1]] = form
    for name in ('cc:move-ucs', 'cc:drag-object'):
        assert name in helpers, 'Missing ' + name

    move_calls = list(walk(helpers['cc:move-ucs'][3:]))
    assert ['trans', 'from', '1', '0'] in move_calls, 'UCS->WCS from'
    assert ['trans', 'to', '1', '0'] in move_calls, 'UCS->WCS to'
    assert any(n[0] == 'vla-move' for n in move_calls
               if isinstance(n, list) and n and isinstance(n[0], str))

    drag_calls = list(walk(helpers['cc:drag-object'][3:]))
    drag_heads = [n[0] for n in drag_calls if isinstance(n, list) and n
                  and isinstance(n[0], str)]
    assert 'cc:move-ucs' in drag_heads, 'drag must move live object'
    quoted = []
    _quoted_strings(helpers['cc:drag-object'], quoted)
    assert 'grread' in quoted, 'drag must use grread'
    assert 'vla-copy' not in drag_heads, 'drag helper must not create entity'
    assert 'vla-put-textstring' not in drag_heads, 'drag helper must not write text'
    print(f'PASS: {len(forms)} top-level forms; CC structure and call arities')
    print('PASS: preselection, clipboard replace, cancel/error cleanup')
    print('PASS: real ghost copy after base + grread drag (CO-like text preview)')
    print('PASS: UTF-8 without BOM, CRLF')


if __name__ == '__main__':
    check(Path(sys.argv[1]) if len(sys.argv) > 1 else
          Path(__file__).resolve().parents[1] / 'AA整合版本.lsp')
