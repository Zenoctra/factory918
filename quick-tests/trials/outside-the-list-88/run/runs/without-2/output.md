## Final message

/private/tmp/wsbox/w-20261005-191428-b45f/scratchpad/blast-radius.md

## File written: scratchpad/blast-radius.md

```
### What it does

Adds `template/.github/shellcheck.sh`, which pins ShellCheck 0.11.0, downloads that build when the machine lacks it (`:18`, `:28`), and runs `--external-sources` over the globs it is given (`:45`). The factory reaches it through the symlink `.github/shellcheck.sh`. Three CI steps call it (`.github/workflows/factory-ci.yml:19`, `:56`; `template/.github/workflows/ci.yml:18`). The 57 findings at `ab47eb9` are resolved with reasoned directives and five code edits (`factory918.sh:273`, `:274-276`, `:388`, `:390`, `:402-403`; `tests/spec-review/fake-gh.sh:15`). The prose lands in the playbook through its patch, both `AGENTS.md`, both `CODING_STANDARDS.md`, `docs/M0-findings.md:170` and P25.

Not in the diff's text: the project glob now lints two upstream scripts nothing linted before, and every project CI gains a first step that needs github.com unless the runner has 0.11.0.

### The one fact it's safe because of

Nothing that runs in a session changed behaviour. The hook and the three skill scripts changed only in comment lines; the CLI's edits print what they printed before. Rung 4.

```
$ diff ab47eb9 vs 69bd412, comment lines stripped (sed '/^[[:space:]]*#/d'):
IDENTICAL: delegation.sh (191 lines), review-brief.sh, review-comment.sh, overlap.sh
$ bash tests/hooks/delegation.sh            -> ok 55 assertions
$ ls -d template/.agents/skills/*/ | wc -l  -> 72
$ ./factory918.sh sync                      -> vendored: 72 skills. ...; git status clean
$ doctor at ab47eb9 vs 69bd412, HOME empty, diff:
33a34
> PASS  shellcheck 0.11.0                   (only this line; models sheet NOTE identical)
$ bash .github/shellcheck.sh <20-file set>  -> files checked: 20, exit 0
$ gate 10, review-comment 82, review-brief 334, overlap 56 assertions, ok
```

`${skills:?}` cannot fire. `skills` is `"$TEMPLATE/.agents/skills"` at `factory918.sh:381`, `TEMPLATE` is `"$F918_DIR/template"` at `:9`, so it is never empty; `sync` ran through both lines.

### Risks

1. A lane without network and without 0.11.0 on PATH cannot run the gate. `template/.github/shellcheck.sh:18` decides to download, `:28` curls, `set -e` ends the run at exit 22. Reproduced in this sandbox with ShellCheck hidden (`curl: (22) ... 403`, `exit 22`). The sentence at `template/.agents/skills/poteto-mode/playbooks/opening-a-pr.md:9` then cannot be obeyed, and the doctor's NOTE at `factory918.sh:276` promises a download that will not come; apt's 0.10.0 prints PASS at `:275` and still downloads. Likely for sandboxed lanes, cheap. CI runs the gate anyway, at the price of the review round #88 set out to remove. To see it, hide `shellcheck` from PATH.

2. The zero-argument form in the factory root checks 6 files and passes. `:35` defaults to the project globs; at the factory root `.claude/hooks` is a symlink so the hooks match, `.agents/skills` does not exist, and 14 of 20 files go unchecked. Output here was `files checked: 6`, exit 0. A lane following the project sentence in the factory gets a green over a third of the set. Likely, cheap. The full command at `AGENTS.md:38` must print 20.

3. The Linux checksum is unproven. github.com is denied in this sandbox, and `docs/M0-findings.md:172` says it was not run on the author's machine. If the digest at `:14` is wrong, `sha256sum -c` at `:29` fails and every project's first CI step goes red. Unlikely, costly. The fixture job on this PR is the proof; do not merge on a red one.

4. An existing project can go red after `update`. `template/.github/workflows/ci.yml:18` lints the project's hooks and skill scripts. `update` overwrites an untouched hook (`factory918.sh:350`), but an edited one goes to `git merge-file` (`:357`) and on conflict stays old (`:362`); the old `delegation.sh` has 4 findings under the gate, and a project's own `scripts/*.sh` were never linted. Medium for projects with their own scripts. Run `bash .github/shellcheck.sh` in the project before merging its update.

### Cleared

- Hook invocation. `delegation.sh` edits are lines 22, 165, 186, 209, all comments; proof above.
- Review in progress. `review-brief.sh:17` is a file-level directive before `set -e`; the predicate at `:189` and the hook's state read at `delegation.sh:27` are unchanged. With a review planted, the hook blocks `cat` of a file under review (exit 2) and passes the gate on it (exit 0), as it always did for `bash -n`.
- factory-start at day zero. `template/.agents/skills/factory-start/SKILL.md:14` wants PASS or NOTE above `slots filled`; the new line sits above it (34 against 37) and is PASS or NOTE only (`factory918.sh:275-276`). `factory-doctor/SKILL.md:6` prints it verbatim. The `tail -30` at `factory-ci.yml:53` is display; nothing parses the doctor.
- Sub-agent with the pin. A per-file run from another directory on `tests/spec-review/review-brief.sh` passes because of `:21`; without `-x` it prints 8 lines of SC1091 and SC2154.
- spec-review and poteto-mode scripts. Comment-only; the playbook sentence survives `sync`.
- show-me-your-work `log.sh` and `worktree-audit.sh`. Newly linted, pass alone (`files checked: 2`); pinned under `research/`, so only a re-pin changes them.
- wizard. `template/.agents/skills/wizard/template.sh` is not under `scripts/`, so no glob reaches it; under the gate it fails with SC2034 at `template.sh:19`. Widen the glob and CI goes red.
- knowledge. Build leaves the tree clean, `check_knowledge.py` passes, `template/docs/factory918/DECISIONS.md:85` is the generated P25.
- `apply`. `cp -p` at `factory918.sh:137` keeps the mode bit; gate test check 5 covers the project layout.
- `fake-gh.sh:15`. Same two branches, under 416 assertions.

### Before you merge

```
the command at AGENTS.md:38                 # prints files checked: 20
bash tests/shellcheck/gate.sh && bash tests/hooks/delegation.sh
f=template/.claude/hooks/delegation.sh; diff <(git show main:$f | sed '/^[[:space:]]*#/d') <(sed '/^[[:space:]]*#/d' $f)   # empty
./factory918.sh sync | tail -1              # vendored: 72 skills; git status clean
PATH=/usr/bin:/bin TMPDIR=$(mktemp -d) bash .github/shellcheck.sh tests/shellcheck/gate.sh   # the download; needs github.com
```

This sandbox could not run the last line; the fixture job runs it on Linux.
```

## File written: scratchpad/fakehome/.claude/pstack-models.md

```

```

## File written: scratchpad/a.txt

```
d="${FAKE_GH_DIR:-.}"
case "$*" in
  "pr view --json body"*) [ -f "${FAKE_PR_BODY:-}" ] && cat "$FAKE_PR_BODY" || { echo 'no pull requests found for branch "x"' >&2; exit 1; } ;;
  "pr view"*)
    if [ -f "$d/pr-error" ]; then cat "$d/pr-error" >&2; exit 1; fi
    while [ "$1" != -q ]; do shift; done
    if [ -f "$d/pr.json" ]; then exec jq -r "$2" "$d/pr.json"; fi
    echo '{"author": {"login": "me"}, "comments": []}' | exec jq -r "$2" ;;
  *"--json body"*) printf '## What to build\n\nWhat to build: the ticket body\n\n## Acceptance criteria\n\n- [ ] The brief carries the ticket body.\n' ;;
  *"--json author,comments"*) printf '### 2026-09-17\n\nuser: the hook stays in bash.\n\n### 2026-09-18\n\nuser: the count is Act on plus Ask.\n\n' ;;
  *) echo "fake gh: unexpected args: $*" >&2; exit 2 ;;
esac
```

## File written: scratchpad/b.txt

```
d="${FAKE_GH_DIR:-.}"
case "$*" in
  "pr view --json body"*) if [ -f "${FAKE_PR_BODY:-}" ]; then cat "$FAKE_PR_BODY"; else echo 'no pull requests found for branch "x"' >&2; exit 1; fi ;;
  "pr view"*)
    if [ -f "$d/pr-error" ]; then cat "$d/pr-error" >&2; exit 1; fi
    while [ "$1" != -q ]; do shift; done
    if [ -f "$d/pr.json" ]; then exec jq -r "$2" "$d/pr.json"; fi
    echo '{"author": {"login": "me"}, "comments": []}' | exec jq -r "$2" ;;
  *"--json body"*) printf '## What to build\n\nWhat to build: the ticket body\n\n## Acceptance criteria\n\n- [ ] The brief carries the ticket body.\n' ;;
  *"--json author,comments"*) printf '### 2026-09-17\n\nuser: the hook stays in bash.\n\n### 2026-09-18\n\nuser: the count is Act on plus Ask.\n\n' ;;
  *) echo "fake gh: unexpected args: $*" >&2; exit 2 ;;
esac
```

## File written: scratchpad/d.txt

```
3c3
<   "pr view --json body"*) [ -f "${FAKE_PR_BODY:-}" ] && cat "$FAKE_PR_BODY" || { echo 'no pull requests found for branch "x"' >&2; exit 1; } ;;
---
>   "pr view --json body"*) if [ -f "${FAKE_PR_BODY:-}" ]; then cat "$FAKE_PR_BODY"; else echo 'no pull requests found for branch "x"' >&2; exit 1; fi ;;
```

## File written: scratchpad/dl/clean.sh

```
#!/usr/bin/env bash
set -euo pipefail
echo "hi $1"
```

## File written: scratchpad/doctor-new.txt

```
PASS  factory files reachable
FAIL  factory918 installed
      fix: in the factory918 clone run ./factory918.sh install, add ~/.local/bin to PATH, open a new terminal
PASS  one factory on this machine
PASS  vp matches the ADR pin
FAIL  vp on PATH
      fix: curl -fsSL https://vite.plus -o /tmp/vp.sh && VP_VERSION=0.3.1 VP_NODE_MANAGER=yes bash /tmp/vp.sh, then open a new terminal
FAIL  vp env doctor
      fix: run vp env doctor and follow its output
FAIL  hooks installed
      fix: vp hooks enable (no .git means this is not a repository yet: git init first)
FAIL  .claude/skills symlink
      fix: rm -rf .claude/skills && ln -s ../.agents/skills .claude/skills
PASS  every skill has a name
PASS  no duplicate skill names
FAIL  gh authenticated
      fix: gh auth login (install gh first: brew, apt, dnf or winget)
FAIL  labels present
      fix: factory918 labels (needs a GitHub remote; factory918 init creates one, or gh repo create --private --source=. --push)
FAIL  ci workflow present
      fix: factory918 update restores it
FAIL  settings.json parses
      fix: fix the JSON in .claude/settings.json, or factory918 update to restore the template copy
FAIL  hooks executable
      fix: chmod +x .claude/hooks/*.sh
FAIL  state dir ignored
      fix: append the lines from the factory clone's template/.gitignore.factory to .gitignore
FAIL  vp check (format, lint, types)
      fix: vp fmt, then vp check, and fix what it reports; it stops at the first failing stage
FAIL  tests
      fix: vp test run and read the failing test
NOTE  models sheet
      fix: factory918 install writes ~/.claude/pstack-models.md
PASS  shellcheck 0.11.0
FAIL  AGENTS.md is Factory918's
      fix: factory918 apply --scaffold replaces the AGENTS.md that vp create wrote
PASS  slots filled (/factory-start)
FAIL  slim knowledge present
      fix: factory918 update restores docs/factory918/
FAIL  glue skills resolve
      fix: factory918 update restores the factory918, factory-start, knowledge and factory-retro skills
FAIL  ledger exists
      fix: factory918 update restores docs/agents/ledger.md
FAIL  ast-grep rules test
      fix: vp install (the rule engine is a devDependency), then pnpm sg:test; a rule without a snapshot needs ast-grep test --update-all
start with the first FAIL
```

## File written: scratchpad/doctor-old.txt

```
PASS  factory files reachable
FAIL  factory918 installed
      fix: in the factory918 clone run ./factory918.sh install, add ~/.local/bin to PATH, open a new terminal
PASS  one factory on this machine
PASS  vp matches the ADR pin
FAIL  vp on PATH
      fix: curl -fsSL https://vite.plus -o /tmp/vp.sh && VP_VERSION=0.3.1 VP_NODE_MANAGER=yes bash /tmp/vp.sh, then open a new terminal
FAIL  vp env doctor
      fix: run vp env doctor and follow its output
FAIL  hooks installed
      fix: vp hooks enable (no .git means this is not a repository yet: git init first)
FAIL  .claude/skills symlink
      fix: rm -rf .claude/skills && ln -s ../.agents/skills .claude/skills
PASS  every skill has a name
PASS  no duplicate skill names
FAIL  gh authenticated
      fix: gh auth login (install gh first: brew, apt, dnf or winget)
FAIL  labels present
      fix: factory918 labels (needs a GitHub remote; factory918 init creates one, or gh repo create --private --source=. --push)
FAIL  ci workflow present
      fix: factory918 update restores it
FAIL  settings.json parses
      fix: fix the JSON in .claude/settings.json, or factory918 update to restore the template copy
FAIL  hooks executable
      fix: chmod +x .claude/hooks/*.sh
FAIL  state dir ignored
      fix: append the lines from the factory clone's template/.gitignore.factory to .gitignore
FAIL  vp check (format, lint, types)
      fix: vp fmt, then vp check, and fix what it reports; it stops at the first failing stage
FAIL  tests
      fix: vp test run and read the failing test
NOTE  models sheet
      fix: factory918 install writes ~/.claude/pstack-models.md
FAIL  AGENTS.md is Factory918's
      fix: factory918 apply --scaffold replaces the AGENTS.md that vp create wrote
PASS  slots filled (/factory-start)
FAIL  slim knowledge present
      fix: factory918 update restores docs/factory918/
FAIL  glue skills resolve
      fix: factory918 update restores the factory918, factory-start, knowledge and factory-retro skills
FAIL  ledger exists
      fix: factory918 update restores docs/agents/ledger.md
FAIL  ast-grep rules test
      fix: vp install (the rule engine is a devDependency), then pnpm sg:test; a rule without a snapshot needs ast-grep test --update-all
start with the first FAIL
```

## Other files written (not shown)

scratchpad/doctor-proj/.factory918/manifest.json
scratchpad/fakehome/.local/state/gh/device-id
scratchpad/hook-new.txt
scratchpad/hook-old.txt
scratchpad/old-hook.sh
scratchpad/probe-err.txt
scratchpad/shim/mktemp
