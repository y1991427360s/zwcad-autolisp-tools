# -*- coding: utf-8 -*-
"""
扫描本项目所有 .lsp，提取每个 c: 命令的 文件 / 行号 / 功能，同时生成 命令索引.md 和 命令索引.html。
用法：在项目根目录执行  python gen_命令索引.py
说明：脚本自动生成，命令有增删改名后重跑本脚本即可刷新索引，无需手工维护两个索引文件。
"""
import glob
import html
import re

# 1) 收集 lsp 文件（排除备份、副本、loader 自身）
files = []
for f in glob.glob('*.lsp') + glob.glob('小命令/*.lsp') + glob.glob('小命令/*.LSP'):
    low = f.lower()
    if '.bak' in low or '副本' in f or low.endswith('aa-loader.lsp'):
        continue
    files.append(f.replace('\\', '/'))
files = sorted(set(files))

def read(path):
    return open(path, 'rb').read().decode('gbk', 'replace')

# 2) 从所有文件的命令清单 / 启动提示建功能字典（补全注释缺失）
hint = {}
hint_res = [
    re.compile(r'\[([A-Za-z0-9]+)\](?:\s*/\s*\[([A-Za-z0-9]+)\])?\s*-\s*([^"\)\r\n]+)'),
    re.compile(r'^;+\s*-\s*([A-Za-z0-9_]+)\s*[:：]?\s*([^\r\n]+)', re.M),
    re.compile(r'^;+\s*([A-Za-z0-9_]+)\s*[:：]\s*([^\r\n]+)', re.M),
    re.compile(r'^;+\s*命令\s+([A-Za-z0-9_]+)\s*[:：]\s*([^\r\n]+)', re.M),
    re.compile(r'^;+\s*([A-Za-z][A-Za-z0-9_]*)\s{2,}([^\r\n]+)', re.M),
]
for f in files:
    text = read(f)
    for m in hint_res[0].finditer(text):
        desc = m.group(3).strip()
        for name in (m.group(1), m.group(2)):
            if name:
                hint.setdefault(name.upper(), desc)
    for pattern in hint_res[1:]:
        for m in pattern.finditer(text):
            name = m.group(1)
            desc = m.group(2).strip()
            if name and desc:
                hint.setdefault(name.upper(), desc)

def clean(txt):
    txt = txt.strip().strip('-').strip()
    # 去掉 "XXX 命令: yyy" / "命令 N (XX): yyy" 这类前缀，保留冒号后描述
    mm = re.search(r'[:：]\s*(.+)$', txt)
    if mm and re.search(r'命令|功能|说明|作用|描述|Function', txt[:mm.start()]):
        txt = mm.group(1).strip()
    # "主命令：XY" 这类无信息描述丢弃
    if re.fullmatch(r'主命令[:：].*', txt) or txt in ('调试命令', '主命令'):
        return ''
    return txt.strip()

def extract(path):
    lines = read(path).split('\n')
    out = []
    for i, l in enumerate(lines):
        m = re.match(r'\s*\(defun\s+c:([A-Za-z0-9_]+)', l, re.I)
        if not m:
            continue
        name = m.group(1).upper()
        desc = ''
        for j in range(i - 1, max(i - 8, -1), -1):
            s = lines[j].strip()
            if not s.startswith(';'):
                if s == '':
                    continue
                break
            txt = s.lstrip(';').strip()
            if re.fullmatch(r'[=\-\s]*', txt):
                continue
            desc = clean(txt)
            if desc and desc.upper() != name:
                break
            desc = ''
        if not desc:
            desc = hint.get(name, '')
        out.append((name, i + 1, desc))
    return out

rows = []
for f in files:
    for name, ln, desc in extract(f):
        rows.append([name, f, ln, desc])

# 3) 标注重复命令（同名出现在多个文件）
from collections import Counter
dup = {n for n, c in Counter(r[0] for r in rows).items() if c > 1}
rows.sort(key=lambda r: (r[0], r[1]))

