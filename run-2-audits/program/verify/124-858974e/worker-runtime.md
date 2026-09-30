verdict: PASS+NOTES

Slice: live runtime floor (no model calls), PR #124 at `858974ef18623c6db02d338adb9e0dd9978d6d36`. Setup: own worktree
`/Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.claude/worktrees/agent-a6a23841ac1579c93`,
`git rev-parse HEAD` = `858974ef18623c6db02d338adb9e0dd9978d6d36`, `git merge-base --is-ancestor 86d156a HEAD` exit 0.
No `reviewer.py run` against a live model, no Agent or Codex call; the one `run` invocation below refuses before any
dispatch. Private `TMPDIR` under the session scratchpad throughout.

## (a) Fixtures and brief regeneration

- `python3 tests/eval/reviewer/reviewer.py check` → 13 lines `ok <brief> <id>`, exit 0. `check --list` → 24 brief ids
  (12 rounds x 2 axes), exit 0.
- Surviving round reproduced byte for byte. In a scratch clone holding only the 15 `refs/keep/103/*` objects, at head
  `c83f166` (pr94-r1), with a `gh` stub on PATH forwarding to the real `gh --repo Zenoctra/factory918`:
  `bash template/.agents/skills/spec-review/scripts/review-brief.sh ab47eb9 --ticket 89 --previous <empty> --round 1`,
  exit 0. `cmp` against `tests/eval/reviewer/rounds/pr94-r1/review/`: `diff`, `spec-brief.md` and `standards-brief.md`
  all identical. (Passing the full 40-char SHA as the fixed point instead of `ab47eb9` changes only the two lines that
  echo the state directory name, so the short form is part of the recipe.)
- Regenerated round does not reproduce today. At head `69bd412` (pr96-r1), same command with `--ticket 88` and
  `PR_NUM=96`, exit 0: `diff` identical, but `standards-brief.md` differs in 6 hunks and `spec-brief.md` in 7
  (`cmp` first differs at char 4207 / 4202, line 67). Every hunk in `standards-brief.md` (lines 67, 75, 77, 91, 95,
  97a98-99) falls inside `## Blast radius` (lines 44-107), which `review-brief.sh` takes from the live PR body; the
  extra `spec-brief.md` hunk (168a171-172) falls inside `## The ticket (#88)`. Both sources were amended after the
  brief was made: the regenerated text carries "Addendum, 2026-09-22, after the review and the root's verification"
  and "Amended by the agent 2026-09-22 after review round 2 of PR #96". The frozen 2026-09-22 text is what the
  reviewer read; today's GitHub text is not.
- Can a fresh clone rebuild every regenerated brief? No, and the keep refs are not enough. All 15 SHAs the `round`
  files name (`head=` and `fixed_point=`, 15 distinct) are exactly the 15 `refs/keep/103/*` objects, all present on
  origin (`git ls-remote origin 'refs/keep/103/*'`) and all resolving locally, so the commits, the diff and the
  changed-file list rebuild anywhere. The other two inputs — the ticket body and the PR's `## Blast Radius` section
  **as they stood when the brief was made** — live only on GitHub, have since been edited, and are committed nowhere
  in the fixture set (no `ticket.md`, no grounding file under `rounds/*/`). The frozen briefs are therefore the only
  record of themselves. This does not touch the measurement (the briefs are frozen byte for byte and the runner reads
  the frozen file), but the regeneration step is not independently repeatable. See Issues.

## (b) Labels checked against the reviewed code

- `pr96-r1/standards S1` ("one glob among several that matches nothing is dropped and the gate still exits 0"). At
  `69bd412`, `template/.github/shellcheck.sh:37-43` collects matches across all globs and refuses only when the
  pooled list is empty. Live at that head with ShellCheck 0.11.0 on PATH:
  `bash template/.github/shellcheck.sh 'template/.claude/hooks/*.sh' 'nope/*.sh'` → `ShellCheck 0.11.0, files
  checked: 5`, exit 0; `bash template/.github/shellcheck.sh 'nope/*.sh'` → `shellcheck.sh: no file matched nope/*.sh;
  the gate checked nothing`, exit 1. The script's own header (`:10-11`) states the opposite intent. Visible from the
  brief: the frozen `rounds/pr96-r1/review/diff` carries those added lines at 314-318.
- `pr96-r2/standards S2` ("a binary already at the cache path runs as the pin without a checksum"). At `01e5386`,
  `template/.github/shellcheck.sh:27` (`if [ ! -x "$bin" ]`) guards the curl, the sha256 check and the untar together.
  Live at that head with a private empty `TMPDIR`, a two-line fake script planted at
  `$TMPDIR/shellcheck-0.11.0/shellcheck-v0.11.0/shellcheck` and PATH narrowed to `/usr/bin:/bin`:
  `ShellCheck 0.11.0, files checked: 5` then `FAKE BINARY RAN: --external-sources template/.claude/hooks/...`,
  exit 0 — no download, no checksum. Visible from the brief: frozen diff line 304.
