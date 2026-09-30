import json,re,collections,statistics as st
exec(open('agg.py').read().split("roles=collections")[0])
def instr(b):
    if re.search(r'first action: invoke the ([\w-]+) skill|invoke the ([\w-]+) skill first',b,re.I): return 'skill-first'
    if re.search(r'invoke (the )?`?([\w-]+)`? skill|use the ([\w-]+) skill|run /[\w-]+|with the Skill tool',b,re.I): return 'skill-mentioned'
    if re.search(r'skills/[\w-]+/(SKILL\.md|references|playbooks)',b): return 'skill-file-path'
    if re.search(r'playbook',b,re.I): return 'playbook-mentioned'
    return 'none'
G=collections.defaultdict(list)
for a in A:
    k=instr(a['brief']); first=a['first_tool']; fa=a['first_tool_arg'] or ''
    firstskill = first=='Skill'
    anyskill = bool(a['skill_calls'])
    pre=collections.Counter()
    for c in C:
        if c['agent']==a['agent'] and c['pre_ms']: pre[bucket(c['cats'])]+=c['tok']
    ground=pre['skill-load']+pre['skill-chain']+pre['process-docs']+pre['orient']
    G[(a['role'],k,firstskill)].append((a,ground,pre))
print('role|brief instruction|first call is Skill|n|any Skill call|median grounding tok (skill+chain+docs+orient) pre-ms|median skill-chain tok|median ctx@ms|median turns->ms')
for k in sorted(G):
    v=G[k]
    print('|'.join(map(str,[k[0],k[1],k[2],len(v),sum(1 for a,_,_ in v if a['skill_calls']),med([g for _,g,_ in v]),med([p['skill-chain'] for _,_,p in v]),med([a['ctx_ms'] for a,_,_ in v]),med([a['ms_turn'] for a,_,_ in v])])))
# compliance
print()
sf=[a for a in A if instr(a['brief'])=='skill-first']
print('skill-first briefs',len(sf),'first tool Skill',sum(a['first_tool']=='Skill' for a in sf))
for a in sf:
    if a['first_tool']!='Skill': print('  noncompliant',a['agent'],a['role'],a['first_tool'],a['first_tool_arg'][:80])
sm=[a for a in A if instr(a['brief'])=='skill-mentioned']
print('skill-mentioned',len(sm),'invoke skill at all',sum(bool(a['skill_calls']) for a in sm),'first',sum(a['first_tool']=='Skill' for a in sm))
for a in sm: print('  ',a['agent'],a['role'],a['first_tool'],(a['first_tool_arg'] or '')[:60],a['skill_calls'][:3])
