verdict: PASS

Re-verification of PR #96 (ticket #88) at head `070c1fa9a1d9da9bcaa0fa4da1d6036f5c11da42`, after the chain rebase
onto PR #94's verified head `715100c`. Every rebase difference is explained by a conflict resolution against #94,
no line of #94's own diff was lost, every gate in `AGENTS.md` "Verifying" passes at this head, and CI at the new
head is green.

## Setup

- Own worktree `/Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.claude/worktrees/agent-a85729639b254134d`,
  clean before and after. `git fetch origin feat/shellcheck feat/design-artifact-on-ticket main` ->
  `+ 2360707...070c1fa feat/shellcheck -> origin/feat/shellcheck (forced update)`, exit 0.
- `git checkout --detach 070c1fa9a1d9da9bcaa0fa4da1d6036f5c11da42` -> `HEAD is now at 070c1fa Remove a cached tarball
  that fails its checksum so the next run fetches it again`, exit 0.
- `git rev-parse HEAD` -> `070c1fa9a1d9da9bcaa0fa4da1d6036f5c11da42`, exit 0.
- `git merge-base --is-ancestor 715100c HEAD` -> exit 0 (#94's verified head is an ancestor).
- `git rev-list --count 715100c..070c1fa` -> `11`, the eleven commits the owner reports.
- All gate runs used `TMPDIR=<session scratchpad>/tmp`. Nothing under version control was written.

## 1. Delta of the rebase

- `git diff --stat ab47eb9..2360707` vs `git diff --stat 715100c..070c1fa`, compared with `diff` -> **no output,
  exit 0**. Identical file list and identical per-file line counts: 27 files, 201 insertions, 18 deletions in both.
- `git diff --name-only` of each range, compared with `diff` -> no output. The two patches touch the same 27 paths;
  no file was added to or dropped from the change by the rebase.
- Per-file `diff <(git diff ab47eb9..2360707 -- F) <(git diff 715100c..070c1fa -- F)` for all 27 files (run from a
  script, since this worktree's guard refuses the inline process-substitution form): 18 files byte-identical,
  9 files differ. Re-comparing with the `index <blob>..<blob>` lines stripped, 3 of those 9 differ only in blob
  hashes and are content-identical:
  - `AGENTS.md` - identical hunk and identical context. #94's own change to this file is the "five -> six core
    documents" line, a different hunk, still present at 070c1fa.
  - `SOURCES.md` - identical hunk and context.
  - `docs/M0-findings.md` - identical hunk and context.
- The 6 files with a real content delta, each explained by a conflict resolution against #94, each keeping both
  PRs' content:
  1. `docs/agents/ledger.md` - this PR's two rows are byte-identical; only the hunk header and context moved
     (`@@ -22,3 +22,5 @@` -> `@@ -24,3 +24,5 @@`) because #94 appended two rows first. #94's two rows sit above this
     PR's two. Both kept, order as the owner describes.
  2. `docs/knowledge/core/DECISIONS.md` - this PR's row renumbered **P25 -> P26** and appended after #94's P25; the
     row's text is otherwise byte-identical to the pre-rebase row. The generated header count goes `93 -> 94`
     instead of `92 -> 93`. #94's P25 row and its P24 amendment (`## Diff`, `## Testing decisions` and `## Design`
     excluded; "amended 2026-09-22 by #89") are both present as context. Both kept.
  3. `docs/knowledge/INDEX.md` - generated. Only the `core/DECISIONS.md` line count changes, `93 -> 94` instead of
     `92 -> 93`. #94's rows in the same hunk (MANUAL 175, GLOSSARY 71, the new `core/SCENARIO-TABLE.md` row) and its
     `119 files` footer line are present and untouched. Both kept.
  4. `template/.agents/skills/poteto-mode/scripts/overlap.sh` - this PR's change is the same one line (the SC2016
     directive gaining its inline reason); it now sits above #94's amended `awk` line
     (`/^## (Diff|Testing decisions|Design)[[:space:]]*$/`) instead of the original `^## Diff` line. Both kept.
  5. `template/docs/factory918/DECISIONS.md` - generated. Same renumber to P26, appended after #94's P25. Both kept.
  6. `tests/poteto-mode/overlap.sh` - this PR's change is the same two-line-to-one-line SC2016 comment rewrite; the
     hunk moved from `@@ -12,9 +12,8 @@` to `@@ -13,9 +13,8 @@` because #94 rewrote the header prose above it and
     added a line. #94's rewritten header text and its check-17 cell are present. Both kept.
