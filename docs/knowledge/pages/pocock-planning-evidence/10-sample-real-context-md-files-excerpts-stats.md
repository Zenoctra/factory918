<!-- lines: 41 | source: pages/pocock-planning-evidence.md | part 10/17 | title: Pocock Planning Evidence (brief) — Sample: real CONTEXT.md files (excerpts, stats) -->

## Contents (line numbers are for the Read tool's offset)
- L6: Sample: real CONTEXT.md files (excerpts, stats)

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
