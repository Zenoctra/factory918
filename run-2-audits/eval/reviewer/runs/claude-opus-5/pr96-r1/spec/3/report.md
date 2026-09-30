## Walk

1. Criterion 1: `factory-ci.yml:19` runs `bash .github/shellcheck.sh` with the four globs plus `factory918.sh` and the gate itself; the root path is a symlink to the template's copy, and the version is pinned in the script (`version=0.11.0`), used from PATH only when `--version` matches exactly.
2. Criterion 1: `741bc89` resolves the 57 findings, so the set passes at the tip.
3. Criterion 2: `template/.github/workflows/ci.yml:17-18` runs the zero-argument form, whose defaults are `.claude/hooks/*.sh`, `.agents/skills/*/scripts/*.sh` and the gate; `factory-ci.yml:54-56` runs the same step inside `/tmp/fx`.
4. Criterion 3: the patch and the vendored `opening-a-pr.md` both carry the sentence in the `**PRs.**` paragraph.
5. Criterion 4: `factory918.sh:274-276` prints `PASS  shellcheck <version>` or `note`, above `slots filled`; the fix text names brew, apt, dnf and winget.
6. Criterion 5: `CODING_STANDARDS.md:15` and `template/CODING_STANDARDS.md:37` state the same-line reason rule; `overlap.sh:49` is the model and every new directive follows it.
7. Criterion 6: `AGENTS.md:38` carries the command, `docs/M0-findings.md:170` the dated version and both checksums.
8. Risk 1 (cached binary, no checksum): outside the documented path and only reachable by writing into `${TMPDIR:-/tmp}`; the pin lives in a version-named directory, so a stale pinned build is the same build. Not counted.
9. Risk 2 (`gate.sh:75` assumes no on-pin ShellCheck in `/usr/bin`): a failing test is loud and names the case. Not counted.
10. Risk 3 (an unmatched glob among matched ones): counted below.
11. Risk 4 (offline lane, unpinned platform): refused with the tool's own message and an install line. Not counted.
12. Risk 5 (a project whose `ci.yml` conflicts in `cmd_update`): `git merge-file` reports the conflict and writes `ci.yml.factory-merge`, so the loss is visible at update time. Not counted.

## Would break

## Fails open

1. **One glob that matches nothing is dropped, and the gate still passes.** `template/.github/shellcheck.sh:38-44` collects every match into `files` and refuses only when `${#files[@]}` is 0 across all globs. Rename `tests/` or a skill's `scripts/` and the factory's five-glob run checks 15 files, prints `files checked: 15` and exits 0; nothing fails, and the count line is the only tell.

```
| A glob matches no file | `shellcheck.sh: no file matched <globs>; the gate checked nothing` on stderr | 1 | fixes the glob; a gate that checked nothing is not a pass |
```

Documented step: the `## Design` table row above, and `AGENTS.md:38`, "ShellCheck at the pin over 20 files".
Result: the run reports a smaller count and exits 0, so CI is green on a set the documentation says is 20 files.

## Not asked for

hard findings: 1
