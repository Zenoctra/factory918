## Act on

## Ask

## Consider

1. [S1] **Duplicated Code / magic number.** A shared reader with `length(prefix) + 40` is tidier; the two readers are four lines each, a reworded line fails toward a whole-diff round, and #107 and #108 edit this script next, so the helper waits for a change that touches these lines.
2. [S2] **Duplicated Code.** A shared per-item walk would define the item boundary once; `stepless()` and `specs()` already repeat it, and folding three walkers into one is a refactor of its own, not #106's.

## Noted

## Dismissed
