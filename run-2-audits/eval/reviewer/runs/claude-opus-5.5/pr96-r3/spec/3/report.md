## Walk

1. Factory CI: `factory-ci.yml:19-20` replaces `bash -n` with the gate over `factory918.sh`, the gate, hooks, every `template/.agents/skills/*/scripts/*.sh` and `tests/*/*.sh`; `:21-22` runs `tests/shellcheck/gate.sh`.
2. Pin: `shellcheck.sh:15-17` holds 0.11.0 and two sha256s; an on-pin `shellcheck` on PATH is used (`:20`), otherwise the release tarball is fetched once and its sha checked and extracted on every run (`:27-33`), which closes blast-radius risk 1.
3. Unpinned platform: refused on stderr, exit 1 (`:24`), asserted by test 6. Risk 2 (a future 0.11.0 in `/usr/bin` breaks test 6) stands; nothing changes it.
4. Checksum mismatch: refused with `sha256sum`'s own warning, exit 1, matching the design row. A download cut off mid-transfer leaves a partial `sc.tar.xz` that is never fetched again (test 9 asserts that), and the `FAILED` line naming the file goes to `/dev/null`. It fails loudly and is not counted.
5. Globs: `IFS=` stops splitting on spaces; an argument that matches nothing is refused even beside matches (`:37-43`), which closes risk 3. Tests 3, 3b, 8 and 8b cover it.
6. Template CI: `ci.yml:17-18` runs the zero-argument form (hooks, skill scripts, the gate). The fixture job runs the same step in `/tmp/fx` (`factory-ci.yml:54-56`).
7. Playbook: the patch and the vendored `opening-a-pr.md` name the gate on every changed shell file before the PR opens.
8. Doctor: prints PASS with the version, or NOTE with `brew install shellcheck` and the apt, dnf and winget equivalents (`factory918.sh:274-276`). An off-pin version passes, which the criterion allows.
9. Directives: every `disable=` in the diff has its reason on the same line, overlap.sh's included. Root `CODING_STANDARDS.md` Bash section states the rule, and the file's header names the Standards axis as its reader.
10. `AGENTS.md` Verifying lists the command and the gate test. `M0-findings.md` has the dated ShellCheck 0.11.0 section.
11. The `models sheet`, `${skills:?}`, the `dirs` count and `fake-gh.sh` edits are finding fixes the "passes at the merge commit" criterion needs.
12. Risks 4 and 5 (an offline lane, a project `ci.yml` that conflicts on update) are loud or out of scope. No code covers them, and none was asked for.

## Would break

## Fails open

## Not asked for

1. **Template prose beyond the named files.** `template/AGENTS.md` gains a Shell line and `template/CODING_STANDARDS.md` gains the directive rule. Both follow from the "universally designed feature" decision, and neither is named in a criterion.

```
- [ ] `AGENTS.md` Verifying lists the command, and a dated line in `docs/M0-findings.md` records the version verified.
```

hard findings: 0
