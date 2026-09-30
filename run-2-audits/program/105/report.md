PR #120 writes the first stack run's speed lessons into the playbooks. It passed four review rounds (the last with `act-on items: 0`) and CI is green at its head. One fact the ticket asked the playbooks to state did not hold in this run: this owner did receive its lane's completion notification while it was polling. Manuel should read that item under Blocked.

## Status

STACK-READY.
- Head: `e090a3880f1914fc327822c1618492dbad59ccf8`. `git rev-parse HEAD` and `git ls-remote origin refs/heads/feat/speed-lessons` agree.
- Branch: `feat/speed-lessons`. PR: https://github.com/Zenoctra/factory918/pull/120, base `main`, ready, MERGEABLE.
- Patch base: `86d156a` (origin/main). Intended parent: `main`.

## Overlap

Step 1, `overlap.sh 105`:
```
go: autopilot-stack
base: origin/main
```
Step 8, `overlap.sh 105 --diff` at e090a38, exit 0. The output is in the PR body under `## Overlap`:
```
go: autopilot-stack
#121 feat/provisional-ticket-ids: AGENTS.md docs/M0-findings.md docs/agents/ledger.md docs/knowledge/INDEX.md docs/knowledge/core/DECISIONS.md template/.agents/skills/poteto-mode/playbooks/ticket.md template/docs/factory918/DECISIONS.md
#124 feat/reviewer-model-eval: SOURCES.md patches/series
```
The root resolves these shared paths when it builds the chain. The record files are append-only, and `ticket.md` and `patches/series` are the likely conflicts.

## Criteria

1. Digest step: `ticket.md` step 0. `grep -c "replaces the body"` prints 2. The count was already 1 at HEAD.
2. Autopilot-stack steps 1, 6 and 7: `autopilot-stack.md` lines 5, 10 and 11.
3. Act-on list, naming #108: Feature, Bug fix, Refactoring and Perf issue at their delegate steps.
4. Poll rule: stated in Ticket step 0 and pointed to from every step that launches a lane, including skill fan-outs (fixed in round 3, e090a38). The dated line is in `docs/M0-findings.md`.
5. Round one at the first push: `opening-a-pr.md` "PRs" and Ticket step 8. Round two also asked for the four docs that contradicted this (f810542).
6. `gh run watch`: `babysit.md` step 6 and Ticket step 8. The `sleep 60` grep prints nothing, and it printed nothing at HEAD either.
7. Blast radius beside the writer: Ticket step 5, checked again at step 8.
8. `no-stale-wording.sh` retires "table unchanged". It prints ok, and the writer proved it fails when the phrase is added. The phrase never existed on `main`.
9. `./factory918.sh sync` leaves the working tree clean. All changed patches regenerate byte for byte (`.scratch/105/regen-check.sh` in the owner worktree, bad=0).
10. Trail review on every PR: Ticket step 9. It also ran on this PR.
11. ShellCheck arguments: `opening-a-pr.md` "PRs", with the default globs quoted from `.github/shellcheck.sh`.
12. `AGENTS.md` "Verifying" lists the test.
13. Proving on the path CI takes: `feature.md` step 5 and `bug-fix.md` step 4.
14. Exact absolute path: the poll rule in Ticket step 0.
15. Registry times from `date`: `autopilot-stack.md` step 2.
16. A closed ticket's design record: the last section of `ticket.md`.

## Reviews

- Round 1: https://github.com/Zenoctra/factory918/pull/120#issuecomment-5788196963, `act-on items: 3`. The fixes were the babysit `/loop` wake inside a lane (57a075a) and marking P29 as amended (c38b01b).
- Round 2: https://github.com/Zenoctra/factory918/pull/120#issuecomment-5788668200, `act-on items: 3`. The fixes were the green-CI wording in four docs (f810542) and scoping and retitling the P29 amendment (0b1f96a). The first round-two lane produced nothing in about 45 minutes. It was told to stop, and a fresh lane posted the round.
- Round 3: https://github.com/Zenoctra/factory918/pull/120#issuecomment-5788792937, `act-on items: 0`, with one Would-break item fixed first (e090a38). The comment printed `would-break fixed after f810542`.
- Round 4 (fix only, fixed point f810542): https://github.com/Zenoctra/factory918/pull/120#issuecomment-5788849068, `round: 4 of 5`, `act-on items: 0`, no restart line and no would-break line.
- There were no restarts.

## CI

Run 35816676418 at head e090a3880f1914fc327822c1618492dbad59ccf8 concluded success. Earlier heads were also green: 35812218937 at 8ce184c, 35812534232 at 57a075a, 35813880121 at d530b74 and 35816242409 at f810542.

## Records

- `docs/knowledge/core/DECISIONS.md` P105 (first numbered P31, renamed at the root's request in d530b74). It records where the lessons live, the root's retarget under autopilot-stack, and the rewrite exception.
- P29 has a new title ("A stacked PR's ticket is linked through trunk") and this appended line: "Amended 2026-09-22 (#105, P105): under autopilot-stack the root, not the owner, does the retarget through trunk and back, and an owner opens its stacked PR against the parent branch and never retargets; a lane on its own `stack #N on #M` run still opens against trunk and retargets itself."
- `docs/agents/ledger.md`: this run's owner received its writer's completion notification while polling inside its turn.
- `docs/M0-findings.md`, dated 2026-09-22: the notification finding with the run-2 counter-observation, and the finding that Actions creates no run for a conflicted PR (#101).
- The record edits are the owner's own, per P11's path split. All prose under `template/`, `AGENTS.md` and `MANUAL.md` came from lanes.

## Decided

- The poll rule is stated once, in Ticket step 0, and the other playbooks point to it. That added eleven new patch files. Only the root may end its turn on a `/loop` wake.
- The root may rewrite a branch another open PR branched from only when the same step rebases that PR and every PR above it. Without this exception, step 7's drift rebase would contradict step 6.
- The STACK-READY report headings are Head, Criteria, Review, CI and Flags. The writer chose them, because the ticket fixed none.
- The four contradicting "after CI is green" docs were fixed on this PR at round two's request, so this PR does the work of #119. I commented on #119 and left closing it to the root.
- The digest step lets a non-stack agent write its own digest. No step yet tells the root to put the digest in each owner's brief (review Noted S2, trail flag 5). I left this as a gap.
- The falsifiability note, that two grep sub-checks already passed at HEAD and "table unchanged" never existed, went out after the work, in this report, rather than before it.

## Blocked

- For Manuel: the ticket's fact that "a child lane's completion notification reaches the root session, never the owner" did not hold in this run. This owner received notifications for its writer, fix and review lanes while it was polling inside its turn. The playbook states the fact as the ticket worded it. The poll rule is correct either way. Nobody retested whether an owner that has ended its turn is woken. If the fact is wrong, the digest bullet should be reworded.
- For the root: #119 is now redundant, and it should close it or tie it to #120.

## Trail

`/Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.scratch/program/105/decisions.tsv`. The trail review is `trail-review.md` beside it, reviewed by Claude Opus 5, with ten flags, each settled in the trail's last rows.
