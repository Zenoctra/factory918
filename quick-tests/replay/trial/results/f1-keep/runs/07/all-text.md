I tried to post your round-one answers word for word as a comment on the ticket, and the post was declined. I haven't retried. They're saved in a local file, and I'll put them in the resolution comment when the ticket closes, unless you'd rather I post them now.

## What I took from your answers

- **Q2: settled on (b).** I'm pinning your point about dense terms as a hypothesis to test, not a rule yet. One precise term (your micro-genre) may carry what would otherwise take many literal rules. The test asks two things: how many rules a model follows, and whether a term that pulls in several rules still needs some of them stated outright. It goes to "Decide how we'll know the writing works" and "Decide what the writing standard is and what carries it" when this ticket closes.
- **Q3: settled on (a), with one correction.** You read me as saying the evidence shows both kinds of bug get found. That's only half true:
  - **A bar changes what gets reported, not what gets found.** The radiologists kept searching. (a) fixes this half by moving the bar to a later step.
  - **What a reader is focused on can change what it sees at all.** That's the gorilla study. A reviewer pointed at edge cases may never notice the bug you wanted. Your worry is this half, and (a) doesn't fix it.

  The evidence for your worry points to a second pass with an open-ended brief. In Shin's preprint, that pass recovered every finding the focused pass hid. That makes it a question about how review is organized, not about wording. It's Q8 below.
- **Q5: settled by your answer, which beats my options.** As I understand it:
  - **In `safe`,** a budget never reaches a brief. Cost and time are only measured afterwards, to look for savings.
  - **In `eco` and Let It Rip,** a budget reaches a reader only if you set it, and only after you've been asked how much it should count. Let It Rip adds a wall-clock budget, and the same rule applies to it.
  - **When in doubt, leave the budget out.** If it seems important and nobody can ask you, it goes in as information. It is written as binding only with your approval.

  The story you told, where a predicted halving of token use was turned into a closing requirement, is the same mistake as P109's "at most" list: a prediction turned into a rule.

## Q1 in practice

Here it is again, more concretely. Ask two questions of any rule:

1. **Is it about the goal, or about the method?** "The goal" covers what's wanted, what done means, and whose decision something is. "The method" is how the reader gets there.
2. **Who said it?**

From those two answers:

- **An agent writing a brief can make a rule binding only by passing down what you, the ticket or AGENTS.md said about the goal**, plus what it owns itself, such as which files it has given to another subagent.
- **You can make anything binding, including a method.** You've done that with the delegation rule.
- **Everything else the writer knows goes in as advice with its reason, or stays out.**

Some rules run through the test, as illustrations only:

| Rule | About | Who said it | Comes out |
|---|---|---|---|
| Never push to `main` | whose decision (you merge) | you | binding |
| The orchestrator never writes the code | method | you, after it was broken while known | binding, because you set it |
| Don't edit files another subagent is working in | whose decision (that subagent's) | the orchestrator, which made the assignment | binding |
| Read only the diff | method | an orchestrator, to save cost | not binding: "the diff is here; the rest of the repo is yours to read" |
| "The bug is probably in `parse.ts`" | the writer's guess | an orchestrator | not a rule at all, and left out, because it leads the reader |
| Cite a `spec:` line or the finding is sent back | what done means | the review script | a bar on finishing, so by Q3 it moves to the filter step |

## Round two

❓ **Q4 - What happens when the reader leaves the writer's route, or a binding rule fights the goal?** These are the five mechanisms the factory has now:

1. **Ask first.** "Say so loudly and get a sign-off before breaking it." This is in both AGENTS.md files.
2. **Obey first, explain after.** "Follow the file and tell me why your instinct differed" ([template/AGENTS.md:16](template/AGENTS.md:16)).
3. **Decide and record.** Where the spec is silent, the agent makes the call and writes a Provisional decision you can overrule.
4. **Skip visibly.** poteto-mode allows a step to be skipped with a `skip: <reason>` line, except delegation, where skipping is forbidden.
5. **Send it back to the artifact.**
   - A writer's flags must end `fixed` or `accepted: <reason>`.
   - A writer that can't implement a table cell stops and reports it.
   - A design hole amends the ticket.

Where they conflict:

- 1 says stop and ask, 2 says comply and explain, and 4 says skip and note.
- 1 also fights "never block on the human".
- None of them says what a subagent does, since a subagent has nobody to ask.

➡️ Replace 1, 2 and 4 with one rule:

- **Advice about method:** the reader uses its judgment. Its report always says where it took another route and why, or says it took none.
- **A binding rule that fights the goal:** in a live conversation with you, ask (that is 1). Unattended, stop that part, report the conflict to the rule's owner, and carry on with the rest.
- **Never:** shrink the goal to fit a rule.

3 and 5 stay. They handle gaps in the spec, not rules that fight the goal, and 5 already works this way.

---

❓ **Q6 - Do the verdicts in the table above match yours?** If any row comes out wrong, the test is wrong, and I'd rather fix it now.

➡️ I'd stand by all six.

---

❓ **Q7 - How are binding rules worded, and where do they live?** The research points to four things:

- **Plain wording with the reason.** Current Claude over-applies emphatic rules.
- **State what to do, not only what not to do.** A prohibition keeps the forbidden idea active and gives no alternative.
- **Repetition gets read past.** Text repeated everywhere becomes boilerplate.
- **Every added rule costs attention.**

The options:

- (a) Each binding rule is stated once, where the reader will meet it: AGENTS.md, or a hook's refusal message, which arrives at the moment of the act with the reason and a way forward. A brief repeats a rule only when its reader wouldn't otherwise meet it.
- (b) Every brief restates the binding rules that apply to it.

➡️ (a). Your dense-term point fits here too: one well-chosen phrase may carry a group of rules, which the test from Q2 would check.

---

❓ **Q8 - Where does the review system you described live?** By that I mean multiple passes, a second open-ended pass, a verifier that sorts findings by kind, a wider range than bugs, and `interrogate`, which is vendored and leads the witness. This map's destination is the writing: how reviewers' briefs are worded, including the template prototype. Which reviewers run, how many passes, and what each one looks for is process.

➡️ Give it its own map, opened with your Q3 words as its starting note. This map then feeds it the writing rules. On this map, I'd add one line under Out of scope pointing to it. Changing `interrogate` itself will need a patch, because it's vendored.