verdict: PASS+NOTES

For a person: PR #121 does what ticket #110 asked, and I could not break it. Every scenario-table row has an assertion, every test and check passes at the head, the generated files match a rebuild, and nothing was hand-edited that should not be. The one deviation worth a minute is that the PR body never names the model that did the work, which `AGENTS.md` asks for and the five PRs before it all carry.

Audit run in worktree `.claude/worktrees/agent-a03e3038d36b1e29a`, detached at `e9fd603752d1eeacf345c9853e34d0f33e20813c`; `git merge-base --is-ancestor 86d156a HEAD` exit 0. No write to anything under version control.

## 1. Acceptance criteria against the diff

- **Criterion 1, a stable id plus a duplicate check.** Met. `tools/check_knowledge.py:7` pins `P[0-9]+[b-z]?`; `tools/check_knowledge.py:10-31` is `provisional_problems`, which walks `## Provisional` to the next `## ` line, takes the cell between the first two pipes, skips the `#` header cell and a `-: ` separator cell, refuses an off-form cell, refuses a cell already seen (naming the earlier line), and refuses a section from which no row was read. `tools/check_knowledge.py:53` joins its problems to the script's list, so a miss reaches the exit code. The id is never read from the table, which is what makes it rebase-stable; nothing in the code reads a max.
- **Criterion 1, one scenario row per collision shape with an assertion each.** Met; see section 2.
- **Criterion 2, existing rows keep their ids and posted `cites:` stay valid.** Met. No row in `git diff 86d156a..e9fd603 -- docs/knowledge/core/DECISIONS.md` is renumbered; the only additions are the preamble at `docs/knowledge/core/DECISIONS.md:68` and the `P110` row at `:101`. `template/.agents/skills/spec-review/scripts/review-brief.sh:248` widens the alternative to `DECISIONS\.md [A-Z]?[0-9]+[b-z]?`, a strict superset of the old `DECISIONS\.md [A-Z]?[0-9]+`, so no previously matching cite stops matching.
- **Criterion 2, the build regenerates with no hand edit.** Met. `python3 tools/build_knowledge.py` then `git status --porcelain` printed nothing (exit 0). `python3 tools/check_knowledge.py` printed `knowledge ok: 119 files`, exit 0.
- **Criterion 3, `issue-tracker.md` and the Ticket playbook say how a lane takes its id.** Met. `docs/agents/issue-tracker.md:13` and `template/docs/agents/issue-tracker.md:13`, byte-identical (`diff` of the two files is empty); `template/.agents/skills/poteto-mode/playbooks/ticket.md:17`.

## 2. The scenario table, row by row, and commit order

Commands: `bash tests/knowledge/provisional-ids.sh` -> `provisional-ids: 26 assertions passed`, exit 0. `bash tests/spec-review/review-brief.sh` -> `ok 660 assertions`, exit 0.

