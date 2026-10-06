I've saved your answers word for word for the resolution comment. Your Q5 rule on budgets is now a standing memory, so it carries into later sessions.

Two answers still need you, Q1 in plain terms and Q4 with the five mechanisms listed. One new question comes out of your Q3 note. The rest is settled.

---

### Q1 again, in plain terms

To decide whether a rule in a brief binds the reader, ask two things: **who said it must hold, and was that their call to make?**

- **You** can bind anything: the goal, the scope, and the process when you choose to require one.
- **An orchestrator** can bind only the coordination of its own run: which files other lanes are editing right now, where results go, which branch to use. It can't bind how the reader does its work.
- **Everything else** goes in as information with its reason, and the reader uses it or doesn't.

| Rule in a brief | Who said it | Their call? | What happens |
|---|---|---|---|
| Never push to main | You | Yes | Binds |
| The orchestrator never writes the code | You, with evidence | Yes, it's your process | Binds |
| Don't edit `foo.ts`, another lane is in it | Orchestrator | Yes, it runs the coordination | Binds |
| Read only the diff | Orchestrator, to save tokens | No, that's the reader's method | Becomes "the diff is here, the ticket is here" |
| Check the migration file first | Orchestrator, from last run | No | Becomes "last run, the bug was in the migration file" |

Writing it out this way turned up a flaw in (c) as I first worded it. It said a rule must be about the task *and* be owned. The delegation rule is about method, so that wording would have stopped it binding. Your Q5 answer contradicts that: you can require specific processes. So ownership does the deciding. The "about the task" part only shows where an orchestrator's authority ends.

❓ **Q1** - **Is this the version you're agreeing to?** It says a rule binds when someone whose call it is said it must hold. You can bind process, an orchestrator can bind only coordination, and everything else is information.

➡️ Yes. It's simpler than what I first wrote, and it's what you seem to have meant.

---

### Q4 again, with the five mechanisms

These are the five ways the factory currently tells a reader what to do when a rule gets in the way:

1. **Ask first.** "If a rule fights the task in front of you, say so loudly and get a sign-off before breaking it." It's in [AGENTS.md:26](AGENTS.md:26) and [template/AGENTS.md:20](template/AGENTS.md:20), copied from Theo. No text says how a subagent running unattended gets that sign-off.
2. **Obey, then explain.** "Follow the file and tell me why your instinct differed" ([template/AGENTS.md:16](template/AGENTS.md:16)). This is the reverse of 1: comply now, object afterwards.
3. **Decide and record.** Where the spec is silent, the agent makes the call and writes a Provisional row in `DECISIONS.md` so you can overrule it.
4. **Skip with a note.** In poteto-mode, a step the agent chooses not to do stays in its list as `skip: <reason>`. [feature.md:12](template/.agents/skills/poteto-mode/playbooks/feature.md:12) forbids this for the delegation step.
5. **Stop that item and send it back.** Writer flags must end `fixed: <sha>` or `accepted: <reason>`, and a script refuses the review until they do. A writer who can't build a test-table cell as written stops and reports it. A design hole gets a dated line on the ticket.

**How they conflict:** 1 says stop before breaking a rule. 2 says comply, then object. 3 and 4 say carry on and leave a record. 5 says stop on that one item and hand it back. 1 also fights the standing rule "never block on the human for anything reversible."

**What I proposed, against these:**
- **The writer's advice on how to do the work** (not binding under Q1): the reader uses its own judgment. Its report always says where it took a different route and why, or that it took none. This is 3 and 4 made general.
- **A binding rule that fights the goal:** the reader stops that part, reports the conflict to whoever owns the rule, and carries on with the rest. This is 5 made general. When you're in the conversation, reporting to the owner just means asking you, so 1 survives as that case.
- **Retired:** 2. "Obey, then explain" makes the reader follow even advice that wasn't binding.
- **Never allowed:** shrinking the goal to fit a rule.

❓ **Q4** - **Does that replacement work for you?**

➡️ Yes. It keeps what works in 3, 4 and 5, gives 1 a form an unattended subagent can actually follow, and drops 2.

---

### Your Q3 worry, and where review goes

**The worry.** I need to correct what I implied. The evidence doesn't show that a reviewer with no focus finds every kind of bug. It shows two narrower things:
- A bar on what to report hides findings the reviewer already made.
- A narrow focus hides what lies outside it.

Attention is still finite, so your worry about one wide pass is fair. The research points to fixing it with more readers, not with a tilt in one reader's brief:
- A "slight push" toward one bug type acts like a one-item list. Examples copy themselves into the answer, and naming part of a set suppresses recall of the rest. So the headache you predicted is what the research predicts.
- In Shin's study, a second reader with an open brief recovered every finding the narrow one missed.
- If a kind of bug matters enough to name, it gets its own pass. The general reviewer's brief stays open.

That is your "multiple passes" point, and it's where your review-system idea starts.

❓ **Q6** - **Where does "a review system of our own" live?** Your point covers several things:
- spec-review hunts mostly for bugs;
- interrogate looks much wider but leads the witness;
- review studies brag about having no false positives while missing half the planted bugs;
- review may be the most important step in the factory.

That is more than wording, and the map's destination is the writing. The ticket "Prototype brief templates for the recurring lane jobs" will rewrite the review briefs, but not the review process: how many passes, which readers, and how findings are filtered.

➡️ Make it a map of its own. Chart it after this map's standard and templates are decided, so it inherits them. Until then, I'd add one line under this map's "Not yet specified" pointing to your words here, so the idea isn't lost.

---

### Recorded, no answer needed

- **Q2: (b).** I'll post your point about rule count and co-pulling terms on the ticket "Decide how we'll know the writing works", as an experiment to run. It asks how many rules a model can follow at once, whether one term that pulls in a whole cluster beats listing the rules (your micro-genre example), and which rules in a cluster still need their own line. Your words go there verbatim.
- **Q5.** In `safe` (the first mode's name), a budget never shapes process and is only measured afterwards. In `eco` and Let It Rip, a budget gets into a brief only after you've been asked how much it should weigh. When in doubt, leave it out. If it seems important and nobody can ask you, it goes in as information. It is written as binding only with your approval. This replaces the options I offered.