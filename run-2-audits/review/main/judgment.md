## Act on

1. [S1] **Garbled sentence in the skill an agent reads.** The sentence that introduces the five quotes in step 4's Report bullet has no subject; fixed on this PR in the skill and its patch. fixed: e5df74c

## Ask

## Consider

## Noted

2. [S2] **Duplicated Code: the definition sentence lives in four places.** The CI fixture grep is the applied-project assertion the ticket asked for; the literal can move to a shared file when the next rename happens, not here.
3. [S4] **Mysterious Name: `line` holds two unrelated values in `report()`.** Valid; no Act on fix touches `review-comment.sh` this round.
4. [S5] **P23 is out of order in the Provisional table.** Valid; no Act on fix touches `DECISIONS.md` this round, so it rides with the next edit of that table.

## Dismissed

5. [S3] **Duplicated Code: `suite factory` adds no coverage in `review-comment.sh`'s test.** Criterion 5 of #81 names both test scripts and requires each to run its assertions in both layouts; the second pass is the criterion, not duplication.
