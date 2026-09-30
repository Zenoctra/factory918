## Would break

## Fails open

## Standards breaches

1. **Two directive reasons misname the awk fence parser they cover.** `CODING_STANDARDS.md`, Bash: "A `# shellcheck disable=` directive carries its reason as a second comment on the same line", and P25 makes the Standards axis the check that the reason is there. A reason that names the wrong thing does not do that job. In `review-comment.sh` the directive sits above `fenced='...'`, which is the awk program that finds fenced blocks. It is not "Markdown emitted verbatim". The backticks are literal characters in awk regexes, and `$0` is awk's record. In `review-brief.sh` the file-level reason says "every single-quoted string here is a jq program or a Markdown template". Running ShellCheck with the directive removed reports SC2016 at lines 116 and 120 of that file. Those lines are `split='...'` and `fenced='...'`, which are awk programs, so the claim is false for two of the sixteen strings the directive covers. Behavior is unchanged, because SC2016 is suppressed correctly either way. Only the stated reason is wrong.

```sh
# template/.agents/skills/spec-review/scripts/review-comment.sh:40
# shellcheck disable=SC2016 # the fenced block is Markdown emitted verbatim; the backticks are literal
fenced='
  /^(```|~~~)/ { match($0, /^(`+|~+)/); m = substr($0, 1, RLENGTH); rest = substr($0, RLENGTH + 1)
```

```sh
# template/.agents/skills/spec-review/scripts/review-brief.sh:17
# shellcheck disable=SC2016 # every single-quoted string here is a jq program or a Markdown template; the backticks and $ are literal
```

## Fix alongside

2. **Gate test case 6 says ShellCheck is hidden, but on the CI runner it is not.** The header says "ShellCheck hidden", yet the run puts `/usr/bin` on PATH. The `ubuntu-latest` image installs its own ShellCheck there, and the ticket's Design says that one is off-pin. So on CI the case reaches the fake `uname` only because the system copy is not 0.11.0. If an image ever ships the pinned version in `/usr/bin`, the gate exits 0 and the case fails loudly. That failure is not silent, but the test's precondition is stated as something it does not set up. PATH should be built from the tools the gate needs, without `/usr/bin`'s ShellCheck, or the header should name the real precondition.

```sh
# tests/shellcheck/gate.sh:75
PATH="$fx/bin:/usr/bin:/bin" run clean.sh
same "6 an unpinned platform without ShellCheck is refused" 1 "$code"
```

3. **Three directive reasons cite `set -f` by line number.** The three SC2086 reasons in `delegation.sh` say "set -f is on (line 7)". This is true at this commit. But an edit above line 7 makes all three stale, and neither the gate nor the hook test would notice. Naming the statement instead (`set -fuo pipefail` at the top) keeps the reason true when lines move.

```sh
# template/.claude/hooks/delegation.sh:165, :186, :209
  # shellcheck disable=SC2086 # set -f is on (line 7), so this splits words without globbing, which is the intent
```

4. **The doctor's NOTE promises a download that some platforms do not get.** The fix text says `.github/shellcheck.sh` downloads the pinned build when ShellCheck is missing. The gate downloads only for Linux x86_64 and macOS arm64. On an Intel Mac or on Linux arm64 it refuses with "install it by hand". There, the NOTE's reason for being a NOTE rather than a FAIL is false. The refusal itself is loud, so the user is not misled for long. Separately, `PASS  shellcheck <version>` prints for any version, including an off-pin one that the gate ignores.

```sh
# factory918.sh:274-276
  local scv; scv="$(shellcheck --version 2>/dev/null | sed -n 's/^version: //p' || true)"
  if [ -n "$scv" ]; then echo "PASS  shellcheck $scv"
  else note "shellcheck" "brew install shellcheck (apt install shellcheck, dnf install ShellCheck, winget install koalaman.shellcheck); .github/shellcheck.sh downloads the pinned build without it, so this is a NOTE"; fi
```

hard findings: 0
