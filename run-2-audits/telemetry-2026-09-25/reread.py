import json,collections,re
C=[json.loads(l) for l in open('callsfull.jsonl')]
by=collections.defaultdict(list)
for c in C: by[c['agent']].append(c)
st=collections.defaultdict(lambda:[0,0,0,set()]); ex=[]
for aid,cs in by.items():
    role=cs[0]['role']; seen={}
    for c in cs:
        if c['state']: seen={}
        if not (c['kind'].startswith('read:') or c['kind']=='bash:read'): continue
        if c['name']=='Read':
            m=re.match(r'(.*?)(@(\S+))?$',c['arg']); f=c['files'][0] if c['files'] else m.group(1); rk=m.group(3)
            whole_ok = rk is None and c['res']<20000
            hit = (f,rk) in seen or (f,'WHOLE') in seen
            if hit and not c['err']:
                s=st[role]; s[0]+=1; s[1]+=c['tok']; s[2]+=c['carry']; s[3].add(aid); ex.append((c['tok'],c['carry'],aid,role,f,c['turn']))
            seen[(f,rk)]=1
            if whole_ok: seen[(f,'WHOLE')]=1
        else:
            k=('BASH',c['arg'])
            if k in seen and not c['err']:
                s=st[role]; s[0]+=1; s[1]+=c['tok']; s[2]+=c['carry']; s[3].add(aid); ex.append((c['tok'],c['carry'],aid,role,c['arg'][:80],c['turn']))
            seen[k]=1
            # whole cat of files counts as whole read
print('| role | rereads of content already in context | lanes | tokens re-added | carried cost |'); print('|---|---|---|---|---|')
T=[0,0,0]
for r,s in sorted(st.items(),key=lambda x:-x[1][2]):
    print(f'| {r} | {s[0]} | {len(s[3])} | {s[1]/1e3:.0f}K | {s[2]/1e6:.1f}M |'); T=[T[0]+s[0],T[1]+s[1],T[2]+s[2]]
print('total',T[0],T[1],T[2])
for e in sorted(ex,reverse=True)[:12]: print(e)
