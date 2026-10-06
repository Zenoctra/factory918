The background search has finished. Your round-one answers are still open; nothing has been decided. Three of its findings change what I'd recommend, and one adds a question. I also tried to read the research branch's note directly, but that command was refused, so what I say about it comes from the search agent's report.

**What it found that bears on the round:**

- **Rules that shape how the work is finished did as much damage as rules on reading.** The Standards review brief only counts a finding that cites `spec:` from a ticket, but it never shows the reviewer that ticket. Honest reviewers therefore downgraded real bugs. Fable wrote "not filed hard because the Standards brief carries no ticket criteria to cite," and Sol filed nothing on pr99, which had 4 hard bugs. The constraints audit had filed this as "report format, kept" and only caught it in a late addendum. That supports your correction: search was the symptom, not the edge.
- **The run-2 constraints audit was built on the framing you rejected.** It sorted constraints into five classes and kept "safety" and "hand-back format" as fine. Its own brief said "Do not propose new constraints." So its conclusions need re-reading in light of this ticket, not adopting as they stand.
- **Five mechanisms for departing from a rule exist, and they point different ways:**
  - say so and get a sign-off (`AGENTS.md:26`, `template/AGENTS.md:20`);
  - follow the file, then explain why your instinct differed (`template/AGENTS.md:16`);
  - decide where the spec is silent and record it as Provisional;
  - pstack's visible `skip: <reason>`, which is switched off for delegation;
  - gates that send a departure back to the ticket or to you (`accepted: <reason>`, the design-hole path).

  No text says how a subagent gets a sign-off, and nothing records the sign-off line ever being used.
- **Some rules on method did clear good.** The mandatory trail review caught owner errors 3 times out of 3. The delegation rule was broken knowingly until a hook held it. Every one of these rules *adds* a step or a check; none of them stops the reader from doing something.
- **Many rules carry no reason.** Examples: "never an arena," the 150-line read cap, the 30-second suite limit, and "Do exactly the task in your prompt" in our agent definitions.

**Changes to the round:**

❓ **Q1, revised:** My test listed "what done means" as binding. The `spec:` gate shows the gap in that. A required report *shape* that a script reads is fine. A rule that filters *which results count* shrinks the goal itself. I'd add: a report format may be binding, but it never decides what counts as a result.

➡️ Still (a) and (b) together, with that clause added, and with every binding rule carrying its reason. The reason is what lets the reader see when the rule fights the goal.

❓ **Q3, revised:** The question is now which of the five mechanisms survive. "Follow the file, then explain" is the opposite default to "stop and get a sign-off."

➡️ For a binding rule that fights the goal: stop that part, report it to the rule's owner, and carry on with the rest. For anything that isn't binding (route knowledge under Q2): depart, then name the departure and the reason in the report. That would fold `skip: <reason>`, `accepted:` and Provisional into one habit. It would replace "follow the file, then explain" and give the sign-off line a version that works for an unattended subagent.

---

❓ **Q6 - Does a rule that requires an extra step get different treatment from a rule that forbids something?** The evidence splits along this line. Mandated checks earned their keep: the trail review, blast radius, the design-hole path. Your correction was about not constraining "the design architecture of how the task is pursued," though, and a mandatory step does constrain it. Options:
- (a) Same treatment. A required step is route, so it's binding only if its owner made it so (Q1).
- (b) A required step that adds a check is allowed by default. Only rules that forbid something need an owner.
- (c) A required step is binding, but the reader may do more around it, or a stronger version of it.

➡️ (a) plus (c). Whether a step is required is still your call. Once it is, it sets a minimum the reader must reach, not a ceiling. That covers both the trail review and the "Execute only the task and path scope the parent assigns" wrapper line, which turns a scope into a ceiling.

---

Not for this ticket: `MANUAL.md:168` still says "twelve ordered beliefs," but PHILOSOPHY has eleven since the cost belief was removed. Also, our prose repeats hook-held limits to subagents that the hook deliberately exempts. That belongs to "Decide where each piece lives and when it reaches the writer."

Q2, Q4 and Q5 stand as asked. I'm waiting on your answers to Q1–Q6.