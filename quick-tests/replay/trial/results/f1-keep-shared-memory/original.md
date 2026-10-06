# Original moment 99996a3c-57a3-41cd-86b4-072bf615d181 (2026-09-30T21:37:17.451Z)

## Text

I've saved your answers word for word in the session scratchpad, and they'll go on the ticket with its resolution. Q2 and Q3 are settled. Q1 and Q5 each need one check, Q4 needs the list you asked for, and three questions are new.

---

**Your Q2 note on terms that pull many rules at once.** I'm keeping it for every decision after this one. It has a flip side the experiment should measure. A micro-genre term works because it brings a whole bundle of norms, and that includes norms you didn't pick. "Code review" pulls in "find bugs, rate severity, skip nitpicks", which brings back the reporting bar Q3 just removed. So the test is:

- what a term brings that you want;
- what it brings that you don't;
- which rules still need their own sentence.

That belongs to the ticket "Decide how we'll know the writing works". I'll link your words there when I close this one.

---

❓ **Q1 check - does this match what you meant by (c)?** My last version contradicted itself. It said a rule needs both tests, then said the delegation rule binds only because you set it. Here is the version that holds together. For each rule in a brief, ask:

1. **Did you make it binding?** You can do that directly, or through a file or ticket you approved. If so, it binds, whatever it's about.
2. **If an agent wrote it**, is it about the task itself, and is it something that agent owns? The task itself means what's wanted, what done means, and what the reader may change. If both hold, it binds. If it's about the route, it can't bind. It becomes knowledge with a reason, or it goes.

So only you can make a rule about the route binding. Here are some real rules run through that test:

