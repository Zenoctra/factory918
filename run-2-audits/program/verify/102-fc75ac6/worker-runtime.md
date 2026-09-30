verdict: PASS

# Slice: live runtime floor, PR #102 (ticket #93) at fc75ac69712119bb0e921e348a54b4d857c41b07

Setup: `git fetch origin feat/would-break-extra-rounds feat/spec-walk-risks main` then `git checkout
--detach fc75ac69712119bb0e921e348a54b4d857c41b07` in my own worktree
(`.claude/worktrees/agent-a229d1b484a1d88ec`). `git rev-parse HEAD` =
`fc75ac69712119bb0e921e348a54b4d857c41b07`; `git merge-base --is-ancestor d8e382c HEAD` exit 0.

Everything below ran live against the skill as the SHA holds it, in throwaway project-layout
repositories built with `tests/spec-review/layout.sh` and `tests/spec-review/fake-gh.sh`, under a
private `TMPDIR` in the session scratchpad. Comment histories were produced by really running
`review-comment.sh` where the check is about the round gate reading real output, and hand-written
only where the cell is about a malformed or synthetic line. Nothing under version control was
written.

## (a) Three rounds, round three's Act on carrying a Would-break item marked `fixed:`

- Rounds one and two run normally (`round: 1 of 3`, `round: 2 of 3`, exit 0). Round three's brief
  ran at `HEAD=c5c54e0…7072`; `<dir>/reviewed` holds exactly that commit. The fix commit
  `e325a7a…e937` landed after it, the judgment marked `1. [S1] **Breaks.** … fixed: e325a7a`, and
  `review-comment.sh` (exit 0) printed, in order:
  `would-break fixed after c5c54e0ef8df6426ae5b553df4b2300becee7072` / `round: 3 of 3` /
  `act-on items: 0`.
- Round four, `review-brief.sh c5c54e0… --ticket 7 --previous history.txt`, exit 0:
  ```
  ticket: #7
  round: 4 of 5
  settled: carried 0, dropped 0 without a citation
  ```
  `<dir>/round` = `4`, `<dir>/reviewed` = `e325a7a…e937` (HEAD at brief time).
- `## Commits` in **both** briefs holds the fix commit and nothing else: `e325a7a fix the
  would-break item`.
- `## The fix under review` is present in **both** briefs, before `## Diff`, with the contract
  paragraph verbatim and round three's fixed item under it:
  ```
  ## The fix under review

  The round before this one fixed these Act on items on this PR after the commit it reviewed; this
  round's diff is those fix commits and nothing else. Read each fix against its item, walk only the
  steps these commits touch, and report only what these commits get wrong. Nothing in this section
  says what you should find or confirm.

  1. [S1] **Breaks.** fixed on this PR fixed: e325a7a
  ```
  (The paragraph is one line in the file; wrapped here.) Ticket #93 table A rows 3 and 20: match.

## (b) Round four's fix earns round five; a sixth is refused

- Round four's comment, built from a judgment marking a second Would-break item fixed:
  `would-break fixed after e325a7a8401dc16cd2b9cedb5bcd2c4bf465e937` / `round: 4 of 5` /
  `act-on items: 0`, exit 0 (table B row 3C).
- Round five, `review-brief.sh e325a7a… --ticket 7 --previous history4.txt`, exit 0: `round: 5 of
  5`, `<dir>/round` = `5`, `## Commits` = `b54fa6a fix the second would-break item` alone, `## The
  fix under review` carrying round four's item (table A row 9).
- Round five's comment: `would-break fixed after b54fa6ac34883dcc79c6839228bac3f78cac91fd` /
  `round: 5 of 5` / `act-on items: 0`, exit 0 (table B row 3D).
- The sixth round, `review-brief.sh b54fa6a… --ticket 7 --previous history5.txt`: **exit 1**,
  stdout empty, one line on stderr:
  `review-brief: five rounds were run on this PR; round five's Would-break fixes are the human's to
  review (spec-review step 5), not reviewed in a sixth round`.
  `.claude/state` and the set of `.scratch/review/*` dirs were identical before and after the run
  (compared, printed `IDENTICAL`): no state written (table A row 11, `F6`).
- The message points at spec-review step 5, which is where the stop-and-report instruction lives
  (quoted under (g)); it names the step rather than restating "write the report".

## (c) A round three with no Would-break fix: the fourth round refused as before

- Same three-round history but every fixed item under `## Fails open` / `## Standards breaches`.
  The round-three comment carries **no** `would-break fixed after` line: its tail is `round: 3 of 3`
  / `act-on items: 0`.
- The fourth round: exit 1, stderr
  ``review-brief: three rounds were run on this PR; the remaining Act on items are fixed here and
  marked `fixed: <sha>`, not reviewed in a fourth round``.
- Ran the identical fixtures against a second scratch repo holding the skill at **d8e382c**. The
  two stderr files are byte-for-byte identical (`diff` printed nothing; `IDENTICAL`). Table A row
  2 / `F4`: match.

## (d) `review-comment.sh`: the line's condition, and no drift for a round-three PR

