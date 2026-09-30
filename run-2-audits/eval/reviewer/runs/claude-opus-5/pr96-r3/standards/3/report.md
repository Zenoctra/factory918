## Would break

## Fails open

## Standards breaches

## Fix alongside

1. **The three SC2086 reasons cite a line number.** `template/.claude/hooks/delegation.sh` gains the same reason three times, each naming `line 7`. `set -fuo pipefail` is on line 7 today; one inserted line above it and all three reasons are false, with nothing to catch it. The reason is the part a reader trusts. Name the flag, not its address: "`set -f` is on (file header)". Duplicated Code, three copies of one sentence.

```sh
  # shellcheck disable=SC2086 # set -f is on (line 7), so this splits words without globbing, which is the intent
  set -- $args
```

2. **The doctor's shellcheck line passes any version.** Its sibling one line up in the same function compares `vp --version` against the ADR pin and fails when they differ; this one prints PASS for 0.10.0, which is exactly the version the gate then ignores and re-downloads. The line reads as "this machine matches" when it means "some shellcheck is here". Either say so in the label (`PASS  shellcheck 0.10.0 (gate downloads 0.11.0)`) or compare against the pin. Not a breach: `.github/shellcheck.sh` does the real check, so nothing silently runs off-pin.

```sh
  local scv; scv="$(shellcheck --version 2>/dev/null | sed -n 's/^version: //p' || true)"
  if [ -n "$scv" ]; then echo "PASS  shellcheck $scv"
```

3. **Two tests prefix a shell function with an assignment.** `tests/shellcheck/gate.sh` sets `PATH` and `TMPDIR` on a call to `run` and to `check_err`, both functions. Bash keeps such an assignment after a function returns in POSIX mode and drops it otherwise, so tests 7, 8 and 8b depend on the shell not being in POSIX mode; run under `sh` or `set -o posix`, they would silently be checking the download path instead. Set the variables inside a subshell (`( export PATH=...; run ... )`) or save and restore them.

```sh
PATH="$fx/bin:/usr/bin:/bin" run clean.sh
...
    PATH=/usr/bin:/bin TMPDIR="$fx/tmp" check_err "9 a cached tarball that fails its checksum is refused" 1 "did NOT match" clean.sh
```

Checked and clean: every added `disable=` carries its reason as a second comment on the same line, and the two file-level ones sit above the first command of files whose job is emitting Markdown; `sha256sum`/`shasum` branches on `command -v`; the two `rm -rf` guards and the `dirs` array preserve behavior; P25 is under Provisional, the tool facts are dated in `M0-findings.md`, the surprise is in the ledger.

hard findings: 0
