import json,glob,os,re,collections
from datetime import datetime
BASE=os.path.expanduser('~/.claude/projects/-Users-manuel-Desktop-Work-Under-The-Sun-Collective-Core-918-factory918/')
SKIP='22c5dda7-568b-4c98-a161-52d8015e38aa'
SKILLS=['poteto-mode','spec-review','how','why','arena','architect','interrogate','show-me-your-work','blast-radius','writing-for-agents','unslop','technical-writing','deslop','knowledge','factory918','tdd','swarm','figure-it-out','teach','babysit','fix-ci','reflect','grill-with-docs','to-spec','to-tickets','domain-modeling','make-pr-easy-to-review','research','thermo-nuclear-code-quality-review']
def ts(s): return datetime.fromisoformat(s.replace('Z','+00:00'))
def text_of(c):
    if isinstance(c,str): return c
    out=[]
    for x in c:
        if x.get('type')=='text': out.append(x.get('text',''))
        elif x.get('type')=='tool_result':
            cc=x.get('content'); out.append(cc if isinstance(cc,str) else text_of(cc or []))
    return '\n'.join(out)

PATH_RE=re.compile(r'''(?:"[^"]*"|'[^']*'|[^\s;|&<>()'"]+)''')
def norm(p):
    p=p.strip('"\'')
    p=re.sub(r'^.*?/factory918/\.claude/worktrees/agent-[0-9a-f]+/','',p)
    p=re.sub(r'^.*?/review-work/[0-9a-f]+/factory918/','',p)
    p=re.sub(r'^.*?/Core_918/factory918/','',p)
    p=re.sub(r'^/private/tmp/claude-501/[^/]+/[0-9a-f-]+/','$SCRATCH/',p)
    p=re.sub(r'^/Users/manuel/','~/',p)
    return p

def file_cat(p):
    q=p
    if re.search(r'(^|/)\.?(claude|agents)/skills/|template/\.agents/skills/|/skills/',q):
        if q.endswith('.md') or '/playbooks/' in q or '/references/' in q: return 'G:skill-doc'
    if re.search(r'(^|/)(AGENTS|CLAUDE)\.md$',q): return 'G:agents-md'
    if re.search(r'docs/knowledge/core/|template/docs/factory918/',q): return 'G:knowledge-core'
    if 'docs/knowledge/' in q: return 'G:knowledge-other'
    if re.search(r'docs/(M0-findings|FACTORY-SPEC)',q) or re.search(r'docs/agents/',q): return 'G:factory-docs'
    if '/memory/' in q and '.claude/projects' in q: return 'G:memory'
    if re.search(r'\.claude/hooks/.*\.md$|session-mandate|\.claude/agents/.*\.md$|(^|/)SOURCES\.md$|(^|/)README\.md$',q): return 'G:factory-docs'
    if re.search(r'brief|handoff|ticket\.md$|lane',q,re.I) and ('.scratch' in q or '$SCRATCH' in q): return 'I:brief'
    if '.scratch/' in q or q.startswith('$S/') or q.startswith('$SCRATCH'): return 'I:handover'
    return None

ORIENT_CMDS={'cd','pwd','ls','echo','date','which','wc','true','export','printf','sleep','test','['}
READ_CMDS={'cat','sed','head','tail','less','nl','awk','grep','rg','bat','file','stat','wc'}
EDIT_RE=re.compile(r'sed -i|perl -[a-z]*i|git apply|git commit|git am |\.write\(|write_text\(|\bpatch -p')
def classify_bash(cmd):
    if EDIT_RE.search(cmd) and not re.search(r'^\s*(S|T|O)=.*\.scratch',cmd):
        c2,f2=classify_bash_inner(cmd); c2.add('W:edit'); return c2,f2
    return classify_bash_inner(cmd)
