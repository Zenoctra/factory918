# #106 owner report (after the design-hole restart)

PR #125 lets review round three read only round two's fixes when round two found no hard bug outside them. It also marks a round-one or round-two review that fixed items before posting as not ready. The root's audit found that the first rule let plain quotes of untouched code count as inside the fix. The rule was redesigned, the ticket was amended, and the review restarted. The PR is green, the new round one found nothing to act on, and it is ready to stack again.

## Status

STACK-READY.
- Head: `0edf8c8952e7563ec862e460f71becde4506bd96`. `git rev-parse HEAD` and `git ls-remote origin refs/heads/feat/fix-only-from-round-two` agree.
- Branch: `feat/fix-only-from-round-two`.
- PR: https://github.com/Zenoctra/factory918/pull/125, ready for review.
- Base branch: `feat/reviewer-model-eval`.
- Patch base: `01a1e5f46891d10b234fe9ee80cbd9e8c67d4438`.
- Intended parent: #124 (ticket #103).
- `closingIssuesReferences` now lists #106.
- Fixes after the root's findings are new commits on caecbc4: 8fd83e1, f33a08a, 8d3496a, 0edf8c8. Nothing was rebased.

## Overlap

Step 1 (`overlap.sh 106`):
```
go: autopilot-stack
#120 feat/speed-lessons: docs/knowledge/core/DECISIONS.md
#121 feat/provisional-ticket-ids: docs/knowledge/core/DECISIONS.md template/.agents/skills/spec-review/scripts/review-brief.sh tests/spec-review/review-brief.sh
#124 feat/reviewer-model-eval: docs/knowledge/core/DECISIONS.md
base: origin/feat/reviewer-model-eval
```
Step 8 (`overlap.sh 106 --diff`, exit 0). The redo touched no new paths.
```
go: autopilot-stack
#120 feat/speed-lessons: SOURCES.md docs/knowledge/INDEX.md docs/knowledge/core/DECISIONS.md docs/knowledge/core/MANUAL.md patches/pstack/poteto-mode/playbooks/babysit.md.patch template/.agents/skills/poteto-mode/playbooks/babysit.md template/docs/agents/review-ladder.md template/docs/factory918/DECISIONS.md template/docs/factory918/MANUAL.md tests/spec-review/no-stale-wording.sh
#121 feat/provisional-ticket-ids: docs/knowledge/INDEX.md docs/knowledge/core/DECISIONS.md template/.agents/skills/spec-review/scripts/review-brief.sh template/docs/factory918/DECISIONS.md tests/spec-review/review-brief.sh
#124 feat/reviewer-model-eval: SOURCES.md docs/knowledge/INDEX.md docs/knowledge/core/DECISIONS.md template/docs/factory918/DECISIONS.md
```

## Criteria

The design is #106's `## Testing decisions`, posted 2026-09-23. It now carries a dated amendment for the hole at table B row 2 column B, and a dated line on cell 21A. Each cell has one labeled assertion, or a one-line reason in the test and on the ticket.
1. Rounds one and two brief byte for byte as before. The `same` helper in brief cells 2A to 4C and 12A compares stdout, `diff` and both briefs against the history with the new lines deleted.
2. Round three is fix-only only when no round-two hard item is outside the fix. It stays fix-only after that.
   - Comment table B rows 1 to 8, 12, 14 and 15.
   - Row 14 is the audit's reproduction. A plain quote at `old.sh:40` shares `exit 0` or `else` with the fix, and no `fix only after` line prints. The same run against caecbc4 printed one.
   - Brief rows 4, 5 and 12 to 18.
3. The fixed point, `FP`, `FR`, `FT` and the fix section: brief rows 5, 7 to 11 and 16, with their B and C columns.
4. The `next round owed` line: comment rows 7 and 8, and the babysit sentence pinned in both copies.
5. Tests come first. 7b7d1fb and 8fd83e1 hold the tests, and each fails at its first new cell. aa155fc and f33a08a hold the scripts.
   - Point 2 from the root: 7C, 8B, 8C, 9B, 9C, 10B, 10C, 11B, 11C, 12B, 12C, 13C, 15C, 16B, 16C, 17C, 18B, 18C, 19B, 19C and 21A now have assertions.
   - 6B, 6C, 20B, 20C and 21B carry a written reason instead.
6. #93's cells 13B, 5C and 5D have direct assertions.
7. `spec-review/SKILL.md` steps 1, 4 and 6 are changed through the patch. P20 is retitled and amended.

