"""Offline MTEXT format-strip regression; executes the real LISP AST, never connects to CAD."""
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / 'tools'))
sys.path.insert(0, str(Path(__file__).resolve().parent))

from lsp_common import defun_forms, parse, read_source  # noqa: E402
from test_ss_mm_ortho_osnap import Lisp, base_builtins  # noqa: E402


def unescape(node):
    """AutoLISP 字符串字面量中的 \\\\ 与 \\" 需还原，否则比较不到单个反斜杠。"""
    if isinstance(node, list):
        return [unescape(x) for x in node]
    if isinstance(node, str) and len(node) >= 2 and node[0] == '"':
        inner = node[1:-1].replace('\\\\', '\\').replace('\\"', '"')
        return '"' + inner + '"'
    return node


def build():
    _, text = read_source()
    funcs = {f[1]: unescape(f) for f in defun_forms(parse(text))}
    b = base_builtins()
    b.update({
        'strlen': len,
        'substr': lambda s, i, n=None: s[i - 1:i - 1 + n] if n is not None else s[i - 1:],
        'vl-string-search': lambda pat, s, start=0: (lambda r: None if r < 0 else r)(s.find(pat, start)),
        '<=': lambda a, b: True if a <= b else None,
    })
    return Lisp(funcs, b)


def strip(lisp, raw):
    return lisp.call('aa:ysdl-strip-mtext-format', [raw], {})


def clean(lisp, raw, keep):
    return lisp.call('aae:clean-mtext-format', [raw, True if keep else None], {})


def check_strip():
    lisp = build()
    # 用户实测样例：\p 段落缩进格式码曾残留 "i23.89632;"
    raw = r'\pi23.89632;{\Fgbenor,gbcbig|c134;\T1.1;小电阻接地成套装置}'
    assert strip(lisp, raw) == '小电阻接地成套装置', strip(lisp, raw)
    # 段落格式码的多种参数形式，整段丢弃
    assert strip(lisp, r'\pxi-2,l0,t0;甲乙') == '甲乙'
    assert strip(lisp, r'\pxqc;丙丁\P戊己') == '丙丁 戊己'
    # \P 换行、\~ 不间断空格仍转成空格，不被 \p 分支吞掉
    assert strip(lisp, r'第一行\P第二行') == '第一行 第二行'
    assert strip(lisp, r'A\~B') == 'A B'
    # 既有格式码行为不变：字体/字高/颜色/跟踪/宽度、花括号、堆叠
    assert strip(lisp, r'{\fArial|b1|i1|c134;\H1.5x;\C3;\T1.1;\W0.8;ABC}') == 'ABC'
    assert strip(lisp, r'{\S1^2;}') == '1/2'
    assert strip(lisp, r'{\S3#4;}') == '3/4'
    assert strip(lisp, r'\Lab\lc') == 'abc'  # 下划线/上划线/删除线只是开关，不产出字符
    # \p 缺分号时按未知码处理，不能吞掉后面的正文
    assert strip(lisp, r'\pABC') == 'ABC'
    print('PASS MTEXT strip: \\p paragraph codes removed; \\P/\\~ retained as space; '
          'font/height/color/tracking/width/stacking unchanged')


def check_aae_clean():
    lisp = build()
    # AAE 属性编辑同一处解析：\p 不是换行，keep-newline 时也不能变成 \P
    assert clean(lisp, r'\pi23.89632;A\PB', True) == r'A\PB'
    assert clean(lisp, r'\pi23.89632;A\PB', False) == 'AB'
    assert clean(lisp, r'{\Fgbenor|b0;\pxqc;装置}', True) == '装置'
    print('PASS AAE clean-mtext-format: \\p dropped, \\P kept only when keep-newline')


def check():
    check_strip()
    check_aae_clean()


if __name__ == '__main__':
    check()
