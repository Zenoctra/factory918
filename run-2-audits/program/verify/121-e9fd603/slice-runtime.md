# Slice: live runtime floor
Exercise the id rule live at the SHA, on scratch copies of the repository (never commit):
(a) Two PRs from one base each add a row: one as `P110`, one as `P111`; merge both into a scratch branch: check passes.
    Both as `P31` (the old max+1 habit): the check refuses, and its message names the duplicate.
(b) A same-ticket second row as `P110b`: passes. `P110a`, `P-110`, `P110B`, `p110`: each refused, with the message quoted.
(c) A rebase of a branch carrying `P110` onto a main that gained another row: the id does not change and the check
    still passes (no renumbering).
(d) A table reshaped so no row is read (e.g. the header changed): the check refuses rather than passing silently.
(e) The spec-review `cites:` grammar: a review comment citing `P110b` is accepted by `review-comment.sh` or
    `review-brief.sh` (whichever parses `cites:`; read the tests to find the harness), and `P17`, `P1`, `P16` still work.
    A malformed cite is refused as before (compare with the same fixture at 86d156a).
(f) `python3 tools/build_knowledge.py` after (a)'s passing merge leaves generated files consistent (rebuild, then check).
(g) Quote the new prose in `template/docs/agents/issue-tracker.md` (and its copy under `docs/agents/`, confirm
    byte-identical) and in `template/.agents/skills/poteto-mode/playbooks/ticket.md`; say whether an agent with no
    other context can take a correct id from them, including the next-free-letter case.
Report: `/Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.scratch/program/verify/121-e9fd603/worker-runtime.md`.
