import json,glob,os,re,collections,statistics as st
from analyze import BASE,SKIP,text_of,classify_call,norm
from dup import fid
A={a['agent']:a for a in map(json.loads,open('agents.jsonl'))}
Cs=collections.defaultdict(list)
for c in map(json.loads,open('calls.jsonl')): Cs[c['agent']].append(c)
tot_lanes=0; lanes_reread=0; reread_tok=[]; pack_sizes=[]; ex=[]; ratio=[]
for p in glob.glob(BASE+'*/subagents/agent-*.jsonl'):
    if SKIP in p: continue
    aid=os.path.basename(p)[6:-6]
    if aid not in A: continue
    recs=[json.loads(l) for l in open(p)]
    res={}
    for r in recs:
        if r.get('type')=='user' and isinstance(r['message'].get('content'),list):
            for x in r['message']['content']:
                if x.get('type')=='tool_result': res[x['tool_use_id']]=text_of([x])
    pack=set(); seen_brief=False; rereads=collections.Counter(); packchars=0
    for r in recs:
        if r.get('type')!='assistant': continue
        for x in r['message'].get('content',[]):
            if x.get('type')!='tool_use': continue
            inp=x.get('input',{}); arg=inp.get('file_path') or inp.get('command') or ''
            out=res.get(x['id'],'')
            if re.search(r'(spec|standards)-brief\.md',arg) and not re.search(r'>\s*\S*brief',arg):
                seen_brief=True
                for m in re.finditer(r'^(?:\s*\d+\t)?### (\S+), (whole|lines)',out,re.M): pack.add(fid(norm(m.group(1))))
                packchars+=len(out)
                continue
            if not pack: continue
            cats,files=classify_call(x['name'],inp)
            for f,_ in files:
                f2=fid(f)
                if f2 in pack and not re.search(r'brief\.md$|/diff$',f2): rereads[f2]+=len(out)/max(len(files),1)
    if not seen_brief or not pack: continue
    tot_lanes+=1; pack_sizes.append(len(pack))
    if rereads:
        lanes_reread+=1; reread_tok.append(sum(rereads.values())/2.5)
        ex.append((round(sum(rereads.values())/2.5),aid,A[aid]['role'],A[aid]['desc'],list(rereads)[:4]))
print('lanes whose brief carried a reading pack:',tot_lanes,'median files in pack',st.median(pack_sizes))
print('lanes that re-read >=1 pack file anyway:',lanes_reread, f'({100*lanes_reread/tot_lanes:.0f}%)','median re-read tokens (chars/2.5)',round(st.median(reread_tok)),'mean',round(st.mean(reread_tok)))
by=collections.Counter(e[2] for e in ex); print(by)
for e in sorted(ex,reverse=True)[:8]: print(e)
