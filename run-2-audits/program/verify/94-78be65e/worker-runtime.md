verdict: PASS+NOTES

# Slice: live runtime floor, PR #94 (ticket #89) at 78be65edc94f22b257d3c220b74482c7e884806b

Every claim below was exercised live in a detached worktree at the PR head. `git rev-parse HEAD`
printed `78be65edc94f22b257d3c220b74482c7e884806b` before anything else (exit 0). The three loads
the slice names — the section filter in `overlap.sh`, the sixth core document reaching an applied
project, and the patched skills after `sync` — all hold. Nothing on the documented path is wrong;
the four notes below are fragilities and coverage gaps, not breakage.

## (a) `overlap.sh` skips `## Testing decisions` and `## Design`

- `bash tests/poteto-mode/overlap.sh` → `ok 57 assertions`, exit 0. The suite includes the new
  case "17 tokens under ## Testing decisions and ## Design ignored"
  (`tests/poteto-mode/overlap.sh:146-156`).
- Filter in isolation, the exact pipeline at
  `template/.agents/skills/poteto-mode/scripts/overlap.sh:48-51`
  (`awk '/^## /{skip=($0 ~ /^## (Diff|Testing decisions|Design)[[:space:]]*$/)} !skip'` into the
  backtick-token `grep -oE`), run on crafted bodies. Exit 0; surviving paths:
  - body with `docs/keep-outside.md` under `## What to build`, `docs/in-diff.md` under `## Diff`,
    `docs/in-testing.md` inside a table under `## Testing decisions`, `src/in-design.txt` under
    `## Design`, `docs/after-design.md` under `## Acceptance criteria` → survivors are
    `docs/after-design.md` and `docs/keep-outside.md` only. Both ways proven: the three inside are
    dropped, the two outside are kept, and collection resumes at the next `## ` heading.
  - `## Testing decisions extra` → `docs/under-extra.md` survives (the heading is not the skipped
    one, so `skip` is cleared), as the header comment's anchored spelling documents.
  - `### Design` → `docs/under-h3-design.md` survives: `^## ` does not match a `###` line, so an h3
    never sets `skip`.
  - `### Legend` inside `## Testing decisions` → nothing survives: an h3 does not clear `skip`
    either, so subheadings inside a posted table stay skipped.
  - CRLF body (`## Testing decisions\r\n`) → nothing survives; `[[:space:]]*$` absorbs the `\r`.
- Whole script, live, against an independent fixture (real clone, bare origin, two open PRs
  `feat-a`/`docs/a.md` and `feat-z`/`src/z.txt`, a fake `gh` answering `issue view` from
  `FAKE_BODY` and `pr list` from a JSON literal, the way `tests/poteto-mode/overlap.sh:25-40`
  does). Script invoked as the playbooks do, `overlap.sh 89`:
  - A, both paths in prose → `go: none` / `#1 feat-a: docs/a.md` / `#2 feat-z: src/z.txt`, exit 1.
  - B, `src/z.txt` moved under `## Design` → `#1 feat-a: docs/a.md` only, exit 1.
  - C, both paths inside `## Testing decisions` and `## Design` → `go: none` / `paths: none` /
    `base: origin/main`, exit 0 (the empty-`paths` branch returns before `gh pr list`).
  - D, `## Testing decisions extra` → `#1 feat-a: docs/a.md`, exit 1.
  - E, `### Design` → `#2 feat-z: src/z.txt`, exit 1.
  - F, `## Design` followed by `## Acceptance criteria` → `#1 feat-a: docs/a.md`, exit 1.
  A vs C is the round-1 Would-break finding ([P1]/[S5]) closed: a posted table's example paths no
  longer become pathspecs.
- `shellcheck` 0.11.0 on `template/.agents/skills/poteto-mode/scripts/overlap.sh` and
  `tests/poteto-mode/overlap.sh`: no output, exit 0 each.

## (b) `SCENARIO-TABLE.md` ships to a project

