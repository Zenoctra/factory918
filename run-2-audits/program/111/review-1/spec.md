## Walk

1. A lane logs a row: `log.sh` writes the header `ts phase decision why evidence result` on first use and stamps `ts` with `date -u +%Y-%m-%dT%H:%M:%SZ`. Unchanged by this diff, as the design says.
2. The skill now says every row is appended only through `log.sh` and a lane never types a row or a timestamp (`template/.agents/skills/show-me-your-work/SKILL.md:861`), and the `ts` bullet names it as the timing record the post-mortem reads (`:840`). The same wording is in `patches/pstack/show-me-your-work/SKILL.md.patch`, `patches/series` and `SOURCES.md` item 18.
3. The trail reviewer runs `scripts/check-trail.sh <logfile> <transcript>...` first, with the transcript of every lane that appended, and the skill says where a subagent's transcript lives (`:892`).
4. Fewer than two arguments: usage on stderr, exit 64. Trail not a file: `no trail at <path>`, exit 2.
5. The header is read at run time from `references/decision-log-template.tsv` (one line, byte-identical to what `log.sh` writes).
6. Bounds: `jq -rRn` takes min and max of the top-level `timestamp` fields across the transcripts, each cut to 19 characters plus `Z`. Non-JSON and torn lines fall out through `fromjson?`; a non-string `timestamp` falls out through `strings`. jq failing exits 2 with jq's message; no timestamp at all exits 2 with `no timestamp in <paths>`.
7. Line 1 that is not the header prints `line 1: header is not the template's`; an empty file reaches the same message from the `NR == 0` END branch.
8. Per row, reasons accumulate in the order columns, then stamp-or-earlier, then outside, joined by `; ` on one line `line <n> <ts>: <reason>`. A row that is not a stamp is skipped for ordering and does not become `prev`, so the next stamped row compares against the last stamped row. Bounds are inclusive with no slack; equal timestamps are not earlier.
9. Clean trail: `ok: <NR-1> rows in order inside the run <first> to <last>`, exit 0. Otherwise exit 1, which refuses the trail as a timing record without blocking merge-ready, because the log is append-only.
10. `check-trail.sh` is in `cmd_sync`'s `keep_files`, so re-vendoring restores it after the pstack skill directory is wiped and before the patches apply.
11. `tests/show-me-your-work/check-trail.sh` asserts exit code, exact stdout and exact stderr for all four columns of rows 1 to 15, plus a live `log.sh` trail between two transcript records and the two scripts' index modes. It runs in CI and is listed under AGENTS.md "Verifying"; the ShellCheck count moves 24 to 26, matching the two new scripts.

## Would break

## Fails open

## Not asked for

hard findings: 0
