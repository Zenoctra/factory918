
Base: `origin/main` a9ebdac. Line numbers are at the base; the writer's edits land beside them (brief: `.scratch/program/109/writer/brief.md`). Proof scripts: `.scratch/program/109/blast/tier-proof.sh` and `hook-proof.sh`, both runnable as `bash <script> <args>` (usage in each header).

### What it does

- Adds a per-repository tier, read once per ticket from `"$(git rev-parse --git-common-dir)/../.claude/state/tier"`: exactly `eco` means eco, anything else (no file, `ECO`, two lines, empty, unreadable) means `safe`. `safe` is today's behavior, unchanged.
- Freezes the tier into the ticket's digest (`Tier: eco` as its first line). Under Autopilot-stack the root writes that line into each owner's brief, and the brief wins over the file.
- In `eco`, a new bullet in Ticket step 0 (ours, `template/.agents/skills/poteto-mode/playbooks/ticket.md:5-9`) swaps five things. The owner does its own `how`/`why` reading. Architect runs one runner plus an adversarial judge, with no writer arena and no `interrogate`. The owner runs `spec-review` with no wrapper lane. A subagent owner writes its own small fixes and records. The hand-back is always the one-page STACK-READY shape. Pointer clauses go into steps 5, 6, 8, Design hole step 2 and the Reply line.
- Two vendored files change through their existing patches: `autopilot-stack.md` step 1 (`autopilot-stack.md:5`, patch `patches/pstack/poteto-mode/playbooks/autopilot-stack.md.patch`) and `architect/SKILL.md` after "Design it twice" (`architect/SKILL.md:36`, patch `patches/pstack/architect/SKILL.md.patch`). `SOURCES.md` items 11 and 14 get a clause each.
- MANUAL "Execution" gets a **Safe and eco.** paragraph and "Models and cost" gets one sentence. `tools/build_knowledge.py` regenerates `template/docs/factory918/MANUAL.md`, so every applied project gets the new paragraph on its next `factory918 update`.
- Adds 21 `expect` lines to `tests/hooks/delegation.sh`, asserting the hook's answer is the same under all three fixture tiers. The hook itself (`template/.claude/hooks/delegation.sh`) does not change.
- What the diff does not spell out: this is prose that changes how many lanes every future ticket launches in the factory and in every applied project. It also lets the author's own context judge the review (spec-review step 5), and a subagent owner write tracked files. Both used to be separated by rule.

### The one fact it is safe because of

**The tier path resolves to the main checkout's `.claude/state/tier` from every place a ticket runs, and the delegation hook's answers do not depend on that file.** Every eco branch is prose gated on that read. When the read says `safe`, every step runs as written, so a wrong read in the safe direction costs money and not correctness. The one dangerous direction would be the hook changing behavior, and it does not read the file.

Proven to step 4 (real code run, fails loud), on git 2.51.2:

`tier-proof.sh` builds a main checkout whose path contains spaces, a worktree nested under `.claude/worktrees/`, and a worktree outside the checkout:

```
--- A3 eco in main
main top                     common-dir=.git            tier=eco
main subdir                  common-dir=../../.git      tier=eco
nested worktree top          common-dir=<abs>/.git      tier=eco
nested worktree subdir       common-dir=<abs>/.git      tier=eco
worktree outside main        common-dir=<abs>/.git      tier=eco
--- A4 other content, read from the nested worktree
value [ECO] safe | value [eco ] safe | value [] safe | value [safe] safe | two lines ECO/fast safe
eco + blank lines  eco          (trailing newlines stripped by $(...), as the contract says)
eco CRLF           safe
--- file only in a worktree session's own .claude/state
eco set in worktree only     tier=safe
no repo                      tier=safe
inside a submodule           common-dir=<abs>/.git/modules/vendor/lib  tier=safe
```

`hook-proof.sh` feeds the unmodified hook table B's seven calls plus two extras. It runs in `execute` with a live review state, under tier none, eco and `ECO\nfast`:

