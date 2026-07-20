# ZW-auto_lisp

面向中望 CAD 2026、兼容 AutoCAD 2018 的 AutoLISP 常用命令集合，主程序为 `AA整合版本.lsp`。

## 使用

1. 在 CAD 中运行 `APPLOAD`。
2. 加载 `E:\366256\ZW-auto_lisp\aa-loader.lsp`，加载器会自动载入主整合文件。
3. 输入所需命令。完整清单见 [`命令索引.md`](命令索引.md)。

常用文字命令：

- `T`：将所选 `TEXT/MTEXT` 刷为 `HZ` 样式，高度 `3`、宽度比例 `0.7`；`MTEXT` 会先拆成 `TEXT`。
- `QSTXT`：从选择内容中保留文字对象。
- `QW`：修改文字高度。
- `WI`：修改文字宽度比例。

## 主要文件

- `AA整合版本.lsp`：主整合程序。
- `aa-loader.lsp`：优先加载入口。
- `小命令/`：独立、试验性或一次性命令。
- `命令索引.md`：自动生成的命令、文件和行号索引。
- `gen_命令索引.py`：命令索引生成脚本。

## 开发约束

所有 `.lsp` 及 CAD 相关文本文件必须使用 GBK 编码和 CRLF 换行。修改主文件前必须做字节级备份，写入后检查 GBK、CRLF 和括号结构。详细规则见 [`AGENTS.md`](AGENTS.md) 或 [`CLAUDE.md`](CLAUDE.md)。

命令入口有增删或代码行号明显变化后，在项目根目录运行：

```powershell
python gen_命令索引.py
```
