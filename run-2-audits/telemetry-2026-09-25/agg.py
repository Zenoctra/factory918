import json,statistics as st,collections,re
A=[json.loads(l) for l in open('agents.jsonl')]
C=[json.loads(l) for l in open('calls.jsonl')]
def keep(a): return a['type']!='claude-code-guide' and not re.match(r'(Reply with|You are a probe)',a['brief']) and a['nturns']>=2
A=[a for a in A if keep(a)]
ids={a['agent'] for a in A}
C=[c for c in C if c['agent'] in ids]
def bucket(cats):
    cs=set(cats)
    proc={c for c in cs if re.match(r'G:(skill-doc|agents-md|knowledge|factory-docs|memory)',c)}
    if cs=={'G:skill'}: return 'skill-load'
    if any(c.startswith('W:') for c in cs):
        return 'task(mixed w/ docs)' if proc else 'task'
    if proc: return 'skill-chain' if proc=={'G:skill-doc'} else 'process-docs'
    if any(c.startswith('I:') for c in cs): return 'intake'
    return 'orient'
def med(x):
    x=[v for v in x if v is not None]; return round(st.median(x)) if x else None
def pct(x,q):
    x=sorted(v for v in x if v is not None); return round(x[min(len(x)-1,int(q*len(x)))]) if x else None
roles=collections.defaultdict(list)
for a in A: roles[a['role']].append(a)
BK=['skill-load','skill-chain','process-docs','orient','intake','task','task(mixed w/ docs)','text']
print('ROLE TABLE (milestone = role-specific first real work)')
print('role|n|ctx0 med|ctx@fw med|ctx@ms med|p90|growth0->ms med|turns->ms med|sec->ms med|total sec med|ms share of life med|'+'|'.join(BK))
for r,g in sorted(roles.items()):
    cs=collections.defaultdict(collections.Counter)
    for c in C:
        if c['role']==r and c['pre_ms']: cs[c['agent']][bucket(c['cats'])]+=c['tok']
    per={b:med([cs[a['agent']][b] for a in g if a['ms_turn'] is not None]) for b in BK}
    share=[a['sec_ms']/a['sec_total'] for a in g if a['sec_ms'] is not None and a['sec_total']>0]
    print(f"{r}|{len(g)}|{med([a['ctx0'] for a in g])}|{med([a['ctx_fw'] for a in g])}|{med([a['ctx_ms'] for a in g])}|{pct([a['ctx_ms'] for a in g],.9)}|{med([a['ctx_ms']-a['ctx0'] for a in g if a['ctx_ms']])}|{med([a['ms_turn'] for a in g])}|{med([a['sec_ms'] for a in g])}|{med([a['sec_total'] for a in g])}|{round(100*st.median(share)) if share else None}%|"+'|'.join(str(per[b]) for b in BK))
# mean attribution (sum) per role
print('\nMEAN tokens per lane before milestone by bucket')
for r,g in sorted(roles.items()):
    tot=collections.Counter(); n=len([a for a in g if a['ms_turn'] is not None])
    for c in C:
        if c['role']==r and c['pre_ms']: tot[bucket(c['cats'])]+=c['tok']
    print(r,n,{b:round(tot[b]/max(n,1)) for b in BK if tot[b]})
