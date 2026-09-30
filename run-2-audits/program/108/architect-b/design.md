# Ticket #108, architect candidate B

Refuse a review while a blast-radius risk or a writer flag has no disposition.

The design has state (a file it reads, exit codes, rounds, two sites), so it opens with the
scenario tables, then the contract, then the test list.

## Legend

The cell vocabulary, defined once.

- `brief` — both briefs written, exit 0, stdout is the `ticket:` / `round:` / `settled:` lines and
  the two brief paths, `.claude/state/review/` and `.scratch/review/<id>/` written as today.
- `brief+risk` — `brief`, and the Spec brief's `## Walk` bullet continues with the risk sentence.
- `standards` — `brief` with the Standards brief alone and `no spec: Standards axis only` on
  stdout, as a run with no spec prints today.
- `refused <kind>` — exit 1, the refusal message of that kind on stderr followed by the offending
  lines, nothing on stdout, no `.claude/state/review/` and no `.scratch/review/<id>/`.
- `warned` — the run continues and prints the named line on stderr.
- The four refusal kinds are `marker`, `item`, `none`, `sha`, `fence`; the Contract defines each.
- `unchanged` — the cell's behaviour is what HEAD already does; the assertion pins it so this
  ticket cannot move it.

## Table A: the blast-radius grounding

