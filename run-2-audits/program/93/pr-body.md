## Why

The review runs three rounds and round three's fixes ship unreviewed whatever they are. On PR #92 that was safe: the two Would-break items were found in round one and their fixes were reviewed by rounds two and three. On PR #87 it was not: round three still found Would-break items in the happy path and their fixes, one a behavior change, shipped unreviewed. Manuel's decision on #93: a fix for a hard bug on the documented path is never left unreviewed, a fail-open fix at round three may be, no rule compares hard counts between rounds, and five rounds of hard bugs stop for a report.

This PR makes a round whose judgment marks a `## Would break` finding `fixed:` print one line, `would-break fixed after <sha>`, naming the commit the round reviewed. `review-brief.sh` reads that line from the last review comment, allows the round after it (four, then five) as a fix-only round whose fixed point must be that commit, and refuses a sixth. A PR that ends at round three prints exactly what it printed before. The mechanism was designed from a scenario table that is the ticket's `## Testing decisions` (two architect candidates, one synthesized); the tests were written from it before the scripts (commit order: tests, scripts, prose, records).

## Scope

- `template/.agents/skills/spec-review/scripts/review-brief.sh`: writes `git rev-parse HEAD` to `<dir>/reviewed` beside `<dir>/round` in both forms; cuts the deciding comment (the last of the history after the restart slice) and reads from it the `would-break fixed after <sha>` line, whether that round had a spec, and its Act on lines ending in `fixed:`; the round parse accepts `of 3` and `of 5`; the gate replaces the fourth-round refusal: a malformed line is refused first (`FM`), a sixth round always (`F6`), a round past three that does not follow a comment carrying the line is refused with the existing message at round four (`F4`, byte-identical) and a new one otherwise (`F5`), then the named commit must resolve (`FR`) and be the fixed point (`FP`), and a fix-only round with no ticket after a round with a spec is refused (`FT`); `cap=3; [ "$round" -le 3 ] || cap=5` decides the `round:` line; from round four both briefs carry `## The fix under review` (`fix_rule`, then the fixed items) after `## Changed files`.
- `template/.agents/skills/spec-review/scripts/review-comment.sh`: before any output, resolves each `fixed:` Act on item's report heading through `specs()` (the two lines the `hole:` check uses); with a Would-break fix and no hole, refuses a missing or malformed `<dir>/reviewed` with the content shown; prints `restart`, else `would-break fixed after <sha>`, then `round: N of <cap>`, then `act-on items:` last; the summary line and the count are unchanged.
- `template/.agents/skills/spec-review/SKILL.md` (through `patches/mattpocock/spec-review.SKILL.md.patch`): step 1 says the cap and the fix-only round; step 4 carries `fix_rule` word for word; step 5 gains the judgment paragraph with the two stops (three: look for the cause; five: stop, report, mark unfinished, wait) and the `fixed:` bullet says a Would-break fix is reviewed once more; step 6 names the line and the new refusal.
- `template/.agents/skills/poteto-mode/playbooks/ticket.md`: step 8 routes a comment carrying the line to a new `### Would-break fix` section (the fix-only command, the round-five report and draft mark); no step renumbered.
- `template/.agents/skills/poteto-mode/playbooks/babysit.md` and `template/.agents/skills/babysit/SKILL.md` (through their patches): the cap sentence, byte-identical in both, pinned by the brief test.
- `template/docs/agents/review-ladder.md` rung 1 (one sentence), `docs/knowledge/core/MANUAL.md` (the merge checklist item), `SOURCES.md` items 4, 6 and 12, `tests/spec-review/no-stale-wording.sh` (`at most three rounds` retired).
- `tests/spec-review/review-brief.sh` (476 to 648 assertions) and `tests/spec-review/review-comment.sh` (150 to 192), one assertion per cell of the ticket's tables A and B, labelled by cell; `fragment()` holds the `cap=3;` line together across both scripts.
- Records: P20 amended, P30 (the round-five stop), one ledger line, generated copies rebuilt.

Out: a Would-break count in the comment (criterion 3 forbids the comparison it invites); a `reviewed:` line on every comment (criterion 4); a second line form for round five; reading the ticket from the PR's closing references at round four (`--ticket N` is the command).

## Tradeoffs

