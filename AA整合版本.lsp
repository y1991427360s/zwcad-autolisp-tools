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
;;;   - HDDL  : 直接校核选中文字中的电缆编号和原理号，问题行标红并在行首标注。
;;;   - QSTXT : 快速从当前选择中仅选中所有文字对象。
;;;   - T     : 把字体刷为HZ样式，高度3，宽度0.7。
;;;   - T2    : 将文字刷为HZ/0.7样式并字高优先避让周围线框，优先3.0字高微移，避免文字缩小。
;;;   - H     : 先将选中文字统一为左中对正，再按指定间距从上到下排列。
;;;   - H2    : 先将选中文字统一为左中对正，右侧文字在最上、越靠左越靠下，按指定间距从上到下排列。
;;;   - Y     : 将选中对象的颜色快速变为青色。
;;;   - YY    : 将选中对象快速改为黄色。
;;;   - RR    : 将选中对象快速改为红色。
;;;   - WW    : 将选中对象快速改为白色；支持尺寸标注（转角标注等全要素变白）、引线及块内实体。
;;;   - GG    : 将选中对象快速改为绿色。
;;;   - HH    : 将选中对象快速改为洋红色。
;;;   - HUI   : 将选中对象快速改为颜色 8；遇到引线先分解再改色，遇到块参照连块内实体一起改。
;;;   - ZHONG : 文字居中对齐；选择直线/矩形时按中心 X 居中。
;;;   - ZHENG : 以水平直线或矩形中心为基准整理文字的水平位置。
;;;   - ZUO   : 将选中文字统一为左中对正，并以最上方文字为基准左对齐。
;;;   - AZUO  : 选择一条竖直直线作为基准线，框选其他所有对象作为一个整体整体移动并左对齐到该直线。
;;;   - HP    : 将选中文字按从左到右排列，使相邻文字首尾间距为指定值，并按最左文字上边对齐。
;;;   - HP2   : 将选中文字改为正中对齐，按中心点指定间距从左到右横向排列。
;;;   - YOU   : 将选中文字统一为右中对正，并以最上方文字为基准右对齐。
;;;   - AYOU  : 选择一条竖直直线作为基准线，框选其他所有对象作为一个整体整体移动并右对齐到该直线。
;;;   - SHANG : 将选中文字统一为中上对正，并以最上方文字为基准上对齐。
;;;   - ASHANG: 选择一条水平直线作为基准线，框选其他所有对象作为一个整体整体移动并向上对齐到该直线。
;;;   - XIA   : 将选中文字统一为中下对正，并以最左侧文字为基准下对齐。
;;;   - AXIA  : 选择一条水平直线作为基准线，框选其他所有对象作为一个整体整体移动并向下对齐到该直线。
;;;   - HE    : 将同一行的两个或以上文字合并。
;;;   - QR    : 快速修改文字高度。
;;;   - QR2   : 连续选择文字并逐轮输入高度进行修改，按 Esc 退出。
;;;   - DEA   : 删除所选对象中高度小于 0.1 的 TEXT/MTEXT 文字。
;;;   - DEK   : 删除选中内容中的所有块参照 (INSERT)。
;;;   - DES   : 所选直线共线重叠时删除短线、保留长线；完全重复留一条，跨图层处理并跳过锁定图层。
;;;   - WI    : 修改选中文字的宽度比例。
;;;   - ATW   : 拾取两点指定最大宽度，将超宽单行文字的宽度比例缩小至两点间距的 95% 并保持左侧不动。
;;;   - XB    : 将选中的文字或尺寸标注整体缩小为原来的十分之一，并保留选择状态。
;;;   - YAN   : 延长竖直直线统一间距，支持分组和上下方向控制。
;;;   - SYAN  : 将选中直线向上延长 5 个单位。
;;;   - XYAN  : 将选中直线向下延长 5 个单位。
;;;   - SYI   : 预选对象中非竖直对象向上移动 5X，竖直直线向上拉伸 5X。
;;;   - XYI   : 预选对象中非竖直对象向下移动 5X，竖直直线向下拉伸 5X。
;;;   - SS    : 拉伸对象并记忆方向与距离，支持动态拉伸实时预览，后续可直接回车重复。
;;;   - SSS   : 将预选对象按 CAD 原生拉伸规则向右拉伸 3 个单位。
;;;   - SJ    : 在选中直线顶端生成上接短线。
;;;   - XJ    : 在选中直线底端生成下接短线。
;;;   - SYJ   : 将选中竖直直线向上延长 5 个单位，再生成上接短线。
;;;   - XYJ   : 将选中竖直直线向下延长 5 个单位，再生成下接短线。
;;;   - GTX   : 按自动容差整理单行/多行电缆文字并自然排序汇总。
;;;   - GTY   : 汇总并按电缆编号排序整理电缆文字。
;;;   - GTZ   : 将选中的交替柜名与电缆编号单列文字，按前后柜与编号重组为3列表格输出。
;;;   - BIAN  : 根据选中直线生成方向三角、至字样和电缆规格标注。
;;;   - LAN   : 竖直线/斜线/水平线联动复制+移动插件。
;;;   - XIN   : 统计选中直线矩形范围内的对象数量并标注结果。
;;;   - XY    : 自动筛选所选中的绿色水平直线，先运行 XIN 统计芯数，再运行 YUAN 提取对应文字并横向输出。
;;;   - XYG   : 一次框选，自动提取绿色直线执行 XY 统计，并提取大字与电缆文字执行 GTX 分类汇总。
;;;   - HB    : 框选电缆清册表格文字，自动将带有“并入”前缀的行合并到对应的目标电缆主行中，自动累加芯数并合并排序原理号。
;;;   - NU    : 材料表数字加数字，从选中文字中提取数字并执行加法运算。
;;;   - KAI   : 将 TEXT/MTEXT 中由空格分隔的内容拆分为多个独立文字。
;;;   - GE    : 选中同一水平行的单行文字，按文字间隙绘制单行表格。
;;;   - UT    : 先将文字统一为左中对正，再按最上方一对的位置整理文字；支持直线及按首尾端点计算的未闭合多段线，保留宽度。
;;;   - HAO   : 选中图框后批量填写页码和档案号。
;;;   - HAO2  : 指定基准块参照与图号矩形范围，批量居中填充或更新递增图号文字。
;;;   - FIVE  : 将测得高度按比例缩放为 5。
;;;   - CE    : 测量点序列形成的多段线总长度。
;;;   - CU    : 将选中对象按 5 个单位的递增间距向上复制指定份数。
;;;   - CD    : 将选中对象按 5 个单位的递增间距向下复制指定份数。
;;;   - JZ    : 将矩形水平中线对齐到1条或2条直线中心线，可同步居中文字。
;;;   - DX    : 批量整理 100×100 方格内的端子号、原理号和终点柜文字，并将整组文字居中。
;;;   - FDX   : 先选方框，再连续选择每批文字，按空格依次移动到下一方框并自动按 DX 规则排列。
;;;   - DX1   : 提取选中文字及坐标，青色文字额外标注“端子名”，复制到剪贴板。
;;;   - DX2   : 按方格从左到右、从上到下导出文字，每个方格一行，框内按行排序并用顿号连接，复制到剪贴板。
;;;   - ZZ    : 先将文字改为中下对正，再居中到最近矩形；多行文字按 5 个单位的中心间距排列。
;;;   - MJ    : 框选单列表格后，按最长文字自动收窄宽度并将各行文字居中。
;;;   - JACC  : ZZ 的同功能入口。
;;;   - DB    : 删除每个选中文字末尾的 N 个字符。
;;;   - DF    : 删除每个选中文字开头的 N 个字符。
;;;   - DE    : 删除选中文字的最右侧括号及括号内容。
;;;   - DE2   : 用最右侧括号内容替换括号前连续数字。
;;;   - DL1   : 创建电缆柜、电缆路径、电缆竖井相关的 1F / 2F 图层。
;;;   - AB    : 在每个选中文字末尾增加输入的文字。
;;;   - AF    : 在每个选中文字开头增加输入的文字。
;;;   - QW    : 提取选中文字，同一行用顿号连接，不同行之间也用顿号分隔，并复制到剪贴板。
;;;   - QW2   : 提取选中文字及坐标，每项一行“x,y 文字”，坐标保留 2 位小数，复制到剪贴板。
;;;   - REP   : 将选中的柜名文字按内置映射表替换为标准柜名。
;;;   - QE    : 用 Windows 剪贴板中的文字批量替换选中文字；文字含“至”字时只替换“至”后的部分。
;;;   - CC    : 读取 Windows 剪贴板，连续复制并替换副本文字，使用原生拖动预览和对象捕捉。
;;;   - AW    : 自动微移选中文字，尽量避开旁边线段、文字和其他对象重叠。
;;;   - ZDML  : 选择多个图框块，生成目录文字。
;;;   - ZDML2 : 指定基准块参照与图名、图号矩形范围，批量提取图名图号并生成目录。
;;;   - ZDMLDEBUG : 选择一个图框块，打印所有增强属性。
;;;   - DUMP  : 打印选中图元的 ActiveX 属性与可用方法（调试辅助）。
;;;   - AAE   : 选择块内属性文字，在自定义窗口中编辑并按回车直接保存。
;;;   - C1    : 复制文字并递增减号右侧编号，使用原生拖动预览和捕捉连续放置。
;;;   - C2    : 复制文字并递减减号右侧编号，使用原生拖动预览和捕捉连续放置。
;;;   - C3    : 复制文字并每次将减号右侧编号加 2，使用原生拖动预览和捕捉连续放置。
;;;   - ZJ    : 选中两条水平线后向左生成短线、矩形并居中标注原理号及终点柜名（青色虚线）。
;;;   - YJ    : 选中两条水平线后向右生成短线、矩形并居中标注原理号及终点柜名（青色虚线）。
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
;;;   - XU    : 将所有选中且支持线型修改的对象改为 HIDDEN2。
;;;   - 0     : 将所选对象中的文字旋转角度统一改为 0 度。
;;;   - 9     : 以所选对象整体包围框中心为基点，整体顺时针旋转 90 度。
;;;   - 99    : 以所选对象整体包围框中心为基点，整体逆时针旋转 90 度。
;;;   - QZ    : 取消当前图纸中的全部分组，组内图元保持不变。
;;;   - XX    : 将选中文字内容替换为 7×2.5。
;;;   - DAO   : 将选中文字按垂直位置上下颠倒排列（最下面的文字放到最上面）。
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
(setq *HH_TextColor*     6)        ; (HH) 快速改色命令的目标颜色（洋红色）
(setq *HUI_TextColor*    8)        ; (HUI) 快速改色命令的目标颜色

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
(setq *ztf-project-dir* "E:/366256/ZW-auto_lisp")

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

