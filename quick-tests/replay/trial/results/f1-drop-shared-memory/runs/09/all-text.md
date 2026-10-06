Your answers aren't saved anywhere yet. I tried to post them word for word on the ticket, the way the map keeps your earlier rounds, and that was declined. For now they live only in this conversation. Tell me if you want them posted, or saved somewhere else.

## Q1 in plain terms

Every sentence in a brief that tells the reader how to act is either a **must** or **advice**.

- **A must comes from you**, or from a document that records your decision. An orchestrator writing a brief may pass your musts along. It may add its own musts only about things it controls, such as a file another subagent is editing right now.
- **Everything else is advice.** It's written with its reason, and the reader may do something different as long as its report says what and why.

How that sorts real rules from this repo:

- **"Never push to main."** Merging is your call, and you made the rule, so it's a must.
- **"The orchestrator never writes the code."** This is about method, but you decided it on evidence and a hook holds it. So it's a must. You can make method a must. An orchestrator can't.
- **"Read two plain commands, because the worktree guard refuses `git` inside `$(...)`."** This is advice: a fact about a tool, with its reason. The guard is the must.
- **"Read only the diff."** A lane added this to save tokens, and you never decided it. It becomes "the diff is here, the ticket is here", with nothing about what not to read.
- **"Only report high-severity issues."** This is a rule about how the task is finished, which your Q3 answer covers. It leaves the brief and becomes a filter step afterward.

## A correction on Q3

You wrote, "if you are saying the evidence says both get found". It says that for only one of two effects:

- **A bar in the brief** ("only report high severity") hurts reporting, not finding. The reader sees the bug and keeps quiet about it. Option (a) fixes that.
- **Where the reader's attention goes** is a different effect, and there the evidence goes the way you fear. What an observer is told to count decides what it sees; that's the gorilla study. A reader's own drift toward edge cases is the same effect. Option (a) doesn't touch it.

I think (a) still stands, and Q7 below covers your worry. Tell me if knowing this changes your answer.

## Q5 as I'll record it

- **In `safe`**, the first tier: no budget ever shapes the process. Cost is only measured afterward.
- **In `eco` and Let It Rip:** a token budget, and in Let It Rip a wall-clock budget, reaches a brief only after you've been asked how binding it is. When in doubt, the budget isn't communicated at all. If it seems important and you can't be asked, it goes in as information, not a limit. It binds only with your approval.
- **A predicted saving is never a requirement.** Your halving example is the case.

This also shapes the map "Design Let It Rip as the third mode". When I close this ticket, I'll carry it there.

## Your Q2 note

The research note doesn't cover your point about one precise term pulling in many rules, the microgenre idea. It's a testable experiment: give the reader one precise term against a list of rules, and count how much of each gets followed. When I close this ticket, I'll carry your words to two other tickets, "Decide what the writing standard is and what carries it" and "Decide how we'll know the writing works".

---

❓ **Q4 - What does the reader do when it goes against advice, or when a must fights the goal?** Here are the five mechanisms in the factory today:

1. **Ask first.** [AGENTS.md:26](AGENTS.md:26) says: "If a rule fights the task in front of you, say so loudly and get a sign-off before breaking it." A subagent has nobody to ask, and nothing says how it would. It also pulls against "never block on the human".
2. **Obey first, explain after.** [template/AGENTS.md:16](template/AGENTS.md:16) says: "when this file and a vendored skill disagree with your instinct, follow the file and tell me why your instinct differed."
3. **Decide and record.** Where the spec is silent, the agent makes the call and writes a Provisional row in `DECISIONS.md` that you can overrule.
4. **Skip visibly.** poteto-mode says a step you choose not to do stays in the list as `skip: <reason>`, and silent skips aren't allowed. Delegation is the exception: [feature.md:12](template/.agents/skills/poteto-mode/playbooks/feature.md:12) forbids skipping it.
5. **Send it back.** This one shows up in three places:
   - A writer that can't build a test cell as written stops and reports it.
   - Writer flags must end in `fixed:` or `accepted: <reason>`, or the review script refuses to run.
   - A hole found in a design gets a dated line on the ticket.

**How they conflict:** when a rule fights the task, (1) says ask before acting, (2) says obey and then explain, and (3) and (4) say act and record it. An agent can find text telling it to do any of these.

