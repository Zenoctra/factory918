Saving your answers word for word as a comment on this ticket was blocked by the permission prompt. They're kept in my scratchpad for now. I'll post them when I record the resolution, unless you'd rather keep them off GitHub.

## Where your answers leave things

**Q2 and Q5 are settled.**
- **Q5:** In `safe` (the tier you called Safety Mode), a budget never shapes the work. The factory only measures cost afterward, to look for savings.
- **Q5, continued:** In `eco` and Let It Rip, any token or wall-clock budget goes in a brief only after you've been asked how much it should weigh.
  - When in doubt, leave it out.
  - If it seems important and you can't be asked, it goes in as information, not as a limit.
  - Anything stated as binding has your approval behind it.
  - Your anecdote is the same failure as the "at most" list: a prediction from one case became a requirement nobody had approved.

**Q3 is settled, with one correction to my earlier claim.** The evidence does not say a reviewer finds every kind of bug equally well. It says something narrower: a bar on what to report doesn't stop the reviewer from finding things, it stops the reviewer from mentioning them. Your worry is a different effect, and a real one: where attention goes decides what gets seen. That's the gorilla study. So a "be especially wary of X" line is risky in its own way, because it can pull attention off everything else. The preprint's remedy wasn't a better-worded focus. It was a second reviewer with an open brief. So (a) holds for this ticket, and how to arrange several review passes belongs to the review-system work you described (Q8 below).

**Two notes for later tickets.** Your point about rule count and words that pull many related rules along with them, like your microgenre example, goes to the tickets on the writing standard and on measurement. It becomes an experiment: how many rules get followed, and whether one well-chosen term does the work of several rules.

## Round two

This round answers your Q1 request with concrete cases, gives Q4 the comparison you asked for, and adds two questions.

---

❓ **Q6 - Does test (c) give the right answer on real rules?** Here's (c) put plainly. Before a rule goes in a brief, ask two things:
- Does it describe the job (what's wanted, what done means, what isn't the reader's call), or how to do the job?
- Did the person who owns that decision say it must hold?

Only a rule that describes the job, and that its owner made firm, is binding. Anything else is advice: the reader may take another route, and says so.

Seven rules from the factory, with how (c) treats each. Tell me where the result feels wrong. That's the real test. These are samples, not the full set.

1. **"Never push to main."** It describes the job (merging is your decision), and you made it firm. **Binding.**
2. **"The orchestrator never writes the code; it delegates."** It's about how to work, not what the job is. You set it, with evidence, and a hook holds it. **Binding**, but only because you own it. This is the case that showed ownership matters.
3. **"Read only the diff and the brief"** (the old reviewer rule). How to work, added by a lane to save cost. **Not binding.** Under the earlier decisions it isn't even written as advice; it goes.
4. **"Never read more than 150 lines in one call"** (the `knowledge` skill). How to work, written by an agent, with no recorded reason. **Not binding.** If a reason exists, it survives as advice that carries the reason.
5. **"A finding isn't hard unless it cites a `spec:` line."** It looks like a description of done, but it's a gate on what gets reported, so Q3 decides it: the reviewer reports everything, and any `spec:` sorting happens in a later step. This is the "done" that sneaks in a route.
6. **"Subagents never launch their own dev servers."** Two halves. The safety half (stray servers fight over ports and outlive the task) describes the job's limits and is yours. **Binding.** The "never" beyond that is route. *My verdict here is unsure.*
7. **Each step in a pstack playbook you adopted.** Did adopting pstack make you the owner of every step, so all of them bind? Or are only the steps you singled out (delegation, the mandatory trail review) binding, with the rest as advice? pstack's own `skip: <reason>` suggests the second. *This is the case I most need your call on.*

➡️ My verdicts as given. For case 7: binding only for the steps you singled out, plus any step whose skipping a later step would have to detect. Every other step can be skipped, and the skip shows in the list with its reason.

---

❓ **Q4 (again) - One way to handle departures, in place of the five there are now.** Here are the five, so you can compare:

1. **Stop and ask first.** Both AGENTS.md files say "if a rule fights the task, say so loudly and get a sign-off before breaking it." A subagent has nobody to ask, and no text says what it should do.
2. **Obey, then explain.** [template/AGENTS.md:16](template/AGENTS.md:16): "when this file and a vendored skill disagree with your instinct, follow the file and tell me why your instinct differed."
3. **Decide, then record.** Where the spec is silent, the agent makes the call and writes a Provisional row in DECISIONS.md for you to overrule later.
4. **Skip, visibly.** In poteto-mode, a skipped step stays in the list as `skip: <reason>`. Delegation is the exception: [feature.md:12](template/.agents/skills/poteto-mode/playbooks/feature.md:12) forbids skipping it.
5. **Hand it back to the work itself.**
   - A writer's flagged risk must end `fixed: <sha>` or `accepted: <reason>`, and the review script refuses to run until each one does.
   - A writer that can't build a test case as written stops and reports it.
   - A hole in the design goes back into the ticket as a dated line.

They conflict. (1) says ask before acting, (2) says obey and explain afterward, and (3) and (4) say act and record. A subagent that reads both (1) and (3) has been told opposite things.

My proposal combines them:
- **Advice about how to work (anything not binding by Q6):** the reader uses its own judgment, and its report always says where it took another route and why, or that it didn't. This takes (3) and (4) and makes them the general rule.
- **A binding rule that fights the goal:** if the owner is reachable (you, in the session you're typing in), ask; that's (1). If not (a subagent), the reader stops that part, reports the conflict back, and finishes the rest. That's (5)'s "stop and report", made general.
- **Never** quietly shrink the goal to fit the rule.

(2) disappears. Obeying silently and explaining later is how a goal shrinks without anyone seeing it.

➡️ As proposed.

---

❓ **Q7 - How are binding rules written and held?** The research says three things:
- loud wording ("CRITICAL", "MUST") makes current Claude over-apply a rule;
- a bare "don't" names the forbidden thing without saying what to do instead;
- every rule repeated in every brief costs attention the reader needs for the job.

A hook's refusal message arrives exactly when the rule matters.

Options:
- (a) Each binding rule is stated once, plainly, with its reason, where it applies. Where a hook holds the rule, the hook's message carries the reason and a way forward, and the prose points to the hook instead of repeating the rule.
- (b) Restate binding rules in every brief, to be safe.
- (c) Leave this to the ticket that decides the writing standard.

➡️ (a). The wording standard in general belongs to that ticket. This question covers only how binding rules are stated and held.

---

❓ **Q8 - Where does your review system go?** You described a review system of the factory's own:
- several passes;
- briefs that don't lead;
- measured on missed bugs, not just false alarms;
- covering more than bugs, the way `interrogate` does.

No open ticket covers it. The closest are "Prototype brief templates for the recurring lane jobs" on this map, and "Choose each tier's review round count from the clean measurement". Neither designs a review process.

Options:
- (a) A sixth wayfinder map of its own, which inherits this map's rules on writing.
- (b) A ticket on this map.
- (c) A ticket on the map "Optimize token use and wall-clock time without losing reliability".

➡️ (a). It's as big as the other five, and its destination is a review process, not a way of writing. This map hands it the brief standard. I'd file a placeholder now so it isn't lost, and chart it when you choose.