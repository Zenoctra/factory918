# #111 owner report

Ticket #111 is done as PR #129. From now on, decision trail rows come only from `log.sh`, and the trail review runs a new script that refuses rows that are out of order or outside the run. CI is green, and review round one found nothing to act on.

## Status

STACK-READY.
- Head: `c183a362e73b88758bdf468a4169619158b47c1d`. `git rev-parse HEAD` and `git ls-remote origin refs/heads/feat/trail-clock` agree.
- Branch: `feat/trail-clock`.
- PR: https://github.com/Zenoctra/factory918/pull/129 (ready, not a draft, MERGEABLE).
- PR base: `feat/review-reading-pack`.
- Patch base: `f58308b5eae3f6617cf3a5200e7679e5737a5702`. The parent head is unchanged on origin.
- Intended parent: PR #126 (ticket #107).

## Overlap

Step 1, `overlap.sh 111`, exit 0:
```
go: autopilot-stack
#120 feat/speed-lessons: SOURCES.md patches/pstack/poteto-mode/playbooks/autonomous-run.md.patch patches/pstack/poteto-mode/playbooks/autopilot-full.md.patch patches/pstack/poteto-mode/playbooks/autopilot-stack.md.patch patches/pstack/poteto-mode/playbooks/babysit.md.patch patches/pstack/poteto-mode/playbooks/bug-fix.md.patch patches/pstack/poteto-mode/playbooks/eval.md.patch patches/pstack/poteto-mode/playbooks/feature.md.patch patches/pstack/poteto-mode/playbooks/hillclimb.md.patch patches/pstack/poteto-mode/playbooks/investigation.md.patch patches/pstack/poteto-mode/playbooks/multi-phase-plan.md.patch patches/pstack/poteto-mode/playbooks/opening-a-pr.md.patch patches/pstack/poteto-mode/playbooks/orchestrate.md.patch patches/pstack/poteto-mode/playbooks/perf-issue.md.patch patches/pstack/poteto-mode/playbooks/refactoring.md.patch patches/pstack/poteto-mode/playbooks/runtime-forensics.md.patch patches/pstack/poteto-mode/playbooks/session-pickup.md.patch patches/pstack/poteto-mode/playbooks/shipping.md.patch patches/pstack/poteto-mode/playbooks/trace-forensics.md.patch patches/pstack/poteto-mode/playbooks/visual-parity.md.patch patches/pstack/poteto-mode/playbooks/worktree-cleanup.md.patch patches/series
#124 feat/reviewer-model-eval: SOURCES.md patches/pstack/poteto-mode/references/provider-dispatch.md.patch patches/series
#125 feat/fix-only-from-round-two: SOURCES.md patches/mattpocock/spec-review.SKILL.md.patch patches/pstack/babysit/SKILL.md.patch patches/pstack/poteto-mode/playbooks/babysit.md.patch
#126 feat/review-reading-pack: SOURCES.md patches/mattpocock/spec-review.SKILL.md.patch
base: origin/feat/review-reading-pack
```
Step 8, `overlap.sh 111 --diff`, exit 0. This is also the PR body's `## Overlap`:
```
go: autopilot-stack
#120 feat/speed-lessons: AGENTS.md SOURCES.md docs/M0-findings.md docs/knowledge/INDEX.md docs/knowledge/core/DECISIONS.md patches/series template/docs/factory918/DECISIONS.md
#121 feat/provisional-ticket-ids: .github/workflows/factory-ci.yml AGENTS.md docs/M0-findings.md docs/knowledge/INDEX.md docs/knowledge/core/DECISIONS.md template/docs/factory918/DECISIONS.md
#124 feat/reviewer-model-eval: .github/workflows/factory-ci.yml AGENTS.md SOURCES.md docs/M0-findings.md docs/knowledge/INDEX.md docs/knowledge/core/DECISIONS.md patches/series template/docs/factory918/DECISIONS.md
#125 feat/fix-only-from-round-two: SOURCES.md docs/knowledge/INDEX.md docs/knowledge/core/DECISIONS.md template/docs/factory918/DECISIONS.md
#126 feat/review-reading-pack: AGENTS.md SOURCES.md docs/knowledge/INDEX.md docs/knowledge/core/DECISIONS.md factory918.sh template/docs/factory918/DECISIONS.md
```

## Criteria

1. Rows are added only through `log.sh`, and the change is carried by a patch, `series` and `SOURCES.md`. The skill's "Logging a row" and `ts` bullet say so. The patch is `patches/pstack/show-me-your-work/SKILL.md.patch`, it is the last line of `series`, and it is `SOURCES.md` item 18. `./factory918.sh sync` leaves `git status` clean; the writer and I both ran it.
2. Out-of-order rows and rows outside the run are refused with a line naming each row. The new script is `template/.agents/skills/show-me-your-work/scripts/check-trail.sh`, and the trail review runs it first. `bash tests/show-me-your-work/check-trail.sh` passes with `ok 66 assertions`, one assertion per cell of the table posted on #111. I ran it, CI ran it, and the writer also ran it on ubuntu:24.04 with mawk and with gawk.
3. The trail is named as the timing record. The skill's `ts` bullet names it as the record the post-mortem tooling reads.

## Reviews

Round 1 reviewed c183a36: https://github.com/Zenoctra/factory918/pull/129#issuecomment-5795711852. The comment ends `round: 1 of 3` and `act-on items: 0`. There was one Consider (test absolute paths that contain a space) and two Noted items. There were no restarts.

The trail review was run by Claude Opus 5 and is at `.scratch/program/111/trail-review/result.md`. The check on my own trail printed `ok: 8 rows in order inside the run`. I settled each item:
- Dismissed: the skill does not name exit 64, but the usage line names the correct call, and a fix commit would move the head past round one for one sentence.
- Kept: detect-only. This is recorded in P111.
- Fixed in the PR body: the mawk and gawk runs are now credited to the writer lane.
- Reran myself: the no-stale-wording check.
- Added as rows: the records commit and the blast-radius skip.

## CI

Run 35866744150 on c183a362e73b88758bdf468a4169619158b47c1d concluded `success`, with Factory and Fixture passing.

## Records

- Provisional P111 says how the trail review checks a trail's clock. The script takes the run's bounds from the transcripts' `timestamp` fields with no slack. A refusal is reported under Attention and does not block merge-ready.
- M0 got one line, dated 2026-09-23. The check gives the same output on macOS awk with jq 1.7.1-apple and on ubuntu:24.04 with mawk and gawk and jq 1.7. Transcript records carry a top-level `timestamp`, except the `custom-title`, `agent-name` and `last-prompt` records. The design lane ran the check on the #88 to #93 trails and it agrees with the post-mortem.
- No ledger line.

## Decided

- Where the run's bounds come from: the transcripts, not typed arguments. This was runner A's design and is the base. Runner B's `run-start` argument would have moved the typing to the reviewer.
- From runner B, the six-column check was grafted in. Its merge-ready block was rejected, because an append-only log could never clear it.
- `check-trail.sh` is ours and listed in `keep_files`, not created by a patch.
- `log.sh` is unchanged, and so is `docs/agents/evidence.md`. The timing-record sentence went into the skill.
- A blank row prints `line N : has 0 columns, expected 6; not a log.sh stamp`. It is cosmetic and I left it.
- Hillclimb step 3's hand-written nine-column `decision.tsv` conflicts with the new rule. I filed it as #128 (needs-triage) and did not widen this PR.

## Blocked

Nothing.

## Trail

`/Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.scratch/program/111/decisions.tsv`. Every row was appended through `log.sh`.
