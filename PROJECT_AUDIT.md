# PROJECT_AUDIT

> 自动生成，可用 `python scripts/audit_lsp.py --check` 检查是否过期。扫描结果与源码绑定，不包含 CAD 实机验收。

扫描 5 个 LSP、1351 个顶层函数、196 个命令入口。

## 文件清单

| 文件 | 字节 | 顶层表达式 | 函数 | 命令 |
| --- | ---: | ---: | ---: | ---: |
| AA整合版本.lsp | 1202223 | 1310 | 1212 | 183 |
| common/aicad_pure.lsp | 483 | 3 | 3 | 0 |
| V6/aicad_aa_loader.lsp | 9914 | 32 | 24 | 3 |
| V6/aicad_extension.lsp | 60953 | 142 | 112 | 10 |
| ZDDL_端子电缆自动出线.lsp | 182 | 2 | 0 | 0 |

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
| duplicate-function | 0 |
| shared-global | 1 |
| command-conflict | 0 |
| nested-command | 0 |
| undo-close | 6 |
| undo-error-path | 6 |
| native-undo | 0 |
| error-binding | 3 |
| error-cleanup | 4 |
| sysvar-restore | 34 |
| nil-selection | 0 |
| implicit-global | 74 |

## 发现清单

| 级别 | 检查 | 文件:行 | 函数 / 变量 | 证据 |
| --- | --- | --- | --- | --- |
| review | error-binding | AA整合版本.lsp:714 | aa:cmd-begin | *error* 赋值未局部声明；可能为动态作用域框架 |
| review | error-binding | AA整合版本.lsp:24216 | c:hddl | *error* 赋值未局部声明；可能为动态作用域框架 |
| review | error-binding | AA整合版本.lsp:24216 | c:hddl | 局部错误处理定义缺少 *error* 局部绑定 |
| review | error-cleanup | AA整合版本.lsp:19590 | de:run | 专属 *error* 未见标准恢复调用；需核对间接清理 |
| review | error-cleanup | AA整合版本.lsp:19724 | c:ge | 专属 *error* 未见标准恢复调用；需核对间接清理 |
| review | error-cleanup | AA整合版本.lsp:23704 | c:qh | 专属 *error* 未见标准恢复调用；需核对间接清理 |
| review | error-cleanup | AA整合版本.lsp:23885 | c:bk | 专属 *error* 未见标准恢复调用；需核对间接清理 |
| review | implicit-global | AA整合版本.lsp:2089 | zhu:sort-nums | 写入未声明变量 n；动态调用方局部绑定需人工确认 |
| review | implicit-global | AA整合版本.lsp:2097 | zhu:classify | 写入未声明变量 s；动态调用方局部绑定需人工确认 |
| review | implicit-global | AA整合版本.lsp:2107 | zhu:build-note | 写入未声明变量 n；动态调用方局部绑定需人工确认 |
| review | implicit-global | AA整合版本.lsp:2224 | hwt:layout | 写入未声明变量 u；动态调用方局部绑定需人工确认 |
| review | implicit-global | AA整合版本.lsp:2305 | hwt:cable-rows | 写入未声明变量 r；动态调用方局部绑定需人工确认 |
| review | implicit-global | AA整合版本.lsp:2318 | hwt:counts-text | 写入未声明变量 c；动态调用方局部绑定需人工确认 |
| review | implicit-global | AA整合版本.lsp:2326 | hwt:make-pline | 写入未声明变量 p；动态调用方局部绑定需人工确认 |
| review | implicit-global | AA整合版本.lsp:2343 | hwt:draw | 写入未声明变量 it；动态调用方局部绑定需人工确认 |
| review | implicit-global | AA整合版本.lsp:2372 | hwt:draw-list | 写入未声明变量 r；动态调用方局部绑定需人工确认 |
| review | implicit-global | AA整合版本.lsp:2372 | hwt:draw-list | 写入未声明变量 s；动态调用方局部绑定需人工确认 |
| review | implicit-global | AA整合版本.lsp:2628 | dh:tidy | 写入未声明变量 x；动态调用方局部绑定需人工确认 |
| review | implicit-global | AA整合版本.lsp:2892 | c:h | 写入未声明变量 item；动态调用方局部绑定需人工确认 |
| review | implicit-global | AA整合版本.lsp:2892 | c:h | 写入未声明变量 row；动态调用方局部绑定需人工确认 |
| review | implicit-global | AA整合版本.lsp:3026 | c:h2 | 写入未声明变量 item；动态调用方局部绑定需人工确认 |
| review | implicit-global | AA整合版本.lsp:3026 | c:h2 | 写入未声明变量 row；动态调用方局部绑定需人工确认 |
| review | implicit-global | AA整合版本.lsp:4020 | c:hp | 写入未声明变量 col；动态调用方局部绑定需人工确认 |
| review | implicit-global | AA整合版本.lsp:4163 | c:hp2 | 写入未声明变量 col；动态调用方局部绑定需人工确认 |
| review | implicit-global | AA整合版本.lsp:4702 | c:he | 写入未声明变量 h；动态调用方局部绑定需人工确认 |
| review | implicit-global | AA整合版本.lsp:4702 | c:he | 写入未声明变量 item；动态调用方局部绑定需人工确认 |
| review | implicit-global | AA整合版本.lsp:4702 | c:he | 写入未声明变量 p1；动态调用方局部绑定需人工确认 |
| review | implicit-global | AA整合版本.lsp:4702 | c:he | 写入未声明变量 p2；动态调用方局部绑定需人工确认 |
| review | implicit-global | AA整合版本.lsp:4702 | c:he | 写入未声明变量 x1；动态调用方局部绑定需人工确认 |
| review | implicit-global | AA整合版本.lsp:4702 | c:he | 写入未声明变量 x2；动态调用方局部绑定需人工确认 |
| review | implicit-global | AA整合版本.lsp:4702 | c:he | 写入未声明变量 y1；动态调用方局部绑定需人工确认 |
| review | implicit-global | AA整合版本.lsp:4702 | c:he | 写入未声明变量 y2；动态调用方局部绑定需人工确认 |
| review | implicit-global | AA整合版本.lsp:5070 | c:det | 写入未声明变量 val；动态调用方局部绑定需人工确认 |
| review | implicit-global | AA整合版本.lsp:5140 | a2t:text-dxf | 写入未声明变量 code；动态调用方局部绑定需人工确认 |
| review | implicit-global | AA整合版本.lsp:5551 | aa:ortho-ent-pts | 写入未声明变量 pair；动态调用方局部绑定需人工确认 |
| review | implicit-global | AA整合版本.lsp:5565 | aa:ortho-detect-vec | 写入未声明变量 g；动态调用方局部绑定需人工确认 |
| review | implicit-global | AA整合版本.lsp:5609 | aa:ortho-restore | 写入未声明变量 ed；动态调用方局部绑定需人工确认 |
| review | implicit-global | AA整合版本.lsp:5671 | aa:ortho-restore-vars | 写入未声明变量 item；动态调用方局部绑定需人工确认 |
| review | implicit-global | AA整合版本.lsp:5791 | aa:ss-get-entity-pts | 写入未声明变量 pair；动态调用方局部绑定需人工确认 |
| review | implicit-global | AA整合版本.lsp:6870 | aa:gty-update-nth | 写入未声明变量 itm；动态调用方局部绑定需人工确认 |
| review | implicit-global | AA整合版本.lsp:7280 | gty2:make-copies | 写入未声明变量 copies；动态调用方局部绑定需人工确认 |
| review | implicit-global | AA整合版本.lsp:7372 | c:gtz | 写入未声明变量 r；动态调用方局部绑定需人工确认 |
| review | implicit-global | AA整合版本.lsp:7726 | lan-vert-mode | 写入未声明变量 x；动态调用方局部绑定需人工确认 |
| review | implicit-global | AA整合版本.lsp:10827 | c:sxc | 写入未声明变量 r；动态调用方局部绑定需人工确认 |
| review | implicit-global | AA整合版本.lsp:12621 | is-frame-block | 写入未声明变量 att；动态调用方局部绑定需人工确认 |
| review | implicit-global | AA整合版本.lsp:12655 | sort-frames-by-position | 写入未声明变量 pa；动态调用方局部绑定需人工确认 |
| review | implicit-global | AA整合版本.lsp:12655 | sort-frames-by-position | 写入未声明变量 pb；动态调用方局部绑定需人工确认 |
| review | implicit-global | AA整合版本.lsp:12655 | sort-frames-by-position | 写入未声明变量 xa；动态调用方局部绑定需人工确认 |
| review | implicit-global | AA整合版本.lsp:12655 | sort-frames-by-position | 写入未声明变量 xb；动态调用方局部绑定需人工确认 |
| review | implicit-global | AA整合版本.lsp:12655 | sort-frames-by-position | 写入未声明变量 ya；动态调用方局部绑定需人工确认 |
| review | implicit-global | AA整合版本.lsp:12655 | sort-frames-by-position | 写入未声明变量 yb；动态调用方局部绑定需人工确认 |
| review | implicit-global | AA整合版本.lsp:12679 | find-att-by-keywords | 写入未声明变量 att；动态调用方局部绑定需人工确认 |
| review | implicit-global | AA整合版本.lsp:12679 | find-att-by-keywords | 写入未声明变量 kw；动态调用方局部绑定需人工确认 |
| review | implicit-global | AA整合版本.lsp:12679 | find-att-by-keywords | 写入未声明变量 tag；动态调用方局部绑定需人工确认 |
| review | implicit-global | AA整合版本.lsp:12719 | fill-one-frame | 写入未声明变量 att；动态调用方局部绑定需人工确认 |
| review | implicit-global | AA整合版本.lsp:12791 | fillframes-run | 写入未声明变量 blk；动态调用方局部绑定需人工确认 |
| review | implicit-global | AA整合版本.lsp:13118 | hao2:sort-blocks | 写入未声明变量 p；动态调用方局部绑定需人工确认 |
| review | implicit-global | AA整合版本.lsp:13499 | ming:find-title-attrib | 写入未声明变量 att；动态调用方局部绑定需人工确认 |
| review | implicit-global | AA整合版本.lsp:13635 | c:ming | 写入未声明变量 b；动态调用方局部绑定需人工确认 |
| review | implicit-global | AA整合版本.lsp:14359 | fdx:place | 写入未声明变量 pending；动态调用方局部绑定需人工确认 |
| review | implicit-global | AA整合版本.lsp:14986 | aa:zz-add-seg | 写入未声明变量 hlist；动态调用方局部绑定需人工确认 |
| review | implicit-global | AA整合版本.lsp:14986 | aa:zz-add-seg | 写入未声明变量 vlist；动态调用方局部绑定需人工确认 |
| review | implicit-global | AA整合版本.lsp:16156 | aa:tbhb-collect | 写入未声明变量 anchor；动态调用方局部绑定需人工确认 |
| review | implicit-global | AA整合版本.lsp:17339 | c:qw2 | 写入未声明变量 it；动态调用方局部绑定需人工确认 |
| review | implicit-global | AA整合版本.lsp:17875 | tjk:draw | 写入未声明变量 item；动态调用方局部绑定需人工确认 |
| review | implicit-global | AA整合版本.lsp:17955 | c:dx1 | 写入未声明变量 it；动态调用方局部绑定需人工确认 |
| review | implicit-global | AA整合版本.lsp:18040 | ce-redraw | 写入未声明变量 p；动态调用方局部绑定需人工确认 |
| review | implicit-global | AA整合版本.lsp:18566 | tktj:draw-row | 写入未声明变量 txt；动态调用方局部绑定需人工确认 |
| review | implicit-global | AA整合版本.lsp:19168 | c1c2:delete-preview | 写入未声明变量 c1c2:*active-preview*；动态调用方局部绑定需人工确认 |
| review | implicit-global | AA整合版本.lsp:19178 | c1c2:place-one | 写入未声明变量 c1c2:*active-preview*；动态调用方局部绑定需人工确认 |
| review | implicit-global | AA整合版本.lsp:19706 | ge:make-line | 写入未声明变量 created；动态调用方局部绑定需人工确认 |
| review | implicit-global | AA整合版本.lsp:20247 | c:dl1 | 写入未声明变量 lay；动态调用方局部绑定需人工确认 |
| review | implicit-global | AA整合版本.lsp:21048 | aa:rep-text | 写入未声明变量 c；动态调用方局部绑定需人工确认 |
| review | implicit-global | AA整合版本.lsp:21094 | aa:rep-end | 写入未声明变量 r；动态调用方局部绑定需人工确认 |
| review | implicit-global | AA整合版本.lsp:27625 | bdl:work-multi | 写入未声明变量 bdl-picks；动态调用方局部绑定需人工确认 |
| review | implicit-global | AA整合版本.lsp:27858 | zyl:remove1 | 写入未声明变量 e；动态调用方局部绑定需人工确认 |
| review | implicit-global | AA整合版本.lsp:27865 | zyl:plan | 写入未声明变量 d；动态调用方局部绑定需人工确认 |
| review | implicit-global | AA整合版本.lsp:27865 | zyl:plan | 写入未声明变量 k；动态调用方局部绑定需人工确认 |
| review | implicit-global | AA整合版本.lsp:27914 | zyl:join | 写入未声明变量 e；动态调用方局部绑定需人工确认 |
| review | implicit-global | AA整合版本.lsp:28052 | zyl:count-same | 写入未声明变量 x；动态调用方局部绑定需人工确认 |
| review | implicit-global | AA整合版本.lsp:28058 | zyl:choose | 写入未声明变量 v；动态调用方局部绑定需人工确认 |
| review | shared-global | V6/aicad_aa_loader.lsp:264 | *aicad_basedirectory* | 跨文件写入: V6/aicad_aa_loader.lsp:264 (aicadloader:command-load), V6/aicad_extension.lsp:62 (aicad:remember-base-directory), V6/aicad_extension.lsp:97 (&lt;load>) |
| review | sysvar-restore | AA整合版本.lsp:5516 | c:ll | "AUTOSNAP": 未见直接变量值恢复；getvar快照=False，需核对框架/是否持久设置 |
| review | sysvar-restore | AA整合版本.lsp:5516 | c:ll | "CMDECHO": 未见直接变量值恢复；getvar快照=False，需核对框架/是否持久设置 |
| review | sysvar-restore | AA整合版本.lsp:5516 | c:ll | "DRAGMODE": 未见直接变量值恢复；getvar快照=False，需核对框架/是否持久设置 |
| review | sysvar-restore | AA整合版本.lsp:5516 | c:ll | "ORTHOMODE": 未见直接变量值恢复；getvar快照=False，需核对框架/是否持久设置 |
| review | sysvar-restore | AA整合版本.lsp:5516 | c:ll | "OSMODE": 未见直接变量值恢复；getvar快照=False，需核对框架/是否持久设置 |
| review | sysvar-restore | AA整合版本.lsp:5516 | c:ll | "SNAPANG": 未见直接变量值恢复；getvar快照=False，需核对框架/是否持久设置 |
| review | sysvar-restore | AA整合版本.lsp:5516 | c:ll | "SNAPMODE": 未见直接变量值恢复；getvar快照=False，需核对框架/是否持久设置 |
| review | sysvar-restore | AA整合版本.lsp:5694 | c:mm | "AUTOSNAP": 未见直接变量值恢复；getvar快照=True，需核对框架/是否持久设置 |
| review | sysvar-restore | AA整合版本.lsp:5694 | c:mm | "CMDECHO": 未见直接变量值恢复；getvar快照=False，需核对框架/是否持久设置 |
| review | sysvar-restore | AA整合版本.lsp:5694 | c:mm | "DRAGMODE": 未见直接变量值恢复；getvar快照=False，需核对框架/是否持久设置 |
| review | sysvar-restore | AA整合版本.lsp:5694 | c:mm | "ORTHOMODE": 未见直接变量值恢复；getvar快照=False，需核对框架/是否持久设置 |
| review | sysvar-restore | AA整合版本.lsp:5694 | c:mm | "SNAPANG": 未见直接变量值恢复；getvar快照=False，需核对框架/是否持久设置 |
| review | sysvar-restore | AA整合版本.lsp:5694 | c:mm | "SNAPMODE": 未见直接变量值恢复；getvar快照=False，需核对框架/是否持久设置 |
| review | sysvar-restore | AA整合版本.lsp:5732 | c:ss | "AUTOSNAP": 未见直接变量值恢复；getvar快照=True，需核对框架/是否持久设置 |
| review | sysvar-restore | AA整合版本.lsp:5732 | c:ss | "CMDECHO": 未见直接变量值恢复；getvar快照=False，需核对框架/是否持久设置 |
| review | sysvar-restore | AA整合版本.lsp:5732 | c:ss | "DRAGMODE": 未见直接变量值恢复；getvar快照=False，需核对框架/是否持久设置 |
| review | sysvar-restore | AA整合版本.lsp:5732 | c:ss | "ORTHOMODE": 未见直接变量值恢复；getvar快照=False，需核对框架/是否持久设置 |
| review | sysvar-restore | AA整合版本.lsp:5732 | c:ss | "SNAPANG": 未见直接变量值恢复；getvar快照=False，需核对框架/是否持久设置 |
| review | sysvar-restore | AA整合版本.lsp:5732 | c:ss | "SNAPMODE": 未见直接变量值恢复；getvar快照=False，需核对框架/是否持久设置 |
| review | sysvar-restore | AA整合版本.lsp:5818 | aa:ss-do-interactive-stretch | "CMDECHO": 未见直接变量值恢复；getvar快照=True，需核对框架/是否持久设置 |
| review | sysvar-restore | AA整合版本.lsp:5818 | aa:ss-do-interactive-stretch | "DRAGMODE": 未见直接变量值恢复；getvar快照=True，需核对框架/是否持久设置 |
| review | sysvar-restore | AA整合版本.lsp:5853 | c:sw | "CMDECHO": 未见直接变量值恢复；getvar快照=False，需核对框架/是否持久设置 |
| review | sysvar-restore | AA整合版本.lsp:7308 | gty2:to-clip | "CMDECHO": 未见直接变量值恢复；getvar快照=False，需核对框架/是否持久设置 |
| review | sysvar-restore | AA整合版本.lsp:11098 | c:sxd | "USERS5": 未见直接变量值恢复；getvar快照=False，需核对框架/是否持久设置 |
| review | sysvar-restore | AA整合版本.lsp:13808 | c:five | "CMDECHO": 未见直接变量值恢复；getvar快照=False，需核对框架/是否持久设置 |
| review | sysvar-restore | AA整合版本.lsp:20101 | aa:rotate-90-run | "CMDECHO": 未见直接变量值恢复；getvar快照=False，需核对框架/是否持久设置 |
| review | sysvar-restore | AA整合版本.lsp:22997 | bh:pick-start | "ERRNO": 未见直接变量值恢复；getvar快照=True，需核对框架/是否持久设置 |
| review | sysvar-restore | AA整合版本.lsp:23102 | c:bh1 | "ERRNO": 未见直接变量值恢复；getvar快照=True，需核对框架/是否持久设置 |
| review | sysvar-restore | AA整合版本.lsp:24446 | c:hs | "CMDECHO": 未见直接变量值恢复；getvar快照=False，需核对框架/是否持久设置 |
| review | sysvar-restore | AA整合版本.lsp:24627 | c:zs | "CMDECHO": 未见直接变量值恢复；getvar快照=False，需核对框架/是否持久设置 |
| review | sysvar-restore | AA整合版本.lsp:24831 | c:sc3 | "CMDECHO": 未见直接变量值恢复；getvar快照=False，需核对框架/是否持久设置 |
| review | sysvar-restore | AA整合版本.lsp:25014 | c:vpo1 | "CMDECHO": 未见直接变量值恢复；getvar快照=False，需核对框架/是否持久设置 |
| review | sysvar-restore | AA整合版本.lsp:25022 | c:vpo2 | "CMDECHO": 未见直接变量值恢复；getvar快照=False，需核对框架/是否持久设置 |
| review | sysvar-restore | AA整合版本.lsp:27923 | zyl:pick | "ERRNO": 未见直接变量值恢复；getvar快照=True，需核对框架/是否持久设置 |
| review | undo-close | AA整合版本.lsp:714 | aa:cmd-begin | vla-startundomark 出现；本函数未找到 vla-endundomark，需追踪调用方/异常路径 |
| review | undo-close | AA整合版本.lsp:745 | aa:undo-mark-on | vla-startundomark 出现；本函数未找到 vla-endundomark，需追踪调用方/异常路径 |
| review | undo-close | AA整合版本.lsp:19211 | c1c2:run | vla-startundomark 出现；本函数未找到 vla-endundomark，需追踪调用方/异常路径 |
| review | undo-close | AA整合版本.lsp:19590 | de:run | vla-startundomark 出现；本函数未找到 vla-endundomark，需追踪调用方/异常路径 |
| review | undo-close | AA整合版本.lsp:19724 | c:ge | vla-startundomark 出现；本函数未找到 vla-endundomark，需追踪调用方/异常路径 |
| review | undo-close | AA整合版本.lsp:23885 | c:bk | vla-startundomark 出现；本函数未找到 vla-endundomark，需追踪调用方/异常路径 |
| review | undo-error-path | V6/aicad_extension.lsp:971 | aicad:apply-zuo | 正常关闭调用存在，但未局部绑定 *error*；需核对外层捕获异常后的关闭保证 |
| review | undo-error-path | V6/aicad_extension.lsp:1012 | aicad:apply-you | 正常关闭调用存在，但未局部绑定 *error*；需核对外层捕获异常后的关闭保证 |
| review | undo-error-path | V6/aicad_extension.lsp:1069 | aicad:apply-shang | 正常关闭调用存在，但未局部绑定 *error*；需核对外层捕获异常后的关闭保证 |
| review | undo-error-path | V6/aicad_extension.lsp:1101 | aicad:apply-xia | 正常关闭调用存在，但未局部绑定 *error*；需核对外层捕获异常后的关闭保证 |
| review | undo-error-path | V6/aicad_extension.lsp:1133 | aicad:apply-zhong | 正常关闭调用存在，但未局部绑定 *error*；需核对外层捕获异常后的关闭保证 |
| review | undo-error-path | V6/aicad_extension.lsp:1282 | aicad:apply-text-replacements | 正常关闭调用存在，但未局部绑定 *error*；需核对外层捕获异常后的关闭保证 |

## 公共库与实际修复

详见 [工程化说明](docs/ENGINEERING.md) 与 [公共库设计](common/README.md)。已抽象的纯函数使用构建时展开，运行时加载入口不变。
高确定性修复、保留项与验证证据见 [人工审阅记录](docs/AUDIT_REVIEW.md)。本报告保留所有启发式候选，不以减少告警数量为目的改写正常命令。

## 全局写入明细

所有显式及隐式全局写入位置保存在 `docs/lsp-audit.json`，包含动态作用域辅助函数；同文件重复写入只作清单，不等同于重复声明冲突。
