I couldn't use GitHub just now, because the `gh` command was denied this session. Your answers are saved word for word in a scratch file, and I'll post them on the ticket once `gh` is allowed again. Two of your points also belong on the map, and I'll add them then:

- **A review system of the factory's own.** I'll add it to the map's "Not yet specified" section, with your words. These are your two observations: `interrogate` looks wider than spec-review but still leads the witness, and review studies boast no false positives while missing half of the planted bugs.
- **Your point about loaded terms (the "microgenre" idea).** I'll attach it to "Decide how we'll know the writing works" as an experiment, and to "Decide what the writing standard is and what carries it". One thing to test alongside it: a loaded term pulls the reader toward what's normal for that genre. That's what you want when the norm is right. It's a lead when you want the reader to find what you didn't expect.

On Q5, your budget rule is saved as a standing memory. The first mode is called `safe`.

On Q3, your worry is a different effect from the one that answer fixes:
- Reporting everything fixes withholding: the reviewer saw a bug and didn't report it because of a bar.
- Your worry is a reviewer looking hard at edge cases and reading past the bug you care about. That's the gorilla effect: what a reader is looking for decides what it sees.
- Reporting everything doesn't fix that. In the 2026 preprint, a second reviewer with an open brief did.
- So the cure is several passes with different, open briefs, not a nudge in one brief. A nudge toward "bug types we're wary of" is a list, the very thing we're avoiding.
- That puts it in the review-system work, not here. Your answer (a) stands.

Below, Q1 in concrete terms, then round two.

---

### Q1 in plain terms

Ask three questions of any rule in a brief or a skill:

1. **Is it about what's being made, or about how the reader goes about it?** Rules about what's being made bind: the goal, what counts as done, and what isn't the reader's call.
2. **If it's about how, did you set it on purpose?** Then it binds, because it's yours.
3. **Otherwise it's advice.** It gets a reason, and the reader may take another route if it says so in its report.

---

❓ **Q6 - Do these verdicts match yours?** These are real rules from the factory, sorted by the three questions. Mark any you'd sort differently.

| Rule | What it's about | Verdict |
|---|---|---|
| Never push to `main` ([AGENTS.md](AGENTS.md)) | What isn't the reader's call: merging is yours | **Binds** |
| The orchestrator never writes the code; it delegates | How, but you set it, and a hook holds it | **Binds** |
| The trail review is mandatory ([ticket.md:26](template/.agents/skills/poteto-mode/playbooks/ticket.md:26)) | How, but you set it, with evidence (3 of 3 catches) | **Binds** |
| "Read nothing beyond this brief. Run nothing." (old review brief) | How, written by a subagent to save cost; nobody asked for it | **Deleted.** The brief says where the diff is, not where the reader may not look |
| `knowledge`: never read more than 150 lines in one call | How, with no recorded reason and no owner | **Deleted**, or kept as advice if a reason turns up |
| Read the tier in two plain commands, because the worktree guard refuses `git` inside `$(...)` ([ticket.md:10](template/.agents/skills/poteto-mode/playbooks/ticket.md:10)) | How, with a real reason | **Advice.** The reader follows it because it's true |
| A reviewer's finding counts as hard only if it cites a `spec:` line | How the task is finished | **Moves to the filter step** (your Q3 answer). The reviewer reports everything |
| Subagents never launch their own dev servers ([template/AGENTS.md:68](template/AGENTS.md:68)) | Half about not fighting over shared ports, half about how. Theo's reason was dropped | **Your call.** Did you adopt it on purpose? |
| pstack: "Execute only the task and path scope the parent assigns" | The task scope is yours; "path scope" limits where the reader may look | **Split.** The task scope binds; the path limit goes |

➡️ I'd sort them as in the table. The dev-server rule is the one I can't decide for you.

---

❓ **Q7 - What replaces the five ways a reader currently handles a rule that gets in its way?** Here are the five, and what each tells a reader to do when a rule blocks its goal:

1. **"Say so loudly and get a sign-off before breaking it."** ([AGENTS.md:26](AGENTS.md:26), [template/AGENTS.md:20](template/AGENTS.md:20), copied from Theo.) *Stop and wait for you.* A subagent has nobody to ask, and this fights "never block on the human".
2. **"Follow the file, then tell me why your instinct differed."** ([template/AGENTS.md:16](template/AGENTS.md:16)) *Obey, and explain afterward.* This is the opposite default to 1.
3. **"Where the spec is silent, decide and record a Provisional decision Manuel can overrule."** *Decide yourself, and write it down.* This is about gaps, not conflicts.
4. **"Skip a step only with `skip: <reason>`, never silently."** (pstack's poteto-mode) *Skip it visibly.* [feature.md:12](template/.agents/skills/poteto-mode/playbooks/feature.md:12) bans this for delegation.
5. **"A writer that can't build something as written stops and reports it. Its flags end `fixed:` or `accepted: <reason>`."** *Stop that part and report it.*

Take the same moment: a subagent hits a rule that blocks its goal. Number 1 waits for nobody, 2 obeys, 4 skips, 5 stops and reports. That's four different behaviors.

➡️ Two cases, replacing 1, 2, 4 and 5:
- **Advice got in the way.** The reader takes the better route. Its report always has a line saying where it departed and why, or saying "none".
- **A binding rule fights the goal.** The reader stops that part, reports the conflict to whoever owns the rule, and finishes the rest. When the owner is you and you're in the room, "report" means saying so loudly and asking, so number 1 survives in its proper place.
- **In both cases the reader never quietly shrinks the goal** to fit a rule.
- **Number 3 stays as it is.** It answers a different situation, where the spec says nothing.

---

❓ **Q8 - How are binding rules worded, and how are they held?** The research says:
- Current Claude models over-apply rules written emphatically ("NEVER", "CRITICAL").
- A bare "don't" keeps the forbidden idea active and doesn't say what to do instead.
- A reminder that arrives at the moment it matters works far better than a general one stated up front.

The options:
- (a) Say each binding rule once, in plain words, with its reason and what to do instead. Hold it with a hook wherever one can be built. The hook's refusal message carries the reason and a way forward, at the moment the reader hits it. Briefs don't repeat rules a hook already holds.
- (b) Repeat binding rules in every brief, so the reader knows them before acting.
- (c) Use hooks only, with no prose.

➡️ (a). The git guard already works this way: its refusal says "use `--force-with-lease` on your own branch, or ask". Repeating hook-held rules in every brief adds to the rule count you pinned in Q2, and buys nothing the hook doesn't already give.