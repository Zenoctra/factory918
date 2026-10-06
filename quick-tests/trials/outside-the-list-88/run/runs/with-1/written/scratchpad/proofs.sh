#!/usr/bin/env bash
# Blast-radius proofs for #88 at 69bd412. Run from anywhere: bash proofs.sh <worktree>.
# Every block prints what it ran and exits 1 on the first claim that does not hold.
set -uo pipefail
wt="${1:?worktree path}"; old=ab47eb9; new=69bd412
t="${TMPDIR:?}"; mkdir -p "$t/p"; cd "$wt"
die() { echo "CLAIM FAILED: $1"; exit 1; }

echo "--1 the hook: only comment lines were added"
git show "$old:template/.claude/hooks/delegation.sh" | grep -v '^[[:space:]]*#' > "$t/p/hook-old"
git show "$new:template/.claude/hooks/delegation.sh" | grep -v '^[[:space:]]*#' > "$t/p/hook-new"
diff "$t/p/hook-old" "$t/p/hook-new" && echo "identical after stripping comment lines ($(wc -l < "$t/p/hook-new" | tr -d ' ') lines)" || die "hook code changed"
sed -n '7p' template/.claude/hooks/delegation.sh | grep -q 'set -f' && echo "line 7 is: $(sed -n 7p template/.claude/hooks/delegation.sh)" || die "set -f is not on line 7"

echo "--2 the doctor's two lines, old and new, HOME with and without the sheet, shellcheck on and off PATH"
mkdir -p "$t/p/with/.claude" "$t/p/without"; touch "$t/p/with/.claude/pstack-models.md"
for rev in $old $new; do
  git show "${rev}:factory918.sh" | sed -n '/PASS  models sheet/,/^  chk "AGENTS.md/p' | grep -v '^  chk' > "$t/p/doctor-$rev.sh"
  echo "$rev: $(wc -l < "$t/p/doctor-$rev.sh" | tr -d ' ') lines extracted"
  for h in with without; do for p in on off; do
    [ $p = on ] && path="$PATH" || path=/usr/bin:/bin
    out="$(HOME="$t/p/$h" PATH="$path" bash -c 'note() { echo "NOTE  $1"; echo "      fix: $2"; }; set -euo pipefail; d() { source "$1"; }; d "$1"' _ "$t/p/doctor-$rev.sh")"
    printf '%s sheet=%s shellcheck=%s\n%s\n' "$rev" "$h" "$p" "$out"
    printf '%s\n' "$out" > "$t/p/out-$rev-$h-$p"
  done; done
done
for h in with without; do for p in on off; do
  grep -v shellcheck "$t/p/out-$old-$h-$p" > "$t/p/a"; grep -v shellcheck "$t/p/out-$new-$h-$p" > "$t/p/b"
  diff "$t/p/a" "$t/p/b" >/dev/null || die "models-sheet line differs ($h, $p)"
done; done
echo "models-sheet output identical in all four states; the shellcheck line is the only addition"

echo "--3 cmd_sync's count line"
skills="$wt/template/.agents/skills"; dirs=("$skills"/*/)
echo "new array: ${#dirs[@]}   old ls|wc: $(ls -d "$skills"/*/ | wc -l | tr -d ' ')"
[ "${#dirs[@]}" = "$(ls -d "$skills"/*/ | wc -l | tr -d ' ')" ] || die "count differs"
grep -q '^  local skills="\$TEMPLATE/.agents/skills"$' factory918.sh && echo '$skills is "$TEMPLATE/.agents/skills" (factory918.sh:381): never empty' || die "skills assignment moved"

echo "--4 the gate reuses a cached binary without a checksum"
c="$t/p/cache"; rm -rf "$c"; mkdir -p "$c/shellcheck-0.11.0/shellcheck-v0.11.0"
printf '#!/bin/sh\necho "PLANTED BINARY RAN: $*"\n' > "$c/shellcheck-0.11.0/shellcheck-v0.11.0/shellcheck"; chmod +x "$c/shellcheck-0.11.0/shellcheck-v0.11.0/shellcheck"
printf '#!/usr/bin/env bash\nf=$1\ncat $f\n' > "$t/p/unquoted.sh"
(cd "$t/p" && TMPDIR="$c" PATH=/usr/bin:/bin bash "$wt/.github/shellcheck.sh" unquoted.sh); code=$?
[ $code = 0 ] || die "expected the planted binary to run and exit 0, got $code"

echo "--5 Linux.aarch64 is not pinned"
mkdir -p "$t/p/fakebin"; printf '#!/bin/sh\ncase "$1" in -s) echo Linux ;; -m) echo aarch64 ;; esac\n' > "$t/p/fakebin/uname"; chmod +x "$t/p/fakebin/uname"
(cd "$t/p" && PATH="$t/p/fakebin:/usr/bin:/bin" bash "$wt/.github/shellcheck.sh" unquoted.sh); code=$?
[ $code = 1 ] || die "expected exit 1 on Linux.aarch64, got $code"

echo "--6 cp -p keeps the gate's mode"
rm -rf "$t/p/proj"; mkdir -p "$t/p/proj/.github"; cp -p "$wt/template/.github/shellcheck.sh" "$t/p/proj/.github/shellcheck.sh"
[ -x "$t/p/proj/.github/shellcheck.sh" ] && echo "copied file is executable" || die "mode lost"
echo "all claims held"
