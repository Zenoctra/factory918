## Would break

## Fails open

## Standards breaches

1. **A directive's reason misstates what the string is.** `CODING_STANDARDS.md`, Bash: "A `# shellcheck disable=` directive carries its reason as a second comment on the same line"; P25 makes the Standards axis the only check that the reason holds. The string under the directive in `template/.agents/skills/spec-review/scripts/review-comment.sh:40` is an awk program (`headings`, `items` and the step check at `:48`, `:50` and `:55` pass it to `awk`). It matches Markdown fences and prints nothing. The reason says it is "Markdown emitted verbatim", so a reader who checks the reason against the code finds it false. A reason that fits: the string is an awk program, so the backticks and `$0` belong to awk, not the shell.

```sh
# shellcheck disable=SC2016 # the fenced block is Markdown emitted verbatim; the backticks are literal
fenced='
  /^(```|~~~)/ { match($0, /^(`+|~+)/); m = substr($0, 1, RLENGTH); rest = substr($0, RLENGTH + 1)
```

2. **Counts in the new M0 entry have no command to regenerate them.** `CODING_STANDARDS.md`, Markdown: "A count or a version in prose is true at the commit that lands it, with the command that regenerates it nearby." The `docs/M0-findings.md` entry states "18 shell files", "57 findings", "6 findings at `warning`, 1 at `error`" and "the factory's gate checks 20 files", but gives no command. The `AGENTS.md` line that says "over 20 files" has its command inline, and that command gives `files checked: 20` at this commit. The M0 counts can only be reproduced by rebuilding the invocation from the prose.

```
At `ab47eb9` the 18 shell files the ticket names produced 57 findings at the default severity and 0 after five fixes and the directives; `tests/shellcheck/gate.sh` joins the set, so the factory's gate checks 20 files. ... (6 findings at `warning`, 1 at `error`)
```

## Fix alongside

3. **The doctor's PASS does not know the pin (Information leakage).** The doctor line passes any `shellcheck` on PATH and prints its version. The gate accepts only 0.11.0 and downloads a copy on the two pinned platforms. On a platform the gate does not pin (Intel macOS, Linux arm64), an off-pin Homebrew or apt install prints `PASS  shellcheck 0.x`, but the gate then refuses with "not pinned for Darwin.x86_64; install it by hand". The refusal is loud, so this is not a hard finding. The doctor and the gate still disagree about the same machine. The version is recorded in the gate only, so a doctor that compared versions would have to read it from there.

```sh
  local scv; scv="$(shellcheck --version 2>/dev/null | sed -n 's/^version: //p' || true)"
  if [ -n "$scv" ]; then echo "PASS  shellcheck $scv"
```

4. **The cached binary is trusted on later runs without a check.** `template/.github/shellcheck.sh:24-33` verifies the sha256 only when it downloads. On a later run, any executable at `${TMPDIR:-/tmp}/shellcheck-0.11.0/shellcheck-v0.11.0/shellcheck` is run without a checksum or version check. On Linux with `TMPDIR` unset, that path is under the shared `/tmp`. macOS and single-user CI runners are not exposed. Running `"$bin" --version | grep -qx "version: $version"` on the cached path before `exec`, or keeping the cache under `$HOME`, would close it.

```sh
  dir="${TMPDIR:-/tmp}/shellcheck-$version"
  bin="$dir/shellcheck-v$version/shellcheck"
  if [ ! -x "$bin" ]; then
```

hard findings: 0
