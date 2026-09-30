verdict: PASS

Re-verification of PR #135 (ticket #109) at `637a062ec5ea03081d1710f0423b8b7a88b0458a`, rebased onto main `672b5a1`.
Checked out detached in my own worktree; `git rev-parse HEAD` printed the SHA, and `git merge-base --is-ancestor 672b5a1 HEAD`
exited 0, so main 672b5a1 is an ancestor. Everything below I ran myself; the owner's `rebase-check.md` was read only at the end,
and my findings match it with nothing extra and nothing missing.

## 1. The rebased diff against the pre-rebase diff

- `git diff 672b5a1 637a062` and `git diff a9ebdac be9cc3f` are both 373 lines and touch the same 16 files. No conflict
  markers: a grep for added `<<<<<<<`, `>>>>>>>` or a bare `=======` over the new diff counted `0`.
- Added lines: 78 in each. Removed lines: 32 in each. Exactly five lines differ between the two diffs, in three places:
  1. **Generated counts.** `docs/knowledge/INDEX.md` and the `<!-- lines: -->` header in `docs/knowledge/core/DECISIONS.md`
     go `107 -> 108` instead of `106 -> 107`. Main's P108 row is one line, so the count shifts by one. `build_knowledge.py`
     reproduces it (gate 4), so this is generated output, not a hand edit.
  2. **`ticket.md` steps 5 and 6.** Both the `-` and the `+` side changed, identically, by main's #136 text ("each ending
     with its disposition once acted on (Opening a PR)," in step 5; the whole writer-flags sentence in step 6). A word diff
     of the removed against the added line shows #135's edit is a pure **insert** on top of main's line:
     step 5 gains "In `eco` you read them yourself (step 0, the tier)."; step 6 gains "In `eco` the architect step is one
     runner and an adversarial judge (step 0, the tier); the table comes first in both tiers." Nothing of main's is removed.
  3. **`review-ladder.md` rung 1.** Same pattern: both sides carry #140's change (main's line no longer ends "...design, and
     zero items is the expected result for a clean change." but "...design."). #135's edit is `context;` becoming
     "context (in `eco` its two reviewers are the fresh context, Ticket step 0);". A replace that only inserts.
- **Nothing of #136 or #140 removed.** I computed the 416 non-blank lines added by `git diff a9ebdac 672b5a1` (the two merges)
  and intersected them with the lines `git diff 672b5a1 637a062` removes. Five hits, and all five are the five above: the two
  generated count lines (re-added with the new count) and the three lines #135 rewrites by insertion. Every other main-added
  line in `ticket.md`, `review-ladder.md`, `docs/knowledge/core/DECISIONS.md`, `docs/agents/ledger.md` and the review scripts
  is untouched by the branch. I re-read the two files at the SHA and confirmed by eye: step 5's disposition clause, step 6's
  `### Writer flags <YYYY-MM-DD>` sentence with `review-brief.sh` refusing an undisposed flag, and rung 1 without the retired
  "zero items is the expected result" wording are all present.

## 2. Reading `ticket.md` 0/5/6 and `review-ladder.md` as an owner in each tier

- **#108's disposition rules hold in both tiers.** Step 5 (unconditional, no `eco` qualifier on it): "...one numbered risk per
  line under `## Risks`, each ending with its disposition once acted on (Opening a PR)...". Step 6: "A writer's flags go on the
  ticket the same way, under a heading that is exactly `### Writer flags <YYYY-MM-DD>` inside the `## Testing decisions` or
  `## Design` section, one numbered flag per line ending with `fixed: <sha>` or `accepted: <reason>`; `review-brief.sh`
  refuses the review while a flag has none, or while a heading looks like that one and is not." Neither sentence is inside an
  `eco` clause and step 0's tier list does not name them, so an eco owner reads them as written.
