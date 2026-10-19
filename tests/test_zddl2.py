"""本机绘图核心与网页核心逐实体比较；不连接 CAD。"""
import importlib.util
import re
import sys
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "tools"))
import zddl2_bridge as bridge
import zddl2_engine as engine
from lsp_common import parse, defun_forms
from check_cable_perf_static import Runner, literal


class StringRunner(Runner):
    """补足既有离线解释器的 AutoLISP 反斜线与引号转义。"""
    def eval(self, expr, env):
        if isinstance(expr, str) and expr.startswith('"'):
            return re.sub(r'\\(.)', lambda m: {"n": "\n", "r": "\r", "t": "\t"}.get(
                m[1], m[1]), expr[1:-1])
        return super().eval(expr, env)


class ZDDL2Tests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.funcs = {str(f[1]).lower(): f for f in defun_forms(parse(
            (ROOT / "AA整合版本.lsp").read_text(encoding="utf-8")))}

    def test_actual_lisp_emits_offset_entities(self):
        # 纯 AutoLISP 重构后，执行现有 work 的 shift/to-dxf/entmake 链路。
        # 模拟交互与解析结果，图元构造、坐标平移及标高处理均运行实际源码。
        class GeometryRunner(Runner):
            def eval(self, expr, env):
                # quote 后 lambda 中的数值已被离线解释器转换为 Python 数值。
                if isinstance(expr, (int, float)):
                    return expr
                return super().eval(expr, env)

        runner, made = GeometryRunner(self.funcs), []
        source = [
            runner.call("zddl2:e-line", [[1., 2.], [3., 4.], "test", 7]),
            runner.call("zddl2:e-text", ["A431", 2., 3., "test", 1, 2, 3., 1.5707963, 7]),
            runner.call("zddl2:e-poly", [[[1., 2.], [3., 4.], [5., 6.]], "test", 7]),
        ]
        runner.mocks.update({
            "ssget": lambda *args: ["text"], "sslength": len,
            "ssname": lambda ss, i: ss[i], "zddl2:text": lambda en: "X、1",
            "vl-string-search": lambda sub, text: text.find(sub) if sub in text else None,
            "initget": lambda *args: None, "getkword": lambda *args: "Shang",
            "getpoint": lambda *args: [100., 200., 30.], "trans": lambda p, *args: p,
            "zddl2:selection-text": lambda *args: "X、1",
            "zddl2:wiring-text": lambda *args: "X:1、A、柜",
            "zddl2:generate": lambda *args: ["OK", "完成", source],
            "tblsearch": lambda *args: None, "zddl:ensure-layer": lambda *args: None,
            "entmake": lambda data: made.append(data) or True,
            "redraw": lambda: None, "princ": lambda *args: None,
        })
        runner.call("zddl2:work", [])
        entities = [e for e in made if e[0] in [(0, "LINE"), (0, "TEXT"), (0, "LWPOLYLINE")]]
        self.assertEqual(3, len(entities))
        for before, after in zip(source, entities):
            expected = []
            for code, value in before:
                if code in (10, 11):
                    value = [value[0] + 100., value[1] + 200.,
                             *([value[2] + 30.] if len(value) == 3 else [])]
                    expected.append([code, *value])
                else:
                    expected.append((code, value))
            if before[0][1] == "LWPOLYLINE":
                expected.append((38, 30.))
            self.assertEqual(expected, after)

    def test_actual_command_cleanup_on_success_and_error(self):
        for fail in (False, True):
            runner, events = Runner(self.funcs), []
            def work():
                if fail:
                    raise RuntimeError("模拟本机绘图失败")
            def caught(name, args):
                try:
                    return runner.call(name, args or [])
                except RuntimeError as error:
                    return error
            runner.mocks.update({
                "aa:cmd-begin": lambda tag: events.append("begin"),
                "aa:cmd-end": lambda: events.append("end"),
                "zddl2:work": work, "princ": lambda *a: None,
                "sssetfirst": lambda *a: None,
                "vl-catch-all-error-message": str,
                "vl-catch-all-apply": caught,
            })
            runner.call("c:zddl2", [])
            self.assertEqual(["begin", "end"], events)

    def test_actual_mtext_paragraphs_become_input_lines(self):
        runner = StringRunner(self.funcs)
        runner.mocks["dx:text-string"] = lambda en: r"{\C4;X、1、2}\PX:1、A、柜"
        runner.mocks["vl-string-search"] = lambda sub, text, start=0: (
            text.find(sub, start) if sub in text[start:] else None)
        self.assertEqual("X、1、2\nX:1、A、柜", runner.call("zddl2:text", ["text"]))

    def test_actual_selection_cancellation_does_not_start_generator(self):
        for stage in range(3):
            runner, calls = Runner(self.funcs), []
            selections = iter([None] if stage == 0 else ["terminals", None if stage == 1 else "wiring"])
            runner.mocks.update({
                "findfile": lambda path: path, "princ": lambda *a: None,
                "ssget": lambda *a: next(selections),
                "sslength": lambda ss: 1, "ssname": lambda ss, i: "text",
                "zddl2:text": lambda en: "X、1",
                "initget": lambda *a: None, "getkword": lambda *a: "Shang",
                "getpoint": lambda *a: None,
                "zddl2:run-process": lambda *a: calls.append(a),
            })
            runner.call("zddl2:work", [], {"*zddl2-python*": "pythonw", "*zddl2-root*": "root"})
            self.assertFalse(calls)

    def test_outer_alignment_and_roundtrip_data(self):
        import ezdxf
        from ezdxf.enums import TextEntityAlignment as Align
        for direction, align in [("UP", Align.MIDDLE_RIGHT), ("DOWN", Align.MIDDLE_LEFT)]:
            with self.subTest(direction=direction), tempfile.TemporaryDirectory() as folder:
                folder = Path(folder)
                t, w, out = [folder / name for name in ("t.txt", "w.txt", "out.txt")]
                t.write_text("X、1、2、3", encoding="utf-8")
                w.write_text("X:1、B+、X:2、A431、X:3、长编号917、目标柜", encoding="utf-8")
                bridge.generate(t, w, out, direction)
                lines = out.read_text(encoding="utf-8").splitlines()
                data = [parse(line)[0] for line in lines]
                self.assertEqual(int(data[0][1]), len(data) - 1)
                params, skipped = bridge.prepare(t.read_text(encoding="utf-8"), w.read_text(encoding="utf-8"), direction)
                dxf = folder / "reference.dxf"
                engine.build_dxf(params, engine.DRAWING, dxf)
                doc = ezdxf.readfile(dxf)
                self.assertEqual(lines[1:], [bridge.entity_data(e) for e in doc.modelspace()])
                principles = list(doc.modelspace().query('TEXT[layer=="接线-原理号"]'))
                self.assertEqual(3, len(principles))
                self.assertTrue(all(e.get_align_enum() == align for e in principles))
                self.assertEqual(1, len(set(e.dxf.align_point.y for e in principles)))

    def test_partial_keeps_destination_and_original_numbers(self):
        params, skipped = bridge.prepare("X、1",
            "Y:1、A、Y:2、B、未选柜\nX:1、C、Y:3、D、所选柜\nZ:1、E、另一柜", "UP")
        self.assertEqual(4, skipped)
        self.assertEqual(1, len(params["connections"]))
        c = params["connections"][0]
        self.assertEqual(("WL-02", "所选柜", "C"), (c["cableNumber"], c["toCabinet"], c["principle"]))

    def test_compact_missing_reference_and_repeated_terminal(self):
        params, skipped = bridge.prepare("JD、1", "OTHER1、A、未选柜\nJD1、L、柜1\nJD1、N、柜2", "DOWN")
        self.assertEqual(1, skipped)
        positions, _, _ = engine.build_columns(params, engine.DRAWING)
        cables, _ = engine.build_cables(params, positions, 1.5)
        self.assertEqual(2, len(cables))
        self.assertEqual(1.5, cables[1]["points"][0]["leadX"] - cables[0]["points"][0]["leadX"])

    def test_all_unselected_still_draws_selected_strips(self):
        params, skipped = bridge.prepare("X、1", "Y:1、A、其他柜", "UP")
        self.assertEqual(1, skipped)
        self.assertFalse(params["connections"])
        self.assertEqual(["1"], params["terminalBlocks"][0]["terminals"])

    def test_bad_input_and_escaped_text(self):
        with self.assertRaises(ValueError):
            bridge.prepare("端子排、", "X1、A", "UP")
        value = '引号"反斜线\\文字'
        self.assertEqual(len(parse(bridge.atom(value))), 1)

    def test_user_coordinate_attachment(self):
        attachment = Path("C:/Users/ys199/.codex/attachments/6ad00e12-5f53-4044-b8de-76b3c89490ad/已粘贴的文本.txt")
        if not attachment.exists():
            self.skipTest("本机会话附件不可用")
        text = attachment.read_text(encoding="utf-8-sig")
        params, _ = bridge.prepare(text, "UD:1、A630II、UD:2、B630II、UD:3、C630II、UD:4、N600、电压转接柜", "UP")
        self.assertEqual(4, len(params["connections"]))
        self.assertGreater(sum(len(b["terminals"]) for b in params["terminalBlocks"]), 50)


if __name__ == "__main__":
    unittest.main()
