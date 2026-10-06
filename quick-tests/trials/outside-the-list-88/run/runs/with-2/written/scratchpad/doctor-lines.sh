# Runs the two doctor lines, old form (ab47eb9) and new form (69bd412), under the same conditions, and diffs their output.
set -uo pipefail
note() { echo "NOTE  $1"; echo "      fix: $2"; }
old() {
  [ -f "$HOME/.claude/pstack-models.md" ] && echo "PASS  models sheet" || note "models sheet" "factory918 install writes ~/.claude/pstack-models.md"
}
new() {
  if [ -f "$HOME/.claude/pstack-models.md" ]; then echo "PASS  models sheet"; else note "models sheet" "factory918 install writes ~/.claude/pstack-models.md"; fi
  local scv; scv="$(shellcheck --version 2>/dev/null | sed -n 's/^version: //p' || true)"
  if [ -n "$scv" ]; then echo "PASS  shellcheck $scv"
  else note "shellcheck" "brew install shellcheck (apt install shellcheck, dnf install ShellCheck, winget install koalaman.shellcheck); .github/shellcheck.sh downloads the pinned build without it, so this is a NOTE"; fi
}
echo "--- sheet present, shellcheck on PATH"; old; echo "..."; new
echo "--- sheet absent (HOME=$1), shellcheck absent (PATH=$2)"; HOME="$1" old; echo "..."; HOME="$1" PATH="$2" new
