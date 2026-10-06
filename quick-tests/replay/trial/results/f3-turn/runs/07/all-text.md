Yes, the round changes. I've read the whole research note: `docs/research/wording-and-reader-context.md`, on the branch `research/wording-and-reader-context`. Three of my earlier premises don't hold up against it.

1. **The research gives the reason behind your correction.** Garfinkel and Suchman argue that no instruction written in advance can contain the situation it will meet. Survey research measured the same thing. Scripted questions got unusual cases right 28% of the time. When the interviewer could explain, they got 87%. The unusual case is exactly what a review or research lane exists to catch. So a rule about the route isn't just wrong sometimes. It is wrong exactly where the lane matters most.
2. **My Q1 counted "what done means" as binding. That is where the most damaging rules hide.** Four findings show it:
   - A reporting bar makes a reviewer find a bug and then leave it out.
   - A measure quietly takes the place of the goal.
   - Commanders' intent statements turned out to be full of method.
   - Our own `spec:` gate is a case.
3. **My Q3 assumed the reader notices when a rule fights the goal.** The evidence says people and models who misread rarely know it, and rarely ask.

What the research can't give: no study tests a limit on a model's method as such. Most of what follows is evidence about people plus Anthropic's guidance without numbers. For Opus 5.5 these are hypotheses until the ticket "Decide how we'll know the writing works" measures them.

Updated terms:
- **Goal:** what the owner will do with the result, and what done looks like.
- **Proxy:** a measurable stand-in for the goal: a count, a threshold, a required citation, a format, a length.
- **Route:** how the reader gets there.
- **Binding rule:** a rule the reader may not overrule by itself.

---

❓ **Q1 - What makes a rule binding?** Last round I said a rule binds when it describes the task and its owner set it. Two things change.

First, "done" splits in two. The goal binds. A proxy only tells the reader how the owner will judge the result. When a proxy fights the goal, the goal wins and the reader says so. The evidence:
- **Radiologists.** Adding a second nodule didn't change their accuracy or how long they searched. It made them reluctant to report what they had found (Berbaum 2015).
- **Claude.** Anthropic's guide for Opus 4.8 says a prompt like "only report high-severity issues" leads the model to find the bugs and then leave them out of its report.
- **Managers.** Managers paid on one measure acted as if that measure were the strategy, without noticing. Merely knowing they were measured was enough, with no pay attached.
- **Our own case.** The Standards brief demands a `spec:` citation from a ticket it never shows. One reviewer in the eval obeyed and filed nothing on a PR that had four real bugs.

Your principle-over-proxy rule already says this ("a prediction, not a constraint"). Q1 would make it the general test.

Second, a case that shows the line isn't about reading at all: "a later review round doesn't read the earlier rounds' findings." That limits what the reader may look at, yet I think it binds. An independent judgment is the goal of that reviewer, not a route to it. Forensic science does the same with blind verification. Fingerprint experts shown context contradicted their own earlier matches (Dror). So a rule about reading can be goal or route, depending on what it protects. Your two owner-set rules still pass:
- **The delegation rule.** It was broken knowingly until a hook held it ([ledger.md:16](docs/agents/ledger.md:16)).
- **The mandatory trail review.** It caught owner errors three times out of three.

The options:
- (a) A rule binds when it states the goal or a limit of authority, and its owner set it. Proxies are information about how the result will be judged, and they yield to the goal.
- (b) Anything the owner set binds, proxies included.
- (c) No general test.

➡️ (a).

---

❓ **Q2 - How does the writing carry what the writer knows about the route?** The research separates three kinds of content I had lumped together:

- **Facts about the territory:** the project's state, tool quirks, what is already known. Give these generously. A lane starting cold knows little about this project, however capable it is. Explicit links help readers like that (McNamara). Task-relevant context improved readers' accuracy in all 16 medical studies reviewed (Loy & Irwig). "Two plain commands, because the worktree guard refuses `git` inside `$(...)`" is a fact about the territory, not a method.
- **The writer's own conclusions and hopes:** leave them out. Telling a model the code was bug-free cut vulnerability detection from 97% to 4% for a small model, and from 96% to 89% for Opus 4.5.
- **Method:** offer it only as something the writer knows, with the reason.

Wording matters more for our readers than for people. Anthropic says current Claude models read instructions literally and over-apply emphatic ones. The research puts it this way: "a literal reader makes every word in a brief bind harder, including the words meant only as illustration." In people, the same limit lowered creativity when worded as control, and didn't when worded as information (Koestner). So "do X" and "X worked last time, because Y" are a wall and a hint.

One pull in the other direction: don't add a line like "feel free to deviate." Assigned dissent was weaker than real dissent and mostly bolstered the original view (Nemeth). My own inference is that a literal reader might deviate just to show it can. The wording should carry the freedom.

