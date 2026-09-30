verdict: PASS+NOTES

Slice: live runtime floor, PR #136 (ticket #108) at `6e5c539f44f90a341495aaf4bb3b44dd7b6e16c8`.
`git merge-base --is-ancestor a9ebdac HEAD` -> exit 0. Setup: the `tests/spec-review/layout.sh` project layout in a
private `/tmp/v108-runtime`, the fake `gh` from `tests/spec-review/fake-gh.sh` on PATH, `FAKE_ISSUE_BODY` supplying
the ticket body, a private `TMPDIR`. Every run was built from the repo's own harness; nothing under version control
was written except the (e) run, whose `.scratch/review/a9ebdac` and `.claude/state/review` I removed afterwards
(`git status --porcelain` clean).

## (a) the risks site

Fixed point `HEAD~1` (the cross-cutting hook commit), `--blast-radius r-*.md`, one risk under `## Risks`.

- no disposition -> exit 1, `no disposition: 1. A subagent inherits it: ...`, no `.claude/state/review`,
  no `.scratch/review/HEAD_1`.
- `fixed: 6692641ca184...` (HEAD, a real commit in the diff) -> exit 0, both briefs written.
- `fixed: 6692641` (7 hex) -> exit 0. The `7,40` grep and `rev-parse --verify` both take the short form.
- `fixed: deadbeef...` (40 hex, resolves nowhere) -> exit 1, `does not resolve to a commit here`, no state.
- `fixed: abc12` (5 hex) -> exit 1, `is not a commit id (7 to 40 lowercase hex characters)`, no state.
- `fixed: <a commit outside HEAD's history>` (`git commit-tree` of HEAD's tree, no parent) -> exit 1,
  `is not in HEAD's history`, no state. (Run at the flags site; one code path.)
- `accepted: the hook is a fixture` -> exit 0.
- `accepted:` with nothing after -> exit 1, "`accepted:` has no reason", no state.

Every refusal printed the two leading lines (`ticket: #7`, `round: 1 of 3`) and then the header, and wrote neither
`.claude/state/review` nor `.scratch/review/HEAD_1`. Exit code 1 in all cases.

## (b) the flags site

A fixed point over a plain file, so the diff is not cross-cutting; `--ticket 7`, `FAKE_ISSUE_BODY` the fixture.

- a ticket with no `Writer flags` list -> exit 0, briefs written, byte for byte what a9ebdac prints (see (d)).
- `### Writer flags 2026-09-23` with a bare flag -> exit 1, `no disposition: - The walk skipped step 4.`, no state.
- the same list with `accepted: out of scope` and `fixed: <HEAD>` -> exit 0.
- near-misses refused, each naming the line: `## Writer flags 2026-09-23` (level 2),
  `#### Writer flags 2026-09-23` (level 4), `### Writer Flags` (no date).
- a second dated opener whose list has a bare flag -> refused naming that flag.
- a disposition on the next line at column 0 -> refused on the first line, as the contract's B5 says.
- a CRLF body -> the CR is stripped and the bare flag is still caught.
- a tab before `accepted:` -> accepted, the reason read from after the tab.

## (c) adversarial: what still passes a flag with no real disposition

Four shapes let a bare flag through. Three are the grammar's own escape hatches; one is a gap.

1. **An unclosed fence anywhere before the opener swallows the whole list, silently.** A ticket body with a shell
   fence opened under `## Notes` and never closed, then `### Writer flags 2026-09-23` and a bare flag -> **exit 0**,
   briefs written, nothing reported. The same for a fence opened before the heading and closed after the list. The
   `fence` offender is emitted only when the fence opened inside a list (`opened = on ? $0 : ""`,
   `template/.agents/skills/spec-review/scripts/review-brief.sh:171`), so the owner's S1 covers one half of this
   case and not the other.
   The risks site does not have this gap: the pre-existing "no Risks heading outside fenced text" check refuses
   both shapes there (verified, exit 1 for each). The asymmetry is that the flags site has no such precondition --
   a ticket with no opener is legitimately unaffected, so a hidden opener is indistinguishable from no opener.
   Mitigation: an unclosed fence renders the rest of the ticket as code on GitHub, so a human can see it.
   Severity: a silent gate bypass reachable by an ordinary ticket-body typo. Worth a ticket, not a blocker.
2. **A heading that misses the site's word is invisible**, such as `### Writer-flags 2026-09-23` or
   `### Writer flag 2026-09-23` (singular) -> exit 0 with a bare flag under it. The near-miss rule keys on
   `index(x, "writer flags") == 1` (`review-brief.sh:178`), so only a heading that still starts with the exact
   words is caught. Same class as 1, smaller: every near-miss that keeps the words (a trailing `:`, trailing text,
   the wrong level, the wrong case, bold) is caught, verified.
3. **A deeper-indented flag is a continuation and is never read**: `- One. accepted: fine` then
   `  - a bare nested flag` -> exit 0. This is the documented rule ("indent a continuation"); a writer who nests
   sub-flags loses the gate on them.
4. **A whole list inside a closed fence** passes as an empty list -> exit 0. Documented ("fence a proof"); table
   C6 asserts it.

Shapes that do not slip: prose holding `fixed:` (`... is not fixed: it stays stale`) refuses as "not a commit id";
a duplicated opener; CRLF; a bad-length or non-ancestor sha; a disposition on the next line; non-ASCII in the
reason (`accepted:` with accents, an em dash and a check mark -> exit 0, correctly).

One asymmetry worth recording: prose holding `accepted:` **does** satisfy the gate
(`- The reviewer accepted: nothing here is a disposition, this is prose.` -> exit 0), while the same prose with
`fixed:` refuses. That follows the contract ("`accepted:` takes a non-empty reason") and is not a bug, but it means
`accepted:` cannot be told from prose, so the flag it guards is only as good as the writer's intent.

## (d) composition with #106 and #107

The a9ebdac copy of the skill (`git archive a9ebdac template/.agents/skills/spec-review`) run beside the HEAD copy
on the same repo with the same fixtures; stdout, stderr, exit code and both briefs diffed:

- a plain, non-cross-cutting diff against {a ticket with no flags list, the stock fake ticket, no ticket, a ticket
  with dispositioned flags}: **identical, byte for byte**, in all four.
- a cross-cutting diff with a dispositioned grounding against {no flags list, no ticket, the stock ticket}:
  identical except the one intended line, the Spec brief's Walk bullet, where the risk sentence gains "and saying
  whether the diff honors the disposition...". Nothing else moved, the reading pack included.
- `bash tests/spec-review/review-brief.sh` -> `ok 1720 assertions`, exit 0 (it covers #91, #93, #106's fix-only
  round three, #107's reading pack and #108's tables A, B and C).
- `bash tests/spec-review/review-comment.sh` -> `ok 298 assertions`, exit 0.
- `bash tests/spec-review/no-stale-wording.sh` -> `ok: no stale wording`, exit 0.

## (e) the live ticket #108

In the worktree at the SHA, with the real `gh`:
`bash template/.agents/skills/spec-review/scripts/review-brief.sh a9ebdac --ticket 108` -> **exit 0**, briefs
written. Ticket #108's own `### Writer flags 2026-09-23` list (11 numbered flags, each ending `accepted: ...`)
passes, and its prose mentions of "Writer flags" (criterion 2, the table B and C column text, the contract) are not
near-misses: the C7/f promise holds against the live body. stderr carried only the expected
`gh could not read the PR's review comments (could not determine current branch...)`, my worktree being detached.
Note: this PR's own a9ebdac..HEAD diff is **not** cross-cutting under the predicate at `review-brief.sh:378`
(it touches `template/.agents/skills/spec-review/`, `patches/` and `docs/`, none of `*.claude/hooks/*`,
`*.claude/settings.json`, `*.agents/skills/factory918/*`), so no grounding was demanded on this run.

## Issues

None that block. The one finding I would file as its own ticket:

- `template/.agents/skills/spec-review/scripts/review-brief.sh:171,185` -- at the flags site, a fence opened
  anywhere before a `### Writer flags <YYYY-MM-DD>` opener and never closed (or closed after the list) hides the
  whole list and the run passes with exit 0. Evidence in (c)1. The in-list case is refused; only the
  before-the-list case is not. The risks site is covered by its own heading precondition.

## Notes

- The three secondary bypasses in (c) -- a hyphenated or singular heading, a nested flag, a fully fenced list --
  are the documented grammar, not defects. If the disposition gate is meant to be load-bearing, (c)1 and (c)2 are
  the two a writer reaches by accident rather than by choice.
- `fixed:` takes lowercase hex only; `fixed: 6692641CA184...` is refused as "not a commit id" although git resolves
  it. Cosmetic.
- Every refusal I produced wrote no state: `.claude/state/review` absent and `.scratch/review/<id>` absent in all
  14 refusing runs.
- Scratch: `/tmp/v108-runtime` (fixtures, both skill copies, outputs) and the driver scripts under this session's
  scratchpad. Nothing under version control was left modified.
