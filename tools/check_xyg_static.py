"""Parse XYG and evaluate its core helpers without CAD."""
from pathlib import Path
from check_fdx_static import ARITY, parse, walk

SOURCE = Path(__file__).resolve().parents[1] / 'AA整合版本.lsp'
raw = SOURCE.read_bytes()
assert not raw.startswith(b'\xef\xbb\xbf'), 'UTF-8 BOM present'
source = raw.decode('utf-8', errors='strict')
assert '\ufffd' not in source, 'U+FFFD replacement char present'
assert b'\n' not in raw.replace(b'\r\n', b''), 'Bare LF / mixed newlines'

forms = parse(source)
functions = {f[1]: f for f in forms if isinstance(f, list) and f[:1] == ['defun']}
targets = {k: v for k, v in functions.items() if k.startswith('xyg:') or k == 'c:xyg'}
assert 'c:xyg' in targets, 'c:xyg not found'
assert len(targets) >= 5, f'Expected at least 5 XYG functions, found {len(targets)}'

for name, form in targets.items():
    signature = form[2]
    declared = set(signature) | {'*error*', 'aa:tag', 'aa:doc', 'aa:undo-open', 'aa:old-cmdecho'}
    for node in walk(form[3:]):
        head = node[0]
        if not isinstance(head, str):
            continue
        if head in ARITY:
            low, high = ARITY[head]
            assert low <= len(node) - 1 <= high, (name, head, len(node) - 1)
        if head == 'setq':
            assert (len(node) - 1) % 2 == 0, (name, 'odd setq count')
            assigned = node[1::2]
            for var in assigned:
                assert var in declared or var.startswith('*'), f'{name}: undeclared setq variable {var}'
        if head == 'foreach':
            loop_var = node[1]
            assert loop_var in declared, f'{name}: undeclared loop variable {loop_var}'
        assert head != 'vl-sort', f'{name}: vl-sort is banned'


# Mock evaluation environment for xyg helpers
def evaluate(node, env):
    if not isinstance(node, list):
        if node == 't':
            return True
        if node == 'nil':
            return None
        if node.startswith('"'):
            return node[1:-1]
        try:
            val = float(node)
            return int(val) if val.is_integer() else val
        except ValueError:
            return env.get(node)
    if not node:
        return None
    op, *args = node
    if op == 'quote':
        def strip_quote(v):
            if isinstance(v, list):
                return [strip_quote(x) for x in v]
            if isinstance(v, str) and v.startswith('"') and v.endswith('"'):
                return v[1:-1]
            return v
        return strip_quote(args[0])
    if op == 'setq':
        for key, val in zip(args[::2], args[1::2]):
            env[key] = evaluate(val, env)
            if key.startswith('*'):
                GLOBALS[key] = env[key]   # 全局变量（如 *xyg-rect-src*）供断言读取
        return env[key]
    if op == 'if':
        branch = 1 if evaluate(args[0], env) else 2
        return evaluate(args[branch], env) if branch < len(args) else None
    if op == 'cond':
        for branch in args:
            test = evaluate(branch[0], env)
            if test or branch[0] == 't':
                result = test
                for expr in branch[1:]:
                    result = evaluate(expr, env)
                return result
        return None
    if op == 'while':
        while evaluate(args[0], env):
            for body in args[1:]:
                evaluate(body, env)
        return None
    if op in ('and', 'or'):
        for arg in args:
            result = evaluate(arg, env)
            if (op == 'and' and not result) or (op == 'or' and result):
                return result
        return result
    if op == 'foreach':
        for value in evaluate(args[1], env) or []:
            env[args[0]] = value
            for body in args[2:]:
                evaluate(body, env)
        return None
    if op == 'progn':
        result = None
        for arg in args:
            result = evaluate(arg, env)
        return result
    return invoke(op, [evaluate(a, env) for a in args], env)


def invoke(name, args, env):
    if name in native:
        return native[name](*args)
    form = functions[name]
    signature = form[2]
    boundary = signature.index('/') if '/' in signature else len(signature)
    local = dict(env)
    local.update({v: None for v in signature[boundary + 1:]})
    local.update(zip(signature[:boundary], args))
    result = None
    for body in form[3:]:
        result = evaluate(body, local)
    return result


