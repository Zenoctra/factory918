## Walk

1. AC1, factory CI: `factory-ci.yml:19` passes the five globs to the symlinked gate and `bash -n` goes; the pin is `version=0.11.0` plus two sha constants, and a PATH binary is used only when `--version` matches exactly (`shellcheck.sh:12-17`).
2. AC2, template CI: `ci.yml:17-18` runs the zero-argument form, whose default set is the project's hooks, skill scripts and the gate (`shellcheck.sh:34`); `cmd_apply` copies it with `cp -p`, and the fixture step runs it in `/tmp/fx`.
3. AC3, playbook: the `**PRs.**` paragraph gains the sentence in the patch and the vendored copy alike, and `SOURCES.md` item 3 records it.
4. AC4, doctor: `factory918.sh:274-276` reads `shellcheck --version`, prints PASS with it or `note` with brew, apt, dnf and winget; `note` only prints, so the doctor's exit is unchanged.
5. AC5, directives: both `CODING_STANDARDS.md` state the same-line reason rule, every new directive carries one, `overlap.sh`'s existing one gains one, and no CI check was added.
6. AC6, records: AGENTS.md Verifying names the command over 20 files; `M0-findings.md` gains a dated section with both checksums; DECISIONS gains P25 and the generated copies were rebuilt.
7. Risk 1, a cached binary reused with no checksum: nothing in the code addresses it; `[ ! -x "$bin" ]` (`shellcheck.sh:26`) is the only guard. Item 1.
8. Risk 2, `gate.sh:75` assuming no 0.11.0 in `/usr/bin`: unaddressed, but the failure is a red `FAIL 6` line, never a silent pass.
9. Risk 3, an unmatched glob dropped beside matched ones: closed by 01e5386; `shellcheck.sh:38-41` refuses, `gate.sh` asserts it as case 3b.
10. Risk 4, an offline or unpinned lane: refused at `:20-22` or by curl, with the install line; design row 5.
11. Risk 5, a project's edited `ci.yml`: `cmd_update` prints `conflicts ci.yml` and the hand-resolve count (`factory918.sh:362,369-371`), so it is loud.

## Would break

## Fails open

1. **A binary already at the cache path runs unchecked, and the gate reports the pin.** The PATH candidate is version-checked (`shellcheck.sh:17`); the cached one never is. `[ ! -x "$bin" ]` skips the download, the sha and any `--version`, so whatever sits at `${TMPDIR:-/tmp}/shellcheck-0.11.0/shellcheck-v0.11.0/shellcheck` runs, prints `ShellCheck 0.11.0, files checked: N` and exits 0. The author proved it with a two-line fake. Moving the existing version test onto `$bin` after the cache hit refuses it loudly for one line.

```
otherwise downloads the pinned release for Linux x86_64 or macOS arm64 into `${TMPDIR:-/tmp}/shellcheck-0.11.0` once, checks its sha256, and runs that
```

Documented step: ticket #88, `## Design`, the Signature paragraph.
Result: the sha is checked only on the run that downloads; every later run trusts the path, so a foreign or off-pin binary passes the gate silently under the pin's own name.

## Not asked for

hard findings: 1
