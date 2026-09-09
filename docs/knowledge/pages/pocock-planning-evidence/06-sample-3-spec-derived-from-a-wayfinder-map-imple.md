<!-- lines: 25 | source: pages/pocock-planning-evidence.md | part 6/17 | title: Pocock Planning Evidence (brief) — Sample 3: spec derived from a wayfinder map, implemented by a bot (course-video-manager #1265 → #1282 → PR #1293) -->

## Contents (line numbers are for the Read tool's offset)
- L6: Sample 3: spec derived from a wayfinder map, implemented by a bot (course-video-manager #1265 → #1282 → PR #1293)

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