from functools import cmp_to_key

GLOBALS = {}

current_env = {}

def lisp_sort(lst, fn):
    if not lst:
        return []
    def cmp(a, b):
        less = invoke(fn, [a, b], current_env) if isinstance(fn, (str, list)) else fn(a, b)
        if less:
            return -1
        less_rev = invoke(fn, [b, a], current_env) if isinstance(fn, (str, list)) else fn(b, a)
        if less_rev:
            return 1
        return 0
    return sorted(lst, key=cmp_to_key(cmp))

entities = {}
native = {
    '+': lambda *a: sum(a), '-': lambda a, *b: a - sum(b) if b else -a,
    '*': lambda a, b: a * b,
    '/': lambda a, b: a // b if isinstance(a, int) and isinstance(b, int) and b != 0 else a / b,
    '<': lambda a, b: a < b, '<=': lambda a, b: a <= b,
    '>': lambda a, b: a > b, '>=': lambda a, b: a >= b,
    '=': lambda a, b: a == b, '/=': lambda a, b: a != b,
    'car': lambda a: a[0] if a else None,
    'cdr': lambda a: ((a[1] if len(a) == 2 else list(a[1:])) if isinstance(a, tuple) else a[1:]) if a else None,
    'cadr': lambda a: a[1] if a and len(a) > 1 else None,
    'caddr': lambda a: a[2] if a and len(a) > 2 else None,
    'cadddr': lambda a: a[3] if a and len(a) > 3 else None,
    'assoc': lambda key, data: next((v for v in (data or []) if v[0] == key), None),
    'member': lambda item, lst: lst if lst and item in lst else None,
    'entget': lambda en: entities.get(en),
    'sslength': lambda s: len(s) if s is not None else 0,
    'ssname': lambda s, i: s[i] if s is not None and 0 <= i < len(s) else None,
    '1+': lambda x: x + 1,
    'null': lambda x: not bool(x),
    'list': lambda *a: list(a),
    'cons': lambda a, b: [a] + (b if isinstance(b, list) else [b]) if b is not None else [a],
    'length': lambda x: len(x) if x is not None else 0,
    'mapcar': lambda fn, lst: [invoke(fn, [x], current_env) for x in (lst or [])],
    'min': lambda *a: min(a),
    'max': lambda *a: max(a),
    'abs': lambda x: abs(x),
    'atoi': lambda s: int(s) if s and s.strip().isdigit() else 0,
    'reverse': lambda lst: list(reversed(lst or [])),
    'nth': lambda i, lst: lst[i] if lst and 0 <= i < len(lst) else None,
    'cddr': lambda a: a[2:] if a and len(a) > 2 else None,
    'eq': lambda a, b: a == b,
    'append': lambda *a: [x for part in a for x in (part or [])] or None,
    'aa:merge-sort': lisp_sort,
    'xy:get-text-bbox': lambda en: entities[en].get('bbox'),
}

def invoke_enhanced(name, args, env):
    global current_env
    current_env = env
    if isinstance(name, list) and name[0] == 'lambda':
        signature = name[1]
        boundary = signature.index('/') if '/' in signature else len(signature)
        local = dict(env)
        local.update({v: None for v in signature[boundary + 1:]})
        local.update(zip(signature[:boundary], args))
        result = None
        for body in name[2:]:
            result = evaluate(body, local)
        return result
    return invoke_orig(name, args, env)

invoke_orig = invoke
invoke = invoke_enhanced

# 联动辅助函数在 CAD 实体层读取 XData，此处以桩替代
native['aa:link-xdata'] = lambda en: None

# Test 1: xyg:find-prefix-text
entities = {
    't_small': [(0, 'TEXT'), (10, [10.0, 50.0, 0.0]), (40, 3.0)],
    't_big_right': [(0, 'TEXT'), (10, [200.0, 100.0, 0.0]), (40, 80.0)],
    't_big_left': [(0, 'MTEXT'), (10, [45.0, 120.0, 0.0]), (40, 85.0)],
}
prefix_result = invoke('xyg:find-prefix-text', [['t_small', 't_big_right', 't_big_left']], {})
assert prefix_result == 't_big_left', f'Expected t_big_left, got {prefix_result}'

