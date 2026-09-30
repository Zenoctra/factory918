## Standards

## Would break

## Fails open

## Standards breaches

## Fix alongside

1. **Mysterious Name: the global `ref` holds a regex, not a reference.** In both scripts `ref=` is the reference *grammar*, while every other use of the word (the `hole:` reference, the `[S<n>]` reference) is a value. The diff had to rename the judgment loop's variable to `ref_id` to stop it clobbering the pattern, which is the collision arriving. The hole loop below also writes `f`, `at`, `want` and `mark` at global scope, and `want` is a name the earlier reference check already used for something else.

```sh
ref='(table [^[:space:]/]+/[^[:space:]/]+|design [^[:space:]].*|criterion [1-9][0-9]*)'
...
  ref_id="$(printf '%s' "$line" | sed -nE 's/^[0-9]+\. \[([SP][0-9]+)\].*/\1/p')"
  at="${rests%%$'\t'*}"; want="${rests#*$'\t'}"
```

Rename the pattern (`ref_re`) and re-anchor the test's `fragment()`, which matches `/^ref='/p`.

2. **Duplicated Code: the reference grammar is written seven times.** Two script copies, held together by `tests/spec-review/review-brief.sh`'s `fragment()`; then five prose copies that nothing holds — two refusal strings in `review-comment.sh`, the spec rule in `review-brief.sh`, `SKILL.md` step 5, `review-ladder.md` and `DECISIONS.md` P26. `tests/spec-review/no-stale-wording.sh` already exists for this class of drift, and this change extends it; one more grep there for the three forms would cover the prose copies the way `fragment()` covers the code.

```sh
fail "... one of 'spec: table <row>/<column>', 'spec: design <signature>' or 'spec: criterion <k>', on its own line. ..."
```

3. **Divergent Change: `review-ladder.md` rung 1 is one bullet carrying four subjects.** It already held what a review counts, the blast-radius precondition, the round cap and where fixes land; this change adds the whole design-hole definition, the detection-confidence ranking and the marking mechanism to the same sentence chain.

```md
- **Rung 1 — spec-review.** ... An Ask item waits for the human. A finding is a design hole when its fix changes the artifact the work was built against rather than the code that implements it: a cell of the ticket's scenario table ... Detection is sharpest for a table and softest for a criterion; all three are marked the same way. ...
```

The ladder is a routing table; the definition belongs in `SKILL.md` step 5, which already carries it word for word. Fix only if a would-break fix touches the rung.

hard findings: 0

## Spec

## Walk

1. Criterion 1: the design-hole definition is in `spec-review/SKILL.md` step 5 and `template/docs/agents/review-ladder.md:6`, both naming the three artifacts, the intent-outranks-a-criterion clause and the could-not-run exemption.
2. Criterion 2: `spec_rule` is echoed one blank line after `$step_rule`, in the Standards brief only when `$spec` is set and always in the Spec brief; `report()` runs `stepless` twice, the step refusal first, the `spec:` refusal second, and returns before the spec scan when `spec-brief.md` is absent.
3. Criterion 3: `holed()` takes the text from the last `hole:` on an Act on line not ending in a `fixed:` or `ticket:` field; four refusals fire in the amended order (no spec, placement, form, value); `holes` is subtracted from the count and `echo restart` sits between the summary and `round:`.
4. Criterion 4: the slicing awk drops every line up to the last `restart` comment and prints the cut count, so the round, the fourth-round refusal and `settled:` read the new series alone; `restart:` prints after `ticket:`; the Ticket playbook gains `### Design hole` and step 8's pointer.
5. Criterion 5: `cites:` gains `#[0-9]+ $ref` inside the anchored group; `review-comment.sh` still never reads `cites:` and `review-brief.sh` never reads `hole:`.
6. Criterion 6: the tests cover table A rows 5 to 8, 11 to 13 and 14 to 17, the no-spec brief layout, and `fragment()` over the two `ref=` lines; table B rows 1D to 1G, 2, 3, 4, 5A and 5D to 5G, 6, 7 and the three notes.
7. Criterion 7: the babysit sentence is the same in `babysit/SKILL.md:41` and `playbooks/babysit.md:18`, columns A to C keep their assertions, and every other reader of `act-on items:` (MANUAL, review-ladder, P20) gains the restart clause.

## Would break

## Fails open

## Not asked for

1. **A malformed mark's value is printed as written, not blank-stripped.** `value()` is `${1##*hole:}`, so `hole:table 2/D` is refused as `'hole:table 2/D'`; under the amended contract the template is `'hole: <value>'` with the value blank-stripped, which would print `'hole: table 2/D'`. A new assertion pins the as-written form for a spelling column E does not list, and no dated line amends the ticket for it. Every value the table does list renders identically either way.

```
`<value>` is the text after `hole:` with leading blanks stripped
```

hard findings: 0

## Judgment

## Act on

## Ask

## Consider

1. [S2] **The reference grammar is written in seven places.** Valid: `fragment()` holds the two script copies and nothing holds the five prose copies; a grep in `no-stale-wording.sh` for the three forms is a two-line follow-up, not worth a round here.

## Noted

2. [S1] **`ref` holds a grammar, not a reference.** Valid; the rename touches both scripts, the test's `fragment()` anchor and nothing under review would break; a later tidy.
3. [S3] **Rung 1 carries four subjects.** Valid; the ladder's bullet grew with every review decision, and splitting it is a ladder change outside this ticket.
4. [P1] **The refused value is shown as written, not blank-stripped.** Valid: the round-one fix changed that contract phrase; the ticket's section now carries a dated line saying the value is shown as written, no cell's outcome changed. cites: user: "AT MOST hardening to fail fast and loud if we move outside of that" on #90

## Dismissed

Standards: 0 would break, 0 fail open, of 3; Spec: 0 would break, 0 fail open, of 1; judged: act on 0 (0 fixed, 0 with a ticket), ask 0, consider 1, noted 3, dismissed 0; fixed point 69bd412.
round: 2 of 3
act-on items: 0
