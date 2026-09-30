# #109 owner report

PR #135 adds the Safe and Eco switch. With no tier file every run is exactly today's; with `eco` the owner does the reading, the review wrapper, the small fixes and the records itself, and the lanes that find surprises stay fresh. It is reviewed through round four with nothing left to act on, CI is green, and it is ready to stack.

## Status

STACK-READY.
- Head: `be9cc3fd667645aece2f5cc7846f03be82a36c2c` (`git rev-parse HEAD` and `git ls-remote origin refs/heads/feat/eco-tier` agree). The root verified 9454e38. Since then there are two commits on the root's wording finding and four on Manuel's interrogate and trail-review ruling (both sections below). None is a rebase.
- Branch: `feat/eco-tier`. PR: https://github.com/Zenoctra/factory918/pull/135, base `main`, ready (not draft), `closingIssuesReferences` [109], MERGEABLE.
- Patch base: `a9ebdac` (`origin/main` when branched). Intended parent: `main`.

## Root finding after 9454e38

The root's finding came from ticket #137's rule that a judging lane's brief must not presume a result, and it is fixed in two new commits (no rebase):
- `dbb0212`, by fix lane 5. The eco judge's brief now reads "to return its findings, not a base; the findings stand in for the second candidate" in `template/.agents/skills/architect/SKILL.md:38`, with the patch regenerated against `research/`. In `ticket.md:12` it now reads "to return its findings, which you settle in the synthesis" (the old "fix" also presumed defects). Line 17, the trail-review count sentence, is untouched, as instructed.
- `dfdf587`, mine, records only. The ledger line now counts "the arena judge and one writer" among the nine, and P109's description says "findings".
- I checked every other sentence the PR adds to a judging lane's brief against the same test: "read that candidate adversarially against the ticket, the grounding and the design red flags" in both places, and the reviewers' briefs, which the PR does not change. None states an expected result, caps output or items, or limits reading. "Read no brief and no diff while the review state exists" binds the owner, not a judging lane, so it stays.
- The PR's Problem section now also says "and one writer". The Fix section's two "defects" became "findings". The Checks list shows the full ShellCheck line with `'tests/*/*/*.sh'` and 26 files, and the head and CI run are updated. The Blast Radius section quotes the lane's grounding verbatim and was left as written.
- Verifying lines run at dfdf587: ShellCheck over the six globs gave 26 files, clean. `./factory918.sh sync` and `python3 tools/build_knowledge.py` both leave `git status` clean. `python3 tools/check_knowledge.py` passes (119 files). `tests/hooks/delegation.sh` gives ok 76. CI run 35916838618 on dfdf587 succeeded.
- No new review round is owed. Round four's comment ended the review with `act-on items: 0` and no `would-break fixed after` line. These two commits answer the root's finding, not an Act on item in a round comment, so no comment marks an item `fixed:`. Under P20 as amended by #106, a round is owed only by a `would-break fixed after` line or a `next round owed:` line, and neither exists. The change is also wording only.
- An earlier gap is corrected. My runs at 148aa8a and 9454e38 used the ShellCheck line without `'tests/*/*/*.sh'` (24 files). The full line (26 files) now passes.

## Manuel's ruling after dfdf587: eco keeps interrogate, the trail review gets no list

