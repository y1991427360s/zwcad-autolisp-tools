# COMMANDS

> 自动生成：`python scripts/audit_lsp.py --write`。仅收录 LSP 顶层命令；.NET 命令见现有命令索引。

参数包含函数形参与可达调用的交互输入类型。依赖列列出直接项目函数和静态发现的外部文件；间接依赖见 JSON。
对象列是可达源码中出现的图元/表记录类型与修改调用的候选范围，可能包含只读取的对象；静态分析无法精确判定实际修改目标。动态函数调用和字符串内回调需人工核对。

| 命令 | 功能（源码注释） | 参数 / 输入 | 依赖 | 修改对象类型（候选） | 位置 |
| --- | --- | --- | --- | --- | --- |
| 0 | 将所选对象中的文字旋转角度统一改为 0 度。 | 无函数形参; 交互: ssget | aa:cmd-begin, aa:cmd-end | ATTDEF, ATTRIB, MTEXT, TEXT；存在修改调用 | AA整合版本.lsp:14290 |
| 9 | 以所选对象整体包围框中心为基点，整体顺时针旋转 90 度。 | 无函数形参; 交互: ssget | aa:cmd-begin, aa:cmd-end, aa:rotate-90-run | 未静态确定；存在修改调用 | AA整合版本.lsp:14373 |
| 99 | 以所选对象整体包围框中心为基点，整体逆时针旋转 90 度。 | 无函数形参; 交互: ssget | aa:cmd-begin, aa:cmd-end, aa:rotate-90-run | 未静态确定；存在修改调用 | AA整合版本.lsp:14385 |
| AAE | 选择块内属性文字，在自定义窗口中编辑并按回车直接保存。 | 无函数形参; 交互: nentsel, ssget; 提示: 选择要编辑的属性文字: | aa:cmd-begin, aa:cmd-end, aae:locate-dcl, aae:resolve-val, aae:split-lines, AAE.DCL, \\AAE.DCL | ATTRIB；存在修改调用 | AA整合版本.lsp:8729 |
| AB | 在每个选中文字末尾增加输入的文字。 | 无函数形参; 交互: getstring, ssget; 提示: 请输入要增加的文字: | aa:cmd-begin, aa:cmd-end, db:add | MTEXT, TEXT；存在修改调用 | AA整合版本.lsp:11730 |
| AF | 在每个选中文字开头增加输入的文字。 | 无函数形参; 交互: getstring, ssget; 提示: 请输入要增加的文字: | aa:cmd-begin, aa:cmd-end, db:add | MTEXT, TEXT；存在修改调用 | AA整合版本.lsp:11736 |
| AICAD | 根据自然语言指令或对话修改选中的 CAD 对象 | 无函数形参; 交互: getstring, ssget; 提示: Describe the change for the selected objects: / Execute this action? [Yes/No] &lt;No>: | aicad:command-aicad, aicad:safe-apply, AICAD_BRIDGE.PS1, AICAD_LAUNCH.VBS, WSCRIPT.EXE | ATTRIB, INSERT, LINE, LWPOLYLINE, MTEXT, POLYLINE, TEXT；存在修改调用 | V6/aicad_extension.lsp:1785 |
| AICADCLEANUI | 清理残留的旧版临时 UI 与界面元素 | 无函数形参; 交互: 未发现 / 委托外部界面 | aicad:cleanup-legacy-ui, aicad:safe-apply | 未静态确定；存在修改调用 | V6/aicad_extension.lsp:1936 |
| AICADREPLACEPANELSHOW | 打开 AICAD 查找替换浮动面板 | 无函数形参; 交互: 未发现 / 委托外部界面 | aicadloader:safe-apply, aicadloader:show-replace-panel | 未静态确定；存在修改调用 | V6/aicad_aa_loader.lsp:304 |
| AICADRIBBON | 执行 Ribbon 功能区输入框中提交的自然语言指令 | 无函数形参; 交互: getstring, ssget; 提示: Execute this action? [Yes/No] &lt;No>: | aicad:command-ribbon, aicad:safe-apply, AICAD_BRIDGE.PS1, AICAD_LAUNCH.VBS, WSCRIPT.EXE | ATTRIB, INSERT, LINE, LWPOLYLINE, MTEXT, POLYLINE, TEXT；存在修改调用 | V6/aicad_extension.lsp:1826 |
| AICADRIBBONFIND | 执行 Ribbon 查找面板中的文字查找与定位 | 无函数形参; 交互: ssget | aicad:command-ribbon-find, aicad:safe-apply | ATTRIB, INSERT, MTEXT, TEXT；存在修改调用 | V6/aicad_extension.lsp:1919 |
| AICADRIBBONFOCUSMATCH | 聚焦并定位 Ribbon 查找匹配的目标图元 | 无函数形参; 交互: 未发现 / 委托外部界面 | aicad:command-ribbon-focus-match, aicad:safe-apply | 未静态确定；存在修改调用 | V6/aicad_extension.lsp:1931 |
| AICADRIBBONREPLACE | 执行 Ribbon 替换面板中的批量查找替换 | 无函数形参; 交互: ssget | aicad:command-ribbon-replace, aicad:safe-apply | ATTRIB, INSERT, MTEXT, TEXT；未发现直接/可达修改调用 | V6/aicad_extension.lsp:1886 |
| ASCAD | AICAD 启动命令别名 | 无函数形参; 交互: getstring, ssget; 提示: Describe the change for the selected objects: / Execute this action? [Yes/No] &lt;No>: | c:aicad, AICAD_BRIDGE.PS1, AICAD_LAUNCH.VBS, WSCRIPT.EXE | ATTRIB, INSERT, LINE, LWPOLYLINE, MTEXT, POLYLINE, TEXT；存在修改调用 | V6/aicad_extension.lsp:1790 |
| ASHANG | 选择一条水平直线作为基准线，框选其他所有对象作为一个整体整体移动并向上对齐到该直线。 | 无函数形参; 交互: entsel, ssget; 提示: [ASHANG] 请选择作为对齐基准的水平直线: | aa:bbox-top-y, aa:cmd-begin, aa:cmd-end, aa:safe-get-bbox, aa:safe-move-entity | LINE；存在修改调用 | AA整合版本.lsp:3440 |
| ATW | 拾取两点指定最大宽度，将超宽单行文字的宽度比例缩小至两点间距的 95% 并保持左侧不动。 | 无函数形参; 交互: getpoint, ssget; 提示: [ATW] 请指定最大宽度第一点: / [ATW] 请指定最大宽度第二点: | aa:bbox-left-x, aa:bbox-right-x, aa:cmd-begin, aa:cmd-end, aa:safe-get-bbox, aa:safe-move-entity | TEXT；存在修改调用 | AA整合版本.lsp:3966 |
| AW | 自动微移选中文字，尽量避开旁边线段、文字和其他对象重叠。 | 无函数形参; 交互: ssget | aw:get-selection, aw:process-one | MTEXT, TEXT；存在修改调用 | AA整合版本.lsp:12682 |
| AXIA | 选择一条水平直线作为基准线，框选其他所有对象作为一个整体整体移动并向下对齐到该直线。 | 无函数形参; 交互: entsel, ssget; 提示: [AXIA] 请选择作为对齐基准的水平直线: | aa:bbox-bottom-y, aa:cmd-begin, aa:cmd-end, aa:safe-get-bbox, aa:safe-move-entity | LINE；存在修改调用 | AA整合版本.lsp:3571 |
| AYOU | 选择一条竖直直线作为基准线，框选其他所有对象作为一个整体整体移动并右对齐到该直线。 | 无函数形参; 交互: entsel, ssget; 提示: [AYOU] 请选择作为对齐基准的竖直直线: | aa:bbox-right-x, aa:cmd-begin, aa:cmd-end, aa:safe-get-bbox, aa:safe-move-entity | LINE；存在修改调用 | AA整合版本.lsp:3308 |
| AZUO | 选择一条竖直直线作为基准线，框选其他所有对象作为一个整体整体移动并左对齐到该直线。 | 无函数形参; 交互: entsel, ssget; 提示: [AZUO] 请选择作为对齐基准的竖直直线: | aa:bbox-left-x, aa:cmd-begin, aa:cmd-end, aa:safe-get-bbox, aa:safe-move-entity | LINE；存在修改调用 | AA整合版本.lsp:2885 |
| BIAN | 根据选中直线生成方向三角、至字样和电缆规格标注。 | 无函数形参; 交互: ssget | aa:cmd-begin, aa:cmd-end, bian-draw-one | LINE, LWPOLYLINE, STYLE, TEXT；存在修改调用 | AA整合版本.lsp:5565 |
| BK | 选中文字后只保留最后一对括号内的内容，括号外有“至”时保留“至”。 | 无函数形参; 交互: ssget | bk:extract-inner, de:end-undo, de:get-text, de:set-text | ATTRIB, MTEXT, TEXT；存在修改调用 | AA整合版本.lsp:15524 |
| BY | 选中两条水平线后向右生成短线、矩形并居中标注B+、B-及同步时钟主机柜（青色虚线）。 | 无函数形参; 交互: ssget | aa:km-ln-cmd | LINE, LWPOLYLINE, POLYLINE, STYLE, TEXT；存在修改调用 | AA整合版本.lsp:14935 |
| BZ | 选中两条水平线后向左生成短线、矩形并居中标注B+、B-及同步时钟主机柜（青色虚线）。 | 无函数形参; 交互: ssget | aa:km-ln-cmd | LINE, LWPOLYLINE, POLYLINE, STYLE, TEXT；存在修改调用 | AA整合版本.lsp:14929 |
| C1 | 复制文字并递增减号右侧编号，使用原生拖动预览和捕捉连续放置。 | 无函数形参; 交互: getpoint, ssget; 提示: 指定基点: | c1c2:run | MTEXT, TEXT；存在修改调用 | AA整合版本.lsp:13700 |
| C2 | 复制文字并递减减号右侧编号，使用原生拖动预览和捕捉连续放置。 | 无函数形参; 交互: getpoint, ssget; 提示: 指定基点: | c1c2:run | MTEXT, TEXT；存在修改调用 | AA整合版本.lsp:13704 |
| C3 | 复制文字并每次将减号右侧编号加 2，使用原生拖动预览和捕捉连续放置。 | 无函数形参; 交互: getpoint, ssget; 提示: 指定基点: | c1c2:run | MTEXT, TEXT；存在修改调用 | AA整合版本.lsp:13708 |
| CC | 读取 Windows 剪贴板，连续复制并替换副本文字，使用原生拖动预览和对象捕捉。 | 无函数形参; 交互: getpoint, ssget; 提示: 指定第一个点（基点）: | aa:cmd-begin, aa:cmd-end, qe:get-clip-text | ATTDEF, MTEXT, TEXT；存在修改调用 | AA整合版本.lsp:11867 |
| CD | 将选中对象按 5 个单位的递增间距向下复制指定份数。 | 无函数形参; 交互: getint, ssget; 提示: 请输入复制份数（每份间距为 5）: | cu:copy-direction | 未静态确定；存在修改调用 | AA整合版本.lsp:15929 |
| CE | 测量点序列形成的多段线总长度。 | 无函数形参; 交互: getpoint; 提示: 请点击下一个点 (回车/空格结束): / 请点击第一个点 (回车/空格结束): | aa:cmd-begin, aa:cmd-end, ce-redraw | LWPOLYLINE；存在修改调用 | AA整合版本.lsp:12465 |
| CU | 将选中对象按 5 个单位的递增间距向上复制指定份数。 | 无函数形参; 交互: getint, ssget; 提示: 请输入复制份数（每份间距为 5）: | cu:copy-direction | 未静态确定；存在修改调用 | AA整合版本.lsp:15925 |
| CY | 将选中对象按 5 个单位的递增间距向右复制指定份数。 | 无函数形参; 交互: getint, ssget; 提示: 请输入复制份数（每份间距为 5）: | cu:copy-direction | 未静态确定；存在修改调用 | AA整合版本.lsp:15937 |
| CZ | 将选中对象按 5 个单位的递增间距向左复制指定份数。 | 无函数形参; 交互: getint, ssget; 提示: 请输入复制份数（每份间距为 5）: | cu:copy-direction | 未静态确定；存在修改调用 | AA整合版本.lsp:15933 |
| DAO | 将选中文字按垂直位置上下颠倒排列（最下面的文字放到最上面）。 | 无函数形参; 交互: ssget | dao:insert-sorted, dao:move-text | MTEXT, TEXT；存在修改调用 | AA整合版本.lsp:15258 |
| DB | 删除每个选中文字末尾的 N 个字符。 | 无函数形参; 交互: getint, ssget; 提示: 请输入要删除的字符个数: | aa:cmd-begin, aa:cmd-end, db:del | MTEXT, TEXT；存在修改调用 | AA整合版本.lsp:11718 |
| DE | 删除选中文字的最右侧括号及括号内容。 | 无函数形参; 交互: ssget | de:run | ATTRIB, MTEXT, TEXT；存在修改调用 | AA整合版本.lsp:13866 |
| DE2 | 用最右侧括号内容替换括号前连续数字。 | 无函数形参; 交互: ssget | de:run | ATTRIB, MTEXT, TEXT；存在修改调用 | AA整合版本.lsp:13867 |
| DEA | 删除所选对象中高度小于 0.1 的 TEXT/MTEXT 文字。 | 无函数形参; 交互: ssget | aa:cmd-begin, aa:cmd-end | MTEXT, TEXT；存在修改调用 | AA整合版本.lsp:3863 |
| DEK | 删除选中内容中的所有块参照 (INSERT)。 | 无函数形参; 交互: ssget | aa:cmd-begin, aa:cmd-end | INSERT；存在修改调用 | AA整合版本.lsp:3893 |
| DES | 所选直线共线重叠时删除短线、保留长线；完全重复留一条，跨图层处理并跳过锁定图层。 | 无函数形参; 交互: ssget | aa:cmd-begin, aa:cmd-end, aa:merge-sort, des:key-less-p, des:overlap-p | LINE；存在修改调用 | AA整合版本.lsp:528 |
| DF | 删除每个选中文字开头的 N 个字符。 | 无函数形参; 交互: getint, ssget; 提示: 请输入要删除的字符个数: | aa:cmd-begin, aa:cmd-end, db:del | MTEXT, TEXT；存在修改调用 | AA整合版本.lsp:11724 |
| DL1 | 创建电缆柜、电缆路径、电缆竖井相关的 1F / 2F 图层。 | 无函数形参; 交互: 未发现 / 委托外部界面 | aa:cmd-begin, aa:cmd-end, dl1:make-layer | 未静态确定；存在修改调用 | AA整合版本.lsp:14477 |
| DUMP | 打印选中图元的 ActiveX 属性与可用方法（调试辅助）。 | 无函数形参; 交互: entsel; 提示: 请选择要检查 ActiveX 属性的图元: | aa:cmd-begin, aa:cmd-end | 未静态确定；未发现直接/可达修改调用 | AA整合版本.lsp:13446 |
| DX | 批量整理 100×100 方格内的端子号、原理号和终点柜文字，并将整组文字居中。 | 无函数形参; 交互: ssget | aa:undo-mark-off, aa:undo-mark-on, aa:zz-filter-text-ss, aa:zz-group-by-rect, aa:zz-text-info, dx:apply-group | LINE, LWPOLYLINE, MTEXT, POLYLINE, TEXT；存在修改调用 | AA整合版本.lsp:10220 |
| DX1 | 提取选中文字及坐标，青色文字额外标注“端子名”，复制到剪贴板。 | 无函数形参; 交互: ssget | aa:cmd-begin, aa:cmd-end, aa:merge-sort, dx:color-kind, zi:pt, zi:to-clip | MTEXT, TEXT；未发现直接/可达修改调用 | AA整合版本.lsp:12364 |
| DX2 | 按方格从左到右、从上到下导出文字，每个方格一行，框内按行排序并用顿号连接，复制到剪贴板。 | 无函数形参; 交互: ssget | aa:cmd-begin, aa:cmd-end, aa:zz-filter-text-ss, aa:zz-group-by-rect, aa:zz-text-info, dx2:export-group, dx2:sort-groups, zi:to-clip | LINE, LWPOLYLINE, MTEXT, POLYLINE, TEXT；未发现直接/可达修改调用 | AA整合版本.lsp:10420 |
| FDX | 先选方框，再连续选择每批文字，按空格依次移动到下一方框并自动按 DX 规则排列。 | 无函数形参; 交互: getkword, ssget; 提示: [FDX] 方框顺序 [按行(R)/按列(C)] &lt;R>: | aa:undo-mark-off, aa:undo-mark-on, fdx:frames, fdx:place, fdx:show-frame, fdx:sort-frames | LINE, LWPOLYLINE, MTEXT, POLYLINE, TEXT；存在修改调用 | AA整合版本.lsp:9968 |
| FIVE | 将测得高度按比例缩放为 5。 | 无函数形参; 交互: getpoint, ssget; 提示: FIVE - 请点取当前格子高度的第一个点: / 请点取当前格子高度的第二个点: / 请点取缩放基点: | aa:cmd-begin, aa:cmd-end | 未静态确定；存在修改调用 | AA整合版本.lsp:9554 |
| GE | 选中同一水平行的单行文字，按文字间隙绘制单行表格。 | 无函数形参; 交互: ssget | ge:end-undo, ge:get-item, ge:make-line, ge:sort-items | LINE, TEXT；存在修改调用 | AA整合版本.lsp:13954 |
| GG | 将选中对象快速改为绿色。 | 无函数形参; 交互: ssget | aa:cmd-begin, aa:cmd-end, aa:color-cmd | 未静态确定；存在修改调用 | AA整合版本.lsp:2445 |
| GTX | 按自动容差整理单行/多行电缆文字并自然排序汇总。 | 无函数形参; 交互: getpoint, ssget; 提示: [GTX] 请指定汇总结果的插入点: | aa:gtx-create-text-entity, aa:gtx-find-last-char, aa:gtx-key, aa:gtx-rows, aa:gtx-select-prefix-text, aa:merge-sort, aa:try-get-bbox, aa:undo-mark-off, aa:undo-mark-on, aa:ysdl-get-plain-text | MTEXT, STYLE, TEXT；存在修改调用 | AA整合版本.lsp:4879 |
| GTY | 汇总并按电缆编号排序整理电缆文字。 | 无函数形参; 交互: ssget | aa:gty-build-sort-key, aa:gty-get-item-ename, aa:gty-get-item-pt, aa:gty-get-item-width, aa:gty-get-item-x, aa:gty-get-item-y, aa:gty-get-item-z, aa:gty-get-text-width, aa:gty-move-entity, aa:gty-update-nth, aa:insert-sort | TEXT；存在修改调用 | AA整合版本.lsp:5165 |
| GTZ | 将选中的交替柜名与电缆编号单列文字，按前后柜与编号重组为3列表格输出。 | 无函数形参; 交互: getpoint, ssget; 提示: [GTZ] 请指定新表格的放置点: | aa:gty-get-text-width, aa:gty-move-entity, aa:merge-sort | TEXT；存在修改调用 | AA整合版本.lsp:5352 |
| H | 先将选中文字统一为左中对正，再按指定间距从上到下排列。 | 无函数形参; 交互: getdist, ssget; 提示: 请输入上下间距 &lt;5>: | aa:cmd-begin, aa:cmd-end, aa:merge-sort, aa:normalize-text-horizontal-align | MTEXT, TEXT；存在修改调用 | AA整合版本.lsp:2043 |
| H2 | 先将选中文字统一为左中对正，右侧文字在最上、越靠左越靠下，按指定间距从上到下排列。 | 无函数形参; 交互: getdist, ssget; 提示: 请输入上下间距 &lt;5>: | aa:cmd-begin, aa:cmd-end, aa:merge-sort, aa:normalize-text-horizontal-align | MTEXT, TEXT；存在修改调用 | AA整合版本.lsp:2174 |
| HAO | 选中图框后批量填写页码和档案号。 | 无函数形参; 交互: getint, getstring, ssget; 提示: 请输入档案号（直接回车跳过不填写）: / 请输入比例（直接回车跳过不填写）: / 请输入起始页码（默认为1，直接回车使用默认值）: | aa:cmd-begin, aa:cmd-end, fillframes-run | INSERT；存在修改调用 | AA整合版本.lsp:8833 |
| HAO2 | 指定基准块参照与图号矩形范围，批量居中填充或更新递增图号文字。 | 无函数形参; 交互: entsel, getcorner, getint, getpoint, getstring, ssget; 提示: [HAO2] 请点击选择基准图框块参照: / [HAO2] 请输入图号前缀 (例如 D260020S-D0205-): / [HAO2] 请输入编号位数 (不足补零，例如 2 位为 01) &lt;2>:（另 1 项见 JSON） | aa:cmd-begin, aa:cmd-end, blk-insertpt, hao2:block-name, hao2:find-existing-text-fast, hao2:format-num, hao2:sort-blocks, tktj:current-space, tktj:ensure-text-style, zdml2:collect-all-texts | INSERT, MTEXT, TEXT；存在修改调用 | AA整合版本.lsp:9079 |
| HBDL | 框选电缆清册表格文字，自动将带有“并入”前缀的行合并到对应的目标电缆主行中，自动累加芯数并在末尾追加原理号，其他行保持原位。 | 无函数形参; 交互: ssget | aa:cmd-begin, aa:cmd-end, aa:ysdl-get-plain-text, hb:apply-merge-in-place, hb:cluster-rows, hb:parse-row | MTEXT, STYLE, TEXT；存在修改调用 | AA整合版本.lsp:7542 |
| HDDL | 直接校核选中文字中的电缆编号和原理号，问题行标红并在行首标注。 | 无函数形参; 交互: ssget | aa:undo-mark-off, aa:undo-mark-on, hddl:add-row, hddl:cell, hddl:clear-markers, hddl:color-cabinet-diffs, hddl:color-cell, hddl:color-core-count-diff, hddl:color-tail-diffs, hddl:color-tail-duplicates, hddl:ensure-layer, hddl:make-marker, hddl:mirror-p, hddl:point, hddl:sort-rows, hddl:tail-count, hddl:tail-different-p, hddl:tail-duplicate-p, hddl:text | MTEXT, TEXT；存在修改调用 | AA整合版本.lsp:15770 |
| HE | 将同一行的两个或以上文字合并。 | 无函数形参; 交互: ssget | aa:cmd-begin, aa:cmd-end, aa:insert-sort | MTEXT, TEXT；存在修改调用 | AA整合版本.lsp:3692 |
| HH | 将选中对象快速改为洋红色。 | 无函数形参; 交互: ssget | aa:cmd-begin, aa:cmd-end, aa:color-cmd | 未静态确定；存在修改调用 | AA整合版本.lsp:2455 |
| HP | 将选中文字按从左到右排列，使相邻文字首尾间距为指定值，并按最左文字上边对齐。 | 无函数形参; 交互: getdist, ssget; 提示: 请输入相邻文字首尾间距 &lt;5>: | aa:bbox-left-x, aa:bbox-right-x, aa:bbox-top-y, aa:cmd-begin, aa:cmd-end, aa:merge-sort, aa:safe-get-bbox, aa:safe-move-entity | MTEXT, TEXT；存在修改调用 | AA整合版本.lsp:3010 |
| HP2 | 将选中文字改为正中对齐，按中心点指定间距从左到右横向排列。 | 无函数形参; 交互: getdist, ssget; 提示: 请输入相邻文字中心间距 &lt;50>: | aa:bbox-bottom-y, aa:bbox-center-x, aa:bbox-top-y, aa:cmd-begin, aa:cmd-end, aa:merge-sort, aa:normalize-text-horizontal-align, aa:safe-get-bbox, aa:safe-move-entity | MTEXT, TEXT；存在修改调用 | AA整合版本.lsp:3153 |
| HS | 选中物体单向横向缩放，左右宽度改变，高度保持不变。 | 无函数形参; 交互: getdist, getpoint, ssget; 提示: :L / 指定新长度: | aa:cmd-begin, aa:cmd-end, aa:hs-filter-unlocked, aa:hs-get-ss-bbox | 未静态确定；存在修改调用 | AA整合版本.lsp:15991 |
| HUI | 将选中对象快速改为颜色 8；遇到引线先分解再改色，遇到块参照连块内实体一起改。 | 无函数形参; 交互: ssget | aa:cmd-begin, aa:cmd-end, aa:deep-color-cmd | DIMENSION, INSERT, LEADER, MTEXT；存在修改调用 | AA整合版本.lsp:2731 |
| JACC | ZZ 的同功能入口。 | 无函数形参; 交互: ssget | aa:zz-run | LINE, LWPOLYLINE, MTEXT, POLYLINE, TEXT；存在修改调用 | AA整合版本.lsp:10832 |
| JZ | 将矩形水平中线对齐到1条或2条直线中心线，可同步居中文字。 | 无函数形参; 交互: ssget | aa:bbox-bottom-y, aa:bbox-center-x, aa:bbox-top-y, aa:jz-line-center-y, aa:safe-get-bbox, aa:safe-move-entity | LINE, LWPOLYLINE, MTEXT, POLYLINE, TEXT；存在修改调用 | AA整合版本.lsp:9615 |
| KAI | 将 TEXT/MTEXT 中由空格分隔的内容拆分为多个独立文字。 | 无函数形参; 交互: ssget | aa:kai-add-texts-after-explode, aa:kai-process-text | MTEXT, TEXT；存在修改调用 | AA整合版本.lsp:8033 |
| KMY | 选中两条水平线后向右生成短线、矩形并居中标注+KM、-KM及直流馈线柜（青色虚线）。 | 无函数形参; 交互: ssget | aa:km-ln-cmd | LINE, LWPOLYLINE, POLYLINE, STYLE, TEXT；存在修改调用 | AA整合版本.lsp:14899 |
| KMZ | 选中两条水平线后向左生成短线、矩形并居中标注+KM、-KM及直流馈线柜（青色虚线）。 | 无函数形参; 交互: ssget | aa:km-ln-cmd | LINE, LWPOLYLINE, POLYLINE, STYLE, TEXT；存在修改调用 | AA整合版本.lsp:14893 |
| LAN | 竖直线/斜线/水平线联动复制+移动插件。 | 无函数形参; 交互: getkword, ssget | aa:cmd-begin, aa:cmd-end, lan-get-option | 未静态确定；存在修改调用 | AA整合版本.lsp:5618 |
| LNY | 选中两条水平线后向右生成短线、矩形并居中标注L、N及相邻屏柜（青色虚线）。 | 无函数形参; 交互: ssget | aa:km-ln-cmd | LINE, LWPOLYLINE, POLYLINE, STYLE, TEXT；存在修改调用 | AA整合版本.lsp:14911 |
| LNZ | 选中两条水平线后向左生成短线、矩形并居中标注L、N及相邻屏柜（青色虚线）。 | 无函数形参; 交互: ssget | aa:km-ln-cmd | LINE, LWPOLYLINE, POLYLINE, STYLE, TEXT；存在修改调用 | AA整合版本.lsp:14905 |
| LOADAICADAA | 加载并初始化 AICAD Ribbon 功能区面板 | 无函数形参; 交互: getfiled | aicadloader:command-load, aicadloader:safe-apply, aicadloader:show-replace-panel, AICADRIBBON.DLL, AICADRIBBONHOST.DLL, AICADRIBBONHOSTV5.DLL, AICADRIBBONHOSTV6.DLL, AICAD_EXTENSION.LSP, LOCATE AICAD_EXTENSION.LSP OR AICADRIBBONHOST.DLL | 未静态确定；存在修改调用 | V6/aicad_aa_loader.lsp:292 |
| LOADAICADZW | 加载并初始化 AICAD Ribbon 功能区面板（别名） | 无函数形参; 交互: getfiled | c:loadaicadaa, AICADRIBBON.DLL, AICADRIBBONHOST.DLL, AICADRIBBONHOSTV5.DLL, AICADRIBBONHOSTV6.DLL, AICAD_EXTENSION.LSP, LOCATE AICAD_EXTENSION.LSP OR AICADRIBBONHOST.DLL | 未静态确定；存在修改调用 | V6/aicad_aa_loader.lsp:300 |
| MING | 按行列网格顺序，批量将单行文字填充到对应属性块的图名属性中。 | 无函数形参; 交互: ssget | aa:cmd-begin, aa:cmd-end, blk-insertpt, ming:cluster-and-sort, ming:find-title-attrib, ming:get-block-height, ming:get-text-info | INSERT, MTEXT, TEXT；未发现直接/可达修改调用 | AA整合版本.lsp:9381 |
| MJ | 框选单列表格后，按最长文字自动收窄宽度并将各行文字居中。 | 无函数形参; 交互: ssget | aa:mj-collect-text-data, aa:mj-frame-bounds, aa:mj-horizontal-ys, aa:mj-move-cached-texts, aa:mj-scale-line-x | LINE, LWPOLYLINE, MTEXT, POLYLINE, TEXT；存在修改调用 | AA整合版本.lsp:10977 |
| NU | 材料表数字加数字，从选中文字中提取数字并执行加法运算。 | 无函数形参; 交互: getreal, ssget; 提示: [NU] 请输入要相加的数值: | aa:nu-rewrite-text | MTEXT, TEXT；存在修改调用 | AA整合版本.lsp:7798 |
| QE | 用 Windows 剪贴板中的文字批量替换选中文字；文字含“至”字时只替换“至”后的部分。 | 无函数形参; 交互: ssget | qe:get-clip-text | ATTDEF, ATTRIB, MTEXT, TEXT；存在修改调用 | AA整合版本.lsp:11797 |
| QH | 只选中已选文字所在行、且位于当前屏幕内、参考文字左右各 1000 内的所有文字（跨多行时逐行选择）。 | 无函数形参; 交互: ssget | aa:merge-sort | MTEXT, TEXT；未发现直接/可达修改调用 | AA整合版本.lsp:15343 |
| QR | 快速修改文字高度。 | 无函数形参; 交互: getdist, ssget; 提示: 请输入新的文字高度: | aa:cmd-begin, aa:cmd-end | MTEXT, TEXT；存在修改调用 | AA整合版本.lsp:3792 |
| QR2 | 连续选择文字并逐轮输入高度进行修改，按 Esc 退出。 | 无函数形参; 交互: getdist, ssget; 提示: 请输入新的文字高度: | aa:cmd-begin, aa:cmd-end | MTEXT, TEXT；存在修改调用 | AA整合版本.lsp:3835 |
| QSTXT | 快速从当前选择中仅选中所有文字对象。 | 无函数形参; 交互: ssget | aa:cmd-begin, aa:cmd-end | 未静态确定；未发现直接/可达修改调用 | AA整合版本.lsp:1367 |
| QW | 提取选中文字，同一行用顿号连接，不同行之间也用顿号分隔，并复制到剪贴板。 | 无函数形参; 交互: ssget | aa:cmd-begin, aa:cmd-end, qw:join, zi:pt, zi:to-clip | MTEXT, TEXT；未发现直接/可达修改调用 | AA整合版本.lsp:12010 |
| QW2 | 提取选中文字及坐标，每项一行“x,y 文字”，坐标保留 2 位小数，复制到剪贴板。 | 无函数形参; 交互: ssget | aa:cmd-begin, aa:cmd-end, aa:merge-sort, zi:pt, zi:to-clip | MTEXT, TEXT；未发现直接/可达修改调用 | AA整合版本.lsp:12051 |
| QW3 | 导出选中对象的类型、图层、坐标、几何及文字属性为结构化文本并复制到剪贴板。 | 无函数形参; 交互: ssget | aa:cmd-begin, aa:cmd-end, aa:merge-sort, aa:qw3-record, zi:to-clip | ARC, ATTDEF, ATTRIB, CIRCLE, DIMENSION, HATCH, INSERT, LINE, LWPOLYLINE, MTEXT, POLYLINE, TEXT；未发现直接/可达修改调用 | AA整合版本.lsp:12323 |
| QZ | 取消当前图纸中的全部分组，组内图元保持不变。 | 无函数形参; 交互: 未发现 / 委托外部界面 | CAD 内置 API | 未静态确定；存在修改调用 | AA整合版本.lsp:14401 |
| REP | 将选中的柜名文字按内置映射表替换为标准柜名。 | 无函数形参; 交互: ssget | aa:cmd-begin, aa:cmd-end, rep-trim | MTEXT, TEXT；未发现直接/可达修改调用 | AA整合版本.lsp:14518 |
| RR | 将选中对象快速改为红色。 | 无函数形参; 交互: ssget | aa:cmd-begin, aa:cmd-end, aa:color-cmd | 未静态确定；存在修改调用 | AA整合版本.lsp:2344 |
| SC3 | 将选中对象整体等比例缩小，使四周距 A3 外框至少 5mm。 | 无函数形参; 交互: ssget | aa:cmd-begin, aa:cmd-end, aa:sc3-entity-bbox, aa:sc3-layer-locked-p | 未静态确定；存在修改调用 | AA整合版本.lsp:16376 |
| SHANG | 将选中文字统一为中上对正，并以最上方文字为基准上对齐。 | 无函数形参; 交互: ssget | aa:align-text-cmd | MTEXT, TEXT；未发现直接/可达修改调用 | AA整合版本.lsp:3430 |
| SJ | 在选中直线顶端生成上接短线。 | 无函数形参; 交互: ssget | aa:cmd-begin, aa:cmd-end | LINE；存在修改调用 | AA整合版本.lsp:4651 |
| SS | 拉伸对象并记忆方向与距离，支持动态拉伸实时预览，后续可直接回车重复。 | 无函数形参; 交互: getpoint, ssget; 提示: 请指定拉伸基点: | aa:cmd-begin, aa:cmd-end, aa:ss-do-interactive-stretch, aa:ss-format-vec | 未静态确定；存在修改调用 | AA整合版本.lsp:4325 |
| SSS | 预先交叉框选表格上方对象，输入目标行高度拉伸，支持小数，默认 10。 | 无函数形参; 交互: getreal, ssget | aa:cmd-begin, aa:cmd-end, aa:sss-find-pair, aa:sss-horizontal-segments, aa:sss-lowest-row-line, aa:sss-pickfirst-box | LINE, LWPOLYLINE, POLYLINE；存在修改调用 | AA整合版本.lsp:4523 |
| SYAN | 将选中直线向上延长 5 个单位。 | 无函数形参; 交互: ssget | aa:extend-line-cmd | LINE；存在修改调用 | AA整合版本.lsp:4634 |
| SYI | 预选对象中非竖直对象向上移动 5X，竖直直线向上拉伸 5X。 | 无函数形参; 交互: getreal, ssget | aa:move-stretch-vertical-cmd | LINE；存在修改调用 | AA整合版本.lsp:4429 |
| SYJ | 将选中竖直直线向上延长 5 个单位，再生成上接短线。 | 无函数形参; 交互: ssget | aa:extend-join-cmd | LINE；存在修改调用 | AA整合版本.lsp:4748 |
| T | 把字体刷为HZ样式，高度3，宽度0.7。 | 无函数形参; 交互: ssget | aa:cmd-begin, aa:cmd-end, txt:run | MTEXT, STYLE, TEXT；存在修改调用 | AA整合版本.lsp:1514 |
| T2 | 将文字刷为HZ/0.7样式并字高优先避让周围线框，优先3.0字高微移，避免文字缩小。 | 无函数形参; 交互: ssget | aa:cmd-begin, aa:cmd-end, txt2:process-selection | ARC, CIRCLE, DIMENSION, INSERT, LEADER, LINE, LWPOLYLINE, MTEXT, POLYLINE, STYLE, TEXT；存在修改调用 | AA整合版本.lsp:2012 |
| TBHB | 将完整直线表格按图纸位置从上到下复制拼接，保留原表及各段标题和列顺序。 | 无函数形参; 交互: getpoint, ssget; 提示: [TBHB] 指定长表的左上角: | aa:merge-sort, aa:tbhb-abort, aa:tbhb-boxes, aa:tbhb-collect, aa:tbhb-group-problem, aa:tbhb-groups, aa:tbhb-inside-p, aa:tbhb-next-top, aa:tbhb-offset, aa:tbhb-seen-line-p, aa:tbhb-shift-point, aa:undo-mark-off, aa:undo-mark-on | CIRCLE, LINE, MTEXT, TEXT；存在修改调用 | AA整合版本.lsp:11242 |
| TONG | 框选文字对象去重，按自然顺序从上到下排列在指定插入点（HZ样式/字高3/宽比0.7/白色/间距5）。 | 无函数形参; 交互: getpoint, ssget; 提示: 请指定放置起点 (从上到下排列): | aa:cmd-begin, aa:cmd-end, aa:merge-sort | MTEXT, STYLE, TEXT；存在修改调用 | AA整合版本.lsp:16578 |
| UNLOAD_AA | 卸载 AICAD 扩展插件（别名） | 无函数形参; 交互: 未发现 / 委托外部界面 | c:unload_aicad | 未静态确定；未发现直接/可达修改调用 | V6/aicad_extension.lsp:1946 |
| UNLOAD_AICAD | 卸载 AICAD 扩展插件及注册环境 | 无函数形参; 交互: 未发现 / 委托外部界面 | aicad:unload | 未静态确定；未发现直接/可达修改调用 | V6/aicad_extension.lsp:1941 |
| UNLOAD_XXX | 卸载 AICAD 扩展插件（别名） | 无函数形参; 交互: 未发现 / 委托外部界面 | c:unload_aicad | 未静态确定；未发现直接/可达修改调用 | V6/aicad_extension.lsp:1950 |
| UPSY | 选中两条水平线后向右生成短线、矩形并居中标注L、N及UPS电源柜（青色虚线）。 | 无函数形参; 交互: ssget | aa:km-ln-cmd | LINE, LWPOLYLINE, POLYLINE, STYLE, TEXT；存在修改调用 | AA整合版本.lsp:14923 |
| UPSZ | 选中两条水平线后向左生成短线、矩形并居中标注L、N及UPS电源柜（青色虚线）。 | 无函数形参; 交互: ssget | aa:km-ln-cmd | LINE, LWPOLYLINE, POLYLINE, STYLE, TEXT；存在修改调用 | AA整合版本.lsp:14917 |
| UT | 先将文字统一为左中对正，再按最上方一对的位置整理文字；支持直线及按首尾端点计算的未闭合多段线，保留宽度。 | 无函数形参; 交互: ssget | aa:normalize-text-horizontal-align, aa:undo-mark-off, aa:undo-mark-on, ut:bbox-bottom, ut:bbox-left, ut:get-bbox, ut:horizontal-line-p, ut:line-y, ut:move, ut:sort-desc | LINE, LWPOLYLINE, MTEXT, POLYLINE, TEXT；存在修改调用 | AA整合版本.lsp:14167 |
| VPO1 | 切换到“单个”标准视口。 | 无函数形参; 交互: 未发现 / 委托外部界面 | aa:cmd-begin, aa:cmd-end | 未静态确定；存在修改调用 | AA整合版本.lsp:16559 |
| VPO2 | 切换到“两个：垂直”标准视口。 | 无函数形参; 交互: 未发现 / 委托外部界面 | aa:cmd-begin, aa:cmd-end | 未静态确定；存在修改调用 | AA整合版本.lsp:16567 |
| WI | 修改选中文字的宽度比例。 | 无函数形参; 交互: getreal, ssget; 提示: 请输入新的文字宽度比例 (例如 0.8 或 1.0): | aa:cmd-begin, aa:cmd-end | MTEXT, TEXT；存在修改调用 | AA整合版本.lsp:3919 |
| WW | 将选中对象快速改为白色；支持尺寸标注（转角标注等全要素变白）、引线及块内实体。 | 无函数形参; 交互: ssget | aa:cmd-begin, aa:cmd-end, aa:deep-color-cmd | DIMENSION, INSERT, LEADER, MTEXT；存在修改调用 | AA整合版本.lsp:2354 |
| XB | 将选中的文字或尺寸标注整体缩小为原来的十分之一，并保留选择状态。 | 无函数形参; 交互: ssget | aa:cmd-begin, aa:cmd-end | DIMENSION, MTEXT, TEXT；存在修改调用 | AA整合版本.lsp:4056 |
| XIA | 将选中文字统一为中下对正，并以最左侧文字为基准下对齐。 | 无函数形参; 交互: ssget | aa:align-text-cmd | MTEXT, TEXT；未发现直接/可达修改调用 | AA整合版本.lsp:3562 |
| XIN | 统计选中直线矩形范围内的对象数量并标注结果。 | 无函数形参; 交互: ssget | aa:cmd-begin, aa:cmd-end | LINE, TEXT；存在修改调用 | AA整合版本.lsp:5761 |
| XJ | 在选中直线底端生成下接短线。 | 无函数形参; 交互: ssget | aa:cmd-begin, aa:cmd-end | LINE；存在修改调用 | AA整合版本.lsp:4679 |
| XU | 将所有选中且支持线型修改的对象改为 HIDDEN2。 | 无函数形参; 交互: ssget | CAD 内置 API | 未静态确定；存在修改调用 | AA整合版本.lsp:2365 |
| XX | 将选中文字内容替换为 7×2.5。 | 无函数形参; 交互: entsel, ssget | aa:cmd-begin, aa:cmd-end | MTEXT, TEXT；未发现直接/可达修改调用 | AA整合版本.lsp:15164 |
| XY | 自动筛选所选中的绿色水平直线，先运行 XIN 统计芯数，再运行 YUAN 提取对应文字并横向输出。 | 无函数形参; 交互: ssget | aa:cmd-begin, aa:cmd-end, xy:run-xin, xy:run-yuan | LINE, MTEXT, TEXT；存在修改调用 | AA整合版本.lsp:6705 |
| XYAN | 将选中直线向下延长 5 个单位。 | 无函数形参; 交互: ssget | aa:extend-line-cmd | LINE；存在修改调用 | AA整合版本.lsp:4637 |
| XYG | 一次框选，自动提取绿色直线执行 XY 统计，并提取大字与电缆文字执行 GTX 分类汇总。 | 无函数形参; 交互: getpoint, ssget; 提示: [XYG] 请指定汇总结果的插入点: | aa:cmd-begin, aa:cmd-end, aa:gtx-find-last-char, aa:gtx-key, aa:gtx-select-prefix-text, aa:merge-sort, aa:ysdl-get-plain-text, xy:filter-green-hlines, xy:run-xin, xy:run-yuan, xy:ss->list, xyg:dedup-hlines, xyg:find-prefix-text, xyg:find-rect-texts, xyg:find-right-new-texts, xyg:output-gtx-matrix | LINE, MTEXT, STYLE, TEXT；存在修改调用 | AA整合版本.lsp:7027 |
| XYI | 预选对象中非竖直对象向下移动 5X，竖直直线向下拉伸 5X。 | 无函数形参; 交互: getreal, ssget | aa:move-stretch-vertical-cmd | LINE；存在修改调用 | AA整合版本.lsp:4430 |
| XYJ | 将选中竖直直线向下延长 5 个单位，再生成下接短线。 | 无函数形参; 交互: ssget | aa:extend-join-cmd | LINE；存在修改调用 | AA整合版本.lsp:4749 |
| Y | 将选中对象的颜色快速变为青色。 | 无函数形参; 交互: ssget | aa:cmd-begin, aa:cmd-end, aa:color-cmd | 未静态确定；存在修改调用 | AA整合版本.lsp:2324 |
| YAN | 延长竖直直线统一间距，支持分组和上下方向控制。 | 无函数形参; 交互: getkword, ssget; 提示: 请输入分组数量 [2/4]: / 请输入延伸方向 [向上(Up)/向下(Down)]: | aa:insert-sort | LINE；存在修改调用 | AA整合版本.lsp:4115 |
| YDY | 选中多条水平线后向右生成短线、矩形并从上往下标注701、-901、-903...及公用测控柜（青色虚线）。 | 无函数形参; 交互: ssget | aa:yd-cmd | LINE, LWPOLYLINE, POLYLINE, STYLE, TEXT；存在修改调用 | AA整合版本.lsp:15151 |
| YDZ | 选中多条水平线后向左生成短线、矩形并从上往下标注701、-901、-903...及公用测控柜（青色虚线）。 | 无函数形参; 交互: ssget | aa:yd-cmd | LINE, LWPOLYLINE, POLYLINE, STYLE, TEXT；存在修改调用 | AA整合版本.lsp:15145 |
| YJ | 选中两条水平线后向右生成短线、矩形并居中标注原理号及终点柜名（青色虚线）。 | 无函数形参; 交互: ssget | aa:km-ln-cmd | LINE, LWPOLYLINE, POLYLINE, STYLE, TEXT；存在修改调用 | AA整合版本.lsp:14947 |
| YOU | 将选中文字统一为右中对正，并以最上方文字为基准右对齐。 | 无函数形参; 交互: ssget | aa:align-text-cmd | MTEXT, TEXT；未发现直接/可达修改调用 | AA整合版本.lsp:3299 |
| YS | 选取两点生成绿色直线及终点直径100的同层全绿晶体机械徽章，无中央字母标志。 | 无函数形参; 交互: getpoint; 提示: YS 指定直线起点: / 指定终点（徽章中心）: | aa:cmd-begin, aa:cmd-end, aa:ys-detail, aa:ys-line, aa:ys-rim, aa:ys-ring, aa:ys-snowflake | CIRCLE, LINE；存在修改调用 | AA整合版本.lsp:290 |
| YS1 | 选取两点生成绿色直线，以第二点为中心生成高80的TGOOD机械装甲线条Logo，可整体撤销。 | 无函数形参; 交互: getpoint; 提示: YS1 指定直线起点: / 指定终点（TGOOD图案中心）: | aa:cmd-begin, aa:cmd-end, aa:ys-line, aa:ys1-d, aa:ys1-g, aa:ys1-o, aa:ys1-t | ARC, LINE；存在修改调用 | AA整合版本.lsp:468 |
| YSDL | 提取选中文字到CSV文件，并改变文字颜色。 | 无函数形参; 交互: ssget | aa:insert-sort, aa:set-entity-aci-color, aa:undo-mark-off, aa:undo-mark-on, aa:ysdl-build-csv-field, aa:ysdl-get-plain-text | MTEXT, TEXT；存在修改调用 | AA整合版本.lsp:1237 |
| YY | 将选中对象快速改为黄色。 | 无函数形参; 交互: ssget | aa:cmd-begin, aa:cmd-end, aa:color-cmd | 未静态确定；存在修改调用 | AA整合版本.lsp:2334 |
| Z0 | 将选中对象的 Z 坐标全部归零（压平到 XY 平面）。 | 无函数形参; 交互: ssget; 提示: :L | aa:cmd-begin, aa:cmd-end, aa:z0-data-flat-p, aa:z0-layer-locked-p, aa:z0-one, aa:z0-polyline-flat-p, aa:z0-polyline-verts | POLYLINE；存在修改调用 | AA整合版本.lsp:16510 |
| ZDML | 选择多个图框块，生成目录文字。 | 无函数形参; 交互: getpoint, ssget; 提示: 指定第 1 页目录表左上角: | aa:cmd-begin, aa:cmd-end, tktj:collect-one-block, tktj:draw-table, tktj:drop, tktj:safe-vla-object, tktj:sort-by-page, tktj:sort-by-position, tktj:take | INSERT；存在修改调用 | AA整合版本.lsp:13092 |
| ZDML2 | 指定基准块参照与图名、图号矩形范围，批量提取图名图号并生成目录。 | 无函数形参; 交互: entsel, getcorner, getpoint, ssget; 提示: [ZDML2] 指定第 1 页目录表左上角: / [ZDML2] 请点击选择基准图框块参照: | aa:cmd-begin, aa:cmd-end, blk-insertpt, hao2:block-name, hao2:sort-blocks, tktj:draw-table, tktj:drop, tktj:take, zdml2:build-spatial-index, zdml2:collect-all-texts, zdml2:extract-rect-text-fast, zdml2:query-rect-index | INSERT, MTEXT, TEXT；存在修改调用 | AA整合版本.lsp:13234 |
| ZDMLDEBUG | 选择一个图框块，打印所有增强属性。 | 无函数形参; 交互: entsel; 提示: 请选择一个图框块: | aa:cmd-begin, aa:cmd-end, tktj:get-attributes | INSERT；未发现直接/可达修改调用 | AA整合版本.lsp:13408 |
| ZDWI | 按各列最宽文字自动调整表格列宽，文字左右各留 3 个图纸单位。 | 无函数形参; 交互: ssget | aa:cmd-begin, aa:cmd-end, aa:merge-sort, aa:safe-get-bbox, aa:zdwi-add-span, aa:zdwi-column, aa:zdwi-expand-selection, aa:zdwi-map-entity, aa:zdwi-set-nth, aa:zdwi-unique, aa:zdwi-vertices, aa:zz-move-text | LINE, LWPOLYLINE, MTEXT, POLYLINE, TEXT；存在修改调用 | AA整合版本.lsp:11515 |
| ZHENG | 以水平直线或矩形中心为基准整理文字的水平位置。 | 无函数形参; 交互: ssget | aa:safe-get-bbox, aa:zheng-add-texts-after-explode, aa:zheng-align-text-center-x, aa:zheng-align-text-to-rect-center, aa:zheng-horizontal-line-p, aa:zheng-line-mid-x | LINE, LWPOLYLINE, MTEXT, POLYLINE, TEXT；存在修改调用 | AA整合版本.lsp:8187 |
| ZHONG | 文字居中对齐；选择直线/矩形时按中心 X 居中。 | 无函数形参; 交互: ssget | aa:align-text-cmd | MTEXT, TEXT；未发现直接/可达修改调用 | AA整合版本.lsp:2790 |
| ZJ | 选中两条水平线后向左生成短线、矩形并居中标注原理号及终点柜名（青色虚线）。 | 无函数形参; 交互: ssget | aa:km-ln-cmd | LINE, LWPOLYLINE, POLYLINE, STYLE, TEXT；存在修改调用 | AA整合版本.lsp:14941 |
| ZS | 选中物体单向纵向缩放，上下高度改变，宽度保持不变。 | 无函数形参; 交互: getdist, getpoint, ssget; 提示: :L / 指定新长度: | aa:cmd-begin, aa:cmd-end, aa:hs-filter-unlocked, aa:hs-get-ss-bbox | 未静态确定；存在修改调用 | AA整合版本.lsp:16172 |
| ZTF | 搜索系统字体并将选定字体写入指定文字样式。 | 无函数形参; 交互: entsel; 提示: 选择一段文字以读取其文字样式： | aa:cmd-begin, aa:cmd-end, ztf:collect-font-records, ztf:run-dialog, ZTF.DCL, \\ZTF.DCL | MTEXT, STYLE, TEXT；未发现直接/可达修改调用 | AA整合版本.lsp:919 |
| ZUO | 将选中文字统一为左中对正，并以最上方文字为基准左对齐。 | 无函数形参; 交互: ssget | aa:align-text-cmd | MTEXT, TEXT；未发现直接/可达修改调用 | AA整合版本.lsp:2875 |
| ZZ | 先将文字改为中下对正，再居中到最近矩形；多行文字按 5 个单位的中心间距排列。 | 无函数形参; 交互: ssget | aa:zz-run | LINE, LWPOLYLINE, MTEXT, POLYLINE, TEXT；存在修改调用 | AA整合版本.lsp:10828 |
