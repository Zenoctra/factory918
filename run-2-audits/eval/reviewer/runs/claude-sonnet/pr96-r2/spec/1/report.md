## Walk

1. Factory CI runs `bash .github/shellcheck.sh factory918.sh template/.github/shellcheck.sh 'template/.claude/hooks/*.sh' 'template/.agents/skills/*/scripts/*.sh' 'tests/*/*.sh'` (`.github/workflows/factory-ci.yml:19-20`), ShellCheck 0.11.0 with `--external-sources`, replacing `bash -n`.
2. Factory CI runs the gate's own test, `tests/shellcheck/gate.sh`, as a separate step (`factory-ci.yml:21-22`).
3. The fixture job re-runs the zero-argument form inside `/tmp/fx` right after `apply` (`factory-ci.yml:30-32`), the same invocation a project's CI makes.
4. A project's CI (`template/.github/workflows/ci.yml:17-18`) runs `bash .github/shellcheck.sh` with no arguments, which defaults to `.claude/hooks/*.sh`, `.agents/skills/*/scripts/*.sh` and the gate itself (`template/.github/shellcheck.sh:313`).
5. Both copies of the Opening a PR playbook (`patches/pstack/poteto-mode/playbooks/opening-a-pr.md.patch`, `template/.agents/skills/poteto-mode/playbooks/opening-a-pr.md`) tell the lane to run the gate on every changed shell file before the PR opens.
6. `factory918 doctor` prints `PASS shellcheck <version>` when a pinned `shellcheck` is on PATH, else a `NOTE` naming the platform install command (`factory918.sh:274-277`), never `FAIL`.
7. `CODING_STANDARDS.md`'s Bash section states a `# shellcheck disable=` directive is valid only with its reason as a second comment on the same line, modeled on `overlap.sh:207-208`.
8. `AGENTS.md` Verifying lists the gate and `tests/shellcheck/gate.sh`; `docs/M0-findings.md` records the 0.11.0 pin, both release checksums, and why the severity floor and `--external-sources` are set as they are.
9. `template/.github/shellcheck.sh` runs the PATH `shellcheck` when its `--version` matches the pin; otherwise it downloads the release for the running Linux x86_64 or macOS arm64 platform, checks its sha256, extracts it once into `${TMPDIR:-/tmp}/shellcheck-0.11.0`, then runs `--external-sources` over every file the caller's globs expand to, refusing (exit 1) any glob that matches nothing.

## Would break

None. Acceptance criteria 1, 2, 4, 5 and 6 are each met by the diff as walked above, and criterion 3's fixture flow (`factory-ci.yml:30-32`) runs the same zero-argument form the project's own CI runs.

## Fails open

1. **A tampered or replaced cache is trusted without a checksum.** Once `${TMPDIR:-/tmp}/shellcheck-$version/shellcheck-v$version/shellcheck` exists, the gate skips the download branch entirely and execs it with no re-check (`template/.github/shellcheck.sh:27,34-35` — the `[ ! -x "$bin" ]` guard at line 27 governs the whole download-and-verify block, and the only checksum check is inside it). `/tmp` is world-writable on a shared machine, so any other process able to write there can substitute a binary that always exits 0, and the gate would report success silently.

Documented step:
```
Local ShellCheck absent or off-pin, platform pinned | downloads once, then one of the rows above | as that row | nothing; the doctor's NOTE says how to install one
```
Result: after the first download, every later run trusts whatever is executable at that cached path with no integrity check, so a substituted binary is indistinguishable from a clean pass; the design documents the download-then-verify path but not what happens to a cache that already exists.

## Not asked for

None. The ShellCheck-driven touch-ups outside the gate itself — the `SC2088` directive and the `${skills:?}`/array-count rewrites in `factory918.sh`, the reason added to `overlap.sh`'s existing directive, the `source-path=SCRIPTDIR` pragmas and disable reasons in the spec-review scripts and tests, and the `delegation.sh` and `fake-gh.sh` comment/`if` rewrites — are exactly the "resolve every ShellCheck finding" and "name the shell gate" commits the ticket's own scope covers, and each is proven behavior-preserving in the blast-radius grounding.

hard findings: 1
