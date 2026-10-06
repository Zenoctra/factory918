Posting your answers to the ticket was denied, so I didn't retry. The comment is drafted word for word in my scratchpad and I'll post it if you want it there. Your budget answer is already saved as a standing rule in my memory.

## Q1, in practice

For each rule, ask two things:

1. Is it about **what the job is**, or **whose decision something is**? Or is it about **how to do the job**?
2. Did the person who owns that decision **actually decide it**?

If the answer to both is yes, it's a rule and the reader follows it. Otherwise the reader gets it as information with its reason, or it gets cut. Some real rules from the factory, sorted:

| Rule | About | Who decided | Result |
|---|---|---|---|
| Never push to main | whose decision (merging is yours) | you | binds |
| The orchestrator never writes code itself | how, but… | you, with evidence, and a hook holds it | binds |
| Don't edit files another subagent is working in | whose decision (that subagent's) | the orchestrator, which owns that assignment | binds |
| "Read only the diff" in a review brief | how | an orchestrator guessing where bugs are | doesn't bind. Becomes "the diff is here, the ticket is #N" |
| `knowledge`'s 150-line reading cap | how | nobody recorded a reason | doesn't bind until you decide it, or it becomes a tip with its reason |
| "Only report high-severity bugs" | how it's finished | — | Q3 moves it out of the brief |

## Q3: your worry is a different effect from the one I cited

I need to correct something. The evidence says a **bar** reduces what gets *reported*, not what gets *found*. Your worry is about **focus**: an open reviewer chasing edge-case input bugs could read right past the kind you care about. The evidence says focus decides what gets seen. In the gorilla study, what people were counting decided what they noticed. That cuts both ways, and a "slight push" toward one bug type would dim everything else the same way.

So one reviewer can't be both open and focused. What the evidence supports is separate passes: one open pass, plus a focused pass for each kind you care most about, and a verifier that rates them all. In Shin's preprint, a separate open-ended reviewer recovered everything the focused one missed. This is the multi-pass review system you described. (a) still holds for each brief; the "be wary of X" goes into its own pass instead of a push inside the open one.

## Q4: the five mechanisms that exist today

1. **Say so loudly and get a sign-off first.** [AGENTS.md:26](AGENTS.md:26), and [template/AGENTS.md:20](template/AGENTS.md:20), taken from Theo. A subagent has nobody to sign off, and this fights "never block on the human".
2. **Follow the rule, then say why your instinct differed.** [template/AGENTS.md:16](template/AGENTS.md:16). This is the opposite default: comply first.
3. **Where the spec is silent, decide and record it as Provisional so you can overrule it.** PHILOSOPHY, DECISIONS, Ticket step 5.
4. **Skip a step visibly** with `skip: <reason>`. This is from upstream pstack, except for delegation, where [feature.md:12](template/.agents/skills/poteto-mode/playbooks/feature.md:12) forbids skipping.
5. **Stop and send it back.** A writer flag must end `fixed:` or `accepted: <reason>` before review runs. A writer that can't build a test cell as written stops and reports it. A design hole amends the ticket with a dated line. Bad acceptance criteria go back to you.

How my proposal maps onto them:
- **Taking a different route:** the reader just does it and reports where and why. That's 4 widened, without the delegation exception, because delegation is a rule that binds.
- **A binding rule fights the goal:** in a conversation with you, it's 1 as written, since you're there to sign off. Unattended, it's 5 widened: stop that part, report to the rule's owner, and carry on with the rest.
- 2 goes away. "Comply first" is the controlling wording the research warns about.
- 3 stays as it is. It covers a gap in the spec, not a conflict with a rule.

## Round two

❓ **Q4 (again)** - **Accept that mapping?** Two cases are handled: a conversation with you, and an unattended run. Nobody ever shrinks the goal to fit a rule.

➡️ Yes.

---

❓ **Q6** - **How are the rules that bind worded and held?** The research points four ways:
- Emphatic wording ("NEVER", "CRITICAL") makes current Claude models over-apply a rule.
- A bare "don't" keeps the idea active and doesn't say what to do instead.
- A reminder that arrives at the moment of use works far better than a general one.
- Text repeated in every brief gets read as boilerplate.

The options:
- (a) Each rule is stated once, where its owner set it, in plain words with the reason and what to do instead. Structure holds it where it can, and the hook's refusal message carries the reason and a way forward. The git guard already does this: "Use --force-with-lease on your own branch, or ask". A brief restates a binding rule only when it's specific to that job, like which files another subagent owns right now.
- (b) Every brief restates the binding rules that apply to it.

➡️ (a). Subagents load AGENTS.md anyway, and a hook's message arrives exactly when the rule matters.

---

❓ **Q7** - **Where does the review system you described go?** The review system is the multi-pass design you described under Q3: open and focused passes, a verifier, and recall measured against planted bugs. This map's destination is about writing. The review-brief wording is already in "Prototype brief templates for the recurring lane jobs". The system itself is process, not prose.

➡️ Its own map, opened after this one, with this map's decisions as inputs. I'd note it under this map's Out of scope so it isn't lost.

---

I'll record your co-pulling-terms idea as an experiment for "Decide how we'll know the writing works": test how many rules get followed, and whether one strongly associated term carries several rules. That goes in when I close this ticket.

One note on naming: the mode you called Safety Mode is the `safe` tier.