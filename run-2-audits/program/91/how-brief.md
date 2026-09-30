# How brief: the blast-radius grounding inside spec-review's brief assembly

You are the `how` explainer lane (read-only; edit nothing, run no git command that writes, launch no agent). Answer one question for a senior engineer about to change this subsystem, at the level of a working mental model, not annotated source. Write the explanation to `/Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.scratch/program/91/how.md` and reply with only that path.

The question: how does `review-brief.sh` decide a diff is cross-cutting, obtain the blast-radius grounding (from `--blast-radius FILE` or from the PR body's `## Blast Radius` section), and place it in the two reviewer briefs; how does the Spec brief's `## Walk` rule reach the reviewer and how does `review-comment.sh` treat walk lines; and how do the test and `SKILL.md` pin the wording the script emits.

Read these files in this checkout (the branch `feat/spec-walk-risks`, at the head of PR #99, is checked out here):

- `/Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.claude/worktrees/agent-a1fb85ddeb81fc326/template/.agents/skills/spec-review/scripts/review-brief.sh` (whole)
- `/Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.claude/worktrees/agent-a1fb85ddeb81fc326/template/.agents/skills/spec-review/scripts/review-comment.sh` (the `items`, `count`, `report` functions and the Walk handling)
- `/Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.claude/worktrees/agent-a1fb85ddeb81fc326/template/.agents/skills/spec-review/SKILL.md` (steps 1, 4, 5, 6)
- `/Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.claude/worktrees/agent-a1fb85ddeb81fc326/tests/spec-review/review-brief.sh` (whole: the fixtures, the `has`/`lacks`/`printed` helpers, the blast-radius cases near the end, and every place the source `SKILL.md` is asserted to carry a wording)
- `/Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.claude/worktrees/agent-a1fb85ddeb81fc326/tests/spec-review/layout.sh` and `fake-gh.sh`
- `/Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.claude/worktrees/agent-a1fb85ddeb81fc326/patches/mattpocock/spec-review.SKILL.md.patch` (how `SKILL.md` is changed: it is vendored, so only through this patch)
- `/Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.claude/worktrees/agent-a1fb85ddeb81fc326/template/.agents/skills/poteto-mode/playbooks/opening-a-pr.md` (the `## Blast Radius` bullet) and its patch `patches/pstack/poteto-mode/playbooks/opening-a-pr.md.patch`
- `/Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.claude/worktrees/agent-a1fb85ddeb81fc326/template/.agents/skills/blast-radius/SKILL.md` (the hand-back shape: which headings a grounding file carries)

Cover, with `file:line` for each claim:

1. The crossing predicate and where the grounding comes from in each case; how the PR-body extraction ends the section (which heading level ends it) and what that means for the grounding's own headings when pasted into a PR body (PR #92's body demoted them to `###`; PR #87 is the earlier example).
2. Where in the brief the grounding lands and under what fixed paragraph (`blast_rule`); the order of sections in `common()`.
3. The Spec brief's Walk bullet: the exact text, where it is written, whether it is a variable or a literal, and how the test at `tests/spec-review/review-brief.sh` asserts the bullets against the source `SKILL.md`.
4. How `review-comment.sh` treats `## Walk` lines (steps, never items; the `items()` awk) so a longer walk changes no count.
5. The fence rule the two scripts share and how a `## Risks` or `### Risks` line inside a fenced hunk would be read.
6. What in the test fixtures is reusable for a new case (the `blast.md` fixture, the `pr-body.md` CRLF fixture, the `pr()` helper, the `--previous` path) and how many assertions the test currently reports (`ok N assertions`; run `bash tests/spec-review/review-brief.sh` from the checkout root, it is read-only over the repo and works in a temp dir).
7. Anything non-obvious a newcomer would get wrong.

Keep it under 900 words. Plain prose, no headings deeper than `##`.
