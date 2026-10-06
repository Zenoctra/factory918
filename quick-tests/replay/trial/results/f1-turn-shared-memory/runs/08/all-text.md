Q2, Q3 and Q5 are settled. Before round two:

- **Your answers aren't on the ticket.** Posting them as a comment on the ticket was declined, so the verbatim record is a draft in my scratchpad, [round-1-answers.md](/private/tmp/qr-fa251854/claude-501/-private-tmp-qt-replay-f1-turn-repo/ad365e4d-9f1b-496f-9b32-afbe590ceac2/scratchpad/round-1-answers.md). Tell me if you want it posted.
- **Q5 is already in memory.** The memory "Budget never binds unasked" says what you said, so I left it as is.

## Q1, slowed down

Before a rule goes into a brief, the writer asks two things:

1. **Is this the reader's call?** How to do the work is the reader's call by default. What's wanted, when it's done, and anything that belongs to someone else are not.
2. **If it isn't the reader's call, who decided that?** It has to be someone with the right to decide: you, a ticket you approved, or whoever owns the thing being protected. An orchestrator's own hunch doesn't count.

If both answers hold up, the rule binds, and it's written plainly with its reason. If not, it goes in as information with its reason (your Q2 answer), or it's left out.

Here's how real rules from the factory come out:

| Rule | The reader's call? | Who decided | Result |
|---|---|---|---|
| Never push to main | No, merging is yours | You | Binds |
| The orchestrator hands code to a lane | It would be, but you took it away | You (P11), after a session broke it | Binds |
| Reviewer: read only the diff | Yes, it's how to search | An agent, to save tokens | Doesn't bind. It becomes a fact the reviewer can use: "the change is in these files" |
| Cite a `spec:` line or it isn't a bug | It looks like "what done means", but it decides what gets reported | An agent's provisional decision | Your Q3 answer: the reviewer reports everything, and the spec link is checked in the step after |
| Subagents never start their own dev servers | Split: the shared ports and processes aren't theirs; checking their own work is | Theo's rule, copied in without its reason | The shared-resource half binds; the rest becomes information |
| Stay inside the ticket's scope | No, scope is part of what's wanted | You, through the ticket | Binds for what gets changed. Anything noticed outside it goes in the report |

The table also shows that for many existing rules, nobody recorded who decided them. Whoever reworks the existing files will have to find out, or ask you.

## On your Q2 note about terms that carry other rules with them

I'll pin it. Testing it belongs to the ticket "Decide how we'll know the writing works". One thing to test there: a micro-genre term brings in the genre's norms. That's what you want when the norm is the goal. It's a risk when the job is to find what lies outside the norm, which is exactly what review is.

## On your Q3 worry

I need to correct how my point came across. The evidence says two different things:

- **A bar changes what gets reported, not what gets found.** Your (a) fixes this.
- **Where a reader's attention goes changes what it sees, and (a) doesn't fix that.** In the gorilla study, observers who counted the team dressed like the gorilla noticed it 58% of the time; those counting the other team, 27%. Your "slight push" would work the same way: findings of the named kind go up and the others go down. In Shin's preprint, what recovered the missed findings was a second reader with an open brief, not better wording in the first brief.

So your worry is right, and the fix is structural: several readers starting from different places. That's review-system design, which brings us to Q7.

---

❓ **Q6 - Which way of departing from a rule replaces the five?** These are the five ways the factory currently handles departing from a rule:

1. **Say so loudly and get a sign-off before breaking it** ([AGENTS.md:26](AGENTS.md:26), [template/AGENTS.md:20](template/AGENTS.md:20)). Nothing says how a subagent working unattended gets a sign-off.
2. **Follow the file, then explain why your instinct differed** ([template/AGENTS.md:16](template/AGENTS.md:16)). This complies first and reports afterward, the opposite of 1.
3. **Where the spec is silent, decide and record a Provisional decision you can overrule** (PHILOSOPHY, DECISIONS, the Ticket playbook).
4. **Skip a step visibly with `skip: <reason>`** (upstream poteto-mode). [feature.md:12](template/.agents/skills/poteto-mode/playbooks/feature.md:12) forbids it for delegation.
5. **Send the conflict back to the artifact.** A writer flag must end `fixed:` or `accepted: <reason>`. A writer who can't implement a cell stops and reports it. A design hole amends the ticket.

There's no record of 1 ever being used.

The options:
- (a) **Two cases.** For knowledge about the route, the reader uses its judgment, and its report always says where it took a different route and why, or that it took none. For a binding rule that fights the goal, the reader stops that part, reports to the rule's owner, and carries on with the rest. It never shrinks the goal to fit a rule. 3 and 5 survive as cases of the second. 1, 2 and 4 go.
- (b) Keep 1 for the orchestrator talking with you, and use (a) for subagents.
- (c) Keep all five and write down when each applies.

➡️ (b). When you're in the conversation, a sign-off is the cheapest way to report to the rule's owner, so 1 is just (a) with you present. The only thing to fix is that a subagent gets no instructions today.

---

❓ **Q7 - Where does the review system live?** You expect a review system of the factory's own: several passes, wider coverage than bugs (security among others), no leading, and judged by how many planted bugs it misses, not only by how few false findings it makes. No existing ticket covers that. "Prototype brief templates for the recurring lane jobs" covers the wording of review briefs, not the process around them.

The options:
- (a) Its own map, which takes this map's decisions as given.
- (b) A patch of fog on this map, graduating into tickets here.
- (c) Folded into the brief-templates prototype.

➡️ (a). How many passes, which lanes, how they're verified and how recall is measured are process questions, and they'd stretch this map's destination well past writing. This map stays the place where review briefs get their writing rules. I'd add one line under this map's Out of scope that points to the new map, and chart that map in its own session.

---

❓ **Q8 - How is a binding rule worded?** What the research says about the rules that remain:
- Emphatic wording ("CRITICAL", "MUST") makes current Claude over-apply a rule.
- A bare prohibition keeps the forbidden idea in view and doesn't say what to do instead.
- A rule with its reason is followed better and more flexibly.
- A limit stated as information harms less than the same limit stated as control.

➡️ Every binding rule is written plainly, with:
- its reason;
- who owns it;
- what to do instead when it gets in the way, which points back to Q6.

No emphatic wording. Where a hook holds the rule, the hook's refusal message carries the same three things, as the git guard's message already does ("Use --force-with-lease on your own branch, or ask"). Where each rule lives is left to the ticket "Decide where each piece lives and when it reaches the writer".

---

Last: after the table, does (c) still hold for Q1, or does seeing it in practice change your answer?