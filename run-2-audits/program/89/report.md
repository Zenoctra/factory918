# Report: ticket #89, owner lane

Ticket #89 is implemented on PR #94, reviewed three times (five findings fixed in round 1, none in rounds 2 and 3), green in CI at every head, and ready for the root to stack on. The root's verification at 78be65e returned three findings; the `## Fix round` section below says what changed for them. The change is prose and patches, plus one two-token change to `overlap.sh` that a review finding forced, with a test cell and a dated amendment on #42's design record.

## Status

STACK-READY.

- Head SHA: `715100c12a8eef8d9f2eb547769404c1f9ce7ab1` (`git rev-parse HEAD` in `.claude/worktrees/owner-89`; `git ls-remote origin refs/heads/feat/design-artifact-on-ticket` prints the same).
- Branch: `feat/design-artifact-on-ticket`.
- PR: https://github.com/Zenoctra/factory918/pull/94 (open, ready for review, not a draft).
- PR base branch: `main`.
- Patch base SHA (branched from): `ab47eb91fa42a896c1eec054e526b615b5cbf316` (`origin/main` at the start of the run).
- Intended parent: `main` (no PR was open at step 1).
- Commits on the branch, oldest first: 3b48036, 5c0f2bf, 02af48c, 0cf6b34, 1662392, c83f166 (the six the writer delivered), b368116, 3f5033f, ca2c106, 0c63fa6 (the four round-1 fixes), 78be65e (records), 715100c (the fix round after the root's verification).
- Not merged, no auto-merge, the issue is open, nothing rebased after the first push.

## Overlap

Step 1, `overlap.sh 89` at ab47eb9 (exit 0):

```
go: autopilot-stack
base: origin/main
```

Step 8, `overlap.sh 89 --diff` at c83f166 when the PR opened: printed nothing, exit 0 (no `## Overlap` section then).

Step 8 rerun at 78be65e after the round-1 fix, and again at 715100c with the same nine paths, exit 0 (now the PR body's `## Overlap` section):

```
go: autopilot-stack
#96 feat/shellcheck: AGENTS.md SOURCES.md docs/M0-findings.md docs/agents/ledger.md docs/knowledge/INDEX.md docs/knowledge/core/DECISIONS.md template/.agents/skills/poteto-mode/scripts/overlap.sh template/docs/factory918/DECISIONS.md tests/poteto-mode/overlap.sh
```

PR #96 closes #88 and branched from `main` too; the go covers it. Both PRs edit `template/.agents/skills/poteto-mode/scripts/overlap.sh` and `tests/poteto-mode/overlap.sh` (this PR: the awk skip regex at line 48, the header comment, one test cell after check 17) and append to the same record files; the root resolves those at chain time.

## Criteria

Each measured at 78be65e in the worktree; each was 0 or absent at ab47eb9 (falsifiability pass, decisions.tsv row `ticket-4`).

1. `architect`'s runner prompt makes the scenario table, then the contract, then the test list the first deliverable for a design with state, else the usage and signature sketch, posted under `## Design`: `template/.agents/skills/architect/references/runner-prompt.md` line 7 (the "With state" bullet) and line 10 (the posting sentence naming `## Testing decisions` and `## Design`); patch `patches/pstack/architect/references/runner-prompt.md.patch`, `series`, `SOURCES.md` item 14. `grep -c -i "scenario table"` on the file: 1. After round 1, `architect/SKILL.md` Phase B (line 32) says the same in one sentence, through `patches/pstack/architect/SKILL.md.patch`.
2. The runner prompt says a cell outside the intended path reads "refused with the tool's own message" and is cut only after the refusal was run and seen: same file, line 7; `grep -c "refused with the tool's own message"`: 1.
3. Ticket step 6 says the table goes on the ticket under `## Testing decisions` before implementation, first line `Posted by the agent <date>` or `Approved by <name> <date>`, the human edits it, a stop only with `/architect with checkpoint`, and the Spec brief carries it because `review-brief.sh` pastes the body: `template/.agents/skills/poteto-mode/playbooks/ticket.md` line 10; `grep -c "Posted by the agent"`: 1. After round 1 the step also says to read the body first and write the whole file back (`gh issue edit --body-file` replaces), to stop on a failed write, and that the step-1 check skips the two sections. `template/docs/agents/issue-tracker.md` and `docs/agents/issue-tracker.md` (identical) name the two sections in the ticket body shape.
4. The Feature, Bug fix, Refactoring and Perf issue delegation steps say the test is written from the table before the implementation, one assertion per cell, and a writer that cannot implement a cell stops and reports it: `feature.md` step 4, `bug-fix.md` step 3, `refactoring.md` step 5, `perf-issue.md` step 3; `grep -c "one assertion per cell"`: 1 in each; the four patches regenerated, `SOURCES.md` item 13 amended.
5. `to-spec`'s Testing Decisions names the table as the shape for stateful work: `template/.agents/skills/to-spec/SKILL.md` line 66; `grep -c -i "scenario table"`: 1; patch `patches/mattpocock/to-spec/SKILL.md.patch`, `series`, `SOURCES.md` item 15.
6. One knowledge page reachable through `/knowledge scenario table`: `docs/knowledge/core/SCENARIO-TABLE.md` (sixth core document, `CORE_DOCS` tuple in `tools/build_knowledge.py`), its row in `docs/knowledge/INDEX.md`, its slim copy `template/docs/factory918/SCENARIO-TABLE.md`; `rg -c -i "scenario table"`: INDEX 1, page 5, slim copy 4; a `Scenario table` glossary entry; `AGENTS.md` line 9 and the `knowledge` skill's slim list count it; `MANUAL.md` "Where to read more" lists it.

Repository checks at 78be65e (also run at c83f166 and 0c63fa6): `./factory918.sh sync` with no `FAILED` line, `git diff --exit-code` and an empty `git status --porcelain template`; `python3 tools/check_knowledge.py && python3 tools/build_knowledge.py && git diff --exit-code` (`knowledge ok: 119 files`); `bash -n factory918.sh`; `tests/hooks/delegation.sh`, `tests/spec-review/review-comment.sh`, `tests/spec-review/review-brief.sh`, `tests/poteto-mode/overlap.sh` (57 assertions), `tests/spec-review/no-stale-wording.sh`; all seven patches reproduce byte for byte with the `patches/README.md` command; `shellcheck` 0.11.0 clean on `overlap.sh` and its test (rule 8); the two `issue-tracker.md` copies identical. The fixture flow ran in CI.

## Reviews

- Round 1 (fixed point ab47eb9, head c83f166): https://github.com/Zenoctra/factory918/pull/94#issuecomment-5779120191. `round: 1 of 3`, `act-on items: 5`. Standards `hard findings: 1`, Spec `hard findings: 4`. Act on: [S1] `gh issue edit --body-file` replaces the body; [P1] and [S5] the posted table's backticked paths feed `overlap.sh`; [P3] two documents still count four; [P4] a failed post has no stop clause. Consider: [P2] `architect/SKILL.md` still says usage first; [S2] the to-spec bullet exempts only snippets. Noted: [S3] `SOURCES.md` line 3 (filed as quick ticket #95); [S4] the repeated writer sentence. No restart: none of the findings changes a criterion or a Decision quote; all were fixed on the PR in commits b368116, 3f5033f, ca2c106, 0c63fa6 (the two Consider items too).
- Round 2 (fixed point c83f166 per rule 7, head 0c63fa6): https://github.com/Zenoctra/factory918/pull/94#issuecomment-5779392389. `round: 2 of 3`, `act-on items: 0`. Both reports `hard findings: 0`. One Noted item: the awk match is case-sensitive and `to-spec` spells its spec section `Testing Decisions` (off the path). No further round owed.
- Round 3 (fixed point 78be65e, head 715100c, only the fix after the root's verification): https://github.com/Zenoctra/factory918/pull/94#issuecomment-5779823400. `round: 3 of 3`, `act-on items: 0`. Both reports `hard findings: 0`, no item in any bucket; the Spec walk checks the `### ` case against the awk line and the test fixture. The three-round budget is spent.
- All three comments were posted only after my own `review-comment.sh <dir>` rerun exited 0 with an identical rebuild. The records commit 78be65e (two record lines) was reviewed by no round of its own; round 3's fixed point was 78be65e, so its diff was not in that round either. CI is green on it.

## CI

- 35745145787, c83f166, success (`pull_request`).
- 35747733851, 0c63fa6, success.
- 35748776685, 78be65e, success.
- 35751505990, 715100c, success.

## Records

- `docs/knowledge/core/DECISIONS.md`, Provisional: new row P25 "The design artifact on the ticket" (the rule, the three choices made in #89, the reason with the ticket's quotes and the #87 versus #92 counts; 2026-09-22). Row P24's clause on the sections `overlap.sh` excludes amended: "(its `## Diff`, `## Testing decisions` and `## Design` sections excluded; amended 2026-09-22 by #89 so a posted table's example paths do not count)".
- `docs/agents/ledger.md`: `2026-09-22 | fable | ended its turn while two explorer lanes were still reading, the harness removed its worktree, and both lanes died without a report | drain every lane before the turn ends; a lane with no worktree cannot report` and `2026-09-22 | fable | the round-1 review lane ended its turn while its two reviewer lanes were still running, the same mistake the owner lane had made an hour earlier, and had to be resumed by message | a lane whose next step depends on its children runs them in the foreground or drains them before the turn ends`.
- `docs/M0-findings.md`: a 2026-09-22 paragraph on what a sixth core document costs (one `CORE_DOCS` tuple; `build_core` copies every core doc except `CONVERSATION-DIGEST.md`; `apply` copies the directory; `doctor` checks only PHILOSOPHY and MANUAL) and on `sync` bumping no VERSION and touching no network against `SOURCES.md` line 3; and a 2026-09-22 paragraph that `gh issue edit N --body-file F` (gh 2.100.0) replaces the body, with the read-then-write sequence.
- On GitHub: ticket #42's `## Testing decisions` intro gained its own dated paragraph (line 34), rewritten in the fix round to be true of #42's body: "Amended 2026-09-22 by #89: the check skips a `## Testing decisions` or `## Design` section as it skips `## Diff`, up to the next `## ` heading (row 7 and the contract's "Named paths"), so a table posted inside that one section, its parts under `###`, adds no paths the ticket names; no assertion changed, one added. This record predates that rule: its table and contract sit under their own `## ` headings, so a check run on this ticket still counts the paths they quote." The before and after bodies are saved beside this report (`42-body.before*.md`, `42-body.after*.md`). Quick ticket #95 "Correct what SOURCES.md says sync does" filed for the Noted finding.

## Decided

- Criterion 3 says "the Ticket playbook's architect step"; the playbook has none. The rule went into step 6 (Testing decisions), extended in place, because "Ticket step 5" is quoted in four playbook patches, `SOURCES.md` and `review-brief.sh:183`, and renumbering would touch them all.
- The knowledge page is a sixth core document rather than a section of `MANUAL.md` or a generated page: a core document ships to projects with one `CORE_DOCS` tuple; a generated page needs a source under the never-edited `research/` and stays in the factory. Prose counts touched: `AGENTS.md:9` ("six"), the `knowledge` skill's slim list, and after round 1 `MANUAL.md` and the build docstring. Not touched: `docs/FACTORY-SPEC-v2.md` (read-only by convention), `tools/bootstrap/`, the hooks and the `factory918` skill (cross-cutting paths).
- The to-spec patch follows `patches/README.md`'s path rule (`patches/mattpocock/to-spec/SKILL.md.patch`), not the flat name of the one existing mattpocock patch.
- Posting on the ticket is the orchestrator's act (step 6); the runner prompt only names the destination. Design holes and how a review judges against the artifact stay in #90; no gate in `review-brief.sh` (not asked).
- `architect` skipped for this ticket (Feature step 2, written reason): prose and patches, no function boundary, not cross-cutting, and the ticket's own Run under says rule 2 yields no table for it. The design went into `.scratch/program/89/design.md`, which the writer implemented.
- The round-1 finding on `overlap.sh` was fixed on this PR, not filed: this PR's rule causes it (a posted table carries backticked example paths), the check should read the ask and not the design, and the change is two tokens in a regex plus one test cell. The cross-model reviewer flags that this made the PR touch a stateful script without a table of its own; the treatment given was an amendment of the existing table record on #42 (row 7 and the contract) plus P24, and the test cell is the assertion for it.
- No review round of its own for the records-only commit 78be65e (stated above); round 3 went to the verification fix instead.
- The ticket's rule 6 (one walk line per blast-radius risk) had nothing to bind: the diff is not cross-cutting and has no blast radius. Rule 8 (`shellcheck`) applied after the round-1 fix and ran clean.

## Blocked

Nothing waits on Manuel for this ticket. For the root: PR #96 (#88) and PR #94 both edit `overlap.sh` and `tests/poteto-mode/overlap.sh` and append to the same record files; whichever lands second needs the other's lines merged (the go covers the pair). Quick ticket #95 is open for the `SOURCES.md` line-3 correction.

## Trail

`/Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.scratch/program/89/decisions.tsv` (24 rows; not committed). Beside it: `todo.md` (the playbook steps, ticked, with the two `skip:` items), `design.md`, `how.md` and the two explorer findings, `writer-report.md`, `fix1-report.md`, `fix2-report.md`, `pr-body.md`, the #42 body before and after each amendment. The review dirs are in the worktree: `.claude/worktrees/owner-89/.scratch/review/ab47eb9/`, `.../c83f166/` and `.../78be65e/`.

## Fix round

The root's verification of 78be65e (`.scratch/program/verify/94-78be65e/`) returned three findings. All three are fixed; none was a design hole.

1. The PR body's `## Overlap` prose read "PR #96 closes #88", and GitHub listed #88 among this PR's closing references. Reworded to "PR #96 is the PR for ticket #88" (a body edit, no commit). `gh api graphql` on `closingIssuesReferences` now returns only #89 (checked twice, the second time after the final body edit).
2. The overlap skip ends at the next `## ` heading, so an artifact whose parts sit under sibling `## ` headings (as #42's `## Scenario table` and `## Contract` do) leaked its example paths, and my amendment on #42 claimed otherwise. Rule 5 judgment: the fix changes the rule's prose, the ticket body shape and a test fixture; no acceptance criterion and no Decision quote changes (criterion 3 already says "under `## Testing decisions`"), so a code-and-prose fix, not a restart. Commit 715100c (fix lane, its own worktree, `fix2-report.md`): Ticket step 6, `issue-tracker.md` (both copies) and `SCENARIO-TABLE.md` say the whole artifact stays inside its one section with `###` headings for its parts, and the page says #42's record predates the rule; the overlap test's check 17 gains a `### Contract` part quoting `src/x/y.txt`, a path fixture PR #2 touches, with a bite proof (the regex reduced to `Diff` fails that check with a `#2 feat-b:` line); the script's and the test's header comments say the skip runs to the next `## ` heading; the awk line is unchanged. The amendment on #42 was rewritten to be true of #42's body (quoted under Records) rather than re-leveling Manuel's approved headings.
3. The PR body now ends with `Claude Fable 5.1 on Claude Code` after the attribution, as PRs #92 and #96 do.

Checks rerun at 715100c in the owner worktree: `./factory918.sh sync` with no `FAILED` line, `git diff --exit-code` and an empty `git status --porcelain template`; `check_knowledge.py`, `build_knowledge.py` and a clean diff (`knowledge ok: 119 files`); `bash -n factory918.sh`; the five test scripts (`tests/poteto-mode/overlap.sh`: `ok 57 assertions`); `shellcheck` 0.11.0 clean on `overlap.sh` and its test; the two `issue-tracker.md` copies identical; `overlap.sh 89 --diff` prints the same nine shared paths with #96.

- New head: `715100c12a8eef8d9f2eb547769404c1f9ce7ab1` from `git rev-parse HEAD`; `git ls-remote origin refs/heads/feat/design-artifact-on-ticket` prints the same. No rebase.
- CI at that SHA: run 35751505990, `pull_request`, success.
- Review round: round 3 of 3 on the fix (fixed point 78be65e): both reports `hard findings: 0`, `act-on items: 0`, comment https://github.com/Zenoctra/factory918/pull/94#issuecomment-5779823400, posted after the gate rerun exited 0.
- PR #94: open, ready (not a draft), base `main`, mergeable, closing reference #89 only.

## Attention

reviewed by Opus (cross-model review of the trail, per show-me-your-work)

- Row `review-1`: the `overlap.sh` fix made the PR touch a stateful script with exit codes, which the ticket's own rule 2 covers, and no new scenario table was written for it; the run amended #42's table record and added one test cell instead. Manuel's judgment, not the run's.
- Row `ticket-8-pr`: the step-8 overlap record was clean at c83f166 and only rerun at 78be65e after the reviewer flagged it; the PR body now carries the `## Overlap` section naming PR #96.
- Row `fix-1`: an agent amended a closed, merged ticket's approved design record (#42); the amendment now sits on its own dated paragraph, and the before and after bodies are saved beside this report.
- Row `records`: commit 78be65e (two record lines) is the one commit no reviewer saw.
- Row `feature-2-architect`: the ticket that strengthens `architect` skipped `architect`, with the reason recorded; the owner wrote the design brief itself.
- The PR body's criterion counts were first written from the greps run at c83f166 and rerun at 78be65e for this report; one line number was corrected (the `## Design` sentence is line 10, not 11).
