<!-- lines: 50 | source: pages/pocock-planning-evidence.md | part 4/17 | title: Pocock Planning Evidence (brief) — Sample 1: Matt's own spec, closed same day via PR (course-video-manager #1579) -->

## Contents (line numbers are for the Read tool's offset)
- L6: Sample 1: Matt's own spec, closed same day via PR (course-video-manager #1579)

## Sample 1: Matt's own spec, closed same day via PR (course-video-manager #1579)

**URL:** https://github.com/mattpocock/course-video-manager/issues/1579. Author mattpocock, created 2026-08-23 12:54Z, closed 15:04Z, label `ready-for-agent` ("PRD ready for an implementing agent to pick up"), linked PR #1585. 26 user stories, 8+ implementation decisions.

Verbatim:

> ## Problem Statement
> Matt records his talking-head videos with his face centered in frame. He wants a new kind of overlay that shows supporting bullet-point content beside his face during a video — but there isn't room for it in the current centered framing, and no existing Overlay can move the camera at all.
>
> ## Solution
> Introduce `bulletPanel`, a new Overlay content-kind: a titled list of up to four Lucide-icon bullets that appears on the left of frame while, simultaneously, the underlying camera footage animates from its normal centered framing to a right-shifted, slightly zoomed framing that clears space for the panel — then animates back to centered when the Overlay ends. The camera move (a Transform) is never authored directly by whoever creates the Overlay; it's entirely derived from the Overlay's `kind`, so creating a `bulletPanel` Overlay is all it takes to get the panel and the camera move together, correctly synced, every time.
>
> ## User Stories
> 1. As an authoring agent, I want to create an Overlay with `kind: bulletPanel`, so that I can attach a bulleted side panel to a moment in a video without a new top-level command.
> 2. As an authoring agent, I want to pass bullet content as a JSON file or via stdin (`--bullets-json <path|->`), so that I can hand off structured, multi-field bullet data without fragile inline flag escaping.
> 3. As an authoring agent, I want each bullet to require an icon, text, and a reveal time, so that every bullet is validated as complete before authoring can succeed.
> 4. As an authoring agent, I want to choose any icon from the full Lucide set, so that I'm not constrained to a narrow curated list when picking the most fitting icon for a bullet's content.
> 5. As an authoring agent, I want an invalid icon name to be rejected at write time, so that a typo doesn't surface only when the video is rendered.
> 6. As an authoring agent, I want to author each bullet's `revealAt` as seconds relative to the Overlay's own start, so that I can compute it directly from `wordStartTime - overlayAt`, the same transcript data I already used to place the Overlay itself.
> 7. As an authoring agent, I want bullets rejected if they aren't submitted in ascending `revealAt` order matching their display order, so that a list can never visually reveal out of the order it's displayed in.
> 8. As an authoring agent, I want a bullet's `revealAt` rejected if it's negative or would leave its own enter animation clipped by the Overlay's exit, so that timing mistakes are caught before render rather than discovered as a visual glitch.
> 9. As an authoring agent, I want at most 4 bullets per panel, so the panel never overflows its allotted width at a readable size.
> 10. As a viewer, I want the presenter's face to pan and zoom smoothly from centered to right-shifted framing as a bulletPanel Overlay begins, so the transition feels like a deliberate camera move rather than a jump cut.
> [11–26 continue: camera returns on exit, Transform derived from `kind`, animation-disable flags, per-bullet reveal, overlap rejection across kinds, Clip Zoom conflict, left-side-only panel, cache invalidation, additive `kind` migration, fail-loud CLI validation, vector icons, reuse of vendored Lucide table.]
>
> ## Implementation Decisions
> - **Overlay schema**: add a `kind` discriminator (`definitionCard` / `bulletPanel`; existing rows have none today and must be treated as `definitionCard` by default — additive migration, not breaking). `bulletPanel` content: `title: string`, `bullets: Array<{ icon: string; text: string; revealAt: number }>`, capped at 4 bullets.
> - **`db-overlay-operations.server.ts`**: extend the create/update path and the Export Hash derivation to persist and hash the new kind, content, and animation-toggle fields, the same way Definition Card's title/description already participate in the hash.
> - **New `kind → defaultTransform` lookup**, sibling to Clip Zoom's shared-rect module: returns `null` for kinds without a Transform (e.g. Definition Card) and a fixed start/end keyframe pair for `bulletPanel`. Start = centered (scale 1.0, origin 0.5/0.5, matching normal recording framing). End ≈ scale 1.3, origin (0.62, 0.4) — an initial ballpark, expected to be visually tuned against a real render rather than treated as final.
> - **`overlay-compositing.ts`'s filtergraph builder**: for any placed Overlay whose kind resolves to a non-null Transform, emit a time-varying `crop` node ahead of the existing `overlay` graphic-compositing chain ... Enter/exit motion is ~0.35s each way when enabled, reusing the existing `Easing.bezier(0.25, 0.1, 0.25, 1)` curve already used by the Subtitle overlay content — no new easing curve introduced.
>
> ## Testing Decisions (condensed)
> CLI/DB write path: extend `cli-overlay-writes.test.ts` with bulletPanel creation, icon rejection, ordering rejection, bounds rejection, overlap rejection, Clip Zoom conflict rejection. Filtergraph builder: extend `overlay-compositing.test.ts`. Props schema: extend `overlay-renderer/tests/props.test.ts`. Deliberately excluded: kind lookup unit tests, Remotion component visual snapshots, editor live-preview tests.
>
> ## Out of Scope (condensed)
> Editor live preview of animated Transform; general keyframe-authoring API; configurable panel side; per-bullet animation overrides; composing Clip Zoom with Transform; curating Lucide icons; Overlay Template mechanism; removing Clip Zoom.
>
> ## Further Notes
> The domain model already documents "at most one Overlay visible at given moment" — this work enforces that invariant. Transform values are intentionally conservative, subject to visual tuning. This is the first overlay kind requiring a `kind` discriminator; migration must be additive.

(Problem Statement, Solution, stories 1–10 and the decision bullets are verbatim; the rest is the fetch tool's condensed rendering.)

**Implemented?** Yes **[measured]**. PR #1585 "bulletPanel Overlay: bulleted side panel with a kind-derived camera Transform", author mattpocock, 12 commits, merged 2026-08-23, description: "This pull request implements specification #1579 across five related tickets: Closes #1579 ... Closes #1580 ... Closes #1582 ... Closes #1583 ... Closes #1584", co-authored by "Claude Opus 5 (1M context)", with a final "Review fixes" commit "Addresses code review findings with timing specifications and validation improvements." Spec to merged PR in about two hours.

**Observation [inferred]:** the spec violates its own template rule twice. It names files (`db-overlay-operations.server.ts`, `overlay-compositing.ts`, three test files) and inlines constants, despite "Do NOT include specific file paths or code snippets." Matt's own output treats that rule as advisory. The stories are also written from the point of view of "an authoring agent", i.e. the customer of this CLI is another agent.
