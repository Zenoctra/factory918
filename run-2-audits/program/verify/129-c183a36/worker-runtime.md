# Slice: live runtime floor, and trying to break the check (PR #129, head c183a36)

verdict: PASS+NOTES

Setup: `git checkout --detach c183a362e73b88758bdf468a4169619158b47c1d` in my own worktree, `git rev-parse HEAD` =
`c183a362e73b88758bdf468a4169619158b47c1d`, `git merge-base --is-ancestor f58308b HEAD` exit 0. Host: macOS 15.6.1,
`/usr/bin/awk`, jq 1.7.1-apple. Private `TMPDIR=/tmp/v129runtime`; all fixtures there, nothing written under version
control.

- The ticket's own test: `bash tests/show-me-your-work/check-trail.sh` -> `ok 66 assertions`, exit 0. It is wired into
  CI at `.github/workflows/factory-ci.yml:30-31` and listed in `AGENTS.md` under Verifying.

## (a) The six real trails of this run

I found the writers rather than assuming them: for each ticket I searched every transcript under
`~/.claude/projects/-Users-manuel-Desktop-Work-Under-The-Sun-Collective-Core-918-factory918/` for a Bash command or a
Write that appends to `program/<N>/decisions.tsv`. Exactly one lane wrote each trail, all of them subagents of the root
session `48857ffb-f0e5-4af1-9b36-ecddce7fb416`, at the path the SKILL.md names. Command:
`bash <script> "<...>/.scratch/program/<N>/decisions.tsv" "<...>/48857ffb-.../subagents/agent-<id>.jsonl"`.

