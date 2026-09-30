## Act on

1. [S1] **The PR list cap is never reported.** Real fails-open by the definition; noted last round and uncitable, so rightly raised again. Refused under the contract's exit 2 when a 101st open PR exists; no cell changes. fixed: d1e5186
2. [S2] **`|| true` covered the whole token pipeline.** Real breach; the `## Diff` filter now runs on its own so an awk failure reaches the trap, and `|| true` covers only grep's no-match. fixed: 2ed2d18
3. [P1] **Step 8 had no exit-2 branch.** Real fails-open in the playbook text: a failed record run read as no overlap. Step 8 now says exit 2 stops and reports and the PR waits; rows 10E and 11E already said so, no cell changes. fixed: 1df787a

## Ask

## Consider

## Noted

4. [S3] **`git diff --name-only` C-quotes a non-ASCII path.** Valid; a path outside ASCII would be missed by the record run. No Act on fix touches that line and the round is the last; a one-flag hardening for a later ticket if a project has such paths.
5. [S4] **The `prs` walk is written three times.** Valid; no behavior, no Act on fix touches it.

## Dismissed
