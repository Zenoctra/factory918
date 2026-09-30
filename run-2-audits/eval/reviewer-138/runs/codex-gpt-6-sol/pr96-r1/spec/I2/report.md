## Walk

1. Factory CI calls the root symlink with the explicit factory, hook, skill-script, and test globs; the gate reports 20 files and ShellCheck 0.11.0 passes on the reviewed tree.
2. `factory918 apply` copies the executable template gate into a project, and the project CI and fixture job call its zero-argument form after checkout.
3. The Opening a PR playbook patch tells the writer lane to run the gate on every changed shell file before opening the PR; the vendored playbook contains the same sentence.
4. `factory918 doctor` prints a ShellCheck PASS with the installed version, or a NOTE with installation commands when the command is absent.
5. The factory and project coding standards require a reason on the same line as a ShellCheck suppression; the changed suppressions carry reasons, and the gate uses ShellCheck's default severity.
6. Both AGENTS.md verifying sections name the gate, while `docs/M0-findings.md` records the dated version and the factory command records its 20-file count.
7. The gate accepts explicit glob arguments or defaults to project hooks, skill scripts, and itself. Its unquoted inner expansion splits a requested filename containing a space, so that documented per-file invocation misses the file.
8. The gate prints the file count before executing ShellCheck with `--external-sources`; a finding makes ShellCheck return nonzero, and a call with no matched files prints the stated refusal.
9. A call with one matching argument and one unmatched glob still runs on the match and exits successfully, despite the design row requiring refusal for a glob that matches no file.
10. When PATH lacks the pin, the gate selects a Linux x86_64 or macOS arm64 archive, verifies its checksum before extraction, and refuses an unpinned platform with the stated message.
11. The new test checks clean and faulty scripts, a wholly unmatched glob, the POSIX shebang, project defaults, an unsupported platform, and the gate's executable bit; it does not exercise mixed matching and unmatched arguments or filenames with spaces.
12. The P25 decision and `SOURCES.md` record the single template gate and its playbook patch; the generated decision copy contains P25 and `check_knowledge.py` passes.
13. Hook's own invocation: the delegation hook changes only in comments, and its Bash scanner does not inspect the gate command; the cleared disposition holds, with 55 hook assertions passing.
14. Interactive session: root AGENTS.md gives the exact factory CI command and it reports 20 clean files; the cleared disposition holds.
15. Subagent: both spec-review tests add `source-path=SCRIPTDIR` before sourcing the shared layout, which resolves their per-file ShellCheck run; the cleared disposition holds.
16. `factory-start` day zero: the doctor line precedes `slots filled` and uses PASS or NOTE, so the documented doctor output remains readable; the cleared disposition holds.
17. Review in progress: the review-brief cross-cutting path and delegation hook's review-state reads are unchanged; the cleared disposition holds.
18. poteto-mode: the ShellCheck instruction is in both the playbook patch and its vendored result; the cleared disposition holds for the reviewed files.
19. spec-review scripts: their SC2016 directives suppress literal Markdown and jq text, and both related test suites pass; the cleared disposition holds.
20. show-me-your-work: its shell scripts are included by the factory CI glob without changing `sync`'s keep list; the cleared disposition holds for this tree.
21. Fixture step: the zero-argument gate checks the current project's shell set, but its own file masks an absent hook glob; the clearance does not establish refusal for a missing component of that set.
22. `cmd_apply`: the template gate is executable and the factory's root symlink is separate from the copied template; the cleared disposition holds.
23. Removed `bash -n`: ShellCheck replaces the syntax command and parses every selected file before returning success; the cleared disposition holds for the selected set.
24. Checksums: the download path runs `sha256sum -c -` or `shasum -a 256 -c -` before extraction, and `set -e` stops a failed check; the cleared disposition holds in the code.
25. Knowledge: P25 appears in the generated decision copy and the knowledge check passes; the cleared disposition holds for consistency of the reviewed tree.
26. wizard: `template.sh` is outside the `scripts/*.sh` glob and unchanged; the accepted scope in the grounding holds.

## Would break

1. **A changed shell file with a space is skipped.** The documented quoted per-file call is split by `for f in $g` at `template/.github/shellcheck.sh:38`. A project can run the gate on a valid file plus `with space.sh`, receive exit 0 and `files checked: 1`, and open a PR without linting the changed file. I reproduced that result with two clean files in a temporary directory.

Documented step: ticket `## Design`, usage: `bash .github/shellcheck.sh '<glob>' ...           exactly these; quote a glob, the script expands it`.

Result: The quoted `with space.sh` argument is divided into `with` and `space.sh` and omitted; the gate succeeds if another argument matches.

spec: design shellcheck.sh [glob...]

```text
bash .github/shellcheck.sh '<glob>' ...           exactly these; quote a glob, the script expands it
```

## Fails open

2. **An unmatched glob is ignored when another argument matches.** The script checks only whether the combined `files` array is empty. `bash .github/shellcheck.sh template/.github/shellcheck.sh 'no-such/*.sh'` reported one checked file and exited 0, leaving the bad requested glob unreported.

Documented step: ticket `## Design`, situation `A glob matches no file`: `shellcheck.sh: no file matched <globs>; the gate checked nothing` on stderr, exit 1.

Result: The gate prints `ShellCheck 0.11.0, files checked: 1` and exits 0 without mentioning `no-such/*.sh`.

spec: design shellcheck.sh [glob...]

```text
| A glob matches no file | `shellcheck.sh: no file matched <globs>; the gate checked nothing` on stderr | 1 | fixes the glob; a gate that checked nothing is not a pass |
```

## Not asked for

hard findings: 2
