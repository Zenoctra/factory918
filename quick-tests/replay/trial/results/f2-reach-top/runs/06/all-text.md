The background search finished. You haven't answered round one yet, so the questions stand. Five of its findings bear on them. Two change what I'd recommend.

**Rules about the route that did good.** The search found route rules that earned their place:
- Mandatory trail review caught the owner's mistakes in all 3 runs where it ran (`ticket.md:26`).
- A lane that narrowed its own grounding let a hook bug survive four review rounds, which is why the blast-radius rule exists (`ledger.md:17`).
- The delegation rule needed a hook because the prose alone was broken knowingly (`ledger.md:16`).

None of these is the writer guessing a better route. Each corrects a measured failure in how the reader judges its own work: checking itself, stopping early, scoping narrowly. That gives Q1 a third possible test. A route rule could be binding when it records evidence that the reader's own judgment fails at this point.

I'm flagging the risk in that test myself. It could become another two-bucket proxy like the one you rejected. My recommendation still stands: what the rule is about plus who owns it. I'd add that every binding rule carries its reason and evidence. Today many don't: "never an arena", the 150-line cap, the 30-second suite limit, and "Do exactly the task in your prompt" in the agent files.

**Q2 for judging lanes.** The research written for "Research how wording and missing context shape a reader's response" separates two things:
- **What the writer volunteers.** Holding back its own guess protects the reader's independence.
- **What the reader may seek.** Limiting that is the harm this ticket is about.

In the one model study, telling a reviewer *where to look* hid findings that an open-ended critic later recovered. So route knowledge that points at where the answer probably is counts as leading the witness. My refined answer to Q2 is (b) in general and (a) for any lane that judges. The same research supports your broader framing over the search-only one. Its counterweight is that specific method helps on simple tasks and with novice readers.

**Q3: the factory already has five ways to depart from a rule, and they disagree.**
1. "Say so loudly and get a sign-off" (`AGENTS.md:26`, `template/AGENTS.md:20`). It's Theo's line. No text says how a subagent gets that sign-off, and it pulls against "never block on the human".
2. "Follow the file and tell me why your instinct differed" (`template/AGENTS.md:16`). This is the opposite: comply first, report afterwards.
3. "Re-read PHILOSOPHY, or record a Provisional decision."
4. pstack's `skip: <reason>`. `feature.md:12` turns it off for delegation.
5. Our artifact-level exits: `accepted: <reason>` on flags, the writer stopping on a cell it can't implement, the design-hole amendment.

No audit looked at these. My Q3 recommendation (stop that part, report it to the owner, carry on) fits 4 and 5, contradicts 2, and fills the gap in 1. Which of the five survive depends on your Q3 answer, so that question waits for round two.

**Q4 and Q5 get support.** The constraints audit found the review-brief limits were added by lanes to save cost; no ticket asked for them (#33, #93, #107). Your rule from 2026-09-17, "talk to subordinates through templates", was said once and never written down.

**State.** Most of the audits' recommendations haven't been applied yet. "Execute only the task and path scope…" is still in the pstack wrapper. The `spec:` gate that made honest reviewers demote real bugs is still live in `review-brief.sh:494`. That work belongs to "Decide the scope and order of reworking existing files", not to this ticket.

**Outside this map:** `MANUAL.md:168` says "twelve ordered beliefs", but PHILOSOPHY has had eleven since ecdb732. I can file a quick ticket for it if you want.

Round one is waiting on your answers to Q1–Q5.