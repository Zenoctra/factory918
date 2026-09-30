# #109 eco tier: how the pieces work today

Read-only exploration of the worktree at `.claude/worktrees/agent-a2ce71454fd0910f0` (branch `feat/eco-tier`, at `origin/main`). All paths are repo-relative unless absolute.

## 1. Phase state, and whether `.claude/state/tier` fits

**Where it is written.** `template/.claude/hooks/mode.sh:8-14` is the only writer: it computes `state_dir="${CLAUDE_PROJECT_DIR:-.}/.claude/state"`, `mkdir -p`s it, and a `case` on the submitted prompt writes `planning` or `execute` into `$state_dir/mode`. Line 15 reads it back, defaulting to `execute`. Lines 26-30 print `PHASE: ...` into every turn's context. Lines 32-35 read a second state file, `.claude/state/review/files`, and print a `REVIEW:` line. The hook is a `UserPromptSubmit` hook, so its stdout is context, not a tool result.

**Every reader of `.claude/state/`:**

- `template/.claude/hooks/mode.sh:10` (`mode`), `:15`, `:32-34` (`review/`).
- `template/.claude/hooks/delegation.sh:26` — `phase="$(cat "$root/.claude/state/mode" 2>/dev/null || echo execute)"`; `:27` `review="$root/.claude/state/review"`; `:47` classifies `.claude/state/*` as `untracked` (so the orchestrator may always write there); `:76` and `:98` read `review/fixed-point` for the block messages.
- `template/.agents/skills/mode-plan/SKILL.md:7` and `template/.agents/skills/mode-build/SKILL.md:7` — each runs `mkdir -p .claude/state && echo <phase> > .claude/state/mode`. These are the two "set it by hand" skills.
- `template/.agents/skills/factory918/SKILL.md:45` — prose: "Read the phase: `cat .claude/state/mode` (missing means `execute`)".
- `template/.agents/skills/spec-review/scripts/review-brief.sh:356` and `review-comment.sh:31` — both set `state=.claude/state/review`; the brief script writes it, the comment script clears it.
- `template/.agents/skills/spec-review/SKILL.md:21` and `:145` name those scripts and the state they write/clear.
- `template/.agents/skills/poteto-mode/scripts/overlap.sh:22` — `prog="$(git rev-parse --git-common-dir)/../.claude/state/program"`, the go registry (a third state file, worktree-common).
- `factory918.sh:267` — `doctor` asserts `git check-ignore -q .claude/state/mode`; `:268-269` warns about a left-behind `.claude/state/review`.
- Prose: `docs/knowledge/core/GLOSSARY.md:39` ("Mode / phase. `planning` or `execute`, stored in `.claude/state/mode`"), `docs/knowledge/core/DECISIONS.md:35` (decision 19, which phase the hooks guard), `docs/knowledge/core/SCENARIO-TABLE.md:74` (the overlap registry).
- Tests: `tests/hooks/delegation.sh:16,27,96-99` build the state dir as a fixture; `tests/poteto-mode/overlap.sh:72,217`.

**Gitignored?** Yes, in both. Factory: `.gitignore:7` `.claude/state/`. Applied projects: `template/.gitignore.factory:5` `.claude/state/`, which `factory918.sh:145` appends once to the project's `.gitignore` (`grep -q '^\.artifacts/' ... || cat "$TEMPLATE/.gitignore.factory" >> "$dir/.gitignore"`). `factory918.sh:267` is the doctor check that the append happened.

**How `apply` treats `.claude/state`.** It does not copy it: the copy loop is `factory918.sh:131-141`, which walks `find "$TEMPLATE" -type f` and skips only `package.scripts.json` and `.gitignore.factory` (`:133`). There is no `.claude/state` under `template/`, so nothing is copied, nothing is recorded in `.factory918/manifest.json`, and `update`/`sync` never touch it. The directory is created at runtime by `mode.sh:9` or by `mode-plan`/`mode-build`. Consequence: state is per-checkout, per-project, never versioned, never managed by the manifest.

