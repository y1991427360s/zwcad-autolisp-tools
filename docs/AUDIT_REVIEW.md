# 审计人工审阅记录

审阅日期：2026-10-02。范围为仓库源码与离线工具；未连接或操作 CAD。

## 已修复的高确定性问题

以下变量仅是函数内部迭代或临时结果，现已加入局部变量表，防止覆盖调用方的同名动态绑定或留下全局值；函数形参、计算流程、命令交互和命令数不变。

| 文件 | 函数 | 新增局部变量 |
| --- | --- | --- |
| AA整合版本.lsp | c:YSDL | row |
| AA整合版本.lsp | txt2:lwpoly-segments | item |
| AA整合版本.lsp | txt2:modify-text | seg |
| AA整合版本.lsp | qw:join | it、r |
| AA整合版本.lsp | hddl:tail-count | rec |
| AA整合版本.lsp | c:TONG | txt |
| V6/aicad_aa_loader.lsp | aicadloader:show-replace-panel | replace-panel-result |
| V6/aicad_extension.lsp | aicad:join | item |
| V6/aicad_extension.lsp | aicad:replace-pairs-preview | pair |
| V6/aicad_extension.lsp | aicad:selection-summary | item |

V6 的路径规范化、非空判断和错误消息三个完全相同的纯函数改由公共模板维护，展开成各自原有命名空间；函数体保持 AST 等价。没有移动运行时加载入口。

原一键检查在 YS1 几何断言通过后强制导入 matplotlib，普通环境会中断。现已将绘图拆为 render_preview，显式 `--preview` 才导入绘图库；默认仍执行原有两组几何、平移和缩放断言，后续 5 项专项检查能够继续执行。

共享解析器改为严格词法读取，补足未关闭字符串、悬空引用、未关闭块注释的诊断；保留原 AST 接口给全部专项检查使用。

## 已核对但不改写的候选

| 发现 | 源码核对 | 处理 |
| --- | --- | --- |
| 两个 V6 顶层 *error* | loader 与 extension 各自恢复不同的环境堆栈；extension 被 loader 加载后会覆盖 loader 的处理器 | 确认存在定义覆盖。暂保留，不能只删一份；需设计命令局部绑定、嵌套加载与 reactor 生命周期的恢复契约。 |
| HDDL 未局部声明 *error* | 自行保存 olderr，正常/错误路径显式赋回；错误路径先 aa:undo-mark-off | 不是“完全未恢复”，但恢复过程中再出错仍有风险；本次不替换其专属逻辑。 |
| aa:cmd-begin / aa:undo-mark-on 未在函数内结束 UNDO | 框架由调用方与 cmd-end / cmd-error / undo-mark-off 成对使用 | 属于拆分接口，不能根据单函数扫描判定泄漏。 |
| c1c2:run、de:run、c:GE、c:BK 的关闭候选 | 分别通过 c1c2:safe-end-undo、de:end-undo、ge:end-undo、de:end-undo 间接关闭；正常路径与专属错误处理均有调用 | 不重复加 EndUndoMark，以免破坏现有撤销。 |
| c:QH 错误恢复候选 | 只计算文字行并更新选择状态，不打开 UNDO 或修改系统变量；局部 *error* 只需打印消息 | 属于宽规则候选，不需要新增恢复函数。 |
| VPO1/VPO2 等 CMDECHO 候选 | aa:cmd-begin 保存值，aa:cmd-end / aa:cmd-error 恢复；因此不在单函数中 getvar/setvar 成对出现 | 保留报告证据，标记为框架恢复。其余变量候选继续逐条追踪。 |
| SS 的 DRAGMODE / CMDECHO | 使用捕获式恢复和命令局部旧值，直接 setvar 规则看不全 | 不因规则漏识别而改写动态预览。 |
| AICAD 基目录跨文件写入 | loader 将已解析目录传给 extension；属于初始化协议 | 不是两个无关模块抢占同一变量。 |
| ge:make-line 的 created、aa:zz-add-seg 的 hlist/vlist 等 | 辅助函数修改调用方动态局部状态，局部化会切断数据流 | 不批量修复所有 implicit-global。 |

## 优先继续追踪的异常路径

1. AICAD apply-* 中一些直接 StartUndoMark/EndUndoMark 只有正常路径配对，外层 safe-apply 捕获异常后只 pop-environment 恢复系统变量。若中途 COM 或图元读取出错，关闭 UNDO 的保证不足。审计用 undo-error-path 标记“存在正常关闭但没有局部错误绑定”的候选，仍必须人工核对外层保证。建议独立设计持有 doc/undo-open 的上下文，并覆盖捕获异常与取消，不在本次全仓整理中替换全部处理函数。
2. 其余 implicit-global 涉及排序比较器、旧图框处理和动态共享缓存。先建立函数输入/输出契约，再逐个判断是否纯内部临时变量。
3. 命令与本机 PGP/CUI、外部插件别名的冲突无法离线完全判断；仓库 LSP/.NET 注册未发现同名命令。短名称 T/H/Y/SS 等部署时仍应核对。
4. nil-selection 当前没有命中所实现的窄规则，不代表所有选择路径安全。参数型选择集依赖调用方校验，COM 句柄失效、ssname 越界和间接返回 nil 仍需后续路径测试。

## 验证证据

`python scripts/check_project.py` 为统一复验入口：解析器/故障检测/公共展开回归、公共源同步、审计产物同步、命令索引同步，以及原有 15 项专项静态检查。整合文件修改前的原始字节保存在忽略的 backups/audit-*/ 中；生成器写 V6 前另保存对应备份。

交付前已实际运行统一入口，9 项基础回归与 15 项专项检查全部通过。与整理前 Git HEAD 的整文件 AST 对比确认：三个运行时 LSP 顶层表达式数量不变，所有函数体不变；只有上述 10 个函数的局部变量表改变。公共展开注释不影响 AST。审计 strict 模式因已保留的全局 *error* 重复定义返回 1，普通检查与文档一致性检查通过。

静态检查成功不证明中文、图纸几何、真实选择集、COM 失败或一次 U 的 CAD 行为已经验收。本次没有重载插件、创建测试图或连接 CAD。
