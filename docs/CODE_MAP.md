# AA整合版本.lsp 代码地图

> 由 `python tools/code_map.py write` 自动生成（`python gen_命令索引.py` 也会顺带生成），请勿手工维护。
> 行号随源码变动；改完 LISP 后重新生成，`python tools/check_all_static.py` 会校验本文件是否过期。

## 使用方法（给 AI / 人）

1. **不要通读整合文件。** 先在下表找命令的行号范围，再按行号只读那一段。
2. `python tools/code_map.py show 命令或函数` 直接输出行号范围和下游调用（加 `--source` 打印源码）。
3. 改共享函数前先跑 `python tools/code_map.py callers 函数名`，确认影响哪些命令。
4. 改动过程中用 `python tools/check_all_static.py --quick` 只跑相关检查；交付前跑一次不带参数的全量检查。

- 源文件：`AA整合版本.lsp`，28252 行，1212 个函数，其中 183 个 `c:` 命令。

## 命令

| 命令 | 行号 | 行数 | 说明 | 直接调用的项目函数（行号） |
|------|------|------|------|------|
| `YS` | 342-391 | 50 | 选取两点生成绿色直线及终点直径100的同层全绿晶体机械徽章，无中央字母标志。 | aa:cmd-begin:714, aa:ys-line:265, aa:ys-ring:334, aa:ys-rim:323, aa:ys-snowflake:291, aa:ys-detail:316, aa:cmd-end:727 |
| `YS1` | 520-546 | 27 | 选取两点生成绿色直线，以第二点为中心生成高80的TGOOD机械装甲线条Logo，可整体撤销。 | aa:cmd-begin:714, aa:ys-line:265, aa:ys1-t:420, aa:ys1-g:437, aa:ys1-o:457, aa:ys1-d:494, aa:cmd-end:727 |
| `DES` | 580-645 | 66 | 所选直线共线重叠时删除短线、保留长线；完全重复留一条，跨图层处理并跳过锁定图层。 | aa:cmd-begin:714, des:key-less-p:549, aa:merge-sort:802, des:record-less-p:554, des:x-less-p:558, des:overlap-p:564, aa:cmd-end:727 |
| `YSTEMP` | 658-712 | 55 | 删除所选对象中竖直共线、首尾相接且长度分别为 21 和 7 的直线对。 | aa:cmd-begin:714, aa:merge-sort:802, ystemp:y-less-p:648, ystemp:pair-p:652, aa:cmd-end:727 |
| `ZTF` | 1062-1075 | 14 | 搜索系统字体并将选定字体写入指定文字样式。 | aa:cmd-begin:714, ztf:collect-font-records:932, ztf:run-dialog:1032, aa:cmd-end:727 |
| `YSDL` | 1618-1819 | 202 | 提取选中文字到CSV文件，并改变文字颜色。 | aa:undo-mark-off:753, aa:undo-mark-on:745, aa:ysdl-get-plain-text:1399, aa:ysdl-get-lwpoly-rect:1453, aa:ysdl-sort-boxes:1520, aa:ysdl-desktop-dir:1596, aa:merge-sort:802, aa:ysdl-parse-rows-from-text-data:1548, aa:ysdl-clean-text:1423, aa:ysdl-format-categorized-row:1588, aa:ysdl-build-csv-field:1414, aa:ysdl-reorder-row:1431 …共 13 个 |
| `Q` | 1831-1857 | 27 | 快速从当前选择中仅选中所有文字对象。 | aa:cmd-begin:714, aa:cmd-end:727 |
| `T` | 2072-2076 | 5 | 把文字及ATTDEF属性定义刷为HZ样式，高度3，宽度0.7；按可见范围保持对齐文字位置。 | aa:cmd-begin:714, txt:run:2055, aa:cmd-end:727 |
| `ZHU` | 2128-2172 | 45 | 选中端子排名和端子号文字，选短接或拆除连片，生成HZ/3/0.7的“注：”单行文字。 | aa:cmd-begin:714, aa:ysdl-get-plain-text:1399, zhu:classify:2097, zhu:trim:2085, zhu:pick-name:2116, zhu:build-note:2107, aa:cmd-end:727 |
| `HWT` | 2395-2446 | 52 | 框选一列柜名文字，按从上到下顺序每行最多5个蛇形排列，生成L1/N1端子、SML电缆编号和两端JL进线的环网图，并输出可供BH3登记的电缆清单。 | aa:cmd-begin:714, aa:ysdl-get-plain-text:1399, aa:merge-sort:802, hwt:counts-text:2318, hwt:row-counts:2180, hwt:draw:2343, hwt:layout:2224, hwt:cable-no:2190, hwt:draw-list:2372, hwt:cable-rows:2305, aa:cmd-end:727 |
| `T2` | 2603-2607 | 5 | 把文字及ATTDEF属性定义刷为宋体样式，高度3，宽度0.8；按可见范围保持对齐文字位置。 | aa:cmd-begin:714, txt2:run:2590, aa:cmd-end:727 |
| `DH` | 2818-2822 | 5 | 把选中的多行文字转成规整的单行文字，保持原位置和对齐，文字不再碎成多段。 | aa:cmd-begin:714, dh:run:2799, aa:cmd-end:727 |
| `ABCN` | 2839-2890 | 52 | 指定一点生成青色 A、B、C、N 单行文字，HZ/3/0.7、左中对正、按 H 默认间距5向下排列。 | aa:cmd-begin:714, aa:safe-get-bbox:1110, aa:safe-move-entity:1156, aa:cmd-end:727 |
| `H` | 2892-3019 | 128 | 先将选中文字统一为左中对正，再按指定间距（插入点/对齐点之间）从上到下排列。 | aa:cmd-begin:714, aa:normalize-text-horizontal-align:3787, aa:merge-sort:802, aa:cmd-end:727 |
| `H2` | 3026-3150 | 125 | 先将选中文字统一为左中对正，右侧文字在最上、越靠左越靠下，按指定间距从上到下排列。 | aa:cmd-begin:714, aa:normalize-text-horizontal-align:3787, aa:merge-sort:802, aa:cmd-end:727 |
| `Y` | 3176-3180 | 5 | 将选中对象的颜色快速变为青色。 | aa:cmd-begin:714, aa:color-cmd:3157, aa:cmd-end:727 |
| `DZ` | 3220-3254 | 35 | 将所选其他文字改为Y命令的青色，保留纯数字及数字后接单个小写a的文字原色。 | aa:cmd-begin:714, aa:ysdl-get-plain-text:1399, aa:dz-number-p:3186, aa:dz-color-text:3202, aa:cmd-end:727 |
| `YY` | 3260-3264 | 5 | 将选中对象快速改为黄色。 | aa:cmd-begin:714, aa:color-cmd:3157, aa:cmd-end:727 |
| `RR` | 3270-3274 | 5 | 将选中对象快速改为红色。 | aa:cmd-begin:714, aa:color-cmd:3157, aa:cmd-end:727 |
| `WW` | 3280-3284 | 5 | 将选中对象快速改为白色。 | aa:cmd-begin:714, aa:color-cmd:3157, aa:cmd-end:727 |
| `WWW` | 3290-3296 | 7 | 将选中对象强制改为白色；尺寸标注全要素变白，引线先分解再变白，块参照连块内实体一起改。 | aa:cmd-begin:714, aa:deep-color-cmd:3615, aa:cmd-end:727 |
| `XU` | 3302-3376 | 75 | 将所有选中且支持线型修改的对象改为 HIDDEN2。 |  |
| `GG` | 3382-3386 | 5 | 将选中对象快速改为绿色。 | aa:cmd-begin:714, aa:color-cmd:3157, aa:cmd-end:727 |
| `PP` | 3392-3396 | 5 | 将选中对象快速改为洋红色。 | aa:cmd-begin:714, aa:color-cmd:3157, aa:cmd-end:727 |
| `HH` | 3402-3406 | 5 | 将选中对象快速改为颜色 8（与 HUI 同色）。 | aa:cmd-begin:714, aa:color-cmd:3157, aa:cmd-end:727 |
| `HUI` | 3672-3677 | 6 | 将选中对象强制改为颜色 8；尺寸标注全要素改色，引线先分解再改色，块参照连块内实体一起改。 | aa:cmd-begin:714, aa:deep-color-cmd:3615, aa:cmd-end:727 |
| `ZHONG` | 3731-3735 | 5 | 文字居中对齐；选择直线/矩形时按中心 X 居中。 | aa:align-text-cmd:3680, aa:find-ref-by-top-bbox:1222, aa:bbox-center-x:1134, aa:normalize-visual-h:3874, aa:align-text-horizontal-by-bbox:1262 |
| `ZUO` | 3885-3889 | 5 | 将选中文字按视觉左侧统一对正（旋转文字按方向换算），并以最左侧文字为基准左对齐。 | aa:align-text-cmd:3680, aa:find-ref-by-left-bbox:1182, aa:bbox-left-x:1140, aa:normalize-visual-h:3874, aa:align-text-horizontal-by-bbox:1262 |
| `AZUO` | 3895-4014 | 120 | 选择一条竖直直线作为基准线，框选其他所有对象作为一个整体整体移动并左对齐到该直线。 | aa:cmd-begin:714, aa:cmd-end:727, aa:safe-get-bbox:1110, aa:bbox-left-x:1140, aa:safe-move-entity:1156 |
| `HP` | 4020-4157 | 138 | 将选中文字按从左到右排列，使相邻文字首尾间距为指定值，并按最左文字上边对齐。 | aa:cmd-begin:714, aa:cmd-end:727, aa:safe-get-bbox:1110, aa:bbox-left-x:1140, aa:bbox-top-y:1148, aa:merge-sort:802, aa:bbox-right-x:1144, aa:safe-move-entity:1156 |
| `HP2` | 4163-4306 | 144 | 将选中文字改为正中对齐，按中心点指定间距从左到右横向排列。 | aa:cmd-begin:714, aa:cmd-end:727, aa:normalize-text-horizontal-align:3787, aa:safe-get-bbox:1110, aa:bbox-center-x:1134, aa:bbox-top-y:1148, aa:bbox-bottom-y:1152, aa:merge-sort:802, aa:safe-move-entity:1156 |
| `YOU` | 4309-4313 | 5 | 将选中文字按视觉右侧统一对正（旋转文字按方向换算），并以最右侧文字为基准右对齐。 | aa:align-text-cmd:3680, aa:find-ref-by-right-bbox:1202, aa:bbox-right-x:1144, aa:normalize-visual-h:3874, aa:align-text-horizontal-by-bbox:1262 |
| `AYOU` | 4318-4437 | 120 | 选择一条竖直直线作为基准线，框选其他所有对象作为一个整体整体移动并右对齐到该直线。 | aa:cmd-begin:714, aa:cmd-end:727, aa:safe-get-bbox:1110, aa:bbox-right-x:1144, aa:safe-move-entity:1156 |
| `SHANG` | 4440-4444 | 5 | 将选中文字按视觉上方统一对正（竖排文字定位点在顶端），并以最上方文字为基准上对齐。 | aa:align-text-cmd:3680, aa:find-ref-by-top-bbox:1222, aa:bbox-top-y:1148, aa:normalize-visual-v:3879, aa:align-text-vertical-by-bbox:1276 |
| `ASHANG` | 4450-4569 | 120 | 选择一条水平直线作为基准线，框选其他所有对象作为一个整体整体移动并向上对齐到该直线。 | aa:cmd-begin:714, aa:cmd-end:727, aa:safe-get-bbox:1110, aa:bbox-top-y:1148, aa:safe-move-entity:1156 |
| `XIA` | 4572-4576 | 5 | 将选中文字按视觉下方统一对正（竖排文字定位点在底端），并以最下方文字为基准下对齐。 | aa:align-text-cmd:3680, aa:find-ref-by-bottom-bbox:1242, aa:bbox-bottom-y:1152, aa:normalize-visual-v:3879, aa:align-text-vertical-by-bbox:1276 |
| `AXIA` | 4581-4700 | 120 | 选择一条水平直线作为基准线，框选其他所有对象作为一个整体整体移动并向下对齐到该直线。 | aa:cmd-begin:714, aa:cmd-end:727, aa:safe-get-bbox:1110, aa:bbox-bottom-y:1152, aa:safe-move-entity:1156 |
| `HE` | 4702-4795 | 94 | 将同一行的两个或以上文字合并。 | aa:cmd-begin:714, aa:insert-sort:774, aa:cmd-end:727 |
| `QR` | 4830-4875 | 46 | 快速修改文字高度，记忆上次高度，回车沿用。 | aa:cmd-begin:714, qr:last-height:4806, qr:height-str:4825, qr:save-height:4818, aa:cmd-end:727 |
| `QR2` | 4881-4911 | 31 | 连续选择文字修改高度，与 QR 共用上次高度；高度回车沿用，选择回车或 Esc 退出。 | aa:cmd-begin:714, qr:last-height:4806, qr:height-str:4825, qr:save-height:4818, aa:cmd-end:727 |
| `DEA` | 4917-4940 | 24 | 删除所选对象中高度小于 0.1 的 TEXT/MTEXT 文字。 | aa:cmd-begin:714, aa:cmd-end:727 |
| `DEK` | 4947-4967 | 21 | 删除选中内容中的所有块参照 (INSERT)。 | aa:cmd-begin:714, aa:cmd-end:727 |
| `DEH` | 5010-5040 | 31 | 删除所选对象中内容含有中文的 TEXT/MTEXT 文字。 | aa:cmd-begin:714, aa:has-chinese:4988, aa:ysdl-get-plain-text:1399, aa:layer-locked-p:4973, aa:cmd-end:727 |
| `DET` | 5070-5111 | 42 | 删除所选对象中内容为指定值(逗号或空格分隔、不区分大小写、回车沿用上次)的属性定义ATTDEF。 | aa:cmd-begin:714, det:split-values:5050, aa:ysdl-get-raw-text:1314, aa:layer-locked-p:4973, aa:cmd-end:727 |
| `A2T` | 5150-5187 | 38 | 将属性定义ATTDEF（炸块残留、X/BURST无法分解）转为普通单行文字，可选标记/默认值/提示。 | aa:cmd-begin:714, a2t:pick-string:5128, a2t:layer-locked-p:5123, a2t:text-dxf:5140, aa:cmd-end:727 |
| `WI` | 5193-5233 | 41 | 修改选中文字的宽度比例。 | aa:cmd-begin:714, aa:cmd-end:727 |
| `ATW` | 5240-5324 | 85 | 拾取两点指定最大宽度，将超宽单行文字的宽度比例缩小至两点间距的 95% 并保持左侧不动。 | aa:cmd-begin:714, aa:safe-get-bbox:1110, aa:bbox-right-x:1144, aa:bbox-left-x:1140, aa:safe-move-entity:1156, aa:cmd-end:727 |
| `XB` | 5330-5383 | 54 | 将选中的文字或尺寸标注整体缩小为原来的十分之一，并保留选择状态。 | aa:cmd-begin:714, aa:cmd-end:727 |
| `YAN` | 5389-5505 | 117 | 延长竖直直线统一间距，支持分组和上下方向控制。 | aa:insert-sort:774 |
| `LL` | 5516-5545 | 30 | 水平/竖直连续画直线并实时预览，结束恢复正交、捕捉与跟踪设置。 | aa:ortho-restore-vars:5671, aa:undo-mark-off:753, aa:undo-mark-on:745 |
| `MM` | 5694-5726 | 33 | 水平/竖直移动并实时预览，第二点可捕捉或输入距离，偏斜自动投影。 | aa:ortho-restore-vars:5671, aa:undo-mark-off:753, aa:undo-mark-on:745, aa:ortho-report:5660, aa:ortho-drag:5620 |
| `SS` | 5732-5764 | 33 | 水平/竖直拉伸并实时预览实体变形，第二点可捕捉或输入距离，偏斜自动投影。 | aa:ortho-restore-vars:5671, aa:undo-mark-off:753, aa:undo-mark-on:745, aa:ortho-report:5660, aa:ortho-drag:5620 |
| `SW` | 5853-5908 | 56 | 拉伸对象并记忆方向与距离，支持动态拉伸实时预览，后续可直接回车重复。 | aa:cmd-begin:714, aa:cmd-error:243, aa:ss-format-vec:5772, aa:ss-do-interactive-stretch:5818, aa:cmd-end:727 |
| `SYI` | 6018-6018 | 1 | 预选对象中非竖直对象向上移动 5X，竖直直线向上拉伸 5X；自动补选短斜线左侧与水平线相交的竖直线。 | aa:move-stretch-vertical-cmd:5951 |
| `XYI` | 6019-6019 | 1 | 预选对象中非竖直对象向下移动 5X，竖直直线向下拉伸 5X；自动补选短斜线左侧与水平线相交的竖直线。 | aa:move-stretch-vertical-cmd:5951 |
| `ZYI` | 6150-6150 | 1 | 预选对象中非水平对象向左移动 5X，水平直线向左拉伸 5X；自动补选短斜线处与竖直线相交的水平线。 | aa:move-stretch-horizontal-cmd:6062 |
| `YYI` | 6156-6156 | 1 | 预选对象中非水平对象向右移动 5X，水平直线向右拉伸 5X；自动补选短斜线处与竖直线相交的水平线。 | aa:move-stretch-horizontal-cmd:6062 |
| `SSS` | 6248-6319 | 72 | 交叉框选调整下沿所在行高度，支持小数，默认 10。 | aa:sss-pickfirst-box:6210, aa:sss-lowest-row-line:6236, aa:sss-find-pair:6183, aa:sss-horizontal-segments:6162, aa:cmd-begin:714, aa:cmd-end:727 |
| `SYAN` | 6362-6362 | 1 | 将选中直线向上延长 5 个单位。 | aa:extend-line-cmd:6322 |
| `XYAN` | 6365-6365 | 1 | 将选中直线向下延长 5 个单位。 | aa:extend-line-cmd:6322 |
| `SJ` | 6379-6405 | 27 | 在选中直线顶端生成上接短线。 | aa:cmd-begin:714, aa:cmd-end:727 |
| `XJ` | 6407-6433 | 27 | 在选中直线底端生成下接短线。 | aa:cmd-begin:714, aa:cmd-end:727 |
| `SYJ` | 6476-6476 | 1 | 将选中竖直直线向上延长 5 个单位，再生成上接短线。 | aa:extend-join-cmd:6434 |
| `XYJ` | 6477-6477 | 1 | 将选中竖直直线向下延长 5 个单位，再生成下接短线。 | aa:extend-join-cmd:6434 |
| `GTX` | 6607-6787 | 181 | 按自动容差整理单行/多行电缆文字并自然排序汇总。 | aa:undo-mark-off:753, aa:undo-mark-on:745, aa:gtx-select-prefix-text:6591, aa:ysdl-get-plain-text:1399, aa:try-get-bbox:1099, aa:merge-sort:802, aa:gtx-rows:6550, aa:gtx-key:6519, aa:gtx-find-last-char:6507, aa:gtx-natural-less:6527, aa:gtx-create-text-entity:6567 |
| `GTY` | 7030-7177 | 148 | 保留原文字，按电缆编号排序整理并复制到指定位置。 | aa:gty-delete-copies:7021, aa:gty-get-text-width:6858, aa:gty-separated-rows:6893, aa:gty-add-row:6927, aa:merge-sort:802, aa:gty-get-item-x:6826, aa:gty-order-rows:6977, aa:gty-column-widths:6989, aa:gty-row-tree:6939, aa:gty-build-sort-key:6834, aa:gty-tree-item:6950, aa:gty-copy-text:7001 …共 14 个 |
| `GTY2` | 7322-7366 | 45 | 把选中电缆文字按 GTY 规则排序整理后放进 CAD 剪贴板，到另一张图 Ctrl+V 粘贴；原文字不变。 | aa:cmd-begin:714, aa:gty-delete-copies:7021, aa:cmd-error:243, gty2:locked-layer:7269, gty2:layout:7183, aa:gty-get-item-pt:6825, aa:gty-get-item-ename:6823, gty2:make-copies:7280, gty2:to-clip:7308, aa:cmd-end:727 |
| `GTZ` | 7372-7529 | 158 | 将选中的交替柜名与电缆编号单列文字，按前后柜与编号重组为3列表格输出。 | aa:gty-get-text-width:6858, aa:merge-sort:802, aa:gty-move-entity:6880 |
| `HWD` | 7556-7629 | 74 | 横排交替柜名与电缆编号重组为起点、编号、终点三列，左中对齐、行距5，保留原横排。 | aa:cmd-begin:714, aa:safe-get-bbox:1110, aa:gty-get-text-width:6858, aa:merge-sort:802, aa:hwd-rows:7535, aa:hwd-make-text:7542, aa:cmd-end:727 |
| `BIAN` | 7685-7715 | 31 | 根据选中直线生成方向三角、至字样和电缆规格标注。 | aa:cmd-begin:714, bian-draw-one:7657, aa:cmd-end:727 |
| `LAN` | 7755-7903 | 149 | 竖直线/斜线/水平线联动复制+移动插件。 | aa:cmd-begin:714, lan-vert-mode:7726, lan-get-option:7740, aa:cmd-end:727 |
| `XIN` | 7910-8000 | 91 | 统计选中直线矩形范围内的对象数量并标注结果。 | aa:cmd-begin:714, aa:cmd-end:727 |
| `XY` | 9164-9178 | 15 | 处理所选电缆线（水平线，或绿色竖直线），先运行 XIN 统计芯数，再运行 YUAN 提取原理号；水平线横向输出，竖直线在底端下方输出 270° 文字。 | aa:cmd-begin:714, xy:run-xin:8382, xy:run-yuan:8970, aa:cmd-end:727 |
| `XYG` | 10202-10202 | 1 | 一次框选，自动提取绿色水平/竖直电缆线执行 XY 统计，并提取大字与电缆文字执行 GTX 分类汇总。 | xyg:run:10004 |
| `XYG2` | 10205-10205 | 1 | 与 XYG 相同的框选和汇总表，但原图不留痕：电缆后面不留芯数和原理号，异常电缆线也不改色、不延长。 | xyg:run:10004 |
| `XYG3` | 10208-10208 | 1 | 与 XYG2 一样不留痕，并把 1(2)# 合画电缆拆成各柜两行，汇总表先排完 1# 再排 2#。 | xyg:run:10004 |
| `SX0` | 10658-10697 | 40 | 清除联动标记：框选文字，删除副本的联动标记使其成为普通文字；原件自动跳过。 | aa:cmd-begin:714, aa:link-dwg-id:10268, aa:link-info:10224, aa:link-root-p:10264, aa:cmd-end:727 |
| `YSSX0` | 10704-10744 | 41 | 强制清除联动标记：框选文字，原件和副本的联动标记一并删除，全部成为普通文字。 | aa:cmd-begin:714, aa:link-dwg-id:10268, aa:link-info:10224, aa:link-root-p:10264, aa:cmd-end:727 |
| `SX` | 10769-10807 | 39 | 联动标记：框选原件端子排文字发放唯一编号（UID），草稿/XY/XYG/GTY 副本自动继承。 | aa:cmd-begin:714, aa:link-dwg-id:10268, aa:link-info:10224, aa:link-root-p:10264, aa:link-export-roots:10751, aa:cmd-end:727 |
| `SXC` | 10827-10916 | 90 | 查看联动标记：选文字（回车=本图全部已标记文字），列出是未标记、原件、副本、原件缺失还是他图副本，点结果卡片条目定位；只读。 | aa:cmd-begin:714, aa:rep-begin:21044, aa:link-dwg-id:10268, aa:link-info:10224, aa:rep-item:21055, aa:link-txt:10822, aa:link-root-p:10264, aa:link-root-ed:11151, aa:link-dwg-label:10814, aa:merge-sort:802, aa:rep-info:21061, aa:rep-counts:21110 …共 14 个 |
| `SXD` | 11098-11144 | 47 | 跳到原件：点选文字，缩放到它的原件；原件在其他图纸时按图名找到该图，打开或切换过去；只读。 | aa:link-pick-text:11082, aa:link-info:10224, aa:link-dwg-id:10268, aa:link-root-ed:11151, aa:link-write-jump:10968, aa:link-locate-dwg:11073, aa:link-default-dir:10620, aa:link-dwg-label:10814, aa:link-ask-folder:10643, aa:link-remember-dir:10630, aa:link-send-later:10998 |
| `SX1` | 11170-11244 | 75 | 联动刷新：全图所有同 UID 的副本文字按原件内容单向更新（只同步文字内容），已保存的图同时导出跨图值文件。 | aa:cmd-begin:714, aa:link-clock:11146, aa:link-dwg-id:10268, aa:link-info:10224, aa:link-root-p:10264, aa:link-root-ed:11151, aa:link-split-text:10247, aa:ysdl-get-plain-text:1399, aa:link-text-for:10286, aa:link-file-path:10318, aa:link-export:10357, aa:cmd-end:727 |
| `SX2` | 11252-11332 | 81 | 跨图联动刷新：读取指定文件夹内各卷册图的 .aalink.txt 值文件，更新本图中原件在其他图纸的副本文字。 | aa:cmd-begin:714, aa:link-dwg-id:10268, aa:link-info:10224, aa:link-ask-folder:10643, aa:link-near-dir:10635, aa:link-collect-files:10554, aa:link-remember-dir:10630, aa:merge-sort:802, aa:link-file-time:10545, aa:link-filter-values:10507, aa:link-read-file:10402, aa:link-uid<:10308 …共 17 个 |
| `HBDL` | 11639-11744 | 106 | 框选电缆清册表格文字，自动将带有“并入”前缀的行合并到对应的目标电缆主行中，自动累加芯数并在末尾追加原理号，其他行保持原位。 | aa:cmd-begin:714, aa:cmd-end:727, aa:ysdl-get-plain-text:1399, hb:cluster-rows:11409, hb:parse-row:11438, hb:apply-merge-in-place:11554 |
| `NU` | 12040-12091 | 52 | 材料表数字加数字：优先改井号相邻数字，其次改最后一个减号后的连续整数，都没有时改第一个数字（支持小数和正负号）。 | aa:nu-rewrite-text:11989, aa:num-int-target-p:11970 |
| `KAI` | 12282-12365 | 84 | 将 TEXT/MTEXT 中由空格分隔的内容拆分为多个独立文字。 | aa:kai-add-texts-after-explode:12221, aa:kai-process-text:12239 |
| `ZHENG` | 12436-12566 | 131 | 以水平直线或矩形中心为基准整理文字的水平位置。 | aa:zheng-horizontal-line-p:12374, aa:safe-get-bbox:1110, aa:zheng-align-text-to-rect-center:12423, aa:zheng-line-mid-x:12389, aa:zheng-add-texts-after-explode:12396, aa:zheng-align-text-center-x:12414 |
| `AAE` | 12983-13068 | 86 | 选择块内属性文字，在自定义窗口中编辑并按回车直接保存。 | aa:cmd-begin:714, aae:split-lines:12937, aae:locate-dcl:13070, aae:resolve-val:12966, aa:cmd-end:727 |
| `HAO` | 13087-13091 | 5 | 选中图框后批量填写页码和档案号。 | aa:cmd-begin:714, fillframes-run:12791, aa:cmd-end:727 |
| `HAO2` | 13333-13490 | 158 | 指定基准块参照与图号矩形范围，批量居中填充或更新递增图号文字。 | aa:cmd-begin:714, blk-insertpt:12612, hao2:block-name:13104, hao2:sort-blocks:13118, zdml2:collect-all-texts:13166, hao2:format-num:13097, hao2:find-existing-text-fast:13300, tktj:current-space:18357, tktj:ensure-text-style:18367, aa:cmd-end:727 |
| `MING` | 13635-13799 | 165 | 按行列网格顺序，批量将单行文字填充到对应属性块的图名属性中。 | aa:cmd-begin:714, ming:find-title-attrib:13499, blk-insertpt:12612, ming:get-block-height:13536, ming:get-text-info:13552, ming:cluster-and-sort:13584, aa:cmd-end:727 |
| `FIVE` | 13808-13849 | 42 | 将测得高度按比例缩放为 5。 | aa:cmd-begin:714, aa:cmd-end:727 |
| `JZ` | 13869-14011 | 143 | 将矩形水平中线对齐到1条或2条直线中心线，可同步居中文字。 | aa:safe-get-bbox:1110, aa:jz-line-center-y:13857, aa:bbox-center-x:1134, aa:bbox-top-y:1148, aa:bbox-bottom-y:1152, aa:safe-move-entity:1156 |
| `FKX` | 14181-14252 | 72 | 单击框内空白处选择正文对象，自动排除图框和右下角标题栏；支持手动指定范围。 | aa:cmd-begin:714, fdx:poly-rect:14041, fdx:add-rect:14255, fkx:choose-frame:14076, fdx:rect-from-points:14019, fkx:collect:14113, fkx:title-rect:14143, fkx:point-in-p:14067, fkx:filter:14170, aa:cmd-end:727 |
| `FDX` | 14435-14473 | 39 | 先选方框，按从上到下、每行从左到右分配；每批文字按空格移动并按 DX 规则排列。 | fdx:restore:14331, aa:undo-mark-off:753, fdx:frames:14293, fdx:sort-frames:14312, fdx:show-frame:14324, aa:undo-mark-on:745, fdx:place:14359 |
| `DX` | 14684-14753 | 70 | 批量整理 100×100 方格内的端子号、原理号和终点柜文字，并将整组文字居中。 | aa:undo-mark-off:753, aa:zz-filter-text-ss:14973, aa:zz-harvest-lines:15091, aa:zz-build-spatial-index:15116, aa:zz-text-info:15182, aa:zz-group-by-rect:15233, aa:undo-mark-on:745, dx:apply-group:14595 |
| `DX2` | 14897-14956 | 60 | 按方格从左到右、从上到下导出文字，每个方格一行，框内按行排序并用顿号连接，复制到剪贴板。 | aa:cmd-begin:714, aa:zz-filter-text-ss:14973, aa:zz-harvest-lines:15091, aa:zz-build-spatial-index:15116, aa:zz-text-info:15182, aa:zz-group-by-rect:15233, dx2:sort-groups:14794, dx2:export-group:14882, zi:to-clip:17021, aa:cmd-end:727 |
| `ZZ` | 15379-15381 | 3 | 先将文字改为中下对正，再居中到最近矩形；多行文字按 5 个单位的中心间距排列。 | aa:zz-run:15327 |
| `ZZ2` | 15502-15598 | 97 | 按 ZZ 居中，恰好双文字单元格所在行调为10，下方内容顺延。 | aa:zz2-poly-ok:15489, aa:safe-get-bbox:1110, aa:zz2-frame:15469, aa:zz-build-spatial-index:15116, aa:zz-text-info:15182, aa:zz-group-by-rect:15233, aa:zz2-plan:15384, aa:zz2-plan-ok:15393, aa:cmd-begin:714, aa:zz2-map-edge:15424, aa:bbox-top-y:1148, aa:bbox-bottom-y:1152 …共 16 个 |
| `JACC` | 15601-15603 | 3 | ZZ 的同功能入口。 | aa:zz-run:15327 |
| `MJ` | 15746-15833 | 88 | 框选单列表格后，按最长文字自动收窄宽度并将各行文字居中。 | aa:mj-frame-bounds:15606, aa:mj-collect-text-data:15625, aa:mj-horizontal-ys:15653, aa:mj-scale-line-x:15726, aa:mj-move-cached-texts:15736 |
| `FIVE2` | 15897-16004 | 108 | 同一列相接的直线表格统一行高5，保留顶边、列宽、字高和圆形符号大小。 | aa:try-get-bbox:1099, aa:tbhb-segment:16009, aa:tbhb-merge-segments:16027, aa:hg5-rows:15839, aa:tbhb-border-p:16019, aa:hg5-side-p:15866, aa:hg5-text-y:15888, aa:cmd-begin:714, aa:hg5-point:15884, aa:hg5-y:15851, aa:cmd-end:727 |
| `HBBG` | 16204-16292 | 89 | 将完整直线表格按图纸位置从上到下复制拼接，保留原表及各段标题和列顺序。 | aa:undo-mark-off:753, aa:tbhb-collect:16156, aa:tbhb-boxes:16048, aa:tbhb-groups:16121, aa:tbhb-group-problem:16096, aa:merge-sort:802, aa:tbhb-before-p:16068, aa:tbhb-item-inside-p:16080, aa:undo-mark-on:745, aa:tbhb-offset:16132, aa:tbhb-shift-point:16138, aa:tbhb-seen-line-p:16142 …共 14 个 |
| `HZBG` | 16360-16424 | 65 | 选中文字生成表格，行高 5，按最宽文字自动列宽，左右各留 3。 | aa:safe-get-bbox:1110, aa:hzbg-plan:16309, aa:cmd-begin:714, aa:hzbg-move:16339, aa:hzbg-line:16352, aa:cmd-end:727 |
| `ZDWI` | 16694-16811 | 118 | 按各列最宽文字自动放宽或缩窄表格列宽，文字左右各留 3 个图纸单位，并按 ZZ 居中。 | aa:zdwi-expand-selection:16507, aa:zdwi-table-groups:16567, aa:zdwi-vertices:16630, aa:zdwi-unique:16613, aa:zdwi-add-span:16618, aa:merge-sort:802, aa:safe-get-bbox:1110, aa:zdwi-column:16643, aa:zdwi-set-nth:16652, aa:cmd-begin:714, aa:zdwi-map-entity:16669, aa:zz-move-text:15201 …共 14 个 |
| `FF` | 16936-16977 | 42 | 预选文字，空格确认查找及替换内容，批量替换所有匹配片段。 | aa:cmd-begin:714, aa:ysdl-get-raw-text:1314, aa:str-replace-all:1291, aa:ff-text-data:16917, aa:cmd-end:727 |
| `DB` | 16980-16984 | 5 | 删除每个选中文字末尾的 N 个字符。 | aa:cmd-begin:714, db:del:16847, aa:cmd-end:727 |
| `DF` | 16986-16990 | 5 | 删除每个选中文字开头的 N 个字符。 | aa:cmd-begin:714, db:del:16847, aa:cmd-end:727 |
| `AB` | 16992-16996 | 5 | 在每个选中文字末尾增加文字（空输入使用剪贴板）。 | aa:cmd-begin:714, db:add:16880, aa:cmd-end:727 |
| `AF` | 16998-17002 | 5 | 在每个选中文字开头增加文字（空输入使用剪贴板）。 | aa:cmd-begin:714, db:add:16880, aa:cmd-end:727 |
| `QE` | 17070-17151 | 82 | 用 Windows 剪贴板中的文字批量替换选中文字；文字含“至”字时只替换“至”后的部分。 | qe:get-clip-text:17039, qe:zhi-prefix:17060 |
| `CC` | 17154-17228 | 75 | 读取 Windows 剪贴板，连续复制并替换副本文字，使用原生拖动预览和对象捕捉。 | aa:cmd-begin:714, aa:cmd-error:243, qe:get-clip-text:17039, aa:cmd-end:727 |
| `QW` | 17297-17333 | 37 | 提取选中文字，同一行用顿号连接，不同行之间也用顿号分隔，并复制到剪贴板。 | aa:cmd-begin:714, aa:ysdl-get-plain-text:1399, zi:pt:17016, qw:join:17232, zi:to-clip:17021, aa:cmd-end:727 |
| `QW2` | 17339-17400 | 62 | 提取选中文字及坐标，每项一行“x,y 文字”，坐标保留 2 位小数，复制到剪贴板。 | aa:cmd-begin:714, aa:ysdl-get-plain-text:1399, zi:pt:17016, aa:merge-sort:802, zi:to-clip:17021, aa:cmd-end:727 |
| `QW2P` | 17506-17549 | 44 | 把剪贴板里“x,y 文字”格式的内容按 T 命令的样式写到当前图层，与 QW2 相反。 | aa:cmd-begin:714, qw2p:read-clip-file:17465, qe:get-clip-text:17039, qw2p:parse-clip:17448, qw2p:text-data:17494, aa:cmd-end:727 |
| `QW3` | 17773-17811 | 39 | 导出选中对象的类型、图层、坐标、几何及文字属性为结构化文本并复制到剪贴板。 | aa:cmd-begin:714, aa:qw3-record:17746, aa:merge-sort:802, zi:to-clip:17021, aa:cmd-end:727 |
| `TJK` | 17900-17950 | 51 | 点选块，统计当前空间或框选范围内同名块（含动态块）的数量，选中它们并用红圈和序号标出；Q 清除标记。 | aa:cmd-begin:714, tjk:clear-marks:17816, aa:cmd-end:727, hao2:block-name:13104, tjk:select:17846, tjk:items:17858, tjk:ensure-layer:17826, tjk:draw:17875 |
| `DX1` | 17955-18025 | 71 | 提取选中文字及坐标，青色文字额外标注“端子名”，复制到剪贴板。 | aa:cmd-begin:714, zi:pt:17016, dx:color-kind:14500, aa:merge-sort:802, zi:to-clip:17021, aa:cmd-end:727 |
| `CE` | 18056-18086 | 31 | 测量点序列形成的多段线总长度。 | aa:cmd-begin:714, ce-redraw:18040, aa:cmd-end:727 |
| `AW` | 18273-18315 | 43 | 自动微移选中文字，尽量避开旁边线段、文字和其他对象重叠。 | aw:get-selection:18265, aw:process-one:18239 |
| `ZDML` | 18683-18761 | 79 | 选择多个图框块，生成目录文字。 | aa:cmd-begin:714, tktj:safe-vla-object:18385, tktj:collect-one-block:18509, tktj:sort-by-page:18626, tktj:sort-by-position:18637, tktj:take:18581, tktj:draw-table:18598, tktj:drop:18590, aa:cmd-end:727 |
| `ZDML2` | 18825-18996 | 172 | 指定基准块参照与图名、图号矩形范围，批量提取图名图号并生成目录。 | aa:cmd-begin:714, blk-insertpt:12612, hao2:block-name:13104, hao2:sort-blocks:13118, zdml2:collect-all-texts:13166, zdml2:build-spatial-index:13214, zdml2:extract-rect-text-fast:18767, zdml2:query-rect-index:13267, tktj:take:18581, tktj:draw-table:18598, tktj:drop:18590, aa:cmd-end:727 |
| `ZDMLDEBUG` | 18999-19033 | 35 | 选择一个图框块，打印所有增强属性。 | aa:cmd-begin:714, tktj:get-attributes:18458, aa:cmd-end:727 |
| `DUMP` | 19037-19061 | 25 | 打印选中图元的 ActiveX 属性与可用方法（调试辅助）。 | aa:cmd-begin:714, aa:cmd-end:727 |
| `C1` | 19279-19281 | 3 | 复制文字并把编号加 1（优先井号相邻数字，其次减号后数字），使用原生拖动预览和捕捉连续放置。 | c1c2:run:19211 |
| `C2` | 19283-19285 | 3 | 复制文字并把编号减 1（优先井号相邻数字，其次减号后数字），使用原生拖动预览和捕捉连续放置。 | c1c2:run:19211 |
| `C3` | 19287-19289 | 3 | 复制文字并把编号每次加 2（优先井号相邻数字，其次减号后数字），使用原生拖动预览和捕捉连续放置。 | c1c2:run:19211 |
| `DE` | 19636-19636 | 1 | 删除选中文字的最右侧括号及括号内容。 | de:run:19590 |
| `DE2` | 19637-19637 | 1 | 用最右侧括号内容替换括号前同样位数的数字（数字带相同尾缀时一并替换，A63(4)0I → A640I）。 | de:run:19590 |
| `GE` | 19724-19826 | 103 | 选中同一水平行的单行文字，按文字间隙绘制单行表格。 | ge:end-undo:19648, ge:get-item:19662, ge:sort-items:19699, ge:make-line:19706 |
| `UT` | 19937-20049 | 113 | 先将文字统一为左中对正，再按最上方一对的位置整理文字；支持直线及按首尾端点计算的未闭合多段线，保留宽度。 | aa:undo-mark-off:753, ut:horizontal-line-p:19854, ut:get-bbox:19876, ut:line-y:19869, ut:sort-desc:19913, aa:undo-mark-on:745, aa:normalize-text-horizontal-align:3787, ut:bbox-bottom:19893, ut:bbox-left:19889, ut:move:19921 |
| `0` | 20060-20094 | 35 | 将所选对象中的文字旋转角度统一改为 0 度。 | aa:cmd-begin:714, aa:cmd-end:727 |
| `9` | 20143-20152 | 10 | 以所选对象整体包围框中心为基点，整体顺时针旋转 90 度。 | aa:cmd-begin:714, aa:rotate-90-run:20101, aa:cmd-end:727 |
| `99` | 20155-20164 | 10 | 以所选对象整体包围框中心为基点，整体逆时针旋转 90 度。 | aa:cmd-begin:714, aa:rotate-90-run:20101, aa:cmd-end:727 |
| `QZ` | 20171-20219 | 49 | 取消当前图纸中的全部分组，组内图元保持不变。 |  |
| `DL1` | 20247-20264 | 18 | 创建电缆柜、电缆路径、电缆竖井相关的 1F / 2F 图层。 | aa:cmd-begin:714, dl1:make-layer:20231, aa:cmd-end:727 |
| `REP` | 20288-20382 | 95 | 将选中的柜名文字按内置映射表替换为标准柜名。 | aa:cmd-begin:714, rep-trim:20278, aa:cmd-end:727 |
| `KMZ` | 20675-20677 | 3 | 选中两条水平线后向左生成短线、矩形并居中标注+KM、-KM及直流馈线柜（青色虚线）。 | aa:km-ln-cmd:20467 |
| `KMY` | 20681-20683 | 3 | 选中两条水平线后向右生成短线、矩形并居中标注+KM、-KM及直流馈线柜（青色虚线）。 | aa:km-ln-cmd:20467 |
| `LNZ` | 20687-20689 | 3 | 选中两条水平线后向左生成短线、矩形并居中标注L、N及相邻屏柜（青色虚线）。 | aa:km-ln-cmd:20467 |
| `LNY` | 20693-20695 | 3 | 选中两条水平线后向右生成短线、矩形并居中标注L、N及相邻屏柜（青色虚线）。 | aa:km-ln-cmd:20467 |
| `UPSZ` | 20699-20701 | 3 | 选中两条水平线后向左生成短线、矩形并居中标注L、N及UPS电源柜（青色虚线）。 | aa:km-ln-cmd:20467 |
| `UPSY` | 20705-20707 | 3 | 选中两条水平线后向右生成短线、矩形并居中标注L、N及UPS电源柜（青色虚线）。 | aa:km-ln-cmd:20467 |
| `BZ` | 20711-20713 | 3 | 选中两条水平线后向左生成短线、矩形并居中标注B+、B-及同步时钟主机柜（青色虚线）。 | aa:km-ln-cmd:20467 |
| `BY` | 20717-20719 | 3 | 选中两条水平线后向右生成短线、矩形并居中标注B+、B-及同步时钟主机柜（青色虚线）。 | aa:km-ln-cmd:20467 |
| `ZJ` | 20751-20753 | 3 | 选中多条水平线后向左生成短线、矩形；原理号标注不变，柜内文字默认读取剪贴板，可手动输入（青色虚线）。 | aa:zj-cmd:20726 |
| `YJ` | 20757-20759 | 3 | 选中多条水平线后向右生成短线、矩形；原理号标注不变，柜内文字默认读取剪贴板，可手动输入（青色虚线）。 | aa:zj-cmd:20726 |
| `YDZ` | 20961-20963 | 3 | 选中多条水平线后向左生成短线、矩形并从上往下标注701、-901、-903...及公用测控柜（青色虚线）。 | aa:yd-cmd:20767 |
| `YDY` | 20967-20969 | 3 | 选中多条水平线后向右生成短线、矩形并从上往下标注701、-901、-903...及公用测控柜（青色虚线）。 | aa:yd-cmd:20767 |
| `LBZ` | 20973-20975 | 3 | 选中多条水平线后向左生成短线、矩形并从上往下标注500、-501、-503...及故障录波柜（青色虚线）。 | aa:yd-cmd:20767 |
| `LBY` | 20979-20981 | 3 | 选中多条水平线后向右生成短线、矩形并从上往下标注500、-501、-503...及故障录波柜（青色虚线）。 | aa:yd-cmd:20767 |
| `485Z` | 20985-20987 | 3 | 选中至少两条水平线后向左生成短线、矩形并居中标注485+、485-及网络通信柜（青色虚线）。 | aa:km-ln-cmd:20467 |
| `485Y` | 20991-20993 | 3 | 选中至少两条水平线后向右生成短线、矩形并居中标注485+、485-及网络通信柜（青色虚线）。 | aa:km-ln-cmd:20467 |
| `XX` | 21004-21032 | 29 | 将选中文字内容替换为 7×2.5。 | aa:cmd-begin:714, aa:cmd-end:727 |
| `JM` | 21411-21486 | 76 | 按绿色电缆线（水平或竖直）所连原理号，把 ZDDLH/ZDDLS 生成的“未填写”替换为电缆截面；无法判断的保留并选中提示。 | aa:cmd-begin:714, aa:rep-begin:21044, xyg:dedup-hlines:9446, xy:ss->list:8048, xy:filter-green-hlines:9138, xy:collect-vlines:8329, xy:build-vline-buckets:8257, xy:build-text-meta-list:8589, xy:collect-texts:8354, xy:hline-info-ed:8144, jm:find-spec-text:21373, aa:ysdl-get-plain-text:1399 …共 24 个 |
| `BH2` | 22496-22671 | 176 | 框选起点柜和绿色电缆线，把已编号但没记录的电缆记入共享记录，给有记录的“未编号”按记录填写；不分配新编号，两端不一致的标红注明原因。 | aa:cmd-begin:714, aa:rep-begin:21044, aa:link-clock:11146, bh:prepare:21890, bh:record-path:21602, bh:now:21606, bh:fold-joins:21842, bh:read-records:21633, bh:rec-key:21541, bh:kmap:21552, bh:nmap:21565, bh:split-map:22481 …共 34 个 |
| `BHG` | 22674-22789 | 116 | 以图为准修改电缆编号记录：记录编号改成图上的编号，原编号存为旧编号供另一端 BH1/BH2 自动跟改；“未编号”的删除其记录。 | aa:cmd-begin:714, aa:rep-begin:21044, aa:link-clock:11146, bh:prepare:21890, bh:record-path:21602, bh:now:21606, bh:fold-joins:21842, bh:read-records:21633, bh:rec-key:21541, bh:kmap:21552, bh:nmap:21565, bh:clean:21521 …共 26 个 |
| `BH1` | 23102-23313 | 212 | 逐根点选编号：先点起点柜名大字并输入前缀、起始号，再依次点绿色电缆线，回车后自动缩放一次识别并按点选顺序编号，同终点加 A/B/C，可撤销本批。 | aa:cmd-begin:714, bh:pick-start:22997, bh:ask-prefix:21970, bh:ask-start:21980, bh:record-path:21602, bh:fold-joins:21842, bh:read-records:21633, bh:rec-key:21541, bh:kmap:21552, bh:nmap:21565, bh:own-records:22954, bh:write-records:21653 …共 42 个 |
| `BH3` | 23392-23568 | 177 | 框选电缆清册文字（起点柜/编号/终点柜/规格/芯数/原理号），以清册为准写入共享记录：没有的记入，有的强制改成清册编号（同 BHG）。 | aa:cmd-begin:714, aa:rep-begin:21044, hddl:text:23988, hddl:point:24006, aa:merge-sort:802, hddl:sort-rows:24070, hddl:rows:24060, hddl:coord:24000, bh:record-path:21602, bh:now:21606, bh:fold-joins:21842, bh:read-records:21633 …共 32 个 |
| `ZDAO` | 23688-23692 | 5 | 将选中文字按垂直位置上下颠倒排列（最下面的文字放到最上面，原 DAO）。 | aa:cmd-begin:714, dao:run:23626, aa:cmd-end:727 |
| `HDAO` | 23695-23699 | 5 | 将选中文字按水平位置左右颠倒排列（最左边的文字放到最右边）。 | aa:cmd-begin:714, dao:run:23626, aa:cmd-end:727 |
| `QH` | 23704-23855 | 152 | 只选中已选文字所在行、且位于当前屏幕内、参考文字左右各 1000 内的所有文字（跨多行时逐行选择）。 | aa:merge-sort:802 |
| `BK` | 23885-23928 | 44 | 选中文字后只保留最后一对括号内的内容，括号外有“至”时保留“至”。 | de:end-undo:19573, de:get-text:19557, bk:extract-inner:23866, de:set-text:19566 |
| `HDDL` | 24216-24306 | 91 | 直接校核选中文字中的电缆编号、规格和原理号，问题行标红并在行首标注。 | aa:undo-mark-off:753, aa:undo-mark-on:745, hddl:ensure-layer:23937, hddl:clear-markers:23977, hddl:text:23988, hddl:point:24006, hddl:sort-rows:24070, hddl:rows:24060, hddl:group-rows:24075, hddl:mirror-p:24210, hddl:cell:24120, hddl:tail-count:24126 …共 20 个 |
| `CU` | 24380-24381 | 2 | 将选中对象按 5 个单位的递增间距向上复制指定份数。 | cu:copy-direction:24312 |
| `CD` | 24384-24385 | 2 | 将选中对象按 5 个单位的递增间距向下复制指定份数。 | cu:copy-direction:24312 |
| `CZ` | 24388-24389 | 2 | 将选中对象按 5 个单位的递增间距向左复制指定份数。 | cu:copy-direction:24312 |
| `CY` | 24392-24393 | 2 | 将选中对象按 5 个单位的递增间距向右复制指定份数。 | cu:copy-direction:24312 |
| `HS` | 24446-24618 | 173 | 选中物体单向横向缩放，左右宽度改变，高度保持不变。 | aa:cmd-begin:714, aa:hs-filter-unlocked:24400, aa:cmd-end:727, aa:hs-get-ss-bbox:24420 |
| `ZS` | 24627-24799 | 173 | 选中物体单向纵向缩放，上下高度改变，宽度保持不变。 | aa:cmd-begin:714, aa:hs-filter-unlocked:24400, aa:cmd-end:727, aa:hs-get-ss-bbox:24420 |
| `SC3` | 24831-24898 | 68 | 将选中对象整体等比例缩小，使四周距 A3 外框至少 5mm。 | aa:cmd-begin:714, aa:sc3-layer-locked-p:24805, aa:sc3-entity-bbox:24813, aa:cmd-end:727 |
| `Z0` | 24965-25008 | 44 | 将选中对象的 Z 坐标全部归零（压平到 XY 平面）。 | aa:cmd-begin:714, aa:z0-layer-locked-p:24904, aa:z0-data-flat-p:24922, aa:z0-polyline-flat-p:24955, aa:z0-one:24935, aa:z0-polyline-verts:24947, aa:cmd-end:727 |
| `VPO1` | 25014-25019 | 6 | 切换到“单个”标准视口。 | aa:cmd-begin:714, aa:cmd-end:727 |
| `VPO2` | 25022-25027 | 6 | 切换到“两个：垂直”标准视口。 | aa:cmd-begin:714, aa:cmd-end:727 |
| `TONG` | 25033-25117 | 85 | 框选文字对象去重，按自然顺序从上到下排列在指定插入点（HZ样式/字高3/宽比0.7/白色/间距5）。 | aa:cmd-begin:714, aa:cmd-end:727, aa:merge-sort:802, aa:gtx-natural-less:6527 |
| `ZDDL2` | 25778-25869 | 92 | 自动根据现有端子排与接线方格绘制电缆引线、干线与标注。 | aa:cmd-begin:714, aa:cmd-end:727, zddl:parse-strip:25309, zddl:parse-wiring-ss:25530, zddl:ensure-layer:25590, zddl:plan-cables:25667, zddl:lookup-terminal:25218, zddl:label-layout:25692, zddl:draw-one-cable:25699, zddl:format-cable-no:25657 |
| `ZDC` | 25871-25873 | 3 | ZDDLH 命令的简写别名。 | c:zddlh:28231 |
| `ZDDLD` | 26963-26991 | 29 | 删除 ZDDL 生成的端子排框线与端子名/号，保留原理号、电缆接线和电缆文字。 | aa:cmd-begin:714, zddl2:xdata-app:26946, aa:layer-locked-p:4973, zddl2:set-layer-lock:26949, aa:cmd-end:727 |
| `XZYL` | 28197-28203 | 7 | 修正原理号：先点原理号正确的电缆录入，再运行点对面一端的同一根电缆，替换不一致的原理号并补填未编号；合画图录入按 1#/2# 拆开；可先选电缆线再运行。 | aa:cmd-begin:714, zyl:work:28165, aa:cmd-end:727 |
| `BDL` | 28209-28215 | 7 | 选择后补的原理号，按 ZDDL 样式补画引线、短斜线、电缆线、箭头和占位文字，自动找空行；选水平原理号时按竖排端子排补画竖直电缆线。 | aa:cmd-begin:714, bdl:work:27609, aa:cmd-end:727 |
| `BDL2` | 28218-28225 | 8 | 连续补画多根电缆：逐根选原理号按空格记住，不选直接空格后一次生成（同 BDL），生成前可先调整窗口，一次 U 全部撤销。 | aa:cmd-begin:714, bdl:work-multi:27625, bdl:hilite:27617, aa:cmd-end:727 |
| `ZDDLH` | 28231-28238 | 8 | 两次选择文字并指定左下基点，生成横排端子排与水平绿色电缆线（原 ZDDL）。 | aa:cmd-begin:714, zddl2:work:26860, aa:cmd-end:727 |
| `ZDDLS` | 28244-28251 | 8 | 两次选择文字并指定左上基点，生成竖排端子排、水平引线与竖直绿色电缆线（向下箭头、文字 270°）。 | aa:cmd-begin:714, zddl2:work:26860, aa:cmd-end:727 |

