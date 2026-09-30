## Walk

1. Factory CI runs the gate over the four sets the ticket names (`factory-ci.yml:19`); the globs `template/.claude/hooks/*.sh` (5), `template/.agents/skills/*/scripts/*.sh` (5), `tests/*/*.sh` (8), plus `factory918.sh` and the gate itself give 20. The one `.sh` under `skills/` outside the set is `wizard/assets/template.sh`, which is not `scripts/*.sh`, so the criterion's wording covers it.
2. The version is pinned in one place (`shellcheck.sh:15`), used on PATH only when `--version` matches exactly (`:20`), else downloaded from the release URL with a per-platform sha256 (`:30-32`). `bash -n` is gone from CI and from `AGENTS.md`.
3. The template's `ci.yml` runs the zero-argument form after checkout (`ci.yml:17-18`); its defaults are `.claude/hooks/*.sh`, `.agents/skills/*/scripts/*.sh` and the gate (`shellcheck.sh:37`). `cmd_apply` copies both files with `cp -p`, so a project never hits the empty-glob refusal: the template ships 5 hooks and 5 skill scripts. The fixture job runs the same line inside `/tmp/fx`.
4. The playbook sentence is in the patch and in the vendored copy, and `SOURCES.md:15` records it, so `sync` keeps it.
5. The doctor prints `PASS shellcheck <v>` or a `NOTE` whose fix is `brew install shellcheck` with three other platforms' commands (`factory918.sh:274-276`); `shellcheck` absent leaves `scv` empty through `|| true` rather than aborting.
6. The disable rule is in the factory's Bash section (`CODING_STANDARDS.md:15`), in the template's Suppressions, and in P25; every directive the diff adds or edits carries its reason on the same line, `overlap.sh:49` included.
7. `AGENTS.md:38` is the CI line verbatim, and `docs/M0-findings.md:170` dates the version, both checksums, the 57-to-0 count and why the severity is the default.
8. Risk 1, an unverified cached binary: outside the documented path, and the cache is the gate's own.
9. Risk 2, a future `ubuntu-latest` carrying 0.11.0: a test fixture's assumption, loud when it breaks.
10. Risk 3, an unmatched glob: commit 01e5386 refuses it, so this is now the count line only when a glob is dropped from the caller.
11. Risk 4, an offline lane: refused with curl's own message.
12. Risk 5, a conflicting `ci.yml`: reported as a conflict and a `.factory-merge` file, not silent.

## Would break

## Fails open

## Not asked for

hard findings: 0
