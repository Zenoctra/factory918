# Slice: live runtime floor
With a fake `gh` (read `tests/spec-review/fake-gh.sh` and the two test harnesses first) and a scratch repository with
commits to review, exercise at the SHA:
(a) Rounds one and two: the brief and `review-brief.sh` stdout are byte for byte what 01a1e5f prints for the same
    history (run both SHAs, diff).
(b) Round two's comment with hard items only inside the fix lines (quoted hunk lines all fix lines): round three is
    fix-only, the fixed point is round two's reviewed commit, `## The fix under review` present; quote the `round:` line.
(c) Round two with a hard item in unchanged code: round three is a whole-diff round. Round two with a Spec hard item
    (quotes its ticket line): whole-diff. Round two with no hard items: fix-only.
(d) The inside rule's edges: a quoted line whose text equals a fix line but sits elsewhere (the owner's accepted
    false-inside), a hunk mixing fix and non-fix `+` lines, context-only quotes, lines under four characters. Say what
    each does and whether the behavior matches P106 as written.
(e) A wrong fixed point for a fix-only round three: refused with #102's message naming the expected commit.
(f) Rounds four and five after a Would-break fix still behave as #102 made them (compare with 01a1e5f).
(g) `review-comment.sh`: `next round owed: round <N> reviews the fixes marked here` printed at round one and round two
    exactly when an item is marked `fixed:`; absent otherwise; babysit's merge-ready sentence in both copies reads it.
(h) Restart after a design hole (#99): the rounds restart and round three logic starts over; quote.
Report: `/Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.scratch/program/verify/125-caecbc4/worker-runtime.md`.
