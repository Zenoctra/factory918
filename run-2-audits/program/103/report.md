# Report: ticket #103, PR #124

The reviewer-model measurement is built, run and reviewed: 24 frozen briefs, a runner with 230 checks, and 375 Claude runs plus 35 Codex runs, with the results in `docs/M0-findings.md` and a provisional choice in P103. Two things wait for Manuel: whether criterion 3's dispatch-matrix rows are waived here, and whether Fable 5.1 may be measured; the partial GPT-6 Astra rows finish when the Codex quota resets.

## Status

STACK-READY, with one open Ask for Manuel (see Blocked).
- Head: `01a1e5f46891d10b234fe9ee80cbd9e8c67d4438` on the root's local branch `chain/124` lineage (my `chain/124-owner`), rebased by the root onto PR #121's head 85988c7 (which sits on #120); the root pushes it. Before the rebase the branch head was `bd6a9b6` on `feat/reviewer-model-eval`.
- Branch: `feat/reviewer-model-eval`. PR: https://github.com/Zenoctra/factory918/pull/124, base `feat/provisional-ticket-ids`.
- Patch base: `86d156a` (origin/main at branch time); now rebased onto 85988c7. Parent in the chain: #121 (`feat/provisional-ticket-ids`).

## Overlap

Step 1 (`overlap.sh 103`):
```
go: autopilot-stack
base: origin/main
```
Step 8 (`overlap.sh 103 --diff`, exit 0, at the final head):
```
go: autopilot-stack
#120 feat/speed-lessons: AGENTS.md SOURCES.md docs/M0-findings.md docs/agents/ledger.md docs/knowledge/INDEX.md docs/knowledge/core/DECISIONS.md patches/series template/docs/factory918/DECISIONS.md
#121 feat/provisional-ticket-ids: .github/workflows/factory-ci.yml AGENTS.md docs/M0-findings.md docs/agents/ledger.md docs/knowledge/INDEX.md docs/knowledge/core/DECISIONS.md template/docs/factory918/DECISIONS.md
```
The AGENTS.md, factory-ci.yml, SOURCES.md and patches/series overlaps are the review-round fixes (the reviewer test in the ShellCheck gate and CI) and the provider-dispatch patch; the root resolves them at chain time.

## Criteria

1. Fixture set: `tests/eval/reviewer/rounds/` (12 rounds, 24 briefs byte-identical to what the reviewers read; 6 surviving, 6 regenerated with the head's own review-brief.sh and a gh stub, method proven on the 6 survivors), `labels` (13 hard findings), `reviewer.py check` prints 13 `ok`. Each round's `inputs/` holds the ticket body, the `--previous` comments, the blast-radius grounding (#96 rounds) and a recipe, and `bash tests/eval/reviewer/rebuild.sh <round>` rebuilds its briefs and diff with no network call: all twelve print `identical`, and the comparison pins `ticket.md` and `blast-radius.md` byte for byte: a one-byte change to either makes it exit 1. `previous.txt` only has to exist, because no brief in the set has a `## Settled in earlier rounds` section and the recipe's `--round` sets the round, so its contents reach no brief. The recipe's `script_at`, `fixed_point`, `ticket` and `round` are pinned in effect, since changing any of them changes the brief or the diff. It is not a CI assertion: CI's checkout is depth 1 and fetches no `refs/keep/*`, so `rebuild.sh` would exit 2 there; a job with `fetch-depth: 0` and `git fetch origin 'refs/keep/103/*:refs/keep/103/*'` could run it, which is a workflow change left to the root.
2. Runner: `tests/eval/reviewer/reviewer.py` (check, run, collect, table); `bash tests/eval/reviewer/refusals.sh` passes 230 checks, now also in CI and the ShellCheck gate. Receipts carry input, output, cache read and write tokens and wall clock; a report without `hard findings:` is a context failure.
3. Results: Sonnet 71 clean runs, Opus 5 72, Opus 5.5 72, every brief at N of at least 3 except Sonnet `pr101-r1/standards` (2 clean after 4 contaminated; no label on it). Fable 5.1, GPT-6 Terra and GPT-6 Sol have dropout receipts (24 each). Provider facts went into `provider-dispatch.md` as dated notes through a new patch, not as matrix rows (see Blocked). GPT-6 Astra, the served GPT-6 model, is measured partially (35 of 72 runs).
4. Table: `docs/M0-findings.md`, "Which reviewer model finds the hard bugs (2026-09-23)". The main table is `reviewer.py table` output; the dropout table's third column is edited by hand, as the section says. with a blinded-judge audit (anchors agree on 115 of 116 Claude decisions and 28 of 31 Astra decisions).
5. Recommendation: P103 in DECISIONS.md Provisional (Standards: gpt-6-astra, provisional until two missing runs; Spec: Opus 5.5) and the proposed sheet change in the PR body; the sheet is not edited.
6. Design: posted on #103 before the runner (2026-09-22), amended 2026-09-23 after round 1's design hole (rows 22 to 24 and contract sentences); refusals.sh asserts every cell.

## Reviews

- Round 1: https://github.com/Zenoctra/factory918/pull/124#issuecomment-5789955187, `act-on items: 3`, `restart` (hole at criterion 6).
- Restarted round 1: https://github.com/Zenoctra/factory918/pull/124#issuecomment-5790110116, `act-on items: 5`.
- Round 2: https://github.com/Zenoctra/factory918/pull/124#issuecomment-5790237925, `act-on items: 2`. [P1] was fixed by f8fdfad (P103 rewritten after the second astra window). [S1] ("P103 leaves the Provisional id sequence") had no fix commit and no Ask: #121's rule makes the ticket number the row id, and round 3 re-sorted it to Consider ([S5]).
- Round 3: https://github.com/Zenoctra/factory918/pull/124#issuecomment-5791372960, `act-on items: 1` (the Ask), `would-break fixed after f8fdfade08f5a8fe3e9fe5ba0c2cd12a75383db5`.
- Round 4 (fix only): https://github.com/Zenoctra/factory918/pull/124#issuecomment-5791417181, `act-on items: 0`.
- Trail review (Claude Opus 5, read-only): `.scratch/program/103/trail-review.md` under the owner worktree; its items were answered by trail rows and commit 155d7d8.

## CI

Run 35838300531 on `bd6a9b60fbd2f533f71a8cb81aeb28d12f1d4b51`: success. The rebased head 01a1e5f gets its CI run when the root pushes it. Local gates at 01a1e5f: ShellCheck clean over 23 files, refusals.sh 230 passed, check_knowledge ok, build_knowledge and sync leave the status clean, provisional-ids 26 assertions passed (details in rebase-check.md).

Verifying lines run at bd6a9b6: the AGENTS.md ShellCheck line (22 files before the rebase, 23 on the chain at 01a1e5f, clean), gate.sh, delegation.sh, review-comment.sh, review-brief.sh, overlap.sh, refusals.sh (230), `reviewer.py check` (13 ok), build_knowledge plus check_knowledge, and `./factory918.sh sync`, with `git status` clean after.

## Records

- Provisional: P103 "Which model runs each review axis" (id per the root's instruction and #121).
- Ledger: "as the #103 owner, launched 23 reviewer lanes in one message and hit the harness's 20-subagent cap ..." and "as the #103 owner, planned 72 Codex runs without checking the ChatGPT account's quota ...".
- M0: the section "Which reviewer model finds the hard bugs (2026-09-23)" (Claude Code 2.1.280, Codex CLI 0.154.0; served ids `claude-sonnet-5`, `claude-opus-5`, `claude-opus-5-5`; results, audit, harness facts).

## Decided

- Claude runs go through the session's Agent tool, because the standalone claude CLI is not logged in; tokens come from subagent transcripts.
- Astra measured in place of Terra and Sol (refused to the account); P103's Standards pick is Astra, provisional on 16 of 18 label offers.
- Contaminated runs (reviewers reading outside their exported tree, mostly Sonnet) are excluded and topped up.
- Provider facts as notes, not matrix rows, because model-matrix.test.ts pins four families. The PR body now says the Astra matrix row waits on Manuel's answer to round 3's Ask (no ticket filed), and phrases the Spec proposal as the lower tier (Claude Opus 5) to the upper tier (Claude Opus 5.5).
- The 15 `refs/keep/103/*` refs were pushed to origin (round 3's Would-break fix), so a fresh clone can fetch the reviewed heads.
- Effort was medium on every Claude run (not settable per call).

## Blocked

- Round 3 Ask: criterion 3 asks for provider-dispatch matrix rows; the PR adds notes because the matrix test allows four families. Manuel decides whether to waive the rows here or file the matrix change (which also gates the proposed `codex:gpt-6-astra` sheet row).
- Fable 5.1 was not measured under the rule "never launch Fable"; measuring it needs Manuel's go (`reviewer.py run claude:fable-5.1 ...` is wired, as withheld).
- Codex quota: 37 Astra runs are usage-limit dropouts; the next window opens at 12:46 UTC 2026-09-23. `reviewer.py run codex:gpt-6-astra <brief> 3` over the set finishes them; P103's Standards pick needs `pr99-r1b/standards` k=2 and k=3. `gpt-6-luna` appeared in the models cache later and was not probed.

## Trail

/Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.scratch/program/103/decisions.tsv
