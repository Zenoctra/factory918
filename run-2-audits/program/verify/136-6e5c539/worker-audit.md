verdict: PASS+NOTES

Independent receipts-and-diff audit of PR #136 (ticket #108) at `6e5c539f44f90a341495aaf4bb3b44dd7b6e16c8`.
For a person: the change does what the ticket asked and every check I ran is green. Two things are for
Manuel, not defects: the new blast-radius patch rewords two clauses of upstream beyond the disposition
line, and the unclosed-fence fail-open on the writer-flags site is real (I reproduced it) and is
scoped out by the design the PR itself records.

Setup
- `git rev-parse HEAD` → `6e5c539f44f90a341495aaf4bb3b44dd7b6e16c8`. Exit 0.
- `git merge-base --is-ancestor a9ebdac HEAD` → exit 0. Patch base confirmed.
- Diff read whole: `git diff a9ebdac..6e5c539`, 26 files, +363/-53.

## 1. Criteria, each to a file:line

- **C1, the risk refusal.** Met. `template/.agents/skills/spec-review/scripts/review-brief.sh:443-450`
  (`bad="$(printf '%s\n' "$grounding" | undisposed risks)"`, `rm -rf "$dir"`, message, `exit 1`),
  inside the `if [ -n "$crossing" ]` block that starts at `:382`, right after the Risks-heading check
  at `:400-406`. A non-cross-cutting diff falls to the `elif` at `:451` and keeps today's
  "is not pasted" line.
- **C2, the flag refusal.** Met. The ticket fetch moved to `review-brief.sh:454-463` (from its old
  place after `fix-ranges`), the flag check at `:466-474`. Guarded by `[ -n "$spec" ]`, so a ticket
  with no body and a ticket with no list both pass.
- **C3, the walk reads each disposition.** Met. `review-brief.sh:497` (`risk_rule`), matched word for
  word by `template/.agents/skills/spec-review/SKILL.md:105` and by the patch hunk
  `patches/mattpocock/spec-review.SKILL.md.patch`.
- **C4, one assertion per cell, tests before the script.** Met. Commit order is `7cfdceb` (tests)
  then `4ad87b9` (script) — `git log --oneline --stat a9ebdac..6e5c539`. See §2.
- **C5, the disposition line in Opening a PR and the hand-back.** Met, both through patches:
  `patches/pstack/poteto-mode/playbooks/opening-a-pr.md.patch` and the new
  `patches/pstack/blast-radius/SKILL.md.patch`, listed in `patches/series:34`, described as SOURCES
  item 19. Pinned by `tests/spec-review/review-brief.sh:820-821`.

Empirical proof of C1/C2 on the real artifact, not only the fixtures:
- `bash template/.agents/skills/spec-review/scripts/review-brief.sh a9ebdac --ticket 108` against the
  **live** #108 body → exit 0, both briefs written. Its 15 flags pass, and `fixed: d016a2e` and
  `fixed: 6e5c539` both resolve and are ancestors of HEAD.
- Same run with flag 15's disposition stripped, served through `tests/spec-review/fake-gh.sh` +
  `FAKE_ISSUE_BODY` → exit 1, stderr the `ticket #108 has Writer flags without a disposition` header
  plus `  no disposition: 15. The records were left to the owner.`; from a clean start no
  `.claude/state` and only the empty `.scratch/review/` parent remained (writer flag 9's accepted
  scope).

## 2. Tables A, B, C: one assertion per cell, tests before the script

`tests/spec-review/review-brief.sh:626-821`. Every non-blank cell is present and named by row/column:
A1/F, A1/P; A2/F, A2/P; A3 and A4 across F P R S; A5 across F P R S; A6/F, A6/P; A7/F, A7/P; A8/F,
A8/P; A9 and A10 across F, P. Table B: B1/r B1/f, B2/r, B3/r B3/f, B4/r, B5/r, B6/r B6/f, B7–B14/r,
B15/r B15/f, B16/r B16/f, B17–B22/r. Table C: C1–C5 both columns (C4/f twice, lowercase and no date),
C6/r C6/f, C7/r C7/f. Blank R/S/f cells are not asserted, which the table's own legend permits.
Each refusal cell goes through `refused8` (`:705-710`), which asserts exit 1, byte-exact stderr, and
that neither `.claude/state/review` nor `$d8` exists. I found no cell of A, B or C without an assertion
and no assertion that softens a cell.

Ordering: `7cfdceb Test every risk and writer flag for a disposition before the brief` precedes
`4ad87b9 Refuse a brief while a risk or a writer flag has no disposition`. Criterion 4 satisfied
in git history, not only in prose.

## 3. Scope, grouped; vendored edits only through patches

