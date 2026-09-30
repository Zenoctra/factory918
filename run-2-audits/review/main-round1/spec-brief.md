# Spec review brief

Read nothing beyond this brief unless a finding needs the code around a hunk, and then read that one function or section, not the file. Run nothing.

## Commits

41104d7 Record what a review counts and that the orchestrator judges before the count
1a50d76 Add a spec reviewer row so the Spec axis runs cheaper than the writer
8eb32c3 Give spec-review a Judge step between the reports and the count
e730367 Count only what would break, and only after the orchestrator has judged it

## Changed files

 .github/workflows/factory-ci.yml                   |   6 +-
 SOURCES.md                                         |   2 +-
 docs/knowledge/INDEX.md                            |   4 +-
 docs/knowledge/core/DECISIONS.md                   |   6 +-
 docs/knowledge/core/MANUAL.md                      |   9 +-
 machine/pstack-models.fable.md                     |   1 +
 machine/pstack-models.opus.md                      |   1 +
 patches/mattpocock/spec-review.SKILL.md.patch      |  49 +++--
 template/.agents/skills/spec-review/SKILL.md       |  36 +++-
 .../skills/spec-review/scripts/review-brief.sh     |  27 ++-
 .../skills/spec-review/scripts/review-comment.sh   |  89 ++++++--
 template/docs/agents/models.md                     |   5 +-
 template/docs/factory918/DECISIONS.md              |   4 +-
 template/docs/factory918/MANUAL.md                 |   1 +
 tests/spec-review/review-brief.sh                  |  64 ++++++
 tests/spec-review/review-comment.sh                | 229 +++++++++++++++++++++
 16 files changed, 475 insertions(+), 58 deletions(-)

## Diff

The diff is 791 lines; read it from `.scratch/review/main/diff`.

## The ticket (#76)

## What to build

> user: lets talk more deeply about why this got missed by the reviewers because that is much more systemically important than the phase flip and you talked right past it. You had context that the reviewer didnt and should have. It was checking if the spec as implimented would execute the way the ticket writer/user would expect. That is a question beyond just "does it pass verification" that is a architectural conversation that needs a bigger picture scope/access. So then the fact that it wasnt given context to know how it fits into the system to see such an issue is needing to be explored.

> user: Im not 100% convinced that the reviewer needs to be fronteir intelligence as opposed to its context needs to be designed by someone with fronteir intelligence. Ive seen Gemini 3.1 flag hundreds and hundreds of non-hallucinated bugs when it was told to go looking for them.

> user: I might change my mind about running more passes and just say after 3 passes, we can afford to find missed bugs the hard way because it will go faster than spending hours and hours in review to find niche cases that wont kill us right away or will fail loud and fast later

> agent: The high-leverage change is that a diff touching something cross-cutting, a hook, `settings.json`, the router, `mode.sh`, must get a blast-radius grounding that enumerates every caller or session affected, and that enumeration is what gets handed to the reviewers. It fixes design-time and review-time with one artifact, and the `blast-radius` skill already exists to produce it.

> agent: Cap at three, and make the stop "no confirmed would-break finding in the round," where would-break means wrong behavior in normal use, not a style, policy, or latent-edge item. [...] It also redefines the #32 gate's `act-on items` from "any hard finding" to "confirmed would-break," which is the same move.

> agent: Cheap-and-thorough finder plus frontier judge is a sound split [...] Fix the scope, then the finder's strength is a cost dial you can turn down.

> user: perfect. all of the above.

The miss that started this: on PR #75 four review rounds found the local defects and none found that the new hook blocks `factory-start` at day zero, because the Spec brief carries the diff and the ticket and nothing about the sessions and skills the hook reaches. The orchestrator found it while answering a question, after scoping the `how` grounding to the hook's own neighborhood and skipping `architect`.

## Decided during planning (2026-09-18)

> user: What does pstack's review process look like? I feel like spec-review might be worded so vaguely and unsafely that it never converges. If pstack naturally says don't stop until act-on = 0, then I don't want to add a cap; I want to fix the review process to flag less arbitrary unimportant kickbacks.

> agent: pstack never says "review until zero"; the count gate is the factory's own patch on both upstreams. pstack converges by judgment: `interrogate` runs once, the orchestrator as lead judge sorts every finding into Act on, Consider, Noted, Dismissed with a reason, more than five act-on items means the judge is not filtering, and the Dismissed list is shown so the human can overrule. Bugbot findings are triaged fix, dismiss, ask, with "ask by default" categories. On PR #75 the five rounds found four would-break bugs; the rest was spec fidelity re-found each round because nothing carried forward, and smells counted as hard findings.

> user: Keep the three-round review with Matt's spec-review tacked to the end, and add the lead-judgment step. Fix what is getting counted, how it is read, and how the reviewers are told to report. Smells are good practice but not so huge they need to be treated so harshly: "fix alongside if there are other hard findings while you are already making changes". Fix carry-forward, but not in a way that lets the orchestrator lead the witness into a false pass or gives non-falsifiable review expectations ("I typed x=5, check that the script says x=5"). The agent knew some findings were accepted and could do nothing; if that had been corrected, later passes could have found new bugs. Also: I had the agent write a comment on #74 that settled two choices before implementation, and the reviewer could not see it as criteria.

