# Fix 1 on PR #126 (#107): the SIGPIPE in the test helpers

The CI failure came from the test, not from the reading pack. Two test helpers stopped reading their pipe early, so the command feeding them was killed and the pipeline was marked failed. Both are fixed, and the ShellCheck count in AGENTS.md is corrected in a second commit.

## Branch and commits

- Branch `wt/107-fix1`, based on `origin/feat/review-reading-pack` at e0e113032b0259a593c5bff2779d2ca4ed393556. Nothing pushed.
- Commit 1, SIGPIPE fix: `3fbc71b2ebee517742fc1b0c1b80465b17b60fcf`, "Read the reading pack's section to the end in the test helpers, #107".
- Commit 2, ShellCheck count: `f58308b5eae3f6617cf3a5200e7679e5737a5702`, "Count the new script in the ShellCheck line, #107". This is the head.

## ShellCheck count commit (asked for mid-task)

`f58308b5eae3f6617cf3a5200e7679e5737a5702`. `AGENTS.md` line 38 now says "over 24 files". I took 24 from the output of the exact command on that line: `ShellCheck 0.11.0, files checked: 24`. A grep of the repository (without `research/`, `.scratch/` and the eval rounds' historical text) finds no other live count. `build_knowledge.py` leaves `git status` clean, and `check_knowledge.py` prints `knowledge ok: 119 files`.

## Root cause: the hypothesis is confirmed, with one correction

`fence()` and `notext()` piped `section "$1"` into an awk that ran `exit` as soon as it had its answer. After that, `section`'s awk died of SIGPIPE on its next write, with status 141. Under `pipefail`, `if ! section ... | awk ...` then sees a failed pipeline and reports a miss, although the reader found the right answer.

The correction is to the trigger. It is not "the section is larger than the kernel pipe buffer". The real pk-w section is only 15,858 bytes, and the `### pk/fenced.md` header starts at byte 5,675. The writer dies whenever it still has output to write after the reader has gone. So the trigger is the writer's stdio output buffer. glibc awk (mawk or gawk on Ubuntu) writes to a pipe in small blocks, so it still has blocks left when the reader exits. On macOS, BSD awk wrote the whole 16 KB section in one write before the reader could exit, so the test passed there. I inferred the buffer sizes from the behavior below and did not measure them on Linux.

Evidence, all run on this Mac (bash 3.2 as `bash`, BSD awk):

1. Synthetic briefs, with the target entries near the top of the section. Old helpers, 20 tries each (`.scratch/fix1/probe.sh`):
   - 1 KB brief: fence 0 misses, notext 0 misses. `section | awk '{exit}'` PIPESTATUS `0 0`.
   - 68 KB, 98 KB and 2 MB briefs: fence 20 of 20 misses, notext 20 of 20 misses. PIPESTATUS `141 0`: the writer was killed by SIGPIPE and the reader succeeded.
2. The real pk-w section, dumped from a throwaway copy of the test (since deleted), and written line by line with an `fflush()` every 40 lines, which imitates glibc's small writes (`.scratch/fix1/probe2.sh`, 50 runs). With the old fence reader, the writer was killed by SIGPIPE 50 of 50 times, and the reader itself missed 0 times. With the new reader, there was no SIGPIPE and no miss. This is the path CI takes.
3. `at()` (`grep | head -1 | cut`) has the same weakness. GNU `head -1` exits after one line, so grep can be killed when it has many matches. On this Mac it did not fail even with 40,000 matching lines, because BSD head/grep behave differently here. I fixed it anyway, because it can fail on Linux.

`reading-pack.sh` on Linux is ruled out. No gawk, mawk or busybox is installed on this machine, so I reasoned about each awk construct instead. They are all POSIX awk that mawk 1.3.4 and gawk both support: `match` with `RSTART`/`RLENGTH`, `substr`, `split`, `length` in `LC_ALL=C`, user functions with extra parameters used as locals, `?:`, bracket expressions such as `[(][)]` and `[{]`, and no interval expressions `{n}`. None of the user function names collides with a gawk builtin. The CI log also points at the helper, not the pack. The `entry` assertion for (9W) runs just before `fence` (9W) on the same section, reads to the end, and checks that the entry opens with a fence line and holds the right text. It passed on CI, and only the early-exiting `fence` failed.

## Changes (commit 1, `tests/spec-review/review-brief.sh` only)

- `fence()`: the `getline ... exit` reader is replaced by a state flag (`st` 0, then 1, then 2, then -1). It still checks only the first occurrence of the header, then a blank line, then the exact fence line. It reads to EOF.
- `notext()`: the same change. It checks the first occurrence of the line, then that the next line is blank, and reads to EOF. At EOF right after the line it still misses, as before.
- `at()`: `grep -m 1 -nxF -- "$2" "$1" | cut -d: -f1`. `cut` reads everything, and `-m 1` works in both GNU and BSD grep. When nothing matches, grep exits 1, as it did before.
- A two-line comment above `section()` states the rule that any reader of its output reads to the end.

Audited and left unchanged:
- `section` and `around` exit early, but they read a file, not a pipe.
- `entry` and `none` read to the end.
- `close_of` and `line_of` read files.
- `section | grep '^### '` and `section | grep -v '^$' | tail -1` (rows 23/24) read everything.
- `rows`, `funcs` and `sections` write to files.
- Lines 270 and 272 (`grep -o | head -1`, `head -2 | tail -1`) and line 1415 (`printf | grep -qF`) are older than #107, work on small inputs, and are outside this fix. See flag 3.

`reading-pack.sh` is unchanged. Its only early-exit reader is `head -n 1 "$tmp/blob" | tr -d '\r' | grep -qE ...`. grep matches whole lines, so it cannot exit before it has read tr's single line with its newline, which is all tr ever writes. Every other pipeline in the script ends in an awk, sort or while loop that reads to the end.

## Verification

- `bash tests/spec-review/review-brief.sh`: `ok 1294 assertions`, run after both commits. The unmodified test on e0e1130 also gives `ok 1294 assertions`, so the count is unchanged.
- `bash .github/shellcheck.sh tests/spec-review/review-brief.sh template/.agents/skills/spec-review/scripts/reading-pack.sh`: `ShellCheck 0.11.0, files checked: 2`, clean.
- The full ShellCheck command from AGENTS.md: `files checked: 24`, clean.
- Failure mode before and after, new helpers, same probes: 0 misses of 20 at 1 KB, 68 KB, 98 KB and 2 MB. The control `section | awk '{exit}'` still shows `141 0`, so the probe still exercises the mechanism. On the real section with small writes: before, SIGPIPE 50 of 50; after, 0 of 50.
- Negative cases (`.scratch/fix1/negative.sh`), old and new helpers both. fence rejects a four-backtick fence, a missing header, and a header whose next-but-one line is not the fence. notext rejects a missing line and a line followed by a non-blank line, and accepts a line followed by a blank. at returns nothing for a missing line. The result is bad=0 for both.
- I have not seen the fix pass on Linux CI. Nothing is pushed.

## Flags

1. fix: none open. Both commits are on `wt/107-fix1` and need to be pushed onto `feat/review-reading-pack` by the owner so CI can confirm on Ubuntu.
2. accept: the owner's hypothesis said "larger than what the pipe already buffered". The trigger is the writer's stdio output buffer, not the kernel pipe buffer. It fails at 16 KB on Linux, well below 64 KB. The fix is the same either way.
3. ask: three pre-#107 pipelines in the same test have the same shape: line 270 `grep -o | head -1`, line 272 `head -2 | tail -1`, and line 1415 `printf '%s' "$out" | grep -qF`. Their inputs are a few KB at most, so they are unlikely to fail. They were outside this ticket's additions, so I left them. Decide whether they get a ticket.
4. accept: `reading-pack.sh` was checked by reasoning only, because no mawk or gawk is on this machine. The Linux CI run after the push is the real test.
