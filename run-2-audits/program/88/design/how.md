# Shell-quality gates, end to end

## Overview

There is no ShellCheck anywhere in this repository today. The only shell gate is a `bash -n` syntax pass in the factory's own CI (`.github/workflows/factory-ci.yml:18-19`); the two `# shellcheck disable=SC2016` directives that exist (`template/.agents/skills/poteto-mode/scripts/overlap.sh:49`, `tests/poteto-mode/overlap.sh:17`) were written for a linter nobody runs. Ticket #88 adds the linter in five places at once, and each place has a different delivery path: the factory's CI is edited directly, the template's CI travels through `apply`/`update`, the playbook sentence must go through a patch or `sync` reverts it, the doctor line is a function in `factory918.sh`, and the standards rule is prose read only at review time.

## Key concepts

- **`template/` is the product.** `factory918 apply` copies it file by file into a project (`factory918.sh:131-141`).
- **The nesting trick.** At the factory root, `.claude/hooks -> ../template/.claude/hooks` and `.claude/skills -> ../template/.agents/skills` are symlinks (P7, `docs/knowledge/core/DECISIONS.md:74`). The factory runs on the template's hooks and skills.
- **A manifest** (`<project>/.factory918/manifest.json`) records the template SHA of every managed path; it is what `update` merges against (`factory918.sh:118-119,139-140`).
- **`keep_files`** is `sync`'s list of files that live under a vendored skill's directory but are ours (`factory918.sh:381`).

## How it works

### (a) The factory's own CI

Two jobs, both in `.github/workflows/factory-ci.yml`. `factory` (line 12) runs the repo's checks; `fixture` (line 34) does day 0 on a fresh monorepo.

The **Shell syntax** step (lines 18-19) is one line: `bash -n factory918.sh`, then a `for` loop over four globs — `template/.claude/hooks/*.sh`, `template/.agents/skills/spec-review/scripts/*.sh`, `template/.agents/skills/poteto-mode/scripts/*.sh`, `tests/*/*.sh`. Note it names two skills explicitly, where ticket #88 asks for "every `scripts/*.sh` under `template/.agents/skills/`". A third skill has scripts today: `template/.agents/skills/show-me-your-work/scripts/log.sh`. It is not syntax-checked now and would be newly covered.

The rest of job 1 runs the four behavioural tests (lines 20-27), a wording check (line 29), the knowledge rebuild-and-diff (line 31), and the vendoring identity check (line 33): `./factory918.sh sync` must leave `git diff --exit-code` clean and `git status --porcelain template` empty.

Job 2 (`fixture`) installs `vp` pinned to 0.3.1 (line 42) and `uv`, creates `/tmp/fx` with `vp create` from `/tmp` (line 49 — `vp create` refuses an absolute `--directory`, `docs/M0-findings.md` "Merge mechanics"), commits, then runs `./factory918.sh apply /tmp/fx --scaffold --profile python --name demo` (line 51). After that it exercises the applied project: `review-brief.sh` run from inside `/tmp/fx` with a fake `gh` on PATH (lines 52-68), `vp check && vp test run && pnpm sg:test && pnpm sg` (line 71), the Python profile's gates (line 74), and two negative probes that the lint rules fire (lines 75-82). Inside `/tmp/fx`, `.claude/hooks/*.sh` and `.agents/skills/*/scripts/*.sh` are **real files** copied by `apply`, not symlinks — so this job is where a template-CI shellcheck step would be proven against a real project's file layout.

### (b) How a template change reaches a project

`template/.github/workflows/ci.yml` is an ordinary file under `template/`, so it rides the same generic copy loop as everything else.

`cmd_apply` (`factory918.sh:107-169`): ensures `.factory918/manifest.json` (118-119), applies a profile if asked (122-129), then walks every file under `template/` (`find . -type f ! -name '.gitkeep'`, line 131), skipping only `package.scripts.json` and `.gitignore.factory` (133). **It copies a file only when the project does not have it** (136) — except for the four `FACTORY_OWNED` paths (`factory918.sh:35`: `AGENTS.md CLAUDE.md vite.config.ts .vite-hooks/pre-commit`) under `--scaffold` (135). Either way it records the template's SHA in the manifest (139-140). Then: `.claude/skills` symlink to `../.agents/skills` if absent (143), gitignore append (145), a `jq` merge of `scripts`/`engines`/`devDependencies` where the project's values win (147-154), `chmod +x` on `.claude/hooks/*.sh` (155), ast-grep approval, `vp install --no-frozen-lockfile`, `vp fmt`, and finally `cmd_doctor "$dir" || true` (168).