(defun ztf:apply-font (/ styleObj fontPath result doc)
  (if (and *ztf-style-name* *ztf-selected-font*)
    (progn
      (setq fontPath (cdr *ztf-selected-font*))
      (setq styleObj (ztf:style-object *ztf-style-name*))
      (if styleObj
        (progn
          (setq result
            (vl-catch-all-apply 'vla-put-FontFile
                                (list styleObj fontPath)))
          (if (vl-catch-all-error-p result)
            (alert (strcat "字体写入失败：\r\n" (vl-catch-all-error-message result)))
            (progn
              (setq doc (vla-get-ActiveDocument (vlax-get-acad-object)))
              (vla-Regen doc 1)
              (alert (strcat "已将样式“" *ztf-style-name*
                             "”的字体改为：\r\n" (car *ztf-selected-font*))))))))
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
         ((or (= next "P") (= next "p") (= next "~"))
          (setq out (strcat out " ")
                idx (+ idx 2)))
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

;;; 命令: YSDL
;;; 功能: 提取选中的文字，自动保存或追加到桌面指定名称的CSV文件中，然后改变文字颜色。
;;; =======================================================================================
(defun c:YSDL (/ aa:doc aa:undo-open *error* ss i ent edata text-data-list sorted-data
               csv-path f fuzz userprofile file-mode action-msg
               ename targetColor text-string ins-point all-rows current-row
               last-y item current-y line-str cell cell-safe)

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

  ;; 1. 提示用户选择文字对象
  (princ "\r\n请选择要导出并改变颜色的文字对象: ")
  (setq ss (ssget '((0 . "TEXT,MTEXT"))))

  (if ss
    (progn
      ;; 2. 提取所选文字的内容和插入点坐标
      (setq text-data-list '()
            i 0)
      (repeat (sslength ss)
        (setq ent (ssname ss i))
        (setq edata (entget ent))
        (setq text-string (aa:ysdl-get-plain-text edata))
        (setq ins-point (cdr (assoc 10 edata)))
        (setq text-data-list (cons (list text-string ins-point) text-data-list))
        (setq i (1+ i))
      )

      ;; 3. 按坐标排序 (从上到下，从左到右)
      (setq sorted-data
             (aa:insert-sort text-data-list
                      '(lambda (item1 item2 / y1 y2)
                         (setq y1 (cadr (cadr item1)))
                         (setq y2 (cadr (cadr item2)))
                         (if (> y1 (+ y2 fuzz))
                           T
                           (if (< y1 (- y2 fuzz))
                             nil
                             (< (car (cadr item1)) (car (cadr item2)))
                           )
                         )
                       )
             )
      )

      ;; 4. 将排序后的数据按行分组
      (setq all-rows '())
      (if sorted-data
        (progn
          (setq current-row (list (car (car sorted-data))))
          (setq last-y (cadr (cadr (car sorted-data))))
          (foreach item (cdr sorted-data)
            (setq current-y (cadr (cadr item)))
            (if (<= (abs (- current-y last-y)) fuzz)
              (setq current-row (append current-row (list (car item))))
              (progn
                (setq all-rows (append all-rows (list current-row)))
                (setq current-row (list (car item)))
              )
            )
            (setq last-y current-y)
          )
          (setq all-rows (append all-rows (list current-row)))
        )
      )

      ;; 5. 自动定位桌面路径并写入或追加CSV文件
      (setq userprofile (getenv "USERPROFILE"))
      (if (and userprofile (/= userprofile ""))
        (progn
          (setq csv-path (strcat userprofile "\\Desktop\\" *YSDL_CsvFileName*))
          (if (findfile csv-path)
            (progn (setq file-mode "a") (setq action-msg "数据已成功追加到桌面文件:\r\n"))
            (progn (setq file-mode "w") (setq action-msg "已在桌面成功创建文件:\r\n"))
          )
          
          (setq f (open csv-path file-mode))
          (foreach row all-rows
            (setq line-str "")
            (foreach cell row
                (setq cell-safe (aa:ysdl-build-csv-field cell))
                (setq line-str (strcat line-str cell-safe ","))
            )
            (setq line-str (substr line-str 1 (1- (strlen line-str))))
            (write-line line-str f)
          )
          (close f)

          ;; 修改已导出文字的颜色
          (setq targetColor *YSDL_TextColor*)
          (setq i 0)
          (repeat (sslength ss)
            (setq ename (ssname ss i))
            (aa:set-entity-aci-color ename targetColor)
            (setq i (1+ i))
          )
          (redraw)

          (alert (strcat action-msg csv-path "\r\n\r\n并且所有选中的文字颜色已更改。"))
        )
        (alert "错误: 无法自动获取您的桌面路径!")
      )
    )
    (princ "\r\n未选择任何文字对象。")
  )
  (aa:undo-mark-off)
  (princ) 
)


;;; =======================================================================================
;;; 命令: LONG
;;; 功能: 计算所有选定多段线（Polyline 和 LWPolyline）的总长度。
;;; =======================================================================================

;;; =======================================================================================
;;; 命令: QSTXT
;;; 功能: 快速选择。在已有的选择集中，仅保留文字类型的对象。
;;; =======================================================================================
(defun c:qstxt (/ *error* aa:tag aa:doc aa:undo-open aa:old-cmdecho ss i ent txt)
  (aa:cmd-begin "QSTXT")
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
;;; Command: TXT
;;; Purpose: Filter selected TEXT and MTEXT, explode MTEXT into TEXT, then set style,
;;;          height, and width factor while keeping other properties unchanged.
;;; =======================================================================================
(defun txt:set-dxf (code value data / item)
  (if (setq item (assoc code data))
    (subst (cons code value) item data)
    (append data (list (cons code value)))
  )
)

(defun txt:modify-text (ename / edata)
  (if (and ename (= "TEXT" (cdr (assoc 0 (setq edata (entget ename))))))
    (progn
      (setq edata (txt:set-dxf 7 "HZ" edata))
      (setq edata (txt:set-dxf 40 3.0 edata))
      (setq edata (txt:set-dxf 41 0.7 edata))
      (if (entmod edata) 1 0)
    )
    0
  )
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

  ;; Modify TEXT immediately instead of building another large selection set.
  (while (< i total)
    (setq ename (ssname sel i)
          etype (cdr (assoc 0 (entget ename))))
    (cond
      ((= etype "TEXT")
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
  (if (null (tblsearch "STYLE" "HZ"))
    (princ "\r\n未找到文字样式 HZ。")
    (progn
      (setq sel (ssget '((0 . "TEXT,MTEXT"))))
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
(defun txt2:lwpoly-segments (ename edata / pts closed segs p0 prev cur p)
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
                                             shift-x shift-y vla-obj final-box)
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
(defun c:H (/ *error* aa:tag aa:doc aa:undo-open aa:old-cmdecho a ss doc i ename vla_obj min_pt max_pt min_list max_list
              edata ht total_ht avg_ht row_tol top_y left_x mid_y text_list rows current_row base_row_y
              sorted_row sorted_text_list text_info anchor_ent anchor_left anchor_top
              current_top current_left target_top delta_x delta_y move_vec count)
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
;;; Function: 将选中对象改为白色；支持转角标注等尺寸标注全要素变白，块内所有实体一并变白。
;;; =======================================================================================
(defun c:WW (/ *error* aa:tag aa:doc aa:undo-open aa:old-cmdecho)
  (aa:cmd-begin "WW")
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
;;; 命令: HH
;;; 功能: 将选中的所有对象颜色改为洋红色（ACI 6）。
;;; =======================================================================================
(defun c:HH (/ *error* aa:tag aa:doc aa:undo-open aa:old-cmdecho)
  (aa:cmd-begin "HH")
  (aa:color-cmd *HH_TextColor* "\r\n请选择要改为洋红色的对象: " "\r\n所有选中对象已改为洋红色。")
  (aa:cmd-end)
)







;;; =======================================================================================
;;; 公共实现: HUI / WW 的深度改色
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
  ;; HUI / WW 共用：块参照直接改块定义，块内实体（含嵌套块与属性）一并改色，不分解块。
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
  ;;   ref-fn   选取基准文字的函数（最上方或最左侧）
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

;;; 功能: 将选中文字统一为左中对正，并以最上方文字为基准左对齐。
(defun c:ZUO ()
  (aa:align-text-cmd "ZUO" "左对齐"
    'aa:find-ref-by-top-bbox 'aa:bbox-left-x
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

;;; 功能: 将选中文字统一为右中对正，并以最上方文字为基准右对齐。
(defun c:YOU ()
  (aa:align-text-cmd "YOU" "右对齐"
    'aa:find-ref-by-top-bbox 'aa:bbox-right-x
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

;;; 功能: 将选中文字统一为中下对正，并以最左侧文字为基准下对齐。
(defun c:XIA ()
  (aa:align-text-cmd "XIA" "下对齐"
    'aa:find-ref-by-left-bbox 'aa:bbox-bottom-y
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
;;; 功能: 快速修改选中文字对象的高度。
;;; =======================================================================================
(defun c:QR (/ *error* aa:tag aa:doc aa:undo-open aa:old-cmdecho a ss i ent data)
  (aa:cmd-begin "QR")
  ;; 1. 提示用户输入高度值并存储在变量 a 中
  (setq a (getdist "\r\n请输入新的文字高度: "))

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
;;; 功能: 连续选择文字并逐轮输入高度进行修改，按 Esc 退出。
;;; =======================================================================================
(defun c:QR2 (/ *error* aa:tag aa:doc aa:undo-open aa:old-cmdecho ss a i ent data count)
  (aa:cmd-begin "QR2")
  (princ "\r\nQR2：选择文字后按空格，输入高度后按空格；重复操作，按 Esc 退出。")
  (while (setq ss (ssget '((0 . "TEXT,MTEXT"))))
    (setq a (getdist "\r\n请输入新的文字高度: "))
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
;;; 命令: SS
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

(defun c:SS (/ *error* aa:tag aa:doc aa:undo-open aa:old-cmdecho aa:old-dragmode ss
               p1 vec desc)
  (setq aa:old-dragmode (getvar "DRAGMODE"))
  (aa:cmd-begin "SS")
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
                   (princ (strcat "\r\n已拉伸并记住位移（" (aa:ss-format-vec vec) "）。下次使用 SS 可直接回车重复。")))
                 (princ "\r\n未产生有效位移，拉伸已取消。"))
               (princ "\r\n已取消指定基点。")))
            ;; 用户直接在屏幕上点了基点 (p1 是点坐标列表)
            ((listp p1)
             (if (setq vec (aa:ss-do-interactive-stretch ss p1))
               (progn
                 (setq *aa:ss-offset* vec)
                 (princ (strcat "\r\n已拉伸并记住位移（" (aa:ss-format-vec vec) "）。下次使用 SS 可直接回车重复。")))
               (princ "\r\n未产生有效位移，拉伸已取消。")))))
        ;; --- 首次使用，无历史记忆 ---
        (progn
          (princ "\r\n[SS] 首次使用，请指定拉伸方向与距离：")
          (if (setq p1 (getpoint "\r\n请指定拉伸基点: "))
            (if (setq vec (aa:ss-do-interactive-stretch ss p1))
              (progn
                (setq *aa:ss-offset* vec)
                (princ (strcat "\r\n已完成拉伸并记住位移（" (aa:ss-format-vec vec) "）。下次使用 SS 可直接回车重复。")))
              (princ "\r\n未产生有效位移，拉伸已取消。"))
            (princ "\r\n已取消指定基点。")))))
    (princ "\r\n未选择要拉伸的对象。"))
  (if aa:old-dragmode
    (vl-catch-all-apply 'setvar (list "DRAGMODE" aa:old-dragmode)))
  (aa:cmd-end)
)

;;; --- SYI / XYI：非竖直对象移动，竖直直线单端拉伸 ---
(defun aa:move-stretch-vertical-cmd (tag hint up-p / *error* aa:tag aa:doc aa:undo-open aa:old-cmdecho
                                      ss move-ss i ent ed p1 p2 delta x tol top-code top-y)
  (aa:cmd-begin tag)
  (if (setq ss (ssget "_I"))
    (if (setq delta (getreal (strcat "\r\n请输入 X 值（" hint " 5X）: ")))
      (progn
        ;; 方向由命令决定，X 只取距离，避免 XYI 因负输入再次反向。
        (setq delta (* 5.0 (abs delta) (if up-p 1.0 -1.0))
              move-ss (ssadd)
              i 0
              tol 1e-8)
        (repeat (sslength ss)
          (setq ent (ssname ss i)
                ed (entget ent))
          (if (= (cdr (assoc 0 ed)) "LINE")
            (progn
              (setq p1 (cdr (assoc 10 ed))
                    p2 (cdr (assoc 11 ed)))
              (if (<= (abs (- (car p1) (car p2))) tol)
                (progn
                  ;; 竖直线只移动朝向 hint 的端点，形成单端拉伸。
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
                (ssadd ent move-ss)))
            (ssadd ent move-ss))
          (setq i (1+ i)))
        (if (> (sslength move-ss) 0)
          (command "_.MOVE" move-ss "" '(0.0 0.0 0.0) (list 0.0 delta 0.0)))
        (redraw)
        (princ (strcat "\r\n已完成：非竖直对象" hint "移动 " (rtos (abs delta) 2 3)
                       "，竖直直线" hint "拉伸相同距离。")))
      (princ "\r\n已取消：X 值无效。"))
    (princ "\r\n请先选择对象，再输入命令。"))
  (aa:cmd-end)
)

(defun c:SYI () (aa:move-stretch-vertical-cmd "SYI" "向上" T))
(defun c:XYI () (aa:move-stretch-vertical-cmd "XYI" "向下" nil))

;;; =======================================================================================
;;; 命令: SSS
;;; 功能: 将命令启动前的预选对象按 CAD 原生拉伸规则向右拉伸 3 个单位。
;;; =======================================================================================
(defun c:SSS (/ *error* aa:tag aa:doc aa:undo-open aa:old-cmdecho ss)
  (aa:cmd-begin "SSS")
  (if (setq ss (ssget "_I"))
    (progn
      (command "_.STRETCH" ss "" "_NON" '(0.0 0.0 0.0) "_NON" '(3.0 0.0 0.0))
      (princ "\r\n已向右拉伸 3 个单位。"))
    (princ "\r\n请先选择要拉伸的对象，再输入 SSS。"))
  (aa:cmd-end)
)


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

(defun c:GTY (/ *error* ss i ent ent-data text-string insertion-point text-height text-width
               text-data total-height avg-height row-tol split-gap col-gap line-height
               rows current-item current-y found split-rows current-row last-item-x current-item-x
               anchor-x anchor-y col-widths col-index row row-index sort-keys row-map token sorted-rows
               doc undo-started)

  (vl-load-com)
  (setq doc          (vla-get-ActiveDocument (vlax-get-acad-object))
        undo-started nil)

  (defun *error* (msg)
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
      (vla-StartUndoMark doc)
      (setq undo-started T
            text-data     '()
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

      (setq rows '())
      (foreach current-item text-data
        (setq current-y (aa:gty-get-item-y current-item)
              found     nil)
        (setq rows
          (mapcar
            '(lambda (line)
               (if (and (not found)
                        (<= (abs (- current-y (aa:gty-get-item-y (car line)))) row-tol))
                 (progn
                   (setq found T)
                   (cons current-item line))
                 line))
            rows))
        (if (not found)
          (setq rows (cons (list current-item) rows))
        )
      )

      (setq rows
        (mapcar
          '(lambda (line)
             (aa:insert-sort line '(lambda (a b) (< (aa:gty-get-item-x a) (aa:gty-get-item-x b)))))
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
                  (setq split-rows (cons current-row split-rows))
                  (setq current-row (list current-item)))
                (setq current-row (append current-row (list current-item)))
              )
              (setq last-item-x current-item-x)
            )
            (setq split-rows (cons current-row split-rows))
          )
        )
      )
      (setq rows (reverse split-rows))

      (setq rows
        (aa:insert-sort
          rows
          '(lambda (a b / ay by ax bx)
             (setq ay (aa:gty-get-item-y (car a))
                   by (aa:gty-get-item-y (car b))
                   ax (aa:gty-get-item-x (car a))
                   bx (aa:gty-get-item-x (car b)))
             (if (> (abs (- ay by)) row-tol)
               (> ay by)
               (< ax bx)))))

      (setq anchor-x (aa:gty-get-item-x (car text-data))
            anchor-y (aa:gty-get-item-y (car text-data)))
      (foreach current-item text-data
        (if (< (aa:gty-get-item-x current-item) anchor-x)
          (setq anchor-x (aa:gty-get-item-x current-item))
        )
        (if (> (aa:gty-get-item-y current-item) anchor-y)
          (setq anchor-y (aa:gty-get-item-y current-item))
        )
      )

      (setq col-widths '())
      (foreach row rows
        (setq col-index 0)
        (foreach current-item row
          (if (>= col-index (length col-widths))
            (setq col-widths
              (append col-widths (list (max (aa:gty-get-item-width current-item) col-gap))))
            (if (> (aa:gty-get-item-width current-item) (nth col-index col-widths))
              (setq col-widths
                (aa:gty-update-nth col-index (aa:gty-get-item-width current-item) col-widths))
            )
          )
          (setq col-index (1+ col-index))
        )
      )

      (setq sort-keys '()
            row-map   '()
            row-index 0)
      (foreach row rows
        (setq token     (aa:gty-build-sort-key row row-index)
              sort-keys (cons token sort-keys)
              row-map   (cons (cons token row) row-map)
              row-index (1+ row-index))
      )
      (setq sorted-rows
        (mapcar
          '(lambda (key) (cdr (assoc key row-map)))
          (acad_strlsort sort-keys)))

      (setq row-index 0)
      (foreach row sorted-rows
        (setq current-item-x anchor-x
              col-index      0)
        (foreach current-item row
          (aa:gty-move-entity
            (aa:gty-get-item-ename current-item)
            (aa:gty-get-item-pt current-item)
            (list current-item-x
                  (- anchor-y (* row-index line-height))
                  (aa:gty-get-item-z current-item)))
          (setq current-item-x (+ current-item-x (nth col-index col-widths) col-gap)
                col-index      (1+ col-index))
        )
        (setq row-index (1+ row-index))
      )

      (vla-EndUndoMark doc)
      (setq undo-started nil)
      (princ "\r\n[GTY] 电缆文字整理完成。")
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
;;;       选中 x 条竖直直线时，副本右移 5*x 单位；S = 向上 5，X = 向下 5
;;;       所有对象先原地复制，再对副本执行移动/变形，原始对象不动。
;;;       水平线：副本上/下移 5，左端缩短 5*x（右端不动）
;;; =======================================================================================

(defun lan-get-option (vert_count move_right / kw)
  (initget "Shang Xia")
  (setq kw
    (getkword
      (strcat "\r\n检测到 " (itoa vert_count)
              " 条竖直线，副本将右移 " (rtos move_right 2 0)
              " 单位。请选择方向 [向上(Shang)/向下(Xia)] <向上>: ")))

  (cond
    ((or (null kw) (equal kw "Shang")) "S")
    ((equal kw "Xia") "X")
  )
)

(defun c:LAN ( / *error* aa:tag aa:doc aa:undo-open aa:old-cmdecho ss total_count
               vert_lines  horiz_lines  diag_lines
               vert_count  horiz_count  diag_count
               opt  move_right  dy
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

  ;; 4. 计算移动量
  (setq move_right (* 5 vert_count))

  ;; 5. 获取 S / X 选项
  (setq opt (lan-get-option vert_count move_right))
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

  ;; 8. 处理水平直线：复制 → 上/下移 5 → 左端缩短 move_right（右端不动）
  (foreach ent horiz_lines
    (setq copy_ent (entmakex (entget ent))
          entdata  (entget copy_ent)
          pt1      (cdr (assoc 10 entdata))
          pt2      (cdr (assoc 11 entdata)))

    (if (< (car pt1) (car pt2))
      (setq new_pt1 (list (+ (car pt1) move_right) (+ (cadr pt1) dy) (caddr pt1))
            new_pt2 (list (car pt2)                 (+ (cadr pt2) dy) (caddr pt2)))
      (setq new_pt1 (list (car pt1)                 (+ (cadr pt1) dy) (caddr pt1))
            new_pt2 (list (+ (car pt2) move_right)  (+ (cadr pt2) dy) (caddr pt2)))
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
            " 5 单位 + 左端缩短 " (rtos move_right 2 0) " 单位（右端不动）。"))
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
(setq *xy-geom-tol*      1e-4)             ; 几何容差
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

(defun xy:is-vertical-line-ed-p (ed tol / p1 p2)
  (and (= (cdr (assoc 0 ed)) "LINE")
       (setq p1 (cdr (assoc 10 ed)))
       (setq p2 (cdr (assoc 11 ed)))
       (xy:near (car p1) (car p2) tol))
)

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
        (setq out (cons (list en (car p1) (cadr p1) (cadr p2)) out))
      )
    )
  )
  (reverse out)
)

;; 竖线数据按 X 坐标分桶：查询时只检查水平线 x 区间内的桶，避免全表扫描
(defun xy:build-vline-buckets (vlineDataList / out b vd)
  (setq out '())
  (foreach vd vlineDataList
    (setq b (fix (/ (cadr vd) *xy-vline-bucket-size*)))
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

;; Optimized: builds vrec from pre-fetched (en x y1 y2) vertical line data; zero entget calls
(defun xy:make-vrec-if-valid-fast (vdata hinfo tol / en x y1 y2 xmin xmax hy loY hiY)
  (setq en   (car vdata))
  (setq x    (cadr vdata))
  (setq y1   (caddr vdata))
  (setq y2   (cadddr vdata))
  (setq xmin (car hinfo))
  (setq xmax (cadr hinfo))
  (setq hy   (caddr hinfo))

  (if (not (xy:between x xmin xmax tol))
    nil
    (progn
      (setq loY (min y1 y2))
      (setq hiY (max y1 y2))
      (cond
        ((and (xy:near hiY hy tol)
              (< loY (- hy tol)))
         (list x 'DOWN (list x loY 0.0) en))
        ((and (xy:near loY hy tol)
              (> hiY (+ hy tol)))
         (list x 'UP   (list x hiY 0.0) en))
        (t nil)
      )
    )
  )
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
(defun xy:copy-text-horizontal (srcEn insPt / ed data)
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

  (entmakex data)
)
(defun xy:process-one-hline (ed vlineDataList textMetaList / hinfo vrecs vrec item found txt rightPt startPt idx newCnt missCnt allVCnt tail cand scan rectXmin rectXmax)
  (setq hinfo (xy:hline-info-ed ed))
  (setq vrecs (xy:get-vrecs-for-hline-ed ed vlineDataList))
  (setq allVCnt (length vrecs))
  (setq found   '())
  (setq missCnt 0)

  ;; 滑动窗口：textMetaList 按 xmin 升序、vrecs 按 x 升序，双指针只检查窗口附近文字
  (setq tail textMetaList)
  (foreach vrec vrecs
    (setq rectXmin (- (car vrec) *xy-hit-half-width*))
    (setq rectXmax (+ (car vrec) *xy-hit-half-width*))
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

(defun xyg:text-in-rect-p (en xmin xmax ymin ymax / ed typ h bbox minx maxx miny maxy pt cx cy)
  (setq ed (entget en)
        typ (cdr (assoc 0 ed)))
  (if (member typ '("TEXT" "MTEXT"))
    (progn
      (setq h (cdr (assoc 40 ed)))
      ;; 排除字高 >= 80 的大字
      (if (and h (< h 79.9))
        (progn
          (setq bbox (xy:get-text-bbox en))
          (if bbox
            (progn
              (setq minx (car bbox)
                    maxx (cadr bbox)
                    miny (caddr bbox)
                    maxy (cadddr bbox))
              ;; 包围盒相交判定：只要文字的包围盒与搜索矩形有一点点触碰重叠，就算命中
              (and (<= minx xmax)
                   (>= maxx xmin)
                   (<= miny ymax)
                   (>= maxy ymin))
            )
            (progn
              ;; 若获取包围盒失败，保底基于插入点扩展判定
              (setq pt (cdr (assoc 10 ed))
                    cx (car pt)
                    cy (cadr pt))
              (and (<= (- cx 2.0) xmax)
                   (>= (+ cx 2.0) xmin)
                   (<= (- cy 0.5) ymax)
                   (>= (+ cy h) ymin))
            )
          )
        )
      )
    )
  )
)

(defun xyg:find-rect-texts (rightPt all-ss / rx ry xmin xmax ymin ymax res i en ed str bbox cx nearby)
  (setq rx   (car rightPt)
        ry   (cadr rightPt)
        xmin (- rx 155.0)
        xmax (+ rx 0.5)
        ymin (- ry 0.5)
        ymax (+ ry 3.5)
        res  '()
        i    0)
  (if all-ss
    (while (< i (sslength all-ss))
      (setq en (ssname all-ss i))
      (if (xyg:text-in-rect-p en xmin xmax ymin ymax)
        (progn
          (setq ed   (entget en)
                str  (aa:ysdl-get-plain-text ed)
                bbox (xy:get-text-bbox en)
                cx   (if bbox (/ (+ (car bbox) (cadr bbox)) 2.0) (car (cdr (assoc 10 ed)))))
          (if (/= (vl-string-trim " \t\r\n" str) "")
            (setq res (cons (list en cx str) res))
          )
        )
      )
      (setq i (1+ i))
    )
  )
  ;; 若在框选集合中未找到足够的3个文字，自动在当前图面对应矩形区域内补充查找，彻底杜绝框选不全导致的漏选
  (if (< (length res) 3)
    (progn
      (setq nearby (xy:window-wcs xmin ymin xmax ymax '((0 . "TEXT,MTEXT"))))
      (if nearby
        (progn
          (setq i 0)
          (while (< i (sslength nearby))
            (setq en (ssname nearby i))
            (if (and (null (assoc en res))
                     (xyg:text-in-rect-p en xmin xmax ymin ymax))
              (progn
                (setq ed   (entget en)
                      str  (aa:ysdl-get-plain-text ed)
                      bbox (xy:get-text-bbox en)
                      cx   (if bbox (/ (+ (car bbox) (cadr bbox)) 2.0) (car (cdr (assoc 10 ed)))))
                (if (/= (vl-string-trim " \t\r\n" str) "")
                  (setq res (cons (list en cx str) res))
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

(defun xyg:find-right-new-texts (rightPt new-texts expected-count max-x / rx ry limit-x res en ed pt x y str prev-x cand keep-cnt trimmed idx cand-num gap-ok)
  (setq rx      (car rightPt)
        ry      (cadr rightPt)
        limit-x (if max-x max-x (+ rx 350.0)))
  (if (and expected-count (> expected-count 0))
    (setq limit-x (min limit-x (+ rx 10.0 (* 30.0 expected-count) 20.0)))
  )
  (setq res '())
  (foreach en new-texts
    (setq ed (entget en))
    (if (member (cdr (assoc 0 ed)) '("TEXT" "MTEXT"))
      (progn
        (setq pt (cdr (assoc 10 ed))
              x  (car pt)
              y  (cadr pt))
        ;; Y 坐标在 ry+0.5 附近，X 坐标大于 rx 且不超过 limit-x
        (if (and (> x (+ rx 0.5))
                 (<= x limit-x)
                 (<= (abs (- y (+ ry 0.5))) 0.6))
          (progn
            (setq str (aa:ysdl-get-plain-text ed))
            (if (/= (vl-string-trim " \t\r\n" str) "")
              (setq res (cons (list en x str) res))
            )
          )
        )
      )
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

  (mapcar 'caddr res)
)

(defun xyg:output-gtx-matrix (categorized-groups prefix-str pt text-style / start-x current-y text-height line-height col-width all-strings output-box cat-item sorted-groups group current-x text-item)
  (setq text-height 3.0
        start-x     (car pt)
        current-y   (cadr pt)
        col-width   50.0
        line-height 5.0
        all-strings (list prefix-str))

  (foreach cat-item categorized-groups
    (foreach group (cadr cat-item)
      (foreach text-item group
        (setq all-strings (cons text-item all-strings))
      )
    )
  )

  (foreach text-item all-strings
    (setq output-box (textbox (list '(0 . "TEXT") (cons 1 text-item)
      (cons 40 text-height) (cons 7 text-style) '(41 . 0.7))))
    (if output-box
      (setq col-width (max col-width
        (+ (* 2.0 text-height) (- (caadr output-box) (caar output-box)))))))

  (foreach cat-item categorized-groups
    (setq sorted-groups
      (aa:merge-sort
        (cadr cat-item)
        '(lambda (itemA itemB)
           (aa:gtx-natural-less (car itemA) (car itemB))))
    )
    (foreach group sorted-groups
      (setq current-x start-x)
      (aa:gtx-create-text-entity (list current-x current-y (caddr pt)) prefix-str text-height text-style)
      (setq current-x (+ current-x col-width))
      (foreach text-item group
        (aa:gtx-create-text-entity (list current-x current-y (caddr pt)) text-item text-height text-style)
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
               line-handle expected-count next-line-min-x other-en other-ed other-p1 other-p2 other-y other-min-x limit-x
               left-texts right-texts full-texts pt text-style categorized-groups
               left-text temp-text last-hyphen-pos category found-category
               eda edb ya yb p1a p2a)

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
              (setq sorted-lines
                (aa:merge-sort green-lines-list
                  '(lambda (ea eb / eda edb ya yb)
                     (setq eda (entget ea)
                           edb (entget eb)
                           ya  (caddr (assoc 10 eda))
                           yb  (caddr (assoc 10 edb)))
                     (> ya yb))))

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
                (setq next-line-min-x nil)
                (foreach other-en sorted-lines
                  (if (/= other-en line-en)
                    (progn
                      (setq other-ed (entget other-en)
                            other-p1 (cdr (assoc 10 other-ed))
                            other-p2 (cdr (assoc 11 other-ed))
                            other-y  (cadr other-p1)
                            other-min-x (min (car other-p1) (car other-p2)))
                      (if (and (<= (abs (- other-y ry)) 0.5)
                               (> other-min-x rx))
                        (if (or (null next-line-min-x) (< other-min-x next-line-min-x))
                          (setq next-line-min-x other-min-x)
                        )
                      )
                    )
                  )
                )
                (setq limit-x (if next-line-min-x (- next-line-min-x 5.0) (+ rx 350.0)))

                ;; 提取右上矩形文字（从左到右，严格最多3个）
                (setq left-texts (xyg:find-rect-texts rightPt all-ss))
                (if (/= (length left-texts) 3)
                  (princ
                    (strcat "\r\n[XYG] 提示: 直线 Y="
                            (rtos ry 2 2)
                            " 右上方找到 " (itoa (length left-texts))
                            " 个文字（期望为3个）。"))
                )

                ;; 提取右侧新生成文字（芯数数字在前，原理号在后，多重限幅防串列重复）
                (setq right-texts (xyg:find-right-new-texts rightPt xy-new-texts expected-count limit-x))

                ;; 组装成整行文字列表
                (setq full-texts (append left-texts right-texts))
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
                              temp-text (aa:gtx-key left-text))
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
                      (xyg:output-gtx-matrix categorized-groups prefix-str pt text-style)
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
;;; 命令: HB
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

(defun c:HB (/ *error* aa:tag aa:doc aa:undo-open aa:old-cmdecho
               ss all-data all-old-enames i en ed str pt-val x y
               text-height text-style tol rows parsed-rows has-merge pr
               merge-cnt row0 col-width r-items)
  (aa:cmd-begin "HB")

  ;; 支持先选后执与后选
  (setq ss (ssget "_I" '((0 . "TEXT,MTEXT"))))
  (if (null ss)
    (progn
      (prompt "\r\n[HB] 请框选要合并的电缆清册表格文字: ")
      (setq ss (ssget '((0 . "TEXT,MTEXT"))))
    )
  )

  (if (null ss)
    (progn
      (princ "\r\n[HB] 未选择对象，HB 命令结束。")
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
          (princ "\r\n[HB] 选集中未找到有效的文字内容。")
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
              (princ "\r\n[HB] 所选文字中未发现包含“并入”的电缆行，无需合并。")
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
                (princ "\r\n[HB] 发现“并入”行，但未匹配到对应的目标主电缆行，未做修改。")
                (princ (strcat "\r\n[HB] 原地合并完成：成功合并 " (itoa merge-cnt) " 个并入行。主电缆芯数已更新，原理号已向后堆积追加。"))
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

(defun aa:nu-rewrite-text (str delta / token start end old-val new-str)
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
  )
)

(defun c:NU (/ *error* doc undo-open ss a i en ed str new-str changed)
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
                changed 0)
          (vla-StartUndoMark doc)
          (setq undo-open T)
          (repeat (sslength ss)
            (setq en (ssname ss i)
                  ed (entget en)
                  str (cdr (assoc 1 ed))
                  new-str (if str (aa:nu-rewrite-text str a)))
            (if (and new-str (/= new-str str))
              (progn
                (setq ed (subst (cons 1 new-str) (assoc 1 ed) ed))
                (if (entmod ed)
                  (setq changed (1+ changed)))))
            (setq i (1+ i)))
          (vla-EndUndoMark doc)
          (setq undo-open nil)
          (princ (strcat "\r\n[NU] 已更新 " (itoa changed) " 个文字对象。"))
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
             ((or (= next "P") (= next "p"))
              (if keep-newline
                (setq out (strcat out "\\P")))
              (setq idx (+ idx 2)))
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

(defun fdx:sort-frames (rects mode / sorted out band anchor tol rect)
  (setq sorted (aa:merge-sort rects
    (if (= mode "C") '(lambda (a b) (< (car a) (car b)))
                       '(lambda (a b) (> (nth 3 a) (nth 3 b))))))
  (while sorted
    (setq rect (car sorted) sorted (cdr sorted) band (list rect)
          anchor (if (= mode "C") (car rect) (nth 3 rect))
          tol (* 0.1 (if (= mode "C") (- (nth 2 rect) (car rect)) (- (nth 3 rect) (cadr rect)))))
    (while (and sorted (<= (abs (- (if (= mode "C") (caar sorted) (nth 3 (car sorted))) anchor)) tol))
      (setq band (cons (car sorted) band) sorted (cdr sorted)))
    (setq band (aa:merge-sort band
      (if (= mode "C") '(lambda (a b) (> (nth 3 a) (nth 3 b)))
                         '(lambda (a b) (< (car a) (car b))))))
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
  ;; Preflight the entire batch before changing any entity. pending belongs to c:FDX.
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
      (setq center (mapcar '(lambda (a b) (/ (+ a b) 2.0)) low high)
            target (trans (list (/ (+ (car rect) (nth 2 rect)) 2.0)
                                (/ (+ (cadr rect) (nth 3 rect)) 2.0) (nth 4 rect)) 1 0)
            delta (mapcar '- target center)
            pending records)
      (foreach ed records
        (if ok
          (progn
            (setq result (vl-catch-all-apply 'entmod (list (fdx:shift-data ed delta))))
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
             (princ (strcat "\r\n[FDX] " (itoa (caddr result)) " 个文字未参与 DX 排列，保留整组移动后的位置。"))))))
      (if (not ok)
        (if (fdx:restore pending)
          (princ "\r\n[FDX] 移动或排列未完成，已恢复本批文字，当前方框不前进。")
          (progn (princ "\r\n[FDX] 恢复失败，请退出后用 U 撤销本轮分配。") (exit))))
      (setq pending nil)
      (redraw)
      ok)))

(defun c:FDX (/ *error* aa:doc aa:undo-open frames-ss frames mode texts index total assigned running pending)
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
      (initget "R C")
      (setq mode (getkword "\r\n[FDX] 方框顺序 [按行(R)/按列(C)] <R>: "))
      (if (null mode) (setq mode "R"))
      (setq frames (fdx:sort-frames frames mode)
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
              moved failed skipped tol rect-tol overflow-count)
  (vl-load-com)
  (setq doc       (vla-get-ActiveDocument (vlax-get-acad-object))
        aa:undo-open nil
        overflow-count 0
        moved     0
        failed    0
        skipped   0
        tol       1e-8
        rect-tol  0.1)

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
         (setq i 0 infos nil)
         (repeat (sslength text-ss)
           (setq en   (ssname text-ss i)
                 info (aa:zz-text-info doc en tol))
           (if info
             (setq infos (cons info infos))
             (setq skipped (1+ skipped)))
           (setq i (1+ i)))
         (setq groups (aa:zz-group-by-rect (reverse infos) rect-tol))
          (aa:undo-mark-on)
         (foreach group groups
           (setq result  (dx:apply-group doc group)
                 moved   (+ moved (car result))
                 failed  (+ failed (cadr result))
                  skipped (+ skipped (caddr result))
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

(defun dx2:sort-groups (groups / out group index)
  (setq out nil
        index 0)
  (foreach group groups
    (setq out (dx2:insert-group (dx2:group-record group index) out)
          index (1+ index)))
  out
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

(defun dx2:sort-y-desc (items / out item)
  (setq out nil)
  (foreach item items
    (setq out (dx2:insert-y-desc item out)))
  out
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

(defun dx2:sort-x-asc (items / out item)
  (setq out nil)
  (foreach item items
    (setq out (dx2:insert-x-asc item out)))
  out
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
               group-text out skipped ok tol rect-tol)
  (aa:cmd-begin "DX2")
  (vl-load-com)
  (setq doc      (vla-get-ActiveDocument (vlax-get-acad-object))
        skipped  0
        out      ""
        tol      1e-8
        rect-tol 0.1)

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
         (setq i 0 infos nil)
         (repeat (sslength text-ss)
           (setq en   (ssname text-ss i)
                 info (aa:zz-text-info doc en tol))
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

(defun aa:zz-collect-lwpoly-pts (ed / pts)
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

(defun aa:zz-build-line-cache (line-ss tol / i en ed typ p1 p2 near vlist hlist pts closed prev first en2 ed2)
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

(defun aa:zz-find-bound-lines (line-cache cx cy tol / vlist hlist rec x y left-x right-x top-y bottom-y dl dr dt db dist)
  (setq vlist (car line-cache)
        hlist (cadr line-cache)
        left-x nil
        right-x nil
        top-y nil
        bottom-y nil
        dl nil
        dr nil
        dt nil
        db nil)
  (foreach rec vlist
    (if (aa:zz-between-p cy (cadr rec) (caddr rec) tol)
      (progn
        (setq x (car rec))
        (cond
          ((< x (- cx tol))
           (setq dist (- cx x))
           (if (or (null dl) (< dist dl))
             (setq dl dist
                   left-x x)))
          ((> x (+ cx tol))
           (setq dist (- x cx))
           (if (or (null dr) (< dist dr))
             (setq dr dist
                   right-x x)))))))
  (foreach rec hlist
    (if (aa:zz-between-p cx (cadr rec) (caddr rec) tol)
      (progn
        (setq y (car rec))
        (cond
          ((< y (- cy tol))
           (setq dist (- cy y))
           (if (or (null db) (< dist db))
             (setq db dist
                   bottom-y y)))
          ((> y (+ cy tol))
           (setq dist (- y cy))
           (if (or (null dt) (< dist dt))
             (setq dt dist
                   top-y y)))))))
  (if (and left-x right-x top-y bottom-y)
    (list left-x right-x top-y bottom-y))
)

(defun aa:zz-text-info (doc en tol / bbox cx cy line-ss line-cache bounds margin pt1 pt2 lx rx ty by max-dist left-dist right-dist top-dist bottom-dist)
  ;; Compute the rectangle (lx rx ty by) bounding a text via spatial query.
  ;; Returns (en cx cy lx rx ty by) or nil if no valid enclosing rectangle.
  (if (setq bbox (aa:safe-get-bbox doc en))
    (progn
      (setq cx       (aa:bbox-center-x bbox)
            cy       (/ (+ (aa:bbox-top-y bbox) (aa:bbox-bottom-y bbox)) 2.0)
            max-dist 300.0
            margin   max-dist
            pt1      (list (- cx margin) (- cy margin))
            pt2      (list (+ cx margin) (+ cy margin))
            line-ss  (ssget "_CP"
                       (mapcar '(lambda (pt) (trans pt 0 1))
                         (list pt1 (list (+ cx margin) (- cy margin))
                               pt2 (list (- cx margin) (+ cy margin))))
                       '((-4 . "<OR")
                         (0 . "LINE")
                         (0 . "LWPOLYLINE")
                         (0 . "POLYLINE")
                         (-4 . "OR>"))))
      (if line-ss
        (progn
          (setq line-cache (aa:zz-build-line-cache line-ss tol)
                bounds     (aa:zz-find-bound-lines line-cache cx cy tol))
          (if bounds
            (progn
              (setq lx          (car bounds)
                    rx          (cadr bounds)
                    ty          (caddr bounds)
                    by          (cadddr bounds)
                    left-dist   (abs (- cx lx))
                    right-dist  (abs (- rx cx))
                    top-dist    (abs (- ty cy))
                    bottom-dist (abs (- cy by)))
              (if (or (> left-dist max-dist)
                      (> right-dist max-dist)
                      (> top-dist max-dist)
                      (> bottom-dist max-dist))
                nil
                (list en cx cy lx rx ty by)))
            nil))
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

(defun aa:zz-group-by-rect (infos rect-tol / groups info placed new-groups g)
  ;; Bucket text-info records by shared rectangle. Returns list of groups,
  ;; each group is a list of text-info records.
  (setq groups '())
  (foreach info infos
    (setq placed     nil
          new-groups '())
    (foreach g groups
      (cond
        ((and (not placed) (aa:zz-rect-match-p info (car g) rect-tol))
         (setq new-groups (cons (cons info g) new-groups)
               placed     T))
        (T
         (setq new-groups (cons g new-groups)))))
    (if (not placed)
      (setq new-groups (cons (list info) new-groups)))
    (setq groups (reverse new-groups)))
  groups
)

(defun aa:zz-insert-y-desc (item items)
  ;; Insert one text-info record, keeping the list sorted by cy descending.
  (cond
    ((null items) (list item))
    ((> (nth 2 item) (nth 2 (car items))) (cons item items))
    (T (cons (car items) (aa:zz-insert-y-desc item (cdr items)))))
)

(defun aa:zz-sort-y-desc (items / out item)
  ;; Sort text-info records by original cy descending (top text first).
  (setq out nil)
  (foreach item items
    (setq out (aa:zz-insert-y-desc item out)))
  out
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
     (setq sorted (aa:zz-sort-y-desc group)
           n      (length sorted)
           info   (car sorted)
           lx     (nth 3 info)
           rx     (nth 4 info)
           ty     (nth 5 info)
           by     (nth 6 info)
           tx     (/ (+ lx rx) 2.0)
           spacing 5.0
           center-y (/ (+ ty by) 2.0)
           start-y (+ center-y (* 0.5 (1- n) spacing))
           cnt    0
           i      0)
     (foreach info sorted
       (setq y (- start-y (* i spacing)))
       (if (aa:zz-move-text (nth 0 info) (nth 1 info) (nth 2 info) tx y)
         (setq cnt (1+ cnt)))
       (setq i (1+ i)))
     cnt))
)

(defun aa:zz-run (/ *error* doc undo-open ss text-ss i en changed skipped tol rect-tol infos groups info alignment-ok)
  (vl-load-com)
  (setq doc       (vla-get-activedocument (vlax-get-acad-object))
        undo-open nil
        changed   0
        skipped   0
        tol       1e-8
        rect-tol  0.1)

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
                i         0
                infos     '())
          (repeat (sslength text-ss)
            (setq en   (ssname text-ss i)
                  ;; 先统一为中下对正，再以新的包围盒执行后续居中计算。
                  alignment-ok (aa:normalize-text-vertical-align doc en 3)
                  info (aa:zz-text-info doc en tol))
            (if info
              (setq infos (cons info infos))
              (setq skipped (1+ skipped)))
            (setq i (1+ i)))
          (setq groups (aa:zz-group-by-rect (reverse infos) rect-tol))
          (foreach g groups
            (setq changed (+ changed (aa:zz-apply-group g))))
          (vla-endundomark doc)
          (setq undo-open nil)
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

;;;========================================================================================
;;; DF-DB-AF-AB  文字批量增删 (DB=删末尾 DF=删开头 AB=尾部加字 AF=头部加字)
;;;========================================================================================
;;; ============================================================
;;; DF-DB-AF-AB.lsp  文字批量增删
;;;   DB : 删除每个选中文字对象“末尾”的 N 个字符
;;;   DF : 删除每个选中文字对象“开头”的 N 个字符
;;;   AF : 在每个选中文字对象“开头”增加输入的文字
;;;   AB : 在每个选中文字对象“末尾”增加输入的文字
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
      (setq txt (getstring "\r\n请输入要增加的文字: "))
      (if (= txt "")
        (princ "\r\n未输入文字，已取消。")
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
;; AB 在每个选中文字末尾增加输入的文字
(defun c:AB (/ *error* aa:tag aa:doc aa:undo-open aa:old-cmdecho)
  (aa:cmd-begin "AB")
  (db:add "B")
  (aa:cmd-end)
)
;; AF 在每个选中文字开头增加输入的文字
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
             old-text (cdr (assoc 1 ed)))
       (cond
         ((not old-text)
          (setq failed (1+ failed)))
         ((= old-text clip-text)
          (setq changed (1+ changed)))
         (t
          ;; 文字含“至”字时只替换“至”后面的文字，
          ;; 例如“至10kV 1(2)#站用变”+剪贴板“变压器超温报警”→“至变压器超温报警”
          (setq pos      (vl-string-search "至" old-text)
                new-text (if pos
                          (strcat (substr old-text 1 (1+ pos)) clip-text)
                          clip-text))
          (if (= old-text new-text)
            (setq changed (1+ changed))
            (progn
              (setq ed (subst (cons 1 new-text) (assoc 1 ed) ed))
              (if (entmod ed)
                (setq changed (1+ changed))
                (setq failed (1+ failed)))))))
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
(defun qw:join (items / rows row row-y row-h tol res line)
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
        (setq txt (cdr (assoc 1 ed)))
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
        (setq txt (cdr (assoc 1 ed)))
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

;;; 命令: C1 - 复制文字，优先把减号后的连续数字加 1
;;; 命令: C2 - 复制文字，优先把减号后的连续数字减 1
;;; 命令: C3 - 复制文字，优先把减号后的连续数字加 2
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

(defun c1c2:first-number-span (s / i n start len first after last-hyphen)
  (setq i 1
        n (strlen s)
        first nil
        after nil
        last-hyphen nil)
  (while (<= i n)
    (if (= (substr s i 1) "-")
      (setq last-hyphen i)
    )
    (setq i (1+ i))
  )
  (setq i 1)
  (while (<= i n)
    (cond
      ((c1c2:is-digit (substr s i 1))
       (setq start i)
       (while (and (<= i n) (c1c2:is-digit (substr s i 1)))
         (setq i (1+ i))
       )
       (setq len (- i start))
       (if (null first)
         (setq first (list start len))
       )
       (if (and last-hyphen (> start last-hyphen) (null after))
         (setq after (list start len))
       )
      )
      (T
       (setq i (1+ i))
      )
    )
  )
  (if after after first)
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

(defun c1c2:change-number (s delta / span start len old new pre post)
  (if (setq span (c1c2:first-number-span s))
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
        (strcat (de:rstrip-digits before) inner after)))
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
                       / *error* doc undo-open oldcmd oldct oldce
                         ss all-lines lines-by-y y-keys valid base-z
                         upper-y lower-y upper-lines lower-lines
                         upper-x lower-x
                         joint-x rect-w rect-x1 rect-x2 rect-cx height center-y
                         bottom top rect-pt1 rect-pt2
                         line-mid-x t-upper-center t-lower-center rect-center
                         t-rect-en t-rect-bbox t-w)
  (vl-load-com)
  (setq doc (vla-get-ActiveDocument (vlax-get-acad-object))
        undo-open nil
        oldcmd nil
        oldct nil
        oldce nil)

  (defun *error* (msg)
    (if oldcmd (setvar "CMDECHO" oldcmd))
    (if oldct (setvar "CELTYPE" oldct))
    (if oldce (setvar "CECOLOR" oldce))
    (if undo-open
      (vl-catch-all-apply 'vla-EndUndoMark (list doc)))
    (sssetfirst nil nil)
    (if (and msg
             (not (wcmatch (strcase msg) "*BREAK*,*CANCEL*,*EXIT*,*QUIT*")))
      (princ (strcat "\r\n[" tag-name "] 错误：" msg)))
    (princ))

  (setq ss (ssget "_I" '((0 . "LINE,LWPOLYLINE,POLYLINE"))))
  (if (null ss)
    (progn
      (princ (strcat "\r\n[" tag-name "] 请选择两条水平直线或多段线（多段线将自动分解）："))
      (setq ss (ssget "_:L" '((0 . "LINE,LWPOLYLINE,POLYLINE"))))))

  (if ss
    (progn
      (vl-catch-all-apply 'vla-StartUndoMark (list doc))
      (setq undo-open T)
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
                     (equal (cadr p1) (cadr p2) 1e-6)
                     (or (null base-z)
                         (equal (if (caddr p1) (caddr p1) 0.0) base-z 1e-6))
                     (equal (if (caddr p1) (caddr p1) 0.0)
                            (if (caddr p2) (caddr p2) 0.0) 1e-6))
              (progn
                (if (null base-z)
                  (setq base-z (if (caddr p1) (caddr p1) 0.0)))
                (setq lines-by-y (cons (list (cadr p1) en p1 p2) lines-by-y)))
              (setq valid nil)))

          (if (not valid)
            (princ (strcat "\r\n[" tag-name "] 所选直线必须全部水平且位于同一标高。"))
            (progn
              ;; 按照 Y 坐标分组并排序
              (setq lines-by-y
                (aa:merge-sort
                  lines-by-y
                  (function (lambda (a b) (< (car a) (car b))))))
              (setq y-keys nil)
              (foreach item lines-by-y
                (if (not (vl-some (function (lambda (y) (equal y (car item) 1e-4))) y-keys))
                  (setq y-keys (cons (car item) y-keys))))
              (setq y-keys (reverse y-keys))

              (if (/= (length y-keys) 2)
                (princ (strcat "\r\n[" tag-name "] 请选择刚好处于上下两个高度的两条水平直线（当前检测到 " (itoa (length y-keys)) " 个不同高度）。"))
                (progn
                  (setq lower-y (car y-keys)
                        upper-y (cadr y-keys))
                  (setq lower-lines (vl-remove-if-not (function (lambda (item) (equal (car item) lower-y 1e-4))) lines-by-y)
                        upper-lines (vl-remove-if-not (function (lambda (item) (equal (car item) upper-y 1e-4))) lines-by-y))

                  ;; 获取上下两组基准水平线的极端 X 坐标
                  (if is-left
                    (progn
                      ;; 向左：取最左侧的 X
                      (setq upper-x
                        (apply 'min
                          (mapcar (function (lambda (item)
                                              (min (car (nth 2 item)) (car (nth 3 item)))))
                                  upper-lines)))
                      (setq lower-x
                        (apply 'min
                          (mapcar (function (lambda (item)
                                              (min (car (nth 2 item)) (car (nth 3 item)))))
                                  lower-lines)))
                      (setq joint-x (- (min upper-x lower-x) 15.0)
                            line-mid-x (/ (+ (min upper-x lower-x) joint-x) 2.0)))
                    (progn
                      ;; 向右：取最右侧的 X
                      (setq upper-x
                        (apply 'max
                          (mapcar (function (lambda (item)
                                              (max (car (nth 2 item)) (car (nth 3 item)))))
                                  upper-lines)))
                      (setq lower-x
                        (apply 'max
                          (mapcar (function (lambda (item)
                                              (max (car (nth 2 item)) (car (nth 3 item)))))
                                  lower-lines)))
                      (setq joint-x (+ (max upper-x lower-x) 15.0)
                            line-mid-x (/ (+ (max upper-x lower-x) joint-x) 2.0))))

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

                  ;; 1. 生成两条延伸短线（长 15，虚线 HIDDEN2，青色 4）
                  (entmakex
                    (list '(0 . "LINE")
                          (cons 8 (getvar "CLAYER"))
                          '(62 . 4)
                          '(6 . "HIDDEN2")
                          (cons 10 (list upper-x upper-y base-z))
                          (cons 11 (list joint-x upper-y base-z))))
                  (entmakex
                    (list '(0 . "LINE")
                          (cons 8 (getvar "CLAYER"))
                          '(62 . 4)
                          '(6 . "HIDDEN2")
                          (cons 10 (list lower-x lower-y base-z))
                          (cons 11 (list joint-x lower-y base-z))))

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
                  ;; (a) 上面直线上方 1.5mm 标注 txt-up
                  (setq t-upper-center (list line-mid-x (+ upper-y 1.5 (/ 3.0 2.0)) base-z))
                  (aa:km-create-centered-text doc txt-up t-upper-center)

                  ;; (b) 下面直线上方 1.5mm 标注 txt-low
                  (setq t-lower-center (list line-mid-x (+ lower-y 1.5 (/ 3.0 2.0)) base-z))
                  (aa:km-create-centered-text doc txt-low t-lower-center)

                  (redraw)
                  (setvar "CELTYPE" oldct)
                  (setvar "CECOLOR" oldce)
                  (setvar "CMDECHO" oldcmd)
                  (setq oldcmd nil)
                  (princ (strcat "\r\n[" tag-name "] 已成功生成两条短线（长15）、矩形（自适应宽"
                                 (rtos rect-w 2 2) "×高" (rtos height 2 2) "）及居中文注。")))))))
        (princ (strcat "\r\n[" tag-name "] 分解后至少需要两条水平直线。"))))
    (princ (strcat "\r\n[" tag-name "] 必须选择直线或多段线。")))
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

;;; Command: ZJ
;;; Function: 选中两条水平线后向左生成短线、矩形并居中标注原理号及终点柜名（青色虚线）。
(defun c:ZJ ()
  (aa:km-ln-cmd "ZJ" T "原理号" "原理号" "终点柜名")
)

;;; Command: YJ
;;; Function: 选中两条水平线后向右生成短线、矩形并居中标注原理号及终点柜名（青色虚线）。
(defun c:YJ ()
  (aa:km-ln-cmd "YJ" nil "原理号" "原理号" "终点柜名")
)

;;; =======================================================================================
;;; YDZ / YDY：为多条水平直线左端/右端生成连接短线与矩形，
;;; 直线上方从上往下依次标注 701、-901、-903、-905...，矩形正中心居中标注“公用测控柜”。
;;; 线段与矩形线型统一为 HIDDEN2，颜色统一为青色（ACI 4），文字统一为青色（ACI 4）。
;;; =======================================================================================

(defun aa:yd-cmd (tag-name is-left
                  / *error* doc undo-open oldcmd oldct oldce
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
        undo-open nil
        oldcmd nil
        oldct nil
        oldce nil)

  (defun *error* (msg)
    (if oldcmd (setvar "CMDECHO" oldcmd))
    (if oldct (setvar "CELTYPE" oldct))
    (if oldce (setvar "CECOLOR" oldce))
    (if undo-open
      (vl-catch-all-apply 'vla-EndUndoMark (list doc)))
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
      (vl-catch-all-apply 'vla-StartUndoMark (list doc))
      (setq undo-open T)
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
                     (equal (cadr p1) (cadr p2) 1e-6)
                     (or (null base-z)
                         (equal (if (caddr p1) (caddr p1) 0.0) base-z 1e-6))
                     (equal (if (caddr p1) (caddr p1) 0.0)
                            (if (caddr p2) (caddr p2) 0.0) 1e-6))
              (progn
                (if (null base-z)
                  (setq base-z (if (caddr p1) (caddr p1) 0.0)))
                (setq lines-by-y (cons (list (cadr p1) en p1 p2) lines-by-y)))
              (setq valid nil)))

          (if (not valid)
            (princ (strcat "\r\n[" tag-name "] 所选直线必须全部水平且位于同一标高。"))
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

                  ;; 2. 创建矩形内文字“公用测控柜”，测量自适应宽度
                  (setq t-rect-en (aa:km-create-centered-text doc "公用测控柜" (list joint-x center-y base-z)))
                  (setq t-rect-bbox (if t-rect-en (aa:safe-get-bbox doc t-rect-en) nil))
                  (setq t-w (if t-rect-bbox
                              (- (aa:bbox-right-x t-rect-bbox) (aa:bbox-left-x t-rect-bbox))
                              (* (strlen "公用测控柜") 3.0 0.7)))
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

                  ;; 5. 生成短线上方标注文字（从上往下：701、-901、-903、-905...）
                  (setq idx 0)
                  (foreach cur-y y-keys
                    (if (= idx 0)
                      (setq cur-txt "701")
                      (setq cur-txt (strcat "-9" (if (< (+ 1 (* (1- idx) 2)) 10)
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
  (sssetfirst nil nil)
  (princ)
)

;;; Command: YDZ
;;; Function: 选中多条水平线后向左生成短线、矩形并从上往下标注701、-901、-903...及公用测控柜（青色虚线）。
(defun c:YDZ ()
  (aa:yd-cmd "YDZ" T)
)

;;; Command: YDY
;;; Function: 选中多条水平线后向右生成短线、矩形并从上往下标注701、-901、-903...及公用测控柜（青色虚线）。
(defun c:YDY ()
  (aa:yd-cmd "YDY" nil)
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
;;; 命令: DAO
;;; 功能: 将选中的从上到下排列的文字顺序颠倒：最下面的文字放到最上面，
;;;       从下往上倒数第二个变成从上往下第二个，其余依此类推。
;;; =======================================================================================

;;; 判断 item 是否应排在 other 之前（Y 大在前；同一行 X 小在前）
(defun dao:upper-p (item other / y1 y2)
  (setq y1 (cadr (cadr item))
        y2 (cadr (cadr other)))
  (if (equal y1 y2 1e-6)
    (< (car (cadr item)) (car (cadr other)))
    (> y1 y2)
  )
)

;;; 把 item 插入已排序列表（保持 Y 降序、同行 X 升序）
(defun dao:insert-sorted (item sorted / result done)
  (setq result '()
        done   nil)
  (while (and sorted (not done))
    (if (dao:upper-p item (car sorted))
      (setq done T)
      (progn
        (setq result (append result (list (car sorted))))
        (setq sorted (cdr sorted))
      )
    )
  )
  (append result (list item) sorted)
)

;;; 平移文字：entmod 修改组码 10（TEXT 若有 11 对齐点则同步平移）
(defun dao:move-text (ename dx dy / ed p10 p11 ok)
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
      (setq ok (entmod ed))
      (if ok
        (progn
          (entupd ename)
          T)
        nil))
    nil)
)

(defun c:DAO (/ *error* doc undo-open ss i ename ed typ p10 lst sorted n
               cur target dx dy moved skipped)
  (vl-load-com)
  (setq doc       (vla-get-activedocument (vlax-get-acad-object))
        undo-open nil
        moved     0
        skipped   0)

  (defun *error* (msg)
    (if undo-open
      (vl-catch-all-apply 'vla-endundomark (list doc))
    )
    (if (and msg
             (/= msg "Function cancelled")
             (/= msg "quit / exit abort"))
      (princ (strcat "\r\n[DAO] 错误: " msg))
    )
    (princ)
  )

  (princ "\r\n[DAO] 请选择要颠倒排列的文字 (TEXT/MTEXT): ")
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

      ;; 2. 插入排序：从上到下（Y 大在前，同一行 X 小在前）
      (setq sorted '())
      (foreach item lst
        (setq sorted (dao:insert-sorted item sorted))
      )
      (setq n (length sorted))

      (if (< n 2)
        (princ "\r\n[DAO] 有效文字不足 2 个，无需颠倒。")
        (progn
          (vla-startundomark doc)
          (setq undo-open T
                i         0)
          ;; 3. 第 i 个（从上到下）文字移到第 n-1-i 个文字的位置，实现上下颠倒
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
          (vla-endundomark doc)
          (setq undo-open nil)
          (princ
            (strcat
              "\r\n[DAO] 完成：共颠倒 " (itoa n) " 个文字，已处理 " (itoa moved)
              " 个，跳过 " (itoa skipped) " 个。"))
        )
      )
    )
    (princ "\r\n[DAO] 未选择任何文字对象。")
  )
  (princ)
)
(princ "\r\n[DAO] 文字上下颠倒命令已加载，选中文字后输入 DAO 运行。")
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

(defun hddl:clear-markers (/ ss i)
  (if (setq ss (ssget "_X" '((0 . "TEXT") (8 . "HDDL_MARK"))))
    (progn
      (setq i 0)
      (repeat (sslength ss)
        (entdel (ssname ss i))
        (setq i (1+ i))))))

(defun hddl:text (ed)
  (aa:ysdl-get-plain-text ed))

(defun hddl:color (e c / d)
  (if (setq d (entget e))
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

(defun hddl:insert-sorted (rec sorted / head)
  (if (null sorted)
    (list rec)
    (if (hddl:row-sort rec (car sorted))
      (cons rec sorted)
      (cons (car sorted) (hddl:insert-sorted rec (cdr sorted))))))

(defun hddl:sort (items / result rec)
  (setq result nil)
  (foreach rec items (setq result (hddl:insert-sorted rec result)))
  result)

(defun hddl:add-row (rec rows / y out hit row)
  (setq y (hddl:coord rec 1) out '() hit nil)
  (foreach row rows
    (if (and (not hit) (<= (abs (- y (hddl:coord (car row) 1))) 1.0))
      (progn (setq out (append out (list (append row (list rec)))) hit T))
      (setq out (append out (list row)))))
  (if hit out (append out (list (list rec)))))

(defun hddl:sort-rows (rows / out row)
  (setq out '())
  (foreach row rows (setq out (append out (list (hddl:sort row)))))
  out)

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
  (entmakex (list '(0 . "TEXT") (cons 8 layer) (cons 10 p) (cons 40 h)
                  (cons 1 txt) (cons 7 style) (cons 50 rot) '(62 . 1))))

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

(defun hddl:tail-count (row / rest n v one)
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

(defun hddl:tail-different-p (a b / i va vb hit)
  ;; 第 6 列起为原理号；逐列比较镜像行的实际内容，而不只比较数量。
  (setq i 5 hit nil)
  (while (and (not hit) (or (hddl:item a i) (hddl:item b i)))
    (setq va (hddl:cell a i) vb (hddl:cell b i))
    (if (/= (strcase va) (strcase vb)) (setq hit T))
    (setq i (1+ i)))
  hit)

(defun hddl:color-tail-diffs (row other / i va vb rec)
  ;; 仅将镜像行中内容不同的原理号单元格标红，芯数及相同原理号保持原色。
  (setq i 5)
  (while (or (hddl:item row i) (hddl:item other i))
    (setq va (hddl:cell row i) vb (hddl:cell other i))
    (if (/= (strcase va) (strcase vb))
      (foreach rec (list (hddl:item row i) (hddl:item other i))
        (if (and rec (car rec)) (hddl:color (car rec) 1))))
    (setq i (1+ i))))

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
                 issue bad marker made mirror-ok olderr stage highlight-type)
  (setq olderr *error*)
  (defun *error* (msg)
    (aa:undo-mark-off)
    (if (and msg (/= (strcase msg) "FUNCTION CANCELLED"))
      (princ (strcat "\r\n[HDDL] 校核失败（阶段：" stage "）：" msg)))
    (setq *error* olderr)
    (princ))
  (aa:undo-mark-on)
  (princ "\r\n请选择要校核的 YSDL 文字: ")
  (if (setq ss (ssget '((0 . "TEXT,MTEXT"))))
    (progn
      (setq stage "清理旧标记")
      (hddl:ensure-layer)
      (hddl:clear-markers)
      (setq stage "读取文字")
      (setq items '() i 0)
      (repeat (sslength ss)
        (setq e (ssname ss i) d (entget e))
        (setq items (cons (list e (hddl:text d) (hddl:point (cdr (assoc 10 d)))) items))
        (setq i (1+ i)))
      ;; 逐条按 Y 坐标归行，再只对每一行的小列表按 X 排序，避免大列表递归。
      (setq stage "按坐标分行" rows '())
      (foreach rec items (setq rows (hddl:add-row rec rows)))
      (setq rows (hddl:sort-rows rows))
      ;; 第二列是 YSDL 的电缆编号列；先按编号收集整行，随后排除合法镜像行。
      (setq stage "按电缆编号分组")
      (setq groups '())
      (foreach row rows
        (setq id (hddl:cell row 1))
        (if (/= id "")
          (if (assoc (strcase id) groups)
            (setq groups
              (subst (cons (strcase id) (append (cdr (assoc (strcase id) groups)) (list row)))
                     (assoc (strcase id) groups) groups))
            (setq groups (cons (cons (strcase id) (list row)) groups)))))
      (setq stage "检查编号和原理号" bad 0 made 0)
      (foreach row rows
        (setq id (hddl:cell row 1) issue nil highlight-type nil)
        (if (/= id "")
          (progn
            (setq grp (cdr (assoc (strcase id) groups))
                  mirror-ok (and (= (length grp) 2)
                                 (hddl:mirror-p (car grp) (cadr grp))))
            (cond
              ((hddl:tail-duplicate-p row)
               (setq issue "[原理号重复]" highlight-type 'duplicate-principle))
              ((and mirror-ok (/= (hddl:tail-count (car grp))
                                  (hddl:tail-count (cadr grp))))
               (setq issue "[原理号数量不一致]" highlight-type 'core-count))
              ((and mirror-ok
                    (hddl:tail-different-p (car grp) (cadr grp)))
               (setq issue "[原理号不一致]" highlight-type 'principle))
              ((and (= (length grp) 2) (not mirror-ok))
               (setq issue "[柜名不一致]" highlight-type 'cabinet))
              ((not mirror-ok)
               (setq issue "[电缆编号重复]" highlight-type 'cable-id)))))
        (if issue
          (progn
            (setq bad (1+ bad))
            (cond
              ((= highlight-type 'duplicate-principle)
               (hddl:color-tail-duplicates row))
              ((= highlight-type 'core-count)
               (hddl:color-core-count-diff (car grp) (cadr grp)))
              ((= highlight-type 'principle)
               (hddl:color-tail-diffs (car grp) (cadr grp)))
              ((= highlight-type 'cabinet)
               (hddl:color-cabinet-diffs (car grp) (cadr grp)))
              (T (hddl:color-cell row 1)))
            (setq marker (hddl:make-marker (car row) issue))
            (if marker (setq made (1+ made))))))
      (setq stage "绘制问题标记")
      (redraw)
      (alert (strcat "HDDL 校核完成\r\n\r\n问题行: " (itoa bad)
                     "\r\n已生成红色标记: " (itoa made)
                     "\r\n\r\n规则：合法的起终点互换镜像行不标红；同向重复、原理号数量不一致会标红芯数，柜名不一致会标红柜名，原理号内容不一致或重复会标红对应原理号。")))
      (princ "\r\n未选择文字。"))
  (aa:undo-mark-off)
  (setq *error* olderr)
  (princ))

;;;----------------------------------------------------------------------------------------
;;; CU / CD：按 5 个单位的递增间距向上或向下复制
;;;----------------------------------------------------------------------------------------

(defun cu:copy-vertical (direction / *error* doc undo-open ss count level i obj clone
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
                  delta (trans (list 0.0 offset 0.0) 1 0 T)
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
  (cu:copy-vertical 1.0))

;;; CD：将选中对象向下复制到 5、10、15……单位的位置。
(defun c:CD ()
  (cu:copy-vertical -1.0))
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
                 pt pt-wcs cur-pt count sty-name)
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

(princ)

