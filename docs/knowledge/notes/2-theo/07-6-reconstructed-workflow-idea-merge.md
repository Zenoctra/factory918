<!-- lines: 60 | source: notes/2-theo.md | part 7/12 | title: Research note: Theo — 6. Reconstructed workflow (idea → merge) -->

## Contents (line numbers are for the Read tool's offset)
- L6: 6. Reconstructed workflow (idea → merge)

## 6. Reconstructed workflow (idea → merge)

Everything in this section is **[INFERRED]** synthesis; each step cites the evidence it rests on.

```
                 ┌──────────────────────────────────────────────────────────────┐
                 │  Machines: Linux Framework desktop (32 threads/64 GB), Mac   │
                 │  mini, ~5 boxes; reached via T3 Code (Tailscale/T3 Connect)  │
                 └──────────────────────────────────────────────────────────────┘
 IDEA ─► short prompt (voice, ≤2 sentences; "What would it look like to…")
   │      global AGENTS.md: "Questions are read only" → no edits during inquiry
   ▼
 PLAN ─► T3 Code Plan mode (proposed plan card) ──► "Refine" | "Implement" | "Implement in a new thread"
   │      for design: HTML mocks A/B/C/D on PostPlan ──► "Do C plus D plus A. File and babysit."
   │      listen when the model pushes back (Lakebed scope cut)
   ▼
 IMPLEMENT ─► one thread = one task; new git worktree per thread (t3.json setup script);
   │           Full access in worktrees; model routed by task (Sol default, Fable for taste/arch,
   │           Luna for cheap bulk); "Match ceremony to task" → no subagents for ordinary work
   ▼
 VERIFY ─► agent proves it: `vp test run <files>` + scoped lint/typecheck (never repo-wide);
   │        integrated pass via test-t3-app / test-t3-mobile (computer use only with permission);
   │        screenshots/video → File Upload skill → PR evidence
   ▼
 FILE ─► only when asked ("file"): File PR skill; conventional title; body ends with model+harness;
   │      one concern per PR; real PR not draft
   ▼
 BABYSIT ─► loop: CI + Macroscope review agents + bots; verify each finding against source; fix real,
   │         dismiss false with reason; "Stop when the bots are green on the latest commit"
   ▼
 HUMAN REVIEW ─► Theo reads the *conversation* + signatures/APIs; HTML review artifact for unfamiliar
   │              areas; Macroscope refuses auto-approve for default changes / lint suppressions
   ▼
 MERGE ─► from T3 Code PR page (Merge now / Auto-merge); thread auto-settles on merge
   │
 BACKLOG ─► cheap model (Muse/Luna) triages 200+ PRs into an HTML report; humans decide; "triage only, never merge"
```

**Step 1 — Idea/prompt.** Prompts are short and spoken: "almost all prompts are two sentences or fewer", dictated with Whisper Flow because "speaking produces much better prompts" [SECONDARY, May 27 2026]. Example: "What would it look like to let users bring environment variables for server-side code?…" → spec in under two minutes → "Love it. Build it." → feature pushed in ten minutes. He gives the model **stop points**: "When you give the model a stop point, life gets much better" [SECONDARY, Aug 11]; earlier: "write a plan, then stop and ask for feedback" [SECONDARY, "I don't really like GPT-5.5"].

