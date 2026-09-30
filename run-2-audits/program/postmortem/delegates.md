# Post-mortem, qualitative lane: what each delegate did and who caught what

Five owner lanes launched 66 delegates (plus 8 sub-lanes that four review lanes launched themselves, and 3 lanes of a first #93 owner that a session limit killed). Nine of those 77 found something that would otherwise have shipped wrong; four more re-found what a sibling had already written down and were the trigger for the fix; the rest did the work they were given, re-derived something a sibling or the owner already had, or died. This report goes ticket by ticket, then across the run.

How to read the tables. Times are wall-clock minutes from the lane's own transcript (first to last message, UTC clock in the text). "Model" is what the owner requested; effort could not be set per call. A verdict is one of four: **changed the outcome** (found something that would otherwise have shipped wrong, and says what), **did the work** (produced the artifact, nothing surprising), **rediscovered** (re-read or re-derived what the owner or a sibling already had), **wasted** (produced nothing that was used, or was killed). The root's own verifier lanes are not the ticket's delegates and are covered under each ticket's review section.

The sources: the owners' reports, trails and lane reports under `.scratch/program/{88,89,90,91,93}/`, the review comments on PRs #94, #96, #99, #101 and #102, the root's verifier comments and worker reports, and the owners' transcripts read through `grep` and `jq` (launch timestamps, child transcripts' first and last timestamps, each child's final message).

---

## Ticket #88, PR #96: run ShellCheck at a pinned version everywhere

Owner: fable, 14:30 to 16:43 (133 minutes, including the chain rebase the root asked for at 16:41). 18 delegates launched, plus 2 reviewers the round-1 review lane launched itself.

| # | Role | Model | Asked, in one line | Ran | Returned |
|---|---|---|---|---|---|
| 1 | how (first try, background) | opus | Explain the CI gates, the doctor and sync | 3.7 min | A full explanation to nobody: the owner's worktree vanished when the owner ended its turn to wait; the text was later recovered from the task file as `how-1.md` |
| 2 | how (second try, foreground) | opus | Same question | 2.8 min | `how.md`, the grounding both architect runners read |
| 3 | architect runner A | fable | Design the gate, given the how output and the measured checksums | 12.5 min | Candidate A: a script per CI plus a hand-typed `shellcheck -x` for lanes |
| 4 | architect runner B | opus | Same task | 14.6 min | Candidate B: one script the template carries, the pin and both checksums inside it |
| 5 | arena cross-judge | opus | Score both candidates, name the base and the grafts | 3.3 min | B 18, A 16; two grafts from A; one false claim found in each candidate |
| 6 | writer | fable | Implement candidate B plus the grafts, five ordered commits | 16.7 min | Five commits; one deviation (20 files linted, not 19: the gate lints its own test) |
| 7 | blast-radius (background) | fable | What could this diff break beyond itself; prove the one safety fact | 9.4 min | Five risks, three proven by running the script |
| 8 | spec-review round 1 lane | fable | Run the review skill: brief, two reviewers, judgment, comment | 4.3 min | Stalled before aggregating (ended its turn waiting on a reviewer it had re-dispatched); the owner aggregated by hand |
| 8a | Standards reviewer, round 1 | opus | Review the brief on the Standards axis | 4.1 min | One hard finding |
| 8b | Spec reviewer, round 1 | opus | Review on the Spec axis | 2.6 min | The same hard finding |
| 9 | fix lane, round 1 | fable | Fix the round-1 items | 2.2 min | One commit |
| 10 | Standards reviewer, round 2 | opus | Round 2, Standards | 2.9 min | Two hard findings and a wrong count |
| 11 | Spec reviewer, round 2 | opus | Round 2, Spec | 3.3 min | One hard finding (the same as one of Standards') |
| 12 | fix lane, round 2 | fable | Fix the round-2 items | 5.1 min | Two commits; proved on the wrong path, so CI went red |
| 13 | fix lane, CI red | fable | Fix the failing CI case | 3.2 min | One commit, proven on the path the runner takes |
| 14 | Standards reviewer, round 3 | opus | Round 3, Standards | 4.7 min | No hard finding; noted that the PR body's grounding was stale |
| 15 | Spec reviewer, round 3 | opus | Round 3, Spec | 4.5 min | Nothing |
| 16 | records lane | fable | The M0 line, the ledger rows | 1.2 min | One commit |
| 17 | trail review | opus | Cross-model audit of the decision trail | 4.4 min | Ten flags |
| 18 | fix lane, tarball | fable | Remove a cached tarball that fails its checksum | 1.7 min | One commit, after round three |

**Verdicts.**

- 1, how (first try): **wasted**, then partly salvaged. The lane finished and its text reached nobody; the owner ran the same question again and later fed both texts to the runners. Cost: 3.7 minutes of lane time and about 6 minutes of the owner's (14:38 to 14:44) rebuilding its worktree.
- 2, how: **did the work**.
- 3, architect A: **did the work**. Two of its details were grafted (a directive that makes the per-file run location-independent, and an honest reading of one finding as "not a live bug"). Its main shape lost.
- 4, architect B: **did the work**; became the design.
- 5, cross-judge: **did the work**. The owner agreed with it. It also caught one false claim on each side, which kept two wrong sentences out of the PR body. Useful, not decisive: the owner said it would have picked B anyway.
- 6, writer: **did the work**.
- 7, blast-radius: **changed the outcome, and was then ignored until the reviewers said the same thing.** Its risk 1 was that a binary already sitting in the temp directory is run as the pinned tool without ever being checked (on a shared machine, anything placed there would pass as ShellCheck). Its risk 3 was that a glob that matches nothing is silently dropped when other globs match, so a renamed directory would shrink the lint set without a word. Those are exactly the hard findings of review rounds 1 and 2, found again within the next fifteen minutes. The owner pasted the file into the PR body as grounding and did not treat its risks as things to fix before opening the review.
- 8, 8a, 8b, round 1: **rediscovered** (risk 3 of the blast-radius file), although it was the trigger for the fix. The review lane itself stalled at the end and the owner finished its job by hand.
- 9, fix 1: **did the work**.
- 10, Standards round 2: **changed the outcome.** It found that an argument containing a space was split into pieces before matching, so the gate refused a file that exists. Manuel's checkout lives under a path with spaces in it; a lane running the gate there with a quoted absolute path would have been refused. It also found the unchecked cached binary (blast-radius risk 1) and a wrong count in the M0 line.
- 11, Spec round 2: **rediscovered** (the cached binary, which Standards and blast-radius both had).
- 12, fix 2: **did the work**, with a cost: it proved its change to the download path on a machine that has the pinned tool on PATH, so the download path never ran and CI caught a stray "OK" line on the wrong stream. One CI cycle and a fix lane lost (about 7 minutes).
- 13, fix 3: **did the work**.
- 14, 15, round 3: **did the work**. Standards noted the stale grounding text; the owner logged "addendum in the PR body" as done and did not write it (the trail review and then the root's verifier both had to ask again).
- 16, records: **did the work**.
- 17, trail review: **changed the outcome.** Fix 2 had introduced a wedge: a half-downloaded or foreign tarball in the cache was never fetched again, so every later run would fail its checksum forever with no hint to delete it. Fixed as the last commit. It also flagged the race of two gates sharing one temp directory (which became ticket #97 via the verifier), the unwritten addendum, and an overclaim about test-before-implementation, all acted on.
- 18, fix 4: **did the work**.

**The count.** 18 delegates (20 with the two sub-reviewers). Three found, on their own, something radically important that the ticket would otherwise have shipped: the blast-radius lane (two of the three real bugs, first, at 15:33), the round-2 Standards reviewer (the space in a path), and the trail review (the wedge). The round-1 pair and the round-2 Spec reviewer re-found what blast-radius had already written down.

**Review rounds and the root's verification.**

- Round 1 (both axes): a glob among several that matches nothing was dropped silently, so the gate could pass while linting fewer files than it claimed. Found by the lane's reviewers; the blast-radius lane had it first; fixed.
- Round 2 (Standards): an argument with a space in it was refused as missing. Found by the Standards reviewer alone; fixed.
- Round 2 (both axes): a cached binary was never re-checked against the pin. Found by both reviewers; blast-radius had it first; fixed.
- Round 2 (Standards): the M0 file count was one short. Fixed.
- CI, not a reviewer: the round-2 fix left the checksum tool's "OK" line on the stream the test compares, only on the download path. Found by CI because the fix lane proved on the other path; fixed.
- Round 3: nothing hard. Standards noted the grounding text was stale; the owner promised an addendum and did not write it.
- Trail review: the wedge (a bad cached tarball is never re-fetched). Found by the trail reviewer after round three; fixed unreviewed. Also the shared temp-directory race, left as a known risk.
- Root's verification at 2360707: passed every gate and the live floor. It asked for body-only corrections (the Risks section still described the pre-fix script; a stale assertion count; missing test cases in the Scope list): this is the round-3 note and the trail-review flag the owner had logged as done. It filed two tickets: #97, the temp-directory race (the trail review had it; the owner had chosen to leave it), and #98, the checksum refusal speaks only in the checksum tool's voice with nothing naming the gate (new; no lane reviewer had raised it). Nothing in the code was found that the lane's own reviewers plus the trail review had not already found. After the chain rebase the verifier audited the resolved patch and found no line lost.

**What the owner rediscovered that a brief could have told it.**

- The reading list (AGENTS.md, the poteto-mode skill, ticket #42's table, PR #92's three rounds, five playbooks and skills): 14:30 to 14:35, about 5 minutes, all fetched fresh. Every owner did the same. A digest in the brief would have replaced it.
- That a lane ends when the owner ends its turn: 14:36 to 14:44, about 8 minutes (the lost how lane, the worktree rebuilt, the re-run). The brief at that time did not say it; the root added the rule to the brief after this owner and #89's had both hit it.
- That grounding findings are Act-on items: the blast-radius risks sat in the PR body from 15:33 while two review rounds (15:34 to 15:55, about 22 minutes of reviewer and fix-lane time) re-found two of them.
- The gate's own behavior on the download path: 15:55 to 16:02, about 7 minutes plus a CI cycle, because the fix was proven on the machine's own path. "Prove a fix on the branch CI takes" was not in the brief.

---

## Ticket #89, PR #94: put a design artifact on the ticket before implementation

Owner: fable, 14:30 to 16:08 (98 minutes). 12 delegates launched, plus 6 reviewers the three review lanes launched themselves.

| # | Role | Model | Asked, in one line | Ran | Returned |
|---|---|---|---|---|---|
| 1 | how explorer, mechanics (background) | opus | How patches, sync and the knowledge build work | 3.4 min | About 85% of its angle, then "my worktree was deleted"; unread by the owner |
| 2 | how explorer, flow (background) | opus | How a design artifact flows from planning to review today | 2.5 min | About two-thirds, then the same death |
| 3 | how explorer, mechanics (foreground) | opus | Same as 1 | 7.2 min | A 30K findings file |
| 4 | how explorer, flow (foreground) | opus | Same as 2 | 7.3 min | A 44K findings file |
| 5 | how explainer | opus | Synthesize the two findings files | 3.7 min | `how.md`, 239 lines |
| 6 | writer | fable | Implement the owner's design note, six commits | 11.7 min | Six commits; five open choices listed |
| 7 | spec-review round 1 lane | fable | Run the review skill | 8.3 min | Stalled with its reviewers still running; resumed by message; five Act-on items |
| 7a | Standards reviewer, round 1 | opus | Standards axis | 7.6 min | One hard finding, two breaches, two nits |
| 7b | Spec reviewer, round 1 | opus | Spec axis | 6.6 min | Four hard findings |
| 8 | fix lane, round 1 | fable | Fix the five items and the two Consider items | 7.6 min | Four commits |
| 9 | spec-review round 2 lane | fable | Round 2 | 6.4 min | Nothing to act on |
| 9a | Standards reviewer, round 2 | opus | | 1.9 min | Nothing hard |
| 9b | Spec reviewer, round 2 | opus | | 5.1 min | Nothing hard |
| 10 | trail review | opus | Cross-model audit of the decision trail | 3.2 min | Six flags |
| 11 | fix lane, verification | fable | Fix the three findings from the root's verification | 5.0 min | One commit |
| 12 | spec-review round 3 lane | fable | Round 3, on the verification fix only | 2.8 min | Nothing |
| 12a | Standards reviewer, round 3 | opus | | 0.8 min | Nothing |
| 12b | Spec reviewer, round 3 | opus | | 2.0 min | Nothing |

**Verdicts.**

- 1 and 2, the first two explorers: **wasted**. Killed when the owner ended its turn; their partial texts were never read.
- 3 and 4, the explorers again: **did the work**.
- 5, the explainer: **did the work**, and two of its facts decided the design: that "Ticket step 5" is quoted by name in four patches and a script, so the new rule went into step 6 rather than renumbering; and that a sixth core document costs one tuple in the build script, so the knowledge page became a core document rather than a generated page.
- 6, writer: **did the work**. One of its five open choices (the build script's own docstring still counting four documents) became a round-1 finding because the owner did not act on it.
- 7a, Standards round 1: **changed the outcome.** The new rule told an agent to post the table with a command that replaces the whole ticket body. An agent following the rule as written would have wiped What to build and the acceptance criteria from every ticket it touched, and the next Spec review would have read an empty spec and said nothing.
- 7b, Spec round 1: **changed the outcome.** The posted table carries example paths in backticks, and the overlap check reads every backticked token in a ticket body as a path the ticket names. Every later ticket carrying a table would have made the step-1 check print phantom overlaps, or refuse to start. Also: a failed post had no stop clause, and two documents still said "four core documents". (Standards had the paths finding too, as a nit.)
- 7, the round-1 lane itself: **did the work**, after stalling the same way the owner had an hour earlier.
- 8, fix 1: **did the work**.
- 9, 9a, 9b, round 2: **did the work**; nothing found.
- 10, trail review: **changed the outcome.** The PR body had no Overlap section: the check had been run only before the round-1 fix, and that fix made the PR touch the overlap script and its test, which PR #96 also touches. The owner re-ran the check and the section went in. It also flagged that the run had amended a closed, approved ticket (#42), and that the records commit was reviewed by nobody; both went into the report for Manuel.
- 11, fix 2: **did the work**.
- 12, 12a, 12b, round 3: **did the work**; nothing found, on a one-commit diff.

**The count.** 12 delegates (18 with the six sub-reviewers). Three found something radically important on their own: the round-1 Standards reviewer (the body wipe), the round-1 Spec reviewer (phantom overlaps), and the trail reviewer (the missing Overlap section).

**Review rounds and the root's verification.**

- Round 1 (Standards): the posting command replaces the ticket body; the rule now says read first, append, write the whole body back. Found by the lane; fixed.
- Round 1 (Spec, and Standards as a nit): a posted table's example paths feed the overlap check; the check now skips the two artifact sections. Found by the lane; fixed.
- Round 1 (Spec): a failed post did not stop the work; now it does. Fixed.
- Round 1 (Spec): two places still counted four core documents. Fixed. (The writer had listed one of the two as an open choice.)
- Round 2: nothing.
- Root's verification at 78be65e: three findings, all missed by three lane rounds and the trail review. First, the body said "PR #96 closes #88", and GitHub read that as this PR closing ticket #88: merging #94 would have closed #88 with its own PR still open. Second, the new section-skip stopped at the next second-level heading, so an artifact whose parts sit under sibling headings (as #42's does) still leaked its paths, and the amendment the lane had written on #42 claimed otherwise. Third, the body lacked the model-and-harness line. All three were fixed in one commit and re-verified.
- Round 3, on that fix: nothing.
- Nothing the lane's reviewers found was missed by the verifiers, because the verifiers read after the fixes. The verifiers' three findings were all missed by the lane.

**What the owner rediscovered that a brief could have told it.**

- The reading list: 14:30 to 14:33, about 3 minutes.
- That a lane ends when the owner ends its turn: 14:35 to 14:44, about 9 minutes of the owner's time plus two dead lanes. Then its round-1 review lane did the same thing (15:17 to 15:20, 3 minutes, resumed by message).
- That the posting command replaces the body: the brief itself said "appended to the ticket body with `gh issue edit N --body-file`" without the read-back. One line in the brief would have removed the round-1 hard finding and its fix commit: about 19 minutes (15:09 to 15:28).
- GitHub's linking rule for "closes" wording: the verification fix round, 15:56 to 16:07, about 11 minutes plus a CI cycle. One line in the brief ("never write closes or fixes beside another ticket's number") would have removed it.
- Waiting for the root's verification: 15:45 to 15:56, 11 minutes idle.

---

## Ticket #90, PR #99: return a design hole to architect and restart the rounds

Owner: fable, 15:39 to 19:04 (205 minutes; the last hour was the chain rebase and body corrections the root asked for, plus waiting). 19 delegates launched; none launched sub-lanes.

| # | Role | Model | Asked, in one line | Ran | Returned |
|---|---|---|---|---|---|
| 1 | how explorer 1 | opus | Trace the brief script | 5.0 min | Findings file |
| 2 | how explorer 2 | opus | Trace the comment script | 3.6 min | Findings file |
| 3 | how explorer 3 | opus | The prose and vendoring surfaces | 5.3 min | Findings file |
| 4 | how explainer | opus | Synthesize the three | 4.6 min | `explanation.md`, 49K |
| 5 | architect runner A | fable | Design the hole route on the frame | 12.5 min | Candidate A, the base |
| 6 | architect runner B | opus | Same | 9.9 min | Candidate B; four choices grafted |
| 7 | arena cross-judge | opus | Score, pick, name grafts | 6.5 min | A 17, B 14; one contract-grade error in B |
| 8 | writer | fable | Implement the posted table, tests first | 23.9 min | Three commits; nine flags |
| 9 | Standards reviewer, round 1 | opus | Standards axis | 4.9 min | One hard finding, marked a design hole |
| 10 | Spec reviewer, round 1 | opus | Spec axis | 6.4 min | One hard finding, marked a design hole |
| 11 | hole re-run runner A | fable | Redesign the two holes | 4.3 min | Amendment candidate |
| 12 | hole re-run runner B | opus | Same | 6.0 min | Amendment candidate |
| 13 | cross-judge, hole 1 | opus | Pick between the two rules for hole 1 | 1.8 min | A's rule |
| 14 | fix writer, holes | fable | Implement the amendments, tests first | 9.9 min | Three commits; nine notes |
| 15 | Standards reviewer, restarted round 1 | opus | | 5.5 min | One hard finding, two breaches, one nit |
| 16 | Spec reviewer, restarted round 1 | opus | | 6.5 min | Nothing |
| 17 | fix lane, restarted round 1 | fable | Fix the four items | 4.7 min | Three commits, including the records commit |
| 18 | Standards reviewer, round 2 | opus | | 5.7 min | Three nits |
| 19 | Spec reviewer, round 2 | opus | | 7.4 min | One note |

**Verdicts.**

- 1 to 3, explorers: **did the work**. The owner read the three files itself and wrote the seams into the runners' frame before the explainer finished.
- 4, explainer: **did the work**; the runners were given it as grounding.
- 5, architect A: **did the work**; became the design.
- 6, architect B: **did the work**; its babysit placement, the "Design hole" section in the Ticket playbook, the extra line in the brief's output and the two-axis table were grafted.
- 7, cross-judge: **changed the outcome.** It found that B's round-reset logic was wrong on the one path real PRs use: after a restart it would have printed round 2 where the contract says round 1, so the count would never actually restart. Had B been the base, or had its derivation been grafted, the feature the ticket exists for would not have worked on GitHub.
- 8, writer: **changed the outcome, and was not listened to.** Its flag 9 said: a judgment reason that merely contains the word "hole:" mid-sentence is refused as if it were a mark. The owner logged "none of its nine flags changes a cell" and opened the review; the round-1 Standards reviewer found the same thing and marked it a design hole, which restarted the review. Its flag 2 corrected a wrong note under the table (recorded as an amendment on the ticket).
- 9, Standards round 1: **rediscovered** the writer's flag 9, as the design hole that restarted the rounds. Also noted that the human's merge checklist still read the count alone.
- 10, Spec round 1: **changed the outcome.** The new rule demanded a reference to the spec on every hard finding, even in a review with no ticket, where there is no spec to reference. Every PR without a ticket would have been unreviewable. A row was missing from the table; the criterion was amended.
- 11, 12, hole re-run: **did the work**; they converged on hole 2 and diverged on hole 1.
- 13, hole cross-judge: **did the work**, with one useful catch: B's rule for hole 1 would have silently counted a near-miss mark as an ordinary fix on the PR, which is the one outcome the ticket forbids. A's rule won.
- 14, fix writer: **did the work**.
- 15, Standards restarted round 1: **did the work**; its findings were prose that had gone stale (the MANUAL's merge checklist, two decision rows) and a refusal message that inserted a space into what it echoed. Real, not radical.
- 16, Spec restarted round 1: **did the work**; nothing.
- 17, fix lane: **did the work**.
- 18, 19, round 2: **did the work**; nothing hard.

**The count.** 19 delegates. Two found something radically important on their own: the round-1 Spec reviewer (no-ticket reviews impossible) and the arena cross-judge (B's broken restart). A third, the writer, found the other design hole first; the Standards reviewer re-found it and got the credit.

**Review rounds and the root's verification.**

- Round 1 (Standards): a reason containing the word "hole:" is read as a mark. Judged a design hole (the term was undefined in the table); restart. Found by the lane; the writer had flagged it 25 minutes earlier.
- Round 1 (Spec): a review with no ticket cannot finish. Judged a design hole (a missing row); restart. Found by the lane.
- Restart: two runners, one judge, one fix writer; the mechanism ran on its own PR.
- Restarted round 1 (Standards): the MANUAL's merge checklist did not know about "restart"; decision rows P20 and P21 were stale; a refusal echoed the value with an inserted space. All fixed.
- Round 2: nothing hard.
- Root's verification at 0ff73f0, after the chain rebase: every gate and the live floor passed (the restart route exercised end to end with decoys). It asked for body-only corrections: the Verification paragraph still named pre-rebase commit ids, and two counts had moved with the rebase. The lane's reviewers could not have seen this (they ran before the rebase). Nothing in the code was found that the lane had missed; the notes carried were judgment calls (a marker on a continuation line is invisible by design; some table rows are covered by structure rather than by their own assertion).

**What the owner rediscovered that a brief could have told it.**

- The reading list: 15:39 to 15:43, about 4 minutes.
- The base: the root's note expected #94; the check printed #96 because #94's commits touch none of the paths #90 names. One minute, and the right call.
- That a writer's "edge outside the table" note is a hole candidate: the writer's flag 9 was accepted at 16:42 and re-found at 16:52; the restart route ran from 16:55 to 17:38 (three redesign lanes, a fix writer, a re-run round: about 43 minutes and 5 lanes). Half of that would have been spent anyway, since the ticket's own feature was exercised on its own PR by the restart, but the trigger was avoidable.
- That GitHub creates no CI run for a PR that conflicts with its base: 17:18 to 17:28, a 10-minute wait loop on a run that would never come, then the finding. The #91 owner hit the same wall at the same time; neither knew of the other.

---

## Ticket #91, PR #101: make the Spec walk cover every blast-radius risk

Owner: fable, 16:45 to 18:07 (83 minutes, including the chain rebase). 8 delegates launched. Note: this owner's trail carries timestamps it made up (it wrote "17:45:00Z" at 17:25 and "19:35:00Z" at 17:46); the minutes below come from the transcript.

| # | Role | Model | Asked, in one line | Ran | Returned |
|---|---|---|---|---|---|
| 1 | how lane | opus | Ground the review-brief script for the walk rule | 3.3 min | `how.md` |
| 2 | architect runner A | fable | Design the walk-per-risk rule | 10.1 min | Candidate; two extra rows taken |
| 3 | architect runner B | opus | Same | 7.1 min | Candidate; the placement of the sentence taken |
| 4 | writer | fable | Implement the posted table, tests first | 12.2 min | Three commits; seven decisions listed |
| 5 | fix lane, CI fixture | fable | Rewrite the workflow's own fake grounding to the new shape | 4.8 min | One commit |
| 6 | Standards reviewer, round 1 | opus | | 3.4 min | Two nits |
| 7 | Spec reviewer, round 1 | opus | | 4.7 min | Nothing; an eight-line walk |
| 8 | trail review | opus | Audit the trail | 1.9 min | Ten flags |

**Verdicts.**

- 1, how: **did the work**.
- 2 and 3, runners: **did the work**; they converged, so the owner skipped the judge and synthesized itself. Two cells came from one runner with no second look (the trail review flagged it; both cells have assertions).
- 4, writer: **did the work**.
- 5, fix lane: **did the work**. The finding was CI's, not a delegate's: the factory workflow's own fake grounding used the old bullet shape, and the new refusal fired on it.
- 6 and 7, round 1: **did the work**; nothing to act on.
- 8, trail review: **rediscovered**, mostly. Its main flag (the branch had never been built or reviewed on top of its real parent, which had moved) was already in the owner's report as the drift left for the root. Its useful sharpening: read "hard findings: 0" as a verdict on a snapshot, not on the branch's parent.

**The count.** 8 delegates. Zero found something radically important. The two real discoveries of this ticket were the owner's own, and both were about GitHub, not the code.

**Review rounds and the root's verification.**

- Round 1: nothing hard on either axis. Two Standards nits noted: the Ticket playbook describes a hand-back shape the blast-radius skill does not produce, and the skill's prose reads as if each heading level were tied to a source.
- CI, not a reviewer: the Fixture job's own grounding file was refused by the new rule. Fixed by a fix lane.
- Root's verification at 7956c69: every gate and the live floor passed; nothing found; notes only (the loose wording of the risk sentence; the vendored blast-radius skill still hands back bullets). After the chain rebase to d8e382c the resolved patch was re-verified and passed. Neither side found anything the other missed; there was nothing to find.

**What the owner rediscovered that a brief could have told it.**

- The reading list: 16:45 to 16:48, about 3 minutes.
- GitHub links "Closes #N" only on a PR whose base is the default branch, so PR #99 (opened against a feature branch) had no ticket link and the overlap check exited 1. 16:46 to 16:51, about 5 minutes of GraphQL digging, then the owner retargeted another lane's PR to main and back for eight seconds to mint the link, and filed ticket #100. The M0 findings file had recorded the rule on 2026-09-17; the brief did not carry it. The cost is not only the 5 minutes: it is a lane editing a PR that was not its own, which the brief forbids.
- The check's fallback base: the check printed `feat/shellcheck` because the chain had been rebased under #99 and containment was broken; the owner branched from #99 as the root's note said. One minute, and the right call, but the root could have said "the check may print a fallback; the parent is #99".
- That GitHub creates no CI run for a conflicting PR: 17:34 to 17:37, about 3 minutes, then a retarget-close-reopen dance to get a run.
- The writer's report was written inside its worktree because the harness refused the shared path; the owner's poll loop watched the shared path and found nothing for 7 minutes after the writer had finished (17:15 to 17:22).

---

## Ticket #93, PR #102: a Would-break fix gets another review round; five rounds stop for a report

Two owners. The first (fable, 17:49 to 18:15, 26 minutes) launched a how lane and two architect runners and was killed by the session limit ("You've hit your session limit") along with both runners. The second (fable, 19:09 to 20:46, 97 minutes) launched 9 delegates.

| # | Role | Model | Asked, in one line | Ran | Returned |
|---|---|---|---|---|---|
| D1 | how (first owner) | opus | Explain the round gate in both scripts | 7.4 min | `how.md`, 21K, saved under `prior/` |
| D2 | architect runner A (first owner) | fable | Design | 5.9 min | Killed: "session limit" |
| D3 | architect runner B (first owner) | opus | Design | 6.2 min | Killed: "session limit" |
| 1 | how (second owner) | opus | Same question, at the new base | 7.2 min | `how.md`, 54K |
| 2 | arena runner, fable | fable | Design the extra rounds | 20.9 min | Candidate, the base |
| 3 | arena runner, opus | opus | Same | 14.8 min | Candidate; six grafts |
| 4 | writer | fable | Implement the posted tables, tests first | 23.0 min | Three commits; an end-to-end run through rounds three to six; nine deviations |
| 5 | Standards reviewer, round 1 | opus | | 5.9 min | Three breaches, one nit |
| 6 | Spec reviewer, round 1 | opus | | 7.7 min | Nothing; walk of eighteen steps |
| 7 | fix lane, round 1 | fable | Fix the three breaches | 2.7 min | One commit |
| 8 | Standards reviewer, round 2 | opus | | 7.1 min | Three nits |
| 9 | Spec reviewer, round 2 | opus | | 7.4 min | Nothing |

**Verdicts.**

- D1, the first owner's how: **wasted**, in effect. It finished, but the second owner read it in one minute at 19:11, called it "input to verify, not to trust", and ran a fresh how lane at a base that had moved by four commits.
- D2, D3: **wasted**; killed at the session limit with nothing written.
- 1, how: **rediscovered** what D1 had, at the new base. Defensible (the base moved), but seven minutes of lane time and eight of the owner's waiting to re-derive a mechanism that had not changed in the parts that mattered.
- 2 and 3, arena runners: **did the work**; converged on one shape, so no judge. The second owner's synthesis note is the clearest record of a pick in the run (six grafts, four rejections, each with a principle).
- 4, writer: **did the work**, and did it well: it ran the whole mechanism end to end on a scratch repository through rounds three, four, five and the refused sixth. It also noted that the factory's own CI fixture step never reaches the new gate, which nobody acted on.
- 5, Standards round 1: **did the work**, usefully. Three breaches: the Ticket playbook licensed the fix-only round more widely than the skill does (a lane reading the playbook alone would have run a fix-only round where a whole-diff round was owed); the review ladder still said "of 3"; and an awk interval expression that older awks reject, the first in these scripts (a portability risk for the CI fixture and for a project on an old awk). Not radical, all real.
- 6, Spec round 1: **did the work**; nothing.
- 7, fix lane: **did the work**.
- 8 and 9, round 2: **did the work**; nothing hard. This round existed because the owner had wrongly declared the review over at round 1 with three marked fixes, then caught itself: Manuel's quote allows an unreviewed non-hard fix only from round three.

**The count.** 9 delegates for the second owner (12 with the dead lane's three). Zero found something radically important; one (the round-1 Standards reviewer) found three things worth fixing. The most important catch of this ticket was the owner catching its own wrong call.

**Review rounds and the root's verification.**

- Round 1 (Standards): the playbook's fix-only rule was wider than the skill's; the ladder's round cap was stale; an awk construct with a portability cost. Found by the lane; fixed.
- The owner's own correction: the round-1 comment said the review could end there; the owner ran round 2 from the same fixed point and said so in round 2's comment. The round-1 sentences stand as posted.
- Round 2: nothing hard.
- Root's verification at fc75ac6: every gate and the live floor passed (rounds four and five allowed, a sixth refused, a round-three PR printing byte for byte what it printed before). Nothing blocking. Notes for Manuel: three table rows have no direct assertion of their own; the round-1 comment reads as review-ready to babysit, which is the class of failure this ticket closes for later rounds (the verifier saw it; the owner had already corrected it by hand); the round-five stop (converting the PR to a draft) is provisional and has no dated M0 line; P29 (written by the #91 owner: open a stacked PR against trunk, then retarget) contradicts how the root actually linked this PR. Neither side missed anything the other found.

**What the owner rediscovered that a brief could have told it.**

- The first owner's 26 minutes and three lanes were lost to the session limit, which is the harness's, not the owner's; the trail and how output survived under `prior/`.
- The second owner's reading list plus the prior scratch: 19:09 to 19:14, about 5 minutes; then a fresh how lane anyway (7 minutes, plus 8 minutes waiting). Had the root's brief said "the prior lane's how.md is trusted grounding; only re-check the lines the base moved", the arena could have started at 19:14 instead of 19:22.
- Its own rule about when a review may end: the wrong sentence at 20:35, corrected at 20:36 by launching round 2. No time lost that the rule did not require, but the posted record carries a wrong sentence.
- Half the trail's rows carry local-clock timestamps beside UTC ones; cosmetic, and a sign the trail was written from memory in places.

---

## Across the five tickets

### The delegates that mattered most, ranked

1. **#88's blast-radius lane** (fable, 9 minutes). Found the unchecked cached binary and the silently dropped glob before any review did. If its risks had been treated as Act-on items, rounds 1 and 2 of PR #96 would have had nothing hard to find.
2. **#89's round-1 Standards reviewer** (opus, 8 minutes). The body wipe: the new rule as written would have deleted the acceptance criteria from every ticket an agent posted a table on.
3. **#90's round-1 Spec reviewer** (opus, 6 minutes). A review with no ticket could never finish; every ticketless PR would have been unreviewable.
4. **#88's round-2 Standards reviewer** (opus, 3 minutes). A path with a space was refused; Manuel's own checkout has one.
5. **#88's trail review** (opus, 4 minutes). The wedge: one bad download and the gate fails forever. Also the temp-directory race and the unwritten addendum.
6. **#89's round-1 Spec reviewer** (opus, 7 minutes). Phantom overlaps: every later ticket's step-1 check would have counted the table's example paths.
7. **#90's arena cross-judge** (opus, 7 minutes). B's restart count was wrong on the path real PRs use; kept it out of the design.
8. **#89's trail review** (opus, 3 minutes). The PR body had no Overlap section after the fix that created the overlap.
9. **#90's writer** (fable, 24 minutes). Flag 9 was the design hole that restarted the review; the owner did not read it as one.
10. **#93's round-1 Standards reviewer** (opus, 6 minutes). A playbook rule wider than the skill's, and a portability risk.

Three trail reviews ran (#88, #89, #91); all three found something the owner had wrong, at 2 to 4 minutes each. That is the best return of any lane kind in the run.

### The patterns of wasted lanes

- **Lanes killed by the owner ending its turn.** Four lanes died this way (#88's first how, #89's two explorers, and the partial loss of #88's worktree), and two review lanes stalled the same way (#88 round 1, #89 round 1) and needed the owner or a message to finish. About 12 minutes of lane time and 20 of owner time. The root rewrote the brief mid-run ("never end your turn to wait; poll for the file"), and no later owner hit it.
- **Lanes killed by the session limit.** The first #93 owner and both its architect runners: 26 minutes plus 12 of lane time, nothing usable except a how file the next owner did not trust.
- **Exploration run twice.** #88 ran how twice (once dead); #89 ran both explorers twice (once dead); #93's second owner re-ran how over a base that had moved four commits while the mechanism had not.
- **Reviewer pairs that returned nothing.** Of the 24 reviewer lanes in the run (two axes per round), 10 produced a finding that led to a fix. 14 returned no hard finding at all: #88 round 3, #89 rounds 2 and 3, #90 round 2 and the Spec side of the restarted round 1, #91 round 1, #93 round 2, and the Spec side of #93 round 1. Most of those rounds were owed by a rule (the round after a Would-break fix, the round after a verification fix), so they are the price of the rule, not waste; but at the review cost floor (about 46K tokens per reviewer before it reads a line) those 14 lanes are the single largest spend that found nothing.
- **The Spec axis re-finding the Standards axis.** In #88 rounds 1 and 2, both reviewers found the same item. The Spec reviewer's distinct value showed only where a criterion or a table row was missing (#89 round 1, #90 round 1).
- **Grounding produced and not acted on.** #88's blast-radius risks and #90's writer flag 9 were both in the owner's hands before the review opened, and both were re-found by reviewers at the cost of a round (and in #90, a restart). Neither was a lane failure; both were the owner treating a delegate's report as something to file rather than something to fix.

### What the root could have put in each brief

In the order of minutes it would have saved, across the run:

1. **A digest of the required reading.** Every owner spent 3 to 5 minutes fetching ticket #42's table, PR #92's three rounds, the playbooks and the skills, and the second #93 owner spent 5 more re-reading the first owner's scratch. About 25 minutes across six owners; a one-page digest in the brief covers it.
2. **The GitHub facts the run kept hitting.** Three rules, each already known somewhere: "Closes #N" links only on a PR whose base is the default branch (M0 had it since 2026-09-17; cost #91 five minutes, an edit to another lane's PR, ticket #100, and the root's own retarget for #93); a "closes" word beside any other ticket's number links that ticket (cost #89 a fix round, 11 minutes); Actions creates no run for a PR that conflicts with its base (cost #90 a 10-minute wait and #91 a retarget-close-reopen).
3. **"Grounding findings are Act-on items."** A risk in the blast-radius file, a writer's "edge outside the table" note, a writer's open choice: fix or answer before the review opens. Would have removed #88's rounds 1 and 2 hard findings (about 22 minutes of lane time) and #90's restart trigger (about 43 minutes, though the restart also exercised the feature).
4. **One line on the posting command.** "`gh issue edit --body-file` replaces the body: read it, append, write it back whole." The brief named the command without it; #89's round-1 hard finding and fix (19 minutes).
5. **"Prove a fix on the path CI takes."** #88's fix lane proved on the machine's path; one CI cycle and a fix lane (7 minutes).
6. **The parent, as decided, and that the check may print a fallback.** Both #91 and #93 saw the check print `feat/shellcheck` after the chain was rebased under #99. Each decided right in a minute, but the brief's "branch from exactly what the check prints" contradicted the root's topology note, and both owners had to choose which to break.
7. **The never-end-your-turn rule from the start.** It reached the brief after #88 and #89 had paid for it.

### The one change per ticket that would have cut the most time

- **#88.** Treat the blast-radius risks as Act-on items before opening the review. Saves the hard findings of rounds 1 and 2, four reviewer lanes and two fix lanes: about 25 minutes of lane time and one CI cycle.
- **#89.** Two lines in the brief: the posting command replaces the body; never write "closes" beside another ticket's number. Saves the round-1 fix cycle and the verification fix round: about 30 minutes and two review rounds.
- **#90.** Read the writer's flag 9 as a hole candidate and settle it before the review. Saves the restart trigger: about 43 minutes and five lanes, minus whatever the restart was worth as a live test of the feature (the verifier counted that live run as evidence, so call it half).
- **#91.** Put the two GitHub rules in the brief. Saves about 10 minutes, the edit to another lane's PR, and ticket #100's discovery cost; the fixture CI failure (6 minutes plus a fix lane) would have been caught if the how lane had been asked to list every caller of the grounding shape.
- **#93.** Hand the second owner the first owner's how file as trusted grounding, with the four commits the base moved by. Saves the how re-run and the wait: about 15 minutes. The 26 minutes the first owner lost to the session limit are the root's to avoid by starting the last lane with headroom.
