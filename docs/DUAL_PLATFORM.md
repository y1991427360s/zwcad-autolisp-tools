# ZWCAD 2026 与 AutoCAD 2018 联动开发

本说明在两个项目的 `docs/DUAL_PLATFORM.md` 中保留完全一致的副本。规则适用于进入任一项目的智能体；更新本说明时必须同步另一份。这里定义后续开发流程，不代表历史代码已全量对齐。

## 项目定位

| 项目 | 本机根目录 | 平台 |
|---|---|---|
| ZW-auto_lisp | `D:\Syncthing\Oracle-Sync\LISP\ZW-auto_lisp` | ZWCAD 2026 |
| AutoCAD2018_lisp | `D:\Syncthing\Oracle-Sync\LISP\AutoCAD2018_lisp` | AutoCAD 2018 |

两边均以 `AA整合版本.lsp` 为主整合文件，并包含 `V6/aicad_aa_loader.lsp`。两边的 `common/` 分别是本项目的构建源，并非自动跨项目共享的目录。换电脑后以当前项目实际位置和同级目录定位，禁止使用旧路径覆盖其他同名项目。

Codex 使用项目 `AGENTS.md`，Claude Code 使用 `CLAUDE.md`。两边同时提供内容一致的 `ANTIGRAVITY.md` 供其他智能体读取；具体客户端是否自动加载该文件需以其实际行为为准。不能自动读取规范的智能体，任务开头须明确要求它读取这些文件和本说明。

## 开发优先级与延后同步

中望 CAD 2026 的开发和交付优先。默认先完成中望功能，AutoCAD 2018 可以保留旧实现，待用户明确提出更新或同步时再补齐；不要自动移植、后台同步或设置定时任务，也不要因 AutoCAD 未更新阻塞中望交付。用户指定开发 AutoCAD 或双边同步时按指定范围执行。

每次中望功能更新完成后，在 [同步台账](PLATFORM_SYNC_LOG.md) 记录北京时间（UTC+08:00，含时分秒）、受影响命令/模块、改动摘要、来源提交或文件 SHA-256、验证结果、AutoCAD 状态及适配注意事项。台账两份保持一致；这只是记录同步，不代表 AutoCAD 代码已更新。

用户以后要求同步 AutoCAD 时，先读取台账和最新中望源码，按依赖核对待同步项；同一命令的多次修改以最新实现为准，保留历史记录。完成移植及适用检查后记录 AutoCAD 完成时间、验证结果和对应来源；不适用的项写明原因，不得静默删除。

## 每次开发的操作顺序

1. 读取两边根目录规范及本说明；按修改范围读取 V6 规范、命令说明和工程化文档。检查各自现有改动及 Git 状态，明确本次需求入口。
2. 列出受影响命令、公共函数、面板/桥接协议和平台适配点。默认先实现中望版，列出需要延后同步到 AutoCAD 的公共功能与适配点；单平台专属改动记录不适用原因。
3. 修改主整合文件前对本次实际修改的平台做字节级备份。按函数或命令移植，严格处理源、目标编码；不得镜像整个目录或覆盖无关改动。平台接口保留各自实现。
4. 本次实际修改的平台，公共纯函数先改 `common/aicad_pure.lsp`，再在各自项目运行 `python scripts/sync_common.py --write`；禁止仅修改 Generated 副本。
5. 改动 LISP 后在本次实际修改的平台根目录更新命令索引及审计产物，并执行适用检查；检查工具必须按该平台编码读取源码。仅改规范文档时检查内容一致性、编码、路径和链接，无需生成与本次无关的源码产物。
6. 新增差异同步登记本说明；中望功能完成时更新同步台账。最终汇报本次完成的平台与验证结果，以及 AutoCAD 的待同步/已同步/不适用状态；涉及 Git 的交付分别确认仓库与远端，按各项目规范保留历史并同步。

LISP 修改后的常用离线入口（在本次实际修改的平台中运行；补齐另一版时再执行其检查）：

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

