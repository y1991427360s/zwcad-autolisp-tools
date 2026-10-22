"""ZDAO / HDAO 文字颠倒离线回归；执行真实 LISP AST，不连接 CAD。"""
import sys
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / 'tools'))
sys.path.insert(0, str(Path(__file__).resolve().parent))

from lsp_common import defun_forms, parse, read_source  # noqa: E402
from test_ss_mm_ortho_osnap import Lisp, base_builtins  # noqa: E402


class Drawing:
    """最小图元库：图元名 -> DXF 列表；点组码用 [code, x, y, z] 表示。"""

    def __init__(self, texts):
        self.ents = {}
        for i, (x, y, typ, align) in enumerate(texts):
            ed = [(0, typ), (1, 'T%d' % i), [10, x, y, 0.0]]
            if align:
                ed.append([11, x + 1.0, y + 0.5, 0.0])
            self.ents['e%d' % i] = ed
        self.order = list(self.ents)
        self.events = []

    def pos(self, name):
        return tuple(next(p for p in self.ents[name] if p[0] == 10)[1:3])

    def align(self, name):
        return tuple(next(p for p in self.ents[name] if p[0] == 11)[1:3])


def build(drawing):
    _, text = read_source()
    funcs = {f[1]: f for f in defun_forms(parse(text))}
    b = base_builtins()
    lisp = Lisp(funcs, b)

    def assoc(k, lst):
        return next((p for p in (lst or []) if isinstance(p, (list, tuple)) and p[0] == k), None)

    def subst(new, old, lst):
        return [new if p is old else p for p in lst]

    def entmod(ed):
        name = drawing.current
        drawing.ents[name] = ed
        drawing.events.append(('entmod', name))
        return ed

    def entget(name):
        drawing.current = name
        return list(drawing.ents[name])

    b.update({
        'assoc': assoc, 'subst': subst, 'entget': entget, 'entmod': entmod,
        'ssget': lambda *a: list(drawing.order) or None,
        'sslength': len, 'ssname': lambda ss, i: ss[i],
        'length': lambda x: len(x or []),
        'nth': lambda i, x: x[i] if x and 0 <= i < len(x) else None,
        '/': lambda a, b: a // b if isinstance(a, int) and isinstance(b, int) else a / b,
        'apply': lambda fn, args: lisp.call(fn, list(args or []), {}),
        'itoa': str, 'redraw': lambda *a: drawing.events.append(('redraw',)),
        'aa:cmd-begin': lambda tag: drawing.events.append(('begin', tag)),
        'aa:cmd-end': lambda: drawing.events.append(('end',)),
    })
    return lisp


class DaoTests(unittest.TestCase):
    def run_cmd(self, cmd, texts):
        drawing = Drawing(texts)
        before = {n: drawing.pos(n) for n in drawing.ents}
        build(drawing).call(cmd, [], {})
        return drawing, before

    def test_zdao_reverses_vertical_order(self):
        # 自上而下 A(y=30) B(y=20) C(y=10)，选择顺序打乱
        drawing, before = self.run_cmd('c:zdao', [(0, 20, 'TEXT', False), (0, 10, 'MTEXT', False),
                                                  (0, 30, 'TEXT', False)])
        self.assertEqual(before['e2'], drawing.pos('e1'))  # 最下面到最上面
        self.assertEqual(before['e1'], drawing.pos('e2'))
        self.assertEqual(before['e0'], drawing.pos('e0'))  # 中间不动
        self.assertEqual(('begin', 'ZDAO'), drawing.events[0])
        self.assertEqual(('end',), drawing.events[-1])

    def test_hdao_reverses_horizontal_order(self):
        # 自左向右 e3(x=0) e1(x=5) e0(x=12) e2(x=30)，Y 各不相同
        drawing, before = self.run_cmd('c:hdao', [(12, 3, 'TEXT', False), (5, 8, 'TEXT', False),
                                                  (30, 1, 'MTEXT', False), (0, 6, 'TEXT', False)])
        self.assertEqual(before['e2'], drawing.pos('e3'))  # 最左到最右
        self.assertEqual(before['e3'], drawing.pos('e2'))
        self.assertEqual(before['e0'], drawing.pos('e1'))  # 左二到右二
        self.assertEqual(before['e1'], drawing.pos('e0'))
        self.assertEqual(('begin', 'HDAO'), drawing.events[0])
        self.assertEqual(('end',), drawing.events[-1])

    def test_hdao_moves_text_alignment_point(self):
        drawing, before = self.run_cmd('c:hdao', [(0, 0, 'TEXT', True), (10, 0, 'TEXT', True)])
        self.assertEqual(before['e1'], drawing.pos('e0'))
        self.assertEqual((11.0, 0.5), drawing.align('e0'))  # 对齐点 11 同步平移
        self.assertEqual((1.0, 0.5), drawing.align('e1'))

    def test_single_text_is_not_moved(self):
        drawing, before = self.run_cmd('c:hdao', [(3, 4, 'TEXT', False)])
        self.assertEqual(before['e0'], drawing.pos('e0'))
        self.assertNotIn('entmod', [e[0] for e in drawing.events])
        self.assertEqual(('end',), drawing.events[-1])


if __name__ == '__main__':
    unittest.main()