**Would `.claude/state/tier` fit?** Yes, identically and with no new machinery:

- It is already gitignored by the existing `.claude/state/` line in both `.gitignore:7` and `template/.gitignore.factory:5`; no ignore change needed.
- It is already classified `untracked` by `delegation.sh:47`, so the orchestrator may write it without tripping the write guard (asserted today at `tests/hooks/delegation.sh:86`).
- `apply` needs no change (nothing under `template/` to copy).
- A reader costs one line, exactly like `mode.sh:15`: `tier="$(cat "$root/.claude/state/tier" 2>/dev/null || echo safe)"` — defaulting to `safe` keeps every existing checkout on today's behavior.

**Who could read it.**

- `mode.sh` — it already prints a per-turn context line; adding `TIER: eco` beside `PHASE: execute` (near `:26-30`) is the cheapest way to make every playbook see the tier without a file read. It would also need a prompt `case` arm to set it, matching `:12-13` (or two skills mirroring `mode-plan`/`mode-build`).
- `delegation.sh:56` (`guard_write`) — the only hook that would branch on the tier for behavior rather than display.
- Playbooks as prose, since they are read by an agent that already has the `TIER:` line in context: `poteto-mode/playbooks/ticket.md` (steps 0, 5, 8), `feature.md` (steps 1, 2, 4), `autopilot-stack.md` (steps 1, 7), `spec-review/SKILL.md` (step 4), `architect/SKILL.md` (Phase B), `how/SKILL.md` (Step 1). A prose branch is the pattern the repo already uses for the review state.
- `factory918.sh doctor` could report it beside the state-dir check at `:267-269`.
- Trap: `.claude/state/program` (`overlap.sh:22`) resolves through `git rev-parse --git-common-dir`, i.e. it is shared across worktrees. A `tier` file at `$CLAUDE_PROJECT_DIR/.claude/state/tier` would be **per-worktree**, so an autopilot-stack owner in its own worktree would not inherit the root's tier unless the brief names it (which AC 4 requires anyway) or the file is placed under the common dir.

## 2. `template/.claude/hooks/delegation.sh`: the write guard

**The decision path for a write**, in order:

1. `:7` `set -fuo pipefail` (no `-e`; the comment at `:6` says anything failing inside lets the call through).
2. `:9-12` one `jq` extracts seven fields: `agent_id`, `tool_name`, `cwd`, `file_path`/`notebook_path`, `offset`, `limit`, `command`. Nothing else from `tool_input` is read — notably **not** `new_string`, `old_string` or `content`. A parse failure exits 0.
3. `:15` `[ -z "$agent_id" ] || exit 0` — **the subagent bypass**. The hook input carries `agent_id` only for a sub-agent (verified, `docs/M0-findings.md`, cited by decision 19 at `docs/knowledge/core/DECISIONS.md:35`). So only the root session is guarded; an autopilot-stack owner, being a subagent, is unguarded today.
4. `:23-24` resolve `root` and require it to be a git work tree, else exit 0.
5. `:26` read the phase from `.claude/state/mode`, defaulting to `execute`.
6. `:201-211` dispatch by tool: `Write|Edit|NotebookEdit` -> `relative()` then `guard_write`; `Read` -> `guard_read` with `ranged` if `offset` or `limit` is set, else `whole`; `Bash` -> tokenise the command (`tokens()`, `:107-130`) and run `scan_segment` per line, which handles `tee`/`cat`/`head`/`sed`/`git` and `>` redirection (`:191-197`).
7. `relative()` `:34-42` makes the path repo-relative and **returns non-zero for anything outside the repo**, which the callers turn into exit 0.
8. `classify()` `:46-53`: `.claude/state/*`, `.artifacts/*`, `.scratch/*`, `.plans/*` -> `untracked`; anything `git ls-files` does not know -> `untracked`; `docs/agents/ledger.md`, `docs/adr/*`, `docs/knowledge/core/DECISIONS.md`, `docs/M0-findings.md` -> `owned`; everything else tracked -> `lane`.
9. `guard_write()` `:55-59` is the whole policy, three lines:
   - `[ "$phase" = execute ] || return 0` — **the phase gate**: no write guard in `planning`.
   - `[ "$(classify "$1")" = lane ] || return 0` — the **path list** is the `owned` list plus the untracked prefixes; only `lane` is blocked.
   - `block "BLOCKED: writing $1 is a lane's job (P11). ..."` — `block()` `:30` echoes to stderr and `exit 2`.

