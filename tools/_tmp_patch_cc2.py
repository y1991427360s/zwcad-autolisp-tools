# -*- coding: utf-8 -*-
"""Rewrite CC helpers: real ghost entity drag like CO."""
from pathlib import Path

src = Path(r"E:\366256\ZW-auto_lisp\AA整合版本.lsp")
raw = src.read_bytes()
text = raw.decode("utf-8")
assert not raw.startswith(b"\xef\xbb\xbf")
assert "�" not in text

marker = ";; CC 读取现有剪贴板，按 CO 的两点方式复制预选文字并替换副本内容"
idx = text.find(marker)
after = text.find(";; QW 内部", idx)
assert idx >= 0 and after > idx, "CC block bounds not found"
print("replace", idx, after, "old bytes", after - idx)

new_block = """;; CC 读取现有剪贴板，按 CO 的两点方式复制预选文字并替换副本内容
;; 基点确认后立刻创建真实副本并替换文字，拖动时移动该副本作为预览

;; CC内部: 在 UCS 下移动对象；from/to 为 UCS 点
(defun cc:move-ucs (obj from to)
  (if (and obj from to (listp from) (listp to)
           (not (equal from to 1e-8)))
    (vla-Move obj
      (vlax-3d-point (trans from 1 0))
      (vlax-3d-point (trans to 1 0)))
  )
)

;; CC内部: 基点后拖动已创建副本，返回 UCS 目标点；取消返回 nil
;; code 5/2+点=跟踪移动，code 3=点击确认，13/32=回车/空格，27=Esc
(defun cc:drag-object (copy-obj base / last-pt pt code ret done target)
  (setq last-pt base
        done nil
        target nil)
  (princ "\\n指定第二个点: ")
  (while (not done)
    (setq ret (vl-catch-all-apply 'grread (list T)))
    (if (or (vl-catch-all-error-p ret) (null ret))
      (setq done T)
      (progn
        (setq code (car ret)
              pt (cadr ret))
        (cond
          ;; 鼠标跟踪：移动真实副本
          ((and (member code '(5 2)) pt (listp pt))
           (cc:move-ucs copy-obj last-pt pt)
           (setq last-pt pt)
          )
          ;; 左键确认
          ((and (= code 3) pt (listp pt))
           (cc:move-ucs copy-obj last-pt pt)
           (setq target pt done T)
          )
          ;; 回车/空格：落在当前跟踪点
          ((and (member code '(1 2)) (numberp pt) (member pt '(13 32)))
           (setq target last-pt done T)
          )
          ;; Esc：取消
          ((and (member code '(1 2)) (numberp pt) (= pt 27))
           (setq target nil done T)
          )
          ;; 其它按键忽略
          ((member code '(1 2))
           nil
          )
          (T
           (setq target nil done T)
          )
        )
      )
    )
  )
  (redraw)
  target
)

(defun c:CC (/ *error* aa:tag aa:doc aa:undo-open aa:old-cmdecho
               clip-text ss src ed base target copy-obj)
  (setq ss (ssget "_I"))
  (aa:cmd-begin "CC")
  (defun *error* (msg)
    (if copy-obj
      (vl-catch-all-apply 'vla-Delete (list copy-obj)))
    (aa:cmd-error msg)
  )
  (setq clip-text (qe:get-clip-text))
  (cond
    ((not (= (type clip-text) 'STR))
     (princ "\\n[CC] 无法获取 Windows 剪贴板中的文字。"))
    ((= clip-text "")
     (princ "\\n[CC] 剪贴板中没有可用的文字。"))
    ((not ss)
     (princ "\\n[CC] 请先预选一个文字对象，再输入 CC。"))
    ((/= (sslength ss) 1)
     (princ "\\n[CC] 请只预选一个文字对象。"))
    (t
      (setq src (ssname ss 0)
            ed (entget src))
      (cond
        ((not (member (cdr (assoc 0 ed)) '("TEXT" "MTEXT" "ATTDEF")))
          (princ "\\n[CC] 请预选一个单行文字、多行文字或属性定义。"))
        ((setq base (getpoint "\\n指定第一个点（基点）: "))
          ;; 基点后立刻复制并写入剪贴板文字，拖动时就是真实文字预览
          (setq copy-obj (vla-Copy (vlax-ename->vla-object src)))
          (vla-put-TextString copy-obj clip-text)
          (setq target (cc:drag-object copy-obj base))
          (cond
            (target
              ;; 拖动路径中已移动到目标；COM 最终点再保险写入一次
              (cc:move-ucs copy-obj base target)
              (setq copy-obj nil)
              (princ "\\n[CC] 已完成复制，副本已替换为剪贴板文字。")
            )
            (T
              (vl-catch-all-apply 'vla-Delete (list copy-obj))
              (setq copy-obj nil)
              (princ "\\n[CC] 已取消。")
            )
          )
        )
      )
    )
  )
  (aa:cmd-end)
)

"""

# Fix double-move issue: during drag the object already moved from base
# along the path. Calling cc:move-ucs(copy-obj base target) again would
# DOUBLE the offset. Remove the final ensure move - drag already placed it.
# I'll correct new_block before write.

new_block = new_block.replace(
    """            (target
              ;; 拖动路径中已移动到目标；COM 最终点再保险写入一次
              (cc:move-ucs copy-obj base target)
              (setq copy-obj nil)
              (princ "\\n[CC] 已完成复制，副本已替换为剪贴板文字。")
            )""",
    """            (target
              ;; 拖动过程中已把副本移动到目标点，此处不再二次位移
              (setq copy-obj nil)
              (princ "\\n[CC] 已完成复制，副本已替换为剪贴板文字。")
            )""",
)

new_block = new_block.replace("\n", "\r\n")
# Python string in file: "\\n" in source becomes \n (backslash-n) in value - good for LISP.
# Wait - the write tool wrote the content with actual backslash-n sequences in the
# triple-quoted string as written. When I wrote `\\n` in the write content, the file
# contains `\\n` which Python interprets as `\n` (one backslash + n). Good.
# Real newlines are `\n` and we convert to `\r\n`. Good.

out_text = text[:idx] + new_block + text[after:]
out = out_text.encode("utf-8")
assert not out.startswith(b"\xef\xbb\xbf")
assert "�" not in out_text
assert b"\n" not in out.replace(b"\r\n", b""), "bare LF"
src.write_bytes(out)
print("written", len(out), "bytes")

# quick sanity: string escapes present
assert "(princ \"\\n指定第二个点: \")" in out_text or '(princ "\\n指定第二个点: ")' in out_text
# show a snippet
i = out_text.find("defun cc:drag-object")
print(out_text[i:i+200].replace("\r\n", " | "))
