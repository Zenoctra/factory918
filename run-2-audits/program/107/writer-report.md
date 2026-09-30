# #107 writer report

The reading pack is built, and every cell in the #107 table has a passing assertion in both layouts. There are three commits on `wt/107-writer`. Nothing was pushed or posted.

Branch `wt/107-writer`, head `94f48478981ec5d1eca9706f83c8a0d4494d1658`, on `0edf8c8` (tip of `feat/fix-only-from-round-two`).

## Commits

1. `8a40823` Test the reading pack of #107, one assertion per cell, before the script. This commit fails at (1W) as intended.
2. `3b8c81b` Carry a reading pack in both review briefs, #107. Adds `reading-pack.sh`, the `review-brief.sh` call, the `cat` in `common()`, the Report sentence and a header line. Also replaces a `sprintf("%70000s")` in the test, because of mawk's sprintf limit.
3. `94f4847` Name the reading pack in spec-review step 4 and keep its script on sync, #107. Covers SKILL.md, the regenerated patch, SOURCES.md item 6 and `keep_files`.

## Verification (at the head)

- `bash tests/spec-review/review-brief.sh`: ok 1294 assertions, about 40 s on this Mac.
- `bash tests/spec-review/review-comment.sh`: ok 298.
- `bash tests/spec-review/no-stale-wording.sh`: ok.
- `bash tests/hooks/delegation.sh`: ok 55.
- `bash tests/eval/reviewer/refusals.sh`: all 230 passed.
- `bash .github/shellcheck.sh` over the four files: clean (0.11.0, 4 files).
- `bash tests/shellcheck/gate.sh`: ok 17.
- `./factory918.sh sync`: `git status` stays clean after it runs. This shows the patch reproduces SKILL.md and that `keep_files` keeps `reading-pack.sh`.
- Real run: `review-brief.sh origin/feat/fix-only-from-round-two --ticket 107 --round 1` on my own diff exited 0. It printed round 1 and wrote a 60012-byte `pack.md`, identical in both briefs, with no over line.
  - Entries: SOURCES.md line 18, a one-line window because item 6 is one long line. `factory918.sh` 379-405, the `keep_files` block. The patch 25-81. SKILL.md 69-94.
  - `review-brief.sh` gives four entries: the header comment window 5-61, the pack call, `common()`/`report_rules()` in a four-backtick fence, and the `pack_rule` lines. The test gives the header, the helpers, and the new block 1451-1765 in a seven-backtick fence.
  - `reading-pack.sh` itself appears as `added, 211 lines; the diff carries it whole: no text`.
  - Each entry reads right. `.claude/state/review` was deleted afterwards.
- CI path (Linux, GNU tools): not run. There is no Linux image here with git and jq, and pulling one is a download nobody approved. What I did for portability:
  - `LC_ALL=C` in the script, so `length()` counts bytes under gawk as well.
  - No awk interval expressions; brackets instead of `\{` and `\(`.
  - No `sed -i`, `stat`, `readlink -f`, or `sprintf` widths.
  - Only POSIX `sort`, `tr`, `head`, `grep -E` and `wc`.
  - Bash 3.2 here and bash 5 on CI.
  - Git features used: `git switch` (2.23+) and `:(literal)` pathspecs in `ls-tree` and `diff`, which I checked with 2.51.

## Flags

1. **Ask: commit 2 is not fully green.** The Tests section puts the SKILL.md drift guard in commit 1, and the brief puts SKILL.md in commit 3. At `3b8c81b`, every table cell and the cutoffs line pass, but the two SKILL.md assertions fail until `94f4847`. To fix, either move the SKILL.md edit into commit 2 or move those two assertions into commit 3.
2. **Accept or change: the newline-path reason.** The contract names no reason text for this case. I wrote `### $'pk/nl\nname.txt', a path holding a newline: no text`, and cells (21W) and (21F) assert that text.
3. **Accept: a Markdown section is trimmed of trailing blank lines, but never above the changed line.** A changed trailing blank stays inside its own unit. The contract does not cover this case.
4. **Accept: shell function edges the contract leaves open.**
   - A function start with no later column-0 `}` is not a function, so the change falls through to the comment-led block.
   - `name()` must have no space before `()`. Names match `[A-Za-z_][A-Za-z0-9_]*`.
   - If there is no column-0 `#` run above the line, the comment-led block starts at line 1.
5. **Ask: merged entries can go past 4096 bytes.** Units are merged after each one is chosen, as the contract says. In the real run, the test's added block became one 315-line entry. Rows 22 to 24 still bound the total.
6. **Ask: the `added` wording.** `added, <n> lines; the diff carries it whole` also appears when the brief hands the diff by path (over 500 lines; the real run's diff was 742). It is true of `<dir>/diff`, but the reviewer then has to open that file.
7. **Accept: row 25 and the trailing blank.** Every pack ends with a blank separator line, the sweep line included. The (25W) assertion compares through command substitution, which drops that blank.
8. **Accept: extra checks in (28W) and (28F).** Besides the exact stdout, round, reviewed and state files, they assert that `<dir>` holds exactly the old files plus `pack.md`, and no `fix-lines`.
9. **Accept: slower test.** `review-brief.sh` now runs the pack on every one of the test's roughly 150 runs per layout. The suite takes about 40 s here. I did not measure the old time.

Opus 5.5, Claude Code (writer lane).
