Posting your answers to the ticket as a comment was declined, so I haven't posted anything. I've saved them word for word in a local file, and they'll go into the resolution comment. If you'd rather they went up now, tell me.

First, Q1 again in plainer terms, since you asked for that before the next questions.

**Q1 in practice.** For any rule, ask whether the reader would be taking a decision someone else already made and owns by breaking it.
- If yes, the rule binds.
- If breaking it only means doing the work differently from how the writer pictured it, it doesn't bind. It's advice.

| Rule | Binds? | Why |
|---|---|---|
| "Never push to main" | Yes | Merging is your decision, and you made this rule. |
| "The orchestrator never writes the code; a subagent does" | Yes | It's about how the work is done, but you decided it, with evidence. |
| "Reviewer: read only the diff" | No | An orchestrator decided it to save tokens. It isn't the orchestrator's decision to make, so at most it becomes information: "the change is in these files." |
| "Only report high-severity bugs" | No | This is your Q3 answer: the reviewer reports everything, and the bar moves to a later step. |

---

❓ **Q4 (again) - Departing from a rule.** These are the five ways the factory handles it now:

1. **Say so loudly and get a sign-off before breaking the rule** ([AGENTS.md:26](AGENTS.md:26), [template/AGENTS.md:20](template/AGENTS.md:20)). A subagent has nobody to sign off, and no text says what it should do instead.
2. **Follow the file, then tell me why your instinct differed** ([template/AGENTS.md:16](template/AGENTS.md:16)). The rule always wins, and the reader explains afterward.
3. **Where the spec is silent, decide and record it** as a Provisional decision you can overrule (PHILOSOPHY, DECISIONS, Ticket playbook).
4. **Skip a step visibly with `skip: <reason>`**, from upstream poteto-mode. The one exception is delegation, where [feature.md:12](template/.agents/skills/poteto-mode/playbooks/feature.md:12) forbids skipping.
5. **Send it back to whoever owns it.**
   - The writer's flags must end `fixed:` or `accepted: <reason>`, and the review script refuses to run until each one has an ending.
   - A writer that can't build a test case as written stops and reports it.
   - A design hole adds a dated line to the ticket.

These conflict in three ways:
- (1) says stop and wait, (2) says obey and explain, and (3) and (4) say decide and record.
- (2) turns every line in the file into a binding rule, which contradicts your Q2 answer.
- (1) doesn't work for subagents.

➡️ Here is how I'd merge them. (1) and (2) become one rule:
- **Advice:** the reader uses its own judgment. Its report always has a line saying where it went its own way, or "none."
- **A binding rule that fights the goal:** the reader stops that part, reports the conflict to the rule's owner, and carries on with the rest. The report is the sign-off request, which makes (1) work for subagents.
- **The reader never shrinks the goal to fit a rule.**

(3), (4) and (5) stay. They're already specific forms of the merged rule. Delegation's "no skip" stays because delegation binds.

---

❓ **Q6 - Rules nobody can trace.** Some rules in the factory have no recorded reason or owner:
- the 150-line reading limit in `knowledge`;
- "never an arena";
- "Subagents never launch their own dev servers", which came from Theo, but his reason was dropped when it was adopted.

Until someone traces one, should it:
- (a) count as advice;
- (b) keep binding until someone reviews it;
- (c) be dropped?

➡️ (a). This fails open, the way you set budgets up in Q5. The ticket "Decide the scope and order of reworking existing files" then traces each rule to an owner, who can make it binding again. The rework audit already found that part of the dev-server rule protects something real. That part would come back quickly.

---

❓ **Q7 - Your worry under Q3, and the "slight push".** The evidence covers two different effects:
- **A bar on what to report** makes a reviewer hold back what it found, not find less. Removing the bar fixes that. Your answer to Q3 covers this.
- **Your worry is about focus,** and the evidence supports it. In the gorilla studies, what observers were told to count decided what they saw. A brief that says "be especially wary of X" is a focus instruction, so it would cost the other kinds of bug. That's the headache you predicted.

What the evidence supports instead is a separate pass. In the 2026 preprint, a second reviewer given an open-ended brief recovered everything the focused one had dropped.

➡️ Put no push in the brief. If one kind of bug matters especially, it gets its own pass with its own reviewer, and the general reviewer's brief stays open.

---

❓ **Q8 - Where does "a review system of our own" go?** Here is where the existing work sits:
- Writing the review subagents' briefs is already on this map, under "Prototype brief templates for the recurring lane jobs".
- Nothing open designs review itself: how many passes, which kinds, how a verifier rates findings, and measuring recall against planted bugs instead of celebrating zero false positives. The closest is "Choose each tier's review round count from the clean measurement", which is narrower.

The options:
- (a) It goes in this map's "Not yet specified".
- (b) It becomes a sixth map.
- (c) It's ticketed under an existing map.

➡️ (b). Its destination, what review is, goes beyond writing, and you named it possibly the most important step. Review briefs stay here. I'd draft the map only once you say so.

---

❓ **Q9 - How a binding rule is written and held.** The research points four ways:
- Emphatic wording ("CRITICAL", "MUST") makes current Claude over-apply a rule.
- A bare "don't" keeps the forbidden idea active and doesn't say what to do instead.
- A rule given with its reason gets applied to cases the writer didn't foresee.
- Every added rule lowers the share of all rules that get followed.

➡️ Write each binding rule once, plainly, with its reason, its owner, and what to do instead. When a hook holds the rule, the hook's refusal message carries the reason and the way forward, and the brief doesn't repeat the rule. That keeps the rule count in briefs down, which is your Q2 point.

---

✅ **Q5 as I'll record it.** Confirm, or correct it:
- **In `safe`** (what you called Safety Mode), no budget ever shapes how the work is done. Budgets are only measured afterward.
- **In `eco` and Let It Rip,** a budget reaches a brief only after you've been asked how binding it is. Wall-clock time is a second budget in Let It Rip, under the same rule.
- **Fail open.** When in doubt, leave the budget out. If it seems important and nobody can be asked, it goes in as information, never as a bar.
- **A predicted saving never becomes a requirement for closing a ticket** unless you made it one.

When this ticket resolves, I'll put a pointer to this on the maps "Design Let It Rip as the third mode" and "Optimize token use and wall-clock time without losing reliability".

**Your Q2 point about terms that carry many rules at once.** The research adds a reason it works. Terms coined inside one conversation, like "lane" or "eco", carry almost nothing to a reader who wasn't there: two people pick the same word for a thing only 10–20% of the time. A micro-genre term works because it's widely used outside your conversation, so the model already learned what goes with it. That suggests two kinds of term:
- **Terms the reader already shares from training**, which can stand in for several rules at once.
- **Terms coined here**, which mean nothing until they're defined.

The experiment you described belongs to the ticket "Decide how we'll know the writing works", and the term idea belongs to "Decide what the writing standard is and what carries it". I'll pin both there when this ticket resolves.