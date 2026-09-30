verdict: PASS

Slice: live runtime floor. PR #121 (ticket #110) at `e9fd603752d1eeacf345c9853e34d0f33e20813c`.
`git rev-parse HEAD` = e9fd603752d1eeacf345c9853e34d0f33e20813c; `git merge-base --is-ancestor 86d156a HEAD`
exit 0. All scratch work in a private TMPDIR under the session scratchpad (`.../scratchpad/s`, a throwaway
copy of the tree at the SHA with its own `.git`); nothing committed or pushed anywhere under version control.

Scratch setup: the tree at the SHA, with the real `| P110 |` row removed and `tools/build_knowledge.py`
re-run, committed as `main`. That gives a base on which ticket 110 has not yet recorded a row, so (a) and
(c) can be run with the ids the slice names. Baseline on that base: `python3 tools/check_knowledge.py` ->
`knowledge ok: 119 files`, exit 0.

## (a) Two lanes from one base

- Lane A on `main` adds `| P110 | ... |`, rebuild, `python3 tools/check_knowledge.py` -> `knowledge ok: 119 files`, exit 0.
- Lane B on `main` adds `| P111 | ... |`, rebuild, check -> `knowledge ok: 119 files`, exit 0.
- Merging lane B into lane A: exit 1, conflict in `docs/knowledge/core/DECISIONS.md` and
  `template/docs/factory918/DECISIONS.md` (both lanes append at the end of the table). Resolved the way the
  design says, by keeping both rows; `python3 tools/build_knowledge.py` then `check_knowledge.py` ->
  `knowledge ok: 119 files`, exit 0. Tail of the table is `| P110 | ... |` then `| P111 | ... |`.
- The old max+1 habit: lane A and lane B each add `| P31 | ... |` with different decision text (identical
  text would auto-merge into one line and hide the collision). Each lane alone passes: check exit 0 on
  both. This reproduces P110's "a lone max+1 id passes its own CI" clause. After the merge (exit 1,
  same two conflicts) and a keep-both resolution, rebuild + check -> exit 1 with:
  `DECISIONS.md line 102: Provisional id P31 is already on line 101; an id comes from its ticket (P<ticket>,
  then b, c, ... for a second row of the same ticket), so rename this row and its mentions`
  The message names the duplicate id and both line numbers.

## (b) The id form

Each id appended as a fresh row to a table already holding `P110`, rebuilt, then checked
(`tools/check_knowledge.py`; driver `.../scratchpad/drive.py`):

| id | exit | first line of output |
|---|---|---|
| `P110b` | 0 | `knowledge ok: 119 files` |
| `P110c` | 0 | `knowledge ok: 119 files` |
| `P110z` | 0 | `knowledge ok: 119 files` |
| `P112` | 0 | `knowledge ok: 119 files` |
| `P110a` | 1 | `DECISIONS.md line 103: Provisional id 'P110a' is not P<ticket> with an optional b-z sibling letter` |
| `P-110` | 1 | same message, `'P-110'` |
| `P110B` | 1 | same message, `'P110B'` |
| `p110` | 1 | same message, `'p110'` |
| `P110aa` | 1 | same message, `'P110aa'` |
| `P110b2` | 1 | same message, `'P110b2'` |
| `110` | 1 | same message, `'110'` |
| `PP110` | 1 | same message, `'PP110'` |
| `P110` with a trailing space | 1 | duplicate message naming line 101 (the cell is stripped, so it is the same id, correctly) |
| `P110` with a leading space | 1 | duplicate message naming line 101 |
| empty id cell | 1 | `Provisional id '' is not P<ticket> with an optional b-z sibling letter` |

`P110a` is refused, as the rule intends (the sibling chain starts at `b`), and `P110b` is accepted while
`P110` is present.

## (c) Rebase does not renumber

- `main2` = `main` plus `| P112 | ... |` (rebuild, check exit 0).
- Rebasing the branch that carries `P110` onto `main2`: exit 1, the same two DECISIONS.md conflicts. Resolved
  keep-both; rebuild; `check_knowledge.py` -> `knowledge ok: 119 files`, exit 0. The branch's row is still
  `| P110 | ... |` (tail: `P112` then `P110`). No renumbering, no edit to the id, and nothing that cites it
  would have to move.

## (d) A reshaped table is refused, not skipped

Driver `.../scratchpad/reshape.py`, each variant rebuilt then checked:

- `## Provisional` demoted to `### Provisional` -> exit 1, `DECISIONS.md: no Provisional row was read; the '## Provisional' section is missing or its table changed shape`.
- rows indented so they no longer start with `|` -> exit 1, same message.
- whole section dropped -> exit 1, same message.
- all `| P...` rows removed, section kept -> exit 1, same message.
- heading text widened to `## Provisional decisions (added by agents...)` -> exit 0. Intentional: the check
  matches the `## Provisional` prefix, and every row is still read and validated, so this is not a silent pass.

## (e) The `cites:` grammar

The harness that parses `cites:` is `template/.agents/skills/spec-review/scripts/review-brief.sh` (line 248,
variable `cites`); its test is `tests/spec-review/review-brief.sh`.

