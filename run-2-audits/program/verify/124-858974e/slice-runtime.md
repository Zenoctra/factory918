# Slice: live runtime floor (no model calls)
(a) Fixtures: `reviewer.py check` at the SHA; then for one surviving and one regenerated round, regenerate the brief
    the way the owner says (the head's own `review-brief.sh` with the gh stub) and diff it byte for byte against the
    frozen brief. Say whether a fresh clone can rebuild every regenerated brief (the keep refs are how).
(b) Labels: pick three of the 13 hard findings in `labels` and confirm each against the reviewed code at its round's
    head (the bug is really there, and a correct reviewer could see it from the brief).
(c) Collect and table: rebuild the M0 results table from the committed receipts with `reviewer.py collect`/`table`
    (find where receipts live; if they are not committed, say so, and whether the table is reproducible at all), and
    diff against the table in `docs/M0-findings.md`. A number that does not reproduce is an issue.
(d) Refusals: break the runner on purpose in a scratch copy (a report without `hard findings:`, a missing receipt, a
    wrong brief hash) and show each is refused as the contract says, quoting messages.
(e) Recommendation: does P103's pick follow from the table (per axis: recall on the hard labels, then cost)? Quote
    the rows it rests on. Say what "provisional until two missing runs" means and whether the table marks it.
Report: `/Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.scratch/program/verify/124-858974e/worker-runtime.md`.
