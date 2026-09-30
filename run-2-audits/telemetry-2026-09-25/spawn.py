import json,glob,os,collections,statistics as st
from analyze import BASE,SKIP,ts
A={a['agent']:a for a in map(json.loads,open('agents.jsonl'))}
launch={}
for f in glob.glob(BASE+'*.jsonl')+glob.glob(BASE+'*/subagents/*.jsonl'):
    if SKIP in f: continue
    for l in open(f):
        if '"Agent"' not in l: continue
        d=json.loads(l)
        if d.get('type')!='assistant': continue
        for x in d['message'].get('content',[]):
            if x.get('type')=='tool_use' and x['name']=='Agent': launch[x['id']]=d['timestamp']
rows=collections.defaultdict(list)
for m in glob.glob(BASE+'*/subagents/*.meta.json'):
    if SKIP in m: continue
    d=json.load(open(m)); aid=os.path.basename(m)[6:-10]
    if aid not in A or d.get('toolUseId') not in launch: continue
    f=m[:-10]+'.jsonl'
    recs=[json.loads(l) for l in open(f)]
    t0=ts(recs[0]['timestamp']); ta=next((ts(r['timestamp']) for r in recs if r.get('type')=='assistant'),None)
    tl=ts(launch[d['toolUseId']])
    a=A[aid]
    rows[a['role']].append(((t0-tl).total_seconds(),(ta-t0).total_seconds() if ta else None,d.get('spawnedWithWorktree',False)))
print('role n | launch->brief s med p90 | brief->first model turn s med p90 | worktree lanes')
for r,v in rows.items():
    a=[x[0] for x in v]; b=[x[1] for x in v if x[1] is not None]
    q=lambda x,p: sorted(x)[int(p*(len(x)-1))]
    print(r,len(v),round(st.median(a),1),round(q(a,.9),1),'|',round(st.median(b),1),round(q(b,.9),1),'|',sum(x[2] for x in v))
wt=[x[0] for v in rows.values() for x in v if x[2]]; nwt=[x[0] for v in rows.values() for x in v if not x[2]]
print('spawn latency with worktree med',st.median(wt) if wt else None,'without',st.median(nwt))
