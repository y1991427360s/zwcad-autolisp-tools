"""Offline ZHU checks: parsed command structure and note text format."""
from lsp_common import SOURCE, parse, read_source, walk


def check():
    _, source = read_source(SOURCE)
    forms = parse(source)
    funcs = {f[1]: f for f in forms if isinstance(f, list) and f and f[0] == 'defun'}
    for name in ('c:zhu', 'zhu:trim', 'zhu:sort-nums', 'zhu:classify', 'zhu:build-note', 'zhu:pick-name'):
        assert name in funcs, name + ' must remain top-level'
    calls = list(walk(funcs['c:zhu']))
    assert ['aa:cmd-begin', '"ZHU"'] in calls and ['aa:cmd-end'] in calls
    assert ['initget', '"D C"'] in calls
    for pair in (['cons', '40', '3.0'], ['cons', '41', '0.7'], ['cons', '7', '"HZ"']):
        assert pair in calls, pair
    assert ['trans', 'pt', '1', '0'] in calls
    assert 'vl-sort' not in str(funcs['zhu:sort-nums'])
    body = source[source.index('(defun zhu:build-note'):source.index('(defun zhu:pick-name')]
    for text in ('"注：拆除"', '"之间的连接片"', '"注：短接"', '"、"', '":"'):
        assert text in body, text
    print('PASS: ZHU structure, HZ/3/0.7 text and note format')


if __name__ == '__main__':
    check()
    print('ALL ZHU STATIC CHECKS PASS')
