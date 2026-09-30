import json,glob,os,re,collections
from life import life,A,BASE,SKIP
out=open('lifes.jsonl','w'); cout=open('callsfull.jsonl','w')
paths=[(p,os.path.basename(p)[6:-6]) for p in glob.glob(BASE+'*/subagents/agent-*.jsonl') if SKIP not in p]
paths+=[(BASE+s+'.jsonl','ROOT-'+s[:8]) for s in ['48857ffb-f0e5-4af1-9b36-ecddce7fb416','b4a8ae9c-88b9-4178-b518-8ac2ff6f1af5']]
for p,aid in paths:
    a=A.get(aid)
    if a is None and not aid.startswith('ROOT'): continue
    role=a['role'] if a else 'root'
    ms=a['ms_turn'] if a and a['ms_turn'] is not None else 0
    L=life(p,role)
    if not L: continue
    T=L['turns']; n=L['n']; se=L['seg_end']
    bases=[0]+L['comp']
    base_carry=0; base_carry_post=0
    for bi,b in enumerate(bases):
        end=(bases[bi+1]-1) if bi+1<len(bases) else n-1
        basectx=T[b]['ctx']
        base_carry+=basectx*(end-b+1)
        base_carry_post+=basectx*max(0,end-max(b,ms)+1)
    added=collections.Counter(); carried=collections.Counter(); carried_post=collections.Counter(); added_post=collections.Counter()
    # mention index for idle carry
    ment=[]
    for t in T: ment.append(t['text']+' '+' '.join(c['arg'] for c in t['calls']))
    for i,k,tok,c in L['chunks']:
        cr=tok*(se[i]-i)
        added[k]+=tok; carried[k]+=cr
        cp=tok*max(0,se[i]-max(i,ms-1)) if True else 0
        carried_post[k if i>=ms else 'PRE-WORK growth']+=cp
        if i>=ms: added_post[k]+=tok
        if c is not None:
            idle=None
            if tok>=5000 and c['files']:
                bns=[os.path.basename(f.rstrip('/')) for f in c['files'] if f]
                last=i
                for k2 in range(i+1,se[i]+1):
                    if any(b and b in ment[k2] for b in bns): last=k2
                idle=tok*(se[i]-last)
            cout.write(json.dumps({'agent':aid,'role':role,'session':p.split('/')[-3][:8] if '/subagents/' in p else aid[5:],'turn':i,'ms':ms,'n':n,'seg_end':se[i],'name':c['name'],'kind':k,'arg':c['arg'][:400],'files':c['files'],'hash':c['hash'],'res':c['res'],'tok':round(tok),'carry':round(cr),'err':c['err'],'errtxt':c['errtxt'],'state':c['state'],'ts':c['ts'],'idle':None if idle is None else round(idle)})+'\n')
    tot={'cache_read':sum(t['cr'] for t in T),'cache_write':sum(t['cw'] for t in T),'input':sum(t['inp'] for t in T),'output':sum(t['out'] for t in T),
         'cache_read_post':sum(t['cr'] for t in T[ms:]),'cache_write_post':sum(t['cw'] for t in T[ms:]),'input_post':sum(t['inp'] for t in T[ms:]),'output_post':sum(t['out'] for t in T[ms:])}
    out.write(json.dumps({'agent':aid,'role':role,'session':(a or {}).get('session',aid[5:]),'desc':(a or {}).get('desc','root'),'n':n,'ms':ms,'comp':L['comp'],'sum_ctx':sum(t['ctx'] for t in T),'base_carry':base_carry,'base_carry_post':base_carry_post,
        'added':dict(added),'carried':dict(carried),'carried_post':dict(carried_post),'added_post':dict(added_post),**tot,'maxctx':max(t['ctx'] for t in T),
        't0':T[0]['ts'],'t1':T[-1]['ts']})+'\n')
print('done')
