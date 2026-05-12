# ZW-auto_lisp 项目规则（Codex 必须遵守）

本项目是 CAD AutoLISP 插件集合，主要面向 AutoCAD 2018，同时也可能涉及 ZWCAD 2026 验证。以下规则是硬性要求，优先于 Codex 的默认编辑习惯。

## 一、文件编码（最重要）

1. 所有 AutoLISP 文件（`.lsp`）必须保存为 ANSI / GBK 编码，绝对不允许 UTF-8、UTF-8 BOM、UTF-16。
2. CAD 相关文本文件（`.dcl`、`.scr`、`.mnl`、`.lin`、`.pat`）同样优先 ANSI / GBK。
3. 换行符必须是 Windows CRLF（`\r\n`），不允许 LF-only。
4. 中文字符串必须在 AutoCAD 2018 中正常显示。出现任何 `\xef\xbf\xbd`、`?`、方块都视为严重 bug。
5. C# 源码可以 UTF-8，但与 CAD 交互的字符串要验证在 AutoCAD 2018 中不乱码。

## 二、编辑 GBK 文件的正确方式（强制）

Codex 的常规文本补丁工具可能按 UTF-8 处理文件。直接用普通文本补丁编辑 GBK 文件，可能把中文破坏成替换字符，造成不可逆损坏。

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
2. AutoCAD 2018 是编码兼容性的关键验证环境。
3. ZWCAD 2026 可用于当前工作流验证，但不能替代 AutoCAD 2018 的编码结论。
4. 不以 WSL2 测试结果作为最终依据，因为路径、编码、COM 行为都可能不一致。

## 五、项目结构要点

- 主整合文件：`E:\366256\ZW-auto_lisp\AA整合版本.lsp`
- 主模块文件：`E:\366256\ZW-auto_lisp\AA-main.lsp`
- 加载器：`E:\366256\ZW-auto_lisp\aa-loader.lsp`
- 小命令目录：`E:\366256\ZW-auto_lisp\小命令`
- Claude 规则文件：`E:\366256\ZW-auto_lisp\CLAUDE.md`
- Codex 规则文件：`E:\366256\ZW-auto_lisp\AGENTS.md`

## 六、发现编码异常时

如果发现文件已经被 UTF-8 化、出现 `\xef\xbf\xbd`、中文乱码、换行异常，必须立刻停手：

1. 不要在损坏文件上继续打补丁。
2. 从最近的干净备份恢复。
3. 恢复后重新用 GBK 字节级方式修改。
4. 再次执行 GBK / CRLF / 无替换字符验证。