> agent: A carried item must cite the decision it rests on (the user's words, a `DECISIONS.md` row, or the ticket author's comment), and the brief says only that these are settled; no expected results. The ticket author's comments are part of the spec; the script pastes them labeled. The trigger paths must name both the factory's `template/` copies and a project's own.

## Acceptance criteria

- [ ] **Blast-radius grounding.** A diff that touches `.claude/hooks/`, `.claude/settings.json`, `mode.sh` or the `factory918` router skill, and in this repository their copies under `template/`, gets a blast-radius grounding before the writer brief, listing every session and skill the change reaches. It is written to a file, and `review-brief.sh` pastes it into both briefs. `architect skipped:` is not accepted for such a diff. Today the briefs carry the diff, the stat, the log, the standards and the ticket only, and the Feature playbook allows skipping `architect` with a reason.
- [ ] **Would-break is the count.** Both briefs define a hard finding as wrong behavior in normal use and require each one as a numbered item under a `## Would break` heading. Standards breaches, visibility and latent-edge items go under their own headings and are not counted. Smells go under `## Fix alongside`, are not counted, and are fixed only when a would-break fix already touches that code. `review-comment.sh` exits 1 when a report's `hard findings:` line exceeds the number of items under `## Would break`. Today every hard finding counts, the Standards reviewer counted smells in rounds 2 and 3 of PR #75, and the script trusts the line.
- [ ] **Lead judgment before the count.** After the reports, the orchestrator sorts every finding into Act on, Consider, Noted or Dismissed with a one-line reason each, following `interrogate`'s lead-judgment reference. `act-on items: N` is the count after judgment. The Dismissed and Noted lists appear in the comment with their reasons. A finding in the bugbot-triage "ask by default" categories (security, privacy, auth, billing, data, migrations, concurrency, cross-system) cannot be dismissed by the agent; it is asked. Today the count is the reviewers' raw sum and the orchestrator's Disposition changes nothing.
- [ ] **Carry-forward that cannot lead the witness.** The next round's brief carries the previous round's Dismissed and Noted items verbatim with their reasons, each citing the decision it rests on: a `user:` line on the ticket, a `DECISIONS.md` row, or a ticket comment by the ticket's author. The brief says these are settled and are not to be re-raised, and says nothing about what the reviewer should find or confirm. An item with no citable decision is not carried. Today each round is a fresh reviewer with the ticket body only; "whole `DECISIONS.md` is writable" was raised in rounds 2 and 4 of PR #75.
- [ ] **The author's ticket comments are spec.** `review-brief.sh` fetches the ticket body and the comments posted by the ticket's author, and pastes both, the comments under a heading naming them as the author's. Comments by anyone else, and the PR's own comments, are never spec. Today the script fetches the body only, so the comment on #74 that settled two choices before implementation reached no reviewer.
- [ ] **Three rounds.** `spec-review` on one PR runs at most three rounds and stops earlier when a round's post-judgment count is 0; `review-comment.sh` prints `round: N` above `act-on items`, counted from the PR's earlier review comments; the review ladder and babysit's step 6 say so; a would-break finding after round three becomes a ticket. Today the ladder and babysit stop only at `act-on items: 0`.
- [ ] **A models row for the Spec axis.** `spec reviewer` has its own row in both presets under `machine/` and in `docs/agents/models.md`, so its finder can run cheaper than the writer's lane; the skill reads that row. Today it runs on the `feature, refactoring` descriptor.
- [ ] **Ledger.** `docs/agents/ledger.md` carries the #75 miss (already on main in bb4c4a6; the PR cites it) and a new line: the reviewer's brief could not see the ticket author's comment on #74, so a settled choice was reviewed as a deviation.

The original criteria of this ticket are superseded by the list above; the ledger criterion is carried over. Execution is one ticket and likely a stack of PRs, one concern each.

## Blocked by

None

## Report

A hard finding is wrong behavior in normal use: a command, hook, script or documented flow does something other than what the ticket or its own documentation says it does, on the path a user takes.

Write the report as Markdown with exactly these `## ` headings, in this order, each holding numbered items or nothing:

- `## Would break`: a requirement missing, partial, or implemented so that normal use does something other than the ticket says.
- `## Latent`: edge cases, visibility, policy, wording; anything a user would not hit in normal use.
- `## Not asked for`: behaviour in the diff the ticket did not ask for.

Each item opens with a line of the form `1. **Title.** body` and quotes the spec line it rests on; number the items continuously across the headings, so the judgment can name your third item as [P3]. Read nothing beyond this brief unless a finding needs the code around a hunk, and then read that one function or section, not the file. Under 400 words.

Write your report to `.scratch/review/main/spec-report.md` and reply with only that path.
End the report with exactly one line `hard findings: N`, where N is the number of items under `## Would break` and nothing else.
