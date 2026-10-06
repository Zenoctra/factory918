I tried to post your answers on this ticket as a comment so your words are saved word for word, as the earlier rounds were. The permission was denied, so I've posted nothing. They're still in this conversation, and I'll include them in the resolution comment at the end unless you want them posted sooner.

Your budget answer is settled. It's now a memory ("Budgets never bind unasked"), so it applies outside this ticket too. Your point about co-pulling terms will go to "Decide how we'll know the writing works" as an experiment to run, and to "Decide what the writing standard is and what carries it" as a principle to weigh. It doesn't change anything here.

Before round two, a correction on Q3. You wrote "if you are saying the evidence says both get found". It doesn't say that. It says a bar in the brief changes what gets reported, not what gets searched. It says nothing about a reviewer left without a focus finding every kind of bug. Models also have default habits; the research found different models give 71–82% similar answers to open questions. So your worry is real, and Q7 below takes it up.

---

❓ **Q6 - The binding test, explained again with examples.** My Q1 text had a hole, and it's probably part of why it felt abstract. Option (c) said a rule binds only if it is about the task and not the route. But the delegation rule is about the route, and I also said it binds because you set it. Both can't be true. Here is the version I think you actually agreed to, as two questions anyone can ask of a rule:

1. **Who said it must hold?** Only you can make a rule about *how* the work is done binding. An orchestrator or a lane can bind only two things: the task itself, and what it hands out (which branch, which files another lane is working in).
2. **If nobody with that authority said so, it doesn't bind.** It becomes information with its reason, and the reader may take another route.

Real cases from the factory:

| Rule | Who set it | Result |
|---|---|---|
| Never push to `main` | You | Binds |
| The orchestrator never writes the code itself | You, with evidence | Binds, even though it's about method |
| The trail review always runs | You, after it caught errors 3 times out of 3 | Binds |
| Work only in this worktree; lane B owns `auth.ts` | The orchestrator, which handed both out | Binds |
| The reviewer reads only the diff | A lane, to save tokens; nobody asked for it | Becomes information: "the change is in the diff; the rest of the repo is yours to read" |
| `knowledge` never reads more than 150 lines per call | Factory text with no recorded reason | Becomes information, or goes |
| "Report only bugs you can cite a `spec:` line for" | Factory text | Not a route rule at all; under your Q3 answer the bar moves to the filter step |

One case I can't settle without you: rules inside skills vendored from Matt and poteto. On 2026-09-24 you ruled that upstream pstack's constraints stay, and that our own text is the suspect part. Do vendored route rules count as set by you, because you chose to vendor them?

➡️ Yes to the two questions. For vendored skills: they bind as written, and we change them only through a patch, as we already do. That keeps your 2026-09-24 ruling. The audit's worst single limit ("Execute only the task and path scope the parent assigns") sits in our wrapper around pstack, not in pstack itself, so this test lets us remove it.

---

❓ **Q7 - Can a brief name what you're most worried about?** You suggested "a SLIGHT push without a boundary" toward bug types you care about, and you saw a headache coming. The evidence shows what the headache is. In the gorilla study, observers counting the black team's passes noticed the black gorilla 58% of the time, and those counting the white team's noticed it 27% of the time. Pointing attention helps the thing you point at and hides the rest. A slight push is still a push. The one model study found the same thing, and a second reviewer with an open-ended brief recovered what the focused one missed.

- (a) The open pass is never pushed. A specific worry gets its own pass with its own reader, running alongside the open pass. This is your "multiple passes".
- (b) A slight push in the open brief.
- (c) Nothing is ever named.

➡️ (a). It answers your worry without costing the open pass anything. How many passes to run and who reads which belongs to Q8's effort, not here. This ticket only decides that a worry never goes into the open brief.

---

❓ **Q8 - Where does building our own review system belong?** You named it: spec-review hunts mostly bugs, `interrogate` is wider but leads the reviewer too, and published AI review claims celebrate zero false positives while missing half the planted bugs. This map's Destination covers how review *briefs* are written. Their templates come from "Prototype brief templates for the recurring lane jobs", and their rework from "Decide the scope and order of reworking existing files". It doesn't cover the review *process*: passes, verifiers, rounds, what replaces `interrogate`. Two open tickets touch that process, "Choose each tier's review round count from the clean measurement" and "Eval the judge and trail-review models the way #103 evals reviewers".

- (a) A new map of its own, designing the review system, which uses this map's writing standard.
- (b) Fog in this map's "Not yet specified".
- (c) Fold it into the brief-templates prototype.

➡️ (a). It's at least as big as this map, and it waits on this map's standard. I'd add one line under "Out of scope" pointing at the new map once you open it, and no ticket here.

---

❓ **Q4, again - one way to handle departures, in place of the five that exist.** Here they are, and how they conflict:

1. **"Say so loudly and get a sign-off before breaking it."** In [AGENTS.md:26](AGENTS.md:26) and [template/AGENTS.md:20](template/AGENTS.md:20), taken from Theo. Ask *first*. A subagent running unattended has no way to get a sign-off, and nothing says how.
2. **"Follow the file and tell me why your instinct differed."** In [template/AGENTS.md:16](template/AGENTS.md:16). Comply first, explain *after*. That's the opposite order to #1.
3. **"Decide and record a Provisional decision Manuel can overrule."** In PHILOSOPHY and DECISIONS. This is for when the spec says nothing. It's about gaps, not about rules fighting the goal.
4. **`skip: <reason>`.** In poteto-mode (vendored). Skip a step but leave it in the list with a reason. The delegation playbook forbids this one for itself.
5. **Hand it back up.** A writer that can't implement a test cell as written stops and reports it. A design hole amends the ticket with a dated line. Writer flags must end `fixed` or `accepted: <reason>`. A criterion that can't be checked goes back to you.

So #1 says ask before, #2 says obey then explain, #4 says skip and note, and #5 says stop and hand back. A reader facing a rule that fights its goal gets four different instructions, depending on which file it read last.

➡️ My proposal:
- **Route information** (anything that isn't binding under Q6): the reader uses its judgment, and its report always says where it took another route and why, or that it took none.
- **A binding rule that fights the goal:** if the owner is present, ask, as in #1. If not, stop that part, report the conflict to the owner, and carry on with the rest, as in #5.
- **Never** shrink the goal to fit a rule.
- **#3 stays as it is**, because it's a different case: a gap, not a conflict.
- **#2 and #4 merge into the first bullet.** In practice #4 becomes the departure line, and #2 stops telling the reader to comply first.