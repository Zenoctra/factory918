# Writer brief: the #138 reviewer runner (independent, sequential and masked arms)

Ticket: `gh issue view 138 --repo Zenoctra/factory918` (read it whole; the quotes from Manuel are settled). Why: M/.scratch/program/reviewer-eval-audit/report.md, sections 3, 4, 5c and 6 (M = /Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918). You write code and fixtures; you launch no subagent and no reviewer run. Your branch: `wt/138-writer`, created from `feat/reviewer-eval-rerun` (commit e710e99, which carries #140's fixed `review-brief.sh`). Commit liberally, plain-sentence messages ending with `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`. Do not push. Do not touch docs/knowledge/, docs/M0-findings.md or DECISIONS.md (the owner writes those).

## Files in scope

tests/eval/reviewer/: reviewer.py, refusals.sh, rebuild.sh, rounds/, labels, and new: truth, agents/.

## 1. Subtract the void fixtures

- Keep rounds pr94-r1, pr96-r1, pr99-r1; delete the other nine round directories.
- Delete `labels`. Its replacement is `truth` (section 3).
- Remove the routes this measurement does not use: `claude:sonnet`, every `codex:*` descriptor, the `External` route, `dispatch`, `receipt_from_runner`, the pstack-runner env, and their tests. Git history keeps them.

## 2. Regenerate the six briefs with the fixed script

- `rebuild.sh` runs review-brief.sh "as it stood at the recipe's script_at". Set each kept round's `inputs/recipe` `script_at` to e710e99ce4293ff2d057b7c9d639a82e97c88f04, regenerate `review/diff`, `standards-brief.md`, `spec-brief.md` from it (the same clone and gh stub machinery; extend the stub for any new gh call the newer script makes, serving only inputs/), commit them, and `bash tests/eval/reviewer/rebuild.sh <round>` must then print identical for all three.
- pr96-r1's `inputs/blast-radius.md`: its `### Risks` list names two of the ground-truth bugs (item 1 cached binary, item 3 unmatched glob). Remove every item of that list and keep the heading line alone: the fixed script refuses a cross-cutting diff whose grounding lacks the heading and refuses a risk line without a `fixed:`/`accepted:` disposition, and the owner decided not to invent dispositions. Check the rest of the grounding and the three rounds' other inputs for a line that names a ground-truth bug (the titles in the stub `truth`, and the audit's section 2 and 3 tables) and report any you find; do not remove it yourself.
- If the newer script cannot brief an old head (a missing file, a refusal), stop at that round and report the exact error; do not patch review-brief.sh.
- Leading-witness rule (Manuel, #137): no brief and no runner prompt states an expected result, count or kind of finding, caps output or items, or limits reading. grep the six regenerated briefs for "expected", "400", "Under ", "Read nothing", "Run nothing", "at most", "no more than" and report each hit with its line.

## 3. Ground truth

`tests/eval/reviewer/truth`, tab-separated, `#` comments, header `# round	id	anchors	fix	where	sources	title`: round, id (G<n>), anchors (` && `-joined regexes, each re.search on the normalized item text, at least two), fix (comma-separated shas to apply in order, or `-`), where, sources, title. The owner supplies the real rows later; write a stub with the old labels of the three rounds translated (fix `-`, where `?`) so everything runs, and make the loader refuse a malformed row with file:line.

## 4. The run matrix

Data shape first (principle-model-the-domain): a run is (descriptor, brief, step), step one of `1`, `I2`, `I3`, `S2`, `S3`, `M2`, `M3`. Arm X's chain is [1, X2, X3]: pass 1 is shared by the three arms. Directory runs/<descriptor>/<round>/<axis>/<step>/. A table of steps holds each step's arm, pass and prerequisites (X2 needs 1; X3 needs 1 and X2), not branches scattered through the code.

- Independent (I): the regenerated brief, unchanged, in a fresh export of the head.
- Sequential (S): the brief plus a `## Settled in earlier rounds` section inserted exactly where review-brief.sh at e710e99 prints its own (same heading, the paragraph copied verbatim from that script: "These findings were raised in an earlier round and settled by the decision each one cites. Do not raise them again. Nothing in this section says what you should find or confirm."), followed by one line per hard item (under `## Would break` or `## Fails open`) of the chain's earlier passes in pass order, each `- ` plus the item's raw text joined onto one line. Take the text from the earlier runs' collected report.md. Add a test that the inserted section sits where the script puts it (generate a brief with the script with one settled item via --previous and compare positions).
- Masked (M): pass k runs on the head with the fix commits of every truth bug the chain's earlier passes found as hard items (anchors, one-to-one claims as today) applied: in a temporary shared clone, detached at the head, cherry-pick the needed commits in `git rev-list --topo-order --reverse` order, commit, regenerate both briefs there with the e710e99 script and the gh stub, then `git archive` that commit into the export and copy the regenerated review files. A truth bug whose fix commits were all applied is masked for that run: record the applied commits and masked ids in run.json. When no found bug has a fix, the masked pass runs on the plain head and run.json says so. `check` proves every subset of each round's fix commits that can arise cherry-picks cleanly and briefs; on a conflict it refuses naming the round and commits (report it to the owner; do not resolve conflicts by hand). The fix commits must be reachable after a fresh clone: list the commits that are not under refs/keep/103/ in your result, and make the fetch hint name refs/keep/138/* too (the owner pushes those refs).
- A pass-2 or pass-3 step is prepared only when its prerequisites are collected complete; a contaminated or usage-limit prerequisite is prepared again first.

## 5. Models, effort, receipts

- MODELS: `claude:opus-5` -> {"subagent_type": "review-lower-high"}, served ^claude-opus-5$; `claude:opus-5.5` -> {"subagent_type": "review-upper-high"}, ^claude-opus-5-5$; `claude:fable-5.1` -> {"subagent_type": "review-fable-high", "model": "fable"}, ^claude-fable-5-1$. The three agent definitions are installed at M/.claude/agents/review-{lower,upper,fable}-high.md (frontmatter name, description, model, `effort: high`); copy them byte for byte into tests/eval/reviewer/agents/ and make `check` refuse when the installed copies under `<main checkout>/.claude/agents/` differ or are missing (the main checkout is the git common dir's parent, as load_env finds it).
- Effort: a receipt whose transcript records any assistant line with an `effort` other than `high` is refused, the same way a served-model mismatch is (a Refusal naming the run, the effort seen and the fix). Test it.
- Usage limit: a Native transcript whose assistant text or error says "hit your usage limit" (USAGE_LIMIT_LINE) becomes a `usage-limit` dropout receipt, excluded from every metric and prepared again by the next `next` call. Test it.
- Contamination, close the audit's holes (section 6): today a Bash command is flagged only when it lacks the export path, so `cd <export> && gh issue view 90` passed. Keep that rule and also flag a Bash command that runs `gh`, `git`, `curl` or `wget` as a command word anywhere in it (after `&&`, `;`, `|`, `$(`), that names an absolute or `~` path outside the export (allow /dev/null and executables under /usr/, /bin/, /opt/homebrew/ used as the command word), or that has a `..` path component. Test each, including the `cd <export> && gh ...` case and a sibling export under the same work directory.
- The runner prompt stays: "Read `<brief>` whole and follow it. You are working in `<checkout>`; every relative path in the brief is relative to it." Check it against the leading-witness rule and keep BANNED.

## 6. Verbs

- `check`: fixtures, truth, agents, masked subsets.
- `next <descriptor>... [--limit N]` (default 8): collect nothing; print up to N launch lines, pass-1 steps first across all briefs, then pass 2, then pass 3, skipping in-flight runs; a prepared run with no transcript is printed again before new ones. Materializes what it prints.
- `collect`: as today.
- `table`: per model, one table: rows are arm x pass; columns: chains, mean new truth bugs per chain in that pass (hard hits not hard-hit by an earlier pass of the same chain; masked bugs excluded from a masked pass), cumulative, demoted (truth bugs matched only by non-hard items), other hard items (hard items matching no truth bug), mean output tokens, mean cache read, mean wall s, contaminated, usage-limit. Also scores.tsv with one row per run and its hit ids. Keep it readable in Markdown.
- Drop `run` if `next` covers it.

## 7. Verify before you report

- `python3 tests/eval/reviewer/reviewer.py check` passes with the stub truth.
- `bash tests/eval/reviewer/refusals.sh` passes, with the new tests.
- `bash tests/eval/reviewer/rebuild.sh pr94-r1` (and pr96-r1, pr99-r1): identical.
- `REVIEWER_OUT=$(mktemp -d) python3 tests/eval/reviewer/reviewer.py next claude:opus-5 --limit 8` prints 6 pass-1 lines and materializes 6 exports; clean up after.
- `bash .github/shellcheck.sh factory918.sh template/.github/shellcheck.sh 'template/.claude/hooks/*.sh' 'template/.agents/skills/*/scripts/*.sh' 'tests/*/*.sh' 'tests/*/*/*.sh'` exits 0 (update the file count in AGENTS.md "Verifying" only if it changes, and say so).
- /deslop over your diff.

## Result

Write M/.scratch/program/138/writer/result.md with Bash (a heredoc; the Write tool may refuse the path): the branch and head sha, each commit, each verify command with its outcome, the leading-witness grep hits, the commits a fresh clone lacks, and an act-on list of anything you could not do or decided (each item: what, why). Then write M/.scratch/program/138/writer/done containing done.
