# Evidence brief: Matt Pocock's planning system in practice

Compiled 2026-09-05. Method: read the skill templates in the local clone of `mattpocock/skills` (HEAD 6654f6b, 2026-08-24), then searched GitHub's issue search API, HN's Algolia API, and the web for real instances. Every outcome claim below is tagged **[measured]** (a number someone counted), **[self-reported]** (an anecdote), or **[inferred]** (my reading of an artifact). Where I could not find something, it says "not found".

Two constraints on evidence quality up front. GitHub's code-search API needs auth and grep.app's index is thin, so CONTEXT.md files were found through issue references rather than a code search. The GitHub HTML pages I fetched do not render comment threads server-side, so for issues with comments I could see the count but not the text.

## What the artifacts are supposed to look like (from the SKILL.md templates)

**Spec** (`skills/engineering/to-spec/SKILL.md`): one tracker issue, label `ready-for-agent`, sections `## Problem Statement`, `## Solution`, `## User Stories` ("A LONG, numbered list ... extremely extensive"), `## Implementation Decisions` ("Do NOT include specific file paths or code snippets. They may end up being outdated very quickly"), `## Testing Decisions`, `## Out of Scope`, `## Further Notes`. Written with "no interview, just synthesis of what you've already discussed." Step 2 sketches test seams and checks them with the user before writing.

**Tickets** (`to-tickets/SKILL.md`): "tracer-bullet vertical slices, each declaring the tickets that block it." Per-issue template: `## Parent`, `## What to build`, `## Acceptance criteria` (checkboxes), `## Blocked by`. "Each slice is sized to fit in a single fresh context window." Published blockers-first so edges can reference real ids; "Do NOT close or modify any parent issue." Local fallback: `.scratch/<feature>/issues/<NN>-<slug>.md`.

**CONTEXT.md** (`domain-modeling/CONTEXT-FORMAT.md`): a glossary. `**Term**:` one or two sentences, `_Avoid_:` synonyms. "Only include terms specific to this project's context ... Keep definitions tight. One or two sentences max. Define what it IS, not what it does."

**Wayfinder map** (`wayfinder/SKILL.md`): one issue labelled `wayfinder:map` with `## Destination`, `## Notes`, `## Decisions so far` ("the index: one line per closed ticket ... a decision lives in exactly one place, its ticket, so the map never restates it, only gists it and links"), `## Not yet specified` (fog), `## Out of scope`. Child issues labelled `wayfinder:research|prototype|grilling|task`, HITL or AFK. "Plan, don't do."

**implement** (docs): reads ticket/spec, drives `/tdd` at pre-agreed seams, runs `/code-review`, commits to the current branch. The docs page itself concedes: "`implement` has no completion step. It ends at the commit and never touches the work item."

The flow: `grill-with-docs → to-spec → to-tickets → implement → code-review`, with `wayfinder` as an on-ramp that "merges onto the chain at to-spec".

## Scale of use (before the samples)

These are GitHub issue-search counts on 2026-09-05, unauthenticated API, so treat them as order-of-magnitude **[measured, loosely]**:

- Issues whose body contains all four of "User Stories", "Implementation Decisions", "Testing Decisions", "Out of Scope": **41,225**. The most recent 14 were created within a 40-minute window (01:23 to 02:00 UTC), nearly all labelled `ready-for-agent`, in repos across TypeScript, Flutter, Python, Chinese-language projects.
- Issues labelled `ready-for-agent`: **355,512**, of which **291,661** closed (82%). Caveat: the label name is not unique to this toolset, though it is the toolset's default vocabulary.
- Issues labelled `wayfinder:map`: **10,294**, of which **6,402** closed (62%).
- Issues with "What to build" + "Acceptance criteria" + "Blocked by" in body, closed, with a linked PR: **98,924**.
- Matt's own `course-video-manager`: **1,272** issues, **29** open; **110** issues match the spec signature, the earliest on 2026-01-14 (#18 "Video Editor Clip Sections"), so the template predates the `to-spec` rename by months.
- `mattpocock/skills` itself: 455 open issues, 323 closed.

So the artifacts exist in volume. Whether they are good is the rest of this document.

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

## Sample 2: third-party spec, 40 stories, closed via 24-commit PR (thstanton/gigloop #511)

**URL:** https://github.com/thstanton/gigloop/issues/511. Author thstanton, opened 2026-06-19, label `ready-for-agent` ("Fully specified, ready for an AFK agent"), 19 comments (not readable), linked PR #539. Titled "PRD: Booking Builder — unified structural-setup flow, editor split & itinerary unification" (pre-rename vocabulary). 40 user stories; Implementation Decisions organised as five deep modules.

Condensed from the page (the tool paraphrased the long sections; module names and constraints are as written):

> **Problem Statement.** The New Booking form prioritizes CRM tasks but forces musicians into an unwieldy "Edit booking" drawer for operational setup. This interface conflates disparate concerns, implements four incompatible save paradigms simultaneously, and artificially splits packages from itinerary ...
>
> **Implementation Decisions.** Module A — Completeness Predicates (Deep Module): single pure module mapping `Booking` to per-concern status (empty | partial | set) ... Module D — Checklist Structural Items: `build_itinerary` and `add_venue`; `assign_band_members` reserved ... Module E — Continuous Create → Build Flow: refactors New Booking to explicit commit checkpoint (atomic `POST`) with Finish/Continue choice. Retires `BookingEditDrawer` ... Series-membership edits inherit ADR-0029 retroactive-assignment guards.
>
> **Testing Decisions.** Module A: pure unit tests over representative `Booking` shapes ... Module B: Storybook interaction tests; primary happy path + explicit Loading & Feedback state assertions ... Modules C & E: lighter direct testing.
>
> **Out of Scope.** Concrete Builder step sequence and grouping; Booking detail-page card topology post-drawer retirement; detailed 375px navigation pattern; Band feature; custom checklist/template authoring; quote/fee tooling.

