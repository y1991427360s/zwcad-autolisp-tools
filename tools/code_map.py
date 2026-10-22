"""AA整合版本.lsp 代码地图：按行号定位命令与函数，避免通读 2 万行整合文件（离线，不连 CAD）。

用法（在项目根目录）：
  python tools/code_map.py write              # 生成 docs/CODE_MAP.md
  python tools/code_map.py check              # 校验 docs/CODE_MAP.md 是否与源码一致
  python tools/code_map.py show NU C1         # 命令/函数的行号范围 + 下游调用（默认 2 层）
  python tools/code_map.py show zddl2:        # 以冒号结尾按前缀列出整组函数
  python tools/code_map.py show NU --source   # 同时打印源码
  python tools/code_map.py callers aa:num-target-span   # 谁调用了它（改共享函数前必查）
"""
import argparse
import bisect
import re
import sys
from collections import OrderedDict
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from lsp_common import SOURCE, parse_with_locations, read_source, walk  # noqa: E402

ROOT = SOURCE.parent
MAP_PATH = ROOT / 'docs' / 'CODE_MAP.md'
GENERIC_PREFIXES = {'aa', 'c'}


class Defun:
    __slots__ = ('name', 'start', 'end', 'node', 'callees')

    def __init__(self, name, start, end, node):
        self.name, self.start, self.end, self.node = name, start, end, node
        self.callees = []

    @property
    def is_command(self):
        return self.name.startswith('c:')

    @property
    def prefix(self):
        if self.is_command:
            return 'c'
        return self.name.split(':', 1)[0] if ':' in self.name else '(无前缀)'


class CodeMap:
    def __init__(self, text):
        self.text = text
        self.lines = text.split('\r\n')
        forms, locations = parse_with_locations(text)
        starts = [0] + [m.end() for m in re.finditer('\n', text)]

        def line_of(offset):
            return bisect.bisect_right(starts, offset)

        self.defuns = []
        for form in forms:
            # 顶层 defun，以及包在 progn / if 等顶层表达式里的 defun；命令内部的局部 *error* 不算
            stack = [form]
            while stack:
                node = stack.pop()
                if not isinstance(node, list) or not node:
                    continue
                if node[0] == 'defun' and len(node) > 2 and isinstance(node[1], str):
                    _, start, end = locations[id(node)]
                    self.defuns.append(Defun(node[1], line_of(start), line_of(end - 1), node))
                    continue
                stack.extend(reversed(node))
        self.defuns.sort(key=lambda d: d.start)
        self.by_name = OrderedDict()
        for d in self.defuns:
            self.by_name.setdefault(d.name, []).append(d)
        known = set(self.by_name)
        for d in self.defuns:
            seen = OrderedDict()
            for node in walk(d.node):
                head = node[0]
                if isinstance(head, str) and head in known and head != d.name:
                    seen[head] = True
                # (function xx) / 'xx 形式传入 mapcar、vl-catch-all-apply 的函数也算调用
                if (head in ('function', 'quote') and len(node) == 2
                        and isinstance(node[1], str) and node[1] in known):
                    seen[node[1]] = True
            d.callees = list(seen)
        self.callers = {}
        for d in self.defuns:
            for c in d.callees:
                self.callers.setdefault(c, []).append(d.name)
        self.descriptions = self._descriptions()

    def _descriptions(self):
        header = self.text.split('(defun', 1)[0]
        desc = {m.group(1).upper(): m.group(2).strip()
                for m in re.finditer(r'^;;;\s*-\s*([A-Za-z0-9_]+)\s*[:：]\s*(.*)$', header, re.M)}
        for d in self.defuns:
            if not d.is_command or d.name[2:].upper() in desc:
                continue
            for j in range(d.start - 2, max(d.start - 10, -1), -1):
                s = self.lines[j].strip()
                if not s.startswith(';'):
                    break
                m = re.match(r';+\s*(?:功能|说明)\s*[:：]\s*(.+)', s)
                if m:
                    desc[d.name[2:].upper()] = m.group(1).strip()
                    break
        return desc

    def resolve(self, query):
        q = query.strip().lower()
        if q.endswith(':') and q != 'c:':
            return [d for d in self.defuns if d.name.startswith(q)]
        for cand in (q, 'c:' + q):
            if cand in self.by_name:
                return list(self.by_name[cand])
        return []

    def transitive_callers(self, names):
        out, todo = set(), list(names)
        while todo:
            n = todo.pop()
            for c in self.callers.get(n, []):
                if c not in out:
                    out.add(c)
                    todo.append(c)
        return out

    def defuns_touching(self, line_ranges):
        hit = OrderedDict()
        for a, b in line_ranges:
            for d in self.defuns:
                if d.start <= b and a <= d.end:
                    hit[d.name] = True
        return list(hit)


