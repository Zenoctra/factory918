# Spec report

## Walk

1. Factory CI's "ShellCheck" step runs `bash .github/shellcheck.sh factory918.sh template/.github/shellcheck.sh 'template/.claude/hooks/*.sh' 'template/.agents/skills/*/scripts/*.sh' 'tests/*/*.sh'`, 20 files, ShellCheck 0.11.0, exit 0 at the merge commit.
2. The template's `ci.yml` adds a "ShellCheck" step running `bash .github/shellcheck.sh` with no arguments, which defaults to `.claude/hooks/*.sh`, `.agents/skills/*/scripts/*.sh` and `.github/shellcheck.sh`; the fixture job runs this inside `/tmp/fx` after `apply`.
3. The Opening a PR playbook, through its patch, tells the lane to run `bash .github/shellcheck.sh` on every changed shell file before the PR opens.
4. `factory918 doctor` prints `PASS  shellcheck <version>` or a `NOTE` naming `brew install shellcheck` (and the apt/dnf/winget equivalents), never `FAIL`.
5. A `# shellcheck disable=` directive must carry its reason as a second comment on the same line, modeled on `overlap.sh`; `CODING_STANDARDS.md`'s Bash section states the rule for the Standards axis to enforce.
6. `AGENTS.md`'s Verifying section lists the exact CI command, and `docs/M0-findings.md` records the pin, both checksums and the finding count at `ab47eb9`.
7. When no local `shellcheck` matches the pin, the script downloads the release for the detected platform, verifies its sha256, extracts it under `${TMPDIR:-/tmp}/shellcheck-<version>`, and runs that binary.
8. A glob that matches no file is refused on stderr with exit 1, even when it stands beside a glob that does match.

## Would break

## Fails open

1. **A cached ShellCheck binary is reused with no verification.** The download branch's own guard, `[ ! -x "$bin" ]`, only downloads and checksums when the cached path is missing or non-executable; once `${TMPDIR:-/tmp}/shellcheck-0.11.0/shellcheck-v0.11.0/shellcheck` exists, the gate executes it directly on every later run, on that machine, with no further check that it is the pinned build.
   ```
   Signature: ... otherwise downloads the pinned release for Linux x86_64 or macOS arm64 into `${TMPDIR:-/tmp}/shellcheck-0.11.0` once, checks its sha256, and runs that.
   ```
   Documented step: `template/.github/shellcheck.sh:24-31` (the design's Signature paragraph, quoted above).
   Result: a file placed or substituted at that cache path — by a prior partial run, a shared world-writable `/tmp` on a multi-tenant box, or anything else that writes there first — is executed as if it were the verified 0.11.0 build; the gate reports its normal `ShellCheck 0.11.0, files checked: N` line and exit 0 with no indication the binary was never checked this run.

## Not asked for

hard findings: 1
