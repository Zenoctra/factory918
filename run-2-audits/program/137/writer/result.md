# Writer result, ticket #137

Branch `wt/137-writer`, pushed to origin, head `624a408a406df6e28bdf262af7d4a607534ce443`. Base `6e5c539` (origin/feat/risk-dispositions; origin/feat/unled-review-briefs does not exist).

## Commits (6e5c539..HEAD)

1. `2e0043b` Assert the review briefs no longer lead the witness. Test only; `bash tests/spec-review/review-brief.sh` fails against the base script and SKILL.md with `FAIL SKILL.md step 4 carries the edge line`.
2. `c3d0b93` Stop the review briefs from leading the witness. `review-brief.sh`, `SKILL.md`, `patches/mattpocock/spec-review.SKILL.md.patch` (regenerated with `diff -u --label a/spec-review/SKILL.md --label b/spec-review/SKILL.md <upstream code-review/SKILL.md> <new SKILL.md>`; the same command over the base SKILL.md reproduces the base patch byte for byte). The brief test passes: `ok 1836 assertions` (base had 1720).
3. `624a408` Refuse the retired review wording in the ladder, CI and the stale-wording check. `template/docs/agents/review-ladder.md`, `.github/workflows/factory-ci.yml`, `tests/spec-review/no-stale-wording.sh`. The brief test still passes, 1836.

## Checks, at 624a408

- `bash tests/spec-review/review-brief.sh`: `ok 1836 assertions`.
- `bash tests/spec-review/no-stale-wording.sh`: exit 1, two hits, both P18's zero-items sentence, which this lane does not own (flag 1):
  - `template/docs/factory918/DECISIONS.md:79` (generated copy)
  - `docs/knowledge/core/DECISIONS.md:87`
- `bash tests/spec-review/review-comment.sh`: `ok 298 assertions`.
- ShellCheck (`bash .github/shellcheck.sh factory918.sh template/.github/shellcheck.sh 'template/.claude/hooks/*.sh' 'template/.agents/skills/*/scripts/*.sh' 'tests/*/*.sh'`): `ShellCheck 0.11.0, files checked: 24`, no findings.
- `./factory918.sh sync`, then `git status --porcelain`: empty.
- `python3 tools/build_knowledge.py` (`knowledge files: 119 → docs/knowledge`), then `git status --porcelain`: empty.
- `python3 tools/check_knowledge.py`: `knowledge ok: 119 files`.
- `bash tests/eval/reviewer/rebuild.sh` with no argument prints `usage: rebuild.sh <round>` and exits 2. `bash tests/eval/reviewer/rebuild.sh pr94-r1` prints `rebuild: pr94-r1: identical` and exits 0: it runs `review-brief.sh` as it stood at the recipe's `script_at`, not the working tree's, so this change does not stop it matching (flag 3). The other ten rounds were not run: the worktree sandbox refused the loop.
- The CI fixture step's new greps, run by hand on a fresh `review-brief.sh 6e5c539 --ticket 137` in this worktree: line 3 of each brief is the reading sentence; each Report section holds the new definition as a whole line and the edge line, and neither `Under 400 words` nor `Read nothing beyond this brief unless`. A grep over the whole brief does find both phrases there, but only because this PR's own diff and reading pack quote the removed lines. The CI fixture's apply diff cannot contain them: `no-stale-wording.sh` finds neither phrase anywhere under `template/`. State cleaned afterwards.

## Item 20, later rounds as blind as today

The file did not pin a `## ` heading list for any brief before this change. The closest checks were `fixed_section` (fix section before the diff), `around` in row 26 (the headings either side of the pack) and the `lacks "## The fix under review"` checks. I added a `headings <brief> <list> <label>` helper next to `fixed_section`, and four assertions. The lists came from running the base test with dump lines added at 6e5c539. The project and factory layouts gave identical lists.