- At the SHA: `bash tests/spec-review/review-brief.sh` -> exit 0, `ok 660 assertions`.
- `bash tests/spec-review/review-comment.sh` -> exit 0, `ok 192 assertions`.
- `bash tests/knowledge/provisional-ids.sh` -> exit 0, `provisional-ids: 26 assertions passed`.
- Legacy ids still carry, live: a scratch copy of the tree with the new test's id loop widened to
  `P110 P110b P1 P16 P17 P30 P110z` -> exit 0, `ok 680 assertions` (660 + 4 assertions x 5 added ids).
  Each of `P1`, `P16`, `P17`, `P30`, `P110`, `P110b`, `P110z` is counted as carried and appears in the
  written brief.
- Malformed cites are refused as before: in the same run, `cites: DECISIONS.md P-110` gives
  `settled: carried 1, dropped 2 without a citation` and does not appear in the brief; the pre-existing
  malformed block (`#42 cell 12A`, `table 12/A`, `#42 criterion 0`, trailing text, trailing sentence) passes
  unchanged at both SHAs.
- Comparison with 86d156a: the same tree with only `review-brief.sh` replaced by that file's 86d156a version
  -> exit 1, failing on exactly one assertion,
  `FAIL cites: DECISIONS.md P110b is counted as carried (5A, 5B)`. `P110` passes at the old version and
  `P-110` is dropped at both. The one-character widening (`[A-Z]?[0-9]+` -> `[A-Z]?[0-9]+[b-z]?`) is exactly
  what the letter suffix needs and loosens nothing else that the suite can see.

## (f) Rebuild after the passing merge

On the merged branch from (a): `python3 tools/build_knowledge.py` -> `knowledge files: 119 -> docs/knowledge`;
the working tree then has 0 modified paths (the rebuild is idempotent and the merge left the generated files
consistent); `python3 tools/check_knowledge.py` -> `knowledge ok: 119 files`, exit 0. Same at the SHA itself
in the verification worktree: build + check both clean, working tree unmodified afterwards.

## (g) The prose

`docs/agents/issue-tracker.md` and `template/docs/agents/issue-tracker.md` are byte-identical
(`cmp` exit 0; both `c7f6393a029a5ad5408848573fe107d1d551e8ee`). Line 13 of each:

> **Record a decision**: a row a PR adds to a decisions table that parallel PRs share takes the id `P<N>`,
> N the ticket the PR closes; a second row from the same ticket takes `P<N>b`, then `P<N>c`. When `P<N>` is
> already in the table (`P1` to `P30` predate this rule), the row takes the next free letter, `P<N>b`. The
> id comes from the ticket, so two PRs branched from one base hold different ids and a rebase changes none.
> The highest id plus one is the id to avoid: two lanes from one base both take it, and every rebase then
> renumbers it and the reviews that cite it. In the factory these are the Provisional rows of
> `docs/knowledge/core/DECISIONS.md`, and `python3 tools/check_knowledge.py` refuses a duplicate or any
> other form.

`template/.agents/skills/poteto-mode/playbooks/ticket.md` line 17:

> A decision the ticket records goes under Provisional in `DECISIONS.md` as `P<N>`, N this ticket's number,
> and a second row as `P<N>b`, then `P<N>c`. When `P<N>` is already in the table (`P1` to `P30` predate this
> rule), the row takes the next free letter, `P<N>b`. The id comes from the ticket, never from the table, so
> a parallel PR or a rebase leaves it unchanged. In the factory, `python3 tools/check_knowledge.py` refuses a
> duplicate or any other form. The rule and its reason are `docs/agents/issue-tracker.md`, "Record a decision".

`docs/knowledge/core/DECISIONS.md` line 68, above the table, says the same in one sentence.

Judgment: yes. An agent with no other context can take a correct id from either passage. It is told the id
comes from its own ticket number, which it always knows, and never from a read of the table; the second-row
case is spelled out (`P110b`, then `P110c`); the legacy collision case (a ticket numbered 1 to 30) is named
explicitly and routed to the same letter rule. The next-free-letter case is covered by "the row takes the
next free letter" - an agent whose `P<N>` and `P<N>b` are both taken reads that as `P<N>c`, and the checker
catches it if it does not. The playbook also points at the fuller statement, so a lane that wants the reason
knows where to look.

## Issues

(none)

## Notes

- The prose's illustration of the next-free-letter case always shows `P<N>b`, while the rule word is "the
  next free letter". An agent facing `P<N>` and `P<N>b` both taken has to generalize one step to reach
  `P<N>c`. The sentence before it does name `P<N>c`, and the checker refuses a duplicate, so this is a
  wording note, not a defect.
- `provisional_problems` reads only rows under a heading whose text starts with `## Provisional`. If someone
  restructures the file so some rows sit under a different later `## ` heading, those rows are not read and,
  because other Provisional rows remain, the "no row was read" guard does not fire: a duplicate parked under
  a new `## More provisional rows` heading passed (exit 0, `knowledge ok: 119 files`). Reaching this requires
  a deliberate re-layout of the document, which the rule does not contemplate; the four reshapes in (d) that
  a rebase or a careless edit could produce are all caught.
- The check validates `docs/knowledge/core/DECISIONS.md` only. `template/docs/factory918/DECISIONS.md` is the
  generated copy and is kept honest by the existing `build_knowledge.py` plus diff-exit-code CI step.
- CI wiring confirmed: `.github/workflows/factory-ci.yml` runs `bash tests/knowledge/provisional-ids.sh` (line
  33) before the knowledge-consistency step (line 35), so the id rule fails a PR on its own step.
- Out of this slice and left to the others: ShellCheck over the new 21-file set, `tests/hooks/delegation.sh`,
  `tests/poteto-mode/overlap.sh`, `./factory918.sh sync`, and the fixture flow.