# Test 2: xyg:text-record + xyg:box-hit-p（替代旧 xyg:text-in-rect-p 的逐次判定）
native['aa:ysdl-get-plain-text'] = lambda ed: next((v for k, v in ed if k == 1), '')
native['vl-string-trim'] = lambda chars, s: s.strip(' \t\r\n')
BBOX = {}
BBOX_CALLS = [0]


def bbox_stub(en):
    BBOX_CALLS[0] += 1
    return BBOX.get(en)


native['xy:get-text-bbox'] = bbox_stub
native['entget'] = lambda en: entities.get(en)


def text_ed(typ, x, y, h, s):
    return [(0, typ), (10, [x, y, 0.0]), (40, h), (1, s)]


def hit(en, rect):
    record = invoke('xyg:text-record', [en, 0, 'box'], {})
    return bool(record) and bool(invoke('xyg:box-hit-p', [record[2:], *rect], {}))


entities = {
    't_in': text_ed('TEXT', 140.0, 51.0, 3.0, 'A'),
    't_out_x': text_ed('TEXT', 240.0, 51.0, 3.0, 'A'),
    't_out_y': text_ed('TEXT', 140.0, 71.0, 3.0, 'A'),
    't_big_in': text_ed('TEXT', 140.0, 51.0, 80.0, 'A'),
    # 中心 cy=54.2 在 [49.8, 53.2] 外，但包围盒 miny=52.5 <= 53.2，与搜索框触碰
    't_touch_edge': text_ed('TEXT', 90.0, 52.5, 3.0, 'A'),
    't_upper_line': text_ed('TEXT', 140.0, 56.0, 3.0, 'A'),
    't_no_bbox': text_ed('TEXT', 120.0, 51.0, 3.0, 'A'),
}
BBOX = {
    't_in': [140.0, 160.0, 51.0, 53.0], 't_out_x': [240.0, 260.0, 51.0, 53.0],
    't_out_y': [140.0, 160.0, 71.0, 73.0], 't_big_in': [140.0, 160.0, 51.0, 53.0],
    't_touch_edge': [90.0, 110.0, 52.5, 56.0], 't_upper_line': [140.0, 160.0, 56.0, 58.0],
}
assert hit('t_in', [100.0, 200.0, 50.0, 55.0])
assert not hit('t_out_x', [100.0, 200.0, 50.0, 55.0])
assert not hit('t_out_y', [100.0, 200.0, 50.0, 55.0])
assert not hit('t_big_in', [100.0, 200.0, 50.0, 55.0])
assert hit('t_touch_edge', [80.0, 120.0, 49.8, 53.2])
# Test 3: 5mm 行距隔离（上一行文字 y=56~58 不进入 y=50 行的 49.8~53.2 搜索带）
assert not hit('t_upper_line', [100.0, 200.0, 49.8, 53.2])
# 包围盒读取失败时按插入点扩展：(x-2, x+2, y-0.5, y+h)
assert invoke('xyg:text-record', ['t_no_bbox', 7, 'box'], {}) == \
    [7, 't_no_bbox', 118.0, 122.0, 50.5, 54.0, 120.0, 'A']
assert hit('t_no_bbox', [121.5, 130.0, 53.9, 60.0])
assert not hit('t_no_bbox', [122.5, 130.0, 50.0, 60.0])

# Test 4: xyg:find-rect-texts keeps only the rightmost 3 texts if more are found
entities = {
    't1': text_ed('TEXT', 10.0, 51.0, 3.0, 'FAR_LEFT'),
    't2': text_ed('TEXT', 50.0, 51.0, 3.0, 'NAME'),
    't3': text_ed('TEXT', 90.0, 51.0, 3.0, 'TARGET'),
    't4': text_ed('TEXT', 130.0, 51.0, 3.0, 'SPEC'),
}
BBOX = {'t1': [10.0, 20.0, 51.0, 52.0], 't2': [50.0, 60.0, 51.0, 52.0],
        't3': [90.0, 100.0, 51.0, 52.0], 't4': [130.0, 140.0, 51.0, 52.0]}
