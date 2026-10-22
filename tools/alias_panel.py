# -*- coding: utf-8 -*-
"""命令别名设置面板；只编辑项目主表与本机 PGP，不连接 CAD。

主表：config/aliases.csv（UTF-8 带 BOM、CRLF，随同步目录走）。
PGP：本机 %AppData% 下的 ZWCAD.pgp，面板只重写末尾托管区块。
"""
from __future__ import annotations

import os
import queue
import sys
import threading
import tkinter as tk
from contextlib import contextmanager
from dataclasses import replace
from pathlib import Path
from tkinter import filedialog, messagebox, ttk

sys.path.insert(0, str(Path(__file__).resolve().parent))
sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

import alias_pgp
from alias_pgp import AliasEntry, AliasError, FLAG_NATIVE, MASTER

ROOT = Path(__file__).resolve().parents[1]
LOCK_FILE = ROOT / ".alias-panel.tmp"


@contextmanager
def exclusive_lock():
    try:
        handle = LOCK_FILE.open("x", encoding="utf-8")
    except FileExistsError:
        raise AliasError("已有面板正在保存，或上次异常退出留下 .alias-panel.tmp；请确认后重试。")
    try:
        yield
    finally:
        handle.close()
        LOCK_FILE.unlink(missing_ok=True)


_INDEX_MODULE = None


def load_index_module():
    """加载项目根目录的 gen_命令索引.py（中文文件名），返回模块。"""
    global _INDEX_MODULE
    if _INDEX_MODULE is None:
        import importlib.util
        path = ROOT / "gen_命令索引.py"
        spec = importlib.util.spec_from_file_location("zw_cmd_index", path)
        if spec is None or spec.loader is None:
            raise AliasError(f"无法加载命令索引脚本：{path}")
        module = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(module)
        _INDEX_MODULE = module
    return _INDEX_MODULE


def scan_plugin_commands():
    """复用 gen_命令索引.py 的扫描逻辑，保证面板与命令索引完全一致。

    返回 (commands, skipped_files)。skipped_files 列出无法按 UTF-8 解码被跳过的文件。
    """
    module = load_index_module()
    _, rows, skipped = module.scan_with_skipped()
    commands = {}
    for name, file, line, desc in rows:
        commands.setdefault(name, {"file": file, "line": line, "desc": desc})
    return commands, skipped


def load_state():
    """读取主表与本机 PGP，返回面板初始状态。"""
    pgp_path = alias_pgp.resolve_pgp_path()
    pgp_doc = None
    if pgp_path and Path(pgp_path).exists():
        pgp_doc = alias_pgp.read_pgp(pgp_path)
    master_exists = MASTER.exists()
    master = alias_pgp.read_master()
    plugin_commands, skipped_files = scan_plugin_commands()
    imported, uncertain, import_note = [], [], ""
    if not master_exists and pgp_doc is not None:
        imported, uncertain = alias_pgp.discover_user_aliases(pgp_doc, set(plugin_commands))
        if imported:
            master = imported
            import_note = f"首次运行：已从本机 PGP 导入 {len(imported)} 条自定义别名。"
            if uncertain:
                import_note += " 以下被注释的行保持原样：" + "、".join(f"{a}→{t}" for a, t in uncertain)
    known_targets = set()
    if pgp_doc is not None:
        for line in pgp_doc.lines:
            if line.target:
                known_targets.add(line.target.upper())
    history_commands = alias_pgp.history_plugin_commands()
    return {
        "pgp_path": pgp_path,
        "pgp_doc": pgp_doc,
        "master": master,
        "master_exists": master_exists,
        "plugin_commands": plugin_commands,
        "skipped_files": skipped_files,
        "known_targets": known_targets,
        "history_commands": history_commands,
        "import_note": import_note,
    }


def master_dirty(current, baseline):
    return list(current) != list(baseline)


def pgp_in_sync(entries, pgp_doc):
    """主表与本机 PGP 托管区块是否一致。"""
    if pgp_doc is None or pgp_doc.managed_start is None:
        return False
    block = [l for l in pgp_doc.lines[pgp_doc.managed_start + 1:pgp_doc.managed_end] if l.alias]
    expected = sorted((alias_pgp.normalize_alias(e.alias), e.target.upper()) for e in entries)
    got = sorted((l.alias.upper(), l.target.upper()) for l in block)
    return expected == got


