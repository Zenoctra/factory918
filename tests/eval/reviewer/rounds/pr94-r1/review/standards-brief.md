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

## Reading pack

### SOURCES.md, lines 19-27 of 27

```
7. Session mandate replaced by ours (`template/.claude/hooks/session-mandate.md`).
8. `mobile-fingerprint-check.yml` copied into `profiles/react-native/` (T3 Code, MIT) with two edits: `runs-on: ubuntu-latest` instead of T3's Blacksmith runner, and the watched paths reduced to `apps/mobile/**`, `packages/shared/**` and the workspace files.
11. `playbooks/autopilot-stack.md` step 1: when a unit is a ticket, its owner runs the Ticket playbook, so tickets close on merge and blockers are checked under a stack run. Step 3: on the go, it runs `overlap.sh go "autopilot-stack" 4 5 8` over the unit tickets, as bare numbers, the program line the owners' Ticket step 1 reads. `poteto-mode/scripts/overlap.sh` is ours, not a patch, and is in `sync`'s `keep_files`.
10. `interrogate/SKILL.md` step 2: when a ticket exists, its What to build and Acceptance criteria are the intent verbatim; the author's PR description and commit messages are used only without one.
9. Every remaining `/no-comments` reference removed from `poteto-mode/` (router step list, `playbooks/autopilot-full.md`, `playbooks/autopilot-stack.md`, `playbooks/multi-phase-plan.md`, `references/codex-tools.md`), since the skill is not vendored (decision 4).
12. `babysit/SKILL.md` step 4: ready also requires the `spec-review` comment on the latest commit to read `act-on items: 0`. The review runs at most three rounds on one PR: a comment reading `round: 3 of 3` and `act-on items: 0` makes the PR review-ready even when the fix commits it names come after the reviewed commit, and an Ask item waits for the human, then is re-sorted and the comment rebuilt with `review-comment.sh <dir>` in the same round.
13. `playbooks/feature.md` step 2, `playbooks/bug-fix.md` step 3, `playbooks/refactoring.md` step 3 and `playbooks/perf-issue.md` step 3: the `architect` skip clause gains one sentence, that a cross-cutting diff (the Ticket playbook, step 5) never skips it. The delegation step of each (Feature step 4, Bug fix step 3, Refactoring step 5, Perf issue step 3) says the test is written from the scenario table before the implementation, one assertion per cell, and that a writer who cannot implement a cell as written stops and reports it (#89).
14. `architect/references/runner-prompt.md`: the first deliverable is the scenario table, then the contract, then the test list for a design with state (a file it reads or writes, exit codes, rounds, more than one actor), else the usage and signature sketch; a cell for an input outside the intended path reads "refused with the tool's own message" and is cut only after the refusal was run and seen; the orchestrator posts the synthesized deliverable on the ticket (#89).
15. `to-spec/SKILL.md` Testing Decisions: the scenario table is the shape for stateful work (#89).
```

### docs/M0-findings.md, lines 170-179 of 179

```
## Still open

- A review costs two sub-agent floors (about 92K) before any reading; one sub-agent per review, or the orchestrator running one axis, would halve it. Manuel's call (ticket #33).
- The React Native profile's Expo app under `vp check`, the fingerprint workflow on a real PR, and a simulator screenshot (first mobile project). The Python profile has now run end to end on GitHub.
- `vp migrate` on a brownfield repo (M8).
- `gh auth login` and `/setup-pstack` are human steps; `/factory-start` is M4.

2026-09-18. The factory checkout has no `.claude/agents/`, so the `pstack-<family>-<effort>` lanes named in `models.md` do not exist here; the Agent tool's `model` field (`fable`, `opus`) dispatched every lane of #76 and effort could not be set. A project made by `factory918 apply` gets the lanes from `template/.claude/agents/`.

2026-09-22. A sixth core document costs one CORE_DOCS tuple in tools/build_knowledge.py and no other code: build_core copies every core document except CONVERSATION-DIGEST.md into template/docs/factory918/, apply copies that directory, doctor checks only PHILOSOPHY and MANUAL. factory918.sh sync (0.3.0) bumps no VERSION and touches no network, against what SOURCES.md line 3 says; the code is the truth (#89).
```

### docs/knowledge/INDEX.md, lines 1-29 of 128

```
# Factory918 knowledge base: index

Read this file first; then grep; then read one section by range. Never read a file over 200 lines without `offset`/`limit`.
The literal transcript of the conversation that produced this system is not available; `core/CONVERSATION-DIGEST.md` is the substitute.

| file | what | lines | read when |
|---|---|---|---|
| `core/PHILOSOPHY.md` | Factory918: philosophy | 64 | First. Whenever the spec is silent. |
| `core/MANUAL.md` | Factory918: the manual | 174 | How to run the loop; what the human does at each point. |
| `core/DECISIONS.md` | Factory918: decisions | 93 | Before overriding any vendored skill; these win. |
| `core/GLOSSARY.md` | Factory918: glossary | 71 | A term in AGENTS.md, a playbook or a ticket is unclear. |
| `core/SCENARIO-TABLE.md` | Factory918: the scenario table | 88 | Designing or reviewing anything with state: a file, exit codes, more than one actor. |
| `core/CONVERSATION-DIGEST.md` | How Factory918 was arrived at | 53 | Why something was chosen, historically; the corrections. |
| `spec/FACTORY-SPEC-v2/01-preamble.md` | The Factory spec, v2 — (preamble) | 11 | Building or updating the factory itself. |
| `spec/FACTORY-SPEC-v2/02-change-log-v1-v2.md` | The Factory spec, v2 — Change log, v1 → v2 | 20 | Building or updating the factory itself. |
| `spec/FACTORY-SPEC-v2/03-change-log-v2-v2-1-2026-09-09-layout-only.md` | The Factory spec, v2 — Change log, v2 → v2.1 (2026-09-09, layout only) | 15 | Building or updating the factory itself. |
| `spec/FACTORY-SPEC-v2/04-0-instructions-to-the-implementing-model.md` | The Factory spec, v2 — 0. Instructions to the implementing model | 20 | Building or updating the factory itself. |
| `spec/FACTORY-SPEC-v2/05-1-what-manuel-needs-in-one-paragraph.md` | The Factory spec, v2 — 1. What Manuel needs, in one paragraph | 12 | Building or updating the factory itself. |
| `spec/FACTORY-SPEC-v2/06-2-the-central-question-does-pstack-build-the-ci-.md` | The Factory spec, v2 — 2. The central question: does pstack build the CI stack on its own? | 38 | Building or updating the factory itself. |
| `spec/FACTORY-SPEC-v2/07-3-the-system-end-to-end.md` | The Factory spec, v2 — 3. The system, end to end | 27 | Building or updating the factory itself. |
| `spec/FACTORY-SPEC-v2/08-4-repository-layout-of-the-factory.md` | The Factory spec, v2 — 4. Repository layout of the factory | 75 | Building or updating the factory itself. |
| `spec/FACTORY-SPEC-v2/09-5-skill-manifest.md` | The Factory spec, v2 — 5. Skill manifest | 61 | Building or updating the factory itself. |
| `spec/FACTORY-SPEC-v2/10-6-contradictions-between-the-vendored-skills-and.md` | The Factory spec, v2 — 6. Contradictions between the vendored skills, and how the factory resolves them | 24 | Building or updating the factory itself. |
| `spec/FACTORY-SPEC-v2/11-7-the-deterministic-layer-concretely.md` | The Factory spec, v2 — 7. The deterministic layer, concretely | 167 | Building or updating the factory itself. |
| `spec/FACTORY-SPEC-v2/12-7-the-deterministic-layer-concretely.md` | The Factory spec, v2 — 7. The deterministic layer, concretely | 128 | Building or updating the factory itself. |
| `spec/FACTORY-SPEC-v2/13-7-the-deterministic-layer-concretely.md` | The Factory spec, v2 — 7. The deterministic layer, concretely | 13 | Building or updating the factory itself. |
| `spec/FACTORY-SPEC-v2/14-8-factory918-sh-init-apply-doctor-update-sync-la.md` | The Factory spec, v2 — 8. `factory918.sh`: init, apply, doctor, update, sync, labels | 44 | Building or updating the factory itself. |
| `spec/FACTORY-SPEC-v2/15-9-milestones-for-the-implementing-model.md` | The Factory spec, v2 — 9. Milestones for the implementing model | 26 | Building or updating the factory itself. |
| `spec/FACTORY-SPEC-v2/16-10-decisions.md` | The Factory spec, v2 — 10. Decisions | 8 | Building or updating the factory itself. |
```

### docs/knowledge/INDEX.md, lines 109-128 of 128

```
| `notes/3-pstack/05-the-six-axes.md` | Research note: pstack — The six axes | 98 | Any pstack skill, playbook or principle in depth; the ports. |
| `notes/3-pstack/06-skill-catalog.md` | Research note: pstack — Skill catalog | 62 | Any pstack skill, playbook or principle in depth; the ports. |
| `notes/3-pstack/07-playbooks-list-name-when-it-s-chosen.md` | Research note: pstack — Playbooks list (name + when it's chosen) | 36 | Any pstack skill, playbook or principle in depth; the ports. |
| `notes/3-pstack/08-running-it-in-claude-code.md` | Research note: pstack — Running it in Claude Code | 34 | Any pstack skill, playbook or principle in depth; the ports. |
| `notes/3-pstack/09-what-theo-said-about-it.md` | Research note: pstack — What Theo said about it | 28 | Any pstack skill, playbook or principle in depth; the ports. |
| `notes/3-pstack/10-what-s-opinionated-friction-for-a-beginner-hones.md` | Research note: pstack — What's opinionated / friction for a beginner (honest) | 19 | Any pstack skill, playbook or principle in depth; the ports. |
| `notes/3-pstack/11-sources.md` | Research note: pstack — Sources | 44 | Any pstack skill, playbook or principle in depth; the ports. |
| `notes/4-ras-mic.md` | Research note: Ras Mic | 180 | Evidence-driven testing; loops. |
| `notes/6-deterministic-layer/01-preamble.md` | Research note: deterministic layer (verbatim config) — (preamble) | 16 | Exact CI YAML, lint rules, hook scripts from the four sources. |
| `notes/6-deterministic-layer/02-a-theo-t3-code-research-2-theo-t3code-excerpts.md` | Research note: deterministic layer (verbatim config) — A. Theo / T3 Code — `research/2-theo-t3code-excerpts/` | 160 | Exact CI YAML, lint rules, hook scripts from the four sources. |
| `notes/6-deterministic-layer/03-a-theo-t3-code-research-2-theo-t3code-excerpts.md` | Research note: deterministic layer (verbatim config) — A. Theo / T3 Code — `research/2-theo-t3code-excerpts/` | 119 | Exact CI YAML, lint rules, hook scripts from the four sources. |
| `notes/6-deterministic-layer/04-a-theo-t3-code-research-2-theo-t3code-excerpts.md` | Research note: deterministic layer (verbatim config) — A. Theo / T3 Code — `research/2-theo-t3code-excerpts/` | 32 | Exact CI YAML, lint rules, hook scripts from the four sources. |
| `notes/6-deterministic-layer/05-b-pstack-research-3-pstack-upstream-cursor-plugi.md` | Research note: deterministic layer (verbatim config) — B. pstack — `research/3-pstack/upstream-cursor-plugin/` | 227 | Exact CI YAML, lint rules, hook scripts from the four sources. |
| `notes/6-deterministic-layer/06-c-pstack-ports-open-pstack-pstack-claude-pstack-.md` | Research note: deterministic layer (verbatim config) — C. pstack ports — open-pstack, pstack-claude, pstack-skills | 141 | Exact CI YAML, lint rules, hook scripts from the four sources. |
| `notes/6-deterministic-layer/07-d-matt-pocock-research-1-matt-pocock-skills-repo.md` | Research note: deterministic layer (verbatim config) — D. Matt Pocock — `research/1-matt-pocock/skills-repo/` | 61 | Exact CI YAML, lint rules, hook scripts from the four sources. |
| `notes/6-deterministic-layer/08-template.md` | Research note: deterministic layer (verbatim config) — Template | 97 | Exact CI YAML, lint rules, hook scripts from the four sources. |
| `notes/6-deterministic-layer/09-e-ras-mic-https-github-com-michaelshimeles-skill.md` | Research note: deterministic layer (verbatim config) — E. Ras Mic — `https://github.com/michaelshimeles/skills/blob/513f8a2/` | 63 | Exact CI YAML, lint rules, hook scripts from the four sources. |
| `notes/6-deterministic-layer/10-cross-system-table.md` | Research note: deterministic layer (verbatim config) — Cross-system table | 26 | Exact CI YAML, lint rules, hook scripts from the four sources. |

119 files. `core/` is hand-maintained; everything else here is generated. Regenerate with `python3 tools/build_knowledge.py` after editing a core document, the spec, or anything under `research/`.
```

### docs/knowledge/core/DECISIONS.md, lines 1-1 of 93

```
<!-- lines: 93 | source: core/DECISIONS.md | part 1/1 | title: Factory918: decisions -->
```

### docs/knowledge/core/DECISIONS.md, lines 91-93 of 93

```
| P2 | Tool versions in CI | Pin every tool CI runs to an exact version, as a devDependency where the tool publishes one | `dlx` and `npx` resolve the latest version, so a rule engine or formatter can change under a project with no diff to show for it. Spec §0 rule 1 already says to pin what you install; this extends it to what CI fetches. First applied to `@ast-grep/cli` 0.45.3 in M0. |
| P24 | Overlap is not coupling; a go is a line that covers its own tickets | Two unblocked tickets relate three ways: dependent (`Blocked by`, off the frontier), disjoint in files (parallel branches off `main`), or overlapping in files (sequenced: one to merge-ready, the merge, then the next). Coupled work, a ticket that needs code an open PR introduces, stacks, and only on a go. Ticket step 1 runs `.claude/skills/poteto-mode/scripts/overlap.sh N` before branching: every open PR's head is fetched fresh and its own commits (its diff from the open PR it stacks on, else `origin/main`) are matched with the ticket body's backticked tokens as pathspecs (its `## Diff` section excluded), so a file, a directory, a glob or a file the PR creates all match; exit 0 prints `base: <ref>` to branch from, exit 1 stops and names the PR to merge first, exit 2 means the check could not run and stderr says why. A go is a line `<label>: #a #b ...` that `overlap.sh go "<label>" N...` appends to the gitignored `.claude/state/program`, written by the orchestrator when the human gives it (autopilot-stack step 3 runs it itself). A go covers a stack only when a line names the ticket and, for every overlapping PR, the ticket that PR closes; so a line a dead program left behind covers nothing outside its own tickets' open PRs and needs no removal. Under a cover the base is the overlapping PR's head, the lowest-numbered when siblings overlap, the containing one when one contains the other; step 8's `--diff` run records the shared paths as the PR body's `## Overlap` section | Ticket #42, Manuel: "working a ticket to completion before automatically moving on"; the #16 to #22 stack was built on a seven-re-reviews mis-estimate (ledger 2026-09-17). First run (PR #87, closed): three review rounds redesigned the matcher three times; the second run designed from a scenario table Manuel approved 2026-09-21 as the ticket's Testing decisions. Rejected: a ticket label as the go (outlives the program), a line pasted into each lane's brief (a forgotten paste blocks a lane), a `done` step (a crash skips it), the script under the factory918 skill (every later edit cross-cutting). |
| P25 | The design artifact on the ticket | For a design with state (a file it reads or writes, exit codes, rounds, or more than one actor) the architect step's first deliverable is a scenario table, appended to the ticket under `## Testing decisions` before implementation, first line `Posted by the agent <date>` (or `Approved by <name> <date>` when the human approved it first); the usage and signature sketch goes under `## Design` for stateless code that crosses a function boundary; prose has its criteria. Posting is the record: the human edits the ticket if the table is wrong, and a stop is asked for only with `/architect with checkpoint`. The table is the test, one assertion per cell; a cell for an input outside the intended path reads "refused with the tool's own message" and is cut only after the refusal was run and seen. Choices made in #89: the rule lives in Ticket step 6 (no renumbering, since "Ticket step 5" is quoted in four patches and `review-brief.sh`); the page is a sixth core document so projects get it; the to-spec patch follows the README path | Ticket #89: the agent's "It is a general design tool, not a #42 thing" and Manuel's "I agree with your choice completely" on posting as the record. PR #87's three rounds redesigned the core three times; PR #92's found 2, 1, 2 items and no cell changed. 2026-09-22. |
```

### docs/knowledge/core/SCENARIO-TABLE.md, added, 88 lines; the diff carries it whole: no text

### patches/mattpocock/to-spec/SKILL.md.patch, whole, 10 lines

```
--- a/to-spec/SKILL.md
+++ b/to-spec/SKILL.md
@@ -63,6 +63,7 @@
 - A description of what makes a good test (only test external behavior, not implementation details)
 - Which modules will be tested
 - Prior art for the tests (i.e. similar types of tests in the codebase)
+- For stateful work (a file read or written, exit codes, more than one actor), the shape is the scenario table: situations down the side, the shape of the input across the top, and in every cell what is printed, the exit code and what the caller does next. The table is the test list, one assertion per cell. It is a decision, not a code snippet, so the rule above does not exclude it.
 
 ## Out of Scope
 
```

### patches/pstack/architect/references/runner-prompt.md.patch, whole, 17 lines

```
--- a/architect/references/runner-prompt.md
+++ b/architect/references/runner-prompt.md
@@ -2,8 +2,13 @@
 
 The orchestrator passes this file through to every parallel candidate runner during Phase B and fills in the variable inputs around it: the task, the Phase A grounding artifacts, the isolated working directory, and the path to write outputs. The working directory is a git worktree when available, otherwise a per-runner subdirectory under the sketch dir; what matters is independence between candidates.
 
-You are producing one candidate design in architect's parallel exploration. Read the **architect** skill in full first; that's the workflow you're inside. Output a candidate design package: type sketch, function signatures, module map, and prose rationale shaped per [`rationale-template.md`](rationale-template.md).
+You are producing one candidate design in architect's parallel exploration. Read the **architect** skill in full first; that's the workflow you're inside. Output a candidate design package. Its first deliverable depends on what the design has.
 
+- With state (a file it reads or writes, exit codes, rounds, or more than one actor): a scenario table, then the contract derived from it, then the test list. Situations go down the side (the states the world can be in: no record, a stale ref, a failing tool, a body with no token), the shape of the input across the top (none, one, siblings, one containing the other, the caller's own), and every cell says what is printed, the exit code and what the caller does next. A legend defines the cell vocabulary once. The contract defines every term the cells use. The test list has one assertion per cell, in the order the cells are written, each naming the fixture state it needs. A cell for an input outside the intended path reads "refused with the tool's own message" and costs no code. Cut such a cell only after the refusal was run and seen; an assumption about a tool's failure mode is a claim until then.
+- Without state, crossing a function boundary: the usage and signature sketch, the caller's usage first, then the types and signatures (the discipline below).
+
+Then the type sketch, function signatures, module map, and prose rationale shaped per [`rationale-template.md`](rationale-template.md). The orchestrator appends the synthesized first deliverable to the ticket before implementation, a table under `## Testing decisions`, a sketch under `## Design` (the Ticket playbook, step 6); the writer, the reviewer and the human read it there.
+
 Apply the following discipline. The orchestrator compares candidates on these axes to pick a base.
 
 - Caller's usage first. Write the README-style usage and two or three real call sites before the types, then derive the type sketch from them. The usage is the spec; the two must agree, so reconcile the sketch to the usage, not the reverse.
```

### patches/pstack/poteto-mode/playbooks/bug-fix.md.patch, whole, 11 lines

```
--- a/poteto-mode/playbooks/bug-fix.md
+++ b/poteto-mode/playbooks/bug-fix.md
@@ -6,7 +6,7 @@
 
 1. Reproduce it yourself on the matching surface via the driver skill (`run` for CLIs/TUIs, `verify` for UIs) (Non-negotiables). Don't hand the repro to the user. A debug or instrumentation protocol that says to ask the user does not override this; you drive the instrumented runtime. Ask the user only with a stated, specific reason the control surface cannot reach the target, and only after driving it as far as it goes. Won't reproduce directly, force it: synthesize the trigger, tighten conditions, or instrument until it fires. A bug you can't reproduce, you can't prove fixed.
 2. Binary-search the cause. Form the candidate hypotheses, then rule them out until one survives. Seed them with `how` over the affected subsystem and the **why** skill for regression history. Each pass, take the split that cuts the most remaining problem space, get runtime evidence, eliminate. When program state is unclear, add instrumentation or logging and read it as the code runs. Don't guess. Drive a long or stubborn hunt with Claude Code's `loop` command. Confirm the surviving *mechanism* with runtime evidence before the step-3 architect/interrogate fan-out; a design grounded on a plausible-but-unconfirmed cause can be unanimously wrong while the real cause sits one subsystem over.
-3. Plan the fix. If it crosses a function boundary, `architect` first. Delegate implementation through provider dispatch using your configured bug-fix descriptor (default `codex:gpt-5.6-sol@max`) with `isolated-write`, a dedicated worktree, and a specific scope; review the diff.
+3. Plan the fix. If it crosses a function boundary, `architect` first; a cross-cutting diff (Ticket step 5) never skips it. Delegate implementation through provider dispatch using your configured bug-fix descriptor (default `codex:gpt-5.6-sol@max`) with `isolated-write`, a dedicated worktree, and a specific scope; review the diff. The brief carries the ticket's design artifact (Ticket step 6). When it is a scenario table, the writer writes the test from the table before the implementation, one assertion per cell in the table's order, and the commit order shows it; a writer that cannot implement a cell as written stops and reports the cell, and never fills it in.
 4. Verify on the same surface; the original repro now passes. "Inconclusive" or wrong-surface is not a pass; flag it. Unit tests show branch behavior, not bug absence.
 5. Stage the commits so the failing repro lands before the fix in git history; the diff tells the story. See the **tdd** skill for the failing-test-first cadence when the bug has a cheap local test path; skip it when the test would be expensive, integration-heavy, or unclear.
    This is the canonical **sequence-verifiable-units** principle skill, the failing test first and the fix on top.
```

### patches/pstack/poteto-mode/playbooks/feature.md.patch, whole, 18 lines

```
--- a/poteto-mode/playbooks/feature.md
+++ b/poteto-mode/playbooks/feature.md
@@ -3,13 +3,13 @@
 **You own the design. Plan, review, verify.** Delegate implementation; stay in the lead.
 
 1. `how` over the affected subsystem.
-2. `architect` for parallel design exploration. Skipping stays as `architect skipped: <reason>`; do not fold the design decision silently into implementation.
+2. `architect` for parallel design exploration. Skipping stays as `architect skipped: <reason>`, not accepted for a cross-cutting diff (Ticket step 5); do not fold the design decision silently into implementation.
 3. Write the throughput checkpoint as four todo items. A dimension that genuinely does not apply (single file, no fan-out) keeps its item with `n/a: <reason>` rather than being dropped:
    - **Blocking first steps.** Gates run before fan-out.
    - **Independent workstreams.** Disjoint files, services, or layers parallelize. Shared writes serialize.
    - **Shared mutable state.** Default to splitting the target (the **separate-before-serializing-shared-state** principle skill). Serialize only for real invariants.
    - **Smallest safe decomposition.** If one worker is best, name why.
-4. Delegate code-writing through provider dispatch using your configured feature descriptor (default `grok:grok-4.6@xhigh`) with `isolated-write`, a dedicated worktree, and a specific scope (file paths, named data shape and its organizing structure per **principle-model-the-domain** — a state machine over scattered booleans, a table/registry over branching, a typed model over repeated shape assumptions, chosen before the delegate writes logic — and success criteria); review its diff yourself. When the implementation admits multiple valid shapes (error handling, abstraction layer, test structure), delegate via the **arena** skill instead so the runners surface the alternatives and the cross-judge guards the pick. Mandatory: no skip-with-reason escape, and Laziness Protocol does not override it (the gain is review separation, not lines saved). The delegate owns the diff directly and never waits on or launches a nested agent. Comments per **Comments**. Surgical edits, re-ground against the source for upstream-derived files. Port shared-primitive improvements to all consumers and verify each. Commit liberally.
+4. Delegate code-writing through provider dispatch using your configured feature descriptor (default `grok:grok-4.6@xhigh`) with `isolated-write`, a dedicated worktree, and a specific scope (file paths, named data shape and its organizing structure per **principle-model-the-domain** — a state machine over scattered booleans, a table/registry over branching, a typed model over repeated shape assumptions, chosen before the delegate writes logic — and success criteria); review its diff yourself. The brief carries the ticket's design artifact (Ticket step 6). When it is a scenario table, the writer writes the test from the table before the implementation, one assertion per cell in the table's order, and the commit order shows it; a writer that cannot implement a cell as written stops and reports the cell, and never fills it in. When the implementation admits multiple valid shapes (error handling, abstraction layer, test structure), delegate via the **arena** skill instead so the runners surface the alternatives and the cross-judge guards the pick. Mandatory: no skip-with-reason escape, and Laziness Protocol does not override it (the gain is review separation, not lines saved). The delegate owns the diff directly and never waits on or launches a nested agent. Comments per **Comments**. Surgical edits, re-ground against the source for upstream-derived files. Port shared-primitive improvements to all consumers and verify each. Commit liberally.
 5. Verify on the matching surface. "Inconclusive" or wrong-surface is not a pass; flag it.
 6. Rebase into small, ordered commits; stack follow-ups.
    Use the **sequence-verifiable-units** principle skill, building, verifying, and committing each small unit before the next.
```

### patches/pstack/poteto-mode/playbooks/perf-issue.md.patch, whole, 11 lines

```
--- a/poteto-mode/playbooks/perf-issue.md
+++ b/poteto-mode/playbooks/perf-issue.md
@@ -13,7 +13,7 @@
    - **Redundancy.** The wait hangs on one slow instance or attempt. Duplicate the work (replicas, hedged requests, speculative execution) and take the fastest result. This trades extra load for lower tail latency, so the trace has to show the wait dominates and the system has headroom; duplication without that tradeoff only adds load.
    - **Lazy evaluation.** Cost lands on results that are never used or not needed yet (eager init on the boot path, rendering offscreen items). Defer the work until first use.
    - **Scheduling.** The work must happen, but not during the interactive moment. Move it to where nobody is waiting: idle callbacks, a background warmup after boot, precompute before the user arrives, cleanup after the frame commits. Distinct from Lazy (later-when-needed): Scheduling often runs the work *earlier* than the hot moment, or in its shadow. The win is perceived latency, so measure the interactive path, not total work done.
-3. Plan the fix from the trace. If it crosses a function boundary, `architect` first. Delegate implementation through provider dispatch using your configured perf-issue descriptor (default `codex:gpt-5.6-sol@max`) with `isolated-write` in a dedicated worktree; review the diff. Capture a post-fix trace.
+3. Plan the fix from the trace. If it crosses a function boundary, `architect` first; a cross-cutting diff (Ticket step 5) never skips it. Delegate implementation through provider dispatch using your configured perf-issue descriptor (default `codex:gpt-5.6-sol@max`) with `isolated-write` in a dedicated worktree; review the diff. The brief carries the ticket's design artifact (Ticket step 6). When it is a scenario table, the writer writes the test from the table before the implementation, one assertion per cell in the table's order, and the commit order shows it; a writer that cannot implement a cell as written stops and reports the cell, and never fills it in. Capture a post-fix trace.
    Apply the **sequence-verifiable-units** principle skill, verifying each attempt before trying the next.
 4. Parse and compare the artifacts (JSON to sqlite, diff). "Inconclusive" or wrong-surface is not a pass; flag it.
 5. Cite the measurement in the PR.
```

### patches/series, whole, 19 lines

```
pstack/poteto-mode/SKILL.md.patch
pstack/poteto-mode/playbooks/autopilot-full.md.patch
pstack/poteto-mode/playbooks/autopilot-stack.md.patch
pstack/poteto-mode/playbooks/babysit.md.patch
pstack/babysit/SKILL.md.patch
pstack/poteto-mode/playbooks/multi-phase-plan.md.patch
pstack/poteto-mode/playbooks/opening-a-pr.md.patch
pstack/poteto-mode/playbooks/bug-fix.md.patch
pstack/poteto-mode/playbooks/feature.md.patch
pstack/poteto-mode/playbooks/perf-issue.md.patch
pstack/poteto-mode/playbooks/refactoring.md.patch
pstack/architect/references/runner-prompt.md.patch
pstack/poteto-mode/references/codex-tools.md.patch
pstack/poteto-mode/scripts/runner/model-matrix.test.ts.patch
pstack/interrogate/SKILL.md.patch
pstack/setup-pstack/SKILL.md.patch
pstack/unslop/SKILL.md.patch
mattpocock/spec-review.SKILL.md.patch
mattpocock/to-spec/SKILL.md.patch
```

### template/.agents/skills/architect/references/runner-prompt.md, whole, 25 lines

```
# Architect runner prompt

The orchestrator passes this file through to every parallel candidate runner during Phase B and fills in the variable inputs around it: the task, the Phase A grounding artifacts, the isolated working directory, and the path to write outputs. The working directory is a git worktree when available, otherwise a per-runner subdirectory under the sketch dir; what matters is independence between candidates.

You are producing one candidate design in architect's parallel exploration. Read the **architect** skill in full first; that's the workflow you're inside. Output a candidate design package. Its first deliverable depends on what the design has.

- With state (a file it reads or writes, exit codes, rounds, or more than one actor): a scenario table, then the contract derived from it, then the test list. Situations go down the side (the states the world can be in: no record, a stale ref, a failing tool, a body with no token), the shape of the input across the top (none, one, siblings, one containing the other, the caller's own), and every cell says what is printed, the exit code and what the caller does next. A legend defines the cell vocabulary once. The contract defines every term the cells use. The test list has one assertion per cell, in the order the cells are written, each naming the fixture state it needs. A cell for an input outside the intended path reads "refused with the tool's own message" and costs no code. Cut such a cell only after the refusal was run and seen; an assumption about a tool's failure mode is a claim until then.
- Without state, crossing a function boundary: the usage and signature sketch, the caller's usage first, then the types and signatures (the discipline below).

Then the type sketch, function signatures, module map, and prose rationale shaped per [`rationale-template.md`](rationale-template.md). The orchestrator appends the synthesized first deliverable to the ticket before implementation, a table under `## Testing decisions`, a sketch under `## Design` (the Ticket playbook, step 6); the writer, the reviewer and the human read it there.

Apply the following discipline. The orchestrator compares candidates on these axes to pick a base.

- Caller's usage first. Write the README-style usage and two or three real call sites before the types, then derive the type sketch from them. The usage is the spec; the two must agree, so reconcile the sketch to the usage, not the reverse.
- Data structures first. Get the core types right and the code becomes obvious. Trace each dominant access pattern through the proposed structure; if the answer is "we'll add a map / index / cache later," the structure is wrong.
- Interface depth. Compare the capability hidden behind the public surface relative to the size of that surface. Prefer a simple interface that pulls complexity into the callee, even when the implementation becomes less simple. Do not put transport or wire types on the public surface; parse into domain types behind the interface.
- Shared state: if two actors might both write, ask "what happens?" If the answer isn't "nothing," default to per-actor state with a merge at the read boundary, per the **separate-before-serializing-shared-state** principle skill.
- Make boundaries visible. `not implemented` errors for bodies, `// TODO` pseudocode for tricky logic, doc comments stating intent and invariants. A reader should trace data from input to output by reading types and signatures alone.
- Encode invariants in types: hard-to-misuse types > runtime checks > prose comments, per the **encode-lessons-in-structure** principle skill.
- Validate at boundaries, trust types inside, per the **boundary-discipline** principle skill. Business logic as pure functions; the shell stays thin.
- Single source of truth per invariant. Derive instead of sync.
- Idempotent state transitions where applicable, per the **make-operations-idempotent** principle skill. Ask what happens if the operation runs twice or crashes halfway.
- Short call chains. If tracing the flow needs more than three files, flatten the hierarchy, per the **laziness-protocol** and **minimize-reader-load** principle skills.

You are one of several runners, each on a different model. Produce the best design your model can make; don't hedge against the others. Differences between candidates are the signal used to pick a base and graft. Converging on a safe-looking middle defeats the exploration.
```

### template/.agents/skills/knowledge/SKILL.md, whole, 26 lines

```
---
name: knowledge
description: Look something up in the Factory918 knowledge base without reading whole files. Use when unsure why this system does something, when a term in AGENTS.md, a playbook or a ticket is unclear, when two vendored skills seem to disagree, or when the user asks how Factory918 works or where a rule came from.
argument-hint: "The question, in a few words"
---

# Knowledge lookup

The corpus is large (the four source systems, six research notes, three reference pages, the spec, the philosophy). Reading any of it whole would spend the context window on things you do not need. Follow this procedure exactly.

## Where the corpus is

`$FACTORY918_HOME/docs/knowledge` if that variable is set; else `~/.factory918/docs/knowledge`; else this project's `docs/factory918` (slim: philosophy, manual, decisions, glossary and the scenario table only, with no header or mini-TOC, so take line numbers from grep and `wc -l`). Call it `$KB`.

## Procedure

1. **Index first.** Read `$KB/INDEX.md` whole; it is the one file meant to be read whole. Every file is listed with its purpose, its line count and when to read it.
2. **Grep before you read.** `rg -n -i "<two or three terms>" $KB --glob '*.md' | head -40`. Prefer terms that would appear in a heading. If the question is about a term, try `GLOSSARY.md` and `DECISIONS.md` first.
3. **Open the mini-TOC, not the file.** Every chunked file begins with a header block: `<!-- lines: N -->` and a `## Contents` list with line numbers per section. Read the first 30 lines of the candidate file only.
4. **Read the section, in a range.** Use the Read tool with `offset` and `limit` from the TOC. Hard rule: never read more than 150 lines in one call, and never read a file whose header says more than 200 lines without a range.
5. **Answer with a citation.** Give the answer in a few sentences and cite `path:line`. If two sources disagree, say which one Factory918 follows and why (`DECISIONS.md` wins, then `PHILOSOPHY.md` §"The beliefs that decide things").
6. **Stop.** Do not summarise the file, do not read adjacent sections "for context," do not read the whole conversation digest to answer a small question.

## When the corpus does not answer

Say so. Then apply the procedure in `PHILOSOPHY.md` §"How to decide when the spec is silent" and record the outcome under "Provisional" in `DECISIONS.md`.
```

### template/.agents/skills/poteto-mode/playbooks/bug-fix.md, whole, 17 lines

```
### Bug fix

**You own this task. Plan, review, verify.** Delegate investigation and the fix to subagents, stay in the lead.

Be scientific. Every shipped line traces to runtime evidence. Belt-and-suspenders that "might help" is a hypothesis, not a fix; it does not ship. When evidence refutes a hypothesis, revert what it motivated. The smallest change the evidence justifies ships, nothing more. Same discipline for Perf, where the evidence is the trace.

1. Reproduce it yourself on the matching surface via the driver skill (`run` for CLIs/TUIs, `verify` for UIs) (Non-negotiables). Don't hand the repro to the user. A debug or instrumentation protocol that says to ask the user does not override this; you drive the instrumented runtime. Ask the user only with a stated, specific reason the control surface cannot reach the target, and only after driving it as far as it goes. Won't reproduce directly, force it: synthesize the trigger, tighten conditions, or instrument until it fires. A bug you can't reproduce, you can't prove fixed.
2. Binary-search the cause. Form the candidate hypotheses, then rule them out until one survives. Seed them with `how` over the affected subsystem and the **why** skill for regression history. Each pass, take the split that cuts the most remaining problem space, get runtime evidence, eliminate. When program state is unclear, add instrumentation or logging and read it as the code runs. Don't guess. Drive a long or stubborn hunt with Claude Code's `loop` command. Confirm the surviving *mechanism* with runtime evidence before the step-3 architect/interrogate fan-out; a design grounded on a plausible-but-unconfirmed cause can be unanimously wrong while the real cause sits one subsystem over.
3. Plan the fix. If it crosses a function boundary, `architect` first; a cross-cutting diff (Ticket step 5) never skips it. Delegate implementation through provider dispatch using your configured bug-fix descriptor (default `codex:gpt-5.6-sol@max`) with `isolated-write`, a dedicated worktree, and a specific scope; review the diff. The brief carries the ticket's design artifact (Ticket step 6). When it is a scenario table, the writer writes the test from the table before the implementation, one assertion per cell in the table's order, and the commit order shows it; a writer that cannot implement a cell as written stops and reports the cell, and never fills it in.
4. Verify on the same surface; the original repro now passes. "Inconclusive" or wrong-surface is not a pass; flag it. Unit tests show branch behavior, not bug absence.
5. Stage the commits so the failing repro lands before the fix in git history; the diff tells the story. See the **tdd** skill for the failing-test-first cadence when the bug has a cheap local test path; skip it when the test would be expensive, integration-heavy, or unclear.
   This is the canonical **sequence-verifiable-units** principle skill, the failing test first and the fix on top.
6. Run **Opening a PR**.

Investigation fans out `how` + `why` as parallel subagents.

**Reply:** what was broken, root cause, fix, how you verified. Quote the decisive failing and passing output, trimmed to the assertion and the counts.
```

### template/.agents/skills/poteto-mode/playbooks/feature.md, whole, 21 lines

```
### Feature

**You own the design. Plan, review, verify.** Delegate implementation; stay in the lead.

1. `how` over the affected subsystem.
2. `architect` for parallel design exploration. Skipping stays as `architect skipped: <reason>`, not accepted for a cross-cutting diff (Ticket step 5); do not fold the design decision silently into implementation.
3. Write the throughput checkpoint as four todo items. A dimension that genuinely does not apply (single file, no fan-out) keeps its item with `n/a: <reason>` rather than being dropped:
   - **Blocking first steps.** Gates run before fan-out.
   - **Independent workstreams.** Disjoint files, services, or layers parallelize. Shared writes serialize.
   - **Shared mutable state.** Default to splitting the target (the **separate-before-serializing-shared-state** principle skill). Serialize only for real invariants.
   - **Smallest safe decomposition.** If one worker is best, name why.
4. Delegate code-writing through provider dispatch using your configured feature descriptor (default `grok:grok-4.6@xhigh`) with `isolated-write`, a dedicated worktree, and a specific scope (file paths, named data shape and its organizing structure per **principle-model-the-domain** — a state machine over scattered booleans, a table/registry over branching, a typed model over repeated shape assumptions, chosen before the delegate writes logic — and success criteria); review its diff yourself. The brief carries the ticket's design artifact (Ticket step 6). When it is a scenario table, the writer writes the test from the table before the implementation, one assertion per cell in the table's order, and the commit order shows it; a writer that cannot implement a cell as written stops and reports the cell, and never fills it in. When the implementation admits multiple valid shapes (error handling, abstraction layer, test structure), delegate via the **arena** skill instead so the runners surface the alternatives and the cross-judge guards the pick. Mandatory: no skip-with-reason escape, and Laziness Protocol does not override it (the gain is review separation, not lines saved). The delegate owns the diff directly and never waits on or launches a nested agent. Comments per **Comments**. Surgical edits, re-ground against the source for upstream-derived files. Port shared-primitive improvements to all consumers and verify each. Commit liberally.
5. Verify on the matching surface. "Inconclusive" or wrong-surface is not a pass; flag it.
6. Rebase into small, ordered commits; stack follow-ups.
   Use the **sequence-verifiable-units** principle skill, building, verifying, and committing each small unit before the next.
7. If the design is contested, `interrogate` before shipping.
8. Run **Opening a PR**.

Code-coupled work (one feature, one migration) goes to a single owner with the checkpoint inline; that owner fans out internally after the blocking phase. Parent-level fan-out is for slices that produce independent artifacts (audits, cross-subsystem investigations, competing experiments). Rewrite the checkpoint at phase boundaries; spawn a fresh owner rather than chaining interrupts.

**Reply:** what you built, what you chose and why, open decisions. Tables for design alternatives.
```

### template/.agents/skills/poteto-mode/playbooks/perf-issue.md, whole, 24 lines

```
### Perf issue

**You own the measurement story. Plan, review, verify the numbers.** Tie every fix to a measurement, don't read source instead of measuring.

1. Capture a baseline trace via the driver skill (`run` for CLIs/TUIs, `verify` for UIs).
2. `how` to ground hypotheses; don't claim a perf ceiling without running it first.
   Most fixes come from eight strategy families. Use them as hypothesis generators, not a checklist. A family earns an attempt only when the trace shows the signal it names, and a focused fix for the dominant cost beats applying all eight.
   - **Elimination.** The cheapest work is work that doesn't run. Before optimizing the hot path, ask whether it needs to exist: a computation nobody consumes, a feature gate that's always off for this user, a sync that redundantly mirrors state, a legacy path kept "just in case". The trace shows what's slow, never that it's deletable, so this family needs the `how` pass, not the profiler. Deleting the work beats every other family when it applies.
   - **Divide and conquer.** The dominant cost scales with input size. Split the work so each piece touches less (chunk, shard, prune the search space) or so independent pieces run in parallel.
   - **Caching.** The same computation or fetch repeats on identical inputs. Store and reuse the result; name what invalidates it before claiming the win.
   - **Indirection.** The hot path does expensive work a cheaper intermediate could absorb: an index instead of a scan, a queue that shifts work off the interactive thread, a handle that lets a cheaper implementation swap in. Add the hop only when it removes more from the critical path than it adds; a layer that sits on the hot path without removing work is pure cost.
   - **Batching.** Many small operations each pay a fixed overhead (RPC, query, syscall, draw call). Coalesce them to pay the overhead once per batch.
   - **Redundancy.** The wait hangs on one slow instance or attempt. Duplicate the work (replicas, hedged requests, speculative execution) and take the fastest result. This trades extra load for lower tail latency, so the trace has to show the wait dominates and the system has headroom; duplication without that tradeoff only adds load.
   - **Lazy evaluation.** Cost lands on results that are never used or not needed yet (eager init on the boot path, rendering offscreen items). Defer the work until first use.
   - **Scheduling.** The work must happen, but not during the interactive moment. Move it to where nobody is waiting: idle callbacks, a background warmup after boot, precompute before the user arrives, cleanup after the frame commits. Distinct from Lazy (later-when-needed): Scheduling often runs the work *earlier* than the hot moment, or in its shadow. The win is perceived latency, so measure the interactive path, not total work done.
3. Plan the fix from the trace. If it crosses a function boundary, `architect` first; a cross-cutting diff (Ticket step 5) never skips it. Delegate implementation through provider dispatch using your configured perf-issue descriptor (default `codex:gpt-5.6-sol@max`) with `isolated-write` in a dedicated worktree; review the diff. The brief carries the ticket's design artifact (Ticket step 6). When it is a scenario table, the writer writes the test from the table before the implementation, one assertion per cell in the table's order, and the commit order shows it; a writer that cannot implement a cell as written stops and reports the cell, and never fills it in. Capture a post-fix trace.
   Apply the **sequence-verifiable-units** principle skill, verifying each attempt before trying the next.
4. Parse and compare the artifacts (JSON to sqlite, diff). "Inconclusive" or wrong-surface is not a pass; flag it.
5. Cite the measurement in the PR.
6. Run **Opening a PR**.

For sustained improvement against a metric rather than a one-off fix, use the Hillclimb playbook (`playbooks/hillclimb.md`).

**Reply:** baseline number, post-fix number, delta, artifact path.
```

### template/.agents/skills/poteto-mode/playbooks/refactoring.md, whole, 16 lines

```
### Refactoring

**You own the contract. The structure changes; the behavior does not.** For "refactor", "rename", "extract", "inline", "dedupe", "restructure", "move this module", "tidy up this area". Distinct from Feature, which adds behavior, and Bug fix, which corrects it.

A refactor that smuggles in a behavior change loses its safety net. If the cleanup reveals a missing feature or a real bug, split it out and ship the structural change first against the pinned contract. A redesign is allowed, but name it and route to Feature. Large or cross-cutting structural work (a migration across many call sites, a coordinated reshape of many subsystems) belongs to the **figure-it-out** skill; this playbook is the focused-to-medium change.

1. Pin the behavior contract first. Run the **how** skill over the affected subsystem to learn the contract, then write a characterization test, snapshot, or equivalence harness that captures current behavior before any structure moves. The harness makes "refactor" a checkable claim (**principle-prove-it-works**). If the area has no coverage, write the pin before touching structure. Type check and lint are not a pin.
2. Name the structure the code is missing per **principle-model-the-domain**: a state machine over scattered booleans, a table or registry over spread-out branching, a typed model over repeated shape assumptions, a reducer over ad hoc mutations. Boring code stays when the shape is already clear and local; the reshape must delete branches or invalid states, not add indirection.
3. Name the target shape. State what the module layout, types, and call graph should be if built today (**principle-foundational-thinking**, **principle-redesign-from-first-principles**). If the target crosses a function boundary, run the **architect** skill for parallel design exploration of the shape before the move; a cross-cutting diff (Ticket step 5) never skips it.
4. Subtract before you add. Delete dead weight, collapse one-caller wrappers, drop redundant validators, and remove orphan references before introducing the new shape (**principle-subtract-before-you-add**). The smallest change that reaches the target shape ships (**principle-laziness-protocol**). A speculative cleanup that "might help" gets reverted, not left to ride.
5. Move in small behavior-preserving steps, each keeping the pin green. For API reshapes, migrate every caller and delete the old API in the same wave (**principle-migrate-callers-then-delete-legacy-apis**). No compatibility shims, no parallel old-and-new paths. Spot-check every rename against the actual files; renames silently miss usages in strings, prose, and back-references. Delegate the mechanical edits through provider dispatch using your configured refactoring descriptor (default `grok:grok-4.6@xhigh`) with `isolated-write`, a dedicated worktree, and a specific scope (file paths, the names being moved, the behavior to hold); review the diff yourself. The brief carries the ticket's design artifact (Ticket step 6). When it is a scenario table, the writer writes the test from the table before the implementation, one assertion per cell in the table's order, and the commit order shows it; a writer that cannot implement a cell as written stops and reports the cell, and never fills it in.
6. Prove behavior is unchanged on the real artifact, not "it compiles" (**principle-prove-it-works**). For larger reshapes, run an equivalence check: a script that diffs old-vs-new outputs, a recorded baseline replayed against the new code, or a smoke run on the matching surface via the relevant control skill. Own the verification yourself; do not trust a delegate's "looks good" summary.
7. Confirm the change earns its place. The success measure is reduced reader load (**principle-minimize-reader-load**): fewer layers between question and answer, less hidden state, fewer indirections without a second consumer. If the diff does not lower reader load somewhere, revert it.
8. Rebase into small ordered commits that tell the story. A subtraction commit, then the reshape, then any follow-on cleanup, so a single revert undoes one slice. Shape them with the **sequence-verifiable-units** principle skill, so each behavior-preserving slice stays green before the next. Run **Opening a PR**.

**Reply:** the structure that changed, the pin you held it against, the equivalence proof, the reader-load delta, what shipped and what got reverted. No new behavior.
```

### template/.agents/skills/to-spec/SKILL.md, whole, 76 lines

```
---
name: to-spec
description: "Turn the current conversation into a spec and publish it to the project issue tracker: no interview, just synthesis of what you've already discussed."
disable-model-invocation: true
---

This skill takes the current conversation context and codebase understanding and produces a spec. Do NOT interview the user; just synthesize what you already know.

The issue tracker and triage label vocabulary should have been provided to you. If not, tell the user to run `/setup-matt-pocock-skills`.

## Process

1. Explore the repo to understand the current state of the codebase, if you haven't already. Use the project's domain glossary vocabulary throughout the spec, and respect any ADRs in the area you're touching.

2. Sketch out the seams at which you're going to test the feature. Existing seams should be preferred to new ones. Use the highest seam possible. If new seams are needed, propose them at the highest point you can. The fewer seams across the codebase, the better - the ideal number is one.

Check with the user that these seams match their expectations.

3. Write the spec using the template below, then publish it to the project issue tracker. Apply the `ready-for-agent` triage label - no need for additional triage.

<spec-template>

## Problem Statement

The problem that the user is facing, from the user's perspective.

## Solution

The solution to the problem, from the user's perspective.

## User Stories

A LONG, numbered list of user stories. Each user story should be in the format of:

1. As an <actor>, I want a <feature>, so that <benefit>

<user-story-example>
1. As a mobile bank customer, I want to see balance on my accounts, so that I can make better informed decisions about my spending
</user-story-example>

This list of user stories should be extremely extensive and cover all aspects of the feature.

## Implementation Decisions

A list of implementation decisions that were made. This can include:

- The modules that will be built/modified
- The interfaces of those modules that will be modified
- Technical clarifications from the developer
- Architectural decisions
- Schema changes
- API contracts
- Specific interactions

Do NOT include specific file paths or code snippets. They may end up being outdated very quickly.

Exception: if a prototype produced a snippet that encodes a decision more precisely than prose can (state machine, reducer, schema, type shape), inline it within the relevant decision and note briefly that it came from a prototype. Trim to the decision-rich parts, not a working demo, just the important bits.

## Testing Decisions

A list of testing decisions that were made. Include:

- A description of what makes a good test (only test external behavior, not implementation details)
- Which modules will be tested
- Prior art for the tests (i.e. similar types of tests in the codebase)
- For stateful work (a file read or written, exit codes, more than one actor), the shape is the scenario table: situations down the side, the shape of the input across the top, and in every cell what is printed, the exit code and what the caller does next. The table is the test list, one assertion per cell. It is a decision, not a code snippet, so the rule above does not exclude it.

## Out of Scope

A description of the things that are out of scope for this spec.

## Further Notes

Any further notes about the feature.

</spec-template>
```

### template/docs/factory918/DECISIONS.md, lines 83-85 of 85

```
| P2 | Tool versions in CI | Pin every tool CI runs to an exact version, as a devDependency where the tool publishes one | `dlx` and `npx` resolve the latest version, so a rule engine or formatter can change under a project with no diff to show for it. Spec §0 rule 1 already says to pin what you install; this extends it to what CI fetches. First applied to `@ast-grep/cli` 0.45.3 in M0. |
| P24 | Overlap is not coupling; a go is a line that covers its own tickets | Two unblocked tickets relate three ways: dependent (`Blocked by`, off the frontier), disjoint in files (parallel branches off `main`), or overlapping in files (sequenced: one to merge-ready, the merge, then the next). Coupled work, a ticket that needs code an open PR introduces, stacks, and only on a go. Ticket step 1 runs `.claude/skills/poteto-mode/scripts/overlap.sh N` before branching: every open PR's head is fetched fresh and its own commits (its diff from the open PR it stacks on, else `origin/main`) are matched with the ticket body's backticked tokens as pathspecs (its `## Diff` section excluded), so a file, a directory, a glob or a file the PR creates all match; exit 0 prints `base: <ref>` to branch from, exit 1 stops and names the PR to merge first, exit 2 means the check could not run and stderr says why. A go is a line `<label>: #a #b ...` that `overlap.sh go "<label>" N...` appends to the gitignored `.claude/state/program`, written by the orchestrator when the human gives it (autopilot-stack step 3 runs it itself). A go covers a stack only when a line names the ticket and, for every overlapping PR, the ticket that PR closes; so a line a dead program left behind covers nothing outside its own tickets' open PRs and needs no removal. Under a cover the base is the overlapping PR's head, the lowest-numbered when siblings overlap, the containing one when one contains the other; step 8's `--diff` run records the shared paths as the PR body's `## Overlap` section | Ticket #42, Manuel: "working a ticket to completion before automatically moving on"; the #16 to #22 stack was built on a seven-re-reviews mis-estimate (ledger 2026-09-17). First run (PR #87, closed): three review rounds redesigned the matcher three times; the second run designed from a scenario table Manuel approved 2026-09-21 as the ticket's Testing decisions. Rejected: a ticket label as the go (outlives the program), a line pasted into each lane's brief (a forgotten paste blocks a lane), a `done` step (a crash skips it), the script under the factory918 skill (every later edit cross-cutting). |
| P25 | The design artifact on the ticket | For a design with state (a file it reads or writes, exit codes, rounds, or more than one actor) the architect step's first deliverable is a scenario table, appended to the ticket under `## Testing decisions` before implementation, first line `Posted by the agent <date>` (or `Approved by <name> <date>` when the human approved it first); the usage and signature sketch goes under `## Design` for stateless code that crosses a function boundary; prose has its criteria. Posting is the record: the human edits the ticket if the table is wrong, and a stop is asked for only with `/architect with checkpoint`. The table is the test, one assertion per cell; a cell for an input outside the intended path reads "refused with the tool's own message" and is cut only after the refusal was run and seen. Choices made in #89: the rule lives in Ticket step 6 (no renumbering, since "Ticket step 5" is quoted in four patches and `review-brief.sh`); the page is a sixth core document so projects get it; the to-spec patch follows the README path | Ticket #89: the agent's "It is a general design tool, not a #42 thing" and Manuel's "I agree with your choice completely" on posting as the record. PR #87's three rounds redesigned the core three times; PR #92's found 2, 1, 2 items and no cell changed. 2026-09-22. |
```

### template/docs/factory918/SCENARIO-TABLE.md, added, 79 lines; the diff carries it whole: no text

### tools/build_knowledge.py, lines 10-74 of 184

```
  docs/FACTORY-SPEC-v2.md                  -> docs/knowledge/spec/FACTORY-SPEC-v2/   (chunked by H2)
  research/superseded/FACTORY-SPEC-v1.md   -> docs/knowledge/spec/FACTORY-SPEC-v1/
  research/pages/*.md                      -> docs/knowledge/pages/
  research/notes/*.md                      -> docs/knowledge/notes/ and pages/pocock-planning-evidence.md

Everything under docs/knowledge/ except core/ is GENERATED. Never edit it; change the source and re-run.

Every output file is at most MAX_LINES lines and starts with
  <!-- lines: N | source: <logical name> | part i/n | title: ... -->
followed by a `## Contents` mini-TOC whose line numbers are for the Read tool's `offset`. INDEX.md lists
every file with its line count and when to read it. The `knowledge` skill depends on this shape.
"""
import re, shutil, sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "docs/knowledge"
CORE = OUT / "core"
RESEARCH = ROOT / "research"
MAX_LINES = 220


def rd(p: Path) -> str:
    return p.read_text()


# (output name, title, loader, when to read). core/ entries are handled in place, see build_core().
CORE_DOCS = [
    ("core/PHILOSOPHY.md", "Factory918: philosophy", "First. Whenever the spec is silent."),
    ("core/MANUAL.md", "Factory918: the manual", "How to run the loop; what the human does at each point."),
    ("core/DECISIONS.md", "Factory918: decisions", "Before overriding any vendored skill; these win."),
    ("core/GLOSSARY.md", "Factory918: glossary", "A term in AGENTS.md, a playbook or a ticket is unclear."),
    ("core/SCENARIO-TABLE.md", "Factory918: the scenario table", "Designing or reviewing anything with state: a file, exit codes, more than one actor."),
    ("core/CONVERSATION-DIGEST.md", "How Factory918 was arrived at", "Why something was chosen, historically; the corrections."),
]
SOURCES = [
    ("spec/FACTORY-SPEC-v2.md", "The Factory spec, v2", lambda: rd(ROOT / "docs/FACTORY-SPEC-v2.md"), "Building or updating the factory itself."),
    ("spec/FACTORY-SPEC-v1.md", "The Factory spec, v1 (superseded)", lambda: rd(RESEARCH / "superseded/FACTORY-SPEC-v1.md"), "Only to see what changed between drafts."),
    ("pages/four-skill-systems.md", "Four Skill Systems (reference page)", lambda: rd(RESEARCH / "pages/four-skill-systems.md"), "What Matt, Theo, pstack or Ras Mic do and why; the ten decisions."),
    ("pages/deterministic-layer.md", "The Deterministic Layer (reference page)", lambda: rd(RESEARCH / "pages/deterministic-layer.md"), "Lint, CI, hooks, review bots, verification; Theo's gates in order."),
    ("pages/pocock-planning-evidence.md", "Pocock Planning Evidence (brief)", lambda: rd(RESEARCH / "notes/5-matt-planning-evidence.md"), "Whether Matt's planning works in practice; real specs, tickets, failures."),
    ("notes/1-matt-pocock.md", "Research note: Matt Pocock", lambda: rd(RESEARCH / "notes/1-matt-pocock.md"), "Any Matt skill in depth."),
    ("notes/2-theo.md", "Research note: Theo", lambda: rd(RESEARCH / "notes/2-theo.md"), "Theo's AGENTS.md, skills, workflow, opinions."),
    ("notes/3-pstack.md", "Research note: pstack", lambda: rd(RESEARCH / "notes/3-pstack.md"), "Any pstack skill, playbook or principle in depth; the ports."),
    ("notes/4-ras-mic.md", "Research note: Ras Mic", lambda: rd(RESEARCH / "notes/4-ras-mic.md"), "Evidence-driven testing; loops."),
    ("notes/6-deterministic-layer.md", "Research note: deterministic layer (verbatim config)", lambda: rd(RESEARCH / "notes/6-deterministic-layer.md"), "Exact CI YAML, lint rules, hook scripts from the four sources."),
]


# ---- chunking -------------------------------------------------------------
def split_h2(text: str):
    lines = text.splitlines()
    parts, cur, title = [], [], None
    for ln in lines:
        if ln.startswith("## "):
            if cur:
                parts.append((title, cur))
            cur, title = [ln], ln[3:].strip()
        else:
            cur.append(ln)
    if cur:
        parts.append((title, cur))
    return parts


```

Not carried, over the pack's 65536 bytes: AGENTS.md whole; docs/agents/issue-tracker.md whole; docs/agents/ledger.md whole; docs/knowledge/core/GLOSSARY.md whole; patches/pstack/poteto-mode/playbooks/refactoring.md.patch whole; template/.agents/skills/poteto-mode/playbooks/ticket.md whole; template/docs/agents/issue-tracker.md whole; template/docs/factory918/GLOSSARY.md whole. Read these at HEAD from the repository.

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

The `## Reading pack` section above is the code to read, as it stands at the reviewed commit; open the repository for what the pack does not carry.

Write the report as Markdown with exactly these `## ` headings, in this order, each holding numbered items or nothing:

- `## Would break`: a breach of a documented standard that makes the documented path give a wrong or silent result. Cite the standard (file + the rule) and quote the hunk.
- `## Fails open`: a breach of a documented standard that lets an input outside the documented path proceed silently. Cite the standard (file + the rule) and quote the hunk.
- `## Standards breaches`: documented-standard breaches that do not change behavior. Cite the standard and quote the hunk.
- `## Fix alongside`: baseline smells and other judgement calls. Name the smell and quote the hunk. They are fixed only when a would-break fix already touches that code; they never count.

Each item opens with a line of the form `1. **Title.** body`, with the quoted hunk in a fenced block under it; number the items continuously across the headings, so the judgment can name your third item as [S3]. A documented repo standard overrides the baseline. Skip anything tooling enforces.

Every item under `## Would break` or `## Fails open` carries a line `Documented step:` quoting the ticket line or the `file:line` of the documentation the user follows, and a line `Result:` saying what happens instead; an item without its `Documented step:` line is sent back.

The same item carries a line `spec:` naming the artifact it rests on: `table <row>/<column>` for a cell of the ticket's scenario table, `design <signature>` for a signature or usage in its `## Design` sketch, or `criterion <k>` for its k-th acceptance checkbox; an item without a `spec:` line in one of those three forms is sent back.

Write your report to `.scratch/review/ab47eb9/standards-report.md` and reply with only that path.
End the report with exactly one line `hard findings: N`, where N is the number of items under `## Would break` and `## Fails open` and nothing else.
