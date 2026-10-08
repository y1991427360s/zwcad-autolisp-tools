# 工程化与静态检查

## 项目入口

- `AA整合版本.lsp`：自包含的 133 个命令。
- `V6/aicad_aa_loader.lsp`：3 个加载/面板命令，加载 V6 extension 与 DLL。
- `V6/aicad_extension.lsp`：10 个 AICAD 命令。
- `common/`：构建时公共源，不新增 CAD 启动加载项。
- `scripts/`：仓库审计、公共源同步与一键检查入口。
- `tests/`：Python 标准库 unittest，覆盖解析器、故障检测与生成器。
- `tools/`：保留原有命令专项检查，避免搬移破坏调用路径。
- `COMMANDS.md`、`PROJECT_AUDIT.md`、`docs/lsp-audit.json`：可重复生成的源码清单和审计证据。

无需安装第三方包即可执行静态检查。Python 3.10+；matplotlib 仅用于可选 YS1 预览。

## 日常流程

修改 LISP 前做字节级备份，保存为 UTF-8 无 BOM、CRLF。公共纯函数修改只编辑模板，然后展开：

```powershell
python scripts/sync_common.py --write
python gen_命令索引.py
python scripts/audit_lsp.py --write
python scripts/check_project.py
```

`check_project.py` 顺序执行 9 项基础回归、公共展开一致性、审计产物一致性、两份命令索引检查、18 项命令专项检查。只读检查不连接 CAD、不生成预览图，不改变图纸或启动项。

单独运行：

```powershell
python -m unittest discover -s tests -v
python scripts/audit_lsp.py
python scripts/audit_lsp.py --check
python scripts/audit_lsp.py --check --strict
python tools/check_ys1_static.py --preview
```

无参数 audit 只扫描并输出计数；`--write` 生成文档；`--check` 发现产物过期时返回非零；`--strict` 另将确定的结构发现作为失败。本仓库保留的全局 `*error*` 重复定义会使 strict 返回 1，这是已记录的存量问题，不代表语法失败。

## 文档解释

命令功能来自原有命令清单与临近注释。形参来自解析后的参数表，交互输入来自静态可达函数；完整提示语、直接/间接依赖及外部文件保存在 JSON。对象类型是候选范围，包含读取对象与 STYLE 表记录；不能把它当成精确修改清单。

审计扫描所有 `.lsp`/`.LSP`，排除 Git、备份和依赖目录；公共模板也参与编码和解析检查。函数名和命令名大小写归一。列表解析区分字符串、转义、单行/块注释与引用，携带源文件行号。命令入口必须位于顶层。

静态分析不解释动态 `eval`、字符串中的 action_tile 回调或计算得到的函数名，不证明取消、COM 失败、文件写入失败或 native command 的每条路径可恢复。系统变量与 UNDO 的存在性检查只能产生候选，必须结合人工追踪和用户授权后的 CAD 验证。详见 [审阅记录](AUDIT_REVIEW.md)。

## 新人先读

先读根目录 AGENTS.md、README.md，再按命令查 COMMANDS.md / 命令索引.md；修改 V6 时还需遵守 V6/AGENTS.md。不得恢复已卸载的 CADTools/YS-Tools。Git 交付使用 main，保留历史，不强推。
