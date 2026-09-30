verdict: PASS

# Slice: the briefs a reviewer actually reads — PR #140 (ticket #137) at e710e99

For a person: I generated all five kinds of review brief from the PR's script and from the patch base's script against byte-identical scratch repositories, then diffed them and read every head brief end to end. Every brief changed in exactly the five ways ticket #137 asked for plus the fails-open line, and no brief that a reviewer reads now states an expected number of findings, caps its length, or limits what it may read or run.

## Setup

- `git rev-parse HEAD` -> `e710e99ce4293ff2d057b7c9d639a82e97c88f04`; `git merge-base --is-ancestor 6e5c539 HEAD` -> exit 0.
- Both versions of the skill extracted whole with `git archive HEAD|6e5c539 template/.agents/skills/spec-review`, so each run used the script, `SKILL.md` and `reading-pack.sh` of its own commit.
- Two scratch git repositories under the session scratchpad, built once with fixed author and committer dates and used by both versions, so the two sets of briefs differ only by the script. Commits: `023188a` (layout), `9ea972e` (the work for #137), `e35123f` (fix the name check for #137); a clone with `46412f3` adding `.claude/hooks/guard.sh` for the cross-cutting case. `tests/spec-review/fake-gh.sh` copied onto `PATH` as `gh`.
- The skill lives outside the scratch repositories, so `git rev-parse --show-toplevel` still resolves to the repository under review and the skill's own files never enter the diff.

## The five briefs, generated at the SHA

All five ran with exit 0 and empty stderr. Drivers: `build.sh` and `run.sh` in this session's scratchpad under `v140/`.

- Round one, Standards and Spec: `review-brief.sh 023188a --ticket 137` -> `ticket: #137`, `round: 1 of 3`, both briefs written.
- Round two, whole diff, after a round one with dispositioned items: same fixed point with `--previous` holding a round-one comment carrying `round: 1 of 3`, `act-on items: 2`, `reviewed: 9ea972e...`, and Noted/Dismissed items with `cites:` fields -> `round: 2 of 3`, `settled: carried 2, dropped 0 without a citation`; `## Settled in earlier rounds` present.
- Fix-only round three (#106): `review-brief.sh 9ea972e --ticket 137 --previous <r1+r2>` where round two's comment carries `fix only after 9ea972e...` -> `round: 3 of 3`; `## The fix under review` present in both briefs.
- A brief with a reading pack (#107): every one of the five carries `## Reading pack` after the diff (round one's Standards brief carries `### src/app.sh, whole, 8 lines` with the file at HEAD).
- Cross-cutting with blast-radius risks (#108): `review-brief.sh e35123f --ticket 137 --blast-radius blast.md` over the hook commit -> `## Blast radius` with both risks and their `accepted:` and `fixed:` dispositions, and the risk sentence appended to the Spec brief's `## Walk` bullet.

## (a) an expected number or kind of result — none

Grep over all eight head briefs for `expected`, `zero items`, `clean change`, `at most`, `no more than`, `probably`, `typical`, `usually`, `rarely`, `most changes` returned nothing outside Manuel's quoted sentences and the smell-baseline bullet names (`Data Clumps`, `Middle Man`). The sentence the audit named is gone:

- base: `A hard finding is one of two things: ... it is the design. Zero items is the expected result for a clean change.`
- head: `A hard finding is one of two things: ... it is the design.`

`count_rule` ("End the report with exactly one line `hard findings: N`...") asks for a count of what was found; it names no expected value. Unchanged from `6e5c539`.

## (b) a cap on words, items or effort — none

`Under 400 words.` is gone from the item-format sentence of both briefs, in all five scenarios. Grep for `400`, `words`, `concise`, `short`, `brief` over the head briefs returns no cap.

## (c) a limit on reading or read-only commands — none

Both bans are gone and replaced:

- Line 3 of every brief, base: `Read nothing beyond this brief unless a finding needs the code around a hunk, and then read that one function or section, not the file. Run nothing.` -> head: `You may open any file in the repository and run read-only commands, such as grep or the test suite.`
- The reading-pack tail, base: `...open the repository only for what the pack does not carry, and then read that one function or section, not the file.` -> head: `...open the repository for what the pack does not carry.`
- The same ban repeated inside the item-format sentence of each axis is gone.

The only remaining "only" is in the fix-only paragraph, `walk only the steps these commits touch, and report only what these commits get wrong`. That is a statement of what the round's diff is, not a limit on reading, and it is byte-identical to `6e5c539`.

## (d) anything about earlier rounds beyond what 6e5c539 carried — nothing new

The round-two and round-three briefs were diffed against `6e5c539`'s briefs for the same comment history. `## Settled in earlier rounds` and `## The fix under review`, their paragraphs and their carried items are byte-identical; the `## ` heading sets are identical. The only changed lines in those two briefs are the same five the other briefs changed.

## Manuel's quote and the fails-open line

Present word for word, exactly once, in all eight briefs, as the line `- Manuel: "An edge case outside the intended path being unsupported is not a flag."`, the fourth of the five quotes. The fails-open line ``An edge case that proceeds silently fails open: file it under `## Fails open`.`` follows the five quotes, three lines after that quote (fifth quote, blank, line) in every brief: for example r1-standards.md line 81 and line 84.

## The full changed-sentence list, base vs head

The unified diff of all eight briefs is the same five changes in every one, and nothing else:

1. Brief line 3: the read-and-run ban replaced by the reading sentence.
2. `## Report` definition: `Zero items is the expected result for a clean change.` deleted.
3. After the five quotes: the fails-open line added, followed by a blank line.
4. Reading-pack sentence: the tail `only for what the pack does not carry, and then read that one function or section, not the file.` replaced by `for what the pack does not carry.`
5. Item-format sentence of each axis: the trailing `Read nothing beyond this brief unless ... not the file. Under 400 words.` deleted.

Nothing else moved: commit list, changed files, blast radius, diff, reading pack, settled section, fix section, ticket body, ticket comments, standards, smell baseline, heading bullets, walk bullet, risk sentence, step rule, spec rule, report path and count rule are byte-identical.

## Checks run

- `bash tests/spec-review/no-stale-wording.sh` -> `ok: no stale wording`, exit 0.
- `bash tests/spec-review/review-brief.sh` -> `ok 1836 assertions`, exit 0.

## Issues

None.

## Notes

1. The fails-open line follows the block of five quotes, not the fourth quote itself; the fifth quote sits between them. That is what ticket #137 asked for ("After the five quotes, add one line"), and `tests/spec-review/review-brief.sh:228` pins it to two lines after the fifth quote.
2. `tests/spec-review/review-brief.sh:226` (`blind_rules`) is called on the round-one briefs and on the reading-pack briefs, not on the round-two, fix-only or cross-cutting briefs. Those come from the same `common`/`report_rules` code paths and I confirmed all three by generating them, so coverage is adequate; adding the call to those three would cost nothing if a later ticket touches the file.
3. The `blind_rules` refusal list checks `"Zero items"` but not the lowercase `"zero items"`. `tests/spec-review/no-stale-wording.sh` checks both, so the pair is covered.
4. `tests/eval/reviewer/rounds/*/review/*-brief.md` still carry the old wording. These are frozen briefs of past rounds, rebuilt by `tests/eval/reviewer/rebuild.sh` with the script as it stood at each round's `script_at`, so they must keep it. Correctly outside `no-stale-wording.sh`'s scope (`template` and `docs/knowledge/core`).
5. `docs/knowledge/core/DECISIONS.md:105` (P107) and its generated copy quote the phrase `"Read nothing beyond this brief"` while recording an option #107 rejected. It is a historical record, not reviewer-facing text, and the gate's pattern includes `unless`, so it does not trip. Left as is, which reads correct.

Verified by Claude Opus 5 (1M context) in Claude Code.
