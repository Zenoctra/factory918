verdict: PASS+NOTES

Re-verification of PR #101 (ticket #91) at `d8e382ca37233bce98724c785ecdbb677abc4e2a`, rebased onto PR #99's tip
`0ff73f0b6c11bb54909c1b54ddc1fe1428ff0f93`. The rebase changed no line this PR adds or removes: the only per-file
differences between the old patch and the new one are the four renumbering and regeneration edits the conflict
resolution required (P26/P27 → P28/P29, the two generated line counts) plus hunk context that moved with #99's text.
Every gate passes at the new head, CI is green there, and a live run of the walk rule shows this PR's risk sentence and
#99's `spec:` rule in the same Spec brief. Three notes below are stale row-id references in text that is not the
repository's content; none changes behavior.

## Setup

- `git fetch origin feat/spec-walk-risks feat/design-hole-restart feat/shellcheck feat/design-artifact-on-ticket main`
  → `+ 7956c69...d8e382c feat/spec-walk-risks -> origin/feat/spec-walk-risks (forced update)`, exit 0. Own worktree
  `/Users/manuel/.../.claude/worktrees/agent-a38cf092608c6d42e`; private `TMPDIR` under the session scratchpad.
- `git checkout --detach d8e382ca37233bce98724c785ecdbb677abc4e2a` → `HEAD is now at d8e382c Give the CI fixture's
  grounding the Risks heading the brief now needs`, exit 0. `git rev-parse HEAD` → `d8e382ca37233bce98724c785ecdbb677abc4e2a`.
- `git merge-base --is-ancestor 0ff73f0 HEAD` → exit 0. `git log --oneline -6` →
  `d8e382c, 769217c, adaf4a0, 649d126, 9db29b4, 0ff73f0`: the tests-first order survived the rebase.
- `git diff 0ff73f0..d8e382c | git patch-id --stable` → `f9556bcf54728f6e26ef893c9c31d8aa8168fe9a`, exit 0, the id the
  brief names for the rebased patch.

## 1. Delta of the rebase

- `git diff --stat 52ccd8e..7956c69` and `git diff --stat 0ff73f0..d8e382c` → byte-identical stat blocks: the same 15
  files, `185 insertions(+), 43 deletions(-)` both times, exit 0. No file is added to or dropped from the patch.
- Per-file comparison (`diff` of each file's hunks, split from the two full diffs by a script under `TMPDIR`), exit 0:
  identical for `.github/workflows/factory-ci.yml`, `patches/pstack/poteto-mode/playbooks/opening-a-pr.md.patch`,
  `template/.agents/skills/poteto-mode/playbooks/opening-a-pr.md`; differing for the other 12.
- Comparing only the `+`/`-` lines (context and `@@` headers dropped) narrows the real differences to four files, exit 0:
  - `docs/knowledge/core/DECISIONS.md`: `| P26 |` → `| P28 |`, `| P27 |` → `| P29 |` on the two added rows, and the
    generated header `<!-- lines: 93 → 95 -->` becomes `<!-- lines: 95 → 97 -->`. The row text after the id is
    character-for-character the same as before the rebase.
  - `template/docs/factory918/DECISIONS.md`: the same two ids, same row text.
  - `docs/knowledge/INDEX.md`: the `core/DECISIONS.md` row's line count `93 → 95` becomes `95 → 97`.
  - `SOURCES.md`: both the removed and the added form of item 6 now carry #99's two `hole:` sentences; an intraline diff
    of the removed against the added line is, in both the old and the new patch, one insertion of exactly the same
    sentence: "The grounding carries its risks under a line that is exactly `## Risks` (a file) or `### Risks` (a PR
    body, its headings demoted one level), outside fenced text, or `review-brief.sh` refuses it naming the source; with
    a grounding the Spec brief's `## Walk` bullet continues with the risk sentence, one numbered line per risk after the
    steps, which step 4 carries word for word." It still lands after "…refuses it without one." and before #99's
    `hole:` sentences, so both sides are kept.
  All four are conflict resolutions against #99's rows and the regeneration that follows them. Nothing else differs.
