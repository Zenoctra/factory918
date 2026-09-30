# #111 writer report

For a person: all four commits are on `wt/111-writer`, and every cell of the #111 table has an assertion that passes on macOS awk, mawk and gawk. Nothing is pushed, and no cell was left out. The list below is the choices and risks the owner decides on.

HEAD `bd15a62a8cf8e59ccc35934e2f00594a67fe0421`

```
bd15a62 Run the trail clock test in CI and list it under Verifying, #111
65ab87a Say trail rows come only from log.sh, and run check-trail.sh in the trail review, #111
27bb48e Add check-trail.sh, which refuses a trail whose clock is not the run's, #111
54c65ac Test the trail clock check cell by cell, #111
```

## Act-on list

1. Choice: reason order. A row's reasons are joined with `; ` in a fixed order: C (columns) first, then N or O, then X. N and O never occur together because a row that is not a stamp is not ordered. The script's header comment says this. Tests pin C;N (row 11, the blank line), C;X (rows 3 and 4 under the wrong transcript) and O;X (rows 8 and 10).
2. Choice: a blank line has 0 columns. awk gives NF=0 for an empty line, so the line reads `line 4 : has 0 columns, expected 6; not a log.sh stamp`. There is a space before the colon because the ts is empty. Counting tabs + 1 would say 1 column. I kept NF because it is the simplest. Rule on it if the text matters.
3. Interpretation, row 15 ("the cell is the row's cell above"). I read it as "the same result the transcript gives without its bad lines", not as literally row 14's ERR. The test runs row 6's trail against `own` + `not json` + a torn record whose prefix would widen the run to 23:59. The result is row 6's cells: OK, OK, and X on every row for wrong.
4. Interpretation, row 3 CRLF. A CRLF file with the template header and one six-column row prints only H under own and every writer, plus X under wrong. The `\r` stays in the last field, so the column count is still 6 and C does not fire. Tested.
5. Row 9 fixture. The spec wants REF[X] under every writer as well as own. So the rows are `09:59:59` (one second before own's first, which is also every writer's first) and `13:00:01` (one second after every writer's last). No row sits one second after own's last. Row 7 pins that own's last second is inside.
6. Row 13 matches on a pattern: the test asserts exit 2, empty stdout, and a stderr containing `Could not open file t/gone.jsonl`. jq's full wording differs between versions (1.7.1-apple and 1.7), so an exact match would be brittle. This is the only non-exact assertion.
7. CI path. `ubuntu-latest` ships mawk as `awk` and a preinstalled jq, so CI takes the mawk path. Proven in `docker run ubuntu:24.04` (jq 1.7) with `/usr/bin/mawk` and again with `/usr/bin/gawk`: `ok 66 assertions` on both. Locally, macOS `/usr/bin/awk` with jq-1.7.1-apple gives `ok 66 assertions`. The runner script is in my scratchpad and I did not commit it.
8. Record for the owner to write: the design's module map asks for a dated `docs/M0-findings.md` line (the check verified on macOS BWK awk + jq 1.7.1-apple and on ubuntu:24.04 mawk and gawk + jq 1.7, 2026-09-23). The brief said I don't edit that file, so it is not in the diff.
9. SKILL.md wording. The skill text says `a lane never types a row or a timestamp`, not the design's longer ban (no printf, no heredoc, no editor, plus the 2026-09-22 story). This follows `/writing-for-agents` on negation and sediment. The 2026-09-22 incident is in the ticket and the PR, not in the skill. The template sentence also changed: it used to say "Copy the template to start a log", which conflicts with "only through log.sh". It now says `log.sh` starts the log with that header.
10. Risk carried over from the design (section 9): hillclimb step 3 opens a hand-written nine-column `decision.tsv` "via show-me-your-work". After this change, check-trail.sh refuses that file on its header. This is not widened here. It needs a follow-up ticket.
11. The ShellCheck count is 26 (the new script and its test), as the tool reports. The CI step is named "check-trail.sh passes and refuses the trails the test says" and sits right after overlap.sh in `.github/workflows/factory-ci.yml`.
12. Deslop pass: in the test, the CRLF fixture is now one `printf` instead of a `trail` plus `sed` into a second file, and `check_err` moved up to sit with the other helpers. Both changes are in the last commit. No other slop found. The script's only comment is its header.

## Verification (last lines)

- `bash tests/show-me-your-work/check-trail.sh`: `ok 66 assertions`
- `bash .github/shellcheck.sh ... 'tests/*/*.sh' 'tests/*/*/*.sh'`: `ShellCheck 0.11.0, files checked: 26`
- `bash tests/shellcheck/gate.sh`: `ok 17 assertions`
- `./factory918.sh sync`: `applied  pstack/show-me-your-work/SKILL.md.patch`, then `vendored: 72 skills.`; `git status --porcelain` empty afterwards (check-trail.sh survives through `keep_files`)
- `python3 tools/build_knowledge.py`: `git status --porcelain` empty
- `bash tests/spec-review/no-stale-wording.sh`: `ok: no stale wording`
- `python3 tools/check_knowledge.py`: `knowledge ok: 119 files`
- `bash tests/poteto-mode/overlap.sh`: `ok 57 assertions` (untouched, run as a neighbour check)
- ubuntu:24.04 docker: `/usr/bin/mawk ok 66 assertions`, `/usr/bin/gawk ok 66 assertions`
- The test commit 54c65ac failed on its own before the script existed: `FAIL 1 no transcript ... exit 127`.

Opus 5.5, Claude Code (writer lane).
