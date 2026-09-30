# Slice: receipts-and-diff audit

Distrust the PR body and the owner's report. Read the actual diff `git diff ab47eb9...2360707` (yours to read
whole; it is large, read it in file groups) and the ticket, and check:
1. Each of the ticket's six acceptance criteria against the diff: name the file:line that satisfies it or say
   it is unmet. Criterion 1 says pinned "to an exact version (a release download or a pinned action, not
   whatever the runner image carries)": confirm the pin and the checksums in the script, and that the PATH
   binary is used only when its version equals the pin. Criterion 4 says the doctor check is NOTE not FAIL.
   Criterion 5 says CI does not enforce the directive reason and the Standards axis does.
2. Scope: one concern per PR. List every file the diff touches, grouped, and flag anything outside the
   ticket's ask (the report admits: `bash -n` removed from CI and AGENTS.md; the template's `CODING_STANDARDS.md`
   and `AGENTS.md` gained rules; 57 findings resolved across the factory's shell files, which is a wide diff;
   directive-reason edits on `overlap.sh`; P25 in DECISIONS.md; ledger and M0 lines). For the 57 resolved
   findings, sample at least ten across different files and confirm each is a behavior-preserving fix (quoting,
   `read -r`, etc.) and not a semantic change; list any that changes behavior.
3. Receipts: three review comments on PR #96 by the author's account ending `act-on items: 3`, `4`, `0` with
   `round: 1 of 3`, `2 of 3`, `3 of 3`; the fix commits between the rounds as the report lists them;
   commits 3f3814c and 2360707 after round 3: confirm and list exactly what each changes. Round 2 fixed a
   Would-break, so rule 7 owed round 3 on it: confirm round 3's fixed point was the round-2 head.
4. PR body shape per `AGENTS.md` "Pull requests" at the SHA: plain-sentence title, problem then fix,
   `## Blast Radius` present with no `## ` heading inside it, `## Overlap` before `## Verification`,
   `## Verification` naming what ran and its outcome, `Closes #88` last before the attribution, the attribution
   line, then the model-and-harness line. `gh api graphql` on `pullRequest(number:96).closingIssuesReferences`
   must list only #88.
5. Blast radius: the diff touches `.claude/hooks/*.sh` through `template/.claude/hooks/`; the grounding claims
   `delegation.sh` stripped of comment lines is byte-identical before and after. Reproduce that claim for every
   hook file the diff touches (`grep -v '^\s*#'` both sides, `diff`), and say whether any hook changed behavior.
6. Forbidden edits: nothing hand-edited under `docs/knowledge/spec/`, `pages/`, `notes/`, `research/`;
   `template/docs/factory918/` and `docs/knowledge/INDEX.md` match a rebuild.
7. The `## Attention` items in the owner's report: for each, say whether it is a defect in this PR, a judgment
   for Manuel, or nothing. Item 4 (two gates sharing one TMPDIR): say whether CI or a lane can hit it.
Report file: `/Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.scratch/program/verify/96-2360707/worker-audit.md`.
