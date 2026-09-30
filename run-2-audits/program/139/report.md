# #139 owner report

PR #142 now refuses a review when any writer flags heading in a ticket body has no flag read under it. It is green on CI at 8aa660a and ready to land. The root's verification found one hole: a hidden second list passed behind the first list's flags. The count is now per heading line, which closes it.

## Status

STACK-READY.

- Head: 8aa660a2a55b934312bbde2e15364484d2888920. `git rev-parse HEAD` and `git ls-remote origin refs/heads/feat/unreadable-writer-flags` agree.
- Branch: `feat/unreadable-writer-flags`, the root's rebase onto `main` at 9846844 (30bdcae), plus four commits.
- PR: https://github.com/Zenoctra/factory918/pull/142. It is ready, `mergeStateStatus: CLEAN`, and targets `main`. The PR opened with `--base main` because #140 had merged and its branch was gone, so `Closes #139` links directly.
- Patch base: e710e99 (`origin/feat/unled-review-briefs`, #140's head). The root then rebased onto `main` at 9846844.
- Intended parent: ticket #137 (PR #140), now merged into `main`.

## Overlap

Step 1 (`overlap.sh 139`, exit 0):
```
go: autopilot-stack
#136 feat/risk-dispositions: template/.agents/skills/spec-review/scripts/review-brief.sh tests/spec-review/review-brief.sh
#140 feat/unled-review-briefs: template/.agents/skills/spec-review/scripts/review-brief.sh tests/spec-review/review-brief.sh
base: origin/feat/unled-review-briefs
```
Step 8 (`overlap.sh 139 --diff`, exit 0, at 9abbcca):
```
go: autopilot-stack
#143 feat/reviewer-eval-rerun: docs/knowledge/core/DECISIONS.md template/docs/factory918/DECISIONS.md
```
This is in the PR body's `## Overlap` section. Both PRs append independent Provisional rows.

## Criteria

1. A body with a writer flags heading anywhere, fenced, quoted or not, is refused when no flag is read under that heading. Criteria 1 to 3 were reworded on #139 to match table D and the per-heading count, with a dated line giving the old and new wording. Per heading means each read flag belongs to the nearest heading line at or above it (659f508). Such a body is refused with exit 1, a message naming the heading, and no state. The final match is two or more `#` whose lowercased text holds `writer` and later `flag`, after any spaces, `>` or list markers. It is proven by table D cells D2 to D7, D11, D11b and D13 to D16, plus C6/f, in `tests/spec-review/review-brief.sh`. Each asserts exit 1, the exact stderr, and no `.claude/state/review` or `.scratch/review/<id>`. D10 (moved to a refusal) and D18 (a fenced first list, then a readable second) prove the per-heading count. Each cell failed before its script commit: f455c8f with the old script, f41ddf3, 416a175, a68ef03 and 197c676.
2. A body with no heading briefs byte for byte as before. The writer lane ran `cmp` and `diff -r` on the e710e99 script and on 5f0c725 with the suite's fake gh, over #108 C7/f's body and the fake's fixed body: identical. That run predates the three widenings. At the head, D9 and D12 (a fenced one-`#` comment) assert the brief. The final match, run by hand over the bodies of #90, #93, #103, #105 to #111, #137 and #139, matches only #108's real `### Writer flags 2026-09-23`.
3. When every heading has a readable list, the brief behaves as before. D1, D17 (two readable lists), A8 and every other cell of #108's tables pass unchanged (C6/f excepted, see Decided). The suite passes with ok 1876 at 8aa660a, rerun by the owner. Fix lane 4 also ran the guard by hand over the 12 live bodies, with no refusal. The root's verifiers found zero false refusals over 99 real ticket bodies at 30bdcae.
4. There is no shape-specific parsing. The guard is one line match over the raw body plus a count of the existing parser's records.

Other checks: ShellCheck at the pin over the 26-file set, exit 0, at 8aa660a. `provisional-ids.sh`: 26 passed. `./factory918.sh sync` is clean at 8aa660a. `no-stale-wording.sh`, `review-comment.sh` (298), `delegation.sh` (55) and `overlap.sh` (57) all pass. `./factory918.sh sync` is clean at 42476d3. `build_knowledge.py` then `check_knowledge.py` give knowledge ok, 119 files.

## Reviews

- Round 1: https://github.com/Zenoctra/factory918/pull/142#issuecomment-5803221695, `act-on items: 3`. List-item heading, SKILL.md sentence, invariant comment; fixed by fix lane 1 (f41ddf3, 833fcae, 6128acc). The spec report was sent back once for an indented `Documented step:` line.
- Round 2: https://github.com/Zenoctra/factory918/pull/142#issuecomment-5803555158, `act-on items: 5`. A fenced one-`#` comment was refused (Would break, against criterion 2), a decorated heading was missed, the P139 row lagged, and the regex dialect was inconsistent; fixed by fix lane 2 (416a175, 1f26c5e, 4cc51f5) and the owner (bc5a7e6). Both reports were sent back once for indentation.
- Round 3: https://github.com/Zenoctra/factory918/pull/142#issuecomment-5804075444, `act-on items: 0`, with four items marked `fixed:` (a68ef03, f494d2b, 42476d3). A possessive or plural heading was missed, so the match is now `##+.*writer.*flag`, the test header was rewrapped, and SKILL.md is pinned.
- There were no restarts. Each round's gap was treated as an implementation miss against a criterion that stands, with a dated amendment to the ticket's legend and table (D11, D12 to D14, D15 and D16).
- Trail review (tier-lower, Claude Opus 5): `.scratch/program/139/trail-review/review.md`. check-trail is ok, 10 rows. Settled: 3 fixed (PR body names 5f0c725 for the byte-for-byte run), 4 fixed (P139 states the broad false positive), 5 fixed (ledger line), 2 is under Blocked, and 1, 6 and 7 were dismissed.

## CI

- Run 35932109587 at the head, 8aa660a2a55b934312bbde2e15364484d2888920: success.
- Earlier runs, all success: 35921863647 at 69d6a96, 35923884958 at 6128acc, 35927261638 at bc5a7e6.

## Records

- Provisional P139 in `docs/knowledge/core/DECISIONS.md`, with its generated copy. It records the per-heading count, the final heading match, and C6/f moving from B to RZ. It records how D10 went from an accepted hole to a refusal (8aa660a). It accepts two limits: a line of two or more `#` holding writer then flag, with no read flag under it, is refused; and the refusal header still says "from its body".
- Ledger, two lines: reviewers indented the `Documented step:` line in three of six reports, and skipping the design pass for a pattern over typed text cost three rounds.
- M0 findings: none.
- Ticket #139: `## Testing decisions` was posted before the tests. It has four dated amendments, one per review round and one for the per-heading count. That last one gives criteria 1 to 3's old and new wording.

## Decided

- #108's cell C6/f (a closed fence holding the exact opener and a bare line) moves from brief to refusal. #139's criterion 1 refuses a heading inside a fence. The root's brief said to keep every cell of #108's tables, and the two conflict only in this cell. I followed the ticket, which Manuel approved with "go ahead", and recorded it in P139 and the PR's Tradeoffs.
- The guard runs only after #136's check prints nothing, so every existing refusal keeps its exact message.
- A one-`#` line never counts, since it is a code comment more often than a heading (round 2). The match took the loosest form, `writer` then `flag`, after three rounds of shape-by-shape widening.
- `ticket.md:15` (the writer's playbook sentence) is unchanged. Its "a heading looks like that one and is not" already covers the case (round 2, S3 dismissed).
- The refusal is shown to the orchestrator. The one sentence added to the reviewer-facing SKILL.md states behavior only, with no expected result, cap or reading limit.

## Decided after verification

- Attribution is at-or-above: a read flag that is itself a heading line counts for that line. The script, SKILL.md and SOURCES.md say so.
- The refusal header is unchanged, so every refusal cell keeps its text. It names the exact heading lines; its words "from its body" are loose when another list was read. P139 records this.
- No fourth review round. P20, as #106 amended it, owes another round past three only after a Would-break fix. A hidden second list is an input outside the documented path that went through silently. That is a Fails-open item, and `review-brief.sh` refuses a fourth round without a `would-break fixed after` line.

## Blocked

Nothing. For Manuel's attention, the match and the per-heading count were fixed after the review rounds and were not reviewed again. The root's three verifiers did check them at 30bdcae. They are in `template/.agents/skills/spec-review/scripts/review-brief.sh`.

## Trail

`/Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.scratch/program/139/decisions.tsv`
