(vl-load-com)

(setq *AICAD_BaseDirectoryEnvVar* "AICADAA_BASEDIR")
(setq *AICAD_DefaultInstallDirectory* "E:\\366256\\ZW-auto_lisp\\V6")

(defun aicad:normalize-path (path)
  (if path
    (vl-string-translate "/" "\\" path)
    ""
  )
)

(defun aicad:not-empty-p (value)
  (and value (/= value ""))
)

(defun aicad:file-exists-p (path / normalized file)
  (setq normalized (aicad:normalize-path path))
  (if (aicad:not-empty-p normalized)
    (progn
      (setq file (open normalized "r"))
      (if file
        (progn
          (close file)
          T
        )
        nil
      )
    )
    nil
  )
)

(defun aicad:combine-path (base name / clean-base)
  (setq clean-base (vl-string-right-trim "\\/" (aicad:normalize-path base)))
  (if (= clean-base "")
    ""
    (strcat clean-base "\\" name)
  )
)

(defun aicad:directory-has-runtime-p (directory)
  (or
    (aicad:file-exists-p (aicad:combine-path directory "aicad_bridge.ps1"))
    (aicad:file-exists-p (aicad:combine-path directory "aicad_launch.vbs"))
  )
)

(defun aicad:directory-for-found-file (file-name / found-path)
  (if (setq found-path (findfile file-name))
    (vl-filename-directory (aicad:normalize-path found-path))
    ""
  )
)

(defun aicad:remember-base-directory (directory / normalized)
  (setq normalized (aicad:normalize-path directory))
  (if (aicad:directory-has-runtime-p normalized)
    (progn
      (setq *AICAD_BaseDirectory* normalized)
      (setenv *AICAD_BaseDirectoryEnvVar* normalized)
      normalized
    )
    ""
  )
)

