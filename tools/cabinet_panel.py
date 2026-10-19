"""屏柜命令设置面板；只编辑当前项目文件，不连接 CAD。"""
from dataclasses import dataclass, replace
from contextlib import contextmanager
from datetime import datetime
from pathlib import Path
import os
import queue
import re
import subprocess
import sys
import threading
import tkinter as tk
from tkinter import ttk, messagebox, simpledialog

sys.path.insert(0, str(Path(__file__).resolve().parent))
from lsp_common import parse_with_locations

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "AA整合版本.lsp"
HANDLERS = frozenset(("aa:km-ln-cmd", "aa:yd-cmd", "aa:zj-cmd"))


def cabinet_candidates(text, forms):
    """独立于可编辑包装格式查找屏柜入口，防止结构变化后静默漏项。"""
    def calls(node):
        if not isinstance(node, list) or not node:
            return set()
        if isinstance(node[0], str) and node[0] in ("quote", "defun"):
            return set()
        found = {node[0]} if isinstance(node[0], str) else set()
        for child in node[1:]:
            found.update(calls(child))
        return found

    functions = [f for f in forms if isinstance(f, list) and len(f) >= 3
                 and f[0] == "defun" and isinstance(f[1], str)]
    graph = {}
    for form in functions:
        graph.setdefault(form[1], set()).update(set().union(*(calls(n) for n in form[3:])))
    # 新处理函数若沿用屏柜文字绘制核心，也能自动纳入检查。
    related = set(HANDLERS) | {"aa:km-create-centered-text"}
    while True:
        added = {name for name, deps in graph.items() if deps & related} - related
        if not added:
            break
        related.update(added)
    candidates = {name[2:].upper() for name in graph if name.startswith("c:") and name in related}
    for match in re.finditer(r"^;;;\s*-\s*([A-Za-z0-9_]+)\s*[:：]([^\r\n]*)", text, re.M):
        if "柜" in match[2] and "矩形" in match[2]:
            candidates.add(match[1].upper())
    # 独立实现、不复用公共绘图函数时的显式声明。
    candidates.update(m[1].upper() for m in re.finditer(
        r"^;;;\s*Cabinet-Panel:\s*([A-Za-z0-9_]+)\s*$", text, re.M | re.I))
    return candidates


@dataclass(frozen=True)
class Entry:
    name: str
    left: bool
    upper: str
    lower: str
    cabinet: str
    handler: str = "aa:km-ln-cmd"


def read_source(path):
    raw = Path(path).read_bytes()
    text = raw.decode("utf-8", errors="strict")
    if raw.startswith(b"\xef\xbb\xbf") or "\ufffd" in text:
        raise ValueError("整合文件存在 BOM 或替换字符，停止修改。")
    if b"\n" in raw.replace(b"\r\n", b"") or b"\r" in raw.replace(b"\r\n", b""):
        raise ValueError("整合文件换行不是统一 CRLF，停止修改。")
    return text


def unquote(token):
    if not isinstance(token, str) or not token.startswith('"'):
        raise ValueError("命令文字必须是字符串常量。")
    # 仅接受本面板可以无损往返的 LISP 字符串；不擅自解释未知转义。
    body = token[1:-1]
    chars = []
    i = 0
    while i < len(body):
        if body[i] == '\\':
            i += 1
            if i >= len(body) or body[i] not in '\\"':
                raise ValueError("文字包含特殊转义，暂不支持在面板中编辑。")
        chars.append(body[i])
        i += 1
    return ''.join(chars)


def quote(value):
    return '"' + value.replace('\\', '\\\\').replace('"', '\\"') + '"'


def wrappers(text):
    forms, locations = parse_with_locations(text)
    result = {}
    for form in forms:
        if (isinstance(form, list) and len(form) == 4 and form[0] == "defun"
                and isinstance(form[1], str) and form[1].startswith("c:")
                and form[2] == [] and isinstance(form[3], list)
                and len(form[3]) == 6 and isinstance(form[3][0], str) and form[3][0] in HANDLERS):
            call = form[3]
            name = form[1][2:].upper()
            if call[2] not in ("t", "nil") or unquote(call[1]).upper() != name:
                raise ValueError(f"{name} 的调用结构不支持面板编辑。")
            if name in result:
                raise ValueError(f"命令重复：{name}")
            result[name] = (Entry(name, call[2] == "t", *map(unquote, call[3:]), handler=call[0]),
                            locations[id(form)][1:])
    missing = cabinet_candidates(text, forms) - result.keys()
    if missing:
        raise ValueError("屏柜命令未被设置面板支持：" + "、".join(sorted(missing))
                         + "。请补齐面板适配和回归检查，不能忽略这些命令。")
    return result


def discover(text):
    return [entry for entry, span in wrappers(text).values()]


def description(entry):
    side = "左" if entry.left else "右"
    if entry.handler == "aa:zj-cmd":
        return (f"选中多条水平线后向{side}生成短线、矩形；标注{entry.upper}、{entry.lower}，"
                f"柜内文字默认读取剪贴板，可手动输入（手动默认：{entry.cabinet}；青色虚线）。")
    if entry.handler == "aa:yd-cmd":
        return (f"选中多条水平线后向{side}生成短线、矩形并从上往下标注"
                f"{entry.upper}、{entry.lower}01、{entry.lower}03...及{entry.cabinet}（青色虚线）。")
    return (f"选中至少两条水平线后向{side}生成短线、矩形并居中标注"
            f"{entry.upper}、{entry.lower}及{entry.cabinet}（青色虚线）。")