def load(path=None):
    _, text = read_source(path or SOURCE)
    return CodeMap(text)


def fmt_range(d):
    return f'{d.start}-{d.end}'


def render_markdown(cm):
    cmds = [d for d in cm.defuns if d.is_command]
    dup = sorted(n for n, ds in cm.by_name.items() if len(ds) > 1)
    out = [
        '# AA整合版本.lsp 代码地图',
        '',
        '> 由 `python tools/code_map.py write` 自动生成（`python gen_命令索引.py` 也会顺带生成），请勿手工维护。',
        '> 行号随源码变动；改完 LISP 后重新生成，`python tools/check_all_static.py` 会校验本文件是否过期。',
        '',
        '## 使用方法（给 AI / 人）',
        '',
        '1. **不要通读整合文件。** 先在下表找命令的行号范围，再按行号只读那一段。',
        '2. `python tools/code_map.py show 命令或函数` 直接输出行号范围和下游调用（加 `--source` 打印源码）。',
        '3. 改共享函数前先跑 `python tools/code_map.py callers 函数名`，确认影响哪些命令。',
        '4. 改动过程中用 `python tools/check_all_static.py --quick` 只跑相关检查；交付前跑一次不带参数的全量检查。',
        '',
        f'- 源文件：`{SOURCE.name}`，{len(cm.lines)} 行，{len(cm.defuns)} 个函数，其中 {len(cmds)} 个 `c:` 命令。',
    ]
    if dup:
        out.append(f'- ⚠️ 重复定义（后加载者生效）：{", ".join(f"`{n}`" for n in dup)}')
    out += ['', '## 命令', '', '| 命令 | 行号 | 行数 | 说明 | 直接调用的项目函数（行号） |',
            '|------|------|------|------|------|']
    for d in cmds:
        calls = []
        for c in d.callees:
            target = cm.by_name[c][0]
            calls.append(f'{c}:{target.start}')
        shown = ', '.join(calls[:12]) + (f' …共 {len(calls)} 个' if len(calls) > 12 else '')
        desc = cm.descriptions.get(d.name[2:].upper(), '').replace('|', '\\|')
        out.append(f'| `{d.name[2:].upper()}` | {fmt_range(d)} | {d.end - d.start + 1} | {desc} | {shown} |')

    groups = OrderedDict()
    for d in cm.defuns:
        if not d.is_command:
            groups.setdefault(d.prefix, []).append(d)
    out += ['', '## 辅助函数分组（按前缀）', '',
            '| 前缀 | 函数数 | 行号分布 | 使用这些函数的命令 |', '|------|------|------|------|']
    for prefix, ds in sorted(groups.items(), key=lambda kv: kv[1][0].start):
        spans = []
        for d in ds:
            if spans and d.start - spans[-1][1] <= 40:
                spans[-1][1] = d.end
            else:
                spans.append([d.start, d.end])
        span_txt = ', '.join(f'{a}-{b}' for a, b in spans[:6]) + (' …' if len(spans) > 6 else '')
        users = sorted({c[2:].upper() for c in cm.transitive_callers([d.name for d in ds])
                        if c.startswith('c:')})
        user_txt = ', '.join(users[:15]) + (f' …共 {len(users)} 个' if len(users) > 15 else '')
        out.append(f'| `{prefix}:` | {len(ds)} | {span_txt} | {user_txt} |')
    return '\r\n'.join(out) + '\r\n'


