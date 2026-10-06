The background search is done. It doesn't settle any of the five questions, but three of its findings bear on them. One changes what Q3 is really asking.

**For Q3: the factory has five different ways to depart from a rule, and they disagree.**
- **Sign-off first.** `AGENTS.md:26` and `template/AGENTS.md:20` say to state the conflict loudly and get your approval before breaking the rule. Nothing says how a subagent gets that approval. It also pulls against "never block on the human" in the same file.
- **Follow it, then explain.** `template/AGENTS.md:16` says to obey the file and tell you why your instinct differed.
- **Decide and record.** `PHILOSOPHY.md` and `DECISIONS.md` say that where the spec is silent, the agent makes the call and adds a Provisional row for you to overrule.
- **Skip visibly.** Upstream poteto-mode allows skipping a step with a written `skip: <reason>`. The feature playbook then forbids that for delegation.
- **Stop and report.** A writer that can't build a test case as specified stops and reports it rather than improvising. A writer's flag must end as fixed or as accepted with a reason.

No audit has looked at these, and nothing shows the sign-off rule has ever been used. So Q3 is really asking which of these becomes the single rule. My recommendation stays the same: stop that part of the work, report the conflict to whoever owns the rule, and carry on with the rest. That is closest to the fifth way, and it would replace the sign-off wording.

**For Q1: the rules on the route that worked were all ones you set.**
- The mandatory trail review caught the owner's mistakes in 3 of 3 runs.
- The delegation rule now has a hook, because the prose alone was broken knowingly.
- The design-hole step caught two gaps that two writers and a judge had missed.

The rules that did harm were added by agents. Some were added to save cost: the reviewer reading limits (#33, #93, #107), "zero items is the expected result", and "under 400 words". In another case a lane turned your question into a rule on a ticket. That supports deciding by who owns a rule, not by what it covers.

The run-2 constraints audit also sorted limits into "what the lane may look at / run / output" versus "safety", which is the old split you rejected. Its own addendum then admits it missed rules on how work gets finished. One example is the `spec:` gate in `review-brief.sh`. It makes reviewers cite a ticket they are never shown, so honest reviewers file real bugs as minor. That gate is still live.

**For Q2: the research for this map draws a line we should keep.** It's on the `research/wording-and-reader-context` branch. It finds that the broader framing is supported. It also adds a counterweight: specific method helps on simple tasks and for readers new to the work. It separates what the writer chooses to share from what the reader is allowed to go and find. That fits recommendation (b): share what you know, give the reason, and set no limits.

One fact outside this ticket's scope: `MANUAL.md:168` says "twelve ordered beliefs", but `PHILOSOPHY.md` has had eleven since the cost belief was removed. I haven't touched it.

I'm waiting on your answers to Q1–Q5 before the next round. If the five departure mechanisms make you want to reframe Q3, say so.