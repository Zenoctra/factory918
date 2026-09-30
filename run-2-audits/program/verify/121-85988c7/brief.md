# Re-verify PR #121 (ticket #110) after the root's rebase onto PR #120

PR #121 was verified at e9fd603 on `main` (reports in `../121-e9fd603/`). The root rebased it onto PR #120's verified
head `e090a3880f1914fc327822c1618492dbad59ccf8` and pushed `85988c7fe789202e4b9a880c71248578a139e2d4`; the PR's base
is now `feat/speed-lessons`. The patch ID changed. The root says the only difference in the net diff is two generated
line counts (`<!-- lines: N -->` in `docs/knowledge/core/DECISIONS.md` and its row in `docs/knowledge/INDEX.md`), and
that the conflicts were append collisions in `AGENTS.md`, `docs/M0-findings.md`, `docs/agents/ledger.md` and the
DECISIONS table, resolved by keeping both sides. Distrust that and check it. Verdict: `PASS`, `PASS+NOTES`, `ISSUES`
or `BLOCKED`, with commands, output and exit codes.

In your own worktree: `git fetch origin feat/provisional-ticket-ids feat/speed-lessons main`, `git checkout --detach
85988c7fe789202e4b9a880c71248578a139e2d4`; confirm the SHA and `git merge-base --is-ancestor e090a38 HEAD`.
1. Compare `git diff 86d156a e9fd603` with `git diff e090a38 85988c7`: every difference named and explained. Nothing
   of #120 lost: `git diff e090a38 85988c7` removes no line #120 added (check the record files and AGENTS.md).
2. No conflict markers anywhere in the tree (`git grep -n '^<<<<<<<\|^>>>>>>>\|^|||||||'`).
3. Every line of `AGENTS.md` "Verifying" at the SHA (fixture flow with a relative `--directory fx` from a private
   parent, as `.github/workflows/factory-ci.yml:51` does; #123), every test under `tests/`, `check_knowledge.py`,
   `build_knowledge.py` then empty status, `./factory918.sh sync` then empty status.
4. DECISIONS: `P105` and `P110` both present, unique, the rule line under `## Provisional` present once.
5. CI at the head: `gh run list --repo Zenoctra/factory918 --json databaseId,headSha,status,conclusion` for 85988c7;
   wait (poll with `sleep 60`, under ten minutes per call) until the non-cancelled run completes; report its id and
   conclusion. `gh pr view 121 --repo Zenoctra/factory918 --json baseRefName,headRefOid,mergeable,closingIssuesReferences`.
Read-only on GitHub; never comment, edit, merge or close. Write your report (first line `verdict: ...`, then one
bullet per check, `## Issues`, `## Notes`) to
`/Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.scratch/program/verify/121-85988c7/worker.md`
(if worktree isolation refuses the Write, write in your scratchpad and `cp` it there). Reply with only the path.
