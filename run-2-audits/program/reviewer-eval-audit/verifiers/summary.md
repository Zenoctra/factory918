# What the verifiers found that the review rounds had passed over

Every PR in both runs ended its spec-review at `act-on items: 0`. The verifier lanes that read the
same PRs afterwards found 81 further items. 56 of them concern code or prose that was inside a
review round's diff, and 46 of those were named by no round at any axis.

The rounds are good at the things a checklist reaches — a stale count, a rule stated two ways in two
documents, a glob that fails open — and they were reliably the ones to catch those. What they passed
over falls into three shapes: the behaviour of a shell or awk rule outside the one case the ticket's
table names (PR 94's heading skip, PR 96's gate, PR 126's reading pack), a table cell the ticket
promised an assertion for and never got (PRs 102 and 125), and the meaning of a term the whole design
rests on (PR 125's "inside the fix"). None of those is found by reading a diff; each was found by
running the code against an input the ticket did not imagine.

## Counts per PR

| PR | issues the verifiers raised | of those, in code a round had read | of those, never named by any round |
|---|---|---|---|
| 94 | 7 | 4 | 2 |
| 96 | 7 | 5 | 5 |
| 99 | 5 | 1 | 1 |
| 101 | 2 | 1 | 0 |
| 102 | 7 | 7 | 7 |
| 120 | 8 | 6 | 4 |
| 121 | 5 | 3 | 3 |
| 124 | 9 | 3 | 1 |
| 125 | 13 | 10 | 9 |
| 126 | 10 | 9 | 9 |
| 129 | 8 | 7 | 5 |
| **total** | **81** | **56** | **46** |

"In code a round had read" means the file was inside a review round's diff or was a file the round's
brief pointed at. The rest are PR-body receipts, ticket state, the owner's own report, or code that
landed after the last round. Run 1 (94, 96, 99, 101, 102) contributes 28 items, 18 in reviewed code,
15 unnamed; run 2 (120, 121, 124, 125, 126, 129) contributes 53, 38 in reviewed code, 31 unnamed.

Where the verifier's finding is severe, it is almost always in run 2, and almost always about running
the code rather than reading it. PR 125's design hole and PR 126's secret leak are the two that would
have shipped.

## Five examples

1. The design hole, found by reproduction after a clean round one
   (`.scratch/program/verify/125-caecbc4/worker-audit.md`, section 7): "a bare `else` or `done` does
   the same. Round three then never re-reads that code."

2. The reading pack carries whatever is in the diff
   (`.scratch/program/verify/126-f58308b/worker-runtime.md`, Notes 1): "177 secret lines carried
   where the diff showed 6."

3. The awk skip that stops at the next `## `, which the rounds had blessed
   (`.scratch/program/verify/94-78be65e/worker-audit.md`, Issues 2): "Running the shipped awk over
   #42's live body still yields the pathspecs".

4. The gate's own recovery message, unreviewed across three rounds
   (`.scratch/program/verify/96-2360707/worker-runtime.md`, Notes 3): "A lane reading CI output sees
   a checksum warning with nothing tying it to the gate."

5. The cells the rounds certified without counting
   (`.scratch/program/verify/102-fc75ac6/worker-audit.md`, Issues 1): "Table A row 13 column B has no
   assertion"; both rounds' Spec walks had recorded "one assertion per cell".

## What is in the TSV and what is not

`verifier-issues.tsv` has one row per item, with the verifier's own severity wording, whether the code
was in a reviewed diff (with round, `file:line @ sha` where the verifier gave one), the round, axis and
item that named it or `none`, and whether it was later fixed.

Skipped as verifier gate or environment rather than defects in a PR's code, one line each:

- Every PR: `factory918 apply` on a local fixture prints `FAIL labels present` and `FAIL slots filled (/factory-start)`, both needing a GitHub remote and a Day-0 interview the fixture has not had.
- PR 96 gates: the Linux leg of the ShellCheck pin is proved only by CI, this machine being Darwin arm64.
- PR 96 gates: the Fixture job was not re-run locally because it needs a network `pnpm install`.
- PR 96 gates: `./factory918.sh sync` returns `$failed` and the harness's zsh reads `${PIPESTATUS[0]}` empty.
- PR 99, 121, 124, 125, 129: `AGENTS.md`'s fixture line writes `--directory /tmp/fx`, which `vp` 0.3.1 refuses — a real defect, but in no PR's diff; filed as #123 and listed in the TSV once, under 99.
- PR 101 gates, 121 gates, 129 gates: `tests/spec-review/layout.sh` is a sourced helper that prints nothing and exits 0 when run directly.
- PR 101 gates: CI green at that head covers a merge against a #99 that has since moved.
- PR 102 gates, 125 gates: the fixture flow ran under the session scratchpad instead of `/tmp/fx` so concurrent verifiers could not share a directory.
- PR 120 runtime: checks deliberately left to the sibling slices (build_knowledge, the shellcheck gate, the hook and spec-review tests, the fixture flow).
- PR 121 gates: the verifier could not `Write` into the primary checkout from its worktree and copied the report in with `cp`.
- PR 124 gates: `git fetch 'refs/keep/103/*'` wrote refs into the shared ref store; no tracked file changed.
- PR 124 runtime: the M0 table is reproducible only on this machine, the receipts living uncommitted under `.scratch/eval/reviewer/`.
- PR 125 audit: the shared session scratchpad was overwritten mid-run by another lane, so the receipt checks were redone in a private subdirectory.
- PR 125 gates, 124 gates: `tests/eval/reviewer/rebuild.sh` is neither in `AGENTS.md` "Verifying" nor in CI, and a fresh clone needs the keep refs first.
- PR 129 gates: the fixture flow ran on macOS 15 arm64 while CI runs it on ubuntu-latest; both green.