Rows are the world state (where the grounding comes from). Columns are the shape of the input
(the grounding's Risks section). The diff is cross-cutting in rows 1 and 2.

| | 1. no Risks heading | 2. heading, nothing under it | 3. every item dispositioned | 4. an item with no disposition | 5. an item `fixed: <sha>` not in the history | 6. a column-0 line that is not an item | 7. a fence under a risk that never closes |
|---|---|---|---|---|---|---|---|
| **`--blast-radius FILE`** | A1 `refused` (unchanged, names the file) | A2 `brief+risk` (unchanged) | A3 `brief+risk` | A4 `refused none`, names the file and the item line | A5 `refused sha`, names the sha and the item line | A6 `refused item`, names the line | A7 `refused fence`, names the file |
| **the PR body's `## Blast Radius`** | A8 `refused` (unchanged, names the section) | A9 `brief+risk` (unchanged) | A10 `brief+risk` | A11 `refused none`, names the section and the item line | A12 `refused sha` | A13 `refused item` | A14 `refused fence`, names the section |
| **the diff is not cross-cutting** | A15 `brief`, no `## Blast radius` section, no risk sentence, `warned` that the file is not pasted | A16 `brief`, the PR body's section is not read | same as A15/A16 | same as A15/A16 | same as A15/A16 | same as A15/A16 | same as A15/A16 |

Row 3 reads the grounding at all, so its seven cells collapse to the two the source distinguishes:
A15 for `--blast-radius FILE`, A16 for a PR body. The other five cost no code and no assertion.

## Table B: the ticket's writer flags

Rows are the world state (the run's form). Columns are the shape of the ticket body. The diff is
not cross-cutting, so Table A decides nothing here.

| | 1. no `Writer flags` line | 2. the list in `## Testing decisions`, all dispositioned | 3. the same in `## Design` | 4. a flag with no disposition | 5. a flag `fixed: <sha>` not in the history | 6. a column-0 line in the list that is not an item | 7. `Writer flags:` as plain text | 8. `## Writer flags <date>` | 9. `### Writer flags` with no date | 10. the heading under `## What to build` | 11. the heading inside a fence | 12. a fence in the body that never closes |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| **round 1 from a fixed point, `--ticket N`** | B1 `brief` | B2 `brief` | B3 `brief` | B4 `refused none`, names #N and the flag line | B5 `refused sha` | B6 `refused item` | B7 `refused marker` | B8 `refused marker` | B9 `refused marker` | B10 `refused marker` | B11 `brief` (a fence is text) | B12 `brief`, `warned` that a list after the fence is not read |
| **the sweep form, `--paths P --commits SHA --ticket N`** | same as B1 | B13 `brief` | same as B3 | B14 `refused none` | same as B5 | same as B6 | same as B7 | same as B8 | same as B9 | same as B10 | same as B11 | same as B12 |

The check is the same call in both forms, so the sweep row proves only that it runs there: one
passing cell and one refusing cell. The other ten cost no assertion.

## Table C: the cross-checks

One column, the outcome.

| situation | outcome |
|---|---|
| C1. a fix-only round 4 (`would-break fixed after <sha>`) with a flag that has no disposition | `refused none`, the same message; the flags check runs at every round |
| C2. no ticket: no `--ticket` and the commits name none | `standards`; with no body there is nothing to read and nothing is refused |
| C3. `gh issue view` fails on the ticket | `warned` with today's `gh could not fetch #N` line, then `standards`; no flags check |
| C4. a flag with no disposition and a risk with no disposition, together | `refused none` naming the ticket; the flags check runs first |
| C5. a sixth round with a flag that has no disposition | `refused` with today's sixth-round message; the round gate runs first |

## Contract

Every term the cells use.

**Cross-cutting**, **grounding**, **Risks heading**, **round**, **the sweep form**: unchanged from
HEAD. This ticket adds no predicate of its own for any of them.

**The fence rule.** The one `review-brief.sh` already holds in `$fenced`: a fence opens on a
column-0 line of three or more backticks or tildes and closes on a line of the same character, at
least as long, followed by nothing but spaces or tabs. Every rule below reads outside fenced text
with that rule, so the grammar cannot drift from the one the reports are parsed with.

**A section.** From the line that names it to the next column-0 line matching `^#+[ \t]`, outside
fenced text, or to the end of the text. This is one rule for both sites: the file form's
`## Risks` ends at `## Cleared`, the PR-body form's `### Risks` ends at `### Cleared`, and the
`### Writer flags` list ends at the next heading of any level. Every Risks section in a grounding
counts, not the first: a second `### Risks` under a first is read the same way.

**An item.** A line inside such a section, outside fenced text, that begins at column 0 with
`N. `, `N) `, `- `, `* ` or `+ ` (a number and a period or bracket, or a bullet, then a space or
tab). Under a Risks heading an item is a **risk**; under a Writer flags heading it is a **flag**.

**A continuation.** A line inside the section that begins with a space or a tab. It continues the
item above it, carries no disposition of its own, and is read for nothing. A fenced proof block
under an item is skipped by the fence rule whether or not it is indented.

**Neither.** A non-blank column-0 line inside the section that is not an item and not a heading.
The script refuses it (kind `item`) instead of guessing whether it is a risk. This is the fail-open
the grammar exists to close: a risk written as a paragraph would otherwise pass carrying nothing.

**A disposition.** The trailing field of the item's own line, whitespace-separated:

- `fixed: <sha>` — the last two fields are the word `fixed:` and a value of 7 to 40 characters
  from `[0-9a-f]`. The value must resolve to a commit here and be HEAD or an ancestor of it.
- `accepted: <reason>` — some field before the last is the word `accepted:`. At least one field
  follows it, so a line ending in a bare `accepted:` carries no reason and is not a disposition.

`fixed:` is tested first and wins when both are present, so a reason that ends in a fix marker
reads as fixed. A marker inside prose is a field of its own only when it is spelled with the
colon and followed by its value, so `the hook is not fixed: it still runs` is not a disposition
and the line is refused for having none, and `prefixed: 9c1f2ab` is a single field and matches
nothing. A disposition on a continuation line does not count: criterion 1 puts it on the risk's
own line, and reading continuations would let one risk's disposition cover the next.

**The Writer flags list.** A line that is exactly `### Writer flags <date>`, `<date>` as
`YYYY-MM-DD`, inside the ticket body's `## Testing decisions` or `## Design` section, outside
fenced text. Its items are the flags. Its date is the day the writer's report was dispositioned,
written by the owner in the same edit that adds the list, and is read by people, not by the script
beyond its shape. Both sections are allowed because ticket.md step 6 puts a scenario table under
the first and a signature sketch under the second, and the flags belong beside whichever the
ticket carries.

**A near-miss marker.** A column-0 line, outside fenced text, matching `^#*[ \t]*Writer flags`
that is not the exact heading, or that is the exact heading while the enclosing `## ` section is
neither `Testing decisions` nor `Design`. Refused (kind `marker`). Without this rule every
near miss is a silent pass, which is the fail-open on the ticket side.

**An unclosed fence.** A fenced block still open at the end of the text. In a grounding it is
refused (kind `fence`): everything after it is invisible, so a risk inside it would pass carrying
nothing, and the grounding is written by this lane for this gate. In a ticket body it is warned
about, not refused: the body is the human's and predates the gate, and refusing every review whose
ticket has a stray fence buys a rare fail-open at the cost of blocking unrelated work.

**The refusal.** Exit 1 with a message on stderr, then each offending line verbatim, indented two
spaces, one per line. Nothing is written: the ticket check runs before `.scratch/review/<id>/`
exists, and the grounding check removes the directory as the two refusals beside it already do.

**Order.** The round gate, then the ticket's flags, then the diff, then the grounding's risks. The
flags check does not depend on the diff, so it runs before any of it; a refusal names one fault at
a time, and the earliest one wins.

## The caller's usage

An owner who dispositioned the report writes this in the grounding file:

```md
## Risks

1. A subagent inherits the hook: `.claude/hooks/x.sh:1`. fixed: 9c1f2ab
2. `factory-start` runs it at day zero: `.claude/hooks/x.sh:1`. accepted: day zero has no skills to reach and the hook exits 0 without them.
   Proof: the day-zero run of `tests/hooks/delegation.sh`.
```

Each disposition ends its own risk's line. The third line continues risk 2, carries its evidence,
and needs no disposition. A disposition written on a continuation line instead is refused, and the
message says where it goes.

And this on the ticket, inside the section the design record already occupies:

```md
## Testing decisions

Posted by the agent 2026-09-23

### Writer flags 2026-09-23

1. The fake gh has no ticket-body fixture, so the new cells need one. fixed: 9c1f2ab
2. The sweep form has no PR, so its grounding can only come from `--blast-radius`. accepted: the sweep reviews units already on main, where there is no PR body to read.
```

Then `review-brief.sh HEAD~3 --ticket 108 --blast-radius .scratch/108/blast-radius.md` briefs as
today. Without either disposition it refuses and says which line to correct.

## Module map and signatures

One script changes. No new file: the whole addition is one awk program, one shell function and a
moved fetch, about fifty lines inside `template/.agents/skills/spec-review/scripts/review-brief.sh`.
`reading-pack.sh` earned its own file at 200 lines (P107); this does not.

`template/.agents/skills/spec-review/scripts/review-brief.sh`

- `dispositions` — an awk program string beside `$split`, `$fenced` and `$ref`, built once, read
  with `-v head=` and `-v mode=`. It prints one tab-separated record per offender and nothing
  else, so the shell decides what to say and git stays out of awk.

  ```awk
  # -v mode=risks|flags. Prints `marker\t<line>`, `item\t<line>`, `none\t<line>`,
  # `sha\t<sha>\t<line>` (the caller resolves it) and `fence\t` at EOF.
  BEGIN { item = "^([0-9]+[.)]|[-*+])[ \t]" }
  { sub(/\r$/, ""); sub(/[ \t]+$/, "") }
  <the shared fence rule, which also sets h on a `## ` line>
  mode == "flags" && /^#*[ \t]*Writer flags/ {
    if ($0 !~ /^### Writer flags [0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]$/ ||
        (h != "Testing decisions" && h != "Design")) { print "marker\t" $0; next } }
  /^#+[ \t]/ { on = ($0 ~ head); next }
  !on || $0 == "" || /^[ \t]/ { next }
  $0 !~ item { print "item\t" $0; next }
  { if (NF >= 2 && $(NF - 1) == "fixed:" && $NF ~ /^[0-9a-f]+$/ && length($NF) >= 7 && length($NF) <= 40) {
      print "sha\t" $NF "\t" $0; next }
    ok = 0; for (i = 1; i < NF; i++) if ($i == "accepted:") ok = 1
    if (!ok) print "none\t" $0 }
  END { if (fence != "") print "fence\t" }
  ```

  The length tests stand in for `{7,40}`, the way the `reviewed:` and `fix only after` parses
  already stand in for an interval expression a few lines above.

- `dispositioned <text-file> <mode> <what> <where>` — the shell side. Reads the awk's records,
  groups them by kind, and on the first kind present prints the message for that kind with its
  lines and returns 1; resolves each `sha` record with `git rev-parse --verify -q "$s^{commit}"`
  and `git merge-base --is-ancestor "$s" HEAD`. `<what>` is the word `risk` or `flag`; `<where>`
  is the phrase the message names (`blast.md`, `the PR body's Blast Radius section`, `#108`). The
  caller decides what to do with the 1: the ticket site exits, the grounding site removes `$dir`
  first. Message order: `marker`, `item`, `none`, `sha`, `fence`.

- The ticket body fetch moves from its place after the state (today around line 390) to just
  before the first stdout line (today line 266), into a `mktemp` with a `trap 'rm -f "$tb"' EXIT`,
  and `cp "$tb" "$dir/ticket.md"` stays where the file is written today. The comments fetch does
  not move: it needs no check and costs a second call only when a spec exists. This is the split
  the ticket's fourth bullet asks for; nothing else in the script reads `$dir/ticket.md`.

- `risk_rule` gains one clause.

Word-for-word copies, each already held together by `tests/spec-review/review-brief.sh`:

- `patches/mattpocock/spec-review.SKILL.md.patch` — step 1's cross-cutting paragraph gains the two
  new refusals in the voice of the two it already quotes; step 4's Walk bullet carries the new
  risk sentence.
- `patches/pstack/poteto-mode/playbooks/opening-a-pr.md.patch` — the `## Blast Radius` bullet gains
  the disposition line.
- `patches/pstack/blast-radius/SKILL.md.patch`, **new**, with `patches/series` and `SOURCES.md` —
  the "What to hand back" Risks bullet gains the disposition. The skill is vendored from
  `research/3-pstack/`, so a direct edit would be lost at the next `factory918 sync`.
- `patches/pstack/poteto-mode/playbooks/feature.md.patch` — step 4's act-on sentence loses its
  forward reference to this ticket and names the refusal in the present tense.
- `template/.agents/skills/poteto-mode/playbooks/ticket.md` step 5, edited directly (not vendored)
  — the grounding's shape sentence gains the disposition, and step 6 gains the flags list beside
  the design record.
- `tests/spec-review/no-stale-wording.sh` — add `and saying what the diff does at that risk`, the
  risk sentence's retired tail, with a line in its header comment.
- `tests/spec-review/fake-gh.sh` — `FAKE_TICKET_BODY`, a file read for `gh issue view --json body`
  the way `FAKE_PR_BODY` is read for `gh pr view --json body`; unset, the fixed body as today.
- `docs/knowledge/core/DECISIONS.md` — a `P108` row, then `python3 tools/build_knowledge.py`.

## The new risk sentence

Today:

> The diff is cross-cutting: after the lines per documented step, one numbered line per risk under
> the Risks heading of the `## Blast radius` section above, in its order and numbered on from the
> last step, each naming the risk and saying what the diff does at that risk; a risk line is a walk
> line and counts nothing.

Proposed:

> The diff is cross-cutting: after the lines per documented step, one numbered line per risk under
> the Risks heading of the `## Blast radius` section above, in its order and numbered on from the
> last step, each naming the risk, quoting its disposition (`fixed: <sha>` or `accepted: <reason>`)
> and saying whether the diff honors it; a risk line is a walk line and counts nothing.

It keeps the sentence's skeleton, so the existing assertion `"${spec_bullets[0]} $risk_rule"` needs
only its new text. `honors` is the ticket's own word. The sentence is carried by the script's
`risk_rule` and by step 4's Walk bullet in the spec-review patch, and nowhere else.

## The refusal messages

Each is one line on stderr, then the offending lines indented two spaces.

`none`, at the grounding:

```
review-brief: the blast-radius grounding (blast.md) carries risks with no disposition; end each risk's own line with `fixed: <sha>` or `accepted: <reason>` (a bare `accepted:` with nothing after it is not a reason, and a line that continues a risk is not the risk's line); nothing written
  1. A subagent inherits the hook: `.claude/hooks/x.sh:1`.
```

`none`, at the ticket: the same sentence with `#108's `### Writer flags` list` in place of the
parenthetical and `flags` for `risks`.

`item`:

```
review-brief: the blast-radius grounding (blast.md) carries a line under its Risks heading that is not a risk; write one risk per line, numbered or bulleted, and indent whatever continues one; nothing written
  the hook reaches a subagent too
```

`sha`:

```
review-brief: the blast-radius grounding (blast.md) marks a risk `fixed: deadbeef`, and that commit is not in this branch's history; name the commit that carries the fix, or write `accepted: <reason>`; nothing written
  1. A subagent inherits the hook: `.claude/hooks/x.sh:1`. fixed: deadbeef
```

`fence`:

```
review-brief: the blast-radius grounding (blast.md) has a fenced block that never closes, so the risks after it cannot be read; close the fence; nothing written
```

`marker`:

```
review-brief: #108 carries a line that names writer flags but is not the list's heading; the list is a line that is exactly `### Writer flags <date>` (the date as YYYY-MM-DD) inside the ticket's `## Testing decisions` or `## Design` section, and the writer's flags are its items; nothing written
  ## Writer flags 2026-09-23
```

The ticket's unclosed-fence warning, which refuses nothing:

```
review-brief: #108's body has a fenced block that never closes; a `### Writer flags` list after it is not read
```

## Test list

`tests/spec-review/review-brief.sh`, one assertion per cell, in the order the cells are written,
each inside the existing `suite()` so it runs in both layouts. Written before the script changes,
in that commit order (criterion 4). The fixture built once beside `blast.md`: `blast-fixed.md`
(a risk ending `fixed: <HEAD~1's short sha>`), `blast-accepted.md`, `blast-none.md`,
`blast-badsha.md`, `blast-prose.md`, `blast-openfence.md`; and ticket bodies `tk-none.md`,
`tk-td.md`, `tk-design.md`, `tk-flag-none.md`, `tk-flag-badsha.md`, `tk-flag-prose.md`,
`tk-plain.md`, `tk-level.md`, `tk-nodate.md`, `tk-wrong-section.md`, `tk-fenced.md`,
`tk-openfence.md`, each named by `FAKE_TICKET_BODY`. A `refused_disp` helper beside the existing
`refused_risks` takes the expected message, runs the script, and asserts exit 1, the exact stderr,
empty stdout, no `.claude/state/review` and no `.scratch/review/<id>`.

Table A, the grounding, cross-cutting fixture as today (`$hooks/x.sh`):

1. A1 `--blast-radius blast.md` (no Risks heading) is refused with today's message naming the
   file, no state. Fixture: `blast.md`, unchanged.
2. A2 `--blast-radius blast-empty-risks.md` briefs and the Walk bullet carries the new risk
   sentence. Fixture: `blast-empty-risks.md`, unchanged.
3. A3 `--blast-radius blast-fixed.md` briefs; both briefs carry the grounding; the Spec bullet is
   `${spec_bullets[0]} $risk_rule`. Fixture: a risk ending `fixed:` with `git rev-parse --short
   HEAD~1`, and a second ending `accepted: a reason`.
4. A4 `--blast-radius blast-none.md` is refused `none`, stderr exactly the message plus the one
   risk line, no state. Fixture: two risks, the second without a disposition.
5. A5 `--blast-radius blast-badsha.md` is refused `sha`. Fixture: `fixed: deadbeef`, which does not
   resolve. A second run with a real commit id that is not an ancestor (a commit made on a second
   branch) gives the same message; both are the one cell, asserted once each because the two git
   tests are separate lines of the script.
6. A6 `--blast-radius blast-prose.md` is refused `item`. Fixture: a column-0 sentence under the
   heading, after a dispositioned risk, so the refusal is the line and not the absence of risks.
7. A7 `--blast-radius blast-openfence.md` is refused `fence`. Fixture: a dispositioned risk, then
   an opening ` ``` ` and no close, then an undispositioned risk. The assertion is the `fence`
   message, and its point is that the hidden risk did not pass.
8. A8 to A14 repeat 1 to 7 through the PR body: `FAKE_PR_BODY` set to a body whose `## Blast
   Radius` section holds the same text with its headings demoted, as the existing 3A fixture does,
   and the `where` in each message is `the PR body's Blast Radius section`.
9. A15 a README-only diff with `--blast-radius blast-none.md` briefs, prints today's `is not
   pasted` line, and neither brief carries `## Blast radius` or the risk sentence.
10. A16 a README-only diff with `FAKE_PR_BODY` holding an undispositioned section briefs the same
    way and reads nothing from the body.

Table B, the writer flags, `--ticket 108` and a README-only diff throughout:

11. B1 `tk-none.md` briefs.
12. B2 `tk-td.md` (the list under `## Testing decisions`, one flag `fixed: <HEAD~1>`, one
    `accepted: a reason`) briefs, and the Spec brief carries the list as part of the ticket body.
13. B3 `tk-design.md` (the same list under `## Design`) briefs.
14. B4 `tk-flag-none.md` is refused `none` naming `#108` and the flag line, with no state.
15. B5 `tk-flag-badsha.md` is refused `sha`.
16. B6 `tk-flag-prose.md` is refused `item`.
17. B7 `tk-plain.md` (`Writer flags:` at column 0 inside `## Testing decisions`) is refused
    `marker`.
18. B8 `tk-level.md` (`## Writer flags 2026-09-23`) is refused `marker`.
19. B9 `tk-nodate.md` (`### Writer flags`) is refused `marker`.
20. B10 `tk-wrong-section.md` (the exact heading under `## What to build`) is refused `marker`.
21. B11 `tk-fenced.md` (the exact heading inside a fenced block, with an undispositioned item
    under it) briefs: fenced text is text.
22. B12 `tk-openfence.md` briefs and prints the unclosed-fence warning on stderr.
23. B13 the sweep form, `--paths a.txt --commits <sha> --ticket 108`, with `tk-td.md`, briefs.
24. B14 the same sweep with `tk-flag-none.md` is refused `none`.

Table C:

25. C1 a fix-only round 4: the existing `would-break fixed after <sha>` fixture, `tk-flag-none.md`,
    refused `none`.
26. C2 no `--ticket` and a commit message naming none: the Standards brief alone, `no spec:
    Standards axis only`, no flags check, no refusal.
27. C3 `FAKE_TICKET_BODY` naming a missing file so the fake gh fails: today's `gh could not fetch`
    line on stderr, the Standards brief alone, no refusal.
28. C4 a cross-cutting diff with `blast-none.md` and `tk-flag-none.md`: refused `none` naming
    `#108`, not the grounding.
29. C5 a sixth round with `tk-flag-none.md`: today's sixth-round message.

Word-for-word, beside the existing `has "$source_skill/SKILL.md" "$blast_rule"` assertions:

30. D1 the source SKILL.md carries the new `$risk_rule`.
31. D2 the source SKILL.md step 1 carries each new refusal message's first clause.
32. D3 `bash tests/spec-review/no-stale-wording.sh` finds no hit for the retired tail.

## Rationale

**Why one grammar and two sites.** The two criteria describe the same shape: a list of things the
owner was handed, each of which must say what was done about it. Writing two parsers would double
the surface and let the two drift, which is the failure `tests/spec-review/review-brief.sh` exists
to prevent for the prose. One awk with a `head` and a `mode` hides both sites behind one function,
and the `marker` kind is the only thing the flags site adds. Interface depth: the caller passes a
file, a mode and two words for the message, and gets back a refusal or silence.

**Why the disposition is the trailing field.** It is the grammar the repository already uses. The
judgment's Act on items end in `fixed: <sha>` or `ticket: #N`, and `review-comment.sh` anchors the
value at the end of the line for exactly the reason this needs it: a field at the end cannot be
confused with prose. Reusing it means an agent that has written one has written the other, and the
`fixed: <sha>` marker already means "fixed on this PR at this commit" (P20).

**Why the sha must resolve and be an ancestor.** A gate whose token is any hex string invites a
plausible string. Resolving costs two git calls per marked risk and catches the invented sha, the
sha from another repository, and the fix that lives on a branch this PR does not carry, which is
the one that would mislead a reviewer into checking a diff that has no fix in it. Not required to
be inside `fixed..HEAD`: a risk fixed before the fixed point is still fixed, and a fix-only round
four has a very late fixed point.

**Why a non-item line is refused rather than read as a risk.** Reading every column-0 line as a
risk would refuse a lead-in sentence and any prose the author writes around the list, which makes
the gate hostile. Reading only items lets a risk written as a paragraph pass carrying nothing,
which is the fail-open. Refusing the ambiguity is the third way, and it is what Manuel's "AT MOST
hardening to fail fast and loud" asks for: the input outside the documented path is refused with a
message saying how to correct it, which the review definition already calls the design and not a
finding.

**Why bullets count.** The blast-radius skill's own hand-back is a bullet list, and it is vendored.
A grammar that accepted only `N. ` would refuse the upstream shape and push the author into
reformatting text the skill told them to write. `N. ` stays what ticket.md asks for; `- ` is
accepted, not recommended.

**Why the flags list is a `###` heading inside the two design sections.** ticket.md step 6 already
holds the design record there, and the step-1 overlap check skips those two sections, so a path a
flag quotes does not become a path the ticket names. A marker anywhere else is refused rather than
ignored, which is the difference between a convention and a gate.

**Why the flags check runs at every round and in the sweep form.** A flag left open at round four
is as ungrounded as one left open at round one, the correction is one `accepted: <reason>` edit,
and a round-dependent branch would be a state machine nobody asked for. Laziness protocol: the
uniform rule is smaller than the exception.

**Why the ticket fetch moves rather than being duplicated.** Two fetches would be two states of the
same body and a second gh call per run. Moving the one fetch to just before the first stdout line
puts it after the cheap refusals (the smell baseline, the ticket count, the round gate), so a run
refused for a sixth round still pays nothing, and before any byte of state, which is the
criterion. `$dir/ticket.md` is written from the same temp file, so its bytes do not change.

**Rejected.** A separate `dispositions.sh` beside `reading-pack.sh`: fifty lines that no other
caller wants, and P107 put the pack in its own file for size, not for principle. Requiring
`## Risks` to be numbered: refuses the vendored hand-back shape. Reading a disposition from a
continuation line: lets one risk's disposition cover the next. Accepting a bare `accepted:`:
a disposition-shaped no-op, which is the fail-open in miniature. Refusing a ticket body whose
fence never closes: blocks unrelated reviews on a body the gate does not own. A `disposition:`
field on its own line under each risk: a second grammar for the same fact, and the criterion says
the risk's own line. Checking the disposition against the diff (does the commit touch the risk's
`file:line`): that is the reviewer's job, and the new risk sentence gives it to them.

