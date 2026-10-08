# PROJECT_AUDIT

> 自动生成，可用 `python scripts/audit_lsp.py --check` 检查是否过期。扫描结果与源码绑定，不包含 CAD 实机验收。

扫描 4 个 LSP、744 个顶层函数、144 个命令入口。

## 文件清单

| 文件 | 字节 | 顶层表达式 | 函数 | 命令 |
| --- | ---: | ---: | ---: | ---: |
| AA整合版本.lsp | 639048 | 691 | 605 | 131 |
| common/aicad_pure.lsp | 483 | 3 | 3 | 0 |
| V6/aicad_aa_loader.lsp | 9584 | 32 | 24 | 3 |
| V6/aicad_extension.lsp | 60691 | 142 | 112 | 10 |

## 检查结论与边界

- 编码、无 BOM、CRLF、整文件表达式解析：所有扫描文件通过，否则生成器直接失败。
- 重复函数/命令：大小写归一后的顶层定义与 .NET CommandMethod 注册；不读取本机 PGP、CUI 或第三方工具，短命令别名仍需部署时核对。
- 全局变量：枚举 setq / foreach / 常量 set 写入；跨文件写入不等于缺陷，AICAD 基目录是共享协议。动态作用域与计算得到的 set 名称不作自动修复。
- UNDO：检查直接/引用函数调用和专属错误处理的关闭证据，并列出原生命令；只证明出现过关闭调用，不能证明每条异常路径都能关闭。
- 错误处理与系统变量：检查局部绑定、恢复调用和快照；持久设置、调用方保存和间接恢复必须人工分类。
- nil/选择集：标记直接消费可取消输入的危险形式；不做完整控制流/类型推断，不能保证其他路径无 nil。
- review 是待核查候选，不是确认运行时故障；error 是确定的重复注册/定义或嵌套命令结构事实。

## 分类计数

| 规则 | 数量 |
| --- | ---: |
| duplicate-function | 1 |
| shared-global | 1 |
| command-conflict | 0 |
| nested-command | 0 |
| undo-close | 6 |
| undo-error-path | 6 |
| native-undo | 0 |
| error-binding | 3 |
| error-cleanup | 4 |
| sysvar-restore | 10 |
| nil-selection | 0 |
| implicit-global | 58 |

## 发现清单

