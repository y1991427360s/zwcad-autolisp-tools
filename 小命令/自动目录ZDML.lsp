;;; 自动目录ZDML.lsp
;;; 中望 CAD / AutoCAD 图框增强属性批量统计目录
;;; 命令:
;;;   ZDML      - 选择多个图框块，生成目录文字
;;;   ZDMLDEBUG - 选择一个图框块，打印所有增强属性

(vl-load-com)

;;; ---------------- 用户可修改参数 ----------------
(setq *TKTJ-COL-OFFSETS* '(0.0 7.5 57.5))
(setq *TKTJ-ROW-GAP* 9.0)
(setq *TKTJ-TEXT-HEIGHT* 4.0)
(setq *TKTJ-TEXT-STYLE* "宋体")
(setq *TKTJ-TEXT-FONTFILE* "simsun.ttc")
(setq *TKTJ-TEXT-WIDTH-FACTOR* 0.8)
(setq *TKTJ-OUTPUT-HEADER* T)
(setq *TKTJ-SORT-BY-POSITION* T)
(setq *TKTJ-ROW-SORT-TOL* 5.0)
(setq *TKTJ-SORT-BY-PAGE* nil)

;;; ---------------- 字段候选映射 ----------------
(setq *TKTJ-SHEETNO-TAGS*
       '("档案号"))

(setq *TKTJ-SHEETNAME-TAGS*
       '("图纸名称"))

(setq *TKTJ-PAGE-TAGS*
       '("页码" "页号" "PAGE" "SHEET"))

(setq *TKTJ-ARCHIVE-TAGS*
       '("档案号" "档号" "文件号" "DWGNO" "DRAWINGNO"))

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
  (setq p (vlax-safearray->list (vlax-variant-value (vla-get-InsertionPoint blockObj))))
  (list (car p) (cadr p) (if (caddr p) (caddr p) 0.0))
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

;;; ---------------- 属性读取与字段提取 ----------------
(defun tktj:get-attributes (blockObj / atts att tag val result)
  ;; 返回原始 TagString 关联表，例如 (("图纸名称" . "xxx") ("页码" . "3"))。
  (setq result nil)
  (if (= :vlax-true (vla-get-HasAttributes blockObj))
    (progn
      (setq atts (tktj:safe-getattributes blockObj))
      (foreach att atts
        (setq tag (tktj:trim (vla-get-TagString att)))
        (setq val (tktj:trim (vla-get-TextString att)))
        (if (> (strlen tag) 0)
          (setq result (append result (list (cons tag val))))
        )
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
  ;; 只有同一个块内同时找到“档案号”和“图纸名称”时，才返回一条目录数据。
  (setq attrs (tktj:get-attributes blockObj))
  (if attrs
    (progn
      (setq insPt (tktj:block-point blockObj))
      (setq namePair (tktj:get-first-pair attrs *TKTJ-SHEETNAME-TAGS* nil))
      (setq noPair (tktj:get-first-pair attrs *TKTJ-SHEETNO-TAGS* nil))
      (setq page (tktj:get-first-value attrs *TKTJ-PAGE-TAGS*))
      (setq archive (tktj:get-first-value attrs *TKTJ-ARCHIVE-TAGS*))
      (if (and noPair namePair)
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
(defun tktj:add-text (pt txt / obj)
  ;; 在当前空间插入左对齐单行文字，图层/颜色默认 ByLayer。
  (setq obj
        (vla-AddText
          (tktj:current-space)
          (if txt (vl-princ-to-string txt) "")
          (vlax-3d-point pt)
          *TKTJ-TEXT-HEIGHT*
        )
  )
  (vla-put-Layer obj (getvar "CLAYER"))
  (vla-put-StyleName obj (tktj:ensure-text-style))
  (vl-catch-all-apply 'vla-put-Alignment (list obj 0))
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

(defun tktj:draw-row (base rowIndex values / x y col pt)
  (setq y (- (cadr base) (* rowIndex *TKTJ-ROW-GAP*)))
  (setq col 0)
  (foreach txt values
    (setq x (+ (car base) (tktj:nth-offset col *TKTJ-COL-OFFSETS*)))
    (setq pt (list x y (if (caddr base) (caddr base) 0.0)))
    (tktj:add-text pt txt)
    (setq col (1+ col))
  )
)

(defun tktj:draw-table (dataList basePt / rowIndex item values)
  ;; 根据数据列表和基点生成三列目录文字。
  (setq rowIndex 0)
  (if *TKTJ-OUTPUT-HEADER*
    (progn
      (tktj:draw-row basePt rowIndex '("序号" "档案号" "图纸名称"))
      (setq rowIndex (1+ rowIndex))
    )
  )
  (foreach item dataList
    (setq values
           (list
             (itoa (1+ (- rowIndex (if *TKTJ-OUTPUT-HEADER* 1 0))))
             (tktj:assoc-data 'sheetNo item)
             (tktj:assoc-data 'sheetName item)
           )
    )
    (tktj:draw-row basePt rowIndex values)
    (setq rowIndex (1+ rowIndex))
  )
  dataList
)

;;; ---------------- 排序 ----------------
(defun tktj:sort-by-page (dataList)
  ;; 数字页码从小到大；非数字页码排到最后。
  (vl-sort
    dataList
    '(lambda (a b)
       (< (tktj:page-number (tktj:assoc-data 'page a))
          (tktj:page-number (tktj:assoc-data 'page b)))
     )
  )
)

(defun tktj:sort-by-position (dataList)
  ;; 图面阅读顺序：同一行先左到右，不同行再从上到下。
  (vl-sort
    dataList
    '(lambda (a b / ax ay bx by)
       (setq ax (tktj:assoc-data 'x a))
       (setq ay (tktj:assoc-data 'y a))
       (setq bx (tktj:assoc-data 'x b))
       (setq by (tktj:assoc-data 'y b))
       (if (<= (abs (- ay by)) *TKTJ-ROW-SORT-TOL*)
         (< ax bx)
         (> ay by)
       )
     )
  )
)

;;; ---------------- 主命令 ----------------
(defun C:ZDML (/ ss i ent obj one data basePt)
  (vl-load-com)
  (princ "\n请选择需要统计的图框块: ")
  (setq ss (ssget '((0 . "INSERT"))))
  (cond
    ((not ss)
     (princ "\n已取消。")
    )
    (T
     (setq i 0)
     (setq data nil)
     (while (< i (sslength ss))
       (setq ent (ssname ss i))
       (setq obj (vlax-ename->vla-object ent))
       (setq one (tktj:collect-one-block obj))
       (if one
         (setq data (append data (list one)))
       )
       (setq i (1+ i))
     )
     (if (not data)
       (princ "\n未选择有效图框块")
       (progn
         (cond
           (*TKTJ-SORT-BY-PAGE*
            (setq data (tktj:sort-by-page data))
           )
           (*TKTJ-SORT-BY-POSITION*
            (setq data (tktj:sort-by-position data))
           )
         )
         (setq basePt (getpoint "\n指定目录表左上角基点: "))
         (if basePt
           (progn
             (tktj:draw-table data basePt)
             (princ
               (strcat
                 "\n已提取 "
                 (itoa (length data))
                 " 个图框属性，并生成目录。"
               )
             )
           )
           (princ "\n已取消。")
         )
       )
     )
    )
  )
  (princ)
)

;;; ---------------- 调试命令 ----------------
(defun C:ZDMLDEBUG (/ ent obj attrs pair)
  (vl-load-com)
  (setq ent (car (entsel "\n请选择一个图框块: ")))
  (cond
    ((not ent)
     (princ "\n已取消。")
    )
    ((/= "INSERT" (cdr (assoc 0 (entget ent))))
     (princ "\n选择对象不是块参照。")
    )
    (T
     (setq obj (vlax-ename->vla-object ent))
     (setq attrs (tktj:get-attributes obj))
     (if attrs
       (progn
         (princ "\n该块增强属性如下:")
         (foreach pair attrs
           (princ
             (strcat
               "\n属性标记: "
               (car pair)
               "  值: "
               (cdr pair)
             )
           )
         )
       )
       (princ "\n该块没有增强属性。")
     )
    )
  )
  (princ)
)

(princ "\n自动目录ZDML.lsp 已加载。输入 ZDML 生成目录，输入 ZDMLDEBUG 查看块属性。")
(princ)
