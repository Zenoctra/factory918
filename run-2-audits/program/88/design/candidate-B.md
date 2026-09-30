# Candidate B — one gate script, carried by the template, called from four places

Every claim marked **[verified]** was run against the checkout at `ab47eb9` with ShellCheck 0.11.0 (`/opt/homebrew/bin/shellcheck`). Commands and outcomes are pasted in **Evidence**.

## Problem

Ticket #88 asks for one tool in five places at once, and the five places have five different delivery paths: the factory's CI is edited directly, the template's CI travels through `apply`/`update` into a repository that can never see the factory's files, the playbook sentence only survives if it goes through `patches/pstack/poteto-mode/playbooks/opening-a-pr.md.patch`, the doctor line is a function in `factory918.sh`, and the standards rule is prose read only by `spec-review`'s Standards axis. The shape is non-obvious because one decision — *what exactly does ShellCheck get run as* — has to be true in all five, and three of the five cannot read each other.

Four constraints from Phase A bound the design:

- **A project's CI runs alone.** `template/` is copied into a project by `cmd_apply` (`factory918.sh:131-141`) and must not depend on the factory checkout at CI time. So the factory and the template cannot share a file unless that file lives under `template/` and the factory runs the template's copy — which is exactly the nesting rule the repo already lives by (`.claude/hooks -> ../template/.claude/hooks`, P7).
- **The lane's run must equal CI's run**, or the ticket's premise ("catch it before CI kicks us back at a brand new writer") is false. This turns out to be a hard constraint, not a nicety: `shellcheck tests/spec-review/review-comment.sh` on one changed file reports two findings that the whole-set run does not **[verified, E5]**. A lane that types the tool's name by hand gets a different answer than CI.
- **`cmd_sync` wipes anything under `template/.agents/skills` that is not one of the four `keep_files`** (`factory918.sh:381-388`), and CI asserts `sync` leaves the tree clean (`.github/workflows/factory-ci.yml:33`). So the gate's own file must not live under a vendored skill, and a fix to `worktree-audit.sh` or `show-me-your-work/scripts/log.sh` would have to become a patch.
- **`chk` cannot produce a `NOTE`** — it sets `fail=1` on any nonzero (`factory918.sh:238`). The doctor line has to be written inline, like the models-sheet line at `:272`.

## Usage (caller's view)

### What a lane types before the PR opens

In a project, from the repository root:

```
$ bash .github/shellcheck.sh .claude/hooks/delegation.sh
ShellCheck 0.11.0, files checked: 1
```

In the factory, the `AGENTS.md` Verifying bullet, the whole set:

```
$ bash template/.github/shellcheck.sh factory918.sh template/.github/shellcheck.sh 'template/.claude/hooks/*.sh' 'template/.agents/skills/*/scripts/*.sh' 'tests/*/*.sh'
ShellCheck 0.11.0, files checked: 19
```

A finding looks like this, and the exit code is 1 **[verified, E6]**:

```
ShellCheck 0.11.0, files checked: 12

In .claude/hooks/probe.sh line 3:
cat $f
    ^-- SC2086 (info): Double quote to prevent globbing and word splitting.
```

### What CI runs

The factory, `.github/workflows/factory-ci.yml`, replacing the `Shell syntax` step at `:18-19`:

```yaml
      - name: ShellCheck
        run: bash template/.github/shellcheck.sh factory918.sh template/.github/shellcheck.sh 'template/.claude/hooks/*.sh' 'template/.agents/skills/*/scripts/*.sh' 'tests/*/*.sh'
```

A project, `template/.github/workflows/ci.yml`, first step of the `check` job after `actions/checkout@v4` (`:16`), before `Reject committed PR evidence`:

```yaml
      - name: ShellCheck
        run: bash .github/shellcheck.sh
```

The fixture, `.github/workflows/factory-ci.yml`, a new step between `Day 0 on a fresh monorepo` (`:46-51`) and `review-brief.sh briefs the apply diff inside the project` (`:52`):

```yaml
      - name: The project's shell gate
        working-directory: /tmp/fx
        run: bash .github/shellcheck.sh
```

The fixture step and the template step are the same three words, because the project's glob list lives inside the script, not in either workflow. That is the whole reason the no-argument form exists.

### What the doctor prints

With the tool:

```
PASS  shellcheck 0.11.0
```

Without it — a `NOTE`, `fail` untouched, exit still 0 **[verified, E7]**:

```
NOTE  shellcheck
      fix: brew install shellcheck (apt install shellcheck, dnf install ShellCheck, winget install koalaman.shellcheck); .github/shellcheck.sh downloads the pinned build without it, so this is a NOTE
```

## Shape

### The one new file

`template/.github/shellcheck.sh`, mode 755, copied to a project's `.github/shellcheck.sh` by `cmd_apply`'s generic loop (`cp -p` at `factory918.sh:137` preserves the bit). It is not under `template/.agents/skills`, so `cmd_sync` never touches it.

It holds the version, both checksums, the platform selection, the cache location, the flags, and the project's default glob list. Its public surface is one command with zero flags. That is the interface-depth judgment: **what the caller must know shrinks to a list of paths; everything the ticket's points 1, 2 and 4 argue about is hidden behind it.** The alternative shape — a `run:` block in each workflow — would put the version and the two checksums in two files and the invocation flags in three (two workflows plus `AGENTS.md`), which is the *information leakage* red flag by its definition: one decision known in several places.

