# Slice: live runtime floor, and try to break the check
At the SHA, with scratch trails and scratch transcript files shaped like the real ones (read the script and test first):
(a) Real trails: run `check-trail.sh` over this run's trails under
    `/Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.scratch/program/<N>/decisions.tsv` for
    N in 103 105 106 107 110 111, with the transcripts it needs (find how it locates them; the session's subagent
    transcripts are under `~/.claude/projects/-Users-manuel-Desktop-Work-Under-The-Sun-Collective-Core-918-factory918/`).
    Report each result; say whether each refusal is a true one (a typed or invented time) or a false one.
(b) Adversarial: rows with equal timestamps; a row one second before the run's first transcript record; timezone
    suffixes other than `Z`; fractional seconds; a CRLF file; a header-only file; a row with a tab inside a field; a
    missing transcript; transcripts with records lacking `timestamp`; a trail that spans two sessions (resume). For
    each: output, exit code, and whether it misleads.
(c) `log.sh`: it stamps from `date -u` and never accepts a typed time; what happens if a caller passes one.
(d) The trail review's instructions at the SHA: quote where it runs the check first and how a refusal is reported
    (Attention, not a merge-ready block). Would an agent following them do the right thing?
Report: `/Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.scratch/program/verify/129-c183a36/worker-runtime.md`.