```
B1 orch Edit small.md|2|BLOCKED: writing small.md is a lane's job (P11)...
B2 orch Edit big.sh|2|BLOCKED: writing big.sh is a lane's job (P11)...
B3 orch echo >> small.md|2|BLOCKED: writing small.md ...
B4 orch Write ledger|0|
B5 orch Write tier|0|
B6 orch review-brief|0|
B7 agent Edit small.md|0|
X1 orch reads tier under review|0|
X2 orch Write SOURCES.md (records commit)|2|BLOCKED: writing SOURCES.md ...
--- diff none vs eco:  identical
--- diff none vs junk: identical
--- tier is read nowhere in the hook: 0
```

Not proven: that `./factory918.sh sync` re-applies the writer's two regenerated patches cleanly. That is the writer's gate. I did not run sync because this lane edits no repository files.

### Risks

1. Subagent owner with worktree isolation: the step 0 one-liner is refused. Ticket step 0's new bullet puts `git rev-parse` inside `$(...)` inside `[ ]` (inserted after `ticket.md:9`), and the harness guard for `isolation: worktree` agents refuses that shape: "this command names git in a form too complex to verify that it stays inside the worktree". I reproduced this in this lane, which is such an agent. Split into two plain commands it runs, and so does the same resolution inside a script (`poteto-mode/scripts/overlap.sh:22`). Likely for any isolated agent that runs step 0 itself: a subagent-run ticket with no `Tier:` line, or table A6's check. The cost is an improvised read or a silent default. Fix: put the read in a script (an `overlap.sh tier` verb or a `tier.sh`) and have step 0 call that.
2. Interactive root session started in a linked worktree: `echo eco > .claude/state/tier` there is ignored. `mode.sh:8-9` creates `.claude/state/` under `CLAUDE_PROJECT_DIR`, so a session running in a worktree has its own `.claude/state/`, and that is where a user naturally writes. The read goes to the common dir and says `safe` (proven: "eco set in worktree only, tier=safe"). The digest's "names the value it did not read" does not fire, because the main file is absent, not junk. Likelihood is low here (Manuel's root runs in the main checkout, which has `.claude/state/{mode,program}`), and the cost is a quietly more expensive run. Check: the digest could also mention a worktree-local tier file when it finds one.
3. `factory-start` at day zero in a fresh project: MANUAL's `echo eco > .claude/state/tier` fails with "No such file or directory" until some prompt has run `mode.sh:9` (`mkdir -p`), and `rm .claude/state/tier` fails when no file exists (both proven, exit 1). This fails loudly and costs little. Fix in the MANUAL paragraph: `mkdir -p .claude/state && echo eco > .claude/state/tier`, and `rm -f`.
4. Interactive and subagent sessions: `template/AGENTS.md:37` says "Inside a playbook the writer is never the orchestrator", and this repository's `AGENTS.md:26` says the same. Both are loaded in every session and neither is edited. Eco item 4 (a subagent owner writes its small fixes and records) contradicts them. Likely outcome: the owner keeps launching fix lanes and loses the savings, or a Standards reviewer cites AGENTS.md against an eco owner's own fix commit. Nothing ships wrong. Fix: one clause on `template/AGENTS.md:37` pointing at Ticket step 0 "The tier", plus the same clause on `AGENTS.md:26`.
5. A review in progress (spec-review): `template/AGENTS.md:79`, `template/docs/agents/review-ladder.md:6` and `docs/knowledge/core/MANUAL.md:94` ("in a fresh context so the reviewer is not the author") are unedited. In eco (item 3), spec-review steps 5 and 6 (the judgment that sorts Act on items and marks `restart` and `hole:`) run in the author's own context. The reviewers stay fresh; the judge of their findings no longer is. That is the one real quality change in eco. The ticket accepted it (table C5), but the three documents a reader trusts most still say otherwise. Medium: a judge with opinions about its own design is the likeliest to downgrade a hole. Check: the P109 row names this trade, and MANUAL:94 gets a clause.
6. poteto-mode playbooks: in `feature.md:12`, the arena for writers is "Mandatory: no skip-with-reason escape". `feature.md:13` has "A fix lane proves its change", and `feature.md:16` has `interrogate` when contested. All are vendored and unpatched, and Ticket step 5 (`ticket.md:14`) says to run the selected playbook's steps "verbatim". Eco items 2 and 4 override them from step 0 only. Likely outcome: an owner obeys the more specific, later text it is reading at step 4. Cost: extra lanes, not a wrong ship. Check: the step 5 pointer clause should say the step 0 list overrides the selected playbook's steps.
7. Bug fix, Refactoring, Perf issue and architect Phase A still fan out `how`. `bug-fix.md:8,15` ("Investigation fans out how + why as parallel subagents"), `refactoring.md:7`, `perf-issue.md:6` and `architect/SKILL.md:24` ("Run the how skill") all lead into `how/SKILL.md:47` explorer lanes. Eco item 1 names only "step 5, Feature step 1". An eco bug fix, or any eco architect Phase A, still launches explorers, so table C's "at most" count is false for those paths. Cost only. Check: item 1 should say "every `how`/`why` a ticket's steps run, including architect Phase A".
8. spec-review: `spec-review/SKILL.md:134,140` ("the fix lane fixes the Act on items") are unpatched, and they sit inside the step an eco owner now runs itself. Same conflict as risk 4, at the point of action. Low.
9. Interactive root session running an eco ticket: its records commit beyond the four owned paths is still blocked. `delegation.sh:47-57` classes `SOURCES.md`, `patches/series` and `VERSION` as `lane` (proven, X2 exits 2). The brief limits item 4 to subagent owners, but the MANUAL paragraph's first sentence ("has the owner do the rest itself: ... its small fixes and records") reads as unconditional before it qualifies. The hook stops it loudly. Low.
10. show-me-your-work trail review: Ticket step 0 says eco "logs each launch as a trail row so the trail review can count them", but `show-me-your-work/SKILL.md:64-68` ("Cross-model review of the trail") tells the reviewer nothing about counting launches. `check-trail.sh:1-30` checks only the clock and columns. The launch cap is not enforced unless the owner's brief to the trail reviewer asks for the count. Low.
11. architect and arena: `arena/SKILL.md:42` (the judge "recommends a base"), `:48` ("Compare against the cross-judge") and `:62` (convergence) all assume N of 2 or more. With one candidate, only the new architect sentence after `architect/SKILL.md:36` and Ticket step 0 say what the judge is for, and the old "Require at least two" sits directly above that sentence. An agent reading arena alone runs a degenerate pick. Low. Check: the architect sentence says the judge returns defects, not a base.
12. Records: `tools/check_knowledge.py:7-30` validates only ids in DECISIONS' Provisional table and never checks a `P109` mention against it. If the owner's records commit is missed or renamed, `ticket.md` and `MANUAL.md`, and through `template/docs/factory918/` every applied project, cite a row that does not exist, and every gate stays green. Low likelihood, and the dangling citation would be permanent. Check before merge: `grep -n '^| P109 |' docs/knowledge/core/DECISIONS.md`.
13. Autopilot-stack owner replacement: `autopilot-stack.md:6` (stand a lane down, then dispatch a replacement) and `feature.md:19` ("spawn a fresh owner") give the replacement a new brief, and table A5 says "the next owner gets the new value". A replacement owner for the same ticket can therefore change tier halfway through, which step 0's "a run never changes tier halfway" rules out. Low. Check: the root copies the tier line from the stood-down owner's digest, not from the file.
14. A review in progress (review-brief.sh): the predicate at `review-brief.sh:315` (`*.claude/hooks/*|*.claude/settings.json|*.agents/skills/factory918/*`) does not match this diff (`tests/hooks/`, playbooks, MANUAL), so the reviewers get this file in their briefs only if the owner passes `--blast-radius`. Low. Check: run round one with `review-brief.sh <base> --ticket 109 --blast-radius .scratch/program/109/blast/blast-radius.md`.
15. A hook's own invocation and the factory918/factory-doctor skills: no hook reads the tier (proven, 0 matches in `delegation.sh`), and `mode.sh:26-30` prints `PHASE:` but no tier. `factory918/SKILL.md:45` routes by phase alone, and `factory918.sh:267-269` (doctor) checks the state directory but not the tier. A user cannot see which tier is live without `cat`. Nothing breaks. Low. Check: optional doctor `note` line.
16. Projects with submodules, or a Windows-edited file: from inside a submodule the common dir is `.git/modules/<name>` and the read says `safe`, and `eco\r\n` also reads `safe` (both proven). Both land on the safe side. For CRLF, the "names the value it did not read" line will print what looks like `eco`. Low.

