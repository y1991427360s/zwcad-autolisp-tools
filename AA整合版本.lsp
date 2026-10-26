;;; =... ... ... ... ... ... ... ... ... ... ... ... ... ... ... ... ... ... ... ... ... ... ...
;;;
;;;                   ZWCAD 多功能集成插件 (Integrated Plugins)
;;;
;;; =======================================================================================
;;;
;;; 版本: 1.4
;;; 修正日期: 2026-09-11
;;; 描述: 本文件整合了多个常用的AutoLISP插件，方便统一加载和管理。
;;;       作者：YS
;;;
;;; 包含以下命令:
;;;
;;;   - YSDL  : 提取选中文字到CSV文件，并改变文字颜色。
;;;   - HDDL  : 直接校核选中文字中的电缆编号、规格和原理号，问题行标红并在行首标注。
;;;   - Q : 快速从当前选择中仅选中所有文字对象。
;;;   - FKX   : 单击框内空白处选择正文对象，自动排除图框和右下角标题栏；支持手动指定范围。
;;;   - T     : 把文字及ATTDEF属性定义刷为HZ样式，高度3，宽度0.7；按可见范围保持对齐文字位置。
;;;   - T2    : 将文字刷为HZ/0.7样式并字高优先避让周围线框，优先3.0字高微移，避免文字缩小。
;;;   - ZHU   : 选中端子排名和端子号文字，选短接或拆除连片，生成HZ/3/0.7的“注：”单行文字。
;;;   - HWT   : 框选一列柜名文字，按从上到下顺序每行最多5个蛇形排列，生成L1/N1端子、SML电缆编号和两端JL进线的环网图，并输出可供BH3登记的电缆清单。
;;;   - ABCN  : 指定一点生成青色 A、B、C、N 单行文字，HZ/3/0.7、左中对正、按 H 默认间距5向下排列。
;;;   - H     : 先将选中文字统一为左中对正，再按指定间距（插入点/对齐点之间）从上到下排列。
;;;   - H2    : 先将选中文字统一为左中对正，右侧文字在最上、越靠左越靠下，按指定间距从上到下排列。
;;;   - Y     : 将选中对象的颜色快速变为青色。
;;;   - DZ    : 将所选其他文字改为Y命令的青色，保留纯数字及数字后接单个小写a的文字原色。
;;;   - YY    : 将选中对象快速改为黄色。
;;;   - RR    : 将选中对象快速改为红色。
;;;   - WW    : 将选中对象快速改为白色。
;;;   - WWW   : 将选中对象强制改为白色；尺寸标注全要素变白，引线先分解再变白，块参照连块内实体一起改。
;;;   - GG    : 将选中对象快速改为绿色。
;;;   - PP    : 将选中对象快速改为洋红色。
;;;   - HH    : 将选中对象快速改为颜色 8（与 HUI 同色）。
;;;   - HUI   : 将选中对象强制改为颜色 8；尺寸标注全要素改色，引线先分解再改色，块参照连块内实体一起改。
;;;   - ZHONG : 文字居中对齐；选择直线/矩形时按中心 X 居中。
;;;   - ZHENG : 以水平直线或矩形中心为基准整理文字的水平位置。
;;;   - ZUO   : 将选中文字统一为左中对正，并以最左侧文字为基准左对齐。
;;;   - AZUO  : 选择一条竖直直线作为基准线，框选其他所有对象作为一个整体整体移动并左对齐到该直线。
;;;   - HP    : 将选中文字按从左到右排列，使相邻文字首尾间距为指定值，并按最左文字上边对齐。
;;;   - HP2   : 将选中文字改为正中对齐，按中心点指定间距从左到右横向排列。
;;;   - YOU   : 将选中文字统一为右中对正，并以最右侧文字为基准右对齐。
;;;   - AYOU  : 选择一条竖直直线作为基准线，框选其他所有对象作为一个整体整体移动并右对齐到该直线。
;;;   - SHANG : 将选中文字统一为中上对正，并以最上方文字为基准上对齐。
;;;   - ASHANG: 选择一条水平直线作为基准线，框选其他所有对象作为一个整体整体移动并向上对齐到该直线。
;;;   - XIA   : 将选中文字统一为中下对正，并以最下方文字为基准下对齐。
;;;   - AXIA  : 选择一条水平直线作为基准线，框选其他所有对象作为一个整体整体移动并向下对齐到该直线。
;;;   - HE    : 将同一行的两个或以上文字合并。
;;;   - QR    : 快速修改文字高度，记忆上次高度，回车沿用。
;;;   - QR2   : 连续选择文字修改高度，与 QR 共用上次高度；高度回车沿用，选择回车或 Esc 退出。
;;;   - DEA   : 删除所选对象中高度小于 0.1 的 TEXT/MTEXT 文字。
;;;   - DEH   : 删除所选对象中内容含有中文的 TEXT/MTEXT 文字。
;;;   - DEK   : 删除选中内容中的所有块参照 (INSERT)。
;;;   - DET   : 删除所选对象中内容为指定值(逗号或空格分隔、不区分大小写、回车沿用上次)的属性定义ATTDEF。
;;;   - A2T   : 将属性定义ATTDEF（炸块残留、X/BURST无法分解）转为普通单行文字，可选标记/默认值/提示。
;;;   - YSTEMP: 删除所选对象中竖直共线、首尾相接且长度分别为 21 和 7 的直线对。
;;;   - DES   : 所选直线共线重叠时删除短线、保留长线；完全重复留一条，跨图层处理并跳过锁定图层。
;;;   - WI    : 修改选中文字的宽度比例。
;;;   - ATW   : 拾取两点指定最大宽度，将超宽单行文字的宽度比例缩小至两点间距的 95% 并保持左侧不动。
;;;   - XB    : 将选中的文字或尺寸标注整体缩小为原来的十分之一，并保留选择状态。
;;;   - YAN   : 延长竖直直线统一间距，支持分组和上下方向控制。
;;;   - SYAN  : 将选中直线向上延长 5 个单位。
;;;   - XYAN  : 将选中直线向下延长 5 个单位。
;;;   - SYI   : 预选对象中非竖直对象向上移动 5X，竖直直线向上拉伸 5X；自动补选短斜线左侧与水平线相交的竖直线。
;;;   - XYI   : 预选对象中非竖直对象向下移动 5X，竖直直线向下拉伸 5X；自动补选短斜线左侧与水平线相交的竖直线。
;;;   - LL    : 水平/竖直连续画直线并实时预览，结束恢复正交、捕捉与跟踪设置。
;;;   - MM    : 水平/竖直移动并实时预览，第二点可捕捉或输入距离，偏斜自动投影。
;;;   - SS    : 水平/竖直拉伸并实时预览实体变形，第二点可捕捉或输入距离，偏斜自动投影。
;;;   - SW    : 拉伸对象并记忆方向与距离，支持动态拉伸实时预览，后续可直接回车重复。
;;;   - SSS   : 交叉框选调整下沿所在行高度，支持小数，默认 10。
;;;   - SJ    : 在选中直线顶端生成上接短线。
;;;   - XJ    : 在选中直线底端生成下接短线。
;;;   - SYJ   : 将选中竖直直线向上延长 5 个单位，再生成上接短线。
;;;   - XYJ   : 将选中竖直直线向下延长 5 个单位，再生成下接短线。
;;;   - GTX   : 按自动容差整理单行/多行电缆文字并自然排序汇总。
;;;   - GTY   : 保留原文字，按电缆编号排序整理并复制到指定位置。
;;;   - HWD   : 横排交替柜名与电缆编号重组为起点、编号、终点三列，左中对齐、行距5，保留原横排。
;;;   - GTZ   : 将选中的交替柜名与电缆编号单列文字，按前后柜与编号重组为3列表格输出。
;;;   - BIAN  : 根据选中直线生成方向三角、至字样和电缆规格标注。
;;;   - LAN   : 竖直线/斜线/水平线联动复制+移动插件。
;;;   - XIN   : 统计选中直线矩形范围内的对象数量并标注结果。
;;;   - XY    : 自动筛选所选中的绿色水平直线，先运行 XIN 统计芯数，再运行 YUAN 提取对应文字并横向输出。
;;;   - XYG   : 一次框选，自动提取绿色直线执行 XY 统计，并提取大字与电缆文字执行 GTX 分类汇总。
;;;   - JM    : 按绿色电缆线所连原理号，把 ZDDL 生成的“未填写”替换为电缆截面；无法判断的保留并选中提示。
;;;   - BH1   : 逐根点选编号：先点起点柜名大字并输入前缀、起始号，再依次点绿色电缆线，回车后自动缩放一次识别并按点选顺序编号，同终点加 A/B/C，可撤销本批。
;;;   - BH2   : 框选起点柜和绿色电缆线，把已编号但没记录的电缆记入共享记录，给有记录的“未编号”按记录填写；不分配新编号，两端不一致的标红注明原因。
;;;   - BHG  : 以图为准修改电缆编号记录：记录编号改成图上的编号，原编号存为旧编号供另一端 BH1/BH2 自动跟改；“未编号”的删除其记录。
;;;   - BH3   : 框选电缆清册文字（起点柜/编号/终点柜/规格/芯数/原理号），以清册为准写入共享记录：没有的记入，有的强制改成清册编号（同 BHG）。
;;;   - SX0   : 清除联动标记：框选文字，删除副本的联动标记使其成为普通文字；原件自动跳过。
;;;   - YSSX0 : 强制清除联动标记：框选文字，原件和副本的联动标记一并删除，全部成为普通文字。
;;;   - SX    : 联动标记：框选原件端子排文字发放唯一编号（UID），草稿/XY/XYG/GTY 副本自动继承。
;;;   - SX1   : 联动刷新：全图所有同 UID 的副本文字按原件内容单向更新（只同步文字内容），已保存的图同时导出跨图值文件。
;;;   - SX2   : 跨图联动刷新：读取指定文件夹内各卷册图的 .aalink.txt 值文件，更新本图中原件在其他图纸的副本文字。
;;;   - HBDL  : 框选电缆清册表格文字，自动将带有“并入”前缀的行合并到对应的目标电缆主行中，自动累加芯数并在末尾追加原理号，其他行保持原位。
;;;   - NU    : 材料表数字加数字：优先改井号相邻数字，其次改最后一个减号后的连续整数，都没有时改第一个数字（支持小数和正负号）。
;;;   - KAI   : 将 TEXT/MTEXT 中由空格分隔的内容拆分为多个独立文字。
;;;   - GE    : 选中同一水平行的单行文字，按文字间隙绘制单行表格。
;;;   - UT    : 先将文字统一为左中对正，再按最上方一对的位置整理文字；支持直线及按首尾端点计算的未闭合多段线，保留宽度。
;;;   - HAO   : 选中图框后批量填写页码和档案号。
;;;   - HAO2  : 指定基准块参照与图号矩形范围，批量居中填充或更新递增图号文字。
;;;   - FIVE  : 将测得高度按比例缩放为 5。
;;;   - CE    : 测量点序列形成的多段线总长度。
;;;   - CU    : 将选中对象按 5 个单位的递增间距向上复制指定份数。
;;;   - CD    : 将选中对象按 5 个单位的递增间距向下复制指定份数。
;;;   - CZ    : 将选中对象按 5 个单位的递增间距向左复制指定份数。
;;;   - CY    : 将选中对象按 5 个单位的递增间距向右复制指定份数。
;;;   - JZ    : 将矩形水平中线对齐到1条或2条直线中心线，可同步居中文字。
;;;   - DX    : 批量整理 100×100 方格内的端子号、原理号和终点柜文字，并将整组文字居中。
;;;   - FDX   : 先选方框，按从上到下、每行从左到右分配；每批文字按空格移动并按 DX 规则排列。
;;;   - DX1   : 提取选中文字及坐标，青色文字额外标注“端子名”，复制到剪贴板。
;;;   - DX2   : 按方格从左到右、从上到下导出文字，每个方格一行，框内按行排序并用顿号连接，复制到剪贴板。
;;;   - ZDDL  : 两次选择文字并指定插入点，按网页规则生成端子排与电缆。
;;;   - ZDC   : ZDDL 命令的简写别名。
;;;   - ZDDLD : 删除 ZDDL 生成的端子排框线与端子名/号，保留原理号、电缆接线和电缆文字。
;;;   - BDL   : 选择后补的原理号，按 ZDDL 样式补画引线、短斜线、电缆线、箭头和占位文字，自动找空行。
;;;   - ZDDL2 : 自动根据现有端子排与接线方格绘制电缆引线、干线与标注。
;;;   - ZZ    : 先将文字改为中下对正，再居中到最近矩形；多行文字按 5 个单位的中心间距排列。
;;;   - ZZ2   : 按 ZZ 居中，恰好双文字单元格所在行调为10，下方内容顺延。
;;;   - MJ    : 框选单列表格后，按最长文字自动收窄宽度并将各行文字居中。
;;;   - FIVE2   : 同一列相接的直线表格统一行高5，保留顶边、列宽、字高和圆形符号大小。
;;;   - HBBG  : 将完整直线表格按图纸位置从上到下复制拼接，保留原表及各段标题和列顺序。
;;;   - HZBG  : 选中文字生成表格，行高 5，按最宽文字自动列宽，左右各留 3。
;;;   - ZDWI  : 按各列最宽文字自动放宽或缩窄表格列宽，文字左右各留 3 个图纸单位，并按 ZZ 居中。
;;;   - JACC  : ZZ 的同功能入口。
;;;   - DB    : 删除每个选中文字末尾的 N 个字符。
;;;   - DF    : 删除每个选中文字开头的 N 个字符。
;;;   - DE    : 删除选中文字的最右侧括号及括号内容。
;;;   - DE2   : 用最右侧括号内容替换括号前连续数字（数字带相同尾缀时一并替换）。
;;;   - DL1   : 创建电缆柜、电缆路径、电缆竖井相关的 1F / 2F 图层。
;;;   - AB    : 在每个选中文字末尾增加文字（空输入使用剪贴板）。
;;;   - AF    : 在每个选中文字开头增加文字（空输入使用剪贴板）。
;;;   - QW    : 提取选中文字，同一行用顿号连接，不同行之间也用顿号分隔，并复制到剪贴板。
;;;   - QW2   : 提取选中文字及坐标，每项一行“x,y 文字”，坐标保留 2 位小数，复制到剪贴板。
;;;   - QW3   : 导出选中对象的类型、图层、坐标、几何及文字属性为结构化文本并复制到剪贴板。
;;;   - FF    : 预选文字，空格确认查找及替换内容，批量替换所有匹配片段。
;;;   - REP   : 将选中的柜名文字按内置映射表替换为标准柜名。
;;;   - QE    : 用 Windows 剪贴板中的文字批量替换选中文字；文字含“至”字时只替换“至”后的部分。
;;;   - CC    : 读取 Windows 剪贴板，连续复制并替换副本文字，使用原生拖动预览和对象捕捉。
;;;   - AW    : 自动微移选中文字，尽量避开旁边线段、文字和其他对象重叠。
;;;   - ZDML  : 选择多个图框块，生成目录文字。
;;;   - ZDML2 : 指定基准块参照与图名、图号矩形范围，批量提取图名图号并生成目录。
;;;   - ZDMLDEBUG : 选择一个图框块，打印所有增强属性。
;;;   - DUMP  : 打印选中图元的 ActiveX 属性与可用方法（调试辅助）。
;;;   - AAE   : 选择块内属性文字，在自定义窗口中编辑并按回车直接保存。
;;;   - C1    : 复制文字并把编号加 1（优先井号相邻数字，其次减号后数字），使用原生拖动预览和捕捉连续放置。
;;;   - C2    : 复制文字并把编号减 1（优先井号相邻数字，其次减号后数字），使用原生拖动预览和捕捉连续放置。
;;;   - C3    : 复制文字并把编号每次加 2（优先井号相邻数字，其次减号后数字），使用原生拖动预览和捕捉连续放置。
;;;   - ZJ    : 选中多条水平线后向左生成短线、矩形；原理号标注不变，柜内文字默认读取剪贴板，可手动输入（青色虚线）。
;;;   - YJ    : 选中多条水平线后向右生成短线、矩形；原理号标注不变，柜内文字默认读取剪贴板，可手动输入（青色虚线）。
;;;   - KMZ   : 选中两条水平线后向左生成短线、矩形并居中标注+KM、-KM及直流馈线柜（青色虚线）。
;;;   - KMY   : 选中两条水平线后向右生成短线、矩形并居中标注+KM、-KM及直流馈线柜（青色虚线）。
;;;   - LNZ   : 选中两条水平线后向左生成短线、矩形并居中标注L、N及相邻屏柜（青色虚线）。
;;;   - LNY   : 选中两条水平线后向右生成短线、矩形并居中标注L、N及相邻屏柜（青色虚线）。
;;;   - UPSZ  : 选中两条水平线后向左生成短线、矩形并居中标注L、N及UPS电源柜（青色虚线）。
;;;   - UPSY  : 选中两条水平线后向右生成短线、矩形并居中标注L、N及UPS电源柜（青色虚线）。
;;;   - BZ    : 选中两条水平线后向左生成短线、矩形并居中标注B+、B-及同步时钟主机柜（青色虚线）。
;;;   - BY    : 选中两条水平线后向右生成短线、矩形并居中标注B+、B-及同步时钟主机柜（青色虚线）。
;;;   - YDZ   : 选中多条水平线后向左生成短线、矩形并从上往下标注701、-901、-903...及公用测控柜（青色虚线）。
;;;   - YDY   : 选中多条水平线后向右生成短线、矩形并从上往下标注701、-901、-903...及公用测控柜（青色虚线）。
;;;   - LBZ   : 选中多条水平线后向左生成短线、矩形并从上往下标注500、-501、-503...及故障录波柜（青色虚线）。
;;;   - LBY   : 选中多条水平线后向右生成短线、矩形并从上往下标注500、-501、-503...及故障录波柜（青色虚线）。
;;;   - 485Y  : 选中至少两条水平线后向右生成短线、矩形并居中标注485+、485-及网络通信柜（青色虚线）。
;;;   - 485Z  : 选中至少两条水平线后向左生成短线、矩形并居中标注485+、485-及网络通信柜（青色虚线）。
;;;   - XU    : 将所有选中且支持线型修改的对象改为 HIDDEN2。
;;;   - 0     : 将所选对象中的文字旋转角度统一改为 0 度。
;;;   - 9     : 以所选对象整体包围框中心为基点，整体顺时针旋转 90 度。
;;;   - 99    : 以所选对象整体包围框中心为基点，整体逆时针旋转 90 度。
;;;   - QZ    : 取消当前图纸中的全部分组，组内图元保持不变。
;;;   - XX    : 将选中文字内容替换为 7×2.5。
;;;   - ZDAO  : 将选中文字按垂直位置上下颠倒排列（最下面的文字放到最上面，原 DAO）。
;;;   - HDAO  : 将选中文字按水平位置左右颠倒排列（最左边的文字放到最右边）。
;;;   - QH    : 只选中已选文字所在行、且位于当前屏幕内、参考文字左右各 1000 内的所有文字（跨多行时逐行选择）。
;;;   - BK    : 选中文字后只保留最后一对括号内的内容，括号外有“至”时保留“至”。
;;;   - ZTF   : 搜索系统字体并将选定字体写入指定文字样式。
;;;   - HS    : 选中物体单向横向缩放，左右宽度改变，高度保持不变。
;;;   - ZS    : 选中物体单向纵向缩放，上下高度改变，宽度保持不变。
;;;   - SC3   : 将选中对象整体等比例缩小，使四周距 A3 外框至少 5mm。
;;;   - Z0    : 将选中对象的 Z 坐标全部归零（压平到 XY 平面）。
;;;   - YS    : 选取两点生成绿色直线及终点直径100的同层全绿晶体机械徽章，无中央字母标志。
;;;   - YS1   : 选取两点生成绿色直线，以第二点为中心生成高80的TGOOD机械装甲线条Logo，可整体撤销。
;;;   - VPO1  : 切换到“单个”标准视口。
;;;   - VPO2  : 切换到“两个：垂直”标准视口。
;;;   - TONG  : 框选文字对象去重，按自然顺序从上到下排列在指定插入点（HZ样式/字高3/宽比0.7/白色/间距5）。
;;;   - MING  : 按行列网格顺序，批量将单行文字填充到对应属性块的图名属性中。
;;; =======================================================================================

;;;----------------------------------------------------------------------------------------
;;;
;;;                              用户可自定义参数区域
;;;                 在这里修改变量值，可以方便地调整插件功能，无需改动核心代码
;;;
;;;----------------------------------------------------------------------------------------

;;; --- YSDL 命令相关参数 ---
(setq *YSDL_RowFuzz*      1.0)     ; (YSDL) 判断文字是否在同一行的Y坐标容差值
(setq *YSDL_CsvFileName*  "output.csv") ; (YSDL) 输出的CSV文件名
(setq *YSDL_TextColor*    2)       ; (YSDL) 提取后文字变为的颜色 (ACI颜色索引: 2=黄, 1=红, 3=绿, 4=青, 5=蓝, 6=品红, 7=白/黑, 8=浅灰, 9=浅灰)

;;; --- 快速改色命令相关参数 ---
(setq *Y_TextColor*      4)        ; (Y) 快速改色命令的目标颜色 (ACI颜色索引: 2=黄, 1=红, 3=绿, 4=青, 5=蓝, 6=品红, 7=白/黑, 8=浅灰, 9=浅灰)
(setq *YY_TextColor*     2)        ; (YY) 快速改色命令的目标颜色
(setq *RR_TextColor*     1)        ; (RR) 快速改色命令的目标颜色
(setq *WW_TextColor*     7)        ; (WW) 快速改色命令的目标颜色
(setq *GG_TextColor*     3)        ; (GG) 快速改色命令的目标颜色
(setq *PP_TextColor*     6)        ; (PP) 快速改色命令的目标颜色（洋红色）
(setq *HUI_TextColor*    8)        ; (HUI) 深度改色命令的目标颜色

;;; --- UT 参数 ---
(setq *UT_TiltAngle*    3.0)       ; (UT) 判断水平直线允许的最大倾斜角度（度），Y 偏差小于该角度视为水平线


;; 统一加载 Visual LISP COM 扩展，确保所有需要的功能都能正常运行
(vl-load-com)

;;;----------------------------------------------------------------------------------------
;;; 公共命令框架 - 统一 undo 分组、错误处理与系统变量保护
;;;
;;; 用法：命令的局部变量表必须声明 *error* aa:tag aa:doc aa:undo-open aa:old-cmdecho
;;;
;;;   (defun c:XXX (/ *error* aa:tag aa:doc aa:undo-open aa:old-cmdecho ss i)
;;;     (aa:cmd-begin "XXX")
;;;     ... 命令主体 ...
;;;     (aa:cmd-end)
;;;   )
;;;
;;; AutoLISP 是动态作用域，下列函数直接读写调用方局部表中的同名变量；
;;; 命令退出时这些绑定自动失效，因此不会污染全局环境。
;;; 开分组后整条命令的所有修改在 CAD 中只需按一次 U 即可整体撤销。
;;;----------------------------------------------------------------------------------------

(defun aa:cmd-error (msg)
  ;; 统一错误处理：关闭 undo 分组、恢复 CMDECHO，再按需打印错误信息
  (if aa:undo-open
    (progn
      (vl-catch-all-apply 'vla-endundomark (list aa:doc))
      (setq aa:undo-open nil)
    )
  )
  (if aa:old-cmdecho
    (vl-catch-all-apply 'setvar (list "CMDECHO" aa:old-cmdecho))
  )
  (if (and msg
           (= (type msg) 'STR)
           (/= (strcase msg) "FUNCTION CANCELLED")
           (/= (strcase msg) "QUIT / EXIT ABORT")
           (/= (strcase msg) "CONSOLE BREAK"))
    (princ (strcat "\r\n[" (if (= (type aa:tag) 'STR) aa:tag "AA") "] 错误: " msg))
  )
  (princ)
)

;;; YS 几何统一在当前 UCS 构造，写入实体时转为 WCS。
(defun aa:ys-line (p q color)
  (if (not (entmake (list '(0 . "LINE") (cons 8 (getvar "CLAYER"))
                         (cons 62 color) '(6 . "CONTINUOUS")
                         (cons 10 (trans p 1 0)) (cons 11 (trans q 1 0)))))
    (error "YS无法创建线条，请检查当前图层。")))

(defun aa:ys-path (pts closed color / first prev pt)
  (setq first (car pts) prev first)
  (foreach pt (cdr pts) (aa:ys-line prev pt color) (setq prev pt))
  (if closed (aa:ys-line prev first color)))

;;; 宽晶柱采用封闭轮廓，不依赖线宽显示设置。
(defun aa:ys-crystal (p q width color / a)
  (setq a (angle p q))
  (aa:ys-path (list (polar p (+ a (/ pi 2.0)) width)
                    (polar q (+ a (/ pi 2.0)) (* width 0.55))
                    (polar q (- a (/ pi 2.0)) (* width 0.55))
                    (polar p (- a (/ pi 2.0)) width)) T color))

(defun aa:ys-diamond (tip a size / base)
  (setq base (polar tip (+ a pi) size))
  (aa:ys-path (list tip
                    (polar base (+ a (/ pi 2.0)) (* size 0.48))
                    (polar tip (+ a pi) (* size 2.0))
                    (polar base (- a (/ pi 2.0)) (* size 0.48))) T 3))

(defun aa:ys-snowflake (center radius / i a p q d tier pts end branch)
  (setq i 0 pts nil)
  (repeat 6
    (setq a (* i (/ pi 3.0))
          p (polar center a (* radius 0.24))
          q (polar center a (* radius 0.84))
          pts (cons p pts))
    (aa:ys-crystal p q (* radius (if (> radius 9.0) 0.055 0.035)) 3)
    (foreach tier '((0.40 0.30) (0.65 0.20))
      (setq p (polar center a (* radius (car tier))))
      (foreach d '(-1.0 1.0)
        (setq branch (+ a (* d (/ pi 3.0)))
              end (polar p branch (* radius (cadr tier))))
        (aa:ys-crystal p end (* radius 0.022) 3)
        (if (or (<= radius 9.0) (< (car tier) 0.5))
          (aa:ys-diamond (polar end branch (* radius 0.08))
                         branch (* radius 0.04)))))
    (aa:ys-diamond (polar center a radius) a (* radius 0.08))
    ;; 小雪花的六个微型节点位于主轴之间，保持原外接半径。
    (if (<= radius 9.0)
      (aa:ys-diamond (polar center (+ a (/ pi 6.0)) (* radius 0.80))
                     (+ a (/ pi 6.0)) (* radius 0.035)))
    (setq i (1+ i)))
  (aa:ys-path (reverse pts) T 3))

(defun aa:ys-detail (center coords angle / pts xy)
  (foreach xy coords
    (setq pts (cons (polar (polar center angle (car xy))
                          (+ angle (/ pi 2.0)) (cadr xy)) pts)))
  (aa:ys-path (reverse pts) nil 3))

;;; 分段圆环给四个方向的饰件留空；小圆弧以密集折线构造。
(defun aa:ys-rim (center radius / quadrant i a pts)
  (setq quadrant 0)
  (repeat 4
    (setq i 0 pts nil)
    (repeat 61
      (setq a (+ (* quadrant (/ pi 2.0)) 0.05
                 (* (/ i 60.0) (- (/ pi 2.0) 0.1)))
            pts (cons (polar center a radius) pts) i (1+ i)))
    (aa:ys-path (reverse pts) nil 3)
    (setq quadrant (1+ quadrant))))

(defun aa:ys-ring (center radius / normal)
  (setq normal (trans '(0.0 0.0 1.0) 1 0 T))
  (if (not (entmake (list '(0 . "CIRCLE") (cons 8 (getvar "CLAYER"))
                         '(62 . 3) '(6 . "CONTINUOUS")
                         (cons 10 (trans (trans center 1 0) 0 normal))
                         (cons 40 radius) (cons 210 normal))))
    (error "YS无法创建圆环。")))

(defun c:YS (/ *error* aa:tag aa:doc aa:undo-open aa:old-cmdecho p1 p2 i a center stroke pts xy side vertical)
  (aa:cmd-begin "YS")
  (setq p1 (getpoint "\r\nYS 指定直线起点: "))
  (if p1 (setq p2 (getpoint p1 "\r\n指定终点（徽章中心）: ")))
  (if (and p2 (not (equal p1 p2 1e-8)))
    (progn
      (aa:ys-line p1 p2 3)
      (aa:ys-ring p2 50.0)
      (aa:ys-rim p2 48.0)
      (aa:ys-rim p2 46.0)
      (aa:ys-snowflake p2 18.0)
      (foreach xy '((0.0 31.0) (-31.0 0.0) (31.0 0.0) (0.0 -31.0))
        (setq center (list (+ (car p2) (car xy))
                           (+ (cadr p2) (cadr xy)) (caddr p2)))
        (aa:ys-snowflake center 9.0))
      ;; 三层翼片从尖窄根部向外展开，四象限共用同一组轮廓。
      (foreach side '(-1.0 1.0)
       (foreach vertical '(-1.0 1.0)
        (foreach stroke '(((10.5 14.5) (17.0 25.0) (32.0 25.0)
                           (35.0 22.0) (35.0 18.0) (32.0 21.5)
                           (18.5 21.5) (10.5 14.5))
                          ((13.0 12.0) (21.0 19.0) (31.0 19.0)
                           (34.0 16.0) (34.0 12.5) (31.0 16.0)
                           (22.0 16.0) (13.0 12.0))
                          ((16.0 9.0) (23.0 13.5) (28.0 13.5)
                           (31.0 10.5) (31.0 8.5) (28.0 11.0)
                           (23.5 11.0) (16.0 9.0)))
          (setq pts nil)
          (foreach xy stroke (setq pts (cons (list (* side (car xy)) (* vertical (cadr xy))) pts)))
          (aa:ys-detail p2 (reverse pts) 0.0))))
      (setq i 0)
      (repeat 36
        (setq a (* i (/ (* 2.0 pi) 36.0)))
        (if (/= (rem i 9) 0)
          (aa:ys-line (polar p2 a 47.0) (polar p2 a 48.5) 3))
        (setq i (1+ i)))
      (setq i 0)
      (repeat 4
        (setq a (* i (/ pi 2.0)))
        (aa:ys-detail p2 '((43.3 0.0) (44.6 1.25) (48.6 1.25)
                           (50.0 0.0) (48.6 -1.25) (44.6 -1.25) (43.3 0.0)) a)
        (aa:ys-detail p2 '((44.3 0.0) (49.1 0.0)) a)
        (aa:ys-detail p2 '((46.3 -2.6) (46.3 2.6)) a)
        (aa:ys-detail p2 '((47.2 -2.6) (47.2 2.6)) a)
        (setq i (1+ i)))
      (redraw)
      (princ "\r\nYS完成：同一图层的全绿色雪花徽章，一次U可整体撤销。"))
    (if p2 (princ "\r\n起点与终点重合，未绘制。")))
  (aa:cmd-end)
  (princ))

;;; YS1：坐标模板为字母宽/高的比例；所有细节尺寸由 H 派生。
(defun aa:ys1-point (x y)
  (list (+ (car base) origin x) (+ (cadr base) y)
        (if (caddr base) (caddr base) 0.0)))

(defun aa:ys1-path (pts closed / result xy)
  (foreach xy pts
    (setq result (cons (aa:ys1-point (car xy) (cadr xy)) result)))
  (aa:ys-path (reverse result) closed 3))

(defun aa:ys1-template (coords width / pts xy)
  (foreach xy coords
    (setq pts (cons (list (* width (car xy)) (* H (cadr xy))) pts)))
  (aa:ys1-path (reverse pts) nil))

;;; 真圆弧按 UCS 法向及 OCS 圆心写入，不用密集折线模拟。
(defun aa:ys1-arc (x y radius start end / normal center axis rotation)
  (setq normal (trans '(0.0 0.0 1.0) 1 0 T)
        center (trans (trans (aa:ys1-point x y) 1 0) 0 normal)
        axis (trans (trans '(1.0 0.0 0.0) 1 0 T) 0 normal T)
        rotation (atan (cadr axis) (car axis)))
  (if (not (entmake (list '(0 . "ARC") (cons 8 (getvar "CLAYER"))
                         '(62 . 3) '(6 . "CONTINUOUS") (cons 10 center)
                         (cons 40 radius) (cons 50 (+ rotation start))
                         (cons 51 (+ rotation end)) (cons 210 normal))))
    (error "YS1无法创建圆弧，请检查当前图层。")))

(defun aa:ys1-t (/ shape x side)
  (foreach shape
    '(((0 1) (1 1) (.86 .79) (.61 .79) (.59 .76) (.59 .14) (.50 0)
       (.41 .14) (.41 .76) (.39 .79) (.14 .79) (0 1))
      ((.055 .975) (.17 .835) (.395 .835) (.455 .755) (.455 .13) (.50 .055)
       (.545 .13) (.545 .755) (.605 .835) (.83 .835) (.945 .975))
      ((.20 .925) (.405 .925) (.50 .81) (.595 .925) (.80 .925))
      ((.48 .70) (.48 .53) (.46 .50) (.48 .47) (.48 .22))
      ((.52 .70) (.52 .53) (.54 .50) (.52 .47) (.52 .22))
      ((.50 .74) (.50 .58)) ((.50 .42) (.50 .17)))
    (aa:ys1-template shape T-W))
  (foreach side '(0.0 1.0)
    (foreach x '(.12 .18 .24)
      (aa:ys1-template
        (list (list (abs (- side x)) .985)
              (list (abs (- side (+ x .065))) .94)) T-W))))

(defun aa:ys1-g (/ shape)
  (foreach shape
    '(((1 1) (.23 1) (0 .77) (0 .23) (.23 0) (.78 0) (.98 .20)
       (.98 .64) (.41 .64) (.41 .38) (.73 .38) (.73 .30) (.66 .23)
       (.29 .23) (.18 .34) (.18 .67) (.30 .79) (.84 .79) (1 1))
      ((.91 .955) (.25 .955) (.05 .75) (.05 .25) (.25 .05) (.755 .05)
       (.93 .22) (.93 .59) (.46 .59) (.46 .43) (.78 .43) (.78 .28)
       (.69 .18) (.27 .18) (.13 .32) (.13 .69) (.28 .84) (.82 .84))
      ((.35 .91) (.78 .91) (.83 .95))
      ((.055 .27) (.10 .31) (.10 .48)) ((.055 .73) (.10 .69) (.10 .55))
      ((.28 .10) (.65 .10) (.70 .14))
      ((.51 .54) (.86 .54) (.86 .25) (.79 .18))
      ((.53 .47) (.66 .47) (.70 .50))
      ((.63 .88) (.67 .85) (.70 .88) (.63 .88))
      ((.72 .85) (.76 .89)) ((.78 .85) (.82 .89))
      ((.02 .25) (.20 .07)) ((.79 .02) (.91 .16)))
    (aa:ys1-template shape G-W))
  (aa:ys1-arc (* G-W .30) (* H .68) (* H .045) (/ pi 2.0) pi))

;;; O 的四层八边框共用尺寸，侧部断口留给双轨机械接口。
(defun aa:ys1-o (/ inset left right low high cut middle sign x y)
  (setq middle (/ O-W 2.0))
  (foreach inset (list 0.0 OFFSET (* OFFSET 3.0) (* OFFSET 3.7))
    (setq left inset right (- O-W inset) low inset high (- H inset)
          cut (if (< inset (* OFFSET 2.0)) CHAMFER (* CHAMFER .55)))
    (if (< inset (* OFFSET 2.0))
      (progn
        (aa:ys1-path
          (list (list left (- (/ H 2.0) SLOT)) (list left (+ low cut))
                (list (+ left cut) low) (list (- middle DETAIL) low)
                (list middle (+ low DETAIL)) (list (+ middle DETAIL) low)
                (list (- right cut) low) (list right (+ low cut))
                (list right (- (/ H 2.0) SLOT))) nil)
        (aa:ys1-path
          (list (list left (+ (/ H 2.0) SLOT)) (list left (- high cut))
                (list (+ left cut) high) (list (- middle DETAIL) high)
                (list middle (- high DETAIL)) (list (+ middle DETAIL) high)
                (list (- right cut) high) (list right (- high cut))
                (list right (+ (/ H 2.0) SLOT))) nil))
      (aa:ys1-path
        (list (list left (+ low cut)) (list (+ left cut) low)
              (list (- right cut) low) (list right (+ low cut))
              (list right (- high cut)) (list (- right cut) high)
              (list (+ left cut) high) (list left (- high cut))) T)))
  (foreach sign '(0.0 1.0)
    (setq x (* sign (- O-W (* OFFSET 2.1))))
    (foreach y (list (- (/ H 2.0) SLOT) (+ (/ H 2.0) SLOT))
      (aa:ys1-path (list (list x y) (list (+ x (* OFFSET 2.1)) y)) nil)))
  (foreach x (list OFFSET (* OFFSET 1.6) (- O-W OFFSET) (- O-W (* OFFSET 1.6)))
    (aa:ys1-path (list (list x (- (/ H 2.0) SLOT))
                       (list x (+ (/ H 2.0) SLOT))) nil))
  (foreach y (list DETAIL (- H DETAIL OFFSET))
    (aa:ys1-path (list (list middle y) (list middle (+ y OFFSET))) nil))
  (foreach x (list (* O-W .27) (* O-W .65))
    (foreach y (list (* OFFSET 2.0) (- H (* OFFSET 2.0)))
      (aa:ys1-path (list (list x y) (list (+ x DETAIL) y)) nil))))

(defun aa:ys1-d (/ inset radius cx lower upper x sign y)
  (setq cx (* D-W .61) lower (* H .32) upper (* H .68))
  (foreach inset (list 0.0 OFFSET (* OFFSET 3.0) (* OFFSET 3.7))
    (setq radius (- (* H .32) inset))
    (aa:ys1-path
      (list (list cx inset) (list (+ inset CHAMFER) inset)
            (list inset (+ inset CHAMFER)) (list inset (- H inset CHAMFER))
            (list (+ inset CHAMFER) (- H inset)) (list cx (- H inset))) nil)
    (aa:ys1-arc cx lower radius (* pi 1.5) (* pi 2.0))
    (aa:ys1-path (list (list (+ cx radius) lower) (list (+ cx radius) upper)) nil)
    (aa:ys1-arc cx upper radius 0.0 (/ pi 2.0)))
  (foreach x (list (* OFFSET 1.8) (* OFFSET 2.4))
    (aa:ys1-path (list (list x (* H .30)) (list x (* H .46))
                       (list (+ x (* SLOT .35)) (* H .50))
                       (list x (* H .54)) (list x (* H .70))) nil))
  (foreach sign '(0.0 1.0)
    (foreach x '(.37 .45 .53)
      (aa:ys1-template (list (list x (abs (- sign .065)))
                             (list (+ x .06) (abs (- sign .135)))) D-W))
    (setq y (if (= sign 0.0) (* H .10) (* H .90)))
    (aa:ys1-path (list (list (* D-W .20) y) (list (* D-W .32) y)) nil))
  (foreach y (list (* H .41) (* H .59))
    (aa:ys1-path (list (list (+ cx (* H .32)) y)
                       (list (- (+ cx (* H .32)) OFFSET) y)) nil)))

;;; YS1：第二点为当前 UCS 中图案包络框中心，base 为内部绘图左下角。
(defun c:YS1 (/ *error* aa:tag aa:doc aa:undo-open aa:old-cmdecho
                 p1 base width origin H T-W G-W O-W D-W GAP OFFSET CHAMFER SLOT DETAIL)
  (aa:cmd-begin "YS1")
  (setq H 80.0 T-W (* H 1.18) G-W H O-W H D-W (* H 1.05)
        GAP (* H .045) OFFSET (* H .045) CHAMFER (* H .18)
        SLOT (* H .09) DETAIL (* H .065) origin 0.0)
  (setq p1 (getpoint "\r\nYS1 指定直线起点: "))
  (if p1
    (setq base (getpoint p1 "\r\n指定终点（TGOOD图案中心）: ")))
  (if base
    (progn
      (if (not (equal p1 base 1e-8)) (aa:ys-line p1 base 3))
      ;; D 的实际最右点为圆心 X 加外弧半径，不能直接按名义 D-W 居中。
      (setq width (+ T-W G-W (* 2.0 O-W) (* 4.0 GAP)
                     (* D-W .61) (* H .32))
            base (list (- (car base) (/ width 2.0))
                       (- (cadr base) (/ H 2.0))
                       (if (caddr base) (caddr base) 0.0)))
      (aa:ys1-t)
      (setq origin (+ origin T-W GAP)) (aa:ys1-g)
      (setq origin (+ origin G-W GAP)) (aa:ys1-o)
      (setq origin (+ origin O-W GAP)) (aa:ys1-o)
      (setq origin (+ origin O-W GAP)) (aa:ys1-d)
      (redraw)
      (princ "\r\nYS1完成：高80的绿色TGOOD机械线稿，线条可单独编辑，一次U整体撤销。")))
  (aa:cmd-end)
  (princ))

;;; DES 使用数值字典序，保留原始坐标精度，不依赖当前 UCS 或显示精度。
(defun des:key-less-p (a b)
  (while (and a b (= (car a) (car b)))
    (setq a (cdr a) b (cdr b)))
  (and a b (< (car a) (car b))))

(defun des:record-less-p (a b)
  (des:key-less-p (car a) (car b)))

;; 记录依次为：几何键、实体、起点、终点、长度、最小X、最大X。
(defun des:x-less-p (a b)
  (< (nth 5 a) (nth 5 b)))

(defun des:dot (a b)
  (apply '+ (mapcar '* a b)))

(defun des:overlap-p (a b tol / p q len unit v w t1 t2)
  (setq p (nth 2 a) q (nth 3 a) len (nth 4 a))
  (if (and (> len tol) (> (nth 4 b) tol)
           (equal (cdddr (cdddr (car a))) (cdddr (cdddr (car b))) 0.0))
    (progn
      (setq unit (mapcar '(lambda (x) (/ x len)) (mapcar '- q p))
            v (mapcar '- (nth 2 b) p)
            w (mapcar '- (nth 3 b) p)
            t1 (des:dot v unit) t2 (des:dot w unit))
      (and
        (<= (distance v (mapcar '(lambda (x) (* x t1)) unit)) tol)
        (<= (distance w (mapcar '(lambda (x) (* x t2)) unit)) tol)
        (> (- (min len (max t1 t2)) (max 0.0 (min t1 t2))) tol)))
    nil))

;;; DES：共线且有重叠长度时整条删除短线，端点相接不删除。
(defun c:DES (/ *error* aa:tag aa:doc aa:undo-open aa:old-cmdecho
                ss i en ed p q tmp key records record previous
                layer-data locked skipped removed failed result
                active next-active other doomed victim tol)
  (aa:cmd-begin "DES")
  (princ "\r\nDES：选择直线，共线重叠时整条删除短线、保留长线（跨图层）。")
  (setq ss (ssget "_I" (list '(0 . "LINE") (cons 410 (getvar "CTAB")))))
  (if (not ss)
    (setq ss (ssget (list '(0 . "LINE") (cons 410 (getvar "CTAB"))))))
  (setq i 0 skipped 0 removed 0 failed 0 tol 1e-8 doomed (ssadd))
  (if ss
    (progn
      (repeat (sslength ss)
        (setq en (ssname ss i) ed (entget en) i (1+ i)
              layer-data (tblsearch "LAYER" (cdr (assoc 8 ed)))
              locked (/= 0 (logand 4 (cdr (assoc 70 layer-data)))))
        (if locked
          (setq skipped (1+ skipped))
          (progn
            (setq p (cdr (assoc 10 ed)) q (cdr (assoc 11 ed)))
            (if (des:key-less-p q p)
              (setq tmp p p q q tmp))
            ;; 厚度及拉伸方向也参与比较，避免删除外观不同的三维实体。
            (setq key (append p q
                        (list (cond ((cdr (assoc 39 ed))) (T 0.0)))
                        (cond ((cdr (assoc 210 ed))) (T '(0.0 0.0 1.0))))
                  records (cons (list key en p q (distance p q)
                                  (min (car p) (car q))
                                  (max (car p) (car q))) records)))))
      ;; 先消除完全重复（含零长度线），再用X区间扫描缩小重叠比较范围。
      (setq records (aa:merge-sort records 'des:record-less-p)
            next-active nil)
      (foreach record records
        (if (and previous (equal (car record) previous 0.0))
          (ssadd (cadr record) doomed)
          (setq previous (car record) next-active (cons record next-active))))
      (setq records (aa:merge-sort next-active 'des:x-less-p))
      (foreach record records
        (setq next-active nil)
        (foreach other active
          (if (>= (+ (nth 6 other) tol) (nth 5 record))
            (progn
              (setq next-active (cons other next-active))
              (if (des:overlap-p record other tol)
                (progn
                  (setq victim
                    (cond
                      ((< (nth 4 record) (- (nth 4 other) tol)) record)
                      ((< (nth 4 other) (- (nth 4 record) tol)) other)))
                  (if victim (ssadd (cadr victim) doomed)))))))
        (setq active (cons record next-active)))
      (setq i 0)
      (repeat (sslength doomed)
        (setq result (vl-catch-all-apply 'entdel (list (ssname doomed i)))
              i (1+ i))
        (if (or (vl-catch-all-error-p result) (not result))
          (setq failed (1+ failed))
          (setq removed (1+ removed))))
      (if (> removed 0) (redraw))
      (princ (strcat "\r\nDES 完成：检查 " (itoa (sslength ss))
                     " 条，删除重复线 " (itoa removed)
                     " 条，跳过锁定图层 " (itoa skipped)
                     " 条，删除失败 " (itoa failed) " 条。")))
    (princ "\r\n未选择直线。"))
  (aa:cmd-end)
  (princ))

;;; YSTEMP 记录：(实体 长度 下端点 上端点 最小Y 最大Y)。
(defun ystemp:y-less-p (a b)
  (< (nth 4 a) (nth 4 b)))

;;; 必须异长、首尾相接；重叠线或仅有同长度邻线不匹配。
(defun ystemp:pair-p (a b tol)
  (and (/= (cadr a) (cadr b))
       (or (equal (nth 3 a) (nth 2 b) tol)
           (equal (nth 3 b) (nth 2 a) tol))))

;;; YSTEMP：删除选中范围内长度21和7、竖直共线且首尾相接的直线对。
(defun c:YSTEMP (/ *error* aa:tag aa:doc aa:undo-open aa:old-cmdecho
                   ss i en ed p q tmp len kind tol layer-data
                   records record active next-active other doomed
                   skipped removed failed result)
  (aa:cmd-begin "YSTEMP")
  (princ "\r\nYSTEMP：选择对象，删除长度21和7的相接竖直线对（WCS，容差0.0001）。")
  (setq ss (ssget "_I" (list '(0 . "LINE") (cons 410 (getvar "CTAB")))))
  (if (not ss)
    (setq ss (ssget (list '(0 . "LINE") (cons 410 (getvar "CTAB"))))))
  (setq i 0 tol 0.0001 skipped 0 removed 0 failed 0 doomed (ssadd))
  (if ss
    (progn
      (repeat (sslength ss)
        (setq en (ssname ss i) ed (entget en) i (1+ i)
              p (cdr (assoc 10 ed)) q (cdr (assoc 11 ed))
              len (distance p q)
              kind (cond ((equal len 21.0 tol) 21)
                         ((equal len 7.0 tol) 7)))
        ;; LINE的DXF端点是WCS坐标；X、Z都必须相同，排除斜线和三维斜线。
        (if (and kind (equal (car p) (car q) tol)
                      (equal (caddr p) (caddr q) tol))
          (progn
            (setq layer-data (tblsearch "LAYER" (cdr (assoc 8 ed))))
            (if (/= 0 (logand 4 (cdr (assoc 70 layer-data))))
              (setq skipped (1+ skipped))
              (progn
                (if (> (cadr p) (cadr q)) (setq tmp p p q q tmp))
                (setq records (cons (list en kind p q (cadr p) (cadr q)) records)))))))
      ;; 按Y区间扫描，过期的候选线及时移出；先完整识别，再统一删除。
      (setq records (aa:merge-sort records 'ystemp:y-less-p))
      (foreach record records
        (setq next-active nil)
        (foreach other active
          (if (>= (+ (nth 5 other) tol) (nth 4 record))
            (progn
              (setq next-active (cons other next-active))
              (if (ystemp:pair-p record other tol)
                (progn (ssadd (car record) doomed)
                       (ssadd (car other) doomed))))))
        (setq active (cons record next-active)))
      (setq i 0)
      (repeat (sslength doomed)
        (setq result (vl-catch-all-apply 'entdel (list (ssname doomed i)))
              i (1+ i))
        (if (or (vl-catch-all-error-p result) (not result))
          (setq failed (1+ failed))
          (setq removed (1+ removed))))
      (if (> removed 0) (redraw))
      (princ (strcat "\r\nYSTEMP 完成：匹配 " (itoa (sslength doomed))
                     " 条，已删除 " (itoa removed)
                     " 条，跳过锁定图层候选线 " (itoa skipped)
                     " 条，删除失败 " (itoa failed) " 条。")))
    (princ "\r\n未选择直线。"))
  (aa:cmd-end)
  (princ))

(defun aa:cmd-begin (tag)
  ;; 进入命令：记录标签、取文档对象、保存 CMDECHO、挂错误处理器并开启 undo 分组
  (vl-load-com)
  (setq aa:tag         tag
        aa:doc         (vla-get-activedocument (vlax-get-acad-object))
        aa:old-cmdecho (getvar "CMDECHO")
        *error*        aa:cmd-error
  )
  (vl-catch-all-apply 'vla-startundomark (list aa:doc))
  (setq aa:undo-open T)
  aa:doc
)

(defun aa:cmd-end ()
  ;; 正常退出命令：关闭 undo 分组并恢复 CMDECHO
  (if aa:undo-open
    (progn
      (vl-catch-all-apply 'vla-endundomark (list aa:doc))
      (setq aa:undo-open nil)
    )
  )
  (if aa:old-cmdecho
    (vl-catch-all-apply 'setvar (list "CMDECHO" aa:old-cmdecho))
  )
  (princ)
)

;;; 下面一对只负责 undo 分组，不接管错误处理器。
;;; 供已经有自定义 *error*（需要关文件、清选择集等专属清理）的命令使用：
;;; 局部表声明 aa:doc aa:undo-open，并在自有 *error* 中调用 (aa:undo-mark-off)。

(defun aa:undo-mark-on ()
  (vl-load-com)
  (setq aa:doc (vla-get-activedocument (vlax-get-acad-object)))
  (vl-catch-all-apply 'vla-startundomark (list aa:doc))
  (setq aa:undo-open T)
  aa:doc
)

(defun aa:undo-mark-off ()
  (if aa:undo-open
    (progn
      (vl-catch-all-apply 'vla-endundomark (list aa:doc))
      (setq aa:undo-open nil)
    )
  )
  (princ)
)

;;;----------------------------------------------------------------------------------------
;;; ZTF - 文字样式字体搜索器
;;;----------------------------------------------------------------------------------------
(setq *ztf-style-name* nil)
(setq *ztf-font-records* nil)
(setq *ztf-filtered-fonts* nil)
(setq *ztf-selected-font* nil)
(setq *ztf-all-styles* nil)
(setq *ztf-filtered-styles* nil)
(setq *ztf-project-dir* "D:/Syncthing/Oracle-Sync/LISP/ZW-auto_lisp")

(defun aa:insert-sort (items comparator / sorted item before)
  ;; 使用插入排序，避免 ZWCAD 2026 对 vl-sort 比较器的性能问题。
  (setq sorted nil)
  (foreach item items
    (setq before nil)
    (while (and sorted (not (apply comparator (list item (car sorted)))))
      (setq before (cons (car sorted) before)
            sorted (cdr sorted)))
    (setq sorted (append (reverse before) (cons item sorted))))
  sorted)

(defun aa:msort-merge (a b comparator / out)
  ;; 稳定归并：只有当 b 的首元素严格排在 a 的首元素之前时才取 b，
  ;; 两者判定相等时保留 a，从而维持原有先后顺序。
  (setq out nil)
  (while (and a b)
    (if (apply comparator (list (car b) (car a)))
      (setq out (cons (car b) out)
            b   (cdr b))
      (setq out (cons (car a) out)
            a   (cdr a))
    )
  )
  (while a (setq out (cons (car a) out) a (cdr a)))
  (while b (setq out (cons (car b) out) b (cdr b)))
  (reverse out)
)

(defun aa:merge-sort (items comparator / n half left rest i)
  ;; O(n log n) 稳定归并排序，用于替代 vl-sort。
  ;; ZWCAD 2026 的 vl-sort 对带 lambda 比较器的大列表性能极差，
  ;; 而且会把比较器判定为相等的元素当作重复项丢弃；本函数两者都不会。
  ;; 比较器同时兼容 '(lambda ...) 与 (function (lambda ...)) 两种写法。
  (setq n (length items))
  (if (< n 2)
    items
    (progn
      (setq half (/ n 2)
            left nil
            rest items
            i    0)
      (while (< i half)
        (setq left (cons (car rest) left)
              rest (cdr rest)
              i    (1+ i))
      )
      (aa:msort-merge
        (aa:merge-sort (reverse left) comparator)
        (aa:merge-sort rest comparator)
        comparator)
    )
  )
)

(defun ztf:sort-style-names (names / sorted name before tail)
  ;; 使用简单插入排序，避免 ZWCAD 的 vl-sort/acad_strlsort 兼容差异。
  (setq sorted nil)
  (foreach name names
    (if (= (type name) 'STR)
      (progn
        (setq before nil)
        (while (and sorted
                    (< (strcase (car sorted)) (strcase name)))
          (setq before (cons (car sorted) before)
                sorted (cdr sorted)))
        (setq sorted (append (reverse before) (cons name sorted))))))
  sorted)

(defun ztf:locate-dcl (/ p loadPath)
  (setq p (findfile "ZTF.dcl"))
  (if (not p)
    (progn
      (setq loadPath (if (and (boundp '*load-truename*)
                              (= (type *load-truename*) 'STR))
                       *load-truename*
                       nil))
      (if loadPath
        (setq p (strcat (vl-filename-directory loadPath) "\\ZTF.dcl")))))
  (if (and p (findfile p))
    (findfile p)
    (if (findfile (strcat *ztf-project-dir* "\\ZTF.dcl"))
      (findfile (strcat *ztf-project-dir* "\\ZTF.dcl"))
      nil)))

(defun ztf:style-names (/ item itemName out current)
  ;; 使用样式表原始顺序，不排序；遇到中望异常返回值时立即停止。
  (setq item (tblnext "STYLE" T))
  (while (and item (listp item))
    (setq itemName (cdr (assoc 2 item)))
    (if (= (type itemName) 'STR)
      (setq out (cons itemName out)))
    (setq item (tblnext "STYLE")))
  (setq current (getvar "TEXTSTYLE"))
  (if (and (= (type current) 'STR) (not (member current out)))
    (setq out (cons current out)))
  (ztf:sort-style-names (reverse out)))

(defun ztf:refresh-style-list (query / q style)
  (setq q (strcase (if (= (type query) 'STR) query "")))
  (setq *ztf-filtered-styles* nil)
  (start_list "style_list")
  (foreach style *ztf-all-styles*
    (if (or (= q "") (vl-string-search q (strcase style)))
      (progn
        (setq *ztf-filtered-styles*
              (append *ztf-filtered-styles* (list style)))
        (add_list style))))
  (end_list)
  (if *ztf-filtered-styles*
    (progn
      (if (member *ztf-style-name* *ztf-filtered-styles*)
        (set_tile "style_list"
                  (itoa (vl-position *ztf-style-name* *ztf-filtered-styles*)))
        (progn
          (setq *ztf-style-name* (car *ztf-filtered-styles*))
          (set_tile "style_list" "0")))
      (ztf:update-style-info *ztf-style-name*))
    (progn
      (setq *ztf-style-name* nil)
      (set_tile "style_info" "No matching text style"))))

(defun ztf:font-file-p (name / upper)
  (if (= (type name) 'STR)
    (progn
      (setq upper (strcase name))
      (or (wcmatch upper "*.TTF")
          (wcmatch upper "*.TTC")
          (wcmatch upper "*.OTF")
          (wcmatch upper "*.FON")
          (wcmatch upper "*.SHX")))
    nil))

(defun ztf:font-label (name / upper alias)
  (if (/= (type name) 'STR)
    (setq name "")
    nil)
  (setq upper (strcase name))
  (setq alias
    (cond
      ((wcmatch upper "SIMSUN*") "宋体")
      ((wcmatch upper "SIMHEI*") "黑体")
      ((wcmatch upper "SIMKAI*") "楷体")
      ((wcmatch upper "SIMFANG*") "仿宋")
      ((wcmatch upper "MSYH*") "微软雅黑")
      ((wcmatch upper "DENGXIAN*") "等线")
      ((wcmatch upper "MICROSOFTYAHEI*") "微软雅黑")
      ((wcmatch upper "NSIMSUN*") "新宋体")
      (T nil)))
  (if alias (strcat alias " | " name) name))

(defun ztf:add-font-file (file records / path)
  (if (and (= (type file) 'STR)
           (ztf:font-file-p file)
           (not (assoc file records))
           (setq path (findfile file)))
    (cons (cons file path) records)
    records))

(defun ztf:collect-font-records (/ windir dir files item path out)
  ;; 首版以 Windows Fonts 目录为主，同时补入当前图纸实际引用的字体文件。
  (setq windir (getenv "WINDIR"))
  (if (/= (type windir) 'STR) (setq windir "C:\\Windows"))
  (setq dir (strcat windir "\\Fonts"))
  (setq files (vl-catch-all-apply 'vl-directory-files (list dir nil 1)))
  (if (vl-catch-all-error-p files) (setq files nil))
  (if (/= (type files) 'LIST) (setq files nil))
  (foreach item files
    (if (ztf:font-file-p item)
      (setq out (cons (cons item (strcat dir "\\" item)) out))))
  ;; SHX 字体通常在 CAD 支持路径，不在 Windows Fonts 文件夹。
  (foreach item '("txt.shx" "simplex.shx" "romans.shx" "romand.shx"
                  "bigfont.shx" "gbcbig.shx")
    (setq out (ztf:add-font-file item out)))
  ;; 当前样式引用的 SHX 文件也加入列表。
  (setq item (getvar "TEXTSTYLE"))
  (if (= (type item) 'STR)
    (progn
      (setq path (vl-catch-all-apply 'tblsearch (list "STYLE" item)))
      (if (vl-catch-all-error-p path) (setq path nil))
      (if (and (listp path) (= (type (cdr (assoc 3 path))) 'STR))
        (setq out (ztf:add-font-file (cdr (assoc 3 path)) out)))))
  (reverse out))

(defun ztf:style-object (styleName / doc styles result)
  (setq doc (vla-get-ActiveDocument (vlax-get-acad-object)))
  (setq styles (vla-get-TextStyles doc))
  (setq result (vl-catch-all-apply 'vla-Item (list styles styleName)))
  (if (vl-catch-all-error-p result) nil result))

(defun ztf:refresh-font-list (query / q rec label)
  (setq q (strcase (if query query "")))
  (setq *ztf-filtered-fonts* nil)
  (start_list "font_list")
  (foreach rec *ztf-font-records*
    (setq label (ztf:font-label (car rec)))
    (if (or (= q "") (vl-string-search q (strcase label)))
      (progn
        (setq *ztf-filtered-fonts* (append *ztf-filtered-fonts* (list rec)))
        (add_list label))))
  (end_list)
  (if *ztf-filtered-fonts*
    (progn
      (setq *ztf-selected-font* (car *ztf-filtered-fonts*))
      (set_tile "font_list" "0")
      (set_tile "font_path" (cdr *ztf-selected-font*)))
    (progn
      (setq *ztf-selected-font* nil)
      (set_tile "font_path" "没有匹配的字体文件"))))

(defun ztf:update-style-info (styleName / count)
  (setq *ztf-style-name* styleName)
  (setq count 0)
  (set_tile "style_info"
            (strcat "Style: " styleName "    Objects: " (itoa count))))

(defun ztf:apply-font (/ styleObj fontPath fontName resolved result doc)
  (if (and *ztf-style-name* *ztf-selected-font*)
    (progn
      (setq fontPath (cdr *ztf-selected-font*))
      ;; SHX 使用支持路径可解析的文件名，避免 STYLE 将带路径的引用
      ;; 与字体列表中的同名项分开显示。系统字体仍保留完整路径。
      (setq fontName (strcat (vl-filename-base fontPath)
                            (vl-filename-extension fontPath)))
      (if (wcmatch (strcase fontName) "*.SHX")
        (progn
          (setq resolved (findfile fontName))
          ;; 只在短文件名仍指向所选文件时写入，避免同名字体被替换。
          (if (and resolved
                   (= (strcase (vl-string-translate "/" "\\" resolved))
                      (strcase (vl-string-translate "/" "\\" fontPath))))
            (setq fontPath fontName)
            (setq fontPath nil))))
      (if (not fontPath)
        (alert "所选 SHX 字体不能通过支持路径中的文件名定位，或存在同名冲突。请检查支持文件搜索路径。")
        (progn
          (setq styleObj (ztf:style-object *ztf-style-name*))
          (if styleObj
            (progn
              (setq result
                (vl-catch-all-apply 'vla-put-FontFile
                                    (list styleObj fontPath)))
              (if (vl-catch-all-error-p result)
                (alert (strcat "字体写入失败：\r\n" (vl-catch-all-error-message result)))
                (progn
                  (setq resolved (cdr (assoc 3 (tblsearch "STYLE" *ztf-style-name*))))
                  (if (or (not (wcmatch (strcase fontName) "*.SHX"))
                          (and (= (type resolved) 'STR)
                               (= (strcase resolved) (strcase fontPath))))
                    (progn
                      (setq doc (vla-get-ActiveDocument (vlax-get-acad-object)))
                      (vla-Regen doc 1)
                      (alert (strcat "已将样式“" *ztf-style-name*
                                     "”的字体改为：\r\n" (car *ztf-selected-font*))))
                    (alert "字体已写入，但样式保存的字体引用与预期不一致，请在 STYLE 中检查。"))))
              (vlax-release-object styleObj))
            (alert "找不到所选文字样式。")))))
    (alert "请先选择文字样式和字体。")))

(defun ztf:run-dialog (/ dclPath dclId status styles styleIndex)
  (setq dclPath (ztf:locate-dcl))
  (if (not dclPath)
    (progn
      (alert "找不到 ZTF.dcl。请把项目目录加入 ZWCAD 的支持文件搜索路径。")
      nil)
    (progn
      (setq styles (ztf:style-names)
            *ztf-all-styles* styles)
      (if (not (member *ztf-style-name* styles))
        (setq *ztf-style-name* (getvar "TEXTSTYLE")))
      (setq dclId (load_dialog dclPath))
      (if (and (> dclId 0) (new_dialog "ztf_main" dclId))
        (progn
          (ztf:refresh-style-list "")
          (ztf:refresh-font-list "")
          (action_tile "style_search" "(ztf:refresh-style-list $value)")
          (action_tile "style_list"
            "(if (nth (atoi $value) *ztf-filtered-styles*) (ztf:update-style-info (nth (atoi $value) *ztf-filtered-styles*)))")
          (action_tile "font_search" "(ztf:refresh-font-list $value)")
          (action_tile "font_list"
            "(if (nth (atoi $value) *ztf-filtered-fonts*) (progn (setq *ztf-selected-font* (nth (atoi $value) *ztf-filtered-fonts*)) (set_tile \"font_path\" (cdr *ztf-selected-font*))) (set_tile \"font_path\" \"\"))")
          (action_tile "pick_style" "(done_dialog 2)")
          (action_tile "apply" "(ztf:apply-font)")
          (action_tile "cancel" "(done_dialog 0)")
          (setq status (start_dialog)))
        (setq status 0))
      (if (> dclId 0) (unload_dialog dclId))
      status)))

(defun c:ZTF (/ *error* aa:tag aa:doc aa:undo-open aa:old-cmdecho ent ed status)
  (aa:cmd-begin "ZTF")
  (setq *ztf-style-name* (getvar "TEXTSTYLE"))
  (setq *ztf-font-records* (ztf:collect-font-records))
  (while (= (setq status (ztf:run-dialog)) 2)
    (if (setq ent (entsel "\r\n选择一段文字以读取其文字样式："))
      (progn
        (setq ed (entget (car ent)))
        (if (member (cdr (assoc 0 ed)) '("TEXT" "MTEXT"))
          (setq *ztf-style-name* (cdr (assoc 7 ed)))
          (princ "\r\n所选对象不是 TEXT 或 MTEXT。")))
      (princ "\r\n未选择文字。")))
  (aa:cmd-end)
)

(defun aa:set-entity-aci-color (ename color / ed cur-c)
  (if (setq ed (entget ename))
    (progn
      (setq cur-c (assoc 62 ed))
      ;; 若已经是目标颜色且无 420/430 真彩色覆盖，直接跳过 entmod，极大提升批量处理速度
      (if (and cur-c
               (= (cdr cur-c) color)
               (not (assoc 420 ed))
               (not (assoc 430 ed)))
        T
        (progn
          (setq ed
            (vl-remove-if
              '(lambda (item) (member (car item) '(420 430)))
              ed))
          (if cur-c
            (setq ed (subst (cons 62 color) cur-c ed))
            (setq ed (append ed (list (cons 62 color)))))
          (if (entmod ed) T nil))))
    nil)
)

(defun aa:try-get-bbox (vla_obj / min_pt max_pt result)
  (setq result
         (vl-catch-all-apply
           'vla-getboundingbox
           (list vla_obj 'min_pt 'max_pt)))
  (if (not (vl-catch-all-error-p result))
    (list (vlax-safearray->list min_pt)
          (vlax-safearray->list max_pt))
  )
)

(defun aa:safe-get-bbox (doc ename / vla_obj bbox)
  (if (and ename
           (setq vla_obj (vlax-ename->vla-object ename)))
    (progn
      (setq bbox (aa:try-get-bbox vla_obj))
      (if (null bbox)
        (progn
          (vl-catch-all-apply 'vla-update (list vla_obj))
          (entupd ename)
          (setq bbox (aa:try-get-bbox vla_obj))
        )
      )
      (if (and (null bbox) doc)
        (progn
          (vl-catch-all-apply 'vla-regen (list doc 0))
          (setq bbox (aa:try-get-bbox vla_obj))
        )
      )
      (vlax-release-object vla_obj)
      bbox
    )
  )
)

(defun aa:bbox-center-x (bbox)
  (/ (+ (car (car bbox))
        (car (cadr bbox)))
     2.0)
)

(defun aa:bbox-left-x (bbox)
  (car (car bbox))
)

(defun aa:bbox-right-x (bbox)
  (car (cadr bbox))
)

(defun aa:bbox-top-y (bbox)
  (cadr (cadr bbox))
)

(defun aa:bbox-bottom-y (bbox)
  (cadr (car bbox))
)

(defun aa:safe-move-entity (ename move_vec / vla_obj vec_pt result)
  (if (and ename
           move_vec
           (setq vla_obj (vlax-ename->vla-object ename)))
    (progn
      (setq vec_pt (if (= (type move_vec) 'LIST)
                     (vlax-3d-point move_vec)
                     move_vec))
      (setq result
             (vl-catch-all-apply
               'vla-move
               (list vla_obj
                     (vlax-3d-point '(0.0 0.0 0.0))
                     vec_pt)))
      (vlax-release-object vla_obj)
      (if (not (vl-catch-all-error-p result))
        (progn
          (entupd ename)
          T
        )
        nil
      )
    )
  )
)

(defun aa:find-ref-by-left-bbox (doc ss / i ename bbox ref-ename ref-bbox)
  (setq i         0
        ref-ename nil
        ref-bbox  nil)
  (repeat (sslength ss)
    (setq ename (ssname ss i)
          bbox  (aa:safe-get-bbox doc ename))
    (if bbox
      (if (or (null ref-bbox)
              (< (aa:bbox-left-x bbox)
                 (aa:bbox-left-x ref-bbox)))
        (setq ref-ename ename
              ref-bbox  bbox))
    )
    (setq i (1+ i))
  )
  (if ref-bbox
    (list ref-ename ref-bbox))
)

(defun aa:find-ref-by-right-bbox (doc ss / i ename bbox ref-ename ref-bbox)
  (setq i         0
        ref-ename nil
        ref-bbox  nil)
  (repeat (sslength ss)
    (setq ename (ssname ss i)
          bbox  (aa:safe-get-bbox doc ename))
    (if bbox
      (if (or (null ref-bbox)
              (> (aa:bbox-right-x bbox)
                 (aa:bbox-right-x ref-bbox)))
        (setq ref-ename ename
              ref-bbox  bbox))
    )
    (setq i (1+ i))
  )
  (if ref-bbox
    (list ref-ename ref-bbox))
)

(defun aa:find-ref-by-top-bbox (doc ss / i ename bbox ref-ename ref-bbox)
  (setq i         0
        ref-ename nil
        ref-bbox  nil)
  (repeat (sslength ss)
    (setq ename (ssname ss i)
          bbox  (aa:safe-get-bbox doc ename))
    (if bbox
      (if (or (null ref-bbox)
              (> (aa:bbox-top-y bbox)
                 (aa:bbox-top-y ref-bbox)))
        (setq ref-ename ename
              ref-bbox  bbox))
    )
    (setq i (1+ i))
  )
  (if ref-bbox
    (list ref-ename ref-bbox))
)

(defun aa:find-ref-by-bottom-bbox (doc ss / i ename bbox ref-ename ref-bbox)
  (setq i         0
        ref-ename nil
        ref-bbox  nil)
  (repeat (sslength ss)
    (setq ename (ssname ss i)
          bbox  (aa:safe-get-bbox doc ename))
    (if bbox
      (if (or (null ref-bbox)
              (< (aa:bbox-bottom-y bbox)
                 (aa:bbox-bottom-y ref-bbox)))
        (setq ref-ename ename
              ref-bbox  bbox))
    )
    (setq i (1+ i))
  )
  (if ref-bbox
    (list ref-ename ref-bbox))
)

(defun aa:align-text-horizontal-by-bbox (doc ename base-x mode / bbox current-x delta-x)
  (if (setq bbox (aa:safe-get-bbox doc ename))
    (progn
      (setq current-x (cond
                        ((= mode 3) (aa:bbox-right-x bbox))
                        ((= mode 2) (aa:bbox-center-x bbox))
                        (T (aa:bbox-left-x bbox)))
            delta-x   (- base-x current-x))
      (if (equal delta-x 0.0 1e-8)
        T
        (aa:safe-move-entity ename (vlax-3d-point (list delta-x 0.0 0.0)))))
  )
)

(defun aa:align-text-vertical-by-bbox (doc ename base-y mode / bbox current-y delta-y)
  (if (setq bbox (aa:safe-get-bbox doc ename))
    (progn
      (setq current-y (if (= mode 1)
                        (aa:bbox-top-y bbox)
                        (aa:bbox-bottom-y bbox))
            delta-y   (- base-y current-y))
      (if (equal delta-y 0.0 1e-8)
        T
        (aa:safe-move-entity ename (vlax-3d-point (list 0.0 delta-y 0.0)))))
  )
)


;;; =======================================================================================
(defun aa:str-replace-all (old new str / start pos result old-len)
  (setq str     (if str str "")
        start   0
        result  ""
        old-len (strlen old))
  (if (= old-len 0)
    str
    (progn
      (while (setq pos (vl-string-search old str start))
        (setq result
               (strcat
                 result
                 (if (> pos start)
                   (substr str (1+ start) (- pos start))
                   "")
                 new)
              start (+ pos old-len))
      )
      (strcat result (substr str (1+ start)))
    )
  )
)

(defun aa:ysdl-get-raw-text (edata / etype raw pair)
  (setq etype (cdr (assoc 0 edata))
        raw   "")
  (cond
    ((= etype "MTEXT")
     (foreach pair edata
       (if (or (= (car pair) 3) (= (car pair) 1))
         (setq raw (strcat raw (cdr pair)))
       )
     )
    )
    (T
     (setq raw (cdr (assoc 1 edata)))
    )
  )
  (if raw raw "")
)

(defun aa:ysdl-strip-mtext-format (str / idx len out ch next semi stack)
  (setq str (if str str "")
        idx 1
        len (strlen str)
        out "")
  (while (<= idx len)
    (setq ch (substr str idx 1))
    (cond
      ((or (= ch "{") (= ch "}"))
       (setq idx (1+ idx)))
      ((/= ch "\\")
       (setq out (strcat out ch)
             idx (1+ idx)))
      ((= idx len)
       (setq idx (1+ idx)))
      (T
       (setq next (substr str (1+ idx) 1))
       (cond
         ((or (= next "\\") (= next "{") (= next "}"))
          (setq out (strcat out next)
                idx (+ idx 2)))
         ;; \P 为换行、\~ 为不间断空格，转成空格
         ((or (= next "P") (= next "~"))
          (setq out (strcat out " ")
                idx (+ idx 2)))
         ;; \p 是段落格式码(缩进/对齐等，如 \pi23.89632;、\pxi-2,l0,t0;、\pxqc;)，
         ;; 参数一直延续到分号结束，必须整段丢弃；否则会残留 "i23.89632;" 之类垃圾字符
         ((= next "p")
          (setq semi (vl-string-search ";" str (+ idx 1)))
          (setq idx (if semi (+ semi 2) (+ idx 2))))
         ((or (= next "L") (= next "l")
              (= next "O") (= next "o")
              (= next "K") (= next "k")
              (= next "X"))
          (setq idx (+ idx 2)))
         ((= next "S")
          (setq semi (vl-string-search ";" str (+ idx 1)))
          (if semi
            (progn
              (setq stack (substr str (+ idx 2) (- semi idx 1)))
              (setq stack (aa:str-replace-all "#" "/" stack))
              (setq stack (aa:str-replace-all "^" "/" stack))
              (setq out (strcat out stack)
                    idx (+ semi 2)))
            (setq idx (+ idx 2))
          )
         )
         ((or (= next "A") (= next "C") (= next "c")
              (= next "F") (= next "f")
              (= next "H") (= next "Q")
              (= next "T") (= next "W"))
          (setq semi (vl-string-search ";" str (+ idx 1)))
          (if semi
            (setq idx (+ semi 2))
            (setq idx (+ idx 2))
          )
         )
         (T
          (setq out (strcat out next)
                idx (+ idx 2)))
       )
      )
    )
  )
  out
)

(defun aa:ysdl-get-plain-text (edata / raw)
  (setq raw (aa:ysdl-get-raw-text edata))
  (if (= (cdr (assoc 0 edata)) "MTEXT")
    (setq raw (aa:ysdl-strip-mtext-format raw))
  )
  raw
)

(defun aa:ysdl-needs-text-formula (str / first)
  (and str
       (> (strlen str) 0)
       (setq first (substr str 1 1))
       (or (= first "=") (= first "+") (= first "-") (= first "@")))
)

(defun aa:ysdl-build-csv-field (cell / field)
  (setq field (if cell cell ""))
  (if (aa:ysdl-needs-text-formula field)
    (setq field (strcat (chr 9) field))
  )
  (setq field (aa:str-replace-all "\"" "\"\"" field))
  (strcat "\"" field "\"")
)

(defun aa:ysdl-clean-text (str / s)
  (setq s (if str str ""))
  (if (vl-string-search "至" s)
    (setq s (aa:str-replace-all "至" "" s))
  )
  (vl-string-trim " \t\r\n" s)
)

(defun aa:ysdl-reorder-row (row / c0 c1 c2 c3 c4 rest)
  (if (>= (length row) 5)
    (progn
      (setq c0 (nth 0 row)   ; 原第1列: 起点
            c1 (nth 1 row)   ; 原第2列: 电缆编号
            c2 (nth 2 row)   ; 原第3列: 终点
            c3 (nth 3 row)   ; 原第4列: 电缆型号
            c4 (nth 4 row)   ; 原第5列: 芯数
            rest row)
      (repeat 5
        (if rest (setq rest (cdr rest))))
      ;; 重排后前五列: 1-电缆编号, 2-芯数, 3-电缆型号, 4-起点, 5-终点，后续列保持原样
      (append (list c1 c4 c3 c0 c2) rest)
    )
    row
  )
)

;;; =======================================================================================
;;; YSDL 辅助函数: 多分类矩形框与行数据处理
;;; =======================================================================================

(defun aa:ysdl-get-lwpoly-rect (ent / edata closed pts has-bulge pair p x y min-x max-x min-y max-y w h ok z)
  (if (and ent (setq edata (entget ent)) (= (cdr (assoc 0 edata)) "LWPOLYLINE"))
    (progn
      (setq closed (/= 0 (logand 1 (cond ((cdr (assoc 70 edata))) (0))))
            pts    '()
            has-bulge nil
            z      (cond ((cdr (assoc 38 edata))) (0.0)))
      (foreach pair edata
        (cond
          ((= (car pair) 10)
           (setq p (trans (list (cadr pair) (caddr pair) z) ent 0))
           (setq pts (cons (list (car p) (cadr p)) pts)))
          ((= (car pair) 42)
           (if (> (abs (cdr pair)) 1e-4)
             (setq has-bulge T)))
        )
      )
      (setq pts (reverse pts))
      (if (and (not has-bulge) (>= (length pts) 4))
        (progn
          (if (and (>= (length pts) 5) (equal (car pts) (last pts) 1e-4))
            (setq pts (reverse (cdr (reverse pts)))
                  closed T)
          )
          (if (and closed (= (length pts) 4))
            (progn
              (setq min-x (car (car pts))
                    max-x (car (car pts))
                    min-y (cadr (car pts))
                    max-y (cadr (car pts)))
              (foreach p (cdr pts)
                (setq x (car p)
                      y (cadr p))
                (if (< x min-x) (setq min-x x))
                (if (> x max-x) (setq max-x x))
                (if (< y min-y) (setq min-y y))
                (if (> y max-y) (setq max-y y))
              )
              (setq w (- max-x min-x)
                    h (- max-y min-y))
              (if (and (<= 4800.0 w 5200.0)
                       (<= 4800.0 h 5200.0))
                (progn
                  (setq ok T)
                  (foreach p pts
                    (setq x (car p)
                          y (cadr p))
                    (if (not (and (or (<= (abs (- x min-x)) 50.0)
                                      (<= (abs (- x max-x)) 50.0))
                                  (or (<= (abs (- y min-y)) 50.0)
                                      (<= (abs (- y max-y)) 50.0))))
                      (setq ok nil)
                    )
                  )
                  (if ok
                    (list min-x min-y max-x max-y)
                  )
                )
              )
            )
          )
        )
      )
    )
  )
)

(defun aa:ysdl-sort-boxes (boxes / sorted out band anchor tol box)
  (if boxes
    (progn
      ;; 1. 按顶边 Y 降序排序 (从上到下)
      (setq sorted (aa:merge-sort boxes '(lambda (a b) (> (nth 3 a) (nth 3 b)))))
      (setq out '())
      (while sorted
        (setq box    (car sorted)
              sorted (cdr sorted)
              band   (list box)
              anchor (nth 3 box)
              tol    1000.0)
        (while (and sorted (<= (abs (- (nth 3 (car sorted)) anchor)) tol))
          (setq band   (cons (car sorted) band)
                sorted (cdr sorted))
        )
        ;; 同一行内按左边 X 升序排序 (从左到右)
        (setq band (aa:merge-sort band '(lambda (a b) (< (car a) (car b)))))
        (foreach box band
          (setq out (cons box out))
        )
      )
      (reverse out)
    )
    '()
  )
)

(defun aa:ysdl-parse-rows-from-text-data (text-data-list fuzz / sorted-by-y all-rows cur-row-items base-y item current-y)
  (if text-data-list
    (progn
      (setq sorted-by-y
             (aa:merge-sort text-data-list
                      '(lambda (a b)
                         (> (caddr a) (caddr b))
                       )
             )
      )
      (setq all-rows      '()
            cur-row-items '()
            base-y        nil)
      (foreach item sorted-by-y
        (setq current-y (caddr item))
        (if (or (null base-y) (<= (abs (- current-y base-y)) fuzz))
          (progn
            (setq cur-row-items (cons item cur-row-items))
            (if (null base-y) (setq base-y current-y))
          )
          (progn
            (setq cur-row-items (aa:merge-sort cur-row-items '(lambda (a b) (< (cadr a) (cadr b)))))
            (setq all-rows (cons (mapcar 'car cur-row-items) all-rows))
            (setq cur-row-items (list item)
                  base-y        current-y)
          )
        )
      )
      (if cur-row-items
        (progn
          (setq cur-row-items (aa:merge-sort cur-row-items '(lambda (a b) (< (cadr a) (cadr b)))))
          (setq all-rows (cons (mapcar 'car cur-row-items) all-rows))
        )
      )
      (reverse all-rows)
    )
    '()
  )
)

(defun aa:ysdl-format-categorized-row (raw-row title-str seq-str / c0 reordered)
  (setq c0 (if (>= (length raw-row) 1) (nth 0 raw-row) ""))
  (setq reordered (aa:ysdl-reorder-row raw-row))
  (cons title-str (cons seq-str (cons c0 reordered)))
)

;; YSDL 导出目录：优先取系统真实桌面（兼容桌面重定向到 D 盘/OneDrive），
;; 读取失败或目录不存在时回退 %USERPROFILE%\Desktop；都不可用返回 nil。
(defun aa:ysdl-desktop-dir (/ dir up)
  (setq dir (vl-catch-all-apply
              'vl-registry-read
              (list "HKEY_CURRENT_USER\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Shell Folders"
                    "Desktop")))
  (if (not (and (= (type dir) 'STR) (/= dir "") (vl-file-directory-p dir)))
    (progn
      (setq up  (getenv "USERPROFILE")
            dir nil)
      (if (and up (/= up "") (vl-file-directory-p (strcat up "\\Desktop")))
        (setq dir (strcat up "\\Desktop"))
      )
    )
  )
  (if dir (vl-string-right-trim "\\/" dir))
)

;;; 命令: YSDL
;;; 功能: 提取图纸电缆文字，按行导出到桌面CSV文件并改变文字颜色。
;;;       支持5000x5000闭合多段线分类框与500字高标题空间识别，增加分类、序号、安装单位名称列；
;;;       未检测到分类框时自动平滑回退为传统无分类电缆导出逻辑。
;;; =======================================================================================
(defun c:YSDL (/ aa:doc aa:undo-open *error* ss i ent edata typ text-string ins-point h
               text-data-list ename-list box-list box sorted-boxes
               fuzz desktop-dir csv-path f file-mode action-msg targetColor
               all-rows row line-str cell cell-safe
               min-x min-y max-x max-y box-texts item x y
               title-items cable-items title-str box-rows
               cur-seq prev-start start-dev seq-str full-row raw-row
               total-exported-rows exported-enames ename)

  ;; 自定义错误处理函数
  (defun *error* (msg)
    (aa:undo-mark-off)
    (if (and f (= (type f) 'FILE))
      (close f)
    )
    (if (not (wcmatch (strcase msg) "*CANCEL*,*QUIT*"))
      (princ (strcat "\r\n发生错误: " msg))
    )
    (princ)
  )

  (aa:undo-mark-on)
  ;; 从全局配置获取容差值
  (setq fuzz *YSDL_RowFuzz*)

  ;; 1. 提示用户选择图纸对象（支持框选包含5000x5000分类框及电缆文字）
  (princ "\r\n请选择图纸对象（支持5000x5000分类框及电缆文字）: ")
  (setq ss (ssget '((0 . "TEXT,MTEXT,LWPOLYLINE"))))

  (if ss
    (progn
      ;; 2. 遍历选择集，提取文字数据与5000x5000分类框
      (setq text-data-list '()
            ename-list     '()
            box-list       '()
            i              0)
      (repeat (sslength ss)
        (setq ent   (ssname ss i)
              edata (entget ent)
              typ   (cdr (assoc 0 edata)))
        (cond
          ((member typ '("TEXT" "MTEXT"))
           (setq text-string (aa:ysdl-get-plain-text edata)
                 ins-point   (cdr (assoc 10 edata))
                 h           (cond ((cdr (assoc 40 edata))) (0.0)))
           ;; 数据格式: (text-string x y ename height)
           (setq text-data-list (cons (list text-string (car ins-point) (cadr ins-point) ent h) text-data-list)
                 ename-list     (cons ent ename-list))
          )
          ((= typ "LWPOLYLINE")
           (if (setq box (aa:ysdl-get-lwpoly-rect ent))
             (if (not (vl-some '(lambda (b) (equal b box 1.0)) box-list))
               (setq box-list (cons box box-list))
             )
           )
          )
        )
        (setq i (1+ i))
      )

      ;; 3. 确定是否进入分类框模式
      (setq sorted-boxes (if box-list (aa:ysdl-sort-boxes box-list) nil))

      ;; 4. 自动定位桌面路径并准备写入CSV文件
      (setq desktop-dir (aa:ysdl-desktop-dir))
      (if desktop-dir
        (progn
          (setq csv-path (strcat desktop-dir "\\" *YSDL_CsvFileName*))
          (if (findfile csv-path)
            (setq file-mode "a" action-msg "数据已成功追加到桌面文件:\r\n")
            (setq file-mode "w" action-msg "已在桌面成功创建文件:\r\n")
          )

          (setq f (open csv-path file-mode)
                total-exported-rows 0
                exported-enames     '())

          (if (not f)
            ;; 打开失败（文件被 Excel/WPS 占用、无写权限或被安全软件拦截）：提示并停止，不改文字颜色
            (progn
              (princ (strcat "\r\n[YSDL] 无法写入 CSV 文件: " csv-path))
              (alert (strcat "无法写入 CSV 文件:\r\n" csv-path
                             "\r\n\r\n可能原因:"
                             "\r\n1. 该文件正在 Excel/WPS 中打开（被占用），请关闭后重试；"
                             "\r\n2. 桌面目录无写入权限，或被安全软件拦截。"
                             "\r\n\r\n本次未导出数据，也未修改文字颜色。"))
            )
            (progn
              (if sorted-boxes
                ;; 模式A: 多分类框识别导出 (R1, R2, R3)
                (foreach box sorted-boxes
                  (setq min-x (nth 0 box)
                        min-y (nth 1 box)
                        max-x (nth 2 box)
                        max-y (nth 3 box))
                  ;; 检索框内文字
                  (setq box-texts '())
                  (foreach item text-data-list
                    (setq x (cadr item)
                          y (caddr item))
                    (if (and (>= x (- min-x 1e-4))
                             (<= x (+ max-x 1e-4))
                             (>= y (- min-y 1e-4))
                             (<= y (+ max-y 1e-4)))
                      (setq box-texts (cons item box-texts))
                    )
                  )
                  ;; 分离字高500 (470~530) 的标题文字与电缆文字
                  (setq title-items '()
                        cable-items '())
                  (foreach item box-texts
                    (setq h (nth 4 item))
                    (if (<= 470.0 h 530.0)
                      (setq title-items (cons item title-items))
                      (setq cable-items (cons item cable-items))
                    )
                  )
                  ;; 提取分类名称
                  (setq title-str "")
                  (if title-items
                    (progn
                      (setq title-items (aa:merge-sort title-items '(lambda (a b) (> (caddr a) (caddr b)))))
                      (setq title-str (vl-string-trim " \t\r\n" (car (car title-items))))
                    )
                  )
                  ;; 行解析与聚类序号编排 (切换分类后序号重置为 1)
                  (setq box-rows   (aa:ysdl-parse-rows-from-text-data cable-items fuzz)
                        cur-seq    0
                        prev-start nil)
                  (foreach raw-row box-rows
                    (setq start-dev (if (>= (length raw-row) 1)
                                      (aa:ysdl-clean-text (nth 0 raw-row))
                                      ""))
                    (if (or (null prev-start) (/= start-dev prev-start))
                      (setq cur-seq    (1+ cur-seq)
                            prev-start start-dev)
                    )
                    (setq seq-str  (itoa cur-seq)
                          full-row (aa:ysdl-format-categorized-row raw-row title-str seq-str)
                          line-str "")
                    (foreach cell full-row
                      (setq cell (aa:ysdl-clean-text cell))
                      (setq cell-safe (aa:ysdl-build-csv-field cell))
                      (setq line-str (strcat line-str cell-safe ","))
                    )
                    (if (> (strlen line-str) 0)
                      (setq line-str (substr line-str 1 (1- (strlen line-str))))
                    )
                    (write-line line-str f)
                    (setq total-exported-rows (1+ total-exported-rows))
                  )
                  ;; 记录该框内文字（包含电缆文字与标题文字）
                  (foreach item box-texts
                    (setq exported-enames (cons (nth 3 item) exported-enames))
                  )
                )
                ;; 模式B: 平滑兼容回退传统无分类模式 (无5000x5000框)
                (progn
                  (setq all-rows (aa:ysdl-parse-rows-from-text-data text-data-list fuzz))
                  (foreach raw-row all-rows
                    (setq row      (aa:ysdl-reorder-row raw-row)
                          line-str "")
                    (foreach cell row
                      (setq cell (aa:ysdl-clean-text cell))
                      (setq cell-safe (aa:ysdl-build-csv-field cell))
                      (setq line-str (strcat line-str cell-safe ","))
                    )
                    (if (> (strlen line-str) 0)
                      (setq line-str (substr line-str 1 (1- (strlen line-str))))
                    )
                    (write-line line-str f)
                    (setq total-exported-rows (1+ total-exported-rows))
                  )
                  (setq exported-enames ename-list)
                )
              )
              (close f)
              (setq f nil)

              ;; 5. 快速修改已导出文字的颜色
              (setq targetColor *YSDL_TextColor*)
              (foreach ename exported-enames
                (aa:set-entity-aci-color ename targetColor)
              )
              (redraw)

              (if sorted-boxes
                (princ (strcat "\r\n[YSDL] " action-msg csv-path " (已识别 " (itoa (length sorted-boxes)) " 个分类框，共导出 " (itoa total-exported-rows) " 行数据)。"))
                (princ (strcat "\r\n[YSDL] " action-msg csv-path " (未检测到分类框，已回退为常规模式，共导出 " (itoa total-exported-rows) " 行数据)。"))
              )
              (alert (strcat action-msg csv-path "\r\n\r\n已成功导出 " (itoa total-exported-rows) " 行数据，所有选中文字颜色已更改。"))
            )
          )
        )
        (alert "错误: 无法获取桌面路径（注册表 Shell Folders 与 %USERPROFILE%\\Desktop 均不可用）!")
      )
    )
    (princ "\r\n未选择任何对象。")
  )
  (aa:undo-mark-off)
  (princ)
)


;;; =======================================================================================
;;; 命令: LONG
;;; 功能: 计算所有选定多段线（Polyline 和 LWPolyline）的总长度。
;;; =======================================================================================

;;; =======================================================================================
;;; 命令: Q
;;; 功能: 快速选择。在已有的选择集中，仅保留文字类型的对象。
;;; =======================================================================================
(defun c:q (/ *error* aa:tag aa:doc aa:undo-open aa:old-cmdecho ss i ent txt)
  (aa:cmd-begin "Q")
  (setq ss (ssget))
  (if ss
    (progn
      (setq txt (ssadd))
      (setq i 0)
      (while (< i (sslength ss))
        (setq ent (ssname ss i))
        (if (wcmatch (cdr (assoc 0 (entget ent))) "*TEXT")
          (ssadd ent txt)
        )
        (setq i (1+ i))
      )
      
      (if (> (sslength txt) 0)
        (progn
          (sssetfirst nil txt)
          (princ (strcat "\r\n已选择 " (itoa (sslength txt)) " 个文字对象"))
        )
        (princ "\r\n所选对象中没有找到文字对象")
      )
    )
    (princ "\r\n未选择任何对象")
  )
  (aa:cmd-end)
)



;;; =======================================================================================
;;; Command: T
;;; Purpose: Filter TEXT/MTEXT/ATTDEF, explode MTEXT, set HZ/3/0.7, and preserve
;;;          the visible anchor of justified TEXT/ATTDEF even with stale alignment points.
;;; =======================================================================================
(defun txt:set-dxf (code value data / item)
  (if (setq item (assoc code data))
    (subst (cons code value) item data)
    (append data (list (cons code value)))
  )
)

;; 按实际可见范围定位，避免旧 DXF 11 对齐点与显示位置不一致时跳位。
;; 水平文字保留相应的左/中/右、下/中/上边界；旋转/倾斜平面保留范围中心。
(defun txt:bbox-anchor (edata bbox / lo hi h v centered)
  (setq lo (car bbox)
        hi (cadr bbox)
        h  (cdr (assoc 72 edata))
        v  (cdr (assoc (if (= (cdr (assoc 0 edata)) "ATTDEF") 74 73) edata))
        centered (or (not (equal (cdr (assoc 50 edata)) 0.0 1e-8))
                     (and (assoc 210 edata)
                          (not (equal (cdr (assoc 210 edata)) '(0.0 0.0 1.0) 1e-8)))))
  (if (not h) (setq h 0))
  (if (not v) (setq v 0))
  (list
    (cond
      (centered (/ (+ (car lo) (car hi)) 2.0))
      ((= h 0) (car lo))
      ((= h 2) (car hi))
      (T (/ (+ (car lo) (car hi)) 2.0)))
    (cond
      ((or centered (= h 4) (= v 2)) (/ (+ (cadr lo) (cadr hi)) 2.0))
      ((= v 3) (cadr hi))
      (T (cadr lo)))
    (/ (+ (caddr lo) (caddr hi)) 2.0))
)

(defun txt:modify-text (ename / edata original aligned vcode oldbox newbox delta ok)
  (if (and ename (member (cdr (assoc 0 (setq edata (entget ename)))) '("TEXT" "ATTDEF")))
    (progn
      (setq original edata
            vcode (if (= (cdr (assoc 0 edata)) "ATTDEF") 74 73)
            aligned (or (and (assoc 72 edata) (/= (cdr (assoc 72 edata)) 0))
                        (and (assoc vcode edata) (/= (cdr (assoc vcode edata)) 0))))
      ;; 普通左基线文字直接 entmod；对齐文字先缓存实际显示范围。
      (if aligned (setq oldbox (aa:safe-get-bbox nil ename)))
      (if (or (not aligned) oldbox)
        (progn
          (setq edata (txt:set-dxf 7 "HZ" edata))
          (setq edata (txt:set-dxf 40 3.0 edata))
          (setq edata (txt:set-dxf 41 0.7 edata))
          (setq ok (entmod edata))
          (if (and ok aligned)
            (progn
              ;; 必须刷新后读取新几何，不能沿用修改前的缓存范围。
              (entupd ename)
              (setq newbox (aa:safe-get-bbox nil ename))
              (if newbox
                (progn
                  (setq delta (mapcar '- (txt:bbox-anchor original oldbox)
                                         (txt:bbox-anchor original newbox)))
                  ;; COM Move 使用 WCS 位移并同步维护插入点、对齐点。
                  (setq ok (or (equal delta '(0.0 0.0 0.0) 1e-8)
                               (aa:safe-move-entity ename delta))))
                (setq ok nil))
              (if (not ok)
                (progn
                  (entmod original)
                  (princ "\r\n对齐文字位置补偿失败，已恢复原文字数据。")))))
          (if ok 1 0))
        (progn
          (princ "\r\n无法读取对齐文字范围，已跳过以避免跳位。")
          0)))
    0)
)

(defun txt:modify-new-texts (before after / cur count)
  (setq count 0)
  (if (and after (not (eq before after)))
    (progn
      (setq cur (if before (entnext before) (entnext)))
      (while cur
        (if (= "TEXT" (cdr (assoc 0 (entget cur))))
          (setq count (+ count (txt:modify-text cur)))
        )
        (if (eq cur after)
          (setq cur nil)
          (setq cur (entnext cur))
        )
      )
    )
  )
  count
)

(defun txt:process-selection (sel / *error* oldcmdecho total i ename etype mtss mtlist before after count)
  (defun *error* (msg)
    (if oldcmdecho
      (setvar "CMDECHO" oldcmdecho)
    )
    (if (and msg (/= msg "Function cancelled") (/= msg "quit / exit abort"))
      (princ (strcat "\r\n错误: " msg))
    )
    (princ)
  )

  (setq oldcmdecho (getvar "CMDECHO"))
  (setvar "CMDECHO" 0)
  (setq total  (sslength sel)
        mtss   (ssadd)
        mtlist '()
        count  0
        i      0)

  ;; Modify TEXT/ATTDEF in place; preserve attribute tag, prompt and flags.
  (while (< i total)
    (setq ename (ssname sel i)
          etype (cdr (assoc 0 (entget ename))))
    (cond
      ((member etype '("TEXT" "ATTDEF"))
       (setq count (+ count (txt:modify-text ename))))
      ((= etype "MTEXT")
       (ssadd ename mtss)
       (setq mtlist (cons ename mtlist)))
    )
    (setq i (1+ i))
  )

  ;; Explode all MTEXT objects in one native command invocation.
  (if (> (sslength mtss) 0)
    (progn
      (setq before (entlast))
      (command "_.explode" mtss "")

      ;; Retry only objects left behind by CAD versions that do not accept a
      ;; multi-object selection set from AutoLISP EXPLODE.
      (foreach ename mtlist
        (if (= "MTEXT" (cdr (assoc 0 (entget ename))))
          (command "_.explode" ename)
        )
      )

      ;; Process the new database range directly; do not copy it into a list
      ;; or reselect every result, both of which are costly in ZWCAD.
      (setq after (entlast)
            count (+ count (txt:modify-new-texts before after)))
    )
  )

  (redraw)
  (setvar "CMDECHO" oldcmdecho)
  (princ (strcat "\r\n已处理文字数量: " (itoa count)))
  count
)

(defun txt:run (/ sel)
  (vl-load-com)
  (if (null (tblsearch "STYLE" "HZ"))
    (princ "\r\n未找到文字样式 HZ。")
    (progn
      (setq sel (ssget '((0 . "TEXT,MTEXT,ATTDEF"))))
      (if sel
        (txt:process-selection sel)
        (princ "\r\n未选择任何对象。")
      )
    )
  )
  (princ)
)

(defun c:T (/ *error* aa:tag aa:doc aa:undo-open aa:old-cmdecho)
  (aa:cmd-begin "T")
  (txt:run)
  (aa:cmd-end)
)


;;; =======================================================================================
;;; 命令: ZHU
;;; 功能: 选中端子排名和端子号文字，选短接或拆除连片，生成HZ/3/0.7的“注：”单行文字。
;;; =======================================================================================
(setq *zhu:last-mode* "D") ; (ZHU) 记住上次选择：D=短接，C=拆除连片

(defun zhu:trim (str)
  (if str (vl-string-trim " \t\r\n" str) ""))

;; 去重并按端子号数值从小到大排序；数值相同再按原字符串排。
(defun zhu:sort-nums (nums / out)
  (foreach n nums
    (if (not (member n out)) (setq out (cons n out))))
  (aa:merge-sort out
    '(lambda (a b)
       (if (= (atoi a) (atoi b)) (< a b) (< (atoi a) (atoi b))))))

;; 把文字分成端子号（纯数字）和其他文字（端子排名候选）；返回 (名称列表 . 端子号列表)。
(defun zhu:classify (strs / names nums)
  (foreach s strs
    (setq s (zhu:trim s))
    (cond
      ((= s ""))
      ((aa:nu-string-all-digits-p s) (setq nums (cons s nums)))
      ((not (member s names)) (setq names (cons s names)))))
  (cons (reverse names) (zhu:sort-nums nums)))

;; mode 为 "D" 生成短接注释，"C" 生成拆除连片注释。
(defun zhu:build-note (mode name nums / body)
  (setq body "")
  (foreach n nums
    (setq body (strcat body (if (= body "") "" "、") name ":" n)))
  (if (= mode "C")
    (strcat "注：拆除" body "之间的连接片")
    (strcat "注：短接" body)))

;; 多个非数字文字时让用户点选端子排名，回车则手动输入。
(defun zhu:pick-name (names / sel ed name)
  (princ (strcat "\r\n[ZHU] 所选文字中有 " (itoa (length names)) " 个非数字文字，无法确定端子排名。"))
  (while (and (null name)
              (setq sel (entsel "\r\n[ZHU] 请点选端子排名文字 <手动输入>: ")))
    (setq ed (entget (car sel)))
    (if (wcmatch (cdr (assoc 0 ed)) "TEXT,MTEXT")
      (setq name (zhu:trim (aa:ysdl-get-plain-text ed)))
      (princ "\r\n[ZHU] 选中的不是文字，请重选。")))
  (if (or (null name) (= name ""))
    (setq name (zhu:trim (getstring T "\r\n[ZHU] 输入端子排名: "))))
  name)

(defun c:ZHU (/ *error* aa:tag aa:doc aa:undo-open aa:old-cmdecho
                ss i strs parts names nums name mode pt note)
  (aa:cmd-begin "ZHU")
  (cond
    ((null (tblsearch "STYLE" "HZ"))
     (princ "\r\n[ZHU] 未找到文字样式 HZ。"))
    ((null (setq ss (ssget '((0 . "TEXT,MTEXT")))))
     (princ "\r\n[ZHU] 未选择任何文字。"))
    (T
     (setq i 0)
     (while (< i (sslength ss))
       (setq strs (cons (aa:ysdl-get-plain-text (entget (ssname ss i))) strs)
             i (1+ i)))
     (setq parts (zhu:classify strs)
           names (car parts)
           nums  (cdr parts))
     (setq name (cond
                  ((= (length names) 1) (car names))
                  ((null names) (zhu:trim (getstring T "\r\n[ZHU] 未找到端子排名，请输入: ")))
                  (T (zhu:pick-name names))))
     (cond
       ((< (length nums) 2)
        (princ "\r\n[ZHU] 至少要选两个端子号（纯数字文字）。"))
       ((= name "")
        (princ "\r\n[ZHU] 未指定端子排名。"))
       (T
        (initget "D C")
        (setq mode (getkword (strcat "\r\n[ZHU] 选择 [短接(D)/拆除连片(C)] <"
                                     (if (= *zhu:last-mode* "C") "C" "D") ">: ")))
        (if (null mode) (setq mode (if (= *zhu:last-mode* "C") "C" "D")))
        (setq *zhu:last-mode* mode
              note (zhu:build-note mode name nums))
        (princ (strcat "\r\n[ZHU] " note))
        (if (setq pt (getpoint "\r\n[ZHU] 指定注释文字插入点: "))
          (entmake
            (list '(0 . "TEXT")
                  (cons 8 (getvar "CLAYER"))
                  (cons 10 (trans pt 1 0))
                  (cons 40 3.0)
                  (cons 1 note)
                  '(50 . 0.0)
                  (cons 41 0.7)
                  (cons 7 "HZ")))
          (princ "\r\n[ZHU] 未指定插入点，未生成文字。"))))))
  (aa:cmd-end))

;;; =======================================================================================
;;; 命令: HWT
;;; 功能: 框选一列柜名文字，按从上到下顺序每行最多5个蛇形排列，生成L1/N1端子、SML电缆编号和两端JL进线的环网图，并输出可供BH3登记的电缆清单。
;;; =======================================================================================

;; 每行最多 5 个：行数 = 向上取整(n/5)，各行数量尽量相等，多出的放在前面几行（13 个 -> 5 4 4）。
(defun hwt:row-counts (n / r base extra i out)
  (setq r     (/ (+ n 4) 5)
        base  (/ n r)
        extra (rem n r)
        i     0)
  (while (< i r)
    (setq out (cons (if (< i extra) (1+ base) base) out)
          i   (1+ i)))
  (reverse out))

(defun hwt:cable-no (i)
  (strcat "SML-" (if (< i 10) "0" "") (itoa i)))

;; 两端进线：xo 为线外端，d 为指向柜子的方向（1 向右，-1 向左），线本身由调用方画。
(defun hwt:feeder-items (xo y d no)
  (list (list "T" "2×4" (list (+ xo (* d 3.6)) (+ y 0.8)) 256)
        (list "T" "至交流馈线柜" (list (+ xo (* d 20.5)) (+ y 0.8)) 256)
        (list "P" (list (list (+ xo (* d 29.75)) y)
                        (list (+ xo (* d 34.2)) (+ y 2.575))
                        (list (+ xo (* d 34.2)) (- y 2.575))))
        (list "T" no (list (+ xo (* d 46.5)) (+ y 0.8)) 256)))

;; 柜框三格：柜名 / L1 N1 / JD 端子号，端子号一律默认 1~2、4~5，个别柜子出图后手改。
(defun hwt:box-items (name cx top / hw)
  (setq hw 17.36)
  (list (list "P" (list (list (- cx hw) top) (list (+ cx hw) top)
                        (list (+ cx hw) (- top 18.0)) (list (- cx hw) (- top 18.0))))
        (list "L" (list (- cx hw) (- top 5.0)) (list (+ cx hw) (- top 5.0)) 256)
        (list "L" (list (- cx hw) (- top 10.0)) (list (+ cx hw) (- top 10.0)) 256)
        (list "L" (list cx (- top 5.0)) (list cx (- top 18.0)) 256)
        (list "N" name (list cx (- top 4.0)) 4)
        (list "T" "L1" (list (- cx 8.68) (- top 9.0)) 4)
        (list "T" "N1" (list (+ cx 8.68) (- top 9.0)) 4)
        (list "T" "JD：1~2" (list (- cx 8.68) (- top 15.5)) 4)
        (list "T" "JD：4~5" (list (+ cx 8.68) (- top 15.5)) 4)))

;; 电缆编号与规格：编号在线上方、规格在线下方，pt 为两者的中心位置。
(defun hwt:label-items (no x y dy-no dy-spec)
  (list (list "T" no (list x (+ y dy-no)) 4)
        (list "T" "2×4" (list x (+ y dy-spec)) 4)))

;; 生成全部图元描述，x0 y0 为第一行第一个柜框左上角（WCS）。
;; 描述：("L" p1 p2 颜色) 直线，("C" 圆心 颜色) 端子圆，("D" 圆心) 实心点，
;;       ("P" 点表) 闭合多段线，("T"/"N" 文字 中心 颜色) 居中单行文字（N 为柜名，需按柜宽压缩）。
(defun hwt:layout (names x0 y0 / counts m1 hw p rs q lg sh xc xl xr k cno prev items
                              m s top bot yc yu yl j name cx a yin yout din dout u1 u2
                              in-end out-pt xt ymid xo last-cx)
  (setq counts (hwt:row-counts (length names))
        m1     (car counts)
        hw     17.36
        p      60.76
        rs     45.0
        q      8.68
        lg     10.375
        sh     4.625
        xc     (+ x0 hw (/ (* (1- m1) p) 2.0))
        xr     (+ xc (/ (* (1- m1) p) 2.0) hw 17.5)
        xl     (- xc (/ (* (1- m1) p) 2.0) hw 17.5)
        k      0
        cno    1)
  (foreach m counts
    (setq s   (if (= (rem k 2) 0) 1 -1)
          top (- y0 (* k rs))
          bot (- top 18.0)
          yc  (+ bot 1.5)
          yu  (- yc sh)
          yl  (- yc lg)
          j   0)
    (while (< j m)
      (setq name   (car names)
            names  (cdr names)
            cx     (+ xc (* s (- j (/ (1- m) 2.0)) p))
            items  (append (reverse (hwt:box-items name cx top)) items)
            ;; 行内交替：偶数位从下线进、上线出，奇数位从上线进、下线出；每行第一个都从下线进
            a      (= (rem j 2) 0)
            yin    (if a yl yu)
            yout   (if a yu yl)
            din    (if a lg sh)
            dout   (if a sh lg)
            u1     (- cx (* s q))
            u2     (+ cx (* s q)))
      (foreach u (list u1 u2)
        (setq items (append
                      (list (list "D" (list (+ u (* s dout)) yout))
                            (list "D" (list (- u (* s din)) yin))
                            (list "L" (list u yc) (list (+ u (* s dout)) yout) 256)
                            (list "L" (list u yc) (list (- u (* s din)) yin) 256)
                            (list "C" (list u yc) 7))
                      items)))
      (setq in-end (list (- u2 (* s din)) yin)
            out-pt (list (+ u1 (* s dout)) yout))
      (cond
        ((null prev)
         (setq xo    (- cx (* s (+ hw 61.0)))
               items (append (reverse (cons (list "L" (list xo yin) in-end 3)
                                            (hwt:feeder-items xo yin s "JL-01")))
                             items)))
        ((= j 0)
         (setq xt    (if (= s 1) xl xr)
               ymid  (/ (+ (cadr prev) yin) 2.0)
               items (append (reverse
                               (append
                                 (list (list "L" prev (list xt (cadr prev)) 256)
                                       (list "L" (list xt (cadr prev)) (list xt yin) 256)
                                       (list "L" (list xt yin) in-end 256))
                                 (hwt:label-items (hwt:cable-no cno) (+ xt (* s 8.0)) ymid 1.2 -3.8)))
                             items)
               cno   (1+ cno)))
        (T
         (setq items (append (reverse
                               (cons (list "L" prev in-end 256)
                                     (hwt:label-items (hwt:cable-no cno) (- cx (* s (/ p 2.0))) yin 0.8 -3.8)))
                             items)
               cno   (1+ cno))))
      (setq prev    out-pt
            last-cx cx
            j       (1+ j)))
    (setq k (1+ k)))
  (setq xo (+ last-cx (* s (+ hw 61.0))))
  (append (reverse items)
          (cons (list "L" prev (list xo (cadr prev)) 3)
                (hwt:feeder-items xo (cadr prev) (- s) "JL-04"))))

;; 电缆清单行：起点柜、编号、终点柜、规格、芯数、原理号 L1 N1（BH3/HDDL 的清册列顺序）；
;; 首尾两行是交流馈线柜进线 JL-01、JL-04。
(defun hwt:cable-rows (names / out i)
  (setq out (list (list "交流馈线柜" "JL-01" (car names)))
        i   1)
  (while (cdr names)
    (setq out   (cons (list (car names) (hwt:cable-no i) (cadr names)) out)
          names (cdr names)
          i     (1+ i)))
  (setq out (cons (list (car names) "JL-04" "交流馈线柜") out)
        names nil)
  (foreach r out
    (setq names (cons (append r (list "2×4" "2" "L1" "N1")) names)))
  names)

(defun hwt:counts-text (counts / out)
  (foreach c counts
    (setq out (if out (strcat out "/" (itoa c)) (itoa c))))
  out)

(defun hwt:pt3 (p z) (list (car p) (cadr p) z))

;; 闭合多段线；width 为全局宽度，bulge 非空时每段用同一凸度（画实心点）。
(defun hwt:make-pline (pts z width bulge / ed)
  (setq ed (list '(0 . "LWPOLYLINE") '(100 . "AcDbEntity") (cons 8 (getvar "CLAYER"))
                 '(100 . "AcDbPolyline") (cons 90 (length pts)) '(70 . 1)
                 (cons 43 width) (cons 38 z)))
  (foreach p pts
    (setq ed (append ed (list (list 10 (car p) (cadr p)))))
    (if bulge (setq ed (append ed (list (cons 42 bulge))))))
  (entmakex ed))

;; 柜名太长时按柜宽压缩宽度系数，避免压到框线。
(defun hwt:fit-name (e / ed box w)
  (setq ed  (entget e)
        box (textbox ed))
  (if box (setq w (- (car (cadr box)) (car (car box)))))
  (if (and w (> w 32.72))
    (entmod (subst (cons 41 (* 0.7 (/ 32.72 w))) (assoc 41 ed) ed))))

(defun hwt:draw (items z style / k p e)
  (foreach it items
    (setq k (car it))
    (cond
      ((= k "L")
       (entmakex (list '(0 . "LINE") (cons 8 (getvar "CLAYER")) (cons 62 (nth 3 it))
                       (cons 10 (hwt:pt3 (cadr it) z)) (cons 11 (hwt:pt3 (caddr it) z)))))
      ((= k "C")
       (entmakex (list '(0 . "CIRCLE") (cons 8 (getvar "CLAYER")) (cons 62 (caddr it))
                       (cons 10 (hwt:pt3 (cadr it) z)) '(40 . 0.75))))
      ((= k "D")
       (setq p (cadr it))
       (hwt:make-pline (list (list (- (car p) 0.153) (cadr p)) (list (+ (car p) 0.153) (cadr p)))
                       z 0.306 1.0))
      ((= k "P")
       (hwt:make-pline (cadr it) z 0.0 nil))
      ((wcmatch k "T,N")
       (setq p (hwt:pt3 (caddr it) z)
             e (entmakex (list '(0 . "TEXT") (cons 8 (getvar "CLAYER")) (cons 62 (nth 3 it))
                               (cons 10 p) (cons 11 p) '(40 . 3.0) (cons 1 (cadr it))
                               '(50 . 0.0) '(41 . 0.7) (cons 7 style) '(72 . 1) '(73 . 0))))
       (if (and e (= k "N")) (hwt:fit-name e))))))

(defun hwt:text-width (str style / box)
  (setq box (textbox (list '(0 . "TEXT") (cons 1 str) '(40 . 3.0) '(41 . 0.7) (cons 7 style))))
  (if box (- (car (cadr box)) (car (car box))) (* 2.1 (strlen str))))

;; 清单：白色左中对齐、行距 5（同 H/HWD），列宽取该列最长文字、列间空 10，
;; 这样 BH3/HDDL 按高度归行、行内按左右排序就能正确读出每一行。
(defun hwt:draw-list (rows x0 y0 z style / c w xs x y p)
  (setq c 0)
  (while (< c (length (car rows)))
    (setq w 0.0)
    (foreach r rows
      (setq w (max w (hwt:text-width (nth c r) style))))
    (setq xs (cons w xs)
          c  (1+ c)))
  (setq x x0)
  (foreach w (reverse xs)
    (setq p (cons x p)
          x (+ x w 10.0)))
  (setq xs (reverse p)
        y  (- y0 1.5))
  (foreach r rows
    (setq c 0)
    (foreach s r
      (setq p (list (nth c xs) y z))
      (entmakex (list '(0 . "TEXT") (cons 8 (getvar "CLAYER")) '(62 . 7) (cons 10 p) (cons 11 p)
                      '(40 . 3.0) (cons 1 s) '(50 . 0.0) '(41 . 0.7) (cons 7 style) '(72 . 0) '(73 . 2)))
      (setq c (1+ c)))
    (setq y (- y 5.0))))

(defun c:HWT (/ *error* aa:tag aa:doc aa:undo-open aa:old-cmdecho
                ss i ed str pairs names pt style lpt)
  (aa:cmd-begin "HWT")
  (princ "\r\n[HWT] 选择一列柜名文字（从上到下即环网顺序）: ")
  (cond
    ((null (setq ss (ssget '((0 . "TEXT,MTEXT")))))
     (princ "\r\n[HWT] 未选择任何文字。"))
    (T
     (setq i 0)
     (while (< i (sslength ss))
       (setq ed  (entget (ssname ss i))
             str (vl-string-trim " \t\r\n" (aa:ysdl-get-plain-text ed))
             i   (1+ i))
       (if (/= str "")
         (setq pairs (cons (cons (cdr (assoc 10 ed)) str) pairs))))
     ;; 从上到下；同一高度再从左到右
     (setq names (mapcar 'cdr
                         (aa:merge-sort pairs
                           '(lambda (a b)
                              (if (equal (cadr (car a)) (cadr (car b)) 1e-6)
                                (< (car (car a)) (car (car b)))
                                (> (cadr (car a)) (cadr (car b))))))))
     (cond
       ((null names)
        (princ "\r\n[HWT] 所选文字内容都是空的。"))
       (T
        (princ (strcat "\r\n[HWT] 共 " (itoa (length names)) " 个柜，分行 "
                       (hwt:counts-text (hwt:row-counts (length names))) "。"))
        (if (setq pt (getpoint "\r\n[HWT] 指定第一行第一个柜框的左上角: "))
          (progn
            (setq pt    (trans pt 1 0)
                  style (if (tblsearch "STYLE" "HZ") "HZ" (getvar "TEXTSTYLE")))
            (if (/= style "HZ")
              (princ (strcat "\r\n[HWT] 未找到文字样式 HZ，改用当前样式 " style "。")))
            (hwt:draw (hwt:layout names (car pt) (cadr pt)) (caddr pt) style)
            (princ (strcat "\r\n[HWT] 已生成环网图"
                           (if (> (length names) 1)
                             (strcat "，柜间电缆 SML-01~" (hwt:cable-no (1- (length names))))
                             "")
                           "，端子号默认 JD：1~2 / JD：4~5，个别柜请手改。"))
            ;; 顺带输出电缆清单，回车放在环网图左下方
            (setq lpt (getpoint "\r\n[HWT] 指定电缆清单左上角 <环网图下方>: ")
                  lpt (if lpt
                        (trans lpt 1 0)
                        (list (- (car pt) 61.0)
                              (- (cadr pt) (* (length (hwt:row-counts (length names))) 45.0) 5.0)
                              (caddr pt))))
            (hwt:draw-list (hwt:cable-rows names) (car lpt) (cadr lpt) (caddr pt) style)
            (princ (strcat "\r\n[HWT] 已生成电缆清单 " (itoa (1+ (length names)))
                           " 行，可框选后用 BH3 登记编号。")))
          (princ "\r\n[HWT] 未指定插入点，未生成。"))))))
  (aa:cmd-end))

;;; =======================================================================================
;;; 命令: T2
;;; 功能: 将文字刷为 HZ/0.7；智能字高优先避让（优先 3.0 标准字高 + 安全微移；空间狭窄时微调至 2.5/2.2；保底保持 3.0 原位）。
;;;       局部空间索引快速提取线段，毫秒级响应，原地优先，文字永不失真缩小。
;;; =======================================================================================
(defun txt2:get-bbox (ename / doc)
  (setq doc (vla-get-activedocument (vlax-get-acad-object)))
  (aa:safe-get-bbox doc ename)
)

(defun txt2:overlap-p (a b / tol)
  (setq tol 1e-6)
  (and a b
       (<= (- (car (car b)) tol) (+ (car (cadr a)) tol))
       (<= (- (car (car a)) tol) (+ (car (cadr b)) tol))
       (<= (- (cadr (car b)) tol) (+ (cadr (cadr a)) tol))
       (<= (- (cadr (car a)) tol) (+ (cadr (cadr b)) tol)))
)

(defun txt2:expand-bbox (box gap)
  (if (and box gap)
    (list
      (list (- (car (car box)) gap)
            (- (cadr (car box)) gap)
            (caddr (car box)))
      (list (+ (car (cadr box)) gap)
            (+ (cadr (cadr box)) gap)
            (caddr (cadr box))))
  )
)

;; 判断线段 (x1 y1)-(x2 y2) 是否与水平线段 y=y0 (x在[xmin, xmax]) 相交
(defun txt2:cross-horiz-p (x1 y1 x2 y2 y0 xmin xmax / xi)
  (if (and (/= y1 y2)
           (<= (* (- y1 y0) (- y2 y0)) 1e-9))
    (progn
      (setq xi (+ x1 (/ (* (- x2 x1) (- y0 y1)) (- y2 y1))))
      (and (<= (- xmin 1e-8) xi) (<= xi (+ xmax 1e-8))))
    nil
  )
)

;; 判断线段 (x1 y1)-(x2 y2) 是否与垂直线段 x=x0 (y在[ymin, ymax]) 相交
(defun txt2:cross-vert-p (x1 y1 x2 y2 x0 ymin ymax / yi)
  (if (and (/= x1 x2)
           (<= (* (- x1 x0) (- x2 x0)) 1e-9))
    (progn
      (setq yi (+ y1 (/ (* (- y2 y1) (- x0 x1)) (- x2 x1))))
      (and (<= (- ymin 1e-8) yi) (<= yi (+ ymax 1e-8))))
    nil
  )
)

;; 纯几何线段与 AABB 矩形碰撞检测（快速 AABB 粗筛 + 端点内外测试 + 边线相交）
(defun txt2:line-box-collision-p (x1 y1 x2 y2 xmin ymin xmax ymax / tol)
  (setq tol 1e-8)
  (cond
    ;; 1. 快速 AABB 排除
    ((or (< (max x1 x2) (- xmin tol))
         (> (min x1 x2) (+ xmax tol))
         (< (max y1 y2) (- ymin tol))
         (> (min y1 y2) (+ ymax tol)))
     nil)
    ;; 2. 端点在矩形内（包含边界容差）
    ((or (and (<= (- xmin tol) x1) (<= x1 (+ xmax tol))
              (<= (- ymin tol) y1) (<= y1 (+ ymax tol)))
         (and (<= (- xmin tol) x2) (<= x2 (+ xmax tol))
              (<= (- ymin tol) y2) (<= y2 (+ ymax tol))))
     T)
    ;; 3. 穿过 4 条边之一
    ((txt2:cross-horiz-p x1 y1 x2 y2 ymin xmin xmax) T)
    ((txt2:cross-horiz-p x1 y1 x2 y2 ymax xmin xmax) T)
    ((txt2:cross-vert-p x1 y1 x2 y2 xmin ymin ymax) T)
    ((txt2:cross-vert-p x1 y1 x2 y2 xmax ymin ymax) T)
    (T nil)
  )
)

;; 提取 LWPOLYLINE 的所有线段
(defun txt2:lwpoly-segments (ename edata / pts closed segs p0 prev cur p item)
  (setq closed (= 1 (logand 1 (cdr (assoc 70 edata))))
        pts    '()
        segs   '())
  (foreach item edata
    (if (= (car item) 10)
      (progn
        ;; 顶点可能位于实体 OCS，统一转换到 WCS 后再参与碰撞计算。
        (setq p (trans (cdr item) ename 0))
        (setq pts (cons p pts)))))
  (setq pts (reverse pts))
  (if (and pts (> (length pts) 1))
    (progn
      (setq p0   (car pts)
            prev p0)
      (foreach cur (cdr pts)
        (setq segs (cons (list (car prev) (cadr prev) (car cur) (cadr cur)) segs)
              prev cur))
      (if closed
        (setq segs (cons (list (car prev) (cadr prev) (car p0) (cadr p0)) segs)))
    )
  )
  segs
)

;; 提取经典 2D/3D POLYLINE 的所有线段
(defun txt2:polyline-segments (ename / edata closed pts sub subed p0 prev cur segs p)
  (setq edata  (entget ename)
        closed (= 1 (logand 1 (cdr (assoc 70 edata))))
        pts    '()
        segs   '()
        sub    (entnext ename))
  (while (and sub (setq subed (entget sub)) (/= "SEQEND" (cdr (assoc 0 subed))))
    (if (= "VERTEX" (cdr (assoc 0 subed)))
      (if (= 0 (logand 16 (cdr (assoc 70 subed))))
        (progn
          (setq p (trans (cdr (assoc 10 subed)) ename 0))
          (setq pts (cons p pts)))))
    (setq sub (entnext sub))
  )
  (setq pts (reverse pts))
  (if (and pts (> (length pts) 1))
    (progn
      (setq p0   (car pts)
            prev p0)
      (foreach cur (cdr pts)
        (setq segs (cons (list (car prev) (cadr prev) (car cur) (cadr cur)) segs)
              prev cur))
      (if closed
        (setq segs (cons (list (car prev) (cadr prev) (car p0) (cadr p0)) segs)))
    )
  )
  segs
)

;; 纯几何碰撞检测：检测测试包围盒是否与局部线段相交或与其他已放置文字盒重叠
(defun txt2:box-collision-p (box lines boxes gap / hit xmin ymin xmax ymax cur-lines cur-boxes cur-b)
  (setq hit nil
        box (txt2:expand-bbox box gap)
        xmin (car (car box))
        ymin (cadr (car box))
        xmax (car (cadr box))
        ymax (cadr (cadr box))
        cur-lines lines
        cur-boxes boxes)
  (while (and cur-lines (not hit))
    (if (txt2:line-box-collision-p (car (car cur-lines)) (cadr (car cur-lines))
                                   (caddr (car cur-lines)) (cadddr (car cur-lines))
                                   xmin ymin xmax ymax)
      (setq hit T))
    (setq cur-lines (cdr cur-lines)))
  (while (and cur-boxes (not hit))
    (setq cur-b (cdr (car cur-boxes)))
    (if (txt2:overlap-p box cur-b)
      (setq hit T))
    (setq cur-boxes (cdr cur-boxes)))
  hit
)

;; 提取指定图元的线段
(defun txt2:extract-entity-lines (en / ed typ p1 p2)
  (if (and en (setq ed (entget en)))
    (progn
      (setq typ (cdr (assoc 0 ed)))
      (cond
        ((= typ "LINE")
         (setq p1 (cdr (assoc 10 ed))
               p2 (cdr (assoc 11 ed)))
         ;; LINE 的 10/11 点已是 WCS；不要按实体 OCS 二次转换。
         (list (list (car p1) (cadr p1) (car p2) (cadr p2))))
        ((= typ "LWPOLYLINE")
         (txt2:lwpoly-segments en ed))
        ((= typ "POLYLINE")
         (txt2:polyline-segments en))
        (T nil)
      )
    )
    nil
  )
)

;; 收集候选障碍物：优先提取用户框选的线框，再在文字群外扩 5.0 局部范围内快速拾取物理线段
;; 杜绝全图扫描与图块/标注的大 AABB 误判
(defun txt2:wcs-box-to-ucs-window (wmin wmax / p1 p2 p3 p4 u1 u2 u3 u4)
  ;; 旋转 UCS 下，WCS 包围盒两个对角点不足以构成完整窗口；转换四角后取 UCS 外包。
  (setq p1 (trans (list (car wmin) (cadr wmin) 0.0) 0 1)
        p2 (trans (list (car wmin) (cadr wmax) 0.0) 0 1)
        p3 (trans (list (car wmax) (cadr wmin) 0.0) 0 1)
        p4 (trans (list (car wmax) (cadr wmax) 0.0) 0 1)
        u1 (list (car p1) (cadr p1) 0.0)
        u2 (list (car p2) (cadr p2) 0.0)
        u3 (list (car p3) (cadr p3) 0.0)
        u4 (list (car p4) (cadr p4) 0.0))
  (list
    (list (min (car u1) (car u2) (car u3) (car u4))
          (min (cadr u1) (cadr u2) (cadr u3) (cadr u4))
          0.0)
    (list (max (car u1) (car u2) (car u3) (car u4))
          (max (cadr u1) (cadr u2) (cadr u3) (cadr u4))
          0.0)))

(defun txt2:collect-obstacles (text-list extra-ents / doc g-min g-max margin ss i en ed typ lines boxes bbox ucs-win)
  (setq doc    (vla-get-activedocument (vlax-get-acad-object))
        g-min  nil
        g-max  nil
        margin 5.0
        lines  '()
        boxes  '())
  ;; 1. 先处理用户一同框选的非文字对象。
  (foreach en extra-ents
    (if (not (member en text-list))
      (progn
        (setq ed (entget en)
              typ (cdr (assoc 0 ed)))
        (if (member typ '("LINE" "LWPOLYLINE" "POLYLINE"))
          (setq lines (append (txt2:extract-entity-lines en) lines))
          (if (setq bbox (aa:safe-get-bbox doc en))
            (setq boxes (cons (cons en bbox) boxes))))
    )
  )
  ;; 2. 动态计算待处理文字联合外包范围
  (foreach en text-list
    (if (setq bbox (aa:safe-get-bbox doc en))
      (if (null g-min)
        (setq g-min (car bbox)
              g-max (cadr bbox))
        (setq g-min (list (min (car g-min) (car (car bbox)))
                          (min (cadr g-min) (cadr (car bbox))))
              g-max (list (max (car g-max) (car (cadr bbox)))
                          (max (cadr g-max) (cadr (cadr bbox))))))))
  ;; 3. 在文字群联合外包盒周围局部拾取线段和其它图元。
  (if (and g-min g-max)
    (progn
      (setq g-min (list (- (car g-min) margin) (- (cadr g-min) margin))
            g-max (list (+ (car g-max) margin) (+ (cadr g-max) margin))
            ;; ssget 窗口按当前 UCS 解释，范围坐标来自 WCS 包围盒四角。
            ucs-win (txt2:wcs-box-to-ucs-window g-min g-max)
            ss    (ssget "C" (car ucs-win) (cadr ucs-win)
                         '((0 . "LINE,LWPOLYLINE,POLYLINE,CIRCLE,ARC,ELLIPSE,SPLINE,INSERT,DIMENSION,LEADER,MULTILEADER"))))
      (if ss
        (progn
          (setq i 0)
          (while (< i (sslength ss))
            (setq en (ssname ss i))
            (if (and (not (member en text-list))
                     (not (member en extra-ents)))
              (progn
                (setq ed (entget en)
                      typ (cdr (assoc 0 ed)))
                (if (member typ '("LINE" "LWPOLYLINE" "POLYLINE"))
                  (setq lines (append (txt2:extract-entity-lines en) lines))
                  (if (setq bbox (aa:safe-get-bbox doc en))
                    (setq boxes (cons (cons en bbox) boxes))))))
            (setq i (1+ i))
          )
        )
      )
    )
  )
  (list lines boxes)
)
)

;; 智能避让修改单个文字：
;; 1. 样式设为 HZ、宽比 0.7；
;; 2. 严格优先采用 3.0 标准字高：原地若无碰撞直接保留，若有碰撞则在微移网格内寻找不碰撞位置；
;; 3. 仅当 3.0 任何微移均无法避让时，才微调字高到 2.5 / 2.2，下限绝不低于 2.2；
;; 4. 保底策略：若极端狭窄处 2.2 仍碰撞，保持 3.0 标准字高原地放置，绝不破坏可读性。
(defun txt2:modify-text (ename lines boxes / doc edata oldbox basebox orig-cx orig-cy w3 h3
                                             local-lines max-r bound-min-x bound-max-x bound-min-y bound-max-y
                                             nudge-offsets best-sol test-height
                                             cur-h cur-dx cur-dy cur-box
                                             cur-cx cur-cy target-cx target-cy
                                             shift-x shift-y vla-obj final-box seg)
  (setq doc (vla-get-activedocument (vlax-get-acad-object)))
  (if (and ename (= "TEXT" (cdr (assoc 0 (setq edata (entget ename))))))
    (progn
      ;; 先保存原中心；刷样式/字高会改变包围盒，最后必须补偿回原中心。
      (setq oldbox (aa:safe-get-bbox doc ename))
      ;; 1. 统一设为样式 HZ、宽比 0.7、初始字高 3.0，并更新获取标准基准盒
      (setq edata (txt:set-dxf 7 "HZ" edata)
            edata (txt:set-dxf 41 0.7 edata)
            edata (txt:set-dxf 40 3.0 edata))
      (entmod edata)
      (entupd ename)
      (setq basebox (aa:safe-get-bbox doc ename))
      (if (null basebox)
        0
        (progn
          (setq orig-cx (/ (+ (car (car (if oldbox oldbox basebox)))
                              (car (cadr (if oldbox oldbox basebox)))) 2.0)
                orig-cy (/ (+ (cadr (car (if oldbox oldbox basebox)))
                              (cadr (cadr (if oldbox oldbox basebox)))) 2.0)
                w3      (- (car (cadr basebox)) (car (car basebox)))
                h3      (- (cadr (cadr basebox)) (cadr (car basebox))))

          ;; 局部线段粗筛：仅提取此文字周围 (半宽/半高 + 2.5) 范围内的线段，毫秒级碰撞检测
          (setq max-r       (+ (max (/ w3 2.0) (/ h3 2.0)) 2.5)
                bound-min-x (- orig-cx max-r)
                bound-max-x (+ orig-cx max-r)
                bound-min-y (- orig-cy max-r)
                bound-max-y (+ orig-cy max-r)
                local-lines '())
          (foreach seg lines
            (if (not (or (< (max (car seg) (caddr seg)) bound-min-x)
                         (> (min (car seg) (caddr seg)) bound-max-x)
                         (< (max (cadr seg) (cadddr seg)) bound-min-y)
                         (> (min (cadr seg) (cadddr seg)) bound-max-y)))
              (setq local-lines (cons seg local-lines))))

          ;; 候选微移向量 (dx dy)：原地优先，垂直微调优先，水平次之，最后轻微斜向
          (setq nudge-offsets
            '(
              (0.0  0.0)
              (0.0  0.3) (0.0 -0.3)
              (0.0  0.6) (0.0 -0.6)
              (0.0  1.0) (0.0 -1.0)
              (0.0  1.5) (0.0 -1.5)
              (0.3  0.0) (-0.3  0.0)
              (0.6  0.0) (-0.6  0.0)
              (1.0  0.0) (-1.0  0.0)
              (1.5  0.0) (-1.5  0.0)
              (0.3  0.3) (-0.3  0.3) (0.3 -0.3) (-0.3 -0.3)
              (0.6  0.6) (-0.6  0.6) (0.6 -0.6) (-0.6 -0.6)
             ))

          ;; 2. 字高优先搜索最优解：
          ;;    严格以标准字高 3.0 为最高优先！能通过微移避开就绝不降低字高！
          (setq test-height
            '(lambda (h / scale half-w half-h sol off-list off dx dy test-box)
               (setq scale    (/ h 3.0)
                     half-w   (* (/ w3 2.0) scale)
                     half-h   (* (/ h3 2.0) scale)
                     sol      nil
                     off-list nudge-offsets)
               (while (and off-list (null sol))
                 (setq off      (car off-list)
                       dx       (car off)
                       dy       (cadr off)
                       test-box (list
                                  (list (- (+ orig-cx dx) half-w)
                                        (- (+ orig-cy dy) half-h)
                                        0.0)
                                  (list (+ (+ orig-cx dx) half-w)
                                        (+ (+ orig-cy dy) half-h)
                                        0.0)))
                 ;; 文字与线框至少保留 0.3 间隙。
                 (if (not (txt2:box-collision-p test-box local-lines boxes 0.3))
                   (setq sol (list h dx dy)))
                 (setq off-list (cdr off-list)))
               sol
             ))

          ;; 第一优先级：3.0 标准字高（原地及微移测试）
          (setq best-sol (apply test-height '(3.0)))

          ;; 第二优先级：若 3.0 任何微移均无法避开，才尝试 2.5
          (if (null best-sol)
            (setq best-sol (apply test-height '(2.5))))

          ;; 第三优先级：若 2.5 仍无法避开，才尝试 2.2
          (if (null best-sol)
            (setq best-sol (apply test-height '(2.2))))

          ;; 3. 保底处理：若所有网格均有碰撞（极端拥挤），
          ;;    坚决保持 3.0 标准字高原地放置，杜绝文字缩为肉眼难辨的微小字！
          (if (null best-sol)
            (setq best-sol (list 3.0 0.0 0.0)))

          ;; 4. 实施最终字高与平移调整
          (setq cur-h  (nth 0 best-sol)
                cur-dx (nth 1 best-sol)
                cur-dy (nth 2 best-sol))

          ;; 若字高不是 3.0，更新字高
          (if (/= cur-h 3.0)
            (progn
              (setq edata (entget ename))
              (setq edata (txt:set-dxf 40 cur-h edata))
              (entmod edata)
              (entupd ename)
            )
          )

          ;; 无论是否微移/降高，都补偿最终包围盒中心，保证刷样式不改变原位置。
          (setq cur-box (aa:safe-get-bbox doc ename))
          (if cur-box
            (progn
              (setq cur-cx    (/ (+ (car (car cur-box)) (car (cadr cur-box))) 2.0)
                    cur-cy    (/ (+ (cadr (car cur-box)) (cadr (cadr cur-box))) 2.0)
                    target-cx (+ orig-cx cur-dx)
                    target-cy (+ orig-cy cur-dy)
                    shift-x   (- target-cx cur-cx)
                    shift-y   (- target-cy cur-cy))
              (if (> (+ (* shift-x shift-x) (* shift-y shift-y)) 1e-8)
                (progn
                  (setq vla-obj (vlax-ename->vla-object ename))
                  (vl-catch-all-apply
                    'vla-Move
                    (list vla-obj
                          (vlax-3d-point '(0.0 0.0 0.0))
                          (vlax-3d-point (list shift-x shift-y 0.0))))
                  (vlax-release-object vla-obj)
                  (entupd ename)
                )
              )
            )
          )

          ;; 返回此文字的最终包围盒，便于后续文字作为障碍避让
          (setq final-box (aa:safe-get-bbox doc ename))
          (if final-box final-box basebox)
        )
      )
    )
    nil
  )
)

(defun txt2:process-selection (sel / doc total i ename etype
                                     mtss mtlist before after text-list extra-ents
                                     count obstacles lines boxes new-box)
  (setq doc        (vla-get-activedocument (vlax-get-acad-object))
        total      (sslength sel)
        mtss       (ssadd)
        mtlist     '()
        text-list  '()
        extra-ents '()
        count      0
        i          0)

  ;; 1. 区分待排版文字 (TEXT/MTEXT) 与随选的避让参照实体 (线框等)
  (while (< i total)
    (setq ename (ssname sel i)
          etype (cdr (assoc 0 (entget ename))))
    (cond
      ((= etype "TEXT")
       (setq text-list (cons ename text-list)))
      ((= etype "MTEXT")
       (ssadd ename mtss)
       (setq mtlist (cons ename mtlist)))
      (T
       (setq extra-ents (cons ename extra-ents)))
    )
    (setq i (1+ i))
  )

  ;; 2. 如果存在 MTEXT，统一炸开并收集炸开后的 TEXT
  (if (> (sslength mtss) 0)
    (progn
      (setq before (entlast))
      (command "_.explode" mtss "")
      (foreach ename mtlist
        (if (= "MTEXT" (cdr (assoc 0 (entget ename))))
          (command "_.explode" ename)))
      (setq after (entlast))
      (if (and after (not (eq before after)))
        (progn
          (setq ename (if before (entnext before) (entnext)))
          (while ename
            (if (= "TEXT" (cdr (assoc 0 (entget ename))))
              (setq text-list (cons ename text-list)))
            (if (eq ename after) (setq ename nil) (setq ename (entnext ename)))
          )
        )
      )
    )
  )

  ;; 3. 局部感知提取障碍物线段并逐个文字智能避让
  (setq text-list (reverse text-list))
  (if text-list
    (progn
      (setq obstacles (txt2:collect-obstacles text-list extra-ents)
            lines     (car obstacles)
            boxes     (cadr obstacles))
      (foreach ename text-list
        (if (setq new-box (txt2:modify-text ename lines boxes))
          (progn
            (setq count (1+ count))
            ;; 将当前文字排定后的新包围盒实时加入障碍盒列表，供后续文字协同避让！
            (setq boxes (cons (cons ename new-box) boxes))
          )
        )
      )
    )
  )

  (redraw)
  (princ (strcat "\r\n已处理文字数量: " (itoa count)))
  count
)

(defun c:T2 (/ *error* aa:tag aa:doc aa:undo-open aa:old-cmdecho sel)
  (aa:cmd-begin "T2")
  (if (null (tblsearch "STYLE" "HZ"))
    (princ "\r\n未找到文字样式 HZ。")
    (progn
      (setq sel (ssget "_I"))
      (if (null sel)
        (progn
          (princ "\r\n请选择文字对象（可同时框选周围线框作为避让参考）: ")
          (setq sel (ssget))
        )
      )
      (if sel
        (txt2:process-selection sel)
        (princ "\r\n未选择任何对象。")
      )
    )
  )
  (aa:cmd-end)
)
;;; =======================================================================================
;;; 命令: H
;;; 功能: 先将选中文字统一为左中对正，再按用户输入的垂直间距从上到下排列。

;;; =======================================================================================
;;; 命令: KUANG
;;; 功能: 依次指定有效区域的左上角点，自动选中各图框有效范围内的对象。
;;; =======================================================================================
(vl-load-com)

;;; =======================================================================================
;;; =======================================================================================
;;; 命令: ABCN
;;; 功能: 指定 A 的左中对齐点，生成 T 格式的青色单行文字；按 H 默认规则排列。
;;; =======================================================================================
(defun c:ABCN (/ *error* aa:tag aa:doc aa:undo-open aa:old-cmdecho
                pt created result ok label en box anchor idx delta)
  (aa:cmd-begin "ABCN")
  (cond
    ((not (tblsearch "STYLE" "HZ"))
     (princ "\r\n未找到文字样式 HZ，请先建立该样式。"))
    ((setq pt (getpoint "\r\n指定 A 的左中对齐点: "))
     (setq pt (trans pt 1 0)
           created nil
           ok T
           idx 0)
     ;; 捕获创建及几何读取异常，任一步失败都清理本批文字。
     (setq result
       (vl-catch-all-apply
         '(lambda ()
            (foreach label '("A" "B" "C" "N")
              (if ok
                (progn
                  (setq en
                    (entmakex
                      (list '(0 . "TEXT")
                            (cons 8 (getvar "CLAYER"))
                            '(62 . 4) '(7 . "HZ") '(40 . 3.0) '(41 . 0.7)
                            '(50 . 0.0) '(51 . 0.0) '(71 . 0)
                            '(72 . 0) '(73 . 2) '(210 0.0 0.0 1.0)
                            (cons 10 pt) (cons 11 pt) (cons 1 label))))
                  (if en
                    (progn
                      (setq created (cons en created)
                            box (aa:safe-get-bbox aa:doc en))
                      (if box
                        (if (= idx 0)
                          (setq anchor box)
                          (progn
                            ;; 与 H 一致：可见左边界对齐，上边界每行向下5。
                            (setq delta
                              (list (- (caar anchor) (caar box))
                                    (- (cadadr anchor) (* idx 5.0) (cadadr box))
                                    0.0))
                            (setq ok (aa:safe-move-entity en delta))))
                        (setq ok nil)))
                    (setq ok nil))
                  (setq idx (1+ idx))))))
         nil))
     (if (or (vl-catch-all-error-p result) (not ok))
       (progn
         (foreach en created (if (entget en) (entdel en)))
         (princ "\r\n生成失败，已清理本批文字，请检查当前图层及 HZ 样式。"))
       (princ "\r\n已生成青色 A、B、C、N，字高3、宽度0.7、间距5。"))
     (redraw)))
  (aa:cmd-end)
)

(defun c:H (/ *error* aa:tag aa:doc aa:undo-open aa:old-cmdecho a ss doc i ename vla_obj min_pt max_pt min_list max_list
              edata ht total_ht avg_ht row_tol top_y left_x mid_y text_list rows current_row base_row_y
              sorted_row sorted_text_list text_info anchor_ent anchor_left anchor_top
              current_top current_left target_top delta_x delta_y move_vec count ref_y anchor_ref)
  (aa:cmd-begin "H")
  (vl-load-com)
  (setq a (getdist "\r\n请输入上下间距 <5>: "))
  (if (not a)
    (setq a 5.0)
  )

  (princ "\r\n选择要对齐的文字对象: ")
  (setq ss (ssget '((0 . "TEXT,MTEXT"))))

  (if (not ss)
    (progn (princ "\r\n未选择任何文字对象。") (exit))
  )

  (setq text_list '()
        total_ht 0.0
        i 0
        doc (vla-get-activedocument (vlax-get-acad-object)))
  (repeat (sslength ss)
    (setq ename   (ssname ss i)
          vla_obj (vlax-ename->vla-object ename)
          edata   (entget ename)
          ht      (cdr (assoc 40 edata)))
    (if (or (null ht) (<= ht 0.0))
      (setq ht 3.5)
    )
    (setq total_ht (+ total_ht ht))
    ;; 先统一为左中对正，再按统一的文字包围盒排列。
    (aa:normalize-text-horizontal-align doc ename 1)
    (vla-getboundingbox vla_obj 'min_pt 'max_pt)
    (setq min_list  (vlax-safearray->list min_pt)
          max_list  (vlax-safearray->list max_pt)
          top_y     (cadr max_list)
          left_x    (car min_list)
          mid_y     (* 0.5 (+ (cadr min_list) (cadr max_list))))
    ;; 上下间距按插入点/对齐点算：左中对正后 TEXT 取对齐点（组码 11），MTEXT 取插入点（组码 10）
    (setq edata (entget ename)
          ref_y (cadr (cdr (assoc (if (and (= (cdr (assoc 0 edata)) "TEXT") (assoc 11 edata)) 11 10)
                                  edata))))
    (setq text_list (cons (list top_y left_x ename mid_y ref_y) text_list)
          i         (1+ i))
    (vlax-release-object vla_obj)
  )

  ;; 动态计算行容差（以平均字高的 0.6 倍为同一行容差，最小 1.0）
  (setq avg_ht  (/ total_ht (max 1 (length text_list)))
        row_tol (max 1.0 (* avg_ht 0.6)))

  ;; 1. 先按垂直中心 Y 坐标从大到小排序（从上到下初排）
  (setq text_list
    (aa:merge-sort
      text_list
      '(lambda (a b)
         (> (nth 3 a) (nth 3 b)))))

  ;; 2. 聚类分行：从上到下扫描，垂直距离在 row_tol 内的归入同一行
  (setq rows '()
        current_row '()
        base_row_y nil)
  (foreach item text_list
    (if (null current_row)
      (setq current_row (list item)
            base_row_y  (nth 3 item))
      (if (<= (abs (- base_row_y (nth 3 item))) row_tol)
        (setq current_row (cons item current_row))
        (progn
          (setq rows (cons current_row rows)
                current_row (list item)
                base_row_y  (nth 3 item))
        )
      )
    )
  )
  (if current_row
    (setq rows (cons current_row rows))
  )
  (setq rows (reverse rows))

  ;; 3. 每行内部按 X 坐标从小到大（从左到右）排序，并展平成全局排序列表
  (setq sorted_text_list '())
  (foreach row rows
    (setq sorted_row
      (aa:merge-sort
        row
        '(lambda (a b)
           (< (cadr a) (cadr b)))))
    (setq sorted_text_list (append sorted_text_list sorted_row))
  )

  ;; 以排在最上方的文字为基准，保持其位置不动，其左边界作为对齐基准线
  (setq anchor_ent  (nth 2 (car sorted_text_list))
        anchor_top  (car (car sorted_text_list))
        anchor_ref  (nth 4 (car sorted_text_list))
        anchor_left (cadr (car sorted_text_list))
        doc         (vla-get-activedocument (vlax-get-acad-object))
        count       0)

  (foreach text_info sorted_text_list
    (setq ename (nth 2 text_info))
    (if (not (eq ename anchor_ent))
      (progn
        (setq vla_obj (vlax-ename->vla-object ename))
        (vla-getboundingbox vla_obj 'min_pt 'max_pt)
        (setq min_list   (vlax-safearray->list min_pt)
              max_list   (vlax-safearray->list max_pt)
              current_left (car min_list)
              delta_x    (- anchor_left current_left)
              delta_y    (- (- anchor_ref (* count a)) (nth 4 text_info)))
        (if (or (/= delta_x 0.0) (/= delta_y 0.0))
          (progn
            (setq move_vec (vlax-3d-point (list delta_x delta_y 0.0)))
            (vla-move vla_obj (vlax-3d-point '(0.0 0.0 0.0)) move_vec)
          )
        )
        (vlax-release-object vla_obj)
      )
    )
    (setq count (1+ count))
  )
  (redraw)

  (princ (strcat "\r\n成功以最上方文字为基准排列并左对齐了 " (itoa (sslength ss)) " 个文字对象。"))
  (aa:cmd-end)
)


;;; =======================================================================================
;;; 命令: H2
;;; 功能: 先将选中文字统一为左中对正，右侧文字在最上、越靠左越靠下，按指定间距从上到下排列。
;;; =======================================================================================
(defun c:H2 (/ *error* aa:tag aa:doc aa:undo-open aa:old-cmdecho a ss doc i ename vla_obj min_pt max_pt min_list max_list
               edata ht total_ht avg_ht row_tol top_y left_x mid_y text_list rows current_row base_row_y
               sorted_row sorted_text_list text_info anchor_ent anchor_left anchor_top
               current_top current_left target_top delta_x delta_y move_vec count)
  (aa:cmd-begin "H2")
  (vl-load-com)
  (setq a (getdist "\r\n请输入上下间距 <5>: "))
  (if (not a)
    (setq a 5.0)
  )

  (princ "\r\n选择要对齐的文字对象: ")
  (setq ss (ssget '((0 . "TEXT,MTEXT"))))

  (if (not ss)
    (progn (princ "\r\n未选择任何文字对象。") (exit))
  )

  (setq text_list '()
        total_ht 0.0
        i 0
        doc (vla-get-activedocument (vlax-get-acad-object)))
  (repeat (sslength ss)
    (setq ename   (ssname ss i)
          vla_obj (vlax-ename->vla-object ename)
          edata   (entget ename)
          ht      (cdr (assoc 40 edata)))
    (if (or (null ht) (<= ht 0.0))
      (setq ht 3.5)
    )
    (setq total_ht (+ total_ht ht))
    ;; 先统一为左中对正，再按统一的文字包围盒排列。
    (aa:normalize-text-horizontal-align doc ename 1)
    (vla-getboundingbox vla_obj 'min_pt 'max_pt)
    (setq min_list  (vlax-safearray->list min_pt)
          max_list  (vlax-safearray->list max_pt)
          top_y     (cadr max_list)
          left_x    (car min_list)
          mid_y     (* 0.5 (+ (cadr min_list) (cadr max_list))))
    (setq text_list (cons (list top_y left_x ename mid_y) text_list)
          i         (1+ i))
    (vlax-release-object vla_obj)
  )

  ;; 动态计算行容差（以平均字高的 0.6 倍为同一行容差，最小 1.0）
  (setq avg_ht  (/ total_ht (max 1 (length text_list)))
        row_tol (max 1.0 (* avg_ht 0.6)))

  ;; 1. 先按垂直中心 Y 坐标从大到小排序（从上到下初排）
  (setq text_list
    (aa:merge-sort
      text_list
      '(lambda (a b)
         (> (nth 3 a) (nth 3 b)))))

  ;; 2. 聚类分行：从上到下扫描，垂直距离在 row_tol 内的归入同一行
  (setq rows '()
        current_row '()
        base_row_y nil)
  (foreach item text_list
    (if (null current_row)
      (setq current_row (list item)
            base_row_y  (nth 3 item))
      (if (<= (abs (- base_row_y (nth 3 item))) row_tol)
        (setq current_row (cons item current_row))
        (progn
          (setq rows (cons current_row rows)
                current_row (list item)
                base_row_y  (nth 3 item))
        )
      )
    )
  )
  (if current_row
    (setq rows (cons current_row rows))
  )
  (setq rows (reverse rows))

  ;; 3. 每行内部按 X 坐标从大到小（从右到左）排序，展平成全局排序列表（右边文字在最上面）
  (setq sorted_text_list '())
  (foreach row rows
    (setq sorted_row
      (aa:merge-sort
        row
        '(lambda (a b)
           (> (cadr a) (cadr b)))))
    (setq sorted_text_list (append sorted_text_list sorted_row))
  )

  ;; 以排序后的首个文字（最上方最右侧）为基准，保持其位置不动，其左边界作为对齐基准线
  (setq anchor_ent  (nth 2 (car sorted_text_list))
        anchor_top  (car (car sorted_text_list))
        anchor_left (cadr (car sorted_text_list))
        doc         (vla-get-activedocument (vlax-get-acad-object))
        count       0)

  (foreach text_info sorted_text_list
    (setq ename (nth 2 text_info))
    (if (not (eq ename anchor_ent))
      (progn
        (setq vla_obj (vlax-ename->vla-object ename))
        (vla-getboundingbox vla_obj 'min_pt 'max_pt)
        (setq min_list   (vlax-safearray->list min_pt)
              max_list   (vlax-safearray->list max_pt)
              current_left (car min_list)
              current_top (cadr max_list)
              target_top (- anchor_top (* count a))
              delta_x    (- anchor_left current_left)
              delta_y    (- target_top current_top))
        (if (or (/= delta_x 0.0) (/= delta_y 0.0))
          (progn
            (setq move_vec (vlax-3d-point (list delta_x delta_y 0.0)))
            (vla-move vla_obj (vlax-3d-point '(0.0 0.0 0.0)) move_vec)
          )
        )
        (vlax-release-object vla_obj)
      )
    )
    (setq count (1+ count))
  )
  (redraw)

  (princ (strcat "\r\n成功以右侧文字优先自上而下排列并左对齐了 " (itoa (sslength ss)) " 个文字对象。"))
  (aa:cmd-end)
)


;;; =======================================================================================
;;; 命令: Y
;;; 功能: 快速将选中对象的颜色更改为青色。
;;; =======================================================================================
(defun aa:color-cmd (targetColor prompt done / ss i ename)
  (princ prompt)
  (setq ss (ssget))
  (if ss
    (progn
      (setq i 0)
      (repeat (sslength ss)
        (setq ename (ssname ss i))
        (aa:set-entity-aci-color ename targetColor)
        (setq i (1+ i))
      )
      (redraw)
      (princ done)
    )
    (princ "\r\n未选择任何对象。")
  )
  (princ)
)

(defun c:y (/ *error* aa:tag aa:doc aa:undo-open aa:old-cmdecho)
  (aa:cmd-begin "Y")
  (aa:color-cmd *Y_TextColor* "\r\n选择要改变颜色的对象: " "\r\n所有选中的对象颜色已更改。")
  (aa:cmd-end)
)

;;; =======================================================================================
;;; 命令: DZ
;;; 功能: 将所选其他文字改为Y命令的青色，保留纯数字及数字后接单个小写a的文字原色。
;;; =======================================================================================
(defun aa:dz-number-p (text / chars valid ch)
  ;; 只排除整段为数字的文字；3I4D、1ZD 等含数字的端子名仍需改色。
  (setq text (vl-string-trim " \t\r\n　" (if text text "")))
  ;; 数字末尾的单个小写 a 是补充端子号（如 7a），也按数字保留原色。
  ;; 只去掉末尾一个 a 后校验全部剩余字符，a、7aa、7A、1ZDa 仍需改色。
  (if (and (> (strlen text) 1) (= (substr text (strlen text) 1) "a"))
    (setq text (substr text 1 (1- (strlen text)))))
  (setq chars (vl-string->list text)
        valid (not (null chars)))
  (while (and chars valid)
    (setq ch (chr (car chars)))
    (if (not (vl-string-search ch "0123456789０１２３４５６７８９零〇○一二三四五六七八九十百千万亿两壹贰叁肆伍陆柒捌玖拾佰仟萬億"))
      (setq valid nil))
    (setq chars (cdr chars)))
  valid)

(defun aa:dz-color-text (en ed / obj result raw clean)
  ;; 多行文字先去掉内嵌颜色，避免其覆盖实体青色；保留其余格式。
  (setq result T)
  (if (= (cdr (assoc 0 ed)) "MTEXT")
    (progn
      (setq raw (aa:ysdl-get-raw-text ed)
            clean (aa:strip-mtext-color-format raw))
      (if (/= raw clean)
        (progn
          (setq obj (vl-catch-all-apply 'vlax-ename->vla-object (list en)))
          (if (vl-catch-all-error-p obj)
            (setq result nil)
            (progn
              (setq result (vl-catch-all-apply 'vla-put-TextString (list obj clean)))
              (vlax-release-object obj)
              (setq result (not (vl-catch-all-error-p result)))))))))
  (and result (aa:set-entity-aci-color en *Y_TextColor*)))

(defun c:DZ (/ *error* aa:tag aa:doc aa:undo-open aa:old-cmdecho
               ss i en ed text layer changed kept skipped result)
  (aa:cmd-begin "DZ")
  (setq changed 0 kept 0 skipped 0
        ss (ssget "_I" '((0 . "TEXT,MTEXT"))))
  (if (null ss)
    (progn
      (princ "\r\nDZ：选择文字，纯数字及数字后接小写a保留原色，其余改为青色：")
      (setq ss (ssget '((0 . "TEXT,MTEXT"))))))
  (if ss
    (progn
      (setq i 0)
      (repeat (sslength ss)
        (setq en (ssname ss i)
              ed (entget en)
              text (vl-string-trim " \t\r\n　" (aa:ysdl-get-plain-text ed))
              layer (tblsearch "LAYER" (cdr (assoc 8 ed)))
              i (1+ i))
        (cond
          ((aa:dz-number-p text) (setq kept (1+ kept)))
          ((or (= text "") (/= 0 (logand 4 (cdr (assoc 70 layer)))))
           (setq skipped (1+ skipped)))
          (T
           (setq result (vl-catch-all-apply 'aa:dz-color-text (list en ed)))
           (if (and (not (vl-catch-all-error-p result)) result)
             (setq changed (1+ changed))
             (setq skipped (1+ skipped))))))
      (if (> changed 0) (redraw))
      (princ (strcat "\r\nDZ 完成：已设为青色 " (itoa changed)
                     " 个，保留数字及小写a编号 " (itoa kept)
                     " 个，跳过空文字、锁定图层或修改失败 " (itoa skipped) " 个。")))
    (princ "\r\n未选择文字。"))
  (sssetfirst nil nil)
  (aa:cmd-end)
  (princ))

;;; =======================================================================================
;;; Command: YY
;;; Function: Set selected objects to yellow color.
;;; =======================================================================================
(defun c:YY (/ *error* aa:tag aa:doc aa:undo-open aa:old-cmdecho)
  (aa:cmd-begin "YY")
  (aa:color-cmd *YY_TextColor* "\r\n选择要改为黄色的对象: " "\r\n所有选中对象已改为黄色。")
  (aa:cmd-end)
)

;;; =======================================================================================
;;; Command: RR
;;; Function: Set selected objects to red color.
;;; =======================================================================================
(defun c:RR (/ *error* aa:tag aa:doc aa:undo-open aa:old-cmdecho)
  (aa:cmd-begin "RR")
  (aa:color-cmd *RR_TextColor* "\r\n选择要改为红色的对象: " "\r\n所有选中对象已改为红色。")
  (aa:cmd-end)
)

;;; =======================================================================================
;;; Command: WW
;;; Function: 将选中对象快速改为白色，不深度处理块和标注；深度改色使用 WWW。
;;; =======================================================================================
(defun c:WW (/ *error* aa:tag aa:doc aa:undo-open aa:old-cmdecho)
  (aa:cmd-begin "WW")
  (aa:color-cmd *WW_TextColor* "\r\n选择要改为白色的对象: " "\r\n所有选中对象已改为白色。")
  (aa:cmd-end)
)

;;; =======================================================================================
;;; Command: WWW
;;; Function: 将选中对象强制改为白色；支持转角标注等尺寸标注全要素变白，块内所有实体一并变白。
;;; =======================================================================================
(defun c:WWW (/ *error* aa:tag aa:doc aa:undo-open aa:old-cmdecho)
  (aa:cmd-begin "WWW")
  (aa:deep-color-cmd *WW_TextColor*
    "\r\n选择要改为白色的对象: " "\r\n所有选中对象已改为白色。")
  (sssetfirst nil nil)
  (aa:cmd-end)
)

;;; =======================================================================================
;;; Command: XU
;;; Function: 将所有选中且支持线型修改的对象改为 HIDDEN2。
;;; =======================================================================================
(defun c:XU (/ *error* doc undo-open oldcmdecho ss i ename obj
              old-ltype result changed unchanged skipped)
  (vl-load-com)
  (setq doc (vla-get-ActiveDocument (vlax-get-acad-object))
        undo-open nil
        oldcmdecho (getvar "CMDECHO")
        changed 0
        unchanged 0
        skipped 0)

  (defun *error* (msg)
    (if oldcmdecho (setvar "CMDECHO" oldcmdecho))
    (if undo-open
      (vl-catch-all-apply 'vla-EndUndoMark (list doc)))
    (sssetfirst nil nil)
    (if (and msg
             (not (wcmatch (strcase msg) "*BREAK*,*CANCEL*,*EXIT*,*QUIT*")))
      (princ (strcat "\r\n[XU] 错误：" msg)))
    (princ))

  (setvar "CMDECHO" 0)
  ;; 图中没有 HIDDEN2 时，先从 CAD 默认线型库加载。
  (if (not (tblsearch "LTYPE" "HIDDEN2"))
    (command "_.-LINETYPE" "_Load" "HIDDEN2" ""))

  (if (tblsearch "LTYPE" "HIDDEN2")
    (progn
      ;; 不设置任何对象类型过滤，处理时再判断是否支持线型属性。
      (setq ss (ssget "_I"))
      (if (null ss)
        (progn
          (princ "\r\n[XU] 请选择需要改为 HIDDEN2 线型的对象：")
          (setq ss (ssget))))

      (if ss
        (progn
          (vl-catch-all-apply 'vla-StartUndoMark (list doc))
          (setq undo-open T
                i 0)
          (repeat (sslength ss)
            (setq ename (ssname ss i)
                  obj (vl-catch-all-apply 'vlax-ename->vla-object (list ename)))
            (if (or (vl-catch-all-error-p obj)
                    (not (vlax-property-available-p obj 'Linetype T)))
              (setq skipped (1+ skipped))
              (progn
                (setq old-ltype
                      (vl-catch-all-apply 'vla-get-Linetype (list obj)))
                (if (and (not (vl-catch-all-error-p old-ltype))
                         (= (strcase old-ltype) "HIDDEN2"))
                  (setq unchanged (1+ unchanged))
                  (progn
                    (setq result
                          (vl-catch-all-apply
                            'vla-put-Linetype
                            (list obj "HIDDEN2")))
                    (if (vl-catch-all-error-p result)
                      (setq skipped (1+ skipped))
                      (setq changed (1+ changed)))))))
            (if (and obj (not (vl-catch-all-error-p obj)))
              (vlax-release-object obj))
            (setq i (1+ i)))
          (redraw)
          (vl-catch-all-apply 'vla-EndUndoMark (list doc))
          (setq undo-open nil)
          (princ
            (strcat "\r\n[XU] 处理完成：已改为 HIDDEN2 " (itoa changed) " 个"
                    "，原本已是该线型 " (itoa unchanged) " 个"
                    "，无法修改 " (itoa skipped) " 个。")))
        (princ "\r\n[XU] 未选择任何对象。")))
    (princ "\r\n[XU] 无法加载 HIDDEN2 线型，命令已取消。"))

  (setvar "CMDECHO" oldcmdecho)
  (sssetfirst nil nil)
  (princ))

;;; =======================================================================================
;;; Command: GG
;;; Function: Set selected objects to green color.
;;; =======================================================================================
(defun c:GG (/ *error* aa:tag aa:doc aa:undo-open aa:old-cmdecho)
  (aa:cmd-begin "GG")
  (aa:color-cmd *GG_TextColor* "\r\n选择要改为绿色的对象: " "\r\n所有选中对象已改为绿色。")
  (aa:cmd-end)
)

;;; =======================================================================================
;;; 命令: PP
;;; 功能: 将选中的所有对象颜色改为洋红色（ACI 6）。
;;; =======================================================================================
(defun c:PP (/ *error* aa:tag aa:doc aa:undo-open aa:old-cmdecho)
  (aa:cmd-begin "PP")
  (aa:color-cmd *PP_TextColor* "\r\n请选择要改为洋红色的对象: " "\r\n所有选中对象已改为洋红色。")
  (aa:cmd-end)
)

;;; =======================================================================================
;;; 命令: HH
;;; 功能: 将选中的所有对象快速改为 HUI 的颜色（ACI 8）。
;;; =======================================================================================
(defun c:HH (/ *error* aa:tag aa:doc aa:undo-open aa:old-cmdecho)
  (aa:cmd-begin "HH")
  (aa:color-cmd *HUI_TextColor* "\r\n请选择要改为颜色 8 的对象: " "\r\n所有选中对象已改为颜色 8。")
  (aa:cmd-end)
)

;;; =======================================================================================
;;; 公共实现: HUI / WWW 的深度改色
;;; 功能: 按目标颜色改色；块参照直接修改块定义，块内实体与嵌套块一并改色，不分解块。
;;; =======================================================================================
(defun aa:deep-color-dimension (doc ename color visited / ed typ txt new-txt obj bname childEname childEd childTyp)
  ;; 转角/对齐等尺寸标注高速改色：
  ;; 1. 剥离文字覆盖中的内嵌颜色控制码（如 \C1;）
  ;; 2. 修改标注实体 DXF 62 组码
  ;; 3. 通过 COM 属性设置尺寸线、尺寸界线、文字及整体颜色覆盖
  ;; 4. 原生指针极速单趟遍历匿名块 (*D...) 定义内部图元（界线、箭头、文字），统一改色
  ;; 注意：不在循环中逐图元调用 entupd / vla-Update，最后由命令统一 Regen 刷新，保证毫秒级极速响应
  (if (and ename (setq ed (entget ename)))
    (progn
      ;; 1. 检查并剥离标注文字中的内嵌颜色控制码
      (setq txt (cdr (assoc 1 ed)))
      (if (and txt (/= txt "") (or (vl-string-search "\\C" txt) (vl-string-search "\\c" txt)))
        (progn
          (setq new-txt (aa:strip-mtext-color-format txt))
          (if (/= new-txt txt)
            (progn
              (setq ed (subst (cons 1 new-txt) (assoc 1 ed) ed))
              (entmod ed)
              (setq ed (entget ename))))))

      ;; 2. 修改标注实体本身的 ACI 颜色（组码 62）
      (aa:set-entity-aci-color ename color)

      ;; 3. 通过 COM 属性设置标注颜色覆盖（尺寸线、界线、文字）
      (setq obj (vl-catch-all-apply 'vlax-ename->vla-object (list ename)))
      (if (and obj (not (vl-catch-all-error-p obj)))
        (progn
          (vl-catch-all-apply 'vla-put-Color (list obj color))
          (vl-catch-all-apply 'vla-put-DimensionLineColor (list obj color))
          (vl-catch-all-apply 'vla-put-ExtensionLineColor (list obj color))
          (vl-catch-all-apply 'vla-put-TextColor (list obj color))
          (vlax-release-object obj)))

      ;; 4. 原生指针极速单趟遍历修改匿名块 (*D...) 定义内部图元，不走 COM 封送开销
      (setq bname (cdr (assoc 2 ed)))
      (if (and bname (/= bname "") (not (member bname visited)))
        (progn
          (setq visited (cons bname visited))
          (setq childEname (cdr (assoc -2 (tblsearch "BLOCK" bname))))
          (while (and childEname
                      (setq childEd (entget childEname))
                      (/= (cdr (assoc 0 childEd)) "ENDBLK"))
            (setq childTyp (cdr (assoc 0 childEd)))
            (cond
              ((= childTyp "MTEXT")
               (setq txt (cdr (assoc 1 childEd)))
               (if (and txt (or (vl-string-search "\\C" txt) (vl-string-search "\\c" txt)))
                 (progn
                   (setq new-txt (aa:strip-mtext-color-format txt))
                   (if (/= new-txt txt)
                     (setq childEd (subst (cons 1 new-txt) (assoc 1 childEd) childEd))))))
              ((= childTyp "INSERT")
               (setq visited (aa:deep-color-block-definition doc (cdr (assoc 2 childEd)) color visited))))
            (aa:set-entity-aci-color childEname color)
            (setq childEname (entnext childEname)))))))
  visited
)

(defun aa:deep-color-attributes (blkObj color / result atts item itemEname)
  ;; 属性参照不属于块定义，单独处理以确保当前选中的块完整改色。
  (setq result (vl-catch-all-apply 'vlax-invoke (list blkObj 'GetAttributes)))
  (if (not (vl-catch-all-error-p result))
    (progn
      (setq atts
        (if (listp result)
          result
          (vl-catch-all-apply 'vlax-safearray->list (list result))))
      (if (not (vl-catch-all-error-p atts))
        (foreach item atts
          (setq itemEname (vl-catch-all-apply 'vlax-vla-object->ename (list item)))
          (if (not (vl-catch-all-error-p itemEname))
            (aa:set-entity-aci-color itemEname color))
          (vlax-release-object item)))))
  result
)

(defun aa:deep-color-block-definition (doc blockName color visited / blocks blockDef result child childEname childEd childTyp childName txt new-txt)
  ;; 通过 BlockTableRecord 修改块内部实体，递归处理嵌套块并避免重复访问。
  ;; 必须返回更新后的 visited 列表：若 visited 落在 if 的 else 分支里，处理过块后
  ;; 会返回 vlax-for 的值 T，调用方把 visited 赋成 T，下一个块 (member blockName T) 报 listp: T。
  (if (and blockName (not (member blockName visited)))
    (progn
      (setq visited (cons blockName visited)
            blocks (vla-get-Blocks doc)
            result (vl-catch-all-apply 'vla-Item (list blocks blockName)))
      (if (not (vl-catch-all-error-p result))
        (progn
          (setq blockDef result)
          (vlax-for child blockDef
            (setq childEname (vl-catch-all-apply 'vlax-vla-object->ename (list child)))
            (if (not (vl-catch-all-error-p childEname))
              (progn
                (setq childEd (entget childEname))
                (setq childTyp (cdr (assoc 0 childEd)))
                (cond
                  ((= childTyp "INSERT")
                   (setq childName (vla-get-Name child))
                   (setq visited (aa:deep-color-block-definition doc childName color visited))
                   (aa:set-entity-aci-color childEname color))
                  ((= childTyp "DIMENSION")
                   (setq visited (aa:deep-color-dimension doc childEname color visited)))
                  ((= childTyp "MTEXT")
                   (setq txt (cdr (assoc 1 childEd)))
                   (if (and txt (or (vl-string-search "\\C" txt) (vl-string-search "\\c" txt)))
                     (progn
                       (setq new-txt (aa:strip-mtext-color-format txt))
                       (if (/= new-txt txt)
                         (entmod (subst (cons 1 new-txt) (assoc 1 childEd) childEd)))))
                   (aa:set-entity-aci-color childEname color))
                  (T
                   (aa:set-entity-aci-color childEname color))))))
          (vlax-release-object blockDef)))
      (if (and blocks (not (vl-catch-all-error-p blocks)))
        (vlax-release-object blocks))))
  visited
)

(defun aa:strip-mtext-color-format (str / idx len out ch next semi)
  ;; 去除 MTEXT 内容中的内嵌颜色控制码（如 \C1; 或 \c255;），保留换行与其余格式
  (if (null str) ""
    (progn
      (setq idx 1
            len (strlen str)
            out "")
      (while (<= idx len)
        (setq ch (substr str idx 1))
        (cond
          ((and (= ch "\\") (<= (+ idx 1) len))
           (setq next (substr str (1+ idx) 1))
           (if (or (= next "C") (= next "c"))
             (progn
               (setq semi (vl-string-search ";" str (+ idx 1)))
               (if semi
                 (setq idx (+ semi 2))
                 (progn
                   (setq out (strcat out ch))
                   (setq idx (1+ idx)))))
             (progn
               (setq out (strcat out ch))
               (setq idx (1+ idx)))))
          (T
           (setq out (strcat out ch))
           (setq idx (1+ idx)))))
      out)))

(defun aa:explode-lead-recursive (ename / queue final-ents cur typ before new-ents)
  ;; 循环分解引线对象（LEADER / MULTILEADER），直到彻底打散为非引线基础图元
  (setq queue (list ename)
        final-ents nil)
  (while queue
    (setq cur (car queue)
          queue (cdr queue))
    (if (and cur (entget cur))
      (progn
        (setq typ (cdr (assoc 0 (entget cur))))
        (if (member typ '("LEADER" "MULTILEADER"))
          (progn
            (setq before (entlast))
            (vl-catch-all-apply 'vl-cmdf (list "_.EXPLODE" cur))
            (if (and (entget cur) (eq before (entlast)))
              (vl-catch-all-apply '(lambda () (command "_.EXPLODE" cur))))
            (setq new-ents nil)
            (while (setq before (entnext before))
              (if (entget before)
                (setq new-ents (cons before new-ents))))
            (if new-ents
              ;; 分解成功，可能包含次级引线（如 MULTILEADER 分解出 LEADER），重新加入队列继续分解
              (setq queue (append new-ents queue))
              ;; 若无法分解（如所在图层被锁定），保留为最终实体避免丢弃
              (setq final-ents (cons cur final-ents))))
          ;; 非引线实体，作为最终图元保留
          (setq final-ents (cons cur final-ents))))))
  (reverse final-ents)
)

(defun aa:deep-explode-and-color (doc ename color visited / ents ent ed typ obj bname txt new-txt)
  ;; 引线先彻底分解为基础图元，然后修改为指定颜色
  (setq ents (aa:explode-lead-recursive ename))
  (foreach ent ents
    (if (and ent (setq ed (entget ent)))
      (progn
        (setq typ (cdr (assoc 0 ed)))
        (cond
          ((= typ "INSERT")
           (setq obj (vlax-ename->vla-object ent)
                 bname (vla-get-Name obj))
           (setq visited (aa:deep-color-block-definition doc bname color visited))
           (aa:deep-color-attributes obj color)
           (vlax-release-object obj)
           (aa:set-entity-aci-color ent color))
          ((= typ "MTEXT")
           (setq txt (cdr (assoc 1 ed)))
           (if (and txt (or (vl-string-search "\\C" txt) (vl-string-search "\\c" txt)))
             (progn
               (setq new-txt (aa:strip-mtext-color-format txt))
               (if (/= new-txt txt)
                 (entmod (subst (cons 1 new-txt) (assoc 1 ed) ed)))))
           (aa:set-entity-aci-color ent color))
          (T
           (aa:set-entity-aci-color ent color))))))
  visited
)

(defun aa:deep-color-cmd (targetColor prompt done / ss i ename ed typ obj doc blockName visited regenResult txt new-txt)
  ;; HUI / WWW 共用：块参照直接改块定义，块内实体（含嵌套块与属性）一并改色，不分解块。
  ;; 遇引线对象（LEADER / MULTILEADER）先分解为基础图元，再统一修改为指定颜色。
  (setq ss (ssget "_I"))
  (if (null ss)
    (progn
      (princ prompt)
      (setq ss (ssget))))

  (if ss
    (progn
      (setq doc (vla-get-ActiveDocument (vlax-get-acad-object))
            visited nil)
      (setq i 0)
      (repeat (sslength ss)
        (setq ename (ssname ss i))
        (if (and ename (setq ed (entget ename)))
          (progn
            (setq typ (cdr (assoc 0 ed)))
            (cond
              ((= typ "INSERT")
               (setq obj (vlax-ename->vla-object ename)
                     blockName (vla-get-Name obj))
               (setq visited (aa:deep-color-block-definition doc blockName targetColor visited))
               (aa:deep-color-attributes obj targetColor)
               (vlax-release-object obj)
               ;; 对块参照本身也设色，兼容块内容使用 ByBlock 的情况。
               (aa:set-entity-aci-color ename targetColor))
              ((member typ '("LEADER" "MULTILEADER"))
               (setq visited (aa:deep-explode-and-color doc ename targetColor visited)))
              ((= typ "DIMENSION")
               (setq visited (aa:deep-color-dimension doc ename targetColor visited)))
              ((= typ "MTEXT")
               (setq txt (cdr (assoc 1 ed)))
               (if (and txt (or (vl-string-search "\\C" txt) (vl-string-search "\\c" txt)))
                 (progn
                   (setq new-txt (aa:strip-mtext-color-format txt))
                   (if (/= new-txt txt)
                     (entmod (subst (cons 1 new-txt) (assoc 1 ed) ed)))))
               (aa:set-entity-aci-color ename targetColor))
              (T
               (aa:set-entity-aci-color ename targetColor)))))
        (setq i (1+ i))
      )
      ;; 修改块定义后必须重新生成视口，普通 redraw 不会立即刷新块参照显示。
      (setq regenResult (vl-catch-all-apply 'vla-Regen (list doc 1)))
      (if (vl-catch-all-error-p regenResult)
        (redraw))
      (sssetfirst nil nil)
      (princ done)
    )
    (princ "\r\n没有选中任何对象。")
  )
  (sssetfirst nil nil)
  (princ)
)

(defun c:HUI (/ *error* aa:tag aa:doc aa:undo-open aa:old-cmdecho)
  (aa:cmd-begin "HUI")
  (aa:deep-color-cmd *HUI_TextColor*
    "\r\n选择要改为颜色 8 的对象: " "\r\n所有选中对象已改为颜色 8。")
  (aa:cmd-end)
)

;;; 功能: 将选中文字统一为中中对正，并以最上方文字为基准居中对齐。
(defun aa:align-text-cmd (tag hint ref-fn edge-fn norm-fn align-fn code axis
                          / *error* aa:tag aa:doc aa:undo-open aa:old-cmdecho
                            ss ref base i ename changed skipped)
  ;; ZHONG / ZUO / YOU / SHANG / XIA 五个对齐命令的共用实现。
  ;;   tag      命令名，用于提示和错误信息
  ;;   hint     动作描述，如 "居中对齐"
  ;;   ref-fn   选取基准文字的函数（最上/最下/最左/最右）
  ;;   edge-fn  从基准包围盒取对齐坐标的函数
  ;;   norm-fn  统一对正方式的函数（水平或垂直）
  ;;   align-fn 按包围盒对齐单个文字的函数
  ;;   code     对正代码：水平 1/2/3 = 左/中/右，垂直 1/2/3 = 上/中/下
  ;;   axis     基准坐标轴名称，仅用于结果提示
  (aa:cmd-begin tag)
  (setq changed 0
        skipped 0)
  (princ (strcat "\r\n[" tag "] 请选择要" hint "的文字..."))
  (if (setq ss (ssget '((0 . "TEXT,MTEXT"))))
    (progn
      ;; 第一阶段：所有文字统一对正方式，同时保持原本的几何位置（X/Y）
      (setq i 0)
      (repeat (sslength ss)
        (setq ename (ssname ss i))
        (apply norm-fn (list aa:doc ename code))
        (setq i (1+ i))
      )
      ;; 第二阶段：在文字对正方式统一后，重新拾取基准文字和基准坐标
      (if (setq ref (apply ref-fn (list aa:doc ss)))
        (progn
          (setq base (apply edge-fn (list (cadr ref)))
                i    0)
          ;; 第三阶段：所有文字（包含基准文字）按统一基准坐标对齐
          (repeat (sslength ss)
            (setq ename (ssname ss i))
            (if (apply align-fn (list aa:doc ename base code))
              (setq changed (1+ changed))
              (setq skipped (1+ skipped)))
            (setq i (1+ i))
          )
          (princ
            (strcat "\r\n[" tag "] 完成。基准 " axis ": " (rtos base 2 4)
                    "，已处理: " (itoa changed)
                    "，跳过: " (itoa skipped) "."))
        )
        (princ (strcat "\r\n[" tag "] 选择中没有有效的文字范围。"))
      )
    )
    (princ (strcat "\r\n[" tag "] 未选择文字对象。"))
  )
  (aa:cmd-end)
)

(defun c:ZHONG ()
  (aa:align-text-cmd "ZHONG" "居中对齐"
    'aa:find-ref-by-top-bbox 'aa:bbox-center-x
    'aa:normalize-text-horizontal-align 'aa:align-text-horizontal-by-bbox 2 "X")
)

(defun aa:set-text-horizontal-align (ename base-x mode / ed typ obj target result)
  (setq ed  (entget ename)
        typ (if ed (cdr (assoc 0 ed)) nil)
        obj (if ed (vlax-ename->vla-object ename) nil))
  (cond
    ((= typ "TEXT")
     (setq target (cond ((= mode 1) 9) ((= mode 3) 11) (T 10))
           result (vl-catch-all-apply 'vla-put-Alignment (list obj target))))
    ((= typ "MTEXT")
     (setq target (cond ((= mode 1) 4) ((= mode 3) 6) (T 5))
           result (vl-catch-all-apply 'vla-put-AttachmentPoint (list obj target))))
    (T
     (setq result nil))
  )
  (if (not (vl-catch-all-error-p result))
    (progn
      (vl-catch-all-apply 'vla-update (list obj))
      (entupd ename)
      (if obj (vlax-release-object obj))
      T)
    (progn
      (if obj (vlax-release-object obj))
      nil))
)

(defun aa:set-text-vertical-align (ename base-y mode / ed typ obj target result)
  (setq ed  (entget ename)
        typ (if ed (cdr (assoc 0 ed)) nil)
        obj (if ed (vlax-ename->vla-object ename) nil))
  (cond
    ((= typ "TEXT")
     (setq target (if (= mode 1) 7 13)
           result (vl-catch-all-apply 'vla-put-Alignment (list obj target))))
    ((= typ "MTEXT")
     (setq target (if (= mode 1) 2 8)
           result (vl-catch-all-apply 'vla-put-AttachmentPoint (list obj target))))
    (T
     (setq result nil))
  )
  (if (not (vl-catch-all-error-p result))
    (progn
      (vl-catch-all-apply 'vla-update (list obj))
      (entupd ename)
      (if obj (vlax-release-object obj))
      T)
    (progn
      (if obj (vlax-release-object obj))
      nil))
)

(defun aa:normalize-text-horizontal-align (doc ename mode / old-bbox new-bbox dx dy)
  (setq old-bbox (aa:safe-get-bbox doc ename))
  (if (aa:set-text-horizontal-align ename 0.0 mode)
    (if (and old-bbox (setq new-bbox (aa:safe-get-bbox doc ename)))
      (progn
        (setq dx (- (aa:bbox-left-x old-bbox) (aa:bbox-left-x new-bbox))
              dy (- (aa:bbox-bottom-y old-bbox) (aa:bbox-bottom-y new-bbox)))
        (if (and (equal dx 0.0 1e-8) (equal dy 0.0 1e-8))
          T
          (aa:safe-move-entity ename (vlax-3d-point (list dx dy 0.0)))))
      T)
    nil)
)

(defun aa:normalize-text-vertical-align (doc ename mode / old-bbox new-bbox dx dy)
  (setq old-bbox (aa:safe-get-bbox doc ename))
  (if (aa:set-text-vertical-align ename 0.0 mode)
    (if (and old-bbox (setq new-bbox (aa:safe-get-bbox doc ename)))
      (progn
        (setq dx (- (aa:bbox-left-x old-bbox) (aa:bbox-left-x new-bbox))
              dy (- (aa:bbox-bottom-y old-bbox) (aa:bbox-bottom-y new-bbox)))
        (if (and (equal dx 0.0 1e-8) (equal dy 0.0 1e-8))
          T
          (aa:safe-move-entity ename (vlax-3d-point (list dx dy 0.0)))))
      T)
    nil)
)

;;; 功能: 将选中文字统一为左中对正，并以最左侧文字为基准左对齐。
(defun c:ZUO ()
  (aa:align-text-cmd "ZUO" "左对齐"
    'aa:find-ref-by-left-bbox 'aa:bbox-left-x
    'aa:normalize-text-horizontal-align 'aa:align-text-horizontal-by-bbox 1 "X")
)

;;; =======================================================================================
;;; 命令: AZUO
;;; 功能: 选择一条竖直直线作为基准线（支持预选），再连续框选其他对象（每批作为一个整体）向左对齐到该直线，按回车或 Esc 退出。
;;; =======================================================================================
(defun c:AZUO (/ *error* aa:tag aa:doc aa:undo-open aa:old-cmdecho
                 ent-sel ref-line ref-ed typ p10 p11 ref-x pre-ss
                 keep-looping ss i en bbox min-x dx move-ents cur-ent cur-ed batch-count)
  (aa:cmd-begin "AZUO")
  (vl-load-com)

  ;; 0. 支持预选检查：如果用户在执行命令前已单选了一条直线
  (if (setq pre-ss (ssget "_I"))
    (progn
      (if (= (sslength pre-ss) 1)
        (progn
          (setq cur-ent (ssname pre-ss 0)
                ref-ed  (entget cur-ent)
                typ     (cdr (assoc 0 ref-ed)))
          (if (= typ "LINE")
            (progn
              (setq p10 (cdr (assoc 10 ref-ed))
                    p11 (cdr (assoc 11 ref-ed)))
              (if (equal (car p10) (car p11) 1e-4)
                (setq ref-line cur-ent
                      ref-x    (car p10))
                (princ "\r\n[AZUO] 预选直线不是竖直直线。")
              )
            )
            (princ "\r\n[AZUO] 预选对象不是直线(LINE)。")
          )
        )
        (princ "\r\n[AZUO] 预选对象多于1个，请按提示重新点选单条基准竖直直线。")
      )
      (sssetfirst nil nil) ; 清除预选亮显状态
      (if ref-line
        (redraw ref-line 3)) ; 高亮基准线
    )
  )

  ;; 1. 若未预选或预选无效，提示用户拾取一条竖直直线作为对齐基准线
  (while (and (null ref-line)
              (setq ent-sel (entsel "\r\n[AZUO] 请选择作为对齐基准的竖直直线: ")))
    (setq cur-ent (car ent-sel)
          ref-ed  (entget cur-ent)
          typ     (cdr (assoc 0 ref-ed)))
    (if (= typ "LINE")
      (progn
        (setq p10 (cdr (assoc 10 ref-ed))
              p11 (cdr (assoc 11 ref-ed)))
        (if (equal (car p10) (car p11) 1e-4)
          (progn
            (setq ref-line cur-ent
                  ref-x    (car p10))
            (redraw ref-line 3)) ; 高亮基准线
          (princ "\r\n[AZUO] 所选直线不是竖直直线，请重新选择。")
        )
      )
      (princ "\r\n[AZUO] 所选对象不是直线(LINE)，请重新选择。")
    )
  )

  (if (null ref-line)
    (progn
      (princ "\r\n[AZUO] 未选择基准竖直直线，命令已退出。")
      (aa:cmd-end)
    )
    (progn
      ;; 2. 连续对齐循环：每次框选一批对象整体对齐，回车空选或 Esc 结束
      (setq keep-looping T
            batch-count  0)
      (while keep-looping
        (princ "\r\n[AZUO] 请框选要对齐的对象 (直接按空格/回车或Esc退出): ")
        (setq ss (ssget))
        (if (null ss)
          (setq keep-looping nil) ; 空选即退出连续循环
          (progn
            ;; 排除基准线本身，并计算当前批次所有有效对象的整体左边界 (min-x)
            (setq move-ents '()
                  min-x     nil
                  i         0)
            (repeat (sslength ss)
              (setq en (ssname ss i))
              (if (not (eq en ref-line))
                (progn
                  (setq cur-ed (entget en))
                  (if (and cur-ed (aa:safe-get-bbox aa:doc en))
                    (progn
                      (setq bbox (aa:safe-get-bbox aa:doc en))
                      (if (or (null min-x) (< (aa:bbox-left-x bbox) min-x))
                        (setq min-x (aa:bbox-left-x bbox)))
                      (setq move-ents (cons en move-ents))
                    )
                  )
                )
              )
              (setq i (1+ i))
            )

            (if (or (null move-ents) (null min-x))
              (princ "\r\n[AZUO] 本批所选对象中没有可计算包围盒的有效图形。")
              (progn
                (setq dx (- ref-x min-x))
                (if (equal dx 0.0 1e-8)
                  (princ (strcat "\r\n[AZUO] 本批对象的左边界已经在基准线上 (X=" (rtos ref-x 2 4) ")，无需移动。"))
                  (progn
                    (foreach en move-ents
                      (aa:safe-move-entity en (list dx 0.0 0.0)))
                    (setq batch-count (1+ batch-count))
                    (princ (strcat "\r\n[AZUO] 第 " (itoa batch-count) " 批对齐完成！"
                                   "整体移动 DX=" (rtos dx 2 4)
                                   "，包含 " (itoa (length move-ents)) " 个对象。"))
                  )
                )
              )
            )
          )
        )
      )
      (redraw ref-line 4) ; 恢复基准线显示
      (princ (strcat "\r\n[AZUO] 连续对齐结束，共完成 " (itoa batch-count) " 批对象对齐。"))
      (aa:cmd-end)
    )
  )
)

;;; =======================================================================================
;;; 命令: HP
;;; 功能: 将选中文字按从左到右排列，使相邻文字首尾间距为指定值，并按最左文字上边对齐。
;;; =======================================================================================
(defun c:HP (/ *error* aa:tag aa:doc aa:undo-open aa:old-cmdecho step ss i ename edata ht total_ht avg_ht col_tol
             bbox items cols current_col base_col_x sorted_col sorted_items ref ref-bbox base-top
             current-right it item-width target-left dx dy changed skipped)
  (aa:cmd-begin "HP")
  (vl-load-com)
  (setq step (getdist "\r\n请输入相邻文字首尾间距 <5>: "))
  (if (null step)
    (setq step 5.0))

  (setq ss (ssget "_I" '((0 . "TEXT,MTEXT"))))
  (if (null ss)
    (progn
      (princ "\r\n[HP] 选择要左右排列的文字对象: ")
      (setq ss (ssget '((0 . "TEXT,MTEXT"))))))

  (if (not ss)
    (progn
      (princ "\r\n[HP] 未选择文字对象。")
      (aa:cmd-end)
    )
    (progn
      (setq i 0
            items '()
            total_ht 0.0
            changed 0
            skipped 0)
      (repeat (sslength ss)
        (setq ename (ssname ss i)
              bbox  (aa:safe-get-bbox aa:doc ename))
        (if bbox
          (progn
            (setq edata (entget ename)
                  ht    (cdr (assoc 40 edata)))
            (if (or (null ht) (<= ht 0.0))
              (setq ht 3.5))
            (setq total_ht (+ total_ht ht))
            ;; 记录项结构: (left_x top_y ename bbox)
            (setq items (cons (list (aa:bbox-left-x bbox)
                                    (aa:bbox-top-y bbox)
                                    ename
                                    bbox)
                              items))
          )
          (setq skipped (1+ skipped))
        )
        (setq i (1+ i))
      )

      (if (null items)
        (princ "\r\n[HP] 选择中没有有效的文字范围。")
        (progn
          ;; 动态计算列容差（以平均字高的 0.6 倍为同一列容差，最小 1.0）
          (setq avg_ht  (/ total_ht (max 1 (length items)))
                col_tol (max 1.0 (* avg_ht 0.6)))

          ;; 1. 先按左边界 X 坐标从小到大排序（从左到右初排）
          (setq items
            (aa:merge-sort
              items
              '(lambda (a b)
                 (< (car a) (car b)))))

          ;; 2. 聚类分列：水平距离在 col_tol 内的文字归入同一列
          (setq cols '()
                current_col '()
                base_col_x nil)
          (foreach it items
            (if (null current_col)
              (setq current_col (list it)
                    base_col_x  (car it))
              (if (<= (abs (- (car it) base_col_x)) col_tol)
                (setq current_col (cons it current_col))
                (progn
                  (setq cols (cons current_col cols)
                        current_col (list it)
                        base_col_x  (car it))
                )
              )
            )
          )
          (if current_col
            (setq cols (cons current_col cols))
          )
          (setq cols (reverse cols))

          ;; 3. 每列内部按 Y 坐标从大到小（从上到下）排序，展平成全局有序列表
          ;; 保证处于同一竖直线的文字：越靠上排在越靠左（自左向右依次向下）
          (setq sorted_items '())
          (foreach col cols
            (setq sorted_col
              (aa:merge-sort
                col
                '(lambda (a b)
                   (> (cadr a) (cadr b)))))
            (setq sorted_items (append sorted_items sorted_col))
          )

          ;; 4. 排列对齐：以排在最左侧（最上方）的文字为基准锚点
          (setq ref           (car sorted_items)
                ref-bbox      (nth 3 ref)
                base-top      (aa:bbox-top-y ref-bbox)
                current-right (aa:bbox-right-x ref-bbox))

          (foreach it sorted_items
            (setq ename (nth 2 it)
                  bbox  (nth 3 it))
            (if (eq ename (nth 2 ref))
              (setq changed (1+ changed))
              (progn
                (setq item-width   (- (aa:bbox-right-x bbox) (aa:bbox-left-x bbox))
                      target-left  (+ current-right step)
                      dx           (- target-left (aa:bbox-left-x bbox))
                      dy           (- base-top (aa:bbox-top-y bbox)))
                (if (aa:safe-move-entity ename (vlax-3d-point (list dx dy 0.0)))
                  (setq changed (1+ changed))
                  (setq skipped (1+ skipped))
                )
                (setq current-right (+ target-left item-width))
              )
            )
          )
          (redraw)
          (princ
            (strcat
              "\r\n[HP] 完成。间距: "
              (rtos step 2 4)
              "，已处理: "
              (itoa changed)
              "，跳过: "
              (itoa skipped)
              "."))
        )
      )
      (aa:cmd-end)
    )
  )
  (princ)
)

;;; =======================================================================================
;;; 命令: HP2
;;; 功能: 将选中文字改为正中对齐，按中心点指定间距从左到右横向排列。
;;; =======================================================================================
(defun c:HP2 (/ *error* aa:tag aa:doc aa:undo-open aa:old-cmdecho step ss i ename edata ht total_ht avg_ht col_tol
               bbox items cols current_col base_col_x sorted_col sorted_items ref base-cx base-cy
               target-cx target-cy dx dy changed skipped k it)
  (aa:cmd-begin "HP2")
  (vl-load-com)
  (setq step (getdist "\r\n请输入相邻文字中心间距 <50>: "))
  (if (null step)
    (setq step 50.0))
  (setq step (abs step))
  (if (zerop step)
    (setq step 50.0))

  (setq ss (ssget "_I" '((0 . "TEXT,MTEXT"))))
  (if (null ss)
    (progn
      (princ "\r\n[HP2] 选择要左右排列的文字对象: ")
      (setq ss (ssget '((0 . "TEXT,MTEXT"))))))

  (if (not ss)
    (progn
      (princ "\r\n[HP2] 未选择文字对象。")
      (aa:cmd-end)
    )
    (progn
      (setq i 0
            items '()
            total_ht 0.0
            changed 0
            skipped 0)
      (repeat (sslength ss)
        (setq ename (ssname ss i))
        ;; 先将文字统一为正中对齐 (Middle Center)，消除属性修改引起的跳动
        (aa:normalize-text-horizontal-align aa:doc ename 2)
        (setq bbox (aa:safe-get-bbox aa:doc ename))
        (if bbox
          (progn
            (setq edata (entget ename)
                  ht    (cdr (assoc 40 edata)))
            (if (or (null ht) (<= ht 0.0))
              (setq ht 3.5))
            (setq total_ht (+ total_ht ht))
            ;; 记录项结构: (center_x center_y ename bbox)
            (setq items (cons (list (aa:bbox-center-x bbox)
                                    (/ (+ (aa:bbox-top-y bbox) (aa:bbox-bottom-y bbox)) 2.0)
                                    ename
                                    bbox)
                              items))
          )
          (setq skipped (1+ skipped))
        )
        (setq i (1+ i))
      )

      (if (null items)
        (princ "\r\n[HP2] 选择中没有有效的文字范围。")
        (progn
          ;; 动态计算列容差（以平均字高的 0.6 倍为同一列容差，最小 1.0）
          (setq avg_ht  (/ total_ht (max 1 (length items)))
                col_tol (max 1.0 (* avg_ht 0.6)))

          ;; 1. 先按中心 X 坐标从小到大排序（从左到右初排）
          (setq items
            (aa:merge-sort
              items
              '(lambda (a b)
                 (< (car a) (car b)))))

          ;; 2. 聚类分列：水平距离在 col_tol 内的文字归入同一列
          (setq cols '()
                current_col '()
                base_col_x nil)
          (foreach it items
            (if (null current_col)
              (setq current_col (list it)
                    base_col_x  (car it))
              (if (<= (abs (- (car it) base_col_x)) col_tol)
                (setq current_col (cons it current_col))
                (progn
                  (setq cols (cons current_col cols)
                        current_col (list it)
                        base_col_x  (car it))
                )
              )
            )
          )
          (if current_col
            (setq cols (cons current_col cols))
          )
          (setq cols (reverse cols))

          ;; 3. 每列内部按中心 Y 坐标从大到小（从上到下）排序，展平成全局有序列表
          (setq sorted_items '())
          (foreach col cols
            (setq sorted_col
              (aa:merge-sort
                col
                '(lambda (a b)
                   (> (cadr a) (cadr b)))))
            (setq sorted_items (append sorted_items sorted_col))
          )

          ;; 4. 排列对齐：以排在最左侧（最上方）的文字中心为基准锚点
          (setq ref     (car sorted_items)
                base-cx (car ref)
                base-cy (cadr ref)
                k       0)

          (foreach it sorted_items
            (setq ename (nth 2 it))
            (if (zerop k)
              (setq changed (1+ changed))
              (progn
                (setq target-cx (+ base-cx (* k step))
                      target-cy base-cy
                      dx        (- target-cx (nth 0 it))
                      dy        (- target-cy (nth 1 it)))
                (if (and (equal dx 0.0 1e-8) (equal dy 0.0 1e-8))
                  (setq changed (1+ changed))
                  (if (aa:safe-move-entity ename (vlax-3d-point (list dx dy 0.0)))
                    (setq changed (1+ changed))
                    (setq skipped (1+ skipped))
                  )
                )
              )
            )
            (setq k (1+ k))
          )
          (redraw)
          (princ
            (strcat
              "\r\n[HP2] 完成。中心间距: "
              (rtos step 2 4)
              "，已处理: "
              (itoa changed)
              "，跳过: "
              (itoa skipped)
              "."))
        )
      )
      (aa:cmd-end)
    )
  )
  (princ)
)

;;; 功能: 将选中文字统一为右中对正，并以最右侧文字为基准右对齐。
(defun c:YOU ()
  (aa:align-text-cmd "YOU" "右对齐"
    'aa:find-ref-by-right-bbox 'aa:bbox-right-x
    'aa:normalize-text-horizontal-align 'aa:align-text-horizontal-by-bbox 3 "X")
)
;;; =======================================================================================
;;; 命令: AYOU
;;; 功能: 选择一条竖直直线作为基准线（支持预选），再连续框选其他对象（每批作为一个整体）向右对齐到该直线，按回车或 Esc 退出。
;;; =======================================================================================
(defun c:AYOU (/ *error* aa:tag aa:doc aa:undo-open aa:old-cmdecho
                 ent-sel ref-line ref-ed typ p10 p11 ref-x pre-ss
                 keep-looping ss i en bbox max-x dx move-ents cur-ent cur-ed batch-count)
  (aa:cmd-begin "AYOU")
  (vl-load-com)

  ;; 0. 支持预选检查：如果用户在执行命令前已单选了一条直线
  (if (setq pre-ss (ssget "_I"))
    (progn
      (if (= (sslength pre-ss) 1)
        (progn
          (setq cur-ent (ssname pre-ss 0)
                ref-ed  (entget cur-ent)
                typ     (cdr (assoc 0 ref-ed)))
          (if (= typ "LINE")
            (progn
              (setq p10 (cdr (assoc 10 ref-ed))
                    p11 (cdr (assoc 11 ref-ed)))
              (if (equal (car p10) (car p11) 1e-4)
                (setq ref-line cur-ent
                      ref-x    (car p10))
                (princ "\r\n[AYOU] 预选直线不是竖直直线。")
              )
            )
            (princ "\r\n[AYOU] 预选对象不是直线(LINE)。")
          )
        )
        (princ "\r\n[AYOU] 预选对象多于1个，请按提示重新点选单条基准竖直直线。")
      )
      (sssetfirst nil nil) ; 清除预选亮显状态
      (if ref-line
        (redraw ref-line 3)) ; 高亮基准线
    )
  )

  ;; 1. 若未预选或预选无效，提示用户拾取一条竖直直线作为对齐基准线
  (while (and (null ref-line)
              (setq ent-sel (entsel "\r\n[AYOU] 请选择作为对齐基准的竖直直线: ")))
    (setq cur-ent (car ent-sel)
          ref-ed  (entget cur-ent)
          typ     (cdr (assoc 0 ref-ed)))
    (if (= typ "LINE")
      (progn
        (setq p10 (cdr (assoc 10 ref-ed))
              p11 (cdr (assoc 11 ref-ed)))
        (if (equal (car p10) (car p11) 1e-4)
          (progn
            (setq ref-line cur-ent
                  ref-x    (car p10))
            (redraw ref-line 3)) ; 高亮基准线
          (princ "\r\n[AYOU] 所选直线不是竖直直线，请重新选择。")
        )
      )
      (princ "\r\n[AYOU] 所选对象不是直线(LINE)，请重新选择。")
    )
  )

  (if (null ref-line)
    (progn
      (princ "\r\n[AYOU] 未选择基准竖直直线，命令已退出。")
      (aa:cmd-end)
    )
    (progn
      ;; 2. 连续对齐循环：每次框选一批对象整体对齐，回车空选或 Esc 结束
      (setq keep-looping T
            batch-count  0)
      (while keep-looping
        (princ "\r\n[AYOU] 请框选要对齐的对象 (直接按空格/回车或Esc退出): ")
        (setq ss (ssget))
        (if (null ss)
          (setq keep-looping nil) ; 空选即退出连续循环
          (progn
            ;; 排除基准线本身，并计算当前批次所有有效对象的整体右边界 (max-x)
            (setq move-ents '()
                  max-x     nil
                  i         0)
            (repeat (sslength ss)
              (setq en (ssname ss i))
              (if (not (eq en ref-line))
                (progn
                  (setq cur-ed (entget en))
                  (if (and cur-ed (aa:safe-get-bbox aa:doc en))
                    (progn
                      (setq bbox (aa:safe-get-bbox aa:doc en))
                      (if (or (null max-x) (> (aa:bbox-right-x bbox) max-x))
                        (setq max-x (aa:bbox-right-x bbox)))
                      (setq move-ents (cons en move-ents))
                    )
                  )
                )
              )
              (setq i (1+ i))
            )

            (if (or (null move-ents) (null max-x))
              (princ "\r\n[AYOU] 本批所选对象中没有可计算包围盒的有效图形。")
              (progn
                (setq dx (- ref-x max-x))
                (if (equal dx 0.0 1e-8)
                  (princ (strcat "\r\n[AYOU] 本批对象的右边界已经在基准线上 (X=" (rtos ref-x 2 4) ")，无需移动。"))
                  (progn
                    (foreach en move-ents
                      (aa:safe-move-entity en (list dx 0.0 0.0)))
                    (setq batch-count (1+ batch-count))
                    (princ (strcat "\r\n[AYOU] 第 " (itoa batch-count) " 批对齐完成！"
                                   "整体移动 DX=" (rtos dx 2 4)
                                   "，包含 " (itoa (length move-ents)) " 个对象。"))
                  )
                )
              )
            )
          )
        )
      )
      (redraw ref-line 4) ; 恢复基准线显示
      (princ (strcat "\r\n[AYOU] 连续对齐结束，共完成 " (itoa batch-count) " 批对象对齐。"))
      (aa:cmd-end)
    )
  )
)

;;; 功能: 将选中文字统一为中上对正，并以最上方文字为基准上对齐。
(defun c:SHANG ()
  (aa:align-text-cmd "SHANG" "上对齐"
    'aa:find-ref-by-top-bbox 'aa:bbox-top-y
    'aa:normalize-text-vertical-align 'aa:align-text-vertical-by-bbox 1 "Y")
)

;;; =======================================================================================
;;; 命令: ASHANG
;;; 功能: 选择一条水平直线作为基准线（支持预选），再连续框选其他对象（每批作为一个整体）向上对齐到该直线，按回车或 Esc 退出。
;;; =======================================================================================
(defun c:ASHANG (/ *error* aa:tag aa:doc aa:undo-open aa:old-cmdecho
                   ent-sel ref-line ref-ed typ p10 p11 ref-y pre-ss
                   keep-looping ss i en bbox max-y dy move-ents cur-ent cur-ed batch-count)
  (aa:cmd-begin "ASHANG")
  (vl-load-com)

  ;; 0. 支持预选检查：如果用户在执行命令前已单选了一条直线
  (if (setq pre-ss (ssget "_I"))
    (progn
      (if (= (sslength pre-ss) 1)
        (progn
          (setq cur-ent (ssname pre-ss 0)
                ref-ed  (entget cur-ent)
                typ     (cdr (assoc 0 ref-ed)))
          (if (= typ "LINE")
            (progn
              (setq p10 (cdr (assoc 10 ref-ed))
                    p11 (cdr (assoc 11 ref-ed)))
              (if (equal (cadr p10) (cadr p11) 1e-4)
                (setq ref-line cur-ent
                      ref-y    (cadr p10))
                (princ "\r\n[ASHANG] 预选直线不是水平直线。")
              )
            )
            (princ "\r\n[ASHANG] 预选对象不是直线(LINE)。")
          )
        )
        (princ "\r\n[ASHANG] 预选对象多于1个，请按提示重新点选单条基准水平直线。")
      )
      (sssetfirst nil nil) ; 清除预选亮显状态
      (if ref-line
        (redraw ref-line 3)) ; 高亮基准线
    )
  )

  ;; 1. 若未预选或预选无效，提示用户拾取一条水平直线作为对齐基准线
  (while (and (null ref-line)
              (setq ent-sel (entsel "\r\n[ASHANG] 请选择作为对齐基准的水平直线: ")))
    (setq cur-ent (car ent-sel)
          ref-ed  (entget cur-ent)
          typ     (cdr (assoc 0 ref-ed)))
    (if (= typ "LINE")
      (progn
        (setq p10 (cdr (assoc 10 ref-ed))
              p11 (cdr (assoc 11 ref-ed)))
        (if (equal (cadr p10) (cadr p11) 1e-4)
          (progn
            (setq ref-line cur-ent
                  ref-y    (cadr p10))
            (redraw ref-line 3)) ; 高亮基准线
          (princ "\r\n[ASHANG] 所选直线不是水平直线，请重新选择。")
        )
      )
      (princ "\r\n[ASHANG] 所选对象不是直线(LINE)，请重新选择。")
    )
  )

  (if (null ref-line)
    (progn
      (princ "\r\n[ASHANG] 未选择基准水平直线，命令已退出。")
      (aa:cmd-end)
    )
    (progn
      ;; 2. 连续对齐循环：每次框选一批对象整体对齐，回车空选或 Esc 结束
      (setq keep-looping T
            batch-count  0)
      (while keep-looping
        (princ "\r\n[ASHANG] 请框选要对齐的对象 (直接按空格/回车或Esc退出): ")
        (setq ss (ssget))
        (if (null ss)
          (setq keep-looping nil) ; 空选即退出连续循环
          (progn
            ;; 排除基准线本身，并计算当前批次所有有效对象的整体上边界 (max-y)
            (setq move-ents '()
                  max-y     nil
                  i         0)
            (repeat (sslength ss)
              (setq en (ssname ss i))
              (if (not (eq en ref-line))
                (progn
                  (setq cur-ed (entget en))
                  (if (and cur-ed (aa:safe-get-bbox aa:doc en))
                    (progn
                      (setq bbox (aa:safe-get-bbox aa:doc en))
                      (if (or (null max-y) (> (aa:bbox-top-y bbox) max-y))
                        (setq max-y (aa:bbox-top-y bbox)))
                      (setq move-ents (cons en move-ents))
                    )
                  )
                )
              )
              (setq i (1+ i))
            )

            (if (or (null move-ents) (null max-y))
              (princ "\r\n[ASHANG] 本批所选对象中没有可计算包围盒的有效图形。")
              (progn
                (setq dy (- ref-y max-y))
                (if (equal dy 0.0 1e-8)
                  (princ (strcat "\r\n[ASHANG] 本批对象的上边界已经在基准线上 (Y=" (rtos ref-y 2 4) ")，无需移动。"))
                  (progn
                    (foreach en move-ents
                      (aa:safe-move-entity en (list 0.0 dy 0.0)))
                    (setq batch-count (1+ batch-count))
                    (princ (strcat "\r\n[ASHANG] 第 " (itoa batch-count) " 批对齐完成！"
                                   "整体移动 DY=" (rtos dy 2 4)
                                   "，包含 " (itoa (length move-ents)) " 个对象。"))
                  )
                )
              )
            )
          )
        )
      )
      (redraw ref-line 4) ; 恢复基准线显示
      (princ (strcat "\r\n[ASHANG] 连续对齐结束，共完成 " (itoa batch-count) " 批对象对齐。"))
      (aa:cmd-end)
    )
  )
)

;;; 功能: 将选中文字统一为中下对正，并以最下方文字为基准下对齐。
(defun c:XIA ()
  (aa:align-text-cmd "XIA" "下对齐"
    'aa:find-ref-by-bottom-bbox 'aa:bbox-bottom-y
    'aa:normalize-text-vertical-align 'aa:align-text-vertical-by-bbox 3 "Y")
)
;;; =======================================================================================
;;; 命令: AXIA
;;; 功能: 选择一条水平直线作为基准线（支持预选），再连续框选其他对象（每批作为一个整体）向下对齐到该直线，按回车或 Esc 退出。
;;; =======================================================================================
(defun c:AXIA (/ *error* aa:tag aa:doc aa:undo-open aa:old-cmdecho
                 ent-sel ref-line ref-ed typ p10 p11 ref-y pre-ss
                 keep-looping ss i en bbox min-y dy move-ents cur-ent cur-ed batch-count)
  (aa:cmd-begin "AXIA")
  (vl-load-com)

  ;; 0. 支持预选检查：如果用户在执行命令前已单选了一条直线
  (if (setq pre-ss (ssget "_I"))
    (progn
      (if (= (sslength pre-ss) 1)
        (progn
          (setq cur-ent (ssname pre-ss 0)
                ref-ed  (entget cur-ent)
                typ     (cdr (assoc 0 ref-ed)))
          (if (= typ "LINE")
            (progn
              (setq p10 (cdr (assoc 10 ref-ed))
                    p11 (cdr (assoc 11 ref-ed)))
              (if (equal (cadr p10) (cadr p11) 1e-4)
                (setq ref-line cur-ent
                      ref-y    (cadr p10))
                (princ "\r\n[AXIA] 预选直线不是水平直线。")
              )
            )
            (princ "\r\n[AXIA] 预选对象不是直线(LINE)。")
          )
        )
        (princ "\r\n[AXIA] 预选对象多于1个，请按提示重新点选单条基准水平直线。")
      )
      (sssetfirst nil nil) ; 清除预选亮显状态
      (if ref-line
        (redraw ref-line 3)) ; 高亮基准线
    )
  )

  ;; 1. 若未预选或预选无效，提示用户拾取一条水平直线作为对齐基准线
  (while (and (null ref-line)
              (setq ent-sel (entsel "\r\n[AXIA] 请选择作为对齐基准的水平直线: ")))
    (setq cur-ent (car ent-sel)
          ref-ed  (entget cur-ent)
          typ     (cdr (assoc 0 ref-ed)))
    (if (= typ "LINE")
      (progn
        (setq p10 (cdr (assoc 10 ref-ed))
              p11 (cdr (assoc 11 ref-ed)))
        (if (equal (cadr p10) (cadr p11) 1e-4)
          (progn
            (setq ref-line cur-ent
                  ref-y    (cadr p10))
            (redraw ref-line 3)) ; 高亮基准线
          (princ "\r\n[AXIA] 所选直线不是水平直线，请重新选择。")
        )
      )
      (princ "\r\n[AXIA] 所选对象不是直线(LINE)，请重新选择。")
    )
  )

  (if (null ref-line)
    (progn
      (princ "\r\n[AXIA] 未选择基准水平直线，命令已退出。")
      (aa:cmd-end)
    )
    (progn
      ;; 2. 连续对齐循环：每次框选一批对象整体对齐，回车空选或 Esc 结束
      (setq keep-looping T
            batch-count  0)
      (while keep-looping
        (princ "\r\n[AXIA] 请框选要对齐的对象 (直接按空格/回车或Esc退出): ")
        (setq ss (ssget))
        (if (null ss)
          (setq keep-looping nil) ; 空选即退出连续循环
          (progn
            ;; 排除基准线本身，并计算当前批次所有有效对象的整体下边界 (min-y)
            (setq move-ents '()
                  min-y     nil
                  i         0)
            (repeat (sslength ss)
              (setq en (ssname ss i))
              (if (not (eq en ref-line))
                (progn
                  (setq cur-ed (entget en))
                  (if (and cur-ed (aa:safe-get-bbox aa:doc en))
                    (progn
                      (setq bbox (aa:safe-get-bbox aa:doc en))
                      (if (or (null min-y) (< (aa:bbox-bottom-y bbox) min-y))
                        (setq min-y (aa:bbox-bottom-y bbox)))
                      (setq move-ents (cons en move-ents))
                    )
                  )
                )
              )
              (setq i (1+ i))
            )

            (if (or (null move-ents) (null min-y))
              (princ "\r\n[AXIA] 本批所选对象中没有可计算包围盒的有效图形。")
              (progn
                (setq dy (- ref-y min-y))
                (if (equal dy 0.0 1e-8)
                  (princ (strcat "\r\n[AXIA] 本批对象的下边界已经在基准线上 (Y=" (rtos ref-y 2 4) ")，无需移动。"))
                  (progn
                    (foreach en move-ents
                      (aa:safe-move-entity en (list 0.0 dy 0.0)))
                    (setq batch-count (1+ batch-count))
                    (princ (strcat "\r\n[AXIA] 第 " (itoa batch-count) " 批对齐完成！"
                                   "整体移动 DY=" (rtos dy 2 4)
                                   "，包含 " (itoa (length move-ents)) " 个对象。"))
                  )
                )
              )
            )
          )
        )
      )
      (redraw ref-line 4) ; 恢复基准线显示
      (princ (strcat "\r\n[AXIA] 连续对齐结束，共完成 " (itoa batch-count) " 批对象对齐。"))
      (aa:cmd-end)
    )
  )
)

(defun c:HE (/ *error* aa:tag aa:doc aa:undo-open aa:old-cmdecho ss lst i ent ent-data pt txt ht sorted-lst master-ent master-data new-str
             vobj pt-min-var pt-max-var old-left-x new-left-x delta-x mv-from mv-to)
  (aa:cmd-begin "HE")
  (vl-load-com) ;; 加载 VL 扩展函数
  
  (princ "\r\n请选择需要合并的文字(按照从上到下，从左到右的逻辑合并):")
  
  ;; 1. 选择文字对象 (过滤 Text 和 MText)
  (if (setq ss (ssget '((0 . "TEXT,MTEXT"))))
    (progn
      (setq lst '())
      (setq i 0)
      
      ;; 2. 遍历选择集，提取实体名、坐标、高度和内容
      (repeat (sslength ss)
        (setq ent (ssname ss i))
        (setq ent-data (entget ent))
        (setq pt (cdr (assoc 10 ent-data))) ;; 插入点
        (setq txt (cdr (assoc 1 ent-data))) ;; 文字内容
        (setq ht (cdr (assoc 40 ent-data))) ;; 文字高度 (用于判断容差)
        
        ;; 将数据存入列表: (实体名 插入点 文字内容 文字高度)
        (setq lst (cons (list ent pt txt ht) lst))
        (setq i (1+ i))
      )
      
      ;; 3. 排序算法 (修正版：去除 let，使用标准 AutoLISP)
      (setq sorted-lst 
        (aa:insert-sort lst
          (function (lambda (e1 e2 / p1 p2 h y1 y2 x1 x2)
            ;; 提取变量
            (setq p1 (cadr e1))
            (setq p2 (cadr e2))
            (setq h (cadddr e1)) ;; 使用第一个对象的文字高度做参考
            (setq y1 (cadr p1))
            (setq y2 (cadr p2))
            (setq x1 (car p1))
            (setq x2 (car p2))
            
            ;; 判断逻辑
            (if (> (abs (- y1 y2)) (* h 0.5))
              (> y1 y2) ;; Y轴差值大：按Y从大到小(上到下)
              (< x1 x2) ;; Y轴差值小(同一行)：按X从小到大(左到右)
            )
          ))
        )
      )
      
      ;; 4. 合并文字
      (setq master-ent (car (car sorted-lst))) ;; 获取排序后的第一个实体作为主实体
      (setq new-str "")
      
      ;; 遍历排序后的列表，拼接字符串
      (foreach item sorted-lst
        (setq new-str (strcat new-str (caddr item)))
      )
      
      ;; 5. 更新主实体并删除其他实体
      ;; 5a. 记录修改前主实体的左边缘 X
      (setq vobj (vlax-ename->vla-object master-ent))
      (vla-getboundingbox vobj 'pt-min-var 'pt-max-var)
      (setq old-left-x (car (vlax-safearray->list pt-min-var)))
      
      ;; 5b. 写入合并后的新天文字串
      (setq master-data (entget master-ent))
      (setq master-data (subst (cons 1 new-str) (assoc 1 master-data) master-data))
      (entmod master-data)
      (entupd master-ent)
      
      ;; 5c. 取目前左边缘 X，按差值平移回原线
      ;;     这样无论主实体是何种对齐方式，最左边沿不移动
      (vla-getboundingbox vobj 'pt-min-var 'pt-max-var)
      (setq new-left-x (car (vlax-safearray->list pt-min-var)))
      (setq delta-x (- old-left-x new-left-x))
      (if (not (equal delta-x 0.0 1e-9))
        (progn
          (setq mv-from (list 0.0 0.0 0.0))
          (setq mv-to   (list delta-x 0.0 0.0))
          (vla-move vobj (vlax-3d-point mv-from) (vlax-3d-point mv-to))
        )
      )
      (vlax-release-object vobj)
      
      ;; 删除其余实体
      (foreach item (cdr sorted-lst)
        (entdel (car item))
      )
      
      (princ (strcat "\r\n成功合并 " (itoa (length sorted-lst)) " 个文字对象。结果: " new-str))
    )
    (princ "\r\n未选中任何文字对象。")
  )
  (aa:cmd-end)
)


;;; =======================================================================================
;;; 命令: QR
;;; 功能: 快速修改选中文字对象的高度；记忆上次高度，直接回车即沿用。
;;; 记忆: 本图会话内存于 *QR_Last_Height*，并用 setenv "AA_QR_Height" 跨图纸/重启保留。
;;; =======================================================================================
(setq *QR_Last_Height* nil) ; (QR) 记录上次使用的文字高度

;; 读取 QR 上次高度：优先本图全局变量，其次 CAD 环境变量；无效返回 nil。
(defun qr:last-height (/ s v)
  (cond
    ((and (numberp *QR_Last_Height*) (> *QR_Last_Height* 0)) *QR_Last_Height*)
    ((and (setq s (vl-catch-all-apply 'getenv '("AA_QR_Height")))
          (= (type s) 'STR)
          (setq v (distof s 2))
          (> v 0))
     (setq *QR_Last_Height* v))
  )
)

;; 保存 QR 高度到全局变量与 CAD 环境变量。
(defun qr:save-height (h)
  (setq *QR_Last_Height* h)
  (vl-catch-all-apply 'setenv (list "AA_QR_Height" (rtos h 2 8)))
  h
)

;; 高度显示用：去掉多余的尾随 0，例如 3.5000 -> 3.5、100.0000 -> 100。
(defun qr:height-str (h / s)
  (setq s (vl-string-right-trim "0" (rtos h 2 4)))
  (vl-string-right-trim "." s)
)

(defun c:QR (/ *error* aa:tag aa:doc aa:undo-open aa:old-cmdecho a ss i ent data last-h)
  (aa:cmd-begin "QR")
  ;; 1. 提示用户输入高度；有上次高度时直接回车沿用
  (setq last-h (qr:last-height))
  (initget 6)
  (setq a (getdist (if last-h
                     (strcat "\r\n请输入新的文字高度 <" (qr:height-str last-h) ">: ")
                     "\r\n请输入新的文字高度: ")))
  (if (and (null a) last-h)
    (setq a last-h))
  (if (and a (> a 0))
    (qr:save-height a))

  ;; 2. 检查高度值是否有效
  (if (and a (> a 0))
    (progn
      ;; 3. 提示用户选择对象，并过滤出单行文字(TEXT)和多行文字(MTEXT)
      (princ "\r\n请选择需要修改高度的文字内容...")
      (setq ss (ssget '((0 . "TEXT,MTEXT"))))

      ;; 4. 检查是否选中了内容
      (if ss
        (progn
          (setq i 0)
          ;; 5. 遍历选择集
          (repeat (sslength ss)
            (setq ent (ssname ss i))
            (setq data (entget ent))
            
            ;; 6. 使用 subst 和 entmod 修改 DXF 组码 40 (高度)
            ;; assoc 40 获取当前高度，cons 40 a 构造新的高度项
            (setq data (subst (cons 40 a) (assoc 40 data) data))
            (entmod data)
            
            (setq i (1+ i))
          )
          (princ (strcat "\r\n操作成功！已将 " (itoa i) " 个文字的高度修改为: " (rtos a)))
        )
        (princ "\r\n未选中任何文字对象。")
      )
    )
    (princ "\r\n错误：请输入有效的高度数值。")
  )
  ;; 静默退出
  (aa:cmd-end)
)

;;; =======================================================================================
;;; 命令: QR2
;;; 功能: 连续选择文字修改高度，与 QR 共用上次高度；高度回车沿用，选择回车或 Esc 退出。
;;; =======================================================================================
(defun c:QR2 (/ *error* aa:tag aa:doc aa:undo-open aa:old-cmdecho ss a i ent data count last-h)
  (aa:cmd-begin "QR2")
  (princ "\r\nQR2：选择文字后输入高度，高度回车沿用上次值；选择时回车或 Esc 退出。")
  (while (setq ss (ssget '((0 . "TEXT,MTEXT"))))
    (setq last-h (qr:last-height))
    (initget 6)
    (setq a (getdist (if last-h
                       (strcat "\r\n请输入新的文字高度 <" (qr:height-str last-h) ">: ")
                       "\r\n请输入新的文字高度: ")))
    (if (and (null a) last-h)
      (setq a last-h))
    (if (and a (> a 0))
      (qr:save-height a))
    (if (and a (> a 0))
      (progn
        (setq i 0
              count 0)
        (repeat (sslength ss)
          (setq ent (ssname ss i)
                data (entget ent))
          (if (assoc 40 data)
            (progn
              (entmod (subst (cons 40 a) (assoc 40 data) data))
              (setq count (1+ count))))
          (setq i (1+ i)))
        (redraw)
        (princ (strcat "\r\n已将 " (itoa count) " 个文字的高度修改为: " (rtos a 2 4))))
      (princ "\r\n错误：请输入有效的高度数值。"))
  )
  (aa:cmd-end)
)

;;; =======================================================================================
;;; 命令: DEA
;;; 功能: 删除所选对象中高度小于 0.1 的 TEXT/MTEXT 文字。
;;; =======================================================================================
(defun c:DEA (/ *error* aa:tag aa:doc aa:undo-open aa:old-cmdecho ss i ent data typ height count)
  (aa:cmd-begin "DEA")
  (princ "\r\n请选择要检查的对象: ")
  (setq ss (ssget))
  (if ss
    (progn
      (setq i 0
            count 0)
      (repeat (sslength ss)
        (setq ent (ssname ss i)
              data (entget ent)
              typ (cdr (assoc 0 data))
              height (cdr (assoc 40 data)))
        (if (and (member typ '("TEXT" "MTEXT"))
                 height
                 (< height 0.1))
          (if (entdel ent)
            (setq count (1+ count))))
        (setq i (1+ i)))
      (redraw)
      (princ (strcat "\r\n已删除 " (itoa count) " 个高度小于 0.1 的文字。")))
    (princ "\r\n未选择任何对象。"))
  (aa:cmd-end)
)


;;; =======================================================================================
;;; 命令: DEK
;;; 功能: 删除所选对象中的所有块参照 (INSERT)。
;;; =======================================================================================
(defun c:DEK (/ *error* aa:tag aa:doc aa:undo-open aa:old-cmdecho ss i ent count)
  (aa:cmd-begin "DEK")
  (princ "\r\n请选择包含块参照的对象: ")
  (setq ss (ssget))
  (if ss
    (progn
      (setq i 0
            count 0)
      (repeat (sslength ss)
        (setq ent (ssname ss i))
        (if (= (cdr (assoc 0 (entget ent))) "INSERT")
          (if (entdel ent)
            (setq count (1+ count))))
        (setq i (1+ i)))
      (redraw)
      (if (> count 0)
        (princ (strcat "\r\n已成功删除 " (itoa count) " 个块参照。"))
        (princ "\r\n所选对象中未找到块参照。")))
    (princ "\r\n未选择任何对象。"))
  (aa:cmd-end)
)

;;; =======================================================================================
;;; 命令: DEH
;;; 功能: 删除所选对象中内容含有中文的 TEXT/MTEXT 文字。
;;; =======================================================================================
(defun aa:layer-locked-p (lname / layer-data)
  (and lname
       (setq layer-data (tblsearch "LAYER" lname))
       (/= 0 (logand 4 (cdr (assoc 70 layer-data))))))

(defun aa:hex->int (s / n i d)
  ;; 十六进制串转整数，含非十六进制字符时返回 nil
  (setq n 0
        i 1)
  (while (and n (<= i (strlen s)))
    (setq d (vl-string-search (strcase (substr s i 1)) "0123456789ABCDEF")
          n (if d (+ (* n 16) d))
          i (1+ i)))
  n)

(defun aa:has-chinese (str / codes c pos hex u hit)
  ;; 兼容两种形态：LISPSYS=1 下 vl-string->list 可能返回 UTF-16 码元，
  ;; 此时中文落在 11904..40959 (0x2E80..0x9FFF)；旧形态返回 UTF-8 字节，中文由 228..233 (0xE4..0xE9) 引导。
  ;; 两种窗口任一命中即判定含中文。AutoLISP 不支持 #x 写法，数值一律用十进制。
  (setq str   (if str str "")
        codes (vl-string->list str))
  (while (and codes (not hit))
    (setq c (car codes))
    (if (or (and (>= c 11904) (<= c 40959))
            (and (>= c 228) (<= c 233)))
      (setq hit T))
    (setq codes (cdr codes)))
  ;; 再查 \U+XXXX 转义（SHX 大字体旧图常见）；MTEXT 去格式码后反斜杠会被去掉，故只匹配 U+
  (setq pos 0)
  (while (and (not hit) (setq pos (vl-string-search "U+" (strcase str) pos)))
    (setq hex (substr str (+ pos 3) 4)
          u   (if (= (strlen hex) 4) (aa:hex->int hex)))
    (if (and u (>= u 11904) (<= u 40959))
      (setq hit T))
    (setq pos (+ pos 2)))
  hit)

(defun c:DEH (/ *error* aa:tag aa:doc aa:undo-open aa:old-cmdecho
               ss i ent ed typ count locked skip)
  (aa:cmd-begin "DEH")
  (princ "\r\n请选择要检查的对象: ")
  (setq ss (ssget))
  (if ss
    (progn
      (setq i 0
            count 0
            locked 0)
      (repeat (sslength ss)
        (setq ent (ssname ss i)
              ed  (entget ent)
              typ (cdr (assoc 0 ed)))
        (if (and (member typ '("TEXT" "MTEXT"))
                 (aa:has-chinese (aa:ysdl-get-plain-text ed)))
          (if (aa:layer-locked-p (cdr (assoc 8 ed)))
            (setq locked (1+ locked))
            (if (entdel ent)
              (setq count (1+ count)))))
        (setq i (1+ i)))
      (redraw)
      (princ (strcat "\r\n已删除 " (itoa count) " 个含中文的文字。"))
      (if (> locked 0)
        (princ (strcat "\r\n另有 " (itoa locked)
                       " 个含中文文字位于锁定图层，已跳过。")))
      (if (and (= count 0) (= locked 0))
        (princ "\r\n所选对象中未找到含中文的文字。")))
    (princ "\r\n未选择任何对象。"))
  (aa:cmd-end)
)


;;; =======================================================================================
;;; 命令: DET
;;; 功能: 删除所选对象中内容为指定值的属性定义 (ATTDEF)；内容即 QW3 导出的"内容"字段，
;;;       支持逗号或空格分隔多个值、不区分大小写，回车沿用上次输入（首次默认 A0,A1）。
;;; =======================================================================================
(if (not *DET_Values*) (setq *DET_Values* "A0,A1"))

(defun det:split-values (str / len i ch start parts)
  ;; 按逗号或空格拆分输入值，忽略连续分隔符与首尾分隔符
  (setq str   (if str str "")
        len   (strlen str)
        i     1
        start 1
        parts '())
  (while (<= i len)
    (setq ch (substr str i 1))
    (if (or (= ch ",") (= ch " "))
      (progn
        (if (< start i)
          (setq parts (cons (substr str start (- i start)) parts)))
        (setq start (1+ i))))
    (setq i (1+ i)))
  (if (<= start len)
    (setq parts (cons (substr str start (- (1+ len) start)) parts)))
  (reverse parts)
)

(defun c:DET (/ *error* aa:tag aa:doc aa:undo-open aa:old-cmdecho
                ss i ent ed raw vals targets hit count locked)
  (aa:cmd-begin "DET")
  (setq vals (getstring T
    (strcat "\r\n输入要删除的属性定义(ATTDEF)内容，逗号或空格分隔多个 <"
            *DET_Values* ">: ")))
  (if (= vals "")
    (setq vals *DET_Values*)
    (setq *DET_Values* vals))
  (setq targets (det:split-values vals))
  (if targets
    (progn
      (princ "\r\n请选择要检查的对象: ")
      (setq ss (ssget))
      (if ss
        (progn
          (setq i 0 count 0 locked 0)
          (repeat (sslength ss)
            (setq ent (ssname ss i)
                  ed  (entget ent)
                  i   (1+ i))
            (if (= (cdr (assoc 0 ed)) "ATTDEF")
              (progn
                (setq raw (strcase (aa:ysdl-get-raw-text ed)) hit nil)
                (foreach val targets
                  (if (= raw (strcase val)) (setq hit T)))
                (if hit
                  (if (aa:layer-locked-p (cdr (assoc 8 ed)))
                    (setq locked (1+ locked))
                    (if (entdel ent)
                      (setq count (1+ count))))))))
          (redraw)
          (princ (strcat "\r\n已删除 " (itoa count) " 个内容为 " vals " 的属性定义。"))
          (if (> locked 0)
            (princ (strcat "\r\n另有 " (itoa locked)
                           " 个匹配的属性定义位于锁定图层，已跳过。")))
          (if (and (= count 0) (= locked 0))
            (princ "\r\n所选对象中未找到匹配的属性定义。")))
        (princ "\r\n未选择任何对象。")))
    (princ "\r\n未输入任何内容。"))
  (aa:cmd-end)
)


;;; =======================================================================================
;;; 命令: A2T
;;; 功能: 将散落的 ATTDEF 属性定义（常见于 X 炸开带属性的块后残留）转换为普通单行文字。
;;;       文字内容可选：智能(默认值非空用默认值，否则用标记)/标记/默认值/提示，选项记忆。
;;;       保留图层、颜色、线型、线宽、字高、宽度比例、倾斜、样式、对齐、旋转和所在空间；
;;;       锁定图层上的对象及内容为空的对象跳过。整体一次 U 撤销。
;;; =======================================================================================
(if (not *A2T_Mode*) (setq *A2T_Mode* "S"))

(defun a2t:layer-locked-p (lname / layer-data)
  (and lname
       (setq layer-data (tblsearch "LAYER" lname))
       (/= 0 (logand 4 (cdr (assoc 70 layer-data))))))

(defun a2t:pick-string (ed mode / tag def prm)
  ;; 按模式取文字内容：S=智能，T=标记，D=默认值，P=提示
  (setq tag (cdr (assoc 2 ed))
        def (cdr (assoc 1 ed))
        prm (cdr (assoc 3 ed)))
  (cond
    ((= mode "T") tag)
    ((= mode "D") def)
    ((= mode "P") prm)
    ((and def (/= def "")) def)
    (T tag)))

(defun a2t:text-dxf (ed str / out item)
  ;; 由 ATTDEF 数据构造 TEXT 的 entmake 列表；ATTDEF 垂直对齐码 74 对应 TEXT 的 73
  (setq out (list (cons 1 str) (cons 0 "TEXT")))
  (foreach code '(67 410 8 6 62 370 420 440 48 39 10 40 50 41 51 7 71 72 11 210)
    (if (setq item (assoc code ed))
      (setq out (cons item out))))
  (if (setq item (assoc 74 ed))
    (setq out (cons (cons 73 (cdr item)) out)))
  (reverse out))

(defun c:A2T (/ *error* aa:tag aa:doc aa:undo-open aa:old-cmdecho
                kw ss i ent ed str new-ent done skip-empty skip-lock failed)
  (aa:cmd-begin "A2T")
  (initget "S T D P")
  (setq kw (getkword
             (strcat "\r\n文字内容 [智能(S)/标记(T)/默认值(D)/提示(P)] <"
                     *A2T_Mode* ">: ")))
  (if kw (setq *A2T_Mode* kw))
  (princ "\r\n请选择要转换的属性定义(ATTDEF): ")
  (setq ss (ssget '((0 . "ATTDEF"))))
  (if ss
    (progn
      (setq i 0 done 0 skip-empty 0 skip-lock 0 failed 0)
      (repeat (sslength ss)
        (setq ent (ssname ss i)
              ed  (entget ent)
              str (a2t:pick-string ed *A2T_Mode*)
              i   (1+ i))
        (cond
          ((a2t:layer-locked-p (cdr (assoc 8 ed)))
           (setq skip-lock (1+ skip-lock)))
          ((or (null str) (= str ""))
           (setq skip-empty (1+ skip-empty)))
          ((setq new-ent (entmake (a2t:text-dxf ed str)))
           (if (entdel ent)
             (setq done (1+ done))
             (progn
               (entdel (entlast))
               (setq failed (1+ failed)))))
          (T (setq failed (1+ failed)))))
      (redraw)
      (princ (strcat "\r\nA2T 完成：转换 " (itoa done)
                     " 个；内容为空跳过 " (itoa skip-empty)
                     " 个；锁定图层跳过 " (itoa skip-lock)
                     " 个；失败 " (itoa failed) " 个。")))
    (princ "\r\n未选择属性定义。"))
  (aa:cmd-end)
  (princ))


;;; =======================================================================================
;;;                          --- WI 命令: 修改文字宽度比例 ---
;;; =======================================================================================
(defun c:wi (/ *error* aa:tag aa:doc aa:undo-open aa:old-cmdecho a ss i ename elist old_width)
  (aa:cmd-begin "wi")
  ;; 1. 提示用户输入文字宽度比例
  (setq a (getreal "\r\n请输入新的文字宽度比例 (例如 0.8 或 1.0): "))

  ;; 2. 检查输入是否有效
  (if (and a (> a 0))
    (progn
      ;; 3. 提示选择对象（过滤只选择 TEXT 和 MTEXT）
      (princ "\r\n请选择要修改的文字对象: ")
      (setq ss (ssget '((0 . "TEXT,MTEXT"))))

      (if ss
        (progn
          (setq i 0)
          ;; 4. 遍历选择集
          (repeat (sslength ss)
            (setq ename (ssname ss i))
            (setq elist (entget ename))
            
            ;; 对于普通文字 (TEXT)，41号组码是宽度比例
            ;; 对于多行文字 (MTEXT)，41号组码是参照矩形宽度
            ;; 这里统一处理 41 号组码
            (if (assoc 41 elist)
              (setq elist (subst (cons 41 a) (assoc 41 elist) elist))
              (setq elist (append elist (list (cons 41 a))))
            )
            
            ;; 更新实体数据
            (entmod elist)
            (setq i (1+ i))
          )
          (princ (strcat "\r\n成功修改了 " (itoa (sslength ss)) " 个文字的宽度比例。"))
        )
        (princ "\r\n未选中任何有效的文字对象。")
      )
    )
    (princ "\r\n无效的宽度数值，请输入大于0的数字。")
  )
  (aa:cmd-end)
)


;;; =======================================================================================
;;;                          --- ATW 命令: 智能调节文字宽度 ---
;;; 功能: 拾取两点指定最大宽度，将超宽单行文字的宽度比例缩小至两点间距的 95% 并保持左侧不动。
;;; =======================================================================================
(defun c:ATW (/ *error* aa:tag aa:doc aa:undo-open aa:old-cmdecho
                ss pt1 pt2 dist target_w i ename elist
                bbox_before bbox_after curr_w scale old_factor new_factor
                dx adjusted_count kept_count)
  (aa:cmd-begin "ATW")
  (vl-load-com)
  (setq aa:doc (vla-get-activedocument (vlax-get-acad-object)))

  ;; 1. 优先读取预选的单行文字，若无预选则提示框选
  (setq ss (ssget "_I" '((0 . "TEXT"))))
  (if (null ss)
    (progn
      (princ "\r\n请选择需要调节宽度的单行文字: ")
      (setq ss (ssget '((0 . "TEXT"))))))

  (if (and ss (> (sslength ss) 0))
    (progn
      ;; 清除预选亮显状态，便于清晰拾取点
      (sssetfirst nil nil)
      ;; 2. 提示用户拾取两点
      (setq pt1 (getpoint "\r\n[ATW] 请指定最大宽度第一点: "))
      (if pt1
        (progn
          (setq pt2 (getpoint pt1 "\r\n[ATW] 请指定最大宽度第二点: "))
          (if pt2
            (progn
              (setq dist (distance pt1 pt2))
              (if (> dist 1e-6)
                (progn
                  (setq target_w (* 0.95 dist)
                        adjusted_count 0
                        kept_count 0
                        i 0)
                  ;; 3. 逐个检查并调整文字
                  (repeat (sslength ss)
                    (setq ename (ssname ss i)
                          elist (entget ename)
                          bbox_before (aa:safe-get-bbox aa:doc ename))
                    (if bbox_before
                      (progn
                        (setq curr_w (- (aa:bbox-right-x bbox_before) (aa:bbox-left-x bbox_before)))
                        (if (> curr_w target_w)
                          (progn
                            ;; 计算新宽度比例
                            (setq old_factor (cdr (assoc 41 elist)))
                            (if (null old_factor) (setq old_factor 1.0))
                            (setq scale (/ target_w curr_w)
                                  new_factor (* old_factor scale))
                            ;; 更新 41 组码
                            (if (assoc 41 elist)
                              (setq elist (subst (cons 41 new_factor) (assoc 41 elist) elist))
                              (setq elist (append elist (list (cons 41 new_factor)))))
                            (entmod elist)
                            (entupd ename)

                            ;; 保持左边缘不动：对比压缩前后的左边界 X 坐标
                            (setq bbox_after (aa:safe-get-bbox aa:doc ename))
                            (if bbox_after
                              (progn
                                (setq dx (- (aa:bbox-left-x bbox_before) (aa:bbox-left-x bbox_after)))
                                (if (not (equal dx 0.0 1e-6))
                                  (aa:safe-move-entity ename (list dx 0.0 0.0)))))
                            (setq adjusted_count (1+ adjusted_count)))
                          (setq kept_count (1+ kept_count))
                        ))
                    )
                    (setq i (1+ i))
                  )
                  (princ (strcat "\r\n[ATW] 处理完成：已调整 " (itoa adjusted_count)
                                 " 个超宽文字，保持 " (itoa kept_count)
                                 " 个合规文字不变（目标最大宽度: " (rtos target_w 2 2) "）。"))
                )
                (princ "\r\n[ATW] 两点间距过小，操作已取消。")
              )
            )
            (princ "\r\n[ATW] 未指定第二点，操作已取消。")
          )
        )
        (princ "\r\n[ATW] 未指定第一点，操作已取消。")
      )
    )
    (princ "\r\n[ATW] 未选择任何单行文字。")
  )
  (aa:cmd-end)
)


;;; =======================================================================================
;;;                      --- XB 命令: 文字/尺寸标注整体缩小 10 倍 ---
;;; =======================================================================================
(defun c:XB (/ *error* aa:tag aa:doc aa:undo-open aa:old-cmdecho ss i ename elist typ old_height new_height obj old_scale result changed skipped)
  (aa:cmd-begin "XB")
  ;; 优先使用执行命令前已经预选的文字/尺寸标注；没有预选时再提示选择。
  (vl-load-com)
  (setq ss (ssget "_I" '((0 . "TEXT,MTEXT,DIMENSION"))))
  (if (null ss)
    (progn
      (princ "\r\n请选择要缩小的文字或尺寸标注: ")
      (setq ss (ssget '((0 . "TEXT,MTEXT,DIMENSION"))))))

  (if ss
    (progn
      (setq i 0
            changed 0
            skipped 0)
      (repeat (sslength ss)
        (setq ename (ssname ss i)
              elist (entget ename)
              typ (cdr (assoc 0 elist)))
        (cond
          ((member typ '("TEXT" "MTEXT"))
           (setq old_height (cdr (assoc 40 elist)))
           (if (and old_height (> old_height 0.0))
             (progn
               (setq new_height (* old_height 0.1))
               (setq elist (subst (cons 40 new_height) (assoc 40 elist) elist))
               (if (entmod elist)
                 (setq changed (1+ changed))
                 (setq skipped (1+ skipped))))
             (setq skipped (1+ skipped))))
          ((= typ "DIMENSION")
           (setq obj (vlax-ename->vla-object ename)
                 result (vl-catch-all-apply 'vla-get-ScaleFactor (list obj)))
           (if (and (not (vl-catch-all-error-p result))
                    (> result 0.0))
             (progn
               (setq old_scale (* result 0.1))
               (setq result (vl-catch-all-apply 'vla-put-ScaleFactor
                                                (list obj old_scale)))
               (if (vl-catch-all-error-p result)
                 (setq skipped (1+ skipped))
                 (setq changed (1+ changed))))
             (setq skipped (1+ skipped)))
           (vlax-release-object obj)))
        (setq i (1+ i)))
      (redraw)
      ;; 完成后清空选择集，不再保持刚修改对象的选中状态。
      (sssetfirst nil nil)
      (princ (strcat "\r\nXB 完成：已将 " (itoa changed) " 个对象缩小为原来的 1/10。"))
      (if (> skipped 0)
        (princ (strcat "跳过 " (itoa skipped) " 个无法处理的对象。"))))
    (princ "\r\n未选择任何文字或尺寸标注。"))
  (aa:cmd-end)
)


;;; =======================================================================================
;;;                      --- YAN 命令: 延长竖直直线统一间距 ---
;;; =======================================================================================
(defun c:YAN (/ *error* doc group_num extend_dir ss ent_list sorted_list i ent p10 p11 p10y p11y multiplier delta new_y new_pt obj)
  
  ;; --- 错误处理函数 ---
  (defun *error* (msg)
    (if (and msg (not (wcmatch (strcase msg) "*BREAK*,*CANCEL*,*EXIT*")))
      (princ (strcat "\r\n错误: " msg))
    )
    (if (= (type doc) 'vla-object) (vla-EndUndoMark doc))
    (princ)
  )

  (vl-load-com)
  (setq doc (vla-get-ActiveDocument (vlax-get-acad-object)))
  
  ;; --- 1. 获取用户输入选项 ---
  
  ;; 初始化选项：分组数量 (2 或 4)
  (initget 1 "2 4")
  (setq group_num (atoi (getkword "\r\n请输入分组数量 [2/4]: ")))
  
  ;; 初始化选项：延伸方向 (Up 或 Down)
  (initget 1 "Up Down")
  (setq extend_dir (getkword "\r\n请输入延伸方向 [向上(Up)/向下(Down)]: "))

  ;; --- 2. 选择对象 ---
  (princ "\r\n请选择竖直直线 (从左到右将自动排序): ")
  (setq ss (ssget '((0 . "LINE"))))
  
  (if ss
    (progn
      (vla-StartUndoMark doc)
      
      ;; --- 3. 将选择集转换为图元列表 ---
      (setq ent_list '())
      (setq i 0)
      (repeat (sslength ss)
        (setq ent_list (cons (ssname ss i) ent_list))
        (setq i (1+ i))
      )
      
      ;; --- 4. 从左到右排序 ---
      ;; 依据组码10 (起点) 的 X 坐标进行排序
      (setq sorted_list 
        (aa:insert-sort ent_list
          '(lambda (e1 e2)
             (< (car (cdr (assoc 10 (entget e1))))
                (car (cdr (assoc 10 (entget e2)))))
           )
        )
      )

      ;; --- 5. 循环处理每一条线 ---
      (setq i 0) ;; 重置计数器作为列表索引
      (foreach ent sorted_list
        (setq obj (entget ent))
        (setq p10 (cdr (assoc 10 obj))) ;; 起点坐标 (X Y Z)
        (setq p11 (cdr (assoc 11 obj))) ;; 终点坐标 (X Y Z)
        
        ;; 计算当前的倍数
        ;; 逻辑：索引除以组数取整，然后+1
        ;; 例如组数为2：0,1 -> 倍数1; 2,3 -> 倍数2
        (setq multiplier (1+ (fix (/ i group_num))))
        (setq delta (* multiplier 5))
        
        (setq p10y (cadr p10))
        (setq p11y (cadr p11))
        
        ;; 根据方向修改坐标
        (if (eq extend_dir "Down")
          ;; --- 向下延伸 ---
          ;; 逻辑：找到Y值较小的那个点，将其Y值减去delta
          (if (< p10y p11y)
            (progn
              ;; p10 是下端点
              (setq new_y (- p10y delta))
              (setq new_pt (list (car p10) new_y (caddr p10)))
              (setq obj (subst (cons 10 new_pt) (assoc 10 obj) obj))
            )
            (progn
              ;; p11 是下端点
              (setq new_y (- p11y delta))
              (setq new_pt (list (car p11) new_y (caddr p11)))
              (setq obj (subst (cons 11 new_pt) (assoc 11 obj) obj))
            )
          )
          ;; --- 向上延伸 ---
          ;; 逻辑：找到Y值较大的那个点，将其Y值加上delta
          (if (> p10y p11y)
            (progn
              ;; p10 是上端点
              (setq new_y (+ p10y delta))
              (setq new_pt (list (car p10) new_y (caddr p10)))
              (setq obj (subst (cons 10 new_pt) (assoc 10 obj) obj))
            )
            (progn
              ;; p11 是上端点
              (setq new_y (+ p11y delta))
              (setq new_pt (list (car p11) new_y (caddr p11)))
              (setq obj (subst (cons 11 new_pt) (assoc 11 obj) obj))
            )
          )
        )
        
        ;; 更新图元
        (entmod obj)
        
        ;; 增加索引
        (setq i (1+ i))
      )
      
      (vla-EndUndoMark doc)
      (princ (strcat "\r\n完成! 共处理了 " (itoa (length sorted_list)) " 条直线。"))
    )
    (princ "\r\n未选择任何对象。")
  )
  (princ)
)


;;; =======================================================================================
;;;                  --- SYAN & XYAN 命令: 直线定向延长工具 ---
;;; =======================================================================================

;;; =======================================================================================
;;; 命令: LL
;;; 功能: 水平/竖直连续画直线，保留原生实时预览，退出恢复绘图设置。
;;; =======================================================================================
(defun c:LL (/ *error* aa:tag aa:doc aa:undo-open aa:old-cmdecho
               saved-vars item p1)
  (setq aa:tag "LL")
  (defun *error* (msg)
    (aa:ortho-restore-vars saved-vars)
    (aa:undo-mark-off)
    (if (and msg (not (wcmatch (strcase msg) "*CANCEL*,*QUIT*,*EXIT*,*BREAK*")))
      (princ (strcat "\r\n[LL] 错误：" msg)))
    (princ))
  ;; 全部保存后再修改；恢复由 aa:ortho-restore-vars 处理正交与极轴追踪互斥。
  (foreach item '("CMDECHO" "DRAGMODE" "OSMODE" "AUTOSNAP" "SNAPMODE" "SNAPANG" "ORTHOMODE")
    (setq saved-vars (append saved-vars (list (cons item (getvar item))))))
  (aa:undo-mark-on)
  ;; 首点保留原有捕捉；后续点交给原生 LINE，连续画线并显示橡皮筋预览。
  (if (setq p1 (getpoint "\r\n[LL] 指定直线起点: "))
    (progn
      (setvar "CMDECHO" 0)
      (setvar "DRAGMODE" 2)
      (setvar "OSMODE" 0)
      (setvar "AUTOSNAP" 0)
      (setvar "SNAPMODE" 0)
      (setvar "SNAPANG" 0.0)
      (setvar "ORTHOMODE" 1)
      (princ "\r\n水平/竖直连续画线：移动鼠标并单击，或沿方向输入长度，回车结束。")
      (command "_.LINE" "_NON" p1)
      (while (> (logand (getvar "CMDACTIVE") 1) 0)
        (command pause))))
  (aa:ortho-restore-vars saved-vars)
  (aa:undo-mark-off)
  (princ))

;;; =======================================================================================
;;; SS / MM 共用：原生拖动完成后读取实际位移，偏离水平/竖直时自动投影校正。
;;; 目标点阶段保留用户的对象捕捉、追踪与距离输入；捕捉点偏斜时只保留主方向分量。
;;; =======================================================================================
(defun aa:ortho-ent-pts (ss / pts i ent ed)
  ;; 圆弧、椭圆、填充被拉伸时点位并非整体平移，不参与位移统计。
  (setq i 0)
  (repeat (sslength ss)
    (setq ent (ssname ss i)
          i   (1+ i))
    (if (and (setq ed (entget ent))
             (not (member (cdr (assoc 0 ed)) '("ARC" "ELLIPSE" "HATCH"))))
      (foreach pair ed
        (if (and (member (car pair) '(10 11 12 13 14))
                 (listp (cdr pair)))
          (setq pts (cons (cdr pair) pts))))))
  (reverse pts))

(defun aa:ortho-detect-vec (before after / b a d groups hit best)
  ;; 统计所有变化点的位移，取出现次数最多的一组，避免标注文字等半位移干扰。
  (while (and before after)
    (setq b      (car before)
          a      (car after)
          before (cdr before)
          after  (cdr after)
          d      (list (- (car a) (car b))
                       (- (cadr a) (cadr b))
                       (if (and (caddr a) (caddr b)) (- (caddr a) (caddr b)) 0.0)))
    (if (> (distance '(0.0 0.0 0.0) d) 1e-8)
      (progn
        (setq hit nil
              groups (mapcar '(lambda (g)
                                (if (and (not hit) (equal (car g) d 1e-6))
                                  (progn (setq hit T) (cons (car g) (1+ (cdr g))))
                                  g))
                             groups))
        (if (not hit)
          (setq groups (cons (cons d 1) groups))))))
  (foreach g groups
    (if (or (null best) (> (cdr g) (cdr best)))
      (setq best g)))
  (car best))

(defun aa:ortho-snapshot (ss / out i ent ed sub)
  ;; 记录拉伸前图元数据，含属性和旧式多段线顶点，用于偏斜时精确还原后重拉。
  (setq i 0)
  (repeat (sslength ss)
    (setq ent (ssname ss i)
          i   (1+ i))
    (if (setq ed (entget ent))
      (progn
        (setq out (cons ed out))
        (if (= (cdr (assoc 66 ed)) 1)
          (progn
            (setq sub (entnext ent))
            (while (and sub
                        (setq ed (entget sub))
                        (/= (cdr (assoc 0 ed)) "SEQEND"))
              (setq out (cons ed out)
                    sub (entnext sub))))))))
  (reverse out))

(defun aa:ortho-restore (snap / ok)
  (setq ok T)
  (foreach ed snap
    (if (not (entmod ed))
      (setq ok nil)))
  ;; 只有带子实体的复杂对象需要刷新主对象显示。
  (foreach ed snap
    (if (= (cdr (assoc 66 ed)) 1)
      (entupd (cdr (assoc -1 ed)))))
  ok)

(defun aa:ortho-drag (cmd ss p1 / before snap vec fix p2 ok)
  ;; cmd 为 "_.MOVE" 或 "_.STRETCH"；p1 为当前 UCS 基点。
  ;; 返回 nil=无位移，"ok"=已正交，"fixed"=已投影校正，"enter"=误回车已撤回，"fail"=校正失败。
  (setq before (aa:ortho-ent-pts ss))
  (if (= cmd "_.STRETCH")
    (setq snap (aa:ortho-snapshot ss)))
  (setvar "LASTPOINT" p1)
  (command cmd ss "" "_NON" p1)
  (while (> (logand (getvar "CMDACTIVE") 1) 0)
    (command pause))
  (if (setq vec (aa:ortho-detect-vec before (aa:ortho-ent-pts ss)))
    (setq vec (trans vec 0 1 T))
    (if (and (setq p2 (getvar "LASTPOINT"))
             (not (equal p1 p2 1e-8)))
      (setq vec (mapcar '- p2 p1))))
  (cond
    ((null vec) nil)
    ;; 第二点直接回车时，原生命令把基点坐标当作位移，撤回以免误移。
    ((and (> (distance '(0.0 0.0 0.0) p1) 1e-8)
          (equal vec p1 1e-6))
     (setq fix '(0.0 0.0 0.0)
           ok  "enter"))
    ((or (> (abs (caddr vec)) 1e-8)
         (and (> (abs (car vec)) 1e-8) (> (abs (cadr vec)) 1e-8)))
     (setq fix (if (>= (abs (car vec)) (abs (cadr vec)))
                 (list (car vec) 0.0 0.0)
                 (list 0.0 (cadr vec) 0.0))
           ok  "fixed"))
    (T (setq ok "ok")))
  (if fix
    (if (= cmd "_.MOVE")
      ;; 移动可直接反向补偿偏斜分量。
      (command "_.MOVE" ss "" "_NON" '(0.0 0.0 0.0) "_NON" (mapcar '- fix vec))
      ;; 拉伸不能叠加补偿：先还原到拉伸前，再按投影后的第二点重新拉伸。
      (if (aa:ortho-restore snap)
        (if (> (distance '(0.0 0.0 0.0) fix) 1e-8)
          (command "_.STRETCH" ss "" "_NON" p1 "_NON" (mapcar '+ p1 fix)))
        (setq ok "fail"))))
  ok)

(defun aa:ortho-report (tag res)
  (cond
    ((= res "fixed")
     (princ (strcat "\r\n[" tag "] 捕捉点不在水平/竖直方向，已自动投影到主方向。")))
    ((= res "enter")
     (princ (strcat "\r\n[" tag "] 第二点为空回车，已撤回误位移。")))
    ((= res "fail")
     (princ (strcat "\r\n[" tag "] 偏斜位移未能自动校正，可输入 U 撤销本次操作。")))
    ((null res)
     (princ (strcat "\r\n[" tag "] 未产生位移。")))))

(defun aa:ortho-restore-vars (saved / orth snap)
  ;; 正交与极轴追踪互斥：打开正交会清掉 AUTOSNAP 的极轴位，且正交开着时还原不回去。
  ;; 先还原其他设置，再按原状态排序：原正交开则后开正交，原正交关则先关正交再还原极轴。
  (setq orth (assoc "ORTHOMODE" saved)
        snap (assoc "AUTOSNAP" saved))
  (foreach item saved
    (if (not (member (car item) '("ORTHOMODE" "AUTOSNAP")))
      (vl-catch-all-apply 'setvar (list (car item) (cdr item)))))
  ;; 两遍保证互斥联动后两项都回到原值。
  (repeat 2
    (if (and orth (= (cdr orth) 1))
      (progn
        (if snap (vl-catch-all-apply 'setvar (list "AUTOSNAP" (cdr snap))))
        (vl-catch-all-apply 'setvar (list "ORTHOMODE" (cdr orth))))
      (progn
        (if orth (vl-catch-all-apply 'setvar (list "ORTHOMODE" (cdr orth))))
        (if snap (vl-catch-all-apply 'setvar (list "AUTOSNAP" (cdr snap)))))))
  (princ))

;;; =======================================================================================
;;; 命令: MM
;;; 功能: 水平/竖直移动对象并实时预览，第二点支持对象捕捉与输入距离，偏斜自动投影。
;;; =======================================================================================
(defun c:MM (/ *error* aa:tag aa:doc aa:undo-open aa:old-cmdecho
               saved-vars item ss p1)
  (setq aa:tag "MM")
  (defun *error* (msg)
    (aa:ortho-restore-vars saved-vars)
    (aa:undo-mark-off)
    (if (and msg (not (wcmatch (strcase msg) "*CANCEL*,*QUIT*,*EXIT*,*BREAK*")))
      (princ (strcat "\r\n[MM] 错误：" msg)))
    (princ))
  ;; 全部保存后再修改；恢复由 aa:ortho-restore-vars 处理正交与极轴追踪互斥。
  (foreach item '("CMDECHO" "DRAGMODE" "OSMODE" "AUTOSNAP" "SNAPMODE" "SNAPANG" "ORTHOMODE")
    (setq saved-vars (append saved-vars (list (cons item (getvar item))))))
  (aa:undo-mark-on)
  (princ "\r\n[MM] 请选择要移动的对象，回车结束选择。")
  (if (or (setq ss (ssget "_I")) (setq ss (ssget)))
    (progn
      (sssetfirst nil nil)
      (if (setq p1 (getpoint "\r\n指定移动基点: "))
        (progn
          (setvar "CMDECHO" 0)
          (setvar "DRAGMODE" 2)
          (setvar "SNAPMODE" 0)
          (setvar "SNAPANG" 0.0)
          ;; 先显式关极轴再开正交，使撤销记录按序回放到原极轴状态，避免 Ctrl+Z 后极轴丢失。
          (setvar "AUTOSNAP" (logand (getvar "AUTOSNAP") (~ 8)))
          (setvar "ORTHOMODE" 1)
          ;; 第二点交给原生 MOVE：保留整批对象实时预览、对象捕捉、追踪和输入距离。
          (princ "\r\n水平/竖直移动：可捕捉对象或沿鼠标方向输入距离，捕捉点偏斜时自动投影: ")
          (aa:ortho-report "MM" (aa:ortho-drag "_.MOVE" ss p1)))))
    (princ "\r\n未选择要移动的对象。"))
  (aa:ortho-restore-vars saved-vars)
  (aa:undo-mark-off)
  (princ))

;;; =======================================================================================
;;; 命令: SS
;;; 功能: 原生实体实时预览的正交拉伸，第二点支持对象捕捉与输入距离，偏斜自动投影。
;;; =======================================================================================
(defun c:SS (/ *error* aa:tag aa:doc aa:undo-open aa:old-cmdecho
               saved-vars item ss p1)
  (setq aa:tag "SS")
  (defun *error* (msg)
    (aa:ortho-restore-vars saved-vars)
    (aa:undo-mark-off)
    (if (and msg (not (wcmatch (strcase msg) "*CANCEL*,*QUIT*,*EXIT*,*BREAK*")))
      (princ (strcat "\r\n[SS] 错误：" msg)))
    (princ))
  ;; 全部保存后再修改；恢复由 aa:ortho-restore-vars 处理正交与极轴追踪互斥。
  (foreach item '("CMDECHO" "DRAGMODE" "OSMODE" "AUTOSNAP" "SNAPMODE" "SNAPANG" "ORTHOMODE")
    (setq saved-vars (append saved-vars (list (cons item (getvar item))))))
  (aa:undo-mark-on)
  (princ "\r\n[SS] 请从右往左交叉框选要拉伸的部分，回车结束选择。")
  (if (or (setq ss (ssget "_I")) (setq ss (ssget)))
    (progn
      (sssetfirst nil nil)
      (if (setq p1 (getpoint "\r\n指定拉伸基点: "))
        (progn
          (setvar "CMDECHO" 0)
          (setvar "DRAGMODE" 2)
          (setvar "SNAPMODE" 0)
          (setvar "SNAPANG" 0.0)
          ;; 先显式关极轴再开正交，使撤销记录按序回放到原极轴状态，避免 Ctrl+Z 后极轴丢失。
          (setvar "AUTOSNAP" (logand (getvar "AUTOSNAP") (~ 8)))
          (setvar "ORTHOMODE" 1)
          ;; 第二点交给原生 STRETCH：保留交叉框信息、实体变形预览、对象捕捉、追踪和输入距离。
          (princ "\r\n水平/竖直拉伸：可捕捉对象或沿鼠标方向输入距离，捕捉点偏斜时自动投影: ")
          (aa:ortho-report "SS" (aa:ortho-drag "_.STRETCH" ss p1)))))
    (princ "\r\n未选择要拉伸的对象。"))
  (aa:ortho-restore-vars saved-vars)
  (aa:undo-mark-off)
  (princ))

;;; =======================================================================================
;;; 命令: SW
;;; 功能: 拉伸对象并记忆方向与距离，支持动态拉伸实时预览，后续可直接回车重复上次拉伸。
;;; =======================================================================================
(or (boundp '*aa:ss-offset*) (setq *aa:ss-offset* nil))

(defun aa:ss-format-vec (vec / dx dy dz tol)
  (if (and vec (= (length vec) 3))
    (setq dx (car vec)
          dy (cadr vec)
          dz (caddr vec)
          tol 1e-4)
    (setq dx 0.0 dy 0.0 dz 0.0 tol 1e-4))
  (cond
    ((and (< (abs dx) tol) (> dy tol) (< (abs dz) tol))
     (strcat "向上 " (rtos dy 2 2)))
    ((and (< (abs dx) tol) (< dy (- tol)) (< (abs dz) tol))
     (strcat "向下 " (rtos (abs dy) 2 2)))
    ((and (< (abs dy) tol) (> dx tol) (< (abs dz) tol))
     (strcat "向右 " (rtos dx 2 2)))
    ((and (< (abs dy) tol) (< dx (- tol)) (< (abs dz) tol))
     (strcat "向左 " (rtos (abs dx) 2 2)))
    (T
     (strcat "X " (rtos dx 2 2) ", Y " (rtos dy 2 2)))))

(defun aa:ss-get-entity-pts (ss / pts i ent ed)
  (setq pts nil
        i 0)
  (if ss
    (repeat (sslength ss)
      (setq ent (ssname ss i)
            ed  (entget ent)
            i   (1+ i))
      (foreach pair ed
        (if (member (car pair) '(10 11 12 13 14))
          (setq pts (cons (cdr pair) pts))))))
  (reverse pts))

(defun aa:ss-detect-displacement (before after / vec b a)
  (setq vec nil)
  (while (and before after (null vec))
    (setq b (car before)
          a (car after)
          before (cdr before)
          after  (cdr after))
    (if (not (equal b a 1e-6))
      (setq vec (list (- (car a) (car b))
                      (- (cadr a) (cadr b))
                      (if (and (caddr a) (caddr b))
                        (- (caddr a) (caddr b))
                        0.0))))))

(defun aa:ss-do-interactive-stretch (ss p1 / pts-before pts-after old-drag old-cmd vec p2)
  ;; 利用 CAD 原生 STRETCH 与 DRAGMODE=2 实现动态拉伸实时预览
  (setq pts-before (aa:ss-get-entity-pts ss)
        old-drag   (getvar "DRAGMODE")
        old-cmd    (getvar "CMDECHO"))
  (setvar "DRAGMODE" 2)
  (setvar "CMDECHO" 0)
  (princ "\r\n请指定拉伸第二点 [动态拉伸预览中]: ")
  (command "_.STRETCH" ss "" "_non" p1)
  (while (> (logand (getvar "CMDACTIVE") 1) 0)
    (command pause))
  (if old-drag
    (vl-catch-all-apply 'setvar (list "DRAGMODE" old-drag)))
  (if old-cmd
    (vl-catch-all-apply 'setvar (list "CMDECHO" old-cmd)))
  (setq pts-after (aa:ss-get-entity-pts ss))
  (setq vec (aa:ss-detect-displacement pts-before pts-after))
  (if vec
    (setq vec (trans vec 0 1 T))
    (progn
      ;; 若图元未抓取到点位变化，尝试读取 LASTPOINT
      (setq p2 (getvar "LASTPOINT"))
      (if (and p2 (not (equal p1 p2 1e-6)))
        (setq vec (list (- (car p2) (car p1))
                        (- (cadr p2) (cadr p1))
                        (if (and (caddr p2) (caddr p1))
                          (- (caddr p2) (caddr p1))
                          0.0))))))
  (if (and vec
           (< (abs (car vec)) 1e-6)
           (< (abs (cadr vec)) 1e-6)
           (< (abs (caddr vec)) 1e-6))
    (setq vec nil))
  vec)

(defun c:SW (/ *error* aa:tag aa:doc aa:undo-open aa:old-cmdecho aa:old-dragmode ss
               p1 vec desc)
  (setq aa:old-dragmode (getvar "DRAGMODE"))
  (aa:cmd-begin "SW")
  (defun *error* (msg)
    (if aa:old-dragmode
      (vl-catch-all-apply 'setvar (list "DRAGMODE" aa:old-dragmode)))
    (aa:cmd-error msg))
  (if (or (setq ss (ssget "_I"))
          (progn
            (princ "\r\n请选择要拉伸的对象: ")
            (setq ss (ssget))))
    (progn
      (if *aa:ss-offset*
        ;; --- 已有上次位移记忆 ---
        (progn
          (setq desc (aa:ss-format-vec *aa:ss-offset*))
          (initget "S")
          (setq p1 (getpoint (strcat "\r\n指定拉伸基点 或 [重设(S)] <回车重复上次 " desc ">: ")))
          (cond
            ;; 用户直接按回车或空格：重复上次位移
            ((null p1)
             (setvar "CMDECHO" 0)
             (command "_.STRETCH" ss "" "_NON" '(0.0 0.0 0.0) "_NON" *aa:ss-offset*)
             (princ (strcat "\r\n已重复上次拉伸（" desc "）。")))
            ;; 用户输入了 S：重新拾取基点，带动态预览
            ((= p1 "S")
             (if (setq p1 (getpoint "\r\n请指定拉伸基点: "))
               (if (setq vec (aa:ss-do-interactive-stretch ss p1))
                 (progn
                   (setq *aa:ss-offset* vec)
                   (princ (strcat "\r\n已拉伸并记住位移（" (aa:ss-format-vec vec) "）。下次使用 SW 可直接回车重复。")))
                 (princ "\r\n未产生有效位移，拉伸已取消。"))
               (princ "\r\n已取消指定基点。")))
            ;; 用户直接在屏幕上点了基点 (p1 是点坐标列表)
            ((listp p1)
             (if (setq vec (aa:ss-do-interactive-stretch ss p1))
               (progn
                 (setq *aa:ss-offset* vec)
                 (princ (strcat "\r\n已拉伸并记住位移（" (aa:ss-format-vec vec) "）。下次使用 SW 可直接回车重复。")))
               (princ "\r\n未产生有效位移，拉伸已取消。")))))
        ;; --- 首次使用，无历史记忆 ---
        (progn
          (princ "\r\n[SW] 首次使用，请指定拉伸方向与距离：")
          (if (setq p1 (getpoint "\r\n请指定拉伸基点: "))
            (if (setq vec (aa:ss-do-interactive-stretch ss p1))
              (progn
                (setq *aa:ss-offset* vec)
                (princ (strcat "\r\n已完成拉伸并记住位移（" (aa:ss-format-vec vec) "）。下次使用 SW 可直接回车重复。")))
              (princ "\r\n未产生有效位移，拉伸已取消。"))
            (princ "\r\n已取消指定基点。")))))
    (princ "\r\n未选择要拉伸的对象。"))
  (if aa:old-dragmode
    (vl-catch-all-apply 'setvar (list "DRAGMODE" aa:old-dragmode)))
  (aa:cmd-end)
)

;;; --- SYI / XYI：非竖直对象移动，竖直直线单端拉伸 ---
;; 自动补选竖直线：短斜线左端 X 处、与选中水平线相交且未被选中的竖直 LINE。
;; 短斜线须有一端落在该水平线上；查找用小窗口 ssget "_C"（对象需在当前视图内）。
(defun aa:msv-find-verticals (ss horiz slashes / tol found h hp1 hp2 hy hx1 hx2 s sp1 sp2 lx
                              pt cs j ce ced cp1 cp2)
  (setq tol 0.01
        found (ssadd))
  (foreach h horiz
    (setq hp1 (car h) hp2 (cadr h)
          hy (cadr hp1)
          hx1 (min (car hp1) (car hp2))
          hx2 (max (car hp1) (car hp2)))
    (foreach s slashes
      (setq sp1 (car s) sp2 (cadr s)
            lx (min (car sp1) (car sp2)))
      (if (and (or (<= (abs (- (cadr sp1) hy)) tol)
                   (<= (abs (- (cadr sp2) hy)) tol))
               (<= (- hx1 tol) lx (+ hx2 tol)))
        (progn
          (setq pt (list lx hy 0.0)
                cs (ssget "_C"
                          (trans (list (- lx 0.05) (- hy 0.05) 0.0) 0 1)
                          (trans (list (+ lx 0.05) (+ hy 0.05) 0.0) 0 1)
                          '((0 . "LINE")))
                j 0)
          (if cs
            (repeat (sslength cs)
              (setq ce (ssname cs j)
                    ced (entget ce)
                    cp1 (cdr (assoc 10 ced))
                    cp2 (cdr (assoc 11 ced)))
              (if (and (not (ssmemb ce ss))
                       (not (ssmemb ce found))
                       (<= (abs (- (car cp1) (car cp2))) tol)
                       (<= (abs (- (car cp1) lx)) tol)
                       (<= (- (min (cadr cp1) (cadr cp2)) tol) hy (+ (max (cadr cp1) (cadr cp2)) tol)))
                (ssadd ce found))
              (setq j (1+ j))))))))
  found
)

(defun aa:move-stretch-vertical-cmd (tag hint up-p / *error* aa:tag aa:doc aa:undo-open aa:old-cmdecho
                                      ss move-ss i ent ed p1 p2 delta x tol top-code top-y
                                      verts horiz slashes found)
  (aa:cmd-begin tag)
  (if (setq ss (ssget "_I"))
    (progn
      (setq delta (getreal (strcat "\r\n请输入 X 值（" hint " 5X，默认 1）<1>: ")))
      (if (null delta) (setq delta 1.0))
      (progn
        ;; 方向由命令决定，X 只取距离，避免 XYI 因负输入再次反向。
        (setq delta (* 5.0 (abs delta) (if up-p 1.0 -1.0))
              move-ss (ssadd)
              i 0
              tol 1e-8)
        ;; 1. 分类：竖直线待拉伸；其余对象待移动；同时记下水平线和短斜线供自动补选
        (repeat (sslength ss)
          (setq ent (ssname ss i)
                ed (entget ent))
          (if (= (cdr (assoc 0 ed)) "LINE")
            (progn
              (setq p1 (cdr (assoc 10 ed))
                    p2 (cdr (assoc 11 ed)))
              (cond
                ((<= (abs (- (car p1) (car p2))) tol)
                 (setq verts (cons ent verts)))
                (T
                 (if (<= (abs (- (cadr p1) (cadr p2))) tol)
                   (setq horiz (cons (list p1 p2) horiz))
                   (if (< (distance p1 p2) 5.0)
                     (setq slashes (cons (list p1 p2) slashes))))
                 (ssadd ent move-ss))))
            (ssadd ent move-ss))
          (setq i (1+ i)))
        ;; 2. 自动补选短斜线左侧、与水平线相交的竖直线
        (setq found (if (and horiz slashes) (aa:msv-find-verticals ss horiz slashes) (ssadd))
              i 0)
        (repeat (sslength found)
          (setq verts (cons (ssname found i) verts)
                i (1+ i)))
        ;; 3. 竖直线只移动朝向 hint 的端点，形成单端拉伸。
        (foreach ent verts
          (setq ed (entget ent)
                p1 (cdr (assoc 10 ed))
                p2 (cdr (assoc 11 ed)))
          (if up-p
            (if (>= (cadr p1) (cadr p2))
              (setq top-code 10 top-y p1)
              (setq top-code 11 top-y p2))
            (if (<= (cadr p1) (cadr p2))
              (setq top-code 10 top-y p1)
              (setq top-code 11 top-y p2)))
          ;; 向上取上端、向下取下端，端点沿命令方向延伸。
          (setq top-y (list (car top-y) (+ (cadr top-y) delta) (caddr top-y)))
          (entmod (subst (cons top-code top-y) (assoc top-code ed) ed)))
        (if (> (sslength move-ss) 0)
          (command "_.MOVE" move-ss "" '(0.0 0.0 0.0) (list 0.0 delta 0.0)))
        (redraw)
        (princ (strcat "\r\n已完成：非竖直对象" hint "移动 " (rtos (abs delta) 2 3)
                       "，竖直直线" hint "拉伸相同距离"
                       (if (> (sslength found) 0)
                         (strcat "（自动补选竖直线 " (itoa (sslength found)) " 条）。")
                         "。"))))
      )
    (princ "\r\n请先选择对象，再输入命令。"))
  (aa:cmd-end)
)

(defun c:SYI () (aa:move-stretch-vertical-cmd "SYI" "向上" T))
(defun c:XYI () (aa:move-stretch-vertical-cmd "XYI" "向下" nil))

;;; =======================================================================================
;;; 命令: SSS
;;; 功能: 按选区下沿所在行拉伸；输入正数目标高度，支持小数，回车默认 10。
;;; =======================================================================================
(defun aa:sss-horizontal-segments (ss / i en ed pts p q out)
  (setq i 0 out nil)
  (repeat (sslength ss)
    (setq en (ssname ss i) ed (entget en)
          pts (aa:zdwi-vertices en))
    (if (and pts (= 1 (logand 1 (cond ((cdr (assoc 70 ed))) (T 0)))))
      (setq pts (append pts (list (car pts)))))
    (while (and pts (cdr pts))
      (setq p (car pts) q (cadr pts))
      ;; Allow drawing roundoff (0.01 units), but reject visibly sloped edges.
      (if (and (> (abs (- (car p) (car q))) 1e-5)
               (<= (abs (- (cadr p) (cadr q))) 0.01)
               (<= (abs (- (cadr p) (cadr q)))
                   (* 1e-4 (abs (- (car p) (car q))))))
        (setq out (cons
          (list (/ (+ (cadr p) (cadr q)) 2.0) (min (car p) (car q))
                (max (car p) (car q)) (cdr (assoc 8 ed))) out)))
      (setq pts (cdr pts)))
    (setq i (1+ i)))
  out)

(defun aa:sss-find-pair (segments border-y left right
                         / above below overlap score best best-score)
  (setq best nil best-score nil)
  (foreach above segments
    (if (and (> (car above) (+ border-y 1e-5))
             (> (min (nth 2 above) right)
                (+ (max (cadr above) left) 1e-5)))
      (foreach below segments
        (if (and (< (car below) (- border-y 1e-5))
                 (> (min (nth 2 below) right)
                    (+ (max (cadr below) left) 1e-5)))
          (progn
            (setq overlap (- (min (nth 2 above) (nth 2 below) right)
                             (max (cadr above) (cadr below) left)))
            (if (and (> overlap 1e-5)
                     (>= overlap
                         (* 0.8 (min (- (nth 2 above) (cadr above))
                                     (- (nth 2 below) (cadr below))))))
              (progn
                (setq score (- (car above) (car below)))
                ;; Near-coincident duplicate edges are one border, not a row.
                (if (and (> score 0.01)
                         (or (null best-score) (< score best-score)))
                  (setq best (list above below)
                        best-score score)))))))))
  best)

(defun aa:sss-pickfirst-box (ss / data rec id desc pt left right low high)
  (setq data (vl-catch-all-apply 'ssnamex (list ss)) id nil)
  (if (not (vl-catch-all-error-p data))
    (progn
      (foreach rec data
        (if (and (numberp (car rec)) (= (car rec) 3)
                 (numberp (last rec)) (< (last rec) 0))
          (setq id (last rec))))
      (if id
        (foreach rec data
          (if (and (numberp (car rec)) (= (car rec) id))
            (foreach desc (cdr rec)
              (setq pt (cadr desc))
              (if (and (listp pt) (numberp (car pt))
                       (numberp (cadr pt)))
                (if left
                  (setq left (min left (car pt))
                        right (max right (car pt))
                        low (min low (cadr pt))
                        high (max high (cadr pt)))
                  (setq left (car pt) right (car pt)
                        low (cadr pt) high (cadr pt))))))))))
  (if (and left right low high
           (> (- right left) 1e-5) (> (- high low) 1e-5))
    (list left low right high)))

(defun aa:sss-lowest-row-line (ss / segments seg best max-width)
  (setq segments (aa:sss-horizontal-segments ss) max-width 0.0)
  (foreach seg segments
    (setq max-width (max max-width (- (nth 2 seg) (cadr seg)))))
  (setq best nil)
  (foreach seg segments
    (if (and (> max-width 1e-5)
             (>= (- (nth 2 seg) (cadr seg)) (* 0.8 max-width))
             (or (null best) (< (car seg) (car best))))
      (setq best seg)))
  best)

(defun c:SSS (/ *error* aa:tag aa:doc aa:undo-open aa:old-cmdecho
                tag target-height
                ss box seed left right lower scan pair old-height delta
                p1 p2)
  (vl-load-com)
  (setq tag "SSS")
  (if (or (not (equal (getvar "UCSXDIR") '(1.0 0.0 0.0) 1e-8))
          (not (equal (getvar "UCSYDIR") '(0.0 1.0 0.0) 1e-8)))
    (princ (strcat "\r\n[" tag "] 请先切换到水平的世界坐标系后再使用。"))
    (progn
      (setq ss (ssget "_I"))
      (if (null ss)
        (princ (strcat "\r\n[" tag "] 请先用交叉窗口框选要拉伸的对象，再输入 " tag "。"))
        (progn
          (setq box (aa:sss-pickfirst-box ss)
                seed (aa:sss-lowest-row-line ss))
          ;; Never replace the user's crossing window with a header window.
          ;; If PICKFIRST lost its polygon, the lowest selected border is the
          ;; upper edge of the crossed row. Keep ss for native stretch semantics.
          (cond
            (box
             (setq left (car box) lower (cadr box) right (caddr box)))
            (seed
             (setq left (cadr seed) right (nth 2 seed)
                   lower (- (car seed) 0.02))))
          (if (null lower)
            (princ (strcat "\r\n[" tag "] 预选对象中没有可识别的表格横线，未修改。"))
            (progn
              (setq scan (ssget "_C"
                           (trans (list left (- lower 1000.0) 0.0) 0 1)
                           (trans (list right (+ lower 1000.0) 0.0) 0 1)
                           '((0 . "LINE,LWPOLYLINE,POLYLINE"))))
              (setq pair (if scan
                           (aa:sss-find-pair
                             (aa:sss-horizontal-segments scan)
                             lower left right)))
              (if (null pair)
                (princ (strcat "\r\n[" tag "] 预选区域下沿两侧没有匹配的表格横线，未修改。"))
                (progn
                  ;; Capture the preselection and row before prompting for height.
                  ;; initget 6 rejects zero/negative values; Enter uses 10.
                  (if (null target-height)
                    (progn
                      (initget 6)
                      (setq target-height
                        (cond ((getreal (strcat "\r\n[" tag "] 输入目标行高度 <10>: ")))
                              (T 10.0)))))
                  (setq old-height (- (caar pair) (caadr pair))
                        delta (- target-height old-height))
                  (if (equal delta 0.0 1e-6)
                    (princ (strcat "\r\n[" tag "] 目标行的高度已经是 "
                                   (rtos target-height 2 2) "。"))
                    (progn
                      (aa:cmd-begin tag)
                      (if box
                        (progn
                          (setq p1 (trans (list (car box) (cadr box) 0.0) 0 1)
                                p2 (trans (list (caddr box) (cadddr box) 0.0) 0 1))
                          (command "_.STRETCH" "_C" p1 p2 ""
                                   "_NON" '(0.0 0.0 0.0)
                                   "_NON" (list 0.0 delta 0.0)))
                        (command "_.STRETCH" ss ""
                                 "_NON" '(0.0 0.0 0.0)
                                 "_NON" (list 0.0 delta 0.0)))
                      (aa:cmd-end)
                      (princ (strcat "\r\n[" tag "] 目标行高度 "
                                     (rtos old-height 2 2) " -> "
                                     (rtos target-height 2 2) "，"
                                     (if (> delta 0.0) "向上拉伸 " "向下缩短 ")
                                     (rtos (abs delta) 2 2) "。"))))))))))))
  (sssetfirst nil nil) ; 命令结束后清除选择与亮显
  (princ))

;;; --- 命令 1: 向上延长 (SYAN) ---
(defun aa:extend-line-cmd (tag hint up-p dist
                           / *error* aa:tag aa:doc aa:undo-open aa:old-cmdecho
                             ss i ent p1 p2 far near ang new-pt)
  ;; SYAN / XYAN 共用：把选中直线沿自身方向从指定一端延长固定长度。
  ;;   tag   命令名
  ;;   hint  方向描述，如 "向上"
  ;;   up-p  T 表示延长上端，nil 表示延长下端
  ;;   dist  延长长度
  (aa:cmd-begin tag)
  (princ (strcat "\r\n请选择要" hint "延长的直线..."))
  (if (setq ss (ssget '((0 . "LINE"))))
    (progn
      (setq i 0)
      (repeat (sslength ss)
        (setq ent (entget (ssname ss i))
              p1  (cdr (assoc 10 ent))
              p2  (cdr (assoc 11 ent)))
        ;; far = 待延长的一端，near = 另一端
        (if (if up-p
              (> (cadr p1) (cadr p2))
              (< (cadr p1) (cadr p2)))
          (setq far p1 near p2)
          (setq far p2 near p1)
        )
        (setq ang    (angle near far)
              new-pt (polar far ang dist))
        (if (equal far p1)
          (setq ent (subst (cons 10 new-pt) (assoc 10 ent) ent))
          (setq ent (subst (cons 11 new-pt) (assoc 11 ent) ent))
        )
        (entmod ent)
        (setq i (1+ i))
      )
      (princ (strcat "\r\n成功" hint "延长了 " (itoa i) " 条直线。"))
    )
    (princ "\r\n未选中任何直线。")
  )
  (aa:cmd-end)
)

(defun c:SYAN () (aa:extend-line-cmd "SYAN" "向上" T   5))

;;; --- 命令 2: 向下延长 (XYAN) ---
(defun c:XYAN () (aa:extend-line-cmd "XYAN" "向下" nil 5))


;;; =======================================================================================

;;; =======================================================================================
;;;              --- XSUO & SSUO 命令: 上下缩短直线 5 单位 ---
;;; =======================================================================================


;;; =======================================================================================
;;;                 --- SJ & XJ 命令: 电缆角标上下接短线 ---
;;; =======================================================================================

(defun c:SJ (/ *error* aa:tag aa:doc aa:undo-open aa:old-cmdecho ss i ent ed p1 p2 top sp ep)
  (aa:cmd-begin "SJ")
  (princ "\r\n=== SJ 上接模式 ===")

  (if (setq ss (ssget '((0 . "LINE"))))
    (progn
      (setq i 0)
      (repeat (sslength ss)
        (setq ent (ssname ss i)
              ed  (entget ent)
              p1  (cdr (assoc 10 ed))
              p2  (cdr (assoc 11 ed)))
        (setq top (if (> (cadr p1) (cadr p2)) p1 p2))
        (setq sp (list (+ (car top) 1.0) (cadr top) (caddr top))
              ep (list (car top) (- (cadr top) 1.0) (caddr top)))
        (entmake (list '(0 . "LINE")
                       (cons 62 7)
                       (cons 10 sp)
                       (cons 11 ep)))
        (setq i (1+ i))
      )
      (princ (strcat "\r\n已成功为 " (itoa (sslength ss)) " 条直线绘制【上接】短线！"))
    )
    (princ "\r\n未选中直线！请框选直线后再输入 SJ")
  )
  (aa:cmd-end)
)

(defun c:XJ (/ *error* aa:tag aa:doc aa:undo-open aa:old-cmdecho ss i ent ed p1 p2 bot sp ep)
  (aa:cmd-begin "XJ")
  (princ "\r\n=== XJ 下接模式 ===")

  (if (setq ss (ssget '((0 . "LINE"))))
    (progn
      (setq i 0)
      (repeat (sslength ss)
        (setq ent (ssname ss i)
              ed  (entget ent)
              p1  (cdr (assoc 10 ed))
              p2  (cdr (assoc 11 ed)))
        (setq bot (if (< (cadr p1) (cadr p2)) p1 p2))
        (setq sp (list (+ (car bot) 1.0) (cadr bot) (caddr bot))
              ep (list (car bot) (+ (cadr bot) 1.0) (caddr bot)))
        (entmake (list '(0 . "LINE")
                       (cons 62 7)
                       (cons 10 sp)
                       (cons 11 ep)))
        (setq i (1+ i))
      )
      (princ (strcat "\r\n已成功为 " (itoa (sslength ss)) " 条直线绘制【下接】短线！"))
    )
    (princ "\r\n未选中直线！请框选直线后再输入 XJ")
  )
  (aa:cmd-end)
)
(defun aa:extend-join-cmd (tag up-p
                          / *error* aa:tag aa:doc aa:undo-open aa:old-cmdecho
                            ss i en ed p1 p2 far near code new-pt sp ep count skipped)
  (aa:cmd-begin tag)
  (princ "\r\n请选择要延长并接短线的竖直直线：")
  (setq ss (ssget "_I" '((0 . "LINE"))))
  (if (not ss) (setq ss (ssget '((0 . "LINE")))))
  (setq count 0 skipped 0)
  (if ss
    (progn
      (setq i 0)
      (repeat (sslength ss)
        (setq en (ssname ss i)
              ed (entget en)
              p1 (cdr (assoc 10 ed))
              p2 (cdr (assoc 11 ed)))
        (if (and (equal (car p1) (car p2) 1e-8)
                 (equal (caddr p1) (caddr p2) 1e-8)
                 (not (equal (cadr p1) (cadr p2) 1e-8))
                 (= 0 (logand 4 (cdr (assoc 70 (tblsearch "LAYER" (cdr (assoc 8 ed))))))))
          (progn
            ;; 与 SYAN/XYAN 相同的端点延长，再以新端点应用 SJ/XJ 的短线规则。
            (if (if up-p (> (cadr p1) (cadr p2)) (< (cadr p1) (cadr p2)))
              (setq far p1 near p2 code 10)
              (setq far p2 near p1 code 11))
            (setq new-pt (polar far (angle near far) 5.0)
                  sp (list (+ (car new-pt) 1.0) (cadr new-pt) (caddr new-pt))
                  ep (list (car new-pt) (+ (cadr new-pt) (if up-p -1.0 1.0)) (caddr new-pt)))
            (if (entmod (subst (cons code new-pt) (assoc code ed) ed))
              (if (entmake (list '(0 . "LINE") '(62 . 7) (cons 10 sp) (cons 11 ep)))
                (setq count (1+ count))
                (progn (entmod ed) (setq skipped (1+ skipped))))
              (setq skipped (1+ skipped))))
          (setq skipped (1+ skipped)))
        (setq i (1+ i)))
      (redraw)
      (princ (strcat "\r\n" tag " 完成：" (itoa count) " 条，跳过 " (itoa skipped) " 条。")))
    (princ "\r\n未选中直线。"))
  (sssetfirst nil nil)
  (aa:cmd-end)
)

(defun c:SYJ () (aa:extend-join-cmd "SYJ" T))
(defun c:XYJ () (aa:extend-join-cmd "XYJ" nil))

;;; 函数: NU
;;; 功能: 材料表数字加数字 - 从选中的文字对象中提取数字，执行加法运算
;;; =======================================================================================



;;; =======================================================================================
;;;                             --- 文件加载完成提示 ---
;;; =======================================================================================

;;; =======================================================================================
;;; Added commands: SYI / XYI / ZYI / YYI / BIAN
;;; =======================================================================================

;; Move selected objects up by 5 units.

;; Move selected objects down by 5 units.

;; Move selected objects left by 5 units.

;; Move selected objects right by 5 units.

;; =============================================================================
;; 电缆文字分类与整理
;; GTX: 按自动容差整理单行/多行电缆文字并自然排序汇总
;; GTY: 汇总并按电缆编号排序整理
;; =============================================================================

(defun aa:gtx-find-last-char (char str / len pos)
  (setq len (strlen str)
        pos nil)
  (while (and (> len 0) (not pos))
    (if (= (substr str len 1) char)
      (setq pos len)
      (setq len (1- len))
    )
  )
  pos
)

(defun aa:gtx-key (txt)
  (setq txt (strcase (vl-string-trim " \t\r\n" txt)))
  (setq txt (vl-string-translate "－–—" "---" txt))
  (if (wcmatch txt "并入*")
    (setq txt (vl-string-left-trim " " (substr txt 3))))
  txt
)

(defun aa:gtx-natural-less (a b / original-a original-b ca cb na nb result decided)
  (setq original-a a original-b b a (aa:gtx-key a) b (aa:gtx-key b))
  (while (and (/= a "") (/= b "") (not decided))
    (setq ca (substr a 1 1) cb (substr b 1 1))
    (if (and (wcmatch ca "#") (wcmatch cb "#"))
      (progn
        (setq na "" nb "")
        (while (and (/= a "") (wcmatch (substr a 1 1) "#"))
          (setq na (strcat na (substr a 1 1)) a (substr a 2)))
        (while (and (/= b "") (wcmatch (substr b 1 1) "#"))
          (setq nb (strcat nb (substr b 1 1)) b (substr b 2)))
        (setq na (vl-string-left-trim "0" na) nb (vl-string-left-trim "0" nb))
        (if (/= na nb)
          (setq decided T result (if (= (strlen na) (strlen nb))
                                   (< na nb) (< (strlen na) (strlen nb))))))
      (if (/= ca cb)
        (setq decided T result (< ca cb))
        (setq a (substr a 2) b (substr b 2)))))
  (if decided result
    (if (= a b) (< original-a original-b) (= a "")))
)

;; Items retain cached WCS bounds; sorting first makes row anchors deterministic.
(defun aa:gtx-rows (items tolerance / rows row anchor item y)
  (setq items (aa:merge-sort items
    '(lambda (a b)
       (if (= (cadr (cadr a)) (cadr (cadr b)))
         (if (= (car (cadr a)) (car (cadr b)))
           (< (nth 4 a) (nth 4 b)) (< (car (cadr a)) (car (cadr b))))
         (> (cadr (cadr a)) (cadr (cadr b)))))))
  (foreach item items
    (setq y (cadr (cadr item)))
    (if (and row (> (- anchor y) (+ tolerance 1e-8)))
      (setq rows (cons (reverse row) rows) row nil))
    (if (not row) (setq anchor y))
    (setq row (cons item row)))
  (if row (setq rows (cons (reverse row) rows)))
  (reverse rows)
)

(defun aa:gtx-create-text-entity (pt content h sty)
  (entmake
    (list
      '(0 . "TEXT")
      (cons 10 pt)
      (cons 40 h)
      (cons 1 content)
      (cons 7 sty)
      '(41 . 0.7)
      '(62 . 7)))
)

(defun aa:gtx-first-text-from-ss (ss / i en)
  (setq i 0
        en nil)
  (while (and ss (< i (sslength ss)) (not en))
    (if (member (cdr (assoc 0 (entget (ssname ss i)))) '("TEXT" "MTEXT"))
      (setq en (ssname ss i))
    )
    (setq i (1+ i))
  )
  en
)

(defun aa:gtx-select-prefix-text (/ prefix-ss prefix-ent)
  (setq prefix-ent nil)
  (while (not prefix-ent)
    (sssetfirst nil nil)
    (prompt "\r\n[GTX] 请选择要加在每组前面的文字（支持框选）: ")
    (setq prefix-ss (ssget '((0 . "TEXT,MTEXT"))))
    (if (and prefix-ss (= (sslength prefix-ss) 1))
      (setq prefix-ent (aa:gtx-first-text-from-ss prefix-ss))
      (prompt "\r\n[GTX] 前缀必须只选一个文字对象。"))
    (if (not prefix-ent)
      (prompt "\r\n[GTX] 未选中文字。请点选或框选一个文字，按 Esc 取消。")
    )
  )
  prefix-ent
)

(defun c:GTX (/ aa:doc aa:undo-open *error* ss i ent ent-data text-data text-string insertion-point
               lines current-item current-y found line categorized-groups
               left-text temp-text last-hyphen-pos category group-texts found-category
               pt start-x current-x col-width line-height text-height text-style
               category-group groups-in-category sorted-groups group text-item
               split-groups current-group last-item-x current-item-x
               prefix-text-ent prefix-text-str item bbox heights base-height row-tol gap-limit
               skipped output-box output-width vla-ent)

  (vl-load-com)
  (setq text-style (if (tblsearch "STYLE" "HZ")
                     "HZ"
                     (getvar "TEXTSTYLE")))

  (defun *error* (msg)
    (aa:undo-mark-off)
    (if (not (member msg '("Function cancelled" "quit / exit abort")))
      (princ (strcat "\r\n[GTX] 错误: " msg))
    )
    (sssetfirst nil nil)
    (princ)
  )

  (aa:undo-mark-on)
  (setq ss (ssget "_I" '((0 . "TEXT,MTEXT"))))
  (if (not ss)
    (progn
      (prompt "\r\n[GTX] 请选择要分类的文字: ")
      (setq ss (ssget '((0 . "TEXT,MTEXT"))))
    )
  )

  (if ss
    (progn
      (setq prefix-text-ent (aa:gtx-select-prefix-text))
      (setq prefix-text-str (aa:ysdl-get-plain-text (entget prefix-text-ent)))

      (if prefix-text-str
        (progn
          (setq text-data '() skipped 0
                i         0)
          (repeat (sslength ss)
            (setq ent             (ssname ss i)
                  ent-data        (entget ent)
                  text-string     (aa:ysdl-get-plain-text ent-data)
                  vla-ent         (vlax-ename->vla-object ent)
                  bbox            (aa:try-get-bbox vla-ent))
            (vlax-release-object vla-ent)
            (if (and bbox (/= (vl-string-trim " \t\r\n" text-string) ""))
              (progn
                (setq insertion-point
                  (list (caar bbox) (/ (+ (cadar bbox) (cadadr bbox)) 2.0) 0.0))
                (setq text-data (cons (list text-string insertion-point
                  (caadr bbox) (cdr (assoc 40 ent-data)) (cdr (assoc 5 ent-data))) text-data))
                (setq heights (cons (max 1e-6 (cdr (assoc 40 ent-data))) heights)))
              (setq skipped (1+ skipped)))
            (setq i (1+ i))
          )
          (if (not text-data) (progn (prompt "\r\n[GTX] 没有可处理的文字。") (exit)))
          (setq heights (aa:merge-sort heights '<)
                base-height (nth (fix (/ (length heights) 2)) heights)
                row-tol (/ base-height 3.0)
                gap-limit (* base-height (/ 200.0 3.0)))
          (setq lines (aa:gtx-rows text-data row-tol))

          (setq lines
            (mapcar
              '(lambda (line)
                 (aa:merge-sort line '(lambda (a b)
                   (if (= (car (cadr a)) (car (cadr b)))
                     (< (nth 4 a) (nth 4 b)) (< (car (cadr a)) (car (cadr b)))))))
              lines))

          (setq split-groups '())
          (foreach line lines
            (if line
              (progn
                (setq current-group (list (car line))
                      last-item-x   (nth 2 (car line)))
                (foreach item (cdr line)
                  (setq current-item-x (car (cadr item)))
                  (if (> (- current-item-x last-item-x) (+ gap-limit 1e-8))
                    (progn
                      (setq split-groups (cons current-group split-groups))
                      (setq current-group (list item) last-item-x (nth 2 item)))
                    (setq current-group (append current-group (list item))
                          last-item-x (max last-item-x (nth 2 item)))
                  )
                )
                (setq split-groups (cons current-group split-groups))
              )
            )
          )
          (setq lines (reverse split-groups))

          (setq categorized-groups '())
          (foreach line lines
            (if (>= (length line) 1)
              (progn
                (setq left-text (caar line)
                      temp-text (aa:gtx-key left-text))
                (setq last-hyphen-pos (aa:gtx-find-last-char "-" temp-text))
                (if last-hyphen-pos
                  (setq category (substr temp-text 1 last-hyphen-pos))
                  (setq category temp-text)
                )
                (setq group-texts    (mapcar 'car line)
                      found-category (assoc category categorized-groups))
                (if found-category
                  (setq categorized-groups
                    (subst
                      (list category (cons group-texts (cadr found-category)))
                      found-category
                      categorized-groups))
                  (setq categorized-groups
                    (cons (list category (list group-texts)) categorized-groups))
                )
              )
            )
          )

          (setq pt (getpoint "\r\n[GTX] 请指定汇总结果的插入点: "))
          (if pt
            (progn
              (setq pt (trans pt 1 0))
              (setq text-height 3.0
                    start-x     (car pt)
                    current-y   (cadr pt)
                    col-width   50.0
                    line-height 5.0)

              (foreach text-item (cons prefix-text-str (mapcar 'car text-data))
                (setq output-box (textbox (list '(0 . "TEXT") (cons 1 text-item)
                  (cons 40 text-height) (cons 7 text-style) '(41 . 0.7))))
                (if output-box
                  (setq col-width (max col-width
                    (+ (* 2.0 text-height) (- (caadr output-box) (caar output-box)))))))
              (setq categorized-groups
                (aa:merge-sort categorized-groups
                  '(lambda (a b) (aa:gtx-natural-less (car a) (car b)))))

              (foreach category-group categorized-groups
                (setq groups-in-category (cadr category-group))

                (setq sorted-groups
                  (aa:merge-sort
                    groups-in-category
                    '(lambda (itemA itemB)
                       (aa:gtx-natural-less (car itemA) (car itemB))))
                )

                (foreach group sorted-groups
                  (setq current-x start-x)
                  (if (not (aa:gtx-create-text-entity (list current-x current-y (caddr pt)) prefix-text-str text-height text-style))
                    (progn (prompt "\r\n[GTX] 创建文字失败，已生成的结果可用 U 整体撤销。") (exit)))
                  (setq current-x (+ current-x col-width))
                  (foreach text-item group
                    (if (not (aa:gtx-create-text-entity (list current-x current-y (caddr pt)) text-item text-height text-style))
                      (progn (prompt "\r\n[GTX] 创建文字失败，已生成的结果可用 U 整体撤销。") (exit)))
                    (setq current-x (+ current-x col-width))
                  )
                  (setq current-y (- current-y line-height))
                )
                (setq current-y (- current-y (* 0.5 line-height)))
              )
              (princ "\r\n[GTX] 文字分类完成。")
              (if (> skipped 0)
                (princ (strcat " 空文字或无法读取包围盒的对象已跳过: " (itoa skipped))))
            )
            (princ "\r\n[GTX] 已取消。")
          )
        )
        (princ "\r\n[GTX] 未选中有效的前缀文字。")
      )
    )
    (princ "\r\n[GTX] 未选择文字。")
  )
  (aa:undo-mark-off)
  (sssetfirst nil nil)
  (princ)
)

(defun aa:gty-pad-left (txt size / result)
  (setq result txt)
  (while (< (strlen result) size)
    (setq result (strcat "0" result))
  )
  result
)

(defun aa:gty-normalize-key (txt / src i char num-buf result)
  (setq src     (strcase (vl-string-trim " " (if txt txt "")))
        i       1
        num-buf ""
        result  "")
  (while (<= i (strlen src))
    (setq char (substr src i 1))
    (if (wcmatch char "#")
      (setq num-buf (strcat num-buf char))
      (progn
        (if (> (strlen num-buf) 0)
          (progn
            (setq result  (strcat result (aa:gty-pad-left num-buf 8))
                  num-buf ""))
        )
        (setq result (strcat result char))
      )
    )
    (setq i (1+ i))
  )
  (if (> (strlen num-buf) 0)
    (setq result (strcat result (aa:gty-pad-left num-buf 8)))
  )
  result
)

(defun aa:gty-get-item-ename (item) (nth 0 item))
(defun aa:gty-get-item-text  (item) (nth 1 item))
(defun aa:gty-get-item-pt    (item) (nth 2 item))
(defun aa:gty-get-item-x     (item) (car (aa:gty-get-item-pt item)))
(defun aa:gty-get-item-y     (item) (cadr (aa:gty-get-item-pt item)))
(defun aa:gty-get-item-z     (item / pt)
  (setq pt (aa:gty-get-item-pt item))
  (if (caddr pt) (caddr pt) 0.0)
)
(defun aa:gty-get-item-width (item) (nth 3 item))

(defun aa:gty-build-sort-key (row idx / raw lead rest i key)
  ;; 取每行最左文字内容
  (if (>= (length row) 4)
    (setq raw (aa:gty-get-item-text (nth 1 row)))
    (setq raw "")
  )
  (if (null raw) (setq raw ""))
  ;; 剥离开头连续数字(系统号,如 1/2),作为最低优先级,实现按后段序列交叉排列
  (setq lead "" i 1)
  (while (and (<= i (strlen raw)) (wcmatch (substr raw i 1) "#"))
    (setq lead (strcat lead (substr raw i 1))
          i    (1+ i)))
  (setq rest (substr raw i))
  ;; 主键=去掉开头数字后的部分(内部数字补零做自然排序);次键=开头数字;末键=原序保稳定
  (setq key (aa:gty-normalize-key rest))
  (strcat
    (if (> (strlen key) 0) "0|" "1|")
    key
    "|"
    (aa:gty-pad-left lead 8)
    "|"
    (aa:gty-pad-left (itoa idx) 6))
)

(defun aa:gty-get-text-width (edata / box p1 p2 h txt)
  (setq h   (cond ((cdr (assoc 40 edata))) (3.0))
        txt (cdr (assoc 1 edata))
        box (textbox edata))
  (if (and box (= (length box) 2))
    (progn
      (setq p1 (car box)
            p2 (cadr box))
      (max (- (car p2) (car p1)) h))
    (max (* (strlen txt) h 0.7) h))
)

(defun aa:gty-update-nth (idx val lst / n result)
  (setq n 0
        result '())
  (foreach itm lst
    (setq result (cons (if (= n idx) val itm) result)
          n      (1+ n))
  )
  (reverse result)
)

(defun aa:gty-move-entity (ename from-pt to-pt / obj result)
  (if (and ename (setq obj (vlax-ename->vla-object ename)))
    (progn
      (setq result
        (vl-catch-all-apply
          'vla-move
          (list obj (vlax-3d-point from-pt) (vlax-3d-point to-pt))))
      (vlax-release-object obj)
      (not (vl-catch-all-error-p result))
    )
  )
)

(defun aa:gty-separated-rows (items tol newest-first / indexed i item ordered bands band high last-y y safe out pair line)
  ;; 仅在每个相邻 Y 带的跨度 <= 容差、带间距 > 容差时走快速路径。
  ;; 此时分行与输入顺序无关；仍用原输入序号恢复建行和入行顺序。
  ;; 连锁容差等歧义返回 nil，由调用方沿用原来的逐项判断。
  (setq indexed nil i 0)
  (foreach item items
    (setq indexed (cons (list i item) indexed) i (1+ i)))
  (setq ordered (aa:merge-sort (reverse indexed)
                  '(lambda (a b) (> (aa:gty-get-item-y (cadr a))
                                    (aa:gty-get-item-y (cadr b)))))
        bands nil band nil safe T)
  (while (and ordered safe)
    (setq pair (car ordered) y (aa:gty-get-item-y (cadr pair)))
    (if (or (null band) (> (- last-y y) tol))
      (progn
        (if band (setq bands (cons band bands)))
        (setq band (list pair) high y))
      (setq band (cons pair band)))
    (if (> (- high y) tol) (setq safe nil))
    (setq last-y y ordered (cdr ordered)))
  (if safe
    (progn
      (if band (setq bands (cons band bands)))
      (setq out nil)
      (foreach band bands
        (setq band (aa:merge-sort band '(lambda (a b) (< (car a) (car b))))
              line (mapcar 'cadr band))
        (setq out (cons (list (caar band) (if newest-first (reverse line) line)) out)))
      (setq out (aa:merge-sort out
                  (if newest-first '(lambda (a b) (> (car a) (car b)))
                                   '(lambda (a b) (< (car a) (car b))))))
      (list T (mapcar 'cadr out)))
    nil))

(defun aa:gty-add-row (item rows tol / prefix rest line hit)
  ;; 保留新行在前、最新入行文字成为代表点的语义；命中后复用尾链。
  (setq prefix nil rest rows hit nil)
  (while (and rest (not hit))
    (setq line (car rest))
    (if (<= (abs (- (aa:gty-get-item-y item) (aa:gty-get-item-y (car line)))) tol)
      (setq hit T)
      (setq prefix (cons line prefix) rest (cdr rest))))
  (if hit
    (append (reverse prefix) (cons (cons item line) (cdr rest)))
    (cons (list item) rows)))

(defun aa:gty-row-tree (rows n / half left rest i)
  ;; 原生字符串排序之后按原序号查回行；平衡树避免逐键 assoc 扫全表。
  (if (= n 1)
    (list 0 (car rows))
    (progn
      (setq half (/ n 2) left nil rest rows i 0)
      (while (< i half)
        (setq left (cons (car rest) left) rest (cdr rest) i (1+ i)))
      (list half (aa:gty-row-tree (reverse left) half)
                 (aa:gty-row-tree rest (- n half))))))

(defun aa:gty-tree-item (tree i)
  (while (> (car tree) 0)
    (if (< i (car tree))
      (setq tree (cadr tree))
      (setq i (- i (car tree)) tree (caddr tree))))
  (cadr tree))

(defun aa:gty-move-text-fast (ename from-pt to-pt / ed normal result)
  ;; 普通左基线、WCS 平面且无扩展字典/反应器的 TEXT 只改插入点。
  (if (equal from-pt to-pt)
    T
    (if (and (setq ed (entget ename))
             (= (cdr (assoc 0 ed)) "TEXT")
             (null (assoc 360 ed))
             (null (assoc 102 ed))
             (or (null (assoc 72 ed)) (= (cdr (assoc 72 ed)) 0))
             (or (null (assoc 73 ed)) (= (cdr (assoc 73 ed)) 0))
             (or (null (setq normal (cdr (assoc 210 ed))))
                 (equal normal '(0.0 0.0 1.0))))
      (progn
        (setq result (vl-catch-all-apply 'entmod
                       (list (subst (cons 10 to-pt) (assoc 10 ed) ed))))
        (if (and (not (vl-catch-all-error-p result)) result)
          T
          (aa:gty-move-entity ename from-pt to-pt)))
      (aa:gty-move-entity ename from-pt to-pt))))

(defun aa:gty-order-rows (rows row-tol fast-rows / comparator)
  (setq comparator '(lambda (a b / ay by ax bx)
             (setq ay (aa:gty-get-item-y (car a))
                   by (aa:gty-get-item-y (car b))
                   ax (aa:gty-get-item-x (car a))
                   bx (aa:gty-get-item-x (car b)))
             (if (> (abs (- ay by)) row-tol)
               (> ay by)
               (< ax bx))))
  (if fast-rows (aa:merge-sort rows comparator)
               (aa:insert-sort rows comparator)))

(defun aa:gty-column-widths (rows gap / widths rest out row item width)
  ;; 逐列沿尾链更新最大宽度，避免每格 length/nth 和整列替换扫描。
  (setq widths nil)
  (foreach row rows
    (setq rest widths out nil)
    (foreach item row
      (setq width (max gap (aa:gty-get-item-width item)
                           (if rest (car rest) gap))
            out (cons width out) rest (cdr rest)))
    (setq widths (append (reverse out) rest)))
  widths)

(defun aa:gty-copy-text (ename from-pt to-pt / obj clone copied moved result)
  ;; 使用原生 Copy 保留字高、样式、颜色、图层、对齐及扩展数据，只移动副本。
  (setq from-pt (trans from-pt ename 0)
        obj (vl-catch-all-apply 'vlax-ename->vla-object (list ename)))
  (if (not (vl-catch-all-error-p obj))
    (progn
      (setq clone (vl-catch-all-apply 'vla-copy (list obj)))
      (vlax-release-object obj)
      (if (not (vl-catch-all-error-p clone))
        (progn
          (setq copied (vl-catch-all-apply 'vlax-vla-object->ename (list clone)))
          (if (not (vl-catch-all-error-p copied))
            (setq moved (vl-catch-all-apply 'aa:gty-move-text-fast
                          (list copied from-pt to-pt))))
          (if (and moved (not (vl-catch-all-error-p moved)))
            (setq result copied)
            (vl-catch-all-apply 'vla-delete (list clone)))
          (vlax-release-object clone)))))
  result)

(defun aa:gty-delete-copies (copies / en obj)
  ;; 失败/取消时仅删除本次生成的副本，不触碰源文字。
  (foreach en copies
    (setq obj (vl-catch-all-apply 'vlax-ename->vla-object (list en)))
    (if (not (vl-catch-all-error-p obj))
      (progn
        (vl-catch-all-apply 'vla-delete (list obj))
        (vlax-release-object obj)))))

(defun c:GTY (/ *error* ss i ent ent-data text-string insertion-point text-height text-width
               text-data total-height avg-height row-tol split-gap col-gap line-height
               rows current-item current-y found split-rows current-row last-item-x current-item-x
               anchor-x anchor-y col-widths col-index row row-index sort-keys row-map token sorted-rows
               doc undo-started fast-rows width-rest target-pt copied copies)

  (vl-load-com)
  (setq doc          (vla-get-ActiveDocument (vlax-get-acad-object))
        undo-started nil)

  (defun *error* (msg)
    (aa:gty-delete-copies copies)
    (setq copies nil)
    (if undo-started
      (vla-EndUndoMark doc)
    )
    (if (not (member msg '("Function cancelled" "quit / exit abort")))
      (princ (strcat "\r\n[GTY] 错误: " msg))
    )
    (sssetfirst nil nil)
    (princ)
  )

  (setq ss (ssget "_I" '((0 . "TEXT"))))
  (if (not ss)
    (progn
      (prompt "\r\n[GTY] 请选择要整理的电缆文字: ")
      (setq ss (ssget '((0 . "TEXT"))))
    )
  )

  (if ss
    (progn
      (setq text-data     '()
            total-height  0.0
            i             0)

      (repeat (sslength ss)
        (setq ent             (ssname ss i)
              ent-data        (entget ent)
              text-string     (cdr (assoc 1 ent-data))
              insertion-point (cdr (assoc 10 ent-data))
              text-height     (cond ((cdr (assoc 40 ent-data))) (3.0))
              text-width      (aa:gty-get-text-width ent-data)
              text-data       (cons (list ent text-string insertion-point text-width text-height) text-data)
              total-height    (+ total-height text-height)
              i               (1+ i))
      )
      (setq text-data (reverse text-data))

      (setq avg-height  (/ total-height (max 1 (length text-data)))
            row-tol     (max 1.0 (* avg-height 0.6))
            split-gap   200.0
            col-gap     (max 10.0 (* avg-height 2.0))
            line-height 5.0)  ;; 行间 Y 坐标差固定为 5

      (setq fast-rows (if (> (length text-data) 128)
                        (aa:gty-separated-rows text-data row-tol T)))
      (if fast-rows
        (setq rows (cadr fast-rows))
        (progn
          (setq rows nil)
          (foreach current-item text-data
            (setq rows (aa:gty-add-row current-item rows row-tol)))))

      (setq rows
        (mapcar
          '(lambda (line)
             (aa:merge-sort line '(lambda (a b) (< (aa:gty-get-item-x a) (aa:gty-get-item-x b)))))
          rows))

      (setq split-rows '())
      (foreach row rows
        (if row
          (progn
            (setq current-row (list (car row))
                  last-item-x (aa:gty-get-item-x (car row)))
            (foreach current-item (cdr row)
              (setq current-item-x (aa:gty-get-item-x current-item))
              (if (> (- current-item-x last-item-x) split-gap)
                (progn
                  (setq split-rows (cons (reverse current-row) split-rows))
                  (setq current-row (list current-item)))
                (setq current-row (cons current-item current-row))
              )
              (setq last-item-x current-item-x)
            )
            (setq split-rows (cons (reverse current-row) split-rows))
          )
        )
      )
      (setq rows (reverse split-rows))

      (setq rows (aa:gty-order-rows rows row-tol fast-rows))

      (setq col-widths (aa:gty-column-widths rows col-gap))

      (setq sort-keys '()
            row-map   (aa:gty-row-tree rows (length rows))
            row-index 0)
      (foreach row rows
        (setq token     (aa:gty-build-sort-key row row-index)
              sort-keys (cons token sort-keys)
              row-index (1+ row-index))
      )
      (setq sorted-rows
        (mapcar
          '(lambda (key)
             (aa:gty-tree-item row-map
               (atoi (substr key (+ 2 (vl-string-position 124 key nil T))))))
          (acad_strlsort sort-keys)))

      (if (setq target-pt (getpoint "\r\n[GTY] 指定整理副本的第一行第一列位置: "))
        (progn
          (setq target-pt (trans target-pt 1 0)
                anchor-x (car target-pt) anchor-y (cadr target-pt)
                row-index 0 copies nil)
          (vla-StartUndoMark doc)
          (setq undo-started T)
          (foreach row sorted-rows
            (setq current-item-x anchor-x width-rest col-widths)
            (foreach current-item row
              (setq copied
                (aa:gty-copy-text
                  (aa:gty-get-item-ename current-item)
                  (aa:gty-get-item-pt current-item)
                  (list current-item-x
                        (- anchor-y (* row-index line-height))
                        (caddr target-pt))))
              (if copied
                (setq copies (cons copied copies))
                (progn
                  (princ "\r\n[GTY] 复制失败，正在清理本次副本，原文字保留。")
                  (quit)))
              (setq current-item-x (+ current-item-x (car width-rest) col-gap)
                    width-rest (cdr width-rest)))
            (setq row-index (1+ row-index)))
          (redraw)
          (vla-EndUndoMark doc)
          (setq undo-started nil copies nil)
          (princ "\r\n[GTY] 整理副本已生成，原文字保持不变。"))
        (princ "\r\n[GTY] 已取消放置，原文字保持不变。"))
    )
    (princ "\r\n[GTY] 未选择文字。")
  )
  (sssetfirst nil nil)
  (princ)
)

;;; =======================================================================================
;;; 命令: GTZ
;;; 功能: 将选中的交替柜名与电缆编号单列文字，按前后柜与电缆编号重组为3列表格输出。
;;; =======================================================================================
(defun c:GTZ (/ doc undo-started *error* ss i ent ent-data text-string insertion-point
               text-height text-width text-style text-layer text-data sorted-items
               rows r-idx c1-item code-item c2-item col1-w col2-w col3-w
               col-gap line-height anchor-x anchor-y row-idx pt)

  (vl-load-com)
  (setq doc          (vla-get-ActiveDocument (vlax-get-acad-object))
        undo-started nil)

  (defun *error* (msg)
    (if undo-started
      (vla-EndUndoMark doc)
    )
    (if (not (member msg '("Function cancelled" "quit / exit abort")))
      (princ (strcat "\r\n[GTZ] 错误: " msg))
    )
    (sssetfirst nil nil)
    (princ)
  )

  (setq ss (ssget "_I" '((0 . "TEXT"))))
  (if (not ss)
    (progn
      (prompt "\r\n[GTZ] 请选择交替的柜名与电缆文字: ")
      (setq ss (ssget '((0 . "TEXT"))))
    )
  )

  (if ss
    (if (< (sslength ss) 3)
      (princ "\r\n[GTZ] 选中的文字数量少于3个，无法组成电缆对。")
      (progn
        (setq text-data '()
              i         0)

        (repeat (sslength ss)
          (setq ent             (ssname ss i)
                ent-data        (entget ent)
                text-string     (cdr (assoc 1 ent-data))
                insertion-point (cdr (assoc 10 ent-data))
                text-height     (cond ((cdr (assoc 40 ent-data))) (3.0))
                text-width      (aa:gty-get-text-width ent-data)
                text-style      (cond ((cdr (assoc 7 ent-data))) ("STANDARD"))
                text-layer      (cond ((cdr (assoc 8 ent-data))) ("0"))
                text-data       (cons (list ent text-string insertion-point text-width text-height text-style text-layer) text-data)
                i               (1+ i))
        )

        ;; 按 Y 坐标从大到小（自上而下）排序
        (setq sorted-items
          (aa:merge-sort
            text-data
            '(lambda (a b)
               (> (cadr (nth 2 a)) (cadr (nth 2 b))))))

        ;; 重组行：每 2 步滑窗取 (c1, code, c2)
        (setq rows  '()
              r-idx 0)
        (while (<= (+ r-idx 2) (1- (length sorted-items)))
          (setq c1-item   (nth r-idx sorted-items)
                code-item (nth (+ r-idx 1) sorted-items)
                c2-item   (nth (+ r-idx 2) sorted-items))
          (setq rows (cons (list c1-item code-item c2-item) rows)
                r-idx (+ r-idx 2))
        )
        (setq rows (reverse rows))

        (if (null rows)
          (princ "\r\n[GTZ] 未能形成有效的电缆组合。")
          (progn
            (setq pt (getpoint "\r\n[GTZ] 请指定新表格的放置点: "))
            (if (not pt)
              (princ "\r\n[GTZ] 已取消放置。")
              (progn
                (setq pt (trans pt 1 0))
                (vla-StartUndoMark doc)
                (setq undo-started T)

                ;; 计算3列的最大宽度
                (setq col1-w 0.0
                      col2-w 0.0
                      col3-w 0.0)
                (foreach r rows
                  (setq col1-w (max col1-w (nth 3 (nth 0 r)))
                        col2-w (max col2-w (nth 3 (nth 1 r)))
                        col3-w (max col3-w (nth 3 (nth 2 r))))
                )

                (setq col-gap     (max 5.0 (* (nth 4 (nth 0 sorted-items)) 1.5))
                      line-height 5.0
                      anchor-x    (car pt)
                      anchor-y    (cadr pt)
                      row-idx     0)

                ;; 逐行放置并生成文字（第1行移动原对象；后续行复制/生成共享柜名）
                (foreach r rows
                  (setq c1-item   (nth 0 r)
                        code-item (nth 1 r)
                        c2-item   (nth 2 r))

                  ;; 第1列：起始柜
                  (if (= row-idx 0)
                    (aa:gty-move-entity
                      (nth 0 c1-item)
                      (nth 2 c1-item)
                      (list anchor-x (- anchor-y (* row-idx line-height)) (caddr pt)))
                    (entmake
                      (list
                        '(0 . "TEXT")
                        (cons 10 (list anchor-x (- anchor-y (* row-idx line-height)) (caddr pt)))
                        (cons 40 (nth 4 c1-item))
                        (cons 1  (nth 1 c1-item))
                        (cons 7  (nth 5 c1-item))
                        (cons 8  (nth 6 c1-item))
                        '(41 . 0.7)
                        '(72 . 0))))

                  ;; 第2列：电缆编号（都是唯一实体，直接移动）
                  (aa:gty-move-entity
                    (nth 0 code-item)
                    (nth 2 code-item)
                    (list (+ anchor-x col1-w col-gap) (- anchor-y (* row-idx line-height)) (caddr pt)))

                  ;; 第3列：终点柜（若是最后一行，移动最后一个原实体；否则生成新实体）
                  (if (= row-idx (1- (length rows)))
                    (aa:gty-move-entity
                      (nth 0 c2-item)
                      (nth 2 c2-item)
                      (list (+ anchor-x col1-w col-gap col2-w col-gap) (- anchor-y (* row-idx line-height)) (caddr pt)))
                    (entmake
                      (list
                        '(0 . "TEXT")
                        (cons 10 (list (+ anchor-x col1-w col-gap col2-w col-gap) (- anchor-y (* row-idx line-height)) (caddr pt)))
                        (cons 40 (nth 4 c2-item))
                        (cons 1  (nth 1 c2-item))
                        (cons 7  (nth 5 c2-item))
                        (cons 8  (nth 6 c2-item))
                        '(41 . 0.7)
                        '(72 . 0))))

                  (setq row-idx (1+ row-idx))
                )

                (redraw)
                (princ (strcat "\r\n[GTZ] 成功重组成 " (itoa (length rows)) " 根电缆3列表格并放置到新位置。"))
                (vla-EndUndoMark doc)
                (setq undo-started nil)
              )
            )
          )
        )
      )
    )
    (princ "\r\n[GTZ] 未选择文字。")
  )
  (sssetfirst nil nil)
  (princ)
)

;;; =======================================================================================
;;; 命令: HWD
;;; 功能: 将横排交替柜名与电缆编号通用重组为起点、编号、终点三列，左中对齐、行距5；保留原横排。
;;; =======================================================================================
(defun aa:hwd-rows (items / rows)
  ;; 相邻电缆共享柜名，每次前进两项；不依赖内容、颜色、图层或编号格式。
  (while (cddr items)
    (setq rows (cons (list (car items) (cadr items) (caddr items)) rows)
          items (cddr items)))
  (reverse rows))

(defun aa:hwd-make-text (ed pt / data pair key)
  ;; 仅复制显示属性；不复制句柄、所有者、扩展字典及原来的对齐/法向量。
  ;; 新文字在WCS水平面左中对齐，消除源文字中意外的不同Z坐标。
  (setq data (list '(0 . "TEXT") '(100 . "AcDbEntity")))
  (foreach key '(67 410 8 6 62 420 430 440 370)
    (if (setq pair (assoc key ed)) (setq data (append data (list pair)))))
  (setq data (append data (list '(100 . "AcDbText") (cons 10 pt)
                (assoc 40 ed) (assoc 1 ed))))
  (foreach key '(7 41 51 71)
    (if (setq pair (assoc key ed)) (setq data (append data (list pair)))))
  (setq data (append data (list '(50 . 0.0) '(72 . 0) (cons 11 pt)
                '(100 . "AcDbText") '(73 . 2) '(210 0.0 0.0 1.0))))
  (if (entmake data) (entlast)))

(defun c:HWD (/ *error* aa:tag aa:doc aa:undo-open aa:old-cmdecho
               ss i en ed bbox items rows item row bad min-y max-y max-h total-h avg-height
               col1-w col2-w gap pt x1 x2 x3 y z made new-en ok col key)
  (aa:cmd-begin "HWD")
  (setq ss (ssget "_I" '((0 . "TEXT"))))
  (if (null ss)
    (progn
      (prompt "\r\n[HWD] 请选择一整横排单行文字（柜名、编号、柜名……，含两端柜名）: ")
      (setq ss (ssget '((0 . "TEXT"))))))
  (cond
    ((null ss) (princ "\r\n[HWD] 未选择文字。"))
    ((or (< (sslength ss) 3) (= (rem (sslength ss) 2) 0))
      (princ "\r\n[HWD] 需要至少3个且为奇数的文字，请完整选择交替排列的柜名与编号。"))
    (T
      (setq i 0 max-h 0.0 total-h 0.0)
      (repeat (sslength ss)
        (setq en (ssname ss i) ed (entget en)
              bbox (aa:safe-get-bbox aa:doc en) i (1+ i))
        (cond
          ((/= 0 (logand 4 (cdr (assoc 70 (tblsearch "LAYER" (cdr (assoc 8 ed)))))))
            (setq bad "所选文字位于锁定图层，请先解锁。"))
          ((or (null bbox) (<= (cdr (assoc 40 ed)) 0.0)
               (not (equal (cond ((cdr (assoc 210 ed))) ('(0.0 0.0 1.0))) '(0.0 0.0 1.0) 1e-8))
               (not (equal (sin (cond ((cdr (assoc 50 ed))) (0.0))) 0.0 1e-8))
               (< (cos (cond ((cdr (assoc 50 ed))) (0.0))) 0.0))
            (setq bad "仅支持WCS平面内水平的单行文字，或存在无法读取范围的文字。"))
          (T
            (setq y (/ (+ (cadr (car bbox)) (cadr (cadr bbox))) 2.0)
                  min-y (if min-y (min min-y y) y)
                  max-y (if max-y (max max-y y) y)
                  max-h (max max-h (cdr (assoc 40 ed)))
                  total-h (+ total-h (cdr (assoc 40 ed)))
                  items (cons (list ed (car (car bbox))
                              (max (aa:gty-get-text-width ed)
                                   (- (car (cadr bbox)) (car (car bbox))))) items)))))
      (if (and (null bad) (> (- max-y min-y) (* max-h 0.6)))
        (setq bad "所选文字不在同一横排，请每次只选择一条环网。"))
      (if bad
        (princ (strcat "\r\n[HWD] " bad))
        (progn
          (setq items (aa:merge-sort items '(lambda (a b) (< (cadr a) (cadr b))))
                rows (aa:hwd-rows items)
                avg-height (/ total-h (float (length items)))
                gap (max 10.0 (* avg-height 2.0))
                col1-w gap col2-w gap)
          (foreach row rows
            (setq col1-w (max col1-w (caddr (car row)))
                  col2-w (max col2-w (caddr (cadr row)))))
          ;; 与GTY一致：列宽取最长文字且不小于列间距，列间距至少10。
          (setq pt (getpoint "\r\n[HWD] 指定第一行起点柜文字的左中位置（保留原横排）: "))
          (if pt
            (progn
              (setq pt (trans pt 1 0) x1 (car pt) x2 (+ x1 col1-w gap)
                    x3 (+ x2 col2-w gap) y (cadr pt) z (caddr pt) ok T)
              (foreach row rows
                (setq col 0)
                (foreach item row
                  (if ok
                    (progn
                      (setq new-en (aa:hwd-make-text (car item)
                                      (list (nth col (list x1 x2 x3)) y z)))
                      (if new-en (setq made (cons new-en made)) (setq ok nil))))
                  (setq col (1+ col)))
                (setq y (- y 5.0)))
              (if ok
                (princ (strcat "\r\n[HWD] 已整理 " (itoa (length rows))
                         " 根电缆：起点、编号、终点三列，左中对齐、行距5；原横排保留。"))
                (progn
                  (foreach en made (entdel en))
                  (princ "\r\n[HWD] 生成失败，已清理本次结果，原横排保留。")))
              (redraw))
            (princ "\r\n[HWD] 已取消放置。"))))))
  (aa:cmd-end)
  (princ))

(defun bian-make-text (pt txt sty / data)
  (setq data
    (list
      '(0 . "TEXT")
      '(100 . "AcDbEntity")
      '(100 . "AcDbText")
      (cons 10 pt)
      (cons 40 3.0)
      (cons 1 txt)
      (cons 7 sty)
      '(72 . 0)
      (cons 11 pt)
      '(50 . 0.0)
      '(41 . 0.7)
      '(51 . 0.0)
      '(71 . 0)
      '(73 . 0)
    )
  )
  (entmake data)
)

(defun bian-right-point (p1 p2)
  (if (> (car p1) (car p2)) p1 p2)
)

(defun bian-draw-one (ed sty / p1 p2 rp oz alt half bp1 bp2)
  (setq p1   (cdr (assoc 10 ed))
        p2   (cdr (assoc 11 ed))
        rp   (bian-right-point p1 p2)
        oz   (list (- (car rp) 40.0) (cadr rp) 0.0)
        alt  (* 2.5 (sqrt 3.0))
        half 2.5
        bp1  (list (- (car oz) alt) (+ (cadr oz) half) 0.0)
        bp2  (list (- (car oz) alt) (- (cadr oz) half) 0.0))

  (entmake
    (list
      '(0 . "LWPOLYLINE")
      '(100 . "AcDbEntity")
      '(100 . "AcDbPolyline")
      '(90 . 3)
      '(70 . 1)
      (cons 10 (list (car oz)  (cadr oz)))
      (cons 10 (list (car bp1) (cadr bp1)))
      (cons 10 (list (car bp2) (cadr bp2)))
    )
  )

  (bian-make-text (list (+ (car oz) 1.5)   (+ (cadr oz) 0.5) 0.0) "\\U+81F3"  sty)
  (bian-make-text (list (+ (car oz) 27.0)  (+ (cadr oz) 0.5) 0.0) "2\\U+00D74" sty)
  (bian-make-text (list (+ (car oz) -20.0) (+ (cadr oz) 0.5) 0.0) "UPS-12"    sty)
)

(defun c:BIAN (/ *error* aa:tag aa:doc aa:undo-open aa:old-cmdecho ss i ent ed sty cnt)
  (aa:cmd-begin "BIAN")
  (setq sty (if (tblsearch "STYLE" "HZ") "HZ" (getvar "TEXTSTYLE")))

  (if (setq ss (ssget '((0 . "LINE"))))
    (progn
      (setq i 0
            cnt (sslength ss))
      (repeat cnt
        (setq ent (ssname ss i)
              ed  (entget ent))
        (bian-draw-one ed sty)
        (setq i (1+ i))
      )
      (if (tblsearch "STYLE" "HZ")
        (princ (strcat "\r\nBIAN 已完成，共处理 " (itoa cnt) " 条直线。"))
        (princ
          (strcat
            "\r\nBIAN 已完成，共处理 "
            (itoa cnt)
            " 条直线；未找到样式 HZ，改用当前样式 "
            sty
            "."
          )
        )
      )
    )
    (princ "\r\n请先选择直线，再运行 BIAN。")
  )
  (aa:cmd-end)
)
;;; =======================================================================================
;;; 命令: LAN
;;; 功能: 竖直线/斜线/水平线联动复制+移动插件。
;;;       连续模式：x 条竖直线相邻间距均为 5 时，副本右移 5*x 单位；
;;;       间隔模式：竖直线相邻间距均大于 5（如 4/20/36/52 号端子）时，副本各右移 5 单位。
;;;       S = 向上 5，X = 向下 5；所有对象先原地复制，再对副本执行移动/变形，原始对象不动。
;;;       水平线：副本上/下移 5；连续模式左端缩短 5*x，间隔模式左端对齐最左竖线副本（右端均不动）
;;; =======================================================================================

;; 按竖直线 X 坐标判断模式：相邻间距全为 5 → "C"（连续）；全大于 5 → "S"（间隔）；否则 nil
(defun lan-vert-mode (vert_lines / xs prev gaps)
  (setq xs (aa:merge-sort
             (mapcar '(lambda (e) (car (cdr (assoc 10 (entget e))))) vert_lines)
             '<))
  (setq prev (car xs))
  (foreach x (cdr xs)
    (setq gaps (cons (- x prev) gaps)
          prev x))
  (cond
    ((vl-every '(lambda (g) (< (abs (- g 5.0)) 0.01)) gaps) "C")
    ((vl-every '(lambda (g) (> g 5.01)) gaps) "S")
  )
)

(defun lan-get-option (vert_count move_right mode / kw)
  (initget "Shang Xia")
  (setq kw
    (getkword
      (strcat "\r\n检测到 " (itoa vert_count)
              (if (equal mode "S") " 条间隔竖直线" " 条连续竖直线")
              "，副本将右移 " (rtos move_right 2 0)
              " 单位。请选择方向 [向上(Shang)/向下(Xia)] <向上>: ")))

  (cond
    ((or (null kw) (equal kw "Shang")) "S")
    ((equal kw "Xia") "X")
  )
)

(defun c:LAN ( / *error* aa:tag aa:doc aa:undo-open aa:old-cmdecho ss total_count
               vert_lines  horiz_lines  diag_lines
               vert_count  horiz_count  diag_count
               opt  move_right  dy  mode  min_x
               i  ent  copy_ent  entdata
               pt1 pt2 new_pt1 new_pt2 )
  (aa:cmd-begin "LAN")

  ;; 1. 取得选择集
  (setq ss (ssget))
  (if (null ss)
    (progn (princ "\r\n未选中任何对象。") (exit))
  )

  (setq total_count (sslength ss)
        vert_lines  '()
        horiz_lines '()
        diag_lines  '())

  ;; 2. 分类：竖直线 / 水平线 / 斜线
  (setq i 0)
  (while (< i total_count)
    (setq ent     (ssname ss i)
          entdata (entget ent)
          pt1     (cdr (assoc 10 entdata))
          pt2     (cdr (assoc 11 entdata)))

    (if (and pt1 pt2)
      (cond
        ((< (abs (- (car pt1) (car pt2))) 0.001)
         (setq vert_lines (cons ent vert_lines)))
        ((< (abs (- (cadr pt1) (cadr pt2))) 0.001)
         (setq horiz_lines (cons ent horiz_lines)))
        (T
         (setq diag_lines (cons ent diag_lines)))
      )
    )
    (setq i (1+ i))
  )

  (setq vert_count  (length vert_lines)
        horiz_count (length horiz_lines)
        diag_count  (length diag_lines))

  ;; 3. 校验选择集
  (cond
    ((= vert_count 0)
     (princ "\r\n错误：未检测到竖直直线，请重新选择。")
     (exit))
    ((/= horiz_count 1)
     (princ (strcat "\r\n错误：需要恰好 1 条水平直线，当前检测到 "
                    (itoa horiz_count) " 条。"))
     (exit))
    ((/= diag_count vert_count)
     (princ (strcat "\r\n错误：斜线数量（" (itoa diag_count)
                    "）与竖直线数量（" (itoa vert_count)
                    "）不匹配。"))
     (exit))
  )

  ;; 4. 判断连续/间隔模式并计算移动量
  (setq mode (lan-vert-mode vert_lines))
  (if (null mode)
    (progn
      (princ "\r\n错误：竖直线间距混杂（部分相距 5、部分更远），请分批选择。")
      (exit)))
  (setq move_right (if (equal mode "S") 5.0 (* 5 vert_count)))

  ;; 5. 获取 S / X 选项
  (setq opt (lan-get-option vert_count move_right mode))
  (if (null opt)
    (progn (princ "\r\n已取消。") (exit)))

  (setq dy (if (equal opt "S") 5.0 -5.0))

  ;; 6. 处理竖直直线：复制 → 右移 move_right → 端点延长 5
  (foreach ent vert_lines
    (setq copy_ent (entmakex (entget ent))
          entdata  (entget copy_ent)
          pt1      (cdr (assoc 10 entdata))
          pt2      (cdr (assoc 11 entdata)))

    (setq new_pt1 (list (+ (car pt1) move_right) (cadr pt1) (caddr pt1))
          new_pt2 (list (+ (car pt2) move_right) (cadr pt2) (caddr pt2)))
    (if (or (null min_x) (< (car new_pt1) min_x))
      (setq min_x (car new_pt1)))

    (if (> (cadr new_pt1) (cadr new_pt2))
      (if (> dy 0)
        (setq new_pt1 (list (car new_pt1) (+ (cadr new_pt1) 5.0) (caddr new_pt1)))
        (setq new_pt2 (list (car new_pt2) (- (cadr new_pt2) 5.0) (caddr new_pt2))))
      (if (> dy 0)
        (setq new_pt2 (list (car new_pt2) (+ (cadr new_pt2) 5.0) (caddr new_pt2)))
        (setq new_pt1 (list (car new_pt1) (- (cadr new_pt1) 5.0) (caddr new_pt1))))
    )

    (setq entdata (subst (cons 10 new_pt1) (assoc 10 entdata) entdata))
    (setq entdata (subst (cons 11 new_pt2) (assoc 11 entdata) entdata))
    (entmod entdata)
  )

  ;; 7. 处理斜线：复制 → 右移 move_right → 上/下移 5
  (foreach ent diag_lines
    (setq copy_ent (entmakex (entget ent))
          entdata  (entget copy_ent)
          pt1      (cdr (assoc 10 entdata))
          pt2      (cdr (assoc 11 entdata)))

    (setq new_pt1 (list (+ (car pt1) move_right) (+ (cadr pt1) dy) (caddr pt1))
          new_pt2 (list (+ (car pt2) move_right) (+ (cadr pt2) dy) (caddr pt2)))

    (setq entdata (subst (cons 10 new_pt1) (assoc 10 entdata) entdata))
    (setq entdata (subst (cons 11 new_pt2) (assoc 11 entdata) entdata))
    (entmod entdata)
  )

  ;; 8. 处理水平直线：复制 → 上/下移 5 → 左端缩短（右端不动）
  ;;    连续模式左端右移 move_right；间隔模式左端直接对齐最左竖线副本的 X
  (foreach ent horiz_lines
    (setq copy_ent (entmakex (entget ent))
          entdata  (entget copy_ent)
          pt1      (cdr (assoc 10 entdata))
          pt2      (cdr (assoc 11 entdata)))

    (if (< (car pt1) (car pt2))
      (setq new_pt1 (list (if (equal mode "S") min_x (+ (car pt1) move_right))
                          (+ (cadr pt1) dy) (caddr pt1))
            new_pt2 (list (car pt2)                 (+ (cadr pt2) dy) (caddr pt2)))
      (setq new_pt1 (list (car pt1)                 (+ (cadr pt1) dy) (caddr pt1))
            new_pt2 (list (if (equal mode "S") min_x (+ (car pt2) move_right))
                          (+ (cadr pt2) dy) (caddr pt2)))
    )

    (setq entdata (subst (cons 10 new_pt1) (assoc 10 entdata) entdata))
    (setq entdata (subst (cons 11 new_pt2) (assoc 11 entdata) entdata))
    (entmod entdata)
  )

  ;; 9. 完成提示
  (princ
    (strcat "\r\n完成！所有对象已原地复制。"
            "\r\n副本：竖直线 & 斜线右移 " (rtos move_right 2 0)
            " 单位 + " (if (> dy 0) "向上" "向下") " 5 单位；"
            "\r\n      水平线 " (if (> dy 0) "向上" "向下")
            (if (equal mode "S")
              " 5 单位 + 左端对齐最左竖线副本（右端不动）。"
              (strcat " 5 单位 + 左端缩短 " (rtos move_right 2 0) " 单位（右端不动）。"))))
  (aa:cmd-end)
)


;;; =======================================================================================
;;; 命令: XIN
;;; 功能: 统计每条选中直线矩形范围内的对象数量，并在直线右端标注统计值。
;;; =======================================================================================
(defun c:XIN ( / *error* aa:tag aa:doc aa:undo-open aa:old-cmdecho ss i ent entData pt1 pt2 leftX rightX topY bottomY
                countSS countNum insertPt textStr rightPt)
  (aa:cmd-begin "XIN")
  (setq ss (ssget '((0 . "LINE"))))
  (if (null ss)
    (progn
      (alert "未选择任何直线！")
      (exit)
    )
  )

  (setq i 0)
  (while (< i (sslength ss))
    (setq ent (ssname ss i))
    (setq entData (entget ent))

    (setq pt1 (cdr (assoc 10 entData)))
    (setq pt2 (cdr (assoc 11 entData)))

    (if (< (car pt1) (car pt2))
      (progn
        (setq leftX (car pt1))
        (setq rightX (car pt2))
        (setq rightPt pt2)
      )
      (progn
        (setq leftX (car pt2))
        (setq rightX (car pt1))
        (setq rightPt pt1)
      )
    )

    (setq topY (+ (cadr pt1) 1.6))
    (setq bottomY (- (cadr pt1) 1.6))

    (setq countSS
           (ssget "W"
             (list leftX bottomY 0.0)
             (list rightX topY 0.0)
           )
    )

    (if countSS
      (progn
        (setq countNum (sslength countSS))
        (if (ssmemb ent countSS)
          (progn
            (ssdel ent countSS)
            (setq countNum (1- countNum))
          )
        )
      )
      (setq countNum 0)
    )

    (setq insertPt (list (+ (car rightPt) 2) (+ (cadr rightPt) 0.5) 0.0))
    (setq textStr (itoa countNum))

    (entmake
      (list
        (cons 0 "TEXT")
        (cons 10 insertPt)
        (cons 40 3.0)
        (cons 1 textStr)
        (cons 7 "Standard")
        (cons 50 0.0)
      )
    )

    (setq i (1+ i))
  )

  (princ (strcat "\r\n处理完成，共处理 " (itoa (sslength ss)) " 条直线。"))
  (aa:cmd-end)
)


;;; =======================================================================================
;;; 命令: XY
;;; 来源: 小命令\芯原XY.lsp
;;; 功能: 先运行 XIN 统计芯数，再运行 YUAN 提取对应文字并横向输出。
;;; =======================================================================================
(vl-load-com)

;; =========================
;; XY 参数区
;; =========================
(setq *xy-geom-tol*      1e-4)             ; 连接与去重容差（不用于放宽芯线倾斜）
(setq *xy-conn-tol*      0.05)             ; 端点实施连接容差（允许竖线端点与水平线有微小间隙）
(setq *xy-vline-ang-tol* (/ pi 180.0))     ; 芯线偏离竖直方向的独立角度容差：1°
(setq *xy-ang-tol*       (/ pi 180.0))     ; 角度容差：±1°
(setq *xy-ray-len*       20.0)             ; 竖直搜索区高度
(setq *xy-hit-half-width* 1.0)             ; 搜索矩形半宽
(setq *xy-out-offx*      10.0)             ; 输出起点相对水平线右端点偏移 X
(setq *xy-out-offy*      0.5)              ; 输出起点相对水平线右端点偏移 Y
(setq *xy-step-x*        30.0)             ; 新文字插入点固定间距
(setq *xy-warn-extend-len* 200.0)          ; 异常水平线右端点延长距离
(setq *xy-last-xin-counts* nil)            ; 最近一次XIN输出数字表
(setq *xy-last-vrec-map*   nil)            ; 最近一次每条水平线匹配到的竖线表
(setq *xy-last-vline-data* nil)            ; 最近一次 pre-fetched 竖直线数据 (en x y1 y2)
(setq *xy-vline-buckets* nil)              ; 竖线按 X 分桶索引 (bucket-id . vdata-list)
(setq *xy-vline-bucket-size* 100.0)        ; 竖线分桶宽度（图纸单位）

;; =========================
;; 通用函数
;; =========================
(defun xy:abs (x)
  (if (< x 0.0) (- x) x)
)

(defun xy:near (a b tol)
  (<= (xy:abs (- a b)) tol)
)

(defun xy:between (v a b tol)
  (and (>= v (- (min a b) tol))
       (<= v (+ (max a b) tol)))
)

(defun xy:ss->list (ss / i lst)
  (setq lst '())
  (if ss
    (progn
      (setq i 0)
      (while (< i (sslength ss))
        (setq lst (cons (ssname ss i) lst))
        (setq i (1+ i))
      )
    )
  )
  (reverse lst)
)

(defun xy:selection-bounds (entities / en ed p1 p2 minx miny maxx maxy)
  ;; 从当前选择集计算窗口，避免为 XY/YUAN 扫描整张图纸。
  (foreach en entities
    (setq ed (entget en)
          p1 (cdr (assoc 10 ed))
          p2 (cdr (assoc 11 ed)))
    (if p1
      (setq minx (if minx (min minx (car p1)) (car p1))
            miny (if miny (min miny (cadr p1)) (cadr p1))
            maxx (if maxx (max maxx (car p1)) (car p1))
            maxy (if maxy (max maxy (cadr p1)) (cadr p1))))
    (if p2
      (setq minx (if minx (min minx (car p2)) minx)
            miny (if miny (min miny (cadr p2)) miny)
            maxx (if maxx (max maxx (car p2)) maxx)
            maxy (if maxy (max maxy (cadr p2)) maxy))))
  (if minx
    (list (list minx miny 0.0) (list maxx maxy 0.0)))
)

(defun xy:is-vertical-line-ed-p (ed tol / p1 p2 dx dy)
  (and (= (cdr (assoc 0 ed)) "LINE")
       (setq p1 (cdr (assoc 10 ed)))
       (setq p2 (cdr (assoc 11 ed)))
       (setq dx (xy:abs (- (car p1) (car p2))))
       (setq dy (xy:abs (- (cadr p1) (cadr p2))))
       (> dy tol)
       (<= (atan dx dy) *xy-vline-ang-tol*)))

(defun xy:pt-offset-x (pt dx)
  (cons (+ (car pt) dx) (cdr pt))
)

(defun xy:remove-dxf-codes (ed codes)
  (vl-remove-if
    '(lambda (pair) (member (car pair) codes))
    ed)
)

(defun xy:mark-abnormal-hline (en / ed p1 p2 code newPt)
  (setq ed (entget en))
  (setq p1 (cdr (assoc 10 ed)) p2 (cdr (assoc 11 ed)))
  (if (and p1 p2)
    (progn
      (setq code (if (>= (car p1) (car p2)) 10 11))
      (setq newPt (xy:pt-offset-x (cdr (assoc code ed)) *xy-warn-extend-len*))
      (setq ed (subst (cons code newPt) (assoc code ed) ed))
      (setq ed (xy:remove-dxf-codes ed '(62 420 430 440)))
      (entmod (append ed (list (cons 62 1))))
    )
  )
)

;; 从已取得的 entget 数据直接计算水平线信息，避免重复 entget
(defun xy:hline-info-ed (ed / p1 p2 x1 x2 y rightpt)
  (setq p1 (cdr (assoc 10 ed)))
  (setq p2 (cdr (assoc 11 ed)))
  (setq x1 (car p1))
  (setq x2 (car p2))
  (setq y  (cadr p1))
  (setq rightpt (if (>= x1 x2) p1 p2))
  (list (min x1 x2) (max x1 x2) y rightpt)
)

(defun xy:norm-angle (a)
  (while (< a 0.0)
    (setq a (+ a (* 2.0 pi)))
  )
  (while (>= a (* 2.0 pi))
    (setq a (- a (* 2.0 pi)))
  )
  a
)

(defun xy:is-vertical-text-90-p (ang tol / a)
  (setq a (xy:norm-angle ang))
  (or (<= (xy:abs (- a (/ pi 2.0))) tol)
      (<= (xy:abs (- a (* 1.5 pi))) tol))
)

(defun xy:dxf (code ed default / pair)
  (setq pair (assoc code ed))
  (if pair (cdr pair) default)
)

(defun xy:is-text-entity-p (en / typ)
  (setq typ (cdr (assoc 0 (entget en))))
  (or (= typ "TEXT") (= typ "MTEXT"))
)

(defun xy:get-text-rotation (ed / direction)
  (if (and (= (cdr (assoc 0 ed)) "MTEXT")
           (setq direction (cdr (assoc 11 ed))))
    (atan (cadr direction) (car direction))
    (xy:dxf 50 ed 0.0))
)

(defun xy:get-text-height (ed)
  (xy:dxf 40 ed 3.0)
)

(defun xy:get-text-style (ed)
  (xy:dxf 7 ed "Standard")
)

(defun xy:get-text-value (ed)
  (xy:dxf 1 ed "")
)

;; =========================
;; XIN 功能
;; =========================
(defun xy:filter-vertical-lines (lineList / out en ed p1 p2)
  (setq out '())
  (foreach en lineList
    (setq ed (entget en))
    (if (xy:is-vertical-line-ed-p ed *xy-geom-tol*)
      (progn
        (setq p1 (cdr (assoc 10 ed)))
        (setq p2 (cdr (assoc 11 ed)))
        ;; 按两个端点分别建立连接候选，分桶使用连接端 X，找文字使用真实远端。
        (setq out (cons (list en p1 p2) out))
        (setq out (cons (list en p2 p1) out))
      )
    )
  )
  (reverse out)
)

;; 竖线数据按 X 坐标分桶：查询时只检查水平线 x 区间内的桶，避免全表扫描
(defun xy:build-vline-buckets (vlineDataList / out b vd)
  (setq out '())
  (foreach vd vlineDataList
    (setq b (fix (/ (car (cadr vd)) *xy-vline-bucket-size*)))
    (setq out (cons (cons b (cons vd (cdr (assoc b out)))) out)))
  (setq *xy-vline-buckets* out)
  out
)

;; 用已取得的 entget 数据计算匹配竖线（避免重复 entget）；竖线按 X 分桶后只查区间内桶
(defun xy:get-vrecs-for-hline-ed (ed vlineDataList / handle pair hinfo xmin xmax vrecs b1 b2 bi vd vrec)
  (setq handle (cdr (assoc 5 ed)))
  (setq pair (assoc handle *xy-last-vrec-map*))
  (if pair
    (cdr pair)
    (progn
      (setq hinfo (xy:hline-info-ed ed))
      (setq xmin (car hinfo))
      (setq xmax (cadr hinfo))
      (setq vrecs '())
      (if *xy-vline-buckets*
        (progn
          (setq b1 (fix (/ (- xmin *xy-geom-tol*) *xy-vline-bucket-size*)))
          (setq b2 (fix (/ (+ xmax *xy-geom-tol*) *xy-vline-bucket-size*)))
          (setq bi b1)
          (while (<= bi b2)
            (setq pair (assoc bi *xy-vline-buckets*))
            (if pair
              (foreach vd (cdr pair)
                (setq vrec (xy:make-vrec-if-valid-fast vd hinfo *xy-geom-tol*))
                (if vrec
                  (setq vrecs (cons vrec vrecs))
                )
              )
            )
            (setq bi (1+ bi))
          )
        )
        (foreach vd vlineDataList
          (setq vrec (xy:make-vrec-if-valid-fast vd hinfo *xy-geom-tol*))
          (if vrec
            (setq vrecs (cons vrec vrecs))
          )
        )
      )
      (xy:dedup-vrecs vrecs *xy-geom-tol*)
    )
  )
)

(defun xy:window-wcs (xmin ymin xmax ymax filter / corners xs ys p1 p2 ss)
  ;; 四角转换后取 UCS 外包矩形，若视口内交叉选择为空则回退全图范围过滤，彻底消除视口缩放影响
  (setq corners (mapcar '(lambda (p) (trans p 0 1))
                  (list (list xmin ymin 0.0) (list xmax ymin 0.0)
                        (list xmax ymax 0.0) (list xmin ymax 0.0))))
  (setq xs (mapcar 'car corners) ys (mapcar 'cadr corners))
  (setq p1 (list (apply 'min xs) (apply 'min ys))
        p2 (list (apply 'max xs) (apply 'max ys)))
  (setq ss (ssget "_C" p1 p2 filter))
  (if (or (null ss) (= (sslength ss) 0))
    (setq ss (ssget "_A"
                    (append filter
                            (list
                              (cons -4 ">=,>=")
                              (cons 10 (list (car p1) (cadr p1) 0.0))
                              (cons -4 "<=,<=")
                              (cons 10 (list (car p2) (cadr p2) 0.0))))))
  )
  ss
)

(defun xy:collect-vlines (selList / result en ed p1 p2 hinfo nearby candidate tol pad)
  ;; 只围绕所选横线做非零高度交叉查询，可取得端点相接的完整竖线。
  (setq result (ssadd) tol *xy-geom-tol* pad (max 1.0 tol))
  (foreach en selList
    (setq ed (entget en) p1 (cdr (assoc 10 ed)) p2 (cdr (assoc 11 ed)))
    (if (and (= (cdr (assoc 0 ed)) "LINE") p1 p2
             (xy:near (cadr p1) (cadr p2) tol))
      (progn
        (setq hinfo (xy:hline-info-ed ed))
        (setq nearby (xy:window-wcs (- (car hinfo) pad) (- (caddr hinfo) pad)
                                    (+ (cadr hinfo) pad) (+ (caddr hinfo) pad)
                                    '((0 . "LINE"))))
        (foreach candidate (xy:ss->list nearby) (ssadd candidate result)))))
  (xy:filter-vertical-lines (xy:ss->list result))
)

(defun xy:collect-texts (selList vlineDataList / result en ed p1 p2 vrec anchor ax ay ymin ymax nearby candidate tol)
  ;; 文字范围由竖线远端决定，完全独立于用户只选的横线范围。
  (setq result (ssadd) tol *xy-geom-tol*)
  (foreach en selList
    (setq ed (entget en) p1 (cdr (assoc 10 ed)) p2 (cdr (assoc 11 ed)))
    (if (and (= (cdr (assoc 0 ed)) "LINE") p1 p2
             (xy:near (cadr p1) (cadr p2) tol))
      (foreach vrec (xy:get-vrecs-for-hline-ed ed vlineDataList)
        (setq anchor (caddr vrec) ax (car anchor) ay (cadr anchor))
        (if (eq (cadr vrec) 'UP)
          (setq ymin ay ymax (+ ay *xy-ray-len*))
          (setq ymin (- ay *xy-ray-len*) ymax ay))
        (setq nearby (xy:window-wcs (- ax *xy-hit-half-width* tol) (- ymin tol)
                                    (+ ax *xy-hit-half-width* tol) (+ ymax tol)
                                    '((0 . "TEXT,MTEXT"))))
        (foreach candidate (xy:ss->list nearby) (ssadd candidate result)))))
  (xy:ss->list result)
)

(defun xy:run-xin (sel / selList vlineDataList ss i ent entData p1 p2 rightPt handle countMap vrecMap vrecs countNum insertPt textStr)
  (setq *xy-last-xin-counts* nil)
  (setq *xy-last-vrec-map* nil)
  (setq *xy-last-vline-data* nil)
  (setq selList (xy:ss->list sel))
  (setq vlineDataList (xy:collect-vlines selList))
  (xy:build-vline-buckets vlineDataList)
  (setq *xy-last-vline-data* vlineDataList)
  (setq ss (ssadd))
  (foreach ent selList
    (setq entData (entget ent))
    (if (and (= (cdr (assoc 0 entData)) "LINE")
             (setq p1 (cdr (assoc 10 entData)))
             (setq p2 (cdr (assoc 11 entData)))
             (xy:near (cadr p1) (cadr p2) *xy-geom-tol*))
      (ssadd ent ss)
    )
  )
  (if (= (sslength ss) 0)
    (progn
      (princ "\r\n选集中没有可供XIN处理的水平直线。")
      nil
    )
    (progn
      (setq i 0)
      (setq countMap '())
      (setq vrecMap '())
      (while (< i (sslength ss))
        (setq ent     (ssname ss i))
        (setq entData (entget ent))
        (setq p1      (cdr (assoc 10 entData)))
        (setq p2      (cdr (assoc 11 entData)))
        (setq rightPt (if (>= (car p1) (car p2)) p1 p2))
        (setq vrecs (xy:get-vrecs-for-hline-ed entData vlineDataList))
        (setq countNum (length vrecs))

        (setq handle   (cdr (assoc 5 entData)))
        (setq countMap (cons (cons handle countNum) countMap))
        (setq vrecMap  (cons (cons handle vrecs) vrecMap))
        (setq insertPt (list (+ (car rightPt) 2) (+ (cadr rightPt) 0.5) 0.0))
        (setq textStr (itoa countNum))

        (entmake
          (list
            (cons 0 "TEXT")
            (cons 10 insertPt)
            (cons 40 3.0)
            (cons 1 textStr)
            (cons 7 "Standard")
            (cons 50 0.0)
          )
        )

        (setq i (1+ i))
      )

      (setq *xy-last-xin-counts* (reverse countMap))
      (setq *xy-last-vrec-map*   (reverse vrecMap))
      (princ (strcat "\r\nXIN处理完成，共处理 " (itoa (sslength ss)) " 条水平直线。"))
      T
    )
  )
);; =========================
;; YUAN 功能
;; =========================

;; vdata = (实体 连接端点 远端点)，保留真实坐标；只接受端点连接，不把穿越当连接。
(defun xy:make-vrec-if-valid-fast (vdata hinfo tol / en nearPt farPt x y farY xmin xmax hy)
  (setq en      (car vdata)
        nearPt  (cadr vdata)
        farPt   (caddr vdata)
        x       (car nearPt)
        y       (cadr nearPt)
        farY    (cadr farPt)
        xmin    (car hinfo)
        xmax    (cadr hinfo)
        hy      (caddr hinfo))
  (if (and (xy:between x xmin xmax *xy-conn-tol*) (xy:near y hy *xy-conn-tol*))
    (cond
      ((< farY (- hy tol)) (list x 'DOWN farPt en))
      ((> farY (+ hy tol)) (list x 'UP farPt en))
      (t nil))
    nil)
)

(defun xy:merge-vrec (a b / side pa pb)
  (setq side (cadr a))
  (setq pa   (caddr a))
  (setq pb   (caddr b))
  (cond
    ((eq side 'DOWN)
     (if (< (cadr pa) (cadr pb)) a b)
    )
    ((eq side 'UP)
     (if (> (cadr pa) (cadr pb)) a b)
    )
    (t a)
  )
)

(defun xy:dedup-vrecs (lst tol / sorted out rec top)
  (setq sorted
        (aa:merge-sort lst
          '(lambda (a b) (< (car a) (car b)))
        )
  )
  (setq out '())
  (foreach rec sorted
    (if (null out)
      (setq out (list rec))
      (progn
        (setq top (car out))
        (if (and (xy:near (car rec) (car top) tol)
                 (eq (cadr rec) (cadr top)))
          (setq out (cons (xy:merge-vrec rec top) (cdr out)))
          (setq out (cons rec out))
        )
      )
    )
  )
  (reverse out)
)

(defun xy:sa->list (val)
  (vlax-safearray->list
    (if (= (type val) 'VARIANT)
      (vlax-variant-value val)
      val))
)

(defun xy:fallback-text-bbox (ed / ip h txt w rot)
  (setq ip  (xy:dxf 10 ed '(0.0 0.0 0.0))
        h   (xy:get-text-height ed)
        txt (xy:get-text-value ed)
        w   (max h (* (strlen txt) h 0.75))
        rot (xy:get-text-rotation ed))
  (if (xy:is-vertical-text-90-p rot (if *xy-ang-tol* *xy-ang-tol* 0.02))
    (list (- (car ip) (/ h 2.0))
          (+ (car ip) (/ h 2.0))
          (- (cadr ip) (/ w 2.0))
          (+ (cadr ip) (/ w 2.0)))
    (list (- (car ip) 2.0)
          (+ (car ip) w 2.0)
          (- (cadr ip) 0.5)
          (+ (cadr ip) h 0.5))
  )
)

(defun xy:get-text-bbox (en / ed obj minPt maxPt ret minLst maxLst out tb ip p1 p2)
  (setq ed (entget en))
  (if (xy:is-text-entity-p en)
    (progn
      (setq obj (vlax-ename->vla-object en))
      (setq ret (vl-catch-all-apply 'vla-getBoundingBox (list obj 'minPt 'maxPt)))
      (setq out
        (if (or (vl-catch-all-error-p ret) (null minPt) (null maxPt))
          (if (and (= (cdr (assoc 0 ed)) "TEXT")
                   (setq tb (textbox ed)))
            (progn
              (setq ip (xy:dxf 10 ed '(0.0 0.0 0.0))
                    p1 (car tb)
                    p2 (cadr tb))
              (list (+ (car ip) (car p1))
                    (+ (car ip) (car p2))
                    (+ (cadr ip) (cadr p1))
                    (+ (cadr ip) (cadr p2)))
            )
            (xy:fallback-text-bbox ed)
          )
          (progn
            (setq minLst (xy:sa->list minPt))
            (setq maxLst (xy:sa->list maxPt))
            (list (car minLst) (car maxLst) (cadr minLst) (cadr maxLst))
          )
        )
      )
      (vlax-release-object obj)
      out
    )
    nil
  )
)

(defun xy:build-text-meta-list (textList / out en ed rot bbox)
  (setq out '())
  (foreach en textList
    (setq ed (entget en))
    (if (xy:is-text-entity-p en)
      (progn
        (setq rot (xy:get-text-rotation ed))
        (if (xy:is-vertical-text-90-p rot *xy-ang-tol*)
          (progn
            (setq bbox (xy:get-text-bbox en))
            (if bbox
              (setq out
                    (cons
                      (list en
                            (car bbox)
                            (cadr bbox)
                            (caddr bbox)
                            (cadddr bbox)
                            rot)
                      out))
            )
          )
        )
      )
    )
  )
  (aa:merge-sort out '(lambda (a b) (< (cadr a) (cadr b))))
)

(defun xy:find-text-for-vrec (textMetaList vrec / side anchor ax ay rectXmin rectXmax rectYmin rectYmax best bestHit bestXDist item en xmin xmax ymin ymax hitY xCenter xDist)
  (setq side   (cadr vrec))
  (setq anchor (caddr vrec))
  (setq ax     (car anchor))
  (setq ay     (cadr anchor))

  (cond
    ((eq side 'DOWN)
     (setq rectXmin (- ax *xy-hit-half-width*))
     (setq rectXmax (+ ax *xy-hit-half-width*))
     (setq rectYmin (- ay *xy-ray-len*))
     (setq rectYmax ay)
     (setq best nil)
     (setq bestHit nil)
     (setq bestXDist nil)

     (foreach item textMetaList
       (setq en   (car item))
       (setq xmin (cadr item))
       (setq xmax (caddr item))
       (setq ymin (cadddr item))
       (setq ymax (nth 4 item))
       (if (and (<= xmin (+ rectXmax *xy-geom-tol*))
                (>= xmax (- rectXmin *xy-geom-tol*))
                (<= ymin (+ rectYmax *xy-geom-tol*))
                (>= ymax (- rectYmin *xy-geom-tol*)))
         (progn
           (setq hitY (min rectYmax ymax))
           (setq xCenter (/ (+ xmin xmax) 2.0))
           (setq xDist (xy:abs (- xCenter ax)))
           (if (or (null best)
                   (> hitY (+ bestHit *xy-geom-tol*))
                   (and (xy:near hitY bestHit *xy-geom-tol*)
                        (< xDist bestXDist)))
             (progn
               (setq best      en)
               (setq bestHit   hitY)
               (setq bestXDist xDist)
             )
           )
         )
       )
     )
     best
    )
    ((eq side 'UP)
     (setq rectXmin (- ax *xy-hit-half-width*))
     (setq rectXmax (+ ax *xy-hit-half-width*))
     (setq rectYmin ay)
     (setq rectYmax (+ ay *xy-ray-len*))
     (setq best nil)
     (setq bestHit nil)
     (setq bestXDist nil)

     (foreach item textMetaList
       (setq en   (car item))
       (setq xmin (cadr item))
       (setq xmax (caddr item))
       (setq ymin (cadddr item))
       (setq ymax (nth 4 item))
       (if (and (<= xmin (+ rectXmax *xy-geom-tol*))
                (>= xmax (- rectXmin *xy-geom-tol*))
                (<= ymin (+ rectYmax *xy-geom-tol*))
                (>= ymax (- rectYmin *xy-geom-tol*)))
         (progn
           (setq hitY (max rectYmin ymin))
           (setq xCenter (/ (+ xmin xmax) 2.0))
           (setq xDist (xy:abs (- xCenter ax)))
           (if (or (null best)
                   (< hitY (- bestHit *xy-geom-tol*))
                   (and (xy:near hitY bestHit *xy-geom-tol*)
                        (< xDist bestXDist)))
             (progn
               (setq best      en)
               (setq bestHit   hitY)
               (setq bestXDist xDist)
             )
           )
         )
       )
     )
     best
    )
    (t nil)
  )
)
(defun xy:copy-text-horizontal (srcEn insPt / ed data link)
  (setq ed (entget srcEn))
  (setq data
    (list
      '(0 . "TEXT")
      (cons 8  (xy:dxf 8 ed "0"))
      (cons 10 insPt)
      (cons 40 (xy:get-text-height ed))
      (cons 1  (xy:get-text-value ed))
      (cons 7  (xy:get-text-style ed))
      (cons 50 0.0)
      (cons 72 0)
      (cons 73 0)
      (cons 210 (xy:dxf 210 ed '(0.0 0.0 1.0)))
    )
  )

  (if (assoc 41 ed)
    (setq data (append data (list (assoc 41 ed))))
  )
  (if (assoc 51 ed)
    (setq data (append data (list (assoc 51 ed))))
  )
  (if (assoc 39 ed)
    (setq data (append data (list (assoc 39 ed))))
  )
  (if (assoc 62 ed)
    (setq data (append data (list (assoc 62 ed))))
  )
  (if (assoc 420 ed)
    (setq data (append data (list (assoc 420 ed))))
  )
  ;; 联动：继承源文字的 AA_LINK 身份（UID），供 SX1 刷新
  (if (setq link (aa:link-xdata srcEn))
    (setq data (append data (list link)))
  )

  (entmakex data)
)
(defun xy:process-one-hline (ed vlineDataList textMetaList / hinfo vrecs vrec item found txt rightPt startPt idx newCnt missCnt allVCnt tail cand scan rectXmin rectXmax)
  (setq hinfo (xy:hline-info-ed ed))
  (setq vrecs (xy:get-vrecs-for-hline-ed ed vlineDataList))
  (setq allVCnt (length vrecs))
  (setq found   '())
  (setq missCnt 0)

  ;; 滑动窗口按远端 X 升序查询；最终输出仍按连接端 X 排列，兼容芯线倾斜或交叉。
  (setq tail textMetaList)
  (foreach vrec (aa:merge-sort vrecs
                  '(lambda (a b) (< (car (caddr a)) (car (caddr b)))))
    (setq rectXmin (- (car (caddr vrec)) *xy-hit-half-width*))
    (setq rectXmax (+ (car (caddr vrec)) *xy-hit-half-width*))
    (while (and tail (< (caddr (car tail)) (- rectXmin *xy-geom-tol*)))
      (setq tail (cdr tail)))
    (setq cand '())
    (setq scan tail)
    (while (and scan (<= (cadr (car scan)) (+ rectXmax *xy-geom-tol*)))
      (setq cand (cons (car scan) cand))
      (setq scan (cdr scan)))
    (setq txt (xy:find-text-for-vrec (reverse cand) vrec))
    (if txt
      (setq found (cons (list (car vrec) txt) found))
      (setq missCnt (1+ missCnt))
    )
  )

  (setq found
        (aa:merge-sort found
          '(lambda (a b) (< (car a) (car b)))
        )
  )

  (setq rightPt (cadddr hinfo))
  (setq startPt
        (list (+ (car rightPt) *xy-out-offx*)
              (+ (cadr rightPt) *xy-out-offy*)
              (if (caddr rightPt) (caddr rightPt) 0.0))
  )

  (setq idx 0)
  (setq newCnt 0)

  (foreach item found
    (if (xy:copy-text-horizontal
      (cadr item)
      (list (+ (car startPt) (* idx *xy-step-x*))
            (cadr startPt)
            (caddr startPt))
    )
      (setq newCnt (1+ newCnt))
      (setq missCnt (1+ missCnt)))
    (setq idx    (1+ idx))
  )

  (list newCnt missCnt allVCnt)
)

(defun xy:run-yuan (sel / selList vlineDataList textList textMetaList hLines hitem en ed p1 p2 res totalH totalNew totalMiss totalV handle warnCnt hY warnYText)
  (if (null sel)
    (progn
      (princ "\r\n未选择对象，YUAN部分结束。")
      nil
    )
    (progn
      (setq selList (xy:ss->list sel))
      (if *xy-last-vline-data*
        (setq vlineDataList *xy-last-vline-data*)
        (progn
          (setq vlineDataList (xy:collect-vlines selList))
          (xy:build-vline-buckets vlineDataList)
        )
      )
      (setq textList (xy:collect-texts selList vlineDataList))
      (setq textMetaList (xy:build-text-meta-list textList))

      (setq hLines '())
      (foreach en selList
        (setq ed (entget en))
        (if (and (= (cdr (assoc 0 ed)) "LINE")
                 (setq p1 (cdr (assoc 10 ed)))
                 (setq p2 (cdr (assoc 11 ed)))
                 (xy:near (cadr p1) (cadr p2) *xy-geom-tol*))
          (setq hLines (cons (list en ed) hLines))
        )
      )
      (setq hLines (reverse hLines))

      (if (null hLines)
        (progn
          (princ "\r\n选集中没有可处理的水平 LINE，YUAN部分结束。")
          nil
        )
        (progn
          (setq totalH    0)
          (setq totalNew  0)
          (setq totalMiss 0)
          (setq totalV    0)
          (setq warnCnt   0)
          (setq warnYText "")

          (foreach hitem hLines
            (setq en (car hitem))
            (setq ed (cadr hitem))
            (setq res (xy:process-one-hline ed vlineDataList textMetaList))
            (setq totalH    (1+ totalH))
            (setq totalNew  (+ totalNew  (car res)))
            (setq totalMiss (+ totalMiss (cadr res)))
            (setq totalV    (+ totalV    (caddr res)))

            (setq handle  (cdr (assoc 5 ed)))
            (setq hY      (caddr (assoc 10 ed)))

            (princ
              (strcat
                "\r\n水平线 Handle="
                handle
                " | 竖线数="
                (itoa (caddr res))
                " | 成功="
                (itoa (car res))
                " | 未找到文字="
                (itoa (cadr res))
              )
            )

            (if (/= (car res) (caddr res))
              (progn
                (xy:mark-abnormal-hline en)
                (setq warnCnt (1+ warnCnt))
                (setq warnYText
                      (if (= warnYText "")
                        (rtos hY 2 4)
                        (strcat warnYText ", " (rtos hY 2 4))))
                (princ
                  (strcat
                    "\r\n警告: 水平线 Handle="
                    handle
                    "，Y="
                    (rtos hY 2 4)
                    " 找到文字="
                    (itoa (car res))
                    "，竖线数="
                    (itoa (caddr res))
                    "。异常请检查。"
                  )
                )
              )
            )
          )

          (princ
            (strcat
              "\r\n--- YUAN 执行完成 ---"
              "\r\n处理水平线数量: " (itoa totalH)
              "\r\n识别竖线总数: "   (itoa totalV)
              "\r\n新建文字总数: "   (itoa totalNew)
              "\r\n未找到文字总数: " (itoa totalMiss)
            )
          )
          (if (> warnCnt 0)
            (princ
              (strcat
                "\r\n注意: 发现 "
                (itoa warnCnt)
                " 条水平线的找到文字数与竖线数不一致，请检查对应水平线。"
                "\r\n异常水平线Y坐标汇总: "
                warnYText
              )
            )
          )
          T
        )
      )
    )
  )
  (redraw)   ; 标记循环内不再逐个 entupd，改为统一重绘
)

;; =========================
;; 绿色水平直线筛选逻辑
;; =========================
(defun xy:is-green-ed-p (ed / tc aci r g b layer-ed)
  (setq tc  (cdr (assoc 420 ed))
        aci (cdr (assoc 62 ed)))
  (cond
    (tc
     (setq r (/ tc 65536)
           g (/ (- tc (* r 65536)) 256)
           b (- tc (* r 65536) (* g 256)))
     (and (> g 150) (< r 100) (< b 100)))
    ((and aci (/= aci 0) (/= aci 256))
     (= (abs aci) 3))
    (T
     (setq layer-ed (tblsearch "LAYER" (cdr (assoc 8 ed))))
     (cond
       ((null layer-ed) nil)
       ((setq tc (cdr (assoc 420 layer-ed)))
        (setq r (/ tc 65536)
              g (/ (- tc (* r 65536)) 256)
              b (- tc (* r 65536) (* g 256)))
        (and (> g 150) (< r 100) (< b 100)))
       ((assoc 62 layer-ed)
        (= (abs (cdr (assoc 62 layer-ed))) 3))
       (T nil)
     ))
  )
)

(defun xy:is-green-hline-p (en / ed p1 p2)
  (and en
       (setq ed (entget en))
       (= (cdr (assoc 0 ed)) "LINE")
       (setq p1 (cdr (assoc 10 ed)))
       (setq p2 (cdr (assoc 11 ed)))
       (xy:near (cadr p1) (cadr p2) *xy-geom-tol*)
       (not (xy:near (car p1) (car p2) *xy-geom-tol*))
       (xy:is-green-ed-p ed))
)

(defun xy:filter-green-hlines (ss / new-ss i en)
  (setq new-ss (ssadd))
  (if ss
    (progn
      (setq i 0)
      (while (< i (sslength ss))
        (setq en (ssname ss i))
        (if (xy:is-green-hline-p en)
          (ssadd en new-ss)
        )
        (setq i (1+ i))
      )
    )
  )
  new-ss
)

;; =========================
;; 主命令：XY
;; =========================
(defun c:XY (/ *error* aa:tag aa:doc aa:undo-open aa:old-cmdecho sel)
  (aa:cmd-begin "XY")
  (princ "\r\n选择需要统计的水平直线，XY自动查找关联竖线和原理号: ")
  (setq sel (ssget))
  (if (null sel)
    (princ "\r\n未选择对象，XY命令结束。")
    (progn
      (princ "\r\n开始执行 XY：先运行 XIN，再运行 YUAN。")
      (xy:run-xin sel)
      (xy:run-yuan sel)
      (princ "\r\nXY 执行结束。")
    )
  )
  (aa:cmd-end)
)

;; =======================================================================================
;; 命令: XYG
;; 功能: 一次框选，自动提取绿色直线执行 XY 统计，并提取大字与电缆文字执行 GTX 分类汇总。
;; =======================================================================================

(defun xyg:find-prefix-text (ss / min-x best-ent i en ed typ h pt x)
  (setq min-x nil
        best-ent nil
        i 0)
  (if ss
    (while (< i (sslength ss))
      (setq en (ssname ss i)
            ed (entget en)
            typ (cdr (assoc 0 ed)))
      (if (member typ '("TEXT" "MTEXT"))
        (progn
          (setq h (cdr (assoc 40 ed)))
          (if (and h (>= h 79.9))
            (progn
              (setq pt (cdr (assoc 10 ed))
                    x  (car pt))
              (if (or (null min-x) (< x min-x))
                (setq min-x x
                      best-ent en))
            )
          )
        )
      )
      (setq i (1+ i))
    )
  )
  best-ent
)

(defun xyg:box-hit-p (box xmin xmax ymin ymax)
  ;; 包围盒相交判定：box 前四项为 (xmin xmax ymin ymax)，只要与搜索矩形有一点触碰重叠就算命中
  (and (<= (car box) xmax)
       (>= (cadr box) xmin)
       (<= (caddr box) ymax)
       (>= (cadddr box) ymin))
)

(defun xyg:text-record (en order mode / ed typ h pt bbox cx str)
  ;; 一次性计算文字查询记录：(原序号 图元 xmin xmax ymin ymax 中心X 纯文本)
  ;; BOX   : 选区小字，排除字高 >= 80 的大字；取精确包围盒，失败时按插入点扩展
  ;; POINT : XY 新生成文字，按插入点检索，不限字高
  ;; 非文字、被排除或纯文本为空时返回 nil
  (setq ed  (entget en)
        typ (cdr (assoc 0 ed)))
  (if (member typ '("TEXT" "MTEXT"))
    (progn
      (setq h  (cdr (assoc 40 ed))
            pt (cdr (assoc 10 ed)))
      (if (or (eq mode 'POINT) (and h (< h 79.9)))
        (progn
          (if (eq mode 'POINT)
            (setq bbox (list (car pt) (car pt) (cadr pt) (cadr pt))
                  cx   (car pt))
            (progn
              (setq bbox (xy:get-text-bbox en))
              (if bbox
                (setq cx (/ (+ (car bbox) (cadr bbox)) 2.0))
                ;; 若获取包围盒失败，保底基于插入点扩展判定
                (setq cx   (car pt)
                      bbox (list (- (car pt) 2.0) (+ (car pt) 2.0)
                                 (- (cadr pt) 0.5) (+ (cadr pt) h)))
              )
            )
          )
          (setq str (aa:ysdl-get-plain-text ed))
          (if (/= (vl-string-trim " \t\r\n" str) "")
            (list order en (car bbox) (cadr bbox) (caddr bbox) (cadddr bbox) cx str)
          )
        )
      )
    )
  )
)

(defun xyg:build-text-index (entities mode / records order en rec)
  ;; 命令内一次性采集文字记录并建立包围盒树，每个文字的包围盒只计算一次
  (setq records '()
        order   0)
  (foreach en entities
    (if (setq rec (xyg:text-record en order mode))
      (setq records (cons rec records))
    )
    (setq order (1+ order))
  )
  (setq records (aa:merge-sort records '(lambda (a b) (< (nth 4 a) (nth 4 b)))))
  (xyg:index-tree records (length records))
)

(defun xyg:index-tree (records n / half i left right item)
  ;; 平衡包围盒树：节点 = (xmin xmax ymin ymax 左子树 右子树 叶记录)，节点范围覆盖整棵子树
  (cond
    ((= n 0) nil)
    ((= n 1)
     (setq item (car records))
     (list (nth 2 item) (nth 3 item) (nth 4 item) (nth 5 item) nil nil item))
    (T
     (setq half (/ n 2)
           i    0
           left '())
     (while (< i half)
       (setq left    (cons (car records) left)
             records (cdr records)
             i       (1+ i))
     )
     (setq left  (xyg:index-tree (reverse left) half)
           right (xyg:index-tree records (- n half)))
     (list (min (car left) (car right)) (max (cadr left) (cadr right))
           (min (caddr left) (caddr right)) (max (cadddr left) (cadddr right))
           left right nil))
  )
)

(defun xyg:index-hits (tree xmin xmax ymin ymax)
  (if (and tree (xyg:box-hit-p tree xmin xmax ymin ymax))
    (if (nth 6 tree)
      (list (nth 6 tree))
      (append (xyg:index-hits (nth 4 tree) xmin xmax ymin ymax)
              (xyg:index-hits (nth 5 tree) xmin xmax ymin ymax))
    )
  )
)

(defun xyg:query-text-index (tree xmin xmax ymin ymax)
  ;; 命中记录恢复原序号顺序，保证后续 cons 与排序结果和逐个扫描完全一致
  (aa:merge-sort (xyg:index-hits tree xmin xmax ymin ymax)
                 '(lambda (a b) (< (car a) (car b))))
)

(defun xyg:find-rect-texts (rightPt rect-index / rx ry xmin xmax ymin ymax res i en nearby record)
  (setq rx   (car rightPt)
        ry   (cadr rightPt)
        xmin (- rx 155.0)
        xmax (+ rx 0.5)
        ymin (- ry 0.5)
        ymax (+ ry 3.5)
        res  '())
  ;; 选区文字：查询命令内预建的包围盒树，不再逐个扫描整个框选集
  (foreach record (xyg:query-text-index rect-index xmin xmax ymin ymax)
    (setq res (cons (list (cadr record) (nth 6 record) (nth 7 record)) res))
  )
  ;; 若在框选集合中未找到足够的3个文字，自动在当前图面对应矩形区域内补充查找，彻底杜绝框选不全导致的漏选
  ;; 补查结果可能包含 XY 新生成的文字，因此保持查询时实时读取
  (if (< (length res) 3)
    (progn
      (setq nearby (xy:window-wcs xmin ymin xmax ymax '((0 . "TEXT,MTEXT"))))
      (if nearby
        (progn
          (setq i 0)
          (while (< i (sslength nearby))
            (setq en (ssname nearby i))
            (if (null (assoc en res))
              (progn
                (setq record (xyg:text-record en i 'BOX))
                (if (and record (xyg:box-hit-p (cddr record) xmin xmax ymin ymax))
                  (setq res (cons (list en (nth 6 record) (nth 7 record)) res))
                )
              )
            )
            (setq i (1+ i))
          )
        )
      )
    )
  )
  ;; 按 X 坐标从左到右排序
  (setq res (aa:merge-sort res '(lambda (a b) (< (cadr a) (cadr b)))))
  ;; 从右侧顶点往左看最多只有 3 个文字，多于 3 个时只保留最靠近右侧的最后 3 个
  (while (> (length res) 3)
    (setq res (cdr res))
  )
  (setq *xyg-rect-src* (mapcar 'aa:link-xdata (mapcar 'car res)))
  (mapcar 'caddr res)
)

(defun xyg:dedup-hlines (lines tol / sorted out top ed edt p1 p2 p1t p2t eda edb p1a p2a p1b p2b ya yb xa xb en)
  (setq sorted
    (aa:merge-sort lines
      '(lambda (ea eb / eda edb p1a p2a p1b p2b ya yb xa xb)
         (setq eda (entget ea)
               edb (entget eb)
               p1a (cdr (assoc 10 eda))
               p2a (cdr (assoc 11 eda))
               p1b (cdr (assoc 10 edb))
               p2b (cdr (assoc 11 edb))
               ya  (cadr p1a)
               yb  (cadr p1b)
               xa  (min (car p1a) (car p2a))
               xb  (min (car p1b) (car p2b)))
         (if (<= (abs (- ya yb)) tol)
           (< xa xb)
           (> ya yb)))))
  (setq out '())
  (foreach en sorted
    (if (null out)
      (setq out (list en))
      (progn
        (setq top (car out)
              ed  (entget en)
              edt (entget top)
              p1  (cdr (assoc 10 ed))
              p2  (cdr (assoc 11 ed))
              p1t (cdr (assoc 10 edt))
              p2t (cdr (assoc 11 edt)))
        (if (and (<= (abs (- (cadr p1) (cadr p1t))) tol)
                 (<= (abs (- (min (car p1) (car p2)) (min (car p1t) (car p2t)))) tol)
                 (<= (abs (- (max (car p1) (car p2)) (max (car p1t) (car p2t)))) tol))
          nil
          (setq out (cons en out))
        )
      )
    )
  )
  (reverse out)
)

(defun xyg:sort-lines-desc (lines / keyed)
  ;; 按 Y 坐标从大到小（从上到下）排序；每条线只 entget 一次，比较结果与逐次读取完全一致
  (setq keyed
    (mapcar '(lambda (en) (list (caddr (assoc 10 (entget en))) en)) lines))
  (mapcar 'cadr (aa:merge-sort keyed '(lambda (a b) (> (car a) (car b)))))
)

(defun xyg:line-geo-list (sorted-lines / en ed p1 p2 out)
  ;; 每条线只读取一次几何：(图元 Y 左端X)，顺序与 sorted-lines（Y 非增）一致
  (setq out '())
  (foreach en sorted-lines
    (setq ed  (entget en)
          p1  (cdr (assoc 10 ed))
          p2  (cdr (assoc 11 ed))
          out (cons (list en (cadr p1) (min (car p1) (car p2))) out))
  )
  (reverse out)
)

(defun xyg:next-line-min-x (line-en rx ry line-geo / best rest item other-y other-min-x)
  ;; 查找同一水平线上位于本线右侧的最近邻线左端X（若有），作为本线文字的硬性右边界
  ;; line-geo 按 Y 非增排列：一旦 Y 已低于本线 0.5 以上，后续各线均不可能命中，提前结束
  (setq best nil
        rest line-geo)
  (while rest
    (setq item    (car rest)
          rest    (cdr rest)
          other-y (cadr item))
    (if (and (< other-y ry) (> (- ry other-y) 0.5))
      (setq rest nil)
      (if (/= (car item) line-en)
        (progn
          (setq other-min-x (caddr item))
          (if (and (<= (abs (- other-y ry)) 0.5)
                   (> other-min-x rx))
            (if (or (null best) (< other-min-x best))
              (setq best other-min-x)
            )
          )
        )
      )
    )
  )
  best
)

(defun xyg:find-right-new-texts (rightPt new-index expected-count max-x / rx ry limit-x res x y record prev-x cand keep-cnt trimmed idx cand-num gap-ok)
  (setq rx      (car rightPt)
        ry      (cadr rightPt)
        limit-x (if max-x max-x (+ rx 350.0)))
  (if (and expected-count (> expected-count 0))
    (setq limit-x (min limit-x (+ rx 10.0 (* 30.0 expected-count) 20.0)))
  )
  (setq res '())
  ;; Y 坐标在 ry+0.5 附近，X 坐标大于 rx 且不超过 limit-x
  ;; 先按放宽的 Y 带查询插入点索引，再执行与逐个扫描相同的精确判定
  (foreach record (xyg:query-text-index new-index (+ rx 0.5) limit-x (- ry 1.0) (+ ry 2.0))
    (setq x (nth 6 record)
          y (nth 4 record))
    (if (and (> x (+ rx 0.5))
             (<= x limit-x)
             (<= (abs (- y (+ ry 0.5))) 0.6))
      (setq res (cons (list (cadr record) x (nth 7 record)) res))
    )
  )
  ;; 按 X 坐标从左到右排序：芯数数字在前，原理号在后
  (setq res (aa:merge-sort res '(lambda (a b) (< (cadr a) (cadr b)))))

  ;; 间距连续性截断：若相邻文字间距突增（> 50.0），说明已越界进入下一列/设备，立即停止
  (if res
    (progn
      (setq prev-x  rx
            trimmed '()
            gap-ok  T)
      (while (and gap-ok res)
        (setq cand (car res))
        (if (null trimmed)
          (setq trimmed (cons cand trimmed)
                prev-x  (cadr cand)
                res     (cdr res))
          (if (<= (- (cadr cand) prev-x) 50.0)
            (setq trimmed (cons cand trimmed)
                  prev-x  (cadr cand)
                  res     (cdr res))
            (setq gap-ok nil)
          )
        )
      )
      (setq res (reverse trimmed))
    )
  )

  ;; 芯数上限截断：首个文字为芯数数字 N，整组最多只包含 1 (芯数) + N (原理号)
  (if res
    (progn
      (if (or (null expected-count) (<= expected-count 0))
        (progn
          (setq cand-num (atoi (caddr (car res))))
          (if (> cand-num 0)
            (setq expected-count cand-num)
          )
        )
      )
      (if (and expected-count (> expected-count 0))
        (progn
          (setq keep-cnt (1+ expected-count)
                trimmed  '()
                idx      0)
          (while (and (< idx keep-cnt) res)
            (setq trimmed (cons (car res) trimmed)
                  res     (cdr res)
                  idx     (1+ idx))
          )
          (setq res (reverse trimmed))
        )
      )
    )
  )

  (setq *xyg-right-src* (mapcar 'aa:link-xdata (mapcar 'car res)))
  (mapcar 'caddr res)
)

(defun xyg:make-linked-text (pt content h sty src / data)
  ;; 生成汇总文字；src 为源文字的 AA_LINK XData（-3 组）时原样继承，供 SX1 刷新
  (setq data
    (list '(0 . "TEXT") (cons 10 pt) (cons 40 h) (cons 1 content) (cons 7 sty) '(41 . 0.7) '(62 . 7)))
  (if src
    (setq data (append data (list src)))
  )
  (entmake data)
)

(defun xyg:output-gtx-matrix (categorized-groups prefix-item pt text-style / start-x current-y text-height line-height col-width all-strings output-box cat-item sorted-groups group current-x text-item)
  (setq text-height 3.0
        start-x     (car pt)
        current-y   (cadr pt)
        col-width   50.0
        line-height 5.0
        all-strings (list (car prefix-item)))

  (foreach cat-item categorized-groups
    (foreach group (cadr cat-item)
      (foreach text-item group
        (setq all-strings (cons (car text-item) all-strings))
      )
    )
  )

  (foreach text-item all-strings
    (setq output-box (textbox (list '(0 . "TEXT") (cons 1 text-item)
      (cons 40 text-height) (cons 7 text-style) '(41 . 0.7))))
    (if output-box
      (setq col-width (max col-width
        (+ (* 2.0 text-height) (- (caadr output-box) (caar output-box)))))))

  ;; 每组为 ((文字 . AA_LINK) ...)，按首项文字（电缆编号）自然排序
  (foreach cat-item categorized-groups
    (setq sorted-groups
      (aa:merge-sort
        (cadr cat-item)
        '(lambda (itemA itemB)
           (aa:gtx-natural-less (car (car itemA)) (car (car itemB)))))
    )
    (foreach group sorted-groups
      (setq current-x start-x)
      (xyg:make-linked-text (list current-x current-y (caddr pt)) (car prefix-item) text-height text-style (cdr prefix-item))
      (setq current-x (+ current-x col-width))
      (foreach text-item group
        (xyg:make-linked-text (list current-x current-y (caddr pt)) (car text-item) text-height text-style (cdr text-item))
        (setq current-x (+ current-x col-width))
      )
      (setq current-y (- current-y line-height))
    )
    (setq current-y (- current-y (* 0.5 line-height)))
  )
)

(defun c:XYG (/ *error* aa:tag aa:doc aa:undo-open aa:old-cmdecho
               all-ss raw-green-lines-ss green-lines-list green-lines-ss sorted-lines
               line-orig-pts
               prefix-ent prefix-str last-ent xy-new-texts cur
               lines-group-data i line-en ed p1 p2 rightPt rx ry
               line-handle expected-count next-line-min-x limit-x
               left-texts right-texts full-texts pt text-style categorized-groups
               left-text temp-text last-hyphen-pos category found-category
               eda p1a p2a left-src right-src prefix-link rect-index new-index line-geo)

  (aa:cmd-begin "XYG")
  (princ "\r\n[XYG] 请框选包含大字、绿色直线及文字的对象区域: ")
  (setq all-ss (ssget))
  (if (null all-ss)
    (progn
      (princ "\r\n[XYG] 未选择对象，XYG 命令结束。")
      (aa:cmd-end)
    )
    (progn
      ;; 1. 自动识别绿色水平直线并进行几何去重
      (setq raw-green-lines-ss (xy:filter-green-hlines all-ss))
      (setq green-lines-list
        (if raw-green-lines-ss
          (xyg:dedup-hlines (xy:ss->list raw-green-lines-ss) 0.5)
          nil))
      (if (or (null green-lines-list) (= (length green-lines-list) 0))
        (progn
          (princ "\r\n[XYG] 选区中未找到颜色为绿色的水平直线，XYG 命令结束。")
          (aa:cmd-end)
        )
        (progn
          (setq green-lines-ss (ssadd))
          (foreach line-en green-lines-list (ssadd line-en green-lines-ss))
          ;; 缓存每条绿色直线原始右端点，防止后续 XY 异常标记延伸直线导致端点偏移
          (setq line-orig-pts
            (mapcar
              '(lambda (en / eda p1a p2a)
                 (setq eda (entget en)
                       p1a (cdr (assoc 10 eda))
                       p2a (cdr (assoc 11 eda)))
                 (cons en (if (>= (car p1a) (car p2a)) p1a p2a)))
              green-lines-list))
          (princ (strcat "\r\n[XYG] 成功识别并去重得到 " (itoa (length green-lines-list)) " 条绿色水平直线。"))

          ;; 2. 识别前缀大字（最左且字高 >= 80）
          (setq prefix-ent (xyg:find-prefix-text all-ss))
          (if prefix-ent
            (setq prefix-str (aa:ysdl-get-plain-text (entget prefix-ent)))
            (progn
              (princ "\r\n[XYG] 选区中未自动检测到字高>=80的大字。")
              (setq prefix-ent (aa:gtx-select-prefix-text))
              (if prefix-ent
                (setq prefix-str (aa:ysdl-get-plain-text (entget prefix-ent)))
                (setq prefix-str nil)
              )
            )
          )

          (if (or (null prefix-str) (= prefix-str ""))
            (progn
              (princ "\r\n[XYG] 未能取得有效的前缀文字，XYG 命令结束。")
              (aa:cmd-end)
            )
            (progn
              (princ (strcat "\r\n[XYG] 采用前缀文字: [" prefix-str "]"))
              (setq prefix-link (aa:link-xdata prefix-ent))

              ;; 3. 执行 XY 命令（记录生成前图元游标）
              (setq last-ent (entlast))
              (princ "\r\n[XYG] 正在执行 XY（统计芯数与提取原理号）...")
              (xy:run-xin green-lines-ss)
              (xy:run-yuan green-lines-ss)

              ;; 收集 XY 新生成的文字
              (setq cur last-ent
                    xy-new-texts '())
              (while (setq cur (entnext cur))
                (if (member (cdr (assoc 0 (entget cur))) '("TEXT" "MTEXT"))
                  (setq xy-new-texts (cons cur xy-new-texts))
                )
              )
              (setq xy-new-texts (reverse xy-new-texts))

              ;; 4. 收集每条绿色直线的数据（从上到下排序）
              ;; 按 Y 坐标从大到小（从上到下）排序
              (setq sorted-lines (xyg:sort-lines-desc green-lines-list))

              ;; 命令内一次性建立文字索引与直线几何缓存（在 XY 完成后建立，与逐线查询时的图面状态一致）
              ;; 选区小字按精确包围盒建树，XY 新文字按插入点建树；均为本命令局部变量，不跨命令保留
              (setq rect-index (xyg:build-text-index (xy:ss->list all-ss) 'BOX)
                    new-index  (xyg:build-text-index xy-new-texts 'POINT)
                    line-geo   (xyg:line-geo-list sorted-lines))

              (setq lines-group-data '()
                    i 0)
              (foreach line-en sorted-lines
                (setq rightPt (cdr (assoc line-en line-orig-pts)))
                (if (null rightPt)
                  (setq ed (entget line-en)
                        p1 (cdr (assoc 10 ed))
                        p2 (cdr (assoc 11 ed))
                        rightPt (if (>= (car p1) (car p2)) p1 p2))
                )
                (setq rx (car rightPt)
                      ry (cadr rightPt)
                      ed (entget line-en)
                      line-handle (cdr (assoc 5 ed))
                      expected-count (if *xy-last-xin-counts* (cdr (assoc line-handle *xy-last-xin-counts*)) nil))

                ;; 查找同一水平线上位于本线右侧的最近邻线（若有），作为本线文字的硬性右边界
                (setq next-line-min-x (xyg:next-line-min-x line-en rx ry line-geo))
                (setq limit-x (if next-line-min-x (- next-line-min-x 5.0) (+ rx 350.0)))

                ;; 提取右上矩形文字（从左到右，严格最多3个）
                (setq left-texts (xyg:find-rect-texts rightPt rect-index)
                      left-src   *xyg-rect-src*)
                (if (/= (length left-texts) 3)
                  (princ
                    (strcat "\r\n[XYG] 提示: 直线 Y="
                            (rtos ry 2 2)
                            " 右上方找到 " (itoa (length left-texts))
                            " 个文字（期望为3个）。"))
                )

                ;; 提取右侧新生成文字（芯数数字在前，原理号在后，多重限幅防串列重复）
                (setq right-texts (xyg:find-right-new-texts rightPt new-index expected-count limit-x)
                      right-src   *xyg-right-src*)

                ;; 组装成整行文字列表
                ;; 每项为 (文字 . 源文字 AA_LINK)，无联动身份时为 nil
                (setq full-texts (append (mapcar 'cons left-texts left-src)
                                         (mapcar 'cons right-texts right-src)))
                (if full-texts
                  (setq lines-group-data (cons full-texts lines-group-data))
                )
                (setq i (1+ i))
              )
              (setq lines-group-data (reverse lines-group-data))

              (if (null lines-group-data)
                (progn
                  (princ "\r\n[XYG] 未能汇总到有效的电缆文字。")
                  (aa:cmd-end)
                )
                (progn
                  ;; 5. GTX 分类归纳
                  (setq categorized-groups '())
                  (foreach full-texts lines-group-data
                    (if (>= (length full-texts) 1)
                      (progn
                        (setq left-text (car full-texts)
                              temp-text (aa:gtx-key (car left-text)))
                        (setq last-hyphen-pos (aa:gtx-find-last-char "-" temp-text))
                        (if last-hyphen-pos
                          (setq category (substr temp-text 1 last-hyphen-pos))
                          (setq category temp-text)
                        )
                        (setq found-category (assoc category categorized-groups))
                        (if found-category
                          (setq categorized-groups
                            (subst
                              (list category (cons full-texts (cadr found-category)))
                              found-category
                              categorized-groups))
                          (setq categorized-groups
                            (cons (list category (list full-texts)) categorized-groups))
                        )
                      )
                    )
                  )

                  (setq categorized-groups
                    (aa:merge-sort categorized-groups
                      '(lambda (a b) (aa:gtx-natural-less (car a) (car b)))))

                  ;; 6. 提示指定插入点并输出矩阵
                  (setq text-style (if (tblsearch "STYLE" "HZ") "HZ" (getvar "TEXTSTYLE")))
                  (setq pt (getpoint "\r\n[XYG] 请指定汇总结果的插入点: "))
                  (if pt
                    (progn
                      (setq pt (trans pt 1 0))
                      (xyg:output-gtx-matrix categorized-groups (cons prefix-str prefix-link) pt text-style)
                      (princ (strcat "\r\n[XYG] 执行完成：成功处理 " (itoa (length lines-group-data)) " 组电缆并生成汇总表格。"))
                    )
                    (princ "\r\n[XYG] 用户取消指定插入点，汇总表格未输出。")
                  )
                  (aa:cmd-end)
                )
              )
            )
          )
        )
      )
    )
  )
)

;;; =======================================================================================
;;; 文字联动（AA_LINK）
;;; 原件文字经 SX 标记后带 XData：(-3 ("AA_LINK" (1000 . 图纸ID) (1000 . 原件句柄)))。
;;; 原生 COPY、GTY 副本、跨图粘贴自动保留该 XData；XY / XYG 新建文字时显式继承。
;;; 图纸 ID 与句柄都等于自身的是原件，其余同 UID 文字均为副本，SX1 按原件内容单向刷新。
;;; 跨图：SX1 在已保存的图旁写出 <图名>.aalink.txt（UTF-8，每行“P/M<TAB>UID<TAB>内容”），
;;; 总图执行 SX2 读取文件夹内全部值文件，按 UID 刷新原件不在本图的副本。
;;; =======================================================================================
(defun aa:link-xdata (en)
  ;; 取文字的 AA_LINK 扩展数据（整个 -3 组）；无记录返回 nil
  (if en (assoc -3 (entget en '("AA_LINK"))))
)

(defun aa:link-info (ed / app)
  ;; 返回 (图纸ID 原件句柄)；无记录或格式不符返回 nil
  (setq app (cdr (assoc "AA_LINK" (cdr (assoc -3 ed)))))
  (if (= (length app) 2)
    (mapcar 'cdr app)
  )
)

(defun aa:link-root-p (info dwg-id h)
  (and info dwg-id h (= (car info) dwg-id) (= (cadr info) h))
)

(defun aa:link-dwg-id (create / rec id en)
  ;; 本图联动 ID 存于命名对象字典 AA_LINK_DWG；create 为 T 时缺失则新建
  (setq rec (dictsearch (namedobjdict) "AA_LINK_DWG"))
  (cond
    (rec (cdr (assoc 1 rec)))
    (create
     (setq id (strcat (rtos (getvar "CDATE") 2 8) "-" (substr (getvar "DWGNAME") 1 60)))
     (if (setq en (entmakex (list '(0 . "XRECORD") '(100 . "AcDbXrecord") (cons 1 id))))
       (progn
         (dictadd (namedobjdict) "AA_LINK_DWG" en)
         id
       )
     )
    )
    (T nil)
  )
)

(defun aa:link-text-for (ed src-ed / str)
  ;; 目标为 TEXT 取原件纯文本；目标与原件同为 MTEXT 时保留格式码；含组码 3 的超长 MTEXT 不处理
  (cond
    ((assoc 3 ed) nil)
    ((and (= (cdr (assoc 0 ed)) "MTEXT") (= (cdr (assoc 0 src-ed)) "MTEXT"))
     (setq str (aa:ysdl-get-raw-text src-ed))
     (if (and str (<= (strlen str) 250)) str)
    )
    (T (aa:ysdl-get-plain-text src-ed))
  )
)

(defun aa:link-text-from-rec (ed rec)
  ;; 跨图版 aa:link-text-for：rec 为值文件记录 (UID 纯文本 MTEXT原文)，原件不是 MTEXT 时原文为 nil
  (cond
    ((assoc 3 ed) nil)
    ((and (= (cdr (assoc 0 ed)) "MTEXT") (caddr rec))
     (if (<= (strlen (caddr rec)) 250) (caddr rec)))
    (T (cadr rec))
  )
)

(defun aa:link-uid< (a b)
  ;; 按 UID（首元素）升序，供 aa:merge-sort 使用
  (< (car a) (car b))
)

(defun aa:link-line-ok-p (s)
  ;; 值文件一行一条记录，含换行符的内容不写出
  (and (= (type s) 'STR) (not (vl-string-search "\n" s)) (not (vl-string-search "\r" s)))
)

(defun aa:link-file-path ()
  ;; 本图值文件：与 dwg 同目录同名，扩展名 .aalink.txt；从未保存的新图返回 nil
  (if (= (getvar "DWGTITLED") 1)
    (strcat (getvar "DWGPREFIX") (vl-filename-base (getvar "DWGNAME")) ".aalink.txt")
  )
)

(defun aa:link-open (path mode / f)
  ;; 值文件按 UTF-8 读写（中望 open 的编码参数）；不支持时退回默认编码，同一环境读写一致
  (setq f (vl-catch-all-apply 'open (list path mode "utf8")))
  (if (or (null f) (vl-catch-all-error-p f))
    (setq f (vl-catch-all-apply 'open (list path mode)))
  )
  (if (vl-catch-all-error-p f) nil f)
)

(defun aa:link-write-records (f roots / tab n item uid ed plain raw)
  ;; roots 为 ((UID . 原件 entget) ...)；每个原件写一行 P（纯文本），MTEXT 原件再写一行 M（含格式码原文）
  (setq tab (chr 9)
        n   0)
  (write-line (strcat "AA_LINK_VALUES" tab "1") f)
  (foreach item roots
    (setq uid   (car item)
          ed    (cdr item)
          plain (aa:ysdl-get-plain-text ed))
    (if (aa:link-line-ok-p plain)
      (progn
        (write-line (strcat "P" tab uid tab plain) f)
        (if (and (= (cdr (assoc 0 ed)) "MTEXT")
                 (aa:link-line-ok-p (setq raw (aa:ysdl-get-raw-text ed))))
          (write-line (strcat "M" tab uid tab raw) f)
        )
        (setq n (1+ n))
      )
    )
  )
  n
)

(defun aa:link-export (roots path / f n)
  ;; 写出值文件，返回写出的原件数；打不开或写入出错返回 nil，文件总会关闭
  (if (setq f (aa:link-open path "w"))
    (progn
      (setq n (vl-catch-all-apply 'aa:link-write-records (list f roots)))
      (close f)
      (if (vl-catch-all-error-p n) nil n)
    )
  )
)

(defun aa:link-parse-line (line / tab p1 p2 kind)
  ;; "P|M<TAB>UID<TAB>内容" → (类型 UID 内容)；表头、空行及其他格式返回 nil
  (setq tab (chr 9))
  (if (and (> (strlen line) 0) (= (substr line (strlen line)) "\r"))
    (setq line (substr line 1 (1- (strlen line))))
  )
  (if (and (setq p1 (vl-string-search tab line))
           (setq p2 (vl-string-search tab line (1+ p1)))
           (> p2 (1+ p1))
           (member (setq kind (substr line 1 p1)) '("P" "M")))
    (list kind (substr line (+ p1 2) (- p2 p1 1)) (substr line (+ p2 2)))
  )
)

(defun aa:link-read-lines (f recs / line rec prev)
  ;; 逐行解析并前插到 recs，记录为 (UID 纯文本 MTEXT原文)；M 行只补给紧邻其前、同 UID 的 P 行
  (while (setq line (read-line f))
    (setq rec (aa:link-parse-line line))
    (cond
      ((null rec)
       (setq prev nil))
      ((= (car rec) "P")
       (setq prev (list (cadr rec) (caddr rec) nil)
             recs (cons prev recs)))
      ((and prev (= (car prev) (cadr rec)))
       (setq recs (cons (list (car prev) (cadr prev) (caddr rec)) (cdr recs))
             prev nil))
      (T
       (setq prev nil))
    )
  )
  recs
)

(defun aa:link-read-file (path recs / f res)
  ;; 读取一个值文件并入 recs；打不开或读取出错时原样返回 recs
  (if (setq f (aa:link-open path "r"))
    (progn
      (setq res (vl-catch-all-apply 'aa:link-read-lines (list f recs)))
      (close f)
      (if (vl-catch-all-error-p res) recs res)
    )
    recs
  )
)

(defun aa:link-file-time (path / st)
  ;; 文件修改时间折算为可比较的数值；取不到时为 0
  (if (setq st (vl-file-systime path))
    (+ (* (nth 0 st) 1e10) (* (nth 1 st) 1e8) (* (nth 3 st) 1e6)
       (* (nth 4 st) 1e4) (* (nth 5 st) 100.0) (nth 6 st))
    0.0
  )
)

(defun aa:link-collect-files (dir depth / out f sub)
  ;; dir 及其下 depth 层子文件夹中的 *.aalink.txt 完整路径；dir 统一补成以 \ 结尾（兼容盘符根目录）
  (setq dir (strcat (vl-string-right-trim "\\/" dir) "\\"))
  (foreach f (vl-directory-files dir "*.aalink.txt" 1)
    (setq out (cons (strcat dir f) out))
  )
  (if (> depth 0)
    (foreach sub (vl-directory-files dir nil -1)
      (if (not (member sub '("." "..")))
        (setq out (append (aa:link-collect-files (strcat dir sub) (1- depth)) out))
      )
    )
  )
  out
)

(defun aa:link-join (items recs / out item)
  ;; items 为 ((UID . 副本图元) ...)，recs 为 ((UID 纯文本 MTEXT原文) ...)，两者均已按 UID 升序；
  ;; 同 UID 多条记录时取第一条（较新文件）。返回 ((副本图元 . 记录或 nil) ...)
  (foreach item items
    (while (and recs (aa:link-uid< (car recs) item))
      (setq recs (cdr recs))
    )
    (setq out (cons (cons (cdr item) (if (and recs (= (caar recs) (car item))) (car recs))) out))
  )
  (reverse out)
)

(defun aa:link-count-conflicts (recs / n)
  ;; recs 已按 UID 排序：同 UID 相邻记录内容不同即计一次冲突
  (setq n 0)
  (while (cdr recs)
    (if (and (= (caar recs) (car (cadr recs)))
             (not (equal (cdar recs) (cdr (cadr recs)))))
      (setq n (1+ n))
    )
    (setq recs (cdr recs))
  )
  n
)

(defun aa:link-browse-folder (/ sh fo self path)
  ;; Windows 文件夹浏览对话框；取消或失败返回 nil
  (setq sh (vl-catch-all-apply 'vlax-create-object '("Shell.Application")))
  (if (= (type sh) 'VLA-OBJECT)
    (progn
      (setq fo (vl-catch-all-apply 'vlax-invoke-method
                 (list sh 'BrowseForFolder 0 "选择卷册图值文件（*.aalink.txt）所在文件夹" 0)))
      (if (= (type fo) 'VLA-OBJECT)
        (progn
          (setq self (vl-catch-all-apply 'vlax-get-property (list fo 'Self)))
          (if (= (type self) 'VLA-OBJECT)
            (progn
              (setq path (vl-catch-all-apply 'vlax-get-property (list self 'Path)))
              (vlax-release-object self)
            )
          )
          (vlax-release-object fo)
        )
      )
      (vlax-release-object sh)
    )
  )
  (if (and (= (type path) 'STR) (vl-file-directory-p path)) path)
)

(defun aa:link-ask-folder (/ default s)
  ;; 回车用默认文件夹（上次使用或本图所在文件夹），B 打开浏览对话框，也可直接输入或粘贴路径
  (setq default (if (and (= (type *aa-link-dir*) 'STR) (vl-file-directory-p *aa-link-dir*))
                  *aa-link-dir*
                  (getvar "DWGPREFIX")))
  (setq s (vl-string-trim " \"" (getstring T (strcat "\r\n[SX2] 值文件所在文件夹 <" default ">，输入 B 浏览: "))))
  (cond
    ((= s "") default)
    ((= (strcase s) "B") (aa:link-browse-folder))
    (T s)
  )
)

;;; =======================================================================================
;;; 命令: SX0
;;; 功能: 清除联动标记。框选文字，删除副本上的 AA_LINK 扩展数据，使其成为与原件无关的普通文字；
;;;       原件自动跳过（清掉原件会让它的全部副本变成“原件缺失”），无标记的文字不处理。
;;; =======================================================================================
(defun c:SX0 (/ *error* aa:tag aa:doc aa:undo-open aa:old-cmdecho
               ss i en ed h info dwg-id n-clr n-root n-none n-fail)
  (aa:cmd-begin "SX0")
  (princ "\r\n[SX0] 框选要清除联动标记的文字（原件会自动跳过）: ")
  (setq ss (ssget '((0 . "TEXT,MTEXT"))))
  (if (null ss)
    (princ "\r\n[SX0] 未选择文字，命令结束。")
    (progn
      (setq dwg-id (aa:link-dwg-id nil)
            i 0 n-clr 0 n-root 0 n-none 0 n-fail 0)
      (while (< i (sslength ss))
        (setq en   (ssname ss i)
              ed   (entget en '("AA_LINK"))
              h    (cdr (assoc 5 ed))
              info (aa:link-info ed))
        (cond
          ((null info)
           (setq n-none (1+ n-none)))
          ((aa:link-root-p info dwg-id h)
           (setq n-root (1+ n-root)))
          ;; 只写应用名不带数据，即删除该应用的扩展数据
          ((entmod (subst '(-3 ("AA_LINK")) (assoc -3 ed) ed))
           (setq n-clr (1+ n-clr)))
          (T
           (setq n-fail (1+ n-fail)))
        )
        (setq i (1+ i))
      )
      (princ (strcat "\r\n[SX0] 清除副本标记 " (itoa n-clr) " 个，跳过原件 " (itoa n-root)
                     " 个，无标记 " (itoa n-none) " 个。"))
      (if (> n-fail 0)
        (princ (strcat "\r\n[SX0] 另有 " (itoa n-fail) " 个副本清除失败（所在图层可能被锁定）。"))
      )
      (if (> n-root 0)
        (princ "\r\n[SX0] 原件标记不会清除；想要不带标记的文字，请复制后对副本执行 SX0。")
      )
    )
  )
  (aa:cmd-end)
)

;;; =======================================================================================
;;; 命令: YSSX0
;;; 功能: 强制清除联动标记。框选文字，原件和副本上的 AA_LINK 扩展数据一并删除，全部成为普通文字。
;;;       注意：原件标记清除后，其他图或本图中仍保留标记的副本将找不到原件，SX1/SX2 不再更新它们。
;;; =======================================================================================
(defun c:YSSX0 (/ *error* aa:tag aa:doc aa:undo-open aa:old-cmdecho
                 ss i en ed h info dwg-id n-root n-copy n-none n-fail)
  (aa:cmd-begin "YSSX0")
  (princ "\r\n[YSSX0] 框选要清除联动标记的文字（原件和副本都会清除）: ")
  (setq ss (ssget '((0 . "TEXT,MTEXT"))))
  (if (null ss)
    (princ "\r\n[YSSX0] 未选择文字，命令结束。")
    (progn
      (setq dwg-id (aa:link-dwg-id nil)
            i 0 n-root 0 n-copy 0 n-none 0 n-fail 0)
      (while (< i (sslength ss))
        (setq en   (ssname ss i)
              ed   (entget en '("AA_LINK"))
              h    (cdr (assoc 5 ed))
              info (aa:link-info ed))
        (cond
          ((null info)
           (setq n-none (1+ n-none)))
          ;; 只写应用名不带数据，即删除该应用的扩展数据
          ((entmod (subst '(-3 ("AA_LINK")) (assoc -3 ed) ed))
           (if (aa:link-root-p info dwg-id h)
             (setq n-root (1+ n-root))
             (setq n-copy (1+ n-copy))
           ))
          (T
           (setq n-fail (1+ n-fail)))
        )
        (setq i (1+ i))
      )
      (princ (strcat "\r\n[YSSX0] 清除原件标记 " (itoa n-root) " 个，副本标记 " (itoa n-copy)
                     " 个，无标记 " (itoa n-none) " 个。"))
      (if (> n-fail 0)
        (princ (strcat "\r\n[YSSX0] 另有 " (itoa n-fail) " 个清除失败（所在图层可能被锁定）。"))
      )
      (if (> n-root 0)
        (princ "\r\n[YSSX0] 已清除原件标记，仍带标记的对应副本将不再被 SX1/SX2 更新；如需可用 SX0 一并清除。")
      )
    )
  )
  (aa:cmd-end)
)

;;; =======================================================================================
;;; 命令: SX
;;; 功能: 联动标记。框选原件端子排文字，为未标记的文字发放 UID；已是原件的跳过，
;;;       副本（草稿、XYG、GTY 等）不会被改成原件。
;;; =======================================================================================
(defun c:SX (/ *error* aa:tag aa:doc aa:undo-open aa:old-cmdecho
                ss i en ed h info dwg-id n-new n-root n-copy)
  (aa:cmd-begin "SX")
  (princ "\r\n[SX] 框选原件端子排中的文字（只选原件，不要选草稿）: ")
  (setq ss (ssget '((0 . "TEXT,MTEXT"))))
  (cond
    ((null ss)
     (princ "\r\n[SX] 未选择文字，命令结束。"))
    ((null (progn (regapp "AA_LINK") (setq dwg-id (aa:link-dwg-id T))))
     (princ "\r\n[SX] 无法创建本图联动 ID，命令结束。"))
    (T
     (setq i 0 n-new 0 n-root 0 n-copy 0)
     (while (< i (sslength ss))
       (setq en   (ssname ss i)
             ed   (entget en '("AA_LINK"))
             h    (cdr (assoc 5 ed))
             info (aa:link-info ed))
       (cond
         ((null info)
          (if (entmod (append ed (list (list -3 (list "AA_LINK" (cons 1000 dwg-id) (cons 1000 h))))))
            (setq n-new (1+ n-new))))
         ((aa:link-root-p info dwg-id h)
          (setq n-root (1+ n-root)))
         (T
          (setq n-copy (1+ n-copy)))
       )
       (setq i (1+ i))
     )
     (princ (strcat "\r\n[SX] 新标记 " (itoa n-new) " 个，已是原件 " (itoa n-root)
                    " 个，副本跳过 " (itoa n-copy) " 个。"))
    )
  )
  (aa:cmd-end)
)

(defun aa:link-clock ()
  ;; 当前时刻（秒），用于命令分段计时
  (* 86400.0 (getvar "DATE"))
)

(defun aa:link-root-ed (info dwg-id / en ed)
  ;; 副本按记录的原件句柄直接定位原件（handent），不再在原件列表里逐个比对；
  ;; 原件须仍存在且自身记录与句柄一致，否则返回 nil
  (if (and info (= (car info) dwg-id)
           (setq en (handent (cadr info)))
           (setq ed (entget en '("AA_LINK")))
           (member (cdr (assoc 0 ed)) '("TEXT" "MTEXT"))
           (aa:link-root-p (aa:link-info ed) dwg-id (cadr info)))
    ed
  )
)

;;; =======================================================================================
;;; 命令: SX1
;;; 功能: 联动刷新。扫描全图带 AA_LINK 的文字，副本按同 UID 原件的内容单向更新，
;;;       只同步文字内容；原件已删除的副本保持原样并计入“原件缺失”。
;;;       原件在其他图纸的副本（跨图粘贴而来）由总图 SX2 刷新，本命令只计数。
;;;       本图有原件且已保存时，同时在 dwg 旁写出 <图名>.aalink.txt，供总图 SX2 跨图刷新。
;;; =======================================================================================
(defun c:SX1 (/ *error* aa:tag aa:doc aa:undo-open aa:old-cmdecho
                ss i en ed h info dwg-id roots items item src-ed new-str n-chg n-miss n-other
                path n-out t0 t1 t2 t3)
  (aa:cmd-begin "SX1")
  (setq t0     (aa:link-clock)
        dwg-id (aa:link-dwg-id nil)
        ss     (ssget "_X" '((0 . "TEXT,MTEXT") (-3 ("AA_LINK")))))
  (if (or (null ss) (null dwg-id))
    (princ "\r\n[SX1] 本图没有联动文字，请先用 SX 标记原件端子排。")
    (progn
      ;; 第一遍：区分原件与副本；原件留 entget 供导出，副本留 (联动信息 . 图元)
      (setq i 0 roots '() items '())
      (while (< i (sslength ss))
        (setq en   (ssname ss i)
              ed   (entget en '("AA_LINK"))
              h    (cdr (assoc 5 ed))
              info (aa:link-info ed))
        (if info
          (if (aa:link-root-p info dwg-id h)
            (setq roots (cons (cons (strcat (car info) "|" (cadr info)) ed) roots))
            (setq items (cons (cons info en) items))
          )
        )
        (setq i (1+ i))
      )
      (setq t1 (aa:link-clock))
      ;; 第二遍：副本按原件内容更新（entget 不带应用名，entmod 不改动扩展数据）
      (setq n-chg 0 n-miss 0 n-other 0)
      (foreach item items
        (cond
          ((/= (car (car item)) dwg-id)
           (setq n-other (1+ n-other)))
          ((setq src-ed (aa:link-root-ed (car item) dwg-id))
           (setq ed      (entget (cdr item))
                 new-str (aa:link-text-for ed src-ed))
           (if (and new-str (/= new-str (cdr (assoc 1 ed))))
             (if (entmod (subst (cons 1 new-str) (assoc 1 ed) ed))
               (setq n-chg (1+ n-chg))
             )
           )
          )
          (T
           (setq n-miss (1+ n-miss)))
        )
      )
      (if (> n-chg 0) (redraw))
      (setq t2 (aa:link-clock))
      (princ (strcat "\r\n[SX1] 原件 " (itoa (length roots)) " 个，副本 " (itoa (length items))
                     " 个，已更新 " (itoa n-chg) " 个，原件缺失 " (itoa n-miss) " 个。"))
      (if (> n-other 0)
        (princ (strcat "\r\n[SX1] 另有 " (itoa n-other) " 个副本的原件在其他图纸，请用 SX2 刷新。"))
      )
      ;; 跨图：导出本图原件的当前内容
      (cond
        ((null roots))
        ((null (setq path (aa:link-file-path)))
         (princ "\r\n[SX1] 图纸尚未保存，未导出跨图值文件；保存后再执行一次 SX1。"))
        ((setq n-out (aa:link-export roots path))
         (princ (strcat "\r\n[SX1] 已导出跨图值文件（原件 " (itoa n-out) " 个）：" path)))
        (T
         (princ (strcat "\r\n[SX1] 跨图值文件写入失败（只读或被占用？）：" path)))
      )
      (setq t3 (aa:link-clock))
      (princ (strcat "\r\n[SX1] 用时 " (rtos (- t3 t0) 2 1) " 秒（扫描 " (rtos (- t1 t0) 2 1)
                     " / 刷新 " (rtos (- t2 t1) 2 1) " / 导出 " (rtos (- t3 t2) 2 1) "）。"))
    )
  )
  (aa:cmd-end)
)

;;; =======================================================================================
;;; 命令: SX2
;;; 功能: 跨图联动刷新（总图用）。读取指定文件夹及其下两层子文件夹内的 *.aalink.txt，
;;;       按 UID 更新本图中原件不在本图的副本，只同步文字内容；同 UID 出现在多个值文件时
;;;       取修改时间较新的文件。本图自有原件的副本仍由 SX1 刷新。
;;; =======================================================================================
(defun c:SX2 (/ *error* aa:tag aa:doc aa:undo-open aa:old-cmdecho
                dwg-id ss i en info items dir files f recs pair rec ed new-str
                n-chg n-miss n-conf)
  (aa:cmd-begin "SX2")
  (setq dwg-id (aa:link-dwg-id nil)
        ss     (ssget "_X" '((0 . "TEXT,MTEXT") (-3 ("AA_LINK"))))
        i      0
        items  '())
  ;; 只收集原件在其他图纸的副本：图纸 ID 与本图不同（本图从未 SX 时 dwg-id 为 nil，全部计入）
  (if ss
    (while (< i (sslength ss))
      (setq en   (ssname ss i)
            info (aa:link-info (entget en '("AA_LINK"))))
      (if (and info (/= (car info) dwg-id))
        (setq items (cons (cons (strcat (car info) "|" (cadr info)) en) items))
      )
      (setq i (1+ i))
    )
  )
  (cond
    ((null items)
     (princ "\r\n[SX2] 本图没有来自其他图纸的联动文字（先在卷册图 SX 标记，再把 GTY 文字复制到本图）。"))
    ((null (setq dir (aa:link-ask-folder)))
     (princ "\r\n[SX2] 未选择文件夹，命令结束。"))
    ((not (vl-file-directory-p dir))
     (princ (strcat "\r\n[SX2] 文件夹不存在：" dir)))
    ((null (setq files (aa:link-collect-files dir 2)))
     (princ (strcat "\r\n[SX2] 未找到 *.aalink.txt 值文件，请先在各卷册图（已保存）执行 SX1：" dir)))
    (T
     (setq *aa-link-dir* dir
           recs          '())
     ;; 按修改时间从旧到新读取，较新文件的记录排在前面；稳定排序后同 UID 的首条即最新
     (foreach f (mapcar 'cdr
                        (aa:merge-sort (mapcar '(lambda (p) (cons (aa:link-file-time p) p)) files)
                                       '(lambda (a b) (< (car a) (car b)))))
       (setq recs (aa:link-read-file f recs))
     )
     (setq recs   (aa:merge-sort recs 'aa:link-uid<)
           items  (aa:merge-sort items 'aa:link-uid<)
           n-conf (aa:link-count-conflicts recs)
           n-chg  0
           n-miss 0)
     ;; 副本按记录更新（entget 不带应用名，entmod 不改动扩展数据）
     (foreach pair (aa:link-join items recs)
       (if (setq rec (cdr pair))
         (progn
           (setq ed      (entget (car pair))
                 new-str (aa:link-text-from-rec ed rec))
           (if (and new-str (/= new-str (cdr (assoc 1 ed))))
             (if (entmod (subst (cons 1 new-str) (assoc 1 ed) ed))
               (setq n-chg (1+ n-chg))
             )
           )
         )
         (setq n-miss (1+ n-miss))
       )
     )
     (redraw)
     (princ (strcat "\r\n[SX2] 值文件 " (itoa (length files)) " 个，跨图副本 " (itoa (length items))
                    " 个，已更新 " (itoa n-chg) " 个，未找到原件值 " (itoa n-miss) " 个"
                    (if (> n-conf 0) (strcat "，多文件内容不一致 " (itoa n-conf) " 处（已取较新文件）") "")
                    "。"))
    )
  )
  (aa:cmd-end)
)

;;; =======================================================================================
;;; 命令: HBDL
;;; 功能: 框选电缆清册表格文字，自动将带有“并入”前缀的行合并到对应的目标电缆主行中，
;;;       自动累加芯数并合并自然排序原理号，支持回车原地紧凑更新或指定新插入点输出。
;;; =======================================================================================

(defun hb:extract-target-cable-id (str)
  (if (vl-string-search "并入" str)
    (vl-string-trim " \t:-：" (vl-string-subst "" "并入" str))
    str
  )
)

(defun hb:find-core-index (items / len best-idx i str val rem-cnt)
  (setq len (length items)
        best-idx nil)
  ;; 策略 1: 用户指定位置在 4×2.5 后面，即从左往右数第 5 个（索引 4）
  (if (and (>= len 5)
           (setq str (caddr (nth 4 items)))
           (setq val (atoi str))
           (> val 0))
    (if (equal str (itoa val))
      (setq best-idx 4)
    )
  )
  ;; 策略 2: 寻找 (atoi val) == 右侧剩余原理号数量 的字段
  (if (null best-idx)
    (progn
      (setq i 1)
      (while (< i len)
        (setq str (caddr (nth i items))
              val (atoi str)
              rem-cnt (- len 1 i))
        (if (and (> val 0) (= val rem-cnt) (equal str (itoa val)))
          (setq best-idx i
                i len)
        )
        (setq i (1+ i))
      )
    )
  )
  ;; 策略 3: 从后往前查找正整数
  (if (null best-idx)
    (progn
      (setq i (1- len))
      (while (> i 1)
        (setq str (caddr (nth i items))
              val (atoi str))
        (if (and (> val 0) (<= val 200) (equal str (itoa val)))
          (setq best-idx i
                i 0)
        )
        (setq i (1- i))
      )
    )
  )
  best-idx
)

(defun hb:find-cable-index (items core-idx / idx i str)
  (setq idx nil
        i 0)
  (while (and (< i core-idx) (null idx))
    (setq str (caddr (nth i items)))
    (if (vl-string-search "并入" str)
      (setq idx i)
    )
    (setq i (1+ i))
  )
  (if (null idx)
    (if (>= core-idx 2) 1 0)
    idx
  )
)

(defun hb:cluster-rows (items tol / sorted rows cur-row cur-y itm y)
  ;; 按 Y 坐标从大到小（从上到下）排序
  (setq sorted
    (aa:merge-sort items '(lambda (a b) (> (cadr a) (cadr b)))))
  (setq rows '()
        cur-row '()
        cur-y nil)
  (foreach itm sorted
    (setq y (cadr itm))
    (if (null cur-y)
      (setq cur-y y
            cur-row (list itm))
      (if (<= (abs (- cur-y y)) tol)
        (setq cur-row (cons itm cur-row))
        (progn
          ;; 当前行结束：按 X 坐标从小到大（从左到右）排序
          (setq rows (cons (aa:merge-sort cur-row '(lambda (a b) (< (car a) (car b)))) rows))
          (setq cur-y y
                cur-row (list itm))
        )
      )
    )
  )
  (if cur-row
    (setq rows (cons (aa:merge-sort cur-row '(lambda (a b) (< (car a) (car b)))) rows))
  )
  (reverse rows)
)

(defun hb:parse-row (items default-cable-idx / core-idx cable-idx cable-str is-merge target-id core-cnt prefix-items middle-items principles i itm-str core-en last-itm row-y all-ens)
  (setq core-idx (hb:find-core-index items))
  (if (and core-idx (> core-idx 0))
    (progn
      (setq cable-idx (hb:find-cable-index items core-idx))
      (if (null cable-idx) (setq cable-idx (if default-cable-idx default-cable-idx 1)))
      (setq cable-str (caddr (nth cable-idx items))
            is-merge  (if (vl-string-search "并入" cable-str) T nil)
            target-id (hb:extract-target-cable-id cable-str)
            core-cnt  (atoi (caddr (nth core-idx items)))
            core-en   (nth 3 (nth core-idx items))
            last-itm  (last items)
            row-y     (cadr (car items))
            all-ens   (mapcar '(lambda (x) (nth 3 x)) items)
            prefix-items '()
            middle-items '()
            principles   '()
            i 0)
      (while (< i (length items))
        (setq itm-str (caddr (nth i items)))
        (cond
          ((< i cable-idx)
           (setq prefix-items (cons itm-str prefix-items)))
          ((and (> i cable-idx) (< i core-idx))
           (setq middle-items (cons itm-str middle-items)))
          ((> i core-idx)
           (setq principles (cons itm-str principles)))
        )
        (setq i (1+ i))
      )
      (list
        (reverse prefix-items)
        cable-str
        target-id
        is-merge
        (reverse middle-items)
        core-cnt
        (reverse principles)
        all-ens
        (caddr (car items))
        core-en
        last-itm
        row-y
        items
      )
    )
    nil
  )
)

(defun hb:update-text-content (en new-str / ed)
  (setq ed (entget en))
  (if (and ed (assoc 1 ed))
    (entmod (subst (cons 1 new-str) (assoc 1 ed) ed))
  )
)

(defun hb:create-text-matching (ref-en pt str / ed d40 d7 d8 d62 d41 d50 d51 d71 d72 d73 lst en)
  (setq ed (entget ref-en))
  (if ed
    (progn
      (setq d40 (cdr (assoc 40 ed))
            d7  (cdr (assoc 7 ed))
            d8  (cdr (assoc 8 ed))
            d62 (if (assoc 62 ed) (cdr (assoc 62 ed)) nil)
            d41 (if (assoc 41 ed) (cdr (assoc 41 ed)) nil)
            d50 (if (assoc 50 ed) (cdr (assoc 50 ed)) nil)
            d51 (if (assoc 51 ed) (cdr (assoc 51 ed)) nil)
            d71 (if (assoc 71 ed) (cdr (assoc 71 ed)) nil)
            d72 (if (assoc 72 ed) (cdr (assoc 72 ed)) nil)
            d73 (if (assoc 73 ed) (cdr (assoc 73 ed)) nil))
      (setq lst (list '(0 . "TEXT") (cons 10 pt) (cons 1 str)))
      (if d40 (setq lst (append lst (list (cons 40 d40)))) (setq lst (append lst (list (cons 40 3.0)))))
      (if d7  (setq lst (append lst (list (cons 7 d7))))   (setq lst (append lst (list (cons 7 (getvar "TEXTSTYLE"))))))
      (if d8  (setq lst (append lst (list (cons 8 d8))))   (setq lst (append lst (list (cons 8 (getvar "CLAYER"))))))
      (if d62 (setq lst (append lst (list (cons 62 d62)))))
      (if d41 (setq lst (append lst (list (cons 41 d41)))))
      (if d50 (setq lst (append lst (list (cons 50 d50)))))
      (if d51 (setq lst (append lst (list (cons 51 d51)))))
      (if d71 (setq lst (append lst (list (cons 71 d71)))))
      (if d72 (setq lst (append lst (list (cons 72 d72)))))
      (if d73 (setq lst (append lst (list (cons 73 d73)))))
      (if (or (and d72 (/= d72 0)) (and d73 (/= d73 0)) (assoc 11 ed))
        (setq lst (append lst (list (cons 11 pt))))
      )
      (setq en (entmakex lst))
      (if (null en)
        (progn
          (entmake lst)
          (setq en (entlast))
        )
      )
      en
    )
  )
)

(defun hb:move-entity (en dy / ed p10 p11)
  (setq ed (entget en))
  (if ed
    (progn
      (if (setq p10 (cdr (assoc 10 ed)))
        (setq ed (subst (cons 10 (list (car p10) (+ (cadr p10) dy) (if (caddr p10) (caddr p10) 0.0)))
                        (assoc 10 ed)
                        ed))
      )
      (if (setq p11 (cdr (assoc 11 ed)))
        (setq ed (subst (cons 11 (list (car p11) (+ (cadr p11) dy) (if (caddr p11) (caddr p11) 0.0)))
                        (assoc 11 ed)
                        ed))
      )
      (entmod ed)
    )
  )
)

(defun hb:apply-merge-in-place (parsed-rows col-width /
                                updated-rows merge-count i r is-merge target-id
                                found-base base-idx b-row merged-core last-itm cur-x base-y ref-en
                                p-str new-en new-base en)
  (setq updated-rows parsed-rows
        merge-count  0
        i 0)
  (while (< i (length updated-rows))
    (setq r (nth i updated-rows)
          is-merge (nth 3 r))
    (if is-merge
      (progn
        (setq target-id (nth 2 r)
              found-base nil
              base-idx   0)
        ;; 在列表中查找匹配的目标主电缆行
        (while (and (< base-idx (length updated-rows)) (null found-base))
          (setq b-row (nth base-idx updated-rows))
          (if (and (/= base-idx i)
                   (null (nth 3 b-row))
                   (equal (nth 0 b-row) (nth 0 r))
                   (equal (nth 2 b-row) target-id))
            (setq found-base b-row)
            (setq base-idx (1+ base-idx))
          )
        )
        (if found-base
          (progn
            ;; 1. 累加芯数并直接就地更新主行芯数文字 (如 3 改成 4)
            (setq merged-core (+ (nth 5 found-base) (nth 5 r)))
            (hb:update-text-content (nth 9 found-base) (itoa merged-core))

            ;; 2. 在主行原有原理号末尾依次追加并入行的原理号
            (setq last-itm (nth 10 found-base)
                  cur-x    (car last-itm)
                  base-y   (cadr last-itm)
                  ref-en   (nth 3 last-itm))
            (foreach p-str (nth 6 r)
              (setq cur-x (+ cur-x col-width))
              (setq new-en (hb:create-text-matching ref-en (list cur-x base-y 0.0) p-str))
              (if new-en
                (setq ref-en new-en
                      last-itm (list cur-x base-y p-str new-en))
              )
            )

            ;; 3. 更新主行在内存中的状态
            (setq new-base
              (list
                (nth 0 found-base)
                (nth 1 found-base)
                (nth 2 found-base)
                nil
                (nth 4 found-base)
                merged-core
                (append (nth 6 found-base) (nth 6 r))
                (append (nth 7 found-base) (nth 7 r))
                (nth 8 found-base)
                (nth 9 found-base)
                last-itm
                (nth 11 found-base)
                (nth 12 found-base)
              ))
            (setq updated-rows (subst new-base found-base updated-rows))

            ;; 4. 删除被吸收并入行的全部文字图元
            (foreach en (nth 7 r)
              (entdel en)
            )
            (setq updated-rows
                    (subst
                      (list (nth 0 r) (nth 1 r) (nth 2 r) 'MERGED (nth 4 r) (nth 5 r) (nth 6 r) (nth 7 r) (nth 8 r) (nth 9 r) (nth 10 r) (nth 11 r) (nth 12 r))
                      r
                      updated-rows))
            (setq merge-count (1+ merge-count))
          )
        )
      )
    )
    (setq i (1+ i))
  )

  merge-count
)

(defun c:HBDL (/ *error* aa:tag aa:doc aa:undo-open aa:old-cmdecho
               ss all-data all-old-enames i en ed str pt-val x y
               text-height text-style tol rows parsed-rows has-merge pr
               merge-cnt row0 col-width r-items)
  (aa:cmd-begin "HBDL")

  ;; 支持先选后执与后选
  (setq ss (ssget "_I" '((0 . "TEXT,MTEXT"))))
  (if (null ss)
    (progn
      (prompt "\r\n[HBDL] 请框选要合并的电缆清册表格文字: ")
      (setq ss (ssget '((0 . "TEXT,MTEXT"))))
    )
  )

  (if (null ss)
    (progn
      (princ "\r\n[HBDL] 未选择对象，HBDL 命令结束。")
      (aa:cmd-end)
    )
    (progn
      ;; 1. 采集所选文字及其坐标
      (setq all-data       '()
            all-old-enames '()
            i              0
            text-height    3.0
            text-style     (if (tblsearch "STYLE" "HZ") "HZ" (getvar "TEXTSTYLE")))
      (while (< i (sslength ss))
        (setq en     (ssname ss i)
              ed     (entget en)
              str    (aa:ysdl-get-plain-text ed)
              pt-val (if (and (= (cdr (assoc 0 ed)) "TEXT")
                              (or (/= (cdr (assoc 72 ed)) 0) (/= (cdr (assoc 73 ed)) 0))
                              (assoc 11 ed))
                       (cdr (assoc 11 ed))
                       (cdr (assoc 10 ed))))
        (if (and pt-val (/= (vl-string-trim " \t\r\n" str) ""))
          (progn
            (if (= i 0)
              (setq text-height (if (assoc 40 ed) (cdr (assoc 40 ed)) 3.0)
                    text-style  (if (assoc 7 ed)  (cdr (assoc 7 ed))  text-style))
            )
            (setq x (car pt-val)
                  y (cadr pt-val))
            (setq all-data (cons (list x y str en) all-data)
                  all-old-enames (cons en all-old-enames))
          )
        )
        (setq i (1+ i))
      )

      (if (null all-data)
        (progn
          (princ "\r\n[HBDL] 选集中未找到有效的文字内容。")
          (aa:cmd-end)
        )
        (progn
          ;; 2. 按行聚类并解析
          (setq tol (* text-height 0.6))
          (setq rows (hb:cluster-rows all-data tol))
          (setq parsed-rows '())
          (foreach r-items rows
            (setq pr (hb:parse-row r-items nil))
            (if pr
              (setq parsed-rows (cons pr parsed-rows))
            )
          )
          (setq parsed-rows (reverse parsed-rows))

          ;; 3. 检查是否存在包含“并入”的行
          (setq has-merge nil)
          (foreach pr parsed-rows
            (if (nth 3 pr) (setq has-merge T))
          )

          (if (null has-merge)
            (progn
              (princ "\r\n[HBDL] 所选文字中未发现包含“并入”的电缆行，无需合并。")
              (aa:cmd-end)
            )
            (progn
              ;; 4. 计算原表格列间距
              (setq row0 (car rows))
              (setq col-width 50.0)
              (if (>= (length row0) 2)
                (setq col-width (abs (- (car (cadr row0)) (car (car row0)))))
              )
              (if (or (< col-width 10.0) (> col-width 200.0))
                (setq col-width 50.0)
              )

              ;; 5. 直接在原图上就地修改合并（3改成4，原理号加上，并入行删除，其他所有行完全不移动）
              (setq merge-cnt (hb:apply-merge-in-place parsed-rows col-width))

              (if (= merge-cnt 0)
                (princ "\r\n[HBDL] 发现“并入”行，但未匹配到对应的目标主电缆行，未做修改。")
                (princ (strcat "\r\n[HBDL] 原地合并完成：成功合并 " (itoa merge-cnt) " 个并入行。主电缆芯数已更新，原理号已向后堆积追加。"))
              )
              (aa:cmd-end)
            )
          )
        )
      )
    )
  )
)
(princ) ; 干净地退出加载过程

(defun aa:digit-char-p (ch / code)
  (and ch
       (= (type ch) 'STR)
       (= (strlen ch) 1)
       (setq code (ascii ch))
       (<= 48 code 57))
)

(defun aa:nu-number-token-at (str start / len idx digit-found end)
  (setq len (strlen str)
        idx start
        digit-found nil
        end nil)
  (if (<= start len)
    (progn
      (if (member (substr str idx 1) '("+" "-"))
        (setq idx (1+ idx)))
      (while (and (<= idx len)
                  (aa:digit-char-p (substr str idx 1)))
        (setq digit-found T
              end idx
              idx (1+ idx)))
      (if (and (<= idx len)
               (= (substr str idx 1) ".")
               (< idx len)
               (aa:digit-char-p (substr str (1+ idx) 1)))
        (progn
          (setq idx (1+ idx))
          (while (and (<= idx len)
                      (aa:digit-char-p (substr str idx 1)))
            (setq digit-found T
                  end idx
                  idx (1+ idx)))))
      (if digit-found
        (list start
              end
              (substr str start (1+ (- end start)))))
    )
  )
)

(defun aa:nu-find-first-number (str / len idx token ch)
  (setq len (strlen str)
        idx 1
        token nil)
  (while (and (<= idx len) (null token))
    (setq ch (substr str idx 1))
    (if (or (aa:digit-char-p ch)
            (and (= ch ".")
                 (< idx len)
                 (aa:digit-char-p (substr str (1+ idx) 1)))
            (and (member ch '("+" "-"))
                 (< idx len)
                 (or (aa:digit-char-p (substr str (1+ idx) 1))
                     (and (< (1+ idx) len)
                          (= (substr str (1+ idx) 1) ".")
                          (aa:digit-char-p (substr str (+ idx 2) 1))))))
      (setq token (aa:nu-number-token-at str idx))
    )
    (if (null token)
      (setq idx (1+ idx))))
  token
)

;;; ---------------------------------------------------------------------------------------
;;; aa:num-target-span - NU 与 C1/C2/C3 共用的“目标数字”选择规则（纯函数，不操作图形）
;;;   返回 (start end kind)：start/end 为 str 中目标连续整数位的起止位置（1 起，含端点），
;;;   kind 为 'HASH（井号相邻数字）、'HYPHEN（最后一个减号后的数字）或 'FIRST（兜底）；
;;;   字符串中没有整数位时返回 nil。只逐字符扫描，不使用 vl-sort 或正则。
;;;   规则 A（井号）：井号指半角 "#" 或全角 "＃"，从左到右逐个检查，命中即停止。
;;;     A1 井号紧挨的左边是数字 → 取向左扩展的连续数字（"35kV 1#风机" → 1、"12#主变" → 12）；
;;;     A2 否则井号紧挨的右边是数字 → 取向右扩展的连续数字（"35kV #1风机" → 1、"#12" → 12）；
;;;     A3 两边都不是数字 → 继续下一个井号。
;;;   规则 B（减号，仅在规则 A 未命中时）：减号指半角 "-" 或全角 "－"，只作分隔符，
;;;     取“后面还有数字的最后一个减号”之后出现的第一段连续数字（"1(2)SVG-501" → 501；
;;;     "A-5-B" 最后一个减号后没有数字，退到前一个减号 → 5，不会把 "-5" 当负数）。
;;;   规则 C（兜底）：以上都没有命中时取第一段连续整数位，即 kind 为 'FIRST。
;;;   规则 A、B 只处理连续整数位，不处理小数点和正负号；调用方按 kind 决定数值格式。
;;; ---------------------------------------------------------------------------------------
(defun aa:num-target-span (str / len idx ch first-s first-e hash-s hash-e
                                 hyphen-pos pending-hyphen nxt-e)
  (setq len (strlen str)
        idx 1
        first-s nil
        first-e nil
        hash-s nil
        hash-e nil
        hyphen-pos nil
        pending-hyphen nil)
  ;; 第一遍：记住第一段连续整数位（兜底），以及“后面还有数字的最后一个减号”的位置：
  ;; 减号先记为待定，之后遇到数字才确认，结尾没有数字的减号不会覆盖前面已确认的位置。
  (while (<= idx len)
    (setq ch (substr str idx 1))
    (cond
      ((aa:digit-char-p ch)
       (if (null first-s) (setq first-s idx))
       (setq first-e idx)
       (if pending-hyphen (setq hyphen-pos pending-hyphen))
       (setq idx (1+ idx)))
      (T
       (if (or (= ch "-") (= ch "－"))
         (setq pending-hyphen idx))
       (setq idx (1+ idx))))
  )
  ;; 规则 A：从左到右逐个井号，紧挨的左边是数字则向左扩展，否则右边是数字则向右扩展；
  ;; 两边都不是数字就继续下一个井号，命中一个即停止。
  (setq idx 1)
  (while (and (<= idx len) (null hash-s))
    (setq ch (substr str idx 1))
    (if (or (= ch "#") (= ch "＃"))
      (cond
        ((and (> idx 1) (aa:digit-char-p (substr str (1- idx) 1)))
         (setq hash-e (1- idx)
               hash-s hash-e)
         (while (and (> hash-s 1) (aa:digit-char-p (substr str (1- hash-s) 1)))
           (setq hash-s (1- hash-s))))
        ((and (< idx len) (aa:digit-char-p (substr str (1+ idx) 1)))
         (setq hash-s (1+ idx)
               hash-e (1+ idx))
         (while (and (< hash-e len) (aa:digit-char-p (substr str (1+ hash-e) 1)))
           (setq hash-e (1+ hash-e))))
      )
    )
    (setq idx (1+ idx))
  )
  (cond
    (hash-s (list hash-s hash-e 'HASH))
    ;; 规则 B：最后一个减号只是分隔符，取它后面第一段连续数字，减号本身保持原样。
    ((and hyphen-pos
          (setq nxt-e (aa:num-next-digit-pos str (1+ hyphen-pos) len)))
     (setq hash-s nxt-e
           hash-e (+ nxt-e (1- (aa:num-digit-run-len str nxt-e len))))
     (list hash-s hash-e 'HYPHEN))
    ;; 规则 C：兜底取第一段连续整数位。
    (first-s (list first-s first-e 'FIRST))
  )
)

;;; ---------------------------------------------------------------------------------------
;;; aa:num-next-digit-pos - 从 str 的第 from 位起找第一段连续数字的首位，找不到返回 nil。
;;; ---------------------------------------------------------------------------------------
(defun aa:num-next-digit-pos (str from len / idx found)
  (setq idx from
        found nil)
  (while (and (<= idx len) (null found))
    (if (aa:digit-char-p (substr str idx 1))
      (setq found idx)
      (setq idx (1+ idx))))
  found
)

;;; ---------------------------------------------------------------------------------------
;;; aa:num-digit-run-len - str 中从第 start 位起连续数字位的个数（可能为 0）。
;;; ---------------------------------------------------------------------------------------
(defun aa:num-digit-run-len (str start len / end)
  (setq end start)
  (while (and (<= end len) (aa:digit-char-p (substr str end 1)))
    (setq end (1+ end)))
  (- end start)
)

(defun aa:nu-trim-number-string (str)
  (if (vl-string-search "." str)
    (progn
      (while (and (> (strlen str) 0)
                  (= (substr str (strlen str) 1) "0"))
        (setq str (substr str 1 (1- (strlen str)))))
      (if (and (> (strlen str) 0)
               (= (substr str (strlen str) 1) "."))
        (setq str (substr str 1 (1- (strlen str))))))
  )
  (if (or (= str "") (= str "-0") (= str "+0"))
    "0"
    str)
)

(defun aa:nu-string-all-digits-p (str / idx ok)
  (setq idx 1
        ok (> (strlen str) 0))
  (while (and ok (<= idx (strlen str)))
    (if (not (aa:digit-char-p (substr str idx 1)))
      (setq ok nil))
    (setq idx (1+ idx)))
  ok
)

(defun aa:nu-format-number (value old-token / raw body keep-plus pad-width abs-str)
  (setq raw (aa:nu-trim-number-string (rtos value 2 8))
        body old-token
        keep-plus nil
        pad-width 0)
  (if (> (strlen body) 0)
    (cond
      ((= (substr body 1 1) "+")
       (setq keep-plus T
             body (substr body 2)))
      ((= (substr body 1 1) "-")
       (setq body (substr body 2)))
    )
  )
  (if (and (= value (fix value))
           (> (strlen body) 1)
           (= (substr body 1 1) "0")
           (aa:nu-string-all-digits-p body))
    (progn
      (setq pad-width (strlen body)
            abs-str (itoa (abs (fix value))))
      (while (< (strlen abs-str) pad-width)
        (setq abs-str (strcat "0" abs-str)))
      (setq raw
             (strcat
               (cond
                 ((< value 0) "-")
                 ((and keep-plus (>= value 0)) "+")
                 (T ""))
               abs-str)))
    (if (and keep-plus
             (>= value 0)
             (/= raw ""))
      (setq raw (strcat "+" raw))))
  raw
)

(defun aa:num-int-target-p (str / span)
  ;; 目标是否按井号/减号规则选中了整数段（这些情况结果小于 0 时不修改）。
  (setq span (aa:num-target-span str))
  (and span (member (caddr span) '(HASH HYPHEN)))
)

(defun aa:num-pad-int (value width / text)
  ;; 整数转字符串并按原数字位数补前导零：72→"072"，位数不够自然进位（99→"100"）。
  (setq text (itoa (fix value)))
  (while (< (strlen text) width)
    (setq text (strcat "0" text)))
  text
)

;;; ---------------------------------------------------------------------------------------
;;; 功能: NU 的单个文字改写：按 aa:num-target-span 选目标数字后加 delta；井号/减号命中时
;;;       只改这段整数位（整数增量保留前导零宽度，小数增量输出小数），结果小于 0 返回 nil（由 NU 跳过并提示），
;;;       其余情况沿用原有 aa:nu-find-first-number 流程（支持小数和正负号）。
;;; ---------------------------------------------------------------------------------------
(defun aa:nu-rewrite-text (str delta / span token start end old-val new-str)
  (setq span (aa:num-target-span str))
  (cond
    ;; 规则 A/B：井号相邻数字或最后一个减号后的数字，整段按整数处理。
    ((member (caddr span) '(HASH HYPHEN))
     (setq start   (car span)
           end     (cadr span)
           old-val (atoi (substr str start (1+ (- end start))))
           ;; 结果小于 0 时不产生 "SVG--1" 这类文字，返回 nil 让调用方跳过。
           ;; 整数增量按整数输出并保留原数字位宽；小数增量按 aa:nu-format-number 输出小数
           ;; （"SVG-501" +0.5 → "SVG-501.5"），不再被截断成原值。
           new-str (cond
                     ((< (+ old-val delta) 0) nil)
                     ((= delta (fix delta))
                      (aa:num-pad-int (+ old-val delta) (1+ (- end start))))
                     (T
                      (aa:nu-format-number (+ old-val delta)
                                           (substr str start (1+ (- end start)))))))
     (if new-str
       (strcat
         (if (> start 1)
           (substr str 1 (1- start))
           "")
         new-str
         (if (< end (strlen str))
           (substr str (1+ end))
           ""))))
    ;; 规则 C 兜底（span 为 'FIRST 或无目标数字）：保持原有行为。
    (T
     (if (setq token (aa:nu-find-first-number str))
       (progn
         (setq start   (car token)
               end     (cadr token)
               old-val (distof (caddr token)))
         (if (numberp old-val)
           (progn
             (setq new-str (aa:nu-format-number (+ old-val delta) (caddr token)))
             (strcat
               (if (> start 1)
                 (substr str 1 (1- start))
                 "")
               new-str
               (if (< end (strlen str))
                 (substr str (1+ end))
                 "")))
         )
       )
     ))
  )
)

(defun c:NU (/ *error* doc undo-open ss a i en ed str new-str changed skipped)
  (vl-load-com)
  (setq doc (vla-get-ActiveDocument (vlax-get-acad-object))
        undo-open nil)

  (defun *error* (msg)
    (if undo-open
      (vl-catch-all-apply 'vla-EndUndoMark (list doc)))
    (if (and msg
             (not (wcmatch (strcase msg) "*BREAK*,*CANCEL*,*EXIT*,*QUIT*")))
      (princ (strcat "\r\n[NU] 错误: " msg)))
    (princ)
  )

  (if (null (setq a (getreal "\r\n[NU] 请输入要相加的数值: ")))
    (princ "\r\n[NU] 未输入数值。")
    (progn
      (princ "\r\n[NU] 请选择 TEXT/MTEXT 文字: ")
      (if (setq ss (ssget '((0 . "TEXT,MTEXT"))))
        (progn
          (setq i 0
                changed 0
                skipped 0)
          (vla-StartUndoMark doc)
          (setq undo-open T)
          (repeat (sslength ss)
            (setq en (ssname ss i)
                  ed (entget en)
                  str (cdr (assoc 1 ed))
                  new-str (if str (aa:nu-rewrite-text str a)))
            (cond
              ((and new-str (/= new-str str))
               (setq ed (subst (cons 1 new-str) (assoc 1 ed) ed))
               (if (entmod ed)
                 (setq changed (1+ changed))))
              ;; 目标数字按整数处理后小于 0（如 "SVG-000" 减 1）：不修改，计入跳过。
              ((and str (null new-str) (aa:num-int-target-p str))
               (setq skipped (1+ skipped))))
            (setq i (1+ i)))
          (vla-EndUndoMark doc)
          (setq undo-open nil)
          (princ (strcat "\r\n[NU] 已更新 " (itoa changed) " 个文字对象。"))
          (if (> skipped 0)
            (princ (strcat "\r\n[NU] 已跳过 " (itoa skipped)
                           " 个文字对象：目标数字减小后小于 0，未修改。")))
        )
        (princ "\r\n[NU] 未选择文字对象。")
      )
    )
  )
  (princ)
)

;;; =======================================================================================
;;; 命令: KAI
;;; 功能: 将 TEXT/MTEXT 中由一个或多个空格分隔的内容劈开为多个独立文字；MTEXT 会先炸开为 TEXT 后处理。
;;; =======================================================================================
(defun aa:kai-remove-dxf (codes data / out item)
  (foreach item data
    (if (not (member (car item) codes))
      (setq out (cons item out))))
  (reverse out)
)

(defun aa:kai-space-p (ch)
  (= ch " ")
)

(defun aa:kai-split-spaces (str / len i ch in-word start parts)
  (setq len (strlen str)
        i 1
        in-word nil
        parts '())
  (while (<= i len)
    (setq ch (substr str i 1))
    (if (aa:kai-space-p ch)
      (if in-word
        (progn
          (setq parts (cons (list start (substr str start (- i start))) parts))
          (setq in-word nil)))
      (if (not in-word)
        (progn
          (setq start i)
          (setq in-word T))))
    (setq i (1+ i)))
  (if in-word
    (setq parts (cons (list start (substr str start (- i start))) parts)))
  (reverse parts)
)

(defun aa:kai-text-box (edata value / box)
  (textbox (subst (cons 1 value) (assoc 1 edata) edata))
)

(defun aa:kai-real-text-width (doc edata value / newdata en bbox width)
  (if (= value "")
    0.0
    (progn
      (setq newdata (aa:kai-remove-dxf '(-1 5 102 330 360) edata))
      (setq newdata (aa:kai-replace-pair 1 value newdata))
      (setq en (entmakex newdata))
      (if en
        (progn
          (setq bbox (aa:safe-get-bbox doc en))
          (setq width (if bbox (- (aa:bbox-right-x bbox) (aa:bbox-left-x bbox)) nil))
          (entdel en)
          (if width width 0.0))
        0.0))
  )
)

(defun aa:kai-prefix-width-real (doc edata prefix / marker marker-width total-width)
  (if (= prefix "")
    0.0
    (progn
      (setq marker "X"
            marker-width (aa:kai-real-text-width doc edata marker)
            total-width (aa:kai-real-text-width doc edata (strcat prefix marker)))
      (max 0.0 (- total-width marker-width))))
)

(defun aa:kai-text-left (edata value / box)
  (setq box (aa:kai-text-box edata value))
  (if box
    (car (car box))
    0.0)
)

(defun aa:kai-dxf-int (code data default / pair)
  (if (setq pair (assoc code data))
    (cdr pair)
    default)
)

(defun aa:kai-aligned-text-p (edata)
  (or (/= (aa:kai-dxf-int 72 edata 0) 0)
      (/= (aa:kai-dxf-int 73 edata 0) 0))
)

(defun aa:kai-base-point (edata / p)
  (if (and (aa:kai-aligned-text-p edata)
           (setq p (cdr (assoc 11 edata))))
    p
    (cdr (assoc 10 edata)))
)

(defun aa:kai-set-position (edata pt)
  (if (aa:kai-aligned-text-p edata)
    (aa:kai-replace-pair 11 pt edata)
    (aa:kai-replace-pair 10 pt edata))
)

(defun aa:kai-offset-point (pt dist ang)
  (list (+ (car pt) (* dist (cos ang)))
        (+ (cadr pt) (* dist (sin ang)))
        (if (caddr pt) (caddr pt) 0.0))
)

(defun aa:kai-adjust-left-by-bbox (doc en target-left / bbox dx)
  (if (and doc en target-left (setq bbox (aa:safe-get-bbox doc en)))
    (progn
      (setq dx (- target-left (aa:bbox-left-x bbox)))
      (if (equal dx 0.0 1e-8)
        T
        (aa:safe-move-entity en (vlax-3d-point (list dx 0.0 0.0)))))
    nil)
)

(defun aa:kai-replace-pair (code value data)
  (if (assoc code data)
    (subst (cons code value) (assoc code data) data)
    (append data (list (cons code value))))
)

(defun aa:kai-make-text (edata value pt / newdata)
  (setq newdata (aa:kai-remove-dxf '(-1 5 102 330 360) edata))
  (setq newdata (aa:kai-replace-pair 1 value newdata))
  (setq newdata (aa:kai-set-position newdata pt))
  (entmakex newdata)
)

(defun aa:kai-add-texts-after-explode (before after outss / cur ed typ added)
  (setq added 0)
  (if (and after (not (eq before after)))
    (progn
      (setq cur (entnext before))
      (while cur
        (setq ed  (entget cur)
              typ (if ed (cdr (assoc 0 ed)) nil))
        (if (= typ "TEXT")
          (progn
            (ssadd cur outss)
            (setq added (1+ added))))
        (if (eq cur after)
          (setq cur nil)
          (setq cur (entnext cur))))))
  added
)

(defun aa:kai-process-text (doc en / ed orig-ed str parts base ang first part prefix prefix-width offset pt made left0 orig-bbox orig-left target-left new-en)
  (setq ed (entget en)
        orig-ed ed
        str (cdr (assoc 1 ed))
        orig-bbox (aa:safe-get-bbox doc en)
        orig-left (if orig-bbox (aa:bbox-left-x orig-bbox) nil))
  (if (and str (wcmatch str "* *"))
    (progn
      (setq parts (aa:kai-split-spaces str))
      (if (> (length parts) 1)
        (progn
          (setq base (aa:kai-base-point ed)
                ang (cond ((cdr (assoc 50 ed))) (0.0))
                left0 (aa:kai-text-left ed str)
                first T
                made 0)
          (foreach part parts
            (setq prefix (if (> (car part) 1) (substr str 1 (1- (car part))) "")
                  prefix-width (aa:kai-prefix-width-real doc orig-ed prefix)
                  offset (- (+ left0 prefix-width)
                            (aa:kai-text-left orig-ed (cadr part)))
                  pt (aa:kai-offset-point base offset ang)
                  target-left (if orig-left (+ orig-left prefix-width) nil))
            (if first
              (progn
                (setq ed (subst (cons 1 (cadr part)) (assoc 1 ed) ed))
                (setq ed (aa:kai-set-position ed pt))
                (entmod ed)
                (entupd en)
                (aa:kai-adjust-left-by-bbox doc en target-left)
                (setq first nil
                      made (1+ made)))
              (progn
                (setq new-en (aa:kai-make-text orig-ed (cadr part) pt))
                (if new-en
                  (progn
                    (aa:kai-adjust-left-by-bbox doc new-en target-left)
                    (setq made (1+ made)))))))
          made)
        0))
    0)
)

(defun c:KAI (/ *error* doc undo-open oldcmdecho ss text-ss mtexts i en ed typ
                changed skipped made before after exploded)
  (vl-load-com)
  (setq doc (vla-get-ActiveDocument (vlax-get-acad-object))
        undo-open nil
        oldcmdecho nil
        text-ss (ssadd)
        mtexts '())

  (defun *error* (msg)
    (if oldcmdecho
      (setvar "CMDECHO" oldcmdecho))
    (if undo-open
      (vl-catch-all-apply 'vla-EndUndoMark (list doc)))
    (if (and msg
             (not (wcmatch (strcase msg) "*BREAK*,*CANCEL*,*EXIT*,*QUIT*")))
      (princ (strcat "\r\n[KAI] 错误: " msg)))
    (sssetfirst nil nil)
    (princ)
  )

  (setq ss (ssget "_I" '((0 . "TEXT,MTEXT"))))
  (if (null ss)
    (progn
      (princ "\r\n[KAI] 请选择要按空格拆分的 TEXT/MTEXT 文字: ")
      (setq ss (ssget "_:L" '((0 . "TEXT,MTEXT"))))))
  (if ss
    (progn
      (setq i 0
            changed 0
            skipped 0
            exploded 0)
      (repeat (sslength ss)
        (setq en  (ssname ss i)
              ed  (entget en)
              typ (if ed (cdr (assoc 0 ed)) nil))
        (cond
          ((= typ "TEXT")
           (ssadd en text-ss))
          ((= typ "MTEXT")
           (setq mtexts (cons en mtexts))))
        (setq i (1+ i)))

      (if (and (= (sslength text-ss) 0) (null mtexts))
        (princ "\r\n[KAI] 未选择 TEXT/MTEXT 文字。")
        (progn
          (setq oldcmdecho (getvar "CMDECHO"))
          (setvar "CMDECHO" 0)
          (vla-StartUndoMark doc)
          (setq undo-open T)

          (foreach en (reverse mtexts)
            (setq before (entlast))
            (command "_.EXPLODE" en)
            (setq after (entlast)
                  made (aa:kai-add-texts-after-explode before after text-ss))
            (if (> made 0)
              (setq exploded (+ exploded made))
              (setq skipped (1+ skipped))))

          (setq i 0)
          (repeat (sslength text-ss)
            (setq made (aa:kai-process-text doc (ssname text-ss i)))
            (if (> made 0)
              (setq changed (+ changed made))
              (setq skipped (1+ skipped)))
            (setq i (1+ i)))

          (vla-EndUndoMark doc)
          (setq undo-open nil)
          (setvar "CMDECHO" oldcmdecho)
          (setq oldcmdecho nil)
          (princ
            (strcat
              "\r\n[KAI] 已拆分文字: "
              (itoa changed)
              "，分解出的多行文字: "
              (itoa exploded)
              "，跳过对象: "
              (itoa skipped)
              ".")))))
    (princ "\r\n[KAI] 未选择 TEXT/MTEXT 文字。"))
  (princ)
)

;;; =======================================================================================
;;; Internal implementation formerly exposed as ZHENG.
;;; Purpose: Center selected TEXT/MTEXT on the midpoint X of one horizontal LINE.
;;;          With one rectangle and one or more texts, set middle-center justification
;;;          for each text, then align them horizontally to the rectangle center,
;;;          preserving each text's Y coordinate.
;;; =======================================================================================
(defun aa:zheng-horizontal-line-p (en tol / ed p1 p2 dx dy angle-tol)
  (setq ed (entget en)
        p1 (cdr (assoc 10 ed))
        p2 (cdr (assoc 11 ed))
        dx (if (and p1 p2) (abs (- (car p2) (car p1))) 0.0)
        dy (if (and p1 p2) (abs (- (cadr p2) (cadr p1))) 0.0)
        angle-tol (* (if (boundp '*UT_TiltAngle*) *UT_TiltAngle* 3.0)
                     (/ pi 180.0)))
  (and (= (cdr (assoc 0 ed)) "LINE")
       p1
       p2
       (> dx tol)
       (<= dy (* dx (/ (sin angle-tol) (cos angle-tol)))))
)

(defun aa:zheng-line-mid-x (en / ed p1 p2)
  (setq ed (entget en)
        p1 (cdr (assoc 10 ed))
        p2 (cdr (assoc 11 ed)))
  (/ (+ (car p1) (car p2)) 2.0)
)

(defun aa:zheng-add-texts-after-explode (before after outss / cur ed typ added)
  (setq added 0)
  (if (and after (not (eq before after)))
    (progn
      (setq cur (entnext before))
      (while cur
        (setq ed  (entget cur)
              typ (if ed (cdr (assoc 0 ed)) nil))
        (if (= typ "TEXT")
          (progn
            (ssadd cur outss)
            (setq added (1+ added))))
        (if (eq cur after)
          (setq cur nil)
          (setq cur (entnext cur))))))
  added
)

(defun aa:zheng-align-text-center-x (doc en base-x / bbox dx)
  (if (setq bbox (aa:safe-get-bbox doc en))
    (progn
      (setq dx (- base-x (aa:bbox-center-x bbox)))
      (if (equal dx 0.0 1e-8)
        T
        (aa:safe-move-entity en (vlax-3d-point (list dx 0.0 0.0))))))
)

(defun aa:zheng-align-text-to-rect-center (doc en rect-bbox / text-bbox dx)
  (if (and rect-bbox
           (aa:normalize-text-horizontal-align doc en 2)
           (setq text-bbox (aa:safe-get-bbox doc en)))
    (progn
      (setq dx (- (aa:bbox-center-x rect-bbox)
                  (aa:bbox-center-x text-bbox)))
      (if (equal dx 0.0 1e-8)
        T
        (aa:safe-move-entity en (vlax-3d-point (list dx 0.0 0.0)))))
    nil)
)

(defun c:ZHENG (/ *error* doc undo-open oldcmdecho ss i en ed typ line-ent rect-ent rect-count
                  rect-bbox text-ss mtexts text-count text-ent base-x before after made changed skipped)
  (vl-load-com)
  (setq doc (vla-get-ActiveDocument (vlax-get-acad-object))
        undo-open nil
        oldcmdecho nil
        line-ent nil
        rect-ent nil
        rect-count 0
        text-ss (ssadd)
        mtexts '()
        changed 0
        skipped 0)

  (defun *error* (msg)
    (if oldcmdecho
      (setvar "CMDECHO" oldcmdecho))
    (if undo-open
      (vl-catch-all-apply 'vla-EndUndoMark (list doc)))
    (if (and msg
             (not (wcmatch (strcase msg) "*BREAK*,*CANCEL*,*EXIT*,*QUIT*")))
      (princ (strcat "\r\n[ZHENG] 错误: " msg)))
    (sssetfirst nil nil)
    (princ)
  )

  (setq ss (ssget "_I" '((0 . "LINE,LWPOLYLINE,POLYLINE,TEXT,MTEXT"))))
  (if (null ss)
    (progn
      (princ "\r\n[ZHENG] 请选择水平直线和文字，或一个矩形和一个文字: ")
      (setq ss (ssget "_:L" '((0 . "LINE,LWPOLYLINE,POLYLINE,TEXT,MTEXT"))))))

  (if ss
    (progn
      (setq i 0)
      (repeat (sslength ss)
        (setq en  (ssname ss i)
              ed  (entget en)
              typ (if ed (cdr (assoc 0 ed)) nil))
        (cond
          ((and (= typ "LINE")
                (null line-ent)
                (aa:zheng-horizontal-line-p en 1e-6))
           (setq line-ent en))
          ((member typ '("LWPOLYLINE" "POLYLINE"))
           (setq rect-count (1+ rect-count))
           (if (null rect-ent)
             (setq rect-ent en)))
          ((= typ "TEXT")
           (ssadd en text-ss))
          ((= typ "MTEXT")
           (setq mtexts (cons en mtexts))))
        (setq i (1+ i)))

      (setq text-count (+ (sslength text-ss) (length mtexts)))
      (cond
        ((> rect-count 1)
         (princ "\r\n[ZHENG] 矩形居中模式请只选择一个矩形。"))
        ((= rect-count 1)
         (cond
           ((= text-count 0)
            (princ "\r\n[ZHENG] 矩形居中模式请至少选择一个 TEXT/MTEXT 文字。"))
           ((null (setq rect-bbox (aa:safe-get-bbox doc rect-ent)))
            (princ "\r\n[ZHENG] 无法读取矩形范围。"))
           (T
            (vla-StartUndoMark doc)
            (setq undo-open T)
            ;; 矩形模式逐个处理所有 TEXT/MTEXT，保持每个文字原有的 Y 坐标。
            (setq i 0)
            (repeat (sslength text-ss)
              (setq text-ent (ssname text-ss i))
              (if (aa:zheng-align-text-to-rect-center doc text-ent rect-bbox)
                (setq changed (1+ changed))
                (setq skipped (1+ skipped)))
              (setq i (1+ i)))
            (foreach text-ent (reverse mtexts)
              (if (aa:zheng-align-text-to-rect-center doc text-ent rect-bbox)
                (setq changed (1+ changed))
                (setq skipped (1+ skipped))))
            (vla-EndUndoMark doc)
            (setq undo-open nil)
            (princ
              (strcat
                "\r\n[ZHENG] 完成。文字已改为正中对正并水平对齐到矩形中心，竖直位置保持不变，已处理: "
                (itoa changed)
                "，跳过: "
                (itoa skipped)
                ".")))))
        ((null line-ent)
         (princ "\r\n[ZHENG] 选择中没有水平直线。"))
        ((= text-count 0)
         (princ "\r\n[ZHENG] 选择中没有 TEXT/MTEXT 文字。"))
        (T
         (setq base-x (aa:zheng-line-mid-x line-ent)
               oldcmdecho (getvar "CMDECHO"))
         (setvar "CMDECHO" 0)
         (vla-StartUndoMark doc)
         (setq undo-open T)

         (foreach en (reverse mtexts)
           (setq before (entlast))
           (command "_.EXPLODE" en)
           (setq after (entlast)
                 made (aa:zheng-add-texts-after-explode before after text-ss))
           (if (= made 0)
             (setq skipped (1+ skipped))))

         (setq i 0)
         (repeat (sslength text-ss)
           (if (aa:zheng-align-text-center-x doc (ssname text-ss i) base-x)
             (setq changed (1+ changed))
             (setq skipped (1+ skipped)))
           (setq i (1+ i)))

         (vla-EndUndoMark doc)
         (setq undo-open nil)
         (setvar "CMDECHO" oldcmdecho)
         (setq oldcmdecho nil)
         (princ
           (strcat
             "\r\n[ZHENG] 完成。基准 X: "
             (rtos base-x 2 4)
             "，已对齐文字: "
             (itoa changed)
             "，跳过: "
             (itoa skipped)
             ".")))))
    (princ "\r\n[ZHENG] 未选择对象。"))
  (sssetfirst nil nil)
  (princ)
)

(princ)

;;; =======================================================================================
;;; BEGIN IMPORT: 自动页码HAO.lsp
;;; Source: 小命令\自动页码HAO.lsp
;;; Imported on: 2026-05-13 17:04:20
;;; =======================================================================================

;;; ============================================================
;;; 自动页码 HAO
;;; 功能：批量填写图框属性 —— 页码（自动排序）+ 项目编号
;;; 排序方式：按Y轴从上到下，Y相同时按X从左到右
;;; 使用方法：加载后执行命令 HAO
;;; ============================================================

(vl-load-com)

;; ── 工具函数 ──────────────────────────────────────────────────

;; 判断实体是否为带属性的块参照
(defun is-attblock (ent / ed)
  (setq ed (entget ent))
  (and (= (cdr (assoc 0 ed)) "INSERT")
       (= (cdr (assoc 66 ed)) 1))   ; 66=1 表示有属性
)

;; 获取块参照的所有属性对象列表 (VLA object)
(defun get-att-objects (blk-obj / atts att-list)
  (setq atts (vlax-invoke blk-obj 'GetAttributes))
  atts
)

;; 读取属性对象的标记名（大写）
(defun att-tag (att-obj)
  (strcase (vlax-get-property att-obj 'TagString))
)

;; 写入属性值
(defun set-att-value (att-obj val)
  (vlax-put-property att-obj 'TextString val)
)

;; 获取块参照的插入点，返回普通 list (x y z)
;; InsertionPoint 返回的是 variant/safearray，必须用 vlax-safearray->list 转换
(defun blk-insertpt (blk-obj / raw)
  (setq raw (vlax-get-property blk-obj 'InsertionPoint))
  (vlax-safearray->list (vlax-variant-value raw))
)

;; ── 识别图框块 ────────────────────────────────────────────────

;; 判断一个块是否为图框：
;; 策略：检查属性标记中是否含有图号、档案号或页码等图框专属关键词，避免普通带属性块（如端子排）被误判
(defun is-frame-block (blk-obj / atts tag found blk-name)
  (setq blk-name (strcase (vl-catch-all-apply 'vlax-get-property (list blk-obj 'Name))))
  (if (vl-catch-all-error-p blk-name) (setq blk-name ""))
  ;; 显式排除常见非图框块名（如端子排、端子眉头等）
  (if (or (wcmatch blk-name "*端子*")
          (wcmatch blk-name "*TERMINAL*")
          (wcmatch blk-name "*眉头*"))
    nil
    (progn
      (setq atts (get-att-objects blk-obj)
            found nil)
      (foreach att atts
        (setq tag (att-tag att))
        (if (or (wcmatch tag "*图号*")
                (wcmatch tag "*档案号*")
                (wcmatch tag "*档案*")
                (wcmatch tag "*DWG*NO*")
                (wcmatch tag "*DRAWING*NO*")
                (wcmatch tag "*页码*")
                (wcmatch tag "*页次*")
                (wcmatch tag "*PAGE*"))
          (setq found T)
        )
        (vlax-release-object att)
      )
      found
    )
  )
)

;; ── 排序 ──────────────────────────────────────────────────────

;; 按Y从大到小（上到下），Y相同时按X从小到大（左到右）
;; 容差：Y差值小于 tolerance 视为同行
(defun sort-frames-by-position (frame-list / tolerance)
  (setq tolerance 100.0)  ; 单位与图纸一致，可根据需要调整
  (aa:merge-sort frame-list
    (function
      (lambda (a b / pa pb ya yb xa xb)
        (setq pa (blk-insertpt a)
              pb (blk-insertpt b)
              ya (cadr pa)
              yb (cadr pb)
              xa (car pa)
              xb (car pb))
        (if (< (abs (- ya yb)) tolerance)
          (< xa xb)          ; 同行：X小的在前
          (> ya yb)          ; 不同行：Y大的（靠上）在前
        )
      )
    )
  )
)

;; ── 属性标记匹配 ──────────────────────────────────────────────

;; 在属性列表中查找匹配关键词的属性对象
;; keywords: 标记关键词列表（大写），返回第一个匹配的 att-obj 或 nil
(defun find-att-by-keywords (atts keywords / result)
  (setq result nil)
  (foreach att atts
    (if (null result)
      (progn
        (setq tag (att-tag att))
        (foreach kw keywords
          (if (and (null result) (wcmatch tag kw))
            (setq result att)
          )
        )
      )
    )
  )
  result
)

;; ── 填写逻辑 ──────────────────────────────────────────────────

;; 页码属性的候选标记关键词（可扩展）
(defun page-keywords ()
  '("*页码*" "*页次*" "页" "*PAGE*")
)

;; 总页数属性的候选标记关键词
(defun total-page-keywords ()
  '("*总页*" "*共*页*" "*TOTAL*")
)

;; 档案号/图号属性的候选标记关键词
(defun proj-num-keywords ()
  '("*档案号*" "*档案*" "*图号*" "*DWG*NO*" "*DRAWING*NO*")
)

;; 比例属性的候选标记关键词
(defun scale-keywords ()
  '("*比例*" "*图纸比例*")
)

;; 填写单个图框
(defun fill-one-frame (blk-obj page-num total-pages archive-num scale-value / atts pg-att tp-att ar-att sc-att)
  (setq atts (get-att-objects blk-obj))

  ;; 查找并填写页码（若图框有独立页码属性则填写；无则静默跳过，不输出多余警告）
  (setq pg-att (find-att-by-keywords atts (page-keywords)))
  (if pg-att
    (set-att-value pg-att (itoa page-num))
  )

  ;; 查找并填写总页数
  (setq tp-att (find-att-by-keywords atts (total-page-keywords)))
  (if tp-att
    (set-att-value tp-att (itoa total-pages))
  )

  ;; 查找并填写档案号/图号（前缀 + 两位页码，如 135101 或 135100）
  (if (and archive-num (> (strlen archive-num) 0))
    (progn
      (setq ar-att (find-att-by-keywords atts (proj-num-keywords)))
      (if ar-att
        (set-att-value ar-att
          (strcat archive-num
                  (if (and (>= page-num 0) (< page-num 10)) "0" "")  ; 不足两位补前导零（支持 00~09）
                  (itoa page-num)))
        (princ (strcat "\r\n  [警告] 未找到图号/档案号属性，块名: "
                       (vlax-get-property blk-obj 'Name)))
      )
    )
  )

  ;; 查找并填写比例
  (if (and scale-value (> (strlen scale-value) 0))
    (progn
      (setq sc-att (find-att-by-keywords atts (scale-keywords)))
      (if sc-att
        (set-att-value sc-att scale-value)
        (princ (strcat "\r\n  [警告] 未找到比例属性，块名: "
                       (vlax-get-property blk-obj 'Name)))
      )
    )
  )

  ;; 刷新块显示
  (vlax-invoke blk-obj 'Update)
  (foreach att atts
    (vlax-release-object att))
)

;; ── 诊断功能 ──────────────────────────────────────────────────

;; ── 主命令：HAO ───────────────────────────────────────────────

;; 从选集中提取图框块 VLA 对象列表
(defun collect-frames-from-ss (ss / i ent blk result)
  (setq result '())
  (if ss
    (progn
      (setq i 0)
      (while (< i (sslength ss))
        (setq ent (ssname ss i)
              blk (vlax-ename->vla-object ent))
        (if (and (is-attblock ent) (is-frame-block blk))
          (setq result (cons blk result))
          (vlax-release-object blk)
        )
        (setq i (1+ i))
      )
    )
  )
  result
)

(defun fillframes-run (/ ss frames sorted archive-num scale-value start-page total-pages i pg)

  (princ "\r\n=== HAO：批量填写图框属性 ===")

  ;; 1. 让用户框选要处理的图框
  (princ "\r\n请选择要填写的图框块（框选或点选，回车确认）：")
  (setq ss (ssget '((0 . "INSERT") (66 . 1))))

  (if (null ss)
    (progn
      (princ "\r\n[取消] 未选择任何对象。\r\n")
      (exit)
    )
  )

  ;; 2. 从选集中筛选出图框块
  (setq frames (collect-frames-from-ss ss))

  (if (null frames)
    (progn
      (princ "\r\n[错误] 选中的对象中未识别到图框块。")
      (princ "\r\n提示：请确认图框属性标记是否包含图号、档案号或页码。\r\n")
      (exit)
    )
  )

  (princ (strcat "\r\n识别到 " (itoa (length frames)) " 个图框块"))

  ;; 3. 排序
  (setq sorted (sort-frames-by-position frames))
  (princ "，已按位置排序（从上到下，从左到右）。")

  ;; 4. 输入档案号
  (setq archive-num
    (getstring T "\r\n请输入档案号（直接回车跳过不填写）: "))

  ;; 5. 输入比例
  (setq scale-value
    (getstring T "\r\n请输入比例（直接回车跳过不填写）: "))

  ;; 6. 输入起始页码
  (setq start-page
    (getint "\r\n请输入起始页码（默认为1，直接回车使用默认值）: "))
  (if (null start-page) (setq start-page 1))

  ;; 7. 批量填写
  (setq i 0)
  (setq total-pages (length sorted))

  (princ "\r\n开始填写属性...")
  (foreach blk sorted
    (setq pg (+ start-page i))
    (princ (strcat "\r\n  第 " (itoa pg) " 页 → 块名: "
                   (vlax-get-property blk 'Name)
                   "  位置: ("
                   (rtos (car (blk-insertpt blk)) 2 0)
                   ", "
                   (rtos (cadr (blk-insertpt blk)) 2 0)
                   ")"))
    (fill-one-frame blk pg total-pages archive-num scale-value)
    (vlax-release-object blk)
    (setq i (1+ i))
  )

  ;; 8. 刷新视图
  (command "_.REGEN")

  (princ (strcat "\r\n=== 完成！共填写 " (itoa total-pages) " 个图框 ===\r\n"))
)

;;; 功能：选择块内属性文字，在自定义窗口中编辑并按回车直接保存。
(defun aae:clean-mtext-format (str keep-newline / idx len out ch next semi stack)
  ;; 过滤 MTEXT 控制符（字宽 \W、字高 \H、对齐 \A、颜色 \C、字体 \F、大括号等）
  ;; keep-newline: 为 T 时保留 \P 换行供拆行使用；为 nil 时去除所有格式与换行
  (if (or (null str) (= str ""))
    ""
    (progn
      (setq idx 1
            len (strlen str)
            out "")
      (while (<= idx len)
        (setq ch (substr str idx 1))
        (cond
          ((or (= ch "{") (= ch "}"))
           (setq idx (1+ idx)))
          ((/= ch "\\")
           (setq out (strcat out ch)
                 idx (1+ idx)))
          ((= idx len)
           (setq idx (1+ idx)))
          (T
           (setq next (substr str (1+ idx) 1))
           (cond
             ((or (= next "\\") (= next "{") (= next "}"))
              (setq out (strcat out next)
                    idx (+ idx 2)))
             ((= next "P")
              (if keep-newline
                (setq out (strcat out "\\P")))
              (setq idx (+ idx 2)))
             ;; \p 为段落格式码(缩进/对齐等，如 \pi23.89632;、\pxqc;)，参数到分号结束，
             ;; 不是换行，必须整段丢弃，否则会残留 "i23.89632;" 之类的垃圾字符
             ((= next "p")
              (setq semi (vl-string-search ";" str (+ idx 1)))
              (setq idx (if semi (+ semi 2) (+ idx 2))))
             ((= next "~")
              (setq out (strcat out " ")
                    idx (+ idx 2)))
             ((or (= next "L") (= next "l")
                  (= next "O") (= next "o")
                  (= next "K") (= next "k")
                  (= next "X") (= next "x"))
              (setq idx (+ idx 2)))
             ((= next "S")
              (setq semi (vl-string-search ";" str (+ idx 1)))
              (if semi
                (progn
                  (setq stack (substr str (+ idx 2) (- semi idx 1)))
                  (setq stack (aa:str-replace-all "#" "/" stack))
                  (setq stack (aa:str-replace-all "^" "/" stack))
                  (setq out (strcat out stack)
                        idx (+ semi 2)))
                (setq idx (+ idx 2))))
             ((or (= next "A") (= next "a")
                  (= next "C") (= next "c")
                  (= next "F") (= next "f")
                  (= next "H") (= next "h")
                  (= next "Q") (= next "q")
                  (= next "T") (= next "t")
                  (= next "W") (= next "w"))
              (setq semi (vl-string-search ";" str (+ idx 1)))
              (if semi
                (setq idx (+ semi 2))
                (setq idx (+ idx 2))))
             (T
              (setq out (strcat out next)
                    idx (+ idx 2)))
           )
          )
        )
      )
      out
    )
  )
)

(defun aae:split-lines (str / pos sep-len line1 line2)
  ;; 将字符串拆分为两行列表 (line1 line2)，并自动剔除所有格式控制码
  (if (or (null str) (= str ""))
    (list "" "")
    (progn
      (setq str (aae:clean-mtext-format str T)
            pos nil
            sep-len 0)
      (cond
        ((setq pos (vl-string-search "\\P" str)) (setq sep-len 2))
        ((setq pos (vl-string-search "\\p" str)) (setq sep-len 2))
        ((setq pos (vl-string-search "\r\n" str)) (setq sep-len 2))
        ((setq pos (vl-string-search "\n" str)) (setq sep-len 1))
        ((setq pos (vl-string-search " // " str)) (setq sep-len 4))
        ((setq pos (vl-string-search "//" str)) (setq sep-len 2))
      )
      (if pos
        (progn
          (setq line1 (substr str 1 pos)
                line2 (substr str (+ pos sep-len 1)))
          (list (aae:clean-mtext-format line1 nil)
                (aae:clean-mtext-format line2 nil))
        )
        (list (aae:clean-mtext-format str nil) "")
      )
    )
  )
)

(defun aae:resolve-val (tile-val cur-val orig-val is-changed)
  ;; 核心防呆：防止选中文本时按回车或确定触发 DCL 控件被意外置空的 Bug
  (cond
    ;; 1. get_tile 成功读到非空内容
    ((and tile-val (/= (vl-string-trim " \t\r\n" tile-val) ""))
     (vl-string-trim " \t\r\n" tile-val))
    ;; 2. get_tile 返回空，但实时跟踪变量 cur-val 有非空内容
    ((and cur-val (/= (vl-string-trim " \t\r\n" cur-val) ""))
     (vl-string-trim " \t\r\n" cur-val))
    ;; 3. 用户未曾进行修改操作（处于全选态直接按回车或点确定），回退到原始值
    ((not is-changed)
     (if orig-val (vl-string-trim " \t\r\n" orig-val) ""))
    ;; 4. 用户确实主动进行了清空操作
    (T "")
  )
)

(defun c:AAE (/ *error* aa:tag aa:doc aa:undo-open aa:old-cmdecho pick ent ed ss
                 dcl-path dcl-id dialog-result old-text new-text line1 line2 lines
                 vla-obj orig-line1 orig-line2 cur-line1 cur-line2
                 line1-changed line2-changed t1 t2)
  (aa:cmd-begin "AAE")
  (vl-load-com)
  (setq ss (ssget "_I" '((0 . "ATTRIB"))))
  (if ss
    (setq pick (list (ssname ss 0) nil))
    (setq pick (nentsel "\r\n选择要编辑的属性文字: "))
  )
  (if pick
    (progn
      (setq ent (car pick)
            ed  (entget ent))
      (if (= (cdr (assoc 0 ed)) "ATTRIB")
        (progn
          (setq vla-obj (vl-catch-all-apply 'vlax-ename->vla-object (list ent)))
          (if (and vla-obj (not (vl-catch-all-error-p vla-obj)))
            (setq old-text (vlax-get-property vla-obj 'TextString))
            (setq old-text (cdr (assoc 1 ed)))
          )
          (setq lines (aae:split-lines old-text)
                orig-line1 (car lines)
                orig-line2 (cadr lines)
                cur-line1  orig-line1
                cur-line2  orig-line2
                line1-changed nil
                line2-changed nil
                t1 nil
                t2 nil
                dcl-path (aae:locate-dcl)
                dcl-id   (if dcl-path (load_dialog dcl-path) 0))
          (if (and (> dcl-id 0) (new_dialog "aae_main" dcl-id))
            (progn
              (set_tile "line1" (if orig-line1 orig-line1 ""))
              (set_tile "line2" (if orig-line2 orig-line2 ""))
              (mode_tile "line1" 2)
              (action_tile "line1"
                "(progn (setq cur-line1 $value line1-changed T))")
              (action_tile "line2"
                "(progn (setq cur-line2 $value line2-changed T))")
              (action_tile "accept"
                "(progn (setq t1 (get_tile \"line1\") t2 (get_tile \"line2\")) (done_dialog 1))")
              (action_tile "cancel" "(done_dialog 0)")
              (setq dialog-result (start_dialog))
              (if (= dialog-result 1)
                (progn
                  (setq line1 (aae:resolve-val t1 cur-line1 orig-line1 line1-changed)
                        line2 (aae:resolve-val t2 cur-line2 orig-line2 line2-changed))
                  (if (> (strlen line2) 0)
                    (setq new-text (strcat line1 "\\P" line2))
                    (setq new-text line1)
                  )
                  ;; 优先通过 ActiveX 写入 TextString（完美支持多行属性与 \P 换行渲染）
                  (if (and vla-obj (not (vl-catch-all-error-p vla-obj)))
                    (progn
                      (vl-catch-all-apply 'vlax-put-property (list vla-obj 'TextString new-text))
                      (vl-catch-all-apply 'vla-update (list vla-obj))
                    )
                    (progn
                      (setq ed (entget ent))
                      (if (assoc 1 ed)
                        (entmod (subst (cons 1 new-text) (assoc 1 ed) ed))
                      )
                    )
                  )
                  (entupd ent)
                )
              )
            )
            (alert "找不到 AAE.dcl，请确认它与 AA整合版本.lsp 在同一目录。")
          )
          (if (and vla-obj (not (vl-catch-all-error-p vla-obj)))
            (vlax-release-object vla-obj)
          )
          (if (> dcl-id 0) (unload_dialog dcl-id))
        )
        (princ "\r\n所选对象不是块属性文字，请直接点选属性文字。")
      )
    )
  )
  ;; 编辑完成后清除双击动作传入的预选和高亮状态。
  (sssetfirst nil nil)
  (aa:cmd-end)
)

(defun aae:locate-dcl (/ p loadPath)
  ;; findfile 只搜索支持路径，因此补充当前 LISP 加载目录和项目目录。
  (setq p (findfile "AAE.dcl"))
  (if (not p)
    (progn
      (setq loadPath (if (and (boundp '*load-truename*)
                              (= (type *load-truename*) 'STR))
                       *load-truename*
                       nil))
      (if loadPath
        (setq p (strcat (vl-filename-directory loadPath) "\\AAE.dcl")))))
  (if (and p (findfile p))
    (findfile p)
    (if (findfile (strcat *ztf-project-dir* "\\AAE.dcl"))
      (findfile (strcat *ztf-project-dir* "\\AAE.dcl"))
      nil)))

(defun c:HAO (/ *error* aa:tag aa:doc aa:undo-open aa:old-cmdecho)
  (aa:cmd-begin "HAO")
  (fillframes-run)
  (aa:cmd-end)
)

;;; =======================================================================================
;;;              --- HAO2 命令: 块参照固定矩形框内批量居中填充图号 ---
;;; =======================================================================================

(defun hao2:format-num (n width / s)
  (setq s (itoa n))
  (while (< (strlen s) width)
    (setq s (strcat "0" s)))
  s
)

(defun hao2:block-name (blkObj / name eff)
  (setq name (vl-catch-all-apply 'vlax-get-property (list blkObj 'Name)))
  (if (vl-catch-all-error-p name) (setq name ""))
  (if (vlax-property-available-p blkObj 'EffectiveName)
    (progn
      (setq eff (vl-catch-all-apply 'vlax-get-property (list blkObj 'EffectiveName)))
      (if (and (not (vl-catch-all-error-p eff)) eff (/= eff ""))
        (setq name eff)
      )
    )
  )
  name
)

(defun hao2:sort-blocks (blkList / tol ptCache sorted rows row rowY item y result pa pb)
  ;; 优化：排序前一次性预取所有块的插入点到 ptCache，消除排序过程中 O(N·logN) 次 COM 跨进程调用
  (setq tol 100.0)
  ;; 预取插入点缓存：((blkObj x y) ...)
  (setq ptCache
        (mapcar (lambda (b / p) (setq p (blk-insertpt b)) (list b (car p) (cadr p)))
                blkList))
  ;; 第一步：按 Y 从大到小（上→下）排序，Y 相同时按 X 从小到大（左→右）
  (setq sorted
        (aa:merge-sort
          ptCache
          '(lambda (a b)
             (if (= (caddr a) (caddr b))
               (< (cadr a) (cadr b))
               (> (caddr a) (caddr b))
             )
           )
        )
  )
  ;; 第二步：按行分组（Y 差值超过容差则视为新行）
  (setq rows nil row nil rowY nil)
  (foreach item sorted
    (setq y (caddr item))
    (if (or (not rowY) (> (abs (- rowY y)) tol))
      (progn
        (if row (setq rows (append rows (list row))))
        (setq row (list item))
        (setq rowY y)
      )
      (setq row (append row (list item)))
    )
  )
  (if row (setq rows (append rows (list row))))
  ;; 第三步：行内按 X 从小到大重新排序，最终展平为 blkObj 列表
  (setq result nil)
  (foreach row rows
    (setq result
          (append
            result
            (mapcar 'car
              (aa:merge-sort row '(lambda (a b) (< (cadr a) (cadr b))))
            )
          )
    )
  )
  result
)

(defun zdml2:collect-all-texts (/ ss i ent ed typ val raw3 ins10 ins11 listAll)
  ;; 优化：完全去除 COM 调用，直接从 entget 结果读取文字内容（无跨进程开销）
  ;; TEXT:  group code 1 = TextString
  ;; MTEXT: group code 1 = 第一段；可能有多个 group 3（后续分段），需顺序拼接
  (setq ss (ssget "_X" '((0 . "TEXT,MTEXT"))))
  (setq listAll '())
  (if ss
    (progn
      (setq i 0)
      (repeat (sslength ss)
        (setq ent   (ssname ss i)
              ed    (entget ent)
              typ   (cdr (assoc 0 ed))
              ins10 (cdr (assoc 10 ed))
              ins11 (cdr (assoc 11 ed)))
        ;; 直接从 DXF 数据表取文字内容，不调用任何 COM 方法
        (setq val (cdr (assoc 1 ed)))
        (if (= typ "MTEXT")
          (progn
            ;; MTEXT 超长文字有多个 group 3（前续段），顺序拼接在 group 1 之前
            (setq raw3
                  (apply 'strcat
                    (mapcar 'cdr
                      (vl-remove-if-not '(lambda (x) (= (car x) 3)) ed))))
            (if (and raw3 (/= raw3 ""))
              (setq val (strcat raw3 (if val val "")))
            )
          )
        )
        (if (and val (> (strlen val) 0))
          (progn
            (setq val (tktj:clean-val val))
            (if (> (strlen val) 0)
              (setq listAll (cons (list ent val ins10 ins11) listAll))
            )
          )
        )
        (setq i (1+ i))
      )
    )
  )
  listAll
)
;;; ─── 空间分桶索引（X 轴分桶）──────────────────────────────────────────────────
;;; 当图框数量较多时，将全量文字按 X 坐标分桶，检索时只扫描覆盖目标矩形的桶，
;;; 将 O(N·M) 降至近似 O(N·M/K)，K = 桶数（32）。
;;; allTexts 格式：((ent val ins10 ins11) ...)，其中 ins10/ins11 为 (x y z) 或 nil

(defun zdml2:build-spatial-index (allTexts / buckets bucketCount minX maxX rangeX
                                              item ins10 ins11 px bIdx)
  ;; 返回 (bucketCount minX bucketWidth buckets)
  ;; buckets 是长度为 bucketCount 的向量（用关联表模拟，key=0..N-1）
  (setq bucketCount 32)
  (if (null allTexts)
    (list bucketCount 0.0 1.0 nil)
    (progn
      ;; 求全量 X 范围
      (setq minX 1e38  maxX -1e38)
      (foreach item allTexts
        (setq ins10 (caddr item)  ins11 (cadddr item))
        (if ins10
          (progn
            (setq px (car ins10))
            (if (< px minX) (setq minX px))
            (if (> px maxX) (setq maxX px))
          )
        )
        (if ins11
          (progn
            (setq px (car ins11))
            (if (< px minX) (setq minX px))
            (if (> px maxX) (setq maxX px))
          )
        )
      )
      (if (>= minX maxX) (setq maxX (+ minX 1.0)))
      (setq rangeX (- maxX minX))
      ;; 构建桶（每桶为 cons (bIdx . 元素列表)）
      (setq buckets nil)
      (foreach item allTexts
        (setq ins10 (caddr item)  ins11 (cadddr item)
              px    (if ins10 (car ins10) (if ins11 (car ins11) minX)))
        (setq bIdx (fix (* (/ (- px minX) rangeX) (1- bucketCount))))
        (if (< bIdx 0) (setq bIdx 0))
        (if (>= bIdx bucketCount) (setq bIdx (1- bucketCount)))
        ;; 将 item 追加到对应桶
        (setq buckets
              (cons
                (if (assoc bIdx buckets)
                  (cons bIdx (cons item (cdr (assoc bIdx buckets))))
                  (cons bIdx (list item))
                )
                (vl-remove-if '(lambda (b) (= (car b) bIdx)) buckets)
              )
        )
      )
      (list bucketCount minX (/ rangeX bucketCount) buckets)
    )
  )
)

(defun zdml2:query-rect-index (spatialIdx qMinX qMaxX / bucketCount minX bw buckets
                                                         bIdxLo bIdxHi result bIdx bucket)
  ;; 根据空间索引返回 X 坐标可能落在 [qMinX, qMaxX] 内的候选 items 列表
  ;; 调用方还需再做精确 Y/X 过滤
  (setq bucketCount (car spatialIdx)
        minX        (cadr spatialIdx)
        bw          (caddr spatialIdx)
        buckets     (cadddr spatialIdx))
  (if (null buckets)
    nil
    (progn
      (setq bIdxLo (fix (/ (- qMinX minX) bw)))
      (setq bIdxHi (fix (/ (- qMaxX minX) bw)))
      (if (< bIdxLo 0) (setq bIdxLo 0))
      (if (>= bIdxHi bucketCount) (setq bIdxHi (1- bucketCount)))
      ;; 多取一桶做边界安全（避免舍入误差漏选）
      (if (> bIdxLo 0) (setq bIdxLo (1- bIdxLo)))
      (if (< bIdxHi (1- bucketCount)) (setq bIdxHi (1+ bIdxHi)))
      (setq result nil)
      (setq bIdx bIdxLo)
      (while (<= bIdx bIdxHi)
        (setq bucket (assoc bIdx buckets))
        (if bucket
          (setq result (append result (cdr bucket)))
        )
        (setq bIdx (1+ bIdx))
      )
      result
    )
  )
)

;;; ─── hao2:find-existing-text-fast（优化版）──────────────────────────────────
(defun hao2:find-existing-text-fast (pt1 pt2 allTexts / minX maxX minY maxY found item ent ins10 ins11)
  (setq minX (min (car pt1) (car pt2))
        maxX (max (car pt1) (car pt2))
        minY (min (cadr pt1) (cadr pt2))
        maxY (max (cadr pt1) (cadr pt2)))
  (setq found nil)
  (foreach item allTexts
    (if (null found)
      (progn
        ;; 使用 car/caddr/cadddr 替代 nth，避免列表遍历
        (setq ent   (car item)
              ins10 (caddr item)
              ins11 (cadddr item))
        (cond
          ((and ins10
                (>= (car ins10) (- minX 1e-4))
                (<= (car ins10) (+ maxX 1e-4))
                (>= (cadr ins10) (- minY 1e-4))
                (<= (cadr ins10) (+ maxY 1e-4)))
           (setq found ent))
          ((and ins11
                (>= (car ins11) (- minX 1e-4))
                (<= (car ins11) (+ maxX 1e-4))
                (>= (cadr ins11) (- minY 1e-4))
                (<= (cadr ins11) (+ maxY 1e-4)))
           (setq found ent))
        )
      )
    )
  )
  found
)

(defun c:HAO2 (/ *error* aa:tag aa:doc aa:undo-open aa:old-cmdecho
                 baseEnt baseObj baseIns targetName
                 p1 p2 minX maxX minY maxY rectW rectH
                 dx1 dy1 dx2 dy2 cx-rel cy-rel
                 txtPrefix startNum numWidth
                 ss i blk blkList sorted targetCount allTexts
                 tgtIns tgtP1 tgtP2 tgtCenter
                 existEnt textH newStr txtObj res)
  (aa:cmd-begin "HAO2")
  (vl-load-com)

  ;; 1. 提示选择基准块参照
  (setq baseEnt (car (entsel "\r\n[HAO2] 请点击选择基准图框块参照: ")))
  (cond
    ((null baseEnt)
     (princ "\r\n[HAO2] 未选择对象，命令已退出。")
    )
    ((/= (cdr (assoc 0 (entget baseEnt))) "INSERT")
     (princ "\r\n[HAO2] 所选对象不是块参照，命令已退出。")
    )
    (T
     (setq baseObj (vlax-ename->vla-object baseEnt)
           baseIns (blk-insertpt baseObj)
           targetName (hao2:block-name baseObj))
     (vlax-release-object baseObj)

     ;; 2. 指定图号所在的矩形范围
     (princ "\r\n[HAO2] 请指定图号填充矩形的第一个角点: ")
     (setq p1 (getpoint))
     (if (null p1)
       (princ "\r\n[HAO2] 未指定角点，命令已退出。")
       (progn
         (princ "\r\n[HAO2] 请指定图号填充矩形的对角点: ")
         (setq p2 (getcorner p1))
         (if (null p2)
           (princ "\r\n[HAO2] 未指定对角点，命令已退出。")
           (progn
             (setq minX (min (car p1) (car p2))
                   maxX (max (car p1) (car p2))
                   minY (min (cadr p1) (cadr p2))
                   maxY (max (cadr p1) (cadr p2))
                   rectW (- maxX minX)
                   rectH (- maxY minY))
             (if (or (<= rectW 1e-4) (<= rectH 1e-4))
               (princ "\r\n[HAO2] 矩形尺寸过小，命令已退出。")
               (progn
                 ;; 计算相对于基准块插入点的相对偏移
                 (setq dx1 (- minX (car baseIns))
                       dy1 (- minY (cadr baseIns))
                       dx2 (- maxX (car baseIns))
                       dy2 (- maxY (cadr baseIns))
                       cx-rel (/ (+ dx1 dx2) 2.0)
                       cy-rel (/ (+ dy1 dy2) 2.0))

                 ;; 3. 输入编号规则
                 (setq txtPrefix (getstring T "\r\n[HAO2] 请输入图号前缀 (例如 D260020S-D0205-): "))
                 (setq startNum (getint "\r\n[HAO2] 请输入起始编号数字 <1>: "))
                 (if (null startNum) (setq startNum 1))
                 (setq numWidth (getint "\r\n[HAO2] 请输入编号位数 (不足补零，例如 2 位为 01) <2>: "))
                 (if (or (null numWidth) (< numWidth 1)) (setq numWidth 2))

                 ;; 4. 框选所有待填充的图框块
                 (princ (strcat "\r\n[HAO2] 请框选所有待处理的图框块 [块名: " targetName "]: "))
                 (setq ss (ssget (list '(0 . "INSERT"))))
                 (if (null ss)
                   (princ "\r\n[HAO2] 未选择图框块，命令已退出。")
                   (progn
                     (setq blkList '()
                           i 0)
                     (repeat (sslength ss)
                       (setq blk (vlax-ename->vla-object (ssname ss i)))
                       (if (= (strcase (hao2:block-name blk)) (strcase targetName))
                         (setq blkList (cons blk blkList))
                         (vlax-release-object blk)
                       )
                       (setq i (1+ i))
                     )

                     (if (null blkList)
                       (princ (strcat "\r\n[HAO2] 所选对象中未找到与基准块同名 [" targetName "] 的图框块。"))
                       (progn
                         ;; 5. 排序：从上到下，从左到右
                         (setq sorted (hao2:sort-blocks blkList)
                               targetCount (length sorted))
                         (princ (strcat "\r\n[HAO2] 成功识别并排序 " (itoa targetCount) " 个图框块，正在准备数据..."))

                         ;; 一次性预收集图纸中所有 TEXT/MTEXT，避免循环中重复全图扫描
                         (setq allTexts (zdml2:collect-all-texts))

                         ;; 6. 依次填充或更新图号
                         (setq i 0)
                         (foreach blk sorted
                           (setq tgtIns (blk-insertpt blk)
                                 tgtP1 (list (+ (car tgtIns) dx1) (+ (cadr tgtIns) dy1))
                                 tgtP2 (list (+ (car tgtIns) dx2) (+ (cadr tgtIns) dy2))
                                 tgtCenter (list (+ (car tgtIns) cx-rel) (+ (cadr tgtIns) cy-rel) (caddr tgtIns))
                                 newStr (strcat txtPrefix (hao2:format-num (+ startNum i) numWidth))
                                 existEnt (hao2:find-existing-text-fast tgtP1 tgtP2 allTexts))

                           (if existEnt
                             ;; 已存在文字：修改内容并重新校准为正中对正
                             (progn
                               (setq txtObj (vlax-ename->vla-object existEnt))
                               (vl-catch-all-apply 'vlax-put-property (list txtObj 'TextString newStr))
                               (if (= (cdr (assoc 0 (entget existEnt))) "TEXT")
                                 (progn
                                   (vl-catch-all-apply 'vla-put-Alignment (list txtObj 10)) ; Middle Center
                                   (vl-catch-all-apply 'vla-put-TextAlignmentPoint (list txtObj (vlax-3d-point tgtCenter)))
                                 )
                                 (progn
                                   (vl-catch-all-apply 'vla-put-AttachmentPoint (list txtObj 5)) ; Middle Center
                                   (vl-catch-all-apply 'vla-put-InsertionPoint (list txtObj (vlax-3d-point tgtCenter)))
                                 )
                               )
                               (vl-catch-all-apply 'vla-update (list txtObj))
                               (vlax-release-object txtObj)
                               (entupd existEnt)
                             )
                             ;; 不存在文字：直接在正中心创建单行文字
                             (progn
                               (setq textH (* rectH 0.55))
                               (if (< textH 2.5) (setq textH 3.0))
                               (setq txtObj
                                     (vla-AddText
                                       (tktj:current-space)
                                       newStr
                                       (vlax-3d-point tgtCenter)
                                       textH
                                     ))
                               (vla-put-Layer txtObj (getvar "CLAYER"))
                               (vla-put-StyleName txtObj (tktj:ensure-text-style))
                               (setq res (vl-catch-all-apply 'vla-put-Alignment (list txtObj 10))) ; acAlignmentMiddleCenter
                               (if (not (vl-catch-all-error-p res))
                                 (vl-catch-all-apply 'vla-put-TextAlignmentPoint (list txtObj (vlax-3d-point tgtCenter)))
                               )
                               (vl-catch-all-apply 'vla-put-ScaleFactor (list txtObj *TKTJ-TEXT-WIDTH-FACTOR*))
                               (vl-catch-all-apply 'vla-update (list txtObj))
                               (vlax-release-object txtObj)
                             )
                           )
                           (vlax-release-object blk)
                           (setq i (1+ i))
                         )
                         (princ (strcat "\r\n[HAO2] 处理完成！共填充/更新 " (itoa i) " 个图号。"))
                       )
                     )
                   )
                 )
               )
             )
           )
         )
       )
     )
    )
  )
  (aa:cmd-end)
)




;;; =======================================================================================
;;;              --- MING 命令: 按行列网格顺序，批量将单行文字填充到属性块图名中 ---
;;; =======================================================================================

(defun ming:find-title-attrib (blkObj / atts found match1 match2 tag)
  ;; 遍历属性块的属性，查找“图名”属性对象（优先“图名”/“图名1”，未选中的属性显式释放）
  (setq atts (vl-catch-all-apply 'vlax-invoke (list blkObj 'GetAttributes)))
  (if (and atts (not (vl-catch-all-error-p atts)))
    (progn
      (foreach att atts
        (setq tag (vl-catch-all-apply 'vlax-get-property (list att 'TagString)))
        (if (and tag (not (vl-catch-all-error-p tag)))
          (progn
            (setq tag (strcase (vl-string-trim " \t\r\n" tag)))
            (cond
              ;; 完全匹配“图名”或“图名1”
              ((or (= tag "图名") (= tag "图名1"))
               (if (null match1) (setq match1 att)))
              ;; 包含“图名”且不含“图号”
              ((and (wcmatch tag "*图名*") (not (wcmatch tag "*图号*")))
               (if (and (null match1) (null match2)) (setq match2 att)))
              ;; 英文候选属性名
              ((or (= tag "TITLE") (= tag "TITLE1") (= tag "SHEETNAME") (= tag "DWGNAME"))
               (if (and (null match1) (null match2)) (setq match2 att)))
            )
          )
        )
      )
      (setq found (if match1 match1 match2))
      ;; 显式释放未匹配的属性 COM 对象，防止内存泄漏
      (foreach att atts
        (if (not (equal att found))
          (vl-catch-all-apply 'vlax-release-object (list att))
        )
      )
      found
    )
    nil
  )
)

(defun ming:get-block-height (blkObj / minPt maxPt pMin pMax h)
  ;; 获取块包围盒高度，用于自适应计算行容差
  (setq minPt nil maxPt nil)
  (if (and (vlax-method-applicable-p blkObj 'GetBoundingBox)
           (not (vl-catch-all-error-p
                  (vl-catch-all-apply 'vla-GetBoundingBox (list blkObj 'minPt 'maxPt)))))
    (progn
      (setq pMin (vlax-safearray->list minPt)
            pMax (vlax-safearray->list maxPt))
      (setq h (abs (- (cadr pMax) (cadr pMin))))
      (if (> h 0.0) h 100.0)
    )
    100.0
  )
)

(defun ming:get-text-info (ent / ed typ val raw3 ins10 ins11 pt h)
  ;; 提取文字实体信息：(ent val x y height)
  (setq ed (entget ent)
        typ (cdr (assoc 0 ed))
        ins10 (cdr (assoc 10 ed))
        ins11 (cdr (assoc 11 ed))
        h (cdr (assoc 40 ed)))
  (if (or (null h) (<= h 0.0)) (setq h 3.5))
  ;; 坐标：非左对齐时优先使用 11 组码
  (if (and ins11 (not (equal ins11 '(0.0 0.0 0.0) 1e-6)))
    (setq pt ins11)
    (setq pt ins10)
  )
  ;; 文字内容清洗（兼容 MTEXT 格式码过滤）
  (setq val (cdr (assoc 1 ed)))
  (if (= typ "MTEXT")
    (progn
      (setq raw3 (apply 'strcat
                   (mapcar 'cdr
                     (vl-remove-if-not '(lambda (x) (= (car x) 3)) ed))))
      (if (and raw3 (/= raw3 ""))
        (setq val (strcat raw3 (if val val ""))))
      (setq val (tktj:clean-val val))
    )
    (if val (setq val (vl-string-trim " \t\r\n" val)) "")
  )
  (if (and pt val (> (strlen val) 0))
    (list ent val (car pt) (cadr pt) h)
    nil
  )
)

(defun ming:cluster-and-sort (items factor / totalH countH h tol sorted rows cur-row last-y itm y)
  ;; 自适应容差的行列网格聚类排序（单链相邻聚类）：
  ;; 1. 根据 items 的平均高度 * factor 计算自适应容差 tol
  ;; 2. 按 Y 降序（上→下）排序
  ;; 3. 按相邻图元 Y 差值 <= tol 进行平滑行聚类（消除整行累计微小倾斜误分行）
  ;; 4. 每行内按 X 升序（左→右）排序
  ;; 5. 返回 rows 列表，形如 ((item11 item12 ...) (item21 item22 ...) ...)
  (if (null items)
    nil
    (progn
      (setq totalH 0.0 countH 0)
      (foreach itm items
        (setq h (nth 4 itm))
        (if (and h (> h 0.0))
          (setq totalH (+ totalH h) countH (1+ countH))
        )
      )
      (setq tol (if (> countH 0)
                  (* (/ totalH countH) factor)
                  50.0))
      (if (< tol 0.5) (setq tol 5.0))
      ;; 按 Y 降序（从上到下）排序
      (setq sorted (aa:merge-sort items '(lambda (a b) (> (cadddr a) (cadddr b)))))
      (setq rows '()
            cur-row '()
            last-y nil)
      (foreach itm sorted
        (setq y (cadddr itm))
        (if (null last-y)
          (setq last-y y
                cur-row (list itm))
          (if (<= (abs (- last-y y)) tol)
            (setq cur-row (cons itm cur-row)
                  last-y y)
            (progn
              ;; 行内按 X 升序（从左到右）排序
              (setq rows (cons (aa:merge-sort cur-row '(lambda (a b) (< (caddr a) (caddr b)))) rows))
              (setq last-y y
                    cur-row (list itm))
            )
          )
        )
      )
      (if cur-row
        (setq rows (cons (aa:merge-sort cur-row '(lambda (a b) (< (caddr a) (caddr b)))) rows))
      )
      (reverse rows)
    )
  )
)

(defun c:MING (/ *error* aa:tag aa:doc aa:undo-open aa:old-cmdecho
                 ss ss-blk ss-txt i ent ed typ blkObj att pt h
                 blk-raw txt-raw blk-list txt-list
                 blk-rows txt-rows sorted-blks sorted-txts
                 n-blk n-txt n-fill idx blk-item txt-item target-att txt-val)
  (aa:cmd-begin "MING")
  (vl-load-com)

  ;; 1. 尝试从预选集或一次性框选中获取实体
  (setq ss (ssget "_I" '((0 . "INSERT,TEXT,MTEXT"))))
  (if (null ss)
    (progn
      (princ "\r\n[MING] 请框选属性块和单行文字 (可一次框选全部): ")
      (setq ss (ssget '((0 . "INSERT,TEXT,MTEXT"))))
    )
  )

  (setq blk-raw '()
        txt-raw '())

  (if ss
    (progn
      (setq i 0)
      (repeat (sslength ss)
        (setq ent (ssname ss i)
              ed  (entget ent)
              typ (cdr (assoc 0 ed)))
        (cond
          ((= typ "INSERT") (setq blk-raw (cons ent blk-raw)))
          ((or (= typ "TEXT") (= typ "MTEXT")) (setq txt-raw (cons ent txt-raw)))
        )
        (setq i (1+ i))
      )
    )
  )

  ;; 2. 如果缺少属性块或缺少文字，引导用户分别补选
  (if (null blk-raw)
    (progn
      (princ "\r\n[MING] 未选中属性块，请选择目标属性块参照: ")
      (setq ss-blk (ssget '((0 . "INSERT"))))
      (if ss-blk
        (progn
          (setq i 0)
          (repeat (sslength ss-blk)
            (setq blk-raw (cons (ssname ss-blk i) blk-raw))
            (setq i (1+ i))
          )
        )
      )
    )
  )

  (if (null txt-raw)
    (progn
      (princ "\r\n[MING] 未选中文字，请选择源文字 (单行文字): ")
      (setq ss-txt (ssget '((0 . "TEXT,MTEXT"))))
      (if ss-txt
        (progn
          (setq i 0)
          (repeat (sslength ss-txt)
            (setq txt-raw (cons (ssname ss-txt i) txt-raw))
            (setq i (1+ i))
          )
        )
      )
    )
  )

  ;; 3. 解析并筛选属性块（必须具有图名属性）
  (setq blk-list '())
  (foreach ent blk-raw
    (setq blkObj (vl-catch-all-apply 'vlax-ename->vla-object (list ent)))
    (if (and blkObj (not (vl-catch-all-error-p blkObj)))
      (progn
        (setq att (ming:find-title-attrib blkObj))
        (if att
          (progn
            (setq pt (blk-insertpt blkObj)
                  h  (ming:get-block-height blkObj))
            (setq blk-list (cons (list ent blkObj (car pt) (cadr pt) h att) blk-list))
          )
          ;; 无图名属性的块，释放其 VLA 对象
          (vl-catch-all-apply 'vlax-release-object (list blkObj))
        )
      )
    )
  )

  ;; 4. 解析单行/多行文字
  (setq txt-list '())
  (foreach ent txt-raw
    (setq txt-item (ming:get-text-info ent))
    (if txt-item
      (setq txt-list (cons txt-item txt-list))
    )
  )

  ;; 5. 校验结果
  (cond
    ((null blk-list)
     (princ "\r\n[MING] 错误：未找到含有【图名】属性的块参照，操作已取消。")
    )
    ((null txt-list)
     ;; 释放已保留的属性和块对象
     (foreach b blk-list
       (vl-catch-all-apply 'vlax-release-object (list (nth 5 b)))
       (vl-catch-all-apply 'vlax-release-object (list (nth 1 b)))
     )
     (princ "\r\n[MING] 错误：未找到有效文字内容，操作已取消。")
    )
    (T
     ;; 6. 执行自适应行列排序
     (setq blk-rows (ming:cluster-and-sort blk-list 0.3)
           txt-rows (ming:cluster-and-sort txt-list 1.0))
     (setq sorted-blks (apply 'append blk-rows)
           sorted-txts (apply 'append txt-rows))

     (setq n-blk (length sorted-blks)
           n-txt (length sorted-txts)
           n-fill (min n-blk n-txt))

     (princ (strcat "\r\n[MING] 识别到图名属性块 " (itoa n-blk) " 个 (分 " (itoa (length blk-rows)) " 行)，"
                    "文字 " (itoa n-txt) " 个 (分 " (itoa (length txt-rows)) " 行)。"))

     (if (/= n-blk n-txt)
       (princ (strcat "\r\n[MING] 提示：属性块数 (" (itoa n-blk) ") 与文字数 (" (itoa n-txt) ") 不一致，按顺序填充前 " (itoa n-fill) " 个。"))
     )

     ;; 7. 按网格排序顺序一一对应填充
     (setq idx 0)
     (while (< idx n-fill)
       (setq blk-item   (nth idx sorted-blks)
             txt-item   (nth idx sorted-txts)
             target-att (nth 5 blk-item)
             txt-val    (nth 1 txt-item))

       ;; 直接将文字写入图名属性（作为单行完整更新）
       (vl-catch-all-apply 'vlax-put-property (list target-att 'TextString txt-val))
       (vl-catch-all-apply 'vla-update (list target-att))
       (vl-catch-all-apply 'vla-update (list (nth 1 blk-item)))
       (entupd (car blk-item))

       ;; 释放 COM 对象
       (vl-catch-all-apply 'vlax-release-object (list target-att))
       (vl-catch-all-apply 'vlax-release-object (list (nth 1 blk-item)))

       (setq idx (1+ idx))
     )

     ;; 若块数量多于文字数量，释放剩余块的 COM 句柄
     (while (< idx n-blk)
       (setq blk-item (nth idx sorted-blks))
       (vl-catch-all-apply 'vlax-release-object (list (nth 5 blk-item)))
       (vl-catch-all-apply 'vlax-release-object (list (nth 1 blk-item)))
       (setq idx (1+ idx))
     )

     (princ (strcat "\r\n[MING] 成功将 " (itoa n-fill) " 个文字填充到对应属性块的【图名】属性中！"))
    )
  )

  (sssetfirst nil nil)
  (aa:cmd-end)
)




;;; =======================================================================================
;;;              --- FIVE 命令: 将测得高度按比例缩放为 5 ---
;;; =======================================================================================

(defun c:FIVE (/ *error* aa:tag aa:doc aa:undo-open aa:old-cmdecho p1 p2 a b ss base)
  (aa:cmd-begin "FIVE")
  (setvar "CMDECHO" 0)

  (setq p1 (getpoint "\r\nFIVE - 请点取当前格子高度的第一个点: "))
  (if p1
    (progn
      (setq p2 (getpoint p1 "\r\n请点取当前格子高度的第二个点: "))
      (if p2
        (progn
          (setq a (distance p1 p2))
          (if (> a 1e-8)
            (progn
              (setq b (/ 5.0 a))
              (princ (strcat "\r\n当前高度 A = " (rtos a 2 4) "，缩放比例 B = " (rtos b 2 6)))
              (princ "\r\n请选择要缩放的对象，完成后按回车或空格确认: ")
              (setq ss (ssget))
              (if ss
                (progn
                  (setq base (getpoint "\r\n请点取缩放基点: "))
                  (if base
                    (progn
                      (command "_.SCALE" ss "" base b)
                      (princ "\r\nFIVE 完成：已按比例缩放，测得高度将变为 5。")
                    )
                    (princ "\r\n未点取基点，FIVE 已取消。")
                  )
                )
                (princ "\r\n未选择对象，FIVE 已取消。")
              )
            )
            (princ "\r\n两点距离过小，FIVE 已取消。")
          )
        )
        (princ "\r\n未点取第二个点，FIVE 已取消。")
      )
    )
    (princ "\r\n未点取第一个点，FIVE 已取消。")
  )

  (aa:cmd-end)
)

;;; END IMPORT: 自动页码HAO.lsp

;;; =======================================================================================
;;;              --- JZ 命令: 矩形水平中线对齐到两条直线中心线 ---
;;; =======================================================================================

(defun aa:jz-line-center-y (ename / ed p1 p2)
  (if (and ename
           (setq ed (entget ename))
           (= (cdr (assoc 0 ed)) "LINE"))
    (progn
      (setq p1 (cdr (assoc 10 ed))
            p2 (cdr (assoc 11 ed)))
      (/ (+ (cadr p1) (cadr p2)) 2.0)
    )
  )
)

(defun c:JZ (/ *error* doc undo-open obj-ss rect-ss text-ss i en typ rect-count text-count
             rect-en rect-bbox line-ss line-count line1 line2 y1 y2 target-y target-x
             moved failed bbox center-y delta-y center-x delta-x)
  (vl-load-com)
  (setq doc (vla-get-activedocument (vlax-get-acad-object))
        undo-open nil)

  (defun *error* (msg)
    (if undo-open
      (vl-catch-all-apply 'vla-endundomark (list doc))
    )
    (if (and msg
             (not (wcmatch (strcase msg) "*BREAK*,*CANCEL*,*EXIT*,*QUIT*")))
      (princ (strcat "\r\n[JZ] 错误: " msg))
    )
    (princ)
  )

  (princ "\r\n[JZ] 请选择一个矩形对象，可同时选择需要放到矩形正中间的文字，完成后按空格或回车确认: ")
  (setq obj-ss (ssget '((0 . "LWPOLYLINE,POLYLINE,TEXT,MTEXT"))))
  (cond
    ((null obj-ss)
     (princ "\r\n[JZ] 未选择矩形或文字，命令取消。"))
    (T
     (setq rect-ss (ssadd)
           text-ss (ssadd)
           i       0)
     (repeat (sslength obj-ss)
       (setq en  (ssname obj-ss i)
             typ (cdr (assoc 0 (entget en))))
       (cond
         ((or (= typ "LWPOLYLINE") (= typ "POLYLINE"))
          (ssadd en rect-ss))
         ((or (= typ "TEXT") (= typ "MTEXT"))
          (ssadd en text-ss))
       )
       (setq i (1+ i))
     )
     (setq rect-count (sslength rect-ss)
           text-count (sslength text-ss))
     (cond
       ((> rect-count 1)
        (princ "\r\n[JZ] 请只选择一个矩形对象。"))
       ((and (= rect-count 0) (= text-count 0))
        (princ "\r\n[JZ] 未选择可处理的矩形或文字，命令取消。"))
       (T
        (if (= rect-count 1)
          (setq rect-en   (ssname rect-ss 0)
                rect-bbox (aa:safe-get-bbox doc rect-en))
        )
        (if (and (= rect-count 1) (null rect-bbox))
          (princ "\r\n[JZ] 无法读取矩形范围，命令取消。")
          (progn
            (princ "\r\n[JZ] 请选择两条直线，完成后按空格或回车确认: ")
            (setq line-ss (ssget '((0 . "LINE"))))
            (cond
              ((null line-ss)
               (princ "\r\n[JZ] 未选择直线，命令取消。"))
              (T
               (setq line-count (sslength line-ss))
               (cond
                 ((= line-count 1)
                  (setq line1 (ssname line-ss 0)
                        y1 (aa:jz-line-center-y line1)
                        y2 y1))
                 ((>= line-count 2)
                  (setq line1 (ssname line-ss 0)
                        line2 (ssname line-ss 1)
                        y1 (aa:jz-line-center-y line1)
                        y2 (aa:jz-line-center-y line2)))
                 (T
                  (setq y1 nil
                        y2 nil))
               )
               (if (and y1 y2)
                 (progn
                   (setq target-y (/ (+ y1 y2) 2.0)
                         target-x (if rect-bbox (aa:bbox-center-x rect-bbox))
                         moved    0
                         failed   0)
                   (vla-startundomark doc)
                   (setq undo-open T)
                   (if (= rect-count 1)
                     (progn
                       (setq center-y (/ (+ (aa:bbox-top-y rect-bbox)
                                            (aa:bbox-bottom-y rect-bbox))
                                         2.0)
                             delta-y  (- target-y center-y))
                       (if (or (equal delta-y 0.0 1e-8)
                               (aa:safe-move-entity rect-en (vlax-3d-point (list 0.0 delta-y 0.0))))
                         (setq moved (1+ moved))
                         (setq failed (1+ failed))
                       )
                     )
                   )
                   (setq i 0)
                   (repeat text-count
                     (setq en   (ssname text-ss i)
                           bbox (aa:safe-get-bbox doc en))
                     (if bbox
                       (progn
                         (setq center-y (/ (+ (aa:bbox-top-y bbox)
                                              (aa:bbox-bottom-y bbox))
                                           2.0)
                               center-x (aa:bbox-center-x bbox)
                               delta-y  (- target-y center-y)
                               delta-x  (if target-x (- target-x center-x) 0.0))
                         (if (or (and (equal delta-x 0.0 1e-8)
                                      (equal delta-y 0.0 1e-8))
                                 (aa:safe-move-entity en (vlax-3d-point (list delta-x delta-y 0.0))))
                           (setq moved (1+ moved))
                           (setq failed (1+ failed))
                         )
                       )
                       (setq failed (1+ failed))
                     )
                     (setq i (1+ i))
                   )
                   (vla-endundomark doc)
                   (setq undo-open nil)
                   (princ
                     (strcat
                       "\r\n[JZ] 完成：已居中 "
                       (itoa moved)
                       " 个对象"
                       (if (> failed 0)
                         (strcat "，失败 " (itoa failed) " 个。")
                         "。")
                     )
                   )
                 )
                 (princ "\r\n[JZ] 无法读取直线中心位置，命令取消。")
               )
              )
            )
          )
        )
       )
     )
    )
  )
  (princ)
)


;;; =======================================================================================
;;; FDX 命令: 连续选择文字并依次分配到预选方框
;;; =======================================================================================

;;; FDX: frame records are (left bottom right top elevation), in current UCS.
(defun fdx:rect-from-points (pts / prev p xs ys z lx ly rx ry ok seen)
  (if (and (> (length pts) 4) (equal (car pts) (last pts) 1e-6))
    (setq pts (reverse (cdr (reverse pts)))))
  (if (= (length pts) 4)
    (progn
      (setq xs (mapcar 'car pts) ys (mapcar 'cadr pts)
            lx (apply 'min xs) rx (apply 'max xs)
            ly (apply 'min ys) ry (apply 'max ys)
            z (caddr (car pts)) prev (last pts)
            ok (and (> (- rx lx) 1e-6) (> (- ry ly) 1e-6)))
      (foreach p pts
        (if (not (and (not (vl-some '(lambda (q) (equal p q 1e-6)) seen))
                      (equal (caddr p) z 1e-6)
                      (or (equal (car p) lx 1e-6) (equal (car p) rx 1e-6))
                      (or (equal (cadr p) ly 1e-6) (equal (cadr p) ry 1e-6))
                      (not (equal p prev 1e-6))
                      (or (equal (car p) (car prev) 1e-6)
                          (equal (cadr p) (cadr prev) 1e-6))))
          (setq ok nil))
        (setq prev p seen (cons p seen)))
      (if ok (list lx ly rx ry z)))))

(defun fdx:poly-rect (en / ed typ pts pair z next vd ok)
  (setq ed (entget en) typ (cdr (assoc 0 ed)) ok T)
  (if (and (aa:zz-poly-closed-p ed)
           (= 0 (logand (cdr (assoc 70 ed)) 126)))
    (progn
      (if (= typ "LWPOLYLINE")
        (progn
          (setq z (cond ((cdr (assoc 38 ed))) (T 0.0)))
          (foreach pair ed
            (cond
              ((= (car pair) 42) (if (not (equal (cdr pair) 0.0 1e-10)) (setq ok nil)))
              ((= (car pair) 10)
               (setq pts (cons (trans (trans (list (cadr pair) (caddr pair) z) en 0) 0 1) pts))))))
        (progn
          (setq z (caddr (cdr (assoc 10 ed))) next (entnext en))
          (while (and next (= (cdr (assoc 0 (setq vd (entget next)))) "VERTEX"))
            (if (and (assoc 42 vd) (not (equal (cdr (assoc 42 vd)) 0.0 1e-10))) (setq ok nil))
            (setq pair (cdr (assoc 10 vd))
                  pts (cons (trans (trans (list (car pair) (cadr pair) z) en 0) 0 1) pts)
                  next (entnext next)))))
      (if ok (fdx:rect-from-points (reverse pts))))))

;;; =======================================================================================
;;; FKX: 点框内空白处选内容，自动排除右下角标题栏。
;;; 搜索仅使用当前视图附近的 _C 选择集；坐标和矩形均为当前 UCS。
;;; =======================================================================================
(defun fkx:point-in-p (pt rect tol)
  (and (> (car pt) (+ (nth 0 rect) tol))
       (> (cadr pt) (+ (nth 1 rect) tol))
       (< (car pt) (- (nth 2 rect) tol))
       (< (cadr pt) (- (nth 3 rect) tol))))

(defun fkx:area (rect)
  (* (- (nth 2 rect) (nth 0 rect)) (- (nth 3 rect) (nth 1 rect))))

(defun fkx:choose-frame (rects pt / best rect)
  (foreach rect rects
    (if (and (fkx:point-in-p pt rect 1e-6)
             (or (null best) (< (fkx:area rect) (fkx:area best))))
      (setq best rect)))
  best)

(defun fkx:overlap-p (box rect tol)
  (and (<= (car (car box)) (+ (nth 2 rect) tol))
       (>= (car (cadr box)) (- (nth 0 rect) tol))
       (<= (cadr (car box)) (+ (nth 3 rect) tol))
       (>= (cadr (cadr box)) (- (nth 1 rect) tol))))

(defun fkx:inside-p (box rect tol)
  (and (fkx:point-in-p (car box) rect tol)
       (fkx:point-in-p (cadr box) rect tol)))

(defun fkx:box (en / obj result box lo hi pts x y z)
  ;; 只读包围盒；转换 WCS 的八角到 UCS，保守包络后再判定。
  (vl-load-com)
  (setq result (vl-catch-all-apply 'vlax-ename->vla-object (list en)))
  (if (not (vl-catch-all-error-p result))
    (progn
      (setq obj result box (aa:try-get-bbox obj))
      (vlax-release-object obj)
      (if box
        (progn
          (setq lo (car box) hi (cadr box))
          (foreach x (list (car lo) (car hi))
            (foreach y (list (cadr lo) (cadr hi))
              (foreach z (list (caddr lo) (caddr hi))
                (setq pts (cons (trans (list x y z) 0 1) pts)))))
          (list (list (apply 'min (mapcar 'car pts))
                      (apply 'min (mapcar 'cadr pts)))
                (list (apply 'max (mapcar 'car pts))
                      (apply 'max (mapcar 'cadr pts)))))))))

(defun fkx:collect (ss / i en ed typ box items tops p q)
  ;; 缓存每个对象的包围盒和文字，只读取一次。tops 为实际水平直线。
  (setq i 0)
  (if ss
    (repeat (sslength ss)
      (setq en (ssname ss i) ed (entget en) typ (cdr (assoc 0 ed)))
      (if (setq box (fkx:box en))
        (setq items (cons (list en typ box
                               (if (member typ '("TEXT" "MTEXT" "ATTDEF"))
                                 (aa:ysdl-get-plain-text ed) "")) items)))
      (if (= typ "LINE")
        (progn
          (setq p (trans (cdr (assoc 10 ed)) 0 1)
                q (trans (cdr (assoc 11 ed)) 0 1))
          (if (and (equal (cadr p) (cadr q) 1e-6)
                   (equal (caddr p) (caddr q) 1e-6))
            (setq tops (cons (list (min (car p) (car q)) (cadr p)
                                   (max (car p) (car q))) tops)))))
      (setq i (1+ i))))
  (list (reverse items) tops))

(defun fkx:label-kind (text / value)
  (setq value (strcase text))
  (cond
    ((or (vl-string-search "图样名称" value) (vl-string-search "图纸名称" value)
         (vl-string-search "图名" value) (vl-string-search "DWG NAME" value)
         (vl-string-search "DRAWING TITLE" value)) 1)
    ((or (vl-string-search "图样代号" value) (vl-string-search "图号" value)
         (vl-string-search "DWG NO" value) (vl-string-search "DRAWING NO" value)) 2)))

(defun fkx:title-rect (rect items tops / w h edge cut name-found no-found item box center kind best)
  ;; 右下角长横线 + 两种独立标题字段共同确认；不依赖图层、句柄或固定坐标。
  (setq w (- (nth 2 rect) (nth 0 rect)) h (- (nth 3 rect) (nth 1 rect)))
  (foreach edge tops
    (if (and (equal (nth 2 edge) (nth 2 rect) 1e-4)
             (> (nth 0 edge) (nth 0 rect))
             (>= (- (nth 2 edge) (nth 0 edge)) (* w 0.2))
             (<= (- (nth 2 edge) (nth 0 edge)) (* w 0.85))
             (> (nth 1 edge) (+ (nth 1 rect) 1e-4))
             (<= (- (nth 1 edge) (nth 1 rect)) (* h 0.35)))
      (progn
        (setq cut (list (nth 0 edge) (nth 1 rect) (nth 2 rect) (nth 1 edge))
              name-found nil no-found nil)
        (foreach item items
          (setq box (nth 2 item)
                center (list (/ (+ (car (car box)) (car (cadr box))) 2.0)
                             (/ (+ (cadr (car box)) (cadr (cadr box))) 2.0)))
          (if (fkx:point-in-p center cut -1e-4)
            (progn
              (setq kind (fkx:label-kind (nth 3 item)))
              (if (equal kind 1) (setq name-found T))
              (if (equal kind 2) (setq no-found T)))))
        (if (and name-found no-found
                 (or (null best) (> (fkx:area cut) (fkx:area best))))
          (setq best cut)))))
  best)

(defun fkx:filter (items rect title / ss item tol)
  (setq ss (ssadd) tol (max 1e-6 (* 1e-8 (min (- (nth 2 rect) (nth 0 rect))
                                             (- (nth 3 rect) (nth 1 rect))))))
  (foreach item items
    (if (and (fkx:inside-p (nth 2 item) rect tol)
             (not (fkx:overlap-p (nth 2 item) title 1e-4)))
      (ssadd (car item) ss)))
  ss)

;;; 命令: FKX
;;; 功能: 单击框内空白处选择内部对象，自动排除图框和右下角标题栏；支持手动指定范围。
(defun c:FKX (/ *error* aa:tag aa:doc aa:undo-open aa:old-cmdecho
               pt nearby radius screen rects i en rect title cache items tops
               picked p1 p2 z ss e1 e2)
  (aa:cmd-begin "FKX")
  (sssetfirst nil nil)
  (princ "\r\n[FKX] 请完整显示目标图框，并在正文空白处点一下；自动排除右下角标题栏。")
  (setq pt (getpoint "\r\n点取方框内空白处 <回车手动选框>: "))
  (if pt
    (progn
      (setq screen (getvar "SCREENSIZE")
            radius (* (getvar "VIEWSIZE") (max 1.0 (/ (car screen) (float (cadr screen)))))
            nearby (ssget "_C" (list (- (car pt) radius) (- (cadr pt) radius) (caddr pt))
                               (list (+ (car pt) radius) (+ (cadr pt) radius) (caddr pt))
                               '((0 . "LWPOLYLINE,POLYLINE")))
            i 0)
      (if nearby
        (repeat (sslength nearby)
          (setq en (ssname nearby i))
          (if (setq rect (fdx:poly-rect en))
            (setq rects (fdx:add-rect rect rects)))
          (setq i (1+ i))))
      (setq rect (fkx:choose-frame rects pt))
      (if (null rect)
        (princ "\r\n未找到包含该点、沿当前 UCS 的闭合矩形。请完整显示图框，或回车使用手动方式。")))
    (progn
      (setq picked (entsel "\r\n点选闭合矩形边框 <回车指定两个对角点>: "))
      (if picked
        (if (member (cdr (assoc 0 (entget (car picked)))) '("LWPOLYLINE" "POLYLINE"))
          (setq rect (fdx:poly-rect (car picked))))
        (progn
          (setq p1 (getpoint "\r\n指定第一个角点: "))
          (if (and p1 (setq p2 (getcorner p1 "\r\n指定对角点: ")))
            (progn
              (setq z (caddr p1))
              (setq rect (fdx:rect-from-points
                           (list (list (car p1) (cadr p1) z)
                                 (list (car p2) (cadr p1) z)
                                 (list (car p2) (cadr p2) z)
                                 (list (car p1) (cadr p2) z))))))))
      (if (null rect) (princ "\r\n未指定有效矩形，FKX 已取消。"))))
  (if rect
    (progn
      (setq cache (fkx:collect (ssget "_C" (list (nth 0 rect) (nth 1 rect) (nth 4 rect))
                                          (list (nth 2 rect) (nth 3 rect) (nth 4 rect))))
            items (car cache) tops (cadr cache)
            title (fkx:title-rect rect items tops))
      (if (null title)
        (progn
          (princ "\r\n未可靠识别标题栏，请指定标题栏的两个角点；回车取消本次选择。")
          (setq e1 (getpoint "\r\n标题栏第一个角点: "))
          (if (and e1 (setq e2 (getcorner e1 "\r\n标题栏对角点: ")))
            (setq title (list (min (car e1) (car e2)) (min (cadr e1) (cadr e2))
                              (max (car e1) (car e2)) (max (cadr e1) (cadr e2)))))
          (if (and title (or (<= (- (nth 2 title) (nth 0 title)) 1e-6)
                             (<= (- (nth 3 title) (nth 1 title)) 1e-6)))
            (setq title nil))))
      (cond
        ((null title) (princ "\r\n未确定排除范围，本次未生成选择集。"))
        ((and pt (fkx:point-in-p pt title -1e-4))
         (princ "\r\n点击位置位于标题栏内，请在正文空白处重试。"))
        (T
         (setq ss (fkx:filter items rect title))
         (if (> (sslength ss) 0)
           (progn
             (sssetfirst nil ss)
             (princ (strcat "\r\nFKX 已选择 " (itoa (sslength ss))
                            " 个正文对象，已排除图框、压边/跨框对象和标题栏。"))
             (if (= (getvar "PICKFIRST") 0)
               (princ "\r\nPICKFIRST=0：请设 PICKFIRST=1 后重跑 FKX，再使用筛选结果。")))
           (princ "\r\n未找到可选正文对象。"))))))
  (aa:cmd-end)
  (princ))


(defun fdx:add-rect (rect rects / found other)
  (foreach other rects (if (equal rect other 1e-6) (setq found T)))
  (if found rects (cons rect rects)))

(defun fdx:line-rects (vs hs / rects top sides v left right bottom best remaining candidates floor-y)
  ;; Only the selected edges participate; adjacent verticals define each cell.
  (setq remaining (aa:merge-sort hs '(lambda (a b) (> (car a) (car b)))))
  (while remaining
    (setq top (car remaining) remaining (cdr remaining))
    (setq sides nil)
    (foreach v vs
      (if (and (equal (nth 3 v) (nth 3 top) 1e-6)
               (<= (cadr v) (- (car top) 1e-6))
               (>= (caddr v) (- (car top) 1e-6))
               (>= (car v) (- (cadr top) 1e-6))
               (<= (car v) (+ (caddr top) 1e-6)))
        (setq sides (cons v sides))))
    (setq sides (aa:merge-sort sides '(lambda (a b)
                   (if (= (car a) (car b)) (< (cadr a) (cadr b)) (< (car a) (car b))))))
    (setq left nil)
    (foreach right sides
      (if (and left (> (- (car right) (car left)) 1e-6))
        (progn
          (setq best nil candidates remaining floor-y (max (cadr left) (cadr right)))
          (while (and candidates (null best) (>= (caar candidates) (- floor-y 1e-6)))
            (setq bottom (car candidates) candidates (cdr candidates))
            (if (and (equal (nth 3 bottom) (nth 3 top) 1e-6)
                     (< (car bottom) (- (car top) 1e-6))
                     (>= (car bottom) (- floor-y 1e-6))
                     (<= (cadr bottom) (+ (car left) 1e-6))
                     (>= (caddr bottom) (- (car right) 1e-6))
                     (or (null best) (> (car bottom) best)))
              (setq best (car bottom))))
          (if best
            (setq rects (fdx:add-rect (list (car left) best (car right) (car top) (nth 3 top)) rects)))))
      (if (or (null left) (> (- (car right) (car left)) 1e-6)) (setq left right))))
  rects)

(defun fdx:frames (ss / i en ed typ rect rects p q vs hs)
  (setq i 0)
  (repeat (sslength ss)
    (setq en (ssname ss i) ed (entget en) typ (cdr (assoc 0 ed)))
    (cond
      ((member typ '("LWPOLYLINE" "POLYLINE"))
       (if (setq rect (fdx:poly-rect en)) (setq rects (fdx:add-rect rect rects))))
      ((= typ "LINE")
       (setq p (trans (cdr (assoc 10 ed)) 0 1) q (trans (cdr (assoc 11 ed)) 0 1))
       (if (equal (caddr p) (caddr q) 1e-6)
         (cond
           ((and (equal (car p) (car q) 1e-6) (> (abs (- (cadr p) (cadr q))) 1e-6))
            (setq vs (cons (list (car p) (min (cadr p) (cadr q)) (max (cadr p) (cadr q)) (caddr p)) vs)))
           ((and (equal (cadr p) (cadr q) 1e-6) (> (abs (- (car p) (car q))) 1e-6))
            (setq hs (cons (list (cadr p) (min (car p) (car q)) (max (car p) (car q)) (caddr p)) hs)))))))
    (setq i (1+ i)))
  (foreach rect (fdx:line-rects vs hs) (setq rects (fdx:add-rect rect rects)))
  rects)

(defun fdx:sort-frames (rects / sorted out band anchor tol rect)
  (setq sorted (aa:merge-sort rects '(lambda (a b) (> (nth 3 a) (nth 3 b)))))
  (while sorted
    (setq rect (car sorted) sorted (cdr sorted) band (list rect)
          anchor (nth 3 rect)
          tol (* 0.1 (- (nth 3 rect) (cadr rect))))
    (while (and sorted (<= (abs (- (nth 3 (car sorted)) anchor)) tol))
      (setq band (cons (car sorted) band) sorted (cdr sorted)))
    (setq band (aa:merge-sort band '(lambda (a b) (< (car a) (car b)))))
    (foreach rect band (setq out (cons rect out))))
  (reverse out))

(defun fdx:show-frame (rect / pts p prev z)
  (setq z (nth 4 rect)
        pts (list (list (car rect) (cadr rect) z) (list (nth 2 rect) (cadr rect) z)
                  (list (nth 2 rect) (nth 3 rect) z) (list (car rect) (nth 3 rect) z))
        prev (last pts))
  (foreach p pts (grdraw prev p 3 1) (setq prev p)))

(defun fdx:restore (records / ed failed result)
  (foreach ed records
    (setq result (vl-catch-all-apply 'entmod (list ed)))
    (if (or (vl-catch-all-error-p result) (null result)) (setq failed T)))
  (not failed))

(defun fdx:shift-data (ed delta / offset pair typ code)
  (setq typ (cdr (assoc 0 ed))
        offset (if (= typ "TEXT") (trans delta 0 (cdr (assoc -1 ed)) T) delta))
  (foreach code (if (= typ "TEXT") '(10 11) '(10))
    (if (setq pair (assoc code ed))
      (setq ed (subst (cons code (mapcar '+ (cdr pair) offset)) pair ed))))
  ed)

(defun fdx:arrange (doc ss rect / corners low high z group i p)
  ;; Use the known destination frame, avoiding another selection or spatial search.
  (setq z (nth 4 rect)
        corners (mapcar '(lambda (p) (trans p 1 0))
          (list (list (car rect) (cadr rect) z) (list (nth 2 rect) (cadr rect) z)
                (list (nth 2 rect) (nth 3 rect) z) (list (car rect) (nth 3 rect) z)))
        low (car corners) high (car corners) i 0)
  (foreach p corners (setq low (mapcar 'min low p) high (mapcar 'max high p)))
  (repeat (sslength ss)
    (setq group (cons (list (ssname ss i) 0.0 0.0
                           (car low) (car high) (cadr high) (cadr low)) group)
          i (1+ i)))
  (dx:apply-group doc (reverse group)))

(defun fdx:place (ss rect / i en ed obj bbox low high records bad center target delta result ok)
  ;; Save original data before horizontal normalization; pending belongs to c:FDX.
  (setq i 0 ok T)
  (repeat (sslength ss)
    (setq en (ssname ss i) ed (entget en)
          obj (vl-catch-all-apply 'vlax-ename->vla-object (list en)))
    (if (or (vl-catch-all-error-p obj)
            (/= 0 (logand 4 (cdr (assoc 70 (tblsearch "LAYER" (cdr (assoc 8 ed))))))))
      (setq bad T)
      (if (setq bbox (aa:try-get-bbox obj))
        (setq low (if low (mapcar 'min low (car bbox)) (car bbox))
              high (if high (mapcar 'max high (cadr bbox)) (cadr bbox))
              records (cons ed records))
        (setq bad T)))
    (if (and obj (not (vl-catch-all-error-p obj)))
      (vlax-release-object obj))
    (setq i (1+ i)))
  (if bad
    (progn (princ "\r\n[FDX] 本批有锁层文字或无法读取的文字，整批未移动，请重新选择。") nil)
    (progn
      ;; Same zero-angle rule as command 0, without interactive selection or nested undo.
      ;; MTEXT uses the last direction/rotation field, so append 50 after its direction.
      (setq pending records low nil high nil)
      (foreach ed records
        (if ok
          (progn
            (setq en (cdr (assoc -1 ed))
                  result (vl-catch-all-apply 'entmod
                    (list (append (vl-remove (assoc 50 ed) ed) (list (cons 50 0.0))))))
            (if (or (vl-catch-all-error-p result) (null result))
              (setq ok nil)
              (progn
                ;; Geometry is read immediately below, so refresh this entity now.
                (entupd en)
                (setq obj (vl-catch-all-apply 'vlax-ename->vla-object (list en)))
                (if (vl-catch-all-error-p obj)
                  (setq ok nil)
                  (progn
                    (if (setq bbox (aa:try-get-bbox obj))
                      (setq low (if low (mapcar 'min low (car bbox)) (car bbox))
                            high (if high (mapcar 'max high (cadr bbox)) (cadr bbox)))
                      (setq ok nil))
                    (vlax-release-object obj))))))))
      (if ok
        (progn
          (setq center (mapcar '(lambda (a b) (/ (+ a b) 2.0)) low high)
                target (trans (list (/ (+ (car rect) (nth 2 rect)) 2.0)
                                    (/ (+ (cadr rect) (nth 3 rect)) 2.0) (nth 4 rect)) 1 0)
                delta (mapcar '- target center)
                pending records)
          (foreach ed records
            (if ok
              (progn
                (setq result (vl-catch-all-apply 'entmod (list (fdx:shift-data (entget (cdr (assoc -1 ed))) delta))))
                (if (or (vl-catch-all-error-p result) (null result)) (setq ok nil)))))
          (if ok
            (progn
              (setq result (vl-catch-all-apply 'fdx:arrange (list aa:doc ss rect)))
              (cond
                ((vl-catch-all-error-p result)
                 (setq ok nil)
                 (princ (strcat "\r\n[FDX] 自动排列错误: " (vl-catch-all-error-message result))))
                ((> (nth 3 result) 0)
                 (setq ok nil)
                 (princ "\r\n[FDX] 本批文字按 DX 排列后超出方框，请减少本批文字或调整字号。"))
                ((> (cadr result) 0) (setq ok nil))
                ((> (caddr result) 0)
                 (princ (strcat "\r\n[FDX] " (itoa (caddr result)) " 个文字未参与 DX 排列，保留整组移动后的位置。"))))))))
      (if (not ok)
        (if (fdx:restore pending)
          (princ "\r\n[FDX] 移动或排列未完成，已恢复本批文字，当前方框不前进。")
          (progn (princ "\r\n[FDX] 恢复失败，请退出后用 U 撤销本轮分配。") (exit))))
      (setq pending nil)
      (redraw)
      ok)))

(defun c:FDX (/ *error* aa:doc aa:undo-open frames-ss frames texts index total assigned running pending)
  (vl-load-com)
  (defun *error* (msg)
    (if (and pending (not (fdx:restore pending)))
      (princ "\r\n[FDX] 本批恢复失败，请用 U 撤销本轮分配。"))
    (aa:undo-mark-off)
    (redraw)
    (if (and msg (not (wcmatch (strcase msg) "*CANCEL*,*QUIT*,*EXIT*,*BREAK*")))
      (princ (strcat "\r\n[FDX] 错误: " msg)))
    (princ))
  (setq frames-ss (ssget "_I" '((0 . "LINE,LWPOLYLINE,POLYLINE"))))
  (sssetfirst nil nil)
  (if (null frames-ss)
    (progn
      (princ "\r\n[FDX] 先选择所有目标方框，按空格确认: ")
      (setq frames-ss (ssget '((0 . "LINE,LWPOLYLINE,POLYLINE"))))))
  (if (and frames-ss (setq frames (fdx:frames frames-ss)))
    (progn
      (setq frames (fdx:sort-frames frames)
            total (length frames) index 1 assigned 0 running T)
      (princ (strcat "\r\n[FDX] 已识别 " (itoa total) " 个方框；每批文字选好后按空格，空选回车或 Esc 结束。"))
      (while (and frames running)
        (redraw)
        (fdx:show-frame (car frames))
        (princ (strcat "\r\n[FDX] 第 " (itoa index) "/" (itoa total) " 框：选择本批文字 <结束>: "))
        (setq texts (ssget '((0 . "TEXT,MTEXT"))))
        (if texts
          (progn
            (if (not aa:undo-open) (aa:undo-mark-on))
            (if (fdx:place texts (car frames))
              (progn
                (setq assigned (+ assigned (sslength texts)) frames (cdr frames) index (1+ index))
                (princ "\r\n[FDX] 已分配并按 DX 规则处理。"))))
          (setq running nil)))
      (aa:undo-mark-off)
      (redraw)
      (princ (strcat "\r\n[FDX] 完成 " (itoa (1- index)) " 个方框，移动 " (itoa assigned) " 个文字；一次 U 可撤销本轮分配。")))
    (princ "\r\n[FDX] 未找到方框。请选择与当前 UCS 轴平行的闭合矩形多段线或完整直线框。"))
  (princ))

;;; DX 命令: 批量整理方格内的端子号、原理号和终点柜文字
(defun dx:true-color-rgb (value / r g b)
  (setq r (fix (/ value 65536))
        g (fix (/ (- value (* r 65536)) 256))
        b (- value (* r 65536) (* g 256)))
  (list r g b)
)

(defun dx:effective-color (en / ed aci layer-ed tc)
  (setq ed  (entget en)
        tc  (cdr (assoc 420 ed))
        aci (cdr (assoc 62 ed)))
  (cond
    (tc (list 'RGB (dx:true-color-rgb tc)))
    ((and aci (/= aci 0) (/= aci 256)) (list 'ACI (abs aci)))
    (T
     (setq layer-ed (tblsearch "LAYER" (cdr (assoc 8 ed))))
     (cond
       ((cdr (assoc 420 layer-ed))
        (list 'RGB (dx:true-color-rgb (cdr (assoc 420 layer-ed)))))
       ((cdr (assoc 62 layer-ed))
        (list 'ACI (abs (cdr (assoc 62 layer-ed)))))
       (T (list 'ACI 7)))))
)

(defun dx:color-kind (en / color mode value)
  (setq color (dx:effective-color en)
        mode  (car color)
        value (cadr color))
  (cond
    ((and (= mode 'ACI) (= value 7)) 'WHITE)
    ((and (= mode 'ACI) (= value 4)) 'CYAN)
    ((and (= mode 'RGB)
          (>= (car value) 245)
          (>= (cadr value) 245)
          (>= (caddr value) 245))
     'WHITE)
    ((and (= mode 'RGB)
          (<= (car value) 20)
          (>= (cadr value) 235)
          (>= (caddr value) 235))
     'CYAN)
    (T nil))
)

(defun dx:text-string (en / ed typ obj value)
  (setq ed  (entget en)
        typ (cdr (assoc 0 ed)))
  (cond
    ((= typ "TEXT") (cdr (assoc 1 ed)))
    ((= typ "MTEXT")
     (setq obj   (vlax-ename->vla-object en)
           value (vl-catch-all-apply 'vla-get-TextString (list obj)))
     (vlax-release-object obj)
     (if (vl-catch-all-error-p value) "" value))
    (T ""))
)

(defun dx:has-hanzi-p (s / codes b found)
  ;; 兼容历史 GBK 数据字节和 LISPSYS Unicode 码点。
  (setq codes (vl-string->list (if s s ""))
        found nil)
  (while (and codes (not found))
    (setq b (car codes))
    (cond
      ((and (>= b 19968) (<= b 40959))
       (setq found T))
      ((and (>= b 176) (<= b 247) (cdr codes)
            (>= (cadr codes) 64) (<= (cadr codes) 254)
            (/= (cadr codes) 127))
       (setq found T
             codes (cdr codes))))
    (setq codes (cdr codes)))
  found
)

(defun dx:item-from-info (doc info / en bbox)
  (setq en   (car info)
        bbox (aa:safe-get-bbox doc en))
  (if bbox
    (list en
          (aa:bbox-center-x bbox)
          (/ (+ (aa:bbox-top-y bbox) (aa:bbox-bottom-y bbox)) 2.0)
          (- (aa:bbox-right-x bbox) (aa:bbox-left-x bbox))
          (- (aa:bbox-top-y bbox) (aa:bbox-bottom-y bbox))
          bbox))
)

(defun dx:insert-y-desc (item items)
  (cond
    ((null items) (list item))
    ((> (nth 2 item) (nth 2 (car items))) (cons item items))
    (T (cons (car items) (dx:insert-y-desc item (cdr items)))))
)

(defun dx:sort-y-desc (items / out item)
  (aa:merge-sort items '(lambda (a b) (> (nth 2 a) (nth 2 b))))
)

(defun dx:pair-rows (terminals principles / result)
  ;; 两列分别从上到下排序后按序号配对，数量不等时仅末尾留空。
  (while (or terminals principles)
    (setq result (cons (list (car terminals) (car principles)) result)
          terminals (cdr terminals)
          principles (cdr principles)))
  (reverse result)
)

(defun dx:max-item-value (items index / result item value)
  (setq result 0.0)
  (foreach item items
    (setq value (nth index item))
    (if (> value result) (setq result value)))
  result
)

(defun dx:move-item-center (item tx ty)
  (aa:zz-move-text (nth 0 item) (nth 1 item) (nth 2 item) tx ty)
)

(defun dx:apply-group (doc group / info item kind text terminals principles destinations ignored
                       rows terminal-w principle-w destination-w max-h hgap vgap total-h total-w
                       top-y left-x i y target-x moved failed destination row-data row overflow)
  (setq terminals    nil
        principles   nil
        destinations nil
        ignored      0
        moved        0
        failed       0)
  (foreach info group
    (setq item (dx:item-from-info doc info)
          kind (dx:color-kind (car info))
          text (dx:text-string (car info)))
    (cond
      ((null item) (setq ignored (1+ ignored)))
      ((and (member kind '(WHITE CYAN)) (dx:has-hanzi-p text))
       (setq destinations (cons item destinations)))
      ((= kind 'WHITE) (setq terminals (cons item terminals)))
      ((= kind 'CYAN)
       (setq principles (cons item principles)))
      (T (setq ignored (1+ ignored)))))
  (setq terminals     (dx:sort-y-desc terminals)
        principles    (dx:sort-y-desc principles)
        destinations  (dx:sort-y-desc destinations)
        row-data      (dx:pair-rows terminals principles)
        rows          (max (length row-data) 1)
        terminal-w    (dx:max-item-value terminals 3)
        principle-w   (dx:max-item-value principles 3)
        destination-w (dx:max-item-value destinations 3)
        max-h         (max (dx:max-item-value terminals 4)
                           (dx:max-item-value principles 4)
                           (dx:max-item-value destinations 4)
                           1.0)
        hgap          (max 2.0 (* max-h 0.80))
        vgap          (max 1.0 (* max-h 0.55))
        destination-w (if destinations
                        (+ (apply '+ (mapcar '(lambda (x) (nth 3 x)) destinations))
                           (* (1- (length destinations)) hgap)) 0.0)
        total-h       (+ (* rows max-h) (* (1- rows) vgap))
        total-w       (+ terminal-w
                         (if (and (> terminal-w 0.0) (> principle-w 0.0)) hgap 0.0)
                         principle-w
                          (if (and destinations (or terminals principles)) hgap 0.0)
                         destination-w)
        left-x        (- (/ (+ (nth 3 (car group)) (nth 4 (car group))) 2.0)
                         (/ total-w 2.0))
        top-y         (+ (/ (+ (nth 5 (car group)) (nth 6 (car group))) 2.0)
                         (/ total-h 2.0)
                         (- (/ max-h 2.0))))
  (setq overflow (or (> total-w (- (nth 4 (car group)) (nth 3 (car group)) 2.0))
                     (> total-h (- (nth 5 (car group)) (nth 6 (car group)) 2.0))))
  (if overflow
    (list 0 0 (+ ignored (length terminals) (length principles) (length destinations)) 1)
    (progn
  (setq i 0)
  (while (< i rows)
    (setq y (- top-y (* i (+ max-h vgap))))
    (setq row (nth i row-data))
    (if (car row)
      (progn
        (setq item (car row))
        (if (dx:move-item-center item (+ left-x (/ (nth 3 item) 2.0)) y)
          (setq moved (1+ moved))
          (setq failed (1+ failed)))))
    (if (cadr row)
      (progn
        (setq item (cadr row)
              target-x (+ left-x terminal-w
                          (if (> terminal-w 0.0) hgap 0.0)
                          (/ (nth 3 item) 2.0)))
        (if (dx:move-item-center item target-x y)
          (setq moved (1+ moved))
          (setq failed (1+ failed)))))
    (setq i (1+ i)))
  (if destinations
    (progn
      (setq y (- top-y (* (1- rows) (+ max-h vgap)))
            target-x (+ left-x terminal-w
                        (if (and (> terminal-w 0.0) (> principle-w 0.0)) hgap 0.0)
                        principle-w
                         (if (or terminals principles) hgap 0.0)))
      (foreach destination destinations
        (if (dx:move-item-center destination (+ target-x (/ (nth 3 destination) 2.0)) y)
          (setq moved (1+ moved))
          (setq failed (1+ failed)))
        (setq target-x (+ target-x (nth 3 destination) hgap)))))
  (list moved failed ignored 0)))
)

(defun c:DX (/ *error* doc aa:doc aa:undo-open ss text-ss i en info infos groups group result
              moved failed skipped tol rect-tol overflow-count line-ss spatial-index)
  (vl-load-com)
  (setq doc            (vla-get-ActiveDocument (vlax-get-acad-object))
        aa:undo-open   nil
        overflow-count 0
        moved          0
        failed         0
        skipped        0
        tol            1e-8
        rect-tol       0.1
        line-ss        nil
        spatial-index  nil)

  (defun *error* (msg)
    (aa:undo-mark-off)
    (if (and msg
             (not (wcmatch (strcase msg) "*BREAK*,*CANCEL*,*EXIT*,*QUIT*")))
      (princ (strcat "\r\n[DX] 错误: " msg)))
    (sssetfirst nil nil)
    (princ))

  (setq ss (ssget "_I"))
  (if (null ss)
    (progn
      (princ "\r\n[DX] 请框选需要整理的方格和文字: ")
      (setq ss (ssget))))

  (cond
    ((null ss) (princ "\r\n[DX] 未选择对象。"))
    (T
     (setq text-ss (aa:zz-filter-text-ss ss))
     (if (= (sslength text-ss) 0)
       (princ "\r\n[DX] 选择中没有 TEXT/MTEXT 文字。")
       (progn
         (setq i             0
               infos         nil
               line-ss       (aa:zz-harvest-lines doc text-ss ss)
               spatial-index (aa:zz-build-spatial-index line-ss tol))
         (repeat (sslength text-ss)
           (setq en   (ssname text-ss i)
                 info (aa:zz-text-info doc en tol spatial-index))
           (if info
             (setq infos (cons info infos))
             (setq skipped (1+ skipped)))
           (setq i (1+ i)))
         (setq groups (aa:zz-group-by-rect (reverse infos) rect-tol))
         (aa:undo-mark-on)
         (foreach group groups
           (setq result         (dx:apply-group doc group)
                 moved          (+ moved (car result))
                 failed         (+ failed (cadr result))
                 skipped        (+ skipped (caddr result))
                 overflow-count (+ overflow-count (nth 3 result))))
         (aa:undo-mark-off)
         (redraw)
         (princ
           (strcat "\r\n[DX] 完成：整理 "
                   (itoa (- (length groups) overflow-count))
                   " 个方格，处理 "
                   (itoa moved)
                   " 个文字"
                   (if (> skipped 0) (strcat "，跳过 " (itoa skipped) " 个") "")
                   (if (> failed 0) (strcat "，失败 " (itoa failed) " 个") "")
                   (if (> overflow-count 0)
                     (strcat "，空间不足，保留原位 " (itoa overflow-count) " 个方格") "")
                   "。"))))))
  (sssetfirst nil nil)
  (princ)
)

;;; =======================================================================================
;;; =======================================================================================
;;; DX2 命令: 按方格和视觉位置导出文字到剪贴板
;;; =======================================================================================

(defun dx2:group-record (group index / info)
  (setq info (car group))
  (list group
        (/ (+ (nth 3 info) (nth 4 info)) 2.0)
        (/ (+ (nth 5 info) (nth 6 info)) 2.0)
        (nth 3 info)
        (nth 4 info)
        (nth 5 info)
        (nth 6 info)
        index)
)

(defun dx2:group-before-p (a b / ay by ax bx ah bh row-tol)
  (setq ay      (nth 2 a)
        by      (nth 2 b)
        ax      (nth 1 a)
        bx      (nth 1 b)
        ah      (- (nth 5 a) (nth 6 a))
        bh      (- (nth 5 b) (nth 6 b))
        row-tol (* 0.25 (min ah bh)))
  (if (<= (abs (- ay by)) row-tol)
    (if (equal ax bx 1e-8)
      (< (nth 7 a) (nth 7 b))
      (< ax bx))
    (> ay by))
)

(defun dx2:insert-group (item items)
  (cond
    ((null items) (list item))
    ((dx2:group-before-p item (car items)) (cons item items))
    (T (cons (car items) (dx2:insert-group item (cdr items)))))
)

(defun dx2:sort-groups (groups / records index group)
  (setq records nil
        index   0)
  (foreach group groups
    (setq records (cons (dx2:group-record group index) records)
          index   (1+ index)))
  (aa:merge-sort (reverse records) 'dx2:group-before-p)
)

(defun dx2:text-record (doc info index / item text)
  (setq item (dx:item-from-info doc info)
        text (dx:text-string (car info)))
  (if (and item text (> (strlen text) 0))
    (list text
          (nth 1 item)
          (nth 2 item)
          (nth 3 item)
          (nth 4 item)
          index))
)

(defun dx2:insert-y-desc (item items)
  (cond
    ((null items) (list item))
    ((> (nth 2 item) (nth 2 (car items))) (cons item items))
    ((and (equal (nth 2 item) (nth 2 (car items)) 1e-8)
          (< (nth 5 item) (nth 5 (car items))))
     (cons item items))
    (T (cons (car items) (dx2:insert-y-desc item (cdr items)))))
)

(defun dx2:sort-y-desc (items)
  (aa:merge-sort
    items
    '(lambda (a b)
       (cond
         ((> (nth 2 a) (nth 2 b)) T)
         ((and (equal (nth 2 a) (nth 2 b) 1e-8)
               (< (nth 5 a) (nth 5 b))) T)
         (T nil))))
)

(defun dx2:insert-x-asc (item items)
  (cond
    ((null items) (list item))
    ((< (nth 1 item) (nth 1 (car items))) (cons item items))
    ((and (equal (nth 1 item) (nth 1 (car items)) 1e-8)
          (< (nth 5 item) (nth 5 (car items))))
     (cons item items))
    (T (cons (car items) (dx2:insert-x-asc item (cdr items)))))
)

(defun dx2:sort-x-asc (items)
  (aa:merge-sort
    items
    '(lambda (a b)
       (cond
         ((< (nth 1 a) (nth 1 b)) T)
         ((and (equal (nth 1 a) (nth 1 b) 1e-8)
               (< (nth 5 a) (nth 5 b))) T)
         (T nil))))
)

(defun dx2:group-rows (items / rows row row-y row-h item tol)
  (setq items (dx2:sort-y-desc items)
        rows  nil
        row   nil
        row-y nil
        row-h 0.0)
  (foreach item items
    (setq tol (* 0.55 (max row-h (nth 4 item) 1e-8)))
    (if (and row (<= (abs (- (nth 2 item) row-y)) tol))
      (progn
        (setq row (cons item row))
        (if (> (nth 4 item) row-h) (setq row-h (nth 4 item))))
      (progn
        (if row (setq rows (cons (dx2:sort-x-asc row) rows)))
        (setq row   (list item)
              row-y (nth 2 item)
              row-h (nth 4 item)))))
  (if row (setq rows (cons (dx2:sort-x-asc row) rows)))
  (reverse rows)
)

(defun dx2:append-text (out text)
  (if (= out "") text (strcat out "、" text))
)

(defun dx2:export-group (doc group / items info item index rows row out)
  (setq items nil
        index 0
        out   "")
  (foreach info group
    (setq item (dx2:text-record doc info index))
    (if item (setq items (cons item items)))
    (setq index (1+ index)))
  (setq rows (dx2:group-rows items))
  (foreach row rows
    (foreach item row
      (setq out (dx2:append-text out (car item)))))
  out
)

(defun c:DX2 (/ *error* aa:tag aa:doc aa:undo-open aa:old-cmdecho doc ss text-ss i en info infos groups sorted-groups group-record
               group-text out skipped ok tol rect-tol line-ss spatial-index)
  (aa:cmd-begin "DX2")
  (vl-load-com)
  (setq doc           (vla-get-ActiveDocument (vlax-get-acad-object))
        skipped       0
        out           ""
        tol           1e-8
        rect-tol      0.1
        line-ss       nil
        spatial-index nil)

  (setq ss (ssget "_I"))
  (if (null ss)
    (progn
      (princ "\r\n[DX2] 请框选需要导出的方格和文字: ")
      (setq ss (ssget))))

  (cond
    ((null ss)
     (princ "\r\n[DX2] 未选择对象。"))
    (T
     (setq text-ss (aa:zz-filter-text-ss ss))
     (if (= (sslength text-ss) 0)
       (princ "\r\n[DX2] 选择中没有 TEXT/MTEXT 文字。")
       (progn
         (setq i             0
               infos         nil
               line-ss       (aa:zz-harvest-lines doc text-ss ss)
               spatial-index (aa:zz-build-spatial-index line-ss tol))
         (repeat (sslength text-ss)
           (setq en   (ssname text-ss i)
                 info (aa:zz-text-info doc en tol spatial-index))
           (if info
             (setq infos (cons info infos))
             (setq skipped (1+ skipped)))
           (setq i (1+ i)))
         (setq groups        (aa:zz-group-by-rect (reverse infos) rect-tol)
               sorted-groups (dx2:sort-groups groups))
         (foreach group-record sorted-groups
           (setq group-text (dx2:export-group doc (car group-record)))
           (if (/= group-text "")
             (setq out (if (= out "") group-text (strcat out "\r\n" group-text)))))
         (if (= out "")
           (princ "\r\n[DX2] 没有找到可导出的文字。")
           (progn
             (setq ok (zi:to-clip out))
             (princ
               (strcat "\r\n[DX2] 已按顺序导出 "
                       (itoa (length sorted-groups))
                       " 个方格（每个方格一行）、"
                       (itoa (- (sslength text-ss) skipped))
                       " 个文字"
                       (if ok "，并复制到剪贴板。" "，但复制到剪贴板失败。")
                       (if (> skipped 0)
                         (strcat " 跳过 " (itoa skipped) " 个无法识别方格的文字。")
                         "")))))))))
  (sssetfirst nil nil)
  (aa:cmd-end)
)

;;; =======================================================================================
;;; Command: ZZ / JACC
;;; Purpose: Center selected TEXT/MTEXT inside nearest surrounding horizontal/vertical LINEs.
;;; =======================================================================================
(defun aa:zz-near-line-tol (tol)
  (max 0.5 (* tol 10.0))
)

(defun aa:zz-between-p (v a b tol / lo hi)
  (setq lo (min a b)
        hi (max a b))
  (and (>= v (- lo tol))
       (<= v (+ hi tol)))
)

(defun aa:zz-filter-text-ss (ss / out i en typ)
  (setq out (ssadd)
        i   0)
  (if ss
    (repeat (sslength ss)
      (setq en  (ssname ss i)
            typ (cdr (assoc 0 (entget en))))
      (if (or (= typ "TEXT") (= typ "MTEXT"))
        (ssadd en out))
      (setq i (1+ i))))
  out
)

(defun aa:zz-add-seg (p1 p2 near / x y ymin ymax xmin xmax)
  (cond
    ((<= (abs (- (car p1) (car p2))) near)
     (setq x    (/ (+ (car p1) (car p2)) 2.0)
           ymin (min (cadr p1) (cadr p2))
           ymax (max (cadr p1) (cadr p2))
           vlist (cons (list x ymin ymax) vlist)))
    ((<= (abs (- (cadr p1) (cadr p2))) near)
     (setq y    (/ (+ (cadr p1) (cadr p2)) 2.0)
           xmin (min (car p1) (car p2))
           xmax (max (car p1) (car p2))
           hlist (cons (list y xmin xmax) hlist)))
  )
)

(defun aa:zz-collect-lwpoly-pts (ed / pts pair)
  (setq pts '())
  (foreach pair ed
    (if (= (car pair) 10)
      (setq pts (cons (cdr pair) pts))))
  (reverse pts)
)

(defun aa:zz-poly-closed-p (ed / f)
  (setq f (cdr (assoc 70 ed)))
  (if f (/= 0 (logand 1 f)) nil)
)

(defun aa:zz-build-line-cache (line-ss tol / i en ed typ p1 p2 near vlist hlist pts closed prev first en2 ed2 p)
  (setq i    0
        near (aa:zz-near-line-tol tol)
        vlist '()
        hlist '())
  (if line-ss
    (repeat (sslength line-ss)
      (setq en  (ssname line-ss i)
            ed  (entget en)
            typ (cdr (assoc 0 ed)))
      (cond
        ((= typ "LINE")
         (setq p1 (cdr (assoc 10 ed))
               p2 (cdr (assoc 11 ed)))
         (if (and p1 p2)
           (aa:zz-add-seg p1 p2 near)))
        ((= typ "LWPOLYLINE")
         (setq pts    (aa:zz-collect-lwpoly-pts ed)
               closed (aa:zz-poly-closed-p ed)
               prev   nil
               first  nil)
         (foreach p pts
           (if prev
             (aa:zz-add-seg prev p near)
             (setq first p))
           (setq prev p))
         (if (and closed first prev (not (equal first prev)))
           (aa:zz-add-seg prev first near)))
        ((= typ "POLYLINE")
         (setq pts '()
               en2 (entnext en))
         (while (and en2
                     (setq ed2 (entget en2))
                     (= (cdr (assoc 0 ed2)) "VERTEX"))
           (setq pts (cons (cdr (assoc 10 ed2)) pts)
                 en2 (entnext en2)))
         (setq pts    (reverse pts)
               closed (aa:zz-poly-closed-p ed)
               prev   nil
               first  nil)
         (foreach p pts
           (if prev
             (aa:zz-add-seg prev p near)
             (setq first p))
           (setq prev p))
         (if (and closed first prev (not (equal first prev)))
           (aa:zz-add-seg prev first near)))
      )
      (setq i (1+ i))))
  (list vlist hlist)
)

(defun aa:zz-calc-texts-bbox (doc text-ss / i en bbox min-x min-y max-x max-y bx1 by1 bx2 by2)
  (setq i     0
        min-x nil
        min-y nil
        max-x nil
        max-y nil)
  (if text-ss
    (repeat (sslength text-ss)
      (setq en (ssname text-ss i))
      (if (setq bbox (aa:safe-get-bbox doc en))
        (progn
          (setq bx1 (aa:bbox-left-x bbox)
                by1 (aa:bbox-bottom-y bbox)
                bx2 (aa:bbox-right-x bbox)
                by2 (aa:bbox-top-y bbox))
          (setq min-x (if min-x (min min-x bx1) bx1)
                min-y (if min-y (min min-y by1) by1)
                max-x (if max-x (max max-x bx2) bx2)
                max-y (if max-y (max max-y by2) by2))))
      (setq i (1+ i))))
  (if (and min-x min-y max-x max-y)
    (list min-x min-y max-x max-y)
    nil)
)

(defun aa:zz-harvest-lines (doc text-ss ss / bbox-union min-x min-y max-x max-y pt1 pt2 line-ss line-filter i en typ)
  (setq line-filter '((-4 . "<OR") (0 . "LINE") (0 . "LWPOLYLINE") (0 . "POLYLINE") (-4 . "OR>"))
        line-ss     nil)
  (if (setq bbox-union (aa:zz-calc-texts-bbox doc text-ss))
    (progn
      (setq min-x (nth 0 bbox-union)
            min-y (nth 1 bbox-union)
            max-x (nth 2 bbox-union)
            max-y (nth 3 bbox-union)
            pt1   (list (- min-x 350.0) (- min-y 350.0))
            pt2   (list (+ max-x 350.0) (+ max-y 350.0))
            line-ss (ssget "_C" (trans pt1 0 1) (trans pt2 0 1) line-filter))))
  (if (and ss (> (sslength ss) 0))
    (progn
      (if (null line-ss) (setq line-ss (ssadd)))
      (setq i 0)
      (repeat (sslength ss)
        (setq en  (ssname ss i)
              typ (cdr (assoc 0 (entget en))))
        (if (member typ '("LINE" "LWPOLYLINE" "POLYLINE"))
          (ssadd en line-ss))
        (setq i (1+ i)))))
  line-ss
)

(defun aa:zz-build-spatial-index (line-ss tol / cache vlist hlist)
  (setq cache (aa:zz-build-line-cache line-ss tol)
        vlist (car cache)
        hlist (cadr cache))
  (list (if vlist (aa:merge-sort vlist '(lambda (a b) (< (car a) (car b)))) nil)
        (if hlist (aa:merge-sort hlist '(lambda (a b) (< (car a) (car b)))) nil))
)

(defun aa:zz-find-bound-lines (line-cache cx cy tol / vlist hlist rec x y left-x right-x top-y bottom-y dl dr dt db dist max-dist)
  (setq vlist    (car line-cache)
        hlist    (cadr line-cache)
        max-dist 300.0
        left-x   nil
        right-x  nil
        top-y    nil
        bottom-y nil
        dl       nil
        dr       nil
        dt       nil
        db       nil)
  (if vlist
    (foreach rec vlist
      (if (aa:zz-between-p cy (cadr rec) (caddr rec) tol)
        (progn
          (setq x (car rec))
          (cond
            ((and (< x (- cx tol)) (>= x (- cx max-dist)))
             (setq dist (- cx x))
             (if (or (null dl) (< dist dl))
               (setq dl dist
                     left-x x)))
            ((and (> x (+ cx tol)) (<= x (+ cx max-dist)))
             (setq dist (- x cx))
             (if (or (null dr) (< dist dr))
               (setq dr dist
                     right-x x))))))))
  (if hlist
    (foreach rec hlist
      (if (aa:zz-between-p cx (cadr rec) (caddr rec) tol)
        (progn
          (setq y (car rec))
          (cond
            ((and (< y (- cy tol)) (>= y (- cy max-dist)))
             (setq dist (- cy y))
             (if (or (null db) (< dist db))
               (setq db dist
                     bottom-y y)))
            ((and (> y (+ cy tol)) (<= y (+ cy max-dist)))
             (setq dist (- y cy))
             (if (or (null dt) (< dist dt))
               (setq dt dist
                     top-y y))))))))
  (if (and left-x right-x top-y bottom-y)
    (list left-x right-x top-y bottom-y)
    nil)
)

(defun aa:zz-find-rect-in-index (spatial-index center-pt tol / cx cy)
  (if (listp center-pt)
    (setq cx (car center-pt)
          cy (cadr center-pt))
    (setq cx center-pt
          cy 0.0))
  (aa:zz-find-bound-lines spatial-index cx cy tol)
)

(defun aa:zz-text-info (doc en tol spatial-index / bbox cx cy bounds lx rx ty by)
  ;; Compute the rectangle (lx rx ty by) bounding a text using in-memory spatial index.
  ;; Returns (en cx cy lx rx ty by) or nil if no valid enclosing rectangle.
  (if (setq bbox (aa:safe-get-bbox doc en))
    (progn
      (setq cx     (aa:bbox-center-x bbox)
            cy     (/ (+ (aa:bbox-top-y bbox) (aa:bbox-bottom-y bbox)) 2.0)
            bounds (aa:zz-find-bound-lines spatial-index cx cy tol))
      (if bounds
        (progn
          (setq lx (car bounds)
                rx (cadr bounds)
                ty (caddr bounds)
                by (cadddr bounds))
          (list en cx cy lx rx ty by))
        nil))
    nil)
)

(defun aa:zz-move-text (en cx cy tx ty / dx dy)
  (setq dx (- tx cx)
        dy (- ty cy))
  (if (and (equal dx 0.0 1e-6) (equal dy 0.0 1e-6))
    T
    (aa:safe-move-entity en (vlax-3d-point (list dx dy 0.0))))
)

(defun aa:zz-rect-match-p (a b rect-tol)
  ;; Two text-info records share the same rectangle when all four edges match.
  (and (equal (nth 3 a) (nth 3 b) rect-tol)
       (equal (nth 4 a) (nth 4 b) rect-tol)
       (equal (nth 5 a) (nth 5 b) rect-tol)
       (equal (nth 6 a) (nth 6 b) rect-tol))
)

(defun aa:zz-info-before-p (a b / tya tyb)
  (setq tya (nth 5 a)
        tyb (nth 5 b))
  (cond
    ((> (abs (- tya tyb)) 0.1)
     (> tya tyb))
    ((> (abs (- (nth 3 a) (nth 3 b))) 0.1)
     (< (nth 3 a) (nth 3 b)))
    ((> (abs (- (nth 6 a) (nth 6 b))) 0.1)
     (> (nth 6 a) (nth 6 b)))
    ((> (abs (- (nth 4 a) (nth 4 b))) 0.1)
     (< (nth 4 a) (nth 4 b)))
    (T
     (> (nth 2 a) (nth 2 b))))
)

(defun aa:zz-group-by-rect (infos rect-tol / sorted groups cur-group cur-ref info)
  ;; Bucket text-info records by shared rectangle in O(N log N) time without nested reversals.
  (if (null infos)
    nil
    (progn
      (setq sorted    (aa:merge-sort infos 'aa:zz-info-before-p)
            groups    '()
            cur-group '()
            cur-ref   nil)
      (foreach info sorted
        (if (and cur-ref (aa:zz-rect-match-p info cur-ref rect-tol))
          (setq cur-group (cons info cur-group))
          (progn
            (if cur-group
              (setq groups (cons (reverse cur-group) groups)))
            (setq cur-group (list info)
                  cur-ref   info))))
      (if cur-group
        (setq groups (cons (reverse cur-group) groups)))
      (reverse groups)))
)

(defun aa:zz-insert-y-desc (item items)
  ;; Insert one text-info record, keeping the list sorted by cy descending.
  (cond
    ((null items) (list item))
    ((> (nth 2 item) (nth 2 (car items))) (cons item items))
    (T (cons (car items) (aa:zz-insert-y-desc item (cdr items)))))
)

(defun aa:zz-sort-y-desc (items)
  ;; Sort text-info records by original cy descending (top text first) using aa:merge-sort.
  (aa:merge-sort items '(lambda (a b) (> (nth 2 a) (nth 2 b))))
)

(defun aa:zz-apply-group (group / cnt info en cx cy lx rx ty by tx sorted n i spacing center-y start-y y)
  ;; Move the texts in one group to their target positions and return the
  ;; number of texts that actually changed position (count for the [ZZ] report).
  (setq cnt (length group))
  (cond
    ((= cnt 1)
     (setq info (car group)
           en   (nth 0 info)
           cx   (nth 1 info)
           cy   (nth 2 info)
           lx   (nth 3 info)
           rx   (nth 4 info)
           ty   (nth 5 info)
           by   (nth 6 info))
     (if (aa:zz-move-text en cx cy (/ (+ lx rx) 2.0) (/ (+ ty by) 2.0))
       1 0))
    (T
     ;; Keep adjacent text centers 5 units apart. Position the complete stack
     ;; symmetrically around the rectangle center while preserving top-to-bottom order.
     (setq sorted   (aa:zz-sort-y-desc group)
           n        (length sorted)
           info     (car sorted)
           lx       (nth 3 info)
           rx       (nth 4 info)
           ty       (nth 5 info)
           by       (nth 6 info)
           tx       (/ (+ lx rx) 2.0)
           spacing  5.0
           center-y (/ (+ ty by) 2.0)
           start-y  (+ center-y (* 0.5 (1- n) spacing))
           cnt      0
           i        0)
     (foreach info sorted
       (setq y (- start-y (* i spacing)))
       (if (aa:zz-move-text (nth 0 info) (nth 1 info) (nth 2 info) tx y)
         (setq cnt (1+ cnt)))
       (setq i (1+ i)))
     cnt))
)

(defun aa:zz-center-texts (doc text-ss line-ss / i en changed skipped tol rect-tol infos groups info alignment-ok spatial-index g)
  ;; Reuse ZZ centering without interactive selection or an extra undo mark.
  (setq i 0 changed 0 skipped 0 tol 1e-8 rect-tol 0.1 infos nil
        spatial-index (aa:zz-build-spatial-index line-ss tol))
  (repeat (sslength text-ss)
    (setq en (ssname text-ss i)
          ;; 先统一为中下对正，再以新的包围盒执行后续居中计算。
          alignment-ok (aa:normalize-text-vertical-align doc en 3)
          info (aa:zz-text-info doc en tol spatial-index))
    (if info
      (setq infos (cons info infos))
      (setq skipped (1+ skipped)))
    (setq i (1+ i)))
  (setq groups (aa:zz-group-by-rect (reverse infos) rect-tol))
  (foreach g groups
    (setq changed (+ changed (aa:zz-apply-group g))))
  (list changed skipped)
)

(defun aa:zz-run (/ *error* doc undo-open ss text-ss changed skipped line-ss result)
  (vl-load-com)
  (setq doc           (vla-get-activedocument (vlax-get-acad-object))
        undo-open     nil
        changed       0
        skipped       0
        line-ss       nil)

  (defun *error* (msg)
    (if undo-open
      (vl-catch-all-apply 'vla-endundomark (list doc)))
    (if (and msg
             (not (wcmatch (strcase msg) "*BREAK*,*CANCEL*,*EXIT*,*QUIT*")))
      (princ (strcat "\r\n[ZZ] 错误: " msg)))
    (sssetfirst nil nil)
    (princ)
  )

  (setq ss (ssget "_I"))
  (if (null ss)
    (progn
      (princ "\r\n[ZZ] 请选择对象，仅处理 TEXT/MTEXT 文字: ")
      (setq ss (ssget))))

  (if ss
    (progn
      (setq text-ss (aa:zz-filter-text-ss ss))
      (if (> (sslength text-ss) 0)
        (progn
          (sssetfirst nil text-ss)
          (vla-startundomark doc)
          (setq undo-open T
                line-ss (aa:zz-harvest-lines doc text-ss ss))
          (setq result (aa:zz-center-texts doc text-ss line-ss)
                changed (car result)
                skipped (cadr result))
          (vla-endundomark doc)
          (setq undo-open nil)
          (redraw)
          (princ
            (strcat
              "\r\n[ZZ] 完成。已居中: "
              (itoa changed)
              "，跳过: "
              (itoa skipped)
              ".")))
        (princ "\r\n[ZZ] 选择中没有 TEXT/MTEXT 文字。")))
    (princ "\r\n[ZZ] 未选择对象。"))
  (sssetfirst nil nil)
  (princ)
)

(defun c:ZZ ()
  (aa:zz-run)
)

;;; ZZ2: 对双文字单元格所在行调整行高10，顶边不动，下方内容顺延。
(defun aa:zz2-plan (groups / g info row rows old seen)
  (foreach g groups
    (if (= (length g) 2)
      (progn
        (setq info (car g) row (list (nth 5 info) (nth 6 info)) seen nil)
        (foreach old rows (if (equal old row 0.01) (setq seen T)))
        (if (not seen) (setq rows (cons row rows))))))
  (aa:merge-sort rows '(lambda (a b) (> (car a) (car b)))))

(defun aa:zz2-plan-ok (rows / rest good)
  (setq rest rows good T)
  (while rest
    (if (or (<= (- (caar rest) (cadar rest)) 0.01)
            (and (cdr rest) (> (caadr rest) (+ (cadar rest) 0.01))))
      (setq good nil))
    (setq rest (cdr rest)))
  good)

(defun aa:zz2-y (y rows / row top bottom delta result)
  ;; 对旧坐标统一映射一次；共享边只移动一次，重复执行不累计增高。
  (setq result y)
  (foreach row rows
    (setq top (car row) bottom (cadr row) delta (- 10.0 (- top bottom)))
    (cond
      ((<= y bottom) (setq result (- result delta)))
      ((< y top)
       (setq result (- result (* delta (/ (- top y) (- top bottom))))))))
  result)

(defun aa:zz2-point (p rows circles / circle center radius dy)
  ;; 与圆相连的端点随圆整体移动，保留圆半径和接点连接。
  (foreach circle circles
    (setq center (car circle) radius (cadr circle))
    (if (and (equal (car p) (car center) 0.03)
             (or (equal (cadr p) (+ (cadr center) radius) 0.03)
                 (equal (cadr p) (- (cadr center) radius) 0.03)))
      (setq dy (- (aa:zz2-y (cadr center) rows) (cadr center)))))
  (append (list (car p) (if dy (+ (cadr p) dy) (aa:zz2-y (cadr p) rows)))
          (cddr p)))

(defun aa:zz2-map-edge (en rows circles / ed typ out pair next vd value)
  (setq ed (entget en) typ (cdr (assoc 0 ed)))
  (cond
    ((member typ '("LINE" "LWPOLYLINE"))
     (foreach pair ed
       (if (or (= (car pair) 10) (and (= typ "LINE") (= (car pair) 11)))
         (setq pair (cons (car pair) (aa:zz2-point (cdr pair) rows circles))))
       (setq out (cons pair out)))
     (entmod (reverse out)))
    ((= typ "POLYLINE")
     (setq next (entnext en) out T)
     (while (and next (= (cdr (assoc 0 (entget next))) "VERTEX"))
       (setq vd (entget next) value (assoc 10 vd))
       (if (null (entmod (subst (cons 10 (aa:zz2-point (cdr value) rows circles)) value vd)))
         (setq out nil))
       (setq next (entnext next)))
     out)))

(defun aa:zz2-shift (en typ dy / ed pair out obj result)
  ;; HATCH 的10包含标高/环路点，不能当普通插入点改写。
  (if (= typ "HATCH")
    (progn
      (setq obj (vl-catch-all-apply 'vlax-ename->vla-object (list en)))
      (if (vl-catch-all-error-p obj)
        nil
        (progn
          (setq result
            (vl-catch-all-apply 'vla-Move
              (list obj (vlax-3d-point '(0.0 0.0 0.0))
                        (vlax-3d-point (list 0.0 dy 0.0)))))
          (vl-catch-all-apply 'vlax-release-object (list obj))
          (not (vl-catch-all-error-p result)))))
    (progn
      ;; 基础坐标批量 entmod；MTEXT 的11为方向向量，不能平移。
      (setq ed (entget en))
      (foreach pair ed
        (if (or (= (car pair) 10)
                (and (= typ "TEXT") (= (car pair) 11))
                (and (member typ '("SOLID" "TRACE")) (member (car pair) '(11 12 13))))
          (setq pair (cons (car pair)
                           (mapcar '+ (cdr pair) (list 0.0 dy 0.0)))))
        (setq out (cons pair out)))
      (entmod (reverse out)))))


(defun aa:zz2-frame (lines / cache seg segments rec left right width rows top bottom)
  (setq cache (aa:zz-build-line-cache lines 1e-8))
  (foreach rec (car cache)
    (setq segments (cons (cons "V" rec) segments)))
  (foreach rec (cadr cache)
    (setq segments (cons (cons "H" rec) segments)))
  (setq segments (aa:tbhb-merge-segments segments) width 0.0)
  (foreach seg segments
    (if (and (= (car seg) "H") (> (- (nth 3 seg) (nth 2 seg)) width))
      (setq left (nth 2 seg) right (nth 3 seg) width (- right left))))
  (if (> width 0.01)
    (progn
      (setq rows (aa:hg5-rows segments left right) top (car rows) bottom (last rows))
      (if (and (> (length rows) 1)
               (aa:tbhb-border-p segments top left right)
               (aa:tbhb-border-p segments bottom left right)
               (aa:hg5-side-p segments left bottom top)
               (aa:hg5-side-p segments right bottom top))
        (list left bottom right top)))))

(defun aa:zz2-poly-ok (en / ed typ next good pair)
  (setq ed (entget en) typ (cdr (assoc 0 ed)) good T)
  (if (= typ "POLYLINE")
    (progn
      (if (/= 0 (logand 126 (cdr (assoc 70 ed)))) (setq good nil))
      (setq next (entnext en))
      (while (and next (= (cdr (assoc 0 (entget next))) "VERTEX"))
        (setq ed (append ed (entget next)) next (entnext next)))))
  (foreach pair ed
    (if (and (= (car pair) 42) (not (equal (cdr pair) 0.0 1e-8)))
      (setq good nil)))
  good)

(defun c:ZZ2 (/ *error* aa:tag aa:doc aa:undo-open aa:old-cmdecho
               ss lines texts i en ed typ layer bbox items circles frame problem
               index infos info groups rows row item cy dy result adjusted current)
  (vl-load-com)
  (setq ss (ssget "_I"))
  (if (null ss)
    (progn
      (princ "\r\n[ZZ2] 请完整框选一张表格（含全部边线、文字和接点符号）：")
      (setq ss (ssget))))
  (if ss
    (progn
      ;; 先检查并缓存；不自动收集选区外图元，不操作相邻表格。
      (setq lines (ssadd) texts (ssadd) i 0)
      (repeat (sslength ss)
        (setq en (ssname ss i) ed (entget en) typ (cdr (assoc 0 ed))
              layer (tblsearch "LAYER" (cdr (assoc 8 ed))))
        (cond
          ((not (member typ '("LINE" "LWPOLYLINE" "POLYLINE" "TEXT" "MTEXT"
                              "CIRCLE" "ARC" "ELLIPSE" "SOLID" "TRACE" "POINT" "HATCH")))
           (setq problem "含不支持的对象（如块或原生表格），请先处理后重试。"))
          ((/= 0 (logand 4 (cdr (assoc 70 layer))))
           (setq problem "含锁定图层，请先解锁。"))
          ((and (assoc 210 ed) (not (equal (cdr (assoc 210 ed)) '(0.0 0.0 1.0) 1e-6)))
           (setq problem "仅支持 WCS XY 平面表格。"))
          ((and (member typ '("LWPOLYLINE" "POLYLINE")) (not (aa:zz2-poly-ok en)))
           (setq problem "表格多段线含圆弧或非二维顶点。"))
          (T
           (setq bbox (aa:safe-get-bbox nil en))
           (if (null bbox)
             (setq problem "无法读取部分对象的范围。")
             (setq items (cons (list en typ bbox) items)))
           (cond
             ((member typ '("LINE" "LWPOLYLINE" "POLYLINE")) (ssadd en lines))
             ((member typ '("TEXT" "MTEXT")) (ssadd en texts))
             ((= typ "CIRCLE")
              (setq circles (cons (list (cdr (assoc 10 ed)) (cdr (assoc 40 ed))) circles))))))
        (setq i (1+ i)))
      (setq frame (aa:zz2-frame lines))
      (if (null frame) (setq problem "未识别到完整闭合外框，请完整框选一张表格。"))
      (if (= (sslength texts) 0) (setq problem "选择中没有文字。"))
      (if (null problem)
        (progn
          (setq index (aa:zz-build-spatial-index lines 1e-8) i 0)
          (repeat (sslength texts)
            (setq en (ssname texts i) info (aa:zz-text-info nil en 1e-8 index))
            (if info (setq infos (cons info infos)))
            (setq i (1+ i)))
          (setq groups (aa:zz-group-by-rect (reverse infos) 0.1)
                rows (aa:zz2-plan groups))
          (if (not (aa:zz2-plan-ok rows))
            (setq problem "双文字单元格的上下边界交错，请分成独立表格处理。"))))
      (if problem
        (princ (strcat "\r\n[ZZ2] " problem " 未修改。"))
        (progn
          (aa:cmd-begin "ZZ2")
          (setq adjusted 0)
          (foreach row rows
            (if (not (equal (- (car row) (cadr row)) 10.0 1e-8))
              (setq adjusted (1+ adjusted))))
          (foreach item items
            (if (/= (cadr item) "HATCH")
              (progn
                (setq en (car item) typ (cadr item) bbox (caddr item))
                (if (member typ '("LINE" "LWPOLYLINE" "POLYLINE"))
                  (if (null (aa:zz2-map-edge en rows circles))
                    (error "ZZ2 边线修改失败，请按一次 U 撤销。"))
                  (progn
                    (setq cy (/ (+ (aa:bbox-top-y bbox) (aa:bbox-bottom-y bbox)) 2.0)
                          dy (- (aa:zz2-y cy rows) cy))
                    (if (and (not (equal dy 0.0 1e-8))
                             (not (aa:zz2-shift en typ dy)))
                      (error "ZZ2 对象移动失败，请按一次 U 撤销。")))))))
          ;; 填充最后处理：关联边界可能已使其跟随，用新范围补齐至缓存目标位置。
          ;; 避免关联填充重复移动，也不依赖常为(0,0,0)的参考点。
          (foreach item items
            (if (= (cadr item) "HATCH")
              (progn
                (setq en (car item) bbox (caddr item)
                      cy (/ (+ (aa:bbox-top-y bbox) (aa:bbox-bottom-y bbox)) 2.0)
                      current (aa:safe-get-bbox nil en))
                (if (null current)
                  (error "ZZ2 填充范围读取失败，请按一次 U 撤销。"))
                (setq dy (- (aa:zz2-y cy rows)
                            (/ (+ (aa:bbox-top-y current) (aa:bbox-bottom-y current)) 2.0)))
                (if (and (not (equal dy 0.0 1e-8))
                         (not (aa:zz2-shift en "HATCH" dy)))
                  (error "ZZ2 填充移动失败，请按一次 U 撤销。")))))
          ;; 完成边线及文字顺延后，复用 ZZ 的对正及间距5居中规则。
          (setq result (aa:zz-center-texts aa:doc texts lines))
          (redraw)
          (aa:cmd-end)
          (princ (strcat "\r\n[ZZ2] 已调整 " (itoa adjusted)
                         " 行至高度10，居中文字 " (itoa (car result))
                         " 个，跳过 " (itoa (cadr result)) " 个。一次 U 可整体撤销。")))))
    (princ "\r\n[ZZ2] 未选择对象。"))
  (sssetfirst nil nil)
  (princ))


(defun c:JACC ()
  (aa:zz-run)
)

;;; MJ: automatically fit a single-column table to its longest text.
(defun aa:mj-frame-bounds (doc ss / i en ed typ bbox low high)
  (setq i 0
        low nil
        high nil)
  (repeat (sslength ss)
    (setq en  (ssname ss i)
          ed  (entget en)
          typ (if ed (cdr (assoc 0 ed)) nil))
    (if (member typ '("LINE" "LWPOLYLINE" "POLYLINE"))
      (if (setq bbox (aa:safe-get-bbox doc en))
        (if low
          (setq low  (mapcar 'min low (car bbox))
                high (mapcar 'max high (cadr bbox)))
          (setq low  (car bbox)
                high (cadr bbox)))))
    (setq i (1+ i)))
  (if low (list low high))
)

(defun aa:mj-collect-text-data (doc ss / i en bbox width height cx cy max-width max-height items)
  (setq i 0
        max-width 0.0
        max-height 0.0
        items '())
  (repeat (sslength ss)
    (setq en   (ssname ss i)
          bbox (aa:safe-get-bbox doc en))
    (if bbox
      (progn
        (setq width  (- (car (cadr bbox)) (car (car bbox)))
              height (- (cadr (cadr bbox)) (cadr (car bbox)))
              cx (/ (+ (car (car bbox)) (car (cadr bbox))) 2.0)
              cy (/ (+ (cadr (car bbox)) (cadr (cadr bbox))) 2.0)
              max-width  (max max-width width)
              max-height (max max-height height)
              items (cons (list en cx cy) items))))
    (setq i (1+ i)))
  (if items (list max-width max-height (reverse items)))
)

(defun aa:mj-add-unique-y (y ys tol / found value)
  (setq found nil)
  (foreach value ys
    (if (equal y value tol) (setq found T)))
  (if found ys (cons y ys))
)

(defun aa:mj-horizontal-ys (doc line-ss / i en bbox width height y ys)
  (setq i 0
        ys '())
  (repeat (sslength line-ss)
    (setq en   (ssname line-ss i)
          bbox (aa:safe-get-bbox doc en))
    (if bbox
      (progn
        (setq width  (- (car (cadr bbox)) (car (car bbox)))
              height (- (cadr (cadr bbox)) (cadr (car bbox))))
        (if (and (> width 1e-8) (<= height 1e-6))
          (setq y (/ (+ (cadr (car bbox)) (cadr (cadr bbox))) 2.0)
                ys (aa:mj-add-unique-y y ys 1e-6)))))
    (setq i (1+ i)))
  ys
)

(defun aa:mj-row-center-y (cy ys / above below y)
  (setq above nil
        below nil)
  (foreach y ys
    (cond
      ((> y cy)
       (if (or (null above) (< y above)) (setq above y)))
      ((< y cy)
       (if (or (null below) (> y below)) (setq below y)))))
  (if (and above below)
    (/ (+ above below) 2.0)
    cy)
)
(defun aa:mj-scale-point-x (pt center-x factor)
  (cons (+ center-x (* (- (car pt) center-x) factor)) (cdr pt))
)

(defun aa:mj-scale-simple-entity-x (en center-x factor / ed typ codes new-ed)
  (setq ed  (entget en)
        typ (if ed (cdr (assoc 0 ed)) nil)
        codes (if (= typ "LINE") '(10 11) '(10)))
  (if ed
    (progn
      (setq new-ed
        (mapcar
          '(lambda (item)
             (if (and (member (car item) codes)
                      (listp (cdr item)))
               (cons (car item) (aa:mj-scale-point-x (cdr item) center-x factor))
               item))
          ed))
      (if (entmod new-ed) T nil))
    nil)
)

(defun aa:mj-scale-polyline-x (en center-x factor / vertex ed typ ok)
  (setq vertex (entnext en)
        ok T)
  (while vertex
    (setq ed  (entget vertex)
          typ (if ed (cdr (assoc 0 ed)) nil))
    (cond
      ((= typ "VERTEX")
       (if (not
             (entmod
               (subst
                 (cons 10 (aa:mj-scale-point-x (cdr (assoc 10 ed)) center-x factor))
                 (assoc 10 ed)
                 ed)))
         (setq ok nil)))
      ((= typ "SEQEND")
       (setq vertex nil)))
    (if vertex (setq vertex (entnext vertex))))
  ok
)

(defun aa:mj-scale-line-x (en center-x factor / typ)
  (setq typ (cdr (assoc 0 (entget en))))
  (cond
    ((member typ '("LINE" "LWPOLYLINE"))
     (aa:mj-scale-simple-entity-x en center-x factor))
    ((= typ "POLYLINE")
     (aa:mj-scale-polyline-x en center-x factor))
    (T nil))
)

(defun aa:mj-move-cached-texts (items center-x horizontal-ys / item target-y moved failed)
  (setq moved 0
        failed 0)
  (foreach item items
    (setq target-y (aa:mj-row-center-y (nth 2 item) horizontal-ys))
    (if (aa:zz-move-text (nth 0 item) (nth 1 item) (nth 2 item) center-x target-y)
      (setq moved (1+ moved))
      (setq failed (1+ failed))))
  (list moved failed)
)
(defun c:MJ (/ *error* doc undo-open ss line-ss text-ss i en typ
               bounds text-data horizontal-ys old-width target-width
               center-x factor scaled failed move-result)
  (vl-load-com)
  (setq doc       (vla-get-ActiveDocument (vlax-get-acad-object))
        undo-open nil
        scaled    0
        failed    0)

  (defun *error* (msg)
    (if undo-open
      (vl-catch-all-apply 'vla-EndUndoMark (list doc)))
    (sssetfirst nil nil)
    (if (and msg
             (not (wcmatch (strcase msg) "*BREAK*,*CANCEL*,*EXIT*,*QUIT*")))
      (princ (strcat "\r\n[MJ] 错误：" msg)))
    (princ)
  )

  (setq ss (ssget "_I" '((0 . "LINE,LWPOLYLINE,POLYLINE,TEXT,MTEXT"))))
  (if (null ss)
    (progn
      (princ "\r\n[MJ] 请框选整张表格的边线和文字：")
      (setq ss (ssget '((0 . "LINE,LWPOLYLINE,POLYLINE,TEXT,MTEXT"))))))

  (if ss
    (progn
      (setq line-ss (ssadd)
            text-ss (ssadd)
            i 0)
      (repeat (sslength ss)
        (setq en  (ssname ss i)
              typ (cdr (assoc 0 (entget en))))
        (if (member typ '("TEXT" "MTEXT"))
          (ssadd en text-ss)
          (ssadd en line-ss))
        (setq i (1+ i)))

      (cond
        ((= (sslength line-ss) 0)
         (princ "\r\n[MJ] 选择中没有找到表格边线。"))
        ((= (sslength text-ss) 0)
         (princ "\r\n[MJ] 选择中没有找到 TEXT/MTEXT 文字。"))
        ((null (setq bounds (aa:mj-frame-bounds doc line-ss)))
         (princ "\r\n[MJ] 无法取得表格范围。"))
        ((null (setq text-data (aa:mj-collect-text-data doc text-ss)))
         (princ "\r\n[MJ] 无法取得文字尺寸。"))
        (T
         (setq old-width (- (car (cadr bounds)) (car (car bounds)))
               center-x (/ (+ (car (car bounds)) (car (cadr bounds))) 2.0)
               target-width (min old-width
                                 (+ (car text-data) (* 2.0 (cadr text-data))))
               horizontal-ys (aa:mj-horizontal-ys doc line-ss))
         (if (<= old-width 1e-8)
           (princ "\r\n[MJ] 表格宽度无效。")
           (progn
             (setq factor (/ target-width old-width))
             (vla-StartUndoMark doc)
             (setq undo-open T
                   i 0)

             (repeat (sslength line-ss)
               (setq en (ssname line-ss i))
               (if (aa:mj-scale-line-x en center-x factor)
                 (setq scaled (1+ scaled))
                 (setq failed (1+ failed)))
               (setq i (1+ i)))

             (setq move-result
                   (aa:mj-move-cached-texts
                     (caddr text-data) center-x horizontal-ys))
             (redraw)
             (vla-EndUndoMark doc)
             (setq undo-open nil)
             (princ
               (strcat
                 "\r\n[MJ] 完成：表格宽度由 " (rtos old-width 2 2)
                 " 调整为 " (rtos target-width 2 2)
                 "，居中文字 " (itoa (car move-result)) " 个。"
                 (if (> (+ failed (cadr move-result)) 0)
                   (strcat " 另有 "
                           (itoa (+ failed (cadr move-result)))
                           " 个对象修改失败。")
                   ""))))))))
    (princ "\r\n[MJ] 未选择对象。"))
  (sssetfirst nil nil)
  (princ)
)

;;; =======================================================================================

;;; 命令: FIVE2
;;; 功能: 同一列相接的直线表格统一行高5，保留顶边、列宽、字高和圆形符号大小。
(defun aa:hg5-rows (segments left right / seg ys sorted out y)
  ;; 短于表宽20%的横线视为符号；分段表格线先合并后再识别。
  (foreach seg segments
    (if (and (= (car seg) "H")
             (>= (- (nth 3 seg) (nth 2 seg)) (* 0.2 (- right left))))
      (setq ys (cons (cadr seg) ys))))
  (setq sorted (aa:merge-sort ys '>))
  (foreach y sorted
    (if (or (null out) (not (equal y (car out) 0.01)))
      (setq out (cons y out))))
  (reverse out))

(defun aa:hg5-y (y rows / top rest a b idx found result)
  ;; 将旧边界分段映射到等距新边界，端点小偏差保留，避免倾斜线失真。
  (setq top (car rows) rest rows idx 0 result y)
  (cond
    ((>= y top) y)
    ((<= y (last rows)) (+ (- top (* 5.0 (1- (length rows)))) (- y (last rows))))
    (T
      (while (and (cdr rest) (not found))
        (setq a (car rest) b (cadr rest))
        (if (and (<= y a) (>= y b))
          (setq result (- top (+ (* idx 5.0) (* 5.0 (/ (- a y) (- a b)))))
                found T))
        (setq rest (cdr rest) idx (1+ idx)))
      result)))

(defun aa:hg5-side-p (segments x bottom top / seg found)
  (foreach seg segments
    (if (and (= (car seg) "V") (equal (cadr seg) x 0.01)
             (<= (nth 2 seg) (+ bottom 0.01))
             (>= (nth 3 seg) (- top 0.01)))
      (setq found T)))
  found)

(defun aa:hg5-circle-dy (p circles rows / circle center radius tip dy)
  ;; 连接圆符号的线端点跟随圆平移，圆的半径保持原值。
  (foreach circle circles
    (setq center (car circle) radius (cadr circle))
    (if (equal (car p) (car center) 0.03)
      (foreach tip (list (+ (cadr center) radius) (- (cadr center) radius))
        (if (equal (cadr p) tip 0.03)
          (setq dy (- (aa:hg5-y (cadr center) rows) (cadr center)))))))
  dy)

(defun aa:hg5-point (p rows circles / dy)
  (setq dy (aa:hg5-circle-dy p circles rows))
  (list (car p) (if dy (+ (cadr p) dy) (aa:hg5-y (cadr p) rows)) (caddr p)))

(defun aa:hg5-text-y (y rows / rest idx target)
  ;; 文字按可见中心归行；合并单元格内的文字保持原有行归属。
  (setq rest rows idx 0)
  (while (and (cdr rest) (null target))
    (if (and (<= y (+ (car rest) 0.01)) (>= y (- (cadr rest) 0.01)))
      (setq target (- (car rows) (+ (* idx 5.0) 2.5))))
    (setq rest (cdr rest) idx (1+ idx)))
  target)

(defun c:FIVE2 (/ *error* aa:tag aa:doc aa:undo-open aa:old-cmdecho
               ss i en ed typ layer obj bbox lo hi p q seg segments items circles
               left right bottom top z rows problem item out pair dy target count)
  (vl-load-com)
  (setq ss (ssget "_I"))
  (if (null ss)
    (progn
      (princ "\r\n[FIVE2] 请框选同一列上下相接的完整表格（含全部边线、文字和圆符号）：")
      (setq ss (ssget))))
  (if ss
    (progn
      (setq i 0 count 0)
      ;; 先缓存和检查全部对象，检查失败时不修改图纸。
      (repeat (sslength ss)
        (setq en (ssname ss i) ed (entget en) typ (cdr (assoc 0 ed))
              layer (tblsearch "LAYER" (cdr (assoc 8 ed))) bbox nil seg nil)
        (cond
          ((not (member typ '("LINE" "TEXT" "MTEXT" "CIRCLE")))
           (setq problem "仅支持直线、单行/多行文字和圆，请先处理块或多段线。"))
          ((/= 0 (logand 4 (cdr (assoc 70 layer))))
           (setq problem "所选对象含锁定图层。"))
          ((and (assoc 210 ed) (not (equal (cdr (assoc 210 ed)) '(0.0 0.0 1.0) 1e-6)))
           (setq problem "仅支持 WCS XY 平面内的表格。"))
          (T
            (setq obj (vlax-ename->vla-object en) bbox (aa:try-get-bbox obj))
            (vlax-release-object obj)
            (if (null bbox)
              (setq problem "无法读取部分对象的可见范围。")
              (progn
                (setq lo (car bbox) hi (cadr bbox))
                (if (null z) (setq z (caddr lo)))
                (if (or (not (equal z (caddr lo) 0.01))
                        (not (equal z (caddr hi) 0.01)))
                  (setq problem "对象不在同一标高。"))
                (cond
                  ((= typ "LINE")
                   (setq p (cdr (assoc 10 ed)) q (cdr (assoc 11 ed))
                         seg (aa:tbhb-segment p q))
                   (if seg (setq segments (cons seg segments)))
                   ;; 整列的左右范围由横线确定，不使用可能越界的文字。
                   (if (and seg (= (car seg) "H"))
                     (setq left (if left (min left (nth 2 seg)) (nth 2 seg))
                           right (if right (max right (nth 3 seg)) (nth 3 seg)))))
                  ((= typ "CIRCLE")
                   (setq circles (cons (list (cdr (assoc 10 ed)) (cdr (assoc 40 ed))) circles)))
                  ((> (- (cadr hi) (cadr lo)) 4.8)
                   (setq problem "部分文字高度超过4.8，无法保留字高放入行高5。")))
                (setq items (cons (list en ed bbox) items))))))
        (setq i (1+ i)))
      (if (and (null problem) left right)
        (progn
          (setq segments (aa:tbhb-merge-segments segments)
                rows (aa:hg5-rows segments left right)
                top (car rows) bottom (last rows))
          (if (or (< (length rows) 2)
                  (not (aa:tbhb-border-p segments top left right))
                  (not (aa:tbhb-border-p segments bottom left right))
                  (not (aa:hg5-side-p segments left bottom top))
                  (not (aa:hg5-side-p segments right bottom top)))
            (setq problem "未找到一整列连续闭合的表格，请完整框选；不同列或不相接的表格分次处理。"))))
      (if (null rows) (setq problem "未找到表格横线。"))
      (if (null problem)
        (foreach item items
          (setq ed (cadr item) bbox (caddr item) lo (car bbox) hi (cadr bbox)
                typ (cdr (assoc 0 ed)))
          ;; 文字允许少量字形越出左右框；表外对象和跨边框对象拒绝处理。
          (if (or (< (car lo) (- left 0.5)) (> (car hi) (+ right 0.5))
                  (< (cadr lo) (- bottom 0.01)) (> (cadr hi) (+ top 0.01)))
            (setq problem "选择中含表外对象或多列内容，请只选一整列相接表格。"))
          (if (member typ '("TEXT" "MTEXT"))
            (if (null (aa:hg5-text-y (/ (+ (cadr lo) (cadr hi)) 2.0) rows))
              (setq problem "有文字无法归入表格行。")))))
      (if problem
        (princ (strcat "\r\n[FIVE2] " problem " 未修改。"))
        (progn
          (aa:cmd-begin "FIVE2")
          (foreach item items
            (setq en (car item) ed (cadr item) bbox (caddr item)
                  typ (cdr (assoc 0 ed)) out nil)
            (cond
              ((= typ "LINE")
               (setq p (cdr (assoc 10 ed)) q (cdr (assoc 11 ed)))
               (setq out (subst (cons 10 (aa:hg5-point p rows circles)) (assoc 10 ed) ed)
                     out (subst (cons 11 (aa:hg5-point q rows circles)) (assoc 11 out) out)))
              ((= typ "CIRCLE")
               (setq p (cdr (assoc 10 ed))
                     q (list (car p) (aa:hg5-y (cadr p) rows) (caddr p))
                     out (subst (cons 10 q) (assoc 10 ed) ed)))
              (T
               (setq target (aa:hg5-text-y (/ (+ (cadar bbox) (cadadr bbox)) 2.0) rows)
                     dy (- target (/ (+ (cadar bbox) (cadadr bbox)) 2.0)))
               ;; 普通TEXT的10/11均平移；MTEXT的11是方向向量，不修改。
               (foreach pair ed
                 (if (or (= (car pair) 10) (and (= typ "TEXT") (= (car pair) 11)))
                   (setq pair (cons (car pair) (mapcar '+ (cdr pair) (list 0.0 dy 0.0)))))
                 (setq out (cons pair out)))
               (setq out (reverse out))))
            (if (null (entmod out))
              (error "FIVE2 修改失败，请按一次 U 撤销本次修改。"))
            (setq count (1+ count)))
          (redraw)
          (aa:cmd-end)
          (princ (strcat "\r\n[FIVE2] 已统一 " (itoa (1- (length rows)))
                         " 行，行高5（含标题和表头），处理 " (itoa count)
                         " 个对象；顶边和列宽保持原位。一次 U 可整体撤销。")))))
    (princ "\r\n[FIVE2] 未选择对象。"))
  (sssetfirst nil nil)
  (princ))

;;; 命令: HBBG
;;; 功能: 将完整直线表格按图纸位置从上到下复制拼接，保留原表及各段标题/列顺序。
;;; =======================================================================================
(defun aa:tbhb-segment (p q / dx dy)
  (setq dx (abs (- (car p) (car q))) dy (abs (- (cadr p) (cadr q))))
  (cond
    ((and (> dx 0.01) (<= dy 0.01) (<= dy (* dx 1e-4)))
     (list "H" (/ (+ (cadr p) (cadr q)) 2.0)
           (min (car p) (car q)) (max (car p) (car q))))
    ((and (> dy 0.01) (<= dx 0.01) (<= dx (* dy 1e-4)))
     (list "V" (/ (+ (car p) (car q)) 2.0)
           (min (cadr p) (cadr q)) (max (cadr p) (cadr q))))))

(defun aa:tbhb-border-p (segments y left right / seg found)
  (setq found nil)
  (foreach seg segments
    (if (and (= (car seg) "H") (equal (cadr seg) y 0.01)
             (equal (nth 2 seg) left 0.01) (equal (nth 3 seg) right 0.01))
      (setq found T)))
  found)

(defun aa:tbhb-merge-segments (segments / seg old out next again)
  ;; Recognition only: join touching/overlapping collinear spans, never edit entities.
  ;; Repeat after extending a span so bridges also join previously skipped spans.
  (setq out nil)
  (foreach seg segments
    (setq again T)
    (while again
      (setq again nil next nil)
      (foreach old out
        (if (and (= (car seg) (car old)) (equal (cadr seg) (cadr old) 0.01)
                 (<= (nth 2 old) (+ (nth 3 seg) 0.01))
                 (>= (nth 3 old) (- (nth 2 seg) 0.01)))
          (setq seg (list (car seg) (cadr seg)
                          (min (nth 2 seg) (nth 2 old))
                          (max (nth 3 seg) (nth 3 old)))
                again T)
          (setq next (cons old next))))
      (setq out (reverse next)))
    (setq out (cons seg out)))
  out)

(defun aa:tbhb-boxes (segments / a b box boxes seen old)
  ;; A frame needs matching full-height side borders and full-width top/bottom.
  ;; Internal column lines cannot become frames without their own top/bottom.
  (setq segments (aa:tbhb-merge-segments segments) boxes nil)
  (foreach a segments
    (if (= (car a) "V")
      (foreach b segments
        (if (and (= (car b) "V") (> (cadr b) (+ (cadr a) 0.01))
                 (equal (nth 2 a) (nth 2 b) 0.01)
                 (equal (nth 3 a) (nth 3 b) 0.01)
                 (aa:tbhb-border-p segments (nth 2 a) (cadr a) (cadr b))
                 (aa:tbhb-border-p segments (nth 3 a) (cadr a) (cadr b)))
          (progn
            (setq box (list (cadr a) (/ (+ (nth 2 a) (nth 2 b)) 2.0)
                            (cadr b) (/ (+ (nth 3 a) (nth 3 b)) 2.0))
                  seen nil)
            (foreach old boxes (if (equal old box 0.01) (setq seen T)))
            (if (not seen) (setq boxes (cons box boxes))))))))
  boxes)

(defun aa:tbhb-before-p (a b)
  ;; Strict geometric order: top Y descending, then left X ascending.
  (if (= (nth 3 a) (nth 3 b))
    (< (car a) (car b))
    (> (nth 3 a) (nth 3 b))))

(defun aa:tbhb-inside-p (bounds frame)
  (and (>= (car bounds) (- (car frame) 0.01))
       (>= (cadr bounds) (- (cadr frame) 0.01))
       (<= (nth 2 bounds) (+ (nth 2 frame) 0.01))
       (<= (nth 3 bounds) (+ (nth 3 frame) 0.01))))

(defun aa:tbhb-item-inside-p (item frame / anchor found)
  ;; Text glyph extents can overhang a border slightly although the text is in
  ;; the cell. Keep strict extents ownership for all other content; for TEXT,
  ;; also accept its WCS insertion/alignment anchor inside the frame.
  (setq found nil)
  (if (aa:tbhb-inside-p (nth 2 item) frame)
    (setq found T)
    (if (= (cadr item) "TEXT")
      (foreach anchor (if (>= (length item) 5) (nth 4 item) nil)
        (if (and (>= (car anchor) (- (car frame) 0.01))
                 (>= (cadr anchor) (- (cadr frame) 0.01))
                 (<= (car anchor) (+ (nth 2 frame) 0.01))
                 (<= (cadr anchor) (+ (nth 3 frame) 0.01)))
          (setq found T)))))
  found)

(defun aa:tbhb-group-problem (items boxes / box other item count width problem found)
  (setq problem nil width (- (nth 2 (car boxes)) (caar boxes)))
  (foreach box boxes
    (if (and (null problem)
             (not (equal width (- (nth 2 box) (car box)) 0.01)))
      (setq problem "表格宽度不一致，未生成。"))
    (foreach other boxes
      (if (and (null problem) (not (equal box other 0.01))
               (> (- (min (nth 2 box) (nth 2 other))
                     (max (car box) (car other))) 0.01)
               (> (- (min (nth 3 box) (nth 3 other))
                     (max (cadr box) (cadr other))) 0.01))
        (setq problem "识别到的表格相互重叠，未生成。"))))
  (foreach item items
    (setq count 0)
    (foreach box boxes
      (if (aa:tbhb-item-inside-p item box) (setq count (1+ count))))
    (if (null problem)
      (cond
        ((= count 0)
         (setq problem "选择中有对象不属于完整表格；请检查缺失外框或表外对象，未生成。"))
        ((> count 1)
         (setq problem "选择中有对象同时属于多张表格；请检查共边或重叠外框，未生成。")))))
  problem)

(defun aa:tbhb-groups (items boxes / box item members groups)
  (if (null (aa:tbhb-group-problem items boxes))
    (progn
      (setq groups nil)
      (foreach box boxes
        (setq members nil)
        (foreach item items
          (if (aa:tbhb-item-inside-p item box) (setq members (cons item members))))
        (setq groups (cons (list box (reverse members)) groups)))
      (reverse groups))))

(defun aa:tbhb-offset (box target)
  (list (- (car target) (car box)) (- (cadr target) (nth 3 box)) (caddr target)))

(defun aa:tbhb-next-top (box target)
  (list (car target) (- (cadr target) (- (nth 3 box) (cadr box))) (caddr target)))

(defun aa:tbhb-shift-point (p offset)
  (list (+ (car p) (car offset)) (+ (cadr p) (cadr offset))
        (+ (caddr p) (caddr offset))))

(defun aa:tbhb-seen-line-p (pts lines / old found)
  (setq found nil)
  (foreach old lines
    (if (or (and (equal (car pts) (car old) 0.01)
                 (equal (cadr pts) (cadr old) 0.01))
            (and (equal (car pts) (cadr old) 0.01)
                 (equal (cadr pts) (car old) 0.01)))
      (setq found T)))
  found)

(defun aa:tbhb-abort (msg)
  (princ (strcat "\r\n[HBBG] " msg))
  (exit))

(defun aa:tbhb-collect (ss / i en ed typ obj bbox pts seg items segments problem layer anchors)
  (setq i 0 items nil segments nil)
  (repeat (sslength ss)
    (setq en (ssname ss i) ed (entget en) typ (cdr (assoc 0 ed))
          pts nil seg nil bbox nil anchors nil problem nil
          layer (tblsearch "LAYER" (cdr (assoc 8 ed))))
    (if (= 4 (logand 4 (cond ((cdr (assoc 70 layer))) (T 0))))
      (setq problem "对象位于锁定图层，请先解锁。")
      (progn
        (setq obj (vl-catch-all-apply 'vlax-ename->vla-object (list en)))
        (if (vl-catch-all-error-p obj)
          (setq obj nil problem "对象无法取得 COM 接口。")
          (progn
            (if (not (and (vlax-method-applicable-p obj 'Copy)
                          (vlax-method-applicable-p obj 'Move)))
              (setq problem "对象不支持复制或移动。")
              (if (= typ "LINE")
                (progn
                  (setq pts (list (cdr (assoc 10 ed)) (cdr (assoc 11 ed)))
                        bbox (list (min (caar pts) (caadr pts))
                                   (min (cadar pts) (cadadr pts))
                                   (max (caar pts) (caadr pts))
                                   (max (cadar pts) (cadadr pts))))
                  ;; Only planar axis-aligned LINEs participate in frame recognition.
                  ;; Diagonal/nonplanar lines remain content and are copied unchanged.
                  (if (and (equal (caddr (car pts)) 0.0 0.01)
                           (equal (caddr (cadr pts)) 0.0 0.01))
                    (setq seg (aa:tbhb-segment (car pts) (cadr pts)))))
                (progn
                  ;; All other types use their WCS extents solely for table ownership.
                  (setq bbox (aa:try-get-bbox obj))
                  (if (null bbox)
                    (setq problem "无法读取对象范围。")
                    (setq bbox (list (caar bbox) (cadar bbox) (caadr bbox) (cadadr bbox))))
                  (if (= typ "TEXT")
                    (foreach anchor (list (cdr (assoc 10 ed)) (cdr (assoc 11 ed)))
                      (if (and anchor (listp anchor))
                        (setq anchors (cons (trans anchor en 0) anchors))))))))
            (vlax-release-object obj)
            (setq obj nil)))))
    (if problem
      (aa:tbhb-abort
        (strcat typ " 句柄=" (cond ((cdr (assoc 5 ed))) (T "?")) "：" problem)))
    (setq items (cons (list en typ bbox pts (reverse anchors)) items))
    (if seg (setq segments (cons seg segments)))
    (setq i (1+ i)))
  (list (reverse items) segments))

(defun c:HBBG (/ *error* aa:tag aa:doc aa:undo-open aa:old-cmdecho
                 ss data boxes groups pt target group box item offset moved-pts
                 src copy result en tb:created drawn count skipped rollback-failed)
  (vl-load-com)
  (defun *error* (msg)
    ;; Only newly created entities are removed; source tables are never modified.
    (if copy
      (progn
        (vl-catch-all-apply 'vla-Delete (list copy))
        (vl-catch-all-apply 'vlax-release-object (list copy))))
    (if src (vl-catch-all-apply 'vlax-release-object (list src)))
    (setq copy nil src nil rollback-failed 0)
    (foreach en tb:created
      (if (entget en)
        (progn
          (setq result (vl-catch-all-apply 'entdel (list en)))
          (if (or (vl-catch-all-error-p result) (null result))
            (setq rollback-failed (1+ rollback-failed))))))
    (aa:undo-mark-off)
    (sssetfirst nil nil)
    (if (and msg (not (wcmatch (strcase msg) "*BREAK*,*CANCEL*,*EXIT*,*QUIT*")))
      (princ (strcat "\r\n[HBBG] " msg)))
    (if (> rollback-failed 0)
      (princ "\r\n[HBBG] 部分副本未能清除，请用 U 撤销本次操作。"))
    (princ))
  (setq ss (ssget "_I"))
  (if (null ss)
    (progn
      (princ "\r\n[HBBG] 请框选要合并的完整表格（含全部边线和文字）：")
      (setq ss (ssget))))
  (if ss
    (progn
      (setq data (aa:tbhb-collect ss)
            boxes (aa:tbhb-boxes (cadr data)))
      (cond
        ((< (length boxes) 2)
         (princ "\r\n[HBBG] 未识别到至少两张完整表格；请选全上下左右四条外边线。"))
        ((null (setq groups (aa:tbhb-groups (car data) boxes)))
         (princ (strcat "\r\n[HBBG] " (aa:tbhb-group-problem (car data) boxes))))
        (T
         (setq boxes (aa:merge-sort boxes 'aa:tbhb-before-p) groups nil)
         ;; Rebuild members in sorted order after validating all-table ownership.
         (setq groups nil)
         (foreach box boxes
           (setq group nil)
           (foreach item (car data)
             (if (aa:tbhb-item-inside-p item box) (setq group (cons item group))))
           (setq groups (cons (list box (reverse group)) groups)))
         (setq groups (reverse groups))
         (princ (strcat "\r\n[HBBG] 已识别 " (itoa (length groups))
                        " 张表，将按图纸位置从上到下拼接，保留各段标题和原表。"))
         (if (setq pt (getpoint "\r\n[HBBG] 指定长表的左上角: "))
           (progn
             (setq target (trans pt 1 0) count 0 skipped 0 drawn nil tb:created nil)
             (aa:undo-mark-on)
             (foreach group groups
               (setq box (car group) offset (aa:tbhb-offset box target))
               (foreach item (cadr group)
                 (setq moved-pts nil)
                 (if (= (cadr item) "LINE")
                   (setq moved-pts
                     (list (aa:tbhb-shift-point (car (nth 3 item)) offset)
                           (aa:tbhb-shift-point (cadr (nth 3 item)) offset))))
                 (if (and moved-pts (aa:tbhb-seen-line-p moved-pts drawn))
                   (setq skipped (1+ skipped))
                   (progn
                     (setq src (vlax-ename->vla-object (car item))
                           result (vl-catch-all-apply 'vla-Copy (list src)))
                     (if (vl-catch-all-error-p result) (aa:tbhb-abort "复制失败，正在清理本次副本。"))
                     (setq copy result en (vlax-vla-object->ename copy)
                           tb:created (cons en tb:created)
                           result (vl-catch-all-apply 'vla-Move
                             (list copy (vlax-3d-point '(0.0 0.0 0.0))
                                        (vlax-3d-point offset))))
                     (if (vl-catch-all-error-p result) (aa:tbhb-abort "移动副本失败，正在清理本次副本。"))
                     (vlax-release-object copy)
                     (vlax-release-object src)
                     (setq copy nil src nil count (1+ count))
                     (if moved-pts (setq drawn (cons moved-pts drawn))))))
               (setq target (aa:tbhb-next-top box target)))
             (aa:undo-mark-off)
             (setq tb:created nil)
             (redraw)
             (princ (strcat "\r\n[HBBG] 已拼接 " (itoa (length groups)) " 张表，复制 "
                            (itoa count) " 个对象，省略 " (itoa skipped)
                            " 条重复边线。原表保留，一次 U 可撤销。")))))))
    (princ "\r\n[HBBG] 未选择对象。"))
  (sssetfirst nil nil)
  (princ))

;;; HZBG: 从排列好的文字生成行高 5、自动列宽的线表格。
;;; 缓存项: (ename center-x center-y width height z)。坐标全部为 WCS。
(defun aa:hzbg-groups (items axis tol / sorted groups group anchor item)
  ;; axis 在排序 lambda 中使用调用方动态作用域。
  (setq sorted (aa:merge-sort items
                 '(lambda (a b) (< (nth axis a) (nth axis b)))))
  (foreach item sorted
    (if (and group (<= (abs (- (nth axis item) anchor)) tol))
      (setq group (cons item group))
      (progn
        (if group (setq groups (cons (reverse group) groups)))
        (setq group (list item) anchor (nth axis item)))))
  (if group (setq groups (cons (reverse group) groups)))
  (reverse groups))

(defun aa:hzbg-plan (items tol / cols rows xs ys x y width col row item
                                ri ci moves occupied cell bad left bottom)
  (setq cols (aa:hzbg-groups items 1 tol)
        rows (aa:hzbg-groups items 2 tol)
        left nil bottom nil)
  (foreach item items
    (setq x (- (nth 1 item) (/ (nth 3 item) 2.0))
          y (nth 2 item))
    (if (or (null left) (< x left)) (setq left x))
    (if (or (null bottom) (< y bottom)) (setq bottom y)))
  (setq x (- left 3.0) xs (list x) ci 0)
  (foreach col cols
    (setq width 0.0)
    (foreach item col (setq width (max width (nth 3 item))))
    (foreach item col
      (setq ri 0)
      (foreach row rows
        (if (member item row)
          (progn
            (setq cell (list ci ri))
            (if (member cell occupied) (setq bad T))
            (setq occupied (cons cell occupied)
                  moves (cons (list item (+ x 3.0 (/ width 2.0))
                                          (+ bottom (* ri 5.0))) moves))))
        (setq ri (1+ ri))))
    (setq x (+ x width 6.0) xs (cons x xs) ci (1+ ci)))
  (setq y (- bottom 2.5) ys (list y))
  (repeat (length rows) (setq y (+ y 5.0) ys (cons y ys)))
  (if (not bad) (list (reverse moves) (reverse xs) (reverse ys))))

(defun aa:hzbg-move (en dx dy / ed vec pair out)
  (setq ed (entget en)
        vec (if (= (cdr (assoc 0 ed)) "TEXT")
              (trans (list dx dy 0.0) 0 en T)
              (list dx dy 0.0)))
  ;; TEXT 的 10/11 为 OCS；MTEXT 的 10 为 WCS，11 是方向而不是位置。
  (foreach pair ed
    (if (or (= (car pair) 10)
            (and (= (cdr (assoc 0 ed)) "TEXT") (= (car pair) 11)))
      (setq pair (cons (car pair) (mapcar '+ (cdr pair) vec))))
    (setq out (cons pair out)))
  (entmod (reverse out)))

(defun aa:hzbg-line (p q layer)
  (if (not (entmake (list '(0 . "LINE") (cons 8 layer)
                         '(6 . "Continuous") '(62 . 256)
                         (cons 10 p) (cons 11 q))))
    (error "HZBG 创建表格线失败，请按一次 U 撤销本次修改。")))

;;; 命令: HZBG
;;; 功能: 选中文字生成表格，行高 5，按最宽文字自动列宽，左右各留 3。
(defun c:HZBG (/ *error* aa:tag aa:doc aa:undo-open aa:old-cmdecho
                ss doc i en ed bbox lo hi items total tol problem layer flags
                z plan moves xs ys item move x y)
  (vl-load-com)
  (setq ss (ssget "_I" '((0 . "TEXT,MTEXT"))))
  (if (null ss)
    (progn (princ "\r\n[HZBG] 请选择同一张表格的全部文字（含表头）: ")
           (setq ss (ssget '((0 . "TEXT,MTEXT"))))))
  (if ss
    (progn
      (setq doc (vla-get-activedocument (vlax-get-acad-object))
            i 0 total 0.0 layer (getvar "CLAYER"))
      (if (/= 0 (logand 4 (cdr (assoc 70 (tblsearch "LAYER" layer)))))
        (setq problem "当前图层已锁定。"))
      (repeat (sslength ss)
        (setq en (ssname ss i) ed (entget en)
              flags (cdr (assoc 70 (tblsearch "LAYER" (cdr (assoc 8 ed)))))
              bbox (aa:safe-get-bbox doc en))
        (cond
          ((/= 0 (logand 4 flags)) (setq problem "所选文字含锁定图层。"))
          ((null bbox) (setq problem "无法读取部分文字的外包框。"))
          ((and (assoc 210 ed)
                (not (equal (cdr (assoc 210 ed)) '(0.0 0.0 1.0) 1e-6)))
           (setq problem "仅支持 WCS XY 平面内的文字。"))
          (T
            (setq lo (car bbox) hi (cadr bbox))
            (if (null z) (setq z (caddr lo)))
            (if (or (not (equal z (caddr lo) 1e-4))
                    (not (equal (caddr lo) (caddr hi) 1e-4)))
              (setq problem "文字必须位于同一标高。"))
            (if (> (- (cadr hi) (cadr lo)) 4.0)
              (setq problem "部分文字高度超过 4，无法放入行高 5 并保留上下留白。"))
            (setq items (cons (list en (/ (+ (car lo) (car hi)) 2.0)
                                      (/ (+ (cadr lo) (cadr hi)) 2.0)
                                      (- (car hi) (car lo))
                                      (- (cadr hi) (cadr lo)) (caddr lo)) items)
                  total (+ total (cdr (assoc 40 ed))))))
        (setq i (1+ i)))
      (if (not problem)
        (progn
          (setq tol (max 0.5 (* 0.6 (/ total (sslength ss))))
                plan (aa:hzbg-plan items tol))
          (if (null plan)
            (setq problem "同一单元格识别到多个文字，请先整理或合并文字。"))))
      (if problem
        (princ (strcat "\r\n[HZBG] " problem " 未修改。"))
        (progn
          (setq moves (car plan) xs (cadr plan) ys (caddr plan))
          (aa:cmd-begin "HZBG")
          (foreach move moves
            (setq item (car move))
            (if (not (aa:hzbg-move (car item) (- (cadr move) (nth 1 item))
                                                     (- (caddr move) (nth 2 item))))
              (error "HZBG 移动文字失败，请按一次 U 撤销本次修改。")))
          (foreach y ys
            (aa:hzbg-line (list (car xs) y z) (list (last xs) y z) layer))
          (foreach x xs
            (aa:hzbg-line (list x (car ys) z) (list x (last ys) z) layer))
          (redraw)
          (aa:cmd-end)
          (princ (strcat "\r\n[HZBG] 已生成 " (itoa (1- (length ys))) " 行 × "
                         (itoa (1- (length xs))) " 列表格，行高 5，左右留白各 3。")))))
    (princ "\r\n[HZBG] 未选择文字。"))
  (sssetfirst nil nil)
  (princ))


;;; ZDWI: fit each column of an axis-aligned line table to its text.
(defun aa:zdwi-seed (ss / i en ed pts p q item best)
  (setq i 0 best nil)
  (repeat (sslength ss)
    (setq en (ssname ss i) ed (entget en) pts (aa:zdwi-vertices en))
    (if (and pts (= 1 (logand 1 (cond ((cdr (assoc 70 ed))) (T 0)))))
      (setq pts (append pts (list (car pts)))))
    (while (and pts (cdr pts))
      (setq p (car pts) q (cadr pts))
      (if (equal (cadr p) (cadr q) aa:zdwi-tol)
        (progn
          (setq item (list (min (car p) (car q))
                           (max (car p) (car q)) (cadr p)
                           (cdr (assoc 8 ed))))
          (if (or (null best)
                  (> (- (cadr item) (car item))
                     (- (cadr best) (car best))))
            (setq best item))))
      (setq pts (cdr pts)))
    (setq i (1+ i)))
  best)

(defun aa:zdwi-border-range (ss x seed-y / lo hi again i en pts p q a b)
  (setq lo seed-y hi seed-y again T)
  (while again
    (setq again nil i 0)
    (repeat (sslength ss)
      (setq en (ssname ss i) pts (aa:zdwi-vertices en))
      ;; Include the implicit last-to-first edge of closed row rectangles.
      ;; Their left border may exist only on this closing segment.
      (if (and pts (= 1 (logand 1 (cond ((cdr (assoc 70 (entget en)))) (T 0)))))
        (setq pts (append pts (list (car pts)))))
      (while (and pts (cdr pts))
        (setq p (car pts) q (cadr pts))
        (if (and (equal (car p) x aa:zdwi-tol)
                 (equal (car q) x aa:zdwi-tol))
          (progn
            (setq a (min (cadr p) (cadr q))
                  b (max (cadr p) (cadr q)))
            (if (and (<= a (+ hi aa:zdwi-tol))
                     (>= b (- lo aa:zdwi-tol)))
              (progn
                (if (< a (- lo 1e-5)) (setq lo a again T))
                (if (> b (+ hi 1e-5)) (setq hi b again T))))))
        (setq pts (cdr pts)))
      (setq i (1+ i))))
  (if (> (- hi lo) aa:zdwi-tol) (list lo hi)))

(defun aa:zdwi-expand-selection (selected / seed x1 x2 y search left-range
                                  right-range lower upper nearby result i en ed typ
                                  pts p inside bbox)
  (setq seed (aa:zdwi-seed selected))
  (if seed
    (progn
      (setq x1 (car seed) x2 (cadr seed) y (caddr seed)
            search (ssget "_C"
                      (trans (list (- x1 aa:zdwi-tol) (- y 1000.0) 0.0) 0 1)
                      (trans (list (+ x2 aa:zdwi-tol) (+ y 1000.0) 0.0) 0 1)
                      ;; Table borders and separators may use different layers.
                      '((0 . "LINE,LWPOLYLINE,POLYLINE"))))
      (if search
        (progn
          (setq left-range (aa:zdwi-border-range search x1 y)
                right-range (aa:zdwi-border-range search x2 y))
          (if (and left-range right-range
                   (equal (car left-range) (car right-range) aa:zdwi-tol)
                   (equal (cadr left-range) (cadr right-range) aa:zdwi-tol))
            (progn
              (setq lower (car left-range) upper (cadr left-range)
                    nearby (ssget "_C"
                             (trans (list (- x1 aa:zdwi-tol)
                                          (- lower aa:zdwi-tol) 0.0) 0 1)
                             (trans (list (+ x2 aa:zdwi-tol)
                                          (+ upper aa:zdwi-tol) 0.0) 0 1)
                             '((0 . "LINE,LWPOLYLINE,POLYLINE,TEXT,MTEXT")))
                    result (ssadd) i 0)
              (if nearby
                (repeat (sslength nearby)
                  (setq en (ssname nearby i) ed (entget en)
                        typ (cdr (assoc 0 ed)) inside T)
                  (if (member typ '("TEXT" "MTEXT"))
                    (progn
                      (setq bbox (aa:safe-get-bbox nil en))
                      (setq inside
                        (and bbox
                             ;; Keep overflowing text by its center, not its
                             ;; full extents: these labels determine expansion.
                             (>= (/ (+ (caar bbox) (caadr bbox)) 2.0)
                                 (- x1 aa:zdwi-tol))
                             (<= (/ (+ (caar bbox) (caadr bbox)) 2.0)
                                 (+ x2 aa:zdwi-tol))
                             (>= (cadar bbox) (- lower aa:zdwi-tol))
                             (<= (cadadr bbox) (+ upper aa:zdwi-tol)))))
                    (progn
                      (setq pts (aa:zdwi-vertices en)
                            inside (not (null pts)))
                      (foreach p pts
                        (if (or (< (car p) (- x1 aa:zdwi-tol))
                                (> (car p) (+ x2 aa:zdwi-tol))
                                (< (cadr p) (- lower aa:zdwi-tol))
                                (> (cadr p) (+ upper aa:zdwi-tol)))
                          (setq inside nil)))))
                  (if inside (ssadd en result))
                  (setq i (1+ i))))
              (if (> (sslength result) 0) result))))))))

(defun aa:zdwi-unique (x values tol / found v)
  (setq found nil)
  (foreach v values (if (equal x v tol) (setq found T)))
  (if found values (cons x values)))

(defun aa:zdwi-add-span (x y1 y2 spans / record found out)
  (setq found nil out nil)
  (foreach record spans
    (if (equal x (car record) aa:zdwi-tol)
      (progn
        (setq out (cons (list (car record)
                              (min y1 (cadr record))
                              (max y2 (caddr record))) out)
              found T))
      (setq out (cons record out))))
  (if found (reverse out) (cons (list x y1 y2) spans)))

(defun aa:zdwi-vertices (en / ed typ v out)
  (setq ed (entget en) typ (cdr (assoc 0 ed)) out nil)
  (cond
    ((= typ "LINE") (list (cdr (assoc 10 ed)) (cdr (assoc 11 ed))))
    ((= typ "LWPOLYLINE")
     (foreach v ed (if (= (car v) 10) (setq out (cons (cdr v) out))))
     (reverse out))
    ((= typ "POLYLINE")
     (setq v (entnext en))
     (while (and v (/= (cdr (assoc 0 (entget v))) "SEQEND"))
       (setq out (cons (cdr (assoc 10 (entget v))) out) v (entnext v)))
     (reverse out))))

(defun aa:zdwi-column (x xs / i answer)
  (setq i 0 answer nil)
  (while (and (< (1+ i) (length xs)) (null answer))
    (if (and (>= x (- (nth i xs) aa:zdwi-tol))
             (<= x (+ (nth (1+ i) xs) aa:zdwi-tol)))
      (setq answer i)
      (setq i (1+ i))))
  answer)

(defun aa:zdwi-set-nth (values index value / i out v)
  (setq i 0 out nil)
  (foreach v values
    (setq out (cons (if (= i index) value v) out)
          i (1+ i)))
  (reverse out))

(defun aa:zdwi-new-x (x old new / i result)
  (setq i (aa:zdwi-column x old))
  (cond
    ((null i) x)
    ((equal x (nth i old) aa:zdwi-tol) (nth i new))
    ((equal x (nth (1+ i) old) aa:zdwi-tol) (nth (1+ i) new))
    (T (+ (nth i new)
          (* (/ (- x (nth i old)) (- (nth (1+ i) old) (nth i old)))
             (- (nth (1+ i) new) (nth i new)))))))

(defun aa:zdwi-map-entity (en old new / ed typ v vd next result)
  (setq ed (entget en) typ (cdr (assoc 0 ed)))
  (cond
    ((= typ "LINE")
     (setq result
       (mapcar '(lambda (a)
         (if (member (car a) '(10 11))
           (cons (car a) (cons (aa:zdwi-new-x (cadr a) old new) (cddr a))) a)) ed))
     (entmod result))
    ((= typ "LWPOLYLINE")
     (setq result
       (mapcar '(lambda (a)
         (if (= (car a) 10)
           (cons 10 (cons (aa:zdwi-new-x (cadr a) old new) (cddr a))) a)) ed))
     (entmod result))
    ((= typ "POLYLINE")
     (setq next (entnext en) result T)
     (while (and next (/= (cdr (assoc 0 (entget next))) "SEQEND"))
       (setq vd (entget next) v (assoc 10 vd))
       (if (not (entmod (subst
                      (cons 10 (cons (aa:zdwi-new-x (cadr v) old new) (cddr v)))
                      v vd))) (setq result nil))
       (setq next (entnext next)))
     result)))

(defun c:ZDWI (/ *error* aa:tag aa:doc aa:undo-open aa:old-cmdecho aa:zdwi-tol
                 ss lines texts i en typ pts p q xs spans record min-y max-y old widths items bbox
                 left right center col new width item target moved failed valid
                 tol x1 x2 centered)
  (vl-load-com)
  ;; Half a drawing unit absorbs small endpoint gaps without merging the
  ;; 10-unit columns in the supplied sample drawing.
  (setq aa:zdwi-tol 0.5)
  (setq ss (ssget "_I" '((0 . "LINE,LWPOLYLINE,POLYLINE,TEXT,MTEXT"))))
  (if (null ss)
    (progn
      (princ "\r\n[ZDWI] 请选择整张表格的线和文字: ")
      (setq ss (ssget '((0 . "LINE,LWPOLYLINE,POLYLINE,TEXT,MTEXT"))))))
  (if ss (setq ss (aa:zdwi-expand-selection ss)))
  (if ss
    (progn
      (setq lines (ssadd) texts (ssadd) i 0 xs nil spans nil
            min-y nil max-y nil valid T)
      (repeat (sslength ss)
        (setq en (ssname ss i) typ (cdr (assoc 0 (entget en))))
        (if (member typ '("TEXT" "MTEXT")) (ssadd en texts) (ssadd en lines))
        (setq i (1+ i)))
      (if (and (> (sslength lines) 0) (> (sslength texts) 0))
        (progn
          (setq i 0)
          (repeat (sslength lines)
            (setq en (ssname lines i) pts (aa:zdwi-vertices en))
            (if (or (null pts) (< (length pts) 2)) (setq valid nil))
            (if (= 1 (logand 1 (cond ((cdr (assoc 70 (entget en)))) (T 0))))
              (setq pts (append pts (list (car pts)))))
            (while (and pts (cdr pts))
              (setq p (car pts) q (cadr pts))
              (setq min-y (if min-y (min min-y (cadr p) (cadr q))
                            (min (cadr p) (cadr q)))
                    max-y (if max-y (max max-y (cadr p) (cadr q))
                            (max (cadr p) (cadr q))))
              (cond
                ((equal (car p) (car q) aa:zdwi-tol)
                 (setq xs (aa:zdwi-unique (car p) xs aa:zdwi-tol)
                       spans (aa:zdwi-add-span (car p)
                                  (min (cadr p) (cadr q))
                                  (max (cadr p) (cadr q)) spans)))
                ((equal (cadr p) (cadr q) aa:zdwi-tol))
                (T (setq valid nil)))
              (setq pts (cdr pts)))
            (setq i (1+ i)))
          (setq old (aa:merge-sort xs '<))
          ;; Local/merged columns need not run from the table top to bottom.
          ;; The expanded selection already includes all connected rows.
          (if (or (not valid) (< (length old) 2))
            (princ "\r\n[ZDWI] 未找到至少两条近似竖直列线，或存在明显斜线；未修改。")
            (progn
              (setq widths nil i 0 items nil)
              (repeat (1- (length old))
                (setq widths (append widths (list 0.0))))
              (repeat (sslength texts)
                (setq en (ssname texts i)
                      bbox (aa:safe-get-bbox nil en))
                (if bbox
                  (progn
                    (setq left (caar bbox) right (caadr bbox)
                          center (/ (+ left right) 2.0)
                          col (aa:zdwi-column center old))
                    ;; Assign by bbox center. Existing text may overhang a
                    ;; narrow cell; fitting that full width is the purpose.
                    (if col
                      (progn
                        (setq widths (aa:zdwi-set-nth widths col
                                       (max (nth col widths) (- right left))))
                        (setq items (cons (list en col center) items)))
                      (setq valid nil)))
                  (setq valid nil))
                (setq i (1+ i)))
              (if (not valid)
                (princ "\r\n[ZDWI] 有文字中心不在表格内，或无法读取包围盒；未修改。")
                (progn
                  (setq new (list (car old)))
                  (foreach width widths
                    (setq new (append new (list (+ (last new) width 6.0)))))
                  (aa:cmd-begin "ZDWI")
                  (setq i 0 failed 0 moved 0)
                  (repeat (sslength lines)
                    (if (not (aa:zdwi-map-entity (ssname lines i) old new))
                      (setq failed (1+ failed)))
                    (setq i (1+ i)))
                  (foreach item items
                    (setq col (cadr item)
                          target (/ (+ (nth col new) (nth (1+ col) new)) 2.0))
                    (if (aa:zz-move-text (car item) (caddr item) 0.0 target 0.0)
                      (setq moved (1+ moved))
                      (setq failed (1+ failed))))
                  (setq centered (aa:zz-center-texts aa:doc texts lines))
                  (redraw)
                  (aa:cmd-end)
                  (princ (strcat "\r\n[ZDWI] 已调整 "
                                 (itoa (length widths)) " 列，移动 "
                                 (itoa moved) " 个文字；已按 ZZ 居中 "
                                 (itoa (car centered)) " 个文字，跳过 "
                                 (itoa (cadr centered)) " 个文字。"
                                 (if (> failed 0)
                                   (strcat " 修改失败 " (itoa failed) " 个对象。") ""))))))))
        (princ "\r\n[ZDWI] 请选择表格线及 TEXT/MTEXT 文字。")))
    (princ "\r\n[ZDWI] 未找到完整表格。请预选表格中的一条整行横线及文字。"))
  (sssetfirst nil nil) ; 命令结束后清除选择与亮显
  (princ))

;;;========================================================================================
;;; DF-DB-AF-AB  文字批量增删 (DB=删末尾 DF=删开头 AB=尾部加字 AF=头部加字)
;;;========================================================================================
;;; ============================================================
;;; DF-DB-AF-AB.lsp  文字批量增删
;;;   DB : 删除每个选中文字对象“末尾”的 N 个字符
;;;   DF : 删除每个选中文字对象“开头”的 N 个字符
;;;   AF : 在每个选中文字对象“开头”增加文字（空输入使用剪贴板）
;;;   AB : 在每个选中文字对象“末尾”增加文字（空输入使用剪贴板）
;;;   N 个字符：汉字/数字/字母/符号(如 ×)均按 1 个字符计
;;; ============================================================


;; 取实体的文字内容（TEXT/MTEXT 均用 DXF 1）
(defun db:get-str (en / e)
  (setq e (entget en))
  (cdr (assoc 1 e))
)

;; 写回文字内容
(defun db:set-str (en s / e)
  (setq e (entget en))
  (entmod (subst (cons 1 s) (assoc 1 e) e))
)

;; 选择文字对象，返回选择集（无则 nil）
(defun db:sel (/ ss)
  (princ "\r\n请选择文字对象: ")
  (setq ss (ssget '((0 . "TEXT,MTEXT"))))
  (if (null ss) (princ "\r\n未选择任何文字对象。"))
  ss
)

;; 删除：mode = "B" 删尾，"F" 删头
(defun db:del (mode / ss n i en s len ns cnt)
  (if (setq ss (db:sel))
    (progn
      (initget 7) ; 不允许空、0、负数
      (setq n (getint "\r\n请输入要删除的字符个数: "))
      (setq i 0 cnt 0)
      (while (< i (sslength ss))
        (setq en (ssname ss i))
        (setq s (db:get-str en))
        (if s
          (progn
            (setq len (strlen s))
            (if (>= n len)
              (setq ns "")                              ; 删空
              (if (= mode "B")
                (setq ns (substr s 1 (- len n)))        ; 删末尾 N
                (setq ns (substr s (1+ n)))             ; 删开头 N
              )
            )
            (db:set-str en ns)
            (setq cnt (1+ cnt))
          )
        )
        (setq i (1+ i))
      )
      (redraw)   ; 循环内不再逐个 entupd，改为统一重绘
      (princ (strcat "\r\n已处理 " (itoa cnt) " 个文字对象。"))
    )
  )
  (princ)
)

;; 增加：mode = "B" 加到末尾，"F" 加到开头
(defun db:add (mode / ss txt i en s ns cnt)
  (if (setq ss (db:sel))
    (progn
      (setq txt (getstring "\r\n请输入要增加的文字 <回车/空格使用剪贴板>: "))
      (if (= txt "")
        (progn
          (vl-load-com)
          (setq txt (qe:get-clip-text))))
      (if (or (/= (type txt) 'STR) (= txt ""))
        (princ "\r\n剪贴板中没有可用的文字或读取失败，未修改任何对象。")
        (progn
          (setq i 0 cnt 0)
          (while (< i (sslength ss))
            (setq en (ssname ss i))
            (setq s (db:get-str en))
            (if s
              (progn
                (if (= mode "B")
                  (setq ns (strcat s txt))   ; 加到末尾
                  (setq ns (strcat txt s))   ; 加到开头
                )
                (db:set-str en ns)
                (setq cnt (1+ cnt))
              )
            )
            (setq i (1+ i))
          )
          (redraw)   ; 循环内不再逐个 entupd，改为统一重绘
          (princ (strcat "\r\n已处理 " (itoa cnt) " 个文字对象。"))
        )
      )
    )
  )
  (princ)
)

;;; FF：预选文字后输入查找与替换内容，空格确认，批量替换所有匹配片段。
(defun aa:ff-text-data (ed value / result pair chunks remaining inserted chunk)
  ;; MTEXT 可能分为多个 DXF 3 段和末尾 DXF 1 段，整体替换后重新分段。
  (if (= (cdr (assoc 0 ed)) "MTEXT")
    (progn
      (setq remaining value)
      (while (> (strlen remaining) 250)
        (setq chunks (cons (cons 3 (substr remaining 1 250)) chunks)
              remaining (substr remaining 251)))
      (setq chunks (reverse (cons (cons 1 remaining) chunks)))
      (foreach pair ed
        (if (member (car pair) '(1 3))
          (if (not inserted)
            (progn
              (foreach chunk chunks (setq result (cons chunk result)))
              (setq inserted T)))
          (setq result (cons pair result))))
      (reverse result))
    (subst (cons 1 value) (assoc 1 ed) ed)))

(defun c:FF (/ *error* aa:tag aa:doc aa:undo-open aa:old-cmdecho
               ss old new i en ed raw value layer-data result changed failed)
  (setq ss (ssget "_I" '((0 . "TEXT,MTEXT"))))
  (aa:cmd-begin "FF")
  (if (not ss)
    (progn
      (prompt "\r\n请选择要查找替换的文字：")
      (setq ss (ssget '((0 . "TEXT,MTEXT"))))))
  (if ss
    (progn
      ;; 不传 T：空格或回车直接结束输入，符合快速替换流程。
      (setq old (getstring "\r\n输入要查找的文字（空格确认）："))
      (if (= old "")
        (prompt "\r\n查找内容为空，未修改。")
        (progn
          (setq new (getstring "\r\n输入替换后的文字（空格确认，留空表示删除）：")
                i 0 changed 0 failed 0)
          (repeat (sslength ss)
            (setq en (ssname ss i)
                  ed (entget en)
                  raw (aa:ysdl-get-raw-text ed)
                  value (aa:str-replace-all old new raw))
            (if (/= raw value)
              (progn
                (setq layer-data (tblsearch "LAYER" (cdr (assoc 8 ed))))
                (if (and layer-data (/= 0 (logand 4 (cdr (assoc 70 layer-data)))))
                  (setq failed (1+ failed))
                  (progn
                    (setq result (vl-catch-all-apply 'entmod
                                   (list (aa:ff-text-data ed value))))
                    (if (or (vl-catch-all-error-p result) (not result))
                      (setq failed (1+ failed))
                      (setq changed (1+ changed)))))))
            (setq i (1+ i)))
          (if (> changed 0) (redraw))
          (prompt (strcat "\r\nFF：已替换 " (itoa changed) " 个文字对象。"
                         (if (> failed 0)
                           (strcat " 跳过锁定或写入失败对象 " (itoa failed) " 个。")
                           ""))))))
    (prompt "\r\n未选择文字。"))
  (aa:cmd-end)
  (princ))

;; DB 删除每个选中文字末尾的 N 个字符
(defun c:DB (/ *error* aa:tag aa:doc aa:undo-open aa:old-cmdecho)
  (aa:cmd-begin "DB")
  (db:del "B")
  (aa:cmd-end)
)
;; DF 删除每个选中文字开头的 N 个字符
(defun c:DF (/ *error* aa:tag aa:doc aa:undo-open aa:old-cmdecho)
  (aa:cmd-begin "DF")
  (db:del "F")
  (aa:cmd-end)
)
;; AB 在每个选中文字末尾增加文字（空输入使用剪贴板）
(defun c:AB (/ *error* aa:tag aa:doc aa:undo-open aa:old-cmdecho)
  (aa:cmd-begin "AB")
  (db:add "B")
  (aa:cmd-end)
)
;; AF 在每个选中文字开头增加文字（空输入使用剪贴板）
(defun c:AF (/ *error* aa:tag aa:doc aa:undo-open aa:old-cmdecho)
  (aa:cmd-begin "AF")
  (db:add "F")
  (aa:cmd-end)
)

(princ)


;; ============================================================
;; ZI  提取选中文字到剪贴板
;;   选中若干 TEXT/MTEXT 后执行 ZI，
;;   把所有文字内容按"从上到下、从左到右"排序，
;;   用顿号"、"连接后复制到 Windows 剪贴板。
;;   例: 公用测控柜、智能故障录波柜
;; ============================================================

;; 取实体插入点坐标 (优先 group 10)
(defun zi:pt (ed)
  (cdr (assoc 10 ed))
)

;; 把字符串写入剪贴板 (借助 htmlfile 的 ActiveX 剪贴板接口)
(defun zi:to-clip (str / html result)
  (setq result nil)
  (vl-catch-all-apply
    (function
      (lambda ()
        (setq html (vlax-create-object "htmlfile"))
        (vlax-invoke
          (vlax-get (vlax-get html 'ParentWindow) 'ClipboardData)
          'SetData "Text" str)
        (vlax-release-object html)
        (setq result t)
      )
    )
  )
  result
)

;; 读取 Windows 剪贴板中的文本
(defun qe:get-clip-text (/ html win clip result)
  (setq result
    (vl-catch-all-apply
      (function
        (lambda ()
          (setq html (vlax-create-object "htmlfile")
                win (vlax-get html 'ParentWindow)
                clip (vlax-get win 'ClipboardData))
          (vlax-invoke clip 'GetData "Text")
        )
      )
    )
  )
  (if clip (vl-catch-all-apply 'vlax-release-object (list clip)))
  (if win (vl-catch-all-apply 'vlax-release-object (list win)))
  (if html (vl-catch-all-apply 'vlax-release-object (list html)))
  (if (vl-catch-all-error-p result) nil result)
)

;; 返回文字中第一个“至”及其之前的部分；没有“至”返回 nil。
;; 中望 LISPSYS=1 下 strlen/substr 均按字符计数，逐字比较不受中文影响。
(defun qe:zhi-prefix (s / i n found)
  (setq i 0 n (strlen s))
  (while (and (not found) (< i n))
    (setq i (1+ i))
    (if (= (substr s i 1) "至")
      (setq found (substr s 1 i))))
  found
)

;; 用 Windows 剪贴板中的文字批量替换选中文字；文字含“至”字时只替换“至”后面的部分（entmod 优化版：QE 命令）
(defun c:QE (/ *error* doc undo-open clip-text ss i ent ed old-text new-text pos changed failed)
  (vl-load-com)
  (setq doc (vla-get-ActiveDocument (vlax-get-acad-object))
        undo-open nil)

  (defun *error* (msg)
    (if undo-open
      (vl-catch-all-apply 'vla-EndUndoMark (list doc)))
    (if (and msg
             (/= msg "Function cancelled")
             (/= msg "quit / exit abort"))
      (princ (strcat "\r\n[QE] 执行失败：" msg)))
    (princ)
  )

  (setq clip-text (qe:get-clip-text))
  ;; Excel 等复制的单元格末尾自带换行，去掉以免写入文字
  (if (= (type clip-text) 'STR)
    (setq clip-text (vl-string-right-trim "\r\n" clip-text)))
  (cond
    ((not (= (type clip-text) 'STR))
     (princ "\r\n[QE] 无法获取 Windows 剪贴板中的文字。"))
    ((= clip-text "")
     (princ "\r\n[QE] 剪贴板中没有可用的文字，未修改任何对象"))
    ((not (setq ss (ssget '((0 . "TEXT,MTEXT,ATTRIB,ATTDEF")))))
     (princ "\r\n[QE] 未选中可替换文字的对象"))
    (t
     (vla-StartUndoMark doc)
     (setq undo-open t
           i -1
           changed 0
           failed 0)
     (repeat (sslength ss)
       (setq ent (ssname ss (setq i (1+ i)))
             ed (entget ent)
             ;; 长多行文字：组码 3 依次存放前段，组码 1 为末段，拼成完整内容
             old-text (if (assoc 1 ed)
                        (strcat
                          (apply 'strcat
                            (mapcar 'cdr
                              (vl-remove-if-not
                                '(lambda (x) (= (car x) 3)) ed)))
                          (cdr (assoc 1 ed)))))
       (cond
         ((not old-text)
          (setq failed (1+ failed)))
         ((= old-text clip-text)
          (setq changed (1+ changed)))
         (t
          ;; 文字含“至”字时只替换“至”后面的文字，
          ;; 例如“至10kV 1(2)#站用变”+剪贴板“变压器超温报警”→“至变压器超温报警”
          ;; 逐字查找“至”，不混用 vl-string-search 位置与 substr，避免中文按字节/字符计数不一致导致截错
          (setq pos      (qe:zhi-prefix old-text)
                new-text (if pos (strcat pos clip-text) clip-text))
          (cond
            ((= old-text new-text)
             (setq changed (1+ changed)))
            ;; 长多行文字的前段存在组码 3，只改组码 1 会残留前段，改用 COM 整体写入
            ((if (assoc 3 ed)
               (not (vl-catch-all-error-p
                      (vl-catch-all-apply 'vla-put-TextString
                        (list (vlax-ename->vla-object ent) new-text))))
               (entmod (subst (cons 1 new-text) (assoc 1 ed) ed)))
             (setq changed (1+ changed)))
            (t
             (setq failed (1+ failed))))))
     )
     (vla-EndUndoMark doc)
     (setq undo-open nil)
     (princ
        (strcat
          "\r\n[QE] 已从剪贴板替换 "
         (itoa changed)
         " 个文字对象"
         (if (> failed 0)
           (strcat "，其中 " (itoa failed) " 个修改失败。")
           "。"))
     )
    )
  )
  (princ)
)

;; CC 读取现有剪贴板；先替换副本内容，再由原生 MOVE 提供拖动预览和捕捉；支持连续多次复制。
(defun c:CC (/ *error* aa:tag aa:doc aa:undo-open aa:old-cmdecho
               clip-text ss src ed base copy-obj old-dragmode
               continue last-pt count)
  (setq ss (ssget "_I"))
  (aa:cmd-begin "CC")
  (defun *error* (msg)
    (if copy-obj
      (vl-catch-all-apply 'vla-Delete (list copy-obj)))
    (if old-dragmode
      (vl-catch-all-apply 'setvar (list "DRAGMODE" old-dragmode)))
    (redraw)
    (aa:cmd-error msg)
  )
  (setq clip-text (qe:get-clip-text))
  (cond
    ((not (= (type clip-text) 'STR))
     (princ "\n[CC] 无法获取 Windows 剪贴板中的文字。"))
    ((= clip-text "")
     (princ "\n[CC] 剪贴板中没有可用的文字。"))
    ((not ss)
     (princ "\n[CC] 请先预选一个文字对象，再输入 CC。"))
    ((/= (sslength ss) 1)
     (princ "\n[CC] 请只预选一个文字对象。"))
    (t
      (setq src (ssname ss 0)
            ed (entget src))
      (cond
        ((not (member (cdr (assoc 0 ed)) '("TEXT" "MTEXT" "ATTDEF")))
         (princ "\n[CC] 请预选一个单行文字、多行文字或属性定义。"))
        ((setq base (getpoint "\n指定第一个点（基点）: "))
         (setq old-dragmode (getvar "DRAGMODE"))
         (setvar "DRAGMODE" 2)
         (sssetfirst nil nil)
         (setq continue T
               count 0)
         (while continue
           (setq copy-obj (vla-Copy (vlax-ename->vla-object src)))
           (vla-put-TextString copy-obj clip-text)
           ;; 原生命令开始前更新显示，确保拖动的是替换后的文字。
           (vla-Update copy-obj)
           ;; base 已经捕捉过，用 _non 防止再次捕捉；目标点交给原生输入。
           (command "_.MOVE" (vlax-vla-object->ename copy-obj) "" "_non" base)
           (setq last-pt (getvar "LASTPOINT"))
           ;; 只隐藏副本的静态显示，不改 Visible/DXF 60，以保留原生拖动图像。
           (redraw (vlax-vla-object->ename copy-obj) 2)
           (while (> (logand (getvar "CMDACTIVE") 1) 0)
             (command pause))
           (redraw (vlax-vla-object->ename copy-obj) 1)
           (if (equal (getvar "LASTPOINT") last-pt 1e-6)
             (progn
               (vl-catch-all-apply 'vla-Delete (list copy-obj))
               (setq copy-obj nil
                     continue nil)
             )
             (progn
               (vlax-release-object copy-obj)
               (setq copy-obj nil
                     count (1+ count))
             )
           )
         )
         (redraw)
         (setvar "DRAGMODE" old-dragmode)
         (setq old-dragmode nil
               copy-obj nil)
         (if (> count 0)
           (princ (strcat "\n[CC] 已完成复制，共复制 " (itoa count) " 个对象，副本已替换为剪贴板文字。"))
           (princ "\n[CC] 已取消。")
         )
        )
      )
    )
  )
  (aa:cmd-end)
)

;; QW 内部: 把 (y x 文字 字高 序号) 列表按行分组，
;; 同一行用顿号连接，行与行之间也用顿号连接，返回 (连接结果 行数)
(defun qw:join (items / rows row row-y row-h tol res line it r)
  ;; 先整体按 y 从大到小(从上到下)排序，序号作为最后一级比较，
  ;; 序号兜底保证比较严格；归并排序本身也不会丢弃同坐标元素
  (setq items
    (aa:merge-sort items
      (function
        (lambda (a b)
          (if (equal (car a) (car b) 1e-9)
            (< (nth 4 a) (nth 4 b))
            (> (car a) (car b))
          )
        )
      )
    )
  )
  ;; 以字高的一半作容差分行: y 差在容差内视为同一行
  (setq rows nil row nil row-y nil row-h 0.0)
  (foreach it items
    (setq tol (* 0.5 (max row-h (cadddr it) 1e-8)))
    (if (and row (<= (abs (- (car it) row-y)) tol))
      (progn
        (setq row (cons it row))
        (if (> (cadddr it) row-h) (setq row-h (cadddr it)))
      )
      (progn
        (if row (setq rows (cons row rows)))
        (setq row    (list it)
              row-y  (car it)
              row-h  (cadddr it))
      )
    )
  )
  (if row (setq rows (cons row rows)))
  (setq rows (reverse rows))
  ;; 行内按 x 从小到大(从左到右)，行内行间全部用顿号连接
  (setq res "")
  (foreach r rows
    (setq r
      (aa:merge-sort r
        (function
          (lambda (a b)
            (if (equal (cadr a) (cadr b) 1e-9)
              (< (nth 4 a) (nth 4 b))
              (< (cadr a) (cadr b))
            )
          )
        )
      )
    )
    (setq line "")
    (foreach it r
      (setq line
        (if (= line "")
          (caddr it)
          (strcat line "、" (caddr it))
        )
      )
    )
    (setq res (if (= res "") line (strcat res "、" line)))
  )
  (list res (length rows))
)

;;   例: ZD1、+KM1、ZD11、-KM1、直流馈线柜、1-2ID4、1(2)B-N4121
;; QW 提取选中文字，同一行用顿号连接，不同行之间也用顿号分隔，并复制到剪贴板
(defun c:QW ( / *error* aa:tag aa:doc aa:undo-open aa:old-cmdecho ss i idx ent ed txt hgt items pt out ok)
  (aa:cmd-begin "QW")
  (setq ss (ssget '((0 . "TEXT,MTEXT"))))
  (if ss
    (progn
      (setq i 0 idx 0 items nil)
      (while (< i (sslength ss))
        (setq ent (ssname ss i))
        (setq ed (entget ent))
        ;; MTEXT 去掉 \T1.001; 等格式码，并拼接超长内容(组码 3)
        (setq txt (aa:ysdl-get-plain-text ed))
        (setq pt (zi:pt ed))
        (setq hgt (cdr (assoc 40 ed)))
        (if (or (null hgt) (<= hgt 0.0)) (setq hgt 0.0))
        (if (and txt (> (strlen txt) 0) pt)
          (progn
            (setq items (cons (list (cadr pt) (car pt) txt hgt idx) items))
            (setq idx (1+ idx))
          )
        )
        (setq i (1+ i))
      )
      (if items
        (progn
          (setq out (qw:join items))
          (setq ok (zi:to-clip (car out)))
          (princ (strcat "\r\n已提取 " (itoa (length items)) " 个文字，共 "
                         (itoa (cadr out)) " 行"
                         (if ok "，并复制到剪贴板。" "，但复制剪贴板失败。")))
        )
        (princ "\r\n选中的对象里没有可提取的文字。")
      )
    )
    (princ "\r\n未选中文字。")
  )
  (aa:cmd-end)
)

;; QW2 提取选中文字及其坐标，每项一行 "x,y 文字"（坐标在前，保留 2 位小数），
;; 按从上到下、从左到右排序，复制到剪贴板
;; 按从上到下、从左到右排序
;; QW2 提取选中文字及坐标，每项一行 "x,y 文字"（坐标在前，保留 2 位小数），复制到剪贴板
(defun c:QW2 ( / *error* aa:tag aa:doc aa:undo-open aa:old-cmdecho ss i idx ent ed txt hgt pt items out ok)
  (aa:cmd-begin "QW2")
  (setq ss (ssget '((0 . "TEXT,MTEXT"))))
  (if ss
    (progn
      (setq i 0 idx 0 items nil)
      (while (< i (sslength ss))
        (setq ent (ssname ss i))
        (setq ed (entget ent))
        ;; MTEXT 去掉 \T1.001; 等格式码，并拼接超长内容(组码 3)
        (setq txt (aa:ysdl-get-plain-text ed))
        (setq pt (zi:pt ed))
        (setq hgt (cdr (assoc 40 ed)))
        (if (or (null hgt) (<= hgt 0.0)) (setq hgt 0.0))
        (if (and txt (> (strlen txt) 0) pt)
          (progn
            (setq items (cons (list (cadr pt) (car pt) txt hgt idx) items))
            (setq idx (1+ idx))
          )
        )
        (setq i (1+ i))
      )
      (if items
        (progn
          ;; 排序: 按 y 从大到小(从上到下), 再按 x 从小到大(从左到右), 序号兜底保证严格比较
          (setq items
            (aa:merge-sort items
              (function
                (lambda (a b)
                  (if (equal (car a) (car b) 1e-9)
                    (if (equal (cadr a) (cadr b) 1e-9)
                      (< (nth 4 a) (nth 4 b))
                      (< (cadr a) (cadr b))
                    )
                    (> (car a) (car b))
                  )
                )
              )
            )
          )
          ;; 每项一行 "x,y 文字"，行间用回车换行
          (setq out "")
          (foreach it items
            (setq out
              (strcat out
                      (rtos (cadr it) 2 2) "," (rtos (car it) 2 2) " " (caddr it)
                      "\r\n"))
          )
          ;; 去掉末尾换行，输出更干净
          (if (> (strlen out) 2)
            (setq out (substr out 1 (- (strlen out) 2))))
          (setq ok (zi:to-clip out))
          (princ (strcat "\r\n已提取 " (itoa (length items)) " 个文字及坐标"
                         (if ok "，并复制到剪贴板。" "，但复制剪贴板失败。")))
        )
        (princ "\r\n选中的对象里没有可提取的文字。")
      )
    )
    (princ "\r\n未选中文字。")
  )
  (aa:cmd-end)
)

;;; QW3: compact, paste-ready inspection of selected CAD entities.
;;; 4 位小数并去掉尾随零：100.0000 -> 100，2.5000 -> 2.5。
(defun aa:qw3-number (value / s)
  (if (numberp value)
    (progn
      (setq s (rtos value 2 4))
      (if (vl-string-search "." s)
        (setq s (vl-string-right-trim "." (vl-string-right-trim "0" s))))
      (if (= s "-0") "0" s))
    "?"))

;;; Z 为 0 时只输出 (x,y)。
(defun aa:qw3-point (pt / z)
  (if (and (listp pt) (numberp (car pt)) (numberp (cadr pt)))
    (progn
      (setq z (if (numberp (caddr pt)) (caddr pt) 0.0))
      (strcat "(" (aa:qw3-number (car pt)) ","
              (aa:qw3-number (cadr pt))
              (if (equal z 0.0 1e-9) "" (strcat "," (aa:qw3-number z)))
              ")"))
    "?"))

;;; 角度（弧度）不为 0 时输出 " | 旋转角=度数"。
(defun aa:qw3-rotation (ang)
  (if (and (numberp ang) (not (equal ang 0.0 1e-9)))
    (strcat " | 旋转角=" (aa:qw3-number (* (/ 180.0 pi) ang)))
    ""))

(defun aa:qw3-escape (value / i ch out)
  (setq value (if value value "") i 1 out "")
  (while (<= i (strlen value))
    (setq ch (substr value i 1)
          out (strcat out
                (cond
                  ((= ch "\"") "\\\"")
                  ((= ch "\\") "\\\\")
                  ((= ch (chr 10)) "\\n")
                  ((= ch (chr 13)) "")
                  (T ch)))
          i (1+ i)))
  (strcat "\"" out "\""))

(defun aa:qw3-color (ed / aci rgb)
  (setq aci (cdr (assoc 62 ed)) rgb (cdr (assoc 420 ed)))
  (cond
    (rgb (strcat "RGB=(" (itoa (fix (/ rgb 65536))) ","
                 (itoa (rem (fix (/ rgb 256)) 256)) ","
                 (itoa (rem rgb 256)) ")"))
    ((null aci) "ByLayer")
    ((= aci 256) "ByLayer")
    ((= aci 0) "ByBlock")
    (T (strcat "ACI=" (itoa aci)))))

(defun aa:qw3-text-align (ed / h v a)
  (if (= (cdr (assoc 0 ed)) "MTEXT")
    (progn
      (setq a (cdr (assoc 71 ed)))
      (if (and a (<= 1 a) (<= a 9))
        (nth (1- a)
          '("左上" "中上" "右上" "左中" "正中" "右中"
            "左下" "中下" "右下"))
        "未知"))
    (progn
      (setq h (cdr (assoc 72 ed))
            v (cdr (assoc (if (member (cdr (assoc 0 ed))
                                   '("ATTRIB" "ATTDEF")) 74 73) ed)))
      (strcat
        (nth (if (and h (<= 0 h) (<= h 5)) h 0)
             '("左" "中" "右" "对齐" "中点" "拟合"))
        (nth (if (and v (<= 0 v) (<= v 3)) v 0)
             '("基线" "下" "中" "上"))))))

(defun aa:qw3-poly-vertices (en ed / typ pair vertex vd pt count shown out)
  (setq typ (cdr (assoc 0 ed)) count 0 shown 0 out "")
  (cond
    ((= typ "LWPOLYLINE")
     (foreach pair ed
       (if (= (car pair) 10)
         (progn
           (setq count (1+ count))
           (if (< shown 100)
             (setq out (strcat out (if (= shown 0) "" ";")
                               (aa:qw3-point (cdr pair)))
                   shown (1+ shown)))))))
    ((= typ "POLYLINE")
     (setq vertex (entnext en))
     (while (and vertex (/= (cdr (assoc 0 (entget vertex))) "SEQEND"))
       (setq vd (entget vertex) pt (cdr (assoc 10 vd)))
       (if (= (cdr (assoc 0 vd)) "VERTEX")
         (progn
           (setq count (1+ count))
           (if (< shown 100)
             (setq out (strcat out (if (= shown 0) "" ";")
                               (aa:qw3-point pt))
                   shown (1+ shown)))))
       (setq vertex (entnext vertex)))))
  (strcat " | 顶点数=" (itoa count)
          (if (= 1 (logand 1 (cond ((cdr (assoc 70 ed))) (T 0))))
            " | 闭合" "")
          " | 顶点=" out
          (if (> count shown)
            (strcat ";…其余" (itoa (- count shown)) "点省略") "")))

(defun aa:qw3-block-attrs (en / next ed out)
  (setq next (if (equal (cdr (assoc 66 (entget en))) 1) (entnext en))
        out "")
  (while (and next (/= (cdr (assoc 0 (entget next))) "SEQEND"))
    (setq ed (entget next))
    (if (= (cdr (assoc 0 ed)) "ATTRIB")
      (setq out (strcat out (if (= out "") "" ";")
                        (cdr (assoc 2 ed)) "="
                        (aa:qw3-escape (cdr (assoc 1 ed))))))
    (setq next (entnext next)))
  (if (= out "") "" (strcat " | 属性=" out)))

(defun aa:qw3-details (en ed / typ raw plain p a b radius angle align sx sy sz)
  (setq typ (cdr (assoc 0 ed)))
  (cond
    ((member typ '("TEXT" "MTEXT" "ATTRIB" "ATTDEF"))
     (setq raw (aa:ysdl-get-raw-text ed)
           plain (if (= typ "MTEXT")
                   (aa:ysdl-strip-mtext-format raw) raw)
           p (cdr (assoc 10 ed))
           align (aa:qw3-text-align ed))
     (strcat " | 内容=" (aa:qw3-escape plain)
             (if (/= raw plain)
               (strcat " | MTEXT原始=" (aa:qw3-escape raw)) "")
             (if (member align '("左基线" "左上")) ""
               (strcat " | 对齐=" align))
             " | 插入点=" (aa:qw3-point (if p (trans p en 0)))
             (if (and (/= typ "MTEXT") (assoc 11 ed)
                      (or (not (equal (cond ((cdr (assoc 72 ed))) (T 0)) 0))
                          (not (equal
                            (cond
                              ((cdr (assoc (if (member typ '("ATTRIB" "ATTDEF"))
                                             74 73) ed)))
                              (T 0)) 0))))
               (strcat " | 对齐点="
                       (aa:qw3-point (trans (cdr (assoc 11 ed)) en 0))) "")
             ;; MTEXT 有 50 组码时方向向量与旋转角重复，只在缺 50 且非 X 轴方向时输出。
             (if (and (= typ "MTEXT") (assoc 11 ed) (not (assoc 50 ed))
                      (not (equal (cdr (assoc 11 ed)) '(1.0 0.0 0.0) 1e-9)))
               (strcat " | 方向向量(DXF)="
                       (aa:qw3-point (cdr (assoc 11 ed)))) "")
             " | 字高=" (aa:qw3-number (cdr (assoc 40 ed)))
             (cond
               ((and (= typ "TEXT") (assoc 41 ed)
                     (not (equal (cdr (assoc 41 ed)) 1.0 1e-9)))
                (strcat " | 宽度系数=" (aa:qw3-number (cdr (assoc 41 ed)))))
               ((and (= typ "MTEXT") (assoc 41 ed)
                     (> (cdr (assoc 41 ed)) 1e-9))
                (strcat " | 文本框宽=" (aa:qw3-number (cdr (assoc 41 ed)))))
               (T ""))
             " | 样式=" (cond ((cdr (assoc 7 ed))) (T "?"))
             (aa:qw3-rotation (cdr (assoc 50 ed)))))
    ((= typ "LINE")
     (setq a (cdr (assoc 10 ed)) b (cdr (assoc 11 ed)))
     (strcat " | 起点=" (aa:qw3-point a)
             " | 终点=" (aa:qw3-point b)
             " | 长度=" (aa:qw3-number (distance a b))))
    ((member typ '("LWPOLYLINE" "POLYLINE"))
     (aa:qw3-poly-vertices en ed))
    ((member typ '("CIRCLE" "ARC"))
     (setq p (cdr (assoc 10 ed)) radius (cdr (assoc 40 ed)))
     (strcat " | 圆心=" (aa:qw3-point (if p (trans p en 0)))
             " | 半径=" (aa:qw3-number radius)
             (if (= typ "ARC")
               (strcat " | 起始角="
                       (aa:qw3-number (* (/ 180.0 pi) (cdr (assoc 50 ed))))
                       " | 终止角="
                       (aa:qw3-number (* (/ 180.0 pi) (cdr (assoc 51 ed)))))
               "")))
    ((= typ "INSERT")
     (setq sx (cond ((cdr (assoc 41 ed))) (T 1.0))
           sy (cond ((cdr (assoc 42 ed))) (T 1.0))
           sz (cond ((cdr (assoc 43 ed))) (T 1.0)))
     (strcat " | 块名=" (cdr (assoc 2 ed))
             " | 插入点=" (aa:qw3-point (trans (cdr (assoc 10 ed)) en 0))
             (if (and (equal sx 1.0 1e-9) (equal sy 1.0 1e-9)
                      (equal sz 1.0 1e-9))
               ""
               (strcat " | 缩放=(" (aa:qw3-number sx) ","
                       (aa:qw3-number sy) "," (aa:qw3-number sz) ")"))
             (aa:qw3-rotation (cdr (assoc 50 ed)))
             (aa:qw3-block-attrs en)))
    ((= typ "DIMENSION")
     (strcat " | 标注样式=" (cond ((cdr (assoc 3 ed))) (T "?"))
             (if (assoc 42 ed)
               (strcat " | 测量值=" (aa:qw3-number (cdr (assoc 42 ed)))) "")
             (if (assoc 1 ed)
               (strcat " | 覆盖文字=" (aa:qw3-escape (cdr (assoc 1 ed)))) "")))
    (T
     (if (assoc 10 ed)
       (strcat " | 参考点=" (aa:qw3-point (cdr (assoc 10 ed)))) ""))))

(defun aa:qw3-record (en idx / ed typ bbox lo hi cx cy line col)
  (setq ed (entget en) typ (cdr (assoc 0 ed))
        bbox (aa:safe-get-bbox nil en))
  (if bbox
    (setq lo (car bbox) hi (cadr bbox)
          cx (/ (+ (car lo) (car hi)) 2.0)
          cy (/ (+ (cadr lo) (cadr hi)) 2.0))
    (setq lo nil hi nil cx 0.0 cy 0.0))
  ;; 颜色/线型为 ByLayer 时省略；直线、圆、圆弧、多段线的范围可由几何推出，也省略。
  (setq line
    (strcat typ
            " | 句柄=" (cond ((cdr (assoc 5 ed))) (T "?"))
            " | 图层=" (cond ((cdr (assoc 8 ed))) (T "?"))
            (if (= (setq col (aa:qw3-color ed)) "ByLayer") ""
              (strcat " | 颜色=" col))
            (if (= (strcase (cond ((cdr (assoc 6 ed))) (T "BYLAYER")))
                   "BYLAYER")
              ""
              (strcat " | 线型=" (cdr (assoc 6 ed))))
            (if (and bbox
                     (not (member typ '("LINE" "CIRCLE" "ARC"
                                        "LWPOLYLINE" "POLYLINE"))))
              (strcat " | 范围=" (aa:qw3-point lo)
                      "~" (aa:qw3-point hi)) "")
            (aa:qw3-details en ed)))
  (list cy cx idx line))

(defun c:QW3 (/ *error* aa:tag aa:doc aa:undo-open aa:old-cmdecho
               ss i items item out ok)
  (setq ss (ssget "_I"))
  (if (null ss)
    (progn
      (princ "\r\n[QW3] 请选择要导出信息的 CAD 对象: ")
      (setq ss (ssget))))
  (if ss
    (progn
      (aa:cmd-begin "QW3")
      (setq i 0 items nil)
      (repeat (sslength ss)
        (setq items (cons (aa:qw3-record (ssname ss i) i) items)
              i (1+ i)))
      (setq items (aa:merge-sort items
                    '(lambda (a b)
                       (if (equal (car a) (car b) 1e-8)
                         (if (equal (cadr a) (cadr b) 1e-8)
                           (< (caddr a) (caddr b))
                           (< (cadr a) (cadr b)))
                         (> (car a) (car b))))))
      (setq out
        (strcat "CAD对象信息 (QW3) 图纸=" (getvar "DWGNAME")
                " | 对象数=" (itoa (sslength ss))
                " | INSUNITS=" (itoa (getvar "INSUNITS"))
                "\r\n说明: 范围/插入点为WCS，顶点为DXF对象坐标，Z=0省略；"
                "未列出的颜色/线型=ByLayer、旋转角=0、缩放=1、对齐=左基线(MTEXT左上)、宽度系数=1"
                "\r\n"))
      (setq i 1)
      (foreach item items
        (setq out (strcat out "[" (itoa i) "] " (nth 3 item) "\r\n")
              i (1+ i)))
      (setq ok (zi:to-clip out))
      (aa:cmd-end)
      (princ (strcat "\r\n[QW3] 已整理 " (itoa (sslength ss))
                     " 个对象的信息"
                     (if ok "并复制到剪贴板。" "，但复制剪贴板失败。"))))
    (princ "\r\n[QW3] 未选择对象。"))
  (princ))

;; 白色及其他颜色与 QW2 相同，每项一行 "x,y 文字"；青色为 "x,y 文字 端子名"
;; DX1 提取选中文字及坐标，青色文字额外标注“端子名”，复制到剪贴板
(defun c:DX1 ( / *error* aa:tag aa:doc aa:undo-open aa:old-cmdecho ss i idx ent ed txt hgt pt items out ok suffix cyan-n)
  (aa:cmd-begin "DX1")
  (setq ss (ssget '((0 . "TEXT,MTEXT"))))
  (if ss
    (progn
      (setq i 0 idx 0 items nil cyan-n 0)
      (while (< i (sslength ss))
        (setq ent (ssname ss i))
        (setq ed (entget ent))
        (setq txt (cdr (assoc 1 ed)))
        (setq pt (zi:pt ed))
        (setq hgt (cdr (assoc 40 ed)))
        (if (or (null hgt) (<= hgt 0.0)) (setq hgt 0.0))
        (if (and txt (> (strlen txt) 0) pt)
          (progn
            (if (= (dx:color-kind ent) 'CYAN)
              (progn
                (setq suffix " 端子名")
                (setq cyan-n (1+ cyan-n))
              )
              (setq suffix "")
            )
            (setq items (cons (list (cadr pt) (car pt) txt hgt idx suffix) items))
            (setq idx (1+ idx))
          )
        )
        (setq i (1+ i))
      )
      (if items
        (progn
          ;; 排序: 按 y 从大到小(从上到下), 再按 x 从小到大(从左到右), 序号兜底保证严格比较
          (setq items
            (aa:merge-sort items
              (function
                (lambda (a b)
                  (if (equal (car a) (car b) 1e-9)
                    (if (equal (cadr a) (cadr b) 1e-9)
                      (< (nth 4 a) (nth 4 b))
                      (< (cadr a) (cadr b))
                    )
                    (> (car a) (car b))
                  )
                )
              )
            )
          )
          ;; 每项一行 "x,y 文字"，青色追加 " 端子名"
          (setq out "")
          (foreach it items
            (setq out
              (strcat out
                      (rtos (cadr it) 2 2) "," (rtos (car it) 2 2) " " (caddr it) (nth 5 it)
                      "\r\n"))
          )
          ;; 去掉末尾换行，输出更干净
          (if (> (strlen out) 2)
            (setq out (substr out 1 (- (strlen out) 2))))
          (setq ok (zi:to-clip out))
          (princ (strcat "\r\n已提取 " (itoa (length items)) " 个文字及坐标"
                         (if (> cyan-n 0)
                           (strcat "，其中 " (itoa cyan-n) " 个青色文字已标注端子名")
                           "")
                         (if ok "，并复制到剪贴板。" "，但复制剪贴板失败。")))
        )
        (princ "\r\n选中的对象里没有可提取的文字。")
      )
    )
    (princ "\r\n未选中文字。")
  )
  (aa:cmd-end)
)

(princ)


;; ============================================================
;; CE  测量点序列形成的多段线总长度
;; ============================================================

;;; CE - 测量点序列形成的多段线总长度
;;; 输入 CE 后依次点击若干点, 回车/空格结束, 输出总长度
;;; 点击过程中用带宽度的临时 LWPOLYLINE 实体做预览,
;;; 缩放/平移/REGEN 都不会被擦掉, 结束后自动删除预览, 仅输出长度

;; 用确认的点列重建预览多段线, 返回新实体名
(defun ce-redraw (pts w / lst)
  (setq lst
    (list '(0 . "LWPOLYLINE")
          '(100 . "AcDbEntity")
          '(100 . "AcDbPolyline")
          (cons 90 (length pts))
          '(70 . 0)
          (cons 43 w)   ;; 全局宽度
          '(62 . 1)))   ;; 颜色: 红
  (foreach p pts
    (setq lst (append lst (list (cons 10 (list (car p) (cadr p)))))))
  (entmake lst)
  (entlast)
)

;; CE 测量点序列形成的多段线总长度
(defun c:CE (/ *error* aa:tag aa:doc aa:undo-open aa:old-cmdecho pt pts total i p1 p2 tmp w)
  (aa:cmd-begin "CE")
  (setq pts '())
  (setq pt (getpoint "\r\n请点击第一个点 (回车/空格结束): "))
  (while pt
    (setq pts (cons pt pts))
    ;; 宽度取当前视图高度的比例, 任意图纸尺度下都明显
    (setq w (/ (getvar "VIEWSIZE") 50.0))
    (if tmp (entdel tmp))
    (if (>= (length pts) 2)
      (setq tmp (ce-redraw (reverse pts) w)))
    ;; (car pts) 为最近确认点, 作为当前段的橡皮筋基点
    (setq pt (getpoint (car pts) "\r\n请点击下一个点 (回车/空格结束): "))
  )
  (if tmp (entdel tmp)) ;; 删除预览, 只测量不留实体
  (setq pts (reverse pts))
  (if (< (length pts) 2)
    (princ "\r\n点数不足, 至少需要两个点。")
    (progn
      (setq total 0.0 i 0)
      (while (< (1+ i) (length pts))
        (setq p1 (nth i pts)
              p2 (nth (1+ i) pts)
              total (+ total (distance p1 p2))
              i (1+ i))
      )
      (princ (strcat "\r\n共点击 " (itoa (length pts)) " 个点, 多段线总长度 = " (rtos total 2 4)))
    )
  )
  (aa:cmd-end)
)
(princ)

;; ============================================================
;; AW  自动微移文字避让
;;   先选择很多文字，再输入 AW；如果选择集中夹杂其他对象，只处理 TEXT/MTEXT。
;;   程序按文字包围框检查附近对象，在上、下、右、左及右上、左上、右下、左下
;;   共 8 个方向小幅搜索移动，目标是让文字包围框不再与线、文字或其他图元重叠。
;; ============================================================

(setq aw:gap-factor 0.03)     ; 避让余量，按文字高度折算
(setq aw:min-gap 0.3)         ; 最小避让容差（至少相差 0.3mm）
(setq aw:step-factor 0.15)    ; 每次尝试移动量，按文字高度折算
(setq aw:max-try 28)          ; 每个方向最多尝试次数

(defun aw:max2 (a b)
  (if (> a b) a b)
)

(defun aw:3d (p)
  (if (= (length p) 2)
    (list (car p) (cadr p) 0.0)
    p
  )
)

(defun aw:v+ (a b)
  (mapcar '+ (aw:3d a) (aw:3d b))
)

(defun aw:v* (v k)
  (mapcar '(lambda (x) (* x k)) (aw:3d v))
)

(defun aw:ucs-disp->wcs (v)
  (trans (aw:3d v) 1 0 T)
)

(defun aw:bbox (obj / mn mx r)
  (setq r (vl-catch-all-apply 'vla-getboundingbox (list obj 'mn 'mx)))
  (if (vl-catch-all-error-p r)
    nil
    (list (vlax-safearray->list mn) (vlax-safearray->list mx))
  )
)

(defun aw:bbox-move (bb v)
  (list (aw:v+ (car bb) v) (aw:v+ (cadr bb) v))
)

(defun aw:bbox-size (bb / mn mx)
  (setq mn (car bb) mx (cadr bb))
  (list (abs (- (car mx) (car mn)))
        (abs (- (cadr mx) (cadr mn)))
        (abs (- (caddr mx) (caddr mn))))
)

(defun aw:expand-bbox (bb gap / mn mx)
  (setq mn (car bb) mx (cadr bb))
  (list (list (- (car mn) gap) (- (cadr mn) gap) (- (caddr mn) gap))
        (list (+ (car mx) gap) (+ (cadr mx) gap) (+ (caddr mx) gap)))
)

(defun aw:bbox->ucs-window (bb / mn mx p1 p2 p3 p4 pts xs ys)
  (setq mn (car bb) mx (cadr bb))
  (setq p1 (trans (list (car mn) (cadr mn) 0.0) 0 1))
  (setq p2 (trans (list (car mx) (cadr mn) 0.0) 0 1))
  (setq p3 (trans (list (car mx) (cadr mx) 0.0) 0 1))
  (setq p4 (trans (list (car mn) (cadr mx) 0.0) 0 1))
  (setq pts (list p1 p2 p3 p4))
  (setq xs (mapcar 'car pts))
  (setq ys (mapcar 'cadr pts))
  (list (list (apply 'min xs) (apply 'min ys) 0.0)
        (list (apply 'max xs) (apply 'max ys) 0.0))
)

(defun aw:ss-has-other-p (ss self / i en found)
  (setq i 0 found nil)
  (while (and ss (< i (sslength ss)) (not found))
    (setq en (ssname ss i))
    (if (/= en self)
      (setq found T)
    )
    (setq i (1+ i))
  )
  found
)

(defun aw:blocked-p (self bb gap / win ss)
  (setq win (aw:bbox->ucs-window (aw:expand-bbox bb gap)))
  (setq ss (ssget "_C" (car win) (cadr win)))
  (aw:ss-has-other-p ss self)
)

(defun aw:try-offset (self basebb gap step / dirs n d v cand ok)
  (setq dirs
    (list
      (list 0.0 1.0 0.0)          ; 上
      (list 0.0 -1.0 0.0)         ; 下
      (list 1.0 0.0 0.0)          ; 右
      (list -1.0 0.0 0.0)         ; 左
      (list 0.707107 0.707107 0.0)   ; 右上
      (list -0.707107 0.707107 0.0)  ; 左上
      (list 0.707107 -0.707107 0.0)  ; 右下
      (list -0.707107 -0.707107 0.0) ; 左下
    )
  )
  (setq n 1 ok nil)
  (while (and (<= n aw:max-try) (not ok))
    (foreach d dirs
      (if (not ok)
        (progn
          (setq v (aw:ucs-disp->wcs (aw:v* d (* step n))))
          (setq cand (aw:bbox-move basebb v))
          (if (not (aw:blocked-p self cand gap))
            (setq ok v)
          )
        )
      )
    )
    (setq n (1+ n))
  )
  ok
)

(defun aw:move-object (obj v / r)
  (setq r
    (vl-catch-all-apply
      'vla-move
      (list obj (vlax-3d-point '(0.0 0.0 0.0)) (vlax-3d-point v))
    )
  )
  (not (vl-catch-all-error-p r))
)

(defun aw:text-unit (en bb / ed h sz w)
  (setq ed (entget en))
  (setq h (cdr (assoc 40 ed)))
  (if (and h (> h 1.0e-8))
    h
    (progn
      (setq sz (aw:bbox-size bb))
      (setq w (car sz))
      (setq h (cadr sz))
      (cond
        ((and h (> h 1.0e-8)) h)
        ((and w (> w 1.0e-8)) w)
        (T 1.0)
      )
    )
  )
)

(defun aw:process-one (en / obj bb unit gap step v res)
  (setq obj (vlax-ename->vla-object en))
  (setq bb (aw:bbox obj))
  (setq res
    (if bb
      (progn
        (setq unit (aw:text-unit en bb))
        (setq gap (aw:max2 (* unit aw:gap-factor) (if aw:min-gap aw:min-gap 0.3)))
        (setq step (aw:max2 (* unit aw:step-factor) 1.0e-8))
        (if (aw:blocked-p en bb gap)
          (progn
            (setq v (aw:try-offset en bb gap step))
            (if v
              (if (aw:move-object obj v) 1 -1)
              -1
            )
          )
          0
        )
      )
      -1
    )
  )
  (vlax-release-object obj)
  res
)
(defun aw:get-selection (/ ss)
  (setq ss (ssget "_I" '((0 . "TEXT,MTEXT"))))
  (if (not ss)
    (setq ss (ssget '((0 . "TEXT,MTEXT"))))
  )
  ss
)

(defun c:AW (/ *error* doc ss i en r moved clean fail total)
  (vl-load-com)
  (setq doc (vla-get-ActiveDocument (vlax-get-acad-object)))
  (defun *error* (msg)
    (if doc
      (vl-catch-all-apply 'vla-EndUndoMark (list doc))
    )
    (sssetfirst nil nil)
    (if (and msg (/= msg "Function cancelled") (/= msg "quit / exit abort"))
      (princ (strcat "\r\nAW 出错：" msg))
    )
    (princ)
  )
  (setq ss (aw:get-selection))
  (if ss
    (progn
      (vl-catch-all-apply 'vla-StartUndoMark (list doc))
      (setq i 0 moved 0 clean 0 fail 0 total (sslength ss))
      (while (< i total)
        (setq en (ssname ss i))
        (setq r (aw:process-one en))
        (cond
          ((= r 1) (setq moved (1+ moved)))
          ((= r 0) (setq clean (1+ clean)))
          (T (setq fail (1+ fail)))
        )
        (setq i (1+ i))
      )
      (vl-catch-all-apply 'vla-EndUndoMark (list doc))
      (sssetfirst nil nil)
      (princ
        (strcat
          "\r\nAW 完成：共 " (itoa total)
          " 个文字，移动 " (itoa moved)
          " 个，原本无需移动 " (itoa clean)
          " 个，未找到合适位置 " (itoa fail) " 个。"
        )
      )
    )
    (princ "\r\nAW：未选中文字。")
  )
  (princ)
)

(princ)

;;; ---------------- 用户可修改参数 ----------------
(setq *TKTJ-COL-OFFSETS* '(5.0 12.0 62.0)) ; 序号列中心；图号/图名距左边线约 2
(setq *TKTJ-ROW-GAP* 9.0)                 ; 目录表每行高度
(setq *TKTJ-TEXT-HEIGHT* 4.0)
(setq *TKTJ-TEXT-STYLE* "宋体")
(setq *TKTJ-TEXT-FONTFILE* "simsun.ttc")
(setq *TKTJ-TEXT-WIDTH-FACTOR* 0.8)
(setq *TKTJ-OUTPUT-HEADER* nil)            ; 只输出正文，不生成“序号/图号/图名”表头
(setq *TKTJ-SORT-BY-POSITION* T)
(setq *TKTJ-ROW-SORT-TOL* 500.0)
(setq *TKTJ-SORT-BY-PAGE* nil)

;;; ---------------- 字段候选映射 ----------------
(setq *TKTJ-SHEETNO-TAGS*
       '("图号"))

(setq *TKTJ-SHEETNAME-TAGS*
       '("图名"))

(setq *TKTJ-PAGE-TAGS*
       '("页码" "页号" "PAGE" "SHEET"))

(setq *TKTJ-ARCHIVE-TAGS*
       '("图号" "档号" "文件号" "DWGNO" "DRAWINGNO"))

;;; ---------------- 基础工具函数 ----------------
(defun tktj:trim (s)
  (if s
    (vl-string-trim " \t\r\n" (vl-princ-to-string s))
    ""
  )
)

(defun tktj:norm-tag (s)
  ;; strcase 可处理英文大小写；中文会保持可匹配状态。
  (strcase (tktj:trim s))
)

(defun tktj:current-space (/ doc)
  ;; 在模型空间、布局图纸空间、布局视口内分别写入当前工作空间。
  (setq doc (vla-get-ActiveDocument (vlax-get-acad-object)))
  (cond
    ((= 1 (getvar "TILEMODE")) (vla-get-ModelSpace doc))
    ((= 1 (getvar "CVPORT")) (vla-get-PaperSpace doc))
    (T (vla-get-ModelSpace doc))
  )
)

(defun tktj:ensure-text-style (/ doc styles style)
  ;; 优先使用“宋体”文字样式；不存在时创建，并尽量绑定宋体字体文件。
  (setq doc (vla-get-ActiveDocument (vlax-get-acad-object)))
  (setq styles (vla-get-TextStyles doc))
  (setq style (vl-catch-all-apply 'vla-Item (list styles *TKTJ-TEXT-STYLE*)))
  (if (vl-catch-all-error-p style)
    (setq style (vl-catch-all-apply 'vla-Add (list styles *TKTJ-TEXT-STYLE*)))
  )
  (if (not (vl-catch-all-error-p style))
    (progn
      (vl-catch-all-apply 'vla-put-FontFile (list style *TKTJ-TEXT-FONTFILE*))
      (vl-catch-all-apply 'vla-put-Width (list style *TKTJ-TEXT-WIDTH-FACTOR*))
      *TKTJ-TEXT-STYLE*
    )
    (getvar "TEXTSTYLE")
  )
)

(defun tktj:safe-vla-object (ent / r)
  (setq r (vl-catch-all-apply 'vlax-ename->vla-object (list ent)))
  (if (vl-catch-all-error-p r)
    nil
    r
  )
)

(defun tktj:safe-property (obj prop / r)
  (setq r (vl-catch-all-apply 'vlax-get-property (list obj prop)))
  (if (vl-catch-all-error-p r)
    nil
    r
  )
)

(defun tktj:safe-getattributes (blk / r)
  (setq r (vl-catch-all-apply 'vlax-invoke (list blk 'GetAttributes)))
  (if (vl-catch-all-error-p r)
    nil
    r
  )
)

(defun tktj:assoc-data (key data)
  (cdr (assoc key data))
)

(defun tktj:block-point (blockObj / p)
  (setq p (tktj:safe-property blockObj 'InsertionPoint))
  (if p
    (progn
      (setq p (vl-catch-all-apply 'vlax-safearray->list (list (vlax-variant-value p))))
      (if (vl-catch-all-error-p p)
        nil
        (list (car p) (cadr p) (if (caddr p) (caddr p) 0.0))
      )
    )
    nil
  )
)

(defun tktj:all-digits-p (s)
  (and (> (strlen s) 0)
       (not (wcmatch s "*[~0-9]*")))
)

(defun tktj:page-number (s / n)
  (setq s (tktj:trim s))
  (if (tktj:all-digits-p s)
    (progn
      (setq n (atoi s))
      n
    )
    2147483647
  )
)

(defun tktj:clean-val (s)
  ;; 清理属性值中的所有 MTEXT 格式控制码（如 \W0.80000;、\A1; 等）及换行符
  ;; 确保目录表格单行输出整洁纯净
  (if (or (null s) (= s ""))
    ""
    (progn
      (setq s (aae:clean-mtext-format s nil))
      (setq s (aa:str-replace-all "\r\n" "" s))
      (setq s (aa:str-replace-all "\n" "" s))
      (setq s (aa:str-replace-all "\r" "" s))
      (tktj:trim s)
    )
  )
)

(defun tktj:get-attributes (blockObj / atts att tag val result hasAtts)
  ;; 返回原始 TagString 关联表，例如 (("图名" . "xxx") ("页码" . "3"))。
  (setq result nil)
  (setq hasAtts (tktj:safe-property blockObj 'HasAttributes))
  (if (= :vlax-true hasAtts)
    (progn
      (setq atts (tktj:safe-getattributes blockObj))
      (foreach att atts
        (setq tag (tktj:safe-property att 'TagString))
        (setq val (tktj:safe-property att 'TextString))
        (setq tag (tktj:trim tag))
        (setq val (tktj:clean-val val))
        (if (> (strlen tag) 0)
          (setq result (append result (list (cons tag val))))
        )
        (vlax-release-object att)
      )
    )
  )
  result
)

(defun tktj:get-first-pair (attrs candidates skipTags / cand found pair tag val)
  ;; 按候选字段优先级返回 (原始Tag . 值)，可通过 skipTags 避免复用同一字段。
  (setq found nil)
  (foreach cand candidates
    (if (not found)
      (foreach pair attrs
        (if (not found)
          (progn
            (setq tag (car pair))
            (setq val (tktj:trim (cdr pair)))
            (if (and (> (strlen val) 0)
                     (= (tktj:norm-tag tag) (tktj:norm-tag cand))
                     (not (member (tktj:norm-tag tag) skipTags)))
              (setq found (cons tag val))
            )
          )
        )
      )
    )
  )
  found
)

(defun tktj:get-first-value (attrs candidates / pair)
  ;; 根据候选字段列表，从属性表中取第一个非空值。
  (setq pair (tktj:get-first-pair attrs candidates nil))
  (if pair (cdr pair) "")
)

(defun tktj:collect-one-block (blockObj / attrs namePair noPair page archive insPt)
  ;; 只有同一个块内同时找到“图号”和“图名”时，才返回一条目录数据。
  (setq attrs (tktj:get-attributes blockObj))
  (if attrs
    (progn
      (setq insPt (tktj:block-point blockObj))
      (setq namePair (tktj:get-first-pair attrs *TKTJ-SHEETNAME-TAGS* nil))
      (setq noPair (tktj:get-first-pair attrs *TKTJ-SHEETNO-TAGS* nil))
      (setq page (tktj:get-first-value attrs *TKTJ-PAGE-TAGS*))
      (setq archive (tktj:get-first-value attrs *TKTJ-ARCHIVE-TAGS*))
      (if (and noPair namePair insPt)
        (list
          (cons 'sheetNo (cdr noPair))
          (cons 'sheetName (cdr namePair))
          (cons 'page page)
          (cons 'archive archive)
          (cons 'x (car insPt))
          (cons 'y (cadr insPt))
        )
        nil
      )
    )
    nil
  )
)

;;; ---------------- 文字输出 ----------------
(defun tktj:add-text (pt txt alignMode cs styleName / obj result)
  ;; 优化：cs 和 styleName 由调用方预获取后传入，避免每次调用重复查询 ActiveX 对象。
  ;; 在当前空间插入带垂直居中的单行文字，图层/颜色默认 ByLayer。
  (setq obj
        (vla-AddText
          cs
          (if txt (vl-princ-to-string txt) "")
          (vlax-3d-point pt)
          *TKTJ-TEXT-HEIGHT*
        )
  )
  (vla-put-Layer obj (getvar "CLAYER"))
  (vla-put-StyleName obj styleName)
  (setq result (vl-catch-all-apply 'vla-put-Alignment (list obj alignMode)))
  (if (not (vl-catch-all-error-p result))
    (vl-catch-all-apply 'vla-put-TextAlignmentPoint
                        (list obj (vlax-3d-point pt))))
  (vl-catch-all-apply 'vla-put-ScaleFactor (list obj *TKTJ-TEXT-WIDTH-FACTOR*))
  obj
)

(defun tktj:nth-offset (n offsets / rest)
  (setq rest offsets)
  (while (and (> n 0) rest)
    (setq rest (cdr rest))
    (setq n (1- n))
  )
  (if rest (car rest) 0.0)
)

(defun tktj:draw-row (base rowIndex values cs styleName / x y col pt alignMode)
  ;; 优化：cs 和 styleName 由 draw-table 预获取后传入。
  ;; base 是整个目录表左上角；文字锚点位于每行垂直中心线。
  (setq y (- (cadr base) (* (+ rowIndex 0.5) *TKTJ-ROW-GAP*)))
  (setq col 0)
  (foreach txt values
    (setq x (+ (car base) (tktj:nth-offset col *TKTJ-COL-OFFSETS*)))
    (setq pt (list x y (if (caddr base) (caddr base) 0.0)))
    ;; 序号列水平居中；图号、图名左对齐并统一垂直居中。
    (setq alignMode (if (= col 0) 10 9))
    (tktj:add-text pt txt alignMode cs styleName)
    (setq col (1+ col))
  )
)

(defun tktj:take (dataList count / out rest n)
  (setq out nil rest dataList n 0)
  (while (and rest (< n count))
    (setq out (append out (list (car rest)))
          rest (cdr rest)
          n (1+ n)))
  out
)

(defun tktj:drop (dataList count / rest n)
  (setq rest dataList n 0)
  (while (and rest (< n count))
    (setq rest (cdr rest)
          n (1+ n)))
  rest
)

(defun tktj:draw-table (dataList basePt startIndex / rowIndex item values cs styleName)
  ;; 优化：一次性预获取 currentSpace 和 styleName，传入 draw-row/add-text，
  ;; 避免每个文字单元重复进行 COM 查询（每页 22~26 行 × 3 列 = 66~78 次）。
  ;; 根据数据列表、起点序号和基点生成一页三列目录文字。
  (setq cs       (tktj:current-space)
        styleName (tktj:ensure-text-style)
        rowIndex 0)
  (if *TKTJ-OUTPUT-HEADER*
    (progn
      (tktj:draw-row basePt rowIndex '("序号" "图号" "图名") cs styleName)
      (setq rowIndex (1+ rowIndex))
    )
  )
  (foreach item dataList
    (setq values
           (list
             (itoa (+ 1 startIndex rowIndex))
             (tktj:assoc-data 'sheetNo item)
             (tktj:assoc-data 'sheetName item)
           )
    )
    (tktj:draw-row basePt rowIndex values cs styleName)
    (setq rowIndex (1+ rowIndex))
  )
  dataList
)

;;; ---------------- 排序 ----------------
(defun tktj:sort-by-page (dataList)
  ;; 数字页码从小到大；非数字页码排到最后。
  (aa:merge-sort
    dataList
    '(lambda (a b)
       (< (tktj:page-number (tktj:assoc-data 'page a))
          (tktj:page-number (tktj:assoc-data 'page b)))
     )
  )
)

(defun tktj:sort-by-position (dataList / sorted rows row rowY item y result)
  ;; 图面阅读顺序：先按上方优先分行，Y 相差容差内视为同一行；行内左侧优先。
  (setq sorted
        (aa:merge-sort
          dataList
          '(lambda (a b / ay by)
             (setq ay (tktj:assoc-data 'y a))
             (setq by (tktj:assoc-data 'y b))
             (if (= ay by)
               (< (tktj:assoc-data 'x a)
                  (tktj:assoc-data 'x b))
               (> ay by)
             )
           )
        )
  )
  (foreach item sorted
    (setq y (tktj:assoc-data 'y item))
    (if (or (not rowY) (> (abs (- rowY y)) *TKTJ-ROW-SORT-TOL*))
      (progn
        (if row (setq rows (append rows (list row))))
        (setq row (list item))
        (setq rowY y)
      )
      (setq row (append row (list item)))
    )
  )
  (if row (setq rows (append rows (list row))))
  (foreach row rows
    (setq result
          (append
            result
            (aa:merge-sort
              row
              '(lambda (a b)
                 (< (tktj:assoc-data 'x a)
                    (tktj:assoc-data 'x b))
               )
            )
          )
    )
  )
  result
)

;;; ---------------- 主命令 ----------------
(defun c:ZDML (/ *error* aa:tag aa:doc aa:undo-open aa:old-cmdecho ss i ent obj one data basePt skipped remaining pageData pageCap
                pageNo startIndex point written)
  (aa:cmd-begin "ZDML")
  (vl-load-com)
  (princ "\r\n请选择需要统计的图框块: ")
  (setq ss (ssget '((0 . "INSERT"))))
  (cond
    ((not ss)
     (princ "\r\n已取消。")
    )
    (T
     (setq i 0)
     (setq data nil)
     (setq skipped 0)
     (while (< i (sslength ss))
       (setq ent (ssname ss i))
       (setq obj (tktj:safe-vla-object ent))
       (setq one (if obj (tktj:collect-one-block obj) nil))
       (if obj (vlax-release-object obj))
       (if one
         (setq data (append data (list one)))
         (setq skipped (1+ skipped))
       )
       (setq i (1+ i))
     )
     (if (not data)
       (princ "\r\n未选择有效图框块")
       (progn
         (cond
           (*TKTJ-SORT-BY-PAGE*
            (setq data (tktj:sort-by-page data))
           )
           (*TKTJ-SORT-BY-POSITION*
            (setq data (tktj:sort-by-position data))
           )
         )
         ;; 第一页最多 22 条，后续每页最多 26 条；每页分别点击目录表左上角。
         (setq remaining data
               pageNo 1
               startIndex 0
               written 0
               basePt (getpoint "\r\n指定第 1 页目录表左上角: "))
         (if basePt
           (progn
             (while remaining
               (setq pageCap (if (= pageNo 1) 22 26)
                     pageData (tktj:take remaining pageCap))
               (tktj:draw-table pageData basePt startIndex)
               (setq written (+ written (length pageData))
                     startIndex written
                     remaining (tktj:drop remaining pageCap))
               (if remaining
                 (progn
                   (setq pageNo (1+ pageNo)
                         point (getpoint
                           (strcat "\r\n指定第 " (itoa pageNo) " 页目录表左上角: ")))
                   (if point
                     (setq basePt point)
                     (setq remaining nil))))
             (if (= written (length data))
               (princ
                 (strcat
                   "\r\n已提取 " (itoa written)
                   " 个图框属性并生成 " (itoa pageNo) " 页目录。跳过 "
                   (itoa skipped) " 个无效或不兼容图框。"))
               (princ
                 (strcat "\r\n已生成前 " (itoa written)
                         " 个目录项，后续页面已取消。")))
           (princ "\r\n已取消。")
         )
       )
     )
    )
  )
  (princ)
)
)
  (aa:cmd-end)
)

;;; =======================================================================================
;;;              --- ZDML2 命令: 基于块参照指定图名图号矩形范围提取生成目录 ---
;;; =======================================================================================

(defun zdml2:extract-rect-text-fast (pt1 pt2 allTexts / minX maxX minY maxY listText res item val ins10 ins11)
  ;; 优化版：在内存缓存中极速检索指定矩形窗口内的所有 TEXT / MTEXT
  ;; - 用 car/cadr/caddr/cadddr 替代 nth，避免链表遍历开销
  ;; - 只有命中多于 1 条时才调用排序
  (setq minX (min (car pt1) (car pt2))
        maxX (max (car pt1) (car pt2))
        minY (min (cadr pt1) (cadr pt2))
        maxY (max (cadr pt1) (cadr pt2)))
  (setq listText '())
  (foreach item allTexts
    (setq val   (cadr item)
          ins10 (caddr item)
          ins11 (cadddr item))
    (cond
      ((and ins10
            (>= (car ins10) (- minX 1e-4))
            (<= (car ins10) (+ maxX 1e-4))
            (>= (cadr ins10) (- minY 1e-4))
            (<= (cadr ins10) (+ maxY 1e-4)))
       (setq listText (cons (list ins10 val) listText)))
      ((and ins11
            (>= (car ins11) (- minX 1e-4))
            (<= (car ins11) (+ maxX 1e-4))
            (>= (cadr ins11) (- minY 1e-4))
            (<= (cadr ins11) (+ maxY 1e-4)))
       (setq listText (cons (list ins11 val) listText)))
    )
  )
  (cond
    ((null listText) "")
    ;; 单条命中：无需排序，直接返回
    ((null (cdr listText)) (cadr (car listText)))
    ;; 多条命中：按 Y 从上到下、X 从左到右排序后拼接
    (T
     (setq listText
           (aa:merge-sort
             listText
             '(lambda (a b / ya yb)
                (setq ya (cadr (car a))
                      yb (cadr (car b)))
                (if (< (abs (- ya yb)) 3.0)
                  (< (car (car a)) (car (car b)))
                  (> ya yb)
                )
              )
           ))
     (setq res "")
     (foreach item listText
       (if (= res "")
         (setq res (cadr item))
         (setq res (strcat res " " (cadr item)))
       )
     )
     (tktj:trim res)
    )
  )
)

(defun c:ZDML2 (/ *error* aa:tag aa:doc aa:undo-open aa:old-cmdecho
                   baseEnt baseObj baseIns targetName
                   noP1 noP2 nameP1 nameP2
                   no-dx1 no-dy1 no-dx2 no-dy2
                   name-dx1 name-dy1 name-dx2 name-dy2
                   ss blkList i blk sorted allTexts spatialIdx
                   data tgtIns tgtNoP1 tgtNoP2 tgtNameP1 tgtNameP2
                   sheetNo sheetName one
                   remaining pageNo startIndex written basePt pageCap pageData)
  (aa:cmd-begin "ZDML2")
  (vl-load-com)

  ;; 1. 提示选择基准图框块
  (setq baseEnt (car (entsel "\r\n[ZDML2] 请点击选择基准图框块参照: ")))
  (cond
    ((null baseEnt)
     (princ "\r\n[ZDML2] 未选择对象，命令已退出。")
    )
    ((/= (cdr (assoc 0 (entget baseEnt))) "INSERT")
     (princ "\r\n[ZDML2] 所选对象不是块参照，命令已退出。")
    )
    (T
     (setq baseObj (vlax-ename->vla-object baseEnt)
           baseIns (blk-insertpt baseObj)
           targetName (hao2:block-name baseObj))
     (vlax-release-object baseObj)

     ;; 2. 指定图号矩形范围
     (princ "\r\n[ZDML2] 请指定【图号】所在矩形的第一个角点: ")
     (setq noP1 (getpoint))
     (if (null noP1)
       (princ "\r\n[ZDML2] 未指定角点，命令已退出。")
       (progn
         (princ "\r\n[ZDML2] 请指定【图号】所在矩形的对角点: ")
         (setq noP2 (getcorner noP1))
         (if (null noP2)
           (princ "\r\n[ZDML2] 未指定对角点，命令已退出。")
           (progn
             (setq no-dx1 (- (min (car noP1) (car noP2)) (car baseIns))
                   no-dy1 (- (min (cadr noP1) (cadr noP2)) (cadr baseIns))
                   no-dx2 (- (max (car noP1) (car noP2)) (car baseIns))
                   no-dy2 (- (max (cadr noP1) (cadr noP2)) (cadr baseIns)))

             ;; 3. 指定图名矩形范围
             (princ "\r\n[ZDML2] 请指定【图名】所在矩形的第一个角点: ")
             (setq nameP1 (getpoint))
             (if (null nameP1)
               (princ "\r\n[ZDML2] 未指定角点，命令已退出。")
               (progn
                 (princ "\r\n[ZDML2] 请指定【图名】所在矩形的对角点: ")
                 (setq nameP2 (getcorner nameP1))
                 (if (null nameP2)
                   (princ "\r\n[ZDML2] 未指定对角点，命令已退出。")
                   (progn
                     (setq name-dx1 (- (min (car nameP1) (car nameP2)) (car baseIns))
                           name-dy1 (- (min (cadr nameP1) (cadr nameP2)) (cadr baseIns))
                           name-dx2 (- (max (car nameP1) (car nameP2)) (car baseIns))
                           name-dy2 (- (max (cadr nameP1) (cadr nameP2)) (cadr baseIns)))

                     ;; 4. 框选要统计的图框块
                     (princ (strcat "\r\n[ZDML2] 请框选所有需要提取的图框块 [块名: " targetName "]: "))
                     (setq ss (ssget (list '(0 . "INSERT"))))
                     (if (null ss)
                       (princ "\r\n[ZDML2] 未选择图框块，命令已退出。")
                       (progn
                         (setq blkList '()
                               i 0)
                         (repeat (sslength ss)
                           (setq blk (vlax-ename->vla-object (ssname ss i)))
                           (if (= (strcase (hao2:block-name blk)) (strcase targetName))
                             (setq blkList (cons blk blkList))
                             (vlax-release-object blk)
                           )
                           (setq i (1+ i))
                         )

                         (if (null blkList)
                           (princ (strcat "\r\n[ZDML2] 所选对象中未找到与基准块同名 [" targetName "] 的图框块。"))
                           (progn
                             ;; 5. 排序：从上到下，从左到右
                             (setq sorted (hao2:sort-blocks blkList))
                             (princ (strcat "\r\n[ZDML2] 成功识别 " (itoa (length sorted)) " 个图框块，正在准备文字数据..."))

                             ;; 一次性预收集图纸中所有 TEXT/MTEXT，并建立空间分桶索引加速后续检索
                             (setq allTexts (zdml2:collect-all-texts)
                                   spatialIdx (zdml2:build-spatial-index allTexts))
                             (princ (strcat "\r\n[ZDML2] 已缓存 " (itoa (length allTexts)) " 条文字，正在提取图号/图名..."))

                             ;; 6. 依次在每个块的对应矩形区域内极速提取图号和图名
                             ;; 优化：data 改为 cons 累积 + 最终 reverse，避免 O(N²) 的 append
                             (setq data '())
                             (foreach blk sorted
                               (setq tgtIns (blk-insertpt blk)
                                     tgtNoP1 (list (+ (car tgtIns) no-dx1) (+ (cadr tgtIns) no-dy1))
                                     tgtNoP2 (list (+ (car tgtIns) no-dx2) (+ (cadr tgtIns) no-dy2))
                                     tgtNameP1 (list (+ (car tgtIns) name-dx1) (+ (cadr tgtIns) name-dy1))
                                     tgtNameP2 (list (+ (car tgtIns) name-dx2) (+ (cadr tgtIns) name-dy2))
                                     ;; 利用空间索引先筛选候选文字，再精确匹配（大幅减少比较次数）
                                     sheetNo (zdml2:extract-rect-text-fast
                                               tgtNoP1 tgtNoP2
                                               (zdml2:query-rect-index spatialIdx
                                                 (min (car tgtNoP1) (car tgtNoP2))
                                                 (max (car tgtNoP1) (car tgtNoP2))))
                                     sheetName (zdml2:extract-rect-text-fast
                                                 tgtNameP1 tgtNameP2
                                                 (zdml2:query-rect-index spatialIdx
                                                   (min (car tgtNameP1) (car tgtNameP2))
                                                   (max (car tgtNameP1) (car tgtNameP2)))))

                               (vlax-release-object blk)
                               (setq one (list
                                           (cons 'sheetNo (if (/= sheetNo "") sheetNo "--"))
                                           (cons 'sheetName (if (/= sheetName "") sheetName "--"))
                                           (cons 'x (car tgtIns))
                                           (cons 'y (cadr tgtIns))
                                         ))
                               ;; cons 比 append 快：O(1) vs O(N)
                               (setq data (cons one data))
                             )
                             ;; cons 是逆序，需 reverse 还原排序后的顺序
                             (setq data (reverse data))

                             (if (null data)
                               (princ "\r\n[ZDML2] 未提取到任何有效数据。")
                               (progn
                                 (princ (strcat "\r\n[ZDML2] 成功提取 " (itoa (length data)) " 条图纸数据。"))
                                 ;; 7. 点击放置目录表格（复用 tktj:draw-table 规范交互）
                                 (setq remaining data
                                       pageNo 1
                                       startIndex 0
                                       written 0
                                       basePt (getpoint "\r\n[ZDML2] 指定第 1 页目录表左上角: "))
                                 (if basePt
                                   (progn
                                     (while remaining
                                       (setq pageCap (if (= pageNo 1) 22 26)
                                             pageData (tktj:take remaining pageCap))
                                       (tktj:draw-table pageData basePt startIndex)
                                       (setq written (+ written (length pageData))
                                             startIndex written
                                             remaining (tktj:drop remaining pageCap)
                                             pageNo (1+ pageNo))
                                       (if remaining
                                         (setq basePt
                                               (getpoint
                                                 (strcat "\r\n[ZDML2] 第 " (itoa (1- pageNo))
                                                         " 页已放置，请指定第 " (itoa pageNo)
                                                         " 页目录表左上角 (回车结束): ")))
                                       )
                                     )
                                     (princ (strcat "\r\n[ZDML2] 完成，共生成 " (itoa written) " 条目录项。"))
                                   )
                                   (princ "\r\n[ZDML2] 已取消放置目录表。")
                                 )
                               )
                             )
                           )
                         )
                       )
                     )
                   )
                 )
               )
             )
           )
         )
       )
     )
    )
  )
  (aa:cmd-end)
)

;;; ---------------- 调试命令 ----------------
(defun c:ZDMLDEBUG (/ *error* aa:tag aa:doc aa:undo-open aa:old-cmdecho ent obj attrs pair)
  (aa:cmd-begin "ZDMLDEBUG")
  (vl-load-com)
  (setq ent (car (entsel "\r\n请选择一个图框块: ")))
  (cond
    ((not ent)
     (princ "\r\n已取消。")
    )
    ((/= "INSERT" (cdr (assoc 0 (entget ent))))
     (princ "\r\n选择对象不是块参照。")
    )
    (T
     (setq obj (vlax-ename->vla-object ent))
     (setq attrs (tktj:get-attributes obj))
     (vlax-release-object obj)
     (if attrs
       (progn
         (princ "\r\n该块增强属性如下:")
         (foreach pair attrs
           (princ
             (strcat
               "\r\n属性标记: "
               (car pair)
               "  值: "
               (cdr pair)
             )
           )
         )
       )
       (princ "\r\n该块没有增强属性。")
     )
    )
  )
  (aa:cmd-end)
)

;;; ---------------- 调试命令: DUMP ----------------
;;; 功能: 打印选中图元的 ActiveX (VLA) 属性与可用方法（探针与调试辅助）。
(defun c:DUMP (/ *error* aa:tag aa:doc aa:undo-open aa:old-cmdecho ent obj res)
  (aa:cmd-begin "DUMP")
  (vl-load-com)
  (setq ent (car (entsel "\r\n请选择要检查 ActiveX 属性的图元: ")))
  (cond
    ((not ent)
     (princ "\r\n未选中任何图元。")
    )
    (T
     (setq obj (vl-catch-all-apply 'vlax-ename->vla-object (list ent)))
     (if (or (vl-catch-all-error-p obj) (null obj))
       (princ "\r\n无法将该图元转换为 ActiveX 对象。")
       (progn
         (setq res (vl-catch-all-apply 'vlax-dump-object (list obj T)))
         (vlax-release-object obj)
         (if (vl-catch-all-error-p res)
           (princ "\r\n执行 vlax-dump-object 失败。")
         )
       )
     )
    )
  )
  (aa:cmd-end)
  (princ)
)

(princ)
;;;----------------------------------------------------------------------------------------
;;;
;;;                              C1 / C2 / C3 编号递增递减复制文字
;;;
;;;----------------------------------------------------------------------------------------

;;; 命令: C1 - 复制文字，优先井号相邻数字，其次减号后数字，把这段连续整数加 1
;;; 命令: C2 - 复制文字，优先井号相邻数字，其次减号后数字，把这段连续整数减 1
;;; 命令: C3 - 复制文字，优先井号相邻数字，其次减号后数字，把这段连续整数加 2
;;; 选择规则: 与 NU 共用 aa:num-target-span；减号只作分隔符，不当负号。
;;; 适用: 单行文字 TEXT、多行文字 MTEXT；不依赖项目主文件
;;; 说明: 使用原生 MOVE 提供拖动预览和捕捉，支持连续多次复制。

(setq c1c2:*active-preview* nil)

(defun c1c2:is-digit (ch / n)
  (if (and ch (= (type ch) 'STR) (= (strlen ch) 1))
    (progn
      (setq n (ascii ch))
      (and (<= 48 n) (<= n 57))
    )
  )
)

;;; ---------------------------------------------------------------------------------------
;;; 功能: C1/C2/C3 的目标数字定位：调用 NU 共用规则 aa:num-target-span（井号相邻数字 >
;;;       最后一个减号后的数字 > 第一段连续整数），转换成原来的 (start len) 返回；
;;;       没有整数位时返回 nil。兜底只取整数段，不引入小数和正负号。
;;; ---------------------------------------------------------------------------------------
(defun c1c2:first-number-span (s / span start end)
  (if (setq span (aa:num-target-span s))
    (setq start (car span)
          end   (cadr span))
  )
  (if start
    (list start (1+ (- end start)))
  )
)

(defun c1c2:repeat-char (ch n / out)
  (setq out "")
  (while (> n 0)
    (setq out (strcat out ch)
          n (1- n))
  )
  out
)

(defun c1c2:itoa-pad (num width / s)
  (setq s (itoa num))
  (if (and (>= num 0) (< (strlen s) width))
    (strcat (c1c2:repeat-char "0" (- width (strlen s))) s)
    s
  )
)

;;; 功能: C1/C2/C3 把目标数字加 delta 并保留原位宽；结果小于 0 返回 nil（不产生 "SVG--1"）。
(defun c1c2:change-number (s delta / span start len old new pre post)
  (if (and (setq span (c1c2:first-number-span s))
           (>= (+ (atoi (substr s (car span) (cadr span))) delta) 0))
    (progn
      (setq start (car span)
            len   (cadr span)
            old   (substr s start len)
            new   (c1c2:itoa-pad (+ (atoi old) delta) len)
            pre   (if (> start 1) (substr s 1 (1- start)) "")
            post  (if (<= (+ start len) (strlen s)) (substr s (+ start len)) ""))
      (strcat pre new post)
    )
  )
)

(defun c1c2:select-text (/ ss)
  (setq ss (ssget "_I" '((0 . "TEXT,MTEXT"))))
  (if (and ss (> (sslength ss) 0))
    (ssname ss 0)
    (progn
      (princ "\r\n选择一个带数字的文字，回车确认: ")
      (setq ss (ssget '((0 . "TEXT,MTEXT"))))
      (if (and ss (> (sslength ss) 0))
        (ssname ss 0)
      )
    )
  )
)

(defun c1c2:pt3 (pt)
  (cond
    ((null pt) nil)
    ((= (length pt) 2) (list (car pt) (cadr pt) 0.0))
    (T pt)
  )
)

(defun c1c2:wcs-point (pt)
  (vlax-3d-point (trans (c1c2:pt3 pt) 1 0))
)

(defun c1c2:move-object (obj from to)
  (if (and obj from to (not (equal from to 1e-8)))
    (vla-Move obj (c1c2:wcs-point from) (c1c2:wcs-point to))
  )
)

(defun c1c2:delete-preview ()
  (if c1c2:*active-preview*
    (progn
      (vl-catch-all-apply 'vla-Delete (list c1c2:*active-preview*))
      (setq c1c2:*active-preview* nil)
      (redraw)
    )
  )
)

(defun c1c2:place-one (src txt base / copy-obj last-pt)
  (setq copy-obj (vla-Copy src))
  (vla-put-TextString copy-obj txt)
  ;; 原生命令开始前更新显示，确保拖动的是递增/递减后的文字。
  (vla-Update copy-obj)
  (setq c1c2:*active-preview* copy-obj)
  ;; base 已经捕捉过，用 _non 防止再次捕捉；目标点交给原生输入。
  (command "_.MOVE" (vlax-vla-object->ename copy-obj) "" "_non" base)
  (setq last-pt (getvar "LASTPOINT"))
  ;; 只隐藏副本的静态显示，不改 Visible/DXF 60，以保留原生拖动图像。
  (redraw (vlax-vla-object->ename copy-obj) 2)
  (while (> (logand (getvar "CMDACTIVE") 1) 0)
    (command pause))
  (redraw (vlax-vla-object->ename copy-obj) 1)
  (setq c1c2:*active-preview* nil)
  (if (equal (getvar "LASTPOINT") last-pt 1e-6)
    (progn
      (vl-catch-all-apply 'vla-Delete (list copy-obj))
      nil
    )
    (progn
      (vlax-release-object copy-obj)
      T
    )
  )
)

(defun c1c2:safe-end-undo (doc)
  (if doc
    (vl-catch-all-apply 'vla-EndUndoMark (list doc))
  )
)

(defun c1c2:run (delta / *error* doc en obj txt base started old-dragmode count)
  (vl-load-com)
  (setq doc (vla-get-ActiveDocument (vlax-get-acad-object))
        started nil
        old-dragmode nil
        count 0)
  (defun *error* (msg)
    (c1c2:delete-preview)
    (if old-dragmode
      (vl-catch-all-apply 'setvar (list "DRAGMODE" old-dragmode)))
    (redraw)
    (if started (c1c2:safe-end-undo doc))
    (if obj (vl-catch-all-apply 'vlax-release-object (list obj)))
    (if (and msg
             (not (member msg '("Function cancelled" "quit / exit abort" "console break"))))
      (princ (strcat "\r\n错误: " msg))
    )
    (princ)
  )
  (setq en (c1c2:select-text))
  (cond
    ((null en)
     (princ "\r\n未选择文字。"))
    (T
     (setq obj (vlax-ename->vla-object en)
           txt (vla-get-TextString obj))
     (cond
       ((not (c1c2:first-number-span txt))
        (vlax-release-object obj)
        (princ "\r\n选中文字中没有找到数字。"))
       ((not (c1c2:change-number txt delta))
        (vlax-release-object obj)
        (princ "\r\n目标数字减小后小于 0，无法复制。"))
       ((not (setq base (getpoint "\r\n指定基点: ")))
        (vlax-release-object obj)
        (princ "\r\n已取消。"))
       (T
        (vla-StartUndoMark doc)
        (setq started T
              old-dragmode (getvar "DRAGMODE")
              txt (c1c2:change-number txt delta))
        (setvar "DRAGMODE" 2)
        (sssetfirst nil nil)
        (while (and txt (c1c2:place-one obj txt base))
          (setq count (1+ count)
                txt (c1c2:change-number txt delta))
        )
        (redraw)
        (setvar "DRAGMODE" old-dragmode)
        (setq old-dragmode nil)
        (vlax-release-object obj)
        (setq obj nil)
        (c1c2:safe-end-undo doc)
        (setq started nil)
        (if (> count 0)
          (princ (strcat "\r\n[C" (cond ((= delta 1) "1") ((= delta -1) "2") ((= delta 2) "3") (T "")) "] 已完成复制，共放置 " (itoa count) " 个对象。"))
          (princ "\r\n已取消。")
        )
        ;; txt 为 nil 说明下一份编号会小于 0，是自动停止而不是用户取消
        (if (null txt)
          (princ "\r\n编号已减到 0，停止复制。"))
       )
     )
    )
  )
  (princ)
)

(defun c:C1 ()
  (c1c2:run 1)
)

(defun c:C2 ()
  (c1c2:run -1)
)

(defun c:C3 ()
  (c1c2:run 2)
)

(princ)

;;;
;;; Source: 小命令\DE-DE2.lsp
;;;
(vl-load-com)

;; ============================================================
;; DE / DE2  括号处理（支持半角()、全角（）和批量选择）
;;   DE  : 删除括号及括号内容        "DS-10(11)" -> "DS-10"
;;   DE2 : 用括号内容替换括号前数字  "DS-10(11)" -> "DS-11"
;;         数字带相同尾缀时连尾缀替换  "A630I(640I)" -> "A640I"
;; ============================================================

;; 查找子串最后一次出现位置（0 基），无则 nil
(defun de:rfind (txt sub / pos last start)
  (setq last nil
        start 0)
  (while (setq pos (vl-string-search sub txt start))
    (setq last pos
          start (1+ pos))
  )
  last
)

;; 查找 limit 位置之前子串最后一次出现位置
(defun de:rfind-before (txt sub limit / pos last start)
  (setq last nil
        start 0)
  (while (and (setq pos (vl-string-search sub txt start))
              (< pos limit))
    (setq last pos
          start (1+ pos))
  )
  last
)

;; 去掉字符串末尾连续的半角数字，返回前缀部分
(defun de:rstrip-digits (s / n ch)
  (setq n (strlen s))
  (while (and (> n 0)
              (setq ch (substr s n 1))
              (>= (ascii ch) 48)
              (<= (ascii ch) 57))
    (setq n (1- n))
  )
  (substr s 1 n)
)

;; 取字符串最后一个半角数字之后的尾缀；无数字返回 nil
(defun de:digit-tail (s / n ch)
  (setq n (strlen s))
  (while (and (> n 0)
              (setq ch (substr s n 1))
              (not (and (>= (ascii ch) 48) (<= (ascii ch) 57))))
    (setq n (1- n))
  )
  (if (> n 0)
    (substr s (1+ n))
    nil)
)

;; DE2 去掉括号前要被替换的部分：
;; 括号内容为“数字+尾缀”（如 640I）且括号前以“数字+同尾缀”结尾（如 A630I）时，
;; 连尾缀一起去掉（A630I -> A）；否则只去掉末尾连续数字（DS-10 -> DS-）
(defun de:strip-replace-target (before inner / tail head)
  (setq tail (de:digit-tail inner))
  (if (and tail
           (> (strlen tail) 0)
           (> (strlen before) (strlen tail))
           (= (substr before (1+ (- (strlen before) (strlen tail)))) tail)
           (setq head (substr before 1 (- (strlen before) (strlen tail))))
           (/= (de:rstrip-digits head) head))
    (de:rstrip-digits head)
    (de:rstrip-digits before))
)

;; 返回最右侧完整括号对：（左位置 右位置 左括号 右括号）
(defun de:find-pair (txt / pa pb posR openCh closeCh posL)
  (setq pa (de:rfind txt ")")
        pb (de:rfind txt "）"))
  (cond
    ((and pa pb)
     (if (> pa pb)
       (setq posR pa openCh "(" closeCh ")")
       (setq posR pb openCh "（" closeCh "）")))
    (pa (setq posR pa openCh "(" closeCh ")"))
    (pb (setq posR pb openCh "（" closeCh "）"))
  )
  (if posR
    (setq posL (de:rfind-before txt openCh posR)))
  (if posL
    (list posL posR openCh closeCh)
    nil)
)

;; 处理单个字符串；无可处理括号时返回 nil
(defun de:strip (txt mode / pair posL posR openCh closeCh before inner after)
  (setq pair (de:find-pair txt))
  (if pair
    (progn
      (setq posL (nth 0 pair)
            posR (nth 1 pair)
            openCh (nth 2 pair)
            closeCh (nth 3 pair)
            before (substr txt 1 posL)
            inner (substr txt
                          (+ posL (strlen openCh) 1)
                          (- posR posL (strlen openCh)))
            after (substr txt (+ posR (strlen closeCh) 1)))
      (if (= mode 0)
        (strcat before after)
        (strcat (de:strip-replace-target before inner) inner after)))
    nil)
)

(defun de:get-text (ent / obj result)
  (setq obj (vlax-ename->vla-object ent)
        result (vl-catch-all-apply 'vla-get-TextString (list obj)))
  (vlax-release-object obj)
  (if (vl-catch-all-error-p result)
    nil
    result)
)

(defun de:set-text (ent txt / obj result)
  (setq obj (vlax-ename->vla-object ent)
        result (vl-catch-all-apply 'vla-put-TextString (list obj txt)))
  (vlax-release-object obj)
  (not (vl-catch-all-error-p result))
)

(defun de:end-undo (doc)
  (if doc
    (vl-catch-all-apply 'vla-EndUndoMark (list doc)))
)

;; 批量处理单行文字、多行文字和属性文字
(defun de:run (mode / *error* doc undo-open ss i ent txt new changed skipped)
  (vl-load-com)
  (setq doc (vla-get-ActiveDocument (vlax-get-acad-object))
        undo-open nil)
  (defun *error* (msg)
    (if undo-open
      (de:end-undo doc))
    (if (and msg
             (not (member msg '("Function cancelled" "quit / exit abort" "console break"))))
      (princ (strcat "\r\n错误: " msg)))
    (princ)
  )
  (prompt "\r\n选择要处理的单行文字、多行文字或属性文字: ")
  (setq ss (ssget '((0 . "TEXT,MTEXT,ATTRIB"))))
  (if ss
    (progn
      (vl-catch-all-apply 'vla-StartUndoMark (list doc))
      (setq undo-open T
            i 0
            changed 0
            skipped 0)
      (while (< i (sslength ss))
        (setq ent (ssname ss i)
              txt (de:get-text ent)
              new (if txt (de:strip txt mode) nil))
        (cond
          ((or (null new) (= new txt)))
          ((de:set-text ent new)
           (setq changed (1+ changed)))
          (T
           (setq skipped (1+ skipped))))
        (setq i (1+ i))
      )
      (de:end-undo doc)
      (setq undo-open nil)
      (redraw)
      (princ (strcat "\r\n已处理 " (itoa changed) " 个文字"))
      (if (> skipped 0)
        (princ (strcat "，" (itoa skipped) " 个文字写入失败")))
    )
    (princ "\r\n未选中文字")
  )
  (princ)
)

(defun c:DE () (de:run 0))
(defun c:DE2 () (de:run 1))

(princ)

;;;
;;; Command: GE
;;; Purpose: Draw one table row around selected horizontal single-line TEXT objects.
;;;          Text is sorted left-to-right; dividers use the midpoint of each clear gap.
;;;
(vl-load-com)

(defun ge:end-undo (doc)
  (if doc
    (vl-catch-all-apply 'vla-EndUndoMark (list doc)))
)

(defun ge:text-point-wcs (en ed / p)
  (setq p
    (if (or (/= 0 (if (assoc 72 ed) (cdr (assoc 72 ed)) 0))
            (/= 0 (if (assoc 73 ed) (cdr (assoc 73 ed)) 0)))
      (cdr (assoc 11 ed))
      (cdr (assoc 10 ed))))
  (if p (trans p en 0))
)

(defun ge:get-item (en / ed obj result minpt maxpt p rot out)
  (setq ed  (entget en)
        rot (if (assoc 50 ed) (cdr (assoc 50 ed)) 0.0))
  (if (and (= "TEXT" (cdr (assoc 0 ed)))
           (equal (sin rot) 0.0 1e-6)
           (setq p (ge:text-point-wcs en ed)))
    (progn
      (setq obj    (vlax-ename->vla-object en)
            result (vl-catch-all-apply
                     'vla-GetBoundingBox
                     (list obj 'minpt 'maxpt)))
      (setq out
        (if (not (vl-catch-all-error-p result))
          (progn
            (setq minpt (vlax-safearray->list minpt)
                  maxpt (vlax-safearray->list maxpt))
            (list
              (car minpt)
              (car maxpt)
              (cadr minpt)
              (cadr maxpt)
              (/ (+ (car minpt) (car maxpt)) 2.0)
              (cadr p)
              (max 1e-6 (- (cadr maxpt) (cadr minpt)))
              en))))
      (vlax-release-object obj)
      out)
    nil)
)

(defun ge:insert-item (item items)
  (cond
    ((null items) (list item))
    ((< (nth 4 item) (nth 4 (car items))) (cons item items))
    (T (cons (car items) (ge:insert-item item (cdr items)))))
)

(defun ge:sort-items (items / out item)
  (setq out nil)
  (foreach item items
    (setq out (ge:insert-item item out)))
  out
)

(defun ge:make-line (layer p1 p2 / en old)
  (setq en
    (entmakex
      (list
        '(0 . "LINE")
        (cons 8 layer)
        (cons 10 p1)
        (cons 11 p2))))
  (if en
    (setq created (cons en created))
    (progn
      (foreach old created
        (if (entget old) (entdel old)))
      (setq created nil)
      (error "GE 无法创建表格线。")))
  en
)

(defun c:GE (/ *error* doc undo-open ss i en item items bad maxh row-y row-tol
               prev rest cur overlap left right bottom top pad z layer created)
  (vl-load-com)
  (setq doc       (vla-get-ActiveDocument (vlax-get-acad-object))
        undo-open nil
        created   nil)

  (defun *error* (msg)
    (if undo-open
      (ge:end-undo doc))
    (if (and msg
             (not (member msg '("Function cancelled" "quit / exit abort" "console break"))))
      (princ (strcat "\r\nGE 错误: " msg)))
    (princ))

  (setq ss (ssget "_I" '((0 . "TEXT"))))
  (if (or (null ss) (= 0 (sslength ss)))
    (progn
      (princ "\r\n[GE] 请选择同一水平行的单行文字: ")
      (setq ss (ssget "_:L" '((0 . "TEXT"))))))

  (cond
    ((or (null ss) (= 0 (sslength ss)))
     (princ "\r\n[GE] 未选择单行文字。"))
    (T
     (setq i 0 items nil bad 0 maxh 0.0)
     (repeat (sslength ss)
       (setq en   (ssname ss i)
             item (ge:get-item en))
       (if item
         (progn
           (setq items (cons item items))
           (if (> (nth 6 item) maxh)
             (setq maxh (nth 6 item))))
         (setq bad (1+ bad)))
       (setq i (1+ i)))

     (cond
       ((> bad 0)
        (princ "\r\n[GE] 选择中包含旋转或无法读取的单行文字，未绘制表格。"))
       ((null items)
        (princ "\r\n[GE] 没有找到可用的单行文字。"))
       (T
        (setq items   (ge:sort-items items)
              row-y   (nth 5 (car items))
              row-tol (max 1e-5 (* maxh 0.25))
              overlap nil
              prev    nil
              left    (nth 0 (car items))
              right   (nth 1 (car items))
              bottom  (nth 2 (car items))
              top     (nth 3 (car items)))

        (foreach cur items
          (if (> (abs (- (nth 5 cur) row-y)) row-tol)
            (setq bad (1+ bad)))
          (if (and prev (<= (nth 0 cur) (+ (nth 1 prev) 1e-6)))
            (setq overlap T))
          (setq right  (max right  (nth 1 cur))
                bottom (min bottom (nth 2 cur))
                top    (max top    (nth 3 cur))
                prev   cur))

        (cond
          ((> bad 0)
           (princ "\r\n[GE] 所选文字不在同一水平行，未绘制表格。"))
          (overlap
           (princ "\r\n[GE] 相邻文字的外包框横向重叠，无法安全绘制分隔线。"))
          (T
           (setq pad    (* maxh 0.5)
                 left   (- left pad)
                 right  (+ right pad)
                 bottom (- bottom pad)
                 top    (+ top pad)
                 z      (caddr (trans (cdr (assoc 10 (entget (nth 7 (car items)))))
                                      (nth 7 (car items)) 0))
                 layer  (getvar "CLAYER"))
           (vl-catch-all-apply 'vla-StartUndoMark (list doc))
           (setq undo-open T)

           (ge:make-line layer (list left bottom z) (list right bottom z))
           (ge:make-line layer (list right bottom z) (list right top z))
           (ge:make-line layer (list right top z) (list left top z))
           (ge:make-line layer (list left top z) (list left bottom z))

           (setq prev (car items)
                 rest (cdr items))
           (while rest
             (setq cur (car rest)
                   i   (/ (+ (nth 1 prev) (nth 0 cur)) 2.0))
             (ge:make-line layer (list i bottom z) (list i top z))
             (setq prev cur
                   rest (cdr rest)))

           (ge:end-undo doc)
           (setq undo-open nil)
           (redraw)
           (princ
             (strcat "\r\n[GE] 已生成表格，单元格数: "
                     (itoa (length items))
                     "。"))))))))
  (princ)
)

(princ)

;;; =======================================================================================
;;; BEGIN IMPORT: UT.lsp
;;; =======================================================================================
(defun ut:abs (x)
  (if (< x 0.0) (- x) x)
)

(defun ut:line-endpoints (ename / ed typ flags p1 p2)
  (setq ed (entget ename)
        typ (cdr (assoc 0 ed))
        flags (cond ((cdr (assoc 70 ed))) (T 0)))
  (cond
    ((= typ "LINE")
     (list (cdr (assoc 10 ed)) (cdr (assoc 11 ed))))
    ((and (member typ '("LWPOLYLINE" "POLYLINE"))
          (= 0 (logand flags (+ 1 16 64))))
     ;; 曲线接口返回 WCS 首尾点；不分解、不修改顶点或宽度。
     (setq p1 (vl-catch-all-apply 'vlax-curve-getStartPoint (list ename))
           p2 (vl-catch-all-apply 'vlax-curve-getEndPoint (list ename)))
     (if (and (not (vl-catch-all-error-p p1))
              (not (vl-catch-all-error-p p2)) p1 p2)
       (list p1 p2))))
)

(defun ut:horizontal-line-p (ename / endpoints p1 p2 dx dy ang)
  (setq endpoints (ut:line-endpoints ename)
        p1 (car endpoints)
        p2 (cadr endpoints))
  (if (and p1 p2)
    (progn
      (setq dx (ut:abs (- (car p1) (car p2)))
            dy (ut:abs (- (cadr p1) (cadr p2)))
            ang (* *UT_TiltAngle* (/ pi 180.0)))
      ;; 倾斜角不超过 *UT_TiltAngle* 度即视为水平直线
      (and (> dx 1e-12)
           (<= dy (* dx (/ (sin ang) (cos ang))))))
    nil)
)

(defun ut:line-y (ename / endpoints p1 p2)
  (setq endpoints (ut:line-endpoints ename)
        p1 (car endpoints)
        p2 (cadr endpoints))
  (/ (+ (cadr p1) (cadr p2)) 2.0)
)

(defun ut:get-bbox (ename / obj minp maxp result out)
  (setq obj (vlax-ename->vla-object ename))
  (setq result
    (vl-catch-all-apply 'vla-getboundingbox (list obj 'minp 'maxp)))
  (setq out
    (if (vl-catch-all-error-p result)
      nil
      (list (vlax-safearray->list minp)
            (vlax-safearray->list maxp))))
  (vlax-release-object obj)
  out
)

(defun ut:bbox-left (bbox)
  (car (car bbox))
)

(defun ut:bbox-bottom (bbox)
  (cadr (car bbox))
)

(defun ut:insert-desc (item items / y out done)
  (setq y (cadr item)
        out nil
        done nil)
  (while items
    (if (and (not done) (> y (cadr (car items))))
      (progn
        (setq out (cons item out))
        (setq done T)))
    (setq out (cons (car items) out)
          items (cdr items)))
  (if (not done)
    (setq out (cons item out)))
  (reverse out)
)

(defun ut:sort-desc (items / out)
  (setq out nil)
  (while items
    (setq out (ut:insert-desc (car items) out)
          items (cdr items)))
  out
)

(defun ut:move (ename dx dy / obj result)
  (if (and ename (or (not (equal dx 0.0 1e-10))
                     (not (equal dy 0.0 1e-10))))
    (progn
      (setq obj (vlax-ename->vla-object ename)
            result
              (vl-catch-all-apply
                'vla-move
                (list obj
                      (vlax-3d-point '(0.0 0.0 0.0))
                      (vlax-3d-point (list dx dy 0.0)))))
      (vlax-release-object obj)
      (not (vl-catch-all-error-p result)))
    T)
)

(defun c:UT (/ *error* doc aa:doc aa:undo-open oldcmdecho ss i en ed typ
              lines texts line-items text-items line-count text-count
              pair-count base-line base-text base-bbox base-left base-gap
              line-item text-item line-y text-bbox target-left target-bottom
              dx dy changed skipped)
  (vl-load-com)
  (setq doc (vla-get-ActiveDocument (vlax-get-acad-object))
        aa:undo-open nil
        oldcmdecho nil
        lines nil
        texts nil
        changed 0
        skipped 0)

  (defun *error* (msg)
    (if oldcmdecho
      (setvar "CMDECHO" oldcmdecho))
    (aa:undo-mark-off)
    (sssetfirst nil nil)
    (if (and msg
             (not (wcmatch (strcase msg) "*BREAK*,*CANCEL*,*EXIT*,*QUIT*")))
      (princ (strcat "\r\n[UT] 错误：" msg)))
    (princ)
  )

  (setq ss (ssget "_I" '((0 . "LINE,LWPOLYLINE,POLYLINE,TEXT,MTEXT"))))
  (if (null ss)
    (progn
      (princ "\r\n[UT] 请选择水平直线或未闭合多段线，以及其上方的文字：")
      (setq ss (ssget "_:L" '((0 . "LINE,LWPOLYLINE,POLYLINE,TEXT,MTEXT"))))))
  (if ss
    (progn
      (setq i 0)
      (repeat (sslength ss)
        (setq en (ssname ss i)
              ed (entget en)
              typ (cdr (assoc 0 ed)))
        (cond
          ((and (member typ '("LINE" "LWPOLYLINE" "POLYLINE"))
                (ut:horizontal-line-p en))
           (setq lines (cons en lines)))
          ((and (or (= typ "TEXT") (= typ "MTEXT"))
                (ut:get-bbox en))
           (setq texts (cons en texts)))
        )
        (setq i (1+ i)))

      (setq line-items nil)
      (foreach en lines
        (setq line-items (cons (list en (ut:line-y en)) line-items)))
      (setq line-items (ut:sort-desc line-items))

      (aa:undo-mark-on)
      (setq text-items nil)
      (foreach en texts
        ;; 先统一文字为左中对正，再读取包围盒进行配对。
        (aa:normalize-text-horizontal-align doc en 1)
        (setq text-bbox (ut:get-bbox en))
        (if text-bbox
          (setq text-items
                (cons (list en (ut:bbox-bottom text-bbox) text-bbox)
                      text-items))))
      (setq text-items (ut:sort-desc text-items))

      (setq line-count (length line-items)
            text-count (length text-items)
            pair-count (min line-count text-count))
      (cond
        ((= line-count 0)
         (princ "\r\n[UT] 未找到水平直线或首尾端点连线水平的未闭合多段线。"))
        ((= text-count 0)
         (princ "\r\n[UT] 未找到有效的 TEXT/MTEXT 文字。"))
        (T
         (setq base-line (car line-items)
               base-text (car text-items)
               base-bbox (caddr base-text)
               base-left (ut:bbox-left base-bbox)
               base-gap (- (cadr base-text) (cadr base-line))
               oldcmdecho (getvar "CMDECHO"))
         (setvar "CMDECHO" 0)
         (repeat pair-count
           (setq line-item (car line-items)
                 text-item (car text-items)
                 line-y (cadr line-item)
                 text-bbox (caddr text-item)
                 target-left base-left
                 target-bottom (+ line-y base-gap)
                 dx (- target-left (ut:bbox-left text-bbox))
                 dy (- target-bottom (ut:bbox-bottom text-bbox)))
           (if (ut:move (car text-item) dx dy)
             (if (or (not (equal dx 0.0 1e-10))
                     (not (equal dy 0.0 1e-10)))
               (setq changed (1+ changed)))
             (setq skipped (1+ skipped)))
           (setq line-items (cdr line-items)
                 text-items (cdr text-items)))
         (redraw)
         (aa:undo-mark-off)
         (setvar "CMDECHO" oldcmdecho)
         (setq oldcmdecho nil)
         (princ
           (strcat
             "\r\n[UT] 整理完成：处理 " (itoa pair-count) " 对，移动 "
             (itoa changed) " 个文字。"
             (if (/= line-count text-count)
               (strcat " 选中的线对象(" (itoa line-count) ")与文字("
                       (itoa text-count) ")数量不一致，按较少数量配对。")
               ""))))))
    (princ "\r\n[UT] 未选择对象。"))
  (aa:undo-mark-off)
  (sssetfirst nil nil)
  (princ)
)



(princ)

;;; 0.lsp
;;; 命令 0：将所选对象中的文字旋转角度统一改为 0 度。

(vl-load-com)

(defun c:0 (/ *error* aa:tag aa:doc aa:undo-open aa:old-cmdecho ss index entity data entity-type changed failed)
  (aa:cmd-begin "0")
  (setq changed 0
        failed  0)
  (prompt "\r\n请选择要处理的对象：")
  (if (setq ss (ssget))
    (progn
      (setq index 0)
      (repeat (sslength ss)
        (setq entity      (ssname ss index)
              data        (entget entity)
              entity-type (cdr (assoc 0 data)))
        (if (member entity-type '("TEXT" "MTEXT" "ATTRIB" "ATTDEF"))
          (if
            (entmod
              (if (assoc 50 data)
                (subst (cons 50 0.0) (assoc 50 data) data)
                (append data (list (cons 50 0.0)))))
            (setq changed (1+ changed))
            (setq failed (1+ failed))))
        (setq index (1+ index)))
      (redraw)
      (prompt
        (strcat
          "\r\n已将 "
          (itoa changed)
          " 个文字对象的旋转角度改为 0 度。"))
      (if (> failed 0)
        (prompt
          (strcat
            " 另有 "
            (itoa failed)
            " 个文字对象修改失败。"))))
    (prompt "\r\n未选择对象。"))
  (aa:cmd-end))

(princ)



;;; 以整体包围框中心为基点旋转选中对象；clockwise 为 T 时顺时针旋转。
(defun aa:rotate-90-run (ss clockwise / index entity data obj result lo hi
                                  bounds-lo bounds-hi center angle blocked)
  (if ss
    (progn
      (setq index 0)
      ;; 先取得全部 WCS 边界并检查锁层，避免只旋转选区的一部分。
      (while (and (< index (sslength ss)) (not blocked))
        (setq entity (ssname ss index)
              data (entget entity)
              obj (vlax-ename->vla-object entity))
        (if (/= 0 (logand 4 (cdr (assoc 70 (tblsearch "LAYER" (cdr (assoc 8 data)))))))
          (setq blocked "选区包含锁定图层对象，请先解锁后重试。")
          (progn
            (setq result (vl-catch-all-apply 'vla-GetBoundingBox (list obj 'lo 'hi)))
            (if (vl-catch-all-error-p result)
              (setq blocked "选区中有无法取得包围框的对象，本次未旋转。")
              (progn
                (setq lo (vlax-safearray->list lo)
                      hi (vlax-safearray->list hi)
                      bounds-lo (if bounds-lo (mapcar 'min bounds-lo lo) lo)
                      bounds-hi (if bounds-hi (mapcar 'max bounds-hi hi) hi))))))
        (vlax-release-object obj)
        (setq index (1+ index)))
      (if blocked
        (prompt (strcat "\r\n" blocked))
        (progn
          (setq center (mapcar '(lambda (a b) (/ (+ a b) 2.0)) bounds-lo bounds-hi)
                angle (if clockwise
                        (if (= 1 (getvar "ANGDIR")) "90d" "-90d")
                        (if (= 1 (getvar "ANGDIR")) "-90d" "90d")))
          (setvar "CMDECHO" 0)
          ;; ROTATE 命令输入使用角度而非弧度；d 明确指定度，并补偿 ANGDIR。
          (vl-cmdf "_.ROTATE" ss "" "_non" (trans center 0 1) angle)
          ;; ROTATE 会清掉预选状态，完成后恢复原选择集，方便连续执行 9/99。
          (sssetfirst nil ss)
          (prompt
            (if clockwise
              "\r\n已整体顺时针旋转 90 度，当前对象仍保持选中，可用一次 U 撤销。"
              "\r\n已整体逆时针旋转 90 度，当前对象仍保持选中，可用一次 U 撤销。")))))
    (prompt "\r\n未选择对象。")))

;;; 命令 9：以整体包围框中心为基点，将选中对象整体顺时针旋转 90 度。
(defun c:9 (/ *error* aa:tag aa:doc aa:undo-open aa:old-cmdecho ss)
  (aa:cmd-begin "9")
  (setq ss (ssget "_I"))
  (if (not ss)
    (progn
      (prompt "\r\n请选择要整体顺时针旋转 90 度的对象：")
      (setq ss (ssget))))
  (aa:rotate-90-run ss T)
  (aa:cmd-end)
  (princ))

;;; 命令 99：以整体包围框中心为基点，将选中对象整体逆时针旋转 90 度。
(defun c:99 (/ *error* aa:tag aa:doc aa:undo-open aa:old-cmdecho ss)
  (aa:cmd-begin "99")
  (setq ss (ssget "_I"))
  (if (not ss)
    (progn
      (prompt "\r\n请选择要整体逆时针旋转 90 度的对象：")
      (setq ss (ssget))))
  (aa:rotate-90-run ss nil)
  (aa:cmd-end)
  (princ))

;;; QZ.lsp
;;; 检测当前图纸中的所有组，并立即取消全部分组；组内图元保持不变。

(vl-load-com)

(defun c:QZ (/ *error* doc groups group-list group-object total success failed undo-open result)
  (vl-load-com)
  (setq doc (vla-get-ActiveDocument (vlax-get-acad-object))
        groups (vla-get-Groups doc)
        undo-open nil)

  (defun *error* (message)
    (if undo-open
      (vl-catch-all-apply 'vla-EndUndoMark (list doc)))
    (if (and message
             (/= message "Function cancelled")
             (/= message "quit / exit abort"))
      (princ (strcat "\r\n[QZ] 执行失败：" message)))
    (princ))

  ;; 先保存组对象，避免删除时改变正在遍历的集合。
  (vlax-for group-object groups
    (setq group-list (cons group-object group-list)))
  (setq total (length group-list))

  (if (= total 0)
    (progn
      (vlax-release-object groups)
      (princ "\r\n[QZ] 当前图纸中没有检测到任何组。"))
    (progn
      (vla-StartUndoMark doc)
      (setq undo-open T
            success 0
            failed 0)
      (foreach group-object group-list
        (setq result
          (vl-catch-all-apply 'vla-Delete (list group-object)))
        (if (vl-catch-all-error-p result)
          (setq failed (1+ failed))
          (setq success (1+ success)))
        (vlax-release-object group-object))
      (vlax-release-object groups)
      (vla-EndUndoMark doc)
      (setq undo-open nil)
      (vla-Regen doc 1)
      (princ
        (strcat
          "\r\n[QZ] 检测到 " (itoa total) " 个组，成功取消 "
          (itoa success) " 个组"
          (if (> failed 0)
            (strcat "，失败 " (itoa failed) " 个。")
            "。")))
      (princ "\r\n组内图元未被删除，可使用 Ctrl+Z 撤销。")))
  (princ))

(princ)

;;; =======================================================================================
;;; BEGIN INTEGRATED SOURCE: DL1.lsp
;;; =======================================================================================
;; ============================================================
;; DL1  创建电缆柜、电缆路径、电缆竖井相关 1F / 2F 图层
;; 依赖：仅使用 CAD 内置 AutoLISP 函数，无外部依赖。
;; ============================================================

(defun dl1:make-layer (name /)
  (if (not (tblsearch "LAYER" name))
    (entmake
      (list
        '(0 . "LAYER")
        '(100 . "AcDbSymbolTableRecord")
        '(100 . "AcDbLayerTableRecord")
        (cons 2 name)
        '(70 . 0)
        '(62 . 7)
        '(6 . "Continuous")
      )
    )
  )
)

(defun c:DL1 (/ *error* aa:tag aa:doc aa:undo-open aa:old-cmdecho layers)
  (aa:cmd-begin "DL1")
  (setq layers
    '(
      "CABLE_CABINET_1F"
      "CABLE_CABINET_2F"
      "CABLE_ROUTE_1F"
      "CABLE_ROUTE_2F"
      "CABLE_SHAFT_1F"
      "CABLE_SHAFT_2F"
    )
  )
  (foreach lay layers
    (dl1:make-layer lay)
  )
  (princ "\r\nDL1：已检查并创建 6 个电缆相关图层。")
  (aa:cmd-end)
)

(princ "\r\nDL1 命令已加载，输入 DL1 创建电缆相关图层。")
(princ)
;;; END INTEGRATED SOURCE: DL1.lsp

;;; =======================================================================================
;;; BEGIN INTEGRATED SOURCE: REP.lsp
;;; =======================================================================================
;;; REP.lsp  柜名标准化替换命令
;;; 命令 REP：选择若干单行/多行文字，将其内容（柜名）替换为标准柜名。
;;; 映射表已内置于本文件（原始数据来自文字替换.xlsx：A列=原柜名，B列=标准柜名）
;;; 匹配规则：去除文字首尾空格后，与原柜名整体精确匹配，命中则整体替换为标准柜名。

(defun rep-trim (s)
  (if (null s) (setq s ""))
  (while (and (> (strlen s) 0)
              (member (substr s 1 1) (list " " "\t")))
    (setq s (substr s 2)))
  (while (and (> (strlen s) 0)
              (member (substr s (strlen s) 1) (list " " "\t")))
    (setq s (substr s 1 (1- (strlen s)))))
  s)

(defun c:REP ( / *error* aa:tag aa:doc aa:undo-open aa:old-cmdecho ss i en obj str key pair cnt miss table)
  (aa:cmd-begin "REP")
  (vl-load-com)
  (setq table
    (list
      (cons "#2直流馈线柜" "直流馈线柜2")
      (cons "1#直流馈线柜" "直流馈线柜1")
      (cons "#1直流馈线柜" "直流馈线柜1")
      (cons "#2配网综合故障管控PT柜" "10kV#2配网综合故障管控PT柜")
      (cons "#1配网综合故障管控PT柜" "10kV#1配网综合故障管控PT柜")
      (cons "#1主变10kV侧开关柜" "10kV#1主变进线柜")
      (cons "#2主变10kV侧开关柜" "10kV#2主变进线柜")
      (cons "#2配网综合故障管控接地柜" "10kV#2配网综合故障管控接地柜")
      (cons "#1配网综合故障管控接地柜" "10kV#1配网综合故障管控接地柜")
      (cons "#1主变测控柜" "主变测控柜1")
      (cons "#2主变测控柜" "主变测控柜2")
      (cons "#1主变保护柜" "主变保护柜1")
      (cons "#2主变保护柜" "主变保护柜2")
      (cons "#1SVG控制柜" "10kV#1SVG控制柜")
      (cons "#2SVG控制柜" "10kV#2SVG控制柜")
      (cons "10kV#1电容出线柜" "10kV#1电容器出线柜")
      (cons "10kV#2电容出线柜" "10kV#2电容器出线柜")
      (cons "#1电容器" "10kV#1电容器")
      (cons "#2电容器" "10kV#2电容器")
      (cons "调度数据专网柜1" "调度数据网柜1")
      (cons "调度数据专网柜2" "调度数据网柜2")
      (cons "10kV 分段柜" "10kV分段柜")
      (cons "110kV 母线智能汇控柜" "110kV母线智能汇控柜")
      (cons "1#主变保护柜" "主变保护柜1")
      (cons "2#主变保护柜" "主变保护柜2")
      (cons "2#直流馈线柜" "直流馈线柜2")
      (cons "逆功率保护及电能质量在线监测柜" "逆功率保护及电能质量监测柜")
      (cons "逆功率保护及电能质量检测柜" "逆功率保护及电能质量监测柜")
      (cons "时钟同步柜" "时间同步柜")
      (cons "GIS#1主变间隔汇控柜" "#1主变110kV智能控制柜")
      (cons "GIS#2主变间隔汇控柜" "#2主变110kV智能控制柜")
      (cons "GIS线路间隔汇控柜" "110kV线路智能汇控柜")
      (cons "10kV#1电容器开关柜" "10kV#1电容器出线柜")
      (cons "10kV#2电容器开关柜" "10kV#2电容器出线柜")
      (cons "GISPT间隔汇控柜" "110kV母线智能汇控柜")
      (cons "10kV分段隔离柜" "10kV隔离柜")
      (cons "10kV1#SVG开关柜" "10kV#1SVG出线柜")
      (cons "10kV2#SVG开关柜" "10kV#2SVG出线柜")
      (cons "#1主变中性点成套装置" "#1主变中性点隔离开关机构")
      (cons "#2主变中性点成套装置" "#2主变中性点隔离开关机构")
      (cons "#1主变有载开关" "#1主变有载调压端子箱")
      (cons "#2主变有载开关" "#2主变有载调压端子箱")
      (cons "#1主变风冷控制柜1" "#1主变风冷控制柜")
      (cons "#1主变风冷控制柜2" "#1主变风冷控制柜")
      (cons "#2主变风冷控制柜1" "#2主变风冷控制柜")
      (cons "#2主变风冷控制柜2" "#2主变风冷控制柜")
      (cons "#1主变油色谱在线监测主机" "#1主变油色谱就地柜")
      (cons "#2主变油色谱在线监测主机" "#2主变油色谱就地柜")
      (cons "在线监测后台主机" "在线监测后台柜")
      (cons "主变油色谱在线监测后台主机柜" "在线监测后台柜")
      (cons "110kV进线间隔GIS汇控柜" "110kV线路智能汇控柜")
      (cons "110kVPT间隔GIS汇控柜" "110kV母线智能汇控柜")
      (cons "#1电容器组" "10kV#1电容器")
      (cons "#2电容器组" "10kV#2电容器")
      (cons "10kV#1电容器组" "10kV#1电容器")
      (cons "10kV#2电容器组" "10kV#2电容器")
      (cons "10kV#1电容器端子箱" "10kV#1电容器")
      (cons "10kV#2电容器端子箱" "10kV#2电容器")
      (cons "#1-1储能并网柜" "10kV#1-1储能出线柜")
      (cons "#1-2储能并网柜" "10kV#1-2储能出线柜")
      (cons "#1-3储能并网柜" "10kV#1-3储能出线柜")
      (cons "#1-4储能并网柜" "10kV#1-4储能出线柜")
      (cons "#2-1储能并网柜" "10kV#2-1储能出线柜")
      (cons "2-2#储能并网柜" "10kV#2-2储能出线柜")
      (cons "#2-3储能并网柜" "10kV#2-3储能出线柜")
      (cons "#2-4储能并网柜" "10kV#2-4储能出线柜")
    )
  )
  (princ "\r\n请选择要替换的文字（单行文字/多行文字）：")
  (setq ss (ssget (list (cons 0 "TEXT,MTEXT"))))
  (if ss
    (progn
      (setq cnt 0 miss 0 i 0)
      (while (< i (sslength ss))
        (setq en (ssname ss i))
        (setq obj (vlax-ename->vla-object en))
        (setq str (vlax-get obj (quote TextString)))
        (setq key (rep-trim str))
        (setq pair (assoc key table))
        (if pair
          (progn
            (vlax-put obj (quote TextString) (cdr pair))
            (setq cnt (1+ cnt)))
          (setq miss (1+ miss)))
        (vlax-release-object obj)
        (setq i (1+ i)))
      (princ (strcat "\r\n替换完成：成功 " (itoa cnt) " 个，未匹配 " (itoa miss) " 个。")))
    (princ "\r\n未选择任何文字。"))
  (aa:cmd-end)
)
(princ "\r\nREP 柜名标准化替换命令已加载，输入 REP 运行。")
(princ)
;;; END INTEGRATED SOURCE: REP.lsp

;;; =======================================================================================
;;; BEGIN INTEGRATED SOURCE: ZJ.lsp
;;; =======================================================================================
;;; Encoding: UTF-8 without BOM, CRLF.
;;; 将选择集中的 LWPOLYLINE/POLYLINE 分解为 LINE，返回全部 LINE 实体列表
(defun aa:explode-collect-lines (ss / oldcmd plines all-lines i en ed typ
                                 pl-ss before cur)
  (setq plines nil
        all-lines nil
        i 0)
  (repeat (sslength ss)
    (setq en (ssname ss i)
          ed (entget en)
          typ (cdr (assoc 0 ed)))
    (cond
      ((= typ "LINE")
       (setq all-lines (cons en all-lines)))
      ((member typ '("LWPOLYLINE" "POLYLINE"))
       (setq plines (cons en plines))))
    (setq i (1+ i)))
  (if plines
    (progn
      (setq oldcmd (getvar "CMDECHO"))
      (setvar "CMDECHO" 0)
      (setq pl-ss (ssadd))
      (foreach en plines
        (ssadd en pl-ss))
      (setq before (entlast))
      (command "_.explode" pl-ss "")
      ;; 个别 CAD 版本不接受选择集参数时，逐个兜底分解
      (foreach en plines
        (if (entget en)
          (command "_.explode" en)))
      ;; 收集分解产生的新 LINE
      (setq cur (if before (entnext before) (entnext)))
      (while cur
        (if (= "LINE" (cdr (assoc 0 (entget cur))))
          (setq all-lines (cons cur all-lines)))
        (setq cur (entnext cur)))
      (setvar "CMDECHO" oldcmd)))
  all-lines)


;;; =======================================================================================
;;; BEGIN INTEGRATED SOURCE: KMZ_KMY.lsp
;;; =======================================================================================
;;; Encoding: UTF-8 without BOM, CRLF.
;;; KMZ / KMY：为两条水平直线左端/右端生成连接短线与矩形，并在直线上方和矩形中居中标注文字。
;;; 线段与矩形线型统一为 HIDDEN2，颜色统一为青色（ACI 4），文字统一为青色（ACI 4）。

(defun aa:km-create-centered-text (doc text-str pt-center / t-style t-ename t-bbox cur-cx cur-cy dx dy)
  (setq t-style (if (tblsearch "STYLE" "HZ") "HZ" (getvar "TEXTSTYLE")))
  (setq t-ename
    (entmakex
      (list '(0 . "TEXT")
            (cons 1 text-str)
            (cons 7 t-style)
            (cons 8 (getvar "CLAYER"))
            '(62 . 4)
            '(40 . 3.0)
            '(41 . 0.7)
            (cons 10 pt-center)
            (cons 11 pt-center)
            '(72 . 1)
            '(73 . 2))))
  (if t-ename
    (progn
      (setq t-bbox (aa:safe-get-bbox doc t-ename))
      (if t-bbox
        (progn
          (setq cur-cx (aa:bbox-center-x t-bbox)
                cur-cy (/ (+ (aa:bbox-top-y t-bbox) (aa:bbox-bottom-y t-bbox)) 2.0)
                dx (- (car pt-center) cur-cx)
                dy (- (cadr pt-center) cur-cy))
          (if (not (and (equal dx 0.0 1e-6) (equal dy 0.0 1e-6)))
            (aa:safe-move-entity t-ename (vlax-3d-point (list dx dy 0.0))))))
      t-ename)
    nil)
)

(defun aa:km-ln-cmd (tag-name is-left txt-up txt-low txt-rect
                       / *error* aa:doc aa:undo-open doc oldcmd oldct oldce
                         ss all-lines lines-by-y y-keys valid base-z
                         en ed p1 p2 dx dy attach-pt item
                         upper-y lower-y
                         extreme-x-list base-ext-x joint-x
                         rect-w rect-x1 rect-x2 rect-cx height center-y
                         bottom top rect-pt1 rect-pt2
                         line-mid-x rect-center
                         t-rect-en t-rect-bbox t-w
                         n-lines idx cur-y cur-lines cur-ext-x y-item cur-txt cur-center)
  (vl-load-com)
  (setq doc (vla-get-ActiveDocument (vlax-get-acad-object))
        aa:undo-open nil
        oldcmd nil
        oldct nil
        oldce nil)

  (defun *error* (msg)
    (if oldcmd (setvar "CMDECHO" oldcmd))
    (if oldct (setvar "CELTYPE" oldct))
    (if oldce (setvar "CECOLOR" oldce))
    (aa:undo-mark-off)
    (sssetfirst nil nil)
    (if (and msg
             (not (wcmatch (strcase msg) "*BREAK*,*CANCEL*,*EXIT*,*QUIT*")))
      (princ (strcat "\r\n[" tag-name "] 错误：" msg)))
    (princ))

  (setq ss (ssget "_I" '((0 . "LINE,LWPOLYLINE,POLYLINE"))))
  (if (null ss)
    (progn
      (princ (strcat "\r\n[" tag-name "] 请选择水平直线或多段线（多段线将自动分解）："))
      (setq ss (ssget "_:L" '((0 . "LINE,LWPOLYLINE,POLYLINE"))))))

  (if ss
    (progn
      (aa:undo-mark-on)
      (setq all-lines (aa:explode-collect-lines ss))
      (if (>= (length all-lines) 2)
        (progn
          (setq lines-by-y nil
                valid T
                base-z nil)
          (foreach en all-lines
            (setq ed (entget en)
                  p1 (cdr (assoc 10 ed))
                  p2 (cdr (assoc 11 ed)))
            ;; 允许图纸中微小水平偏差：Y差 <= 0.1 图纸单位且斜率 <= 1%。
            ;; 使用连接侧的真实端点高度，避免短线与原线之间出现缝隙。
            (if (and p1 p2)
              (setq dx (abs (- (car p2) (car p1)))
                    dy (abs (- (cadr p2) (cadr p1)))
                    attach-pt
                      (if (if is-left (<= (car p1) (car p2)) (>= (car p1) (car p2)))
                        p1 p2)))
            (if (and p1 p2
                     (> dx 1e-6)
                     (<= dy 0.1)
                     (<= dy (* dx 0.01))
                     (or (null base-z)
                         (equal (if (caddr p1) (caddr p1) 0.0) base-z 1e-6))
                     (equal (if (caddr p1) (caddr p1) 0.0)
                            (if (caddr p2) (caddr p2) 0.0) 1e-6))
              (progn
                (if (null base-z)
                  (setq base-z (if (caddr p1) (caddr p1) 0.0)))
                (setq lines-by-y (cons (list (cadr attach-pt) en p1 p2) lines-by-y)))
              (setq valid nil)))

          (if (not valid)
            (princ (strcat "\r\n[" tag-name "] 所选直线必须接近水平（Y差≤0.1且斜率≤1%）且位于同一标高。"))
            (progn
              ;; 获取所有不同的 Y 高度并降序排序（从上到下）
              (setq y-keys nil)
              (foreach item lines-by-y
                (if (not (vl-some (function (lambda (y) (equal y (car item) 1e-4))) y-keys))
                  (setq y-keys (cons (car item) y-keys))))
              (setq y-keys
                (aa:merge-sort
                  y-keys
                  (function (lambda (a b) (> a b)))))

              (if (< (length y-keys) 2)
                (princ (strcat "\r\n[" tag-name "] 请至少选择处于两个不同高度的水平直线。"))
                (progn
                  (setq upper-y (car y-keys)
                        lower-y (last y-keys))

                  ;; 获取各高度水平线的极端 X 坐标
                  (setq extreme-x-list nil)
                  (foreach cur-y y-keys
                    (setq cur-lines (vl-remove-if-not (function (lambda (item) (equal (car item) cur-y 1e-4))) lines-by-y))
                    (if is-left
                      (setq cur-ext-x
                        (apply 'min
                          (mapcar (function (lambda (item)
                                               (min (car (nth 2 item)) (car (nth 3 item)))))
                                  cur-lines)))
                      (setq cur-ext-x
                        (apply 'max
                          (mapcar (function (lambda (item)
                                               (max (car (nth 2 item)) (car (nth 3 item)))))
                                  cur-lines))))
                    (setq extreme-x-list (cons (cons cur-y cur-ext-x) extreme-x-list)))
                  (setq extreme-x-list (reverse extreme-x-list))

                  (if is-left
                    (progn
                      (setq base-ext-x (apply 'min (mapcar 'cdr extreme-x-list))
                            joint-x (- base-ext-x 15.0)
                            line-mid-x (/ (+ base-ext-x joint-x) 2.0)))
                    (progn
                      (setq base-ext-x (apply 'max (mapcar 'cdr extreme-x-list))
                            joint-x (+ base-ext-x 15.0)
                            line-mid-x (/ (+ base-ext-x joint-x) 2.0))))

                  (setq height (max 20.0 (+ (- upper-y lower-y) 4.0))
                        center-y (/ (+ lower-y upper-y) 2.0)
                        bottom (- center-y (/ height 2.0))
                        top (+ center-y (/ height 2.0))
                        oldcmd (getvar "CMDECHO"))
                  (setvar "CMDECHO" 0)

                  ;; 加载 HIDDEN2 线型
                  (if (not (tblsearch "LTYPE" "HIDDEN2"))
                    (command "_.-LINETYPE" "_Load" "HIDDEN2" ""))

                  (setq oldct (getvar "CELTYPE")
                        oldce (getvar "CECOLOR"))
                  (setvar "CELTYPE" "HIDDEN2")
                  (setvar "CECOLOR" "4")

                  ;; 1. 为每个高度生成延伸短线（长 15，虚线 HIDDEN2，青色 4）
                  (foreach y-item extreme-x-list
                    (setq cur-y (car y-item)
                          cur-ext-x (cdr y-item))
                    (entmakex
                      (list '(0 . "LINE")
                            (cons 8 (getvar "CLAYER"))
                            '(62 . 4)
                            '(6 . "HIDDEN2")
                            (cons 10 (list cur-ext-x cur-y base-z))
                            (cons 11 (list joint-x cur-y base-z)))))

                  ;; 2. 先创建矩形内文字（初始在 joint-x 处），以便精准测量文字包围盒宽度
                  (setq t-rect-en (aa:km-create-centered-text doc txt-rect (list joint-x center-y base-z)))
                  (setq t-rect-bbox (if t-rect-en (aa:safe-get-bbox doc t-rect-en) nil))
                  (setq t-w (if t-rect-bbox
                              (- (aa:bbox-right-x t-rect-bbox) (aa:bbox-left-x t-rect-bbox))
                              (* (strlen txt-rect) 3.0 0.7))) ; 兜底计算
                  ;; 矩形左右边界与文字左右边界保持 2.5mm 间距，即总宽度 = 文字宽 + 5.0
                  (setq rect-w (+ t-w 5.0))

                  (if is-left
                    (setq rect-x1 (- joint-x rect-w)
                          rect-x2 joint-x
                          rect-cx (/ (+ rect-x1 rect-x2) 2.0))
                    (setq rect-x1 joint-x
                          rect-x2 (+ joint-x rect-w)
                          rect-cx (/ (+ rect-x1 rect-x2) 2.0)))

                  (setq rect-pt1 (list rect-x1 bottom base-z)
                        rect-pt2 (list rect-x2 top base-z))

                  ;; 3. 生成矩形（自适应宽度，虚线 HIDDEN2，青色 4）
                  (command "_.RECTANG" "_non" rect-pt1 "_non" rect-pt2)

                  ;; 4. 将矩形文字平移至矩形正中心
                  (if t-rect-en
                    (aa:safe-move-entity t-rect-en (vlax-3d-point (list (- rect-cx joint-x) 0.0 0.0))))

                  ;; 5. 生成短线上方标注文字（青色 4，HZ样式，字高 3.0，完全居中）
                  (setq n-lines (length y-keys)
                        idx 0)
                  (foreach cur-y y-keys
                    (setq cur-txt
                      (cond
                        ((= idx 0) txt-up)
                        ((= idx (1- n-lines)) txt-low)
                        ((equal txt-up txt-low) txt-up)
                        (T nil)))
                    (if (and cur-txt (/= cur-txt ""))
                      (progn
                        (setq cur-center (list line-mid-x (+ cur-y 1.5 (/ 3.0 2.0)) base-z))
                        (aa:km-create-centered-text doc cur-txt cur-center)))
                    (setq idx (1+ idx)))

                  (redraw)
                  (setvar "CELTYPE" oldct)
                  (setvar "CECOLOR" oldce)
                  (setvar "CMDECHO" oldcmd)
                  (setq oldcmd nil)
                  (if (= (length y-keys) 2)
                    (princ (strcat "\r\n[" tag-name "] 已成功生成两条短线（长15）、矩形（自适应宽"
                                   (rtos rect-w 2 2) "×高" (rtos height 2 2) "）及居中文注。"))
                    (princ (strcat "\r\n[" tag-name "] 已成功为 " (itoa (length y-keys))
                                   " 条水平线生成短线（长15）、矩形（自适应宽"
                                   (rtos rect-w 2 2) "×高" (rtos height 2 2) "）及居中文注。"))))))))
        (princ (strcat "\r\n[" tag-name "] 分解后至少需要两条水平直线。"))))
    (princ (strcat "\r\n[" tag-name "] 必须选择直线或多段线。")))
  (aa:undo-mark-off)
  (sssetfirst nil nil)
  (princ)
)

;;; Command: KMZ
;;; Function: 选中两条水平线后向左生成短线、矩形并居中标注+KM、-KM及直流馈线柜（青色虚线）。
(defun c:KMZ ()
  (aa:km-ln-cmd "KMZ" T "+KM" "-KM" "直流馈线柜")
)

;;; Command: KMY
;;; Function: 选中两条水平线后向右生成短线、矩形并居中标注+KM、-KM及直流馈线柜（青色虚线）。
(defun c:KMY ()
  (aa:km-ln-cmd "KMY" nil "+KM" "-KM" "直流馈线柜")
)

;;; Command: LNZ
;;; Function: 选中两条水平线后向左生成短线、矩形并居中标注L、N及相邻屏柜（青色虚线）。
(defun c:LNZ ()
  (aa:km-ln-cmd "LNZ" T "L" "N" "相邻屏柜")
)

;;; Command: LNY
;;; Function: 选中两条水平线后向右生成短线、矩形并居中标注L、N及相邻屏柜（青色虚线）。
(defun c:LNY ()
  (aa:km-ln-cmd "LNY" nil "L" "N" "相邻屏柜")
)

;;; Command: UPSZ
;;; Function: 选中两条水平线后向左生成短线、矩形并居中标注L、N及UPS电源柜（青色虚线）。
(defun c:UPSZ ()
  (aa:km-ln-cmd "UPSZ" T "L" "N" "UPS电源柜")
)

;;; Command: UPSY
;;; Function: 选中两条水平线后向右生成短线、矩形并居中标注L、N及UPS电源柜（青色虚线）。
(defun c:UPSY ()
  (aa:km-ln-cmd "UPSY" nil "L" "N" "UPS电源柜")
)

;;; Command: BZ
;;; Function: 选中两条水平线后向左生成短线、矩形并居中标注B+、B-及同步时钟主机柜（青色虚线）。
(defun c:BZ ()
  (aa:km-ln-cmd "BZ" T "B+" "B-" "同步时钟主机柜")
)

;;; Command: BY
;;; Function: 选中两条水平线后向右生成短线、矩形并居中标注B+、B-及同步时钟主机柜（青色虚线）。
(defun c:BY ()
  (aa:km-ln-cmd "BY" nil "B+" "B-" "同步时钟主机柜")
)

;;; ZJ/YJ：先确定柜内文字，再交给已有屏柜函数统一绘图和撤销。
(defun aa:zj-clean-text (value)
  (if (= (type value) 'STR)
    (vl-string-trim " \t\r\n" (vl-string-translate "\t\r\n" "   " value))))

(defun aa:zj-cmd (tag-name is-left txt-up txt-low manual-default
                  / source-mode cabinet-text clip-result preselected)
  (vl-load-com)
  (setq preselected (ssget "_I" '((0 . "LINE,LWPOLYLINE,POLYLINE"))))
  (initget "Clipboard Manual")
  (setq source-mode
    (getkword "\r\n柜内文字来源 [剪贴板(Clipboard)/手动(Manual)] <剪贴板>: "))
  (if (= source-mode "Manual")
    (progn
      (setq cabinet-text (getstring T (strcat "\r\n请输入柜内文字 <" manual-default ">: ")))
      (if (= cabinet-text "") (setq cabinet-text manual-default)))
    (progn
      (setq clip-result (vl-catch-all-apply 'qe:get-clip-text '()))
      (if (not (vl-catch-all-error-p clip-result))
        (setq cabinet-text clip-result))))
  (setq cabinet-text (aa:zj-clean-text cabinet-text))
  (if (and cabinet-text (/= cabinet-text ""))
    (progn
      (if preselected (sssetfirst nil preselected))
      (aa:km-ln-cmd tag-name is-left txt-up txt-low cabinet-text))
    (princ (strcat "\r\n[" tag-name "] 没有可用的柜内文字；剪贴板为空或读取失败时，请重新运行并选择手动(Manual)。未修改图形。")))
  (princ))

;;; Command: ZJ
;;; Function: 选中多条水平线后向左生成短线、矩形；原理号标注不变，柜内文字默认读取剪贴板，可手动输入（青色虚线）。
(defun c:ZJ ()
  (aa:zj-cmd "ZJ" T "原理号" "原理号" "终点柜名")
)

;;; Command: YJ
;;; Function: 选中多条水平线后向右生成短线、矩形；原理号标注不变，柜内文字默认读取剪贴板，可手动输入（青色虚线）。
(defun c:YJ ()
  (aa:zj-cmd "YJ" nil "原理号" "原理号" "终点柜名")
)

;;; =======================================================================================
;;; YDZ / YDY：为多条水平直线左端/右端生成连接短线与矩形，
;;; 直线上方从上往下依次标注 701、-901、-903、-905...，矩形正中心居中标注“公用测控柜”。
;;; 线段与矩形线型统一为 HIDDEN2，颜色统一为青色（ACI 4），文字统一为青色（ACI 4）。
;;; =======================================================================================

(defun aa:yd-cmd (tag-name is-left first-label number-prefix cabinet-text
                  / *error* doc aa:doc aa:undo-open oldcmd oldct oldce
                    en ed p1 p2 item idx
                    ss all-lines lines-by-y y-keys valid base-z
                    upper-y lower-y
                    extreme-x-list joint-x
                    rect-w rect-x1 rect-x2 rect-cx height center-y
                    bottom top rect-pt1 rect-pt2
                    line-mid-x
                    t-rect-en t-rect-bbox t-w
                    y-item cur-y cur-lines cur-ext-x cur-txt cur-center)
  (vl-load-com)
  (setq doc (vla-get-ActiveDocument (vlax-get-acad-object))
        aa:undo-open nil
        oldcmd nil
        oldct nil
        oldce nil)

  (defun *error* (msg)
    (if oldcmd (setvar "CMDECHO" oldcmd))
    (if oldct (setvar "CELTYPE" oldct))
    (if oldce (setvar "CECOLOR" oldce))
    (aa:undo-mark-off)
    (sssetfirst nil nil)
    (if (and msg
             (not (wcmatch (strcase msg) "*BREAK*,*CANCEL*,*EXIT*,*QUIT*")))
      (princ (strcat "\r\n[" tag-name "] 错误：" msg)))
    (princ))

  (setq ss (ssget "_I" '((0 . "LINE,LWPOLYLINE,POLYLINE"))))
  (if (null ss)
    (progn
      (princ (strcat "\r\n[" tag-name "] 请选择水平直线或多段线（多段线将自动分解）："))
      (setq ss (ssget "_:L" '((0 . "LINE,LWPOLYLINE,POLYLINE"))))))

  (if ss
    (progn
      (aa:undo-mark-on)
      (setq all-lines (aa:explode-collect-lines ss))
      (if (>= (length all-lines) 2)
        (progn
          (setq lines-by-y nil
                valid T
                base-z nil)
          (foreach en all-lines
            (setq ed (entget en)
                  p1 (cdr (assoc 10 ed))
                  p2 (cdr (assoc 11 ed)))
            (if (and p1 p2
                     (equal (cadr p1) (cadr p2) 0.05)
                     (or (null base-z)
                         (equal (if (caddr p1) (caddr p1) 0.0) base-z 1e-6))
                     (equal (if (caddr p1) (caddr p1) 0.0)
                            (if (caddr p2) (caddr p2) 0.0) 1e-6))
              (progn
                (if (null base-z)
                  (setq base-z (if (caddr p1) (caddr p1) 0.0)))
                ;; 允许 0.05 图形单位的微小高差；按出线侧端点取 Y，不修改原线。
                (setq cur-y
                  (cadr (if (if is-left
                              (<= (car p1) (car p2))
                              (>= (car p1) (car p2)))
                          p1 p2)))
                (setq lines-by-y (cons (list cur-y en p1 p2) lines-by-y)))
              (setq valid nil)))

          (if (not valid)
            (princ (strcat "\r\n[" tag-name "] 所选直线必须近似水平（两端高差不超过0.05）且位于同一标高。"))
            (progn
              ;; 获取所有不同的 Y 高度并降序排序（从上到下）
              (setq y-keys nil)
              (foreach item lines-by-y
                (if (not (vl-some (function (lambda (y) (equal y (car item) 1e-4))) y-keys))
                  (setq y-keys (cons (car item) y-keys))))
              (setq y-keys
                (aa:merge-sort
                  y-keys
                  (function (lambda (a b) (> a b)))))

              (if (< (length y-keys) 2)
                (princ (strcat "\r\n[" tag-name "] 请至少选择处于两个不同高度的水平直线。"))
                (progn
                  (setq upper-y (car y-keys)
                        lower-y (last y-keys))

                  ;; 获取各高度水平线的极端 X 坐标
                  (setq extreme-x-list nil)
                  (foreach cur-y y-keys
                    (setq cur-lines (vl-remove-if-not (function (lambda (item) (equal (car item) cur-y 1e-4))) lines-by-y))
                    (if is-left
                      (setq cur-ext-x
                        (apply 'min
                          (mapcar (function (lambda (item)
                                              (min (car (nth 2 item)) (car (nth 3 item)))))
                                  cur-lines)))
                      (setq cur-ext-x
                        (apply 'max
                          (mapcar (function (lambda (item)
                                              (max (car (nth 2 item)) (car (nth 3 item)))))
                                  cur-lines))))
                    (setq extreme-x-list (cons (cons cur-y cur-ext-x) extreme-x-list)))
                  (setq extreme-x-list (reverse extreme-x-list))

                  (if is-left
                    (progn
                      (setq joint-x (- (apply 'min (mapcar 'cdr extreme-x-list)) 20.0)
                            line-mid-x (/ (+ (+ joint-x 20.0) joint-x) 2.0)))
                    (progn
                      (setq joint-x (+ (apply 'max (mapcar 'cdr extreme-x-list)) 20.0)
                            line-mid-x (/ (+ (- joint-x 20.0) joint-x) 2.0))))

                  (setq height (max 20.0 (+ (- upper-y lower-y) 4.0))
                        center-y (/ (+ lower-y upper-y) 2.0)
                        bottom (- center-y (/ height 2.0))
                        top (+ center-y (/ height 2.0))
                        oldcmd (getvar "CMDECHO"))
                  (setvar "CMDECHO" 0)

                  ;; 加载 HIDDEN2 线型
                  (if (not (tblsearch "LTYPE" "HIDDEN2"))
                    (command "_.-LINETYPE" "_Load" "HIDDEN2" ""))

                  (setq oldct (getvar "CELTYPE")
                        oldce (getvar "CECOLOR"))
                  (setvar "CELTYPE" "HIDDEN2")
                  (setvar "CECOLOR" "4")

                  ;; 1. 为每个高度生成延伸短线（虚线 HIDDEN2，青色 4）
                  (foreach y-item extreme-x-list
                    (setq cur-y (car y-item)
                          cur-ext-x (cdr y-item))
                    (entmakex
                      (list '(0 . "LINE")
                            (cons 8 (getvar "CLAYER"))
                            '(62 . 4)
                            '(6 . "HIDDEN2")
                            (cons 10 (list cur-ext-x cur-y base-z))
                            (cons 11 (list joint-x cur-y base-z)))))

                  ;; 2. 按命令参数创建矩形内柜名文字，测量自适应宽度
                  (setq t-rect-en (aa:km-create-centered-text doc cabinet-text (list joint-x center-y base-z)))
                  (setq t-rect-bbox (if t-rect-en (aa:safe-get-bbox doc t-rect-en) nil))
                  (setq t-w (if t-rect-bbox
                              (- (aa:bbox-right-x t-rect-bbox) (aa:bbox-left-x t-rect-bbox))
                              (* (strlen cabinet-text) 3.0 0.7)))
                  (setq rect-w (+ t-w 5.0))

                  (if is-left
                    (setq rect-x1 (- joint-x rect-w)
                          rect-x2 joint-x
                          rect-cx (/ (+ rect-x1 rect-x2) 2.0))
                    (setq rect-x1 joint-x
                          rect-x2 (+ joint-x rect-w)
                          rect-cx (/ (+ rect-x1 rect-x2) 2.0)))

                  (setq rect-pt1 (list rect-x1 bottom base-z)
                        rect-pt2 (list rect-x2 top base-z))

                  ;; 3. 生成矩形（自适应宽度，虚线 HIDDEN2，青色 4）
                  (command "_.RECTANG" "_non" rect-pt1 "_non" rect-pt2)

                  ;; 4. 平移矩形文字至矩形正中心
                  (if t-rect-en
                    (aa:safe-move-entity t-rect-en (vlax-3d-point (list (- rect-cx joint-x) 0.0 0.0))))

                  ;; 5. 按命令参数生成短线上方编号，后续奇数编号保留连字符前缀。
                  (setq idx 0)
                  (foreach cur-y y-keys
                    (if (= idx 0)
                      (setq cur-txt first-label)
                      (setq cur-txt (strcat number-prefix (if (< (+ 1 (* (1- idx) 2)) 10)
                                                    (strcat "0" (itoa (+ 1 (* (1- idx) 2))))
                                                    (itoa (+ 1 (* (1- idx) 2)))))))
                    (setq cur-center (list line-mid-x (+ cur-y 1.5 (/ 3.0 2.0)) base-z))
                    (aa:km-create-centered-text doc cur-txt cur-center)
                    (setq idx (1+ idx)))

                  (redraw)
                  (setvar "CELTYPE" oldct)
                  (setvar "CECOLOR" oldce)
                  (setvar "CMDECHO" oldcmd)
                  (setq oldcmd nil)
                  (princ (strcat "\r\n[" tag-name "] 已成功为 " (itoa (length y-keys))
                                 " 条水平线生成短线、矩形（自适应宽" (rtos rect-w 2 2)
                                 "×高" (rtos height 2 2) "）及居中文注。")))))))
        (princ (strcat "\r\n[" tag-name "] 分解后至少需要两条水平直线。"))))
    (princ (strcat "\r\n[" tag-name "] 必须选择直线或多段线。")))
  (aa:undo-mark-off)
  (sssetfirst nil nil)
  (princ)
)

;;; Command: YDZ
;;; Function: 选中多条水平线后向左生成短线、矩形并从上往下标注701、-901、-903...及公用测控柜（青色虚线）。
(defun c:YDZ ()
  (aa:yd-cmd "YDZ" T "701" "-9" "公用测控柜")
)

;;; Command: YDY
;;; Function: 选中多条水平线后向右生成短线、矩形并从上往下标注701、-901、-903...及公用测控柜（青色虚线）。
(defun c:YDY ()
  (aa:yd-cmd "YDY" nil "701" "-9" "公用测控柜")
)

;;; Command: LBZ
;;; Function: 选中多条水平线后向左生成短线、矩形并从上往下标注500、-501、-503...及故障录波柜（青色虚线）。
(defun c:LBZ ()
  (aa:yd-cmd "LBZ" T "500" "-5" "故障录波柜")
)

;;; Command: LBY
;;; Function: 选中多条水平线后向右生成短线、矩形并从上往下标注500、-501、-503...及故障录波柜（青色虚线）。
(defun c:LBY ()
  (aa:yd-cmd "LBY" nil "500" "-5" "故障录波柜")
)

;;; Command: 485Z
;;; Function: 选中至少两条水平线后向左生成短线、矩形并居中标注485+、485-及网络通信柜（青色虚线）。
(defun c:485Z ()
  (aa:km-ln-cmd "485Z" T "485+" "485-" "网络通信柜")
)

;;; Command: 485Y
;;; Function: 选中至少两条水平线后向右生成短线、矩形并居中标注485+、485-及网络通信柜（青色虚线）。
(defun c:485Y ()
  (aa:km-ln-cmd "485Y" nil "485+" "485-" "网络通信柜")
)

(princ)
;;; END INTEGRATED SOURCE: KMZ_KMY.lsp

;;; =======================================================================================
;;; BEGIN XX: 将选中文字替换为固定内容 7×2.5
;;; =======================================================================================
;;; Encoding: UTF-8 without BOM, CRLF.
;;; XX：将选中文字内容替换为 "7×2.5"（预选优先，未预选则点选）。

(defun c:XX (/ *error* aa:tag aa:doc aa:undo-open aa:old-cmdecho ss en obj cnt i)
  (aa:cmd-begin "XX")
  (vl-load-com)
  (setq ss (ssget "_I" '((0 . "TEXT,MTEXT"))))
  (if (null ss)
    (progn
      (princ "\r\n请点选要替换为 7×2.5 的文字：")
      (setq en (entsel))
      (if en
        (setq ss (ssadd (car en))))))
  (if ss
    (progn
      (setq cnt 0 i 0)
      (while (< i (sslength ss))
        (setq en (ssname ss i)
              obj (vlax-ename->vla-object en))
        (if (member (strcase (vla-get-ObjectName obj))
                    '("ACDBTEXT" "ACDBMTEXT"))
          (progn
            (vlax-put obj (quote TextString) "7×2.5")
            (setq cnt (1+ cnt))))
        (vlax-release-object obj)
        (setq i (1+ i)))
      (redraw)
      (princ (strcat "\r\n[XX] 已把 " (itoa cnt) " 个文字替换为 7×2.5。")))
    (princ "\r\n[XX] 未选择文字。"))
  (sssetfirst nil nil)
  (aa:cmd-end)
)
;;; =======================================================================================
;;; BEGIN AA 结果卡片：命令把明细写进结果文件，AHK 面板弹出卡片显示，点条目定位到图上
;;; =======================================================================================
;;; Encoding: UTF-8 without BOM, CRLF.
;;; 结果文件 %TEMP%\AA-CAD-Report\report.txt（UTF-8，TAB 分隔，先写 .tmp 再改名，避免读到半个文件）：
;;;   AAREPORT 1 / ID / CMD / TIME / DWG（完整路径）/ SHORT（一行汇总）/ SUM（完整统计）/ INFO 说明… / ITEM 级别 类别 句柄 文字…
;;;   级别：err 问题、warn 提醒、ok 正常、info 说明。命令行只显示一行汇总。
;;; AHK（excel-command-panel）检测到新结果且有条目时弹出卡片；点条目在 CAD 空闲时发送 (aa:rep-zoom "句柄") 定位。

(setq *aa-rep-cmd* nil *aa-rep* nil *aa-rep-info* nil)

(defun aa:rep-begin (cmd)
  (setq *aa-rep-cmd* cmd *aa-rep* nil *aa-rep-info* nil)
)

(defun aa:rep-text (s)
  ;; 写入结果文件的一项：TAB、换行换成空格
  (foreach c '("\t" "\r" "\n")
    (setq s (aa:str-replace-all c " " (if s s ""))))
  s
)

(defun aa:rep-item (level kind en txt / ed h)
  ;; 一条明细：level 为 err/warn/ok/info，kind 为类别，en 为点击后要定位的图元（可为 nil）
  (setq h (if (and en (setq ed (entget en))) (cdr (assoc 5 ed))))
  (setq *aa-rep* (cons (list level kind (if h h "") txt) *aa-rep*))
)

(defun aa:rep-info (txt)
  (setq *aa-rep-info* (cons txt *aa-rep-info*))
)

(defun aa:rep-dir (/ d)
  (setq d (getenv "TEMP"))
  (if (or (null d) (= d "")) (setq d (getvar "TEMPPREFIX")))
  (strcat (vl-string-right-trim "\\" d) "\\AA-CAD-Report")
)

(defun aa:rep-write (short full / dir tmp out f r ok)
  ;; 写结果文件；成功返回 T
  (setq dir (aa:rep-dir) tmp (strcat dir "\\report.tmp") out (strcat dir "\\report.txt"))
  (vl-mkdir dir)
  (if (setq f (aa:link-open tmp "w"))
    (progn
      (write-line "AAREPORT\t1" f)
      (write-line (strcat "ID\t" (rtos (getvar "DATE") 2 8) "-" *aa-rep-cmd*) f)
      (write-line (strcat "CMD\t" *aa-rep-cmd*) f)
      (write-line (strcat "TIME\t" (menucmd "M=$(edtime,$(getvar,date),YYYY-MO-DD HH:MM:SS)")) f)
      (write-line (strcat "DWG\t" (getvar "DWGPREFIX") (getvar "DWGNAME")) f)
      (write-line (strcat "SHORT\t" (aa:rep-text short)) f)
      (write-line (strcat "SUM\t" (aa:rep-text full)) f)
      (foreach r (reverse *aa-rep-info*)
        (write-line (strcat "INFO\t" (aa:rep-text r)) f))
      (foreach r (reverse *aa-rep*)
        (write-line (strcat "ITEM\t" (car r) "\t" (aa:rep-text (cadr r)) "\t" (caddr r) "\t" (aa:rep-text (cadddr r))) f))
      (close f)
      (if (findfile out) (vl-file-delete out))
      (setq ok (vl-file-rename tmp out))))
  ok
)

(defun aa:rep-end (short full / n bad)
  ;; 命令结束：写结果文件，命令行只显示一行汇总（short）；写不进去时把明细打在命令行，信息不丢
  (setq n (length *aa-rep*))
  (foreach r *aa-rep* (if (member (car r) '("err" "warn")) (setq bad (cons r bad))))
  (if (aa:rep-write short full)
    (princ (strcat "\r\n[" *aa-rep-cmd* "] " short
                   (cond ((> (length bad) 0) (strcat "；" (itoa (length bad)) " 条问题已选中，明细见结果卡片"))
                         ((> n 0) "；明细见结果卡片")
                         (T ""))))
    (progn
      (princ (strcat "\r\n[" *aa-rep-cmd* "] " full))
      (foreach r (reverse *aa-rep-info*) (princ (strcat "\r\n[" *aa-rep-cmd* "] " r)))
      (foreach r (reverse *aa-rep*) (princ (strcat "\r\n[" *aa-rep-cmd* "] " (cadr r) "：" (cadddr r))))))
  (setq *aa-rep* nil *aa-rep-info* nil)
)

(defun aa:rep-counts (lst / out r)
  ;; ((“填入” . 3) (“冲突” . 0) ...) → “填入 3，…”，只列非零项；全为 0 返回“没有变化”
  (foreach r lst
    (if (and (cdr r) (> (cdr r) 0))
      (setq out (if out (strcat out "，" (car r) " " (itoa (cdr r))) (strcat (car r) " " (itoa (cdr r)))))))
  (if out out "没有变化")
)

(defun aa:rep-zoom (h / en obj mn mx a b c w res)
  ;; 结果卡片点条目时由 AHK 调用：按句柄缩放到对象并选中
  (vl-load-com)
  (if (and h (setq en (handent h)) (entget en))
    (progn
      (setq obj (vlax-ename->vla-object en)
            res (vl-catch-all-apply 'vla-GetBoundingBox (list obj 'mn 'mx)))
      (if (not (vl-catch-all-error-p res))
        (progn
          (setq a (vlax-safearray->list mn) b (vlax-safearray->list mx)
                c (mapcar '(lambda (p q) (/ (+ p q) 2.0)) a b)
                ;; 半宽至少 120：字高 3 的截面、编号文字也能看到整段电缆线和端子排上下文（实测 40 太窄）
                w (max 120.0 (min 300.0 (* 1.5 (max (- (car b) (car a)) (- (cadr b) (cadr a)))))))
          (vla-ZoomWindow (vlax-get-acad-object)
                          (vlax-3d-point (list (- (car c) w) (- (cadr c) (* 0.6 w)) 0.0))
                          (vlax-3d-point (list (+ (car c) w) (+ (cadr c) (* 0.6 w)) 0.0)))))
      (vlax-release-object obj)
      (sssetfirst nil (ssadd en))
      (princ (strcat "\r\n[结果卡片] 已定位到对象 " h)))
    (princ (strcat "\r\n[结果卡片] 找不到对象 " (if h h "") "（可能已删除，或不在当前图纸）")))
  (princ)
)
;;; END AA 结果卡片
;;; =======================================================================================
;;; BEGIN JM: 按原理号自动填写电缆截面
;;; =======================================================================================
;;; Encoding: UTF-8 without BOM, CRLF.
;;; JM：复用 XY/XYG 的“绿色水平电缆线 → 竖向芯线 → 竖排原理号”识别，
;;; 只替换 ZDDL 写在电缆线右上方的“未填写”；判断不了的保留原文字，结束后选中提示人工确认。
;;; 已填写的截面按同样规则核对，不一致或芯数不足的在电缆线右端写红字（JM_MARK 图层，同 BH2 的位置）并选中；
;;; 原理号判断不了的已填截面写“[无法核对] 原因”并选中。每次运行先清掉这些线上次的 JM 原因文字。
;;; 截面规则（原理号先去空格、转大写，取最后一个减号后的部分判断）：
;;;   B+ / B- / 485+ / 485-（末尾带撇号 485+' 也算）→ 通讯线
;;;   含 KM（控母）、BM（合母/装置母线）、HM（合闸母线）、ZM（装置母线）→ 2×4
;;;   L、N、L1、N1（单个 L/N 或加一位数字）→ 2×4
;;;   BL01、BT01、BS01、B01（并列/备自投/闭锁/非电量开入，B 只接两位数字；也可写成 BS-01、B-01）→ 信号线
;;;   A/B/C/N 开头接数字（A4253、N600、A640I ...）、L 接三位以上数字（L610、L640 ...）→ 4×4
;;;   纯数字 5xx/7xx/8xx/9xx（501、701、801、8010、DN-901 ...）→ 信号线 4/7/10/14×1.5
;;;   纯数字 1xx 及三位以上的 2xx/3xx（101、133、233、333 ...）→ 控制线 4/7/10×2.5（没有 14×2.5）
;;;   单个字母接纯数字（R133 ...）→ 按数字部分同上判断
;;;   数字带字母后缀（107A ...）：5/7/8/9 开头是信号线；控制号带后缀是测控信号回路，
;;;     这根电缆里只要有一个，整根的控制号都按信号线 1.5 算（107 107A → 4×1.5）
;;;   减号后只有一两位数字（1UYHD-01、1UYHD-33 ...）→ 控制线
;;;   信号/控制线芯数取严格大于原理号个数的最小规格，留备用芯。

(defun jm:norm (s / pr)
  ;; 去空格、转大写，全角加减号统一为半角
  (setq s (strcase (if s s "")))
  (foreach pr '((" " . "") ("\t" . "") ("＋" . "+") ("－" . "-") ("—" . "-") ("–" . "-"))
    (setq s (aa:str-replace-all (car pr) (cdr pr) s)))
  s
)

(defun jm:tail (s / pos)
  ;; 最后一个减号之后的部分：2B-A4253 → A4253，DN-901 → 901
  (if (setq pos (vl-string-position (ascii "-") s nil T))
    (substr s (+ pos 2))
    s)
)

(defun jm:digits-p (s)
  (and (/= s "") (not (wcmatch s "*[~0-9]*")))
)

(defun jm:classify (raw / s tl n c)
  ;; 返回 COMM / KM / LN / AC / SIG / CTL / CTLS（控制号带字母后缀）；无法识别返回 nil
  (setq s (jm:norm raw) tl (jm:tail s) n (strlen s))
  ;; 通讯线判断忽略末尾撇号（第二路通讯常写成 485+' 485-'）
  (setq c (vl-string-right-trim "'`" (aa:str-replace-all "′" "'" (aa:str-replace-all "’" "'" s))))
  (cond
    ((= s "") nil)
    ((or (member c '("B+" "B-"))
         (and (>= (strlen c) 4) (member (substr c (- (strlen c) 3)) '("485+" "485-"))))
     'COMM)
    ((or (vl-string-search "KM" s) (vl-string-search "BM" s)
         (vl-string-search "HM" s) (vl-string-search "ZM" s)) 'KM)
    ((wcmatch s "L,N,LN,L#,N#") 'LN)
    ;; 并列/备自投/闭锁/非电量开入，也有写成 BS-01、BL-03、B-05 的
    ((or (wcmatch tl "B##,BL#*,BT#*,BS#*") (wcmatch s "B-##,*BL-#*,*BT-#*,*BS-#*")) 'SIG)
    ;; L 接三位以上数字是 PT 电压的 L 相（L610、L630、L640、L601 ...）；
    ;; U/I 接相别再接数字是电压、电流回路（UA1 UB1 UC1 UN1、IA2 IB2 IC2 IN2 ...）
    ((wcmatch tl "[ABCN]#*,L###*,[UI][ABCN]#*") 'AC)
    ;; 减号后只有一两位数字（1UYHD-01、1UYHD-33 ...）算控制线
    ((and (jm:digits-p tl) (/= tl s) (<= (strlen tl) 2)) 'CTL)
    ((jm:digits-p tl) (jm:num-class tl))
    ;; 单个字母接纯数字（R133 ...）按数字部分判断
    ((and (wcmatch tl "@#*") (jm:digits-p (substr tl 2))) (jm:num-class (substr tl 2)))
    ;; 数字带字母后缀（107A ...）按数字部分判断，控制号带后缀记为 CTLS（测控信号回路）
    ((and (wcmatch tl "#*@") (jm:digits-p (vl-string-right-trim "ABCDEFGHIJKLMNOPQRSTUVWXYZ" tl)))
     (if (eq (setq n (jm:num-class (vl-string-right-trim "ABCDEFGHIJKLMNOPQRSTUVWXYZ" tl))) 'CTL) 'CTLS n))
    (T nil))
)

(defun jm:num-class (d)
  ;; 纯数字原理号：1xx、三位以上 2xx/3xx 控制线，5xx/7xx/8xx/9xx 信号线
  (cond
    ((wcmatch d "1*") 'CTL)
    ((and (wcmatch d "2*,3*") (>= (strlen d) 3)) 'CTL)
    ((wcmatch d "5*,7*,8*,9*") 'SIG)
    (T nil))
)

(defun jm:fixed-spec (cls)
  (cdr (assoc cls '((AC . "4×4") (KM . "2×4") (LN . "2×4") (COMM . "通讯线"))))
)

(defun jm:pick-cores (n lst / out c)
  ;; 取严格大于原理号个数的最小芯数（必须留备用芯）
  (foreach c lst
    (if (and (null out) (> c n)) (setq out c)))
  out
)

(defun jm:join (lst / out s)
  (setq out "")
  (foreach s lst
    (setq out (if (= out "") s (strcat out " " s))))
  out
)

(defun jm:decide (prins / n c classes unknown specs spec cores)
  ;; 返回 (截面 . nil)；无法确定返回 (nil . 原因)
  (setq n (length prins))
  (foreach c prins
    (setq spec (jm:classify c))
    (if spec
      (if (not (member spec classes)) (setq classes (cons spec classes)))
      (setq unknown (cons (if (= c "") "(空)" c) unknown))))
  ;; 有控制号带字母后缀（107A）的是测控信号回路：整根的控制号都按信号线算
  (if (member 'CTLS classes)
    (setq classes (cons 'SIG (vl-remove 'SIG (vl-remove 'CTL (vl-remove 'CTLS classes))))))
  (cond
    ((= n 0) (cons nil "未识别到原理号"))
    (unknown (cons nil (strcat "无法识别的原理号: " (jm:join (reverse unknown)))))
    ((vl-every 'jm:fixed-spec classes)
     (foreach c classes
       (setq spec (jm:fixed-spec c))
       (if (not (member spec specs)) (setq specs (cons spec specs))))
     (if (cdr specs)
       (cons nil "原理号类型混合")
       (cons (car specs) nil)))
    ((cdr classes) (cons nil "原理号类型混合"))
    ((eq (car classes) 'SIG)
     (if (setq cores (jm:pick-cores n '(4 7 10 14)))
       (cons (strcat (itoa cores) "×1.5") nil)
       (cons nil (strcat "信号线原理号 " (itoa n) " 个，超出 14×1.5"))))
    ((eq (car classes) 'CTL)
     (if (setq cores (jm:pick-cores n '(4 7 10)))
       (cons (strcat (itoa cores) "×2.5") nil)
       (cons nil (strcat "控制线原理号 " (itoa n) " 个，超出 10×2.5（没有 14×2.5）"))))
    (T (cons nil "无法判断")))
)

(defun jm:line-principles (ed vlineDataList textMetaList / vrecs vrec tail scan cand rectXmin rectXmax txt prins miss)
  ;; 与 YUAN 相同：按竖线远端 X 滑动查找竖排原理号；返回 (原理号列表 未找到数)
  (setq vrecs (xy:get-vrecs-for-hline-ed ed vlineDataList)
        prins nil miss 0 tail textMetaList)
  (foreach vrec (aa:merge-sort vrecs
                  '(lambda (a b) (< (car (caddr a)) (car (caddr b)))))
    (setq rectXmin (- (car (caddr vrec)) *xy-hit-half-width*)
          rectXmax (+ (car (caddr vrec)) *xy-hit-half-width*))
    (while (and tail (< (caddr (car tail)) (- rectXmin *xy-geom-tol*)))
      (setq tail (cdr tail)))
    (setq cand nil scan tail)
    (while (and scan (<= (cadr (car scan)) (+ rectXmax *xy-geom-tol*)))
      (setq cand (cons (car scan) cand) scan (cdr scan)))
    (if (setq txt (xy:find-text-for-vrec (reverse cand) vrec))
      (setq prins (cons (aa:ysdl-get-plain-text (entget txt)) prins))
      (setq miss (1+ miss))))
  (list (reverse prins) miss)
)

(defun jm:spec-norm (s / pr)
  ;; 截面比较用：去空格、转大写，x / X / * 统一为 ×
  (setq s (jm:norm s))
  (foreach pr '(("X" . "×") ("*" . "×") ("＊" . "×"))
    (setq s (aa:str-replace-all (car pr) (cdr pr) s)))
  s
)

(defun jm:spec-like-p (s / z)
  ;; 是不是截面文字：“未填写”、“通讯线”或“芯数×截面”
  (setq z (jm:spec-norm s))
  (or (= z "未填写") (= z "通讯线")
      (and (vl-string-search "×" z) (wcmatch z "#*")))
)

(defun jm:check-spec (have dec n / h e c)
  ;; 已填写的截面与按原理号算出的比较；合理返回 nil，否则返回原因
  (setq h (jm:spec-norm have) e (car dec))
  (cond
    ((= h (jm:spec-norm e)) nil)
    ((and (vl-string-search "×" h) (> (setq c (atoi h)) 0) (<= c n))
     (strcat "芯数不足：原理号 " (itoa n) " 个，须留备用芯，应为 " e))
    (T (strcat "应为 " e)))
)

(defun jm:ensure-layer ()
  (if (not (tblsearch "LAYER" "JM_MARK"))
    (entmake '((0 . "LAYER") (100 . "AcDbSymbolTableRecord")
               (100 . "AcDbLayerTableRecord") (2 . "JM_MARK")
               (70 . 0) (62 . 1))))
)

(defun jm:clear-marks (hinfos / ss marks i en ip h rx ry rest m)
  ;; 删除这些电缆线右端上次 JM 写的原因文字（JM_MARK 图层，与 BH 的 BH_MARK 分开）
  (if (setq ss (ssget "_X" '((0 . "TEXT") (8 . "JM_MARK"))))
    (progn
      (setq i 0)
      (repeat (sslength ss)
        (setq en (ssname ss i) i (1+ i))
        (if (setq ip (cdr (assoc 10 (entget en))))
          (setq marks (cons (list (car ip) (cadr ip) en) marks))))
      (foreach h hinfos
        (setq rx (cadr h) ry (caddr h) rest nil)
        (foreach m marks
          (if (and (<= (+ rx 1.0) (car m) (+ rx 4.0)) (< ry (cadr m) (+ ry 3.0)))
            (entdel (caddr m))
            (setq rest (cons m rest))))
        (setq marks rest))))
)

(defun jm:make-mark (hinfo txt)
  ;; 与 BH2 相同：电缆线右端写红色原因
  (jm:ensure-layer)
  (entmakex (list '(0 . "TEXT") '(8 . "JM_MARK")
                  (list 10 (+ (cadr hinfo) 2.0) (+ (caddr hinfo) 0.5) 0.0)
                  '(40 . 3.0) (cons 1 txt) '(50 . 0.0) '(41 . 0.7) '(62 . 1)
                  (cons 7 (if (tblsearch "STYLE" "HZ") "HZ" (getvar "TEXTSTYLE")))))
)

(defun jm:find-spec-text (hinfo / xmin rx ry ss en ed ip best bestx)
  ;; ZDDL 把截面（先写“未填写”）写在电缆线上方 0.5~1.0、线段范围内最右边；同一根线取最靠右的截面文字
  (setq xmin (car hinfo) rx (cadr hinfo) ry (caddr hinfo))
  (setq ss (xy:window-wcs xmin (+ ry 0.1) (+ rx 2.0) (+ ry 3.0) '((0 . "TEXT,MTEXT"))))
  (foreach en (xy:ss->list ss)
    (setq ed (entget en) ip (cdr (assoc 10 ed)))
    (if (and ip
             (jm:spec-like-p (aa:ysdl-get-plain-text ed))
             (<= (- xmin 0.1) (car ip) rx)
             (< ry (cadr ip) (+ ry 3.0))
             (or (null bestx) (> (car ip) bestx)))
      (setq best en bestx (car ip))))
  best
)

(defun jm:set-text (en val / ed obj)
  (setq ed (entget en))
  (if (= (cdr (assoc 0 ed)) "TEXT")
    (entmod (subst (cons 1 val) (assoc 1 ed) ed))
    (progn
      (setq obj (vlax-ename->vla-object en))
      (vl-catch-all-apply 'vla-put-TextString (list obj val))
      (vlax-release-object obj)))
)

;;; 功能: 框选 ZDDL 出线区域，按绿色电缆线所连原理号把“未填写”替换为电缆截面，并核对已填写的截面，不合理或无法判断的在右端写红字并选中。
(defun c:JM (/ *error* aa:tag aa:doc aa:undo-open aa:old-cmdecho
               ss lines vlineDataList textMetaList en ed hinfo res prins miss dec spec-en
               done skip unsure-ss have why nok nbad nunk hinfos r)
  (aa:cmd-begin "JM")
  (aa:rep-begin "JM")
  (princ "\r\n[JM] 请框选包含绿色电缆线、芯线、原理号和“未填写”的区域: ")
  (setq ss (ssget) unsure-ss (ssadd))
  (cond
    ((null ss)
     (princ "\r\n[JM] 未选择对象，命令结束。"))
    ((null (setq lines (xyg:dedup-hlines (xy:ss->list (xy:filter-green-hlines ss)) 0.5)))
     (princ "\r\n[JM] 选区中未找到绿色水平直线，命令结束。"))
    (T
     ;; 清掉上次 XY/XYG 的竖线缓存，按本次选区重新识别
     (setq *xy-last-vrec-map* nil)
     (setq vlineDataList (xy:collect-vlines lines))
     (xy:build-vline-buckets vlineDataList)
     (setq textMetaList (xy:build-text-meta-list (xy:collect-texts lines vlineDataList)))
     (setq done 0 skip 0 nok 0 nbad 0 nunk 0)
     (foreach en lines
       (setq ed (entget en) hinfo (xy:hline-info-ed ed))
       (if (setq spec-en (jm:find-spec-text hinfo))
         (progn
           (setq hinfos (cons hinfo hinfos)
                 have (aa:ysdl-get-plain-text (entget spec-en))
                 res (jm:line-principles ed vlineDataList textMetaList)
                 prins (car res)
                 miss (cadr res))
           (setq dec (if (> miss 0)
                       (cons nil (strcat "有 " (itoa miss) " 根芯线未找到原理号"))
                       (jm:decide prins)))
           (cond
             ;; “未填写”：判断得了就填，判断不了的保留并写原因
             ((= (jm:spec-norm have) "未填写")
              (if (car dec)
                (progn
                  (jm:set-text spec-en (car dec))
                  (setq done (1+ done)))
                (progn
                  (ssadd spec-en unsure-ss)
                  (setq why (cons (list hinfo (strcat "[无法判断] " (cdr dec))) why))
                  (aa:rep-item "err" "无法判断" spec-en
                               (strcat "原理号[" (jm:join prins) "]：" (cdr dec) "，保留“未填写”")))))
             ;; 已填写的：按原理号核对；原理号判断不了的也选中并写原因，由人工确认
             ((null (car dec))
              (ssadd spec-en unsure-ss)
              (setq nunk (1+ nunk)
                    why (cons (list hinfo (strcat "[无法核对] " (cdr dec))) why))
              (aa:rep-item "warn" "无法核对" spec-en
                           (strcat "已填 " have "，原理号[" (jm:join prins) "]：" (cdr dec))))
             ((setq r (jm:check-spec have dec (length prins)))
              (ssadd spec-en unsure-ss)
              (setq nbad (1+ nbad)
                    why (cons (list hinfo (strcat "[截面不合理] " r)) why))
              (aa:rep-item "err" "截面不合理" spec-en
                           (strcat "已填 " have "，原理号[" (jm:join prins) "]：" r)))
             (T (setq nok (1+ nok)))))
         (setq skip (1+ skip))))
     ;; 清掉这些电缆线上次的原因文字，再写本次的
     (jm:clear-marks hinfos)
     (foreach r why (jm:make-mark (car r) (cadr r)))
     (redraw)
     (aa:rep-end
       (strcat "完成：" (aa:rep-counts (list (cons "填写" done) (cons "核对合理" nok) (cons "不合理" nbad)
                                            (cons "无法判断" (- (sslength unsure-ss) nbad nunk)) (cons "无法核对" nunk))))
       (strcat "完成：已填写 " (itoa done) " 根；无法判断 "
               (itoa (- (sslength unsure-ss) nbad nunk)) " 根（保留“未填写”）；已填写的核对：合理 "
               (itoa nok) " 根，不合理 " (itoa nbad) " 根，原理号判断不了无法核对 " (itoa nunk)
               " 根；没有截面文字跳过 " (itoa skip) " 根。"
               (if (> (sslength unsure-ss) 0) "问题截面已选中，并在电缆线右端写了红色原因。" "")))))
  (aa:cmd-end)
  (if (> (sslength unsure-ss) 0)
    (sssetfirst nil unsure-ss)
    (sssetfirst nil nil))
  (princ)
)
;;; END JM
;;; =======================================================================================
;;; Encoding: UTF-8 without BOM, CRLF.
;;; BH1：编号。先点起点柜名大字，输入前缀和起始号，再依次点绿色电缆线（记住顺序），
;;;      回车后自动缩放到所有电缆线和原理号都在屏幕内、一次识别，按点选顺序编号，同终点再次出现时第一根改为 A、
;;;      之后 B、C；到录波柜的信号线固定 130，到公用测控柜的信号线固定 131；编完恢复原视图，可撤销本批。
;;; BH2：记录与填写，不分配新编号。一次框选一个起点柜（字高 >=80 的柜名大字）和它的绿色电缆线，
;;; 复用 JM 的“绿色电缆线 → 芯线 → 原理号”识别。每根电缆以“两端柜名（不分起终点）+ 原理号集合
;;; （不分顺序）”确定，记录在 dwg 所在文件夹的“电缆编号记录.txt”（UTF-8，TAB 分隔），
;;; 同一文件夹的各卷册图共用，所以电缆另一端在别的图里也能对上号：
;;;   已有编号 → 记录里没有就记入；是记录的旧编号就改成新编号；其余不一致的编号标红，
;;;               并在电缆线右端写原因（BH_MARK 图层）；
;;;   “未编号” → 记录里有就直接填入；没有记录的不动（用 BH1 编号）。
;;; BH3：从电缆清册表格记录。框选清册文字（列：起点柜 编号 终点柜 规格 芯数 原理号…），以本次选中的清册为准：
;;;      没有的记入；有的强制改成清册编号，原编号存为旧编号（同 BHG）；“***”等占位编号照常记录，可多根共用；
;;;      编号为空或未编号、没有原理号的行跳过；编号属于另一根电缆时删掉那条记录改给清册这根；清册内同一电缆
;;;      或同一编号重复的都记入（完全相同的行只记一次）；这些情况在命令行“说明”并选中编号，不拒绝。
;;; BHG：以图为准改记录。框选方式同 BH2，把记录里的编号改成图上的编号，原编号存入“旧编号”列，
;;;       另一端再运行 BH1/BH2 时自动跟着改；选中的“未编号”电缆删除其记录。
;;; 记录文件先写成功才改图；一次 U 撤销图面修改，但不会撤销已写入的记录。
;;; 记录列：电缆编号 柜名1 柜名2 原理号 图纸 时间 旧编号（旧编号可空，多个用空格分隔；旧 6 列文件照常读取）。

(setq *bh-record-name* "电缆编号记录.txt")

(defun bh:split (s sep / out p)
  ;; 按单字符分隔符拆分
  (while (setq p (vl-string-search sep s))
    (setq out (cons (substr s 1 p) out)
          s (substr s (+ p 2))))
  (reverse (cons s out))
)

(defun bh:clean (s)
  ;; 编号比较用：去空格、转大写
  (jm:norm (vl-string-trim " \t" (if s s "")))
)

(defun bh:prins-str (lst / out p)
  ;; 原理号去空格转大写、去空项后排序，用空格连接；排列顺序不影响比较
  (foreach p lst
    (setq p (jm:norm p))
    (if (/= p "") (setq out (cons p out))))
  (jm:join (aa:merge-sort out '(lambda (a b) (< a b))))
)

(defun bh:key (a b prins / na nb)
  ;; 两端柜名不分先后：按比较用柜名排序后拼上原理号
  (setq na (hddl:cabinet a) nb (hddl:cabinet b))
  (if (< nb na) (setq a na na nb nb a))
  (strcat na (chr 1) nb (chr 1) prins)
)

(defun bh:rec-key (r)
  (bh:key (nth 1 r) (nth 2 r) (bh:prins-str (bh:split (nth 3 r) " ")))
)

(defun bh:olds (r / out o)
  ;; 记录第 7 列：旧编号列表
  (foreach o (if (nth 6 r) (bh:split (nth 6 r) " "))
    (if (/= o "") (setq out (cons o out))))
  (reverse out)
)

(defun bh:kmap (recs keys / out r k)
  ;; 键 → (键 编号 旧编号列表)；同一键多行时以最前面一行为准。keys 为与 recs 一一对应的键（bh:rec-key 只算一次）
  (foreach r recs
    (setq k (car keys) keys (cdr keys))
    (if (not (assoc k out)) (setq out (cons (list k (car r) (bh:olds r)) out))))
  out
)

(defun bh:placeholder-p (num)
  ;; “***”之类没有字母和数字的编号是占位编号，可以多根电缆共用
  (not (wcmatch (if num num "") "*[A-Za-z0-9]*"))
)

(defun bh:nmap (recs keys / out r nc)
  ;; 比较用编号 → (编号 键 柜名1 柜名2)；占位编号不收录
  (foreach r recs
    (setq nc (bh:clean (car r)))
    (if (and (not (bh:placeholder-p nc)) (not (assoc nc out)))
      (setq out (cons (list nc (car keys) (nth 1 r) (nth 2 r)) out)))
    (setq keys (cdr keys)))
  out
)

(defun bh:rebuild (recs rkeys upd del ren / ks r k k2 o olds oldmap keep)
  ;; 以图/清册为准重建记录表（BHG、BH3 共用）：
  ;;   upd ((键 新记录) ...) 改为新记录；del (键 ...) 删除；ren ((原键 . 新键) ...) 同一根电缆换了柜名或原理号。
  ;;   被改掉的记录收集原编号和旧编号（按时间先后），写进新记录第 7 列，新记录统一追加到末尾。
  (setq ks rkeys)
  (foreach r recs
    (setq k (car ks)
          ks (cdr ks)
          k2 (if (assoc k ren) (cdr (assoc k ren)) k))
    (cond
      ((member k del) nil)
      ((assoc k2 upd)
       (setq k k2 olds (cdr (assoc k oldmap)))
       (foreach o (append (bh:olds r) (list (car r)))
         (if (not (member (bh:clean o) (mapcar 'bh:clean olds)))
           (setq olds (append olds (list o)))))
       (setq oldmap (cons (cons k olds) (vl-remove (assoc k oldmap) oldmap))))
      (T (setq keep (cons r keep)))))
  (foreach r (reverse upd)
    (setq olds nil)
    (foreach o (cdr (assoc (car r) oldmap))
      (if (/= (bh:clean o) (bh:clean (car (cadr r))))
        (setq olds (append olds (list o)))))
    (setq keep (cons (append (cadr r) (list (jm:join olds))) keep)))
  (reverse keep)
)

(defun bh:record-path ()
  (strcat (getvar "DWGPREFIX") *bh-record-name*)
)

(defun bh:now ()
  (menucmd "M=$(edtime,$(getvar,date),YYYY-MO-DD HH:MM:SS)")
)

(defun bh:dest-p (s / z)
  (setq s (vl-string-trim " \t" (if s s "")) z (strlen "至"))
  (and (> (strlen s) z) (= (substr s 1 z) "至"))
)

(defun bh:dest-name (s)
  (setq s (vl-string-trim " \t" s))
  (vl-string-trim " \t" (substr s (1+ (strlen "至"))))
)

(defun bh:read-lines (f / line flds recs)
  (while (setq line (read-line f))
    (if (and (> (strlen line) 0) (= (substr line (strlen line)) "\r"))
      (setq line (substr line 1 (1- (strlen line)))))
    (setq flds (bh:split line (chr 9)))
    ;; 跳过表头（可能带 BOM）、空行和列数不足的行
    (if (and (>= (length flds) 4)
             (/= (vl-string-trim " \t" (car flds)) "")
             (not (vl-string-search "电缆编号" (car flds))))
      (setq recs (cons (mapcar '(lambda (x) (vl-string-trim " \t" x)) flds) recs))))
  (reverse recs)
)

(defun bh:read-records (path / f res)
  ;; 返回 ((编号 柜名1 柜名2 原理号 图纸 时间 旧编号) ...)；没有文件时返回 nil
  (if (and (findfile path) (setq f (aa:link-open path "r")))
    (progn
      (setq res (vl-catch-all-apply 'bh:read-lines (list f)))
      (close f)
      (if (vl-catch-all-error-p res) nil res))
  )
)

(defun bh:write-lines (f recs / tab r)
  (setq tab (chr 9))
  (write-line (strcat "电缆编号" tab "柜名1" tab "柜名2" tab "原理号" tab "图纸" tab "时间" tab "旧编号") f)
  (foreach r recs
    (write-line (strcat (nth 0 r) tab (nth 1 r) tab (nth 2 r) tab (nth 3 r) tab
                        (if (nth 4 r) (nth 4 r) "") tab (if (nth 5 r) (nth 5 r) "") tab
                        (if (nth 6 r) (nth 6 r) "")) f))
  T
)

(defun bh:write-records (path recs / f res)
  (if (setq f (aa:link-open path "w"))
    (progn
      (setq res (vl-catch-all-apply 'bh:write-lines (list f recs)))
      (close f)
      (not (vl-catch-all-error-p res)))
  )
)

(defun bh:write-failed (path)
  (alert (strcat "无法写入电缆编号记录文件:\r\n" path
                 "\r\n\r\n可能被 Excel/WPS/记事本占用或没有写权限。\r\n本次未修改图纸。"))
)

(defun bh:text-index (ss / i en ed ip out)
  ;; 选择集中的单行/多行文字（不含 BH_MARK 原因文字）：((x y 图元) ...)，按 Y 从大到小
  (setq i 0)
  (repeat (sslength ss)
    (setq en (ssname ss i) ed (entget en) i (1+ i))
    (if (and (member (cdr (assoc 0 ed)) '("TEXT" "MTEXT"))
             (/= (strcase (cdr (assoc 8 ed))) "BH_MARK")
             (setq ip (cdr (assoc 10 ed))))
      (setq out (cons (list (car ip) (cadr ip) en) out))))
  (aa:merge-sort out '(lambda (a b) (> (cadr a) (cadr b))))
)

(defun bh:in-band-p (x y hinfo)
  ;; 电缆线上方 0.1~3、线段范围内（与原窗口查询的判定相同）
  (and (<= (- (car hinfo) 0.1) x (+ (cadr hinfo) 2.0))
       (< (caddr hinfo) y (+ (caddr hinfo) 3.0)))
)

(defun bh:line-texts-window (hinfo / en ed ip out)
  ;; 选择集里文字不全时的补查：这根线上方的文字带在屏幕内用快速查询，不在屏幕内用全图查询（bh:query）
  (foreach en (bh:query '((0 . "TEXT,MTEXT") (8 . "~BH_MARK"))
                        (list (list (- (car hinfo) 0.1) (caddr hinfo) (+ (cadr hinfo) 2.0) (+ (caddr hinfo) 3.0)))
                        '(10))
    (setq ed (entget en) ip (cdr (assoc 10 ed)))
    (if (and ip (bh:in-band-p (car ip) (cadr ip) hinfo))
      (setq out (cons (list (car ip) en) out))))
  out
)

(defun bh:texts-complete-p (texts / t1 dest ok)
  ;; 文字里既有“至…”，又有它左边 40 以内的编号文字（与 bh:analyze 的取法相同）
  (foreach t1 texts
    (if (and (null dest) (bh:dest-p (caddr t1))) (setq dest t1)))
  (if dest
    (foreach t1 texts
      (if (and (< (car t1) (car dest)) (<= (- (car dest) (car t1)) 40.0)) (setq ok T))))
  ok
)

(defun bh:line-texts (hinfo / ry scan rec out t1)
  ;; 电缆线上方 0.1~3、线段范围内的文字，按 X 从左到右：((x 图元 纯文本) ...)
  ;; 先查选择集索引 *bh-tail*（bh:prepare 的局部变量，按 Y 从大到小）：电缆线按从上到下的顺序调用，
  ;; 已经高于本线上方 3 的文字以后也用不到，直接从 *bh-tail* 去掉，整趟只扫一遍。
  (setq ry (caddr hinfo))
  (while (and *bh-tail* (>= (cadr (car *bh-tail*)) (+ ry 3.0)))
    (setq *bh-tail* (cdr *bh-tail*)))
  (setq scan *bh-tail*)
  (while (and scan (> (cadr (setq rec (car scan))) ry))
    (if (bh:in-band-p (car rec) (cadr rec) hinfo)
      (setq out (cons (list (car rec) (caddr rec)) out)))
    (setq scan (cdr scan)))
  ;; 先按 X 排序，与 bh:analyze 取最左边的“至…”一致
  (setq out (aa:merge-sort (mapcar '(lambda (t1) (list (car t1) (cadr t1) (aa:ysdl-get-plain-text (entget (cadr t1))))) out)
                           '(lambda (a b) (< (car a) (car b)))))
  ;; 选择集里没能同时找到“至…”和它左边的编号（只点选了部分对象）时，到图上补查一次
  (if (not (bh:texts-complete-p out))
    (setq out (aa:merge-sort (mapcar '(lambda (t1) (list (car t1) (cadr t1) (aa:ysdl-get-plain-text (entget (cadr t1)))))
                                     (bh:line-texts-window hinfo))
                             '(lambda (a b) (< (car a) (car b))))))
  out
)

(defun bh:analyze (ed hinfo start texts vlineDataList textMetaList / dest num t1 res prins miss dname v d lead)
  ;; 成功返回 (OK hinfo 编号图元 编号文字 终点柜名 原理号列表 键 全是信号线 “至…”图元 引线长度)
  ;; 引线长度 = 芯线远端到电缆线的最短竖向距离，离端子排越近越短（相邻屏柜分前后柜用）
  ;; 失败返回 (ERR 原因 编号图元或nil hinfo)；没有“至…”的绿色直线不是电缆，返回 (SKIP 原因 nil hinfo)
  ;; texts 为电缆线上方的文字 ((x 图元 纯文本) ...)：批量识别用 bh:line-texts，BH1 单根补查用 bh:x-texts
  (foreach t1 texts
    (if (and (null dest) (bh:dest-p (caddr t1))) (setq dest t1)))
  ;; ZDDL 把编号写在“至…”左侧约 21.5 处，取左侧最近的一个
  (if dest
    (foreach t1 texts
      (if (and (< (car t1) (car dest)) (<= (- (car dest) (car t1)) 40.0))
        (setq num t1))))
  (cond
    ((null dest) (list 'SKIP "未找到“至…”去向文字" nil hinfo))
    ((null num) (list 'ERR "未找到电缆编号文字" nil hinfo))
    ((member (hddl:cabinet (setq dname (bh:dest-name (caddr dest)))) '("" "未填写"))
     (list 'ERR "终点柜名未填写" (cadr num) hinfo))
    (T
     (setq res (jm:line-principles ed vlineDataList textMetaList)
           prins (car res)
           miss (cadr res))
     (cond
       ((> miss 0) (list 'ERR (strcat "有 " (itoa miss) " 根芯线未找到原理号") (cadr num) hinfo))
       ((null prins) (list 'ERR "未识别到原理号" (cadr num) hinfo))
       (T
        (foreach v (xy:get-vrecs-for-hline-ed ed vlineDataList)
          (setq d (abs (- (cadr (caddr v)) (caddr hinfo)))
                lead (if lead (min lead d) d)))
        (list 'OK hinfo (cadr num) (vl-string-trim " \t" (caddr num)) dname prins
              (bh:key start dname (bh:prins-str prins))
              (vl-every '(lambda (p) (eq (jm:classify p) 'SIG)) prins)
              (cadr dest) (if lead lead 0.0))))))
)

(defun bh:prepare (tag / ss lines start-en start-name vlineDataList textMetaList en ed hinfo items it nskip *bh-tail*)
  ;; BH2 / BHG 共用：检查已保存 → 框选 → 起点柜名 → 逐根识别（从上到下）
  ;; 成功返回 (起点柜名 items)；失败打印原因返回 nil
  (cond
    ((/= (getvar "DWGTITLED") 1)
     (princ (strcat "\r\n[" tag "] 请先保存图纸：电缆编号记录写在 dwg 所在文件夹，未保存的新图没有文件夹。"))
     nil)
    ((progn
       (princ (strcat "\r\n[" tag "] 请框选起点柜（含柜名大字）及绿色电缆线、芯线、原理号和电缆文字: "))
       (null (setq ss (ssget))))
     (princ (strcat "\r\n[" tag "] 未选择对象，命令结束。"))
     nil)
    ((null (setq lines (xyg:dedup-hlines (xy:ss->list (xy:filter-green-hlines ss)) 0.5)))
     (princ (strcat "\r\n[" tag "] 选区中未找到绿色水平直线，命令结束。"))
     nil)
    ((progn
       (if (null (setq start-en (xyg:find-prefix-text ss)))
         (progn
           (princ (strcat "\r\n[" tag "] 选区内没有柜名大字（字高 >=80）。"))
           (setq start-en (car (entsel (strcat "\r\n[" tag "] 请点选起点柜名文字: "))))
           (if (and start-en (not (member (cdr (assoc 0 (entget start-en))) '("TEXT" "MTEXT"))))
             (setq start-en nil))))
       (or (null start-en)
           (= (setq start-name (vl-string-trim " \t" (aa:ysdl-get-plain-text (entget start-en)))) "")))
     (princ (strcat "\r\n[" tag "] 未取得起点柜名，命令结束。"))
     nil)
    (T
     (princ (strcat "\r\n[" tag "] 起点柜：" start-name))
     ;; 同 JM：清掉 XY/XYG 竖线缓存，按本次选区重新识别
     (setq *xy-last-vrec-map* nil
           vlineDataList (xy:collect-vlines lines))
     (xy:build-vline-buckets vlineDataList)
     (setq textMetaList (xy:build-text-meta-list (xy:collect-texts lines vlineDataList))
           *bh-tail* (bh:text-index ss))
     (foreach en (xyg:sort-lines-desc lines)
       (setq ed (entget en) hinfo (xy:hline-info-ed ed))
       (setq items (cons (bh:analyze ed hinfo start-name (bh:line-texts hinfo) vlineDataList textMetaList) items)))
     (setq nskip 0)
     (foreach it items
       (if (eq (car it) 'SKIP) (setq nskip (1+ nskip))))
     (if (> nskip 0)
       (aa:rep-info (strcat "跳过没有“至…”去向文字的绿色直线 " (itoa nskip) " 根（不是电缆）。")))
     (list start-name (reverse items))))
)

(defun bh:special (endname sig / n)
  ;; 信号线到录波柜固定 130，到公用测控柜固定 131
  (setq n (hddl:cabinet endname))
  (cond
    ((not sig) nil)
    ((vl-string-search "录波" n) "130")
    ((vl-string-search "公用测控" n) "131"))
)

(defun bh:pad (n w / s)
  (setq s (itoa n))
  (while (< (strlen s) w) (setq s (strcat "0" s)))
  s
)

(defun bh:letter (i)
  ;; 0→A … 25→Z，之后 AA、AB…
  (if (< i 26)
    (chr (+ 65 i))
    (strcat (chr (+ 64 (/ i 26))) (chr (+ 65 (rem i 26)))))
)

(defun bh:tail-base (tl / i)
  ;; “104A” → “104”：开头连续数字
  (setq i 0)
  (while (and (< i (strlen tl)) (wcmatch (substr tl (1+ i) 1) "#")) (setq i (1+ i)))
  (substr tl 1 i)
)

(defun bh:ask-prefix (tag / s)
  (setq s "")
  (while (= s "")
    (setq s (vl-string-trim " \t-" (getstring (strcat "\r\n[" tag "] 请输入编号“-”前面的部分（如 1B、DS）"
                                                     (if *bh-last-prefix* (strcat " <" *bh-last-prefix* ">") "")
                                                     ": "))))
    (if (and (= s "") *bh-last-prefix*) (setq s *bh-last-prefix*)))
  (setq *bh-last-prefix* s)
)

(defun bh:ask-start (tag / d s)
  (setq d (if *bh-last-start* *bh-last-start* "101") s nil)
  (while (null s)
    (setq s (vl-string-trim " \t" (getstring (strcat "\r\n[" tag "] “-”后面从几开始编号 [101/131/132/其他数字] <" d ">: "))))
    (if (= s "") (setq s d))
    (if (or (wcmatch s "*[~0-9]*") (= (atoi s) 0))
      (progn (princ (strcat "\r\n[" tag "] 请输入数字，例如 101、131、132 或 01。")) (setq s nil))))
  (setq *bh-last-start* s)
)

(defun bh:ask-reserved-p (tag pfx b)
  ;; 顺序号排到专用号时由用户决定；返回 T 表示照常使用
  (initget "S U")
  (= "U" (getkword (strcat "\r\n[" tag "] 顺序编号排到了 " pfx "-" b "（"
                           (if (= b "130") "录波柜" "公用测控柜")
                           "专用号）。[跳过(S)/照常使用(U)] <跳过>: ")))
)

(defun bh:ensure-layer ()
  (if (not (tblsearch "LAYER" "BH_MARK"))
    (entmake '((0 . "LAYER") (100 . "AcDbSymbolTableRecord")
               (100 . "AcDbLayerTableRecord") (2 . "BH_MARK")
               (70 . 0) (62 . 1))))
  "BH_MARK"
)

(defun bh:clear-markers (hinfos / ss marks i en ip h rx ry rest m)
  ;; 删除这些电缆线右端旧的原因文字：BH_MARK 文字全图只取一次（通常很少），再按坐标逐线匹配
  (if (setq ss (ssget "_X" '((0 . "TEXT") (8 . "BH_MARK"))))
    (progn
      (setq i 0)
      (repeat (sslength ss)
        (setq en (ssname ss i) i (1+ i))
        (if (setq ip (cdr (assoc 10 (entget en))))
          (setq marks (cons (list (car ip) (cadr ip) en) marks))))
      (foreach h hinfos
        (setq rx (cadr h) ry (caddr h) rest nil)
        (foreach m marks
          (if (and (<= (+ rx 1.0) (car m) (+ rx 4.0)) (< ry (cadr m) (+ ry 3.0)))
            (entdel (caddr m))
            (setq rest (cons m rest))))
        (setq marks rest))))
)

(defun bh:make-marker (hinfo txt)
  (bh:ensure-layer)
  (entmakex (list '(0 . "TEXT") '(8 . "BH_MARK")
                  (list 10 (+ (cadr hinfo) 2.0) (+ (caddr hinfo) 0.5) 0.0)
                  '(40 . 3.0) (cons 1 txt) '(50 . 0.0) '(41 . 0.7) '(62 . 1)
                  (cons 7 (if (tblsearch "STYLE" "HZ") "HZ" (getvar "TEXTSTYLE")))))
)

(defun bh:finish (tag items oks conflicts errs bad-ss / it en r)
  ;; 改图收尾：清旧原因文字 → 一致的编号恢复白色 → 冲突标红写原因 → 无法识别的写原因；问题编号加入 bad-ss
  (bh:clear-markers (mapcar '(lambda (it) (if (eq (car it) 'OK) (cadr it) (cadddr it))) items))
  (foreach en oks
    (if (= (cdr (assoc 62 (entget en))) 1) (hddl:color en 7)))
  (foreach r conflicts
    (hddl:color (car r) 1)
    (ssadd (car r) bad-ss)
    (bh:make-marker (cadr r) (strcat "[编号冲突] " (caddr r)))
    (aa:rep-item "err" "编号冲突" (car r) (strcat (aa:ysdl-get-plain-text (entget (car r))) "：" (caddr r))))
  (foreach r errs
    (if (caddr r) (ssadd (caddr r) bad-ss))
    (bh:make-marker (cadddr r) (strcat "[无法编号] " (cadr r)))
    (aa:rep-item "err" "无法编号" (caddr r) (cadr r)))
  (redraw)
)

(defun bh:neighbor-p (name)
  (= (hddl:cabinet name) (hddl:cabinet "相邻屏柜"))
)

(defun bh:num-parts (num / s p b tl)
  ;; “SML-22” → ("SML" 22 "22")；没有“-”或“-”后不以数字开头（如“***”）返回 nil
  (setq s (bh:clean num))
  (if (and (setq p (vl-string-position (ascii "-") s nil T))
           (/= (setq b (bh:tail-base (setq tl (substr s (+ p 2))))) ""))
    (list (substr s 1 p) (atoi b) tl))
)

(defun bh:num-first (a b / pa pb)
  ;; “-”前相同的两个编号按顺序号比先后：a 在前返回 A，b 在前返回 B；前缀不同或无法比较返回 nil
  (setq pa (bh:num-parts a) pb (bh:num-parts b))
  (cond
    ((or (null pa) (null pb) (/= (car pa) (car pb))) nil)
    ((< (cadr pa) (cadr pb)) 'A)
    ((> (cadr pa) (cadr pb)) 'B)
    ((< (caddr pa) (caddr pb)) 'A)
    ((> (caddr pa) (caddr pb)) 'B))
)

(defun bh:neighbor-order (r1 r2 s / o)
  ;; 本柜的两条相邻屏柜电缆记录分前后，返回 (前一个柜记录 后一个柜记录)，分不出返回 nil。
  ;; 环网电缆沿链连续编号，先比编号顺序号（小的在前）；记录两端是各自起点柜 BH1/BH2 记的，方向不可靠，
  ;; 编号无法比较（如“***”）时才看方向：本柜作柜名2 的是前一个柜。
  (setq o (bh:num-first (car r1) (car r2)))
  (cond
    ((eq o 'A) (list r1 r2))
    ((eq o 'B) (list r2 r1))
    ((and (= (hddl:cabinet (nth 2 r1)) s) (= (hddl:cabinet (nth 1 r2)) s)) (list r1 r2))
    ((and (= (hddl:cabinet (nth 1 r1)) s) (= (hddl:cabinet (nth 2 r2)) s)) (list r2 r1)))
)

(defun bh:resolve-neighbors (items start recs / s groups it g gk r c c1 c2 k ks cands ord sorted pairs other out dests bad msg)
  ;; 终点写“相邻屏柜”的环网电缆（LNZ/LNY 画的）按记录定出实际相邻柜：
  ;;   同一原理号为一组，在记录里找本柜一端、原理号相同的电缆（不分记录方向）。
  ;;   一组两根时，记录也应正好两根：按 bh:neighbor-order 分前后，离端子排近（引线短）的配前一个柜，远的配后一个柜。
  ;;   一组只有一根时，记录里只有一根才能确定。
  ;; 返回 (新 items 改去向列表 ((“至…”图元 新文字) ...) 无法确定列表 ((编号图元 原因) ...))
  ;; 无法确定的电缆在新 items 里换成 (NB 原因 编号图元 hinfo)
  (setq s (hddl:cabinet start))
  (foreach it items
    (if (and (eq (car it) 'OK) (bh:neighbor-p (nth 4 it)))
      (progn
        (setq gk (bh:prins-str (nth 5 it)))
        (if (setq g (assoc gk groups))
          (setq groups (subst (append g (list it)) g groups))
          (setq groups (append groups (list (list gk it))))))))
  (foreach g groups
    (setq gk (car g) cands nil ks nil)
    (foreach r recs
      (setq c1 (hddl:cabinet (nth 1 r)) c2 (hddl:cabinet (nth 2 r)))
      (if (and (= (bh:prins-str (bh:split (nth 3 r) " ")) gk)
               (/= c1 c2) (or (= c1 s) (= c2 s))
               (not (bh:neighbor-p (nth 1 r))) (not (bh:neighbor-p (nth 2 r)))
               (not (member (setq k (bh:key (nth 1 r) (nth 2 r) gk)) ks)))
        (setq ks (cons k ks) cands (cons r cands))))
    (setq cands (reverse cands)
          sorted (aa:merge-sort (cdr g) '(lambda (a b) (< (nth 9 a) (nth 9 b))))
          msg (cond
                ((null cands) "记录里没有本柜的相邻屏柜电缆")
                (T (strcat "记录里本柜的相邻屏柜电缆有 " (itoa (length cands)) " 根"))))
    (setq pairs
      (cond
        ((cddr sorted) (mapcar '(lambda (it) (list it nil "同一原理号的相邻屏柜电缆超过两根")) sorted))
        ((cdr sorted)
         (cond
           ((/= (length cands) 2)
            (mapcar '(lambda (it) (list it nil (if cands (strcat msg "，应为 2 根，无法确定") msg))) sorted))
           ((setq ord (bh:neighbor-order (car cands) (cadr cands) s))
            (list (list (car sorted) (car ord)) (list (cadr sorted) (cadr ord))))
           (T (mapcar '(lambda (it) (list it nil "记录里两根相邻屏柜电缆分不出前后（编号不是同一前缀的顺序号，记录方向也相同）"))
                      sorted))))
        ((null cands) (list (list (car sorted) nil msg)))
        ((cdr cands) (list (list (car sorted) nil (strcat msg "，只有一根无法确定是哪一个"))))
        (T (list (list (car sorted) (car cands))))))
    (foreach c pairs
      (setq it (car c) r (cadr c))
      (cond
        (r
         (setq other (if (= (hddl:cabinet (nth 1 r)) s) (nth 2 r) (nth 1 r)))
         (setq out (cons (cons it (list 'OK (nth 1 it) (nth 2 it) (nth 3 it) other (nth 5 it)
                                         (bh:key start other gk) (nth 7 it) (nth 8 it) (nth 9 it)))
                         out)
               dests (cons (list (nth 8 it) (strcat "至" other)) dests)))
        (T
         ;; 无法确定的改成 (NB 原因 编号图元 hinfo)：只提示，不参与后面的重复检查和统计
         (setq msg (caddr c)
               out (cons (cons it (list 'NB msg (nth 2 it) (nth 1 it))) out)
               bad (cons (list (nth 2 it) msg) bad))))))
  (list (mapcar '(lambda (it) (if (assoc it out) (cdr (assoc it out)) it)) items)
        (reverse dests) (reverse bad))
)

(defun bh:used-msg (hit)
  (strcat "编号已被另一根电缆使用（" (caddr hit) "—" (cadddr hit) "）")
)

(defun bh:renamed-p (oldk newk / o n)
  ;; 编号相同的两条记录是否是同一根电缆、图上只改了一样：
  ;;   原理号相同，两端柜名至少有一个相同（起点柜或终点柜改了名）；
  ;;   或两端柜名都相同，只改了原理号。键里两端柜名已排序，柜名相同即 car、cadr 分别相等。
  (setq o (bh:split oldk (chr 1)) n (bh:split newk (chr 1)))
  (if (= (caddr o) (caddr n))
    (or (member (car o) (list (car n) (cadr n)))
        (member (cadr o) (list (car n) (cadr n))))
    (and (= (car o) (car n)) (= (cadr o) (cadr n))))
)

(defun bh:prin-base (p / s b)
  ;; 疑似比较用：去掉数字后面的 I/II 后缀（A610I、A610Ⅱ → A610）
  (setq s (aa:str-replace-all "Ⅱ" "II" (aa:str-replace-all "Ⅰ" "I" (jm:norm p))) b s)
  (while (and (> (strlen b) 1) (= (substr b (strlen b)) "I"))
    (setq b (substr b 1 (1- (strlen b)))))
  (if (wcmatch b "*#") b s)
)

(defun bh:prins-minus (a b / out p)
  ;; a 里有、b 里没有的原理号（都已去空格转大写）
  (foreach p a
    (if (not (member p b)) (setq out (cons p out))))
  (reverse out)
)

(defun bh:similar (start dest prins recs / s d pb mine r c1 c2 rp hits nums txt)
  ;; “未编号”且没有完全相同的记录时找疑似记录：两端柜名相同（不分先后），原理号去掉 I/II 后缀后相同。
  ;; 只提示，不填写（I/II 常用来区分两根不同的电缆）。返回 (疑似编号 原因)，没有返回 nil
  (setq s (hddl:cabinet start) d (hddl:cabinet dest)
        mine (bh:split (bh:prins-str prins) " ")
        pb (bh:prins-str (mapcar 'bh:prin-base mine)))
  (foreach r recs
    (setq c1 (hddl:cabinet (nth 1 r)) c2 (hddl:cabinet (nth 2 r)))
    (if (and (or (and (= c1 s) (= c2 d)) (and (= c1 d) (= c2 s)))
             (not (bh:placeholder-p (bh:clean (car r))))
             (not (member (car r) nums))
             (setq rp (bh:split (bh:prins-str (bh:split (nth 3 r) " ")) " "))
             (= (bh:prins-str (mapcar 'bh:prin-base rp)) pb))
      (setq nums (cons (car r) nums) hits (cons (list (car r) rp (nth 4 r)) hits))))
  (if (setq hits (reverse hits))
    (progn
      (setq txt "")
      (foreach r hits
        (setq txt (strcat txt (if (= txt "") "" "；")
                          (if (cdr hits) (strcat (car r) " ") "")
                          "图上 " (jm:join (bh:prins-minus mine (cadr r)))
                          "，记录 " (jm:join (bh:prins-minus (cadr r) mine))
                          (if (and (caddr r) (/= (caddr r) "")) (strcat "（" (caddr r) "）") ""))))
      (list (jm:join (reverse nums))
            (strcat (if (cdr hits)
                      (strcat "原理号不一致且有 " (itoa (length hits)) " 根疑似，无法填入：")
                      "原理号不一致，无法填入：")
                    txt "；统一两张图的原理号后再运行 BH2"))))
)

;;; ---- 合画柜：两张图合画成一张时，柜名写成“35kV 1(2)#SVG控制柜”，编号写成“DS-24(25)”

(defun bh:all-digits-p (s)
  (and s (/= s "") (not (wcmatch s "*[~0-9]*")))
)

(defun bh:num-suffix (s / i)
  ;; 最后一个数字后面的部分：“640I” → “I”，“25” → “”
  (setq i (strlen s))
  (while (and (> i 0) (not (wcmatch (substr s i 1) "#"))) (setq i (1- i)))
  (substr s (1+ i))
)

(defun bh:combo-alts (s / p j q dg sf toks out)
  ;; 数字后面括号里写另一张图的数字（全角括号也认，括号里多个用 , ， 、 / 分隔），拆成各张图的写法，第一个是括号前的数字：
  ;;   “35kV 1(2)#SVG控制柜” → (“35kV 1#SVG控制柜” “35kV 2#SVG控制柜”)；“DS-24(25)” → (“DS-24” “DS-25”)。
  ;; 数字带相同字母尾缀的连尾缀一起换：“A630I(640I)” → (“A630I” “A640I”)。
  ;; 没有这种写法返回 nil；只认第一处
  (setq s (aa:str-replace-all "）" ")" (aa:str-replace-all "（" "(" (if s s ""))))
  (while (and (null out) (setq p (vl-string-search "(" s (if p (1+ p) 0))))
    ;; p 为“(”的 0 起位置；括号里每项都是“数字+同一字母尾缀 sf”，括号前也要以 sf 结尾，j 再往前跳过连续数字
    (if (and (setq q (vl-string-search ")" s p))
             (setq toks (bh:split (aa:str-replace-all "/" "," (aa:str-replace-all "、" "," (aa:str-replace-all "，" ","
                                    (substr s (+ p 2) (- q p 1)))))
                                  ","))
             (setq sf (bh:num-suffix (car toks)))
             (not (wcmatch sf "*[~A-Za-z]*"))
             (vl-every '(lambda (x) (and (> (strlen x) (strlen sf)) (= (bh:num-suffix x) sf)
                                         (bh:all-digits-p (substr x 1 (- (strlen x) (strlen sf))))))
                       toks)
             (>= p (strlen sf))
             (= (substr s (- (1+ p) (strlen sf)) (strlen sf)) sf)
             (progn
               (setq j (- p (strlen sf)))
               (while (and (> j 0) (wcmatch (substr s j 1) "#")) (setq j (1- j)))
               (< j (- p (strlen sf)))))
      (setq dg (substr s (1+ j) (- p j))
            out (mapcar '(lambda (d) (strcat (substr s 1 j) d (substr s (+ q 2)))) (cons dg toks)))))
  out
)

(defun bh:runs (s / i c d dk cur out)
  ;; 按数字 / 非数字切段：“DS-24A” → (“DS-” “24” “A”)
  (setq i 1 cur "")
  (while (<= i (strlen s))
    (setq c (substr s i 1) d (wcmatch c "#"))
    (if (and (/= cur "") (not (eq d dk))) (setq out (cons cur out) cur ""))
    (setq cur (strcat cur c) dk d i (1+ i)))
  (if (/= cur "") (setq out (cons cur out)))
  (reverse out)
)

(defun bh:combo-join (nums / rs n i d r out)
  ;; 各张图的编号合成一个：全相同写一个；只差一段数字时写成“DS-24(25)”“1(2)UBY-105”；合不成返回 nil
  (if (vl-every '(lambda (x) (= (bh:clean x) (bh:clean (car nums)))) nums)
    (car nums)
    (progn
      (setq rs (mapcar 'bh:runs nums) n (length (car rs)) i 0)
      (if (vl-every '(lambda (r) (= (length r) n)) rs)
        (while (< i n)
          (if (not (vl-every '(lambda (r) (= (nth i r) (nth i (car rs)))) rs))
            (setq d (cons i d)))
          (setq i (1+ i))))
      (if (and d (null (cdr d)) (vl-every '(lambda (r) (bh:all-digits-p (nth (car d) r))) rs))
        (progn
          (setq out "" i 0)
          (foreach r (car rs)
            (setq out (strcat out r
                              (if (= i (car d))
                                (strcat "(" (aa:str-replace-all " " "," (jm:join (mapcar '(lambda (x) (nth i x)) (cdr rs)))) ")")
                                ""))
                  i (1+ i)))
          ;; 合成的写法必须能原样拆回这几个编号
          (if (equal (mapcar 'bh:clean (bh:combo-alts out)) (mapcar 'bh:clean nums)) out)))))
)

(defun bh:combo-variants (start dest prins / ss ds ps a n bad i out)
  ;; 合画柜电缆拆成各张图的 (起点 终点 原理号列表)；起点、终点、原理号里合并写法的个数必须一致。不是合画柜返回 nil
  (setq ss (bh:combo-alts start) ds (bh:combo-alts dest) ps (mapcar 'bh:combo-alts prins))
  (foreach a (append (list ss ds) ps)
    (if a
      (if (null n) (setq n (length a)) (if (/= n (length a)) (setq bad T)))))
  (if (and n (not bad))
    (progn
      (setq i 0)
      (repeat n
        (setq out (cons (list (if ss (nth i ss) start) (if ds (nth i ds) dest)
                              (mapcar '(lambda (p a) (if a (nth i a) p)) prins ps))
                        out)
              i (1+ i)))
      (reverse out)))
)

(defun bh:combo-key (v)
  (bh:key (car v) (cadr v) (bh:prins-str (caddr v)))
)

(defun bh:combo-label (v)
  (strcat (car v) "—" (cadr v))
)

(defun bh:combo-lookup (start it kmap / cv hits txt)
  ;; “未编号”的合画柜电缆：拆成各张图分别查记录。全都有 → (T 合成编号)；只有部分有或编号合不成 → (nil 原因)；
  ;; 不是合画柜或一张都没有记录 → nil（按普通“未编号且没有记录”处理）
  (if (setq cv (bh:combo-variants start (nth 4 it) (nth 5 it)))
    (progn
      (setq hits (mapcar '(lambda (v) (assoc (bh:combo-key v) kmap)) cv))
      (cond
        ((not (vl-some 'car hits)) nil)
        ((vl-every 'car hits)
         (if (setq txt (bh:combo-join (mapcar 'cadr hits)))
           (list T txt)
           (list nil (strcat "合画柜各张图的记录编号 " (jm:join (mapcar 'cadr hits))
                             " 合不成“DS-24(25)”这种写法，请手工填写"))))
        (T
         (setq txt "")
         (mapcar '(lambda (v h)
                    (setq txt (strcat txt (if (= txt "") "" "；") (bh:combo-label v)
                                      (if h (strcat " 记录 " (cadr h)) " 没有记录"))))
                 cv hits)
         (list nil (strcat "合画柜只找到部分记录：" txt "；另一张图编号记录后再运行 BH2"))))))
)

(defun bh:combo-numbered (start it kmap nmap / cv nums acts bad olds adds new)
  ;; 已编号的合画柜电缆（编号也是合并写法如 DS-24(25)，个数与柜名一致）：拆开逐张和记录核对。
  ;; 返回 nil（不适用，按普通电缆处理）/ (OK) / (CONFLICT 原因) /
  ;;      (SET 要记入的 ((编号 起点 终点 原理号列表) ...) 旧编号改新后的合并编号或nil)
  (if (and (setq cv (bh:combo-variants start (nth 4 it) (nth 5 it)))
           (setq nums (bh:combo-alts (nth 3 it)))
           (= (length nums) (length cv)))
    (progn
      (setq acts (mapcar '(lambda (v n) (bh:numbered-action (bh:combo-key v) (bh:clean n) kmap nmap)) cv nums))
      (mapcar '(lambda (v n a)
                 (cond
                   ((eq (car a) 'CONFLICT)
                    (if (null bad) (setq bad (strcat (bh:combo-label v) " " n "：" (cadr a)))))
                   ((eq (car a) 'OLD) (setq olds T new (cons (cadr a) new)))
                   (T
                    (if (eq (car a) 'ADD) (setq adds (cons (list n (car v) (cadr v) (caddr v)) adds)))
                    (setq new (cons n new)))))
              cv nums acts)
      (cond
        (bad (list 'CONFLICT bad))
        ((and (not olds) (null adds)) '(OK))
        ((and olds (null (setq new (bh:combo-join (reverse new)))))
         (list 'CONFLICT "合画柜的旧编号要改成记录的新编号，但新编号合不成合并写法，请手工修改"))
        (T (list 'SET (reverse adds) (if olds new))))))
)

(defun bh:split-map (recs / r cv nums out)
  ;; 反方向：记录是在合画图那端记的（“1(2)ZYB-103 35kV 1(2)#站用变进线柜 … 1(2)ZYB-A421 …”），这一端分开画。
  ;; 把柜名、原理号、编号都能按同样个数拆开的记录拆成各张图：(各张的键 各张的编号 记录原编号) ...；同一键以前面的为准
  (foreach r recs
    (if (and (setq cv (bh:combo-variants (nth 1 r) (nth 2 r) (bh:split (nth 3 r) " ")))
             (setq nums (bh:combo-alts (car r)))
             (= (length nums) (length cv)))
      (mapcar '(lambda (v n / k)
                 (if (not (assoc (setq k (bh:combo-key v)) out))
                   (setq out (cons (list k n (car r)) out))))
              cv nums)))
  out
)

;;; 功能: 框选起点柜和绿色电缆线，把已编号但没记录的电缆记入共享记录，给有记录的“未编号”按记录填写；不分配新编号，两端不一致的标红注明原因。
(defun c:BH2 (/ *error* aa:tag aa:doc aa:undo-open aa:old-cmdecho
                prep path start-name items recs newrecs kmap nmap r k nc it hit seen
                fills nonum conflicts errs oks now dwg bad-ss nfill nold nrec nok rkeys t0 nb dests nbad sim sims
                cm a kk combos ncombo nadd smap nsplit)
  (aa:cmd-begin "BH2")
  (aa:rep-begin "BH2")
  (setq bad-ss (ssadd) t0 (aa:link-clock) nonum 0 ncombo 0 nadd 0 nsplit 0)
  (if (setq prep (bh:prepare "BH2"))
    (progn
     (setq start-name (car prep)
           items (cadr prep)
           path (bh:record-path)
           dwg (getvar "DWGNAME")
           now (bh:now)
           recs (bh:read-records path)
           rkeys (mapcar 'bh:rec-key recs)
           kmap (bh:kmap recs rkeys)
           nmap (bh:nmap recs rkeys)
           smap (bh:split-map recs)
           nb (bh:resolve-neighbors items start-name recs)
           items (car nb)
           dests (cadr nb)
           nbad (caddr nb))
     ;; 终点是“相邻屏柜”的环网电缆：已按记录定出实际相邻柜的，后面照常按记录填号
     ;; 已编号的核对或记入；“未编号”的有记录就填，没记录的不动（编号用 BH1）
     (foreach it items
       (if (not (eq (car it) 'OK))
         (if (eq (car it) 'ERR) (setq errs (cons it errs)))
         (progn
           (setq k (nth 6 it) nc (bh:clean (nth 3 it)))
           (cond
             ((member k seen)
              (setq conflicts (cons (list (nth 2 it) (cadr it) "本次选择中同一起终点、原理号的电缆重复") conflicts)))
             ((= nc (bh:clean "未编号"))
              (setq seen (cons k seen))
              (cond
                ((setq hit (assoc k kmap))
                 (setq fills (cons (list (nth 2 it) (cadr hit)) fills)))
                ;; 合画柜（柜名写成“1(2)#”）：按拆开后各张图的记录合成编号，如 DS-24、DS-25 → DS-24(25)
                ((setq cm (bh:combo-lookup start-name it kmap))
                 (if (car cm)
                   (setq fills (cons (list (nth 2 it) (cadr cm)) fills) ncombo (1+ ncombo))
                   (setq combos (cons (list (nth 2 it) (cadr it) (cadr cm)) combos))))
                ;; 反方向：记录是合画图那端记的，拆开后对上这一根，填拆开的编号（1(2)ZYB-103 → 1ZYB-103）
                ((setq hit (assoc k smap))
                 (setq fills (cons (list (nth 2 it) (cadr hit)) fills) nsplit (1+ nsplit)))
                (T
                 (setq nonum (1+ nonum))
                 ;; 原理号只差 I/II 后缀的疑似记录：写出疑似编号和原因，不填
                 (if (setq sim (bh:similar start-name (nth 4 it) (nth 5 it) recs))
                   (setq sims (cons (list (nth 2 it) (cadr it) (car sim) (cadr sim)) sims))))))
             (T
              (setq seen (cons k seen))
              (cond
                ((setq hit (assoc k kmap))
                 (cond
                   ((= (bh:clean (cadr hit)) nc)
                    (setq oks (cons (nth 2 it) oks)))
                   ;; 另一端用 BHG 改过编号：图上还是旧编号的直接改成新编号
                   ((member nc (mapcar 'bh:clean (caddr hit)))
                    (setq fills (cons (list (nth 2 it) (cadr hit) T) fills)))
                   (T
                    (setq conflicts (cons (list (nth 2 it) (cadr it)
                                                (strcat "与另一端记录编号 " (cadr hit) " 不一致"))
                                          conflicts)))))
                ;; 合画柜且编号也是合并写法（DS-24(25)）：拆开逐张核对，没记录的分别记入
                ((setq cm (bh:combo-numbered start-name it kmap nmap))
                 (cond
                   ((eq (car cm) 'OK) (setq oks (cons (nth 2 it) oks)))
                   ((eq (car cm) 'CONFLICT)
                    (setq conflicts (cons (list (nth 2 it) (cadr it) (cadr cm)) conflicts)))
                   (T
                    (foreach a (cadr cm)
                      (setq r (list (car a) (cadr a) (caddr a) (bh:prins-str (cadddr a)) dwg now)
                            kk (bh:key (cadr a) (caddr a) (nth 3 r))
                            newrecs (cons r newrecs)
                            kmap (cons (list kk (car a) nil) kmap)
                            nmap (cons (list (bh:clean (car a)) kk (cadr a) (caddr a)) nmap)))
                    (if (caddr cm)
                      (setq fills (cons (list (nth 2 it) (caddr cm) T) fills))
                      (setq oks (cons (nth 2 it) oks) nadd (1+ nadd))))))
                ;; 反方向：和合画图记录拆开后的编号核对，一致不另记
                ((setq hit (assoc k smap))
                 (if (= (bh:clean (cadr hit)) nc)
                   (setq oks (cons (nth 2 it) oks))
                   (setq conflicts (cons (list (nth 2 it) (cadr it)
                                               (strcat "与合画图记录 " (caddr hit) " 拆开后的编号 " (cadr hit) " 不一致"))
                                         conflicts))))
                ((setq hit (assoc nc nmap))
                 (setq conflicts (cons (list (nth 2 it) (cadr it) (bh:used-msg hit)) conflicts)))
                (T
                 (setq r (list (nth 3 it) start-name (nth 4 it) (bh:prins-str (nth 5 it)) dwg now)
                       newrecs (cons r newrecs)
                       kmap (cons (list k (nth 3 it) nil) kmap)
                       nmap (cons (list nc k start-name (nth 4 it)) nmap)
                       oks (cons (nth 2 it) oks)
                       nadd (1+ nadd)))))))))
     (setq fills (reverse fills) newrecs (reverse newrecs))
     ;; 先写记录文件，写不进去就不改图
     (if (and newrecs (not (bh:write-records path (append recs newrecs))))
       (bh:write-failed path)
       (progn
         (setq nfill 0 nold 0)
         (foreach r fills
           (jm:set-text (car r) (cadr r))
           (if (= (cdr (assoc 62 (entget (car r)))) 1) (hddl:color (car r) 7))
           (if (caddr r) (setq nold (1+ nold)) (setq nfill (1+ nfill))))
         (bh:finish "BH2" items oks conflicts errs bad-ss)
         (foreach r (reverse sims)
           (ssadd (car r) bad-ss)
           (bh:make-marker (cadr r) (strcat "[疑似 " (caddr r) "] " (cadddr r)))
           (aa:rep-item "warn" "疑似记录" (car r) (strcat "疑似 " (caddr r) "：" (cadddr r))))
         ;; 合画柜只找到部分记录、或编号合不成合并写法：不填，选中并写原因
         (foreach r (reverse combos)
           (ssadd (car r) bad-ss)
           (bh:make-marker (cadr r) (strcat "[合画柜] " (caddr r)))
           (aa:rep-item "warn" "合画柜" (car r) (caddr r)))
         (if (> nsplit 0)
           (aa:rep-info (strcat "合画图那端记的记录（如 1(2)ZYB-103）：拆开后填入 "
                                (itoa nsplit) " 根，已计入“按记录填入”。")))
         (if (> ncombo 0)
           (aa:rep-info (strcat "合画柜（柜名写成 1(2)# 的两张图合画）：按各张图的记录合成编号填入 "
                                (itoa ncombo) " 根，已计入“按记录填入”。")))
         ;; “至相邻屏柜”改成实际柜名；无法确定相邻柜的选中并说明原因
         (foreach r dests (jm:set-text (car r) (cadr r)))
         (foreach r nbad
           ;; 上次误判留下的红色恢复白色（旧原因文字已由 bh:finish 清掉）
           (if (= (cdr (assoc 62 (entget (car r)))) 1) (hddl:color (car r) 7))
           (ssadd (car r) bad-ss)
           (aa:rep-item "warn" "相邻屏柜" (car r) (strcat (aa:ysdl-get-plain-text (entget (car r))) "：无法确定实际柜，" (cadr r))))
         (if (or dests nbad)
           (aa:rep-info (strcat "相邻屏柜：按记录改为实际柜名 " (itoa (length dests)) " 根；无法确定 "
                                (itoa (length nbad)) " 根（已选中）。")))
         (setq nrec nadd nok (- (length oks) nrec))
         (aa:rep-info (strcat "用时 " (rtos (- (aa:link-clock) t0) 2 1) " 秒。"))
         (aa:rep-info (strcat "记录文件：" path " （共 " (itoa (+ (length recs) (length newrecs))) " 条）"))
         (if conflicts
           (aa:rep-info "提示：如果是图上改过编号、终点柜名或原理号，确认图面正确后运行 BHG 以图为准更新记录。"))
         (aa:rep-end
           (strcat "完成：" (aa:rep-counts (list (cons "填入" nfill) (cons "新记入" nrec) (cons "旧号改新" nold) (cons "一致" nok)
                                                (cons "未编号无记录" nonum) (cons "疑似" (length sims))
                                                (cons "合画柜无法填入" (length combos)) (cons "冲突" (length conflicts))
                                                (cons "无法识别" (length errs)) (cons "相邻柜改名" (length dests))
                                                (cons "相邻柜无法确定" (length nbad)))))
           (strcat "完成：已编号新记入 " (itoa nrec) " 根；按记录填入 " (itoa nfill)
                   " 根；旧编号改为新编号 " (itoa nold) " 根；已编号且与记录一致 " (itoa nok)
                   " 根；未编号且没有记录 " (itoa nonum) " 根（未处理，需要编号请用 BH1"
                   (if sims (strcat "；其中 " (itoa (length sims)) " 根有疑似记录，已选中并写了原因") "")
                   "）；"
                   (if combos (strcat "合画柜无法填入 " (itoa (length combos)) " 根（已选中并写了原因）；") "")
                   "编号冲突 "
                   (itoa (length conflicts)) " 根；无法识别 " (itoa (length errs))
                   " 根（冲突和无法识别的已选中，并在电缆线右端写了原因）。"))))))
  (aa:cmd-end)
  (if (> (sslength bad-ss) 0)
    (sssetfirst nil bad-ss)
    (sssetfirst nil nil))
  (princ)
)

;;; 功能: 以图为准修改电缆编号记录：框选起点柜和电缆，把记录编号改成图上的编号（原编号存为旧编号，另一端 BH1/BH2 自动跟改），“未编号”的删除其记录。
(defun c:BHG (/ *error* aa:tag aa:doc aa:undo-open aa:old-cmdecho
                 prep path start-name items recs kmap nmap r k nc it hit seen upd del
                 conflicts errs oks keep oldmap olds o dwg now bad-ss nadd nchg ren k2 rkeys ks t0 selkeys used borrows b chg nnum)
  (aa:cmd-begin "BHG")
  (aa:rep-begin "BHG")
  (setq bad-ss (ssadd) t0 (aa:link-clock))
  (if (setq prep (bh:prepare "BHG"))
    (progn
     (setq start-name (car prep)
           items (cadr prep)
           path (bh:record-path)
           dwg (getvar "DWGNAME")
           now (bh:now)
           recs (bh:read-records path)
           rkeys (mapcar 'bh:rec-key recs)
           kmap (bh:kmap recs rkeys)
           nmap (bh:nmap recs rkeys)
           nadd 0 nchg 0 nnum 0)
     ;; 本次选中的电缆键：编号的原主人也在本次选择里时，它的记录会按图一起改掉，编号可以让出（两根互换、挪用编号）
     (foreach it items
       (if (eq (car it) 'OK) (setq selkeys (cons (nth 6 it) selkeys))))
     ;; 1. 逐根决定：改记录 / 删记录 / 已一致 / 冲突
     (foreach it items
       (if (not (eq (car it) 'OK))
         (if (eq (car it) 'ERR) (setq errs (cons it errs)))
         (progn
           (setq k (nth 6 it) nc (bh:clean (nth 3 it)) hit (assoc k kmap))
           (cond
             ;; “未编号”没有编号可核对，不参与重复检查：有记录就删掉，图上不动（上次误标的红色恢复白色）
             ((= nc (bh:clean "未编号"))
              (setq nnum (1+ nnum))
              (if (and hit (not (member k del))) (setq del (cons k del)))
              (if (= (cdr (assoc 62 (entget (nth 2 it)))) 1) (hddl:color (nth 2 it) 7)))
             ((member k seen)
              (setq conflicts (cons (list (nth 2 it) (cadr it) "本次选择中同一起终点、原理号的电缆重复") conflicts)))
             ((member nc used)
              (setq seen (cons k seen)
                    conflicts (cons (list (nth 2 it) (cadr it) "本次选择中编号重复") conflicts)))
             ((and (setq r (assoc nc nmap)) (/= (cadr r) k)
                   (not (bh:renamed-p (cadr r) k))
                   (not (member (cadr r) selkeys)))
              (setq seen (cons k seen)
                    conflicts (cons (list (nth 2 it) (cadr it) (bh:used-msg r)) conflicts)))
             ((and hit (= (bh:clean (cadr hit)) nc))
              (setq seen (cons k seen) oks (cons (nth 2 it) oks)
                    used (if (bh:placeholder-p nc) used (cons nc used))))
             (T
              (cond
                ;; 编号原属的电缆也在本次选择里：记下来，最后核对它确实改用了别的编号或改成“未编号”
                ((and r (/= (cadr r) k) (member (cadr r) selkeys))
                 (setq borrows (cons (list k (cadr r) (nth 2 it) (cadr it) (if hit 'CHG 'ADD) (bh:used-msg r)) borrows))
                 (if hit (setq nchg (1+ nchg)) (setq nadd (1+ nadd))))
                ;; 编号所属记录是同一根电缆，只是图上改了某一端柜名或原理号：把那条记录换成图上的内容
                ((and r (/= (cadr r) k))
                 (setq ren (cons (cons (cadr r) k) ren)))
                (hit (setq nchg (1+ nchg)))
                (T (setq nadd (1+ nadd))))
              (setq seen (cons k seen)
                    used (if (bh:placeholder-p nc) used (cons nc used))
                    upd (cons (list k (list (nth 3 it) start-name (nth 4 it) (bh:prins-str (nth 5 it)) dwg now)) upd)
                    nmap (cons (list nc k start-name (nth 4 it)) nmap)
                    oks (cons (nth 2 it) oks)))))))
     ;; 借用的编号：原属电缆没有改号（仍是这个编号、冲突或无法识别）就撤回，按冲突处理；撤回可能连锁，循环到不再变化
     (setq chg T)
     (while chg
       (setq chg nil)
       (foreach b borrows
         (if (and (assoc (car b) upd) (not (assoc (cadr b) upd)) (not (member (cadr b) del)))
           (setq upd (vl-remove (assoc (car b) upd) upd)
                 oks (vl-remove (nth 2 b) oks)
                 nchg (if (eq (nth 4 b) 'CHG) (1- nchg) nchg)
                 nadd (if (eq (nth 4 b) 'ADD) (1- nadd) nadd)
                 conflicts (cons (list (nth 2 b) (nth 3 b) (strcat (nth 5 b) "，那根电缆本次没有改用别的编号")) conflicts)
                 chg T))))
     ;; 2. 生成新记录表：删掉的不要；改掉的收集原编号和旧编号，统一追加到末尾
     (if (or upd del)
       (setq keep (bh:rebuild recs rkeys upd del ren)))
     ;; 3. 先写记录文件，写不进去就不改图
     (if (and (or upd del) (not (bh:write-records path keep)))
       (bh:write-failed path)
       (progn
         (bh:finish "BHG" items oks conflicts errs bad-ss)
         (if (> nchg 0)
           (aa:rep-info "原编号已存为旧编号：到电缆另一端运行 BH1 或 BH2，图上的旧编号会自动改成新编号。"))
         (aa:rep-info (strcat "用时 " (rtos (- (aa:link-clock) t0) 2 1) " 秒。"))
         (aa:rep-info (strcat "记录文件：" path))
         (aa:rep-end
           (strcat "完成：" (aa:rep-counts (list (cons "改为图上编号" nchg) (cons "更正柜名/原理号" (length ren)) (cons "新记入" nadd)
                                                (cons "删除未编号记录" (length del)) (cons "一致" (- (length oks) nchg nadd (length ren)))
                                                (cons "冲突" (length conflicts)) (cons "无法识别" (length errs)))))
           (strcat "完成：记录改为图上编号 " (itoa nchg) " 根；按图更正柜名/原理号 " (itoa (length ren))
                   " 根；新记入 " (itoa nadd)
                   " 根；未编号 " (itoa nnum) " 根（不核对，其中有记录的已删除 " (itoa (length del)) " 根）；已与记录一致 "
                   (itoa (- (length oks) nchg nadd (length ren))) " 根；编号冲突 " (itoa (length conflicts))
                   " 根；无法识别 " (itoa (length errs)) " 根。"))))))
  (aa:cmd-end)
  (if (> (sslength bad-ss) 0)
    (sssetfirst nil bad-ss)
    (sssetfirst nil nil))
  (princ)
)

;;; ---------------------------------------------------------------------------------------
;;; BH1 单根补查：批量识别没认出的线，按视图内快速查询 / 全图查询（ssget "_X"）再识别一次

(defun bh:view-rect (/ c h sz)
  ;; 当前视图在 WCS 中的范围 (x1 y1 x2 y2 每像素图形单位)；UCS 不是世界坐标或视图有扭转时返回 nil（只走全图查询）
  (if (and (= (getvar "WORLDUCS") 1) (equal (getvar "VIEWTWIST") 0.0 1e-9)
           (setq c (getvar "VIEWCTR") h (getvar "VIEWSIZE") sz (getvar "SCREENSIZE"))
           (> (cadr sz) 0))
    (list (- (car c) (* 0.5 h (/ (float (car sz)) (cadr sz)))) (- (cadr c) (* 0.5 h))
          (+ (car c) (* 0.5 h (/ (float (car sz)) (cadr sz)))) (+ (cadr c) (* 0.5 h))
          (/ h (float (cadr sz)))))
)

(defun bh:query (flt boxes codes / vr ss b c en out)
  ;; 取 boxes（((x1 y1 x2 y2) ...)）里的对象：
  ;;   全部在当前视图内、且放大到 1 个图形单位至少 2 个像素时，用 ssget "_C"（走显示索引，快）；
  ;;   否则（或 *bh-force-x* 为真）用 ssget "_X" 全图按组码 codes 的点坐标筛选，不受视口限制。
  ;; _C 取到的是与矩形相交的对象，比按点坐标筛选多，调用方都会再按坐标精确判定。
  (setq vr (if (not *bh-force-x*) (bh:view-rect)))
  (if (and vr (<= (nth 4 vr) 0.5)
           (vl-every '(lambda (b) (and (>= (car b) (car vr)) (>= (cadr b) (cadr vr))
                                        (<= (caddr b) (caddr vr)) (<= (cadddr b) (cadddr vr))))
                     boxes))
    (progn
      (setq *bh-fast-used* T out (ssadd))
      (foreach b boxes
        (if (setq ss (ssget "_C" (list (car b) (cadr b)) (list (caddr b) (cadddr b)) flt))
          (foreach en (xy:ss->list ss) (ssadd en out))))
      (xy:ss->list out))
    (progn
      (foreach b boxes
        (foreach c codes
          (setq out (append out (list '(-4 . "<AND") '(-4 . ">=,>=,*") (list c (car b) (cadr b) 0.0)
                                      '(-4 . "<=,<=,*") (list c (caddr b) (cadddr b) 0.0) '(-4 . "AND>"))))))
      (xy:ss->list (ssget "_X" (append flt '((-4 . "<OR")) out '((-4 . "OR>")))))))
)

(defun bh:x-vlines (hinfo / pad)
  ;; 任一端点落在电缆线附近的直线，再交给 XY 的竖线判定（与 xy:collect-vlines 的结果一致，只是不受视口限制）
  (setq pad (max 1.0 *xy-geom-tol*))
  (xy:filter-vertical-lines
    (bh:query '((0 . "LINE"))
              (list (list (- (car hinfo) pad) (- (caddr hinfo) pad) (+ (cadr hinfo) pad) (+ (caddr hinfo) pad)))
              '(10 11)))
)

(defun bh:prin-range (vrec)
  ;; 芯线远端原理号的搜索高度范围 (下 上)
  (if (eq (cadr vrec) 'UP)
    (list (cadr (caddr vrec)) (+ (cadr (caddr vrec)) *xy-ray-len*))
    (list (- (cadr (caddr vrec)) *xy-ray-len*) (cadr (caddr vrec))))
)

(defun bh:near-anchor-p (x y vrecs / vrec r hit)
  ;; 插入点是否可能属于某根芯线远端的原理号：X 距芯线 6 以内（竖排文字宽约 3），Y 在搜索区上下再放宽 30（容纳文字长度）。
  ;; 只是减少 COM 外框计算的粗筛，最终仍由 xy:find-text-for-vrec 按外框精确判定
  (foreach vrec vrecs
    (setq r (bh:prin-range vrec))
    (if (and (not hit)
             (<= (abs (- x (car (caddr vrec)))) 6.0)
             (<= (- (car r) 30.0) y (+ (cadr r) 30.0)))
      (setq hit T)))
  hit
)

(defun bh:x-texts (hinfo vrecs / rx ry x1 y1 x2 y2 vrec r en ed ip x y lines prins marks)
  ;; 一次全图查询（不受视口限制）取三类文字：
  ;;   线上方 0.1~3 的编号/去向/规格 → ((x 图元 纯文本) ...)，按 X 排序；
  ;;   芯线远端附近的原理号候选 → (图元 ...)；
  ;;   线右端旧的原因文字（BH_MARK）→ (图元 ...)
  (setq rx (cadr hinfo) ry (caddr hinfo))
  (foreach vrec vrecs
    (setq r (bh:prin-range vrec))
    (setq x1 (if x1 (min x1 (car (caddr vrec))) (car (caddr vrec)))
          x2 (if x2 (max x2 (car (caddr vrec))) (car (caddr vrec)))
          y1 (if y1 (min y1 (car r)) (car r))
          y2 (if y2 (max y2 (cadr r)) (cadr r))))
  (foreach en (bh:query '((0 . "TEXT,MTEXT"))
                        (cons (list (- (car hinfo) 0.1) ry (+ rx 4.0) (+ ry 3.0))
                              (if x1 (list (list (- x1 6.0) (- y1 30.0) (+ x2 6.0) (+ y2 30.0)))))
                        '(10))
    (setq ed (entget en) ip (cdr (assoc 10 ed)) x (car ip) y (cadr ip))
    (if (= (strcase (cdr (assoc 8 ed))) "BH_MARK")
      (if (and (= (cdr (assoc 0 ed)) "TEXT") (<= (+ rx 1.0) x (+ rx 4.0)) (< ry y (+ ry 3.0)))
        (setq marks (cons en marks)))
      (progn
        (if (bh:in-band-p x y hinfo)
          (setq lines (cons (list x en (aa:ysdl-get-plain-text ed)) lines)))
        (if (bh:near-anchor-p x y vrecs)
          (setq prins (cons en prins))))))
  (list (aa:merge-sort lines '(lambda (a b) (< (car a) (car b)))) prins marks)
)

(defun bh:analyze-pass (ed hinfo start / vlineDataList tx)
  (setq *xy-last-vrec-map* nil
        vlineDataList (bh:x-vlines hinfo))
  (xy:build-vline-buckets vlineDataList)
  (setq tx (bh:x-texts hinfo (xy:get-vrecs-for-hline-ed ed vlineDataList))
        *bh-marks* (caddr tx))
  (bh:analyze ed hinfo start (car tx) vlineDataList (xy:build-text-meta-list (cadr tx)))
)

(defun bh:analyze-one (en start / ed hinfo res *bh-force-x* *bh-fast-used*)
  ;; 单根电缆线识别，结果格式同 bh:analyze；这根线右端旧的原因文字放进 *bh-marks*（c:BH1 的局部变量）。
  ;; 先按当前视图快速查询；用了快速查询却没识别成功（如原理号在屏幕外）时，改用全图查询再识别一次
  (setq ed (entget en)
        hinfo (xy:hline-info-ed ed)
        res (bh:analyze-pass ed hinfo start))
  (if (and *bh-fast-used* (not (eq (car res) 'OK)))
    (setq *bh-force-x* T
          res (bh:analyze-pass ed hinfo start)))
  res
)

(defun bh:numbered-action (k nc kmap nmap / hit)
  ;; 已有编号的电缆与记录核对：(OK) 一致 / (OLD 新编号) 是旧编号 / (CONFLICT 原因) / (ADD) 记入
  (cond
    ((setq hit (assoc k kmap))
     (cond
       ((= (bh:clean (cadr hit)) nc) '(OK))
       ((member nc (mapcar 'bh:clean (caddr hit))) (list 'OLD (cadr hit)))
       (T (list 'CONFLICT (strcat "与另一端记录编号 " (cadr hit) " 不一致")))))
    ((setq hit (assoc nc nmap)) (list 'CONFLICT (bh:used-msg hit)))
    (T '(ADD)))
)

(defun bh:used-tails (pfx recs skip / pre o r out)
  ;; 同前缀在记录里用过的“-”后部分（现行编号和旧编号），已转大写；旧编号在 skip 里的不算（重新编号时放出的号）
  (setq pre (strcat (bh:clean pfx) "-"))
  (foreach r recs
    (foreach o (cons (car r) (vl-remove-if '(lambda (o) (member (bh:clean o) skip)) (bh:olds r)))
      (setq o (bh:clean o))
      (if (and (> (strlen o) (strlen pre)) (= (substr o 1 (strlen pre)) pre))
        (setq out (cons (substr o (1+ (strlen pre))) out)))))
  out
)

(defun bh:own-records (recs keys start pfx / pre s r out)
  ;; 本柜（任一端是起点柜）、编号以“前缀-”开头的记录：((键 . 编号) ...)
  (setq pre (strcat (bh:clean pfx) "-") s (hddl:cabinet start))
  (foreach r recs
    (if (and (member s (list (hddl:cabinet (nth 1 r)) (hddl:cabinet (nth 2 r))))
             (> (strlen (bh:clean (car r))) (strlen pre))
             (= (substr (bh:clean (car r)) 1 (strlen pre)) pre))
      (setq out (cons (cons (car keys) (car r)) out)))
    (setq keys (cdr keys)))
  (reverse out)
)

(defun bh:free-letter (base tails taken / i)
  ;; base 后第一个没用过的字母
  (setq i 0)
  (while (or (member (strcat base (bh:letter i)) tails) (member (bh:letter i) taken))
    (setq i (1+ i)))
  (bh:letter i)
)

(defun bh:set-num (en val / ed c)
  ;; 改编号文字并把红色恢复白色；返回撤销用的操作 (TEXT 图元 原文字 原颜色)
  (setq ed (entget en) c (cdr (assoc 62 ed)))
  (setq c (list 'TEXT en (cdr (assoc 1 ed)) (if c c 256)))
  (jm:set-text en val)
  (if (= (cadddr c) 1) (hddl:color en 7))
  c
)

(defun bh:set-red (en / ed c)
  (setq ed (entget en) c (cdr (assoc 62 ed)))
  (hddl:color en 1)
  (list 'TEXT en (cdr (assoc 1 ed)) (if c c 256))
)

(defun bh:undo-ops (ops / op)
  ;; ops 按“后做的在前”排列，依次还原
  (foreach op ops
    (if (eq (car op) 'TEXT)
      (progn (jm:set-text (cadr op) (caddr op)) (hddl:color (cadr op) (cadddr op)))
      (entdel (cadr op))))
)

(defun bh:pick-start (tag / sel ed h name quit)
  ;; 点选起点柜名大字（字高 >=80）；回车或 Esc 放弃返回 nil
  (while (and (null name) (not quit))
    (setvar "ERRNO" 0)
    (setq sel (entsel (strcat "\r\n[" tag "] 请选择起点柜名大字（字高 >=80）: ")))
    (cond
      ((null sel)
       (if (/= (getvar "ERRNO") 7) (setq quit T)))
      ((not (member (cdr (assoc 0 (setq ed (entget (car sel))))) '("TEXT" "MTEXT")))
       (princ (strcat "\r\n[" tag "] 选中的不是文字。")))
      ((< (setq h (cdr (assoc 40 ed))) 79.9)
       (princ (strcat "\r\n[" tag "] 字高 " (rtos h 2 1) " 小于 80，请选择柜名大字。")))
      ((= (setq name (vl-string-trim " \t" (aa:ysdl-get-plain-text ed))) "")
       (setq name nil)
       (princ (strcat "\r\n[" tag "] 柜名文字为空。")))))
  name
)

(defun bh:lines-box (lines / en h b)
  ;; 选中电缆线连同线上方文字带的外包范围 (x1 y1 x2 y2)
  (foreach en lines
    (setq h (xy:hline-info-ed (entget en))
          b (bh:box-add b (- (car h) 0.1) (caddr h) (+ (cadr h) 4.0) (+ (caddr h) 3.0))))
  b
)

(defun bh:box-add (b x1 y1 x2 y2)
  (if b
    (list (min (car b) x1) (min (cadr b) y1) (max (caddr b) x2) (max (cadddr b) y2))
    (list x1 y1 x2 y2))
)

(defun bh:zoom-box (b / m p1 p2 res)
  ;; 把范围 b 缩放进屏幕，四周留 5% 边
  (setq m (* 0.05 (max (- (caddr b) (car b)) (- (cadddr b) (cadr b)) 20.0))
        p1 (list (- (car b) m) (- (cadr b) m) 0.0)
        p2 (list (+ (caddr b) m) (+ (cadddr b) m) 0.0))
  (setq res (vl-catch-all-apply 'vla-ZoomWindow (list (vlax-get-acad-object) (vlax-3d-point p1) (vlax-3d-point p2))))
  (if (vl-catch-all-error-p res)
    (command "_.ZOOM" "_W" (trans p1 0 1) (trans p2 0 1)))
)

(defun bh:view-save ()
  (list (trans (getvar "VIEWCTR") 1 0) (getvar "VIEWSIZE"))
)

(defun bh:view-restore (v / res)
  (setq res (vl-catch-all-apply 'vla-ZoomCenter (list (vlax-get-acad-object) (vlax-3d-point (car v)) (cadr v))))
  (if (vl-catch-all-error-p res)
    (command "_.ZOOM" "_C" (trans (car v) 0 1) (cadr v)))
)

(defun bh:mark-list (/ ss i en ip out)
  ;; 全图 BH_MARK 原因文字 ((x y 图元) ...)，每批只取一次
  (if (setq ss (ssget "_X" '((0 . "TEXT") (8 . "BH_MARK"))))
    (progn
      (setq i 0)
      (repeat (sslength ss)
        (setq en (ssname ss i) i (1+ i))
        (if (setq ip (cdr (assoc 10 (entget en))))
          (setq out (cons (list (car ip) (cadr ip) en) out))))))
  out
)

(defun bh:marks-for (hinfo marks / m out)
  ;; 这根线右端的旧原因文字
  (foreach m marks
    (if (and (<= (+ (cadr hinfo) 1.0) (car m) (+ (cadr hinfo) 4.0))
             (< (caddr hinfo) (cadr m) (+ (caddr hinfo) 3.0)))
      (setq out (cons (caddr m) out))))
  out
)

(defun bh:analyze-picked (lines start / b lb vlineDataList textMetaList *bh-tail* en ed hinfo v r ss out)
  ;; 先缩放到全部选中的电缆线取芯线，再缩放到连同芯线远端原理号区域，用屏幕内查询一次识别（同 BH2/XYG 的识别方式）。
  ;; 返回与 lines 一一对应（点选顺序）的识别结果
  (setq lb (bh:lines-box lines) b lb)
  (bh:zoom-box b)
  (setq *xy-last-vrec-map* nil
        vlineDataList (xy:collect-vlines lines))
  (xy:build-vline-buckets vlineDataList)
  (foreach en lines
    (foreach v (xy:get-vrecs-for-hline-ed (entget en) vlineDataList)
      (setq r (bh:prin-range v)
            b (bh:box-add b (- (car (caddr v)) 6.0) (- (car r) 30.0) (+ (car (caddr v)) 6.0) (+ (cadr r) 30.0)))))
  (if (not (equal b lb)) (bh:zoom-box b))
  (setq textMetaList (xy:build-text-meta-list (xy:collect-texts lines vlineDataList))
        ss (ssget "_C" (trans (list (car lb) (cadr lb) 0.0) 0 1) (trans (list (caddr lb) (cadddr lb) 0.0) 0 1)
                  '((0 . "TEXT,MTEXT")))
        *bh-tail* (if ss (bh:text-index ss)))
  ;; bh:line-texts 要求从上到下调用，识别完再按点选顺序取出
  (foreach en (xyg:sort-lines-desc lines)
    (setq ed (entget en) hinfo (xy:hline-info-ed ed)
          out (cons (cons en (bh:analyze ed hinfo start (bh:line-texts hinfo) vlineDataList textMetaList)) out)))
  (mapcar '(lambda (en) (cdr (assoc en out))) lines)
)

;;; 功能: 逐根点选编号：先点起点柜名大字并输入前缀、起始号，再依次点绿色电缆线，回车后自动缩放一次识别并按点选顺序编号，同终点加 A/B/C，可撤销本批。
(defun c:BH1 (/ *error* aa:tag aa:doc aa:undo-open aa:old-cmdecho
                path dwg start-name pfx start n width recs rkeys kmap nmap groups hist
                sel en it k nc hit act sp gid g base tails first num newrecs newkeys sets ops
                red mark msg h s done L1 L2 r e cnt oldmap freed o t1 t2 *bh-marks*
                picks stop view items marks i nb)
  (aa:cmd-begin "BH1")
  (cond
    ((/= (getvar "DWGTITLED") 1)
     (princ "\r\n[BH1] 请先保存图纸：电缆编号记录写在 dwg 所在文件夹，未保存的新图没有文件夹。"))
    ((null (setq start-name (bh:pick-start "BH1")))
     (princ "\r\n[BH1] 未选择起点柜，命令结束。"))
    (T
     (princ (strcat "\r\n[BH1] 起点柜：" start-name))
     (setq pfx (bh:ask-prefix "BH1")
           start (bh:ask-start "BH1")
           n (atoi start)
           width (strlen start)
           path (bh:record-path)
           dwg (getvar "DWGNAME")
           recs (bh:read-records path)
           rkeys (mapcar 'bh:rec-key recs)
           kmap (bh:kmap recs rkeys)
           nmap (bh:nmap recs rkeys)
           cnt 0)
     ;; 本柜已有本前缀的编号时，可以选择全部重新编号：先删掉这些记录，旧号留作“旧编号”，另一端会自动跟改
     (if (setq oldmap (bh:own-records recs rkeys start-name pfx))
       (progn
         (initget "K R")
         (if (= "R" (getkword (strcat "\r\n[BH1] 记录里本柜已有 " (itoa (length oldmap)) " 条 " pfx
                                      "- 开头的编号（" (cdr (car oldmap)) " 等）。[沿用(K)/重新编号(R)] <沿用>: ")))
           (progn
             (setq newrecs nil newkeys nil)
             (mapcar '(lambda (r e) (if (not (assoc e oldmap)) (setq newrecs (cons r newrecs) newkeys (cons e newkeys))))
                     recs rkeys)
             (setq newrecs (reverse newrecs) newkeys (reverse newkeys))
             (if (bh:write-records path newrecs)
               (progn
                 (setq recs newrecs rkeys newkeys
                       kmap (bh:kmap recs rkeys) nmap (bh:nmap recs rkeys)
                       freed (mapcar '(lambda (o) (bh:clean (cdr o))) oldmap))
                 (princ (strcat "\r\n[BH1] 已清除这 " (itoa (length oldmap)) " 条记录，从 " pfx "-" start
                                " 重新编号；图上显示旧号的线点到后也会重新编号。")))
               (progn (bh:write-failed path) (setq done T))))
           (setq oldmap nil))))
     (while (not done)
       ;; ---- 第 1 步：依次点选，记住顺序（选中的线高亮）
       (setq picks nil stop nil)
       (while (not stop)
         (setvar "ERRNO" 0)
         (initget "U")
         (setq sel (entsel (strcat "\r\n[BH1] 依次点选电缆线（已选 " (itoa (length picks)) " 根，下一个顺序号 "
                                   pfx "-" (bh:pad n width) "）[撤销(U)] <"
                                   (if picks "回车开始编号" "结束") ">: ")))
         (cond
           ((= sel "U")
            (if picks
              (progn (redraw (car picks) 4) (setq picks (cdr picks))
                     (princ (strcat "\r\n[BH1] 已去掉最后一根，还剩 " (itoa (length picks)) " 根。")))
              (princ "\r\n[BH1] 还没有选中电缆线。")))
           ((null sel)
            (if (/= (getvar "ERRNO") 7) (setq stop T)))
           ((not (xy:is-green-hline-p (setq en (car sel))))
            (princ "\r\n[BH1] 选中的不是绿色水平直线。"))
           ((member en picks)
            (princ "\r\n[BH1] 这根已经选过了。"))
           (T
            (redraw en 3)
            (setq picks (cons en picks)))))
       (setq picks (reverse picks))
       (if (null picks)
         (setq done T)
         (progn
           ;; ---- 第 2 步：缩放识别，再恢复原来的视图
           (setq t1 (aa:link-clock) view (bh:view-save)
                 items (bh:analyze-picked picks start-name))
           (bh:view-restore view)
           (foreach en picks (redraw en 4))
           (setq t2 (aa:link-clock) marks (bh:mark-list) i 0 nb 0)
           (aa:rep-begin "BH1")
           ;; ---- 第 3 步：按点选顺序编号
           (foreach it items
             (setq i (1+ i))
             ;; 屏幕内没认出（如个别原理号仍在范围外）时，这一根改用全图查询再识别一次
             (if (eq (car it) 'ERR)
               (setq it (bh:analyze-one (nth (1- i) picks) start-name)))
             (cond
               ((eq (car it) 'SKIP)
                (aa:rep-item "info" "跳过" (nth (1- i) picks) (strcat "第 " (itoa i) " 根：上方没有“至…”去向文字，不是电缆")))
               ((eq (car it) 'ERR)
                (aa:rep-item "err" "无法编号" (nth (1- i) picks) (strcat "第 " (itoa i) " 根：" (cadr it))))
               (T
                (setq k (nth 6 it) nc (bh:clean (nth 3 it))
                      newrecs recs newkeys rkeys sets nil red nil mark nil msg nil ops nil L1 nil
                      s (list recs rkeys groups n)
                      *bh-marks* (bh:marks-for (cadr it) marks)
                      ;; 选了重新编号、这根还没重编时：o 为 (键 . 旧号)
                      o (if (and (assoc k oldmap) (not (assoc k kmap))) (assoc k oldmap)))
                (cond
                  ;; 已有编号：只核对，不占顺序号（重新编号模式下图上还是旧号的除外）
                  ((and (/= nc (bh:clean "未编号")) (not (and o (= nc (bh:clean (cdr o))))))
                   (setq act (bh:numbered-action k nc kmap nmap))
                   (cond
                     ((eq (car act) 'OK) (setq msg (strcat (nth 3 it) " 已编号，与记录一致")))
                     ((eq (car act) 'OLD)
                      (setq sets (list (list (nth 2 it) (cadr act)))
                            msg (strcat "旧编号 " (nth 3 it) " 改为 " (cadr act))))
                     ((eq (car act) 'CONFLICT)
                      (setq red T mark (cadr act) msg (strcat (nth 3 it) " 编号冲突：" (cadr act))))
                     (T
                      (setq newrecs (append recs (list (list (nth 3 it) start-name (nth 4 it) (bh:prins-str (nth 5 it)) dwg (bh:now))))
                            newkeys (append rkeys (list k))
                            msg (strcat (nth 3 it) " 已编号，记入记录")))))
                  ;; 未编号，记录里有：直接填入
                  ((setq hit (assoc k kmap))
                   (setq sets (list (list (nth 2 it) (cadr hit)))
                         msg (strcat "按记录填入 " (cadr hit))))
                  ;; 未编号，分配新编号
                  (T
                   (setq sp (bh:special (nth 4 it) (nth 7 it))
                         gid (strcat (hddl:cabinet (nth 4 it)) (chr 1) (if sp sp ""))
                         g (assoc gid groups)
                         tails (bh:used-tails pfx recs freed))
                   (cond
                     ;; 本次已经编过这个终点柜：加字母；第一根还是不带字母的，先改成 A
                     (g
                      (setq base (cadr g) first (caddr g) L1 nil)
                      (if (= (bh:clean (cadr (assoc (cadr first) kmap))) (bh:clean (strcat pfx "-" base)))
                        (setq L1 (bh:free-letter base tails nil)
                              sets (list (list (car first) (strcat pfx "-" base L1)))
                              newrecs (mapcar '(lambda (r e) (if (= e (cadr first)) (cons (strcat pfx "-" base L1) (cdr r)) r))
                                              recs rkeys)))
                      (setq L2 (bh:free-letter base tails (if L1 (list L1)))
                            num (strcat pfx "-" base L2)))
                     ;; 录波 / 公用测控信号线：固定 130 / 131
                     (sp
                      (setq base sp
                            num (if (member sp (mapcar 'bh:tail-base tails))
                                  (progn
                                    (aa:rep-item "warn" "注意" (nth 2 it) (strcat pfx "-" sp " 已经用过，这根从字母编起，请人工确认"))
                                    (strcat pfx "-" sp (bh:free-letter sp tails nil)))
                                  (strcat pfx "-" sp))
                            groups (cons (list gid base (list (nth 2 it) k)) groups)))
                     ;; 新终点柜：取下一个没用过的顺序号
                     (T
                      (setq base nil)
                      (while (null base)
                        (setq base (bh:pad n width))
                        (cond
                          ((member base (mapcar 'bh:tail-base tails))
                           (setq base nil n (1+ n)))
                          ((and (member base '("130" "131")) (not (bh:ask-reserved-p "BH1" pfx base)))
                           (setq base nil n (1+ n)))))
                      (setq n (1+ n)
                            num (strcat pfx "-" base)
                            groups (cons (list gid base (list (nth 2 it) k)) groups))))
                   (setq sets (append sets (list (list (nth 2 it) num)))
                         newrecs (append newrecs (list (list num start-name (nth 4 it) (bh:prins-str (nth 5 it)) dwg (bh:now)
                                                             (if (and o (/= (bh:clean (cdr o)) (bh:clean num))) (cdr o) ""))))
                         newkeys (append rkeys (list k))
                         msg (strcat "新编号 " num (if o (strcat "（原 " (cdr o) "）") "")
                                     (if L1 (strcat "（同终点第一根改为 " (cadr (car sets)) "）") "")))))
                ;; 先写记录，写不进去就不改图
                (if (and (not (eq newrecs recs)) (not (bh:write-records path newrecs)))
                  (progn
                    (bh:write-failed path)
                    (setq groups (nth 2 s) n (nth 3 s)))
                  (progn
                    (foreach e *bh-marks*
                      (entdel e)
                      (setq ops (cons (list 'DEL e) ops)))
                    (foreach r sets
                      (setq ops (cons (bh:set-num (car r) (cadr r)) ops)))
                    (cond
                      (red
                       (setq ops (cons (bh:set-red (nth 2 it)) ops))
                       (setq ops (cons (list 'MAKE (bh:make-marker (cadr it) (strcat "[编号冲突] " mark))) ops)))
                      ((null sets)
                       (if (= (cdr (assoc 62 (entget (nth 2 it)))) 1)
                         (setq ops (cons (bh:set-num (nth 2 it) (nth 3 it)) ops)))))
                    (setq msg (strcat "至" (nth 4 it) "：" msg))
                    (aa:rep-item (if red "err" "ok") (if red "编号冲突" "编号") (nth 2 it) (strcat "第 " (itoa i) " 根 " msg))
                    (if (or ops (not (eq newrecs recs)))
                      (setq hist (cons (list s ops msg) hist) cnt (1+ cnt) nb (1+ nb)))
                    (setq recs newrecs rkeys newkeys
                          kmap (bh:kmap recs rkeys) nmap (bh:nmap recs rkeys)))))))
           (aa:rep-end (strcat "本批 " (itoa (length picks)) " 根完成")
                       (strcat "本批 " (itoa (length picks)) " 根完成：识别 " (rtos (- t2 t1) 2 2)
                               " 秒，编号 " (rtos (- (aa:link-clock) t2) 2 2) " 秒。"))
           ;; ---- 第 4 步：可撤销整批，回车继续点下一批
           (initget "U")
           (if (and (> nb 0) (= "U" (getkword "\r\n[BH1] [撤销本批(U)] <继续点选>: ")))
             (progn
               (while (and (> nb 0) hist)
                 (setq h (car hist) s (car h))
                 (if (and (not (eq (car s) recs)) (not (bh:write-records path (car s))))
                   (progn (bh:write-failed path) (setq nb 0))
                   (progn
                     (bh:undo-ops (cadr h))
                     (setq recs (nth 0 s) rkeys (nth 1 s) groups (nth 2 s) n (nth 3 s)
                           kmap (bh:kmap recs rkeys) nmap (bh:nmap recs rkeys)
                           hist (cdr hist) cnt (1- cnt) nb (1- nb)))))
               (princ (strcat "\r\n[BH1] 已撤销本批，下一个顺序号回到 " pfx "-" (bh:pad n width) "。")))))))
     (princ (strcat "\r\n[BH1] 结束：本次共编 " (itoa cnt) " 根。记录文件：" path))))
  (aa:cmd-end)
  (princ)
)
(defun bh:spec-cell-p (v / s)
  ;; 清册规格列：含“×”或“数字x数字”（2×4、KVVP2-22 4x1.5）、“通讯线”“未填写”
  (setq s (jm:norm v))
  (or (vl-string-search "×" s) (wcmatch s "*#X#*") (= s "通讯线") (= s "未填写"))
)

(defun bh:core-cell-p (v)
  ;; 清册芯数列：一两位数字（2、4、10）；三位以上的数字是原理号（101）
  (wcmatch (jm:norm v) "#,##")
)

(defun bh:table-row (row / prins i v c3 c4 nospec)
  ;; 清册一行（HDDL 分行结果，按 X 排序）→ (编号 起点柜 终点柜 原理号列表 编号图元 没写规格)
  ;; 列：起点 编号 终点 规格 芯数 原理号…（同 HDDL）；也认 芯数 规格 的旧顺序
  ;; 规格列空着（第 4 个文字就是芯数）时，第 5 个文字已是原理号，不能当芯数丢掉；第 6 项为 T 表示没写规格
  (setq c3 (hddl:cell row 3) c4 (hddl:cell row 4))
  (cond
    ((and (bh:core-cell-p c3) (bh:spec-cell-p c4)) (setq i 5))
    ((bh:core-cell-p c3) (setq i 4 nospec (and (hddl:item row 4) T)))
    ((bh:core-cell-p c4) (setq i 5))
    (T (setq i 4)))
  (while (hddl:item row i)
    (setq v (hddl:cell row i))
    (if (/= v "") (setq prins (cons v prins)))
    (setq i (1+ i)))
  (list (hddl:cell row 1) (hddl:cell row 0) (hddl:cell row 2) (reverse prins) (car (hddl:item row 1)) nospec)
)

;;; 功能: 框选电缆清册文字（起点柜/编号/终点柜/规格/芯数/原理号），以本次选中的清册为准写入共享记录：没有的记入，有的强制改成清册编号，编号被别的电缆占用或清册内重复时也照清册记入并在命令行说明。
(defun c:BH3 (/ *error* aa:tag aa:doc aa:undo-open aa:old-cmdecho
                ss i e d items rows row tr num k nc hit r path dwg now recs rkeys kmap nmap
                upd ren del keep notes nok nadd nchg nskip nsteal nmul bad-ss selk seln dk dn act same pairs nospec)
  (aa:cmd-begin "BH3")
  (aa:rep-begin "BH3")
  (setq bad-ss (ssadd) nok 0 nadd 0 nchg 0 nskip 0 nsteal 0 nmul 0 nospec nil)
  (cond
    ((/= (getvar "DWGTITLED") 1)
     (princ "\r\n[BH3] 请先保存图纸：电缆编号记录写在 dwg 所在文件夹，未保存的新图没有文件夹。"))
    ((progn
       (princ "\r\n[BH3] 请框选电缆清册文字（每行：起点柜 电缆编号 终点柜 规格 芯数 原理号…）: ")
       (null (setq ss (ssget '((0 . "TEXT,MTEXT") (8 . "~BH_MARK,HDDL_MARK"))))))
     (princ "\r\n[BH3] 未选择文字，命令结束。"))
    (T
     ;; 与 HDDL 相同：按 Y 归行，行内按 X 排序；各行按从上到下处理，记录文件里的顺序与清册一致
     (setq i 0)
     (repeat (sslength ss)
       (setq e (ssname ss i) d (entget e) i (1+ i))
       (setq items (cons (list e (hddl:text d) (hddl:point (cdr (assoc 10 d)))) items)))
     (setq rows (aa:merge-sort (hddl:sort-rows (hddl:rows items))
                  '(lambda (a b) (> (hddl:coord (car a) 1) (hddl:coord (car b) 1))))
           path (bh:record-path)
           dwg (getvar "DWGNAME")
           now (bh:now)
           recs (bh:read-records path)
           rkeys (mapcar 'bh:rec-key recs)
           kmap (bh:kmap recs rkeys)
           nmap (bh:nmap recs rkeys)
           ;; 记录里已有的（键 . 比较用编号）：清册内重复的电缆重跑时据此认作一致，不重复记入
           pairs (mapcar '(lambda (r k) (cons k (bh:clean (car r)))) recs rkeys))
     (foreach row rows
       (setq tr (bh:table-row row) num (car tr))
       (cond
         ;; 编号为空或“未编号”、柜名不全、没有原理号的行（含表头）跳过；*** 等占位编号照常记录
         ((or (= num "") (= (bh:clean num) (bh:clean "未编号"))
              (= (cadr tr) "") (= (caddr tr) "") (null (cadddr tr)))
          (setq nskip (1+ nskip)))
         (T
          (if (nth 5 tr) (setq nospec (cons tr nospec)))
          (setq k (bh:key (cadr tr) (caddr tr) (bh:prins-str (cadddr tr)))
                nc (bh:clean num)
                hit (assoc k kmap)
                r (if (not (bh:placeholder-p nc)) (assoc nc nmap))
                dk (assoc k selk)
                same (vl-some '(lambda (x) (and (= (car x) k) (= (bh:clean (cdr x)) nc))) selk)
                dn (if (not (bh:placeholder-p nc)) (assoc nc seln))
                act T)
          ;; 一律以本次选中的清册为准，有疑问的照样记入，在命令行说明
          (cond
            ;; 与本次前面一行完全相同（同一起终点、原理号、同编号）：只记一次
            (same
             (setq act nil
                   notes (cons (list (nth 4 tr) (strcat num " 与本次选择中前面一行完全相同，只记一次")) notes)))
            ;; 记录里已有完全相同的（两端柜名、原理号、编号）
            ((and (member (cons k nc) pairs) (not (member k del)))
             (setq act nil nok (1+ nok)))
            ;; 同一起终点、原理号的电缆有多根：每根都记入
            (dk
             (setq nmul (1+ nmul) nadd (1+ nadd)
                   notes (cons (list (nth 4 tr)
                                     (strcat num " 与本次选择中的 " (cdr dk)
                                             " 两端柜名和原理号都相同，两根都已记入（BH2 按柜名+原理号对号时只认前一根，请核对端子排）"))
                               notes)))
            ;; 编号在本次选择中已给了另一根电缆：照清册两根都记入
            (dn
             (setq nmul (1+ nmul) nadd (1+ nadd)
                   notes (cons (list (nth 4 tr)
                                     (strcat num " 在本次选择中也用于 " (caddr dn) "—" (cadddr dn) "，两根都已记入，请核对清册"))
                               notes)))
            ;; 编号原属另一根电缆（两端柜名和原理号都对不上）：删掉那条记录，编号按清册给这根
            ((and r (/= (cadr r) k) (not (bh:renamed-p (cadr r) k)))
             (setq nsteal (1+ nsteal)
                   del (if (member (cadr r) del) del (cons (cadr r) del))
                   notes (cons (list (nth 4 tr)
                                     (strcat num " 原属 " (caddr r) "—" (cadddr r) " 的记录已删除，按清册改给 "
                                             (cadr tr) "—" (caddr tr)))
                               notes))
             (if hit (setq nchg (1+ nchg)) (setq nadd (1+ nadd))))
            ;; 没有的记入；编号不同的强制改（原编号存为旧编号）；同一根电缆换了柜名或原理号的换成清册内容
            ((and r (/= (cadr r) k)) (setq ren (cons (cons (cadr r) k) ren)))
            (hit (setq nchg (1+ nchg)))
            (T (setq nadd (1+ nadd))))
          (if (not same)
            (setq selk (cons (cons k num) selk)
                  seln (if (or dn (bh:placeholder-p nc)) seln (cons (list nc num (cadr tr) (caddr tr)) seln))))
          (if act
            (setq upd (cons (list k (list num (cadr tr) (caddr tr) (bh:prins-str (cadddr tr)) dwg now)) upd)))))
       ;; 上一版标红的编号恢复白色
       (if (and (nth 4 tr) (= (cdr (assoc 62 (entget (nth 4 tr)))) 1)) (hddl:color (nth 4 tr) 7)))
     (if (or upd del) (setq keep (bh:rebuild recs rkeys upd del ren)))
     ;; 先写记录文件，写不进去就不改图
     (if (and (or upd del) (not (bh:write-records path keep)))
       (bh:write-failed path)
       (progn
         (foreach e (reverse notes)
           (if (car e) (ssadd (car e) bad-ss))
           (aa:rep-item "warn" "说明" (car e) (cadr e)))
         ;; 没写规格的行：每行一条明细，另汇总一行提醒（列出前 8 个编号），编号一并选中
         (if nospec
           (progn
             (setq nospec (reverse nospec) e "" i 0)
             (foreach tr nospec
               (if (nth 4 tr) (ssadd (nth 4 tr) bad-ss))
               (aa:rep-item "warn" "没写规格" (nth 4 tr) (strcat (car tr) "：芯数后面直接是原理号，已按原理号记入，请补写规格"))
               (if (< i 8) (setq e (strcat e (if (= e "") "" "、") (car tr))))
               (setq i (1+ i)))
             (aa:rep-info (strcat "提醒：" (itoa (length nospec)) " 行没写规格（芯数后面直接是原理号，已按原理号记入）："
                                  e (if (> i 8) " 等" "") "，编号已选中，请在清册补写规格。"))))
         (if (> nchg 0)
           (aa:rep-info "原编号已存为旧编号：端子排图上还是旧编号的，运行 BH1 或 BH2 会自动改成新编号。"))
         (aa:rep-info (strcat "记录文件：" path))
         (aa:rep-end
           (strcat "完成：" (aa:rep-counts (list (cons "新记入" nadd) (cons "改为清册编号" nchg) (cons "更正柜名/原理号" (length ren))
                                                (cons "一致" nok) (cons "从别的电缆改过来" nsteal) (cons "清册内重复" nmul)
                                                (cons "没写规格" (length nospec)) (cons "跳过行" nskip))))
           (strcat "完成（以本次选中的清册为准）：新记入 " (itoa nadd) " 根；记录改为清册编号 " (itoa nchg)
                   " 根；按清册更正柜名/原理号 " (itoa (length ren)) " 根；与记录一致 " (itoa nok)
                   " 根；其中编号从别的电缆改过来 " (itoa nsteal) " 根（原记录已删除）、清册内同一电缆或同一编号重复 "
                   (itoa nmul) " 根（都已记入）；跳过 " (itoa nskip)
                   " 行（编号为空或未编号、柜名不全、没有原理号）。"))))))
  (aa:cmd-end)
  (if (> (sslength bad-ss) 0)
    (sssetfirst nil bad-ss)
    (sssetfirst nil nil))
  (princ)
)
;;; END BH
;;; =======================================================================================
;;; 命令: ZDAO / HDAO
;;; 功能: 颠倒选中文字的排列顺序。ZDAO 纵向（原 DAO）：最下面的文字放到最上面，
;;;       从下往上倒数第二个变成从上往下第二个；HDAO 水平：最左边的放到最右边，
;;;       左边第二个变成从右边开始的第二个；其余依此类推。
;;; =======================================================================================

;;; 纵向排序：Y 大在前；同一行 X 小在前
(defun dao:upper-p (item other / y1 y2)
  (setq y1 (cadr (cadr item))
        y2 (cadr (cadr other)))
  (if (equal y1 y2 1e-6)
    (< (car (cadr item)) (car (cadr other)))
    (> y1 y2)
  )
)

;;; 水平排序：X 小在前；同一列 Y 大在前
(defun dao:left-p (item other / x1 x2)
  (setq x1 (car (cadr item))
        x2 (car (cadr other)))
  (if (equal x1 x2 1e-6)
    (> (cadr (cadr item)) (cadr (cadr other)))
    (< x1 x2)
  )
)

;;; 平移文字：entmod 修改组码 10（TEXT 若有 11 对齐点则同步平移）
(defun dao:move-text (ename dx dy / ed p10 p11)
  (setq ed (entget ename))
  (if (and ed (setq p10 (cdr (assoc 10 ed))))
    (progn
      (setq ed
        (subst
          (cons 10
                (list (+ (car p10) dx)
                      (+ (cadr p10) dy)
                      (if (caddr p10) (caddr p10) 0.0)))
          (assoc 10 ed)
          ed))
      (if (assoc 11 ed)
        (progn
          (setq p11 (cdr (assoc 11 ed)))
          (setq ed
            (subst
              (cons 11
                    (list (+ (car p11) dx)
                          (+ (cadr p11) dy)
                          (if (caddr p11) (caddr p11) 0.0)))
              (assoc 11 ed)
              ed))))
      (if (entmod ed) T nil))
    nil)
)

;;; 公共流程：mode 为 "V"（纵向，ZDAO）或 "H"（水平，HDAO）
(defun dao:run (mode / tag word ss i ename ed typ p10 lst sorted n
                  item cur target dx dy moved skipped)
  (setq tag     (if (= mode "H") "[HDAO]" "[ZDAO]")
        word    (if (= mode "H") "左右" "上下")
        moved   0
        skipped 0)
  (princ (strcat "\r\n" tag " 请选择要" word "颠倒排列的文字 (TEXT/MTEXT): "))
  (if (setq ss (ssget '((0 . "TEXT,MTEXT"))))
    (progn
      ;; 1. 收集每个文字及其插入点（组码 10）
      (setq lst '()
            i   0)
      (repeat (sslength ss)
        (setq ename (ssname ss i)
              ed    (entget ename)
              typ   (cdr (assoc 0 ed))
              p10   (cdr (assoc 10 ed)))
        (if (and p10 (or (= typ "TEXT") (= typ "MTEXT")))
          (setq lst (cons (list ename p10) lst))
          (setq skipped (1+ skipped))
        )
        (setq i (1+ i))
      )

      ;; 2. 排序：纵向从上到下，水平从左到右
      (setq sorted (aa:merge-sort (reverse lst)
                                  (if (= mode "H") 'dao:left-p 'dao:upper-p))
            n      (length sorted))

      (if (< n 2)
        (princ (strcat "\r\n" tag " 有效文字不足 2 个，无需颠倒。"))
        (progn
          ;; 3. 第 i 个文字移到第 n-1-i 个文字的位置，实现颠倒
          (setq i 0)
          (foreach item sorted
            (setq ename  (car item)
                  cur    (cadr item)
                  target (cadr (nth (- n 1 i) sorted))
                  dx     (- (car target) (car cur))
                  dy     (- (cadr target) (cadr cur)))
            (if (and (equal dx 0.0 1e-8) (equal dy 0.0 1e-8))
              (setq moved (1+ moved))
              (if (dao:move-text ename dx dy)
                (setq moved (1+ moved))
                (setq skipped (1+ skipped))
              )
            )
            (setq i (1+ i))
          )
          (redraw)
          (princ
            (strcat
              "\r\n" tag " 完成：共" word "颠倒 " (itoa n) " 个文字，已处理 " (itoa moved)
              " 个，跳过 " (itoa skipped) " 个。"))
        )
      )
    )
    (princ (strcat "\r\n" tag " 未选择任何文字对象。"))
  )
)

;;; 功能: 将选中文字按垂直位置上下颠倒排列（最下面的文字放到最上面），一次 U 撤销。
(defun c:ZDAO (/ *error* aa:tag aa:doc aa:undo-open aa:old-cmdecho)
  (aa:cmd-begin "ZDAO")
  (dao:run "V")
  (aa:cmd-end)
)

;;; 功能: 将选中文字按水平位置左右颠倒排列（最左边的文字放到最右边），一次 U 撤销。
(defun c:HDAO (/ *error* aa:tag aa:doc aa:undo-open aa:old-cmdecho)
  (aa:cmd-begin "HDAO")
  (dao:run "H")
  (aa:cmd-end)
)
;;; =======================================================================================
;;; 命令: QH
;;; 功能: 只选中已选文字所在行的所有文字（参考文字跨多行时逐行选择）；仅当前屏幕内、参考文字范围左右各 1000 绘图单位内寻找。
;;; =======================================================================================
(defun c:QH (/ *error* ss i ename ed ins x y h
             xmin xmax n ref-list sorted-ref rows
             last last-avg last-maxh item row
             row-centers rt left right bottom top found
             j e2 ed2 p2 x2 y2
             vctr vsize ssize aspect vw vh cx cy2
             scr-xmin scr-xmax scr-ymin scr-ymax)
  (vl-load-com)

  (defun *error* (msg)
    (if (and msg
             (not (wcmatch (strcase msg) "*BREAK*,*CANCEL*,*EXIT*,*QUIT*")))
      (princ (strcat "\r\n[QH] 错误: " msg))
    )
    (princ)
  )

  ;; 1. 取已选中的文字作为参考（无预选时手动选择）
  (setq ss (ssget "_I" '((0 . "TEXT,MTEXT"))))
  (if (null ss)
    (progn
      (princ "\r\n[QH] 请选择参考文字（可先选中文字再运行命令）: ")
      (setq ss (ssget '((0 . "TEXT,MTEXT"))))
    )
  )
  (if (null ss)
    (progn
      (princ "\r\n[QH] 未选择任何文字，命令已取消。")
      (exit)
    )
  )

  ;; 2. 收集参考文字信息 (x y h) 并统计整体 X 范围
  (setq i 0 xmin nil xmax nil n 0 ref-list '())
  (repeat (sslength ss)
    (setq ename (ssname ss i)
          ed    (entget ename)
          ins   (cdr (assoc 10 ed)))
    (if ins
      (progn
        (setq x (car ins)
              y (cadr ins)
              h (if (assoc 40 ed) (cdr (assoc 40 ed)) 0.0))
        (if (null xmin) (setq xmin x xmax x))
        (setq xmin (min xmin x)
              xmax (max xmax x)
              n     (1+ n)
              ref-list (cons (list x y h) ref-list))
      )
    )
    (setq i (1+ i))
  )
  (if (= n 0)
    (progn
      (princ "\r\n[QH] 无法读取参考文字的位置信息，命令已取消。")
      (exit)
    )
  )

  ;; 3. 参考文字按 Y 排序后聚类成行（行间容差取组内最大字高的 0.7 倍）
  (setq sorted-ref (aa:merge-sort ref-list
                     '(lambda (a b) (< (cadr a) (cadr b))))
        rows '())
  (foreach item sorted-ref
    (setq y (cadr item)
          h (caddr item))
    (if (null rows)
      (setq rows (list (list y y h)))
      (progn
        (setq last     (car rows)
              last-avg (/ (+ (car last) (cadr last)) 2.0)
              last-maxh (caddr last))
        (if (<= (abs (- y last-avg)) (* last-maxh 0.7))
          (setq rows (cons (list (min (car last) y)
                                 (max (cadr last) y)
                                 (max (caddr last) h))
                           (cdr rows)))
          (setq rows (cons (list y y h) rows))
        )
      )
    )
  )
  ;; 每行生成 (行中心Y 行容差)，容差至少半个字高
  (setq row-centers '())
  (foreach row rows
    (setq row-centers
           (cons (list (/ (+ (car row) (cadr row)) 2.0)
                       (max (+ (/ (- (cadr row) (car row)) 2.0)
                                (* (caddr row) 0.5))
                            (* (caddr row) 0.5)))
                 row-centers))
  )

  ;; 4. 当前屏幕可视范围（模型空间当前视口）
  (setq vctr  (getvar "VIEWCTR")
        vsize (getvar "VIEWSIZE")
        ssize (getvar "SCREENSIZE")
        aspect (if (and (> (car ssize) 0) (> (cadr ssize) 0))
                 (/ (float (car ssize)) (cadr ssize))
                 1.0)
        vw    (* vsize aspect)
        vh    vsize
        cx    (car vctr)
        cy2   (cadr vctr)
        scr-xmin (- cx (/ vw 2.0))
        scr-xmax (+ cx (/ vw 2.0))
        scr-ymin (- cy2 (/ vh 2.0))
        scr-ymax (+ cy2 (/ vh 2.0)))

  ;; 5. 全库文字：只保留 屏幕内 + 参考文字所在行 + 左右各 1000 内
  (setq left  (max scr-xmin (- xmin 1000.0))
        right (min scr-xmax (+ xmax 1000.0))
        bottom scr-ymin
        top    scr-ymax
        found (ssadd))
  (setq ss (ssget "X" '((0 . "TEXT,MTEXT"))))
  (if ss
    (progn
      (setq j 0)
      (repeat (sslength ss)
        (setq e2  (ssname ss j)
              ed2 (entget e2)
              p2  (cdr (assoc 10 ed2)))
        (if p2
          (progn
            (setq x2 (car p2)
                  y2 (cadr p2))
            (if (and (<= left x2) (<= x2 right)
                     (<= bottom y2) (<= y2 top)
                     (vl-some
                       '(lambda (rt)
                          (<= (abs (- y2 (car rt))) (cadr rt)))
                       row-centers))
              (ssadd e2 found)
            )
          )
        )
        (setq j (1+ j))
      )
    )
  )

  ;; 6. 高亮选中结果
  (if (> (sslength found) 0)
    (progn
      (sssetfirst nil found)
      (princ (strcat "\r\n[QH] 已选中 " (itoa (sslength found))
                     " 个文字（参考文字所在行 · 当前屏幕内 · 左右各 1000 内）。")))
    (princ "\r\n[QH] 未找到同行文字。")
  )
  (princ)
)
(princ "\r\n[QH] 行内文字批量选择命令已加载，先选中文字再输入 QH 运行。")
(princ "\r\n[XX] 文字替换命令已加载，选中文字后输入 XX 运行。")
(princ)
;;; =======================================================================================
;;; 命令: BK
;;; 功能: 选中文字后，只保留最后一对括号（半角/全角均可）内的内容。
;;;       例: "至10kV 1#分段开关柜(10kV 1#分段隔离柜)" -> "至10kV 1#分段隔离柜"
;;;           "1-24S-901(2-11S-901)" -> "2-11S-901"
;;;           "至2#主变保护柜(故障录波柜)" -> "至故障录波柜"
;;; =======================================================================================
(defun bk:extract-inner (txt / pair posL posR openCh before inner)
  (setq pair (de:find-pair txt))
  (if pair
    (progn
      (setq posL   (nth 0 pair)
            posR   (nth 1 pair)
            openCh (nth 2 pair)
            before (substr txt 1 (1- posL))
            inner  (substr txt
                           (+ posL (strlen openCh) 1)
                           (- posR posL (strlen openCh))))
      (if (> (strlen inner) 0)
        (if (vl-string-search "至" before)
          (strcat "至" inner)
          inner)
        nil))
    nil)
)

(defun c:BK (/ *error* doc undo-open ss i ent txt new changed skipped)
  (vl-load-com)
  (setq doc       (vla-get-ActiveDocument (vlax-get-acad-object))
        undo-open nil)
  (defun *error* (msg)
    (if undo-open
      (de:end-undo doc))
    (if (and msg
             (not (member msg '("Function cancelled" "quit / exit abort" "console break"))))
      (princ (strcat "\r\n错误: " msg)))
    (princ)
  )
  (prompt "\r\n选择要提取括号内内容的文字 (TEXT/MTEXT/ATTRIB): ")
  (setq ss (ssget '((0 . "TEXT,MTEXT,ATTRIB"))))
  (if ss
    (progn
      (vl-catch-all-apply 'vla-StartUndoMark (list doc))
      (setq undo-open T
            i 0
            changed 0
            skipped 0)
      (while (< i (sslength ss))
        (setq ent (ssname ss i)
              txt (de:get-text ent)
              new (if txt (bk:extract-inner txt) nil))
        (cond
          ((or (null new) (= new txt)))
          ((de:set-text ent new)
           (setq changed (1+ changed)))
          (T
           (setq skipped (1+ skipped))))
        (setq i (1+ i))
      )
      (de:end-undo doc)
      (setq undo-open nil)
      (redraw)
      (princ (strcat "\r\n[BK] 已处理 " (itoa changed) " 个文字"))
      (if (> skipped 0)
        (princ (strcat "，" (itoa skipped) " 个文字写入失败")))
    )
    (princ "\r\n[BK] 未选中文字")
  )
  (princ)
)

(princ "\r\nAA整合版本已加载。")
(princ)

;;; HDDL 内置校核命令
;;; HDDL - 直接校核选中文字中的电缆编号（内置于 AA整合版本.lsp）
;;; 不依赖外部文件或其他 CAD 平台专有函数。

(defun hddl:ensure-layer (/)
  (if (not (tblsearch "LAYER" "HDDL_MARK"))
    (entmake '((0 . "LAYER") (100 . "AcDbSymbolTableRecord")
               (100 . "AcDbLayerTableRecord") (2 . "HDDL_MARK")
               (70 . 0) (62 . 1))))
  "HDDL_MARK")

(defun hddl:marker-selected-p (ed source-ss / data owner pt h rot dist anchor nearby i e hit)
  ;; 新标记以对象句柄关联源行，不按电缆编号匹配，避免不同表格互相清理。
  (setq data (assoc -3 ed))
  (if data
    (progn
      (setq owner (cdr (assoc 1005 (cdr (cadr data)))))
      (and owner (setq e (handent owner)) (ssmemb e source-ss)))
    (progn
      ;; 兼容旧标记：反算生成时的源文字插入点，再检查它是否在本次选择中。
      (setq pt (cdr (assoc 10 ed)) h (cdr (assoc 40 ed))
            rot (if (assoc 50 ed) (cdr (assoc 50 ed)) 0.0))
      (if (and pt h (> h 0.0) (assoc 1 ed))
        (progn
          (setq dist (* h (+ 2.0 (strlen (cdr (assoc 1 ed)))))
                anchor (list (+ (car pt) (* dist (cos rot)))
                             (+ (cadr pt) (* dist (sin rot)))
                             (if (caddr pt) (caddr pt) 0.0))
                nearby (ssget "_C"
                         (trans (mapcar '- anchor '(0.001 0.001 0.0)) 0 1)
                         (trans (mapcar '+ anchor '(0.001 0.001 0.0)) 0 1)
                         '((0 . "TEXT,MTEXT") (8 . "~HDDL_MARK")))
                i 0 hit nil)
          (if nearby
            (repeat (sslength nearby)
              (setq e (ssname nearby i))
              (if (and (ssmemb e source-ss)
                       (setq owner (entget e))
                       (equal (cdr (assoc 410 ed)) (cdr (assoc 410 owner)))
                       (equal anchor (cdr (assoc 10 owner)) 0.001))
                (setq hit T))
              (setq i (1+ i))))
          hit)))))

(defun hddl:clear-markers (source-ss / markers i e ed stale)
  ;; 只收集本次选中源文字的旧标记，再统一删除，保留其他堆的校核结果。
  (if (setq markers (ssget "_X" '((0 . "TEXT") (8 . "HDDL_MARK"))))
    (progn
      (setq i 0 stale nil)
      (repeat (sslength markers)
        (setq e (ssname markers i) ed (entget e '("HDDL_ROW")))
        (if (hddl:marker-selected-p ed source-ss) (setq stale (cons e stale)))
        (setq i (1+ i)))
      (foreach e stale (entdel e)))))

(defun hddl:text (ed)
  (aa:ysdl-get-plain-text ed))

(defun hddl:color (e c / d)
  (if (and (setq d (entget e))
           (or (assoc 420 d) (assoc 430 d) (not (equal (cdr (assoc 62 d)) c))))
    (progn
      (setq d (vl-remove-if '(lambda (x) (member (car x) '(420 430))) d))
      (if (assoc 62 d) (setq d (subst (cons 62 c) (assoc 62 d) d))
        (setq d (append d (list (cons 62 c)))))
      (entmod d))))

(defun hddl:coord (rec axis / p)
  (setq p (if (and rec (= (type rec) 'LIST)) (caddr rec) nil))
  (if (and p (= (type p) 'LIST) (numberp (car p)) (numberp (cadr p)))
    (if (= axis 0) (car p) (cadr p))
    0.0))

(defun hddl:point (p)
  (if (and p (= (type p) 'LIST) (numberp (car p)) (numberp (cadr p)))
    (list (car p) (cadr p) (if (numberp (caddr p)) (caddr p) 0.0))
    '(0.0 0.0 0.0)))

(defun hddl:skip (xs n / i)
  (setq i 0)
  (while (and xs (< i n) (= (type xs) 'LIST))
    (setq xs (cdr xs) i (1+ i)))
  (if (= (type xs) 'LIST) xs nil))

(defun hddl:item (xs n / i)
  (setq i 0)
  (while (and xs (< i n) (= (type xs) 'LIST))
    (setq xs (cdr xs) i (1+ i)))
  (if (and xs (= (type xs) 'LIST) (= i n)) (car xs) nil))

(defun hddl:row-sort (a b / ya yb xa xb)
  (setq ya (hddl:coord a 1) yb (hddl:coord b 1)
        xa (hddl:coord a 0) xb (hddl:coord b 0))
  (if (> ya (+ yb 1.0)) T
    (if (< ya (- yb 1.0)) nil (< xa xb))))

(defun hddl:insert-sorted (rec sorted / prefix)
  ;; 保持原逐项插入的比较次序，改为迭代，避免长行递归栈。
  (setq prefix nil)
  (while (and sorted (not (hddl:row-sort rec (car sorted))))
    (setq prefix (cons (car sorted) prefix) sorted (cdr sorted)))
  (append (reverse prefix) (cons rec sorted)))

(defun hddl:sort (items / result rec low high y)
  (setq result nil)
  (foreach rec items
    (setq y (hddl:coord rec 1)
          low (if low (min low y) y) high (if high (max high y) y)))
  ;; 只有全行 Y 跨度 <= 1 才可证明比较器退化成纯 X 的严格排序。
  (if (and low (<= (- high low) 1.0))
    (aa:merge-sort items 'hddl:row-sort)
    (progn
      (foreach rec items (setq result (hddl:insert-sorted rec result)))
      result)))

(defun hddl:add-row (rec rows / prefix rest row hit y)
  ;; 固定首项代表点，命中后只重建前缀；不再在每一行反复 append。
  (setq y (hddl:coord rec 1) prefix nil rest rows hit nil)
  (while (and rest (not hit))
    (setq row (car rest))
    (if (<= (abs (- y (hddl:coord (car row) 1))) 1.0)
      (setq hit T)
      (setq prefix (cons row prefix) rest (cdr rest))))
  (if hit
    (append (reverse prefix) (cons (append row (list rec)) (cdr rest)))
    (append (reverse prefix) (list (list rec)))))

(defun hddl:rows (items / packed rows rec)
  (setq packed (if (> (length items) 128)
                 (aa:gty-separated-rows items 1.0 nil)))
  (if packed
    (cadr packed)
    (progn
      (setq rows nil)
      (foreach rec items (setq rows (hddl:add-row rec rows)))
      rows)))

(defun hddl:sort-rows (rows / out row)
  (setq out nil)
  (foreach row rows (setq out (cons (hddl:sort row) out)))
  (reverse out))

(defun hddl:group-rows (rows / pairs row id groups key members pair)
  ;; 稳定排序后顺序归组，替代逐行 assoc/subst 全表扫描。
  (setq pairs nil groups nil members nil key nil)
  (foreach row rows
    (setq id (strcase (hddl:cell row 1)))
    (if (/= id "") (setq pairs (cons (list id row) pairs))))
  (setq pairs (aa:merge-sort (reverse pairs) '(lambda (a b) (< (car a) (car b)))))
  (foreach pair pairs
    (if (and key (/= key (car pair)))
      (progn
        (setq groups (cons (cons key (reverse members)) groups) members nil)))
    (setq key (car pair) members (cons (cadr pair) members)))
  (if key (setq groups (cons (cons key (reverse members)) groups)))
  (reverse groups))

(defun hddl:make-marker (rec txt / ed pt h style rot layer dist p)
  (setq ed (entget (car rec))
        pt (caddr rec)
        h (cdr (assoc 40 ed))
        style (if (assoc 7 ed) (cdr (assoc 7 ed)) (getvar "TEXTSTYLE"))
        rot (if (assoc 50 ed) (cdr (assoc 50 ed)) 0.0)
        layer "HDDL_MARK")
  (if (or (null h) (<= h 0.0)) (setq h (getvar "TEXTSIZE")))
  (if (or (null h) (<= h 0.0)) (setq h 2.5))
  (setq dist (* h (+ 2.0 (strlen txt)))
        p (list (- (car pt) (* dist (cos rot)))
                (- (cadr pt) (* dist (sin rot)))
                (if (caddr pt) (caddr pt) 0.0)))
  (regapp "HDDL_ROW")
  (entmakex (list '(0 . "TEXT") (cons 8 layer) (cons 10 p) (cons 40 h)
                  (cons 1 txt) (cons 7 style) (cons 50 rot) '(62 . 1)
                  (list -3 (list "HDDL_ROW" (cons 1005 (cdr (assoc 5 ed))))))))

(defun hddl:tail-duplicate-p (row / rest seen v hit one)
  ;; 第 6 列起是原理号；芯数不参与原理号重复判断。
  (setq rest (hddl:skip row 5) seen '() hit nil)
  (while (and rest (not hit))
    (setq one (car rest)
          v (if (and (= (type one) 'LIST) (cdr one))
              (vl-string-trim " \t" (cadr one)) ""))
    (if (and (/= v "") (member (strcase v) seen)) (setq hit T))
    (if (/= v "") (setq seen (cons (strcase v) seen)))
    (setq rest (cdr rest)))
  hit)

(defun hddl:cell (row n)
  (if (setq row (hddl:item row n))
    (if (and (= (type row) 'LIST) (cdr row))
      (vl-string-trim " \t" (cadr row)) "")
    ""))

(defun hddl:tail-count (row / rest n v one rec)
  (setq rest (hddl:skip row 4) n 0)
  (foreach rec rest
    (setq one rec
          v (if (and (= (type one) 'LIST) (cdr one))
              (vl-string-trim " \t" (cadr one)) ""))
    (if (/= v "") (setq n (1+ n))))
  n)

(defun hddl:color-cell (row n / rec)
  (if (setq rec (hddl:item row n))
    (if (car rec) (hddl:color (car rec) 1)))
  nil)

(defun hddl:color-core-count-diff (a b)
  ;; 原理号数量不一致时，标红两行对应的电缆芯数。
  (hddl:color-cell a 4)
  (hddl:color-cell b 4))

(defun hddl:color-cabinet-diffs (a b / a0 a2 b0 b2)
  ;; 镜像端点柜名不匹配时，只标红不相等的柜名文字。
  (setq a0 (hddl:cabinet (hddl:cell a 0))
        a2 (hddl:cabinet (hddl:cell a 2))
        b0 (hddl:cabinet (hddl:cell b 0))
        b2 (hddl:cabinet (hddl:cell b 2)))
  (if (/= a0 b2)
    (progn (hddl:color-cell a 0) (hddl:color-cell b 2)))
  (if (/= a2 b0)
    (progn (hddl:color-cell a 2) (hddl:color-cell b 0))))

(defun hddl:color-tail-duplicates (row / i j value other)
  ;; 同一行重复的原理号双方都标红，其他字段保持原色。
  (setq i 5)
  (while (hddl:item row i)
    (setq value (strcase (hddl:cell row i)) j 5)
    (while (< j i)
      (setq other (strcase (hddl:cell row j)))
      (if (and (/= value "") (= value other))
        (progn (hddl:color-cell row i) (hddl:color-cell row j)))
      (setq j (1+ j)))
    (setq i (1+ i))))

(defun hddl:tail-values (row / i value values)
  ;; 第 6 列起收集非空原理号；沿用去首尾空白、忽略大小写的规则。
  (setq i 5 values nil)
  (while (hddl:item row i)
    (setq value (strcase (hddl:cell row i)))
    (if (/= value "") (setq values (cons value values)))
    (setq i (1+ i)))
  values)

(defun hddl:tail-different-p (a b / av bv value hit)
  ;; 原理号按内容比对，排列顺序不同不算问题；行内重复另行检查。
  (setq av (hddl:tail-values a) bv (hddl:tail-values b)
        hit (/= (length av) (length bv)))
  (foreach value av
    (if (not (member value bv)) (setq hit T)))
  (foreach value bv
    (if (not (member value av)) (setq hit T)))
  hit)

(defun hddl:color-tail-diffs (row other / pair current values i value rec)
  ;; 两行分别只标红在另一行中找不到的原理号，不按列位置标红。
  (foreach pair (list (list row other) (list other row))
    (setq current (car pair) values (hddl:tail-values (cadr pair)) i 5)
    (while (setq rec (hddl:item current i))
      (setq value (strcase (hddl:cell current i)))
      (if (and (/= value "") (not (member value values)) (car rec))
        (hddl:color (car rec) 1))
      (setq i (1+ i)))))

(defun hddl:cabinet (s / blank z-len)
  ;; 柜名比较忽略内部空白，不修改图中原文字。核对时一律先去掉空格再对比。
  (setq s (if s s ""))
  (foreach blank (list " " "\t" "\r" "\n" "　" (chr 160) (vl-list->string '(194 160)))
    (while (vl-string-search blank s)
      (setq s (vl-string-subst "" blank s))))
  ;; “至”表示到达方向，不属于柜名；比较镜像端点时统一去掉开头的“至”前缀（兼容不同字符编码字节数）
  (setq z-len (strlen "至"))
  (while (and (>= (strlen s) z-len)
              (= (substr s 1 z-len) "至"))
    (setq s (substr s (1+ z-len))))
  (strcase s))

(defun hddl:mirror-p (a b)
  (and (= (strcase (hddl:cabinet (hddl:cell a 0)))
          (strcase (hddl:cabinet (hddl:cell b 2))))
       (= (strcase (hddl:cabinet (hddl:cell a 2)))
          (strcase (hddl:cabinet (hddl:cell b 0))))))

(defun c:HDDL (/ aa:doc aa:undo-open ss i e d items sorted rows cur lasty rec row id groups grp
                 issue bad marker made mirror-ok olderr stage highlight-type group group-issue colored spec-diff)
  (setq olderr *error*)
  (defun *error* (msg)
    (aa:undo-mark-off)
    (if (and msg (/= (strcase msg) "FUNCTION CANCELLED"))
      (princ (strcat "\r\n[HDDL] 校核失败（阶段：" stage "）：" msg)))
    (setq *error* olderr)
    (princ))
  (aa:undo-mark-on)
  (princ "\r\n请选择要校核的 YSDL 文字: ")
  (if (setq ss (ssget '((0 . "TEXT,MTEXT") (8 . "~HDDL_MARK"))))
    (progn
      (setq stage "清理旧标记")
      (hddl:ensure-layer)
      (hddl:clear-markers ss)
      (setq stage "读取文字")
      (setq items '() i 0)
      (repeat (sslength ss)
        (setq e (ssname ss i) d (entget e))
        (setq items (cons (list e (hddl:text d) (hddl:point (cdr (assoc 10 d)))) items))
        (setq i (1+ i)))
      ;; 逐条按 Y 坐标归行，再只对每一行的小列表按 X 排序，避免大列表递归。
      (setq stage "按坐标分行" rows (hddl:sort-rows (hddl:rows items)))
      (setq stage "按电缆编号分组" groups (hddl:group-rows rows))
      (setq stage "检查编号、规格和原理号" bad 0 made 0)
      (foreach group groups
        (setq grp (cdr group) colored nil
              mirror-ok (and (= (length grp) 2) (hddl:mirror-p (car grp) (cadr grp)))
              spec-diff (and (= (length grp) 2)
                             (/= (strcase (hddl:cell (car grp) 3))
                                 (strcase (hddl:cell (cadr grp) 3))))
              group-issue
                (cond
                  ((and mirror-ok (/= (hddl:tail-count (car grp))
                                      (hddl:tail-count (cadr grp)))) 'core-count)
                  ((and mirror-ok (hddl:tail-different-p (car grp) (cadr grp))) 'principle)
                  ((and (= (length grp) 2) (not mirror-ok)) 'cabinet)
                  ((not mirror-ok) 'cable-id)))
        (foreach row grp
          (setq issue nil highlight-type nil)
          (cond
            ((hddl:tail-duplicate-p row)
             (setq issue "[原理号重复]" highlight-type 'duplicate-principle))
            ((= group-issue 'core-count)
             (setq issue "[原理号数量不一致]" highlight-type 'core-count))
            ((= group-issue 'principle)
             (setq issue "[原理号不一致]" highlight-type 'principle))
            ((= group-issue 'cabinet)
             (setq issue "[柜名不一致]" highlight-type 'cabinet))
            ((= group-issue 'cable-id)
             (setq issue "[电缆编号重复]" highlight-type 'cable-id)))
          ;; 规格单独检查，避免原理号或柜名问题遮蔽规格差异。
          (if spec-diff
            (progn
              (setq issue (strcat (if issue issue "") "[电缆规格不一致]"))
              (if (not (member 'spec colored))
                (progn
                  (hddl:color-cell (car grp) 3)
                  (hddl:color-cell (cadr grp) 3)
                  (setq colored (cons 'spec colored))))))
          (if issue
            (progn
              (setq bad (1+ bad))
              (if (and highlight-type
                       (or (= highlight-type 'duplicate-principle)
                           (= highlight-type 'cable-id)
                           (not (member highlight-type colored))))
                (progn
                  (setq colored (cons highlight-type colored))
                  (cond
                    ((= highlight-type 'duplicate-principle)
                     (hddl:color-tail-duplicates row))
                    ((= highlight-type 'core-count)
                     (hddl:color-core-count-diff (car grp) (cadr grp)))
                    ((= highlight-type 'principle)
                     (hddl:color-tail-diffs (car grp) (cadr grp)))
                    ((= highlight-type 'cabinet)
                     (hddl:color-cabinet-diffs (car grp) (cadr grp)))
                    (T (hddl:color-cell row 1)))))
              (setq marker (hddl:make-marker (car row) issue))
              (if marker (setq made (1+ made)))))))
      (setq stage "绘制问题标记")
      (redraw)
      (alert (strcat "HDDL 校核完成\r\n\r\n问题行: " (itoa bad)
                     "\r\n已生成红色标记: " (itoa made)
                     "\r\n\r\n规则：合法的起终点互换镜像行不标红，原理号排列顺序不影响校核；规格不一致会标红两端规格；同向重复、原理号数量不一致会标红芯数，柜名不一致会标红柜名，原理号内容不一致或重复会标红对应原理号。")))
      (princ "\r\n未选择文字。"))
  (aa:undo-mark-off)
  (setq *error* olderr)
  (princ))

;;;----------------------------------------------------------------------------------------
;;; CU / CD / CZ / CY：按 5 个单位的递增间距向指定方向复制
;;;----------------------------------------------------------------------------------------

(defun cu:copy-direction (axis direction / *error* doc undo-open ss count level i obj clone
                                     move-result copied failed offset delta)
  (vl-load-com)
  (setq doc (vla-get-ActiveDocument (vlax-get-acad-object))
        undo-open nil)
  (defun *error* (msg)
    (if undo-open
      (progn
        (vla-EndUndoMark doc)
        (setq undo-open nil)))
    (if (and msg
             (/= (strcase msg) "FUNCTION CANCELLED")
             (/= (strcase msg) "QUIT / EXIT ABORT"))
      (princ (strcat "\r\n复制失败: " msg)))
    (princ))
  (setq ss (ssget "_I"))
  (if (null ss)
    (progn
      (princ "\r\n请选择要复制的对象: ")
      (setq ss (ssget))))
  (if ss
    (progn
      (initget 6)
      (setq count (getint "\r\n请输入复制份数（每份间距为 5）: "))
      (if count
        (progn
          (vla-StartUndoMark doc)
          (setq undo-open T
                copied 0
                failed 0
                level 1)
          (repeat count
            (setq offset (* direction 5.0 level)
                  delta (trans (if (= axis 'x) (list offset 0.0 0.0) (list 0.0 offset 0.0)) 1 0 T)
                  i 0)
            (repeat (sslength ss)
              (setq obj (vlax-ename->vla-object (ssname ss i))
                    clone (vl-catch-all-apply 'vla-Copy (list obj)))
              (if (vl-catch-all-error-p clone)
                (setq failed (1+ failed))
                (progn
                  (setq move-result
                    (vl-catch-all-apply
                      'vla-Move
                      (list clone
                            (vlax-3d-point '(0.0 0.0 0.0))
                            (vlax-3d-point delta))))
                  (if (vl-catch-all-error-p move-result)
                    (progn
                      (vl-catch-all-apply 'vla-Delete (list clone))
                      (setq failed (1+ failed)))
                    (setq copied (1+ copied)))
                  (vlax-release-object clone)))
              (vlax-release-object obj)
              (setq i (1+ i)))
            (setq level (1+ level)))
          (vla-EndUndoMark doc)
          (setq undo-open nil)
          (redraw)
          (princ
            (strcat "\r\n完成：已复制 " (itoa copied) " 个对象"
                    (if (> failed 0)
                      (strcat "，失败 " (itoa failed) " 个。")
                      "。"))))))
    (princ "\r\n未选择对象。"))
  (princ))

;;; CU：将选中对象向上复制到 5、10、15……单位的位置。
(defun c:CU ()
  (cu:copy-direction 'y 1.0))

;;; CD：将选中对象向下复制到 5、10、15……单位的位置。
(defun c:CD ()
  (cu:copy-direction 'y -1.0))

;;; CZ：将选中对象向左复制到 5、10、15……单位的位置。
(defun c:CZ ()
  (cu:copy-direction 'x -1.0))

;;; CY：将选中对象向右复制到 5、10、15……单位的位置。
(defun c:CY ()
  (cu:copy-direction 'x 1.0))
;;; =======================================================================================
;;;              --- HS 命令: 选中物体单向横向缩放（宽度改变，高度不变） ---
;;; =======================================================================================

(setq *HS_Last_Scale* 1.0) ; (HS) 记录上次使用的横向缩放比例

(defun aa:hs-filter-unlocked (ss / out i ename layer-ent)
  ;; 过滤掉锁定图层上的对象，防止打包块或修改时报错
  (if ss
    (progn
      (setq out (ssadd))
      (setq i 0)
      (repeat (sslength ss)
        (setq ename (ssname ss i))
        (setq layer-ent (tblsearch "LAYER" (cdr (assoc 8 (entget ename)))))
        ;; 组码 70 的第 4 位 (4) 代表锁定图层
        (if (or (null layer-ent) (/= (logand (cdr (assoc 70 layer-ent)) 4) 4))
          (ssadd ename out)
        )
        (setq i (1+ i))
      )
      (if (> (sslength out) 0) out nil)
    )
  )
)

(defun aa:hs-get-ss-bbox (doc ss / i ename bbox min-pt max-pt all-min-x all-min-y all-max-x all-max-y)
  ;; 获取整个选择集在 WCS 下的整体包围盒
  (setq i 0)
  (repeat (sslength ss)
    (setq ename (ssname ss i))
    (setq bbox (aa:safe-get-bbox doc ename))
    (if bbox
      (progn
        (setq min-pt (car bbox)
              max-pt (cadr bbox))
        (setq all-min-x (if all-min-x (min all-min-x (car min-pt)) (car min-pt))
              all-min-y (if all-min-y (min all-min-y (cadr min-pt)) (cadr min-pt))
              all-max-x (if all-max-x (max all-max-x (car max-pt)) (car max-pt))
              all-max-y (if all-max-y (max all-max-y (cadr max-pt)) (cadr max-pt))
        )
      )
    )
    (setq i (1+ i))
  )
  (if (and all-min-x all-max-x)
    (list (list all-min-x all-min-y 0.0)
          (list all-max-x all-max-y 0.0))
    nil
  )
)

(defun c:HS (/ *error* aa:tag aa:doc aa:undo-open aa:old-cmdecho
               ss bbox wcs-min wcs-max def-base-wcs def-base cur-width
               base inp ref-len new-len scale ucs-pt1 ucs-pt2 ucs-angle
               last-ent blk-idx blkname blkDef cur-space blkRef blkEname new-ss blocks)
  (aa:cmd-begin "HS")
  (vl-load-com)
  (setvar "CMDECHO" 0)

  ;; 1. 优先读取预选集，无预选则交互选择
  (setq ss (ssget "_I"))
  (if (null ss)
    (progn
      (princ "\r\n请选择要横向缩放的对象: ")
      (setq ss (ssget ":L"))
    )
  )
  (setq ss (aa:hs-filter-unlocked ss))

  (if (null ss)
    (progn
      (princ "\r\n未选择有效对象，HS 已退出。")
      (aa:cmd-end)
    )
    (progn
      ;; 2. 计算包围盒与推荐基点
      (setq bbox (aa:hs-get-ss-bbox aa:doc ss))
      (if bbox
        (progn
          (setq wcs-min (car bbox)
                wcs-max (cadr bbox))
          ;; 默认基点取左侧中点 (WCS) 并转为当前 UCS
          (setq def-base-wcs (list (car wcs-min) (/ (+ (cadr wcs-min) (cadr wcs-max)) 2.0) 0.0))
          (setq def-base (trans def-base-wcs 0 1))
          (setq cur-width (abs (- (car (trans (list (car wcs-max) (cadr wcs-min) 0.0) 0 1))
                                  (car def-base))))
        )
        (progn
          (setq def-base '(0.0 0.0 0.0)
                cur-width 100.0)
        )
      )

      ;; 3. 拾取基点
      (setq base (getpoint def-base
                   (strcat "\r\n请指定横向缩放基点 <默认左侧 ("
                           (rtos (car def-base) 2 2) ","
                           (rtos (cadr def-base) 2 2) ")>: ")))
      (if (null base) (setq base def-base))

      ;; 4. 输入缩放比例或选择参照(R)
      (if (or (null *HS_Last_Scale*) (<= *HS_Last_Scale* 0.0))
        (setq *HS_Last_Scale* 1.0)
      )
      (initget "Reference R")
      (setq inp (getdist base
                  (strcat "\r\n指定横向缩放比例 或 [参照(R)] <"
                          (rtos *HS_Last_Scale* 2 4) ">: ")))
      (cond
        ;; 参照模式
        ((or (= inp "Reference") (= inp "R"))
         (initget 6) ; 参照长度不可为 0 或负数
         (setq ref-len (getdist base
                         (strcat "\r\n指定参照长度 <" (rtos cur-width 2 4) ">: ")))
         (if (null ref-len) (setq ref-len cur-width))
         (if (and ref-len (> ref-len 1e-6))
           (progn
             (initget 7) ; 新长度不可为 0、负数或空
             (setq new-len (getdist base "\r\n指定新长度: "))
             (setq scale (/ new-len ref-len))
             (princ (strcat "\r\n计算所得横向缩放比例为: " (rtos scale 2 6)))
           )
           (setq scale nil)
         )
        )
        ;; 用户直接回车默认值
        ((null inp)
         (setq scale *HS_Last_Scale*))
        ;; 用户直接输入了数字或点取了两点距离
        ((numberp inp)
         (setq scale inp))
        (t (setq scale nil))
      )

      (cond
        ((or (null scale) (<= scale 1e-6))
         (princ "\r\n缩放比例无效或过小，HS 已取消。")
         (aa:cmd-end)
        )
        ((equal scale 1.0 1e-6)
         (princ "\r\n横向缩放比例为 1，对象未改变。")
         (aa:cmd-end)
        )
        (t
         (setq *HS_Last_Scale* scale)

         ;; 5. 处理当前 UCS 旋转：若 UCS 存在旋转角，临时将物体对齐到世界坐标系
         (setq ucs-pt1 (trans '(0.0 0.0 0.0) 1 0))
         (setq ucs-pt2 (trans '(1.0 0.0 0.0) 1 0))
         (setq ucs-angle (angle ucs-pt1 ucs-pt2))
         (if (> (abs ucs-angle) 1e-6)
           (command "_.ROTATE" ss "" "_non" base (angtos (- ucs-angle) (getvar "AUNITS") 8))
         )

         ;; 6. 创建临时块并打散
         (setq last-ent (entlast))
         (setq blk-idx 0)
         (while (tblsearch "BLOCK" (setq blkname (strcat "HS_TMP_" (itoa blk-idx))))
           (setq blk-idx (1+ blk-idx))
         )

         ;; 打包成临时块
         (command "_.BLOCK" blkname "_non" base ss "")

         ;; 设置该块定义允许分解
         (setq blocks (vla-get-blocks aa:doc))
         (setq blkDef (vla-item blocks blkname))
         (vl-catch-all-apply 'vla-put-explodable (list blkDef :vlax-true))
         (vlax-release-object blkDef)
         (vlax-release-object blocks)

         ;; 插入带非等比比例 (scale, 1.0, 1.0) 的块引用
         (setq cur-space (if (= (getvar "CVPORT") 1)
                           (vla-get-PaperSpace aa:doc)
                           (vla-get-ModelSpace aa:doc)))
         (setq blkRef (vl-catch-all-apply
                        'vlax-invoke
                        (list cur-space 'InsertBlock (trans base 1 0) blkname scale 1.0 1.0 0.0)))
         (vlax-release-object cur-space)

         ;; 分解该块引用
         (if (and blkRef (not (vl-catch-all-error-p blkRef)))
           (progn
             (setq blkEname (vlax-vla-object->ename blkRef))
             (vlax-release-object blkRef)
             (command "_.EXPLODE" blkEname)
           )
           (progn
             ;; 降级调用命令行插入
             (command "_.-INSERT" blkname "_non" base scale 1.0 0.0)
             (command "_.EXPLODE" (entlast))
           )
         )

         ;; 追踪打散生成的新实体
         (setq new-ss (ssadd))
         (while (setq last-ent (entnext last-ent))
           (if (entget last-ent)
             (ssadd last-ent new-ss)
           )
         )

         ;; 清理临时块定义
         (vl-catch-all-apply
           '(lambda ()
              (vla-delete (vla-item (vla-get-blocks aa:doc) blkname))
            )
         )

         ;; 7. 若之前补偿了 UCS 旋转，此时旋转还原
         (if (and (> (abs ucs-angle) 1e-6) (> (sslength new-ss) 0))
           (command "_.ROTATE" new-ss "" "_non" base (angtos ucs-angle (getvar "AUNITS") 8))
         )

         (redraw)
         (sssetfirst nil nil)
         (princ (strcat "\r\nHS 完成：已将 " (itoa (sslength new-ss))
                        " 个对象横向缩放 " (rtos scale 2 4) " 倍（高度保持不变）。"))
         (aa:cmd-end)
        )
      )
    )
  )
)

;;; =======================================================================================
;;;              --- ZS 命令: 选中物体单向纵向缩放（高度改变，宽度不变） ---
;;; =======================================================================================

(setq *ZS_Last_Scale* 1.0) ; (ZS) 记录上次使用的纵向缩放比例

;;; ZS：选中物体单向纵向缩放，上下高度改变，宽度保持不变。
(defun c:ZS (/ *error* aa:tag aa:doc aa:undo-open aa:old-cmdecho
               ss bbox wcs-min wcs-max def-base-wcs def-base cur-height
               base inp ref-len new-len scale ucs-pt1 ucs-pt2 ucs-angle
               last-ent blk-idx blkname blkDef cur-space blkRef blkEname new-ss blocks)
  (aa:cmd-begin "ZS")
  (vl-load-com)
  (setvar "CMDECHO" 0)

  ;; 1. 优先读取预选集，无预选则交互选择
  (setq ss (ssget "_I"))
  (if (null ss)
    (progn
      (princ "\r\n请选择要纵向缩放的对象: ")
      (setq ss (ssget ":L"))
    )
  )
  (setq ss (aa:hs-filter-unlocked ss))

  (if (null ss)
    (progn
      (princ "\r\n未选择有效对象，ZS 已退出。")
      (aa:cmd-end)
    )
    (progn
      ;; 2. 计算包围盒与推荐基点
      (setq bbox (aa:hs-get-ss-bbox aa:doc ss))
      (if bbox
        (progn
          (setq wcs-min (car bbox)
                wcs-max (cadr bbox))
          ;; 默认基点取底部中点 (WCS) 并转为当前 UCS
          (setq def-base-wcs (list (/ (+ (car wcs-min) (car wcs-max)) 2.0) (cadr wcs-min) 0.0))
          (setq def-base (trans def-base-wcs 0 1))
          (setq cur-height (abs (- (cadr (trans (list (car wcs-min) (cadr wcs-max) 0.0) 0 1))
                                   (cadr def-base))))
        )
        (progn
          (setq def-base '(0.0 0.0 0.0)
                cur-height 100.0)
        )
      )

      ;; 3. 拾取基点
      (setq base (getpoint def-base
                   (strcat "\r\n请指定纵向缩放基点 <默认底部 ("
                           (rtos (car def-base) 2 2) ","
                           (rtos (cadr def-base) 2 2) ")>: ")))
      (if (null base) (setq base def-base))

      ;; 4. 输入缩放比例或选择参照(R)
      (if (or (null *ZS_Last_Scale*) (<= *ZS_Last_Scale* 0.0))
        (setq *ZS_Last_Scale* 1.0)
      )
      (initget "Reference R")
      (setq inp (getdist base
                  (strcat "\r\n指定纵向缩放比例 或 [参照(R)] <"
                          (rtos *ZS_Last_Scale* 2 4) ">: ")))
      (cond
        ;; 参照模式
        ((or (= inp "Reference") (= inp "R"))
         (initget 6) ; 参照长度不可为 0 或负数
         (setq ref-len (getdist base
                         (strcat "\r\n指定参照长度 <" (rtos cur-height 2 4) ">: ")))
         (if (null ref-len) (setq ref-len cur-height))
         (if (and ref-len (> ref-len 1e-6))
           (progn
             (initget 7) ; 新长度不可为 0、负数或空
             (setq new-len (getdist base "\r\n指定新长度: "))
             (setq scale (/ new-len ref-len))
             (princ (strcat "\r\n计算所得纵向缩放比例为: " (rtos scale 2 6)))
           )
           (setq scale nil)
         )
        )
        ;; 用户直接回车默认值
        ((null inp)
         (setq scale *ZS_Last_Scale*))
        ;; 用户直接输入了数字或点取了两点距离
        ((numberp inp)
         (setq scale inp))
        (t (setq scale nil))
      )

      (cond
        ((or (null scale) (<= scale 1e-6))
         (princ "\r\n缩放比例无效或过小，ZS 已取消。")
         (aa:cmd-end)
        )
        ((equal scale 1.0 1e-6)
         (princ "\r\n纵向缩放比例为 1，对象未改变。")
         (aa:cmd-end)
        )
        (t
         (setq *ZS_Last_Scale* scale)

         ;; 5. 处理当前 UCS 旋转：若 UCS 存在旋转角，临时将物体对齐到世界坐标系
         (setq ucs-pt1 (trans '(0.0 0.0 0.0) 1 0))
         (setq ucs-pt2 (trans '(1.0 0.0 0.0) 1 0))
         (setq ucs-angle (angle ucs-pt1 ucs-pt2))
         (if (> (abs ucs-angle) 1e-6)
           (command "_.ROTATE" ss "" "_non" base (angtos (- ucs-angle) (getvar "AUNITS") 8))
         )

         ;; 6. 创建临时块并打散
         (setq last-ent (entlast))
         (setq blk-idx 0)
         (while (tblsearch "BLOCK" (setq blkname (strcat "ZS_TMP_" (itoa blk-idx))))
           (setq blk-idx (1+ blk-idx))
         )

         ;; 打包成临时块
         (command "_.BLOCK" blkname "_non" base ss "")

         ;; 设置该块定义允许分解
         (setq blocks (vla-get-blocks aa:doc))
         (setq blkDef (vla-item blocks blkname))
         (vl-catch-all-apply 'vla-put-explodable (list blkDef :vlax-true))
         (vlax-release-object blkDef)
         (vlax-release-object blocks)

         ;; 插入带非等比比例 (1.0, scale, 1.0) 的块引用
         (setq cur-space (if (= (getvar "CVPORT") 1)
                           (vla-get-PaperSpace aa:doc)
                           (vla-get-ModelSpace aa:doc)))
         (setq blkRef (vl-catch-all-apply
                        'vlax-invoke
                        (list cur-space 'InsertBlock (trans base 1 0) blkname 1.0 scale 1.0 0.0)))
         (vlax-release-object cur-space)

         ;; 分解该块引用
         (if (and blkRef (not (vl-catch-all-error-p blkRef)))
           (progn
             (setq blkEname (vlax-vla-object->ename blkRef))
             (vlax-release-object blkRef)
             (command "_.EXPLODE" blkEname)
           )
           (progn
             ;; 降级调用命令行插入
             (command "_.-INSERT" blkname "_non" base 1.0 scale 0.0)
             (command "_.EXPLODE" (entlast))
           )
         )

         ;; 追踪打散生成的新实体
         (setq new-ss (ssadd))
         (while (setq last-ent (entnext last-ent))
           (if (entget last-ent)
             (ssadd last-ent new-ss)
           )
         )

         ;; 清理临时块定义
         (vl-catch-all-apply
           '(lambda ()
              (vla-delete (vla-item (vla-get-blocks aa:doc) blkname))
            )
         )

         ;; 7. 若之前补偿了 UCS 旋转，此时旋转还原
         (if (and (> (abs ucs-angle) 1e-6) (> (sslength new-ss) 0))
           (command "_.ROTATE" new-ss "" "_non" base (angtos ucs-angle (getvar "AUNITS") 8))
         )

         (redraw)
         (sssetfirst nil nil)
         (princ (strcat "\r\nZS 完成：已将 " (itoa (sslength new-ss))
                        " 个对象纵向缩放 " (rtos scale 2 4) " 倍（宽度保持不变）。"))
         (aa:cmd-end)
        )
      )
    )
  )
)

;;; =======================================================================================
;;;              --- SC3 命令: 将选中对象整体缩小到 A3 尺寸范围 ---
;;; =======================================================================================

(defun aa:sc3-layer-locked-p (ename / ed layer layer-data)
  ;; 锁定图层上的对象不能可靠地整体缩放，检测到时整批取消。
  (setq ed (entget ename)
        layer (if ed (cdr (assoc 8 ed))))
  (and layer
       (setq layer-data (tblsearch "LAYER" layer))
       (/= 0 (logand 4 (cdr (assoc 70 layer-data))))))

(defun aa:sc3-entity-bbox (ename / obj min-pt max-pt result out)
  ;; 返回实体的 WCS 包围框，只保留 X/Y 范围；无法取得时返回 nil。
  (setq obj    (vlax-ename->vla-object ename)
        result (vl-catch-all-apply 'vla-getboundingbox
                                   (list obj 'min-pt 'max-pt)))
  (setq out
    (if (or (vl-catch-all-error-p result)
            (null min-pt)
            (null max-pt))
      nil
      (progn
        (setq min-pt (vlax-safearray->list min-pt)
              max-pt (vlax-safearray->list max-pt))
        (list (car min-pt) (cadr min-pt)
              (car max-pt) (cadr max-pt)))))
  (vlax-release-object obj)
  out)

(defun c:SC3 (/ *error* aa:tag aa:doc aa:undo-open aa:old-cmdecho
              ss i ename bbox all-min-x all-min-y all-max-x all-max-y
              length width scale center blocked margin max-length max-width)
  (aa:cmd-begin "SC3")
  (setvar "CMDECHO" 0)
  (setq margin     5.0
        max-length (- 420.0 (* 2.0 margin))
        max-width  (- 297.0 (* 2.0 margin)))
  (setq ss (ssget "_I"))
  (if (null ss)
    (progn
      (princ "\r\n请选择要缩小到 A3 尺寸范围的对象：")
      (setq ss (ssget))))
  (if (null ss)
    (princ "\r\n未选择对象，SC3 已取消。")
    (progn
      ;; 先完整检查图层和包围框，避免只缩放选区中的一部分。
      (setq i 0)
      (while (and (< i (sslength ss)) (null blocked))
        (setq ename (ssname ss i))
        (cond
          ((aa:sc3-layer-locked-p ename)
           (setq blocked "选区包含锁定图层对象，请先解锁后重试。"))
          ((null (setq bbox (aa:sc3-entity-bbox ename)))
           (setq blocked "选区中有无法取得包围框的对象，本次未缩放。"))
          (T
           (setq all-min-x (if all-min-x (min all-min-x (nth 0 bbox)) (nth 0 bbox))
                 all-min-y (if all-min-y (min all-min-y (nth 1 bbox)) (nth 1 bbox))
                 all-max-x (if all-max-x (max all-max-x (nth 2 bbox)) (nth 2 bbox))
                 all-max-y (if all-max-y (max all-max-y (nth 3 bbox)) (nth 3 bbox)))))
        (setq i (1+ i)))
      (if blocked
        (princ (strcat "\r\n" blocked))
        (progn
          (setq length (abs (- all-max-x all-min-x))
                width  (abs (- all-max-y all-min-y))
                scale 1.0)
          (if (> length max-length)
            (setq scale (min scale (/ max-length length))))
          (if (> width max-width)
            (setq scale (min scale (/ max-width width))))
          (if (equal scale 1.0 1e-10)
            (progn
              (sssetfirst nil ss)
              (princ (strcat "\r\nSC3 未缩放：当前整体尺寸为 "
                             (rtos length 2 3) " × "
                              (rtos width 2 3) "，已在 "
                              (rtos max-length 2 3) " × "
                              (rtos max-width 2 3) " 范围内。")))
            (progn
              (setq center
                    (list (/ (+ all-min-x all-max-x) 2.0)
                          (/ (+ all-min-y all-max-y) 2.0)
                          0.0))
              (vl-cmdf "_.SCALE" ss "" "_non" (trans center 0 1) scale)
              (redraw)
              (sssetfirst nil ss)
              (princ (strcat "\r\nSC3 完成：原整体尺寸为 "
                             (rtos length 2 3) " × "
                             (rtos width 2 3)
                             "，缩放比例为 "
                             (rtos scale 2 6)
                             "，目标范围为 "
                             (rtos max-length 2 3) " × "
                             (rtos max-width 2 3)
                             "（四周留 " (rtos margin 2 3) "mm）。"))))))))
  (aa:cmd-end)
  (princ))

;;; =======================================================================================
;;; 命令: Z0
;;; 功能: 将选中对象的 Z 坐标全部归零（压平到 XY 平面）。
;;; =======================================================================================
(defun aa:z0-layer-locked-p (lname / layer-data)
  ;; 图层表组码 70 的第 3 位 (4) 表示锁定
  (and lname
       (setq layer-data (tblsearch "LAYER" lname))
       (/= 0 (logand 4 (cdr (assoc 70 layer-data))))))

(defun aa:z0-zero-pair (pair / code value)
  ;; 点组码的第三个分量是 Z；独立的 30-38 组码同样归零。
  (setq code  (car pair)
        value (cdr pair))
  (cond
    ((and (integerp code) (>= code 10) (<= code 18)
          (listp value) (>= (length value) 3))
     (list code (nth 0 value) (nth 1 value) 0.0))
    ((and (integerp code) (>= code 30) (<= code 38))
     (cons code 0.0))
    (T pair)))

(defun aa:z0-data-flat-p (data / pair flat)
  (setq flat T)
  (foreach pair data
    (if (and (consp pair)
             (integerp (car pair))
             (or (and (>= (car pair) 30) (<= (car pair) 38)
                      (/= (cdr pair) 0.0))
                 (and (>= (car pair) 10) (<= (car pair) 18)
                      (listp (cdr pair)) (>= (length (cdr pair)) 3)
                      (/= (nth 2 (cdr pair)) 0.0))))
      (setq flat nil)))
  flat)

(defun aa:z0-one (ename / ed ok)
  ;; 将单个实体 DXF 中的 Z/标高置 0；返回 T 表示已压平
  (setq ed (entget ename)
        ok nil)
  (if (null ed)
    nil
    (progn
      (if (aa:z0-data-flat-p ed)
        (setq ok T)
        (setq ok (if (entmod (mapcar 'aa:z0-zero-pair ed)) T nil)))
      ok)))

(defun aa:z0-polyline-verts (pline / v)
  ;; 旧式 POLYLINE 的各 VERTEX 一并归零
  (setq v (entnext pline))
  (while (and v (= "VERTEX" (cdr (assoc 0 (entget v)))))
    (aa:z0-one v)
    (setq v (entnext v)))
  T)

(defun aa:z0-polyline-flat-p (pline / v ed flat)
  ;; 顶点链全部已在平面时才视为已压平
  (setq flat T
        v    (entnext pline))
  (while (and v (= "VERTEX" (cdr (assoc 0 (setq ed (entget v))))))
    (if (not (aa:z0-data-flat-p ed))
      (setq flat nil))
    (setq v (entnext v)))
  flat)

(defun c:Z0 (/ *error* aa:tag aa:doc aa:undo-open aa:old-cmdecho
               ss i ename ed typ changed flat locked failed)
  (aa:cmd-begin "Z0")
  (setq changed 0
        flat    0
        locked  0
        failed  0)
  (setq ss (ssget "_I"))
  (if (null ss)
    (progn
      (princ "\r\n请选择要把 Z 坐标归零的对象：")
      (setq ss (ssget ":L"))))
  (if (null ss)
    (princ "\r\n未选择对象。")
    (progn
      (setq i 0)
      (repeat (sslength ss)
        (setq ename (ssname ss i)
              ed     (entget ename)
              typ    (cdr (assoc 0 ed)))
        (cond
          ((null ed)
           (setq failed (1+ failed)))
          ((aa:z0-layer-locked-p (cdr (assoc 8 ed)))
           (setq locked (1+ locked)))
          ((and (aa:z0-data-flat-p ed)
                (or (/= typ "POLYLINE")
                    (aa:z0-polyline-flat-p ename)))
           (setq flat (1+ flat)))
          ((aa:z0-one ename)
           (setq changed (1+ changed))
           (if (= typ "POLYLINE")
             (aa:z0-polyline-verts ename)))
          (T
           (setq failed (1+ failed))))
        (setq i (1+ i)))
      (redraw)
      (princ
        (strcat
          "\r\nZ0 完成：已归零 " (itoa changed) " 个"
          "，原本已是平面 " (itoa flat) " 个"
          "，锁定图层跳过 " (itoa locked) " 个"
          "，无法修改 " (itoa failed) " 个。"))))
  (aa:cmd-end))

;;;----------------------------------------------------------------------------------------
;;; VPO1 / VPO2 : 视口切换命令
;;;----------------------------------------------------------------------------------------
;;; VPO1 : 切换到“单个”标准视口
(defun c:VPO1 (/ *error* aa:tag aa:doc aa:undo-open aa:old-cmdecho)
  (aa:cmd-begin "VPO1")
  (setvar "CMDECHO" 0)
  (vl-cmdf "_.vports" "_single")
  (princ "\r\n已切换到单个标准视口。")
  (aa:cmd-end))

;;; VPO2 : 切换到“两个：垂直”标准视口
(defun c:VPO2 (/ *error* aa:tag aa:doc aa:undo-open aa:old-cmdecho)
  (aa:cmd-begin "VPO2")
  (setvar "CMDECHO" 0)
  (vl-cmdf "_.vports" "_2" "_vertical")
  (princ "\r\n已切换到两个垂直标准视口。")
  (aa:cmd-end))

;;;----------------------------------------------------------------------------------------
;;; TONG : 框选文字对象去重，按自然顺序从上到下排列在指定插入点
;;; 样式: HZ, 字高: 3.0, 宽比: 0.7, 颜色: 白色(7), 行距: 5.0, 对正: 左对齐
;;;----------------------------------------------------------------------------------------
(defun c:TONG (/ *error* aa:tag aa:doc aa:undo-open aa:old-cmdecho
                 ss i ename edata raw-str val unique-list sorted-list
                 pt pt-wcs cur-pt count sty-name txt)
  (aa:cmd-begin "TONG")
  (princ "\r\n选择要统计去重的文字对象: ")
  (setq ss (ssget '((0 . "TEXT,MTEXT"))))
  (if (not ss)
    (progn
      (princ "\r\n未选择任何文字对象。")
      (aa:cmd-end)
    )
    (progn
      ;; 提取所有文字内容并去重
      (setq unique-list '()
            i 0)
      (repeat (sslength ss)
        (setq ename (ssname ss i)
              edata (entget ename)
              raw-str (cdr (assoc 1 edata)))
        ;; 去除首尾空白
        (if raw-str
          (setq val (vl-string-trim " \t\r\n" raw-str))
          (setq val "")
        )
        (if (and (/= val "") (not (member val unique-list)))
          (setq unique-list (cons val unique-list))
        )
        (setq i (1+ i))
      )

      (if (null unique-list)
        (progn
          (princ "\r\n所选对象中无有效文字。")
          (aa:cmd-end)
        )
        (progn
          ;; 自然排序 (A-Z, 1-9)
          (setq sorted-list
            (aa:merge-sort
              unique-list
              '(lambda (a b) (aa:gtx-natural-less a b))))

          (princ (strcat "\r\n共提取去重后 " (itoa (length sorted-list)) " 个不同文字。"))
          (setq pt (getpoint "\r\n请指定放置起点 (从上到下排列): "))
          (if (not pt)
            (progn
              (princ "\r\n已取消指定点。")
              (aa:cmd-end)
            )
            (progn
              ;; 确保样式存在，优先 HZ，没有则使用当前样式
              (if (tblsearch "STYLE" "HZ")
                (setq sty-name "HZ")
                (setq sty-name (getvar "TEXTSTYLE"))
              )
              ;; 转换当前 UCS 点到 WCS
              (setq pt-wcs (trans pt 1 0)
                    count  0)
              (foreach txt sorted-list
                (setq cur-pt (list (car pt-wcs)
                                   (- (cadr pt-wcs) (* count 5.0))
                                   (caddr pt-wcs)))
                (entmake
                  (list
                    '(0 . "TEXT")
                    (cons 10 cur-pt)
                    (cons 40 3.0)
                    (cons 41 0.7)
                    (cons 1 txt)
                    (cons 7 sty-name)
                    '(62 . 7)
                    (cons 8 (getvar "CLAYER"))))
                (setq count (1+ count))
              )
              (redraw)
              (princ (strcat "\r\n[TONG] 成功生成 " (itoa count) " 个去重文字（样式: " sty-name "，高: 3.0，宽比: 0.7，白色，间距: 5.0）。"))
              (aa:cmd-end)
            )
          )
        )
      )
    )
  )
  (princ)
)

;;; =======================================================================================
;;; BEGIN ZDDL2: 端子排直接根据接线方格自动出线与标注
;;; =======================================================================================
;;; 命令: ZDDL2
;;; 功能: 框选现有端子排与 100×100 接线方格，自动在端子排下方（或上方）绘制电缆引出线、
;;;       转折斜短线、水平电缆干线、三角指示标、电缆编号、至去向柜文字，并可选回写原理号。

(defun zddl:is-numeric-p (str / i c ok)
  (if (and str (/= str ""))
    (progn
      (setq i 1 ok T)
      (while (and (<= i (strlen str)) ok)
        (setq c (ascii (substr str i 1)))
        (if (not (or (and (>= c 48) (<= c 57)) (= c 46)))
          (setq ok nil))
        (setq i (1+ i)))
      ok)
    nil)
)

(defun zddl:clean-ref (str / p)
  (if (setq p (vl-string-search ":" str))
    (list (substr str 1 p) (substr str (+ p 2)))
    (list "" str))
)

(defun zddl:find-block-for-x (sorted-blocks x / blk-name blk)
  (setq blk-name (car (car sorted-blocks)))
  (foreach blk sorted-blocks
    (if (<= (cadr blk) (+ x 0.1))
      (setq blk-name (car blk))))
  blk-name
)

(defun zddl:text-point (ent ed / typ pt ha va)
  (setq typ (cdr (assoc 0 ed))
        pt  (cdr (assoc 10 ed)))
  ;; MTEXT 的 11 是方向向量；TEXT 仅在实际启用对齐时使用 11。
  ;; Aligned/Fit 的 10、11 是基线两端，仍使用 10 作为文字定位点。
  (if (= typ "TEXT")
    (progn
      (setq ha (cdr (assoc 72 ed))
            va (cdr (assoc 73 ed)))
      (if (and (assoc 11 ed)
               (not (member ha '(3 5)))
               (or (and ha (/= ha 0)) (and va (/= va 0))))
        (setq pt (cdr (assoc 11 ed))))
      (if pt (setq pt (trans pt ent 0)))))
  pt
)

;; 返回文字所在格的 (中心X 底Y 顶Y 左X 右X)，不限制文字位于中带。
(defun zddl:bounds-for-point (verticals x y / v left right bot top)
  (foreach v verticals
    (if (and (> y (+ (cadr v) 0.05)) (< y (- (caddr v) 0.05)))
      (progn
        (if (<= (car v) x)
          (cond
            ((or (null left) (> (car v) (car left))) (setq left v))
            ((= (car v) (car left))
             (setq left (list (car left) (max (cadr left) (cadr v))
                              (min (caddr left) (caddr v)))))))
        (if (> (car v) x)
          (cond
            ((or (null right) (< (car v) (car right))) (setq right v))
            ((= (car v) (car right))
             (setq right (list (car right) (max (cadr right) (cadr v))
                               (min (caddr right) (caddr v))))))))))
  (if (and left right)
    (progn
      (setq bot (max (cadr left) (cadr right))
            top (min (caddr left) (caddr right)))
      (if (> (- top bot) 0.1)
        (list (/ (+ (car left) (car right)) 2.0) bot top (car left) (car right))))))

;; 端子号须位于各自格的中带；允许缩放后小于 8 的端子格。
(defun zddl:cell-for-point (verticals x y / cell bot top)
  (if (setq cell (zddl:bounds-for-point verticals x y))
    (progn
      (setq bot (nth 1 cell) top (nth 2 cell))
      (if (and (>= y (+ bot (* 0.3 (- top bot))))
               (<= y (- top (* 0.3 (- top bot)))))
        cell))))

;; 同一列边框可由多段组成，只扩展相接/重叠段，不跨越两行间的空白。
(defun zddl:column-span (verticals x bot top / v changed)
  (setq changed T)
  (while changed
    (setq changed nil)
    (foreach v verticals
      (if (and (equal x (car v) 0.05)
               (<= (cadr v) (+ top 0.05)) (>= (caddr v) (- bot 0.05)))
        (progn
          (if (< (cadr v) bot) (setq bot (cadr v) changed T))
          (if (> (caddr v) top) (setq top (caddr v) changed T))))))
  (list bot top))

;; 带分隔符引用精确匹配；无分隔符引用对照已识别排名拼接，不能按数字拆分排名。
;; 例如 26TXD1 -> 26TXD:1；A:11 / A1:1 均对应 A11 时必须拒绝歧义。
(defun zddl:lookup-terminal (ref term-map / hit item parts suffix compact count)
  (setq ref (strcase (vl-string-trim " \t\r\n" ref))
        ref (vl-string-subst ":" "：" ref)
        hit (cdr (assoc ref term-map)))
  (if (and (null hit) (not (vl-string-search ":" ref)))
    (progn
      (setq count 0)
      (foreach item term-map
        (setq parts (zddl:clean-ref (strcase (car item)))
              suffix (cadr parts)
              compact (strcat (car parts) suffix))
        (if (or (= compact ref) (= suffix ref))
          (setq hit (cdr item) count (1+ count))))
      (if (/= count 1) (setq hit nil))))
  hit)

;; 真正横框的两端均落在竖框上；跨列短接线的端点在端子中心，不能切分文字格。
(defun zddl:grid-edge-p (h verticals / v first-hit last-hit)
  (foreach v verticals
    (if (and (<= (cadr v) (+ (car h) 0.05))
             (>= (caddr v) (- (car h) 0.05)))
      (progn
        (if (equal (car v) (cadr h) 0.05) (setq first-hit T))
        (if (equal (car v) (caddr h) 0.05) (setq last-hit T)))))
  (and first-hit last-hit))

;; 原理号只写入端子号中带外侧、紧邻的真实分格；不使用整排总高猜位置。
;; 返回 (下锚点 上锚点 下可用长度 上可用长度 下已有文字 上已有文字)。
(defun zddl:write-slots (horiz texts x y outer-bot outer-top left right
                         / h low high below above item lower-used upper-used border-gap changed)
  (foreach h horiz
    (if (and (<= (cadr h) (+ left 0.05)) (>= (caddr h) (- right 0.05)))
      (progn
        (if (and (< (car h) (- y 0.05)) (or (null low) (> (car h) low)))
          (setq low (car h)))
        (if (and (> (car h) (+ y 0.05)) (or (null high) (< (car h) high)))
          (setq high (car h))))))
  (if (and low high)
    (progn
      ;; 编号带可带 1mm 双横框；先合并贴近的框线，再寻找外侧文字格。
      ;; 容差随列宽缩放且不超过 1.5mm，不能把正常文字格跨过去。
      (setq border-gap (min 1.5 (* 0.25 (- right left))) changed T)
      (while changed
        (setq changed nil)
        (foreach h horiz
          (if (and (<= (cadr h) (+ left 0.05)) (>= (caddr h) (- right 0.05)))
            (progn
              (if (and (< (car h) (- low 0.05)) (<= (- low (car h)) border-gap))
                (setq low (car h) changed T))
              (if (and (> (car h) (+ high 0.05)) (<= (- (car h) high) border-gap))
                (setq high (car h) changed T))))))
      (setq below outer-bot above outer-top)
      (foreach h horiz
        (if (and (<= (cadr h) (+ left 0.05)) (>= (caddr h) (- right 0.05)))
          (progn
            (if (and (< (car h) (- low 0.05)) (> (car h) below)) (setq below (car h)))
            (if (and (> (car h) (+ high 0.05)) (< (car h) above)) (setq above (car h))))))
      (foreach item texts
        (if (and (> (cadr item) (+ left 0.05)) (< (cadr item) (- right 0.05)))
          (progn
            (if (and (> (caddr item) (+ below 0.05)) (< (caddr item) (- low 0.05)))
              (setq lower-used T))
            (if (and (> (caddr item) (+ high 0.05)) (< (caddr item) (- above 0.05)))
              (setq upper-used T)))))
      (list (+ below 2.0) (- above 2.0)
            (max 0.0 (- low below 4.0)) (max 0.0 (- above high 4.0)) lower-used upper-used))
    (list nil nil 0.0 0.0 T T)))

(defun zddl:parse-strip (ss / i ent ed typ pt txt p1 p2 y x h
                              pin-bot pin-top strip-left strip-right raw-texts
                              verticals cells names itm cell name best term-map
                              bot top outer-bot outer-top v rec name-cell left-span right-span
                              row-name other keep-cell mid-y horizontals slots grid-lines)
  (setq i 0 pin-bot 1e99 pin-top -1e99 strip-left 1e99 strip-right -1e99)
  (repeat (sslength ss)
    (setq ent (ssname ss i) ed (entget ent) typ (cdr (assoc 0 ed)))
    (cond
      ;; 上次生成的引线/标注不得参与原图端子几何识别。
      ((member (cdr (assoc 8 ed)) '("电缆-接线" "电缆-文字" "接线-原理号")) nil)
      ((= typ "LINE")
       (setq p1 (cdr (assoc 10 ed)) p2 (cdr (assoc 11 ed)))
       (if (< (abs (- (cadr p1) (cadr p2))) 0.05)
         (setq horizontals (cons (list (cadr p1) (min (car p1) (car p2))
                                      (max (car p1) (car p2))) horizontals)
               pin-bot (min pin-bot (cadr p1)) pin-top (max pin-top (cadr p1))
               strip-left (min strip-left (car p1) (car p2))
               strip-right (max strip-right (car p1) (car p2))))
       (if (and (< (abs (- (car p1) (car p2))) 0.05)
                (> (abs (- (cadr p1) (cadr p2))) 0.1))
         (setq verticals (cons (list (car p1) (min (cadr p1) (cadr p2))
                                     (max (cadr p1) (cadr p2))) verticals))))
      ((member typ '("TEXT" "MTEXT"))
       (setq txt (vl-string-trim " \t\r\n" (dx:text-string ent))
             pt (zddl:text-point ent ed))
       (if (and pt (/= txt ""))
         (setq raw-texts (cons (list txt (car pt) (cadr pt)) raw-texts)))))
    (setq i (1+ i)))
  ;; 必须先收集全部竖框，再剔除跨越相邻端子列的短接横线。
  (if verticals
    (progn
      (foreach h horizontals
        (if (zddl:grid-edge-p h verticals) (setq grid-lines (cons h grid-lines))))
      (setq horizontals grid-lines)))
  ;; 每个文字按自己的端子格判断中带，不再使用整个选择区的总高度。
  (foreach itm raw-texts
    (setq txt (car itm) x (cadr itm) y (caddr itm)
          cell (zddl:cell-for-point verticals x y))
    ;; 兼容旧图仅框选水平边线的单行情况；有竖边时禁止跨行回退。
    (if (and (null verticals) (< pin-bot pin-top))
      (progn
        (setq h (- pin-top pin-bot))
        (if (and (>= y (+ pin-bot (* 0.3 h))) (<= y (- pin-top (* 0.3 h))))
          (setq cell (list x pin-bot pin-top strip-left strip-right)))))
    (if (and cell (zddl:is-numeric-p txt))
      (setq cells (cons (append (cons txt cell) (list y)) cells)))
    ;; 排名可位于宽标题列的底格；原理号列的普通英文不能冒充排名。
    (if (and (not (zddl:is-numeric-p txt))
             (not (dx:has-hanzi-p txt)) (not (vl-string-search ":" txt))
             (not (member (strcase txt) '("GND" "COM" "NC" "NO")))
             (setq name-cell (if verticals (zddl:bounds-for-point verticals x y) cell)))
      (progn
        (setq left-span (zddl:column-span verticals (nth 3 name-cell)
                                        (nth 1 name-cell) (nth 2 name-cell))
              right-span (zddl:column-span verticals (nth 4 name-cell)
                                         (nth 1 name-cell) (nth 2 name-cell))
              names (cons (list (strcase txt) (car name-cell)
                                (max (car left-span) (car right-span))
                                (min (cadr left-span) (cadr right-span))
                                (nth 3 name-cell) (nth 4 name-cell)) names)))))
  (setq cells (aa:merge-sort cells '(lambda (a b) (< (cadr a) (cadr b)))))
  (if cells
    (progn
      (setq pin-bot 1e99 pin-top -1e99 strip-left 1e99 strip-right -1e99)
      (foreach itm cells
        (setq txt (car itm) x (cadr itm) bot (nth 2 itm) top (nth 3 itm)
              best nil name "ZD" outer-bot bot outer-top top row-name nil)
        (foreach rec names
          (if (and (>= bot (- (nth 2 rec) 0.05)) (<= top (+ (nth 3 rec) 0.05))
                   ;; 排名位于较宽的标题列；窄原理号列不能成为新排名。
                   (or (null verticals)
                       (> (- (nth 5 rec) (nth 4 rec)) (* 1.1 (- (nth 5 itm) (nth 4 itm)))))
                   (if verticals (>= (nth 4 itm) (- (nth 5 rec) 0.05)) (< (cadr rec) x))
                   (or (null best) (> (cadr rec) best)))
            (setq name (car rec) best (cadr rec) row-name rec)))
        ;; 同列若混入纯数字原理号，保留更靠近整排中线的端子号。
        ;; 接地端子可偏离中线，列内没有其他编号时仍予以保留。
        (setq keep-cell (or best (null names)))
        (if row-name
          (progn
            (setq mid-y (/ (+ (nth 2 row-name) (nth 3 row-name)) 2.0))
            (foreach other cells
              (if (and (equal x (cadr other) 0.05)
                       (>= (nth 6 other) (nth 2 row-name))
                       (<= (nth 6 other) (nth 3 row-name))
                       (< (abs (- (nth 6 other) mid-y))
                          (- (abs (- (nth 6 itm) mid-y)) 0.05)))
                (setq keep-cell nil)))))
        (if keep-cell
          (progn
            ;; 包含紧接端子格的功能说明格，出线从整行外缘开始，回写仍在原理号格。
            (foreach v verticals
              (if (or (equal (car v) (nth 4 itm) 0.05) (equal (car v) (nth 5 itm) 0.05))
                (progn
                  (if (equal (caddr v) bot 0.05) (setq outer-bot (min outer-bot (cadr v))))
                  (if (equal (cadr v) top 0.05) (setq outer-top (max outer-top (caddr v)))))))
            (setq slots (zddl:write-slots horizontals raw-texts x (nth 6 itm)
                                          outer-bot outer-top (nth 4 itm) (nth 5 itm))
                  rec (append (list x outer-bot outer-top) slots
                              (list (- (nth 5 itm) (nth 4 itm))))
                  term-map (cons (cons (strcat name ":" txt) rec) term-map)
                  pin-bot (min pin-bot outer-bot) pin-top (max pin-top outer-top)
                  strip-left (min strip-left (nth 4 itm)) strip-right (max strip-right (nth 5 itm))))))
      (list term-map pin-bot pin-top strip-left strip-right (+ pin-bot 10.0) (- pin-top 10.0)))
    (progn
      (princ (strcat "\r\n[ZDDL2] 诊断：已读取 " (itoa (length raw-texts))
                     " 个文字，未找到位于端子格中带的数字端子号；请包含端子格完整边框。"))
      nil)))

(defun zddl:sort-box-texts (texts /)
  (aa:merge-sort texts '(lambda (a b) (> (nth 2 a) (nth 2 b))))
)

(defun zddl:parse-one-box (box-texts / dest spec remaining rows itm pairs term-txt
                                      princ-txt txt col r matched new-rows y-sum avg-y)
  (setq dest      ""
        spec      ""
        remaining '()
        pairs     '())
  (foreach itm box-texts
    (setq txt (car itm))
    (cond
      ((and (= dest "") (dx:has-hanzi-p txt))
       (setq dest txt))
      ((and (= spec "")
            (or (wcmatch txt "*×*")
                (wcmatch txt "*\\U+00D7*")
                (wcmatch txt "*\\*")
                (wcmatch (strcase txt) "*#[X*]#[.,0-9]*")
                (wcmatch (strcase txt) "*KVV*")
                (wcmatch (strcase txt) "*YJV*")
                (wcmatch (strcase txt) "*WDZ*")
                (wcmatch (strcase txt) "*RVV*")
                (wcmatch (strcase txt) "*DJYP*")))
       (setq spec txt))
      (T
       (setq remaining (cons itm remaining)))))

  (if remaining
    (progn
      ;; 按 Y 降序排列
      (setq remaining (zddl:sort-box-texts remaining)
            rows      '())
      ;; 聚类成行：使用行内 Y 均值，容差 2.2mm
      (foreach itm remaining
        (setq matched  nil
              new-rows '())
        (foreach r rows
          (if (not matched)
            (progn
              (setq y-sum (apply '+ (mapcar 'caddr r))
                    avg-y (/ y-sum (float (length r))))
              (if (<= (abs (- avg-y (nth 2 itm))) 2.2)
                (setq matched  T
                      new-rows (cons (cons itm r) new-rows))
                (setq new-rows (cons r new-rows))))
            (setq new-rows (cons r new-rows))))
        (if matched
          (setq rows (reverse new-rows))
          (setq rows (append rows (list (list itm))))))

      ;; 遍历每行，提取端子引用与原理号
      (foreach r rows
        (setq term-txt  ""
              princ-txt "")
        (foreach itm r
          (setq txt (car itm)
                col (nth 3 itm))
          (cond
            ((vl-string-search ":" txt)
             (setq term-txt txt))
            ((= col 4)
             (setq princ-txt txt))
            ((= col 7)
             (if (= term-txt "") (setq term-txt txt) (setq princ-txt txt)))
            (T
             (if (= term-txt "") (setq term-txt txt) (setq princ-txt txt)))))
        (if (/= term-txt "")
          (setq pairs (cons (cons term-txt princ-txt) pairs))))
      (setq pairs (reverse pairs))))
  (list pairs dest spec)
)

(defun zddl:cluster-texts-by-x (text-items / sorted-items groups cur-group last-x itm x)
  (setq sorted-items (aa:merge-sort text-items '(lambda (a b) (< (cadr a) (cadr b))))
        groups       '()
        cur-group    '()
        last-x       nil)
  (foreach itm sorted-items
    (setq x (cadr itm))
    (if (or (null last-x) (<= (abs (- x last-x)) 40.0))
      (setq cur-group (cons itm cur-group)
            last-x    x)
      (progn
        (setq groups    (cons (reverse cur-group) groups)
              cur-group (list itm)
              last-x    x))))
  (if cur-group
    (setq groups (cons (reverse cur-group) groups)))
  (reverse groups)
)

(defun zddl:parse-wiring-ss (ss doc tol rect-tol / text-ss line-ss spatial-index
                                                   infos i en info groups sorted-groups
                                                   text-items raw-groups cables cable
                                                   grp-rec ed txt col pt g)
  (setq text-ss (aa:zz-filter-text-ss ss))
  (if (or (null text-ss) (= (sslength text-ss) 0))
    nil
    (progn
      (setq line-ss (aa:zz-harvest-lines doc text-ss ss))
      (if (and line-ss (> (sslength line-ss) 0))
        (progn
          (setq spatial-index (aa:zz-build-spatial-index line-ss tol)
                infos         nil
                i             0)
          (repeat (sslength text-ss)
            (setq en   (ssname text-ss i)
                  info (aa:zz-text-info doc en tol spatial-index))
            (if info (setq infos (cons info infos)))
            (setq i (1+ i)))
          (setq groups (aa:zz-group-by-rect (reverse infos) rect-tol))
          (if groups
            (progn
              (setq sorted-groups (dx2:sort-groups groups)
                    cables        '())
              (foreach grp-rec sorted-groups
                (setq text-items '())
                (foreach info (car grp-rec)
                  (setq en  (car info)
                        ed  (entget en)
                        txt (vl-string-trim " \t\r\n" (dx:text-string en))
                        col (cdr (assoc 62 ed))
                        pt  (zddl:text-point en ed))
                  (if (null col) (setq col 7))
                  (setq text-items (cons (list txt (car pt) (cadr pt) col) text-items)))
                (setq cable (zddl:parse-one-box text-items))
                (if (car cable)
                  (setq cables (cons cable cables))))
              (reverse cables))
            nil))
        ;; Fallback: 没有检测到封闭方格边框线时按 X 间距聚类
        (progn
          (setq text-items '()
                i          0)
          (repeat (sslength text-ss)
            (setq en  (ssname text-ss i)
                  ed  (entget en)
                  txt (vl-string-trim " \t\r\n" (dx:text-string en))
                  col (cdr (assoc 62 ed))
                  pt  (zddl:text-point en ed))
            (if (null col) (setq col 7))
            (setq text-items (cons (list txt (car pt) (cadr pt) col) text-items))
            (setq i (1+ i)))
          (setq raw-groups (zddl:cluster-texts-by-x text-items)
                cables     '())
          (foreach g raw-groups
            (setq cable (zddl:parse-one-box g))
            (if (car cable) (setq cables (cons cable cables))))
          (reverse cables)))))
)

(defun zddl:ensure-layer (name color /)
  (if (null (tblsearch "LAYER" name))
    (entmake (list '(0 . "LAYER")
                   '(100 . "AcDbSymbolTableRecord")
                   '(100 . "AcDbLayerTableRecord")
                   (cons 2 name)
                   '(70 . 0)
                   (cons 62 color)
                   '(6 . "Continuous"))))
)

(defun zddl:make-line (p1 p2 layer color /)
  (entmake (list '(0 . "LINE")
                 (cons 8 layer)
                 (cons 62 color)
                 (cons 10 p1)
                 (cons 11 p2)))
)

(defun zddl:make-triangle (tip-pt / oz alt half bp1 bp2)
  (setq oz   tip-pt
        alt  (* 1.5 (sqrt 3.0))
        half 1.5
        bp1  (list (- (car oz) alt) (+ (cadr oz) half) 0.0)
        bp2  (list (- (car oz) alt) (- (cadr oz) half) 0.0))
  (entmake
    (list
      '(0 . "LWPOLYLINE")
      '(100 . "AcDbEntity")
      '(100 . "AcDbPolyline")
      (cons 8 "电缆-接线")
      '(62 . 7)
      '(90 . 3)
      '(70 . 1)
      (cons 10 (list (car oz)  (cadr oz)))
      (cons 10 (list (car bp1) (cadr bp1)))
      (cons 10 (list (car bp2) (cadr bp2)))))
)

(defun zddl:make-text (pt txt sty layer color rot h-align v-align height / data)
  (if (and txt (/= txt ""))
    (progn
      (setq data (list '(0 . "TEXT")
                       (cons 8 layer)
                       (cons 62 color)
                       (cons 10 pt)
                       (cons 40 height)
                       (cons 41 0.7)
                       (cons 1 txt)
                       (cons 7 sty)
                       (cons 50 rot)
                       (cons 72 h-align)
                       (cons 73 v-align)))
      (if (or (/= h-align 0) (/= v-align 0))
        (setq data (append data (list (cons 11 pt)))))
      (entmake data)))
)

;; 字体测量失败时使用保守宽度估计；不依赖 COM 或已创建的临时实体。
(defun zddl:text-width (txt sty height / box)
  (setq box (vl-catch-all-apply 'textbox
              (list (list '(0 . "TEXT") (cons 1 txt) (cons 7 sty)
                          (cons 40 height) '(41 . 0.7) '(50 . 0.0)))))
  (if (and (not (vl-catch-all-error-p box)) box)
    (max 0.01 (abs (- (car (cadr box)) (car (car box)))))
    (* height (strlen txt))))

(defun zddl:format-cable-no (prefix num / num-str)
  (if (< num 10)
    (setq num-str (strcat "0" (itoa num)))
    (setq num-str (itoa num)))
  (if (or (wcmatch prefix "*-") (wcmatch prefix "*_"))
    (strcat prefix num-str)
    (strcat prefix "-" num-str))
)

;; 先按实际端子位置规划电缆；保留原接线组编号，绘制高度与编号解耦。
(defun zddl:plan-cables (cables term-map dir / plans serial cable pr match x left-x row-y pin)
  (setq serial 0)
  (foreach cable cables
    (setq left-x nil row-y nil)
    (foreach pr (car cable)
      (setq match (zddl:lookup-terminal (car pr) term-map))
      (if match
        (progn
          (setq x (car match) pin (if (= dir "X") (nth 1 match) (nth 2 match))
                left-x (if left-x (min left-x x) x)
                row-y (if row-y (if (= dir "X") (min row-y pin) (max row-y pin)) pin)))))
    (if left-x
      (progn
        (setq plans (cons (list row-y left-x serial cable) plans)
              serial (1+ serial)))
      (foreach pr (car cable)
        (princ (strcat "\r\n[ZDDL2] 提示：端子「" (car pr) "」未匹配，此接线组已跳过。")))))
  (aa:merge-sort (reverse plans) 'zddl:plan-before))

(defun zddl:plan-before (a b /)
  (if (equal (car a) (car b) 0.05)
    (< (cadr a) (cadr b))
    (> (car a) (car b))))

;; 去向、规格位置与末端测量共用一套规则，供全批预排及实际绘制调用。
(defun zddl:label-layout (cable marker-x sty / dest spec dest-x spec-x)
  (setq dest (cadr cable) spec (caddr cable) dest-x (+ marker-x 2.0))
  (if (and (/= dest "") (not (wcmatch dest "至*"))) (setq dest (strcat "至" dest)))
  (if (or (null spec) (= spec "")) (setq spec "未填写"))
  (setq spec-x (+ dest-x (zddl:text-width dest sty 3.0) 3.0))
  (list dest spec dest-x spec-x (+ spec-x (zddl:text-width spec sty 3.0) 2.0)))

(defun zddl:draw-one-cable (cable-data idx lane-idx pin-y dir prefix start-idx right-x write-p
                            cell-y term-map sty right-end / pairs dest spec cable-no cable-y
                            xs x min-x marker-x base-y p-txt ref match pr matches row-pin rec
                            capacity occupied text-height dest-x spec-x end-x layout)
  (setq pairs    (car cable-data)
        dest     (cadr cable-data)
        spec     (caddr cable-data)
        cable-no (zddl:format-cable-no prefix (+ start-idx idx)))
  ;; 先匹配端子，按实际所在行计算本根电缆的出线基准。
  (setq matches nil row-pin nil)
  (foreach pr pairs
    (setq match (zddl:lookup-terminal (car pr) term-map))
    (if match
      (progn
        (setq matches (cons (cons pr match) matches))
        (setq x (if (= dir "X") (nth 1 match) (nth 2 match)))
        (setq row-pin (if row-pin (if (= dir "X") (min row-pin x) (max row-pin x)) x)))
      (princ (strcat "\r\n[ZDDL2] 提示：端子「" (car pr) "」未找到或裸端子号不唯一，已跳过。"))))
  (if row-pin (setq pin-y row-pin))
  (if (= dir "X")
    (setq cable-y (- pin-y (+ 10.0 (* lane-idx 7.0))))
    (setq cable-y (+ pin-y (+ 10.0 (* lane-idx 7.0)))))
  (setq xs nil)
  (foreach rec (reverse matches)
    (setq pr (car rec) match (cdr rec) p-txt (cdr pr)
          pin-y (if (= dir "X") (nth 1 match) (nth 2 match))
          cell-y (if (= dir "X") (nth 3 match) (nth 4 match)))
    (if match
      (progn
        (setq x (car match)
              xs (cons x xs))
        ;; 竖向引线
        (zddl:make-line (list x pin-y 0.0) (list x cable-y 0.0) "电缆-接线" 7)
        ;; 接线转折短线
        (if (= dir "X")
          (zddl:make-line (list (+ x 1.0) cable-y 0.0) (list x (+ cable-y 1.0) 0.0) "电缆-接线" 7)
          (zddl:make-line (list (+ x 1.0) cable-y 0.0) (list x (- cable-y 1.0) 0.0) "电缆-接线" 7))
        ;; 与网页一致：向上贴上外框内侧，向下贴下外框内侧，均留 2mm。
        ;; 长编号按真实格长和列宽缩放，已有原理号保留，禁止叠写。
        (if (and (= write-p "Y") (/= p-txt ""))
          (progn
            (setq capacity (nth (if (= dir "X") 5 6) match)
                  occupied (nth (if (= dir "X") 7 8) match))
            (if (and cell-y capacity (> capacity 0.1) (not occupied))
              (progn
                (setq text-height (min 3.0 (max 0.1 (- (nth 9 match) 1.0))
                                       (/ (* 3.0 capacity) (zddl:text-width p-txt sty 3.0))))
                (zddl:make-text (list x cell-y 0.0) p-txt sty "接线-原理号" 4
                                (/ pi 2.0) (if (= dir "X") 0 2) 2 text-height))
              (princ (strcat "\r\n[ZDDL2] 端子「" (car pr)
                             "」外侧格已有文字或空间不足，保留原内容，仅绘制引线。"))))))
      (princ (strcat "\r\n[ZDDL2] 提示：未在端子排中匹配到端子「" (car pr) "」，已跳过该引出线。"))))

  (if xs
    (progn
      (setq min-x    (apply 'min xs)
            marker-x (max (- right-x 46.0) (+ (apply 'max xs) 24.0))
            base-y   (+ cable-y 1.0)
            dest-x   (+ marker-x 2.0))
      (setq layout (zddl:label-layout cable-data marker-x sty)
            dest (nth 0 layout) spec (nth 1 layout)
            dest-x (nth 2 layout) spec-x (nth 3 layout)
            end-x (nth 4 layout))
      ;; 全批统一到最长标注右端；独立调用仍保证文字完整落在线内。
      (if right-end (setq end-x (max end-x right-end)))
      ;; 水平电缆干线
      (zddl:make-line (list min-x cable-y 0.0) (list end-x cable-y 0.0) "电缆-接线" 3)
      ;; 三角标
      (zddl:make-triangle (list marker-x cable-y 0.0))
      ;; 标注：电缆编号
      (zddl:make-text (list (- marker-x 18.0) base-y 0.0) cable-no sty "电缆-文字" 7 0.0 0 0 3.0)
      ;; 标注：去向与规格按实际字体宽度排开。
      (if (/= dest "")
        (zddl:make-text (list dest-x base-y 0.0) dest sty "电缆-文字" 7 0.0 0 0 3.0))
      (zddl:make-text (list spec-x base-y 0.0) spec sty "电缆-文字" 7 0.0 0 0 3.0)
      T)
    nil)
)

(defun c:ZDDL2 (/ *error* aa:tag aa:doc aa:undo-open aa:old-cmdecho
                 doc tol rect-tol strip-ss box-ss strip-res term-map
                 pin-bot pin-top strip-left strip-right cell-bot-y cell-top-y
                 cables kw-dir opt-dir prefix start-no opt-write
                 right-x pin-y cell-y sty success-cnt cab plans plan row-y lane-idx pr match right-end layout)
  (aa:cmd-begin "ZDDL2")
  (vl-load-com)
  (setq doc      (vla-get-ActiveDocument (vlax-get-acad-object))
        tol      1e-8
        rect-tol 0.1)

  (princ "\r\n=== ZDDL2: 端子排电缆自动出线与标注 ===")
  (setq strip-ss (ssget "_I"))
  (if (null strip-ss)
    (progn
      (princ "\r\n[ZDDL2] 请框选现有端子排（包含端子排名称、端子号及边框线）: ")
      (setq strip-ss (ssget))))

  (if (null strip-ss)
    (progn (princ "\r\n[ZDDL2] 未选择端子排。") (aa:cmd-end))
    (progn
      (setq strip-res (zddl:parse-strip strip-ss))
      (if (null strip-res)
        (progn (princ "\r\n[ZDDL2] 错误：未能从所选中识别出有效的端子排结构。") (aa:cmd-end))
        (progn
          (setq term-map    (nth 0 strip-res)
                pin-bot     (nth 1 strip-res)
                pin-top     (nth 2 strip-res)
                strip-left  (nth 3 strip-res)
                strip-right (nth 4 strip-res)
                cell-bot-y  (nth 5 strip-res)
                cell-top-y  (nth 6 strip-res))
          (princ (strcat "\r\n[ZDDL2] 成功识别端子排，端子总数 " (itoa (length term-map)) " 个。"))
          (princ "\r\n[ZDDL2] 请框选 100×100 接线方格（包含端子引用、原理号及去向柜）: ")
          (setq box-ss (ssget))
          (if (null box-ss)
            (progn (princ "\r\n[ZDDL2] 未选择接线方格。") (aa:cmd-end))
            (progn
              (setq cables (zddl:parse-wiring-ss box-ss doc tol rect-tol))
              (if (null cables)
                (progn (princ "\r\n[ZDDL2] 未能从所选方格中识别出有效接线信息。") (aa:cmd-end))
                (progn
                  (princ (strcat "\r\n[ZDDL2] 成功识别 " (itoa (length cables)) " 组电缆接线。"))

                  ;; 出线方向选项：第一个为“向上”，第二个为“向下”，默认<向上>
                  (initget "Shang Xia")
                  (setq kw-dir (getkword "\r\n出线方向 [向上(Shang)/向下(Xia)] <向上>: "))
                  (if (equal kw-dir "Xia")
                    (setq opt-dir "X" pin-y pin-bot cell-y cell-bot-y)
                    (setq opt-dir "S" pin-y pin-top cell-y cell-top-y))

                  ;; 其余参数一律按标准默认处理（前缀WL，起始序号1，回写原理号，自动右侧对齐）
                  (setq prefix    "WL"
                        start-no  1
                        opt-write "Y")

                  ;; 确保图层和文字样式
                  (zddl:ensure-layer "电缆-接线" 7)
                  (zddl:ensure-layer "电缆-文字" 7)
                  (zddl:ensure-layer "接线-原理号" 4)
                  (setq sty (if (tblsearch "STYLE" "HZ") "HZ" (getvar "TEXTSTYLE")))

                  ;; 执行绘制
                  (setq success-cnt 0 row-y nil lane-idx 0
                        plans (zddl:plan-cables cables term-map opt-dir)
                        right-x nil)
                  ;; 标注列跟随本次实际接线最右端，不被空白端子或其他排拉远。
                  (foreach plan plans
                    (foreach pr (car (nth 3 plan))
                      (if (setq match (zddl:lookup-terminal (car pr) term-map))
                        (setq right-x (if right-x (max right-x (+ (car match) 70.0))
                                        (+ (car match) 70.0))))))
                  ;; 三角标共列，按全批最长去向和规格确定统一右端。
                  (setq right-end nil)
                  (foreach plan plans
                    (setq layout (zddl:label-layout (nth 3 plan) (- right-x 46.0) sty)
                          right-end (if right-end (max right-end (nth 4 layout)) (nth 4 layout))))
                  (foreach plan plans
                    (if (or (null row-y) (not (equal row-y (car plan) 0.05)))
                      (setq row-y (car plan) lane-idx 0))
                    (setq cab (nth 3 plan))
                    (if (zddl:draw-one-cable cab (nth 2 plan) lane-idx pin-y opt-dir prefix start-no right-x opt-write cell-y term-map sty right-end)
                      (setq success-cnt (1+ success-cnt) lane-idx (1+ lane-idx))))
                  (redraw)
                  (if (> success-cnt 0)
                    (princ (strcat "\r\n[ZDDL2] 绘制完成！成功绘制 " (itoa success-cnt) " 根电缆接线及标注 (" (zddl:format-cable-no prefix start-no) "~" (zddl:format-cable-no prefix (+ start-no success-cnt -1)) ")。"))
                    (princ "\r\n[ZDDL2] 未生成电缆：所有接线组均未匹配到端子，请检查端子引用与排名称。"))
                  (aa:cmd-end)
                ))))))))
  (sssetfirst nil nil)
  (princ)
)

(defun c:ZDC ()
  (c:ZDDL)
)

(princ)


;;; BEGIN ZDDL: 本机端子排与电缆生成（纯 AutoLISP，不依赖 Python）
;; 命令 ZDDL 使用下方 zddl2:* 纯 AutoLISP 计算（不依赖 Python / ezdxf）；CAD 内完成解析、布局与绘图。
;; 规则与 tools/zddl2_engine.py 保持一致；字符串按 Unicode 字符处理。
(defun zddl2:text (en / text)
  (setq text (aae:clean-mtext-format (dx:text-string en) T))
  (while (vl-string-search "\\P" text)
    (setq text (vl-string-subst "\n" "\\P" text)))
  text)

(defun zddl2:selection-text (ss coordinate / i en ed pt txt items item out marked)
  (setq i 0 out "")
  (repeat (sslength ss)
    (setq en (ssname ss i) ed (entget en) txt (zddl2:text en)
          pt (zddl:text-point en ed))
    (if (and pt txt (/= txt ""))
      (progn
        ;; 端子名按 DZ 规则自动识别：纯数字及“数字+a”为端子号，其余为端子名，无需先改青色。
        (setq marked (or (wcmatch txt "*端子名") (not (aa:dz-number-p txt))))
        (if (and coordinate marked (not (wcmatch txt "*端子名")))
          (setq txt (strcat txt " 端子名")))
        (setq items (cons (list (car pt) (cadr pt) txt i) items))))
    (setq i (1+ i)))
  (setq items (aa:merge-sort items
    '(lambda (a b) (if (equal (cadr a) (cadr b) 0.001)
      (if (equal (car a) (car b) 0.001) (< (nth 3 a) (nth 3 b)) (< (car a) (car b)))
      (> (cadr a) (cadr b))))))
  (foreach item items
    (setq out (strcat out
      (if coordinate (strcat (rtos (car item) 2 6) "," (rtos (cadr item) 2 6) " ") "")
      (nth 2 item) "\n")))
  out)

;; 命令 ZDDL 使用的纯 AutoLISP 版（不依赖 Python / ezdxf）
;; 解析、布局与图元生成全部在 CAD 内完成，规则与 tools/zddl2_engine.py 的
;; parse_terminals / parse_wiring / prepare / build_dxf 保持一致。
;; AutoLISP 按字节处理 GBK 字符串，本段所有字符操作都先按“汉字 = 2 字节”切分。

(defun zddl2:ws () (strcat " " (chr 9) (chr 10) (chr 13)))
(defun zddl2:ws-list () (list " " (chr 9) (chr 10) (chr 13)))
(defun zddl2:field-delims () (list (chr 9) "," "，" "、"))
(defun zddl2:record-delims () (list ";" "；" "|" "｜" (chr 13) (chr 10)))
(defun zddl2:punct-list () (list "。" "." "!" "！"))
(defun zddl2:colon-chars () (list ":" "："))
(defun zddl2:sep-chars () (list "-" "_" ":" "：" " " (chr 9) (chr 13) (chr 10)))

;; ---------- 字符串基础 ----------

(defun zddl2:chars (s / i n out)
  ;; Unicode 字符串：逐字符切分
  (setq i 1 n (strlen s) out nil)
  (while (<= i n)
    (setq out (cons (substr s i 1) out) i (1+ i)))
  (reverse out))

(defun zddl2:join (lst)
  (if lst (apply 'strcat lst) ""))

(defun zddl2:join-sep (lst sep / out x)
  (setq out "")
  (foreach x lst
    (setq out (if (= out "") x (strcat out sep x))))
  out)

(defun zddl2:take (lst n)
  (if (or (null lst) (<= n 0)) nil (cons (car lst) (zddl2:take (cdr lst) (1- n)))))

(defun zddl2:drop (lst n)
  (if (or (null lst) (<= n 0)) lst (zddl2:drop (cdr lst) (1- n))))

(defun zddl2:split (s delims / chars cur out ch)
  (setq chars (zddl2:chars s) cur "" out nil)
  (foreach ch chars
    (if (member ch delims)
      (setq out (cons cur out) cur "")
      (setq cur (strcat cur ch))))
  (reverse (cons cur out)))

(defun zddl2:trim (s) (vl-string-trim (zddl2:ws) s))

(defun zddl2:strip-punct (s / rc)
  (setq rc (reverse (zddl2:chars s)))
  (while (and rc (member (car rc) (zddl2:punct-list)))
    (setq rc (cdr rc)))
  (zddl2:join (reverse rc)))

(defun zddl2:starts-p (s p)
  (and (<= (strlen p) (strlen s)) (equal (substr s 1 (strlen p)) p)))

(defun zddl2:ends-p (s p / cs cp)
  ;; 按汉字为单位比较末尾，避免汉字的第二字节恰好是 ASCII 字母时误判
  (setq cs (zddl2:chars s) cp (zddl2:chars p))
  (and (<= (length cp) (length cs))
       (equal (zddl2:join (zddl2:drop cs (- (length cs) (length cp)))) p)))

(defun zddl2:letter-p (ch)
  (and (= (strlen ch) 1)
       (or (and (>= (ascii ch) 65) (<= (ascii ch) 90))
           (and (>= (ascii ch) 97) (<= (ascii ch) 122)))))

(defun zddl2:digit-p (ch)
  (and (= (strlen ch) 1) (>= (ascii ch) 48) (<= (ascii ch) 57)))

(defun zddl2:cjk-p (ch) (>= (ascii ch) 11904))

(defun zddl2:han-p (ch)
  ;; 与 BLOCK_NAME_HINT 的 一-龥 相同（U+4E00..U+9FA5）
  (and (>= (ascii ch) 19968) (<= (ascii ch) 40869)))

(defun zddl2:upch (ch)
  (if (and (= (strlen ch) 1) (>= (ascii ch) 97) (<= (ascii ch) 122))
    (chr (- (ascii ch) 32))
    ch))

(defun zddl2:upper-ascii (s / out ch)
  (setq out nil)
  (foreach ch (zddl2:chars s)
    (setq out (cons (zddl2:upch ch) out)))
  (zddl2:join (reverse out)))

(defun zddl2:compact (s / out ch)
  ;; 与 compact_reference 一致：去掉 - _ : ：及空白，ASCII 转大写
  (setq out nil)
  (foreach ch (zddl2:chars s)
    (if (not (member ch (zddl2:sep-chars)))
      (setq out (cons (zddl2:upch ch) out))))
  (zddl2:join (reverse out)))

(defun zddl2:lines (text / out ln)
  (setq out nil)
  (foreach ln (zddl2:split text (list (chr 10)))
    (setq out (cons (vl-string-right-trim (chr 13) ln) out)))
  (reverse out))

(defun zddl2:units (text / out piece)
  ;; 与 RECORD_SPLIT 切分后去掉空段一致
  (setq out nil)
  (foreach piece (zddl2:split text (zddl2:record-delims))
    (if (/= (zddl2:trim piece) "")
      (setq out (cons (zddl2:trim piece) out))))
  (reverse out))

(defun zddl2:clean-tokens (unit / out f)
  ;; clean_tokens：按字段切分，去空项，再去掉末尾标点
  (setq out nil)
  (foreach f (zddl2:split unit (zddl2:field-delims))
    (setq f (zddl2:trim f))
    (if (/= f "")
      (setq out (cons (zddl2:strip-punct f) out))))
  (reverse out))

(defun zddl2:blank-p (s) (= (zddl2:trim s) ""))

(defun zddl2:nth-or (lst n)
  (if (> (length lst) n) (nth n lst) ""))

;; ---------- 数字与坐标行 ----------

(defun zddl2:num-end (s i / n j d0 nd)
  ;; 从字节位置 i 起匹配 [+-]?(\d+(\.\d*)?|\.\d+)，返回匹配结束后的位置；不匹配返回 nil
  (setq n (strlen s) j i)
  (if (and (<= j n) (or (equal (substr s j 1) "+") (equal (substr s j 1) "-")))
    (setq j (1+ j)))
  (setq d0 j)
  (while (and (<= j n) (zddl2:digit-p (substr s j 1)))
    (setq j (1+ j)))
  (setq nd (- j d0))
  (cond
    ((> nd 0)
      (if (and (<= j n) (equal (substr s j 1) "."))
        (progn
          (setq j (1+ j))
          (while (and (<= j n) (zddl2:digit-p (substr s j 1)))
            (setq j (1+ j)))))
      j)
    ((and (<= j n) (equal (substr s j 1) "."))
      (setq j (1+ j) d0 j)
      (while (and (<= j n) (zddl2:digit-p (substr s j 1)))
        (setq j (1+ j)))
      (if (> (- j d0) 0) j nil))
    (T nil)))

(defun zddl2:numeric-p (s / e)
  (setq e (zddl2:num-end s 1))
  (and e (> (strlen s) 0) (= e (1+ (strlen s)))))

(defun zddl2:skip-ws (s i)
  (while (and (<= i (strlen s)) (member (substr s i 1) (zddl2:ws-list)))
    (setq i (1+ i)))
  i)

(defun zddl2:parse-coord-line (raw / s xe ys ye tok)
  ;; COORDINATE_LINE：^\s*num\s*,\s*num\s+(.+?)\s*$ ；返回 (x y 文字) 或 nil
  (setq s (zddl2:trim raw))
  (setq xe (zddl2:num-end s 1))
  (if (null xe)
    nil
    (if (not (equal (substr s (zddl2:skip-ws s xe) 1) ","))
      nil
      (progn
        (setq ys (zddl2:skip-ws s (1+ (zddl2:skip-ws s xe))))
        (setq ye (zddl2:num-end s ys))
        (if (or (null ye) (not (member (substr s ye 1) (zddl2:ws-list))))
          nil
          (progn
            (setq tok (zddl2:trim (substr s ye)))
            (if (= tok "")
              nil
              (list (atof (substr s 1 (- (zddl2:skip-ws s xe) 1)))
                    (atof (substr s ys (- ye ys)))
                    tok))))))))

(defun zddl2:coord-line-p (raw)
  (if (zddl2:parse-coord-line raw) T nil))

(defun zddl2:name-mark (tok / n)
  ;; 行末「端子名」标记：返回 (是否标记  名称)
  (setq n (strlen tok))
  (if (and (>= n 3) (zddl2:ends-p tok "端子名"))
    (list T (zddl2:trim (substr tok 1 (- n 3))))
    (list nil tok)))

;; ---------- 稳定插入排序（个数很少，足够） ----------

(defun zddl2:before-p (a b pi si desc / ka kb)
  (setq ka (nth pi a) kb (nth pi b))
  (cond
    ((= ka kb)
      (if si (< (nth si a) (nth si b)) nil))
    (desc (> ka kb))
    (T (< ka kb))))

(defun zddl2:insert-sorted (x lst pi si desc)
  (cond
    ((null lst) (list x))
    ((zddl2:before-p x (car lst) pi si desc) (cons x lst))
    (T (cons (car lst) (zddl2:insert-sorted x (cdr lst) pi si desc)))))

(defun zddl2:isort (items pi si desc / out x)
  (setq out nil)
  (foreach x items
    (setq out (zddl2:insert-sorted x out pi si desc)))
  out)

;; ---------- 关联表（每项为 (键 值)） ----------

(defun zddl2:al-get (al key dflt / e)
  (setq e (assoc key al))
  (if e (cadr e) dflt))

(defun zddl2:al-set (al key val / out found e)
  (setq out nil found nil)
  (foreach e al
    (if (equal (car e) key)
      (setq out (cons (list key val) out) found T)
      (setq out (cons e out))))
  (if (not found) (setq out (cons (list key val) out)))
  (reverse out))

(defun zddl2:uniq (lst / out x)
  (setq out nil)
  (foreach x lst
    (if (not (member x out)) (setq out (cons x out))))
  (reverse out))

(defun zddl2:dups (lst / seen out x)
  ;; 第二次及以后出现的值，按第二次出现的顺序去重
  (setq seen nil out nil)
  (foreach x lst
    (if (member x seen)
      (if (not (member x out)) (setq out (cons x out)))
      (setq seen (cons x seen))))
  (reverse out))

;; ---------- 端子排名称判断（BLOCK_NAME_HINT） ----------

(defun zddl2:all-digits-p (chars / ok ch)
  (setq ok T)
  (foreach ch chars
    (if (not (zddl2:digit-p ch)) (setq ok nil)))
  ok)

(defun zddl2:letters-digits-p (tok / chars n k)
  ;; [A-Za-z]{1,4}[0-9]{0,2}
  (setq chars (zddl2:chars tok) n (length chars) k 0)
  (while (and (< k n) (zddl2:letter-p (nth k chars)))
    (setq k (1+ k)))
  (and (>= k 1) (<= k 4)
       (<= (- n k) 2)
       (zddl2:all-digits-p (zddl2:drop chars k))))

(defun zddl2:block-name-p (tok / chars ok haslet ch)
  ;; 1) 只含字母数字、连字符、汉字，含字母或汉字，且以 D/d 或 -COM 结尾
  ;; 2) 1~4 个字母后接 0~2 个数字
  (setq chars (zddl2:chars tok) ok T haslet nil)
  (foreach ch chars
    (cond
      ((zddl2:letter-p ch) (setq haslet T))
      ((zddl2:digit-p ch) nil)
      ((equal ch "-") nil)
      ((zddl2:han-p ch) (setq haslet T))
      (T (setq ok nil))))
  (or
    (and ok haslet
         (or (zddl2:ends-p tok "D") (zddl2:ends-p tok "d")
             (zddl2:ends-p (zddl2:upper-ascii tok) "-COM")))
    (zddl2:letters-digits-p tok)))

;; ---------- 普通格式：端子排名称 + 端子号 ----------

(defun zddl2:group-terms (events name / out ev)
  ;; events 中 T 类事件的归属名为 name 的端子号（按出现顺序）
  (setq out nil)
  (foreach ev events
    (if (and (equal (car ev) "T") (equal (caddr ev) name))
      (setq out (cons (cadr ev) out))))
  (reverse out))

(defun zddl2:parse-plain (text / events cur pos names blocks errs terms kept dups unit tok ev name)
  (setq events nil)
  (foreach unit (zddl2:units text)
    (setq cur nil pos 0)
    (foreach tok (zddl2:clean-tokens unit)
      (if (or (= pos 0) (zddl2:block-name-p tok) (null cur))
        (setq events (cons (list "S" tok tok) events) cur tok)
        (setq events (cons (list "T" tok cur) events)))
      (setq pos (1+ pos))))
  (setq events (reverse events))
  (setq names nil)
  (foreach ev events
    (if (equal (car ev) "S") (setq names (cons (cadr ev) names))))
  (setq names (zddl2:uniq (reverse names)) blocks nil errs nil)
  (foreach name names
    (setq terms (zddl2:group-terms events name))
    (cond
      ((zddl2:numeric-p name)
        (setq errs (append errs
          (list (strcat "端子排名称「" name "」是纯数字，多半是漏写了名称；坐标格式每行要写成「横坐标,纵坐标 文字」")))))
      ((null terms)
        (setq errs (append errs (list (strcat "端子排「" name "」后面没有端子号")))))
      (T
        (setq kept (zddl2:uniq terms) dups (zddl2:dups terms))
        (if dups
          (setq errs (append errs
            (list (strcat "端子排「" name "」里这些端子号出现了不止一次：" (zddl2:join-sep dups "、"))))))
        (setq blocks (append blocks (list (list name name kept "默认行")))))))
  (if (and (null blocks) (null errs))
    (setq errs (list "上面的端子排还没填")))
  (list blocks errs))

(defun zddl2:parse-terminals (text / lines first-line n errs ln)
  (setq lines (zddl2:lines text) first-line nil n 0 errs nil)
  (foreach ln lines
    (if (and (null first-line) (not (zddl2:blank-p ln)))
      (setq first-line ln)))
  (cond
    ((and first-line (zddl2:coord-line-p first-line))
      (zddl2:parse-coords text))
    (T
      (foreach ln lines
        (setq n (1+ n))
        (if (and (null errs) (not (zddl2:blank-p ln)) (zddl2:coord-line-p ln))
          (setq errs (list (strcat "第 " (itoa n) " 行是坐标格式，但整段按普通格式解析："
                                   (zddl2:trim ln) "。两种格式不能混用，请整段统一")))))
      (if errs
        (list nil errs)
        (zddl2:parse-plain text)))))

;; ---------- 坐标格式：横坐标,纵坐标 文字 ----------
;; 行格式：(x y 文字 是否端子排名称)

(defun zddl2:rows-with (rows marked / out r)
  (setq out nil)
  (foreach r rows
    (if (if marked (nth 3 r) (not (nth 3 r)))
      (setq out (cons r out))))
  (reverse out))

(defun zddl2:sort-x (rows) (zddl2:isort rows 0 nil nil))

(defun zddl2:coord-tol ()
  ;; 坐标分排容差：纵坐标相差不超过该值即视为同一排（与 COORDINATE_Y_TOLERANCE 一致）
  30.0)

(defun zddl2:unique-name (label counts / c)
  ;; 同名端子排第二次出现起命名为 名称@序号
  (setq c (1+ (zddl2:al-get counts label 0)))
  (list (if (= c 1) label (strcat label "@" (itoa c)))
        (zddl2:al-set counts label c)))

(defun zddl2:coord-horizontal (rows / sy bands blocks errs counts bandno band anchors tr al2 a nextx terms res orph r)
  ;; 横排型：先按水平带分组，再按端子排名称的横坐标划分端子
  ;; 整图文字可达数百个，按纵坐标排序用归并排序，避免递归插入排序过深
  (setq sy (aa:merge-sort rows '(lambda (a b) (> (cadr a) (cadr b)))) bands nil)
  (foreach r sy
    (if (or (null bands) (> (abs (- (nth 1 (car (car bands))) (nth 1 r))) (zddl2:coord-tol)))
      (setq bands (cons (list r) bands))
      (setq bands (cons (cons r (car bands)) (cdr bands)))))
  (setq bands (reverse (mapcar '(lambda (b) (reverse b)) bands)))
  (setq blocks nil errs nil counts nil bandno 0)
  (foreach band bands
    (setq bandno (1+ bandno)
          anchors (zddl2:sort-x (zddl2:rows-with band T))
          tr (zddl2:sort-x (zddl2:rows-with band nil)))
    (cond
      ((null anchors)
        (if tr
          (setq errs (append errs (list (strcat "纵坐标 " (rtos (nth 1 (car band)) 2 2)
                                                " 附近的一排文字没有标「端子名」的端子排名称；示例文字："
                                                (zddl2:join-sep (zddl2:take (mapcar '(lambda (r) (nth 2 r)) tr) 3) "、")
                                                "。请在这一排补写「端子排名称 端子名」"))))))
      (T
        ;; 名称左边的端子号并入本排第一块，名称写在一排中间或右端也能识别
        (setq orph nil)
        (foreach r tr
          (if (<= (car r) (car (car anchors)))
            (setq orph (cons (nth 2 r) orph))))
        (setq orph (reverse orph))
        (setq al2 anchors)
        (while al2
          (setq a (car al2)
                nextx (if (cdr al2) (car (cadr al2)) 1e18)
                terms (if (eq al2 anchors) orph nil))
          (foreach r tr
            (if (and (> (car r) (car a)) (<= (car r) nextx))
              (setq terms (append terms (list (nth 2 r))))))
          (if (null terms)
            (setq errs (append errs (list (strcat "端子排「" (nth 2 a) "」附近没有识别到端子号"))))
            (progn
              (setq res (zddl2:unique-name (nth 2 a) counts))
              (setq counts (cadr res))
              ;; 同一排的端子排共用一个排键，出图时仍画在同一排、从左到右排列
              (setq blocks (append blocks
                (list (list (car res) (nth 2 a) terms (strcat "坐标排-" (itoa bandno))))))))
          (setq al2 (cdr al2))))))
  (if (null blocks)
    (setq errs (append errs (list "坐标清单里没有标「端子名」的横向端子排"))))
  (list blocks errs))

(defun zddl2:parse-coords (text / lines n rows errs bad item res res2 blocks empties ln bk)
  (setq lines (zddl2:lines text) n 0 rows nil errs nil bad nil)
  (foreach ln lines
    (setq n (1+ n))
    (if (and (null bad) (not (zddl2:blank-p ln)))
      (progn
        (setq item (zddl2:parse-coord-line ln))
        (if (null item)
          (setq bad (strcat "第 " (itoa n) " 行不是“横坐标,纵坐标 文字”格式：" (zddl2:trim ln)
                            "。两种格式不能混用，请整段统一"))
          (progn
            (setq res (zddl2:name-mark (caddr item)))
            (if (and (car res) (equal (cadr res) ""))
              (setq errs (append errs (list (strcat "第 " (itoa n) " 行标了端子名，但名称是空的"))))
              (setq rows (append rows (list (list (car item) (cadr item) (cadr res) (car res)))))))))))
  (cond
    (bad (list nil (list bad)))
    ((null rows) (list nil errs))
    ((null (zddl2:rows-with rows T))
      (list nil (append errs (list "坐标清单里没有标「端子名」的端子排名称。请写成「X 端子名」这种格式"))))
    (T
      ;; 端子排始终横排：按排分组后从左往右读取
      (setq res2 (zddl2:coord-horizontal rows))
      (setq blocks (car res2) empties nil)
      (foreach bk blocks
        (if (null (caddr bk))
          (setq empties (append empties (list (strcat "端子排「" (cadr bk) "」后面没有端子号"))))))
      (list blocks (append errs (cadr res2) empties)))))

;; ---------- 引用匹配（ref_matches） ----------

(defun zddl2:first-colon-prefix (text / chars pre done ch)
  ;; 第一个冒号（: 或 ：）之前的部分；没有冒号返回 nil
  (setq chars (zddl2:chars text) pre nil done nil)
  (foreach ch chars
    (if (not done)
      (if (member ch (zddl2:colon-chars))
        (setq done T)
        (setq pre (strcat (if pre pre "") ch)))))
  (if done (if pre pre "") nil))

(defun zddl2:sep-positions (label / parts out cum p)
  ;; 名称中分隔符在去掉分隔符后的位置，如 QD-COM 为 (2)
  (setq parts (zddl2:split (zddl2:trim label) (zddl2:sep-chars)) out nil cum 0)
  (foreach p (reverse (cdr (reverse parts)))
    (setq cum (+ cum (strlen p)))
    (setq out (cons cum out)))
  out)

(defun zddl2:ref-matches (ref blocks / text ctext pre colon-at reason labels entries sorted matches lab clen cname wanted found e b term)
  ;; 返回 (匹配列表  原因)；匹配项为 (端子排名称  内部名  端子号)
  (setq text (zddl2:trim ref))
  (if (= text "")
    (list nil "缺少端子号")
    (progn
      (setq ctext (zddl2:compact text)
            pre (zddl2:first-colon-prefix text)
            colon-at (if pre (strlen (zddl2:compact pre)) nil)
            reason (strcat "「" text "」对不上任何端子排")
            matches nil)
      (setq labels (zddl2:uniq (mapcar '(lambda (b) (cadr b)) blocks)))
      (setq entries (mapcar '(lambda (l) (list l (strlen (zddl2:compact l)) (zddl2:compact l))) labels))
      (setq sorted (zddl2:isort entries 1 nil t))
      (foreach e sorted
        (setq lab (nth 0 e) clen (nth 1 e) cname (nth 2 e))
        (if (and (> clen 0)
                 (zddl2:starts-p ctext cname)
                 (or (null colon-at) (= colon-at clen) (member colon-at (zddl2:sep-positions lab))))
          (progn
            (setq wanted (substr ctext (1+ clen)))
            (if (= wanted "")
              (setq reason (strcat "「" text "」只有端子排名称，缺端子号"))
              (progn
                (setq found nil)
                (foreach b blocks
                  (if (equal (cadr b) lab)
                    (foreach term (caddr b)
                      (if (equal (zddl2:compact term) wanted)
                        (setq found (cons (list lab (car b) term) found))))))
                (if found
                  (setq matches (append matches (zddl2:uniq (reverse found))))
                  (setq reason (strcat lab " 没有 " wanted " 号端子"))))))))
      (list matches (if matches "" reason)))))

(defun zddl2:looks-ref (tok blocks)
  (if (car (zddl2:ref-matches tok blocks)) T nil))

(defun zddl2:push-rec (rec out / r)
  (setq r (reverse rec))
  (while (and r (equal (car r) ""))
    (setq r (cdr r)))
  (if r (cons (reverse r) out) out))

(defun zddl2:split-records (text blocks / out cur unit tok)
  ;; 按记录切分；遇到“端子排名称+端子号”的项自动另起一条
  (setq out nil)
  (foreach unit (zddl2:units text)
    (setq cur nil)
    (foreach tok (mapcar '(lambda (f) (zddl2:strip-punct f))
                         (mapcar '(lambda (f) (zddl2:trim f)) (zddl2:split unit (zddl2:field-delims))))
      (if (and cur (zddl2:looks-ref tok blocks))
        (progn
          (setq out (zddl2:push-rec cur out))
          (setq cur (list tok)))
        (setq cur (append cur (list tok)))))
    (setq out (zddl2:push-rec cur out)))
  (reverse out))

(defun zddl2:pad2 (n)
  (if (< n 10) (strcat "0" (itoa n)) (itoa n)))

(defun zddl2:parse-wiring (text blocks / recs rows errs idx rec ref principle dest res bucket cables conns ord cabnum c row)
  ;; 返回 (连接列表  错误列表)；连接为 (端子排名称 端子号 原理号 去向柜 电缆号 电缆序号)
  (if (zddl2:blank-p text)
    (list nil nil)
    (progn
      (setq recs (zddl2:split-records text blocks) rows nil errs nil idx 0)
      (foreach rec recs
        (setq idx (1+ idx)
              ref (zddl2:nth-or rec 0)
              principle (zddl2:nth-or rec 1)
              dest (zddl2:nth-or rec 2))
        (if (> (length rec) 3)
          (setq errs (append errs (list (strcat "第 " (itoa idx) " 条「" (zddl2:join-sep rec "、")
                                                "」项数太多，一条只能写 端子号、原理号、去向柜"))))
          (progn
            (setq res (zddl2:ref-matches ref blocks))
            (if (null (car res))
              (setq errs (append errs (list (strcat "第 " (itoa idx) " 条「" (zddl2:join-sep rec "、")
                                                    "」：" (cadr res)))))
              (setq rows (append rows
                (list (list idx (cadr (car (car res))) (caddr (car (car res))) principle dest))))))))
      ;; 分电缆：遇到写了去向柜的记录即结束一根电缆
      (setq cables nil bucket nil)
      (foreach row rows
        (setq bucket (append bucket (list row)))
        (if (/= (nth 4 row) "")
          (progn
            (setq cables (cons (list bucket (nth 4 row)) cables))
            (setq bucket nil))))
      (if bucket (setq cables (cons (list bucket "") cables)))
      (setq cables (reverse cables) conns nil ord 0)
      (foreach c cables
        (setq ord (1+ ord) cabnum (strcat "WL-" (zddl2:pad2 ord)))
        (foreach row (car c)
          (setq conns (append conns
            (list (list (nth 1 row) (nth 2 row) (nth 3 row) (cadr c) cabnum ord))))))
      (if (and (null conns) (null errs))
        (setq errs (list "上面的接线还没填")))
      (list conns errs))))

(defun zddl2:name-number (tok / chars n k prefix digits pieces)
  ;; prepare 中的补全规则：X2:1 形式，或 X21 形式（字母前缀 + 末尾数字）
  (setq pieces (zddl2:split tok (zddl2:colon-chars)))
  (if (and (= (length pieces) 2)
           (/= (car pieces) "") (/= (cadr pieces) "")
           (not (zddl2:has-space-p tok)))
    (list (car pieces) (cadr pieces))
    (progn
      (setq chars (zddl2:chars tok) n (length chars) k n)
      (while (and (> k 0) (zddl2:digit-p (nth (1- k) chars)))
        (setq k (1- k)))
      (setq prefix (zddl2:take chars k) digits (zddl2:drop chars k))
      (if (and (> k 0) (< k n)
               (zddl2:letter-p (nth (1- k) chars))
               (zddl2:prefix-ok-p prefix))
        (list (zddl2:join prefix) (zddl2:join digits))
        nil))))

(defun zddl2:prefix-ok-p (chars / ok ch)
  (setq ok T)
  (foreach ch chars
    (if (not (or (zddl2:letter-p ch) (zddl2:digit-p ch) (equal ch "-")))
      (setq ok nil)))
  ok)

(defun zddl2:has-space-p (tok / hit ch)
  (setq hit nil)
  (foreach ch (zddl2:chars tok)
    (if (member ch (zddl2:ws-list)) (setq hit T)))
  hit)

(defun zddl2:find-block (name blocks / hit b)
  (setq hit nil)
  (foreach b blocks
    (if (and (null hit) (equal (car b) name)) (setq hit b)))
  hit)

(defun zddl2:universe-add (univ name number / b out replaced x)
  (setq b (zddl2:find-block name univ))
  (cond
    ((null b) (append univ (list (list name name (list number) nil))))
    ((member number (caddr b)) univ)
    (T
      (setq out nil replaced nil)
      (foreach x univ
        (if (and (not replaced) (equal (car x) name))
          (setq out (cons (list (car x) (cadr x) (append (caddr x) (list number)) (cadddr x)) out)
                replaced T)
          (setq out (cons x out))))
      (reverse out))))

;; ---------- 布局（build_columns / build_cables / build_dxf） ----------
;; 端子位置 (键 x 中心 序号 行键)；排版行 (名称 标签 端子号列表 中心列表 起点 首格 宽度 行键)

(defun zddl2:columns (blocks / cursors pos layouts order totw cur start first idx x cen key centers width rk b term)
  (setq cursors nil pos nil layouts nil order 0)
  (foreach b blocks
    (setq rk (cadddr b)
          cur (zddl2:al-get cursors rk 0.0)
          start cur
          first (+ start 10.0)
          idx 0
          centers nil)
    (foreach term (caddr b)
      (setq x (+ first (* idx 5.0))
            cen (+ x 2.5)
            key (strcat (car b) (chr 1) term))
      (if (not (assoc key pos))
        (setq pos (cons (list key x cen order rk) pos)))
      (setq centers (cons cen centers) order (1+ order) idx (1+ idx)))
    (setq width (+ 10.0 (* 5.0 (max 1 (length (caddr b))))))
    (setq layouts (append layouts
      (list (list (car b) (cadr b) (caddr b) (reverse centers) start first width rk))))
    (setq cursors (zddl2:al-set cursors rk (+ start width))))
  (setq totw (if cursors (apply 'max (mapcar '(lambda (c) (cadr c)) cursors)) 0.0))
  (list (reverse pos) layouts totw))

(defun zddl2:cables-of (cables rk / out c)
  (setq out nil)
  (foreach c cables
    (if (equal (nth 1 c) rk) (setq out (cons c out))))
  (reverse out))

(defun zddl2:wiring-text (ss / i en ed txt rows cable pair out literal)
  (setq i 0 literal nil)
  (repeat (sslength ss)
    (setq en (ssname ss i) ed (entget en) i (1+ i))
    (if (member (cdr (assoc 0 ed)) '("TEXT" "MTEXT"))
      (progn
        (setq txt (zddl2:text en))
        (if (or (vl-string-search "、" txt) (vl-string-search "，" txt)
                (vl-string-search "," txt)) (setq literal T)))))
  (if literal
    (zddl2:selection-text ss nil)
    (progn
      (setq rows (zddl:parse-wiring-ss ss aa:doc 1e-8 0.1) out "")
      (foreach cable rows
        (foreach pair (car cable)
          (setq out (strcat out (car pair) "、" (cdr pair) "、")))
        (setq out (strcat out (cadr cable) "\n")))
      out)))

(defun zddl2:cables (kept pos / groups key p rk cen ord pt found new-groups g cabs pts leftmost cnt-al idx-al out-cabs pts2 cnt i off leadx c cb q)
  ;; 同一电缆号 + 同一行的端子合并为一根电缆；同一端子接多根电缆时引线等距展开
  ;; 组结构：(电缆号 行键 端子点列表(逆序) 序号 去向柜)；端子点：(键 中心 序号 原理号)
  (setq groups nil)
  (foreach c kept
    (setq key (strcat (nth 0 c) (chr 1) (nth 1 c))
          p (assoc key pos))
    (if p
      (progn
        (setq rk (nth 4 p) cen (nth 2 p) ord (nth 3 p)
              pt (list key cen ord (nth 2 c))
              found nil new-groups nil)
        (foreach g groups
          (if (and (not found) (equal (car g) (nth 4 c)) (equal (cadr g) rk))
            (progn
              (setq new-groups (cons (list (car g) (cadr g) (cons pt (caddr g)) (cadddr g) (nth 4 g))
                                     new-groups))
              (setq found T))
            (setq new-groups (cons g new-groups))))
        (if (not found)
          (setq new-groups (cons (list (nth 4 c) rk (list pt) (nth 5 c) (nth 3 c)) new-groups)))
        (setq groups (reverse new-groups)))))
  (setq cabs nil)
  (foreach g groups
    (setq pts (zddl2:isort (reverse (caddr g)) 1 nil nil)
          leftmost (apply 'min (mapcar '(lambda (q) (caddr q)) pts)))
    (setq cabs (append cabs (list (list (car g) (cadr g) pts leftmost (cadddr g) (nth 4 g))))))
  ;; 电缆按最左端子、再按序号排列（与 build_cables 的排序键一致）
  (setq cabs (zddl2:isort cabs 3 4 nil))
  (setq cnt-al nil)
  (foreach cb cabs
    (foreach q (caddr cb)
      (setq cnt-al (zddl2:al-set cnt-al (car q) (1+ (zddl2:al-get cnt-al (car q) 0))))))
  (setq idx-al nil out-cabs nil)
  (foreach cb cabs
    (setq pts2 nil)
    (foreach q (caddr cb)
      (setq cnt (zddl2:al-get cnt-al (car q) 0)
            i (zddl2:al-get idx-al (car q) 0)
            off (* (- i (/ (- cnt 1) 2.0)) 1.5)
            leadx (+ (cadr q) off))
      (setq idx-al (zddl2:al-set idx-al (car q) (1+ i)))
      ;; 点：(键 中心 序号 原理号 引线 X)
      (setq pts2 (append pts2 (list (list (car q) (cadr q) (caddr q) (cadddr q) leadx)))))
    (setq out-cabs (append out-cabs
      (list (list (car cb) (cadr cb) pts2 (nth 3 cb) (nth 4 cb) (nth 5 cb))))))
  out-cabs)

(defun zddl2:plans (rowkeys cables up / cursor plans rk cnt span blocky pin)
  ;; 每一排的 (块底 Y, 引线端 Y, 电缆跨度)；按 reversed(row_keys) 自下而上堆叠
  (setq cursor 0.0 plans nil)
  (foreach rk (reverse rowkeys)
    (setq cnt (length (zddl2:cables-of cables rk))
          span (if (> cnt 0) (+ 10.0 (* 5.0 (max 0 (- cnt 1)))) 0.0)
          blocky (if up cursor (+ cursor span))
          pin (if up (+ blocky 75.0) blocky))
    (setq plans (zddl2:al-set plans rk (list blocky pin span)))
    (setq cursor (+ cursor 75.0 span 20.0)))
  plans)

(defun zddl2:text-width (s / tw ch)
  ;; 与 text_width 一致：汉字计 1，其它计 0.55；字高 3，宽度因子 0.7
  (setq tw 0.0)
  (foreach ch (zddl2:chars s)
    (setq tw (+ tw (if (zddl2:cjk-p ch) 1.0 0.55))))
  (* (* tw 3.0) 0.7))

(defun zddl2:e-line (p1 p2 layer color)
  (list (list 0 "LINE") (list 8 layer) (list 62 color)
        (list 10 (list (car p1) (cadr p1) 0.0))
        (list 11 (list (car p2) (cadr p2) 0.0))))

(defun zddl2:e-text (content x y layer ha va h rad color)
  ;; 空文字不生成图元（与 text() 的 skip 一致）
  (if (= content "")
    nil
    (list (list 0 "TEXT") (list 8 layer) (list 62 color) (list 7 "HZ")
          (list 40 h) (list 41 0.7) (list 50 rad) (list 72 ha) (list 73 va)
          (list 1 content)
          (list 10 (list x y 0.0)) (list 11 (list x y 0.0)))))

(defun zddl2:e-poly (pts layer color / out p)
  (setq out (list (list 0 "LWPOLYLINE") (list 100 "AcDbEntity") (list 8 layer) (list 62 color)
                  (list 100 "AcDbPolyline") (list 90 (length pts)) (list 70 1)))
  (foreach p pts
    (setq out (append out (list (list 10 (list (car p) (cadr p)))))))
  out)

(defun zddl2:range-list (a b / out k)
  ;; 整数 a 到 b-1
  (setq out nil k a)
  (while (< k b)
    (setq out (cons k out) k (1+ k)))
  (reverse out))

(defun zddl2:clean-ents (lst / out e)
  (setq out nil)
  (foreach e lst
    (if e (setq out (cons e out))))
  (reverse out))

(defun zddl2:draw-layout (l plans / plan y band0 band1 numc startx firstx endx out k term)
  ;; 端子排外框、分隔线、名称与端子号
  (setq plan (zddl2:al-get plans (nth 7 l) nil)
        y (car plan)
        band0 (+ y 35.0)
        band1 (+ band0 5.0)
        numc (+ band0 2.5)
        startx (nth 4 l)
        firstx (nth 5 l)
        endx (+ startx (nth 6 l)))
  (setq out (list
    (zddl2:e-line (list startx y) (list endx y) "端子排-框线" 7)
    (zddl2:e-line (list endx y) (list endx (+ y 75.0)) "端子排-框线" 7)
    (zddl2:e-line (list endx (+ y 75.0)) (list startx (+ y 75.0)) "端子排-框线" 7)
    (zddl2:e-line (list startx (+ y 75.0)) (list startx y) "端子排-框线" 7)
    (zddl2:e-line (list firstx y) (list firstx (+ y 75.0)) "端子排-框线" 7)
    (zddl2:e-line (list firstx band0) (list endx band0) "端子排-框线" 7)
    (zddl2:e-line (list firstx band1) (list endx band1) "端子排-框线" 7)
    (zddl2:e-text (nth 1 l) (+ startx 5.0) (+ y 37.5) "端子排-文字" 1 2 3.0 1.5707963 7)))
  (foreach k (zddl2:range-list 1 (length (nth 2 l)))
    (setq out (append out (list
      (zddl2:e-line (list (+ firstx (* k 5.0)) y) (list (+ firstx (* k 5.0)) (+ y 75.0)) "端子排-框线" 7)))))
  (setq k 0)
  (foreach term (nth 2 l)
    (setq out (append out (list
      (zddl2:e-text term (nth k (nth 3 l)) numc "端子排-文字" 1 2 3.0 1.5707963 7))))
    (setq k (1+ k)))
  out)

(defun zddl2:draw-principles (kept pos plans up / prins out key p cen rk plan blocky y ha pr c)
  ;; 原理号：每个端子取第一个非空原理号；上出线贴顶，下出线贴底
  (setq prins nil out nil)
  (foreach c kept
    (setq key (strcat (nth 0 c) (chr 1) (nth 1 c)))
    (if (and (assoc key pos) (/= (nth 2 c) "") (not (assoc key prins)))
      (setq prins (append prins (list (list key (nth 2 c)))))))
  (foreach pr prins
    (setq p (assoc (car pr) pos)
          cen (nth 2 p)
          rk (nth 4 p)
          plan (zddl2:al-get plans rk nil)
          blocky (car plan))
    (if up
      (setq y (+ blocky 73.0) ha 2)
      (setq y (+ blocky 2.0) ha 0))
    (setq out (append out (list
      (zddl2:e-text (cadr pr) cen y "接线-原理号" ha 2 3.0 1.5707963 4)))))
  out)

(defun zddl2:draw-cables (cables plans rowkeys up tip linr specx / out rk plan pin rowcs k off ycab xs minx depth half cb x)
  ;; 每根电缆：竖向引线、短斜线、横向电缆线、箭头、编号/去向/规格
  (setq out nil half 2.5 depth (* 2.5 (sqrt 3.0)))
  (foreach rk rowkeys
    (setq plan (zddl2:al-get plans rk nil)
          pin (cadr plan)
          rowcs (zddl2:cables-of cables rk)
          k 0)
    (foreach cb rowcs
      (setq off (+ 10.0 (* k 5.0))
            ycab (if up (+ pin off) (- pin off))
            xs (mapcar '(lambda (q) (nth 4 q)) (caddr cb))
            minx (apply 'min xs))
      (foreach x xs
        (setq out (append out (list (zddl2:e-line (list x pin) (list x ycab) "电缆-接线" 7))))
        (if up
          (setq out (append out (list (zddl2:e-line (list (+ x 1.0) ycab) (list x (- ycab 1.0)) "电缆-接线" 7))))
          (setq out (append out (list (zddl2:e-line (list (+ x 1.0) ycab) (list x (+ ycab 1.0)) "电缆-接线" 7))))))
      (setq out (append out (list (zddl2:e-line (list minx ycab) (list linr ycab) "电缆-接线" 3))))
      (setq out (append out (list (zddl2:e-poly
        (list (list tip ycab) (list (- tip depth) (+ ycab half)) (list (- tip depth) (- ycab half)))
        "电缆-接线" 7))))
      (setq out (append out (list
        ;; 图上电缆编号统一写“未编号”；内部 WL-xx 仅用于区分电缆分组，不再输出
        (zddl2:e-text "未编号" (- tip 20.0) (+ ycab 0.5) "电缆-文字" 0 0 3.0 0.0 7)
        (zddl2:e-text (strcat "至" (if (/= (nth 5 cb) "") (nth 5 cb) "未填写")) (+ tip 1.5) (+ ycab 0.5) "电缆-文字" 0 0 3.0 0.0 7)
        (zddl2:e-text "未填写" specx (+ ycab 0.5) "电缆-文字" 0 0 3.0 0.0 7))))
      (setq k (1+ k))))
  out)

(defun zddl2:entities (blocks kept up / cols pos layouts totw rowkeys cables plans nterm ncable nrow
                                        bus numx tip linr specx tops ents out cb pl l)
  ;; 返回 (图元列表  端子数  电缆数)；图元坐标相对于基点原点
  (setq cols (zddl2:columns blocks) pos (car cols) layouts (cadr cols) totw (caddr cols))
  (setq rowkeys (zddl2:uniq (mapcar '(lambda (l) (nth 7 l)) layouts)))
  (setq cables (zddl2:cables kept pos))
  (setq plans (zddl2:plans rowkeys cables up))
  (setq nterm (apply '+ (mapcar '(lambda (l) (length (nth 2 l))) layouts))
        ncable (length cables)
        nrow (length rowkeys))
  (setq bus (+ totw 18.0)
        numx (+ bus 4.0)
        tip (+ numx 20.0)
        linr (+ tip 40.0)
        specx (+ tip 32.0))
  ;; 不再绘制“端子排接线图”标题及统计说明文字
  (setq ents nil)
  (foreach l layouts
    (setq ents (append ents (zddl2:draw-layout l plans))))
  (setq ents (append ents (zddl2:draw-principles kept pos plans up)))
  (setq ents (append ents (zddl2:draw-cables cables plans rowkeys up tip linr specx)))
  (list (zddl2:clean-ents ents) nterm ncable))

(defun zddl2:shift-pt (p bx by bz)
  (if (= (length p) 3)
    (list (+ bx (car p)) (+ by (cadr p)) (+ bz (caddr p)))
    (list (+ bx (car p)) (+ by (cadr p)))))

(defun zddl2:shift (ent bx by bz)
  (mapcar '(lambda (g)
             (if (or (= (car g) 10) (= (car g) 11))
               (list (car g) (zddl2:shift-pt (cadr g) bx by bz))
               g))
          ent))

(defun zddl2:to-dxf (ent)
  (mapcar '(lambda (g) (cons (car g) (cadr g))) ent))

(defun zddl2:err-join (errs)
  (zddl2:join-sep (zddl2:take errs 10) "；"))

(defun zddl2:generate (term-text wiring-text up / pr blocks errs univ cands fields n i tok2 nn wr conns werr keys kept skipped ent unit tok b term c)
  ;; 返回 (结果  信息/错误  图元列表)；结果为 "OK" 或 "ERR"
  (setq pr (zddl2:parse-terminals term-text)
        blocks (car pr)
        errs (cadr pr))
  (if errs
    (list "ERR" (zddl2:err-join errs) nil)
    (progn
      ;; 接线中出现的未选端子也要能解析，以便生成完整电缆（与 prepare 一致）
      (setq univ blocks cands nil)
      (foreach unit (zddl2:units wiring-text)
        (setq fields (mapcar '(lambda (f) (zddl2:trim f)) (zddl2:split unit (zddl2:field-delims)))
              n (length fields)
              i 0)
        (while (< i (1- n))
          (setq cands (append cands (list (nth i fields))))
          (setq i (+ i 2))))
      (foreach tok cands
        (setq tok2 (zddl2:trim tok))
        (if (not (zddl2:looks-ref tok2 univ))
          (progn
            (setq nn (zddl2:name-number tok2))
            (if nn (setq univ (zddl2:universe-add univ (car nn) (cadr nn)))))))
      (setq wr (zddl2:parse-wiring wiring-text univ)
            conns (car wr)
            werr (cadr wr))
      (if werr
        (list "ERR" (zddl2:err-join werr) nil)
        (progn
          (setq keys nil)
          (foreach b blocks
            (foreach term (caddr b)
              (setq keys (cons (strcat (car b) (chr 1) term) keys))))
          (setq kept nil)
          (foreach c conns
            (if (member (strcat (nth 0 c) (chr 1) (nth 1 c)) keys)
              (setq kept (cons c kept))))
          (setq kept (reverse kept)
                skipped (- (length conns) (length kept)))
          (setq ent (zddl2:entities blocks kept up))
          (list "OK"
                (strcat "生成 " (itoa (cadr ent)) " 个端子、" (itoa (caddr ent))
                        " 组电缆；跳过未选端子的 " (itoa skipped) " 条接线。")
                (car ent)))))))

(defun zddl2:work (/ terminals wiring kw up point coordinate i txt res check layers layer data count total bx by bz ent e3)
  (cond
    (T
      (princ "\n[ZDDL] 第一步：选择端子名及端子号文字，空格确认：")
      (setq terminals (ssget '((0 . "TEXT,MTEXT"))))
      (if terminals
        (progn
          ;; 普通格式为“排名、1、2”；原理图散字按 DZ 规则自动区分端子名与端子号，横排、竖排均可。
          (setq coordinate T i 0)
          (repeat (sslength terminals)
            (setq txt (zddl2:text (ssname terminals i)) i (1+ i))
            (if (or (vl-string-search "、" txt) (vl-string-search "，" txt)
                    (vl-string-search "," txt))
              (setq coordinate nil)))
          (princ "\n[ZDDL] 第二步：选择电缆接线文字，空格确认：")
          (setq wiring (ssget))
          (if wiring
            (progn
              (initget "Shang Xia")
              (setq kw (getkword "\n出线方向 [向上(Shang)/向下(Xia)] <向上>: "))
              (setq up (not (equal kw "Xia")))
              (setq point (getpoint "\n[ZDDL] 第三步：指定生成图左下基点："))
              (if point
                (progn
                  (setq point (trans point 1 0))
                  (setq res (zddl2:generate (zddl2:selection-text terminals coordinate)
                                            (zddl2:wiring-text wiring) up))
                  (if (equal (car res) "ERR")
                    (princ (strcat "\n[ZDDL] 生成失败：" (cadr res)))
                    (progn
                      ;; 先检查需保留图层，避免锁层导致半幅生成；整批仍在一个 UNDO 中。
                      ;; 端子排辅助层（框线、端子名/号）由本命令自行解锁、生成后再锁定。
                      (setq check T)
                      (setq layers '("端子排-框线" "端子排-文字" "接线-原理号" "电缆-接线" "电缆-文字" "图签-文字"))
                      (foreach layer layers
                        (if (and (not (member layer (zddl2:scaffold-layers)))
                                 (setq data (tblsearch "LAYER" layer))
                                 (/= 0 (logand 4 (cdr (assoc 70 data)))))
                          (setq check nil)))
                      (if check
                        (progn
                          (foreach layer layers
                            (zddl:ensure-layer layer 7))
                          (if (not (tblsearch "STYLE" "HZ"))
                            (entmake '((0 . "STYLE") (2 . "HZ") (70 . 0) (40 . 0.0) (41 . 0.7)
                                       (50 . 0.0) (71 . 0) (42 . 3.0) (3 . "txt.shx") (4 . "hztxt.shx"))))
                          (regapp (zddl2:xdata-app))
                          (foreach layer (zddl2:scaffold-layers)
                            (zddl2:set-layer-lock layer nil))
                          (setq count 0 total (length (caddr res))
                                bx (car point) by (cadr point) bz (caddr point))
                          (foreach ent (caddr res)
                            (setq e3 (zddl2:to-dxf (zddl2:shift ent bx by bz)))
                            (if (= (cdr (assoc 0 e3)) "LWPOLYLINE")
                              (setq e3 (append e3 (list (cons 38 bz)))))
                            ;; 辅助层图元打标记，供 ZDDLD 用完后一键删除
                            (if (member (cdr (assoc 8 e3)) (zddl2:scaffold-layers))
                              (setq e3 (append e3 (list (list -3 (list (zddl2:xdata-app) (cons 1000 "ZDDL")))))))
                            (if (entmake e3)
                              (setq count (1+ count))))
                          ;; 锁定辅助层：仍可见但不可选，便于只框选原理号、电缆接线和电缆文字
                          (foreach layer (zddl2:scaffold-layers)
                            (zddl2:set-layer-lock layer T))
                          (redraw)
                          (if (= count total)
                            (princ (strcat "\n[ZDDL] " (cadr res)))
                            (princ "\n[ZDDL] 部分图元创建失败，请用一次 U 撤销本批。"))
                          (princ "\n[ZDDL] 端子排框线与端子名/号已锁定（不可选）；用完后输入 ZDDLD 删除。"))
                        (princ "\n[ZDDL] 原理号/电缆图层已锁定，请解锁后重试。"))))))))))))
  (princ))

(defun zddl2:scaffold-layers ()
  ;; ZDDL 生成的辅助图层：仅供对照，用完删除
  '("端子排-框线" "端子排-文字"))

(defun zddl2:xdata-app ()
  "AA_ZDDL")

(defun zddl2:set-layer-lock (name lock / data flags)
  ;; 修改图层锁定状态；图层不存在时不处理
  (if (setq data (tblobjname "LAYER" name))
    (progn
      (setq data  (entget data)
            flags (cdr (assoc 70 data)))
      (entmod (subst (cons 70 (if lock (logior flags 4) (logand flags (~ 4))))
                     (assoc 70 data)
                     data)))))

;;; =======================================================================================
;;; 命令: ZDDLD
;;; 功能: 删除 ZDDL 生成的端子排框线与端子名/号（锁定的辅助图元），保留原理号、电缆接线和电缆文字，一次 U 撤销。
;;; =======================================================================================
(defun c:ZDDLD (/ *error* aa:tag aa:doc aa:undo-open aa:old-cmdecho
                  ss i ent lname locked count)
  (aa:cmd-begin "ZDDLD")
  (setq ss (ssget "_X" (list (list -3 (list (zddl2:xdata-app))))))
  (if ss
    (progn
      ;; 先记下并解锁图元所在的锁定图层，删完再恢复，避免锁层导致删除失败
      (setq i 0 locked nil count 0)
      (repeat (sslength ss)
        (setq lname (cdr (assoc 8 (entget (ssname ss i))))
              i     (1+ i))
        (if (and (not (member lname locked))
                 (aa:layer-locked-p lname))
          (progn
            (setq locked (cons lname locked))
            (zddl2:set-layer-lock lname nil))))
      (setq i 0)
      (repeat (sslength ss)
        (setq ent (ssname ss i)
              i   (1+ i))
        (if (entdel ent)
          (setq count (1+ count))))
      (foreach lname locked
        (zddl2:set-layer-lock lname T))
      (redraw)
      (princ (strcat "\n[ZDDLD] 已删除 " (itoa count)
                     " 个 ZDDL 端子排辅助图元；原理号、电缆接线和电缆文字保留。")))
    (princ "\n[ZDDLD] 图中没有 ZDDL 生成的端子排辅助图元。"))
  (aa:cmd-end))

;;; --- BDL：给后补的原理号补画一根 ZDDL 样式的电缆 ---
;; 尺寸沿用 zddl2:draw-cables：第 1 根电缆距端子排 10，之后每根错开 5；箭头尖端左 20 写编号、右 1.5 写去向、右 32 写截面，电缆线到尖端右 40。
;; 端子排边线、端子格竖线、已有引线用小窗口 ssget "_C" 查找（原理号附近需在当前视图内）。

(defun bdl:cross-lines (p1 p2 / ss i ed out)
  ;; 小窗口交叉选择 LINE，返回 ((起点 终点) ...)；p1/p2 为 WCS
  (setq ss (ssget "_C" (trans p1 0 1) (trans p2 0 1) '((0 . "LINE")))
        i 0 out nil)
  (if ss
    (repeat (sslength ss)
      (setq ed (entget (ssname ss i)) i (1+ i))
      (setq out (cons (list (cdr (assoc 10 ed)) (cdr (assoc 11 ed))) out))))
  out)

(defun bdl:horizontal-p (ln)
  (and (< (abs (- (cadr (car ln)) (cadr (cadr ln)))) 0.01)
       (> (abs (- (car (car ln)) (car (cadr ln)))) 1.0)))

(defun bdl:vertical-p (ln)
  (and (< (abs (- (car (car ln)) (car (cadr ln)))) 0.01)
       (> (abs (- (cadr (car ln)) (cadr (cadr ln)))) 1.0)))

(defun bdl:edge (cx ylo yhi / below above d y ln)
  ;; 原理号上下 4 以内、跨过 cx 的水平线：返回 (下方最近 上方最近)，各为 (距离 Y) 或 nil。
  ;; 文字两端允许压线 0.5（手工补的原理号常比格子略长）
  (setq below nil above nil)
  (foreach ln (bdl:cross-lines (list (- cx 0.05) (- ylo 4.0) 0.0) (list (+ cx 0.05) (+ yhi 4.0) 0.0))
    (if (bdl:horizontal-p ln)
      (progn
        (setq y (cadr (car ln)))
        (if (<= y (+ ylo 0.5))
          (progn
            (setq d (max 0.0 (- ylo y)))
            (if (or (null below) (< d (car below))) (setq below (list d y)))))
        (if (>= y (- yhi 0.5))
          (progn
            (setq d (max 0.0 (- y yhi)))
            (if (or (null above) (< d (car above))) (setq above (list d y))))))))
  (list below above))

(defun bdl:direction (items / los his lo-sp hi-sp nb na db da e)
  ;; 整组判断出线方向：1 向上、-1 向下、nil 判断不了。
  ;; ZDDL 向下出线的原理号底端对齐（贴下边线），向上出线顶端对齐；长短不一时据此判断，否则看哪侧边线更近
  (setq los (mapcar 'cadr items) his (mapcar 'caddr items)
        lo-sp (- (apply 'max los) (apply 'min los))
        hi-sp (- (apply 'max his) (apply 'min his))
        nb 0 na 0 db 0.0 da 0.0)
  (foreach e (mapcar 'cadddr items)
    (if (car e) (setq nb (1+ nb) db (+ db (car (car e)))))
    (if (cadr e) (setq na (1+ na) da (+ da (car (cadr e))))))
  (cond
    ((and (< lo-sp 0.2) (> hi-sp 0.2)) -1)
    ((and (< hi-sp 0.2) (> lo-sp 0.2)) 1)
    ((> nb na) -1)
    ((> na nb) 1)
    ((= nb 0) nil)
    ((<= db da) -1)
    (T 1)))

(defun bdl:cell-center (cx yin / left right x ln)
  ;; 端子格左右竖线的中点；找不到格线（如已 ZDDLD）时用原理号中心 X
  (setq left nil right nil)
  (foreach ln (bdl:cross-lines (list (- cx 5.5) yin 0.0) (list (+ cx 5.5) yin 0.0))
    (if (bdl:vertical-p ln)
      (progn
        (setq x (car (car ln)))
        (if (and (<= x cx) (or (null left) (> x left))) (setq left x))
        (if (and (>= x cx) (or (null right) (< x right))) (setq right x)))))
  (if (and left right (<= 3.0 (- right left) 7.0))
    (/ (+ left right) 2.0)
    cx))

(defun bdl:lead-used-p (x pin s used / hit ln)
  ;; 本次已用，或端子排外 0.5 处已有竖直引线
  (setq hit (vl-some '(lambda (u) (< (abs (- u x)) 0.3)) used))
  (if (not hit)
    (foreach ln (bdl:cross-lines (list (- x 0.3) (+ pin (* s 0.5)) 0.0)
                                 (list (+ x 0.3) (+ pin (* s 0.5)) 0.0))
      (if (bdl:vertical-p ln) (setq hit T))))
  hit)

(defun bdl:lead-x (cen pin s used / x c)
  ;; 端子中心已有引线时按 ZDDL 的 1.5 间距错开
  (setq x nil)
  (foreach c (list cen (+ cen 1.5) (- cen 1.5) (+ cen 3.0) (- cen 3.0))
    (if (and (null x) (not (bdl:lead-used-p c pin s used)))
      (setq x c)))
  (if x x cen))

(defun bdl:green-lines (/ ss i ed p1 p2 out)
  ;; 当前空间全部绿色水平 LINE：((Y 左X 右X) ...)
  (setq ss (ssget "_X" (list '(0 . "LINE") '(62 . 3) (cons 410 (getvar "CTAB"))))
        i 0 out nil)
  (if ss
    (repeat (sslength ss)
      (setq ed (entget (ssname ss i)) i (1+ i)
            p1 (cdr (assoc 10 ed)) p2 (cdr (assoc 11 ed)))
      (if (bdl:horizontal-p (list p1 p2))
        (setq out (cons (list (cadr p1) (min (car p1) (car p2)) (max (car p1) (car p2))) out)))))
  out)

(defun bdl:tips (/ ss i ed pts best p out)
  ;; 当前空间全部三点闭合多段线的尖端（X 最大的顶点）：((X Y) ...)
  (setq ss (ssget "_X" (list '(0 . "LWPOLYLINE") '(90 . 3) (cons 410 (getvar "CTAB"))))
        i 0 out nil)
  (if ss
    (repeat (sslength ss)
      (setq ed (entget (ssname ss i)) i (1+ i) best nil)
      (foreach p ed
        (if (= (car p) 10)
          (if (or (null best) (> (cadr p) (car best)))
            (setq best (cdr p)))))
      (if best (setq out (cons best out)))))
  out)

(defun bdl:slot-line (greens y minx / hit g)
  ;; Y 处挡住新电缆的绿色电缆线（右端越过最左引线，左端不远于 400）
  (setq hit nil)
  (foreach g greens
    (if (and (null hit)
             (< (abs (- (car g) y)) 1.0)
             (>= (caddr g) (- minx 0.5))
             (<= (cadr g) (+ minx 400.0)))
      (setq hit g)))
  hit)

(defun bdl:line-tip (g tips / hit t2)
  ;; 电缆线上的箭头尖端 X
  (setq hit nil)
  (foreach t2 tips
    (if (and (null hit)
             (< (abs (- (cadr t2) (car g))) 0.05)
             (< (cadr g) (car t2) (+ (caddr g) 0.05)))
      (setq hit (car t2))))
  hit)

(defun bdl:work (/ ss i en bbox items it cx edge pin s kw cen x used xs minx maxx
                   greens tips k run lastk free g stack ycab p tip linr best bestd d gtip
                   layers lname ok ents count)
  (princ "\n[BDL] 选择后补的原理号文字（同一根电缆的一起选），空格确认：")
  (setq ss (ssget '((0 . "TEXT,MTEXT"))))
  (if ss
    (progn
      ;; 1. 原理号包围盒，找各自的端子排边线
      (setq i 0 items nil)
      (repeat (sslength ss)
        (setq en (ssname ss i) i (1+ i)
              bbox (aa:safe-get-bbox aa:doc en))
        (if bbox
          (progn
            (setq cx (aa:bbox-center-x bbox))
            (setq items (cons (list cx (aa:bbox-bottom-y bbox) (aa:bbox-top-y bbox)
                                    (bdl:edge cx (aa:bbox-bottom-y bbox) (aa:bbox-top-y bbox)))
                              items)))))
      (setq items (reverse items) ok T pin nil s nil)
      (if items
        (progn
          ;; 先整组定方向，再取该侧边线；同一根电缆的原理号边线应在同一高度
          (setq s (bdl:direction items))
          (if (null s)
            (progn
              ;; 找不到端子排边线（如已 ZDDLD）且原理号等长时询问方向
              (initget "Shang Xia")
              (setq kw (getkword "\n[BDL] 未找到端子排边线，出线方向 [向上(Shang)/向下(Xia)] <向下>: ")
                    s (if (equal kw "Shang") 1 -1))))
          (foreach it items
            (if (setq edge (if (= s -1) (car (nth 3 it)) (cadr (nth 3 it))))
              (if pin
                (if (> (abs (- pin (cadr edge))) 1.0)
                  (setq ok nil)
                  (setq pin (if (= s -1) (max pin (cadr edge)) (min pin (cadr edge)))))
                (setq pin (cadr edge)))))
          ;; 该侧没有边线时按 ZDDL 原理号距边 2 反推
          (if (null pin)
            (setq pin (if (= s 1)
                        (+ (apply 'max (mapcar 'caddr items)) 2.0)
                        (- (apply 'min (mapcar 'cadr items)) 2.0))))))
      (cond
        ((null items)
         (princ "\n[BDL] 未读到原理号文字的范围。"))
        ((not ok)
         (princ (strcat "\n[BDL] 所选原理号" (if (= s 1) "上" "下")
                        "方的端子排边线高度不一致（相差超过 1），请只选同一排端子上同一根电缆的原理号。")))
        (T
         ;; 2. 引线 X：端子格中心，已有引线时错开 1.5
         (setq used nil)
         (foreach it items
           (setq cen (bdl:cell-center (car it) (- pin s))
                 x (bdl:lead-x cen pin s used)
                 used (cons x used)))
         (setq xs (reverse used)
               minx (apply 'min xs)
               maxx (apply 'max xs))
         ;; 3. 从端子排往外逐行查空位：中间空出的行优先；连续空 4 行视为电缆组结束
         (setq greens (bdl:green-lines)
               tips (bdl:tips)
               k 0 run 0 lastk -1 stack nil)
         (while (and (<= k 200) (<= run 3))
           (if (setq g (bdl:slot-line greens (+ pin (* s (+ 10.0 (* 5.0 k)))) minx))
             (setq lastk k run 0 stack (cons g stack))
             (setq run (1+ run)))
           (setq k (1+ k)))
         (setq k 0 free nil)
         (while (and (null free) (< k lastk))
           (if (not (bdl:slot-line greens (+ pin (* s (+ 10.0 (* 5.0 k)))) minx))
             (setq free k))
           (setq k (1+ k)))
         (cond
           (free (setq ycab (+ pin (* s (+ 10.0 (* 5.0 free))))))
           ((< lastk 0) (setq ycab (+ pin (* s 10.0))))
           ;; 没有空行：接在最后一根之后
           (T (setq ycab (+ pin (* s (+ 10.0 (* 5.0 (1+ lastk))))))))
         ;; 4. 箭头与文字位置对齐最近一根已有电缆；没有电缆时让用户指定箭头尖端
         (setq tip nil linr nil best nil bestd nil)
         (foreach g stack
           (setq d (abs (- (car g) ycab)) gtip (bdl:line-tip g tips))
           (if (and gtip (or (null bestd) (< d bestd)))
             (setq best g bestd d tip gtip linr (caddr g))))
         (if (and (null tip) stack)
           (setq g (car stack) linr (caddr g) tip (- linr 40.0)))
         (if (null tip)
           (if (setq p (getpoint "\n[BDL] 附近没有已有电缆，指定箭头尖端位置: "))
             (setq tip (car (trans p 1 0)) linr (+ tip 40.0))))
         (if tip
           (progn
             (setq layers '("电缆-接线" "电缆-文字") ok T)
             (foreach lname layers
               (if (and (tblsearch "LAYER" lname) (aa:layer-locked-p lname))
                 (setq ok nil)))
             (if ok
               (progn
                 (foreach lname layers (zddl:ensure-layer lname 7))
                 (if (not (tblsearch "STYLE" "HZ"))
                   (entmake '((0 . "STYLE") (2 . "HZ") (70 . 0) (40 . 0.0) (41 . 0.7)
                              (50 . 0.0) (71 . 0) (42 . 3.0) (3 . "txt.shx") (4 . "hztxt.shx"))))
                 ;; 5. 与 zddl2:draw-cables 相同的图元：引线、短斜线、电缆线、箭头、三段文字
                 (setq ents nil)
                 (foreach x xs
                   (setq ents (cons (zddl2:e-line (list x pin) (list x ycab) "电缆-接线" 7) ents))
                   (setq ents (cons (zddl2:e-line (list (+ x 1.0) ycab) (list x (- ycab s)) "电缆-接线" 7) ents)))
                 (setq ents (cons (zddl2:e-line (list minx ycab) (list linr ycab) "电缆-接线" 3) ents))
                 (setq ents (cons (zddl2:e-poly
                                    (list (list tip ycab)
                                          (list (- tip (* 2.5 (sqrt 3.0))) (+ ycab 2.5))
                                          (list (- tip (* 2.5 (sqrt 3.0))) (- ycab 2.5)))
                                    "电缆-接线" 7)
                                  ents))
                 (setq ents (cons (zddl2:e-text "未编号" (- tip 20.0) (+ ycab 0.5) "电缆-文字" 0 0 3.0 0.0 7) ents)
                       ents (cons (zddl2:e-text "至未填写" (+ tip 1.5) (+ ycab 0.5) "电缆-文字" 0 0 3.0 0.0 7) ents)
                       ents (cons (zddl2:e-text "未填写" (+ tip 32.0) (+ ycab 0.5) "电缆-文字" 0 0 3.0 0.0 7) ents))
                 (setq count 0)
                 (foreach g (reverse ents)
                   (if (entmake (zddl2:to-dxf g)) (setq count (1+ count))))
                 (redraw)
                 (if (= count (length ents))
                   (princ (strcat "\n[BDL] 已补画 1 根电缆（" (itoa (length xs)) " 根引线，距端子排 "
                                  (rtos (abs (- ycab pin)) 2 1) "）；填写去向后可运行 JM 补截面、BH1 编号。"))
                   (princ "\n[BDL] 部分图元创建失败，请用一次 U 撤销本批。")))
               (princ "\n[BDL] 电缆图层已锁定，请解锁后重试。")))
           (princ "\n[BDL] 未指定箭头位置，已取消。")))))
    (princ "\n[BDL] 未选择原理号。"))
  (princ))

;;; =======================================================================================
;;; 命令: BDL
;;; 功能: 选择端子排上后补的原理号文字，按 ZDDL 样式自动补画引线、短斜线、绿色电缆线、箭头及“未编号/至未填写/未填写”，自动找电缆组空行，没有空行时接在最后一根之后，一次 U 撤销。
;;; =======================================================================================
(defun c:BDL (/ *error* aa:tag aa:doc aa:undo-open aa:old-cmdecho result)
  (aa:cmd-begin "BDL")
  (setq result (vl-catch-all-apply 'bdl:work nil))
  (if (vl-catch-all-error-p result)
    (princ (strcat "\n[BDL] " (vl-catch-all-error-message result))))
  (aa:cmd-end)
  (princ))

;;; =======================================================================================
;;; 命令: ZDDL
;;; 功能: 依次选择端子名/端子号文字与电缆接线文字，指定左下基点后生成端子排与电缆，一次 U 撤销。
;;; =======================================================================================
(defun c:ZDDL (/ *error* aa:tag aa:doc aa:undo-open aa:old-cmdecho result)
  (aa:cmd-begin "ZDDL")
  (setq result (vl-catch-all-apply 'zddl2:work nil))
  (if (vl-catch-all-error-p result)
    (princ (strcat "\n[ZDDL] " (vl-catch-all-error-message result))))
  (aa:cmd-end)
  (sssetfirst nil nil)
  (princ))
