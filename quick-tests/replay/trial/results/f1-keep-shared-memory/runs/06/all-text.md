Your round-one answers aren't saved on the ticket yet. I tried to post them word for word as a comment, and the post was declined. Say if you want them posted, and I'll do it.

## Q1 in practice

For each rule in a brief, ask two things: is it about *what the job is*, or *how to do it*? And who said so? It binds only if it's about the job and you, or whoever owns that decision, said it must hold. Here it is applied to rules we actually have:

| Rule | About | Who said it | Result |
|---|---|---|---|
| "Don't merge the PR" | the job's limits (merging is yours) | you | **binds** |
| "Only read the files in the diff" | how | an orchestrator, to save cost | **doesn't bind**. At most it becomes information, like "the diff touches X, and Y calls into it" |
| "The orchestrator never writes the code" | how | you, with evidence | **binds**, because you made it bind |
| "Under 400 words" | how the job is finished | an orchestrator | **doesn't bind**, and Q3 removes it anyway |
| "Don't tell the reviewer the owner thinks it's fine" | not a rule on the reader at all | — | the writer keeping its opinion out. That belongs to "Decide what the writing standard is and what carries it" |

If any of these rows looks wrong to you, Q1 isn't settled yet and we should stay on it.

## Q3: a correction

You wrote "if you are saying the evidence says both get found". I wasn't clear, and the evidence splits in two:

- **A bar on what to report** ("only high severity") makes the reader find the bug and then leave it out. Your answer (a) fixes this: report everything, and filter later.
- **A focus on what to look for** ("we're especially wary of X") makes the reader actually not see what lies outside X. That's the gorilla study, and Shin's preprint on models. Your worry is real, and (a) doesn't fix it. A "slight push" toward one kind of bug is this case.

What fixed the focus problem in Shin's study was structural: a second reviewer with an open brief recovered every missed finding. That is your "multiple passes" point, so the focus problem belongs to the design of the review process.

## Q4: the five mechanisms we have now

| # | What it says | Where | Problem |
|---|---|---|---|
| 1 | If a rule fights the task, say so loudly and get a sign-off *before* breaking it | [AGENTS.md:26](AGENTS.md:26), [template/AGENTS.md:20](template/AGENTS.md:20) | A subagent has nobody to sign off. It also pulls against "never block on the human for reversible work". |
| 2 | Follow the file, then tell me why your instinct differed | [template/AGENTS.md:16](template/AGENTS.md:16), your own note | Opposite default to #1: #1 asks before acting, #2 complies and then explains |
| 3 | Where the spec is silent, decide and record a Provisional row you can overrule | [ticket.md:30](template/.agents/skills/poteto-mode/playbooks/ticket.md:30) | None. This handles a gap, not a conflict between a rule and the goal |
| 4 | A playbook step you skip stays in the list as `skip: <reason>`, and no silent skips | [poteto-mode SKILL.md:113](template/.agents/skills/poteto-mode/SKILL.md:113), upstream | [feature.md:12](template/.agents/skills/poteto-mode/playbooks/feature.md:12) bans it for delegation, with no reason given |
| 5 | Writer flags must end `fixed:` or `accepted: <reason>`. A writer that can't build a cell stops and reports it | [spec-review SKILL.md:29](template/.agents/skills/spec-review/SKILL.md:29), feature.md:12 | None. A script checks it |

My proposal from before, mapped onto these:

- **For a rule that doesn't bind:** the reader uses its own judgment and its report says where it departed. That replaces #2's "follow, then explain" for rules that don't bind, and turns #4's `skip:` line into the general form instead of an exception.
- **For a binding rule that fights the goal:** stop that part, report it to the rule's owner, and carry on with the rest. When the owner is you, sitting in the conversation, that *is* #1. So #1 survives as the special case where the owner is present.
- **#3 and #5 stay as they are.** They're already this shape.

Underneath this is a question only you can answer. It's below as Q4b.

---

❓ **Q4 - One mechanism in place of #1, #2 and #4, with #3 and #5 kept?**

➡️ Yes, as mapped above.

---

❓ **Q4b - Does a file you wrote make every line in it binding?** Your note in the template says "follow the file", and line 20 says "These are good defaults, not hard rules." Under Q1, owning a file isn't the same as saying each rule in it must hold. The options:
- (a) Only rules you marked as binding, or that a hook or script enforces, bind. Everything else in AGENTS.md is a default, and a departure from it gets reported.
- (b) Everything in a file you own binds until you say otherwise.

➡️ (a). It matches your own line 20. It also means your "follow the file, tell me why" note gets rewritten as "depart if you must, and tell me why". That changes your words, so it needs your yes.

---

❓ **Q6 - How are binding rules worded and held?** The research finds three things. Emphatic wording ("CRITICAL", "MUST") makes current Claude models over-apply a rule. A bare "don't" keeps the forbidden idea active without saying what to do instead. A reminder that arrives at the moment of use works far better than a standing rule. The options:
- (a) Binding rules are written plainly, once, with the reason and with what to do instead. Where a hook or script holds a rule, the brief doesn't repeat it, and the hook's refusal message carries the reason and a way forward, as the git guard already does.
- (b) Binding rules are restated in every brief.

➡️ (a). This also answers your Q2 note: fewer rules restated means more attention left for each one.

---

❓ **Q7 - Where does the review-system redesign live?** You asked for it in Q3: multiple passes, better briefs, measuring recall and not only false positives, and a fix for the way spec-review and interrogate both lead the reader. The options:
- (a) A map of its own, started from this map's decisions, with your Q3 words as its seed.
- (b) Fold it into this map.
- (c) Leave it to "Prototype brief templates for the recurring lane jobs".

➡️ (a). How many passes, which verifiers, and how to measure recall are process design, beyond this map's destination, which is the writing. This map would list it under Out of scope with a link, and the brief templates ticket would feed it.

---

Your other two notes I'll record where they belong when this ticket resolves:

- **The co-pull terms idea, with its experiment:** one dense term that carries most of a rule set, plus specific additions only where the term doesn't already reach. This goes to "Decide how we'll know the writing works", as an experiment, and to the standard ticket, as a technique.
- **Budgets:** these are already saved to my memory as you stated them. The first mode is called `safe`.