## What to build

Remove the wording in our own review briefs that leads the witness. The audit of 2026-09-23 (`.scratch/program/leading-prompts-audit/report.md` in the main checkout, sections 1 to 3) found it in the two briefs `review-brief.sh` writes and in the text our patch adds to `spec-review/SKILL.md`. Upstream pstack's milder lines stay untouched.

> Manuel (2026-09-23): "In terms of your leading witness finds after review, the pStack ones are fine. Leave them there. OURS though are awful and need fixed/removed. My quote is fine, dont remove it, its still what I want there, but if you want you can add that line after that you talked about "an edge case that proceeds silently fails open, so file it." The other 4 findings though absolutely need fixed"

> Manuel (2026-09-23), on telling later rounds what earlier rounds found: "nope. we arent doing you r review info increase suggestion. We are keeping them equally blind. I HATE leading witness prompts."

> Manuel (2026-09-23): "400 word cap sounds like trying to save money on output tokens when thinking tokens make up the vast majority of token costs, not output. [...] Zero items is expected is absolutely HORRENDOUS. [...] You are guiding the witness."

Files: `template/.agents/skills/spec-review/scripts/review-brief.sh`, `tests/spec-review/review-brief.sh`, `template/.agents/skills/spec-review/SKILL.md` through `patches/mattpocock/spec-review.SKILL.md.patch`, `template/docs/agents/review-ladder.md` and its copy `docs/agents/review-ladder.md`, `docs/knowledge/core/DECISIONS.md` (P18).

The lines, with the audit's file:line at a9ebdac:
1. "Zero items is the expected result for a clean change." (`review-brief.sh:402`, `SKILL.md:79`, P18, `review-ladder.md:6`): delete it. Say nothing about how many items to expect.
2. The read and run ban, "Read nothing beyond this brief unless a finding needs the code around a hunk, and then read that one function or section, not the file. Run nothing." (`review-brief.sh:425`, `:513`, `:549`; `SKILL.md:75`, `:97`, `:108`): replace it. The reviewer may open any file and run read-only commands (grep, the test suite) that a suspicion needs.
3. The reading pack's tail, "…open the repository only for what the pack does not carry, and then read that one function or section, not the file." (`review-brief.sh:423`, `SKILL.md:86`): drop the cap on what is opened.
4. "Under 400 words." (`review-brief.sh:513`, `:549`; `SKILL.md:97`, `:108`): delete the cap on the report and on the number of items.
5. The judge heuristics our lane paraphrased into spec-review step 5, "a report that is all nits means the code is probably fine" and "more than five Act on items means you are not filtering" (`SKILL.md:116`): delete both. The judge sorts each item on its merits.

Keep: Manuel's quote "An edge case outside the intended path being unsupported is not a flag.", word for word. After the five quotes, add one line: "An edge case that proceeds silently fails open: file it under `## Fails open`." Keep later rounds as blind as today: add nothing that tells a reviewer what earlier rounds found, fixed or rated.

## Acceptance criteria

- [ ] Neither brief, `spec-review/SKILL.md`, P18 nor `review-ladder.md` states an expected number of findings, a word or item cap, or a limit on what the reviewer may read or run read-only. Each of the five lines above is gone or replaced, and `tests/spec-review/no-stale-wording.sh` refuses each removed phrase.
- [ ] Manuel's quote is present word for word, followed by the fails-open line.
- [ ] A round-two or round-three brief carries nothing about earlier rounds' findings, fixes or ratings beyond what it carries today (`## Settled in earlier rounds` and, in a fix-only round, `## The fix under review`).
- [ ] P18 is amended with a dated line saying what was removed and why, quoting Manuel.
- [ ] `tests/spec-review/review-brief.sh` asserts the new text in both briefs.

## Blocked by

The PR for #108, which edits `review-brief.sh` at the same time. This one stacks on it.