| 级别 | 检查 | 文件:行 | 函数 / 变量 | 证据 |
| --- | --- | --- | --- | --- |
| error | duplicate-function | V6/aicad_aa_loader.lsp:72 | *error* | 同名顶层定义: V6/aicad_aa_loader.lsp:72, V6/aicad_extension.lsp:236 |
| review | error-binding | AA整合版本.lsp:595 | aa:cmd-begin | *error* 赋值未局部声明；可能为动态作用域框架 |
| review | error-binding | AA整合版本.lsp:15770 | c:hddl | *error* 赋值未局部声明；可能为动态作用域框架 |
| review | error-binding | AA整合版本.lsp:15770 | c:hddl | 局部错误处理定义缺少 *error* 局部绑定 |
| review | error-cleanup | AA整合版本.lsp:13821 | de:run | 专属 *error* 未见标准恢复调用；需核对间接清理 |
| review | error-cleanup | AA整合版本.lsp:13954 | c:ge | 专属 *error* 未见标准恢复调用；需核对间接清理 |
| review | error-cleanup | AA整合版本.lsp:15343 | c:qh | 专属 *error* 未见标准恢复调用；需核对间接清理 |
| review | error-cleanup | AA整合版本.lsp:15524 | c:bk | 专属 *error* 未见标准恢复调用；需核对间接清理 |
| review | implicit-global | AA整合版本.lsp:2043 | c:h | 写入未声明变量 item；动态调用方局部绑定需人工确认 |
| review | implicit-global | AA整合版本.lsp:2043 | c:h | 写入未声明变量 row；动态调用方局部绑定需人工确认 |
| review | implicit-global | AA整合版本.lsp:2174 | c:h2 | 写入未声明变量 item；动态调用方局部绑定需人工确认 |
| review | implicit-global | AA整合版本.lsp:2174 | c:h2 | 写入未声明变量 row；动态调用方局部绑定需人工确认 |
| review | implicit-global | AA整合版本.lsp:3010 | c:hp | 写入未声明变量 col；动态调用方局部绑定需人工确认 |
| review | implicit-global | AA整合版本.lsp:3153 | c:hp2 | 写入未声明变量 col；动态调用方局部绑定需人工确认 |
| review | implicit-global | AA整合版本.lsp:3692 | c:he | 写入未声明变量 h；动态调用方局部绑定需人工确认 |
| review | implicit-global | AA整合版本.lsp:3692 | c:he | 写入未声明变量 item；动态调用方局部绑定需人工确认 |
| review | implicit-global | AA整合版本.lsp:3692 | c:he | 写入未声明变量 p1；动态调用方局部绑定需人工确认 |
| review | implicit-global | AA整合版本.lsp:3692 | c:he | 写入未声明变量 p2；动态调用方局部绑定需人工确认 |
| review | implicit-global | AA整合版本.lsp:3692 | c:he | 写入未声明变量 x1；动态调用方局部绑定需人工确认 |
| review | implicit-global | AA整合版本.lsp:3692 | c:he | 写入未声明变量 x2；动态调用方局部绑定需人工确认 |
| review | implicit-global | AA整合版本.lsp:3692 | c:he | 写入未声明变量 y1；动态调用方局部绑定需人工确认 |
| review | implicit-global | AA整合版本.lsp:3692 | c:he | 写入未声明变量 y2；动态调用方局部绑定需人工确认 |
| review | implicit-global | AA整合版本.lsp:4263 | aa:ss-get-entity-pts | 写入未声明变量 pair；动态调用方局部绑定需人工确认 |
| review | implicit-global | AA整合版本.lsp:5142 | aa:gty-update-nth | 写入未声明变量 itm；动态调用方局部绑定需人工确认 |
| review | implicit-global | AA整合版本.lsp:5352 | c:gtz | 写入未声明变量 r；动态调用方局部绑定需人工确认 |
| review | implicit-global | AA整合版本.lsp:8372 | is-frame-block | 写入未声明变量 att；动态调用方局部绑定需人工确认 |
| review | implicit-global | AA整合版本.lsp:8406 | sort-frames-by-position | 写入未声明变量 pa；动态调用方局部绑定需人工确认 |
| review | implicit-global | AA整合版本.lsp:8406 | sort-frames-by-position | 写入未声明变量 pb；动态调用方局部绑定需人工确认 |
| review | implicit-global | AA整合版本.lsp:8406 | sort-frames-by-position | 写入未声明变量 xa；动态调用方局部绑定需人工确认 |
| review | implicit-global | AA整合版本.lsp:8406 | sort-frames-by-position | 写入未声明变量 xb；动态调用方局部绑定需人工确认 |
| review | implicit-global | AA整合版本.lsp:8406 | sort-frames-by-position | 写入未声明变量 ya；动态调用方局部绑定需人工确认 |
| review | implicit-global | AA整合版本.lsp:8406 | sort-frames-by-position | 写入未声明变量 yb；动态调用方局部绑定需人工确认 |
| review | implicit-global | AA整合版本.lsp:8430 | find-att-by-keywords | 写入未声明变量 att；动态调用方局部绑定需人工确认 |
| review | implicit-global | AA整合版本.lsp:8430 | find-att-by-keywords | 写入未声明变量 kw；动态调用方局部绑定需人工确认 |
| review | implicit-global | AA整合版本.lsp:8430 | find-att-by-keywords | 写入未声明变量 tag；动态调用方局部绑定需人工确认 |
| review | implicit-global | AA整合版本.lsp:8470 | fill-one-frame | 写入未声明变量 att；动态调用方局部绑定需人工确认 |
| review | implicit-global | AA整合版本.lsp:8542 | fillframes-run | 写入未声明变量 blk；动态调用方局部绑定需人工确认 |
| review | implicit-global | AA整合版本.lsp:8864 | hao2:sort-blocks | 写入未声明变量 p；动态调用方局部绑定需人工确认 |
| review | implicit-global | AA整合版本.lsp:9245 | ming:find-title-attrib | 写入未声明变量 att；动态调用方局部绑定需人工确认 |
| review | implicit-global | AA整合版本.lsp:9381 | c:ming | 写入未声明变量 b；动态调用方局部绑定需人工确认 |
| review | implicit-global | AA整合版本.lsp:9917 | fdx:place | 写入未声明变量 pending；动态调用方局部绑定需人工确认 |
| review | implicit-global | AA整合版本.lsp:10504 | aa:zz-add-seg | 写入未声明变量 hlist；动态调用方局部绑定需人工确认 |
| review | implicit-global | AA整合版本.lsp:10504 | aa:zz-add-seg | 写入未声明变量 vlist；动态调用方局部绑定需人工确认 |
| review | implicit-global | AA整合版本.lsp:10519 | aa:zz-collect-lwpoly-pts | 写入未声明变量 pair；动态调用方局部绑定需人工确认 |
| review | implicit-global | AA整合版本.lsp:10532 | aa:zz-build-line-cache | 写入未声明变量 p；动态调用方局部绑定需人工确认 |
| review | implicit-global | AA整合版本.lsp:10766 | aa:zz-run | 写入未声明变量 g；动态调用方局部绑定需人工确认 |
| review | implicit-global | AA整合版本.lsp:12051 | c:qw2 | 写入未声明变量 it；动态调用方局部绑定需人工确认 |
| review | implicit-global | AA整合版本.lsp:12364 | c:dx1 | 写入未声明变量 it；动态调用方局部绑定需人工确认 |
| review | implicit-global | AA整合版本.lsp:12449 | ce-redraw | 写入未声明变量 p；动态调用方局部绑定需人工确认 |
| review | implicit-global | AA整合版本.lsp:12975 | tktj:draw-row | 写入未声明变量 txt；动态调用方局部绑定需人工确认 |
| review | implicit-global | AA整合版本.lsp:13595 | c1c2:delete-preview | 写入未声明变量 c1c2:*active-preview*；动态调用方局部绑定需人工确认 |
| review | implicit-global | AA整合版本.lsp:13605 | c1c2:place-one | 写入未声明变量 c1c2:*active-preview*；动态调用方局部绑定需人工确认 |
| review | implicit-global | AA整合版本.lsp:13936 | ge:make-line | 写入未声明变量 created；动态调用方局部绑定需人工确认 |
| review | implicit-global | AA整合版本.lsp:14477 | c:dl1 | 写入未声明变量 lay；动态调用方局部绑定需人工确认 |
| review | implicit-global | AA整合版本.lsp:14697 | aa:km-ln-cmd | 写入未声明变量 ed；动态调用方局部绑定需人工确认 |
| review | implicit-global | AA整合版本.lsp:14697 | aa:km-ln-cmd | 写入未声明变量 en；动态调用方局部绑定需人工确认 |
| review | implicit-global | AA整合版本.lsp:14697 | aa:km-ln-cmd | 写入未声明变量 item；动态调用方局部绑定需人工确认 |
| review | implicit-global | AA整合版本.lsp:14697 | aa:km-ln-cmd | 写入未声明变量 p1；动态调用方局部绑定需人工确认 |
| review | implicit-global | AA整合版本.lsp:14697 | aa:km-ln-cmd | 写入未声明变量 p2；动态调用方局部绑定需人工确认 |
| review | implicit-global | AA整合版本.lsp:14957 | aa:yd-cmd | 写入未声明变量 ed；动态调用方局部绑定需人工确认 |
| review | implicit-global | AA整合版本.lsp:14957 | aa:yd-cmd | 写入未声明变量 en；动态调用方局部绑定需人工确认 |
| review | implicit-global | AA整合版本.lsp:14957 | aa:yd-cmd | 写入未声明变量 idx；动态调用方局部绑定需人工确认 |
| review | implicit-global | AA整合版本.lsp:14957 | aa:yd-cmd | 写入未声明变量 item；动态调用方局部绑定需人工确认 |
| review | implicit-global | AA整合版本.lsp:14957 | aa:yd-cmd | 写入未声明变量 p1；动态调用方局部绑定需人工确认 |
| review | implicit-global | AA整合版本.lsp:14957 | aa:yd-cmd | 写入未声明变量 p2；动态调用方局部绑定需人工确认 |
| review | implicit-global | AA整合版本.lsp:15258 | c:dao | 写入未声明变量 item；动态调用方局部绑定需人工确认 |
| review | shared-global | V6/aicad_aa_loader.lsp:261 | *aicad_basedirectory* | 跨文件写入: V6/aicad_aa_loader.lsp:261 (aicadloader:command-load), V6/aicad_extension.lsp:62 (aicad:remember-base-directory), V6/aicad_extension.lsp:97 (&lt;load>) |
| review | sysvar-restore | AA整合版本.lsp:4290 | aa:ss-do-interactive-stretch | "CMDECHO": 未见直接变量值恢复；getvar快照=True，需核对框架/是否持久设置 |
| review | sysvar-restore | AA整合版本.lsp:4290 | aa:ss-do-interactive-stretch | "DRAGMODE": 未见直接变量值恢复；getvar快照=True，需核对框架/是否持久设置 |
| review | sysvar-restore | AA整合版本.lsp:4325 | c:ss | "CMDECHO": 未见直接变量值恢复；getvar快照=False，需核对框架/是否持久设置 |
| review | sysvar-restore | AA整合版本.lsp:9554 | c:five | "CMDECHO": 未见直接变量值恢复；getvar快照=False，需核对框架/是否持久设置 |
| review | sysvar-restore | AA整合版本.lsp:14331 | aa:rotate-90-run | "CMDECHO": 未见直接变量值恢复；getvar快照=False，需核对框架/是否持久设置 |
| review | sysvar-restore | AA整合版本.lsp:15991 | c:hs | "CMDECHO": 未见直接变量值恢复；getvar快照=False，需核对框架/是否持久设置 |
| review | sysvar-restore | AA整合版本.lsp:16172 | c:zs | "CMDECHO": 未见直接变量值恢复；getvar快照=False，需核对框架/是否持久设置 |
| review | sysvar-restore | AA整合版本.lsp:16376 | c:sc3 | "CMDECHO": 未见直接变量值恢复；getvar快照=False，需核对框架/是否持久设置 |
| review | sysvar-restore | AA整合版本.lsp:16559 | c:vpo1 | "CMDECHO": 未见直接变量值恢复；getvar快照=False，需核对框架/是否持久设置 |
| review | sysvar-restore | AA整合版本.lsp:16567 | c:vpo2 | "CMDECHO": 未见直接变量值恢复；getvar快照=False，需核对框架/是否持久设置 |
| review | undo-close | AA整合版本.lsp:595 | aa:cmd-begin | vla-startundomark 出现；本函数未找到 vla-endundomark，需追踪调用方/异常路径 |
| review | undo-close | AA整合版本.lsp:626 | aa:undo-mark-on | vla-startundomark 出现；本函数未找到 vla-endundomark，需追踪调用方/异常路径 |
| review | undo-close | AA整合版本.lsp:13638 | c1c2:run | vla-startundomark 出现；本函数未找到 vla-endundomark，需追踪调用方/异常路径 |
| review | undo-close | AA整合版本.lsp:13821 | de:run | vla-startundomark 出现；本函数未找到 vla-endundomark，需追踪调用方/异常路径 |
| review | undo-close | AA整合版本.lsp:13954 | c:ge | vla-startundomark 出现；本函数未找到 vla-endundomark，需追踪调用方/异常路径 |
| review | undo-close | AA整合版本.lsp:15524 | c:bk | vla-startundomark 出现；本函数未找到 vla-endundomark，需追踪调用方/异常路径 |
| review | undo-error-path | V6/aicad_extension.lsp:968 | aicad:apply-zuo | 正常关闭调用存在，但未局部绑定 *error*；需核对外层捕获异常后的关闭保证 |
| review | undo-error-path | V6/aicad_extension.lsp:1009 | aicad:apply-you | 正常关闭调用存在，但未局部绑定 *error*；需核对外层捕获异常后的关闭保证 |
| review | undo-error-path | V6/aicad_extension.lsp:1066 | aicad:apply-shang | 正常关闭调用存在，但未局部绑定 *error*；需核对外层捕获异常后的关闭保证 |
| review | undo-error-path | V6/aicad_extension.lsp:1098 | aicad:apply-xia | 正常关闭调用存在，但未局部绑定 *error*；需核对外层捕获异常后的关闭保证 |
| review | undo-error-path | V6/aicad_extension.lsp:1130 | aicad:apply-zhong | 正常关闭调用存在，但未局部绑定 *error*；需核对外层捕获异常后的关闭保证 |
| review | undo-error-path | V6/aicad_extension.lsp:1279 | aicad:apply-text-replacements | 正常关闭调用存在，但未局部绑定 *error*；需核对外层捕获异常后的关闭保证 |

## 公共库与实际修复

详见 [工程化说明](docs/ENGINEERING.md) 与 [公共库设计](common/README.md)。已抽象的纯函数使用构建时展开，运行时加载入口不变。
高确定性修复、保留项与验证证据见 [人工审阅记录](docs/AUDIT_REVIEW.md)。本报告保留所有启发式候选，不以减少告警数量为目的改写正常命令。

## 全局写入明细

所有显式及隐式全局写入位置保存在 `docs/lsp-audit.json`，包含动态作用域辅助函数；同文件重复写入只作清单，不等同于重复声明冲突。
