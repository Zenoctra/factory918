# Cross-judge verdict, ticket #109 arena

Read-only judge, no lanes launched. Every file claim below was checked against the worktree at
`.claude/worktrees/agent-a2ce71454fd0910f0` (a9ebdac).

## Scores

| # | Rubric criterion | A | B |
|---|---|---|---|
| 1 | Five AC met, settled choices not reopened | 4 | 4 |
| 2 | Hook decision sound given the hook's blind spots | 4 | 5 |
| 3 | Table complete, cells testable, every hook cell an `expect` line | 4 | 2 |
| 4 | Safe stays today's behavior with the tier file absent | 5 | 5 |
| 5 | Smallest vendored surface, patch correctness | 5 | 4 |
| 6 | Tier survives an owner in its own worktree | 4 | 5 |
| 7 | Criterion 4's launch bound provable | 4 | 4 |
| | **Total** | **30** | **29** |

## Defects found in B (adversarial read)

1. **The test block is inserted in the wrong phase, and four assertions fail.** B puts its new lines
   "after the planning-phase group at `:131`". At that point `.claude/state/mode` holds `planning`
   (`tests/hooks/delegation.sh:127`), and `guard_write` returns 0 before any policy when the phase is
   not execute (`template/.claude/hooks/delegation.sh:56`); the existing row at `:128` asserts exactly
   that. So B's cells 2A, 3A, 4A and 5A, each `expect 2 "$(write_msg big.sh)" orchestrator Write`,
   get exit 0. Four of thirteen lines fail on the first run. B's own "Next implementation step" is
   "run it green against the unmodified hook", so this is not a cosmetic slip: it falsifies the one
   fact the design rests on being recorded as a passing assertion.
2. **Row 13's linked-worktree cell cannot produce a block.** B sets `CLAUDE_PROJECT_DIR="$fx/../wt"`
   and reuses the same `path big.sh` helper, which emits `$fx/big.sh`. The hook resolves `root` from
   `CLAUDE_PROJECT_DIR` (`delegation.sh:23`), and `relative()` returns 1 for any path outside `root`
   (`:41`), so `Write` exits 0 at `:203`. Expected 2, gets 0. A fifth failing line.
3. **The row-13 fixture leaks outside the trap.** `git worktree add ../wt` writes a sibling of the
   `mktemp -d` dir; `trap 'rm -rf "$fx"' EXIT` (`:9`) never removes it. Every run of the test would
   leave a worktree behind, and the second run would fail on an existing path.
4. **False claim about the architect patch.** B: "the existing `patches/pstack/architect/SKILL.md.patch`,
   whose hunk already covers the Phase B block at `:29-35`". The hunk header is `@@ -29,7 +29,7 @@`,
   and "Design it twice." is `template/.agents/skills/architect/SKILL.md:36` — outside it. The edit
   regenerates as a second hunk. Harmless to the design, but the stated justification is wrong.
5. **Off-by-one line cite.** "1D is `:118-125`": the sub-agent group starts at `:117`
   (`expect 0 "" agent Write "$(path big.sh)" "sub-agent Write to big.sh"`).
6. **Column B does not test what it names.** The column is "root runs `review-brief.sh <fp>`", but
   every cell is asserted as a `Write` of `.claude/state/review/files`. The actual call an eco owner
   makes, `Bash bash .../review-brief.sh main`, is never fed to the hook. A's B6 does feed it.
7. **`interrogate` is missing from the launch count.** `playbooks/feature.md:16` step 7 launches lanes
   for a contested design. B's derived table has no row for it, so criterion 4's cap is unproven for
   exactly the ticket shape where it matters. A caught this (its C7) and flagged it as an open question.

## Defects found in A (adversarial read)

1. **Off-by-one insertion cite.** "after the sub-agent block (line 126) and before `echo planning`
   (line 128)": the sub-agent group ends at `:125`, `:126` is blank, `echo planning` is `:127`. The
   insertion point is correct and in the execute phase with review state live, so all nine rows pass
   as written — only the numbers are wrong.
2. **Two of the nine rows are duplicates.** B7 and B8 are byte-identical in call and expectation to
   the existing `:112` and `:115`. Real new coverage is seven rows, not nine.
3. **The safe side of the new cells is never asserted.** A's left column is "covered by class", but
   B1 and B3 write to `small.md`, which no existing row writes to. B's fixture-per-tier-value shape
   (safe / eco / unreadable, same call) is the better one and A should take it.
4. **A footgun in the prose an owner reads.** A's Ticket step 0 bullet hands the owner
   `[ "$(cat .claude/state/tier 2>/dev/null)" = eco ]` and then tells it not to run the command. An
   owner in `.claude/worktrees/agent-*` that runs it anyway gets no file and silently reads `safe`
   inside an `eco` program. B's common-dir form makes that impossible.
5. **Broken sentence in the MANUAL paragraph**: "so owning small fixes is an autopilot-stack owner's".
   `/unslop` before it ships.

## Claims checked and found true (both candidates)