**Step 2 — Plan.** T3 Code has a first-class Plan interaction mode (`interactionMode: "plan"` maps to Claude Code's `plan` permission mode [PRIMARY: `apps/server/src/provider/Layers/ClaudeAdapter.ts` ~line 4620]); the plan becomes an `OrchestrationProposedPlan` with `implementedAt` / `implementationThreadId`, and the composer offers **Refine / Implement / Implement in a new thread** [PRIMARY: `packages/contracts/src/orchestration.ts`; `apps/web/src/components/chat/ComposerPrimaryActions.tsx`]. For anything visual he asks for several HTML variants at once and picks by letter [SECONDARY, May 13 and Aug 11]. Plans are never committed [PRIMARY: AGENTS.md line 125]. Note the swing: in late 2025 he relied on "Cursor's plan mode with Opus"; by May 2026 he said that "just hurts" to look back on and that two-sentence prompts replaced long plans [SECONDARY]; by Aug 2026 the tier-list workflow for Sol/Fable is "vague description → plan approval → autonomous implementation, verification, PR filing" [SECONDARY, Aug 22]. So planning didn't disappear; it moved from long human-written plans to short prompts plus agent-written plans he approves.

**Step 3 — Implement.** One thread per task, run to completion before the next: "over 100 threads" in five days, each "single task completed start-to-finish before next began… I don't want old context getting in the way" [SECONDARY, May 27]. Parallelism comes from *many threads across machines*, not from subagents inside one thread ("Match ceremony to task"; "Delegation is for breadth or adversarial review, not for ordinary tasks" [SECONDARY, Aug 11]). Threads run in fresh worktrees: T3 Code defaults new threads to `local` but supports per-project `defaultThreadEnvMode: "worktree"` and `newWorktreesStartFromOrigin` [PRIMARY: `packages/contracts/src/settings.ts`, `t3ProjectFile.ts`]; his own machine held 125 worktrees [SECONDARY, Aug 20]. Permission mode: "Use Full access for work in a worktree or a sandbox you can throw away" [PRIMARY: `docs/user/permission-modes.md`]. Where he intervenes mid-thread: answers async questions (Codex "asks questions without stopping its work" [PRIMARY: `docs/user/providers-codex.md`]), approvals in supervised mode, and kills contaminated threads ("Once something's in the context, you can't prompt it out. You need to just start a new thread" [SECONDARY]).

**Step 4 — Verify.** The agent must produce the smallest proof and is barred from repo-wide checks [PRIMARY: AGENTS.md 106–111]. For UI, one integrated pass with the `test-t3-*` skills, with permission before computer use. Evidence is uploaded, not committed [PRIMARY: CI step; File Upload skill]. Philosophy: "Don't read diffs to verify. Give model tools to test its own output" [SECONDARY, May 27]; "The era of finding bugs by just reading the code has ended" [SECONDARY, Aug 24]; "If you don't have a custom debugger yet, you're not slopping hard enough" [SECONDARY, "You're reading way too much code"]. Verification infrastructure he built for agents: dev servers shared over Tailscale, read-only production data snapshots, a `gh` feature for uploading screenshots/videos as PR evidence [SECONDARY, Aug 24; PRIMARY: AGENTS.md "Test data", "Dev servers"].

**Step 5 — File and babysit.** "file and babysit" is his literal two-word instruction (demo: pointer-events bug fixed, PR filed, shepherded through bots and merged "in roughly fifteen minutes" [SECONDARY, Aug 11]). Repo rules: agent never files unless asked; conventional title; body ends with model + harness; one concern per PR; babysit until "bots are green on the latest commit" [PRIMARY].

**Step 6 — Human review.** "If you're looking at the code more than you're looking at the conversation about the code, you're already behind" and "You have to read what it says" [SECONDARY, May 27]. He reads "all function signatures and API definitions exhaustively" but delegates implementation reading to verification code and per-file summaries [SECONDARY, "You're reading way too much code"]. For unfamiliar areas he asks for an HTML review artifact: "Help me review this PR by creating HTML. I'm unfamiliar with streaming logic—focus there. Render actual diff with inline annotations, color-code findings by severity" [SECONDARY, May 13]. Machine review: Macroscope agents on trusted PRs, with a hard rule that default changes and any new lint/type-suppression directive "requires human review" [PRIMARY: `.macroscope/approvability.md`].

**Step 7 — Merge and settle.** Merge from the T3 Code PR page ("Merge now", "Auto-merge" with strategy) [PRIMARY: `apps/web/src/components/pullRequest/PullRequestDetailPanel.tsx`, `docs/user/source-control.md`]; threads auto-settle when their PR merges or after three idle days [PRIMARY: `docs/user/thread-sidebar.md`].

**Step 8 — Backlog.** Ease of filing creates bloat ("414 open PRs on T3 Code right now. It gets bad" [SECONDARY, May 27]); he uses cheap models to triage: 222 PRs classified into an HTML report in <5 min for $0.10, "use Muse for triage only, never merge" [SECONDARY, Aug 7].

---
