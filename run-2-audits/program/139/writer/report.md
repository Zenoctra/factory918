# #139 writer report

The script now refuses a brief when the ticket body has a writer flags heading line anywhere and the flag check read no flag. Table D's ten cells and the moved C6/f cell are in the suite, and every check below passes.

Branch: `wt/139-writer` (worktree agent-a34f29ee0e14df270), on `origin/feat/unled-review-briefs` at e710e99. Not pushed.

- Tests commit: f455c8f "Add the Table D cells for an unreadable writer flags list"
- Script commit: 5f0c725 "Refuse a brief when a writer flags heading yields no flag" (head)

## Before the script commit

I ran a copy of the suite with the refusal and brief assertions made non-fatal, at f455c8f with the e710e99 script. These cells failed (exit 0, wanted 1), in both the project and factory passes: (C6/f, #139), (D2), (D3), (D4), (D5), (D6), (D7). D1, D8, D9 and D10 passed, as the table expects. The copy counted 1842 assertions, 14 short of the final 1856 (7 cells times 2 passes).

## Verification

- `bash tests/spec-review/review-brief.sh`: ok 1856 assertions.
- `bash .github/shellcheck.sh factory918.sh template/.github/shellcheck.sh 'template/.claude/hooks/*.sh' 'template/.agents/skills/*/scripts/*.sh' 'tests/*/*.sh'`: 24 files, exit 0. The same command with the worktree AGENTS.md's extra `'tests/*/*/*.sh'` glob: 26 files, exit 0.
- `bash tests/spec-review/review-comment.sh`: ok 298 assertions.
- `bash tests/hooks/delegation.sh`: ok 55 assertions.
- `bash tests/poteto-mode/overlap.sh`: ok 57 assertions.
- Byte for byte: a scratch harness (`w139/cmp.sh` in the writer session's scratchpad) takes the e710e99 spec-review skill (`git archive`) and the head copy, builds a two-commit repo with the suite's fake gh on PATH, and runs both with `--ticket 7` on two bodies. The bodies are #108 C7/f's body and the fake's fixed body. Both versions exit 0 with empty stderr. `cmp` shows both briefs identical, `diff -r` shows the whole review directory and `.claude/state/review` identical, and stdout and stderr are identical for both bodies.

## Act-on

- C6/f and D3 now assert the same run and the same refusal. The brief asked for both, so I kept both. Keep them, or drop one.
- A body with a heading like `## Writer flag handling` and no list is refused. The legend's heading rule matches it. Accept that, or narrow it.
- D10 is the accepted hole from the contract. One readable list lets a second, unreadable list pass.
- The suite's header comment (lines 48-49) gets one sentence for #139, table D. That was not in the brief's list of edits, but it sits in the allowed file.
