# Report, ticket #137

PR #140 removes the leading wording from our review briefs. The briefs no longer state an expected count of findings, cap the report's words or items, or limit what a reviewer reads or which read-only commands it runs. Manuel's quote stays, followed by the fails-open line. CI is green, and review round one ended with `act-on items: 0`.

## Status

STACK-READY.
- Head: `e710e99ce4293ff2d057b7c9d639a82e97c88f04`. `git rev-parse HEAD` and `git ls-remote origin refs/heads/feat/unled-review-briefs` agree.
- Branch: `feat/unled-review-briefs`.
- PR: https://github.com/Zenoctra/factory918/pull/140, ready for review (no longer a draft).
- PR base: `feat/risk-dispositions`.
- Patch base: `6e5c539f44f90a341495aaf4bb3b44dd7b6e16c8` (origin/feat/risk-dispositions).
- Intended parent: #108 (PR #136).
- `Closes #137` will not link while the base is not `main`. The root owns the #100 workaround.

## Overlap

Step 1, `overlap.sh 137`, exit 0:
```
go: autopilot-stack
#135 feat/eco-tier: docs/knowledge/core/DECISIONS.md template/docs/agents/review-ladder.md
#136 feat/risk-dispositions: docs/knowledge/core/DECISIONS.md patches/mattpocock/spec-review.SKILL.md.patch template/.agents/skills/spec-review/SKILL.md template/.agents/skills/spec-review/scripts/review-brief.sh tests/spec-review/no-stale-wording.sh tests/spec-review/review-brief.sh
base: origin/feat/eco-tier
```
Root override: I branched from `origin/feat/risk-dispositions`, not the printed `origin/feat/eco-tier`. The printed base comes from the check's last tie-break. Neither #135 nor #136 contains the other, so it takes the lower PR number. That is wrong for this ticket, which rewrites `review-brief.sh`, a file #136 changed. #135 (#109) shares only records and `review-ladder.md` with it.

Step 8, `overlap.sh 137 --diff`, exit 0:
```
go: autopilot-stack
#135 feat/eco-tier: SOURCES.md docs/knowledge/core/DECISIONS.md template/docs/agents/review-ladder.md template/docs/factory918/DECISIONS.md
#136 feat/risk-dispositions: .github/workflows/factory-ci.yml SOURCES.md docs/knowledge/core/DECISIONS.md patches/mattpocock/spec-review.SKILL.md.patch template/.agents/skills/spec-review/SKILL.md template/.agents/skills/spec-review/scripts/review-brief.sh template/docs/factory918/DECISIONS.md tests/spec-review/no-stale-wording.sh tests/spec-review/review-brief.sh
```
#135 now shares four files with this PR: `SOURCES.md`, both copies of `DECISIONS.md`, and `review-ladder.md`. The root resolves them when it builds the chain.

## Criteria

1. The briefs, `SKILL.md`, P18 and `review-ladder.md` state no expected count, no word or item cap, and no reading or read-only limit, and `no-stale-wording.sh` refuses each removed phrase. Proof: the phrases were removed, and `bash tests/spec-review/no-stale-wording.sh` prints `ok: no stale wording` with all eleven phrases in its list.
2. Manuel's quote is present word for word, followed by the fails-open line. Proof: `tests/spec-review/review-brief.sh` asserts that the edge line sits two lines after the fifth quote in both briefs, including the pack and fix-only briefs, and that `SKILL.md` carries it. Result: `ok 1836 assertions`.
3. Later rounds are no less blind than today. Proof: the diff does not touch the settled or fix sections. New assertions pin the `## ` heading list of a round-two brief and a fix-only brief, Standards and Spec, to the lists the base script wrote.
4. P18 is amended with a dated line that quotes Manuel. Proof: commit e710e99.
5. The test asserts the new text in both briefs. Proof: commit 2e0043b changes only the test. Run against the base script and `SKILL.md`, it fails with `FAIL SKILL.md step 4 carries the edge line`.

## Reviews

- Round 1: https://github.com/Zenoctra/factory918/pull/140#issuecomment-5802644824. The comment's summary is `act-on items: 0` and its round line is `round: 1 of 3`. The standards reviewer ran on tier-lower and the spec reviewer on tier-upper. There were no hard findings and two Noted style points: the ban list is repeated in three files, and the heading-list helper does not skip fenced `## ` lines. No restarts.

## CI

Run 35917215163 at head e710e99ce4293ff2d057b7c9d639a82e97c88f04 concluded `success`.

## Records

- P18, reason column: "Amended 2026-09-23 (#137): the definition no longer says how many items to expect; the briefs no longer cap the report's words or items, and no longer limit what a reviewer opens or which read-only commands it runs; the judge step no longer says what a report of nits means or how many Act on items are too many. Manuel's "not a flag" quote stays word for word, followed by the fails-open line. Later rounds stay as blind as before." The row then quotes Manuel three times. The decision cell drops the zero-items sentence and names the fails-open line after the quotes.
- There is no new Provisional row (P137 was not needed), no ledger line, and no M0 line.

## Decided

- The replacement wording. The ticket said to replace or drop each line but gave no final text for most of them. I did not use the audit's proposals where they failed the no-leading test. Its item line said "under about 80 words", which is a cap. Its definition line, "the report's length follows from the diff, not from any expected count", still talks about a count. What I chose:
  - The zero-items sentence is deleted, with nothing in its place.
  - The reading sentence is "You may open any file in the repository and run read-only commands, such as grep or the test suite."
  - The pack sentence ends "open the repository for what the pack does not carry."
  - The judge step says "sort each item on its merits".
  - For the diff over 500 lines, the path is handed over "to read it from".
- I added `.github/workflows/factory-ci.yml` to the change. The fixture step grepped the old definition, so CI would have failed without it. It now matches the new definition as a whole line.
- I fixed `SOURCES.md` item 6, which described our patch as telling reviewers "to read nothing beyond it". The ticket did not list the file. The sentence became false with this change.
- The ticket names `docs/agents/review-ladder.md` as a copy to change. That file does not exist on this base, so only the template copy changed.
- Two things are left as they were:
  - P107's history mentions the old sentences as a rejected option. It is #107's record.
  - The eval runner prompt `tests/eval/reviewer/reviewer.py` is not on the ticket's settled list.
  - The stale-wording check uses the `...unless` form of the old reading ban, so P107 does not trip it.
- The frozen eval rounds were not edited. The expectation that `rebuild.sh` would stop matching was wrong. The script runs `review-brief.sh` as it stood at each round's recorded commit, so `rebuild.sh pr94-r1` prints `identical`. The PR body says this. Regenerating the rounds with the new briefs remains #138's job.

## Blocked

Nothing waits on Manuel.

## Trail

`/Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.scratch/program/137/decisions.tsv` has 10 rows. The trail review is at `.scratch/program/137/trail-review.md`, reviewed by Claude Opus 5, and check-trail printed `ok`. Its six flags were settled:
- Flags 1 and 2 were logged as late rows.
- Flag 3 was accepted.
- Flag 4 is the #135 file overlap, left to the root's chain build.
- Flag 5 was dismissed: the heading-list test runs on fixed fixtures, so a fixture that gains a heading makes it fail loudly.
- Flag 6: no ticket for the two style points.
