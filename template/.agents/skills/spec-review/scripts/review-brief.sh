#!/usr/bin/env bash
# spec-review step 1. Runs the diff once, writes the review state the delegation hook reads, and
# assembles the two reviewer briefs, so the orchestrator hands each lane a file and reads no code.
#   review-brief.sh <fixed-point> [--ticket N] [--standards FILE ...]
#   review-brief.sh --paths P... --commits SHA... [--ticket N] [--standards FILE ...]
# The second form is the sweep over units already on main: the fixed point is the word "paths"
# and the diff is git show <commits> -- <paths>. Rerunning overwrites the previous state.
set -euo pipefail
usage() {
  echo "usage: review-brief.sh <fixed-point> [--ticket N] [--standards FILE ...]" >&2
  echo "       review-brief.sh --paths P... --commits SHA... [--ticket N] [--standards FILE ...]" >&2
  exit 1
}
skill="$(cd "$(dirname "$0")/.." && pwd -P)"
root="$(git rev-parse --show-toplevel)"
cd "$root"
fixed="" ticket="" list=""
paths=() commits=() standards=()
while [ $# -gt 0 ]; do
  case "$1" in
    --ticket) ticket="${2:-}"; [ -n "$ticket" ] || usage; list=""; shift ;;
    --standards) list=standards ;;
    --paths) list=paths ;;
    --commits) list=commits ;;
    -*) usage ;;
    *) case "$list" in
         standards) standards+=("$1") ;;
         paths) paths+=("$1") ;;
         commits) commits+=("$1") ;;
         *) [ -z "$fixed" ] || usage; fixed="$1" ;;
       esac ;;
  esac
  shift
