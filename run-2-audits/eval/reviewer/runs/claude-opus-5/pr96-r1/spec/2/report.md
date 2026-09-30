## Walk

1. Factory CI: `bash -n` is replaced by the gate over five arguments (`factory-ci.yml:19`); those globs name exactly the 18 files the criterion lists, plus `factory918.sh` and the gate, so the count line reads 20.
2. Pin: `version=0.11.0` with both release sha256s in the script (`shellcheck.sh:13-16`); PATH's copy is used only when `--version` matches `version: 0.11.0` exactly (`:20`), otherwise the release is fetched.
3. Template CI: `check` gains `bash .github/shellcheck.sh` first (`ci.yml:17-18`); the zero-argument set is `.claude/hooks/*.sh`, `.agents/skills/*/scripts/*.sh` and the gate itself (`:37`). `cmd_apply`'s `cp -p` carries the 755 mode, and the fixture job runs the same step in `/tmp/fx`.
4. Playbook: the `**PRs.**` paragraph names the gate before the PR opens, in the vendored copy and in the patch, so `sync` keeps it.
5. Doctor: a `shellcheck` line above `slots filled`, PASS with the version or NOTE with `brew install shellcheck` and the three other package managers; never FAIL.
6. Prose: the disable-with-reason rule in both `CODING_STANDARDS.md` files, the command in both `AGENTS.md`, a dated M0 line carrying the version and both checksums, P25.
7. Risk 1 (cached binary, no checksum): real, and the cached binary's version is not re-checked either; it is machine state, not caller input, and a CI runner is fresh. Not counted.
8. Risk 2 (test 6 breaks when the runner ships 0.11.0): a red CI with no code fault, loud. Not counted.
9. Risk 3 (an unmatched glob among matched ones): counted below as [P1].
10. Risk 4 (offline or unpinned platform): refused with the tool's own message, exit non-zero. Not counted.
11. Risk 5 (`ci.yml` merge conflict on `update`): `git merge-file` leaves `ci.yml.factory-merge` and says so. Not counted.

## Would break

## Fails open

1. **A path or glob that matches nothing is dropped in silence whenever another matches.** `files` accumulates over all arguments and the refusal fires only when the total is zero (`template/.github/shellcheck.sh:38-44`), so `shellcheck.sh a.sh typo.sh` checks one file, prints `files checked: 1` and exits 0. The lane's documented use is a list of changed files, where a stale or mistyped path is the likely error; CI's five globs shrink the same way after a directory is renamed. The count line is the only tell, and nobody reads it on a green step.

Documented step: ticket `## Design`, and the playbook line the patch adds.

```
| A glob matches no file | `shellcheck.sh: no file matched <globs>; the gate checked nothing` on stderr | 1 | fixes the glob; a gate that checked nothing is not a pass |
```

```
Run `bash .github/shellcheck.sh` on every shell file the diff changes before the PR opens
```

Result: exit 0 with the unmatched argument silently unchecked; only an all-miss is refused. `tests/shellcheck/gate.sh:57` asserts the single-glob case, so the gap is untested.

## Not asked for

hard findings: 1
