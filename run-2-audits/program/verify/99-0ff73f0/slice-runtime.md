# Slice: live runtime floor
Exercise the design-hole route live at the SHA, using `tests/spec-review/fake-gh.sh`'s technique for a fake `gh`
(read the harness first) and a scratch repository with a ticket-bearing branch:
(a) `review-brief.sh`: both briefs carry the `spec:` rule when a ticket is present; a run with no ticket writes no
    rule into the Standards brief. Quote the rule.
(b) `review-comment.sh`: a counted item with a well-formed `spec:` line is accepted; one with no `spec:` line, a
    malformed one, and one inside a fenced block are each refused with a message naming the three forms and exit 1,
    clearing nothing; with no Spec brief the same item is accepted and a `hole:` on it is refused.
(c) `hole:` on an Act-on item: `restart` printed between the summary and `round:`, the item left out of
    `act-on items:`; refusals for wrong placement, wrong form (value shown as written), a `spec:` mismatch.
(d) The round reset read from comments: a restart comment as the second and third author comment yields `restart:`
    and `round: 1 of 3` on the next `review-brief.sh`; three post-restart rounds still refuse a fourth with the
    unchanged message; a `restart` in prose, in a fence, trailing text, or without the `act-on items:` anchor resets
    nothing; `--round 4` refused unchanged.
(e) `cites: #N table`, `#N design`, `#N criterion` carry as settled in the next brief; malformed forms dropped and
    counted in the script's stderr line.
(f) The real PR: `gh pr view 99 --json comments` shows comment 5780539782 carrying `restart`; run `review-brief.sh`'s
    round computation against those comments (via `--previous FILE` if the script supports it, else a fake `gh`) and
    show `round: 2 of 3` (the post-restart series ended at round two).
(g) Quote the changed prose: Ticket playbook step 8's pointer and `### Design hole` section, `spec-review/SKILL.md`
    step 5's definition, `review-ladder.md` rung 1, the babysit playbook and skill paragraphs, `MANUAL.md`'s merge-read
    line; say whether an agent can follow each and whether the babysit merge-ready sentences are unchanged.
Report: `/Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.scratch/program/verify/99-0ff73f0/worker-runtime.md`.