The proposal:
- **Against advice:** the reader uses its judgment, the way (3) and (4) work. Its report always carries a line saying where it went another way and why, or "none".
- **A must fights the goal:** in the session you type into, it asks you; that's (1), which works when you're at the keyboard. In a subagent, it stops that part, reports the conflict to whoever briefed it, and carries on with the rest; that's (5).
- **(2) goes away.** Obeying a must into a worse result and explaining afterward is what the report line replaces.
- **`skip:` and `accepted:` stay** as forms of that report.
- **Never shrink the goal to fit a rule.**

The options:
- (a) The proposal.
- (b) Keep all five, and write down which one applies when.
- (c) Ask first everywhere.

➡️ (a).

---

❓ **Q5 - What counts as "you decided it"?** Q1 makes this the key question, because a lot of the factory's text was written by models and merged by you in PRs. Cases:

- **"Read no brief and no diff while the review state exists"** ([ticket.md:13](template/.agents/skills/poteto-mode/playbooks/ticket.md:13)). A lane wrote it with no reason given, and you merged it.
- **The 150-line reading cap in the `knowledge` skill.** There's no recorded reason anywhere.
- **The delegation rule.** Your words are in a decision row, and a hook holds it.
- **pstack's own rules.** On 2026-09-24 you ruled that upstream pstack's constraints stay, and that Factory918's model-written text is suspect until proven.

The options:
- (a) Anything in a file you merged is a must.
- (b) A must needs a record of you deciding that specific rule (your words in a decision row, a ticket, or an approval), or it comes from an upstream you adopted. A model-written rule with no such record counts as advice until the ticket "Decide the scope and order of reworking existing files" sorts it.
- (c) Only rules you restate fresh are musts.

➡️ (b). It also gives the rework ticket its first sorting job.

---

❓ **Q6 - Can a review brief point the reviewer at the kinds of bug you care about?** This is your Q3 worry. The research draws one line here. Context about the task helped readers in every study, such as clinical information given to readers of medical tests. Telling readers what to look for narrows what they see. In one model study, a narrowly briefed model hid critical findings, and a second reviewer with an open brief recovered all of them.

The same concern, written three ways:
- "This change rewrites token refresh, which every login goes through." This is context about what's at stake.
- "Be especially wary of auth bugs." This is a focus.
- "Look for auth, injection and race bugs." This is a list, which turns the brief into a multiple-choice question.

The options:
- (a) A brief carries what's at stake as context and never says what to look for. Coverage of the kinds of bug comes from more than one pass, with at least one pass on a fully open brief.
- (b) Allow a light "especially wary of X".
- (c) The brief carries only the goal.

➡️ (a). How many passes, and which ones, belongs to the review system in Q8.

---

❓ **Q7 - How is a must worded, and how is it held?** Three findings from the research apply:
- Current Claude over-applies emphatic wording like "CRITICAL" and "MUST".
- A bare "don't" keeps the forbidden idea active and doesn't say what to do instead.
- A reminder that arrives at the moment of use fixed most of the gap in one model study.

Today the git guard's refusal already names a way forward ("Use --force-with-lease on your own branch, or ask"), while AGENTS.md's list of dangers is mostly bare "never" lines.

The options:
- (a) Every must is written plainly, says what to do (for example, "Push to a branch and open a PR; Manuel merges"), and carries its reason. Where a hook or script holds it, the refusal message carries the reason and the way forward.
- (b) Same as (a), but keep emphasis for the few hardest musts.

➡️ (a). Whether briefs also repeat a must that a hook already holds is a question for the ticket "Decide where each piece lives and when it reaches the writer".

---

❓ **Q8 - Where does the review system you described go?** You described one that covers a wider spectrum than bugs, uses several passes and a verifier that rates each kind of bug, and is measured by recall against planted bugs, not just by false positives. That's process, which is bigger than how agents write. Tickets already touching it include "Choose each tier's review round count from the clean measurement" and "Eval the judge and trail-review models the way #103 evals reviewers".

The options:
- (a) It gets its own wayfinder map, built on this map's decisions and research. This map keeps how review briefs are written, in "Prototype brief templates for the recurring lane jobs".
- (b) It becomes new tickets on this map.
- (c) It's left to the existing review tickets.

➡️ (a). When I close this ticket, I'll note it under this map's out-of-scope section, pointing to the new map. The new map itself gets charted only when you say so.