## Would break

1. **The gate splits a path on spaces and then refuses a file that exists.** `template/.github/shellcheck.sh:38` expands every argument with an unquoted `$g` so that a quoted glob expands. Word splitting runs on the value before pathname expansion, so an argument that is a path with a space (this repository lives under `Under The Sun Collective`) becomes four words, none a file, and the gate refuses it with the glob message. Run in a project-shaped copy at a path with a space: `bash .github/shellcheck.sh "$t/.claude/hooks/delegation.sh"` printed `shellcheck.sh: no file matched /var/.../with space/.claude/hooks/delegation.sh; the gate checked nothing`, exit 1. The refusal is loud but wrong: the file is there, and the message tells the lane to fix a glob that is correct. A glob such as `.claude/hooks/*.sh` is unaffected (its expansion is not re-split), so only a literal spaced path triggers it. Standard: `CODING_STANDARDS.md:8`, "Quote every path. Paths here contain spaces." and `:13`, "Test a command the way a user types it: absolute paths, from another directory, through the installed symlink." Setting `IFS=` (empty) for the loop keeps the glob and drops the split; a glob per argument is already the documented form.

```sh
for g in "$@"; do
  for f in $g; do if [ -f "$f" ]; then files+=("$f"); fi; done
done
if [ "${#files[@]}" = 0 ]; then
  echo "shellcheck.sh: no file matched $*; the gate checked nothing" >&2
  exit 1
fi
```

Documented step: `CODING_STANDARDS.md:13` "Test a command the way a user types it: absolute paths, from another directory, through the installed symlink." and the ticket's Design usage line, `bash .github/shellcheck.sh .claude/hooks/mode.sh  a lane before the PR opens, on every shell file the diff changes`.
Result: an absolute path with a space is refused as "no file matched"; the lane is sent to fix a glob that is right, and the file goes unchecked.
spec: design `bash .github/shellcheck.sh '<glob>' ...           exactly these; quote a glob, the script expands it`

2. **The checksum's OK line lands on the gate's stdout, so the gate's test fails on a cold machine.** `template/.github/shellcheck.sh:29-30` pipes into `sha256sum -c -` or `shasum -a 256 -c -`, and both print `<path>/sc.tar.xz: OK` on stdout (shown here with `shasum` on a local file: stdout `f: OK`). The design's download row says the gate prints "one of the rows above", that is, the count line only; on the first run the count line is preceded by the OK line. `tests/shellcheck/gate.sh:66` compares stdout exactly, so on a machine whose `shellcheck` on PATH is absent or off the pin and whose `${TMPDIR:-/tmp}/shellcheck-0.11.0` is cold, `bash tests/shellcheck/gate.sh` run on its own downloads inside check 1 and reports `FAIL 1 a clean file` against a gate that works; the header at `:8` says the download is not exercised there. CI does not see it because the "ShellCheck" step warms the cache before the test, and this machine has the pin on PATH; a fresh Linux x86_64 or macOS arm64 checkout that runs the test first does. Standard: `CODING_STANDARDS.md:13`, "Test a command the way a user types it", and the design table's Prints column. Redirecting the verdict to stderr (`| sha256sum -c - >&2`) keeps stdout to the contract; `--status` loses the OK line a person wants to see.

```sh
    if command -v sha256sum >/dev/null; then echo "$sha  $dir/sc.tar.xz" | sha256sum -c -
    else echo "$sha  $dir/sc.tar.xz" | shasum -a 256 -c -; fi
```

Documented step: `AGENTS.md:39` "`bash tests/shellcheck/gate.sh`." and `tests/shellcheck/gate.sh:8` "The download is not exercised here; the fixture job in factory-ci.yml proves it."
Result: on a machine without the pin and with a cold cache, the test's first check gets `<tmp>/shellcheck-0.11.0/sc.tar.xz: OK` ahead of `ShellCheck 0.11.0, files checked: 1` and fails, so the test reports a defect the gate does not have.
spec: design table `Local ShellCheck absent or off-pin, platform pinned`/`Prints`

## Fails open

## Standards breaches

## Fix alongside

3. **Judgement call: the doctor says PASS for a ShellCheck the gate will not use.** `factory918.sh:274-276` prints `PASS  shellcheck <version>` for any version on PATH; an off-pin build (the Ubuntu image's, a brew upgrade) passes the doctor while the gate downloads the pin around it. The `vp` line four checks up compares against its pin. Ticket criterion 4 asks only for a line, a fix and NOTE without the tool, so this counts for nothing; if it is touched, print the pin next to the found version or NOTE when they differ.

```sh
  local scv; scv="$(shellcheck --version 2>/dev/null | sed -n 's/^version: //p' || true)"
  if [ -n "$scv" ]; then echo "PASS  shellcheck $scv"
```

4. **Judgement call: check 6 hides ShellCheck by trimming PATH, which does not hide `/usr/bin`.** `tests/shellcheck/gate.sh:75` relies on the pinned binary living outside `/usr/bin:/bin`. Homebrew's does; a distro package's is `/usr/bin/shellcheck`, and on the day an image or an apt install carries 0.11.0 there, the gate takes the on-PATH branch, never reaches the fake `uname`, and check 6 fails with exit 0. A `shellcheck` stub in `$fx/bin` that exits 127 hides it on every machine.

```sh
PATH="$fx/bin:/usr/bin:/bin" run clean.sh
same "6 an unpinned platform without ShellCheck is refused" 1 "$code"
```

5. **A line number inside a directive's reason.** `template/.claude/hooks/delegation.sh:165`, `:186` and `:209` say "set -f is on (line 7)". It is true at this commit (`set -fuo pipefail` is line 7), and it stops being true the next time the header gains a line, with nothing to catch it. Naming the statement (`set -fuo pipefail` in the header) says the same thing and does not age.

```sh
  # shellcheck disable=SC2086 # set -f is on (line 7), so this splits words without globbing, which is the intent
  set -- $args
```

6. **Duplicated Code: two of the three `rm -rf` on `$skills` state the invariant, the third does not.** `factory918.sh:388` and `:390` now read `"${skills:?}/$n"`; `:391` still reads `"$skills/spec-review"`. ShellCheck flags only the first form, which is why the third was left, but a reader now has to work out why the guard covers two lines and not the one between them. Either all three or, since the blast radius shows `$skills` cannot be empty, a one-line comment saying the guard is ShellCheck's asking.

```sh
  rm -rf "$skills/spec-review"; cp -R "$matt/engineering/code-review" "$skills/spec-review"
```

hard findings: 2
