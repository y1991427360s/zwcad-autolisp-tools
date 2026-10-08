"""Execute TBHB geometry helpers with all 195 supplied QW3 objects; no CAD."""
from collections import Counter
from functools import cmp_to_key
import json
from pathlib import Path

from check_zdwi_static import evaluate
from lsp_common import ARITY, defun_forms, parse, read_source, walk


def check():
    _, text = read_source()
    funcs = {f[1]: f for f in defun_forms(parse(text))}
    affected = {name: f for name, f in funcs.items() if name.startswith('aa:tbhb-')}
    command = funcs['c:tbhb']
    for f in list(affected.values()) + [command]:
        for n in walk(f[3:]):
            if isinstance(n[0], str) and n[0] in ARITY:
                low, high = ARITY[n[0]]
                assert low <= len(n) - 1 <= high, (f[1], n)
    calls = list(walk(command[3:]))
    heads = [n[0] for n in calls if isinstance(n[0], str)]
    assert heads.count('aa:undo-mark-on') == 1
    assert heads.count('aa:undo-mark-off') == 2  # normal path and error cleanup
    assert 'aa:cmd-begin' not in heads  # preserves dedicated rollback handler
    assert 'command' not in heads and 'entmod' not in heads
    assert ['aa:merge-sort', 'boxes', ['quote', 'aa:tbhb-before-p']] in calls
    copy_call = ['vl-catch-all-apply', ['quote', 'vla-copy'], ['list', 'src']]
    assert copy_call in calls
    assert ['list', 'copy', ['vlax-3d-point', ['quote', ['0.0', '0.0', '0.0']]],
            ['vlax-3d-point', 'offset']] in calls
    assert ['foreach', 'en', 'tb:created'] == next(
        n[:3] for n in calls if n[:3] == ['foreach', 'en', 'tb:created'])
    assert ['vl-catch-all-apply', ['quote', 'entdel'], ['list', 'en']] in calls
    assert heads.index('getpoint') < heads.index('aa:undo-mark-on')
    collect_heads = [n[0] for n in walk(affected['aa:tbhb-collect']) if isinstance(n[0], str)]
    assert 'vlax-method-applicable-p' in collect_heads and 'vlax-release-object' in collect_heads
    assert 'tblsearch' in collect_heads and 'logand' in collect_heads
    assert 'entupd' not in collect_heads
    assert ['exit'] in list(walk(affected['aa:tbhb-abort']))

    def call(name, *args):
        env = {'__functions': affected}
        names = []
        for i, arg in enumerate(args):
            key = 'arg' + str(i)
            env[key] = arg
            names.append(key)
        return evaluate([name] + names, env)

    rows = json.loads((Path(__file__).parent / 'fixtures/tbhb_qw3.json').read_text(encoding='utf-8'))
    assert len(rows) == 195
    lookup = {r['handle']: r for r in rows}
    items = [[r['handle'], r['type'], r['bounds'], r.get('pts')] for r in rows]
    segments = [call('aa:tbhb-segment', *r['pts']) for r in rows if r['type'] == 'LINE']
    assert len(segments) == 71 and all(segments)
    boxes = call('aa:tbhb-boxes', segments)
    assert len(boxes) == 4, boxes

    def compare(a, b):
        if call('aa:tbhb-before-p', a, b):
            return -1
        return 1 if call('aa:tbhb-before-p', b, a) else 0

    ordered = sorted(boxes, key=cmp_to_key(compare))
    groups = call('aa:tbhb-groups', items, ordered)
    assert groups and sum(len(g[1]) for g in groups) == 195
    titles = [[lookup[i[0]]['text'] for i in members
               if lookup[i[0]].get('text', '').endswith('D')][0]
              for _, members in groups]
    assert titles == ['11D', '13D', '12D', '14D'], titles  # geometric, never numeric title order
    # Selection order and reversed line endpoints must not change table order.
    reversed_segments = [call('aa:tbhb-segment', *reversed(r['pts']))
                         for r in reversed(rows) if r['type'] == 'LINE']
    assert sorted(call('aa:tbhb-boxes', reversed_segments), key=cmp_to_key(compare)) == ordered
    tie = [[20, 0, 70, 60], [-20, 0, 30, 60]]
    assert sorted(tie, key=cmp_to_key(compare))[0][0] == -20
    # Removing either complete border prevents identification of that frame.
    frame = [call('aa:tbhb-segment', [0, 0, 0], [50, 0, 0]),
             call('aa:tbhb-segment', [0, 60, 0], [50, 60, 0]),
             call('aa:tbhb-segment', [0, 0, 0], [0, 60, 0]),
             call('aa:tbhb-segment', [50, 0, 0], [50, 60, 0])]
    assert len(call('aa:tbhb-boxes', frame)) == 1
    for index in range(4):
        assert not call('aa:tbhb-boxes', frame[:index] + frame[index + 1:])
    for p, q in (([0, 0, 0], [50, 1, 0]), ([0, 0, 0], [0, 0, 0])):
        assert call('aa:tbhb-segment', p, q) is None
    extra = ['outside', 'TEXT', [10000, 10000, 10001, 10001], None]
    assert call('aa:tbhb-groups', items + [extra], ordered) is None
    different_widths = [ordered[0], [0, -60, 40, 0]]
    assert call('aa:tbhb-groups', [], different_widths) is None
    overlapping = [[0, 0, 50, 60], [20, 20, 70, 80]]
    assert call('aa:tbhb-groups', [], overlapping) is None

    # Execute the same offsets and deduplication helpers as the copy loop.
    target = [1000, 2000, 0]
    drawn, copied_texts, skipped = [], [], 0
    for box, members in groups:
        offset = call('aa:tbhb-offset', box, target)
        assert abs(box[0] + offset[0] - 1000) < 1e-8
        assert abs(box[3] + offset[1] - target[1]) < 1e-8
        for item in members:
            if item[1] == 'LINE':
                pts = [call('aa:tbhb-shift-point', p, offset) for p in item[3]]
                if call('aa:tbhb-seen-line-p', pts, drawn):
                    skipped += 1
                else:
                    drawn.append(pts)
            else:
                copied_texts.append(lookup[item[0]]['text'])
        next_top = call('aa:tbhb-next-top', box, target)
        assert abs(next_top[1] - (box[1] + offset[1])) < 1e-8
        target = next_top
    assert Counter(copied_texts) == Counter(r['text'] for r in rows if r['type'] != 'LINE')
    assert len(copied_texts) == 124
    assert abs(target[1] - 1759.99915) < 1e-6, target
    assert skipped >= 3, skipped  # all three joining boundaries occur just once
    assert len(drawn) + skipped == 71
    print('PASS TBHB: 195 QW3 objects, 4 frames, 11D/13D/12D/14D geometric order, '
          '124 texts preserved, seam/duplicate removal, incomplete/overlapping frames, '
          'width/ownership guards and copy rollback structure')


if __name__ == '__main__':
    check()