| ticket | writer lane | exit | result |
| --- | --- | --- | --- |
| 103 | `agent-a91d9f1cee64cb2f2` | 0 | `ok: 47 rows in order inside the run 2026-09-23T02:41:54Z to 2026-09-23T08:56:24Z` |
| 105 | `agent-a5809216d2cd24bda` | 1 | header refused + 22 rows `has 5 columns, expected 6; not a log.sh stamp` |
| 106 | `agent-aa93144dff7a44365` | 1 | header refused + 18 rows, same two reasons |
| 107 | `agent-a259c8b9e8547f7dd` | 1 | header refused + 20 rows, same two reasons |
| 110 | `agent-a292885989e3b0d34` | 1 | 24 rows `not a log.sh stamp` (header is the template's) |
| 111 | `agent-ac0fc71652f8accb3` | 0 | `ok: 11 rows in order inside the run 2026-09-23T13:04:03Z to 2026-09-23T13:33:37Z` |

Every refusal is a true one, and I checked the transcripts to say so rather than inferring it from the file:

- 105 appended with `printf '%s\n' "$(date +%H:%M)\t..."` — local wall clock, no date, five columns. The trail reads
  `21:42`, `21:44`, ... while the lane's own transcript runs on the same UTC day as 106 and 107. True refusal.
- 106 and 107 appended with a bare `printf '%s\t<decision>\t<why>\t<evidence>\t<result>\n'` and a typed `ts`
  (`2026-09-23T03:57:46`, no `Z`; `2026-09-23 06:08:40`, a space). True refusals.
- 110 is the sharpest one. The lane *started* with `log.sh` (`bash $S $L start "branched ..."` in its own worktree),
  then rewrote the whole file with the Write tool and flattened every stamp to the date `2026-09-22` — seven Write
  calls, the last versions typed row by row. The real stamps existed and were replaced by a typed date. This is exactly
  the failure the ticket names, and the check catches it.
- 103 and 111 are true passes: both lanes appended only through `log.sh` (103 by absolute path to its worktree's
  `.claude/skills/.../log.sh`, 111 through `template/.agents/skills/.../log.sh`), so every row carries a `date -u`
  stamp and every one falls inside its lane's transcript span.

So on this run the check's verdict is right six times out of six, with no false refusal.

## (b) Adversarial cases

Fixtures: a transcript from `2026-09-22T10:00:00.900Z` to `11:00:00.100Z` (so the cut to the second is exercised on
both ends), a second from `14:00` to `15:00`, plus degenerate ones. Every case below ran against the script at the SHA.

| case | output | exit | misleads? |
| --- | --- | --- | --- |
| two rows with equal `ts` | `ok: 2 rows ...` | 0 | no — `log.sh` can stamp two rows in one second, and the order test is `<`, not `<=` |
| row at `09:59:59Z`, one second before the first record | `line 2 ...: outside the run 2026-09-22T10:00:00Z to 2026-09-22T11:00:00Z` | 1 | no |
| row exactly at the cut bound `10:00:00Z` | `ok: 1 rows ...` | 0 | no — the `.900` cut is what makes this row legitimate |
| `+00:00`, `+02:00`, `-05:00` suffixes | three `not a log.sh stamp` lines | 1 | no |
| fractional seconds `10:30:00.500Z` | `not a log.sh stamp` | 1 | no |
| whole file CRLF | `line 1: header is not the template's` | 1 | no |
| CRLF rows, LF header | `ok: 1 rows ...` | 0 | mildly — see Notes 1 |
| header only | `ok: 0 rows in order inside the run ...` | 0 | no |
| a tab inside a field | `line 2 ...: has 7 columns, expected 6` | 1 | no — the reason names columns, not the tab, which is the same defect |
| missing transcript | `jq: error: Could not open file gone.jsonl` on stderr | 2 | no |
| transcript with no `timestamp` on any record | `no timestamp in notime.jsonl` on stderr | 2 | no |
| one good transcript + one untimed one | `ok: 2 rows ...` | 0 | no — the untimed file contributes nothing and cannot narrow the bounds |
| two sessions (resume), both given | `ok: 2 rows in order inside the run 10:00:00Z to 15:00:00Z` | 0 | no |
| two sessions, only the first given | `line 3 2026-09-22T14:30:00Z: outside the run ... to 11:00:00Z` | 1 | no — a true refusal of the reviewer's own omission, and the message names the bound so the fix is obvious |
| a row inside the gap between the two sessions (`12:00`) | `ok: 3 rows ...` | 0 | by design: the run is first to last across the transcripts given, not a union of spans |

Extra probes:

| case | output | exit | misleads? |
| --- | --- | --- | --- |
| lowercase `z` | `not a log.sh stamp` | 1 | no |
| `25:99:99Z` (outside the bounds lexically) | `outside the run ...` | 1 | no, but the reason is the wrong one — see Notes 2 |
| `2026-13-45T10:30:00Z` | `outside the run ...` | 1 | same |
| `13:99:99Z`, lexically *inside* the bounds | `ok: 1 rows ...` | 0 | yes, narrowly — see Notes 2 |
| leading space in `ts` | `not a log.sh stamp` | 1 | no |
| last row with no trailing newline | `ok: 1 rows ...` | 0 | no |
| trailing blank line | `line 3 : has 0 columns, expected 6; not a log.sh stamp` | 1 | no |
| transcript whose `timestamp` is `"not-a-time"` | `outside the run not-a-timeZ to not-a-timeZ` | 1 | see Notes 3 — refuses, which is the safe direction |
| a directory passed as a transcript | (nothing) | 2 | see Notes 4 |
| a typed time that happens to fall inside the run | `ok: 1 rows ...` | 0 | inherent, see Notes 5 |

## (c) `log.sh` and a typed time

`log.sh` takes six arguments and stamps `ts` itself (`template/.agents/skills/show-me-your-work/scripts/log.sh:23`,
`ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"`); there is no argument that reaches `ts`.

- A caller who passes a time as the first cell gets it in `phase`, not `ts`:
  `log.sh c1.tsv 2026-01-01T00:00:00Z decision why ev res` wrote
  `2026-09-23T13:37:38Z<TAB>2026-01-01T00:00:00Z<TAB>decision<TAB>why<TAB>ev<TAB>res`. The typed time is visible in the
  wrong column and the real stamp is intact.
- A caller who tries to prepend `ts` and pass seven arguments is refused: exit 1,
  `usage: log.sh <logfile> <phase> <decision> <why> <evidence> <result>` (`log.sh:6-9`).
- `TZ=Asia/Tokyo log.sh ...` still stamps UTC (`date -u`): the row read `2026-09-23T13:37:39Z` against a concurrent
  `date -u` of `2026-09-23T13:37:39Z`. The environment cannot move the stamp.
- A row `log.sh` wrote between two transcript records passes the check: `ok: 1 rows in order inside the run
  2026-09-23T13:37:38Z to 2026-09-23T13:37:39Z`, exit 0. `log.sh` and `check-trail.sh` agree on the same second.

## (d) The trail review's instructions at the SHA

`template/.agents/skills/show-me-your-work/SKILL.md:68`, under "## Cross-model review of the trail", first sentence of
the new paragraph:

> The reviewer first runs `scripts/check-trail.sh <logfile> <transcript>...` with the transcript of every lane that
> appended to the log.

and, in the same paragraph:

> Exit 1 refuses the trail as a timing record: its lines go first under Attention, verbatim, and the post-mortem times
> the run from the transcript instead. The refusal does not block merge-ready, because the log is append-only and its
> rows stay as written. Exit 2 means the check did not run: fix the path and rerun, or write `trail clock not checked:
> <message>` under Attention.

Yes, an agent following this does the right thing, and I tested the parts an agent could get wrong:

- The transcript path it gives (`~/.claude/projects/<encoded-cwd>/<session>/subagents/agent-<id>.jsonl`, the main
  session's as `<session>.jsonl` beside it) is where all six writers' transcripts actually are. Every lane of this run,
  including lanes that launched their own lanes, sits flat in the one `subagents/` directory of the root session, so
  "every lane that appended" is reachable without walking a tree.
- "first" is unambiguous: the paragraph sits above the flag list, and the Attention section is already the required
  ending (`SKILL.md:76`), so a refusal has a defined place to go.
- The exit-2 wording is the only soft spot (Notes 4).

## Issues

None. Every refusal the script produced in this slice was earned, and the two passes were earned.

## Notes

1. CRLF rows under an LF header pass (exit 0). `NF` is still 6 and `ts` is untouched, so the timing verdict is right;
   the trailing `\r` just rides in the last cell. The test covers the CRLF header, which is the case that matters.
2. The `ts` test is a shape regex plus a string comparison, not a date parse, so an impossible clock value is judged by
   where it sorts. `2026-09-22T25:99:99Z` and `2026-13-45T10:30:00Z` are refused, but as "outside the run" rather than
   as nonsense; `2026-09-22T13:99:99Z` between bounds of `10:00:00Z` and `15:00:00Z` passes as `ok`. A lane that types a
   time is by hypothesis typing a plausible one, so this is a curiosity, not a hole worth code. It is also what keeps
   the script free of the GNU/BSD `date` split that `docs/M0-findings.md:222` records.
3. A transcript whose `timestamp` is a non-time string yields bounds like `not-a-timeZ` and refuses every row (exit 1).
   It fails safe, and the nonsense bound is printed in the message, so a reviewer sees what happened.
4. A directory passed where a transcript belongs exits 2 with nothing on stdout or stderr on this host. The SKILL.md
   tells the reviewer to write `trail clock not checked: <message>` under Attention; in this one case there is no
   message to quote. Small and self-diagnosing (the reviewer typed the path), so I would not change code for it.
5. The check cannot catch a typed time that lands inside the run's span; only the format, the order and the bounds are
   provable from the transcript. P111 in `docs/knowledge/core/DECISIONS.md` says as much ("bounds passed as arguments
   would move the typing to the reviewer"). On this run it did not matter: all four typed trails were typed in a shape
   the format test rejects.
6. Not my slice, so untested here: the `docs/M0-findings.md:222` claim of identical output under mawk and gawk in
   `ubuntu:24.04`, and the claim that the design lane ran the check against the #88-#93 trails. Everything above is
   macOS `/usr/bin/awk` and jq 1.7.1-apple.
