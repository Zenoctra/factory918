# Slice: live runtime floor, and try to break it
With a fake `gh` (read `tests/spec-review/fake-gh.sh` and the harness first) and scratch repositories, at the SHA:
(a) A cross-cutting diff whose blast-radius grounding has a risk with no disposition: refused, exit 1, nothing written
    under `.claude/state/review` or `.scratch/review/<id>`, message names the line. With `fixed: <sha>` (a real commit in
    the diff), `fixed: <bogus>`, `accepted: <reason>`, `accepted:` empty: say what each does.
(b) A ticket body with `### Writer flags <date>` and a bare flag: refused naming it; with dispositions: passes; a ticket
    with no list: unaffected, byte for byte what a9ebdac prints for the same input.
(c) Adversarial: the flags list inside a fence, after an unclosed fence (the owner's S1), duplicated headings, CRLF,
    a `fixed:` sha that is not an ancestor of HEAD, a sha of the wrong length, a disposition on the next line,
    unicode in the reason. Does any shape pass a flag that has no real disposition? That is the one that matters.
(d) Composition: fix-only round three (#106) and the reading pack (#107) still behave as at a9ebdac for inputs with no
    risks or flags (diff the outputs).
(e) The live ticket #108's own list: run the real script against it (`--ticket 108`) and report.
Report: `/Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.scratch/program/verify/136-6e5c539/worker-runtime.md`.
