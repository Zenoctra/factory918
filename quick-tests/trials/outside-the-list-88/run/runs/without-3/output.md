## Final message

/private/tmp/wsbox/w-20261005-191428-a222/scratchpad/blast-radius.md

## File written: scratchpad/blast-radius.md

```
### What it does

Adds one shell gate, `template/.github/shellcheck.sh`, which runs ShellCheck 0.11.0 with `--external-sources` and fetches the pinned build when the machine lacks it (`template/.github/shellcheck.sh:18-33`). The factory reaches it through the new symlink `.github/shellcheck.sh`. Three CI steps call it (`.github/workflows/factory-ci.yml:19`, `:56`, `template/.github/workflows/ci.yml:18`); `tests/shellcheck/gate.sh` asserts its table. The 57 findings at `ab47eb9` are resolved with five code edits and directives elsewhere. `template/.claude/hooks/delegation.sh` gains four comment lines (`:21`, `:165`, `:186`, `:209`) and nothing else. The doctor gains a PASS or NOTE line for `shellcheck` (`factory918.sh:274-276`). The playbook, both `AGENTS.md`, both `CODING_STANDARDS.md`, M0, P25 and the ledger carry the prose.

Not spelled out by the diff: two vendored, unpatched scripts, `show-me-your-work/scripts/log.sh` and `poteto-mode/scripts/worktree-audit.sh`, are now linted on every CI run, and the gate's network path is reached only off the pin, so no run here exercised it.

### The one fact it's safe because of

Nothing that runs in a session, a lane or a hook behaves differently. The diff changes what gets linted and printed, not what executes. Rung 4, except the download, which is unproven here.

The hook. Comment lines stripped from both versions and diffed, then the test and live feeds:

```
$ diff <(git show ab47eb9:template/.claude/hooks/delegation.sh | grep -v '^[[:space:]]*#') <(grep -v '^[[:space:]]*#' template/.claude/hooks/delegation.sh); echo $?
0
$ bash tests/hooks/delegation.sh
ok 55 assertions
[gate, factory globs] hook exit: 0      [gate, zero-arg] hook exit: 0
[cat factory918.sh] hook exit: 2        (BLOCKED: factory918.sh is 428 lines ...)
[review: gate] hook exit: 0             [review: cat hook under review] hook exit: 2
```

The CLI's three edits. `sync` under `/bin/bash` 3.2.57, what `#!/usr/bin/env bash` resolves to here:

```
$ ./factory918.sh sync | tail -1; git status --porcelain | wc -l
vendored: 72 skills. Review with git status, bump VERSION, commit.
0
```

`${skills:?}` cannot fire. `skills="$TEMPLATE/.agents/skills"` (`factory918.sh:381`), `TEMPLATE="$F918_DIR/template"` (`:9`), and `sync` ran both `rm -rf` lines (`:388`, `:390`) without tripping. The doctor's two lines, old and new, run in isolation with a stub `note`:

```
old, sheet=no:  NOTE  models sheet / fix: factory918 install writes ~/.claude/pstack-models.md
new, sheet=no:  same two lines, then PASS  shellcheck 0.11.0
old, sheet=yes: PASS  models sheet          new, sheet=yes: PASS  models sheet / PASS  shellcheck 0.11.0
new, no shellcheck on PATH: NOTE  shellcheck / fix: brew install shellcheck (...)   exit 0
```

The gate from the factory root, with an empty `TMPDIR` to catch any download:

```
ShellCheck 0.11.0, files checked: 20   exit 0   entries under TMPDIR: 0
tests/shellcheck/gate.sh: ok 10   review-comment: ok 82   review-brief: ok 334   overlap: ok 56
python3 tools/build_knowledge.py: status clean   check_knowledge: knowledge ok: 118 files
```

### Risks