- Row 1 (one PR on today's base): cases 1, 2 and the six-value loop of case 3, `tests/knowledge/provisional-ids.sh:80-89`.
- Row 2 (two PRs from one base, rebased): cases 4, 5, 6, `:91-98`.
- Row 3 (two PRs for one ticket): cases 7, 8, 9, `:100-108`.
- Row 4 (a chain rebase): cases 10, 11, 12, `:110-121`; case 10 asserts the `P110` line is byte-identical after `P112` is inserted above it (`:114`).
- Row 5 (a row cited by a review comment): `tests/spec-review/review-brief.sh:303-315` — 5A `P110` carried, 5B `P110b` carried, 5C `P-110` dropped with the dropped count one higher. Item 16 (5D, the two regexes held together) is `tests/knowledge/provisional-ids.sh:123-139`.
- Row 6 (the ticket number is a legacy id): cases 17, 18, 19, `:141-148`.
- Row 7 (two lanes each took max+1): case 20, `:150-151`.
- Row 8 (the heading renamed): case 21, `:153-156`.
- Row 9 (`main` at HEAD, a `P25` mention in a Reason cell): case 22, `:158-162`.

No row lacks an assertion, and I found no assertion the table does not say: the 26 assertions map exactly onto test-list items 1-12 and 16-22 (item 3 is six cases, item 10 carries an extra byte-identity assertion, item 16 carries an extra grammar assertion), with items 13-15 in `review-brief.sh`.

Commit order shows tests first: `git log --reverse --format='%h %ad %s' --date=iso-strict 86d156a..e9fd603` gives `6018216` (the knowledge test) and `796334d` (the cites test) before `5d8060c` (the check) and `713174c` (the grammar). Exit 0.

## 3. Scope of the diff

`git diff --stat 86d156a..e9fd603`: 14 files, 229 insertions, 6 deletions.

- The rule and the check: `tools/check_knowledge.py`, `docs/knowledge/core/DECISIONS.md`, `docs/knowledge/INDEX.md`, `template/docs/factory918/DECISIONS.md`.
- The grammar: `template/.agents/skills/spec-review/scripts/review-brief.sh`.
- The tests and the gate: `tests/knowledge/provisional-ids.sh` (new), `tests/spec-review/review-brief.sh`, `.github/workflows/factory-ci.yml`, `AGENTS.md`.
- Criterion 3's prose: `docs/agents/issue-tracker.md`, `template/docs/agents/issue-tracker.md`, `template/.agents/skills/poteto-mode/playbooks/ticket.md`.
- Records: `docs/agents/ledger.md` (one line), `docs/M0-findings.md` (one dated line).

Nothing outside the ticket's ask. The ledger and findings lines are the only part a reader of #110 would not predict; `AGENTS.md` makes both standing practice ("a surprise goes to `docs/agents/ledger.md`"; "Anything verified against a tool version gets a dated line"), and the round-two Spec reviewer raised and dismissed exactly this. I agree with the dismissal.

Vendored-skill rule: the two files under `template/.agents/skills/` are factory-authored, not vendored — `./factory918.sh sync` ran to `vendored: 72 skills`, exit 0, and `git status --porcelain` was empty afterwards, so neither edit is overwritten by a re-vendor and no `patches/` entry was owed. `patches/series` and `SOURCES.md` are untouched, correctly.

## 4. Receipts

- Review comments on PR #121, both by `Zenoctra` (the author's account): `2026-09-23T03:11:01Z` ends `round: 1 of 3` / `act-on items: 1`; `2026-09-23T03:16:28Z` ends `round: 2 of 3` / `act-on items: 0`, and its opening says it covers "the whole diff after the file-mode fix and the trail review's fixes".
- Round one's single act-on item was the test's file mode. Fixed: `git ls-files -s tests/knowledge/provisional-ids.sh` -> `100755` (commit `27b2ace`), matching `tests/spec-review/review-brief.sh` at `100755`.
- CI green at the head: `gh run view 35813400632 --json headSha,conclusion` -> `headSha e9fd6037...`, `conclusion success`; `gh pr checks 121` -> Factory pass, Fixture pass.
- `gh pr view 121 --json headRefOid,baseRefName,mergeable,isDraft,closingIssuesReferences` -> head `e9fd603752d1eeacf345c9853e34d0f33e20813c`, base `main`, `MERGEABLE`, not a draft, closing references `#110` only.
- #122 exists, open, `needs-triage`, titled "Give projects a decisions record apply does not overwrite", and its body is the project-side question the owner says it is (a project's `DECISIONS.md` is the generated `docs/factory918/` copy that `apply` overwrites), with `Blocked by #110`.
- I re-ran the repository's own verification set at the head: ShellCheck over 21 files, no findings; `tests/knowledge/provisional-ids.sh` 26; `tests/spec-review/review-brief.sh` 660; `check_knowledge.py` ok; `build_knowledge.py` clean; `factory918.sh sync` clean. All exit 0.

## 5. PR body shape

Title "Take a Provisional row's id from its ticket so parallel PRs never collide" is a plain sentence, not `type(scope):`. The body opens with the problem, then the fix. `## Blast Radius` is present and contains no `## ` heading. `## Overlap` precedes `## Verification`. Verification names what ran with outcomes (assertion counts, exit behavior, the run id). `Closes #110` is the last line before the attribution. The attribution line is there. The model-and-harness line is not — see Issues.

The `## Overlap` block's file list for `#120` is exactly the intersection of the two PRs' file sets; I checked it against `gh pr view 120 --json files` and `git diff --name-only 86d156a..e9fd603` and found no file missing or extra.

## 6. Forbidden and generated files

`git diff --name-only 86d156a..e9fd603` touches nothing under `docs/knowledge/spec/`, `docs/knowledge/pages/`, `docs/knowledge/notes/` or `research/`. It does touch two generated paths, `docs/knowledge/INDEX.md` and `template/docs/factory918/DECISIONS.md`, and both match a rebuild: `python3 tools/build_knowledge.py` left `git status --porcelain` empty. No hand edit survived.

## 7. The owner's `## Decided` items and the #120 flag

- `P<ticket>` rather than the ticket's example `P-<ticket>`: correct and load-bearing. `P-110` fails both `P[0-9]+[b-z]?` and the `cites:` alternative; case 3 and case 5C prove each half.
- Letters `b` to `z`, `P110a` refused: `tools/check_knowledge.py:7` excludes `a`; case 3 asserts `bad('P110a')`.
- A lone max+1 id passes its own CI: true, and it is written into the `P110` row as an accepted limit, not hidden. Nothing to fix.
- The project-side question left to #122: verified above.
- **The #120 flag is already resolved.** At `gh pr diff 120` taken at the start of this audit, #120's head added `| P31 | Where the run's speed lessons live (#105) |`. Re-fetched minutes later (head `d530b745`, updated `2026-09-23T03:19:39Z`), that row reads `| P105 | Where the run's speed lessons live (#105) |`, and the two `(#105, P31)` references inside its amended `P29` row now read `(#105, P105)`. So: nothing for Manuel here. The owner's flag was accurate when written and #120 has since taken its ticket's id.

## Issues

1. The PR body never names the model that did the work. `AGENTS.md` "Pull requests" says "end with the model and harness"; the body ends with the Claude Code attribution line alone, while PRs #94, #96, #99, #101 and #102 all end with a further `Claude Fable 5.1 on Claude Code` line. Fixable by an edit to the body; no code change. (#120's body has the same gap, so this is a run-wide slip, not a #121-only one.)

## Notes

- Both review comments carry "Claude Opus 5.5 on Claude Code" at the end of their opening paragraph rather than at the end of the comment. `AGENTS.md` says a posted comment "ends the same way". The information is present and attributable; only its position differs.
- `provisional_problems` reads the Provisional section line by line and does not track fenced code blocks, so a fenced line starting with `|` inside that section would be read as a row. The section today holds exactly one table and the check is on the source file only, so this is latent, not live. Round two's Standards report already noted two adjacent smells (the `DECISIONS.md` vs `core/DECISIONS.md` name and the test's second table parser) and deferred both; I would not add a third act-on item here.
- The two PRs in the stack both append to the end of the same table and both move the same `INDEX.md` count line, so a textual conflict at the rebase is expected. The fix is the one the `P110` row names: keep both rows, change no id.

Claude Opus 5 on Claude Code
