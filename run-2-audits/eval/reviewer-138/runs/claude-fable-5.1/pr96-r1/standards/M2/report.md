## Would break

## Fails open

1. **A glob that matches nothing is dropped silently when another glob matches.** The gate refuses only when every glob together matches no file; one empty glob beside a full one is skipped, the count line shrinks and the exit is 0. A typo in one of the five globs the factory's CI step passes (`.github/workflows/factory-ci.yml:19`), or a hooks directory that moves, leaves that whole class unchecked with a green step, and nothing in CI compares the printed count to the 20 that `AGENTS.md:38` states. Verified in this tree: `bash .github/shellcheck.sh factory918.sh 'template/.claude/hook/*.sh'` prints `ShellCheck 0.11.0, files checked: 1` and exits 0. Standard: `CODING_STANDARDS.md`, Bash, "A failure a gate depends on is printed before anything continues ... never hide it." The script's own header narrows the rule to "Globs that match no file at all", and the refusal text says "the gate checked nothing", so the author designed the all-empty case on purpose; the ticket's table row is written per glob, and the per-glob case is the one a typo produces.
Documented step: ticket `## Design` table, row "A glob matches no file": prints `shellcheck.sh: no file matched <globs>; the gate checked nothing`, exit 1, "fixes the glob; a gate that checked nothing is not a pass".
Result: the empty glob is dropped, the other files are checked, exit 0; the caller proceeds with fewer files gated than the command names.
spec: table "A glob matches no file"/Exit

```
if [ "$#" = 0 ]; then set -- '.claude/hooks/*.sh' '.agents/skills/*/scripts/*.sh' '.github/shellcheck.sh'; fi
files=()
IFS=  # an argument is one path or one glob, never split on the spaces in it
for g in "$@"; do
  for f in $g; do if [ -f "$f" ]; then files+=("$f"); fi; done
done
if [ "${#files[@]}" = 0 ]; then
  echo "shellcheck.sh: no file matched $*; the gate checked nothing" >&2
  exit 1
fi
```

## Standards breaches

## Fix alongside

2. **The refusal runs the globs together.** `IFS=` is still in force when `"$*"` joins the arguments, so two globs print with no separator: `bash .github/shellcheck.sh 'nope/*.sh' 'nada/*.sh'` gives `shellcheck.sh: no file matched nope/*.shnada/*.sh; the gate checked nothing` (verified). The table cell reads `no file matched <globs>`; the test only ever passes one glob, so it does not see this. Restore `IFS` after the loop, or print `"$@"` through `printf '%s '`. Smell: Mysterious Name, in the sense that the message no longer names the inputs a person can recognise.

```
IFS=  # an argument is one path or one glob, never split on the spaces in it
for g in "$@"; do
  for f in $g; do if [ -f "$f" ]; then files+=("$f"); fi; done
done
if [ "${#files[@]}" = 0 ]; then
  echo "shellcheck.sh: no file matched $*; the gate checked nothing" >&2
```

3. **A bad tarball is sticky and the refusal does not say what to remove.** `[ -f "$tarball" ] || curl` keeps whatever is on disk, so a download cut mid-stream (curl writes as it receives; `-f` only guards HTTP errors) fails the checksum on every later run with `sc.tar.xz: FAILED` / `WARNING: 1 computed checksum did NOT match`, and nothing names the file to delete. Verified with a one-byte `sc.tar.xz` under a private `TMPDIR` and ShellCheck off PATH: two runs, same refusal, file still there. The table cell accepts the tool's own message, so this is inside the design; the cheap hardening is `rm -f "$tarball"` before the checksum exits, or download to `$tarball.part` and rename after the check passes. Judgement call, not a smell from the baseline.

```
  [ -f "$tarball" ] || curl -fsSL -o "$tarball" "https://github.com/koalaman/shellcheck/releases/download/v$version/shellcheck-v$version.$plat.tar.xz"
  if command -v sha256sum >/dev/null; then echo "$sha  $tarball" | sha256sum -c - >&2
  else echo "$sha  $tarball" | shasum -a 256 -c - >&2; fi
```

4. **Check 6's premise is "ShellCheck hidden", but the PATH it sets does not hide one that lives in `/usr/bin`.** On this Mac the pin is at `/opt/homebrew/bin`, so the narrowed PATH hides it. On `ubuntu-latest` the image ships `shellcheck 0.9.0` in `/usr/bin` (runner-images `Ubuntu2404-Readme.md`, read 2026-09-24), so the check passes there for a different reason: the version is off the pin, not absent. The day the image moves to 0.11.0, check 6 goes red with `exit 0` where the test wants 1, and the header's "ShellCheck hidden" is wrong on Linux today. A fake `shellcheck` in `$fx/bin` that exits 1 would make the hiding real on every machine and let the comment say what the test does. Smell: the test's comment states a condition the code does not establish.

```
PATH="$fx/bin:/usr/bin:/bin" run clean.sh
same "6 an unpinned platform without ShellCheck is refused" 1 "$code"
same "6 the refusal names the pair" "shellcheck.sh: ShellCheck 0.11.0 is not pinned for Plan9.mips; install it by hand" "$err"
```

5. **The doctor's PASS names any version, not the pin.** `vp matches the ADR pin` compares against the ADR; the new line prints `PASS  shellcheck 0.9.0` on a machine whose ShellCheck the gate will ignore and replace with a download. Harmless, because the gate does the right thing either way and the NOTE says so, but a person reading PASS believes the local tool is the one CI runs. Printing the pin beside an off-pin version (`PASS  shellcheck 0.9.0 (the gate pins 0.11.0 and downloads it)`) keeps the table honest without a FAIL. Judgement call.

```
  local scv; scv="$(shellcheck --version 2>/dev/null | sed -n 's/^version: //p' || true)"
  if [ -n "$scv" ]; then echo "PASS  shellcheck $scv"
  else note "shellcheck" "brew install shellcheck (apt install shellcheck, dnf install ShellCheck, winget install koalaman.shellcheck); .github/shellcheck.sh downloads the pinned build without it, so this is a NOTE"; fi
```

6. **Three directive reasons cite `set -f` by line number.** `line 7` is right at this commit (`set -fuo pipefail` is line 7 of `delegation.sh`, no `set +f` anywhere), but a header edit moves it and the reason then points at the wrong line while ShellCheck stays silent. Citing the text (`set -f in the header`) survives edits. Nit.

```
  # shellcheck disable=SC2086 # set -f is on (line 7), so this splits words without globbing, which is the intent
  set -- $args
```

hard findings: 1
