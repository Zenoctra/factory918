## What to build

Simplify the fix-only round three that PR #125 (ticket #106) added. Round three reviews only round two's fixes exactly when round two's reports hold no hard item (Would-break or Fails-open, either axis) at all. The "inside the fix" rule and what exists only to serve it go: `fix-lines`, `fix-ranges`, the quoted-hunk location matching, and the `reviewed:` line if nothing else reads it.

> agent (the #106 owner, report, 2026-09-23): "Fix-only could require that round two reports no hard item at all. That would drop the inside rule, `fix-lines`, `fix-ranges` and the `reviewed:` line. It gives the same verdict on every real round two measured."

> agent (the root, 2026-09-23): "On every real round two measured so far, the simpler rule gives the same answer. Being simpler, it can't misjudge where a finding sits, so I'd lean toward it."

> Manuel (2026-09-23): "If you have a lean, then go for it."

Why: the first inside rule failed open (a plain quote of untouched code sharing one line with the fix made round three fix-only; the verifier reproduced it). The redesign closed that hole but kept one contrived false-inside and a lot of matching code. Manuel's bar in #106 is "at least one pass goes with zero new happy path hard bugs found before we commit ourself to diff only reviews". A round two with zero hard items meets that bar directly.

Files: `template/.agents/skills/spec-review/scripts/review-brief.sh`, `template/.agents/skills/spec-review/scripts/review-comment.sh`, `tests/spec-review/review-brief.sh`, `tests/spec-review/review-comment.sh`, `template/.agents/skills/spec-review/SKILL.md` (via `patches/mattpocock/spec-review.SKILL.md.patch`), `template/.agents/skills/babysit/SKILL.md` and `template/.agents/skills/poteto-mode/playbooks/babysit.md` (via their patches), `docs/knowledge/core/DECISIONS.md`.

## Acceptance criteria

- [ ] Round three is fix-only when, and only when, round two's two reports hold no hard item. Rounds one and two, rounds four and five, the three-round cap and the restart route behave as they do at PR #125's head.
- [ ] The inside rule's code, its state files and its tests are deleted. `review-brief.sh` and `review-comment.sh` are shorter than at #126's head, and no test asserts a location match.
- [ ] #106's table cells that the inside rule decided are amended on #106 with a dated line, and each surviving cell has one assertion.
- [ ] P106 is amended, or superseded by P<N>, to say that the inside rule was removed and why.
- [ ] `spec-review/SKILL.md` (through its patch) and babysit say the simpler rule.

## Blocked by

None. This stacks on the run-2 chain (#120, #121, #124, #125, #126, #129).