Suites at 0edf8c8:
- `review-brief.sh`: 1104 assertions pass. `review-comment.sh`: 298 pass.
- `no-stale-wording.sh`: clean. ShellCheck: 23 files, no findings. `shellcheck/gate.sh`: 17 pass.
- `delegation.sh`: 55 pass. `overlap.sh`: 57 pass. `provisional-ids.sh`: 26 pass. `eval/reviewer/refusals.sh`: 230 pass.
- `build_knowledge.py` and `./factory918.sh sync` both leave `git status` clean. `check_knowledge.py` passes.

## Reviews

- **5792617219, voided.** It first held #124's comment by mistake, from the shared scratchpad. It now holds a note with no `act-on items:` line.
- **5792623153, round one on the first design.** `act-on items: 0`.
- **5792876117, round one rebuilt with `restart`.** It adds one Would-break item, `[P1]`, marked `hole: table 2/B`. The owner added P1 to the Spec report from the root's audit, section 7, and the comment's opening says so. Its tail reads `act-on items: 0`.
- **5793367657, round one after the restart, on 0edf8c8.** `act-on items: 0`. Both axes found 0 hard items. Standards raised 2 smells, both judged Consider: the fix-line trim rule is written in both scripts, and `outside()` reads zero hard items the same with or without fix files.

Restarts: one.

Trail reviews, both by Claude Opus 5:
- `trail-review.md`, 9 flags.
- `trail-review-2.md`, which confirms the root's four points are closed and reproduces the hole fix independently. Its flags are settled in the trail.

## CI

Run 35849516283 on head 0edf8c8952e7563ec862e460f71becde4506bd96 concluded success. The earlier run 35844249945 passed on caecbc4.

## Records

- DECISIONS.md P20 is retitled "Review rounds: three, five after a Would-break fix, fix-only from round three". Its amendment is dated 2026-09-23 (#106) and names `fix-lines` and `fix-ranges`.
- DECISIONS.md P106 (Provisional) holds the amended inside rule, the hole that led to it, and the options rejected.
- The ledger line stays off the branch, as the root directed. It is in `.scratch/program/106/ledger-line.md` for the root to add at chain time.
- No M0 line.

## Decided

- **The inside rule.** A round-two hard item is inside the fix only when three things hold:
  - It quotes at least one `+` line of four characters or more.
  - Every `+` or `-` line it quotes is a `+` line the fix commits added, and that text occurs exactly once across the HEAD versions of the files round two reviewed.
  - Every `path:N` or `path:N-M` in its unfenced lines names exactly one of those files, at lines inside one range the fix commits changed. This includes its `Documented step:`.
- **What counts as outside.** Everything else. That covers:
  - a plain-code quote, or no quote at all;
  - a removed line;
  - a repeated text such as `exit 0` or `else`;
  - a quoted `---` or `+++` header;
  - a location anywhere else.
- **What the rule costs and why it holds.**
  - None of the 13 real hard items in `tests/eval/reviewer/rounds/` would read inside. In practice, fix-only means round two found no hard bug.
  - One case still reads inside with no location check: an item that quotes a unique fix-added `+` line and names no file. That was accepted, because a text that occurs once can only have come from the fix.
- **The fix files.** The brief computes `fix-lines` and `fix-ranges` at the reviewed commit, so the comment script stays free of git.
- **Stickiness.** "Once fix-only, every later round is" takes no code. The rule decides round three only, and rounds four and five exist only as #93's fix-only rounds.
- **The comment lines.** `reviewed: <sha>` at round one, `fix only after <sha>` at round two, and `next round owed: round <N> reviews the fixes marked here`.
- **The fix section at round three.** `## The fix under review` lists every Act on item not marked `ticket:`.
- **Cell 21A.** It asserts 5A's lines over a CRLF history, not 21C's. Over gh, round one's settled items carry. A dated line on the ticket records this.

## Blocked

Nothing blocks the stack. For the root and Manuel:
- **A simpler rule, for Manuel to decide.** Fix-only could require that round two reports no hard item at all. That would drop the inside rule, `fix-lines`, `fix-ranges` and the `reviewed:` line. It gives the same verdict on every real round two measured. P106 records it as a follow-up ticket if Manuel agrees. No ticket was filed.
- **Round two with no findings.** A round two with zero hard items licenses fix-only whatever the reason. An empty or crashed reviewer lane is refused earlier, because `review-comment.sh` requires both reports in shape.
- **No model outside the Claude family.** Every lane in this run was Claude, so the trail review's "different model family" requirement cannot be met with the pinned tiers. Both trail reviews flagged it.
- **The #103 owner's `pr-body.md`.** Earlier in the run, this lane overwrote that file in the shared scratchpad.

## Trail

`/Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.scratch/program/106/decisions.tsv`
