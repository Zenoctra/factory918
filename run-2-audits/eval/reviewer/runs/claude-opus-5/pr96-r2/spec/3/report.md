## Walk

1. Factory CI replaces `bash -n` with `bash .github/shellcheck.sh` over the five globs the ticket names (`factory-ci.yml:19`); the symlink resolves to `template/.github/shellcheck.sh`, which pins 0.11.0, uses PATH's copy only when its version matches exactly, and otherwise downloads the pinned release for the two pinned platforms.
2. The gate passes at the merge commit: 20 files, resolved by five edits plus four directives in `delegation.sh`, two in the spec-review scripts, one in `factory918.sh` and one in `layout.sh`.
3. `tests/shellcheck/gate.sh` asserts the Design table's rows and is run as its own CI step (`:21`).
4. A project's `ci.yml` gets the gate first in `check` (`template/.github/workflows/ci.yml:17-18`); zero-argument, it checks `.claude/hooks/*.sh`, `.agents/skills/*/scripts/*.sh` and itself. The fixture job proves it inside `/tmp/fx` (`factory-ci.yml:54-56`).
5. The Opening a PR playbook names the gate in both the patch and the vendored copy; `sync` leaves the tree clean.
6. `cmd_doctor` prints `PASS shellcheck <version>` or a `NOTE` whose fix is `brew install shellcheck` and three platform equivalents, above `slots filled`.
7. The disable-with-reason rule lands in both `CODING_STANDARDS.md` files, `overlap.sh` carries the model directive, `AGENTS.md` Verifying lists the command, `docs/M0-findings.md` gains the dated ShellCheck section, and P25 records the decision.

## Would break

1. **The zero-argument form refuses inside the factory.** The factory root has `.claude/hooks` and `.claude/skills` (both symlinks) but no `.agents/`, so the default glob `.agents/skills/*/scripts/*.sh` matches nothing and the new refusal aborts on exit 1 before ShellCheck runs, in a healthy checkout. The message, `no file matched .agents/skills/*/scripts/*.sh; the gate checked nothing`, tells the lane to fix a glob it did not write; the real correction is to pass arguments. A lane taking the playbook's command literally reads a red gate on a clean tree.

Documented step:

```
**PRs.** ... Run `bash .github/shellcheck.sh` on every shell file the diff changes before the PR opens; it is the gate CI runs
```

and the script's own header, `template/.github/shellcheck.sh:5`: `bash .github/shellcheck.sh   this project's shell files`.

Result: exit 1 with a refusal naming a glob, in the one repository where the file is a symlink to the template. Either the factory needs the argument form spelled out where the playbook says it, or the default set has to be the one the repository it runs in actually has.

## Fails open

2. **A cached binary is run without its checksum.** After the first download, `[ ! -x "$bin" ]` (`template/.github/shellcheck.sh:26`) skips both the download and the `sha256sum -c`, so any executable at `${TMPDIR:-/tmp}/shellcheck-0.11.0/shellcheck-v0.11.0/shellcheck` is exec'd and its exit becomes the gate's. The author proved it: a two-line fake ran and the gate exited 0. On a shared box `/tmp` is world-writable; on a fresh runner it cannot happen.

Documented step:

```
Signature: `shellcheck.sh [glob...]`. ... downloads the pinned release for Linux x86_64 or macOS arm64 into `${TMPDIR:-/tmp}/shellcheck-0.11.0` once, checks its sha256, and runs that.
```

Result: on every run after the first, the binary the gate trusts is never checked and nothing says so; the gate passes silently. Checking the sha of the extracted binary, or of the tarball, on each run costs one line.

## Not asked for

hard findings: 2
