# Ticket #93, owner lane

PR #102 adds the extra review rounds for a Would-break fix: the comment names the fix and the reviewed commit, the brief allows a fix-only round four and five from that commit and refuses a sixth, and a PR that ends at round three prints exactly what it printed before. It is open against `feat/spec-walk-risks` at the head below, CI green, reviewed in two rounds with zero hard findings, marked ready; the root lands it.

## Status

STACK-READY

- Head SHA: `fc75ac69712119bb0e921e348a54b4d857c41b07` (`git rev-parse HEAD` and `git ls-remote origin refs/heads/feat/would-break-extra-rounds` agree)
- Branch: `feat/would-break-extra-rounds`
- PR: https://github.com/Zenoctra/factory918/pull/102 (ready for review, not a draft; `closingIssuesReferences` lists #93 after the root's retarget through `main` and back)
- PR base branch: `feat/spec-walk-risks`
- Patch base SHA: `d8e382ca37233bce98724c785ecdbb677abc4e2a` (PR #101's head, confirmed by `git fetch origin feat/spec-walk-risks` before branching)
- Intended parent: ticket #91 (PR #101), the top of the chain, per the root's topology decision
- Commits above the base, in order: `41ce420` tests from the tables, `27c43af` the scripts, `1998c69` prose and patches, `7b01fd6` records, `fc75ac6` the round-one fixes

## Overlap

Step 1 (`.claude/skills/poteto-mode/scripts/overlap.sh 93`), verbatim:

```
go: autopilot-stack
#96 feat/shellcheck: tests/spec-review/fake-gh.sh tests/spec-review/layout.sh tests/spec-review/review-brief.sh tests/spec-review/review-comment.sh
#99 feat/design-hole-restart: tests/spec-review/no-stale-wording.sh tests/spec-review/review-brief.sh tests/spec-review/review-comment.sh
#101 feat/spec-walk-risks: tests/spec-review/review-brief.sh tests/spec-review/review-comment.sh
base: origin/feat/spec-walk-risks
exit: 0
```

The printed base matched the root's decision (no containment fallback), so the branch was made from `d8e382c`.

Step 8 (`overlap.sh 93 --diff`), verbatim, the run after the root linked the ticket; the first run, before the PR existed, printed the same four lines without the records commit's files, both exited 0, and no exit 1 was seen at any step (the file is `overlap-step8-final.txt` beside this report):

```
go: autopilot-stack
#94 feat/design-artifact-on-ticket: SOURCES.md docs/agents/ledger.md docs/knowledge/INDEX.md docs/knowledge/core/DECISIONS.md docs/knowledge/core/MANUAL.md template/.agents/skills/poteto-mode/playbooks/ticket.md template/docs/factory918/DECISIONS.md template/docs/factory918/MANUAL.md
#96 feat/shellcheck: SOURCES.md docs/agents/ledger.md docs/knowledge/INDEX.md docs/knowledge/core/DECISIONS.md template/.agents/skills/spec-review/scripts/review-brief.sh template/.agents/skills/spec-review/scripts/review-comment.sh template/docs/factory918/DECISIONS.md tests/spec-review/review-brief.sh tests/spec-review/review-comment.sh
#99 feat/design-hole-restart: SOURCES.md docs/agents/ledger.md docs/knowledge/INDEX.md docs/knowledge/core/DECISIONS.md docs/knowledge/core/MANUAL.md patches/mattpocock/spec-review.SKILL.md.patch patches/pstack/babysit/SKILL.md.patch patches/pstack/poteto-mode/playbooks/babysit.md.patch template/.agents/skills/babysit/SKILL.md template/.agents/skills/poteto-mode/playbooks/babysit.md template/.agents/skills/poteto-mode/playbooks/ticket.md template/.agents/skills/spec-review/SKILL.md template/.agents/skills/spec-review/scripts/review-brief.sh template/.agents/skills/spec-review/scripts/review-comment.sh template/docs/agents/review-ladder.md template/docs/factory918/DECISIONS.md template/docs/factory918/MANUAL.md tests/spec-review/no-stale-wording.sh tests/spec-review/review-brief.sh tests/spec-review/review-comment.sh
#101 feat/spec-walk-risks: SOURCES.md docs/agents/ledger.md docs/knowledge/INDEX.md docs/knowledge/core/DECISIONS.md patches/mattpocock/spec-review.SKILL.md.patch template/.agents/skills/poteto-mode/playbooks/ticket.md template/.agents/skills/spec-review/SKILL.md template/.agents/skills/spec-review/scripts/review-brief.sh template/docs/factory918/DECISIONS.md tests/spec-review/review-brief.sh tests/spec-review/review-comment.sh
exit: 0
```

## Criteria

1. "A round whose Act on items include a Would-break fix is followed by another round, past three, up to five ... `review-brief.sh` reads the kind of the fixed items from the previous round's comment and refuses a sixth round." Proven by `tests/spec-review/review-comment.sh` cells 3A to 3D, 2B, 2C, 6B and `tests/spec-review/review-brief.sh` cells 3A, 9A, 2A, 8A, 11A, 11B, 15A (labels as in the ticket's tables), all green at the head; the writer's end-to-end run through rounds three, four, five and the refused sixth is in `writer-report.md`.
2. "A round past three reviews the fix only: its fixed point is the commit the previous round reviewed, and the Ticket playbook and `spec-review` say so." Brief test cells 3A and 9A (`## Commits` holds only the fix commit; `## The fix under review` in both briefs), 4A, 5A, 10A (a wrong or unresolvable fixed point refused); `spec-review/SKILL.md` step 1 and `ticket.md`'s `### Would-break fix` section, corrected in round one to scope the fix-only command to a line on a round-three or round-four comment.
3. "No rule compares hard-finding counts between rounds. The orchestrator's prose in `spec-review` step 5 says ..." The step 5 paragraph after the design-hole paragraph carries the two stops; no script compares counts; the summary line is byte-identical in every `accept` expectation (no Would-break count printed); babysit's sentence reads `round: 5 of 5` with the line as a wait.
4. "`babysit`'s merge-ready condition reads the same comment lines and is unchanged for a PR that ends at round three." Both copies read `act-on items:`, `round:` and the new line only; the brief test pins the sentence in both files; comment-test cells 1B and 2B print today's tail; the three `F4` assertions pass byte for byte; the 476 and 150 base assertions pass unchanged except the three the ticket names. Noted at step 4: this criterion was already true at the base (a regression guard), kept as verification rather than sent back.
5. "`tests/spec-review/` covers a round four with a fix-only fixed point and the round-five stop." Brief cells 3A, 4A, 9A, 10A, 11A; comment cells 3C, 3D.
6. "P20 amended; `docs/agents/review-ladder.md` says the same in one sentence." `docs/knowledge/core/DECISIONS.md` P20 (the 2026-09-22 amendment, commit 7b01fd6) and `template/docs/agents/review-ladder.md` rung 1 (commit 1998c69, wording fixed in fc75ac6).

## Reviews

- Round 1: https://github.com/Zenoctra/factory918/pull/102#issuecomment-5783722681, `act-on items: 0`, `round: 1 of 3`; 0 hard findings on both axes; three Standards breaches fixed in `fc75ac6` and marked `fixed:`, one smell Noted. The comment's two sentences say the review could end at round one; that was wrong (Manuel's Decision quote allows an unreviewed non-hard fix only from round three), so round two ran from the same fixed point and reviewed the fixes.
- Round 2: https://github.com/Zenoctra/factory918/pull/102#issuecomment-5783855182, `act-on items: 0`, `round: 2 of 3`, on the latest commit `fc75ac6`; 0 hard findings on both axes; three Standards points Noted (a step 4 bullet's position, the duplicated heading lookup, a ragged comment wrap), none worth a round; no fix after the reviewed commit, so the PR is review-ready by the base rule.
- Restarts: none.

## CI

- Run 35779526784 on `7b01fd6`: completed, success (Factory and Fixture jobs).
- Run 35781166757 on `fc75ac6`: completed, success. Round two reviewed this commit; no further push.

## Records

- `docs/knowledge/core/DECISIONS.md` P20, Choice cell: "Amended 2026-09-22 (#93): from round three on the Act on items are fixed before the comment and the round may be the last, unless a fixed item sits under `## Would break` in its report: then `review-comment.sh` prints `would-break fixed after <sha>` ... at five with Would-break items still found the orchestrator reports to the human and marks the PR unfinished (P30)." Reason cell: "Amended 2026-09-22 after #93: Manuel, "never leave a hard bug change unreviewed" ...".
- `docs/knowledge/core/DECISIONS.md` P30, new: "Round five's stop is a draft and a report" (the fix-and-mark at five, the report comment, `gh pr ready --undo`, and the three rejected alternatives).
- `docs/agents/ledger.md`: "2026-09-22 | Claude Fable 5.1 | as the #93 owner lane, took over from a lane a rate limit had killed mid-architect ... | a killed lane's scratch is input, never a result ...".
- `docs/M0-findings.md`: no line; no new tool-version fact was verified in this lane.
- Generated copies rebuilt (`template/docs/factory918/DECISIONS.md`, `docs/knowledge/INDEX.md`), commit `7b01fd6`.

## Decided

- The design (arena: fable candidate as base, six grafts from the opus candidate, no cross-judge since both converged on one shape): one conditional comment line `would-break fixed after <sha>`; the cap digit by round only (`of 5` from round four), not by the judgment; the line never beside `restart`; the reviewed commit recorded once in `<dir>/reviewed`; a malformed line refused; a fix-only round with no ticket after a round with a spec refused rather than warned; `## The fix under review` carries the fixed items; the sweep form after a line is refused by the existing fixed-point check.
- Round five: fix and mark as at any last round, post, report as its own PR comment (no line starting `act-on items:`), convert the PR to a draft, continue other work, wait. Leaving the items unfixed was rejected because babysit reads a nonzero count as a blocker to fix here. Recorded as P30 for Manuel to promote or overrule.
- Criterion 4 already held at the base; kept as a verification guard, not sent back.
- The writer's nine deviations (fixture details, `wb_first`/`wb_line` names, `F5` printing "round 0" for `--round 5` with no comment) accepted; none changes a cell. The `F5` wording for the no-comment case is the template with `top` = 0 and could read better; left as is (an input outside the path).
- Round one's judgment ended the review with marked standards-breach fixes; corrected by running round two, since Manuel's quote allows unreviewed non-hard fixes only from round three. The posted round-one sentences stand as the record; round two's sentences say so.
- The PR was opened against `feat/spec-walk-risks` per the root's decision, not retargeted by this lane; the root did the one retarget through `main` that linked #93. P29 (the #91 lane's provisional row) says a stacked PR is opened against trunk and retargeted; the root's instruction took precedence here and the root may want to reconcile P29 with its topology rule.
- Interrogate skipped: the two architect candidates converged and no reviewer contested the design.

## Blocked

- Nothing waits on Manuel for this lane. P30 (the draft as the round-five mark, `gh pr ready --undo`) is a decision he may overrule; the guard hook blocks only the merge command, so the draft command is allowed, but it was not exercised on a real PR in this lane.
- The step 8 check did not exit 1 in this lane (the root linked the ticket before the check was rerun), so there is nothing to record under an empty closing reference.

## Trail

`/Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.scratch/program/93/decisions.tsv` (24 rows), beside `todo.md`, `how/how.md`, `arch/` (frame, both candidates, synthesis note, the posted table), `design-constraints.md`, `writer-brief.md`, `writer-report.md`, `fix1-report.md`, `pr-body-final.md`, the two review comments, the overlap outputs and the posted ticket body.