- The remaining eight files differ only in hunk headers and context lines, i.e. the base moved under them:
  `docs/M0-findings.md` (`@@ -179 → @@ -183`), `docs/agents/ledger.md` (`@@ -23 → @@ -28`),
  `patches/mattpocock/spec-review.SKILL.md.patch`, `template/.agents/skills/poteto-mode/playbooks/ticket.md` (the
  context line is #99's expanded step 6), `template/.agents/skills/spec-review/SKILL.md`,
  `template/.agents/skills/spec-review/scripts/review-brief.sh`, `tests/spec-review/review-brief.sh`,
  `tests/spec-review/review-comment.sh`. For all eight the added and removed lines are identical to the pre-rebase patch.
- No line #99 added is dropped. Checking every whole line added by `git diff 070c1fa..0ff73f0` against the lines removed
  by `git diff 0ff73f0..d8e382c`, in the 11 files both touch, the only hits are five lines this PR rewrites in place and
  rewrote identically before the rebase: SOURCES.md item 6 (shown above to keep #99's text), the two generated line-count
  lines, and three lines of the header comment of `tests/spec-review/review-brief.sh`. #99's exclusively-owned files
  (`scripts/review-comment.sh`, `babysit/SKILL.md`, `playbooks/babysit.md`, `review-ladder.md`, `MANUAL.md`,
  `no-stale-wording.sh`) are untouched by the delta, so they stand as #99 left them.
- Coexistence, by running the two suites at four points:
  - `bash tests/spec-review/review-brief.sh` → `ok 476 assertions`, exit 0 at `d8e382c`; `ok 422 assertions` at `0ff73f0`.
  - `bash tests/spec-review/review-comment.sh` → `ok 150 assertions`, exit 0 at `d8e382c`; `ok 148 assertions` at `0ff73f0`.
  - Same two suites at the old base and old head: `414 → 468` and `134 → 136`.
  The difference this PR makes is `+54` brief assertions and `+2` comment assertions, the same before and after the
  rebase; the `+8` and `+14` the new base carries are #99's own cells, and they still pass with this PR's on top.

## 2. Gates at d8e382c

Every line of `AGENTS.md` "Verifying" that is not the CI fixture flow (check 5 records CI running that):

- `bash .github/shellcheck.sh factory918.sh template/.github/shellcheck.sh 'template/.claude/hooks/*.sh'
  'template/.agents/skills/*/scripts/*.sh' 'tests/*/*.sh'` → `ShellCheck 0.11.0, files checked: 20`, exit 0.
- `bash tests/shellcheck/gate.sh` → `ok 17 assertions`, exit 0.
- `bash tests/hooks/delegation.sh` → `ok 55 assertions`, exit 0.
- `bash tests/spec-review/review-comment.sh` → `ok 150 assertions`, exit 0.
- `bash tests/spec-review/review-brief.sh` → `ok 476 assertions`, exit 0.
- `bash tests/poteto-mode/overlap.sh` → `ok 57 assertions`, exit 0.
- `bash tests/spec-review/no-stale-wording.sh` → `ok: no stale wording`, exit 0.
  (That is every `tests/**/*.sh` except `fake-gh.sh` and the sourced `layout.sh`.)
- `python3 tools/check_knowledge.py` → `knowledge ok: 119 files`, exit 0.
- `python3 tools/build_knowledge.py` → `knowledge files: 119 → docs/knowledge`, exit 0; `git status --porcelain` → empty.
- `./factory918.sh sync` → `vendored: 72 skills. Review with git status, bump VERSION, commit.`, exit 0;
  `git status --porcelain` → empty.
- Patches reproduce with the `patches/README.md` command: a script under `TMPDIR` ran
  `diff -u --label a/<path> --label b/<path> research/<upstream>/<path> template/.agents/skills/<path>` for all 20
  entries of `patches/series` (upstream roots as `factory918.sh` `cmd_sync` resolves them:
  `research/3-pstack/open-pstack-claude-code-port/plugins/pstack/skills`, `research/1-matt-pocock/skills-repo/skills`,
  with `spec-review/SKILL.md` against `engineering/code-review/SKILL.md`) and compared each to the committed patch →
  `patches reproduced byte-for-byte: 20`, exit 0.

## 3. DECISIONS.md at d8e382c

- `grep -o '^| P[0-9]* | [^|]*' docs/knowledge/core/DECISIONS.md | tail -5`, exit 0:
  `P25 The design artifact on the ticket`, `P26 One shell gate, carried by the template`,
  `P27 A design hole restarts the review`, `P28 The Spec walk covers every blast-radius risk`,
  `P29 A stacked PR is opened against trunk, then retargeted`.
- Attribution by blame, `git log --oneline -L 93,97:docs/knowledge/core/DECISIONS.md`, exit 0:
  `c83f166` (only on `origin/feat/design-artifact-on-ticket` and its children) added P25 → PR #94;
  `319f0b1` (first on `origin/feat/shellcheck`) added P26 → PR #96; `0ff73f0` added P27 → PR #99;
  `769217c`, this PR, added P28 and P29. `git branch -r --contains` confirmed the branch each commit first appears on.
- No duplicate ids: `grep -o '^| P[0-9]* |' … | sort | uniq -c | awk '$1>1'` printed nothing, exit 0. The ids present
  are P1–P5 and P7–P29 (see Notes on P6).
- `template/docs/factory918/DECISIONS.md` carries the same P25–P29 rows, exit 0.
- PR body: `gh pr view 101 --repo Zenoctra/factory918 --json body -q .body | grep -nE 'P2[0-9]'`, exit 0, one hit,
  line 14: "Records: `DECISIONS.md` P28 (the walk contract) and P29 (a stacked PR is opened against trunk and
  retargeted …)". The body says P28/P29.

## 4. Live check of the walk rule at d8e382c

A throwaway project layout under `TMPDIR` (`.agents/skills/spec-review` copied from this head, `.claude/hooks/`,
`.claude/skills -> ../.agents/skills`), a cross-cutting commit adding `.claude/hooks/x.sh`, `tests/spec-review/fake-gh.sh`
on `PATH` as `gh`, and a grounding file whose risks sit under a line that is exactly `## Risks`:
`bash .agents/skills/spec-review/scripts/review-brief.sh HEAD~1 --blast-radius grounding.md` → exit 0, stdout
`ticket: #7` / `round: 1 of 3` / `.scratch/review/HEAD_1/standards-brief.md` / `.scratch/review/HEAD_1/spec-brief.md`.
The Spec brief carries the grounding under `## Blast radius` with the `## Risks` heading and both numbered risks intact,
and both rules stand in it:

- This PR's risk sentence, the tail of the `## Walk` bullet (line 70): "The diff is cross-cutting: after the lines per
  documented step, one numbered line per risk under the Risks heading of the `## Blast radius` section above, in its
  order and numbered on from the last step, each naming the risk and saying what the diff does at that risk; a risk line
  is a walk line and counts nothing."
- #99's `spec:` rule (line 79): "The same item carries a line `spec:` naming the artifact it rests on:
  `table <row>/<column>` for a cell of the ticket's scenario table, `design <signature>` for a signature or usage in its
  `## Design` sketch, or `criterion <k>` for its k-th acceptance checkbox; an item without a `spec:` line in one of those
  three forms is sent back."

The same run without a fetchable ticket printed `no spec: Standards axis only` and wrote no Spec brief, which is #99's
no-spec path behaving as it did before this PR.

## 5. CI at the new head

- `gh run list --repo Zenoctra/factory918 --branch feat/spec-walk-risks --json databaseId,headSha,status,conclusion,event`
  → exit 0. The `pull_request` run at `headSha d8e382ca37233bce98724c785ecdbb677abc4e2a` is `35765178886`,
  `status completed`, `conclusion success`. Already finished; no polling needed.
- `gh run view 35765178886 --repo Zenoctra/factory918 --json jobs` → exit 0: `Fixture | completed | success`,
  `Factory | completed | success`. The Fixture job is the `AGENTS.md` fixture flow.
- For context, the same list shows `7956c696…` (the pre-rebase head) `success` and `6add1e35…` `failure`, an older head.

## 6. PR metadata

- `gh pr view 101 --repo Zenoctra/factory918 --json headRefOid,baseRefName,mergeable,isDraft,closingIssuesReferences,title`
  → exit 0: `headRefOid d8e382ca37233bce98724c785ecdbb677abc4e2a` (matches the verified head),
  `baseRefName feat/design-hole-restart` (PR #99's branch, as a chained PR should be), `mergeable MERGEABLE`,
  `isDraft false`, `title "Make the Spec walk cover every blast-radius risk"`.
- `closingIssuesReferences`: one entry, issue **#91** only. Not empty, so the P29 workaround held and ticket #100's
  fallback reason does not apply here.

## Issues

None.

## Notes

- The records commit's own message, `769217c`, still reads "DECISIONS.md gains P26 … and P27" while the rows it adds are
  P28 and P29. `git log -1 --format=%B 769217c` confirms it. The owner's `## Chain rebase` section records why it was
  not reworded (the harness refuses a non-interactive reword and `-i` is unavailable). Text in history, not in the
  repository's content; the PR body, which reviewers read, says P28/P29.
- The round-one review comment on PR #101 cites `DECISIONS.md P26` for a noted item, which is now P28. That comment
  itself anticipated it: "Row P26 here collides with PR #96's P26 and is renumbered at the chain rebase." Posted
  comments are not edited, so nothing to fix.
- `docs/knowledge/core/DECISIONS.md` has no `P6` row: the ids run P1–P5 then P7–P29. This predates the PR (the delta adds
  only P28 and P29) and is out of its scope; worth a ticket only if the numbering is meant to be gapless.
- The owner's `## Chain rebase` account matches everything above independently: the conflict set, which side won in each
  file, the renumbering, the regeneration by `build_knowledge.py`, and the gate outputs (`476`/`150` and the rest) are
  the same figures this run produced. I read that section only after finishing checks 1 to 3.
- The three `git` calls that read `tests/spec-review/fake-gh.sh` from this head were run against throwaway repositories
  under `TMPDIR`; the worktree was left detached at `d8e382c` with `git status --porcelain` empty.