- Would-break item present but **not** fixed, a Fails-open one fixed → no line; tail is the
  summary, `round: 3 of 3`, `act-on items: 1`.
- Same reports, the Would-break item marked `fixed:` → the line prints between the summary and
  `round:` (table B row 3B).
- The line names the **reviewed** commit (`<dir>/reviewed`), not the fix commit; the fix commit is
  named by the `fixed: <sha>` field on the judgment item, printed verbatim under `## Judgment`.
- A hole outranks it: with one item `hole: criterion 1` and another `fixed:`, the comment prints
  `restart` and no `would-break` line (table B row 5). `hole: criterion 1 fixed: abc1234` (the
  ending rule) counts as a fix, not a hole, and prints the line (table B row 4).
- A Would-break item marked `ticket: #9` prints no line (table B row 6).
- No spec (`<dir>/spec-brief.md` absent): the line still prints, the heading being read from
  `specs()` (table B row 3F). Sweep form (`fixed point paths`): the line prints with the
  checked-out HEAD (table B row 9).
- `<dir>/reviewed` missing while the line is needed: exit 1, state kept, the `RM` message verbatim
  as the ticket writes it, recovery advice included. I checked the advice is actionable:
  `<dir>/log` is `git log <fixed>..HEAD --oneline`, newest first, so its first commit is the
  reviewed commit (`cf0da0b`), which is what the accepted run had printed.
- The cap, with `<dir>/round` set by hand: `3` → `round: 3 of 3`, `4` → `round: 4 of 5`, `5` →
  `round: 5 of 5`, `6` → `round: 6 of 5` (the round file is trusted, as the ticket says).
- Same-fixture diff at both SHAs for a PR ending at round three with no Would-break fix: the two
  comments differ only in the incidental commit id of the scratch repo; with 40- and 7-hex ids
  normalised, `diff` prints nothing (`IDENTICAL`). Nothing changed for that path.

## (e) A wrong or unresolvable fixed point for a fix-only round

Each refused before any state (the `.scratch/review` listing unchanged), exit 1, one line:

- Fixed point `c5c54e0…~1` instead of the commit round three reviewed →
  ``review-brief: round 4 reviews only the fix from c5c54e0…7072, the commit round 3 reviewed (the
  `would-break fixed after` line of the last review comment); c5c54e0…7072~1 is not that commit``
  (`FP`, table A row 4).
- A hand-written line `would-break fixed after HEAD~1` →
  ``review-brief: the last review comment carries `would-break fixed after HEAD~1`, which is not
  the line review-comment.sh writes (a 40-character commit id follows the words); post the comment
  the script printed`` (`FM`, row 14) — and it fires first, before the round gate.
- A well-formed id that does not resolve here →
  `review-brief: round 4 reviews only the fix from 0123…4567, the commit round 3 reviewed, and that
  commit does not resolve here; fetch the PR's branch` (`FR`, row 5).
- The fix-only round without `--ticket` while the commits name no ticket and round three had a spec
  → `review-brief: round 4 reviews only the fix and its commits name no ticket, while round 3 had a
  spec; pass --ticket N so the Spec axis reads the same spec` (`FT`, row 6).
- Sweep form on that history → `FP(4,s,paths)`: `… paths is not that commit` (row 17).
- No comments at all: `--round 4` → `F4`, `--round 5` → `F5`, `--round 6` → `F6` (row 1B).
- A history ending `(3W s)` with `--round 5` → `F5`; with `--round 3` → `round: 3 of 3` and **no**
  `## The fix under review` section (row 3B).
- `(1), (2), (3W s), (4)` with no line on the round-four comment → `F5` (row 8).
- A round-one comment carrying the line → `round: 2 of 3`, exit 0, no fix section, whole diff from
  the original fixed point (row 12).
- A comment carrying both `restart` and the line → `restart:` and `round: 1 of 3`, no fix section:
  restart wins (row 13).

## (f) Babysit

Both copies carry the same sentence, word for word
(`template/.agents/skills/babysit/SKILL.md:40` and
`template/.agents/skills/poteto-mode/playbooks/babysit.md:16`):

> The review runs three rounds on one PR, five when round three or four fixed a Would-break item; a
> comment reading `round: 3 of 3`, `round: 4 of 5` or `round: 5 of 5` with `act-on items: 0` and no
> `would-break fixed after <sha>` line makes the PR review-ready even when the fix commits it names
> come after the reviewed commit. A comment carrying the line `would-break fixed after <sha>` is not
> review-ready whatever its count: below round five another round is owed and the orchestrator runs
> it (`spec-review` step 1 says its fixed point); at `round: 5 of 5` it is the human's line, a wait
> like an `## Ask` item and not a blocker to fix here, until the human answers the report the
> orchestrator posted on the PR.

- Read against the comment (b) actually produced (`would-break fixed after b54fa6a…`, `round: 5 of
  5`, `act-on items: 0`): the second sentence applies and the `round: 5 of 5` clause decides — the
  PR is neither ready nor a blocker to fix in babysit. It reads `round: 5 of 5` as a wait.
