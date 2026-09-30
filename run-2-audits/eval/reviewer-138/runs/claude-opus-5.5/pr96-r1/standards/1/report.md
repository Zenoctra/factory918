## Would break

## Fails open

1. **The gate splits a path on spaces and silently drops the pieces.** `CODING_STANDARDS.md`, Bash: "Quote every path. Paths here contain spaces." It also says: "Test a command the way a user types it: absolute paths, from another directory". `for f in $g` runs under the default IFS, so it both globs and word-splits. An argument such as `/…/Under The Sun Collective/…/hooks/x.sh` breaks into pieces. None of the pieces is a file, so `[ -f "$f" ]` drops each one without a message. Run from a directory whose path has a space:
   - A: an absolute path to a file with an SC2086 finding, passed alone, exits 1 with `no file matched <the path>; the gate checked nothing`. The file exists, so the message points the lane the wrong way.
   - B: a clean relative file plus the same absolute path prints `ShellCheck 0.11.0, files checked: 1` and exits 0. The file with the finding was never checked.

   The factory's clone and every lane worktree sit under a path with spaces, and lanes are told to use absolute paths. `tests/shellcheck/gate.sh` runs the gate from a directory with a space but passes only relative arguments, so it cannot catch this. Fix: set `IFS=` for the expansion loop, so `$g` is globbed but not split (checked: with `IFS=`, `"$PWD/.claude/hooks/*.sh"` under a spaced directory matches both files). Then add a gate.sh case that passes an absolute path containing a space.
   Documented step: `template/.agents/skills/poteto-mode/playbooks/opening-a-pr.md:9` "Run `bash .github/shellcheck.sh` on every shell file the diff changes before the PR opens"; ticket `## Design`: "`bash .github/shellcheck.sh '<glob>' ...` exactly these; quote a glob, the script expands it"
   Result: a changed file whose path holds a space is either refused as "no file matched" although it exists, or, beside any other argument that matches, skipped silently with exit 0.
   spec: design `shellcheck.sh [glob...]`

   ```
   +for g in "$@"; do
   +  for f in $g; do if [ -f "$f" ]; then files+=("$f"); fi; done
   +done
   +if [ "${#files[@]}" = 0 ]; then
   ```

2. **An argument that matches nothing is dropped silently when another one matches.** `CODING_STANDARDS.md`, Bash: "A failure a gate depends on is printed before anything continues." The refusal only fires when the whole set comes out empty. A mistyped path or a stale glob next to one that matches is left out with no message. Probe C: `bash shellcheck.sh .claude/hooks/good.sh .claude/hooks/bda.sh` prints `files checked: 1` and exits 0. The same thing applies to the factory's CI line. If a rename makes `'template/.agents/skills/*/scripts/*.sh'` match nothing, CI keeps passing on a smaller set, and nothing compares the printed count with the 20 that `AGENTS.md` states. Fix: count the matches for each explicit argument, and refuse the first one that matched nothing, naming it on stderr. This fits the refusal row the table already has. The zero-argument defaults can keep tolerating an empty glob, which the grounding relies on for a project with its hooks deleted.
   Documented step: ticket `## Design` table, row "A glob matches no file": "`shellcheck.sh: no file matched <globs>; the gate checked nothing` on stderr | 1 | fixes the glob; a gate that checked nothing is not a pass"
   Result: with one other argument matching, the unmatched glob or mistyped path exits 0 and prints nothing about it.
   spec: table A glob matches no file/Exit

   ```
   +  for f in $g; do if [ -f "$f" ]; then files+=("$f"); fi; done
   +done
   +if [ "${#files[@]}" = 0 ]; then
   +  echo "shellcheck.sh: no file matched $*; the gate checked nothing" >&2
   ```

## Standards breaches

3. **Two directive reasons misdescribe what they suppress.** `CODING_STANDARDS.md`, Bash: "A `# shellcheck disable=` directive carries its reason as a second comment on the same line". P25 makes the Standards axis the only check on that reason. In `review-brief.sh`, the file-level reason says every single-quoted string is "a jq program or a Markdown template". Two of the 16 SC2016 sites it covers are the awk programs `split=` (:115 without the directive) and `fenced=`. In `review-comment.sh`, the reason on `fenced=` says "the fenced block is Markdown emitted verbatim". `fenced` is an awk program whose backticks are regex characters that match Markdown fences, and it emits nothing. The suppressions themselves are right; the reasons should name awk.

   ```
   +# shellcheck disable=SC2016 # every single-quoted string here is a jq program or a Markdown template; the backticks and $ are literal
   ```
   ```
   +# shellcheck disable=SC2016 # the fenced block is Markdown emitted verbatim; the backticks are literal
    fenced='
      /^(```|~~~)/ { match($0, /^(`+|~+)/); m = substr($0, 1, RLENGTH); rest = substr($0, RLENGTH + 1)
   ```

## Fix alongside

4. **Test 6 says ShellCheck is hidden, but on CI it is not.** This is a Mysterious Name-type mismatch between the comment and the behavior. `PATH="$fx/bin:/usr/bin:/bin"` hides a Homebrew ShellCheck. On `ubuntu-latest`, though, the image's ShellCheck sits at `/usr/bin/shellcheck`, which the ticket describes as off-pin. So on CI the test exercises "off-pin, unpinned platform", not "absent, unpinned platform". The result is the same today. If the image ever ships 0.11.0 in `/usr/bin`, the test fails. A PATH made of only the fake `bin` plus a directory holding links to `bash`, `cat` and `grep` would make "hidden" true on both machines.

   ```
   +# build for is refused when no ShellCheck is on PATH (a fake uname on PATH, ShellCheck hidden).
   ...
   +PATH="$fx/bin:/usr/bin:/bin" run clean.sh
   ```

hard findings: 2
