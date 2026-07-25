;;; 0.lsp
;;; 命令 0：将所选对象中的文字旋转角度统一改为 0 度。

(vl-load-com)

(defun c:0 (/ ss index entity data entity-type changed failed)
  (setq changed 0
        failed  0)
  (prompt "\n请选择要处理的对象：")
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
          "\n已将 "
          (itoa changed)
          " 个文字对象的旋转角度改为 0 度。"))
      (if (> failed 0)
        (prompt
          (strcat
            " 另有 "
            (itoa failed)
            " 个文字对象修改失败。"))))
    (prompt "\n未选择对象。"))
  (princ))

(princ "\n命令 0 已加载：将所选文字对象的旋转角度改为 0 度。")
(princ)
