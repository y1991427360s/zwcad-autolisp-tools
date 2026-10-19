"""Execute delivered ZZ2 AST against offline DXF fixtures; never accesses CAD."""
import functools
import math
import json
from pathlib import Path
from lsp_common import ARITY, defun_forms, parse, read_source, walk
from check_zdwi_static import evaluate, lisp_equal


def check():
    _, source = read_source()
    funcs = {f[1]: f for f in defun_forms(parse(source))}
    affected = {n: f for n, f in funcs.items() if n.startswith('aa:zz2-') or n == 'c:zz2'}
    assert len(affected) == 9
    for form in affected.values():
        for node in walk(form[3:]):
            if isinstance(node[0], str) and node[0] in ARITY:
                low, high = ARITY[node[0]]
                assert low <= len(node)-1 <= high, node
    cmd = funcs['c:zz2']
    assert {'*error*', 'aa:tag', 'aa:doc', 'aa:undo-open', 'aa:old-cmdecho'} <= set(cmd[2])
    heads = [n[0] for n in walk(cmd[3:])]
    assert heads.count('aa:cmd-begin') == heads.count('aa:cmd-end') == 1
    assert 'command' not in heads and 'aa:zz-center-texts' in heads

    data = {}
    boxes = {}
    com = {"fail": None, "released": [], "moves": []}
    state = {'selected': [], 'undo': 0, 'writes': 0, 'messages': []}
    def bbox(_, en):
        if en in boxes:
            return boxes[en]
        ed = data[en]
        typ = ed[0][1]
        pts = [r[1] for r in ed if r[0] in ((10,11) if typ == 'LINE' else (10,))]
        if typ == "CIRCLE":
            r = next(v for k,v in ed if k == 40)
            return [[pts[0][0]-r,pts[0][1]-r,pts[0][2]],
                    [pts[0][0]+r,pts[0][1]+r,pts[0][2]]]
        return [[min(p[i] for p in pts) for i in range(3)],
                [max(p[i] for p in pts) for i in range(3)]]
    def entmod(ed):
        ed = [r if isinstance(r,tuple) else (r[0],r[1:] if r[0] in (10,11,12,13) else r[1]) for r in ed]
        en = next(r[1] for r in ed if r[0] == -1)
        if en in boxes and ed[0][1] == 'TEXT':
            oldp = next(v for k,v in data[en] if k==10)
            newp = next(v for k,v in ed if k==10)
            delta = [b-a for a,b in zip(oldp,newp)]
            boxes[en] = [[a+b for a,b in zip(q,delta)] for q in boxes[en]]
        data[en] = ed
        state['writes'] += 1
        return en
    def add(typ, points, extra=()):
        en = 'e'+str(len(data))
        data[en] = [(0,typ),(-1,en),(8,'0')] + list(points) + list(extra)
        return en
    def ssget(*_):
        return list(state['selected']) or None
    def mark(delta):
        state['undo'] += delta
        state['marks'].append(delta)
    env = {'__functions': funcs, '__builtins': {}}
    def call(name, *args):
        local = env | {f'a{i}': a for i,a in enumerate(args)}
        return evaluate([name]+[f'a{i}' for i in range(len(args))],local)
    def sort(items, cmp):
        if isinstance(cmp, list):
            def before(a,b):
                scope = env | dict(zip(cmp[1],(a,b)))
                return evaluate(cmp[2],scope)
        else:
            def before(a,b):
                return call(cmp,a,b)
        return sorted(items or [],key=functools.cmp_to_key(
            lambda a,b: -1 if before(a,b) else 1 if before(b,a) else 0))
    def cache(lines,tol):
        # Existing evaluator copies dynamic scopes: the established ZZ collector
        # writes caller locals from aa:zz-add-seg. Emulate only this CAD collector.
        vs,hs=[],[]
        for en in lines:
            pts=[v for k,v in data[en] if k in (10,11)]
            if data[en][0][1] == "LWPOLYLINE" and next((v for k,v in data[en] if k == 70),0) & 1:
                pts = pts + pts[:1]
            for p,q in zip(pts,pts[1:]):
                if abs(p[0]-q[0])<1e-7:vs.append([p[0],min(p[1],q[1]),max(p[1],q[1])])
                elif abs(p[1]-q[1])<1e-7:hs.append([p[1],min(p[0],q[0]),max(p[0],q[0])])
        return [vs,hs]
    def move(en,cx,cy,x,y):
        p = next(r[1] for r in data[en] if r[0] == 10)
        entmod([(k, [p[0]+x-cx,p[1]+y-cy,p[2]] if k==10 else v) for k,v in data[en]])
        return True
    def catch(fn, args):
        try:
            if fn == 'vlax-ename->vla-object':
                if com['fail'] == 'convert': raise RuntimeError('conversion failed')
                return args[0]
            if fn == 'vlax-release-object':
                com['released'].append(args[0])
                return None
            if fn == 'vla-move':
                if com['fail'] == 'move': raise RuntimeError('move failed')
                en, start, end = args
                assert len(start) == len(end) == 3
                assert data[en][0][1] == 'HATCH'
                delta = [b-a for a,b in zip(start,end)]
                boxes[en] = [[a+b for a,b in zip(q,delta)] for q in boxes[en]]
                com['moves'].append((en,delta))
                state['writes'] += 1
                return None  # ActiveX Move succeeds without a return value.
            raise AssertionError(fn)
        except RuntimeError as error:
            return error
    # Pure AST helpers use the same evaluator as existing command regressions.
    env['__functions'] = {n:f for n,f in funcs.items() if n not in (
        'aa:merge-sort','aa:safe-get-bbox','aa:normalize-text-vertical-align',
        'aa:zz-move-text','aa:cmd-begin','aa:cmd-end','aa:zz-build-line-cache')}
    env['__builtins'] = {
        '*':lambda *xs:math.prod(xs),
        'member':lambda x,xs:any(x==v or (isinstance(x,(int,float)) and str(x)==v) for v in (xs or [])),
        'cddr': lambda x:x[2:], 'cadddr':lambda x:x[3],
        'entget':lambda en:data[en], 'entmod':entmod,
        'vl-catch-all-apply':catch,
        'vl-catch-all-error-p':lambda v:isinstance(v,Exception),
        'vlax-3d-point':lambda p:[float(v) for v in p],
        'entnext':lambda en:env.get('__next',{}).get(en),
        'subst':lambda new,old,xs:[new if v==old else v for v in xs],
        'assoc':lambda key,ed:next((r for r in ed if r[0]==key),None),
        'cdr':lambda x:x[1] if isinstance(x,tuple) else x[1:] if x else None,
        'cons':lambda a,b: [a]+(b or []) if b is None or isinstance(b,list) else (a,b),
        'aa:safe-get-bbox':bbox,
        'aa:zz-build-line-cache':cache,
        'aa:merge-sort':sort, 'aa:zz-move-text':move,
        'aa:normalize-text-vertical-align':lambda *a:True,
        'ssget':ssget, 'vl-load-com':lambda:None,
        'tblsearch':lambda *a:[(70,0)], 'sssetfirst':lambda *a:None,
        'aa:cmd-begin':lambda *a:mark(1), 'aa:cmd-end':lambda:mark(-1),
        'redraw':lambda:None, 'princ':lambda *a:state['messages'].extend(a),
        'error':lambda msg:(_ for _ in ()).throw(RuntimeError(msg)),
        'mapcar':lambda fn,a,b:[x+y for x,y in zip(a,b)],
    }
    # Deduplicate two columns sharing a row; only exactly two objects qualify.
    def info(en,y,top,bottom,l=0,r=50):return [en,10,y,l,r,top,bottom]
    groups = [[info('a',48,50,44),info('b',48,50,44)],
              [info('c',48,50,44,50,100),info('d',48,50,44,50,100)],
              [info('s',41,44,39)],
              [info('q',30,32,26)]*3,
              [info('e',35,39,33),info('f',35,39,33)]]
    rows=call('aa:zz2-plan',groups)
    assert rows==[[50,44],[39,33]],rows
    assert call('aa:zz2-plan-ok',rows)
    assert not call('aa:zz2-plan-ok',[[50,44],[46,40]])
    for y,expected in ((50,50),(44,40),(39,35),(33,25),(28,20),(60,60)):
        assert call('aa:zz2-y',y,rows)==expected
    assert call('aa:zz2-y',5,[[20,5]])==10, 'Shrink tall double-text row to 10'
    assert call('aa:zz2-y',5,[[20,10]])==5, 'Height10 is stable'
    # Actual full command: two headers of height6, body rows height5.
    for header_height in (6,10,15,2.5):
        data.clear()
        boxes.clear()
        top=100.0
        ys=[top,top-header_height,top-header_height-5,
            top-2*header_height-5,top-2*header_height-10]
        for y in ys:add('LINE',[(10,[0,y,0]),(11,[100,y,0])])
        for x in (0,100):add('LINE',[(10,[x,ys[-1],0]),(11,[x,top,0])])
        words=[]
        for a,b in zip(ys,ys[1:]):
            words.append(add('TEXT',[(10,[20,(a+b)/2,0])]))
            if a-b==header_height and (a==ys[0] or a==ys[2]):
                words.append(add('TEXT',[(10,[65,(a+b)/2-0.1,0])]))
        circle=add('CIRCLE',[(10,[45,ys[1]-2,0])],[(40,0.5)])
        wire=add('LINE',[(10,[45,ys[1]-2.5,0]),(11,[45,ys[1]-4,0])])
        state.update(selected=list(data),undo=0,marks=[],writes=0,messages=[])
        call('c:zz2')
        assert state['marks']==[1,-1] and state['undo']==0, state
        actual=[next(v for k,v in data['e'+str(i)] if k==10)[1] for i in range(5)]
        assert lisp_equal(actual,[100,90,85,75,70],1e-7),(header_height,actual)
        assert next(v for k,v in data[circle] if k==40)==0.5
        cpoint=next(v for k,v in data[circle] if k==10)
        tip=next(v for k,v in data[wire] if k==10)
        assert abs(cpoint[1]-0.5-tip[1])<1e-7
        # Pair centers5 apart; singles centered in their unchanged-height rows.
        wp=[next(v for k,v in data[w] if k==10) for w in words]
        assert [p[1] for p in wp]==[97.5,92.5,87.5,82.5,77.5,72.5],wp
        first={en:list(ed) for en,ed in data.items()}
        call('c:zz2')
        assert data==first,'Repeated command must not expand again'
    # User QW3 geometry: 92 entities, closed cell polylines, eight filled circles.
    fixture = json.loads((Path(__file__).resolve().parents[1] /
                          'tests/fixtures/zz2_qw3_92.json').read_text(encoding='utf-8'))
    for associative_follow in (False, True):
        data.clear(); boxes.clear()
        com.update(fail=None,released=[],moves=[])
        hatches=[]; circles=[]; words=[]
        for rec in fixture:
            typ=rec['type']; pts=rec['points']
            coords=list(zip((10,11) if typ=='LINE' else [10]*len(pts),pts))
            extra = [(70,1)] if typ=='LWPOLYLINE' else [(40,rec['radius'])] if typ=='CIRCLE' else []
            en=add(typ,coords,extra)
            if typ in ('TEXT','HATCH'): boxes[en]=rec['bbox']
            if typ=='HATCH':hatches.append(en)
            if typ=='CIRCLE':circles.append(en)
            if typ=='TEXT':words.append(en)
        # Simulate a CAD that automatically follows circle boundaries on entmod.
        normal_entmod = env['__builtins']['entmod']
        def follow_entmod(ed):
            old={en:bbox(None,en) for en in circles}
            result=normal_entmod(ed)
            if associative_follow:
                for h,c in zip(hatches,circles):
                    dy=bbox(None,c)[0][1]-old[c][0][1]
                    boxes[h]=[[p[0],p[1]+dy,p[2]] for p in boxes[h]]
            return result
        env['__builtins']['entmod']=follow_entmod
        state.update(selected=list(data),undo=0,marks=[],writes=0,messages=[])
        call('c:zz2')
        assert state['marks']==[1,-1],state['messages']
        assert any('已调整 2 行' in msg for msg in state['messages'])
        for h,c in zip(hatches,circles):
            assert lisp_equal(bbox(None,h),bbox(None,c),1e-3),(h,c,bbox(None,h),bbox(None,c))
            assert next(v for k,v in data[h] if k==10)==[0,0,0], 'HATCH elevation stays unchanged'
        assert len(com['moves'])==(0 if associative_follow else 8),com
        assert com['released']==[en for en,_ in com['moves']]
        first_boxes={en:[list(p) for p in box] for en,box in boxes.items()}
        first={en:list(ed) for en,ed in data.items()}
        call('c:zz2')
        assert all(lisp_equal(data[en],ed,1e-7) for en,ed in first.items()), [(en,ed,data[en]) for en,ed in first.items() if ed != data[en]][:4]
        assert all(lisp_equal(boxes[en],box,1e-7) for en,box in first_boxes.items()), 'QW3 bbox repeat must be stable'
        env['__builtins']['entmod']=normal_entmod
    # Conversion/move failures return nil; acquired objects are always released.
    for failure in ('convert','move'):
        com.update(fail=failure,released=[])
        assert not call('aa:zz2-shift',hatches[0],'HATCH',-3)
        assert com['released']==([] if failure=='convert' else [hatches[0]])
    com['fail']=None
    # MTEXT direction is unchanged; SOLID translates all four corners.
    mt=add('MTEXT',[(10,[1,2,0]),(11,[1,0,0])])
    call('aa:zz2-shift',mt,'MTEXT',-4)
    assert next(v for k,v in data[mt] if k==11)==[1,0,0]
    solid=add('SOLID',[(k,[k,2,0]) for k in (10,11,12,13)])
    call('aa:zz2-shift',solid,'SOLID',-4)
    assert all(v[1]==-2 for k,v in data[solid] if k in (10,11,12,13))
    # Both supported polyline DXF representations execute their actual writers.
    lw=add('LWPOLYLINE',[(10,[0,20]),(10,[10,20]),(10,[10,14]),(10,[0,14])],[(70,1),(42,0)])
    assert call('aa:zz2-poly-ok',lw)
    call('aa:zz2-map-edge',lw,[[20,14]],[])
    assert [v[1] for k,v in data[lw] if k==10]==[20,20,10,10]
    curved=add('LWPOLYLINE',[(10,[0,20]),(10,[10,14])],[(42,0.3)])
    assert not call('aa:zz2-poly-ok',curved)
    poly=add('POLYLINE',[],[(70,0)])
    v1=add('VERTEX',[(10,[0,20,0])],[(42,0)])
    v2=add('VERTEX',[(10,[0,14,0])],[(42,0)])
    end=add('SEQEND',[])
    env['__next']={poly:v1,v1:v2,v2:end}
    assert call('aa:zz2-poly-ok',poly)
    call('aa:zz2-map-edge',poly,[[20,14]],[])
    assert next(v for k,v in data[v2] if k==10)==[0,10,0]
    # Cells of one or three text objects retain their row height.
    for n in (1,3):
        data.clear()
        boxes.clear()
        for p,q in (([0,20,0],[100,20,0]),([0,14,0],[100,14,0]),
                    ([0,14,0],[0,20,0]),([100,14,0],[100,20,0])):
            add('LINE',[(10,p),(11,q)])
        for i in range(n):add('TEXT',[(10,[30+i*10,17,0])])
        state.update(selected=list(data),marks=[],writes=0)
        call('c:zz2')
        assert next(v for k,v in data['e1'] if k==10)[1]==14
    # Cancellation and unsupported objects never open undo or edit DXF.
    for selected in ([],[add('INSERT',[(10,[0,0,0])])]):
        state.update(selected=selected,marks=[],writes=0)
        call('c:zz2')
        assert not state['marks'] and state['writes']==0
    print('PASS ZZ2: actual AST command, 4 heights, repeated runs, shared rows, '
          'QW3 92 entities / 8 hatches, associative follow, COM failures, '
          'overlap guard, circles/wires, MTEXT/SOLID, cancellation, undo and syntax')


if __name__=='__main__':
    check()
