PR #126 gives both review briefs a `## Reading pack` section. It holds the code the diff touches, as it stands at the reviewed commit, within fixed byte cutoffs, so a reviewer does not have to open the repository. It is stack-ready on #125: two review rounds ended at `act-on items: 0`, and CI is green at the head.

## Status

- `STACK-READY`.
- Head: f58308b5eae3f6617cf3a5200e7679e5737a5702. `git rev-parse HEAD` and `git ls-remote origin refs/heads/feat/review-reading-pack` return the same SHA.
- Branch: `feat/review-reading-pack`.
- PR: https://github.com/Zenoctra/factory918/pull/126. It is no longer a draft.
- Base branch: `feat/fix-only-from-round-two`, which is PR #125. Its head is still 0edf8c8952e7563ec862e460f71becde4506bd96.
- Patch base SHA: 0edf8c8952e7563ec862e460f71becde4506bd96.
- Intended parent: ticket #106 (PR #125).
- `closingIssuesReferences` lists #107, after the root's #100 retarget. I did not retarget.
- The PR body now ends with `Closes #107`, then the attribution line, then `Claude Opus 5.5 on Claude Code` as the last line. I reordered it with `gh pr edit --body-file` and pushed no commit, so the head is still f58308b.

## Overlap

Step 1 (`overlap.sh 107`, exit 0):

```
go: autopilot-stack
#121 feat/provisional-ticket-ids: template/.agents/skills/spec-review/scripts/review-brief.sh tests/spec-review/review-brief.sh
#125 feat/fix-only-from-round-two: template/.agents/skills/spec-review/scripts/review-brief.sh tests/spec-review/review-brief.sh
base: origin/feat/fix-only-from-round-two
```

Step 8 (`overlap.sh 107 --diff`, exit 0):

```
go: autopilot-stack
#120 feat/speed-lessons: SOURCES.md docs/knowledge/INDEX.md docs/knowledge/core/DECISIONS.md template/docs/factory918/DECISIONS.md
#121 feat/provisional-ticket-ids: docs/knowledge/INDEX.md docs/knowledge/core/DECISIONS.md template/.agents/skills/spec-review/scripts/review-brief.sh template/docs/factory918/DECISIONS.md tests/spec-review/review-brief.sh
#124 feat/reviewer-model-eval: SOURCES.md docs/knowledge/INDEX.md docs/knowledge/core/DECISIONS.md template/docs/factory918/DECISIONS.md
#125 feat/fix-only-from-round-two: SOURCES.md docs/knowledge/INDEX.md docs/knowledge/core/DECISIONS.md patches/mattpocock/spec-review.SKILL.md.patch template/.agents/skills/spec-review/SKILL.md template/.agents/skills/spec-review/scripts/review-brief.sh template/docs/factory918/DECISIONS.md tests/spec-review/review-brief.sh
```

## Criteria

1. **Both briefs carry the pack after the diff: whole small files, and each changed function or section of a large file under a line naming the file and range.** Table rows 1 to 21 and row 26 have one assertion per cell in both layouts, and `tests/spec-review/review-brief.sh` prints `ok 1294 assertions`. A real run over the whole stack (`reading-pack.sh origin/main`, saved as `pack-origin-main.md`) reads right.
2. **The pack is bounded, with one line naming what it leaves out.** Rows 22 to 24 cover it: exactly the 65536-byte total, a 2-byte file over the total, and one entry larger than the total. The real run carried 64 KB and ended with one `Not carried` line.
3. **The Report section says the pack is the code to read.** Row 27 checks both briefs, and the drift guard checks SKILL.md.
4. **The scenario table is on the ticket, with one assertion per cell written first.** The table is under `## Testing decisions` on #107, with an appended dated amendment for writer flags 2, 4 and 5. Commit `8a40823` (tests) comes before `3b8c81b` (script).
5. **SKILL.md step 4 names the section and the cutoffs.** The change went through the patch. `./factory918.sh sync` leaves `git status` clean, and the drift guard asserts the bullet and the sentence.

## Reviews

- Round 1: https://github.com/Zenoctra/factory918/pull/126#issuecomment-5794486013
  - `act-on items: 0`.
  - One item, S1 (the AGENTS.md ShellCheck count), was marked `fixed: f58308b` and owed round 2.
- Round 2, the whole diff at f58308b: https://github.com/Zenoctra/factory918/pull/126#issuecomment-5795119512
  - `act-on items: 0`.
  - Both axes had 0 hard findings. Three Standards notes were recorded as Noted.
  - The Spec lane of round 2 was stopped by a network error and relaunched fresh on the same brief.
- No restarts.
- The trail review ran: `trail-review.md`, `reviewed by Claude Opus 5`. It raised 12 flags:
  - Fixed: the todo record, the ticket amendment, the missing ticket (now #127), and the PR body's Linux and head-verification claims.
  - Accepted: the commit-order note and the records commit not being last.
  - Left for Manuel: 1, 10 and 11, under Blocked.

## CI

- Run 35857124541 at e0e1130 failed at (9W) on Ubuntu. Two new test helpers exited before reading all their input, so under `pipefail` the command feeding them was killed by SIGPIPE. Commit 3fbc71b fixes this.
- Run 35858370668 at f58308b5eae3f6617cf3a5200e7679e5737a5702 concluded `success`.

## Records

- P107 is under Provisional in `docs/knowledge/core/DECISIONS.md`, commit e0e1130. It records the byte cutoffs, smallest-first selection, the unit ladder, no pack for the sweep, and why the script is its own file. It also records the rejected options: `.gitattributes`, an indentation parser, an unbounded `pack.md`, and reworded read-nothing sentences.
- The records commit is not the last on the branch. The CI fix and the count fix landed after it, and I did not rewrite pushed history.
- No ledger line and no M0 line were added.
- On #107, the Testing decisions section got the table (posted before implementation) and one dated amendment. The accepted writer flags are in comment https://github.com/Zenoctra/factory918/issues/107#issuecomment-5794299028.
- New ticket #127 covers three pre-#107 pipelines in the same test that exit early the same way.

## Decided

- The cutoffs are bytes (8192 bytes for a whole file, 4096 per unit, 65536 in total), because lines in this repository run to 1 KB.
- Smallest entries go first, while the output keeps production order.
- Shell units fall through three rungs: the function, then the comment-led block, then a window. Markdown takes the section, then a window.
- Deleted, binary, generated (`linguist-generated`), link, submodule, empty and large added files get a header line and no text.
- The sweep form carries no pack.
- The logic is a separate `reading-pack.sh` in `keep_files`, so #108's edits to `review-brief.sh` do not collide with it.
- A git failure inside the pack refuses the brief before any state is written.
- The existing "Read nothing beyond this brief" sentences are unchanged.
- The `how` step was done in-lane (one script, read whole).
- `interrogate` was skipped, because the two design candidates converged and their differences were settled by measurement.

## Blocked

These need Manuel's call. None of them blocks the PR.

1. **A `.gitattributes` for the generated paths.** Without it, the generated DECISIONS.md copies take about 7 KB of a factory pack. Adding one also collapses those files in GitHub's PR view.
2. **Measuring the pack.** No one has measured whether the pack shortens reviewer time enough to pay for up to 64 KB more text per brief.
3. **The in-lane `how`.** AGENTS.md asks for a sign-off before an owner reads in bulk itself. I logged a reason and took no sign-off.

## Trail

/Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.scratch/program/107/decisions.tsv
