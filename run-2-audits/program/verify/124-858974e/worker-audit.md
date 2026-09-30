verdict: PASS+NOTES

Receipts-and-diff audit of PR #124 (ticket #103) at `858974ef18623c6db02d338adb9e0dd9978d6d36`. Nothing in the code or the
records is wrong on the documented path: every check named in the PR body reproduces at the head, the committed results
table is identical to the one the runner generated, and the fixture heads are all on origin. What is left is paperwork
and two questions for Manuel: criterion 3's matrix rows, and a ticket the PR body promises but nobody filed.

## Setup

- `git fetch origin feat/reviewer-model-eval main`; `git checkout --detach 858974e`; `git rev-parse HEAD` =
  `858974ef18623c6db02d338adb9e0dd9978d6d36`. Exit 0.
- `git merge-base --is-ancestor 86d156a HEAD` exit 0. Non-fixture diff is 14 files, 1783 insertions
  (`git diff --stat 86d156a..858974e -- ':!tests/eval/reviewer/rounds'`).
- No model run was launched. Only `check`, `refusals.sh` and the repo's own tests ran.

## 1. Acceptance criteria against the diff

- Criterion 1 (fixture set). **Met.** 12 round directories; 24 briefs (`rounds/*/review/{standards,spec}-brief.md`), 12
  `diff` files, 24 `*-report.historical.md`, 12 `round` files. `tests/eval/reviewer/labels` carries 13 labels (6
  Standards, 7 Spec) over 9 briefs; the other 15 briefs are unlabeled and present, as the criterion requires.
  `python3 tests/eval/reviewer/reviewer.py check` prints 13 `ok` lines, exit 0. Provenance: 6 `brief_source=surviving`,
  6 `brief_source=regenerated`, 12 `head_source=recorded`.
- Criterion 2 (runner). **Met.** `tests/eval/reviewer/reviewer.py` (946 lines): `MODELS` at :118, `load_fixtures` :210,
  `parse_report` :288, `score` :348, `receipt_from_transcript` :380, `receipt_from_runner` :437, `noise` :465,
  `render_table` :508, `cmd_check/run/collect/table` :763/:784/:844/:884. `bash tests/eval/reviewer/refusals.sh` →
  `all 230 checks passed`, exit 0.
- Criterion 3 (results for six models; descriptors and matrix rows in `provider-dispatch.md`). **Partly met, the
  remainder waived-pending-Manuel.** Raw receipts in the owner's `.scratch/eval/reviewer/runs/` corroborate the body:
  sonnet 86 receipts / 86 reports, opus-5 75/75, opus-5.5 72/72, astra 72 receipts with 34 reports, fable-5.1 24/0,
  terra 24/0, sol 24/0. Unmet parts, each disclosed: Fable withheld by the operator rule (`reviewer.py:122`,
  `Withheld("operator rule 2026-09-22, Fable is not launched")`); Terra and Sol `unavailable-model` dropouts; astra
  partial (35 of 72 runs); Sonnet `pr101-r1/standards` at 2 clean runs, below N=3, on an unlabeled brief.
  **Matrix rows: the owner added notes instead.** The notes
  (`template/.agents/skills/poteto-mode/references/provider-dispatch.md`, two paragraphs after line 19) carry the model
  ids, the alias resolution and the HTTP 400, but not what a matrix row carries — provider, family, upstream choice,
  selectable efforts, default effort — so a descriptor still cannot be dispatched from them. That matters for the
  proposed `codex:gpt-6-astra@medium` Standards row, which has no route without a matrix row.
  **The matrix test really does forbid a fifth family.** `model-matrix.test.ts:111-114` throws
  "model matrix must be header, separator, and 4 data rows, got ${table.length}" whenever the table is not exactly six
  lines, and :24 pins `const FAMILY_ORDER = ["fable", "sol", "grok", "opus"] as const;`, asserted at :209 with
  `expect(rows.map((row) => row.family)).toEqual([...FAMILY_ORDER]);`. A new family row is impossible without editing
  that test; replacing the existing `sol` row's model is possible, and the notes say why it was not done (Terra and Sol
  are refused to this account). The waiver is honest; it is Manuel's call, as round 3's Ask says.
