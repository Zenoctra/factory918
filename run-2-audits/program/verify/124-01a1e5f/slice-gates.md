# Slice: gates and the rebase
1. Net diff: `git diff 85988c7 01a1e5f` against `git diff 86d156a bd6a9b6`; every difference named. Expected only:
   SOURCES.md entry 16 renumbered 17; AGENTS.md ShellCheck line (glob with `'tests/*/*/*.sh'`, count 23) and the
   test bullets of #120, #121 and this PR all present; generated line counts. Nothing of #120 or #121 removed
   (`git diff e090a38 01a1e5f` and `git diff 85988c7 01a1e5f` remove no line those PRs added). No conflict markers.
2. Every line of `AGENTS.md` "Verifying" at the SHA (fixture flow with a relative `--directory fx` from a private
   parent, as `.github/workflows/factory-ci.yml:51` does; #123), every test under `tests/`, `check_knowledge.py`,
   `build_knowledge.py` then empty status, `./factory918.sh sync` then empty status, ShellCheck prints 23 files and
   AGENTS.md says 23. DECISIONS: P103, P105, P110 each present once.
3. CI at 01a1e5f: `gh run list --repo Zenoctra/factory918 --json databaseId,headSha,status,conclusion`; poll with
   `sleep 60` (under ten minutes per call) until the non-cancelled run completes; id and conclusion.
   `gh pr view 124 --repo Zenoctra/factory918 --json baseRefName,headRefOid,mergeable,closingIssuesReferences`.
Report: `/Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.scratch/program/verify/124-01a1e5f/worker-gates.md`.
