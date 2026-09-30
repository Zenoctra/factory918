# Slice: the briefs a reviewer actually reads
With a fake `gh` (read `tests/spec-review/fake-gh.sh` and the harness) and a scratch repository, generate at the SHA:
a round-one Standards and Spec brief, a round-two whole-diff brief after a round one with dispositioned items, a fix-only
round-three brief (#106), a brief with a reading pack (#107), and a cross-cutting brief with blast-radius risks (#108).
For each, read it top to bottom as a reviewer and quote every sentence that (a) states or implies an expected number
or kind of result, (b) caps words, items or effort, (c) limits reading or read-only commands, (d) tells a later round
anything about earlier rounds' findings, fixes or ratings beyond what 6e5c539 already told it (diff the round-two and
round-three briefs against 6e5c539's for the same history). Anything in (a) to (c), or new in (d), is an issue. Confirm
Manuel's quote is word for word and followed by the fails-open line. Diff every brief against 6e5c539's for the same
input and list every changed sentence; nothing outside the ticket's five lines and the fails-open line should change.
Report: `/Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.scratch/program/verify/140-e710e99/worker-runtime.md`.
