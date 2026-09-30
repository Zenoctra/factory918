# Slice: live runtime floor, and try to break the pack
With a fake `gh` (read `tests/spec-review/fake-gh.sh` and the harness first) and scratch repositories, at the SHA:
(a) Run the real brief over the chain itself (`review-brief.sh` or `reading-pack.sh origin/main` as the owner did) and
    read the pack as a reviewer would: is the code a reviewer needs there, cut at sensible boundaries, in production
    order, under 65536 bytes, with a correct `Not carried` line? Quote the headers.
(b) Adversarial: file names with spaces, newlines, leading dashes, unicode; a renamed file; a mode-only change; CRLF;
    a file with no trailing newline; a shell file with nested functions and heredocs containing `}`; a markdown file
    with fenced code containing `#` lines; a 1-byte-over-cutoff file; a single line longer than 4096 bytes; binary
    detection (NUL byte, a UTF-16 file); a symlink out of the repo; a submodule; `linguist-generated`; an empty diff.
    For each: output, exit code, and whether a reviewer is misled or the brief breaks.
(c) Safety: a secret-looking file (`.env` added in the diff) — does the pack copy it into a brief that gets posted or
    shared? Say what the brief's audience is and whether that matters.
(d) Determinism: two runs give byte-identical packs; locale (`LC_ALL=C` vs `en_US.UTF-8`) does not change selection.
(e) Composition with #125: rounds one and two still print what 0edf8c8 prints except the new section; a fix-only
    round three's pack covers the fix, not the whole diff (or say which, and whether that matches the ticket).
(f) A git failure inside the pack refuses the brief before any state is written (break `git` via PATH and check the
    state dir is untouched).
Report: `/Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.scratch/program/verify/126-f58308b/worker-runtime.md`.
