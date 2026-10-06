The background search came back. It doesn't settle any of the round-one questions. It does change how I'd frame two of them, and it raises one new question.

**What it found that bears on this round**

- **The factory gives five different answers to "a rule fights the task", and they contradict each other.** The two AGENTS.md files say to say so loudly and get a sign-off. The template's [AGENTS.md:16](template/AGENTS.md:16) says the opposite: "follow the file and tell me why your instinct differed." PHILOSOPHY and DECISIONS say to decide and record a Provisional row. Upstream pstack allows a visible `skip: <reason>`, and [feature.md:12](template/.agents/skills/poteto-mode/playbooks/feature.md:12) then forbids that skip for delegation. No text says how a subagent would get a sign-off. None of the run-2 audits looked at these mechanisms.
- **Some rules on the route have clearly done good**, all recorded in [ledger.md](docs/agents/ledger.md):
  - The trail review was made mandatory after 3 of 3 lanes that ran it caught owner errors.
  - An agent scoped its own grounding too narrowly, and a hook bug survived four review rounds. That led to the blast-radius rule.
  - An agent broke the delegation rule knowingly. That is why a hook now holds it.

  These are the strongest counter-case to "the route belongs to the reader."
- **A rule about how the work is finished did as much damage as the reading limits.** The Standards brief requires a `spec:` citation from a ticket it never shows the reviewer. So honest reviewers demoted real bugs, and Sol filed nothing on PR 99, which had four hard bugs. The constraints audit had kept "hand-back format" as a safe class, and its own late addendum retracts that.
- **The constraints audit's five classes match the framing you rejected.** It sorted limits into what a lane may look at, what it may run, caps, safety rules (kept) and hand-back format (kept). Its counts are useful. Its categories shouldn't be reused.
- **The research on the `research/wording-and-reader-context` branch adds a counterweight.** Step-by-step method helps on simple tasks and for novice readers. It finds no study that tests a limit on strategy as such.
- **Most of the audits' recommendations haven't been applied yet.** Two examples: "Execute only the task and path scope the parent assigns" is still in the pstack wrapper, and the 150-line read cap is still in `knowledge`.

**How this changes round one**

- **Q1:** my recommendation stands, but here is the case it has to survive. The trail review, blast-radius and delegation rules are all about the route, and they all exist because readers got the route wrong when left free. Under my test they bind only because you set them, with evidence. The alternative would be: a rule about the route earns binding status by evidence that readers get that part wrong. I'd still keep it as your call, because evidence can be found for almost any limit after the fact. That is how "read only the brief" got justified as a cost fix nobody asked for.
- **Q3:** the five mechanisms map onto three cases. A rule that fights a binding rule: stop that part and report it to the rule's owner, which is what [feature.md:12](template/.agents/skills/poteto-mode/playbooks/feature.md:12) already does for writer cells. Knowledge about the route: take another route and report it, as in Q2(b). The spec says nothing: decide and record a Provisional row. "Follow the file and tell me why your instinct differed" and the sign-off line would both be replaced. I'd add that to the recommendation.

**New question**

❓ **Q6 - Is the shape of the report part of the task, or part of the route?** Your approved template line put "how to report" in the fixed part of a brief. The `spec:` gate shows that a report's shape can quietly shrink the goal: a finding that doesn't fit the format gets dropped.
- (a) The report's shape is binding, because the next reader depends on it.
- (b) The report's shape is binding only as far as the next reader needs it, for example a script that parses it. A format must never be the reason a finding is left out, so anything that doesn't fit goes in a section reserved for it.
- (c) The report's shape is knowledge, like the rest of the route.

➡️ (b). The parser's needs are real. "Must cite a spec line to count" is a filter dressed as a format.

**Coming in a later round**

- **Hooks:** belief 3 in PHILOSOPHY pushes every rule to the strongest rung, a hook. Once Q1 settles, the question is whether only binding rules may climb that far, so that knowledge about the route never becomes a hook. That depends on Q1, so it waits.
- **Stale count:** an aside the search found. MANUAL still says "twelve ordered beliefs", but PHILOSOPHY has had eleven since the cost belief came out. That's a one-line fix outside this map. I'll file it as a quick ticket unless you'd rather not.

Q1 to Q6 are all still open for your answers.