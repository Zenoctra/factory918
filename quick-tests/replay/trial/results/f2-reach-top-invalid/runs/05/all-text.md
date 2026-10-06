The background search finished. I haven't seen your answers to round one, so nothing is settled yet. Three of its findings change the questions, so here they are before you answer. I tried to check the research branch myself and the command was denied, so that part is the search's report and I haven't confirmed it.

**1. The factory already has five ways to depart from a rule, and they disagree.** This changes Q3.
- [AGENTS.md:26](AGENTS.md:26) and [template/AGENTS.md:20](template/AGENTS.md:20): say so loudly and get a sign-off before breaking the rule.
- [template/AGENTS.md:16](template/AGENTS.md:16): follow the file first, then explain why your instinct differed. That's the opposite default.
- [template/AGENTS.md:18](template/AGENTS.md:18): never block on the human for anything reversible. This pulls against the sign-off rule.
- pstack's `skip: <reason>`: allowed for most steps, switched off for delegation.
- Our report-back paths: `accepted: <reason>`, and "stop and report the cell". Some freehand briefs also ask the reader to list where it departed and why.

No text says how a subagent gets a sign-off, and the search found no record of anyone ever using it. So Q3 isn't really a new rule. It's picking one of these and retiring the rest.

**2. Rules about how the work is reported did damage too.** This tests Q1. The constraints audit sorted "report format" as always safe and kept it (`ours-with-calls.md:110-116` on `research/run-2-audits`). Its own late addendum admits that was wrong: the `spec:` gate made one reviewer file nothing on PR 99, which had four hard bugs, because the brief never showed the ticket it was told to cite. The audit's categories copied the old "protect the world / shape the search" split, which is your correction showing up in the evidence.

So "how to report" isn't automatically part of the task. Under Q1 I'd treat a report format as binding only when it serves the person or script that reads it, never when it filters what counts as a finding. The approved template line put "how to report" in the fixed part, so that line needs the same qualifier. This is still the `spec:` gate the audit found ([review-brief.sh:494](template/.agents/skills/spec-review/scripts/review-brief.sh:494)).

**3. Some rules about the route earned their place, and all of them came with a measured reason.**
- The mandatory trail review caught the owner's errors three times out of three ([ticket.md:26](template/.agents/skills/poteto-mode/playbooks/ticket.md:26)).
- Narrow grounding let a hook bug survive four review rounds, which is where the blast-radius rule came from ([ledger.md:17](docs/agents/ledger.md:17)).
- The delegation rule needed a hook because the prose alone wasn't followed.

All three are your rules, which fits the Q1 recommendation (binding because their owner set them). It also backs Q2: these rules hold up because each one states its reason. Many of our other rules state none, for example "never an arena", the 150-line cap, and "Do exactly the task in your prompt".

**One counterweight from the research,** on `research/wording-and-reader-context` according to the search: a specific method helps on simple tasks and for less capable readers. The research also separates a writer choosing not to volunteer something from a writer forbidding the reader to look for it. And no study it found tests limits on an agent's route directly. That could push Q2 toward (c), a default the reader may override, for simple, repeated lane jobs.

Round one stands as asked, with these changes:
- **Q1:** test it against the report-format case as well as the delegation rule.
- **Q3:** read it as choosing among the five existing paths.
- **Q2:** weigh the counterweight.