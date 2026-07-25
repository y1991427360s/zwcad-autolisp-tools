;;; Encoding: GBK/ANSI, CRLF.
;;; ZJ：为多条水平直线左端补齐连接线，并在左侧生成矩形。

(defun c:ZJ (/ *error* doc undo-open oldcmd ss i en ed p1 p2 left
              left-points min-left-x min-y max-y base-z valid
              joint-x left-x height center-y bottom top rect1 rect2
              created failed)
  (vl-load-com)
  (setq doc (vla-get-ActiveDocument (vlax-get-acad-object))
        undo-open nil
        oldcmd nil)

  (defun *error* (msg)
    (if oldcmd (setvar "CMDECHO" oldcmd))
    (if undo-open
      (vl-catch-all-apply 'vla-EndUndoMark (list doc)))
    (sssetfirst nil nil)
    (if (and msg
             (not (wcmatch (strcase msg) "*BREAK*,*CANCEL*,*EXIT*,*QUIT*")))
      (princ (strcat "\n[ZJ] 错误：" msg)))
    (princ))

  (setq ss (ssget "_I" '((0 . "LINE"))))
  (if (null ss)
    (progn
      (princ "\n[ZJ] 请选择两条或更多水平直线：")
      (setq ss (ssget "_:L" '((0 . "LINE"))))))

  (if (and ss (>= (sslength ss) 2))
    (progn
      (setq i 0
            left-points nil
            min-left-x nil
            min-y nil
            max-y nil
            base-z nil
            valid T)
      (repeat (sslength ss)
        (setq en (ssname ss i)
              ed (entget en)
              p1 (cdr (assoc 10 ed))
              p2 (cdr (assoc 11 ed)))
        (if (and p1 p2
                 (equal (cadr p1) (cadr p2) 1e-8)
                 (or (null base-z)
                     (equal (if (caddr p1) (caddr p1) 0.0) base-z 1e-8))
                 (equal (if (caddr p1) (caddr p1) 0.0)
                        (if (caddr p2) (caddr p2) 0.0) 1e-8))
          (progn
            (setq left (if (<= (car p1) (car p2)) p1 p2))
            (if (null base-z)
              (setq base-z (if (caddr left) (caddr left) 0.0)))
            (setq left-points (cons left left-points)
                  min-left-x (if min-left-x (min min-left-x (car left)) (car left))
                  min-y (if min-y (min min-y (cadr left)) (cadr left))
                  max-y (if max-y (max max-y (cadr left)) (cadr left))))
          (setq valid nil))
        (setq i (1+ i)))

      (if valid
        (progn
          (setq joint-x (- min-left-x 10.0)
                left-x (- joint-x 12.0)
                height (max 20.0 (+ (- max-y min-y) 4.0))
                center-y (/ (+ min-y max-y) 2.0)
                bottom (- center-y (/ height 2.0))
                top (+ center-y (/ height 2.0))
                rect1 (list left-x bottom base-z)
                rect2 (list joint-x top base-z)
                oldcmd (getvar "CMDECHO")
                created 0
                failed 0)
          (setvar "CMDECHO" 0)
          (vl-catch-all-apply 'vla-StartUndoMark (list doc))
          (setq undo-open T)

          (foreach left left-points
            (if (entmakex
                  (list '(0 . "LINE")
                        (cons 8 (getvar "CLAYER"))
                        (cons 10 left)
                        (cons 11 (list joint-x (cadr left) base-z))))
              (setq created (1+ created))
              (setq failed (1+ failed))))

          (command "_.RECTANG" "_non" rect1 "_non" rect2)
          (redraw)
          (vl-catch-all-apply 'vla-EndUndoMark (list doc))
          (setq undo-open nil)
          (setvar "CMDECHO" oldcmd)
          (setq oldcmd nil)
          (princ
            (strcat "\n[ZJ] 已为 " (itoa created) " 条水平直线生成左侧连接线和矩形，矩形宽 12、高 "
                    (rtos height 2 2) "。"
                    (if (> failed 0)
                      (strcat " 有 " (itoa failed) " 条连接线生成失败。")
                      ""))))
        (princ "\n[ZJ] 所选直线必须全部水平且位于同一标高。")))
    (princ "\n[ZJ] 必须选择两条或更多直线。"))
  (sssetfirst nil nil)
  (princ)
)

(princ "\nZJ 命令已加载。")
(princ)
