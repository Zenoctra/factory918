# Todo for ticket #91 (owner lane)

## Ticket playbook
- [x] T1 clean checkout, origin fetched, overlap.sh 91: first run exit 1 (PR #99 unlinked to #90; GitHub links only default-branch PRs; #99 retargeted main and back, ticket #100 filed); second run exit 0, `base: origin/feat/shellcheck` (containment broken by #96's rebase under #99); branched from origin/feat/design-hole-restart per the root's parent, deviation recorded
- [x] T2 read the ticket; no Parent; worked examples #42 Testing decisions and PR #92 read
- [x] T3 Blocked by #42: closed (PR #92 merged 2026-09-22)
- [x] T4 falsifiability pass: falsifiability.md (criterion 3 already passes at HEAD; kept as a regression check, noted for the human)
- [ ] T5 Feature selected; how lane launched; blast-radius: n/a, the diff touches no `.claude/hooks/`, `settings.json` or factory918 skill file (the predicate at review-brief.sh); a light reach paragraph goes in the PR body as PR #99 did
- [ ] T6 Testing decisions: scenario table on ticket (Run under rule 2), tests before implementation
- [ ] T7 verify on matching surface
- [ ] T8 overlap.sh 91 --diff -> ## Overlap in PR body; Opening a PR
- [ ] T9 babysit to merge-ready (never merge)

## Feature playbook
- [x] F1 how lane (opus): how.md
- [x] F2 architect: two runners (fable, opus) converged; judge skipped; table posted on #91 under ## Testing decisions 2026-09-22 (testing-decisions.md)
- [x] T6 Testing decisions posted before any code; writer launched with tests-first commit order
- [x] F3 throughput checkpoint:
  - Blocking first steps: overlap check and branch (done); how + two architect runners fan out together; the table is posted on the ticket before any code; the writer starts only after the table is posted.
  - Independent workstreams: n/a for writing: one script, one test, two patches and SOURCES.md are one concern and one writer; reviewers (Standards, Spec) run in parallel later.
  - Shared mutable state: the writer works in its own worktree on `wt/91-writer`; I fast-forward `feat/spec-walk-risks` onto it; nobody else writes that branch. The report directory is written by lanes at distinct file names only.
  - Smallest safe decomposition: one writer, because the test assertions and the script's rule text must agree word for word and the SKILL.md patch pins the same sentence; splitting would serialize on that string anyway.
- [x] F4 writer lane (fable) on wt/91-writer; diff reviewed, fast-forwarded to 6add1e3; no fix needed
- [x] F5 verified: every AGENTS.md Verifying line green at 6add1e3 and 469f78d
- [x] F6 commits: ccf5bf6 tests, c0761dd script, 6add1e3 prose, 469f78d records
- [x] F7 interrogate: skip: the two architect candidates converged; nothing contested
- [x] F8 Opening a PR: PR #101 draft, opened against main then retargeted to feat/design-hole-restart
- [x] CI fix: Fixture job's blast.md fixture lacked a Risks heading (run 35760574314); fix lane wt/91-fix1, commit 7956c69, pushed

## Opening a PR
- [x] O1 deslop over diff (nothing to remove); unslop over the body (no tells); technical-writing layers applied by hand
- [x] O2 shellcheck per changed file and the 20-file gate, clean
- [x] O3 draft PR #101 opened against main (link), retargeted to feat/design-hole-restart
- [x] O4 CI green on 7956c69 (run 35761775682, via a main retarget + reopen since the PR conflicts with its moved base); spec-review round 1: 0 hard findings, act-on items: 0, comment posted after review-comment.sh exit 0
- [x] O5 gh pr ready done after CI green
- [x] T8 overlap.sh 91 --diff recorded in ## Overlap (exit 0)
- [x] T9 babysit: skip: the brief says no babysit; never merge; drift on #99 reported to the root in report.md
- [x] O6 records commit 469f78d (DECISIONS P26, P27; ledger; M0)
- [x] O7 report.md written (STACK-READY at 7956c69; trail reviewed by opus, trail-review.md)
