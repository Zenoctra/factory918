verdict: PASS+NOTES

For a person: PR #135 does what ticket #109 asked, and I could re-derive every number and every table cell
myself instead of taking the PR body's word. Nothing blocks the stack; four items below are Manuel's call,
not defects, and one record sentence is slightly wrong in a way that changes no behavior.

Setup: `git checkout --detach 9454e38` in my own worktree; `git rev-parse HEAD` =
`9454e3849fadd5e69c9414b5a555fa316a6b5870`; `git merge-base --is-ancestor a9ebdac HEAD` exit 0. Diff read
whole: `git diff a9ebdac..9454e38`, 16 files, +81 -35.

## 1. The five acceptance criteria

- **C1 tier switch, DECISIONS row, MANUAL "Execution".** Met.
  `template/.agents/skills/poteto-mode/playbooks/ticket.md:10` ("The tier" bullet), pointers at `:22` (step 5),
  `:23` (step 6), `:25` (step 8), `:46` (Design hole step 2), `:28` (Reply).
  `docs/knowledge/core/DECISIONS.md:107` = P109, naming both tiers and what each keeps.
  `docs/knowledge/core/MANUAL.md:79` = the **Safe and eco.** paragraph, with
  `mkdir -p .claude/state && echo eco > .claude/state/tier`, `rm -f ...`, and the fallback sentence
  ("`safe` is the fallback: when a model struggles in `eco` ... run the next ticket, or this one again, in `safe`").
- **C2 the eco substitutions, and what stays fresh.** Met. `ticket.md:11-15` items 1-5 and the closing
  paragraph `ticket.md:17`; the architect one-runner exception at
  `template/.agents/skills/architect/SKILL.md:36-38` through `patches/pstack/architect/SKILL.md.patch`.
