# Ledger

One line per time an agent surprised you: `YYYY-MM-DD | model | what it did | what you wanted`. Append only. Rules are promoted from here (`/reflect`), never invented ahead of it.

2026-09-16 | fable | committed the ADR-pin doctor check before reading its test result | run the test, then commit
2026-09-17 | fable | ran apply through the ~/.local/bin symlink and copied nothing, because BASH_SOURCE was the link | resolve the link; a check that template/ is reachable
2026-09-17 | fable | passed the user's absolute path straight to vp create --directory, which refuses it; every local test had used a relative name | test the command the way a user types it
2026-09-17 | fable | hid vp install failures behind || true, which cost three CI runs to find | report every failure a gate depends on
2026-09-17 | fable | put seven concerns in PR #2 | one concern per PR; a bootstrap is still one PR per concern
2026-09-17 | fable | recorded surprises in the findings file instead of the ledger it had just created | the ledger is the ledger
2026-09-17 | fable | after changing a rule or renaming a file, left the decision record (P8, P10, P5) and two path references saying the old thing, across four PRs in one stack; the reviews caught all of them | before committing, grep for the old wording or path; a CI check that a renamed file is referenced nowhere would hold this
2026-09-17 | fable | three times in one day an edit script asserted on remembered text, stopped before writing, and the commit that followed claimed the change; twice the PR body repeated the claim | after any scripted edit, check that the intended file is in git diff --stat before committing; replace exact-text anchors with span markers taken from the file as it reads now
2026-09-17 | fable | renamed a variable with a regex that missed its assignment, so the doctor called every checkout "detached HEAD"; the retest grepped the output without asserting a line and the chain went on to push | after an edit, assert the exact expected output, not that a command ran
2026-09-17 | fable | fixed the act-on findings of PRs #23 to #30 in one closing PR at the top of the stack (#31) instead of on each reviewed PR | fixes land on the PR that was reviewed; a finding outside its scope becomes a ticket
2026-09-17 | fable | assigned a failing gh query's output under set -e, so the doctor stopped early on the fixture and apply's || true hid it; the retest read one line of the output | tolerate the failure inside the substitution; read the whole doctor output when testing a new line
2026-09-18 | fable | took three delegates' jobs in one session (bulk reading, a script, a finding) while knowing the rule; noticed by the human | brief the lane and judge its result; #74 holds it with hooks
2026-09-18 | fable | scoped the how grounding to the hook's neighborhood and skipped architect, so the hook blocking factory-start at day zero was found by the orchestrator after four review rounds, not by the reviewers, whose briefs carry the diff and the ticket only | ground a cross-cutting change in its blast radius before the brief, and hand that list to the reviewers
2026-09-18 | fable | briefed the Spec reviewer with the ticket body only, so the comment Manuel had written on #74 that settled two choices before implementation was reviewed as a deviation for two rounds | the ticket author's comments are spec; paste them into the brief
