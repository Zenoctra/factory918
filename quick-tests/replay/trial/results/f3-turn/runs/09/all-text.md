I'll read the research myself rather than through a summary, since the point is to bring it into the questions.

---

Yes, the round changes. I read the research note whole. It's "How wording and missing context shape a reader's response", on the `research/wording-and-reader-context` branch. Four findings change the questions, so this round replaces round one.

1. **My test classed the most dangerous rules as safe.** Round one called a rule binding when it states "what done means". The research's best-measured harm sits exactly there:
   - Anthropic's guide for Opus 4.8 reports that when a review prompt says "only report high-severity issues", the model still finds the smaller bugs and then leaves them out of its report.
   - In Berbaum's 2015 study, radiologists who found one nodule kept searching for more but became reluctant to report a second.
   - Our own answer-key audit found that the Standards brief demanded a `spec:` citation from a ticket it never showed. Honest reviewers downgraded real bugs because they couldn't cite one.

   Your correction said "pursued **or completed**", and I had only taken in the first half.
2. **Labelling advice as optional doesn't free the reader.** Round one's Q2 relied on writing route advice "as knowledge, not an order". Three findings say that isn't enough:
   - In Schuman & Scott's survey, four problems offered as a list went from 2% of answers to 60%, even though people were explicitly invited to name a different one.
   - Codex copied lines from a related example function into 32–61% of its solutions.
   - Chess masters who knew a familiar five-move mate said they were looking for a shorter one, but their eyes stayed on the familiar squares.

   Current Claude models also read instructions literally, so words meant as illustration still bind. What goes into a brief matters far more than how it's labelled.
3. **Readers rarely notice when a rule has narrowed them, and rarely ask.** Survey respondents told they could ask for help asked 4% of the time. Current models almost never ask on underspecified coding tasks. A 2026 preprint found that a narrowly focused instruction stopped models reporting critical findings they reported otherwise, and nothing in their output showed it. Round one's Q3 assumed the reader would notice a conflict.
4. **Two counterweights.** Holding back what the writer volunteers protects the reader's independence. In every study that showed forensic examiners a previous decision, it biased them. That is different from limiting what the reader may look for. And spelling out the method helps on simple tasks and for novices.

The research also says plainly that no study tests a limit on method in models, and none covers Opus 5.5. The answers below rest on the human evidence, our audits and your reasoning. "Decide how we'll know the writing works" should run the experiments.

The terms are the same as before. **The goal** is what's wanted and why. **The route** is how the reader gets there. **A binding rule** is one the reader may not overrule on its own.

---

❓ **Q1 - What makes a rule binding?** Your words give a better line than round one did: is the rule a **guess about the route**, or a **fact that holds on any route**? "If you could predict it, then you could constrain it. The point is to leave it open for something you CANT predict." Garfinkel (sociology) and Suchman (human-computer interaction) explain why: no instruction written in advance can cover every situation it will meet. A guess fails in the unforeseen case, and the unforeseen case is what a capable reader is there for.

Test cases from the factory:
- **"Never push to main"** is a fact on any route, because merging is yours. Binding.
- **"Another subagent is writing `x.ts` right now"** is a fact while it's true, and the orchestrator that launched both subagents owns it. Binding.
- **"Round two doesn't see round one's findings"** is a fact, because an independent check is the whole point of round two. Binding, and it's the one limit on reading that survives.
- **"Read only the diff"** is a guess. In the reviewer eval, 4 of the 13 labelled bugs were in files the brief said not to open.
- **"A hard finding must cite `spec:`"** is a guess, even though it's worded as "what done means".
- **The delegation rule** (the orchestrator never writes the code) is a guess too, but it's your design for the whole system, made deliberately, with its reason written down.
- **"Never an arena"** ([ticket.md:12](template/.agents/skills/poteto-mode/playbooks/ticket.md:12)) has no reason, so nobody can tell which kind it is. A rule without its reason can't be sorted.

The options:
- (a) The guess-or-fact test, plus ownership. A guess binds only when the system's owner makes it binding deliberately, with its reason and evidence written down, so it can be revisited later. An orchestrator can never make its own guess binding.
- (b) Round one's test, based on what the rule is about.
- (c) No test; argue each rule on its own.

➡️ (a). It sorts every case above correctly, including the ones (b) got wrong.

---

❓ **Q2 - Does a scope limit what the reader notices, or only what it changes?** Scope is legitimate, but some scope rules are worded to cover everything. Our tier agents say "Do exactly the task in your prompt". The pstack wrapper says "Execute only the task and path scope the parent assigns", which the constraints audit rated the worst single limit in the factory. In the famous gorilla study, 46% of people counting basketball passes missed a person in a gorilla suit walking through: the instruction decided what they saw. In the 2026 preprint, a second model given an open brief recovered every finding the narrowly briefed models had left out.

The options:
- (a) A scope limits what the reader **changes**, never what it reads, notices or reports. Anything outside the scope gets reported; AGENTS.md already turns that into a ticket.
- (b) A scope limits everything.
- (c) Briefs carry no scope.

➡️ (a). It keeps one concern per PR without making the scope a blindfold.

---

