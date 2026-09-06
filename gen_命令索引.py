# -*- coding: utf-8 -*-
"""
递归扫描并生成 ZW-auto_lisp 命令索引（Markdown 与 HTML 双版本）。
用法：
  python gen_命令索引.py         # 重新扫描并生成 命令索引.md 和 命令索引.html
  python gen_命令索引.py --check # 校验编码、换行、命令完整性与索引一致性
"""
import argparse
import html
import json
import re
import sys
from collections import Counter
from pathlib import Path

ROOT = Path(__file__).resolve().parent
MAIN = ROOT / 'AA整合版本.lsp'
EXCLUDED = {'.git', '.svn', '__pycache__', 'node_modules'}

AICAD_DEFAULTS = {
    'AICAD': '根据自然语言指令或对话修改选中的 CAD 对象',
    'ASCAD': 'AICAD 启动命令别名',
    'AICADRIBBON': '执行 Ribbon 功能区输入框中提交的自然语言指令',
    'AICADRIBBONREPLACE': '执行 Ribbon 替换面板中的批量查找替换',
    'AICADRIBBONFIND': '执行 Ribbon 查找面板中的文字查找与定位',
    'AICADRIBBONFOCUSMATCH': '聚焦并定位 Ribbon 查找匹配的目标图元',
    'AICADCLEANUI': '清理残留的旧版临时 UI 与界面元素',
    'LOADAICADAA': '加载并初始化 AICAD Ribbon 功能区面板',
    'LOADAICADZW': '加载并初始化 AICAD Ribbon 功能区面板（别名）',
    'AICADREPLACEPANELSHOW': '打开 AICAD 查找替换浮动面板',
    'UNLOAD_AICAD': '卸载 AICAD 扩展插件及注册环境',
    'UNLOAD_AA': '卸载 AICAD 扩展插件（别名）',
    'UNLOAD_XXX': '卸载 AICAD 扩展插件（别名）',
}

def files():
    out = []
    for p in ROOT.rglob('*.lsp'):
        rel = p.relative_to(ROOT)
        low = p.name.lower()
        if any(x.lower() in EXCLUDED for x in rel.parts[:-1]) or '.bak' in low or '副本' in p.name or low.startswith(('backup', '备份')):
            continue
        out.append(p)
    return sorted(out, key=lambda p: p.as_posix().lower())

def text(p):
    return p.read_bytes().decode('utf-8')

def clean_desc(txt, cmd):
    if not txt:
        return ''
    txt = txt.strip().strip(';').strip()
    # 过滤纯符号分隔线 (如 ======, ------, ****** 等)
    if re.fullmatch(r'[=\-\*#_~`\s]+', txt):
        return ''
    # 过滤代码行注释
    if txt.startswith('(') or 'defun' in txt.lower():
        return ''
    # 过滤 "功能: ", "说明: ", "命令: " 等前缀
    txt = re.sub(r'^(?:功能|说明|作用|描述|命令|Function|Command)\s*[:：]\s*', '', txt, flags=re.I)
    txt = re.sub(r'^命令\s*\d+\s*(?:\([^)]*\))?\s*[:：]\s*', '', txt, flags=re.I)
    # 过滤 "CMD: " 或 "CMD - " 前缀
    txt = re.sub(rf'^{re.escape(cmd)}\s*[:：\-]\s*', '', txt, flags=re.I)
    if txt.upper().startswith(cmd + ' '):
        txt = txt[len(cmd):].strip()
    # 过滤无意义的占位词
    if txt in ('主命令', '调试命令', '测试命令') or re.fullmatch(rf'{re.escape(cmd)}', txt, re.I):
        return ''
    return txt.strip()

def extract(p, hints):
    ls = text(p).splitlines()
    out = []
    for i, line in enumerate(ls):
        m = re.match(r'\s*\(defun\s+c:([A-Za-z0-9_]+)', line, re.I)
        if not m:
            continue
        n = m.group(1).upper()
        d = ''
        for j in range(i - 1, max(i - 8, -1), -1):
            s = ls[j].strip()
            if not s:
                continue
            if not s.startswith(';'):
                break
            c = clean_desc(s, n)
            if c:
                d = c
                break
        final_desc = hints.get(n, '') or d
        out.append((n, p.relative_to(ROOT).as_posix(), i + 1, final_desc))
    return out