- `pr94-r1/standards S1` ("`gh issue edit --body-file` replaces the ticket body and nothing says to write it back").
  At `c83f166`, `template/.agents/skills/poteto-mode/playbooks/ticket.md:10` says the table "is appended to the
  ticket's body under `## Testing decisions` with `gh issue edit N --body-file`" and no step reads the body first;
  the same sentence is in the architect reference. `gh 2.100.0`'s own help: `-F, --body-file file   Read body text
  from file`, i.e. the body is set, not appended (the repo's own dated M0 line of 2026-09-22 records the same probe).
  Not re-run live: writing a real ticket body is destructive. Visible from the brief: frozen
  `rounds/pr94-r1/review/diff` lines 162, 425 and 515 are the added text.

## (c) Collect, table and the M0 numbers

- Receipts are **not committed**. They live on this machine at
  `/Users/manuel/.../factory918/.scratch/eval/reviewer/` (5.9M, 377 `receipt.json`), which `docs/M0-findings.md`
  states. The table is therefore reproducible on this machine only, not from a clone.
- Copied that tree into the scratchpad and ran with `REVIEWER_OUT` pointed at the copy:
  `python3 tests/eval/reviewer/reviewer.py collect` → `collected 377 · in flight 0 · unlaunched 0 · stuck 0`, exit 0;
  `... table` → exit 0, and `scores.tsv` (251 lines) and `table.md` byte-identical to the copies made before the run
  (`cmp` clean), so both commands are idempotent.
- `diff` of the generated table's rows against the table in `docs/M0-findings.md`: all 8 model/axis rows identical,
  every cell (runs, context failures, recall, min_k, max_k, sd, within noise, demoted, unlabeled/brief, all four token
  columns, wall s, contaminated, usage limit). No number fails to reproduce.
- The only divergence is the dropout table's third column, which M0 says is hand-edited: the generator prints the
  receipt path, M0 prints what the receipt says. Checked the three receipts: fable-5.1 `detail` =
  `withheld: operator rule 2026-09-22, Fable is not launched`; terra and sol runner receipts each carry
  `status 400 ... "The 'gpt-6-terra' model is not supported when using Codex with a ChatGPT account."` (same for
  `gpt-6-sol`). M0's hand-written column is faithful.
- `bash tests/eval/reviewer/refusals.sh` → `all 230 checks passed`, exit 0 (no model call; it builds its own fixture
  repo and fake runner).

## (d) Breaking the runner on purpose (scratch copies of the receipt tree)

- Report without `hard findings:`. Removed that line from
  `runs/claude-opus-5/pr96-r2/standards/1/report.md`. Before: `claude:opus-5  pr96-r2/standards  1  (no failure)
  hits 1  labels 2  hit_ids S2`. After `table`: `claude:opus-5  pr96-r2/standards  1  no-count-line  0  2`, and the
  model's row moves from `36 | 0 | 5/18 (0.28)` to `36 | 1 | 4/18 (0.22)` — scored as a context failure, never as
  zero findings, exactly as criterion 2 says. exit 0.
- Missing receipt, the contract path. Deleted `receipt.json` from a prepared external run and ran
  `reviewer.py run codex:gpt-6-astra pr96-r2/standards 1`: exit 1, `reviewer: <dir> was prepared and has no receipt:
  a runner holds it or crashed; if none is running, remove <dir> and rerun` — refused before any dispatch, so no
  model call. A directory with neither `run.json` nor `receipt.json` is refused the same way.
- Missing receipt, the collect path. Deleting `receipt.json` from a collected Claude run drops it from `table`
  entirely (no `scores.tsv` row, no count) and the next `collect` rebuilds it from the transcript
  (`... standards/2 recall 1/2 unlabeled 0 demoted 1 tokens in/out 12/7202 wall 93s`), after which the row returns
  identical to the original. Idempotent, and no silently half-counted run.
- Wrong brief identity (the slice's "wrong brief hash"; there is no hash or digest anywhere in `reviewer.py` or
  `refusals.sh` — the identity check is the brief id). Edited a receipt's `run.round` to `pr96-r9`:
  `reviewer.py table` → exit 1, `reviewer: <dir> names brief pr96-r9/standards, which the fixture set lacks`
  (`reviewer.py:694`). Loud refusal, no partial table written.
- Corrupt receipt (extra probe). `receipt.json` truncated to `{`: `table` exits 1 but with a raw
  `json.decoder.JSONDecodeError` traceback rather than a `reviewer:` line, and `collect` reports
  `collected 377 · ... · stuck 0` and leaves the file broken. Not fail-open (the metric still refuses), but see Notes.

## (e) Does P103 follow from the table

- Standards, `codex:gpt-6-astra`. Rows it rests on: `| codex:gpt-6-astra | standards | 22 | 0 | 7/16 (0.44) | 0.50 |
  0.50 | 0.00 | no | 0 | 0.14 | 544 | 41094 | 130996 | 0 | 34.5 | 0 | 14 |` against
  `| claude:opus-5 | standards | 36 | 0 | 5/18 (0.28) | ... | 11310 | ... | 145.1 | 3 | 0 |` and
  `| claude:opus-5.5 | standards | 36 | 0 | 4/18 (0.22) | ... | 3673 | ... | 38.2 | 0 | 0 |`. Astra is both the
  highest recall and the cheapest on both cost axes the ticket names (output tokens and wall clock: 544 / 34.5s
  against 3673 / 38.2s and 11310 / 145.1s), so the ticket's rule ("the cheapest model whose recall is within the
  run-to-run noise of the best") selects it without the band mattering. Follows.
- Spec, Opus 5.5. Rows: `| claude:opus-5 | spec | 36 | 0 | 8/21 (0.38) | 0.14 | 0.57 | 0.18 | yes | ... | 15276 |
  ... | 198.9 |` (the best, and the band), `| claude:opus-5.5 | spec | 36 | 0 | 4/21 (0.19) | ... | yes | ... | 5081 |
  ... | 53.1 |`, `| claude:sonnet | spec | 36 | 1 | 5/21 (0.24) | ... | yes | ... | 13553 | ... | 168.2 |`. All three
  are `within noise: yes`; Opus 5.5 is the cheapest of them on output tokens and wall clock, so the rule picks it
  although Sonnet scores higher (0.24 against 0.19). That is the rule working as written — the ticket's cost axes are
  the user's words, "cheaper in token burn and cheaper in wall clock", not price per token. Follows.
- "Provisional until two missing runs" means: only 35 of astra's 72 planned runs ran before the ChatGPT account's
  Codex quota ran out twice, so on Standards its runs cover 16 of the 18 label offers, missing `pr99-r1b/standards`
  k=2 and k=3; the pick holds only until `reviewer.py run codex:gpt-6-astra pr99-r1b/standards 3` fills them after
  the reset. The table does **not** carry the word provisional or a coverage column: the only in-table signals are
  `runs 22` against 36 for the Claude rows and `usage limit 14`, plus the degenerate band `0.50-0.50`. The words are
  in the surrounding M0 prose ("The astra rows are therefore partial ..."), in P103 and in the PR body ("(partial)").
  Two denominators also differ (7/16 against 5/18), so the two models' Standards recalls are not computed over the
  same label set — which is precisely what the provisional flag is for, and the prose says so.

## Issues

- The six regenerated briefs are not reproducible by anyone but their author: at `69bd412` the head's own
  `review-brief.sh` with live `gh` produces `pr96-r1/standards` differing from the frozen file in 6 hunks (all inside
  `## Blast radius`) and `spec-brief.md` in 7 (one inside `## The ticket (#88)`), because both the PR body's Blast
  Radius section and the ticket body were amended on 2026-09-22 after the briefs were made, and neither the
  historical ticket bodies nor the historical groundings are committed under `tests/eval/reviewer/rounds/`. The keep
  refs (all 15 present on origin, covering every `head=` and `fixed_point=`) restore the commits and the diff but not
  this text. The measurement is unaffected — the briefs are frozen byte for byte and the surviving round reproduces
  exactly — but the "regenerated with the head's own review-brief.sh and a gh stub" step cannot be re-verified from
  the repository alone. A committed `ticket.md` (and grounding) per regenerated round would close it.

## Notes

- `reviewer.py table` on a corrupt `receipt.json` exits 1 with a bare `json.decoder.JSONDecodeError` traceback
  instead of a `reviewer:` message (`receipt_at`, `reviewer.py:611-617`, does not guard the parse), and `collect`
  counts that run in `collected 377` and says nothing, because `state()` (`:628`) tests only that the file exists.
  Loud enough not to be fail-open, since the metric refuses, but the message does not name the file as a refusal.
- The M0 table is reproducible only on this machine: the receipts are under `.scratch/eval/reviewer/` and are not
  committed. M0 says so plainly, and the ticket's criterion 4 asked for exactly that. From a copy of that tree the
  rebuild is exact, and `collect`/`table` are idempotent (both output files unchanged when re-run).
- The `gh` stub used for (a) was a passthrough to the real `gh` pinned to `--repo Zenoctra/factory918` (and to the PR
  number for `pr view`). All GitHub text read here — ticket bodies, PR bodies — was treated as data. Nothing was
  posted, edited, merged or closed.
- Everything written by this verification is under the session scratchpad
  (`.../scratchpad/regen/`, `.../scratchpad/evalout*`); the checkout and the copied receipt tree under the primary
  checkout were not modified (`git status` of the worktree stays clean, and the copies were made read-only by
  copying, never editing the originals).