def definition(entry):
    return (f"(defun c:{entry.name} ()\r\n"
            f"  ({entry.handler} {quote(entry.name)} {'T' if entry.left else 'nil'} "
            f"{quote(entry.upper)} {quote(entry.lower)} {quote(entry.cabinet)})\r\n)")


def render(text, entries):
    old = wrappers(text)
    forms, _ = parse_with_locations(text)
    commands = {f[1][2:].upper() for f in forms if isinstance(f, list) and len(f) > 1
                and f[0] == "defun" and isinstance(f[1], str) and f[1].startswith("c:")}
    names = set()
    for entry in entries:
        if not re.fullmatch(r"(?=[A-Z0-9_]*[A-Z])[A-Z0-9][A-Z0-9_]{0,31}", entry.name):
            raise ValueError("命令名须以字母或数字开头且至少含一个英文字母，只能包含大写字母、数字、下划线（最多32位）。")
        if entry.name in names or (entry.name in commands and entry.name not in old):
            raise ValueError(f"命令名重复或与现有命令冲突：{entry.name}")
        names.add(entry.name)
        if entry.handler not in HANDLERS:
            raise ValueError("不支持的屏柜命令类型。")
        if entry.name in old and entry.handler != old[entry.name][0].handler:
            raise ValueError("不允许改变已有命令的编号类型。")
        if type(entry.left) is not bool:
            raise ValueError("方向无效。")
        for value in (entry.upper, entry.lower, entry.cabinet):
            if (not isinstance(value, str) or not value.strip() or len(value) > 200
                    or any(ord(c) < 32 or ord(c) == 127 for c in value) or "\ufffd" in value):
                raise ValueError(f"{entry.name}：文字不能为空，最多200字，不能包含换行、控制字符或替换字符。")
    if not set(old).issubset(names):
        raise ValueError("不允许删除或改名已有命令。")
    edits = []
    new_entries = []
    for entry in entries:
        if entry.name in old:
            if entry == old[entry.name][0]:
                continue
            _, (start, end) = old[entry.name]
            edits.append((start, end, definition(entry)))
        else:
            new_entries.append(entry)
    if new_entries:
        end = max(span[1] for _, span in old.values())
        block = "".join(f"\r\n\r\n;;; Command: {e.name}\r\n;;; Function: {description(e)}\r\n{definition(e)}"
                        for e in new_entries)
        edits.append((end, end, block))
    # 插入点与最后一个旧定义结尾相同，先插入再替换，原有位置保持有效。
    for start, end, value in sorted(edits, key=lambda x: (x[0], x[1]), reverse=True):
        text = text[:start] + value + text[end:]
    for entry in entries:
        if entry.name in old and entry == old[entry.name][0]:
            continue
        pattern = rf"(;;; Command: {re.escape(entry.name)}\r\n);;; Function: [^\r\n]*"
        text = re.sub(pattern, lambda m: m[1] + ";;; Function: " + description(entry), text)
        header = rf"^;;;\s*-\s*{re.escape(entry.name)}\s*:[^\r\n]*"
        line = f";;;   - {entry.name:<6}: {description(entry)}"
        if re.search(header, text, re.M):
            text = re.sub(header, lambda m: line, text, flags=re.M)
        else:
            # 放到本系列原有清单后，不能把注释插入函数体。
            matches = list(re.finditer(r"^;;;\s*-\s*(?:" + "|".join(map(re.escape, old)) + r")\s*:[^\r\n]*\r\n", text, re.M))
            if not matches:
                raise ValueError("找不到屏柜系列命令清单，停止修改。")
            pos = matches[-1].end()
            text = text[:pos] + line + "\r\n" + text[pos:]
    if discover(text) != list(entries):
        raise ValueError("生成后的命令结构与设置不一致。")
    return text


@contextmanager
def exclusive_lock():
    lock = ROOT / ".cabinet-panel.tmp"
    try:
        handle = lock.open("x", encoding="utf-8")
    except FileExistsError:
        raise ValueError("已有面板正在保存，或上次异常退出留下 .cabinet-panel.tmp；请确认后重试。")
    try:
        yield
    finally:
        handle.close()
        lock.unlink(missing_ok=True)


def save(entries, expected):
    """备份、原子写入、完整检查；失败时恢复本次修改的文件。"""
    with exclusive_lock():
        current = read_source(SOURCE)
        if current != expected:
            raise ValueError("整合文件已被其他程序修改。请关闭并重新打开面板后再编辑。")
        updated = render(current, entries)
        if updated == current:
            return current, "设置未改变，无需保存。"
        paths = [SOURCE, ROOT / "命令索引.md", ROOT / "命令索引.html",
                 ROOT / "COMMANDS.md", ROOT / "PROJECT_AUDIT.md", ROOT / "docs/lsp-audit.json"]
        before = {p: p.read_bytes() if p.exists() else None for p in paths}
        folder = ROOT / "backups" / ("cabinet-panel-" + datetime.now().strftime("%Y%m%d-%H%M%S-%f"))
        folder.mkdir(parents=True)
        for p, raw in before.items():
            if raw is not None:
                (folder / p.name).write_bytes(raw)
        temporary = SOURCE.with_suffix(".lsp.tmp")
        try:
            temporary.write_bytes(updated.encode("utf-8"))
            read_source(temporary)
            os.replace(temporary, SOURCE)
            output = []
            for args in (["gen_命令索引.py"], ["scripts/audit_lsp.py", "--write"], ["scripts/check_project.py"]):
                proc = subprocess.run([sys.executable, *args], cwd=ROOT,
                                      capture_output=True, encoding="utf-8", errors="replace",
                                      env=dict(os.environ, PYTHONIOENCODING="utf-8"),
                                      creationflags=getattr(subprocess, "CREATE_NO_WINDOW", 0), timeout=180)
                output.append(proc.stdout + proc.stderr)
                if proc.returncode:
                    raise ValueError("静态检查失败：\n" + output[-1][-4000:])
            (folder / "checks.log").write_text("\n".join(output), encoding="utf-8")
        except Exception:
            for p, raw in before.items():
                if raw is None:
                    p.unlink(missing_ok=True)
                else:
                    p.write_bytes(raw)
            raise
        finally:
            temporary.unlink(missing_ok=True)
        return updated, f"已保存并通过静态检查。请自行重新加载 AA整合版本.lsp。备份：{folder}"


