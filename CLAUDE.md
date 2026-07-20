# ZW-auto_lisp 项目规则（必须遵守）

本项目是 CAD AutoLISP 插件集合，主要使用中望 CAD 2026（ZWCAD 2026），有时也会使用 AutoCAD 2018。以下规则是硬性要求，优先于各工具的默认编辑习惯。

本文件必须与 `E:\366256\ZW-auto_lisp\CLAUDE.md` 永远保持完全同步。更新其中任意一份后，必须立即把同样内容写入另一份。

## 一、文件编码（最重要）

1. 所有 AutoLISP 文件（`.lsp`）必须保存为 ANSI / GBK 编码，绝对不允许 UTF-8、UTF-8 BOM、UTF-16。
2. CAD 相关文本文件（`.dcl`、`.scr`、`.mnl`、`.lin`、`.pat`）同样优先 ANSI / GBK。
3. 换行符必须是 Windows CRLF（`\r\n`），不允许 LF-only。
4. 中文字符串必须在中望 CAD 2026 与 AutoCAD 2018 中正常显示。出现任何 `\xef\xbf\xbd`、`?`、方块都视为严重 bug。
5. C# 源码可以 UTF-8，但与 CAD 交互的字符串要验证在中望 CAD 2026 与 AutoCAD 2018 中不乱码。

## 二、编辑 GBK 文件的正确方式（强制）

Codex、Claude Code 等工具的常规文本补丁可能按 UTF-8 处理文件。直接用普通文本补丁编辑 GBK 文件，可能把中文破坏成替换字符，造成不可逆损坏。

因此：

- 禁止对 `.lsp` / `.dcl` / `.scr` / `.mnl` / `.lin` / `.pat` 等 GBK 文件直接使用普通 UTF-8 文本补丁。
- 必须用字节级方式读写，且显式指定 `gbk` 编码。
- 写入后必须立即验证文件仍然是 GBK 且换行为 CRLF。
- 如果改动内容本身不含中文，可以通过脚本做 ASCII 字符串替换；如果补丁内容含中文，必须以 GBK 字节或 GBK 临时文件方式处理，不能把中文直接写进普通 UTF-8 补丁。

推荐 Python 方式：

```python
from pathlib import Path

path = Path(r"E:\366256\ZW-auto_lisp\AA整合版本.lsp")

# 读
text = path.read_bytes().decode("gbk")

# 修改 text 后写回，确保 CRLF + GBK
out = text.replace("\r\n", "\n").replace("\r", "\n").replace("\n", "\r\n")
path.write_bytes(out.encode("gbk"))

# 验证
back = path.read_bytes()
assert b"\xef\xbf\xbd" not in back
back.decode("gbk")
assert b"\r\n" in back
```

PowerShell 写 GBK 文件时必须显式指定 936 编码，例如：

```powershell
[System.IO.File]::WriteAllText($path, $text, [System.Text.Encoding]::GetEncoding(936))
```

不要用 PowerShell 默认写入 CAD 相关文件。

## 三、修改前备份

修改 `.lsp` 主文件前，必须先复制一份备份，命名格式建议：

- `<原名>.bak_YYYYMMDD`
- `<原名>.bak-encoding-YYYYMMDD-HHMMSS`

备份必须通过字节级复制完成，不能触发编码转换。

## 四、测试环境

1. 插件必须尽量在 Windows 原生 CAD 环境中测试。
2. 中望 CAD 2026 是主要日常使用和当前工作流验证环境。
3. AutoCAD 2018 仍是编码兼容性的关键验证环境，不能忽略。
4. 不以 WSL2 测试结果作为最终依据，因为路径、编码、COM 行为都可能不一致。

## 五、项目结构要点

- 主整合文件：`E:\366256\ZW-auto_lisp\AA整合版本.lsp`
- 加载器：`E:\366256\ZW-auto_lisp\aa-loader.lsp`
- 小命令目录：`E:\366256\ZW-auto_lisp\小命令`
- Markdown 命令索引：`E:\366256\ZW-auto_lisp\命令索引.md`
- HTML 命令索引：`E:\366256\ZW-auto_lisp\命令索引.html`
- Claude 规则文件：`E:\366256\ZW-auto_lisp\CLAUDE.md`
- Codex 规则文件：`E:\366256\ZW-auto_lisp\AGENTS.md`

## 六、发现编码异常时

如果发现文件已经被 UTF-8 化、出现 `\xef\xbf\xbd`、中文乱码、换行异常，必须立刻停手：

1. 不要在损坏文件上继续打补丁。
2. 从最近的干净备份恢复。
3. 恢复后重新用 GBK 字节级方式修改。
4. 再次执行 GBK / CRLF / 无替换字符验证。

## 七、命令清单维护（强制）

1. `AA整合版本.lsp` 文件开头的 `;;; 包含以下命令:` 清单必须覆盖当前文件内所有 `(defun c:命令名 ...)` 入口。
2. 每次新增、删除、改名命令，必须同步更新该清单，不能只改函数本体。
3. 更新清单时优先以实际存在的 `(defun c:...)` 为准，不保留已经不存在的旧命令。
4. 命令说明要简短写清用途，新增命令至少写明触发命令名和核心功能。

## 八、批量处理性能

1. 批量处理大量实体时，不要在循环中逐对象调用原生命令或 `entupd`；优先把选择集一次性交给原生命令，使用 `entmod` 完成逐实体数据修改后再统一 `redraw`。
2. 对 AutoCAD / ZWCAD 可能存在差异的批量命令，应检查批处理后仍存在的对象，并只对遗漏对象执行兼容性补处理。

## 九、整合版本与命令索引同步（强制）

1. 每次新增、修改、删除或改名 AutoLISP 命令后，必须重新更新 `AA整合版本.lsp`，确保整合版本包含本次完成的最新脚本内容；不得只修改独立脚本而遗漏整合版本。
2. 整合版本更新完成后，必须在项目根目录运行 `python gen_命令索引.py`，同时重新生成 `命令索引.md` 和 `命令索引.html`。
3. Markdown 与 HTML 两份命令索引必须保持内容一致，均以生成器扫描到的实际 `.lsp` 命令为准，禁止只更新其中一份。
4. 交付前必须核对 `AA整合版本.lsp`、`命令索引.md`、`命令索引.html` 均已反映本次脚本修改。