class Panel:
    BG_MAIN = "#F1F3F6"
    BG_CARD = "#FFFFFF"
    BG_SUBTLE = "#F7F8FA"
    BORDER = "#E4E6EB"
    SEPARATOR = "#ECEEF1"
    PRIMARY = "#3B82F6"
    PRIMARY_HOVER = "#2563EB"
    PRIMARY_LIGHT = "#EFF6FF"
    DANGER = "#D32F2F"
    TEXT_MAIN = "#1F2329"
    TEXT_MUTED = "#6B7280"
    ROW_HOVER = "#F1F3F6"
    WARN_BG = "#FFFBEB"
    WARN_FG = "#B45309"
    OK_BG = "#ECFDF5"
    OK_FG = "#059669"
    DIFF_BG = "#FEF3C7"

    def __init__(self, root):
        self.root = root
        self.events = queue.Queue()
        self.busy = False
        self.selected = None
        self._loading = False

        try:
            state = load_state()
        except AliasError as error:
            raise AliasError(f"初始化失败：{error}")

        self.pgp_path = state["pgp_path"]
        self.pgp_doc = state["pgp_doc"]
        self.entries = list(state["master"])
        self.baseline = list(state["master"])
        self.plugin_commands = state["plugin_commands"]
        self.known_targets = state["known_targets"]
        self.history_commands = state["history_commands"]
        self.skipped_files = state["skipped_files"]
        self.import_note = state["import_note"]
        self.master_existed = state["master_exists"]
        self.pgp_raw_snapshot = None
        if self.pgp_path and Path(self.pgp_path).exists():
            self.pgp_raw_snapshot = Path(self.pgp_path).read_bytes()

        root.title("命令别名设置 · ZW-auto_lisp")
        width, height = 1200, 760
        screen_w, screen_h = root.winfo_screenwidth(), root.winfo_screenheight()
        pos_x = max(20, (screen_w - width) // 2)
        pos_y = max(20, (screen_h - height) // 2 - 20)
        root.geometry(f"{width}x{height}+{pos_x}+{pos_y}")
        root.minsize(980, 640)
        root.configure(bg=self.BG_MAIN)

        self._setup_styles()
        self._build_ui()
        self.refresh_list()
        self._update_dirty_ui()
        init_notes = []
        if self.import_note:
            init_notes.append(self.import_note)
        if self.skipped_files:
            init_notes.append("扫描时跳过无法解码的文件：" + "、".join(self.skipped_files))
        if init_notes:
            self.status.set("　".join(init_notes))
        root.protocol("WM_DELETE_WINDOW", self.close)

    def _setup_styles(self):
        style = ttk.Style()
        style.theme_use("clam")
        font_family = "Microsoft YaHei UI"
        self.root.option_add("*TCombobox*Listbox.font", (font_family, 10))
        self.root.option_add("*TCombobox*Listbox.background", "#FFFFFF")
        self.root.option_add("*TCombobox*Listbox.foreground", self.TEXT_MAIN)
        self.root.option_add("*TCombobox*Listbox.selectBackground", self.PRIMARY)
        self.root.option_add("*TCombobox*Listbox.selectForeground", "#FFFFFF")

        style.configure("Treeview",
                        background=self.BG_CARD, fieldbackground=self.BG_CARD,
                        foreground=self.TEXT_MAIN, bordercolor=self.BORDER,
                        lightcolor=self.BORDER, darkcolor=self.BORDER,
                        rowheight=30, borderwidth=1, relief="solid",
                        font=(font_family, 10))
        style.map("Treeview",
                  background=[("selected", self.PRIMARY)],
                  foreground=[("selected", "#FFFFFF")])
        style.configure("Treeview.Heading",
                        background=self.BG_SUBTLE, foreground="#475569",
                        bordercolor=self.BORDER, font=(font_family, 9, "bold"),
                        borderwidth=1, relief="flat", padding=(6, 6))

        style.configure("TEntry",
                        fieldbackground="#FFFFFF", foreground=self.TEXT_MAIN,
                        bordercolor=self.BORDER, lightcolor="#FFFFFF",
                        darkcolor=self.BORDER, insertcolor=self.TEXT_MAIN,
                        padding=(8, 5))
        style.map("TEntry",
                  bordercolor=[("focus", self.PRIMARY)],
                  lightcolor=[("focus", self.PRIMARY)],
                  darkcolor=[("focus", self.PRIMARY)])

        style.configure("Primary.TButton",
                        font=(font_family, 10, "bold"),
                        background=self.PRIMARY, foreground="#FFFFFF",
                        bordercolor=self.PRIMARY, lightcolor=self.PRIMARY,
                        darkcolor=self.PRIMARY, padding=(18, 8), relief="flat")
        style.map("Primary.TButton",
                  background=[("active", self.PRIMARY_HOVER), ("disabled", "#94A3B8")],
                  foreground=[("disabled", "#F1F5F9")])

        style.configure("Secondary.TButton",
                        font=(font_family, 9, "bold"),
                        background="#FFFFFF", foreground=self.TEXT_MAIN,
                        bordercolor=self.BORDER, lightcolor="#FFFFFF",
                        darkcolor=self.BORDER, padding=(12, 6), relief="flat")
        style.map("Secondary.TButton",
                  background=[("active", self.ROW_HOVER)])

        style.configure("Subtle.TButton",
                        font=(font_family, 9),
                        background=self.BG_SUBTLE, foreground="#475569",
                        bordercolor=self.BORDER, lightcolor=self.BG_SUBTLE,
                        darkcolor=self.BORDER, padding=(10, 4), relief="flat")
        style.map("Subtle.TButton",
                  background=[("active", self.PRIMARY_LIGHT)],
                  foreground=[("active", self.PRIMARY_HOVER)])

    def _build_ui(self):
        # ── 顶部标题栏 ──
        header = tk.Frame(self.root, bg=self.BG_CARD, highlightthickness=1,
                          highlightbackground=self.BORDER)
        header.pack(side="top", fill="x", padx=20, pady=(16, 12))
        inner = tk.Frame(header, bg=self.BG_CARD, padx=18, pady=12)
        inner.pack(fill="x")

        left = tk.Frame(inner, bg=self.BG_CARD)
        left.pack(side="left", fill="y")
        row = tk.Frame(left, bg=self.BG_CARD)
        row.pack(anchor="w")
        tk.Frame(row, bg=self.PRIMARY, width=4, height=22).pack(side="left", padx=(0, 10), pady=2)
        tk.Label(row, text="命令别名设置", font=("Microsoft YaHei UI", 15, "bold"),
                 bg=self.BG_CARD, fg=self.TEXT_MAIN).pack(side="left")
        tk.Label(row, text="PGP 命令行别名", font=("Microsoft YaHei UI", 9, "bold"),
                 bg=self.PRIMARY_LIGHT, fg=self.PRIMARY_HOVER, padx=8, pady=2).pack(side="left", padx=(10, 0))
        tk.Label(left, text="编辑别名主表 → 保存并应用到本机 PGP → 在 CAD 输入 REINIT 生效",
                 font=("Microsoft YaHei UI", 9), bg=self.BG_CARD,
                 fg=self.TEXT_MUTED).pack(anchor="w", pady=(4, 0))

        file_box = tk.Frame(inner, bg=self.BG_SUBTLE, highlightthickness=1,
                            highlightbackground=self.BORDER, padx=12, pady=6)
        file_box.pack(side="right", anchor="center")
        pgp_text = str(self.pgp_path) if self.pgp_path else "未找到本机 PGP，请点击“浏览”选择"
        tk.Label(file_box, text="本机 PGP 文件", font=("Microsoft YaHei UI", 8, "bold"),
                 bg=self.BG_SUBTLE, fg=self.TEXT_MUTED).pack(anchor="w")
        pgp_row = tk.Frame(file_box, bg=self.BG_SUBTLE)
        pgp_row.pack(fill="x", pady=(2, 0))
        self.pgp_label = tk.Label(pgp_row, text=pgp_text, font=("Consolas", 8),
                                  bg=self.BG_SUBTLE, fg=self.TEXT_MAIN, anchor="w")
        self.pgp_label.pack(side="left")
        browse_btn = tk.Label(pgp_row, text="浏览…", font=("Microsoft YaHei UI", 8),
                              bg=self.BG_SUBTLE, fg=self.PRIMARY, cursor="hand2")
        browse_btn.pack(side="left", padx=(10, 0))
        browse_btn.bind("<Button-1>", self._browse_pgp)
        tk.Label(file_box, text=f"主表：{MASTER}", font=("Consolas", 8),
                 bg=self.BG_SUBTLE, fg=self.TEXT_MUTED).pack(anchor="w", pady=(2, 0))

        # ── 底部状态与操作栏 ──
        footer = tk.Frame(self.root, bg=self.BG_CARD, highlightthickness=1,
                          highlightbackground=self.BORDER)
        footer.pack(side="bottom", fill="x", padx=20, pady=(0, 16))
        finner = tk.Frame(footer, bg=self.BG_CARD, padx=16, pady=10)
        finner.pack(fill="x")

        status_frame = tk.Frame(finner, bg=self.BG_CARD)
        status_frame.pack(side="left", fill="x", expand=True)
        self.status_badge = tk.Label(status_frame, text="● 已同步", font=("Microsoft YaHei UI", 9, "bold"),
                                     bg=self.OK_BG, fg=self.OK_FG, padx=8, pady=3)
        self.status_badge.pack(side="left", padx=(0, 10))
        self.status = tk.StringVar(value="尚未修改。保存前会自动备份主表和 PGP，失败自动回滚。")
        tk.Label(status_frame, textvariable=self.status, font=("Microsoft YaHei UI", 9),
                 bg=self.BG_CARD, fg=self.TEXT_MAIN, wraplength=640,
                 justify="left").pack(side="left", fill="x")

        btn_group = tk.Frame(finner, bg=self.BG_CARD)
        btn_group.pack(side="right")
        ttk.Button(btn_group, text="打开备份文件夹", style="Subtle.TButton",
                   command=self._open_backups, cursor="hand2").pack(side="left", padx=(0, 8))
        ttk.Button(btn_group, text="重新扫描命令", style="Subtle.TButton",
                   command=self.rescan_commands, cursor="hand2").pack(side="left", padx=(0, 8))
        ttk.Button(btn_group, text="从本机 PGP 重新导入", style="Secondary.TButton",
                   command=self.reimport, cursor="hand2").pack(side="left", padx=(0, 8))
        ttk.Button(btn_group, text="仅应用到本机", style="Secondary.TButton",
                   command=self.apply_only, cursor="hand2").pack(side="left", padx=(0, 8))
        self.save_button = ttk.Button(btn_group, text="保存并应用到本机", style="Primary.TButton",
                                      command=self.save, cursor="hand2")
        self.save_button.pack(side="left")

        # ── 主体 ──
        body = tk.Frame(self.root, bg=self.BG_MAIN)
        body.pack(side="top", fill="both", expand=True, padx=20, pady=(0, 12))

        # 左：搜索 + 命令列表
        left_card = tk.Frame(body, bg=self.BG_CARD, width=430,
                             highlightthickness=1, highlightbackground=self.BORDER)
        left_card.pack(side="left", fill="both", padx=(0, 14))
        left_card.pack_propagate(False)

        search_wrap = tk.Frame(left_card, bg=self.BG_CARD, padx=12, pady=10)
        search_wrap.pack(fill="x")
        self.search_var = tk.StringVar()
        self.search_var.trace_add("write", lambda *a: self.refresh_list())
        search_entry = ttk.Entry(search_wrap, textvariable=self.search_var,
                                 font=("Microsoft YaHei UI", 10))
        search_entry.pack(fill="x")
        search_entry.insert(0, "")
        tk.Label(search_wrap, text="搜索命令名、别名或功能说明；勾选下方可只看未设别名或与本机不一致",
                 font=("Microsoft YaHei UI", 8), bg=self.BG_CARD,
                 fg=self.TEXT_MUTED, wraplength=390, justify="left").pack(anchor="w", pady=(4, 0))

        filter_row = tk.Frame(left_card, bg=self.BG_CARD, padx=12)
        filter_row.pack(fill="x", pady=(0, 4))
        self.filter_unset = tk.BooleanVar(value=False)
        self.filter_diff = tk.BooleanVar(value=False)
        for var, text in ((self.filter_unset, "未设别名"), (self.filter_diff, "与本机不一致")):
            cb = tk.Checkbutton(filter_row, text=text, variable=var, bg=self.BG_CARD,
                                fg=self.TEXT_MAIN, font=("Microsoft YaHei UI", 9),
                                activebackground=self.BG_CARD, command=self.refresh_list)
            cb.pack(side="left", padx=(0, 12))

        tk.Frame(left_card, bg=self.SEPARATOR, height=1).pack(fill="x")
        list_wrap = tk.Frame(left_card, bg=self.BG_CARD, padx=6, pady=4)
        list_wrap.pack(fill="both", expand=True)
        self.tree = ttk.Treeview(list_wrap, columns=("alias",), show="tree headings",
                                 selectmode="browse")
        self.tree.heading("#0", text="  命令", anchor="w")
        self.tree.heading("alias", text="别名（主表）", anchor="w")
        self.tree.column("#0", width=180, minwidth=120, anchor="w")
        self.tree.column("alias", width=180, minwidth=100, anchor="w")
        scroll = ttk.Scrollbar(list_wrap, orient="vertical", command=self.tree.yview)
        self.tree.configure(yscrollcommand=scroll.set)
        self.tree.pack(side="left", fill="both", expand=True)
        scroll.pack(side="right", fill="y")
        self.tree.bind("<<TreeviewSelect>>", self._on_select)
        # 行底色标签：diff=与本机不一致, ok=已设别名, none=未设
        self.tree.tag_configure("diff", background=self.DIFF_BG)
        self.tree.tag_configure("ok", background="#FFFFFF")
        self.tree.tag_configure("none", background=self.BG_SUBTLE)

        # 右：编辑区
        right = tk.Frame(body, bg=self.BG_MAIN)
        right.pack(side="left", fill="both", expand=True)

        info_card = tk.Frame(right, bg=self.BG_CARD, highlightthickness=1,
                             highlightbackground=self.BORDER)
        info_card.pack(side="top", fill="x", pady=(0, 12))
        info_inner = tk.Frame(info_card, bg=self.BG_CARD, padx=16, pady=12)
        info_inner.pack(fill="x")
        self.info_title = tk.Label(info_inner, text="请选择左侧命令", font=("Microsoft YaHei UI", 12, "bold"),
                                   bg=self.BG_CARD, fg=self.TEXT_MAIN, anchor="w")
        self.info_title.pack(fill="x")
        self.info_desc = tk.Label(info_inner, text="", font=("Microsoft YaHei UI", 9),
                                  bg=self.BG_CARD, fg=self.TEXT_MUTED, anchor="w",
                                  wraplength=560, justify="left")
        self.info_desc.pack(fill="x", pady=(4, 0))
        self.info_pgp = tk.Label(info_inner, text="", font=("Consolas", 9),
                                 bg=self.BG_CARD, fg=self.TEXT_MUTED, anchor="w")
        self.info_pgp.pack(fill="x", pady=(4, 0))

        edit_card = tk.Frame(right, bg=self.BG_CARD, highlightthickness=1,
                             highlightbackground=self.BORDER)
        edit_card.pack(side="top", fill="both", expand=True)
        edit_inner = tk.Frame(edit_card, bg=self.BG_CARD, padx=16, pady=14)
        edit_inner.pack(fill="both", expand=True)
        tk.Label(edit_inner, text="别名列表（每行一条，可增删改）", font=("Microsoft YaHei UI", 10, "bold"),
                 bg=self.BG_CARD, fg=self.TEXT_MAIN).pack(anchor="w")
        tk.Label(edit_inner, text="别名只允许字母、数字、-；目标命令自动转大写；一个命令可有多个别名。",
                 font=("Microsoft YaHei UI", 8), bg=self.BG_CARD,
                 fg=self.TEXT_MUTED).pack(anchor="w", pady=(2, 8))

        table_head = tk.Frame(edit_inner, bg=self.BG_SUBTLE, highlightthickness=1,
                              highlightbackground=self.BORDER)
        table_head.pack(fill="x")
        for text, width in (("别名", 14), ("目标命令", 18), ("备注", 24)):
            tk.Label(table_head, text=text, font=("Microsoft YaHei UI", 9, "bold"),
                     bg=self.BG_SUBTLE, fg=self.TEXT_MAIN, width=width,
                     anchor="w", padx=8, pady=4).pack(side="left")
        tk.Label(table_head, text="", bg=self.BG_SUBTLE).pack(side="left", fill="x", expand=True)

        self.rows_frame = tk.Frame(edit_inner, bg=self.BG_CARD)
        self.rows_frame.pack(fill="both", expand=True, pady=(6, 0))
        self.alias_rows = []

        add_row = tk.Frame(edit_inner, bg=self.BG_CARD)
        add_row.pack(fill="x", pady=(8, 0))
        self.add_btn = ttk.Button(add_row, text="＋ 添加别名", style="Subtle.TButton",
                                  command=self._add_row, cursor="hand2")
        self.add_btn.pack(side="left")

        native_card = tk.Frame(right, bg=self.BG_CARD, highlightthickness=1,
                               highlightbackground=self.BORDER)
        native_card.pack(side="top", fill="x", pady=(12, 0))
        native_inner = tk.Frame(native_card, bg=self.BG_CARD, padx=16, pady=10)
        native_inner.pack(fill="x")
        tk.Label(native_inner, text="指向中望原生命令的别名", font=("Microsoft YaHei UI", 10, "bold"),
                 bg=self.BG_CARD, fg=self.TEXT_MAIN).pack(anchor="w")
        tk.Label(native_inner, text="例如 C→COPY。原生命令名无法在离线状态核对，保存时只警告不拦截。",
                 font=("Microsoft YaHei UI", 8), bg=self.BG_CARD,
                 fg=self.TEXT_MUTED).pack(anchor="w", pady=(2, 6))
        self.native_btn = ttk.Button(native_inner, text="＋ 添加原生命令别名", style="Secondary.TButton",
                                     command=self._add_native, cursor="hand2")
        self.native_btn.pack(anchor="w")

        self._refresh_alias_table()

    # ---------- 列表 ----------

    def _aliases_by_target(self):
        result = {}
        for entry in self.entries:
            result.setdefault(entry.target.upper(), []).append(entry)
        return result

    def _pgp_aliases_by_target(self):
        result = {}
        if self.pgp_doc is None:
            return result
        start, end = self.pgp_doc.managed_start, self.pgp_doc.managed_end
        lines = self.pgp_doc.lines if start is None else self.pgp_doc.lines[start + 1:end]
        for line in lines:
            if line.alias:
                result.setdefault(line.target.upper(), []).append(line.alias.upper())
        return result

    def refresh_list(self):
        query = self.search_var.get().strip().upper() if hasattr(self, "search_var") else ""
        only_unset = self.filter_unset.get()
        only_diff = self.filter_diff.get()
        aliases_by_target = self._aliases_by_target()
        pgp_by_target = self._pgp_aliases_by_target()
        targets = sorted(set(self.plugin_commands) | set(aliases_by_target))
        self.tree.delete(*self.tree.get_children())
        self._row_index = {}
        shown = 0
        for target in targets:
            master_aliases = [e.alias for e in aliases_by_target.get(target, [])]
            pgp_aliases = pgp_by_target.get(target, [])
            desc = self.plugin_commands.get(target, {}).get("desc", "")
            is_native = target not in self.plugin_commands
            if query and query not in target and \
                    not any(query in a for a in master_aliases) and \
                    query not in desc.upper():
                continue
            if only_unset and master_aliases:
                continue
            if only_diff and sorted(master_aliases) == sorted(pgp_aliases):
                continue
            if is_native and not master_aliases and query not in target:
                continue  # 原生命令默认不全部列出，避免列表过长
            tag = "ok"
            if not master_aliases:
                tag = "none"
            elif sorted(master_aliases) != sorted(pgp_aliases):
                tag = "diff"
            iid = target
            label = ("  " + target) if not is_native else ("  [原生] " + target)
            self.tree.insert("", "end", iid=iid, text=label,
                             values=(", ".join(master_aliases),), tags=(tag,))
            self._row_index[iid] = target
            shown += 1
        if shown == 0:
            self.tree.insert("", "end", iid="__empty__",
                             text="  无匹配命令", values=("",), tags=("none",))

    def _on_select(self, event=None):
        selection = self.tree.selection()
        if not selection or selection[0] == "__empty__":
            return
        target = self._row_index.get(selection[0])
        if target is None:
            return
        self.selected = target
        self._refresh_detail()

    # ---------- 右侧编辑区 ----------

    def _refresh_detail(self):
        target = self.selected
        if target is None:
            return
        aliases = [e for e in self.entries if e.target.upper() == target]
        pgp_aliases = self._pgp_aliases_by_target().get(target, [])
        is_plugin = target in self.plugin_commands
        native_flag = any(FLAG_NATIVE in (e.flags or ()) for e in aliases)
        if is_plugin:
            kind = "插件命令"
        elif native_flag:
            kind = "原生命令（已标记；离线无法核对）"
        else:
            kind = "原生命令（未标记，保存时若目标未知会被拦截）"
        self.info_title.configure(text=f"{target}　·　{kind}")
        desc = self.plugin_commands.get(target, {}).get("desc", "")
        file_line = ""
        if is_plugin:
            info = self.plugin_commands[target]
            file_line = f"{info['file']}:{info['line']}"
        # 目标可能已失效（历史插件命令里有、当前没有）
        stale = (not is_plugin and not native_flag
                 and target in self.history_commands)
        extra = "　⚠ 该插件命令可能已删除或改名" if stale else ""
        self.info_desc.configure(text=(desc or "（无功能说明）") + (("　" + file_line) if file_line else "") + extra)
        pgp_text = "、".join(pgp_aliases) if pgp_aliases else "（本机 PGP 中无别名）"
        if pgp_aliases and sorted(pgp_aliases) != sorted([e.alias for e in aliases]):
            pgp_text += "　⚠ 与主表不一致"
        self.info_pgp.configure(text=f"本机 PGP 实际值：{pgp_text}")
        self._refresh_alias_table()

    def _refresh_alias_table(self):
        for widget in self.rows_frame.winfo_children():
            widget.destroy()
        self.alias_rows = []
        if self.selected is None:
            return
        target = self.selected
        rows = [e for e in self.entries if e.target.upper() == target]
        for entry in rows:
            self._make_row(entry)

    def _make_row(self, entry):
        frame = tk.Frame(self.rows_frame, bg=self.BG_CARD,
                         highlightthickness=1, highlightbackground=self.SEPARATOR)
        frame.pack(fill="x", pady=2)
        alias_var = tk.StringVar(value=entry.alias)
        note_var = tk.StringVar(value=entry.note)
        alias_entry = ttk.Entry(frame, textvariable=alias_var, font=("Consolas", 10), width=16)
        alias_entry.pack(side="left", padx=6, pady=4)
        tk.Label(frame, text="→", bg=self.BG_CARD, fg=self.TEXT_MUTED,
                 font=("Microsoft YaHei UI", 10)).pack(side="left")
        tk.Label(frame, text=entry.target, bg=self.BG_CARD, fg=self.TEXT_MAIN,
                 font=("Consolas", 10, "bold"), width=20, anchor="w").pack(side="left", padx=6)
        if FLAG_NATIVE in (entry.flags or ()):
            tk.Label(frame, text="原生", bg=self.PRIMARY_LIGHT, fg=self.PRIMARY_HOVER,
                     font=("Microsoft YaHei UI", 8, "bold"), padx=6, pady=1).pack(side="left", padx=(0, 6))
        note_entry = ttk.Entry(frame, textvariable=note_var, font=("Microsoft YaHei UI", 9), width=24)
        note_entry.pack(side="left", padx=6)
        row_state = {"frame": frame, "entry": entry, "alias_var": alias_var, "note_var": note_var}

        def on_change(*_):
            if self._loading:
                return
            new_alias = alias_pgp.normalize_alias(alias_var.get())
            new_note = note_var.get()
            # 用同一个 new 对象同时更新 self.entries 和 row_state，保证 is 比较有效
            old = row_state["entry"]
            new = replace(old, alias=new_alias, note=new_note)
            self.entries = [new if e is old else e for e in self.entries]
            row_state["entry"] = new
            self.refresh_list()
            self._update_dirty_ui()
            self.status.set("有未保存的修改。")

        alias_var.trace_add("write", on_change)
        note_var.trace_add("write", on_change)

        del_btn = tk.Label(frame, text="删除", font=("Microsoft YaHei UI", 9),
                           bg=self.BG_CARD, fg=self.DANGER, cursor="hand2")
        del_btn.pack(side="right", padx=8)
        del_btn.bind("<Button-1>", lambda e: self._delete_row(row_state))
        self.alias_rows.append(row_state)

    def _delete_row(self, row_state):
        """删除一行；供删除按钮与回归测试共用同一条代码路径。"""
        target_entry = row_state["entry"]
        self.entries = [e for e in self.entries if e is not target_entry]
        row_state["frame"].destroy()
        if row_state in self.alias_rows:
            self.alias_rows.remove(row_state)
        self.refresh_list()
        self._update_dirty_ui()
        self.status.set(f"已删除别名 {target_entry.alias}（未保存）。")

    def _add_row(self):
        if self.selected is None:
            messagebox.showinfo("请先选择命令", "在左侧选中一个命令后再添加别名。", parent=self.root)
            return
        # 同一目标已有 native 标记时，新行沿用该标记
        flags = ()
        for existing in self.entries:
            if existing.target.upper() == self.selected and FLAG_NATIVE in (existing.flags or ()):
                flags = (FLAG_NATIVE,)
                break
        entry = AliasEntry("", self.selected, "", flags)
        self.entries.append(entry)
        self._loading = True
        self._refresh_alias_table()
        self._loading = False
        self._update_dirty_ui()
        self.status.set("已新增一行，请填写别名。")

    def _add_native(self):
        dialog = tk.Toplevel(self.root)
        dialog.title("添加原生命令别名")
        dialog.configure(bg=self.BG_CARD)
        dialog.resizable(False, False)
        dialog.transient(self.root)
        dialog.grab_set()
        rx, ry = self.root.winfo_rootx(), self.root.winfo_rooty()
        rw, rh = self.root.winfo_width(), self.root.winfo_height()
        dialog.geometry(f"420x200+{rx + (rw - 420) // 2}+{ry + (rh - 200) // 2}")
        body = tk.Frame(dialog, bg=self.BG_CARD, padx=20, pady=16)
        body.pack(fill="both", expand=True)
        tk.Label(body, text="目标原生命令名（如 COPY、CIRCLE）：",
                 font=("Microsoft YaHei UI", 10, "bold"), bg=self.BG_CARD,
                 fg=self.TEXT_MAIN).pack(anchor="w")
        target_var = tk.StringVar()
        ttk.Entry(body, textvariable=target_var, font=("Consolas", 11)).pack(fill="x", pady=(6, 12))
        tk.Label(body, text="别名（如 C）：", font=("Microsoft YaHei UI", 10, "bold"),
                 bg=self.BG_CARD, fg=self.TEXT_MAIN).pack(anchor="w")
        alias_var = tk.StringVar()
        ttk.Entry(body, textvariable=alias_var, font=("Consolas", 11)).pack(fill="x", pady=(6, 14))
        result = [None]

        def confirm(event=None):
            result[0] = (alias_var.get(), target_var.get())
            dialog.destroy()

        btns = tk.Frame(body, bg=self.BG_CARD)
        btns.pack(fill="x")
        ttk.Button(btns, text="添加", style="Primary.TButton", command=confirm,
                   cursor="hand2").pack(side="right")
        ttk.Button(btns, text="取消", style="Secondary.TButton", command=dialog.destroy,
                   cursor="hand2").pack(side="right", padx=(0, 8))
        dialog.bind("<Return>", confirm)
        self.root.wait_window(dialog)
        if not result[0]:
            return
        alias, target = result[0]
        self.add_native_entry(alias, target)

    def add_native_entry(self, alias, target):
        """登记一条指向中望原生命令的别名（带 native 标记，供对话框与测试共用）。"""
        alias = alias_pgp.normalize_alias(alias)
        target = target.strip().upper()
        if not alias or not target:
            messagebox.showerror("无效", "别名和目标命令不能为空。", parent=self.root)
            return False
        self.entries.append(AliasEntry(alias, target, "原生命令", (FLAG_NATIVE,)))
        self.selected = target
        self.refresh_list()
        if self.tree.exists(target):
            self.tree.selection_set(target)
            self.tree.see(target)
        self._refresh_detail()
        self._update_dirty_ui()
        return True

    # ---------- 状态 ----------

    def _update_dirty_ui(self):
        dirty = master_dirty(self.entries, self.baseline)
        in_sync = pgp_in_sync(self.entries, self.pgp_doc)
        if self.busy:
            self.status_badge.configure(text="● 保存中", bg=self.PRIMARY_LIGHT, fg=self.PRIMARY_HOVER)
            self.save_button.configure(state="disabled")
            return
        if dirty:
            self.status_badge.configure(text="● 未保存修改", bg=self.WARN_BG, fg=self.WARN_FG)
        elif not in_sync:
            self.status_badge.configure(text="● 与本机 PGP 不一致", bg=self.DIFF_BG, fg=self.WARN_FG)
        else:
            self.status_badge.configure(text="● 已同步", bg=self.OK_BG, fg=self.OK_FG)
        self.save_button.configure(state="normal")

    # ---------- 动作 ----------

    def _browse_pgp(self, event=None):
        path = filedialog.askopenfilename(
            parent=self.root, title="选择 ZWCAD.pgp",
            filetypes=[("PGP 文件", "*.pgp"), ("所有文件", "*.*")])
        if not path:
            return
        alias_pgp.save_local_pgp_path(Path(path))
        self.pgp_path = Path(path)
        self.pgp_doc = alias_pgp.read_pgp(path)
        self.pgp_raw_snapshot = Path(path).read_bytes()
        self.pgp_label.configure(text=str(self.pgp_path))
        self.refresh_list()
        self._refresh_detail()
        self._update_dirty_ui()
        self.status.set(f"已切换到 PGP：{path}")

    def _open_backups(self):
        folder = ROOT / "backups"
        folder.mkdir(exist_ok=True)
        os.startfile(folder)

    def rescan_commands(self):
        """重新扫描插件命令；保留当前编辑内容与选择。"""
        commands, skipped = scan_plugin_commands()
        self.plugin_commands = commands
        self.skipped_files = skipped
        self.history_commands = alias_pgp.history_plugin_commands()
        # 目标已不在扫描结果里的条目标记为失效提示，但不删除用户编辑内容
        self.refresh_list()
        if self.selected:
            if self.tree.exists(self.selected):
                self.tree.selection_set(self.selected)
                self.tree.see(self.selected)
                self._refresh_detail()
            else:
                self._refresh_detail()
        note = f"已重新扫描：当前插件命令 {len(commands)} 条。"
        if skipped:
            note += " 跳过无法解码的文件：" + "、".join(skipped)
        self.status.set(note)
        self._update_dirty_ui()

    def _validate(self):
        errors, _ = alias_pgp.validate_master(self.entries, set(self.plugin_commands), self.known_targets)
        return errors

    def _write_master(self, path=None):
        path = Path(path or MASTER)
        path.parent.mkdir(parents=True, exist_ok=True)
        raw = alias_pgp.render_master_bytes(self.entries)
        temporary = path.with_suffix(".csv.tmp")
        temporary.write_bytes(raw)
        # 回读校验（含 flags）
        got = alias_pgp.parse_master_bytes(temporary.read_bytes())
        if got != list(self.entries):
            temporary.unlink(missing_ok=True)
            raise AliasError("主表写回后内容不一致，已取消。")
        os.replace(temporary, path)

    def _run_save(self, apply_pgp: bool):
        errors, validate_warnings = alias_pgp.validate_master(
            self.entries, set(self.plugin_commands), self.known_targets)
        # 失效目标提示（历史插件命令里有、当前没有；仅警告不拦截）
        stale = alias_pgp.stale_target_warnings(
            self.entries, set(self.plugin_commands), self.history_commands)
        validate_warnings = list(validate_warnings) + stale
        if errors:
            messagebox.showerror("存在冲突，无法保存", "\n".join("• " + e for e in errors), parent=self.root)
            return
        if self.busy:
            return
        if self.pgp_doc is None:
            messagebox.showerror("未找到 PGP", "请先点击右上角“浏览”选择本机 ZWCAD.pgp。", parent=self.root)
            return
        override_warns = alias_pgp.override_conflicts(self.entries, self.pgp_doc)
        restore_warns = alias_pgp.restore_warnings(self.pgp_doc, self.entries)
        all_warnings = list(override_warns) + list(restore_warns) + list(validate_warnings)
        if all_warnings:
            if not messagebox.askyesno("保存确认",
                                       "以下提示需要确认：\n\n" +
                                       "\n".join("• " + w for w in all_warnings[:20]) +
                                       ("\n…" if len(all_warnings) > 20 else "") +
                                       "\n\n是否继续保存？", parent=self.root):
                return
        # 笔记本场景：本机 PGP 无托管区块 + 用户区有主表没有的别名，询问是否并入
        extra_entries = []
        if self.pgp_doc.managed_start is None:
            discovered, _ = alias_pgp.discover_user_aliases(self.pgp_doc, set(self.plugin_commands))
            master_aliases = {alias_pgp.normalize_alias(e.alias) for e in self.entries}
            extra_entries = [e for e in discovered
                             if alias_pgp.normalize_alias(e.alias) not in master_aliases]
        if extra_entries:
            choice = messagebox.askyesnocancel(
                "检测到本机多余别名",
                "本机 PGP 用户区有以下别名不在主表里：\n\n"
                + "\n".join(f"  {e.alias} → {e.target}" for e in extra_entries[:15])
                + ("\n  …" if len(extra_entries) > 15 else "")
                + "\n\n是＝并入主表；否＝保持原样留在区块外；取消＝中止保存。",
                parent=self.root)
            if choice is None:
                return
            if choice:
                self.entries = list(self.entries) + [
                    replace(e, note="本机导入") for e in extra_entries]
                self.refresh_list()
                self._refresh_detail()
                self._update_dirty_ui()
        self.busy = True
        self._update_dirty_ui()
        self.status.set("正在备份并写入，请稍候…")
        entries = list(self.entries)
        pgp_path = self.pgp_path
        snapshot = self.pgp_raw_snapshot

        def worker():
            pgp_backup = ""
            pgp_applied = False
            try:
                with exclusive_lock():
                    if apply_pgp:
                        report, _ = alias_pgp.apply_to_pgp(
                            pgp_path, entries, set(self.plugin_commands),
                            self.known_targets, expect_doc=snapshot)
                        pgp_backup = report.get("backup", "")
                        pgp_applied = True
                    self._write_master()
                self.events.put((True, ("saved", pgp_backup)))
            except Exception as error:
                if pgp_applied and pgp_backup:
                    # PGP 已替换成功但主表写入失败：用备份把 PGP 也恢复，保证两者一致
                    backup_pgp = Path(pgp_backup) / Path(pgp_path).name
                    try:
                        if not backup_pgp.exists():
                            raise AliasError(f"备份文件不存在：{backup_pgp}")
                        Path(pgp_path).write_bytes(backup_pgp.read_bytes())
                        self.events.put((False, ("pgp_restored",
                                                 f"PGP 已写入但主表保存失败，已用备份恢复 PGP。"
                                                 f"备份目录：{pgp_backup}。原始错误：{error}")))
                    except Exception as restore_error:
                        self.events.put((False, ("pgp_restore_failed",
                                                 f"PGP 已写入但主表保存失败；恢复 PGP 也失败。"
                                                 f"请手动从备份恢复：{pgp_backup}。"
                                                 f"原始错误：{error}；恢复错误：{restore_error}")))
                    return
                self.events.put((False, ("no_change", str(error))))

        threading.Thread(target=worker, daemon=True).start()
        self.root.after(100, self._poll)

    def _poll(self):
        try:
            ok, info = self.events.get_nowait()
        except queue.Empty:
            self.root.after(100, self._poll)
            return
        self.busy = False
        if ok:
            _, backup = info
            self.baseline = list(self.entries)
            if self.pgp_path and Path(self.pgp_path).exists():
                self.pgp_doc = alias_pgp.read_pgp(self.pgp_path)
                self.pgp_raw_snapshot = Path(self.pgp_path).read_bytes()
            self.status.set(("已保存并应用到本机 PGP。" if backup else "已保存主表。")
                            + " 备份：" + (backup or "—")
                            + "。请到 CAD 输入 REINIT 并勾选 PGP 文件；若无效请重启 CAD。"
                              "插件命令的别名需等 LSP 加载后才能使用。")
            self.refresh_list()
            self._refresh_detail()
        else:
            kind, message = info
            if kind == "pgp_restored":
                self.status.set("保存未完成：PGP 已用备份恢复。")
                messagebox.showerror("保存失败", message, parent=self.root)
                # PGP 已被恢复，重新读取实际内容
                if self.pgp_path and Path(self.pgp_path).exists():
                    self.pgp_doc = alias_pgp.read_pgp(self.pgp_path)
                    self.pgp_raw_snapshot = Path(self.pgp_path).read_bytes()
                self.refresh_list()
                self._refresh_detail()
            elif kind == "pgp_restore_failed":
                self.status.set("保存失败：PGP 与主表可能不一致，请按提示手动恢复。")
                messagebox.showerror("保存失败（需手动恢复）", message, parent=self.root)
            else:  # no_change：PGP 和主表均未修改
                self.status.set("保存未完成，未做任何修改。")
                messagebox.showerror("保存失败", message, parent=self.root)
        self._update_dirty_ui()

    def save(self):
        self._run_save(apply_pgp=True)

    def apply_only(self):
        if master_dirty(self.entries, self.baseline):
            if not messagebox.askyesno("有未保存修改", "当前有未保存到主表的修改。仅应用主表已有内容，丢弃这些修改？",
                                       parent=self.root):
                return
            self.entries = list(self.baseline)
            self.refresh_list()
            self._refresh_detail()
        self._run_save(apply_pgp=True)

    def reimport(self):
        if self.pgp_doc is None:
            messagebox.showerror("未找到 PGP", "请先点击右上角“浏览”选择本机 ZWCAD.pgp。", parent=self.root)
            return
        imported, uncertain = alias_pgp.discover_user_aliases(self.pgp_doc, set(self.plugin_commands))
        if self.pgp_doc.managed_start is not None:
            messagebox.showinfo("已有托管区块", "本机 PGP 已存在托管区块，无需重新导入。如需同步请点击“仅应用到本机”。",
                                parent=self.root)
            return
        if not imported:
            messagebox.showinfo("无自定义别名", "本机 PGP 末尾未检测到可导入的自定义别名。", parent=self.root)
            return
        if not messagebox.askyesno("重新导入", f"将从本机 PGP 导入 {len(imported)} 条别名并覆盖当前主表，是否继续？",
                                   parent=self.root):
            return
        self.entries = list(imported)
        self._update_dirty_ui()
        self.refresh_list()
        self._refresh_detail()
        note = f"已导入 {len(imported)} 条。"
        if uncertain:
            note += " 被注释的行保持原样：" + "、".join(f"{a}→{t}" for a, t in uncertain)
        self.status.set(note)

    def close(self):
        if self.busy:
            messagebox.showinfo("正在保存", "请等待保存结束再关闭。", parent=self.root)
            return
        if master_dirty(self.entries, self.baseline):
            if not messagebox.askyesno("未保存的修改", "放弃未保存的修改并关闭？", parent=self.root):
                return
        self.root.destroy()


def main():
    root = tk.Tk()
    try:
        Panel(root)
        root.mainloop()
    except Exception as error:
        root.withdraw()
        messagebox.showerror("无法打开命令别名设置", str(error), parent=root)
        root.destroy()
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
