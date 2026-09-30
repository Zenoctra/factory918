## Would break

## Fails open

1. **The gate splits a path on spaces and silently drops the pieces, so a named file with a space in its path goes unchecked and the gate exits 0.** `CODING_STANDARDS.md`, Bash: "Quote every path. Paths here contain spaces." `$g` is expanded unquoted so it will glob, but with the default `IFS` it is also word-split. Every piece that is not a file is then filtered out by `[ -f "$f" ]` with no message. The refusal only fires when *no* argument yields a file, so a file dropped beside any file that matches passes silently. This repository lives under `.../Under The Sun Collective/...`, and lanes here are told to use absolute paths, so the absolute form of a changed file is the realistic input. Reproduced at this tree with ShellCheck 0.11.0 on PATH: a file holding `cat $1` (SC2086) at `$TMP/with space/bad.sh`, run as `bash .github/shellcheck.sh factory918.sh "$TMP/with space/bad.sh"`, prints `ShellCheck 0.11.0, files checked: 1` and exits 0. Alone, the same path is refused with `no file matched <path>`, which names a file that exists. The same `[ -f ]` filter also drops a mistyped name beside a good one (`factory918.sh nosuch.sh` gives `files checked: 1`, exit 0). `tests/shellcheck/gate.sh` passes only relative arguments from inside the fixture directory, so it never runs the gate the way the other Bash rule asks ("Test a command the way a user types it: absolute paths, from another directory"), and this case went untested. Setting `IFS=` around the inner loop keeps the glob and stops the split. Refusing any single argument that matches nothing would close the typo case.
Documented step: `template/.agents/skills/poteto-mode/playbooks/opening-a-pr.md:9` "Run `bash .github/shellcheck.sh` on every shell file the diff changes before the PR opens"
Result: a changed shell file whose path contains a space (any absolute path in this repository) is not checked, and the gate prints a count and exits 0, so the finding reaches CI or review, the exact cost the gate exists to remove.
spec: design shellcheck.sh [glob...]

```sh
for g in "$@"; do
  for f in $g; do if [ -f "$f" ]; then files+=("$f"); fi; done
done
if [ "${#files[@]}" = 0 ]; then
```

## Standards breaches

2. **A disable directive's reason describes the wrong thing.** `CODING_STANDARDS.md`, Bash: a `# shellcheck disable=` directive "carries its reason." The reason says the string is Markdown emitted verbatim. `fenced` is an awk program fragment that *matches* Markdown fence lines, and it is spliced into `awk` calls (`headings`, `items`, and the step check). It is never emitted. A reader auditing the suppression is told something false about what the string is for. Something like "an awk program; the backticks are fence characters it matches, not command substitution" would be accurate.

```sh
# shellcheck disable=SC2016 # the fenced block is Markdown emitted verbatim; the backticks are literal
fenced='
```

3. **The count in the findings line does not add up the way the sentence says.** `CODING_STANDARDS.md`, Markdown: "A count or a version in prose is true at the commit that lands it." 20 is the true total, but the sentence gives 18 plus `gate.sh` joining, which makes 19. The 20th file is `template/.github/shellcheck.sh` itself, which the sentence does not name.

```
At `ab47eb9` the 18 shell files the ticket names produced 57 findings ... `tests/shellcheck/gate.sh` joins the set, so the factory's gate checks 20 files.
```

## Fix alongside

4. **Speculative breadth in a suppression: the file-level SC2016 in `review-brief.sh`.** The standard allows the file top only for "a file whose whole job produces the pattern". Without the directive there are 16 hits over about 10 statements in a 362-line file (lines 93, 115, 119, 225, 239, 242, 316-321, 344-349). Most of the file is argument parsing, git and control flow, and a future unintended SC2016 anywhere in it is now silenced. This is a judgement call. Per-statement directives, or one each above the two template blocks at 316 and 344, would keep the scope narrow.

```sh
# shellcheck disable=SC2016 # every single-quoted string here is a jq program or a Markdown template; the backticks and $ are literal
set -euo pipefail
```

5. **The cached binary is trusted on sight, and runs share one cache path.** After the first download, `[ ! -x "$bin" ]` skips both the download and the sha256 check, so whatever sits at `${TMPDIR:-/tmp}/shellcheck-0.11.0/shellcheck-v0.11.0/shellcheck` runs unverified. On Linux with `TMPDIR` unset, that path is in the world-writable `/tmp`. Parallel lanes that download at once also write the same `sc.tar.xz`. A clash there fails loudly, not silently. This is noted for the Spec axis, since the ticket's design text owns the download behavior.

```sh
  if [ ! -x "$bin" ]; then
    mkdir -p "$dir"
    curl -fsSL -o "$dir/sc.tar.xz" ...
```

6. **The doctor prints PASS for any ShellCheck version.** `PASS  shellcheck 0.9.0` appears on a machine where the gate will ignore that binary and download the pin. The line is informational and the gate still works, so this is only a wording mismatch between the doctor and the gate.

```sh
  local scv; scv="$(shellcheck --version 2>/dev/null | sed -n 's/^version: //p' || true)"
  if [ -n "$scv" ]; then echo "PASS  shellcheck $scv"
```

hard findings: 1
