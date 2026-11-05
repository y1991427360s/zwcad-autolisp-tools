# AA整合版本.lsp 代码地图

> 由 `python tools/code_map.py write` 自动生成（`python gen_命令索引.py` 也会顺带生成），请勿手工维护。
> 行号随源码变动；改完 LISP 后重新生成，`python tools/check_all_static.py` 会校验本文件是否过期。

## 使用方法（给 AI / 人）

1. **不要通读整合文件。** 先在下表找命令的行号范围，再按行号只读那一段。
2. `python tools/code_map.py show 命令或函数` 直接输出行号范围和下游调用（加 `--source` 打印源码）。
3. 改共享函数前先跑 `python tools/code_map.py callers 函数名`，确认影响哪些命令。
4. 改动过程中用 `python tools/check_all_static.py --quick` 只跑相关检查；交付前跑一次不带参数的全量检查。

- 源文件：`AA整合版本.lsp`，29333 行，1286 个函数，其中 187 个 `c:` 命令。

## 命令

| 命令 | 行号 | 行数 | 说明 | 直接调用的项目函数（行号） |
|------|------|------|------|------|
| `YS` | 346-395 | 50 | 选取两点生成绿色直线及终点直径100的同层全绿晶体机械徽章，无中央字母标志。 | aa:cmd-begin:718, aa:ys-line:269, aa:ys-ring:338, aa:ys-rim:327, aa:ys-snowflake:295, aa:ys-detail:320, aa:cmd-end:731 |
| `YS1` | 524-550 | 27 | 选取两点生成绿色直线，以第二点为中心生成高80的TGOOD机械装甲线条Logo，可整体撤销。 | aa:cmd-begin:718, aa:ys-line:269, aa:ys1-t:424, aa:ys1-g:441, aa:ys1-o:461, aa:ys1-d:498, aa:cmd-end:731 |
| `DES` | 584-649 | 66 | 所选直线共线重叠时删除短线、保留长线；完全重复留一条，跨图层处理并跳过锁定图层。 | aa:cmd-begin:718, des:key-less-p:553, aa:merge-sort:806, des:record-less-p:558, des:x-less-p:562, des:overlap-p:568, aa:cmd-end:731 |
| `YSTEMP` | 662-716 | 55 | 删除所选对象中竖直共线、首尾相接且长度分别为 21 和 7 的直线对。 | aa:cmd-begin:718, aa:merge-sort:806, ystemp:y-less-p:652, ystemp:pair-p:656, aa:cmd-end:731 |
| `ZTF` | 1077-1090 | 14 | 搜索系统字体并将选定字体写入指定文字样式。 | aa:cmd-begin:718, ztf:collect-font-records:940, ztf:run-dialog:1047, aa:cmd-end:731 |
| `YSDL` | 1895-1895 | 1 | 提取选中文字到CSV文件，并改变文字颜色。 | aa:ysdl-run:1670 |
| `YSDL2` | 1899-1899 | 1 | 按 YSDL 格式导出电缆文字到CSV，同一电缆编号只导出最先出现的一行。 | aa:ysdl-run:1670 |
| `Q` | 1911-1937 | 27 | 快速从当前选择中仅选中所有文字对象。 | aa:cmd-begin:718, aa:cmd-end:731 |
| `T` | 2152-2156 | 5 | 把文字及ATTDEF属性定义刷为HZ样式，高度3，宽度0.7；按可见范围保持对齐文字位置。 | aa:cmd-begin:718, txt:run:2135, aa:cmd-end:731 |
| `ZHU` | 2208-2252 | 45 | 选中端子排名和端子号文字，选短接或拆除连片，生成HZ/3/0.7的“注：”单行文字。 | aa:cmd-begin:718, aa:ysdl-get-plain-text:1414, zhu:classify:2177, zhu:trim:2165, zhu:pick-name:2196, zhu:build-note:2187, aa:cmd-end:731 |
| `HWT` | 2475-2526 | 52 | 框选一列柜名文字，按从上到下顺序每行最多5个蛇形排列，生成L1/N1端子、SML电缆编号和两端JL进线的环网图，并输出可供BH3登记的电缆清单。 | aa:cmd-begin:718, aa:ysdl-get-plain-text:1414, aa:merge-sort:806, hwt:counts-text:2398, hwt:row-counts:2260, hwt:draw:2423, hwt:layout:2304, hwt:cable-no:2270, hwt:draw-list:2452, hwt:cable-rows:2385, aa:cmd-end:731 |
| `T2` | 2721-2725 | 5 | 把文字及ATTDEF属性定义刷为宋体样式，高度3，宽度0.8；按可见范围保持对齐文字位置。 | aa:cmd-begin:718, txt2:run:2708, aa:cmd-end:731 |
| `SONG` | 2736-2757 | 22 | 把图中只绑 simsun.ttc 字体文件、没写字体名的文字样式改为按字体名“宋体”设置，AutoCAD 打开不再显示 simsun.ttc、字形一致。 | aa:cmd-begin:718, aa:style-bad-simsun-p:2548, aa:style-use-songti:2537, song:join:2731, aa:cmd-end:731 |
| `DH` | 2968-2972 | 5 | 把选中的多行文字转成规整的单行文字，保持原位置和对齐，文字不再碎成多段。 | aa:cmd-begin:718, dh:run:2949, aa:cmd-end:731 |
| `ABCN` | 2989-3040 | 52 | 指定一点生成青色 A、B、C、N 单行文字，HZ/3/0.7、左中对正、按 H 默认间距5向下排列。 | aa:cmd-begin:718, aa:safe-get-bbox:1125, aa:safe-move-entity:1171, aa:cmd-end:731 |
| `H` | 3042-3169 | 128 | 先将选中文字统一为左中对正，再按指定间距（插入点/对齐点之间）从上到下排列。 | aa:cmd-begin:718, aa:normalize-text-horizontal-align:4037, aa:merge-sort:806, aa:cmd-end:731 |
| `H2` | 3176-3300 | 125 | 先将选中文字统一为左中对正，右侧文字在最上、越靠左越靠下，按指定间距从上到下排列。 | aa:cmd-begin:718, aa:normalize-text-horizontal-align:4037, aa:merge-sort:806, aa:cmd-end:731 |
| `Y` | 3326-3330 | 5 | 将选中对象的颜色快速变为青色。 | aa:cmd-begin:718, aa:color-cmd:3307, aa:cmd-end:731 |
| `DZ` | 3370-3404 | 35 | 将所选其他文字改为Y命令的青色，保留纯数字及数字后接单个小写a的文字原色。 | aa:cmd-begin:718, aa:ysdl-get-plain-text:1414, aa:dz-number-p:3336, aa:dz-color-text:3352, aa:cmd-end:731 |
| `YY` | 3410-3414 | 5 | 将选中对象快速改为黄色。 | aa:cmd-begin:718, aa:color-cmd:3307, aa:cmd-end:731 |
| `RR` | 3420-3424 | 5 | 将选中对象快速改为红色。 | aa:cmd-begin:718, aa:color-cmd:3307, aa:cmd-end:731 |
| `WW` | 3430-3434 | 5 | 将选中对象快速改为白色。 | aa:cmd-begin:718, aa:color-cmd:3307, aa:cmd-end:731 |
| `WWW` | 3440-3446 | 7 | 将选中对象强制改为白色；尺寸标注全要素变白，引线先分解再变白，块参照连块内实体一起改。 | aa:cmd-begin:718, aa:deep-color-cmd:3843, aa:cmd-end:731 |
| `XU` | 3452-3526 | 75 | 将所有选中且支持线型修改的对象改为 HIDDEN2。 |  |
| `GG` | 3532-3536 | 5 | 将选中对象快速改为绿色。 | aa:cmd-begin:718, aa:color-cmd:3307, aa:cmd-end:731 |
| `PP` | 3542-3546 | 5 | 将选中对象快速改为洋红色。 | aa:cmd-begin:718, aa:color-cmd:3307, aa:cmd-end:731 |
| `HH` | 3552-3556 | 5 | 将选中对象快速改为颜色 8（与 HUI 同色）。 | aa:cmd-begin:718, aa:color-cmd:3307, aa:cmd-end:731 |
| `HUI` | 3922-3927 | 6 | 将选中对象强制改为颜色 8；尺寸标注全要素改色，引线先分解再改色，块参照连块内实体一起改。 | aa:cmd-begin:718, aa:deep-color-cmd:3843, aa:cmd-end:731 |
| `ZHONG` | 3981-3985 | 5 | 文字居中对齐；选择直线/矩形时按中心 X 居中。 | aa:align-text-cmd:3930, aa:find-ref-by-top-bbox:1237, aa:bbox-center-x:1149, aa:normalize-visual-h:4124, aa:align-text-horizontal-by-bbox:1277 |
| `ZUO` | 4135-4139 | 5 | 将选中文字按视觉左侧统一对正（旋转文字按方向换算），并以最左侧文字为基准左对齐。 | aa:align-text-cmd:3930, aa:find-ref-by-left-bbox:1197, aa:bbox-left-x:1155, aa:normalize-visual-h:4124, aa:align-text-horizontal-by-bbox:1277 |
| `AZUO` | 4145-4264 | 120 | 选择一条竖直直线作为基准线，框选其他所有对象作为一个整体整体移动并左对齐到该直线。 | aa:cmd-begin:718, aa:cmd-end:731, aa:safe-get-bbox:1125, aa:bbox-left-x:1155, aa:safe-move-entity:1171 |
| `HP` | 4270-4407 | 138 | 将选中文字按从左到右排列，使相邻文字首尾间距为指定值，并按最左文字上边对齐。 | aa:cmd-begin:718, aa:cmd-end:731, aa:safe-get-bbox:1125, aa:bbox-left-x:1155, aa:bbox-top-y:1163, aa:merge-sort:806, aa:bbox-right-x:1159, aa:safe-move-entity:1171 |
| `HP2` | 4413-4556 | 144 | 将选中文字改为正中对齐，按中心点指定间距从左到右横向排列。 | aa:cmd-begin:718, aa:cmd-end:731, aa:normalize-text-horizontal-align:4037, aa:safe-get-bbox:1125, aa:bbox-center-x:1149, aa:bbox-top-y:1163, aa:bbox-bottom-y:1167, aa:merge-sort:806, aa:safe-move-entity:1171 |
| `YOU` | 4559-4563 | 5 | 将选中文字按视觉右侧统一对正（旋转文字按方向换算），并以最右侧文字为基准右对齐。 | aa:align-text-cmd:3930, aa:find-ref-by-right-bbox:1217, aa:bbox-right-x:1159, aa:normalize-visual-h:4124, aa:align-text-horizontal-by-bbox:1277 |
| `AYOU` | 4568-4687 | 120 | 选择一条竖直直线作为基准线，框选其他所有对象作为一个整体整体移动并右对齐到该直线。 | aa:cmd-begin:718, aa:cmd-end:731, aa:safe-get-bbox:1125, aa:bbox-right-x:1159, aa:safe-move-entity:1171 |
| `SHANG` | 4690-4694 | 5 | 将选中文字按视觉上方统一对正（竖排文字定位点在顶端），并以最上方文字为基准上对齐。 | aa:align-text-cmd:3930, aa:find-ref-by-top-bbox:1237, aa:bbox-top-y:1163, aa:normalize-visual-v:4129, aa:align-text-vertical-by-bbox:1291 |
| `ASHANG` | 4700-4819 | 120 | 选择一条水平直线作为基准线，框选其他所有对象作为一个整体整体移动并向上对齐到该直线。 | aa:cmd-begin:718, aa:cmd-end:731, aa:safe-get-bbox:1125, aa:bbox-top-y:1163, aa:safe-move-entity:1171 |
| `XIA` | 4822-4826 | 5 | 将选中文字按视觉下方统一对正（竖排文字定位点在底端），并以最下方文字为基准下对齐。 | aa:align-text-cmd:3930, aa:find-ref-by-bottom-bbox:1257, aa:bbox-bottom-y:1167, aa:normalize-visual-v:4129, aa:align-text-vertical-by-bbox:1291 |
| `AXIA` | 4831-4950 | 120 | 选择一条水平直线作为基准线，框选其他所有对象作为一个整体整体移动并向下对齐到该直线。 | aa:cmd-begin:718, aa:cmd-end:731, aa:safe-get-bbox:1125, aa:bbox-bottom-y:1167, aa:safe-move-entity:1171 |
| `HE` | 4952-5045 | 94 | 将同一行的两个或以上文字合并。 | aa:cmd-begin:718, aa:insert-sort:778, aa:cmd-end:731 |
| `QR` | 5080-5125 | 46 | 快速修改文字高度，记忆上次高度，回车沿用。 | aa:cmd-begin:718, qr:last-height:5056, qr:height-str:5075, qr:save-height:5068, aa:cmd-end:731 |
| `QR2` | 5131-5161 | 31 | 连续选择文字修改高度，与 QR 共用上次高度；高度回车沿用，选择回车或 Esc 退出。 | aa:cmd-begin:718, qr:last-height:5056, qr:height-str:5075, qr:save-height:5068, aa:cmd-end:731 |
| `DEA` | 5167-5190 | 24 | 删除所选对象中高度小于 0.1 的 TEXT/MTEXT 文字。 | aa:cmd-begin:718, aa:cmd-end:731 |
| `DEK` | 5197-5217 | 21 | 删除选中内容中的所有块参照 (INSERT)。 | aa:cmd-begin:718, aa:cmd-end:731 |
| `DEH` | 5260-5290 | 31 | 删除所选对象中内容含有中文的 TEXT/MTEXT 文字。 | aa:cmd-begin:718, aa:has-chinese:5238, aa:ysdl-get-plain-text:1414, aa:layer-locked-p:5223, aa:cmd-end:731 |
| `DET` | 5320-5361 | 42 | 删除所选对象中内容为指定值(逗号或空格分隔、不区分大小写、回车沿用上次)的属性定义ATTDEF。 | aa:cmd-begin:718, det:split-values:5300, aa:ysdl-get-raw-text:1329, aa:layer-locked-p:5223, aa:cmd-end:731 |
| `A2T` | 5400-5437 | 38 | 将属性定义ATTDEF（炸块残留、X/BURST无法分解）转为普通单行文字，可选标记/默认值/提示。 | aa:cmd-begin:718, a2t:pick-string:5378, a2t:layer-locked-p:5373, a2t:text-dxf:5390, aa:cmd-end:731 |
| `WI` | 5443-5483 | 41 | 修改选中文字的宽度比例。 | aa:cmd-begin:718, aa:cmd-end:731 |
| `ATW` | 5490-5574 | 85 | 拾取两点指定最大宽度，将超宽单行文字的宽度比例缩小至两点间距的 95% 并保持左侧不动。 | aa:cmd-begin:718, aa:safe-get-bbox:1125, aa:bbox-right-x:1159, aa:bbox-left-x:1155, aa:safe-move-entity:1171, aa:cmd-end:731 |
| `XB` | 5580-5633 | 54 | 将选中的文字或尺寸标注整体缩小为原来的十分之一，并保留选择状态。 | aa:cmd-begin:718, aa:cmd-end:731 |
| `YAN` | 5639-5755 | 117 | 延长竖直直线统一间距，支持分组和上下方向控制。 | aa:insert-sort:778 |
| `LL` | 5766-5795 | 30 | 水平/竖直连续画直线并实时预览，结束恢复正交、捕捉与跟踪设置。 | aa:ortho-restore-vars:6040, aa:undo-mark-off:757, aa:undo-mark-on:749 |
| `LONG` | 5862-5914 | 53 | 连续点选路径各点，过程中红色粗线和大字实时显示路径与长度，空格结束后弹窗并在命令行显示总长度，不保留对象。 | long:del:5848, long:drop-layer:5853, aa:undo-mark-off:757, aa:undo-mark-on:749, long:layer:5801, long:fmt:5814, long:total:5823, long:make-path:5831, long:make-label:5839 |
| `MM` | 6063-6095 | 33 | 水平/竖直移动并实时预览，第二点可捕捉或输入距离，偏斜自动投影。 | aa:ortho-restore-vars:6040, aa:undo-mark-off:757, aa:undo-mark-on:749, aa:ortho-report:6029, aa:ortho-drag:5989 |
| `SS` | 6101-6133 | 33 | 水平/竖直拉伸并实时预览实体变形，第二点可捕捉或输入距离，偏斜自动投影。 | aa:ortho-restore-vars:6040, aa:undo-mark-off:757, aa:undo-mark-on:749, aa:ortho-report:6029, aa:ortho-drag:5989 |
| `SW` | 6222-6277 | 56 | 拉伸对象并记忆方向与距离，支持动态拉伸实时预览，后续可直接回车重复。 | aa:cmd-begin:718, aa:cmd-error:247, aa:ss-format-vec:6141, aa:ss-do-interactive-stretch:6187, aa:cmd-end:731 |
| `SYI` | 6387-6387 | 1 | 预选对象中非竖直对象向上移动 5X，竖直直线向上拉伸 5X；自动补选短斜线左侧与水平线相交的竖直线。 | aa:move-stretch-vertical-cmd:6320 |
| `XYI` | 6388-6388 | 1 | 预选对象中非竖直对象向下移动 5X，竖直直线向下拉伸 5X；自动补选短斜线左侧与水平线相交的竖直线。 | aa:move-stretch-vertical-cmd:6320 |
| `ZYI` | 6519-6519 | 1 | 预选对象中非水平对象向左移动 5X，水平直线向左拉伸 5X；自动补选短斜线处与竖直线相交的水平线。 | aa:move-stretch-horizontal-cmd:6431 |
| `YYI` | 6525-6525 | 1 | 预选对象中非水平对象向右移动 5X，水平直线向右拉伸 5X；自动补选短斜线处与竖直线相交的水平线。 | aa:move-stretch-horizontal-cmd:6431 |
| `SSS` | 6617-6688 | 72 | 交叉框选调整下沿所在行高度，支持小数，默认 10。 | aa:sss-pickfirst-box:6579, aa:sss-lowest-row-line:6605, aa:sss-find-pair:6552, aa:sss-horizontal-segments:6531, aa:cmd-begin:718, aa:cmd-end:731 |
| `SYAN` | 6731-6731 | 1 | 将选中直线向上延长 5 个单位。 | aa:extend-line-cmd:6691 |
| `XYAN` | 6734-6734 | 1 | 将选中直线向下延长 5 个单位。 | aa:extend-line-cmd:6691 |
| `SJ` | 6748-6774 | 27 | 在选中直线顶端生成上接短线。 | aa:cmd-begin:718, aa:cmd-end:731 |
| `XJ` | 6776-6802 | 27 | 在选中直线底端生成下接短线。 | aa:cmd-begin:718, aa:cmd-end:731 |
| `SYJ` | 6845-6845 | 1 | 将选中竖直直线向上延长 5 个单位，再生成上接短线。 | aa:extend-join-cmd:6803 |
| `XYJ` | 6846-6846 | 1 | 将选中竖直直线向下延长 5 个单位，再生成下接短线。 | aa:extend-join-cmd:6803 |
| `GTX` | 6976-7156 | 181 | 按自动容差整理单行/多行电缆文字并自然排序汇总。 | aa:undo-mark-off:757, aa:undo-mark-on:749, aa:gtx-select-prefix-text:6960, aa:ysdl-get-plain-text:1414, aa:try-get-bbox:1114, aa:merge-sort:806, aa:gtx-rows:6919, aa:gtx-key:6888, aa:gtx-find-last-char:6876, aa:gtx-natural-less:6896, aa:gtx-create-text-entity:6936 |
| `GTY` | 7399-7546 | 148 | 保留原文字，按电缆编号排序整理并复制到指定位置。 | aa:gty-delete-copies:7390, aa:gty-get-text-width:7227, aa:gty-separated-rows:7262, aa:gty-add-row:7296, aa:merge-sort:806, aa:gty-get-item-x:7195, aa:gty-order-rows:7346, aa:gty-column-widths:7358, aa:gty-row-tree:7308, aa:gty-build-sort-key:7203, aa:gty-tree-item:7319, aa:gty-copy-text:7370 …共 14 个 |
| `GTY2` | 7691-7735 | 45 | 把选中电缆文字按 GTY 规则排序整理后放进 CAD 剪贴板，到另一张图 Ctrl+V 粘贴；原文字不变。 | aa:cmd-begin:718, aa:gty-delete-copies:7390, aa:cmd-error:247, gty2:locked-layer:7638, gty2:layout:7552, aa:gty-get-item-pt:7194, aa:gty-get-item-ename:7192, gty2:make-copies:7649, gty2:to-clip:7677, aa:cmd-end:731 |
| `GTZ` | 7741-7898 | 158 | 将选中的交替柜名与电缆编号单列文字，按前后柜与编号重组为3列表格输出。 | aa:gty-get-text-width:7227, aa:merge-sort:806, aa:gty-move-entity:7249 |
| `HWD` | 7925-7998 | 74 | 横排交替柜名与电缆编号重组为起点、编号、终点三列，左中对齐、行距5，保留原横排。 | aa:cmd-begin:718, aa:safe-get-bbox:1125, aa:gty-get-text-width:7227, aa:merge-sort:806, aa:hwd-rows:7904, aa:hwd-make-text:7911, aa:cmd-end:731 |
| `BIAN` | 8054-8084 | 31 | 根据选中直线生成方向三角、至字样和电缆规格标注。 | aa:cmd-begin:718, bian-draw-one:8026, aa:cmd-end:731 |
| `LAN` | 8124-8272 | 149 | 竖直线/斜线/水平线联动复制+移动插件。 | aa:cmd-begin:718, lan-vert-mode:8095, lan-get-option:8109, aa:cmd-end:731 |
| `XIN` | 8279-8369 | 91 | 统计选中直线矩形范围内的对象数量并标注结果。 | aa:cmd-begin:718, aa:cmd-end:731 |
| `XY` | 9533-9547 | 15 | 处理所选电缆线（水平线，或绿色竖直线），先运行 XIN 统计芯数，再运行 YUAN 提取原理号；水平线横向输出，竖直线在底端下方输出 270° 文字。 | aa:cmd-begin:718, xy:run-xin:8751, xy:run-yuan:9339, aa:cmd-end:731 |
| `XYG` | 10571-10571 | 1 | 一次框选，自动提取绿色水平/竖直电缆线执行 XY 统计，并提取大字与电缆文字执行 GTX 分类汇总。 | xyg:run:10373 |
| `XYG2` | 10574-10574 | 1 | 与 XYG 相同的框选和汇总表，但原图不留痕：电缆后面不留芯数和原理号，异常电缆线也不改色、不延长。 | xyg:run:10373 |
| `XYG3` | 10577-10577 | 1 | 与 XYG2 一样不留痕，并把 1(2)# 合画电缆拆成各柜两行，汇总表先排完 1# 再排 2#。 | xyg:run:10373 |
| `SX0` | 11027-11066 | 40 | 清除联动标记：框选文字，删除副本的联动标记使其成为普通文字；原件自动跳过。 | aa:cmd-begin:718, aa:link-dwg-id:10637, aa:link-info:10593, aa:link-root-p:10633, aa:cmd-end:731 |
| `YSSX0` | 11073-11113 | 41 | 强制清除联动标记：框选文字，原件和副本的联动标记一并删除，全部成为普通文字。 | aa:cmd-begin:718, aa:link-dwg-id:10637, aa:link-info:10593, aa:link-root-p:10633, aa:cmd-end:731 |
| `SX` | 11138-11176 | 39 | 联动标记：框选原件端子排文字发放唯一编号（UID），草稿/XY/XYG/GTY 副本自动继承。 | aa:cmd-begin:718, aa:link-dwg-id:10637, aa:link-info:10593, aa:link-root-p:10633, aa:link-export-roots:11120, aa:cmd-end:731 |
| `SXC` | 11196-11285 | 90 | 查看联动标记：选文字（回车=本图全部已标记文字），列出是未标记、原件、副本、原件缺失还是他图副本，点结果卡片条目定位；只读。 | aa:cmd-begin:718, aa:rep-begin:21615, aa:link-dwg-id:10637, aa:link-info:10593, aa:rep-item:21626, aa:link-txt:11191, aa:link-root-p:10633, aa:link-root-ed:11520, aa:link-dwg-label:11183, aa:merge-sort:806, aa:rep-info:21632, aa:rep-counts:21681 …共 14 个 |
| `SXD` | 11467-11513 | 47 | 跳到原件：点选文字，缩放到它的原件；原件在其他图纸时按图名找到该图，打开或切换过去；只读。 | aa:link-pick-text:11451, aa:link-info:10593, aa:link-dwg-id:10637, aa:link-root-ed:11520, aa:link-write-jump:11337, aa:link-locate-dwg:11442, aa:link-default-dir:10989, aa:link-dwg-label:11183, aa:link-ask-folder:11012, aa:link-remember-dir:10999, aa:link-send-later:11367 |
| `SX1` | 11539-11613 | 75 | 联动刷新：全图所有同 UID 的副本文字按原件内容单向更新（只同步文字内容），已保存的图同时导出跨图值文件。 | aa:cmd-begin:718, aa:link-clock:11515, aa:link-dwg-id:10637, aa:link-info:10593, aa:link-root-p:10633, aa:link-root-ed:11520, aa:link-split-text:10616, aa:ysdl-get-plain-text:1414, aa:link-text-for:10655, aa:link-file-path:10687, aa:link-export:10726, aa:cmd-end:731 |
| `SX2` | 11621-11701 | 81 | 跨图联动刷新：读取指定文件夹内各卷册图的 .aalink.txt 值文件，更新本图中原件在其他图纸的副本文字。 | aa:cmd-begin:718, aa:link-dwg-id:10637, aa:link-info:10593, aa:link-ask-folder:11012, aa:link-near-dir:11004, aa:link-collect-files:10923, aa:link-remember-dir:10999, aa:merge-sort:806, aa:link-file-time:10914, aa:link-filter-values:10876, aa:link-read-file:10771, aa:link-uid<:10677 …共 17 个 |
| `HBDL` | 12008-12113 | 106 | 框选电缆清册表格文字，自动将带有“并入”前缀的行合并到对应的目标电缆主行中，自动累加芯数并在末尾追加原理号，其他行保持原位。 | aa:cmd-begin:718, aa:cmd-end:731, aa:ysdl-get-plain-text:1414, hb:cluster-rows:11778, hb:parse-row:11807, hb:apply-merge-in-place:11923 |
| `NU` | 12409-12460 | 52 | 材料表数字加数字：优先改井号相邻数字，其次改最后一个减号后的连续整数，都没有时改第一个数字（支持小数和正负号）。 | aa:nu-rewrite-text:12358, aa:num-int-target-p:12339 |
| `KAI` | 12651-12734 | 84 | 将 TEXT/MTEXT 中由空格分隔的内容拆分为多个独立文字。 | aa:kai-add-texts-after-explode:12590, aa:kai-process-text:12608 |
| `ZHENG` | 12805-12935 | 131 | 以水平直线或矩形中心为基准整理文字的水平位置。 | aa:zheng-horizontal-line-p:12743, aa:safe-get-bbox:1125, aa:zheng-align-text-to-rect-center:12792, aa:zheng-line-mid-x:12758, aa:zheng-add-texts-after-explode:12765, aa:zheng-align-text-center-x:12783 |
| `AAE` | 13352-13437 | 86 | 选择块内属性文字，在自定义窗口中编辑并按回车直接保存。 | aa:cmd-begin:718, aae:split-lines:13306, aae:locate-dcl:13439, aae:resolve-val:13335, aa:cmd-end:731 |
| `HAO` | 13456-13460 | 5 | 选中图框后批量填写页码和档案号。 | aa:cmd-begin:718, fillframes-run:13160, aa:cmd-end:731 |
| `HAO2` | 13702-13859 | 158 | 指定基准块参照与图号矩形范围，批量居中填充或更新递增图号文字。 | aa:cmd-begin:718, blk-insertpt:12981, hao2:block-name:13473, hao2:sort-blocks:13487, zdml2:collect-all-texts:13535, hao2:format-num:13466, hao2:find-existing-text-fast:13669, tktj:current-space:18880, tktj:ensure-text-style:18890, aa:cmd-end:731 |
| `MING` | 14004-14168 | 165 | 按行列网格顺序，批量将单行文字填充到对应属性块的图名属性中。 | aa:cmd-begin:718, ming:find-title-attrib:13868, blk-insertpt:12981, ming:get-block-height:13905, ming:get-text-info:13921, ming:cluster-and-sort:13953, aa:cmd-end:731 |
| `FIVE` | 14177-14218 | 42 | 将测得高度按比例缩放为 5。 | aa:cmd-begin:718, aa:cmd-end:731 |
| `JZ` | 14238-14380 | 143 | 将矩形水平中线对齐到1条或2条直线中心线，可同步居中文字。 | aa:safe-get-bbox:1125, aa:jz-line-center-y:14226, aa:bbox-center-x:1149, aa:bbox-top-y:1163, aa:bbox-bottom-y:1167, aa:safe-move-entity:1171 |
| `FKX` | 14550-14621 | 72 | 单击框内空白处选择正文对象，自动排除图框和右下角标题栏；支持手动指定范围。 | aa:cmd-begin:718, fdx:poly-rect:14410, fdx:add-rect:14624, fkx:choose-frame:14445, fdx:rect-from-points:14388, fkx:collect:14482, fkx:title-rect:14512, fkx:point-in-p:14436, fkx:filter:14539, aa:cmd-end:731 |
| `FDX` | 14804-14842 | 39 | 先选方框，按从上到下、每行从左到右分配；每批文字按空格移动并按 DX 规则排列。 | fdx:restore:14700, aa:undo-mark-off:757, fdx:frames:14662, fdx:sort-frames:14681, fdx:show-frame:14693, aa:undo-mark-on:749, fdx:place:14728 |
| `DX` | 15053-15122 | 70 | 批量整理 100×100 方格内的端子号、原理号和终点柜文字，并将整组文字居中。 | aa:undo-mark-off:757, aa:zz-filter-text-ss:15342, aa:zz-harvest-lines:15610, aa:zz-build-spatial-index:15635, aa:zz-text-info:15701, aa:zz-group-by-rect:15752, aa:undo-mark-on:749, dx:apply-group:14964 |
| `DX2` | 15266-15325 | 60 | 按方格从左到右、从上到下导出文字，每个方格一行，框内按行排序并用顿号连接，复制到剪贴板。 | aa:cmd-begin:718, aa:zz-filter-text-ss:15342, aa:zz-harvest-lines:15610, aa:zz-build-spatial-index:15635, aa:zz-text-info:15701, aa:zz-group-by-rect:15752, dx2:sort-groups:15163, dx2:export-group:15251, zi:to-clip:17544, aa:cmd-end:731 |
| `ZZ` | 15902-15904 | 3 | 先将文字改为中下对正，再居中到最近矩形；多行文字按 5 个单位的中心间距排列。 | aa:zz-run:15846 |
| `ZZ2` | 16025-16121 | 97 | 按 ZZ 居中，恰好双文字单元格所在行调为10，下方内容顺延。 | aa:zz2-poly-ok:16012, aa:safe-get-bbox:1125, aa:zz2-frame:15992, aa:zz-build-spatial-index:15635, aa:zz-text-info:15701, aa:zz-group-by-rect:15752, aa:zz2-plan:15907, aa:zz2-plan-ok:15916, aa:cmd-begin:718, aa:zz2-map-edge:15947, aa:bbox-top-y:1163, aa:bbox-bottom-y:1167 …共 16 个 |
| `JACC` | 16124-16126 | 3 | ZZ 的同功能入口。 | aa:zz-run:15846 |
| `MJ` | 16269-16356 | 88 | 框选单列表格后，按最长文字自动收窄宽度并将各行文字居中。 | aa:mj-frame-bounds:16129, aa:mj-collect-text-data:16148, aa:mj-horizontal-ys:16176, aa:mj-scale-line-x:16249, aa:mj-move-cached-texts:16259 |
| `FIVE2` | 16420-16527 | 108 | 同一列相接的直线表格统一行高5，保留顶边、列宽、字高和圆形符号大小。 | aa:try-get-bbox:1114, aa:tbhb-segment:16532, aa:tbhb-merge-segments:16550, aa:hg5-rows:16362, aa:tbhb-border-p:16542, aa:hg5-side-p:16389, aa:hg5-text-y:16411, aa:cmd-begin:718, aa:hg5-point:16407, aa:hg5-y:16374, aa:cmd-end:731 |
| `HBBG` | 16727-16815 | 89 | 将完整直线表格按图纸位置从上到下复制拼接，保留原表及各段标题和列顺序。 | aa:undo-mark-off:757, aa:tbhb-collect:16679, aa:tbhb-boxes:16571, aa:tbhb-groups:16644, aa:tbhb-group-problem:16619, aa:merge-sort:806, aa:tbhb-before-p:16591, aa:tbhb-item-inside-p:16603, aa:undo-mark-on:749, aa:tbhb-offset:16655, aa:tbhb-shift-point:16661, aa:tbhb-seen-line-p:16665 …共 14 个 |
| `HZBG` | 16883-16947 | 65 | 选中文字生成表格，行高 5，按最宽文字自动列宽，左右各留 3。 | aa:safe-get-bbox:1125, aa:hzbg-plan:16832, aa:cmd-begin:718, aa:hzbg-move:16862, aa:hzbg-line:16875, aa:cmd-end:731 |
| `ZDWI` | 17217-17334 | 118 | 按各列最宽文字自动放宽或缩窄表格列宽，文字左右各留 3 个图纸单位，并按 ZZ 居中。 | aa:zdwi-expand-selection:17030, aa:zdwi-table-groups:17090, aa:zdwi-vertices:17153, aa:zdwi-unique:17136, aa:zdwi-add-span:17141, aa:merge-sort:806, aa:safe-get-bbox:1125, aa:zdwi-column:17166, aa:zdwi-set-nth:17175, aa:cmd-begin:718, aa:zdwi-map-entity:17192, aa:zz-move-text:15720 …共 14 个 |
| `FF` | 17459-17500 | 42 | 预选文字，空格确认查找及替换内容，批量替换所有匹配片段。 | aa:cmd-begin:718, aa:ysdl-get-raw-text:1329, aa:str-replace-all:1306, aa:ff-text-data:17440, aa:cmd-end:731 |
| `DB` | 17503-17507 | 5 | 删除每个选中文字末尾的 N 个字符。 | aa:cmd-begin:718, db:del:17370, aa:cmd-end:731 |
| `DF` | 17509-17513 | 5 | 删除每个选中文字开头的 N 个字符。 | aa:cmd-begin:718, db:del:17370, aa:cmd-end:731 |
| `AB` | 17515-17519 | 5 | 在每个选中文字末尾增加文字（空输入使用剪贴板）。 | aa:cmd-begin:718, db:add:17403, aa:cmd-end:731 |
| `AF` | 17521-17525 | 5 | 在每个选中文字开头增加文字（空输入使用剪贴板）。 | aa:cmd-begin:718, db:add:17403, aa:cmd-end:731 |
| `QE` | 17593-17674 | 82 | 用 Windows 剪贴板中的文字批量替换选中文字；文字含“至”字时只替换“至”后的部分。 | qe:get-clip-text:17562, qe:zhi-prefix:17583 |
| `CC` | 17677-17751 | 75 | 读取 Windows 剪贴板，连续复制并替换副本文字，使用原生拖动预览和对象捕捉。 | aa:cmd-begin:718, aa:cmd-error:247, qe:get-clip-text:17562, aa:cmd-end:731 |
| `QW` | 17820-17856 | 37 | 提取选中文字，同一行用顿号连接，不同行之间也用顿号分隔，并复制到剪贴板。 | aa:cmd-begin:718, aa:ysdl-get-plain-text:1414, zi:pt:17539, qw:join:17755, zi:to-clip:17544, aa:cmd-end:731 |
| `QW2` | 17862-17923 | 62 | 提取选中文字及坐标，每项一行“x,y 文字”，坐标保留 2 位小数，复制到剪贴板。 | aa:cmd-begin:718, aa:ysdl-get-plain-text:1414, zi:pt:17539, aa:merge-sort:806, zi:to-clip:17544, aa:cmd-end:731 |
| `QW2P` | 18029-18072 | 44 | 把剪贴板里“x,y 文字”格式的内容按 T 命令的样式写到当前图层，与 QW2 相反。 | aa:cmd-begin:718, qw2p:read-clip-file:17988, qe:get-clip-text:17562, qw2p:parse-clip:17971, qw2p:text-data:18017, aa:cmd-end:731 |
| `QW3` | 18296-18334 | 39 | 导出选中对象的类型、图层、坐标、几何及文字属性为结构化文本并复制到剪贴板。 | aa:cmd-begin:718, aa:qw3-record:18269, aa:merge-sort:806, zi:to-clip:17544, aa:cmd-end:731 |
| `TJK` | 18423-18473 | 51 | 点选块，统计当前空间或框选范围内同名块（含动态块）的数量，选中它们并用红圈和序号标出；Q 清除标记。 | aa:cmd-begin:718, tjk:clear-marks:18339, aa:cmd-end:731, hao2:block-name:13473, tjk:select:18369, tjk:items:18381, tjk:ensure-layer:18349, tjk:draw:18398 |
| `DX1` | 18478-18548 | 71 | 提取选中文字及坐标，青色文字额外标注“端子名”，复制到剪贴板。 | aa:cmd-begin:718, zi:pt:17539, dx:color-kind:14869, aa:merge-sort:806, zi:to-clip:17544, aa:cmd-end:731 |
| `CE` | 18579-18609 | 31 | 测量点序列形成的多段线总长度。 | aa:cmd-begin:718, ce-redraw:18563, aa:cmd-end:731 |
| `AW` | 18796-18838 | 43 | 自动微移选中文字，尽量避开旁边线段、文字和其他对象重叠。 | aw:get-selection:18788, aw:process-one:18762 |
| `ZDML` | 19204-19282 | 79 | 选择多个图框块，生成目录文字。 | aa:cmd-begin:718, tktj:safe-vla-object:18906, tktj:collect-one-block:19030, tktj:sort-by-page:19147, tktj:sort-by-position:19158, tktj:take:19102, tktj:draw-table:19119, tktj:drop:19111, aa:cmd-end:731 |
| `ZDML2` | 19346-19517 | 172 | 指定基准块参照与图名、图号矩形范围，批量提取图名图号并生成目录。 | aa:cmd-begin:718, blk-insertpt:12981, hao2:block-name:13473, hao2:sort-blocks:13487, zdml2:collect-all-texts:13535, zdml2:build-spatial-index:13583, zdml2:extract-rect-text-fast:19288, zdml2:query-rect-index:13636, tktj:take:19102, tktj:draw-table:19119, tktj:drop:19111, aa:cmd-end:731 |
| `ZDMLDEBUG` | 19520-19554 | 35 | 选择一个图框块，打印所有增强属性。 | aa:cmd-begin:718, tktj:get-attributes:18979, aa:cmd-end:731 |
| `DUMP` | 19558-19582 | 25 | 打印选中图元的 ActiveX 属性与可用方法（调试辅助）。 | aa:cmd-begin:718, aa:cmd-end:731 |
| `C1` | 19850-19852 | 3 | 复制文字（可多选，各自变化）并把编号加 1（优先井号相邻数字，其次减号后数字），使用原生拖动预览和捕捉连续放置。 | c1c2:run:19779 |
| `C2` | 19854-19856 | 3 | 复制文字（可多选，各自变化）并把编号减 1（优先井号相邻数字，其次减号后数字），使用原生拖动预览和捕捉连续放置。 | c1c2:run:19779 |
| `C3` | 19858-19860 | 3 | 复制文字（可多选，各自变化）并把编号每次加 2（优先井号相邻数字，其次减号后数字），使用原生拖动预览和捕捉连续放置。 | c1c2:run:19779 |
| `DE` | 20207-20207 | 1 | 删除选中文字的最右侧括号及括号内容。 | de:run:20161 |
| `DE2` | 20208-20208 | 1 | 用最右侧括号内容替换括号前同样位数的数字（数字带相同尾缀时一并替换，A63(4)0I → A640I）。 | de:run:20161 |
| `GE` | 20295-20397 | 103 | 选中同一水平行的单行文字，按文字间隙绘制单行表格。 | ge:end-undo:20219, ge:get-item:20233, ge:sort-items:20270, ge:make-line:20277 |
| `UT` | 20508-20620 | 113 | 先将文字统一为左中对正，再按最上方一对的位置整理文字；支持直线及按首尾端点计算的未闭合多段线，保留宽度。 | aa:undo-mark-off:757, ut:horizontal-line-p:20425, ut:get-bbox:20447, ut:line-y:20440, ut:sort-desc:20484, aa:undo-mark-on:749, aa:normalize-text-horizontal-align:4037, ut:bbox-bottom:20464, ut:bbox-left:20460, ut:move:20492 |
| `0` | 20631-20665 | 35 | 将所选对象中的文字旋转角度统一改为 0 度。 | aa:cmd-begin:718, aa:cmd-end:731 |
| `9` | 20714-20723 | 10 | 以所选对象整体包围框中心为基点，整体顺时针旋转 90 度。 | aa:cmd-begin:718, aa:rotate-90-run:20672, aa:cmd-end:731 |
| `99` | 20726-20735 | 10 | 以所选对象整体包围框中心为基点，整体逆时针旋转 90 度。 | aa:cmd-begin:718, aa:rotate-90-run:20672, aa:cmd-end:731 |
| `QZ` | 20742-20790 | 49 | 取消当前图纸中的全部分组，组内图元保持不变。 |  |
| `DL1` | 20818-20835 | 18 | 创建电缆柜、电缆路径、电缆竖井相关的 1F / 2F 图层。 | aa:cmd-begin:718, dl1:make-layer:20802, aa:cmd-end:731 |
| `REP` | 20859-20953 | 95 | 将选中的柜名文字按内置映射表替换为标准柜名。 | aa:cmd-begin:718, rep-trim:20849, aa:cmd-end:731 |
| `KMZ` | 21246-21248 | 3 | 选中两条水平线后向左生成短线、矩形并居中标注+KM、-KM及直流馈线柜（青色虚线）。 | aa:km-ln-cmd:21038 |
| `KMY` | 21252-21254 | 3 | 选中两条水平线后向右生成短线、矩形并居中标注+KM、-KM及直流馈线柜（青色虚线）。 | aa:km-ln-cmd:21038 |
| `LNZ` | 21258-21260 | 3 | 选中两条水平线后向左生成短线、矩形并居中标注L、N及相邻屏柜（青色虚线）。 | aa:km-ln-cmd:21038 |
| `LNY` | 21264-21266 | 3 | 选中两条水平线后向右生成短线、矩形并居中标注L、N及相邻屏柜（青色虚线）。 | aa:km-ln-cmd:21038 |
| `UPSZ` | 21270-21272 | 3 | 选中两条水平线后向左生成短线、矩形并居中标注L、N及UPS电源柜（青色虚线）。 | aa:km-ln-cmd:21038 |
| `UPSY` | 21276-21278 | 3 | 选中两条水平线后向右生成短线、矩形并居中标注L、N及UPS电源柜（青色虚线）。 | aa:km-ln-cmd:21038 |
| `BZ` | 21282-21284 | 3 | 选中两条水平线后向左生成短线、矩形并居中标注B+、B-及同步时钟主机柜（青色虚线）。 | aa:km-ln-cmd:21038 |
| `BY` | 21288-21290 | 3 | 选中两条水平线后向右生成短线、矩形并居中标注B+、B-及同步时钟主机柜（青色虚线）。 | aa:km-ln-cmd:21038 |
| `ZJ` | 21322-21324 | 3 | 选中多条水平线后向左生成短线、矩形；原理号标注不变，柜内文字默认读取剪贴板，可手动输入（青色虚线）。 | aa:zj-cmd:21297 |
| `YJ` | 21328-21330 | 3 | 选中多条水平线后向右生成短线、矩形；原理号标注不变，柜内文字默认读取剪贴板，可手动输入（青色虚线）。 | aa:zj-cmd:21297 |
| `YDZ` | 21532-21534 | 3 | 选中多条水平线后向左生成短线、矩形并从上往下标注701、-901、-903...及公用测控柜（青色虚线）。 | aa:yd-cmd:21338 |
| `YDY` | 21538-21540 | 3 | 选中多条水平线后向右生成短线、矩形并从上往下标注701、-901、-903...及公用测控柜（青色虚线）。 | aa:yd-cmd:21338 |
| `LBZ` | 21544-21546 | 3 | 选中多条水平线后向左生成短线、矩形并从上往下标注500、-501、-503...及故障录波柜（青色虚线）。 | aa:yd-cmd:21338 |
| `LBY` | 21550-21552 | 3 | 选中多条水平线后向右生成短线、矩形并从上往下标注500、-501、-503...及故障录波柜（青色虚线）。 | aa:yd-cmd:21338 |
| `485Z` | 21556-21558 | 3 | 选中至少两条水平线后向左生成短线、矩形并居中标注485+、485-及网络通信柜（青色虚线）。 | aa:km-ln-cmd:21038 |
| `485Y` | 21562-21564 | 3 | 选中至少两条水平线后向右生成短线、矩形并居中标注485+、485-及网络通信柜（青色虚线）。 | aa:km-ln-cmd:21038 |
| `XX` | 21575-21603 | 29 | 将选中文字内容替换为 7×2.5。 | aa:cmd-begin:718, aa:cmd-end:731 |
| `JM` | 21982-22057 | 76 | 按绿色电缆线（水平或竖直）所连原理号，把 ZDDLH/ZDDLS 生成的“未填写”替换为电缆截面；无法判断的保留并选中提示。 | aa:cmd-begin:718, aa:rep-begin:21615, xyg:dedup-hlines:9815, xy:ss->list:8417, xy:filter-green-hlines:9507, xy:collect-vlines:8698, xy:build-vline-buckets:8626, xy:build-text-meta-list:8958, xy:collect-texts:8723, xy:hline-info-ed:8513, jm:find-spec-text:21944, aa:ysdl-get-plain-text:1414 …共 24 个 |
| `HDDZ` | 22556-22567 | 12 | 先选原理图剔出的端子与原理号，再选端子图，按“端子名:端子号”核对两边原理号是否一致，问题写结果卡片、标红并选中。 | aa:cmd-begin:718, hddz:work:22545, aa:cmd-end:731 |
| `BH2` | 23577-23752 | 176 | 框选起点柜和绿色电缆线，把已编号但没记录的电缆记入共享记录，给有记录的“未编号”按记录填写；不分配新编号，两端不一致的标红注明原因。 | aa:cmd-begin:718, aa:rep-begin:21615, aa:link-clock:11515, bh:prepare:22971, bh:record-path:22683, bh:now:22687, bh:fold-joins:22923, bh:read-records:22714, bh:rec-key:22622, bh:kmap:22633, bh:nmap:22646, bh:split-map:23562 …共 34 个 |
| `BHG` | 23755-23870 | 116 | 以图为准修改电缆编号记录：记录编号改成图上的编号，原编号存为旧编号供另一端 BH1/BH2 自动跟改；“未编号”的删除其记录。 | aa:cmd-begin:718, aa:rep-begin:21615, aa:link-clock:11515, bh:prepare:22971, bh:record-path:22683, bh:now:22687, bh:fold-joins:22923, bh:read-records:22714, bh:rec-key:22622, bh:kmap:22633, bh:nmap:22646, bh:clean:22602 …共 26 个 |
| `BH1` | 24183-24394 | 212 | 逐根点选编号：先点起点柜名大字并输入前缀、起始号，再依次点绿色电缆线，回车后自动缩放一次识别并按点选顺序编号，同终点加 A/B/C，可撤销本批。 | aa:cmd-begin:718, bh:pick-start:24078, bh:ask-prefix:23051, bh:ask-start:23061, bh:record-path:22683, bh:fold-joins:22923, bh:read-records:22714, bh:rec-key:22622, bh:kmap:22633, bh:nmap:22646, bh:own-records:24035, bh:write-records:22734 …共 42 个 |
| `BH3` | 24473-24649 | 177 | 框选电缆清册文字（起点柜/编号/终点柜/规格/芯数/原理号），以清册为准写入共享记录：没有的记入，有的强制改成清册编号（同 BHG）。 | aa:cmd-begin:718, aa:rep-begin:21615, hddl:text:25069, hddl:point:25087, aa:merge-sort:806, hddl:sort-rows:25151, hddl:rows:25141, hddl:coord:25081, bh:record-path:22683, bh:now:22687, bh:fold-joins:22923, bh:read-records:22714 …共 32 个 |
| `ZDAO` | 24769-24773 | 5 | 将选中文字按垂直位置上下颠倒排列（最下面的文字放到最上面，原 DAO）。 | aa:cmd-begin:718, dao:run:24707, aa:cmd-end:731 |
| `HDAO` | 24776-24780 | 5 | 将选中文字按水平位置左右颠倒排列（最左边的文字放到最右边）。 | aa:cmd-begin:718, dao:run:24707, aa:cmd-end:731 |
| `QH` | 24785-24936 | 152 | 只选中已选文字所在行、且位于当前屏幕内、参考文字左右各 1000 内的所有文字（跨多行时逐行选择）。 | aa:merge-sort:806 |
| `BK` | 24966-25009 | 44 | 选中文字后只保留最后一对括号内的内容，括号外有“至”时保留“至”。 | de:end-undo:20144, de:get-text:20128, bk:extract-inner:24947, de:set-text:20137 |
| `HDDL` | 25297-25387 | 91 | 直接校核选中文字中的电缆编号、规格和原理号，问题行标红并在行首标注。 | aa:undo-mark-off:757, aa:undo-mark-on:749, hddl:ensure-layer:25018, hddl:clear-markers:25058, hddl:text:25069, hddl:point:25087, hddl:sort-rows:25151, hddl:rows:25141, hddl:group-rows:25156, hddl:mirror-p:25291, hddl:cell:25201, hddl:tail-count:25207 …共 20 个 |
| `CU` | 25461-25462 | 2 | 将选中对象按 5 个单位的递增间距向上复制指定份数。 | cu:copy-direction:25393 |
| `CD` | 25465-25466 | 2 | 将选中对象按 5 个单位的递增间距向下复制指定份数。 | cu:copy-direction:25393 |
| `CZ` | 25469-25470 | 2 | 将选中对象按 5 个单位的递增间距向左复制指定份数。 | cu:copy-direction:25393 |
| `CY` | 25473-25474 | 2 | 将选中对象按 5 个单位的递增间距向右复制指定份数。 | cu:copy-direction:25393 |
| `HS` | 25527-25699 | 173 | 选中物体单向横向缩放，左右宽度改变，高度保持不变。 | aa:cmd-begin:718, aa:hs-filter-unlocked:25481, aa:cmd-end:731, aa:hs-get-ss-bbox:25501 |
| `ZS` | 25708-25880 | 173 | 选中物体单向纵向缩放，上下高度改变，宽度保持不变。 | aa:cmd-begin:718, aa:hs-filter-unlocked:25481, aa:cmd-end:731, aa:hs-get-ss-bbox:25501 |
| `SC3` | 25912-25979 | 68 | 将选中对象整体等比例缩小，使四周距 A3 外框至少 5mm。 | aa:cmd-begin:718, aa:sc3-layer-locked-p:25886, aa:sc3-entity-bbox:25894, aa:cmd-end:731 |
| `Z0` | 26046-26089 | 44 | 将选中对象的 Z 坐标全部归零（压平到 XY 平面）。 | aa:cmd-begin:718, aa:z0-layer-locked-p:25985, aa:z0-data-flat-p:26003, aa:z0-polyline-flat-p:26036, aa:z0-one:26016, aa:z0-polyline-verts:26028, aa:cmd-end:731 |
| `VPO1` | 26095-26100 | 6 | 切换到“单个”标准视口。 | aa:cmd-begin:718, aa:cmd-end:731 |
| `VPO2` | 26103-26108 | 6 | 切换到“两个：垂直”标准视口。 | aa:cmd-begin:718, aa:cmd-end:731 |
| `TONG` | 26114-26198 | 85 | 框选文字对象去重，按自然顺序从上到下排列在指定插入点（HZ样式/字高3/宽比0.7/白色/间距5）。 | aa:cmd-begin:718, aa:cmd-end:731, aa:merge-sort:806, aa:gtx-natural-less:6896 |
| `ZDDL2` | 26859-26950 | 92 | 自动根据现有端子排与接线方格绘制电缆引线、干线与标注。 | aa:cmd-begin:718, aa:cmd-end:731, zddl:parse-strip:26390, zddl:parse-wiring-ss:26611, zddl:ensure-layer:26671, zddl:plan-cables:26748, zddl:lookup-terminal:26299, zddl:label-layout:26773, zddl:draw-one-cable:26780, zddl:format-cable-no:26738 |
| `ZDC` | 26952-26954 | 3 | ZDDLH 命令的简写别名。 | c:zddlh:29312 |
| `ZDDLD` | 28044-28072 | 29 | 删除 ZDDL 生成的端子排框线与端子名/号，保留原理号、电缆接线和电缆文字。 | aa:cmd-begin:718, zddl2:xdata-app:28027, aa:layer-locked-p:5223, zddl2:set-layer-lock:28030, aa:cmd-end:731 |
| `XZYL` | 29278-29284 | 7 | 修正原理号：先点原理号正确的电缆录入，再运行点对面一端的同一根电缆，替换不一致的原理号并补填未编号；合画图录入按 1#/2# 拆开；可先选电缆线再运行。 | aa:cmd-begin:718, zyl:work:29246, aa:cmd-end:731 |
| `BDL` | 29290-29296 | 7 | 选择后补的原理号，按 ZDDL 样式补画引线、短斜线、电缆线、箭头和占位文字，自动找空行；选水平原理号时按竖排端子排补画竖直电缆线。 | aa:cmd-begin:718, bdl:work:28690, aa:cmd-end:731 |
| `BDL2` | 29299-29306 | 8 | 连续补画多根电缆：逐根选原理号按空格记住，不选直接空格后一次生成（同 BDL），生成前可先调整窗口，一次 U 全部撤销。 | aa:cmd-begin:718, bdl:work-multi:28706, bdl:hilite:28698, aa:cmd-end:731 |
| `ZDDLH` | 29312-29319 | 8 | 两次选择文字并指定左下基点，生成横排端子排与水平绿色电缆线（原 ZDDL）。 | aa:cmd-begin:718, zddl2:work:27941, aa:cmd-end:731 |
| `ZDDLS` | 29325-29332 | 8 | 两次选择文字并指定左上基点，生成竖排端子排、水平引线与竖直绿色电缆线（向下箭头、文字 270°）。 | aa:cmd-begin:718, zddl2:work:27941, aa:cmd-end:731 |