def scan():
    fs = files()
    hints = dict(AICAD_DEFAULTS)
    for p in fs:
        content = text(p)
        header_part = content.split('(defun', 1)[0]
        for m in re.finditer(r'^;;;\s*-\s*([A-Za-z0-9_]+)\s*[:：]\s*(.+)$', header_part, re.M):
            n, d = m.group(1).upper(), m.group(2).strip()
            if n and d:
                hints.setdefault(n, d)
        for m in re.finditer(r'\[([A-Za-z0-9]+)(?:\]\s*/\s*\[([A-Za-z0-9]+))?\]\s*-\s*([^"\)\r\n]+)', content):
            for n in m.group(1, 2):
                if n:
                    hints.setdefault(n.upper(), m.group(3).strip())
    rows = [r for p in fs for r in extract(p, hints)]
    ribbon = ROOT / 'V6' / 'AICADRibbon' / 'AiRibbonPlugin.cs'
    if ribbon.exists():
        for i, line in enumerate(text(ribbon).splitlines(), 1):
            if re.search(r'\[CommandMethod\("DWGWIN"', line):
                rows.append(('DWGWIN', ribbon.relative_to(ROOT).as_posix(), i,
                             '打开单实例图纸窗口管理器，汇总本机当前会话所有中望CAD图纸并跨进程切换。'))
                fs.append(ribbon)
    rows.sort(key=lambda r: (r[0], r[1], r[2]))
    return fs, rows

