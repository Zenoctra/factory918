# Writer brief, ticket #137 (Zenoctra/factory918)

Read `gh issue view 137 --repo Zenoctra/factory918` whole first. The ticket's list is settled by Manuel; do not reopen it. Upstream pstack wording (interrogate `lead-judgment.md` and the rest) is left alone.

## Where you work

Your worktree. Start: `git fetch origin` then `git switch -c wt/137-writer origin/feat/unled-review-briefs` if that branch exists on origin, else `git switch -c wt/137-writer 6e5c539` (origin/feat/risk-dispositions). Commit on `wt/137-writer` and `git push -u origin wt/137-writer`. Commits are plain sentences (P14), ending with `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`. Do not edit `docs/knowledge/core/DECISIONS.md`, `docs/agents/ledger.md` or `docs/M0-findings.md` (the owner writes those). Do not edit anything under `tests/eval/reviewer/` (the frozen rounds stop matching; #138 regenerates them). Never edit generated files (`template/docs/factory918/`, `docs/knowledge/spec|pages|notes`).

## The exact text (the owner chose it; use it word for word)

Every new sentence was checked against one test: it states no expected count of findings, no cap on length or items, and no limit on reading or on read-only commands. Do not add any sentence of your own to a brief. Add nothing that tells a later round what earlier rounds found, fixed or rated.

In `template/.agents/skills/spec-review/scripts/review-brief.sh`:

1. `definition=`: delete the last sentence, " Zero items is the expected result for a clean change." Nothing replaces it.
2. After the five `quotes`, the brief prints one more line, then a blank line, then `$pack_rule`. The line, word for word (a new variable, say `edge_rule`, with a one-line comment that SKILL.md step 4 carries it word for word):
   An edge case that proceeds silently fails open: file it under `## Fails open`.
   Keep Manuel's quote "An edge case outside the intended path being unsupported is not a flag." word for word where it is.
3. `common()`'s first line, "Read nothing beyond this brief unless ... Run nothing.", becomes, word for word (a variable, say `read_rule`, so the test and SKILL.md can hold it):
   You may open any file in the repository and run read-only commands, such as grep or the test suite.
4. `pack_rule=`: becomes
   The `## Reading pack` section above is the code to read, as it stands at the reviewed commit; open the repository for what the pack does not carry.
5. The Standards item-form line (about :594): delete " Read nothing beyond this brief unless a finding needs the code around a hunk, and then read that one function or section, not the file. Under 400 words." so it ends "... Skip anything tooling enforces."
6. The Spec item-form line (about :630): delete the same two sentences so it ends "... can name your third item as [P3]."
7. Update the comments that describe these (for example the one above `definition=` and above `pack_rule=`) so they stay true. A comment only for a why the code cannot show.

In `template/.agents/skills/spec-review/SKILL.md` (it is patched upstream: the change goes through `patches/mattpocock/spec-review.SKILL.md.patch`, then `./factory918.sh sync` must reproduce the SKILL.md exactly and leave `git status` clean; read `SOURCES.md` item 6 and `patches/series` for how the patch is built, and regenerate the patch from the upstream file and your new SKILL.md rather than hand-editing hunks):

8. "Both briefs carry:" gets a new first bullet: `- The reading sentence, first, word for word: "You may open any file in the repository and run read-only commands, such as grep or the test suite."`
9. The diff bullet (about :77): "Over that, the brief hands the path `<dir>/diff`, so a reviewer reads one file and runs nothing." becomes "Over that, the brief hands the path `<dir>/diff` to read it from."
10. `## Report` bullet: the definition quoted without the zero-items sentence. After the five quote bullets, before "Then the reading-pack sentence", add: `Then one line of ours, word for word: "An edge case that proceeds silently fails open: file it under `## Fails open`."` (match the surrounding quoting style; the test holds the line word for word). The reading-pack sentence quoted as in item 4.
11. Standards item form (about :99): drop "; read nothing beyond the brief but the code around a hunk; under 400 words" so it ends "skip anything tooling enforces."
12. Spec item form (about :110): drop "; read nothing beyond the brief but the code around a hunk; under 400 words" so it ends "and are not items."
13. Step 5, Judge (about :118): "following [`lead-judgment.md`](...): a reviewer with nothing critical inflates nits, so a report that is all nits means the code is probably fine; more than five Act on items means you are not filtering; the Dismissed list is shown so the human can overrule you." becomes "following [`lead-judgment.md`](...): sort each item on its merits; the Dismissed list is shown so the human can overrule you."

Elsewhere:

14. `template/docs/agents/review-ladder.md:6`: delete ", and zero items is the expected result for a clean change" so the clause ends "it is the design." (the repository has no `docs/agents/review-ladder.md` copy on this base; if one exists on yours, copy the template's over it).
15. `.github/workflows/factory-ci.yml` (about :73) greps the old definition in the fixture's briefs: grep the new definition instead, and also grep the edge line and the reading sentence in each brief, and fail if either brief carries `Under 400 words` or `Read nothing beyond this brief unless`.
16. `tests/spec-review/no-stale-wording.sh`: refuse each removed phrase with `-e` fixed strings, and extend its header comment the same way it names earlier tickets ("#137's ..."). Phrases: `Zero items is the expected result`, `Read nothing beyond this brief unless`, `read that one function or section, not the file`, `Run nothing.`, `reads one file and runs nothing`, `read nothing beyond the brief but the code around a hunk`, `Under 400 words`, `under 400 words`, `a report that is all nits means`, `more than five Act on items`, `zero items is the expected result`. Then run it and confirm `ok` over `template` and `docs/knowledge/core`; if a phrase hits a line this ticket does not own, stop and report it rather than editing that line.

## The test (`tests/spec-review/review-brief.sh`)

17. Update `definition` and `pack_rule` to the new text. Add `edge_rule` and `read_rule` with the exact text above.
18. For both briefs: `has` the edge line, and assert it sits on the line two after the fifth quote (the same arithmetic the existing definition/quote check and row 27 use); row 27's check that the pack sentence is two after the fifth quote moves to two after the edge line. `has` the reading sentence; `lacks` each of `Under 400 words`, `Read nothing beyond this brief`, `Run nothing`, `Zero items`, `not the file`. Do this for the round-one briefs and for the pack/fix-only briefs the file already builds (pk-w, pk-f).
19. `has "$source_skill/SKILL.md"` for the edge line and the reading sentence; `lacks` in SKILL.md for `all nits`, `more than five Act on items`, `under 400 words`, `runs nothing`.
20. Criterion 3, later rounds stay as blind as today: find whether the file already pins the `## ` heading list of a round-two brief and a fix-only brief. If it does, say where. If it does not, add one assertion per brief kind that its `grep '^## '` heading list equals the list the script writes today at base 6e5c539 (compute it by running the base script, not from memory).

## Order and checks

Commit the test changes first (they fail against the base script), then the script and SKILL.md/patch, then the ladder, CI and stale-wording changes. Each commit leaves `bash tests/spec-review/review-brief.sh` in the state its message says. Before you finish, run and record the outcome of: `bash tests/spec-review/review-brief.sh`, `bash tests/spec-review/no-stale-wording.sh`, `bash tests/spec-review/review-comment.sh`, `bash .github/shellcheck.sh factory918.sh template/.github/shellcheck.sh 'template/.claude/hooks/*.sh' 'template/.agents/skills/*/scripts/*.sh' 'tests/*/*.sh'`, `./factory918.sh sync` then `git status --porcelain` (must be empty), `python3 tools/build_knowledge.py` then `git status --porcelain` (must be empty), `python3 tools/check_knowledge.py`. Also `bash tests/eval/reviewer/rebuild.sh` if it exists: expect it to stop matching; record exactly what it prints, do not fix it.

Then grep the final briefs you generated in the test's temp dir (or a fresh run) and paste the `## Report` section of one Standards and one Spec brief in your result.

## Result

Write your result to `/Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.scratch/program/137/writer/result.md` with a Bash `cp` from your worktree (never under your worktree's own `.scratch/`): the branch and head SHA you pushed, the commit list, each check and its outcome, the answer to item 20, the pasted Report sections, and an act-on list of flags (anything you could not do as written, each numbered, or `none`). Write the file last.