**Red-flag screen.** No shallow module: `dispositioned` hides the parse, the git resolution and
five messages behind four arguments. No information leakage: the fence rule and the heading rule
live in one place and both sites read them. No temporal decomposition: the function is named for
what it decides, not for when it runs. No pass-through: the shell side does the git work awk
cannot, and the awk does the parse the shell should not.

## Adversarial inputs tried against this grammar

Each was walked line by line against the awk above.

1. `1. A subagent inherits it: \`x.sh:1\`.` under `## Risks`. No `fixed:` pair, no `accepted:`
   field. `none`. Refused. Correct: this is #96's risk, the one that cost two rounds.
2. `- **Risks.** \`factory-start\` at day zero runs it: \`x.sh:1\`.` with no heading. The existing
   heading check refuses it first, unchanged (A1). Correct: the bullet hand-back still has to grow
   a heading, as it does today.
3. `1. the hook is not fixed: it still runs at day zero.` The last two fields are `it` and
   `day zero.`, so no `fixed:` pair; no field equals `accepted:`. `none`. Refused. The `fixed:`
   inside prose does not open the gate, which was the input I most expected to fail open.
4. `1. the risk was accepted: nobody runs day zero.` A field equals `accepted:` with fields after
   it. Passes as `accepted: nobody runs day zero.` Accepted deliberately: the sentence is a
   disposition with a reason, and the reviewer reads it as one.