- Fix-only (row 9A's round-five brief, `.scratch/review/$s4/`), after the 9A `only_commit`: `## Commits`, `## Changed files`, `## The fix under review`, `## Diff`, `## Reading pack`, `## Settled in earlier rounds`, then for Standards `## Standards`, `## Smell baseline`, `## Report`, and for Spec `## The ticket (#7)`, `## What to build`, `## Acceptance criteria`, `## Comments by the ticket's author (#7)`, `## Report`.
- Round two (row 12A's brief, `$std` and `$spec`), after the 12A `lacks`: the same without `## The fix under review`.

## Report sections (fresh run: `review-brief.sh 6e5c539 --ticket 137`)

Standards brief:

````
## Report

A hard finding is one of two things: the documented path gives a wrong or silent result, or an input outside it proceeds silently (fails open). An input outside the documented path that is refused with a message saying how to correct it is not a finding; it is the design.

- Manuel: "there are an infinite amount of unhappy paths and only 1 happy one"
- Manuel: "AT MOST hardening to fail fast and loud if we move outside of that"
- Manuel: "we notice the variable is unexpected and flag that without having to diagnose every reason the variable might be wrong for the user"
- Manuel: "An edge case outside the intended path being unsupported is not a flag."
- Manuel: "Primary focus must be the happy path, then unhappy paths that error in a way the user can correct."

An edge case that proceeds silently fails open: file it under `## Fails open`.

The `## Reading pack` section above is the code to read, as it stands at the reviewed commit; open the repository for what the pack does not carry.

Write the report as Markdown with exactly these `## ` headings, in this order, each holding numbered items or nothing:

- `## Would break`: a breach of a documented standard that makes the documented path give a wrong or silent result. Cite the standard (file + the rule) and quote the hunk.
- `## Fails open`: a breach of a documented standard that lets an input outside the documented path proceed silently. Cite the standard (file + the rule) and quote the hunk.
- `## Standards breaches`: documented-standard breaches that do not change behavior. Cite the standard and quote the hunk.
- `## Fix alongside`: baseline smells and other judgement calls. Name the smell and quote the hunk. They are fixed only when a would-break fix already touches that code; they never count.

Each item opens with a line of the form `1. **Title.** body`, with the quoted hunk in a fenced block under it; number the items continuously across the headings, so the judgment can name your third item as [S3]. A documented repo standard overrides the baseline. Skip anything tooling enforces.

Every item under `## Would break` or `## Fails open` carries a line `Documented step:` quoting the ticket line or the `file:line` of the documentation the user follows, and a line `Result:` saying what happens instead; an item without its `Documented step:` line is sent back.

The same item carries a line `spec:` naming the artifact it rests on: `table <row>/<column>` for a cell of the ticket's scenario table, `design <signature>` for a signature or usage in its `## Design` sketch, or `criterion <k>` for its k-th acceptance checkbox; an item without a `spec:` line in one of those three forms is sent back.

Write your report to `.scratch/review/6e5c539/standards-report.md` and reply with only that path.
End the report with exactly one line `hard findings: N`, where N is the number of items under `## Would break` and `## Fails open` and nothing else.
````

Spec brief:

````
## Report

A hard finding is one of two things: the documented path gives a wrong or silent result, or an input outside it proceeds silently (fails open). An input outside the documented path that is refused with a message saying how to correct it is not a finding; it is the design.

- Manuel: "there are an infinite amount of unhappy paths and only 1 happy one"
- Manuel: "AT MOST hardening to fail fast and loud if we move outside of that"
- Manuel: "we notice the variable is unexpected and flag that without having to diagnose every reason the variable might be wrong for the user"
- Manuel: "An edge case outside the intended path being unsupported is not a flag."
- Manuel: "Primary focus must be the happy path, then unhappy paths that error in a way the user can correct."

An edge case that proceeds silently fails open: file it under `## Fails open`.

The `## Reading pack` section above is the code to read, as it stands at the reviewed commit; open the repository for what the pack does not carry.

Write the report as Markdown with exactly these `## ` headings, in this order, each holding numbered items or nothing:

- `## Walk`: one numbered line per documented step of the path the change touches (the ticket's criteria and the documentation the diff changes), each saying what the code does at that step. A walk, not findings: its lines are numbered 1..K on their own and count nothing.
- `## Would break`: a requirement missing, partial, or implemented so that the documented path gives a wrong or silent result.
- `## Fails open`: an input outside the documented path that proceeds silently instead of being refused with a message saying how to correct it.
- `## Not asked for`: behaviour in the diff the ticket did not ask for.

Each item opens with a line of the form `1. **Title.** body` and quotes the spec line it rests on in a fenced block (a criterion can carry `## ` or `1. ` lines, and only fenced text is exempt from the report shape); number the items continuously across the headings from `## Would break` on, so the judgment can name your third item as [P3].

Every item under `## Would break` or `## Fails open` carries a line `Documented step:` quoting the ticket line or the `file:line` of the documentation the user follows, and a line `Result:` saying what happens instead; an item without its `Documented step:` line is sent back.

The same item carries a line `spec:` naming the artifact it rests on: `table <row>/<column>` for a cell of the ticket's scenario table, `design <signature>` for a signature or usage in its `## Design` sketch, or `criterion <k>` for its k-th acceptance checkbox; an item without a `spec:` line in one of those three forms is sent back.

Write your report to `.scratch/review/6e5c539/spec-report.md` and reply with only that path.
End the report with exactly one line `hard findings: N`, where N is the number of items under `## Would break` and `## Fails open` and nothing else.
````

Each brief's first line after the title is `You may open any file in the repository and run read-only commands, such as grep or the test suite.`

## Act-on flags

1. `no-stale-wording.sh` fails on P18's "Zero items is the expected result for a clean change." at `docs/knowledge/core/DECISIONS.md:87` and its generated copy `template/docs/factory918/DECISIONS.md:79`. This lane does not own DECISIONS.md, so I left the row alone. The check passes once the owner amends P18 and reruns `python3 tools/build_knowledge.py`. P107's rejection note quotes "the "Read nothing beyond this brief" sentences" without "unless" and does not hit.
2. `SOURCES.md` item 6 still says "each brief says to read nothing beyond it", which is now untrue. It is not on the brief's list, so I left it alone. It needs a replacement sentence chosen by the owner.
3. `tests/eval/reviewer/rebuild.sh` did not stop matching. It takes a round argument and runs the script pinned at each recipe's `script_at`, so `pr94-r1` is still `identical`. The other ten rounds were not run.
4. Item 20 asked for one assertion per brief kind. I wrote one per brief, Standards and Spec, so each kind has two assertions (four in all).
5. The CI definition grep is now `grep -qxF` (whole line), where it used `-qF` before. Otherwise a brief that still ended the definition with the zero-items sentence would pass.
6. The two new code comments in `review-brief.sh`, above `edge_rule` and `read_rule`, are mine. They follow the neighbouring "SKILL.md step 4 carries it word for word" form. The comments above `pack_rule` and `report_rules()` now say the sentence comes after the edge line.
7. `docs/agents/review-ladder.md` does not exist on this base, so only the template copy was edited.
