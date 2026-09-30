import json,statistics as st,collections,sys
A=[json.loads(l) for l in open('agents.jsonl')]
def med(x): x=[v for v in x if v is not None]; return round(st.median(x)) if x else None
def p(x,q): 
    x=sorted(v for v in x if v is not None); 
    return round(x[min(len(x)-1,int(q*len(x)))]) if x else None
groups=collections.defaultdict(list)
for a in A: groups[(a['session'],a['role'])].append(a)
print('session role n | ctx0 med | ctx_fw med p90 | growth med | sec_fw med | sec_total med | fw_turn med | brief chars med')
for k in sorted(groups):
    g=groups[k]
    gr=[a['ctx_fw']-a['ctx0'] for a in g if a['ctx_fw']]
    print(k,len(g),'|',med([a['ctx0'] for a in g]),'|',med([a['ctx_fw'] for a in g]),p([a['ctx_fw'] for a in g],.9),'|',med(gr),'|',med([a['sec_fw'] for a in g]),'|',med([a['sec_total'] for a in g]),'|',med([a['fw_turn'] for a in g]),'|',med([a['brief_chars'] for a in g]))
