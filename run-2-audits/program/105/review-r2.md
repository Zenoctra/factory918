round: 2 of 3
comment: https://github.com/Zenoctra/factory918/pull/120#issuecomment-5788668200
act-on items: 3
restart line: no; would-break fixed after line: no (round two fixes nothing before posting)
reviewed: d530b7452f17dbb5ca31154484633f98f76c52e6, fixed point origin/main

Act on:
1. [S1, same as P1] template/docs/agents/review-ladder.md:6, template/AGENTS.md:79, AGENTS.md:56, docs/knowledge/core/MANUAL.md:94 still gate round one on green CI; reword each to "round one at the first push, CI alongside; green CI before merge-ready and STACK-READY" (MANUAL.md then python3 tools/build_knowledge.py).
2. [S2, same as P2] docs/knowledge/core/DECISIONS.md:97 (P29 amendment) gives the retarget to "the root", which only autopilot-stack has; scope the amendment to autopilot-stack and keep the lane's own retarget through trunk for a solo `stack #N on #M` run.
3. [S3] docs/knowledge/core/DECISIONS.md:97 P29 title ("opened against trunk, then retargeted") contradicts the amended body; reword the title in the same fix, then rebuild (generated copy template/docs/factory918/DECISIONS.md:89).

Noted: P1, P2 (duplicates of 1 and 2), S4 (P105 key vs sequential P number), S5 (short `table unchanged` gate phrase, as criterion 8 names it).
