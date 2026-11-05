# AA整合版本.lsp 代码地图

> 由 `python tools/code_map.py write` 自动生成（`python gen_命令索引.py` 也会顺带生成），请勿手工维护。
> 行号随源码变动；改完 LISP 后重新生成，`python tools/check_all_static.py` 会校验本文件是否过期。

## 使用方法（给 AI / 人）

1. **不要通读整合文件。** 先在下表找命令的行号范围，再按行号只读那一段。
2. `python tools/code_map.py show 命令或函数` 直接输出行号范围和下游调用（加 `--source` 打印源码）。
3. 改共享函数前先跑 `python tools/code_map.py callers 函数名`，确认影响哪些命令。
4. 改动过程中用 `python tools/check_all_static.py --quick` 只跑相关检查；交付前跑一次不带参数的全量检查。

- 源文件：`AA整合版本.lsp`，29253 行，1280 个函数，其中 186 个 `c:` 命令。

## 命令

| 命令 | 行号 | 行数 | 说明 | 直接调用的项目函数（行号） |
|------|------|------|------|------|
| `YS` | 345-394 | 50 | 选取两点生成绿色直线及终点直径100的同层全绿晶体机械徽章，无中央字母标志。 | aa:cmd-begin:717, aa:ys-line:268, aa:ys-ring:337, aa:ys-rim:326, aa:ys-snowflake:294, aa:ys-detail:319, aa:cmd-end:730 |
| `YS1` | 523-549 | 27 | 选取两点生成绿色直线，以第二点为中心生成高80的TGOOD机械装甲线条Logo，可整体撤销。 | aa:cmd-begin:717, aa:ys-line:268, aa:ys1-t:423, aa:ys1-g:440, aa:ys1-o:460, aa:ys1-d:497, aa:cmd-end:730 |
| `DES` | 583-648 | 66 | 所选直线共线重叠时删除短线、保留长线；完全重复留一条，跨图层处理并跳过锁定图层。 | aa:cmd-begin:717, des:key-less-p:552, aa:merge-sort:805, des:record-less-p:557, des:x-less-p:561, des:overlap-p:567, aa:cmd-end:730 |
| `YSTEMP` | 661-715 | 55 | 删除所选对象中竖直共线、首尾相接且长度分别为 21 和 7 的直线对。 | aa:cmd-begin:717, aa:merge-sort:805, ystemp:y-less-p:651, ystemp:pair-p:655, aa:cmd-end:730 |
| `ZTF` | 1065-1078 | 14 | 搜索系统字体并将选定字体写入指定文字样式。 | aa:cmd-begin:717, ztf:collect-font-records:935, ztf:run-dialog:1035, aa:cmd-end:730 |
| `YSDL` | 1883-1883 | 1 | 提取选中文字到CSV文件，并改变文字颜色。 | aa:ysdl-run:1658 |
| `YSDL2` | 1887-1887 | 1 | 按 YSDL 格式导出电缆文字到CSV，同一电缆编号只导出最先出现的一行。 | aa:ysdl-run:1658 |
| `Q` | 1899-1925 | 27 | 快速从当前选择中仅选中所有文字对象。 | aa:cmd-begin:717, aa:cmd-end:730 |
| `T` | 2140-2144 | 5 | 把文字及ATTDEF属性定义刷为HZ样式，高度3，宽度0.7；按可见范围保持对齐文字位置。 | aa:cmd-begin:717, txt:run:2123, aa:cmd-end:730 |
| `ZHU` | 2196-2240 | 45 | 选中端子排名和端子号文字，选短接或拆除连片，生成HZ/3/0.7的“注：”单行文字。 | aa:cmd-begin:717, aa:ysdl-get-plain-text:1402, zhu:classify:2165, zhu:trim:2153, zhu:pick-name:2184, zhu:build-note:2175, aa:cmd-end:730 |
| `HWT` | 2463-2514 | 52 | 框选一列柜名文字，按从上到下顺序每行最多5个蛇形排列，生成L1/N1端子、SML电缆编号和两端JL进线的环网图，并输出可供BH3登记的电缆清单。 | aa:cmd-begin:717, aa:ysdl-get-plain-text:1402, aa:merge-sort:805, hwt:counts-text:2386, hwt:row-counts:2248, hwt:draw:2411, hwt:layout:2292, hwt:cable-no:2258, hwt:draw-list:2440, hwt:cable-rows:2373, aa:cmd-end:730 |
| `T2` | 2671-2675 | 5 | 把文字及ATTDEF属性定义刷为宋体样式，高度3，宽度0.8；按可见范围保持对齐文字位置。 | aa:cmd-begin:717, txt2:run:2658, aa:cmd-end:730 |
| `DH` | 2886-2890 | 5 | 把选中的多行文字转成规整的单行文字，保持原位置和对齐，文字不再碎成多段。 | aa:cmd-begin:717, dh:run:2867, aa:cmd-end:730 |
| `ABCN` | 2907-2958 | 52 | 指定一点生成青色 A、B、C、N 单行文字，HZ/3/0.7、左中对正、按 H 默认间距5向下排列。 | aa:cmd-begin:717, aa:safe-get-bbox:1113, aa:safe-move-entity:1159, aa:cmd-end:730 |
| `H` | 2960-3087 | 128 | 先将选中文字统一为左中对正，再按指定间距（插入点/对齐点之间）从上到下排列。 | aa:cmd-begin:717, aa:normalize-text-horizontal-align:3955, aa:merge-sort:805, aa:cmd-end:730 |
| `H2` | 3094-3218 | 125 | 先将选中文字统一为左中对正，右侧文字在最上、越靠左越靠下，按指定间距从上到下排列。 | aa:cmd-begin:717, aa:normalize-text-horizontal-align:3955, aa:merge-sort:805, aa:cmd-end:730 |
| `Y` | 3244-3248 | 5 | 将选中对象的颜色快速变为青色。 | aa:cmd-begin:717, aa:color-cmd:3225, aa:cmd-end:730 |
| `DZ` | 3288-3322 | 35 | 将所选其他文字改为Y命令的青色，保留纯数字及数字后接单个小写a的文字原色。 | aa:cmd-begin:717, aa:ysdl-get-plain-text:1402, aa:dz-number-p:3254, aa:dz-color-text:3270, aa:cmd-end:730 |
| `YY` | 3328-3332 | 5 | 将选中对象快速改为黄色。 | aa:cmd-begin:717, aa:color-cmd:3225, aa:cmd-end:730 |
| `RR` | 3338-3342 | 5 | 将选中对象快速改为红色。 | aa:cmd-begin:717, aa:color-cmd:3225, aa:cmd-end:730 |
| `WW` | 3348-3352 | 5 | 将选中对象快速改为白色。 | aa:cmd-begin:717, aa:color-cmd:3225, aa:cmd-end:730 |
| `WWW` | 3358-3364 | 7 | 将选中对象强制改为白色；尺寸标注全要素变白，引线先分解再变白，块参照连块内实体一起改。 | aa:cmd-begin:717, aa:deep-color-cmd:3761, aa:cmd-end:730 |
| `XU` | 3370-3444 | 75 | 将所有选中且支持线型修改的对象改为 HIDDEN2。 |  |
| `GG` | 3450-3454 | 5 | 将选中对象快速改为绿色。 | aa:cmd-begin:717, aa:color-cmd:3225, aa:cmd-end:730 |
| `PP` | 3460-3464 | 5 | 将选中对象快速改为洋红色。 | aa:cmd-begin:717, aa:color-cmd:3225, aa:cmd-end:730 |
| `HH` | 3470-3474 | 5 | 将选中对象快速改为颜色 8（与 HUI 同色）。 | aa:cmd-begin:717, aa:color-cmd:3225, aa:cmd-end:730 |
| `HUI` | 3840-3845 | 6 | 将选中对象强制改为颜色 8；尺寸标注全要素改色，引线先分解再改色，块参照连块内实体一起改。 | aa:cmd-begin:717, aa:deep-color-cmd:3761, aa:cmd-end:730 |
| `ZHONG` | 3899-3903 | 5 | 文字居中对齐；选择直线/矩形时按中心 X 居中。 | aa:align-text-cmd:3848, aa:find-ref-by-top-bbox:1225, aa:bbox-center-x:1137, aa:normalize-visual-h:4042, aa:align-text-horizontal-by-bbox:1265 |
| `ZUO` | 4053-4057 | 5 | 将选中文字按视觉左侧统一对正（旋转文字按方向换算），并以最左侧文字为基准左对齐。 | aa:align-text-cmd:3848, aa:find-ref-by-left-bbox:1185, aa:bbox-left-x:1143, aa:normalize-visual-h:4042, aa:align-text-horizontal-by-bbox:1265 |
| `AZUO` | 4063-4182 | 120 | 选择一条竖直直线作为基准线，框选其他所有对象作为一个整体整体移动并左对齐到该直线。 | aa:cmd-begin:717, aa:cmd-end:730, aa:safe-get-bbox:1113, aa:bbox-left-x:1143, aa:safe-move-entity:1159 |
| `HP` | 4188-4325 | 138 | 将选中文字按从左到右排列，使相邻文字首尾间距为指定值，并按最左文字上边对齐。 | aa:cmd-begin:717, aa:cmd-end:730, aa:safe-get-bbox:1113, aa:bbox-left-x:1143, aa:bbox-top-y:1151, aa:merge-sort:805, aa:bbox-right-x:1147, aa:safe-move-entity:1159 |
| `HP2` | 4331-4474 | 144 | 将选中文字改为正中对齐，按中心点指定间距从左到右横向排列。 | aa:cmd-begin:717, aa:cmd-end:730, aa:normalize-text-horizontal-align:3955, aa:safe-get-bbox:1113, aa:bbox-center-x:1137, aa:bbox-top-y:1151, aa:bbox-bottom-y:1155, aa:merge-sort:805, aa:safe-move-entity:1159 |
| `YOU` | 4477-4481 | 5 | 将选中文字按视觉右侧统一对正（旋转文字按方向换算），并以最右侧文字为基准右对齐。 | aa:align-text-cmd:3848, aa:find-ref-by-right-bbox:1205, aa:bbox-right-x:1147, aa:normalize-visual-h:4042, aa:align-text-horizontal-by-bbox:1265 |
| `AYOU` | 4486-4605 | 120 | 选择一条竖直直线作为基准线，框选其他所有对象作为一个整体整体移动并右对齐到该直线。 | aa:cmd-begin:717, aa:cmd-end:730, aa:safe-get-bbox:1113, aa:bbox-right-x:1147, aa:safe-move-entity:1159 |
| `SHANG` | 4608-4612 | 5 | 将选中文字按视觉上方统一对正（竖排文字定位点在顶端），并以最上方文字为基准上对齐。 | aa:align-text-cmd:3848, aa:find-ref-by-top-bbox:1225, aa:bbox-top-y:1151, aa:normalize-visual-v:4047, aa:align-text-vertical-by-bbox:1279 |
| `ASHANG` | 4618-4737 | 120 | 选择一条水平直线作为基准线，框选其他所有对象作为一个整体整体移动并向上对齐到该直线。 | aa:cmd-begin:717, aa:cmd-end:730, aa:safe-get-bbox:1113, aa:bbox-top-y:1151, aa:safe-move-entity:1159 |
| `XIA` | 4740-4744 | 5 | 将选中文字按视觉下方统一对正（竖排文字定位点在底端），并以最下方文字为基准下对齐。 | aa:align-text-cmd:3848, aa:find-ref-by-bottom-bbox:1245, aa:bbox-bottom-y:1155, aa:normalize-visual-v:4047, aa:align-text-vertical-by-bbox:1279 |
| `AXIA` | 4749-4868 | 120 | 选择一条水平直线作为基准线，框选其他所有对象作为一个整体整体移动并向下对齐到该直线。 | aa:cmd-begin:717, aa:cmd-end:730, aa:safe-get-bbox:1113, aa:bbox-bottom-y:1155, aa:safe-move-entity:1159 |
| `HE` | 4870-4963 | 94 | 将同一行的两个或以上文字合并。 | aa:cmd-begin:717, aa:insert-sort:777, aa:cmd-end:730 |
| `QR` | 4998-5043 | 46 | 快速修改文字高度，记忆上次高度，回车沿用。 | aa:cmd-begin:717, qr:last-height:4974, qr:height-str:4993, qr:save-height:4986, aa:cmd-end:730 |
| `QR2` | 5049-5079 | 31 | 连续选择文字修改高度，与 QR 共用上次高度；高度回车沿用，选择回车或 Esc 退出。 | aa:cmd-begin:717, qr:last-height:4974, qr:height-str:4993, qr:save-height:4986, aa:cmd-end:730 |
| `DEA` | 5085-5108 | 24 | 删除所选对象中高度小于 0.1 的 TEXT/MTEXT 文字。 | aa:cmd-begin:717, aa:cmd-end:730 |
| `DEK` | 5115-5135 | 21 | 删除选中内容中的所有块参照 (INSERT)。 | aa:cmd-begin:717, aa:cmd-end:730 |
| `DEH` | 5178-5208 | 31 | 删除所选对象中内容含有中文的 TEXT/MTEXT 文字。 | aa:cmd-begin:717, aa:has-chinese:5156, aa:ysdl-get-plain-text:1402, aa:layer-locked-p:5141, aa:cmd-end:730 |
| `DET` | 5238-5279 | 42 | 删除所选对象中内容为指定值(逗号或空格分隔、不区分大小写、回车沿用上次)的属性定义ATTDEF。 | aa:cmd-begin:717, det:split-values:5218, aa:ysdl-get-raw-text:1317, aa:layer-locked-p:5141, aa:cmd-end:730 |
| `A2T` | 5318-5355 | 38 | 将属性定义ATTDEF（炸块残留、X/BURST无法分解）转为普通单行文字，可选标记/默认值/提示。 | aa:cmd-begin:717, a2t:pick-string:5296, a2t:layer-locked-p:5291, a2t:text-dxf:5308, aa:cmd-end:730 |
| `WI` | 5361-5401 | 41 | 修改选中文字的宽度比例。 | aa:cmd-begin:717, aa:cmd-end:730 |
| `ATW` | 5408-5492 | 85 | 拾取两点指定最大宽度，将超宽单行文字的宽度比例缩小至两点间距的 95% 并保持左侧不动。 | aa:cmd-begin:717, aa:safe-get-bbox:1113, aa:bbox-right-x:1147, aa:bbox-left-x:1143, aa:safe-move-entity:1159, aa:cmd-end:730 |
| `XB` | 5498-5551 | 54 | 将选中的文字或尺寸标注整体缩小为原来的十分之一，并保留选择状态。 | aa:cmd-begin:717, aa:cmd-end:730 |
| `YAN` | 5557-5673 | 117 | 延长竖直直线统一间距，支持分组和上下方向控制。 | aa:insert-sort:777 |
| `LL` | 5684-5713 | 30 | 水平/竖直连续画直线并实时预览，结束恢复正交、捕捉与跟踪设置。 | aa:ortho-restore-vars:5958, aa:undo-mark-off:756, aa:undo-mark-on:748 |
| `LONG` | 5780-5832 | 53 | 连续点选路径各点，过程中红色粗线和大字实时显示路径与长度，空格结束后弹窗并在命令行显示总长度，不保留对象。 | long:del:5766, long:drop-layer:5771, aa:undo-mark-off:756, aa:undo-mark-on:748, long:layer:5719, long:fmt:5732, long:total:5741, long:make-path:5749, long:make-label:5757 |
| `MM` | 5981-6013 | 33 | 水平/竖直移动并实时预览，第二点可捕捉或输入距离，偏斜自动投影。 | aa:ortho-restore-vars:5958, aa:undo-mark-off:756, aa:undo-mark-on:748, aa:ortho-report:5947, aa:ortho-drag:5907 |
| `SS` | 6019-6051 | 33 | 水平/竖直拉伸并实时预览实体变形，第二点可捕捉或输入距离，偏斜自动投影。 | aa:ortho-restore-vars:5958, aa:undo-mark-off:756, aa:undo-mark-on:748, aa:ortho-report:5947, aa:ortho-drag:5907 |
| `SW` | 6140-6195 | 56 | 拉伸对象并记忆方向与距离，支持动态拉伸实时预览，后续可直接回车重复。 | aa:cmd-begin:717, aa:cmd-error:246, aa:ss-format-vec:6059, aa:ss-do-interactive-stretch:6105, aa:cmd-end:730 |
| `SYI` | 6305-6305 | 1 | 预选对象中非竖直对象向上移动 5X，竖直直线向上拉伸 5X；自动补选短斜线左侧与水平线相交的竖直线。 | aa:move-stretch-vertical-cmd:6238 |
| `XYI` | 6306-6306 | 1 | 预选对象中非竖直对象向下移动 5X，竖直直线向下拉伸 5X；自动补选短斜线左侧与水平线相交的竖直线。 | aa:move-stretch-vertical-cmd:6238 |
| `ZYI` | 6437-6437 | 1 | 预选对象中非水平对象向左移动 5X，水平直线向左拉伸 5X；自动补选短斜线处与竖直线相交的水平线。 | aa:move-stretch-horizontal-cmd:6349 |
| `YYI` | 6443-6443 | 1 | 预选对象中非水平对象向右移动 5X，水平直线向右拉伸 5X；自动补选短斜线处与竖直线相交的水平线。 | aa:move-stretch-horizontal-cmd:6349 |
| `SSS` | 6535-6606 | 72 | 交叉框选调整下沿所在行高度，支持小数，默认 10。 | aa:sss-pickfirst-box:6497, aa:sss-lowest-row-line:6523, aa:sss-find-pair:6470, aa:sss-horizontal-segments:6449, aa:cmd-begin:717, aa:cmd-end:730 |
| `SYAN` | 6649-6649 | 1 | 将选中直线向上延长 5 个单位。 | aa:extend-line-cmd:6609 |
| `XYAN` | 6652-6652 | 1 | 将选中直线向下延长 5 个单位。 | aa:extend-line-cmd:6609 |
| `SJ` | 6666-6692 | 27 | 在选中直线顶端生成上接短线。 | aa:cmd-begin:717, aa:cmd-end:730 |
| `XJ` | 6694-6720 | 27 | 在选中直线底端生成下接短线。 | aa:cmd-begin:717, aa:cmd-end:730 |
| `SYJ` | 6763-6763 | 1 | 将选中竖直直线向上延长 5 个单位，再生成上接短线。 | aa:extend-join-cmd:6721 |
| `XYJ` | 6764-6764 | 1 | 将选中竖直直线向下延长 5 个单位，再生成下接短线。 | aa:extend-join-cmd:6721 |
| `GTX` | 6894-7074 | 181 | 按自动容差整理单行/多行电缆文字并自然排序汇总。 | aa:undo-mark-off:756, aa:undo-mark-on:748, aa:gtx-select-prefix-text:6878, aa:ysdl-get-plain-text:1402, aa:try-get-bbox:1102, aa:merge-sort:805, aa:gtx-rows:6837, aa:gtx-key:6806, aa:gtx-find-last-char:6794, aa:gtx-natural-less:6814, aa:gtx-create-text-entity:6854 |
| `GTY` | 7317-7464 | 148 | 保留原文字，按电缆编号排序整理并复制到指定位置。 | aa:gty-delete-copies:7308, aa:gty-get-text-width:7145, aa:gty-separated-rows:7180, aa:gty-add-row:7214, aa:merge-sort:805, aa:gty-get-item-x:7113, aa:gty-order-rows:7264, aa:gty-column-widths:7276, aa:gty-row-tree:7226, aa:gty-build-sort-key:7121, aa:gty-tree-item:7237, aa:gty-copy-text:7288 …共 14 个 |
| `GTY2` | 7609-7653 | 45 | 把选中电缆文字按 GTY 规则排序整理后放进 CAD 剪贴板，到另一张图 Ctrl+V 粘贴；原文字不变。 | aa:cmd-begin:717, aa:gty-delete-copies:7308, aa:cmd-error:246, gty2:locked-layer:7556, gty2:layout:7470, aa:gty-get-item-pt:7112, aa:gty-get-item-ename:7110, gty2:make-copies:7567, gty2:to-clip:7595, aa:cmd-end:730 |
| `GTZ` | 7659-7816 | 158 | 将选中的交替柜名与电缆编号单列文字，按前后柜与编号重组为3列表格输出。 | aa:gty-get-text-width:7145, aa:merge-sort:805, aa:gty-move-entity:7167 |
| `HWD` | 7843-7916 | 74 | 横排交替柜名与电缆编号重组为起点、编号、终点三列，左中对齐、行距5，保留原横排。 | aa:cmd-begin:717, aa:safe-get-bbox:1113, aa:gty-get-text-width:7145, aa:merge-sort:805, aa:hwd-rows:7822, aa:hwd-make-text:7829, aa:cmd-end:730 |
| `BIAN` | 7972-8002 | 31 | 根据选中直线生成方向三角、至字样和电缆规格标注。 | aa:cmd-begin:717, bian-draw-one:7944, aa:cmd-end:730 |
| `LAN` | 8042-8190 | 149 | 竖直线/斜线/水平线联动复制+移动插件。 | aa:cmd-begin:717, lan-vert-mode:8013, lan-get-option:8027, aa:cmd-end:730 |
| `XIN` | 8197-8287 | 91 | 统计选中直线矩形范围内的对象数量并标注结果。 | aa:cmd-begin:717, aa:cmd-end:730 |
| `XY` | 9451-9465 | 15 | 处理所选电缆线（水平线，或绿色竖直线），先运行 XIN 统计芯数，再运行 YUAN 提取原理号；水平线横向输出，竖直线在底端下方输出 270° 文字。 | aa:cmd-begin:717, xy:run-xin:8669, xy:run-yuan:9257, aa:cmd-end:730 |
| `XYG` | 10489-10489 | 1 | 一次框选，自动提取绿色水平/竖直电缆线执行 XY 统计，并提取大字与电缆文字执行 GTX 分类汇总。 | xyg:run:10291 |
| `XYG2` | 10492-10492 | 1 | 与 XYG 相同的框选和汇总表，但原图不留痕：电缆后面不留芯数和原理号，异常电缆线也不改色、不延长。 | xyg:run:10291 |
| `XYG3` | 10495-10495 | 1 | 与 XYG2 一样不留痕，并把 1(2)# 合画电缆拆成各柜两行，汇总表先排完 1# 再排 2#。 | xyg:run:10291 |
| `SX0` | 10945-10984 | 40 | 清除联动标记：框选文字，删除副本的联动标记使其成为普通文字；原件自动跳过。 | aa:cmd-begin:717, aa:link-dwg-id:10555, aa:link-info:10511, aa:link-root-p:10551, aa:cmd-end:730 |
| `YSSX0` | 10991-11031 | 41 | 强制清除联动标记：框选文字，原件和副本的联动标记一并删除，全部成为普通文字。 | aa:cmd-begin:717, aa:link-dwg-id:10555, aa:link-info:10511, aa:link-root-p:10551, aa:cmd-end:730 |
| `SX` | 11056-11094 | 39 | 联动标记：框选原件端子排文字发放唯一编号（UID），草稿/XY/XYG/GTY 副本自动继承。 | aa:cmd-begin:717, aa:link-dwg-id:10555, aa:link-info:10511, aa:link-root-p:10551, aa:link-export-roots:11038, aa:cmd-end:730 |
| `SXC` | 11114-11203 | 90 | 查看联动标记：选文字（回车=本图全部已标记文字），列出是未标记、原件、副本、原件缺失还是他图副本，点结果卡片条目定位；只读。 | aa:cmd-begin:717, aa:rep-begin:21535, aa:link-dwg-id:10555, aa:link-info:10511, aa:rep-item:21546, aa:link-txt:11109, aa:link-root-p:10551, aa:link-root-ed:11438, aa:link-dwg-label:11101, aa:merge-sort:805, aa:rep-info:21552, aa:rep-counts:21601 …共 14 个 |
| `SXD` | 11385-11431 | 47 | 跳到原件：点选文字，缩放到它的原件；原件在其他图纸时按图名找到该图，打开或切换过去；只读。 | aa:link-pick-text:11369, aa:link-info:10511, aa:link-dwg-id:10555, aa:link-root-ed:11438, aa:link-write-jump:11255, aa:link-locate-dwg:11360, aa:link-default-dir:10907, aa:link-dwg-label:11101, aa:link-ask-folder:10930, aa:link-remember-dir:10917, aa:link-send-later:11285 |
| `SX1` | 11457-11531 | 75 | 联动刷新：全图所有同 UID 的副本文字按原件内容单向更新（只同步文字内容），已保存的图同时导出跨图值文件。 | aa:cmd-begin:717, aa:link-clock:11433, aa:link-dwg-id:10555, aa:link-info:10511, aa:link-root-p:10551, aa:link-root-ed:11438, aa:link-split-text:10534, aa:ysdl-get-plain-text:1402, aa:link-text-for:10573, aa:link-file-path:10605, aa:link-export:10644, aa:cmd-end:730 |
| `SX2` | 11539-11619 | 81 | 跨图联动刷新：读取指定文件夹内各卷册图的 .aalink.txt 值文件，更新本图中原件在其他图纸的副本文字。 | aa:cmd-begin:717, aa:link-dwg-id:10555, aa:link-info:10511, aa:link-ask-folder:10930, aa:link-near-dir:10922, aa:link-collect-files:10841, aa:link-remember-dir:10917, aa:merge-sort:805, aa:link-file-time:10832, aa:link-filter-values:10794, aa:link-read-file:10689, aa:link-uid<:10595 …共 17 个 |
| `HBDL` | 11926-12031 | 106 | 框选电缆清册表格文字，自动将带有“并入”前缀的行合并到对应的目标电缆主行中，自动累加芯数并在末尾追加原理号，其他行保持原位。 | aa:cmd-begin:717, aa:cmd-end:730, aa:ysdl-get-plain-text:1402, hb:cluster-rows:11696, hb:parse-row:11725, hb:apply-merge-in-place:11841 |
| `NU` | 12327-12378 | 52 | 材料表数字加数字：优先改井号相邻数字，其次改最后一个减号后的连续整数，都没有时改第一个数字（支持小数和正负号）。 | aa:nu-rewrite-text:12276, aa:num-int-target-p:12257 |
| `KAI` | 12569-12652 | 84 | 将 TEXT/MTEXT 中由空格分隔的内容拆分为多个独立文字。 | aa:kai-add-texts-after-explode:12508, aa:kai-process-text:12526 |
| `ZHENG` | 12723-12853 | 131 | 以水平直线或矩形中心为基准整理文字的水平位置。 | aa:zheng-horizontal-line-p:12661, aa:safe-get-bbox:1113, aa:zheng-align-text-to-rect-center:12710, aa:zheng-line-mid-x:12676, aa:zheng-add-texts-after-explode:12683, aa:zheng-align-text-center-x:12701 |
| `AAE` | 13270-13355 | 86 | 选择块内属性文字，在自定义窗口中编辑并按回车直接保存。 | aa:cmd-begin:717, aae:split-lines:13224, aae:locate-dcl:13357, aae:resolve-val:13253, aa:cmd-end:730 |
| `HAO` | 13374-13378 | 5 | 选中图框后批量填写页码和档案号。 | aa:cmd-begin:717, fillframes-run:13078, aa:cmd-end:730 |
| `HAO2` | 13620-13777 | 158 | 指定基准块参照与图号矩形范围，批量居中填充或更新递增图号文字。 | aa:cmd-begin:717, blk-insertpt:12899, hao2:block-name:13391, hao2:sort-blocks:13405, zdml2:collect-all-texts:13453, hao2:format-num:13384, hao2:find-existing-text-fast:13587, tktj:current-space:18798, tktj:ensure-text-style:18808, aa:cmd-end:730 |
| `MING` | 13922-14086 | 165 | 按行列网格顺序，批量将单行文字填充到对应属性块的图名属性中。 | aa:cmd-begin:717, ming:find-title-attrib:13786, blk-insertpt:12899, ming:get-block-height:13823, ming:get-text-info:13839, ming:cluster-and-sort:13871, aa:cmd-end:730 |
| `FIVE` | 14095-14136 | 42 | 将测得高度按比例缩放为 5。 | aa:cmd-begin:717, aa:cmd-end:730 |
| `JZ` | 14156-14298 | 143 | 将矩形水平中线对齐到1条或2条直线中心线，可同步居中文字。 | aa:safe-get-bbox:1113, aa:jz-line-center-y:14144, aa:bbox-center-x:1137, aa:bbox-top-y:1151, aa:bbox-bottom-y:1155, aa:safe-move-entity:1159 |
| `FKX` | 14468-14539 | 72 | 单击框内空白处选择正文对象，自动排除图框和右下角标题栏；支持手动指定范围。 | aa:cmd-begin:717, fdx:poly-rect:14328, fdx:add-rect:14542, fkx:choose-frame:14363, fdx:rect-from-points:14306, fkx:collect:14400, fkx:title-rect:14430, fkx:point-in-p:14354, fkx:filter:14457, aa:cmd-end:730 |
| `FDX` | 14722-14760 | 39 | 先选方框，按从上到下、每行从左到右分配；每批文字按空格移动并按 DX 规则排列。 | fdx:restore:14618, aa:undo-mark-off:756, fdx:frames:14580, fdx:sort-frames:14599, fdx:show-frame:14611, aa:undo-mark-on:748, fdx:place:14646 |
| `DX` | 14971-15040 | 70 | 批量整理 100×100 方格内的端子号、原理号和终点柜文字，并将整组文字居中。 | aa:undo-mark-off:756, aa:zz-filter-text-ss:15260, aa:zz-harvest-lines:15528, aa:zz-build-spatial-index:15553, aa:zz-text-info:15619, aa:zz-group-by-rect:15670, aa:undo-mark-on:748, dx:apply-group:14882 |
| `DX2` | 15184-15243 | 60 | 按方格从左到右、从上到下导出文字，每个方格一行，框内按行排序并用顿号连接，复制到剪贴板。 | aa:cmd-begin:717, aa:zz-filter-text-ss:15260, aa:zz-harvest-lines:15528, aa:zz-build-spatial-index:15553, aa:zz-text-info:15619, aa:zz-group-by-rect:15670, dx2:sort-groups:15081, dx2:export-group:15169, zi:to-clip:17462, aa:cmd-end:730 |
| `ZZ` | 15820-15822 | 3 | 先将文字改为中下对正，再居中到最近矩形；多行文字按 5 个单位的中心间距排列。 | aa:zz-run:15764 |
| `ZZ2` | 15943-16039 | 97 | 按 ZZ 居中，恰好双文字单元格所在行调为10，下方内容顺延。 | aa:zz2-poly-ok:15930, aa:safe-get-bbox:1113, aa:zz2-frame:15910, aa:zz-build-spatial-index:15553, aa:zz-text-info:15619, aa:zz-group-by-rect:15670, aa:zz2-plan:15825, aa:zz2-plan-ok:15834, aa:cmd-begin:717, aa:zz2-map-edge:15865, aa:bbox-top-y:1151, aa:bbox-bottom-y:1155 …共 16 个 |
| `JACC` | 16042-16044 | 3 | ZZ 的同功能入口。 | aa:zz-run:15764 |
| `MJ` | 16187-16274 | 88 | 框选单列表格后，按最长文字自动收窄宽度并将各行文字居中。 | aa:mj-frame-bounds:16047, aa:mj-collect-text-data:16066, aa:mj-horizontal-ys:16094, aa:mj-scale-line-x:16167, aa:mj-move-cached-texts:16177 |
| `FIVE2` | 16338-16445 | 108 | 同一列相接的直线表格统一行高5，保留顶边、列宽、字高和圆形符号大小。 | aa:try-get-bbox:1102, aa:tbhb-segment:16450, aa:tbhb-merge-segments:16468, aa:hg5-rows:16280, aa:tbhb-border-p:16460, aa:hg5-side-p:16307, aa:hg5-text-y:16329, aa:cmd-begin:717, aa:hg5-point:16325, aa:hg5-y:16292, aa:cmd-end:730 |
| `HBBG` | 16645-16733 | 89 | 将完整直线表格按图纸位置从上到下复制拼接，保留原表及各段标题和列顺序。 | aa:undo-mark-off:756, aa:tbhb-collect:16597, aa:tbhb-boxes:16489, aa:tbhb-groups:16562, aa:tbhb-group-problem:16537, aa:merge-sort:805, aa:tbhb-before-p:16509, aa:tbhb-item-inside-p:16521, aa:undo-mark-on:748, aa:tbhb-offset:16573, aa:tbhb-shift-point:16579, aa:tbhb-seen-line-p:16583 …共 14 个 |
| `HZBG` | 16801-16865 | 65 | 选中文字生成表格，行高 5，按最宽文字自动列宽，左右各留 3。 | aa:safe-get-bbox:1113, aa:hzbg-plan:16750, aa:cmd-begin:717, aa:hzbg-move:16780, aa:hzbg-line:16793, aa:cmd-end:730 |
| `ZDWI` | 17135-17252 | 118 | 按各列最宽文字自动放宽或缩窄表格列宽，文字左右各留 3 个图纸单位，并按 ZZ 居中。 | aa:zdwi-expand-selection:16948, aa:zdwi-table-groups:17008, aa:zdwi-vertices:17071, aa:zdwi-unique:17054, aa:zdwi-add-span:17059, aa:merge-sort:805, aa:safe-get-bbox:1113, aa:zdwi-column:17084, aa:zdwi-set-nth:17093, aa:cmd-begin:717, aa:zdwi-map-entity:17110, aa:zz-move-text:15638 …共 14 个 |
| `FF` | 17377-17418 | 42 | 预选文字，空格确认查找及替换内容，批量替换所有匹配片段。 | aa:cmd-begin:717, aa:ysdl-get-raw-text:1317, aa:str-replace-all:1294, aa:ff-text-data:17358, aa:cmd-end:730 |
| `DB` | 17421-17425 | 5 | 删除每个选中文字末尾的 N 个字符。 | aa:cmd-begin:717, db:del:17288, aa:cmd-end:730 |
| `DF` | 17427-17431 | 5 | 删除每个选中文字开头的 N 个字符。 | aa:cmd-begin:717, db:del:17288, aa:cmd-end:730 |
| `AB` | 17433-17437 | 5 | 在每个选中文字末尾增加文字（空输入使用剪贴板）。 | aa:cmd-begin:717, db:add:17321, aa:cmd-end:730 |
| `AF` | 17439-17443 | 5 | 在每个选中文字开头增加文字（空输入使用剪贴板）。 | aa:cmd-begin:717, db:add:17321, aa:cmd-end:730 |
| `QE` | 17511-17592 | 82 | 用 Windows 剪贴板中的文字批量替换选中文字；文字含“至”字时只替换“至”后的部分。 | qe:get-clip-text:17480, qe:zhi-prefix:17501 |
| `CC` | 17595-17669 | 75 | 读取 Windows 剪贴板，连续复制并替换副本文字，使用原生拖动预览和对象捕捉。 | aa:cmd-begin:717, aa:cmd-error:246, qe:get-clip-text:17480, aa:cmd-end:730 |
| `QW` | 17738-17774 | 37 | 提取选中文字，同一行用顿号连接，不同行之间也用顿号分隔，并复制到剪贴板。 | aa:cmd-begin:717, aa:ysdl-get-plain-text:1402, zi:pt:17457, qw:join:17673, zi:to-clip:17462, aa:cmd-end:730 |
| `QW2` | 17780-17841 | 62 | 提取选中文字及坐标，每项一行“x,y 文字”，坐标保留 2 位小数，复制到剪贴板。 | aa:cmd-begin:717, aa:ysdl-get-plain-text:1402, zi:pt:17457, aa:merge-sort:805, zi:to-clip:17462, aa:cmd-end:730 |
| `QW2P` | 17947-17990 | 44 | 把剪贴板里“x,y 文字”格式的内容按 T 命令的样式写到当前图层，与 QW2 相反。 | aa:cmd-begin:717, qw2p:read-clip-file:17906, qe:get-clip-text:17480, qw2p:parse-clip:17889, qw2p:text-data:17935, aa:cmd-end:730 |
| `QW3` | 18214-18252 | 39 | 导出选中对象的类型、图层、坐标、几何及文字属性为结构化文本并复制到剪贴板。 | aa:cmd-begin:717, aa:qw3-record:18187, aa:merge-sort:805, zi:to-clip:17462, aa:cmd-end:730 |
| `TJK` | 18341-18391 | 51 | 点选块，统计当前空间或框选范围内同名块（含动态块）的数量，选中它们并用红圈和序号标出；Q 清除标记。 | aa:cmd-begin:717, tjk:clear-marks:18257, aa:cmd-end:730, hao2:block-name:13391, tjk:select:18287, tjk:items:18299, tjk:ensure-layer:18267, tjk:draw:18316 |
| `DX1` | 18396-18466 | 71 | 提取选中文字及坐标，青色文字额外标注“端子名”，复制到剪贴板。 | aa:cmd-begin:717, zi:pt:17457, dx:color-kind:14787, aa:merge-sort:805, zi:to-clip:17462, aa:cmd-end:730 |
| `CE` | 18497-18527 | 31 | 测量点序列形成的多段线总长度。 | aa:cmd-begin:717, ce-redraw:18481, aa:cmd-end:730 |
| `AW` | 18714-18756 | 43 | 自动微移选中文字，尽量避开旁边线段、文字和其他对象重叠。 | aw:get-selection:18706, aw:process-one:18680 |
| `ZDML` | 19124-19202 | 79 | 选择多个图框块，生成目录文字。 | aa:cmd-begin:717, tktj:safe-vla-object:18826, tktj:collect-one-block:18950, tktj:sort-by-page:19067, tktj:sort-by-position:19078, tktj:take:19022, tktj:draw-table:19039, tktj:drop:19031, aa:cmd-end:730 |
| `ZDML2` | 19266-19437 | 172 | 指定基准块参照与图名、图号矩形范围，批量提取图名图号并生成目录。 | aa:cmd-begin:717, blk-insertpt:12899, hao2:block-name:13391, hao2:sort-blocks:13405, zdml2:collect-all-texts:13453, zdml2:build-spatial-index:13501, zdml2:extract-rect-text-fast:19208, zdml2:query-rect-index:13554, tktj:take:19022, tktj:draw-table:19039, tktj:drop:19031, aa:cmd-end:730 |
| `ZDMLDEBUG` | 19440-19474 | 35 | 选择一个图框块，打印所有增强属性。 | aa:cmd-begin:717, tktj:get-attributes:18899, aa:cmd-end:730 |
| `DUMP` | 19478-19502 | 25 | 打印选中图元的 ActiveX 属性与可用方法（调试辅助）。 | aa:cmd-begin:717, aa:cmd-end:730 |
| `C1` | 19770-19772 | 3 | 复制文字（可多选，各自变化）并把编号加 1（优先井号相邻数字，其次减号后数字），使用原生拖动预览和捕捉连续放置。 | c1c2:run:19699 |
| `C2` | 19774-19776 | 3 | 复制文字（可多选，各自变化）并把编号减 1（优先井号相邻数字，其次减号后数字），使用原生拖动预览和捕捉连续放置。 | c1c2:run:19699 |
| `C3` | 19778-19780 | 3 | 复制文字（可多选，各自变化）并把编号每次加 2（优先井号相邻数字，其次减号后数字），使用原生拖动预览和捕捉连续放置。 | c1c2:run:19699 |
| `DE` | 20127-20127 | 1 | 删除选中文字的最右侧括号及括号内容。 | de:run:20081 |
| `DE2` | 20128-20128 | 1 | 用最右侧括号内容替换括号前同样位数的数字（数字带相同尾缀时一并替换，A63(4)0I → A640I）。 | de:run:20081 |
| `GE` | 20215-20317 | 103 | 选中同一水平行的单行文字，按文字间隙绘制单行表格。 | ge:end-undo:20139, ge:get-item:20153, ge:sort-items:20190, ge:make-line:20197 |
| `UT` | 20428-20540 | 113 | 先将文字统一为左中对正，再按最上方一对的位置整理文字；支持直线及按首尾端点计算的未闭合多段线，保留宽度。 | aa:undo-mark-off:756, ut:horizontal-line-p:20345, ut:get-bbox:20367, ut:line-y:20360, ut:sort-desc:20404, aa:undo-mark-on:748, aa:normalize-text-horizontal-align:3955, ut:bbox-bottom:20384, ut:bbox-left:20380, ut:move:20412 |
| `0` | 20551-20585 | 35 | 将所选对象中的文字旋转角度统一改为 0 度。 | aa:cmd-begin:717, aa:cmd-end:730 |
| `9` | 20634-20643 | 10 | 以所选对象整体包围框中心为基点，整体顺时针旋转 90 度。 | aa:cmd-begin:717, aa:rotate-90-run:20592, aa:cmd-end:730 |
| `99` | 20646-20655 | 10 | 以所选对象整体包围框中心为基点，整体逆时针旋转 90 度。 | aa:cmd-begin:717, aa:rotate-90-run:20592, aa:cmd-end:730 |
| `QZ` | 20662-20710 | 49 | 取消当前图纸中的全部分组，组内图元保持不变。 |  |
| `DL1` | 20738-20755 | 18 | 创建电缆柜、电缆路径、电缆竖井相关的 1F / 2F 图层。 | aa:cmd-begin:717, dl1:make-layer:20722, aa:cmd-end:730 |
| `REP` | 20779-20873 | 95 | 将选中的柜名文字按内置映射表替换为标准柜名。 | aa:cmd-begin:717, rep-trim:20769, aa:cmd-end:730 |
| `KMZ` | 21166-21168 | 3 | 选中两条水平线后向左生成短线、矩形并居中标注+KM、-KM及直流馈线柜（青色虚线）。 | aa:km-ln-cmd:20958 |
| `KMY` | 21172-21174 | 3 | 选中两条水平线后向右生成短线、矩形并居中标注+KM、-KM及直流馈线柜（青色虚线）。 | aa:km-ln-cmd:20958 |
| `LNZ` | 21178-21180 | 3 | 选中两条水平线后向左生成短线、矩形并居中标注L、N及相邻屏柜（青色虚线）。 | aa:km-ln-cmd:20958 |
| `LNY` | 21184-21186 | 3 | 选中两条水平线后向右生成短线、矩形并居中标注L、N及相邻屏柜（青色虚线）。 | aa:km-ln-cmd:20958 |
| `UPSZ` | 21190-21192 | 3 | 选中两条水平线后向左生成短线、矩形并居中标注L、N及UPS电源柜（青色虚线）。 | aa:km-ln-cmd:20958 |
| `UPSY` | 21196-21198 | 3 | 选中两条水平线后向右生成短线、矩形并居中标注L、N及UPS电源柜（青色虚线）。 | aa:km-ln-cmd:20958 |
| `BZ` | 21202-21204 | 3 | 选中两条水平线后向左生成短线、矩形并居中标注B+、B-及同步时钟主机柜（青色虚线）。 | aa:km-ln-cmd:20958 |
| `BY` | 21208-21210 | 3 | 选中两条水平线后向右生成短线、矩形并居中标注B+、B-及同步时钟主机柜（青色虚线）。 | aa:km-ln-cmd:20958 |
| `ZJ` | 21242-21244 | 3 | 选中多条水平线后向左生成短线、矩形；原理号标注不变，柜内文字默认读取剪贴板，可手动输入（青色虚线）。 | aa:zj-cmd:21217 |
| `YJ` | 21248-21250 | 3 | 选中多条水平线后向右生成短线、矩形；原理号标注不变，柜内文字默认读取剪贴板，可手动输入（青色虚线）。 | aa:zj-cmd:21217 |
| `YDZ` | 21452-21454 | 3 | 选中多条水平线后向左生成短线、矩形并从上往下标注701、-901、-903...及公用测控柜（青色虚线）。 | aa:yd-cmd:21258 |
| `YDY` | 21458-21460 | 3 | 选中多条水平线后向右生成短线、矩形并从上往下标注701、-901、-903...及公用测控柜（青色虚线）。 | aa:yd-cmd:21258 |
| `LBZ` | 21464-21466 | 3 | 选中多条水平线后向左生成短线、矩形并从上往下标注500、-501、-503...及故障录波柜（青色虚线）。 | aa:yd-cmd:21258 |
| `LBY` | 21470-21472 | 3 | 选中多条水平线后向右生成短线、矩形并从上往下标注500、-501、-503...及故障录波柜（青色虚线）。 | aa:yd-cmd:21258 |
| `485Z` | 21476-21478 | 3 | 选中至少两条水平线后向左生成短线、矩形并居中标注485+、485-及网络通信柜（青色虚线）。 | aa:km-ln-cmd:20958 |
| `485Y` | 21482-21484 | 3 | 选中至少两条水平线后向右生成短线、矩形并居中标注485+、485-及网络通信柜（青色虚线）。 | aa:km-ln-cmd:20958 |
| `XX` | 21495-21523 | 29 | 将选中文字内容替换为 7×2.5。 | aa:cmd-begin:717, aa:cmd-end:730 |
| `JM` | 21902-21977 | 76 | 按绿色电缆线（水平或竖直）所连原理号，把 ZDDLH/ZDDLS 生成的“未填写”替换为电缆截面；无法判断的保留并选中提示。 | aa:cmd-begin:717, aa:rep-begin:21535, xyg:dedup-hlines:9733, xy:ss->list:8335, xy:filter-green-hlines:9425, xy:collect-vlines:8616, xy:build-vline-buckets:8544, xy:build-text-meta-list:8876, xy:collect-texts:8641, xy:hline-info-ed:8431, jm:find-spec-text:21864, aa:ysdl-get-plain-text:1402 …共 24 个 |
| `HDDZ` | 22476-22487 | 12 | 先选原理图剔出的端子与原理号，再选端子图，按“端子名:端子号”核对两边原理号是否一致，问题写结果卡片、标红并选中。 | aa:cmd-begin:717, hddz:work:22465, aa:cmd-end:730 |
| `BH2` | 23497-23672 | 176 | 框选起点柜和绿色电缆线，把已编号但没记录的电缆记入共享记录，给有记录的“未编号”按记录填写；不分配新编号，两端不一致的标红注明原因。 | aa:cmd-begin:717, aa:rep-begin:21535, aa:link-clock:11433, bh:prepare:22891, bh:record-path:22603, bh:now:22607, bh:fold-joins:22843, bh:read-records:22634, bh:rec-key:22542, bh:kmap:22553, bh:nmap:22566, bh:split-map:23482 …共 34 个 |
| `BHG` | 23675-23790 | 116 | 以图为准修改电缆编号记录：记录编号改成图上的编号，原编号存为旧编号供另一端 BH1/BH2 自动跟改；“未编号”的删除其记录。 | aa:cmd-begin:717, aa:rep-begin:21535, aa:link-clock:11433, bh:prepare:22891, bh:record-path:22603, bh:now:22607, bh:fold-joins:22843, bh:read-records:22634, bh:rec-key:22542, bh:kmap:22553, bh:nmap:22566, bh:clean:22522 …共 26 个 |
| `BH1` | 24103-24314 | 212 | 逐根点选编号：先点起点柜名大字并输入前缀、起始号，再依次点绿色电缆线，回车后自动缩放一次识别并按点选顺序编号，同终点加 A/B/C，可撤销本批。 | aa:cmd-begin:717, bh:pick-start:23998, bh:ask-prefix:22971, bh:ask-start:22981, bh:record-path:22603, bh:fold-joins:22843, bh:read-records:22634, bh:rec-key:22542, bh:kmap:22553, bh:nmap:22566, bh:own-records:23955, bh:write-records:22654 …共 42 个 |
| `BH3` | 24393-24569 | 177 | 框选电缆清册文字（起点柜/编号/终点柜/规格/芯数/原理号），以清册为准写入共享记录：没有的记入，有的强制改成清册编号（同 BHG）。 | aa:cmd-begin:717, aa:rep-begin:21535, hddl:text:24989, hddl:point:25007, aa:merge-sort:805, hddl:sort-rows:25071, hddl:rows:25061, hddl:coord:25001, bh:record-path:22603, bh:now:22607, bh:fold-joins:22843, bh:read-records:22634 …共 32 个 |
| `ZDAO` | 24689-24693 | 5 | 将选中文字按垂直位置上下颠倒排列（最下面的文字放到最上面，原 DAO）。 | aa:cmd-begin:717, dao:run:24627, aa:cmd-end:730 |
| `HDAO` | 24696-24700 | 5 | 将选中文字按水平位置左右颠倒排列（最左边的文字放到最右边）。 | aa:cmd-begin:717, dao:run:24627, aa:cmd-end:730 |
| `QH` | 24705-24856 | 152 | 只选中已选文字所在行、且位于当前屏幕内、参考文字左右各 1000 内的所有文字（跨多行时逐行选择）。 | aa:merge-sort:805 |
| `BK` | 24886-24929 | 44 | 选中文字后只保留最后一对括号内的内容，括号外有“至”时保留“至”。 | de:end-undo:20064, de:get-text:20048, bk:extract-inner:24867, de:set-text:20057 |
| `HDDL` | 25217-25307 | 91 | 直接校核选中文字中的电缆编号、规格和原理号，问题行标红并在行首标注。 | aa:undo-mark-off:756, aa:undo-mark-on:748, hddl:ensure-layer:24938, hddl:clear-markers:24978, hddl:text:24989, hddl:point:25007, hddl:sort-rows:25071, hddl:rows:25061, hddl:group-rows:25076, hddl:mirror-p:25211, hddl:cell:25121, hddl:tail-count:25127 …共 20 个 |
| `CU` | 25381-25382 | 2 | 将选中对象按 5 个单位的递增间距向上复制指定份数。 | cu:copy-direction:25313 |
| `CD` | 25385-25386 | 2 | 将选中对象按 5 个单位的递增间距向下复制指定份数。 | cu:copy-direction:25313 |
| `CZ` | 25389-25390 | 2 | 将选中对象按 5 个单位的递增间距向左复制指定份数。 | cu:copy-direction:25313 |
| `CY` | 25393-25394 | 2 | 将选中对象按 5 个单位的递增间距向右复制指定份数。 | cu:copy-direction:25313 |
| `HS` | 25447-25619 | 173 | 选中物体单向横向缩放，左右宽度改变，高度保持不变。 | aa:cmd-begin:717, aa:hs-filter-unlocked:25401, aa:cmd-end:730, aa:hs-get-ss-bbox:25421 |
| `ZS` | 25628-25800 | 173 | 选中物体单向纵向缩放，上下高度改变，宽度保持不变。 | aa:cmd-begin:717, aa:hs-filter-unlocked:25401, aa:cmd-end:730, aa:hs-get-ss-bbox:25421 |
| `SC3` | 25832-25899 | 68 | 将选中对象整体等比例缩小，使四周距 A3 外框至少 5mm。 | aa:cmd-begin:717, aa:sc3-layer-locked-p:25806, aa:sc3-entity-bbox:25814, aa:cmd-end:730 |
| `Z0` | 25966-26009 | 44 | 将选中对象的 Z 坐标全部归零（压平到 XY 平面）。 | aa:cmd-begin:717, aa:z0-layer-locked-p:25905, aa:z0-data-flat-p:25923, aa:z0-polyline-flat-p:25956, aa:z0-one:25936, aa:z0-polyline-verts:25948, aa:cmd-end:730 |
| `VPO1` | 26015-26020 | 6 | 切换到“单个”标准视口。 | aa:cmd-begin:717, aa:cmd-end:730 |
| `VPO2` | 26023-26028 | 6 | 切换到“两个：垂直”标准视口。 | aa:cmd-begin:717, aa:cmd-end:730 |
| `TONG` | 26034-26118 | 85 | 框选文字对象去重，按自然顺序从上到下排列在指定插入点（HZ样式/字高3/宽比0.7/白色/间距5）。 | aa:cmd-begin:717, aa:cmd-end:730, aa:merge-sort:805, aa:gtx-natural-less:6814 |
| `ZDDL2` | 26779-26870 | 92 | 自动根据现有端子排与接线方格绘制电缆引线、干线与标注。 | aa:cmd-begin:717, aa:cmd-end:730, zddl:parse-strip:26310, zddl:parse-wiring-ss:26531, zddl:ensure-layer:26591, zddl:plan-cables:26668, zddl:lookup-terminal:26219, zddl:label-layout:26693, zddl:draw-one-cable:26700, zddl:format-cable-no:26658 |
| `ZDC` | 26872-26874 | 3 | ZDDLH 命令的简写别名。 | c:zddlh:29232 |
| `ZDDLD` | 27964-27992 | 29 | 删除 ZDDL 生成的端子排框线与端子名/号，保留原理号、电缆接线和电缆文字。 | aa:cmd-begin:717, zddl2:xdata-app:27947, aa:layer-locked-p:5141, zddl2:set-layer-lock:27950, aa:cmd-end:730 |
| `XZYL` | 29198-29204 | 7 | 修正原理号：先点原理号正确的电缆录入，再运行点对面一端的同一根电缆，替换不一致的原理号并补填未编号；合画图录入按 1#/2# 拆开；可先选电缆线再运行。 | aa:cmd-begin:717, zyl:work:29166, aa:cmd-end:730 |
| `BDL` | 29210-29216 | 7 | 选择后补的原理号，按 ZDDL 样式补画引线、短斜线、电缆线、箭头和占位文字，自动找空行；选水平原理号时按竖排端子排补画竖直电缆线。 | aa:cmd-begin:717, bdl:work:28610, aa:cmd-end:730 |
| `BDL2` | 29219-29226 | 8 | 连续补画多根电缆：逐根选原理号按空格记住，不选直接空格后一次生成（同 BDL），生成前可先调整窗口，一次 U 全部撤销。 | aa:cmd-begin:717, bdl:work-multi:28626, bdl:hilite:28618, aa:cmd-end:730 |
| `ZDDLH` | 29232-29239 | 8 | 两次选择文字并指定左下基点，生成横排端子排与水平绿色电缆线（原 ZDDL）。 | aa:cmd-begin:717, zddl2:work:27861, aa:cmd-end:730 |
| `ZDDLS` | 29245-29252 | 8 | 两次选择文字并指定左上基点，生成竖排端子排、水平引线与竖直绿色电缆线（向下箭头、文字 270°）。 | aa:cmd-begin:717, zddl2:work:27861, aa:cmd-end:730 |