with open('命令索引.md', 'w', encoding='utf-8') as w:
    w.write('# ZW-auto_lisp 命令索引\n\n')
    w.write('> 本文件与 `命令索引.html` 均由 `gen_命令索引.py` 自动生成，请勿手工维护。\n')
    w.write('> 命令有增删改名后，在项目根目录运行 `python gen_命令索引.py` 同时重新生成两份索引。\n\n')
    w.write(f'- 命令总数：**{len(rows)}**，覆盖 **{len(files)}** 个文件。\n')
    if dup:
        w.write(f'- ⚠️ 重复定义命令（多个文件同名，注意加载顺序/避免改错文件）：**{", ".join(sorted(dup))}**\n')
    w.write('\n| 命令 | 文件 | 行号 | 功能 |\n|------|------|------|------|\n')
    for name, f, ln, desc in rows:
        flag = ' ⚠️' if name in dup else ''
        desc = (desc or '').replace('|', '\\|')
        w.write(f'| `{name}`{flag} | {f} | {ln} | {desc} |\n')

duplicate_note = ''
if dup:
    duplicate_note = f'''<p class="warning"><strong>重复定义命令：</strong>{html.escape(", ".join(sorted(dup)))}。请注意加载顺序，避免改错文件。</p>'''

table_rows = []
for name, f, ln, desc in rows:
    warning = '<span class="badge" title="该命令在多个文件中重复定义">重复</span>' if name in dup else ''
    file_href = f.replace('\\', '/').replace(' ', '%20')
    table_rows.append(
        '<tr>'
        f'<td><code>{html.escape(name)}</code>{warning}</td>'
        f'<td><a href="{html.escape(file_href, quote=True)}">{html.escape(f)}</a></td>'
        f'<td>{ln}</td>'
        f'<td>{html.escape(desc or "")}</td>'
        '</tr>'
    )

html_doc = f'''<!doctype html>
<html lang="zh-CN">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>ZW-auto_lisp 命令索引</title>
  <style>
    :root {{ color-scheme: light; font-family: "Microsoft YaHei", "Segoe UI", sans-serif; color: #202124; background: #f5f6f8; }}
    * {{ box-sizing: border-box; }}
    body {{ margin: 0; }}
    main {{ width: min(1180px, calc(100% - 32px)); margin: 32px auto; }}
    h1 {{ margin: 0 0 8px; font-size: 28px; letter-spacing: 0; }}
    .meta {{ margin: 0 0 20px; color: #5f6368; }}
    .warning {{ padding: 10px 12px; border-left: 4px solid #d93025; background: #fce8e6; }}
    .table-wrap {{ overflow-x: auto; border: 1px solid #d9dce1; background: #fff; }}
    table {{ width: 100%; border-collapse: collapse; font-size: 14px; }}
    th, td {{ padding: 10px 12px; border-bottom: 1px solid #e5e7eb; text-align: left; vertical-align: top; }}
    th {{ position: sticky; top: 0; background: #eef1f5; white-space: nowrap; }}
    tbody tr:hover {{ background: #f8fafc; }}
    code {{ font-family: Consolas, monospace; font-weight: 700; }}
    a {{ color: #0b57d0; text-decoration: none; }}
    a:hover {{ text-decoration: underline; }}
    .badge {{ display: inline-block; margin-left: 8px; padding: 1px 5px; border: 1px solid #d93025; color: #b3261e; font-size: 12px; }}
    footer {{ margin-top: 14px; color: #6b7280; font-size: 13px; }}
    @media (max-width: 640px) {{ main {{ width: calc(100% - 20px); margin: 20px auto; }} h1 {{ font-size: 22px; }} th, td {{ padding: 8px; }} }}
  </style>
</head>
<body>
  <main>
    <h1>ZW-auto_lisp 命令索引</h1>
    <p class="meta">命令总数：<strong>{len(rows)}</strong>，覆盖 <strong>{len(files)}</strong> 个文件。</p>
    {duplicate_note}
    <div class="table-wrap">
      <table>
        <thead><tr><th>命令</th><th>文件</th><th>行号</th><th>功能</th></tr></thead>
        <tbody>{''.join(table_rows)}</tbody>
      </table>
    </div>
    <footer>本文件由 <code>gen_命令索引.py</code> 自动生成，请勿手工维护。</footer>
  </main>
</body>
</html>
'''

with open('命令索引.html', 'w', encoding='utf-8', newline='\n') as w:
    w.write(html_doc)

print(f'已生成 命令索引.md、命令索引.html：{len(rows)} 个命令，{len(files)} 个文件')
if dup:
    print('重复命令:', ', '.join(sorted(dup)))
