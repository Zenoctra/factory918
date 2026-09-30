## Act on

1. [S1] **A reason that says "hole:" is read as a field.** Real, and the fix defines what text is a `hole:` field, a term table B's cells use without defining it (the same input is column A or column E depending on that meaning): a design hole, not a fix on this PR. hole: table 1/A
2. [P1] **A review with no ticket cannot satisfy `spec:`.** Real: table B has no row for a report with no ticket, and all three reference forms name the ticket, so the fix adds a row or a form: a design hole. hole: criterion 2

## Ask

## Consider

3. [S2] **Three globals reused inside the hole loop.** Valid; the redesign's writer pass touches `holed()` and names them then.

## Noted

4. [S3] **The MANUAL's merge checklist reads the count alone.** Valid and outside the ticket's files; the owner's records commit adds the `restart` clause to `MANUAL.md`.

## Dismissed