def classify_bash_inner(cmd):
    segs=re.split(r'&&|\|\||;|\n|\|',cmd)
    cats=set(); files=[]
    for s in segs:
        s=s.strip()
        if not s or s.startswith('#'): continue
        toks=PATH_RE.findall(s)
        if not toks: continue
        w=toks[0].strip('"\'')
        if re.match(r'^[A-Z_]+=',w):
            if len(toks)==1: cats.add('G:orient'); continue
            toks=toks[1:]; w=toks[0]
        w=os.path.basename(w)
        if w in ('cd','pwd','ls','echo','date','which','true','export','printf','mkdir','[','test','tr','sort','uniq','fold','cut','xargs'):
            cats.add('G:orient'); continue
        if w=='git':
            sub=toks[1] if len(toks)>1 else ''
            if sub in ('status','log','branch','rev-parse','remote','worktree','config','-C'):
                cats.add('G:orient'); continue
            if sub in ('diff','show'):
                cats.add('W:diff'); continue
            cats.add('W:git'); continue
        if w=='gh':
            if len(toks)>2 and toks[1]=='issue' and toks[2] in('view','list'): cats.add('I:ticket'); continue
            if len(toks)>2 and toks[1]=='pr' and toks[2]=='diff': cats.add('W:diff'); continue
            if len(toks)>2 and toks[1]=='pr' and toks[2]=='view': cats.add('I:ticket'); continue
            if len(toks)>1 and toks[1]=='api' and 'issues' in s and 'comments' not in s: cats.add('I:ticket'); continue
            cats.add('W:gh'); continue
        if w in READ_CMDS:
            fs=[norm(t) for t in toks[1:] if ('/' in t or '.' in t) and not t.startswith('-') and not re.match(r"^['\"]?[\d,]+p['\"]?$",t)]
            fs=[f for f in fs if re.search(r'\.(md|sh|py|json|ya?ml|tsv|txt|diff|patch)$|/diff$|^\S+/$',f)]
            if not fs:
                cats.add('G:orient' if w=='wc' else 'W:read'); continue
            for f in fs:
                c=file_cat(f); files.append((f,c or 'W:read')); cats.add(c or 'W:read')
            continue
        if w=='find': cats.add('G:orient'); continue
        cats.add('W:cmd')
    return cats,files

def classify_call(name,inp):
    if name=='Skill': return {'G:skill'},[('skill:'+inp.get('skill',''),'G:skill')]
    if name=='Read':
        f=norm(inp.get('file_path','')); c=file_cat(f)
        if re.search(r'(^|/)diff$|\.diff$|\.patch$',f): c='W:diff'
        return {c or 'W:read'},[(f,c or 'W:read')]
    if name=='Bash': return classify_bash(inp.get('command',''))
    if name in ('ToolSearch','TaskOutput'): return {'G:orient'},[]
    if name in ('Glob',): return {'G:orient'},[]
    if name=='Grep':
        p=norm(inp.get('path','') or '')
        c=file_cat(p) if p else None
        return {c or 'W:grep'},[(p,c)] if c else []
    if name in ('Edit','Write','NotebookEdit','MultiEdit'):
        f=norm(inp.get('file_path',''))
        c='W:note' if re.search(r'\.scratch/|\$SCRATCH|^/tmp|^/private/tmp|/var/folders/.*/\.scratch/|report|result|todo',f) else 'W:edit'
        return {c},[(f,c)]
    if name=='Agent': return {'W:agent'},[]
    return {'W:'+name},[]

def is_ground(cats): return all(c.startswith('G:') or c.startswith('I:') for c in cats)

def role_of(desc,brief,atype):
    d=(desc or '').lower(); b=brief.lower()
    if 'review-work/' in b: return 'reviewer-eval'
    if re.search(r'own ticket|owner',d): return 'owner'
    if re.search(r'trail review|cross-model review',d): return 'reviewer'
    if re.search(r'verify|re-verify|audit',d): return 'verifier'
    if re.search(r'review|reviewer|judge',d): return 'reviewer'
    if re.search(r'writer|fix|implement|records lane',d): return 'writer'
    if re.search(r'how|explorer|explainer|blast-radius|grounding',d): return 'explorer'
    if re.search(r'architect|arena|runner',d): return 'architect'
    if re.search(r'post-mortem',d): return 'analysis'
    return 'other'


