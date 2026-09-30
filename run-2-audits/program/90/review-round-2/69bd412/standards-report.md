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
