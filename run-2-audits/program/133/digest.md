# #133 digest

Required reading
- Ticket #133 (body; no comments). Rule: round three is fix-only exactly when round two's two reports hold no hard item (Would break / Fails open, either axis, Spec only with a spec). Delete the inside rule: outside(), fix-lines, fix-ranges, quoted-hunk and location matching, and the `reviewed:` RV line (nothing else reads it: reading-pack.sh does not; `<dir>/reviewed` and `<dir>/files` stay, they serve the WB/FO lines and the brief).
- #106 body: `## Testing decisions` (tables A and B, contract, tests) and its 2026-09-23 amendments. Saved at .scratch/program/133/issue106-body.md.
- P106, P20 (DECISIONS.md). Verifier reports .scratch/program/verify/125-0edf8c8/comment.md.
- Playbooks: ticket.md, feature.md, opening-a-pr.md (worktree copies, #120's rules).
- Parent: PR #129 (feat/trail-clock, c183a36). Stack: #120 #121 #124 #125 #126 #129.

Facts
- A lane's completion notification reaches the root, never me: poll the exact absolute result path inside my turn.
- `Closes #N` links only on a PR based on the default branch; the root handles #100's workaround. Do not retarget.
- Actions creates no pull_request run for a PR that conflicts with its base.
- `gh issue edit --body-file` replaces the body: read it first, write it back whole.
- Trail rows only through show-me-your-work scripts/log.sh.
