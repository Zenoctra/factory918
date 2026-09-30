# Cross-judge verdict: ticket #88 architect arena

| # | Criterion | A | B |
|---|---|---|---|
| 1 | Pinning, same mechanism, no factory dependency | 3 — release tarball + sha256 in one template-carried script; both CIs call it; Linux x86_64 only by choice, and A names that as an open risk. | 3 — same script shape, both checksums, platform branch, `sha256sum`/`shasum` fallback, and the pin enforced by `grep -qx "version: 0.11.0"` rather than by the image. |
| 2 | File sets and the fixture proof | 3 — 19 files (18 + the gate), globs against `template/`, never `.claude/`; fixture step runs the project globs in `/tmp/fx`. | 3 — same 19; the project globs live inside the script, so the fixture step and the template step are byte-identical (`bash .github/shellcheck.sh`) and cannot drift. |
| 3 | Findings resolved honestly; lane command = CI command | 2 — good judgments (SC2115 "not real, fixed anyway"), but four file-level SC2016 directives where two files hold 1 and 2 occurrences, and the lane types `shellcheck -x …` while CI runs the script: not the same command. | 3 — per-site directives at the verified lines (`review-comment.sh:40`, tests `:94`, `:509`); the SC2086 reason cites `set -f` at `delegation.sh:7`, which I confirmed; the lane types the CI command verbatim. |
| 4 | Doctor line | 3 — inline `if`/`else`, NOTE, four platforms, version in PASS. | 3 — capture-then-branch, the `:260-262` shape, NOTE, four platforms, and the fix text says why it is a NOTE. |
| 5 | Playbook / SOURCES / standards / AGENTS | 2 — all surfaces covered, but the `AGENTS.md` bullet and the playbook sentence name `shellcheck -x`, not the command CI runs. | 3 — every surface, and the `AGENTS.md` bullet is the CI line character for character. |
| 6 | Smallest honest diff, test-first order | 3 — four commits, gate red first; keeps a widened `bash -n` beside ShellCheck (duplication). | 3 — same order; `tests/shellcheck/gate.sh` earns its place because B's script has logic (glob expansion, fail-on-empty) that CI cannot exercise; drops `bash -n`. |
| | **Total** | **16** | **18** |

## Recommended base: B

B is the only candidate where the sentence the playbook asks a lane to run is literally the CI step, which is the ticket's stated reason for existing; its directives sit on verified individual lines instead of blanketing two files that hold one finding each, and its `set -f` reason is a fact about the code I could check rather than a restatement of intent. A's design is sound and its judgments are candid, but its lane runs an unpinned local tool with hand-typed flags, so drift between lane and CI is designed in.

## Graft from A

1. **`# shellcheck source-path=SCRIPTDIR source=layout.sh`** above the `.` line in `tests/spec-review/review-brief.sh:20` and `review-comment.sh:11`. A found this; B did not, and B papers over the same cwd sensitivity with a header sentence. Verified: from `cwd=/` with an absolute path, `shellcheck -x` reports `SC1091 … ./tests/spec-review/layout.sh: openBinaryFile: does not exist` plus SC2154 on `skill`; with the directive both are gone. It makes the per-file run location-independent, which is what a lane actually does.
2. **A's honest reading of SC2115.** Keep B's `${skills:?}` edit, but adopt A's reason: the invariant is stated in code, not a live bug.

## False claims found

- **A, §2:** "forcing `-s bash` on it adds a spurious SC2015 at 15:54". False.
  `shellcheck -f gcc tests/spec-review/fake-gh.sh` → `fake-gh.sh:15:54: note: … [SC2015]`, exit 1; `shellcheck -s bash -f gcc tests/spec-review/fake-gh.sh` → the identical single line, exit 1. `-s bash` adds nothing; it *hides* things: on `#!/bin/sh` with `arr=(a b)` it drops SC3030 and SC3054 (exit 0), which is B's E3 and is correct.
- **B, Point 3 table:** `factory918.sh:384` SC2115 called "**Real** … `rm -rf "/$n"` at the filesystem root is the failure mode". Overstated. `factory918.sh:377` is `local skills="$TEMPLATE/.agents/skills"`, a literal suffix, so `$skills` is never empty inside `cmd_sync`; A's "not real, fix anyway" is the accurate judgment. The edit is identical either way.

Spot-checks that held for both: 57 findings at `ab47eb9` with the documented code breakdown; `${skills:?}` clears both SC2115; `# shellcheck disable=SC2016 # reason` parses while the bare-prose form is SC1073+SC1072 (exit 1); `worktree-audit.sh` and `show-me-your-work/scripts/log.sh` are clean, so no new patch; B's `local -a dirs` count and `ls -d | wc -l` both print 72; both gate scripts pass `shellcheck` themselves (exit 0).
