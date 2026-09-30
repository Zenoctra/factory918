# Spec review brief

Read nothing beyond this brief unless a finding needs the code around a hunk, and then read that one function or section, not the file. Run nothing.

## Commits

7956c69 Give the CI fixture's grounding the Risks heading the brief now needs
469f78d Record the walk contract and the stacked-PR link workaround for #91
6add1e3 Say where the risks go, in the skill, the two playbooks and SOURCES.md
c0761dd Continue the Spec walk with one line per blast-radius risk
ccf5bf6 Test the Spec walk's risk lines from ticket #91's table before the script

## Changed files

 .github/workflows/factory-ci.yml                   |   4 +-
 SOURCES.md                                         |   4 +-
 docs/M0-findings.md                                |   2 +
 docs/agents/ledger.md                              |   2 +
 docs/knowledge/INDEX.md                            |   2 +-
 docs/knowledge/core/DECISIONS.md                   |   4 +-
 patches/mattpocock/spec-review.SKILL.md.patch      |   4 +-
 .../poteto-mode/playbooks/opening-a-pr.md.patch    |   2 +-
 .../skills/poteto-mode/playbooks/opening-a-pr.md   |   2 +-
 .../.agents/skills/poteto-mode/playbooks/ticket.md |   2 +-
 template/.agents/skills/spec-review/SKILL.md       |   4 +-
 .../skills/spec-review/scripts/review-brief.sh     |  28 +++-
 template/docs/factory918/DECISIONS.md              |   2 +
 tests/spec-review/review-brief.sh                  | 146 +++++++++++++++++----
 tests/spec-review/review-comment.sh                |  20 +++
 15 files changed, 185 insertions(+), 43 deletions(-)

## Diff

The diff is 503 lines; read it from `.scratch/review/52ccd8eb509a2871260827a8514c3a1fcaac4d5d/diff`.

## The ticket (#91)

## Problem

Observed (agent): both reviewers on PR #87 carried the author's blast-radius grounding in their briefs for three rounds, including its first risk, an owner lane blocking on a step with no human, and neither raised it until round three. On PR #92 the grounding named the detached-HEAD case as its third risk before round one; round one's Spec reviewer did not walk it and round two found it. Two runs, the same failure, one round late each time. The brief says to check the diff against each risk, but the report shape forces a line per documented step (`## Walk`) and nothing per risk.

## Decision

> user: why not hand the blast radius result that you are checking yourself off to the reviewer? ... I feel like it contradicts earlier rules about what the orchestrator is allowed to do VS what is required to delegate for very good reason.

> agent: You are right that it contradicts P11 and P19, and the facts kill it anyway: both reviewers had the blast radius in their briefs in all three rounds, risk 1 included, and neither raised it until round three. So the gap is on the reviewer side.

> user: I imagine Shell Check and the Spec Walk are good practice but survivable for the right now.

## Acceptance criteria

- [ ] For a cross-cutting diff, the Spec brief's `## Walk` rule requires, after the lines per documented step, one numbered line per risk under the grounding's Risks heading, each saying what the diff does at that risk.
- [ ] `review-brief.sh` finds the Risks heading in both forms the grounding takes: `## Risks` in a `--blast-radius FILE` and `### Risks` in a PR body, where the grounding's inner headings are demoted one level so the `## Blast Radius` section stays intact; it writes the rule only when a grounding is present, and `tests/spec-review/review-brief.sh` asserts both forms and the absent case.
- [ ] `review-comment.sh` still counts walk lines as steps, not items.
- [ ] The Opening a PR playbook's Blast Radius bullet (through its patch) says the inner headings are demoted to `###` when the file is pasted, so the next reader does it without learning it from a refusal.

## Run under

