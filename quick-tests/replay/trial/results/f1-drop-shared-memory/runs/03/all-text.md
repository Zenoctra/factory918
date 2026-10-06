Your answers to this round aren't saved anywhere yet, and you've asked for your words on this subject to be kept. I'm posting them to the ticket word for word.

---

The post was blocked, so I'll save the text locally instead and leave posting to you.

---

Your answers to round one are saved. The ticket post was blocked, so the text is in [152-round1-answers.md](/private/tmp/qr-dd099167/claude-501/-private-tmp-qt-replay-f1-drop-repo/2e49b3e4-4297-45a5-ac23-440006a5a19f/scratchpad/152-round1-answers.md) in my scratch folder, which won't outlast this session. Should I post it to the ticket, or will you?

**Settled in round one:**
- **Q2 (b):** what the writer knows about the route goes in as a resource with its reason. I'll pin your related-terms idea to the map as an experiment for "Decide how we'll know the writing works" and "Decide what the writing standard is and what carries it". The idea is that one precise term may carry a whole cluster of rules, and the experiment finds which rules still need saying on top. The research measured how fast instructions stop being followed as they pile up (68% of 500). It didn't study this.
- **Q5, in my words; correct me if I got it wrong:**
  - In `safe`, a budget never shapes how work is done. It is only measured afterwards.
  - In `eco` and Let It Rip, a token budget, and in Let It Rip also a wall-clock budget, reaches a reader only after you've been asked how binding it is.
  - When in doubt, leave it out. If it seems important and nobody can ask you, it goes in as information. It goes in as binding only with your approval.
  - A predicted saving is never a requirement.

  This also belongs on the map "Design Let It Rip as the third mode", so I'll link it from there.
- **Q3 (a), with one correction before you lock it in.** The research found two separate effects:
  - **A bar** ("only report high severity") makes the reader leave out things it found. Moving the bar to a later step fixes that. That is what (a) does.
  - **A focus** ("look for X") changes what the reader sees at all. Observers counting passes missed the gorilla. A verifier afterward can't rate a bug nobody saw.

  Your worry, that a reviewer drifts into edge cases and reads past the bugs you care about, is the focus effect, and (a) doesn't fix it. A "slight push" doesn't fix it either, because the push is itself a focus. It helps the bug type you named and hides the others. Q3 below picks this up.

---

❓ **Q1 - Is this what you chose in (c)?** Here it is in plain terms. A writer can make a rule a must only if the thing it governs is the writer's to decide. Everything else it writes is advice with a reason, and the reader may take another route and say so. Who decides what:

- **You decide** the goal, what done means, merging, and the factory's process rules.
- **An orchestrator writing a brief decides** the coordination it runs: which subagent is in which files right now, and where results go.
- **The reader decides** how it does the job, unless one of the two above has decided otherwise.

Some cases, to make it concrete. They aren't the whole set:

| Rule | Whose call | Under (c) |
|---|---|---|
| "Never push to main" | Yours: merging is your decision | Binds |
| "The orchestrator never writes the code itself" | Yours: it's about the route, but you set it, with evidence | Binds |
| "Don't edit files the other subagent is working in" | The orchestrator's: it runs the coordination | Binds |
| "Read only the diff" | The reviewer's own route: the orchestrator was guessing | Advice with a reason, or cut |
| "Cite a spec line or it isn't a bug" | A bar on finishing | Moves to the filter step (round one, Q3) |
| "Under 400 words" | Nobody set it as a budget | Cut; budgets follow your Q5 answer |

The delegation row shows the test is really about **whose call it is**. A rule's subject only tells you whose call it is by default: the route defaults to the reader.

➡️ Yes, this is (c). If any row surprises you, that row is where we need to slow down.

---

❓ **Q2 - The five ways the factory handles a reader departing from a rule.** Today:

1. **Ask first.** Both `AGENTS.md` files: if a rule fights the task, "say so loudly and get a sign-off before breaking it." That works when you're in the conversation. A subagent has nobody to ask, and the rule pulls against "never block on the human".
2. **Obey first, explain after.** [template/AGENTS.md:16](template/AGENTS.md:16), in your voice: "follow the file and tell me why your instinct differed."
3. **Decide and record.** Where the spec is silent, the agent decides and writes a Provisional entry in `DECISIONS.md` that you can overrule.
4. **Skip visibly.** pstack's poteto-mode: a playbook step you choose not to do stays on the list as `skip: <reason>`. Delegation is the exception, with "no skip-with-reason escape".
5. **Stop and hand back.** A writer that can't implement a test cell as written stops and reports it. Every writer flag and risk must end `fixed: <sha>` or `accepted: <reason>` before review opens.

Numbers 1, 2 and 4 conflict: ask before departing, comply and explain, and depart and log. Nothing tells a reader which one applies. My proposal:

- **Advice about the route:** the reader may depart. Its report says where and why, or says it took none. This generalizes 4.
- **A binding rule that fights the goal:** in your conversation, 1 (ask). In a subagent, 5 generalized: stop that part, report to whoever owns the rule, carry on with the rest. The reader never shrinks the goal to fit the rule.
- **3 stays.** It covers a gap in the spec, not a conflict with a rule.
- **2 goes**, but only if you say so, because it's your note in the template. Under (c) the file's binding rules bind anyway, and the rest is advice. Its "tell me why" part survives as the report line.

➡️ The proposal as written, with 2 removed.

---

❓ **Q3 - How does a bug type you specifically care about get found?** A focus helps what it names and hides what it doesn't. In the gorilla study, observers counting the black team's passes noticed the black gorilla more than twice as often as those counting the white team's. In the 2026 model preprint, a narrow task hid findings, and a second reviewer with an open brief recovered all of them. The options:

- (a) Every review has one open-ended pass. When someone wants a type looked for (security, say), that type gets its own pass with its own brief. The open pass's brief gets no push.
- (b) A light push inside the single brief.
- (c) Leave it to whatever designs the review system (Q4).

➡️ (a) as the writing rule: a push goes in its own pass, never into the open one. How many passes, and which, belongs to Q4.

---

❓ **Q4 - Where does designing a review system of your own live?** Your points: spec-review mostly hunts bugs, interrogate looks more widely but also leads, and published studies celebrate zero false positives while missing half the planted bugs. All of that goes past writing into process: how many passes, what verifies them, and how recall is measured. A few open tickets touch review, such as the round count per tier and evaluating the judge models. None of them designs the system. The options:

- (a) Fog on this map.
- (b) Its own map, which takes this map's decisions as inputs.
- (c) Part of the map "Optimize token use and wall-clock time without losing reliability".

➡️ (b). This map keeps the writing of review briefs: the templates prototype and the rework of existing files. The new map owns the system, and its first question is recall, which is the measure the research says reviewers should be judged on. Here it gets an Out of scope line pointing to the new map. I'd chart that map in its own session.

---

Round three covers how binding rules are worded and enforced: plain, with the reason, no emphasis, and what a hook's refusal message does that a brief's restatement can't.