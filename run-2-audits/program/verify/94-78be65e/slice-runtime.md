# Slice: live runtime floor

Exercise the load-bearing behavior the PR introduces, live, not by reading. The PR claims:
(a) `template/.agents/skills/poteto-mode/scripts/overlap.sh` now skips a ticket body's `## Testing decisions`
and `## Design` sections when collecting backticked paths, as it skips `## Diff`. Prove it both ways at the
SHA: run the script's path-extraction awk/grep pipeline (or the whole script with a fake `gh` on PATH that
returns a crafted body, the way `tests/poteto-mode/overlap.sh` does; read that test's harness first) on a
body with backticked paths inside and outside those sections, and show which paths survive. Also show
that a heading like `## Testing decisions extra` or `### Design` behaves as the header comment documents.
(b) The sixth core document `docs/knowledge/core/SCENARIO-TABLE.md` ships to a project: run the fixture
flow's apply step into a scratch directory outside the repository (`cd /tmp && vp create vite:monorepo
--directory fx-verify-94 --no-interactive --git --hooks --no-agent`, then from your worktree
`./factory918.sh apply /tmp/fx-verify-94 --scaffold --profile python --name demo`), and check the applied
project has `docs/factory918/SCENARIO-TABLE.md`, that `factory918 doctor` (or `./factory918.sh doctor`
run inside the project) still passes, and that `/knowledge`'s slim list in the applied project names it.
Remove `/tmp/fx-verify-94` when done.
(c) The patched skills read correctly after `sync`: `template/.agents/skills/architect/references/runner-prompt.md`
line 7 and 10, `template/.agents/skills/architect/SKILL.md` Phase B, `template/.agents/skills/to-spec/SKILL.md`
line 66, the four playbooks' delegation steps: quote each changed sentence and say whether it reads as a
rule an agent can follow (ambiguity is a note, a contradiction with `ticket.md` step 6 is an issue).
Report file: `/Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.scratch/program/verify/94-78be65e/worker-runtime.md`.
