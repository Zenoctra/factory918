The background search finished. Your answers to round one are still open, and nothing it found changes the questions themselves. A few findings bear on them, and one changes a recommendation.

**On Q3, departing from a rule.** The factory has five ways out of a rule, and they disagree with each other:
- "Say so loudly and get a sign-off" (both AGENTS files).
- "Follow the file and tell me why your instinct differed" ([template/AGENTS.md:16](template/AGENTS.md:16)). That is the opposite default: obey first, report afterwards.
- Decide, and record the call as Provisional so you can overrule it.
- pstack's `skip: <reason>`, which [feature.md:12](template/.agents/skills/poteto-mode/playbooks/feature.md:12) then shuts off for delegation.
- "Stop and report the cell, never fill it in" for writers.

None of the run-2 audits looked at these, and I found no record of the sign-off ever being used. My recommendation for Q3 still holds. Whatever you pick there should replace all five with one rule, not become a sixth.

**On Q2, reasons.** About half the factory's route rules carry no reason. Examples are "never an arena", "Read no brief and no diff while the review state exists", "nothing wider is redesigned", and the `knowledge` skill's 150-line cap, whose number has no recorded source. The research for "Research how wording and missing context shape a reader's response" supports giving the reason: the model generalizes from the reason, not from the rule. That backs (b).

**Your correction holds up against the evidence.** The run-2 constraints audit sorted limits using the old protect-the-world / shape-the-search split. Its own late addendum then found that a rule about how a review is *finished* had been filed as "report format" and skipped. That rule is the `spec:` citation gate, which the answer-key audit also found. Under that gate, Sol filed nothing on PR 99, which had four hard behaviour bugs. So the damage was never only about search, and the research says the same: the costliest human findings are reporting bars and method limits, not only reading limits.

**Route rules have also earned their place.** Rules about the route did real good in a few cases:
- The mandatory trail review caught the owner's errors three times out of three.
- The delegation rule needed a hook because prose alone didn't hold.
- The design-hole path caught two holes that two runners and a judge had missed.

Under my Q1 recommendation, these stay binding because you set them, not because of what they say. That's why I'd still pick (a) and (b) together.

**One change to my Q4 recommendation.** The research separates two things your examples mix:
- what the reader may *seek*, such as which files a reviewer may read;
- what the writer *volunteers*, such as its own conclusion about the diff.

The forensic evidence supports holding back on what the writer volunteers. It says nothing for limiting what the reader may seek. So Q4 becomes: the orchestrator doesn't invent binding route rules, and separately, it holds back its own conclusions when briefing a judge. The second half is about leading the witness, so it may belong to "Decide what the writing standard is and what carries it" rather than here. Tell me if you'd rather keep it in this ticket.

**One question for the next round.** [PHILOSOPHY.md:23](docs/knowledge/core/PHILOSOPHY.md:23) praises pstack's playbooks for making "the agent follow… a script rather than improvising". [PHILOSOPHY.md:37](docs/knowledge/core/PHILOSOPHY.md:37) pushes rules down to hooks, where no override in the prose exists. Both pull against whatever Q1 and Q2 settle. I'll ask how the playbooks fit once you've answered Q1, since it depends on that answer.

The audits' recommendations are also mostly still unapplied on this branch, including "Execute only the task and path scope the parent assigns" and the `spec:` gate. That's rework for "Decide the scope and order of reworking existing files", not this ticket.

Over to you on Q1–Q5.