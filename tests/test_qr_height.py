"""QR/QR2 共享高度与回车语义的离线实际 AST 回归；不连接 CAD。"""
import sys
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "tools"))
from lsp_common import parse, walk
from check_cable_perf_static import Runner


class HeightRunner(Runner):
    def __init__(self, funcs):
        super().__init__(funcs)
        self.memory = {"*qr_last_height*": None}
        self.saved = {}
        self.prompts, self.modified, self.events = [], [], []
        self.selections, self.heights = iter([]), iter([])
        self.mocks.update({
            "aa:cmd-begin": lambda tag: self.events.append("begin"),
            "aa:cmd-end": lambda: self.events.append("end"),
            "initget": lambda flags: self.events.append(("initget", flags)),
            "getdist": self.getdist,
            "ssget": lambda *a: next(self.selections), "sslength": len,
            "ssname": lambda ss, i: ss[i],
            "entget": lambda en: [(0, "TEXT"), (40, 1.)],
            "entmod": lambda data: self.modified.append(data) or data,
            "redraw": lambda: self.events.append("redraw"),
            "princ": lambda *a: None, "numberp": lambda v: isinstance(v, (int, float)),
            "type": lambda v: "str" if isinstance(v, str) else "real",
            "distof": lambda s, mode: self.distof(s),
            "rtos": lambda v, mode=2, precision=4: f"{v:.{precision}f}",
            "vl-string-right-trim": lambda chars, s: s.rstrip(chars),
            "getenv": lambda key: self.saved.get(key),
            "setenv": lambda key, value: self.saved.update({key: value}),
            "vl-catch-all-apply": lambda name, args: self.call(name, args or []),
        })

    @staticmethod
    def distof(s):
        try:
            return float(s)
        except ValueError:
            return None

    def getdist(self, prompt):
        assert self.events[-1] == ("initget", 6)
        self.prompts.append(prompt)
        return next(self.heights)

    def call(self, name, values, env=None):
        return super().call(name, values, (env or {}) | self.memory)

    def eval(self, expr, env):
        result = super().eval(expr, env)
        if isinstance(expr, list) and expr[:1] == ["setq"]:
            for name in expr[1::2]:
                if name in self.memory:
                    self.memory[name] = env[name]
        return result


class QRHeightTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        forms = parse((ROOT / "AA整合版本.lsp").read_text(encoding="utf-8"))
        cls.funcs = {f[1]: f for f in forms if isinstance(f, list) and f[:1] == ["defun"]}

    def test_shared_memory_and_each_round_default(self):
        r = HeightRunner(self.funcs)
        r.heights, r.selections = iter([3.5]), iter([["text"]])
        r.call("c:qr", [])
        r.heights, r.selections = iter([None, 4.25, None]), iter([["text"]] * 3 + [None])
        r.call("c:qr2", [])
        self.assertTrue(all("<3.5>" in p for p in r.prompts[1:3]))
        self.assertIn("<4.25>", r.prompts[3])
        self.assertEqual([3.5, 3.5, 4.25, 4.25], [dict(d)[40] for d in r.modified])
        r.heights, r.selections = iter([None]), iter([["text"]])
        r.call("c:qr", [])
        self.assertIn("<4.25>", r.prompts[-1])
        self.assertEqual(4.25, dict(r.modified[-1])[40])
        self.assertEqual(["begin", "end"] * 3, [e for e in r.events if e in ("begin", "end")])
        self.assertEqual(4.25, float(r.saved["AA_QR_Height"]))

    def test_no_memory_enter_skips_round_then_accepts_height(self):
        r = HeightRunner(self.funcs)
        r.heights, r.selections = iter([None, 2.]), iter([["text"], ["text"], None])
        r.call("c:qr2", [])
        self.assertTrue(all("<" not in p for p in r.prompts))
        self.assertEqual(1, len(r.modified))
        self.assertEqual(2., dict(r.modified[0])[40])

    def test_persistent_memory_invalid_and_positive_values(self):
        for value, expected in [(None, None), ("bad", None), ("0", None), ("-2", None), ("3.5", 3.5)]:
            r = HeightRunner(self.funcs)
            if value is not None:
                r.saved["AA_QR_Height"] = value
            self.assertEqual(expected, r.call("qr:last-height", []))
        self.assertEqual("3.5", r.call("qr:height-str", [3.5]))
        self.assertEqual("100", r.call("qr:height-str", [100.]))

    def test_top_level_helpers_and_height_input_guard(self):
        for name in ("c:qr", "c:qr2", "qr:last-height", "qr:save-height", "qr:height-str"):
            self.assertIn(name, self.funcs)
        for name in ("c:qr", "c:qr2"):
            form = self.funcs[name]
            self.assertIn("last-h", form[2])
            # getdist 的 setq 前一个同层表达式必须为 initget 6。
            blocks = [form[3:]] + list(walk(form[3:]))
            guards = 0
            for block in blocks:
                for i, item in enumerate(block):
                    if isinstance(item, list) and item[:2] == ["setq", "a"] and any(
                        node[:1] == ["getdist"] for node in walk(item)):
                        self.assertEqual(["initget", "6"], block[i - 1])
                        guards += 1
            self.assertGreater(guards, 0)


if __name__ == "__main__":
    unittest.main()