- Criterion 4 (dated M0 section). **Met.** `docs/M0-findings.md` gains "Which reviewer model finds the hard bugs
  (2026-09-23)" with every required column plus the run counts. The committed table is identical to the generated
  `.scratch/eval/reviewer/table.md`; only the dropout table's third column is hand-written, and the section says so.
  Arithmetic closes: 22 + 13 runs and 14 + 23 usage-limit dropouts = the 72 planned astra runs.
- Criterion 5 (one recommendation per axis). **Met.** `docs/knowledge/core/DECISIONS.md` P103 and the generated
  `template/docs/factory918/DECISIONS.md` copy; the proposed sheet change is PR body lines 33-40; no models sheet is in
  the diff.
- Criterion 6 (design before the runner, one assertion per cell). **Met.** See section 2.

## 2. Design cells, commit order, restart handling

- One assertion per cell: every row 1 to 24 of the ticket's table has assertions in `refusals.sh`, counted from its own
  output — row 1: 26, 2: 6, 3: 6, 4: 12, 5: 11, 6: 9, 7: 5, 8: 3, 9: 4, 10: 6, 11: 3, 12: 5, 13: 3, 14: 3, 15: 3,
  16: 3, 17: 3, 18: 4, 19: 15, 20: 50, 21: 5, 22: 11, 23: 10, 24: 7. Rows 23 and 24, the ones the restarted round one
  said had no per-cell assertion, now name each cell: `197 23 run claude`, `198-199/203/206 23 collect`,
  `200-201/204 23 table`; `207-208 24 run codex`, `209-211 24 table`, `212-213 24 collect`.
- Tests before the runner and before each fix, in commit order (`git log --reverse 86d156a..858974e`): `b2e14dd` (the
  scenario-table test) precedes `448e96d` (the runner). Every later fix is preceded by its assertion: `78d7bad` →
  `8e0797a`, `29e3b24` → `b44fa4e`, `21b9b41` → `06e672a`, `3ce64e8` → `6f9044a`, `b7f865c` → `14e89d4`, `f1f4ed8` →
  `430c255`, `e112221` → `858974e`.
- Restart handled per `ticket.md`, "Design hole": round one's item 3 carries `hole: criterion 6` (step 1); the
  amendment says "Synthesized from two runners (Claude Opus 5.5 and Claude Opus 5), which agreed on every rule; the
  judge was skipped" (step 2); it is a dated added line, not a rewrite — "Amended 2026-09-23 by #124 (review round 1,
  hole at criterion 6): ..." with rows 22 to 24, each superseded contract sentence named, and an "Assertions moved"
  paragraph (step 3); the rounds restart at `round: 1 of 3` (step 5). Step 4's ordering holds for the work owed after
  the amendment (`b7f865c` before `14e89d4`, `f1f4ed8` before `430c255`); rows 22 and 23 describe behaviour the live
  runs had already grown before the round, which is what the amendment exists to document.

## 3. Scope of the non-fixture diff

- The measurement itself: `tests/eval/reviewer/reviewer.py`, `refusals.sh`, `labels`, plus the fixture tree.
- Criterion 3's provider facts: `SOURCES.md` item 16, `patches/series`,
  `patches/pstack/poteto-mode/references/provider-dispatch.md.patch`, and the vendored
  `template/.agents/skills/poteto-mode/references/provider-dispatch.md` it produces — the patch route AGENTS.md requires.
- Records: `docs/M0-findings.md`, `docs/agents/ledger.md` (2 lines), `docs/knowledge/core/DECISIONS.md` P103,
  `docs/knowledge/INDEX.md` line count, generated `template/docs/factory918/DECISIONS.md`.
