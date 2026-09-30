import json,re,collections
C=collections.defaultdict(list)
for c in map(json.loads,open('calls.jsonl')): C[c['agent']].append(c)
A=[json.loads(l) for l in open('agents.jsonl')]
def short(a):
    a=re.sub(r'/Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/(\.claude/worktrees/[^/]+/)?','',a)
    a=re.sub(r'/var/folders/\S+?/review-work/[0-9a-f]+/factory918/','',a)
    a=re.sub(r'/Users/manuel/\.claude/projects/[^/]+/','~proj/',a)
    a=re.sub(r'cd "[^"]*" && ','',a); a=re.sub(r'\s+',' ',a).replace('|','\\|')
    return a[:100]
order=['owner','writer','architect','explorer','verifier','reviewer','reviewer-eval','analysis','other']
out=['# Pre-work tool-call sequences, every lane','','One table per lane: each tool call before the lane\'s first real work (role milestone, marked `>>`), in order. `tok` is the context growth that call caused (ctx delta of its turn, split across parallel calls by result size); `exec` is the tool\'s own run time; `+s` is seconds since the lane received its brief. Capped at 40 calls per lane.','']
for r in order:
    g=[a for a in A if a['role']==r]
    out.append(f'\n## {r} ({len(g)} lanes)\n')
    for a in sorted(g,key=lambda a:(a['session'],a['agent'])):
        cs=[c for c in C[a['agent']] if c['pre_ms'] or c['is_ms']]
        out.append(f"\n### {a['agent']} · {a['session']} · {a['type']} · \"{a['desc']}\"\n")
        out.append(f"brief {a['brief_chars']} chars · ctx0 {a['ctx0']} · ctx at first work {a['ctx_ms']} · turns to first work {a['ms_turn']} · {a['sec_ms']} s to first work of {round(a['sec_total'])} s life\n")
        if not cs: out.append('(first call was already task work, or no milestone reached)\n'); continue
        out.append('| turn | +s | ctx | tool | category | tok | exec s | argument |\n|---|---|---|---|---|---|---|---|')
        for c in cs[:40]:
            out.append(f"| {'>>' if c['is_ms'] else ''}{c['turn']} | {c['sec_from_start']:.0f} | {c['ctx']} | {c['name']} | {','.join(c['cats'])} | {c['tok']} | {'' if c['exec_s'] is None else round(c['exec_s'],1)} | `{short(c['arg'])}` |")
open('sequences.md','w').write('\n'.join(out))
