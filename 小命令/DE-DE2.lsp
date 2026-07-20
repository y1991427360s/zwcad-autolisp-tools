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
  (if (vl-catch-all-error-p result)
    nil
    result)
)

(defun de:set-text (ent txt / obj result)
  (setq obj (vlax-ename->vla-object ent)
        result (vl-catch-all-apply 'vla-put-TextString (list obj txt)))
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
      (princ (strcat "\n错误: " msg)))
    (princ)
  )
  (prompt "\n选择要处理的单行文字、多行文字或属性文字: ")
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
      (princ (strcat "\n已处理 " (itoa changed) " 个文字"))
      (if (> skipped 0)
        (princ (strcat "，" (itoa skipped) " 个文字写入失败")))
    )
    (princ "\n未选中文字")
  )
  (princ)
)

(defun c:DE () (de:run 0))
(defun c:DE2 () (de:run 1))

(princ "\nDE / DE2 已加载：DE=删除括号及内容；DE2=用括号内容替换括号前数字。")
(princ)
