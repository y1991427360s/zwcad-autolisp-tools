"""Shared AutoLISP parse helpers for offline static checks (no CAD)."""
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / 'AA整合版本.lsp'
TOKEN = re.compile(r';[^\n]*|"(?:\\.|[^"\\])*"|[()]|\x27|[^\s()\x27;]+')


def parse(text):
    return parse_with_locations(text)[0]


def parse_with_locations(text):
    """Strict reader; locations maps list identity to (line, start, end).

    Preserve the historical list/string AST used by command checks. Unlike a
    regex tokenizer, reject unterminated strings and support ;| ... |; comments.
    """
    tokens = []
    i, line = 0, 1
    while i < len(text):
        ch = text[i]
        if ch.isspace():
            line += ch == '\n'
            i += 1
            continue
        if text.startswith(';|', i):
            start, depth = i, 1
            i += 2
            while i < len(text) and depth:
                if text.startswith(';|', i):
                    depth += 1
                    i += 2
                elif text.startswith('|;', i):
                    depth -= 1
                    i += 2
                else:
                    i += 1
            assert not depth, f'Unclosed block comment at line {line}'
            line += text[start:i].count('\n')
            continue
        if ch == ';':
            end = text.find('\n', i)
            i = len(text) if end < 0 else end
            continue
        start, start_line = i, line
        if ch == '"':
            i += 1
            while i < len(text):
                if text[i] == '\\':
                    i += 2
                elif text[i] == '"':
                    i += 1
                    break
                else:
                    i += 1
            else:
                raise AssertionError(f'Unclosed string at line {start_line}')
            assert i <= len(text), f'Unclosed string at line {start_line}'
            line += text[start:i].count('\n')
        elif ch in "()'":
            i += 1
        else:
            while i < len(text) and not text[i].isspace() and text[i] not in "()';\"":
                i += 1
        tokens.append((text[start:i], start_line, start, i))
    pos, locations = 0, {}

    def item():
        nonlocal pos
        assert pos < len(tokens), 'Quote without expression / unexpected EOF'
        token, ln, start, end = tokens[pos]
        pos += 1
        if token == '(':
            result = []
            while pos < len(tokens) and tokens[pos][0] != ')':
                result.append(item())
            assert pos < len(tokens), f'Unclosed list at line {ln}'
            end = tokens[pos][3]
            pos += 1
            locations[id(result)] = (ln, start, end)
            return result
        assert token != ')', f'Unexpected closing parenthesis at line {ln}'
        if token == "'":
            result = ['quote', item()]
            locations[id(result)] = (ln, start, tokens[pos - 1][3])
            return result
        return token if token.startswith('"') else token.lower()

    forms = []
    while pos < len(tokens):
        forms.append(item())
    return forms, locations


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
    if '\ufffd' in text:
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
