## What to build

Split from #104 (2026-09-22) at Manuel's request.

> agent: "Grounding produced and not acted on. #88's blast-radius risks and #90's writer flag 9 were both in the owner's hands before the review opened, and both were re-found by reviewers at the cost of a round (and in #90, a restart). Neither was a lane failure; both were the owner treating a delegate's report as something to file rather than something to fix."

> agent: "delegate reports are act-on lists, not attachments"

> user: "I agree with your choices here."

Facts the lane starts from. On PR #96 the blast-radius lane named the unchecked cached binary and the silently dropped glob at 10:33, and review rounds one and two re-found both; on PR #99 the writer's flag 9 was the design hole that restarted the review. The prose rule (a delegate's report is an act-on list, settled before round one) is #105; this ticket is the refusal that enforces it in `template/.agents/skills/spec-review/scripts/review-brief.sh`, with `tests/spec-review/review-brief.sh`. This ticket shares those files with #106 and #107: the three run one at a time, or as a stack under a go.

## Acceptance criteria

- [ ] The PR body's `## Blast Radius` section carries, under its Risks heading, one disposition per risk on the risk's own line (`fixed: <sha>` or `accepted: <reason>`), and `review-brief.sh` refuses to brief a cross-cutting diff whose Risks lines carry none, exit 1, no state written, with a message naming the risks that lack one; a diff that is not cross-cutting is unaffected.
- [ ] A writer's flags reach the ticket under `## Testing decisions` (or `## Design`) as a dated `Writer flags` list with a disposition per flag, and the brief refuses when the ticket body carries a `Writer flags` list with a flag that has none; a ticket with no such list is unaffected.
- [ ] The Spec brief's walk rule (#91) reads each risk's disposition and asks the reviewer to say whether the diff honors it.
- [ ] The scenario table on this ticket has one row per shape (no grounding, grounding with every risk dispositioned, one risk without, a writer flag without, a non-cross-cutting diff) and `tests/spec-review/review-brief.sh` has one assertion per cell, written before the script changes, in the commit order.
- [ ] The Opening a PR playbook's Blast Radius bullet and the blast-radius skill's hand-back (through their patches) show the disposition line.

## Blocked by

- #105 (the prose rule this refusal enforces, so the playbooks and the script say the same thing).


## Testing decisions

Posted by the agent 2026-09-23

Synthesized from two architect runners (Claude Opus 5.5 as the base, Claude Opus 5 grafted); the grammar was run as a prototype on the inputs of tables B and C before this was posted.

### Legend

- **B**: exit 0, the briefs and `.claude/state/review/` written as today. **B+**: B for a cross-cutting diff; both briefs carry `## Blast radius` with the grounding verbatim, dispositions included, and the Spec brief's Walk bullet ends with the new risk sentence. **B/np**: B plus today's stderr line `review-brief: the diff is not cross-cutting; <file> is not pasted`. **B/ns**: B with `no spec: Standards axis only`, the Standards brief alone.
- **RG**: today's refusal for a missing grounding. **RR[x]**: the new risk refusal; **RF[x]**: the new flag refusal. `x` is the exact list of offending lines, each `  <reason>: <line>`. Every refusal exits 1 and leaves neither `.claude/state/review/` nor `.scratch/review/<id>/`.
- **TOOL**: refused with the script's existing message; unchanged.
- Reasons: `nd` no disposition; `nc(v)` `fixed: v` is not a commit id (7 to 40 lowercase hex characters); `nr(v)` does not resolve to a commit here; `nh(v)` is not in HEAD's history; `na` `accepted:` has no reason; `fo` a fence opened here never closes; `nm` not the opener heading.

### Table A: the criterion's shapes, by review form

