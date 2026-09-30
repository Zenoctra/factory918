## Walk

1. Factory CI: `factory-ci.yml:19` replaces `bash -n` with the gate over `factory918.sh`, the gate, `template/.claude/hooks/*.sh`, `template/.agents/skills/*/scripts/*.sh` and `tests/*/*.sh`. The version and both checksums are pinned in `template/.github/shellcheck.sh:15-17`, and a runner's off-pin ShellCheck triggers the release download.
2. Template CI: `ci.yml:17-18` runs the zero-argument form, which covers `.claude/hooks/*.sh`, `.agents/skills/*/scripts/*.sh` and the gate itself. The fixture job runs the same line in `/tmp/fx`.
3. Playbook: the sentence is added to both the patch and the vendored copy, and the two texts match.
4. Doctor: `factory918.sh:274-276` prints PASS with the version, or NOTE with `brew install shellcheck` plus the apt, dnf and winget equivalents. It never prints FAIL.
5. Directive reasons: every directive in the diff carries a same-line `# reason`, modeled on `overlap.sh:49`. `CODING_STANDARDS.md` Bash states the rule. The file header already says the Standards axis reads it at review time.
6. `AGENTS.md:38-39` lists the command and the test. `M0-findings.md` has the dated 0.11.0 section.
7. Risk 1 (cached binary skips the sha): the brief describes an earlier version. At the head, commit a64c7e6 verifies the tarball's sha on every off-pin run and re-extracts it (`shellcheck.sh:307-310`). The old `[ ! -x "$bin" ]` guard is gone. Test 9 covers a bad cached tarball.
8. Risk 2 (test 6 and a runner with 0.11.0 in `/usr/bin`): still present at `gate.sh:471`. This is a test-environment assumption, not a wrong result on the documented path.
9. Risk 3 (a silent unmatched glob): fixed by 01e5386. `shellcheck.sh:316-323` refuses per glob, and test 3b asserts it.
10. Risk 4 (an offline lane or an unpinned platform): the gate stops with an error that says what went wrong. This matches the design table's platform row.
11. Risk 5 (`update` conflict on `ci.yml`): the conflict lands in `ci.yml.factory-merge`, which the user can see. This is not the documented path for this ticket.

## Would break

## Fails open

## Not asked for

1. **Checksum row simulated.** Test 9 plants a bad tarball, but the design says this row "is the tool's own refusal and is not simulated". The test is harmless and adds coverage.

```
the checksum row is the tool's own refusal and is not simulated.
```

2. **Refactors outside the findings' minimum.** `cmd_sync` now counts with an array instead of `ls | wc -l`. The models-sheet line is rewritten as `if/else`. Both resolve ShellCheck findings (SC2012, SC2015), so the change in behaviour is nil. The ledger line is a process record.

```
passes at the merge commit.
```

hard findings: 0
