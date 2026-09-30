verdict: PASS

Re-verification of PR #94 (ticket #89) at `715100c12a8eef8d9f2eb547769404c1f9ce7ab1`, run in the isolated
worktree `.claude/worktrees/agent-a731c490f1c289084` at a detached checkout of that SHA. The three findings
the root raised at 78be65e are fixed. The delta contains nothing else. All gates and receipts pass.

## 1. Delta since 78be65e

- `git log --oneline 78be65e..715100c` → one commit, `715100c Keep the whole design artifact inside its one
  ticket section`. Exit 0.
- `git diff --stat 78be65e..715100c` → exit 0, 7 files, 24 insertions / 19 deletions:

  ```
   docs/agents/issue-tracker.md                           |  2 +-
   docs/knowledge/core/SCENARIO-TABLE.md                  |  4 ++--
   .../.agents/skills/poteto-mode/playbooks/ticket.md     |  2 +-
   template/.agents/skills/poteto-mode/scripts/overlap.sh | 11 ++++++-----
   template/docs/agents/issue-tracker.md                  |  2 +-
   template/docs/factory918/SCENARIO-TABLE.md             |  4 ++--
   tests/poteto-mode/overlap.sh                           | 18 +++++++++++-------
   7 files changed, 24 insertions(+), 19 deletions(-)
  ```

- Full diff read. Every hunk belongs to finding 2: the one-section rule added to `ticket.md` step 6, both
  `issue-tracker.md` copies and both `SCENARIO-TABLE.md` copies; a header-comment reflow in
  `overlap.sh` and in the test saying the skip runs "up to the next `## ` heading"; and the check-17
  fixture gaining a `### Contract` part that quotes `src/x/y.txt`, with the check's label updated to name it.
  **The awk line itself is unchanged** — no executable behavior moved in this commit. No `check`/`same` call
  was added or removed.
- Findings 1 and 3 were PR-body edits, so they correctly leave no commit. **Nothing beyond the three fixes.**

## 2. Finding 1 — closing references

- `gh api graphql -f query='{repository(owner:"Zenoctra",name:"factory918"){pullRequest(number:94){closingIssuesReferences(first:10){nodes{number state}}}}}'`
  → exit 0:
  `{"data":{"repository":{"pullRequest":{"closingIssuesReferences":{"nodes":[{"number":89,"state":"OPEN"}]}}}}}`
  **Only #89.**
- `gh pr view 94 --repo Zenoctra/factory918 --json body -q .body` (66 lines) then
  `grep -nEio '(close[sd]?|fix(es|ed)?|resolve[sd]?)[^A-Za-z0-9]{0,4}#[0-9]+'` → exit 0, one hit:
  `61:Closes #89`. No other closing keyword before a `#`.
- Every `#N` in the body inspected (`grep -nEo '.{0,40}#[0-9]+'`): #42, #87, #92, #90, #96, #88, #89. The
  formerly offending line now reads, at body line 37: "PR #96 is the PR for ticket #88, which the
  `autopilot-stack` go covers" — a reference with no closing verb.

## 3. Finding 2 — the one-section rule

### (a) The rule, quoted from the SHA

- `template/.agents/skills/poteto-mode/playbooks/ticket.md:10` (step 6): "The whole artifact (the legend,
  the table, the contract and the test list, or the usage and the signatures) stays inside that one section,
  its parts under `###` headings, because the skip ends at the next `## ` heading."
- `docs/agents/issue-tracker.md:26` and `template/docs/agents/issue-tracker.md:26` (identical — `diff`
  exit 0): "Each section holds the whole artifact, with `###` headings for its parts, since the overlap
  check skips a section up to the next `## ` heading."
- `docs/knowledge/core/SCENARIO-TABLE.md:45` and `template/docs/factory918/SCENARIO-TABLE.md:36`: "The
  whole artifact stays inside the one section, its parts (the legend, the table, the contract, the test
  list) under `###` headings, because the skip ends at the next `## ` heading."
- `SCENARIO-TABLE.md` also records, in "The #42 example": "#42's record was written before this rule, so
  its table and contract sit under their own `## ` headings there. A table posted from now on keeps them
  under `###` inside the one section."

**Can an agent follow it?** Yes. The rule states the action (keep the artifact in one `## ` section, parts
under `###`), names the parts explicitly in the playbook the agent executes, and gives the mechanical
reason (the skip ends at the next `## ` heading), so an agent can check its own output against it without
reading the script. It lands in step 6 of the playbook that does the posting, not only in reference prose.

### (b) The shipped awk over two bodies

The awk as shipped, `template/.agents/skills/poteto-mode/scripts/overlap.sh:49`:

```
outside="$(printf '%s\n' "$body" | awk '/^## /{skip=($0 ~ /^## (Diff|Testing decisions|Design)[[:space:]]*$/)} !skip')"
```