Columns: **F** round 1, `--blast-radius blast.md`; **P** round 1, the grounding in the PR body's `## Blast Radius` section under `### Risks`; **R** a fix-only round 3 (`fix only after <sha>`, #106) with the cross-cutting commit after the fixed point and `--blast-radius`; **S** the sweep form, `--paths <hook> --commits HEAD --blast-radius blast.md`. "Risks OK": `1. ... fixed: <HEAD short sha>` and `2. ... accepted: the hook exits 0 before any skill`. "One risk bare": line 2 has no disposition. A blank R or S cell is not asserted: the check is the same call in every form.

| # | Situation | F | P | R | S |
|---|---|---|---|---|---|
| A1 | not cross-cutting; a grounding with one risk bare; a ticket with no list | B/np | B | | |
| A2 | cross-cutting; no grounding | RG | RG | | |
| A3 | cross-cutting; risks OK; a ticket with no list | B+ | B+ | B+ | B+ |
| A4 | cross-cutting; one risk bare | RR[`nd: 2. ...`] | RR[same] | RR[same] | RR[same] |
| A5 | cross-cutting; risks OK; a Writer flags list with flag 2 bare | RF[`nd: 2. ...`] | RF[same] | RF[same] | RF[same] |
| A6 | not cross-cutting; a Writer flags list with flag 2 bare | RF[as A5] | RF[same] | | |
| A7 | cross-cutting; one risk bare and flag 2 bare | RR[as A4], no flag line | RR | | |
| A8 | cross-cutting; risks OK; every flag dispositioned | B+, the Spec brief carries the list | B+ | | |
| A9 | cross-cutting; risks OK; no ticket | B/ns | B/ns | | |
| A10 | cross-cutting; risks OK; `gh issue view` fails | B/ns plus today's `gh could not fetch` line | same | | |

A1 to A6 are the ticket's five shapes (A5 and A6 split the writer flag by diff kind); A7 to A10 settle the order and the no-spec cases.

### Table B: the line grammar, by site

Column **r**: the line sits under `## Risks` in `blast.md`, cross-cutting, form F, a ticket with no list. Column **f**: under `### Writer flags 2026-09-23` inside the ticket's `## Testing decisions`, a diff that is not cross-cutting. Both use one code path; f is asserted where it proves that. `<H>` is HEAD's short sha, `<X>` a commit outside HEAD's history.

