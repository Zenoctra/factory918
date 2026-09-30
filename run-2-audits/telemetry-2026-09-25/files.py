import json,re,collections
exec(open('agg.py').read().split("roles=collections")[0])
from dup import fid
def nrm(p):
    p=fid(p); p=re.sub(r'/\d{2,4}(/|$|-)',r'/N\1',p); p=re.sub(r'\b[0-9a-f]{7,40}\b','SHA',p); p=re.sub(r'(?<=/)(origin_main|main)(?=/)','SHA',p)
    p=re.sub(r'^.*?/\.scratch/','.scratch/',p); return p
roles=collections.defaultdict(set)
for a in A: roles[a['role']].add(a['agent'])
for role in ['owner','writer','architect','reviewer','reviewer-eval','verifier','explorer']:
    lanes=roles[role]; n=len(lanes)
    seen=collections.defaultdict(set); tok=collections.Counter(); cat={}
    for c in C:
        if c['agent'] in lanes and (c['pre_ms']):
            fs=[f for f,cc in c['files'] if f and not f.startswith('skill:')]
            for f,cc in c['files']:
                if not f or f.startswith('skill:'): continue
                k=nrm(f); seen[k].add(c['agent']); tok[k]+=c['tok']/len(fs); cat[k]=cc
    print(f'\n### {role} n={n}: files read before first real work (% lanes, mean tok per lane that read it, category)')
    for k,v in sorted(seen.items(),key=lambda x:-len(x[1]))[:18]:
        if len(v)<2: break
        print(f'  {100*len(v)/n:4.0f}% {len(v):>3} {tok[k]/len(v):>7.0f}  {cat[k]:<16} {k[:90]}')
