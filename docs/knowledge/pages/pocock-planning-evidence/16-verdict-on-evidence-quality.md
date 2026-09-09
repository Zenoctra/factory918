<!-- lines: 27 | source: pages/pocock-planning-evidence.md | part 16/17 | title: Pocock Planning Evidence (brief) — Verdict on evidence quality -->

## Contents (line numbers are for the Read tool's offset)
- L6: Verdict on evidence quality

## Verdict on evidence quality

**Demonstrated (measured, primary artifacts):**
- The pipeline produces real, dense, template-conforming specs and ticket sets, and those close via merged PRs within hours to a day, in Matt's repo (PRs #1585, #1576, #1293) and in third-party repos (gigloop #539, noupling 0.9.0). Bot-authored implementation from a spec exists (#1293).
- Adoption is large: tens of thousands of template specs, ten thousand wayfinder maps, and hundreds of thousands of `ready-for-agent` issues on public GitHub, with high closure rates.
- Matt dogfoods it heavily: 110 specs, 8 maps, 1,272 issues in one repo since January.
- CONTEXT.md bloats: 5x in five months in Matt's own repo, 137 KB in a third-party repo, with Matt's own open issue saying so and a third-party drift report.
- Specific, counted failure modes exist: 75% rework on a 26-ticket stack (#595), 1.5M tokens for 14 tickets (#826), 16→27 tickets with an orphaned invariant (#924), 59 map lines silently lost (#944).

**Only claimed (self-reported, no methodology):**
- Faster or better outcomes than without the skills (andrew.ooo "20-40%", HN one-liners, Matt's "far better code" in the README).
- That the shared vocabulary reduces tokens or improves navigation (README claim; HN pushback; no measurement either way).
- That wayfinder's decision maps prevent the "27 tickets, 13 made sense" waterfall trap; the docs themselves say the trap is "repeatedly-reported".

**Absent:**
- Any controlled comparison against no-framework, or against BMAD/Spec-Kit.
- Any regression or defect-rate data after shipping.
- Any written BMAD → Pocock migration with outcomes.
- Transcripts of the wayfinder live demo and the March feature-build video (paywalled/unavailable); the Sandcastle map that demo produced is still unresolved.
- Comment threads on the most relevant issues (#341's 16 comments), which the fetch could not render.

**Reading for Manuel:** the artifacts are actionable in the concrete sense that agents build them and merge them the same day, including on Matt's own production tooling, and the tickets shown above are specific enough that an implementer can fail them. What the evidence does not support is the idea that the system removes the failure Manuel hit. It moves the summarisation to one hop and puts a human quiz in front of it, and the field reports say that hop still drops invariants and still writes unfalsifiable criteria unless a human reads them. Matt's own PRD stance ("We don't look at these") is in tension with his docs' advice to read the seams and out-of-scope sections; the honest synthesis is that the spec is not for reading, the ticket list and its acceptance criteria are.
