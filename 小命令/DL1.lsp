;; ============================================================
;; DL1  创建电缆柜、电缆路径、电缆竖井相关 1F / 2F 图层
;; 依赖：仅使用 CAD 内置 AutoLISP 函数，无外部依赖。
;; ============================================================

(defun dl1:make-layer (name /)
  (if (not (tblsearch "LAYER" name))
    (entmake
      (list
        '(0 . "LAYER")
        '(100 . "AcDbSymbolTableRecord")
        '(100 . "AcDbLayerTableRecord")
        (cons 2 name)
        '(70 . 0)
        '(62 . 7)
        '(6 . "Continuous")
      )
    )
  )
)

(defun c:DL1 (/ layers)
  (setq layers
    '(
      "CABLE_CABINET_1F"
      "CABLE_CABINET_2F"
      "CABLE_ROUTE_1F"
      "CABLE_ROUTE_2F"
      "CABLE_SHAFT_1F"
      "CABLE_SHAFT_2F"
    )
  )
  (foreach lay layers
    (dl1:make-layer lay)
  )
  (princ "\nDL1：已检查并创建 6 个电缆相关图层。")
  (princ)
)

(princ "\nDL1 命令已加载，输入 DL1 创建电缆相关图层。")
(princ)