## 辅助函数分组（按前缀）

| 前缀 | 函数数 | 行号分布 | 使用这些函数的命令 |
|------|------|------|------|
| `aa:` | 342 | 247-344, 398-521, 718-830, 1092-1891, 2537-2573, 3307-3368 … | 0, 485Y, 485Z, 9, 99, A2T, AAE, AB, ABCN, AF, ASHANG, ATW, AXIA, AYOU, AZUO …共 177 个 |
| `des:` | 5 | 553-581 | DES |
| `ystemp:` | 2 | 652-659 | YSTEMP |
| `ztf:` | 14 | 832-1075 | ZTF |
| `txt:` | 7 | 1946-2148 | T, T2 |
| `zhu:` | 5 | 2165-2206 | ZHU |
| `hwt:` | 14 | 2260-2473 | HWT |
| `txt2:` | 5 | 2575-2719 | DH, T2 |
| `song:` | 1 | 2731-2734 | SONG |
| `dh:` | 10 | 2766-2966 | DH |
| `qr:` | 3 | 5056-5078 | QR, QR2 |
| `det:` | 1 | 5300-5318 | DET |
| `a2t:` | 3 | 5373-5398 | A2T |
| `long:` | 8 | 5801-5859 | LONG |
| `gty2:` | 4 | 7552-7689 | GTY2 |
| `(无前缀):` | 22 | 8000-8052, 8095-8122, 12957-13228, 18563-18576, 20849-20857 | BIAN, CE, HAO, HAO2, LAN, MING, REP, ZDML2 |
| `xy:` | 47 | 8404-9528 | BH1, BH2, BHG, JM, XY, XYG, XYG2, XYG3, XZYL |
| `xyg:` | 32 | 9554-10568 | BH1, BH2, BHG, DE, DE2, JM, SX1, SX2, XYG, XYG2, XYG3 |
| `hb:` | 9 | 11709-12006 | HBDL |
| `aae:` | 4 | 13231-13350, 13439-13454 | AAE, HAO2, MING, ZDC, ZDDLH, ZDDLS, ZDML, ZDML2, ZDMLDEBUG |
| `hao2:` | 4 | 13466-13533, 13669-13700 | HAO2, TJK, ZDML2 |
| `zdml2:` | 4 | 13535-13666, 19288-19344 | HAO2, ZDML2 |
| `ming:` | 4 | 13868-14002 | MING |
| `fdx:` | 11 | 14388-14430, 14624-14802 | FDX, FKX |
| `fkx:` | 10 | 14436-14546 | FKX |
| `dx:` | 12 | 14845-15051 | DX, DX1, DX2, FDX, HDDZ, ZDC, ZDDL2, ZDDLH, ZDDLS |
| `dx2:` | 12 | 15129-15264 | DX2, ZDC, ZDDL2, ZDDLH, ZDDLS |
| `db:` | 5 | 17350-17437 | AB, AF, DB, DF |
| `zi:` | 2 | 17539-17559 | DX1, DX2, QW, QW2, QW3 |
| `qe:` | 2 | 17562-17590 | AB, AF, CC, QE, QW2P, YJ, ZJ |
| `qw:` | 1 | 17755-17816 | QW |
| `qw2p:` | 6 | 17926-18026 | QW2P |
| `tjk:` | 6 | 18339-18420 | TJK |
| `aw:` | 17 | 18624-18794 | AW, XZYL |
| `tktj:` | 24 | 18868-19201 | HAO2, MING, ZDML, ZDML2, ZDMLDEBUG |
| `c1c2:` | 15 | 19602-19848 | C1, C2, C3 |
| `de:` | 21 | 19881-20205 | BK, DE, DE2, SX1, SX2, XYG, XYG2, XYG3 |
| `ge:` | 6 | 20219-20293 | GE |
| `ut:` | 10 | 20404-20506 | UT |
| `dl1:` | 1 | 20802-20816 | DL1 |
| `jm:` | 20 | 21734-21979 | BDL, BDL2, BH1, BH2, BH3, BHG, JM, XZYL |
| `hddz:` | 39 | 22075-22553 | HDDZ |
| `bh:` | 101 | 22594-23574, 23875-24180, 24395-24470 | BDL, BDL2, BH1, BH2, BH3, BHG, DE, DE2, JM, SX1, SX2, XYG, XYG2, XYG3, XZYL |
| `dao:` | 4 | 24659-24766 | HDAO, ZDAO |
| `bk:` | 1 | 24947-24964 | BK |
| `hddl:` | 29 | 25018-25295 | BH1, BH2, BH3, BHG, HDDL, XZYL, YSDL, YSDL2 |
| `cu:` | 1 | 25393-25458 | CD, CU, CY, CZ |
| `zddl:` | 27 | 26207-26857 | BDL, BDL2, ZDC, ZDDL2, ZDDLH, ZDDLS |
| `zddl2:` | 96 | 26962-28038 | BDL, BDL2, YSDL, YSDL2, ZDC, ZDDLD, ZDDLH, ZDDLS |
| `bdl:` | 39 | 28079-28884 | BDL, BDL2, XZYL |
| `zyl:` | 31 | 28893-29272 | XZYL |