- `cd /tmp && vp create vite:monorepo --directory fx-verify-94 --no-interactive --git --hooks
  --no-agent` → `Scaffolded fx-verify-94 with Vite+ monorepo`, exit 0 (`vp v0.3.1`).
- `./factory918.sh apply /tmp/fx-verify-94 --scaffold --profile python --name demo` from the
  worktree → completed and ran doctor.
- `ls /tmp/fx-verify-94/docs/factory918/` → `DECISIONS.md GLOSSARY.md MANUAL.md PHILOSOPHY.md
  SCENARIO-TABLE.md` (five; the new one is 11299 bytes). Criterion 6 met at the project end.
- `./factory918.sh doctor` inside the project → exit 1, with exactly two FAILs: `labels present`
  ("needs a GitHub remote") and `slots filled (/factory-start)`. Both are setup preconditions of a
  bare fixture, not regressions: `factory918.sh` does not appear in
  `git diff --stat ab47eb9 78be65e` at all, so every doctor predicate is byte-identical to the
  base. Everything the PR touches passes, including `PASS slim knowledge present` and
  `PASS ast-grep rules test`.
- `/knowledge`'s slim list in the applied project names it:
  `/tmp/fx-verify-94/.agents/skills/knowledge/SKILL.md:13` reads "this project's `docs/factory918`
  (slim: philosophy, manual, decisions, glossary and the scenario table only ...)".
- The skill's step-2 grep reaches the page: `rg -n -i -c "scenario table" docs/factory918` in the
  project → `DECISIONS.md:2`, `GLOSSARY.md:1`, `SCENARIO-TABLE.md:4`, exit 0.
- `/tmp/fx-verify-94` removed (`rm -rf`; `ls` then reports no such file).

## (c) The patched skills after `sync`

- `./factory918.sh sync` → `applied pstack/architect/SKILL.md.patch`,
  `applied pstack/architect/references/runner-prompt.md.patch`,
  `applied mattpocock/to-spec/SKILL.md.patch`, the four playbook patches, `vendored: 72 skills`.
  `git status --porcelain` afterwards → 0 lines; `git rev-parse HEAD` unchanged. The patches
  re-apply to the pins and reproduce the vendored files exactly.
- `python3 tools/check_knowledge.py` → `knowledge ok: 119 files`, exit 0;
  `python3 tools/build_knowledge.py` → exit 0, `git status --porcelain` 0 lines.
- `bash -n factory918.sh` (0), `bash tests/hooks/delegation.sh` (0),
  `bash tests/spec-review/review-comment.sh` (0), `bash tests/spec-review/review-brief.sh` (0).
- `diff docs/agents/issue-tracker.md template/docs/agents/issue-tracker.md` → no output, exit 0.
  `template/docs/factory918/SCENARIO-TABLE.md` (79 lines) is byte-identical to the core document's
  body below its generated header (88 lines); `diff` of the two → no output, exit 0.

The changed sentences, quoted, and whether an agent can follow them. None contradicts
`template/.agents/skills/poteto-mode/playbooks/ticket.md:10` (step 6).

1. `template/.agents/skills/architect/references/runner-prompt.md:7` — "With state (a file it reads
   or writes, exit codes, rounds, or more than one actor): a scenario table, then the contract
   derived from it, then the test list. ... A cell for an input outside the intended path reads
   \"refused with the tool's own message\" and costs no code. Cut such a cell only after the
   refusal was run and seen; an assumption about a tool's failure mode is a claim until then."
   Followable: the trigger is a closed list, the order of the three deliverables is fixed, the
   axes and the cell's contents are spelled out, and the cut rule names the observation that
   licenses it. Criteria 1 and 2 met.
2. `runner-prompt.md:8` — "Without state, crossing a function boundary: the usage and signature
   sketch, the caller's usage first, then the types and signatures (the discipline below)." The
   two bullets partition on state, so a runner picks one without judgment.
3. `runner-prompt.md:10` — "The orchestrator appends the synthesized first deliverable to the
   ticket before implementation, a table under `## Testing decisions`, a sketch under `## Design`
   (the Ticket playbook, step 6); the writer, the reviewer and the human read it there."
   Followable, and it names the owner (orchestrator, not the runner) and cites the step that
   carries the read-add-write-back mechanics rather than restating them.