Where method does help: step-by-step guidance helps novices and simple tasks, and hurts experts and complex, novel tasks (expertise reversal, d = +0.51 against −0.43).

The options:
- (a) Leave method out entirely.
- (b) Give facts about the territory generously, leave out conclusions, and offer method as knowledge with its reason. Step-by-step method only for jobs shown to be routine. The report notes where the reader took another route.
- (c) Method as defaults the reader may override.

➡️ (b).

---

❓ **Q3 - What happens when a binding rule or a proxy fights the goal?** My earlier answer had the reader stop that part and report the conflict. That depends on the reader noticing, and the evidence says it mostly won't:
- People told they could ask for help asked on 4% of the occasions help was given.
- Models on underspecified coding tasks almost never asked.
- Claude 3.7 Sonnet mentioned a hint it had used 25% of the time.

So the failure I called (c), narrowing the goal to fit the rule, isn't a choice the reader makes. It happens without the reader noticing. The reviewer in the `spec:` case didn't report a conflict. It just obeyed.

Two findings point at fixes:
- **Separate the finding from the filtering.** Anthropic recommends asking for every finding with a confidence and a severity, and filtering in a separate step. One 2026 preprint found that an open-ended critic recovered every finding a narrow instruction had suppressed. It is a single-author preprint.
- **Make the account expected, not optional.** Readers told that definitions were essential checked them on 81% of questions. Readers told that definitions were available checked on 23%.

The factory currently has five mechanisms for departing from a rule, and they disagree: sign-off, follow-then-explain, record a Provisional decision, `skip: <reason>`, and `accepted: <reason>`. This decision replaces them.

The options:
- (a) Stop that part and report, as before.
- (b) Same as (a), plus every report must include what the reader saw or wanted to do but didn't because of a rule or bar, and why.
- (c) Same as (b), plus an open-ended second pass after any lane whose brief had to be narrow.

➡️ (b). With you present, a session asks you. Without you, the lane stops that part and reports. I'd hand (c) to the measurement ticket, since its evidence is one preprint.

---

❓ **Q4 - Who may write a binding rule into a brief?** My answer is the same; the reasons are stronger. Interrogators who were led to expect guilt asked questions that presumed guilt (Kassin). The orchestrator always holds a hope about the answer, so its rules about the route tend to encode that hope. Commanders' intent statements, in practice, came out full of method (Shattuck).

There is also something new for templates. Text repeated across every item gets read past, and text unique to one item gets read as the point (Igou). So a line the orchestrator adds for one job outweighs the fixed rules around it.

➡️ The orchestrator passes your rules down, binds only what it owns, and offers everything else as Q2 content.

---

❓ **Q5 - What if the owner really needs a narrow output?** This used to be about budgets. The research shows one pattern across several kinds of narrowing:
- **Tight output budgets** hurt reasoning. Phi-4-reasoning fell from 72% to 54% at 1,024 tokens.
- **Required JSON** hurt reasoning. Answering freely and converting afterwards mostly removed the loss. That study is contested.
- **Reporting bars** make readers withhold what they found.

Narrowing costs a lot when it's applied during the work, and little when it's applied afterwards.

The options:
- (a) The reader applies the narrowing during the work: a severity bar, a length, a format, a budget.
- (b) The reader does the work openly, and the narrowing happens as a separate step afterwards: a filter, a conversion, a summary for you. Either the same reader does it at the end, or another lane does.
- (c) No narrowing.

➡️ (b). A budget you set yourself still binds. It's stated as a fact with its reason, and the reader plans within it.

---

❓ **Q6 (new) - How is a binding rule worded?** The evidence on wording:
- **Emphasis.** Anthropic says current Claude models over-apply emphatic wording ("CRITICAL: you MUST"), and generalize correctly from a stated reason.
- **Prohibitions.** A prohibition keeps the forbidden idea active and doesn't say what to do instead, so the model falls back on some other fixed default. This was measured in older and smaller models. It isn't shown for current ones.

Our own cases:
- "Subagents never launch their own dev servers" lost Theo's reason when it was adopted.
- My memory says "never tell ANY subagent what it can't look at." A literal reader would apply that to the blind-review rule in Q1 and break it.
- The git guard's block message already names a way forward: use `--force-with-lease` on your own branch, or ask.

The options:
- (a) Plain wording, with the reason, the scope (what it covers and what it doesn't) and what to do instead. A hook's block message carries the same.
- (b) Emphatic wording for the few binding rules, so they stand out.

➡️ (a). The reason is what lets a literal reader apply the rule where it's meant and not beyond. Whether binding rules sit in prose or in a hook belongs to the ticket "Decide where each piece lives and when it reaches the writer."

---

The research note warns that its own section headings aren't the full space. The same goes for these six questions. Once this round settles, I'll rewrite the memory that still uses the old test.