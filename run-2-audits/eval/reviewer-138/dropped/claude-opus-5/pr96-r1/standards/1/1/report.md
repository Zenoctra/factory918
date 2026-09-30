## Would break

## Fails open

1. **An argument whose path holds a space is split, dropped, and the gate still passes.** `for f in $g` is unquoted, so every argument is word-split before it is globbed. Glob *results* are not re-split, so the zero-argument form is safe (a hook named `my hook.sh` is checked); an *argument* that holds a space is not. Passing one such path beside one that matches drops it silently and exits 0. The ticket's Design amendment of 2026-09-22 already names this ("An argument is one path or one glob and is never split on a space"), so if this is a later round it is a carry-forward, not a new finding.
Documented step: `template/AGENTS.md:63`, "Shell: `bash .github/shellcheck.sh` before a PR, on the files the diff changes"; the standard breached is `CODING_STANDARDS.md`, Bash, "Quote every path. Paths here contain spaces." — the rule the gate's own fixture root honours (`tests/shellcheck/gate.sh:15`, `fx="$tmp/with space"`).
Result: run in a tree holding `my dir/bad.sh` (a planted SC2086) and a clean `clean.sh`, `bash shellcheck.sh "my dir/bad.sh" clean.sh` prints `ShellCheck 0.11.0, files checked: 1` and exits 0. The lane reads a pass for a file the gate never opened. Alone, the same argument is refused (`no file matched my dir/bad.sh`), so the failure is visible only when nothing else matches.
spec: design shellcheck.sh [glob...]

```
if [ "$#" = 0 ]; then set -- '.claude/hooks/*.sh' '.agents/skills/*/scripts/*.sh' '.github/shellcheck.sh'; fi
files=()
for g in "$@"; do
  for f in $g; do if [ -f "$f" ]; then files+=("$f"); fi; done
done
```

2. **A glob that names nothing is refused only when every glob names nothing.** The emptiness test is on the aggregate `files` array, not per argument, so one dead glob beside one live glob is a silent pass. This matters for the factory's own gate, whose CI step names five globs (`.github/workflows/factory-ci.yml:19`): rename `tests/` or move `template/.claude/hooks/`, and CI goes green having stopped checking that set, with `files checked:` the only clue and no baseline to compare it against. The Design amendment of 2026-09-22 names this too ("a glob that matches no file is refused even beside globs that match").
Documented step: `template/.github/shellcheck.sh:10-11`, "Globs that match no file at all leave the gate checking nothing, which is a failure, not a pass"; the standard breached is `CODING_STANDARDS.md`, Bash, "A failure a gate depends on is printed before anything continues."
Result: `bash .github/shellcheck.sh 'template/.claude/hooks/*.sh' 'tests/gone/*.sh'` prints `ShellCheck 0.11.0, files checked: 5` and exits 0, with nothing on stderr. `tests/shellcheck/gate.sh:68` asserts only the single-glob case, so the test agrees with the code and the gap is invisible.
spec: table "A glob matches no file"/"Exit"

```
if [ "${#files[@]}" = 0 ]; then
  echo "shellcheck.sh: no file matched $*; the gate checked nothing" >&2
  exit 1
fi
```

3. **Any executable already at the cache path runs unverified, under the pin's name.** `[ ! -x "$bin" ]` gates the download, the checksum and the extraction together, so a file that is already there is neither checksummed nor asked its version. The cache path is `${TMPDIR:-/tmp}/shellcheck-0.11.0/...`, and TMPDIR is unset on a Linux runner, so on CI it sits under world-writable `/tmp` and survives between jobs on a self-hosted runner or a shared dev box. The Design amendment of 2026-09-22 names this as well ("its sha256 is verified and the binary extracted from it on every run that does not use the ShellCheck on PATH, so a foreign binary at the cache path never runs").
Documented step: `template/.github/shellcheck.sh:2-4`, "Runs ShellCheck at the pinned version over the files the globs name, downloading that version when this machine does not have it, so the run a lane makes before a PR and the run CI makes are one run"; the standard breached is `docs/knowledge/core/DECISIONS.md` P25, "`template/.github/shellcheck.sh` holds the ShellCheck version, both release checksums and the flags ... so a lane's per-file run and CI's whole-set run give the same answer."
Result: with a stub shell script planted at `$TMPDIR/shellcheck-0.11.0/shellcheck-v0.11.0/shellcheck` and no ShellCheck on PATH, the gate printed `ShellCheck 0.11.0, files checked: 1`, ran the stub (`I am not ShellCheck. args: --external-sources bad.sh`) and exited 0 over a file holding SC2086. No network call, no checksum, no version check; the pin's guarantee is gone and the line above it claims the pin.
spec: design shellcheck.sh [glob...]

```
  dir="${TMPDIR:-/tmp}/shellcheck-$version"
  bin="$dir/shellcheck-v$version/shellcheck"
  if [ ! -x "$bin" ]; then
    mkdir -p "$dir"
    curl -fsSL -o "$dir/sc.tar.xz" "https://github.com/koalaman/shellcheck/releases/download/v$version/shellcheck-v$version.$plat.tar.xz"
    if command -v sha256sum >/dev/null; then echo "$sha  $dir/sc.tar.xz" | sha256sum -c -
    else echo "$sha  $dir/sc.tar.xz" | shasum -a 256 -c -; fi
    tar -xJf "$dir/sc.tar.xz" -C "$dir"
  fi
```

## Standards breaches

## Fix alongside

4. **Divergent Change: the doctor's new line PASSes any version, where its neighbour compares against the pin.** `chk "vp matches the ADR pin"` (`factory918.sh:251`) exists because a tool that is present but off-pin is the interesting case; the shellcheck line reports presence only, so `PASS  shellcheck 0.9.0` reads as agreement with a pin it does not meet. The gate handles an off-pin binary by downloading the pin, so nothing breaks; the table just tells a person less than the one above it. Acceptance criterion 4 asks only for a line, a fix and NOTE-not-FAIL, all of which are there.

```
  local scv; scv="$(shellcheck --version 2>/dev/null | sed -n 's/^version: //p' || true)"
  if [ -n "$scv" ]; then echo "PASS  shellcheck $scv"
```

5. **`tests/shellcheck/gate.sh` lands at mode 644 while the tests beside it are 755.** `tests/hooks/delegation.sh`, `tests/spec-review/review-brief.sh`, `review-comment.sh`, `fake-gh.sh` and `no-stale-wording.sh` are executable; the new test is not, in a change whose seventh assertion is the mode bit of the script it tests. Everything invokes it as `bash tests/shellcheck/gate.sh`, so nothing fails.

```
new file mode 100644
--- /dev/null
+++ b/tests/shellcheck/gate.sh
```

6. **The `template/AGENTS.md` sentence undercounts the default set.** "with no arguments it checks the project's hooks and skill scripts" leaves out `.github/shellcheck.sh`, which the default set names and which `tests/shellcheck/gate.sh:73` counts (4 files = two hooks, one skill script, the gate). A reader who checks the count against the sentence gets a mismatch of one.

```
+- Shell: `bash .github/shellcheck.sh` before a PR, on the files the diff changes; with no arguments it checks the project's hooks and skill scripts, which is what CI runs.
```

hard findings: 3
