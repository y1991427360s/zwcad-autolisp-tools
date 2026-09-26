"""Check C1, C2, C3 native drag preview, continuous copying, and number alteration."""
import re
import sys
from pathlib import Path
from lsp_common import ARITY, SOURCE, parse, walk


def check_c1c2_functions(forms):
    defun_map = {f[1]: f for f in forms if isinstance(f, list) and f[:1] == ['defun']}
    for cmd, delta in [('c:c1', '1'), ('c:c2', '-1'), ('c:c3', '2')]:
        assert cmd in defun_map, f'Missing {cmd}'
        body = defun_map[cmd]
        calls = list(walk(body[3:]))
        assert ['c1c2:run', delta] in calls, f'{cmd} must call c1c2:run with {delta}'

    assert 'c1c2:place-one' in defun_map, 'Missing c1c2:place-one'
    p_calls = list(walk(defun_map['c1c2:place-one'][3:]))
    copy = ['vla-copy', 'src']
    replace = ['vla-put-textstring', 'copy-obj', 'txt']
    update = ['vla-update', 'copy-obj']
    move = ['command', '"_.MOVE"', ['vlax-vla-object->ename', 'copy-obj'], '""', '"_non"', 'base']
    hide = ['redraw', ['vlax-vla-object->ename', 'copy-obj'], '2']
    pause = ['command', 'pause']
    show = ['redraw', ['vlax-vla-object->ename', 'copy-obj'], '1']
    assert copy in p_calls, 'c1c2:place-one must call vla-copy'
    assert replace in p_calls, 'c1c2:place-one must call vla-put-textstring'
    assert update in p_calls, 'c1c2:place-one must call vla-update'
    assert move in p_calls, 'c1c2:place-one must call native MOVE'
    assert hide in p_calls, 'c1c2:place-one must hide static copy during drag'
    assert pause in p_calls, 'c1c2:place-one must pause for user input'
    assert show in p_calls, 'c1c2:place-one must show placed copy after drag'
    assert p_calls.index(copy) < p_calls.index(replace) < p_calls.index(update) < p_calls.index(move)
    sample_last = ['setq', 'last-pt', ['getvar', '"LASTPOINT"']]
    assert sample_last in p_calls
    assert p_calls.index(move) < p_calls.index(sample_last) < p_calls.index(hide) < p_calls.index(pause) < p_calls.index(show)
    assert ['vl-catch-all-apply', ['quote', 'vla-delete'], ['list', 'copy-obj']] in p_calls
    assert ['vlax-release-object', 'copy-obj'] in p_calls

    assert 'c1c2:run' in defun_map, 'Missing c1c2:run'
    r_calls = list(walk(defun_map['c1c2:run'][3:]))
    assert ['vla-startundomark', 'doc'] in r_calls
    assert ['c1c2:safe-end-undo', 'doc'] in r_calls
    assert ['setvar', '"DRAGMODE"', '2'] in r_calls
    assert any(n[0] == 'while' and isinstance(n[1], list) and 'c1c2:place-one' in [x[0] for x in walk(n[1]) if isinstance(x, list)] for n in r_calls), 'c1c2:run must loop c1c2:place-one'

    error_defun = next(n for n in r_calls if n[:2] == ['defun', '*error*'])
    e_calls = list(walk(error_defun))
    assert ['c1c2:delete-preview'] in e_calls
    assert ['c1c2:safe-end-undo', 'doc'] in e_calls


def py_first_number_span(s):
    last_hyphen = s.rfind('-')
    first = None
    after = None
    for m in re.finditer(r'\d+', s):
        span = (m.start(), m.end() - m.start())
        if first is None:
            first = span
        if last_hyphen != -1 and m.start() > last_hyphen and after is None:
            after = span
    return after if after is not None else first


def py_change_number(s, delta):
    span = py_first_number_span(s)
    if not span:
        return None
    start, length = span
    old_num = int(s[start:start + length])
    new_num = old_num + delta
    if new_num >= 0:
        new_str = str(new_num).zfill(length)
    else:
        new_str = str(new_num)
    return s[:start] + new_str + s[start + length:]


def check_logic():
    assert py_change_number('A-01', 1) == 'A-02'
    assert py_change_number('A-01', -1) == 'A-00'
    assert py_change_number('A-01', 2) == 'A-03'
    assert py_change_number('W10-20', 1) == 'W10-21'
    assert py_change_number('TAG-99', 1) == 'TAG-100'
    assert py_change_number('NO_NUMBER', 1) is None


def check(path=None):
    source_path = path or SOURCE
    data = source_path.read_bytes()
    assert not data.startswith(b'\xef\xbb\xbf'), 'UTF-8 BOM'
    source = data.decode('utf-8', errors='strict')
    assert '\ufffd' not in source
    assert b'\n' not in data.replace(b'\r\n', b''), 'Bare LF'
    forms = parse(source)
    check_c1c2_functions(forms)
    check_logic()
    print('PASS: C1/C2/C3 structure, native MOVE preview, undo, and number logic')


if __name__ == '__main__':
    check(Path(sys.argv[1]) if len(sys.argv) > 1 else SOURCE)
