import json,glob,os,re,collections,hashlib
from analyze import BASE,SKIP,text_of,classify_call,norm,ts,EDIT_RE
A={a['agent']:a for a in map(json.loads,open('agents.jsonl'))}
TEST_RE=re.compile(r'tests/[\w/-]+\.sh|shellcheck|build_knowledge|check_knowledge|factory918\.sh (sync|apply)|\bvp (check|test)|pnpm |pytest|reviewer\.py|refusals\.sh|rebuild\.sh|fixes\.sh')
POLL_RE=re.compile(r'\bsleep\b|until |while ')
STATE_RE=re.compile(r'git (checkout|switch|merge|pull|rebase|reset|am|cherry-pick|stash|fetch|commit|apply|worktree add)|factory918\.sh (sync|apply)|build_knowledge|sed -i|perl -[a-z]*i|\.write\(|write_text\(|>\s*(?!/dev/null|&)\S')
def kind_of(name,inp):
    if name=='Read':
        f=inp.get('file_path','')
        if re.search(r'(^|/)diff$|\.diff$|\.patch$',f): return 'read:diff'
        if '/tool-results/' in f: return 'read:saved-output'
        return 'read:file'
    if name in('Grep','Glob'): return 'grep/ls'
    if name in('Edit','Write','NotebookEdit','MultiEdit'): return 'edit/write'
    if name=='Skill': return 'skill'
    if name in('Agent',): return 'agent-launch'
    if name in('TaskOutput',): return 'agent-result'
    if name in('SendMessage','TaskStop'): return 'agent-msg'
    if name=='ToolSearch': return 'toolsearch'
    if name!='Bash': return 'other-tool'
    cmd=inp.get('command','')
    if POLL_RE.search(cmd): return 'bash:poll/wait'
    if TEST_RE.search(cmd): return 'bash:test/check'
    if re.search(r'\bgh (run|pr checks)',cmd): return 'bash:gh-ci'
    if re.search(r'\bgh ',cmd): return 'bash:gh'
    if re.search(r'git (diff|show)',cmd): return 'bash:git-diff'
    if re.search(r'(^|[;&|(]\s*)(cat|sed -n|head|tail|nl|awk)\b',cmd): return 'bash:read'
    if re.search(r'(^|[;&|(]\s*)(grep|rg|ls|find)\b',cmd): return 'bash:grep/ls'
    if re.search(r'\bgit ',cmd): return 'bash:git'
    if re.search(r'python3?|\.sh\b',cmd): return 'bash:script'
    return 'bash:other'
