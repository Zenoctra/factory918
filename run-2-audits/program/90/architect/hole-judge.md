# Cross-judge, hole 1: what text is a `hole:` field

Read-only judgment of `hole-a.md` and `hole-b.md`, section "Hole 1", 2026-09-22. Hole 2 is not judged.

## 1. Which outcome is silent

A refuses every `hole:` text that is not a well-formed reference, with a message that shows the value and names both corrections. Nothing outside the documented path proceeds; the cost is one reworded reason. That is Manuel's "AT MOST hardening to fail fast and loud if we move outside of that", exactly.

B accepts `hole: cell 12A` as prose. The item is then an ordinary Act on item, no `restart` line, and the caller fixes it on the PR. That is the one outcome the ticket's Decision forbids ("if review brings up a design hole in the system, then it starts all 3 reviews over"), reached with no message, and it is a fail-open by the review's own definition: an input outside the documented path proceeds silently. B's own open question concedes it ("the only signal is the posted comment carrying no `restart` line"). B also does not remove the prose collision: `Not a design hole: table 1/A stands.` still matches its keyword grep and still fails the `$` check, which is why B has to add the same "if the words are prose, reword" clause A adds. So B pays A's cost anyway and buys only a lower collision rate, with a silent wrong result as the price.

## 2. The rule a reader holds

A is one clause: a `hole:` on the line, outside a trailing `fixed:` or `ticket:` field, is a mark, and a mark that is not a reference is refused. It matches the note already under table B ("the field that ends the line is the field") and needs no second list. B is two clauses plus a three-word vocabulary, and the reader must also know which near misses fall out of the vocabulary silently.

B's appeal to `fixed:`, `ticket:` and `cites:` is real but misreads why they can afford the anchor. A malformed `fixed:` or `ticket:` leaves the item counted, and a malformed `cites:` (table A row 17) leaves it uncited: both fail toward more work by the human, which is harmless. A malformed `hole:` dropped fails toward less work and the wrong kind of it. The asymmetry is principled and belongs in the Terms sentence, which A should say in one clause rather than leave implicit.

## 3. Size of the change

A: `holed()` untouched, two `fail` strings gain `value="${line##*hole:}"`. Roughly eight message assertions move, three added. No runtime behaviour changes except the wording of refusals already firing.

B: one grep line, two `fail` strings, four cells (1A, 1E, 5A, 5E) and the contract bullet. Fewer assertions move, but one existing refusal flips to acceptance (a Noted item whose reason says "design hole:" is refused today, accepted under B), which is a behaviour change riding on a term definition. The sizes are close; A's is the lower-risk shape.

## 4. The happy path

B is better here and this is its only real win: a reason reading `Not a design hole: the table stands.` is accepted. Under A it costs one refusal and one edit per collision. That collision is bounded, though: the judgment reason is one line, the word without a colon is free, and the refusal names the fix. Weighed against a hole silently fixed on the PR, one reworded sentence is the cheaper failure by a wide margin.

## Verdict

**Candidate A's rule is right.** Both rules refuse a prose collision that lands next to the grammar's keywords, so both must teach the judge to reword; the only thing B's keyword gate changes is which malformed marks stop being loud, and every one of those becomes a design hole fixed on the PR with no `restart` line, which is the single outcome ticket #90 exists to prevent and the Decision quotes put above any one criterion. A's cost is a bounded, correctable refusal on the happy path, which the review's own definition says is not a finding but the design; B's cost is a silent wrong result, which that same definition says is. A's rule is also the shorter thing to hold in mind and the smaller diff, and its one asymmetry with `fixed:` and `ticket:` is justified by direction of failure rather than by symmetry of form.

## Cells got wrong against the design

- **B, 1E and 5E.** The design's column E header names `hole: cell 12A` as a refusal. B moves it to 1A and 5A as accepted and counted, reversing a documented outcome that the finding never questioned (the finding is about prose reasons, not near-miss marks). Amending a cell outside the hole's scope, and in the forbidden direction.
- **B, 1G.** Internally contradictory: "Row 1 column G is unchanged in text" and then the G refusal gains a reword clause. G's text and G's reach both change.
- **A, the contract's second bullet under "One reference grammar".** It still reads "the judgment field on an Act on item's own line, `$`-anchored like `fixed:` and `ticket:`" — the sentence the standards finding quoted as the contradiction. A amends Terms and the cells but leaves it. It needs a clause saying the anchor is on the value (`hole: $ref$`), not on detection, which is `holed()`'s exclusion of a trailing `fixed:` or `ticket:`. B amends this sentence; A must too.
- **A, the note under table B.** "A `hole:` beside `fixed:` or `ticket:` on one line ... (each grep is `$`-anchored, so at most one matches ...)" is no longer true of `hole:` under A. The outcome it states still holds; the reason must be reworded to the `grep -vE "$ending"` exclusion.
- **A, 1G.** Amending G's message is outside the named cell but is forced by the term, since under G the correct advice is "reword". Keep it; record it as a second consequence of the same definition, as A's own open question proposes.
