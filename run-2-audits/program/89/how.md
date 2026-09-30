# The design-artifact path today, and what #89 changes

## Overview

Factory918 has a complete, enforced chain for one kind of design output — `blast-radius` — and no chain
at all for the other. A blast-radius report has a mandated file (`.scratch/<ticket>/blast-radius.md`), a
mandated PR-body section (`## Blast Radius`), and a script that refuses to brief a cross-cutting diff
without it (`template/.agents/skills/spec-review/scripts/review-brief.sh:188` holds the predicate). The
`architect` skill's design package has none of the three. It is produced inside an arena working
directory, consumed by the implementation step in the same session, and then it is gone: nothing writes
it to `.scratch/`, nothing posts it to the ticket, nothing puts it in the PR body, and the Spec reviewer
never sees it. The reviewer grades the diff against the ticket's acceptance criteria alone.

Ticket #89 closes that gap by reusing a mechanism that already exists rather than building a new one:
`review-brief.sh:335` pastes the ticket body verbatim into the Spec brief, so anything appended to the
ticket body under `## Testing decisions` reaches the Spec reviewer with zero script change. The work is
therefore entirely prose — six edits across four skills, two of them requiring brand-new vendor patches,
one landing in a file we own outright, one in four existing patches, plus a knowledge page and the ticket
body-shape doc. No code changes, no new enforcement point. The ticket itself says so: "This ticket
changes prose and patches only, so rule 2 yields no table."

## Key Concepts

**Vendored vs. ours.** `template/.agents/skills/` is rebuilt from scratch by `./factory918.sh sync`
(lines 375–400): every pinned upstream skill directory is `rm -rf`'d and re-copied from `research/`, then
`patches/series` is replayed with `git apply -C template/.agents/skills`. Four files survive that wipe
because `factory918.sh:381` stashes and restores them — `poteto-mode/playbooks/ticket.md`,
`poteto-mode/scripts/overlap.sh`, `spec-review/scripts/review-brief.sh`,
`spec-review/scripts/review-comment.sh`. Those four are ours and are edited directly. Everything else in
that tree is vendored: edit the file, then regenerate a patch, or the next `sync` silently reverts you.

**The patch triplet.** Changing a vendored file means three artifacts, not one: the edited file under
`template/`, a unified diff under `patches/`, and a line in `patches/series`. A fourth, `SOURCES.md`, is
the human description. CI enforces the first three together (see Gotchas).

**Design artifact vs. Testing decisions.** Today these are two unrelated things. `to-spec` writes a
`## Testing Decisions` section on the *spec* issue describing seams; Ticket step 6 (`ticket.md:10`) says
to `tdd` at those seams. `architect` produces a usage sketch and type sketch in a scratch directory.
#89 makes the design artifact *become* the ticket's Testing decisions, which is exactly what happened by
hand on #42 and is recorded as P24 in `docs/knowledge/core/DECISIONS.md:92`.

**Scenario table.** Situations down the side, input shape across the top, and in every cell what is
printed, the exit code, and what the caller does next. The test list is one assertion per cell in the
order written. It exists in the repo today only as consequences: `tests/poteto-mode/overlap.sh:6` names
its cases "in the order of the scenario table in the ticket's design", and `docs/agents/ledger.md:24`
records the cell that was cut on an unverified assumption and came back as a round-two finding.

## How It Works

### Planning: the artifact never gets created

`/to-spec` (`template/.agents/skills/to-spec/SKILL.md`) step 2 at `:15` sketches *test seams* and checks
them with the user in conversation. The spec issue it writes carries `## Testing Decisions` at `:59–65`,
defined as three things: what makes a good test, which modules get tested, prior art. No table, no cells,
no contract. `:55` forbids file paths and code snippets outright, with a narrow prototype exception at
`:57` ("a snippet that encodes a decision more precisely than prose can").

`/to-tickets` (`template/.agents/skills/to-tickets/SKILL.md`) splits the spec into child tickets whose
bodies have exactly four sections — `## Parent`, `## What to build`, `## Acceptance criteria`,
`## Blocked by` (`:84–103`, mirrored in `template/docs/agents/issue-tracker.md:20–24`). The word "test"
does not appear in the file. **Testing decisions are never copied down to a ticket.** The only link is
`## Parent`, which `ticket.md:6` tells the orchestrator to follow.

