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


@dataclass(frozen=True)
class Entry:
    name: str
    left: bool
    upper: str
    lower: str
    cabinet: str


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
                and len(form[3]) == 6 and form[3][0] == "aa:km-ln-cmd"):
            call = form[3]
            name = form[1][2:].upper()
            if call[2] not in ("t", "nil") or unquote(call[1]).upper() != name:
                raise ValueError(f"{name} 的调用结构不支持面板编辑。")
            if name in result:
                raise ValueError(f"命令重复：{name}")
            result[name] = (Entry(name, call[2] == "t", *map(unquote, call[3:])),
                            locations[id(form)][1:])
    return result


def discover(text):
    return [entry for entry, span in wrappers(text).values()]


def description(entry):
    side = "左" if entry.left else "右"
    return (f"选中至少两条水平线后向{side}生成短线、矩形并居中标注"
            f"{entry.upper}、{entry.lower}及{entry.cabinet}（青色虚线）。")


def definition(entry):
    return (f"(defun c:{entry.name} ()\r\n"
            f"  (aa:km-ln-cmd {quote(entry.name)} {'T' if entry.left else 'nil'} "
            f"{quote(entry.upper)} {quote(entry.lower)} {quote(entry.cabinet)})\r\n)")


def render(text, entries):
    old = wrappers(text)
    forms, _ = parse_with_locations(text)
    commands = {f[1][2:].upper() for f in forms if isinstance(f, list) and len(f) > 1
                and f[0] == "defun" and isinstance(f[1], str) and f[1].startswith("c:")}
    names = set()
    for entry in entries:
        if not re.fullmatch(r"[A-Z][A-Z0-9_]{0,31}", entry.name):
            raise ValueError("命令名须以英文字母开头，只能包含大写字母、数字、下划线（最多32位）。")
        if entry.name in names or (entry.name in commands and entry.name not in old):
            raise ValueError(f"命令名重复或与现有命令冲突：{entry.name}")
        names.add(entry.name)
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
    def __init__(self, root):
        self.root = root
        self.original = read_source(SOURCE)
        self.entries = discover(self.original)
        self.selected = None
        self.loading = False
        self.busy = False
        self.events = queue.Queue()
        root.title("屏柜命令设置 · ZW-auto_lisp")
        root.geometry("1020x670")
        root.minsize(880, 590)
        style = ttk.Style()
        style.theme_use("clam")
        style.configure("TLabel", font=("Microsoft YaHei UI", 10))
        style.configure("TButton", font=("Microsoft YaHei UI", 10), padding=7)
        style.configure("Treeview", rowheight=32, font=("Microsoft YaHei UI", 10))
        base = ttk.Frame(root, padding=20)
        base.pack(fill="both", expand=True)
        ttk.Label(base, text="屏柜命令设置", font=("Microsoft YaHei UI", 20, "bold")).pack(anchor="w")
        ttk.Label(base, text="修改文字和方向 → 保存 → 在 CAD 中自行重新加载", foreground="#546477").pack(anchor="w", pady=(5, 12))
        ttk.Label(base, text=f"当前文件：{SOURCE}", wraplength=960).pack(anchor="w")
        body = ttk.Frame(base)
        body.pack(fill="both", expand=True, pady=14)
        left = ttk.Frame(body)
        left.pack(side="left", fill="y", padx=(0, 22))
        self.tree = ttk.Treeview(left, columns=("side",), show="tree headings", height=11, selectmode="browse")
        self.tree.heading("#0", text="命令")
        self.tree.heading("side", text="方向")
        self.tree.column("#0", width=130)
        self.tree.column("side", width=65)
        self.tree.pack(fill="y", expand=True)
        self.tree.bind("<<TreeviewSelect>>", self.select)
        self.add_button = ttk.Button(left, text="复制为新命令…", command=self.add)
        self.add_button.pack(fill="x", pady=10)
        right = ttk.Frame(body)
        right.pack(side="left", fill="both", expand=True)
        self.vars = {key: tk.StringVar() for key in ("name", "side", "upper", "lower", "cabinet")}
        self.inputs = []
        for i, (key, label) in enumerate((("name", "命令名"), ("side", "生成方向"), ("upper", "上方标注"), ("lower", "下方标注"), ("cabinet", "柜内文字"))):
            ttk.Label(right, text=label).grid(row=i, column=0, sticky="w", pady=7, padx=(0, 15))
            if key == "side":
                widget = ttk.Combobox(right, textvariable=self.vars[key], values=("向左", "向右"), state="readonly")
            else:
                widget = ttk.Entry(right, textvariable=self.vars[key], font=("Microsoft YaHei UI", 11), state="readonly" if key == "name" else "normal")
            widget.grid(row=i, column=1, sticky="ew", pady=7)
            self.inputs.append(widget)
            self.vars[key].trace_add("write", self.change)
        right.columnconfigure(1, weight=1)
        ttk.Label(right, text="实时示意预览（尺寸以 CAD 实际绘制为准）", foreground="#546477").grid(row=5, column=0, columnspan=2, sticky="w", pady=(16, 8))
        self.canvas = tk.Canvas(right, bg="#ffffff", height=175, highlightthickness=1, highlightbackground="#d4dde7")
        self.canvas.grid(row=6, column=0, columnspan=2, sticky="nsew")
        right.rowconfigure(6, weight=1)
        self.canvas.bind("<Configure>", lambda event: self.preview())
        self.status = tk.StringVar(value="尚未修改。保存前会自动备份并检查，失败会恢复原文件。")
        ttk.Label(base, textvariable=self.status, wraplength=960).pack(anchor="w", pady=(0, 8))
        self.save_button = ttk.Button(base, text="保存全部设置", command=self.save)
        self.save_button.pack(anchor="e")
        self.refresh()
        root.protocol("WM_DELETE_WINDOW", self.close)

    def refresh(self):
        for item in self.tree.get_children():
            self.tree.delete(item)
        for i, entry in enumerate(self.entries):
            self.tree.insert("", "end", iid=str(i), text=entry.name, values=("左" if entry.left else "右",))
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
        for key, value in (("name", entry.name), ("side", "向左" if entry.left else "向右"), ("upper", entry.upper), ("lower", entry.lower), ("cabinet", entry.cabinet)):
            self.vars[key].set(value)
        self.loading = False
        self.preview()

    def change(self, *args):
        if self.loading or self.selected is None:
            return
        self.entries[self.selected] = Entry(self.vars["name"].get(), self.vars["side"].get() == "向左",
                                            *(self.vars[k].get() for k in ("upper", "lower", "cabinet")))
        self.tree.item(str(self.selected), values=("左" if self.entries[self.selected].left else "右",))
        self.status.set("有未保存的设置。预览已更新，保存后再自行重新加载。")
        self.preview()

    def preview(self):
        if self.selected is None:
            return
        canvas = self.canvas
        canvas.delete("all")
        width, height = max(canvas.winfo_width(), 450), max(canvas.winfo_height(), 175)
        entry = self.entries[self.selected]
        middle = height / 2
        box_width = min(max(120, len(entry.cabinet) * 14 + 28), width * .65)
        x1 = 18 if entry.left else width - box_width - 18
        x2 = x1 + box_width
        joint, tail = (x2, width - 22) if entry.left else (x1, 22)
        color = "#007f8c"
        canvas.create_rectangle(x1, middle - 50, x2, middle + 50, outline=color, dash=(6, 3), width=2)
        canvas.create_text((x1+x2)/2, middle, text=entry.cabinet, font=("Microsoft YaHei UI", 11), fill=color, width=box_width-12)
        for offset, text in ((-27, entry.upper), (27, entry.lower)):
            canvas.create_line(joint, middle+offset, tail, middle+offset, fill=color, dash=(6, 3), width=2)
            canvas.create_text((joint+tail)/2, middle+offset-13, text=text, fill=color, font=("Microsoft YaHei UI", 10))

    def add(self):
        if self.busy:
            return
        name = simpledialog.askstring("增加命令", "新命令名（如 DYZ、UPSFZ）：", parent=self.root)
        if not name:
            return
        entry = replace(self.entries[self.selected], name=name.strip().upper())
        try:
            render(self.original, [*self.entries, entry])
        except Exception as error:
            messagebox.showerror("无法增加", str(error), parent=self.root)
            return
        self.entries.append(entry)
        self.selected = len(self.entries)-1
        self.refresh()
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
