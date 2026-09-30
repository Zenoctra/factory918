# Writer report: ticket #91, "The Spec walk covers every blast-radius risk"

For a cross-cutting diff, the Spec brief's Walk bullet now ends with one sentence asking for a numbered line per risk under the grounding's Risks heading, and `review-brief.sh` refuses a grounding that has no `## Risks` or `### Risks` line outside fenced text, naming the file or the PR body. The test was written from the ticket's table first, one assertion per cell, and every verify command in the brief passes on the branch.

This file is at the worktree's copy of the brief's path (`.scratch/program/91/writer-report.md` under `.claude/worktrees/agent-a7a4f71ef05e6b5bb`): the harness refused a write to the shared checkout's path.

## Branch and commits

Branch `wt/91-writer`, from `52ccd8eb` (the head of PR #99), in the worktree `.claude/worktrees/agent-a7a4f71ef05e6b5bb`. Nothing pushed.

1. `ccf5bf61e9caf7dfe00eeec38eb67ac70004d089` Test the Spec walk's risk lines from ticket #91's table before the script. At this commit `bash tests/spec-review/review-brief.sh` fails at its first new assertion, "SKILL.md step 4 carries the risk sentence" (exit 1); `review-comment.sh` passes with the new fixture (136).
2. `c0761dd492d5903410a679d56dd38cccb2b6c22f` Continue the Spec walk with one line per blast-radius risk. The script, plus SKILL.md step 4's sentence through its patch (see Decisions). `bash tests/spec-review/review-brief.sh` passes: `ok 468 assertions`.
3. `6add1e35394a079ace7673e82131d04b96ab5f60` Say where the risks go, in the skill, the two playbooks and SOURCES.md. SKILL.md step 1, `opening-a-pr.md`, `ticket.md` step 5, SOURCES.md items 3 and 6, both patches regenerated.

## Cells and the assertion that proves each (`tests/spec-review/review-brief.sh`)

| Cell | Assertion (line) |
|---|---|
| 1A | 549-570: `blast-risks.md`; stdout exact (556), both briefs carry `## Blast radius`, the paragraph, the bullet text, the numbered risk, section before `## Diff` (560-567); the Spec brief carries `${spec_bullets[0]} $risk_rule` as one string, so the sentence is on the bullet's line (569); the Standards brief lacks it (570) |
| 1B | 647-657: README commit, `--blast-radius blast-risks.md`; stderr `ignored` exact (653); both briefs lack `## Blast radius`, the file's text and the sentence (655-657) |
| 2A | 571-573: `blast-risks-demoted.md` (`### Risks`), the same bullet |
| 2B | as 1B (the source restricts no level; no separate run) |
| 3A | 600-613: `pr-body.md` (CRLF, fenced `## `, `### Risks`); the existing bounds assertions stand (606-610), the demoted heading is in both briefs (607), the Spec bullet carries the sentence (612), the Standards brief does not (613) |
| 3B | 659-666: README commit with `FAKE_PR_BODY=pr-body.md`; stderr empty (661), both briefs lack `## Blast radius`, the body's text and the sentence (664-666) |
| 4A | the E half: 618-628, `pr-body-empty.md`, the existing refusal, relabeled; the N half: 629-632, `pr-body-undemoted.md` (prose, then `## Risks`), refused with `N` naming `the PR body's Blast Radius section`, exit 1, no state, no briefs |
| 4B | as 3B |
| 5A | 580-581: today's `blast.md` unchanged, refused with `N` naming `blast.md` (the `refused_risks` helper, 527-545: exit 1, stdout `ticket:`/`round:` lines then the message, no state, no briefs) |
| 6A | 582-583: `blast-fenced.md`, refused the same way |
| 7A | 574-576: `blast-both.md`, the same bullet |
| 8A | 577-579: `blast-empty-risks.md`, the same bullet |
| 5B-8B | as 1B or 3B |
| 9A | 585-598: the existing `E` refusal, relabeled |
| 9B | 161-162: the first, not cross-cutting run's briefs lack the sentence (beside the existing `lacks "## Blast radius"`) |
| 10 | 633-645: `--blast-radius missing.md`, exit 1, the two `usage()` lines exactly, no state |
| Contract, SKILL.md | 128: `has "$source_skill/SKILL.md" "$risk_rule"`; the `spec_bullets[0]` pin (existing) still holds as a substring of the longer bullet |
| Criterion 3 | `tests/spec-review/review-comment.sh` 262-281: the round-2 Spec report's walk continued with lines 4 and 5 (risks) gives the same summary line, `round: 2 of 3` and `act-on items: 3` |

## The emitted text, verbatim

From the end-to-end run (a throwaway project layout, a cross-cutting commit, `--blast-radius blast.md` with `## What it does` and `## Risks` holding two numbered risks), stdout:

```
ticket: #7
round: 1 of 3
.scratch/review/HEAD_1/standards-brief.md
.scratch/review/HEAD_1/spec-brief.md
```

The Spec brief's line 71:

```
- `## Walk`: one numbered line per documented step of the path the change touches (the ticket's criteria and the documentation the diff changes), each saying what the code does at that step. A walk, not findings: its lines are numbered 1..K on their own and count nothing. The diff is cross-cutting: after the lines per documented step, one numbered line per risk under the Risks heading of the `## Blast radius` section above, in its order and numbered on from the last step, each naming the risk and saying what the diff does at that risk; a risk line is a walk line and counts nothing.
```

Its `## Blast radius` section, before `## Diff`:

```
## Blast radius

The sessions and skills this change reaches, as the author grounded them before the review. Check the diff against each one; the grounding is the author's claim, not evidence.

## What it does

Adds a hook that exits 0.

## Risks

1. `factory-start` at day zero runs it before any skill is installed: `.claude/hooks/x.sh:1`.
2. A subagent inherits it: `.claude/hooks/x.sh:1`.

## Diff
```

The Standards brief carries the sentence 0 times. The same commit with a bullet hand-back (`- **Risks.** none`) as the file:

```
ticket: #7
round: 1 of 3
review-brief: the blast-radius grounding (blast-bullets.md) has no Risks heading outside fenced text; put the risks under a line that is exactly `## Risks` in the file, `### Risks` in the PR body, where the grounding's headings are demoted one level so the section stays intact
exit 1
```

## Verify commands, from the worktree root, at `6add1e3`

- `bash tests/spec-review/review-brief.sh`: `ok 468 assertions` (414 at the base; 27 new per layout).
- `bash tests/spec-review/review-comment.sh`: `ok 136 assertions` (134 at the base; the criterion-3 fixture adds one per layout).
- `bash tests/spec-review/no-stale-wording.sh`: `ok: no stale wording`.
- `bash tests/shellcheck/gate.sh`: `ok 10 assertions`.
- `bash .github/shellcheck.sh`: `ShellCheck 0.11.0, files checked: 6`, exit 0.
- `bash .github/shellcheck.sh factory918.sh template/.github/shellcheck.sh 'template/.claude/hooks/*.sh' 'template/.agents/skills/*/scripts/*.sh' 'tests/*/*.sh'` (the set the worktree's AGENTS.md names): `files checked: 20`, exit 0.
- `shellcheck -x template/.agents/skills/spec-review/scripts/review-brief.sh tests/spec-review/review-brief.sh tests/spec-review/review-comment.sh`: clean. Without `-x`, plain `shellcheck` on the tests prints the pre-existing SC1091/SC2154 for the sourced `layout.sh` (the same at the base); the gate runs with `--external-sources`.
- `./factory918.sh sync`: 17 patches applied, none failed; `git status --porcelain` prints nothing (run after each of commits 2 and 3, before committing).
- `python3 tools/check_knowledge.py`: `knowledge ok: 118 files`.
- End to end: above.

## Decisions the design did not settle

1. Commit 2 carries SKILL.md step 4's risk sentence (through its patch) together with the script, and commit 3 the rest of the prose. The brief put all of SKILL.md in commit 3 but also said the test passes at commit 2; the test pins the sentence against the source SKILL.md, so both could not hold. I chose a true "passes at commit 2" and said so in the commit body.
2. Cell 10: the design says "today's assertions, unchanged", but the base test had no assertion for `--blast-radius` naming no file. I added one (633-645), asserting today's behaviour: exit 1, the `usage()` block, no state. No code changed for it.
3. `tests/spec-review/review-comment.sh` moved from 134 to 136 assertions. The brief's verify list says "unchanged", but the design (and the brief's own implementation notes) ask for the criterion-3 fixture, which is an assertion. `review-comment.sh` itself is unchanged.
4. Fixture names the design left open: `blast-risks-demoted.md` for 2A ("the same file with `### Risks`"), and `pr-body-undemoted.md` carries `- **What it does.** Adds a hook that exits 0.` as the "prose left" before its `## Risks`.
5. The refusals share a small helper in the test, `refused_risks <label> <where> [args]` (527-545), instead of four copies of the ten-line block; each call is one assertion.
6. `ticket.md` step 5 ends with "the Spec reviewer walks every risk under it", one clause past the two edits the design named, so the author knows why the heading matters.
7. Note, not a decision: a `--blast-radius FILE` grounding passes through intact, so its `## Risks` reaches the brief as a `## ` heading after `## Blast radius` (the sentence says "the Risks heading of the `## Blast radius` section above"); a PR-body grounding reaches it as `### Risks`. The design accepts both.

## Cells not implemented (rule 4)

None. Every cell of the table is implemented as written and has its assertion.
