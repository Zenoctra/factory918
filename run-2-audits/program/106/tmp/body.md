Every review round after the first read the whole diff from zero, though round one found eight of the ten findings that led to fixes on the last run. A round-one comment that marked its fixes `fixed:` also read `act-on items: 0` and passed as review-ready (PR #102's round one).

Round three now reviews only round two's fix commits when round two reported no Would-break or Fails-open item outside them. `review-comment.sh` decides it from the reports' quoted hunks and the fix commits' changed lines, and prints `fix only after <sha>`. `review-brief.sh` then takes that sha as round three's fixed point, the way #102 made rounds four and five fix-only. Rounds one and two brief exactly as before. A round-one comment now records the commit it reviewed (`reviewed: <sha>`) so round two can tell the fix lines apart. A round-one or round-two comment that marks an item `fixed:` prints `next round owed: round <N> reviews the fixes marked here`, and babysit reads it as not review-ready.

The design is the scenario table on #106 (`## Testing decisions`). The ticket left one question open: where a finding sits. A hard item is inside the fix when one of its quoted lines is a line the fix added or removed and every `+` or `-` line it quotes is one; context lines count for nothing. Anything else, a Spec item quoting its ticket line included, keeps round three whole-diff. That rule is recorded as P106.

## Records

- `docs/knowledge/core/DECISIONS.md` P20: retitled "Review rounds: three, five after a Would-break fix, fix-only from round three", with an amendment dated 2026-09-23 (#106).
- `docs/knowledge/core/DECISIONS.md` P106 (Provisional): where a round-two finding sits.

## Overlap

```
go: autopilot-stack
#120 feat/speed-lessons: SOURCES.md docs/knowledge/INDEX.md docs/knowledge/core/DECISIONS.md docs/knowledge/core/MANUAL.md patches/pstack/poteto-mode/playbooks/babysit.md.patch template/.agents/skills/poteto-mode/playbooks/babysit.md template/docs/agents/review-ladder.md template/docs/factory918/DECISIONS.md template/docs/factory918/MANUAL.md tests/spec-review/no-stale-wording.sh
#121 feat/provisional-ticket-ids: docs/knowledge/INDEX.md docs/knowledge/core/DECISIONS.md template/.agents/skills/spec-review/scripts/review-brief.sh template/docs/factory918/DECISIONS.md tests/spec-review/review-brief.sh
#124 feat/reviewer-model-eval: SOURCES.md docs/knowledge/INDEX.md docs/knowledge/core/DECISIONS.md template/docs/factory918/DECISIONS.md
```

Stacked on #124 (`feat/reviewer-model-eval`, 01a1e5f).

## Verification

All of these ran at caecbc4.

- Criterion 1, rounds one and two brief byte for byte as before: `tests/spec-review/review-brief.sh` cells 2A to 4C and 12A. The `same` helper compares stdout, `diff` and both briefs against the same history with every new line deleted.
- Criterion 2, the fix-only decision: `tests/spec-review/review-comment.sh` table B rows 1 to 6 and 12 (the Dismissed case shows the judgment does not decide), and `tests/spec-review/review-brief.sh` rows 4 and 5 (whole diff and fix-only), 12 and 13 (lines that are not the line), 14 (restart) and 15 to 18 (sticky, #93 unchanged).
- Criterion 3, the fixed point and the fix section: brief rows 5 and 7 to 11 (`FP` naming `fix only after`, `FR`, `FT`, the empty diff, the sweep); row 16 keeps #93's `FP` text byte for byte.
- Criterion 4, the owed line: comment table B rows 7 and 8; the babysit sentence is pinned in both copies by the brief test.
- Criterion 5, one assertion per cell, tests first: commit 7b7d1fb holds the tests and fails at its first new cell; aa155fc holds the scripts.
- Criterion 6, #93's 13B, 5C and 5D: direct assertions in #93's blocks of both test files.
- Criterion 7: `spec-review/SKILL.md` step 1 (through `patches/mattpocock/spec-review.SKILL.md.patch`), pinned by the brief test; P20 retitled and amended.
- `bash tests/spec-review/review-brief.sh`: ok 986 assertions. `bash tests/spec-review/review-comment.sh`: ok 264 assertions. `bash tests/spec-review/no-stale-wording.sh`: ok.
- `bash .github/shellcheck.sh` over the 23 files AGENTS.md names: no findings. `bash tests/shellcheck/gate.sh`: ok 17.
- `bash tests/hooks/delegation.sh`: ok 55. `bash tests/poteto-mode/overlap.sh`: ok 57. `bash tests/knowledge/provisional-ids.sh`: 26 passed. `bash tests/eval/reviewer/refusals.sh`: 230 passed.
- `python3 tools/build_knowledge.py` leaves `git status` clean, and `python3 tools/check_knowledge.py` passes (119 files). `./factory918.sh sync` leaves `git status` clean.

Closes #106

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Claude Opus 5.5 on Claude Code
