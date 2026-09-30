import json,sys,os,glob
BASE=os.path.expanduser('~/.claude/projects/-Users-manuel-Desktop-Work-Under-The-Sun-Collective-Core-918-factory918/')
def load(path):
    recs=[json.loads(l) for l in open(path)]
    return recs
def ctx(u):
    return u.get('input_tokens',0)+u.get('cache_read_input_tokens',0)+u.get('cache_creation_input_tokens',0)
def summarize_input(name,inp):
    if name=='Read': return inp.get('file_path','')+ (f" off={inp.get('offset')}" if inp.get('offset') else '')
    if name=='Bash': return inp.get('command','')[:200].replace('\n',' ; ')
    if name=='Skill': return inp.get('skill','')+' '+str(inp.get('args',''))[:80]
    if name in('Grep','Glob'): return json.dumps(inp)[:200]
    if name in('Edit','Write'): return inp.get('file_path','')
    if name=='Agent': return inp.get('description','')
    return json.dumps(inp)[:150]
def dump(path, maxcalls=40):
    recs=load(path)
    meta=path.replace('.jsonl','.meta.json')
    if os.path.exists(meta): print(open(meta).read())
    first=recs[0]
    c=first['message']['content']
    brief=c if isinstance(c,str) else ' '.join(x.get('text','') for x in c if x.get('type')=='text')
    print('BRIEF chars',len(brief)); print(brief[:1500]); print('---')
    seen=set(); n=0; results={}
    for r in recs:
        if r.get('type')=='user' and isinstance(r['message'].get('content'),list):
            for x in r['message']['content']:
                if x.get('type')=='tool_result':
                    cc=x.get('content'); s=json.dumps(cc) if not isinstance(cc,str) else cc
                    results[x['tool_use_id']]=len(s)
    for r in recs:
        if r.get('type')=='user' and r.get('isMeta'):
            c=r['message']['content']; t=c if isinstance(c,str) else ' '.join(x.get('text','') for x in c if x.get('type')=='text')
            print(f"   [meta user msg {len(t)} chars: {t[:100]!r}]")
        if r.get('type')=='attachment' and r['attachment'].get('type')=='nested_memory':
            print('   [nested_memory', r['attachment'].get('path'), len(json.dumps(r['attachment'])),']')
        if r.get('type')!='assistant': continue
        m=r['message']; mid=m.get('id')
        u=m.get('usage',{})
        for x in m.get('content',[]):
            if x.get('type')=='tool_use':
                n+=1
                if n>maxcalls: return
                print(f"{r['timestamp'][11:19]} ctx={ctx(u):>7} {x['name']:6} {summarize_input(x['name'],x['input'])} -> {results.get(x['id'],0)}c")
            elif x.get('type')=='text' and n<3:
                print(f"{r['timestamp'][11:19]} ctx={ctx(u):>7} TEXT {x['text'][:150]!r}")
if __name__=='__main__':
    dump(sys.argv[1], int(sys.argv[2]) if len(sys.argv)>2 else 40)