native['xy:ss->list'] = lambda ss: list(ss or [])
native['xy:window-wcs'] = lambda *a: None
rect_index = invoke('xyg:build-text-index', [['t1', 't2', 't3', 't4'], 'box'], {})
res_3 = invoke('xyg:find-rect-texts', [[150.0, 50.0, 0.0], rect_index], {})
assert res_3 == ['NAME', 'TARGET', 'SPEC'], f'Expected 3 texts, got {res_3}'

# Test 5: xyg:dedup-hlines removes duplicate overlapping lines
entities = {
    'line_a': [(0, 'LINE'), (10, [0.0, 50.0, 0.0]), (11, [150.0, 50.0, 0.0])],
    'line_dup': [(0, 'LINE'), (10, [0.0, 50.0, 0.0]), (11, [150.0, 50.0, 0.0])],
    'line_right': [(0, 'LINE'), (10, [500.0, 50.0, 0.0]), (11, [650.0, 50.0, 0.0])],
    'line_lower': [(0, 'LINE'), (10, [0.0, 45.0, 0.0]), (11, [150.0, 45.0, 0.0])],
}
dedup_res = invoke('xyg:dedup-hlines', [['line_a', 'line_dup', 'line_right', 'line_lower'], 0.5], {})
assert len(dedup_res) == 3, f'Expected 3 lines after deduplication, got {len(dedup_res)}: {dedup_res}'
assert 'line_a' in dedup_res or 'line_dup' in dedup_res
assert 'line_right' in dedup_res and 'line_lower' in dedup_res

# Test 6: xyg:find-right-new-texts handles multiple columns on same row (no duplicate text)
# Row Y=50.0: Line 1 (rightPt=250.0) and Line 5 (rightPt=650.0)
entities = {}
for prefix, base in (('rt1', 250.0), ('rt5', 650.0)):
    for suffix, dx, s in (('core', 2.0, '4'), ('p1', 10.0, '107'), ('p2', 40.0, '107A'),
                          ('p3', 70.0, '101'), ('p4', 100.0, '133')):
        entities[f'{prefix}_{suffix}'] = text_ed('TEXT', base + dx, 50.5, 3.0, s)
new_index = invoke('xyg:build-text-index', [list(entities), 'point'], {})
expected_row = ['4', '107', '107A', '101', '133']
# Case 6a: with limit_x = 495.0 and expected_count = 4
assert invoke('xyg:find-right-new-texts', [[250.0, 50.0, 0.0], new_index, 4, 495.0], {}) == expected_row
# Case 6b: without max_x (relying on gap cutoff and core count truncation)
assert invoke('xyg:find-right-new-texts', [[250.0, 50.0, 0.0], new_index, 4, None], {}) == expected_row
# Case 6c: without max_x and without expected_count (auto-detected from first number "4")
assert invoke('xyg:find-right-new-texts', [[250.0, 50.0, 0.0], new_index, None, None], {}) == expected_row

# Test 7: AA_LINK 联动身份解析与原件判定（SX/SX1 共用）
functions.update({f[1]: f for f in forms if isinstance(f, list) and f[:1] == ['defun']
                  and f[1] in ('aa:link-info', 'aa:link-root-p')})
ed_link = [(0, 'TEXT'), (5, '2A'), [-3, ['AA_LINK', (1000, 'D1'), (1000, '2A')]]]
info = invoke('aa:link-info', [ed_link], {})
assert info == ['D1', '2A'], info
assert invoke('aa:link-info', [[(0, 'TEXT'), (5, '2A')]], {}) is None
assert invoke('aa:link-root-p', [info, 'D1', '2A'], {})          # 原件：图纸 ID 与句柄均匹配
assert not invoke('aa:link-root-p', [info, 'D1', '3F'], {})      # 草稿/XYG/GTY 副本：句柄不同
assert not invoke('aa:link-root-p', [info, 'D2', '2A'], {})      # 跨图粘贴：图纸 ID 不同
assert not invoke('aa:link-root-p', [None, 'D1', '2A'], {})