- One conditional machine line in the comment, in exchange for byte-identical tails on every PR that ends at round three. Three existing assertions move, all in fixtures that already marked a Would-break item `fixed:`, each named with its cell in the ticket.
- The cap digit depends on the round only (`of 5` from round four), not on the judgment, so both scripts derive it from one line and the round-three comment still reads `round: 3 of 3`; babysit reads the line, not the digit.
- The fixed point at rounds four and five is enforced by the script (`FP`, `FR`), because a wrong one fails toward the wrong review: the original fixed point re-reviews the whole diff at full cost, a later commit skips part of the fix.
- A fix-only round with no ticket after a round with a spec is refused, not warned: the fix commits rarely name the ticket, and a hard-bug fix reviewed on the Standards axis alone is the silent path.
- `<dir>/reviewed` is refused only when the line is needed, and the refusal says to write the commit by hand rather than rerun the brief, since a rerun after the fixes would record the fixing commit as the reviewed one.
- Round five's Would-break items are fixed and marked as at any last round, and the report names those fixes as unreviewed; leaving them unfixed would make babysit read a nonzero count as a blocker to fix here, the opposite of the wait (P30).

## Blast Radius

Not a cross-cutting diff: no path under `.claude/hooks/`, no `settings.json`, nothing under the `factory918` skill (`review-brief.sh`'s predicate), so the review brief needs no grounding section. What the change reaches, as read before writing it:

- Every `spec-review` round here and in every applied project. `review-brief.sh` writes one more file in the review dir on every run and reads the last comment's line only past round three; `review-comment.sh` reads the fixed items' headings on every run and prints one more line only when a Would-break item was fixed and no hole is marked. A round with no Would-break fix prints byte-identical lines, and the three `F4` assertions pass unchanged.
- Babysit (both copies) and the merge checklist: one sentence each, reading the same tail lines.
- `sync`: `spec-review/SKILL.md` and both babysit files change through their patches; `./factory918.sh sync` leaves the tree clean.

The one fact it is safe because of: every new print and every new refusal sits under a condition that is false for a round with no Would-break fix (`wb_first` empty, `round` at most 3), so the 476 and 150 assertions at the base pass unchanged except the three the ticket names, and the CI fixture's round-one brief is untouched.

Risks: a review dir written by an older `review-brief.sh` (no `<dir>/reviewed`) refuses at the comment when a Would-break item is fixed, with the message saying what to write; a PR whose round three already fixed a Would-break item before this merges reads as review-ready today and would not after, which is the intended change.

## Overlap

```
go: autopilot-stack
#94 feat/design-artifact-on-ticket: SOURCES.md docs/knowledge/core/MANUAL.md template/.agents/skills/poteto-mode/playbooks/ticket.md template/docs/factory918/MANUAL.md
#96 feat/shellcheck: SOURCES.md template/.agents/skills/spec-review/scripts/review-brief.sh template/.agents/skills/spec-review/scripts/review-comment.sh tests/spec-review/review-brief.sh tests/spec-review/review-comment.sh
#99 feat/design-hole-restart: SOURCES.md docs/knowledge/core/MANUAL.md patches/mattpocock/spec-review.SKILL.md.patch patches/pstack/babysit/SKILL.md.patch patches/pstack/poteto-mode/playbooks/babysit.md.patch template/.agents/skills/babysit/SKILL.md template/.agents/skills/poteto-mode/playbooks/babysit.md template/.agents/skills/poteto-mode/playbooks/ticket.md template/.agents/skills/spec-review/SKILL.md template/.agents/skills/spec-review/scripts/review-brief.sh template/.agents/skills/spec-review/scripts/review-comment.sh template/docs/agents/review-ladder.md template/docs/factory918/MANUAL.md tests/spec-review/no-stale-wording.sh tests/spec-review/review-brief.sh tests/spec-review/review-comment.sh
#101 feat/spec-walk-risks: SOURCES.md patches/mattpocock/spec-review.SKILL.md.patch template/.agents/skills/poteto-mode/playbooks/ticket.md template/.agents/skills/spec-review/SKILL.md template/.agents/skills/spec-review/scripts/review-brief.sh tests/spec-review/review-brief.sh tests/spec-review/review-comment.sh
```

The step 1 check printed `base: origin/feat/spec-walk-risks` (PR #101, ticket #91), exit 0, and this branch was made from its head `d8e382c`. This branch stacks on PR #101, the top of the chain, since it changes the round logic PR #99 introduced and the brief PR #101 last touched; the program's root rebases the chain. The `--diff` run at step 8 exited 0 before this PR existed; a rerun after it opens may exit 1 with an empty closing reference, because GitHub links `Closes #N` only against the default branch (ticket #100); the root does the one retarget through `main` that links the ticket.

## Verification

Each acceptance criterion of #93 is quoted, then how it was proven. The ticket's `## Testing decisions`, two scenario tables and a contract posted 2026-09-22, is the spec for the mechanism; the tests were written from the tables before the scripts (commits `41ce420` tests, `27c43af` scripts, `1998c69` prose and patches), one assertion per cell, labelled by cell in both test files.

- "A round whose Act on items include a Would-break fix is followed by another round, past three, up to five; a round whose fixes are all Fails-open items, prose, or standards breaches may be the last. `review-brief.sh` reads the kind of the fixed items from the previous round's comment and refuses a sixth round." Table B cells 3A to 3D (the line printed for a Standards and for a Spec Would-break fix), 2B and 2C (a Fails-open or Standards-breaches fix prints no line), 6B (a ticketed Would-break item prints none); table A cells 3A (round four allowed after the line), 9A (round five), 2A and 8A (refused without it), 11A and 11B (the sixth refused after a plain or a lined round five). The kind is read from the comment's line, not from the orchestrator (15A: the line in an earlier comment does not count).
- "A round past three reviews the fix only: its fixed point is the commit the previous round reviewed, and the Ticket playbook and `spec-review` say so." Table A 3A and 9A assert the Standards brief's `## Commits` holds only the fix commit and both briefs carry `## The fix under review` with the fixed items; 4A and 10A assert the original fixed point, `HEAD` and round three's commit are refused at rounds four and five with the message naming the required commit; 5A a commit that does not resolve. Prose: `spec-review/SKILL.md` step 1 and `ticket.md`'s `### Would-break fix` section, read at the diff.
- "No rule compares hard-finding counts between rounds. The orchestrator's prose in `spec-review` step 5 says: at round three ... continue to five; at five ... stop, write a report ... mark the PR blocked as unfinished ... wait for the human ..." `spec-review/SKILL.md` step 5, the paragraph after the design-hole paragraph, read at the diff; no script compares counts, and the comment prints no Would-break count (the summary line is byte-identical in every `accept` expectation). Babysit reads `round: 5 of 5` with the line as a wait (both copies, read at the diff).
- "`babysit`'s merge-ready condition reads the same comment lines and is unchanged for a PR that ends at round three." Both babysit copies read `act-on items:`, `round:` and the new line only; the brief test pins the sentence in both files. Table B 1B and 2B print `round: 3 of 3` and today's tail; the three `F4` assertions pass byte for byte; the 476 and 150 base assertions pass unchanged except the three named in the ticket's test list.
- "`tests/spec-review/` covers a round four with a fix-only fixed point and the round-five stop." `tests/spec-review/review-brief.sh` cells 3A, 4A, 9A, 10A, 11A; `tests/spec-review/review-comment.sh` cells 3C, 3D; the writer also ran both scripts end to end in a throwaway project layout through rounds three, four, five and the refused sixth, and its printed lines are in the design trail.
- "P20 amended; `docs/agents/review-ladder.md` says the same in one sentence." `docs/knowledge/core/DECISIONS.md` P20 (the 2026-09-22 amendment) and `template/docs/agents/review-ladder.md` rung 1, read at the diff.

Also run from this checkout at the head commit, each exit 0: `bash tests/spec-review/review-brief.sh` (`ok 648 assertions`, 476 at the base); `bash tests/spec-review/review-comment.sh` (`ok 192 assertions`, 150 at the base); `bash tests/spec-review/no-stale-wording.sh` (`ok: no stale wording`); `bash tests/hooks/delegation.sh` (`ok 55 assertions`); `bash tests/poteto-mode/overlap.sh` (`ok 57 assertions`); `bash tests/shellcheck/gate.sh` (`ok 17 assertions`); the ShellCheck gate over the 20 files (`ShellCheck 0.11.0, files checked: 20`, no findings) and `shellcheck -x` on the five changed shell files; `python3 tools/build_knowledge.py` then `git status --porcelain` prints nothing and `python3 tools/check_knowledge.py` prints `knowledge ok: 119 files`; `./factory918.sh sync` then `git status --porcelain` prints nothing. CI runs the same on `pull_request`.

Review: (filled after CI)

Design trail, not committed: `.scratch/program/93/` holds the `how` explanation, the two architect candidates, the synthesis note, the writer's brief and report, and the decision log.

Closes #93

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Claude Fable 5.1 on Claude Code
