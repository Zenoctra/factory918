### What it does

Adds `template/.github/shellcheck.sh`, a gate that runs ShellCheck 0.11.0 with `--external-sources` over the globs it is given and downloads the pinned release when the pin is not on PATH. The factory reaches it through the symlink `.github/shellcheck.sh`. Three CI steps call it (`factory-ci.yml:19` replacing `bash -n`, `:56` inside the applied fixture, template `ci.yml:18` first in `check`); `tests/shellcheck/gate.sh` asserts its table. The 57 findings at `ab47eb9` are resolved by five code edits (`factory918.sh:273,388,390,402`, `fake-gh.sh:15`) and same-line-reason directives everywhere else. The doctor gains a `shellcheck` line that is PASS or NOTE, never FAIL (`factory918.sh:274-276`). The playbook sentence lands through its patch; both `AGENTS.md` and both `CODING_STANDARDS.md` name the gate.

Not in the diff's words: `show-me-your-work/scripts/log.sh` is linted for the first time (the old `bash -n` glob named two skills by hand), and every `apply` and `update` prints one more doctor line.

### The one fact it's safe because of

Every shell file a session runs through changed only in comment lines, and the three code edits in the CLI produce the same output as before. Rung 4. The script is `scratchpad/proofs.sh`; its output, trimmed:

```
--1 the hook: only comment lines were added
identical after stripping comment lines (191 lines)
line 7 is: set -fuo pipefail
--2 the doctor's two lines, old and new, HOME with and without the sheet, shellcheck on and off PATH
69bd412 sheet=with shellcheck=on
PASS  models sheet
PASS  shellcheck 0.11.0
69bd412 sheet=with shellcheck=off
PASS  models sheet
NOTE  shellcheck
models-sheet output identical in all four states; the shellcheck line is the only addition
--3 cmd_sync's count line
new array: 72   old ls|wc: 72
$skills is "$TEMPLATE/.agents/skills" (factory918.sh:381): never empty
all claims held
```

The other seven directive-only files diff empty the same way. The five behavioural tests pass (537 assertions). The gate over the factory set prints `files checked: 20`, exit 0. `sync` and `build_knowledge.py` leave `git status` empty; `check_knowledge.py` passes.

### Risks

1. **A cached binary runs unchecked.** `template/.github/shellcheck.sh:24-26`. `[ ! -x "$bin" ]` on the predictable `${TMPDIR:-/tmp}/shellcheck-0.11.0` skips the download and the checksum together; on a shared Linux box `/tmp` is world-writable, so whatever sits there runs with the lane's rights. Proven (block 4): a planted `shellcheck` printed `PLANTED BINARY RAN: --external-sources unquoted.sh`, exit 0. Needs a hostile local user or a torn extraction, so unlikely; bad if it happens. Verify the tarball every run, or extract under `mktemp -d`.
2. **An edited `ci.yml` leaves a project with no gate and no warning.** `factory918.sh:354`. The clone has no tags, so every both-changed file becomes `.factory-merge`. Proven on a scratch project with the old `ci.yml` plus one local step: `update` wrote `ci.yml.factory-merge`, the live `ci.yml` has zero `shellcheck` mentions, and the doctor said nothing, since its new line checks only PATH. Medium likelihood for existing projects; the cost is a gate the project thinks it has.
3. **A sandboxed lane without the pin fails with curl's words only.** `:28`. Proven here with ShellCheck hidden: `curl: (22) The requested URL returned error: 403`, exit 22. The playbook step at `opening-a-pr.md:9` cannot run and the lane cannot tell why. Medium on a machine without Homebrew ShellCheck; costs a lane turn.
4. **Linux aarch64 and Intel macOS are unpinned.** `:20-22`. Docker on Apple Silicon, `ubuntu-24.04-arm` runners and `Darwin.x86_64` get `not pinned for Linux.aarch64; install it by hand` unless 0.11.0 is on PATH (block 5). Low today.

### Cleared

- Hook's own invocation: comment-only diff at `delegation.sh:21,165,186,209`; `set -f` is on at `:7`, so the SC2086 reasons are true.
- Review in progress: `review-brief.sh:189` matches `template/.claude/hooks/delegation.sh`, so this PR is briefed with this writeup; the hook's Bash scanner (`delegation.sh:192-198`) matches only `tee`, `cat`, `head`, `sed`, `git`, so the gate is never blocked under review; `review-brief.sh:17` is a file-level directive.
- Day zero: the shellcheck line sits above `slots filled` and is never FAIL, so `factory-start/SKILL.md:14` passes; `apply` and `update` end in `cmd_doctor || true` (`:168`, `:373`); the fixture's `tail -30` gains two lines.
- Subagent per-file run from `/` with absolute paths: exit 0; `source-path=SCRIPTDIR` at `tests/spec-review/review-brief.sh:20` and `review-comment.sh:11`.
- `apply`: real run on a scratch project; `cp -p` (`:137`) keeps 755, the zero-argument gate checked 11 files, exit 0. `update` writes the gate 0644 (`:338`), harmless since every documented call starts with `bash`.
- `bash -n` removal: a missing `fi` is SC1046 and SC1072 at error level, exit 1.
- Root symlink: tracked as 120000, relative target, no `$0` or `BASH_SOURCE` in the gate, `sync` leaves it alone. The zero-argument form there checks 6 files, not 20; `AGENTS.md:38` gives the full form.
- A project that deleted its hooks: the zero-argument form checks only itself and passes; the refusal at `:41` needs the gate missing too. Cosmetic.
- `show-me-your-work/scripts/log.sh`: `shellcheck -x` exit 0; vendored, no patch names it. `wizard/template.sh` is outside the globs and has one SC2034 (`:19`).
- factory-doctor reports the table verbatim; knowledge rebuilds clean with P25 in `template/docs/factory918/DECISIONS.md`; the playbook patch applies, `vendored: 72 skills`.
- `sha256sum`, `shasum` and an xz-capable bsdtar all exist on macOS 15. The download was not run (network denied here), rung 2, as `M0-findings.md:172` says.

### Before you merge

```
TMPDIR=<writable> bash scratchpad/proofs.sh <checkout>
bash .github/shellcheck.sh factory918.sh template/.github/shellcheck.sh 'template/.claude/hooks/*.sh' 'template/.agents/skills/*/scripts/*.sh' 'tests/*/*.sh'
bash tests/shellcheck/gate.sh && bash tests/hooks/delegation.sh
```

Risk 1: plant a `#!/bin/sh` at `$TMPDIR/shellcheck-0.11.0/shellcheck-v0.11.0/shellcheck`, hide ShellCheck from PATH, run the gate. Risk 2: `factory918 update` on a copy of a project that edited `ci.yml`, then `grep -c shellcheck .github/workflows/ci.yml`.