`cmd_update` (`factory918.sh:301-370`) is a Python three-way merge. Per managed path: new in the template → written, or dropped beside as `.factory-merge` on conflict (330-336); locally deleted → never re-added (339-340); template unchanged since the recorded SHA → untouched (344-345); **locally untouched → overwritten with the new template** (346-347); both changed → `git merge-file` on the old template at tag `v<recorded version>` (348-359), conflicts landing in `<file>.factory-merge` with the project's file left alone. `cmd_update` also ends with `cmd_doctor "$dir" || true` (369).

So a new step added to `template/.github/workflows/ci.yml` reaches an existing project only through `update`, and only cleanly if that project never edited its `ci.yml`.

### (c) `cmd_doctor`

`cmd_doctor` (`factory918.sh:236-289`) defines two local helpers at 238-239:

- `chk "<label>" "<command>" "<fix>"` — `eval`s the command with output discarded; prints `PASS  <label>`, or `FAIL  <label>` plus an indented `      fix: <fix>` line and sets `fail=1`.
- `note "<label>" "<fix>"` — prints `NOTE  <label>` and the same `      fix:` line, and **never** touches `fail`.

It starts with `doctor_branch` (246, defined 195-230), then ~25 `chk` lines, and ends with `all clear` or `start with the first FAIL` and `return $fail` (287-288). Two existing checks are deliberately NOTE-not-FAIL: the **models sheet** (272, a bare `[ -f "$HOME/.claude/pstack-models.md" ] && echo PASS || note ...`) and **delete-branch-on-merge** (260-262, which reads `gh repo view --json deleteBranchOnMerge` with its failure tolerated inside the substitution, PASSes on `true`, NOTEs on `false`, and prints nothing when gh cannot answer). A missing-tool `shellcheck` line follows the models-sheet shape exactly: a `[ ... ] && echo "PASS  ..." || note "shellcheck" "brew install shellcheck"`, outside `chk` because `chk` cannot produce a NOTE.

Because `apply` and `update` both end in `cmd_doctor ... || true`, a new NOTE line shows up at the end of every day-0 run and every update, including the fixture job's `apply` output (`.github/workflows/factory-ci.yml:51`, piped to `tail -30`).

### (d) The vendored-skill patch mechanism

`cmd_sync` (`factory918.sh:375-400`) rebuilds `template/.agents/skills` from the pinned copies under `research/` — never the network (372-374). In order: stash `keep_files` into a temp dir (383); `rm -rf` and re-copy every pstack skill except `no-comments` (384); re-copy the named Pocock skills (385-386); copy `code-review` → `spec-review` (387); restore `keep_files` (388); refresh `.claude/agents` (389); then apply `patches/series` line by line with `git -C "$skills" apply` (391-395), printing `FAILED   <patch>` and returning nonzero if a patch no longer applies.

`keep_files` (`factory918.sh:381`) is exactly four paths: `poteto-mode/playbooks/ticket.md`, `poteto-mode/scripts/overlap.sh`, `spec-review/scripts/review-brief.sh`, `spec-review/scripts/review-comment.sh`. Everything else inside a vendored skill directory is wiped and re-copied — including `poteto-mode/scripts/worktree-audit.sh` and `show-me-your-work/scripts/log.sh`, which are upstream files (no patch names them; `patches/series`).

`template/.agents/skills/poteto-mode/playbooks/opening-a-pr.md` is edited only through `patches/pstack/poteto-mode/playbooks/opening-a-pr.md.patch` (listed in `patches/series:7`). The patch is a unified diff with paths relative to `.agents/skills` (`patches/README.md:3`) and today carries three hunks (the `**PRs.**` paragraph, the `## Blast Radius` bullet, the closing subagent sentence). Workflow: edit the template file, then regenerate with the command in `patches/README.md:9`:

    diff -u --label a/<path> --label b/<path> research/<upstream>/<path> template/.agents/skills/<path> > patches/<source>/<path>.patch

The upstream copy is `research/3-pstack/open-pstack-claude-code-port/plugins/pstack/skills/poteto-mode/playbooks/opening-a-pr.md` (path only; derived from `factory918.sh:378` plus `patches/README.md:9`). After regenerating, `./factory918.sh sync` must leave `git diff --exit-code` clean and `git status --porcelain template` empty (`.github/workflows/factory-ci.yml:33`). Each patch also has a numbered prose entry in `SOURCES.md` under "## Patches" (line 11); entry 3 (`SOURCES.md:15`) is this playbook's, and a new sentence in it belongs there.

