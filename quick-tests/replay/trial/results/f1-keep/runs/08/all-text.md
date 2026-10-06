Your answers are saved word for word, and they'll go into the ticket's resolution comment as you wrote them. Before round two, here are the things you asked for or flagged.

**Q1 in practice.** Ask two questions of any rule. **Whose decision is this?** And **has that person made it?** A rule binds only when the person who owns the decision made it. By default, the route belongs to the reader doing the work. The goal, the scope, merging and the factory's design belong to you. Four rules from the factory:

| Rule | Whose decision? | Binds? |
|---|---|---|
| "Never push to main" | Yours: merging is your call | Yes |
| "Read only the diff" | The reader's: it's route, and an orchestrator wrote it to save cost | No. It becomes "the diff and the ticket are here", and the reviewer reads whatever it needs |
| "The orchestrator never writes the code" | Route, but you took that decision back on purpose, with evidence | Yes, because you set it |
| "Another lane is editing these files right now" | The orchestrator's: it assigned the files | Yes, because the orchestrator owns that assignment |

What this stops is an orchestrator turning its own guess about the route into a wall. It can bind only what it owns or what you handed it. Writing it out plainly also fixed a muddle in how I worded (c): ownership is the test, and what a rule is about only tells you who owns it.

**Your Q2 note on terms that carry many rules.** I'll keep it in full. I'll also put a pointer on two tickets: "Decide what the writing standard is and what carries it", because it's a way of writing rules, and "Decide how we'll know the writing works", because you want it tested: how many rules get followed, and whether one term carries several.

**Your Q3 worry is real, and the evidence doesn't make it go away.** The research shows two different things:
- **A bar hides what was found.** Your answer (a) fixes this.
- **Attention hides what was never seen.** The gorilla study shows this. An open brief doesn't make a reviewer see everything. It only means the writer's guess no longer decides what gets skipped. A single open reviewer still drifts to its own habits, and models drift to the same habits as each other.

So your instinct of several passes, then a verifier, is the fix the evidence points to. Adding a "slight push" about bug types you're wary of has a cost: naming a kind pulls attention toward it and away from the rest. One way to push without a boundary is to give the push to a second lane, so it never replaces the open pass. That's a design question for the review system, which is Q7 below.

**Q5, restated so you can correct it:**
- **In `safe`** (your "Safety Mode"), budget never shapes the work. It is only measured afterward, to look for savings.
- **In `eco`,** a budget enters only when you set one. Before it is written into a brief as binding, someone asks you how much it weighs against everything else.
- **In Let It Rip,** the same applies, and wall-clock time counts as a second budget. The mode exists for speed, but that alone doesn't mean any reader is told about speed, and it never overrides a process you require.
- **When in doubt, leave the budget out.** If it seems important and nobody can ask you, it goes in as information, not as a limit. A budget written as binding needs your approval.

---

❓ **Q4 - What happens when the reader departs from the route, or a binding rule fights the goal?** These are the five mechanisms the factory has now:

1. **Say so loudly, and get a sign-off before breaking the rule.** [AGENTS.md:26](AGENTS.md:26) and [template/AGENTS.md:20](template/AGENTS.md:20). This is Theo's line. A subagent has nobody to sign off, and no text says what it should do instead. It also pulls against "never block on the human".
2. **Follow the file, then say why your instinct differed.** [template/AGENTS.md:16](template/AGENTS.md:16). This is the opposite default: comply first, explain afterward.
3. **Where the spec is silent, decide and record a Provisional decision you can overrule.** PHILOSOPHY, DECISIONS, and Ticket step 5.
4. **Skip a step visibly, with `skip: <reason>`.** This comes from upstream pstack. Delegation is the exception: [feature.md:12](template/.agents/skills/poteto-mode/playbooks/feature.md:12) forbids skipping it.
5. **Send it back up.**
   - A writer's flags must end `fixed:` or `accepted: <reason>`.
   - A writer that can't build a table cell as written stops and reports.
   - A design hole amends the ticket with a dated line.
   - Untestable criteria go back to you.

A subagent that reads several of these gets different answers to the same situation: ask first, comply first, decide and log, or skip and log.

➡️ Two mechanisms replace the five:
- **For route knowledge (2, 3 and 4 merge here):** the reader uses its judgment. Its report always says where it took another route and why, or that it took none.
- **For a binding rule that fights the goal (1 and 5 merge here):** the reader stops that part, tells the rule's owner, and carries on with the rest. When you're in the conversation, "tell the owner" means asking you, so 1 survives for the session you type into.
- **In both cases,** the reader never shrinks the goal to fit a rule.

---

❓ **Q6 - Does "a prediction never becomes a requirement" reach beyond budget?** Your story was about tokens: a model turned "this might halve token use" into a closing condition, then gutted the design to meet it. The same thing happened with the "at most" list in P109, and with criteria lanes have written onto tickets. Should the rule be general? Under it, any predicted effect (a saving, a count, a speedup) stays a prediction unless you approve it as a requirement.

➡️ Yes. It is your Q5 rule with the word "budget" removed, and it follows from Q1: a prediction belongs to whoever made it, and only you can make it bind.

---

❓ **Q7 - Where does the review system you described go?** You described several passes, better briefs, a process of the factory's own, and recall measured against planted bugs, not just how few false positives there are. That is bigger than this map, which is about writing. The options:
- (a) Fold it into "Prototype brief templates for the recurring lane jobs".
- (b) Keep the review briefs in that prototype ticket, and give the review system as a whole its own wayfinder map later, carrying your words from this answer.
- (c) Add it to this map's "Not yet specified" section.

➡️ (b). The briefs are writing, and they belong here. The number of passes, the verifier, and how review is scored are process design, and they deserve their own map. Until that map exists, I'd record it on this map under "Out of scope", linked, so it isn't lost.

---

❓ **Q8 - How is a binding rule worded and enforced?** Once a rule binds, there are two places to hold it:
- **In the prose of every brief,** where it adds to the rule count you pinned in Q2.
- **In a hook or script that refuses at the moment it matters,** with the reason and a way forward in the refusal message. The git guard already works this way: "Use --force-with-lease on your own branch, or ask."

The research says plain wording beats emphatic wording ("CRITICAL: MUST" makes current Claude over-apply a rule), and a bare "don't" names the forbidden thing without saying what to do instead.

➡️ Wherever a hook or script can hold a binding rule, it holds it there, and its refusal message carries the reason and a way forward. The brief then mentions the rule once, in plain words, or not at all. Prose alone carries only the binding rules no tool can check. The rung each rule can reach is decided on the map's ticket "Decide where each piece lives and when it reaches the writer". This ticket decides only the order of preference.