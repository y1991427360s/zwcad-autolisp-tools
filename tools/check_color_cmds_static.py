"""改色入口与颜色配置的离线 AST 检查，不连接 CAD。"""
import argparse
from pathlib import Path

from lsp_common import SOURCE, parse, walk


EXPECTED = {
    'ww': ('aa:color-cmd', '*ww_textcolor*', 7),
    'www': ('aa:deep-color-cmd', '*ww_textcolor*', 7),
    'pp': ('aa:color-cmd', '*pp_textcolor*', 6),
    'hh': ('aa:color-cmd', '*hui_textcolor*', 8),
    'hui': ('aa:deep-color-cmd', '*hui_textcolor*', 8),
    'gg': ('aa:color-cmd', '*gg_textcolor*', 3),
    'rr': ('aa:color-cmd', '*rr_textcolor*', 1),
    'yy': ('aa:color-cmd', '*yy_textcolor*', 2),
    'y': ('aa:color-cmd', '*y_textcolor*', 4),
}


def check(source=SOURCE, encoding=None):
    raw = Path(source).read_bytes()
    assert not raw.startswith(b'\xef\xbb\xbf'), 'BOM present'
    # 生产检查使用各平台公共读取器；显式编码仅供任务前备份反向验证。
    if encoding is None:
        from lsp_common import read_source
        _, text = read_source(Path(source))
    else:
        text = raw.decode(encoding, errors='strict')
    assert '\ufffd' not in text, 'Replacement character present'
    assert not set(raw.replace(b'\r\n', b'')) & {10, 13}, 'Mixed newlines'
    assert '*hh_textcolor*' not in text.lower(), 'Obsolete *HH_TextColor* remains'
    forms = parse(text)
    top = [f for f in forms if isinstance(f, list) and f[:1] == ['defun']]
    funcs = {f[1]: f for f in top}
    values = {}
    for form in forms:
        if isinstance(form, list) and form[:1] == ['setq']:
            for key, value in zip(form[1::2], form[2::2]):
                values.setdefault(key, []).append(value)
    required = {'*error*', 'aa:tag', 'aa:doc', 'aa:undo-open', 'aa:old-cmdecho'}
    for command, (helper, variable, color) in EXPECTED.items():
        name = 'c:' + command
        assert sum(f[1] == name for f in top) == 1, (name, 'not unique/top-level')
        form = funcs[name]
        signature = form[2]
        assert signature[0] == '/' and required <= set(signature[1:]), (name, 'locals')
        calls = [node for node in walk(form[3:]) if node and isinstance(node[0], str)]
        routes = [node for node in calls if node[0] in ('aa:color-cmd', 'aa:deep-color-cmd')]
        assert len(routes) == 1 and routes[0][0] == helper, (name, 'helper', routes)
        assert len(routes[0]) == 4 and routes[0][1] == variable, (name, 'color variable')
        assert values.get(variable) == [str(color)], (variable, values.get(variable))
        assert [node for node in calls if node[0] == 'aa:cmd-begin'] == [
            ['aa:cmd-begin', '"' + command.upper() + '"']], (name, 'begin')
        assert [node for node in calls if node[0] == 'aa:cmd-end'] == [['aa:cmd-end']], (name, 'end')
        assert form[3][0] == 'aa:cmd-begin' and form[-1] == ['aa:cmd-end'], (name, 'undo order')
        if command == 'www':
            assert ['sssetfirst', 'nil', 'nil'] in form[3:-1], 'WWW must clear selection'
    print('PASS color commands: WW/WWW/PP/HH/HUI/GG/RR/YY/Y; colors, helpers, top-level, locals, undo and selection cleanup')


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--source', type=Path, default=SOURCE)
    parser.add_argument('--encoding', choices=('utf-8', 'gbk'))
    args, _ = parser.parse_known_args()
    check(args.source, args.encoding)
