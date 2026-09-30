## Walk

1. Factory CI drops `bash -n` for `bash .github/shellcheck.sh factory918.sh template/.github/shellcheck.sh 'template/.claude/hooks/*.sh' 'template/.agents/skills/*/scripts/*.sh' 'tests/*/*.sh'` (`factory-ci.yml:19`), the exact set criterion 1 names, through a root symlink to the template's copy; the version is a literal in the script, not the runner's.
2. Criterion 2: `template/.github/workflows/ci.yml:17-18` adds `bash .github/shellcheck.sh` first in `check`; the zero-argument globs are `.claude/hooks/*.sh`, `.agents/skills/*/scripts/*.sh`, `.github/shellcheck.sh` (`shellcheck.sh:35`), and the fixture job runs that form inside `/tmp/fx`.
3. Criterion 3: the `**PRs.**` paragraph of `opening-a-pr.md` gains the sentence, and `patches/pstack/.../opening-a-pr.md.patch:8` carries it, so `sync` keeps it.
4. Criterion 4: `factory918.sh:274-276` prints `PASS shellcheck <v>` or `note` with `brew install shellcheck` and the three other package managers; never `FAIL`.
5. Criterion 5: `CODING_STANDARDS.md:15` (Bash section) states the same-line reason rule with `overlap.sh` as the model; `template/CODING_STANDARDS.md:37` says it for projects; every directive added in this diff carries a reason.
6. Criterion 6: `AGENTS.md:38-39` lists the command and the gate's test; `docs/M0-findings.md:170-172` is the dated line with both checksums, the severity reasoning and the `-x` reasoning.
7. Risk 1 (cached binary, no checksum): real, and the item below.
8. Risk 2 (`gate.sh:75` assumes no on-pin ShellCheck in `/usr/bin`): a test that goes red on an image bump, no path a user follows.
9. Risk 3 (an unmatched glob dropped beside matched ones): the grounding is stale; `shellcheck.sh:38-41` refuses per glob and `gate.sh:62-63` asserts it.
10. Risk 4 (no network, no pin, off-platform): refused with the tool's own message at `:28` or the script's at `:22`.
11. Risk 5 (`ci.yml` conflict on `update`): lands in `ci.yml.factory-merge`, which `merge-file` says loudly.

## Would break

## Fails open

1. **A cached binary is run as the pin without its checksum.** `shellcheck.sh:26` skips the download, and so the sha, whenever `${TMPDIR:-/tmp}/shellcheck-0.11.0/shellcheck-v0.11.0/shellcheck` is executable. On a shared box `/tmp` is world-writable, so any binary at that path runs while the gate prints `ShellCheck 0.11.0` and exits 0; the author reproduced it. Checking the version of `$bin` after extraction, as line 21 already does for PATH, closes it.

```
pinned to an exact version (a release download or a pinned action, not whatever the runner image carries), and passes at the merge commit
```

Documented step: ticket #88 acceptance criterion 1; `## Design` row "Checksum mismatch | refused with `sha256sum`'s own message".
Result: an unverified binary at the cache path is trusted, and the gate reports the pin.

## Not asked for

hard findings: 1