| Rule | Who set it | About | Result |
|---|---|---|---|
| Never push to main | You | Who decides what lands | Binds |
| The orchestrator never writes the code itself | You, after an agent knowingly broke it | The route | Binds, because you set it |
| "Read nothing beyond this brief. Run nothing." (a review brief, removed in #137) | An agent, to save cost | The route | Never binds. At most it becomes "the change is in these files" as a place to start |
| Only change files in your own worktree, because other subagents are changing the rest | The orchestrator, which owns how the work is split | What the reader may change | Binds |
| `knowledge`: never read more than 150 lines in one call | No reason recorded | The route | Doesn't bind: find the reason and state it as knowledge, or cut it |
| The `spec:` gate: no bug without a ticket line to cite | Written into a script | How the task is finished | Q3: becomes a filter step after the reviewer reports |

➡️ Yes, if these results feel right to you. If any row feels wrong, that row is where the test is still off.

---

❓ **Q4 again - the five mechanisms that exist today:**

1. **"Say so loudly and get a sign-off before breaking it"** ([AGENTS.md:26](AGENTS.md:26), [template/AGENTS.md:20](template/AGENTS.md:20)). It came from Theo's file. A subagent has nobody to sign off. It also pulls against "never block on the human for reversible work", which is in the same file.
2. **"Follow the file, then tell me why your instinct differed"** ([template/AGENTS.md:16](template/AGENTS.md:16)). This is the opposite default: obey first, explain afterward.
3. **"Decide, and record it as Provisional so Manuel can overrule it."** This is for when the spec says nothing, for example a name the ticket never specified.
4. **"Skip a step visibly: `skip: <reason>`."** This comes from pstack's poteto-mode. It is switched off for delegation.
5. **Send the conflict back through the work itself.**
   - A writer's flags must end `fixed:` or `accepted: <reason>`, or the review script refuses to run.
   - A writer that can't implement a test cell as written stops and reports that cell.
   - A design hole gets a dated line on the ticket.

They disagree on three things: stopping or carrying on, asking first or explaining afterward, and whether a subagent can use them at all.

➡️ My proposal, mapped onto those five:
- **Route knowledge**, which after Q2 never binds: the reader uses its own judgment. Its report always says where it took a different route and why, or that it didn't. This replaces 2 and 4.
- **A binding rule that fights the goal:** the reader stops that part, reports it to whoever owns the rule, and carries on with the rest. This is 1, made to work for subagents, with 5 as the ways it already happens.
- **3 stays as it is.** When the spec is silent, there's no rule and no conflict.
- **In every case, the goal is never shrunk to fit a rule.**

---

❓ **Q5 check - is this your rule?**
- **In `safe`:** a budget never shapes the work. It is measured afterward, to look for savings.
- **In `eco` and Let It Rip:** a budget enters the writing only after you set one. Let It Rip adds wall-clock time as a second budget. Before a budget is written as binding, the agent asks you how much it should weigh against your other goals, including processes you've required.
- **By default, the budget isn't mentioned.** If the writer thinks it matters but can't ask, it's written as information, not as a limit. It binds only with your approval.
- **A predicted saving is never a condition for closing a ticket.**

➡️ Confirm, or correct any part.

---

❓ **Q6 - When one kind of bug matters especially, how should the review pursue it?** You worried that a reviewer might fixate on edge-case input bugs and miss the kind you want. The evidence answers that in two parts:
- **A bar changes what gets reported.** So Q3's report-everything, then filter, gets back what the reviewer found but didn't report.
- **Telling the reader what to look for changes what it finds.** That's the gorilla finding, and Shin's preprint shows it in models. So your "slight push" would help the kind you name and quietly cost the others.

Your worry in the other direction is real too. Models already give 71–82% similar answers to open questions, so a reviewer drifting to its habitual kind of bug is its own pull.

The options:
- (a) One open pass that reports everything. Where a kind of bug matters especially, add a separate pass whose goal is that kind. A verifier then sorts and rates all of it.
- (b) A push toward the kind in the single brief.
- (c) The open pass only, sorted afterward.

➡️ (a). It's the pattern in Shin's study, where a second open-ended reviewer recovered what the narrow one hid. How many passes to run, and for which kinds, is a question about the review system, which is Q7.

---

❓ **Q7 - Where does designing the review system as a whole belong?** No map or ticket covers it. What exists:
- per-change review tickets;
- "Choose each tier's review round count from the clean measurement";
- "Eval the judge and trail-review models the way #103 evals reviewers".

This map covers how review briefs are written, through the templates prototype and the rework of existing files, which starts with the adversarial briefs.

Your points about it go beyond wording:
- spec-review looks mostly for bugs, while interrogate looks wider;
- the vendored interrogate script leads the witness too;
- studies celebrate zero false positives while missing half the planted bugs.

That last point is recall, which the research names as the measure for reviewers.

The options:
- (a) A new wayfinder map, "Design the factory's review system", seeded with your words, taking this map's decisions as inputs.
- (b) Fog on this map.
- (c) A ticket on this map.

➡️ (a). Passes, verifiers and measuring recall against planted bugs are process, not writing. This map's destination would bloat, and the review system would be squeezed in. Charting it is its own session. I'd only record it here as the next map.

---

❓ **Q8 - How are binding rules worded, and where are they held?** "Never push to main" is written in prose in several places, and a hook also enforces it. The research gives three findings:
- Current Claude over-applies emphatic wording.
- A bare "never" keeps the forbidden act in mind without saying what to do instead.
- A reminder at the moment of use worked where a standing instruction didn't.

The options:
- (a) A binding rule is written once, plainly, as what to do and why. For example: "changes reach main through a PR that Manuel merges, because merging is his call". Where a hook enforces the rule, the hook's refusal message carries the reason and the way forward, and briefs don't repeat it.
- (b) The rule is repeated in each brief as well, to be safe.
- (c) Prose only, no hooks.

➡️ (a). Exactly where the single statement lives is decided in "Decide where each piece lives and when it reaches the writer". This ticket decides only how it's worded and that it isn't repeated.

## Tool calls in the same response
