import json,collections,re
L=[json.loads(l) for l in open('lifes.jsonl')]
A={a['agent']:a for a in map(json.loads,open('agents.jsonl'))}
def keep(x):
    if x['role']=='root': return True
    a=A[x['agent']]; return a['type']!='claude-code-guide' and not re.match(r'(Reply with|You are a probe)',a['brief']) and x['n']>=2
L=[x for x in L if keep(x)]
G={'read:file':'file reads','bash:read':'file reads','read:saved-output':'saved-output reads','read:diff':'diffs','bash:git-diff':'diffs','grep/ls':'grep/ls/find','bash:grep/ls':'grep/ls/find',
   'bash:test/check':'test/check runs','bash:gh':'gh (issues/PRs)','bash:gh-ci':'gh CI watch','bash:git':'git other','bash:script':'scripts/other bash','bash:other':'scripts/other bash',
   'bash:poll/wait':'polling/wait loops','agent-launch':'subagent launch+results','agent-result':'subagent launch+results','agent-msg':'subagent launch+results','incoming:task-notification':'subagent launch+results',
   'edit/write':'edits/writes','incoming:skill-text':'skill text','skill':'skill text','model-output(carried)':'own output (carried)','incoming:nested-memory':'nested CLAUDE/AGENTS','PRE-WORK growth':'pre-work reading (carried)'}
def g(k): return G.get(k,'other')
order=['floor','pre-work reading (carried)','file reads','diffs','saved-output reads','grep/ls/find','test/check runs','gh (issues/PRs)','gh CI watch','git other','scripts/other bash','polling/wait loops','subagent launch+results','edits/writes','skill text','own output (carried)','nested CLAUDE/AGENTS','other']
roles=['owner','writer','architect','explorer','verifier','reviewer','reviewer-eval','other','root']
print('## After first work: what the re-sent context consists of (share of sum of per-turn context, turns >= milestone)\n')
print('| role | lanes | turns after | total input processed | output tokens | out/in | '+' | '.join(order)+' |')
print('|'+'---|'*(6+len(order)))
tot_all=collections.Counter(); 
for r in roles:
    xs=[x for x in L if x['role']==r]
    if not xs: continue
    c=collections.Counter(); tin=0; tout=0; nt=0
    for x in xs:
        c['floor']+=x['base_carry_post']
        for k,v in x['carried_post'].items(): c[g(k)]+=v
        tin+=x['cache_read_post']+x['cache_write_post']+x['input_post']; tout+=x['output_post']; nt+=x['n']-x['ms']
    s=sum(c.values())
    print(f"| {r} | {len(xs)} | {nt} | {tin/1e6:.1f}M | {tout/1e6:.2f}M | {100*tout/tin:.1f}% | "+' | '.join(f"{100*c[o]/s:.0f}%" if c[o] else '' for o in order)+' |')
    tot_all.update(c)
print('\n## New content added after first work, by kind (tokens, first time it enters context) and its carried cost\n')
print('| role | '+' | '.join(o for o in order[2:])+' |'); print('|'+'---|'*(1+len(order)-2))
for r in roles:
    xs=[x for x in L if x['role']==r]
    c=collections.Counter()
    for x in xs:
        for k,v in x['added_post'].items(): c[g(k)]+=v
    print(f'| {r} (added, M tok) | '+' | '.join(f"{c[o]/1e6:.2f}" for o in order[2:])+' |')
print('\n## Billing view, whole life incl. pre-work (all lanes + roots)')
for r in roles:
    xs=[x for x in L if x['role']==r]
    cr=sum(x['cache_read'] for x in xs); cw=sum(x['cache_write'] for x in xs); i=sum(x['input'] for x in xs); o=sum(x['output'] for x in xs)
    T=cr+cw+i+o; W=cr*0.1+cw*1.25+i+o*5
    print(f"{r}: total {T/1e6:.0f}M tok; cache read {100*cr/T:.0f}%, cache write {100*cw/T:.1f}%, uncached {100*i/T:.2f}%, output {100*o/T:.2f}% | price-weighted (0.1/1.25/1/5): cache read {100*cr*0.1/W:.0f}%, cache write {100*cw*1.25/W:.0f}%, output {100*o*5/W:.0f}%")
xs=L
cr=sum(x['cache_read'] for x in xs); cw=sum(x['cache_write'] for x in xs); i=sum(x['input'] for x in xs); o=sum(x['output'] for x in xs)
T=cr+cw+i+o; W=cr*0.1+cw*1.25+i+o*5
print(f"ALL: total {T/1e6:.0f}M; cache read {100*cr/T:.1f}%, write {100*cw/T:.1f}%, output {100*o/T:.2f}% | weighted: read {100*cr*0.1/W:.0f}%, write {100*cw*1.25/W:.0f}%, output {100*o*5/W:.0f}%")
