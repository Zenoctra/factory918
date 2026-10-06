The background search is back. It changes two of my recommendations and adds one question. Questions 1 to 5 are still open as posted above. This is what bears on them.

**For Q1 (what makes a rule binding).**
- **Search isn't the only kind of rule that does harm.** Your broader framing holds up. The worst rule the audits found isn't about search. It's about how a reviewer finishes its report: the Standards brief makes a reviewer cite the ticket for every serious bug, but never shows it the ticket. So honest reviewers downgraded real bugs. Fable wrote "not filed hard because the Standards brief carries no ticket criteria to cite." That came from the answer-key audit on the run-2 audits branch, and the gate is still live at `review-brief.sh:494`.
- **Some rules about how the work is done helped, and a test must keep them:**
  - the mandatory trail review caught the owner's mistakes 3 times out of 3;
  - the delegation hook exists because the prose rule was broken knowingly;
  - P18 defines a "hard" bug because a reviewer counted code smells as hard.

  Each of these is a rule you set, or one that was fixed after something failed. That supports the "who owns it" half of my Q1 recommendation.
- **The old constraints audit used the framing you rejected.** It sorted limits into "safety, keep" and "search, cut", and its brief said "Do not propose new constraints". Its list of 45 lines to cut is probably still mostly right, but its sorting can't be the standard.

**For Q2 (how the writing carries a rule about the route).**
- **The research cuts both ways.** It's on the branch `research/wording-and-reader-context`, which is not merged. It says specific method helps on simple tasks and for beginners, and hurts on complex tasks and for experts. It also says no study tests a limit on an AI model's strategy directly.
- **Reasons are missing unevenly.** Some rules carry their reason ("because a worktree agent's guard refuses `git` inside `$(...)`"). Many don't: "never an arena", the 150-line read cap, "Subagents never launch their own dev servers". The last one lost Theo's reason when we adopted it.

  I still recommend (b): knowledge, with its reason, as a report-don't-ask default. The research gives the reader's own judgment of the task's difficulty as the reason it's a default and not an order.

**For Q3 (what the reader does when a binding rule fights the goal): my recommendation changes.** The factory has five ways to depart from a rule today, and they disagree:
1. say so loudly and get a sign-off, which is in both AGENTS files only;
2. follow the file first, then explain why your instinct differed (`template/AGENTS.md:16`);
3. decide, and record a Provisional row you can overrule;
4. pstack's `skip: <reason>`, which `feature.md:12` turns off for delegation;
5. carry the problem back to the artifact: `accepted: <reason>` on flags, the writer stopping on a test cell it can't build as written, and the design-hole amendment.

No audit looked at these. Nothing records the sign-off ever being used, and it pulls against "never block on the human". So my recommendation is now: one mechanism, which is option (a), and the other four are folded into it or removed. Whether to cut any of them belongs to the ticket "Decide the scope and order of reworking existing files". This ticket only says what the single rule is.

**A new question this raised:**

❓ **Q6 - Must every binding rule carry its reason, where the reader sees it?** Without the reason, a reader can't tell when it has hit the case the rule never meant to cover. That is the case your correction is about. Today only `DECISIONS.md` requires reasons, and that file isn't where readers meet rules.
- (a) Yes. A binding rule with no reason next to it is a bug the rework must fix.
- (b) Yes for new writing; existing rules get reasons when they're next touched.
- (c) No. A pointer to `DECISIONS.md` is enough.

➡️ (a). The reason is what lets a reader see past the rule, and a pointer is a read it will skip.

**Two notes, no decision needed:**
- **Vendored skills.** Some of the worst lines are in vendored pstack text, for example "Execute only the task and path scope the parent assigns". My memory says upstream limits stay. Whether that still holds is for the rework ticket. I'll note it there and not here.
- **A stale count.** `MANUAL.md:168` still says "twelve ordered beliefs". PHILOSOPHY has eleven since the cost belief came out.

I'll wait for your answers to Q1–Q6 before recording anything on the ticket.