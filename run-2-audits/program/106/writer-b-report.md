# Writer B report, ticket #106, design-hole redo (PR #125)

For a person: the amendment from 2026-09-23 is implemented in three commits on `wt/106-writer-b`, on top of `caecbc4`. A plain-code quote no longer makes round three fix-only, both variants of the audit's reproduction now print no `fix only after` line, and every listed check passes.

Branch `wt/106-writer-b`, worktree `/Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.claude/worktrees/agent-ad3d0c12b1425b29a`. Nothing was pushed, and nothing on GitHub was touched.

## Commits

```
8d3496a Say in step 6 which quotes and locations keep round three fix-only, #106
f33a08a Count only quoted fix lines and locations in the fix as inside it, #106
8fd83e1 Test the amended inside-the-fix rule and the uncovered table A cells, #106
```

1. `8fd83e1` holds the tests only. Against the scripts at `caecbc4`, the comment test's first failure is the new 3B `-` line cell ("a - line never counts (3B)"). The brief test's first failure is the moved `ff` helper at 2A: the old brief writes `four`, `hook fixed` and `walk fixed`, and the test expects `hook fixed` plus the ranges.
2. `f33a08a` changes the scripts. It replaces `review-brief.sh` edit 5 with the amendment's block verbatim and applies its header clause. It replaces `review-comment.sh` `outside()` and its header clause verbatim. Two header comment paragraphs were rewrapped to the file's width, with no change to their words.
3. `8d3496a` changes the prose. It edits the step 6 clause of `spec-review/SKILL.md` word for word from the amendment, regenerates `patches/mattpocock/spec-review.SKILL.md.patch` with the README's `diff -u` command (one changed line), and updates `SOURCES.md` item 6. The item named the old rule in two places: "added or removed to `<dir>/fix-lines`" and "quotes a line outside `<dir>/fix-lines`". `DECISIONS.md` is untouched.

## Act on

- fix: every table B cell and every test the amendment lists is implemented as written, except the 21A deviation below. This covers `at()`, the new `inside`, 3B relabeled, the two 3B `-`/header cells and the non-fix `+` cell, the 4B short marked lines, the 5B lone checkbox, the moved 6B plus the new lone added-line 6B, 14B in three variants, 15B's five no-`FO` cases and two `FO` cases, and the missing-ranges case. The brief test has the second fix commit's `a.txt`, `fix_lines='hook fixed'`, `fix_ranges`, and `ff`/`no_ff` over both files.
- fix: the point 2 cells have assertions: 7C, 8B, 8C, 9B, 9C, 10B, 10C (row 10's check is now a loop over 10A to 10C), 11B, 11C, 12B, 12C, 13C, 15C, 16B, 16C, 17C, 18B, 18C (with the refused sixth round), 19B, 19C and 21A. 6B/6C, 20B/20C and 21B each get a one-line comment in the test giving the amendment's reason.
- ask: for 21A the amendment says `pr me me:previous-1r.md me:previous-2f-crlf.md` "gives the 21C lines". It cannot as written. 21C runs `--previous` of (2F) alone and prints `settled: carried 1, dropped 0`. Over gh with (1R) before it, the brief prints `settled: carried 3, dropped 1`, because (1R)'s items carry. The cell asserts `$r3_fix` instead, the same output 5A gets from the LF history, plus the fix section. That keeps the cell's intent: the gh path's `split` reads a CRLF comment as it reads an LF one. Keeping the literal 21C lines would mean dropping (1R) from the history. Which do you want?
- accepted: for 12C the amendment says "the four single-file variants", but there are five: fenced, short, upper, trailing and bare. All five get the `--previous` assertions. The two multi-comment variants (stranger, rebuilt (2)) get only the 12B `--round 3` run, over gh, as the amendment says.
- accepted: `review-brief.sh`'s header sentence "(review-comment.sh: no hard finding of round two outside the lines of the fix commits it reviewed)" is left as it was. The amendment names only the "added or removed to `<dir>/fix-lines`" clause, and this sentence still holds loosely under the new rule.

No cell was left unimplemented.

## Verification (at `8d3496a`)

- `bash tests/spec-review/review-brief.sh`: exit 0, `ok 1104 assertions` (986 at `caecbc4`).
- `bash tests/spec-review/review-comment.sh`: exit 0, `ok 298 assertions` (264 at `caecbc4`).
- `bash tests/spec-review/no-stale-wording.sh`: exit 0, `ok: no stale wording`.
- `bash .github/shellcheck.sh factory918.sh template/.github/shellcheck.sh 'template/.claude/hooks/*.sh' 'template/.agents/skills/*/scripts/*.sh' 'tests/*/*.sh' 'tests/*/*/*.sh'`: exit 0, `ShellCheck 0.11.0, files checked: 23`, no findings.
- `bash tests/shellcheck/gate.sh`: exit 0, `ok 17 assertions`.
- `bash tests/hooks/delegation.sh`: exit 0, `ok 55 assertions`.
- `bash tests/poteto-mode/overlap.sh`: exit 0, `ok 57 assertions`.
- `bash tests/eval/reviewer/refusals.sh`: exit 0, `all 230 checks passed`.
- `bash tests/knowledge/provisional-ids.sh`: exit 0, `26 assertions passed` (this is in AGENTS.md's list).
- `./factory918.sh sync` and `python3 tools/build_knowledge.py` leave `git status --short` empty. `python3 tools/check_knowledge.py` prints `knowledge ok: 119 files`.
- Criterion 1: the rows 2A, 3A, 4A and 12A `same` assertions still pass, so the round-one and round-two briefs are byte for byte the same with and without the new lines.

## The audit's reproduction (section 7), rerun

The script is `.scratch/writer-b/repro.sh` in the worktree. It builds a round-two dir with a Would-break item at `Documented step: old.sh:40` quoting a plain ```` ```sh ```` block, then runs `review-comment.sh <dir>`. Variant one has fix lines `exit 1 # miss` and `exit 0`, and the quote `if [ -z "$dir" ]; then` / `  exit 0` / `fi`. Variant two has fix lines `exit 1 # miss` and `else`, and a quote holding `else`. Neither variant writes `fix-ranges`, just as in the audit.

New `review-comment.sh` (`f33a08a`), tails:

```
== exit0
Standards: 1 would break, 0 fail open, of 2; Spec: no spec; judged: act on 2 (0 fixed, 0 with a ticket), ask 0, consider 0, noted 0, dismissed 0; fixed point main.
round: 2 of 3
act-on items: 2
== else
Standards: 1 would break, 0 fail open, of 2; Spec: no spec; judged: act on 2 (0 fixed, 0 with a ticket), ask 0, consider 0, noted 0, dismissed 0; fixed point main.
round: 2 of 3
act-on items: 2
```

The same script run against `caecbc4`'s `review-comment.sh` (`.scratch/writer-b/repro-old.sh`) prints `fix only after 0123456789abcdef0123456789abcdef01234567` before `round: 2 of 3` in both variants. That confirms the audit's finding and shows the fix.

Opus 5.5 (1M context), Claude Code writer lane.