## 辅助函数分组（按前缀）

| 前缀 | 函数数 | 行号分布 | 使用这些函数的命令 |
|------|------|------|------|
| `aa:` | 323 | 243-340, 394-517, 714-826, 1077-1611, 3157-3218, 3412-3882 … | 0, 485Y, 485Z, 9, 99, A2T, AAE, AB, ABCN, AF, ASHANG, ATW, AXIA, AYOU, AZUO …共 173 个 |
| `des:` | 5 | 549-577 | DES |
| `ystemp:` | 2 | 648-655 | YSTEMP |
| `ztf:` | 13 | 828-1060 | ZTF |
| `txt:` | 7 | 1866-2068 | T, T2 |
| `zhu:` | 5 | 2085-2126 | ZHU |
| `hwt:` | 14 | 2180-2393 | HWT |
| `txt2:` | 5 | 2454-2601 | DH, T2 |
| `dh:` | 10 | 2616-2816 | DH |
| `qr:` | 3 | 4806-4828 | QR, QR2 |
| `det:` | 1 | 5050-5068 | DET |
| `a2t:` | 3 | 5123-5148 | A2T |
| `gty2:` | 4 | 7183-7320 | GTY2 |
| `(无前缀):` | 22 | 7631-7683, 7726-7753, 12588-12859, 18040-18053, 20278-20286 | BIAN, CE, HAO, HAO2, LAN, MING, REP, ZDML2 |
| `xy:` | 47 | 8035-9159 | BH1, BH2, BHG, JM, XY, XYG, XYG2, XYG3, XZYL |
| `xyg:` | 32 | 9185-10199 | BH1, BH2, BHG, DE, DE2, JM, SX1, SX2, XYG, XYG2, XYG3 |
| `hb:` | 9 | 11340-11637 | HBDL |
| `aae:` | 4 | 12862-12981, 13070-13085 | AAE, HAO2, MING, ZDC, ZDDLH, ZDDLS, ZDML, ZDML2, ZDMLDEBUG |
| `hao2:` | 4 | 13097-13164, 13300-13331 | HAO2, TJK, ZDML2 |
| `zdml2:` | 4 | 13166-13297, 18767-18823 | HAO2, ZDML2 |
| `ming:` | 4 | 13499-13633 | MING |
| `fdx:` | 11 | 14019-14061, 14255-14433 | FDX, FKX |
| `fkx:` | 10 | 14067-14177 | FKX |
| `dx:` | 12 | 14476-14682 | DX, DX1, DX2, FDX, ZDC, ZDDL2, ZDDLH, ZDDLS |
| `dx2:` | 12 | 14760-14895 | DX2, ZDC, ZDDL2, ZDDLH, ZDDLS |
| `db:` | 5 | 16827-16914 | AB, AF, DB, DF |
| `zi:` | 2 | 17016-17036 | DX1, DX2, QW, QW2, QW3 |
| `qe:` | 2 | 17039-17067 | AB, AF, CC, QE, QW2P, YJ, ZJ |
| `qw:` | 1 | 17232-17293 | QW |
| `qw2p:` | 6 | 17403-17503 | QW2P |
| `tjk:` | 6 | 17816-17897 | TJK |
| `aw:` | 17 | 18101-18271 | AW, XZYL |
| `tktj:` | 24 | 18345-18680 | HAO2, MING, ZDML, ZDML2, ZDMLDEBUG |
| `c1c2:` | 13 | 19079-19277 | C1, C2, C3 |
| `de:` | 21 | 19310-19634 | BK, DE, DE2, SX1, SX2, XYG, XYG2, XYG3 |
| `ge:` | 6 | 19648-19722 | GE |
| `ut:` | 10 | 19833-19935 | UT |
| `dl1:` | 1 | 20231-20245 | DL1 |
| `jm:` | 20 | 21163-21408 | BDL, BDL2, BH1, BH2, BH3, BHG, JM, XZYL |
| `bh:` | 101 | 21513-22493, 22794-23099, 23314-23389 | BDL, BDL2, BH1, BH2, BH3, BHG, DE, DE2, JM, SX1, SX2, XYG, XYG2, XYG3, XZYL |
| `dao:` | 4 | 23578-23685 | HDAO, ZDAO |
| `bk:` | 1 | 23866-23883 | BK |
| `hddl:` | 29 | 23937-24214 | BH1, BH2, BH3, BHG, HDDL, XZYL |
| `cu:` | 1 | 24312-24377 | CD, CU, CY, CZ |
| `zddl:` | 27 | 25126-25776 | BDL, BDL2, ZDC, ZDDL2, ZDDLH, ZDDLS |
| `zddl2:` | 96 | 25881-26957 | BDL, BDL2, ZDC, ZDDLD, ZDDLH, ZDDLS |
| `bdl:` | 39 | 26998-27803 | BDL, BDL2, XZYL |
| `zyl:` | 31 | 27812-28191 | XZYL |
