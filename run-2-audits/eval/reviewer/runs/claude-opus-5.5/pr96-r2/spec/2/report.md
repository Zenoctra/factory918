## Walk

1. Factory CI: `factory-ci.yml` replaces `bash -n` with `bash .github/shellcheck.sh` over `factory918.sh`, the gate, hooks, every `template/.agents/skills/*/scripts/*.sh` and `tests/*/*.sh`. The version and both sha256 values live in the gate, so the tool is a pinned release download, not the runner's copy.
2. Template CI: `ci.yml` runs the zero-argument form, which covers `.claude/hooks/*.sh`, `.agents/skills/*/scripts/*.sh` and the gate itself. The fixture job runs the same step inside `/tmp/fx`.
3. Playbook: the patch and the vendored `opening-a-pr.md:9` both carry the sentence, and `SOURCES.md` item 3 describes it.
4. Doctor: `scv` prints PASS with the version, or a NOTE whose fix names `brew install shellcheck` and the equivalents on other platforms.
5. Directives: every `disable=` in the set now carries a same-line reason, including the one in `overlap.sh` that the criterion names as the model. The Bash section of the root `CODING_STANDARDS.md`, which the Standards axis reads, states the rule, and the template's Suppressions section repeats it.
6. `AGENTS.md` Verifying lists the command and `gate.sh`. `M0-findings.md` has a section dated 2026-09-22 that records 0.11.0.
7. Risk 1 (cached binary, no checksum): true, and the cause is outside the documented path (someone tampering with the cache). No user input reaches it.
8. Risk 2 (`gate.sh` test 6 on a future image with 0.11.0 in `/usr/bin`): a possible future red CI. Today the image's copy is off-pin, so the test reaches the `uname` branch.
9. Risk 3 (a glob that matches nothing is dropped): fixed by 01e5386. `:38-42` refuses it even when other globs match, and test 3b asserts that.
10. Risk 4 (offline, or a platform with no pin): refused loudly by curl or by the gate's own message. This is the design row.
11. Risk 5 (`update` conflict on `ci.yml`): `cmd_update` prints a `conflicts` line and writes `.factory-merge` (`factory918.sh:362-368`). The failure is loud.

## Would break

## Fails open

## Not asked for

hard findings: 0