- Review fallout: `.github/workflows/factory-ci.yml` (the `tests/*/*/*.sh` glob and the new `refusals.sh` step) and
  `AGENTS.md` "Verifying" (same glob, 20 → 21 files, the new test bullet). These come from the restarted round one's
  Act-on S1 and S2 and are in scope, since the PR adds the shell file the gate was missing.
- Nothing outside the ask. No `.scratch` artifact is committed.
- Model rule of 2026-09-22: the committed records honour it. Fable is a `withheld` dropout everywhere, the runner
  cannot launch it (`reviewer.py:122`), and the Claude descriptors are `tier-lower` pinned to `claude-opus-5` and
  `tier-upper` pinned to `claude-opus-5-5` (`reviewer.py:120-121`), which is the tier rule exactly. The **proposed**
  sheet change (body line 38) asks for `claude:fable@high`, arguing the tier rule launches that on Opus 5.5. That
  matches today's sheet vocabulary but writes the word Fable into the sheet; it is a proposal for Manuel, not an edit,
  so it does not contradict the rule, only re-raises it (see Notes).

## 4. Receipts

- Five review comments, all present and consistent with the head: round 1 (`restart`, hole at criterion 6,
  `act-on items: 3`), restarted round 1 (`round: 1 of 3`), round 2 (`2 of 3`), round 3 (`3 of 3`,
  `would-break fixed after f8fdfade08f5a8fe3e9fe5ba0c2cd12a75383db5`), round 4 (`4 of 5`, `act-on items: 0`).
- Round 4's fixed point is `f8fdfade...`, the commit round 3 reviewed. Correct per "Would-break fix" step 1.
- Act-on items traced: round 1 S1 (fence-blind gates) → `b7f865c` + `14e89d4`; S3 (astra arithmetic) → `fb9d8e2`;
  P2 (hole) → the ticket amendment. Restarted round 1 S1/S2 (ShellCheck glob, CI step) → `430c255`; S3 (hand-edited
  dropout column) → `ed9e5d2`; P2 (rows 23/24 cells) → `f1f4ed8`. Round 2 P1 (astra comparability, P103 text) →
  `f8fdfad`. Round 3 P1 → `e112221` + `858974e`, marked `fixed: 858974e` in the comment. Round 4: none. One exception,
  round 2's S1, is in Issues.
- CI green at the head: `gh api repos/Zenoctra/factory918/commits/858974e.../check-runs` → `Fixture success`,
  `Factory success`, both with `head_sha 858974e`.
- `gh pr view 124 --json headRefOid,baseRefName,mergeable,isDraft,closingIssuesReferences`:
  `858974ef18623c6db02d338adb9e0dd9978d6d36`, `main`, `MERGEABLE`, `isDraft false`, closing references = #103 only.
- The reviewed heads are recoverable off this machine: `git ls-remote origin 'refs/keep/*'` lists 15 refs, and all 12
  `head=` values in `rounds/*/round` are among them.

## 5. PR body against AGENTS.md "Pull requests"

- Plain-sentence title, no `type(scope):` (P14): "Measure which reviewer model finds the hard bugs cheapest". Pass.
- Problem then fix: line 1 states the gap and what the PR adds, before `## Why`. Pass.
- `## Blast Radius` present with no `## ` heading inside it (lines 48-50). The diff is not cross-cutting by
  `review-brief.sh`'s predicate (`*.claude/hooks/*|*.claude/settings.json|*.agents/skills/factory918/*`,
  `review-brief.sh:286`), so the section is optional and needs no `### Risks`. Pass.
- `## Overlap` (52) before `## Verification` (57), and verbatim: I re-ran
  `bash .claude/skills/poteto-mode/scripts/overlap.sh 103 --diff` at the head (exit 0) and its `#120` and `#121` lines
  `diff` identical to body lines 54-55.
- Verification quotes each criterion with evidence and states outcomes, not just command names (lines 59-76). Pass.
- `Closes #103` is the last line before the attribution (80), then the attribution (82), then the model-and-harness
  line (84). Pass.

## 6. Forbidden and generated files

