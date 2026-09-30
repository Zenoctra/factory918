## Walk

1. `.github/workflows/factory-ci.yml:19` runs `bash .github/shellcheck.sh` over the factory's 20 named files in place of `bash -n`, and `:21` runs `tests/shellcheck/gate.sh`.
2. `template/.github/workflows/ci.yml:17-18` runs the zero-argument form first in `check`, over `.claude/hooks/*.sh` and `.agents/skills/*/scripts/*.sh`; the fixture job proves it passes on `ubuntu-latest`.
3. `template/.agents/skills/poteto-mode/playbooks/opening-a-pr.md:9` (through its patch) tells a lane to run `bash .github/shellcheck.sh` on every changed shell file before the PR opens.
4. `factory918.sh:274-276` prints `PASS shellcheck <version>` when a local binary exists and matches the pin, else `NOTE shellcheck` naming the install command; never `FAIL`.
5. `template/.agents/skills/poteto-mode/scripts/overlap.sh:49` carries `# shellcheck disable=SC2016 # <reason>` on one line, the model the standard cites; `CODING_STANDARDS.md:15` states the same-line-reason rule; CI does not enforce it.
6. `AGENTS.md:38-39` lists the two commands; `docs/M0-findings.md:172` records ShellCheck 0.11.0 verified 2026-09-21 with the two release shas and the findings-fixed count.
7. `template/.github/shellcheck.sh:18-33` uses `shellcheck` on PATH when its version matches the pin; otherwise it downloads the pinned release once per `${TMPDIR:-/tmp}/shellcheck-<version>` directory, checks its sha256, and runs it.
8. `template/.github/shellcheck.sh:36-44` expands each glob argument in turn and exits 1 with a stderr message naming the first glob that matched nothing, before running ShellCheck; run against `'template/.claude/hooks/*.sh' 'nope/*.sh'` at this commit, it refuses on `nope/*.sh` and never reports a partial count.

## Would break

## Fails open

1. **Cached binary reused with no re-verification.** Once `${TMPDIR:-/tmp}/shellcheck-0.11.0/shellcheck-v0.11.0/shellcheck` exists, `[ ! -x "$bin" ]` at `template/.github/shellcheck.sh:26` is false and the script skips both the download and the sha256 check on every later run, executing whatever is at that path.
```
Uses the shellcheck on PATH when its version is the pin; otherwise downloads the pinned release ... into `${TMPDIR:-/tmp}/shellcheck-$version` once, checks its sha256, and runs that.
```
Documented step: `## Design`, Signature paragraph, and the table's "Local ShellCheck absent or off-pin, platform pinned" row (checksum verified as part of the documented path).
Result: I replaced the cached file at that exact path with a two-line script; the gate printed `ShellCheck 0.11.0, files checked: 1` and ran `FAKE BINARY RAN --external-sources tests/shellcheck/gate.sh`, exit 0. Nothing in the documented path re-checks the binary's identity after the first download, so a corrupted or substituted cache is trusted silently.

2. **Doctor does not see a project ci.yml that lost the gate.** `cmd_update`'s three-way merge (`factory918.sh:357-361`) can conflict on `template/.github/workflows/ci.yml`; the project's `ci.yml` then keeps its old content (no ShellCheck step) while the merged text lands only in `ci.yml.factory-merge`. `factory918 doctor`'s only CI check, `chk "ci workflow present" "[ -f .github/workflows/ci.yml ]"` (`factory918.sh:265`), and its shellcheck line (`:274-276`), which checks only whether a local binary exists, both still print PASS.
```
The template's CI runs `shellcheck` over a project's `.claude/hooks/*.sh` and `.agents/skills/*/scripts/*.sh`, pinned the same way, and the fixture flow passes it.
```
Documented step: Acceptance criteria, bullet 2.
Result: a project whose `ci.yml` was edited near the checkout step before an update loses the gate on that branch of `cmd_update`, and every doctor check the ticket added or relies on for this feature still reads PASS, so the missing gate has no check that surfaces it after the initial merge message scrolls by.

## Not asked for

hard findings: 2
