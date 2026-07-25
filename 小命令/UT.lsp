;;; UT.lsp
;;; 命令：UT
;;; 用途：将选中的水平直线与其上方文字按最上方一对的相对位置统一整理。
;;; 说明：文字按从上到下与水平直线配对；仅移动文字，不改变文字属性和直线位置。

(vl-load-com)

(defun ut:abs (x)
  (if (< x 0.0) (- x) x)
)

(defun ut:horizontal-line-p (ename / ed p1 p2)
  (setq ed (entget ename)
        p1 (cdr (assoc 10 ed))
        p2 (cdr (assoc 11 ed)))
  (and p1 p2 (<= (ut:abs (- (cadr p1) (cadr p2))) 1e-8))
)

(defun ut:line-y (ename / ed p1 p2)
  (setq ed (entget ename)
        p1 (cdr (assoc 10 ed))
        p2 (cdr (assoc 11 ed)))
  (/ (+ (cadr p1) (cadr p2)) 2.0)
)

(defun ut:get-bbox (ename / obj minp maxp result)
  (setq obj (vlax-ename->vla-object ename))
  (setq result
    (vl-catch-all-apply 'vla-getboundingbox (list obj 'minp 'maxp)))
  (if (vl-catch-all-error-p result)
    nil
    (list (vlax-safearray->list minp)
          (vlax-safearray->list maxp)))
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
      (not (vl-catch-all-error-p result)))
    T)
)

(defun c:UT (/ *error* doc undo-open oldcmdecho ss i en ed typ
              lines texts line-items text-items line-count text-count
              pair-count base-line base-text base-bbox base-left base-gap
              line-item text-item line-y text-bbox target-left target-bottom
              dx dy changed skipped)
  (vl-load-com)
  (setq doc (vla-get-ActiveDocument (vlax-get-acad-object))
        undo-open nil
        oldcmdecho nil
        lines nil
        texts nil
        changed 0
        skipped 0)

  (defun *error* (msg)
    (if oldcmdecho
      (setvar "CMDECHO" oldcmdecho))
    (if undo-open
      (vl-catch-all-apply 'vla-EndUndoMark (list doc)))
    (sssetfirst nil nil)
    (if (and msg
             (not (wcmatch (strcase msg) "*BREAK*,*CANCEL*,*EXIT*,*QUIT*")))
      (princ (strcat "\n[UT] 错误：" msg)))
    (princ)
  )

  (setq ss (ssget "_I" '((0 . "LINE,TEXT,MTEXT"))))
  (if (null ss)
    (progn
      (princ "\n[UT] 请选择水平直线和其上方的文字：")
      (setq ss (ssget "_:L" '((0 . "LINE,TEXT,MTEXT"))))))
  (if ss
    (progn
      (setq i 0)
      (repeat (sslength ss)
        (setq en (ssname ss i)
              ed (entget en)
              typ (cdr (assoc 0 ed)))
        (cond
          ((and (= typ "LINE") (ut:horizontal-line-p en))
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

      (setq text-items nil)
      (foreach en texts
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
         (princ "\n[UT] 未找到水平直线。"))
        ((= text-count 0)
         (princ "\n[UT] 未找到有效的 TEXT/MTEXT 文字。"))
        (T
         (setq base-line (car line-items)
               base-text (car text-items)
               base-bbox (caddr base-text)
               base-left (ut:bbox-left base-bbox)
               base-gap (- (cadr base-text) (cadr base-line))
               oldcmdecho (getvar "CMDECHO"))
         (setvar "CMDECHO" 0)
         (vl-catch-all-apply 'vla-StartUndoMark (list doc))
         (setq undo-open T)
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
         (vl-catch-all-apply 'vla-EndUndoMark (list doc))
         (setq undo-open nil)
         (setvar "CMDECHO" oldcmdecho)
         (setq oldcmdecho nil)
         (princ
           (strcat
             "\n[UT] 整理完成：处理 " (itoa pair-count) " 对，移动 "
             (itoa changed) " 个文字。"
             (if (/= line-count text-count)
               (strcat " 选中的直线(" (itoa line-count) ")与文字("
                       (itoa text-count) ")数量不一致，按较少数量配对。")
               ""))))))
    (princ "\n[UT] 未选择对象。"))
  (sssetfirst nil nil)
  (princ)
)

(princ)
