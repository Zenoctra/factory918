## Final message

/private/tmp/wsbox/w-20261005-191428-dafc/scratchpad/blast-radius.md

## File written: scratchpad/blast-radius.md

```
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
```

## File written: scratchpad/bin/mktemp

```
#!/bin/sh
# Sandbox shim: macOS mktemp ignores TMPDIR when called without a template, and the sandbox
# refuses /var/folders. Append a template under TMPDIR when the caller gave none.
for a in "$@"; do case "$a" in -*) ;; *) exec /usr/bin/mktemp "$@" ;; esac; done
exec /usr/bin/mktemp "$@" "${TMPDIR:-/tmp}/tmp.XXXXXXXXXX"
```

## File written: scratchpad/proofs.sh

```
#!/usr/bin/env bash
# Blast-radius proofs for #88 at 69bd412. Run from anywhere: bash proofs.sh <worktree>.
# Every block prints what it ran and exits 1 on the first claim that does not hold.
set -uo pipefail
wt="${1:?worktree path}"; old=ab47eb9; new=69bd412
t="${TMPDIR:?}"; mkdir -p "$t/p"; cd "$wt"
die() { echo "CLAIM FAILED: $1"; exit 1; }

echo "--1 the hook: only comment lines were added"
git show "$old:template/.claude/hooks/delegation.sh" | grep -v '^[[:space:]]*#' > "$t/p/hook-old"
git show "$new:template/.claude/hooks/delegation.sh" | grep -v '^[[:space:]]*#' > "$t/p/hook-new"
diff "$t/p/hook-old" "$t/p/hook-new" && echo "identical after stripping comment lines ($(wc -l < "$t/p/hook-new" | tr -d ' ') lines)" || die "hook code changed"
sed -n '7p' template/.claude/hooks/delegation.sh | grep -q 'set -f' && echo "line 7 is: $(sed -n 7p template/.claude/hooks/delegation.sh)" || die "set -f is not on line 7"

echo "--2 the doctor's two lines, old and new, HOME with and without the sheet, shellcheck on and off PATH"
mkdir -p "$t/p/with/.claude" "$t/p/without"; touch "$t/p/with/.claude/pstack-models.md"
for rev in $old $new; do
  git show "${rev}:factory918.sh" | sed -n '/PASS  models sheet/,/^  chk "AGENTS.md/p' | grep -v '^  chk' > "$t/p/doctor-$rev.sh"
  echo "$rev: $(wc -l < "$t/p/doctor-$rev.sh" | tr -d ' ') lines extracted"
  for h in with without; do for p in on off; do
    [ $p = on ] && path="$PATH" || path=/usr/bin:/bin
    out="$(HOME="$t/p/$h" PATH="$path" bash -c 'note() { echo "NOTE  $1"; echo "      fix: $2"; }; set -euo pipefail; d() { source "$1"; }; d "$1"' _ "$t/p/doctor-$rev.sh")"
    printf '%s sheet=%s shellcheck=%s\n%s\n' "$rev" "$h" "$p" "$out"
    printf '%s\n' "$out" > "$t/p/out-$rev-$h-$p"
  done; done
done
for h in with without; do for p in on off; do
  grep -v shellcheck "$t/p/out-$old-$h-$p" > "$t/p/a"; grep -v shellcheck "$t/p/out-$new-$h-$p" > "$t/p/b"
  diff "$t/p/a" "$t/p/b" >/dev/null || die "models-sheet line differs ($h, $p)"
done; done
echo "models-sheet output identical in all four states; the shellcheck line is the only addition"

echo "--3 cmd_sync's count line"
skills="$wt/template/.agents/skills"; dirs=("$skills"/*/)
echo "new array: ${#dirs[@]}   old ls|wc: $(ls -d "$skills"/*/ | wc -l | tr -d ' ')"
[ "${#dirs[@]}" = "$(ls -d "$skills"/*/ | wc -l | tr -d ' ')" ] || die "count differs"
grep -q '^  local skills="\$TEMPLATE/.agents/skills"$' factory918.sh && echo '$skills is "$TEMPLATE/.agents/skills" (factory918.sh:381): never empty' || die "skills assignment moved"

echo "--4 the gate reuses a cached binary without a checksum"
c="$t/p/cache"; rm -rf "$c"; mkdir -p "$c/shellcheck-0.11.0/shellcheck-v0.11.0"
printf '#!/bin/sh\necho "PLANTED BINARY RAN: $*"\n' > "$c/shellcheck-0.11.0/shellcheck-v0.11.0/shellcheck"; chmod +x "$c/shellcheck-0.11.0/shellcheck-v0.11.0/shellcheck"
printf '#!/usr/bin/env bash\nf=$1\ncat $f\n' > "$t/p/unquoted.sh"
(cd "$t/p" && TMPDIR="$c" PATH=/usr/bin:/bin bash "$wt/.github/shellcheck.sh" unquoted.sh); code=$?
[ $code = 0 ] || die "expected the planted binary to run and exit 0, got $code"

echo "--5 Linux.aarch64 is not pinned"
mkdir -p "$t/p/fakebin"; printf '#!/bin/sh\ncase "$1" in -s) echo Linux ;; -m) echo aarch64 ;; esac\n' > "$t/p/fakebin/uname"; chmod +x "$t/p/fakebin/uname"
(cd "$t/p" && PATH="$t/p/fakebin:/usr/bin:/bin" bash "$wt/.github/shellcheck.sh" unquoted.sh); code=$?
[ $code = 1 ] || die "expected exit 1 on Linux.aarch64, got $code"

echo "--6 cp -p keeps the gate's mode"
rm -rf "$t/p/proj"; mkdir -p "$t/p/proj/.github"; cp -p "$wt/template/.github/shellcheck.sh" "$t/p/proj/.github/shellcheck.sh"
[ -x "$t/p/proj/.github/shellcheck.sh" ] && echo "copied file is executable" || die "mode lost"
echo "all claims held"
```