```bash
#!/usr/bin/env bash
# The shell gate, in this project and in the factory that wrote it. Runs ShellCheck at the pinned
# version over the files the globs name, downloading that version when this machine does not have
# it, so the run a lane makes before a PR and the run CI makes are one run.
#   bash .github/shellcheck.sh                  this project's shell files
#   bash .github/shellcheck.sh '<glob>' ...     exactly these; quote a glob, this script expands it
# Run it from the repository root: --external-sources resolves a sourced file against the working
# directory. The severity is the default, because SC2086, the unquoted expansion, is info level and
# a --severity floor would pass the class this gate exists for. No --shell: each file is read in the
# dialect of its own shebang, so a `#!/bin/sh` file keeps its bashism checks. Globs that match no
# file at all leave the gate checking nothing, which is a failure, not a pass.
set -euo pipefail
version=0.11.0
sha_linux_x86_64=8c3be12b05d5c177a04c29e3c78ce89ac86f1595681cab149b65b97c4e227198
sha_darwin_aarch64=56affdd8de5527894dca6dc3d7e0a99a873b0f004d7aabc30ae407d3f48b0a79

bin=shellcheck
if ! "$bin" --version 2>/dev/null | grep -qx "version: $version"; then
  case "$(uname -s).$(uname -m)" in
    Linux.x86_64)                 plat=linux.x86_64;   sha="$sha_linux_x86_64" ;;
    Darwin.arm64|Darwin.aarch64)  plat=darwin.aarch64; sha="$sha_darwin_aarch64" ;;
    *) echo "shellcheck.sh: ShellCheck $version is not pinned for $(uname -s).$(uname -m); install it by hand" >&2; exit 1 ;;
  esac
  dir="${TMPDIR:-/tmp}/shellcheck-$version"
  bin="$dir/shellcheck-v$version/shellcheck"
  if [ ! -x "$bin" ]; then
    mkdir -p "$dir"
    curl -fsSL -o "$dir/sc.tar.xz" "https://github.com/koalaman/shellcheck/releases/download/v$version/shellcheck-v$version.$plat.tar.xz"
    if command -v sha256sum >/dev/null; then echo "$sha  $dir/sc.tar.xz" | sha256sum -c -
    else echo "$sha  $dir/sc.tar.xz" | shasum -a 256 -c -; fi
    tar -xJf "$dir/sc.tar.xz" -C "$dir"
  fi
fi

if [ "$#" = 0 ]; then set -- '.claude/hooks/*.sh' '.agents/skills/*/scripts/*.sh' '.github/shellcheck.sh'; fi
files=()
for g in "$@"; do
  for f in $g; do if [ -f "$f" ]; then files+=("$f"); fi; done
done
if [ "${#files[@]}" = 0 ]; then
  echo "shellcheck.sh: no file matched $*; the gate checked nothing" >&2
  exit 1
