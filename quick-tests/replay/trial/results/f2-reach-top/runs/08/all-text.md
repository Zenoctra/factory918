The background search finished. You haven't answered round one yet, so the questions are still open. Here's what it found and how it bears on them.

**Q1 (what makes a rule binding).** Some rules about the route have clearly done good:
- The mandatory review of the owner's decision trail caught owner errors in 3 runs out of 3 ([ticket.md:26](template/.agents/skills/poteto-mode/playbooks/ticket.md:26)).
- The delegation rule needed a hook because an agent broke it knowingly ([ledger.md:16](docs/agents/ledger.md:16)).
- The definition of a "hard" finding exists because a reviewer counted code smells as hard bugs ([DECISIONS.md:88](docs/knowledge/core/DECISIONS.md:88)).

You set or approved all three, so under my recommendation they stay binding because you own them. Separately, the philosophy itself leans toward scripted method: belief 3 pushes rules to the strongest rung, and belief 7 prefers copied patterns over first-principles ideas ([PHILOSOPHY.md:37](docs/knowledge/core/PHILOSOPHY.md:37), [:41](docs/knowledge/core/PHILOSOPHY.md:41)). Once Q1 is settled, a follow-up question is whether the playbooks count as your binding rules or as route knowledge.

**Q2 (carry the reason).** The factory's rules carry their reasons unevenly. Some do ("because a worktree-isolated agent's guard refuses `git` inside `$(...)`"). Many don't: "never an arena", "nothing wider is redesigned", the 150-line read cap, "Do exactly the task in your prompt" in the agent definitions. Rules with no reason are exactly the ones a reader can't judge against an unforeseen case, which supports (b).

**Q3 (when a binding rule fights the goal).** There are five ways to depart from a rule today, and they disagree:
- Say so loudly and get a sign-off. This is only in the two AGENTS.md files, with no route to a sign-off for a subagent.
- Follow the file, then explain why your instinct differed ([template/AGENTS.md:16](template/AGENTS.md:16)).
- Decide where the spec is silent and record it as a provisional decision.
- pstack's "skip: <reason>" line. For delegation it's switched off on purpose.
- Send a finding or departure back to its source: a writer's flag needs a fix or a reason to accept it, a test-table cell the writer can't implement gets reported, and a design hole amends the ticket.

No audit examined these. If you pick (a), the standard would replace all five with one rule, so this is bigger than it first looked.

**Your correction holds up in the evidence.** The run-2 constraints audit sorted limits using the very framing you rejected, and it kept "safety" and "report format" as acceptable. Its own late addendum admits that a report-format rule did comparable damage. Reviewers had to cite a ticket criterion they were never shown, so they demoted real bugs, and one reviewer filed nothing on a PR that had four hard behaviour bugs. That rule bounds how the work is finished, not how the search goes. Four of 13 labelled bugs also sat in files the brief told the reviewer not to open. Most of the audits' recommendations haven't been applied yet: the "Execute only…" wrapper line, the reading limits in `review-brief.sh`, the 150-line cap and the `spec:` gate are all still live.

**The research ticket "Research how wording and missing context shape a reader's response" already has a write-up.** It's on the unmerged branch `research/wording-and-reader-context`. It supports the broader framing. It also gives two counterweights:
- Spelling out the method helps on simple tasks and for novices.
- Holding back what the writer volunteers is different from limiting what the reader may look for.

It also says no study tests limits on a model's strategy directly. That fits Q2(b): knowledge with a reason, offered rather than imposed.

One thing out of scope here: [MANUAL.md:168](docs/knowledge/core/MANUAL.md:168) still says "twelve ordered beliefs", but the philosophy has eleven since the cost belief was removed. I'll file it as a quick ticket unless you'd rather I didn't.

Round one, Q1 to Q5, is still waiting for your answers. None of these findings changes my recommendations.