# Architect Phase B brief, ticket #106, design hole at table B row 2 column B ("inside the fix")

Scope: only the meaning of "inside the fix" (the ticket's Terms: "fix lines", "quoted lines", "inside the fix") and the table cells, tests and code that rest on it. Nothing wider is redesigned.

Read, read-only:
- The ticket: `gh issue view 106 --repo Zenoctra/factory918 --json body -q .body`, section `## Testing decisions` (Terms, tables A and B, Contract, Tests).
- The hole, reproduced: "/Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.scratch/program/verify/125-caecbc4/worker-audit.md" section 7, and the runtime note on quoted `---`/`+++` headers in `worker-runtime.md` (Notes, first bullet) in the same directory.
- The code at PR #125's head, worktree "/Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.claude/worktrees/agent-aa93144dff7a44365": `template/.agents/skills/spec-review/scripts/review-comment.sh` (`outside()`), `review-brief.sh` (the `fix-lines` block after `git rev-parse HEAD > "$dir/reviewed"`), and the tests `tests/spec-review/review-comment.sh`, `tests/spec-review/review-brief.sh`.
- What reviewers actually quote: the real reports under `tests/eval/reviewer/rounds/*/review/standards-report*.md` and `spec-report*.md` in that worktree. Look at how Would-break and Fails-open items quote code (plain code blocks? diff hunks with `+`/`-`? `file:line` in the body?), and base the rule on that evidence; cite two or three examples.

The bar, from the root (non-negotiable):
- A plain-code quote (no `+` or `-` lines), or an item located at a `file:line` outside the fix's changed ranges, must never read as inside.
- Fail safe toward a whole-diff round three in every uncertain case. Quoted `---`/`+++` headers already make an item outside; keep that.
- Criterion 1 still holds: the round-one and round-two briefs stay byte for byte what they were at the patch base (no new report rule in them). The decision is the script's, from the reports and the fix commits, never from the judgment.
- Manuel's words the rule serves: "at least one pass goes with zero new happy path hard bugs found before we commit ourself to diff only reviews."

Candidate from the owner, to weigh against your own (reject it if the evidence says so):
- Fix lines become "identifying" fix lines: an added fix line counts only when its text occurs exactly once across the HEAD versions of the files round two's whole diff touches (`<dir>/files`), a removed one only when its text occurs nowhere in those files at HEAD and once in the fix-changed files at the RV commit. Short or repeated texts (`exit 0`, `else`, `done`) then locate nothing.
- Inside iff the quote has at least one marked line, and every marked line's text is an identifying fix line. Unmarked lines are neutral. No marked line: outside.
- Additionally, `review-brief.sh` writes `<dir>/fix-ranges` (`path start end`, new-side ranges of `git diff -U0 <rv> HEAD`), and any `path:N` in an item's unfenced text (other than its `Documented step:` and `spec:` lines) naming a file in `<dir>/files` at a line outside those ranges makes the item outside.
Say whether the location check earns its code, given the marked-line rule; whether uniqueness should be across `<dir>/files` or the whole tree; what a reviewer's typical quote shape means for how often fix-only fires.

Also settle point 2 from the root: table A cells 6B, 6C, 7C, 8B, 8C, 9B, 9C, 10B, 10C, 11B, 11C, 12B, 12C, 13C, 15C, 16B, 16C, 17C, 18B, 18C, 19B, 19C, 20B, 20C, 21A and 21B have outcomes and no assertion. For each, either name the assertion or say in one line why it needs none (for example, a column that differs from A only by an input path the existing 5B/5C assertions already exercise). Prefer assertions when cheap.

Deliverable: the amendment, written as it will be appended at the end of the ticket's `## Testing decisions` section, never rewriting an existing line: one line `Amended 2026-09-23 by #125 (review round 1, hole at table 2/B): <what changed and why>; <which assertions moved>`, then the replacement Terms paragraphs for "fix lines", "quoted lines" and "inside the fix" under `### Terms (amended 2026-09-23)`, the replacement table B rows it changes (full rows, same columns) under `### Table B rows (amended 2026-09-23)`, the new or changed Contract pieces (exact awk/shell) under `### Contract (amended 2026-09-23)`, and the test list changes under `### Tests (amended 2026-09-23)` including the reproduction as a cell and the point-2 disposition. Then, after a rule line, a short section for the owner: the options you rejected and why.

Write to the absolute path in your prompt and reply with only that path. Read-only: edit no repository file, post nothing.