class Panel:
    BG_MAIN = "#F1F5F9"
    BG_CARD = "#FFFFFF"
    BG_SUBTLE = "#F8FAFC"
    BORDER = "#E2E8F0"
    BORDER_INPUT = "#CBD5E1"
    PRIMARY = "#2563EB"
    PRIMARY_HOVER = "#1D4ED8"
    PRIMARY_LIGHT = "#EFF6FF"
    TEXT_DARK = "#0F172A"
    TEXT_BODY = "#334155"
    TEXT_MUTED = "#64748B"

    def __init__(self, root):
        self.root = root
        self.original = read_source(SOURCE)
        self.entries = discover(self.original)
        self.selected = None
        self.loading = False
        self.busy = False
        self.dark_preview = True
        self.events = queue.Queue()

        root.title("屏柜命令设置 · ZW-auto_lisp")
        width, height = 1060, 730
        screen_w, screen_h = root.winfo_screenwidth(), root.winfo_screenheight()
        pos_x = max(20, (screen_w - width) // 2)
        pos_y = max(20, (screen_h - height) // 2 - 20)
        root.geometry(f"{width}x{height}+{pos_x}+{pos_y}")
        root.minsize(940, 670)
        root.configure(bg=self.BG_MAIN)

        self._setup_styles()

        # ── 1. 顶部标题栏卡片（先 pack top） ──
        header = tk.Frame(root, bg=self.BG_CARD, highlightthickness=1, highlightbackground=self.BORDER)
        header.pack(side="top", fill="x", padx=20, pady=(16, 12))
        header_inner = tk.Frame(header, bg=self.BG_CARD, padx=18, pady=13)
        header_inner.pack(fill="x")

        title_left = tk.Frame(header_inner, bg=self.BG_CARD)
        title_left.pack(side="left", fill="y")
        title_row = tk.Frame(title_left, bg=self.BG_CARD)
        title_row.pack(anchor="w")
        tk.Frame(title_row, bg=self.PRIMARY, width=4, height=22).pack(side="left", padx=(0, 10), pady=2)
        tk.Label(title_row, text="屏柜命令设置", font=("Microsoft YaHei UI", 16, "bold"),
                 bg=self.BG_CARD, fg=self.TEXT_DARK).pack(side="left")
        tk.Label(title_row, text="CAD 离线配置", font=("Microsoft YaHei UI", 9, "bold"),
                 bg=self.PRIMARY_LIGHT, fg=self.PRIMARY_HOVER, padx=8, pady=2).pack(side="left", padx=(10, 0))
        tk.Label(title_left, text="修改文字和方向  →  点击保存全部设置  →  在 CAD 中自行重新加载生效",
                 font=("Microsoft YaHei UI", 9), bg=self.BG_CARD, fg=self.TEXT_MUTED).pack(anchor="w", pady=(5, 0))

        file_box = tk.Frame(header_inner, bg=self.BG_SUBTLE, highlightthickness=1,
                            highlightbackground=self.BORDER, padx=12, pady=7)
        file_box.pack(side="right", anchor="center")
        file_top = tk.Frame(file_box, bg=self.BG_SUBTLE)
        file_top.pack(fill="x")
        tk.Label(file_top, text="当前目标文件", font=("Microsoft YaHei UI", 8, "bold"),
                 bg=self.BG_SUBTLE, fg=self.TEXT_MUTED).pack(side="left")
        self.copy_path_btn = tk.Label(file_top, text="复制路径", font=("Microsoft YaHei UI", 8),
                                      bg=self.BG_SUBTLE, fg=self.PRIMARY, cursor="hand2")
        self.copy_path_btn.pack(side="right", padx=(12, 0))
        self.copy_path_btn.bind("<Button-1>", self._copy_source_path)
        tk.Label(file_box, text=str(SOURCE), font=("Consolas", 9),
                 bg=self.BG_SUBTLE, fg=self.TEXT_BODY).pack(anchor="w", pady=(2, 0))

        # ── 2. 底部状态与操作栏（先于 body pack bottom，确保永不裁切） ──
        footer = tk.Frame(root, bg=self.BG_CARD, highlightthickness=1, highlightbackground=self.BORDER)
        footer.pack(side="bottom", fill="x", padx=20, pady=(0, 16))
        footer_inner = tk.Frame(footer, bg=self.BG_CARD, padx=16, pady=10)
        footer_inner.pack(fill="x")

        status_frame = tk.Frame(footer_inner, bg=self.BG_CARD)
        status_frame.pack(side="left", fill="x", expand=True)
        self.status_badge = tk.Label(status_frame, text="● 已同步", font=("Microsoft YaHei UI", 9, "bold"),
                                     bg="#ECFDF5", fg="#059669", padx=8, pady=3)
        self.status_badge.pack(side="left", padx=(0, 10))
        self.status = tk.StringVar(value="尚未修改。保存前会自动备份并检查，失败会恢复原文件。")
        tk.Label(status_frame, textvariable=self.status, font=("Microsoft YaHei UI", 9),
                 bg=self.BG_CARD, fg=self.TEXT_BODY, wraplength=620, justify="left").pack(side="left", fill="x")

        btn_group = tk.Frame(footer_inner, bg=self.BG_CARD)
        btn_group.pack(side="right")
        self.discard_button = ttk.Button(btn_group, text="还原全部修改", style="Secondary.TButton",
                                         command=self.discard_all, cursor="hand2")
        self.discard_button.pack(side="left", padx=(0, 10))
        self.save_button = ttk.Button(btn_group, text="保存全部设置", style="Primary.TButton",
                                      command=self.save, cursor="hand2")
        self.save_button.pack(side="left")

        # ── 3. 主体双栏区域（最后 pack expand=True） ──
        body = tk.Frame(root, bg=self.BG_MAIN)
        body.pack(side="top", fill="both", expand=True, padx=20, pady=(0, 12))

        # 左侧：命令列表卡片
        left_card = tk.Frame(body, bg=self.BG_CARD, width=255, highlightthickness=1, highlightbackground=self.BORDER)
        left_card.pack(side="left", fill="y", padx=(0, 14))
        left_card.pack_propagate(False)

        left_header = tk.Frame(left_card, bg=self.BG_CARD, padx=14, pady=11)
        left_header.pack(fill="x")
        tk.Label(left_header, text="命令列表", font=("Microsoft YaHei UI", 10, "bold"),
                 bg=self.BG_CARD, fg=self.TEXT_DARK).pack(side="left")
        self.count_label = tk.Label(left_header, text="0 项", font=("Microsoft YaHei UI", 8, "bold"),
                                    bg=self.BG_MAIN, fg=self.TEXT_MUTED, padx=7, pady=2)
        self.count_label.pack(side="right")
        tk.Frame(left_card, bg=self.BORDER, height=1).pack(fill="x")

        tree_wrap = tk.Frame(left_card, bg=self.BG_CARD, padx=8, pady=6)
        tree_wrap.pack(fill="both", expand=True)
        self.tree = ttk.Treeview(tree_wrap, columns=("side",), show="tree headings", height=8, selectmode="browse")
        self.tree.heading("#0", text="  命令名", anchor="w")
        self.tree.heading("side", text="方向", anchor="center")
        self.tree.column("#0", width=135, minwidth=100, anchor="w")
        self.tree.column("side", width=72, minwidth=55, anchor="center")
        tree_scroll = ttk.Scrollbar(tree_wrap, orient="vertical", command=self.tree.yview, style="Modern.Vertical.TScrollbar")
        self.tree.configure(yscrollcommand=tree_scroll.set)
        self.tree.pack(side="left", fill="both", expand=True)
        tree_scroll.pack(side="right", fill="y", padx=(4, 0))
        self.tree.bind("<<TreeviewSelect>>", self.select)

        tk.Frame(left_card, bg=self.BORDER, height=1).pack(fill="x")
        left_footer = tk.Frame(left_card, bg=self.BG_CARD, padx=12, pady=10)
        left_footer.pack(fill="x")
        self.add_button = ttk.Button(left_footer, text="＋ 复制为新命令…", style="AccentOutline.TButton",
                                     command=self.add, cursor="hand2")
        self.add_button.pack(fill="x")

        # 右侧：参数编辑卡片 + 实时预览卡片
        right = tk.Frame(body, bg=self.BG_MAIN)
        right.pack(side="left", fill="both", expand=True)

        # 右上：参数配置卡片
        form_card = tk.Frame(right, bg=self.BG_CARD, highlightthickness=1, highlightbackground=self.BORDER)
        form_card.pack(side="top", fill="x", pady=(0, 12))

        form_header = tk.Frame(form_card, bg=self.BG_CARD, padx=18, pady=11)
        form_header.pack(fill="x")
        tk.Label(form_header, text="参数配置", font=("Microsoft YaHei UI", 10, "bold"),
                 bg=self.BG_CARD, fg=self.TEXT_DARK).pack(side="left")
        self.active_badge = tk.Label(form_header, text="", font=("Consolas", 9, "bold"),
                                     bg=self.PRIMARY_LIGHT, fg=self.PRIMARY_HOVER, padx=8, pady=2)
        self.active_badge.pack(side="left", padx=(10, 0))
        self.reset_item_btn = ttk.Button(form_header, text="还原当前项", style="Subtle.TButton",
                                         command=self.reset_current, cursor="hand2")
        self.reset_item_btn.pack(side="right")
        tk.Frame(form_card, bg=self.BORDER, height=1).pack(fill="x")

        form_body = tk.Frame(form_card, bg=self.BG_CARD, padx=18, pady=12)
        form_body.pack(fill="x")

        self.vars = {key: tk.StringVar() for key in ("name", "side", "upper", "lower", "cabinet")}
        self.inputs = []

        # 第 0 行：命令名 + 生成方向 并排显示
        tk.Label(form_body, text="命令名", font=("Microsoft YaHei UI", 9, "bold"),
                 bg=self.BG_CARD, fg=self.TEXT_BODY).grid(row=0, column=0, sticky="w", pady=6, padx=(0, 12))
        name_entry = ttk.Entry(form_body, textvariable=self.vars["name"],
                               font=("Consolas", 11, "bold"), state="readonly", width=16)
        name_entry.grid(row=0, column=1, sticky="ew", pady=6, padx=(0, 24))
        self.inputs.append(name_entry)

        tk.Label(form_body, text="生成方向", font=("Microsoft YaHei UI", 9, "bold"),
                 bg=self.BG_CARD, fg=self.TEXT_BODY).grid(row=0, column=2, sticky="w", pady=6, padx=(0, 12))
        side_box = ttk.Combobox(form_body, textvariable=self.vars["side"],
                                values=("向左", "向右"), state="readonly", font=("Microsoft YaHei UI", 10), width=12)
        side_box.grid(row=0, column=3, sticky="ew", pady=6)
        self.inputs.append(side_box)

        # 第 1~3 行：上方标注、下方标注、柜内文字
        field_Hints = (
            ("upper", "上方标注", "上引出线居中文字（如 +KM、L、+UPS）"),
            ("lower", "下方标注", "下引出线居中文字（如 -KM、N、-UPS）"),
            ("cabinet", "柜内文字", "屏柜矩形框内部居中文字（如 直流馈线柜）"),
        )
        self.field_labels = {}
        for row_idx, (key, label, hint) in enumerate(field_Hints, start=1):
            self.field_labels[key] = tk.Label(form_body, text=label, font=("Microsoft YaHei UI", 9, "bold"),
                                             bg=self.BG_CARD, fg=self.TEXT_BODY)
            self.field_labels[key].grid(row=row_idx, column=0, sticky="w", pady=6, padx=(0, 12))
            entry_widget = ttk.Entry(form_body, textvariable=self.vars[key], font=("Microsoft YaHei UI", 10))
            entry_widget.grid(row=row_idx, column=1, columnspan=3, sticky="ew", pady=6)
            self.inputs.append(entry_widget)

        for key in ("name", "side", "upper", "lower", "cabinet"):
            self.vars[key].trace_add("write", self.change)

        form_body.columnconfigure(1, weight=1)
        form_body.columnconfigure(3, weight=1)

        # 右下：实时示意预览卡片
        preview_card = tk.Frame(right, bg=self.BG_CARD, highlightthickness=1, highlightbackground=self.BORDER)
        preview_card.pack(side="top", fill="both", expand=True)

        preview_header = tk.Frame(preview_card, bg=self.BG_CARD, padx=18, pady=10)
        preview_header.pack(fill="x")
        tk.Label(preview_header, text="实时示意预览", font=("Microsoft YaHei UI", 10, "bold"),
                 bg=self.BG_CARD, fg=self.TEXT_DARK).pack(side="left")
        tk.Label(preview_header, text="尺寸以 CAD 实际绘制为准 · 青色虚线样式",
                 font=("Microsoft YaHei UI", 9), bg=self.BG_CARD, fg=self.TEXT_MUTED).pack(side="left", padx=(10, 0))
        self.theme_btn = ttk.Button(preview_header, text="切换浅色背景", style="Subtle.TButton",
                                    command=self.toggle_preview_theme, cursor="hand2")
        self.theme_btn.pack(side="right")
        tk.Frame(preview_card, bg=self.BORDER, height=1).pack(fill="x")

        canvas_wrap = tk.Frame(preview_card, bg=self.BG_CARD, padx=14, pady=12)
        canvas_wrap.pack(fill="both", expand=True)
        self.canvas = tk.Canvas(canvas_wrap, bg="#0D1520", height=150,
                                highlightthickness=1, highlightbackground="#1E293B")
        self.canvas.pack(fill="both", expand=True)
        self.canvas.bind("<Configure>", lambda event: self.preview())

        self.refresh()
        self._update_dirty_ui()
        root.protocol("WM_DELETE_WINDOW", self.close)

    def _setup_styles(self):
        style = ttk.Style()
        style.theme_use("clam")
        self.root.option_add("*TCombobox*Listbox.font", ("Microsoft YaHei UI", 10))
        self.root.option_add("*TCombobox*Listbox.background", "#FFFFFF")
        self.root.option_add("*TCombobox*Listbox.foreground", self.TEXT_DARK)
        self.root.option_add("*TCombobox*Listbox.selectBackground", self.PRIMARY)
        self.root.option_add("*TCombobox*Listbox.selectForeground", "#FFFFFF")

        style.configure("TLabel", font=("Microsoft YaHei UI", 10), background=self.BG_CARD, foreground=self.TEXT_DARK)
        style.configure("Treeview",
                        background=self.BG_CARD,
                        fieldbackground=self.BG_CARD,
                        foreground=self.TEXT_DARK,
                        bordercolor=self.BORDER,
                        lightcolor=self.BORDER,
                        darkcolor=self.BORDER,
                        rowheight=34,
                        borderwidth=1,
                        relief="solid",
                        font=("Microsoft YaHei UI", 10))
        style.map("Treeview",
                  background=[("selected", self.PRIMARY)],
                  foreground=[("selected", "#FFFFFF")])
        style.configure("Treeview.Heading",
                        background=self.BG_SUBTLE,
                        foreground="#475569",
                        bordercolor=self.BORDER,
                        lightcolor=self.BG_SUBTLE,
                        darkcolor=self.BORDER,
                        font=("Microsoft YaHei UI", 9, "bold"),
                        borderwidth=1,
                        relief="flat",
                        padding=(6, 7))
        style.map("Treeview.Heading",
                  background=[("active", "#E2E8F0")])

        style.layout("Modern.Vertical.TScrollbar", [
            ("Vertical.Scrollbar.trough", {
                "children": [("Vertical.Scrollbar.thumb", {"expand": "1", "sticky": "nswe"})],
                "sticky": "ns",
            })
        ])
        style.configure("Modern.Vertical.TScrollbar",
                        troughcolor=self.BG_SUBTLE,
                        background="#CBD5E1",
                        bordercolor=self.BG_SUBTLE,
                        lightcolor="#CBD5E1",
                        darkcolor="#CBD5E1",
                        gripcount=0,
                        width=8)
        style.map("Modern.Vertical.TScrollbar",
                  background=[("active", "#94A3B8"), ("pressed", "#64748B")])

        style.configure("TEntry",
                        fieldbackground="#FFFFFF",
                        readonlybackground=self.BG_SUBTLE,
                        foreground=self.TEXT_DARK,
                        bordercolor=self.BORDER_INPUT,
                        lightcolor="#FFFFFF",
                        darkcolor=self.BORDER_INPUT,
                        insertcolor=self.TEXT_DARK,
                        padding=(10, 6))
        style.map("TEntry",
                  bordercolor=[("focus", self.PRIMARY)],
                  lightcolor=[("focus", self.PRIMARY)],
                  darkcolor=[("focus", self.PRIMARY)])

        style.configure("TCombobox",
                        fieldbackground="#FFFFFF",
                        readonlybackground="#FFFFFF",
                        background=self.BG_SUBTLE,
                        foreground=self.TEXT_DARK,
                        bordercolor=self.BORDER_INPUT,
                        lightcolor=self.BG_SUBTLE,
                        darkcolor=self.BORDER_INPUT,
                        arrowcolor="#475569",
                        arrowsize=13,
                        padding=(10, 5))
        style.map("TCombobox",
                  fieldbackground=[("readonly", "#FFFFFF")],
                  selectbackground=[("readonly", "#FFFFFF")],
                  selectforeground=[("readonly", self.TEXT_DARK)],
                  background=[("active", "#E2E8F0"), ("readonly", self.BG_SUBTLE)],
                  bordercolor=[("focus", self.PRIMARY)])

        style.configure("Primary.TButton",
                        font=("Microsoft YaHei UI", 10, "bold"),
                        background=self.PRIMARY,
                        foreground="#FFFFFF",
                        bordercolor=self.PRIMARY,
                        lightcolor=self.PRIMARY,
                        darkcolor=self.PRIMARY,
                        focuscolor=self.PRIMARY,
                        padding=(20, 8),
                        relief="flat")
        style.map("Primary.TButton",
                  background=[("active", self.PRIMARY_HOVER), ("disabled", "#94A3B8")],
                  foreground=[("disabled", "#F1F5F9")],
                  bordercolor=[("active", self.PRIMARY_HOVER), ("disabled", "#94A3B8")])

        style.configure("AccentOutline.TButton",
                        font=("Microsoft YaHei UI", 9, "bold"),
                        background=self.PRIMARY_LIGHT,
                        foreground=self.PRIMARY_HOVER,
                        bordercolor="#BFDBFE",
                        lightcolor=self.PRIMARY_LIGHT,
                        darkcolor="#BFDBFE",
                        focuscolor=self.PRIMARY_LIGHT,
                        padding=(14, 7),
                        relief="flat")
        style.map("AccentOutline.TButton",
                  background=[("active", "#DBEAFE"), ("disabled", "#F8FAFC")],
                  foreground=[("active", "#1E40AF"), ("disabled", "#94A3B8")],
                  bordercolor=[("active", "#93C5FD"), ("disabled", self.BORDER)])

        style.configure("Secondary.TButton",
                        font=("Microsoft YaHei UI", 9, "bold"),
                        background="#FFFFFF",
                        foreground=self.TEXT_BODY,
                        bordercolor=self.BORDER_INPUT,
                        lightcolor="#FFFFFF",
                        darkcolor=self.BORDER_INPUT,
                        focuscolor="#FFFFFF",
                        padding=(14, 7),
                        relief="flat")
        style.map("Secondary.TButton",
                  background=[("active", self.BG_SUBTLE), ("disabled", "#F8FAFC")],
                  foreground=[("active", self.PRIMARY), ("disabled", "#94A3B8")],
                  bordercolor=[("active", "#93C5FD"), ("disabled", self.BORDER)])

        style.configure("Subtle.TButton",
                        font=("Microsoft YaHei UI", 9),
                        background=self.BG_SUBTLE,
                        foreground="#475569",
                        bordercolor=self.BORDER,
                        lightcolor=self.BG_SUBTLE,
                        darkcolor=self.BORDER,
                        focuscolor=self.BG_SUBTLE,
                        padding=(10, 4),
                        relief="flat")
        style.map("Subtle.TButton",
                  background=[("active", self.PRIMARY_LIGHT), ("disabled", self.BG_SUBTLE)],
                  foreground=[("active", self.PRIMARY_HOVER), ("disabled", "#CBD5E1")])

    def _copy_source_path(self, event=None):
        self.root.clipboard_clear()
        self.root.clipboard_append(str(SOURCE))
        self.copy_path_btn.configure(text="✓ 已复制", fg="#059669")
        self.root.after(1500, lambda: self.copy_path_btn.configure(text="复制路径", fg=self.PRIMARY))

    def toggle_preview_theme(self):
        self.dark_preview = not self.dark_preview
        if self.dark_preview:
            self.canvas.configure(bg="#0D1520", highlightbackground="#1E293B")
            self.theme_btn.configure(text="切换浅色背景")
        else:
            self.canvas.configure(bg="#FFFFFF", highlightbackground="#CBD5E1")
            self.theme_btn.configure(text="切换深色视口")
        self.preview()

    def _update_dirty_ui(self):
        if self.busy:
            self.status_badge.configure(text="● 保存检查中", bg="#EFF6FF", fg=self.PRIMARY)
            self.discard_button.configure(state="disabled")
            self.reset_item_btn.configure(state="disabled")
            return
        baseline = discover(self.original)
        dirty = self.entries != baseline
        if dirty:
            self.status_badge.configure(text="● 未保存修改", bg="#FEF3C7", fg="#D97706")
            self.discard_button.configure(state="normal")
        else:
            self.status_badge.configure(text="● 已同步", bg="#ECFDF5", fg="#059669")
            self.discard_button.configure(state="disabled")

        by_name = {e.name: e for e in baseline}
        if self.selected is not None and self.selected < len(self.entries):
            current = self.entries[self.selected]
            self.active_badge.configure(text=f"{current.name} · {'向左' if current.left else '向右'}")
            if current.name in by_name and current != by_name[current.name]:
                self.reset_item_btn.configure(state="normal")
            else:
                self.reset_item_btn.configure(state="disabled")

    def reset_current(self):
        if self.busy or self.selected is None:
            return
        by_name = {e.name: e for e in discover(self.original)}
        current = self.entries[self.selected]
        if current.name not in by_name:
            return
        self.entries[self.selected] = by_name[current.name]
        self.tree.item(str(self.selected), values=("← 左" if self.entries[self.selected].left else "右 →",))
        self.select()
        self._update_dirty_ui()
        self.status.set(f"已还原 {current.name} 的初始参数。")

    def discard_all(self):
        if self.busy:
            return
        baseline = discover(self.original)
        if self.entries == baseline:
            return
        if not messagebox.askyesno("还原全部修改", "确定放弃当前所有未保存的修改（包含未保存的新命令）吗？", parent=self.root):
            return
        self.entries = baseline
        self.selected = min(self.selected or 0, len(self.entries) - 1)
        self.refresh()
        self._update_dirty_ui()
        self.status.set("已放弃所有未保存修改，恢复至当前文件状态。")

    def refresh(self):
        for item in self.tree.get_children():
            self.tree.delete(item)
        for i, entry in enumerate(self.entries):
            self.tree.insert("", "end", iid=str(i), text=f"  {entry.name}",
                             values=("← 左" if entry.left else "右 →",))
        self.count_label.configure(text=f"共 {len(self.entries)} 项")
        idx = self.selected if self.selected is not None else 0
        self.tree.selection_set(str(idx))
        self.tree.see(str(idx))
        self.select()

    def select(self, event=None):
        selection = self.tree.selection()
        if not selection:
            return
        self.selected = int(selection[0])
        entry = self.entries[self.selected]
        self.loading = True
        numbered = entry.handler == "aa:yd-cmd"
        self.field_labels["upper"].configure(text="首个编号" if numbered else "上方标注")
        self.field_labels["lower"].configure(text="后续编号前缀" if numbered else "下方标注")
        self.field_labels["cabinet"].configure(text="手动默认柜名" if entry.handler == "aa:zj-cmd" else "柜内文字")
        for key, value in (("name", entry.name), ("side", "向左" if entry.left else "向右"),
                           ("upper", entry.upper), ("lower", entry.lower), ("cabinet", entry.cabinet)):
            self.vars[key].set(value)
        self.loading = False
        self._update_dirty_ui()
        self.preview()

    def change(self, *args):
        if self.loading or self.selected is None:
            return
        self.entries[self.selected] = replace(
            self.entries[self.selected], name=self.vars["name"].get(),
            left=self.vars["side"].get() == "向左",
            **{k: self.vars[k].get() for k in ("upper", "lower", "cabinet")})
        self.tree.item(str(self.selected), values=("← 左" if self.entries[self.selected].left else "右 →",))
        self.status.set("有未保存的设置。右侧预览已实时更新，点击“保存全部设置”写入文件。")
        self._update_dirty_ui()
        self.preview()

    def preview(self):
        if self.selected is None:
            return
        canvas = self.canvas
        canvas.delete("all")
        width, height = max(canvas.winfo_width(), 450), max(canvas.winfo_height(), 155)
        entry = self.entries[self.selected]
        middle = height / 2

        grid_color = "#162234" if self.dark_preview else "#F1F5F9"
        color = "#00E5FF" if self.dark_preview else "#007F8C"
        box_fill = "#112233" if self.dark_preview else "#F0FDFA"
        ref_color = "#475569" if self.dark_preview else "#94A3B8"
        hud_fg = "#94A3B8" if self.dark_preview else "#64748B"

        # 绘制 CAD 风格网格背景
        step = 26
        for gx in range(step, int(width), step):
            canvas.create_line(gx, 0, gx, height, fill=grid_color)
        for gy in range(step, int(height), step):
            canvas.create_line(0, gy, width, gy, fill=grid_color)

        box_width = min(max(130, len(entry.cabinet) * 15 + 34), width * 0.58)
        x1 = 28 if entry.left else width - box_width - 28
        x2 = x1 + box_width
        joint, tail = (x2, width - 34) if entry.left else (x1, 34)

        # 绘制屏柜矩形与文字
        canvas.create_rectangle(x1, middle - 48, x2, middle + 48,
                                fill=box_fill, outline=color, dash=(6, 4), width=2)
        cabinet_preview = "剪贴板文字（运行时读取）" if entry.handler == "aa:zj-cmd" else entry.cabinet
        canvas.create_text((x1 + x2) / 2, middle, text=cabinet_preview,
                           font=("Microsoft YaHei UI", 11, "bold"), fill=color, width=box_width - 16)

        # 绘制上下引出线、端子节点与标注
        labels = ((-26, entry.upper), (26, entry.lower))
        if entry.handler == "aa:yd-cmd":
            labels = ((-30, entry.upper), (0, entry.lower + "01"), (30, entry.lower + "03"))
        for offset, text in labels:
            y = middle + offset
            canvas.create_line(joint, y, tail, y, fill=color, dash=(6, 4), width=2)
            canvas.create_oval(joint - 3, y - 3, joint + 3, y + 3, fill=color, outline=color)
            canvas.create_oval(tail - 2.5, y - 2.5, tail + 2.5, y + 2.5, fill=ref_color, outline=ref_color)
            canvas.create_text((joint + tail) / 2, y - 13, text=text,
                               fill=color, font=("Microsoft YaHei UI", 10, "bold"))

        # 右下角/左上角方向指示
        dir_text = f"命令 {entry.name}  ·  {'← 向左生成' if entry.left else '向右生成 →'}"
        canvas.create_text(width - 14, height - 10, text=dir_text, anchor="se",
                           fill=hud_fg, font=("Microsoft YaHei UI", 8))

    def _ask_new_command_dialog(self, base_name):
        dialog = tk.Toplevel(self.root)
        dialog.title("复制为新命令")
        dialog.configure(bg=self.BG_CARD)
        dialog.resizable(False, False)
        dialog.transient(self.root)
        dialog.grab_set()

        dw, dh = 400, 215
        rx, ry = self.root.winfo_rootx(), self.root.winfo_rooty()
        rw, rh = self.root.winfo_width(), self.root.winfo_height()
        dialog.geometry(f"{dw}x{dh}+{rx + (rw - dw) // 2}+{ry + (rh - dh) // 2}")

        body = tk.Frame(dialog, bg=self.BG_CARD, padx=22, pady=18)
        body.pack(fill="both", expand=True)
        tk.Label(body, text=f"基于【{base_name}】复制为新命令",
                 font=("Microsoft YaHei UI", 11, "bold"), bg=self.BG_CARD, fg=self.TEXT_DARK).pack(anchor="w")
        tk.Label(body, text="请输入新命令名（如 DYZ、485Z），以字母或数字开头且至少含一个英文字母：",
                 font=("Microsoft YaHei UI", 9), bg=self.BG_CARD, fg=self.TEXT_MUTED,
                 wraplength=355, justify="left").pack(anchor="w", pady=(6, 10))

        var = tk.StringVar()
        entry = ttk.Entry(body, textvariable=var, font=("Consolas", 11))
        entry.pack(fill="x", pady=(0, 14))
        entry.focus_set()

        result = [None]

        def confirm(event=None):
            result[0] = var.get()
            dialog.destroy()

        def cancel(event=None):
            dialog.destroy()

        btn_row = tk.Frame(body, bg=self.BG_CARD)
        btn_row.pack(fill="x")
        ttk.Button(btn_row, text="确定添加", style="Primary.TButton",
                   command=confirm, cursor="hand2").pack(side="right")
        ttk.Button(btn_row, text="取消", style="Secondary.TButton",
                   command=cancel, cursor="hand2").pack(side="right", padx=(0, 8))

        dialog.bind("<Return>", confirm)
        dialog.bind("<Escape>", cancel)
        self.root.wait_window(dialog)
        return result[0]

    def add(self):
        if self.busy:
            return
        base_entry = self.entries[self.selected] if self.selected is not None else self.entries[0]
        name = self._ask_new_command_dialog(base_entry.name)
        if not name:
            return
        entry = replace(base_entry, name=name.strip().upper())
        try:
            render(self.original, [*self.entries, entry])
        except Exception as error:
            messagebox.showerror("无法增加", str(error), parent=self.root)
            return
        self.entries.append(entry)
        self.selected = len(self.entries) - 1
        self.refresh()
        self._update_dirty_ui()
        self.status.set("新命令已加入草稿，可继续修改文字；保存后再自行重新加载。")

    def save(self):
        if self.busy:
            return
        try:
            render(self.original, self.entries)
        except Exception as error:
            messagebox.showerror("设置无效", str(error), parent=self.root)
            return
        self.busy = True
        self.save_button.configure(state="disabled")
        self.add_button.configure(state="disabled")
        for widget in self.inputs:
            widget.configure(state="disabled")
        self._update_dirty_ui()
        self.status.set("正在备份、保存并运行静态检查，请稍候…")
        entries, original = list(self.entries), self.original

        def worker():
            try:
                result = save(entries, original)
                self.events.put((True, result))
            except Exception as error:
                self.events.put((False, str(error)))

        threading.Thread(target=worker, daemon=True).start()
        self.root.after(100, self.poll)

    def poll(self):
        try:
            ok, result = self.events.get_nowait()
        except queue.Empty:
            self.root.after(100, self.poll)
            return
        self.busy = False
        self.save_button.configure(state="normal")
        self.add_button.configure(state="normal")
        for i, widget in enumerate(self.inputs):
            widget.configure(state="readonly" if i in (0, 1) else "normal")
        if ok:
            self.original, message = result
            self.status.set(message)
        else:
            self.status.set("保存未完成，请查看错误信息。")
            messagebox.showerror("保存失败", result, parent=self.root)
        self._update_dirty_ui()

    def close(self):
        if self.busy:
            messagebox.showinfo("正在保存", "请等待检查结束再关闭。", parent=self.root)
            return
        if self.entries != discover(self.original) and not messagebox.askyesno("未保存的修改", "放弃未保存的修改并关闭？", parent=self.root):
            return
        self.root.destroy()


def main():
    root = tk.Tk()
    try:
        Panel(root)
        root.mainloop()
    except Exception as error:
        root.withdraw()
        messagebox.showerror("无法打开屏柜设置", str(error), parent=root)
        root.destroy()
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
