# #89 — how a design artifact flows from planning to review today

Worktree read: `/Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.claude/worktrees/owner-89` (branch `feat/design-artifact-on-ticket`, equal to `main`). All paths below are repo-relative to that worktree.

---

## Components Found

### 1. `architect` skill — vendored from pstack, **unpatched**

Four files, all short:

| Path | Lines |
|---|---|
| `template/.agents/skills/architect/SKILL.md` | 84 |
| `template/.agents/skills/architect/references/runner-prompt.md` | 20 |
| `template/.agents/skills/architect/references/design-red-flags.md` | 33 |
| `template/.agents/skills/architect/references/rationale-template.md` | 35 |

`patches/series` (17 entries) contains **no** architect patch. `SOURCES.md:7` vendors `plugins/pstack/skills/*` (51 dirs) from open-pstack v1.3.0. So `architect/` is re-vendored by `./factory918.sh sync` and, per `AGENTS.md` "The ways to hurt yourself" #3, changes (1) and (2) of the ticket need a **new patch** under `patches/pstack/architect/references/runner-prompt.md.patch`, a `series` line, and a `SOURCES.md` numbered entry.

#### The runner prompt, exactly as it reads today

`template/.agents/skills/architect/references/runner-prompt.md`

- **:1–3** — header/handshake. `:3`:
  > "The orchestrator passes this file through to every parallel candidate runner during Phase B and fills in the variable inputs around it: the task, the Phase A grounding artifacts, the isolated working directory, and the path to write outputs. The working directory is a git worktree when available, otherwise a per-runner subdirectory under the sketch dir; what matters is independence between candidates."
- **:5** — the deliverable list, the sentence change (1) extends:
  > "You are producing one candidate design in architect's parallel exploration. Read the **architect** skill in full first; that's the workflow you're inside. Output a candidate design package: type sketch, function signatures, module map, and prose rationale shaped per [`rationale-template.md`](rationale-template.md)."
- **:7** — "Apply the following discipline. The orchestrator compares candidates on these axes to pick a base."
- **:9** — **this is where "usage first, then types and signatures" lives**:
  > "- Caller's usage first. Write the README-style usage and two or three real call sites before the types, then derive the type sketch from them. The usage is the spec; the two must agree, so reconcile the sketch to the usage, not the reverse."
- **:10–18** — nine more discipline bullets: Data structures first (:10), Interface depth (:11), Shared state (:12), Make boundaries visible (:13), Encode invariants in types (:14), Validate at boundaries (:15), Single source of truth (:16), Idempotent state transitions (:17), Short call chains (:18). **None of them mentions state-by-input tables, exit codes, refusals, or a test list.**
- **:20** — closing "don't hedge against the others / differences are the signal" paragraph.

There is **no ordering of deliverables** in the runner prompt beyond `:5`'s flat list plus `:9`'s "usage before types". The ticket's "first deliverable … then a contract derived from it, then a test list" has no counterpart today.

#### Runners, judging, checkpoint

- **Count and roles**: `SKILL.md:34` — "Use your configured architect runners (defaults `claude:fable@max`, `codex:gpt-5.6-sol@max`, `grok:grok-4.6@xhigh`, `claude:opus@xhigh`)." Four descriptors, all the same role (design candidate); no differentiated roles. `template/.agents/skills/setup-pstack/SKILL.md:105` writes the same defaults into the model sheet; the user's own sheet (`~/.claude/pstack-models.md`) sets `architect runners: claude:fable@high, claude:opus@high`.
- **How the lead judges**: architect delegates to `arena`. `SKILL.md:32` — "Run the **arena** skill with the design-sketch task and the Phase A grounding artifacts. Pass `references/runner-prompt.md` as each runner's prompt. Each candidate produces a design package shaped per `references/rationale-template.md`: the caller's usage written first, then the type sketch, function signatures, module map, and prose rationale derived from it." Then `SKILL.md:36` (design it twice, two structurally distinct candidates), `:38` (screen against `design-red-flags.md`), `:40` (compare on interface depth), `:42` ("Arena returns one synthesized design package. The synthesis decision populates the rationale's 'Synthesis decision' section.").
  Arena itself: Phase C cross-judge (`template/.agents/skills/arena/SKILL.md:42`), Phase D pick a base (`:44–52`), Phase E graft (`:54–62`), Phase F verify (`:64–68`).
- **Checkpoint**: `template/.agents/skills/architect/SKILL.md:44–52`, "Phase C: Agree (opt-in)". Verbatim:
  - `:46` — "Default: proceed directly to implementation with the synthesized design. No human checkpoint."
  - `:48` — "Opt in to a checkpoint when the invoker explicitly asks: \"/architect with checkpoint,\" \"stop and show me before implementing,\" or similar. Then surface the synthesized design and pause for sign-off."
  - `:50` — the synthesis can ship as its own commit either way; names `foundational-thinking`, `outcome-oriented-execution`, and `interrogate` for adversarial pressure.
  - `:52` — "If the human pushes back on the shape (in a checkpoint or after the fact), treat that as Phase A evidence. Re-ground and re-run Phase B before writing more code."
  So **"/architect with checkpoint" is already the exact opt-in phrase** the ticket's change (3) wants the Ticket playbook to name. It exists only inside the architect skill today; no playbook mentions it.
