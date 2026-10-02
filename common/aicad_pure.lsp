;;; Build-time source; do not add this file to CAD startup loading.
;;; scripts/sync_common.py emits the existing module namespaces in place.
(defun common:normalize-path (path)
  (if path
    (vl-string-translate "/" "\\" path)
    ""
  )
)

(defun common:not-empty-p (value)
  (and value (/= value ""))
)

(defun common:error-message (err)
  (cond
    ((vl-catch-all-error-p err) (vl-catch-all-error-message err))
    ((= (type err) 'STR) err)
    (T "")
  )
)
