Nothing got posted. I tried to post your answers word for word on this ticket, with short pointer comments on three sibling tickets, and that write was declined. Your answers are only in this conversation for now. Should I post them on the ticket, or hold everything until the ticket resolves?

I also rewrote my local memory note to replace the old "protect the world / shape the search" test with your Q1, Q2, Q3 and Q5 answers.

## Q1 in plain terms

**A rule binds only if whoever has the say over that thing made it binding.**

- **You** have the say over the factory. When you decide something must always happen, it binds, even if it's about how the work is done. Those are your "absolutely necessary" rules.
- **An orchestrator** has the say over almost nothing. It can pass your rules down. It can bind the little it is actually running, like "another lane is editing `ticket.md` right now, leave it alone." It can't turn its own guesses about how the work should go into rules.
- **Everything else** is what the writer knows, handed over with its reason (your Q2).

Here's how that sorts some real rules from the factory:

| Rule | Binds? | Why |
|---|---|---|
| Never push to `main` | Yes | You decide merges, and you made it a rule. |
| The trail review is mandatory | Yes | You set it, with evidence (it caught the owner's errors 3 times out of 3). |
| The orchestrator never writes the code | Yes | Yours, held by a hook. It's about method, and it still binds because you own it. |
| "Read nothing beyond this brief. Run nothing." (old review brief) | No | A lane added it to save cost. Nobody with the say made it binding. |
| `knowledge`: "never read more than 150 lines in one call" | No, unless you say so | Nobody recorded a reason or an owner. It becomes advice with its reason, something like "long files eat context, read them in parts." |

## Your Q3 worry

Your worry is still valid after (a). The research shows two separate effects, and (a) only fixes one of them:

- **Reporting bars:** a bar makes the reader hold back what it already found. Option (a) fixes this by removing the bar from the finder's brief.
- **Focus:** what the reader is looking at decides what it sees. (a) doesn't fix this. Even with an open brief, a model has its own default focus. Different models' answers to open questions are 71–82% alike, so several lanes can share the same blind spot.

The "slight push" toward certain bug types is a list in disguise. The human evidence (offered options, part-list cueing) predicts it pulls the whole search toward the named types. The answer the evidence supports is structural, not more wording. In Shin's preprint, a separate critic with an open brief recovered every finding the narrow lane had left out. That's Q8 below.

## Settled so far

- **Q1:** (c), as above.
- **Q2:** (b). Your idea about terms that pull related behavior goes to "Decide what the writing standard is and what carries it" as something to try, and to "Decide how we'll know the writing works" as an experiment.
- **Q3:** (a).
- **Q5:** In `safe`, a budget never affects how the work is done; it's only measured afterward. In `eco` and Let It Rip, a token or wall-clock budget reaches a reader only after you've been asked how much it matters and you approved it as binding. When in doubt, leave it out. If it seems important and nobody can ask you, it goes in as information, never as a limit.

---

❓ **Q6 - What happens when a reader departs from the writer's route, or a binding rule fights the goal?** Here are the five ways the factory handles this today:

1. **Ask first.** Both `AGENTS.md` files say: "say so loudly and get a sign-off before breaking it." A subagent has nobody to ask, and nothing says how it would get a sign-off. It also pulls against "proceed on anything reversible."
2. **Obey first, explain after.** Your note in `template/AGENTS.md`: "when this file and a vendored skill disagree with your instinct, follow the file and tell me why your instinct differed."
3. **Decide and record.** Where the spec is silent, the agent makes the call and logs it under Provisional in `DECISIONS.md` so you can overrule it.
4. **Skip visibly.** In poteto-mode (upstream), a skipped step stays in the list as `skip: <reason>`. Delegation is the exception: it can't be skipped.
5. **Stop and send it back up.** A writer that can't implement a table cell as written stops and reports it. Every writer flag must end `fixed:` or `accepted: <reason>`. A design hole amends the ticket.

They disagree on the basic move: ask first (1), obey first (2), act and record (3, 4), or stop and report (5).

My proposal replaces all five:
- **Route knowledge:** the reader uses its own judgment. Its report always carries a line saying where it took another route and why, or that it didn't. That's 3 and 4, made routine.
- **A binding rule that fights the goal:** the reader stops that part, reports the conflict to the rule's owner, and carries on with the rest. That's 5. In your own conversation the owner is right there, so "report to the owner" means asking you, which is 1 in the one place it works.
- **Never shrink the goal to fit a rule.**

That leaves your note (2). It conflicts with Q2. If what the file says about the route is a resource, then "follow the file" turns it back into an order. The note's real purpose seems to be "tell me when your instinct differs, so the rules get better," and that survives in the departure line.

➡️ The proposal above, plus rewording your note to "use the file's patterns unless you have a reason not to, and tell me when your instinct differed and which way you went." It's your note, so this is your call.

---

❓ **Q7 - How does a binding rule show that it binds?** Under Q1, binding rules should be few: yours, plus the coordination an orchestrator really owns. The reader has to be able to tell which rules those are. The research on wording:
- Emphatic wording ("CRITICAL", "MUST") makes current Claude over-apply a rule.
- A bare prohibition keeps the forbidden idea active and doesn't say what to do instead.
- A rule with its reason gets applied more sensibly.

The options:
- (a) Each binding rule says that it binds, gives its reason, and says what to do instead or who to report to. It's written plainly, with no capitals or alarm words. Anything that doesn't say it binds is a resource.
- (b) Binding rules sit in one dedicated place, and everything outside that place is a resource.
- (c) Only hooks bind, and prose never does.

➡️ (a). Where a hook already holds the rule, the hook's refusal message carries the reason and the way forward, because it arrives at the moment it matters. (c) is too strong, because some of your rules, like the trail review, have no hook. Where each piece lives is the job of the ticket "Decide where each piece lives and when it reaches the writer," not this one.

---

❓ **Q8 - How do we make sure the kinds of bugs you care about get looked for, without a list that bounds the search?**

The options:
- (a) A light mention in the finder's brief ("we're especially wary of X").
- (b) Several passes, each with its own goal. One pass is always fully open. A kind you particularly care about gets a pass whose whole goal is that kind. A separate verifier sorts and rates what comes back, as you described.
- (c) Only the open pass, and trust it.

➡️ (b). The open pass is the protection against a narrow pass's blind spot, and a dedicated pass keeps the named kind out of the open pass's brief. This ticket decides only the principle: coverage comes from separate passes, not from steering inside a brief. How many passes, and of what kinds, belongs to Q9.

---

❓ **Q9 - Where does "a review system of our own" go?** You described something bigger than review briefs: multiple passes, judging by what gets missed and not only by false positives, the gap between spec-review and interrogate, and interrogate's own leading wording. This map's destination is writing. Review briefs are inside it, through the ticket on brief templates and the ticket on reworking existing files. The passes, the verifier and the measurement of misses are process design.

The options:
- (a) A new wayfinder map for the review system, opened with your words from Q3, and listed under this map's Out of scope with a link.
- (b) A note under this map's Not yet specified.
- (c) Fold it into the brief-templates and rework tickets.

➡️ (a). It's big enough to need its own destination. It would also inherit everything this map decides about writing briefs, so it can come after this one.