1. A lane without the pin on PATH and without network stops at the gate. `template/.github/shellcheck.sh:18` misses the pin, `:28` curls github.com. Reproduced with `PATH=/usr/bin:/bin` in this sandbox: `curl: (22) The requested URL returned error: 403`, nonzero exit. With `TMPDIR` unset and `/tmp` read-only it dies at `:27 mkdir`. Unlikely here (0.11.0 is in `/opt/homebrew/bin`), but a sandboxed writer lane whose PATH drops Homebrew cannot satisfy `opening-a-pr.md:9`. Loud, not silent. Check: `PATH=/usr/bin:/bin bash .github/shellcheck.sh factory918.sh`.
2. The download and checksum path is unproven at rung 4. `tests/shellcheck/gate.sh:8` defers it to the fixture; `factory-ci.yml:54-56` runs it on a runner whose ShellCheck is not 0.11.0, so the fetch happens there. Network is denied here; the first green fixture run is the proof.
3. The cross-cutting predicate at `review-brief.sh:189` names hooks, `settings.json` and the `factory918` skill, not `.github/shellcheck.sh` or `.github/workflows/`. A later edit to the gate, which every project's CI and lane runs, gets no blast-radius brief. A ticket, not this PR.
4. `log.sh` and `worktree-audit.sh` enter the gate with no patch (`patches/series`, 0 hits) and no `keep_files` entry (`factory918.sh:385`). Clean today; an upstream bump that brings a finding needs a new patch, or CI's `sync`-clean step fails. Low now.
5. `factory-ci.yml:53` pipes `apply` through `tail -30`; the doctor prints about 30 lines (`factory918.sh:246-291`), so the new line hides one more top line in the fixture log. Visibility only; `:168` runs it `|| true`.

### Cleared

- The new hook comments cite `set -f` at line 7; `delegation.sh:7` is `set -fuo pipefail`. No `delegation.sh:<n>` citation exists outside `research/`, so the shift breaks nothing.
- `factory-start/SKILL.md:14` requires PASS or NOTE above `slots filled`; the new line (`factory918.sh:274-276`) is above `:278` and prints only those two. `factory-doctor/SKILL.md:6` reprints the table.
- The per-file run from another directory is clean for both sourcing tests (`files checked: 2`); the `ab47eb9` copy of `tests/spec-review/review-brief.sh` without `source-path` gives SC1091 x2, SC2154 x4.
- A project layout built from the real template files, zero-argument form: `files checked: 11`, exit 0. The default globs (`:35`) skip the `.claude/skills` symlink.
- `wizard/template.sh` is outside `*/scripts/*.sh`; it carries two SC2034 (`:19` is one). Widening the glob would fail on a vendored file.
- `review-brief.sh:17` file-level and `review-comment.sh:40` site-level SC2016; both tests green. The file-level one hides a future genuine SC2016 there.
- P25 is at `docs/knowledge/core/DECISIONS.md:93` and `template/docs/factory918/DECISIONS.md:85`; the rebuild is clean.
- The root symlink is outside `template/`, so `apply` never copies it; CI names `template/.github/shellcheck.sh` explicitly.

### Before you merge

```
bash .github/shellcheck.sh factory918.sh template/.github/shellcheck.sh 'template/.claude/hooks/*.sh' 'template/.agents/skills/*/scripts/*.sh' 'tests/*/*.sh'
diff <(git show ab47eb9:template/.claude/hooks/delegation.sh | grep -v '^[[:space:]]*#') <(grep -v '^[[:space:]]*#' template/.claude/hooks/delegation.sh) && bash tests/hooks/delegation.sh
bash tests/shellcheck/gate.sh && ./factory918.sh sync | tail -1 && git status --porcelain
PATH=/usr/bin:/bin bash .github/shellcheck.sh factory918.sh   # the no-pin path; expect a loud curl failure offline
```

