verdict: PASS

Re-verification of PR #135 (ticket #109) at `be9cc3fd667645aece2f5cc7846f03be82a36c2c`, in a private worktree,
read-only, nothing posted or edited on GitHub. Detaching at that SHA and printing HEAD gave
`be9cc3fd667645aece2f5cc7846f03be82a36c2c`; the working tree stayed clean throughout.

## 1. The delta since 9454e38 is only what the brief names

Six commits: `dbb0212`, `dfdf587`, `1cfb14b`, `0a277f2`, `e9b70cc`, `be9cc3f`.
The stat over `9454e38..be9cc3f`: 9 files, 13 insertions, 13 deletions, every one a single-line replacement.
Read whole at `-U0`. Every changed line is one of the three named changes:

- Wording (dbb0212/dfdf587): `patches/pstack/architect/SKILL.md.patch:15` and `template/.agents/skills/architect/SKILL.md:38`
  turn the eco judge's "defects" into "findings"; `docs/agents/ledger.md:38` counts "one writer" among the nine
  outcome-changing delegates.
- Eco keeps `interrogate`: removal of "Not run in `eco` (Ticket step 0, "The tier")." from
  `docs/knowledge/core/MANUAL.md:98` and `template/docs/agents/review-ladder.md:8` (and the generated
  `template/docs/factory918/MANUAL.md:79`); addition of "`interrogate`'s reviewers" to the fresh-lane list in both
  MANUALs and both DECISIONS P109 rows; removal of "Opening a PR's `interrogate`" from ticket.md step 0's override
  list and of "you skip `interrogate` wherever a step launches it (Feature step 7, Opening a PR's subagent line,
  review-ladder rung 3), and the judge stands in" from item 2.
- Trail review: ticket.md's closing paragraph drops "So an eco ticket launches at most one writer, ... and its brief
  to the trail review asks for that count against this list" and replaces it with the log-every-launch sentence plus
  "gives it no list, ceiling or count to compare against; you compare its list with this tier's rule in your hand-back".
  Both DECISIONS rows carry the same, plus the dated amendment sentence.

Nothing else moved. No script, test, hook, profile or generated page changed in this range.

## 2. Reading step 0 as an eco owner

Would I launch `interrogate` wherever safe launches it? Yes. `ticket.md:10` now lists the overrides as "(Feature steps
4 and 5, the `how` fan-out, `spec-review`'s fix lane)" with no `interrogate` among them; item 2 ends at "Feature step 4
briefs one writer, never an arena."; and `ticket.md:17` reads "In both tiers the writer, `blast-radius`, both reviewers
every round, the architect judge, `interrogate`'s reviewers when a step launches it, and the trail review are fresh
lanes". The launch points it would reach are unconditional: `playbooks/feature.md:16` "If the design is contested,
`interrogate` before shipping."; `playbooks/opening-a-pr.md:31` "A subagent that opens a PR runs `interrogate` and
`/deslop`."; `template/docs/agents/review-ladder.md:8` "Multi-tier review on this account's models." No tier clause on
any of the three.

Would I brief the trail review with a list, count or ceiling? No. `ticket.md:17`: "The trail review's brief asks it to
list every lane launch it finds in the trail and the transcripts, and gives it no list, ceiling or count to compare
against; you compare its list with this tier's rule in your hand-back, after it reports."

Grepped for anything still skipping `interrogate` in eco: every `interrogate` hit and every word-boundary `eco` hit
across `template/`, `docs/knowledge/core/`, `docs/agents/`, `AGENTS.md`, `CLAUDE.md`. The only surviving "not run in
eco" strings are in `research/` (the read-only corpus) and in `docs/FACTORY-SPEC-v2.md` with its generated
`docs/knowledge/spec/` page, which quote the pre-tier spec edit and predate #109. Neither is a playbook an owner acts
on. No issue.

## 3. Safe is unchanged

Diffed the playbooks, `template/docs/agents/review-ladder.md`, `template/AGENTS.md` and `AGENTS.md` against a9ebdac:
5 files. Every inserted clause is either the tier rule itself (ticket.md step 0's new block) or scoped to `eco` inside
the sentence that contains it: ticket.md step 5 "In `eco` you read them yourself", step 6 "In `eco` the architect step
is one runner and an adversarial judge", step 8 "in `eco` you run `spec-review` yourself", the Reply line "In `eco` it
is step 0's one page", Design hole step 2 "in `eco`, one runner and the judge", autopilot-stack step 1 "whose first
line is `Tier: eco` when the root's tier file read `eco`", review-ladder rung 1 and both AGENTS.md lines "(in `eco` its
two reviewers are the fresh context, Ticket step 0)". With no tier file the digest carries no `Tier:` line, the run is
`safe`, and `safe` is "every step as written". `template/.agents/skills/architect/SKILL.md:36` adds only "unless the
caller's tier asks for one runner (below)" to the design-it-twice rule. No other playbook under
`template/.agents/skills/poteto-mode/playbooks/` changed in this range.

## 4. Leading-witness test on the judging lanes' briefs

