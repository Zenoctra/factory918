Your answers are recorded, and I'll post them word for word on the ticket when it closes. Q2 and Q5 are settled as you wrote them. Q1 needs another pass, because my last version contradicted itself. Q3 is settled, but part of your worry is still open. Q4 now lists the five mechanisms.

**On Q2, your point about one term doing the work of many.** The research supports a version of it. A micro-genre term works because the model already shares its meaning from training. The factory's own words ("lane", "eco", "P109") work the other way: they were coined in a context the reader never saw. In the research, two pairs of people picked the same term for a thing only about 10% of the time (§7). So the standard should prefer widely known terms that carry the whole bundle, define any term the factory coined, and add only what the term doesn't already imply. How many rules a reader can follow, and whether one term reliably pulls in several rules, are experiments. When this ticket closes, I'll post your words on "Decide what the writing standard is and what carries it" and on "Decide how we'll know the writing works".

**On Q3, your worry is partly right, and choosing (a) doesn't fix it.** The research describes two separate effects:
- **A bar** ("only report serious bugs") makes the reviewer find the bug and then not report it. Reporting everything and filtering afterward fixes this.
- **A focus** ("look for X") makes the reviewer not see Y at all. That's the gorilla study, and Shin's preprint shows it in models. A reviewer with no focus written into its brief still has its own default focus, and models tend to converge on the same one (§2).

So a "slight push" toward a bug type would add a focus. What recovered the missed findings in Shin's study wasn't a push. It was a second, independent reviewer with an open-ended brief. How many passes to run, and which kinds, is part of the review system you described. Q8 below asks where that work goes.

---

❓ **Q1 (again, concretely) - When does a rule bind?** Two plain rules:

1. **Only the person who owns a decision can make a rule about it binding.** You own merging, budgets, the playbooks and the factory's rules. The ticket's author owns its scope. An orchestrator writing a brief owns almost nothing. It can pass your binding rules down, but it can't make up new ones.
2. **Rules about what the job is bind by default. Rules about how to do it don't bind unless the owner bound them on purpose.** Even then the owner gives the reason, so the reader can see when the rule stops fitting.

Here's how that sorts five real cases:

| Rule | Who wrote it | About what or how? | Binds? |
|---|---|---|---|
| "Don't merge" | You | What: merging isn't the lane's call | Yes |
| "The orchestrator never writes the code" | You, with evidence | How, bound on purpose | Yes |
| "Cut token burn in half or the ticket isn't done" (your story) | An agent, from a prediction | What, but not the agent's to set | No. It should have asked you, or written it as information |
| "Read only the diff" | An orchestrator, to save cost | How | No. It becomes information: "the diff is here; it touches X" |
| "File nothing as hard without a `spec:` line" | A lane, in a script | How the work is finished | No. By your Q3 answer, it becomes a field the filter step ranks on |

My last message presented "about what" and "who owns it" as two tests that both had to pass. The delegation rule fails the first test, yet I said it binds. The version above fixes that: ownership decides, and "what versus how" decides only the default.

➡️ This version. If a case in the table looks wrong to you, that's the thing to tell me.

---

❓ **Q4 - Replacing the five ways the factory handles a rule that doesn't fit.** Today there are five:

| # | What it says | Where | What the reader does |
|---|---|---|---|
| 1 | "If one fights the task in front of you, say so loudly and get a sign-off before breaking it." | Your note in [template/AGENTS.md:20](template/AGENTS.md:20); [AGENTS.md:26](AGENTS.md:26) | Stops and asks first. A subagent has nobody to ask, and this pulls against your "never block on the human" two lines earlier. |
| 2 | "When this file and a vendored skill disagree with your instinct, follow the file and tell me why your instinct differed." | Your note, [template/AGENTS.md:16](template/AGENTS.md:16) | Obeys first, then explains. |
| 3 | Where the spec is silent, decide and record a Provisional decision you can overrule. | PHILOSOPHY, DECISIONS, [ticket.md:30](template/.agents/skills/poteto-mode/playbooks/ticket.md:30) | Decides and records it. |
| 4 | A playbook step you choose not to do stays in the list as `skip: <reason>`. Delegation is the exception: "no skip-with-reason escape". | Upstream poteto-mode [SKILL.md:113](template/.agents/skills/poteto-mode/SKILL.md:113); [feature.md:12](template/.agents/skills/poteto-mode/playbooks/feature.md:12) | Skips openly. |
| 5 | Hands the problem back to the work itself. A writer's flag must end `fixed:` or `accepted: <reason>`, or the review script refuses to run. A writer that can't build a test cell as written stops and reports it. A gap in the design gets a dated line on the ticket. | spec-review, feature.md, ticket.md | Stops that piece. Structure catches it. |

My proposal:
- **Advice about how** (not binding): the reader uses its judgment. Its report always has a line saying where it took a different route and why, or that it took none. This replaces 4 for advice.
- **A binding rule that fights the goal:** the reader stops that part, reports the conflict to the rule's owner, and carries on with the rest. This replaces 1. Number 5 already works this way for specific cases, so it stays.
- Number 3 stays. It covers a gap in the spec, not a conflict with a rule.
- The goal never shrinks to fit a rule.

➡️ This proposal. Number 2 is your own note, so it gets its own question.

---

❓ **Q6 - Does "follow the file, then tell me why your instinct differed" still stand?** You wrote this note to learn by copying professional patterns. On 2026-09-24 you also ruled that "upstream pStack's constraints stay; it is Factory918-written text (all model-written) that is suspect until proven." Those two pull apart for rules about how to work:
- (a) The note stands as written. Every route the factory's files describe beats the agent's instinct, and the agent reports the difference.
- (b) It stands for patterns copied from proven upstreams (Matt, pstack, Theo). Route advice that Factory918 wrote itself is information under Q2, until a result proves it.
- (c) Retire it. All route advice is information.

➡️ (b). It keeps what you wanted from the note, copying people who've seen the pattern work, and it matches your 09-24 ruling.

---

❓ **Q7 - Restating your Q5 answer for the record.** Correct anything that's off:
- In `safe`, a budget never shapes the process. Budget numbers are only measured afterward, to look for ways to optimize.
- In `eco` and Let It Rip, a budget enters only after you set one. Before any brief carries it, you get asked how binding it is. Let It Rip adds wall-clock time as a second budget under the same rule.
- When in doubt, don't tell the reader about the budget. If it seems important and nobody can stop to ask you, it goes in as information. It goes in as binding only with your approval.
- An overall goal you set, like Let It Rip being fast, doesn't override the processes you've required.

➡️ Confirm or correct.

---

❓ **Q8 - Where does building your own review system go?** The scope you described is several passes, better briefs, more than bugs (interrogate's wider range, security), not inheriting interrogate's leading, and measuring recall instead of celebrating zero false positives. No existing ticket covers it. "Choose each tier's review round count from the clean measurement" and "Eval the judge and trail-review models the way #103 evals reviewers" are pieces of it. The options:
- (a) Its own map, opened later, under this map's Out of scope with a link and your words.
- (b) Fog on this map.
- (c) Folded into "Decide the scope and order of reworking existing files".

➡️ (a). This map's destination is how the factory writes. A review system is a process design that uses those decisions without being one of them. Putting it under Out of scope with your words means it isn't lost while it waits.