- Fix lane 6 made three commits. `1cfb14b` edits `ticket.md` step 0. The override list no longer names Feature step 7 or Opening a PR's `interrogate`. Item 2 no longer skips `interrogate`, and ends "Feature step 4 briefs one writer, never an arena." The closing paragraph lists `interrogate`'s reviewers among the lanes that stay fresh in both tiers. Its new text: "Log each lane you launch as a trail row. The trail review's brief asks it to list every lane launch it finds in the trail and the transcripts, and gives it no list, ceiling or count to compare against; you compare its list with this tier's rule in your hand-back, after it reports." Also in `1cfb14b`, `review-ladder.md` rung 3 reads exactly as on `main` again. `0a277f2` and `e9b70cc` edit MANUAL: ladder item 6 reads as on `main` again, and **Safe and eco.** lists `interrogate`'s reviewers among the fresh lanes. The regenerated copy went in its own commit because the lane missed it in the first one.
- `be9cc3f` is mine and amends P109. The fresh-lane list gains `interrogate`'s reviewers, and "(no writer arena, no `interrogate`)" becomes "(no writer arena)". A sentence says the trail review lists every launch with no list or count, and that the owner compares in its hand-back. A dated amendment quotes Manuel. The regenerated DECISIONS copy is in the same commit.
- #109's body gained a dated amendment at the end of `## Testing decisions`, appended after re-reading the whole body, with no cell edited. It quotes both of Manuel's sentences, changes row C7's eco cell to "its reviewers, as in safe", keeps C1's `why` drop and C3's writer-arena drop with their reason (neither is a surprise-finder; the writer stays fresh as one lane), rewrites the trail review's part, and says table B does not move.
- Table B did not move. `tests/hooks/delegation.sh` is unchanged at ok 76.
- No vendored file changed in this step, so no patch was regenerated. The architect sentence and its patch are as of dbb0212. The lane searched the whole branch diff and found no other sentence that skips `interrogate` or hands a judging lane an expected list, cap or count. My grep for "no `interrogate`", "not run in `eco`" and "skip `interrogate`" over `template`, the core docs, AGENTS.md and SOURCES.md finds nothing. MANUAL's "decides how many of these roles a ticket launches" describes the tier to a person, not a judging lane's brief, so it stays.
- PR body: the Fix bullet lists `interrogate`'s reviewers and the trail-review rule. Criterion 4 says the "at most" list was a prediction, not a constraint, per the amendment. A "Decided after the reviews" paragraph was added. The Checks section names head be9cc3f and CI run 35917699843.
- Verifying lines run at be9cc3f: ShellCheck over the six globs, 26 files, clean. gate.sh ok 17. delegation.sh ok 76. review-comment.sh ok 298. review-brief.sh ok 1294. overlap.sh ok 57. check-trail.sh ok 66. no-stale-wording ok. provisional-ids 26 passed. reviewer refusals 230 passed. `./factory918.sh sync` and `build_knowledge.py` both leave `git status` clean, and `check_knowledge.py` passes (119 files). CI run 35917699843 on be9cc3f succeeded.
- No review round is owed, and here is how I decided. P20 as #106 amended it owes another round only when a round's comment carries `would-break fixed after <sha>`, or `next round owed:` (an item marked `fixed:` at round one or two). Round four's comment carries neither and ends `act-on items: 0`, and no later round comment exists. These commits follow the human's ruling, not an Act on item, so nothing is marked `fixed:`. The design artifact changed, but by Manuel's ruling and not by a review's `restart`, so P27's restart does not apply either. The root's verification of be9cc3f is the check on this change.

## Overlap

Step 1, `overlap.sh 109`:
```
go: autopilot-stack
base: origin/main
```
Step 8, `overlap.sh 109 --diff`: no output, exit 0.

## Criteria

1. A tier switch exists and the playbooks read it. The proof is Ticket step 0's "The tier" bullet (`template/.agents/skills/poteto-mode/playbooks/ticket.md`), with pointers at steps 5, 6 and 8, Design hole step 2 and the Reply. There is also P109 in DECISIONS Provisional and MANUAL "Execution", **Safe and eco.** (setter plus fallback). Table A was walked with `tier-proof.sh` (`.scratch/program/109/walk/table-a.txt`).
2. The eco substitutions. Proven by step 0 items 1 to 5 and the closing paragraph. The architect Phase B one-runner exception goes through `patches/pstack/architect/SKILL.md.patch`. The writer, blast radius, both reviewers, the judge and the trail review stay fresh in both tiers, and step 6 is unchanged.
3. The hook's eco behavior is decided and tested. Decided: the hook does not change, and a root-run ticket's small fixes go to a fix lane. Table B is on the ticket. `tests/hooks/delegation.sh` has 21 assertions (7 calls x 3 tier files), committed first (96901b9) and green against the unmodified hook, with `ok 76` at head.
4. The owner brief names the tier. Autopilot-stack step 1 (patch) names the `Tier: eco` digest line. Manuel ruled on 2026-09-23 that the "at most" list was a prediction, not a constraint; see the amendment on #109. Eco keeps `interrogate`'s reviewers, so a ticket that reaches a step launching `interrogate` adds them to that list, and otherwise the list holds. The PR Verification maps table C onto the 2026-09-22 delegate kinds. No ceiling is handed to the trail review: it lists the launches, and the owner compares in its hand-back.
5. The ledger line. `docs/agents/ledger.md`, 2026-09-23 #109: 53% waiting on lanes plus 17% with turns ended, 70% together; 98 min of owner reasoning; which lane kinds found something and which found nothing.

## Reviews

