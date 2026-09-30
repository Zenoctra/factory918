# PR #120 review, round 1 of 3 (ticket #105, head 8ce184c, fixed point origin/main)

Comment: https://github.com/Zenoctra/factory918/pull/120#issuecomment-5788196963
act-on items: 3
restart line: not printed. would-break fixed after line: not printed.
Review dir: .claude/worktrees/agent-a5809216d2cd24bda/.scratch/review/origin_main (reports, judgment.md, comment.md)

Act on:
1. [P1] template/.agents/skills/poteto-mode/playbooks/babysit.md:14 (step 6, via patches/pstack/poteto-mode/playbooks/babysit.md.patch): the /loop dynamic-mode wake still ends an owner lane's turn; add the clause the autonomous-run patch carries, that a run inside a lane polls the watcher's result file per the poll rule instead of arming a /loop wake.
2. [P2] docs/knowledge/core/DECISIONS.md:97 and template/docs/factory918/DECISIONS.md:89: P29 still tells the owner to retarget its stacked PR; mark P29 'Amended by P31 (#105)' as P10/P16 do, then rebuild knowledge.
3. [S1] same P29 row as item 2 (Standards side); fixed by the same amendment.

Noted (uncited, may be raised again): S2 no step has the root write the digest into an owner's brief (autopilot-stack); S3 new pstack lines in patches/series sit after the mattpocock block; S4 new M0-findings lines pin no tool version.