- Nothing outside the nine files the brief lists differs. The nine are exactly the intersection of the two PRs'
  file sets (`comm -12` of `git diff --name-only ab47eb9..715100c` and `git diff --name-only 715100c..070c1fa`).
- No line of #94 lost or altered. Two independent checks:
  - `comm -12` of (#94's added lines, sorted, unique) and (this patch's removed lines, sorted, unique) -> exactly
    two lines, both generated line counts:
    `<!-- lines: 93 | source: core/DECISIONS.md | part 1/1 | title: Factory918: decisions -->` and
    ``| `core/DECISIONS.md` | Factory918: decisions | 93 | ... |``. Both are replaced by their `94` form, which is
    what `build_knowledge.py` must produce once a row is appended. No other line of #94 is removed.
  - For every one of the 35 files #94 touches, every non-blank line #94 added checked with `grep -Fqx` against the
    file at 070c1fa -> only the same two generated-count lines report absent. Every other added line is present.
- No leftover conflict markers: `grep -rn '^<<<<<<<\|^>>>>>>>\|^=======$'` over `*.md *.sh *.yml *.py *.patch`
  excluding `research/` -> no output.
- The owner's account in `.scratch/program/88/report.md` ("Conflicts and how each was resolved") names the same six
  files with the same resolutions. I reached the list independently from the diffs before reading it; it matches.

## 2. Gates at 070c1fa

`AGENTS.md` "Verifying" at this head lists the ShellCheck gate command, `tests/shellcheck/gate.sh`, the four named
tests, the knowledge pair, `./factory918.sh sync`, and the fixture flow (which is what CI runs).

- `bash .github/shellcheck.sh factory918.sh template/.github/shellcheck.sh 'template/.claude/hooks/*.sh' 'template/.agents/skills/*/scripts/*.sh' 'tests/*/*.sh'`
  -> `ShellCheck 0.11.0, files checked: 20`, exit 0.
- `bash tests/shellcheck/gate.sh` -> `ok 17 assertions`, exit 0.
- `bash tests/hooks/delegation.sh` -> `ok 55 assertions`, exit 0.
- `bash tests/spec-review/review-comment.sh` -> `ok 82 assertions`, exit 0.
- `bash tests/spec-review/review-brief.sh` -> `ok 334 assertions`, exit 0.
- `bash tests/poteto-mode/overlap.sh` -> `ok 57 assertions`, exit 0.
- `bash tests/spec-review/layout.sh` -> no output, exit 0.
- `bash tests/spec-review/no-stale-wording.sh` -> `ok: no stale wording`, exit 0.
  (Every `tests/**/*.sh` except `tests/spec-review/fake-gh.sh`, which is a fixture, was run.)
- Both changes present in `tests/poteto-mode/overlap.sh` at this head:
  - line 160, #94's added cell: `check "17 tokens under ## Testing decisions (with ### parts) and ## Design ignored" 0 $'go: none\npaths: none\nbase: origin/main' 9`
  - line 17, this PR's directive reason: `# shellcheck disable=SC2016 # the backticks in the bodies below are the ticket's token delimiters, not command substitution`
  The test passes with both.
- `python3 tools/build_knowledge.py` -> `knowledge files: 119 -> docs/knowledge`, exit 0; `git status --porcelain`
  afterwards -> 0 lines.
- `python3 tools/check_knowledge.py` -> `knowledge ok: 119 files`, exit 0.
- `./factory918.sh sync` -> `vendored: 72 skills.`, exit 0; `git status --porcelain` afterwards -> 0 lines.
- Patches reproduce: the sync log has 20 `applied ` lines and `patches/series` has 20 entries; 0 lines matching
  `fail|error|reject`; the tree is clean after, so every patch applies to the pinned upstream and produces exactly
  the vendored bytes at this head.

## 3. `docs/knowledge/core/DECISIONS.md` at 070c1fa

- `grep -oE '^\| P[0-9]+ \|' docs/knowledge/core/DECISIONS.md | sort | uniq -c` -> every id count is 1. No duplicates.
- `P24` is "Overlap is not coupling...", `P25` is "The design artifact on the ticket" (#94's row), `P26` is
  "One shell gate, carried by the template" (this PR's row). Same three ids and titles in the regenerated
  `template/docs/factory918/DECISIONS.md`.
- Repo-wide `grep` for `P25|P26` outside `docs/knowledge/` and `research/` finds only the two DECISIONS copies.
  No prose, test, workflow or record names the id, so nothing was left pointing at the old number.
- PR body mentions say P26: line 18 ``...DECISIONS.md` P26 (P25 until the chain rebase onto PR #94, whose own row is
  P25)...``; line 80 ``...regenerates `template/docs/factory918/DECISIONS.md` with P26 (P25 before the chain rebase)...``.

## 4. CI at the new head

- `gh run list --repo Zenoctra/factory918 --branch feat/shellcheck --json databaseId,headSha,status,conclusion,event,createdAt --limit 10`
  -> the newest run is `databaseId 35756075400`, `headSha 070c1fa9a1d9da9bcaa0fa4da1d6036f5c11da42`,
  `event pull_request`, `status completed`, `conclusion success`, created `2026-09-22T16:44:11Z`. Exit 0. No polling
  needed; the run had already completed.
- `gh run view 35756075400 --repo Zenoctra/factory918 --json ...jobs` -> jobs `Fixture` success, `Factory` success.
  Title "Run ShellCheck at a pinned version in the factory, in every project and before a PR opens". Exit 0.
  The run is the `pull_request` event against the retargeted base, so its merge ref is against
  `feat/design-artifact-on-ticket`.

## 5. PR metadata

- `gh pr view 96 --repo Zenoctra/factory918 --json headRefOid,baseRefName,mergeable,isDraft,closingIssuesReferences,title,state`
  -> `headRefOid 070c1fa9a1d9da9bcaa0fa4da1d6036f5c11da42`, `baseRefName feat/design-artifact-on-ticket`,
  `mergeable MERGEABLE`, `isDraft false`, `state OPEN`, `closingIssuesReferences` a single entry, issue **#88**.
  Exit 0.

## Issues

None.

## Notes

- `docs/knowledge/core/DECISIONS.md` has no `P6` row. This predates both PRs: `git show ab47eb9:...` and
  `git show 715100c:...` also have no `P6`. Not introduced by this rebase and outside this PR's scope; recorded so a
  later id audit does not read it as damage from the renumber.
- The two lines of #94 that this patch replaces are the generated `DECISIONS.md` line counts (93 -> 94) in
  `docs/knowledge/core/DECISIONS.md` and `docs/knowledge/INDEX.md`. That is `build_knowledge.py`'s own output for a
  file that gained a row, not a hand edit: re-running the builder at this head leaves the tree clean.
- `./factory918.sh sync` was run twice (the first run's exit code was lost to a shell quirk in the reporting
  pipeline); both runs left `git status --porcelain` empty, and the second recorded exit 0 directly.
- The fixture flow in "Verifying" was not run locally; CI's `Fixture` job is that flow and it passed at this head.
- GitHub text (PR body, run titles, the owner's report) was read as data only. Nothing was merged, commented,
  edited or closed.