- Over **#42's live body** (`gh issue view 42 --repo Zenoctra/factory918 --json body -q .body`, exit 0;
  its `## ` headings are Problem, Decision, Acceptance criteria, Testing decisions, Scenario table,
  Contract — no `### ` headings anywhere): 27 tokens survive the skip. 23 of them come from lines 36-end,
  i.e. from the sibling `## Scenario table` and `## Contract` sections: `.claude/state/program`,
  `GIT_LITERAL_PATHSPECS=1`, `+refs/heads/<h>:refs/remotes/origin/<h>`, `closingIssuesReferences`,
  `origin/main`, `nearest`, `--diff`, `gh`, `{a,b}`, `G`, `L`, `L(j)`, `L(k)`, `L(k1)`, `L(k2)`,
  `B(x)`, `B(main)`, `B(origin/main)`, `base:`, `N`, `#`, `#9`, `#N`. Only `###` and `main` survive from
  `## Testing decisions` itself, so **the skip works but ends at `## Scenario table`, exactly as claimed.**
- Over a **body shaped by the new rule** (scratch fixture: `## Problem` quoting `docs/outside.md`, then
  `## Testing decisions` containing `### Legend`, `### Scenario table` quoting `docs/a.md`, `### Contract`
  quoting `src/x/y.txt`, `### Test list` quoting `tests/poteto-mode/overlap.sh`, then `## Design` quoting
  `src/z.txt`, then `## Blocked by`): exactly one token survives — `docs/outside.md`. Exit 0. Every `###`
  part is skipped and the skip correctly releases at `## Blocked by`.

### (c) #42's amended paragraph

