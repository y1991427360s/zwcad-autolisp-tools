"""Offline QW2P checks: command structure, and run the clipboard parser through a mini evaluator."""
from lsp_common import SOURCE, parse, read_source, walk
import lisp_mini_eval as ev


def distof(text, _mode):
    try:
        return float(text)
    except ValueError:
        return None


def substr(text, start, length=None):
    return text[start - 1:] if length is None else text[start - 1:start - 1 + length]


def search(needle, text):
    pos = text.find(needle)
    return pos if pos >= 0 else None


# 模拟 vl-string-search 按字节计数：中文 UTF-8 占 3 字节，返回位置与 substr 不一致
def byte_search(needle, text):
    pos = text.find(needle)
    return len(text[:pos].encode('utf-8')) if pos >= 0 else None


def parsed(text):
    ev.G['clip'] = text
    return ev.call('(qw2p:parse-clip clip)')


def check():
    _, source = read_source(SOURCE)
    forms = parse(source)
    funcs = {f[1]: f for f in forms if isinstance(f, list) and f and f[0] == 'defun'}
    for name in ('c:qw2p', 'qw2p:newline-pos', 'qw2p:parse-line', 'qw2p:add-line', 'qw2p:parse-clip',
                 'qw2p:read-clip-file', 'qw2p:text-data'):
        assert name in funcs, name + ' must remain top-level'
    calls = list(walk(funcs['c:qw2p']))
    assert ['aa:cmd-begin', '"QW2P"'] in calls and ['aa:cmd-end'] in calls
    assert ['qe:get-clip-text'] in calls and ['qw2p:read-clip-file'] in calls
    reader = str(funcs['qw2p:read-clip-file'])
    assert 'get-clipboard' in reader.lower() and ':vlax-true' in reader.lower() and 'aa:link-open' in reader
    assert ['trans', 'base', '1', '0'] in calls
    assert 'vl-sort' not in str(funcs['c:qw2p'])
    assert 'entsel' not in str(funcs['c:qw2p']), 'QW2P no longer asks for a sample text'
    assert ['tblsearch', '"STYLE"', '"HZ"'] in calls
    print('PASS: QW2P structure')

    # 迷你解释器不还原字符串里的转义，这里换成真实字符
    runnable = source.replace('"\\n"', '"\n"').replace('" \\t\\r"', '" \t\r"')
    ev.load_defuns(runnable, 'qw2p:')
    ev.B.update({'substr': substr, 'strlen': len, 'distof': distof,
                 'caddr': lambda a: a[2] if a and len(a) > 2 else None,
                 'vl-string-trim': lambda chars, s: s.strip(chars)})
    sample = ('39997.97,2047.04 35kV 风机回路进线柜+备用柜\r\n'
              '-12.5,3 至1-1#直流,馈线柜\r\n'
              '\r\n'
              "40197.97,1969.54 485+'\n"
              '0,0 末行没有换行')
    expected = [[[39997.97, 2047.04, '35kV 风机回路进线柜+备用柜'],
                 [-12.5, 3.0, '至1-1#直流,馈线柜'],
                 [40197.97, 1969.54, "485+'"],
                 [0.0, 0.0, '末行没有换行']], 0, None]
    for finder in (search, byte_search):
        ev.B['vl-string-search'] = finder
        assert parsed(sample) == expected, parsed(sample)
    ev.B['vl-string-search'] = search
    for bad in ('这不是坐标', '12,34', 'a,b 文字', '12 文字', ',34 文字', '12,34 '):
        items, count, first = parsed(bad + '\r\n1,2 正常')
        assert count == 1 and items == [[1.0, 2.0, '正常']], (bad, items, count)
        assert first == bad.strip(), (bad, first)
    # 末行被截断时留下一条残缺行，提示里要能看到它
    assert parsed('1,2 正常\r\n39672.55,108')[1:] == [1, '39672.55,108']
    print('PASS: QW2P clipboard parser (Chinese offsets, spaces, commas, bad lines)')

    ev.B['getvar'] = lambda name: {'CLAYER': '电缆层'}[name]
    data = ev.call('(qw2p:text-data (list 1.0 2.0 0.0) "文字")')
    pairs = {item[0]: list(item[1:]) if len(item) > 2 else item[1] for item in data}
    assert pairs == {0: 'TEXT', 8: '电缆层', 10: [1.0, 2.0, 0.0], 40: 3.0, 1: '文字', 7: 'HZ', 50: 0.0, 41: 0.7}, pairs
    print('PASS: QW2P text matches T style on the current layer, color by layer')


if __name__ == '__main__':
    check()
