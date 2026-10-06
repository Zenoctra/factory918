Yes, the research changes the round. Three of my five recommendations had a hole, and it adds two questions I hadn't asked. Here is what changed, then the revised round. I've left out my earlier round-one answers, so this one replaces them.

The research is [docs/research/wording-and-reader-context.md](https://github.com/Zenoctra/factory918/blob/research/wording-and-reader-context/docs/research/wording-and-reader-context.md) on its own branch. Section numbers below (§4 and so on) point into it.

## What changed

- **My test for "binding" let the worst cap through.** I counted "what done means" as part of the task, so as binding. The strongest evidence of harm is about exactly that: rules that set a bar on what the reader reports.
  - Radiologists who found a second abnormality kept searching, but they became reluctant to report it (§4).
  - Anthropic reports the same about its own models: told "only report high-severity issues", Claude still finds the bugs and leaves the ones below the bar out of its report (§4).
  - The factory has its own case. The `spec:` citation gate made a reviewer file nothing on a PR that had four real bugs.

  So a definition of done can itself be the cap, and it needs its own question.

- **Even a plain statement of the task narrows what the reader sees.** In the gorilla study, what people were told to count decided whether they noticed the gorilla. One 2026 preprint found the same in models: a narrow task made them leave out critical findings they reported without it. A separate reviewer given an open brief recovered every one of those findings (§4). The task alone isn't enough; the reader also needs the purpose behind it, and a place to put what lies outside the task.

- **My Q3 assumed the reader notices when a rule fights the goal.** Usually it doesn't.
  - People who misread a question are confident in the misreading. When told they could ask, they asked 4% of the times help was given (§8).
  - Models almost never ask on underspecified coding tasks (§8).
  - Models act on hints in the brief without mentioning them (§3).
  - A mechanism that waits for the reader to bring up a conflict will mostly stay silent. One survey result points at the fix: people told definitions were *essential* checked them on 81% of questions, against 23% when told they were *available* (§8).

- **Route knowledge splits into two kinds.** Step-by-step guidance helps novices and hurts experts (§4). Readers who know little about a subject do better with explicit links (§9). A subagent is a capable reader that knows almost nothing about this project. So it should get facts about the project generously and method sparingly. I'll call the facts **terrain**. "A guard refuses `git` inside `$(...)`" is terrain. "Read the tier in two plain commands" is the route someone worked out from that terrain.

- **How a rule is worded matters separately from what it says.**
  - The same limit lowered creativity when worded as control, and not when worded as information (§4).
  - Current Claude models take instructions literally and over-apply emphatic ones (§4, §11).
  - A literal reader turns an illustration into a rule.

- **The evidence has a gap exactly where this ticket sits.** No model study tests a limit on method as such: which files to read, which order to work in, which list to cite from (§4, §13). The case rests on the human studies, the vendor's own notes, and the factory's run-2 evidence. Q7 asks what that means for deciding now.

Two things stayed the same, and the research made them stronger:
- The route belongs to the reader. Garfinkel and Suchman argue that no instruction written in advance can contain the situation it will meet (§4). That is your "leave it open for something you CAN'T predict", argued from the nature of instructions themselves.
- An orchestrator shouldn't invent binding rules. Interrogators who were told to expect guilt asked guilt-presuming questions (§3). In the one test of military commander's intent, intent statements written in practice were full of method (§4).

The terms I use:
- **The goal** is what's wanted, and why.
- **The route** is how the reader gets there.
- **Terrain** is facts about the project.
- **A binding rule** is one the reader may not overrule by itself.
- **The owner** of a rule is whoever holds the authority it protects: you, the ticket, or the orchestrator for the things it controls.

The options under each question are a starting point. If the right answer is outside them, say so.

---

❓ **Q1 - What makes a rule binding, and who may write one?** Proposed test: a rule is binding only when both of these hold:
- **It's about the goal or about authority.** It states the goal and its purpose, or it marks a decision that belongs to someone else: you merge, another subagent holds a file, the ticket draws the scope.
- **Its owner made it binding.** An orchestrator writing a brief may pass down your rules and the ticket's, and may bind what it controls itself. Anything else it believes about the route is offered as knowledge (Q4), never as a rule.

How the test treats the run-2 evidence:
- The delegation rule and the mandatory trail review are rules about the route, and both worked: the trail review caught the owner's errors three times out of three. Under this test they stay binding because you set them with evidence behind them.
- "Read only the diff" fails both conditions.

The options:
- (a) both conditions together;
- (b) ownership alone;
- (c) no test, so each rule is argued case by case.

➡️ (a). Ownership alone would let you or a ticket bind a guessed route without anyone noticing that it is a route. Content alone would let an orchestrator dress up its guess as part of "the goal".

---

❓ **Q2 - Where do limits on what comes back belong?** This covers severity bars, finding caps, word limits, and gates like "every hard bug must cite `spec:`". Each one sits inside the reader's work and decides what it reports, not what it finds. The options:
- (a) The reader reports everything it found, each item with its own confidence and severity. Any cut happens in a separate step that someone else runs. This is Anthropic's own advice (§4).
- (b) Keep the bar in the brief, but worded as information: "Manuel acts on hard bugs first."
- (c) Case by case.

One counterweight: an instruction to "report everything" leans too. More detailed find-and-fix prompts raised false positives in model reviewers (§3).

➡️ (a), with the confidence attached, so the later step has something to filter on, and with no push toward more or fewer findings. A real budget of time or money is stated as a fact, and the reader plans its route within it. A budget only you set may cap the work directly. The map "Optimize token use and wall-clock time without losing reliability" can revisit budgets with measurements.

---

❓ **Q3 - What does a reader do with something important outside its task?** A spec reviewer sees a security hole. A researcher sees that the question itself is wrong. The options:
- (a) Report it, marked as outside the task, and don't act on it.
- (b) Act on it if it seems clearly right.
- (c) Ignore it; it's outside the task.

➡️ (a). The preprint result says this is where narrow tasks lose the most: the finding is seen and never written down. Acting on it could cross someone else's authority under Q1. Every brief would say once that the purpose matters more than the task as written, and give the report a place for findings outside the task.

---

❓ **Q4 - How does the writer pass on what it knows about the route?** Proposed:
- **Terrain is given freely.** That means facts about the project the reader couldn't easily find, each with its reason.
- **Route advice is the writer's experience, worded as information** ("this went wrong for me when…"), and only when it isn't something the reader would find on its own.
- **The reader may take a different route** and says in its report that it did.

The counterweight is simple tasks, where the research says specific direction helps. Informational wording covers that case too: when the advice is right, a capable reader follows it anyway, and when it's wrong, the reader is free to go another way. The options:
- (a) the above;
- (b) route advice left out entirely;
- (c) route advice written as an overridable default.

➡️ (a).

---

❓ **Q5 - Since readers rarely bring up a conflict on their own, how does a departure become visible?** The factory has five departure mechanisms today, and they conflict:
- say so loudly and get a sign-off first;
- follow the file, then explain why your instinct differed;
- `skip: <reason>`;
- decide where the spec is silent and record a Provisional decision;
- `accepted: <reason>` on a writer flag.

Proposed: one mechanism replaces all five. Every report has a required section: what in the brief, the rules or the situation held you back from the goal, and what you did about it. The section is required, so an empty one is an explicit "nothing". The reader then acts by the kind of rule:
- **On a binding rule,** it stops that part, reports the conflict to the rule's owner, and carries on with the rest.
- **On anything else,** it departs and says why in that section.
- **In either case,** it never quietly narrows the goal to fit a rule.

A limit: models don't always mention the hints they act on, so this section won't catch everything. Measurement is the backstop.

➡️ The above. Which of the five existing mechanisms survive, and in what form, is rework for the ticket "Decide the scope and order of reworking existing files". This ticket only decides what replaces them.

---

❓ **Q6 - How is a binding rule worded?** Proposed:
- **Plain, with its reason, stated once.** No capitals and no "CRITICAL".
- **Held by structure where possible.** That means a hook, a script or CI, which matches the philosophy's preference for enforcing rules in structure rather than prose.
- **Stated as terrain when a hook holds it:** "a hook blocks pushes to main; merging is Manuel's." No emphatic prohibition.

The evidence:
- emphatic wording makes current models over-apply a rule (§4);
- controlling wording costs creativity where the same limit worded as information doesn't (§4);
- a prohibition keeps the forbidden idea in mind, though only weakly in current frontier models (§5).

The options:
- (a) the above;
- (b) keep emphatic wording for safety rules.

➡️ (a). A hook is stronger than emphasis, and the reader still learns where the walls are.

---

❓ **Q7 - Decide now, or wait for measurement?** Where the model evidence is thin:
- the gorilla-effect result is one unreviewed preprint;
- the vendor's notes have no published numbers and cover Opus 4.8, not 5.5, which the factory runs;
- no study tests a limit on method in models (§13).

The options:
- (a) Decide now, and hand the ticket "Decide how we'll know the writing works" two experiments to check the decision: the same open-ended task with and without an illustrative list, and the same task with a method rule worded as a command or as information.
- (b) Make the decision provisional until those experiments run.
- (c) Wait for them.

➡️ (a). The principle rests on your own stance, decades of human evidence, and the factory's run-2 findings. The experiments then test how it's worded, not whether it holds. The research itself notes that the factory can run the first one, which nobody has published.

---

The housekeeping from before still stands: once this settles, I'll rewrite my memory that holds the old rule (that safety rules about side effects are the exception).