def cmd_write(cm):
    MAP_PATH.parent.mkdir(exist_ok=True)
    MAP_PATH.write_bytes(render_markdown(cm).encode('utf-8'))
    print(f'已生成 {MAP_PATH.relative_to(ROOT).as_posix()}：{len(cm.defuns)} 个函数')
    return 0


def is_fresh(cm):
    return MAP_PATH.exists() and MAP_PATH.read_bytes() == render_markdown(cm).encode('utf-8')


def cmd_check(cm):
    if is_fresh(cm):
        print('PASS code-map: docs/CODE_MAP.md 与源码一致')
        return 0
    print('FAIL code-map: docs/CODE_MAP.md 已过期，请运行 python tools/code_map.py write')
    return 1


def cmd_show(cm, queries, depth, source):
    rc = 0
    for q in queries:
        found = cm.resolve(q)
        if not found:
            print(f'未找到：{q}')
            rc = 1
            continue
        if q.endswith(':'):
            print(f'== 前缀 {q}（{len(found)} 个函数）==')
            for d in found:
                print(f'  {d.name:<40} {fmt_range(d)}')
            continue
        for d in found:
            print(f'== {d.name}  行 {fmt_range(d)}（{d.end - d.start + 1} 行）==')
            desc = cm.descriptions.get(d.name[2:].upper()) if d.is_command else None
            if desc:
                print(f'  说明: {desc}')
            seen = {d.name}

            def tree(name, level):
                for c in cm.by_name[name][0].callees if name in cm.by_name else []:
                    if c in seen:
                        continue
                    seen.add(c)
                    t = cm.by_name[c][0]
                    print(f'  {"  " * level}-> {c:<40} {fmt_range(t)}')
                    if level + 1 < depth:
                        tree(c, level + 1)

            tree(d.name, 0)
            if source:
                print('\n'.join(f'{i:>6}  {cm.lines[i - 1]}' for i in range(d.start, d.end + 1)))
    return rc


def cmd_callers(cm, queries):
    rc = 0
    for q in queries:
        found = cm.resolve(q)
        if not found:
            print(f'未找到：{q}')
            rc = 1
            continue
        name = found[0].name
        direct = cm.callers.get(name, [])
        cmds = sorted(c[2:].upper() for c in cm.transitive_callers([name]) if c.startswith('c:'))
        print(f'== {name}  行 {fmt_range(found[0])} ==')
        print(f'  直接调用者 {len(direct)} 个：')
        for c in direct:
            print(f'    {c:<40} {fmt_range(cm.by_name[c][0])}')
        print(f'  最终影响的命令 {len(cmds)} 个：{", ".join(cmds) or "无"}')
    return rc


def main(argv=None):
    ap = argparse.ArgumentParser(description='AA整合版本.lsp 代码地图')
    sub = ap.add_subparsers(dest='action', required=True)
    sub.add_parser('write')
    sub.add_parser('check')
    p = sub.add_parser('show')
    p.add_argument('names', nargs='+')
    p.add_argument('--depth', type=int, default=2)
    p.add_argument('--source', action='store_true')
    p = sub.add_parser('callers')
    p.add_argument('names', nargs='+')
    a = ap.parse_args(argv)
    cm = load()
    if a.action == 'write':
        return cmd_write(cm)
    if a.action == 'check':
        return cmd_check(cm)
    if a.action == 'show':
        return cmd_show(cm, a.names, a.depth, a.source)
    return cmd_callers(cm, a.names)


if __name__ == '__main__':
    sys.stdout.reconfigure(encoding='utf-8')
    sys.exit(main())
