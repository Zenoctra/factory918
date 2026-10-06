I tried to post your answers on the ticket word for word, the way the map's earlier rounds were saved, but the post was declined, so nothing is on GitHub yet. They're saved word for word in a local file, `152-answers-round1.md` in my scratchpad. Say if you want them posted. The budget rule from Q5 is already in memory: in `safe` a budget never shapes the process, in `eco` and Let It Rip you're asked first how much it should count, and when in doubt it's left out.

## Q1 in plain terms

For every "must" or "never" in a brief, ask two questions: **who decided this, and did they have the right to decide it for this reader?**

- **You** can decide anything, including how the work gets done. Your rules bind.
- **A ticket** decides what's wanted and what done means. Those bind.
- **The agent writing a brief** can only decide what it's coordinating, such as which files another subagent is editing right now, or where results go. Everything else it thinks about how the work should go is a tip with a reason. The reader may ignore it, and says in its report when it did.

Here are some real rules run through it:

| Rule | Who decided it | Binds? |
|---|---|---|
| "Never push to main" | You | Yes |
| "The orchestrator never writes the code itself" | You, after it went wrong | Yes, even though it's about how the work is done |
| "Don't edit `ticket.md`, another subagent is rewriting it" | The brief's writer, about something it's coordinating | Yes |
| "Read only the diff" in a review brief | The brief's writer, guessing where the bugs are | No. At most it becomes a tip: "the diff is here; the changed function is called from there" |
| "Only file a bug if you can cite a `spec:` line" | A subagent added it to the review script to save cost; nobody asked for it | No. And under your Q3 answer, bars like this move to a later step anyway |

Is that what you agreed to? Round two builds on it.

## Q4: the five mechanisms that exist today

| # | Where | What it says | Under my proposal |
|---|---|---|---|
| 1 | [AGENTS.md:26](AGENTS.md:26), [template/AGENTS.md:20](template/AGENTS.md:20) (Theo's line) | If a rule fights the task, say so loudly and get a sign-off before breaking it | This is the case of a binding rule that fights the goal: stop that part and report it to whoever owns the rule. With you in the session, that's what happens today. A subagent has nobody to sign off, so it reports the conflict and finishes the rest instead of waiting. |
| 2 | [template/AGENTS.md:16](template/AGENTS.md:16) | When the file disagrees with your instinct, follow the file and tell me why your instinct differed | Still holds for your rules. For tips, the reader uses its own judgment and reports where it went its own way. This one changes the most. |
| 3 | PHILOSOPHY, DECISIONS, [ticket.md:30](template/.agents/skills/poteto-mode/playbooks/ticket.md:30) | Where the spec says nothing, make the call and record it as a Provisional decision you can overrule | Unchanged. It covers a gap in the spec, not a rule that fights the goal. |
| 4 | poteto-mode `SKILL.md:113` (vendored); [feature.md:12](template/.agents/skills/poteto-mode/playbooks/feature.md:12) forbids it for delegation | A skipped step stays in the list as `skip: <reason>` | This becomes the report line for a step the reader dropped. The delegation exception stays, because you decided it. |
| 5 | spec-review's `fixed:`/`accepted:`, feature.md:12, ticket.md:21 and 41–50 | A writer who can't build a test cell stops and reports it; each flag ends fixed or accepted with a reason; bad acceptance criteria go back to you | Unchanged. These already mean "stop and report to the owner". |

So the proposal mostly sorts the five rather than replacing them: one rule that says which one applies when.
- For your rules, 1 and 5 apply.
- For tips, 4 applies.
- For gaps in the spec, 3 applies.
- 2 now covers only your rules.

Two things are new. Every report has a line for where the reader departed from the brief's tips, even if it says "none". And no reader ever shrinks the goal to fit a rule.

## On your Q3 worry

Your worry is partly right, and the evidence splits on it:
- **A bar** like "report only high severity" changes what gets reported, not what gets found. Option (a) fixes that by moving the bar to a later step.
- **A focus** like "we're especially wary of X" really does change what gets seen. That's the gorilla finding: an observer told what to count misses what's beside it. So the "slight push" you described would cost what lies outside the push.

The fix that held up in the one model study is structural: several passes, some with a focus and one with an open brief, and then a separate step that rates the findings. That's the review-system work you described, and it brings me to the questions.

---

❓ **Q6 - Do the vendored skills' rules count as yours?** You adopted pstack and Matt's skills, and their rules change only through a patch. My memory has your 2026-09-24 ruling that upstream constraints stay and that it's text the factory wrote that is suspect. But the run-2 audit named a pstack line the worst single limit it found: "Execute only the task and path scope the parent assigns."
- (a) Yes. Adopting a skill counts as deciding its rules. Changing one means a patch, and you decide each patch.
- (b) They're tips until you've confirmed them one by one.

➡️ (a). It matches your earlier ruling and the patch process. The "Execute only…" line then goes to you as a patch question, not to a subagent's judgment.

---

❓ **Q7 - Where does the review system you described go?** None of the open tickets covers it whole. The closest are "Choose each tier's review round count from the clean measurement" and "Eval the judge and trail-review models the way #103 evals reviewers". The pieces you named go beyond this map's destination, which is how the factory writes:
- measuring how many known bugs get missed, not only false positives;
- several passes;
- briefs for spec-review and `interrogate`;
- leading wording inside the vendored `interrogate`.

The options:
- (a) A note under this map's "Not yet specified".
- (b) A sixth map of its own, whose destination is the review process, building on what this map decides.
- (c) Fold it into the ticket "Decide the scope and order of reworking existing files".

➡️ (b). Its destination is different, and it needs this map's standard and the ticket "Decide how we'll know the writing works" before it can be planned well. I'd leave a one-line pointer in this map's "Out of scope" so nobody loses it.

---

❓ **Q8 - Where does your note on rule count and co-pulling terms live?** It bears on every decision here. It's also a testable claim: one well-chosen term may carry a cluster of rules, and the few things it doesn't carry would be stated separately, like your micro-genre prompts.

➡️ Two places:
- A line in the map's Notes pointing to your words, so every session sees it.
- An experiment for the ticket "Decide how we'll know the writing works": how many rules a reader keeps, and whether one term carries several of them.

---

After these, round two covers how binding rules are worded and held: plain wording against emphatic, a prohibition against saying what to do instead, and whether a hook's refusal message, which arrives with its reason at the moment it applies, does more than repeating the rule in every brief.