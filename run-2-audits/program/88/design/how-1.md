# how (lane 1): the shell-quality gates end to end

## Overview

Factory918 has two shell-quality gates today and both are the same command: `bash -n`. The factory's own CI runs it over its shell files in one step; a project applied from `template/` gets no shell gate at all, because `template/.github/workflows/ci.yml` only knows about Vite+ (`vp check`, `pnpm sg`, `vp test run`).

The path a change takes to an applied project is: edit `template/` → `factory918 apply` copies every file under `template/` that does not already exist in the project, recording a sha per path in `.factory918/manifest.json` → later `factory918 update` three-way-merges each managed path from that recorded base. Vendored skills are the exception: they are rebuilt by `factory918 sync` from `research/` plus `patches/series`, so a change to one is a patch file, not a file edit.

## (a) The factory's own CI

`.github/workflows/factory-ci.yml`, two jobs.

**`factory`** (l.12, 10-minute timeout), eight steps on a plain checkout with no toolchain:
- l.18-19 **Shell syntax**: `bash -n factory918.sh && for f in template/.claude/hooks/*.sh template/.agents/skills/spec-review/scripts/*.sh template/.agents/skills/poteto-mode/scripts/*.sh tests/*/*.sh; do bash -n "$f"; done`. Compared with the ticket's set ("every `scripts/*.sh` under `template/.agents/skills/`"), this glob misses `template/.agents/skills/show-me-your-work/scripts/log.sh`, and neither set names `template/.agents/skills/wizard/template.sh` (not under `scripts/`, mode 100644, a library the wizard skill copies rather than runs).
- l.20-29: the four test scripts, then `tests/spec-review/no-stale-wording.sh`.
- l.30-31 knowledge: `python3 tools/check_knowledge.py && python3 tools/build_knowledge.py && git diff --exit-code`.
- l.32-33 vendoring: `./factory918.sh sync > /dev/null && git diff --exit-code && test -z "$(git status --porcelain template)"`.

**`fixture`** (l.34, 20 minutes): `vp create` a monorepo at `/tmp/fx` (l.49), commit, `./factory918.sh apply /tmp/fx --scaffold --profile python --name demo` (l.51). Then: `review-brief.sh` run from `/tmp/fx` through the applied path with `tests/spec-review/fake-gh.sh` copied to `/tmp/fake-gh/gh` on `PATH` (l.56-58); `vp check && vp test run && pnpm sg:test && pnpm sg` (l.71); the Python profile's job inline (l.74); a rule-firing probe (l.77-82).

The fixture never runs `/tmp/fx/.github/workflows/ci.yml`. Its "The gates a project runs" step (l.69-71) re-types the template CI's commands by hand. A new step added to `template/.github/workflows/ci.yml` is not exercised by factory CI unless the fixture job is given a matching step.

## (b) The template's CI and how apply/update carry it

`template/.github/workflows/ci.yml` has jobs `check` (l.11: committed-evidence rejection, `setup-vp`, `vp check`, `pnpm sg`, `vp run -r build`) and `test` (l.32: `vp test run`). No shell step.

`cmd_apply` (`factory918.sh:107`) walks `template/` with `find . -type f` (l.131), skips `package.scripts.json` and `.gitignore.factory` (l.133), and copies each path only when it does not already exist in the project (l.136), except the four `FACTORY_OWNED` paths under `--scaffold` (l.35, l.135). It records `sha256` of the template file into `.factory918/manifest.json` (l.139-140). `.github/workflows/ci.yml`, all five `template/.claude/hooks/*.sh` and every `template/.agents/skills/**` file land at the same relative path in the project. `.claude/skills` is a symlink created at l.143 (`ln -s ../.agents/skills`), and `chmod +x "$dir"/.claude/hooks/*.sh` runs at l.155.