Every sentence this PR puts into a judging lane's brief, checked for an expected result, a count, a list, an output cap
or a limit on reading:

- Architect cross-judge (`architect/SKILL.md:38`): "briefs it to read that one candidate adversarially against the
  rubric and the grounding and to return its findings, not a base; the findings stand in for the second candidate."
  "findings" carries no verdict, where the earlier "defects" presupposed one; "not a base" names the output's kind, not
  its size. Clean.
- ticket.md item 2: "briefed to read that candidate adversarially against the ticket, the grounding and `architect`'s
  design red flags and to return its findings, which you settle in the synthesis." Clean; "which you settle" replaced
  "which you fix", which had assumed the findings were real.
- Trail review (`ticket.md:17`): quoted above. "list every lane launch it finds in the trail and the transcripts" tells
  it to look everywhere rather than capping it; no list, ceiling or count is handed over; the comparison happens in the
  owner's hand-back after the reviewer reports. Clean.
- Reviewers (`ticket.md` item 3): "its two reviewers launched by you with their briefs' paths and polled per the poll
  rule ... the two reviewers are the fresh context." No expectation about what they will find. Clean.
- The PR adds nothing to `show-me-your-work`'s "Cross-model review of the trail" (`SKILL.md:64-75`) or to
  `spec-review`'s brief scripts; both are unchanged since a9ebdac, and neither carries an expected count.

## 5. Gates

| Command | Result |
|---|---|
| ShellCheck over the six globs of `AGENTS.md:38` | `ShellCheck 0.11.0, files checked: 26`, exit 0 |
| `bash tests/hooks/delegation.sh` | `ok 76 assertions`, exit 0 |
| `python3 tools/build_knowledge.py` | `knowledge files: 119 -> docs/knowledge`, then a clean status |
| `python3 tools/check_knowledge.py` | `knowledge ok: 119 files`, exit 0 |
| `./factory918.sh sync` | `vendored: 72 skills.`, then a clean status |
| `gh run view 35917699843 --json headSha,conclusion,status,workflowName` | `{"conclusion":"success","headSha":"be9cc3fd667645aece2f5cc7846f03be82a36c2c","status":"completed","workflowName":"Factory CI"}` |

The brief's ShellCheck line is the short one (five globs, 24 files); it also passes, exit 0. The repository's own
`AGENTS.md:38` names six globs and 26 files, which is what the table reports.

## 6. #109's body

The body is 101 lines. The amendment is one paragraph at the end, opening "Amended 2026-09-23 by the agent in #135
(Manuel's ruling, relayed by the root session)". It quotes Manuel verbatim, "This sounds EXACTLY like prioritizing the
verification step pass over the philosophy of the feature/factory itself. And like prioritizing a predicted result of a
feature over the actually designed feature itself." and "Tail review is probably a 'No expected list' desire as well.",
and moves exactly the one cell it names, C7's eco cell, from "not run; C2's judge stands in" to "its reviewers, as in
safe". It states explicitly that C1's `why` investigators and C3's writer arena stay dropped and that "Table B's
assertions do not move". Tables A and B and rows C1 to C6, C8 and C9 are untouched. The earlier verifiers' files in
`../135-9454e38/` do not hold the body verbatim, but `worker-audit.md:63` cites C7 against `ticket.md:12`, which is
where the skip clause lived at 9454e38 and where it is now gone; nothing in those files contradicts the body as it
stands.

## Issues

None.

## Notes

- The amendment is appended as prose rather than applied into the table. A reader who reads only row C7, the contract
  bullet at line 90 ("The writer, blast radius, both reviewers every round, the architect judge and the trail review
  stay fresh lanes") or test-list item 3 ("showing an eco ticket keeps at most the writer, ...") still sees the
  superseded text and must reach the last paragraph to learn it was replaced. The amendment does name all three ("The
  contract's list of fresh lanes gains `interrogate`'s reviewers", "Test list item 3 becomes that comparison in the
  hand-back rather than a proof of a ceiling"), which is why this is a note and not an issue, and appending a dated
  amendment is the shape Factory918 uses.
- Criterion 4 on #109 still reads "a run under `eco` ... would launch, per ticket, at most the writer, the
  blast-radius lane, the runner and judge, two reviewers per round and the trail review". After the ruling that list is
  no longer the tier's rule, since `interrogate`'s reviewers are now in it. The amendment reclassifies the "at most"
  list as a prediction rather than a constraint, so the criterion is satisfiable as amended, but the criterion's own
  words were not edited.
- `docs/FACTORY-SPEC-v2.md:224` and its generated page `docs/knowledge/spec/FACTORY-SPEC-v2/09-5-skill-manifest.md:47`
  quote the original spec edit for `opening-a-pr.md` ("runs `interrogate` and `/deslop`"). That is the historical spec,
  not a live instruction, and it now agrees with the playbook anyway.
- Unchanged from the first verification: a tier file written inside a worktree's own `.claude/state/` does nothing,
  because the tier is read through the main checkout's common dir. That fails safe and is the documented design.
