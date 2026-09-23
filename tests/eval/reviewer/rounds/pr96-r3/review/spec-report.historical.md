## Walk

1. Criterion 1: `factory-ci.yml:19` runs the gate over `factory918.sh`, the gate itself, `'template/.claude/hooks/*.sh'`, `'template/.agents/skills/*/scripts/*.sh'`, `'tests/*/*.sh'` — a superset of the `bash -n` set it replaces, single-quoted so the script expands them.
2. The pin: `shellcheck.sh:19-20` takes PATH's ShellCheck only when `--version` is exactly `version: 0.11.0`, else downloads the pinned release and refuses an unpinned platform (`:21-25`). Never the image's own.
3. `factory-ci.yml:21` runs `tests/shellcheck/gate.sh`, one assertion per row of the ticket's `## Design` table plus the argument and mode-bit rows.
4. Criterion 2: `template/.github/workflows/ci.yml:17-18` runs the zero-argument form, whose defaults (`:36`) are the two globs the criterion names plus the gate. `cmd_apply` copies it with `cp -p` (`factory918.sh:137`); `factory-ci.yml:54-56` runs it inside `/tmp/fx`.
5. Criterion 3: the `**PRs.**` paragraph, in the patch (`opening-a-pr.md.patch:8`) and the vendored copy, tells the lane to run the gate on every shell file the diff changes, before the PR.
6. Criterion 4: `factory918.sh:274-276` prints `PASS  shellcheck <v>` or a `note` naming brew, apt, dnf and winget. NOTE, not FAIL, and above `slots filled`.
7. Criterion 5: `CODING_STANDARDS.md:15` requires the reason as a second comment on the same line; `overlap.sh:49` is the model and now carries one, as do the eight new directives.
8. Criterion 6: `AGENTS.md:38` lists the command verbatim; `M0-findings.md:170-172` dates it 2026-09-22 with both checksums.
9. Other documentation the diff changes — P25 and its generated twins, `template/AGENTS.md:63`, `template/CODING_STANDARDS.md:37`, `SOURCES.md:15`, `ledger.md:25` — each states what the code does.
10. Risk 1, a cached binary reused unchecked: closed here. `shellcheck.sh:30-33` verifies the sha every run, not only on download, and `tar -xJf` re-extracts over the cached binary. The `[ ! -x "$bin" ]` guard the risk cites is gone.
11. Risk 2, `gate.sh:75` assuming no 0.11.0 in `/usr/bin`: still live. Cost is a red factory CI with an exact `FAIL 6` line; nothing silent, no product path touched.
12. Risk 3, an unmatched glob dropped beside matched ones: closed. `shellcheck.sh:39-46` tracks `matched` per argument and exits 1 on the first miss; `gate.sh:70-71` asserts it.
13. Risk 4, an offline lane: refused loudly — curl's message under `-fsS`, or the platform line at `:24` telling the lane to install by hand.
14. Risk 5, a conflicting project `ci.yml`: `cmd_update` writes `ci.yml.factory-merge` and prints `conflicts .github/workflows/ci.yml`, so the missing step is reported. No criterion asks the doctor to check it.

## Would break

## Fails open

## Not asked for

hard findings: 0
