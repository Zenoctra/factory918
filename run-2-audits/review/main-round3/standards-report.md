## Would break

## Standards breaches

1. **Step 6's refusal list omits the numbering refusal.** `numbered()` is a real exit-1 path with its own fixture (`tests/spec-review/review-comment.sh`, "numbering restarts under the second heading"), but SKILL.md step 6 enumerates the refusals and leaves it out, so an orchestrator that hits it has no documented reason. CODING_STANDARDS.md, Markdown: skills are written with `/writing-for-agents`; the script's own documentation should list what it refuses.

```
It exits 1, printing why and clearing nothing, when a report is missing or has no `hard findings:` line (...); when a report's `hard findings: N` is larger than its `## Would break` item count (...); when a report's or the judgment's `## ` headings are not the shape above; when `judgment.md` is missing; when the judgment's item count differs from the reports'; or when a `[S<n>]` or `[P<n>]` reference is missing, repeated or points at no item.
```

## Fix alongside

2. **The fixed point prefers a foreign state over the dir's own copy.** Judgement call. On a rerun (`review-comment.sh <dir>`) while a *different* review holds the state, the summary prints that other review's fixed point. `review-brief.sh` now writes `$dir/fixed-point` precisely so the dir is self-describing; the two branches are in the wrong order. The script already guards the same mismatch one line below when clearing the state.

```sh
if [ -f "$state/fixed-point" ]; then fixed="fixed point $(cat "$state/fixed-point")"
elif [ -f "$dir/fixed-point" ]; then fixed="fixed point $(cat "$dir/fixed-point")"
```

3. **Duplicated Code: the report shape lives in two files, one sentence of it pinned.** `review-brief.sh` writes the heading bullets and SKILL.md step 4 repeats them verbatim, but `tests/spec-review/review-brief.sh` asserts only `$definition` against SKILL.md. The heading descriptions can drift silently. Extend the existing `has "$skill/SKILL.md" ...` line to the three bullets.

```sh
has "$skill/SKILL.md" "$definition" "SKILL.md step 4 carries the definition"
```

4. **The CommonMark claim is wider than the code.** A closing fence may not carry an info string; this treats ```` ```sh ```` inside a ``` block as a close. The longer-fence case is tested, so the behavior is fine, but the comment overstates it.

```sh
# same character at least as long (CommonMark), so a hunk that quotes a fence stays inside its
```

hard findings: 0
