"""Offline DH checks: command structure, and run the MTEXT parser and wrap through a mini evaluator."""
from lsp_common import SOURCE, parse, read_source, walk
import lisp_mini_eval as ev


BS = '¤'  # 解释器分词不支持单独的反斜杠字符串，测试时用这个字符代替


def substr(text, start, length=None):
    return text[start - 1:] if length is None else text[start - 1:start - 1 + length]


def lines_of(raw):
    ev.G['raw'] = raw.replace(chr(92), BS)
    return ev.call('(dh:parse raw)')


def wrapped(text, boxw):
    ev.G['s'] = text
    ev.G['b'] = boxw
    return ev.call('(dh:wrap s "ST" 2.5 1.0 b)')


# 模拟宋体：中文约 3.4 宽，英文数字约 1.7 宽
def width(text):
    return sum(3.4 if ord(c) > 126 else 1.7 for c in text)


def check():
    _, source = read_source(SOURCE)
    forms = parse(source)
    funcs = {f[1]: f for f in forms if isinstance(f, list) and f and f[0] == 'defun'}
    for name in ('c:dh', 'dh:run', 'dh:convert', 'dh:parse', 'dh:wrap'):
        assert name in funcs, name + ' must remain top-level'
    assert funcs['c:dh'][3:] == [['aa:cmd-begin', '"DH"'], ['dh:run'], ['aa:cmd-end']]
    convert = str(funcs['dh:convert'])
    assert "'txt2:ensure-style'" in convert and "'aa:safe-get-bbox'" in convert
    assert 'command' not in [c[0] for c in walk(funcs['dh:convert']) if isinstance(c, list) and c]
    assert "'entdel', 'en'" in convert, 'original is removed only by dh:convert after success'
    assert '"_:L"' in str(funcs['dh:run'])
    print('PASS: DH structure')

    # 迷你解释器不还原字符串里的转义，这里换成真实字符
    runnable = (source.replace('"\\n"', '"\n"').replace('"\\r"', '"\r"').replace('"\\t"', '"\t"')
                .replace('"\\\\"', '"' + BS + '"'))
    ev.load_defuns(runnable, 'dh:')
    ev.B.update({'/=': lambda a, b: a != b,
                 'member': lambda a, b: b[b.index(a):] if a in b else None,
                 'substr': substr, 'strlen': len, 'ascii': lambda c: ord(c[0]),
                 'distof': lambda s, _m: float(s), 'strcase': str.upper,
                 'wcmatch': lambda s, _p: s.endswith('X'),
                 'caddr': lambda a: a[2] if a and len(a) > 2 else None,
                 'vl-string-trim': lambda chars, s: s.strip(chars),
                 'vl-string-translate': lambda a, b, s: s.translate(str.maketrans(a, b)),
                 'max': max, 'caar': lambda a: a[0][0], 'caadr': lambda a: a[1][0],
                 'textbox': lambda d: [[0.0, 0.0, 0.0], [width(d[0][1]), 2.5, 0.0]]})
    font = '\\fSimSun|b0|i0|c134|p2;'
    assert lines_of('{' + font + '总装机箱（E6616）}')[0:2] == [['总装机箱（E6616）'], True]
    assert lines_of('32{' + font + '路}E1/T1{' + font + '支路板}')[0] == ['32路E1/T1支路板']
    assert lines_of('{' + font + '中继电缆}-20m-75ohm-21E1\n')[0] == ['中继电缆-20m-75ohm-21E1']
    assert lines_of('{' + font + '设备网元}LICENSE{' + font + '授权\n}')[0] == ['设备网元LICENSE授权']
    assert lines_of('第一行\\P第二行')[0] == ['第一行', '第二行']
    assert lines_of('A\\~B\\{C\\}\\\\D')[0] == ['A B{C}' + BS + 'D']
    assert lines_of('\\U+2205 25')[0] == [BS + 'U+2205 25']
    assert lines_of('\\S1^2;')[0] == ['1/2']
    parsed = lines_of('{\\H1.5x;\\W0.7;ABC}')
    assert parsed[2] == (1.5, True) or list(parsed[2]) == [1.5, True]
    print('PASS: DH parser')

    assert wrapped('通用交叉及主控时钟处理板', 24.5833) == ['通用交叉及主控', '时钟处理板']
    assert wrapped('中继电缆-20m-75ohm-21E1', 24.5833) == ['中继电缆-', '20m-75ohm-21E1']
    assert wrapped('设备网元LICENSE授权', 24.5833) == ['设备网元', 'LICENSE授权']
    assert wrapped('ABCDEFGHIJKLMNOPQR', 10.0) == ['ABCDE', 'FGHIJ', 'KLMNO', 'PQR']
    print('PASS: DH wrap')


if __name__ == '__main__':
    check()
