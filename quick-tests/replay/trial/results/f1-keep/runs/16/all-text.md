I tried to post your round-one answers word for word on the ticket "Decide how the writing treats rules that bound how a task is pursued", as with your earlier answers, but the permission was declined. They're saved locally in the session scratchpad. Tell me if you want them posted.

I've updated my memory. It no longer holds the old "protect the world / shape the search" test. It now records your budget rule: in `safe`, no budget shapes how the work is done; in `eco` and Let It Rip, a budget counts only if you set it and said how binding it is; when in doubt, it stays out.

Your note about terms that pull in many details at once leaves Q2 unchanged. It belongs to two other tickets: as a writing tool in "Decide what the writing standard is and what carries it", and as an experiment in "Decide how we'll know the writing works". I'll add it to both when this ticket closes. One caution to carry with it: a dense term also brings in that genre's habits, including ones you'd reject. A study of 162 personas found that framing a model as an expert added no accuracy, and other studies found framing can add bias. That's the "leading the witness" problem arriving through a single word.

Round two follows. Q6 is your request to slow down on Q1: the same test, shown on real factory rules.

---

❓ **Q6 - Does the Q1 test give the right verdict on real rules?** In plain words: **a rule can stop the reader only if it's about something that isn't the reader's call, and the person whose call it is said so. How the reader gets the work done is always the reader's call.**

Here is the test on six rules the factory has now:

| The rule today | Whose call is it? | Verdict |
|---|---|---|
| Never push to `main` (the guard hook) | Yours. You merge. | **Binds.** |
| The orchestrator never writes the code inside a playbook (the delegation hook) | It's about how the work gets done, but you set it, after an agent broke it knowingly. | **Binds**, because you made it bind. It's the clearest case of ownership doing the work. |
| "Execute only the task and path scope the parent assigns" (every pstack subagent file) | It splits in two. Writing to files another subagent is editing isn't the reader's call. Which files to *read* is the reader's call; the parent guessed. | **Writing outside its files binds. Reading is free.** Four of the 13 labelled bugs in the reviewer eval sat in files the brief said not to open. |
| `knowledge`: "never read more than 150 lines in one call" | The reader's. No reason is recorded and you never ruled on it. | **Doesn't bind.** It becomes information ("long reads cost context; ranges from the table of contents usually work") or it goes. |
| "That is the scope; nothing wider is redesigned" (Ticket playbook, design-hole step) | The ticket's scope is yours. | **Binds what gets changed, not what gets noticed.** Anything seen outside the scope is reported and becomes a ticket, which AGENTS.md already says. |
| A reviewer finding counts only with a `spec:` citation (`review-brief.sh`) | It's about what done means, but it's really a bar on reporting. | **Q3 rule:** the reviewer reports everything. Whether a finding blocks the merge is decided in a later step. |

➡️ All six verdicts as shown. If any one feels wrong to you, that's the useful answer, because it means the test needs another piece.

---

❓ **Q4, asked again - One way to depart from a rule, in place of five.** These are the five mechanisms the factory has today:

1. **"Say so loudly and get a sign-off before breaking it."** [AGENTS.md:26](AGENTS.md:26), and [template/AGENTS.md:20](template/AGENTS.md:20) in projects. It comes from Theo. Nothing says how a subagent gets a sign-off, since it has no person to ask. It also pulls against the line two sentences earlier: "Proceed on anything reversible."
2. **"Follow the file and tell me why your instinct differed."** [template/AGENTS.md:16](template/AGENTS.md:16). It's the opposite default: comply first, explain afterwards.
3. **"Where the spec is silent, decide and record it under Provisional in DECISIONS.md"** so you can overrule it later. This is the Ticket playbook.
4. **`skip: <reason>`** for a playbook step the agent chooses not to do. This is poteto-mode, vendored. The delegation step forbids it: "no skip-with-reason escape" ([feature.md:12](template/.agents/skills/poteto-mode/playbooks/feature.md:12)).
5. **`fixed: <sha>` or `accepted: <reason>`** on every risk and writer flag. A script refuses the review until each has one. Separately, a writer that can't build a table cell as written "stops and reports the cell."

