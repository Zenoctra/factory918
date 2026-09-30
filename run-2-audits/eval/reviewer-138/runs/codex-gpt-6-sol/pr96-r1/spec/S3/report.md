## Walk

1. Factory CI calls the template gate through `.github/shellcheck.sh` with `factory918.sh`, the gate, the hook and skill script globs, and the test glob; ShellCheck 0.11.0 checks 20 files and passes.
2. Project CI calls the same copied gate with no arguments after checkout, and the factory fixture calls that form in `/tmp/fx`; it checks the project's hooks, skill scripts, and gate.
3. The Opening a PR patch and its vendored playbook tell the writer to run the gate on every changed shell file before opening the PR; the explicit-argument form accepts file paths and globs.
4. `factory918 doctor` prints `PASS  shellcheck <version>` when it finds a local binary, or a `NOTE` with platform installation commands when it does not; `apply` and `update` retain the doctor call.
5. The factory and project coding standards require reasons on the same line as ShellCheck suppressions; the changed directives carry reasons, and CI leaves that prose rule to the Standards review.
6. Both AGENTS.md verification sections name the gate, and the dated M0 finding records the 0.11.0 pin and observed lint results.
7. The gate uses the local binary only when its reported version is 0.11.0; otherwise it selects the pinned Linux x86_64 or macOS arm64 release, verifies the archive checksum, and runs the extracted binary.
8. The gate runs `--external-sources` at default severity without forcing a shell dialect; a clean file passes, and a finding prints the count followed by ShellCheck's report and exits nonzero.
9. A wholly unmatched file argument exits with the gate's correction message; an unpinned platform without a matching local binary exits with the platform message.
10. The gate test checks clean, finding, unmatched, POSIX dialect, no-argument project, unsupported-platform, and executable-mode cases; the focused test passes 10 assertions.
11. Hook's own invocation: the hook diff adds only comments and its `Bash` scanner does not intercept the gate; the hook test passes, honoring the cleared disposition.
12. Interactive session: the root AGENTS.md command is the factory CI command and checks 20 files, honoring the cleared disposition.
13. Subagent: the two spec-review tests identify `layout.sh` by `SCRIPTDIR`, so per-file lint resolves their source from another directory, honoring the cleared disposition.
14. `factory-start` day zero: the doctor line appears before `slots filled`, reports PASS or NOTE, and the apply and update doctor calls remain, honoring the cleared disposition.
15. Review in progress: the hook's review-state reads do not change, and the spec-review test suite passes, honoring the cleared disposition.
16. poteto-mode: the playbook wording is also in its source patch, so sync can regenerate the vendored copy, honoring the cleared disposition.
17. spec-review scripts: their added SC2016 directives change lint treatment only; the review-brief and review-comment suites pass, honoring the cleared disposition.
18. show-me-your-work scripts: the factory glob lints their `scripts/*.sh` files; sync's `keep_files` does not include them and this diff does not edit them, honoring the cleared disposition.
19. Fixture step: its zero-argument invocation checks the copied project files and the gate itself; the gate test exercises the same file selection, honoring the cleared disposition.
20. `cmd_apply`: `find` includes the template gate as a regular file and `cp -p` preserves its executable bit; the factory symlink stays outside the template, honoring the cleared disposition.
21. Removed `bash -n`: ShellCheck now checks syntax as part of the factory gate, and the listed malformed probes are refused, honoring the cleared disposition.
22. Checksum and extraction: the restricted-PATH macOS run downloaded the archive, printed the checksum `OK`, and checked one file; the script retries when no executable was extracted, honoring the cleared disposition.
23. Knowledge: the source decision adds P25 and the generated template decision and index carry it, honoring the cleared disposition.
24. wizard: `template.sh` is outside the `scripts/*.sh` globs and is unchanged, honoring the cleared disposition.

## Would break

## Fails open

## Not asked for

hard findings: 0
