# Todo for ticket #88 (owner lane)

Legend: `[ ]` open, `[x]` done, `skip: <reason>` stays listed.

## Owner brief preamble

- [x] Read poteto-mode SKILL.md Principles in full.
- [x] Read ticket #42 `## Testing decisions` and PR #92 (description and its three review comments).
- [x] Start `decisions.tsv` within 15 minutes (show-me-your-work).

## Ticket playbook (verbatim steps)

- [x] 1. Start from an up-to-date `main`. `git fetch origin main:main` (`git pull --ff-only` when on `main`), so local `main` moves too, then note the current branch. If `git status --porcelain` prints anything, stop, tell the user the checkout is dirty and what is in it, and do not start. Then run `.claude/skills/poteto-mode/scripts/overlap.sh N`. It prints `go: <label or none>`, one line per open PR whose own commits touch a path the ticket names in backticks, and on exit 0 a last line `base: <ref>`: `git switch -c <branch> <ref>`, and when the ref is a PR head, keep the output and report every printed PR as an overlap and the base as the intended parent. Exit 1: stop, report. Exit 2: stop and report stderr.
- [x] 2. Read the ticket: `gh issue view N --json title,body,labels,state,comments`. Its What to build is the goal; its Acceptance criteria are the finish condition; its Parent is the spec: read it too, and read `CONTEXT.md` and the ADRs in the area.
- [x] 3. Check Blocked by. Every listed issue must be closed. If one is open, stop and report which; do not start.
- [x] 4. Falsifiability pass. For each criterion name the command or observation that would fail it right now. A criterion that already passes at HEAD, that another ticket owns, or that only restates the request goes back to the human as a note before work starts. A ticket whose criteria span more than one concern goes back to the human to be split before work starts.
- [x] 5. (Feature run; blast-radius written and in the PR body) Select by content and run that playbook's steps verbatim from step 1 (Feature). `how` and `why` over the affected subsystem come first. Cross-cutting diff (`.claude/hooks/`): after `how`, run `blast-radius` over it and write the result to `.scratch/<ticket>/blast-radius.md` in that skill's hand-back shape, with a risk for every session kind and every skill the change reaches, each with a `file:line`. Such a change never skips `architect`. The PR body's `## Blast Radius` section is that file verbatim.
- [x] 6. The spec's Testing decisions (no table; the Design case table is the seam and gate.sh asserts one row each) are the pre-agreed seams. `tdd` there, and nowhere the spec did not agree unless a criterion needs it.
- [x] 7. Verify on the matching surface (no verify-<app> skill in the factory; the gate, its test and the CI fixture are the surface). `docs/agents/evidence.md`; the primary agent runs the project's `verify-<app>` skill once after integrating.
- [x] 8. (overlap --diff exit 0, section in the PR body; draft PR #96 open) Run `.claude/skills/poteto-mode/scripts/overlap.sh N --diff`; its output, when there is any, is the PR body's `## Overlap` section verbatim, placed before `## Verification`; exit 1 means the reply names the printed PR as the one to merge first. Exit 2: stop and report stderr. Then run Opening a PR. The body's Verification section quotes each criterion with its evidence path. The last line before the attribution is `Closes #N`.
- [x] 9. (three rounds, CI green, act-on 0; never merged) Babysit to merge-ready per `playbooks/babysit.md`. Never merge.

## Run under (ticket #88, by hand)

- [x] (1) `how` and `blast-radius` (writeup at .scratch/program/88/blast-radius.md, verbatim in the PR body) as the Ticket playbook says.
- [x] (2) Architect artifact: usage, signature and a case table posted under ## Design on #88. This ticket has no state of its own, so no scenario table; a `## Design` usage-and-signature sketch is posted on the ticket if code crosses a function boundary, first line "Posted by the agent 2026-09-22"; prose-only parts have none.
- [x] (3) Tests written from the artifact before the implementation; commit order shows it.
- [x] (4) A writer that cannot implement a cell stops and reports it.
- [x] (5) (no design hole in three rounds) A design hole in review returns to architect; restart the review count with a PR comment "restart" and why.
- [x] (6) (walk carried one line per risk in rounds 1 to 3) Spec reviewer's walk has one line per risk in the blast-radius grounding.
- [x] (7) (round 2 fixed one; round 3 reviewed it) A round that fixed a Would-break item gets one more round, up to five.
- [x] (8) `shellcheck` on every changed shell file (the gate ran over all 20 at 69bd412, exit 0) before the PR opens.

## Feature playbook (verbatim steps, run at Ticket step 5)

- [x] F1. `how` over the affected subsystem.
- [x] F2. `architect` for parallel design exploration. Not skippable for a cross-cutting diff.
- [x] F3. Throughput checkpoint, four items:
  - [x] Blocking first steps. The design (arena, judge, synthesis) and the Design post on the ticket ran before the writer; the writer runs the gate, the four tests, sync and build_knowledge before it reports.
  - [x] Independent workstreams. n/a: one coupled diff (script, CI, test, prose all name the same command); one writer.
  - [x] Shared mutable state. The writer owns wt/88-writer in its own worktree; the records files are appended, siblings append too, the root resolves at chain time.
  - [x] Smallest safe decomposition. One writer, five ordered commits; splitting would put the script name in two lanes.
- [x] F4. Delegate code-writing through provider dispatch (feature: claude:fable@high) with `isolated-write`, a dedicated worktree, a specific scope (file paths, named data shape, success criteria); review its diff yourself. Mandatory.
- [x] F5. Verify on the matching surface. Ran the gate, gate.sh, the five tests, sync and the knowledge build myself on feat/shellcheck at 69bd412; all green.
- [x] F6. Rebase into small, ordered commits. Already five ordered commits (gate, fixes, doctor, prose, records); no rebase needed.
- [ ] F7. If the design is contested, `interrogate` before shipping. skip: the arena converged on one shape and the judge agreed; no round changed the design.
- [x] F8. Run Opening a PR (PR #96).

## Opening a PR (at Ticket step 8)

- [x] `/deslop` over the diff before commit (writer before each commit; I re-read the diff: why-comments only, no narration).
- [x] `/technical-writing` then `/unslop` over title, body, commit messages (no long dash, plain sentences, problem then fix).
- [x] Title: plain sentence (AGENTS.md overrides the Conventional Commits rule here).
- [x] Body: Why, Scope, Tradeoffs, Blast Radius (file verbatim, no `## ` inside), Overlap (if any), Verification (each criterion quoted with evidence), `Closes #88`, attribution.
- [x] Open early as a draft (#96); `gh pr ready` once Verification and Blast Radius carry evidence.
- [x] After CI green: `spec-review`, three rounds (act-on 3, 4, 0), every comment gated on `review-comment.sh` exit 0.
- [x] Records commit: P25 in DECISIONS.md (69bd412), ledger lines and M0 section (69bd412, 3f3814c).
- [x] Report at `.scratch/program/88/report.md`.