- **C3 hook decided and tested, tests first.** Met. Hook unchanged: `git diff a9ebdac HEAD -- template/.claude/hooks/`
  is empty. `tests/hooks/delegation.sh:128-143` is the 7x3 loop. The test file is byte-identical between
  96901b9 (the branch's first commit, `--stat`: one file, +17) and HEAD, and the hook never changes, so the
  21 assertions were green against the unmodified hook. `bash tests/hooks/delegation.sh` -> `ok 76 assertions`.
- **C4 owner brief names the tier; launch ceiling.** Met.
  `template/.agents/skills/poteto-mode/playbooks/autopilot-stack.md:5` ("whose first line is `Tier: eco` when
  the root's tier file read `eco` as that owner launched, and following that tier for its whole run"), through
  `patches/pstack/poteto-mode/playbooks/autopilot-stack.md.patch`; the ceiling at `ticket.md:17`.
- **C5 ledger line with the numbers.** Met, and the numbers reproduce exactly (see 8b for one wording flaw).
  `docs/agents/ledger.md:38`. Recomputed from `.scratch/program/postmortem/waits.md` class sums for the five
  owners that shipped a PR (#88 #89 #90 #91 #93-fresh): waiting on children 73.1+70.3+51.0+61.0+11.7 = 267.1;
  turn ended 81.4+21.6+16.3+5.1+21.9 = 146.3, minus #90's 60-minute rate-limit gap = 86.3; model latency
  25.0+21.2+15.4+18.4+18.0 = 98.0 (each between 15 and 25); tool time 54.9. Total 566.3 - 60 = 506.3.
  267/506 = 52.8% (53%), 86/506 = 17%, 353/506 = 69.8% (70%). Every figure in the line checks out.

## 2. Tables A, B, C: one assertion or walked proof per cell

**Table A, walked myself** (my own script, not the PR's `tier-proof.sh`): a fixture main checkout at
`.../scratchpad/walk1/a checkout with spaces` (spaces in the path), a worktree nested under
`.claude/worktrees/` and one outside, reading through the playbook's two commands.

```
A1 no file            main top=safe main subdir=safe nested worktree=safe outside worktree=safe
A2 holds safe         ... safe safe safe safe
A3 holds eco          main top=eco main subdir=eco nested worktree=eco outside worktree=eco
A4 ECO / 'eco ' / empty / two lines / CRLF     all safe, from all four places
A3 eco + blank lines  eco (trailing newlines stripped, as the contract says)
A6 worktree-only eco  safe from all four places
no repo               safe
```
A5 is prose, asserted at `ticket.md:10` ("the brief wins over the file, because a run never changes tier
halfway" and "A replacement owner for the same ticket takes the tier line of the brief it replaces, never the file").

**Table B**: each of B1-B7 has a literal `expect` line at `tests/hooks/delegation.sh:134-140`, run under the
three fixture tiers the legend defines (`none`, `echo eco >`, `printf 'ECO\nfast\n' >`) at `:129-133`, inserted
after the sub-agent group and before `echo planning` as the table says, with `rm -f .claude/state/tier` at `:143`.
Tests-first holds (96901b9 is the branch's first commit and touches nothing else).

**Table C**: every cell has an assertion. C1 `ticket.md:11`; C2 `:12`, `:23`, `:46` and `architect/SKILL.md:38`;
C3 `:12` ("Feature step 4 briefs one writer, never an arena"); C4 and C8 `:17`; C5 `:13` and `:25`; C6 `:14`;
C7 `:12` plus `template/docs/agents/review-ladder.md:8` and `docs/knowledge/core/MANUAL.md:98`; C9 `:15` and `:28`.

Test list item 3 ("a walk mapping each of the 2026-09-22 run's 77 delegates to a C row") is satisfied at the
level of lane *kinds*, not per delegate, and its source (`.scratch/program/postmortem/delegates.md`) is
untracked. I read that file and the mapping is right, but a reader with only the PR cannot check it.

## 3. Scope and vendored edits

Sixteen files, grouped: the rule (`ticket.md`), the two vendored files plus their patches plus `SOURCES.md`
items 11 and 14, the reader-facing pointers (`AGENTS.md`, `template/AGENTS.md`, `review-ladder.md`,
`MANUAL.md`), the records (`DECISIONS.md`, `ledger.md`, `INDEX.md`), the generated copies under
`template/docs/factory918/`, and the test. Nothing outside #109. One concern.

Vendored edits go only through patches: `patches/series:3` and `:12` already list both patch files;
`./factory918.sh sync` re-applies them and leaves `git status` empty. `ticket.md` is ours, not vendored
(`factory918.sh:385` `keep_files`).

**#137 check (does this PR change an upstream sentence beyond what the eco rule needs?).** One upstream
sentence changes: `architect/SKILL.md` "Design it twice. Require at least two structurally distinct candidates
before synthesis, even when the first looks sufficient" gains ", unless the caller's tier asks for one runner
(below)". That is the minimum: without it the upstream sentence flatly forbids what eco does. Nothing is
removed, and no #137 wording (expected counts, word caps, read/run bans) is touched anywhere in the diff.
The autopilot-stack step 1 line is already a full replacement line in our own patch, so its added clause is ours.

## 4. Receipts on the PR

- Round 1 `act-on items: 5` (`reviewed: 148aa8a`), round 2 `1`, round 3 `0` with `would-break fixed after
  259448e` and both items carrying `fixed: 1756050` / `fixed: 6fab5bd`, round 4 `round: 4 of 5`,
  `act-on items: 0`, no would-break line, no `next round owed:` line. Rounds 1 and 2 carry 0 fixed items, so
  no `next round owed:` line was due; their fixes were reviewed by the following round.
- **Round count re-derived with `review-brief.sh` through the fake gh.** I rebuilt the real comment history
  into `--previous` fixtures. With the first three comments and fixed point `a9ebdac` the script refuses:
  "round 4 reviews only the fix from 259448e..., the commit round 3 reviewed ...; a9ebdac is not that commit"
  (exit 1). With fixed point `259448e` it prints `round: 4 of 5` — byte-identical to the posted round-four
  comment's round line and fixed point. With all four comments it prints `round: 5 of 5`, i.e. a fifth round
  is permitted but not owed; the ladder's readiness rule stops it at `act-on items: 0`. Round four was legitimate
  and the review is finished.
- Commits d9a4227 and 9454e38 land after round 3 but before round 4's review, and round four's report records
  them explicitly ("Two fix commits answer no Act on item ... recorded, no action"). Nothing on the branch is unreviewed.
- CI: `Factory` SUCCESS and `Fixture` SUCCESS on 9454e38. `closingIssuesReferences` = [109], only.

## 5. PR body shape

Plain-sentence title. `## Problem` then `## Fix`. `## Blast Radius` at line 17 contains only `### ` headings
(`### What it does`, `### The one fact it is safe because of`, `### Risks`, `### Cleared`, `### Before you merge`)
and runs to `## Verification` at line 119. Verification quotes each criterion with its evidence. Last three
non-empty lines: `Closes #109`, the Claude Code attribution, `Claude Opus 5.5 on Claude Code`.

No `## Overlap` section. That was correct when the PR opened (`overlap.sh 109 --diff` printed nothing). See Note 8e.

## 6. Forbidden edits and generated files

Nothing under `research/`, `tools/bootstrap/`, `docs/knowledge/spec|pages|notes/`. `python3
tools/build_knowledge.py` leaves `git status` empty (119 files) and `python3 tools/check_knowledge.py` passes,
so `template/docs/factory918/DECISIONS.md` and `MANUAL.md` and the `INDEX.md` line counts match a rebuild.
`grep -c '^| P109 |'` finds exactly one row in each DECISIONS copy.

Gates I re-ran at this head, all green: ShellCheck 0.11.0 over 24 files; `tests/shellcheck/gate.sh` ok 17;
`tests/hooks/delegation.sh` ok 76; `tests/spec-review/review-comment.sh` ok 298;
`tests/spec-review/review-brief.sh` ok 1294; `tests/poteto-mode/overlap.sh` ok 57; `./factory918.sh sync`
leaves `git status` empty.

## Issues

None that block. The two items I weighed hardest and concluded are not defects:

- The one-page hand-back (`ticket.md:15`) and "Read no brief and no diff while the review state exists"
  (`:13`) look like caps, but the first binds the owner's report and the second protects reviewer blindness;
  neither touches a judging lane's brief.
- `docs/agents/review-ladder.md` does not exist in this repository (only `template/docs/agents/review-ladder.md`),
  so there is no un-updated copy.

## Notes

**7. Leading-witness check (#137).** Two new sentences reach a judging lane's brief. Neither caps output or
limits reading; one primes a result.

1. `template/.agents/skills/poteto-mode/playbooks/ticket.md:17`, quoted: "So an eco ticket launches **at most**
   one writer, one blast-radius lane, one runner and one judge per architect round (a Design hole restart runs
   another), two reviewers per round and one trail review, and logs each launch as a trail row, **and its brief
   to the trail review asks for that count against this list**." The trail review is a judging lane, and its
   brief is handed the expected count before it counts. Both round-one reviewers already flagged the
   launch-count obligation as not asked for (judged Noted, item 6). This is the pattern Manuel named on #137;
   a plainer brief would ask the reviewer to count and compare afterwards. **Judgment for Manuel**, not a defect —
   it does not change the diff's behavior and the ticket's criterion 4 is what motivates the count.
2. `template/.agents/skills/architect/SKILL.md:38` and `ticket.md:12`, quoted: "briefed to read that candidate
   adversarially ... and **to return its defects, not a base**". It presumes defects exist. Mild, and it is the
   whole point of the substitution for the second runner. **Nothing**, on Manuel's "pstack's milder lines are fine"
   standard — but this sentence is ours, not pstack's, so he may want "its findings" instead.

**8. The owner's Decided and Blocked items.**

a. *The extra drops* (`why` investigator lanes, the writer arena, `interrogate` wherever a step launches it).
   **Judgment for Manuel, disclosed, and I agree with the owner.** The writer arena drop is inside Manuel's
   approved quote ("the arena's two runners plus a judge can be one runner plus a judge"). `interrogate` and the
   `why` investigators are not in his quoted list, but criterion 4's "at most" ceiling cannot hold with them, so
   dropping them is derived from the criterion rather than invented. The owner says so under Decided.

b. *One sentence in the records is wrong.* The ledger line and the PR's Problem section both say the nine
   outcome-changing delegates "were blast radius, the two reviewer axes, the trail review and the arena judge".
   `delegates.md` has exactly nine rows verdicted **changed the outcome**, and one of them is #90's **writer**
   ("8, writer: changed the outcome, and was not listened to"), ranked 9 in that file's own list. So the
   enumeration names eight of the nine kinds. It inherits the framing from ticket #109's own What to build, and
   it changes nothing: the writer stays a fresh lane in both tiers, which is the conclusion the line draws.
   **A note for Manuel**, worth a half-clause if the ledger line is ever amended.

c. *`interrogate` was skipped on this run, which ran in `safe`.* `opening-a-pr.md:31` is unconditional: "A
   subagent that opens a PR runs `interrogate` and `/deslop`." The owner was a subagent, ran in `safe`, and
   skipped it, disclosing the skip in the PR body and the report. The eco clause this PR adds would have
   permitted it; `safe` does not. **Judgment for Manuel.** It is a process deviation on the run, not a defect in
   the diff, and four `spec-review` rounds plus a blast-radius lane and a trail review covered the change. It
   does mean the PR that introduces "eco skips interrogate" is itself the one run that skipped interrogate.

d. *The silent worktree tier file.* Reproduced: a tier file written only in a linked worktree's own
   `.claude/state/` reads `safe` from every place, and nothing prints the live tier. **Nothing** — the failure
   direction is a more expensive run, never a wrong one, and MANUAL's setter says "in the main checkout". Worth
   remembering only because the harness refuses the natural one-line read, which is why `ticket.md:10` spells out
   two commands; I hit that same refusal myself running my table-A walk, which confirms the shape of the rule.

e. **`overlap.sh` today prints an overlap that did not exist when the PR opened.** Re-running
   `overlap.sh 109 --diff` now prints PR **#136** (`feat/risk-dispositions`), which shares `SOURCES.md`,
   `docs/agents/ledger.md`, `docs/knowledge/INDEX.md`, both `DECISIONS.md` copies and
   `template/.agents/skills/poteto-mode/playbooks/ticket.md`. #136 is the later PR, so the sequencing or
   `## Overlap` burden is #136's, not #135's, and `overlap.sh:94` skips a PR whose head is the current branch,
   so #135's own line would not print from its branch. Flagging it because the root stacks these: **#136
   overlaps #135 on `ticket.md` and `DECISIONS.md` and must stack on it or wait for it.**

f. *Test list item 3's per-delegate mapping is at the level of lane kinds*, and its source is untracked. Not a
   criterion, and I verified the mapping myself against `delegates.md`. No action.
