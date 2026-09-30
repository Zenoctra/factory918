# Ticket #108, fix lane 1

Branch `wt/108-fix1` off `bf459a9`. Commit `d016a2e` "Point the four playbooks at both disposition forms".

## Change

The parenthetical "(Ticket step 6 gives the form; `review-brief.sh` refuses the review while one has none)" became "(Ticket steps 5 and 6 give the forms; `review-brief.sh` refuses the review while one has none)" in the delegation step of `feature.md`, `bug-fix.md`, `refactoring.md` and `perf-issue.md`.

The four playbooks are vendored, so the edit was made in the `+` line of each patch under `patches/pstack/poteto-mode/playbooks/`, and `./factory918.sh sync` re-applied them onto the pre-patch upstream to regenerate the four files under `template/.agents/skills/poteto-mode/playbooks/`. Hunk headers and context lines are untouched, so each patch still applies cleanly. `grep -n "gives the form" SOURCES.md` found nothing, so SOURCES.md needed no edit.

Eight files changed, four insertions and four deletions:

    patches/pstack/poteto-mode/playbooks/bug-fix.md.patch
    patches/pstack/poteto-mode/playbooks/feature.md.patch
    patches/pstack/poteto-mode/playbooks/perf-issue.md.patch
    patches/pstack/poteto-mode/playbooks/refactoring.md.patch
    template/.agents/skills/poteto-mode/playbooks/bug-fix.md
    template/.agents/skills/poteto-mode/playbooks/feature.md
    template/.agents/skills/poteto-mode/playbooks/perf-issue.md
    template/.agents/skills/poteto-mode/playbooks/refactoring.md

## Verification

`./factory918.sh sync` before commit: `vendored: 72 skills. Review with git status, bump VERSION, commit.`

`git status --porcelain` before commit: the eight files above and nothing else.

`bash tests/spec-review/no-stale-wording.sh`: `ok: no stale wording` (exit 0).

`bash tests/spec-review/review-brief.sh`: `ok 1720 assertions` (exit 0).

`./factory918.sh sync` after commit, then `git status --porcelain`: no output, clean.

`grep -rn "Ticket step 6 gives the form" template patches SOURCES.md`: no output, exit 1.

Nothing was pushed.
