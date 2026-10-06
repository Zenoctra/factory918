The background search finished, and it confirms your correction. The worst rule it found wasn't about searching at all: it was a rule about how a review gets finished. Round one is still open, and only my recommendation on Q3 changes.

**What it found, by question:**

- **Q1 (what makes a rule binding):**
  - **A finishing rule did harm too.** The Standards review brief requires a reviewer to cite the ticket for any serious bug, but the reviewer never gets the ticket. Honest reviewers therefore downgraded real bugs: one wrote that a bug was "not filed hard because the Standards brief carries no ticket criteria to cite." On one PR, a reviewer filed nothing at all, even though the PR had four serious behaviour bugs. That gate is still live in `review-brief.sh:494`.
  - **Some rules about method did good.** The mandatory review of the decision trail caught the owner's mistakes in all three runs where it ran. The "check what else this could break" rule exists because a hook bug survived four review rounds. The delegation hook exists because prose alone didn't stop an agent from breaking the rule knowingly. You set each of those, after a measured failure. That fits the "you own it, so it binds" half of my recommendation. It doesn't fit a test based only on what a rule is about.
  - **The earlier constraints audit used the framing you rejected.** It sorted rules into the same split and was told not to propose new rules. Its 45 "delete or replace" calls were judged by the test this ticket replaces. That matters for the ticket "Decide the scope and order of reworking existing files", not for this one.
- **Q2 (rules about the route):** Reasons are uneven. Some rules carry theirs: "read the tier in two plain commands because the worktree guard refuses git inside `$(...)`" is route knowledge written exactly as (b) would want. Others carry none: the 150-line reading cap, "never an arena", and "do exactly the task in your prompt" in the agent definitions. The audit found no recorded reason for 150.
- **Q3 (a binding rule fights the goal):** This changes my recommendation. The factory has five ways to depart from a rule, and they disagree:
  1. "Say so loudly and get a sign-off." This is only in the two `AGENTS.md` files, with no route for a subagent to get one.
  2. "Follow the file and tell me why your instinct differed." This is the opposite default: obey first, explain after.
  3. Re-read the philosophy, or record the decision as provisional so you can overrule it later.
  4. A visible `skip: <reason>`, which the feature playbook then forbids for delegation.
  5. Stop and report, for example "a writer that cannot implement a cell as written stops and reports the cell, and never fills it in."

  No audit looked at these, and I found no record of the sign-off ever being used. My new recommendation is (a), and this decision should also pick one way to depart and retire the others. The fifth way already is (a).
- **Q4 (who may write a binding rule):** The evidence supports my recommendation. The rules that cut reviewers off from reading were added by agents to save cost, and no ticket asked for them. Another agent turned one of your questions into a rule on a ticket, and you removed it.
- **Q5 (cost and time):** No new evidence.

**Related research.** An unmerged research branch, `research/wording-and-reader-context`, addresses this exact question. It says the evidence supports your broader framing over the search-only one. It adds two counterweights:
- Specific method helps on simple tasks and for novices.
- Restraint in what the writer volunteers is a different thing from limiting what the reader may look for.

It also notes that no study of models has tested a limit on strategy directly.

Separately, `MANUAL.md:168` still says "twelve ordered beliefs" when the philosophy now has eleven. I'll file that as its own ticket rather than fix it here.

So round one stands, with Q3 widened: when a binding rule fights the goal, what should the reader do, and should that one answer replace the five ways the factory has now?