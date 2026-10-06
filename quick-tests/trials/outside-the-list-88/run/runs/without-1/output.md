## Final message

/private/tmp/wsbox/w-20261005-191428-d2b2/scratchpad/blast-radius.md

## File written: scratchpad/blast-radius.md

```
### What it does

Adds one shell gate, `template/.github/shellcheck.sh`, which runs ShellCheck 0.11.0 with `--external-sources` over the globs given and downloads the pinned build when the machine lacks it; the factory reaches it through the symlink `.github/shellcheck.sh`. Three CI steps call it (`.github/workflows/factory-ci.yml:18`, `:54`, `template/.github/workflows/ci.yml:17`), `tests/shellcheck/gate.sh` asserts its table, and the 57 findings on the factory's 20 files are resolved, mostly with same-line-reasoned directives. The doctor gains a NOTE-not-FAIL row (`factory918.sh:274`), the Opening a PR playbook a sentence through its patch, the four standards files a line each, `DECISIONS.md` P25.

Not spelled out by the diff: every project that runs `factory918 update` gets a first CI step that lints its hooks and skill scripts, edited ones included. Ticket #88 was unreadable (`gh` unauthenticated); the commits and design notes stood in.

### The one fact it's safe because of

Nothing a running session executes changed its behaviour. The four shipped scripts the diff touches changed only in comment lines, and the CLI's three code edits print what they printed before, plus one doctor row. Rung 4, run at `69bd412` in a throwaway worktree.

Comment lines stripped from both versions, then hashed:

```
same once comments stripped: delegation.sh (191 lines both sides), review-brief.sh, review-comment.sh, overlap.sh
```

The gate and every test the Verifying list names:

```
gate over the factory set: ShellCheck 0.11.0, files checked: 20, exit 0
gate.sh ok 10, delegation.sh ok 55, review-comment.sh ok 82, review-brief.sh ok 334, overlap.sh ok 56
```

`sync` printed `vendored: 72 skills` (the old `ls | wc -l` form also gives 72) and left `git status` empty, so `${skills:?}` never fired: `$skills` is `"$TEMPLATE/.agents/skills"` (`factory918.sh:381`) over a `TEMPLATE` set at `:9`. The doctor, old script against new, on a stub project, tool on PATH then hidden with an empty HOME:

```
old:  PASS  models sheet        |  NOTE  models sheet / fix: factory918 install writes ~/.claude/pstack-models.md
new:  PASS  models sheet        |  NOTE  models sheet / fix: (same)
      PASS  shellcheck 0.11.0   |  NOTE  shellcheck / fix: brew install shellcheck (...)
