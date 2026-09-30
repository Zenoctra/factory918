# Slice: receipts-and-diff audit
Distrust the PR body and the owner's report. Read `git diff 6e5c539..e710e99` whole:
1. Each of #137's criteria: file:line or unmet. The five listed lines: each gone or replaced, in every place the audit
   names (review-brief.sh, SKILL.md steps 4 and 5, P18, review-ladder.md).
2. Scope: every file touched; anything outside the ask (the owner added factory-ci.yml and SOURCES.md item 6: judge
   each); no upstream pstack wording changed (Manuel ruled it stays): check `patches/pstack/**` is untouched.
3. The owner's replacement sentences: apply the no-leading test to each strictly; the owner rejected two audit proposals
   as still leading. Agree or not, with reasons.
4. Receipts: round one on PR #140 `act-on items: 0`; whether a round two is owed under #106's rule (run `review-brief.sh`
   over the real comment history via a fake gh); CI green; `closingIssuesReferences` #137 only; base
   feat/risk-dispositions.
5. PR body per `AGENTS.md` "Pull requests": title, problem then fix, `## Blast Radius` (no `## ` inside), `## Overlap`
   before `## Verification`, outcomes, last three lines `Closes #137`, attribution, `Claude Opus 5.5 on Claude Code`.
6. Forbidden edits; generated files match a rebuild.
7. The owner's Decided items: defect, judgment for Manuel, or nothing. The eval runner prompt
   `tests/eval/reviewer/reviewer.py` was left unchanged: does it lead? (#138 will run on it.)
Report: `/Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.scratch/program/verify/140-e710e99/worker-audit.md`.
