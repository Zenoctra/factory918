# Spec review report

## Walk

1. AC1: `.github/workflows/factory-ci.yml:18-19` replaces `bash -n` with the gate over the four sets plus the gate itself; the pin is `version=0.11.0` (`template/.github/shellcheck.sh:13`), and a PATH binary is used only when `--version` matches it exactly (`:18`), else the release is downloaded.
2. AC2: `template/.github/workflows/ci.yml:17-18` runs the zero-argument form first in `check`; the fixture job runs that same line inside `/tmp/fx` (`factory-ci.yml:54-56`). One script, one pin.
3. AC3: the `**PRs.**` sentence lands in the patch (`opening-a-pr.md.patch:8`) and in the vendored copy, so `sync` keeps it.
4. AC4: `factory918.sh:274-276` prints `PASS  shellcheck <v>` or `note`, never `chk`, so a bare machine gets NOTE; the fix names brew, apt, dnf and winget.
5. AC5: the rule is stated in `CODING_STANDARDS.md:15` and `template/CODING_STANDARDS.md:37`; every directive the diff adds carries its reason on the same line, and `overlap.sh:49` gains the one it lacked. No CI check, as asked.
6. AC6: `AGENTS.md:38-39` lists both commands; `docs/M0-findings.md:170-172` is the dated line with the version, both shas and why the severity stays default.
7. Other prose: P25 in `DECISIONS.md` with the INDEX count and the regenerated template copy, `SOURCES.md` item 3, the ledger line.
8. Risk 1 (cached binary, no sha): nothing; `:26` skips the download and the checksum whenever that path is executable.
9. Risk 2 (`gate.sh:75` assumes no on-pin `/usr/bin` ShellCheck): nothing in the code; the failure is a red CI, loud.
10. Risk 3 (a dropped glob): nothing; item 1 below.
11. Risk 4 (no network, no ShellCheck, or an unpinned platform): refused at `:22` or by curl at `:28`, exit nonzero with a message.
12. Risk 5 (`cmd_update` conflict leaves a project's `ci.yml` without the step): nothing; the doctor gains no check for the step.

## Would break

## Fails open

1. **One glob of several matching nothing passes the gate.** `template/.github/shellcheck.sh:37-39` keeps only paths that exist, and `:40` refuses only when the whole set is empty, so a renamed or mistyped path among good ones is dropped silently.

```
| A glob matches no file | `shellcheck.sh: no file matched <globs>; the gate checked nothing` on stderr | 1 | fixes the glob; a gate that checked nothing is not a pass |
```

Documented step: `template/.agents/skills/poteto-mode/playbooks/opening-a-pr.md:9`, "Run `bash .github/shellcheck.sh` on every shell file the diff changes before the PR opens", and the CI line's five globs.
Result: exit 0 with the count quietly one lower; the lane and CI both report a pass over files nobody checked.

## Not asked for

hard findings: 1