- Nothing under `docs/knowledge/spec/`, `pages/`, `notes/` or `research/` is in the diff.
- `template/docs/factory918/DECISIONS.md` is generated (`tools/build_knowledge.py:126`) and matches a rebuild:
  `python3 tools/build_knowledge.py` (119 files) then `git status --porcelain` → empty. `python3
  tools/check_knowledge.py` → `knowledge ok: 119 files`. `./factory918.sh sync` exit 0, `git status --porcelain` empty.

## 7. Head-checks reproduced

- `bash .github/shellcheck.sh ... 'tests/*/*.sh' 'tests/*/*/*.sh'` → `ShellCheck 0.11.0, files checked: 21`, clean, the
  count AGENTS.md now claims.
- `tests/shellcheck/gate.sh` 17, `tests/hooks/delegation.sh` 55, `tests/spec-review/review-comment.sh` 192,
  `tests/spec-review/review-brief.sh` 648, `tests/poteto-mode/overlap.sh` 57, `tests/eval/reviewer/refusals.sh` 230.
  All exit 0 and all match the PR body's numbers.

## 8. Chain-time rebase (scratch clone, nothing pushed)

Done in `/tmp/claude-501/-Users-manuel-Desktop-Work-Under-The-Sun-Collective-Core-918-factory918/48857ffb-f0e5-4af1-9b36-ecddce7fb416/scratchpad/chain-audit`,
a clone of this worktree with a second remote at `https://github.com/Zenoctra/factory918.git`. **#121's head has moved
since the brief was written: it is `85988c7`, not `e9fd603`** (`gh pr view 121 --json headRefOid`); I used the live head.

- `chain120` = `feat/speed-lessons` rebased onto `main`: already up to date, tip
  `e090a3880f1914fc327822c1618492dbad59ccf8`.
- `chain121` = `feat/provisional-ticket-ids` rebased onto `chain120`: already up to date, tip
  `85988c7fe789202e4b9a880c71248578a139e2d4`.
- `chain124` = this PR's 25 commits rebased onto `chain121`: **four conflicts**, tip after resolution
  `0a7c8ae61e84e3cb3305a0e37554f655afc4b909`, plus one follow-up commit for the rebuild,
  `02c9389378aa86541db418b91a90855101e87699`.

Conflict log and resolutions:

1. `09a74ee` "Record what the providers report...": `SOURCES.md`. Both sides add an item 16. Resolution: keep #120's
   item 16 (the speed lessons) and renumber this PR's entry to **17**. `patches/series` auto-merged.
2. `b7e62ea` "Record the reviewer-model results...": `docs/agents/ledger.md`, `docs/knowledge/INDEX.md`,
   `docs/knowledge/core/DECISIONS.md`, `template/docs/factory918/DECISIONS.md`. Resolutions: ledger, keep both sides,
   this PR's two 2026-09-23 lines after the 2026-09-22 ones; DECISIONS, keep all three rows with **P103 before P105 and
   P110** (numeric order) and drop the duplicated `<!-- lines: -->` header, keeping the larger count; INDEX, take the
   chain's count and let the rebuild fix it.
