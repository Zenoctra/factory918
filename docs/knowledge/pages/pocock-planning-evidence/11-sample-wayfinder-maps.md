<!-- lines: 39 | source: pages/pocock-planning-evidence.md | part 11/17 | title: Pocock Planning Evidence (brief) — Sample: wayfinder maps -->

## Contents (line numbers are for the Read tool's offset)
- L6: Sample: wayfinder maps

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
