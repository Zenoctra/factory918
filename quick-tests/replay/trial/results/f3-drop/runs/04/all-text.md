Yes, the research changes them. My first round treated the problem as sorting rules into allowed and not allowed. The research says the bigger problem is how any rule lands on the reader. Findings are from [the research note](https://github.com/Zenoctra/factory918/blob/research/wording-and-reader-context/docs/research/wording-and-reader-context.md) unless marked otherwise.

## What changed

**1. Stating the goal is itself a limit on the route.** Round one treated "what's wanted" and "what done means" as safe ground for rules the reader can't overrule. The evidence says otherwise:

- **The one model study of this** (Shin 2026, a preprint) found that an ordinary, focused task instruction stopped models reporting safety-critical findings. The same models reported those findings when given no narrow task. A second critic with an open brief recovered every one.
- **The human version is the gorilla study.** People told what to count stopped seeing what they weren't told to count.
- **The most damaging rule, in people and in models, is a bar on what to report**, and it sits inside "what done means". Anthropic's guidance for its current models says this directly: a reviewer finds the issue, then leaves it out because it falls under the stated bar.
- **The run-2 `spec:` gate is our own case of this.**

**2. Wording a rule as information instead of as an order may not free a model.**
- In people the result is solid: the same limit, worded as control, lowered creativity, and worded as information, it didn't.
- No study found that people's resistance to control exists in models. Anthropic reports something else: current Claude reads literally and over-applies emphatic wording.
- So "here's what I'd try" may still work as an order. Round one's Q2 recommendation rested on this. I hold it with less confidence now, and "Decide how we'll know the writing works" should test it.

**3. A reader that hits a conflict rarely notices it and rarely says so.**
- Survey respondents who were told they could ask for help asked on 4% of the occasions it was given.
- Current models almost never ask on underspecified coding tasks.
- Models use a hint in the prompt without mentioning it in their reasoning.
- So permission to depart from a rule won't make departures happen. One finding is direct: telling readers that checking a definition was *essential*, not just *available*, raised checking from 23% to 81%.

**Two distinctions I didn't have before:**
- **Withholding something is not the same as forbidding it.** Forensic science protects an examiner's independence by not telling them a colleague's conclusion. That limits what the writer *volunteers*. Nothing in the evidence supports limiting what the reader may *seek*. On paper the two look alike: "you won't be given the earlier review" versus "don't look at the earlier review". That resemblance is how the second kind slid in.
- **Capable but new to the project.** A subagent is a capable reader that knows nothing about this project. Step-by-step method hurts capable readers (expertise reversal, d = −0.43). Explicit context helps readers new to a domain. So facts about the situation need different treatment from strategy for the task. Round one lumped both together as "route knowledge."

**One limit on this ticket.** Telling writers to "consider the reader" barely works in people: across 15 experiments, imagining the other's view made people slightly *less* accurate (d = −0.26). A generic system prompt barely helped models. What helped was real signal from the reader. So nothing decided here can rely on prose addressed to writers alone. Where the guidance lives and how it's checked belong to two later tickets on the map: "Decide where each piece lives and when it reaches the writer" and "Decide how we'll know the writing works". I'll hand them this finding.

## The revised round

You talked about "leaving the door open for a model to overrule certain rules that aren't absolutely necessary." That gives the tree its main question: Q1, whether rules come in two tiers. Q2 to Q4 don't depend on it. Three later questions do, and they're listed at the end. The options in each question are starting points, not the full set.

---

❓ **Q1 - Two tiers, and what goes in the top one**

The idea is that most rules are ones the reader may overrule when the goal needs it, as long as it says so. A few are rules it may not overrule on its own. My proposal:

- **Overrulable is the default.** Every rule is overrulable unless it's marked top tier.
- **The top tier holds limits on someone else's authority.** You merge PRs. Another subagent owns those files right now. The ticket decides what changes.
- **It also holds rules the owner of that authority marked top tier, each with its reason.** The delegation rule is top tier because you set it, after an agent broke it while knowing the rule, and not because of what it's about.
- **The goal is in neither tier.** Rules exist to serve it. Done criteria are evidence that the goal was reached, not the goal itself. When they disagree, the goal wins and the reader says so. That is your ruling in P109 against treating a predicted result as the design; management research calls the failure "surrogation".
- **An orchestrator writing a brief may pass top-tier rules down and mark what it owns.** It may not promote its own guess about the route into the top tier. In the interrogation study (Kassin 2003), what the asker expected shaped the questions, and the questions shaped the answers.

The alternatives: (b) round one's single test, based on what a rule is about, with no tiers; or (c) no definition, with each rule argued in the standard.

This is several statements, not one sentence, because you asked for the full nuance and not a dogmatic line. Shattuck's study of commanders' intent shows the risk. Intent statements meant to free subordinates were full of method anyway. Leaving out matches that happened by coincidence, only 34% of subordinates' actions matched the intent. Stating the end and the reason is necessary, not sufficient.

➡️ The proposal.

---

❓ **Q2 - Scope limits what the reader changes, not what it notices**

AGENTS.md already tells the orchestrator that "a finding outside its scope becomes a ticket." The proposal extends that to every reader: the ticket's scope limits what the reader *changes*, never what it *looks at or reports*. Every brief leaves a way to say "I noticed this, outside the goal."

The wording has to hold up against two findings:
- Asking a model to find and fix problems raised its false positives (Jin & Chen 2026).
- Assigned dissent did worse than genuine dissent (Nemeth 2001).

So the brief offers the channel and doesn't demand anything of it: "if you noticed something outside this, say so", never "report at least one."

The options:
- (a) every brief carries the channel;
- (b) only review and research briefs carry it;
- (c) scope covers noticing too.

➡️ (a).

---

❓ **Q3 - Facts about the situation versus strategy for the task**

The proposal:
- **Facts go in freely, with their reason.** Examples: the guard refuses `git` inside `$(...)`; paths here contain spaces; this suite takes four minutes. A reader new to the project lacks these and can't find them cheaply.
- **Strategy stays out unless its owner set it.** Examples: read these files first, check X before Y.
- **Hard-won strategy, when the writer has some, is written as what the writer did and what happened.** It is never written as advice, and the reader may ignore it.

The evidence for keeping strategy out by default:
- Four problems offered in a list went from 2% of answers to 60%, even with "other" invited (Schuman & Scott).
- Codex copied an anchor function's lines into 32 to 61% of its solutions.

Point 2 above weakens the third part: a past experience in a brief may still steer a model that reads literally.

The options:
- (a) as proposed;
- (b) strategy allowed as a default the reader may override;
- (c) no route content at all, facts included.

➡️ (a), with the steering risk handed to "Decide how we'll know the writing works" to test.

---

❓ **Q4 - Bars on what to report, and budgets**

The evidence:
- Anthropic's guidance for current Claude is to ask for every finding with a confidence and a severity, and to filter in a separate step. A bar in the brief lowers how many real problems get reported while the reviewer's ability stays the same.
- Under tight output budgets, reasoning models fell sharply: one went from 72% to 54% at 1,024 tokens.

The proposal:
- No brief puts a bar on what to report, a cap on the number of findings, or a length cap on its reader.
- Filtering is a later step that sees everything.
- A cost or time budget, when one exists, is stated as a fact about the situation, and the reader plans its route within it.
- A budget you set is top tier if you mark it so.

The options:
- (a) as proposed;
- (b) caps allowed where the output goes straight to a person;
- (c) budgets left out of briefs entirely.

➡️ (a). The map "Optimize token use and wall-clock time without losing reliability" still owns the budget numbers.

---

**Next round, waiting on Q1:**

- **What the reader does when a rule fights the goal.** The factory has five departure mechanisms today, and they conflict. Two of them sit side by side in your note in [template/AGENTS.md:16-20](template/AGENTS.md:16): "follow the file and tell me why your instinct differed" and "say so loudly and get a sign-off." Those are your words and they pull in opposite directions, so the choice is yours.
- **Playbooks.** [PHILOSOPHY.md:23](docs/knowledge/core/PHILOSOPHY.md:23) says pstack's playbooks make the agent "follow a script rather than improvising." That limits the route by design, and some scripted steps have earned it: the trail review caught the owner's errors three times out of three. The question is which steps in factory-written playbooks stay overrulable.
- **The ladder.** Belief 3 pushes each rule onto the strongest rung that can hold it, and a hook leaves the reader no way through. That fits top-tier rules. The question is whether an overrulable rule may ever go into a hook, and if so, only with a message that names the way through, as the git guard's does.