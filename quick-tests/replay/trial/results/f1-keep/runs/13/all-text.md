I couldn't recover the copy of your answers I'd saved, because the scratch folder was reset, so I've saved them word for word again. They'll go on the ticket with the resolution, and I'll add pointers on the map and on the Let It Rip map at the same time.

## Settled from your answers

- **Q2: (b).** Pinned for every decision that rests on this: each rule added costs the reader attention. Your micro-genre idea is a hypothesis to test. One well-chosen term may pull a whole set of rules in with it, and then only what that term wouldn't carry needs saying. At resolution I'll record it, in your words, on "Decide what the writing standard is and what carries it" and as an experiment on "Decide how we'll know the writing works".
- **Q3: (a).** The reader reports everything it found. Any bar is applied afterward, by a separate step. Your worry gets its own question below, because the evidence is less comforting than I made it sound.
- **Q5: settled as you put it.** Here is my restatement, so you can correct it:
  - In `safe` mode (the first one; you called it Safety Mode), no budget ever shapes the process. Tokens and time are measured afterward, only to look for savings.
  - In `eco` and Let It Rip, a budget exists only if you set one. Before it reaches any brief, the agent asks you how much it should weigh. Let It Rip adds wall-clock time as a second budget, handled the same way.
  - A goal you set for the mode doesn't mean the reader is told about it, and it never overrides steps you've made required.
  - When in doubt, budget stays out of the brief. If the writer thinks it matters but can't ask, it goes in as information, not a limit. A budget written as binding means you approved it.
  - Your story (a predicted halving of token use became a closing requirement, and the agent cut required steps to hit it) is the same mistake as the "at most" list in decision P109: a prediction turned into a rule.

---

❓ **Q1, again, in practice.** Every line of a brief gets two questions:

1. Is this line about **what's wanted**, or about **how to get there**?
2. If it's about how, did **the person who owns that call** say it must hold?

If a line is about what's wanted, or the owner said it must hold, it binds. Otherwise it's information the reader may use or set aside. Here is a made-up reviewer brief, line by line:

| Line in the brief | What or how? | Who said so? | Result |
|---|---|---|---|
| "Review PR #160 against what its ticket asks for." | What | n/a | Binds |
| "Don't merge, push or post on GitHub." | Who decides: those calls are yours | You, in AGENTS.md | Binds |
| "Don't edit `src/foo`; another lane is writing it now." | Who decides: that lane owns the file | The orchestrator, which runs the lanes | Binds |
| "The orchestrator never writes code itself." | How | You, with evidence | Binds, because you set it |
| "Read only the diff and the ticket." | How | The orchestrator's guess | **Doesn't bind.** It's cut, or turned into a fact: "the diff changes `delegation.sh`, which every root session runs" |
| "Start with `delegation.sh`; last round's bug was there." | How | The orchestrator's experience | Information with its reason. The reader may start elsewhere and says so |
| "Every finding must cite a ticket line." | How it's finished | n/a | Moves out of the brief into the filter step (your Q3) |

The fourth and fifth rows are both about how. The only difference is who said it, and that's the point of (c). An orchestrator can't turn its own guess into a rule; only you can.

➡️ Confirm (c) with this picture, or tell me which row looks wrong to you.

---

❓ **Q4, with the five mechanisms that exist today.**

| # | The mechanism | Where | The problem |
|---|---|---|---|
| 1 | **Ask first.** "If one fights the task in front of you, say so loudly and get a sign-off before breaking it." | [AGENTS.md:26](AGENTS.md:26), [template/AGENTS.md:20](template/AGENTS.md:20), taken from Theo | A subagent has nobody to ask, and no text says how it would. It also pulls against "never block on the human". |
| 2 | **Obey first, explain after.** "Follow the file and tell me why your instinct differed." | [template/AGENTS.md:16](template/AGENTS.md:16), your own note | It's the opposite of #1, about the same file. |
| 3 | **Decide and record.** Where the spec is silent, the agent decides and writes a Provisional row in DECISIONS that you can overrule. Separately, re-read PHILOSOPHY "when a rule fights you". | DECISIONS, [MANUAL.md:168](docs/knowledge/core/MANUAL.md:168) | It covers gaps in the spec, not conflicts with a rule. |
| 4 | **Skip visibly.** A step not done stays in the list as `skip: <reason>`; skipping silently isn't allowed. Turned off for delegation. | [poteto-mode SKILL.md:113](template/.agents/skills/poteto-mode/SKILL.md:113) (upstream), [feature.md:12](template/.agents/skills/poteto-mode/playbooks/feature.md:12) | None. It's my proposal for route steps, already working upstream. |
| 5 | **Send it back.** Each writer flag must end `fixed:` or `accepted: <reason>` before review runs. A writer that can't build a table cell as written stops and reports it. A design hole amends the ticket. Bad criteria go back to you. | spec-review, Ticket and Feature playbooks | None. It covers a different case: the artifact can't be built as written. |