**Implemented?** Yes **[measured]**. PR #539, author thstanton (human account), merged 2026-06-20, 24 commits, "Closes #511, #516–#529, #535, #536" (the spec plus 16 tickets). PR verification note: "Full `apps/web` suite green (492 tests); tsc + vite build + eslint clean. Deep-scroll on ?section= not verified in jsdom." Four items were explicitly deferred to new tickets (#530, #534, #537, #538). So: a 40-story spec became 16 tickets and one merged PR in ~24 hours, with scope leakage handled by filing follow-ups rather than silently dropping them.

## Sample 3: spec derived from a wayfinder map, implemented by a bot (course-video-manager #1265 → #1282 → PR #1293)

Map #1265 "Wayfinder map: TikTok creator — short-form videos, portrait player, subtitled render, TikTok + Shorts posting" opened 2026-07-13, closed 07-15, 15 decision tickets. Spec #1282 opened 2026-07-14 (label `ready-for-agent`), 42 user stories, 28 implementation-decision bullets. Excerpts:

> ## Problem Statement
> Matt wants to make short-form (9:16) talking-head videos and post them to TikTok and YouTube Shorts. CVM today is built end-to-end around landscape lesson videos.
>
> Implementation decisions (first six, condensed): Two service seams only (Render, Post); existing boundaries unchanged. OBS profile switching inside existing obs-connector seam. Schema needs no test seam; exercised through service seams. Remotion overlay renderer extracted to own package; CVM owns glue. `videos.format` column: plain text, values "standard"|"short", no pgEnum. `videoPosts` child table: id, videoId, platform, remoteId, remoteUrl, postedAt, createdAt.
>
> Further Notes: Rotate AWS keys in total-typescript-monorepo. Buffer Free tier suffices. Suggested implementation sequence: (1) format + TikToks surface; (2) Studio + OBS choreography; (3) render pipeline; (4) posting.

**Implemented?** Yes, by an AFK agent **[measured]**. PR #1293 "feat: TikTok creator — short-form video pipeline", author `github-actions[bot]`, co-author Claude Opus 4.6, created and merged 2026-07-14, 9 commits, closes #1282 plus tickets #1283–#1290. The PR body is the most honest artifact in this set because it enumerates its own drift:

> **Identified Spec Gaps.** 1. "Post TikTok" dropdown action — was disabled; wired to posting modal in commit 0e99ee6. 2. Record tile OBS automation — tile navigates to editor (which starts recording), differs slightly from "one-click" spec intent. 3. Blob deletion grace period — spec requested 24-hour window; implementation deletes immediately on `sent`.
>
> **Notable Standards Fixes.** The agent review flagged five standards violations, all addressed in commit ce1038db: replaced raw `localStorage` with `useLocalStorage` hook; converted `useEffect` navigation to server-side `redirect()`; swapped promise-based file I/O for Effect `FileSystem` primitives; fixed unstable `useCallback` dependencies via ref pattern; corrected Buffer `remoteUrl` storing ephemeral blob URLs.
>
> **Scope creep.** Minor housekeeping in `CONTEXT.md`, dead code removal in `schema.ts`, and unrelated course-duplication drift tests.

So the map → spec → tickets → bot-implemented PR chain closed in two days, and two of 42 stories were knowingly shipped differently from the spec, flagged rather than hidden.

## Sample 4: Matt's Sandcastle-labelled spec, 44-commit PR (course-video-manager #1567 → PR #1576)

Spec #1567 "Overlay + Definition Card: word-level transcript timing, CLI-authored on-screen term cards, export pipeline support", opened 2026-08-22, label `Sandcastle` ("Issues for Sandcastle to work on", i.e. Matt's own AFK-agent runner), 29 user stories, 16 implementation decisions.

> ## Problem Statement
> Matt has no way to put polished, agent-authored visual content on top of his course footage. The only per-Clip 'extras' today are static, single-purpose hacks: Clip Zoom (a fixed 115% crop, camera scenes only) and Effect Clip (a fake Clip row whose entire job is to hold a white-noise transition).
>
> Testing Decisions (condensed): primary seam is the CLI harness (cli-write/remote-test-harness.ts) with real PGlite, extending patterns from cli-clip-writes.test.ts. Secondary seam employs pure functions without DB/Effect dependencies. FFmpeg services remain faked wholesale; no automated tests run against Remotion renderer packages.

**Implemented?** Yes **[measured]**. PR #1576, author mattpocock, 44 commits, created 2026-08-22, merged 08-23, closes the spec plus 8 tickets (#1568–#1575). Test counts in the PR: "@cvm/core (634), @cvm/local (2851), @cvm/overlay-renderer (10 tests)"; "Two-axis code review completed; violations fixed in separate 'code-review fixes' commit"; "Five modules refactored past token budgets; code motion only." Flagged for manual verification: "ffmpeg filter graph behavior (overlay timing/alpha blending) requires real export testing; Definition Card visual design reviewed via Remotion Studio, not automated tests."

## Sample 5: third-party spec from a cleared map, not yet built (allisonmahmood/patchy-cloud #135)

