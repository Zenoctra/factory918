Yes, it changes the round. Some recommendations hold, but the questions themselves have moved. Three things shifted once I read the research ([the note, on its branch](https://github.com/Zenoctra/factory918/blob/research/wording-and-reader-context/docs/research/wording-and-reader-context.md)):

1. **The question is less "which rules are binding" and more "what every rule carries."** The strongest findings are about how a rule is put to the reader, not which rules exist:
   - The same limit lowered creativity when it was worded as control, and not when it was worded as information.
   - Models generalize from the reason behind an instruction.
   - No rule written in advance can contain the situation it will meet.
   - A definition of "done" can steer the route harder than any rule does.

2. **Wording alone is weaker than I assumed.**
   - Current Claude models read instructions literally, so "here's what I know" can still land as an order.
   - Readers rarely notice when they've misread, and rarely ask.
   - Models use hints without mentioning them.

   So several answers need structure, not just better phrasing.

3. **Round one made the mistake in miniature.** My Q1 replaced your rejected two-bin sort with a three-bin sort. The research's open-versus-closed question studies say that sort would have become the whole space: in one study, four listed problems went from 2% of open answers to 60% of closed ones. Every question also came as (a)/(b)/(c). This round asks each question openly first. Any options I name are ones I considered, not the edge of the question.

A caveat on evidence strength. The research's biggest gap is this ticket's exact question: no study tests a limit on *method* in models. What follows rests on human evidence, plus model evidence from close neighbours: reporting bars, output formats, framing. Read the recommendations as reasoned bets that the ticket "Decide how we'll know the writing works" should test.

Terms, as before: **the goal** is what's wanted; **the route** is how the reader gets there; **the writer** is whoever writes the brief or file; **the reader** is the subagent or person who acts on it.

---

❓ **Q1 - What does every rule carry with it?** Round one tried to sort rules into binding and not by what they're about. The research points somewhere else.
- **Controlling wording vs information.** Children painting under identical limits were less creative only when the limits were worded as control (Koestner 1984).
- **Reasons travel.** A rule with its reason is taken on better (Deci 1994), and Anthropic's guidance says its models generalize from the reason.
- **No rule is complete.** Garfinkel and Suchman argue no instruction can foresee its situation, so the reader always fills the gap. The writer's only choice is whether the text helps it fill the gap well.

The reason is what lets a reader see the case the writer couldn't predict, which is your "leave it open for something you CAN'T predict". The factory shows both kinds:
- [ticket.md:10](template/.agents/skills/poteto-mode/playbooks/ticket.md:10) carries its reason.
- The `knowledge` skill's 150-line reading cap has no recorded reason at all.

➡️ Every rule states its purpose (what it serves, and why) and its owner (who can change it), worded as information about the situation, not as control. A rule whose writer can't state its purpose doesn't ship. "Binding" stays, but it only says who decides whether the rule may be broken, which is Q5's and Q6's business. It no longer sorts rules by content.

---

❓ **Q2 - What should the writer pass on about the route?** Round one treated this as one thing. The research splits it in two.
- **Facts about the situation help.**
  - Across 16 studies, clinical context made medical readers more accurate, and none found a loss (Loy & Irwig 2004).
  - Explicit links help readers new to a subject (McNamara 1996). A fresh subagent is new to the project, however capable it is.
- **Recommended methods hurt capable readers.**
  - Step-by-step guidance helps novices and hurts experts: experts did better with less of it (d = −0.43).
  - A familiar method blocks a better one: chess masters said they searched for a shorter mate while their eyes stayed on the familiar one.
  - Codex copied lines from an example function into 32–61% of its solutions.
- **Context carrying the writer's conclusion moves even experts.** Fingerprint examiners reversed their own earlier matches. Telling a model the code was bug-free cut detection from 97% to 4% for GPT-4o-mini, and from 96% to 89% for Claude Opus 4.5.

The factory's own example: "read the tier in two plain commands, because the guard refuses `git` inside `$(...)`". The fact is the guard. The two commands are the writer's method.

➡️ Pass on facts about the situation generously, with where they came from. Leave out methods and conclusions. When the writer believes a method matters, it writes the fact that convinced it and lets the reader work out the method. The research's one counterweight is simple tasks and novice readers, which is rarely our case.

---

❓ **Q3 - How should the writing say what "done" means without the check replacing the goal?** I missed this in round one, where I listed "what done means" as safely binding. The research says a definition of done can steer the route harder than any rule:
- People treat a measure as if it were the goal. It happens without their noticing, and merely being measured is enough (Black et al. 2022).
- A specific outcome goal hurts on complex, novel tasks. A goal to learn does better (Winters & Latham 1996).

The factory has two cases:
- **The `spec:` citation gate.** One reviewer obeyed it and filed nothing on a PR with four hard bugs. Fable demoted real bugs "because the Standards brief carries no ticket criteria to cite."
- **Your P109 ruling.** You called a ticket's "at most" list "a prediction, not a constraint".

One finding helps: several measures reduced the effect compared with one (Choi 2012).

➡️ The writing states the purpose first. Then it names any checks the writer will apply, as checks *of* that purpose. It asks the reader to report what the purpose needed that the checks didn't cover. That gives a concrete counter-move, where "the purpose wins" alone is just a general appeal, and the research found general appeals weak.

---

❓ **Q4 - When the writer needs a limit for its own reasons, can that limit run after the reader's work instead of during it?** This question is new, and it's the most research-backed pattern in the set. Many harmful limits exist for the writer's convenience: a length, a format a script parses, a severity bar, a cost cap. The evidence says these work better as a separate step after the reader:
- **Reporting bars.** Radiologists given an extra finding kept searching, but became reluctant to report what they found (Berbaum 2015). Anthropic reports the same of its models. A "high-severity only" bar left recall down while the model still found the bugs. Its advice is to ask for every finding with a confidence and severity, and filter in a separate step.
- **Output formats.** Forcing JSON hurt reasoning, and answering in prose first and converting afterwards mostly removed the loss (Tam 2024; a rebuttal disputes this).
- **Output budgets.** Tight budgets cut reasoning models sharply: Phi-4-reasoning went from 72% to 54%.
- **A narrow task.** In one 2026 preprint, a narrow task instruction suppressed findings the same models otherwise reported. A separate critic with an open-ended brief recovered all of them.

This also handles round one's budget question: a budget becomes a fact the reader plans within, never a cap on what it returns.

➡️ Yes, as the default. A limit the writer needs (filter, format, length, cost) goes in a step after the reader, not in the reader's brief, unless it truly can't. This is structure rather than wording, which suits a literal reader. The cost is an extra step, and measuring that cost is the efficiency map's job.

---

❓ **Q5 - When a rule fights the goal, who notices?** Round one asked what the reader *does*. The research says the reader often won't notice at all:
- Claude 3.7 Sonnet mentioned a hint it had used only 25% of the time.
- Treating the measure as the goal happens without awareness.
- Survey respondents asked for help on 4% of the occasions it was given, and current models almost never ask about an underspecified task.

Two things helped:
- **Wording.** Calling definitions "essential" rather than "available" raised how often readers checked them from 23% to 81%.
- **Read-back.** A hospital handoff program ending in "the receiver restates the plan" cut medical errors by 23%. It wasn't randomized, and it was bundled with training.

Today the factory has five departure mechanisms that conflict, and none fits a subagent with nobody to sign off.

➡️ The reader restates the goal and the rules it is under before it starts, so the writer can see a misreading. When a rule fights the goal, the reader stops that part, carries on with the rest, and reports the conflict to the rule's owner. It never quietly shrinks the goal. Since that shrinking is mostly unconscious, the read-back is what makes it visible, not a ban.

---

❓ **Q6 - May the writer invent binding rules from its own judgment about the route?** Round one asked this, and the research sharpens why not:
- Writers overestimate how well they're understood, and more so with close partners (Savitsky 2011). An orchestrator after a long session is that close partner.
- An interviewer told to expect guilt asked guilt-presuming questions, and neutral listeners then heard the suspects as more defensive (Kassin 2003).
- Commanders' written intent matched their real intent in about a third of cases, and was often full of method (Shattuck 2000).

➡️ Unchanged, now better grounded. The writer passes down rules it doesn't own, with their owners. It binds only what it owns itself. Everything else it knows goes in as situation facts under Q2.

---

**A pattern from a few cases, not a test.** The factory's rules about process that did good either added an independent look or bound the orchestrator: the trail review (3 of 3), the delegation hook, blast-radius. The ones that did harm narrowed someone who was looking. The 2026 preprint's open-ended critic fits too. That's too few cases to build on, and building on them would repeat the reviewer-to-universal mistake. I'm noting it so the measurement ticket can check it.

**One limit on all of this.** People told to "consider the reader" got slightly *less* accurate, and a generic system prompt barely helped models. Whatever we decide here won't change writers by being written down. How it reaches them is a question for "Decide what the writing standard is and what carries it" and "Decide where each piece lives and when it reaches the writer".

This round replaces round one; answer whichever way suits you.