Then watch the fixture step `The shell gate a project runs`, where the download runs.
```

## Other files written (not shown)

scratchpad/tmp/bin/mktemp
scratchpad/tmp/doctor-lines.sh
scratchpad/tmp/home.T3iWad/.claude/pstack-models.md
scratchpad/tmp/old918.sh
scratchpad/tmp/proj.c0PNKR/.agents/skills/architect/SKILL.md
scratchpad/tmp/proj.c0PNKR/.agents/skills/architect/references/design-red-flags.md
scratchpad/tmp/proj.c0PNKR/.agents/skills/architect/references/rationale-template.md
scratchpad/tmp/proj.c0PNKR/.agents/skills/architect/references/runner-prompt.md
scratchpad/tmp/proj.c0PNKR/.agents/skills/arena/SKILL.md
scratchpad/tmp/proj.c0PNKR/.agents/skills/automate-me/SKILL.md
scratchpad/tmp/proj.c0PNKR/.agents/skills/babysit/SKILL.md
scratchpad/tmp/proj.c0PNKR/.agents/skills/blast-radius/SKILL.md
scratchpad/tmp/proj.c0PNKR/.agents/skills/bro/SKILL.md
scratchpad/tmp/proj.c0PNKR/.agents/skills/create-verification-skill/SKILL.md
scratchpad/tmp/proj.c0PNKR/.agents/skills/create-verification-skill/references/feature-map-example/README.md
scratchpad/tmp/proj.c0PNKR/.agents/skills/create-verification-skill/references/feature-map-example/create-note.md
scratchpad/tmp/proj.c0PNKR/.agents/skills/create-verification-skill/references/feature-map-example/search.md
scratchpad/tmp/proj.c0PNKR/.agents/skills/deslop/SKILL.md
scratchpad/tmp/proj.c0PNKR/.agents/skills/domain-modeling/ADR-FORMAT.md
scratchpad/tmp/proj.c0PNKR/.agents/skills/domain-modeling/CONTEXT-FORMAT.md
scratchpad/tmp/proj.c0PNKR/.agents/skills/domain-modeling/SKILL.md
scratchpad/tmp/proj.c0PNKR/.agents/skills/domain-modeling/agents/openai.yaml
scratchpad/tmp/proj.c0PNKR/.agents/skills/factory-doctor/SKILL.md
scratchpad/tmp/proj.c0PNKR/.agents/skills/factory-retro/SKILL.md
scratchpad/tmp/proj.c0PNKR/.agents/skills/factory-start/SKILL.md
scratchpad/tmp/proj.c0PNKR/.agents/skills/factory918/SKILL.md
scratchpad/tmp/proj.c0PNKR/.agents/skills/figure-it-out/SKILL.md
scratchpad/tmp/proj.c0PNKR/.agents/skills/fix-ci/SKILL.md
scratchpad/tmp/proj.c0PNKR/.agents/skills/fix-merge-conflicts/SKILL.md
scratchpad/tmp/proj.c0PNKR/.agents/skills/get-pr-comments/SKILL.md
scratchpad/tmp/proj.c0PNKR/.agents/skills/grill-me/SKILL.md
scratchpad/tmp/proj.c0PNKR/.agents/skills/grill-me/agents/openai.yaml
scratchpad/tmp/proj.c0PNKR/.agents/skills/grill-with-docs/SKILL.md
scratchpad/tmp/proj.c0PNKR/.agents/skills/grill-with-docs/agents/openai.yaml
scratchpad/tmp/proj.c0PNKR/.agents/skills/grilling/SKILL.md
scratchpad/tmp/proj.c0PNKR/.agents/skills/grilling/agents/openai.yaml
scratchpad/tmp/proj.c0PNKR/.agents/skills/how/SKILL.md
scratchpad/tmp/proj.c0PNKR/.agents/skills/how/references/critic-prompt.md
scratchpad/tmp/proj.c0PNKR/.agents/skills/how/references/critique-rubric.md
scratchpad/tmp/proj.c0PNKR/.agents/skills/how/references/explainer-prompt.md
scratchpad/tmp/proj.c0PNKR/.agents/skills/how/references/explorer-prompt.md
scratchpad/tmp/proj.c0PNKR/.agents/skills/interrogate/SKILL.md
scratchpad/tmp/proj.c0PNKR/.agents/skills/interrogate/references/code-quality-review.md
scratchpad/tmp/proj.c0PNKR/.agents/skills/interrogate/references/lead-judgment.md
scratchpad/tmp/proj.c0PNKR/.agents/skills/interrogate/references/reviewer-prompt.md
scratchpad/tmp/proj.c0PNKR/.agents/skills/interrogate/references/rubric.md
scratchpad/tmp/proj.c0PNKR/.agents/skills/knowledge/SKILL.md
scratchpad/tmp/proj.c0PNKR/.agents/skills/maintain-verification-skill/SKILL.md
scratchpad/tmp/proj.c0PNKR/.agents/skills/make-pr-easy-to-review/SKILL.md
scratchpad/tmp/proj.c0PNKR/.agents/skills/mode-build/SKILL.md
... and 157 more
