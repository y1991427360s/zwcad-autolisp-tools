(vl-load-com)

(setq *AICADAA_BaseDirectoryEnvVar* "AICADAA_BASEDIR")
(setq *AICADAA_DefaultInstallDirectory* "E:\\366256\\ZW-auto_lisp\\V6")
(setq *AICADAA_EnvStack* nil)
(setq *AICADAA_SystemVariablesToRestore*
  '("CMDECHO" "OSMODE" "PICKFIRST" "FILEDIA" "CMDDIA")
)

(defun aicadloader:error-message (err)
  (cond
    ((vl-catch-all-error-p err) (vl-catch-all-error-message err))
    ((= (type err) 'STR) err)
    (T "")
  )
)

(defun aicadloader:save-system-variables (/ saved name value)
  (setq saved '())
  (foreach name *AICADAA_SystemVariablesToRestore*
    (setq value (vl-catch-all-apply 'getvar (list name)))
    (if (not (vl-catch-all-error-p value))
      (setq saved (cons (cons name value) saved))
    )
  )
  saved
)

(defun aicadloader:restore-system-variables (saved / item)
  (foreach item saved
    (vl-catch-all-apply 'setvar (list (car item) (cdr item)))
  )
)

(defun aicadloader:push-environment ()
  (setq *AICADAA_EnvStack*
    (cons (aicadloader:save-system-variables) *AICADAA_EnvStack*)
  )
)

(defun aicadloader:pop-environment (/ saved)
  (if *AICADAA_EnvStack*
    (progn
      (setq saved (car *AICADAA_EnvStack*))
      (setq *AICADAA_EnvStack* (cdr *AICADAA_EnvStack*))
      (aicadloader:restore-system-variables saved)
    )
  )
)

(defun aicadloader:restore-all-environments ()
  (while *AICADAA_EnvStack*
    (aicadloader:pop-environment)
  )
)

(defun aicadloader:safe-apply (context fn args / result message)
  (aicadloader:push-environment)
  (setq result (vl-catch-all-apply fn args))
  (aicadloader:pop-environment)
  (if (vl-catch-all-error-p result)
    (progn
      (setq message (aicadloader:error-message result))
      (princ (strcat "\nAICAD loader error in " context ": " message))
      nil
    )
    result
  )
)

(defun *error* (message)
  (aicadloader:restore-all-environments)
  (princ (strcat "\nAICAD loader interrupted: " message))
  (princ)
)

(defun aicadloader:normalize-path (path)
  (if path
    (vl-string-translate "/" "\\" path)
    ""
  )
)

(defun aicadloader:not-empty-p (value)
  (and value (/= value ""))
)

(defun aicadloader:combine-path (base name / clean-base)
  (setq clean-base (vl-string-right-trim "\\/" (aicadloader:normalize-path base)))
  (if (= clean-base "")
    ""
    (strcat clean-base "\\" name)
  )
)

(defun aicadloader:file-exists-p (path / normalized)
  (setq normalized (aicadloader:normalize-path path))
  (if (and (aicadloader:not-empty-p normalized) (findfile normalized))
    T
    nil
  )
)

(defun aicadloader:directory-score (directory / normalized score)
  (setq normalized (aicadloader:normalize-path directory))
  (setq score 0)
  (if (aicadloader:not-empty-p normalized)
    (progn
      (if (aicadloader:file-exists-p (aicadloader:combine-path normalized "aicad_extension.lsp"))
        (setq score (+ score 2))
      )
      (if (or
            (aicadloader:file-exists-p (aicadloader:combine-path normalized "AICADRibbonHostV6.dll"))
            (aicadloader:file-exists-p (aicadloader:combine-path normalized "AICADRibbonHostV5.dll"))
            (aicadloader:file-exists-p (aicadloader:combine-path normalized "AICADRibbonHost.dll"))
            (aicadloader:file-exists-p (aicadloader:combine-path normalized "AICADRibbon.dll"))
          )
        (setq score (+ score 1))
      )
    )
  )
  score
)

(defun aicadloader:directory-for-found-file (file-name / found-path)
  (if (setq found-path (findfile file-name))
    (vl-filename-directory (aicadloader:normalize-path found-path))
    ""
  )
)

(defun aicadloader:candidate-directories ()
  (list
    *AICADAA_DefaultInstallDirectory*
    (if (and (boundp '*AICADAA_LoaderDirectory*)
             (aicadloader:not-empty-p *AICADAA_LoaderDirectory*))
      *AICADAA_LoaderDirectory*
      ""
    )
    (getenv *AICADAA_BaseDirectoryEnvVar*)
    (aicadloader:directory-for-found-file "aicad_extension.lsp")
    (aicadloader:directory-for-found-file "AICADRibbonHostV6.dll")
    (aicadloader:directory-for-found-file "AICADRibbonHostV5.dll")
    (aicadloader:directory-for-found-file "AICADRibbonHost.dll")
    (aicadloader:directory-for-found-file "AICADRibbon.dll")
    (getvar "DWGPREFIX")
  )
)

(defun aicadloader:select-best-directory (directories / best-dir best-score candidate candidate-score)
  (setq best-dir ""
        best-score 0)
  (foreach candidate directories
    (setq candidate-score (aicadloader:directory-score candidate))
    (if (> candidate-score best-score)
      (progn
        (setq best-dir (aicadloader:normalize-path candidate))
        (setq best-score candidate-score)
      )
    )
  )
  best-dir
)

(defun aicadloader:prompt-for-base-directory (/ start-path picked-path picked-dir)
  (setq start-path
    (cond
      ((aicadloader:not-empty-p (getenv *AICADAA_BaseDirectoryEnvVar*))
       (getenv *AICADAA_BaseDirectoryEnvVar*)
      )
      ((aicadloader:not-empty-p *AICADAA_DefaultInstallDirectory*)
       *AICADAA_DefaultInstallDirectory*
      )
      (T
       (strcat (getenv "USERPROFILE") "\\Desktop")
      )
    )
  )
  (vl-catch-all-apply 'setvar (list "FILEDIA" 1))
  (vl-catch-all-apply 'setvar (list "CMDDIA" 1))
  (setq picked-path
    (getfiled
      "Locate aicad_extension.lsp or AICADRibbonHost.dll"
      start-path
      ""
      0
    )
  )
  (if (aicadloader:not-empty-p picked-path)
    (setq picked-dir (vl-filename-directory (aicadloader:normalize-path picked-path)))
    (setq picked-dir "")
  )
  (if (> (aicadloader:directory-score picked-dir) 0)
    picked-dir
    ""
  )
)

(defun aicadloader:remember-base-directory (directory / normalized)
  (setq normalized (aicadloader:normalize-path directory))
  (if (> (aicadloader:directory-score normalized) 0)
    (progn
      (setq *AICADAA_LoaderDirectory* normalized)
      (setenv *AICADAA_BaseDirectoryEnvVar* normalized)
      normalized
    )
    ""
  )
)

(defun aicadloader:base-directory (/ candidate)
  (setq candidate (aicadloader:select-best-directory (aicadloader:candidate-directories)))
  (if (= candidate "")
    (setq candidate (aicadloader:prompt-for-base-directory))
  )
  (aicadloader:remember-base-directory candidate)
)

(setq *AICADAA_LoaderDirectory*
  (aicadloader:remember-base-directory
    (aicadloader:select-best-directory (aicadloader:candidate-directories))
  )
)

(defun aicadloader:show-replace-panel ()
  (setq replace-panel-result (vl-catch-all-apply 'vl-cmdf (list "AICADREPLACEPANEL")))
  (if (vl-catch-all-error-p replace-panel-result)
    (princ (strcat "\nAICADREPLACEPANEL failed: " (aicadloader:error-message replace-panel-result)))
  )
)

(defun aicadloader:command-load (/ base-dir lsp-path dll-path hosted-v6-dll-path hosted-v5-dll-path hosted-dll-path standard-dll-path netload-result replace-panel-result)
  (setq base-dir (aicadloader:base-directory))
  (setq lsp-path (aicadloader:combine-path base-dir "aicad_extension.lsp"))
  (setq hosted-v6-dll-path (aicadloader:combine-path base-dir "AICADRibbonHostV6.dll"))
  (setq hosted-v5-dll-path (aicadloader:combine-path base-dir "AICADRibbonHostV5.dll"))
  (setq standard-dll-path (aicadloader:combine-path base-dir "AICADRibbon.dll"))
  (setq hosted-dll-path (aicadloader:combine-path base-dir "AICADRibbonHost.dll"))
  (setq dll-path
    (cond
      ((aicadloader:file-exists-p hosted-v6-dll-path)
       hosted-v6-dll-path
      )
      ((aicadloader:file-exists-p hosted-v5-dll-path)
       hosted-v5-dll-path
      )
      ((aicadloader:file-exists-p hosted-dll-path)
       hosted-dll-path
      )
      ((aicadloader:file-exists-p standard-dll-path)
       standard-dll-path
      )
      (T
       hosted-dll-path
      )
    )
  )
  (setq *AICAD_BaseDirectory* base-dir)

  (princ (strcat "\nAICAD base folder: " base-dir))

  (if (aicadloader:file-exists-p lsp-path)
    (progn
      (if (not c:AICADRIBBON)
        (progn
          (princ (strcat "\nLoading LISP: " lsp-path))
          (load lsp-path)
        )
      )
    )
    (princ (strcat "\nMissing aicad_extension.lsp: " lsp-path))
  )

  (if (aicadloader:file-exists-p dll-path)
    (progn
      (princ (strcat "\nLoading DLL: " dll-path))
      (setq netload-result (vl-catch-all-apply 'vl-cmdf (list "_.NETLOAD" dll-path)))
      (if (vl-catch-all-error-p netload-result)
        (princ (strcat "\nNETLOAD failed: " (aicadloader:error-message netload-result)))
      )
    )
    (princ (strcat "\nMissing Ribbon DLL: " dll-path))
  )

  (princ "\nAICAD ribbon loader finished.")
  (princ)
)

(defun c:LOADAICADAA ()
  (aicadloader:safe-apply "LOADAICADAA" 'aicadloader:command-load '())
  (if (and (boundp '*AICAD_ReplacePanelOnLoad*) *AICAD_ReplacePanelOnLoad*)
    (aicadloader:show-replace-panel)
  )
  (princ)
)

(defun c:LOADAICADZW ()
  (c:LOADAICADAA)
)

(defun c:AICADREPLACEPANELSHOW ()
  (aicadloader:safe-apply "AICADREPLACEPANELSHOW" 'aicadloader:show-replace-panel '())
  (princ)
)

;; 启动时加载插件,替换面板默认手动打开。
(setq *AICAD_ReplacePanelOnLoad* nil)

(c:LOADAICADAA)
