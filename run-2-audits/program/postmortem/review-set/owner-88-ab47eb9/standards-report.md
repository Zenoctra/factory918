## Would break

## Fails open

## Standards breaches

1. **The blast-radius grounding no longer describes the code it grounds.** `CODING_STANDARDS.md`, Markdown: "A count or a version in prose is true at the commit that lands it." Risk 1 of the PR body cites a cache test at `template/.github/shellcheck.sh:26` that skips the sha; commits `a64c7e6` and `1362b48` replaced it, and the shipped gate verifies the tarball on every run. The Cleared line "with the hooks deleted, 6" is falsified by `01e5386`: an unmatched glob is now refused, so that case exits 1, not 6. Both are the evidence the next round's reviewers are handed.

```sh
  [ -f "$tarball" ] || curl -fsSL -o "$tarball" "https://github.com/koalaman/shellcheck/releases/download/v$version/shellcheck-v$version.$plat.tar.xz"
  if command -v sha256sum >/dev/null; then echo "$sha  $tarball" | sha256sum -c - >/dev/null
```

## Fix alongside

2. **Speculative Generality: a file-wide SC2016 on a 362-line production script.** The new rule asks for "the narrowest scope that covers the intent, above the one statement or at the top of a file whose whole job produces the pattern". `review-brief.sh` emits Markdown and jq, but not only; the sibling `review-comment.sh` got statement-scoped directives instead. A future genuine `'...$var...'` in a non-template string goes unreported.

```sh
# shellcheck disable=SC2016 # every single-quoted string here is a jq program or a Markdown template; the backticks and $ are literal
set -euo pipefail
```

3. **The doctor passes any ShellCheck, not the pin.** `factory918.sh` prints `PASS  shellcheck 0.9.0` for a version the gate then ignores and re-downloads. Harmless, since the gate carries the pin, but the line reads as "this machine matches" when it does not. Compare the pinned string the gate itself greps, `version: $version`.

```sh
  if [ -n "$scv" ]; then echo "PASS  shellcheck $scv"
```

4. **A commit title names the wrong stream.** `1362b48`, "Keep the checksum tool's OK line off the gate's stderr": `>/dev/null` at `template/.github/shellcheck.sh:31-32` redirects stdout, which is where `-: OK` lands and the stream `tests/shellcheck/gate.sh` compares exactly. The failure warning stays on stderr, which is why test 9 still sees `did NOT match`.

```sh
  if command -v sha256sum >/dev/null; then echo "$sha  $tarball" | sha256sum -c - >/dev/null
  else echo "$sha  $tarball" | shasum -a 256 -c - >/dev/null; fi
```

hard findings: 0
