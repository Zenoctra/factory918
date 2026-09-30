# Explorer 3 — prose surfaces and vendoring mechanics (ticket #90)

All paths are relative to the worktree root
`/Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.claude/worktrees/agent-a7e863dda12fb2374`.

### Components Found

**1. `template/.agents/skills/spec-review/SKILL.md` (155 lines).** The one prose surface that defines rounds, the three marks and carry-forward.

- **Step 1, "Pin the fixed point"** — lines 17–29. The round rule is line 25, one paragraph:

  > One PR gets at most three rounds, and a round is over when its comment is posted. The script reads the branch's PR comments that carry a line `act-on items:` (`gh pr view --json comments`); the round is one more than the highest `round: N of 3` line among them (a comment without one is round 1), so a comment rebuilt in the same round does not advance it. It writes the round to `<dir>/round`, prints `round: N of 3`, and exits 1 before writing any state when three rounds were run: what remains under Act on is then fixed on this PR and marked `fixed: <sha>` (step 5), not reviewed in a fourth round. […] `--round N` sets the round directly and `--previous FILE` supplies the earlier review comments from a file instead of `gh`, for a branch whose PR is elsewhere.

  Line 27 holds the cross-cutting/blast-radius rule; line 29 the sweep form (`--paths`/`--commits`).
- **Step 4, "Spawn both sub-agents in parallel"** — lines 66–110. Line 76 is the settled-item carry-forward bullet (`## Settled in earlier rounds`, from round two on, "verbatim, in comment order and each line once", the fixed paragraph, "An item without a citation is dropped", "never what to find: a brief that named an expected result would be leading the witness"). Line 77 is the `## Report` bullet: the hard-finding definition verbatim, Manuel's five quoted sentences, then line 84's step rule (`Documented step:` / `Result:`) and count rule (`hard findings: N`). Lines 86–95 the Standards brief's four headings; lines 97–106 the Spec brief's four headings (`## Walk`, `## Would break`, `## Fails open`, `## Not asked for`). Line 110 the two reviewer role descriptors.
- **Step 5, "Judge"** — lines 112–134. Line 114 points at `../interrogate/references/lead-judgment.md`. Lines 116–122: the five judgment headings (`## Act on`, `## Ask`, `## Consider`, `## Noted`, `## Dismissed`). Line 124: the `1. [S2] **Title.** reason` item form and the numbering rule. Line 126: Fix-alongside routing. Line 128: the Ask-answered rerun ("that is the same round, not a new one"). **Lines 130–134 are the three trailing fields**, introduced by line 130 "Three trailing fields, each with one grammar:":
  - line 132 `cites: <decision>` — Noted/Dismissed only, one of `user: "<quoted words>" on #N`, `DECISIONS.md <row id>` (`P17`, `19`), `#N comment <YYYY-MM-DD>`. "Nothing else counts. Only a cited item carries into every later round's briefs as settled […] An item you cannot cite is not settled, however sure you are."
  - line 133 `ticket: #N` — Act on only, out of scope, not counted.
  - line 134 `fixed: <sha>` — Act on only, not counted; "At round three the Act on items are fixed on this PR by a fix lane […] Manuel's rule is that after three passes the rest is found the hard way. An Ask item is never fixed or filed away; it waits for the human."

  This is the list a `hole: <spec ref>` mark would join; it is a four-item list after the change, and the introducing sentence ("Three trailing fields") is itself a count that would have to change.
- **Step 6, "Aggregate"** — lines 136–146. Line 138 is the output contract: `round: N of 3` from `<dir>/round`, then "the final line `act-on items: N`, where N is the number of items under `## Act on` without a `fixed:` or `ticket:` field plus the number under `## Ask`; […] Zero is written as `act-on items: 0`. Babysit reads this line, so it is always present and always last." Line 140 is the refusal list. Line 142 the rerun-from-dir form. Line 146 the signature rule.

**2. The vendoring pair.** `patches/mattpocock/spec-review.SKILL.md.patch` (139 lines) + `patches/series:17` (`mattpocock/spec-review.SKILL.md.patch`, last in the series). The upstream is `research/1-matt-pocock/skills-repo/skills/engineering/code-review/SKILL.md`, 87 lines.

**3. `template/.agents/skills/poteto-mode/playbooks/ticket.md`** — a `keep_file` (ours, never patched). 24 lines, two sections: "### Ticket" (steps 1–9 at lines 5–13, Reply at 15) and "### Quick ticket" (lines 17–24).

**4. Babysit's two merge-ready surfaces**, both patched:
- `template/.agents/skills/poteto-mode/playbooks/babysit.md:16` ← `patches/pstack/poteto-mode/playbooks/babysit.md.patch:7`
- `template/.agents/skills/babysit/SKILL.md:40` ← `patches/pstack/babysit/SKILL.md.patch:8`

**5. `template/docs/agents/review-ladder.md`** — 13 lines; rung 1 is line 6. There is **no** `docs/agents/review-ladder.md` at the factory root (`docs/agents/` holds only `domain.md`, `issue-tracker.md`, `ledger.md`, `triage-labels.md`).

**6. Design-phase skills** a hole would return to: `template/.agents/skills/architect/SKILL.md` (Phase B at lines 30–42), `template/.agents/skills/architect/references/runner-prompt.md` (20 lines), `template/.agents/skills/arena/SKILL.md` (Phases A–F, lines 23–68), `template/.agents/skills/interrogate/references/lead-judgment.md` (58 lines).

**7. Records surfaces:** `docs/knowledge/core/DECISIONS.md` (Provisional at line 66, rows 70–93), `docs/agents/ledger.md`, `docs/M0-findings.md`.

