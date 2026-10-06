I'm continuing with round two. Here is where round one landed:

- **Q2 and Q5 are settled.** Your budget rule is already in my memory: in safe, a budget never shapes the process; in eco and Let It Rip, you're asked how binding it is first; when in doubt, it's left out.
- **Q3 is settled as (a).** Your worry gets its own question below (Q7).
- **Your note on rule load and terms that pull in many related details** goes to the map when I close this ticket, as an open item for "Decide how we'll know the writing works". It's an experiment worth running: how many rules a model actually follows, whether one well-chosen term carries several rules, and which rules still need stating on their own.
- **Q1 needs a concrete picture**, so Q6 walks real factory rules through the test.
- **Q4 needed the five mechanisms laid out**, which I do below.

Your answers are saved word for word, and they go on the ticket when it closes.

---

❓ **Q6 - Q1 in practice: do these feel right?** The test asks two things of each rule. Is it about the task itself, or about how the reader goes about it? And if it's about how, did the person who owns that decision say it must hold? Here are real factory rules run through it:

| Rule | About | Who set it | Result |
|---|---|---|---|
| Never push to `main` | The task: merging is your decision, not the agent's | You | **Binds.** The guard hook holds it |
| The orchestrator never writes the code; a lane does | How | You, with evidence (an agent broke it knowingly) | **Binds**, because you made it bind. The hook holds it |
| The trail review is mandatory | How | You, with evidence (caught the owner's errors 3 of 3 times) | **Binds** |
| "Read nothing beyond this brief" (the old reviewer brief) | How | A lane, to save cost; nobody asked for it | **Gone.** Nobody with authority made it bind |
| `knowledge`: never read more than 150 lines in one call | How | No recorded owner or reason | **Becomes information** at most, such as "files here are long; this skill looks up sections" |
| "Run it as two plain commands, because the worktree guard refuses `git` inside `$(...)`" | How | A lesson that cost a run | **Information with its reason.** The reader follows it because it's true, not because it binds |
| A finding without a `spec:` citation is sent back | How the task is finished | A lane | **Moves.** The reviewer reports everything, and the filtering happens afterwards (Q3) |
| "Subagents never launch their own dev servers" | How, but it touches something shared (ports, a server another lane may own) | Theo's rule, adopted; its reason was dropped | **Unclear until you say.** That's the test working: it makes the owner say whether the rule binds, and then the reason gets written back in |

➡️ If every row matches your gut, the test holds. A row that feels wrong is where the test is wrong, and I'd rather find that now. The last row needs your call either way.

---

❓ **Q4 (again) - One way to depart, in place of five.** Here is what exists today:

1. **Ask first.** [AGENTS.md:26](AGENTS.md:26): "If a rule fights the task, say so loudly and get a sign-off before breaking it."
   - A subagent has nobody to ask.
   - It clashes with "never block on the human; proceed on anything reversible."
   - I found no record of it ever being used.
2. **Obey, then explain.** [template/AGENTS.md:16](template/AGENTS.md:16): "follow the file and tell me why your instinct differed." This is the opposite default to #1, and in practice it means quietly shrinking the work to fit the rule.
3. **Decide and record.** Where the spec is silent, the agent makes the call and writes a Provisional row in `DECISIONS.md` that you can overrule. This covers gaps, not conflicts.
4. **Skip with a reason.** poteto-mode lets a step be dropped if it stays listed as `skip: <reason>`. `feature.md` then forbids that for delegation.
5. **Stop and send it back.** A writer that can't implement a test case as written stops and reports instead of improvising. Writer flags must end `fixed:` or `accepted: <reason>`, or the script refuses the review. A design hole gets written onto the ticket.

The proposal:

- **Rules that are only information** (the "information" rows in Q6): the reader uses its judgment. Its report always has a line saying where it took a different route and why, or that it took none. This generalizes #4. It's a standing field, not an invitation, because readers rarely volunteer things otherwise.
- **A binding rule that fights the goal:** the reader stops that part, reports the conflict to whoever owns the rule, and carries on with the rest. When you're in the conversation, that means asking you, which is #1. When the reader is unattended, it reports back instead, which is #5. It's one rule either way.
- **Never shrink the goal to fit a rule.** This retires #2.
- **#3 stays as it is**, since it covers silence, not conflict.

➡️ Adopt it. It removes #2 and reduces #1 and #4 to cases of the two bullets above.

---

❓ **Q7 - Your worry: the reviewer fixates on one kind of bug.** You're half right, and the research says which half.

- **A bar on what gets reported** ("only high severity") doesn't stop the finding. The bugs are found, then withheld. Reporting everything and filtering afterwards fixes that.
- **Focus does change what gets found.** That was the gorilla result, and Shin's preprint shows it in models. So a reviewer chasing edge cases really can read past the bug you care about.
- **Your "slight push"** ("we're especially wary of X") is itself a focus instruction, so it would cause the same problem it's meant to prevent. The one thing that recovered the missed findings in Shin's study was a second, separate reviewer with an open brief. A hint inside the first reviewer's brief didn't do that.

The options:
- (a) The main review brief stays open, with no named bug types. A concern you have goes to its own separate pass that names it, alongside the open one and never inside it.
- (b) The slight push, written into the open brief.
- (c) Neither, and leave it to the review-system work in Q8.

➡️ (a) as the principle. Exactly which passes exist is Q8's business.

---

❓ **Q8 - Where does "a review system of our own" live?** You described review as perhaps the most important step, and the one this discipline helps most. You also pointed out that `interrogate` already leads the witness, and that studies celebrate having no false positives while missing half the planted bugs. This map's destination is the writing: the standard, where it lives, the brief templates, and reworking existing briefs. A review system is bigger than that. It covers how many passes there are, what each looks for, how the verifier rates findings, and how recall gets measured.

The options:
- (a) It becomes its own map, fed by this one's decisions.
- (b) It goes into this map's fog and grows into tickets here.
- (c) It becomes a single ticket on this map.

➡️ (a). Its destination is a working review process, not writing, and folding it in would stretch this map past what one plan can carry. I'd note it under this map's Out of scope with a link, and the review brief templates stay here. I won't create the map without your go-ahead.

---

❓ **Q9 - How a binding rule is worded.** Given that some rules bind, the research says how to write them:
- plainly, with no emphasis, because current Claude over-applies "CRITICAL / MUST";
- with the reason, because the model generalizes from the reason;
- with what to do instead, because a bare "don't" keeps the forbidden idea active and doesn't say where to go.

The guard hook already does this: "Use --force-with-lease on your own branch, or ask." Whether a brief restates a rule a hook already holds is a placement question, so it goes to "Decide where each piece lives and when it reaches the writer".

➡️ Every binding rule is written plainly, carries its reason, and names the way forward. When a hook holds the rule, its refusal message is where the reader meets all three.