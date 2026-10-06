Q2, Q3 and Q5 are settled, and I'm writing up round two now. On the record-keeping:

- **Your budget rule (Q5)** was already in my memory, word for word as you set it: in `safe`, budget is only measured afterward; in `eco` and Let It Rip, you're asked how binding a budget is before any brief carries it; and when in doubt, leave it out.
- **The note on terms that carry many details at once** is now a memory too. It's marked as something to test, and that test belongs to the map's ticket on measuring the writing.
- **Your round-one answers, word for word,** are drafted as a comment for this ticket in [round1.md](/private/tmp/qr-20d23a95/claude-501/-private-tmp-qt-replay-f1-turn-repo/83b918f9-09e1-4744-abe4-d4f07b8ac4f1/scratchpad/round1.md). The command to post it was declined, so it isn't on GitHub. Say if you want it posted.

---

## Q1 again, more slowly

Every rule in a brief gets two checks:

1. **Is it about the what, or the how?** The what is what you want, what done looks like, or whose decision something is. The how is the way the reader goes about it.
2. **Did the person whose decision it is actually say it must hold?**

A rule binds only if it's about the what and its owner said so. Anything else the writer knows can still go in, as information with its reason, and the reader may find a better way.

Your token-budget story is the clearest example. "This change might halve token burn" was a guess from one case. The agent turned it into "done means token burn is halved". That made it look like a what, so it passes check 1. It fails check 2, because you never said it must hold. Under (c) it could only have gone in as information: "one case suggested it might halve; that's a guess." Then the agent would have had no reason to cut steps to hit a number.

❓ **Q6 - Do these verdicts match what you'd say?**

| # | Rule | My verdict | Why |
|---|---|---|---|
| 1 | Never push to `main` | Binds | Merging is your decision, and you said so |
| 2 | The orchestrator never writes the code (the delegation rule) | Binds | It says whose job writing is, and you decided it, with evidence |
| 3 | The trail review is mandatory ([ticket.md:26](template/.agents/skills/poteto-mode/playbooks/ticket.md:26)) | Binds, but it's the borderline case | It's a how. You made it part of what done means: a ticket isn't done until someone else has checked the record of its decisions. You did that on evidence, after it caught the owner's mistakes 3 times out of 3 |
| 4 | "Token burn halved" as a done-condition | Doesn't bind | A guess that you never made binding |
| 5 | A reviewer reads only the diff | Doesn't bind | A how, added by an agent for cost. Becomes: "the change is in these files; the whole repo is there to read" |
| 6 | Never read more than 150 lines in one call (the `knowledge` skill) | Doesn't bind | A how, with no owner or reason on record |
| 7 | "Cite a `spec:` line or it isn't a hard bug" (the review brief script) | Neither: it moves | It looks like a definition of done, but it's a bar on what gets reported. Under your Q3 answer it moves to the separate filter step |

➡️ These are my verdicts. Mark any you disagree with. I'm least sure of case 3. My reading is that you can turn a how into part of what done means, but only you can.

---

## Your worry under Q3

You asked whether the evidence says both kinds of bug get found. The answer is partly:

- **A bar changes what gets reported, not what gets found.** Under (a), bugs the reviewer noticed and rated as minor still reach the verifier. That part of your worry is covered.
- **Focus is the other part, and your worry there is real.** If the reviewer's attention drifts to unsupported-input edge cases, it may never notice the kind you want. What a reader is focused on decides what it sees. The gorilla study showed this in people, and Shin's 2026 preprint showed it in models. It's true whether the reader picks the focus itself or we hand it one.
- **So a "we're especially wary of X" line is also a focus.** The evidence predicts it trades other kinds of bug for X. Your sense that it brings headaches matches that.
- **What recovered the missed findings in Shin's study was a second reader with an open brief, not a better single brief.** Models also tend to land on the same answers: different models' answers to open questions were 71–82% similar. Two lanes with the same brief will mostly see the same things.

So covering every kind of bug is a job for several passes from different angles plus one open pass. That's the review system you described, not a line in one brief. For this ticket, (a) stands with no push.

---

❓ **Q4 again - what happens when the reader departs from the route, or when a binding rule fights the goal?** These are the five mechanisms the factory has now:

1. **Say so loudly and get a sign-off before breaking it** ([AGENTS.md:26](AGENTS.md:26), [template/AGENTS.md:20](template/AGENTS.md:20), taken from Theo). A subagent has nobody to sign off. It also pulls against "never block on the human".
2. **Follow the file, then tell me why your instinct differed** ([template/AGENTS.md:16](template/AGENTS.md:16)). This is the opposite default: obey first and explain afterward.
3. **Where the spec is silent, decide and record a Provisional decision Manuel can overrule** (PHILOSOPHY, DECISIONS, [ticket.md:30](template/.agents/skills/poteto-mode/playbooks/ticket.md:30)). This covers gaps, not conflicts.
4. **A skipped step stays in the list with `skip: <reason>`** (poteto-mode, from upstream). [feature.md:12](template/.agents/skills/poteto-mode/playbooks/feature.md:12) forbids it for delegation.
5. **Hand the problem back.** Each writer flag has to end in `fixed:` or `accepted: <reason>`, and the review script refuses until it does. A writer that can't build a cell as written stops and reports it. A design hole amends the ticket. Bad acceptance criteria go back to you.

The proposed rule:
- When the reader takes a different route from the one the brief suggested, its report says where and why.
- When a binding rule stops it from reaching the goal, it stops that part, tells the rule's owner, and does the rest.
- It never shrinks the goal to fit a rule.

The options:
- (a) The proposed rule replaces all five.
- (b) The proposed rule replaces 1 and 2, which contradict each other and each other's tone. Mechanisms 3 and 5 stay, since each is already this rule applied to one situation. Mechanism 4 is upstream's, and changing it would take a patch.

➡️ (b). On a closer look, 3 and 5 work and already have the shape of the new rule.

---

❓ **Q7 - Where does "a review system of our own" go?** Your Q3 note describes more than writing: several passes, verifiers, measuring recall and not only false positives, and `interrogate`'s vendored script, which also leads the witness. The options:
- (a) Fog on this map.
- (b) Its own map.
- (c) A split. This map decides how review briefs are written, and a separate map designs the review system and uses this map's writing standard.

➡️ (c). This map gets one Out of scope line pointing at the future map. That map is charted after "Decide what the writing standard is and what carries it" settles, so the review system is the first thing built on the standard.