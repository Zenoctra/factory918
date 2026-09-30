# Digest for #108 (Ticket step 0)

Ticket: #108 "Refuse a review while a risk or writer flag has no disposition". Blocked by #105 (merged in a9ebdac).
Base: origin/main a9ebdac (overlap.sh 108: go autopilot-stack, base origin/main). Branch feat/risk-dispositions. PR targets main.

Required reading
- gh issue view 108 (criteria 1-5).
- The failures it cites: PR #96 (blast-radius lane named two risks at 10:33, rounds one and two re-found them), PR #99 (writer flag 9 was the design hole that restarted review).
- template/.agents/skills/poteto-mode/playbooks/ticket.md, feature.md, opening-a-pr.md.
- template/.agents/skills/spec-review/scripts/review-brief.sh (563 lines; grounding check at 307-348, ticket fetch at 386-395 after state is written at 356), SKILL.md step 1 and step 4 (risk sentence word for word), tests/spec-review/review-brief.sh.
- template/.agents/skills/blast-radius/SKILL.md "What to hand back" (vendored: needs a new patch in patches/series + SOURCES.md).
- DECISIONS P20, P21, P23, P106, P107 (their table cells stay at their outcomes).

Facts a run paid for
- Poll rule: a lane's completion notification reaches the root, never me. I poll the exact absolute path I told the lane to write (.scratch/program/108/<lane>/...), inside my turn, never ending the turn to wait.
- GitHub links Closes #N only on a PR whose base is main; name other tickets without a closing word.
- No pull_request run means the PR conflicts with its base.
- gh issue edit --body-file replaces the body: read it whole first, write it back whole.
- Stand a lane down with TaskStop, not a message.
- Architect: try adversarial inputs myself before the review rounds (#106's verifiers found a hole the rounds missed).
- Decision trail rows only through show-me-your-work scripts/log.sh.
- Worktree isolation: Write/Edit tools cannot write to the main checkout; use Bash for .scratch files; git commands must be plain and target my worktree.