- Read against the comment (c) produced (`round: 3 of 3`, `act-on items: 0`, no line): the first
  sentence applies and the PR is review-ready — the same verdict the d8e382c sentence gave for the
  same bytes. Unchanged for a PR ending at round three.
- `patches/pstack/babysit/SKILL.md.patch` and
  `patches/pstack/poteto-mode/playbooks/babysit.md.patch` carry the same replacement, so
  `factory918 sync` re-applies it.

## (g) The changed prose

- **`spec-review/SKILL.md` step 1.** States the cap ("three rounds … five when round three or four
  fixed a Would-break item"), that the round line reads `of 5` from round four, that `<dir>/reviewed`
  records the commit reviewed, names the fix-only round's fixed point and the exact call
  (`scripts/review-brief.sh <sha> --ticket N`, with why the ticket is needed), and lists the five
  refusals. Followable: every refusal I hit live is named there, and the one instruction it gives
  the agent is the call that worked.
- **`spec-review/SKILL.md` step 4.** The `## The fix under review` bullet carries the fix paragraph
  word for word; I saw the identical string in both live briefs, and `tests/spec-review/review-brief.sh`
  holds the copies together (ran: `ok 648 assertions`).
- **`spec-review/SKILL.md` step 5.** Two stops, both judgment. At round three: look for what is
  causing hard bugs to keep turning up before the fix lane starts, and say what you found in the two
  sentences above the comment; when the cause is not obvious, fix and go on to round four, and to
  five if four finds another. At round five with Would-break items still found: fix and mark them as
  at any last round, post the comment, then post a separate report for the human (every round's
  Would-break items with their fixes and what they share, what round three's look found, what in the
  factory would have caught them earlier), `gh pr ready --undo`, go on with unrelated work, wait.
  Followable, and it is what the `F6` refusal points at. It also carries the no-count rule the
  ticket's Decision demands ("No count is compared between rounds"); I confirmed live that the
  summary line is unchanged and never says how many of the fixes were would-break.
- **`ticket.md` `### Would-break fix`.** Two numbered steps. Item 1 splits the cases the way the
  scripts behave: a round-three or round-four comment → the next round from `<sha>` with
  `--ticket N` (matches (a) and (b)); a round-one or round-two comment → the next round as any
  other from the original fixed point (matches the live row-12 run, `round: 2 of 3`, no fix
  section). Item 2 is the round-five stop. Followable.
- **`review-ladder.md` rung 1.** Descriptive and consistent with both scripts: `of 5` from round
  four, five rounds when three or four fixed a Would-break item, each round past three reviewing
  only that fix from the commit the round before reviewed, no count compared, and a `round: 5 of 5`
  comment carrying the line stopping the PR as unfinished.
- **No contradiction with #99's design-hole section.** They sit side by side in `ticket.md`
  (`### Design hole` at line 26, `### Would-break fix` at line 37) and step 8 routes to exactly one:
  `restart` → Design hole, "not on to step 9"; the `would-break` line → Would-break fix, "before
  step 9". The scripts cannot produce both marks in one comment — `review-comment.sh` prints
  `restart` *or* the line, hole first, confirmed live (table B row 5) — and `review-brief.sh` lets
  restart win when a `--previous` file carries both (table A row 13, run live: `restart:` and
  `round: 1 of 3`). Design hole step 5's "reviewed from round one" and Would-break fix item 1's "up
  to five" never apply to the same comment.

## The repository's own gates at this SHA

- `bash tests/spec-review/review-brief.sh` → `ok 648 assertions`, exit 0.
- `bash tests/spec-review/review-comment.sh` → `ok 192 assertions`, exit 0.
- `bash tests/spec-review/no-stale-wording.sh` → `ok: no stale wording`, exit 0.

## Issues

None found in this slice.

## Notes

- `F5` is parameterised on `top`, so with no comments at all (`--round 5`, empty history) it reads
  "(the last review comment is round 0)" although there is no last review comment. That is what the
  ticket's `F5` definition produces and table A row 1B asks only for `F5`, so it is in spec; it is
  the one rough edge in an otherwise precise refusal set.
- The reviewed commit is recorded at brief time, so rerunning `review-brief.sh` for the same round
  *after* the fix lane has committed re-records HEAD and would carry the wrong commit into the next
  round. The ticket names this ("rerunning it after the fixes were committed would record the fixing
  commit as the reviewed one") and the `RM` message steers to writing the id by hand instead. I
  checked where a wrong value lands: a line naming HEAD itself refuses with the pre-existing
  `review-brief: the diff is empty; nothing to review since <sha>` (exit 1), and any other wrong
  commit refuses with `FP`. It fails closed, not silently.
- Below round three the change is visible to babysit only: a round-one or round-two comment whose
  judgment fixes a Would-break item now carries the line and so is not review-ready even at
  `act-on items: 0`, where before it was. That is table A row 12 and table B row 3A, and both prose
  copies say it, so it is intended; it is the one behaviour change outside rounds four and five.
- The empty-diff refusal prints the `ticket:`/`round:`/`settled:` lines on stdout before failing on
  stderr. Pre-existing ordering, unchanged by this PR.
