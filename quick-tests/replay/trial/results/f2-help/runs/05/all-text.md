The search is back. Before I tell you any of its "conflicts" are real, I'm reading each departure mechanism where it's written.

---

The background search finished. I checked its claims against the source before using them, and two of my round-one recommendations change as a result.

## What the search found

**The run-2 audits sorted rules by the framing you've rejected.** The constraints audit split them into "what the subagent may look at, run, or produce", which it cut, and "safety and report format", which it kept. That is the "protect the world or shape the search" test.
- Its own late addendum admits the split missed a rule about how the work is finished. Reviewers had to cite a `spec:` line from a ticket the brief never showed them. In the PR 99 review, Sol obeyed this and filed nothing, though that PR had four hard bugs.
- Most of what the audits recommended hasn't been applied yet. For example, the pstack wrapper still says "Execute only the task and path scope the parent assigns." That's work for "Decide the scope and order of reworking existing files", not this ticket.

**Rules about how the work is done have also helped.**
- The mandatory trail review caught the subagent's mistakes in 3 of 3 runs.
- The delegation rule needed a hook because an agent broke it knowingly.
- Narrow grounding that skipped `architect` let a bug survive four review rounds.

**What good rules have in common is a stated reason, often a measured one.** The research written for "Research how wording and missing context shape a reader's response" points the same way. Anthropic's guidance says models generalize from the reason behind an instruction. The research also adds two counterweights:
- Spelling out the steps helps on simple tasks and with novice readers.
- Holding back what the writer *volunteers* (for example, its own conclusion about a diff) protects a reader's independence. That's different from limiting what the reader may *seek*.

## The "five conflicting mechanisms" don't conflict

The search reported five ways a reader may depart from a rule, pointing different directions. Read where they're written, each covers a different situation:

| Situation | What the text says | Where |
|---|---|---|
| The file disagrees with your instinct about a pattern | Follow the file, tell Manuel why your instinct differed | [template/AGENTS.md:16](template/AGENTS.md:16) |
| A rule fights the task itself | Say so loudly, get a sign-off first | [template/AGENTS.md:20](template/AGENTS.md:20), [AGENTS.md:26](AGENTS.md:26) |
| A playbook step isn't needed | Keep it in the list with `skip: <reason>` | [poteto-mode/SKILL.md:113](template/.agents/skills/poteto-mode/SKILL.md:113) |
| A step the playbook's author says can't be skipped | "Mandatory: no skip-with-reason escape", with the reason | [feature.md:12](template/.agents/skills/poteto-mode/playbooks/feature.md:12) |
| The spec doesn't say | Decide, record it under Provisional so you can overrule it | [PHILOSOPHY.md:47-55](docs/knowledge/core/PHILOSOPHY.md:47) |
| A subagent can't carry out a test-table cell as written | Stop, report the cell, never improvise | [feature.md:12](template/.agents/skills/poteto-mode/playbooks/feature.md:12) |
| A reversible action | Proceed without asking | [template/AGENTS.md:18](template/AGENTS.md:18) |

They agree on one thing: **a departure is always visible, never silent.** The real gap is narrower. Only the test-table case covers a subagent whose brief contains a rule that fights its goal. Every other subagent brief is silent on what to do.

## Revised Q1, Q2 and Q3

❓ **Q1 (revised) - What makes a rule binding?** My first recommendation was that anything you own is binding. That's too broad. Every playbook step you've adopted would become binding, and the template already calls your rules "good defaults, not hard rules". It would close exactly the door you said to keep open.

pstack already has a better shape: steps are defaults, a default may be skipped visibly with a reason, and the few that can't be skipped are marked as such, with the reason written beside them. Proposed test:
- **The task itself is binding:** what's wanted, what done means, and what belongs to someone else's authority (you merge, another subagent owns a file).
- **The route is a default:** what to read, run or try, in what order, and when to stop. The reader may depart from a default, visibly and with a reason.
- **A route rule becomes binding only if its owner marks it that way and writes the reason beside it.** The delegation rule is the model.

➡️ This version, replacing the one I gave before.

❓ **Q2 (refined) - How should the writing carry knowledge about the route?** My recommendation stands: state it as something the writer knows, with the reason, and only when the reader couldn't easily find it. The research adds two things:
- On a simple task, or for a weaker reader, more spelled-out steps can help.
- Keep "what I'm telling you" separate from "what you may look for". The writer holding back its own conclusions is good restraint. Limiting what the reader may look for is not.

➡️ Unchanged, with those two notes carried into the standard.

❓ **Q3 (sharpened) - What does a subagent do when a binding rule fights its goal?**

➡️ Unchanged: stop that part, report the conflict to whoever owns the rule, carry on with the rest. It's the test-table rule extended to every brief, and the subagent version of the sign-off line.

Q4 and Q5 stand as I asked them.

One unrelated thing I noticed: [MANUAL.md:168](docs/knowledge/core/MANUAL.md:168) still says "twelve ordered beliefs", but PHILOSOPHY has had eleven since the cost belief was removed. I can file a quick ticket for it.