Quoted from the live body: "Amended 2026-09-22 by #89: the check skips a `## Testing decisions` or
`## Design` section as it skips `## Diff`, up to the next `## ` heading (row 7 and the contract's 'Named
paths'), so a table posted inside that one section, its parts under `###`, adds no paths the ticket names;
no assertion changed, one added. This record predates that rule: its table and contract sit under their own
`## ` headings, so a check run on this ticket still counts the paths they quote."

**True of the shipped awk** (verified by the new-rule fixture in (b): a `###` part adds nothing) **and true
of #42's own body** (verified in (b): 23 tokens from its `## Scenario table` and `## Contract` do survive).
The earlier version of this amendment claimed the opposite for #42; the amendment no longer overstates, and
it does not re-level Manuel's approved `## ` headings.

### (d) The test and the bite proof

- `bash tests/poteto-mode/overlap.sh` at 715100c → `ok 57 assertions`, exit 0.
- Bite proof as briefed, in a scratch copy of `template/` and `tests/` (tracked files untouched; confirmed
  by an empty `git status --porcelain` at the end). Reducing the alternation to `(Diff)` in the copy's
  `overlap.sh:49` and running the copy's test:

  ```
  FAIL 17 tokens under ## Testing decisions (with ### parts) and ## Design ignored
    got:    exit 1: go: none
  #1 feat-a: docs/a.md
  #2 feat-b: src/x/y.txt src/z.txt
  #4 feat-b2: src/z.txt
    wanted: exit 0: go: none
  paths: none
  base: origin/main
  exit=1
  ```

- Sharper bite, to prove the **new** `### Contract` fixture is itself load-bearing rather than riding on the
  pre-existing assertion: in the same scratch copy, only the skip's boundary was loosened
  (`/^## /{...}` → `/^#/{...}`, alternation intact), so the skip ends at the first `###` instead of the next
  `## `. Check 17 fails on the new part alone:

  ```
  FAIL 17 tokens under ## Testing decisions (with ### parts) and ## Design ignored
    got:    exit 1: go: none
  #2 feat-b: src/x/y.txt
    wanted: exit 0: go: none
  paths: none
  base: origin/main
  exit=1
  ```

  `src/x/y.txt` is the path the `### Contract` part quotes and the path fixture PR #2 touches. The new
  assertion pins the documented boundary and nothing else.
- Scratch copy deleted; `git status --porcelain` empty and `git rev-parse HEAD` still 715100c.

## 4. Finding 3 — the PR body's sign-off

`tail -8` of the body:

```
Closes #89

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Claude Fable 5.1 on Claude Code
```

The attribution line is followed by the model-and-harness line. **Fixed.**

## 5. Gates at the SHA

All run from the worktree at the detached 715100c.

- `bash -n factory918.sh` → exit 0, no output.
- `bash tests/hooks/delegation.sh` → `ok 55 assertions`, exit 0.
- `bash tests/poteto-mode/overlap.sh` → `ok 57 assertions`, exit 0.
- `bash tests/spec-review/layout.sh` → exit 0, no output.
- `bash tests/spec-review/no-stale-wording.sh` → `ok: no stale wording`, exit 0.
- `bash tests/spec-review/review-brief.sh` → `ok 334 assertions`, exit 0.
- `bash tests/spec-review/review-comment.sh` → `ok 82 assertions`, exit 0.
- (`tests/spec-review/fake-gh.sh` skipped per brief; it is a fixture, not a test.)
- `python3 tools/check_knowledge.py` → `knowledge ok: 119 files`, exit 0.
- `python3 tools/build_knowledge.py` → `knowledge files: 119 → docs/knowledge`, exit 0; then
  `git status --porcelain` → empty, exit 0.
- `./factory918.sh sync` → exit 0, 20 `applied` lines, no `FAILED`, `vendored: 72 skills`; then
  `git status --porcelain` → empty, exit 0.
- `shellcheck` 0.11.0 on the two `*.sh` changed across the whole PR
  (`git diff --name-only ab47eb9..715100c -- '*.sh'` → `template/.agents/skills/poteto-mode/scripts/overlap.sh`,
  `tests/poteto-mode/overlap.sh`) → exit 0, no output.
- The seven patches the PR touches, regenerated with the `patches/README.md` command
  (`diff -u --label a/<path> --label b/<path> research/<upstream>/<path> template/.agents/skills/<path>`)
  against the pins under `research/3-pstack/open-pstack-claude-code-port/plugins/pstack/skills` and
  `research/1-matt-pocock/skills-repo/skills`, then `cmp` against the tracked file — all byte-identical,
  script exit 0:

  ```
  same  patches/mattpocock/to-spec/SKILL.md.patch
  same  patches/pstack/architect/SKILL.md.patch
  same  patches/pstack/architect/references/runner-prompt.md.patch
  same  patches/pstack/poteto-mode/playbooks/bug-fix.md.patch
  same  patches/pstack/poteto-mode/playbooks/feature.md.patch
  same  patches/pstack/poteto-mode/playbooks/perf-issue.md.patch
  same  patches/pstack/poteto-mode/playbooks/refactoring.md.patch
  ```

## 6. Receipts

- `gh pr view 94 --repo Zenoctra/factory918 --json comments` → three comments, all by `Zenoctra`; the third
  is https://github.com/Zenoctra/factory918/pull/94#issuecomment-5779823400 at 2026-09-22T16:07:32Z. Its
  last two lines are `round: 3 of 3` and `act-on items: 0`; both reports inside carry `hard findings: 0`
  and the judgment's Act on / Ask / Consider / Noted / Dismissed sections are all empty. Its opening is two
  plain sentences for a person, and it ends with the model-and-harness line.
- `gh run view 35751505990 --repo Zenoctra/factory918 --json headSha,conclusion,status,event,workflowName,url`
  → exit 0: `Factory CI`, event `pull_request`, `headSha` `715100c12a8eef8d9f2eb547769404c1f9ce7ab1`,
  status `completed`, conclusion **`success`**.
- `gh pr view 94 --repo Zenoctra/factory918 --json headRefOid,baseRefName,isDraft,mergeable,state` → exit 0:
  `{"baseRefName":"main","headRefOid":"715100c12a8eef8d9f2eb547769404c1f9ce7ab1","isDraft":false,"mergeable":"MERGEABLE","state":"OPEN"}`.
  Head matches the SHA under review; base `main`; not a draft; mergeable; open.

## Issues

None.

## Notes

1. The commit changes no executable line. `overlap.sh:49` is byte-identical to 78be65e; only its header
   comment and the surrounding documents moved. The behavior the three documents now describe was already
   the behavior — the fix is that the prose and the ticket-body shape stopped contradicting it.
2. #42's live body still leaks 23 tokens past the skip, because its table and contract sit under sibling
   `## ` headings. One of them, `.claude/state/program`, is a real repository path, so an `overlap.sh 42`
   run today would count it as a path the ticket names. This is now stated on #42 and in
   `SCENARIO-TABLE.md` rather than denied, which is what the finding asked for; #42 is closed and no PR
   will branch from it, so the leak is inert. Flagging it only so the next reader of #42 is not surprised.
3. The new fixture is falsifiable in the precise direction the rule claims: loosening the skip's boundary
   to any heading level (alternation untouched) makes check 17 fail with exactly the `### Contract` path,
   `#2 feat-b: src/x/y.txt`. The briefed bite proof (alternation reduced to `Diff`) also fails the check
   but would have failed it before this commit too, so the sharper variant is the one that proves the
   addition earns its place.
4. Verification was read-only throughout: a detached checkout in this agent's own worktree, all writes
   under the session scratchpad and this report directory, nothing touched on GitHub.

Claude Opus 5 (1M context) on Claude Code
