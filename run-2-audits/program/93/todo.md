# Todo for #93 (owner lane)

## Brief step 0
- [x] Invoke poteto-mode with "#93"
- [x] Read session-mandate.md, DECISIONS P11 P14 P20-P24
- [x] Read Principles section of poteto-mode in full

## Ticket playbook
- [x] T1 fetch origin; status clean; overlap.sh 93 exit 0, base: origin/feat/spec-walk-risks (= d8e382c, PR #101); branched feat/would-break-extra-rounds
- [x] T2 read ticket #93; #42 Testing decisions; PR #92 + 3 review comments; #90's tables; PR #99/#101 bodies
- [x] T3 Blocked by #42: CLOSED
- [x] T4 falsifiability: C1 C2 C3 C5 C6 fail at base (greps); C4 a regression guard, noted
- [x] T5 select Feature; how launched; cross-cutting predicate does not fire (no hooks/, settings.json, factory918 skill path) -> blast-radius skip: not cross-cutting; PR body's Blast Radius section grounds it as PR #101 did
- [x] T6 tests written from the table first (commit 41ce420 before 27c43af)
- [x] T7 verified in the owner worktree: all AGENTS.md Verifying lines green
- [x] T8 overlap --diff exit 0 (recorded); PR #102 opened as a draft against feat/spec-walk-risks, Closes #93
- [x] T9 merge-ready: two rounds, act-on items 0 on the latest commit, CI green, PR ready; never merged

## Feature playbook
- [x] F1 how: explainer lane (opus) done, 886 lines verified at d8e382c, worktree .scratch/program/93/how/how.md
- [x] F2 architect: arena run (fable base, six grafts from opus, no judge: convergence), synthesized table posted on ticket #93
- [x] F3 throughput checkpoint:
  - Blocking first steps: how -> arena -> synthesized table posted on the ticket -> writer (tests from the table, then scripts, then prose) -> owner review -> shell gate + tests -> push -> draft PR -> CI -> spec-review rounds -> records commit.
  - Independent workstreams: n/a for the code; the comment strings, the brief's regexes, the tests and the prose pin the same bytes, so one writer owns tests, scripts and prose. The owner's records (DECISIONS Provisional, ledger, M0) are a separate last commit by the owner (P11).
  - Shared mutable state: one writer worktree on wt/93-writer; the owner fast-forwards feat/would-break-extra-rounds onto it; fixes after review are new commits by a fresh writer lane on the same branch, one at a time.
  - Smallest safe decomposition: one writer, because splitting prose from code would have two lanes pin the same strings and drift; review lanes (standards, spec) fan out later per spec-review.
- [x] F4 writer (fable, worktree) done: 3 commits, diff reviewed, ff-merged
- [x] F5 verified on the matching surface (tests + writer e2e run)
- [x] F6 commits ordered: tests, scripts, prose, records
- [x] F7 interrogate: skip: the two architect candidates converged on one shape, the design is not contested
- [x] F8 Opening a PR: draft PR #102

## Brief extras
- [x] scenario table appended to ticket body (Posted by the agent 2026-09-22), read-back matches
- [x] shellcheck -x on 5 changed files; the 20-file gate clean
- [x] every Verifying line green (648, 192, stale ok, 55, 57, 17, knowledge 119 clean, sync clean)
- [x] draft PR #102 opened within minutes of the push; ready after review
- [x] spec-review rounds 1 and 2 after CI green; rule 7 not triggered (no Would-break finding)
- [x] records commit 7b01fd6 (P20 amended, P30, ledger)
- [x] scratch mirrored to the shared report dir; report.md written
