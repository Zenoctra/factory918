<!-- lines: 65 | source: pages/pocock-planning-evidence.md | part 9/17 | title: Pocock Planning Evidence (brief) — Sample: a real ticket set (course-video-manager #1580, #1582, #1583, #1584) -->

## Contents (line numbers are for the Read tool's offset)
- L6: Sample: a real ticket set (course-video-manager #1580, #1582, #1583, #1584)

## Sample: a real ticket set (course-video-manager #1580, #1582, #1583, #1584)

The four tickets `to-tickets` cut from spec #1579. All by mattpocock, 2026-08-23, `ready-for-agent`, all closed by PR #1585.

**#1580 "Overlay foundation: kind discriminator + overlap rejection"** (condensed by the fetch tool): Parent #1579. What to build: add a `kind` discriminator to Overlay (`definitionCard`/`bulletPanel`), backward compatible, and "reject creating or updating any Overlay whose time window overlaps another Overlay on the same Video." Seven acceptance criteria including "Export Hash includes `kind` for cache invalidation" and "Tests extend `cli-overlay-writes.test.ts`". **Blocked by: None.**

**#1582 "bulletPanel authoring & rendering"** (verbatim):

> ## What to build
> `cvm overlay add --kind bulletPanel --bullets-json <path|->` creates a validated, persisted Overlay — a title plus up to 4 bullets (icon, text, `revealAt`) — and the transparent overlay layer actually renders it: the title, then each bullet's icon and text easing in at its own author-set time, with the whole panel exiting together, never staggered. `revealAt` is authored as seconds relative to the Overlay's own start, so an authoring agent can derive it directly from a transcript word-start time minus the Overlay's own `at`. Includes exposing the vendored Lucide icon-node table to the overlay-renderer package as groundwork, since only this ticket needs it.
>
> ## Acceptance criteria
> - [ ] `overlay add --kind bulletPanel --bullets-json <path|->` accepts a title and up to 4 bullets, each with `icon`, `text`, and `revealAt`
> - [ ] A bullet with a missing icon, or an icon name that isn't a real Lucide icon, is rejected
> - [ ] Bullets are rejected unless submitted in ascending `revealAt` order matching their display order
> - [ ] A bullet's `revealAt` is rejected if negative, or if it would leave its own enter animation clipped by the Overlay's exit
> - [ ] More than 4 bullets is rejected
> - [ ] The overlay-renderer package can render any Lucide icon name as an inline SVG glyph, reusing the vendored icon-node table (no `lucide-react` dependency added to that package)
> - [ ] A rendered bulletPanel overlay shows the title, then each bullet's icon+text easing in at its own authored `revealAt`, using the shared ~0.35s easing curve already used by the Subtitle overlay content
> - [ ] The whole panel (title + bullets) exits together on the Overlay's own exit, never staggered per-bullet
> - [ ] With `disableEnterAnimation` set, bullets pop in fully-formed at their own `revealAt` instead of easing in
> - [ ] Tests extend `cli-overlay-writes.test.ts` (validation) and the overlay-renderer package's props test (bulletPanel content shape parsing/defaulting)
>
> ## Blocked by
> Overlay foundation: kind discriminator + overlap rejection #1580 (needs the `kind` discriminator to exist)

**#1583 "Camera Transform: kind-derived pan/zoom + Clip-Zoom conflict guard"** (verbatim, criteria abridged):

> ## What to build
> The export pipeline pans and zooms the camera from centered to a right-shifted framing, and back, for the duration of any Overlay whose `kind` carries a Transform — today, just `bulletPanel` — via an extensible `kind -> defaultTransform` lookup rather than anything authored per-instance. Also: reject creating a `bulletPanel` Overlay whose time window lands on a Clip that already has Clip Zoom enabled, rather than compounding the two crops.
>
> ## Acceptance criteria
> - [ ] A `kind -> defaultTransform` lookup returns `null` for `definitionCard` and a fixed start/end keyframe pair for `bulletPanel`
> - [ ] The crop animates centered -> right-shifted over ~0.35s using the existing Subtitle easing curve (`Easing.bezier(0.25, 0.1, 0.25, 1)`), and reverses symmetrically on exit
> - [ ] A Definition Card Overlay emits no crop node
> - [ ] Creating a `bulletPanel` Overlay whose time window lands on a Clip with Clip Zoom enabled (`zoomType != 'none'`) is rejected
> - [ ] Tests extend `overlay-compositing.test.ts` (pure-function filtergraph assertions, no ffmpeg execution) and the CLI write-path seam for the Clip-Zoom rejection
> [two further criteria omitted]
>
> ## Blocked by
> Overlay foundation: kind discriminator + overlap rejection #1580 (needs the `kind` discriminator to exist)

**#1584 "End-to-end publish integration + Export Hash sensitivity"** (verbatim):

> ## What to build
> Prove the bulletPanel feature works as a whole, not just as isolated pieces: publishing a video containing a `bulletPanel` Overlay produces the camera pan/zoom and the rendered panel content together, correctly synced, in one export pass. Editing a bulletPanel Overlay's content invalidates any cached export, the same way editing Definition Card content already does.
>
> ## Acceptance criteria
> - [ ] Publishing a video containing a `bulletPanel` Overlay produces both the camera pan/zoom (from #1583) and the rendered panel content (from #1582) in one export pass, correctly synced to the Overlay's timing
> - [ ] Tests extend `course-publish-service-overlay-composite.test.ts` with bulletPanel cases covering render-cache addressing and Export Hash sensitivity
> - [ ] A full sample export (manual or automated smoke) shows the expected camera move and panel content together
> [one criterion omitted]
>
> ## Blocked by
> - bulletPanel authoring & rendering #1582 (needs bulletPanel authoring & rendering)
> - Camera Transform: kind-derived pan/zoom + Clip-Zoom conflict guard #1583 (needs the camera Transform)

**Graph:** 1580 → {1582, 1583} → 1584. A diamond; 1582 and 1583 are parallelisable. **Implemented?** All four closed by the same 12-commit PR the same afternoon **[measured]**. The "Blocked by" edges were written as body text with issue links, not as GitHub native dependencies (consistent with the docs' admission in issue #513 that the skill falls back to body text). Note that #1584 is not a vertical slice; it is an integration/proof ticket, which the template allows in practice. The tickets also name test files, against the "no file paths" rule.

**A second, third-party ticket set** (pererikbergman/noupling, 2026-09-04): epic #338 "Epic: same Issues in every report (0.9.0)" with 13 sub-issues #339–#351, each labelled `ready-for-agent` plus `effort: small|medium|large`. The epic's dependency list: "#344 blocked by #342; #345 blocked by #344; #346 blocked by #342; #347 blocked by #342; #350 blocked by #343–#349; #351 blocked by #350, #343". #344 is titled "... (expand)" and #350 "... (contract)", i.e. the wide-refactor expand/contract sequencing from the skill in the wild. Within 24 hours, 8 of 13 were closed with merged PRs (#352, #353 ...); 5 remain open **[measured]**. The epic body is a custom format ("Decisions" list, no user stories), so this user has adapted the template.
