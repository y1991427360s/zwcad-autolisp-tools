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
            runner.call("zddl2:e-line", [[0., 0.], [5., 0.], "端子排-框线", 7]),
        ]
        locks = []
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
            "regapp": lambda name: name,
            "zddl2:set-layer-lock": lambda name, lock: locks.append((name, bool(lock))),
        })
        runner.call("zddl2:work", [None])
        entities = [e for e in made if e[0] in [(0, "LINE"), (0, "TEXT"), (0, "LWPOLYLINE")]]
        self.assertEqual(4, len(entities))
        # 辅助层先解锁、生成后再锁定；只有辅助层图元带 AA_ZDDL 标记
        self.assertEqual([("端子排-框线", False), ("端子排-文字", False),
                          ("端子排-框线", True), ("端子排-文字", True)], locks)
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
            if before[1][1] == "端子排-框线":
                expected.append([-3, ["AA_ZDDL", (1000, "ZDDL")]])
            self.assertEqual(expected, after)

    def test_actual_command_cleanup_on_success_and_error(self):
        for command, fail in [(c, f) for c in ("c:zddlh", "c:zddls") for f in (False, True)]:
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
                "zddl2:work": lambda vertical=None: work(), "princ": lambda *a: None,
                "sssetfirst": lambda *a: None,
                "vl-catch-all-error-message": str,
                "vl-catch-all-apply": caught,
            })
            runner.call(command, [])
            self.assertEqual(["begin", "end"], events)

    def test_vertical_layout_rotates_horizontal_result(self):
        # ZDDLS：同一输入的横向结果顺时针转 90°；绿色电缆线竖直、箭头向下、电缆文字 270°、端子号水平。
        class GeometryRunner(StringRunner):
            def eval(self, expr, env):
                if isinstance(expr, (int, float)):
                    return expr
                return super().eval(expr, env)
        import math
        runner = GeometryRunner(self.funcs)
        runner.mocks["eq"] = lambda a, b: a is b
        # 按 zddl2:draw-cables / draw-layout 的横向尺寸构造一根向上出线的电缆（ycab=60，箭头尖端 x=100）
        tip, ycab, d = 100.0, 60.0, 2.5 * math.sqrt(3.0)
        source = [
            runner.call("zddl2:e-line", [[12.5, 50.0], [12.5, ycab], "电缆-接线", 7]),
            runner.call("zddl2:e-line", [[13.5, ycab], [12.5, ycab - 1.0], "电缆-接线", 7]),
            runner.call("zddl2:e-line", [[12.5, ycab], [tip + 40.0, ycab], "电缆-接线", 3]),
            runner.call("zddl2:e-poly", [[[tip, ycab], [tip - d, ycab + 2.5], [tip - d, ycab - 2.5]], "电缆-接线", 7]),
            runner.call("zddl2:e-text", ["未编号", tip - 20.0, ycab + 0.5, "电缆-文字", 0, 0, 3.0, 0.0, 7]),
            runner.call("zddl2:e-text", ["至目标柜", tip + 1.5, ycab + 0.5, "电缆-文字", 0, 0, 3.0, 0.0, 7]),
            runner.call("zddl2:e-text", ["未填写", tip + 32.0, ycab + 0.5, "电缆-文字", 0, 0, 3.0, 0.0, 7]),
            runner.call("zddl2:e-text", ["1", 12.5, 37.5, "端子排-文字", 1, 2, 3.0, 1.5707963, 7]),
            runner.call("zddl2:e-text", ["A", 12.5, 73.0, "接线-原理号", 2, 2, 3.0, 1.5707963, 4]),
        ]
        res = ["OK", "", source]
        rotated = [runner.call("zddl2:rotate-cw", [e], {"pi": math.pi}) for e in res[2]]
        def get(e, code):
            return next((g[1] for g in e if g[0] == code), None)
        greens = [e for e in rotated if get(e, 0) == "LINE" and get(e, 62) == 3]
        self.assertEqual(1, len(greens))
        p1, p2 = get(greens[0], 10), get(greens[0], 11)
        self.assertAlmostEqual(p1[0], p2[0])
        self.assertGreater(p1[1], p2[1])
        arrow = next(e for e in rotated if get(e, 0) == "LWPOLYLINE")
        pts = [g[1] for g in arrow if g[0] == 10]
        self.assertTrue(all(pts[0][1] < q[1] for q in pts[1:]))
        for e in rotated:
            if get(e, 0) == "TEXT":
                angle = get(e, 50)
                if get(e, 8) == "电缆-文字":
                    self.assertAlmostEqual(1.5 * math.pi, angle, places=5)
                    self.assertAlmostEqual(p1[0] + 0.5, get(e, 10)[0])
                else:
                    self.assertAlmostEqual(0.0, angle, places=5)
        texts = {get(e, 1): get(e, 10) for e in rotated if get(e, 0) == "TEXT"}
        tip_y = pts[0][1]
        self.assertAlmostEqual(tip_y + 20.0, texts["未编号"][1])
        self.assertAlmostEqual(tip_y - 1.5, texts["至目标柜"][1])
        self.assertAlmostEqual(tip_y - 32.0, texts["未填写"][1])
        # 短斜线与 BDL 向右出线一致：(xcab-1, y) → (xcab, y-1)
        slash = rotated[1]
        self.assertEqual([[60.0, -13.5], [59.0, -12.5]], [list(get(slash, 10)[:2]), list(get(slash, 11)[:2])])
        # 横向 → 竖向坐标映射 (x, y) → (y, -x)
        for before, after in zip(res[2], rotated):
            for g0, g1 in zip(before, after):
                if g0[0] in (10, 11):
                    self.assertEqual([g0[1][1], -g0[1][0]], list(g1[1][:2]))

    def test_vertical_terminal_column_selection(self):
        # 用户 QW3 竖排端子排：端子名在上、端子号往下每格 5，一列叠 8 块（143 个文字）。
        # ZDDLS 把 (x, y) 转成 (-y, x) 后按横排解析：整列为一排，块和端子号按从上往下的顺序读出。
        import json
        data = json.loads((ROOT / "tests/fixtures/zddls_qw3_143_vertical.json").read_text(encoding="utf-8"))
        ents = [{0: "TEXT", 1: t, 10: [x, y, 0.0], 11: [x, y, 0.0]} for x, y, t in data["items"]]
        class NumberRunner(StringRunner):
            def eval(self, expr, env):
                if isinstance(expr, (int, float)):
                    return expr
                return super().eval(expr, env)
        runner = NumberRunner(self.funcs)
        sys.setrecursionlimit(max(sys.getrecursionlimit(), 20000))
        runner.mocks.update({
            "eq": lambda a, b: a is b,
            "sslength": len, "ssname": lambda ss, i: ss[i], "entget": lambda en: en,
            "zddl2:text": lambda en: en[1],
            "zddl:text-point": lambda en, ed: ed[11],
            "aa:dz-number-p": lambda t: t.rstrip("a").isdigit(),
            "wcmatch": lambda t, pat: t.endswith(pat.lstrip("*")),
            "rtos": lambda v, mode, prec: "%.*f" % (prec, v),
        })
        expected = [("Q1D", 27), ("YD", 21), ("BSD", 14), ("TD", 29), ("XD", 5), ("JRD", 11), ("BD", 8), ("XMX", 20)]
        for shuffled in (ents, list(reversed(ents))):
            text = runner.call("zddl2:selection-text", [shuffled, True, True])
            rows = []
            for line in text.splitlines():
                xy, token = line.split(" ", 1)
                marked = token.endswith("端子名")
                rows.append([float(xy.split(",")[0]), float(xy.split(",")[1]),
                             token[:-3].strip() if marked else token, True if marked else None])
            blocks, errors = runner.call("zddl2:coord-horizontal", [rows])
            self.assertFalse(errors)
            self.assertEqual(expected, [(b[1], len(b[2])) for b in blocks])
            for b in blocks:
                self.assertEqual([str(i) for i in range(1, len(b[2]) + 1)], list(b[2]))
            self.assertEqual(1, len({b[3] for b in blocks}))
        # 同一份文字按横排读（ZDDLH）会把每个文字各算一排，读不出端子排，证明必须按竖排处理
        text = runner.call("zddl2:selection-text", [ents, True, None])
        rows = []
        for line in text.splitlines():
            xy, token = line.split(" ", 1)
            marked = token.endswith("端子名")
            rows.append([float(xy.split(",")[0]), float(xy.split(",")[1]),
                         token[:-3].strip() if marked else token, True if marked else None])
        blocks, errors = runner.call("zddl2:coord-horizontal", [rows])
        self.assertNotEqual(expected, [(b[1], len(b[2])) for b in blocks])

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
            runner.call("zddl2:work", [None], {"*zddl2-python*": "pythonw", "*zddl2-root*": "root"})
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
        # 该附件是旧的纵列坐标清单；2026-10-22 起坐标端子排始终按横排读取，纵列清单会报“没有识别到端子号”。
        with self.assertRaisesRegex(ValueError, "没有识别到端子号"):
            bridge.prepare(text, "UD:1、A630II、UD:2、B630II、UD:3、C630II、UD:4、N600、电压转接柜", "UP")

    def test_loose_coordinate_rows_match_engine(self):
        # 坐标始终横排、容差 30：未对齐的横排、名称在中间及多排，LISP 与网页核心结果一致。
        runner = StringRunner(self.funcs)
        runner.mocks["eq"] = lambda a, b: a is b
        cases = {
            "0,0 ZD 端子名\n" + "\n".join("%d,%.1f %d" % (5 * i, (-8.0, 6.0)[i % 2], i) for i in range(1, 13)):
                [("ZD", [str(i) for i in range(1, 13)])],
            "0,0 1\n5,0 2\n10,2 ZD 端子名\n15,0 3\n20,0 4": [("ZD", ["1", "2", "3", "4"])],
            "0,0 ZD 端子名\n5,0 1\n10,0 2\n0,-40 JD 端子名\n5,-40 1\n10,-40 2\n15,-40 3":
                [("ZD", ["1", "2"]), ("JD", ["1", "2", "3"])],
            "0,0 ZD 端子名\n5,0 1\n10,0 2\n30,0 JD 端子名\n35,0 1": [("ZD", ["1", "2"]), ("JD", ["1"])],
        }
        for text, expected in cases.items():
            blocks, errors = engine.parse_coordinate_terminals(text)
            self.assertEqual([], errors)
            self.assertEqual(expected, [(b["label"], b["terminals"]) for b in blocks])
            rows = []
            for line in text.splitlines():
                xy, token = line.split(" ", 1)
                marked = token.endswith("端子名")
                rows.append([float(xy.split(",")[0]), float(xy.split(",")[1]),
                             token[:-3].strip() if marked else token, True if marked else None])
            result = runner.call("zddl2:coord-horizontal", [rows])
            self.assertEqual(expected, [(b[1], list(b[2])) for b in result[0]])
            self.assertFalse(result[1])

    def test_user_320_horizontal_rows_stay_four_rows(self):
        # 用户 QW3 选中的 320 个旋转 90° 文字（4 排、40 块端子排，按对齐点坐标重建）。
        # 同一排的端子排必须共用排键，出图仍为 4 排；曾因每块单独成排画成 40 排。
        import json
        items = json.loads((ROOT / "tests/fixtures/zddl_qw3_320_horizontal.json").read_text(encoding="utf-8"))
        rows = [[x, y, t, None if t.isdigit() else True] for x, y, t in items]
        runner = StringRunner(self.funcs)
        runner.mocks["eq"] = lambda a, b: a is b
        blocks, errors = runner.call("zddl2:coord-horizontal", [rows])
        self.assertFalse(errors)
        self.assertEqual(40, len(blocks))
        self.assertEqual(320 - 40, sum(len(b[2]) for b in blocks))
        groups = {}
        for b in blocks:
            groups.setdefault(b[3], []).append(b[1])
        self.assertEqual([12, 5, 9, 14], [len(v) for v in groups.values()])
        self.assertEqual(["1C5D", "ZD", "I14D", "UD"], [v[0] for v in groups.values()])
        self.assertEqual(31, len(next(b[2] for b in blocks if b[1] == "YBD")))
        cols = runner.call("zddl2:columns", [blocks])
        self.assertEqual(4, len({p[4] for p in cols[0]}))
        text = "\n".join("%.6f,%.6f %s" % (x, y, t if t.isdigit() else t + " 端子名") for x, y, t in items)
        py_blocks, py_errors = engine.parse_coordinate_terminals(text)
        self.assertEqual([], py_errors)
        self.assertEqual([(b[1], list(b[2]), b[3]) for b in blocks],
                         [(b["label"], b["terminals"], b["physicalGroup"]) for b in py_blocks])


if __name__ == "__main__":
    unittest.main()