Until #89, #90, #91 and #93 merge, the lane that runs this ticket follows their rules by hand; following them is part of the ticket. The worked example of every artifact named here is ticket #42 (its `## Testing decisions` section) and PR #92 (its description and its three review comments); read both first. The rules: (1) `how` and `blast-radius` as the Ticket playbook says. (2) When the change has state (a file it reads or writes, exit codes, rounds, or more than one actor) the architect step writes a scenario table before any code: situations down the side, the shape of the input across the top, and in every cell what is printed, the exit code and what the caller does; a cell for an input outside the intended path reads "refused with the tool's own message" and costs no code, and such a cell is cut only after the refusal was run and seen. When the change is code with no state that crosses a function boundary, the architect step posts the usage and signature sketch (the caller's usage first, then types and signatures) on the ticket under `## Design` instead; a prose change has no artifact beyond its acceptance criteria. The table is appended to this ticket's body under `## Testing decisions`, first line "Posted by the agent <date>"; the human edits it if it is wrong, and a stop before implementation is asked for only with the phrase "/architect with checkpoint". (3) The test is written from the table before the implementation, one assertion per cell, and the commit order shows it. (4) A writer that cannot implement a cell as written stops and reports the cell; it never fills it. (5) In review, a finding is a design hole when its fix changes the artifact the work was built against rather than the code that implements it: a table cell or a term its cells use, a signature or a usage in the sketch, or an acceptance criterion (the ticket's intent, its What to build or Decision quotes, outranks any one criterion, so a criterion that must change goes back to architect, which re-derives it from the intent and amends the ticket with a dated line); a design hole is not fixed on the PR but returns to architect, scoped to that cell, and the review count restarts (on this PR with a comment that says "restart" and why); a refusal added under an existing could-not-run clause is not a hole. (6) The Spec reviewer's walk has one line per risk in the blast-radius grounding. (7) A round that fixed a Would-break item is followed by another round even past three, reviewing only the fix (the previous reviewed commit as the fixed point), up to five; at five with Would-break items still found, stop, write a report for the human, mark the PR unfinished and wait. (8) `shellcheck` on every changed shell file before the PR opens. This ticket has state (a grounding present or absent, in a file or a body, with headings at two levels), so rule 2 yields a small table: situations are those forms, the input is the diff being cross-cutting or not, cells name what the brief contains. Its files overlap #90's and #93's in `review-brief.sh` and its test; under the program's go it stacks on the printed PR.

## Blocked by

- #42




## Testing decisions

Posted by the agent 2026-09-22. Two architect runners (Fable, Opus) designed this from the code at PR #99's head and converged on every structural choice; the judge was skipped. The scenario table is the spec for the mechanism: a review finding that changes a cell is a design hole and returns the work to architect; a finding that leaves the table standing is an implementation bug fixed on the PR. The test is written from the table before the script, one assertion per cell.

### Scenario table

Cell = what the Spec brief's `## Walk` bullet carries / exit / what the orchestrator does. `R` = the bullet as today plus the risk sentence (the Contract), with `## Blast radius` before `## Diff` in both briefs as today. `plain` = the bullet as today, no risk sentence. `E` = today's refusal `review-brief: cross-cutting diff (<paths>) without a blast-radius grounding; run the blast-radius skill, put the result in the PR body's Blast Radius section or pass --blast-radius FILE`, stderr, exit 1, no state, no briefs. `N` = the new refusal (the Contract), stderr, exit 1, no state, no briefs. `ignored` = today's stderr line `review-brief: the diff is not cross-cutting; <FILE> is not pasted`, the file never read. "Grounding" = the file's text, or the PR body's section cut at the next unfenced `## ` line, leading blank lines stripped (today's extraction, unchanged). The Standards brief carries the risk sentence in no cell; `review-comment.sh` reads no cell (walk lines are steps, never items).

