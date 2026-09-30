## Walk

1. Factory CI: `factory-ci.yml:19-20` runs `bash .github/shellcheck.sh` over `factory918.sh`, the gate, hooks, every `skills/*/scripts/*.sh` and `tests/*/*.sh`. The symlink resolves to the template copy. The version and both sha256 values are pinned in `template/.github/shellcheck.sh:14-16`. `bash -n` is removed, and ShellCheck covers what it checked.
2. Template CI: `ci.yml:17-18` runs the zero-argument form over `.claude/hooks/*.sh`, `.agents/skills/*/scripts/*.sh` and the gate. The fixture job runs the same step inside `/tmp/fx`.
3. Playbook: the patch and the vendored `opening-a-pr.md` both carry the sentence "run it on every changed shell file before the PR opens". `sync` reproduces the vendored copy.
4. Doctor: the `shellcheck` line prints PASS with the version it finds, or NOTE with `brew install shellcheck` and the equivalents for other platforms. It never prints FAIL. An off-pin version also prints PASS, so the doctor does not report that the gate will download or refuse. The gate's own message covers that case.
5. Directives: every `disable=` in the diff has a same-line reason, and `overlap.sh:49` is the model. The root `CODING_STANDARDS.md` Bash section and the template's Suppressions section state the rule.
6. The root `AGENTS.md` Verifying section lists the command and the gate test. `M0-findings.md` has a dated ShellCheck section. The fixture-flow bullet was not updated with the new fixture step. It already omitted the review-brief step before this diff.
7. Risk 1, the cached binary skips its checksum: real. It needs a planted file in `$TMPDIR`, which is outside the documented path.
8. Risk 2, test 6 depends on the runner image's `/usr/bin`: not a fault today. It would turn red loudly, not silently.
9. Risk 3, an unmatched glob beside matched ones: fixed by `01e5386` (`shellcheck.sh:38-41`). Test 3b asserts the fix.
10. Risk 4, an offline lane or an unpinned platform: the gate refuses with a correctable message. This is the design table's row.
11. Risk 5, a `ci.yml` merge conflict on update: the change lands in `ci.yml.factory-merge`, which is update's documented conflict path. The failure is not silent.

## Would break

## Fails open

## Not asked for

hard findings: 0
