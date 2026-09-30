## Would break

1. **The gate's test hides ShellCheck by PATH position, so a distro package at the pin makes check 6 fail against a gate that works.** `tests/shellcheck/gate.sh:75` runs the platform row with `PATH="$fx/bin:/usr/bin:/bin"`, and the header at `:7` says this is "ShellCheck hidden". It is hidden only where it lives outside `/usr/bin` and `/bin`: Homebrew on this machine (`/opt/homebrew/bin`), or an off-pin apt package (`ubuntu-latest` carries `shellcheck 0.9.0-1`, checked in the runner-images README today). On a Linux whose package is 0.11.0 at `/usr/bin/shellcheck` (Arch's is; the doctor's own fix text sends a user to `apt`, `dnf` and `winget` packages), the gate finds the pin on that PATH, never reaches the `uname` case, and prints the count line with exit 0, so `same "6 ..." 1 "$code"` reports `FAIL 6`. Run here with the test's line and a pinned `shellcheck` in a directory the PATH keeps: `PATH="$fx/bin:$fx/pinned:/usr/bin:/bin" bash template/.github/shellcheck.sh clean.sh` printed `ShellCheck 0.11.0, files checked: 1`, exit 0; the same line without the pinned directory printed the refusal, exit 1. Standard: `CODING_STANDARDS.md:9`, "Prefer commands that behave the same on macOS and Linux": the test passes on macOS and on the CI image and fails on a Linux laid out by the doctor's fix. Hiding by name fixes it in one line beside the fake `uname`: `printf '#!/bin/sh\nexit 127\n' > bin/shellcheck; chmod +x bin/shellcheck`.

```sh
cat > bin/uname <<'SH'
#!/bin/sh
case "$1" in -s) echo Plan9 ;; -m) echo mips ;; esac
SH
chmod +x bin/uname
...
PATH="$fx/bin:/usr/bin:/bin" run clean.sh
same "6 an unpinned platform without ShellCheck is refused" 1 "$code"
same "6 the refusal names the pair" "shellcheck.sh: ShellCheck 0.11.0 is not pinned for Plan9.mips; install it by hand" "$err"
```

Documented step: `AGENTS.md:39` "`bash tests/shellcheck/gate.sh`." and `tests/shellcheck/gate.sh:6-7` "a platform the pin has no build for is refused when no ShellCheck is on PATH (a fake uname on PATH, ShellCheck hidden)".
Result: on a machine whose `/usr/bin/shellcheck` is 0.11.0, check 6 gets the count line and exit 0 instead of the refusal and reports `FAIL 6 an unpinned platform without ShellCheck is refused` for a gate that behaves as designed; CI and this machine do not see it because their ShellCheck is off-pin or outside `/usr/bin`.
spec: table `Local ShellCheck absent, platform not pinned`/`Exit`

## Fails open

## Standards breaches

2. **The file-level directive in `review-brief.sh` gives a reason that misdescribes two of its sixteen sites.** `CODING_STANDARDS.md:15` asks the reason to state why the pattern is intended; the reason says "every single-quoted string here is a jq program or a Markdown template", but two of the sixteen SC2016 findings the directive covers at `ab47eb9` are the awk programs `split='` (`:115`) and `fenced='` (`:119`), neither jq nor Markdown. The directive itself sits where the standard puts it (the whole file produces the pattern, so the top of the file); only the reason is short by a word: "a jq or awk program or a Markdown template".

```sh
# shellcheck disable=SC2016 # every single-quoted string here is a jq program or a Markdown template; the backticks and $ are literal
set -euo pipefail
```

## Fix alongside

hard findings: 1