- 2026-10-14 文档检查时，中望目录是 Git 工作区且存在既有未提交改动；AutoCAD 2018 目录执行 `git status` 提示不是 Git 仓库。2026-10-19 起 AutoCAD 2018 目录已是独立 Git 仓库，远端 `origin` 为私有仓库 https://github.com/y1991427360s/autocad2018-autolisp-tools ，默认分支 `main`；两版仓库各自提交推送，不互推远端。
- 当前 AutoCAD 2018 的部分文档来自中望版，不能将历史中望实测记录视为 AutoCAD 2018 实测。根目录与 V6 规范、构建脚本及实际源码是核对入口。
- 本次仅建立联动规则并纠正规范中的直接冲突，未全量比对或同步历史功能，未运行两版 LISP 检查或 CAD 实机验证。

## 新差异的记录格式

每项差异记录：命令/模块、触发条件、中望表现、AutoCAD 表现、各自处理方式、证据（源码位置/离线检查/授权后的实测）、状态（静态确认/实机确认/待验证）。未实现的同步项在同步台账记录原因和下一步。

## 给后续智能体的任务开头

> 本次维护 ZWCAD 2026 与 AutoCAD 2018 两版插件。请先读取两边项目规范及 docs/DUAL_PLATFORM.md，默认优先交付中望版，把完成时间和 AutoCAD 待同步项写入 docs/PLATFORM_SYNC_LOG.md，待我要求时再补齐 AutoCAD。保留各平台编码、SDK 和实现差异，对实际修改的平台完成离线检查并汇报。未经我明确要求，不连接或操作任何 CAD。

## 2026-10-15 补齐后的静态差异记录

- 核对时间：2026-10-15 08:19:17 +08:00，证据见同步台账本次补齐记录及 AutoCAD `backups/platform-sync-20261015-081638/sync-verification.json`。
- 主整合文件业务函数已对齐，保留 `ztf:run-dialog` 平台提示及 `*ztf-project-dir*` 路径；CP936 与 UTF-8 的编码约定分别保持，实际中文显示未做 CAD 验证。
- V6 无待移植业务差异：加载路径、AutoCAD 专用 `LOADAICADACAD` 别名、Autodesk/ZwSoft 命名空间和 Application 别名均保留；AutoCAD 窗口管理器现有实现发现 acad 与 ZWCAD 两类进程，中望仅发现 ZWCAD。上述为源码静态确认，不代表窗口交互实机确认。
- ZDDL 独立模块与整合模块业务 AST 一致；两版均保留独立/整合同名定义，当前严格审计产生 23 项重复定义告警，全仓单元测试 24/25 通过。27 项命令专项与整文件解析通过；不将专项通过表述为严格全仓通过。

## 2026-10-15 AutoLISP 实数字面量兼容检查

