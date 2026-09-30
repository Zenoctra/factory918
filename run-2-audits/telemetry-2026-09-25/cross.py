import json,collections,re,statistics as st
from dup import fid
A={a['agent']:a for a in map(json.loads,open('agents.jsonl'))}
C=[json.loads(l) for l in open('callsfull.jsonl')]
def ticket(aid):
    if aid.startswith('ROOT'): return None
    a=A[aid]; m=re.search(r'#(\d{2,3})',a['desc'] or '') or re.search(r'(?:ticket|PR|#)\s*#?(\d{2,3})\b',a['brief'])
    return m.group(1) if m else None
GATES=[r'tests/[\w/-]+\.sh',r'\.github/shellcheck\.sh',r'build_knowledge',r'check_knowledge',r'factory918\.sh sync',r'factory918\.sh apply',r'\bvp (check|test)',r'reviewer\.py']
gate_runs=collections.defaultdict(lambda: collections.defaultdict(list))
file_reads=collections.defaultdict(lambda: collections.defaultdict(list))
for c in C:
    if c['role']=='reviewer-eval': continue
    t=ticket(c['agent'])
    if not t: continue
    key=(c['session'],t)
    if c['kind']=='bash:test/check':
        for g in GATES:
            for m in set(re.findall(g,c['arg'])):
                gate_runs[key][m if isinstance(m,str) and m else g].append((c['agent'],c['role'],c['tok']/max(1,len(GATES)),c['turn']))
    if c['kind'].startswith('read:') or c['kind']=='bash:read':
        for f in c['files']:
            f=fid(f)
            if '.scratch' in f or 'tool-results' in f: continue
            file_reads[key][f].append((c['agent'],c['role'],c['tok']/max(1,len(c['files']))))
# gates
print('### Gate/test commands per ticket across lanes (runs, lanes, roles)')
tot_runs=0; tot_extra_lanes=0; rows=[]
for key,g in gate_runs.items():
    for gate,runs in g.items():
        lanes={r[0] for r in runs}; roles=collections.Counter(r[1] for r in runs)
        rows.append((len(runs),key,gate,len(lanes),dict(roles)))
rows.sort(reverse=True)
per_ticket=collections.Counter(); per_ticket_l=collections.defaultdict(set)
for r in rows:
    per_ticket[r[1]]+=r[0]
print('tickets with gate runs',len(per_ticket),'median runs of any gate per ticket',st.median(per_ticket.values()))
for r in rows[:15]: print(r)
# how many distinct lanes run the same gate per ticket
lanes_per=[r[3] for r in rows if r[2] in ('tests/shellcheck/gate.sh','tests/hooks/delegation.sh','build_knowledge','tests/spec-review/review-brief.sh')]
print('lanes running the same core gate on the same ticket: median',st.median(lanes_per) if lanes_per else None,'max',max(lanes_per) if lanes_per else None)
print('\n### Files read by several lanes of the same ticket (non-scratch)')
rows=[]
for key,fr in file_reads.items():
    for f,rs in fr.items():
        lanes={r[0] for r in rs}
        if len(lanes)>=3:
            tok=sum(r[2] for r in rs); first=collections.defaultdict(float)
            for r in rs: first[r[0]]=max(first[r[0]],r[2])
            rows.append((round(tok),len(lanes),key,f,dict(collections.Counter(A[l]['role'] for l in lanes if l in A))))
rows.sort(reverse=True)
print('file-ticket pairs read by >=3 lanes',len(rows),'tokens in those reads',sum(r[0] for r in rows))
for r in rows[:20]: print(r)
