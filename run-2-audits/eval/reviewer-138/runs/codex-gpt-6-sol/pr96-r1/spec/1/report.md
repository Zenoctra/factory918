## Walk

1. Factory CI invokes the root symlink with explicit globs for `factory918.sh`, the gate, hooks, skill scripts, and tests; the checked set has 20 files and passes locally.
2. Project CI invokes the copied gate without arguments, which selects project hooks, skill scripts, and the gate; the fixture workflow invokes the same command after `apply`.
3. The Opening a PR playbook and its source patch tell a lane to run the gate on every changed shell file before opening the PR.
4. `factory918 doctor` prints a ShellCheck PASS when a version is installed and a NOTE with install commands when it is absent.
5. The changed `disable=` directives carry same-line reasons, and both factory and project coding standards state the rule for review.
6. Both AGENTS.md files name the verification command, and `docs/M0-findings.md` records the 0.11.0 pin with a date.
7. The gate chooses a ShellCheck 0.11.0 binary from PATH or downloads a platform build into temporary storage, checking the archive checksum before extraction.
8. The gate expands the supplied globs or its default set, prints the file count, and invokes ShellCheck with `--external-sources`, default severity, and each file's own shell dialect.
9. A finding produces ShellCheck's report and exit 1; a sole unmatched glob produces the documented refusal; an unsupported platform without the pin produces an install message.
10. Hook's own invocation: the hook changes only in comments, and its Bash scanner passes the gate call. This honors the cleared disposition.
11. Interactive session: the factory AGENTS.md command matches the CI command and passes over 20 files. This honors the cleared disposition.
12. Subagent: the spec-review tests add `source-path=SCRIPTDIR`, so a per-file run can resolve `layout.sh` from another directory. This honors the cleared disposition.
13. `factory-start` day zero: the doctor line appears before `slots filled`, with PASS or NOTE output that the existing flow can display. This honors the cleared disposition.
14. Review in progress: the changed hook lines are comments, while review-brief still identifies this hook as cross-cutting and receives its grounding. This honors the cleared disposition.
15. poteto-mode: the pre-PR instruction is in the patch and the vendored playbook, so sync retains it. This honors the cleared disposition.
16. spec-review scripts: the file-level SC2016 directives only affect linting; the review-brief and review-comment tests pass. This honors the cleared disposition.
17. show-me-your-work scripts: the factory glob lints their current copies, while sync still restores them from upstream unless patched. The stated cleared disposition holds for this diff.
18. Fixture step: the zero-argument gate selects the files present in the applied project and refuses an invocation from a directory with no selected files. This honors the cleared disposition.
19. `cmd_apply`: the copied gate keeps its executable mode; the factory-only symlink stays outside the template. This honors the cleared disposition.
20. Removed `bash -n`: ShellCheck checks the previous syntax set and the new script test exercises clean, finding, and refusal results. This honors the cleared disposition.
21. Checksum and extraction: the download checks its archive with `sha256sum` or `shasum`, then extracts with `tar -xJf`; a failed download or checksum stops the gate. This honors the cleared disposition.
22. Knowledge: the new P25 decision is reflected in the generated template decision file. This honors the cleared disposition.
23. wizard: its `template.sh` is outside the named `scripts/*.sh` glob, and this change does not alter that skill. This honors the cleared disposition.

## Would break

1. **A quoted file path containing a space is rejected.** The documented explicit-argument form promises to check the files named by the caller. The gate splits each argument at spaces in `for f in $g`, even when the caller quoted it. Running it on a clean file named `a b.sh` printed `no file matched .../a b.sh; the gate checked nothing` and exited 1. The path can arise in a project where paths contain spaces.

   ```text
   bash .github/shellcheck.sh '<glob>' ...           exactly these; quote a glob, the script expands it
   ```

   Documented step: `.scratch/review/ab47eb9/ticket.md:40`, the quoted explicit-glob usage.
   Result: The named clean file is skipped and the command refuses it instead of checking it.
   spec: design shellcheck.sh [glob...]

## Fails open

2. **One unmatched argument is silently dropped when another matches.** The gate checks whether the combined `files` array is empty, so it never reports which supplied glob failed to match. `bash .github/shellcheck.sh template/.github/shellcheck.sh 'missing/*.sh'` printed `files checked: 1` and exited 0. A typo in one of CI's explicit globs can therefore leave that class of files unchecked while the gate passes.

   ```text
   | A glob matches no file | `shellcheck.sh: no file matched <globs>; the gate checked nothing` on stderr | 1 | fixes the glob; a gate that checked nothing is not a pass |
   ```

   Documented step: `.scratch/review/ab47eb9/ticket.md:40,52`, the multi-glob usage and unmatched-glob refusal.
   Result: The gate reports success and gives no correction for the unmatched argument.
   spec: design shellcheck.sh [glob...]

## Not asked for

hard findings: 2
