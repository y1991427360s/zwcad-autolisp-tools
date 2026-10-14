# ZWCAD 2026 与 AutoCAD 2018 联动开发

本说明在两个项目的 `docs/DUAL_PLATFORM.md` 中保留完全一致的副本。规则适用于进入任一项目的智能体；更新本说明时必须同步另一份。这里定义后续开发流程，不代表历史代码已全量对齐。

## 项目定位

| 项目 | 本机根目录 | 平台 |
|---|---|---|
| ZW-auto_lisp | `D:\Syncthing\Oracle-Sync\LISP\ZW-auto_lisp` | ZWCAD 2026 |
| AutoCAD2018_lisp | `D:\Syncthing\Oracle-Sync\LISP\AutoCAD2018_lisp` | AutoCAD 2018 |

两边均以 `AA整合版本.lsp` 为主整合文件，并包含 `V6/aicad_aa_loader.lsp`。两边的 `common/` 分别是本项目的构建源，并非自动跨项目共享的目录。换电脑后以当前项目实际位置和同级目录定位，禁止使用旧路径覆盖其他同名项目。

Codex 使用项目 `AGENTS.md`，Claude Code 使用 `CLAUDE.md`。两边同时提供内容一致的 `ANTIGRAVITY.md` 供其他智能体读取；具体客户端是否自动加载该文件需以其实际行为为准。不能自动读取规范的智能体，任务开头须明确要求它读取这些文件和本说明。

## 每次开发的操作顺序

1. 读取两边根目录规范及本说明；按修改范围读取 V6 规范、命令说明和工程化文档。检查各自现有改动及 Git 状态，明确本次需求入口。
2. 列出受影响命令、公共函数、面板/桥接协议和平台适配点。公共功能默认双边实现；单平台限定或专属改动要记录另一版是否需要对应修复。
3. 修改主整合文件前各自做字节级备份。按函数或命令移植，严格处理源、目标编码；不得镜像整个目录或覆盖无关改动。平台接口保留各自实现。
4. 公共纯函数分别先改 `common/aicad_pure.lsp`，再在各自项目运行 `python scripts/sync_common.py --write`；禁止仅修改 Generated 副本。
5. 改动 LISP 后在各自根目录更新命令索引及审计产物，并执行适用检查；检查工具必须按该平台编码读取源码。仅改规范文档时检查内容一致性、编码、路径和链接，无需生成与本次无关的源码产物。
6. 新增差异同步登记本说明。最终分别汇报两版修改和验证状态；涉及 Git 的交付分别确认仓库与远端，按各项目规范保留历史并同步。

LISP 修改后的常用离线入口（在两个项目中分别运行）：

```powershell
python gen_命令索引.py
python scripts/audit_lsp.py --write
python tools/check_all_static.py
python scripts/check_project.py
```

脚本存在不等于适配已完成。出现编码或 SDK 不兼容时先处理本次涉及的适配问题，不得为通过检查把 AutoCAD 2018 源码转成 UTF-8，也不得把一边的通过结果当作另一边的验收结果。

## 已知差异与适配要求

| 范围 | 中望版 | AutoCAD 2018 版 | 处理与证据 |
|---|---|---|---|
| CAD 文本编码 | UTF-8 无 BOM、CRLF | GBK/CP936 无 BOM、CRLF | 各自根规范与 `tools/check_all_static.py` 已明确；文档均为 UTF-8。严格解码后局部移植，禁止字节复制。 |
| LISP 引擎 | 本项目 Unicode 加载约定为 `LISPSYS=1` | 经典引擎，不套用 `LISPSYS=1` 要求 | Autodesk 官方说明 Unicode 支持从 AutoCAD 2021 引入；不得对 2018 使用新版专有 API/参数。中望实际设置仅在明确授权后核对。 |
| .NET 构建 | `V6/build_zwcad_ribbon.ps1`，引用 `ZwManaged.dll`、`ZwDatabaseMgd.dll`、`ZdWindows.dll` | `V6/build_autocad_ribbon.ps1`，引用 `accoremgd.dll`、`acdbmgd.dll`、`acmgd.dll`、`AdWindows.dll` | 已静态核对两边构建脚本。SDK、命名空间、加载器路径分别维护，DLL 不直接跨平台替换；本说明未进行构建或运行验证。 |
| 加载路径 | 指向中望项目及其 V6 | 指向 AutoCAD 项目及其 V6 | 各自核对加载器、配置、支持路径和 `AICADAA_BASEDIR`；不能全局替换为同一路径。实际 CAD 加载路径本次未查询。 |
| 大列表排序 | 项目既有中望性能经验：避免 `vl-sort` 加 lambda | 不从中望经验推断实际性能 | 两版遵守现有 `aa:merge-sort` 规则，ZTF 小列表沿用 `aa:insert-sort`；性能结论分别记录平台与证据。 |
| COM、原生命令与交互 | 依中望对象模型及实际行为适配 | 依 AutoCAD 2018 对象模型及实际行为适配 | 属性/方法预检或捕获异常，保持相同业务结果；包围盒、对齐、原生命令参数、剪贴板、撤销和取消清理分别验证，未经实机验证标记待验证。 |

Unicode 兼容依据：[Autodesk AutoLISP 兼容说明](https://help.autodesk.com/cloudhelp/2027/ENU/AutoCAD-Customization/files/GUID-31FD1A96-C002-434E-8684-63D50BE0CF94.htm)、[Autodesk 开发者文档：Unicode 文本读写](https://blog.autodesk.io/working-with-unicode-text-reading-from-and-writing-to-files/)。

## 当前边界

- 2026-10-14 文档检查时，中望目录是 Git 工作区且存在既有未提交改动；AutoCAD 2018 目录执行 `git status` 提示不是 Git 仓库。此状态需在后续任务中重新检查；不自动初始化仓库或推送到中望远端。
- 当前 AutoCAD 2018 的部分文档来自中望版，不能将历史中望实测记录视为 AutoCAD 2018 实测。根目录与 V6 规范、构建脚本及实际源码是核对入口。
- 本次仅建立联动规则并纠正规范中的直接冲突，未全量比对或同步历史功能，未运行两版 LISP 检查或 CAD 实机验证。

## 新差异的记录格式

每项差异记录：命令/模块、触发条件、中望表现、AutoCAD 表现、各自处理方式、证据（源码位置/离线检查/授权后的实测）、状态（静态确认/实机确认/待验证）。未实现的同步项同时记录原因和下一步。

## 给后续智能体的任务开头

> 本次维护 ZWCAD 2026 与 AutoCAD 2018 两版插件。请先读取两边项目规范及 docs/DUAL_PLATFORM.md，默认同步公共功能，保留各平台编码、SDK 和实现差异，分别完成离线检查并汇报。未经我明确要求，不连接或操作任何 CAD。
