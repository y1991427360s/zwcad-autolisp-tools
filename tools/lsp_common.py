"""Shared AutoLISP parse helpers for offline static checks (no CAD)."""
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / 'AA整合版本.lsp'
TOKEN = re.compile(r';[^\n]*|"(?:\\.|[^"\\])*"|[()]|\x27|[^\s()\x27;]+')


def parse(text):
    tokens = iter(t for t in TOKEN.findall(text) if not t.startswith(';'))

    def item(token):
        if token == '(':
            result = []
            for token in tokens:
                if token == ')':
                    return result
                result.append(item(token))
            raise AssertionError('Unclosed list')
        if token == ')':
            raise AssertionError('Unexpected closing parenthesis')
        if token == "'":
            return ['quote', item(next(tokens))]
        return token.lower() if not token.startswith('"') else token

    return [item(token) for token in tokens]


ARITY = {
    'if': (2, 3), 'not': (1, 1), 'abs': (1, 1), 'car': (1, 1),
    'cdr': (1, 1), 'cadr': (1, 1), 'caddr': (1, 1), 'caar': (1, 1),
    'nth': (2, 2), 'cons': (2, 2), 'foreach': (3, 1000),
    'while': (2, 1000), 'trans': (3, 4), 'equal': (2, 3),
    'entmod': (1, 1), 'mapcar': (2, 1000),
}


def walk(node):
    if not isinstance(node, list) or not node:
        return
    yield node
    for child in node:
        yield from walk(child)


def read_source(path=None):
    raw = (path or SOURCE).read_bytes()
    if raw.startswith(b'\xef\xbb\xbf'):
        raise AssertionError('UTF-8 BOM present')
    try:
        text = raw.decode('utf-8', errors='strict')
    except UnicodeDecodeError as exc:
        raise AssertionError(f'UTF-8 decode failed: {exc}') from exc
    if '�' in text:
        raise AssertionError('Replacement character U+FFFD present')
    if b'\n' in raw.replace(b'\r\n', b''):
        raise AssertionError('Bare LF / mixed newlines')
    return raw, text


def defun_forms(forms):
    return [f for f in forms if isinstance(f, list) and f[:1] == ['defun']]


def command_names(forms):
    names = []
    for form in defun_forms(forms):
        name = form[1]
        if isinstance(name, str) and name.startswith('c:'):
            names.append(name[2:].upper())
    return names
