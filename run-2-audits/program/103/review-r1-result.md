# PR #124 (ticket #103), review round 1

- Review dir: /Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.claude/worktrees/agent-a91d9f1cee64cb2f2/.scratch/review/origin_main (fixed point origin/main)
- Round line: `round: 1 of 3`
- `act-on items: 3` (Act on S1 and S3, plus Ask P1; P2 is marked `hole: criterion 6`, so it is left out of the count and the comment carries the line `restart`)
- review-comment.sh: exit 0. The first run exited 1 because Spec item 3 had `spec: table 20/run, Claude model`, which the grammar rejects. The Spec reviewer rewrote it to `spec: table 20/collect`, and the rerun exited 0.
- Reviewers: both ran as tier-lower. Standards: 0 would break, 1 fails open, 4 items in total. Spec: 2 would break, 1 fails open, 3 items in total.

## Act on
1. [S1] The no-count-line and no-hard-headings gates in reviewer.py also read fenced text. A report that only quotes the count line or a hard heading inside a fence is scored as a clean run with zero findings instead of a context failure (table row 17).
2. [S3] The Codex run counts in the M0-findings section do not add up: 17 runs plus 51 dropouts is 68, but the ledger line says 72 runs were started.
3. [P2] The ticket's Design has no row for the usage-limit dropout or the settle rule, and its Contract defines the noise band differently from the code. The fix changes the ticket, not the code: `hole: criterion 6`, which sends the work back to architect with a `restart`.

## Ask
4. [P1] Six reviewed heads exist only in local refs/keep/103/* refs. On another clone the refusal in row 5 names refs that clone does not have. Keeping the heads means pushing those refs or a bundle to origin, and that is the human's call.

## Also judged
Consider: S2 (refusals.sh is outside the ShellCheck glob) and P3 (a round file missing its provenance keys still loads). Noted: S4 (the Provisional row is numbered P103). Dismissed: none.

comment-body.md: /Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.claude/worktrees/agent-a91d9f1cee64cb2f2/.scratch/review/origin_main/comment-body.md (not posted)
