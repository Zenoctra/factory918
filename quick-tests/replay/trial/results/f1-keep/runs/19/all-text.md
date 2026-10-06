I tried to post your answers word for word as a comment on the ticket, so the two notes you asked to pin would be saved. That post was declined, so nothing went to GitHub. Your answers are saved word for word in a local scratch file, and I'll put them in the resolution comment unless you'd like them somewhere else.

## Settled from your answers

- **Q2, how route knowledge is written: (b).** What the writer knows about how to do the task goes in as information with its reason, never as an order. I've pinned your note on terms that pull many rules at once, the micro-genre point, as a hypothesis to test, not a rule to adopt yet. The test is to give two sets of lanes the same task, one with a list of rules and one with a single term that should carry them, and count which rules each set follows. It belongs to the tickets "Decide what the writing standard is and what carries it" and "Decide how we'll know the writing works".
- **Q5, budgets.** Here is your ruling as I understand it. Correct me if any of it is off.
  - In `safe`, a budget never shapes the process. Cost is only measured afterwards, to look for savings.
  - In `eco` and Let It Rip, a token budget, and in Let It Rip also a wall-clock budget, reaches a reader only after you've been asked how much it should weigh against your other goals.
  - When in doubt, leave the budget out of the brief. If it seems important and there's no way to ask, it goes in as information, not as a limit. It's written as binding only if you approved that.
  - A prediction, like "this might halve token use", is never a condition for closing a ticket. That's your story, and the same ruling as "principle over proxy" on the "at most" list.

## Q1 again, in practice

You picked (c) but found it abstract, so here it is as cases. The question for each rule is: may the agent reading it decide to do otherwise?

| Rule | Who set it | What it's about | Binding? |
|---|---|---|---|
| Never push to `main` | you | your decision (merging), not the agent's | **Yes** |
| The orchestrator never writes the code itself | you, with evidence | how the work is done | **Yes**, because you set it deliberately |
| "Another lane is editing `foo.sh` right now" | the orchestrator | something the orchestrator owns at that moment | **Yes**, the reader can't know otherwise |
| "Read only the diff" | an orchestrator, to save tokens | how the work is done | **No.** It becomes information: "the diff is here; the changed function is called from X" |
| "Cite a `spec:` line or it isn't a bug" | a lane, while building the review script | what counts as done | **No**, because nobody with authority set it |

So in practice (c) comes to this:

- **Only you can make a rule bind**, directly, or through the ticket, AGENTS.md or DECISIONS.md where your decisions are written.
- **An agent can bind only what it actually owns**, such as which files another lane holds right now.
- **Everything else an agent writes is information, with its reason.**
- **Rules about the route bind only when you made them bind on purpose.** That's why the delegation rule binds and "read only the diff" doesn't.

Is that what you meant by (c)?

## Q3: your worry is half right

The evidence splits in two:

- **A bar changes what gets reported, not what gets found.** "Only report high-severity issues" makes a reviewer stay quiet about bugs it found. Moving the bar to a later step fixes that.
- **A focus changes what gets seen.** That's the gorilla study and the 2026 preprint. A reviewer told to look at one kind of bug really does see less of the other kinds.

So your worry is real. A "slight push" toward the bug types you care about would cause the same miss for every type it doesn't name. The research's answer is structural, not wording: if a kind of bug matters enough, give it its own pass, and always keep one pass with an open brief. In the preprint, the open-brief reviewer recovered everything the focused one had dropped.

That leads straight into your point about a review system of our own. I agree with you. Recall, the share of planted bugs a review finds, is the number that matters, and studies that report only false positives hide it. Whether that work belongs on this map or gets a map of its own is a question I've put to you as Q4 below.

---

❓ **Q3 - The five ways an agent may depart from a rule today.** Here they are, with where each lives:

| # | Where | What it says | In practice |
|---|---|---|---|
| 1 | Both `AGENTS.md` files | "If one fights the task in front of you, say so loudly and get a sign-off before breaking it." | Copied from Theo. Only these two files mention it. It never says how a subagent, which has nobody to ask, gets a sign-off. |
| 2 | [template/AGENTS.md:16](template/AGENTS.md:16) | "When this file and a vendored skill disagree with your instinct, follow the file and tell me why your instinct differed." | The opposite default to #1: obey first, explain after. |
| 3 | `MANUAL.md`, `PHILOSOPHY.md`, `DECISIONS.md` | When a rule fights you, re-read the reasoning. Where the spec is silent, make the call and record it as Provisional so you can overrule it. | The agent decides, and leaves a record you can overturn. |
| 4 | poteto-mode (upstream pstack) | A step you choose not to do stays on the list as `skip: <reason>`; skipping silently isn't allowed. [feature.md:12](template/.agents/skills/poteto-mode/playbooks/feature.md:12) forbids this for delegation. | A visible skip, with one hard exception. |
| 5 | Our review scripts and playbooks | Writer flags must end `fixed: <sha>` or `accepted: <reason>`. A writer that can't build a test cell as written stops and reports it. A design hole is written back into the ticket. | The departure goes back up to the artifact or to you. |

What I proposed replaces #1, #2 and #4 with one rule:
- When the agent departs from route knowledge, it uses its judgment, and its report always says where it departed and why, or says it didn't.
- When a binding rule fights the goal, it stops that part, reports the conflict to whoever set the rule, and carries on with the rest.
- It never shrinks the goal to fit a rule.

#3 and #5 stay. They are already this pattern, applied to specs and to artifacts.

➡️ The replacement above. #2 is the one I'd most want gone: "obey, then explain" is exactly how a rule ends up beating the goal without anyone noticing.

---

❓ **Q4 - Where does the review system go?** The options:
- (a) Add it to this map's "Not yet specified" section. The review briefs already fall under "Prototype brief templates for the recurring lane jobs" and "Decide the scope and order of reworking existing files".
- (b) Give it a map of its own, opened once this map has decided the writing standard.

➡️ (b), with one line in this map's "Out of scope" section pointing to it. A review system covers more than writing: the number of passes, the kind of each pass, judging the findings, and measuring recall. Its briefs would still follow this map's standard.

---

❓ **Q5 - How a binding rule is written and enforced.** The research says emphatic wording ("CRITICAL", "MUST") makes current Claude models over-apply a rule, and that a bare "don't" names the forbidden thing without saying what to do instead. My proposal:
- A binding rule is written once, plainly, with its reason and what to do instead.
- Where a hook enforces it, the hook's refusal message carries the reason and the way forward, because it arrives at the moment it's needed.
- Briefs don't restate it; at most they point to where it's written.

This also serves your Q2 note: fewer restated rules leaves the reader more attention for the ones that matter.

➡️ As above.