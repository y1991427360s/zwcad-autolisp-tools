;;; Priority loader for the AA integrated package.
;;; ASCII-only startup shim for AutoCAD/ZWCAD.
(vl-load-com)

(defun AA-Priority-Autoload (/ dir files target)
  (setq dir "E:/366256/ZW-auto_lisp")
  (setq files (vl-directory-files dir "AA*.lsp" 1))
  (setq files
    (vl-remove-if
      '(lambda (f)
         (or
           (= (strcase f) "AA-LOADER.LSP")
           (= (strcase f) "AA-MAIN.LSP")
           (wcmatch (strcase f) "* - *")
         )
       )
      files
    )
  )
  (setq target (car files))
  (if target
    (load (strcat dir "/" target) nil)
    (prompt "\nAA priority loader: integrated AA LSP not found.")
  )
  (princ)
)

(AA-Priority-Autoload)