def life(path,role,ms_turn=None):
    recs=[json.loads(l) for l in open(path)]
    res={}; err={}
    for r in recs:
        if r.get('type')=='user' and isinstance(r['message'].get('content'),list):
            for x in r['message']['content']:
                if x.get('type')=='tool_result':
                    t=text_of([x]); res[x['tool_use_id']]=t; err[x['tool_use_id']]=bool(x.get('is_error'))
    turns=[]; bymid={}; pending_incoming=0
    incoming_after=collections.Counter()
    for r in recs:
        if r.get('type')=='assistant':
            m=r['message']; mid=m.get('id') or r['uuid']
            if mid not in bymid:
                u=m.get('usage',{})
                t={'i':len(turns),'ts':r['timestamp'],'ctx':u.get('input_tokens',0)+u.get('cache_read_input_tokens',0)+u.get('cache_creation_input_tokens',0),
                   'cr':u.get('cache_read_input_tokens',0),'cw':u.get('cache_creation_input_tokens',0),'inp':u.get('input_tokens',0),'out':0,'calls':[],'text':''}
                bymid[mid]=t; turns.append(t)
            t=bymid[mid]; t['out']=max(t['out'],m.get('usage',{}).get('output_tokens',0))
            for x in m.get('content',[]):
                if x.get('type')=='tool_use':
                    inp=x.get('input',{})
                    cats,files=classify_call(x['name'],inp)
                    o=res.get(x['id'],'')
                    t['calls'].append({'name':x['name'],'kind':kind_of(x['name'],inp),'arg':(inp.get('file_path','')+(f"@{inp.get('offset')}:{inp.get('limit')}" if inp.get('offset') or inp.get('limit') else '')) if x['name']=='Read' else (inp.get('command') or inp.get('skill') or inp.get('description') or inp.get('pattern') or json.dumps(inp)[:300]),
                        'files':[f for f,c in files if f and not str(f).startswith('skill:')],'res':len(o),'hash':hashlib.md5(o.encode()).hexdigest()[:10],'err':err.get(x['id'],False),'errtxt':o[:160] if err.get(x['id']) else '',
                        'state':bool(x['name'] in('Edit','Write','NotebookEdit') or (x['name']=='Bash' and STATE_RE.search(inp.get('command','')))),'ts':r['timestamp']})
                elif x.get('type')=='text': t['text']+=x.get('text','')
        elif turns and r.get('type') in('user','attachment'):
            if r.get('type')=='user' and not (isinstance(r['message'].get('content'),list) and any(x.get('type')=='tool_result' for x in r['message']['content'])):
                c=text_of(r['message'].get('content'))
                k='task-notification' if 'task-notification' in c else ('skill-text' if r.get('isMeta') else ('compact-summary' if r.get('isCompactSummary') else 'user-message'))
                turns[-1].setdefault('incoming',collections.Counter())[k]+=len(c)
            elif r.get('type')=='attachment' and r['attachment'].get('type')=='queued_command':
                turns[-1].setdefault('incoming',collections.Counter())['task-notification']+=len(json.dumps(r['attachment']))
            elif r.get('type')=='attachment' and r['attachment'].get('type')=='nested_memory':
                turns[-1].setdefault('incoming',collections.Counter())['nested-memory']+=len(json.dumps(r['attachment']))
    kept=[]
    for t in turns:
        if t['ctx']==0 and kept:
            kept[-1]['calls']+=t['calls']
            inc=kept[-1].setdefault('incoming',collections.Counter()); inc.update(t.get('incoming',{}))
            continue
        if t['ctx']==0: continue
        kept.append(t)
    turns=kept
    for k,t in enumerate(turns): t['i']=k
    n=len(turns)
    if not n: return None
    # segments by compaction (ctx drop >40%)
    seg_end=[n-1]*n; comp=[]
    for i in range(n-1,0,-1):
        pass
    for i in range(1,n-1):
        if turns[i]['ctx']<0.6*turns[i-1]['ctx'] and turns[i+1]['ctx']>=0.8*turns[i-1]['ctx']:
            turns[i]['outlier']=True; turns[i]['ctx_raw']=turns[i]['ctx']; turns[i]['ctx']=turns[i-1]['ctx']
    bounds=[i for i in range(1,n) if turns[i]['ctx']<0.6*turns[i-1]['ctx']]
    comp=bounds
    nb=sorted(bounds)+[n]
    for i in range(n):
        seg_end[i]=next(b for b in nb if b>i)-1  # last turn carrying chunk added at turn i
    chunks=[]  # (turn, kind, tokens, call)
    for i,t in enumerate(turns):
        if i+1>=n: break
        d=turns[i+1]['ctx']-t['ctx']
        if i+1 in bounds or d<=0: continue
        mp=min(t['out'],d); rp=d-mp
        chunks.append((i,'model-output(carried)',mp,None))
        inc=t.get('incoming',{})
        tot=sum(max(c['res'],1) for c in t['calls'])+sum(inc.values())
        if tot==0: chunks.append((i,'other/unattributed',rp,None)); continue
        for c in t['calls']:
            chunks.append((i,c['kind'],rp*max(c['res'],1)/tot,c))
        for k,v in inc.items(): chunks.append((i,'incoming:'+k,rp*v/tot,None))
    return {'turns':turns,'chunks':chunks,'seg_end':seg_end,'comp':comp,'n':n}
