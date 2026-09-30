## Walk

1. Criterion 1: `factory-ci.yml:19` replaces `bash -n` with the gate over the four sets the ticket names; the count line reports 20 files, and `tests/shellcheck/gate.sh` runs as its own step.
2. Signature: the gate uses the PATH `shellcheck` only when `--version` is `version: 0.11.0`, else maps `uname -s.-m` to a pinned tarball, verifies its sha256, extracts and `exec`s it.
3. Criterion 2: `template/.github/workflows/ci.yml:17` runs the zero-argument form, whose default globs are the project's hooks, its skill scripts and the gate itself; the fixture job runs the same line in `/tmp/fx`.
4. Criterion 3: the `**PRs.**` sentence is added in `opening-a-pr.md.patch` and its vendored copy, with the SOURCES.md entry updated.
5. Criterion 4: `cmd_doctor` prints `PASS  shellcheck <v>` or a `note` whose fix names brew, apt, dnf and winget; never `FAIL`.
6. Criterion 5: the reason-on-the-same-line rule is in the factory's Bash section and the template's Suppressions section, with `overlap.sh` rewritten as the model.
7. Criterion 6: `AGENTS.md` Verifying carries the command verbatim, and `docs/M0-findings.md` gains a dated ShellCheck section with both checksums.
8. Risk 1 (cached binary reused unverified) is closed: `a64c7e6` moved the sha and the extract above the `[ -f "$tarball" ]` guard, so both run every time.
9. Risk 2 (test 6 assumes no on-pin ShellCheck in `/usr/bin`) stands; it fails the test, not the gate.
10. Risk 3 (an unmatched glob dropped beside matched ones) is closed by `01e5386` and asserted by test 3b.
11. Risk 4 (an offline lane) is a loud refusal by the design's platform and download rows.
12. Risk 5 (a project's `ci.yml` conflicting on update) is reported: `cmd_update` writes `.factory-merge` and prints `conflicts <rel>`; `.github/shellcheck.sh` itself lands through the new-in-the-template branch.

## Would break

1. **The checksum refusal hides the file it refuses, and keeps it.** `>/dev/null` on both `sha256sum -c -` and `shasum -a 256 -c -` (`template/.github/shellcheck.sh:29-30`) discards the `<path>: FAILED` line, which is the half of the message that names the tarball; only `WARNING: 1 computed checksum did NOT match` reaches stderr. Because `[ -f "$tarball" ]` skips the download, an interrupted download wedges that machine's gate on every later run with no path to delete. The grounding's own clearance says otherwise.

```
| Checksum mismatch | refused with `sha256sum`'s own message | 1 | reports it; the pin or the download is wrong |
```

Documented step: the `## Design` table row above, and `A half download leaves no binary, so the next run retries` in the blast-radius Cleared list.
Result: the caller sees a count with no filename, and the half download leaves a tarball that fails its sha on every run until someone finds and deletes it by hand. Test 9 pins this by asserting nothing on stdout and that the tarball is not fetched again.

## Fails open

## Not asked for

hard findings: 1