(defun aicad:resolve-base-directory (/ candidate resolved)
  (setq resolved "")
  (foreach candidate
    (list
      *AICAD_DefaultInstallDirectory*
      (if (and (boundp '*AICAD_BaseDirectory*)
               (aicad:not-empty-p *AICAD_BaseDirectory*))
        *AICAD_BaseDirectory*
        ""
      )
      (getenv *AICAD_BaseDirectoryEnvVar*)
      (aicad:directory-for-found-file "aicad_bridge.ps1")
      (aicad:directory-for-found-file "aicad_launch.vbs")
    )
    (if (and (= resolved "") (aicad:directory-has-runtime-p candidate))
      (setq resolved (aicad:normalize-path candidate))
    )
  )
  (if (= resolved "")
    (setq resolved (aicad:normalize-path (strcat (getenv "USERPROFILE") "\\Desktop")))
  )
  (if (= (aicad:remember-base-directory resolved) "")
    resolved
    *AICAD_BaseDirectory*
  )
)

(setq *AICAD_BaseDirectory* (aicad:resolve-base-directory))
(setq *AICAD_BridgeScriptPath* (aicad:combine-path *AICAD_BaseDirectory* "aicad_bridge.ps1"))
(setq *AICAD_LauncherScriptPath* (aicad:combine-path *AICAD_BaseDirectory* "aicad_launch.vbs"))
(setq *AICAD_Model* "gpt-4.1-mini")
(setq *AICAD_TimeoutSeconds* 30)
(setq *AICAD_PollMilliseconds* 250)
(setq *AICAD_RequireConfirmation* nil)
(setq *AICAD_RibbonReplaceSearchVar* "AICAD_RIBBON_REPLACE_SEARCH")
(setq *AICAD_RibbonReplaceValueVar* "AICAD_RIBBON_REPLACE_VALUE")
(setq *AICAD_RibbonReplaceCountVar* "AICAD_RIBBON_REPLACE_COUNT")
(setq *AICAD_RibbonReplaceSearchPrefix* "AICAD_RIBBON_REPLACE_SEARCH_")
(setq *AICAD_RibbonReplaceValuePrefix* "AICAD_RIBBON_REPLACE_VALUE_")
(setq *AICAD_RibbonFindSearchVar* "AICAD_RIBBON_FIND_SEARCH")
(setq *AICAD_RibbonFindHandleVar* "AICAD_RIBBON_FIND_HANDLE")
(setq *AICAD_LastFindSearchText* "")
(setq *AICAD_LastFindSignature* "")
(setq *AICAD_LastFindHandle* "")
(setq *AICAD_LastFindHighlighted* nil)
(setq *AICAD_ReactorList* nil)
(setq *AICAD_EnvStack* nil)
(setq *AICAD_SystemVariablesToRestore*
  '("CMDECHO" "OSMODE" "PICKFIRST" "FILEDIA" "CMDDIA")
)

(defun aicad:error-message (err)
  (cond
    ((vl-catch-all-error-p err) (vl-catch-all-error-message err))
    ((= (type err) 'STR) err)
    (T "")
  )
)

(defun aicad:cancel-message-p (message / text)
  (setq text (strcase (vl-string-trim " \t\r\n" (if message message ""))))
  (or
    (wcmatch text "*CANCEL*")
    (wcmatch text "*QUIT*")
    (wcmatch text "*BREAK*")
    (wcmatch text "*INTERRUPT*")
    (wcmatch text "*中断*")
    (wcmatch text "*取消*")
  )
)

(defun aicad:save-system-variables (/ saved name value)
  (setq saved '())
  (foreach name *AICAD_SystemVariablesToRestore*
    (setq value (vl-catch-all-apply 'getvar (list name)))
    (if (not (vl-catch-all-error-p value))
      (setq saved (cons (cons name value) saved))
    )
  )
  saved
)

(defun aicad:restore-system-variables (saved / item)
  (foreach item saved
    (vl-catch-all-apply 'setvar (list (car item) (cdr item)))
  )
)

(defun aicad:push-environment ()
  (setq *AICAD_EnvStack*
    (cons (aicad:save-system-variables) *AICAD_EnvStack*)
  )
)

(defun aicad:pop-environment (/ saved)
  (if *AICAD_EnvStack*
    (progn
      (setq saved (car *AICAD_EnvStack*))
      (setq *AICAD_EnvStack* (cdr *AICAD_EnvStack*))
      (aicad:restore-system-variables saved)
    )
  )
)

(defun aicad:restore-all-environments ()
  (while *AICAD_EnvStack*
    (aicad:pop-environment)
  )
)

(defun aicad:print-error (context message)
  (if (aicad:cancel-message-p message)
    (princ (strcat "\nAICAD cancelled in " context ". Environment restored."))
    (princ (strcat "\nAICAD error in " context ": " message))
  )
)

(defun aicad:safe-apply (context fn args / result message)
  (aicad:push-environment)
  (setq result (vl-catch-all-apply fn args))
  (aicad:pop-environment)
  (if (vl-catch-all-error-p result)
    (progn
      (setq message (aicad:error-message result))
      (aicad:print-error context message)
      nil
    )
    result
  )
)

(defun aicad:register-reactor (reactor)
  (if reactor
    (setq *AICAD_ReactorList* (cons reactor *AICAD_ReactorList*))
  )
  reactor
)

(defun aicad:remove-reactors (/ reactor)
  (foreach reactor *AICAD_ReactorList*
    (if reactor
      (vl-catch-all-apply 'vlr-remove (list reactor))
    )
  )
  (setq *AICAD_ReactorList* nil)
)

(defun aicad:unload (/)
  (aicad:remove-reactors)
  (aicad:restore-all-environments)
  (setenv "AICAD_RIBBON_INPUT" "")
  (setenv *AICAD_RibbonReplaceSearchVar* "")
  (setenv *AICAD_RibbonReplaceValueVar* "")
  (setenv *AICAD_RibbonReplaceCountVar* "")
  (setenv *AICAD_RibbonFindSearchVar* "")
  (setenv *AICAD_RibbonFindHandleVar* "")
  (princ "\nAICAD unloaded: reactors removed and environment restored.")
)

(defun *error* (message)
  (aicad:restore-all-environments)
  (aicad:print-error "global handler" message)
  (princ)
)

(defun aicad:escape-json (text / idx ch out)
  (setq idx 1
        out "")
  (while (<= idx (strlen text))
    (setq ch (substr text idx 1))
    (cond
      ((= ch "\\") (setq out (strcat out "\\\\")))
      ((= ch "\"") (setq out (strcat out "\\\"")))
      ((= (ascii ch) 9) (setq out (strcat out " ")))
      ((= (ascii ch) 10) (setq out (strcat out " ")))
      ((= (ascii ch) 13) (setq out (strcat out " ")))
      (T (setq out (strcat out ch)))
    )
    (setq idx (1+ idx))
  )
  out
)

(defun aicad:trim (text)
  (if text
    (vl-string-trim " \t\r\n" text)
    ""
  )
)

(defun aicad:write-text-file (path content / file)
  (if (setq file (open path "w"))
    (progn
      (write-line content file)
      (close file)
      T
    )
    nil
  )
)

(defun aicad:read-kv-file (path / file line pos key value pairs)
  (setq pairs '())
  (if (setq file (open path "r"))
    (progn
      (while (setq line (read-line file))
        (if (setq pos (vl-string-search "=" line))
          (progn
            (setq key (strcase (substr line 1 pos)))
            (setq value (substr line (+ pos 2)))
            (setq pairs (cons (cons key value) pairs))
          )
        )
      )
      (close file)
    )
  )
  (reverse pairs)
)

(defun aicad:kv-get (pairs key / item)
  (if (setq item (assoc (strcase key) pairs))
    (cdr item)
    ""
  )
)

(defun aicad:assoc-inc (key alist / item)
  (if (setq item (assoc key alist))
    (subst (cons key (1+ (cdr item))) item alist)
    (cons (cons key 1) alist)
  )
)

(defun aicad:join (items sep / result)
  (if items
    (progn
      (setq result (car items))
      (foreach item (cdr items)
        (setq result (strcat result sep item))
      )
      result
    )
    ""
  )
)

(defun aicad:nonempty-search-p (text)
  ;; True when TEXT is a usable search operand.
  ;; Empty string is invalid; pure spaces/tabs/full-width spaces are valid.
  (and text (/= text ""))
)

(defun aicad:replace-pairs-from-result (result / replace-count i search-text replace-text pairs)
  (setq pairs '())
  (setq replace-count (atoi (aicad:kv-get result "REPLACE_COUNT")))
  (if (> replace-count 0)
    (progn
      (setq i 1)
      (while (<= i replace-count)
        (setq search-text (aicad:kv-get result (strcat "REPLACE_PAIR_" (itoa i) "_SEARCH")))
        (setq replace-text (aicad:kv-get result (strcat "REPLACE_PAIR_" (itoa i) "_REPLACE")))
        ;; Allow pure-whitespace search; empty replace means delete matched text.
        (if (aicad:nonempty-search-p search-text)
          (setq pairs (append pairs (list (list search-text (if replace-text replace-text "")))))
        )
        (setq i (1+ i))
      )
    )
  )
  (if (not pairs)
    (progn
      (setq search-text (aicad:kv-get result "SEARCH_TEXT"))
      (setq replace-text (aicad:kv-get result "REPLACE_TEXT"))
      (if (aicad:nonempty-search-p search-text)
        (setq pairs (list (list search-text (if replace-text replace-text ""))))
      )
    )
  )
  pairs
)

(defun aicad:replace-pairs-preview (pairs / items)
  (setq items '())
  (foreach pair pairs
    (setq items (cons (strcat (car pair) "->" (cadr pair)) items))
  )
  (aicad:join (reverse items) "; ")
)

(defun aicad:legacy-toolbar-name-p (name / normalized)
  (setq normalized (strcase (aicad:trim name)))
  (or
    (wcmatch normalized "AA*")
    (wcmatch normalized "*AICAD*")
  )
)

(defun aicad:safe-toolbar-name (toolbar / result)
  (setq result (vl-catch-all-apply 'vla-get-name (list toolbar)))
  (if (vl-catch-all-error-p result)
    ""
    result
  )
)

(defun aicad:hide-toolbar-by-command (toolbar-name / result)
  (setq result
    (vl-catch-all-apply
      'vl-cmdf
      (list "_.-TOOLBAR" toolbar-name "_Hide")
    )
  )
  (not (vl-catch-all-error-p result))
)

(defun aicad:delete-legacy-toolbars (/ acad menu-groups group toolbars toolbar toolbar-name toolbar-names toolbar-object result removed-count hidden-count)
  (setq removed-count 0
        hidden-count 0)
  (setq acad (vlax-get-acad-object))
  (setq menu-groups (vl-catch-all-apply 'vla-get-MenuGroups (list acad)))
  (if (not (vl-catch-all-error-p menu-groups))
    (vlax-for group menu-groups
      (setq toolbars (vl-catch-all-apply 'vla-get-Toolbars (list group)))
      (if (not (vl-catch-all-error-p toolbars))
        (progn
          (setq toolbar-names '())
          (vlax-for toolbar toolbars
            (setq toolbar-name (aicad:safe-toolbar-name toolbar))
            (if (aicad:legacy-toolbar-name-p toolbar-name)
              (setq toolbar-names (cons toolbar-name toolbar-names))
            )
          )
          (foreach toolbar-name toolbar-names
            (setq toolbar-object (vl-catch-all-apply 'vla-item (list toolbars toolbar-name)))
            (if (not (vl-catch-all-error-p toolbar-object))
              (progn
                (vl-catch-all-apply 'vla-put-Visible (list toolbar-object :vlax-false))
                (setq result (vl-catch-all-apply 'vla-Delete (list toolbar-object)))
                (if (not (vl-catch-all-error-p result))
                  (setq removed-count (1+ removed-count))
                  (if (aicad:hide-toolbar-by-command toolbar-name)
                    (setq hidden-count (1+ hidden-count))
                  )
                )
              )
              (if (aicad:hide-toolbar-by-command toolbar-name)
                (setq hidden-count (1+ hidden-count))
              )
            )
          )
        )
      )
    )
  )
  (list removed-count hidden-count)
)

(defun aicad:cleanup-legacy-ui (/ counts removed-count hidden-count)
  (setq counts (aicad:delete-legacy-toolbars))
  (setq removed-count (car counts))
  (setq hidden-count (cadr counts))
  (if (> (+ removed-count hidden-count) 0)
    (princ
      (strcat
        "\nLegacy AA toolbar cleanup: removed="
        (itoa removed-count)
        ", hidden="
        (itoa hidden-count)
      )
    )
  )
  counts
)

(defun aicad:selection-summary (ss / counts i ent entdata enttype typeparts total)
  (setq counts '()
        i 0
        total (sslength ss))
  (repeat total
    (setq ent (ssname ss i))
    (setq entdata (entget ent))
    (setq enttype (cdr (assoc 0 entdata)))
    (setq counts (aicad:assoc-inc enttype counts))
    (setq i (1+ i))
  )
  (setq typeparts '())
  (foreach item counts
    (setq typeparts
      (append typeparts
        (list (strcat (car item) ":" (itoa (cdr item))))
      )
    )
  )
  (strcat
    "count="
    (itoa total)
    "; text_only="
    (if (= total (+ (if (assoc "TEXT" counts) (cdr (assoc "TEXT" counts)) 0)
                    (if (assoc "MTEXT" counts) (cdr (assoc "MTEXT" counts)) 0)))
      "true"
      "false"
    )
    "; types="
    (aicad:join typeparts ",")
  )
)

(defun aicad:allowed-commands ()
  (strcat
    "QW|Set the height for selected TEXT or MTEXT objects. "
    "Use only when the user asks to change text height. "
    "Required argument: height > 0."
    "\\n"
    "WI|Set the width factor for selected TEXT or MTEXT objects. "
    "Use only when the user asks to change text width or width factor. "
    "Required argument: width_factor > 0."
    "\\n"
    "Y|Set the color for the selected objects. "
    "Use only when the user explicitly asks to change object color. "
    "For LINE target_type, include LINE, LWPOLYLINE, and POLYLINE objects. "
    "Required argument: color_index as CAD ACI integer."
    "\\n"
    "ZUO|Left align selected TEXT or MTEXT using the left edge of the topmost text object. "
    "No arguments."
    "\\n"
    "YOU|Right align selected TEXT or MTEXT using the right edge of the topmost text object. "
    "No arguments."
    "\\n"
    "SHANG|Top align selected TEXT or MTEXT using the top edge of the leftmost text object. "
    "No arguments."
    "\\n"
    "XIA|Bottom align selected TEXT or MTEXT using the bottom edge of the leftmost text object. "
    "No arguments."
    "\\n"
    "ZHONG|Center align selected TEXT or MTEXT using the visual center of the topmost text object. "
    "No arguments."
    "\\n"
    "HEI|Arrange selected TEXT or MTEXT from top to bottom with left alignment and uniform spacing. "
    "Required argument: spacing > 0. Use spacing 5 when the user does not specify one."
    "\\n"
    "RETXT|Replace text content inside selected TEXT or MTEXT objects. "
    "Required arguments: search_text and replace_text, or ordered replacement pairs. Apply replacements in order."
    "\\n"
    "MOVEOBJ|Move selected objects by a delta vector. "
    "Required arguments: target_type, delta_x, delta_y. target_type is TEXT, LINE, or ALL. "
    "For LINE target_type, include LINE, LWPOLYLINE, and POLYLINE objects."
    "\\n"
    "LINEEDIT|Extend or shorten selected LINE objects from one side by a distance. "
    "Required arguments: side, mode, distance. side is LEFT, RIGHT, UP, or DOWN. mode is EXTEND or SHORTEN."
    "\\n"
    "NONE|Return NONE when the request is not supported by the current whitelist."
  )
)

(defun aicad:make-request-json (user-text ss)
  (strcat
    "{"
    "\"user_text\":\"" (aicad:escape-json user-text) "\","
    "\"selection_summary\":\"" (aicad:escape-json (aicad:selection-summary ss)) "\","
    "\"allowed_commands\":\"" (aicad:escape-json (aicad:allowed-commands)) "\","
    "\"model\":\"" (aicad:escape-json *AICAD_Model*) "\""
    "}"
  )
)

(defun aicad:sleep-millis (milliseconds / remaining chunk result start elapsed)
  (setq remaining milliseconds)
  (while (> remaining 0)
    (setq chunk (if (> remaining 100) 100 remaining))
    (setq result (vl-catch-all-apply 'vl-cmdf (list "_.DELAY" chunk)))
    (if (vl-catch-all-error-p result)
      (progn
        (setq start (getvar "DATE"))
        (setq elapsed 0.0)
        (while (< elapsed chunk)
          (setq elapsed (* (- (getvar "DATE") start) 86400000.0))
        )
      )
    )
    (setq remaining (- remaining chunk))
  )
)

(defun aicad:wait-for-file (path / start elapsed)
  (setq start (getvar "DATE"))
  (while
    (and
      (not (aicad:file-exists-p path))
      (< (* (- (getvar "DATE") start) 86400.0) *AICAD_TimeoutSeconds*)
    )
    (aicad:sleep-millis *AICAD_PollMilliseconds*)
  )
  (aicad:file-exists-p path)
)

(defun aicad:resolve-bridge-path (/ search-path)
  (cond
    ((aicad:file-exists-p *AICAD_BridgeScriptPath*) *AICAD_BridgeScriptPath*)
    ((setq search-path (findfile "aicad_bridge.ps1")) search-path)
    (T nil)
  )
)

(defun aicad:resolve-launcher-path (/ search-path)
  (cond
    ((aicad:file-exists-p *AICAD_LauncherScriptPath*) *AICAD_LauncherScriptPath*)
    ((setq search-path (findfile "aicad_launch.vbs")) search-path)
    (T nil)
  )
)

(defun aicad:call-bridge (user-text ss / bridge launcher req-path rsp-path args result)
  (setq bridge (aicad:resolve-bridge-path))
  (setq launcher (aicad:resolve-launcher-path))
  (cond
    ((not bridge)
     (list
       (cons "STATUS" "ERROR")
       (cons "MESSAGE" "Bridge script not found. Update *AICAD_BridgeScriptPath* or put aicad_bridge.ps1 on the ZWCAD support path.")
      )
    )
    ((not launcher)
     (list
       (cons "STATUS" "ERROR")
       (cons "MESSAGE" "Launcher script not found. Update *AICAD_LauncherScriptPath* or put aicad_launch.vbs on the ZWCAD support path.")
      )
    )
    (T
     (setq req-path (vl-filename-mktemp "aicad_request_" (getenv "TEMP") ".json"))
     (setq rsp-path (vl-filename-mktemp "aicad_response_" (getenv "TEMP") ".txt"))
     (aicad:write-text-file req-path (aicad:make-request-json user-text ss))
     (if (aicad:file-exists-p rsp-path)
       (vl-file-delete rsp-path)
     )
     (setq args
       (strcat
         "\""
         launcher
         "\" \""
         bridge
         "\" \""
         req-path
         "\" \""
         rsp-path
         "\""
       )
     )
     (startapp "wscript.exe" args)
     (if (aicad:wait-for-file rsp-path)
       (setq result (aicad:read-kv-file rsp-path))
       (setq result
         (list
           (cons "STATUS" "ERROR")
           (cons "MESSAGE" "Timed out waiting for AI response.")
         )
       )
     )
     (if (aicad:file-exists-p req-path) (vl-file-delete req-path))
     (if (aicad:file-exists-p rsp-path) (vl-file-delete rsp-path))
     result
    )
  )
)

(defun aicad:set-dxf (edata code value)
  (if (assoc code edata)
    (subst (cons code value) (assoc code edata) edata)
    (append edata (list (cons code value)))
  )
)

(defun aicad:filter-selection (ss mode / filtered i ename enttype)
  (setq filtered (ssadd)
        i 0)
  (repeat (sslength ss)
    (setq ename (ssname ss i))
    (setq enttype (cdr (assoc 0 (entget ename))))
    (cond
      ((= mode "ALL")
       (ssadd ename filtered)
      )
      ((= mode "TEXT")
       (if (member enttype '("TEXT" "MTEXT"))
         (ssadd ename filtered)
       )
      )
      ((= mode "LINE")
       (if (member enttype '("LINE" "LWPOLYLINE" "POLYLINE"))
         (ssadd ename filtered)
       )
      )
      ((= mode "STRAIGHTLINE")
       (if (= enttype "LINE")
         (ssadd ename filtered)
       )
      )
    )
    (setq i (1+ i))
  )
  filtered
)

(defun aicad:selection-count (ss)
  (if ss (sslength ss) 0)
)

(defun aicad:get-entity-handle (ename / edata)
  (setq edata (entget ename))
  (if edata
    (cdr (assoc 5 edata))
    ""
  )
)

(defun aicad:get-entity-text (ename / edata obj text)
  (setq text "")
  (if ename
    (progn
      (setq edata (entget ename))
      (if edata
        (setq text (cdr (assoc 1 edata)))
      )
      (if (or (not text) (= text ""))
        (progn
          (setq obj (vl-catch-all-apply 'vlax-ename->vla-object (list ename)))
          (if (not (vl-catch-all-error-p obj))
            (setq text (vl-catch-all-apply 'vla-get-TextString (list obj)))
          )
          (if (vl-catch-all-error-p text)
            (setq text "")
          )
        )
      )
    )
  )
  (if text text "")
)

(defun aicad:text-contains-p (text search-text)
  (and text
       (/= search-text "")
       (numberp (vl-string-search search-text text)))
)

(defun aicad:matching-text-entities (ss search-text / i ename text matches)
  (setq i 0
        matches '())
  (repeat (sslength ss)
    (setq ename (ssname ss i))
    (setq text (aicad:get-entity-text ename))
    (if (aicad:text-contains-p text search-text)
      (setq matches (cons ename matches))
    )
    (setq i (1+ i))
  )
  (reverse matches)
)

(defun aicad:index-of (items value / idx found)
  (setq idx 0
        found nil)
  (while (and items (null found))
    (if (equal (car items) value)
      (setq found idx)
      (progn
        (setq items (cdr items))
        (setq idx (1+ idx))
      )
    )
  )
  found
)

(defun aicad:reset-find-state ()
  (setq *AICAD_LastFindSearchText* ""
        *AICAD_LastFindSignature* ""
        *AICAD_LastFindHandle* "")
)

(defun aicad:clear-last-find-highlight ()
  (if (and *AICAD_LastFindHighlighted*
           (entget *AICAD_LastFindHighlighted*))
    (redraw *AICAD_LastFindHighlighted* 4)
  )
  (setq *AICAD_LastFindHighlighted* nil)
)

(defun aicad:zoom-to-entity-window (ename / bbox min-pt max-pt dx dy pad-x pad-y p1 p2 result)
  (setq bbox (aicad:get-bbox-lists ename))
  (setq min-pt (car bbox))
  (setq max-pt (cadr bbox))
  (if (and min-pt max-pt)
    (progn
      (setq dx (abs (- (car max-pt) (car min-pt))))
      (setq dy (abs (- (cadr max-pt) (cadr min-pt))))
      (setq pad-x (max 1.0 (* (max dx 1.0) 1.5)))
      (setq pad-y (max 1.0 (* (max dy 1.0) 1.5)))
      (setq p1 (list (- (car min-pt) pad-x) (- (cadr min-pt) pad-y)))
      (setq p2 (list (+ (car max-pt) pad-x) (+ (cadr max-pt) pad-y)))
      (setq result (vl-catch-all-apply 'vl-cmdf (list "_.ZOOM" "_W" p1 p2)))
      (not (vl-catch-all-error-p result))
    )
    nil
  )
)

(defun aicad:zoom-to-entity (ename / result)
  (setq result (vl-catch-all-apply 'vl-cmdf (list "_.ZOOM" "_OBJECT" ename "")))
  (if (vl-catch-all-error-p result)
    (aicad:zoom-to-entity-window ename)
    T
  )
)

(defun aicad:pick-find-match (matches search-text / handles signature current-index next-index)
  (setq handles (mapcar 'aicad:get-entity-handle matches))
  (setq signature (aicad:join handles "|"))
  (if (and (= search-text *AICAD_LastFindSearchText*)
           (= signature *AICAD_LastFindSignature*))
    (progn
      (setq current-index (aicad:index-of handles *AICAD_LastFindHandle*))
      (if current-index
        (setq next-index (rem (1+ current-index) (length matches)))
        (setq next-index 0)
      )
    )
    (setq next-index 0)
  )
  (setq *AICAD_LastFindSearchText* search-text)
  (setq *AICAD_LastFindSignature* signature)
  (setq *AICAD_LastFindHandle* (nth next-index handles))
  (list (nth next-index matches) (1+ next-index) (length matches))
)

(defun aicad:focus-find-match (ename)
  (aicad:clear-last-find-highlight)
  (if (entget ename)
    (progn
      (aicad:zoom-to-entity ename)
      (redraw ename 3)
      (setq *AICAD_LastFindHandle* (aicad:get-entity-handle ename))
      (setq *AICAD_LastFindHighlighted* ename)
      T
    )
    nil
  )
)

(defun aicad:run-ribbon-find-focus (handle / ename)
  (cond
    ((= (aicad:trim handle) "")
     (princ "\nFind result handle is empty.")
    )
    ((not (setq ename (handent handle)))
     (aicad:clear-last-find-highlight)
     (princ "\nThe selected find result no longer exists.")
    )
    ((aicad:focus-find-match ename)
     (princ "\nJumped to selected find result.")
    )
    (T
     (princ "\nFailed to jump to selected find result.")
    )
  )
)

(defun aicad:get-bbox-lists (ename / obj min-pt max-pt)
  (setq obj (vlax-ename->vla-object ename))
  (vla-getboundingbox obj 'min-pt 'max-pt)
  (list (vlax-safearray->list min-pt) (vlax-safearray->list max-pt))
)

(defun aicad:get-top-entity (ss / i ename bbox max-pt top-entity top-y)
  (setq i 0
        top-entity nil
        top-y nil)
  (repeat (sslength ss)
    (setq ename (ssname ss i))
    (setq bbox (aicad:get-bbox-lists ename))
    (setq max-pt (cadr bbox))
    (if (or (null top-y) (> (cadr max-pt) top-y))
      (progn
        (setq top-y (cadr max-pt))
        (setq top-entity ename)
      )
    )
    (setq i (1+ i))
  )
  top-entity
)

(defun aicad:get-leftmost-reference (ss / i ename bbox min-pt ref-min-x ref-y)
  (setq i 0
        ref-min-x nil
        ref-y nil)
  (repeat (sslength ss)
    (setq ename (ssname ss i))
    (setq bbox (aicad:get-bbox-lists ename))
    (setq min-pt (car bbox))
    (if (or (null ref-min-x) (< (car min-pt) ref-min-x))
      (progn
        (setq ref-min-x (car min-pt))
        (setq ref-y (cadr min-pt))
      )
    )
    (setq i (1+ i))
  )
  (list ref-min-x ref-y)
)

(defun aicad:get-leftmost-top-reference (ss / i ename bbox min-pt max-pt ref-min-x ref-top-y)
  (setq i 0
        ref-min-x nil
        ref-top-y nil)
  (repeat (sslength ss)
    (setq ename (ssname ss i))
    (setq bbox (aicad:get-bbox-lists ename))
    (setq min-pt (car bbox))
    (setq max-pt (cadr bbox))
    (if (or (null ref-min-x) (< (car min-pt) ref-min-x))
      (progn
        (setq ref-min-x (car min-pt))
        (setq ref-top-y (cadr max-pt))
      )
    )
    (setq i (1+ i))
  )
  (list ref-min-x ref-top-y)
)

(defun aicad:apply-color (ss color-index / i ename count)
  (setq i 0
        count 0)
  (repeat (sslength ss)
    (setq ename (ssname ss i))
    (vla-put-Color (vlax-ename->vla-object ename) color-index)
    (setq count (1+ count))
    (setq i (1+ i))
  )
  count
)

(defun aicad:apply-zuo (ss / top-entity top-bbox base-x i ename bbox max-pt edata objtype ins-z new-point)
  (setq top-entity (aicad:get-top-entity ss))
  (if (not top-entity)
    0
    (progn
      (setq top-bbox (aicad:get-bbox-lists top-entity))
      (setq base-x (car (car top-bbox)))
      (vla-startundomark (vla-get-activedocument (vlax-get-acad-object)))
      (setq i 0)
      (repeat (sslength ss)
        (setq ename (ssname ss i))
        (setq bbox (aicad:get-bbox-lists ename))
        (setq max-pt (cadr bbox))
        (setq edata (entget ename))
        (setq objtype (cdr (assoc 0 edata)))
        (setq ins-z (caddr (cdr (assoc 10 edata))))
        (setq new-point (list base-x (cadr max-pt) ins-z))
        (cond
          ((= objtype "TEXT")
           (setq edata (aicad:set-dxf edata 72 0))
           (setq edata (aicad:set-dxf edata 73 3))
           (setq edata (aicad:set-dxf edata 10 new-point))
           (if (assoc 11 edata)
             (setq edata (aicad:set-dxf edata 11 new-point))
           )
          )
          ((= objtype "MTEXT")
           (setq edata (aicad:set-dxf edata 71 1))
           (setq edata (aicad:set-dxf edata 10 new-point))
          )
        )
        (entmod edata)
        (entupd ename)
        (setq i (1+ i))
      )
      (vla-endundomark (vla-get-activedocument (vlax-get-acad-object)))
      (sslength ss)
    )
  )
)

(defun aicad:apply-you (ss / top-entity top-bbox base-x i ename bbox max-pt edata objtype ins-z new-point)
  (setq top-entity (aicad:get-top-entity ss))
  (if (not top-entity)
    0
    (progn
      (setq top-bbox (aicad:get-bbox-lists top-entity))
      (setq base-x (car (cadr top-bbox)))
      (vla-startundomark (vla-get-activedocument (vlax-get-acad-object)))
      (setq i 0)
      (repeat (sslength ss)
        (setq ename (ssname ss i))
        (setq bbox (aicad:get-bbox-lists ename))
        (setq max-pt (cadr bbox))
        (setq edata (entget ename))
        (setq objtype (cdr (assoc 0 edata)))
        (setq ins-z (caddr (cdr (assoc 10 edata))))
        (setq new-point (list base-x (cadr max-pt) ins-z))
        (cond
          ((= objtype "TEXT")
           (setq edata (aicad:set-dxf edata 72 2))
           (setq edata (aicad:set-dxf edata 73 3))
           (setq edata (aicad:set-dxf edata 10 new-point))
           (if (assoc 11 edata)
             (setq edata (aicad:set-dxf edata 11 new-point))
           )
          )
          ((= objtype "MTEXT")
           (setq edata (aicad:set-dxf edata 71 3))
           (setq edata (aicad:set-dxf edata 10 new-point))
          )
        )
        (entmod edata)
        (entupd ename)
        (setq i (1+ i))
      )
      (vla-endundomark (vla-get-activedocument (vlax-get-acad-object)))
      (sslength ss)
    )
  )
)

(defun aicad:justify-text-selection (ss justify-code / old-cmdecho result)
  (setq old-cmdecho (vl-catch-all-apply 'getvar (list "CMDECHO")))
  (setvar "CMDECHO" 0)
  (setq result (vl-catch-all-apply 'vl-cmdf (list "_.JUSTIFYTEXT" ss "" justify-code)))
  (if (not (vl-catch-all-error-p old-cmdecho))
    (setvar "CMDECHO" old-cmdecho)
  )
  (if (vl-catch-all-error-p result)
    (progn
      (aicad:print-error "JUSTIFYTEXT" (aicad:error-message result))
      nil
    )
    T
  )
)

(defun aicad:apply-shang (ss / ref-data ref-top-y i ename edata objtype pt z-val new-pt)
  (setq ref-data (aicad:get-leftmost-top-reference ss))
  (setq ref-top-y (cadr ref-data))
  (vla-startundomark (vla-get-activedocument (vlax-get-acad-object)))
  (aicad:justify-text-selection ss "TR")
  (setq i 0)
  (repeat (sslength ss)
    (setq ename (ssname ss i))
    (setq edata (entget ename))
    (setq objtype (cdr (assoc 0 edata)))
    (cond
      ((= objtype "MTEXT")
       (setq pt (cdr (assoc 10 edata)))
       (setq z-val (caddr pt))
       (setq new-pt (list (car pt) ref-top-y z-val))
       (setq edata (aicad:set-dxf edata 10 new-pt))
      )
      ((= objtype "TEXT")
       (setq pt (cdr (assoc 11 edata)))
       (setq z-val (caddr pt))
       (setq new-pt (list (car pt) ref-top-y z-val))
       (setq edata (aicad:set-dxf edata 11 new-pt))
      )
    )
    (entmod edata)
    (entupd ename)
    (setq i (1+ i))
  )
  (vla-endundomark (vla-get-activedocument (vlax-get-acad-object)))
  (sslength ss)
)

(defun aicad:apply-xia (ss / ref-data ref-bottom-y i ename edata objtype pt z-val new-pt)
  (setq ref-data (aicad:get-leftmost-reference ss))
  (setq ref-bottom-y (cadr ref-data))
  (vla-startundomark (vla-get-activedocument (vlax-get-acad-object)))
  (aicad:justify-text-selection ss "BL")
  (setq i 0)
  (repeat (sslength ss)
    (setq ename (ssname ss i))
    (setq edata (entget ename))
    (setq objtype (cdr (assoc 0 edata)))
    (cond
      ((= objtype "MTEXT")
       (setq pt (cdr (assoc 10 edata)))
       (setq z-val (caddr pt))
       (setq new-pt (list (car pt) ref-bottom-y z-val))
       (setq edata (aicad:set-dxf edata 10 new-pt))
      )
      ((= objtype "TEXT")
       (setq pt (cdr (assoc 11 edata)))
       (setq z-val (caddr pt))
       (setq new-pt (list (car pt) ref-bottom-y z-val))
       (setq edata (aicad:set-dxf edata 11 new-pt))
      )
    )
    (entmod edata)
    (entupd ename)
    (setq i (1+ i))
  )
  (vla-endundomark (vla-get-activedocument (vlax-get-acad-object)))
  (sslength ss)
)

(defun aicad:apply-zhong (ss / top-entity top-bbox base-x i ename bbox min-pt max-pt center-y edata objtype ins-z new-point)
  (setq top-entity (aicad:get-top-entity ss))
  (if (not top-entity)
    0
    (progn
      (setq top-bbox (aicad:get-bbox-lists top-entity))
      (setq base-x (/ (+ (car (car top-bbox)) (car (cadr top-bbox))) 2.0))
      (vla-startundomark (vla-get-activedocument (vlax-get-acad-object)))
      (setq i 0)
      (repeat (sslength ss)
        (setq ename (ssname ss i))
        (setq bbox (aicad:get-bbox-lists ename))
        (setq min-pt (car bbox))
        (setq max-pt (cadr bbox))
        (setq center-y (/ (+ (cadr min-pt) (cadr max-pt)) 2.0))
        (setq edata (entget ename))
        (setq objtype (cdr (assoc 0 edata)))
        (setq ins-z (caddr (cdr (assoc 10 edata))))
        (setq new-point (list base-x center-y ins-z))
        (cond
          ((= objtype "TEXT")
           (setq edata (aicad:set-dxf edata 72 1))
           (setq edata (aicad:set-dxf edata 73 2))
           (setq edata (aicad:set-dxf edata 10 new-point))
           (setq edata (aicad:set-dxf edata 11 new-point))
          )
          ((= objtype "MTEXT")
           (setq edata (aicad:set-dxf edata 71 5))
           (setq edata (aicad:set-dxf edata 10 new-point))
          )
        )
        (entmod edata)
        (entupd ename)
        (setq i (1+ i))
      )
      (vla-endundomark (vla-get-activedocument (vlax-get-acad-object)))
      (sslength ss)
    )
  )
)

(defun aicad:align-left-top (edata objtype)
  (cond
    ((= objtype "TEXT")
     (setq edata (aicad:set-dxf edata 72 0))
     (setq edata (aicad:set-dxf edata 73 0))
     (if (assoc 11 edata)
       (setq edata (vl-remove (assoc 11 edata) edata))
     )
    )
    ((= objtype "MTEXT")
     (setq edata (aicad:set-dxf edata 71 1))
    )
  )
  edata
)

(defun aicad:text-info-y-desc-p (a b)
  (> (car a) (car b))
)

(defun aicad:apply-hei (ss spacing / text-list count ent ent-data objtype modified-data insertion-point x y text-content sorted-list base-x max-y current-y text-info new-point)
  (setq text-list '()
        count 0
        base-x nil
        max-y nil)
  (repeat (sslength ss)
    (setq ent (ssname ss count))
    (setq ent-data (entget ent))
    (setq objtype (cdr (assoc 0 ent-data)))
    (setq modified-data (aicad:align-left-top ent-data objtype))
    (entmod modified-data)
    (entupd ent)
    (setq ent-data (entget ent))
    (setq insertion-point (cdr (assoc 10 ent-data)))
    (setq x (car insertion-point))
    (setq y (cadr insertion-point))
    (setq text-content (cdr (assoc 1 ent-data)))
    (setq text-list (cons (list y x text-content ent) text-list))
    (if (or (not base-x) (< x base-x))
      (setq base-x x)
    )
    (if (or (not max-y) (> y max-y))
      (setq max-y y)
    )
    (setq count (1+ count))
  )
  (if text-list
    (progn
      (setq sorted-list (vl-sort text-list 'aicad:text-info-y-desc-p))
      (setq current-y max-y
            count 0)
      (foreach text-info sorted-list
        (setq ent (cadddr text-info))
        (setq ent-data (entget ent))
        (setq new-point (list base-x current-y (caddr (cdr (assoc 10 ent-data)))))
        (setq ent-data (aicad:set-dxf ent-data 10 new-point))
        (entmod ent-data)
        (entupd ent)
        (setq current-y (- current-y spacing))
        (setq count (1+ count))
      )
    )
  )
  count
)

(defun aicad:string-replace-all (text search-text replace-text / pos start result)
  (if (or (not text) (= search-text ""))
    text
    (progn
      (setq start 0
            result "")
      (while (setq pos (vl-string-search search-text text start))
        (setq result
          (strcat
            result
            (substr text (1+ start) (- pos start))
            replace-text
          )
        )
        (setq start (+ pos (strlen search-text)))
      )
      (strcat result (substr text (1+ start)))
    )
  )
)

(defun aicad:apply-text-replacements (ss replace-pairs / i ent ent-data text-content new-text count pair)
  (setq i 0
        count 0)
  (repeat (sslength ss)
    (setq ent (ssname ss i))
    (setq ent-data (entget ent))
    (setq text-content (cdr (assoc 1 ent-data)))
    (if (and text-content (/= text-content ""))
      (progn
        (setq new-text text-content)
        (foreach pair replace-pairs
          (setq new-text (aicad:string-replace-all new-text (car pair) (cadr pair)))
        )
        (if (/= new-text text-content)
          (progn
            (setq ent-data (aicad:set-dxf ent-data 1 new-text))
            (entmod ent-data)
            (entupd ent)
            (setq count (1+ count))
          )
        )
      )
    )
    (setq i (1+ i))
  )
  count
)

(defun aicad:apply-move (ss delta-x delta-y / i ename obj from-point to-point count)
  (if (> (aicad:selection-count ss) 0)
    (progn
      (setq i 0
            count 0
            from-point (vlax-3d-point '(0.0 0.0 0.0))
            to-point (vlax-3d-point (list delta-x delta-y 0.0)))
      (repeat (sslength ss)
        (setq ename (ssname ss i))
        (setq obj (vlax-ename->vla-object ename))
        (vla-move obj from-point to-point)
        (setq count (1+ count))
        (setq i (1+ i))
      )
      count
    )
    0
  )
)

(defun aicad:line-length (p1 p2)
  (distance p1 p2)
)

(defun aicad:unit-vector (from-point to-point / len)
  (setq len (aicad:line-length from-point to-point))
  (if (> len 1e-9)
    (list
      (/ (- (car to-point) (car from-point)) len)
      (/ (- (cadr to-point) (cadr from-point)) len)
      (/ (- (caddr to-point) (caddr from-point)) len)
    )
    '(0.0 0.0 0.0)
  )
)

(defun aicad:point-add-scaled (point vec scale)
  (list
    (+ (car point) (* (car vec) scale))
    (+ (cadr point) (* (cadr vec) scale))
    (+ (caddr point) (* (caddr vec) scale))
  )
)

(defun aicad:line-side-points (p1 p2 side)
  (cond
    ((= side "LEFT")
     (if (<= (car p1) (car p2)) (list p1 p2) (list p2 p1))
    )
    ((= side "RIGHT")
     (if (>= (car p1) (car p2)) (list p1 p2) (list p2 p1))
    )
    ((= side "UP")
     (if (>= (cadr p1) (cadr p2)) (list p1 p2) (list p2 p1))
    )
    ((= side "DOWN")
     (if (<= (cadr p1) (cadr p2)) (list p1 p2) (list p2 p1))
    )
    (T
     (list p1 p2)
    )
  )
)

(defun aicad:apply-line-edit (ss side mode edit-distance / i ename edata p1 p2 chosen other dir new-point count len)
  (setq i 0
        count 0)
  (repeat (sslength ss)
    (setq ename (ssname ss i))
    (setq edata (entget ename))
    (setq p1 (cdr (assoc 10 edata)))
    (setq p2 (cdr (assoc 11 edata)))
    (if (and p1 p2)
      (progn
        (setq len (aicad:line-length p1 p2))
        (if (> len 1e-9)
          (progn
            (setq chosen (car (aicad:line-side-points p1 p2 side)))
            (setq other (cadr (aicad:line-side-points p1 p2 side)))
            (cond
              ((= mode "EXTEND")
               (setq dir (aicad:unit-vector other chosen))
               (setq new-point (aicad:point-add-scaled chosen dir edit-distance))
              )
              ((and (= mode "SHORTEN") (< edit-distance len))
               (setq dir (aicad:unit-vector chosen other))
               (setq new-point (aicad:point-add-scaled chosen dir edit-distance))
              )
            )
            (if new-point
              (progn
                (if (equal chosen p1 1e-9)
                  (setq edata (aicad:set-dxf edata 10 new-point))
                  (setq edata (aicad:set-dxf edata 11 new-point))
                )
                (entmod edata)
                (entupd ename)
                (setq count (1+ count))
              )
            )
          )
        )
      )
    )
    (setq i (1+ i))
    (setq new-point nil)
  )
  count
)

(defun aicad:apply-text-height (ss height / i ent edata count)
  (setq i 0
        count 0)
  (repeat (sslength ss)
    (setq ent (ssname ss i))
    (setq edata (entget ent))
    (setq edata (aicad:set-dxf edata 40 height))
    (entmod edata)
    (entupd ent)
    (setq count (1+ count))
    (setq i (1+ i))
  )
  count
)

(defun aicad:apply-text-width (ss width-factor / i ent edata count)
  (setq i 0
        count 0)
  (repeat (sslength ss)
    (setq ent (ssname ss i))
    (setq edata (entget ent))
    (setq edata (aicad:set-dxf edata 41 width-factor))
    (entmod edata)
    (entupd ent)
    (setq count (1+ count))
    (setq i (1+ i))
  )
  count
)

(defun aicad:execution-preview (result / command height width-factor message preview search-text replace-text side mode line-distance replace-pairs)
  (setq command (strcase (aicad:kv-get result "TARGET_COMMAND")))
  (setq message (aicad:kv-get result "MESSAGE"))
  (setq preview "")
  (cond
    ((= command "QW")
     (setq height (aicad:kv-get result "HEIGHT"))
     (setq preview (strcat "Command=QW, height=" height))
    )
    ((= command "WI")
     (setq width-factor (aicad:kv-get result "WIDTH_FACTOR"))
     (setq preview (strcat "Command=WI, width_factor=" width-factor))
    )
    ((= command "Y")
     (setq preview
       (strcat
         "Command=Y, target_type=" (aicad:kv-get result "TARGET_TYPE")
         ", color_index=" (aicad:kv-get result "COLOR_INDEX")
       )
     )
    )
    ((= command "HEI")
     (setq preview (strcat "Command=HEI, spacing=" (aicad:kv-get result "SPACING")))
    )
    ((= command "RETXT")
     (setq replace-pairs (aicad:replace-pairs-from-result result))
     (if replace-pairs
       (setq preview (strcat "Command=RETXT, replacements=" (aicad:replace-pairs-preview replace-pairs)))
       (progn
         (setq search-text (aicad:kv-get result "SEARCH_TEXT"))
         (setq replace-text (aicad:kv-get result "REPLACE_TEXT"))
         (setq preview (strcat "Command=RETXT, search_text=" search-text ", replace_text=" replace-text))
       )
     )
    )
    ((= command "MOVEOBJ")
     (setq preview
       (strcat
         "Command=MOVEOBJ, target_type=" (aicad:kv-get result "TARGET_TYPE")
         ", delta_x=" (aicad:kv-get result "DELTA_X")
         ", delta_y=" (aicad:kv-get result "DELTA_Y")
       )
     )
    )
    ((= command "LINEEDIT")
     (setq preview
       (strcat
         "Command=LINEEDIT, mode=" (aicad:kv-get result "MODE")
         ", side=" (aicad:kv-get result "SIDE")
         ", distance=" (aicad:kv-get result "DISTANCE")
       )
     )
    )
    (T
      (setq preview (strcat "Command=" command))
    )
  )
  (if (/= message "")
    (strcat preview " | " message)
    preview
  )
)

(defun aicad:confirm-execution (preview / answer)
  (princ (strcat "\nAI plan: " preview))
  (if *AICAD_RequireConfirmation*
    (progn
      (setq answer (strcase (vl-string-trim " " (getstring T "\nExecute this action? [Yes/No] <No>: "))))
      (or
        (= answer "Y")
        (= answer "YES")
        (= answer "1")
      )
    )
    T
  )
)

(defun aicad:dispatch (result ss / command height width-factor color-index spacing count search-text replace-text replace-pairs target-type delta-x delta-y target-ss side mode line-distance)
  (setq command (strcase (aicad:kv-get result "TARGET_COMMAND")))
  (cond
    ((= command "QW")
     (setq target-ss (aicad:filter-selection ss "TEXT"))
     (setq height (distof (aicad:kv-get result "HEIGHT")))
     (if (and (> (aicad:selection-count target-ss) 0) height (> height 0.0))
       (progn
         (setq count (aicad:apply-text-height target-ss height))
         (strcat "Updated text height for " (itoa count) " object(s).")
       )
       "No matching text objects or invalid height."
     )
    )
    ((= command "WI")
     (setq target-ss (aicad:filter-selection ss "TEXT"))
     (setq width-factor (distof (aicad:kv-get result "WIDTH_FACTOR")))
     (if (and (> (aicad:selection-count target-ss) 0) width-factor (> width-factor 0.0))
       (progn
         (setq count (aicad:apply-text-width target-ss width-factor))
         (strcat "Updated text width factor for " (itoa count) " object(s).")
       )
       "No matching text objects or invalid width factor."
     )
    )
    ((= command "Y")
     (setq target-type (aicad:kv-get result "TARGET_TYPE"))
     (if (= target-type "") (setq target-type "ALL"))
     (setq target-ss (aicad:filter-selection ss target-type))
     (setq color-index (atoi (aicad:kv-get result "COLOR_INDEX")))
     (if (and (> (aicad:selection-count target-ss) 0) (> color-index 0))
       (progn
         (setq count (aicad:apply-color target-ss color-index))
         (strcat "Updated color for " (itoa count) " object(s).")
       )
       "No matching objects or invalid color index."
     )
    )
    ((= command "ZUO")
     (setq target-ss (aicad:filter-selection ss "TEXT"))
     (setq count (aicad:apply-zuo target-ss))
     (strcat "Left aligned " (itoa count) " object(s).")
    )
    ((= command "YOU")
     (setq target-ss (aicad:filter-selection ss "TEXT"))
     (setq count (aicad:apply-you target-ss))
     (strcat "Right aligned " (itoa count) " object(s).")
    )
    ((= command "SHANG")
     (setq target-ss (aicad:filter-selection ss "TEXT"))
     (setq count (aicad:apply-shang target-ss))
     (strcat "Top aligned " (itoa count) " object(s).")
    )
    ((= command "XIA")
     (setq target-ss (aicad:filter-selection ss "TEXT"))
     (setq count (aicad:apply-xia target-ss))
     (strcat "Bottom aligned " (itoa count) " object(s).")
    )
    ((= command "ZHONG")
     (setq target-ss (aicad:filter-selection ss "TEXT"))
     (setq count (aicad:apply-zhong target-ss))
     (strcat "Center aligned " (itoa count) " object(s).")
    )
    ((= command "HEI")
     (setq target-ss (aicad:filter-selection ss "TEXT"))
     (setq spacing (distof (aicad:kv-get result "SPACING")))
     (if (and (> (aicad:selection-count target-ss) 0) spacing (> spacing 0.0))
       (progn
         (setq count (aicad:apply-hei target-ss spacing))
         (strcat "Arranged " (itoa count) " object(s) with uniform spacing.")
       )
       "No matching text objects or invalid spacing."
     )
    )
    ((= command "RETXT")
     (setq target-ss (aicad:filter-selection ss "TEXT"))
     (setq replace-pairs (aicad:replace-pairs-from-result result))
     (if (and (> (aicad:selection-count target-ss) 0) replace-pairs)
       (progn
         (setq count (aicad:apply-text-replacements target-ss replace-pairs))
         (strcat "Replaced text in " (itoa count) " object(s).")
       )
       "No matching text objects or invalid text replacement arguments."
     )
    )
    ((= command "MOVEOBJ")
     (setq target-type (aicad:kv-get result "TARGET_TYPE"))
     (if (= target-type "") (setq target-type "ALL"))
     (setq target-ss (aicad:filter-selection ss target-type))
     (setq delta-x (distof (aicad:kv-get result "DELTA_X")))
     (setq delta-y (distof (aicad:kv-get result "DELTA_Y")))
     (if (and (> (aicad:selection-count target-ss) 0) delta-x delta-y)
       (progn
         (setq count (aicad:apply-move target-ss delta-x delta-y))
         (strcat "Moved " (itoa count) " object(s).")
       )
       "No matching objects or invalid move delta."
     )
    )
    ((= command "LINEEDIT")
     (setq target-ss (aicad:filter-selection ss "STRAIGHTLINE"))
     (setq side (aicad:kv-get result "SIDE"))
     (setq mode (aicad:kv-get result "MODE"))
     (setq line-distance (distof (aicad:kv-get result "DISTANCE")))
     (if (and (> (aicad:selection-count target-ss) 0)
              (/= side "")
              (/= mode "")
              line-distance
              (> line-distance 0.0))
       (progn
         (setq count (aicad:apply-line-edit target-ss side mode line-distance))
         (strcat "Edited " (itoa count) " line object(s).")
       )
       "No matching straight lines or invalid line edit arguments."
     )
    )
    ((= command "NONE")
     "The current whitelist does not support this request yet."
    )
    (T
     (strcat "Unsupported command returned by AI: " command)
    )
  )
)

(defun aicad:resolve-selection (/ ss)
  (setq ss (ssget "_I"))
  (if (not ss)
    (setq ss (ssget "_P"))
  )
  (if (not ss)
    (progn
      (princ "\nSelect objects for AI processing.")
      (setq ss (ssget))
    )
  )
  ss
)

(defun aicad:run-request (user-text ss / result status preview)
  (if (not ss)
    (princ "\nNo objects selected.")
    (progn
      (setq user-text (aicad:trim user-text))
      (if (= user-text "")
        (princ "\nNo instruction entered.")
        (progn
          (setq result (aicad:call-bridge user-text ss))
          (setq status (strcase (aicad:kv-get result "STATUS")))
          (cond
            ((= status "OK")
             (setq preview (aicad:execution-preview result))
             (if (aicad:confirm-execution preview)
               (princ (strcat "\n" (aicad:dispatch result ss)))
               (princ "\nExecution cancelled.")
             )
            )
            ((= status "UNSUPPORTED")
             (princ (strcat "\n" (aicad:kv-get result "MESSAGE")))
            )
            (T
             (princ (strcat "\nAI call failed: " (aicad:kv-get result "MESSAGE")))
            )
          )
        )
      )
    )
  )
)

(defun aicad:run-command (user-text / ss)
  (setq ss (aicad:resolve-selection))
  (aicad:run-request user-text ss)
)

(defun aicad:run-ribbon-replacement-pairs (pairs / ss target-ss count)
  (setq ss (aicad:resolve-selection))
  (cond
    ((not ss)
     (princ "\nNo objects selected.")
    )
    ((not pairs)
     (princ "\nRibbon replace source text is empty.")
    )
    (T
     (setq target-ss (aicad:filter-selection ss "TEXT"))
     (if (> (aicad:selection-count target-ss) 0)
       (progn
         (setq count (aicad:apply-text-replacements target-ss pairs))
         (princ (strcat "\nReplaced text in " (itoa count) " object(s) using "
                        (itoa (length pairs)) " replacement group(s)."))
       )
       (princ "\nNo matching text objects selected.")
     )
    )
  )
)

(defun aicad:run-ribbon-replacement (search-text replace-text)
  (aicad:run-ribbon-replacement-pairs
    (if (aicad:nonempty-search-p search-text)
      (list (list search-text (if replace-text replace-text "")))
      nil
    )
  )
)

(defun aicad:run-ribbon-find (search-text / ss target-ss matches match-result match-ename)
  (setq ss (aicad:resolve-selection))
  (cond
    ((not ss)
     (aicad:clear-last-find-highlight)
     (aicad:reset-find-state)
     (princ "\nNo objects selected.")
    )
    ((= (aicad:trim search-text) "")
     (princ "\nRibbon find text is empty.")
    )
    (T
     (setq target-ss (aicad:filter-selection ss "TEXT"))
     (if (> (aicad:selection-count target-ss) 0)
       (progn
         (setq matches (aicad:matching-text-entities target-ss search-text))
         (if matches
           (progn
             (setq match-result (aicad:pick-find-match matches search-text))
             (setq match-ename (car match-result))
             (if (aicad:focus-find-match match-ename)
               (princ
                 (strcat
                   "\nFound match "
                   (itoa (cadr match-result))
                   "/"
                   (itoa (caddr match-result))
                   "."
                 )
               )
               (princ "\nFound a matching text object, but failed to zoom to it.")
             )
           )
           (progn
             (aicad:clear-last-find-highlight)
             (aicad:reset-find-state)
             (princ "\nNo matching text found in current selection.")
           )
         )
       )
       (progn
         (aicad:clear-last-find-highlight)
         (aicad:reset-find-state)
         (princ "\nNo text objects selected.")
       )
     )
    )
  )
)

(defun aicad:command-aicad (/ user-text)
  (setq user-text (getstring T "\nDescribe the change for the selected objects: "))
  (aicad:run-command user-text)
  (princ)
)

(defun c:AICAD ()
  (aicad:safe-apply "AICAD" 'aicad:command-aicad '())
  (princ)
)

(defun c:ASCAD ()
  (c:AICAD)
)

(defun aicad:command-ribbon (/ user-text)
  (setq user-text (aicad:trim (getenv "AICAD_RIBBON_INPUT")))
  (setenv "AICAD_RIBBON_INPUT" "")
  (if (= user-text "")
    (princ "\nRibbon input is empty.")
    (aicad:run-command user-text)
  )
  (princ)
)

(defun c:AICADRIBBON ()
  (aicad:safe-apply "AICADRIBBON" 'aicad:command-ribbon '())
  (princ)
)

(defun aicad:command-ribbon-replace (/ replace-count i search-text replace-text pairs)
  (setq pairs '())
  (setq replace-count (atoi (getenv *AICAD_RibbonReplaceCountVar*)))
  (if (> replace-count 0)
    (progn
      (setq i 1)
      (while (<= i replace-count)
        (setq search-text (getenv (strcat *AICAD_RibbonReplaceSearchPrefix* (itoa i))))
        (setq replace-text (getenv (strcat *AICAD_RibbonReplaceValuePrefix* (itoa i))))
        (if search-text (setenv (strcat *AICAD_RibbonReplaceSearchPrefix* (itoa i)) ""))
        (if replace-text (setenv (strcat *AICAD_RibbonReplaceValuePrefix* (itoa i)) ""))
        ;; Keep pure spaces as valid search text (do not use aicad:trim here).
        (if (aicad:nonempty-search-p search-text)
          (setq pairs (append pairs (list (list search-text (if replace-text replace-text "")))))
        )
        (setq i (1+ i))
      )
      (setenv *AICAD_RibbonReplaceCountVar* "")
    )
    ;; Backward compatibility: single search/value pair from the old scheme.
    (progn
      (setq search-text (getenv *AICAD_RibbonReplaceSearchVar*))
      (setq replace-text (getenv *AICAD_RibbonReplaceValueVar*))
      (setenv *AICAD_RibbonReplaceSearchVar* "")
      (setenv *AICAD_RibbonReplaceValueVar* "")
      (if (aicad:nonempty-search-p search-text)
        (setq pairs (list (list search-text (if replace-text replace-text ""))))
      )
    )
  )
  (aicad:run-ribbon-replacement-pairs pairs)
  (princ)
)

(defun c:AICADRIBBONREPLACE ()
  (aicad:safe-apply "AICADRIBBONREPLACE" 'aicad:command-ribbon-replace '())
  (princ)
)

(defun aicad:command-ribbon-find (/ search-text)
  (setq search-text (getenv *AICAD_RibbonFindSearchVar*))
  (setenv *AICAD_RibbonFindSearchVar* "")
  (aicad:run-ribbon-find search-text)
  (princ)
)

(defun c:AICADRIBBONFIND ()
  (aicad:safe-apply "AICADRIBBONFIND" 'aicad:command-ribbon-find '())
  (princ)
)

(defun aicad:command-ribbon-focus-match (/ handle)
  (setq handle (getenv *AICAD_RibbonFindHandleVar*))
  (setenv *AICAD_RibbonFindHandleVar* "")
  (aicad:run-ribbon-find-focus handle)
  (princ)
)

(defun c:AICADRIBBONFOCUSMATCH ()
  (aicad:safe-apply "AICADRIBBONFOCUSMATCH" 'aicad:command-ribbon-focus-match '())
  (princ)
)

(defun c:AICADCLEANUI ()
  (aicad:safe-apply "AICADCLEANUI" 'aicad:cleanup-legacy-ui '())
  (princ)
)

(defun c:UNLOAD_AICAD ()
  (aicad:unload)
  (princ)
)

(defun c:UNLOAD_AA ()
  (c:UNLOAD_AICAD)
)

(defun c:UNLOAD_XXX ()
  (c:UNLOAD_AICAD)
)

(aicad:safe-apply "startup cleanup" 'aicad:cleanup-legacy-ui '())
(princ "\nAICAD extension loaded. Run [AICAD] or [ASCAD], or use the AA ribbon input box.")
(princ)