Opened 2026-09-05 (today), no `ready-for-agent` label on the spec itself but on its ten sub-issues #136–#145. 40 user stories, 13 numbered implementation decisions. Opening line: "Charted on the Auth map (2026-09-02 to 2026-09-05). This issue is the auth spec: every shape decision the build implements, assembled from the map's Notes and its closed tickets, which hold the detail." Implementation decision 1 verbatim: "Clerk holds the browser session; Patchy issues exactly one credential, the machine token; every bearer is a user." Testing decisions: "assert caller-visible outputs: response status, headers, cookies, body, database rows, and command exit codes. Never mock Clerk or test SQL directly." Status: 0/10 sub-issues done. Included as the freshest full-chain instance; outcome unknown.

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

## Sample: real CONTEXT.md files (excerpts, stats)

| Repo | Size now | Terms (approx) | Notes |
| --- | --- | --- | --- |
| mattpocock/skills (local clone) | 1,768 bytes, 4 terms | 4 | Pure glossary plus "Relationships" and "Flagged ambiguities". |
| mattpocock/course-video-manager, commit 076a5a7 (the version the README showcases) | 212 lines, 11.8 KB | ~65 | Sections: Language, Course structure, Course versions, Ghost entities, Video and clips, Video export and hashing, Recording, Planning, Ordering and lifecycle, Relationships, Example dialogue, Example dialogue: ghost courses, Flagged ambiguities. |
| mattpocock/course-video-manager, main today | 432 lines (312 loc), 63.4 KB | ~127 | 19 sections. "Materialization cascade", the README's showcase term, no longer exists (the git-repo backing was removed via wayfinder map #1197). |
| mattpocock/sandcastle | 217 lines, 12.1 KB | ~65 | Contains paths: `.sandcastle/worktrees/`, `~/.claude/projects/<encoded-cwd>/`, `<session-id>.jsonl`. |
| thstanton/gigloop | 733 lines, 137 KB | ~50+ | Nine "## Design principle — ..." sections before "## Terms". Hybrid glossary/ADR/spec. |

Verbatim entries, showcased version (March/April 2026):

> **Materialization:** The act of transitioning a ghost entity to a real entity by creating its on-disk representation.
> **Materialization Cascade:** The chain reaction when materializing a lesson inside a ghost course: assigns file path to course, materializes section, then materializes lesson — all in one flow.
> **CourseRepo:** The local git repository on disk that backs a course, referenced by the course's `repoPath`.

Verbatim entries, current version:

> **Course**: The primary domain entity: a structured collection of versions, sections, lessons, and videos, held entirely in the database. Not backed by any on-disk repository — the former git-repo backing was retired (ADR 0018). _Avoid_: Repo, Project
> **Section**: A grouping of lessons within a course version, ordered by fractional index. Identity is carried by its `title` (uniqueness enforced per-parent by `order`); its display path is derived from title, not stored. _Avoid_: Module, Unit
> **Transform**: An **Overlay**'s pan/zoom move on the underlying footage — an ordered sequence of framing keyframes (fractions of frame, following **Clip Zoom**'s convention, not pixels), interpolated in order across the owning **Overlay**'s duration. _Avoid_: Framing, Clip Zoom, Ken Burns, Pan
> **Clip Zoom**: A clip-level marker (`none`/`subtle`) that renders a **Clip** at 115% of frame — cropped centrally in x, biased above centre in y — so that a run of face-only camera clips has some visual change across its cuts.

Examples of non-glossary content in the current file, as flagged by the fetch: `packages/core/features/videos/clip-zoom.ts`, `{courseId}-{exportHash}.mp4`, "chained `overlay` node per Overlay, never a pass per Overlay", `EXPORT_VERSION` constant.

**Did it stay a glossary?** No, and Matt says so himself. Issue #1589 (mattpocock, 2026-08-23, open), "CONTEXT.md carries implementation detail that belongs in the code", verbatim:

> `CONTEXT.md` is the ubiquitous-language document — what each term MEANS, and the rules that hold for it. A large part of it currently describes HOW things are built instead: source paths and package paths (`packages/core/features/videos/clip-zoom.ts`); filename templates (`{courseId}-{exportHash}.mp4`, `{courseId}-{contentHash}.mov`); ffmpeg mechanics — node names, `setpts`, `enable='between(t,…)'`, chained `overlay` nodes, crop-before-scale ordering; tool names as mechanism: Remotion, Chromium, Whisper's upload cap and chunking; easing control points, tuning constants, and pixel arithmetic; test methodology (what is asserted against what); concurrency limits and pool sizes ... Implementation detail in a glossary goes stale silently. Nothing compiles against it, so it drifts from the code and then misleads whoever reads it — which is an agent, most of the time ... Raised while tuning the Bullet Panel's look, after adding a paragraph to the **Transform** entry that was itself mostly implementation detail.

The 5x byte growth from the showcased commit to today, in ~5 months of daily agent use, is the measured version of that complaint **[measured]**.

Third-party drift report: princess-pi/wtft #79 (duppypro, 2026-09-04) "CONTEXT.md: Widget entry describes one where two exist, contradicts passing test, Footer undefined": "The glossary is the file we point new work at, so a wrong entry propagates into everything written from it ... `CONTEXT.md` defines Widget as 'The persistent TUI panel wtft renders below the editor … toggled via `-S/--show` / `-H/--hide`.' However, `tests/wtft-74-budget-flag-parsing.test.ts` §4 establishes the opposite—and passes ... The behavior works; the glossary's description does not."

Gigloop's file opens with nine "Design principle — ..." essays ("booking as epic", "reminders are a Booking property", ...) before its first term. That is a spec wearing a glossary's filename.

The docs page itself records the pushback: "the sharpest public pushback is that a term and its plain-English expansion get the same result from the model, and that the vocabulary really compresses communication between the humans who share it." On HN (2026-09-02) ceuk made exactly that point about "materialization cascade" being less clear than the sentence it replaced.