`cmd_update` (l.301) is a Python heredoc doing a three-way merge per managed path: `O` = the template file at the tag `v<recorded version>` (l.318-320), `N` = the template now, `L` = the project's file. Untouched locally → take the new template (l.346); both changed → `git merge-file` (l.353), conflict written to `<file>.factory-merge` (l.358); deleted locally → `state: deleted`, never re-added (l.339). A project that already had its own `ci.yml` at apply time keeps it, so a new CI step reaches it only through `update`'s merge.

## (c) `cmd_doctor`

`factory918.sh:236`. Helpers at l.238-239:

```
chk() { if eval "$2" >/dev/null 2>&1; then echo "PASS  $1"; else echo "FAIL  $1"; echo "      fix: $3"; fail=1; fi; }
note() { echo "NOTE  $1"; echo "      fix: $2"; }
```

`chk <label> <command string> <fix>`: the command is `eval`'d, output swallowed, a failure sets `fail=1`, the exit code at l.288. `note` never fails the run. The tail is `[ "$fail" = 0 ] && echo "all clear" || echo "start with the first FAIL"` (l.287).

NOTE-not-FAIL patterns:
- models sheet, l.272: `[ -f "$HOME/.claude/pstack-models.md" ] && echo "PASS  models sheet" || note "models sheet" "factory918 install writes ~/.claude/pstack-models.md"`.
- delete-branch-on-merge, l.260-262: a value is captured first with `|| true` inside the substitution, then `true` → PASS, `false` → NOTE, anything else prints nothing. That is the template for "a tool that may simply be absent": capture, branch, print nothing when the question cannot be asked. `CODING_STANDARDS.md:11`: "A `FAIL` with no fix is a bug."

`chk` `eval`s its second argument, so every quote in a check string is escaped twice (l.248-250). A new doctor line for `shellcheck` should follow the capture-then-branch shape.

## (d) The vendored-skill patch mechanism

`cmd_sync` (`factory918.sh:375`):
1. `keep_files` (l.381): `poteto-mode/playbooks/ticket.md`, `poteto-mode/scripts/overlap.sh`, `spec-review/scripts/review-brief.sh`, `spec-review/scripts/review-comment.sh` are copied to a temp dir (l.383), the vendored trees wiped and re-copied (l.384-387), then the kept files copied back (l.388). Everything under a vendored skill not in `keep_files` is restored from the pin; `worktree-audit.sh` and `show-me-your-work/scripts/log.sh` are upstream files, not ours.
2. `patches/series` is applied in order with `git -C "$skills" apply` (l.391-395); a patch that no longer applies prints `FAILED` and sets the exit code.

`patches/README.md:9`: `diff -u --label a/<path> --label b/<path> research/<upstream>/<path> template/.agents/skills/<path> > patches/<source>/<path>.patch`.

`opening-a-pr.md` is edited through `patches/pstack/poteto-mode/playbooks/opening-a-pr.md.patch` (line 7 of `series`, item 3 in `SOURCES.md`); the **PRs** paragraph is `opening-a-pr.md:9`. `./factory918.sh sync` must leave `git diff --exit-code` clean and `git status --porcelain template` empty (factory-ci l.33).

## (e) The shell files

| Path | Mode | Shebang | How it runs |
|---|---|---|---|
| `factory918.sh` | 755 | bash | executed, also via `~/.local/bin/factory918` symlink |
| `template/.claude/hooks/{block-dangerous-git,delegation,format-on-write,mode,session-start}.sh` | 755 | bash | Claude Code hooks |
| `template/.agents/skills/poteto-mode/scripts/{overlap,worktree-audit}.sh` | 755 | bash | overlap.sh ours (`keep_files`); worktree-audit.sh vendored |
| `template/.agents/skills/show-me-your-work/scripts/log.sh` | 755 | bash | vendored; not in today's CI glob |
| `template/.agents/skills/spec-review/scripts/{review-brief,review-comment}.sh` | 755 | bash | ours (`keep_files`) |
| `template/.agents/skills/wizard/template.sh` | 644 | bash | vendored library; outside the ticket's set |
| `tests/hooks/delegation.sh`, `tests/poteto-mode/overlap.sh`, `tests/spec-review/{no-stale-wording,review-brief,review-comment}.sh` | mixed | bash | `bash <file>` |
| `tests/spec-review/layout.sh` | 644 | none | sourced by `review-brief.sh:20` and `review-comment.sh:11` |
| `tests/spec-review/fake-gh.sh` | 755 | `#!/bin/sh` | copied onto PATH as `gh` by `tests/spec-review/review-brief.sh:25` and factory-ci l.56 |