fi
echo "ShellCheck $version, files checked: ${#files[@]}"
exec "$bin" --external-sources "${files[@]}"
```

Signature: `shellcheck.sh [glob...] -> 0 clean | 1 findings, or nothing matched, or no pinned build for this platform`. Idempotent: the second run on a machine finds the cached binary and downloads nothing (`[ ! -x "$bin" ]`), per **make-operations-idempotent**. It writes nothing inside the repository, so no `.gitignore` change. `${#files[@]}` on an empty array is safe under `set -u` on bash 3.2, and the empty array is never expanded because the zero case exits first **[verified, E8]**.

### Point 1 — the pinning mechanism

**Release download with checksum**, not an action. Three reasons, in order of weight:

1. A pinned third-party action in `template/` would hand every project Factory918 applies a supply-chain dependency the project never chose. The factory's own style is to pin by version input on a first-party action (`voidzero-dev/setup-vp@v1` with `version: "0.3.1" # the ADR pin`, `factory-ci.yml:40-42`); there is no first-party ShellCheck action.
2. I cannot resolve a commit SHA for any third-party action from this read-only checkout, and inventing one is worse than not using one.
3. The tarball plus its sha256 is a pin a reader can check by eye against `SOURCES.md`-style prose; an action SHA is not.

The two CIs **share the script, not the text**. The factory runs `template/.github/shellcheck.sh` in place. This is the same nesting the repository already uses for hooks and skills, so it introduces no new idea.

### Point 2 — the exact invocation

`shellcheck --external-sources <file>...`. Four decisions, each argued:

- **Severity: the default.** The ticket's own Problem names "an unquoted command substitution" as one of the three findings that cost a review round. That is SC2086, and SC2086 is **info level**: at `--severity=warning` a file containing `x=$(date); echo $x` exits 0 **[verified, E2]**. A severity floor would let through the exact class this gate exists for. The 6-finding `-S warning` set and the 1-finding `-S error` set are therefore both rejected; the price is resolving all 57 findings at HEAD, which point 3 does.
- **`--external-sources` (`-x`): yes, and it is load-bearing.** `tests/spec-review/layout.sh` is sourced by `review-brief.sh:20` and `review-comment.sh:11`. Without `-x`, those two files report SC1091 plus three SC2154 "referenced but not assigned" warnings **[verified, E5]**. Those findings vanish when `layout.sh` happens to be in the same invocation — so the whole-set run is clean by accident of the glob, while a lane checking one changed file is not. `-x` makes the two agree. Note that `-x` resolution is relative to the working directory, which is why the script's header says to run it from the repository root **[verified, E5b: from `cwd=/` the same file reports SC1091 "does not exist"]**.
- **No `--shell`/`-s`.** `tests/spec-review/fake-gh.sh` is `#!/bin/sh` and is copied onto `PATH` as `gh`. ShellCheck reads each file in the dialect of its own shebang; forcing `-s bash` hides SC3030 and SC3054 (POSIX-undefined arrays) in that file **[verified, E3]**. A bashism there would break the fixture step at `factory-ci.yml:56` in a way the gate is supposed to prevent.
- **`layout.sh` gets a `shell` directive, not a `disable`.** One header line supplies the dialect and the two unused-variable exemptions with one reason **[verified, E4]**:

```bash
# shellcheck shell=bash disable=SC2034 # sourced by the two spec-review tests, so it has no shebang; hooks and skill are read by the sourcing test
```

- **Globs.** Factory: `factory918.sh`, `template/.github/shellcheck.sh`, `'template/.claude/hooks/*.sh'`, `'template/.agents/skills/*/scripts/*.sh'`, `'tests/*/*.sh'` — 19 files, the ticket's 18 plus the gate itself. Written against `template/`, never `.claude/`, because the factory root's `.claude/hooks` and `.claude/skills` are symlinks into `template/` and a `.claude/` glob would lint the same files twice. The skills glob is `*/scripts/*.sh`, which is wider than today's `bash -n` step (`factory-ci.yml:19` names `spec-review` and `poteto-mode` by hand): `show-me-your-work/scripts/log.sh` is newly covered and passes. Project: the script's default, `.claude/hooks/*.sh`, `.agents/skills/*/scripts/*.sh`, `.github/shellcheck.sh` — 11 files in a freshly applied project **[verified, E6]**, again avoiding `.claude/skills`, which is a symlink to `.agents/skills` there.
- **`bash -n` is removed, not kept beside it.** ShellCheck refuses a file it cannot parse — a missing `then` gives SC1050/SC1072/SC1073 at error level and exit 1 **[verified, E9]** — and its glob is a superset of the old step's. Keeping both would be the duplication this design exists to remove, per **subtract-before-you-add**.

### Point 3 — every finding at HEAD, named and resolved

19 files, 57 findings at default severity, **0 after these 11 edits** **[verified, E1 and E10]**. The rule that decides directive-versus-fix: *a directive states a fact about the code that ShellCheck cannot see; a fix is for anything else.* The rule that decides a directive's scope: *the narrowest scope that covers the intent* — above the one statement, or at the top of a file whose whole job produces the pattern. That is already what the repository does (`tests/poteto-mode/overlap.sh:17` file-level, `overlap.sh:49` inline).

**Real fixes (5 sites, 4 files).**

| Finding | Judgment | Edit |
|---|---|---|
| `factory918.sh:384` SC2115 | **Real.** `$skills` is `"$TEMPLATE/.agents/skills"`; `set -u` does not protect a variable that is set but empty, and `rm -rf "/$n"` at the filesystem root is the failure mode. Zero behaviour change when non-empty. | `rm -rf "$skills/$n"` → `rm -rf "${skills:?}/$n"` |
| `factory918.sh:386` SC2115 | Same. | same |
| `factory918.sh:272` SC2015 | **Real, and it matters here.** `echo` returns nonzero on `EPIPE`, which is reachable: `cmd_doctor` output is piped (`factory-ci.yml:51` pipes `apply` to `tail -30`). More decisively, this design adds a *second* NOTE line beside it and must not add a second instance of the pattern. | `[ -f "$HOME/.claude/pstack-models.md" ] && echo "PASS  models sheet" \|\| note ...` → `if [ -f "$HOME/.claude/pstack-models.md" ]; then echo "PASS  models sheet"; else note "models sheet" "factory918 install writes ~/.claude/pstack-models.md"; fi` |
| `tests/spec-review/fake-gh.sh:15` SC2015 | **Real but benign** — a failing `cat` would make the fake report "no pull requests found". An `if` says what was meant and costs one line. | → `  "pr view --json body"*) if [ -f "${FAKE_PR_BODY:-}" ]; then cat "$FAKE_PR_BODY"; else echo 'no pull requests found for branch "x"' >&2; exit 1; fi ;;` |
| `factory918.sh:398` SC2012 | **False positive on the data** (skill directory names are lowercase-hyphen), but the rewrite is strictly smaller — it deletes three processes — so a fix beats a directive. | `echo "vendored: $(ls -d "$skills"/*/ \| wc -l \| tr -d ' ') skills. ..."` → `local -a dirs; dirs=("$skills"/*/)` then `echo "vendored: ${#dirs[@]} skills. Review with git status, bump VERSION, commit."`. Counts identically **[verified, E8]**. |

**Directives (6, covering 52 findings).** Each is `# shellcheck disable=<code> # <reason>`, the reason a second comment on the same line.

| File:line | Codes | Directive text (verbatim) |
|---|---|---|
| `factory918.sh:249` (above the `chk`) | SC2088 ×1 | `  # shellcheck disable=SC2088 # the tilde is inside the fix text printed to a person, never a path this script expands` |
| `template/.claude/hooks/delegation.sh:21` | SC2016 ×1 | `# shellcheck disable=SC2016 # $p is the sed address 7,$p, not a shell expansion` |
| `delegation.sh:164`, `:184` | SC2086 ×2 | `  # shellcheck disable=SC2086 # set -f is on (line 7), so this splits words without globbing, which is the intent` |
| `delegation.sh:206` | SC2086 ×1 | `    # shellcheck disable=SC2086 # set -f is on (line 7), so the tokenised segment splits into words without globbing` |
| `template/.agents/skills/spec-review/scripts/review-brief.sh`, above `set -euo pipefail` | SC2016 ×16, file level | `# shellcheck disable=SC2016 # every single-quoted string here is a jq program or a Markdown template; the backticks and $ are literal` |
| `review-comment.sh:40` | SC2016 ×1 | `# shellcheck disable=SC2016 # the fenced block is Markdown emitted verbatim; the backticks are literal` |
| `tests/spec-review/review-brief.sh`, above `set -euo pipefail` | SC2016 ×25, file level | `# shellcheck disable=SC2016 # the expected strings below are the Markdown the script emits; the backticks and $ are literal` |
| `tests/spec-review/review-comment.sh:94`, `:509` | SC2016 ×2 | `# shellcheck disable=SC2016 # the expected Markdown is literal; the backticks are not command substitution` |
| `tests/spec-review/layout.sh:1` | SC2148 ×1, SC2034 ×2 | `# shellcheck shell=bash disable=SC2034 # sourced by the two spec-review tests, so it has no shebang; hooks and skill are read by the sourcing test` |

**So: 45 SC2016 get two file-level directives and four inline ones, not 45 directives, not an `.shellcheckrc`, not a severity floor.** The two file-level ones are honest because those two files exist to emit Markdown and jq programs; a blanket SC2016 in `review-comment.sh`, where one string in a 500-line file is a template, would not be, so that one is inline. An `.shellcheckrc` is rejected outright for a second reason: a factory-root `.shellcheckrc` would not travel to a project, so the "universally designed" requirement would need two of them — leakage again — and a suppression in a config file is invisible to a lane reading the code.

The two pre-existing directives are rewritten into the same form: `tests/poteto-mode/overlap.sh:17` (today bare, with its reason in the header at `:15-16`) and `template/.agents/skills/poteto-mode/scripts/overlap.sh:49` (today bare, indented). `overlap.sh` is in `keep_files`, so that edit survives `sync`; `tests/` is outside `template/` entirely.

Neither `template/.agents/skills/poteto-mode/scripts/worktree-audit.sh` nor `show-me-your-work/scripts/log.sh` needs an edit — both are clean at default severity — so no new patch and no `keep_files` change is required. That is luck worth naming: had either needed a fix, it would have cost a patch, a `series` line and a `SOURCES.md` entry.

### Point 4 — the fixture proves the project globs

Yes, and with the same three words the template's step uses, because the project's glob list is the script's zero-argument default rather than text in a workflow. The fixture step runs `bash .github/shellcheck.sh` with `working-directory: /tmp/fx`, where `.claude/hooks/` holds five real files and `.agents/skills/*/scripts/` five more (`apply` copies, it does not symlink; only `.claude/skills` is a link). Placed right after the apply step so a template regression fails in seconds, before the 20-minute job spends time on `vp`. A simulated project tree gates 11 files and catches a planted SC2086 **[verified, E6]**.

### Point 5 — the doctor line

Inserted immediately after the models-sheet line (`factory918.sh:272`), where the other machine-level checks sit:

```bash
  local scv; scv="$(shellcheck --version 2>/dev/null | sed -n 's/^version: //p' || true)"
  if [ -n "$scv" ]; then echo "PASS  shellcheck $scv"
  else note "shellcheck" "brew install shellcheck (apt install shellcheck, dnf install ShellCheck, winget install koalaman.shellcheck); .github/shellcheck.sh downloads the pinned build without it, so this is a NOTE"; fi
```

- Label `shellcheck`, lowercase, like `models sheet` and `vp on PATH`.
- Capture-then-branch, the `delete-branch-on-merge` shape at `:260-262`, because `chk` cannot emit a `NOTE` (`:238` sets `fail=1`). `|| true` inside the substitution absorbs the missing command under `pipefail`.
- PASS **carries the version**, because the doctor's job is to tell a person what is true.
- **The version is not compared to the pin.** The gate downloads the pin when the local build differs, so an off-pin local ShellCheck is not a defect — it costs one download on first use. A FAIL or a second NOTE for it would be noise. The fix string's last clause says why the line is a NOTE, which is the counterpart of `CODING_STANDARDS.md:11` ("A `FAIL` with no fix is a bug").
- Four platforms named, matching the `gh` line's style at `:257`.
- Verified in both states, exit 0 either way **[verified, E7]**.

### Point 6 — the prose, exact text

**`opening-a-pr.md`, the `**PRs.**` paragraph (`:9`), second sentence, after "Run `/deslop` over the diff before commit.":**

> Run `bash .github/shellcheck.sh` on every shell file the diff changes before the PR opens; it is the gate CI runs, so the finding lands in this lane instead of a review round.

Delivered by editing `template/.agents/skills/poteto-mode/playbooks/opening-a-pr.md`, then regenerating `patches/pstack/poteto-mode/playbooks/opening-a-pr.md.patch` with the command at `patches/README.md:9`, then confirming `./factory918.sh sync` leaves `git status` clean (`factory-ci.yml:33`). No `series` change: the patch is already line 7.

**`SOURCES.md` item 3 (`:15`), appended to the existing sentence:**

> The `**PRs.**` paragraph also tells the lane to run `bash .github/shellcheck.sh` on every changed shell file before the PR opens.

**Root `CODING_STANDARDS.md`, new bullet at the end of the Bash section (after `:14`):**

> - A `# shellcheck disable=` directive carries its reason as a second comment on the same line: `# shellcheck disable=SC2016 # the backticks are the ticket's token delimiters`. The directive sits on the narrowest scope that covers the intent — above the one statement, or at the top of a file whose whole job produces the pattern.

`CODING_STANDARDS.md:3` says to skip what CI enforces, and CI *does* enforce that the reason is a comment and not bare prose (bare prose is SC1072/SC1073, an error **[verified, E4]**). What CI cannot check is whether a reason exists at all or whether it is true, which is exactly what this bullet gives the Standards axis. The example shows the form so the rule is usable without a second lookup.

**Template `CODING_STANDARDS.md`, `## Suppressions` (`:35-37`), appended to the paragraph:**

> A `# shellcheck disable=` in a hook or a skill script puts its reason in a second comment on the same line, because the directive is itself a comment and an adjacent one would be ambiguous.

Yes, the template gets it: the Decision quote says "universally designed", and every project carries five hooks and five skill scripts that this gate lints.

**Root `AGENTS.md` `## Verifying`, replacing the `bash -n factory918.sh` bullet at `:38`:**

> - `bash template/.github/shellcheck.sh factory918.sh template/.github/shellcheck.sh 'template/.claude/hooks/*.sh' 'template/.agents/skills/*/scripts/*.sh' 'tests/*/*.sh'` — ShellCheck at the pin, 19 files; it replaces `bash -n`, whose set it covers.

**Template `AGENTS.md` `## Verifying`, new bullet after `:62`:**

> - Shell: `bash .github/shellcheck.sh` before a PR, on the files the diff changes; with no arguments it checks the project's hooks and skill scripts, which is what CI runs.

### Point 7 — test first, and the commit order

There is no scenario table, so the "test" is two things, and the commit order shows both before the code they judge.

1. **The CI step that fails at `ab47eb9`.** Commit 1 adds the gate and wires all three CI steps; at that commit the factory job fails with 57 findings **[verified, E1]**. Commit 2 makes it pass. The PR body records both SHAs, which is the evidence that the gate has teeth.
2. **`tests/shellcheck/gate.sh`**, also in commit 1, covering what the CI step cannot: that a planted SC2086 is refused (exit 1), that a glob matching nothing is refused rather than passing silently (exit 1, the fail-open case), that a clean file passes (exit 0), and that a `#!/bin/sh` file keeps its POSIX checks. It lands under `tests/*/*.sh`, so the gate lints its own test.

Commits, in order:

1. `template/.github/shellcheck.sh` + `tests/shellcheck/gate.sh` + the factory step + the template step + the fixture step. **Factory CI red.**
2. The 5 fixes and the 6 directives, plus the two pre-existing directives rewritten. **Factory CI green**; the four behavioural tests still pass — 334 assertions in `review-brief.sh` alone **[verified, E10]**.
3. The doctor line.
4. Prose: the playbook edit, the regenerated patch, `SOURCES.md`, both `CODING_STANDARDS.md`, both `AGENTS.md`, `docs/M0-findings.md`, and the `DECISIONS.md` Provisional row, then `python3 tools/build_knowledge.py`.

A writer that cannot make a cell work stops and says so rather than widening a glob or lowering the severity to get green.

### Point 8 — the ticket's `## Design` section and the findings line

`## Design` on ticket #88 carries the script's usage block and its signature, nothing more:

> `bash .github/shellcheck.sh` — this project's shell files (`.claude/hooks/*.sh`, `.agents/skills/*/scripts/*.sh`, `.github/shellcheck.sh`).
> `bash .github/shellcheck.sh '<glob>' ...` — exactly those; quote a glob, the script expands it.
> Exit 0 clean, 1 on a finding, on globs that matched no file, or on a platform the pin has no build for. Run from the repository root. Holds the version, both checksums and the flags; the factory runs `template/.github/shellcheck.sh` with its own globs.

`docs/M0-findings.md`, a new section before `## Still open` (`:170`):

> ## ShellCheck (2026-09-22)
>
> ShellCheck 0.11.0, Homebrew, macOS arm64, is the pin: `shellcheck-v0.11.0.linux.x86_64.tar.xz` sha256 `8c3be12b05d5c177a04c29e3c78ce89ac86f1595681cab149b65b97c4e227198`, `shellcheck-v0.11.0.darwin.aarch64.tar.xz` sha256 `56affdd8de5527894dca6dc3d7e0a99a873b0f004d7aabc30ae407d3f48b0a79`. At `ab47eb9` the 18 shell files the ticket names produced 57 findings at the default severity and 0 after eleven edits. The severity floor is the default, not `warning`: SC2086, the unquoted expansion the ticket's Problem names, is info level, so `--severity=warning` leaves that class passing (6 findings at `warning`, 1 at `error`). `--external-sources` is required, not optional: without it the two spec-review tests report SC1091 and three SC2154 on the sourced `tests/spec-review/layout.sh`, so a lane checking one changed file would disagree with CI; `-x` resolves the sourced path relative to the working directory, so the gate runs from the repository root. No `--shell`: forcing `-s bash` hides SC3030 and SC3054 in `tests/spec-review/fake-gh.sh`, which is `#!/bin/sh`. A directive's reason must be a second comment on the same line — `# shellcheck disable=SC2016 # reason` parses, `# shellcheck disable=SC2016 reason` is SC1073 plus SC1072, an error — and `# shellcheck shell=bash disable=SC2034 # reason` on one line clears SC2148 on a file with no shebang.

`DECISIONS.md` Provisional, the next free id is P25:

> | P25 | One shell gate, carried by the template | `template/.github/shellcheck.sh` holds the ShellCheck version, both release checksums and the flags; a project gets it as `.github/shellcheck.sh` and the factory runs the template's copy. The severity is the default and `--external-sources` is on, so a lane's per-file run and CI's whole-set run give the same answer. A `disable=` directive carries its reason in a second comment on the same line; CI cannot check that a reason exists, the Standards axis does | A `run:` block in each workflow would put the pin in two files and the flags in three, and a project's CI cannot read the factory's files. SC2086 is info level, so a `--severity` floor would pass the class ticket #88 was written for; without `-x` the two spec-review tests report findings on one file that vanish on the whole set, which would make the playbook's "run it before the PR" sentence false. Ticket #88, 2026-09-22. |

### Files the writer touches

| File | Edit |
|---|---|
| `template/.github/shellcheck.sh` | New, mode 755: the gate — pin, checksums, platform, flags, project default globs. |
| `tests/shellcheck/gate.sh` | New: refuses a planted SC2086, refuses a glob that matched nothing, passes a clean file, keeps POSIX checks on a `#!/bin/sh` file. |
| `.github/workflows/factory-ci.yml` | Replace the `Shell syntax` step (`:18-19`) with the `ShellCheck` step; add `The project's shell gate` to the `fixture` job after `:51`. |
| `template/.github/workflows/ci.yml` | Add the `ShellCheck` step to `check`, after `actions/checkout@v4` (`:16`). |
| `factory918.sh` | Directive above `:249`; `:272` to `if`/`else`; the doctor `shellcheck` line after it; `${skills:?}` at `:384` and `:386`; array count at `:398`. |
| `template/.claude/hooks/delegation.sh` | Four directives: SC2016 above `:21`, SC2086 above `:164`, `:184`, `:206`. |
| `template/.agents/skills/spec-review/scripts/review-brief.sh` | File-level SC2016 directive above `set -euo pipefail`. |
| `template/.agents/skills/spec-review/scripts/review-comment.sh` | SC2016 directive above `:40`. |
| `template/.agents/skills/poteto-mode/scripts/overlap.sh` | `:49` directive gains its reason on the same line. |
| `template/.agents/skills/poteto-mode/playbooks/opening-a-pr.md` | One sentence into the `**PRs.**` paragraph (`:9`). |
| `patches/pstack/poteto-mode/playbooks/opening-a-pr.md.patch` | Regenerated with `patches/README.md:9`. |
| `SOURCES.md` | Item 3 (`:15`) gains one sentence. |
| `tests/spec-review/layout.sh` | Header `shell=bash disable=SC2034` directive at line 1. |
| `tests/spec-review/fake-gh.sh` | `:15` to `if`/`else`. |
| `tests/spec-review/review-brief.sh` | File-level SC2016 directive above `set -euo pipefail`. |
| `tests/spec-review/review-comment.sh` | SC2016 directives above `:94` and `:509`. |
| `tests/poteto-mode/overlap.sh` | `:17` directive gains its reason on the same line. |
| `CODING_STANDARDS.md` | One Bash bullet after `:14`. |
| `template/CODING_STANDARDS.md` | One sentence into `## Suppressions` (`:37`). |
| `AGENTS.md` | `## Verifying` bullet `:38` replaced. |
| `template/AGENTS.md` | `## Verifying` gains a Shell bullet after `:62`. |
| `docs/M0-findings.md` | New `## ShellCheck (2026-09-22)` section before `## Still open` (`:170`). |
| `docs/knowledge/core/DECISIONS.md` | Provisional row P25, then `python3 tools/build_knowledge.py`. |

## Synthesis decision

*Filled in by arena.*

## Tradeoffs accepted

- **We accept a new managed file in every project in exchange for one copy of the pin, the flags and the project glob list.** The alternative keeps the pin in two workflows and the flags in three places, and nothing would notice them drifting.
- **We accept resolving all 57 findings in exchange for a gate that catches SC2086.** A `--severity=warning` floor would have been a two-finding-per-file day and a 6-finding cleanup, and it would have missed the unquoted command substitution that cost PR #87 a review round. Proved, not assumed **[E2]**.
- **We accept two file-level SC2016 directives, hiding that code in two files, in exchange for not writing 41 inline ones.** Both files exist to emit jq programs and Markdown templates; a genuine `'$var'` bug there would be a bug in a literal, which the behavioural tests assert word for word (`review-brief.sh`, 334 assertions).
- **We accept that the gate downloads a tarball on a machine whose ShellCheck is off-pin,** rather than failing or silently using the local build. This is why the doctor line is a NOTE rather than a FAIL, and why the darwin checksum is in the script at all.
- **We accept removing `bash -n` rather than keeping both steps.** ShellCheck refuses an unparseable file at error level **[E9]** and its glob is wider. Keeping a second syntax step would be the duplication the design is removing.
- **We accept that `--external-sources` is cwd-sensitive** and handle it with a header sentence rather than a `cd` inside the script, so a lane can still pass an absolute path to one file.
- **We accept that `template/.agents/skills/wizard/template.sh` stays unlinted.** It is mode 644, not under `scripts/`, and outside the ticket's set; widening the glob to reach it is a second concern.

## Alternatives considered

- **Two `run:` blocks, no script.** Seven lines of YAML in each workflow, each carrying the version, the URL and the checksum. Hides nothing: every caller — both workflows, the `AGENTS.md` bullet, the playbook sentence — has to know the flags, and there are four of them. It is the *information leakage* red flag stated plainly, and it makes the playbook sentence unwritable, because there is no command to name that equals what CI runs. Rejected on interface depth: a zero-line public surface with four copies of the decision is worse than one command with none.
- **A pinned third-party action (`ludeeus/action-shellcheck` or similar) in both workflows.** Exposes less to the factory but exposes a supply-chain dependency to every project the factory applies, which a project never opted into; gives a lane nothing to run locally, so the ticket's "before CI" requirement would still need a second mechanism; and I could not resolve a SHA from this checkout to pin honestly. Rejected.
- **`--severity=warning` plus an `.shellcheckrc`.** The cheapest path to green: six findings, no directives, 45 SC2016 gone for free. Rejected on evidence — SC2086 is info level **[E2]**, so the gate would not have caught the finding the ticket was written about — and on a second ground: an `.shellcheckrc` at the factory root does not travel to a project, so "universally designed" would need two config files and the suppressions would be invisible in the code a lane reads.
- **A `--project` flag instead of the no-argument default.** Same behaviour, one more thing on the public surface. The no-argument form is the common case for the two callers that matter (the template step and the fixture step), so it is the default rather than a flag.
- **The script detecting whether it sits in the factory or a project and choosing globs itself.** One command everywhere, zero glob text in any workflow. Rejected because the factory root's `.claude/hooks` is a symlink into `template/`, so the union of both glob sets double-lints five files and needs a realpath dedup; and because putting the factory's paths inside a file that ships to every project is leakage pointed the other way. The product knows the product's layout; the factory names its own files on its own command line.
- **Linting only the files a diff changed, in CI as well as locally.** Faster, and it is what the playbook sentence asks a lane to do. Rejected for CI: a gate that only sees the diff cannot say the tree is clean at the merge commit, which is what the first acceptance criterion asks for. The script supports both because it takes paths.

## Open questions and risks

- The download path is the one thing this sketch could not execute: a read-only lane may not fetch the tarball, so `curl` → checksum → `tar -xJf` is unproven, and the extracted layout (`shellcheck-v0.11.0/shellcheck`) comes from the ticket's facts rather than from a run. The fixture job proves it on the first CI run, on Linux only. Should commit 1 be pushed early on purpose, so that CI answers this before the rest of the branch is built?
- `tar -xJf` needs xz. It is present on `ubuntu-latest` and in macOS bsdtar, but neither was checked here. Is it worth a one-line `command -v xz` guard with a clear message, or does a `tar` failure read clearly enough on its own?
- `cmd_update` overwrites a project's `ci.yml` only if the project never touched it (`factory918.sh:346-347`); otherwise the new step arrives as a `ci.yml.factory-merge` beside it, and a project that edited its CI silently has no shell gate. Should `cmd_doctor` gain a second line checking that `.github/shellcheck.sh` exists and that `ci.yml` names it, or is that a separate ticket?
- `tests/spec-review/layout.sh` gains a directive line above a header comment that currently opens the file. Is a machine-readable line above the prose acceptable there, or should the header keep line 1 and the directive sit after it? ShellCheck accepts either as long as it precedes the first command.
- The two file-level SC2016 directives make a real `'$var'` typo in those files invisible to the linter. The behavioural tests assert the emitted Markdown word for word, so a typo fails a test instead — is that enough, or does one of the two deserve per-site directives?
- `sed -n 's/^version: //p'` in the doctor line depends on ShellCheck's `--version` format. It holds for 0.11.0 **[E7]**; a future version that reformats the banner turns the PASS into a silent NOTE. Acceptable?

## Next implementation step

Write `tests/shellcheck/gate.sh` — the four cases above, against a not-yet-existing `template/.github/shellcheck.sh` — so the first commit is red for the right reason before the script exists.

---

## Evidence

All commands run in `/Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.claude/worktrees/owner-88` at `ab47eb9`, or in a scratch mirror of its shell files.

**E1 — the 18-file set at HEAD, default severity.**
```
$ shellcheck factory918.sh template/.claude/hooks/*.sh template/.agents/skills/*/scripts/*.sh tests/*/*.sh -f gcc
… 57 lines … ; exit=1
```
The breakdown matches the ticket's facts exactly: SC2016 ×45, SC2086 ×3, SC2115 ×2, SC2034 ×2, SC2015 ×2, SC2148 ×1, SC2088 ×1, SC2012 ×1. `-S warning` → 6 findings, exit 1. `-S error` → 1 finding (SC2148), exit 1.

**E2 — SC2086 is info level, so a `warning` floor passes it.**
```
$ cat unq.sh
#!/usr/bin/env bash
x=$(date)
echo $x
$ shellcheck -f gcc unq.sh
unq.sh:3:6: note: Double quote to prevent globbing and word splitting. [SC2086]
$ shellcheck -S warning -f gcc unq.sh; echo "exit=$?"
exit=0
```

**E3 — `-s bash` hides POSIX checks in a `#!/bin/sh` file.**
```
$ cat sh1.sh
#!/bin/sh
arr=(a b)
echo "${arr[0]}"
$ shellcheck -f gcc sh1.sh
sh1.sh:2:5: warning: In POSIX sh, arrays are undefined. [SC3030]
sh1.sh:3:7: warning: In POSIX sh, array references are undefined. [SC3054]
$ shellcheck -s bash -f gcc sh1.sh; echo "exit=$?"
exit=0
```

**E4 — the same-line reason must be a second comment; `shell=bash` clears SC2148.**
```
$ cat a.sh        # '# shellcheck disable=SC2016 # the backticks are … not command substitution'
$ shellcheck -f gcc a.sh; echo "exit=$?"
exit=0
$ cat b.sh        # '# shellcheck disable=SC2016  # reason: literal backticks'
$ shellcheck -f gcc b.sh; echo "exit=$?"
exit=0
$ cat c.sh        # '# shellcheck disable=SC2016 -- literal backticks'
$ shellcheck -f gcc c.sh
c.sh:2:1: error: Couldn't parse this shellcheck directive. Fix to allow more checks. [SC1073]
c.sh:2:31: error: Expected '=' after directive key. Fix any mentioned problems and try again. [SC1072]
exit=1
$ cat d.sh        # '# shellcheck disable=SC2016 the backticks are literal'
$ shellcheck -f gcc d.sh
d.sh:2:1: error: Couldn't parse this shellcheck directive. … [SC1073]
d.sh:2:32: error: Expected '=' after directive key. … [SC1072]
exit=1
```
With `# shellcheck shell=bash disable=SC2034 # sourced by the two spec-review tests, …` prepended to `layout.sh`, SC2148 and both SC2034 are gone and the multi-key directive with the trailing reason parses.

**E5 — `-x` is load-bearing for a per-file run.**
```
$ shellcheck -f gcc tests/spec-review/review-brief.sh tests/spec-review/review-comment.sh   # post-fix mirror, no -x, layout.sh not an input
tests/spec-review/review-brief.sh:21:3: note: Not following: ./tests/spec-review/layout.sh was not specified as input (see shellcheck -x). [SC1091]
tests/spec-review/review-brief.sh:73:7: warning: skill is referenced but not assigned. [SC2154]
tests/spec-review/review-brief.sh:111:6: warning: source_skill is referenced but not assigned. [SC2154]
tests/spec-review/review-brief.sh:363:18: warning: hooks is referenced but not assigned. [SC2154]
tests/spec-review/review-comment.sh:11:3: note: Not following: … [SC1091]
tests/spec-review/review-comment.sh:72:9: warning: skill is referenced but not assigned. [SC2154]
exit=1
$ shellcheck -x -f gcc tests/spec-review/review-brief.sh tests/spec-review/review-comment.sh; echo "exit=$?"
exit=0
```
**E5b — `-x` resolves relative to the working directory.** The same `-x` run from `cwd=/` with an absolute path reports `SC1091 … ./tests/spec-review/layout.sh: openBinaryFile: does not exist`.

**E6 — the script, all four paths.** Against the fully edited mirror and a simulated applied project:
```
$ bash template/.github/shellcheck.sh factory918.sh template/.github/shellcheck.sh 'template/.claude/hooks/*.sh' 'template/.agents/skills/*/scripts/*.sh' 'tests/*/*.sh'
ShellCheck 0.11.0, files checked: 19
exit=0
$ bash template/.github/shellcheck.sh 'nope/*.sh'
shellcheck.sh: no file matched nope/*.sh; the gate checked nothing
exit=1
$ bash template/.github/shellcheck.sh tests/spec-review/review-comment.sh
ShellCheck 0.11.0, files checked: 1
exit=0
$ cd <simulated project> && bash .github/shellcheck.sh
ShellCheck 0.11.0, files checked: 11
exit=0
$ printf '#!/usr/bin/env bash\nf=$(ls)\ncat $f\n' > .claude/hooks/probe.sh && bash .github/shellcheck.sh
ShellCheck 0.11.0, files checked: 12
… SC2086 … ; exit=1
$ shellcheck -x -f gcc template/.github/shellcheck.sh; echo "exit=$?"   # the gate passes its own gate
exit=0
```

**E7 — the doctor line, both states.**
```
$ bash doc.sh                                        # shellcheck on PATH
PASS  shellcheck 0.11.0
exit=0
$ PATH="/tmp/emptybin:/usr/bin:/bin" bash doc.sh     # shellcheck absent
NOTE  shellcheck
      fix: brew install shellcheck (apt install shellcheck, dnf install ShellCheck, winget install koalaman.shellcheck); .github/shellcheck.sh downloads the pinned build without it, so this is a NOTE
exit=0
$ shellcheck -f gcc doc.sh; echo "exit=$?"
exit=0
```

**E8 — the array rewrite and bash 3.2.**
```
$ bash -c 'f(){ local -a dirs; dirs=(/etc/*/); echo "${#dirs[@]}"; }; f'   → 19
$ ls -d /etc/*/ | wc -l | tr -d ' '                                        → 19
$ /bin/bash --version | head -1                        GNU bash, version 3.2.57(1)-release
$ /bin/bash -c 'set -euo pipefail; files=(); echo "count=${#files[@]}"'    → count=0
$ /bin/bash template/.github/shellcheck.sh tests/spec-review/layout.sh     → ShellCheck 0.11.0, files checked: 1 ; exit=0
```

**E9 — ShellCheck refuses what `bash -n` refuses.**
```
$ printf '#!/usr/bin/env bash\nif [ 1 = 1 ]\necho hi\n' > bad.sh
$ bash -n bad.sh; echo "exit=$?"          → syntax error: unexpected end of file ; exit=2
$ shellcheck -f gcc bad.sh; echo "exit=$?"
bad.sh:2:1: error: Couldn't parse this if expression. Fix to allow more checks. [SC1073]
bad.sh:4:1: error: Expected 'then'. [SC1050]
bad.sh:4:1: error: Expected 'then'. Fix any mentioned problems and try again. [SC1072]
exit=1
```

**E10 — the whole end state, in a mirror with all 11 edits applied.**
```
$ shellcheck -x -f gcc factory918.sh template/.claude/hooks/*.sh template/.agents/skills/*/scripts/*.sh tests/*/*.sh; echo "exit=$?"
exit=0
$ shellcheck -f gcc <same, without -x>; echo "exit=$?"
exit=0
$ for f in <all 19>; do bash -n "$f"; done            → no output
$ sh -n tests/spec-review/fake-gh.sh                  → no output
$ bash tests/hooks/delegation.sh                      → PASS
$ bash tests/spec-review/review-comment.sh            → PASS
$ bash tests/spec-review/review-brief.sh              → ok 334 assertions
$ bash tests/poteto-mode/overlap.sh                   → PASS
```
57 findings at HEAD, 0 after the edits, and the four behavioural tests still pass.
