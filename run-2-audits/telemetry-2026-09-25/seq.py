import json,sys,re
C=[json.loads(l) for l in open('calls.jsonl')]
A={a['agent']:a for a in map(json.loads,open('agents.jsonl'))}
def short(c):
    a=c['arg']; a=re.sub(r'/Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/(\.claude/worktrees/agent-[0-9a-f]+/)?','',a)
    a=re.sub(r'cd "[^"]*" && ','',a); a=re.sub(r'\s+',' ',a)
    return a[:110]
def show(aid,limit=30,extra=3):
    a=A[aid]; cs=[c for c in C if c['agent']==aid]
    print(f"## {aid} {a['session']} {a['role']} {a['type']} '{a['desc']}' brief={a['brief_chars']}c ctx0={a['ctx0']} ms_turn={a['ms_turn']} ctx_ms={a['ctx_ms']} sec_ms={a['sec_ms']} total={a['sec_total']:.0f}s skills_named={a['skills_named']} nested={[n[0].split('/')[-1] for n in a['nested']]}")
    k=0
    for c in cs:
        if not c['pre_ms'] and not c['is_ms']:
            continue
        k+=1
        if k>limit: break
        mark='>>' if c['is_ms'] else '  '
        print(f"{mark} t{c['turn']:<2} +{c['sec_from_start']:>5.0f}s ctx={c['ctx']:>6} {c['name']:<9} {','.join(c['cats']):<22} +{c['tok']:>5}tok exec={c['exec_s'] if c['exec_s'] is None else round(c['exec_s'],1)}s  {short(c)}")
for x in sys.argv[1:]: show(x); print()
