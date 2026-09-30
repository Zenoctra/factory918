## Walk

1. Factory CI calls the root symlink with `factory918.sh`, the template gate, hooks, skill scripts and tests; the gate uses ShellCheck 0.11.0 at default severity with `--external-sources` and checks 20 files. The command passed locally.
2. `factory918 apply` copies the executable gate into a project, whose `check` job calls its zero-argument form before the other checks. The fixture workflow calls that same form from `/tmp/fx`.
3. The Opening a PR patch and its vendored playbook tell a lane to run the gate on every changed shell file before opening the PR; the gate accepts explicit file or glob arguments.
4. `factory918 doctor` reports a ShellCheck version as PASS when installed and a NOTE with platform installation commands when absent; the gate can fetch the pin independently.
5. The factory and project coding standards require a reason on the same line as a ShellCheck suppression. The changed directives supply reasons; CI leaves that judgment to Standards review.
6. Both `AGENTS.md` files name the shell command in Verifying, and `docs/M0-findings.md` records the dated 0.11.0 pin, flags and checksums.
7. For a clean matched file the gate prints its count and exits 0; for a finding it prints the count and ShellCheck's report and exits 1; with no matched file it prints its refusal on stderr and exits 1. The gate test passed all 10 assertions.
8. When PATH lacks the pin on a supported platform, the gate downloads and verifies its archive before running it; the macOS download printed a checksum OK line and checked one file. An unsupported platform receives the specified refusal.
9. Hook's own invocation: the diff adds only suppression comments to `delegation.sh`, and its `Bash` scan does not classify the gate command as a guarded read or write. This honors the cleared claim; its 55 assertions pass.
10. Interactive session: the factory `AGENTS.md` command matches the CI command and checked 20 files locally. This honors the cleared claim.
11. Subagent: the two spec-review tests mark their sourced `layout.sh` with `source-path=SCRIPTDIR`, so a per-file ShellCheck call can resolve it from another directory. This honors the cleared claim.
12. `factory-start` day zero: the new doctor line appears before `slots filled`, uses PASS or NOTE, and leaves the later checks in place. This honors the cleared claim.
13. Review in progress: only comments change in the delegation hook, and the review brief still treats a hooks diff as cross-cutting. This honors the cleared claim.
14. poteto-mode: the new pre-PR instruction is in both the source patch and vendored playbook; the patch remains listed in `series`. This honors the cleared claim.
15. spec-review scripts: their new SC2016 directives change no executable statements; the review-brief and review-comment tests passed 334 and 82 assertions. This honors the cleared claim.
16. show-me-your-work scripts: the factory glob includes their `scripts/*.sh` files, while `cmd_sync` keeps only the four named local files. The stated patch requirement for any future vendored edit follows from that code, so the cleared claim holds.
17. Fixture step: the zero-argument form names project hooks, skill scripts and the gate itself, and the fixture job calls it from the project root. The gate test's project fixture counted four files; this honors the cleared claim about the intended fixture path.
18. `cmd_apply`: its `find` and `cp -p` copy the executable template gate into a project, while the factory symlink remains outside `template/`. This honors the cleared claim.
19. Removed `bash -n`: factory CI replaces its syntax check with ShellCheck over a broader named set, and ShellCheck reports syntax errors as findings. This honors the cleared claim.
20. Checksums and extraction: the script checks the release archive before extraction, uses `tar -xJf`, and retries when no executable was extracted. The pinned macOS download succeeded, supporting the cleared claim.
21. Knowledge: the new P25 source decision is reflected in its generated template copy and index; `check_knowledge.py` passed for 118 files. This honors the cleared claim.
22. wizard: the configured skill glob covers `scripts/*.sh`, leaving the vendored wizard `template.sh` outside this ticket's named set; no wizard file changed. This honors the cleared claim.

## Would break

## Fails open

## Not asked for

hard findings: 0
