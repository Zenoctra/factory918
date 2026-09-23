#!/usr/bin/env bash
# Rebuild one round's briefs from its committed inputs/. Runs review-brief.sh as it stood at the
# recipe's script_at, in a shared clone checked out at the round's head, behind a gh stub that
# serves inputs/ and never touches the network.
#   rebuild.sh <round>                      compare diff and both briefs byte for byte with review/
#   rebuild.sh <round> --write              write them into review/ instead
#   rebuild.sh <round> --export DIR [SHA...] apply the fix commits SHA... to the head in topological
#       order and fold them into the head commit (the brief's commit list keeps its shape), brief
#       that tree, archive it into DIR and put diff and both briefs in DIR's review directory;
#       prints the folded commit (the head itself when no SHA is given)
# REBUILD_FIXTURES (this directory) holds rounds/; REBUILD_REPO (this repository) holds the commits.
# The heads and fix commits live under refs/keep/103/* and refs/keep/138/*; fetch them first on a
# fresh clone. Exit 0 on success, 1 naming the first file that differs, 2 on a setup error, 3 when
# the fix commits do not apply.
set -euo pipefail
usage() { echo "usage: rebuild.sh <round> [--write | --export DIR [SHA...]]" >&2; exit 2; }
[ $# -ge 1 ] || usage
name="$1"
shift
mode=compare export="" picks=()
case "${1:-}" in
  "") ;;
  --write) [ $# -eq 1 ] || usage; mode=write ;;
  --export) [ $# -ge 2 ] || usage; mode=export; export="$2"; shift 2; picks=("$@") ;;
  *) usage ;;
esac
here="$(cd "$(dirname "$0")" && pwd -P)"
rdir="${REBUILD_FIXTURES:-$here}/rounds/$name"
inputs="$rdir/inputs"
[ -f "$inputs/recipe" ] || { echo "rebuild: $inputs/recipe missing" >&2; exit 2; }
value() { sed -n "s/^$1=//p" "$2"; }
head="$(value head "$rdir/round")"
script_at="$(value script_at "$inputs/recipe")"
fixed="$(value fixed_point "$inputs/recipe")"
ticket="$(value ticket "$inputs/recipe")"
round="$(value round "$inputs/recipe")"
repo="${REBUILD_REPO:-$(git -C "$here" rev-parse --show-toplevel)}"
fetch="git fetch origin 'refs/keep/103/*:refs/keep/103/*' 'refs/keep/138/*:refs/keep/138/*'"
for c in "$head" "$script_at" ${picks[@]+"${picks[@]}"}; do
  git -C "$repo" cat-file -e "$c^{commit}" 2>/dev/null || { echo "rebuild: $c is not in this repository; $fetch" >&2; exit 2; }
done

tmp="$(mktemp -d "${TMPDIR:-/tmp}/rebuild.XXXXXX")"
trap 'rm -rf "$tmp"' EXIT
git clone -q --shared --no-checkout "$repo" "$tmp/clone"
git -C "$tmp/clone" checkout -q --detach "$head"
if [ ${#picks[@]} -gt 0 ]; then
  order=()
  while read -r c; do
    for p in "${picks[@]}"; do
      [ "$(git -C "$tmp/clone" rev-parse "$p^{commit}")" != "$c" ] || order+=("$c")
    done
  done < <(git -C "$tmp/clone" rev-list --topo-order --reverse "${picks[@]}" "^$head")
  [ ${#order[@]} -eq ${#picks[@]} ] || { echo "rebuild: $name: not every fix commit descends from $head: ${picks[*]}" >&2; exit 2; }
  git -C "$tmp/clone" -c user.name=rebuild -c user.email=rebuild@localhost cherry-pick -n "${order[@]}" >/dev/null 2>&1 ||
    { echo "rebuild: $name: the fix commits ${order[*]} do not apply to $head" >&2; exit 3; }
  (
    cd "$tmp/clone"
    GIT_COMMITTER_NAME="$(git log -1 --format=%cn HEAD)" GIT_COMMITTER_EMAIL="$(git log -1 --format=%ce HEAD)" \
      GIT_COMMITTER_DATE="$(git log -1 --format=%cI HEAD)" git commit -q --amend --no-edit --no-verify
  )
fi
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
reldir="$(cat "$tmp/clone/.claude/state/review/dir")"
out="$tmp/clone/$reldir"
files=(diff standards-brief.md spec-brief.md)
case "$mode" in
  compare)
    for f in "${files[@]}"; do
      cmp -s "$out/$f" "$rdir/review/$f" || { echo "rebuild: $name: $f differs" >&2; exit 1; }
    done
    echo "rebuild: $name: identical" ;;
  write)
    for f in "${files[@]}"; do cp "$out/$f" "$rdir/review/$f"; done
    echo "rebuild: $name: written" ;;
  export)
    mkdir -p "$export/$reldir"
    git -C "$tmp/clone" archive HEAD | tar -x -C "$export"
    for f in "${files[@]}"; do cp "$out/$f" "$export/$reldir/$f"; done
    git -C "$tmp/clone" rev-parse HEAD ;;
esac
