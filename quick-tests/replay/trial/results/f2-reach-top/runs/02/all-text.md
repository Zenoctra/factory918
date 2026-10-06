The background search came back while your round-one answers are still open. None of the questions are settled, and I'm treating nothing as approved. Five findings bear on the questions:

- **The factory gives a reader five ways to depart from a rule, and they disagree (Q3).**
  - `AGENTS.md:26` and `template/AGENTS.md:20`: say so loudly and get a sign-off.
  - `template/AGENTS.md:16`: follow the file first, then explain.
  - The Provisional row in `DECISIONS.md`: decide yourself and record it.
  - pstack's `skip: <reason>`.
  - The review scripts' `accepted: <reason>`.

  The sign-off line came from Theo's file almost word for word. Nothing says how a subagent gets a sign-off, and the line pulls against "never block on the human". No record shows it was ever used. That supports picking one way in Q3 and changing the other four to match.

- **Rules about the route have also done good (Q1 and Q4).** Making the trail review mandatory caught owner mistakes 3 times out of 3, and the delegation rule needed a hook because prose alone was ignored. You set both from evidence, and the test I suggested still holds them: they're binding because you own them. The rules that did harm were the ones a lane made up for cost, which nobody had asked for: #33, #93 and #107.

- **"How to report" is not automatically safe.** The map's template outline put "how to report" in the fixed part. But the Standards review brief requires a `spec:` citation from a ticket it never shows the reviewer, so honest reviewers marked real bugs as less serious to fit. One of them wrote it was "not filed hard because the Standards brief carries no ticket criteria to cite." That's the same failure as your smell-list example, coming in through the report format. It leads to a sixth question, below.

- **The research for this map is already written.** It's `docs/research/wording-and-reader-context.md` on the unmerged branch `research/wording-and-reader-context`. It supports your broader framing over the reviewer-only one. It also gives two counterweights:
  - Spelling out the method helps on simple tasks and for readers new to the work.
  - A writer holding back what it volunteers is a different thing from limiting what the reader may look for.

  That second point matches Q2's "knowledge, not orders". The research ticket, "Research how wording and missing context shape a reader's response", is still open on GitHub.

- **Most of the run-2 audits' fixes haven't landed.** Still live:
  - the wrapper line "Execute only the task and path scope the parent assigns";
  - the `knowledge` skill's 150-line cap;
  - the review-brief limits;
  - the `spec:` gate.

  Whatever this ticket decides applies to those lines when the rework happens. Separately, the audits sorted rules using the old protect-the-world / shape-the-search split, so they skipped rules about order and process unless one happened to cap output.

---

❓ **Q6 - Can a report format decide what counts as a finding?** The receiver owns the format, because a script or the next lane has to parse it, so by Q1 the format binds. The question is whether it can also filter what the reader is allowed to report. The options:
- (a) The format binds only the shape. Anything the reader found that doesn't fit the format still gets reported, marked as not fitting.
- (b) The format may define what qualifies, and anything that doesn't qualify is dropped.

➡️ (a). Under (b), a format written for parsing quietly becomes a limit on the goal, which is what happened with the `spec:` gate. Under (a), a mismatch between the format and the finding becomes a Q3 conflict that gets reported, not a bug that's thrown away.

---

Q1–Q5 from my previous message are still open. Answer whichever you like in any order. After this round settles, I'll post your answers on the ticket, close it, and add a line to the map.