- 范围：AutoCAD 主文件 YS1 几何代码及入口，加载时报“输入中的点位置不正确”。
- 静态证据：原文件第 378 行起含 247 个省略前导零的小数；AutoCAD 分支离线解析器原把 `.86` 当普通符号，未能阻止加载错误。
- 处理：仅 AutoCAD 源码补齐前导零，保持 GBK/CP936、CRLF；其解析器和回归同步加强。中望源码本次未改；不推断中望是否接受原写法，运行差异待验证。
- 依据：[Autodesk 实数语法](https://help.autodesk.com/cloudhelp/2020/ENU/AutoCAD-AutoLISP/files/GUID-F2BFD097-295B-4499-BBD9-0A785C377070.htm) 明确 -1 到 1 之间的小数必须包含前导零。修复已静态确认，未做 CAD 实机验证。

## 2026-10-15 AutoCAD 9 / 99 的 COM 对象转换

- 用户运行报 `VLAX-ENAME->VLA-OBJECT` 未定义；静态确认入口已有 `vl-load-com`，会话函数缺失原因尚未确定，不能写成 AutoCAD 2018 不支持该函数。
- AutoCAD 共用旋转函数改用当前 Document 的 HandleToObject，以 DXF 5 句柄取得对象并捕获错误；失败时整批不旋转。该方法有 AutoCAD 2018 官方文档依据。
- 中望版保留既有实现；只确认源码差异，未做任一 CAD 实机验证。

## 2026-10-15 AutoCAD 9 / 99 直接对象旋转与 ZDDL 单一实现

- 用户日志显示原 ROTATE 交互未收齐参数且旧代码提前报告成功；精确的输入拒绝原因未做 CAD 查询。AutoCAD 旋转实现改用 Rotate3D，显式 WCS 三维轴点和弧度，沿当前 UCS 的 Z 轴旋转。静态与模拟验证通过，运行效果待用户实机验收；不得把该日志推断为中望同样失败。
- AutoCAD ZDDL 旧独立文件改为兼容加载入口，主整合文件保留唯一业务定义；中望暂保留原独立/整合双份实现，本次不修改其代码。AutoCAD 严格审计的 23 项重复定义已消除。
- 官方接口依据：[AutoCAD 2018 Rotate3D](https://help.autodesk.com/cloudhelp/2018/ENU/AutoCAD-ActiveX-Reference/files/GUID-1057C914-CB4F-43C9-841F-F80207D9398E.htm)。采用标准 ActiveX 对象方法，当前仅做离线验证。

## 2026-10-15 AutoCAD XY / XYG 文字包围盒对象转换

- 用户反馈：XYG 识别 8 条绿色直线并完成 XIN 后，报告 `VLAX-ENAME->VLA-OBJECT` 未定义。静态调用链定位到 `xy:get-text-bbox`；文件顶层已有 COM 初始化，当前会话函数缺失的具体原因未确定，不推断为 AutoCAD 2018 不支持该接口。
- AutoCAD 处理：共用文字包围盒函数在受保护路径中初始化 COM，通过当前 Document 的 `HandleToObject` 取得对象；对象转换、精确包围盒及数组读取统一捕获，已取得对象统一释放。失败时沿用 TEXT 的 textbox 与其余文字的估算回退。
- 影响范围：所有复用 `xy:get-text-bbox` 的 XY / XYG 文字查询。中望插件代码保留既有实现；只同步兼容记录与台账。新增离线回归执行实际交付函数 AST，覆盖无需 ename 转换函数的精确包围盒及各阶段失败路径，未进行 CAD 实机验证。

## 2026-10-15 AutoCAD XYG 批量文字空间索引

- 依据：用户确认前次 XYG 修复能够完成目的，但反馈执行较慢。源码确认旧矩形文字查询逐横线扫描整个选区，对每个小字重复读取 COM 包围盒，命中后再次读取。
- AutoCAD 处理：一次命令采集原选区文字精确包围盒、纯文本及原序号，构建带子树范围的平衡包围盒树；新生成文字按原插入点规则建立独立索引。索引均为 `c:XYG` 局部变量，查询后恢复原序号，保留等 X 候选顺序、选区优先、少于 3 字才窗口补查、右侧连续间距与芯数截断。共用文字包围盒优先借用 `aa:doc`，独立调用仍初始化 COM；不保留跨命令缓存或新增持久 COM 引用。
- 另外缓存横线排序/邻线几何；竖线桶改成唯一键，保留桶内原逆序优先级。空间窗口与视口外补查逻辑不改。中望插件代码本次未改，仅同步本说明与台账。
- 验证：离线执行实际新旧 LISP AST，995 对象/8 行构造场景的矩形提取包围盒请求从 6816 次降到 800 次，输出相同；此为请求量对比，不是 CAD 运行时间或实机倍速。随机几何、边界接触、长文字、缺选补查、同 X 顺序、同排多列、异常横线延伸、取消插入点均做回归；实图性能待用户重载验收。

## 2026-10-15 AutoCAD QW3 共用包围盒转换

- 用户反馈 QW3 报 `VLAX-ENAME->VLA-OBJECT` 未定义；静态调用链为 `aa:qw3-record` → `aa:safe-get-bbox`，命令入口已有 COM 初始化，会话缺失原因仍待确认。
- AutoCAD 共用包围盒改用 Document.HandleToObject，捕获转换及读取异常、统一释放对象，保留更新与重生成重试；QW3 传入当前命令文档，失败时继续导出 DXF 信息。此共用函数的其他调用方一并采用句柄转换。中望源码未改，未进行任一 CAD 实机验证。

## 2026-10-17 AutoCAD 2018 的 open 无编码参数（ZDDL2）

- 适用范围：ZDDL2 的临时输入/输出文件。中望版用 `(open path mode "utf8")`；AutoCAD 2018 的 AutoLISP `open` 官方签名只有文件名与模式，未确认支持编码参数，故按保守处理，不使用。
- 处理：AutoCAD 版读写系统 ANSI（中文 Windows 为 GBK/CP936），`tools/zddl2_bridge.py` 按 gbk 严格读写，GBK 无法表示的字符明确报错而非替换；面板写回同样 CP936 严格编码。
- 验证状态：仅离线测试（含 GBK 往返）；未在 AutoCAD 2018 实机验证，不得写成已验证事实。

## 2026-10-17 ZDDL2 字符单位差异（两版）

- 中望版（ZWCAD 2026，Unicode）：字符串以字符为单位，`strlen`/`substr` 直接按字符计算；汉字宽度判断用码位 ≥ 0x2E80；端子排名称汉字范围 U+4E00–U+9FA5。
- AutoCAD 2018 版（GBK 字节）：字符串按字节计算，汉字占 2 字节，需先按双字节切分再逐字处理。
- 两版 ZDDL2 的解析与布局规则相同，均与 `tools/zddl2_engine.py` 一致；离线对照已分别通过。依据：两版 LISP 运行时的字符串语义不同（LISPSYS 与经典引擎）。
- 状态：静态与离线对照已验证；实机未验证。

## 2026-10-18 09:22:03 XY 连接容差修复后的待同步差异

- 范围：`xy:make-vrec-if-valid-fast` 的端点连接及横线区间判断。中望恢复使用传入的 `tol`（当前 0.0001），与 2026-10-15 台账要求一致；AutoCAD 当前仍使用 `*xy-conn-tol*`（0.05）。
- 证据：任务前中望实际 AST 把 Y 间隙 0.001 和 X 越界 0.01 的候选计入；修复后 XY 专项全部通过。AutoCAD 源码静态读取确认仍有上述宽容差，本次授权仅移植 QR/QR2，未修改其 XY。
- 处理与状态：中望已修复、AutoCAD XY 待另行授权同步；仅源码及离线证据，未连接 CAD，不推断两版实机表现。QR/QR2 共用相同函数逻辑，保留 UTF-8/CP936 编码及各自 `aa:cmd-begin` 平台适配。

## 2026-10-18 10:28:43 XY 连接容差恢复 0.05（上一条差异已消除）

- 范围：`xy:make-vrec-if-valid-fast` 的端点连接及横线区间判断。用户决定恢复 2026-10-17 新增的 `*xy-conn-tol*`（0.05），撤销 09:22:03 那次改回 `tol`（0.0001）的修复。
- 现状：中望与 AutoCAD 都使用 `*xy-conn-tol*` = 0.05，两版行为一致，上一条“XY 连接容差修复后的待同步差异”不再需要同步。去重与芯线倾斜判断仍用 `*xy-geom-tol*`（0.0001）。
- 证据与状态：仅为源码及离线检查（`check_xy_static.py`），未连接 CAD，实机效果未验证。

## 2026-10-19 文字联动值文件编码（SX1 / SX2）

- 适用范围：文字联动 `aa:link-open`（SX1 导出、SX2 读取 `<图名>.aalink.txt`）。
- 差异：中望版 `(open path mode "utf8")`，值文件为 UTF-8；AutoCAD 2018 的 `open` 无编码参数（同 ZDDL2 一节），AutoCAD 版改为两参数 `open`，按系统 ANSI（GBK/CP936）读写。其余联动函数两版 AST 一致。
- 影响：同一平台内导出与读取一致；跨平台混用值文件（AutoCAD 总图读中望卷册图的文件或反之）时中文会乱码，文档已提示勿混用。
- 证据与验证：源码比对与离线 `tools/check_link_static.py`（AutoCAD 版断言两参数 open）；均未实机验证。
- XYG 接入方式：AutoCAD 保留自有 XYG 索引（2026-10-15），仅在 `xyg:find-rect-texts` / `xyg:find-right-new-texts` 返回前写入 `*xyg-rect-src*` / `*xyg-right-src*`，`c:XYG` 按中望方式组装 (文字 . AA_LINK)；中望 10-17 的 XYG 索引重写未移植。

## 2026-10-19 AutoCAD 2018 字符串按 GBK 字节计数（DB / DF）

- 适用范围：AutoCAD 版按“字符个数”截取文字的命令，本次为 DB / DF（`db:del`）。
- 差异：AutoCAD 2018 经典 AutoLISP 的 `strlen` / `substr` 按 GBK 字节计数（同 ZDDL2 字符单位一节）；中望 LISPSYS=1 按 Unicode 字符计数。
- 处理：AutoCAD 版新增 `aa:gbk-chars` 先按字符切分再删除；中望保持原实现。
- 证据与验证：用户实机反馈 DB 结果错误；离线字节模型测试 `tests/test_db_gbk.py` 复现旧问题并验证修复，修复后未实机验证。

## 2026-10-19 字符串位置函数单位不一致（QE）

- 适用范围：用 `vl-string-search` 返回的位置再交给 `substr` 截取的代码，本次为 `c:QE` 的“至”前缀。
- 差异：中望 LISPSYS=1 的 `strlen`/`substr` 按 Unicode 字符计数；AutoCAD 2018 按 GBK 字节计数且字节搜索可能跨字符误命中。`vl-string-search` 返回值的单位两版均未实机测定，不应与 `substr` 混用。
- 处理：两版改为同一套函数逐字符扫描（中望 `substr` 逐字，AutoCAD `aa:gbk-chars`）。
- 证据与验证：用户实机反馈两版含中文时替换异常；离线字节模型推演，修复后未实机验证。
- 2026-10-19 补充：QE 随后改为整段替换，不再截取“至”前缀，`qe:zhi-prefix` 已删除；上述单位差异仍适用于其他混用 `vl-string-search` 与 `substr` 的代码。
- 2026-10-19 再补充：用户确认保留“至”前缀规则，QE 已恢复 `qe:zhi-prefix` 逐字查找实现，上一行“已删除”作废。

## 2026-10-19 CC / C1 / C2 / C3 拖动前隐藏副本（redraw 模式 2）

- 适用范围：CC（`c:CC`）与 C1/C2/C3（`c1c2:place-one`）把副本交给原生 MOVE 前的显示处理。
- 差异：中望版用 `(redraw 副本 2)` 隐藏原位静态显示，原生拖动影像正常；AutoCAD 2018 用户反馈同样写法下没有实时预览，判断为拖动影像依赖屏幕显示、随隐藏一起消失（推测，未实机确认）。
- 处理：AutoCAD 版删除隐藏与恢复的两处 `redraw`，副本拖动期间在原位保持可见；中望版保持原实现。AutoCAD 的 `check_cc_static.py`、`check_c1c2_static.py` 改为断言不得隐藏副本。
- 验证状态：仅离线结构检查；AutoCAD 实时预览待用户重载验收。

## 2026-10-19 AutoCAD 2018 用 = / /= 比较图元名恒为“不相等”（已实机验证）

- 适用范围：所有用 `=` 或 `/=` 判断两个图元名是否同一对象的代码，例如从选择集中排除自身。
- 差异：AutoCAD 2018 实测，同一对象分别由 `handent` 或两次 `ssname` 取得的图元名，`(= a b)` 为 nil、`(/= a b)` 为 T，只有 `eq` / `equal` 返回 T；即使同一变量两次求值 `(= e e)` 为 T，也不能依赖。中望中相同写法可正确比较（AW 在中望表现正常为旁证）。
- 处理：AutoCAD 版图元名比较一律用 `eq`（`member`、`assoc` 基于 equal，不受影响）。本次改了 `aw:neighbors`（导致 AW 不排除自身）与 `c:XYG` 邻线查找；中望源码不改，但后续两版新代码比较图元名都应使用 `eq`。
- 证据：2026-10-19 经用户授权连接 AutoCAD 2018，对图纸中文字 4DC356 实测上述四种比较的返回值；修复前 AW 邻近对象列表含自身外框，修复后不含。

## 2026-10-19 AutoCAD 2018 未加引号的 lambda（HAO2）

- 适用范围：直接写 `(mapcar (lambda ...) lst)` 等未加引号的 lambda，本次所见为带局部变量的 `(lambda (b / p) ...)`。
- 差异：AutoCAD 2018 用户实机执行 HAO2 报“函数错误: #<SUBR @... -lambda->”；同一代码在中望正常。全文件仅此一处未加引号的 lambda，其余写成 `'(lambda ...)` 的比较器在 AutoCAD 中正常（XYG、GTY 等）。是“未加引号”还是“带局部变量”触发，未单独实测区分。
- 处理：AutoCAD 版 `hao2:sort-blocks` 改为 foreach；新增 `tests/test_autocad_compat.py` 禁止 AutoCAD 主文件出现未加引号的 lambda。中望不改。
- 验证状态：报错为用户实机现象；修复仅离线检查，待用户重载验收。

## 2026-10-19 本机 AutoCAD 2018（22.0s）无 LISP 反应器、命令中拒绝 COM、.NET 写注册表不可见（已实机验证）

- 适用范围：需要监听命令开始/结束的功能（如输入法自动切换信号），以及外部程序通过 COM 读 CAD 状态。
- 差异：`(atoms-family 1)` 中没有任何 `VLR-*` 函数，`(vl-load-reactors)` 后仍为 nil，`vlr-command-reactor` 报 no function definition；命令运行中外部 COM 调用返回 `RPC_E_CALL_REJECTED`；.NET 插件用 `Microsoft.Win32.Registry` 写 HKCU 不报错，但注册表中找不到写入结果（同进程 LISP `vl-registry-write` 可见）。.NET 的 Document 命令事件与文件写入正常。中望未测。
- 处理：AutoCAD 版不要使用 `vlr-*` 反应器；命令事件改用 .NET 插件（`tools/CadImeSignal`），信号经文件传递。
- 证据：2026-10-19 经用户授权连接 AutoCAD 2018，用诊断 LISP 与诊断 DLL 的日志实测上述现象。

## 2026-10-22 DEH 中文判定（GBK 字节 vs Unicode 码位）

- 适用范围：`DEH` 的 `aa:has-chinese`。
- 中望版：按 Unicode 码位 0x2E80..0x9FFF（兼容 UTF-8 字节 E4..E9）判定，CJK 标点（、。〇）与假名也算中文。
- AutoCAD 2018 版：`vl-string->list` 返回 GBK 字节，按双字节逐字判断，只认 GBK 汉字区（首字节 129..160、176..247；170..175、248..254 且尾字节 64..160）；符号区 161..169（全角标点、×、°、〇、假名）不算中文。两版都识别 `U+XXXX` 转义，×、全角逗号/括号都不算中文。
- 影响：只含 CJK 标点或假名、不含汉字的文字，两版结果可能不同；含汉字的文字两版一致。
- 证据与状态：源码静态比对及 AutoCAD `tests/test_deh_gbk.py`（真实 AST + GBK 字节模拟）；两版均未实机验证。

## 2026-10-22 命令别名面板（ZWCAD.pgp / acad.pgp）

- 适用范围：两版各自的命令别名设置面板（`tools/alias_pgp.py`、`tools/alias_panel.py`）与主表 `config/aliases.csv`。
- PGP 位置：中望 `%AppData%\ZWSOFT\ZWCAD\2026\zh-CN\Support\ZWCAD.pgp`；AutoCAD `%AppData%\Autodesk\AutoCAD 2018\R22.0\chs\Support\acad.pgp`。
- 默认区/用户区分界：中望按文件末尾往前第一个空行；acad.pgp 末尾有 `-- User Defined Command Aliases --` 说明段，以含 `DO NOT REMOVE` 的行结尾，AutoCAD 版以最后一个这样的行为分界，找不到时退回空行规则。
- 托管区块标记分别为 `ZW-auto_lisp aliases` 与 `AutoCAD2018_lisp aliases`；两版主表各自独立，互不同步。默认别名不同（例如 acad.pgp 默认 R→REDRAW），同一主表放到另一平台可能产生不同的覆盖提示。
- 证据与状态：本机 acad.pgp 只读解析（UTF-8 带 BOM、CRLF、540 行）与离线测试；未实机验证 REINIT 生效。

## 2026-10-26 文件读写编码差异与结果卡片（ANSI/GBK vs UTF-8）

- 适用范围：`aa:rep-*`（结果卡片）、`bh:log-*`（电缆编号历史记录）、`c:HWT`（环网图电缆清单导出）等文件读写函数。
- 中望版：`open` 支持三参数 `(open path mode "utf8")`，以 UTF-8 编码读写外部临时文件与记录文件。
- AutoCAD 2018 版：`open` 仅支持两参数 `(open path mode)`，按当前操作系统 ANSI/GBK 编码读写文件；官方签名未确认支持编码参数，保守不传 `"utf8"`（未实机测定传入后的表现）。
- 外部集成适配：AutoCAD 版的 `report.txt` 以 GBK 编码输出，外部 AHK 脚本 `cad-report-card.ahk` 自 2026-10-26 22:24:03 起自动识别编码：合法 UTF-8 按 UTF-8 解码，否则按 CP936 解码，两版共用同一结果文件路径和格式（冒烟测试覆盖 UTF-8 / GBK 两种写盘）。电缆记录文件（`cables.tsv`）在 AutoCAD 版同样使用 GBK 格式存储。
- 证据与状态：AutoCAD 静态 AST 分析及 `check_bh_static.py` 场景 22 检验通过；未做 CAD 实机验证。

## 2026-10-26 C1 / C2 / C3 原生 MOVE 拖动预览（隐藏静态副本差异）

- 适用范围：`c1c2:place-one` 原生拖动预览逻辑。
- 中望版：在调用 `(command "_.MOVE" ...)` 之后，调用 `(redraw copy-obj 2)` 隐藏静态副本，原生拖动影像仍能正常跟随鼠标，结束后再 `(redraw copy-obj 1)` 恢复。
- AutoCAD 2018 版：若在 `MOVE` 之后调用 `(redraw copy-obj 2)`，AutoCAD 会将拖动中的动态影像连同原实体一同隐去，导致用户在拖动过程中看不到实时预览。因此 AutoCAD 版不得隐藏静态副本，保持原位可见，与 AutoCAD 原生 MOVE 拖动行为一致。
- 证据与状态：`tools/check_c1c2_static.py` 静态断言显式约束；未做 CAD 实机验证。

## 2026-10-26 字符截取与全角符号字节语义（动态步长适配）

- 适用范围：`aa:num-target-span`（NU / C1 / C2 / C3 数字目标提取）、`aa:str-replace-all`、`jm:` 截面匹配等字符串分析函数。
- 差异：AutoCAD 2018 的 AutoLISP 运行在 GBK 字节语义下，全角字符如 `＃`（0xA3 0xA3）和 `－`（0xA3 0xAD）的 `strlen` 返回 2，`substr` 按字节偏移切片；而纯 Python 解释器或中望环境字符语义下返回 1。
- 处理：源码中涉及全角字符跳步和切片时，一律使用 `(strlen "－")`、`(strlen "＃")` 动态获取步长，禁止硬编码步长为 1 或 2，确保在 GBK 实机与 Python 离线模拟测试中逻辑完全一致。
- 证据与状态：`tools/check_nu_c1c2_target_static.py` 全量 650 项断言（含 39 个复杂全角字符边界用例）全部通过。
