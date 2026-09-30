# Phase A grounding for #110 (owner, 2026-09-22)

Ticket: `gh issue view 110 --repo Zenoctra/factory918`. Read it whole.

## The record
- `docs/knowledge/core/DECISIONS.md`, section `## Provisional (added by agents; Manuel promotes or overrules)`
  (line 66): one markdown table `| # | Decision | Choice | Reason |`, rows `| P1 | ...` to `| P30 | ...`.
  Row order is not numeric (P23 sits before P22, P2 after P22). P6 is absent; P17 is a `(promoted)` stub
  kept so its id stays. New rows are appended at the end of the section.
- Header line 3 (after the generated header) tells agents to add to Provisional; `PHILOSOPHY.md` "How to
  decide when the spec is silent" step 5 and `template/.agents/skills/knowledge/SKILL.md:26` say the same.
  None says how the id is chosen; agents took max+1 at branch time.

## The build and the check
- `tools/build_knowledge.py`: rewrites each core doc's generated header and mini-TOC in place, copies the
  core docs (minus CONVERSATION-DIGEST) header-stripped into `template/docs/factory918/`, rebuilds
  `docs/knowledge/INDEX.md`. It never reads the table contents. Max 220 lines per core doc
  (DECISIONS.md is 98 lines now).
- `tools/check_knowledge.py` (25 lines): INDEX line counts, 240-line cap, mini-TOC targets. Exit 1 on any
  miss. No id check today.
- CI: `.github/workflows/factory-ci.yml:33` runs `python3 tools/check_knowledge.py && python3 tools/build_knowledge.py && git diff --exit-code`.

## The consumers of an id
- `template/.agents/skills/spec-review/scripts/review-brief.sh:248`:
  `cites='cites: (user: "[^"]+" on #[0-9]+|DECISIONS\.md [A-Z]?[0-9]+|#[0-9]+ comment ...|#[0-9]+ '"$ref"')$'`.
  A judgment item ending in a matching `cites:` carries into later review rounds as settled; one that does
  not match is dropped. An id format outside `[A-Z]?[0-9]+` silently stops carrying unless this grammar
  changes. Tests: `tests/spec-review/review-brief.sh` (cites of `DECISIONS.md P17`, `P1`, `P16`).
- `template/.agents/skills/spec-review/SKILL.md:137` documents the form (`P17`, `19`). That file is a
  vendored copy changed only through `patches/mattpocock/spec-review.SKILL.md.patch` (listed in
  `patches/series`, described in `SOURCES.md` item 6); `./factory918.sh sync` must leave `git status` clean.
- Posted review comments on closed PRs cite `DECISIONS.md P<n>` for existing rows; those must stay valid
  (existing ids never change).
- Prose all over the repo mentions ids (`P11`, `P14`, `P24` in AGENTS.md, playbooks, ledger).

## Where the rule must be written (criterion 3)
- `template/docs/agents/issue-tracker.md` (then copied to `docs/agents/issue-tracker.md`; the two are
  identical copies).
- `template/.agents/skills/poteto-mode/playbooks/ticket.md` (ours, not a patch; edit directly). Ticket
  #105 rewrites much of this file in a parallel PR: keep the edit to one sentence or step placement that
  rebases easily.

## Facts on parallel work
- Every change reaches the repo as a PR closing one ticket (Quick ticket covers conversation work; P10).
  One ticket is one PR (Ticket step 4). The orchestrator writes DECISIONS.md itself (P11) on the PR's branch.
- The 2026-09-22 stack: #94, #96, #99, #101 (two rows, P28 and P29), #102 each took max+1; every chain
  rebase renumbered rows and prose mentions.
- Tickets are numbered above 100 now; legacy ids are P1 to P30.
