import json,glob,os,re,collections,statistics as st
from analyze import classify_call, text_of, norm, BASE, SKIP, ts
A={a['agent']:a for a in map(json.loads,open('agents.jsonl'))}
C=[json.loads(l) for l in open('calls.jsonl')]
def fid(f):
    f=re.sub(r'^\.claude/skills/','template/.agents/skills/',f)  # symlinked
    f=re.sub(r'^.*?/\.claude/worktrees/[^/]+/','',f)
    return f
def reads_of(path):
    recs=[json.loads(l) for l in open(path)]
    res={}; restext={}
    for r in recs:
        if r.get('type')=='user' and isinstance(r['message'].get('content'),list):
            for x in r['message']['content']:
                if x.get('type')=='tool_result': res[x['tool_use_id']]=len(text_of([x]))
    ev=[]
    for r in recs:
        if r.get('type')!='assistant': continue
        for x in r['message'].get('content',[]):
            if x.get('type')!='tool_use': continue
            if x['name']=='Agent': ev.append(('agent',r['timestamp'],x['id'],None,0)); continue
            cats,files=classify_call(x['name'],x.get('input',{}))
            fs=[f for f,c in files if not str(f).startswith('skill:') and f]
            for f in fs: ev.append(('read',r['timestamp'],x['id'],fid(f),res.get(x['id'],0)/max(len(fs),1)))
            if x['name']=='Skill': ev.append(('read',r['timestamp'],x['id'],'SKILL:'+x['input'].get('skill',''),0))
    return ev
# map toolUseId -> child
metas={}
for m in glob.glob(BASE+'*/subagents/*.meta.json'):
    if SKIP in m: continue
    d=json.load(open(m)); metas[d.get('toolUseId')]=(os.path.basename(m)[6:-10],d,m)
cache={}
def parent_path(child_meta_path,d):
    sess=child_meta_path.split('/subagents/')[0]
    if d.get('parentAgentId'): return sess+'/subagents/agent-'+d['parentAgentId']+'.jsonl'
    return sess+'.jsonl'
stats=collections.defaultdict(list); examples=[]
filecount=collections.Counter(); filetok=collections.Counter()
for tuid,(cid,d,mp) in metas.items():
    if cid not in A: continue
    pp=parent_path(mp,d)
    if not os.path.exists(pp): continue
    if pp not in cache: cache[pp]=reads_of(pp)
    ev=cache[pp]
    launch=next((e for e in ev if e[0]=='agent' and e[2]==tuid),None)
    if not launch: continue
    pread={e[3] for e in ev if e[0]=='read' and e[1]<=launch[1]}
    cfiles=collections.Counter(); ctok=collections.Counter()
    for c in C:
        if c['agent']==cid and (c['pre_ms'] or c['is_ms'] ) :
            fs=[fid(f) for f,cat in c['files'] if f and not str(f).startswith('skill:')]
            for f in fs: cfiles[f]+=1; ctok[f]+=c['tok']/max(len(fs),1)
    dup=[f for f in cfiles if f in pread and not re.search(r'\.scratch/',f)]
    duptok=sum(ctok[f] for f in dup)
    a=A[cid]
    stats[a['role']].append((len(cfiles),len(dup),duptok, a['ctx_ms']-a['ctx0'] if a['ctx_ms'] else None, 'root' if pp.endswith(d.get('parentAgentId','@@')+'.jsonl')==False else 'lane'))
    for f in dup: filecount[(a['role'],f)]+=1; filetok[(a['role'],f)]+=ctok[f]
    if duptok>8000: examples.append((round(duptok),cid,a['role'],a['desc'],dup[:6]))
if __name__=='__main__':
  print('role | children | median distinct files read pre-work | median of those already read by parent | median dup tokens | mean dup tokens | mean growth to ms')
  for r,v in stats.items():
      print(r,len(v),st.median([x[0] for x in v]),st.median([x[1] for x in v]),round(st.median([x[2] for x in v])),round(sum(x[2] for x in v)/len(v)),round(st.mean([x[3] for x in v if x[3] is not None])) if any(x[3] for x in v) else None)
  print('\nTop re-read files (child re-reads a non-scratch file its parent already read before launching it)')
  for (r,f),v in sorted(filecount.items(),key=lambda x:-filetok[x[0]])[:30]:
      print(f'{r:14} {v:>3} lanes {filetok[(r,f)]/v:>7.0f} tok/lane  {f[:100]}')
  print('\nExamples')
  for e in sorted(examples,reverse=True)[:12]: print(e)
