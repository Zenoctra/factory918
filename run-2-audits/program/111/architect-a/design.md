# #111 design, runner A: the trail's clock checked against the transcript's clock

Read from `origin/feat/review-reading-pack` at f58308b. Runner A, Opus 5.5.

The shape in two sentences. `log.sh` stays exactly as upstream ships it, and the skill's text is patched so it is the only way a row is written. One new script of ours, `show-me-your-work/scripts/check-trail.sh`, takes the trail and the lane's transcript file(s) and prints one line per bad row. The run's bounds come from the transcripts' own `timestamp` fields, so no agent types a time anywhere, reviewer included. It does no date arithmetic at all, so `date -d` versus `date -j` never arises; it compares fixed-width UTC strings.

## 1. Scenario table

Across the top is the transcript argument, the only input that varies besides the trail. Down the side is the state of the trail and of the transcripts. "Own" is the transcript of the lane that wrote every row. "Every writer" means all lanes that appended, for a trail two owners shared (the #93 run). "Wrong" is a transcript of an unrelated lane.

Legend (every cell is one of these):

- **OK**. stdout `ok: <n> rows in order inside the run <first> to <last>`, exit 0. The caller (the trail reviewer) quotes the line under Attention and goes on with the review.
- **REF[x]**. stdout one line per offending row, `line <n> <ts>: <reason>[; <reason>]`, reasons named by x; exit 1. The trail is refused. The reviewer puts the lines first under Attention, verbatim; nobody edits the rows (append-only); the trail's times are not timing evidence and the post-mortem uses the transcript.
- **ERR[msg]**. stderr msg, exit 2, nothing on stdout. The check did not run. The caller fixes the argument (the right transcript, the right trail path) and reruns; if it cannot, Attention says `trail clock not checked: <msg>`.
- **USE**. stderr `usage: check-trail.sh <trail.tsv> <transcript.jsonl>...`, exit 64.

Reason vocabulary for REF: `H` = the line `line 1: header is not the template's`; `O` = `earlier than line <m> (<ts>)`; `X` = `outside the run <first> to <last>`; `N` = `not a log.sh stamp`.

| # | Situation | no transcript | own | every writer | wrong |
|---|---|---|---|---|---|
| 1 | trail path is not a file | USE | ERR[`no trail at <path>`] | ERR[same] | ERR[same] |
| 2 | trail is 0 bytes | USE | REF[H] | REF[H] | REF[H] |
| 3 | header is not the template's (#91's `ts what why evidence result`, a CRLF file) | USE | REF[H + row lines] | REF[H + row lines] | REF[H + row lines] |
| 4 | header only | USE | OK (0 rows) | OK | OK |
| 5 | every row a `log.sh` stamp, non-decreasing, inside the run | USE | OK | OK | REF[X on every row] |
| 6 | a row on the first or the last second of the run; two rows on the same second | USE | OK | OK | REF[X] |
| 7 | a row earlier than the stamped row above it | USE | REF[O] | REF[O] | REF[O, X] |
| 8 | a row before the first or after the last record | USE | REF[X] | REF[X] | REF[X] |
| 9 | a row both earlier and outside | USE | REF[O; X on one line] | REF[O; X] | REF[O; X] |
| 10 | a ts that is not a stamp (`17:45:00Z`, a blank line, `2026-09-22 10:40:00`) | USE | REF[N]; the row is skipped for ordering, the next row compares with the last stamped row | REF[N] | REF[N, X] |
| 11 | rows from two owners (a relaunched owner reused the trail) | USE | REF[X on the other owner's rows] | OK | REF[X] |
| 12 | a transcript file is missing | USE | ERR[jq's own `Could not open file <path>: No such file or directory`] | ERR[same] | ERR[same] |
| 13 | no transcript line has a `timestamp` | USE | ERR[`no timestamp in <paths>`] | ERR[same] | ERR[same] |
| 14 | a transcript has non-JSON lines or a torn last line (a live lane) | USE | those lines are skipped; the cell is the row's cell above | same | same |

Every cell above was run on macOS (BWK awk, jq 1.7.1-apple) and in `ubuntu:24.04` with mawk and with gawk (jq 1.7), with identical output; see section 7. Row 12 is the tool's own refusal and costs no code.

Real trails, same script, their owners' transcripts (from `.scratch/program/postmortem/timeline.md`): #88, #89 and #90 print OK; #91 prints REF[H] plus 9 X lines (the 9 of 18 the post-mortem found); #93 with both owners' transcripts prints REF[H] plus 14 lines, two of them O at 15:05 and 16:30, the two the post-mortem found. #88's trail against #93's transcript prints X on all 24 rows, which is cell 5/wrong: a wrong transcript is loud, never a silent pass.

## 2. Contract

- **Trail.** A TSV file. Line 1 is the header; every later line is a row. A row's `ts` is the text before its first tab.
- **Template header.** Line 1 of `show-me-your-work/references/decision-log-template.tsv`, read at run time from the script's own directory. It is the same text `log.sh` writes; the check does not keep a third copy.
- **Stamp.** A `ts` matching `YYYY-MM-DDTHH:MM:SSZ` exactly, the format `log.sh` writes with `date -u +%Y-%m-%dT%H:%M:%SZ`. Anything else is not a stamp.
- **Transcript.** A JSONL file whose records carry a top-level `timestamp` in ISO 8601 UTC (Claude Code `~/.claude/projects/<encoded-cwd>/<session>.jsonl` and `<session>/subagents/agent-<id>.jsonl`; Codex `~/.codex/sessions/YYYY/MM/DD/rollout-*.jsonl`; both checked). Lines that are not JSON, and records with no string `timestamp`, are ignored.
- **Run.** From **first** to **last**: the smallest and largest `timestamp` over every transcript given, each cut to its first 19 characters plus `Z`. Cutting floors to the second on both sides, and a row's stamp is also floored, so a row written between the first and the last record always compares inside. No slack: `log.sh` and the harness read the same machine clock.
- **Earlier.** A stamped row whose `ts` sorts before the `ts` of the nearest stamped row above it. Equal is not earlier. Compared as strings, which is chronological for stamps.
- **Outside.** A stamped row whose `ts` sorts before first or after last. Inclusive bounds.
- **Refusal line.** `line <n> <ts>: <reason>` with the reasons for that row joined by `; `, `n` being the file's line number (header is line 1). One line per offending row, in file order; the header line, when present, comes first.
- **Exit codes.** 0 OK, 1 refused, 2 the check could not read its input, 64 usage. The same split `overlap.sh` uses.
- **Not checked, on purpose.** Column count, cell content, a stamp that is suspiciously round (`:00` seconds happen for real), and rows written in a batch at the end (each then carries the late time, which is true). Which transcript is "the lane's own" is the caller's job; a transcript that is too wide (the root session for a whole day) loosens the bounds, and the skill text names the lane's own file.

## 3. Test list

`tests/show-me-your-work/check-trail.sh`, in the style of `tests/poteto-mode/overlap.sh`: a temp fixture root with a space, a `.claude/skills` symlink to `template/.agents/skills` so the script runs by the path skills name, fixture transcripts written with `printf`, one assertion of exit code and exact stdout/stderr per cell, in table order, exit 1 on the first miss.

1. no argument besides the trail: exit 64, the usage line on stderr (cell column "no transcript").
2. trail path missing: exit 2, `no trail at <path>` (1).
3. 0-byte trail: exit 1, stdout exactly `line 1: header is not the template's` (2).
4. #91's five-column header with one inside row: exit 1, the header line only (3).
5. CRLF header: exit 1, the header line (3).
6. header only: exit 0, `ok: 0 rows ...` with the fixture's first and last (4).
7. three stamped rows inside, own transcript: exit 0, `ok: 3 rows ...` (5, own).
8. same trail, a wrong transcript: exit 1, an X line per row (5, wrong).
9. rows on first, first again, and last: exit 0 (6). The fixture's first record has `.900Z` and its last `.100Z`, so the floor is exercised on both ends.
10. rows 10:30, 10:20, 10:40: exit 1, one line `line 3 ...: earlier than line 2 (...)` (7).
11. rows the day before and one second after last: exit 1, two X lines (8).
12. a row both earlier than the one above and before first (10:30, then 09:00 with first 10:00): exit 1, one line `line 3 ...: earlier than line 2 (...); outside the run ...` (9).
13. `17:45:00Z`, a blank line, `2026-09-22 10:40:00`, then 10:20 after a 10:30 row: exit 1, three N lines and `line 6 ...: earlier than line 2 (...)` (10).
14. two owners' rows, only the first owner's transcript: exit 1, X on the second owner's rows (11, own).
15. same, both transcripts: exit 0 (11, every writer).
16. a missing transcript: exit 2, stderr contains `Could not open file` (12).
17. a transcript of `{"type":"custom-title"}` only: exit 2, `no timestamp in <path>` (13).
18. a transcript with a `not json` line and a torn last line after a later-looking prefix: the bounds come from the whole records only, asserted through an `ok` line whose last is the whole record's second (14).
19. `log.sh` writes two rows into a fresh trail between two `date -u` transcript records: exit 0. This ties the stamp format of `log.sh` to the check's.
20. the script and `log.sh` are executable in the index (`git ls-files -s`, mode 100755).

Wire it in `.github/workflows/factory-ci.yml` next to `tests/poteto-mode/overlap.sh`, and add `bash tests/show-me-your-work/check-trail.sh` to `AGENTS.md` "Verifying". The ShellCheck line's count goes from 24 to 26 files (the script and the test).

## 4. Usage

The trail reviewer, per the patched "Cross-model review of the trail":

```sh
# a lane's trail, its own transcript (the launcher has the agent id from the Agent tool result)
.claude/skills/show-me-your-work/scripts/check-trail.sh .scratch/program/111/decisions.tsv \
  ~/.claude/projects/<encoded-cwd>/<session>/subagents/agent-<id>.jsonl
# ok: 23 rows in order inside the run 2026-09-22T14:30:11Z to 2026-09-22T16:08:23Z

# a trail two owners shared: every writer's transcript
.claude/skills/show-me-your-work/scripts/check-trail.sh .scratch/program/93/decisions.tsv \
  .../agent-a73dbb8e2f9e6aec5.jsonl .../agent-a8edee7d294766f8f.jsonl
# line 10 2026-09-22T15:05:00Z: earlier than line 9 (2026-09-22T19:23:59Z); outside the run 2026-09-22T17:49:20Z to 2026-09-22T20:46:16Z
# ...   (exit 1)
```

The writer, unchanged: `scripts/log.sh <logfile> <phase> <decision> <why> <evidence> <result>`.

The post-mortem tooling can call the same script per owner instead of `parse.py`'s own out-of-order and outside logic; that is a later change to scratch tooling, not this ticket.

## 5. Signatures and the script

One file, no functions worth naming. The body below is the version every cell ran against; the writer may reword comments, not behavior.

```bash
#!/usr/bin/env bash
# Refuses a show-me-your-work trail whose clock is not the run's clock: a header other than the
# template's, a ts that is not a log.sh stamp, a row earlier than the row above it, or a row outside
# the run. The run is the first to the last timestamp across the transcripts given, cut to the
# second, so the bounds come from the harness's clock and nobody types them.
# Usage: check-trail.sh <trail.tsv> <transcript.jsonl>...
# Exit 0 with one ok line; 1 with one line per offending row; 2 on unreadable input; 64 on usage.
set -euo pipefail
[ "$#" -ge 2 ] || { echo 'usage: check-trail.sh <trail.tsv> <transcript.jsonl>...' >&2; exit 64; }
trail="$1"; shift
[ -f "$trail" ] || { echo "no trail at $trail" >&2; exit 2; }
header="$(cat "$(dirname "$0")/../references/decision-log-template.tsv")"
bounds="$(jq -rRn '[inputs | fromjson? | .timestamp? | strings | .[0:19] + "Z"] | select(length > 0) | "\(min) \(max)"' "$@")" || exit 2
[ -n "$bounds" ] || { echo "no timestamp in $*" >&2; exit 2; }
awk -F'\t' -v header="$header" -v first="${bounds% *}" -v last="${bounds#* }" '
NR == 1 { if ($0 != header) { print "line 1: header is not the template'\''s"; bad = 1 }; next }
{
  ts = $1; why = ""
  if (ts !~ /^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T[0-9][0-9]:[0-9][0-9]:[0-9][0-9]Z$/) why = "not a log.sh stamp"
  else {
    if (prev != "" && ts < prev) why = "earlier than line " pline " (" prev ")"
    if (ts < first || ts > last) why = why (why == "" ? "" : "; ") "outside the run " first " to " last
    prev = ts; pline = NR
  }
  if (why != "") { print "line " NR " " ts ": " why; bad = 1 }
}
END {
  if (NR == 0) { print "line 1: header is not the template'\''s"; bad = 1 }
  if (!bad) print "ok: " (NR > 0 ? NR - 1 : 0) " rows in order inside the run " first " to " last
  exit bad
}' "$trail"
```

Portability notes, each run, not assumed: the regex spells out repetitions because older mawk lacks `{4}`; string `<` on stamps is a string compare in BWK awk, mawk and gawk because a stamp never looks numeric; `fromjson?` with `-R` is what makes a torn line harmless (plain `jq -n inputs` exits 2 on it); jq is already a hard requirement of the CLI (`factory918.sh` line 74).

## 6. Module map and the skill text

| File | Change | Why |
|---|---|---|
| `template/.agents/skills/show-me-your-work/scripts/check-trail.sh` | new, ours | the deterministic half of criterion 2 |
| `factory918.sh` `cmd_sync` | add `show-me-your-work/scripts/check-trail.sh` to `keep_files` | sync deletes the skill dir and re-copies upstream |
| `template/.agents/skills/show-me-your-work/SKILL.md` | edited in place, then the patch regenerated | criteria 1, 2 and 3 in the text |
| `patches/pstack/show-me-your-work/SKILL.md.patch` | new | the vendoring rule |
| `patches/series` | append the patch | same |
| `SOURCES.md` | item 18: the patch, and that `check-trail.sh` is ours and in `keep_files` | same |
| `tests/show-me-your-work/check-trail.sh` | new | section 3 |
| `.github/workflows/factory-ci.yml`, `AGENTS.md` Verifying | one line each; ShellCheck count 24 to 26 | the test runs in CI |
| `docs/M0-findings.md` | a dated line: the check verified on macOS BWK awk + jq 1.7.1-apple and ubuntu:24.04 mawk and gawk + jq 1.7 | the verifying rule |

Not changed: `log.sh` (it already stamps from `date -u`; a check inside it would never see a hand-typed row, which is the failure), `decision-log-template.tsv`, `docs/agents/evidence.md` (it is about PR evidence files; criterion 3 lands in the skill, where the lane that writes the trail reads it), and the four callers (orchestrate, hillclimb, autonomous-run, figure-it-out) and the Ticket playbook, which all route to the skill by name and inherit the rule.

Why `keep_files` and not a patch that creates the file: the file has no upstream counterpart, so a creating patch is the whole file as `+` lines, which ShellCheck cannot read and a writer cannot edit without regenerating a diff. `keep_files` is the precedent for exactly this (`poteto-mode/scripts/overlap.sh`, the three `spec-review/scripts/*`).

The patched SKILL.md text, three places. The writer runs `/writing-for-agents` on it.

"The format", replacing the template sentence and the `ts` bullet:

> `scripts/log.sh` starts the log with the header row in `references/decision-log-template.tsv`. Columns:
>
> - **ts.** The UTC second `scripts/log.sh` stamped from `date -u` when the row was appended. It is the timeline axis, and it is the timing record the post-mortem tooling reads for how long each phase took, so it must be the clock's time, never a typed one.

"Logging a row", replacing the paragraph that starts "Use the helper":

> Append every row with `scripts/log.sh <logfile> <phase> <decision> <why> <evidence> <result>`, and only with it. It stamps `ts`, writes the header on first use, strips stray tabs and newlines, and prefixes any cell starting with `=`, `+`, `-` or `@` with a single quote so a reviewer opening the log in a spreadsheet doesn't trigger formula execution. Never type a timestamp, and never add a row with `printf`, a heredoc or an editor: on 2026-09-22 two lanes typed times into their trails and the post-mortem could not time their phases. Log a row when the thing happens; a row logged late carries the late time, which is true.

"Cross-model review of the trail", a new paragraph after the first:

> The reviewer first runs `scripts/check-trail.sh <logfile> <transcript>...`, passing the transcript of every lane that appended to the log (the file the audit above reads). It prints one `ok` line and exits 0, or prints one line per offending row and exits 1: a header other than the template's, a `ts` that is not a `log.sh` stamp, a row earlier than the row above it, or a row outside the run, which is the first to the last timestamp in those transcripts. Exit 1 refuses the trail. Its lines go first under Attention, verbatim. Don't repair the rows (the log is append-only); a refused trail's times are not timing evidence. Exit 2 means the check did not run; fix the path and rerun, or write `trail clock not checked: <message>` under Attention.

## 7. What was run

- The prototype and a cell runner in the scratchpad (`p/skill/scripts/check-trail.sh`, `p/run.sh`, `p/in-ubuntu.sh`). All 15 prototype cells on macOS (`/usr/bin/awk`, jq 1.7.1-apple), then `docker run ubuntu:24.04` with `/usr/bin/mawk` and again with `/usr/bin/gawk` (jq 1.7). The three outputs are identical apart from temp paths and the live-cell second.
- Against real data: `.scratch/program/{88,89,90,91,93}/decisions.tsv` with the owners' transcripts under `~/.claude/projects/-Users-...-factory918/b4a8ae9c-.../subagents/`. Results in section 1; they agree with `timeline.md`.
- Transcript formats: a Claude Code subagent JSONL and a Codex 0.154.0 rollout both carry a top-level `timestamp` like `2026-09-18T00:12:54.070Z`; Claude Code session files also hold records with no `timestamp` (`custom-title`, `agent-name`, `last-prompt`), which the check ignores.

## 8. Rationale and choices

- **Bounds from transcript files, not typed arguments.** The ticket's failure is an agent typing a time. A `--start/--end` interface moves the typing to the reviewer. A path is something the reviewer finds, not invents, and a wrong path is loud (every row X), as the #88-against-#93 run shows.
- **No slack, no date parsing.** The post-mortem's five minutes of slack existed because it compared hand-typed times. `log.sh` and the harness share the clock; flooring both sides to the second makes the inclusive compare exact. With no arithmetic, the BSD/GNU `date` split never appears, and neither does awk's non-POSIX `mktime`.
- **Header checked.** A header other than the template's means the file was not started by `log.sh`, and the post-mortem reads columns by position (#91 and #93's five-column trails lost their phase column). One line of refusal, no parsing.
- **Immediate predecessor, not running maximum, for "earlier".** Matches `parse.py` and names one inversion per bad row. Against a running maximum, one future-typed row would flag every later row; that row is already flagged X.
- **One line per row with reasons joined.** The criterion asks for a line naming the rows; one line per row keeps a row's count honest when it is both earlier and outside.
- **The refusal does not block merge-ready.** The code in the PR is not wrong, and the rows cannot be fixed without editing history. The refusal is reported under Attention, where the owner and the human see it. If the orchestrator wants a block, Ticket step 9 (ours, no patch) is the one sentence to add.

## 9. Open points for the orchestrator

- **Hillclimb conflicts with criterion 1.** `poteto-mode/playbooks/hillclimb.md` step 3 opens a `decision.tsv` "via show-me-your-work" with nine columns of its own (id, hypothesis, change, before, after, ...), written by hand. After this change the skill says rows come only from `log.sh`, and the check refuses that file on its header. I would not widen this PR; a follow-up ticket should rename hillclimb's attempt table (for example `attempts.tsv`) and keep a separate `log.sh` trail. Flag it on the PR.
- **The owner brief.** `.scratch/program/owner-brief.md` is outside the repository; the orchestrator should make it say "append with `scripts/log.sh`" so the next run's owners see the rule before they open a trail.
- **Finding the transcript.** The skill already sends the reviewer to the transcript without saying how to find a subagent's file. The launcher has the agent id from the Agent tool result, and the file is `~/.claude/projects/<encoded-cwd>/<session>/subagents/agent-<id>.jsonl`. If the synthesizer wants that path in the patched text, it is one clause.
