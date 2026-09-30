# Todo for ticket #89 (owner lane)

Legend: [x] done, [ ] open, `skip: <reason>` kept in place.

## Poteto-mode non-negotiable

- [x] Read the Principles section of `.claude/skills/poteto-mode/SKILL.md` in full.

## Ticket playbook (verbatim)

- [x] 1. Start from an up-to-date `main`. `git fetch origin main:main` (`git pull --ff-only` when on `main`), so local `main` moves too, then note the current branch. If `git status --porcelain` prints anything, stop, tell the user the checkout is dirty and what is in it, and do not start. Then run `.claude/skills/poteto-mode/scripts/overlap.sh N`. It prints `go: <label or none>`, one line per open PR whose own commits touch a path the ticket names in backticks, and on exit 0 a last line `base: <ref>`: `git switch -c <branch> <ref>`. (Ran `git fetch origin` per the brief since main is checked out elsewhere; porcelain clean; output `go: autopilot-stack` / `base: origin/main`, exit 0; branch `feat/design-artifact-on-ticket` from origin/main ab47eb9.)
- [x] 2. Read the ticket: `gh issue view N --json title,body,labels,state,comments`. Its What to build is the goal; its Acceptance criteria are the finish condition; its Parent is the spec: read it too, and read `CONTEXT.md` and the ADRs in the area. (No Parent on #89. Read #42's Testing decisions and PR #92 as `## Run under` says.)
- [x] 3. Check Blocked by. Every listed issue must be closed. (#42 is closed.)
- [x] 4. Falsifiability pass. (All six fail at HEAD; greps logged in decisions.tsv ticket-4; one concern.) For each criterion name the command or observation that would fail it right now.
- [x] 5. Select by content and run that playbook's steps verbatim from step 1: Feature. `how` and `why` first. Cross-cutting predicate (`review-brief.sh` holds it); if cross-cutting, `blast-radius` to `.scratch/89/blast-radius.md` and never skip `architect`.
- [x] 6. The spec's Testing decisions (no Parent spec; the ticket's Run under says rule 2 yields no table for this prose change; no tdd) are the pre-agreed seams. `tdd` there and nowhere else unless a criterion needs it.
- [x] 7. Verify on the matching surface per `docs/agents/evidence.md`.
- [x] 8. Run `.claude/skills/poteto-mode/scripts/overlap.sh N --diff` (printed nothing, exit 0: no Overlap section); output verbatim as `## Overlap` before `## Verification`. Then Opening a PR. Verification quotes each criterion with its evidence path. Last line before the attribution is `Closes #N`.
- [x] 9. Babysit to merge-ready per `playbooks/babysit.md`. Never merge. (CI green on c83f166, 0c63fa6, 78be65e; act-on items: 0 on the round-2 comment; the records commit 78be65e came after it, stated in the report; not merged)

## Feature playbook (verbatim)

- [x] 1. `how` over the affected subsystem. (two explorers, opus; explainer, opus; result .scratch/program/89/how.md)
- [x] 2. `architect` for parallel design exploration. architect skipped: prose and patches only, no function boundary, not cross-cutting (review-brief.sh:188 predicate), and the ticket's Run under says rule 2 yields no table for it; the design choices are in .scratch/program/89/design.md and decisions.tsv.
- [x] 3. Write the throughput checkpoint as four todo items:
  - [x] Blocking first steps. `how` (done), the design note `.scratch/program/89/design.md` (done); no other gate before the writer.
  - [x] Independent workstreams. Vendored patches (architect, to-spec, four playbooks, series, SOURCES) / ticket.md and issue-tracker copies / the knowledge page and its build / records: disjoint files, but one vocabulary across all of them, so one writer in commit order.
  - [x] Shared mutable state. n/a inside the ticket (one writer, one worktree). Across the program, DECISIONS.md, ledger.md and M0-findings.md are appended by sibling lanes; the root resolves them at chain time, and this lane appends at the end of each section only.
  - [x] Smallest safe decomposition. One writer, six ordered commits, each verified by sync and build cleanliness; two parallel writers would need a merge and risk two spellings of the same rule.
- [x] 4. Delegate code-writing (claude:fable@high per the sheet: general-purpose, model fable, isolation worktree) with a specific scope; review its diff yourself. Mandatory.
- [x] 5. Verify on the matching surface. (CLI proof: sync, build, bash -n, five test scripts, six patch reproductions, six criterion greps; all in the PR body)
- [x] 6. Rebase into small, ordered commits; stack follow-ups. (six ordered commits from the writer; no rebase after the push, per the brief)
- [ ] 7. If the design is contested, `interrogate` before shipping. skip: not contested; the ticket's Decision quotes settle the design and the owner's choices are recorded in DECISIONS P25
- [x] 8. Run Opening a PR. (PR #94)

## Opening a PR (verbatim, with AGENTS.md overrides)

- [ ] `/deslop` over the diff before commit. skip: prose and patches, no code; the writer applied writing-for-agents, technical-writing and unslop instead
- [x] `/technical-writing` then `/unslop` over title, body, commit messages.
- [x] Plain-sentence title (AGENTS.md P14 overrides the Conventional Commits rule here).
- [x] Body: Why, Scope, Tradeoffs, Blast Radius, Overlap, Verification; `Closes #89`; attribution line.
- [x] Forge `gh`; `--repo Zenoctra/factory918` on every `gh pr` command.
- [x] Open early as a draft; `gh pr ready` once Verification carries evidence.
- [x] After CI is green: `spec-review` in a fresh lane; fix Act-on items; `review-comment.sh` gate on every comment. (round 1: 5 act-on, fixed in 4 commits; round 2 on the fix: 0; both comments gated on exit 0)
- [x] `shellcheck` on every changed shell file. (none at c83f166; after the round-1 fix, shellcheck 0.11.0 clean on `overlap.sh` and `tests/poteto-mode/overlap.sh`)

## Records and report

- [x] Provisional decision in DECISIONS.md, ledger surprise, M0 dated line: one last commit. (P25, two ledger lines, two M0 lines; c83f166 and 78be65e)
- [x] Audit decisions.tsv against the transcript; cross-model review of the trail. (pointers resolve; Opus review in the report's Attention section)
- [x] Report at `.scratch/program/89/report.md`.
