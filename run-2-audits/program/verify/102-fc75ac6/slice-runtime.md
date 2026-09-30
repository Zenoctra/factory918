# Slice: live runtime floor
Exercise the fix-only rounds live at the SHA, with a fake `gh` (read `tests/spec-review/fake-gh.sh` and the two test
files' harnesses first) and a scratch repository with commits to review:
(a) A comment history of three rounds where round three's Act on carries a Would-break item marked `fixed: <sha>`:
    `review-brief.sh` allows round four with the fixed point equal to the commit round three reviewed; quote the
    `round:` line, the `## Commits` section (only the fix commit) and the `## The fix under review` section in both
    briefs.
(b) Round four's comment again with a Would-break fix: round five allowed the same way; round five's comment with a
    Would-break fix: a sixth refused, exit 1, no state written, message says to stop and report.
(c) Round three whose fixes are all Fails-open or Standards items, no Would-break: a fourth round refused as before
    this PR (the pre-existing message, byte for byte).
(d) `review-comment.sh`: the comment names the fix and the reviewed commit on the new line only when a Would-break
    item is marked fixed; a PR ending at round three with no such fix prints exactly what it printed at d8e382c
    (diff the outputs of the same fixtures at both SHAs).
(e) A wrong fixed point for a fix-only round (not the commit the previous round reviewed, or unresolvable): refused
    with a message naming the expected commit.
(f) Babysit: quote the merge-ready sentence in `template/.agents/skills/babysit/SKILL.md` and
    `template/.agents/skills/poteto-mode/playbooks/babysit.md`; show it reads `round: 5 of 5` as a wait and is
    unchanged for a PR ending at round three.
(g) Quote the changed prose (`spec-review/SKILL.md` steps 1 and 5, `ticket.md`'s `### Would-break fix` section,
    `review-ladder.md` rung 1) and say whether an agent can follow each; a contradiction with #99's design-hole
    section in the same playbook is an issue.
Report: `/Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.scratch/program/verify/102-fc75ac6/worker-runtime.md`.