## Sample: wayfinder maps

**Matt's maps** **[measured]**: 8 total. course-video-manager: #1111 (CMS auto-link, 07-03 → 07-06), #1137 (Rename Segment → Beat, same day), #1181 (Title-driven paths, same day), #1197 (Remove local-repo backing, 07-07 → 07-08), #1265 (TikTok creator, 07-13 → 07-15), #1347 (immutable course manifests, 07-17 → 07-24); all closed. sandcastle: #884 (AI SDK harness spike, opened 07-08) and #893 (WSL2 bind-mount provider, opened 07-08), both still open, #884 at "0 of 8 completed", Decisions so far "None yet". Two of eight maps stalled for two months.

**Map #1197 "Wayfinder map: Remove the local-repo backing from CVM courses"** (mattpocock, 2026-07-07, closed 07-08, 9 decision tickets), body as rendered:

> ## Destination
> Remove CVM's local-git-repo backing entirely. No `CourseRepo`, no on-disk section/lesson folders, no ghost/real distinction, no materialization cascade, or git plumbing. Every Section/Lesson/Video becomes a plain DB row; videos' local files live in one directory keyed by `lineageId`. Publish derives structure from the DB and emits only `.mp4` + `course.json` to Dropbox.
>
> ## Notes
> Target repo: `~/repos/matt/course-video-manager`. Ground truth already established through investigation. Effort supersedes title-driven-paths work (map #1181/PR #1190). Core affected files: `course-repo-write-service.ts`, `course-repo-parser.ts`, and ~48 other source files.
>
> ## Decisions So Far
> 1. Remove local-repo entirely — no feature flag (#1198): wholesale removal; safety net is git history
> 2. Publish output: .mp4 + course.json only (#1199): drop `.transcript.md`, `.body.md`, `.meta.json`, `TODO.md`, `changelog.md`
> 3. Keep todo/done as free per-lesson flag (#1200): plain nullable column decoupled from filesystem
> 4. Unify per-video local files by lineageId (#1201): one `video-files/{lineageId}` store for all videos
> 5. Migration: DB-only + rename standalone dirs (#1202): drop `repo_path`/`fs_status`, rename `{id}`→`{lineageId}` dirs
> 6. Sequencing with #1190 (#1203): land slices 1–3, cancel slices 4 & 6
> 7. Confirm no git-push dependency (#1205): delete Push button; repos stay inert
> 8. Agent VFS model (#1204): delete agent entirely (CVM CLI covers editing surface)
> 9. course.json path shape (#1206): retire `path`; identify nodes by `title`
>
> ## Not Yet Specified
> Standalone ↔ lesson relationship & move-to-course flow; Publish-time validation/lint replacing disk-structure assumptions
>
> ## Out of Scope
> Implementation spec and code changes; Footage path and exported `.mp4` handling; AI Hero-side `course.json` reader

This is the map behaving as designed: nine one-line gists, each pointing at a ticket, fog listed, scope fenced, resolved in a day. The current CONTEXT.md's "Course ... the former git-repo backing was retired (ADR 0018)" is the downstream trace of this map.

**Third-party map #112 "Auth map — Clerk, companies and machine tokens on tier 0"** (allisonmahmood/patchy-cloud, 2026-09-02, open, 17 decisions in three days, then spec #135 and ten build tickets). Destination verbatim: "... The map concludes when key decisions are finalized, the auth specification is written, and build work is filed as `ready-for-agent` sub-issues—one per agent session—following the approach used in the Effect v4 port." Decision 7 shows what a prototype ticket contributes: "Proven on `prototype/login-door`. Script-free pages complete handshake in 4.0–5.4 seconds door-side; local verification after 60 seconds uses cached tokens (~1 ms) ... Open question: 'Clerk per request or Clerk at the door only.'" Decision 2 shows research paying off: "Patchy table chosen over Clerk Organizations for this slice. Organizations require a $100/month B2B add-on for verified domains and per-org SSO." "Not Yet Specified: Nothing. The specification is filed; earlier fog has graduated into it."

**Observation [inferred]:** this map's Decisions-so-far entries are paragraphs, not one-line gists; the map became a store, the very thing the skill says it must not be. That is the mechanism behind issue #944 (below), where a map body silently exceeded GitHub's 65,536-character limit. Also, the ten build sub-issues carry `wayfinder:task` labels, i.e. implementation tickets typed as decision tickets, which the docs call "the type that goes wrong most often in practice."

## Matt's own worked builds (what he built, what happened, his own caveats)

**course-video-manager as the dogfood repo.** The aihero.dev page for "Real-world feature build with Claude Code: every step explained" (2026-03-20) describes "a raw, unscripted look at how I actually work with AI agents on a real codebase with over 1,200 commits and 637 closed issues", covering "initial feature brainstorming with the 'grill me' skill, through creating PRDs and breaking them into issues, to running autonomous Ralph loops." The video itself is behind the course. Today the repo has 1,272 issues and 29 open; 110 of them are template specs since 2026-01-14; the repo's labels include `ready-for-agent`, `Sandcastle` (issues for his AFK runner), `agent:blocked`, `needs-triage`, `source:architecture-review` **[measured]**.

**AI Engineer Europe workshop, "Full Walkthrough: Workflow for AI Coding" (2026-04-24)**, per the shanraisshan/claude-code-best-practice transcript notes and videohighlight summary **[self-reported by Matt, summarised by third parties]**: feature was a gamification system (points, streaks, levels) for a course platform. Sequence: grill (~22 questions, ~25K tokens of planning), PRD (18 user stories, problem/solution/implementation decisions/testing/out of scope), PRD-to-issues (first proposal of 5 tasks rejected as "too horizontal"; he asked for a slice like "Award points for lesson completion visible on dashboard"), then a Ralph loop (`ralph_once.sh` concatenating local markdown issues, last 5 commits, TDD prompt, "No more tasks" sentinel). Reported hiccups: the agent started creating GitHub issues instead of local files and had to be corrected; a missing `point_events` table needed `npm db migrate`; a type error (`thresholds` vs `level_thresholds`) was caught by the feedback loop. Final suite: 284 tests; a subagent exploration burned 93.7K tokens. His line on the PRD: "We don't look at these. The reason I don't look at these is because what am I testing at this point?" On quality: "the quality of your feedback loops influences how good your AI can code. Essentially, that is the ceiling." On frameworks: he "prefers owning his stack rather than using off-the-shelf frameworks like Specification, Open Spec, or Taskmaster, citing a need for observability and control when things fail."

**Wayfinder demo.** The v1.1 changelog post (aihero.dev, 2026-07-08) says he "demonstrated Wayfinder using the Sandcastle repo, investigating whether to pull in the AI SDK as a dependency." That is map #884, which is still at 0 of 8 tickets two months later **[measured]**. Latent Space (2026-08-20) describes another: a rearchitecture of his personal website, "20+" tickets in the image caption, no outcome given. No transcript of "LIVE: The /wayfinder Demo" was found.

**His caveats, in his own docs.** The docs pages in the repo are unusually candid; the to-tickets page states over-decomposition "is the most reported friction on this skill", the implement page states "`implement` has no completion step", the wayfinder page states the grilling verbosity complaint "is not resolved", and the grill-with-docs page concedes that "the bulk of what you agreed exists only in the context window you agreed it in." Full list in Failure reports.

**On spec-to-code and BMAD, in his words.** README: "Approaches like GSD, BMAD, and Spec-Kit try to help by owning the process. But while doing so, they take away your control and make bugs in the process hard to resolve." X (status 2044029094942159126): "I just ran an AI coding course for ~2,000 people. One massive piece of feedback was how dissatisfied people are with frameworks like BMAD, GSD, Spec-Kit. Turns out that giving away control of context to a framework makes things a lot harder to debug. My advice: own the process." The "Software Fundamentals Matter More Than Ever" talk, per videohighlight: he says attempts to use the specs-to-code method "resulted in increasingly poor quality code" and critiques "the 'specs to code' movement, which suggests that writing specifications is the best way to build applications." X (status 2075856898142740821): "One clarification for folks using /wayfinder: The flow for big work should be: /wayfinder -> /to-spec -> /to-tickets -> /implement. Once the /wayfinder map is complete, you turn it into a spec. Some folks are using /wayfinder as the ENTIRE flow ..." And the tutorial tweet (2075218406266036236): "My skills repo has 160K stars, 7.5m downloads... ...and no tutorial."

## Reported outcomes

| Source | Date | Type | Claim | Caveat |
| --- | --- | --- | --- | --- |
| cvm PR #1585 (Matt) | 2026-08-23 | measured | Spec #1579 (26 stories) → 4 tickets → 12-commit PR merged in ~2h10m; co-author Claude Opus 5 | Matt's own repo; he wrote the spec, ran the agents and merged |
| cvm PR #1576 (Matt) | 2026-08-23 | measured | Spec #1567 (29 stories) → 8 tickets → 44-commit PR merged next day; 634/2851/10 tests | ffmpeg behaviour and visual design flagged "requires real export testing" |
| cvm PR #1293 (github-actions bot) | 2026-07-14 | measured | Map (15 decisions, 2 days) → spec (42 stories) → 8 tickets → bot PR merged same day | PR self-reports 3 spec deviations and scope creep |
| gigloop PR #539 (thstanton) | 2026-06-20 | measured | Spec (40 stories) → 16 tickets → 24-commit PR merged next day, 492 tests green | 4 items deferred to follow-up tickets; one path "not verified in jsdom" |
| noupling epic #338 | 2026-09-04 | measured | 13 tickets, expand/contract sequencing, 8 closed via PRs in 24h | Custom epic format, not the stock spec template |
| GitHub-wide counts | 2026-09-05 | measured, loosely | 41,225 template specs; 355,512 `ready-for-agent` issues, 82% closed; 10,294 maps, 62% closed | Closure ≠ quality; label may be used outside this toolset |
| Matt, AIE workshop | 2026-04-24 | self-reported | Gamification feature end-to-end in a 2h session; 284 tests; ~25K planning tokens; 93.7K subagent tokens | Demo on his own codebase; three live corrections needed |
| andrew.ooo | 2026-05-02 | self-reported, presented as measured | "time-to-correct-PR was consistently 20-40% lower with the skills installed than without"; "/grill-me alone is worth the install" | One week, one Astro project, no methodology; also reviews a `/caveman` skill that is not in this repo |
| andrew.ooo | 2026-05-02 | self-reported | "skip a week of edits [to CONTEXT.md] and the agent's accuracy regresses fast" | Same |
| HN, pipes | 2026-07-07 | self-reported | grill-me and tdd "massively helped, and technically the code generated is correct but it's still hard to follow and bloated" | Two skills only, not the spec/ticket pipeline |
| HN, gregwebs | 2026-08-14 | self-reported | "The grilling (grill-with-docs) skills are amazing for ensuring you produce a thorough spec that covers all the edge cases. The /code-review skill from there helps ensure that the code changes meet the spec." | Uses his own "intermediate detailed plan stage" instead of to-tickets |
| HN, LinXitoW | 2026-08-10 | self-reported | "the combination of the mattpocock skills, and the beads local issue tracker take care of all of that very well, with generally high quality output" | One sentence |
| Discussion #484, TimHoogervorst | 2026-07-09 | self-reported | Wayfinder "did not really do anything", defaulted to task tickets, rarely prototyped or researched, needed "babysitting" and more tokens than the grill→spec flow | Early v1.1 |
| Issue #595, david-seu | 2026-07-16 | measured (by reporter) | 26-ticket stack: "~20 agent runs per closed ticket, and roughly three quarters of those are repair-loop rework" | Root cause attributed to acceptance criteria; closed with template guidance change |
| Issue #826, jmnicolas90 | 2026-08-09 | measured (by reporter) | "/to-tickets consumed 2 whole sessions of a claude max 5x plan!!! 1.5M+ tokens"; 14 tickets, 90k–156k tokens per enumerator agent, ~70 OPEN decisions left for the human | The repo "mandates" a customised enumerator pipeline, not the stock skill |
| Issue #924, exwer | 2026-08-21 | self-reported with counts | 85-story PRD → 16 tickets → 27 tickets; a critical invariant was orphaned and only found in test env | Local markdown tracker |
| Issue #944, smoochy | 2026-08-23 | measured (by reporter) | Map body silently truncated at 65,536 chars; "59 index lines were lost"; map exceeded 100 sub-issues | Long-running map |
| Issue #554, richardwhatever | 2026-07-13 | self-reported with count | Sub-issue linking "has never worked across nearly a dozen specifications" on Codex 5.5 High | Open, no comment |
| Issue #341, tuterx | 2026-06-13 | self-reported | Precise grill answers "generalize into weaker summaries like 'persist sessions' or 'support retry,' allowing implementation drift" | 16 comments, unread; open |
| cvm #1589 (Matt) | 2026-08-23 | self-reported by author, plus measured 5x growth | CONTEXT.md "carries implementation detail that belongs in the code" | Open |

Not found: any controlled comparison (same feature, with and without the pipeline), any regression rate, any before/after defect count. The dev.to three-way comparison (2026-07-18) says it plainly: "Nobody has established the baseline: does any framework produce better results than running the same model with no framework at all?"

## Failure reports (what breaks)

From `mattpocock/skills` issues, verbatim where I could get it:

**Acceptance criteria that grade nothing (#595, closed).** "We ran a 26-ticket stack through it. It has produced ~20 agent runs per closed ticket, and roughly three quarters of those are repair-loop rework. The rework traces back to the criteria, not to the implementations ... **1. The criterion passes at HEAD.** ... One of ours graded a seam that lived only on an unmerged branch: three of four criteria passed at HEAD, and the ticket was fiction. **2. The criterion grades something the ticket does not own.** ... We have four instances; one criterion carried three clauses with three different owners. **3. The criterion echoes the request instead of deriving from the artifact.** ... Killed two tickets outright." Postscript: "an 8-criteria ticket closed clean while a 9-criteria one died. Count wasn't the variable; ownership was." (The docs page attributes this stack to horizontal slicing "by layer (corpus, producer, aggregator, selector)"; that framing is not in the issue text I could read.)

**Requirements orphaned in decomposition (#924, open).** "The PRD was detailed and marked ready-for-agent, with roughly 85 user stories ... The initial split produced 16 tickets. A critical PRD invariant was that the new writers must produce the complete serving model consumed by the unchanged read APIs ... A later parity ticket explicitly excluded serving-table hydration as 'another ticket', but that ticket was never created. Acceptance relied on proxies such as job success, an active pointer, rows being present, and the live endpoint responding. Those checks passed while several UI paths were empty and some serving rows were semantically incomplete. The gap was only found in the test environment ... The issue set eventually grew from 16 to 27 tickets ... the missing serving path was a direct PRD-to-ticket omission, and several original tests were too weak to prove their PRD claims."

**Detail loss between grill and spec (#341, open, 16 comments).** "Details frequently generalize into weaker summaries like 'persist sessions' or 'support retry,' allowing implementation drift ... Workflow relies on compressed prose and conversational memory with no deterministic way to verify whether answers were omitted, constraints weakened, or issues cover all decisions." The docs page for grill-with-docs adopts this: "Precise answers (ordering guarantees, negative requirements, numeric defaults) get softened into weaker prose downstream, and the result can look complete while missing the thing you actually decided."

**Semantic frame drift (#1015, open, 2026-09-02).** "An implementation agent can be locally coherent while silently changing one of those frames [identity boundaries, ownership, lifecycle, valid states, authority]. That is different from ordinary implementation drift." Proposes SUPPORTED/CONFLICT/UNSUPPORTED classification. Links to #130 and #207 "because `CONTEXT.md`/glossary material should not be treated as a PRD or execution plan."

**Token blow-up (#826, open).** Quoted above. Note the agent's own explanation inside the report: "It's the cost profile of the process itself: you're buying ~60 code-verified micro-decisions per ticket so implementers and reviewers don't burn review rounds discovering them later. Whether that trade is worth it at this price is a fair question." The user's reaction: "Great now I also have 70 questions to answer and need to wait 4 hours for reset."

**Wayfinder doing instead of deciding (#931, open).** "A `wayfinder:task` was allowed to modify production code after execution was enabled in the map Notes. The work happened inside Wayfinder rather than through the implementation flow, bypassing typical TDD, code review, and explicit design checks." The docs: "the constraint and its exemption live in the same file the constrained party owns."

**Map truncation (#944, open).** "Body crossed 65,536 characters during routine resolution append. Write was silently truncated with no notification. 59 index lines were lost, including entire `## Not yet specified` and `## Out of scope` sections ... Permanently lost: reasoning that existed only in the map body, particularly out-of-scope rulings for closed, unbuilt tickets."

**Tracker wiring (#554, #513, open).** "It has never worked across nearly a dozen specifications." Docs: the agent "went as far as asserting GitHub has no native blocking relationship at all."

**Stop conditions (#976, open).** "`to-tickets` requires narrow, complete, single-context vertical slices, but the generated ticket templates do not make the completion boundary explicit ... legitimate adjacent concerns expand ticket scope even after original acceptance criteria are satisfied."

**Skipping the pipeline (#975, open).** "After a /grill-with-docs session reaches a confirmed shared understanding, the workflow can jump directly into implementation instead of routing" to to-spec.

**Admitted in the docs pages** (Matt-curated summaries of field reports): implement "does not reliably close or check off the ticket"; parallel `/implement` sessions in one checkout produced "a `git commit --amend` in one session landing on another session's commit, a stash vanishing from `refs/stash`, and commits landing on the wrong branch, all in a single afternoon across three issues"; "One ticket burned 150k tokens ... normal rather than a sign something broke"; "I charted 27 tickets, and by the time I got to the thirteenth, the rest no longer made sense. A real and repeatedly-reported outcome"; "The grilling is exhausting. Every question is three paragraphs long ... not resolved"; and on to-spec: "Nothing keeps it in sync, so in practice it is a snapshot of what you knew at that moment ... Treat it as throwaway once the work ships."

**Matt's own artifacts contradict the templates** [inferred from samples]: file paths in specs and tickets; a map whose decisions are paragraphs; CONTEXT.md at 63 KB. The rules are aspirations the model does not reliably honour, and Matt does not appear to hand-correct them.

## BMAD vs Matt: structural comparison

BMAD's own framing (v4 README, quoted via kirodotdev/Kiro#1463): "**Agentic Planning:** Dedicated agents (Analyst, PM, Architect) collaborate with you to create detailed, consistent PRDs and Architecture documents. **Context-Engineered Development:** The Scrum Master agent then transforms these detailed plans into hyper-detailed development stories that contain everything the Dev agent needs ... This two-phase approach eliminates both planning inconsistency and context loss - the biggest problems in AI-assisted development." Current README (v6, 52.7k stars) reframes as Clarify → Plan → Build and verify → Learn, with "Durable context" as a selling point, and admits "Coding assistants are effective at implementation, but they often turn unstated assumptions into code."

| Dimension | BMAD-METHOD | Matt's skills |
| --- | --- | --- |
| Who writes the plan | Persona agents (Analyst → PM → Architect → PO shards → SM writes stories); the human answers elicitation prompts | The human, interrogated by one grilling agent; `to-spec` then transcribes "no interview, just synthesis" |
| Document hops before code | Brief → PRD → Architecture → sharded docs → story files (4–5 generated documents, each summarising the last) | Conversation → spec → tickets (2 documents; wayfinder adds a map of decision tickets before the spec) |
| Where decisions are made | Inside generated documents, by persona agents, reviewed after the fact | In the conversation, by the human, before any document; the spec "does not decide anything" |
| Where detail lives when the dev agent runs | The story file ("hyper-detailed ... everything the Dev agent needs") assembled by the SM agent from the sharded architecture | The ticket plus the parent spec plus CONTEXT.md/ADRs in the repo; ticket "sized to fit a single fresh context window" |
| What survives after shipping | The doc tree (docs/prd.md, docs/architecture/, stories/) stays in the repo | The docs say the spec is "throwaway once the work ships"; CONTEXT.md and ADRs are what is meant to last |
| Model-run or human-run | Model-run pipeline with human elicitation checkpoints; users automate whole epics (HN suchuanyi: "Now one command delivers a complete Epic") | Human-run: every planning skill is `disable-model-invocation: true`; dispatch of tickets is manual; "there is no auto-dispatch mode" |
| Framework's own failure log | Issues #95 "Dev agent frequently implements stories with tests but skips compilation and test execution, checking off tasks without validation"; #387 "Claude Code not following Dev-Agent instructions"; #497 dev agent "fails to load architecture files after brownfield workflow"; #2538 "Excessive noise in generated code (epic/story comments, AI slop)" | Issues #595, #924, #341, #826, #944, #931 above |
| Where Manuel's complaint lands | Summarisation loss is structural: each hop is a model summarising a model's output | Summarisation loss is reduced to one hop (conversation → spec) but is still reported (#341, #924, #1015) |

**Migration reports.** Only two found, both thin:

- HN, taffydavid, 2026-05-03: "I just spent a week training up in spec driven development through bmad, which was awful, and speckit which was ok but not great. Both had what seemed like unnecessary ceremony around the specs, generating fields of spec documents which presumably fill up the context window quickly. I just kept thinking 'this should be using something simpler, all this markdown is unnecessary'. This seems like the answer to that thought!" (commenting on a grill-me thread; no follow-up on results).
- Matt's ~2,000-student feedback tweet, above (aggregate, unquantified).

Nobody who wrote up a BMAD → Pocock migration with before/after numbers was found. The closest BMAD-side first-hand account (dev.to, arch4g, 2025-12-30): "it took roughly 12 to 16 hours before the first line of code was written"; "I tried to be clever and tell it something like: 'don't read everything, just put stuff into files and summarize.' In practice, that didn't really work"; but also "stories became 'the superpower'" and "everything is written down, you're not relying on your memory or on some fragile chat context." BMAD defenders on HN (redact207, sminchev) report onboarding several SaaS projects and reaching "2-3 iterations" per fix; those are self-reports too.

**Is Matt's system "the same philosophy"?** [inferred] Partly. Both are spec-first and both put a generated ticket/story between the plan and the code. The differences that matter for Manuel's specific burn (hallucinated, over-summarised stories that could not build): (1) there is one generative summarisation hop, not four, and it summarises a human conversation rather than another model's document; (2) the human is forced to answer the questions, so the content of the spec is things the human said; (3) tickets are meant to be vertical slices verified by a test at a pre-agreed seam, so a story that cannot build fails loudly at the first ticket. The evidence says (1)–(3) do not eliminate drift: #341, #924 and #1015 are the same disease at lower dose, and #595's 75% rework figure shows what happens when acceptance criteria are model-written and nobody checks them. The system's answer to that is "the quiz step exists for exactly this" and "reconcile the criteria yourself", i.e. the human is the safeguard. That is the design, not a bug, and it is the opposite of BMAD's "eliminates ... context loss" claim.

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

## Sources

Local clone: `research/1-matt-pocock/skills-repo/` (skills/engineering/{to-spec,to-tickets,wayfinder,implement,grill-with-docs}/SKILL.md; domain-modeling/CONTEXT-FORMAT.md; docs/engineering/*.md; README.md; CONTEXT.md; CHANGELOG.md; setup-matt-pocock-skills/issue-tracker-{github,local}.md).

Matt's repos:
- https://github.com/mattpocock/course-video-manager/issues/1579 (spec), /issues/1580, /issues/1582, /issues/1583, /issues/1584 (tickets), /pull/1585
- https://github.com/mattpocock/course-video-manager/issues/1567, /pull/1576
- https://github.com/mattpocock/course-video-manager/issues/1265 (map), /issues/1282 (spec), /pull/1293
- https://github.com/mattpocock/course-video-manager/issues/1197 (map), /issues/1589 (CONTEXT.md self-critique)
- https://github.com/mattpocock/course-video-manager/blob/main/CONTEXT.md?plain=1 and .../blob/076a5a7a182db0fe1e62971dd7a68bcadf010f1c/CONTEXT.md
- https://github.com/mattpocock/sandcastle/issues/884, .../blob/main/CONTEXT.md
- https://github.com/mattpocock/skills/issues/595, /826, /924, /931, /944, /554, /341, /1015, /976, /975; /discussions/484

Third-party artifacts:
- https://github.com/thstanton/gigloop/issues/511, /pull/539, /blob/main/CONTEXT.md
- https://github.com/allisonmahmood/patchy-cloud/issues/112 (map), /issues/135 (spec)
- https://github.com/pererikbergman/noupling/issues/338 (+ #339–#351)
- https://github.com/princess-pi/wtft/issues/79

GitHub search API queries (2026-09-05): `"Implementation Decisions" "Testing Decisions" "Out of Scope" "User Stories" in:body`; `label:ready-for-agent is:issue [is:closed]`; `label:"wayfinder:map" [is:closed]`; `"What to build" "Acceptance criteria" "Blocked by" in:body is:closed linked:pr`; `user:mattpocock label:"wayfinder:map"`; `repo:mattpocock/course-video-manager ...`.

Matt's own writing/talks:
- https://www.aihero.dev/real-world-feature-build-with-claude-code (2026-03-20)
- https://www.aihero.dev/skills/skills-changelog-v1-1-wayfinder-to-spec-to-tickets-grilling-improvements (2026-07-08)
- https://www.aihero.dev/things-people-get-wrong-with-grill-me-and-grill-with-docs (2026-05-25)
- https://github.com/shanraisshan/claude-code-best-practice/blob/main/videos/claude-matt-pocock-24-apr-26.md and https://videohighlight.com/v/-QFHIoCo-Ko (AIE workshop)
- https://videohighlight.com/v/v4F1gFy-hqg ("Software Fundamentals Matter More Than Ever")
- https://youtubesummary.com/summary/M6mYodf0dJM
- https://www.latent.space/p/wayfinder-skill (2026-08-20)
- X: status/2044029094942159126 (BMAD/GSD/Spec-Kit feedback), status/2075856898142740821 (wayfinder → to-spec clarification), status/2075218406266036236 (160K stars / 7.5m downloads)

Community:
- HN: https://news.ycombinator.com/item?id=49529329 (2026-09-01 thread), comments 49297440 (gregwebs), 48814877 (pipes), 49242942 (LinXitoW), 48095831 (adamthegoalie), 47994926 (taffydavid on BMAD)
- https://andrew.ooo/posts/matt-pocock-skills-claude-code-review/ (2026-05-02)
- https://kaizencode.art/notepad/matt-pocock-skills-guide/ (2026-07-16)
- https://nathanfennel.com/blog/matt-pocock-skills-three-months-later (2026-07-17)
- https://blog.alexrusin.com/agentic-coding-pipeline-matt-pocock-skills/ (2026-08-07)
- https://dev.to/jamilxt/superpowers-vs-agent-skills-vs-pocock-three-philosophies-of-ai-coding-workflows-e6n (2026-07-18)

BMAD:
- https://github.com/bmad-code-org/BMAD-METHOD (README), issues #95, #387, #497, #2538
- https://github.com/kirodotdev/Kiro/issues/1463 (quotes BMAD v4 "Two Key Innovations")
- https://dev.to/arch4g/my-experience-using-the-bmad-framework-on-a-personal-project-patience-required-28aa (2025-12-30)
- HN Algolia search "BMAD" (redact207, sminchev, suchuanyi, manapause comments)
