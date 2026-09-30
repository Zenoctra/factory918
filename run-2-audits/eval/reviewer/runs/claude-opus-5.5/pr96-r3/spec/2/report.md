## Walk

1. Factory CI: `factory-ci.yml:19` runs the gate through the root symlink over the ticket's four sets plus the gate and its test; it uses a local 0.11.0 or downloads the pinned tarball and checks its sha256. Satisfies criterion 1.
2. Template CI: `ci.yml` runs `bash .github/shellcheck.sh` first in `check`. The zero-argument globs are hooks, skill scripts and the gate. The fixture job runs the same line in `/tmp/fx`. Satisfies criterion 2.
3. Playbook: the patch and the vendored `opening-a-pr.md` both carry the sentence. Satisfies criterion 3.
4. Doctor: `PASS  shellcheck <v>` or a NOTE whose fix text starts `brew install shellcheck`. Satisfies criterion 4.
5. Directives: every `disable=` in the diff carries a same-line reason, `overlap.sh` included, and both CODING_STANDARDS files state the rule. Satisfies criterion 5.
6. `AGENTS.md` Verifying lists the command, and `M0-findings.md` has the dated ShellCheck section. Satisfies criterion 6.
7. Risk 1 (cached binary unchecked): resolved by a64c7e6. The tarball's sha is checked and the tarball re-extracted on every run, so a swapped binary is overwritten. A side effect: an interrupted `curl -o` leaves a partial tarball that is never downloaded again (test 9 asserts that). Every later run refuses it with `did NOT match` and no hint to delete `$dir`. The refusal is loud, and it is the design's "Checksum mismatch" row. The brief's cleared line "a half download ... the next run retries" is now stale.
8. Risk 2 (test 6 and a 0.11.0 in `/usr/bin`): unchanged. Test 9 uses the same `PATH=/usr/bin:/bin` assumption. Today the runner's ShellCheck is off-pin, so both tests pass.
9. Risk 3 (a silent unmatched glob): resolved by 01e5386. Test 3b covers it.
10. Risk 4 (offline or unpinned platform): loud, curl's message or the gate's platform refusal. This matches the design table.
11. Risk 5 (an `update` conflict in `ci.yml`): the step lands in `ci.yml.factory-merge`, which is `update`'s existing conflict path. `cmd_update` adds the new `.github/shellcheck.sh` as a new file (`factory918.sh:334-339`), so the step and its script do not come apart.

## Would break

## Fails open

## Not asked for

hard findings: 0