def milestone_ok(role,c):
    cats=set(c['cats'])
    if role=='writer': return 'W:edit' in cats
    if role=='owner': return c['name']=='Agent' or 'W:edit' in cats
    if role in ('reviewer','reviewer-eval'): return bool(cats & {'W:diff','W:read','W:grep','W:cmd','W:edit'})
    return not is_ground(cats)

def analyze(path):
    session=path.split('/')[-3]
    recs=[json.loads(l) for l in open(path)]
    if not recs: return None,[]
    metap=path[:-6]+'.meta.json'
    meta=json.load(open(metap)) if os.path.exists(metap) else {}
    first=next((r for r in recs if r.get('type')=='user'),None)
    if not first: return None,[]
    brief=text_of(first['message']['content'])
    role=role_of(meta.get('description'),brief,meta.get('agentType'))
    pre_att=collections.Counter(); nested=[]; results={}; rts={}; skill_meta=[]
    for r in recs:
        if r.get('type')=='attachment' and r['attachment'].get('type')=='nested_memory':
            a=r['attachment']; nested.append((norm(a.get('path','')),len(json.dumps(a.get('content',{})))))
        if r.get('type')=='user':
            c=r['message'].get('content')
            if isinstance(c,list):
                for x in c:
                    if x.get('type')=='tool_result':
                        results[x['tool_use_id']]=len(text_of([x])); rts[x['tool_use_id']]=r['timestamp']
            if r.get('isMeta'): skill_meta.append(len(text_of(c)))
    for r in recs:
        if r.get('type')=='assistant': break
        if r.get('type')=='attachment': pre_att[r['attachment'].get('type')]+=len(json.dumps(r['attachment']))
    turns=[]; bymid={}
    for r in recs:
        if r.get('type')!='assistant': continue
        m=r['message']; mid=m.get('id') or r['uuid']
        if mid not in bymid:
            u=m.get('usage',{})
            t={'ts':r['timestamp'],'ctx':u.get('input_tokens',0)+u.get('cache_read_input_tokens',0)+u.get('cache_creation_input_tokens',0),
               'cread':u.get('cache_read_input_tokens',0),'out':0,'calls':[],'model':m.get('model')}
            bymid[mid]=t; turns.append(t)
        t=bymid[mid]; t['out']=max(t['out'],m.get('usage',{}).get('output_tokens',0))
        for x in m.get('content',[]):
            if x.get('type')=='tool_use':
                cats,files=classify_call(x['name'],x.get('input',{}))
                inp=x.get('input',{})
                arg=inp.get('skill') if x['name']=='Skill' else (inp.get('file_path') or inp.get('command') or inp.get('query') or inp.get('pattern') or inp.get('description') or json.dumps(inp)[:200])
                t['calls'].append({'name':x['name'],'cats':sorted(cats),'files':files,'res':results.get(x['id'],0),'arg':str(arg),
                    'ts_use':r['timestamp'],'ts_res':rts.get(x['id'])})
    if not turns: return None,[]
    start=ts(recs[0]['timestamp']); end=ts(recs[-1]['timestamp'])
    for i,t in enumerate(turns):
        t['delta']=(turns[i+1]['ctx']-t['ctx']) if i+1<len(turns) else 0
        t['wall']=(ts(turns[i+1]['ts'])-ts(t['ts'])).total_seconds() if i+1<len(turns) else 0
    fw=fedit=fdiff=ms=None
    for i,t in enumerate(turns):
        for c in t['calls']:
            if fw is None and not is_ground(set(c['cats'])): fw=i
            if fedit is None and 'W:edit' in c['cats']: fedit=i
            if fdiff is None and 'W:diff' in c['cats']: fdiff=i
            if ms is None and milestone_ok(role,c): ms=i
    callrecs=[]
    upto=fw if fw is not None else len(turns)
    attrib=collections.Counter(); attrib_ms=collections.Counter()
    for i,t in enumerate(turns):
        tot=sum(max(c['res'],1) for c in t['calls']) or 1
        for j,c in enumerate(t['calls']):
            share=t['delta']*max(c['res'],1)/tot
            k=c['cats'][0] if len(c['cats'])==1 else ('mixed:'+'+'.join(c['cats']))
            if i<upto: attrib[k]+=share
            if ms is not None and i<ms: attrib_ms[k]+=share
            exec_s=(ts(c['ts_res'])-ts(c['ts_use'])).total_seconds() if c['ts_res'] else None
            callrecs.append({'session':session[:8],'agent':os.path.basename(path)[6:-6],'role':role,'turn':i,'name':c['name'],'cats':c['cats'],
               'arg':c['arg'][:220],'files':c['files'],'res_chars':c['res'],'tok':round(share),'ctx':t['ctx'],
               'sec_from_start':(ts(c['ts_use'])-start).total_seconds(),'exec_s':exec_s,'turn_wall':t['wall'],
               'pre_fw': i<upto, 'pre_ms': (ms is not None and i<ms), 'is_fw': i==fw, 'is_ms': i==ms})
        if not t['calls']:
            if i<upto: attrib['text-only']+=t['delta']
            if ms is not None and i<ms: attrib_ms['text-only']+=t['delta']
    first_call=next(((i,c) for i,t in enumerate(turns) for c in t['calls']),None)
    skill_calls=[(i,c['arg']) for i,t in enumerate(turns) for c in t['calls'] if c['name']=='Skill']
    named=[s for s in SKILLS if re.search(r'(?<![\w-])/?'+re.escape(s)+r'(?![\w-])',brief)]
    sec=lambda k: (ts(turns[k]['ts'])-start).total_seconds() if k is not None else None
    cx=lambda k: turns[k]['ctx'] if k is not None else None
    return {
      'session':session[:8],'agent':os.path.basename(path)[6:-6],'type':meta.get('agentType'),'desc':meta.get('description'),
      'depth':meta.get('spawnDepth'),'model':turns[0]['model'],'role':role,
      'brief_chars':len(brief),'brief':brief[:4000],
      'pre_att':dict(pre_att),'nested':nested,'skill_meta_chars':skill_meta,
      'ctx0':turns[0]['ctx'],'cread0':turns[0]['cread'],'ctx_fw':cx(fw),'ctx_fedit':cx(fedit),'ctx_fdiff':cx(fdiff),'ctx_ms':cx(ms),
      'ctx_max':max(t['ctx'] for t in turns),'ctx_last':turns[-1]['ctx'],'nturns':len(turns),'fw_turn':fw,'ms_turn':ms,
      'sec_fw':sec(fw),'sec_fedit':sec(fedit),'sec_ms':sec(ms),'sec_total':(end-start).total_seconds(),
      'first_tool':first_call[1]['name'] if first_call else None,'first_tool_arg':str(first_call[1]['arg'])[:160] if first_call else None,
      'skill_calls':skill_calls,'skills_named':named,
      'attrib':{k:round(v) for k,v in attrib.items()},'attrib_ms':{k:round(v) for k,v in attrib_ms.items()},
      'out_total':sum(t['out'] for t in turns),'sum_ctx':sum(t['ctx'] for t in turns),'turn_walls':[t['wall'] for t in turns],
    },callrecs
if __name__=='__main__':
  out=open('agents.jsonl','w'); cout=open('calls.jsonl','w')
  n=0
  for p in sorted(glob.glob(BASE+'*/subagents/agent-*.jsonl')):
      if SKIP in p: continue
      try: r,cr=analyze(p)
      except Exception as e:
          import traceback; traceback.print_exc(); print('ERR',p,e); continue
      if r:
          out.write(json.dumps(r)+'\n'); n+=1
          for c in cr: cout.write(json.dumps(c)+'\n')
  print(n)
