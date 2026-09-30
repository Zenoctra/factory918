verdict: PASS+NOTES

The per-heading change does what it claims. D10's exact failure is closed, every gate is green, CI is
green at the head, and the no-heading path is byte for byte what `origin/main` prints. One residual
of the same class survives, narrower than D10 and present on `main` too: see Issues.

- Head confirmed. `git rev-parse HEAD` = `8aa660a2a55b934312bbde2e15364484d2888920`;
  `git merge-base --is-ancestor 30bdcae HEAD` exit 0; `git status --porcelain` empty. Work done in
  the worktree `.claude/worktrees/agent-a1fb52f925c206983`, detached, read only on GitHub
  (`gh issue list`, `gh run list` only; nothing posted, edited, merged or closed).

## 1. The diff 30bdcae..8aa660a

Four commits, 7 files, +32/-22. `git diff --stat 30bdcae..8aa660a`:

```
SOURCES.md                                         |  2 +-
docs/knowledge/core/DECISIONS.md                   |  2 +-
patches/mattpocock/spec-review.SKILL.md.patch      |  2 +-
template/.agents/skills/spec-review/SKILL.md       |  2 +-
.../skills/spec-review/scripts/review-brief.sh     | 33 +++++++++++++---------
template/docs/factory918/DECISIONS.md              |  2 +-
tests/spec-review/review-brief.sh                  | 11 +++++---
```

Read whole, and word-diffed for the long-line files. Nothing outside the concern:

- `review-brief.sh`: the header sentence, the `disposed` comment, `-v at=1` printing `NR` in place of
  the field record, and the guard rewritten as two awks (line numbers of read flags, then one record
  per heading line with none at or below it before the next heading).
- `tests/spec-review/review-brief.sh`: the file header sentence, the SKILL.md `has` string, the
  table-D comment, D10 flipped from `briefed8` to `refused8`, D17 and D18 added.
- P139's row in both `DECISIONS.md` copies, the SKILL.md step-1 sentence, its line in the patch, and
  the SOURCES.md line. No other cell, rule or script touched.

## 2. Scenarios, own scratch repo and the suite's fake gh

Harness: `tests/spec-review/layout.sh` `layout project` into a private `mktemp -d`, two commits,
`tests/spec-review/fake-gh.sh` copied onto PATH as `gh`, `FAKE_ISSUE_BODY` per case,
`review-brief.sh <base> --ticket 7`. Every refusal was checked for exit 1, the exact stderr, and the
absence of both `.claude/state/review` and `.scratch/review/<id>`. No refusal below wrote review
state.

| case | body | exit | result |
| --- | --- | --- | --- |
| A | two readable `### Writer flags <date>` lists, each with a disposed flag | 0 | briefed |
| B | first readable, second inside a closed md fence | 1 | #139 refusal naming `### Writer flags 2026-09-24` |
| C | first readable, second quoted (`> ### Writer flags 2026-09-24`) | 1 | P108 refusal, `no disposition:` on the quoted heading and the `>` line |
| D | first readable, second under a fence that never closes | 1 | P108 refusal, `a fence opened here never closes:` on the fence line |
| E | first inside a closed fence, second readable | 1 | #139 refusal naming `### Writer flags 2026-09-23` |
| F | three lists, the middle one empty | 1 | #139 refusal naming `### Writer flags 2026-09-24` |
| G1 | opener, then `#### Details`, then the flags | 1 | P108 refusal, `no disposition: #### Details` |
| G2 | `## Writer flags` above the dated opener that holds the flags | 1 | P108 refusal, "not the heading `### Writer flags <YYYY-MM-DD>`: ## Writer flags" |
| H | no writer-flags heading at all | 0 | briefed |

C and D refuse through #136's disposition check, which runs first, not through #139's; the brief
asked for a refusal naming the second heading and what they name is the quoted lines and the open
fence. That is the older check answering first, and its message points at the real cause. Right.

G1 and G2 answer the sub-heading question: a deeper sub-heading under the opener is read as an
undisposed flag and refused by name; a shallower `## Writer flags` above it is a P108 near-miss and
refused by name. Neither is new on this PR, both are loud and both name the offending line, so the
writer is told what to change. Right by P18 (a refused input outside the documented path is the
design, not a finding).

H, byte for byte: one fixture repo, the same body, `review-brief.sh` from `8aa660a` and from
`origin/main` (`git archive origin/main template/.agents/skills/spec-review`) in turn. `cmp` on
stdout, stderr, `standards-brief.md` and `spec-brief.md`: identical, all four, exit 0 both.

## 3. False-refusal scan

`gh issue list --repo Zenoctra/factory918 --state all --limit 150 --json number,title,body` returned
99 issues. Each body was run through `review-brief.sh` in this worktree (so real `fixed:` shas
resolve) with the fake `gh`, fixed point `HEAD~1`, `--ticket <number>`.

