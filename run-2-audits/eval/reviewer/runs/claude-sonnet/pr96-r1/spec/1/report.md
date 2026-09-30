## Walk

1. Factory CI runs `bash .github/shellcheck.sh factory918.sh template/.github/shellcheck.sh 'template/.claude/hooks/*.sh' 'template/.agents/skills/*/scripts/*.sh' 'tests/*/*.sh'` (`.github/workflows/factory-ci.yml:19-20`) in place of `bash -n`, pinned to ShellCheck 0.11.0 (`template/.github/shellcheck.sh:8`), and `tests/shellcheck/gate.sh` runs alongside it (`:21-22`).
2. `template/.github/workflows/ci.yml:17-18` adds `bash .github/shellcheck.sh` with no arguments; the zero-argument default (`template/.github/shellcheck.sh:35`) is `.claude/hooks/*.sh`, `.agents/skills/*/scripts/*.sh`, `.github/shellcheck.sh`, and the fixture job runs the same step inside `/tmp/fx` (`factory-ci.yml:30-32`).
3. `patches/pstack/poteto-mode/playbooks/opening-a-pr.md.patch:8` and `template/.agents/skills/poteto-mode/playbooks/opening-a-pr.md:9` add the sentence naming `bash .github/shellcheck.sh` on every changed shell file before the PR opens.
4. `factory918.sh:274-276` adds a `shellcheck --version` check printing `PASS shellcheck <ver>` when found, else `note "shellcheck" "brew install shellcheck (...)"`, a NOTE rather than a FAIL.
5. `CODING_STANDARDS.md:16` (the `## Bash` section) states the same-line reason rule, modeled on `template/.agents/skills/poteto-mode/scripts/overlap.sh:49`.
6. `AGENTS.md:38` lists the ShellCheck command; `docs/M0-findings.md:170` records the dated, versioned finding.

## Would break

## Fails open

1. **A silently unmatched glob among matched ones.** The gate only refuses when the combined file count across every glob is zero (`template/.github/shellcheck.sh:40-43`); it never checks that each glob it was given matched at least one file. The factory CI step names four globs (`factory918.sh`, `template/.github/shellcheck.sh`, `'template/.claude/hooks/*.sh'`, `'template/.agents/skills/*/scripts/*.sh'`, `'tests/*/*.sh'`); if a future rename empties one of them, the run still prints `ShellCheck 0.11.0, files checked: N` at a smaller N and exits 0, so CI stays green while one of the four named sets goes unchecked.
   Documented step: `.github/workflows/factory-ci.yml:19-20` and criterion 1, "`shellcheck` runs in the factory's CI over `factory918.sh`, `template/.claude/hooks/*.sh`, every `scripts/*.sh` under `template/.agents/skills/`, and `tests/*/*.sh` ... and passes at the merge commit."
   Result: the run reports a smaller `files checked: N` and exits 0 instead of refusing; nothing distinguishes this from a legitimately smaller file set. Reproduced in the blast-radius grounding: `bash .github/shellcheck.sh 'template/.claude/hooks/*.sh' 'nope/*.sh'` prints `files checked: 5`, exit 0.

## Not asked for

hard findings: 1