**8. Tests that pin prose:** `tests/spec-review/no-stale-wording.sh` (13 lines), `tests/spec-review/layout.sh` (27 lines, a sourced helper, no assertions).

---

### Flow

#### A. How a round runs end to end, as the prose describes it

1. **Round number.** `SKILL.md:25` → `review-brief.sh` reads the PR author's comments containing a line `act-on items:`, takes `max(round: N of 3) + 1`, writes `<dir>/round`, prints `round: N of 3`, exits 1 at four. Implementation echoes: `review-brief.sh:127` (comment), `:135` (`/^round: [0-9]+ of 3$/`), `:141` (the refusal string), `:145` (`echo "round: $round of 3"`).
2. **Carry-forward into the briefs.** `SKILL.md:76` → `review-brief.sh:146–161`: from every earlier comment's `## Judgment` section, the `## Noted` and `## Dismissed` numbered items matching the regex at `review-brief.sh:151`:

   ```
   cites='cites: (user: "[^"]+" on #[0-9]+|DECISIONS\.md [A-Z]?[0-9]+|#[0-9]+ comment [0-9]{4}-[0-9]{2}-[0-9]{2})$'
   ```

   The regex is anchored at end-of-line, so `cites:` must be the last field on the item's line. It prints `settled: carried N, dropped M without a citation` (`:160`). **There is no table / `## Design` / criterion alternative in that grammar today** — the three alternatives are the only ones, in the script and in `SKILL.md:132` alike.
3. **Reports.** Step 4 briefs; each report ends `hard findings: N`.
4. **Judgment.** Step 5 sorts every report item into the five buckets and attaches at most one trailing mark (`cites:`, `ticket:`, `fixed:`).
5. **Count.** Step 6 / `review-comment.sh:157–158`:

   ```
   echo "round: $round of 3"
   echo "act-on items: $((act - fixed_here - ticketed + ask))"
   ```

6. **Consumers of the count.** `babysit.md:16`, `babysit/SKILL.md:40`, `template/docs/agents/review-ladder.md:6`, `docs/knowledge/core/MANUAL.md:103` (= `template/docs/factory918/MANUAL.md:84`).

#### B. Which of `spec-review/SKILL.md` is upstream and which is ours

The patch `patches/mattpocock/spec-review.SKILL.md.patch` rewrites six regions. Reading the patch's `-`/`+` sides against the 155-line template file:

| Template lines | Origin |
|---|---|
| 1–4 frontmatter | upstream, with `name: code-review` → `name: spec-review` (patch lines 3–8); the `description:` is upstream verbatim |
| 6–13 (two axes, parallel sub-agents, issue-tracker sentence) | upstream verbatim |
| 15–19 (`## Process`, step 1 heading, "Whatever the user said…") | upstream verbatim |
| **21–29** (`review-brief.sh`, round rule, blast radius, sweep) | **ours** (patch lines 10–24) |
| 31–37 (step 2 list items 1–3) | upstream |
| **38, 40** (the "no spec: Standards axis only" item and the ticket-author-comments sentence) | **ours** (patch lines 29–36) |
| 42–64 (step 3, the whole Fowler smell baseline) | upstream verbatim |
| 66 (`### 4.` heading) | upstream |
| **68–110** (both briefs, headings, report shape, reviewer descriptors) | **ours** (patch lines 41–99) |
| **112–134** (`### 5. Judge`, the five buckets, the three trailing fields) | **ours** (patch lines 101–123) |
| **136–146** (`### 6. Aggregate`) | **ours**, replacing upstream's `### 5. Aggregate` (patch lines 74–85 delete the upstream three-line step) |
| 148–155 (`## Why two axes`) | upstream verbatim |

So **every line ticket #90 wants to touch (step 5's trailing fields, step 6's count, step 1's round rule) is already inside a `+` hunk of the patch.** There is no upstream text in those regions.

#### C. How `factory918.sh sync` applies patches

`factory918.sh:379–405`, `cmd_sync()`. The relevant lines:

```
385	  local keep_files="poteto-mode/playbooks/ticket.md poteto-mode/scripts/overlap.sh spec-review/scripts/review-brief.sh spec-review/scripts/review-comment.sh"
386	  local tmp; tmp="$(mktemp -d)"
387	  for k in $keep_files; do mkdir -p "$tmp/keep/$(dirname "$k")"; cp "$skills/$k" "$tmp/keep/$k"; done
...
391	  rm -rf "$skills/spec-review"; cp -R "$matt/engineering/code-review" "$skills/spec-review"
392	  for k in $keep_files; do mkdir -p "$skills/$(dirname "$k")"; cp "$tmp/keep/$k" "$skills/$k"; done
...
395	  while read -r p; do
396	    [ -n "$p" ] || continue
397	    if git -C "$skills" apply --check "$F918_DIR/patches/$p" 2>/dev/null; then git -C "$skills" apply "$F918_DIR/patches/$p"; echo "applied  $p"
398	    else echo "FAILED   $p (upstream moved; rewrite the patch)"; failed=1; fi
399	  done < "$F918_DIR/patches/series"
```

