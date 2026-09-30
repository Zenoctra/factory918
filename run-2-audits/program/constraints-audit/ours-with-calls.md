# Our own constraint lines, with the root's call on each

Every line below is text Factory918 wrote. Upstream pstack, Matt and Theo lines are left out: they stay. For each line, "My call" is **Delete**, **Replace**, or **Keep**, with one reason. Where I defend a line, the reason says what the line protects. The full quotes and commit history are in `report.md`, sections 1–107.

## The review briefs (`review-brief.sh`, generated for both reviewers)

| Line | What it says | My call | Why |
|---|---|---|---|
| `:506` | "The Reading pack section above is the code to read …" | **Replace** | "the code to read" defines a reading set. Say what the pack carries and that the repository is open. |
| `:503` | fix-only round: "walk only the steps these commits touch, and report only what these commits get wrong" | **Delete** | The round's diff already is the fix. The "only" was an agent's cost narrowing in #93, not yours. |
| `:586` | "the smell baseline below is the whole standard" | **Replace** | Say which standards were passed. Let the reviewer apply any standard it finds documented. |
| `:550` | "Do not raise them again." (settled items) | **Replace, I'd defend the intent** | It exists because settled findings kept coming back as new. Better: "If you reach one again, say what its cited decision misses." That keeps the anti-churn purpose without forbidding the thought. |
| review-*-high / tier-* wrappers | "Do exactly the task in your prompt." | **Replace** | Harmless in intent, but it reads as a fence. Say the task is what to deliver, and the repository is open. |

## The spec-review skill (our patch) and the judge

| Line | What it says | My call | Why |
|---|---|---|---|
| `SKILL.md:21` | orchestrator: "Do not read the diff yourself" | **Replace, partly defend** | What it protects: the orchestrator must not quietly become a third reviewer, which is your delegation rule. What's wrong: it blinds the judge. My version: the judge may open anything it needs to check a reviewer's claim, and its job is to sort the reviewers' items, not add its own. |
| `SKILL.md:119` + `delegation.sh:76,98` | judge "never the code under review", enforced by the hook | **Delete the read ban, keep the role** | Same reason. A judge that can't check a claim before dismissing it is judging blind. |

## Delegation hook (binds the root orchestrator only)

| Line | What it says | My call | Why |
|---|---|---|---|
| `delegation.sh:82` | the root may not read a file over 200 lines whole | **Keep, I'd defend it** | This is your rule, "reading in bulk is a lane's job", applied to the orchestrator. It never touches subagents. The number 200 has no recorded reason, so it could become a warning, but the rule is yours. |

## Ticket playbook (ours)

| Line | What it says | My call | Why |
|---|---|---|---|
| `:13` eco | owner: "Read no brief and no diff while the review state exists" | **Delete** | #109 asked to drop the review wrapper lane, not to blind the owner. A lane added it. |
| `:11`, `:12`, `:15` eco | no explorer lanes; one runner + judge; one writer; one-page hand-back | **Keep the tier, reword** | You approved these in #109. Say them as Eco's defaults, not bans, and drop "one page" (keep the headings). |
| `:45`, `:46` design hole | "nothing wider is redesigned"; "scoped to it" | **Delete** | #90 said "scoped to the cell". A lane made it "nothing wider". A redesign should see the whole artifact. |
| `:46` | "the judge skipped when they converge" | **Delete** | It drops the one lane that reads the runners' work. It's backwards against Eco and has no recorded reason. |
| `:23` + feature/bug-fix/refactoring/perf | a writer that can't implement a cell "stops and reports the cell, and never fills it in" | **Keep, I'd defend it** | This isn't a reading limit. It's tests-first integrity: the writer may not quietly invent behavior the table didn't settle. Add the reason: "so the table is amended on the ticket rather than diverging from the code." |
| `:10` | "never nested in one line" | **Keep as a fact** | It's a real harness guard. Reword it as the fact: the guard refuses nested `git`. |

## Autopilot-stack playbook (our patch)

| Line | What it says | My call | Why |
|---|---|---|---|
| `:11` | STACK-READY report "is one page" | **Delete "one page"** | The headings are the useful part. |
| `:10` | "Owners start one at a time" | **Keep, I'd defend it** | It's about chain order, not reading. Each owner branches from the settled tip. Add the measured reason. |

## `knowledge` skill (ours; any lane can load it)

| Line | What it says | My call | Why |
|---|---|---|---|
| `:3`, `:9`, `:17`, `:19` | "without reading whole files", "Open the mini-TOC, not the file", "first 30 lines only" | **Replace** | Say how to find the section fast, not what not to read. |
| `:18` | `\| head -40` | **Delete** | Arbitrary cap. |
| `:20` | "never read more than 150 lines in one call …" | **Delete** | A hard read cap handed back to lanes the hook deliberately exempts. |
| `:21`, `:22` | "in a few sentences"; "Stop. Do not read adjacent sections …" | **Delete** | Output cap and a reading ban. |

## `factory918` skill (ours)

