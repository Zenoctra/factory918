## Would break

1. **Standards-only review can never file a Would-break or Fails-open item.** `SKILL.md:38` documents that without a ticket the Spec axis skips and the run is "Standards axis only"; that path is intended to still find and report Standards violations. But step 4's brief text at `SKILL.md:84` adds the spec rule to *every* brief unconditionally ("Then the spec rule, word for word: ... an item without a `spec:` line in one of those three forms is sent back"), and `review-brief.sh` implements it that way: `echo "$spec_rule"` at line 360 is inside the `standards-brief.md` block with no `if [ -n "$spec" ]` guard, unlike the ticket-only sections around it. `review-comment.sh:119` then calls `report "$dir/standards-report.md" ...` unconditionally too, and `report()`'s `stepless "$f" "^spec: $ref\$"` check refuses any Would-break/Fails-open item lacking a `spec:` line naming a ticket's table cell, Design signature, or acceptance criterion. In a ticket-less run there is no scenario table, `## Design` sketch, or criteria to cite — the three allowed forms all name parts of a ticket that does not exist. A real Standards finding (e.g. a bash quoting bug) is therefore unreportable: the reviewer either fabricates a fake ticket reference or the report is refused by `review-comment.sh` and the review never completes, even though nothing about the diff or the review is malformed.

This diff's own standards-brief (`.scratch/review/69bd412/standards-brief.md`, produced for this very review, which has no ticket) reproduces the bug directly: it demands a `spec:` line on any Would-break/Fails-open item with no ticket artifact anywhere in the brief to ground it against.

Documented step: `template/.agents/skills/spec-review/SKILL.md:38`, "the **Spec** sub-agent skips and the report says ... 'no spec: Standards axis only'" (a supported path), together with `SKILL.md:84`'s unconditional spec rule and `review-brief.sh:360`'s unguarded `echo "$spec_rule"`.
Result: `review-comment.sh:119`'s `report()` refuses any counted Standards item in a ticket-less run for missing `spec:`, so a genuine Standards-only review can report zero hard findings even when real ones exist.
spec: design review-brief.sh:360 echo "$spec_rule" (standards-brief block, no `[ -n "$spec" ]` guard)

Note: a later commit on this repository's real history (`90b76f7`, after the three commits reviewed here) fixes exactly this by making the spec rule and its enforcement conditional on a spec being found, confirming the gap.

## Fails open

## Standards breaches

## Fix alongside

hard findings: 1