- **"Stay in the loop"** appears only in the skill description (`SKILL.md:3`): "Sketch types, signatures, and module structure before code, then stay in the loop while implementation fills in." Phase D (`:54–58`) is the loop: "Deviations from the sketch are signal worth surfacing, not friction to absorb silently."
- **Outputs** (`SKILL.md:82–84`): "The caller's usage is written first and the type sketch derived from it. One file with new types and signatures for small changes; module map plus type definitions for larger work. The rationale ships alongside, shaped per `references/rationale-template.md`, including the usage sketch and the synthesis decision." **No destination outside the working tree is named. Nothing posts anything to a ticket.**
- `rationale-template.md` sections: Problem (`:5`), Usage (caller's view) (`:9–11`, "Write this first, before the type sketch"), Shape (`:13–15`), Synthesis decision (`:17–19`), Tradeoffs accepted (`:21–23`), Alternatives considered (`:25–27`), Open questions and risks (`:29–31`), Next implementation step (`:33–35`). No Testing/scenario section.
- `design-red-flags.md` is the screen list: Shallow module, Information leakage, Temporal decomposition, Pass-through method. It is mirrored in `template/CODING_STANDARDS.md:31–33` ("## Design red flags (pstack's architect)"), which `review-brief.sh` pastes into the Standards brief.

### 2. Ticket playbook — **ours** (`keep_files`), not a patch

`template/.agents/skills/poteto-mode/playbooks/ticket.md`, 24 lines. Confirmed ours: `factory918.sh:381`

```
local keep_files="poteto-mode/playbooks/ticket.md poteto-mode/scripts/overlap.sh spec-review/scripts/review-brief.sh spec-review/scripts/review-comment.sh"
```

(`SOURCES.md:14` also says patch 2 "added" it; the file itself is preserved across `sync` by `keep_files`, so it is edited directly.)

**Step 5, whole (`ticket.md:9`):**

> "5. Select by content and run that playbook's steps verbatim from step 1: new behavior → Feature; a defect → Bug fix; a behavior-preserving change → Refactoring; measured slowness → Perf issue. `how` and `why` over the affected subsystem come first in all of them. A change whose diff will touch a cross-cutting path, one under a `.claude/hooks/` directory, a `.claude/settings.json`, or a file of the `factory918` skill (`.agents/skills/factory918/`), at any depth (`spec-review`'s `review-brief.sh` holds the predicate), reaches every session and skill at once: after `how`, run `blast-radius` over it and write the result to `.scratch/<ticket>/blast-radius.md` in that skill's hand-back shape (what it does; the one fact it is safe because of and how far it was proven; risks; cleared; before you merge), with a risk for every session kind (the interactive session, a subagent, a hook's own invocation, `factory-start` at day zero, a review in progress) and every skill the change reaches, each with a `file:line`. Such a change never skips `architect`. The PR body's `## Blast Radius` section is that file verbatim, and `review-brief.sh` refuses to brief the diff without it."

**Step 6, whole (`ticket.md:10`):**

> "6. The spec's **Testing decisions** are the pre-agreed seams. `tdd` there, and nowhere the spec did not agree unless a criterion needs it."

**Every `architect` / `Testing decisions` / `## Design` mention in `ticket.md`:**
- `architect` — once, `ticket.md:9`, the clause "Such a change never skips `architect`."
- `Testing decisions` — once, `ticket.md:10` (step 6, above).
- `## Design` — **zero occurrences anywhere in the repo** outside `research/` (only `template/CODING_STANDARDS.md:31` "## Design red flags" and a research note's "## Design principle").

**Important structural fact for change (3):** `ticket.md` has **no numbered architect step**. The architect step lives in the four sub-playbooks (Feature step 2; Bug fix / Refactoring / Perf issue step 3), which `ticket.md:9` routes to. The nearest thing to "the Ticket playbook's architect step" today is the one clause inside step 5. This is a naming mismatch in the ticket worth flagging to the writer.

Also in `ticket.md`: step 2 (`:6`) names the body shape — "The body shape is `docs/agents/issue-tracker.md`, \"Ticket body\"." Step 4 (`:8`) is the falsifiability pass. The "Quick ticket" section (`:17–24`) has its own rule at `:23`: "Reply with the number and the criteria in one line, then proceed; do not wait. The human edits the issue if the words are wrong." — that "the human edits it if wrong, do not wait" pattern is the precedent change (3) reuses.

### 3. The four sub-playbooks' delegation steps

| Playbook | Architect step | Delegation step (the one change (4) lands in) |
|---|---|---|
| `feature.md` | step 2, `:6` | **step 4, `:12`** |
| `bug-fix.md` | step 3 (same line as delegation), `:9` | **step 3, `:9`** |
| `refactoring.md` | step 3, `:9` | **step 5, `:11`** |
| `perf-issue.md` | step 3 (same line as delegation), `:16` | **step 3, `:16`** |

Quoted whole:

**`template/.agents/skills/poteto-mode/playbooks/feature.md:12`**
> "4. Delegate code-writing through provider dispatch using your configured feature descriptor (default `grok:grok-4.6@xhigh`) with `isolated-write`, a dedicated worktree, and a specific scope (file paths, named data shape and its organizing structure per **principle-model-the-domain** — a state machine over scattered booleans, a table/registry over branching, a typed model over repeated shape assumptions, chosen before the delegate writes logic — and success criteria); review its diff yourself. When the implementation admits multiple valid shapes (error handling, abstraction layer, test structure), delegate via the **arena** skill instead so the runners surface the alternatives and the cross-judge guards the pick. Mandatory: no skip-with-reason escape, and Laziness Protocol does not override it (the gain is review separation, not lines saved). The delegate owns the diff directly and never waits on or launches a nested agent. Comments per **Comments**. Surgical edits, re-ground against the source for upstream-derived files. Port shared-primitive improvements to all consumers and verify each. Commit liberally."

**`template/.agents/skills/poteto-mode/playbooks/bug-fix.md:9`**
> "3. Plan the fix. If it crosses a function boundary, `architect` first; a cross-cutting diff (Ticket step 5) never skips it. Delegate implementation through provider dispatch using your configured bug-fix descriptor (default `codex:gpt-5.6-sol@max`) with `isolated-write`, a dedicated worktree, and a specific scope; review the diff."

**`template/.agents/skills/poteto-mode/playbooks/refactoring.md:11`**
> "5. Move in small behavior-preserving steps, each keeping the pin green. For API reshapes, migrate every caller and delete the old API in the same wave (**principle-migrate-callers-then-delete-legacy-apis**). No compatibility shims, no parallel old-and-new paths. Spot-check every rename against the actual files; renames silently miss usages in strings, prose, and back-references. Delegate the mechanical edits through provider dispatch using your configured refactoring descriptor (default `grok:grok-4.6@xhigh`) with `isolated-write`, a dedicated worktree, and a specific scope (file paths, the names being moved, the behavior to hold); review the diff yourself."

**`template/.agents/skills/poteto-mode/playbooks/perf-issue.md:16`**
> "3. Plan the fix from the trace. If it crosses a function boundary, `architect` first; a cross-cutting diff (Ticket step 5) never skips it. Delegate implementation through provider dispatch using your configured perf-issue descriptor (default `codex:gpt-5.6-sol@max`) with `isolated-write` in a dedicated worktree; review the diff. Capture a post-fix trace."

Relevant neighbours: `feature.md:6` (architect step 2), `refactoring.md:9` (architect step 3), `bug-fix.md:11` (step 5, the `tdd` failing-test-first cadence: "See the **tdd** skill for the failing-test-first cadence when the bug has a cheap local test path; skip it when the test would be expensive, integration-heavy, or unclear.").

### 4. The patch hunks (change (4)'s blast radius)

All four playbooks are vendored pstack files, re-vendored on `sync`, so change (4) must extend patch 13's files. `SOURCES.md:25`:

> "13. `playbooks/feature.md` step 2, `playbooks/bug-fix.md` step 3, `playbooks/refactoring.md` step 3 and `playbooks/perf-issue.md` step 3: the `architect` skip clause gains one sentence, that a cross-cutting diff (the Ticket playbook, step 5) never skips it."

`patches/series` lines 8–11 list `bug-fix`, `feature`, `perf-issue`, `refactoring` (in that order).

**Is the delegation step already inside a patch hunk?**

| Patch | Hunk header | Context lines it covers | Delegation step inside the hunk? |
|---|---|---|---|
| `patches/pstack/poteto-mode/playbooks/feature.md.patch` (11 lines) | `@@ -3,7 +3,7 @@` (`:3`) | header, step 1, step 2 (changed), step 3 + its first two sub-bullets | **No.** Hunk ends at the "Independent workstreams" bullet; step 4 (`feature.md:12`) is outside. A new hunk is needed. |
| `patches/pstack/poteto-mode/playbooks/bug-fix.md.patch` (11 lines) | `@@ -6,7 +6,7 @@` | step 1, step 2, step 3 (changed), steps 4–5 | **Yes.** The changed line *is* the delegation line (`bug-fix.md:9`). |
| `patches/pstack/poteto-mode/playbooks/refactoring.md.patch` (11 lines) | `@@ -6,7 +6,7 @@` | steps 1, 2, 3 (changed), 4, **5**, 6 | **Yes.** Step 5 (`refactoring.md:11`) is trailing context in the hunk; editing it means rewriting the hunk's context/counts, not adding a hunk. |
| `patches/pstack/poteto-mode/playbooks/perf-issue.md.patch` (11 lines) | `@@ -13,7 +13,7 @@` | three strategy bullets, step 3 (changed), steps 4–5 | **Yes.** The changed line *is* the delegation line (`perf-issue.md:16`). |

So only `feature.md.patch` needs a second hunk; the other three need the existing hunk widened/edited.

### 5. `to-spec` — vendored from mattpocock, **unpatched and byte-identical to upstream**

`diff -u research/1-matt-pocock/skills-repo/skills/engineering/to-spec/SKILL.md template/.agents/skills/to-spec/SKILL.md` → **no differences**. `patches/series` has only one mattpocock patch, `mattpocock/spec-review.SKILL.md.patch` (line 17). So change (5) needs a new `patches/mattpocock/to-spec.SKILL.md.patch` + `series` + `SOURCES.md` entry.

**"Testing Decisions" section verbatim, `template/.agents/skills/to-spec/SKILL.md:59–65`:**

```
59  ## Testing Decisions
60
61  A list of testing decisions that were made. Include:
62
63  - A description of what makes a good test (only test external behavior, not implementation details)
64  - Which modules will be tested
65  - Prior art for the tests (i.e. similar types of tests in the codebase)
```

Note the heading is **Title Case** here (`## Testing Decisions`), while everywhere in Factory918's own prose it is sentence case ("Testing decisions": `ticket.md:10`, `template/AGENTS.md:66`, `GLOSSARY.md:51`, `DECISIONS.md` P24). The ticket's `## Testing decisions` on a ticket body is therefore a *different heading string* from the spec's `## Testing Decisions`.

Upstream context that matters for change (5): `to-spec/SKILL.md:15` is the seam step —
> "2. Sketch out the seams at which you're going to test the feature. Existing seams should be preferred to new ones. Use the highest seam possible. If new seams are needed, propose them at the highest point you can. The fewer seams across the codebase, the better - the ideal number is one."
and `:17` — "Check with the user that these seams match their expectations."

### 6. `to-tickets` — how Testing decisions reach a ticket body: **they don't**

`template/.agents/skills/to-tickets/SKILL.md` (105 lines) contains **zero** occurrences of "Testing decisions" / "test". Its issue template (`:84–103`) has exactly four sections:

```
 86  ## Parent
 90  ## What to build
 94  ## Acceptance criteria
 99  ## Blocked by
```

and the local-file template (`:69–82`) has **What to build / Blocked by / Status / checkboxes**. `:105` — "In either form, avoid specific file paths or code snippets: they go stale fast. Exception: if a prototype produced a snippet that encodes a decision more precisely than prose can (state machine, reducer, schema, type shape), inline it and note briefly that it came from a prototype."

So **Testing decisions live only on the parent spec issue**, never copied onto the child ticket. The Ticket playbook reaches them by reading the Parent (`ticket.md:6`: "its **Parent** is the spec: read it too (`gh issue view <parent>`)"), and step 6 (`ticket.md:10`) applies them.

`to-tickets` is vendored and unpatched too (not in `series`).

### 7. `review-brief.sh` — where the ticket body lands in the Spec brief

`template/.agents/skills/spec-review/scripts/review-brief.sh`, 361 lines. Ours (`factory918.sh:381` `keep_files`).

**Ticket resolution**, `:66–80`. Comment at `:66–67`:
> "# The spec is the ticket body: --ticket, or the one #N the commit messages name, oldest first. / # Never the author's own words (SKILL.md step 2). Two numbers is a question for the caller."

**The fetch**, `:218–227`:
```
218  # The spec is the ticket body plus the comments its author posted, each under its date. Comments by
219  # anyone else, and the PR's own comments, are never spec.
220  spec="" comments=""
221  if [ -n "$ticket" ]; then
222    err="$(gh issue view "$ticket" --json body -q .body 2>&1 >"$dir/ticket.md" || true)"
223    spec="$(cat "$dir/ticket.md")"
224    [ -n "$spec" ] || echo "review-brief: gh could not fetch #$ticket (...); no spec" >&2
225    by_author='.author.login as $a | .comments[] | select(.author.login == $a) | "### \(.createdAt[:10])\n\n\(.body)\n"'
226    [ -z "$spec" ] || comments="$(gh issue view "$ticket" --json author,comments -q "$by_author" 2>/dev/null || true)"
227  fi
```

**The paste into the Spec brief**, `:328–342`:
```
328  if [ -n "$spec" ]; then
329    {
330      echo "# Spec review brief"
331      echo
332      common
333      echo "## The ticket (#$ticket)"
334      echo
335      printf '%s\n' "$spec"        <-- the whole ticket body, verbatim
336      echo
337      if [ -n "$comments" ]; then
338        echo "## Comments by the ticket's author (#$ticket)"
339        echo
340        printf '%s\n' "$comments"  <-- the author's comments, each under "### YYYY-MM-DD"
341        echo
342      fi
```

**This is the mechanism change (3) names.** Because `:335` pastes the body wholesale, a `## Testing decisions` section appended to the ticket body reaches the Spec reviewer with zero script change. A comment posted by the ticket author (the `## Design` route of change (1)) also reaches it, via `:340`, but only when the commenter's login equals `.author.login` of the issue.

Note the interaction with the brief's own report shape, `:349`:
> "Each item opens with a line of the form `1. **Title.** body` and quotes the spec line it rests on in a fenced block (a criterion can carry `## ` or `1. ` lines, and only fenced text is exempt from the report shape) …"
— i.e. a ticket body already may carry `## ` headings; the brief tolerates them.

**Cross-cutting predicate** (the "one place the predicate lives"), `:180–190`:
```
180  # A cross-cutting path reaches every session and skill, so its diff alone cannot show the review
181  # what it breaks: the brief also carries the author's blast-radius grounding (the blast-radius
182  # skill's hand-back), from --blast-radius FILE or the PR body's `## Blast Radius` section, and is
183  # refused without one. This is the one place the predicate lives; the Ticket playbook says it in
184  # words. The leading `*` covers a project's own `.claude/hooks/` and the factory's `template/` copy.
185  crossing=""
186  while read -r p; do
187    case "$p" in
188      *.claude/hooks/*|*.claude/settings.json|*.agents/skills/factory918/*) crossing="$crossing $p" ;;
189    esac
190  done < "$dir/files"
```
Three globs: `*.claude/hooks/*`, `*.claude/settings.json`, `*.agents/skills/factory918/*`. **Note: `.agents/skills/architect/` and the playbooks are NOT cross-cutting**, so a #89 implementation PR does not itself need a blast radius.

The brief's own definition of a finding, `:231` — relevant because change (2)'s "refused with the tool's own message" mirrors it word-for-word in spirit:
> "A hard finding is one of two things: the documented path gives a wrong or silent result, or an input outside it proceeds silently (fails open). An input outside the documented path that is refused with a message saying how to correct it is not a finding; it is the design. Zero items is the expected result for a clean change."
and the Spec brief's `## Fails open` heading, `:346`:
> "- `## Fails open`: an input outside the documented path that proceeds silently instead of being refused with a message saying how to correct it."

Test that pins the paste: `tests/spec-review/review-brief.sh:166–170`
```
166  has "$spec" "What to build: the ticket body" "Spec: the ticket body from gh"
167  has "$spec" "## Comments by the ticket's author (#7)" "Spec: the author's comments heading"
170  lacks "$std" "## Comments by the ticket's author" "Standards: no ticket comments"
```

### 8. `template/docs/agents/issue-tracker.md` — the Ticket body shape

`:16–26`, "## Ticket body". `:18`:
> "Every ticket has this shape, in this order. The Ticket playbook, `spec-review`, `interrogate` and the quick-ticket path all read it."

The five bullets, in order:
- `:20` **Title** — "the ask in about six words, a plain sentence."
- `:21` **`## What to build`** — to-tickets form, or for a quick ticket "the exchange that carried the decision, quoted and attributed… Quote; never paraphrase or summarize, and put nothing in the ticket that neither said."
- `:22` **`## Acceptance criteria`** — "one checkbox per observation that would fail today, in the user's terms. Each one is something a command or a look can falsify."
- `:23` **`## Parent`** — "the spec issue, for planned tickets. A quick ticket has none."
- `:24` **`## Blocked by`** — issue numbers or `None`.
- `:26` — "Anything an agent may pick up carries the label `ready-for-agent`."

**Neither `## Testing decisions` nor `## Design` is named.** Change (3) adds a sixth section to a list that explicitly claims "this shape, in this order" and names its four readers, so `issue-tracker.md` must change with it. Per `AGENTS.md` "Agent skills", the canonical copy is `template/docs/agents/issue-tracker.md` and the factory's own `docs/agents/issue-tracker.md` is a copy of it (both exist; `docs/agents/issue-tracker.md` is referenced by `ticket.md:6`).

### 9. `template/docs/agents/review-ladder.md` — 13 lines; no architect, no design holes

Neither "architect" nor "design" appears. Rung 1 (`:6`) is the `spec-review` rung and carries the same two-kinds-of-finding definition as `review-brief.sh:231`:
> "Each axis counts two kinds of finding: the documented path gives a wrong or silent result, or an input outside it proceeds silently (fails open); an input outside the documented path that is refused with a message saying how to correct it is not a finding, it is the design, and zero items is the expected result for a clean change."
Rung 3 (`:8`) is `interrogate`, "When the design is contested, or the diff touches an invariant named in `CONTEXT.md`." Rung 4 (`:9`) is the human.

### 10. Every line in the core docs that already says something (change-(g) grep)

Greps for `architect|testing decision|scenario|design hole|## Design|usage first|signature`, case-insensitive:

- `template/.agents/skills/factory918/SKILL.md` (74 lines) — **no match at all.** The routing table (`:49–67`) never names `architect` or a design artifact. Closest: `:55` (a ticket reference → `/poteto-mode "#N"`).
- `template/AGENTS.md:66` — the only match:
  > "- The spec's **Testing decisions** are the pre-agreed seams. `tdd` there."
  (in "## Verifying", `:60–74`). `tools/bootstrap/inputs/AGENTS.md:66` carries the identical line (frozen provenance; do not edit).
- `docs/knowledge/core/MANUAL.md` — two matches:
  - `:122` — "- Before a large feature, or monthly: `/thermo-nuclear-code-quality-review` on the area you are about to touch, or `/architect` to reshape it before code."
  - `:139` — the models table row "| Panels: `how` critics, `architect`, `arena` runners | Fable + Opus | Opus high + Opus medium |"
  - Adjacent, not matched by the grep but load-bearing: `:65` ("Confirm the test seams when `/to-spec` asks; those become the pre-agreed seams `tdd` uses in execution") and `:77` (the Execution walk-through, which compresses the whole sub-playbook to "`how` and `why` over the subsystem, design, delegated build with a reviewed diff, verification on the real surface, then Opening a PR and Babysit").
- `docs/knowledge/core/DECISIONS.md` — two matches:
  - `:29` decision 13 (models) mentions "hard architecture".
  - `:92` **P24**, the key one. Its rationale column ends:
    > "First run (PR #87, closed): three review rounds redesigned the matcher three times; the second run designed from a **scenario table Manuel approved 2026-09-21 as the ticket's Testing decisions.**"
    This is the only place in the repo that already states the practice #89 wants to codify. It is recorded as a one-off inside a decision about overlap, not as a rule anywhere an agent reads. (The generated mirror `template/docs/factory918/DECISIONS.md:84` carries the same text.)
- `docs/knowledge/core/GLOSSARY.md` — two matches:
  - `:51` — "**Seam.** The public boundary you test at; the interface where you observe behaviour without reaching inside. Pre-agreed seams are the spec's Testing decisions. (Matt, from Michael Feathers)"
  - `:55` — "**Spec.** The issue `/to-spec` writes from a grilling session: problem, solution, user stories, implementation decisions, testing decisions, out of scope. A decision record, throwaway once shipped. (Matt)"
  - No glossary entry for "scenario table", "design artifact" or "architect". (Generated mirror: `template/docs/factory918/GLOSSARY.md:47,51`.)
- `template/.agents/skills/poteto-mode/SKILL.md` router mentions of architect: `:21` — "- Code crossing a function boundary → the **architect** skill, parallel design exploration before implementing."; `:90` (dispatch defaults); `:113` — "The failure mode is reading a playbook then writing a bespoke plan that drops its named steps (`architect`, the throughput checkpoint). A step you choose not to do stays in the list with a one-line `skip: <reason>`".

### 11. `docs/agents/ledger.md` — the 2026-09-21 cut-cell entry (change (2)'s evidence)

The file is 24 lines; three entries dated 2026-09-21. The one asked for is the **last line of the file**, `docs/agents/ledger.md:24`, verbatim:

> `2026-09-21 | fable | cut the detached-HEAD cell from the #42 scenario table on the judge's word that git would fail loudly on its own; git ran fine with an empty branch name and round two found the record step reporting the ticket's own PR | a cell cut as 'the tool refuses it' is cut only after the refusal was run and seen; an assumption about a tool's failure mode is a rung-1 claim until then`

Change (2)'s wording ("cut only after the refusal was run and seen") is lifted from this line's "what you wanted" column almost word for word.

The two neighbours, same date:
- `:21` — "asked whether ticket #82 needed to exist, then closed it before Manuel answered… | a question is a question; answer it and wait for his decision, even when the answer is obvious"
- `:23` — "briefed the writer lane with the script path `.agents/skills/factory918/scripts/overlap.sh` after its own design note said `.claude/skills` resolves in both… | the brief is checked against the design note before it is sent; a path an agent will type is tested the way it is typed"

### 12. The one existing scenario table in the repo

`tests/poteto-mode/overlap.sh:6` — the test header names its cases as "the order of **the scenario table in the ticket's design**":
```
 5  # call FAKE_GH_FAIL names), and asserts the exit code and the output of each call in the order of
 6  # the scenario table in the ticket's design: usage, no origin remote, a failing gh, a head with no
 7  # merge base, more open PRs than the list holds, tokens that name no path
 8  # or lie outside the repository, one PR shared, a deleted and a stale remote ref both fetched, a file
 9  # a PR creates, a stacked PR reporting only its own commits, a glob and both directory forms,
10  # `## Diff` skipped, two PRs in ascending number, gos that cover and gos that do not, the base as the
11  # head that contains the others, ...
```
This is the #42 table P24 refers to — the working precedent for "one assertion per cell" (change (4)). The table itself is not in the repo; only its consequences (the test's ordering) and P24's sentence survive.

---

## Flow

Today, end to end, a design artifact's life:

1. **Planning.** `/grill-with-docs` → `/to-spec`. `to-spec` step 2 (`to-spec/SKILL.md:15–17`) sketches test **seams** and checks them with the user in conversation. The spec issue it publishes carries `## Testing Decisions` (`:59–65`), whose content is defined only as "what makes a good test / which modules / prior art". No table, no per-input cells, no contract.
2. **Tickets.** `/to-tickets` splits the spec into child tickets whose bodies have exactly `## Parent`, `## What to build`, `## Acceptance criteria`, `## Blocked by` (`to-tickets/SKILL.md:84–103`; `template/docs/agents/issue-tracker.md:20–24`). **Testing decisions are not copied down.** The only link is `## Parent`.
3. **Execution starts.** `/poteto-mode "#N"` → Ticket playbook. Step 1 overlap check (`ticket.md:5`), step 2 reads the ticket and follows `## Parent` to the spec (`ticket.md:6`), step 3 blockers, step 4 falsifiability, step 5 routes to Feature / Bug fix / Refactoring / Perf issue (`ticket.md:9`).
4. **Design.** The sub-playbook's architect step fires — Feature `:6` unconditionally, the other three "if it crosses a function boundary"; a cross-cutting diff never skips it. `architect` runs Phase A (`how`/`why` grounding), then Phase B hands `references/runner-prompt.md` to N arena runners (default four descriptors, one role) (`architect/SKILL.md:32–34`). Each runner returns a design package: **usage first, then types, signatures, module map, rationale** (`runner-prompt.md:5,9`; `rationale-template.md:9–11`). Arena cross-judges, picks a base, grafts (`arena/SKILL.md:40–62`), and architect ends with one synthesized design package plus its rationale.
5. **The artifact stops there.** It lives in the arena/architect working directory (a worktree or `/tmp/arena-<slug>/candidate-<n>/`, `arena/SKILL.md:30`). Nothing writes it to `.scratch/<ticket>/`, nothing posts it to the ticket, nothing puts it in the PR body. Compare `blast-radius`, which *does* have a mandated destination — `.scratch/<ticket>/blast-radius.md`, then the PR body's `## Blast Radius`, then `review-brief.sh:196–198` reads it back. **The design artifact has no equivalent of that chain.**
6. **Checkpoint.** Default is none (`architect/SKILL.md:46`). A human sign-off happens only on the literal opt-in "/architect with checkpoint" (`:48`). That phrase exists nowhere a person or an orchestrator would see it — only inside the architect skill itself.
7. **Implementation.** The sub-playbook's delegation step sends the writer a "specific scope": Feature `:12` (file paths, a named data shape per `principle-model-the-domain`, success criteria); Bug fix `:9` and Perf `:16` say only "a specific scope"; Refactoring `:11` says "file paths, the names being moved, the behavior to hold". **None of the four names the design artifact as an input, none says the test comes first, none tells the writer what to do when a designed case cannot be implemented as written.** Test-first appears only in Bug fix step 5 (`:11`, the `tdd` cadence, explicitly skippable) and Refactoring step 1 (`:7`, the characterization pin).
8. **Testing decisions in execution.** Ticket step 6 (`ticket.md:10`) applies the *spec's* Testing decisions as the pre-agreed seams; `template/AGENTS.md:66` and `GLOSSARY.md:51` say the same. The design artifact and the Testing decisions are two unconnected things today.
9. **Review.** `review-brief.sh` fetches the ticket body (`:222`) and pastes it whole into the Spec brief under `## The ticket (#N)` (`:335`), plus the ticket author's own comments under `## Comments by the ticket's author` (`:340`). The Spec reviewer grades `## Walk` / `## Would break` / `## Fails open` / `## Not asked for` (`:344–347`) against that body. **Since the design artifact never reaches the ticket body, the Spec reviewer never sees the design — it grades the diff against the acceptance criteria only.** Change (3)'s mechanism works precisely because `:335` is a verbatim paste.
10. **The recorded failure this fixes.** `DECISIONS.md:92` (P24): PR #87's first run burned three review rounds redesigning the matcher three times; the second run designed from a scenario table Manuel approved on 2026-09-21 as the ticket's Testing decisions. And `docs/agents/ledger.md:24`: a cell cut from that table on an unverified assumption about git's failure mode came back as a round-two finding.

## Files Read

- `template/.agents/skills/architect/SKILL.md` (whole, 84)
- `template/.agents/skills/architect/references/runner-prompt.md` (whole, 20)
- `template/.agents/skills/architect/references/design-red-flags.md` (whole, 33)
- `template/.agents/skills/architect/references/rationale-template.md` (whole, 35)
- `template/.agents/skills/arena/SKILL.md` (whole, 72)
- `template/.agents/skills/poteto-mode/playbooks/ticket.md` (whole, 24)
- `template/.agents/skills/poteto-mode/playbooks/feature.md` (whole, 21)
- `template/.agents/skills/poteto-mode/playbooks/bug-fix.md` (whole, 17)
- `template/.agents/skills/poteto-mode/playbooks/refactoring.md` (whole, 16)
- `template/.agents/skills/poteto-mode/playbooks/perf-issue.md` (whole, 24)
- `template/.agents/skills/poteto-mode/SKILL.md` (grepped)
- `template/.agents/skills/to-spec/SKILL.md` (whole, 75)
- `template/.agents/skills/to-tickets/SKILL.md` (whole, 105)
- `template/.agents/skills/spec-review/scripts/review-brief.sh` (whole, 361)
- `template/.agents/skills/factory918/SKILL.md` (whole, 74)
- `template/docs/agents/issue-tracker.md` (whole, 57)
- `template/docs/agents/review-ladder.md` (whole, 13)
- `template/AGENTS.md` (`:55–80`)
- `template/CODING_STANDARDS.md` (`:25–37`)
- `docs/knowledge/core/MANUAL.md` (`:110–145`, section map, greps)
- `docs/knowledge/core/DECISIONS.md` (greps; `:29`, `:92`)
- `docs/knowledge/core/GLOSSARY.md` (greps; `:11`, `:51`, `:55`)
- `docs/agents/ledger.md` (whole, 24)
- `SOURCES.md` (whole, 25)
- `patches/series` (whole, 17)
- `patches/pstack/poteto-mode/playbooks/{feature,bug-fix,refactoring,perf-issue}.md.patch` (all four whole, 11 lines each)
- `factory918.sh` (grepped; `:381–388`)
- `tests/spec-review/review-brief.sh` (grepped)
- `tests/poteto-mode/overlap.sh` (`:1–20`)
- `research/1-matt-pocock/skills-repo/skills/engineering/to-spec/SKILL.md` (diffed against template copy)

## Boundaries

- **Vendored vs ours.** Of the seven files the ticket's five changes touch, **only `ticket.md` is ours** (`factory918.sh:381` `keep_files`). `architect/references/runner-prompt.md`, `to-spec/SKILL.md`, and the four sub-playbooks are all re-vendored by `./factory918.sh sync` and need patches (`AGENTS.md` #3). Two of the five changes need a *brand-new* patch file + `series` line + `SOURCES.md` entry (architect runner-prompt; to-spec), and one extends four existing patches (13). The verification list requires `./factory918.sh sync` to leave `git status` clean, which is the check that the patches apply.
- **Not cross-cutting.** `review-brief.sh:188`'s predicate is `*.claude/hooks/*`, `*.claude/settings.json`, `*.agents/skills/factory918/*`. None of #89's target files match, so an implementing PR needs no `## Blast Radius` and `architect` is not forced by Ticket step 5 (Feature step 2 still makes it mandatory-with-a-reason).
- **Generated mirrors.** `template/docs/factory918/{GLOSSARY,DECISIONS,MANUAL,PHILOSOPHY}.md` and `docs/knowledge/{spec,pages,notes}/` are generated from `docs/knowledge/core/*.md` by `python3 tools/build_knowledge.py`. Any core-doc edit must be followed by that build. `tools/bootstrap/inputs/AGENTS.md:66` is frozen provenance and must NOT be edited even though it carries the same Testing-decisions line as `template/AGENTS.md:66`.
- **Two copies of the agent docs.** `docs/agents/issue-tracker.md` (what `ticket.md:6` points at, inside a project) and `template/docs/agents/issue-tracker.md`. `AGENTS.md` "Agent skills" says: edit the `template/docs/agents/` copy, then copy. Same for `review-ladder.md`, `domain.md`, `triage-labels.md`. `docs/agents/ledger.md` exists only at the repo root (the factory's own ledger).
- **Two spellings.** `## Testing Decisions` (Title Case, upstream `to-spec` heading, `to-spec/SKILL.md:59`) vs "Testing decisions" (sentence case, everywhere in Factory918's own prose). The ticket asks for `## Testing decisions` on a ticket body — a third string, on a different artifact from the spec's section. A writer must not conflate them.

## Non-Obvious Things

1. **The Ticket playbook has no architect step.** Change (3) says "the Ticket playbook's architect step". `ticket.md` mentions `architect` exactly once, inside step 5's cross-cutting sentence (`:9`). The real architect steps are `feature.md:6`, `bug-fix.md:9`, `refactoring.md:9`, `perf-issue.md:16` — all vendored. Landing change (3) in `ticket.md` means either adding a new step (renumbering steps 6–9, which `ticket.md:9` and `ticket.md:12` and `SOURCES.md:15,18,21` and `factory918/SKILL.md:55` all reference by number: "Ticket step 5", "step 8") or extending step 5 / step 6 in place. **Renumbering is the sharp edge here**: "Ticket step 5" is quoted by name in the four patched playbooks (patch 13) and in `review-brief.sh:183`'s comment; `ticket.md:5` names "step 8" as the paths-none check.
2. **`/architect with checkpoint` already exists, verbatim**, at `architect/SKILL.md:48`. Change (3) is not inventing a phrase; it is surfacing an existing opt-in to the place where an orchestrator would look for it. The default is already "no checkpoint" (`:46`), which means the ticket's "a stop before implementation is asked for only with '/architect with checkpoint'" is a *restatement* of architect's own default, not a new rule — the new part is that the table gets posted anyway, without stopping.
3. **The blast-radius chain is the template for what #89 wants.** `blast-radius` output has a mandated file (`.scratch/<ticket>/blast-radius.md`), a mandated PR-body section (`## Blast Radius`), and a script that refuses without it (`review-brief.sh:201–205`). The design artifact has none of the three. If #89 wants the same guarantee, a parallel enforcement point would be needed; the ticket as written relies on the ticket body paste (`:335`) instead, which is unenforced — nothing refuses a PR whose ticket has no `## Testing decisions`.
4. **The ticket-author filter.** `review-brief.sh:225` selects issue comments by `.author.login == $a` where `$a` is the *issue's* author. So the ticket's route (1) ("posted on the ticket under `## Design`") reaches the Spec reviewer **only when the agent posts from the same account that opened the issue**. Change (3)'s route (appending to the ticket *body*) is unconditional — `:335` pastes the body regardless of who wrote it. Those two routes have materially different reliability; the ticket treats them as interchangeable.
5. **"Approved by \<name\> \<date\>" already has a house form.** `AGENTS.md` and `template/AGENTS.md:78` require an agent-posted comment to end with the model and harness "with 'approved by <name>' added when the human approved it before posting; only an approved comment posted from the author's account is the author's words." Change (3)'s "Posted by the agent \<date\>" / "Approved by \<name\> \<date\>" first line is a new, *leading* variant of an existing *trailing* convention. Worth reconciling.
6. **The no-code-snippets rule cuts against tables.** `to-spec/SKILL.md:55` — "Do NOT include specific file paths or code snippets. They may end up being outdated very quickly", with a prototype exception at `:57`. `to-tickets/SKILL.md:105` repeats it. A scenario table with exit codes and printed output sits close to that line; change (5) should probably lean on the existing prototype exception's phrasing ("a snippet that encodes a decision more precisely than prose can").
7. **`## Design` exists nowhere.** Zero hits repo-wide outside `research/` for a `## Design` heading used this way. It would be a new vocabulary item — and `GLOSSARY.md` has no entry for "scenario table", "design artifact", or "architect" either.
8. **Only `feature.md.patch` needs a new hunk.** The other three patches' existing `@@` already contain (bug-fix, perf-issue) or trail into (refactoring) the delegation line. That asymmetry is invisible from the SOURCES.md description of patch 13.
9. **The runner prompt is a flat bullet list with no ordering.** `runner-prompt.md:9–18` is ten peer bullets. Change (1) wants an ordered, conditional deliverable spine ("for any design with state… first deliverable is X, then Y, then Z; for stateless code… the usage sketch"). That is a structural change to the file's shape, not another bullet — and it partly *duplicates* `:9` (usage-first), which would then apply only to the stateless branch.
10. **`architect` never names a ticket.** Nothing in `architect/SKILL.md` or its references knows a ticket exists. The skill is invoked from inside a playbook step; the ticket number is the orchestrator's context, not the runner's. A runner told to "post on the ticket under `## Design`" would be the first architect runner that writes outside its own output path — which collides with `arena/SKILL.md:30`'s isolation rule ("N candidates writing to the same path is shared mutable state"). The posting must be the orchestrator's act after synthesis, not the runner's.

## Open Questions

- **Ticket #89's own body.** I did not run `gh issue view 89`; my reading of the five changes is the parent's paraphrase. If the writer needs the exact wording Manuel used (which matters for the "Posted by the agent \<date\>" strings), it should be fetched.
- **Where exactly change (3) lands in `ticket.md`.** New step 6 (renumbering 6→7, 7→8, 8→9) vs. extending the existing step 6 vs. extending step 5. Every choice has a cross-reference cost I listed under Non-Obvious #1; I could not determine the intended one from the ticket text I was given.
- **Whether `issue-tracker.md` must change.** `:18` says "this shape, in this order" and names four readers. Adding `## Testing decisions` to a ticket body without amending that list leaves the doc wrong. The ticket's five changes don't mention it; I judge it required but cannot confirm it was scoped in.
- **Whether `to-tickets` needs to change too.** Change (5) names `to-spec` only. But the table lands on a *ticket* body, and `to-tickets` is the thing that writes ticket bodies (`:84–103`), with no Testing-decisions section. If the table is written at architect time (change 3), `to-tickets` may legitimately stay untouched — but then a spec's scenario table (change 5) has no path down to a ticket other than `## Parent`.
- **Enforcement.** Nothing refuses a PR whose ticket has no scenario table. Whether #89 wants one (a `review-brief.sh` gate, the way the blast-radius gate works) or is content with prose-only is not stated in the five changes.
- **`docs/agents/issue-tracker.md` vs `template/docs/agents/issue-tracker.md`** are two files; I read the template copy whole and confirmed `ticket.md:6` points at the project-relative path. I did not diff the two.
