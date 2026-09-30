import json,re,collections,statistics as st,os
exec(open('agg.py').read().split("roles=collections")[0])
def nrm(p):
    p=re.sub(r'agent-[0-9a-f]+','agent-X',p); p=re.sub(r'/\d{2,4}(/|$)',r'/N\1',p); p=re.sub(r'\b[0-9a-f]{7,40}\b','SHA',p)
    p=re.sub(r'#?\b\d{2,4}\b','N',p)
    return p
def segsig(cmd):
    cmd=re.sub(r"<<-?\s*['\"]?(\w+)['\"]?[^\n]*\n.*?\n\1\b",' HEREDOC',cmd,flags=re.S)
    out=[]
    for s in re.split(r'&&|\|\||;|\n',cmd):
        s=s.strip()
        if not s or s.startswith('#'): continue
        s=s.split('|')[0].strip()
        toks=s.split()
        toks=[t for t in toks if not re.match(r'^[A-Z_]+=',t)]
        if not toks: continue
        w=os.path.basename(toks[0].strip('"\''))
        if w in ('cd','echo','mkdir','true','printf','export','sleep'): continue
        if w in ('git','gh'):
            sub=' '.join(t for t in toks[1:3] if not t.startswith('-') and not t.startswith('"'))
            out.append(nrm(f'{w} {sub}')[:40]); continue
        if w in ('bash','sh','python3'):
            f=next((os.path.basename(t.strip('"\'')) for t in toks[1:] if not t.startswith('-')),'')
            out.append(f'{w} {f}'[:50]); continue
        if w in ('cat','sed','head','tail','nl','awk','grep','wc','less','ls','find'):
            fs=[t.strip('"\'') for t in toks[1:] if ('/' in t or re.search(r'\.\w+["\']?$',t)) and not t.startswith('-')]
            fs=[nrm(re.sub(r'^.*?/factory918/(\.claude/worktrees/agent-X/)?','',f)) for f in fs]
            fs=[f for f in fs if not re.match(r"^['\"]?\d",f)]
            out.append(f'{w} '+(' '.join(fs[:2]) if fs else '')); continue
        out.append(w)
    return out
def sigs(c):
    if c['name']=='Skill': return ['Skill '+c['arg']]
    if c['name']=='Read':
        return ['Read '+nrm(re.sub(r'^.*?/factory918/(\.claude/worktrees/agent-[0-9a-f]+/)?','',re.sub(r'^.*?/review-work/[0-9a-f]+/factory918/','',c['arg'])))]
    if c['name']=='Bash': return segsig(c['arg'])
    return [c['name']]
roles=collections.defaultdict(set)
for a in A: roles[a['role']].add(a['agent'])
for role in ['owner','writer','architect','reviewer','reviewer-eval','verifier','explorer']:
    lanes=roles[role]; n=len(lanes)
    cnt=collections.Counter(); tok=collections.Counter(); secs=collections.defaultdict(list); ex=collections.defaultdict(list)
    for c in C:
        if c['agent'] in lanes and (c['pre_ms'] or c['is_ms']):
            ss=set(sigs(c))
            for s in ss:
                cnt[(s,c['agent'])]=1
                tok[s]+=c['tok']/len(ss); ex[s].append(c['exec_s'] or 0)
    per=collections.Counter(s for (s,_) in cnt)
    print(f'\n#### {role} (n={n})\n\n| call | lanes | count | mean tokens added | mean exec s |\n|---|---|---|---|---|')
    for s,v in per.most_common(16):
        if v<2: break
        print(f'| {s[:80]} | {100*v/n:.0f}% | {v} | {tok[s]/v:.0f} | {sum(ex[s])/len(ex[s]):.1f} |')