- 99 scanned, 99 exit 0. 0 wrongful refusals, matching the earlier scan.
- Coverage caveat: exactly one of the 99 bodies (#108) holds a line the guard's heading regex
  matches, so 98 of the runs never reach the check. The scan proves no regression; it does not
  exercise the new per-heading arithmetic against real text.

## 4. Gates, at 8aa660a

```
tests/spec-review/review-brief.sh          exit 0   ok 1876 assertions
tests/spec-review/review-comment.sh        exit 0   ok 298 assertions
tests/spec-review/no-stale-wording.sh      exit 0   ok: no stale wording
.github/shellcheck.sh (the AGENTS.md line) exit 0   ShellCheck 0.11.0, files checked: 24
tests/shellcheck/gate.sh                   exit 0   ok 17 assertions
tests/hooks/delegation.sh                  exit 0   ok 76 assertions
tests/poteto-mode/overlap.sh               exit 0   ok 57 assertions
python3 tools/check_knowledge.py           exit 0   knowledge ok: 119 files
python3 tools/build_knowledge.py           exit 0   git status --porcelain empty afterwards
./factory918.sh sync                       exit 0   git status --porcelain empty afterwards
```

Patch regenerated by hand: `diff -u` of the pinned upstream
`research/1-matt-pocock/skills-repo/skills/engineering/code-review/SKILL.md` against
`template/.agents/skills/spec-review/SKILL.md`, headers normalised to `a/spec-review/SKILL.md` and
`b/spec-review/SKILL.md`, `cmp` against `patches/mattpocock/spec-review.SKILL.md.patch`: identical,
byte for byte.

CI: `gh run list --repo Zenoctra/factory918 --json headSha,conclusion,status,name,databaseId` gives
one run at `8aa660a2a55b934312bbde2e15364484d2888920`, `Factory CI completed success`, id
`35932109587`. Already complete, so no polling was needed.

## 5. Leading-witness test (#137)

The changed sentence is `template/.agents/skills/spec-review/SKILL.md:29`, in step 1, which addresses
the orchestrator about what the script refuses. It states behaviour and quotes the refusal's first
clause. It sets no expected number of findings, no word cap, no limit on what a reviewer may open or
run, and says nothing about what an earlier round found. Neither brief written in case A or H
contains the string `writer flags` at all (`grep -c` = 0 in both), so nothing of this reaches a
reviewer. Passes.

## Issues

1. The D10 class is narrowed, not closed. A second writer-flags list fully inside a closed fence
   still passes silently when any readable flag of the enclosing list follows the fence, because that
   flag is the nearest-heading credit for the fenced heading. The body (case Q), with the inner fence
   written here as `~~~` so this report stays readable:

   ~~~text
   ### Writer flags 2026-09-23

   1. a accepted: ok

   ```md
   ### Writer flags 2026-09-24

   2. b the hook may break, nobody looked
   ```

   3. c accepted: ok
   ~~~

   `review-brief.sh <base> --ticket 7` exits 0 and writes both briefs. Flag `2. b` is never read and
   never disposition-checked: case N, the same body with the fenced block removed, refuses that same
   line with `no disposition:`, which proves the fence hid it. `origin/main` exits 0 on this body
   too, so it is a residual, not a regression, and it is strictly narrower than D10 (which needed no
   trailing flag). The practical #139 shape, a second writer appending a hidden list at the end of
   the body, is caught: case O, the fenced list with nothing readable after it, refuses.

   The implementation matches its own spec here. P139 as amended says a heading "with no read flag
   under it" is refused, and this heading does have one under it. So this is a gap in the rule, not a
   bug against it. Whether to close it (attribute a read flag only to an unfenced heading, or count
   fenced heading lines separately) is Manuel's call; a narrower rule risks the false refusals the
   scan is guarding.

## Notes

- Case I: a continuation line indented under a settled flag, `   #### writer flag note accepted: ok`,
  is now refused (it is a heading line with nothing after it). The per-body guard passed it, since a
  flag was read elsewhere. P139's amended row accepts exactly this ("any line of two or more `#` that
  holds `writer` and then `flag`, with no read flag under it, is refused"), the message names the
  line, and the scan found no real ticket hitting it. Behaviour change, documented, not an issue.
- Case M: a fenced heading credited by a readable flag after the fence passes, but that flag is read
  and disposition-checked as part of the enclosing list, so nothing is lost. Only the grouping is
  wrong. Harmless on its own; it is the mechanism behind Issue 1.
- The owner's report is accurate on every claim I checked (head sha, `ok 1876`, CI run 35932109587,
  clean `sync`, `knowledge ok: 119 files`, the per-heading rule, D10/D17/D18, patch bytes), with two
  stale counts: it says ShellCheck covers "the 26-file set" (the run reports 24) and "`delegation.sh`
  (55)" (the run reports 76). Neither affects a gate.
- The report's "Decided after verification" line, that the refusal header still says "from its body"
  when another list was read, is true and is recorded in P139. The headings it names are exact, so
  the writer is not misled in practice.
