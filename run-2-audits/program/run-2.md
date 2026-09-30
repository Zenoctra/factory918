# Run 2: autopilot-stack #103 #105 #110 #106 #107 #108 #109

Manuel gave the go on 2026-09-22. The go line is already in `.claude/state/program`. The owner brief is
`.scratch/program/owner-brief.md` (run 1's is `owner-brief.run1.md`).

## Why a fresh session

Manuel's model rule (2026-09-22): upper tier = Claude Opus 5.5 (replaces every `fable` role), lower tier =
Claude Opus 5 (replaces every `opus` role). The Agent tool's `model` enum cannot name Opus 5, and the bare
`opus` alias is now Opus 5.5. The pinned definitions `.claude/agents/tier-upper.md` (`claude-opus-5-5`) and
`tier-lower.md` (`claude-opus-5`) are loaded only at session start (excluded from git via `.git/info/exclude`).

Step 0 of the new session: probe both with a one-line "reply with your exact model ID" Agent call. If
`tier-lower` fails or reports another model, the `claude-opus-5` ID is wrong: stop and ask Manuel.

## Order (Manuel's note, verbatim rules in the conversation of 2026-09-22)

1. #103, #105, #110 together from `main` (no shared files). Owners: `tier-upper`, `isolation: "worktree"`.
2. Then serially from the settled tip: #106, then #107 stacked on #106, then #108 on #107. The three share
   the review brief script and its test.
3. #108 and #109 only after Manuel merges #105.
4. Keep rate-limit headroom before launching the last owner.
5. Later, when convenient: #111; #112 after #103.

## Root rules

- The root is the only topology writer; never rewrite a branch with a live child; rebase a link before
  verifying it.
- #100 is open: the root retargets a stacked PR through `main` and back once so its ticket links.
- Every owner's first action is the poteto-mode skill, then the brief's step 0. Owners poll for their lanes'
  files inside their turn. Every writer, fix and architect lane an owner launches also starts with the
  poteto-mode skill.
- Delegate reports are act-on lists settled before round one; the trail review runs on every PR.
- STACK-READY verification (playbook step 4): three `tier-lower` verifier lanes per PR (gates, live runtime
  floor, receipts-and-diff audit), as in run 1.
- Measurements and the reconciliation of carried notes: `.scratch/program/postmortem/`.
- Todo file: `.claude/state/todo-run2.md`.