### (e) The shell files #88 names

| File | Shebang | Mode | Notes |
|---|---|---|---|
| `factory918.sh` | `#!/usr/bin/env bash` | exec | `set -euo pipefail` (line 4) |
| `template/.claude/hooks/block-dangerous-git.sh`, `delegation.sh`, `format-on-write.sh`, `mode.sh`, `session-start.sh` | `#!/usr/bin/env bash` | exec | `delegation.sh` and `format-on-write.sh` run **without `-e`** by design (`CODING_STANDARDS.md:14`) |
| `template/.agents/skills/poteto-mode/scripts/overlap.sh`, `worktree-audit.sh` | `#!/usr/bin/env bash` | exec | only `overlap.sh` is in `keep_files` |
| `template/.agents/skills/show-me-your-work/scripts/log.sh` | `#!/usr/bin/env bash` | exec | vendored, not in the current CI glob |
| `template/.agents/skills/spec-review/scripts/review-brief.sh`, `review-comment.sh` | `#!/usr/bin/env bash` | exec | both in `keep_files` |
| `tests/hooks/delegation.sh`, `tests/spec-review/no-stale-wording.sh`, `review-brief.sh`, `review-comment.sh` | `#!/usr/bin/env bash` | exec | |
| `tests/poteto-mode/overlap.sh` | `#!/usr/bin/env bash` | **not executable** | run as `bash tests/...` |
| `tests/spec-review/fake-gh.sh` | `#!/bin/sh` | exec | **POSIX sh**, copied onto PATH as `gh` (`.github/workflows/factory-ci.yml:56`; `tests/spec-review/fake-gh.sh:2`) |
| `tests/spec-review/layout.sh` | **no shebang** | not executable | sourced by both spec-review tests (`tests/spec-review/review-brief.sh:20`, `review-comment.sh:11`) |

Both existing directives are a bare line above the statement, with the reason in a nearby comment rather than on the same line:

- `template/.agents/skills/poteto-mode/scripts/overlap.sh:49` — `  # shellcheck disable=SC2016` above a `grep -oE '\`[^\`[:space:]]+\`'` pipeline.
- `tests/poteto-mode/overlap.sh:17` — file-level `# shellcheck disable=SC2016`, with the reason in the header comment two lines earlier (15-16: "The backticks in the bodies below are the ticket's token delimiters, not command substitutions").

Ticket #88 calls `overlap.sh`'s "the model" and asks for the reason on the same line, so both of these will need rewriting to match whatever form the design settles on.

### (f) The prose surfaces

- Root `AGENTS.md:36-46` "Verifying": a flat bullet list of commands, one per line, ending with the fixture flow (45) and "Anything verified against a tool version gets a dated line in `docs/M0-findings.md`" (46).
- Root `CODING_STANDARDS.md:5-14` "## Bash (`factory918.sh`, the hooks)": nine bullets; line 3 says to "Skip anything the CI gate (`.github/workflows/factory-ci.yml`) already enforces", which is the tension a suppression-reason rule has to be written around (CI runs the linter, the Standards axis judges the reason).
- Template `CODING_STANDARDS.md:35-37` "## Suppressions": three sentences covering `oxlint-disable`, `@ts-ignore`, `@ts-expect-error` — "Every new or broadened ... needs an adjacent comment explaining why. The directive itself is not an explanation. A stale directive fails lint." This is the sentence pattern a `shellcheck disable` rule extends.
- Template `AGENTS.md:60-68` "## Verifying": prose bullets organised by surface (TypeScript, Python, tests, evidence), not a command list.

### (g) The record files

- `docs/M0-findings.md`: `## <Topic> (YYYY-MM-DD)` sections of dense prose, each fact stating the tool version it was checked against (e.g. `docs/M0-findings.md:5`, and the sections at 112, 120, 132, 138). #88's criterion is a dated line recording the verified `shellcheck` version (0.11.0 Homebrew, per the ticket).
- `docs/agents/ledger.md:3` states the shape: `YYYY-MM-DD | model | what it did | what you wanted`, append only. Rows run from line 5 to 23.
- `docs/knowledge/core/DECISIONS.md:66-68` "## Provisional (added by agents; Manuel promotes or overrules)" is a four-column table `| # | Decision | Choice | Reason |`. Numbering is `P<n>`, **not in order** in the file (the tail runs P20, P21, P23, P22, P2, P24 at lines 87-92); the next free number is **P25**.
- `python3 tools/build_knowledge.py` with only `DECISIONS.md` changed touches three things: it rewrites `docs/knowledge/core/DECISIONS.md` in place with a regenerated `<!-- lines: N ... -->` header and mini-TOC (`tools/build_knowledge.py:104-119,133`), writes the header-stripped body to `template/docs/factory918/DECISIONS.md` (135-137), and rewrites `docs/knowledge/INDEX.md` with the new line count (175; the row is `docs/knowledge/INDEX.md:10`). `check_knowledge.py` then asserts the INDEX count, the 240-line cap and every TOC line number (`tools/check_knowledge.py:2,13-21`). The generated `spec/`, `pages/` and `notes/` trees are rebuilt from scratch every run (`tools/build_knowledge.py:141-142`) but produce no diff unless their sources changed.

