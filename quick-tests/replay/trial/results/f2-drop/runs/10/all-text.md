The background search came back. Nothing in it settles a question for you, but it changes three of my recommendations. The round is still open.

**Q1 and Q2 have a counterweight.** Some rules about the route did good *because* they were binding:
- The mandatory trail review caught an owner's mistake three times out of three.
- An agent skipped `architect` and a hook bug survived four review rounds. That's where the blast-radius rule came from.
- An agent broke the delegation rule knowingly, so a hook now enforces it.

If every route rule became advice under Q2(b), these would all have been optional. So I'm adjusting Q1: a route rule can be binding when you own it *and* it carries the evidence that made it. The trail review qualifies. "Read nothing beyond this brief" doesn't, because a lane added it to save cost and nobody asked for it.

The research branch says something similar. Telling a reader the method helps on simple tasks and for novices, and hurts on complex tasks and for experts. It also separates a writer holding back what it volunteers from a writer limiting what the reader may look for. No study tests a limit on an AI model's strategy directly, so the evidence for that part is thin.

**Q3 is bigger than I framed it.** The factory gives a reader five different ways to depart from a rule, and they disagree:
- "say so loudly and get a sign-off" (`AGENTS.md:26`, `template/AGENTS.md:20`);
- "follow the file and tell me why your instinct differed" (`template/AGENTS.md:16`), which is the opposite default;
- `skip: <reason>` in poteto-mode, which is switched off for delegation;
- `accepted: <reason>` on writer flags;
- "stop and report the cell, never fill it in" for a writer who can't build a scenario-table cell as written.

None of the audits examined these. Nothing records the sign-off route ever being used, and nothing says how a subagent would get a sign-off. The real question is therefore which one of these becomes the standard, or whether different kinds of rule get different ways out.

➡️ My recommendation stays (a): stop that part, report to the rule's owner, carry on with the rest. The `accepted: <reason>` mechanism is the closest match among the five, because the script makes every departure visible. "Follow the file, then explain" should go: it is the comply-first default that lets a rule quietly shrink the goal.

**One thing for later rework, not this ticket.** The constraints audit sorted limits into five classes, and those classes mirror the "protect the world / shape the search" split you've rejected. That includes the six rules it chose to keep, so its keep-or-cut calls need re-judging under whatever test comes out of this ticket. This bears on the ticket "Decide the scope and order of reworking existing files". I'll add it there once you've answered.

I'm waiting on your answers to Q1–Q5.