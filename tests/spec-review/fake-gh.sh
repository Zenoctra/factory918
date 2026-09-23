#!/bin/sh
# A gh for review-brief.sh: copied onto PATH as `gh` by tests/spec-review/review-brief.sh and by the
# CI fixture step. Fixtures are read from FAKE_GH_DIR, default the current directory (the script
# runs at the repository root):
#   pr.json     the PR, its author and comments; the script's own jq expression runs against it, so
#               the author filter is what is tested. Absent: a PR with no comments.
#   pr-error    printed to stderr with exit 1 in place of the comments (a failing gh).
#   FAKE_PR_BODY  the file whose text is the PR body for `gh pr view --json body`; unset or missing:
#               no PR for this branch.
# `gh issue view` answers with a fixed ticket body holding an acceptance-criteria list, and with the
# ticket author's comments already in the shape the script's jq expression prints (a comment by
# someone else is left out), so a run needs no fixture at all. Two fixtures change that:
#   issue-error   printed to stderr with exit 1 in place of either answer (a failing gh).
#   FAKE_ISSUE_BODY  the file whose text is the ticket body; unset or missing: the fixed body.
d="${FAKE_GH_DIR:-.}"
if [ "$1" = issue ] && [ -f "$d/issue-error" ]; then cat "$d/issue-error" >&2; exit 1; fi
case "$*" in
  "pr view --json body"*) if [ -f "${FAKE_PR_BODY:-}" ]; then cat "$FAKE_PR_BODY"; else echo 'no pull requests found for branch "x"' >&2; exit 1; fi ;;
  "pr view"*)
    if [ -f "$d/pr-error" ]; then cat "$d/pr-error" >&2; exit 1; fi
    while [ "$1" != -q ]; do shift; done
    if [ -f "$d/pr.json" ]; then exec jq -r "$2" "$d/pr.json"; fi
    echo '{"author": {"login": "me"}, "comments": []}' | exec jq -r "$2" ;;
  *"--json body"*) if [ -f "${FAKE_ISSUE_BODY:-}" ]; then cat "$FAKE_ISSUE_BODY"; else printf '## What to build\n\nWhat to build: the ticket body\n\n## Acceptance criteria\n\n- [ ] The brief carries the ticket body.\n'; fi ;;
  *"--json author,comments"*) printf '### 2026-09-17\n\nuser: the hook stays in bash.\n\n### 2026-09-18\n\nuser: the count is Act on plus Ask.\n\n' ;;
  *) echo "fake gh: unexpected args: $*" >&2; exit 2 ;;
esac