- **#137's wording holds in both tiers.** Rung 1 now ends "...a signature or a usage in its `## Design` sketch, or an acceptance
  criterion..." with no expected-result sentence; `tests/spec-review/no-stale-wording.sh` passes at the SHA ("ok: no stale
  wording"), and the fixture's generated briefs carry neither "Under 400 words" nor "Read nothing beyond this brief unless"
  (checked below).
- **Eco's rule.** Step 0's closing paragraph: "In both tiers the writer, `blast-radius`, both reviewers every round, the
  architect judge, `interrogate`'s reviewers when a step launches it, and the trail review are fresh lanes, and step 6's
  table-first, tests-first order is unchanged." So `interrogate` is kept. And: "The trail review's brief asks it to list every
  lane launch it finds in the trail and the transcripts, and gives it no list, ceiling or count to compare against; you compare
  its list with this tier's rule in your hand-back, after it reports." `P109` in `DECISIONS.md` says the same and carries the
  amendment line: "Amended 2026-09-23 on Manuel's ruling: eco keeps `interrogate`, since a lane that reads someone else's work
  stays fresh in both tiers, and criterion 4's 'at most' list was a prediction, not a constraint".
- **Safe with no tier file.** Step 0: "A ticket runs `eco` when the main checkout's tier file holds exactly `eco` (trailing
  newlines aside) ... and `safe` otherwise... A digest or brief with no `Tier:` line is `safe`... A file holding anything but
  `eco` or `safe` reads `safe`... A read that fails is `safe` too... `safe` is every step as written." Every sentence #135 adds
  outside step 0's tier bullet is prefixed "In `eco`" or "in `eco`", and the word diff in section 1 shows each is an insertion,
  so a safe owner's text in steps 5, 6 and rung 1 is main's text verbatim plus a clause that does not apply to it.

## 3. Leading-witness test (#137) on the sentences #135 adds to a judging lane's brief

Every added sentence that shapes a brief for a lane that judges:

- `architect/SKILL.md`: "A caller whose tier asks for one runner (Factory918's `eco`, Ticket step 0) keeps the cross-judge and
  briefs it to read that one candidate adversarially against the rubric and the grounding and to return its findings, not a
  base; the findings stand in for the second candidate." No expected result, count, list, cap or reading limit. "not a base"
  names the output's form, not how much to find.
- `ticket.md` step 0 item 2: "...one runner and one judge on another model, briefed to read that candidate adversarially against
  the ticket, the grounding and `architect`'s design red flags and to return its findings, which you settle in the synthesis."
  Clean.
- `ticket.md` step 0, the trail review: "...gives it no list, ceiling or count to compare against" explicitly forbids the leading.
- `ticket.md` step 0 item 3 and rung 1 / `template/AGENTS.md`: "its two reviewers launched by you with their briefs' paths and
  polled per the poll rule", "(in `eco` its two reviewers are the fresh context, Ticket step 0)", "Read no brief and no diff
  while the review state exists". All addressed to the orchestrator; none adds text to a reviewer's brief.
- I grepped every added line for `at most|expect|no more than|under [0-9]+ words|read nothing|run nothing|zero items|should
  find|ceiling|budget`. The only hits are the two negations above, the historical "at most" quote inside P109's amendment
  sentence, and the `expect` shell function in `tests/hooks/delegation.sh`. No violation.

## 4. Gates at 637a062

All run in my worktree at the SHA. Every one exited 0.

