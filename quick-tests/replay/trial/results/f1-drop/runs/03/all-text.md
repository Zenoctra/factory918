Round two is below. First, some housekeeping:

- **Your answers aren't on the ticket yet.** I tried to post them word for word as a comment on the ticket, and the tool permission was denied. They're saved locally in my scratch folder for now. I'd still like them on the ticket. Tell me if I may post them, or I'll include them with the resolution.
- **Q5 is settled. Here's how I understood it, so you can correct me:**
  - **In `safe`, the first mode,** a budget never shapes how the work is done. It is only measured afterward, to look for savings.
  - **In `eco` and Let It Rip,** a budget exists only if you set one. Before it reaches any brief, someone asks you how much it should weigh against your other goals. In Let It Rip, wall-clock time works the same way.
  - **When in doubt, the budget isn't mentioned at all.** If it seems important and nobody can ask you, it goes in as information, not as a limit. It is a binding limit only if you approved it.
  - **A goal you set never becomes a pass condition.** Your story of "cut token burn in half" turning into a requirement for closing the ticket is the case to guard against.

---

❓ **Q1 again, in practice** - **Does this sorting match your instinct?** Here is (c) applied to five rules that exist in the factory today. They are cases to check the test against, not a set to fit future rules into.

| Rule today | About the task, or about how to do it? | Who set it | Under (c) |
|---|---|---|---|
| Never push to `main` | The task's limits: merging is yours | You | **Binding.** The hook holds it. |
| The session you talk to never writes code itself; a subagent does | How to do it | You, after it was broken knowingly ([ledger.md:16](docs/agents/ledger.md:16)) | **Binding**, because it's yours, even though it's about method |
| A review brief saying "read only the diff" | How to do it | An agent, to save tokens (#33) | **Not binding.** It becomes information: "here is the diff; it touches these modules." The reviewer reads whatever it decides it needs. |
| `knowledge`: "never read more than 150 lines in one call" ([SKILL.md:20](template/.agents/skills/knowledge/SKILL.md:20)) | How to do it | An agent, with no reason recorded | **Not binding.** It becomes a tip with its reason, if a reason can be found, or it goes. |
| Spec reviewer: "file a bug as hard only if it cites a ticket line" | How the task is finished | An agent | **Not binding.** It moves out of the reviewer's brief (your Q3): the reviewer reports everything, and the citation becomes something the later filtering step uses. |

The short version: an agent can hand down your rules, but it can't invent new ones about how another agent should work. Anything it knows about how to do the work, it passes on as advice with the reason attached.

➡️ If a row surprises you, that's where the test is wrong. I'd especially like your read on row two: whether a rule about method that you set should bind even when the agent finds a better way, or whether it should report that better way and still follow the rule (Q4 below).

---

❓ **Q4 again, with the five mechanisms** - **What does an agent do when a rule gets in the way?** Here is what the factory says today:

| # | Where | What it tells the agent | The trouble |
|---|---|---|---|
| 1 | Both `AGENTS.md` files ([AGENTS.md:26](AGENTS.md:26), [template/AGENTS.md:20](template/AGENTS.md:20)) | If a rule fights the task, say so loudly and get a sign-off before breaking it | A subagent has nobody to ask. It also pulls against "never block on the human." The template's copy says the rules are "good defaults, not hard rules", which makes everything bendable. |
| 2 | [template/AGENTS.md:16](template/AGENTS.md:16) | When the file disagrees with your instinct, follow the file and tell me why your instinct differed | The opposite default to #1: obey first, explain afterward |
| 3 | PHILOSOPHY, DECISIONS, the Ticket playbook | Where the spec is silent, decide and record the decision as Provisional so Manuel can overrule it | Fine, but it's about silence, not conflict |
| 4 | pstack's `poteto-mode` | Skip a step visibly, with `skip: <reason>`; never skip silently | Except for delegation, where [feature.md:12](template/.agents/skills/poteto-mode/playbooks/feature.md:12) forbids skipping. So whether a step can be skipped depends on which file you're in. |
| 5 | Review scripts, the Feature playbook | Each writer's flag must end `fixed` or `accepted: <reason>`. A writer that can't build something as specified stops and reports it, and never fills it in. A design hole amends the ticket. | These work, and they're about finishing, not about departing from a rule |

What I propose instead:

- **Advice about how to work (Q2):** the agent uses its own judgment. Its report always has a line saying where it took a different route and why, or saying it took none. This replaces #2 and #4 for advice.
- **A binding rule that gets in the way:** the agent stops that part and reports the conflict to whoever owns the rule. It carries on with everything else. In the session you're watching, that report is the "say so loudly" of #1, so #1 survives there. A subagent reports to the agent that briefed it, which brings it to you.
- **Unchanged:** #3 and #5, which cover different situations.
- **Never allowed:** quietly narrowing the goal so the rule fits.

➡️ Approve this, or tell me which current mechanism you want kept as it is. One more thing: #2's "follow the file and tell me why your instinct differed" is how you learn from agents. Under the proposal, that learning still happens through the departure line, but only for advice, not for binding rules.

---

❓ **Q6** - **Your "slight push" toward bug types we care about most.** The evidence says the push is risky even without a boundary:

- Unusual examples pull answers harder than typical ones, because readers think of the typical ones anyway.
- Naming some items from a list makes people recall fewer of the rest. That effect is robust: 109 samples.
- Shin's study found the fix was structural: a separate reviewer with an open brief recovered every finding the focused one had hidden.

The options:
- (a) No push in the open review brief. If a kind of bug matters enough, it gets its own reviewer with its own focus, and the open reviewer stays open.
- (b) A push worded as information ("we've been hurt by X before").
- (c) No push and no extra reviewer.

➡️ (a). It's also the shape your "multiple passes" point suggests, so the actual design belongs to Q7.

---

❓ **Q7** - **Where does "a review system of our own" go?** Its parts are multiple passes, recall measured against planted bugs, spec-review and `interrogate` reconsidered, and verifiers that rate what was found. That is bigger than this map's destination, which is about writing.

The options:
- (a) A new, sixth map, charted later. This map keeps the review brief templates (the existing ticket "Prototype brief templates for the recurring lane jobs"), and its Out of scope section points to the new map.
- (b) Fog on this map.
- (c) A ticket under the map "Optimize token use and wall-clock time without losing reliability".

➡️ (a). Review is the largest thing you named today, and on this map it would compete with the writing standard. I'd add a line to the map now and create the new map only when you say so.

---

❓ **Q8** - **Rule count, and words that pull many rules at once.** Your microgenre point is a hypothesis the research doesn't cover. The nearest results are two:

- At 500 simultaneous instructions, the best model followed 68%.
- Assigning a persona ("you are a senior reviewer") added no accuracy.

The second is a reason to test your idea, not to doubt it. A microgenre term carries hundreds of specifics, while a persona carries a vague stance. The experiment would be:
- the same task, with N explicit rules against one dense term plus only the rules that term wouldn't carry;
- measure how many of the rules are followed;
- check whether any rule still needs stating on its own.

➡️ It goes as an experiment into the existing ticket "Decide how we'll know the writing works", with your words quoted. It also goes as a standing consideration into "Decide what the writing standard is and what carries it". Neither ticket is open yet, so this changes no decision here.

---

❓ **Q9** - **How are the rules that do bind worded and enforced?** The research points to four things:

- Current Claude over-applies emphatic wording ("CRITICAL", "MUST").
- A prohibition keeps the forbidden idea active and doesn't say what to do instead.
- Text repeated in every brief gets read past.
- A reminder at the moment of use worked where a general instruction didn't.

The options:
- (a) Each binding rule is written once, in plain words, with its reason and the way forward. Where a hook can hold it, the hook's refusal message carries the reason and the way forward at the moment the agent hits it, much as the git guard does today ("Use --force-with-lease on your own branch, or ask"). Briefs point to the rule instead of restating it.
- (b) Binding rules are restated in every brief that might touch them.
- (c) Both.

➡️ (a). Where each rule lives is the map's ticket "Decide where each piece lives and when it reaches the writer". This ticket only settles how a binding rule is worded and that it carries its reason and a way forward.