done
if [ ${#paths[@]} -gt 0 ]; then
  [ ${#commits[@]} -gt 0 ] && [ -z "$fixed" ] || usage
  for c in "${commits[@]}"; do
    git rev-parse --verify -q "$c^{commit}" >/dev/null || { echo "review-brief: $c does not resolve to a commit" >&2; exit 1; }
  done
  fixed=paths
  id="sweep-$(git rev-parse --short "${commits[0]}")"
else
  [ -n "$fixed" ] || usage
  git rev-parse --verify -q "$fixed^{commit}" >/dev/null || { echo "review-brief: $fixed does not resolve to a commit" >&2; exit 1; }
  id="$(printf '%s' "$fixed" | tr -c 'A-Za-z0-9._-' '_')"
fi
# The smell baseline is SKILL.md step 3's bullets, each with its fix arrow; a resync that moves
# them must fail here, before any state is written, not leave a brief with no baseline.
smells="$(sed -n '/^### 3\./,/^### 4\./p' "$skill/SKILL.md" | grep '^- \*\*.*→' || true)"
if [ -z "$smells" ]; then
  echo "review-brief: no smell baseline found in $skill/SKILL.md (no line matching '^- **...→' between '### 3.' and '### 4.'); nothing written" >&2
  exit 1
fi
dir=".scratch/review/$id"
rm -rf "$dir"
mkdir -p "$dir"
if [ "$fixed" = paths ]; then
  git show --format='commit %h %s' "${commits[@]}" -- "${paths[@]}" > "$dir/diff"
  git show --stat --format='%h %s' "${commits[@]}" -- "${paths[@]}" > "$dir/stat"
  git log --oneline --no-walk "${commits[@]}" > "$dir/log"
  git show --name-only --format= "${commits[@]}" -- "${paths[@]}" | sed '/^$/d' | sort -u > "$dir/files"
  messages="$(git log --format=%B --no-walk "${commits[@]}")"
else
  git diff "$fixed...HEAD" > "$dir/diff"
  git diff "$fixed...HEAD" --stat > "$dir/stat"
  git log "$fixed..HEAD" --oneline > "$dir/log"
  git diff "$fixed...HEAD" --name-only > "$dir/files"
  messages="$(git log "$fixed..HEAD" --format=%B)"
fi
if [ ! -s "$dir/diff" ]; then
  rm -rf "$dir"
  echo "review-brief: the diff is empty; nothing to review since $fixed" >&2
  exit 1
fi
state=.claude/state/review
rm -rf "$state"
mkdir -p "$state"
echo "$fixed" > "$state/fixed-point"
cp "$dir/files" "$state/files"
echo "$dir" > "$state/dir"

# The spec is the ticket body, from --ticket or from the first #N in the commit messages. Never the
# author's own words (SKILL.md step 2).
[ -n "$ticket" ] || ticket="$(printf '%s\n' "$messages" | grep -oE '#[0-9]+' | head -1 | tr -d '#' || true)"
spec=""
if [ -n "$ticket" ]; then
  spec="$(gh issue view "$ticket" --json body -q .body 2>/dev/null || true)"
  [ -n "$spec" ] || echo "review-brief: gh could not fetch #$ticket; no spec" >&2
fi
if [ ${#standards[@]} -eq 0 ] && [ -f CODING_STANDARDS.md ]; then standards=(CODING_STANDARDS.md); fi
common() {
  echo "Read nothing beyond this brief unless a finding needs the code around a hunk, and then read that one function or section, not the file. Run nothing."
  echo
  echo "## Commits"
  echo
  cat "$dir/log"
  echo
  echo "## Changed files"
  echo
  cat "$dir/stat"
  echo
  echo "## Diff"
  echo
  if [ "$(wc -l < "$dir/diff")" -lt 500 ]; then
    echo '```diff'
    cat "$dir/diff"
    echo '```'
  else
    echo "The diff is $(wc -l < "$dir/diff" | tr -d ' ') lines; read it from \`$dir/diff\`."
  fi
  echo
}
{
  echo "# Standards review brief"
  echo
  common
  echo "## Standards"
  echo
  if [ ${#standards[@]} -gt 0 ]; then
    for f in "${standards[@]}"; do
      echo "### $f"
      echo
      cat "$f"
      echo
    done
  else
    echo "This repository documents no coding standards; the smell baseline below is the whole standard."
    echo
  fi
  echo "## Smell baseline"
  echo
  echo "Each smell reads *what it is* -> *how to fix*; match it against the diff. A documented repo standard overrides the baseline; every smell is a judgement call, never a hard violation."
  echo
  printf '%s\n' "$smells"
  echo
  echo "## Report"
  echo
  echo "Report, per file/hunk where relevant, (a) every place the diff violates a documented standard: cite the standard (file + the rule); and (b) any baseline smell you spot: name it and quote the hunk. Distinguish hard violations from judgement calls: documented-standard breaches can be hard, but baseline smells are always judgement calls, and a documented repo standard overrides the baseline. Skip anything tooling enforces. Read nothing beyond this brief unless a finding needs the code around a hunk, and then read that one function or section, not the file. Under 400 words."
  echo
  echo "Write your report to \`$dir/standards-report.md\` and reply with only that path."
  echo "End the report with exactly one line \`hard findings: N\` counting your hard findings (documented-standard breaches; baseline smells and judgement calls do not count)."
} > "$dir/standards-brief.md"
if [ -n "$spec" ]; then
  {
    echo "# Spec review brief"
    echo
    common
    echo "## The ticket (#$ticket)"
    echo
    printf '%s\n' "$spec"
    echo
    echo "## Report"
    echo
    echo "Report: (a) requirements the spec asked for that are missing or partial; (b) behaviour in the diff that wasn't asked for (scope creep); (c) requirements that look implemented but where the implementation looks wrong. Quote the spec line for each finding. Read nothing beyond this brief unless a finding needs the code around a hunk, and then read that one function or section, not the file. Under 400 words."
    echo
    echo "Write your report to \`$dir/spec-report.md\` and reply with only that path."
    echo "End the report with exactly one line \`hard findings: N\` counting your hard findings (requirements missing or partial, implementations that look wrong, and behaviour that was not asked for)."
  } > "$dir/spec-brief.md"
  echo "$dir/standards-brief.md"
  echo "$dir/spec-brief.md"
else
  echo "$dir/standards-brief.md"
  echo "no spec: Standards axis only"
fi