```

`build_knowledge.py` leaves status clean; `check_knowledge.py` says `knowledge ok: 118 files`.

Harness note: bare `mktemp -d` here ignores `TMPDIR` and the sandbox denies `/var/folders`, so the tests ran behind a `mktemp` shim supplying a scratchpad template.

### Risks

1. A sandboxed lane without network cannot run the gate when ShellCheck at the pin is off PATH. `template/.github/shellcheck.sh:18` misses the pin, `:28` curls GitHub, and the lane sees curl's error, not the gate's. Reproduced with the tool hidden and `github.com` denied: `curl: (22) The requested URL returned error: 403`, exit 22. Likely for any sandboxed writer lane without 0.11.0; the cost is a lane that skips the sentence at `template/.agents/skills/poteto-mode/playbooks/opening-a-pr.md:9` and lets CI find it, the round the ticket wanted to save. Check: `PATH=/usr/bin:/bin bash .github/shellcheck.sh <file>` inside a lane.
2. The linux checksum at `template/.github/shellcheck.sh:15` and the download path are unproven here (`docs/M0-findings.md:85` says so). If wrong, every project CI fails at its first step and the fixture at `factory-ci.yml:54`. Low likelihood, high cost; this PR's fixture job is the proof.
3. `tests/shellcheck/gate.sh:75` hides ShellCheck with `PATH="$fx/bin:/usr/bin:/bin"`, assuming `/usr/bin/shellcheck` is absent or off the pin. GitHub's Ubuntu image preinstalls one there; the day it ships 0.11.0, check 6 finds the pin, lints `clean.sh` clean, and the test wants exit 1. Low now, rising with runner updates; cost is a red factory CI with a clear name. Check: `/usr/bin/shellcheck --version` on the runner.
4. A project that edited a hook and runs `update` gets `template/.github/workflows/ci.yml:17` as its first step while its edit is kept (`factory918.sh:350`, `:352`). One unquoted expansion there turns its next CI red. Moderate for such projects; cost is one fix commit. Check: `bash .github/shellcheck.sh` in the project before pushing the update.
5. `template/.agents/skills/wizard/template.sh` is outside the zero-argument set (`template/.github/shellcheck.sh:35`) and the factory set (`AGENTS.md:38`), and has a real SC2034 at line 19. A lane editing it follows the playbook sentence, fails a gate CI never runs, and cannot suppress it (vendored, no patch). Low on both counts.
### Cleared

- Hook's own invocation: `template/.claude/hooks/delegation.sh:21`, `:165`, `:186`, `:209` are the only added lines, all comments; 55 assertions pass.
- Review in progress: `review-brief.sh:189` matches the hook path; on `ab47eb9` it refused without a grounding and wrote no state, and with one listed 27 files including the hook in `.claude/state/review/files`, which `delegation.sh:63` reads.
- Interactive session: `AGENTS.md:38` is the CI step verbatim; `delegation.sh:191` does not scan `bash`.
- Day zero: `factory-start/SKILL.md:14` accepts NOTE above `slots filled` (shellcheck is row 36, `slots filled` 39); `factory-doctor/SKILL.md:6` prints the table as is; the fixture's `tail -30` (`factory-ci.yml:53`) only displays; `apply` copies the gate with `cp -p` (`factory918.sh:137`).
- show-me-your-work `log.sh` and `worktree-audit.sh`: clean under the pin; vendored, outside `keep_files` (`factory918.sh:385`), so a re-pin with a finding needs a patch.
- knowledge: `docs/knowledge/INDEX.md:10` says 93 lines; `template/docs/factory918/DECISIONS.md:85` carries P25. Patch 7 in `patches/series` applied under `sync`; `SOURCES.md:15` describes the sentence.

### Before you merge

- Watch this PR's `fixture` job through `The shell gate a project runs`, the only proof of the linux checksum and the download.
- In a sandboxed lane: `PATH=/usr/bin:/bin bash .github/shellcheck.sh tests/shellcheck/gate.sh`. A curl error means risk 1 is live.
- For each of the four scripts above: `diff <(git show ab47eb9:$f | grep -vE '^\s*#') <(git show 69bd412:$f | grep -vE '^\s*#')` prints nothing.
- `bash tests/shellcheck/gate.sh && bash tests/hooks/delegation.sh && ./factory918.sh sync && git status --porcelain` (expect `vendored: 72 skills`, no status output).
```

## File written: scratchpad/bin/mktemp

```
#!/bin/sh
if [ $# -eq 0 ]; then exec /usr/bin/mktemp "${TMPDIR:-/tmp}/tmp.XXXXXXXXXX"; fi
if [ $# -eq 1 ] && [ "$1" = -d ]; then exec /usr/bin/mktemp -d "${TMPDIR:-/tmp}/tmp.XXXXXXXXXX"; fi
exec /usr/bin/mktemp "$@"
```

## File written: scratchpad/fake-gh/gh

```
#!/bin/sh
# A gh for review-brief.sh: copied onto PATH as `gh` by tests/spec-review/review-brief.sh and by the
# CI fixture step. Fixtures are read from FAKE_GH_DIR, default the current directory (the script
# runs at the repository root):
#   pr.json     the PR, its author and comments; the script's own jq expression runs against it, so
#               the author filter is what is tested. Absent: a PR with no comments.
#   pr-error    printed to stderr with exit 1 in place of the comments (a failing gh).
#   FAKE_PR_BODY  the file whose text is the PR body for `gh pr view --json body`; unset or missing:
#               no PR for this branch.
# `gh issue view` answers with a fixed ticket body holding an acceptance-criteria list, and with the
# ticket author's comments already in the shape the script's jq expression prints (a comment by
# someone else is left out), so a run needs no fixture at all.
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

## Other files written (not shown)

scratchpad/tmp/blast.md
scratchpad/tmp/fake-gh/gh
scratchpad/tmp/proj/.factory918/manifest.json