### Execution: the artifact is created and discarded

`/poteto-mode "#N"` enters the Ticket playbook (`template/.agents/skills/poteto-mode/playbooks/ticket.md`,
24 lines). Step 5 at `:9` routes by content to Feature / Bug fix / Refactoring / Perf issue. That step is
also where the cross-cutting rule lives, and it contains the playbook's *only* mention of `architect`:
"Such a change never skips `architect`."

The actual architect step lives in the sub-playbooks: `feature.md:6` (step 2, unconditional, skip needs a
written reason), `bug-fix.md:9` (step 3, "if it crosses a function boundary"), `refactoring.md:9`
(step 3), `perf-issue.md:16` (step 3).

`architect` then runs three phases. Phase A grounds with `how`/`why`. Phase B (`architect/SKILL.md:32–34`)
hands `references/runner-prompt.md` to N arena runners as their prompt. Each returns a design package:
usage first, then types, signatures, module map, rationale — the ordering rule is a single bullet at
`runner-prompt.md:9` ("Caller's usage first"), sitting as a peer among ten flat discipline bullets
(`:9–18`). None of those ten mentions state, exit codes, refusals, or a test list. Phase C
(`SKILL.md:44–52`) is "Agree (opt-in)": `:46` says the default is to proceed with no human checkpoint;
`:48` names the opt-in phrase **"/architect with checkpoint"** verbatim. That phrase exists nowhere an
orchestrator or a human would look — only inside the architect skill.

Then the artifact stops. `SKILL.md:82–84` names no destination outside the working tree. The arena
candidates live in a worktree or `/tmp/arena-<slug>/candidate-<n>/`. Nothing posts anything anywhere.

### Implementation: the writer is not told about the design

Each sub-playbook's delegation step sends the writer "a specific scope": `feature.md:12` (file paths, a
named data shape per `principle-model-the-domain`, success criteria), `bug-fix.md:9` and
`perf-issue.md:16` (just "a specific scope"), `refactoring.md:11` (file paths, names being moved, behavior
to hold). **None of the four names the design artifact as an input; none says the test comes first; none
says what a writer does when a designed case cannot be implemented as written.** Test-first appears only
in `bug-fix.md:11` (the `tdd` cadence, explicitly skippable) and `refactoring.md:7` (the characterization
pin).

### Review: the brief sees the ticket body and nothing else

