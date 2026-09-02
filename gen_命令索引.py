# -*- coding: utf-8 -*-
"""递归生成或检查 ZW-auto_lisp 命令索引。"""
import argparse, html, re, sys
from collections import Counter
from pathlib import Path

ROOT = Path(__file__).resolve().parent
MAIN = ROOT / 'AA整合版本.lsp'
EXCLUDED = {'.git', '.svn', '__pycache__', 'node_modules'}

def files():
    out = []
    for p in ROOT.rglob('*.lsp'):
        rel = p.relative_to(ROOT)
        low = p.name.lower()
        if any(x.lower() in EXCLUDED for x in rel.parts[:-1]) or '.bak' in low or '副本' in p.name or low.startswith(('backup','备份')):
            continue
        out.append(p)
    return sorted(out, key=lambda p: p.as_posix().lower())

def text(p): return p.read_bytes().decode('utf-8')

def extract(p, hints):
    ls, out = text(p).splitlines(), []
    for i, line in enumerate(ls):
        m = re.match(r'\s*\(defun\s+c:([A-Za-z0-9_]+)', line, re.I)
        if not m: continue
        n, d = m.group(1).upper(), ''
        for j in range(i - 1, max(i - 8, -1), -1):
            s = ls[j].strip()
            if not s: continue
            if not s.startswith(';'): break
            c = s.lstrip(';').strip().strip('-').strip()
            if c and c.upper() != n: d = c; break
        out.append((n, p.relative_to(ROOT).as_posix(), i + 1, d or hints.get(n, '')))
    return out

def scan():
    fs, hints = files(), {}
    for p in fs:
        for m in re.finditer(r'\[([A-Za-z0-9]+)(?:\]\s*/\s*\[([A-Za-z0-9]+))?\]\s*-\s*([^"\)\r\n]+)', text(p)):
            for n in m.group(1, 2):
                if n: hints.setdefault(n.upper(), m.group(3).strip())
    return fs, sorted((r for p in fs for r in extract(p, hints)), key=lambda r: (r[0], r[1], r[2]))

def generate(fs, rows):
    dup = {n for n,c in Counter(r[0] for r in rows).items() if c > 1}
    lines = ['# ZW-auto_lisp 命令索引', '', '> 本文件由 `gen_命令索引.py` 自动生成，请勿手工维护。', '', f'- 命令总数：**{len(rows)}**，覆盖 **{len(fs)}** 个文件。', '', '| 命令 | 文件 | 行号 | 功能 |', '|------|------|------|------|']
    for n,f,ln,d in rows: lines.append(f"| `{n}`{' ⚠️' if n in dup else ''} | {f} | {ln} | {(d or '').replace('|','\\|')} |")
    (ROOT/'命令索引.md').write_bytes(('\r\n'.join(lines)+'\r\n').encode('utf-8'))
    body = ''.join(f'<tr><td><code>{html.escape(n)}</code></td><td>{html.escape(f)}</td><td>{ln}</td><td>{html.escape(d or "")}</td></tr>' for n,f,ln,d in rows)
    (ROOT/'命令索引.html').write_text(f'<!doctype html><meta charset="utf-8"><title>ZW-auto_lisp 命令索引</title><h1>ZW-auto_lisp 命令索引</h1><p>命令总数：{len(rows)}，覆盖 {len(fs)} 个文件。</p><table><tr><th>命令</th><th>文件</th><th>行号</th><th>功能</th></tr>{body}</table>', encoding='utf-8', newline='\n')

def check(fs, rows):
    errors=[]
    for p in fs:
        b=p.read_bytes(); rel=p.relative_to(ROOT)
        if b.startswith(b'\xef\xbb\xbf'): errors.append(f'{rel}: 含 UTF-8 BOM')
        try: b.decode('utf-8')
        except UnicodeDecodeError as e: errors.append(f'{rel}: UTF-8 解码失败 ({e})'); continue
        if b'\xef\xbf\xbd' in b: errors.append(f'{rel}: 含替换字符 U+FFFD')
        if b'\n' in b and b'\r\n' not in b: errors.append(f'{rel}: 未使用 CRLF 换行')
        if b'\r\r\n' in b or re.search(rb'(?<!\r)\n', b): errors.append(f'{rel}: 存在混合换行')
    actual={n for n,*_ in rows}
    if MAIN.exists():
        main_actual={n for n,*_ in (extract(MAIN, {}))}
        h=text(MAIN).split('(defun',1)[0]
        listed={m.group(1).upper() for m in re.finditer(r'^;;;\s*-\s*([A-Za-z0-9_]+)\s*:', h, re.M)}
        if main_actual-listed: errors.append('AA整合版本.lsp 头部命令清单缺少：'+', '.join(sorted(main_actual-listed)))
    md=ROOT/'命令索引.md'
    if not md.exists() or not (ROOT/'命令索引.html').exists(): errors.append('命令索引文件不存在，请先运行生成模式')
    elif {line.split('`')[1].split('`')[0].replace(' ⚠️', '') for line in md.read_text(encoding='utf-8').splitlines() if line.startswith('| `') and '` |' in line} != actual:
        errors.append('命令索引.md 与实际 defun c: 命令不一致')
    if errors: print('检查失败：\n- '+'\n- '.join(errors)); return 1
    print(f'检查通过：{len(rows)} 个命令，{len(fs)} 个 LISP 文件'); return 0

if __name__ == '__main__':
    ap=argparse.ArgumentParser(); ap.add_argument('--check',action='store_true'); a=ap.parse_args(); fs,rows=scan(); sys.exit(check(fs,rows) if a.check else (generate(fs,rows) or 0))
