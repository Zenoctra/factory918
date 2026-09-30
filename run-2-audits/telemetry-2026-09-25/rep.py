import json,collections,re,os
C=[json.loads(l) for l in open('callsfull.jsonl')]
by=collections.defaultdict(list)
for c in C: by[c['agent']].append(c)
def grp(k):
    if k.startswith('read:') or k=='bash:read': return 'file read'
    if k in('bash:git-diff',): return 'diff'
    if k=='bash:test/check': return 'test/check'
    if k in('bash:gh','bash:gh-ci'): return 'gh'
    if k=='bash:poll/wait': return 'poll'
    if k in('grep/ls','bash:grep/ls'): return 'grep/ls'
    return 'other'
same=collections.defaultdict(lambda: [0,0,0]); lanes=collections.defaultdict(set); ex=collections.defaultdict(list)
fileread=collections.defaultdict(lambda:[0,0,0]); flanes=collections.defaultdict(set); fex=[]
for aid,cs in by.items():
    role=cs[0]['role']
    seen={}; fseen={}
    for idx,c in enumerate(cs):
        if c['name'] in('Edit','Write','Agent','SendMessage','TaskStop','Skill','ToolSearch'): 
            if c['state']: fseen={}
            continue
        key=(c['name'],c['arg'])
        g=grp(c['kind'])
        if key in seen and seen[key][1]==c['hash'] and not c['err']:
            s=same[(role,g)]; s[0]+=1; s[1]+=c['tok']; s[2]+=c['carry']; lanes[(role,g)].add(aid)
            ex[(role,g)].append((c['tok'],aid,c['arg'][:90].replace('\n',' '),c['turn'],seen[key][0]))
        seen[key]=(c['turn'],c['hash'])
        # file-level rereads (whole or partial), no state change between
        if c['state']: fseen={}
        if g=='file read':
            for f in c['files']:
                if f in fseen and fseen[f]!=c['turn']:
                    s=fileread[role]; s[0]+=1; s[1]+=c['tok']/len(c['files']); s[2]+=c['carry']/len(c['files']); flanes[role].add(aid)
                    fex.append((round(c['tok']/len(c['files'])),aid,role,f,fseen[f],c['turn']))
                fseen[f]=c['turn']
print('### Identical call, identical output, repeated in the same lane (excluding the first)')
print('| role | kind | repeats | lanes | tokens added by repeats | carried cost of repeats |'); print('|---|---|---|---|---|---|')
tot=[0,0,0]
for (r,g),v in sorted(same.items(),key=lambda x:-x[1][2]):
    if v[1]<20000: continue
    print(f'| {r} | {g} | {v[0]} | {len(lanes[(r,g)])} | {v[1]/1e3:.0f}K | {v[2]/1e6:.1f}M |')
for v in same.values(): tot=[a+b for a,b in zip(tot,v)]
print('TOTAL identical repeats',tot[0],f'added {tot[1]/1e6:.2f}M carried {tot[2]/1e6:.1f}M')
print('\n### Same file read again with no state-changing call in between (any range)')
print('| role | rereads | lanes | tokens | carried |'); print('|---|---|---|---|---|')
for r,v in sorted(fileread.items(),key=lambda x:-x[1][2]): print(f'| {r} | {v[0]} | {len(flanes[r])} | {v[1]/1e3:.0f}K | {v[2]/1e6:.1f}M |')
print('\nexamples identical repeats')
for k in [('owner','poll'),('owner','file read'),('writer','test/check'),('verifier','file read'),('reviewer-eval','file read'),('root','file read'),('root','gh'),('owner','gh')]:
    for e in sorted(ex.get(k,[]),reverse=True)[:3]: print(k,e)
print('\nexamples file rereads')
for e in sorted(fex,reverse=True)[:12]: print(e)