So allow/block is a pure function of (subagent?, git work tree?, phase, path class). **Size is nowhere in the write path.** The read path is the only place a size threshold exists: `max_lines=200` at `:28`, used by `guard_read` `:78-82` and by `scan_head`/`scan_sed`.

**Where a size-based allowance would go.** Inside `guard_write()` at `:55-59`, as a fourth condition between the `classify` test and `block`. Two structural facts constrain it:

- The size is **not in the parsed fields**. The `jq` filter at `:9-11` would have to be extended (e.g. `(.tool_input.new_string // .tool_input.content // "" | tostring | split("\n") | length)`), and `field()` at `:13` indexes by line number, so a new field must go at position 7 and the `command` field's `7,$p` at `:22` must become `8,$p`.
- `Edit` gives `new_string`; `Write` gives `content`; `NotebookEdit` gives neither in the parsed set; and a `Bash` heredoc write is detected at `:72-74`/`:182` with no body available at all (`tokens()` at `:110` deliberately drops heredoc bodies). So a size rule cannot cover every write route — exactly the decision AC 3 asks to settle and test.
- `tier` itself would be read next to `phase` at `:26`.

**How `tests/hooks/delegation.sh` is structured** (145 lines):

- `:6-28` build a throwaway git fixture in `mktemp -d`: `big.sh` (250 lines), `small.md` (10), the four `owned` paths, a `.scratch/` file, `echo execute > .claude/state/mode`, `export CLAUDE_PROJECT_DIR="$fx"`.
- `:30-33` define the expected BLOCKED strings once, as functions or variables (`write_msg`, `cap_msg`, `diff_msg`, `review_msg`), so an assertion never retypes a message.
- `:39-49` `call <orchestrator|agent> <tool> <tool_input JSON>` builds the full PreToolUse JSON with `jq -cn` and pipes it to the hook, capturing stderr into `err` and the exit code into `code`. The `agent` variant merges `{"agent_id":"a1b2c3","agent_type":"general-purpose"}` — that is how the subagent bypass is exercised.
- `:51-60` `expect <exit> <message> <who> <tool> <tool_input JSON> <label>` compares both the code and the exact stderr; a mismatch prints got/wanted and `exit 1` on the first miss. `n` counts passes.
- `:61-63` three input builders: `path()`, `ranged()`, `bash_cmd()`.
- Scenario rows then run as one `expect` line each, grouped: writes and reads `:65-94`, review state `:96-116`, subagent bypass `:118-126`, planning phase `:128-131`, degraded review state `:133-135`, malformed JSON `:137-144`, `echo "ok $n assertions"` at `:145`.

A scenario-table row becomes exactly one `expect` line: expected exit, expected message, actor, tool, input, label. One assertion verbatim (`tests/hooks/delegation.sh:65`):

    expect 2 "$(write_msg big.sh)" orchestrator Write "$(path big.sh)" "orchestrator Write to big.sh"

and the allow-side counterpart for state (`:86`):

    expect 0 "" orchestrator Write "$(path .claude/state/todo.md)" "Write to .claude/state"

A tier row would add `echo eco > .claude/state/tier` as a fixture mutation — the pattern used at `:128` for the phase, `echo planning > .claude/state/mode` — then the `expect` rows for allowed-small and blocked-large writes.

## 3. Each eco change: the exact file and line that makes the lane today

### how explorer / explainer lanes

