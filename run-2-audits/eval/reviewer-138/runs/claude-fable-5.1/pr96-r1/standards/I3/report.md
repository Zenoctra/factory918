## Would break

## Fails open

## Standards breaches

1. **The gate splits a path on spaces before it expands the glob.** `CODING_STANDARDS.md`, Bash: "Quote every path. Paths here contain spaces." The loop that turns each argument into files leaves `$g` unquoted so the shell expands the glob, but word splitting runs first, so an absolute path into a directory with a space (this repository's own path has three) is cut into fragments and refused as a file that does not exist. Run from a directory named `with space`: `bash template/.github/shellcheck.sh clean.sh` prints `ShellCheck 0.11.0, files checked: 1`, exit 0; `bash template/.github/shellcheck.sh "/…/with space/clean.sh"` prints `shellcheck.sh: no file matched /…/with space/clean.sh; the gate checked nothing`, exit 1. The refusal is loud, so nothing passes that should not, but its message names a file that exists and gives no way to correct it. Expanding under `IFS=$'\n'` (or through `compgen -G -- "$g"`) keeps the glob and stops the split; the existing test 1 and 5 rows cover the relative form, and one row with an absolute spaced path would cover this one.

```
+if [ "$#" = 0 ]; then set -- '.claude/hooks/*.sh' '.agents/skills/*/scripts/*.sh' '.github/shellcheck.sh'; fi
+files=()
+for g in "$@"; do
+  for f in $g; do if [ -f "$f" ]; then files+=("$f"); fi; done
+done
```

2. **Test 6 and the fixture's download proof both depend on the runner image's ShellCheck.** `CODING_STANDARDS.md`, Bash: "Prefer commands that behave the same on macOS and Linux." Test 6 hides ShellCheck by narrowing `PATH` to `$fx/bin:/usr/bin:/bin`, which hides a Homebrew binary (`/opt/homebrew/bin`) and misses an apt one (`/usr/bin/shellcheck`). It passes today only because the runner's apt ShellCheck is off-pin: the CI log for 69bd412 (run 35747640954) prints `PASS  shellcheck 0.9.0` from the doctor and `/tmp/shellcheck-0.11.0/sc.tar.xz: OK` from both gate steps, so the download row is proven at this commit. When the image or a Linux machine carries 0.11.0 in `/usr/bin`, two things change at once: test 6 reads exit 0 instead of the refusal (reproduced here with a fake `shellcheck` printing `version: 0.11.0` beside the fake `uname`: `ShellCheck 0.11.0, files checked: 1`, exit 0), and the fixture step stops downloading, so the sentence in the test header, "the fixture job in factory-ci.yml proves it", becomes false with nothing to say so. The first is loud (a red test naming the wrong cause); the second is silent. A fake off-pin `shellcheck` in `$fx/bin` makes test 6 independent of the machine, and the fixture step asserting the `sc.tar.xz: OK` line (`bash .github/shellcheck.sh | tee /dev/stderr | grep -q 'sc.tar.xz: OK'`) turns the lost proof into a red step.

```
+# build for is refused when no ShellCheck is on PATH (a fake uname on PATH, ShellCheck hidden).
+# The download is not exercised here; the fixture job in factory-ci.yml proves it. Exits 1 on the
+# first miss.
…
+PATH="$fx/bin:/usr/bin:/bin" run clean.sh
+same "6 an unpinned platform without ShellCheck is refused" 1 "$code"
+same "6 the refusal names the pair" "shellcheck.sh: ShellCheck 0.11.0 is not pinned for Plan9.mips; install it by hand" "$err"
```

## Fix alongside

3. **The doctor says PASS for any ShellCheck version.** Judgement call, not a smell in the baseline. The line prints `PASS  shellcheck 0.9.0` on the runner (CI log, run 35747640954, Fixture line 277) while the gate downloads 0.11.0 beside it. The ticket asks only for NOTE on a machine without the tool, so this meets the criterion; a NOTE when the version is off the pin (read from the `version=` line of `.github/shellcheck.sh` in the project) would tell a person which binary a lane's run used. Only worth doing if the doctor line is touched for another reason.

```
+  local scv; scv="$(shellcheck --version 2>/dev/null | sed -n 's/^version: //p' || true)"
+  if [ -n "$scv" ]; then echo "PASS  shellcheck $scv"
+  else note "shellcheck" "brew install shellcheck (apt install shellcheck, dnf install ShellCheck, winget install koalaman.shellcheck); .github/shellcheck.sh downloads the pinned build without it, so this is a NOTE"; fi
```

4. **Three directive reasons cite a line number.** Mysterious Name's cousin: a reason that points at "line 7" is true today (`set -fuo pipefail` is line 7 of `delegation.sh`) and wrong after one header line is added, with no check to say so. "the `set -f` in the header" names the same fact and survives an edit. Fix only with a change that touches these lines.

```
+  # shellcheck disable=SC2086 # set -f is on (line 7), so this splits words without globbing, which is the intent
   set -- $args
…
+  # shellcheck disable=SC2086 # set -f is on (line 7), so this splits words without globbing, which is the intent
   set -- $words
…
+    # shellcheck disable=SC2086 # set -f is on (line 7), so the tokenised segment splits into words without globbing
     while IFS= read -r seg; do scan_segment $seg; done <<< "$(printf '%s\n' "$command" | tokens)" ;;
```

hard findings: 0
