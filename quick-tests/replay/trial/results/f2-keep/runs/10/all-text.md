The background search has finished. Three of its findings change my recommendations, so here are the amendments before you answer. Nothing from the round is settled yet; I'm still waiting on your answers to Q1–Q5.

**What it found that bears on the round**

- **Rules on how a task is finished did as much harm as rules on reading.**
  - The constraints audit from run 2 sorted rules into five classes. It kept "hand-back format" as safe, which mirrors the old "protect the world" split.
  - Its own late addendum admits a mistake there. The Standards review brief required each hard finding to cite the ticket, but never showed the reviewer the ticket. One reviewer followed that rule and filed nothing on a PR that had four real behaviour bugs.
  - So "how to report" isn't automatically safe.
- **Some rules about the route did real good.** Each one you set, each had a measured reason, and some of them are now held by hooks:
  - the mandatory trail review caught the owner's errors 3 times out of 3;
  - the blast-radius rule came from a hook bug that survived four review rounds;
  - the delegation rule got a hook after an agent knowingly broke it.
- **The factory has five ways to depart from a rule, and they disagree.**
  1. "Say so loudly and get a sign-off" ([AGENTS.md:26](AGENTS.md:26), [template/AGENTS.md:20](template/AGENTS.md:20)). No text says how a subagent gets that sign-off.
  2. "Follow the file and tell me why your instinct differed" ([template/AGENTS.md:16](template/AGENTS.md:16)). This is the opposite default: comply first, explain after.
  3. Record a Provisional decision for you to overrule.
  4. pstack's visible `skip: <reason>`, which the feature playbook switches off for delegation.
  5. The artifact-level dispositions: `fixed:` or `accepted:` on writer flags, and "stop and report the cell" for a writer who can't implement a cell as written.

  None of the audits looked at these.
- **Reasons are uneven.** Some rules carry their reason; many don't. Examples without one: "never an arena", "Read no brief and no diff while the review state exists", the 150-line cap in the `knowledge` skill, and "Do exactly the task in your prompt" in the tier agents.
- **The research branch for this map** (`research/wording-and-reader-context`) supports your broader framing.
  - It also gives a counterweight: specific method helps on simple tasks and for novices.
  - It draws a line between restraint in what the writer volunteers and limits on what the reader may seek.
  - No model study tests a limit on strategy directly.

**Amendments to round one**

- **Q1, amended recommendation.** I'd keep (a) and (b) together, with one sharpening. The shape of the report (where it goes, what fields it has) can be fixed. A bar on what counts as reportable is about the route, and it is not binding unless you set it, because it quietly narrows the goal. The `spec:` citation gate is the case this sharpening is for. The rules that did good all fit (b): you set them, and they carry a measured reason.
- **Q2, amended recommendation.** Still (b) with (a) as the starting point. The research adds a rule for when route knowledge earns its place: a short, simple task, or a known trap. "Here is what I know, and why" informs the reader. "Look only here" limits it. The research separates the two, so the standard can too.
- **Q3, widened.** Your answer will also decide what happens to the five departure mechanisms. My recommendation becomes:
  - one rule for every reader: stop that part, report the conflict to whoever owns the rule, and carry on with the rest;
  - the root session can still get your sign-off live, since you're there;
  - mechanism 2 ("follow the file, explain after") retires, because it makes the reader comply silently first;
  - `skip: <reason>` and the `fixed:` / `accepted:` dispositions stay as the way a departure gets reported.

  If you'd rather keep "follow first, explain after" for the root session, say so.

Q4 and Q5 are unchanged.

One unrelated stale fact the search found: [MANUAL.md:168](docs/knowledge/core/MANUAL.md:168) says the philosophy has "twelve ordered beliefs", but it has had eleven since you removed the cost belief. That isn't this ticket's question; I'll file it as a quick ticket once the round settles.