- `bash .github/shellcheck.sh factory918.sh template/.github/shellcheck.sh 'template/.claude/hooks/*.sh' 'template/.agents/skills/*/scripts/*.sh' 'tests/*/*.sh' 'tests/*/*/*.sh'` -> `ShellCheck 0.11.0, files checked: 26`
- `bash tests/shellcheck/gate.sh` -> `ok 17 assertions`
- `bash tests/hooks/delegation.sh` -> `ok 76 assertions`
- `bash tests/spec-review/review-comment.sh` -> `ok 298 assertions`
- `bash tests/spec-review/review-brief.sh` -> `ok 1836 assertions`
- `bash tests/poteto-mode/overlap.sh` -> `ok 57 assertions`
- `bash tests/show-me-your-work/check-trail.sh` -> `ok 66 assertions`
- `bash tests/spec-review/no-stale-wording.sh` -> `ok: no stale wording`
- `bash tests/knowledge/provisional-ids.sh` -> `provisional-ids: 26 assertions passed`
- `bash tests/eval/reviewer/refusals.sh` -> `all 230 checks passed`
- `python3 tools/build_knowledge.py` -> `knowledge files: 119 -> docs/knowledge`; `git status --porcelain` printed nothing.
- `python3 tools/check_knowledge.py` -> `knowledge ok: 119 files`
- `./factory918.sh sync` -> `vendored: 72 skills.`; `git status --porcelain` printed nothing.

**Fixture flow**, from a private `mktemp -d` parent with a relative `--directory fx`, as `factory-ci.yml:51` does:

- `(cd <tmp>/fixparent && vp create vite:monorepo --directory fx --no-interactive --git --hooks --no-agent)` -> exit 0, `vp v0.3.1`.
- `git add -A && git commit -qm "chore: initial commit"` in `fx` -> `c69ddfe`.
- `./factory918.sh apply <tmp>/fixparent/fx --scaffold --profile python --name demo` -> ran; see Notes on its two doctor FAILs.
- `bash .github/shellcheck.sh` in `fx` -> `ShellCheck 0.11.0, files checked: 13`
- `git add -A && git commit -qm "factory918 apply"` -> `a6b4832`; then
  `PATH=<fake-gh>:$PATH .agents/skills/spec-review/scripts/review-brief.sh HEAD~1 --ticket 1 --blast-radius <tmp>/blast.md`
  -> `ticket: #1`, `round: 1 of 3`, both briefs written. I then ran the workflow's own assertion block over them verbatim
  (the hard-finding sentence, the fails-open sentence, the "You may open any file in the repository and run read-only
  commands" sentence, no word cap, no reading limit, `## Fails open` present, no `## Latent`, `## Walk` and the cross-cutting
  sentence only in the Spec brief) -> `BRIEF CHECKS OK`, exit 0.
- `vp check` -> `All 63 files are correctly formatted`, `Found no warnings, lint errors, or type errors in 9 files`
- `vp test run` -> `Test Files 2 passed (2)`, `Tests 10 passed (10)`
- `pnpm sg:test` -> `test result: ok. 2 passed; 0 failed;`; `pnpm sg` -> clean
- `.github/workflows/python.yml` steps inside `python/demo`: `uv sync --frozen`, `uv run ruff format --check .` ->
  `2 files already formatted`, `uv run ruff check .` -> `All checks passed!`, `uv run pyright` -> `0 errors, 0 warnings,
  0 informations`, `uv run pytest` -> `1 passed`, `uv audit` -> `Found no known vulnerabilities`.

**CI at the SHA.** `gh run list --json headSha,conclusion,status,databaseId` filtered to the SHA:
`{"conclusion":"success","databaseId":35922042563,"headSha":"637a062ec5ea03081d1710f0423b8b7a88b0458a","status":"completed"}`.
The run was `in_progress` on my first call and `success` on the second; no cancelled run for this SHA.

## Issues

None.

## Notes

- `./factory918.sh apply` on the fixture prints two doctor FAILs, `labels present` and `slots filled (/factory-start)`. Both
  are environmental for a throwaway fixture with no GitHub remote and no Day-0 interview, and CI's own step pipes that command
  through `tail -30`, so its exit code never gated. Not a finding against #135; the same two would appear on any main SHA.
- The owner's `rebase-check.md` is accurate. Every claim I checked held: the two generated counts, the three conflict
  resolutions being insert-only, the empty conflict-marker grep, and every gate line. I found nothing it omitted.
- I read that log only at the end; sections 1 to 4 were produced independently first.

Claude Opus 5 (1M context) on Claude Code