## 辅助函数分组（按前缀）

| 前缀 | 函数数 | 行号分布 | 使用这些函数的命令 |
|------|------|------|------|
| `aa:` | 339 | 246-343, 397-520, 717-829, 1080-1879, 3225-3286, 3480-4050 … | 0, 485Y, 485Z, 9, 99, A2T, AAE, AB, ABCN, AF, ASHANG, ATW, AXIA, AYOU, AZUO …共 176 个 |
| `des:` | 5 | 552-580 | DES |
| `ystemp:` | 2 | 651-658 | YSTEMP |
| `ztf:` | 13 | 831-1063 | ZTF |
| `txt:` | 7 | 1934-2136 | T, T2 |
| `zhu:` | 5 | 2153-2194 | ZHU |
| `hwt:` | 14 | 2248-2461 | HWT |
| `txt2:` | 5 | 2522-2669 | DH, T2 |
| `dh:` | 10 | 2684-2884 | DH |
| `qr:` | 3 | 4974-4996 | QR, QR2 |
| `det:` | 1 | 5218-5236 | DET |
| `a2t:` | 3 | 5291-5316 | A2T |
| `long:` | 8 | 5719-5777 | LONG |
| `gty2:` | 4 | 7470-7607 | GTY2 |
| `(无前缀):` | 22 | 7918-7970, 8013-8040, 12875-13146, 18481-18494, 20769-20777 | BIAN, CE, HAO, HAO2, LAN, MING, REP, ZDML2 |
| `xy:` | 47 | 8322-9446 | BH1, BH2, BHG, JM, XY, XYG, XYG2, XYG3, XZYL |
| `xyg:` | 32 | 9472-10486 | BH1, BH2, BHG, DE, DE2, JM, SX1, SX2, XYG, XYG2, XYG3 |
| `hb:` | 9 | 11627-11924 | HBDL |
| `aae:` | 4 | 13149-13268, 13357-13372 | AAE, HAO2, MING, ZDC, ZDDLH, ZDDLS, ZDML, ZDML2, ZDMLDEBUG |
| `hao2:` | 4 | 13384-13451, 13587-13618 | HAO2, TJK, ZDML2 |
| `zdml2:` | 4 | 13453-13584, 19208-19264 | HAO2, ZDML2 |
| `ming:` | 4 | 13786-13920 | MING |
| `fdx:` | 11 | 14306-14348, 14542-14720 | FDX, FKX |
| `fkx:` | 10 | 14354-14464 | FKX |
| `dx:` | 12 | 14763-14969 | DX, DX1, DX2, FDX, HDDZ, ZDC, ZDDL2, ZDDLH, ZDDLS |
| `dx2:` | 12 | 15047-15182 | DX2, ZDC, ZDDL2, ZDDLH, ZDDLS |
| `db:` | 5 | 17268-17355 | AB, AF, DB, DF |
| `zi:` | 2 | 17457-17477 | DX1, DX2, QW, QW2, QW3 |
| `qe:` | 2 | 17480-17508 | AB, AF, CC, QE, QW2P, YJ, ZJ |
| `qw:` | 1 | 17673-17734 | QW |
| `qw2p:` | 6 | 17844-17944 | QW2P |
| `tjk:` | 6 | 18257-18338 | TJK |
| `aw:` | 17 | 18542-18712 | AW, XZYL |
| `tktj:` | 24 | 18786-19121 | HAO2, MING, ZDML, ZDML2, ZDMLDEBUG |
| `c1c2:` | 15 | 19522-19768 | C1, C2, C3 |
| `de:` | 21 | 19801-20125 | BK, DE, DE2, SX1, SX2, XYG, XYG2, XYG3 |
| `ge:` | 6 | 20139-20213 | GE |
| `ut:` | 10 | 20324-20426 | UT |
| `dl1:` | 1 | 20722-20736 | DL1 |
| `jm:` | 20 | 21654-21899 | BDL, BDL2, BH1, BH2, BH3, BHG, JM, XZYL |
| `hddz:` | 39 | 21995-22473 | HDDZ |
| `bh:` | 101 | 22514-23494, 23795-24100, 24315-24390 | BDL, BDL2, BH1, BH2, BH3, BHG, DE, DE2, JM, SX1, SX2, XYG, XYG2, XYG3, XZYL |
| `dao:` | 4 | 24579-24686 | HDAO, ZDAO |
| `bk:` | 1 | 24867-24884 | BK |
| `hddl:` | 29 | 24938-25215 | BH1, BH2, BH3, BHG, HDDL, XZYL, YSDL, YSDL2 |
| `cu:` | 1 | 25313-25378 | CD, CU, CY, CZ |
| `zddl:` | 27 | 26127-26777 | BDL, BDL2, ZDC, ZDDL2, ZDDLH, ZDDLS |
| `zddl2:` | 96 | 26882-27958 | BDL, BDL2, YSDL, YSDL2, ZDC, ZDDLD, ZDDLH, ZDDLS |
| `bdl:` | 39 | 27999-28804 | BDL, BDL2, XZYL |
| `zyl:` | 31 | 28813-29192 | XZYL |
