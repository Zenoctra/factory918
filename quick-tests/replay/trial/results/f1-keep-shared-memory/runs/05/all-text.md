His answers from this round only existed in a scratch file, and that file is gone, so I'm posting them word for word on the ticket now. The map's other comments were saved the same way.

---

The comment with your round-one answers was declined, so for now they exist only in this conversation. If you want them on the ticket, or anywhere else, tell me where and I'll save them there. I did update my own memory. It used to hold the old "protect the world / shape the search" test. It now holds your Q1–Q3 answers, and your budget rule has a note of its own.

## Q1 in practice

Here's what (c) means in practice, read together with your Q5 answer. You said processes you require stay required even when a broader goal like wall clock would pull against them. So the test comes down to two questions you can ask about any rule:

1. **Who said it has to hold?** Only you can make a rule binding, or the person who owns that decision. If a subagent wrote the rule into a brief on its own, it doesn't bind.
2. **Is it about what you want, or about how to get there?** When you require a process, it binds, and it carries its reason. Anything someone else adds about how to do the work arrives as advice with a reason. The reader may do better.

Five real rules, sorted by those two questions:

| Rule | Who made it hold? | Result |
|---|---|---|
| Never push to main | You | Binds. A hook holds it. |
| The orchestrator never writes the code itself | You, with evidence | Binds. It's a process you required. |
| A review brief's "read only the diff" | A subagent, to save tokens (#33). Nobody asked for it. | Doesn't bind. At most: "the change is in these files." |
| "Token burn must halve to close the ticket" | A model, from a prediction | Doesn't bind. This is your Q5 story. |
| The knowledge skill's "never read more than 150 lines at once" | No recorded owner or reason | Advice at most, and only if someone finds the reason. |

The table only illustrates the test. The test itself is the two questions.

## Q4, with the five mechanisms laid out

Today the factory gives five different answers to "this rule doesn't fit my task":

1. **Ask first.** "Say so loudly and get a sign-off before breaking it" ([AGENTS.md:26](AGENTS.md:26), [template/AGENTS.md:20](template/AGENTS.md:20), taken from Theo). A subagent running alone has nobody to ask. The rule also pulls against "never block on the human for reversible work."
2. **Obey, then explain.** "Follow the file and tell me why your instinct differed; that is how the rules here get better" ([template/AGENTS.md:16](template/AGENTS.md:16), your own sentence).
3. **Decide and log.** Where the spec says nothing, the agent decides and writes a Provisional decision you can overrule. The manual also says to reread the philosophy "when a rule fights you."
4. **Skip openly.** A playbook step the agent drops stays in its list as `skip: <reason>` (poteto-mode, from upstream). There is one exception: skipping delegation is forbidden.
5. **Send it back into the record.** Writer flags end in `fixed:` or `accepted: <reason>`, or the review script refuses to run. A writer who can't implement a test case as written stops and reports it. A design hole amends the ticket. Bad acceptance criteria go back to you.

The conflict is between 1, 2 and 4. Faced with the same situation, they say ask first, obey first, and skip with a note. Which one an agent follows depends on which file it read most recently.

My proposal:
- **A rule you made binding:** this keeps 1, adapted for subagents. "Asking" becomes stopping that part, reporting the conflict to you, and carrying on with the rest.
- **Advice about how to work:** this generalizes 4. The reader may take another way, and its report always says where it did and why, or says it took none.
- **3 and 5 stay unchanged.** They cover gaps and records, not overruling.
- **2 changes, and that's yours to decide.** Under Q2, the advice in the file becomes a resource, so "follow the file first" would apply only to rules you made binding. Your learning loop survives, because the report still says where the agent differed and why. What changes is that the agent no longer complies before explaining.

➡️ Adopt the one mechanism, with 2 narrowed to rules you made binding.

## Q3: your worry is fair, and I overstated the evidence

The evidence says a reporting bar doesn't stop bugs being *found*; it stops them being *reported*. It doesn't say a reviewer chasing edge-case input bugs also finds the kind you care about. What the reviewer focuses on decides what it sees, whether the brief set that focus or the reviewer drifted into it. That's the gorilla study. So an open brief alone doesn't guarantee coverage. The answer to that is your own: more than one pass. Q6 below takes it up.

## Q5

Understood, and saved:
- **Safe:** budget never shapes the process, and is only measured afterward.
- **Eco and Let It Rip:** a budget is interviewed before it reaches any brief, and Let It Rip adds wall clock. When in doubt, it's left out. If it seems important and nobody can ask you, it goes in as information. It binds only if you approved it.

---

## Round two

❓ **Q4 again:** see above.

---

❓ **Q6 - When one kind of finding matters most, how is that said without narrowing the reader?** The options:
- (a) A slight push in the open brief: "we are especially wary of X."
- (b) A separate pass whose whole task is X, run alongside the open one. Each reader gets one clear job, and a verifier sorts the combined findings.
- (c) Say nothing, and rely on the verifier.

The research cuts against (a) in particular. Atypical examples pull answers toward them more than typical ones do, and naming part of a set lowers recall of the rest. So the push would buy X at the cost of everything else. In the one model study of a narrow task, a second reader with an open brief recovered what the narrow one missed.

➡️ (b). It's your "multiple passes", made the rule for any finding the writer cares about most.

---

❓ **Q7 - How are binding rules worded and held?** The research says current Claude reads literally and over-applies emphatic wording ("NEVER", "CRITICAL"). It also says a bare "don't" keeps the forbidden idea active without saying what to do instead. The options:
- (a) Each binding rule is stated once, in plain words, with its reason. Where it reads naturally, it says what to do rather than what not to do ("merges go through Manuel"). It's held by a hook where one can hold it, and the hook's refusal message carries the reason and a way forward. Briefs point to the rule rather than restating it.
- (b) The rule is restated in every brief it touches, for safety.

➡️ (a). Restating it everywhere is the rule-count cost you pinned, and it makes the rule read as boilerplate.

---

❓ **Q8 - Where do your two side notes go?**
- The "micro-genre" idea: one term that pulls a whole cluster of rules with it, plus experiments on how many rules get followed and which need an extra push. It's a measurement question, so I'd put it on "Decide how we'll know the writing works", and cross-link it from "Decide what the writing standard is and what carries it."
- "A review system of our own" goes under this map's Not yet specified, in your words, for now. Whether it becomes its own map gets decided when the frontier reaches it.

➡️ Both as above. Those edits, like saving your answers, wait on how you want tracker writes handled, since the comment was declined.