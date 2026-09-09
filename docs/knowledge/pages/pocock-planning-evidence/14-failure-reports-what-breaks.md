<!-- lines: 32 | source: pages/pocock-planning-evidence.md | part 14/17 | title: Pocock Planning Evidence (brief) — Failure reports (what breaks) -->

## Contents (line numbers are for the Read tool's offset)
- L6: Failure reports (what breaks)

## Failure reports (what breaks)

From `mattpocock/skills` issues, verbatim where I could get it:

**Acceptance criteria that grade nothing (#595, closed).** "We ran a 26-ticket stack through it. It has produced ~20 agent runs per closed ticket, and roughly three quarters of those are repair-loop rework. The rework traces back to the criteria, not to the implementations ... **1. The criterion passes at HEAD.** ... One of ours graded a seam that lived only on an unmerged branch: three of four criteria passed at HEAD, and the ticket was fiction. **2. The criterion grades something the ticket does not own.** ... We have four instances; one criterion carried three clauses with three different owners. **3. The criterion echoes the request instead of deriving from the artifact.** ... Killed two tickets outright." Postscript: "an 8-criteria ticket closed clean while a 9-criteria one died. Count wasn't the variable; ownership was." (The docs page attributes this stack to horizontal slicing "by layer (corpus, producer, aggregator, selector)"; that framing is not in the issue text I could read.)

**Requirements orphaned in decomposition (#924, open).** "The PRD was detailed and marked ready-for-agent, with roughly 85 user stories ... The initial split produced 16 tickets. A critical PRD invariant was that the new writers must produce the complete serving model consumed by the unchanged read APIs ... A later parity ticket explicitly excluded serving-table hydration as 'another ticket', but that ticket was never created. Acceptance relied on proxies such as job success, an active pointer, rows being present, and the live endpoint responding. Those checks passed while several UI paths were empty and some serving rows were semantically incomplete. The gap was only found in the test environment ... The issue set eventually grew from 16 to 27 tickets ... the missing serving path was a direct PRD-to-ticket omission, and several original tests were too weak to prove their PRD claims."

**Detail loss between grill and spec (#341, open, 16 comments).** "Details frequently generalize into weaker summaries like 'persist sessions' or 'support retry,' allowing implementation drift ... Workflow relies on compressed prose and conversational memory with no deterministic way to verify whether answers were omitted, constraints weakened, or issues cover all decisions." The docs page for grill-with-docs adopts this: "Precise answers (ordering guarantees, negative requirements, numeric defaults) get softened into weaker prose downstream, and the result can look complete while missing the thing you actually decided."

**Semantic frame drift (#1015, open, 2026-09-02).** "An implementation agent can be locally coherent while silently changing one of those frames [identity boundaries, ownership, lifecycle, valid states, authority]. That is different from ordinary implementation drift." Proposes SUPPORTED/CONFLICT/UNSUPPORTED classification. Links to #130 and #207 "because `CONTEXT.md`/glossary material should not be treated as a PRD or execution plan."

**Token blow-up (#826, open).** Quoted above. Note the agent's own explanation inside the report: "It's the cost profile of the process itself: you're buying ~60 code-verified micro-decisions per ticket so implementers and reviewers don't burn review rounds discovering them later. Whether that trade is worth it at this price is a fair question." The user's reaction: "Great now I also have 70 questions to answer and need to wait 4 hours for reset."

**Wayfinder doing instead of deciding (#931, open).** "A `wayfinder:task` was allowed to modify production code after execution was enabled in the map Notes. The work happened inside Wayfinder rather than through the implementation flow, bypassing typical TDD, code review, and explicit design checks." The docs: "the constraint and its exemption live in the same file the constrained party owns."

**Map truncation (#944, open).** "Body crossed 65,536 characters during routine resolution append. Write was silently truncated with no notification. 59 index lines were lost, including entire `## Not yet specified` and `## Out of scope` sections ... Permanently lost: reasoning that existed only in the map body, particularly out-of-scope rulings for closed, unbuilt tickets."

**Tracker wiring (#554, #513, open).** "It has never worked across nearly a dozen specifications." Docs: the agent "went as far as asserting GitHub has no native blocking relationship at all."

**Stop conditions (#976, open).** "`to-tickets` requires narrow, complete, single-context vertical slices, but the generated ticket templates do not make the completion boundary explicit ... legitimate adjacent concerns expand ticket scope even after original acceptance criteria are satisfied."

**Skipping the pipeline (#975, open).** "After a /grill-with-docs session reaches a confirmed shared understanding, the workflow can jump directly into implementation instead of routing" to to-spec.

**Admitted in the docs pages** (Matt-curated summaries of field reports): implement "does not reliably close or check off the ticket"; parallel `/implement` sessions in one checkout produced "a `git commit --amend` in one session landing on another session's commit, a stash vanishing from `refs/stash`, and commits landing on the wrong branch, all in a single afternoon across three issues"; "One ticket burned 150k tokens ... normal rather than a sign something broke"; "I charted 27 tickets, and by the time I got to the thirteenth, the rest no longer made sense. A real and repeatedly-reported outcome"; "The grilling is exhausting. Every question is three paragraphs long ... not resolved"; and on to-spec: "Nothing keeps it in sync, so in practice it is a snapshot of what you knew at that moment ... Treat it as throwaway once the work ships."

**Matt's own artifacts contradict the templates** [inferred from samples]: file paths in specs and tickets; a map whose decisions are paragraphs; CONTEXT.md at 63 KB. The rules are aspirations the model does not reliably honour, and Matt does not appear to hand-correct them.
