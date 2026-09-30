## Walk

1. The Opening a PR playbook and `template/AGENTS.md` tell the writer to run `.github/shellcheck.sh` on each changed shell file before opening the PR; the script accepts paths as arguments.
2. Factory CI calls the root symlink with `factory918.sh`, the template gate, hooks, skill scripts, and tests; the local run checked 20 files and exited 0.
3. Project CI calls the copied gate with no arguments; it selects the project's hooks, skill scripts, and gate file.
4. The factory fixture calls that same no-argument form after `apply`, before the project's other gates.
5. The gate uses ShellCheck on PATH when it reports 0.11.0; otherwise it selects a pinned macOS arm64 or Linux x86_64 release and verifies the downloaded archive. A local download produced the checksum OK line and passed.
6. The gate expands each quoted glob and refuses a glob with no file before running ShellCheck; `tests/shellcheck/gate.sh` passed all 10 assertions.
7. The gate prints the file count, runs ShellCheck with `--external-sources` and default severity, and leaves the shell dialect to each shebang; the finding and POSIX test cases passed.
8. `factory918 doctor` prints a ShellCheck line: PASS for an installed executable or NOTE with installation commands when absent.
9. The factory and project coding standards require a reason on the same line as each ShellCheck disable directive; the edited directives carry reasons.
10. The factory's Verifying command and the dated findings entry record the invocation and 0.11.0 pin; P25 and its generated copy record the shared-gate choice.
11. Hook's own invocation: `delegation.sh` gains comments only; its test passed 55 assertions, so the cleared disposition holds.
12. Interactive session: the new `AGENTS.md` command matches factory CI and checked 20 files locally, so the cleared disposition holds.
13. Subagent: both spec-review test scripts gain `source-path=SCRIPTDIR` above their sourced layout file, supporting the per-file invocation described in the grounding; the cleared disposition holds.
14. `factory-start` day zero: the doctor line is above `slots filled` and returns PASS or NOTE, which the skill accepts; the cleared disposition holds.
15. Review in progress: the hook's review-state reads do not change, while the added hook comments make this a cross-cutting review; the cleared disposition holds.
16. poteto-mode: the playbook instruction is in both the working copy and its vendored patch; the cleared disposition holds.
17. spec-review scripts: the added SC2016 directives change lint interpretation, and the review-brief and review-comment tests passed 334 and 82 assertions; the cleared disposition holds.
18. show-me-your-work: the factory glob includes its two scripts without changing them; `sync` does not preserve local edits to those scripts, as the grounding says, so the cleared disposition holds for this diff.
19. Fixture step: the gate's no-argument globs include the gate itself and refuse a missing required glob; the cleared disposition holds.
20. `cmd_apply`: its `find` and `cp -p` copy the executable gate into a project, while the factory symlink stays outside `template/`; the cleared disposition holds.
21. Removed `bash -n`: the factory CI now runs ShellCheck over the prior shell set and additional shell files; the cleared disposition holds.
22. Checksums: both checksum branches refuse a mismatched archive, and the macOS download verified locally; the cleared disposition holds for the download path, subject to the cached-executable finding below.
23. Knowledge: P25 appears in the core decision and generated project copy, with the index count updated; the cleared disposition holds.
24. wizard: `template.sh` is outside the specified `scripts/*.sh` glob and is unchanged; the accepted scope in the grounding holds.

## Would break

## Fails open

1. **An unverified cached executable can pass the gate.** When ShellCheck is absent or off pin, `template/.github/shellcheck.sh:25-33` checks only whether the cache path is executable. A pre-existing executable there skips the download and checksum and is run as if it were ShellCheck 0.11.0. With ShellCheck hidden from PATH, I placed an executable that exits 0 at that path; the gate printed `ShellCheck 0.11.0, files checked: 1` and exited 0 without inspecting the file.

```text
Signature: `shellcheck.sh [glob...]`. Runs ShellCheck 0.11.0 with `--external-sources` at the default severity and no `--shell` over the files the globs match. Uses the `shellcheck` on PATH when its version is the pin; otherwise downloads the pinned release for Linux x86_64 or macOS arm64 into `${TMPDIR:-/tmp}/shellcheck-0.11.0` once, checks its sha256, and runs that. Writes nothing inside the repository.
```

Documented step: `ticket.md:46`: "Uses the `shellcheck` on PATH when its version is the pin; otherwise downloads the pinned release for Linux x86_64 or macOS arm64 into `${TMPDIR:-/tmp}/shellcheck-0.11.0` once, checks its sha256, and runs that."
Result: An executable already at the cache path bypasses both the version and checksum checks, and a no-op program can report a clean file set.
spec: design shellcheck.sh [glob...]

## Not asked for

hard findings: 1
