# Trail review, ticket #139 / PR #142

## Attention

reviewed by Claude Opus 5

check-trail.sh, verbatim:

```
ok: 10 rows in order inside the run 2026-09-23T21:02:36Z to 2026-09-23T22:35:29Z
```

The trail is honest: every row maps to a real action, the SHAs, comment links and ticket amendments all resolve, and the three amendments on #139 match the three review rounds one for one. The flags below are about what the rows decided, not whether they happened.

1. **The shipped regex and the pinned SKILL.md sentence were never reviewed.** (row 2026-09-23T22:35:18Z, "round 3 closed act-on items: 0 with four fixes marked") Round 3's reports were written against `##+[^a-z]*writer[^a-z]*flags?`; the fixes that followed (a68ef03, f494d2b, 42476d3) replaced it with the far looser `^([ \t>]|[-*+]|[0-9]+[.)])*##+.*writer.*flag` and added a word-for-word `has` pin on a new SKILL.md sentence. The three-round rule stops there, so no reviewer saw either. `fix3/report.md` asks for exactly this ("The pinned SKILL.md sentence is new, and no reviewer has seen its wording. Read it once"), and that request does not appear in the trail. **Ask:** read `template/.agents/skills/spec-review/SKILL.md:29` and the guard's final match before merge.

2. **CI has never run on the head this PR would merge from.** (same row) The row records it honestly — last green CI 35927261638 at bc5a7e6, `mergeStateStatus` DIRTY, PR marked ready anyway — but bc5a7e6 is three commits before 9abbcca, and those three commits are the final regex, the SKILL.md pin and the test rewrap. The PR body also says mawk was not run locally and CI is where mawk runs. The debt was handed to the root with no owner named. **Ask:** confirm a green CI run at the rebased head before merge; do not read the bc5a7e6 run as coverage of the shipped match.

3. **Criterion 2's byte-for-byte proof predates the shipped code.** (row 2026-09-23T21:21:10Z, "accept the writer's diff") The `cmp`/`diff -r` harness against #140's head ran in the writer lane at 5f0c725. The match then broadened three times (833fcae, 1f26c5e, f494d2b), each time enlarging the set of bodies that can reach the guard. The PR body's Verification still cites that run as the proof for criterion 2 without saying which commit it covers. In-suite D9 and D12 cover two bodies, so the residual risk is small, but the cited evidence is not evidence for what ships. **Fix:** rerun the harness at head, or reword that bullet to name 5f0c725 and lean on D9/D12.

4. **The round-3 loosening dismisses false positives with an argument the refusal message does not support.** (row 2026-09-23T22:22:50Z, "a false positive refuses loudly with a correctable message, which is Manuel's preferred failure") `##+.*writer.*flag` now matches `## Rewriter flagging policy`, `## The writer should flag risks`, and any fenced Markdown example of this very feature quoted in a future ticket body — and this repo's tickets quote the skill constantly. The refusal's message names only the one readable heading form, so a writer whose ticket has no flags at all is told to write a flag list. The sweep over 12 live ticket bodies is real evidence, but it is evidence about bodies written before this rule existed. **Fix or dismiss:** one clause in the message for the no-list case ("if this line is an example, reword it"), or record the accept in P139 in those words rather than as `## Writer flag handling`, which is the narrow case, not the broad one.

5. **Skipping the design pass was the wrong call, and the trail shows the cost.** (row 2026-09-23T21:04:38Z, "skip architect runners... one conditional in one script, no new state file") Every one of the three rounds found another heading shape that same conditional missed, each costing a fix lane, a dated ticket amendment and a P139 rewrite; round 3's own row admits the pattern ("each round had loosened the match one class at a time"). A one-line regex over free-form human prose is a small diff but a large design surface. **Fix:** a line in `docs/agents/ledger.md` — when the rule is a pattern over text a human types, enumerate the shape space before the first lane, or start at the loosest rule and narrow.

6. **A writer act-on dismissed in one line came back as a review finding.** (row 2026-09-23T21:21:10Z) The writer's report asked outright whether `## Writer flag handling` with no list should be refused or narrowed. The row dismisses it with a why aimed at the other items. One round later that exact question returned as round 2's P1 (the fenced one-`#` comment) and forced a grammar change. **Dismiss**, the outcome was right — but the row's `why` does not cover the item it dismissed, which is the one thing a reader of the trail would want there.

7. **The ticket's table D and the suite disagree by one row.** (row 2026-09-23T21:27:49Z, round 1) The amendment announces "New row D11"; the suite has D11 and D11b (`- ###` and `1. ###`). Every other row is named in the ticket. **Fix or dismiss:** one clause on the round-1 amendment, or accept that D11b is D11's second half.
