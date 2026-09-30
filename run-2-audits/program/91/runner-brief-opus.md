# Architect runner brief: the scenario table for ticket #91

You are one of two architect runners (read-only: edit nothing in the repository, run no git command that writes, launch no agent). Produce a design package and write it to the output path given at the end; reply with only that path.

## The ask

Ticket #91 on Zenoctra/factory918, "The Spec walk covers every blast-radius risk". Read it whole: `gh issue view 91 --repo Zenoctra/factory918`. Its `## Run under` rule 2 says the architect step writes a scenario table before any code: situations down the side, the shape of the input across the top, and in every cell what is printed, the exit code and what the caller does; a cell for an input outside the intended path reads "refused with the tool's own message" and costs no code. The ticket says: "This ticket has state (a grounding present or absent, in a file or a body, with headings at two levels), so rule 2 yields a small table: situations are those forms, the input is the diff being cross-cutting or not, cells name what the brief contains."

The worked example of the artifact is ticket #42's `## Testing decisions` (`gh issue view 42 --repo Zenoctra/factory918`, the `## Scenario table` and `## Contract` parts): read it for the shape (the cell legend, the row and column labels, the contract paragraph naming the exact command forms, exits and messages). Your table is smaller.

## The code you design against

The branch `feat/spec-walk-risks` is checked out here at the head of PR #99 (ticket #90); it is the base your design lands on. Read:

- `/Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.claude/worktrees/agent-a1fb85ddeb81fc326/template/.agents/skills/spec-review/scripts/review-brief.sh` whole. The crossing predicate, the grounding extraction (`--blast-radius FILE`, else the PR body's `## Blast Radius` section, cut at the next `## `), `blast_rule`, `common()`, the Spec brief's Walk bullet (a literal `echo` in the Spec brief block), `step_rule`, `spec_rule`.
- `/Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.claude/worktrees/agent-a1fb85ddeb81fc326/template/.agents/skills/spec-review/scripts/review-comment.sh`: `items()` skips `## Walk`; walk lines are steps, never items, never counted.
- `/Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.claude/worktrees/agent-a1fb85ddeb81fc326/tests/spec-review/review-brief.sh` whole: the helpers `has`, `lacks`, `printed`, the `pr()` fixture, the blast-radius cases at the end (a `--blast-radius blast.md` file, a CRLF PR body with a fenced `## ` line, an empty section, a README-only diff), and the block that asserts the source `SKILL.md` carries each rule word for word (`definition`, `step_rule`, `spec_rule`, `count_rule`, `settled_rule`, `blast_rule`, the heading bullets).
- `/Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.claude/worktrees/agent-a1fb85ddeb81fc326/template/.agents/skills/spec-review/SKILL.md` step 4 (both briefs, the Spec brief's Walk bullet, the blast-radius paragraph). `SKILL.md` is vendored: it changes only through `patches/mattpocock/spec-review.SKILL.md.patch`.
- `/Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.claude/worktrees/agent-a1fb85ddeb81fc326/template/.agents/skills/poteto-mode/playbooks/opening-a-pr.md`, the `## Blast Radius` bullet, and `patches/pstack/poteto-mode/playbooks/opening-a-pr.md.patch`; `template/.agents/skills/poteto-mode/playbooks/ticket.md` step 5 (which says the PR body's section is the file "verbatim").
- `/Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.claude/worktrees/agent-a1fb85ddeb81fc326/template/.agents/skills/blast-radius/SKILL.md`: the hand-back shape a grounding file follows (what it does; the one fact; risks; cleared; before you merge) and how its Risks are written (numbered, bold title, `file:line`). PR #92's body is a real grounding pasted into a PR with its inner headings demoted to `###` (`gh pr view 92 --repo Zenoctra/factory918 --json body -q .body`, the `## Blast Radius` section, `### Risks` with four numbered risks).

## What the design must settle

The four acceptance criteria, verbatim from the ticket, are the finish line. Settle in the table and the contract:

1. Where the risk rule is written (the Spec brief only; the Standards brief has no Walk) and its exact sentence. The ticket asks for "after the lines per documented step, one numbered line per risk under the grounding's Risks heading, each saying what the diff does at that risk". Decide whether the sentence names the heading form found (`## Risks` or `### Risks`) and whether it names the risk count; say what each choice costs the test's word-for-word check against `SKILL.md` (a fixed sentence is pinned as one string; a sentence with a variable part is pinned as its fixed parts).
2. How the Risks heading is found: outside fenced text (the shared `fenced` awk), at level 2 or 3, the first one; whether the source (file or body) restricts the level or either level is accepted from either source.
3. A grounding present with no Risks heading: refused before any state (with what message, saying how to correct it), or the rule written anyway. Say which and why; a refusal is a cell that costs no code beyond the message.
4. The absent case: a diff that is not cross-cutting writes no risk rule, with or without `--blast-radius` (the existing stderr line stays).
5. The prose: `SKILL.md` step 4's Spec Walk bullet (through the patch) and the Opening a PR `## Blast Radius` bullet (through its patch) saying the inner headings are demoted to `###` when the file is pasted; whether `ticket.md` step 5's "verbatim" changes (it is not vendored; it is kept by `sync`), and `SOURCES.md` items 3 and 6 which describe the two patches.
6. `review-comment.sh` is unchanged (criterion 3 is a regression check: a walk with risk lines still counts nothing).

## Output shape

Write one Markdown file with, in this order:

1. `## Usage` — the caller's usage first: the command lines an orchestrator runs (`review-brief.sh HEAD~1 --blast-radius blast.md`; `review-brief.sh <fixed> ` with a PR whose body carries the section), what stdout and stderr say in each case, and the exact text the Spec brief carries after the Walk bullet.
2. `## Scenario table` — a legend line, then a Markdown table: situations (the forms the grounding takes, including present-without-Risks, Risks inside a fence, both heading levels present, and the absent case) down the side; the input across the top (A. cross-cutting diff; B. not cross-cutting); each cell: what the Spec brief contains / exit / what the caller does. Cells outside the intended path read "refused with the tool's own message" and name the message.
3. `## Contract` — the exact rule sentence(s) the script emits, the detection rule (fence, level, first match), the refusal message, which files change (script, test, `SKILL.md` patch, `opening-a-pr.md` patch, `SOURCES.md`, `ticket.md` if at all), and the test plan: one assertion per cell, named by row/column, added to `tests/spec-review/review-brief.sh` (say which existing fixtures each reuses).
4. `## Rationale` — under 250 words: why this shape, what you rejected.
5. `## Open` — anything the ticket does not settle and your default.

Under 1200 words in total. No implementation code; a two-line sketch of the detection (the awk or grep) is allowed in the contract.

Output path: /Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.scratch/program/91/architect-opus.md