`review-brief.sh` resolves the ticket (`:66–80`), fetches its body with `gh issue view --json body`
(`:222`), and separately fetches comments filtered to the issue's own author (`:225`, the jq expression
`.author.login as $a | .comments[] | select(.author.login == $a)`). The Spec brief is assembled at
`:328–342`: `:333` prints the `## The ticket (#N)` heading, **`:335` prints the whole body verbatim**,
`:338`/`:340` add the author's comments under `## Comments by the ticket's author (#N)` with each under a
`### YYYY-MM-DD` date heading. `:349` explicitly tolerates `## ` headings inside a pasted criterion.
`tests/spec-review/review-brief.sh:166–170` pins both pastes.

So the chain #89 relies on already works end to end — there is simply nothing in it today.

```
to-spec ──"## Testing Decisions" (seams, prose)──▶ spec issue
                                                      │ ## Parent
to-tickets ──4 sections, no testing────────────────▶ ticket ──▶ review-brief.sh:335 ──▶ Spec brief
                                                      ▲
architect ──design package──▶ arena workdir ──╳ (dead end today; #89 adds this arrow)
```

## Where Things Live

| # | File / group | Current shape | Ours or vendored | Mechanics |
|---|---|---|---|---|
| 1 | `template/.agents/skills/architect/references/runner-prompt.md` (20 lines) | `:5` deliverable list; `:9–18` ten flat discipline bullets; `:9` is usage-first | **Vendored, unpatched.** Byte-identical to `research/3-pstack/.../skills/architect/references/runner-prompt.md` | **Brand-new patch.** `patches/pstack/architect/references/runner-prompt.md.patch`, a new `series` line, a new `SOURCES.md` concept (next free number is 14; concept 13 already names the four playbooks) |
| 2 | `template/.agents/skills/poteto-mode/playbooks/ticket.md` (24 lines) | 9 numbered steps; `architect` appears once, in step 5 at `:9`; step 6 at `:10` is Testing decisions | **Ours** (`factory918.sh:381` `keep_files`) | Edit directly. No patch. `SOURCES.md:14` calls it "added" by patch 2, which is stale wording — the file is preserved by `keep_files`, not by a diff |
| 3 | `playbooks/{feature,bug-fix,refactoring,perf-issue}.md` | Delegation steps at `feature.md:12`, `bug-fix.md:9`, `refactoring.md:11`, `perf-issue.md:16` | **Vendored, already patched** (`series` lines 8–11) | Extend the four existing 11-line patches. Only `feature.md.patch` needs a **second hunk** — its `@@ -3,7 +3,7 @@` ends before step 4. The other three already contain the delegation line (bug-fix, perf-issue: it *is* the changed line) or trail into it (refactoring step 5 is context). Update `SOURCES.md:25` concept 13 |
| 4 | `template/.agents/skills/to-spec/SKILL.md` (75 lines) | `## Testing Decisions` at `:59–65`; no-snippets rule at `:55`, prototype exception at `:57` | **Vendored, unpatched** (mattpocock pin) | **Brand-new patch.** `patches/mattpocock/to-spec.SKILL.md.patch`; labels `a/to-spec/SKILL.md` / `b/to-spec/SKILL.md` (no rename, unlike `spec-review`) |
| 5 | `docs/knowledge/core/*.md` + `tools/build_knowledge.py` | 5 core docs; `CORE_DOCS` at `:37–43`; `build_core` at `:124–137` | **Ours**, hand-maintained; `docs/knowledge/{spec,pages,notes}/` and `template/docs/factory918/` are generated | Adding a section to `MANUAL.md` or `GLOSSARY.md` costs nothing but a rebuild. A **sixth core doc** costs one `CORE_DOCS` tuple plus the prose that counts them (see Gotchas). A `pages/` entry needs a source file, and every current loader reads `research/` (never-edit) except the spec one (`build_knowledge.py:45`, which reads `docs/FACTORY-SPEC-v2.md`) |
| 6 | `patches/series` (17 lines) + `SOURCES.md` (25 lines) | Order is creation order, not alphabetical or grouped | **Ours** | `series` order only matters when two patches touch the same file; the two new patches are each their file's only patch, so position is free. `SOURCES.md` numbers are *concepts* (13 of them) not files (17), and the list is physically out of order (…8, 11, 10, 9, 12, 13) |
| 7 | `template/docs/agents/issue-tracker.md` + `docs/agents/issue-tracker.md` | `:18` claims "this shape, in this order" and names four readers; five bullets at `:20–24` | **Ours**, two identical copies (verified byte-identical) | Edit the `template/` copy, then copy to the repo-root one (`AGENTS.md`, "Agent skills"). `ticket.md:6` points at the project-relative path |

The ticket's six acceptance criteria map: criterion 1 & 2 → file 1; criterion 3 → file 2; criterion 4 →
file 3; criterion 5 → file 4; criterion 6 → file 5. File 7 is not in the criteria but is required by
consistency — `issue-tracker.md:18` becomes false the moment a ticket body carries a sixth section.

## Gotchas

**The Ticket playbook has no architect step.** Criterion 3 says "The Ticket playbook's architect step".
There isn't one. `ticket.md` mentions `architect` exactly once, in the cross-cutting sentence at `:9`.
The real architect steps are in the four vendored sub-playbooks. Three landing options, each with a cost:
a new step (renumber 6→7, 7→8, 8→9), extend step 5, or extend step 6. **Renumbering is the sharp edge**:
"Ticket step 5" is quoted by name in all four playbook patches, in `SOURCES.md:15,18,21`, and in
`review-brief.sh:183`'s comment; `ticket.md:5` names "step 8" as the `paths: none` check; `ticket.md:12`
is step 8 itself. Extending step 6 is the cheapest — it already owns Testing decisions.

**The ticket-author comment filter.** `review-brief.sh:225` selects comments where `.author.login`
equals the *issue's* author. The ticket offers two routes for the artifact — appended to the body under
`## Testing decisions`, or posted as a comment under `## Design` — and treats them as interchangeable.
They are not. The body paste at `:335` is unconditional; the comment route reaches the reviewer only when
the agent posts from the account that opened the issue. Prefer the body route, or say the constraint out
loud in the prose you write.

**Three spellings of "testing decisions".** `## Testing Decisions` (Title Case) is upstream `to-spec`'s
heading on the *spec* issue at `:59`. "Testing decisions" (sentence case) is Factory918's own prose
everywhere — `ticket.md:10`, `template/AGENTS.md:66`, `GLOSSARY.md:51`, `DECISIONS.md:92`. The ticket
asks for `## Testing decisions` as a *heading on a ticket body*, a third string on a third artifact.
Don't conflate them, and don't "fix" the Title Case one into sentence case — that would be an unrelated
patch hunk.

**`architect` never knows the ticket.** Nothing in `architect/SKILL.md` or its references knows a ticket
exists; the ticket number is the orchestrator's context, not the runner's. A runner told to post on the
ticket would also be the first architect runner writing outside its own output path, which collides with
`arena/SKILL.md:30`'s isolation rule. **The posting has to be the orchestrator's act after synthesis** —
which is why criterion 1 puts the *shape* of the deliverable in the runner prompt and criterion 3 puts the
*posting* in the Ticket playbook. Keep that split.

**"/architect with checkpoint" already exists** verbatim at `architect/SKILL.md:48`, with "no checkpoint"
already the default at `:46`. Criterion 3's stop rule is a restatement of architect's own default, not a
new rule. The genuinely new part is that the table gets posted anyway, without stopping.

**CI catches a wrong patch and a stale knowledge build, in two separate steps**
(`.github/workflows/factory-ci.yml`):
- `:31` — `python3 tools/check_knowledge.py && python3 tools/build_knowledge.py && git diff --exit-code`.
  A core-doc edit without a rebuild fails here, as does a hand-edited generated file (`build_generated`
  `shutil.rmtree`s `spec/`, `pages/`, `notes/` wholesale at `build_knowledge.py:142`).
- `:33` — `./factory918.sh sync > /dev/null && git diff --exit-code && test -z "$(git status --porcelain template)"`.
  This is the one that catches a forgotten patch, a patch that doesn't apply, a `series` line pointing at
  nothing, **and an untracked stray file under `template/`**. Note `cmd_sync` keeps going after a failed
  patch (it prints `FAILED <path>`) and returns non-zero only at the end, so read its whole output.

**Patch regeneration is byte-exact and the labels are load-bearing.** `patches/README.md` gives the
command; the `--label a/<path> --label b/<path>` flags are what make it apply as `-p1`, since `sync` runs
`git apply -C template/.agents/skills`. All 17 checked-in patches reproduce byte-identically with it.
Two naming conventions coexist — pstack patches mirror the tree
(`pstack/poteto-mode/playbooks/feature.md.patch`), the one mattpocock patch is flat and dotted
(`mattpocock/spec-review.SKILL.md.patch`). The name is not load-bearing; `series` carries the path.
Also: `patches/README.md`'s hand instruction `git apply ../../patches/<file>` is off by one level for
this repo (it should be `../../../patches`); `sync` uses an absolute path, so nothing breaks.

**`no-stale-wording.sh`** greps `template` and `docs/knowledge/core` for `## Latent` and "A hard finding
is wrong behavior in normal use" and fails on any hit. New prose about findings in the runner prompt or
the playbooks must not reintroduce either. Note that `review-brief.sh:231` and
`template/docs/agents/review-ladder.md:6` carry the *current* definition word for word — criterion 2's
"refused with the tool's own message" phrasing deliberately mirrors it, so quote the current wording.

**The "five core documents" prose count.** Nothing counts core docs at runtime, but seven prose locations
state the number or enumerate the names: `AGENTS.md:9`, `template/AGENTS.md:5,31`,
`template/.agents/skills/knowledge/SKILL.md:9,13`, `template/.claude/hooks/session-mandate.md:2`,
`template/.agents/skills/factory918/SKILL.md:40,74`, `docs/FACTORY-SPEC-v2.md:186,238`, `README.md:38–39`.
A sixth core doc means editing all of them. `tools/bootstrap/build_template.py:865` also hardcodes the
four names and is **frozen provenance — do not edit it**. Adding a section to `MANUAL.md` (174/220 lines
of headroom) or a `GLOSSARY.md` entry avoids the whole problem. Caveat: `GLOSSARY.md` has an empty
mini-TOC, because `write_chunk` only collects `## `/`### ` lines and the glossary is `**bold term.**`
paragraphs — a glossary entry is findable by `rg` (step 2 of the skill) but never by the TOC step.

**`/knowledge scenario table` reachability has two layers.** The skill (`knowledge/SKILL.md:13`) resolves
`$KB` to `$FACTORY918_HOME/docs/knowledge`, else `~/.factory918/docs/knowledge`, else the project's
`docs/factory918/` (only the four slim core docs). Step 1 reads `INDEX.md`, step 2 greps. So the page must
(a) exist under `$KB` and (b) contain the literal words. Two hits already exist —
`docs/knowledge/core/DECISIONS.md:92` (P24) and its slim mirror — so a new page must outrank them or be
cross-referenced from P24. Two traps: `~/.factory918` symlinks to the **main clone**, so a page added on a
branch is invisible to `/knowledge` from a worktree unless you set `FACTORY918_HOME`; and only core docs
reach a project (`build_core:135` slim-copies every core doc except the one literally named
`CONVERSATION-DIGEST.md`), so `pages/`/`notes/`/`spec/` content is factory-only.

**#89's own diff is not cross-cutting.** `review-brief.sh:188`'s three globs are `*.claude/hooks/*`,
`*.claude/settings.json`, `*.agents/skills/factory918/*`. None of the seven file groups match, so the
implementing PR needs no `## Blast Radius` section and Ticket step 5 does not force `architect` on it.
Note the tension: the ticket's own "Run under" rule 6 ("the Spec reviewer's walk has one line per risk in
the blast-radius grounding") presumes a blast-radius exists. Worth settling with Manuel before the PR.
Rule 8 also requires `shellcheck` on every changed shell file — if the implementation stays prose-only,
no shell file changes and the rule is vacuous. `#42`, the sole blocker, is **CLOSED**, so Ticket step 3
passes.

## Open questions the explorers flagged, and where they stand

1. **Where criterion 3 lands in `ticket.md`** — new step vs. extend step 5 vs. extend step 6. Unresolved;
   the renumbering cost above argues for step 6.
2. **Criterion 5's "through its patch or the factory's copy"** is genuinely ambiguous. Mechanically, any
   edit to `template/.agents/skills/to-spec/SKILL.md` needs a patch; "the factory's copy" may mean
   Factory918's own prose about seams instead (`MANUAL.md:65`). Confirm before writing.
3. **`to-tickets` is not in the criteria** but is the thing that writes ticket bodies, and it has no
   Testing-decisions section. If the table is written at architect time (criterion 3), `to-tickets` can
   legitimately stay untouched — but then a spec's scenario table (criterion 5) has no path down to a
   ticket other than `## Parent`.
4. **Nothing enforces any of this.** No script refuses a PR whose ticket has no `## Testing decisions`,
   the way `review-brief.sh` refuses a cross-cutting diff with no blast radius. The ticket does not ask
   for a gate. If one is wanted later, it is a separate ticket.
5. **A new file inside a vendored skill directory** (say `architect/references/scenario-table.md`) has no
   precedent: it would need either a `/dev/null` create-patch (which `git apply` accepts but
   `patches/README.md`'s command shape does not describe) or a `keep_files` entry. Prefer editing
   `runner-prompt.md` in place, which criterion 1 asks for anyway.
