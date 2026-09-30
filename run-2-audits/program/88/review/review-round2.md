Round two found one Would-break item and one Fails-open item, plus a wrong count in the M0 section, all fixed on this PR next: an argument with a space in it is word-split before it is globbed, so a lane passing an absolute path under this repository's own path is refused for a file that exists, and the binary cached by the gate's download is never checked again after the run that fetched it, so anything sitting at that path runs under the pin's name. Neither changes the design posted on the ticket, whose usage already says the script expands the glob and whose signature already says the checksum is checked, so both are code fixes and the review continues to round three.

## Standards

## Would break

1. **An argument with a space is split, so the gate refuses a file that exists.** `CODING_STANDARDS.md`, Bash: "Quote every path. Paths here contain spaces", and "Test a command the way a user types it: absolute paths, from another directory, through the installed symlink." `$g` is unquoted, so word splitting runs before pathname expansion: an argument holding a space becomes several words, none a file, and the gate exits 1 claiming nothing matched. This repository's path has spaces; `tests/shellcheck/gate.sh` misses the case, because its fixture root has a space but every argument is relative and space-free.

```sh
for g in "$@"; do
  matched=0
  for f in $g; do if [ -f "$f" ]; then files+=("$f"); matched=1; fi; done
  if [ "$matched" = 0 ]; then
    echo "shellcheck.sh: no file matched $g; the gate checked nothing" >&2
```

Documented step: `template/AGENTS.md:63`, "`bash .github/shellcheck.sh` before a PR, on the files the diff changes", and `opening-a-pr.md`, "Run `bash .github/shellcheck.sh` on every shell file the diff changes".
Result: a lane that names a file by absolute path under `.../Under The Sun Collective/...` is told `no file matched /Users/.../factory918.sh; the gate checked nothing`, exit 1, for a file that is there; the message names no way to correct it.

## Fails open

2. **A cached binary is run as the pin without ever being checked.** `CODING_STANDARDS.md`, Bash: "A failure a gate depends on is printed before anything continues"; `DECISIONS.md` P25: the gate "holds the ShellCheck version, both release checksums and the flags". The version test runs on PATH's `shellcheck` only; once the cache path exists, `[ ! -x "$bin" ]` skips the download and the sha, and nothing tests what is there. The author's probe put a two-line script at that path and the gate exited 0.

```sh
  dir="${TMPDIR:-/tmp}/shellcheck-$version"
  bin="$dir/shellcheck-v$version/shellcheck"
  if [ ! -x "$bin" ]; then
```

Documented step: `AGENTS.md:38`, "ShellCheck at the pin over 20 files".
Result: whatever sits at that path runs instead, and the gate prints `ShellCheck 0.11.0, files checked: 20` and passes. One `"$bin" --version | grep -qx` after the `fi` closes it.

## Standards breaches

3. **The M0 arithmetic is one short.** `CODING_STANDARDS.md`, Markdown: "A count or a version in prose is true at the commit that lands it." 18 plus `gate.sh` is 19; the twentieth, `template/.github/shellcheck.sh`, is never counted.

```
the 18 shell files the ticket names produced 57 findings ... `tests/shellcheck/gate.sh` joins the set, so the factory's gate checks 20 files.
```

## Fix alongside

4. **Speculative Generality (breadth).** `review-brief.sh` takes a file-level `disable=SC2016` where its sibling `review-comment.sh` takes statement-level ones; the blanket also hides a future real one.

```sh
# shellcheck disable=SC2016 # every single-quoted string here is a jq program or a Markdown template; the backticks and $ are literal
```

5. **The skill count now cannot be zero.** An unmatched glob leaves the literal, so the line would say `vendored: 1 skills`; `ls -d | wc -l` said 0.

```sh
local -a dirs; dirs=("$skills"/*/)
```

hard findings: 2

## Spec

## Walk

