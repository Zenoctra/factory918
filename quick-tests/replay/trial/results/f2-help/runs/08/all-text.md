The background search is back, and none of it changes the five questions above. Your answers to those are still open, and I haven't treated anything as decided. The search does bear on two of my recommendations and adds one question.

**What it found**

- **The factory already has several ways to depart from a rule.** In the summary they looked contradictory, so I read each one where it's written. They cover different situations:
  - "follow the file and tell me why your instinct differed" (`template/AGENTS.md:16`) is for when your instinct disagrees with the file;
  - "say so loudly and get a sign-off" (`:20`) is for when a rule blocks the task;
  - pstack's `skip: <reason>` covers skipping a playbook step.

  None of them covers a subagent with nobody to ask, which is the gap Q3 is about. There's also already a precedent for Q3's option (a). A writer subagent "that cannot implement a cell as written stops and reports the cell, and never fills it in" (`feature.md:12`). A cell is one row of the test table a ticket hands the writer.
- **Rules on method did good, too.** Manuel set every one of these, and each says the reader must do more:
  - the mandatory review of the decision log caught an owner subagent's mistake in 3 runs out of 3;
  - the delegation hook was added after an agent knowingly broke the prose rule;
  - the blast-radius rule was added after narrow scoping let a hook bug survive four review rounds.

  The harmful rules mostly make the reader do less: read less, stop at N, cite only from a list. That pattern isn't clean, though. "Owners start one at a time" also makes the reader do less, and it was kept because it has a measured reason. So I'm not proposing "more versus less" as the test. That would be one more narrow proxy, like the search split you rejected.
- **The worst bound found wasn't about search.** It was about how findings get reported. The Standards review brief requires each hard finding to cite a `spec:` line from a ticket the brief never shows. Honest reviewers therefore demoted real bugs. One model wrote "not filed hard because the Standards brief carries no ticket criteria to cite." On one PR a reviewer filed nothing, even though that PR had 4 hard bugs. The run-2 constraints audit itself had sorted "report format" as safe and skipped it, then admitted the miss in an addendum. That supports your correction: a rule on how a task is finished can do as much damage as a rule on what may be read.
- **The research for the sibling ticket** "Research how wording and missing context shape a reader's response" is written. It sits on a local branch, and that ticket is still open. It finds no model study that tests a limit on strategy directly. The human evidence predicts such limits cost most when the task is new and the reader is capable. There are two counterweights:
  - specific method helps on simple tasks and novice readers;
  - holding back what the writer volunteers (its own conclusions) protects the reader's independence, which is different from limiting what the reader may look for.

  It also reports that output-length budgets hurt reasoning models, which supports Q5's option (a).

**How this changes my recommendations**

- **Q1:** same recommendation, plus one test case. The `spec:` citation rule is a rule about reporting, and it decided which findings counted. Under my test, only a rule's owner can make it binding. The orchestrator may bind where results go and their shape, but never the bar for what's worth reporting. That bar belongs to the goal, and it can't be stricter than the goal.
- **Q3:** same recommendation, now with the writer-cell rule as precedent.

**One new question**

❓ **Q6 - Must a binding rule carry its reason?** The audit found many rules with no reason attached: the 150-line reading cap in the `knowledge` skill, "never an arena," the 30-second test-suite limit. Nobody recorded why the cap is 150 lines. Without the reason, a reader can't tell when a rule fights the goal (Q3), and a later writer can't tell whether the rule still holds. The research also reports that models generalize from a rule's reason.
- (a) Every binding rule states its reason.
- (b) Only rules a reader is likely to question carry one.
- (c) Reasons live in `DECISIONS.md`, and the rule points there.

➡️ (a), kept short, with (c) allowed when the reason is long. A binding rule with no reason anywhere should be flagged when existing files are reworked. The rework itself belongs to the ticket "Decide the scope and order of reworking existing files", not this one.

---

Two things I noticed that are outside this ticket:
- **An unclear "These".** At `template/AGENTS.md:20`, "These are good defaults" could mean your note or the whole file.
- **A stale count.** `MANUAL.md:168` still says "twelve ordered beliefs", but PHILOSOPHY has had eleven since the cost belief was removed.

I'll file each as a quick ticket if you want.