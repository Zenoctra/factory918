Before I pass on what the search found, I'm reading the rules it says conflict, in their own files.

---

The search is back. Your round-one answers are still open; this is what it found and how it changes those questions.

**Where rules on method helped.** Some rules about how the work is done prevented real failures:
- The mandatory review of an owner's decision log caught the owner's mistakes in 3 of 3 runs.
- The design-hole check found two holes that two runners and a judge had missed.
- An agent broke the delegation rule knowingly, and now a hook holds that rule.

Each of these was set by you, and each carries a reason measured from a real run. That fits the recommendation I gave under Q1: what made them binding was who owns them and the reason attached, not the topic of the rule.

**Where they hurt, beyond searching.** The damage isn't limited to what a reviewer may read. The "at most N lanes" prediction in P109 is one example. Another is the Standards review's requirement to cite a `spec:` line from a ticket it never shows the reviewer. That requirement made honest reviewers demote real bugs: Sol filed nothing on PR 99, which had four hard bugs. So a rule about how findings are reported did as much harm as a rule about reading.

**The run-2 constraints audit used the old test.** It sorted limits into "what the lane may look at" and similar categories versus "safety" and "report format", and only then judged them. That's the "protect the world / shape the search" split you've rejected. Its own late addendum admits the report-format group hid the worst case. So its list of rules to keep needs re-judging under whatever test Q1 settles, and that belongs to "Decide the scope and order of reworking existing files". Most of its recommended cuts haven't been applied yet.

**The ways a reader may depart from a rule apply to different situations.** The search reported them as conflicting. I read each one where it's written, and they don't conflict:
- "Follow the file and tell me why your instinct differed" (`template/AGENTS.md:16`) covers disagreeing with a pattern on taste.
- "Say so loudly and get a sign-off" (`:20`) covers a rule that blocks the task.
- "Proceed on anything reversible" (`:18`) covers actions, not rules.
- The playbook's `skip: <reason>` covers your own todo steps. The delegation step removes that option on purpose.

The real gap is the one in Q3: nothing says what a subagent does when it has no one to get a sign-off from. Nobody has ever audited these departure rules.

**The research for "Research how wording and missing context shape a reader's response" is already written**, on its research branch, and it has a section on this ticket:
- It supports your wider framing. The costliest effects it found in people come from bars on reporting, specific goals set for complex tasks, step-by-step instructions given to experts, and controlling wording, not only from limits on reading.
- No study of models tests a limit on strategy directly.
- It draws a distinction that changes my Q2. A rule that limits what the reader may look for is different from the writer choosing not to share something, such as their own view of where the bug is. The forensic evidence backs the writer holding back. So "route knowledge", which Q2 recommended sharing with its reason, can itself lead the witness.

**Revised Q2 recommendation:** share a fact about the route only when the reader couldn't easily find it itself, such as a tool quirk or a trap that cost a run. Give the reason, and never present it as an order. Never share the writer's guess about the answer. A known trap helps the reader; a hunch about where the bug is points them at it.

Q1 and Q3–Q5 stand as asked. One unrelated slip turned up: `MANUAL.md:168` still says "twelve ordered beliefs", but the philosophy has had eleven since the cost belief was removed. I'll put that in the ledger rather than this map.