3. `430c255` "Lint and run the reviewer test in the gate": `AGENTS.md`. Both sides edit the ShellCheck bullet and the
   test list. Resolution: take this PR's wider glob (`'tests/*/*.sh' 'tests/*/*/*.sh'`), keep every test bullet from
   both sides, and **move the file count to 22** — the merged set really is 22 files (verified below), not the 21
   either branch claims alone. `.github/workflows/factory-ci.yml` auto-merged (glob at :19, `refusals.sh` at :31,
   `provisional-ids.sh` at :35).
4. `f8fdfad` "Put the second gpt-6-astra window into the results and P103": both `DECISIONS.md` copies. Resolution:
   take this PR's rewritten P103 row and keep #120's P105 and #121's P110.

Post-resolution verification on `chain124`:

- `python3 tools/check_knowledge.py` first **failed**: `core/DECISIONS.md: INDEX says 102 lines, file has 103`. That is
  expected of the resolution, not a defect: three Provisional rows now land where each branch added one.
  `python3 tools/build_knowledge.py` fixes it (102 → 103 in `INDEX.md` and in the `<!-- lines: -->` header); I
  committed that as `02c9389`. **The chain-time resolver must run `build_knowledge.py` and commit its output.**
- Then: `check_knowledge.py` → `knowledge ok: 119 files`; `./factory918.sh sync` → exit 0 and `git status` clean;
  `bash tests/knowledge/provisional-ids.sh` → `provisional-ids: 26 assertions passed` (P103 satisfies #121's id rule);
  `bash .github/shellcheck.sh ... 'tests/*/*/*.sh'` → `files checked: 22`, clean; `tests/shellcheck/gate.sh` 17;
  `tests/eval/reviewer/refusals.sh` 230.
- Nothing was pushed; the clone is scratch only.

## Issues

- The PR body says the `provider-dispatch.md` matrix row for `gpt-6-astra` "is its own ticket" (line 37), and the
  Tradeoffs repeat it (line 45), but **no such ticket exists**: `gh issue list --state all --limit 40` has nothing for
  it and the highest number is #123. AGENTS.md: "a finding outside its scope becomes a ticket". Either file it or
  rewrite the sentence to say it waits on Manuel's answer to round 3's Ask.
- Round 2's Act-on **[S1] "P103 leaves the Provisional id sequence"** was never renumbered and no commit names it as
  fixed. It was answered by argument instead: P103's rationale ends "The id is the ticket number, the scheme #121
  introduces in the same stack", and round 3 re-sorted the same substance down to Consider. The outcome is right (the
  id matches #121's rule and `provisional-ids.sh` passes on the rebased chain), but an Act-on item closed with neither
  a fix commit nor an Ask is a receipts gap.

## Notes

- The restarted round one's trailer reads `act-on items: 5` while its judgment line reads "act on 4"; the 5 is the last
  item's number and item 5 is an Ask. No live effect (the head's last review comment is round 4 with
  `act-on items: 0`), but babysit reads that trailer, so the off-by-one is worth knowing.
- Judgment for Manuel: round 1's Ask said pushing `refs/keep/103/*` to origin "writes to the shared remote and is the
  human's call". Round 3 turned it into an Act-on and the 15 refs are now on origin. The write is additive and
  non-destructive, and the code fix (`858974e`) only teaches the refusal to print
  `git fetch origin 'refs/keep/103/*:refs/keep/103/*'`, but the shared-remote write happened without a recorded
  approval.
- Judgment for Manuel: the proposed Spec change reads `claude:opus@high` → `claude:fable@high` (body line 38), relying
  on the tier rule to read `fable` as Opus 5.5. It is consistent with today's sheet, but it puts the word the operator
  rule forbids launching into the sheet; "the upper tier" would carry the same instruction with no re-reading risk.
- The ledger line "17 completed, 51 hit the usage limit, 2 ... unauthenticated ... 2 were never attempted" describes the
  first quota window; the final record is 35 run and 37 dropouts. Both are true at their moment, and the line is the
  surprise it exists to record, but a later reader may take the 17 as the measurement's coverage.
- The owner's report is accurate where I could check it: head, base, criteria, review links, CI run, records and the
  refs push. Its Decided items are design calls with evidence behind them; nothing there needs Manuel. Its Blocked
  items are the two real questions (criterion 3's matrix rows, measuring Fable) plus the Codex quota, which is a wait,
  not a decision. One overstatement: the report's criterion 4 says the M0 table is "generated by `reviewer.py table`",
  while the section itself says the dropout table's third column is hand-edited.
- The six regenerated briefs cannot be re-derived here without the historical `gh` state, so the "byte for byte" claim
  rests on the owner's method note and the six survivors it reproduced. The parts I could check (24 briefs, 12 diffs,
  24 historical reports, provenance keys, all 12 heads on origin) hold.
