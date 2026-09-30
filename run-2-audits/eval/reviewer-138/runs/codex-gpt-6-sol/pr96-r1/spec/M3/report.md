## Walk

1. `factory918 apply` copies the executable gate from `template/.github/shellcheck.sh` into a project; the factory calls that same file through `.github/shellcheck.sh`.
2. Factory CI passes the five explicit file patterns to the gate, covering `factory918.sh`, the template gate, hooks, skill scripts, and tests. The run checks 20 files at ShellCheck 0.11.0 and exits 0.
3. Project CI calls the gate with no arguments. The default patterns cover project hooks, skill scripts, and the gate itself; the factory fixture runs this same command after `apply`.
4. The Opening a PR playbook directs a lane to run the gate on each changed shell file before opening the PR. Its patch and `SOURCES.md` carry the instruction; the factory's `AGENTS.md` gives its explicit patterns.
5. `factory918 doctor` prints `PASS  shellcheck <version>` when ShellCheck is on PATH, or a `NOTE` with platform install commands when it is absent. Neither outcome makes ShellCheck a doctor failure.
6. The factory and project standards require a reason in a second comment on the same line as each `# shellcheck disable=` directive. The edited directives use that form.
7. Both `AGENTS.md` files name the gate under Verifying. The dated `docs/M0-findings.md` entry records the pin and observed findings, while P25 records the gate choice in the source decision and generated project copy.
8. For a clean explicit file, the gate prints `ShellCheck 0.11.0, files checked: 1`; ShellCheck exits 0.
9. For a ShellCheck finding, the gate prints its file count and ShellCheck reports the finding with a failing exit. The planted SC2086 test exercises this path.
10. For an unmatched glob, the gate writes the stated refusal to stderr and exits 1 before invoking ShellCheck.
11. With no matching local version on a pinned platform, the gate downloads the release into the temporary directory, checks its SHA-256, extracts it, and runs it. A fresh macOS download printed the checksum `OK` line and checked one file.
12. With no matching local version on an unpinned platform, the gate prints the platform pair and install instruction on stderr and exits 1.
13. A cached archive with the wrong checksum is refused by `sha256sum` or `shasum` before extraction; it cannot reach the lint call.
14. Hook's own invocation: the hook diff adds comments only, and its command scanner does not intercept the gate's `bash` call. The cleared disposition holds.
15. Interactive session: the factory's `AGENTS.md` gives the explicit five-pattern command, which checks 20 files successfully. The cleared disposition holds; the zero-argument form is for an applied project.
16. Subagent: both spec-review tests identify their sourced layout file with `source-path=SCRIPTDIR`, so a single-file gate call can resolve it from another directory. The cleared disposition holds.
17. `factory-start` day zero: the doctor prints the optional ShellCheck line before `slots filled`; `apply` and `update` still print the doctor report. The cleared disposition holds.
18. Review in progress: the comment-only hook edit leaves its review-state reads intact, and `review-brief.sh` still treats that hook as cross-cutting. The cleared disposition holds.
19. poteto-mode: the Opening a PR wording is present in the patch that `sync` applies to the vendored playbook. The cleared disposition holds.
20. spec-review scripts: the two file-level SC2016 directives cover literal template text; their focused tests pass. The cleared disposition holds.
21. show-me-your-work: its scripts are included by the skill-script glob and pass, although `sync` does not preserve local edits to them. The cleared disposition holds for this diff.
22. Fixture step: the zero-argument command checks the installed project's files, including the gate; the gate refuses a missing required pattern. The cleared disposition holds.
23. `cmd_apply`: `cp -p` retains the gate's executable bit in a project, and the factory-only symlink is not copied. The cleared disposition holds.
24. Removed `bash -n`: ShellCheck rejects unparseable shell files while checking a broader set. The cleared disposition holds.
25. Checksum and extraction: both supported checksum commands refuse a mismatch, and the macOS archive extracts through `tar -xJf`; a fresh download succeeded. The cleared disposition holds.
26. Knowledge: the source P25 decision is reflected in the generated project decision, and the knowledge checks pass. The cleared disposition holds.
27. wizard: `template.sh` lies outside the specified `scripts/*.sh` patterns, so the gate does not change the wizard's documented path. The cleared disposition holds.

## Would break

## Fails open

## Not asked for

hard findings: 0