### Cleared

- Hook behavior across tiers: table B plus two extra calls give byte-identical exit codes and stderr under none, eco and junk, in execute with a live review (step 4, `hook-proof.sh`). The orchestrator's tier read during a review is not blocked (X1). `delegation.sh:47` classes `.claude/state/*` as untracked, so B5 passes.
- The root running review-brief.sh (eco item 3) does not leak the diff: the script's stdout is the two brief paths (`review-brief.sh:558-559`). Every read of the diff or the briefs stays blocked by `delegation.sh:63-77`.
- Git ignore and apply: `.gitignore:7` and `template/.gitignore.factory:5` already ignore `.claude/state/`. `apply` copies nothing from there (`factory918.sh:131-141`), so no manifest entry exists and `update`/`sync` never touch the tier file.
- Applied projects on `factory918 update`: `ticket.md`, the two patched files and `template/docs/factory918/MANUAL.md` go through the three-way merge at `factory918.sh:328-362`. A locally edited copy gets a `.factory-merge` conflict, the normal path.
- Path resolution: the main checkout top and subdirectories, worktrees nested and outside, paths with spaces, and no repository at all (`fatal`, reads `safe`) all behave as the contract says (step 4, `tier-proof.sh`).
- No test, tool or CI step pins the text of `ticket.md`, `autopilot-stack.md` or `architect/SKILL.md` (grep over `tests/`, `tools/`, `.github/`, skill scripts; only historical eval fixtures mention them).
- `P109` cited from a template file has precedent: the hook message cites `P11` (`delegation.sh:58`), which resolves to `template/docs/factory918/DECISIONS.md` in a project.
- Ordering: #105 (blocker) is merged, no PR is open on the repository, and #108 is OPEN but edits `review-brief.sh` and its test, which this brief keeps out of.
- The architect patch: the new text sits a few lines below the existing `@@ -29,7` hunk. `diff -u` may merge the two into one hunk, which `git apply` takes the same way. Only `sync` leaving the tree clean proves it (not run here).