5. `1. a risk. prefixed: 9c1f2ab`. One field `prefixed:`, so no `fixed:` pair and no `accepted:`
   field. `none`. Refused. A marker glued to a word does not count.
6. `1. a risk. fixed: abc1234.` The last field is `abc1234.`, not hex. `none`. Refused, and the
   message says how to correct it. A trailing period costs one edit, not a silent pass.
7. `1. a risk. accepted:` with nothing after. The `accepted:` field is the last field, so the loop
   that requires `i < NF` does not find it. `none`. Refused, and the message names the empty reason.
8. `1. a risk. accepted: rare. fixed: 9c1f2ab`. The `fixed:` pair is tested first and wins; the sha
   is resolved. Correct: the trailing field is the disposition, whatever precedes it.
9. A risk wrapped over two lines with `accepted: rare.` on the second, indented. The second line is
   a continuation and is skipped; the first has no disposition. `none`. Refused, and the message's
   parenthetical says a line that continues a risk is not the risk's line. This one is a real cost:
   it is the shape a writer reaches for, and it is why the message carries that clause.
10. `## Risks` with nothing under it. Zero items, zero offenders. Briefs with the risk sentence,
    as HEAD does (A2, the existing 8A cell). The grammar does not move a cell #91 settled.
11. `## Risks` then `1. a risk. fixed: 9c1f2ab` then `### Risks` then `2. another risk.` Both
    sections are read, because `on` is recomputed at every heading rather than latched. `none` on
    the second. Refused. The existing check exits at the first heading it finds, so reading only
    the first section would have been the natural port and a fail-open; the existing 7A fixture is
    exactly this shape and would have passed.