- `template/.agents/skills/how/SKILL.md:30-35` — the Simple/Complex fork. `:32` "skip explorer agents; the explainer explores and explains in a single pass. Go to Step 2b." `:33` "spawn parallel explorer agents first, then hand off to the explainer."
- `:37-56` Step 2a: `:39` decompose into 2-4 angles; `:45` "Narrow questions: 2 explorers is fine. Broad subsystems: up to 4"; `:47` "Start all explorers in one fan-out phase through provider dispatch. Use your configured how-explorer descriptor (default `grok:grok-4.6@xhigh`) in `read-only` mode."; `:49` each gets `references/explorer-prompt.md`.
- `:62` Step 2b: "Dispatch one read-only lane that explores and explains in one pass using your configured how-explainer descriptor (default `claude:fable@max`)." `:70` Step 2c: the synthesising explainer lane. `:76` the orchestrator presents the explainer's output and must not rewrite it.
- The entry points that make a ticket run this: `template/.agents/skills/poteto-mode/playbooks/ticket.md:14` (step 5) — "`how` and `why` over the affected subsystem come first in all of them" — and `template/.agents/skills/poteto-mode/playbooks/feature.md:5` (step 1) — "`how` over the affected subsystem. Poll each lane's result file per the poll rule (Ticket step 0)." The same step-1 line exists in `bug-fix.md`, `refactoring.md` and `perf-issue.md` (SOURCES.md item 13 patched those four together).
- Models-sheet rows eco would stop consuming: `how explorer`, `how explainer`, `how critics`, mirrored in `docs/knowledge/core/MANUAL.md:139`.
- **Patch touching `how/SKILL.md`: none.** `patches/series` has no `pstack/how/` entry. `how` is vendored verbatim from `research/3-pstack/open-pstack-claude-code-port/plugins/pstack/skills/how/`, so an eco branch inside it needs a **new** patch file, a new `series` line and a new SOURCES.md item. Patches on the callers do exist: `patches/pstack/poteto-mode/playbooks/feature.md.patch`, `bug-fix.md.patch`, `refactoring.md.patch`, `perf-issue.md.patch`. `ticket.md` is ours, not a patch (`patches/README.md:11`, `factory918.sh:385` `keep_files`).

### architect: two runners plus a judge

- `template/.agents/skills/architect/SKILL.md:32` (Phase B) — "Run the **arena** skill with the design-sketch task and the Phase A grounding artifacts. Pass `references/runner-prompt.md` as each runner's prompt."
- `:34` — "Use your configured architect runners (defaults `claude:fable@max`, `codex:gpt-5.6-sol@max`, `grok:grok-4.6@xhigh`, `claude:opus@xhigh`)."
- `:36` — "**Design it twice.** Require at least two structurally distinct candidates before synthesis, even when the first looks sufficient." This is the sentence eco must change; it is justified by the `exhaust-the-design-space` principle skill.
- `:80` — a failed check returns to Phase B and re-runs arena.
- The judge lives in `arena`: `template/.agents/skills/arena/SKILL.md:40-42` (Phase C, Cross-judge) — "choose the judge descriptor from `arena cross-judge pool` ... Dispatch one read-only judge through the provider contract. It sees the rubric and completed candidates by path label, scores each criterion, and recommends a base." `:29` picks runners; `:30` assigns one output path per candidate; `:48` the parent scores against the cross-judge; `:62` handles convergence ("ship the consensus shape. No graft is needed") — with one runner there is no convergence case, so eco must say what the judge compares against.
- The other caller that already reduces the count: `ticket.md:38` (Design hole, step 2) — "Run `architect` Phase B scoped to it ... Two runners; the judge is skipped when they converge." Eco's "one runner plus an adversarial judge" inverts this line, so both must be edited together or they contradict.
- **Patches:** `patches/pstack/architect/SKILL.md.patch` (hunk header `@@ -29,7 +29,7 @@`, i.e. it already edits the Phase B block at `:29-35`) and `patches/pstack/architect/references/runner-prompt.md.patch`, both in `patches/series`, described at `SOURCES.md:26` (item 14). **`arena/SKILL.md` has no patch** — a new one is needed if the judge's contract changes there rather than in `architect`.

### The "review wrapper lane"

No file says "launch a review lane"; the lane is made by two rules meeting:

