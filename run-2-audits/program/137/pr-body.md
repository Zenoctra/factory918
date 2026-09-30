Our own review briefs told the reviewer what result to expect, capped its report and forbade it to read or run anything. This PR removes those lines and replaces the reading ban with a permission, as Manuel ruled on 2026-09-23 in #137.

## Problem

The audit of 2026-09-23 found five kinds of leading wording in the two briefs `review-brief.sh` writes and in the text our patch adds to `spec-review/SKILL.md`:

1. The definition ended "Zero items is the expected result for a clean change." It stated a count up front, and zero is the count that ends the round. P18 and `review-ladder.md` repeated it.
2. Each brief opened by forbidding the reviewer to read anything beyond the brief, unless a finding already needed the code around a hunk, and forbade running anything. A reviewer could not read in order to find a finding.
3. The reading-pack sentence allowed opening the repository only for one function or section, not the file.
4. Both item-form lines capped the report at 400 words, which also caps the number of items.
5. The judge step told the judge that a report of nits means the code is probably fine and that more than five Act on items means it is not filtering.

Manuel: "Zero items is expected is absolutely HORRENDOUS. [...] You are guiding the witness."

## Fix

- The definition drops its last sentence. Nothing replaces it, so no brief states how many items to expect.
- Each brief's first line is now "You may open any file in the repository and run read-only commands, such as grep or the test suite."
- The reading-pack sentence ends "open the repository for what the pack does not carry."
- Both item-form lines lose the reading limit and the word cap.
- The judge step says to sort each item on its merits. Upstream `lead-judgment.md` is untouched, as Manuel asked.
- Manuel's quote "An edge case outside the intended path being unsupported is not a flag." stays word for word. After the five quotes, both briefs carry "An edge case that proceeds silently fails open: file it under `## Fails open`."
- Later rounds are exactly as blind as before. The test now pins the `## ` heading list of a round-two brief and a fix-only brief to what the script wrote at the base.
- `SKILL.md` (through `patches/mattpocock/spec-review.SKILL.md.patch`), `review-ladder.md`, `SOURCES.md` item 6 and P18 say the same. P18 carries a dated amendment that quotes Manuel.
- `no-stale-wording.sh` refuses each removed phrase. The fixture CI step checks the new definition as a whole line and fails on the old cap or reading ban.

Every new sentence was checked against one test: it states no expected count, no cap on length or items, and no limit on reading or on read-only commands.

The frozen eval rounds under `tests/eval/reviewer/` are not edited. `rebuild.sh` runs `review-brief.sh` as it stood at each round's recorded commit, so the frozen briefs still match (`rebuild: pr94-r1: identical`). Rebuilding them with the new briefs is #138's job.

## Overlap

```
go: autopilot-stack
#135 feat/eco-tier: SOURCES.md docs/knowledge/core/DECISIONS.md template/docs/agents/review-ladder.md template/docs/factory918/DECISIONS.md
#136 feat/risk-dispositions: .github/workflows/factory-ci.yml SOURCES.md docs/knowledge/core/DECISIONS.md patches/mattpocock/spec-review.SKILL.md.patch template/.agents/skills/spec-review/SKILL.md template/.agents/skills/spec-review/scripts/review-brief.sh template/docs/factory918/DECISIONS.md tests/spec-review/no-stale-wording.sh tests/spec-review/review-brief.sh
```

This PR stacks on #136. `overlap.sh 137` printed `base: origin/feat/eco-tier`, from its last tie-break (neither #135 nor #136 contains the other, so it takes the lower PR number). The stack owner overrode it: this PR rewrites `review-brief.sh`, which #136 changed, and shares only records and `review-ladder.md` with #135.

## Verification

- Criterion 1 (no expected count, no cap, no reading or read-only limit; each line gone or replaced; the stale-wording check refuses each): `bash tests/spec-review/no-stale-wording.sh` prints `ok: no stale wording` over `template` and `docs/knowledge/core`, and the phrases are in its list.
- Criterion 2 (the quote word for word, then the fails-open line): `bash tests/spec-review/review-brief.sh` asserts in both briefs that the edge line sits two lines after the fifth quote and the pack sentence two lines after it. `ok 1836 assertions`.
- Criterion 3 (later rounds as blind as today): the same test pins the `## ` heading lists of a round-two and a fix-only brief, Standards and Spec, to the lists the base script wrote. The diff does not touch the settled or fix sections.
- Criterion 4 (P18 amended with a dated line quoting Manuel): commit "Amend P18".
- Criterion 5 (the test asserts the new text in both briefs): the first commit changes only the test. Against the base script and `SKILL.md` it fails with `FAIL SKILL.md step 4 carries the edge line`.
- ShellCheck at the pin over 24 files: pass. `tests/shellcheck/gate.sh` ok 17, `tests/hooks/delegation.sh` ok 55, `tests/spec-review/review-comment.sh` ok 298, `tests/poteto-mode/overlap.sh` ok 57.
- `./factory918.sh sync` and `python3 tools/build_knowledge.py` each leave `git status` clean. `python3 tools/check_knowledge.py` prints `knowledge ok: 119 files`.
- The fixture flow runs in CI.

Closes #137
🤖 Generated with [Claude Code](https://claude.com/claude-code)
Claude Opus 5.5 on Claude Code