# Test 8: 缓存版与旧版逐个扫描结果一致（随机几何、边界接触、同 X 并列、窗口补查、联动来源一一对应）
# 旧版函数原文取自 2026-10-17 优化前源码，仅把 xyg: 前缀改为 old:；邻线与排序循环原样包成函数。
LEGACY_LSP = r'''
(defun old:text-in-rect-p (en xmin xmax ymin ymax / ed typ h bbox minx maxx miny maxy pt cx cy)
  (setq ed (entget en)
        typ (cdr (assoc 0 ed)))
  (if (member typ '("TEXT" "MTEXT"))
    (progn
      (setq h (cdr (assoc 40 ed)))
      ;; 排除字高 >= 80 的大字
      (if (and h (< h 79.9))
        (progn
          (setq bbox (xy:get-text-bbox en))
          (if bbox
            (progn
              (setq minx (car bbox)
                    maxx (cadr bbox)
                    miny (caddr bbox)
                    maxy (cadddr bbox))
              ;; 包围盒相交判定：只要文字的包围盒与搜索矩形有一点点触碰重叠，就算命中
              (and (<= minx xmax)
                   (>= maxx xmin)
                   (<= miny ymax)
                   (>= maxy ymin))
            )
            (progn
              ;; 若获取包围盒失败，保底基于插入点扩展判定
              (setq pt (cdr (assoc 10 ed))
                    cx (car pt)
                    cy (cadr pt))
              (and (<= (- cx 2.0) xmax)
                   (>= (+ cx 2.0) xmin)
                   (<= (- cy 0.5) ymax)
                   (>= (+ cy h) ymin))
            )
          )
        )
      )
    )
  )
)

(defun old:find-rect-texts (rightPt all-ss / rx ry xmin xmax ymin ymax res i en ed str bbox cx nearby)
  (setq rx   (car rightPt)
        ry   (cadr rightPt)
        xmin (- rx 155.0)
        xmax (+ rx 0.5)
        ymin (- ry 0.5)
        ymax (+ ry 3.5)
        res  '()
        i    0)
  (if all-ss
    (while (< i (sslength all-ss))
      (setq en (ssname all-ss i))
      (if (old:text-in-rect-p en xmin xmax ymin ymax)
        (progn
          (setq ed   (entget en)
                str  (aa:ysdl-get-plain-text ed)
                bbox (xy:get-text-bbox en)
                cx   (if bbox (/ (+ (car bbox) (cadr bbox)) 2.0) (car (cdr (assoc 10 ed)))))
          (if (/= (vl-string-trim " \t\r\n" str) "")
            (setq res (cons (list en cx str) res))
          )
        )
      )
      (setq i (1+ i))
    )
  )
  ;; 若在框选集合中未找到足够的3个文字，自动在当前图面对应矩形区域内补充查找，彻底杜绝框选不全导致的漏选
  (if (< (length res) 3)
    (progn
      (setq nearby (xy:window-wcs xmin ymin xmax ymax '((0 . "TEXT,MTEXT"))))
      (if nearby
        (progn
          (setq i 0)
          (while (< i (sslength nearby))
            (setq en (ssname nearby i))
            (if (and (null (assoc en res))
                     (old:text-in-rect-p en xmin xmax ymin ymax))
              (progn
                (setq ed   (entget en)
                      str  (aa:ysdl-get-plain-text ed)
                      bbox (xy:get-text-bbox en)
                      cx   (if bbox (/ (+ (car bbox) (cadr bbox)) 2.0) (car (cdr (assoc 10 ed)))))
                (if (/= (vl-string-trim " \t\r\n" str) "")
                  (setq res (cons (list en cx str) res))
                )
              )
            )
            (setq i (1+ i))
          )
        )
      )
    )
  )
  ;; 按 X 坐标从左到右排序
  (setq res (aa:merge-sort res '(lambda (a b) (< (cadr a) (cadr b)))))
  ;; 从右侧顶点往左看最多只有 3 个文字，多于 3 个时只保留最靠近右侧的最后 3 个
  (while (> (length res) 3)
    (setq res (cdr res))
  )
  (setq *xyg-rect-src* (mapcar 'aa:link-xdata (mapcar 'car res)))
  (mapcar 'caddr res)
)

(defun old:find-right-new-texts (rightPt new-texts expected-count max-x / rx ry limit-x res en ed pt x y str prev-x cand keep-cnt trimmed idx cand-num gap-ok)
  (setq rx      (car rightPt)
        ry      (cadr rightPt)
        limit-x (if max-x max-x (+ rx 350.0)))
  (if (and expected-count (> expected-count 0))
    (setq limit-x (min limit-x (+ rx 10.0 (* 30.0 expected-count) 20.0)))
  )
  (setq res '())
  (foreach en new-texts
    (setq ed (entget en))
    (if (member (cdr (assoc 0 ed)) '("TEXT" "MTEXT"))
      (progn
        (setq pt (cdr (assoc 10 ed))
              x  (car pt)
              y  (cadr pt))
        ;; Y 坐标在 ry+0.5 附近，X 坐标大于 rx 且不超过 limit-x
        (if (and (> x (+ rx 0.5))
                 (<= x limit-x)
                 (<= (abs (- y (+ ry 0.5))) 0.6))
          (progn
            (setq str (aa:ysdl-get-plain-text ed))
            (if (/= (vl-string-trim " \t\r\n" str) "")
              (setq res (cons (list en x str) res))
            )
          )
        )
      )
    )
  )
  ;; 按 X 坐标从左到右排序：芯数数字在前，原理号在后
  (setq res (aa:merge-sort res '(lambda (a b) (< (cadr a) (cadr b)))))

  ;; 间距连续性截断：若相邻文字间距突增（> 50.0），说明已越界进入下一列/设备，立即停止
  (if res
    (progn
      (setq prev-x  rx
            trimmed '()
            gap-ok  T)
      (while (and gap-ok res)
        (setq cand (car res))
        (if (null trimmed)
          (setq trimmed (cons cand trimmed)
                prev-x  (cadr cand)
                res     (cdr res))
          (if (<= (- (cadr cand) prev-x) 50.0)
            (setq trimmed (cons cand trimmed)
                  prev-x  (cadr cand)
                  res     (cdr res))
            (setq gap-ok nil)
          )
        )
      )
      (setq res (reverse trimmed))
    )
  )

  ;; 芯数上限截断：首个文字为芯数数字 N，整组最多只包含 1 (芯数) + N (原理号)
  (if res
    (progn
      (if (or (null expected-count) (<= expected-count 0))
        (progn
          (setq cand-num (atoi (caddr (car res))))
          (if (> cand-num 0)
            (setq expected-count cand-num)
          )
        )
      )
      (if (and expected-count (> expected-count 0))
        (progn
          (setq keep-cnt (1+ expected-count)
                trimmed  '()
                idx      0)
          (while (and (< idx keep-cnt) res)
            (setq trimmed (cons (car res) trimmed)
                  res     (cdr res)
                  idx     (1+ idx))
          )
          (setq res (reverse trimmed))
        )
      )
    )
  )

  (setq *xyg-right-src* (mapcar 'aa:link-xdata (mapcar 'car res)))
  (mapcar 'caddr res)
)
(defun old:sort-lines-desc (green-lines-list)
  (aa:merge-sort green-lines-list
    '(lambda (ea eb / eda edb ya yb)
       (setq eda (entget ea)
             edb (entget eb)
             ya  (caddr (assoc 10 eda))
             yb  (caddr (assoc 10 edb)))
       (> ya yb))))

(defun old:next-line-min-x (line-en rx ry sorted-lines / next-line-min-x other-en other-ed other-p1 other-p2 other-y other-min-x)
  (setq next-line-min-x nil)
  (foreach other-en sorted-lines
    (if (/= other-en line-en)
      (progn
        (setq other-ed (entget other-en)
              other-p1 (cdr (assoc 10 other-ed))
              other-p2 (cdr (assoc 11 other-ed))
              other-y  (cadr other-p1)
              other-min-x (min (car other-p1) (car other-p2)))
        (if (and (<= (abs (- other-y ry)) 0.5)
                 (> other-min-x rx))
          (if (or (null next-line-min-x) (< other-min-x next-line-min-x))
            (setq next-line-min-x other-min-x)
          )
        )
      )
    )
  )
  next-line-min-x
)
'''
functions.update({f[1]: f for f in parse(LEGACY_LSP) if isinstance(f, list) and f[:1] == ['defun']})
native['aa:link-xdata'] = lambda en: ['LINK', en]