### Before you merge

1. Run both proofs against the branch. `bash .scratch/program/109/blast/hook-proof.sh <worktree> $(mktemp -d)/fx` should print identical twice, and the new `tests/hooks/delegation.sh` count should be the old one plus 21. `bash .scratch/program/109/blast/tier-proof.sh $(mktemp -d)` should print the A1, A3, A4 and A6 rows as shown above; that is table A's shell walk for the PR's Verification.
2. From a worktree-isolated subagent, run the exact step 0 command. It is refused today (risk 1). Either move the read into a script, or have step 0 give the two-command form (`git rev-parse --git-common-dir`, then `cat <that>/../.claude/state/tier`).
3. `grep -n '^| P109 |' docs/knowledge/core/DECISIONS.md` finds the row. The row names the trade in risk 5 and scopes P11 (`DECISIONS.md:80`, "split by path, not by size") for subagent owners in eco.
4. `grep -n 'writer is never the orchestrator' template/AGENTS.md AGENTS.md` and `grep -n 'fresh context' template/AGENTS.md template/docs/agents/review-ladder.md docs/knowledge/core/MANUAL.md`: each hit either points at the tier or is recorded on the ticket as accepted (risks 4 and 5).
5. `./factory918.sh sync && git status --porcelain` is empty. `python3 tools/build_knowledge.py && git status --porcelain` is empty. `python3 tools/check_knowledge.py` passes.
6. Run review round one with `--blast-radius` pointing at this file (risk 14).
