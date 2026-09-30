import json,glob,os,collections
from life import life,A,BASE,SKIP,ts
Ls={x['agent']:x for x in map(json.loads,open('lifes.jsonl'))}
paths=[(p,os.path.basename(p)[6:-6]) for p in glob.glob(BASE+'*/subagents/agent-*.jsonl') if SKIP not in p]
paths+=[(BASE+s+'.jsonl','ROOT-'+s[:8]) for s in ['48857ffb-f0e5-4af1-9b36-ecddce7fb416','b4a8ae9c-88b9-4178-b518-8ac2ff6f1af5']]
agg=collections.defaultdict(lambda: collections.Counter()); ex=[]
gapb=lambda g: '<5m' if g<300 else ('5-60m' if g<3600 else '>1h')
for p,aid in paths:
    if aid not in Ls: continue
    role=Ls[aid]['role']
    L=life(p,role); T=L['turns']
    for i in range(1,len(T)):
        new=max(0,T[i]['ctx']-T[i-1]['ctx'])
        excess=T[i]['cw']-new-2000
        gap=(ts(T[i]['ts'])-ts(T[i-1]['ts'])).total_seconds()
        agg[role]['cw_total']+=T[i]['cw']
        if excess>10000:
            agg[role]['miss_n']+=1; agg[role]['miss_tok']+=excess; agg[role]['miss_'+gapb(gap)]+=excess; agg[role]['missn_'+gapb(gap)]+=1
            if excess>150000: ex.append((round(excess),aid,role,round(gap),T[i]['ts']))
print('role | cache-write total | re-writes of already-seen context (n, tokens) | by idle gap before the turn')
for r,c in agg.items():
    print(r, f"{c['cw_total']/1e6:.1f}M", c['miss_n'], f"{c['miss_tok']/1e6:.1f}M ({100*c['miss_tok']/max(1,c['cw_total']):.0f}% of writes)", {k:(c['missn_'+k],f"{c['miss_'+k]/1e6:.1f}M") for k in ['<5m','5-60m','>1h']})
for e in sorted(ex,reverse=True)[:10]: print(e)