- `template/AGENTS.md:79` — "At the first push, run `spec-review` round one **in a fresh context**, with CI running alongside". Mirrored at `template/docs/agents/review-ladder.md:6` and `docs/knowledge/core/MANUAL.md:94` ("in a fresh context so the reviewer is not the author"). This repo's own `AGENTS.md`, "Pull requests", carries the same sentence.
- `template/.agents/skills/poteto-mode/playbooks/ticket.md:17` (step 8) — "Review round one starts at the first push and CI runs alongside it; **poll each review lane's result file per the poll rule (step 0)**". The poll rule is `ticket.md:6`: a lane's completion notification reaches the root session, never the owner that launched it. Calling it a "review lane" whose result file is polled is what makes the fresh context a *subagent* rather than a fresh root session.

Inside that lane, `spec-review` spawns the two reviewers:

- `template/.agents/skills/spec-review/SKILL.md:11` — "Both axes run as **parallel sub-agents** so they don't pollute each other's context, then this skill aggregates their findings."
- `:21` (step 1) — runs `scripts/review-brief.sh <fixed-point>`, which writes the diff, both briefs and `.claude/state/review/`.
- `:66-68` (step 4, "Spawn both sub-agents in parallel") — each sub-agent's prompt is just its brief's path; each writes `<dir>/standards-report.md` or `<dir>/spec-report.md` and replies with only that path.
- `:112` — the descriptors: `standards reviewer` (default `claude:opus@medium`) and `spec reviewer` (default `claude:opus@high`), read-only.
- `:114` step 5 (Judge), `:143-145` step 6 (Aggregate, runs `scripts/review-comment.sh`, which clears the state).

Eco's change is to drop the outer lane: the owner runs `review-brief.sh` itself and dispatches the two reviewer subagents directly, then does steps 5 and 6. **The obstacle is `delegation.sh`**: `.claude/state/review/files` makes `guard_read` `:73-77` and `scan_git` `:86-96` block the orchestrator from reading the diff, the stat and both briefs (`in_review()` `:63-71`) — asserted today at `tests/hooks/delegation.sh:104-116`. Reports are readable (`:115`), so steps 5 and 6 are already root-safe; step 1 and step 4 are not, because the owner would be the one running the script that writes the block-state. This is the hard edge for the writer.

- **Patch:** `patches/mattpocock/spec-review.SKILL.md.patch`, in `series`, described at `SOURCES.md:18` (item 6, the longest item in the file). It already rewrites steps 1, 4, 5 and 6. `review-brief.sh`, `review-comment.sh` and `reading-pack.sh` are **ours**, kept across sync by `factory918.sh:385` `keep_files`, so they are edited directly.

### Fix lanes and records lanes

- `template/.agents/skills/spec-review/SKILL.md:134` — "From round three on **the fix lane** fixes the Act on items on this PR before the comment is posted"; `:140` repeats it for the `fixed: <sha>` bullet.
- `template/.agents/skills/poteto-mode/playbooks/ticket.md:48` (Would-break fix, step 1) — "From round three on the fix lane fixes that round's Act on items before its comment is posted".
- `template/.agents/skills/poteto-mode/playbooks/feature.md:13` (step 5) — "A fix lane proves its change on the path CI takes".
- `template/.agents/skills/poteto-mode/playbooks/babysit.md:16` — "the fix lands on this PR"; `:28` step 8 — bot findings fixed "with a red-first proof in the lowest PR that owns the code". Babysit never names the lane; it inherits P11.
- The rule that makes all of them lanes is **P11**, `docs/knowledge/core/DECISIONS.md:80` — "A separate lane writes; the orchestrator designs, briefs, and reviews the returned diff. **The split is by path, not by size**: the orchestrator writes its own records (`docs/agents/ledger.md`, `docs/adr/*`, this file, `docs/M0-findings.md` ...)". That clause is precisely what eco's "owner writes small fixes" contradicts, and it is what the hook implements at `delegation.sh:50` and `:56-58`. Decision 19 at `DECISIONS.md:35` scopes the guard to `execute` and records the subagent bypass.
- The **records commit** is already the owner's by path: `ticket.md:22` (a decision goes under Provisional as `P<N>`; id rule P110 at `DECISIONS.md:102`, prose at `:68`) and this repo's `AGENTS.md`, "Pull requests". Those four paths are the `owned` arm of `classify()` at `delegation.sh:50`, asserted allowed at `tests/hooks/delegation.sh:87,89,90,91`. So "the owner writes the records commit itself" is already true for those four paths in `safe`; what eco adds is the rest of a records commit (`SOURCES.md`, `patches/series`, `VERSION`, `template/docs/`), which `classify()` calls `lane` and blocks — see `tests/hooks/delegation.sh:88` for the analogous `docs/agents/issue-tracker.md` block.
- **Patches:** `patches/mattpocock/spec-review.SKILL.md.patch` (for `SKILL.md:134,140`), `patches/pstack/poteto-mode/playbooks/feature.md.patch` (for `feature.md:13`), `patches/pstack/poteto-mode/playbooks/babysit.md.patch` and `patches/pstack/babysit/SKILL.md.patch` (SOURCES.md items 4 and 12). `ticket.md` is ours; `DECISIONS.md` is a hand-maintained core doc.

