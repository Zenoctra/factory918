# Verifier: receipts-and-diff audit, PR #120 at e090a38

verdict: PASS+NOTES

The change does what ticket #105 asked, all sixteen criteria are met in the tree at this SHA, the vendored
edits all go through `patches/` and reproduce byte for byte, and the receipts on the PR match what the brief
described. Two things need a person: #119 is now redundant but is still open and labelled `ready-for-agent`
with nothing linking it to this PR, and the PR body miscounts the regenerated patches (19, actually 20).

## Setup

- `git fetch origin feat/speed-lessons main`, `git checkout --detach e090a388...` → `git rev-parse HEAD`
  prints `e090a3880f1914fc327822c1618492dbad59ccf8`. exit 0.
- `git merge-base --is-ancestor 86d156a HEAD` → exit 0. Patch base confirmed.
- Diff read whole with `git diff -U0 --word-diff=plain 86d156a..e090a38`, split into the non-playbook set
  (17 KB) and the playbook set (46 KB); 54 files, 301 insertions, 83 deletions.

## 1. Acceptance criteria against the diff

All sixteen met. Evidence at this SHA:

- **C1, the digest.** `template/.agents/skills/poteto-mode/playbooks/ticket.md:5-9` adds step 0 with the
  required reading, the three harness/GitHub facts and the `--body-file` fact.
  `grep -c "replaces the body" …/ticket.md` → `2`, exit 0 (≥1 asked). The owner disclosed that the count was
  already 1 at HEAD (step 6's pre-existing sentence), so the criterion's grep was not falsifying; step 0 is
  present on its own terms.
- **C2, autopilot-stack.** Step 1 at `autopilot-stack.md:5` ("An owner's first action is invoking the
  poteto-mode skill, then reading the digest (Ticket step 0)…"). Step 6 at `:10` carries all three: the root
  "never rewrites a branch another open PR branched from, unless the same step rebases that PR and every PR
  above it"; "Owners start one at a time, each from the settled tip of the chain"; "Until #100 lands, the root
  retargets each stacked PR through `<trunk>` and back once … an owner never retargets". Step 7 at `:11`
  carries the rebase-then-verify rule and the one-page STACK-READY report with the five fixed headings
  (`## Head`, `## Criteria`, `## Review`, `## CI`, `## Flags`).
- **C3, act-on list.** `feature.md:12`, `bug-fix.md:9`, `refactoring.md:11`, `perf-issue.md:16`, each with the
  same sentence naming #108.
- **C4, poll rule on every lane-launching step + M0 line.** Verified independently, not from the PR body:
  of the 24 playbooks, exactly three contain no "poll rule" string — `authoring-a-skill.md`, `pause-safely.md`,
  `prototype.md` — and a grep of those three for `subagent|parallel|fan.out|delegate|lane|arena|swarm|spawn`
  returns only two false positives ("delete; prose", "Start nothing"), so none of them launches a lane. The
  dated M0 line is `docs/M0-findings.md:188-189`.
- **C5, round one at the first push.** `opening-a-pr.md` "**PRs.**" paragraph and `ticket.md` step 8, both
  with "a green CI is required before merge-ready and STACK-READY, not before round one".
- **C6, `gh run watch`, no sleep loops.** `babysit.md:14` ("Any other CI wait is `gh run watch <run-id>
  --exit-status` or the harness's Monitor on the run; never a sleep loop") and `ticket.md` step 8.
  `grep -rn "sleep 60" template/.agents/skills/poteto-mode/playbooks/` → no output, exit 1.
- **C7, blast radius beside the writer.** `ticket.md` step 5: "once `how` and the design with its table exist,
  run `blast-radius` over them beside the writer lane, not after it"; and "Step 8 checks that section against
  the final diff", with step 8 carrying the check.
- **C8, Spec axis never skipped; test retires the phrase.** `bash tests/spec-review/no-stale-wording.sh` →
  `ok: no stale wording`, exit 0. Negative proof run by me: writing `skip when the table unchanged` into a
  throwaway file under `template/.agents/skills/poteto-mode/playbooks/` makes it print the file:line and exit 1
  (file removed afterwards). A grep for skip-the-Spec-axis wording across `template/.agents/skills/`,
  `template/docs/` and `docs/knowledge/core/` returns only `spec-review`'s legitimate "no spec: Standards axis
  only" path. `opening-a-pr.md` adds "A round with a ticket runs both axes, whatever the diff since the last
  round changed."
- **C9, sync clean and patches reproduce.** `./factory918.sh sync` → exit 0, then `git status --porcelain`
  empty. All 20 changed patches regenerated with the `patches/README.md` command against
  `research/3-pstack/open-pstack-claude-code-port/plugins/pstack/skills/…` and compared with `cmp`: 20 OK,
  0 different.
- **C10, trail review.** `ticket.md` step 9.
- **C11, ShellCheck arguments.** `opening-a-pr.md` "**PRs.**" names the changed files as arguments and quotes
  the bare form's globs. I checked the quoted globs against the script it refers to:
  `template/.github/shellcheck.sh:37` sets exactly `'.claude/hooks/*.sh' '.agents/skills/*/scripts/*.sh'
  '.github/shellcheck.sh'`. Match.
- **C12, Verifying list.** `AGENTS.md:44`.
- **C13, the path CI takes.** `feature.md` step 5 and `bug-fix.md` step 4.
- **C14, exact absolute path.** `ticket.md` step 0, second bullet, with the PR #101 seven-minute example.
- **C15, `date` on registry lines.** `autopilot-stack.md:6` (step 2).
- **C16, a closed ticket's design record.** New `### A closed ticket's design record` section at the end of
  `ticket.md`, with the append-only rule, the line format, `--body-file`, and the `## Records` requirement.

## 2. Scope

Grouped, 54 files:

- Playbook prose (21 files under `template/.agents/skills/poteto-mode/playbooks/`) and the 20 patches that
  carry the vendored 20 of them. In scope: the ticket names these files.
- `patches/series` (+11 lines), `SOURCES.md` (item 16). Required by the vendoring rule; in scope.
- `docs/M0-findings.md` (two dated findings). Named by the ticket; in scope.
- `docs/agents/ledger.md`, `docs/knowledge/core/DECISIONS.md` (P105 added, P29 retitled and amended),
  `docs/knowledge/INDEX.md`, `template/docs/factory918/DECISIONS.md`. Not in the ticket's file list, but
  `AGENTS.md` "Pull requests" requires both records; in scope.
- `tests/spec-review/no-stale-wording.sh`. The ticket's "one test that greps for retired wording"; in scope.
- The four "after CI is green" documents: `AGENTS.md`, `template/AGENTS.md`,
  `template/docs/agents/review-ladder.md`, `docs/knowledge/core/MANUAL.md` (plus its generated
  `template/docs/factory918/MANUAL.md`). **Judgment: in scope.** This PR is what made those four lines
  contradict the playbooks, and round two raised it as a Would-break item on both axes
  (`act-on` 1 of round 2). A PR that leaves a contradiction it created is not a clean change; fixing it here
  is the narrower action, and the diff is five lines.
- **#119 is now redundant.** Its criterion 1 grep,
  `grep -rn "After CI is green\|Once CI is green" AGENTS.md template/AGENTS.md template/docs/agents/
  docs/knowledge/core/`, prints nothing at this SHA (exit 1). Its criterion 2 (build clean, check passes)
  holds. Its criterion 3, "`docs/agents/review-ladder.md` matches its template copy", is vacuous: there is no
  `docs/agents/review-ladder.md` in this repo (`ls docs/agents/` → `domain.md issue-tracker.md ledger.md
  triage-labels.md`), so nothing can drift. See Issues for what is left to do about it.

## 3. Vendored edits go through patches

- 21 changed files under `template/.agents/skills/`. 20 are vendored and each has a patch in
  `patches/` listed in `patches/series` (11 new lines, the rest pre-existing entries).
- The 21st, `ticket.md`, is ours, not vendored: `patches/README.md` says so ("The session mandate … and
  `ticket.md` are ours, not patches") and `SOURCES.md` item 2 records it as added by `sync`.
- Independent proof, not taken from the docs: `./factory918.sh sync` re-copies the pins and re-applies
  `series`, and it left `git status --porcelain` empty. A vendored edit without a patch would have been
  reverted and shown up as a modification.
- `SOURCES.md` item 16 is the next free number (existing items run 1–15; the 9/10/11 ordering wobble at
  `SOURCES.md:21-23` predates this PR).

## 4. Receipts

- Four PR comments, all from `Zenoctra`, in order: `round: 1 of 3` / `act-on items: 3`;
  `round: 2 of 3` / `act-on items: 3`; `would-break fixed after f8105426da8226ba7780ba8f0a64c7334d096c1e` +
  `round: 3 of 3` / `act-on items: 0`; `round: 4 of 5` / `act-on items: 0`. Matches the brief exactly.
- Round 1's three act-on items map to commits in the log: item 1 (babysit's `/loop` wake inside a lane) →
  `57a075a`; items 2 and 3 (P29 unmarked in both DECISIONS copies) → `c38b01b`. Both present in the diff
  (`babysit.md:14`'s new clause; P29's "Amended 2026-09-22 (#105, P105)" in both copies).
- Round 2's three act-on items: item 1 (four docs still gate round one on green CI) → `f810542`; items 2 and 3
  (scope the amendment to autopilot-stack, reword the title) → `0b1f96a`. Both visible in the diff; P29's title
  is now "A stacked PR's ticket is linked through trunk".
- Round 3: one Would-break item (architect/interrogate fan-out steps carry no poll pointer), marked
  `fixed: e090a3880f1914fc327822c1618492dbad59ccf8` on the judgment line, count 0 as the rule allows.
- Round 4's fixed point is `f8105426da8226ba7780ba8f0a64c7334d096c1e`, which is the commit round 3 reviewed
  (round 3's `would-break fixed after` names the same SHA). Correct per the review-ladder rule.
- Round 4's three findings are all under Standards "Fix alongside" and judged Noted (`noted 3`), so nothing was
  left unfixed that should have been fixed.
- CI: `gh pr checks 120` → Factory pass 46s, Fixture pass 34s. `gh run view 35816676418 --json
  headSha,conclusion,event` → `headSha` `e090a388…`, `conclusion` `success`, `event` `pull_request`. Green at
  the head, not at an earlier one.
- `gh pr view 120 --json headRefOid,baseRefName,mergeable,isDraft,closingIssuesReferences`:
  head `e090a3880f1914fc327822c1618492dbad59ccf8`, base `main`, `MERGEABLE`, not a draft, closing references
  exactly one issue, #105.

## 5. PR body shape

Conforms to `AGENTS.md` "Pull requests" at this SHA.

- Title "Write the first stack run's speed lessons into the playbooks": a plain sentence, no `type(scope):`.
- Opens with the problem (the run's waits), then the fix, in the first paragraph.
- `## Blast Radius` present and contains no `## ` heading (three sentences of prose). The body itself states the
  diff touches no cross-cutting path, so the section is voluntary; having it does not break the section rule.
- `## Overlap` sits immediately before `## Verification`. Order correct.
- Verification names outcomes, not just commands (`prints 2`, `prints nothing`, `exits 1`, `ok: no stale
  wording`, run id `35816676418`), one bullet per criterion.
- `Closes #105` is the last line before the attribution; attribution, then `Claude Opus 5.5 on Claude Code`
  last. Correct order.

## 6. Forbidden and generated files

- `git diff --name-only 86d156a..e090a38 | grep -E '^(research/|docs/knowledge/(spec|pages|notes)/)'` → no
  output, exit 1. Nothing hand-edited in the read-only or generated trees.
- `python3 tools/build_knowledge.py` → `knowledge files: 119 → docs/knowledge`, then `git status --porcelain`
  empty. `tools/build_knowledge.py:126` writes `template/docs/factory918`, so the committed copies of
  `DECISIONS.md` and `MANUAL.md` there match a rebuild exactly. `python3 tools/check_knowledge.py` →
  `knowledge ok: 119 files`, exit 0.

## 7. The owner's Decided and Blocked items

- Decided, poll rule stated once with pointers; root-only `/loop` wake; the rewrite exception; STACK-READY
  headings chosen by the writer. **Nothing** — all four are recorded in P105 in both DECISIONS copies, which is
  where a decision belongs, and the reviewers saw them (round 3 Noted S2 cites P105).
- Decided, the four "after CI is green" docs doing #119's work. **Judgment for Manuel**, covered in Issues.
- Decided, no step tells the root to put the digest into each owner's brief. **Nothing for this PR.** The
  ticket's criterion 1 asks only that the digest be "carried in the brief under Autopilot-stack, else written
  by you", which step 0 says; round 1 judged the gap Noted (S4/S2) rather than act-on. Worth a ticket, not a
  fix here.
- Decided, the falsifiability note went out after the work rather than before. **Judgment for Manuel**, a
  process observation; the note itself is honest and I confirmed both sub-checks did already pass at HEAD.
- Blocked, the notification fact did not hold in this run. **Judgment for Manuel**, as the owner says. Not a
  defect in the change: the ticket dictated the wording, the playbook uses it, and the counter-observation is
  recorded twice, at `docs/agents/ledger.md:34` and inside the M0 line itself. If Manuel rules the fact wrong,
  the digest bullet and the M0 line both need one sentence changed.
- Blocked, #119. **Judgment for the root**, see Issues.

## 8. Chain-time rebase onto PR #121 (e9fd603)

Done in a throwaway clone under the session scratchpad (`…/scratchpad/reb/repo`), nothing pushed.
`git rebase e9fd603752d1eeacf345c9853e34d0f33e20813c` over this PR's 11 commits. Four conflicts, all
append-collisions with obvious resolutions:

1. `AGENTS.md`, commit `156aae3`: #121 adds `- bash tests/knowledge/provisional-ids.sh` and this PR adds
   `- bash tests/spec-review/no-stale-wording.sh` at the same point in "Verifying". Resolution: keep both lines.
2. `docs/M0-findings.md`, commit `982b125`: both sides append a dated 2026-09-22 finding at the end.
   Resolution: keep both blocks. (Both are notification findings, from different lanes; they do not contradict.)
3. `docs/knowledge/core/DECISIONS.md` + `template/docs/factory918/DECISIONS.md` + `docs/knowledge/INDEX.md`,
   commit `8ce184c`: #121's `P110` row and this PR's row land on the same last line of the Provisional table.
   Resolution: keep both rows, take either generated line count and rebuild.
4. Same two DECISIONS files again at `d530b74` and `0b1f96a`, which rename `P31` → `P105` and rewrite the row.
   Resolution: keep `P110`, drop the superseded `P31`/old `P105` line, take the incoming row.

After resolving and `python3 tools/build_knowledge.py`, the rebuild changes exactly two generated lines (the
`core/DECISIONS.md` line count 101 → 102 in `INDEX.md` and in the file's own header), so **the rebase needs one
extra rebuild commit**; the root should expect that and not treat it as drift.

On the rebased tree:

- `python3 tools/check_knowledge.py` → `knowledge ok: 119 files`, exit 0.
- `bash tests/knowledge/provisional-ids.sh` → `provisional-ids: 26 assertions passed`, exit 0. P105 satisfies
  #121's ticket-number rule with no change.
- Extra, unasked: `./factory918.sh sync` → `git status --porcelain` empty;
  `bash tests/spec-review/no-stale-wording.sh` → `ok: no stale wording`;
  `bash tests/poteto-mode/overlap.sh` → `ok 57 assertions`.

## Issues

1. **#119 is open, labelled `ready-for-agent`, and nothing links it to this PR.** All three of its acceptance
   criteria already hold at e090a38 (grep exits 1 with no output; build and check pass; its third criterion
   names a file that does not exist). The merge of #120 will not close it, because only `Closes #105` is in the
   body and `closingIssuesReferences` lists #105 alone. A root or a human dispatching #119 next would hand a
   lane a ticket with nothing left to do. Close it by hand against #120, or strip its label.
2. **The PR body undercounts the regenerated patches.** "Each of the 19 changed playbook patches" in the
   Verification section; `git diff --name-only 86d156a..e090a38 -- patches/pstack/poteto-mode/playbooks` lists
   20. Cosmetic, but it is a receipt, and I regenerated 20, all matching. Worth one word on the next push if
   one happens; not worth a push of its own.

## Notes

- `ticket.md` now carries two amendment-line formats for a ticket's design artifact: Design hole step 3's
  `Amended <date> by #N (review round <r>, hole at <reference>): …` and the new closed-record section's
  `Amended <date> by <name or "the agent"> in #<PR>: …`. They cover different situations (an open ticket
  mid-restart versus a closed ticket touched by a later PR), so this is not a contradiction, but a reader
  choosing between them has to notice which section applies.
- Round 4's Standards report flagged that the poll pointer sits after the work consuming the lane's answer in
  Hillclimb step 1 and Refactoring step 1, and a person-shift in `opening-a-pr.md`'s closing line. Judged
  Noted, correctly under the ladder, so they are unfixed by design. If anyone touches those files again, they
  are two-word moves.
- The Overlap block names `#124 feat/reviewer-model-eval` on `SOURCES.md` and `patches/series`. Not in my
  slice's chain, and I did not rebase against it, but the root should expect the same append-collision shape
  there (one new `SOURCES.md` item number and one `series` line).
- `AGENTS.md`'s ShellCheck line says "over 20 files" here and "21 files" on #121's head. Pre-existing on both
  sides, not caused by this PR, and it merged cleanly in the rebase.