import random

GRID = 0.5   # 坐标取 0.5 网格，频繁制造恰好接触搜索框边界的情形
stats = {'old_calls': 0, 'new_calls': 0, 'rect': 0, 'right': 0, 'fallback': 0}


def snap(v):
    return round(v / GRID) * GRID


def run_scene(seed):
    global entities, BBOX
    r = random.Random(seed)
    entities, BBOX = {}, {}
    columns = [150.0, 400.0, 650.0][:r.randint(1, 3)]
    rows = [50.0 + 5.0 * k for k in range(r.randint(2, 6))]
    right_pts = [[snap(cx + r.choice([0.0, 0.0, 0.25, -0.5])), ry + r.choice([0.0, 0.0, 0.1, -0.3]), 0.0]
                 for cx in columns for ry in rows]
    selection, drawing = [], []
    n = 0
    for rp in right_pts:
        for _ in range(r.randint(0, 7)):
            n += 1
            en = f'T{n}'
            w, hgt = snap(r.uniform(1.0, 30.0)), r.choice([2.5, 3.0, 3.5, 3.0])
            x0 = snap(rp[0] + r.uniform(-200.0, 20.0))
            y0 = snap(rp[1] + r.uniform(-3.0, 4.0))
            h = r.choice([3.0] * 9 + [80.0, 79.9, 100.0])
            s = r.choice(['W1', '1-2', 'KVV', 'X', '7', '  ', '']) if r.random() < 0.3 else f'S{n}'
            typ = r.choice(['TEXT', 'TEXT', 'MTEXT'])
            entities[en] = text_ed(typ, x0, y0, h, s)
            if r.random() < 0.85:
                BBOX[en] = [x0, x0 + w, y0, y0 + hgt]
            if r.random() < 0.2 and drawing:   # 与已有文字包围盒完全相同：中心X并列，检验等X顺序
                twin = r.choice(drawing)
                if twin in BBOX:
                    BBOX[en] = list(BBOX[twin])
            drawing.append(en)
            if r.random() < 0.8:
                selection.append(en)
        if r.random() < 0.3:
            n += 1
            entities[f'L{n}'] = [(0, 'LINE'), (10, [rp[0] - 100.0, rp[1], 0.0]), (11, list(rp))]
            selection.append(f'L{n}')
    r.shuffle(selection)
    r.shuffle(drawing)

    def window(xmin, ymin, xmax, ymax, flt):
        # 模拟交叉窗口：图面上与窗口相交的文字（含选区内与选区外），顺序固定
        stats['fallback'] += 1
        hits = []
        for en in drawing:
            pt = entities[en][1][1]
            box = BBOX.get(en, [pt[0], pt[0], pt[1], pt[1]])
            if box[0] <= xmax and box[1] >= xmin and box[2] <= ymax and box[3] >= ymin:
                hits.append(en)
        return hits or None

    native['xy:window-wcs'] = window
    BBOX_CALLS[0] = 0
    rect_index = invoke('xyg:build-text-index', [selection, 'box'], {})
    for rp in right_pts:
        new_res = invoke('xyg:find-rect-texts', [rp, rect_index], {})
        new_src = GLOBALS['*xyg-rect-src*']
        assert len(new_res) == len(new_src or []), (seed, rp)
        GLOBALS['*xyg-rect-src*'] = 'unset'
        mid = BBOX_CALLS[0]
        old_res = invoke('old:find-rect-texts', [rp, selection], {})
        old_src = GLOBALS['*xyg-rect-src*']
        stats['old_calls'] += BBOX_CALLS[0] - mid
        BBOX_CALLS[0] = mid
        assert (new_res, new_src) == (old_res, old_src), (seed, rp, new_res, old_res, new_src, old_src)
        stats['rect'] += 1
    stats['new_calls'] += BBOX_CALLS[0]

    # XY 新文字：芯数 + 原理号，Y 在 ry+0.5 附近抖动以覆盖 ±0.6 判定边界
    new_texts = []
    for rp in right_pts:
        x = rp[0] + r.choice([0.0, 0.5, 0.75, 2.0])
        for k in range(r.randint(0, 6)):
            n += 1
            en = f'N{n}'
            dy = r.choice([0.5, 0.5, 0.5, 1.1, -0.1, 1.2, -0.2, 0.0, 2.5])
            s = str(r.randint(1, 5)) if k == 0 else r.choice([f'P{n}', '', f'Q{n}'])
            entities[en] = text_ed('TEXT', x, rp[1] + dy, 3.0, s)
            new_texts.append(en)
            x += r.choice([10.0, 30.0, 30.0, 49.5, 50.0, 50.5, 80.0])
    r.shuffle(new_texts)
    new_index = invoke('xyg:build-text-index', [new_texts, 'point'], {})
    for rp in right_pts:
        for expected in (None, 0, r.randint(1, 5)):
            for max_x in (None, rp[0] + r.choice([5.0, 60.0, 120.0, 400.0])):
                a = invoke('xyg:find-right-new-texts', [rp, new_index, expected, max_x], {})
                a_src = GLOBALS['*xyg-right-src*']
                GLOBALS['*xyg-right-src*'] = 'unset'
                b = invoke('old:find-right-new-texts', [rp, new_texts, expected, max_x], {})
                b_src = GLOBALS['*xyg-right-src*']
                assert (a, a_src) == (b, b_src), (seed, rp, expected, max_x, a, b)
                stats['right'] += 1

    # 直线排序与右侧邻线边界
    lines = []
    for k in range(r.randint(1, 12)):
        y = r.choice(rows) + r.choice([0.0, 0.0, 0.5, -0.5, 0.25, 0.75, -0.75])
        x1 = snap(r.uniform(0.0, 800.0))
        x2 = x1 + snap(r.uniform(-150.0, 150.0))
        en = f'G{k}'
        # (10 x y z) 形式，使 (caddr (assoc 10 ed)) 与 (cdr (assoc 10 ed)) 均按 AutoLISP 语义取值
        entities[en] = [(0, 'LINE'), (10, x1, y, 0.0), (11, x2, y, 0.0)]
        lines.append(en)
    sorted_new = invoke('xyg:sort-lines-desc', [lines], {})
    assert sorted_new == invoke('old:sort-lines-desc', [lines], {}), seed
    geo = invoke('xyg:line-geo-list', [sorted_new], {})
    for en in sorted_new:
        p1, p2 = list(entities[en][1][1:]), list(entities[en][2][1:])
        rp = p1 if p1[0] >= p2[0] else p2
        for ry in (rp[1], rp[1] + 0.5, rp[1] - 0.5, rp[1] + 0.25):
            got = invoke('xyg:next-line-min-x', [en, rp[0], ry, geo], {})
            want = invoke('old:next-line-min-x', [en, rp[0], ry, sorted_new], {})
            assert got == want, (seed, en, ry, got, want)