- Script + tests: `review-brief.sh`, `tests/spec-review/{review-brief,fake-gh,no-stale-wording}.sh`,
  `.github/workflows/factory-ci.yml`.
- Vendored prose, all through `patches/`: `spec-review` SKILL.md, `opening-a-pr.md`,
  `blast-radius/SKILL.md`, and the four playbook pointers. `ticket.md` is ours and is edited directly,
  which `AGENTS.md`/SOURCES item 11 allows.
- Records: `DECISIONS.md` (core + generated copy), `INDEX.md`, `docs/agents/ledger.md`, `SOURCES.md`.
- `./factory918.sh sync` applied `pstack/blast-radius/SKILL.md.patch` and left `git status` clean, so
  every vendored edit is reproducible from its patch.

**Judgment for Manuel (upstream wording).** The new blast-radius patch changes upstream's Risks bullet
in three places, not one. `diff research/3-pstack/open-pstack-claude-code-port/plugins/pstack/skills/blast-radius/SKILL.md template/.agents/skills/blast-radius/SKILL.md`:

- upstream: `- **Risks.** Only the real ones. Each names how it breaks, ... Paste the proof for the ones that matter.`
- vendored: `- **Risks.** Only the real ones, one per line. Each names how it breaks, ... Paste the proof for the ones that matter, fenced under its risk. Once the author has acted on a risk, its line ends with the disposition, ...`

Beyond the disposition sentence the patch adds "one per line" and "fenced under its risk". Writer flag
13 names exactly this and the owner accepted it: the grammar reads one disposition per line and treats
an unfenced proof line as an item with no disposition, so both clauses are load-bearing for the
refusal, not cosmetic. Against your 2026-09-23 ruling that upstream pstack's wording stays as it is,
this is a call only you can make. It is two clauses on one line and nothing else in the file moves.

## 4. Receipts

- **Round one.** One PR comment (Zenoctra, 2026-09-23T20:00:27Z) ending `reviewed: 6e5c539f44f9...`,
  `round: 1 of 3`, `act-on items: 0`. `reviewed:` equals HEAD. No `restart`, no
  `would-break fixed after`, no `next round owed`, no `fix only after`.
- **Does it owe a round two?** No. Under #106/SOURCES item 4, `next round owed: round <N> ...` is what
  makes a round-one comment not review-ready, and `review-comment.sh` prints it only when an Act on
  item is marked fixed. `act-on items: 0` with no Act on item means no such line, and none is present.
  Checked through the script over the real history: with the live `gh pr view --json author,comments`
  payload placed as the fake gh's `pr.json`, `review-brief.sh a9ebdac --ticket 108` exits 0 and prints
  `round: 2 of 3` / `settled: carried 1, dropped 1 without a citation` — i.e. a round two *may* run,
  but nothing owes one. Merge-readiness rests on the round-one `act-on items: 0`.
- **CI.** `Factory` SUCCESS, `Fixture` SUCCESS (`gh pr view 136 --json statusCheckRollup`).
- **closingIssuesReferences.** `[108]` only. Base `main`, head `feat/risk-dispositions`, state OPEN.

## 5. PR body against AGENTS.md "Pull requests"

Conforms. Plain-sentence title; problem (two paragraphs on #96 and #99) then fix; `## Blast Radius`
present for a change that reaches every `spec-review` run, and it contains no `## ` line inside it;
`## Overlap` sits before `## Verification`; the Verification bullets state outcomes, not command names
(`ok 1720 assertions`, `success`, `clean`); the last three content lines are `Closes #108`, the
🤖 attribution, and `Claude Opus 5.5 on Claude Code`. One concern. The two opening sentences are for a
person.

## 6. Forbidden edits and generated files

- No edit under `research/`, `docs/knowledge/spec/`, `pages/` or `notes/`.
- `template/docs/factory918/DECISIONS.md` and `docs/knowledge/INDEX.md` are generated and are changed
  in the diff, but they are the rebuild of the edited source `docs/knowledge/core/DECISIONS.md`:
  `python3 tools/build_knowledge.py` leaves `git status` clean, and `python3 tools/check_knowledge.py`
  prints `knowledge ok: 119 files`.
- `./factory918.sh sync` leaves `git status` clean.

## 7. Leading-witness check (#137)

The PR adds exactly one new sentence to a reviewer brief, `risk_rule` at `review-brief.sh:497`:

> "The diff is cross-cutting: after the lines per documented step, one numbered line per risk under the
> Risks heading of the `## Blast radius` section above, in its order and numbered on from the last
> step, each naming the risk, saying what the diff does at that risk, and saying whether the diff
> honors the disposition the risk's line ends with (for `fixed: <sha>`, whether that commit fixes the
> risk; for `accepted: <reason>`, whether the reason holds for this diff); a risk line is a walk line
> and counts nothing."