def build_html(fs, rows, dup):
    total = len(rows)
    aa_count = sum(1 for r in rows if 'AA' in r[1])
    aicad_count = total - aa_count

    rows_data = []
    table_rows_html = []
    for n, f, ln, d in rows:
        cat = 'aa' if 'AA' in f else 'aicad'
        tag_class = 'aa' if cat == 'aa' else 'aicad'
        tag_text = 'AA核心' if cat == 'aa' else 'AICAD'
        is_dup = n in dup
        desc_str = d or ''

        rows_data.append({
            'cmd': n,
            'file': f,
            'line': ln,
            'desc': desc_str,
            'cat': cat,
            'dup': is_dup
        })

        dup_badge = '<span class="badge-dup" title="重复定义命令">重复</span>' if is_dup else ''
        table_rows_html.append(
            f'<tr>'
            f'<td class="td-cmd">'
            f'<span class="cmd-badge" onclick="copyCommand(\'{html.escape(n)}\')" title="点击复制命令">'
            f'<code>{html.escape(n)}</code>{dup_badge}'
            f'</span>'
            f'</td>'
            f'<td class="td-file">'
            f'<span class="file-tag {tag_class}">{tag_text}</span>'
            f'<div class="file-name">{html.escape(f)}</div>'
            f'</td>'
            f'<td class="td-line">{ln}</td>'
            f'<td class="td-desc">{html.escape(desc_str)}</td>'
            f'<td class="td-action">'
            f'<button class="copy-btn" onclick="copyCommand(\'{html.escape(n)}\')" title="复制命令">复制</button>'
            f'</td>'
            f'</tr>'
        )

    json_payload = json.dumps(rows_data, ensure_ascii=False).replace('</script>', '<\\/script>')
    tbody_content = '\n'.join(table_rows_html)

    html_code = f"""<!doctype html>
<html lang="zh-CN">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>ZW-auto_lisp 命令索引</title>
  <style>
    :root {{
      --bg-primary: #f8fafc;
      --bg-card: #ffffff;
      --border-color: #e2e8f0;
      --border-focus: #3b82f6;
      --text-main: #0f172a;
      --text-muted: #64748b;
      --text-sub: #334155;
      --primary: #2563eb;
      --primary-light: #eff6ff;
      --primary-hover: #1d4ed8;
      --badge-aa-bg: #e0f2fe;
      --badge-aa-text: #0369a1;
      --badge-aicad-bg: #f3e8ff;
      --badge-aicad-text: #7e22ce;
      --row-hover: #f1f5f9;
      --code-bg: #f1f5f9;
      --code-text: #0f172a;
      --highlight: #fef08a;
      --shadow-sm: 0 1px 2px 0 rgba(0, 0, 0, 0.05);
      --shadow-md: 0 4px 6px -1px rgba(0, 0, 0, 0.07), 0 2px 4px -2px rgba(0, 0, 0, 0.05);
      --shadow-lg: 0 10px 15px -3px rgba(0, 0, 0, 0.07), 0 4px 6px -4px rgba(0, 0, 0, 0.05);
    }}

    @media (prefers-color-scheme: dark) {{
      :root {{
        --bg-primary: #0f172a;
        --bg-card: #1e293b;
        --border-color: #334155;
        --border-focus: #60a5fa;
        --text-main: #f8fafc;
        --text-muted: #94a3b8;
        --text-sub: #cbd5e1;
        --primary: #3b82f6;
        --primary-light: #1e3a8a;
        --primary-hover: #60a5fa;
        --badge-aa-bg: #082f49;
        --badge-aa-text: #38bdf8;
        --badge-aicad-bg: #3b0764;
        --badge-aicad-text: #c084fc;
        --row-hover: #293548;
        --code-bg: #334155;
        --code-text: #f8fafc;
        --highlight: #854d0e;
      }}
    }}

    * {{ box-sizing: border-box; margin: 0; padding: 0; }}
    body {{
      font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "PingFang SC", "Hiragino Sans GB", "Microsoft YaHei", sans-serif;
      background-color: var(--bg-primary);
      color: var(--text-main);
      line-height: 1.5;
      padding: 24px 16px 60px;
    }}

    .container {{
      max-width: 1280px;
      margin: 0 auto;
    }}

    /* Header */
    header {{
      margin-bottom: 24px;
    }}
    .header-top {{
      display: flex;
      align-items: center;
      justify-content: space-between;
      flex-wrap: wrap;
      gap: 16px;
      margin-bottom: 14px;
    }}
    .title-group {{
      display: flex;
      align-items: center;
      gap: 12px;
    }}
    .logo-icon {{
      display: inline-flex;
      align-items: center;
      justify-content: center;
      width: 36px;
      height: 36px;
      border-radius: 10px;
      background: var(--primary);
      color: #fff;
      font-size: 18px;
      font-weight: 700;
    }}
    h1 {{
      font-size: 26px;
      font-weight: 700;
      letter-spacing: -0.02em;
    }}
    .version-pill {{
      font-size: 12px;
      padding: 3px 10px;
      border-radius: 9999px;
      background: var(--primary-light);
      color: var(--primary);
      font-weight: 600;
    }}

    .stats-bar {{
      display: flex;
      flex-wrap: wrap;
      gap: 10px;
      font-size: 13px;
      color: var(--text-muted);
    }}
    .stat-badge {{
      display: inline-flex;
      align-items: center;
      gap: 6px;
      background: var(--bg-card);
      padding: 6px 12px;
      border-radius: 8px;
      border: 1px solid var(--border-color);
      box-shadow: var(--shadow-sm);
    }}
    .stat-badge strong {{
      color: var(--text-main);
    }}

    /* Toolbar */
    .toolbar {{
      background: var(--bg-card);
      border: 1px solid var(--border-color);
      border-radius: 12px;
      padding: 16px;
      margin-bottom: 20px;
      box-shadow: var(--shadow-sm);
      display: flex;
      flex-direction: column;
      gap: 14px;
    }}
    .search-row {{
      display: flex;
      gap: 12px;
      align-items: center;
    }}
    .search-box-wrap {{
      position: relative;
      flex: 1;
    }}
    .search-icon {{
      position: absolute;
      left: 14px;
      top: 50%;
      transform: translateY(-50%);
      color: var(--text-muted);
      font-size: 15px;
      pointer-events: none;
    }}
    .search-input {{
      width: 100%;
      height: 44px;
      padding: 8px 40px 8px 38px;
      border-radius: 8px;
      border: 1px solid var(--border-color);
      background: var(--bg-primary);
      color: var(--text-main);
      font-size: 14px;
      outline: none;
      transition: border-color 0.15s, box-shadow 0.15s;
    }}
    .search-input:focus {{
      border-color: var(--border-focus);
      box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.15);
      background: var(--bg-card);
    }}
    .clear-btn {{
      position: absolute;
      right: 12px;
      top: 50%;
      transform: translateY(-50%);
      background: none;
      border: none;
      color: var(--text-muted);
      font-size: 16px;
      cursor: pointer;
      display: none;
      padding: 4px;
      line-height: 1;
    }}
    .clear-btn:hover {{ color: var(--text-main); }}

    .filter-row {{
      display: flex;
      align-items: center;
      justify-content: space-between;
      flex-wrap: wrap;
      gap: 12px;
    }}
    .tab-group {{
      display: inline-flex;
      gap: 6px;
      background: var(--bg-primary);
      padding: 4px;
      border-radius: 8px;
      border: 1px solid var(--border-color);
    }}
    .tab-btn {{
      padding: 6px 14px;
      font-size: 13px;
      font-weight: 500;
      border-radius: 6px;
      border: none;
      background: transparent;
      color: var(--text-muted);
      cursor: pointer;
      transition: all 0.15s;
    }}
    .tab-btn:hover {{
      color: var(--text-main);
    }}
    .tab-btn.active {{
      background: var(--bg-card);
      color: var(--primary);
      font-weight: 600;
      box-shadow: var(--shadow-sm);
    }}
    .result-info {{
      font-size: 13px;
      color: var(--text-muted);
    }}
    .result-info strong {{
      color: var(--primary);
      font-size: 14px;
    }}

    /* Table Container */
    .table-card {{
      background: var(--bg-card);
      border: 1px solid var(--border-color);
      border-radius: 12px;
      box-shadow: var(--shadow-md);
      overflow: hidden;
    }}
    .table-wrap {{
      overflow-x: auto;
      max-height: calc(100vh - 280px);
    }}
    table {{
      width: 100%;
      border-collapse: collapse;
      text-align: left;
      font-size: 14px;
    }}
    thead th {{
      position: sticky;
      top: 0;
      z-index: 10;
      background: var(--bg-primary);
      color: var(--text-muted);
      font-weight: 600;
      font-size: 12px;
      text-transform: uppercase;
      letter-spacing: 0.04em;
      padding: 12px 16px;
      border-bottom: 1px solid var(--border-color);
      white-space: nowrap;
    }}
    tbody tr {{
      border-bottom: 1px solid var(--border-color);
      transition: background-color 0.1s;
    }}
    tbody tr:last-child {{
      border-bottom: none;
    }}
    tbody tr:hover {{
      background-color: var(--row-hover);
    }}

    td {{
      padding: 12px 16px;
      vertical-align: middle;
    }}

    /* Table Columns */
    .td-cmd {{
      width: 150px;
      white-space: nowrap;
    }}
    .cmd-badge {{
      display: inline-flex;
      align-items: center;
      gap: 6px;
      padding: 4px 10px;
      background: var(--code-bg);
      border: 1px solid var(--border-color);
      color: var(--code-text);
      font-family: "Cascadia Code", Consolas, "Courier New", monospace;
      font-weight: 700;
      font-size: 14px;
      border-radius: 6px;
      cursor: pointer;
      user-select: all;
      transition: all 0.15s;
    }}
    .cmd-badge code {{
      font-family: inherit;
    }}
    .cmd-badge:hover {{
      border-color: var(--primary);
      color: var(--primary);
      transform: translateY(-1px);
      box-shadow: var(--shadow-sm);
    }}
    .cmd-badge:active {{
      transform: translateY(0);
    }}

    .badge-dup {{
      display: inline-block;
      font-size: 11px;
      padding: 1px 4px;
      border-radius: 4px;
      background: #fee2e2;
      color: #b91c1c;
      font-weight: 600;
      margin-left: 4px;
    }}

    .td-file {{
      width: 200px;
      white-space: nowrap;
    }}
    .file-tag {{
      display: inline-flex;
      align-items: center;
      gap: 4px;
      padding: 2px 8px;
      border-radius: 6px;
      font-size: 12px;
      font-weight: 500;
    }}
    .file-tag.aa {{
      background: var(--badge-aa-bg);
      color: var(--badge-aa-text);
    }}
    .file-tag.aicad {{
      background: var(--badge-aicad-bg);
      color: var(--badge-aicad-text);
    }}
    .file-name {{
      font-size: 12px;
      color: var(--text-muted);
      margin-top: 3px;
      font-family: Consolas, monospace;
    }}

    .td-line {{
      width: 80px;
      color: var(--text-muted);
      font-size: 13px;
      font-family: Consolas, monospace;
      white-space: nowrap;
    }}

    .td-desc {{
      color: var(--text-sub);
      line-height: 1.6;
    }}

    .td-action {{
      width: 80px;
      text-align: center;
      white-space: nowrap;
    }}
    .copy-btn {{
      padding: 4px 10px;
      font-size: 12px;
      border: 1px solid var(--border-color);
      border-radius: 6px;
      background: var(--bg-card);
      color: var(--text-muted);
      cursor: pointer;
      transition: all 0.15s;
    }}
    .copy-btn:hover {{
      border-color: var(--primary);
      color: var(--primary);
      background: var(--primary-light);
    }}

    /* Highlight */
    mark {{
      background: var(--highlight);
      color: inherit;
      padding: 0 2px;
      border-radius: 2px;
    }}

    /* Empty state */
    .empty-state {{
      padding: 60px 20px;
      text-align: center;
      color: var(--text-muted);
    }}
    .empty-state-icon {{
      font-size: 40px;
      margin-bottom: 12px;
      opacity: 0.6;
    }}
    .empty-state-text {{
      font-size: 15px;
    }}

    /* Toast */
    .toast {{
      position: fixed;
      bottom: 24px;
      left: 50%;
      transform: translateX(-50%) translateY(100px);
      background: #1e293b;
      color: #ffffff;
      padding: 10px 20px;
      border-radius: 8px;
      font-size: 14px;
      font-weight: 500;
      box-shadow: var(--shadow-lg);
      z-index: 1000;
      opacity: 0;
      transition: all 0.25s cubic-bezier(0.16, 1, 0.3, 1);
      display: flex;
      align-items: center;
      gap: 8px;
      pointer-events: none;
    }}
    .toast.show {{
      transform: translateX(-50%) translateY(0);
      opacity: 1;
    }}

    /* Footer */
    footer {{
      margin-top: 24px;
      text-align: center;
      font-size: 13px;
      color: var(--text-muted);
    }}
    footer code {{
      font-family: Consolas, monospace;
      color: var(--primary);
    }}

    @media (max-width: 768px) {{
      body {{ padding: 16px 10px; }}
      h1 {{ font-size: 20px; }}
      .toolbar {{ padding: 12px; }}
      .filter-row {{ flex-direction: column; align-items: flex-start; }}
      .tab-group {{ width: 100%; justify-content: space-between; }}
      .td-action {{ display: none; }}
      thead th:last-child {{ display: none; }}
    }}
  </style>
</head>
<body>
  <div class="container">
    <header>
      <div class="header-top">
        <div class="title-group">
          <span class="logo-icon">ZW</span>
          <h1>ZW-auto_lisp 命令索引</h1>
          <span class="version-pill">ZWCAD 2026</span>
        </div>
        <div class="stats-bar">
          <div class="stat-badge"><span>总命令数:</span> <strong>{total}</strong></div>
          <div class="stat-badge"><span>AA核心工具:</span> <strong>{aa_count}</strong></div>
          <div class="stat-badge"><span>AICAD扩展:</span> <strong>{aicad_count}</strong></div>
          <div class="stat-badge"><span>覆盖源码:</span> <strong>{len(fs)} 个文件</strong></div>
        </div>
      </div>
    </header>

    <div class="toolbar">
      <div class="search-row">
        <div class="search-box-wrap">
          <span class="search-icon">🔍</span>
          <input type="text" id="searchInput" class="search-input" placeholder="输入命令名、功能描述、源文件 (按 / 聚焦，按 Esc 清空)..." autofocus autocomplete="off">
          <button id="clearBtn" class="clear-btn" title="清空搜索">✕</button>
        </div>
      </div>
      <div class="filter-row">
        <div class="tab-group" id="filterTabs">
          <button class="tab-btn active" data-filter="all">全部 ({total})</button>
          <button class="tab-btn" data-filter="aa">AA核心常用 ({aa_count})</button>
          <button class="tab-btn" data-filter="aicad">AICAD扩展 ({aicad_count})</button>
        </div>
        <div class="result-info">
          显示 <strong id="visibleCount">{total}</strong> / {total} 个命令
        </div>
      </div>
    </div>

    <div class="table-card">
      <div class="table-wrap">
        <table>
          <thead>
            <tr>
              <th>命令</th>
              <th>分类 / 文件</th>
              <th>行号</th>
              <th>功能说明</th>
              <th class="td-action">操作</th>
            </tr>
          </thead>
          <tbody id="tableBody">
{tbody_content}
          </tbody>
        </table>
        <div id="emptyState" class="empty-state" style="display: none;">
          <div class="empty-state-icon">🔎</div>
          <div class="empty-state-text">未找到与关键词匹配的命令</div>
        </div>
      </div>
    </div>

    <footer>
      本文件由 <code>gen_命令索引.py</code> 自动生成，请勿手工维护。每次修改或新增 LISP 命令后运行脚本自动更新。
    </footer>
  </div>

  <div id="toast" class="toast">✓ 命令已复制到剪贴板</div>

  <script>
    const COMMANDS = {json_payload};
    let currentFilter = 'all';
    let searchQuery = '';

    const searchInput = document.getElementById('searchInput');
    const clearBtn = document.getElementById('clearBtn');
    const filterTabs = document.getElementById('filterTabs');
    const tableBody = document.getElementById('tableBody');
    const emptyState = document.getElementById('emptyState');
    const visibleCount = document.getElementById('visibleCount');
    const toast = document.getElementById('toast');

    function escapeHtml(text) {{
      return (text || '')
        .replace(/&/g, '&amp;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;')
        .replace(/"/g, '&quot;')
        .replace(/'/g, '&#039;');
    }}

    function highlightText(text, query) {{
      const safeText = escapeHtml(text);
      if (!query) return safeText;
      const q = query.toLowerCase();
      const lower = safeText.toLowerCase();
      const idx = lower.indexOf(q);
      if (idx === -1) return safeText;
      return safeText.substring(0, idx) + '<mark>' + safeText.substring(idx, idx + q.length) + '</mark>' + safeText.substring(idx + q.length);
    }}

    let toastTimer = null;
    function showToast(text) {{
      toast.textContent = text;
      toast.classList.add('show');
      if (toastTimer) clearTimeout(toastTimer);
      toastTimer = setTimeout(() => toast.classList.remove('show'), 1800);
    }}

    function copyCommand(cmd) {{
      if (navigator.clipboard && navigator.clipboard.writeText) {{
        navigator.clipboard.writeText(cmd).then(() => {{
          showToast('✓ 已复制命令: ' + cmd);
        }}).catch(() => {{
          fallbackCopy(cmd);
        }});
      }} else {{
        fallbackCopy(cmd);
      }}
    }}

    function fallbackCopy(cmd) {{
      const input = document.createElement('input');
      input.value = cmd;
      document.body.appendChild(input);
      input.select();
      document.execCommand('copy');
      document.body.removeChild(input);
      showToast('✓ 已复制命令: ' + cmd);
    }}

    function renderTable() {{
      const query = searchQuery.trim().toLowerCase();
      const filtered = COMMANDS.filter(item => {{
        if (currentFilter !== 'all' && item.cat !== currentFilter) return false;
        if (!query) return true;
        return item.cmd.toLowerCase().includes(query) ||
               item.desc.toLowerCase().includes(query) ||
               item.file.toLowerCase().includes(query) ||
               String(item.line).includes(query);
      }});

      visibleCount.textContent = filtered.length;

      if (filtered.length === 0) {{
        tableBody.innerHTML = '';
        emptyState.style.display = 'block';
        return;
      }}

      emptyState.style.display = 'none';

      const rowsHtml = filtered.map(item => {{
        const isAA = item.cat === 'aa';
        const tagClass = isAA ? 'aa' : 'aicad';
        const tagText = isAA ? 'AA核心' : 'AICAD';
        const dupBadge = item.dup ? '<span class="badge-dup" title="重复定义命令">重复</span>' : '';
        const cmdHighlighted = highlightText(item.cmd, query);
        const descHighlighted = highlightText(item.desc, query);
        const fileHighlighted = highlightText(item.file, query);

        return `
          <tr>
            <td class="td-cmd">
              <span class="cmd-badge" onclick="copyCommand('${{item.cmd}}')" title="点击复制命令">
                <code>${{cmdHighlighted}}</code>${{dupBadge}}
              </span>
            </td>
            <td class="td-file">
              <span class="file-tag ${{tagClass}}">${{tagText}}</span>
              <div class="file-name">${{fileHighlighted}}</div>
            </td>
            <td class="td-line">${{item.line}}</td>
            <td class="td-desc">${{descHighlighted}}</td>
            <td class="td-action">
              <button class="copy-btn" onclick="copyCommand('${{item.cmd}}')" title="复制命令">复制</button>
            </td>
          </tr>
        `;
      }}).join('');

      tableBody.innerHTML = rowsHtml;
    }}

    // Search input events
    searchInput.addEventListener('input', (e) => {{
      searchQuery = e.target.value;
      clearBtn.style.display = searchQuery ? 'block' : 'none';
      renderTable();
    }});

    clearBtn.addEventListener('click', () => {{
      searchInput.value = '';
      searchQuery = '';
      clearBtn.style.display = 'none';
      searchInput.focus();
      renderTable();
    }});

    // Tab filter events
    filterTabs.addEventListener('click', (e) => {{
      const btn = e.target.closest('.tab-btn');
      if (!btn) return;
      filterTabs.querySelectorAll('.tab-btn').forEach(b => b.classList.remove('active'));
      btn.classList.add('active');
      currentFilter = btn.dataset.filter;
      renderTable();
    }});

    // Global keyboard shortcuts
    window.addEventListener('keydown', (e) => {{
      if (e.key === '/' && document.activeElement !== searchInput) {{
        e.preventDefault();
        searchInput.focus();
        searchInput.select();
      }} else if ((e.ctrlKey || e.metaKey) && e.key.toLowerCase() === 'k') {{
        e.preventDefault();
        searchInput.focus();
        searchInput.select();
      }} else if (e.key === 'Escape') {{
        if (searchInput.value) {{
          searchInput.value = '';
          searchQuery = '';
          clearBtn.style.display = 'none';
          renderTable();
        }}
        searchInput.blur();
      }}
    }});
  </script>
</body>
</html>
"""
    return html_code

