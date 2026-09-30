# Slice: live runtime floor, and try to break it
With a fake `gh` (read `tests/spec-review/fake-gh.sh` and the harness) and a scratch repository, at the SHA:
(a) Every shape that hides a flags list from #136's check: unclosed fence above it, the list inside a closed fence, a
    blockquote, hyphenated and singular headings, `#`-count variations, CRLF, a heading with trailing text, unicode
    lookalikes. Each is refused loudly with no review state written, or say why it passes.
(b) False refusals: a ticket with no flag list whose headings or prose mention "writer" and "flag" (the owner accepted
    `## The writer should flag risks` being refused). List every realistic heading you can find in this repository's
    own tickets (`gh issue list --state all --limit 150 --json number` then bodies) that the guard would refuse wrongly.
    Count them. That number is what Manuel needs to judge the loose match.
(c) A body with no writer-flags heading: byte for byte what origin/main prints for the same input (diff).
(d) Composition with #136's refusals, #106's fix-only rounds, #107's pack and #137's clean briefs: unchanged.
Report: `/Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.scratch/program/verify/142-30bdcae/worker-runtime.md`.