## Where things live

```
.github/workflows/factory-ci.yml            the factory's two jobs; "Shell syntax" at :18
template/.github/workflows/ci.yml           the project CI, 2 jobs (check, test); no shell step
factory918.sh                               :35 FACTORY_OWNED · :107 apply · :236 doctor (chk/note :238)
                                            :301 update · :375 sync (keep_files :381)
template/.claude/hooks/*.sh                 5 hooks, copied as real files into a project
template/.agents/skills/*/scripts/*.sh      5 scripts across poteto-mode, show-me-your-work, spec-review
tests/*/*.sh                                9 files; layout.sh sourced, fake-gh.sh is /bin/sh
patches/series, patches/README.md           patch order; regeneration command at README:9
patches/pstack/poteto-mode/playbooks/opening-a-pr.md.patch
SOURCES.md:11+                              numbered prose entry per patch (entry 3 = that playbook)
CODING_STANDARDS.md:5                       root "Bash" · template/CODING_STANDARDS.md:35 "Suppressions"
AGENTS.md:36                                root "Verifying" · template/AGENTS.md:60
docs/M0-findings.md · docs/agents/ledger.md:3 · docs/knowledge/core/DECISIONS.md:66
tools/build_knowledge.py · tools/check_knowledge.py
```

## Gotchas

1. **The existing glob is narrower than the ticket's.** `.github/workflows/factory-ci.yml:19` names `spec-review/scripts/*.sh` and `poteto-mode/scripts/*.sh` by hand; `show-me-your-work/scripts/log.sh` is unchecked today. If the shellcheck step uses `template/.agents/skills/*/scripts/*.sh`, it lints a file `bash -n` has never seen, and that file must pass at the merge commit.
2. **The factory root's `.claude/` is symlinks.** `.claude/hooks -> ../template/.claude/hooks` and `.claude/skills -> ../template/.agents/skills`. A glob written as `.claude/hooks/*.sh` in the factory silently lints the template's copies twice if `template/...` is also globbed. Write factory globs against `template/`.
3. **A fix to a vendored script is reverted by `sync`.** Only the four `keep_files` paths survive. A shellcheck fix to `worktree-audit.sh` or `show-me-your-work/scripts/log.sh` must become a patch in `patches/series` with an entry in `SOURCES.md`, or CI's `sync`-clean step (line 33) fails on the next run.
4. **`layout.sh` has no shebang and is sourced.** ShellCheck will guess `sh` and flood it with false positives; it needs `# shellcheck shell=bash` (and the callers' `source`/`.` line needs `# shellcheck source=...` or `-x`). `fake-gh.sh` is genuinely `#!/bin/sh` and must be linted as POSIX sh, not bash.
5. **`chk` cannot produce a NOTE.** It sets `fail=1` on any nonzero. A NOTE-not-FAIL shellcheck line has to be written inline like the models-sheet line at `factory918.sh:272`, not as a `chk`.
6. **`update` overwrites only untouched files.** A project that edited its `ci.yml` gets a three-way merge or a `ci.yml.factory-merge` beside it (`factory918.sh:346-358`); `apply` never overwrites an existing `ci.yml` at all.
7. **Pinning fights the environment.** `docs/M0-findings.md` lists the machine's tools; `shellcheck` is not among them (it was installed by hand 2026-09-21 per the ticket). The doctor NOTE exists precisely because a project machine will not have it, while CI must pin an exact version (P2, `docs/knowledge/core/DECISIONS.md:91`).
8. **Two documents, two audiences.** The CI step is the enforcement; the `CODING_STANDARDS.md` suppression-reason rule is read only at review time by `spec-review`'s Standards axis (`CODING_STANDARDS.md:3`), and that file explicitly says not to repeat what CI enforces. The reason-on-the-same-line rule is the part CI cannot check, so it is the part that belongs there.