| Line | What it says | My call | Why |
|---|---|---|---|
| `:10`, `:45` | "then stop"; "name the entry point, and stop" | **Replace, partly defend** | For you, the router should name the step, not launch hours of work unasked. But when a session launched it for the work, "stop" shouldn't bind that lane. |
| `:62`, `:74` | "Reads ranges, not files"; "rather than paraphrasing at length" | **Replace / delete** | Wording from belief 9 (below). |

## `factory-retro` skill (ours)

| Line | What it says | My call | Why |
|---|---|---|---|
| `:15` | "the last seven days … skim each" | **Replace** | Start with the unread sessions, and let it read older ones and subagent transcripts too. "Skim" invites a shallow pass. |
| `:17`, `:35` | "say so and stop"; "in one sentence" | **Replace / delete** | Output caps with no reason. |

## `template/AGENTS.md` (ours only; Theo's and Matt's lines stay)

| Line | What it says | My call | Why |
|---|---|---|---|
| `:65` | "Run the whole suite only if it finishes in under 30 seconds" | **Replace** | The 30 seconds has no reason. CI runs everything, so running more locally only helps. |
| `:68` | "Subagents never launch their own dev servers …" (Theo's, widened by us) | **Keep, I'd defend the safety half** | Port collisions and orphaned processes are real side effects. Rewrite it as the safety rule it is: start it from your own worktree on a free port, stop it by the PID you captured. |
| `:78` | "Reviewers ignore body prose by design" | **Delete** | It's no longer true. The Spec brief pastes the PR body's blast radius. |
| `:5` | "`knowledge` looks things up without reading files whole" | **Replace** | Belief 9 wording. |

## MANUAL, DECISIONS, PHILOSOPHY, models.md (ours)

| Line | What it says | My call | Why |
|---|---|---|---|
| PHILOSOPHY `:43` belief 9 | "Read knowledge in ranges, never whole." | **Replace** | This is the root of every "without reading whole" line. It began as a rule for the model building the factory. Keep the true part: point at documents and keep bulk in lanes. |
| PHILOSOPHY `:39` belief 5, MANUAL `:95` | 30-second suite cap; "local checks stay targeted" | **Replace** | Same as `AGENTS.md:65`. |
| PHILOSOPHY `:44` belief 10 | panels and `interrogate` "off unless a decision is contested" | **Your call** | It's a cost gate on the adversarial lanes. It ties into merging `interrogate` into reviews. |
| MANUAL `:96` | the writer is "deliberately not loaded with" the coding standards | **Delete** | It withholds a file from the writer on purpose. The writer should read the standards it's judged by. |
| MANUAL `:98` | `interrogate` "is the expensive rung, so it is conditional" | **Your call** | Same as belief 10. |
| MANUAL `:143`, DECISIONS P16, `models.md:15-16` | Standards reviewer and explorers "Opus 5 medium", "junior work", "a well-built brief carries everything it reads" | **Hold for #138** | The reason given assumes a reviewer that reads only the paste. Replace the wording now. Settle the model and effort from #138's results. |
| DECISIONS P107 | defends "Read nothing beyond this brief" | **Replace** | Stale since #137. |
| DECISIONS P20 | later rounds "review only that fix" | **Replace** | Say the round's diff is the fix. The reviewer opens anything the fix reaches. |
| DECISIONS P21 | the spec is the ticket body plus its author's comments, "nobody else's comments and none of the PR's own" | **Keep, I'd defend it** | This is your #7 rule, "reviews read the human's words, not the author's". It stops the PR author leading the reviewer. |
| DECISIONS P109, MANUAL | eco "hands back one page" | **Replace** | Keep the headings, drop the page cap. |
| MANUAL `:165`, `:176-178`, PHILOSOPHY `:13`, `:64` | "without reading files whole", "a section at a time", "Only if you are changing the factory" | **Replace** | Belief 9 wording. |

## Frozen eval briefs (24 files)

Being replaced: #138 regenerates them from the current script. They still carry "Read nothing beyond… Run nothing", "Zero items is expected" and "Under 400 words".

## Summary of my calls

- **Delete or replace:** almost all of it, about 45 lines.
- **Keep, with the reason written in:** 6 lines.
  - the root's bulk-reading rule (your delegation rule)
  - the writer-cell rule (tests-first integrity)
  - owners start one at a time (chain order)
  - P21 (your #7 rule)
  - the dev-server safety half
  - the nested-git fact
- **Your calls:** 2 cost gates on `interrogate` and panels. **Held for #138:** the reviewer model and effort lines.

## Filing gates (added 2026-09-25; the first pass filed these as "report format" and skipped them)

| Line | What it says | My call | Why |
|---|---|---|---|
| `review-brief.sh:494` | every item carries a `spec:` line or "is sent back" | **Replace (#144)** | The Standards brief never shows the ticket it demands a citation of. Allow `spec: none`; send nothing back. |
| `review-brief.sh:493` | an item without `Documented step:` "is sent back" | **Keep the line, delete the gate** | The line is your happy-path test of "hard". An item without one is filed as not hard, not rejected. |
| `review-brief.sh:596-598` | every Standards item is "a breach of a documented standard", with the standard cited | **Replace** | A behaviour bug with no written standard behind it can't be filed. Sol obeyed this and filed nothing on pr99, whose 4 hard bugs are all behaviour bugs. Cite a standard where one applies; file real bugs either way. Belongs with the review merge. |
