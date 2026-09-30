## Would break

## Fails open

1. **The cached binary runs without a version or sha check.** The PATH binary is verified against the pin (`grep -qx "version: $version"`), but once `$dir/shellcheck-v$version/shellcheck` exists, `[ ! -x "$bin" ]` skips the download, the sha and any version check, and the gate still prints the pin. A binary that is not ShellCheck 0.11.0 at that path passes the gate silently; the author proved it by planting a two-line script there. One line, `"$bin" --version | grep -qx "version: $version"` after the `if`, refuses it loudly.

Documented step: `template/AGENTS.md:63` "Shell: `bash .github/shellcheck.sh` before a PR ... which is what CI runs", under P25 (`DECISIONS.md`), which says the file "holds the ShellCheck version, both release checksums and the flags" so a lane's run and CI's run "give the same answer".
Result: the two runs can use different binaries, and the line `ShellCheck 0.11.0` is printed either way.

```sh
  bin="$dir/shellcheck-v$version/shellcheck"
  if [ ! -x "$bin" ]; then
    mkdir -p "$dir"
    curl -fsSL -o "$dir/sc.tar.xz" ...
```

## Standards breaches

## Fix alongside

2. **A reason that cites a line number.** Three directives in `delegation.sh` name "(line 7)". The line moves the first time anything is inserted above `set -fuo pipefail`, and nothing checks it. Naming `set -f` alone carries the same intent.

```sh
  # shellcheck disable=SC2086 # set -f is on (line 7), so this splits words without globbing, which is the intent
```

3. **A doctor line that passes any version.** `PASS  shellcheck $scv` prints for every version, next to `chk "vp matches the ADR pin"`, which compares. A reader of the table takes PASS as "at the pin". Comparing `$scv` to the gate's `version=` would say what it means; the gate itself is unaffected, since it downloads the pin.

```sh
  if [ -n "$scv" ]; then echo "PASS  shellcheck $scv"
```

hard findings: 1