def generate(fs, rows):
    dup = {n for n, c in Counter(r[0] for r in rows).items() if c > 1}
    aa_count = sum(1 for r in rows if 'AA' in r[1])
    aicad_count = len(rows) - aa_count

    # 生成 Markdown 索引
    lines = [
        '# ZW-auto_lisp 命令索引',
        '',
        '> 本文件与 `命令索引.html` 均由 `gen_命令索引.py` 自动生成，请勿手工维护。',
        '> 每次新增、修改、删除或改名 AutoLISP 命令后，在项目根目录运行 `python gen_命令索引.py` 同时重新生成两份索引。',
        '',
        f'- 命令总数：**{len(rows)}**，覆盖 **{len(fs)}** 个文件。',
        f'- AA核心常用工具：**{aa_count}** 个，AICAD扩展：**{aicad_count}** 个。',
    ]
    if dup:
        lines.append(f'- ⚠️ 重复定义命令（多个文件同名，注意加载顺序）：**{", ".join(sorted(dup))}**')

    lines.extend([
        '',
        '| 命令 | 文件 | 行号 | 功能 |',
        '|------|------|------|------|'
    ])
    for n, f, ln, d in rows:
        flag = ' ⚠️' if n in dup else ''
        desc_escaped = (d or '').replace('|', '\\|')
        lines.append(f"| `{n}`{flag} | {f} | {ln} | {desc_escaped} |")

    md_path = ROOT / '命令索引.md'
    md_content = '\r\n'.join(lines) + '\r\n'
    md_path.write_bytes(md_content.encode('utf-8'))

    # 生成 HTML 索引
    html_path = ROOT / '命令索引.html'
    html_content = build_html(fs, rows, dup)
    html_crlf = html_content.replace('\r\n', '\n').replace('\r', '\n').replace('\n', '\r\n')
    html_path.write_bytes(html_crlf.encode('utf-8'))

    print(f'已生成 命令索引.md、命令索引.html：{len(rows)} 个命令，覆盖 {len(fs)} 个源文件')
    if dup:
        print('重复定义命令:', ', '.join(sorted(dup)))

