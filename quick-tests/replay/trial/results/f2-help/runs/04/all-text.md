The background search finished. Your round-one answers are still outstanding, so I won't build anything on them yet. Three findings change Q1 and Q2, and the revised versions are below. Q3 to Q5 stand as I wrote them.

**1. The old "safe" categories hid a harmful rule.** The run-2 constraints audit sorted rules much as the framing you corrected did. It treated safety rules and "report format" rules as fine to keep. Its late addendum found that one of those format rules did real damage. The Standards reviewer had to cite a `spec:` line from a ticket it was never shown. Sol obeyed and filed nothing on PR 99, which had four hard bugs. That is your correction in action: a rule on how the work is finished, not how it's searched, and it sat in the category everyone had marked harmless.

**2. Rules about the route have also done good, and the good ones share a trait.**
- The mandatory trail review caught the owner's errors 3 times out of 3 (`ticket.md:26`).
- The blast-radius rule exists because an agent scoped its own grounding narrowly and a day-zero bug got through four review rounds.
- The delegation hook exists because an agent broke the delegation rule knowingly.

Each one answers a failure that was observed when an agent took its own route. The harmful ones were predictions. You named that difference yourself on P109: the "at most" list was "a prediction, not a constraint".

**3. The #154 research (on the branch `research/wording-and-reader-context`) splits something I had merged.**
- Holding back what the writer volunteers, such as its own guess about where the bug is, protects the reader's independence. The forensic evidence supports that.
- Limiting what the reader may seek is a different thing, and nothing supports it.
- One counterweight: specific method helps on simple tasks and for novice readers.

The research also says no study on models tests a limit on strategy as such. The case for your framing rests on human evidence, plus Garfinkel's and Suchman's point that no rule written in advance contains the situation it will meet.

**On the rules for departing from a rule.** I read each one where it's written. They don't contradict each other; each covers a different situation:
- An agent's instinct disagrees with the file: follow the file and explain (`template/AGENTS.md:16`).
- A rule fights the task: say so loudly and get a sign-off (`:20`).
- A playbook step isn't worth doing: `skip: <reason>`, never silent.
- A writer can't implement a cell: stop and report it.
- The spec is silent: decide, and record it as Provisional.

What they share is that a departure is always made visible. The one real gap is the one Q3 already asks about: the sign-off line assumes a person is there to give it.

---

❓ **Q1 (revised) - What makes a rule about the route binding?** My recommendation was that a rule is binding only if it states the task or a limit of authority, and only that authority's owner can make it binding. Finding 2 adds another candidate test.
- (a) What the rule is about: the task and its limits of authority, never the route.
- (b) Who owns it: binding only if its owner said so.
- (c) No single test; each rule is argued on its own.
- (d) What the rule answers: a rule about the route may bind only when it answers a failure that was observed when an agent took its own route, and it names that failure. A rule written from a prediction doesn't bind.

➡️ (b) with (d): you or the ticket's owner set it, and it carries the observed failure it answers. The trail review, blast radius and delegation all pass. "Read only the diff" and the `spec:` gate don't, and neither does any guess an orchestrator writes into a brief. Naming the failure also lets a reader recognize a case the failure never covered.

---

❓ **Q2 (revised) - How should the writing carry what the writer knows about the route?** Finding 3 splits this into two kinds of knowledge:
- **About the world:** a tool quirk, a guard that refuses `$(...)`, where the results go.
- **About the answer:** what the writer expects the reader to find, where it thinks the bug is, what it hopes is true.

➡️ Knowledge about the world goes in when the reader couldn't easily find it, with the reason, as something the writer knows, never as an order. The reader may take another route and says so in its report. Knowledge about the answer stays out, especially for a reader whose job is to judge, because that's leading the witness. Whether simple mechanical jobs (a records lane, a fix lane) should get more step-by-step detail is still open; my lean is no for now, and #153's measurement can show whether that's wrong.

---

Two things are outside this ticket, so I'll only flag them:
- Most of the audits' recommended cuts haven't been applied yet. For example, `pstack-opus-medium.md:12` still says "Execute only the task and path scope the parent assigns". That work belongs to the rework ticket, "Decide the scope and order of reworking existing files".
- `MANUAL.md:168` still says "twelve ordered beliefs"; PHILOSOPHY has eleven. I can file a quick ticket for it.