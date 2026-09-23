#!/usr/bin/env bash
# Rebuild one round's frozen briefs from its committed inputs/ and compare them byte for byte with
# review/. Runs review-brief.sh as it stood at the recipe's script_at, in a shared clone checked out
# at the round's head, behind a gh stub that serves inputs/ and never touches the network.
# The heads live under refs/keep/103/*; fetch them first on a fresh clone.
# Exit 0 when diff and both briefs match, 1 naming the first file that differs, 2 on a setup error.
set -euo pipefail
[ $# -eq 1 ] || { echo "usage: rebuild.sh <round>" >&2; exit 2; }
here="$(cd "$(dirname "$0")" && pwd -P)"
rdir="$here/rounds/$1"
inputs="$rdir/inputs"
[ -f "$inputs/recipe" ] || { echo "rebuild: $inputs/recipe missing" >&2; exit 2; }
value() { sed -n "s/^$1=//p" "$2"; }
head="$(value head "$rdir/round")"
script_at="$(value script_at "$inputs/recipe")"
fixed="$(value fixed_point "$inputs/recipe")"
ticket="$(value ticket "$inputs/recipe")"
round="$(value round "$inputs/recipe")"
repo="$(git -C "$here" rev-parse --show-toplevel)"
for c in "$head" "$script_at"; do
  git -C "$repo" cat-file -e "$c^{commit}" 2>/dev/null || {
    echo "rebuild: $c is not in this repository; git fetch origin 'refs/keep/103/*:refs/keep/103/*'" >&2; exit 2; }
done

tmp="$(mktemp -d "${TMPDIR:-/tmp}/rebuild.XXXXXX")"
trap 'rm -rf "$tmp"' EXIT
git clone -q --shared --no-checkout "$repo" "$tmp/clone"
git -C "$tmp/clone" checkout -q --detach "$head"
mkdir -p "$tmp/skill" "$tmp/bin"
git -C "$repo" archive "$script_at" template/.agents/skills/spec-review | tar -x -C "$tmp/skill"
cat > "$tmp/bin/gh" <<'STUB'
#!/usr/bin/env bash
case "$*" in
  "issue view $REBUILD_TICKET --json body -q .body") cat "$REBUILD_INPUTS/ticket.md" ;;
  "issue view $REBUILD_TICKET --json author,comments -q "*) : ;;
  *) echo "gh stub: unhandled: $*" >&2; exit 1 ;;
esac
STUB
chmod +x "$tmp/bin/gh"

args=("$fixed" --ticket "$ticket" --previous "$inputs/previous.txt" --round "$round")
[ ! -f "$inputs/blast-radius.md" ] || args+=(--blast-radius "$inputs/blast-radius.md")
(cd "$tmp/clone" && PATH="$tmp/bin:$PATH" REBUILD_TICKET="$ticket" REBUILD_INPUTS="$inputs" \
  bash "$tmp/skill/template/.agents/skills/spec-review/scripts/review-brief.sh" "${args[@]}" >/dev/null)
out="$tmp/clone/$(cat "$tmp/clone/.claude/state/review/dir")"
for f in diff standards-brief.md spec-brief.md; do
  cmp -s "$out/$f" "$rdir/review/$f" || { echo "rebuild: $1: $f differs" >&2; exit 1; }
done
echo "rebuild: $1: identical"