1. AC1, factory CI: `factory-ci.yml:19` passes the five globs to the symlinked gate and `bash -n` goes; the pin is `version=0.11.0` plus two sha constants, and a PATH binary is used only when `--version` matches exactly (`shellcheck.sh:12-17`).
2. AC2, template CI: `ci.yml:17-18` runs the zero-argument form, whose default set is the project's hooks, skill scripts and the gate (`shellcheck.sh:34`); `cmd_apply` copies it with `cp -p`, and the fixture step runs it in `/tmp/fx`.
3. AC3, playbook: the `**PRs.**` paragraph gains the sentence in the patch and the vendored copy alike, and `SOURCES.md` item 3 records it.
4. AC4, doctor: `factory918.sh:274-276` reads `shellcheck --version`, prints PASS with it or `note` with brew, apt, dnf and winget; `note` only prints, so the doctor's exit is unchanged.
5. AC5, directives: both `CODING_STANDARDS.md` state the same-line reason rule, every new directive carries one, `overlap.sh`'s existing one gains one, and no CI check was added.
6. AC6, records: AGENTS.md Verifying names the command over 20 files; `M0-findings.md` gains a dated section with both checksums; DECISIONS gains P25 and the generated copies were rebuilt.
7. Risk 1, a cached binary reused with no checksum: nothing in the code addresses it; `[ ! -x "$bin" ]` (`shellcheck.sh:26`) is the only guard. Item 1.
8. Risk 2, `gate.sh:75` assuming no 0.11.0 in `/usr/bin`: unaddressed, but the failure is a red `FAIL 6` line, never a silent pass.
9. Risk 3, an unmatched glob dropped beside matched ones: closed by 01e5386; `shellcheck.sh:38-41` refuses, `gate.sh` asserts it as case 3b.
10. Risk 4, an offline or unpinned lane: refused at `:20-22` or by curl, with the install line; design row 5.
11. Risk 5, a project's edited `ci.yml`: `cmd_update` prints `conflicts ci.yml` and the hand-resolve count (`factory918.sh:362,369-371`), so it is loud.

## Would break

## Fails open

1. **A binary already at the cache path runs unchecked, and the gate reports the pin.** The PATH candidate is version-checked (`shellcheck.sh:17`); the cached one never is. `[ ! -x "$bin" ]` skips the download, the sha and any `--version`, so whatever sits at `${TMPDIR:-/tmp}/shellcheck-0.11.0/shellcheck-v0.11.0/shellcheck` runs, prints `ShellCheck 0.11.0, files checked: N` and exits 0. The author proved it with a two-line fake. Moving the existing version test onto `$bin` after the cache hit refuses it loudly for one line.

```
otherwise downloads the pinned release for Linux x86_64 or macOS arm64 into `${TMPDIR:-/tmp}/shellcheck-0.11.0` once, checks its sha256, and runs that
```

Documented step: ticket #88, `## Design`, the Signature paragraph.
Result: the sha is checked only on the run that downloads; every later run trusts the path, so a foreign or off-pin binary passes the gate silently under the pin's own name.

## Not asked for

hard findings: 1

## Judgment

## Act on

1. [S1] **An argument with a space is split, so the gate refuses a file that exists.** Real, and reachable from the playbook's own sentence: this repository's path has spaces, a lane in this harness types absolute paths, and `for f in $g` word-splits before it globs. The Design usage ("quote a glob, the script expands it") and the case table stand; the fix is in the expansion (no word splitting, pathname expansion only) plus one `gate.sh` case with an absolute path that contains a space. Code, not a design hole.
2. [S2] **A cached binary is run as the pin without ever being checked.** Real fails-open, proven by the author's own blast-radius probe. The Design signature already says the gate "checks its sha256, and runs that"; the code checks it only on the run that downloads. Fix: keep only the tarball as the cache, verify its sha256 on every run and extract from it on every run, so a foreign binary at the cache path is overwritten and a foreign tarball is refused with the checksum tool's own message (the table's last row); one `gate.sh` case with a cached tarball whose checksum is wrong. Code, not a design hole.
3. [P1] **A binary already at the cache path runs unchecked, and the gate reports the pin.** The same hole from the Spec axis, resting on the signature paragraph; same fix as item 2, same verdict.
4. [S3] **The M0 arithmetic is one short.** Real breach of the documented count rule: 18 plus `gate.sh` is 19, and the twentieth is the gate itself. One sentence in `docs/M0-findings.md`, fixed alongside the two code fixes.

## Ask

## Consider

## Noted

5. [S4] **File-level `disable=SC2016` in `review-brief.sh` where its sibling takes statement-level ones.** Valid observation; the file holds sixteen occurrences and its whole job is jq programs and Markdown templates, its sibling holds one, so the scope is the narrowest that covers each intent, which is the rule `CODING_STANDARDS.md` states. No Act on fix touches that line.
6. [S5] **The skill count can no longer read zero.** Valid; `cmd_sync` has just copied the vendored skills when the line runs, so the count is never zero on the documented path, and an unmatched glob there would mean the copies failed, which `set -e` already aborts on. No Act on fix touches that line.

## Dismissed

Standards: 1 would break, 1 fail open, of 5; Spec: 0 would break, 1 fail open, of 1; judged: act on 4 (0 fixed, 0 with a ticket), ask 0, consider 0, noted 2, dismissed 0; fixed point ab47eb9.
round: 2 of 3
act-on items: 4

Claude Fable 5.1 on Claude Code
