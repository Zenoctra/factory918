Your answers are saved word for word in a local file. Posting them to the ticket was declined, so they'll go into the resolution comment unless you want them posted sooner. Your budget rule is already in my memory as you stated it. A note on names: the first mode is called `safe` in the factory, and the second is `eco`.

Three notes go elsewhere when this ticket closes:
- Your point about one strongly associated term pulling a whole set of rules with it goes to "Decide how we'll know the writing works" as an experiment to run, and to "Decide what the writing standard is and what carries it" as a principle.
- The wall-clock budget goes to the map "Design Let It Rip as the third mode".
- The review system is Q5 below.

Before round two, here's Q1 made concrete, since you asked for that.

**Q1 in plain terms.** Every rule in a brief gets two questions:
1. Does it say *what* to achieve, or *how* to go about it?
2. If it says how, did you decide it?

A "what" rule binds. A "how" rule binds only if you decided it. Any other "how" becomes something the reader is told, with the reason, and is free to act on differently.

---

❓ **Q1 - Do these six verdicts match what you meant by (c)?** Each is a real rule in the factory today.

1. **"Never push to main"** (AGENTS.md, held by the guard hook). It says what isn't the reader's to decide, because merging is yours. **Binds.**
2. **"The orchestrator never writes the code; a lane does"** (held by the delegation hook). It's a "how", but you decided it, and the evidence is that an agent broke it knowingly when it was only prose. **Binds.**
3. **"Never read more than 150 lines in one call"** (the `knowledge` skill). It's a "how", with no recorded reason, and nobody remembers you choosing 150. **Doesn't bind.** It becomes information ("the core documents are long; reading by section keeps your context free"), or it goes.
4. **"Execute only the task and path scope the parent assigns"** (pstack's wrapper for lanes). One sentence holding two rules:
   - "These files belong to another lane" is ownership. **Binds.**
   - "Do only this" limits the route. **Doesn't bind.**

   So the test works per rule, not per sentence.
5. **The `spec:` gate** ([review-brief.sh:494](template/.agents/skills/spec-review/scripts/review-brief.sh:494)): a finding without a citation is sent back. Your definition of a hard bug is yours (P18), so it binds, but under your Q3 answer it binds on the filter step, not on the reviewer. The reviewer reports everything, and the citation decides afterward which findings count as hard. It no longer decides which findings get filed at all.
6. **"Subagents never launch their own dev servers"** (template AGENTS.md). You adopted it from Theo, so it **binds**. But its reason was dropped when it was copied, and Q4 below asks whether a binding rule needs to carry its reason.

➡️ Yes to all six, if they match what you meant. If one doesn't, that's where my reading of (c) is wrong.

---

❓ **Q2 - Does Q3 (a) still stand after this correction?** You said "if you are saying the evidence says both get found". It doesn't say that, and I should have been clearer. The evidence says a bar makes a reviewer **hold back findings it already made**, and moving the bar to a filter step fixes that. Your worry is a different failure: a reviewer that **never notices** a kind of bug because its attention went elsewhere. That's the gorilla finding, and it's real. (a) doesn't fix it.

What did fix it in the one model study was a second reviewer with a different, open brief, which recovered everything the focused one missed. Your "slight push toward the bugs we're wary of" is a list, and the evidence on partial lists says a partial list pulls attention toward what it names and away from the rest. So the fix for attention is more than one pass, not a better-worded push, and that belongs to the review system (Q5).

➡️ Keep (a) for what it fixes. The attention problem goes to the review system and isn't solved by wording in this ticket.

---

❓ **Q3 - The five ways the factory lets a reader depart from a rule today.** This is the earlier Q4, now with the list.

1. **Ask first.** "If one fights the task in front of you, say so loudly and get a sign-off before breaking it" ([template/AGENTS.md:20](template/AGENTS.md:20), and [AGENTS.md:26](AGENTS.md:26) here). A subagent has nobody to ask, and nothing says how it would get a sign-off.
2. **Obey, then explain.** "When this file and a vendored skill disagree with your instinct, follow the file and tell me why your instinct differed" ([template/AGENTS.md:16](template/AGENTS.md:16)).
3. **Decide and record.** Where the spec is silent, the agent decides and records a Provisional decision you can overrule ([ticket.md:30](template/.agents/skills/poteto-mode/playbooks/ticket.md:30)).
4. **Skip visibly.** A playbook step the agent skips stays in its list as `skip: <reason>` (poteto-mode, from upstream). The delegation step forbids even that ([feature.md:12](template/.agents/skills/poteto-mode/playbooks/feature.md:12)).
5. **Write it back onto the artifact.** A writer's flag must end in `fixed: <sha>` or `accepted: <reason>`, and the review script refuses to run until each does. A writer that can't implement a scenario cell as written stops and reports that cell.

Where they conflict: 1 says ask before acting, 2 says obey and explain afterward, and 3 and 4 say act and record. For one situation (a rule fights the task), 1 and 2 give opposite instructions.

The proposal:
- **One rule** replaces 1 and 2.
  - On the route, the reader uses its judgment, and its report always says where it departed and why.
  - When a binding rule fights the goal, the reader stops that part, reports to the rule's owner, and carries on with the rest.
  - It never shrinks the goal to fit a rule.
- **3, 4 and 5 stay** as the places a departure gets written down: the decisions table, the step list, and the ticket.

1 and 2 are written in your voice in the template's AGENTS.md, so replacing them changes your words.

➡️ Replace 1 and 2 with the one rule, and keep 3, 4 and 5 as its records.

---

❓ **Q4 - How are binding rules written and held?** The research says:
- current Claude over-applies emphatic wording ("NEVER", "CRITICAL");
- a bare "don't" keeps the forbidden idea active without saying what to do instead;
- a reason lets the reader handle the case the writer didn't foresee.

Your Q2 note adds the cost of count: every rule stated takes focus from the others. The guard hook already shows a good pattern. When it refuses, it says why and names a way forward ("Use --force-with-lease on your own branch, or ask"). The options:
- (a) Every binding rule carries its reason and its owner in plain words, without emphasis, and is stated where the reader meets it. Where a hook holds the rule, the hook's refusal message carries the reason and the way forward, and the briefs stop restating it.
- (b) Hooks hold it, and the briefs restate it as well, to be safe.

➡️ (a). The refusal message arrives at the moment of use, which is where the research says guidance works, and it takes one rule out of every brief.

---

❓ **Q5 - Where does the review system go?** This map's Destination covers how review briefs are *written*, and the "Prototype brief templates for the recurring lane jobs" ticket will draft them. What you describe is bigger:
- several passes with different briefs;
- a verifier that sorts findings;
- measuring recall, meaning how many known bugs get found and not just how few false alarms;
- your own system replacing `interrogate`'s leading parts.

That's process, not writing. Some groundwork exists: the run-2 reviewer evals measured recall against planted bugs, and found 4 of 13 labelled bugs sitting in files the brief told reviewers not to open. The options:
- (a) The review briefs stay here. The review system becomes its own map, built on this map's decisions, and is recorded under this map's Out of scope with a link.
- (b) Widen this map's Destination to include it.
- (c) Add it as a ticket on this map.

➡️ (a). It's at least as big as this map. This map's decisions on wording, bars and passes are its foundation, so it starts after them, and it gets its own Destination instead of riding inside one about writing.