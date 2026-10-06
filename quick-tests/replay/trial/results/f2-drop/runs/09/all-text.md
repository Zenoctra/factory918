The search finished. Your answers to round one aren't in yet, so nothing is decided. Three of its findings change the questions, so here's what to weigh before you answer.

**1. The factory has five different ways to depart from a rule, and they point different ways.**
- **Sign-off first.** "Say so loudly and get a sign-off before breaking it" (`AGENTS.md:26`, `template/AGENTS.md:20`). It came from Theo's file, and no skill repeats it. A subagent has no way to get a sign-off, and the mandate tells subagents to ignore it.
- **Follow first.** "Follow the file and tell me why your instinct differed" (`template/AGENTS.md:16`).
- **Decide and record.** The reader makes its own call and logs it as a Provisional row in `DECISIONS.md`.
- **Skip visibly.** pstack's `skip: <reason>`. `feature.md:12` switches it off for delegation.
- **Report back.** `accepted: <reason>`, "stop and report the cell", the dated amendment for a design hole.

None of the run-2 audits looked at these. That turns my Q3 into a bigger question than I posed it: should the standard keep one way to depart, and which?

**2. Some rules about the route did real good.**
- The mandatory trail review caught the owner's errors in 3 of 3 runs.
- An owner narrowed its own reading, and a hook bug survived four review rounds. That's where the blast-radius rule came from.
- A lane broke the delegation rule knowingly, so prose wasn't enough and a hook now holds it.

All three are rules you set from evidence, and every one bounds the route. They fit my Q1 recommendation, where your ownership is what makes a rule binding. They don't fit a test based only on what a rule is about. That's another reason to pick (a) and (b) together.

**3. The old framing is still built into the audit everyone would start from.** The constraints audit's five classes put "safety, kept" against "what it may look at or run, cut". That's the "protect the world / shape the search" split you corrected. Its brief also said "Do not propose new constraints." Its own late addendum admits the first pass treated the `spec:` gate as "report format" and skipped it. That gate made Sol file nothing on a PR with four hard bugs, and it is a rule on how the work is finished, not on search. So when the "Decide the scope and order of reworking existing files" ticket uses that audit, it needs re-sorting under whatever test you pick here. I'll add that as a note on that ticket once this one closes.

Most of the audits' recommendations haven't been applied yet. "Execute only the task and path scope the parent assigns", the 150-line read cap in `knowledge`, and the `spec:` gate are all still live. That fits a map that plans before it changes anything.

Here is Q3 rewritten to take in the first finding:

❓ **Q3 - How does a reader depart from a rule, and does the standard keep one way?** Here are three ways the standard could go:
- (a) **One way for every reader.** A route rule is knowledge the reader may depart from, with the reason given in its report. A binding rule that fights the goal stops only that part of the work and is reported to the rule's owner; the rest carries on. "Follow first" and "sign-off first" go, and the existing mechanisms are rewritten to match.
- (b) **Keep sign-off for the session you're in, use (a) for subagents.** Departures differ depending on whether a person is there to answer.
- (c) **Keep all five,** and write down which applies where.

➡️ (a). With one way to depart, every rule that can't reach your attention fails the same visible way. Today a silent departure is the easiest of the five. (b) is what (a) reduces to anyway when you happen to be in the conversation.

Q1, Q2, Q4 and Q5 stand as I asked them. I'm waiting for your answers before anything is recorded on the ticket.