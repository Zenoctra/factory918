## Walk

1. **Factory CI.** `.github/shellcheck.sh` links to the template gate. The factory job runs it over `factory918.sh`, the template gate, hooks, skill scripts, and tests, then runs `tests/shellcheck/gate.sh`. The local command reports 20 files and exits 0.
2. **Project CI.** `apply` copies the executable gate into a project. The template `check` job and the factory fixture both run its zero-argument form from the project root.
3. **Before a PR.** The patched Opening a PR playbook tells a lane to run the gate on every changed shell file before opening the PR. `SOURCES.md` records the patch.
4. **Doctor.** `factory918 doctor` prints `PASS  shellcheck <version>` when ShellCheck is on PATH and a `NOTE` with install commands when it is absent. The line precedes `slots filled`.
5. **Directive reasons.** `CODING_STANDARDS.md` and the template Standards file require a reason in a second comment on the directive's line. The changed directives carry reasons; the factory Standards rule also limits their scope.
6. **Verification record.** Root `AGENTS.md` lists the full factory gate command and its test. Template `AGENTS.md` names the project command. `docs/M0-findings.md` records the pin and checks dated 2026-09-22.
7. **Gate inputs.** With no arguments, the gate selects project hooks, skill scripts, and itself. With arguments, it loops over the supplied globs and passes collected files to ShellCheck. Paths containing spaces and partially unmatched argument lists expose P1 and P2.
8. **Clean and finding results.** The gate prints a file count before running ShellCheck 0.11.0 with `--external-sources`, the default severity, and each file's own shell dialect. The gate test observes exit 0 for a clean file and exit 1 for SC2086 and a POSIX shell error.
9. **No-match result.** When the entire collected file list is empty, the gate prints the documented refusal on stderr and exits 1. A missing glob alongside a matching one passes, as P2 shows.
10. **Pinned local or downloaded tool.** The gate checks the PATH binary's version, selects a pinned release for Linux x86_64 or macOS arm64, and verifies a fresh archive before extraction. An executable already in its cache bypasses both checks, as P3 shows.
11. **Unsupported platform.** With no pinned PATH binary and an unsupported OS or architecture, the gate prints the platform and tells the caller to install ShellCheck by hand. The gate test exercises this refusal.
12. **Checksum failure.** A fresh archive goes through `sha256sum -c -` or `shasum -a 256 -c -`; a failed check stops the script. The cache path skips the archive check, as P3 shows.
13. **Hook's own invocation risk.** The diff adds comments only to `delegation.sh`; its Bash scanner still lets this gate command through. The cleared disposition holds for the hook's current behavior.
14. **Interactive session risk.** Root `AGENTS.md` gives the factory CI command, and that command checks 20 current files. The cleared disposition holds for this command.
15. **Subagent risk.** Both spec-review tests gain `source-path=SCRIPTDIR`, so their sourced `layout.sh` resolves in a per-file ShellCheck run from another directory. The cleared disposition holds.
16. **`factory-start` day-zero risk.** The new doctor line is above `slots filled` and reports PASS or NOTE; `apply` and `update` still print the doctor report. The cleared disposition holds.
17. **Review-in-progress risk.** The hook's review-state reads are unchanged, and the changed hook still triggers blast-radius grounding in `review-brief.sh`. The cleared disposition holds.
18. **poteto-mode risk.** The playbook edit is also present in its vendored patch and `SOURCES.md`. The cleared disposition holds for the reviewed files.
19. **spec-review scripts risk.** The diff adds SC2016 comments to `review-brief.sh` and `review-comment.sh` without changing their commands. The cleared disposition holds.
20. **show-me-your-work risk.** The factory glob includes `log.sh` and `worktree-audit.sh`; neither changes, and `sync`'s keep list does not include them. The cleared disposition holds for this diff.
21. **Fixture-step risk.** The zero-argument gate includes its own file, so the fixture has a nonempty set. A subdirectory call with no matching relative paths refuses. The cleared disposition holds for that documented fixture call.
22. **`cmd_apply` and symlink risk.** `cp -p` retains the gate's executable bit in a project; the root symlink remains outside `template/`. The cleared disposition holds.
23. **Removed `bash -n` risk.** Factory CI replaces the syntax-only command with ShellCheck, which rejects the cited unparseable probes and checks a wider file set. The cleared disposition holds.
24. **Download and checksum risk.** The checksum commands reject a bad fresh archive and extraction uses `tar -xJf`. An already executable cache entry is trusted without verification, so the cleared disposition does not cover P3.
25. **Knowledge risk.** P25 is in the core decisions and its generated template copy, and the index count changed with it. The cleared disposition holds for the reviewed content.
26. **Wizard risk.** The factory glob names `scripts/*.sh`; `wizard/template.sh` lies outside it and is unchanged. The stated exclusion holds.

## Would break

1. **A quoted path with spaces is not checked.** `template/.github/shellcheck.sh:38` splits `$g` into words before expanding it. In a temporary directory, `good.sh` plus `with space/bad.sh` printed `files checked: 1` and exited 0; the bad file contains SC2086. With the spaced path alone, the gate wrongly says no file matched. This breaks the documented per-file command for a changed shell file whose path contains spaces.

Documented step: Ticket `## Design`: "bash .github/shellcheck.sh '<glob>' ... exactly these; quote a glob, the script expands it".

Result: The requested file is omitted, and a mixed request reports success without checking it.

spec: design `shellcheck.sh [glob...]`

```
bash .github/shellcheck.sh '<glob>' ...           exactly these; quote a glob, the script expands it
```

## Fails open

2. **One missing glob passes when another matches.** The gate tests only whether the combined `files` array is empty. In a temporary directory, `bash shellcheck.sh good.sh 'missing/*.sh'` printed `files checked: 1` and exited 0 with no refusal for the unmatched glob.

Documented step: Ticket `## Design`, row "A glob matches no file": "`shellcheck.sh: no file matched <globs>; the gate checked nothing` on stderr", exit 1.

Result: The requested missing glob is silently dropped, so the caller cannot tell that the gate checked less than requested.

spec: design `shellcheck.sh [glob...]`

```
| A glob matches no file | `shellcheck.sh: no file matched <globs>; the gate checked nothing` on stderr | 1 | fixes the glob; a gate that checked nothing is not a pass |
```

3. **An unpinned cached binary passes as ShellCheck 0.11.0.** The gate validates a PATH binary and a fresh archive, but `template/.github/shellcheck.sh:26` accepts any executable at `${TMPDIR:-/tmp}/shellcheck-0.11.0/shellcheck-v0.11.0/shellcheck`. I placed a fake executable there, hid ShellCheck from PATH, and ran the gate on an SC2086 file. It printed `ShellCheck 0.11.0, files checked: 1`, ran the fake program, and exited 0.

Documented step: Ticket criterion 1: "pinned to an exact version (a release download or a pinned action, not whatever the runner image carries)".

Result: A preexisting off-pin executable skips the download and checksum and can make CI report success on a file ShellCheck would reject.

spec: criterion 1

```
- [ ] `shellcheck` runs in the factory's CI over `factory918.sh`, `template/.claude/hooks/*.sh`, every `scripts/*.sh` under `template/.agents/skills/` and `tests/*/*.sh`, pinned to an exact version (a release download or a pinned action, not whatever the runner image carries), and passes at the merge commit.
```

## Not asked for

hard findings: 3