So my earlier "one mechanism replaces five" was too strong. Only #1 and #2 conflict. Corrected proposal:

- **A route rule:** the reader uses its judgment, and its report says where it departed and why, or says it didn't. This is #4, applied everywhere.
- **A binding rule that fights the goal:** the reader stops that part, reports the conflict to the rule's owner, and carries on with the rest. When the owner is you and you're right there in the session, that is #1, so #1 survives where someone can actually sign off.
- **Never** shrink the goal to fit a rule.
- #3 and #5 stay as they are.

➡️ Agree?

---

❓ **Q6 - Your own note, line 16.** "Follow the file and tell me why your instinct differed" comes from your stance that a copied professional pattern beats a model's first-principles idea. Under Q1, most lines in that file are about how, so the reader could depart from them. These are two of your positions, and they pull against each other. The options:

- (a) Your note makes every line in the file binding.
- (b) Your note binds only the lines you mark as required. Everywhere else, the reader departs and reports why. That delivers the same learning ("tell me why your instinct differed") without the obedience.
- (c) Something else.

➡️ (b). The report line keeps what your note is for, which is learning where the rules are wrong.

---

❓ **Q7 - Should a review brief name the kinds of bug we're most worried about?** Your worry is real, and I overstated the comfort. The research shows two different effects:

- **A bar** ("report only X") makes the reader find things and then withhold them. Your Q3 answer, (a), fixes that.
- **A focus** ("look for X") makes the reader not see Y at all. That's the gorilla study. In Shin's preprint, a focused instruction suppressed findings the same models reported without it.

A focused reviewer reading past the bug we wanted is the second effect, and that's exactly your worry. A "slight push toward the kinds we fear" is itself a focus. By the list evidence (four listed problems went from 2% of answers to 60%), it pulls attention toward those kinds and away from everything else. The one fix with evidence behind it is structural: in Shin's study, a separate reviewer with an open-ended brief recovered every omitted finding. The options:

- (a) Name feared kinds of bug in the brief.
- (b) Never name them in an open reviewer's brief. Where a kind really matters (security, say), add a separate lane whose task is that kind, alongside the open reviewer. The open one stays unfocused.
- (c) Name them, labelled as examples rather than a limit.

➡️ (b). Specialists go in their own lanes, never as a nudge to the generalist. That's a review-process decision, though, so it depends on Q8.

---

❓ **Q8 - Where does the review system get designed?** You're describing more than better briefs. It means several passes, specialist lanes beside an open one, a verifier that sorts findings by kind, the filter step from Q3, and the leading in vendored `interrogate`. That's process design. This map's destination is how writing works, including the review briefs. The options:

- (a) Fold the whole review system into this map as new tickets.
- (b) This map keeps the review *briefs*. The prototype ticket for brief templates and the rework ticket already put adversarial briefs first. The review *process* becomes its own map, a sixth one, charted later. Today's Q3 and Q7 decisions get handed to it as starting points.
- (c) Leave it in this map's "Not yet specified" and decide later.

➡️ (b). Review is big enough to deserve its own destination, and mixing it in would blur this one. Charting it is its own session, so it waits until you choose to start it. At this ticket's resolution I'd put it under "Out of scope" here, with a pointer.

Your 50% figure for planted bugs that AI reviewers miss is a claim I haven't checked. If it matters to the new map, it belongs in that map's research, not in my answer.