| Situation | A. cross-cutting diff | B. not cross-cutting |
|---|---|---|
| 1. `--blast-radius FILE`, `## Risks` unfenced, numbered risks under it | `R` / 0 / spawn both lanes; the reviewer walks the steps, then the risks | `plain`, `ignored` / 0 / spawn both lanes |
| 2. `--blast-radius FILE`, `### Risks` (a body pasted back to a file) | as 1A; the source restricts no level | as 1B |
| 3. PR body section, `### Risks` inside it (PR #92's shape; CRLF and a fenced `## ` line kept, today's fixture) | `R` / 0 / spawn both lanes | `plain` / 0 / the body is never fetched |
| 4. PR body section, headings not demoted (`## Risks` after `## Blast Radius`) | the section ends at the first inner `## `: nothing left before it gives `E`, prose left gives `N` / 1 / stop; the author demotes the body's headings to `###` (Opening a PR); no code beyond the two messages | as 3B |
| 5. Grounding present, no Risks heading at all (the bullet hand-back `- **Risks.**`, today's `blast.md`) | `N` / 1 / stop; the author adds the heading; no code beyond the message | as 1B or 3B |
| 6. The only Risks heading is inside a fenced block | as 5A: headings are read outside fenced text only | as 1B or 3B |
| 7. Both levels present (`## Risks` then `### Risks`) | `R` / 0 / the first unfenced one satisfies the check; nothing is counted, so nothing else moves | as 1B or 3B |
| 8. Risks heading with no numbered line under it | `R` / 0 / the reviewer writes zero risk lines; no code | as 1B or 3B |
| 9. No grounding: no `--blast-radius`, and no PR or an empty `## Blast Radius` section | `E` / 1 / stop, as today | `plain` / 0 / spawn both lanes, as today |
| 10. `--blast-radius` names no file | refused with the tool's own message, the `usage()` block / 1 / stop; costs no code | as 10A |

### Contract

The rule: one shell variable, `risk_rule`, holding this sentence, appended to the Spec brief's `## Walk` bullet on the same line, only when `grounding` is non-empty; the bullet's own text does not change, so the assertions that pin it hold as substrings:

> The diff is cross-cutting: after the lines per documented step, one numbered line per risk under the Risks heading of the `## Blast radius` section above, in its order and numbered on from the last step, each naming the risk and saying what the diff does at that risk; a risk line is a walk line and counts nothing.

`SKILL.md` step 4 carries the sentence word for word as it carries the blast-radius paragraph, and step 1's cross-cutting paragraph says the grounding must carry a Risks heading and quotes the refusal; `tests/spec-review/review-brief.sh` pins the sentence as one string in the source `SKILL.md`, in the Spec brief (1A), and absent from the Standards brief (1A) and from every Spec brief of a diff that is not cross-cutting (1B, 3B).

Detection, inside the existing cross-cutting block, after the empty-grounding check and before any state is written, over the grounding text whatever its source, with the shared `fenced` awk (fenced text skipped), CR and trailing blanks stripped: the first line that is exactly `## Risks` or `### Risks`. Not found: `rm -rf "$dir"`, then on stderr, exit 1:

> review-brief: the blast-radius grounding (<FILE, or: the PR body's Blast Radius section>) has no Risks heading outside fenced text; put the risks under a line that is exactly `## Risks` in the file, `### Risks` in the PR body, where the grounding's headings are demoted one level so the section stays intact

Files: `template/.agents/skills/spec-review/scripts/review-brief.sh` (the variable, the detection, the refusal, the header comment); `template/.agents/skills/spec-review/SKILL.md` through `patches/mattpocock/spec-review.SKILL.md.patch` (steps 1 and 4); `template/.agents/skills/poteto-mode/playbooks/opening-a-pr.md` through `patches/pstack/poteto-mode/playbooks/opening-a-pr.md.patch`: the `## Blast Radius` bullet says the file's `## ` headings are demoted to `###` when it is pasted, because an undemoted `## ` line ends the section, and that `review-brief.sh` finds the risks under `### Risks`; `template/.agents/skills/poteto-mode/playbooks/ticket.md` step 5 (ours): the hand-back is written with each part under a `## ` heading and one numbered risk per line under `## Risks`, and "that file verbatim" becomes "that file with its `## ` headings demoted to `###`"; `SOURCES.md` items 3 and 6, one sentence each. `template/.agents/skills/blast-radius/SKILL.md` is vendored and not touched. `review-comment.sh` is unchanged; criterion 3's regression check is one fixture in `tests/spec-review/review-comment.sh`: a Spec report whose walk continues with risk lines still counts them as steps (the same `hard findings:` and `act-on items:` as without them).

Tests, `tests/spec-review/review-brief.sh`, one assertion per cell, named by row and column in a comment: 1A and 1B on a new `blast-risks.md` (today's `blast.md` text plus `## Risks` and one numbered risk), the cross-cutting `x.sh` commit and the README-only commit; 2A the same file with `### Risks`; 3A and 3B today's CRLF `pr-body.md` with `### Risks` added, its existing assertions standing; 4A a `pr-body-undemoted.md` with prose then `## Risks`, refused with `N` naming the PR body, no state, no briefs; 5A today's `blast.md` unchanged, now refused with `N` naming the file; 6A `blast-fenced.md`; 7A `blast-both.md`; 8A `blast-empty-risks.md`; 9A, 9B and 10 today's assertions, unchanged. The `SKILL.md` block gains the `risk_rule` pin.

Open, with the default taken: the heading text is exactly `Risks` (`## Risks (confirmed)` is refused, the message says the form); the risk lines continue the walk's numbering; the Spec report's word cap is unchanged (PR #92 had four risks); `blast-radius/SKILL.md` still hands back bullets, so `ticket.md` step 5 carries the heading shape instead of a patch on that skill.

## Report

A hard finding is one of two things: the documented path gives a wrong or silent result, or an input outside it proceeds silently (fails open). An input outside the documented path that is refused with a message saying how to correct it is not a finding; it is the design. Zero items is the expected result for a clean change.

- Manuel: "there are an infinite amount of unhappy paths and only 1 happy one"
- Manuel: "AT MOST hardening to fail fast and loud if we move outside of that"
- Manuel: "we notice the variable is unexpected and flag that without having to diagnose every reason the variable might be wrong for the user"
- Manuel: "An edge case outside the intended path being unsupported is not a flag."
- Manuel: "Primary focus must be the happy path, then unhappy paths that error in a way the user can correct."

Write the report as Markdown with exactly these `## ` headings, in this order, each holding numbered items or nothing:

- `## Walk`: one numbered line per documented step of the path the change touches (the ticket's criteria and the documentation the diff changes), each saying what the code does at that step. A walk, not findings: its lines are numbered 1..K on their own and count nothing.
- `## Would break`: a requirement missing, partial, or implemented so that the documented path gives a wrong or silent result.
- `## Fails open`: an input outside the documented path that proceeds silently instead of being refused with a message saying how to correct it.
- `## Not asked for`: behaviour in the diff the ticket did not ask for.

Each item opens with a line of the form `1. **Title.** body` and quotes the spec line it rests on in a fenced block (a criterion can carry `## ` or `1. ` lines, and only fenced text is exempt from the report shape); number the items continuously across the headings from `## Would break` on, so the judgment can name your third item as [P3]. Read nothing beyond this brief unless a finding needs the code around a hunk, and then read that one function or section, not the file. Under 400 words.

Every item under `## Would break` or `## Fails open` carries a line `Documented step:` quoting the ticket line or the `file:line` of the documentation the user follows, and a line `Result:` saying what happens instead; an item without its `Documented step:` line is sent back.

The same item carries a line `spec:` naming the artifact it rests on: `table <row>/<column>` for a cell of the ticket's scenario table, `design <signature>` for a signature or usage in its `## Design` sketch, or `criterion <k>` for its k-th acceptance checkbox; an item without a `spec:` line in one of those three forms is sent back.

Write your report to `.scratch/review/52ccd8eb509a2871260827a8514c3a1fcaac4d5d/spec-report.md` and reply with only that path.
End the report with exactly one line `hard findings: N`, where N is the number of items under `## Would break` and `## Fails open` and nothing else.