| # | Lines under the opener | r | f |
|---|---|---|---|
| B1 | `1. text fixed: <H>` | B+ | B |
| B2 | `1. text accepted: out of scope, #130` | B+ | |
| B3 | `1. text` | RR[`nd`] | RF[`nd`] |
| B4 | `- a bullet item` | RR[`nd`] | |
| B5 | `1. first half`, then at column 0 `second half accepted: ok` | RR[`nd: 1. first half`] | |
| B6 | `1. a accepted: ok`, an indented continuation, a closed fence holding `## x` and `1. y`, `2. b fixed: <H>` | B+ | B |
| B7 | `1. the binary is not fixed: it stays stale` | RR[`nc(it stays stale)`] | |
| B8 | `1. text fixed: 1234abc` (resolves nowhere) | RR[`nr`] | |
| B9 | `1. text fixed: <X>` | RR[`nh`] | |
| B10 | `1. text accepted:` | RR[`na`] | |
| B11 | `1. text accepted: partly, then fixed: <H>` (the last field wins) | B+ | |
| B12 | `1. text fixed: <H> (the second commit)` | RR[`nc`] | |
| B13 | ``1. text `fixed: <H>` `` in backticks | RR[`nd`] | |
| B14 | `1. text fixed: ABCDEF1` | RR[`nc`] | |
| B15 | `1. a accepted: ok`, a fence that never closes, `2. hidden` | RR[`fo`] | RF[`fo`] |
| B16 | `1. a accepted: ok`, `#### Risks` (r) or `#### Writer flags 2026-09-23` (f), `2. b` | RR[`nm`, `nd: 2. b`] | RF[`nm`, `nd: 2. b`] |
| B17 | `1. a accepted: ok`, `#### Proof` | RR[`nd: #### Proof`] | |
| B18 | the opener and no lines | B+ (#91 cell 8A, unchanged) | |
| B19 | `  1. a accepted: ok`, `  2. b` (the list indented two spaces) | RR[`nd`] | |
| B20 | `1. a accepted: ok`, a second exact opener, `2. b` | RR[`nd: 2. b`] | |
| B21 | `1. a accepted: ok`, a heading at the opener's level, prose with no disposition | B+ | |
| B22 | CRLF line ends and trailing spaces after `fixed: <H>` | B+ | |

### Table C: the openers, by site

Column **r**: a line in `blast.md` beside an exact `## Risks` whose one risk is dispositioned, cross-cutting. Column **f**: a line in the ticket body, not cross-cutting.

| # | The line | r | f |
|---|---|---|---|
| C1 | a plain marker: `Risks:` (r), `Writer flags:` (f) | RR[`nm`] | RF[`nm`] |
| C2 | the wrong level: `#### Risks` under `## Cleared` (r), `## Writer flags 2026-09-23` (f) | RR[`nm`] | RF[`nm`] |
| C3 | trailing text: `### Risks (two)` (r), `### Writer flags 2026-09-23 (PR #99)` (f) | RR[`nm`] | RF[`nm`] |
| C4 | lowercase: `## risks` (r), `### writer flags 2026-09-23` (f); and for f no date, `### Writer flags` | RR[`nm`] | RF[`nm`], RF[`nm`] |
| C5 | bold: `**Risks**` (r), `**Writer flags 2026-09-23**` (f) | RR[`nm`] | RF[`nm`] |
| C6 | an opener inside a fenced block, with a bare item under it | B+ | B |
| C7 | prose: `Risks here are low.` and `- **Risks.** day zero: x.sh:1` (r); this ticket's criterion 2 line, `Writer flags are recorded by the orchestrator.` and a table row naming Writer flags (f) | B+ | B |

C7/f is this ticket's own body: the review of the PR that closes #108 must not refuse its own ticket.

### Contract

- **Opener.** An unfenced line that, less CR and trailing blanks, is exactly `## Risks` or `### Risks` (in the grounding), or `### Writer flags YYYY-MM-DD` (in the ticket body, anywhere in it; Ticket step 6 places it under `## Testing decisions` or `## Design`). Every opener starts a list; every list is checked.
- **List.** The lines after an opener up to the next unfenced heading no deeper than the opener, or the end of the text. A deeper heading inside it is an item, or a near-miss.
- **Item.** An unfenced, non-blank line of a list indented no deeper than the list's first non-blank line. A deeper line is a continuation and is not read. Numbered lines are the documented form; a bullet, prose, a table row or a deeper heading is an item too, so no shape passes unread.
- **Disposition.** The field from the last match of `(^|[ \t])(fixed|accepted):` on the item's own line to its end. `fixed:` takes 7 to 40 lowercase hex characters to the end of the line, which resolve to a commit that is HEAD or its ancestor. `accepted:` takes a non-empty reason.
- **Near-miss.** An unfenced line that is not an opener and is either a heading whose text, lowercased, starts with `risks` or `writer flags` (the site's word) followed by a non-letter or the end, or a line that holds only that word, optionally wrapped in `*` or `_`, with digits, spaces, `-`, and one `:` or `.`. Prose that goes on past the word is not one.
- **Unclosed fence.** A fence opened inside a list and still open at the end of the text.
- **Placement.** The risk check runs right after today's Risks-heading check, for a cross-cutting diff only. The ticket fetch moves, unchanged, before the reading pack and every state write; the flag check runs right after it whenever the ticket body was fetched, at every round and in both forms. The risk check runs first. Both refusals remove `.scratch/review/<id>/` and exit 1.
- **Messages.** `review-brief: the blast-radius grounding (<where>) has risk lines without a disposition; ...` and `review-brief: ticket #<N> has Writer flags without a disposition; ...`, each followed by the offending lines, and each header saying every correction a reason can call for (end the line with `fixed: <sha>` or `accepted: <reason>` as plain text, indent a continuation, fence a proof, use the exact opener).
- **Risk sentence (criterion 3).** "The diff is cross-cutting: after the lines per documented step, one numbered line per risk under the Risks heading of the `## Blast radius` section above, in its order and numbered on from the last step, each naming the risk, saying what the diff does at that risk, and saying whether the diff honors the disposition the risk's line ends with (for `fixed: <sha>`, whether that commit fixes the risk; for `accepted: <reason>`, whether the reason holds for this diff); a risk line is a walk line and counts nothing." Carried word for word by `review-brief.sh` and `spec-review` SKILL.md step 4.

Accepted holes. A risk written after a same-level heading below the list is not read, and GitHub renders it under that heading too. `fixed: <sha>` proves the commit is in the history, not that it is the fix; the walk asks the reviewer. After a rebase the body's shas are refused by name until updated. A flag list in a ticket comment is not read.

### Test list

`tests/spec-review/review-brief.sh`, written before the script changes, in its own commit: one assertion per non-blank cell of tables A, B and C in table order, each named by its row and column, each refusal asserting exit 1, the exact stderr and that neither state directory exists. The #91 fixtures gain `accepted: fixture` on each risk line so cells 1A, 2A, 3A and 7A keep their outcome; every cell of #90's, #91's, #93's, #106's and #107's tables keeps its outcome. Word-for-word pins: the risk sentence in SKILL.md step 4, the disposition line in `opening-a-pr.md` and in the blast-radius skill's hand-back; `tests/spec-review/no-stale-wording.sh` gains the retired tail of the old risk sentence.


Posted by the agent 2026-09-23: the writer lane's flags, each with the owner's disposition.

### Writer flags 2026-09-23

1. The CI fixture step's `/tmp/blast.md` risk line in `.github/workflows/factory-ci.yml` gained a disposition, a file the brief did not name. accepted: CI's apply-diff brief is cross-cutting, so its fixture grounding must follow the new rule; the edit is the rule applied to the fixture
2. A6/F asserts today's `not cross-cutting; blast8.md is not pasted` line before the flag refusal. accepted: that line is unchanged output printed before the ticket fetch, and the cell reads RF
3. The two refusal headers are the writer's wording, ending "indent a continuation, fence a proof, and write the heading exactly that way". accepted: the contract asks each header to name every correction a reason can call for
4. The script commit alone fails the three prose pins; the suite is green from the prose commit on. accepted: criterion 4 orders the tests before the script, and each pin is prose the third commit writes
5. Table A's fixtures: F, P and R run from a text commit with the hook commit on it, R reads a round-two `fix only after` comment, S runs `--paths <hook> --commits HEAD`, and every run passes `--ticket 7` but A9's. accepted: each form is the one the table names
6. The f cells of tables B and C run with no grounding and no PR body. accepted: column f is a diff that is not cross-cutting
7. C7/f asserts three lines taken from this ticket's body, not the whole body. accepted: the hand run over the live body briefed with exit 0
8. mawk was not run locally; macOS awk ran every cell. accepted: CI on Ubuntu runs the suite under mawk before the PR is merge-ready, and the awk uses no interval expression or gawk extension
9. The refusal helper checks `.scratch/review/<id>`, not its parent. accepted: the legend names `<id>`, and today's refusals leave the parent the same way
10. The ticket fetch block moved with its text unchanged. accepted: the contract asks for the move and nothing else
11. The fake gh's `issue-error` fails both `gh issue view` calls. accepted: a failing gh fails both, and A10 reads the body call's message
12. The four playbook pointers named Ticket step 6 for both forms, while the risk form is in step 5 and Opening a PR. fixed: d016a2e
13. The blast-radius hand-back's Risks bullet also gained "one per line" and "fenced under its risk". accepted: the disposition is per line and the item rule reads a fenced proof as not a risk
14. The flag refusal is its own paragraph in spec-review step 1. accepted: the cross-cutting paragraph is about the grounding, and the flag check runs for every diff
15. The records (P108, the P28 amendment) were left to the owner. fixed: 6e5c539