Order: keep_files saved to a temp dir → every vendored skill dir blown away and recopied from `research/` (line 388 pstack, 389–390 matt, **391 `spec-review` ← `research/1-matt-pocock/skills-repo/skills/engineering/code-review`**) → keep_files restored (392) → patches applied in `patches/series` order with `git apply` from inside `template/.agents/skills` (395–399). `git apply --check` first; a patch that no longer applies prints `FAILED` and sets `failed=1` (the command's exit code), it does not abort the loop.

The four `keep_files` — including `poteto-mode/playbooks/ticket.md` and both spec-review scripts — are **ours**: they survive the wipe and no patch describes them. `spec-review/SKILL.md` is **not** a keep_file; it is regenerated from the upstream 87-line file and then rebuilt by the patch.

#### D. Answer: patch, template, or both?

**Both, in the same commit.** `sync` overwrites `template/.agents/skills/spec-review/SKILL.md` from the upstream pin and replays the patch, so:

- edit only the **template** file → `./factory918.sh sync` reverts the edit, `git diff` is non-empty → CI fails.
- edit only the **patch** → the template file on disk (what agents actually read, via `.claude/skills` → `template/.agents/skills`) does not have the change, and `sync` would introduce it → `git diff` non-empty → CI fails.

The check is `.github/workflows/factory-ci.yml:34–35`:

```
      - name: Vendored skills equal the pins plus the patches
        run: ./factory918.sh sync > /dev/null && git diff --exit-code && test -z "$(git status --porcelain template)"
```

(`AGENTS.md` "Verifying" states the same as `./factory918.sh sync` leaves `git status` clean.) There is a second, independent generated-file gate at `factory-ci.yml:32–33` (`python3 tools/check_knowledge.py && python3 tools/build_knowledge.py && git diff --exit-code`) that catches a `docs/knowledge/core/*.md` edit without a rebuild.

**Precedent.** `git log --oneline -- patches/mattpocock/spec-review.SKILL.md.patch` shows 12 commits; each also touches the template file:

- `e5df74c` "Give the sentence that introduces Manuel's five quotes a subject" — exactly two files, `patches/mattpocock/spec-review.SKILL.md.patch` (1 line) and `template/.agents/skills/spec-review/SKILL.md` (1 line).
- `82dc11e` "Read only the PR author's review comments, fix round three on the PR, and sign the comment" — the full shape of a change like #90's: `AGENTS.md`, `SOURCES.md`, three patches (`spec-review.SKILL.md.patch`, `babysit/SKILL.md.patch`, `poteto-mode/playbooks/babysit.md.patch`), the three matching template files, both spec-review scripts, `template/AGENTS.md`, `template/docs/agents/review-ladder.md`, and both tests. Fourteen files, one commit.

`SOURCES.md` item 6 (line 18) is the prose description of what the spec-review patch does; item 4 (line 16) describes the babysit playbook patch; item 12 (line 24) the babysit SKILL patch. `82dc11e` changed `SOURCES.md` alongside the patches, so item 6 is maintained in lockstep and would need the `hole:`/`spec:`/restart sentences added.

#### E. `template/.agents/skills/poteto-mode/playbooks/ticket.md` — where a "return to architect" step sits

Steps as they stand (each one numbered line):

- **5** (line 9): "Select by content and run that playbook's steps verbatim from step 1: new behavior → Feature; a defect → Bug fix; a behavior-preserving change → Refactoring; measured slowness → Perf issue. `how` and `why` over the affected subsystem come first in all of them." Then the cross-cutting clause: the `.claude/hooks/` / `.claude/settings.json` / `.agents/skills/factory918/` predicate, `blast-radius` into `.scratch/<ticket>/blast-radius.md`, "Such a change never skips `architect`", and "The PR body's `## Blast Radius` section is that file verbatim, and `review-brief.sh` refuses to brief the diff without it."
- **6** (line 10): "The spec's **Testing decisions** are the pre-agreed seams. `tdd` there, and nowhere the spec did not agree unless a criterion needs it."
- **7** (line 11): "Verify on the matching surface per `docs/agents/evidence.md`; the primary agent runs the project's `verify-<app>` skill once after integrating."
- **8** (line 12): `overlap.sh N --diff` → the PR body's `## Overlap` section; then **Opening a PR**; "The last line before the attribution is `Closes #N`."
- **9** (line 13): "Babysit to merge-ready per `playbooks/babysit.md`. Never merge."
- Line 15 is the **Reply:** contract: "the ticket, the criteria and how each was proven, what the ticket did not settle and what you chose, the PR URL."

A "return to architect Phase B and restart the review from round one" step has no home in 1–9 today: step 9 is the last and delegates wholly to `babysit.md`. The natural insertion is a new step between 9 and the Reply line (a step 10, "when the review returns a hole"), or a nested clause under step 9, since babysit is where the `act-on items` line is read. Note the playbook never mentions rounds or `act-on items` at all — the only round prose in the ticket flow is inside `babysit.md:16` and `review-ladder.md:6`. Also note that step 5's *architect* reference is indirect: it names the four downstream playbooks, and only the cross-cutting clause says "never skips `architect`"; the `architect` invocation itself lives in `playbooks/feature.md` step 2, `bug-fix.md` step 3, `refactoring.md` step 3, `perf-issue.md` step 3 (per `SOURCES.md:25`, patch item 13).

Ticket.md is a `keep_file`, so it is edited directly with no patch.

#### F. Babysit's merge-ready sentences, verbatim

`template/.agents/skills/poteto-mode/playbooks/babysit.md:16` (an indented paragraph inside step 6):

> Merge-ready also needs the `spec-review` comment on the PR's latest commit to read `act-on items: 0`. A nonzero count, or no review comment on the latest commit, is a blocker of the same class as a red check, and the fix lands on this PR. Step 4's follow-up PR is not the route for it unless the reviewed PR has already merged. The review runs at most three rounds on one PR; a comment reading `round: 3 of 3` and `act-on items: 0` makes the PR review-ready even when the fix commits it names come after the reviewed commit. An item under `## Ask` in that comment waits for the human and is not fixed on the PR; once the human answers, the orchestrator re-sorts it in the judgment with the answer as its reason and reruns `scripts/review-comment.sh <dir>` on the same reports, which is the same round.

`template/.agents/skills/babysit/SKILL.md:40` (first bullet of step 4, "When to stop"):

> - Build is green, every comment resolved, the `spec-review` comment on the latest commit reads `act-on items: 0`, branch merges cleanly → call it ready. The review runs at most three rounds on one PR; a comment reading `round: 3 of 3` and `act-on items: 0` makes the PR review-ready even when the fix commits it names come after the reviewed commit. An item under `## Ask` in that comment waits for the human and is not fixed on the PR; once the human answers, the orchestrator re-sorts it in the judgment with the answer as its reason and reruns `scripts/review-comment.sh <dir>` on the same reports, which is the same round.

Both are `+` lines of their patches (`patches/pstack/poteto-mode/playbooks/babysit.md.patch:7`, `patches/pstack/babysit/SKILL.md.patch:8`), so both would need the patch+template pair if touched. **Neither sentence names `hole:` or a restart; a PR with no hole reads exactly the same, so criterion 7 ("babysit's merge-ready condition stays unchanged") is satisfied by leaving both lines byte-identical.** The adjacent, unpatched `babysit/SKILL.md:41` is a *different* three-round rule — "You've run three rounds of fix → push → recheck and it still isn't fully green" — upstream text about CI fix rounds, not review rounds; it is easy to confuse with the review cap.

#### G. `template/docs/agents/review-ladder.md` rung 1, verbatim (line 6)

> - **Rung 1 — spec-review.** After CI is green, the agent runs `spec-review` in a fresh context: the Standards axis reads `CODING_STANDARDS.md`; the Spec axis reads the originating ticket and its parent spec. Each axis counts two kinds of finding: the documented path gives a wrong or silent result, or an input outside it proceeds silently (fails open); an input outside the documented path that is refused with a message saying how to correct it is not a finding, it is the design, and zero items is the expected result for a clean change. A cross-cutting diff's review brief also carries its blast radius, the PR body's `## Blast Radius` section, and the review does not start without one. Act-on items get fixed; the rest are recorded in the PR body. The report is posted as a comment on the PR, names the commit it reviewed, and ends with the lines `round: N of 3` and `act-on items: N`. One PR gets at most three rounds, and the review stops earlier at `act-on items: 0`; a comment reading `round: 3 of 3` and `act-on items: 0` makes the PR review-ready even when the fix commits it names come after the reviewed commit. An Ask item waits for the human. Fixes land on the PR that was reviewed, never on a PR above it. On a stack, the chain above the fix is rebased onto it and re-verified. A finding outside the PR's scope becomes a ticket, not a commit here. A long review comment opens with two plain sentences for a person, per `AGENTS.md` "Pull requests". Fallback if the skill is missing: Claude Code's built-in `/code-review`.

Context lines: `:3` "Each rung runs only if its precondition exists. Missing rungs are skipped, never failed."; `:5` rung 0 (CI); `:7` rung 2 (external bot); `:8` rung 3 (`interrogate`); `:9` rung 4 (human); `:11–13` "## External bots configured for this repo" / "(none)".

`review-ladder.md` is **not** a vendored/patched file — it is the factory's own document under `template/docs/agents/`, edited directly.

**Root copy:** none. `docs/agents/` at the factory root holds `domain.md`, `issue-tracker.md`, `ledger.md`, `triage-labels.md` only. `AGENTS.md:51` ("## Agent skills", lines 49–51) says:

> The issue tracker this repository uses, and how skills read and write it, is `docs/agents/issue-tracker.md`. Domain documentation layout is `docs/agents/domain.md`; the triage label vocabulary is `docs/agents/triage-labels.md`. All three are the template's copies; edit them under `template/docs/agents/`, then copy.

That rule names exactly those three files. `review-ladder.md` has never been copied to the root, so editing `template/docs/agents/review-ladder.md` alone is complete for the factory (there is nothing to copy). Confirmed against `82dc11e`, which changed `template/docs/agents/review-ladder.md` and no root counterpart.

**Does `apply` copy `template/docs/agents/` into projects?** Yes — indiscriminately. `factory918.sh:131–141`:

```
131	  (cd "$TEMPLATE" && find . -type f ! -name '.gitkeep' -print0) | while IFS= read -r -d '' rel; do
...
136	    if [ ! -e "$dir/$rel" ] || [ -n "$owned" ]; then
137	      mkdir -p "$dir/$(dirname "$rel")"; cp -p "$TEMPLATE/$rel" "$dir/$rel"
138	    fi
```

Every file under `template/` that does not already exist in the project is copied and hashed into `.factory918/manifest.json`. Only `package.scripts.json` and `.gitignore.factory` are excluded (line 133), and only `FACTORY_OWNED="AGENTS.md CLAUDE.md vite.config.ts .vite-hooks/pre-commit"` (line 35) is force-overwritten under `--scaffold`. So `template/docs/agents/review-ladder.md` lands at `<project>/docs/agents/review-ladder.md`, which is the path `babysit.md:8` and `MANUAL.md:95` read.

#### H. What a scoped architect re-run would take

`architect/SKILL.md` Phase B (lines 30–42):

- line 32: "Run the **arena** skill with the design-sketch task and the Phase A grounding artifacts. Pass `references/runner-prompt.md` as each runner's prompt. Each candidate produces a design package shaped per `references/rationale-template.md`: the caller's usage written first, then the type sketch, function signatures, module map, and prose rationale derived from it."
- line 34: "Use your configured architect runners (defaults `claude:fable@max`, `codex:gpt-5.6-sol@max`, `grok:grok-4.6@xhigh`, `claude:opus@xhigh`)." Manuel's sheet overrides this with `architect runners: claude:fable@high, claude:opus@high` — **two** runners.
- line 36: "Design it twice. Require at least two structurally distinct candidates before synthesis, even when the first looks sufficient."
- line 38: screen against `references/design-red-flags.md`; line 40: compare on interface depth; line 42: "Arena returns one synthesized design package."
- Phase A (lines 22–28) is `how` + optional `why`; "Skip Phase A only when the work is genuinely greenfield." Phase C (44–52) is opt-in checkpoint; line 52: "If the human pushes back on the shape (in a checkpoint or after the fact), treat that as Phase A evidence. Re-ground and re-run Phase B before writing more code." — **this is the closest existing sentence to "a design hole returns to Phase B"**, but it is triggered by the human, not by a review finding. Phase E (60–80) is the scrap path; its step 4 (line 80) is literally "Return to Phase B and re-run arena", triggered by a *pattern* of implementation friction (line 73: "The signal is a *pattern*, not single instances").

`arena/SKILL.md`:

- Phase A step 3 (line 29): "Pick the runners. Use `arena runners` from the current harness's pstack model sheet when present. Otherwise default to `claude:fable@max`, …. Spawn more when the arena covers multiple design directions. Same descriptor N times when the work is generation-bound rather than judgment-sensitive."
- Phase C, Cross-judge (line 42): "After all Phase B candidates complete, choose the judge descriptor from `arena cross-judge pool` … Dispatch one read-only judge through the provider contract. It sees the rubric and completed candidates by path label, scores each criterion, and recommends a base with rationale. It runs in parallel with the parent's reading in Phase D."
- **There is no "skip the judge" clause in arena today.** Phase C reads as unconditional. The nearest thing is Phase E (line 62): "When N candidates converge on the same shape, that is a strong agreement signal. Note the convergence in the record and ship the consensus shape. No graft is needed." — that skips the *graft*, not the judge. So "two runners; the judge is skipped when they converge" is a **new** rule that has no current textual home in `arena/SKILL.md`; it would be stated by the caller (the hole-restart step) rather than found in arena.
- `architect/references/runner-prompt.md` (20 lines) is the per-runner prompt: caller's usage first, data structures first, interface depth, shared state, visible boundaries, invariants in types, boundary discipline, single source of truth, idempotence, short call chains; line 20: "You are one of several runners, each on a different model. […] Converging on a safe-looking middle defeats the exploration." (Note the tension with a two-runner, same-family configuration.)

`interrogate/references/lead-judgment.md` (referenced by `spec-review` step 5, `SKILL.md:114`) is a 58-line filtering framework, not a procedure: Nitpick Gravity (line 20), Hypothetical vs. Actual (24), Premature Abstraction Warnings (28), "I Would Have Done It Differently" (32), Missing Context Signals (36–41), When Reviewers Are Right (45–52), Verdict Calibration (56–58: "If your 'Act On' list has more than 5 items, you're probably not filtering hard enough" and "The 'Dismissed' section is not busywork. It's a trust mechanism."). It says nothing about rounds, restarts or design artifacts; the three sentences `spec-review:114` quotes from it are the ones the orchestrator actually uses.

#### I. Every prose mention of the round count / three-round rule

Grep: `grep -rn -E 'round: |three rounds|act-on items|3 of 3'` over `template/`, `docs/knowledge/core/`, `docs/agents/`, `AGENTS.md`, `SOURCES.md`, `tools/build_knowledge.py`, `tests/` (`research/` excluded). Hits below with false positives removed (`background: true` in `.claude/agents/*.md` ×9, `run_in_background: true` in `provider-dispatch.md:45,76` and `codex-tools.md:35,38`, `orchestrate.md:19`, `model-matrix.test.ts:254`, `grilling/SKILL.md:8` "Work the tree in **rounds**" — an unrelated grilling loop).

**Hand-edited prose (would need updating):**

| Path:line | What it says |
|---|---|
| `template/.agents/skills/spec-review/SKILL.md:25` | the round rule (step 1) — **patched** |
| `template/.agents/skills/spec-review/SKILL.md:138` | the `round:`/`act-on items:` output contract (step 6) — **patched** |
| `template/.agents/skills/poteto-mode/playbooks/babysit.md:16` | merge-ready needs `act-on items: 0`; `round: 3 of 3` — **patched** |
| `template/.agents/skills/babysit/SKILL.md:40` | same, standalone skill — **patched** |
| `template/.agents/skills/babysit/SKILL.md:41` | upstream's unrelated "three rounds of fix → push → recheck" — upstream, unpatched |
| `template/docs/agents/review-ladder.md:6` | rung 1, ends with `round: N of 3` and `act-on items: N` — ours, direct edit |
| `docs/knowledge/core/MANUAL.md:103` | "`spec-review`'s last line on the latest commit reads `act-on items: 0`" — core doc, direct edit + rebuild |
| `docs/knowledge/core/DECISIONS.md:86` | **P19**, the judgment and the count | 
| `docs/knowledge/core/DECISIONS.md:87` | **P20**, "Three review rounds at most" — the decision #90 amends |
| `docs/knowledge/core/DECISIONS.md:88` | **P21**, "What carries into the next round" — the `cites:` decision |
| `docs/knowledge/core/DECISIONS.md:85` | **P18**, "What a review counts" (hard-finding definition, headings) |
| `docs/knowledge/core/DECISIONS.md:89` | **P23**, "The Spec report opens with a walk" |
| `docs/agents/ledger.md:20` | 2026-09-18 line ending "one concern per ticket so one PR closes it; three rounds per PR; fix what the last round found and stop" |
| `SOURCES.md:16` | patch item 4 (babysit playbook) |
| `SOURCES.md:18` | patch item 6 (spec-review) — the long one |
| `SOURCES.md:24` | patch item 12 (babysit SKILL) |

**Scripts (comments + emitted strings), owned, not patched:**
`template/.agents/skills/spec-review/scripts/review-brief.sh:8,83,94,127,135,141,145,151`; `template/.agents/skills/spec-review/scripts/review-comment.sh:3,157,158`.

**Tests (assert the emitted prose):** `tests/spec-review/review-comment.sh:167,168,253,254,291,292,308,309,350,351,387,388,406,407,427,428,445,446,467,468,494,495,540,541`; `tests/spec-review/review-brief.sh:10,77,88,97,219,220,224,253,256,259,266,280,281,285,295,303,355,356,374,396`. `review-brief.sh:295` and `:355` both assert the exact fourth-round refusal string:

> `review-brief: three rounds were run on this PR; the remaining Act on items are fixed here and marked \`fixed: <sha>\`, not reviewed in a fourth round`

**Generated, never edited directly:** `template/docs/factory918/DECISIONS.md:78,79` (= core P19, P20) and `template/docs/factory918/MANUAL.md:84` (= core MANUAL:103). `tools/build_knowledge.py:124–137` (`build_core`) writes each `docs/knowledge/core/*.md` in place with a header and then copies the header-stripped body to `template/docs/factory918/<name>.md`, skipping `CONVERSATION-DIGEST.md` (line 135). `docs/knowledge/spec/`, `pages/`, `notes/` are wiped and rebuilt (line 141–142) from `docs/FACTORY-SPEC-v2.md` and `research/`. `tools/build_knowledge.py` itself contains no round wording.

#### J. Records shapes to match

**`docs/knowledge/core/DECISIONS.md`.** `## Provisional (added by agents; Manuel promotes or overrules)` is line 66; the intro at line 11 says "Add to 'Provisional' when you decide something the spec left open; Manuel promotes or overrules from there." Rows are a three-column markdown table `| P<n> | <title> | <what was decided> | <why, ending in a date> |` — actually four cells: id, title, decision, rationale. Rows are **not** in numeric order (…P22 at 90, P2 at 91, P24 at 92, P25 at 93). A promoted row keeps its number as a tombstone (`| P17 | (promoted) | Became settled decision 19 on 2026-09-18 … | The number stays retired so earlier references to P17 keep their meaning. |`, line 84). Amendments are written inline as "Amended <date> (#N): …".

The last two rows, `DECISIONS.md:92` and `:93`:

- **P24 | Overlap is not coupling; a go is a line that covers its own tickets** — decision column runs to ~15 lines of prose ending "step 8's `--diff` run records the shared paths as the PR body's `## Overlap` section"; rationale column: "Ticket #42, Manuel: "working a ticket to completion before automatically moving on"; the #16 to #22 stack was built on a seven-re-reviews mis-estimate (ledger 2026-09-17). First run (PR #87, closed): three review rounds redesigned the matcher three times; the second run designed from a scenario table Manuel approved 2026-09-21 as the ticket's Testing decisions. Rejected: a ticket label as the go (outlives the program), a line pasted into each lane's brief (a forgotten paste blocks a lane), a `done` step (a crash skips it), the script under the factory918 skill (every later edit cross-cutting)."
- **P25 | One shell gate, carried by the template** — "`template/.github/shellcheck.sh` holds the ShellCheck version, both release checksums and the flags; … A `disable=` directive carries its reason in a second comment on the same line; CI cannot check that a reason exists, the Standards axis does"; rationale ends "Ticket #88, 2026-09-22."

Both end their rationale with `Ticket #N, <date>.` or `<date>.`; both name what was **rejected** where alternatives existed.

**`docs/agents/ledger.md`** — pipe-delimited, no table header: `<YYYY-MM-DD> | <model> | <what it did> | <what was wanted>`. Not sorted by date. Last two lines:

```
2026-09-21 | fable | cut the detached-HEAD cell from the #42 scenario table on the judge's word that git would fail loudly on its own; git ran fine with an empty branch name and round two found the record step reporting the ticket's own PR | a cell cut as 'the tool refuses it' is cut only after the refusal was run and seen; an assumption about a tool's failure mode is a rung-1 claim until then
2026-09-22 | Claude Fable 5.1 | as the #88 owner lane, ended its turn to wait on a background lane; the harness removed the lane's empty worktree and its result reached nobody, so the lane and the worktree were redone | drain a lane in the foreground when the next step depends on it, and commit early so the worktree has something to keep
```

Note the model column changed style between the two (`fable` → `Claude Fable 5.1`).

**`docs/M0-findings.md`** — `## <Tool or area> (<YYYY-MM-DD>)` headings, then a paragraph of verified facts. The last dated section is `## ShellCheck (2026-09-22)` (one long paragraph naming versions, sha256s, counts, what was and was not run). After it come `## Still open` (four bullets) and a trailing undated-heading paragraph dated inline "2026-09-18. The factory checkout has no `.claude/agents/` …". A `hole:`/restart change would add a new `## <area> (2026-09-22)` section only if something was verified against a real tool.

#### K. What the two prose tests pin

**`tests/spec-review/no-stale-wording.sh`** (13 lines). Its whole assertion is line 8:

```
hits="$(grep -rnF -e '## Latent' -e 'A hard finding is wrong behavior in normal use' template docs/knowledge/core | cut -d: -f1,2 || true)"
```

Exits 1 printing each `file:line`, else prints `ok: no stale wording`. It pins exactly two retired strings from #81 — the `## Latent` heading and the old hard-finding sentence — across `template/` and `docs/knowledge/core/`. **It says nothing about rounds, `act-on items`, `cites:`, `ticket:` or `fixed:`.** It is the template for a "retired wording" guard: if #90 retires a phrase (e.g. "Three trailing fields"), this is where a new `-e` would go. It is wired at `.github/workflows/factory-ci.yml:30–31` ("No retired review wording under template/ or the core knowledge").

**`tests/spec-review/layout.sh`** (27 lines) pins **no prose at all**. It is a sourced helper (no shebang; `# shellcheck shell=bash disable=SC2034 # …` at line 7) defining `layout <project|factory> <dir>`: it copies `template/.agents/skills/spec-review` into a fresh git repo laid out either as a project (`.agents/skills/spec-review/`, `.claude/hooks/` with an executable noop hook, `.claude/skills -> ../.agents/skills`) or as the factory (the same under `template/`, with `.claude/skills` and `.claude/hooks` symlinked there), then `git init` + commit. It sets `skill` (the copy to run) and `hooks` (the dir a cross-cutting commit touches). Both spec-review tests source it. `docs/M0-findings.md`'s ShellCheck section notes it is why `--external-sources` is required.

---

### Files Read

- `template/.agents/skills/spec-review/SKILL.md` (whole, 155 lines)
- `patches/mattpocock/spec-review.SKILL.md.patch` (whole, 139 lines)
- `patches/pstack/babysit/SKILL.md.patch`, `patches/pstack/poteto-mode/playbooks/babysit.md.patch` (whole)
- `patches/series` (17 lines), `SOURCES.md` (items 1–13 and the pin table)
- `factory918.sh` lines 35, 107–180 (`cmd_apply`), 376–405 (`cmd_sync`), 248–281 (doctor checks)
- `.github/workflows/factory-ci.yml` (whole, 87 lines)
- `template/.agents/skills/poteto-mode/playbooks/ticket.md` (whole)
- `template/.agents/skills/poteto-mode/playbooks/babysit.md` (whole), `template/.agents/skills/babysit/SKILL.md` lines 1–60
- `template/docs/agents/review-ladder.md` (whole)
- `template/.agents/skills/architect/SKILL.md` (whole), `template/.agents/skills/architect/references/runner-prompt.md` (whole)
- `template/.agents/skills/arena/SKILL.md` (whole), `template/.agents/skills/interrogate/references/lead-judgment.md` (whole)
- `docs/knowledge/core/DECISIONS.md` lines 7, 11, 66, 70–93; `docs/knowledge/core/MANUAL.md` lines 95–115
- `docs/agents/ledger.md` (tail), `docs/M0-findings.md` (tail)
- `tests/spec-review/no-stale-wording.sh`, `tests/spec-review/layout.sh` (whole)
- `tools/build_knowledge.py` lines 26–54, 104–145
- `template/.agents/skills/spec-review/scripts/review-brief.sh` lines 145–200 (cites grammar, cross-cutting predicate)
- `AGENTS.md` lines 49–55
- `.scratch/program/90/todo.md` (the owner lane's own plan, untracked scratch)

### Boundaries

- **Owned vs. vendored.** Four files under `template/.agents/skills/` are `keep_files` (`factory918.sh:385`) and are edited directly with no patch: `poteto-mode/playbooks/ticket.md`, `poteto-mode/scripts/overlap.sh`, `spec-review/scripts/review-brief.sh`, `spec-review/scripts/review-comment.sh`. Everything else under that tree is wiped and rebuilt by `sync` — including `spec-review/SKILL.md`, `poteto-mode/playbooks/babysit.md` and `babysit/SKILL.md` — so a change there is patch + template + `SOURCES.md`, one commit.
- **`template/docs/` is not vendored at all.** `review-ladder.md`, `evidence.md`, `feedback-loops.md`, `models.md` are the factory's own and are edited directly. `sync` never touches `template/docs/`; `apply` copies the whole tree into a project (`factory918.sh:131–141`).
- **Generated, never edited:** `template/docs/factory918/*.md` (from `docs/knowledge/core/*.md`), `docs/knowledge/spec/`, `docs/knowledge/pages/`, `docs/knowledge/notes/`, `docs/knowledge/INDEX.md`. A core-doc edit must be followed by `python3 tools/build_knowledge.py`, gated at `factory-ci.yml:32–33`.
- **Two independent CI gates** catch a half-edit: `factory-ci.yml:34–35` for patches vs. template, `:32–33` for core docs vs. generated. Both are `git diff --exit-code` after regenerating.
- **The factory has no `docs/agents/review-ladder.md`.** `babysit.md:8`'s conditional ("If `docs/agents/review-ladder.md` lists no external bot for this repo, there are no bot comments to wait for or triage") therefore resolves in the factory to *file absent* — the sentence says "lists no external bot", not "exists"; nothing enforces its presence (`cmd_doctor` checks only `docs/agents/ledger.md`, `factory918.sh:281`). The template's copy says `(none)` at line 13.
- **Everything in `research/` is read-only vendored corpus.** `research/1-matt-pocock/skills-repo/skills/engineering/code-review/SKILL.md` (87 lines) is the spec-review upstream.
- My angle stopped at the scripts' prose: the shell logic of `review-brief.sh` / `review-comment.sh` and their tests belong to the other explorers.

### Non-Obvious Things

1. **`cites:` must be the last field on its item line.** The regex at `review-brief.sh:151` is anchored with `$`. Adding a `spec:` line to hard findings or a `hole:` mark to a judgment item has to keep `cites:` terminal, or reshape the regex. The three `cites:` alternatives in the script and in `SKILL.md:132` are the *same* three, restated — two places to change for the new table/design/criterion forms, plus `SOURCES.md:18`.
2. **`SKILL.md:130` says "Three trailing fields, each with one grammar:".** A fourth mark (`hole:`) makes that sentence false. It is a `+` line of the patch (patch line 119), so both copies change.
3. **The round count appears as a literal `of 3` in eleven places** (skill ×2, ladder, babysit ×2, both scripts, P20, SOURCES ×2, plus ~30 test assertions). `review-comment.sh:157` hard-codes `echo "round: $round of 3"`. Anything that makes the cap conditional (a hole restarting at round one) touches every one of them, and the owner lane's own plan (`.scratch/program/90/todo.md`, R7) additionally runs this ticket under a "one more round past three, up to five" rule — a run-time rule for *this* PR, not part of the change.
4. **Two different "three rounds" rules sit on adjacent lines** in `babysit/SKILL.md:40` (review rounds, ours, patched) and `:41` (CI fix→push→recheck rounds, upstream, unpatched). Only :40 is in scope.
5. **Arena has no judge-skip clause.** Phase C (`arena/SKILL.md:42`) dispatches a cross-judge unconditionally; the convergence rule at line 62 skips the *graft*, not the judge. "Two runners; the judge is skipped when they converge" would be new text, and it cuts against `runner-prompt.md:20` ("You are one of several runners, each on a different model … Converging on a safe-looking middle defeats the exploration") and `architect/SKILL.md:36` ("Require at least two structurally distinct candidates"). Manuel's sheet already configures exactly two architect runners (`claude:fable@high, claude:opus@high`) against the skill's four defaults.
6. **The ticket playbook never mentions rounds, `act-on items`, or `spec-review` by name** except through step 9's delegation to `babysit.md` and step 5's mention that `review-brief.sh` holds the cross-cutting predicate. A restart step is a genuinely new kind of step for that file.
7. **`architect/SKILL.md:52`** already carries the closest precedent for a hole: "If the human pushes back on the shape (in a checkpoint or after the fact), treat that as Phase A evidence. Re-ground and re-run Phase B before writing more code." A review-found hole is the same move with a different trigger — worth citing rather than inventing.
8. **The Ticket playbook's step 5 does not invoke `architect` directly.** The invocation lives in the four downstream playbooks (`feature.md` step 2, `bug-fix.md` step 3, `refactoring.md` step 3, `perf-issue.md` step 3, per `SOURCES.md:25`), all of which are **patched** files. A "return to architect Phase B" step written into `ticket.md` (a keep_file) reaches architect across a playbook boundary that the current prose crosses only in one direction.
9. **P18/P19/P20/P21/P23 are five separate Provisional rows** covering what a review counts, the judgment, the round cap, carry-forward, and the walk. A design-hole decision most naturally becomes a new **P26** amending P20 (the cap) and P18 (what a finding is), following the inline "Amended <date> (#N):" style the existing rows use rather than rewriting them.
10. **`no-stale-wording.sh` is the only test that greps prose**, and it pins only two #81 strings. Nothing today pins the sentences the change edits, so a stale copy of a round sentence in one of the eleven places would pass CI (the patch/template gate catches drift between the two copies of a *patched* file, not drift between `SKILL.md`, `review-ladder.md` and `DECISIONS.md`).
11. **`git log` precedent `82dc11e`** is the closest analogue in shape to what #90 will produce: three patches + three template files + two scripts + `SOURCES.md` + `AGENTS.md` + `template/AGENTS.md` + `template/docs/agents/review-ladder.md` + two tests, all in one commit. It is the right model for the change's file set (minus babysit, which #90 leaves alone).

### Open Questions

1. Does a `hole:` mark go on an **Act on** item (like `ticket:`/`fixed:`) or is it a bucket of its own? `SKILL.md:138`'s count subtracts `fixed:` and `ticket:` from Act on; if `hole:` sits on an Act on item and prints `restart` instead of a count, step 6's "the final line `act-on items: N` … always present and always last" contract has to say which line wins, and `babysit.md:16` reads only `act-on items: 0`. Leaving `act-on items:` last and adding `restart` above it is the only shape that keeps babysit byte-identical, but the prose does not decide this today.
2. Where exactly does the restart step live — a new step 10 in `ticket.md`, a clause inside step 9, or a rung-1 sentence in `review-ladder.md:6`? All three are prose surfaces with no current owner for this transition.
3. Does `template/docs/agents/review-ladder.md` need a root-level copy at `docs/agents/review-ladder.md` once it describes a hole restart the factory itself runs? `AGENTS.md:51` names only three files as copied; the ladder's absence at the root means the factory's own `babysit.md:8` reads a missing file.
4. `spec:` on a hard finding — is it a third `Documented step:`-class line (checked by `review-comment.sh`, per P18) or a free-form reference? If checked, the check's refusal text joins `SKILL.md:140`'s list, which is patched prose plus test assertions in `tests/spec-review/review-comment.sh`.
5. Whether the "two runners; the judge is skipped when they converge" rule is written into `arena/SKILL.md` (a **patched** file, patch not currently in `patches/series` for arena — there is none, so a new patch file and a new `series` line would be needed) or stated only in the restart step's brief. The latter avoids touching arena at all.
6. `docs/knowledge/core/MANUAL.md:103` states the human's merge-readiness test in terms of `act-on items: 0`. If a hole can leave a PR not-ready in a new way, that sentence and its generated twin `template/docs/factory918/MANUAL.md:84` may need a clause — not obviously in #90's scope.