❓ **Q3 - Where do thresholds, caps, formats and budgets go?** These are rules about how a task is completed: "only hard bugs", "at most N findings", "under 400 words", "answer in this shape". When readers apply them to their own work, the research shows a cost each time:
- They hold back findings they already made.
- A tight output budget dropped one reasoning model's score from 72% to 54% (Sun 2025).
- Requiring JSON hurt reasoning, and answering in plain prose first, then converting, mostly removed the loss (Tam 2024; this one is disputed).

Anthropic's own advice is to ask for every finding with a confidence and a severity, and filter in a separate step.

The options:
- (a) The reader reports everything in its own words, with how sure it is and how much each finding matters. A separate step then applies any threshold, format or length: a script where the cut is mechanical, a person or another agent where it takes judgment. A real budget you set (time, tokens, money) is a fact of the situation: the brief states it and the reader plans around it. A cap invented to save cost is a guess and stays out.
- (b) Thresholds stay in the brief, worded as information.
- (c) Decide case by case.

➡️ (a). The cost is an extra step per job. The efficiency map should measure that cost; it isn't a reason to put the threshold back in the reader's brief.

---

❓ **Q4 - What may a writer pass on that isn't binding?** You wanted to leave "the door open for a model to overrule certain rules that aren't absolutely necessary". The research separates two kinds of non-binding content:
- **Terrain** is facts about the project and its tools that hold on any route and are hard to find: "the worktree guard refuses `git` inside `$(...)`", "paths contain spaces". A subagent starting cold knows little about the project, however capable it is, and readers who know little do much better when connections are spelled out (McNamara 1996).
- **Method** is how to go about the work. For capable readers, step-by-step guidance is a cost. A meta-analysis of 60 studies found it helped novices (d = 0.51) and hurt experts (d = −0.43). Finding 2 says method anchors the reader however it's labelled.

The options:
- (a) A brief carries the goal in its owner's words, the binding rules with their reasons, and terrain with its reasons. It carries no method, even as a suggestion. If a writer feels a method is needed, it asks why. If something later depends on the method, it's a binding rule (Q1) and carries its reason. If it's a lesson from a past run, it goes in as what happened, for the reader to weigh: "on one ticket, a subagent that skipped the design step let a hook bug survive four review rounds." The factory's standing defaults in AGENTS.md and the playbooks stay overrulable, as you said, and each is written with its reason first. The reason is what tells the reader when overruling is justified.
- (b) Method suggestions allowed, marked optional.
- (c) Method stated as a default the reader may override.

➡️ (a). In one study, children painted less creatively when limits were worded as control, and not when the same limits were worded as information. The research found no sign that models push back against controlling wording; instead they over-apply it. That argues for keeping orders out of briefs, not softening them.

---

❓ **Q5 - Which rules may be enforced by hooks, scripts or CI?** The map's destination asks for "the highest rung each rule can reach", and the philosophy (belief 3) pushes rules up toward hooks and scripts. A rule enforced by a hook can't be overruled at all, so a guess placed there becomes a wall. The `knowledge` skill's 150-line reading cap is a case in point. It carries no reason, and it limits subagents that the delegation hook deliberately leaves free.

The options:
- (a) Only binding rules get enforced, never a guess about the route. Every block message says why it blocked and what to do instead, as the git guard already does ("Use --force-with-lease on your own branch, or ask"). A bare "don't" leaves the reader to land on some other default (research, section 5).
- (b) Any rule gets enforced once there's evidence the written rule wasn't followed.
- (c) Keep the current approach.

➡️ (a). Evidence that a written rule was ignored, like the delegation rule being broken knowingly, justifies a hook only for a rule that is already binding.

---

❓ **Q6 - One way to depart from a rule, instead of five.** The factory has five departure mechanisms that disagree with each other. After Q1–Q4, only two kinds of rule are left to depart from: binding rules and standing defaults. The research adds three findings:
- Readers check far more when checking is presented as required. Survey respondents told definitions were essential looked them up for 81% of questions; told they were merely available, 23%.
- Letting a model ask questions recovered up to 74% of the performance lost on underspecified coding tasks.
- A hospital handoff scheme called I-PASS ends with the receiver restating the plan, and it was linked to 23% fewer medical errors.

The options:
- (a) A standing default: the reader may depart from it and reports what it did and why. A binding rule: the reader keeps it, does all it can around it, and asks the rule's owner if it can reach them; otherwise it stops that part and reports. Every report has a required section: "What did any rule or instruction stop you doing or seeing, and where did you depart?" The reader never shrinks the goal to fit a rule.
- (b) The sign-off line becomes the one mechanism.
- (c) Keep all five.

➡️ (a). The required section is the closest thing to that restatement that an unattended subagent can do. It won't catch everything: models use hints their reasoning never mentions. The real protection is Q1–Q4 keeping guesses out of the brief in the first place.

---

**How I'll record the answer.** You said a single sentence collapses a nuanced point. The research agrees: in one army study, commanders' written statements of intent got their intent across only 34% of the time. So the resolution will carry the reasoning, your words and the test cases, not a one-line test. I'll draw the cases from different kinds of work, because the old framing went wrong by generalizing from reviewers alone.

**One finding cuts against your Q9 preference.** For the note that lists in your words are examples, not boundaries, the closest the research gets is Schuman & Scott's invitation to name another problem. That kept 60% of answers inside the list. It isn't a reason to stop quoting you in full, but the note alone is weak. That belongs to "Decide what the writing standard is and what carries it". The test the research says nobody has run belongs to "Decide how we'll know the writing works": the same open task with and without an example list, counting what's found outside the list.