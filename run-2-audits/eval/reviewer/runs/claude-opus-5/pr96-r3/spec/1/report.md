## Walk

1. Factory CI replaces `bash -n` with `bash .github/shellcheck.sh factory918.sh template/.github/shellcheck.sh 'template/.claude/hooks/*.sh' 'template/.agents/skills/*/scripts/*.sh' 'tests/*/*.sh'` (`factory-ci.yml:19`). The set is a superset of the `bash -n` set it removed: the old loop named only the `spec-review` and `poteto-mode` script directories, the glob names all of them.
2. The pin is exact and not the runner's: `version=0.11.0` with the two release sha256s (`template/.github/shellcheck.sh:12-14`); a PATH copy is used only when `--version` prints `version: 0.11.0` verbatim (`:17`), otherwise the release tarball is fetched once, re-checksummed on every run and re-extracted (`:26-31`).
3. The template's CI runs the zero-argument form first in `check` (`ci.yml:17-18`), whose default set is `.claude/hooks/*.sh`, `.agents/skills/*/scripts/*.sh` and the gate itself (`shellcheck.sh:34`) — the two directories the criterion names. `cmd_apply` copies every file under `template/` (`factory918.sh:131-138`), so a project gets `.github/shellcheck.sh`; the fixture job runs the same line in `/tmp/fx` (`factory-ci.yml:54-56`).
4. The playbook's `**PRs.**` paragraph tells the lane to run the gate on every changed shell file before the PR opens, in the vendored copy and in the patch that regenerates it (`opening-a-pr.md:9`, `opening-a-pr.md.patch:8`).
5. The doctor prints `PASS  shellcheck <v>` or a `note` whose fix is `brew install shellcheck` with the apt, dnf and winget equivalents (`factory918.sh:274-276`); `note`, not `chk`, so a machine without it is never FAIL, and the line sits above `slots filled`.
6. The reason-on-the-same-line rule is in the root standards' Bash section (`CODING_STANDARDS.md:15`) and the template's Suppressions section, with `overlap.sh:49` rewritten as the model; no CI check enforces it.
7. `AGENTS.md:38-39` lists the gate command and the gate's test under Verifying, and `docs/M0-findings.md:170-172` records 0.11.0, both checksums, the 57-to-0 count, and why the severity floor, `--external-sources` and no `--shell` are as they are.
8. A glob matching nothing is refused on stderr before ShellCheck runs, even beside globs that matched (`shellcheck.sh:38-41`); `tests/shellcheck/gate.sh` asserts that row and four others.

## Would break

## Fails open

## Not asked for

hard findings: 0
