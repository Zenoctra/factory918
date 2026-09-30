## Walk

1. Factory CI: `factory-ci.yml` replaces `bash -n` with `bash .github/shellcheck.sh` over the ticket's four sets plus the gate and its test (20 files), pinned to 0.11.0 by a release download with sha256 check.
2. Template CI: `ci.yml` runs the zero-argument form, which expands `.claude/hooks/*.sh`, `.agents/skills/*/scripts/*.sh` and the gate itself; the fixture job runs the same step inside `/tmp/fx`.
3. Playbook: the patch adds the sentence to `**PRs.**`, `sync` reproduces it, `SOURCES.md` item 3 records it.
4. Doctor: prints `PASS  shellcheck <version>` for any local version, otherwise `NOTE` with `brew install shellcheck` and the apt, dnf and winget equivalents.
5. Directives: every `disable=` carries its reason as a second comment on the same line; `overlap.sh` is updated to the model; the factory's `CODING_STANDARDS.md` Bash section and the template's Suppressions section state the rule.
6. `AGENTS.md` Verifying lists the command and `tests/shellcheck/gate.sh`; `docs/M0-findings.md` has a dated ShellCheck section with the version and both checksums.
7. Risks 1 to 5 from the grounding: 1 and 3 are items below; 2 is test fragility on a future runner image, not a path result; 4 is a loud refusal by design; 5 is `update`'s documented conflict path, which leaves `ci.yml.factory-merge` for the person.

## Would break

## Fails open

1. **A glob that matches nothing is dropped when another glob matches.** The design refuses a gate that checked nothing, but `for f in $g` keeps only files that exist, so a stale glob in the factory's CI list shrinks the set with no message.

```
| A glob matches no file | `shellcheck.sh: no file matched <globs>; the gate checked nothing` on stderr | 1 | fixes the glob; a gate that checked nothing is not a pass |
```

Documented step: ticket #88 `## Design`, the row quoted above; `template/.github/shellcheck.sh:11`.
Result: `bash .github/shellcheck.sh 'template/.claude/hooks/*.sh' 'nope/*.sh'` prints `files checked: 5` and exits 0. A renamed `tests/` or `scripts/` directory passes CI while its files go unchecked.

2. **A cached binary is run without its checksum.** The sha256 check runs only on download. Once `${TMPDIR:-/tmp}/shellcheck-0.11.0/shellcheck-v0.11.0/shellcheck` is executable, it runs whatever it is.

```
| Checksum mismatch | refused with `sha256sum`'s own message | 1 | reports it; the pin or the download is wrong |
```

Documented step: ticket #88 `## Design`, "downloads the pinned release ... once, checks its sha256, and runs that"; `template/.github/shellcheck.sh:26`.
Result: the grounding replaced the cached file with a two-line script, and the gate ran it and exited 0. On a shared machine with a world-writable `/tmp`, the gate passes silently.

## Not asked for

3. **Doctor models-sheet line rewritten.** The `&& ||` becomes `if/else` with the same output, as a ShellCheck fix (SC2015). Required for the set to pass, so in scope.

```
pinned to an exact version ... and passes at the merge commit.
```

hard findings: 2
