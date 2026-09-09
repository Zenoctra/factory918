<!-- lines: 15 | source: pages/pocock-planning-evidence.md | part 7/17 | title: Pocock Planning Evidence (brief) — Sample 4: Matt's Sandcastle-labelled spec, 44-commit PR (course-video-manager #1567 → PR #1576) -->

## Contents (line numbers are for the Read tool's offset)
- L6: Sample 4: Matt's Sandcastle-labelled spec, 44-commit PR (course-video-manager #1567 → PR #1576)

## Sample 4: Matt's Sandcastle-labelled spec, 44-commit PR (course-video-manager #1567 → PR #1576)

Spec #1567 "Overlay + Definition Card: word-level transcript timing, CLI-authored on-screen term cards, export pipeline support", opened 2026-08-22, label `Sandcastle` ("Issues for Sandcastle to work on", i.e. Matt's own AFK-agent runner), 29 user stories, 16 implementation decisions.

> ## Problem Statement
> Matt has no way to put polished, agent-authored visual content on top of his course footage. The only per-Clip 'extras' today are static, single-purpose hacks: Clip Zoom (a fixed 115% crop, camera scenes only) and Effect Clip (a fake Clip row whose entire job is to hold a white-noise transition).
>
> Testing Decisions (condensed): primary seam is the CLI harness (cli-write/remote-test-harness.ts) with real PGlite, extending patterns from cli-clip-writes.test.ts. Secondary seam employs pure functions without DB/Effect dependencies. FFmpeg services remain faked wholesale; no automated tests run against Remotion renderer packages.

**Implemented?** Yes **[measured]**. PR #1576, author mattpocock, 44 commits, created 2026-08-22, merged 08-23, closes the spec plus 8 tickets (#1568–#1575). Test counts in the PR: "@cvm/core (634), @cvm/local (2851), @cvm/overlay-renderer (10 tests)"; "Two-axis code review completed; violations fixed in separate 'code-review fixes' commit"; "Five modules refactored past token budgets; code motion only." Flagged for manual verification: "ffmpeg filter graph behavior (overlay timing/alpha blending) requires real export testing; Definition Card visual design reviewed via Remotion Studio, not automated tests."
