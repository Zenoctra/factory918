verdict: ISSUES

Two small factual corrections, both in prose, neither in the committed code or fixtures. Everything the slice
asked to verify about the fixes themselves reproduced. Worktree
`/Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.claude/worktrees/agent-a30f3e77ac99201ea`,
detached at `01a1e5f46891d10b234fe9ee80cbd9e8c67d4438`; `git merge-base --is-ancestor 85988c7 HEAD` exit 0;
`git status --porcelain` empty at the start and at the end (every mutation below was restored and re-compared).
No model run launched, no GitHub write, `TMPDIR` private.

## 1. Reproducibility

- All twelve rounds rebuild byte for byte. `bash tests/eval/reviewer/rebuild.sh <round>` for `pr101-r1 pr102-r1
  pr102-r2 pr94-r1 pr94-r2 pr94-r3 pr96-r1 pr96-r2 pr96-r3 pr99-r1 pr99-r1b pr99-r2`: every one exit 0,
  `rebuild: <round>: identical`. Run with a `gh` shim **and** a `curl` shim first on `PATH`, each appending its
  argv to a log and exiting 1.
- No network call happened. The shim log was 0 lines after all twelve runs. (rebuild.sh installs its own `gh`
  stub ahead of mine inside `$tmp/bin`, so the outer shim is the backstop for anything the inner stub does not
  shadow; nothing reached it. The inner stub's default branch is `exit 1`, so an unhandled `gh` call fails loudly.)
- One-byte change fails and names the file, for two of the three input kinds:
  - `pr94-r1/inputs/ticket.md`, first byte replaced: exit 1, `rebuild: pr94-r1: spec-brief.md differs`.
  - `pr96-r3/inputs/blast-radius.md`, first byte replaced: exit 1, `rebuild: pr96-r3: standards-brief.md differs`.
  - `previous.txt`: **no mutation of it changes anything** — see Issue 1.
- Missing inputs do not pass silently:
  - `inputs/recipe` absent: exit 2, `rebuild: <inputs>/recipe missing`.
  - `previous.txt` absent (pr94-r2): exit 1, review-brief.sh's own `usage:` block.
  - `blast-radius.md` absent (pr96-r3): exit 1, review-brief.sh's cross-cutting refusal naming `--blast-radius`.
  - `ticket.md` absent (pr94-r1): exit 1; the inner stub's `cat` fails, review-brief.sh prints `gh could not
    fetch #89 (...); no spec`, and rebuild.sh then reports `spec-brief.md differs`.
- Method note (`tests/eval/reviewer/reviewer.py` docstring lines 4-9 plus `rebuild.sh`'s header): a stranger can
  do it. The fetch line (`git fetch origin 'refs/keep/103/*:refs/keep/103/*'`) and the command are both there,
  and rebuild.sh's header gives the exit codes and says it makes no network call. Two gaps, both self-correcting:
  the note names no way to enumerate the rounds (the nearest thing, `reviewer.py check --list`, prints
  `<round>/<axis>` brief ids, and passing one of those to `rebuild.sh` gives the exit-2 `recipe missing`
  message rather than a hint; `ls tests/eval/reviewer/rounds` is the answer); and the note does not say the
  twelve are run one at a time with no all-rounds mode.

## 2. Were the inputs committed faithfully?

`userContentEdits` (GraphQL) exposes the full body at every revision, so this is checkable. Checked all six
**regenerated** rounds, not two, against the issue's revision history and against the round's review-comment
timestamp (`gh api repos/Zenoctra/factory918/issues/comments/<id> --jq .created_at`), which upper-bounds when
the brief was built. Every committed `inputs/ticket.md` equals a real historical revision byte for byte apart
from one trailing newline, and in each case it is the revision that was current when that round ran:

| round | ticket | committed bytes | matching revision | round comment |
| --- | --- | --- | --- | --- |
| pr96-r1 | #88 | 8401 | 2026-09-22T15:06:20Z (8400) | 15:39:28Z |
| pr96-r2 | #88 | 8401 | 2026-09-22T15:06:20Z (8400) | 15:55:30Z |
| pr99-r1 | #90 | 32328 | 2026-09-22T16:43:24Z (32327) | 16:55:59Z |
| pr99-r1b | #90 | 38731 | 2026-09-22T17:06:35Z (38730) | 17:38:20Z |
| pr101-r1 | #91 | 12653 | 2026-09-22T17:02:34Z (12652) | 17:44:23Z |
| pr102-r1 | #93 | 54702 | 2026-09-22T19:50:03Z (54701) | 20:34:57Z |

Four of the six do **not** match the ticket's current body, which is the right answer: they match the body as it
stood then. The sharpest case is pr102-r1: the committed body is the 19:50:03Z revision, and the only later edit
(20:30:54Z, four minutes before the round-1 comment) begins `Amended 2026-09-22 by #93 (review round 1,
Standards item 1, no hole): ...` — i.e. the edit that round 1 itself caused. The inputs were captured before it.
Nothing here could not be checked.

## 3. PR body (`gh pr view 124 --json body`)

- gpt-6-astra matrix row: "That also needs a `provider-dispatch.md` row for the model, which
  `model-matrix.test.ts` does not allow today; whether that row is added, and where, waits on Manuel's answer to
  round 3's Ask." Tradeoffs repeats it. No ticket is named for it. Every `#N` in the whole body is `#94 #96 #99
  #101 #102 #103 #120 #121`; all eight exist on the repository. ok
- Spec proposal in tiers: "move `spec reviewer` from the lower tier (Claude Opus 5) to the upper tier (Claude
  Opus 5.5), keeping effort `high`." Fable appears once, as "Fable 5.1 was not launched: the operator's rule of
  2026-09-22 says Fable is never launched." Nothing proposes launching it. ok
- Trailer order: `Closes #103`, then the 🤖 attribution line, then `Claude Opus 5.5 on Claude Code`, and nothing
  after. ok
- Verification section names `rebuild.sh` ("`bash tests/eval/reviewer/rebuild.sh <round>` for all twelve rounds:
  `identical`"). It does **not** say there what CI does not run and why; that sentence ("It needs the reviewed
  heads, so it runs locally, not in CI, whose checkout is shallow and does not fetch `refs/keep/*`") lives in
  Scope instead. Present in the body, in the wrong section — see Note 1.

## 4. The owner's report (`.scratch/program/103/report.md`)

- Reviews records round 2's [S1] disposition: "[S1] (\"P103 leaves the Provisional id sequence\") had no fix
  commit and no Ask: #121's rule makes the ticket number the row id, and round 3 re-sorted it to Consider
  ([S5])." ok
- Criterion 4 names both: "The main table is `reviewer.py table` output; the dropout table's third column is
  edited by hand, as the section says." ok
- The M0 section says the same. `docs/M0-findings.md:176` ("`python3 tests/eval/reviewer/reviewer.py table`
  rebuilds the table from them") and the paragraph after the dropout table ("The dropout table's third column is
  edited by hand: `reviewer.py table` prints the path of one receipt there, and the column above gives what that
  receipt says instead, since the path exists only on this machine"). The PR body's fourth Verification bullet
  uses the same words. All three agree. ok

## 5. The new code

- `ae4bc6d` and `9f16641` survived the rebase unchanged: `git patch-id --stable` is `f24bec50…` for both
  `ae4bc6d` and `1dec0b2`, and `0ff1ae4b…` for both `9f16641` and `e8a3dbe`. `1dec0b2` touches 39 files, every
  one under `rounds/*/inputs/` (12 recipes + 12 ticket.md + 12 previous.txt + 3 blast-radius.md), nothing else.
  `9f16641`/`e8a3dbe` adds `rebuild.sh` and three docstring lines in `reviewer.py`.
- `bd6a9b6` and `01a1e5f` differ, correctly: pre-rebase it was 21→22 files, post-rebase 22→23, because #121's
  base adds `tests/knowledge/provisional-ids.sh`. 23 is the true count — the six globs of the AGENTS.md line
  expand to 23 distinct files at this head.
- Quoting: every expansion in `rebuild.sh` is double-quoted; `args` is a real array and `"${args[@]}"` is
  correctly quoted; the `gh` stub heredoc is quoted (`<<'STUB'`) so `$REBUILD_TICKET` expands at stub runtime,
  which is what the `case` patterns need. `set -euo pipefail` is set, so the `git archive | tar` pipeline and
  the `(cd … && bash review-brief.sh …)` subshell both abort the script on failure before the `cmp` loop runs.
  I found no quoting defect.
- Path escaping: `rdir="$here/rounds/$1"` is not validated, so `rebuild.sh ../../..` points outside `rounds/`.
  It only ever reads (`recipe`, `ticket.md`, `previous.txt`, `blast-radius.md`, `round`) and the missing-recipe
  check stops it almost immediately, so there is no write and no deletion outside `$tmp`. Note 2.
- Silent pass on a missing input: none found beyond Issue 1 (all four absent-input cases above fail loudly).
- Smaller: `inputs/recipe` carries its own `fixed_point` (short sha) while `round` carries a full one, and
  rebuild.sh uses the recipe's without checking they agree; `value()`'s `sed -n "s/^$1=//p"` would concatenate
  duplicate keys. Neither is triggered by any committed round.

## Issues

1. **`inputs/previous.txt` is committed but nothing verifies its contents; the record says otherwise.**
   Changing its first byte (pr94-r1, pr94-r2, pr102-r2), changing a carried judgment item's text inside a
   `cites:`-bearing item (pr99-r2, the only round whose `previous.txt` holds `cites:` lines), and truncating the
   whole file to the single byte `x` (pr99-r2 and pr94-r3) all still print `identical`. No brief in the set
   contains a `## Settled in earlier rounds` section, and `rebuild.sh` passes `--round N` from the recipe, which
   overrides the only other thing `previous.txt` feeds. So the file's whole observable effect on the rebuild is
   that it exists. The twelve `previous.txt` files are unverified inputs: a wrong one would pass.
   `.scratch/program/103/report.md`, criterion 1, claims "a one-byte change to an input makes it exit 1", which
   is true for `ticket.md` and `blast-radius.md` and false for `previous.txt`. Fix is in the prose, not the code
   (the briefs genuinely are a function of ticket body + grounding + diff here): say which inputs the comparison
   pins and which it only requires to be present. The committed PR body does not make this claim and needs no
   change for it.

2. **The PR body still says the ShellCheck gate covers 22 files; at this head it is 23.** Two places: the first
   bullet under "Checks run at the head of this branch" ("The AGENTS.md ShellCheck line, now with
   `'tests/*/*/*.sh'`: 22 files, clean") and the closing line of the Verification section ("22 files, with
   `rebuild.sh`"). `AGENTS.md` at `01a1e5f` says 23, and expanding the line's globs at this head gives 23
   distinct files. The body was written before the rebase onto #121's head, which added the 23rd. The owner's
   report repeats the stale 22 twice (Status, CI). PR-body text only; the code and AGENTS.md are right.

## Notes

1. Slice item 3 asked the Verification section to say what CI does not run and why. The sentence exists, in
   Scope, and is accurate. Moving or repeating one clause under Verification would close it.
2. `rebuild.sh <round>` does not constrain `<round>` to a name under `rounds/`. Read-only, and a bad value dies
   on the `recipe missing` check, so it is a hygiene note, not a hole.
3. `.scratch/program/103/report.md` criterion 4 reads "... as the section says. with a blinded-judge audit
   (anchors agree on 115 of 116 Claude decisions and 28 of 31 Astra decisions)." — a sentence fragment joined to
   the previous sentence by a full stop. `docs/M0-findings.md:190` has a similar seam ("... only on this
   machine. How to read it. Recall is ..."), where "How to read it." reads as a heading that ended up inline.
   Both are prose, in an uncommitted report and a committed record respectively.
4. The owner's report is stale against this head in ways the rebase explains and which nothing needs to act on:
   Head `bd6a9b6`, base `main`, "all new commits with no rebase". Only the file count (Issue 2) matters.
5. `python3 tests/eval/reviewer/reviewer.py check --list` exits 0 and prints all 24 brief ids at this head.

## Commands

```
git fetch origin feat/reviewer-model-eval feat/provisional-ticket-ids feat/speed-lessons main 'refs/keep/103/*:refs/keep/103/*'   # 0
git checkout --detach 01a1e5f46891d10b234fe9ee80cbd9e8c67d4438                                                                   # 0
git merge-base --is-ancestor 85988c7 HEAD                                                                                        # 0
PATH=<shim>:$PATH GH_SHIM_LOG=<log> TMPDIR=<private> bash tests/eval/reviewer/rebuild.sh <each of 12 rounds>                      # 0 x12, "identical"
   (shim log: 0 lines)
<first byte of pr94-r1/inputs/ticket.md changed>      bash tests/eval/reviewer/rebuild.sh pr94-r1                                 # 1, "spec-brief.md differs"
<first byte of pr96-r3/inputs/blast-radius.md changed> bash tests/eval/reviewer/rebuild.sh pr96-r3                                # 1, "standards-brief.md differs"
<pr99-r2/inputs/previous.txt truncated to one byte>   bash tests/eval/reviewer/rebuild.sh pr99-r2                                 # 0, "identical"   <-- Issue 1
<pr94-r3/inputs/previous.txt truncated to one byte>   bash tests/eval/reviewer/rebuild.sh pr94-r3                                 # 0, "identical"   <-- Issue 1
<pr94-r2/inputs/previous.txt removed>                 bash tests/eval/reviewer/rebuild.sh pr94-r2                                 # 1, review-brief usage
<pr96-r3/inputs/blast-radius.md removed>              bash tests/eval/reviewer/rebuild.sh pr96-r3                                 # 1, cross-cutting refusal
<pr94-r1/inputs/ticket.md removed>                    bash tests/eval/reviewer/rebuild.sh pr94-r1                                 # 1, "gh could not fetch #89"
gh api graphql (issue userContentEdits, #88 #90 #91 #93)                                                                         # 0
gh api repos/Zenoctra/factory918/issues/comments/<6 ids> --jq .created_at                                                        # 0
gh pr view 124 --json body,baseRefName,headRefName,state                                                                         # 0  (base feat/provisional-ticket-ids, OPEN)
git show ae4bc6d | git patch-id --stable ; git show 1dec0b2 | git patch-id --stable                                              # equal
git show 9f16641 | git patch-id --stable ; git show e8a3dbe | git patch-id --stable                                              # equal
ls -1 <the six AGENTS.md globs> | sort -u | wc -l                                                                                # 23
python3 tests/eval/reviewer/reviewer.py check --list                                                                             # 0, 24 ids
git status --porcelain                                                                                                           # empty
```
