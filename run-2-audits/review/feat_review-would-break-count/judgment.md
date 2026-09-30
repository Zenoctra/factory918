## Act on

1. [S1] **The two new gh calls hide their failure.** A token or network error reads as "no PR", the round gate fails open and the author's comments vanish silently; print gh's error and fall back to round 1 only on "no pull requests found". fixed: dd37c0e
2. [S2] **The CRLF fixture uses a GNU-only sed form.** Build it with printf or awk so the assertion proves CRLF handling on macOS too. fixed: dd37c0e
3. [S5] **The cites anchor drops an item with a trailing space.** Strip trailing spaces and tabs before matching, as the heading parse does; rides with [S1] in the same script. fixed: dd37c0e
4. [P1] **A re-sorted Ask item fails the judgment numbering check.** Step 5 says to renumber after moving an item, and a test re-sorts an item across headings and reruns the comment. fixed: dd37c0e
5. [P2] **A rebuilt same-round comment counts as a round.** Derive the round from the highest `round: N of 3` line among the earlier review comments, not from how many comments carry the count line; a rebuilt comment repeats its round number. fixed: dd37c0e
6. [P3] **Settled items survive only one round.** Carry the cited Noted and Dismissed items from every earlier review comment, verbatim, deduplicated by exact line, so a round-one decision still reaches round three. fixed: dd37c0e
7. [P5] **The gh-derived fourth-round refusal is untested.** The fake gh serves three earlier comments; rides with [P2], whose change it tests. fixed: dd37c0e

8. [S3] **Any comment carrying the count line is read as a round and pasted into the briefs.** Strangers' text from GitHub would then reach the reviewers under "do not raise these again". The fix is to read only comments posted by the PR's author, which is the account the orchestrator posts under; a security-class change to what the briefs trust, Manuel answered 2026-09-18: read only the PR author's account, sign the comment by the model on the harness and by the approver. fixed: 82dc11e
## Ask

## Consider

9. [P7] **A fix for #79 rides on this PR.** Whether those five items stay here or move to #77 is the open choice on the ticket; either way they are one commit that can be cherry-picked.

## Noted

10. [S4] **The fence parser lives in both scripts.** Held identical by a test; a sourced fragment would be a third file for two users.
11. [P4] **A review dir from before this change has no round file.** Prints round 1; such dirs are gone once this merges.

## Dismissed

12. [P6] **Every comment by the ticket's author becomes spec, including ones the agent posted under that login.** That is P21 as decided: a comment the agent writes on a ticket at Manuel's direction is his decision (P10), which is exactly the #74 case this criterion exists for.
