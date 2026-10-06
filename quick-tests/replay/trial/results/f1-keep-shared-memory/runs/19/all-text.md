Your answers are saved and I'm checking two lines in the factory files before I write round two.

---

Your answers to Q1, Q2, Q3 and Q5 are in my memory. I tried to post all five on the ticket word for word and the post was declined. They're saved in my scratchpad for now, and I'll put them in the resolution comment when we close, if you're OK with that.

**Q5 is settled as you stated it.** One naming note: the first mode is called `safe`.

**Your co-pull idea from Q2.** The research has one finding next to it. Models already give 71–82% similar answers to open questions, so a dense term may work partly because it points at defaults the model already holds. That cuts both ways: a well-chosen term carries a whole cluster of rules for a few tokens, but it also carries pulls you didn't pick, the same way an example does. Nobody has measured either effect, so it's an experiment. At resolution I'll add it as a hypothesis to test on the ticket "Decide how we'll know the writing works".

**Your Q3 worry is real, and (a) doesn't fix all of it.** The evidence splits in two:
- **A bar changes what gets reported, not what gets found.** The radiologists still searched; they just stopped saying so. (a) fixes this half.
- **Focus changes what gets found.** The gorilla observers really didn't see it, and Shin's focused models really didn't report it. A reviewer chasing edge cases can read past the kind of bug you want.

A "we're especially wary of X" line probably makes the second half worse. People given part of a list recall less of the rest, and models copy the examples they're handed. Your sense that it brings headaches matches the evidence. What recovered every missed finding in Shin's study was a second reader with a different, open brief. That is your "multiple passes", so it leads into Q7.

---

**Q1 again, in practice.** Picture hiring a contractor to build a deck.
- Things you may bind them to: what to build, that it holds 500 lb, that the neighbor's fence isn't theirs to touch, and that you approve the final design.
- Things you don't bind them to: which hammer to use, or which corner to start from.
- Things you can still tell them, as information: "the soil here is clay, and last time the posts sank." They decide what to do with that.

(c) says a rule binds when it's about the job or about whose decision something is, and the person who owns that decision made it a rule. Here is (c) applied to rules the factory has today:

| Rule today | Binds? | Why |
|---|---|---|
| Never push to `main` | Yes | Merging is your decision, and you set the rule. A hook holds it. |
| The orchestrator never writes the code; it briefs a lane | Yes | You decided who does which job, with evidence, and a hook holds it. |
| Every ticket gets a trail review | Yes | You set it, and it's part of what "done" means. It caught the owner's errors three times out of three. |
| Subagents never launch dev servers or simulators | Yes, once its reason is restored | The primary agent owns those shared resources. The reason was dropped when the rule was adopted. |
| Review brief: "Read nothing beyond this brief, run nothing" (mostly removed in #137) | No | It's about how to review. Lanes added it to save cost, and nobody with authority chose it. |
| `knowledge`: never read more than 150 lines in one call | No | It's route, with no recorded reason and no owner. It becomes a fact with its reason, or it goes. |
| Run the whole test suite only if it takes under 30 seconds | No, unless you say it's yours | It's route. As information: "CI runs the full suite; a long local run proves nothing CI won't." |
| A bug without a `spec:` line isn't hard | Moves out of the brief | It's a finishing rule (Q3). The later filter step can use it to rank findings. |
| pstack: "Execute only the task and path scope the parent assigns" | Split | The limit on what the lane *changes* binds, because the parent owns that. The limit on what it *reads* doesn't. |

❓ **Q6 - Is that sorting right?** Mark any row you'd sort differently. A row where your gut disagrees with (c) is the most useful thing you can give me, because it means the test is missing something.

➡️ The table as shown.

---

❓ **Q4 - One way to depart from a rule, in place of five.** Here are the five mechanisms that exist today, and what my proposal does to each. Two of them are your own words, from "A note from Manuel" in `template/AGENTS.md`.

1. **Say so loudly and get a sign-off before breaking the rule** (yours, [template/AGENTS.md:20](template/AGENTS.md:20)). This works when you're in the session. A subagent running unattended has nobody to ask, and the rule pulls against your "never block on the human".
   *Proposal:* keep it for sessions you're in. A subagent instead stops that part, reports the conflict to whoever owns the rule, and carries on with the rest.
2. **Follow the file, then tell me why your instinct differed** (yours, [template/AGENTS.md:16](template/AGENTS.md:16)). Its purpose is in its last clause: "that is how the rules here get better." Under Q2, though, most rules about the route become information, so "follow the file" would hold only for binding rules.
   *Proposal:* binding rules are followed and the disagreement is reported. Route information may be departed from, and the report always says where and why. Your purpose survives, because the report is still the feedback that improves the rules.
3. **Where the spec is silent, decide and record a Provisional decision for you to overrule** ([ticket.md:30](template/.agents/skills/poteto-mode/playbooks/ticket.md:30)). This covers gaps, not conflicts.
   *Proposal:* unchanged.
4. **Skip a step visibly with `skip: <reason>`, never silently** (upstream poteto-mode; turned off for delegation).
   *Proposal:* this becomes the general form for any departure from the route, still turned off for binding steps like delegation.
5. **Send it back up.** Writer flags must end `fixed:` or `accepted: <reason>`. A writer that can't implement a test-table cell stops and reports it. A design hole is added to the ticket with a dated line. Bad criteria go back to you.
   *Proposal:* unchanged. These already handle a binding rule that fights the goal correctly.

In short: keep 3 and 5, widen 4 to cover any route departure, limit 1 to sessions you're in, and reword 2. One rule above all of them: the reader never quietly shrinks the goal to fit a rule.

➡️ Adopt it. Because 1 and 2 are in your note, their new wording comes back to you before it lands.

---

❓ **Q7 - Where does the review system get designed?** You're describing more than better review briefs:
- multiple passes;
- a verifier that classifies findings;
- your own system in place of a vendored `interrogate` that leads the witness;
- measured recall, not just a low false-positive rate.

This map's destination covers the briefs and templates for recurring lane jobs, so the *wording* of review briefs belongs here. The *process* (which passes, how many readers, what each one is given, who filters) is a design effort of its own. Existing tickets touch it: "Choose each tier's review round count from the clean measurement" and "Eval the judge and trail-review models the way #103 evals reviewers".

The options:
- (a) A new map, "Build the factory's own review system". It takes this map's decisions as input, and this map's Out of scope section points to it.
- (b) Fog on this map.
- (c) A ticket on this map.

➡️ (a). You called review possibly the most important step in AI-driven development, and it has enough open decisions for a map of its own. I'd chart it in its own session.

---

❓ **Q8 - How are binding rules worded and enforced?** The research points to plain wording with the reason attached, not emphasis: current Claude over-applies "CRITICAL / MUST". It also says to state what to do, not only what's forbidden, since a bare "don't" keeps the forbidden idea active and leaves the reader no direction. Where a hook enforces a rule, its refusal message reaches the reader at the moment it matters, which is where the research says guidance works best. Today the git guard's refusal message already names the way forward.

The options:
- (a) Each binding rule is stated once, plainly, with its reason, where it applies. Where a hook holds it, a brief mentions it only as a fact ("a hook refuses pushes to `main`; Manuel merges"). The hook's message carries the reason and the way forward.
- (b) Briefs restate every binding rule in full.
- (c) A brief leaves out hook-held rules entirely.

➡️ (a). (c) costs the reader wasted turns: the ledger records lanes losing turns to a guard they didn't know about.