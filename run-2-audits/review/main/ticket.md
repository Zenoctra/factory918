## What to build

> user: I notice it seems like reviewers tend to get bogged down from a SPECIFIC kind of "hard finding" which is "should the user be allowed to interact with the system in a certain way and still get the desired result" which then results in "would-break" bugs really just extending the scope of what we intended to service by going deep into edge cases. Every edge case sounds defensible because it reflects a genuine break scenario, but all we need to ask ourselves, are we just edge testing for un-expected user behavior and is that really worth our time as opposed to simply having an intended path, and AT MOST hardening to fail fast and loud if we move outside of that. [...] there are an infinite amount of unhappy paths and only 1 happy one. The primary focus of the reviews kind of MUST be the happy path. Then easy and expected unhappy paths that dont necessarily get provided for, but error in a way that the user knows how to correct itself.

> agent: Across #75's five rounds and #77's and #78's four, about one finding in six was the intended path giving a wrong or silent result, a few were failures the user cannot see, and the rest were unexpected input that already fails loud, wording, smells, or repeats. The reviewers labelled the third kind would-break because the definition says "wrong behavior in normal use" and they read "normal" generously.

> user: The best I could think of is "An edge case outside the intended path being unsupported does not count as a flag to bring to attention." Additionally, I'm sure a CERTAIN amount of edge cases are meant to be accounted at least a LITTLE in terms of errors, but more like we notice the variable is unexpected and flag that without having to diagnose every reason the variable might be wrong for the user. [...] if its easier to find an edge case than an actual bug in the intended path, then the edge case is going to get chosen while the important bug gets missed due to model laziness and focus.

> agent: Industry names for this: a precondition violation belongs to the caller (design by contract); "by design" and "enhancement, not a defect" in triage; fail-open versus fail-closed; a reproduction starts from a documented step; bikeshedding for the reviewer's drift to the easy finding; approve with comments. Proposed: report what breaks the walk, then at most three hardening items.

> user: This is going to consistently return a result with exactly 1 thing that breaks and exactly 3 things that can be hardened. I dont want that and I dont want hardening taking up more thought or token output than actual breakage. [...] I also want to make sure my exact philosophical reasonings are quoted in the skills/system instructions/prompts as well because even if the things you said covers it all, using the exact verbiage of the user is going to help semantic philosophical alignment.

> agent: No quota. An input outside the documented path either meets a guard that refuses it loudly, and there is nothing to report, or it proceeds silently, and that is fails open, counted. No heading for hardening exists. The report opens with the walk of the documented path, then Would break and Fails open, each item naming the documented step it starts from, and the script refuses one that does not. Zero items is the expected result for a clean change, said in those words.

> user: "An edge case outside the intended path being unsupported is not a flag." "Primary focus must be the happy path, then unhappy paths that error in a way the user can correct." add these two quotes as well to the list of my words that we keep quoted. Then go ahead and make the ticket.

The five sentences of Manuel's that the brief and the skill quote verbatim, attributed:

1. "there are an infinite amount of unhappy paths and only 1 happy one"
2. "AT MOST hardening to fail fast and loud if we move outside of that"
3. "we notice the variable is unexpected and flag that without having to diagnose every reason the variable might be wrong for the user"
4. "An edge case outside the intended path being unsupported is not a flag."
5. "Primary focus must be the happy path, then unhappy paths that error in a way the user can correct."

## Acceptance criteria

- [ ] **The definition.** Both briefs and `spec-review/SKILL.md` step 4 carry, word for word and pinned by the existing test: a hard finding is one of two things, the documented path gives a wrong or silent result, or an input outside it proceeds silently (fails open); an input outside the documented path that is refused with a message saying how to correct it is not a finding, it is the design; zero items is the expected result for a clean change. The five quotes above follow it, attributed to Manuel. Today the definition is "wrong behavior in normal use" and the reviewers read "normal" generously.
- [ ] **The Spec report opens with the walk.** Its first heading is `## Walk`: one numbered line per documented step of the path the change touches (the ticket's criteria and the documentation the diff changes), each saying what the code does at that step. Then `## Would break`, `## Fails open`, `## Not asked for`. `## Latent` no longer exists. Today the report has no walk and Latent is where edge cases go.
- [ ] **The Standards report** keeps `## Would break`, gains `## Fails open` after it, then `## Standards breaches` and `## Fix alongside`. Today it has no Fails open heading.
- [ ] **Every item under Would break or Fails open** carries a line `Documented step:` quoting the ticket line or the `file:line` of the documentation the user follows, and a line `Result:` saying what happens instead. `review-comment.sh` refuses a report whose Would-break or Fails-open item lacks a `Documented step:` line, naming the item. `hard findings: N` counts the items under both headings. Today nothing ties a finding to a documented step and only Would break counts.
- [ ] **Both layouts.** `tests/spec-review/review-brief.sh` and `tests/spec-review/review-comment.sh` run their assertions twice, in a temporary repository with a project layout (`.claude/hooks/`, `.agents/skills/spec-review/`) and in one with the factory's `template/` layout, and every assertion holds in both. CI's fixture flow runs `review-brief.sh` with a fake `gh` inside the applied project and asserts both briefs exist with the headings above. Today the tests use one generic layout and the fixture flow never runs the review scripts.
- [ ] **No stale wording.** A CI step greps `template/` and `docs/knowledge/core/` for the retired phrases (`## Latent`, the old definition sentence) and fails when one is found. Today nothing catches a rename that leaves the old words behind.
- [ ] **The ladder and the judgment texts** name the two counted kinds in the same words; `interrogate`'s lead-judgment reference is unchanged.

## Expected effect

Not a criterion. The PR runs the new briefs once against the saved diffs of #77 round 2 and #78 round 1 with the same reviewer model and reports, in the four rows of the table from this conversation, what came back. No sentence of the brief is changed to move that number; a result that argues against the definition is a reason to re-read the run, not the rule.

## Blocked by

None

