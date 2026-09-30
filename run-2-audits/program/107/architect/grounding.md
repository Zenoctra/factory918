# Grounding for #107 (reading pack in the review briefs)

Ticket: `gh issue view 107 --repo Zenoctra/factory918` (read it whole; five criteria). Script:
`template/.agents/skills/spec-review/scripts/review-brief.sh` in the owner's worktree
`/Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.claude/worktrees/agent-a259c8b9e8547f7dd`
(branch `feat/review-reading-pack`, head 0edf8c8). Test: `tests/spec-review/review-brief.sh` there (fixture
helpers `has`, `lacks`, `printed`; `suite project|factory` runs everything twice, in a temp repo laid out by
`tests/spec-review/layout.sh`). SKILL.md step 4 is `template/.agents/skills/spec-review/SKILL.md`, vendored:
changed through `patches/mattpocock/spec-review.SKILL.md.patch`.

## How the script works today (the part #107 touches)

- The diff range is `git diff "$fixed...HEAD"` (three dot, so new-side line numbers are HEAD's). In a fix-only
  round (round three after `fix only after <sha>`, rounds four and five after `would-break fixed after <sha>`)
  `$fixed` is that sha, so the diff is the fix commits alone. The sweep form (`--paths P... --commits SHA...`)
  sets `fixed=paths` and the diff is `git show <commits> -- <paths>`.
- `<dir>/files` is `git diff --name-only` (rename detection on by default config). `<dir>/reviewed` is HEAD.
- `common()` writes, in both briefs: the read-nothing line, `## Commits`, `## Changed files`, `## The fix under
  review` (fix-only rounds), `## Blast radius` (cross-cutting), `## Diff` (inline in a ```diff fence under 500
  lines, else the path `<dir>/diff`), `## Settled in earlier rounds` (when something carries).
- `report_rules()` writes `## Report`, the definition, Manuel's five sentences, then the shape sentence; each brief
  then writes its headings, item form, step rule, spec rule, report path, count rule.
- SKILL.md step 4 carries several script strings word for word and the test asserts each copy (drift guard).
- Constraints from the tickets below this one: every cell of #93's tables, #106's tables and #90's table keeps
  its outcome (the test holds them). #106 asserts rounds one and two print byte for byte the same with its
  comment lines deleted: that compares two runs of the new script, so a pack does not break it. #108 will stack
  on this PR and change the same script, so keep the change a self-contained unit.

## The owner's draft design (attack it; replace any part you can beat)

Section `## Reading pack` in `common()` right after `## Diff` (before Settled), in both briefs, every round.

Per changed file (`git diff -M -z --name-status "$fixed...HEAD"`, in that order):
- binary (numstat `-`), generated (`git check-attr linguist-generated` set or true), deleted at HEAD, not a blob
  at HEAD (submodule): one line naming the path and why; carries no text.
- up to FILE_MAX = 300 lines at HEAD (`git show HEAD:<path>`): the whole file.
- longer, added by the diff: one line, the diff carries it whole.
- longer, otherwise: ranges from `git diff -U0 -M "$fixed...HEAD" -- <path>` (old and new path for a rename)
  hunk headers, new side; a pure deletion `+c,0` maps to line max(c,1). Each changed line maps to a unit:
  - Markdown (`.md`, `.markdown`): the section from its nearest heading (`^#{1,6} ` outside fenced text) to the
    line before the next heading of any level; lines above the first heading are a section.
  - shell (`.sh`, `.bash`, or a shebang naming sh or bash): the enclosing function, from a column-0
    `name()` / `function name` line to the first column-0 `}` line (a one-line function is its own line).
  - a unit longer than FILE_MAX, a line outside any function, or any other file type: WINDOW = 20 lines either
    side of the line, clipped to the file.
  Units per file are merged when they overlap or touch; each merged range is one entry.
  No changed lines (mode only, pure rename): one line saying so.
- Each entry: a line `### `path` lines a-b of N` (or `whole, N lines`), then the text in a fence of backticks one
  longer than the longest backtick run opening any line of the text (at least three), no info string.
- TOTAL = 1500 lines of carried text. Entries are taken in order; at the first entry that does not fit, the pack
  stops and one line lists every entry not carried (path and range) as paths to read from the repository at HEAD.
- Sweep form: the section holds one line saying the sweep carries no pack (files at HEAD are not the code the
  older commits changed).
- The Report section of both briefs gains one sentence, after Manuel's five sentences: the pack is the code to
  read, and the repository is opened only for what the pack does not carry. SKILL.md step 4 gets a bullet naming
  the section and the three cutoffs, and the sentence word for word; the test holds both copies.

Open questions the owner has not settled: whether FILE_MAX 300 / WINDOW 20 / TOTAL 1500 are right (the brief's
diff inline cutoff is 500 lines; a reviewer lane is Claude Opus 5 or 5.5); whether the existing "Read nothing
beyond this brief unless a finding needs the code around a hunk" sentences should change; whether "stop at the
first overflow" beats "skip and keep filling"; whether a large file's top-level shell code deserves a better unit
than a window (review-brief.sh itself is 548 lines, almost all top level, with no blank lines between blocks;
tests/spec-review/review-brief.sh is 1398 lines, nearly all inside one function `suite()`); whether
`linguist-generated` is the right test for generated (the factory has no .gitattributes today; its generated
paths are `docs/knowledge/spec/`, `pages/`, `notes/`, `template/docs/factory918/`); what the header line format is.
