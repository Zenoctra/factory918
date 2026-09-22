#!/usr/bin/env bash
# Runs template/.github/shellcheck.sh, the shell gate, from a temp directory whose path has a
# space, and asserts one case per row of the table under ## Design on ticket #88: a clean file
# passes and is counted, a planted SC2086 is reported, a glob that matches no file is refused on
# stderr, a #!/bin/sh file keeps its POSIX checks, the zero-argument form from a project's root
# counts the project's hooks, skill scripts and the gate itself, and a platform the pin has no
# build for is refused when no ShellCheck is on PATH (a fake uname on PATH, ShellCheck hidden).
# The download is not exercised here; the fixture job in factory-ci.yml proves it. Exits 1 on the
# first miss.
set -euo pipefail
here="$(cd "$(dirname "$0")/../.." && pwd -P)"
script="$here/template/.github/shellcheck.sh"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
fx="$tmp/with space"
mkdir -p "$fx/bin" "$fx/project/.claude/hooks" "$fx/project/.agents/skills/x/scripts" "$fx/project/.github"
cd "$fx"
cat > clean.sh <<'SH'
#!/usr/bin/env bash
set -euo pipefail
name="$1"
echo "hello $name"
SH
cat > unquoted.sh <<'SH'
#!/usr/bin/env bash
f="$1"
cat $f
SH
cat > posix.sh <<'SH'
#!/bin/sh
arr=(a b)
echo "${arr[0]}"
SH
cp clean.sh project/.claude/hooks/a.sh
cp clean.sh project/.claude/hooks/b.sh
cp clean.sh project/.agents/skills/x/scripts/c.sh
cp "$script" project/.github/shellcheck.sh
ln -s ../.agents/skills project/.claude/skills
cat > bin/uname <<'SH'
#!/bin/sh
case "$1" in -s) echo Plan9 ;; -m) echo mips ;; esac
SH
chmod +x bin/uname

n=0
fail() { echo "FAIL $1"; echo "  got:    $2"; echo "  wanted: $3"; exit 1; }
# run <args...>: the gate from the current directory, its exit in code, stdout in got, stderr in err.
run() { set +e; got="$(bash "$script" "$@" 2>"$tmp/err")"; code=$?; set -e; err="$(cat "$tmp/err")"; }
# check <name> <exit> <stdout> <args...>: both exact.
check() {
  local name="$1" want="$2" out="$3"; shift 3
  run "$@"
  if [ "$code" != "$want" ] || [ "$got" != "$out" ]; then fail "$name" "exit $code: $got$err" "exit $want: $out"; fi
  n=$((n + 1))
}
# check_err <name> <exit> <pattern> <args...>: the exit exact, stdout plus stderr holding the pattern.
check_err() {
  local name="$1" want="$2" pat="$3"; shift 3
  run "$@"
  if [ "$code" != "$want" ] || ! grep -qF -- "$pat" <<< "$got$err"; then fail "$name" "exit $code: $got$err" "exit $want with $pat"; fi
  n=$((n + 1))
}
# same <name> <wanted> <got>
same() { [ "$2" = "$3" ] || fail "$1" "$3" "$2"; n=$((n + 1)); }

check "1 a clean file" 0 "ShellCheck 0.11.0, files checked: 1" clean.sh
check_err "2 a planted SC2086" 1 "SC2086" unquoted.sh
check_err "3 a glob that matches nothing" 1 "no file matched nope/*.sh; the gate checked nothing" 'nope/*.sh'
same "3 the refusal is on stderr" "shellcheck.sh: no file matched nope/*.sh; the gate checked nothing" "$err"
same "3 nothing on stdout" "" "$got"
check_err "4 a #!/bin/sh file keeps its POSIX checks" 1 "SC3030" posix.sh
cd project
check "5 the zero-argument form from a project's root" 0 "ShellCheck 0.11.0, files checked: 4"
cd ..
PATH="$fx/bin:/usr/bin:/bin" run clean.sh
same "6 an unpinned platform without ShellCheck is refused" 1 "$code"
same "6 the refusal names the pair" "shellcheck.sh: ShellCheck 0.11.0 is not pinned for Plan9.mips; install it by hand" "$err"
test -x "$script" || fail "7 the mode bit" "not executable" "executable"
n=$((n + 1))

echo "ok $n assertions"