It primes no result (it poses an open question with two branches and predicts neither answer), caps no
output (no count or length), and limits no reading (it adds no "read only" clause; the pre-existing
"read nothing beyond this brief" sentences are untouched). The unchanged `blast_rule` still says the
grounding "is the author's claim, not evidence". No other brief string changed.

## 8. The owner's Decided and Blocked items

- **S1, the unclosed fence above a flags list — real fail-open, correctly escalated, not a defect
  against the spec.** Reproduced through the real script: a ticket body with one unclosed ```` ```sh ````
  above `### Writer flags 2026-09-23` and two bare flags briefs at **exit 0** with nothing printed.
  Mechanism: `$fenced`'s `fence != "" { next }` swallows the opener itself, so `on` never becomes 1,
  and the END guard cannot fire because `opened = on ? $0 : ""` recorded an empty string
  (`review-brief.sh:172`, `:181`). The risks site is covered by the Risks-heading refusal that runs
  first; the flags site has no such guard. P108 scopes the fence refusal to "a fence opened in a list",
  so this is inside the recorded design — **judgment for Manuel**, not a defect. Round one noting it
  with `cites: DECISIONS.md P108` does cite a record this PR itself writes, which the owner flags too;
  that is a process point worth your eye, and the cheapest close is the owner's: report `fence` when a
  fence is still open at EOF in `flags` mode.
- **The rebase-sha hole in P108 — real, documented, and live on this very PR.** `undisposed` ends with
  `git merge-base --is-ancestor "$value" HEAD` (`review-brief.sh:416`), so a rewritten commit fails by
  name even though it still resolves. #108's flags 12 and 15 carry `fixed: d016a2e` and
  `fixed: 6e5c539`. If the chain rebase rewrites `feat/risk-dispositions` before any later brief, both
  are refused until #108's body is edited. **Judgment for the root/Manuel**, already recorded as an
  accepted hole in P108 and in the PR's `## Tradeoffs`. Nothing to fix on this PR.

## Issues

None that block. No criterion is unmet, no cell is unasserted, no forbidden file is edited, and no
receipt in the PR body is false about an outcome.

## Notes

1. **A receipt is off by two.** The PR body says "ShellCheck 0.11.0 at the pin over 26 files: clean."
   `bash .github/shellcheck.sh factory918.sh template/.github/shellcheck.sh 'template/.claude/hooks/*.sh' 'template/.agents/skills/*/scripts/*.sh' 'tests/*/*.sh'`
   — the exact `AGENTS.md` set at this head — prints `ShellCheck 0.11.0, files checked: 24`, exit 0.
   Clean either way; only the count is wrong.
2. **A refusal does not clear a *previous* run's `.claude/state/review`.** Both new refusals do
   `rm -rf "$dir"` only. Run a successful brief, then a refused one, and the delegation hook still
   reads the stale `.claude/state/review/dir`. Pre-existing across every refusal in this script (the
   Risks-heading refusal behaves the same), not introduced by #108, and invisible to the tests because
   `go8` does `rm -rf .scratch .claude/state` before each run. Worth a ticket only if you want it
   closed; out of scope here.
3. **A backticked disposition preceded by a space counts.** `field()` matches
   `(^|[ \t])(fixed|accepted):`, so `` 1. text `x fixed: 3f2a9c1` `` reads as dispositioned while
   B13's `` 1. text `fixed: <H>` `` (backtick immediately before) correctly reads `nd`. A prose line
   that merely quotes an example with a leading space inside backticks would pass. Narrow, and the
   error direction is a false pass on a hand-written risk line, not a false refusal.
4. **Everything I ran, all at `6e5c539`, all exit 0:** `tests/spec-review/review-brief.sh`
   → `ok 1720 assertions` (matches the PR body); `tests/spec-review/review-comment.sh` → `ok 298
   assertions`; `tests/spec-review/no-stale-wording.sh` → `ok: no stale wording`;
   `tests/shellcheck/gate.sh` → `ok 17 assertions`; `tests/hooks/delegation.sh` → `ok 55 assertions`;
   `tests/poteto-mode/overlap.sh` → `ok 57 assertions`; the ShellCheck gate over 24 files;
   `tools/build_knowledge.py` + `tools/check_knowledge.py`; `./factory918.sh sync`. `git status` is
   clean after all of them.
5. I did not run the fixture flow (`vp create` / `factory918 apply`); CI's `Fixture` job is green at
   this head and it carries the `accepted: a fixture` edit to `.github/workflows/factory-ci.yml:68`,
   which is the only path that exercises that change.

Claude Opus 5 on Claude Code