## Other files written (not shown)

scratchpad/tmp/a
scratchpad/tmp/app/.agents/skills/architect/SKILL.md
scratchpad/tmp/app/.agents/skills/architect/references/design-red-flags.md
scratchpad/tmp/app/.agents/skills/architect/references/rationale-template.md
scratchpad/tmp/app/.agents/skills/architect/references/runner-prompt.md
scratchpad/tmp/app/.agents/skills/arena/SKILL.md
scratchpad/tmp/app/.agents/skills/automate-me/SKILL.md
scratchpad/tmp/app/.agents/skills/babysit/SKILL.md
scratchpad/tmp/app/.agents/skills/blast-radius/SKILL.md
scratchpad/tmp/app/.agents/skills/bro/SKILL.md
scratchpad/tmp/app/.agents/skills/create-verification-skill/SKILL.md
scratchpad/tmp/app/.agents/skills/create-verification-skill/references/feature-map-example/README.md
scratchpad/tmp/app/.agents/skills/create-verification-skill/references/feature-map-example/create-note.md
scratchpad/tmp/app/.agents/skills/create-verification-skill/references/feature-map-example/search.md
scratchpad/tmp/app/.agents/skills/deslop/SKILL.md
scratchpad/tmp/app/.agents/skills/domain-modeling/ADR-FORMAT.md
scratchpad/tmp/app/.agents/skills/domain-modeling/CONTEXT-FORMAT.md
scratchpad/tmp/app/.agents/skills/domain-modeling/SKILL.md
scratchpad/tmp/app/.agents/skills/domain-modeling/agents/openai.yaml
scratchpad/tmp/app/.agents/skills/factory-doctor/SKILL.md
scratchpad/tmp/app/.agents/skills/factory-retro/SKILL.md
scratchpad/tmp/app/.agents/skills/factory-start/SKILL.md
scratchpad/tmp/app/.agents/skills/factory918/SKILL.md
scratchpad/tmp/app/.agents/skills/figure-it-out/SKILL.md
scratchpad/tmp/app/.agents/skills/fix-ci/SKILL.md
scratchpad/tmp/app/.agents/skills/fix-merge-conflicts/SKILL.md
scratchpad/tmp/app/.agents/skills/get-pr-comments/SKILL.md
scratchpad/tmp/app/.agents/skills/grill-me/SKILL.md
scratchpad/tmp/app/.agents/skills/grill-me/agents/openai.yaml
scratchpad/tmp/app/.agents/skills/grill-with-docs/SKILL.md
scratchpad/tmp/app/.agents/skills/grill-with-docs/agents/openai.yaml
scratchpad/tmp/app/.agents/skills/grilling/SKILL.md
scratchpad/tmp/app/.agents/skills/grilling/agents/openai.yaml
scratchpad/tmp/app/.agents/skills/how/SKILL.md
scratchpad/tmp/app/.agents/skills/how/references/critic-prompt.md
scratchpad/tmp/app/.agents/skills/how/references/critique-rubric.md
scratchpad/tmp/app/.agents/skills/how/references/explainer-prompt.md
scratchpad/tmp/app/.agents/skills/how/references/explorer-prompt.md
scratchpad/tmp/app/.agents/skills/interrogate/SKILL.md
scratchpad/tmp/app/.agents/skills/interrogate/references/code-quality-review.md
scratchpad/tmp/app/.agents/skills/interrogate/references/lead-judgment.md
scratchpad/tmp/app/.agents/skills/interrogate/references/reviewer-prompt.md
scratchpad/tmp/app/.agents/skills/interrogate/references/rubric.md
scratchpad/tmp/app/.agents/skills/knowledge/SKILL.md
scratchpad/tmp/app/.agents/skills/maintain-verification-skill/SKILL.md
scratchpad/tmp/app/.agents/skills/make-pr-easy-to-review/SKILL.md
scratchpad/tmp/app/.agents/skills/mode-build/SKILL.md
scratchpad/tmp/app/.agents/skills/mode-plan/SKILL.md
scratchpad/tmp/app/.agents/skills/poteto-mode/SKILL.md
scratchpad/tmp/app/.agents/skills/poteto-mode/playbooks/authoring-a-skill.md
... and 498 more
