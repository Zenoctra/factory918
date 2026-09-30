## Walk

1. AC1, factory CI. `factory-ci.yml:19` runs the gate over `factory918.sh`, the gate itself, `template/.claude/hooks/*.sh`, `template/.agents/skills/*/scripts/*.sh` and `tests/*/*.sh`; the removed `bash -n` set is a subset (its two named skill directories fall inside the `*` glob). The version is exact: `grep -qx "version: 0.11.0"` accepts the runner's copy only at the pin, otherwise a release tarball is downloaded and checksummed (`shellcheck.sh:17-31`).
2. AC2, project CI. `template/.github/workflows/ci.yml:17-18` runs the zero-argument form, which is `.claude/hooks/*.sh`, `.agents/skills/*/scripts/*.sh` and the gate (`shellcheck.sh:34`). `cmd_apply`'s `find . -type f` plus `cp -p` (`factory918.sh:131-138`) puts the gate in the project; `factory-ci.yml:54-56` runs it inside `/tmp/fx`.
3. AC3, playbook. The patch (`opening-a-pr.md.patch:8`) and the vendored copy carry the same sentence; `SOURCES.md:15` records it, so `sync` reproduces it.
4. AC4, doctor. `factory918.sh:274-276` prints `PASS shellcheck <version>` or calls `note`, which never touches `fail`, so a machine without it stays NOTE and the fix names brew, apt, dnf and winget.
5. AC5, directives. `CODING_STANDARDS.md:15`, in the Bash section, states the same-line reason rule; the template's `Suppressions` section repeats it for projects; every directive the diff adds or edits carries a reason.
6. AC6, records. `AGENTS.md:38-39` lists both commands; `docs/M0-findings.md:170` is the dated line with the pin and both sha256s. The commit order does not show the test before the implementation (rule 3): `1208407` carries the gate and `tests/shellcheck/gate.sh` together, though the test's cases do track the table's rows rather than the code.
7. Risk 1, a tampered cache. No longer reachable: the sha is checked on every run and `tar -xJf` re-extracts over the binary (`shellcheck.sh:28-30`), so the grounding's risk text is stale against `a64c7e6`.
8. Risk 2, a runner image shipping 0.11.0 in `/usr/bin`. Real, and costs a red factory CI with no code fault; test 6 hides ShellCheck by narrowing PATH (`gate.sh:71`).
9. Risk 3, a silently dropped glob. No longer reachable: `matched=0` refuses on stderr even beside globs that matched (`shellcheck.sh:36-43`), asserted by test 3b.
10. Risk 4, an offline lane. Refused loudly by curl or by the platform line (`:20-22`), which is the design's own row.
11. Risk 5, a project whose `ci.yml` conflicts on update. `cmd_update` names the conflict and writes `ci.yml.factory-merge` (`factory918.sh:357-362`), so a missing gate is loud, not silent.

## Would break

## Fails open

## Not asked for

hard findings: 0