- Round 1: https://github.com/Zenoctra/factory918/pull/135#issuecomment-5801940462, `act-on items: 5`. Its one Would-break: `interrogate` was dropped only at Feature step 7. All five fixed (fix lane 2).
- Round 2: https://github.com/Zenoctra/factory918/pull/135#issuecomment-5802070957, `act-on items: 1`. The repository's AGENTS.md:59 lacked the eco clause. Fixed (fix lane 3).
- Round 3: https://github.com/Zenoctra/factory918/pull/135#issuecomment-5802217510, `act-on items: 0`. Two items were fixed before posting (fix lane 4): S1 (Would break, count per architect round, 1756050) and S2 (Fails open, an absent Tier line reads safe, 6fab5bd). It carries `would-break fixed after 259448e`.
- Round 4 (fix only after 259448e): https://github.com/Zenoctra/factory918/pull/135#issuecomment-5802248053, `round: 4 of 5`, `act-on items: 0`, no would-break line. The review ends here.
- No restarts.
- Before round one, the blast-radius lane's risks 1, 3 to 11 and 13 and writer flag 5 were fixed (fix lane 1). The rest were accepted with reasons in https://github.com/Zenoctra/factory918/issues/109#issuecomment-5801707581.
- In round three I made two format-only edits to the Standards report's `spec:` lines so `review-comment.sh` would accept them: backticks removed, and `table A1/autopilot-stack owner (own worktree)` shortened to `table A1/autopilot-stack`. The findings are unchanged, and the trail logs it.

## CI

Run 35917699843, head `be9cc3f`, conclusion `success`. Earlier heads: 35916838618 (dfdf587), 35914742211 (9454e38), 35911963563 (148aa8a), 35912957059 (6430d6b) and 35913818812 (259448e), all success.

## Records

- Provisional: `P109`, "How much ceremony a run pays (#109)". It names both tiers and what each keeps, and says the hook reads no tier. The reasons are Manuel's quotes, the run numbers and the rejected size allowance, and the accepted trade is that the owner judges its reviewers' findings in eco. P11's Choice cell gains the clause "Amended 2026-09-23 (#109, P109): in `eco` a subagent owner writes its own small fixes and records commit; the root session is unchanged".
- Ledger: the 2026-09-23 `as the #109 owner, set the safe and eco tiers from the 2026-09-22 run ...` line (criterion 5). Since dfdf587 it names the nine outcome-changing lanes as "blast radius, the two reviewer axes, the trail review, the arena judge and one writer". P109 says the judge "returns its findings", and since be9cc3f it keeps `interrogate`'s reviewers fresh and carries the dated amendment with the trail-review rule.
- M0: none.
- A surprise I did not commit, to keep the reviewed head fixed; the root may want it as a ledger line. `review-comment.sh`'s `spec: table <row>/<column>` grammar refuses a column header that contains spaces, so a scenario table's column headers should be single tokens. Table A's header "autopilot-stack owner (own worktree)" forced a hand edit of a reviewer's line.

## Decided

- Criterion 3's branch. The hook does not change, and a root-run ticket's small fixes go to a fix lane. Both architect runners reached this independently. A size rule would fail open on heredocs, NotebookEdit and interpreter writes (#132).
- Where the tier lives. It is the main checkout's `.claude/state/tier`, read through `git rev-parse --git-common-dir`, and is `eco` only when it holds exactly `eco`. It is frozen in the digest's `Tier: eco` line. The brief wins over the file, a missing line is safe, and a replacement owner takes the replaced brief's tier. There is no hook or `mode.sh` display line and no setter skill; you set it with `mkdir -p .claude/state && echo eco > .claude/state/tier`.
- Eco also drops the `why` investigator lanes and the writer arena. Neither is a surprise-finder, and the writer stays fresh as one lane. Superseded: I had also dropped `interrogate` to meet criterion 4's count. Manuel ruled on 2026-09-23 that it stays fresh in both tiers, because it reads someone else's work and the count was a prediction (be9cc3f and the #109 amendment).
- The rule is stated once, in Ticket step 0 (ours, no patch), with an override clause over the playbook and skill steps it names. Only two vendored files change, both through existing patches. `feature.md`, `how`, `arena` and `spec-review` stay unpatched.
- One-page hand-back means Autopilot-stack step 7's five headings, for every eco hand-back.
- Eco logs each launch as a trail row. Since Manuel's ruling, the trail review lists every launch it finds with no expected list or count, and the owner compares that list with the tier in its hand-back.
- The root's STACK-READY swarm is the root's check, not a lane the ticket launches.

## Blocked

Nothing waits on Manuel. Two things are for him to judge:
- This ticket ran in safe mode but skipped `interrogate`. Opening a PR says a subagent that opens a PR runs it. I skipped it because the design was not contested, and the PR body discloses the skip.
- The trail review's flag 7: blast risks 2 and 15 together mean an `eco` set in a worktree's own `.claude/state` silently does nothing, and nothing shows the live tier. Both were accepted as fail-safe.

## Trail

`/Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.scratch/program/109/decisions.tsv`. `check-trail.sh` passed at review time. The trail review is `.scratch/program/109/trail/review.md` (reviewed by Claude Opus 5, 11 flags). Flags 1 to 4, 6, 8, 10 and 11 were acted on; 5, 7 and 9 are disclosed above and in the PR body.
