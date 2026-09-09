<!-- lines: 31 | source: pages/pocock-planning-evidence.md | part 13/17 | title: Pocock Planning Evidence (brief) — Reported outcomes -->

## Contents (line numbers are for the Read tool's offset)
- L6: Reported outcomes

## Reported outcomes

| Source | Date | Type | Claim | Caveat |
| --- | --- | --- | --- | --- |
| cvm PR #1585 (Matt) | 2026-08-23 | measured | Spec #1579 (26 stories) → 4 tickets → 12-commit PR merged in ~2h10m; co-author Claude Opus 5 | Matt's own repo; he wrote the spec, ran the agents and merged |
| cvm PR #1576 (Matt) | 2026-08-23 | measured | Spec #1567 (29 stories) → 8 tickets → 44-commit PR merged next day; 634/2851/10 tests | ffmpeg behaviour and visual design flagged "requires real export testing" |
| cvm PR #1293 (github-actions bot) | 2026-07-14 | measured | Map (15 decisions, 2 days) → spec (42 stories) → 8 tickets → bot PR merged same day | PR self-reports 3 spec deviations and scope creep |
| gigloop PR #539 (thstanton) | 2026-06-20 | measured | Spec (40 stories) → 16 tickets → 24-commit PR merged next day, 492 tests green | 4 items deferred to follow-up tickets; one path "not verified in jsdom" |
| noupling epic #338 | 2026-09-04 | measured | 13 tickets, expand/contract sequencing, 8 closed via PRs in 24h | Custom epic format, not the stock spec template |
| GitHub-wide counts | 2026-09-05 | measured, loosely | 41,225 template specs; 355,512 `ready-for-agent` issues, 82% closed; 10,294 maps, 62% closed | Closure ≠ quality; label may be used outside this toolset |
| Matt, AIE workshop | 2026-04-24 | self-reported | Gamification feature end-to-end in a 2h session; 284 tests; ~25K planning tokens; 93.7K subagent tokens | Demo on his own codebase; three live corrections needed |
| andrew.ooo | 2026-05-02 | self-reported, presented as measured | "time-to-correct-PR was consistently 20-40% lower with the skills installed than without"; "/grill-me alone is worth the install" | One week, one Astro project, no methodology; also reviews a `/caveman` skill that is not in this repo |
| andrew.ooo | 2026-05-02 | self-reported | "skip a week of edits [to CONTEXT.md] and the agent's accuracy regresses fast" | Same |
| HN, pipes | 2026-07-07 | self-reported | grill-me and tdd "massively helped, and technically the code generated is correct but it's still hard to follow and bloated" | Two skills only, not the spec/ticket pipeline |
| HN, gregwebs | 2026-08-14 | self-reported | "The grilling (grill-with-docs) skills are amazing for ensuring you produce a thorough spec that covers all the edge cases. The /code-review skill from there helps ensure that the code changes meet the spec." | Uses his own "intermediate detailed plan stage" instead of to-tickets |
| HN, LinXitoW | 2026-08-10 | self-reported | "the combination of the mattpocock skills, and the beads local issue tracker take care of all of that very well, with generally high quality output" | One sentence |
| Discussion #484, TimHoogervorst | 2026-07-09 | self-reported | Wayfinder "did not really do anything", defaulted to task tickets, rarely prototyped or researched, needed "babysitting" and more tokens than the grill→spec flow | Early v1.1 |
| Issue #595, david-seu | 2026-07-16 | measured (by reporter) | 26-ticket stack: "~20 agent runs per closed ticket, and roughly three quarters of those are repair-loop rework" | Root cause attributed to acceptance criteria; closed with template guidance change |
| Issue #826, jmnicolas90 | 2026-08-09 | measured (by reporter) | "/to-tickets consumed 2 whole sessions of a claude max 5x plan!!! 1.5M+ tokens"; 14 tickets, 90k–156k tokens per enumerator agent, ~70 OPEN decisions left for the human | The repo "mandates" a customised enumerator pipeline, not the stock skill |
| Issue #924, exwer | 2026-08-21 | self-reported with counts | 85-story PRD → 16 tickets → 27 tickets; a critical invariant was orphaned and only found in test env | Local markdown tracker |
| Issue #944, smoochy | 2026-08-23 | measured (by reporter) | Map body silently truncated at 65,536 chars; "59 index lines were lost"; map exceeded 100 sub-issues | Long-running map |
| Issue #554, richardwhatever | 2026-07-13 | self-reported with count | Sub-issue linking "has never worked across nearly a dozen specifications" on Codex 5.5 High | Open, no comment |
| Issue #341, tuterx | 2026-06-13 | self-reported | Precise grill answers "generalize into weaker summaries like 'persist sessions' or 'support retry,' allowing implementation drift" | 16 comments, unread; open |
| cvm #1589 (Matt) | 2026-08-23 | self-reported by author, plus measured 5x growth | CONTEXT.md "carries implementation detail that belongs in the code" | Open |

Not found: any controlled comparison (same feature, with and without the pipeline), any regression rate, any before/after defect count. The dev.to three-way comparison (2026-07-18) says it plainly: "Nobody has established the baseline: does any framework produce better results than running the same model with no framework at all?"
