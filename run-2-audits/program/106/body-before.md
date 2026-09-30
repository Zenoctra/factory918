## What to build

Split from #104 (2026-09-22) at Manuel's request.

> agent: "Every round is a fresh pair reading from zero. Round one found eight of the ten findings that led to fixes. Rounds two and three found two, both on #88, both in the fix itself. #93 already encodes the answer for rounds four and five: a fix-only round reads only the fix commit. Extend that to round two. A fix-only brief is two minutes of reading, not eight. Saves 10 to 15 minutes per ticket and loses nothing the data shows."

> agent: "Round one stays a full two-axis read"

> user: "I agree with your choices here."

> user: "You mentioned doing only the limited scope reviewers on diff instead of whole specs after the first pass. I dont like that, but only a bit. Instead, wait until a review came back only with hard findings on fixes and then every review after that can be diff only from then on. That way at least one pass goes with zero new happy path hard bugs found before we commit ourself to diff only reviews."

Facts the lane starts from. PR #102 (ticket #93) made rounds four and five fix-only: `review-brief.sh` takes the commit the previous round reviewed as the fixed point, writes only the fix's commits and diff into both briefs, and records the reviewed commit. This ticket applies the same mechanism to every round after the first that follows a fix, so round two and round three review the fix, not the whole diff. The round after a Would-break fix, the three-round cap, the restart route (#90) and the Spec axis running every round are unchanged. The scripts are `template/.agents/skills/spec-review/scripts/review-brief.sh` and `review-comment.sh`, the tests `tests/spec-review/review-brief.sh` and `review-comment.sh`. This ticket shares those files with #107 and #108: the three run one at a time, or as a stack under a go.

## Acceptance criteria

- [ ] Rounds one and two always review the whole diff from the ticket's fixed point, byte for byte what the script prints today.
- [ ] From round three on, a round is fix-only when the previous round reported no hard finding (Would-break or Fails-open, either axis) outside the lines of the fix commits that round reviewed; the script decides this from the previous round's comment and the fix commits' changed ranges, never from a human's word, and once a round is fix-only every later round is. A previous round with a hard finding in unchanged code makes the next round a whole-diff round again.
- [ ] A fix-only round uses the commit the previous round reviewed as the fixed point and writes only the fix's commits and diff into both briefs with the `## The fix under review` section PR #102 introduced; a fix-only fixed point that is not that commit is refused with the message #102 introduced, naming the expected commit; the round after a Would-break fix and the three-round cap are unchanged.
- [ ] A round-one or round-two judgment that marks any item `fixed:` is not review-ready: `review-comment.sh` prints the line that says the next round is owed, and babysit's merge-ready condition reads it (PR #102's round one, with three marked fixes, read as ready; the owner caught it by hand).
- [ ] The scenario table on this ticket has one row per comment history (no comments; round one with fixes; round one without; round two with a hard finding in unchanged code; round two with hard findings only in the fix; round two with none; a restart; rounds four and five) and `tests/spec-review/review-brief.sh` and `review-comment.sh` have one assertion per cell, written before the script changes, in the commit order.
- [ ] Ticket #93's table cells 13B, 5C and 5D gain direct assertions in the same test files.
- [ ] `spec-review/SKILL.md` step 1 (through its patch) says which rounds are fix-only and why; `docs/knowledge/core/DECISIONS.md` P20 gains a dated amendment and its title no longer reads "Three review rounds at most".

## Blocked by

None.