### The hand-back report shape

- `template/.agents/skills/poteto-mode/playbooks/autopilot-stack.md:11` (step 7, last sentence) — "Every STACK-READY report, first or after a rebase, is **one page** under these headings: `## Head` (SHA, patch base, parent), `## Criteria` (each with its evidence path), `## Review` (the last round's comment and its `act-on items:` line), `## CI`, `## Flags`."
- Referenced from `:8` (step 4) — "The owner reports STACK-READY with the exact head SHA, **in step 7's one-page shape**" — and from `ticket.md:18` (step 9), which requires the trail review before STACK-READY.
- `ticket.md:20` — the Ticket playbook's own **Reply:** line (the ticket, the criteria and how each was proven, what the ticket did not settle, the PR URL). `feature.md:21`, `babysit.md:33` and `autopilot-stack.md:16` each have one.
- So the one-page shape **already exists** for STACK-READY; the eco change is to make it the shape for the non-autopilot hand-back too (`ticket.md:20`), or to state that eco's report is step 7's five headings in every case.
- **Patch:** `patches/pstack/poteto-mode/playbooks/autopilot-stack.md.patch`, in `series`, described at `SOURCES.md:21` (item 11, which today only covers step 1's Ticket-playbook addition) and `SOURCES.md:28` (item 16, the poll-rule sweep from #105). `ticket.md` is ours.

## 4. Making and re-applying a patch

**What `sync` does** (`factory918.sh:377-405`, and `patches/README.md:5`):

1. `:385` copy the six `keep_files` (ours, living inside vendored directories) to a temp dir: `poteto-mode/playbooks/ticket.md`, `poteto-mode/scripts/overlap.sh`, `spec-review/scripts/review-brief.sh`, `review-comment.sh`, `reading-pack.sh`, `show-me-your-work/scripts/check-trail.sh`.
2. `:388` re-copy every pstack skill from `research/3-pstack/open-pstack-claude-code-port/plugins/pstack/skills/*/`, dropping `no-comments`.
3. `:389-390` re-copy the named Matt skills from `research/1-matt-pocock/skills-repo/skills`.
4. `:391` `cp -R "$matt/engineering/code-review" "$skills/spec-review"`.
5. `:392` restore the `keep_files`.
6. `:393` re-copy `.claude/agents/` from the pin, dropping `comment-sicko.md`.
7. `:395-399` apply each line of `patches/series` **in order** with `git apply`, from `template/.agents/skills` as cwd; a patch that no longer applies prints `FAILED   <p> (upstream moved; rewrite the patch)` and sets the exit code.
8. `:401` assert our seven own skills still exist.

`AGENTS.md` "Verifying" requires `./factory918.sh sync` to leave the working tree clean, so a patch that does not exactly reproduce the edited file fails the gate.

**Regenerating a patch** — `patches/README.md:7-9`:

    diff -u --label a/<path> --label b/<path> research/<upstream>/<path> template/.agents/skills/<path> > patches/<source>/<path>.patch

For a pstack skill, `<upstream>` is `3-pstack/open-pstack-claude-code-port/plugins/pstack/skills` (the path `sync` reads at `factory918.sh:382`), so for example:

    diff -u --label a/how/SKILL.md --label b/how/SKILL.md \
      research/3-pstack/open-pstack-claude-code-port/plugins/pstack/skills/how/SKILL.md \
      template/.agents/skills/how/SKILL.md > patches/pstack/how/SKILL.md.patch

Patch paths are relative to `.agents/skills` (`patches/README.md:3`), which the `--label a/how/SKILL.md` form produces.

**What a writer must do after editing `template/.agents/skills/...`** — the sequence the last three patch PRs used (seen via `git log --stat -3 -- patches/`):

1. Edit the vendored file under `template/.agents/skills/` directly.
2. Regenerate its patch with the `diff -u` above. Commit `65ab87a` ("Say trail rows come only from log.sh, and run check-trail.sh in the trail review, #111") touched `patches/pstack/show-me-your-work/SKILL.md.patch` (+32) and `patches/series` (+1) in the same commit — a **new** patch also needs its `series` line.
3. Add or amend the `SOURCES.md` numbered item. `65ab87a`'s message: "The patch, series and SOURCES.md item 18 carry it." `94f4847` ("Name the reading pack in spec-review step 4 and keep its script on sync, #107") changed `patches/mattpocock/spec-review.SKILL.md.patch` by 3 lines and says "SOURCES.md item 6 says so". `8d3496a` is the minimal case: one changed line in the same patch.
4. Run `./factory918.sh sync` and confirm the working tree is clean (`AGENTS.md`, "Verifying").
5. If a core doc changed too: `python3 tools/build_knowledge.py`, then `python3 tools/check_knowledge.py`.
6. Re-run the shell gates named in `AGENTS.md` "Verifying" if a script or hook changed — `65ab87a`'s siblings `bd15a62` (CI) and `f58308b` (the ShellCheck file count) show those landing as their own commits.

Ordering trap: `series` is applied top to bottom against a freshly re-vendored tree, so two patches touching the same file must not overlap hunks, and a patch generated against an already-patched `template/` copy would double-apply. Always diff against `research/`, never against a previous `template/` state.

## 5. `MANUAL.md` "Execution", and the `template/docs/` mirrors

`docs/knowledge/core/MANUAL.md` is hand-maintained (`AGENTS.md`, "Which files are the truth"). Its `## Contents` block at `:3-18` carries line numbers for the Read tool, so **any insertion renumbers that block** and `tools/build_knowledge.py` must be re-run.

Section outline:

- `:75` `## Execution`
- `:77` `/poteto-mode "#42"` — what the Ticket playbook does (reads the issue and parent spec, refuses on an open blocker, falsifiability pass).
- `:79` **Several at once.** one ticket per session; the three ways two unblocked tickets relate.
- `:81` **Draining the frontier.** `/poteto-mode "autopilot-stack #4 #5 #8"`; one owner lane per ticket in its own context and worktree, swarm-verified, delivered as a chain.
- `:83` **What you do.** not much until the PR exists; the agent asks only before irreversible actions.
- `:85` **Evidence.** `.artifacts/<task>/`, never committed.
- `:87` `## Pull requests, review and merge` begins.

**Where "how to set the tier" sits.** Between `:77` and `:79` — a new bold-lead paragraph, e.g. `**Safe and eco.**`, right after the `/poteto-mode "#42"` paragraph and before **Several at once.** Reasons: `:77` is the only paragraph about how a run starts; the tier is a property of the run, not of the fan-out; and AC 1 wants the same paragraph to say `safe` is the fallback when a model struggles, which reads as a caveat on "what the playbook does" rather than on the autopilot paragraph. The alternative home, `## Models and cost` (`:130-146`, role table at `:134-140`), is where a reader looks for "which model", not "how much ceremony" — but the tier changes what that table costs, so a one-line cross-reference there is cheap. The two setter skills to mirror are `mode-plan/SKILL.md:7` and `mode-build/SKILL.md:7`.

`DECISIONS.md`'s Provisional section starts at `docs/knowledge/core/DECISIONS.md:66`; the id rule (P110) is at `:102`, stated in prose at `:68` — a row from ticket #109 must be `P109`, and `tools/check_knowledge.py` refuses any other form.

**The `template/docs/` mirrors are generated.** `tools/build_knowledge.py:126-139` (`build_core`): for each of the six `CORE_DOCS` it writes a chunk under `docs/knowledge/core/`, and at `:137-139` — `if p.name != "CONVERSATION-DIGEST.md"` — it writes the header-stripped body to `template/docs/factory918/<name>`. That directory holds `DECISIONS.md`, `GLOSSARY.md`, `MANUAL.md`, `PHILOSOPHY.md`, `SCENARIO-TABLE.md`. So `template/docs/factory918/MANUAL.md` is **never edited by hand** (`AGENTS.md`, "The ways to hurt yourself", item 2); edit `docs/knowledge/core/MANUAL.md`, run `python3 tools/build_knowledge.py`, and the working tree must be clean afterwards. `:142` also shows `spec/`, `pages/` and `notes/` are wiped and rebuilt while `core/` is never touched. Separately, `template/docs/agents/*.md` (issue-tracker, domain, triage-labels, review-ladder, evidence) are the template's hand-edited copies, then copied to `docs/agents/` (`AGENTS.md`, "Agent skills").

## 6. The autopilot-stack owner brief

**There is no brief template anywhere in the repo outside `.scratch/`.** Searched `template/`, `docs/`, `tests/` for "owner brief", "brief the owner", "owner's brief", "standing orders"; `template/.agents/skills/poteto-mode/references/` contains only `bugbot-triage.md`, `codex-tools.md`, `provider-dispatch.md`. Every "standing orders" hit is the root's program objective, not an owner's brief: `autopilot-stack.md:7`, `autopilot-full.md:5`, `multi-phase-plan.md:37,45`, `orchestrate.md:10,64,83,102,104`, and the `orch` CLI's own store (`scripts/orch/orch.ts:511-522`).

What an owner receives is stated only as prose, in two places:

- `template/.agents/skills/poteto-mode/playbooks/autopilot-stack.md:5` (step 1) — "An owner's first action is invoking the poteto-mode skill, then reading **the digest (Ticket step 0) its brief carries**; it polls its own lanes per that step's poll rule." Also there: the owner runs `playbooks/ticket.md`, owns one PR end to end in its own worktree, and starts a `decisions.tsv` trail within about 15 minutes.
- `template/.agents/skills/poteto-mode/playbooks/ticket.md:5` (step 0) — "Read the digest before step 1: one page, **carried in the brief under Autopilot-stack**, else written by you to `.scratch/...`", followed by four bullets (`:6-9`): the poll rule, the `Closes #N` base rule, the no-`pull_request`-run-on-conflict rule, and `gh issue edit --body-file` replacing the body.
- `autopilot-stack.md:7` (step 3) adds the one thing the root writes that every owner reads indirectly: `overlap.sh go "autopilot-stack" 4 5 8`, the go line owners read in Ticket step 1.

So AC 4 ("the owner brief names the tier") has no existing template to extend. Either the tier joins `ticket.md:5`'s digest bullets — where the brief's contents are actually enumerated, and which every owner reads whether or not autopilot-stack launched it — or `autopilot-stack.md:5` gains a sentence naming the tier as a required field of the brief. The first is the cheaper edit and also covers a root-run ticket; the second is the only one that survives the per-worktree state problem in section 1, since an owner in its own worktree will not see the root's `.claude/state/tier`. Patch discipline differs: `autopilot-stack.md` goes through `patches/pstack/poteto-mode/playbooks/autopilot-stack.md.patch` plus `SOURCES.md` item 11; `ticket.md` is edited directly, since it is ours.
