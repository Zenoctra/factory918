# Outside the list

3 runs per brief with claude-fable-5-1 at high, mode work; one blind judge pass (claude-opus-5-5 at high) over all 6 outputs. Safety check: no problems.

## Counts

Per run: distinct findings, how many the list names, how many it does not.

| Run | findings | on the list | outside the list | minutes | ok |
|---|---|---|---|---|---|
| with-1 | 25 | 13 | 12 | 11.0 | True |
| with-2 | 24 | 12 | 12 | 9.4 | True |
| with-3 | 28 | 13 | 15 | 11.2 | True |
| without-1 | 13 | 2 | 11 | 9.9 | True |
| without-2 | 18 | 3 | 15 | 10.2 | True |
| without-3 | 16 | 4 | 12 | 9.4 | True |

- **with**: 32 distinct findings across its runs; 13 on the list, 19 outside it.
- **without**: 24 distinct findings across its runs; 5 on the list, 19 outside it.
- Outside the list and found only by **without**: 3; only by **with**: 3.

## Each list item: how many runs found it

| Item | with | without |
|---|---|---|
| L1. the download path of template/.github/shellcheck.sh on a machine without ShellCheck at the | 3/3 | 3/3 |
| L2. the download path on a runner whose uname pair is unpinned | 3/3 | 0/3 |
| L3. a cached binary under ${TMPDIR:-/tmp}/shellcheck-0.11.0 that is reused without a checksum  | 3/3 | 0/3 |
| L4. tar -xJf needing xz | 3/3 | 0/3 |
| L5. sha256sum versus shasum | 3/3 | 0/3 |
| L6. a project whose ci.yml was edited locally so factory918 update leaves a .factory-merge and | 3/3 | 0/3 |
| L7. the fixture job's new step | 2/3 | 1/3 |
| L8. cmd_apply copying template/.github/shellcheck.sh with its mode | 3/3 | 2/3 |
| L9. the factory-root symlink .github/shellcheck.sh under actions/checkout and under the sync c | 3/3 | 0/3 |
| L10. the removed bash -n step (does ShellCheck refuse everything bash -n refused?) | 3/3 | 0/3 |
| L11. a glob that matches nothing in a project that deleted its hooks | 3/3 | 0/3 |
| L12. the source-path=SCRIPTDIR directives | 3/3 | 2/3 |
| L13. the set -f claim in the delegation.sh directive reasons (is set -f really on at that point | 3/3 | 1/3 |

## Findings outside the list

| Finding | with | without |
|---|---|---|
| The download path and the pinned Linux checksum have not been tested at rung 4 on any machine; only the PR's fixture CI job will exercise them, and a wrong dige | 3/3 | 3/3 |
| The delegation.sh hook (and the other shipped scripts the diff touches) changed only in comment lines; the code with comments stripped is identical, and 55 hook | 3/3 | 3/3 |
| The cmd_sync edits are equivalent: ${skills:?} can never fire because skills is derived from TEMPLATE, the array count matches the old ls|wc count (72), and syn | 3/3 | 3/3 |
| The new doctor shellcheck line is only ever PASS or NOTE and sits above 'slots filled', so factory-start day zero and factory-doctor's table are unaffected; the | 3/3 | 3/3 |
| The cross-cutting predicate at review-brief.sh:189 does not match .github/shellcheck.sh or the workflows, so later edits to the gate get no blast-radius brief. | 1/3 | 1/3 |
| While a review is in progress, the hook still reads .claude/state/review unchanged, and its Bash scanner never blocks running the gate. | 3/3 | 2/3 |
| The vendored, unpatched show-me-your-work log.sh and worktree-audit.sh are now linted. They pass today, but an upstream bump that introduces a finding would nee | 3/3 | 3/3 |
| wizard/template.sh is outside every gate glob yet has a real SC2034 at line 19, so widening the glob would turn CI red, and a lane that edits it fails a gate th | 3/3 | 3/3 |
| wizard/SKILL.md:41 still tells readers to run bash -n. | 2/3 | 0/3 |
| The file-level SC2016 directive at review-brief.sh:17 would also hide any future genuine SC2016 in that file. | 3/3 | 2/3 |
| At the factory root, the zero-argument form checks only 6 of the 20 files and still passes, giving a misleading green result. | 1/3 | 1/3 |
| Check 6 in tests/shellcheck/gate.sh hardcodes PATH with /usr/bin and assumes no ShellCheck 0.11.0 there; a runner image that ships 0.11.0 would make the test fa | 1/3 | 1/3 |
| After update, an existing project whose hooks were edited (and so kept) or that has its own scripts is linted by the new first CI step and can go red. | 0/3 | 2/3 |
| The doctor prints PASS for any ShellCheck version (for example apt's 0.10.0), even though the gate will ignore that copy and download the pin. | 1/3 | 1/3 |
| The doctor's shellcheck NOTE says the gate will download the tool and that its absence blocks nothing, which is false in an offline sandbox. | 1/3 | 1/3 |
| The fixture's apply step pipes through tail -30, and the extra doctor line pushes one more line out of the visible log; this affects display only. | 2/3 | 3/3 |
| update writes the gate with mode 0644, which is harmless because every documented call starts with bash. | 1/3 | 0/3 |
| The knowledge build and check stay clean, and P25 is generated into template/docs/factory918/DECISIONS.md. | 3/3 | 3/3 |
| The fake-gh.sh:15 rewrite from an && || chain to an if keeps the same two branches. | 0/3 | 1/3 |
| The line shifts in delegation.sh break no delegation.sh:<n> citation, because none exist outside research/. | 0/3 | 1/3 |
| The gate and the CLI changes run correctly under macOS's bash 3.2. | 1/3 | 1/3 |
| Checked for SIGPIPE misfires in the version check at shellcheck.sh:18; 0 of 300 runs misfired. | 1/3 | 0/3 |

## Files

- `brief.with.md`, `brief.without.md`, `list.txt`: the inputs.
- `runs/<brief>-<n>/output.md`: each run's final message and the files it wrote; `stream.jsonl` its events.
- `judge.json`, `blind-key.json`: the judge's findings by blind id, and which id was which run.
- `judged-items.jsonl`: the judge's list-item calls, for `judge-agreement.py`.