def check(fs, rows):
    errors = []
    for p in fs:
        b = p.read_bytes()
        rel = p.relative_to(ROOT)
        if b.startswith(b'\xef\xbb\xbf'):
            errors.append(f'{rel}: 含 UTF-8 BOM')
        try:
            b.decode('utf-8')
        except UnicodeDecodeError as e:
            errors.append(f'{rel}: UTF-8 解码失败 ({e})')
            continue
        if b'\xef\xbf\xbd' in b:
            errors.append(f'{rel}: 含替换字符 U+FFFD')
        if b'\n' in b and b'\r\n' not in b:
            errors.append(f'{rel}: 未使用 CRLF 换行')
        if b'\r\r\n' in b or re.search(rb'(?<!\r)\n', b):
            errors.append(f'{rel}: 存在混合换行')
    actual = {n for n, *_ in rows}
    if MAIN.exists():
        main_actual = {n for n, *_ in extract(MAIN, {})}
        h = text(MAIN).split('(defun', 1)[0]
        listed = {m.group(1).upper() for m in re.finditer(r'^;;;\s*-\s*([A-Za-z0-9_]+)\s*:', h, re.M)}
        if main_actual - listed:
            errors.append('AA整合版本.lsp 头部命令清单缺少：' + ', '.join(sorted(main_actual - listed)))
        if listed - main_actual:
            errors.append('AA整合版本.lsp 头部命令清单残留已删除命令：' + ', '.join(sorted(listed - main_actual)))
    md = ROOT / '命令索引.md'
    html_file = ROOT / '命令索引.html'
    if not md.exists() or not html_file.exists():
        errors.append('命令索引文件不存在，请先运行生成模式')
    else:
        md_commands = {
            line.split('`')[1].split('`')[0].replace(' ⚠️', '')
            for line in md.read_text(encoding='utf-8').splitlines()
            if line.startswith('| `') and '` |' in line
        }
        if md_commands != actual:
            errors.append('命令索引.md 与实际 defun c: 命令不一致')

        html_bytes = html_file.read_bytes()
        if html_bytes.startswith(b'\xef\xbb\xbf'):
            errors.append('命令索引.html: 含 UTF-8 BOM')
        if b'\xef\xbf\xbd' in html_bytes:
            errors.append('命令索引.html: 含替换字符 U+FFFD')

    if errors:
        print('检查失败：\n- ' + '\n- '.join(errors))
        return 1
    print(f'检查通过：{len(rows)} 个命令，{len(fs)} 个源文件')
    return 0

if __name__ == '__main__':
    ap = argparse.ArgumentParser(description='ZW-auto_lisp 命令索引生成与校验工具')
    ap.add_argument('--check', action='store_true', help='执行编码、换行及命令一致性检查')
    a = ap.parse_args()
    fs, rows = scan()
    if a.check:
        sys.exit(check(fs, rows))
    else:
        generate(fs, rows)
        sys.exit(0)
