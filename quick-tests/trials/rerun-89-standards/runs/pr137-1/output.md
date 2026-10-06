## Final message

/private/tmp/wsbox/w-20261005-191215-9ba4/factory918/.scratch/review/ab47eb9/standards-report.md

## File written: factory918/.scratch/review/ab47eb9/standards-report.md

```
# Standards review

For a person: the change reads clean against the bash/Python standards (nothing but one `CORE_DOCS` tuple), the build and the patch series verify, and the prose is good. The three hard findings are all the same shape: the new rule says a stateful design must produce and post a scenario table, but no step on the documented path makes that happen or notices when it does not.

Verified before reporting: `python3 tools/build_knowledge.py` leaves `git status` clean and `python3 tools/check_knowledge.py` passes (119 files); `bash -n factory918.sh` passes; `./factory918.sh sync` applies all 20 patches, including the two new ones, and leaves `git status` clean (run in a scratch copy, because `mktemp -d` is blocked in this sandbox). `tests/hooks/delegation.sh`, `tests/spec-review/*.sh` and `tests/poteto-mode/overlap.sh` could not run for the same `mktemp -d` restriction; the diff touches none of their subjects. The diff is not cross-cutting under `review-brief.sh`'s predicate (no `.claude/hooks/`, no `.claude/settings.json`, no `.agents/skills/factory918/`), so no blast-radius grounding is owed.

## Would break

1. **The posting step rewrites the ticket body instead of appending to it.** `gh issue edit N --body-file FILE` replaces the issue body with the file's contents; it has no append mode. The step says "appended" and names the destructive flag, and never says to read the current body first (`gh issue view N --json body -q .body`) and write body-plus-section. Every other `gh issue` operation the repo documents is additive (`--add-label`, `--add-assignee`, `gh issue comment`), so there is no house pattern to fall back on; `template/docs/agents/issue-tracker.md:7-12` lists no body-rewrite operation at all. The standard breached is `CODING_STANDARDS.md:22` ("Written with `/writing-for-agents` when an agent reads it"): `template/.agents/skills/writing-for-agents/SKILL.md:47-52` requires a step whose completion is checkable, and this one is followed to completion by a command that silently drops the rest of the body.

   ```
   before implementation the synthesized table is appended to the ticket's body under `## Testing decisions` with `gh issue edit N --body-file`, first line `Posted by the agent <date>`
   ```

   Documented step: `template/.agents/skills/poteto-mode/playbooks/ticket.md:10` (Ticket playbook, step 6).
   Result: an agent that writes the new section to the body file and runs the documented command replaces `## What to build`, `## Acceptance criteria`, `## Parent` and `## Blocked by` with the table alone. Nothing errors. `review-brief.sh:222` then pastes that truncated body as the Spec brief's spec, so the Spec axis reviews the work against the table with the ask deleted, and the shape `template/docs/agents/issue-tracker.md:18` calls canonical ("Every ticket has this shape, in this order") is gone from the record the human reads.

2. **Nothing on the documented path triggers the table for a stateful design that does not cross a function boundary.** Ticket step 6 delegates the trigger to "the selected playbook's architect step", but three of the four playbooks gate that step on a function boundary and the fourth gates the no-skip clause on a cross-cutting diff. State is never a trigger anywhere. The new mandatory case therefore has no entry point: a change to a state file's format, an exit-code change, or a new round counter inside one function runs no `architect`, produces no table, and the delegation step's "When it is a scenario table" simply does not fire. The cross-cutting case shows the shape the fix takes, one clause on the same sentence.

   ```
   3. Plan the fix. If it crosses a function boundary, `architect` first; a cross-cutting diff (Ticket step 5) never skips it.
   ```

   ```
   2. `architect` for parallel design exploration. Skipping stays as `architect skipped: <reason>`, not accepted for a cross-cutting diff (Ticket step 5); do not fold the design decision silently into implementation.
   ```

   Documented step: `template/.agents/skills/poteto-mode/playbooks/ticket.md:10` ("The selected playbook's architect step adds the ticket's own: when the design adds state ... `architect`'s first deliverable is the scenario table"), against `bug-fix.md:9`, `perf-issue.md:16`, `refactoring.md:9` ("If it crosses a function boundary, `architect` first") and `feature.md:6`.
   Result: the rule that `docs/knowledge/core/DECISIONS.md` P25 and `SCENARIO-TABLE.md:11` state unconditionally ("before any code that has state") is unreachable for exactly the stateful-but-local change, and the work proceeds to the writer with no table and no message. That is the PR #87 failure the change exists to prevent.

## Fails open

3. **A candidate package that comes back with no scenario table is accepted silently, and the orchestrator has no named section to post.** The patch puts the state branch only in the runner prompt. `architect/SKILL.md:32` (Phase B) and `:84` (Outputs) still say the package is "the caller's usage written first, then the type sketch", and `references/rationale-template.md:9` still says "Write this first, before the type sketch" under `## Usage (caller's view)`. The template the same sentence points to has no heading for a table. No step in Phase B, C or D checks that the first deliverable the runner prompt asks for exists, and the posting instruction says "the synthesized first deliverable" without naming the section that holds it.

   ```
   Then the type sketch, function signatures, module map, and prose rationale shaped per [`rationale-template.md`](rationale-template.md). The orchestrator appends the synthesized first deliverable to the ticket before implementation, a table under `## Testing decisions`, a sketch under `## Design` (the Ticket playbook, step 6); the writer, the reviewer and the human read it there.
   ```

   Documented step: `template/.agents/skills/architect/references/runner-prompt.md:5-10`, read against `template/.agents/skills/architect/SKILL.md:32` and `template/.agents/skills/architect/references/rationale-template.md:9`.
   Result: a runner told to "Read the **architect** skill in full first" gets usage-first from the skill and table-first from the prompt, and a package with no table satisfies every shape document it was given. The orchestrator then has nothing to extract, posts nothing under `## Testing decisions`, and the writer's "When it is a scenario table" branch stays dark. The absence is never refused and never reported.

## Standards breaches

4. **The writer rule is pasted verbatim into four playbooks, and the trigger list it travels with has already drifted.** `CODING_STANDARDS.md:22` sends agent-facing markdown through `/writing-for-agents`, whose pruning rule is "Keep each meaning in a **single source of truth**: one authoritative place, so changing the behaviour is a one-place edit" (`template/.agents/skills/writing-for-agents/SKILL.md:78`). The same 46-word rule now lives in `feature.md:12`, `bug-fix.md:9`, `refactoring.md:9` and `perf-issue.md:16`, each sentence already carrying its own pointer ("Ticket step 6") that would do the job alone. The cost is not hypothetical: the state trigger is "a file it reads or writes, exit codes, rounds, or more than one actor" in `ticket.md:10`, the runner prompt and P25, but "a file read or written, exit codes, more than one actor" in the `to-spec` patch and "a file, exit codes, more than one actor" in the `CORE_DOCS` tuple that generates `INDEX.md`. Rounds are state in four copies and not state in two.

   ```
   The brief carries the ticket's design artifact (Ticket step 6). When it is a scenario table, the writer writes the test from the table before the implementation, one assertion per cell in the table's order, and the commit order shows it; a writer that cannot implement a cell as written stops and reports the cell, and never fills it in.
   ```

5. **The runner prompt carries a sentence addressed to the orchestrator.** The file's own header says it "is passed through to every parallel candidate runner during Phase B", so a line about what the orchestrator does afterwards is exposition in the runner's context, which `template/.agents/skills/writing-for-agents/SKILL.md:80` prunes ("does it still bear on what the document does? A line loses relevance by never bearing on the task"). It also reads as an instruction a runner could act on, and N runners each editing one ticket body with the body-replacing command of finding 1 is a race with a destructive loser. The orchestrator-side home is `architect/SKILL.md` Phase C/D, which the patch leaves untouched.

   ```
   The orchestrator appends the synthesized first deliverable to the ticket before implementation, a table under `## Testing decisions`, a sketch under `## Design` (the Ticket playbook, step 6); the writer, the reviewer and the human read it there.
   ```

6. **Half the new core document is a factory-internal example that every project receives.** Lines 49 to 78 of `docs/knowledge/core/SCENARIO-TABLE.md` are the #42 legend, the fourteen-row `overlap.sh` table and two paragraphs of its contract, verbatim; `build_core` copies the page to `template/docs/factory918/SCENARIO-TABLE.md`, where that is 45 of 79 lines about `.claude/state/program`, `closingIssuesReferences` and `tests/poteto-mode/overlap.sh`, none of which a project has. `CODING_STANDARDS.md:22` asks for one Diátaxis mode per file, and the page runs explanation ("What it is", "Why") over reference ("The shape", "Where it goes") over a worked example; `writing-for-agents SKILL.md:79` treats a restatement of material the agent can look up as a cache that earns its load only when the lookup is expensive, and the durable copy is named in the page itself (ticket #42 and PR #92). Two or three rows and the legend carry the lesson; the rest is sediment the next `overlap.sh` change has to chase.

   ```
   The durable copy is the `## Testing decisions` section of ticket #42 and the description of PR #92. The legend and the table, verbatim:
   ```

## Fix alongside

7. **Shotgun Surgery.** One rule landed in ten prose homes: `ticket.md`, four playbooks, the runner prompt, `to-spec`, `issue-tracker.md`, `GLOSSARY.md`, `DECISIONS.md` P25 and the new page. The playbooks are separately patched vendored files with no include mechanism, so some spread is forced, but the rule's definition belongs in one of them (the new page) with pointers elsewhere, which would also close finding 4.

   ```
   patches/pstack/poteto-mode/playbooks/{bug-fix,feature,perf-issue,refactoring}.md.patch
   ```

8. **Sprawl in `feature.md` step 4.** The step was already one long paragraph; it is now about 190 words carrying four unrelated rules (data shape, the design artifact, the arena branch, the no-skip clause). `writing-for-agents SKILL.md:43` names sprawl as the failure mode and the ladder as the cure. Worth a split only if a would-break fix lands in that step anyway.

   ```
   ... and success criteria); review its diff yourself. The brief carries the ticket's design artifact (Ticket step 6). When it is a scenario table, ... When the implementation admits multiple valid shapes (error handling, abstraction layer, test structure), delegate via the **arena** skill instead ...
   ```

9. **Two tables can claim `## Testing decisions` with no tie-break.** The `to-spec` patch makes the table the shape for the spec's Testing Decisions, and Ticket step 6 posts "the ticket's own" under a heading of the same name on the ticket. `review-brief.sh` pastes only the ticket body, so the review reads one of them; which one governs when the architect's table disagrees with the spec's is unstated.

   ```
   - For stateful work (a file read or written, exit codes, more than one actor), the shape is the scenario table: situations down the side, the shape of the input across the top, and in every cell what is printed, the exit code and what the caller does next.
   ```

hard findings: 3
```

## File written: scratchpad/syncchk/repo/.scratch/review/ab47eb9/standards-brief.md

```
# Standards review brief

You may open any file in the repository and run read-only commands, such as grep or the test suite.

## Commits

c83f166 Record the design-artifact decision, a ledger line and a finding
1662392 Add the scenario table as a sixth core document
0cf6b34 Name the scenario table in to-spec's Testing Decisions
02af48c Tell the writer to work from the scenario table
5c0f2bf Post the design artifact on the ticket before implementation
3b48036 Make the scenario table the runner prompt's first deliverable

## Changed files

 AGENTS.md                                          |  2 +-
 SOURCES.md                                         |  4 +-
 docs/M0-findings.md                                |  2 +
 docs/agents/issue-tracker.md                       |  2 +
 docs/agents/ledger.md                              |  1 +
 docs/knowledge/INDEX.md                            |  7 +-
 docs/knowledge/core/DECISIONS.md                   |  3 +-
 docs/knowledge/core/GLOSSARY.md                    |  4 +-
 docs/knowledge/core/SCENARIO-TABLE.md              | 88 ++++++++++++++++++++++
 patches/mattpocock/to-spec/SKILL.md.patch          | 10 +++
 .../architect/references/runner-prompt.md.patch    | 17 +++++
 .../pstack/poteto-mode/playbooks/bug-fix.md.patch  |  2 +-
 .../pstack/poteto-mode/playbooks/feature.md.patch  |  9 ++-
 .../poteto-mode/playbooks/perf-issue.md.patch      |  2 +-
 .../poteto-mode/playbooks/refactoring.md.patch     |  7 +-
 patches/series                                     |  2 +
 .../skills/architect/references/runner-prompt.md   |  7 +-
 template/.agents/skills/knowledge/SKILL.md         |  2 +-
 .../skills/poteto-mode/playbooks/bug-fix.md        |  2 +-
 .../skills/poteto-mode/playbooks/feature.md        |  2 +-
 .../skills/poteto-mode/playbooks/perf-issue.md     |  2 +-
 .../skills/poteto-mode/playbooks/refactoring.md    |  2 +-
 .../.agents/skills/poteto-mode/playbooks/ticket.md |  2 +-
 template/.agents/skills/to-spec/SKILL.md           |  1 +
 template/docs/agents/issue-tracker.md              |  2 +
 template/docs/factory918/DECISIONS.md              |  1 +
 template/docs/factory918/GLOSSARY.md               |  2 +
 template/docs/factory918/SCENARIO-TABLE.md         | 79 +++++++++++++++++++
 tools/build_knowledge.py                           |  1 +
 29 files changed, 248 insertions(+), 19 deletions(-)

## Diff

The diff is 572 lines; read it from `.scratch/review/ab47eb9/diff`.

## Standards

### CODING_STANDARDS.md

# Coding standards for the factory itself

Read at review time by `spec-review`'s Standards axis. Skip anything the CI gate (`.github/workflows/factory-ci.yml`) already enforces. The template's `CODING_STANDARDS.md` is for projects; this one is for the bash, Python and markdown this repository is made of.

## Bash (`factory918.sh`, the hooks)

- `set -euo pipefail` at the top; one function per subcommand; the dispatch `case` at the bottom.
- Quote every path. Paths here contain spaces.
- Prefer commands that behave the same on macOS and Linux. Where BSD and GNU differ (`sed -i`, `date -d`, `readlink -f`), either use a form both accept or branch on `command -v`.
- Structured edits to JSON or YAML go through `jq` or a short `python3` heredoc, never `sed`.
- Every doctor check carries its fix as the third argument. A `FAIL` with no fix is a bug.
- A failure a gate depends on is printed before anything continues. `|| true` may stop a failure from aborting the command (the doctor's report at the end of `apply` is one), never hide it.
- Test a command the way a user types it: absolute paths, from another directory, through the installed symlink.
- A `PreToolUse` hook that must let the call through on its own failure runs without `-e`, says so in its header, and exits 2 only on a decided block. `delegation.sh` and `format-on-write.sh` are the two that do.

## Python (`tools/`, heredocs in the CLI)

- Standard library only. One script per job; each exits 1 on any miss and says what missed.

## Markdown (docs, skills, both `AGENTS.md`)

- Written with `/writing-for-agents` when an agent reads it, `/technical-writing` and `/unslop` when a person does. One Diátaxis mode per file, except the vendored copies under `docs/agents/`, which are edited in the template or not at all.
- `docs/knowledge/core/` is the source; everything under `docs/knowledge/spec/`, `pages/`, `notes/` and `template/docs/factory918/` is generated and never edited.
- A count or a version in prose is true at the commit that lands it, with the command that regenerates it nearby.

## Commits and pull requests

The rules are in `AGENTS.md`, "Pull requests"; they are not repeated here. Records: a verified tool fact goes to `docs/M0-findings.md` with its date, a surprise to `docs/agents/ledger.md`, a choice to `docs/knowledge/core/DECISIONS.md` under Provisional.

## Smell baseline

Each smell reads *what it is* -> *how to fix*; match it against the diff. A documented repo standard overrides the baseline; every smell is a judgement call, never a hard violation.

- **Mysterious Name**: a function, variable, or type whose name doesn't reveal what it does or holds. → rename it; if no honest name comes, the design's murky.
- **Duplicated Code**: the same logic shape appears in more than one hunk or file in the change. → extract the shared shape, call it from both.
- **Feature Envy**: a method that reaches into another object's data more than its own. → move the method onto the data it envies.
- **Data Clumps**: the same few fields or params keep travelling together (a type wanting to be born). → bundle them into one type, pass that.
- **Primitive Obsession**: a primitive or string standing in for a domain concept that deserves its own type. → give the concept its own small type.
- **Repeated Switches**: the same `switch`/`if`-cascade on the same type recurs across the change. → replace with polymorphism, or one map both sites share.
- **Shotgun Surgery**: one logical change forces scattered edits across many files in the diff. → gather what changes together into one module.
- **Divergent Change**: one file or module is edited for several unrelated reasons. → split so each module changes for one reason.
- **Speculative Generality**: abstraction, parameters, or hooks added for needs the spec doesn't have. → delete it; inline back until a real need shows.
- **Message Chains**: long `a.b().c().d()` navigation the caller shouldn't depend on. → hide the walk behind one method on the first object.
- **Middle Man**: a class or function that mostly just delegates onward. → cut it, call the real target direct.
- **Refused Bequest**: a subclass or implementer that ignores or overrides most of what it inherits. → drop the inheritance, use composition.

## Report

A hard finding is one of two things: the documented path gives a wrong or silent result, or an input outside it proceeds silently (fails open). An input outside the documented path that is refused with a message saying how to correct it is not a finding; it is the design.

- Manuel: "there are an infinite amount of unhappy paths and only 1 happy one"
- Manuel: "AT MOST hardening to fail fast and loud if we move outside of that"
- Manuel: "we notice the variable is unexpected and flag that without having to diagnose every reason the variable might be wrong for the user"
- Manuel: "An edge case outside the intended path being unsupported is not a flag."
- Manuel: "Primary focus must be the happy path, then unhappy paths that error in a way the user can correct."

An edge case that proceeds silently fails open: file it under `## Fails open`.

Write the report as Markdown with exactly these `## ` headings, in this order, each holding numbered items or nothing:

- `## Would break`: a breach of a documented standard that makes the documented path give a wrong or silent result. Cite the standard (file + the rule) and quote the hunk.
- `## Fails open`: a breach of a documented standard that lets an input outside the documented path proceed silently. Cite the standard (file + the rule) and quote the hunk.
- `## Standards breaches`: documented-standard breaches that do not change behavior. Cite the standard and quote the hunk.
- `## Fix alongside`: baseline smells and other judgement calls. Name the smell and quote the hunk. They are fixed only when a would-break fix already touches that code; they never count.

Each item opens with a line of the form `1. **Title.** body`, with the quoted hunk in a fenced block under it; number the items continuously across the headings, so the judgment can name your third item as [S3]. A documented repo standard overrides the baseline. Skip anything tooling enforces.

Every item under `## Would break` or `## Fails open` carries a line `Documented step:` quoting the ticket line or the `file:line` of the documentation the user follows, and a line `Result:` saying what happens instead; an item without its `Documented step:` line is sent back.

Write your report to `.scratch/review/ab47eb9/standards-report.md` and reply with only that path.
End the report with exactly one line `hard findings: N`, where N is the number of items under `## Would break` and `## Fails open` and nothing else.
```

## File written: scratchpad/syncchk/repo/factory918.sh

```
#!/usr/bin/env bash
# The Factory918 CLI. Subcommands: install | models [preset] | init | apply [--profile name] [--name n] | doctor | update | sync | sync-repos | labels | knowledge
# Implemented per docs/FACTORY-SPEC-v2.md §8; verified against the tool versions in docs/M0-findings.md.
set -euo pipefail
# Resolve the script's real location: ~/.local/bin/factory918 is a symlink into the clone.
self="${BASH_SOURCE[0]}"
while [ -L "$self" ]; do target="$(readlink "$self")"; case "$target" in /*) self="$target" ;; *) self="$(dirname "$self")/$target" ;; esac; done
F918_DIR="$(cd "$(dirname "$self")" && pwd -P)"
TEMPLATE="$F918_DIR/template"
VERSION="$(cat "$F918_DIR/VERSION" 2>/dev/null || echo 0.1.0)"

usage() { sed -n '2,3p' "$0"; exit 1; }
need() { command -v "$1" >/dev/null || { echo "missing: $1" >&2; exit 1; }; }

sha() { if command -v sha256sum >/dev/null; then sha256sum "$1"; else shasum -a 256 "$1"; fi | cut -d' ' -f1; }

approve_ast_grep() {
  [ -f "$1" ] || return 0
  python3 - "$1" <<'EOF'
import re, sys, pathlib
p = pathlib.Path(sys.argv[1]); t = p.read_text()
if re.search(r'^\s+"?@ast-grep/cli"?:\s*true\s*$', t, re.M):
    sys.exit(0)
line = '  "@ast-grep/cli": true'
if "allowBuilds:" in t:
    t = re.sub(r'^\s+"?@ast-grep/cli"?:.*$', line, t, count=1, flags=re.M)
    if line not in t:
        t = t.replace("allowBuilds:", "allowBuilds:\n" + line, 1)
else:
    t = t.rstrip("\n") + "\nallowBuilds:\n" + line + "\n"
p.write_text(t)
EOF
}

FACTORY_OWNED="AGENTS.md CLAUDE.md vite.config.ts .vite-hooks/pre-commit"

# Python package at python/<name>: pyproject, a package, a smoke test, the CI job, a lockfile,
# and *.py in the commit hook. A profile is additive like apply: nothing that exists is replaced.
apply_python() {
  local dir="$1" name="$2" pkg="$1/python/$2" P="$F918_DIR/profiles/python"
  need uv
  mkdir -p "$pkg/src/$name" "$pkg/tests" "$dir/.github/workflows"
  [ -s "$pkg/pyproject.toml" ] || sed "s/<name>/$name/g" "$P/pyproject.toml" > "$pkg/pyproject.toml"
  [ -s "$pkg/src/$name/__init__.py" ] || printf '"""%s."""\n' "$name" > "$pkg/src/$name/__init__.py"
  [ -s "$pkg/tests/test_smoke.py" ] || printf 'import %s\n\n\ndef test_imports() -> None:\n    assert %s.__doc__\n' "$name" "$name" > "$pkg/tests/test_smoke.py"
  [ -s "$dir/.github/workflows/python.yml" ] || sed "s/<name>/$name/g" "$P/python.yml" > "$dir/.github/workflows/python.yml"
  [ -s "$pkg/uv.lock" ] || (cd "$pkg" && uv lock -q)
  # Same thin hook for Python: the formatter only, on commit.
  if [ -f "$dir/vite.config.ts" ] && ! grep -q '"\*\.py"' "$dir/vite.config.ts"; then
    python3 - "$dir/vite.config.ts" "$name" <<'EOF'
import pathlib, re, sys
p = pathlib.Path(sys.argv[1]); t = p.read_text()
task = f'"*.py": "uv run --project python/{sys.argv[2]} ruff format",'
t = re.sub(r'(\n(\s*)"\*": "vp fmt[^\n]*\n)', lambda m: m.group(1) + m.group(2) + task + "\n", t, count=1)
p.write_text(t)
EOF
  fi
}

# Expo app files and the native-fingerprint signal. The app itself is one command the
# human or the agent runs, printed at the end, because it downloads an Expo SDK.
apply_react_native() {
  local dir="$1" P="$F918_DIR/profiles/react-native"
  mkdir -p "$dir/apps/mobile" "$dir/.github/workflows"
  [ -s "$dir/apps/mobile/eas.json" ] || cp "$P/eas.json.example" "$dir/apps/mobile/eas.json"
  [ -s "$dir/.github/workflows/mobile-fingerprint-check.yml" ] || cp "$P/mobile-fingerprint-check.yml" "$dir/.github/workflows/mobile-fingerprint-check.yml"
  [ -s "$dir/apps/mobile/package.json" ] || echo "Next: (cd $dir && npx create-expo-app@latest apps/mobile --template blank-typescript), then vp install."
}

# Per machine, once: ~/.factory918 points at this clone (the knowledge skill's fallback and
# $FACTORY918_HOME's default), and ~/.local/bin/factory918 puts the CLI on PATH.
cmd_install() {
  local home="$HOME/.factory918" bin="$HOME/.local/bin"
  for tool in git jq python3; do command -v "$tool" >/dev/null || echo "missing: $tool (install it with your package manager; the CLI needs git, jq and python3)"; done
  if [ -e "$home" ] && [ "$(cd "$home" && pwd -P)" != "$(cd "$F918_DIR" && pwd -P)" ]; then
    echo "$home already points elsewhere: $(readlink "$home" || echo "$home"). Move it aside or set FACTORY918_HOME." >&2; exit 1
  fi
  [ -e "$home" ] || ln -s "$F918_DIR" "$home"
  mkdir -p "$bin"; ln -sf "$F918_DIR/factory918.sh" "$bin/factory918"
  echo "installed: $home -> $F918_DIR"
  echo "installed: $bin/factory918"
  case ":$PATH:" in *":$bin:"*) ;; *) echo "add to your shell rc: export PATH=\"\$HOME/.local/bin:\$PATH\"" ;; esac
  # The one user-level write the factory makes (spec §5.5): pstack's role sheet, from machine/.
  if [ ! -f "$HOME/.claude/pstack-models.md" ]; then
    mkdir -p "$HOME/.claude"; cp "$F918_DIR/machine/pstack-models.fable.md" "$HOME/.claude/pstack-models.md"; echo "installed: ~/.claude/pstack-models.md (fable preset)"
  fi
  grep -qx '@~/.claude/pstack-models.md' "$HOME/.claude/CLAUDE.md" 2>/dev/null || { printf '@~/.claude/pstack-models.md\n' >> "$HOME/.claude/CLAUDE.md"; echo "installed: include line in ~/.claude/CLAUDE.md"; }
  command -v vp >/dev/null || echo "next: install Vite+ with  curl -fsSL https://vite.plus -o /tmp/vp.sh && VP_VERSION=0.3.1 VP_NODE_MANAGER=yes bash /tmp/vp.sh"
  command -v gh >/dev/null && gh auth status >/dev/null 2>&1 || echo "next: gh auth login"
}

# Which preset of pstack's role sheet is active on this machine. pstack never falls back on its
# own: when a lane drops out on quota, the human switches. No argument prints the active preset.
presets() { local p; for p in "$F918_DIR"/machine/pstack-models.*.md; do p="${p##*/pstack-models.}"; echo "${p%.md}"; done; }