4. `template/.agents/skills/architect/SKILL.md:32` (Phase B) — "For a design with state the package
   opens with the scenario table, its contract and its test list, and
   `references/runner-prompt.md` gives the shape." This closes round 1's [P2]: the skill each
   runner is told to read in full no longer says usage-first unconditionally. Agrees with 1 and 3.
5. `template/.agents/skills/to-spec/SKILL.md:66` — "For stateful work (a file read or written, exit
   codes, more than one actor), the shape is the scenario table: ... The table is the test list,
   one assertion per cell. It is a decision, so the rule above about paths and snippets does not
   exclude it." Followable, and the exemption now covers both halves of the rule at
   `to-spec/SKILL.md:55` ("Do NOT include specific file paths or code snippets"), closing round
   1's [S2]. "the rule above" does name a rule that is really above it.
6. The four delegation steps carry the same sentence verbatim — `feature.md:12` (step 4),
   `bug-fix.md:9` (step 3), `refactoring.md:11` (step 5), `perf-issue.md:16` (step 3): "The brief
   carries the ticket's design artifact (Ticket step 6). When it is a scenario table, the writer
   writes the test from the table before the implementation, one assertion per cell in the table's
   order, and the commit order shows it; a writer that cannot implement a cell as written stops
   and reports the cell, and never fills it in." Followable and checkable after the fact (commit
   order, assertion count). Criterion 4 met. The cross-reference resolves: `ticket.md` step 6 is
   the Testing-decisions step, and step 5, quoted elsewhere, was not renumbered.
7. `ticket.md:10` (step 6) — "read the current body into a file (`gh issue view N --json body -q
   .body`), add the section at the end with its first line `Posted by the agent <date>` ... and
   write the whole file back with `gh issue edit N --body-file`, since that command replaces the
   body and never merges. If the write fails, stop and report the error; implementation does not
   start without the artifact on the ticket. ... The step-1 check skips both sections, so a path a
   cell quotes does not count as a path the ticket names." Closes round 1's [S1] and [P4]. The
   claim it rests on is live-verified: `review-brief.sh:222` writes the whole
   `gh issue view --json body` output to `$dir/ticket.md`, so a posted table reaches the Spec
   brief with no script change.

## Issues

(none)

## Notes

1. Heading matching is case-sensitive and the repository spells the words two ways. Live case 6:
   a body headed `## Testing Decisions` (the spelling of `to-spec/SKILL.md:59`, which names the
   spec file's own section) yields `docs/capital-d.md` — not skipped. The documented path
   (`ticket.md` step 6 and `template/docs/agents/issue-tracker.md:26`) is lowercase throughout, so
   nothing on it breaks; an agent that copied the spec's capitalization when posting on the ticket
   would silently feed the table's paths back into the step-1 check. Round 2 recorded this as
   [S1]; this run is the live confirmation. A case-insensitive alternation would cost one flag.
2. `doctor`'s `slim knowledge present` check (`factory918.sh:275`) still tests only
   `docs/factory918/PHILOSOPHY.md` and `MANUAL.md`, so an `update` that failed to copy the new
   fifth document would pass the gate. The PR body says so and calls it out of scope; recorded
   here because criterion 6's guarantee inside a project is unguarded.
3. A slim project has no `docs/factory918/INDEX.md`, so the `knowledge` skill's step 1 ("Read
   `$KB/INDEX.md` whole") has nothing to open there and the new page is reached by step 2's grep,
   which I confirmed works. Pre-existing (the slim shape is documented as "no header or
   mini-TOC"), not introduced by this PR.
4. `runner-prompt.md:10` says the orchestrator "appends ... to the ticket" without the
   read-and-write-back mechanics; it cites step 6, which has them. An orchestrator acting on the
   runner prompt alone could reach for `gh issue edit --body-file` directly. The citation carries
   it, so this is a wording note, not a gap.