Existing directives, both SC2016:
- `template/.agents/skills/poteto-mode/scripts/overlap.sh:49`: indented, on the line before the `grep -oE` pipeline, no reason of its own (the header explains).
- `tests/poteto-mode/overlap.sh:17`: file-level, the last line of the header block above `set -euo pipefail`; the header's last sentence justifies it: "The backticks in the bodies below are the ticket's token delimiters, not command substitutions."

At `-S warning` over the ticket's set the findings are: `factory918.sh:249` SC2088 (prose inside a chk fix string; false positive), `factory918.sh:384,386` SC2115 (`rm -rf "$skills/$n"` in `cmd_sync`), `tests/spec-review/layout.sh:1` SC2148 error (sourced, no shebang), `layout.sh:12,20` SC2034 (`hooks`/`skill` set for the sourcing test).

## (f) Where the rules go

- Root `AGENTS.md:36-46`, "Verifying": `bash -n factory918.sh` is l.38, the four test commands l.39-42, `./factory918.sh sync` l.44, the fixture flow l.45, l.46 "Anything verified against a tool version gets a dated line in `docs/M0-findings.md`."
- Root `CODING_STANDARDS.md:5-14`, "## Bash": l.3 says "Skip anything the CI gate already enforces", so the rule worth writing is about directives, not about running the tool.
- `template/CODING_STANDARDS.md:35-37`, "## Suppressions": the sentence shape a `# shellcheck disable=` rule extends; the template's standards have no Bash section.

## (g) Records and the knowledge build

- `docs/M0-findings.md`: dated H2 sections, prose paragraphs naming the tool version, later amendments inlined as `2026-09-17: …` sentences.
- `docs/agents/ledger.md:3`: `YYYY-MM-DD | model | what it did | what you wanted`, append-only.
- `docs/knowledge/core/DECISIONS.md:66` `## Provisional (added by agents; Manuel promotes or overrules)`, a table `| # | Decision | Choice | Reason |`, ids `P1`…; the Reason cell ends with an attribution and date. Highest live id today: P24 (P19 was the lane's count; PR #92 added P24).
- `python3 tools/build_knowledge.py` regenerates each core file in place (header and TOC), the slim copies `template/docs/factory918/{PHILOSOPHY,MANUAL,DECISIONS,GLOSSARY}.md`, all of `docs/knowledge/{spec,pages,notes}/`, and `docs/knowledge/INDEX.md`. Changing only `DECISIONS.md` still needs a rebuild; factory CI l.31 catches a missed one.

## Gotchas

1. The factory root's `.claude/hooks` and `.claude/skills` are symlinks into `template/`. In `/tmp/fx` the same paths are real files.
2. The fixture job does not run the template's CI; a step added to `template/.github/workflows/ci.yml` alone gets zero coverage.
3. `tests/spec-review/layout.sh` has no shebang (SC2148 is an error) because it is sourced; `tests/spec-review/fake-gh.sh` is `#!/bin/sh`, checked in the POSIX dialect.
4. Three of the five skill scripts are vendored; a finding in `worktree-audit.sh` or `log.sh` is fixed by a patch in `patches/` + `series` + `SOURCES.md`, not by editing the file.
5. Pinning style: the factory CI pins by action input with a trailing comment (`version: "0.3.1" # the ADR pin`, l.42); project pins live in `template/docs/adr/0001-toolchain.md:3`.
6. `cmd_sync` trips SC2115 twice (l.384, l.386).
