# Original turn fedfffbd-556a-49d5-98f1-7f21d41e8d5e (2026-09-30T21:35:26.702Z)

## Prompt

Q1: (c) Ill be honest, this got a little abstract for me to track. But as much as I could, C seems like a good answer, but if I need a more intuitive understanding of what that looks like in practice to answer future questions, we are gonna have to slow down and explain it to me again in a different way.
Q2: (b) Also, on the 3rd note you mentioned about the number of rules increasing leading to fewer and fewer being followed as focus is split. This is a pretty big detail that I already knew but it's worth pinning for keeping in mind with all decisions as well as maybe future planning, but some things that help include heavy co-related terms. For example, when prompting a music generation AI for a song style, many people are addicted to things like listing guitar style and BPM and music theory desires and things of that nature, however, after having generated thousands of songs myself, I have found that one really accurate micro genre term where songs in that microgenre already carry 90% of the details you want on average does 10 times more for significantly less tokens of style details to focus on and then you can add other nuances to get the last 10% by making sure you ONLY discuss what would almost never show up in that micro genre or is at least not a genre specific norm. The same thing can happen for rules. There may be key words that overwhelmingly co-pull the model weights to alot of the other same terms on the subject and that can reduce the amount of literal rules having to get applied. BUT we would want to experiment on it. Like seeing how many rules can be followed, and if a term co-pulls to multiple rules, are there some anyways that a worth giving an extra push but adding them specifically? These things are all worth thinking about and dont in any way negate choosing (b) here, but bears on all decisions that rely on this kind of theory.
Q3: I definitely agree with with (a)... I worry a littel bit that a model might focus on a wrong type of bug and then read right past the type that we WANT to find because its focused on unhappy path unsupported iput edgecases, but if you are saying the evidence says both get found and then we let a review verifier look through and rate what kind of bugs each of them are seperately, then I suppose (a) is the best option. Otherwise, it would maybe be a SLIGHT psuh without a boundary in the brief to say we are especially wary of certain types of bugs. But I can honestly see a lot of headache that comes from that. Also, this is maybe unrelated, but seeing as we are gonna be working on our review process templates and what just general process stuff in general here a little later, its worth noting for later that right now the spec-reviewer is mostly sent looking for bugs, but interrogate has a much wider spectrum of things it is looking for which include but are not limited to security issues. BUT even the vendored Interrogate script somewhat leads the witness so Im thinking we are probably working towards a whole review system of our own either in a ticket we have already planned or in a new ticket that is coming later because review may well be the absolute most important step in AI Driven development and it also is one that I feel can use the most work and can get the most help from the stuff we are discussing now. AI Review studies all celebrate having no false positives, but then conveniently ignore that their system misses 50% of known planted bugs at the same time. This sounds like a need for multiple passes and better briefs and process and all the stuff we are talking about here. 
Q4: You didnt tell me what the 5 conflicting mechanisms WERE. So what you say makes sense, but I can't compare it to what currently exists to make an educated choice in affirming you.
Q5: Budget is a question that is answered differently based on mode. In Safety Mode (or whatever the first mode we made was called) there is no budget that should ever effect process. Budget is only ever used in the factory to measure what happened after the fact to go looking for ways to optimize. Budget in Eco Mode is a little more available to think about, but ONLY after a user sets a budget constraint and that budget constraint should be then clarified more as a point of principle so that before it gets written in a brief as a binding constraint, the user can clarify the severity of priority the budget should have on a process. Ive seen a model take a suggestion that a change might cut context token burn in half and then because the ticket was about a budget focused thing, it made the token burn getting cut in half a requirement of the ticket to close and then the change didnt have such a drastic affect and so it started rewritting all of its architecture and cutting required steps in order to force the token burn down. It made that requirement without asking me how important the token budget was. I would have told it it was a prediction from a single anecdotal case and not binding. So in Eco and Let It Rip mode, any budget constraints should be interviewed first to determine how important it is. And in Let It Rip mode, there is a second budget that ALSO becomes important which is Wall Clock. Let It Rip mode is being designed for the wall clock, BUT its the same as what I said about token budget in Eco Mode, just because im setting an overarching goal, doesnt mean a model needs to be told about it and doesnt mean that it overrides my other goals like setting specific processes that are required. So any time a token or wall clock budget is maybe getting communicated to a reader, it should be interviewed to see exactly how binding it is. There isnt a set heuristic, but we should fail open here. As in, when in doubt, DONT COMMUNICATE BUDGET. If you think it is super important but cant stop to ask, then it is information not boundary, and if its communicated as binding it must have been user approved.

## Tool calls

- Bash: {"command": "cd \"/Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918\" && grep -n -i -o '.\\{60\\}\\beco\\b.\\{60\\}' docs/knowledge/core/DECISIONS.md | head -5; grep -rn -i 'safe mode\\|safety mode\\|`safe`\\|mode.*safe' docs/knowledge/core/*.md template/.agents/skills/poteto-mode/playbooks/ticket.md | head -5; gh issue list --state open --search 'review in:title' --json numb
- Bash: {"command": "cat > \"/private/tmp/claude-501/-Users-manuel-Desktop-Work-Under-The-Sun-Collective-Core-918-factory918/c0c3530f-56c5-4eec-ae2f-949cebfc2e96/scratchpad/152-answers-round1.md\" <<'EOF'\nManuel's answers, #152 round 1 (research-informed version), 2026-09-30, verbatim:\n\nQ1: (c) Ill be honest, this got a little abstract for me to track. But as much as I could, C seems like a good answer

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
