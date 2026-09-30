## What to build

> agent (post-mortem, 2026-09-22): "two trails with invented timestamps"

> agent (delegates.md): "this owner's trail carries timestamps it made up (it wrote "17:45:00Z" at 17:25 and "19:35:00Z" at 17:46); the minutes below come from the transcript."

Facts the lane starts from. The show-me-your-work skill (`template/.agents/skills/show-me-your-work/`, vendored; changes go through `patches/`) keeps a `decisions.tsv` with a `ts` column; its `scripts/log.sh` exists but lanes wrote rows by hand. Ticket #91's and #93's trails carried placeholder and out-of-order timestamps, which broke the post-mortem's per-phase timing (`.scratch/program/postmortem/timeline.md`).

## Acceptance criteria

- [ ] The skill says a row is appended only through `scripts/log.sh`, which stamps `ts` from `date -u`, and a lane never types a timestamp; the patch, `series` and `SOURCES.md` carry it.
- [ ] A trail whose rows are out of order or carry a timestamp outside the lane's run is refused by the trail review with a line naming the rows.
- [ ] `docs/agents/evidence.md` or the skill names the trail as the timing record the post-mortem tooling reads.

## Blocked by

None.


## Testing decisions

Posted by the agent 2026-09-23. Synthesized from two architect runners: runner A's design is the base, and runner B's column-count check is grafted in. Both runners ran every cell on macOS and on `ubuntu:24.04`. Runner A also checked the #88 to #93 trails against their owners' transcripts.

### Shape

`log.sh` does not change. The skill text says a row is appended only through it. A new script of ours, `show-me-your-work/scripts/check-trail.sh <trail.tsv> <transcript.jsonl>...`, is in `sync`'s `keep_files`. It reads the run's bounds from the `timestamp` fields of the given transcripts, so nobody types a bound. The trail review runs it first. A refusal goes first under Attention, verbatim. It does not block merge-ready, because the log is append-only and its rows cannot be repaired.

### Legend

- **OK.** stdout `ok: <n> rows in order inside the run <first> to <last>`, exit 0. The reviewer quotes the line and goes on.
- **REF[x].** stdout has one line per offending row in file order, `line <n> <ts>: <reason>[; <reason>]`. The header's line comes first when it is wrong. Exit 1. The trail is refused as a timing record.
- **ERR[msg].** stderr msg, exit 2, nothing on stdout. The check did not run, so the reviewer writes `trail clock not checked: <msg>`.
- **USE.** stderr `usage: check-trail.sh <trail.tsv> <transcript.jsonl>...`, exit 64.
- Reasons: `H` is `line 1: header is not the template's`. `C` is `has <k> columns, expected 6`. `O` is `earlier than line <m> (<ts>)`. `X` is `outside the run <first> to <last>`. `N` is `not a log.sh stamp`.

### Table

Columns: the transcripts given. "Own" is the transcript of the lane that wrote every row. "Every writer" is the transcripts of all lanes that appended. "Wrong" is an unrelated lane's transcript.

| # | Situation | no transcript | own | every writer | wrong |
|---|---|---|---|---|---|
| 1 | trail path is not a file | USE | ERR[`no trail at <path>`] | ERR[same] | ERR[same] |
| 2 | trail is 0 bytes | USE | REF[H] | REF[H] | REF[H] |
| 3 | header is not the template's (`ts what why evidence result`, or CRLF) | USE | REF[H, then C on each five-column row] | same | same, plus X |
| 4 | a row with seven columns under the template header, inside the run | USE | REF[C] | REF[C] | REF[C; X] |
| 5 | header only | USE | OK (0 rows) | OK | OK |
| 6 | every row a stamp, non-decreasing, inside the run | USE | OK | OK | REF[X on every row] |
| 7 | a row on the first or last second of the run; two rows in one second | USE | OK | OK | REF[X] |
| 8 | a row earlier than the stamped row above it | USE | REF[O] | REF[O] | REF[O; X] |
| 9 | a row before the first or after the last transcript record | USE | REF[X] | REF[X] | REF[X] |
| 10 | a row both earlier and outside | USE | REF[O; X on one line] | same | same |
| 11 | a ts that is not a stamp (`17:45:00Z`, a blank line, `2026-09-22 10:40:00`) | USE | REF[N], with C too on the blank line; the row is skipped for order, and the next row compares with the last stamped row | REF[N] | REF[N], with X on the stamped rows |
| 12 | rows from two owners who shared one trail | USE | REF[X on the other owner's rows] | OK | REF[X] |
| 13 | a transcript file is missing | USE | ERR[jq's own `Could not open file ...`] | same | same |
| 14 | no transcript line has a `timestamp` | USE | ERR[`no timestamp in <paths>`] | same | same |
| 15 | a transcript has non-JSON lines or a torn last line | USE | those lines are skipped, and the cell is the row's cell above | same | same |

### Contract

- **Stamp.** A `ts` that exactly matches `YYYY-MM-DDTHH:MM:SSZ`, the form `log.sh` writes with `date -u +%Y-%m-%dT%H:%M:%SZ`.
- **Template header.** Line 1 of `references/decision-log-template.tsv`, read at run time.
- **Run.** It runs from the smallest to the largest top-level `timestamp` over the given transcripts. Each value is cut to its first 19 characters plus `Z`. The bounds are inclusive and have no slack. Values are compared as strings.
- **Earlier.** A stamped row is earlier when its `ts` sorts before the nearest stamped row above it. Equal is not earlier.
- **Exit codes.** 0 means clean, 1 refused, 2 unreadable input, and 64 usage.

### Tests

`tests/show-me-your-work/check-trail.sh` asserts one case per cell, in table order, on the exit code and the exact output. It also asserts that `log.sh` rows written between two transcript records pass, which ties the two stamp formats together. It runs in CI and is listed under `AGENTS.md` "Verifying".
