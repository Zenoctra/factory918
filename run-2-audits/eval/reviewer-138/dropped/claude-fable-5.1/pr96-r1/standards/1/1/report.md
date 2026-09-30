## Would break

## Fails open

1. **An argument that matches no file is dropped without a word when another argument matches.** `template/.github/shellcheck.sh` expands every argument through one unquoted `for f in $g` and then filters with `[ -f "$f" ]`; the only refusal is the all-empty check on `files`. So a lane that misspells one of the changed files, or names a glob that matches nothing beside one that does, gets a count line and exit 0. The gate's own header promises the refusal only for "globs that match no file at all". Run at the reviewed commit, from a directory holding `a.sh`: `bash template/.github/shellcheck.sh a.sh typo.sh` prints `ShellCheck 0.11.0, files checked: 1`, exit 0; `bash template/.github/shellcheck.sh a.sh 'nope/*.sh'` prints the same, exit 0. Standard: `CODING_STANDARDS.md`, Bash, "A failure a gate depends on is printed before anything continues", and the report rule "an input outside the documented path that proceeds silently fails open". The ticket's `## Design` amendment already names this ("a glob that matches no file is refused even beside globs that match"); the reviewed commit does not implement it.
Documented step: `template/.agents/skills/poteto-mode/playbooks/opening-a-pr.md:9`, "Run `bash .github/shellcheck.sh` on every shell file the diff changes before the PR opens; it is the gate CI runs".
Result: the misspelt or unmatched file is never checked, the count says one fewer than asked, the exit is 0, and the lane opens the PR believing the gate ran over its diff.
spec: table "A glob matches no file"/Exit

```
+files=()
+for g in "$@"; do
+  for f in $g; do if [ -f "$f" ]; then files+=("$f"); fi; done
+done
+if [ "${#files[@]}" = 0 ]; then
+  echo "shellcheck.sh: no file matched $*; the gate checked nothing" >&2
+  exit 1
+fi
```

2. **A quoted path with a space is split into two words the script then treats as two paths.** The same `for f in $g` runs word splitting before globbing, so the quoting the caller did is undone inside the gate. `bash template/.github/shellcheck.sh a.sh "my dir/b c.sh"` and `bash template/.github/shellcheck.sh a.sh "my dir/*.sh"` each print `files checked: 1`, exit 0: `my`, `dir/b`, `c.sh` and `dir/*.sh` match nothing and are dropped by item 1. Alone, the spaced argument is refused with `no file matched my dir/b c.sh`, a message that reads as if the path had been looked up whole. Standard: `CODING_STANDARDS.md`, Bash, "Quote every path. Paths here contain spaces." The header's "quote a glob, this script expands it" describes the intent; the expansion chosen (`$IFS` splitting, then globbing) is the one the standard forbids. A per-argument expansion (`compgen -G`, or `set -- $g` under `set -f` with `IFS=` cleared, or a `case "$g" in *[*?[]*)` split between literal paths and globs) keeps the argument whole.
Documented step: `template/.agents/skills/poteto-mode/playbooks/opening-a-pr.md:9`, "Run `bash .github/shellcheck.sh` on every shell file the diff changes before the PR opens".
Result: a file whose path holds a space is silently skipped when any other argument matches, and refused under a misleading message when it is the only argument.
spec: design `shellcheck.sh [glob...]`

```
+#   bash .github/shellcheck.sh '<glob>' ...     exactly these; quote a glob, this script expands it
...
+for g in "$@"; do
+  for f in $g; do if [ -f "$f" ]; then files+=("$f"); fi; done
+done
```

3. **Any executable already at the cache path runs as ShellCheck, with no checksum.** The download branch is guarded by `[ ! -x "$bin" ]` on `${TMPDIR:-/tmp}/shellcheck-0.11.0/shellcheck-v0.11.0/shellcheck`, and the sha256 is checked only on the tarball inside that branch. A file that is already there, planted, left by a truncated `tar` run, or written by anyone with access to `/tmp`, is executed with the project's files as arguments and its exit code becomes the gate's. Run at the reviewed commit with a two-line `#!/bin/sh` script at that path and ShellCheck hidden from `PATH`, over a file holding a real SC2086: `ShellCheck 0.11.0, files checked: 1`, `FOREIGN BINARY RAN with: --external-sources bad.sh`, exit 0. Standard: `CODING_STANDARDS.md`, Bash, "A failure a gate depends on is printed before anything continues"; `docs/knowledge/core/DECISIONS.md` P2, "Pin every tool CI runs to an exact version", which the checksum is the whole of here. The ticket's `## Design` amendment already names the fix ("its sha256 is verified and the binary extracted from it on every run that does not use the ShellCheck on PATH, so a foreign binary at the cache path never runs"); the reviewed commit does not implement it.
Documented step: `template/.github/workflows/ci.yml:17-18`, the `ShellCheck` step `bash .github/shellcheck.sh`, and `template/.agents/skills/poteto-mode/playbooks/opening-a-pr.md:9`.
Result: whatever sits at the cache path decides the gate; on a shared machine or a reused runner the pin is not what ran, and a green gate proves nothing about the shell files.
spec: design `shellcheck.sh [glob...]`

```
+  dir="${TMPDIR:-/tmp}/shellcheck-$version"
+  bin="$dir/shellcheck-v$version/shellcheck"
+  if [ ! -x "$bin" ]; then
+    mkdir -p "$dir"
+    curl -fsSL -o "$dir/sc.tar.xz" "https://github.com/koalaman/shellcheck/releases/download/v$version/shellcheck-v$version.$plat.tar.xz"
+    if command -v sha256sum >/dev/null; then echo "$sha  $dir/sc.tar.xz" | sha256sum -c -
+    else echo "$sha  $dir/sc.tar.xz" | shasum -a 256 -c -; fi
+    tar -xJf "$dir/sc.tar.xz" -C "$dir"
+  fi
+fi
```

## Standards breaches

## Fix alongside

4. **Speculative Generality in reverse: the test's "ShellCheck hidden" is a `PATH` prefix, not a hidden ShellCheck.** Check 6 in `tests/shellcheck/gate.sh` sets `PATH="$fx/bin:/usr/bin:/bin"` and relies on neither `/usr/bin` nor `/bin` carrying ShellCheck at the pin. On this machine the pin is under `/opt/homebrew/bin`, so it holds; on `ubuntu-latest` it holds only while the image's `/usr/bin/shellcheck` stays off-pin, which the ticket asserts and nothing checks. The day the image ships 0.11.0, check 6 reports `exit 0` against `1`, and the download row the fixture job is said to prove stops being exercised too. A fake `shellcheck` in `$fx/bin` printing `version: 0.0.0` hides the real one on every machine and costs three lines.

```
+PATH="$fx/bin:/usr/bin:/bin" run clean.sh
+same "6 an unpinned platform without ShellCheck is refused" 1 "$code"
```

5. **Information leakage: the doctor reports `PASS` for any ShellCheck, while the pin lives one file away.** `cmd_doctor` prints `PASS  shellcheck 0.10.0` on a machine whose ShellCheck the gate will not use (the gate downloads the pin instead). The ticket asks only for presence, so this is not a breach, but the line tells the user something the gate contradicts a minute later. Reading `version=` from `.github/shellcheck.sh` and printing `PASS  shellcheck 0.11.0 (the pin)` or `NOTE  shellcheck 0.10.0 is off the pin 0.11.0; the gate downloads the pin` keeps one source for the number.

```
+  local scv; scv="$(shellcheck --version 2>/dev/null | sed -n 's/^version: //p' || true)"
+  if [ -n "$scv" ]; then echo "PASS  shellcheck $scv"
+  else note "shellcheck" "brew install shellcheck (apt install shellcheck, dnf install ShellCheck, winget install koalaman.shellcheck); .github/shellcheck.sh downloads the pinned build without it, so this is a NOTE"; fi
```

Checked and clean, for the record: the 57, 6 and 1 counts in `docs/M0-findings.md` reproduce at `ab47eb9` (18 files, `-x`, default, `-S warning`, `-S error`); the factory gate at the reviewed commit checks 20 files and exits 0, as `AGENTS.md` says; every `disable=` directive in the diff carries its reason as a second comment on the same line and sits on the statement or, where the whole file produces the pattern, at its top; `cmd_doctor`'s NOTE carries its fix; the `|| true` on the doctor's version read turns absence into a NOTE, not silence; `sha256sum` and `shasum` are branched on `command -v`; the symlink at `.github/shellcheck.sh` is outside `template/`, so `apply` never copies it; `cmd_update` adds `.github/shellcheck.sh` to an existing project through `write_bytes`, without the mode bit, which does not matter because every caller runs it through `bash`.

hard findings: 3