12. A dispositioned risk, then an unclosed ` ``` `, then an undispositioned risk. Everything after
    the fence is fenced text, so the second risk is invisible and the section never ends. Without
    the `END` rule this briefs and the hidden risk passes. `fence`. Refused. This is the hole the
    brief warned #106's verifiers found by trying inputs, and it is the reason the `fence` kind
    exists.
13. A fenced block, properly closed, under a risk, holding the text `1. a risk` at column 0. The
    fence rule skips it, so it is not an item and not an offender. Briefs. Correct: the proof block
    the blast-radius skill asks for does not become a risk.
14. A ticket body whose `## Testing decisions` section quotes `### Writer flags 2026-09-23` inside
    a fenced example, with an undispositioned item under it. Fenced, so no marker and no items.
    Briefs. Correct: a ticket that documents this feature, such as #108's own body once the table
    lands, does not refuse every review of it. The same text outside a fence is a real heading and
    a real list, and is read as one.
15. A ticket body with `Writer flags: none this time` at column 0 under `## Testing decisions`.
    Matches the marker rule, is not the exact heading. `marker`. Refused. Without the marker rule
    this is the whole ticket-side fail-open: a list the owner thought they had written.
16. A ticket body with `### Writer flags 2026-09-23` under `## What to build`. The exact heading,
    the wrong enclosing section. `marker`. Refused, and the message names the two sections.
17. A ticket body with `### Writer flags 2026-9-3`. The date shape fails, so it is a near miss.
    `marker`. Refused.
18. A CRLF ticket body from the web UI. Every line loses its CR in the first rule, as the rest of
    the script already does. Reads the same as a body posted by `gh`.

## Synthesis notes for the orchestrator

The two decisions I would defend hardest, because they are where a smaller design fails open:
reading every Risks section rather than the first (input 11, which the existing 7A fixture would
have walked straight through), and refusing an unclosed fence in the grounding (input 12). The
decision I am least sure of is input 9, the disposition on a wrapped line: it is the friendliest
thing to relax, and relaxing it means reading an item's block rather than its line, which costs
one more awk state and weakens criterion 1's words. I left it strict and paid for it in the
message.