for seed in range(60):
    run_scene(1000 + seed)
assert stats['rect'] > 300 and stats['right'] > 1000 and stats['fallback'] > 0, stats
assert stats['new_calls'] < stats['old_calls'], stats

# Test 8: xyg:output-gtx-matrix 处理 (文字 . AA_LINK) 项：排序只比较文字，输出文字与联动一一对应
def _nat_less(a, b):
    assert isinstance(a, str) and isinstance(b, str), ('natural-less got non-string', a, b)
    return a < b
made = []
native['aa:gtx-natural-less'] = _nat_less
native['textbox'] = lambda ed: None
native['xyg:make-linked-text'] = lambda pt, content, h, sty, src: made.append((content, src)) or True
link_a = [-3, ['AA_LINK', (1000, 'D1'), (1000, '1A')]]
grp_b = [['DS-03', link_a], ['4'], ['107', link_a]]
grp_a = [['DS-01'], ['2'], ['101']]
cats = [['DS', [grp_b, grp_a]]]
invoke('xyg:output-gtx-matrix', [cats, ['同步时钟柜'], [0.0, 0.0, 0.0], 'HZ'], {})
assert [c for c, _ in made] == ['同步时钟柜', 'DS-01', '2', '101', '同步时钟柜', 'DS-03', '4', '107'], made
assert made[5][1] == [link_a] and not made[1][1], made

print(f'PASS: {len(targets)} XYG functions; prefix text detection; 3mm rect filtering & 3-text truncation; hline dedup; '
      f'right-text cluster/count isolation (no duplicate text across columns); AA_LINK info/root detection; matrix sort on (text . link) pairs; '
      f"indexed vs legacy identical ({stats['rect']} rect + {stats['right']} right queries, "
      f"bbox requests {stats['old_calls']} -> {stats['new_calls']}); balanced forms and arities")