`overlap.sh:22` is `prog="$(git rev-parse --git-common-dir)/../.claude/state/program"`; `.gitignore:7`
and `template/.gitignore.factory:5` both hold `.claude/state/`; `patches/README.md:7-9` is the `diff -u`
regeneration form; both patch files exist and are already in `patches/series`, so neither candidate
needs a new series line; `SOURCES.md` item 11 is autopilot-stack step 1 and item 14 is architect Phase B;
the hook facts (`:9-11` seven fields, `:15` sub-agent bypass, `:47` `.claude/state/*` untracked, `:56`
phase gate, no `new_string`/`content` parsed, `tokens()` dropping heredoc bodies at `:109-113`, the
`7,$p` address at `:22`); `write_msg` `:30`, `diff_msg` `:31`, `review_msg` `:33`, `:65`, `:86`;
`MANUAL.md:77` is the `/poteto-mode "#42"` paragraph and `:79` is **Several at once.**; P110's id rule
gives `P109`; autopilot-stack step 7 is the one page under five headings (`## Head`, `## Criteria`,
`## Review`, `## CI`, `## Flags`); `ticket.md` step 0 has four bullets, so "a fifth bullet" is right in
both; `ticket.md:38` is "Two runners; the judge is skipped when they converge."

## Convergence

Both candidates independently take criterion 3's second branch (no hook change, root-run small fixes
still go to a fix lane) on the same evidence, and both put the tier in `.claude/state/tier`, keep
`mode.sh` untouched, and leave `review-brief.sh` alone. That agreement is the strongest signal in the
arena; treat the hook decision as settled and spend the synthesis on placement, pointers and the test.

## Recommended base: A

Not because A is better designed — B's contract, placement and hook rationale are both sharper — but
because of what the ticket makes load-bearing. Criterion 3 says the assertions are written before the
hook changes, and the whole design's claim is that they pass green against an unmodified hook. A's nine
rows do. Five of B's thirteen do not, and the two broken ones are broken for structural reasons (phase
state, and the hook's root resolution) that a reader would only find by running it. A also has the
smaller vendored surface (one file against two), which rubric item 5 rewards directly, and it is the
only candidate that noticed `feature.md:16`.

## Grafts from B, each with its reason

1. **The path form.** Replace A's bare `.claude/state/tier` with
   `"$(git rev-parse --git-common-dir)/../.claude/state/tier"`, B's contract. It is the resolution
   `overlap.sh:22` already uses for the go registry, so it is a precedent rather than a new pattern,
   and it turns A's worktree answer from a convention an owner must obey into a mechanism. Keep A's
   `Tier: eco` digest line on top of it as the frozen copy, with B's explicit "the brief wins"
   precedence so the two readers can never disagree mid-run. Fixes A defect 4; wins rubric 6.
2. **Pointer sentences at the point of use.** B points at step 0 from Ticket steps 5, 6, 8, the Design
   hole and the Reply line. That is P105's actual pattern ("stated once ... and every playbook step
   that launches a lane points at it in one sentence"). A points only from step 0 and the Design hole,
   which leaves step 8's review branch reading as safe to an owner executing it.
3. **The fixture-per-tier-value test shape.** Keep A's insertion point (after `:125`, before `:127`,
   where the phase is execute and review state is live) and A's call set, but assert each call under
   three fixtures — no file, `eco`, and a junk value — the way B does. That gives the invariance a
   before/after pair instead of A's unasserted "by class" left column. Drop A's B7/B8 duplicates.
   Do not take B's row 13; if the worktree cell is wanted, it needs a fixture inside `$fx` whose
   `path()` resolves under the emulated root, and it belongs in a separate ticket.
4. **The hook rationale's framing.** B's "a widening rule survives the routes the hook cannot parse,
   a narrowing rule fails open on every one of them" is the sentence that makes the decision defensible
   rather than merely convenient. Put it in the DECISIONS P109 Reason cell.
5. **The five headings, named.** B cites autopilot-stack step 7's `## Head` / `## Criteria` / `## Review`
   / `## CI` / `## Flags` explicitly; A says "step 7's page". Name them, so "one page" is checkable.
6. **The architect sentence.** Take B's one-clause addition after "Design it twice." through the
   existing `patches/pstack/architect/SKILL.md.patch`, with the claim corrected: it is a second hunk,
   not the existing one. Worth the second vendored file, because Phase B's "Require at least two
   structurally distinct candidates before synthesis" is an imperative in the file the eco owner opens
   at that exact step, and A's answer to it is only a tradeoff note.

## Rejected from B, with reasons

- **The `= row 3` cells** (5B-5D, 6A-6D) as unasserted. The justification is sound, but A's habit of
  writing the row and running it is cheaper than the argument, once the fixture is right.
- **B's grep-rejection as a reason to drop A's second walk.** B is right that a grep over prose passes
  a reworded wrong sentence, so make A's launch-word grep a discovery aid in the PR's Verification, not
  the proof. The proof is the derived per-launch-point table plus A's trail row per launch, which is the
  one mechanism either candidate offers for counting a live run.

## Carry forward into the synthesis

A's open question about `why` and `feature.md:16`'s `interrogate` is unresolved in both packages and is
the largest remaining hole in criterion 4: neither candidate's count survives a contested design. Decide
it, or say in the contract that an eco ticket reaching step 7 leaves the cap.