They conflict on the basic question: does the reader stop and ask, comply and explain, or decide and record? And none of them separates the writer's advice about the route from a rule that binds.

What I'd put in their place:
- **For the route**, the reader uses its own judgment. Its report always carries one line: where it went a different way from what the brief suggested, and why, or "none". That keeps the useful part of 3, 4 and 5, which is a visible record.
- **For a binding rule that fights the goal**, the reader stops only the part the rule blocks, reports the conflict to the rule's owner, and carries on with the rest. That's mechanism 1, made workable for a subagent.
- **Never** quietly shrink the goal so the rule fits.
- Mechanism 2 goes. "Comply, then explain" is the reverse of the principle for anything that doesn't bind, and it's no different from 1 for anything that does.

➡️ The above. Mechanism 5's script check stays as it is, because it holds you and the record to a disposition, not the reader to a route.

---

❓ **Q7 - Your worry that a reviewer fixes on the wrong kind of bug.** You're half right about what the evidence says.

- **The half it does cover:** a bar like "only report high severity" stops reporting, not finding. Both the radiologists and Anthropic's own measurements show this. That's why Q3's answer (report everything, filter later) works.
- **The half it doesn't cover:** what a reader is told to look for does shape what it sees. That's the gorilla study, and Shin's preprint on models. So your worry is real, and a "slight push" toward certain kinds of bug would cause it in reverse. In the survey study, naming four problems moved them from 2% of answers to 60%, even with an "other" slot open.

What fixed it in the one model study was structure, not a hint: a second reader with an open-ended brief recovered every finding the focused one had left out.

➡️ No "especially wary of X" in a general reviewer's brief. Coverage comes from having more than one reader. When a kind of bug matters especially, like security, it gets a pass whose whole goal it is, given as that reader's own task. The general reviewer stays open. A dedicated pass isn't a limit on anyone: it's one more reader with a different goal.

---

❓ **Q8 - Where does "a review system of our own" go?** None of the open tickets covers it. There's "Choose each tier's review round count from the clean measurement" and "Eval the judge and trail-review models the way #103 evals reviewers", but nothing redesigns review. Your points are bigger than the wording of a brief:
- spec-review hunts bugs while `interrogate` looks wider;
- even `interrogate` leads the witness;
- the studies celebrate no false positives while missing half of the planted bugs;
- this calls for several passes.

The options:
- (a) A new wayfinder map, a sixth alongside the five. This map's decisions feed into it.
- (b) Fold it into this map through the ticket "Prototype brief templates for the recurring lane jobs".
- (c) Put it on the map "Optimize token use and wall-clock time without losing reliability".

➡️ (a). This map's destination is the writing: how each review brief is worded stays here, in the templates ticket. How many passes there are, with which goals, and how findings get filtered is the design of the review process, so it needs its own map. "Recall, not just precision" goes to "Decide how we'll know the writing works" either way.

---

❓ **Q5, confirming - Is this your budget rule?**
- **`safe`:** no budget ever shapes how the work is done. Cost is only measured afterwards, to look for optimizations.
- **`eco` and Let It Rip:** a budget counts only if you set it. Before a budget is written into a brief as a limit, you're asked how much it should weigh against your other goals. Let It Rip adds a wall-clock budget under the same rule. A goal you set for the run is not automatically something the reader is told, and it never overrides processes you required.
- **Failing open:** when in doubt, the budget isn't mentioned. If it seems important and there's no chance to ask, it goes in as information. A budget written as a limit is always one you approved as a limit.

➡️ Yes, as written. A predicted saving is never a closing requirement. That's the case you described, and the same ruling as the "at most" list in P109.