cmd_models() {
  local sheet="$HOME/.claude/pstack-models.md" preset="${1:-}" n
  if [ -z "$preset" ]; then
    [ -f "$sheet" ] || { echo "no sheet at $sheet yet: factory918 install writes the fable preset"; return 0; }
    for n in $(presets); do cmp -s "$F918_DIR/machine/pstack-models.$n.md" "$sheet" && { echo "active: $n"; return 0; }; done
    echo "active: a sheet edited by hand (matches no preset in machine/)"; return 0
  fi
  [ -f "$F918_DIR/machine/pstack-models.$preset.md" ] || { echo "no preset named $preset; have: $(presets | tr '\n' ' ')" >&2; exit 1; }
  mkdir -p "$HOME/.claude"; cp "$F918_DIR/machine/pstack-models.$preset.md" "$sheet"; echo "active: $preset -> $sheet"
}

cmd_apply() {
  local dir="${1:-.}"; need jq; need python3
  shift || true
  local profile="" scaffold="" name=""
  while [ $# -gt 0 ]; do case "$1" in
    --profile) profile="$2"; shift 2 ;;
    --name) name="$2"; shift 2 ;;
    --scaffold) scaffold=1; shift ;;
    *) shift ;;
  esac; done
  mkdir -p "$dir/.factory918"
  local manifest="$dir/.factory918/manifest.json"
  [ -f "$manifest" ] || echo '{"version":"'"$VERSION"'","files":{},"profiles":[]}' > "$manifest"
  printf '{"factory":"%s"}\n' "$(cd "$F918_DIR" && pwd -P)" > "$dir/.factory918/local.json"   # git-ignored; the clone that applied
  tmp="$(mktemp)"; jq 'del(.factory)' "$manifest" > "$tmp" && mv "$tmp" "$manifest"           # older manifests carried the path
  if [ -n "$profile" ]; then
    case "$profile" in
      python) apply_python "$dir" "${name:-$(basename "$(cd "$dir" && pwd)")}" ;;
      react-native) apply_react_native "$dir" ;;
      *) echo "unknown profile: $profile (python | react-native)" >&2; exit 1 ;;
    esac
    tmp="$(mktemp)"; jq --arg p "$profile" '.profiles = ((.profiles // []) + [$p] | unique)' "$manifest" > "$tmp" && mv "$tmp" "$manifest"
  fi
  # Copy every managed file that does not exist locally; record its hash. Never overwrite an existing file here.
  (cd "$TEMPLATE" && find . -type f ! -name '.gitkeep' -print0) | while IFS= read -r -d '' rel; do
    rel="${rel#./}"
    case "$rel" in package.scripts.json|.gitignore.factory) continue ;; esac
    owned=""
    [ -n "$scaffold" ] && case " $FACTORY_OWNED " in *" $rel "*) owned=1 ;; esac
    if [ ! -e "$dir/$rel" ] || [ -n "$owned" ]; then
      mkdir -p "$dir/$(dirname "$rel")"; cp -p "$TEMPLATE/$rel" "$dir/$rel"
    fi
    h="$(sha "$TEMPLATE/$rel")"
    tmp="$(mktemp)"; jq --arg k "$rel" --arg v "$h" '.files[$k]={"template":$v}' "$manifest" > "$tmp" && mv "$tmp" "$manifest"
  done
  # Symlink .claude/skills -> ../.agents/skills (T3 Code's pattern).
  mkdir -p "$dir/.claude"; [ -e "$dir/.claude/skills" ] || ln -s ../.agents/skills "$dir/.claude/skills"
  # Append gitignore entries once.
  grep -q '^\.artifacts/' "$dir/.gitignore" 2>/dev/null || cat "$TEMPLATE/.gitignore.factory" >> "$dir/.gitignore"
  # Merge scripts, engines and devDependencies; the project's own values win.
  if [ -f "$dir/package.json" ]; then
    tmp="$(mktemp)"
    jq -s '.[0] as $t | .[1]
           | .scripts = (($t.scripts // {}) + (.scripts // {}))
           | .engines = (($t.engines // {}) + (.engines // {}))
           | .devDependencies = (($t.devDependencies // {}) + (.devDependencies // {}))' \
      "$TEMPLATE/package.scripts.json" "$dir/package.json" > "$tmp" && mv "$tmp" "$dir/package.json"
  fi
  chmod +x "$dir"/.claude/hooks/*.sh "$dir/.vite-hooks/pre-commit" 2>/dev/null || true
  # pnpm gates the native binary @ast-grep/cli builds; approve it once so nobody is
  # asked at install time. In a workspace the key lives in pnpm-workspace.yaml.
  approve_ast_grep "$dir/pnpm-workspace.yaml"
  # Install first: the lint plugin and the rule engine are devDependencies, and the
  # gates report missing tooling as failure. Then format, because vp check stops at
  # the first stage and an unformatted file would hide every lint and type error.
  # apply just changed package.json, so the lockfile must be regenerated; pnpm would otherwise
  # refuse under CI. A failed install is reported, never hidden: every gate depends on it.
  log="$(mktemp)"
  if ! (cd "$dir" && vp install --no-frozen-lockfile) > "$log" 2>&1; then echo "warning: vp install failed:"; tail -8 "$log"; fi
  rm -f "$log"
  (cd "$dir" && vp fmt >/dev/null 2>&1) || true
  cmd_doctor "$dir" || true
}

cmd_init() {
  local dir="$1"; shift; local template="vite:monorepo" github=1
  while [ $# -gt 0 ]; do case "$1" in --no-github) github=""; shift ;; vite:*) template="$1"; shift ;; *) shift ;; esac; done
  need vp; [ -z "$github" ] || need gh
  # vp create refuses an absolute --directory: run it from the parent and pass the name.
  mkdir -p "$(dirname "$dir")"
  (cd "$(dirname "$dir")" && vp create "$template" --directory "$(basename "$dir")" --no-interactive --git --hooks --no-agent)
  git -C "$dir" branch -M main   # vp create uses the machine default; CI, the guard and protection assume main
  cmd_apply "$dir" --scaffold
  if [ -n "$github" ]; then
    if (cd "$dir" && gh repo create --source=. --private --push); then
      # Owner-mode repository setting: merged branches are deleted so stacked PRs retarget to main.
      (cd "$dir" && gh repo edit --delete-branch-on-merge >/dev/null) || echo "note: could not set delete-branch-on-merge; delete branches after merging"
      cmd_labels "$dir"
    else
      echo "skipped gh repo create; labels and repository settings wait until a remote exists"
    fi
  fi
  echo "Next: open Claude Code in $dir and run /factory-start. Human-only steps such as secrets: /wizard writes the script."
}

# A session inherits whatever branch the last one left, so the doctor says where the checkout is
# before anything else. Offline, the line says it compared against the last fetch; it never
# reports "up to date" as if the fetch had happened.
doctor_branch() {
  git rev-parse --is-inside-work-tree >/dev/null 2>&1 || return 0
  local ref="" branch behind plural merged stale=""
  if git remote get-url origin >/dev/null 2>&1; then
    git fetch -q origin main 2>/dev/null || stale=" (fetch failed, compared against the last fetch)"
  fi
  if git rev-parse -q --verify origin/main >/dev/null 2>&1; then ref=origin/main
  elif git rev-parse -q --verify main >/dev/null 2>&1; then ref=main; fi
  branch="$(git branch --show-current)"
  if ! git rev-parse -q --verify HEAD >/dev/null 2>&1; then
    note "branch ${branch:-detached HEAD} has no commits yet" "git add -A && git commit -m 'chore: initial commit'"
  elif [ -z "$ref" ]; then
    note "branch ${branch:-detached HEAD}: no main to compare against" "git remote add origin <url> && git fetch origin"
  elif [ -z "$branch" ]; then
    note "detached HEAD" "git checkout main && git pull"
  else
    behind="$(git rev-list --count "HEAD..$ref" 2>/dev/null || echo unknown)"; plural=s; [ "$behind" = 1 ] && plural=""
    if [ "$behind" = unknown ]; then
      note "branch $branch: could not compare with $ref" "git fetch origin, then git status"
    elif [ "$branch" = main ]; then
      if [ "$behind" -gt 0 ]; then note "branch main is $behind commit$plural behind $ref$stale" "git pull"; else echo "PASS  branch main, up to date$stale"; fi
    elif [ "$behind" -eq 0 ]; then
      echo "PASS  branch $branch, up to date with main$stale"
    elif git merge-base --is-ancestor HEAD "$ref"; then
      note "branch $branch is already in main$stale" "git checkout main && git pull"
    else
      merged="$(gh pr list --head "$branch" --state merged --json number --jq length 2>/dev/null || echo unknown)"
      if [ "$merged" = unknown ] || [ -z "$merged" ]; then stale="$stale (merged state unknown, gh did not answer)"; merged=0; fi
      if [ "$merged" -gt 0 ]; then
        note "branch $branch was merged (squash or rebase, so main does not contain its commits)" "git checkout main && git pull"
      else
        note "branch $branch is $behind commit$plural behind main$stale" "git checkout main && git pull to start a ticket, or git rebase $ref to continue this branch"
      fi
    fi
  fi
}

# Each FAIL line carries its fix, so an agent reading the table can guide a person who has
# never seen this system. PASS needs nothing; NOTE is optional.
STALE_DAYS=14

cmd_doctor() {
  local dir="${1:-.}"; local fail=0
  chk() { if eval "$2" >/dev/null 2>&1; then echo "PASS  $1"; else echo "FAIL  $1"; echo "      fix: $3"; fail=1; fi; }
  note() { echo "NOTE  $1"; echo "      fix: $2"; }
  cd "$dir"
  if [ ! -f .factory918/manifest.json ]; then
    echo "FAIL  this directory is not a Factory918 project"
    echo "      fix: factory918 init <new-dir> to create one, or factory918 apply here to add Factory918 to an existing repo"
    return 1
  fi
  doctor_branch
  chk "factory files reachable"       "[ -d \"$TEMPLATE\" ] && [ -d \"$F918_DIR/profiles\" ]" "the factory918 command does not resolve to a clone (template/ missing beside it); run ./factory918.sh install from the clone"
  chk "factory918 installed"          "command -v factory918 && [ -d \"\${FACTORY918_HOME:-\$HOME/.factory918}/docs/knowledge\" ]" "in the factory918 clone run ./factory918.sh install, add ~/.local/bin to PATH, open a new terminal"
  chk "one factory on this machine"   "[ ! -e \"\$HOME/.factory918\" ] || [ \"\$(cd \"\$HOME/.factory918\" && pwd -P)\" = \"\$(cd \"\$(dirname \"\$(readlink \"\$(command -v factory918)\")\")\" && pwd -P)\" ]" "~/.factory918 and ~/.local/bin/factory918 point at different clones; run ./factory918.sh install from the one you want"
  chk "vp matches the ADR pin"        "[ \"\$(vp --version | head -1 | sed 's/^vp v//')\" = \"\$(sed -n 's/.*vite-plus \\([0-9][0-9.]*\\).*/\\1/p' docs/adr/0001-toolchain.md | head -1)\" ]" "docs/adr/0001-toolchain.md pins a different vite-plus than vp --version reports; update the ADR or run the Vite+ installer with VP_VERSION=<pin>"
  chk "vp on PATH"                    "command -v vp" "curl -fsSL https://vite.plus -o /tmp/vp.sh && VP_VERSION=0.3.1 VP_NODE_MANAGER=yes bash /tmp/vp.sh, then open a new terminal"
  chk "vp env doctor"                 "vp env doctor" "run vp env doctor and follow its output"
  chk "hooks installed"               "vp hooks status | grep -qi 'hooksPath'" "vp hooks enable (no .git means this is not a repository yet: git init first)"
  chk ".claude/skills symlink"        "[ \"\$(readlink .claude/skills)\" = ../.agents/skills ]" "rm -rf .claude/skills && ln -s ../.agents/skills .claude/skills"
  chk "every skill has a name"        "! grep -L '^name:' .agents/skills/*/SKILL.md | grep ." "factory918 update restores the vendored skills; a skill you wrote needs a name: line in its frontmatter"
  chk "no duplicate skill names"      "[ -z \"\$(grep -h '^name:' .agents/skills/*/SKILL.md | sort | uniq -d)\" ]" "rename or remove one of the two skills that share a name (grep -h ^name: .agents/skills/*/SKILL.md | sort | uniq -d)"
  chk "gh authenticated"              "gh auth status" "gh auth login (install gh first: brew, apt, dnf or winget)"
  chk "labels present"                "gh label list --limit 200 | grep -q ready-for-agent" "factory918 labels (needs a GitHub remote; factory918 init creates one, or gh repo create --private --source=. --push)"
  # No remote or no auth prints nothing here; the two lines above already say so.
  local dbm; dbm="$(gh repo view --json deleteBranchOnMerge --jq .deleteBranchOnMerge 2>/dev/null || true)"
  if [ "$dbm" = true ]; then echo "PASS  delete-branch-on-merge"
  elif [ "$dbm" = false ]; then note "delete-branch-on-merge" "gh repo edit --delete-branch-on-merge; without it a stacked PR stays on its merged parent's branch instead of retargeting to main"; fi
  chk "ci workflow present"           "[ -f .github/workflows/ci.yml ]" "factory918 update restores it"
  chk "settings.json parses"          "jq . .claude/settings.json" "fix the JSON in .claude/settings.json, or factory918 update to restore the template copy"
  chk "hooks executable"              "[ -x .claude/hooks/mode.sh ] && [ -x .claude/hooks/block-dangerous-git.sh ] && [ -x .claude/hooks/delegation.sh ]" "chmod +x .claude/hooks/*.sh"
  chk "state dir ignored"             "git check-ignore -q .claude/state/mode" "append the lines from the factory clone's template/.gitignore.factory to .gitignore"
  if [ -f .claude/state/review/files ]; then
    note "a review state is left behind: .claude/state/review ($(cat .claude/state/review/fixed-point 2>/dev/null || echo unknown), $(wc -l < .claude/state/review/files | tr -d ' ') files); reads of those files are blocked" "finish the review (spec-review step 6 runs review-comment.sh, which clears it) or rm -rf .claude/state/review"
  fi
  chk "vp check (format, lint, types)" "vp check" "vp fmt, then vp check, and fix what it reports; it stops at the first failing stage"
  chk "tests"                         "vp test run" "vp test run and read the failing test"
  [ -f "$HOME/.claude/pstack-models.md" ] && echo "PASS  models sheet" || note "models sheet" "factory918 install writes ~/.claude/pstack-models.md"
  chk "AGENTS.md is Factory918's"     "grep -q 'factory918' AGENTS.md" "factory918 apply --scaffold replaces the AGENTS.md that vp create wrote"
  chk "slots filled (/factory-start)" "! grep -q '<[A-Za-z].*slot\|<Project name>\|<One paragraph' AGENTS.md" "open Claude Code here and run /factory-start, the Day-0 interview; it fills every <slot>"
  chk "slim knowledge present"        "[ -f docs/factory918/PHILOSOPHY.md ] && [ -f docs/factory918/MANUAL.md ]" "factory918 update restores docs/factory918/"
  chk "glue skills resolve"           "[ -f .agents/skills/factory918/SKILL.md ] && [ -f .agents/skills/factory-start/SKILL.md ] && [ -f .agents/skills/knowledge/SKILL.md ] && [ -f .agents/skills/factory-retro/SKILL.md ]" "factory918 update restores the factory918, factory-start, knowledge and factory-retro skills"
  chk "ledger exists"                 "[ -f docs/agents/ledger.md ]" "factory918 update restores docs/agents/ledger.md"
  chk "ast-grep rules test"           "pnpm sg:test" "vp install (the rule engine is a devDependency), then pnpm sg:test; a rule without a snapshot needs ast-grep test --update-all"
  # Evidence is never committed and nothing prunes it; say when it is old, delete nothing.
  # A directory's mtime moves only when its direct entries change, so a tas
... (8592 more characters, see written/scratchpad/syncchk/repo/factory918.sh)
```

## Other files written (not shown)

scratchpad/syncchk/repo/.claude/settings.json
scratchpad/syncchk/repo/.github/workflows/factory-ci.yml
scratchpad/syncchk/repo/.gitignore
scratchpad/syncchk/repo/.scratch/review/ab47eb9/diff
scratchpad/syncchk/repo/AGENTS.md
scratchpad/syncchk/repo/CLAUDE.md
scratchpad/syncchk/repo/CODING_STANDARDS.md
scratchpad/syncchk/repo/LICENSE
scratchpad/syncchk/repo/README.md
scratchpad/syncchk/repo/SOURCES.md
scratchpad/syncchk/repo/VERSION
scratchpad/syncchk/repo/docs/FACTORY-SPEC-v2.md
scratchpad/syncchk/repo/docs/M0-findings.md
scratchpad/syncchk/repo/docs/agents/domain.md
scratchpad/syncchk/repo/docs/agents/issue-tracker.md
scratchpad/syncchk/repo/docs/agents/ledger.md
scratchpad/syncchk/repo/docs/agents/triage-labels.md
scratchpad/syncchk/repo/docs/knowledge/INDEX.md
scratchpad/syncchk/repo/docs/knowledge/core/CONVERSATION-DIGEST.md
scratchpad/syncchk/repo/docs/knowledge/core/DECISIONS.md
scratchpad/syncchk/repo/docs/knowledge/core/GLOSSARY.md
scratchpad/syncchk/repo/docs/knowledge/core/MANUAL.md
scratchpad/syncchk/repo/docs/knowledge/core/PHILOSOPHY.md
scratchpad/syncchk/repo/docs/knowledge/core/SCENARIO-TABLE.md
scratchpad/syncchk/repo/docs/knowledge/notes/1-matt-pocock/01-preamble.md
scratchpad/syncchk/repo/docs/knowledge/notes/1-matt-pocock/02-who-he-is-brief-relevance-to-manuel.md
scratchpad/syncchk/repo/docs/knowledge/notes/1-matt-pocock/03-philosophy-with-verbatim-quotes-citations.md
scratchpad/syncchk/repo/docs/knowledge/notes/1-matt-pocock/04-the-end-to-end-flow-step-by-step-text-diagram-wh.md
scratchpad/syncchk/repo/docs/knowledge/notes/1-matt-pocock/05-the-six-axes.md
scratchpad/syncchk/repo/docs/knowledge/notes/1-matt-pocock/06-skill-catalog.md
scratchpad/syncchk/repo/docs/knowledge/notes/1-matt-pocock/07-how-the-system-evolved-changelog-releases-what-w.md
scratchpad/syncchk/repo/docs/knowledge/notes/1-matt-pocock/08-setup-install-for-claude-code-exact-commands-fir.md
scratchpad/syncchk/repo/docs/knowledge/notes/1-matt-pocock/09-what-s-opinionated-possible-friction-for-a-begin.md
scratchpad/syncchk/repo/docs/knowledge/notes/1-matt-pocock/10-sources.md
scratchpad/syncchk/repo/docs/knowledge/notes/2-theo/01-preamble.md
scratchpad/syncchk/repo/docs/knowledge/notes/2-theo/02-1-who-he-is-and-why-his-experience-matters-brief.md
scratchpad/syncchk/repo/docs/knowledge/notes/2-theo/03-2-evidence-inventory.md
scratchpad/syncchk/repo/docs/knowledge/notes/2-theo/04-3-his-agents-md-analyzed.md
scratchpad/syncchk/repo/docs/knowledge/notes/2-theo/05-4-his-skills.md
scratchpad/syncchk/repo/docs/knowledge/notes/2-theo/06-5-why-don-t-copy-them.md
scratchpad/syncchk/repo/docs/knowledge/notes/2-theo/07-6-reconstructed-workflow-idea-merge.md
scratchpad/syncchk/repo/docs/knowledge/notes/2-theo/08-7-the-six-axes.md
scratchpad/syncchk/repo/docs/knowledge/notes/2-theo/09-8-t3-code-as-an-encoding-of-his-workflow.md
scratchpad/syncchk/repo/docs/knowledge/notes/2-theo/10-9-timeline-of-how-his-stance-evolved-2024-2026.md
scratchpad/syncchk/repo/docs/knowledge/notes/2-theo/11-10-what-s-reusable-for-a-claude-code-beginner-vs.md
scratchpad/syncchk/repo/docs/knowledge/notes/2-theo/12-11-sources.md
scratchpad/syncchk/repo/docs/knowledge/notes/3-pstack/01-preamble.md
scratchpad/syncchk/repo/docs/knowledge/notes/3-pstack/02-who-she-is-and-why-it-exists-sourced.md
scratchpad/syncchk/repo/docs/knowledge/notes/3-pstack/03-philosophy-the-21-principles.md
scratchpad/syncchk/repo/docs/knowledge/notes/3-pstack/04-the-workflow.md
... and 1027 more
