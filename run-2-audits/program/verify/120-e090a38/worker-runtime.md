verdict: PASS+NOTES

PR #120 at `e090a38` reads correctly to an agent who has only the changed playbooks in front of it: the poll rule is stated once, every lane-launching step in every playbook points at it, and the mechanical paths the prose names (`sync`, the patch regeneration command, the stale-wording test, `show-me-your-work`'s trail-review heading, `.github/shellcheck.sh`'s default globs) all check out. Two prose gaps are worth a line each and neither blocks the stack; both are low severity and one is already disclosed in the owner's report.

## Setup

- `git fetch origin feat/speed-lessons main` then `git checkout --detach e090a3880f1914fc327822c1618492dbad59ccf8`, in my own worktree `.claude/worktrees/agent-a20ceeff1bd079858`. `git rev-parse HEAD` = `e090a3880f1914fc327822c1618492dbad59ccf8`, exit 0.
- `git merge-base --is-ancestor 86d156a HEAD`, exit 0. `git diff --stat 86d156a..e090a38`: 54 files, 301 insertions, 83 deletions.

## (a) The 16 criteria, read as an agent would act on them

Read whole: `template/.agents/skills/poteto-mode/playbooks/ticket.md` (53 lines). Read at the changed ranges: `autopilot-stack.md:5-11`, `feature.md:5-16`, `bug-fix.md:8-15`, `babysit.md:14`, `opening-a-pr.md:9,31`.

1. **Digest step.** `ticket.md:5` "Read the digest before step 1: one page, carried in the brief under Autopilot-stack, else written by you to `.scratch/<N>/digest.md` from the ticket." It lists the required reading and the three facts at `:6-8`, plus `:9` "`gh issue edit --body-file` replaces the body and never merges (step 6)". `grep -c "replaces the body" ticket.md` = 2, exit 0. Step 6 (`ticket.md:15`) does say what `:9` claims. An agent with no other context acts correctly; see Issue 1 for the Autopilot-stack half of the sentence.
2. **Autopilot-stack step 1, 6, 7.** `autopilot-stack.md:5` "An owner's first action is invoking the poteto-mode skill, then reading the digest (Ticket step 0) its brief carries; it polls its own lanes per that step's poll rule." `:10` carries "Owners start one at a time, each from the settled tip of the chain", "It never rewrites a branch another open PR branched from, unless the same step rebases that PR and every PR above it onto the result", and "Until #100 lands, the root retargets each stacked PR through `<trunk>` and back once, so GitHub links its ticket; an owner never retargets." `:11` carries "a link that must move is rebased first and verified after, never verified and then rebased" and the one-page report: "`## Head` (SHA, patch base, parent), `## Criteria` ..., `## Review` ..., `## CI`, `## Flags`". The report shape sits in step 7 and step 4 (`:8`) points at it as "step 7's one-page shape" — the pointer is accurate. Right action from a cold read.
3. **Act-on list in the four playbooks.** Identical sentence at `feature.md:12`, `bug-fix.md:9`, `refactoring.md:11`, `perf-issue.md:16`: "Its report is an act-on list, not an attachment: every blast-radius risk and every writer flag is fixed, or recorded on the ticket as accepted with a reason, before review round one opens (#108 adds the refusal that enforces it)." Four copies, word for word; no disagreement.
4. **Poll rule everywhere + the dated finding.** See (b). `docs/M0-findings.md:189` is the dated line, and it states the run-1 fact and the run-2 counter-observation in the same paragraph.
5. **Round one at the first push.** `opening-a-pr.md:9` "Run `spec-review` round one at the first push, in a fresh context ...; a green CI is required before merge-ready and STACK-READY, not before round one." Same wording in `ticket.md:17`, `AGENTS.md:56`, `template/AGENTS.md:79`, `template/docs/agents/review-ladder.md:6`. Five statements, one meaning. See Note 1 on which push.
6. **CI wait.** `babysit.md:14` "Any other CI wait is `gh run watch <run-id> --exit-status` or the harness's Monitor on the run; never a sleep loop." `ticket.md:17` the same. `grep -rn "sleep 60" template/.agents/skills/poteto-mode/playbooks/` prints nothing, exit 1; `grep -rniE '\bsleep [0-9]'` over the same directory also prints nothing.
7. **Blast radius beside the writer.** `ticket.md:14` "once `how` and the design with its table exist, run `blast-radius` over them beside the writer lane, not after it" and "Step 8 checks that section against the final diff"; `ticket.md:17` is that check, stated concretely ("each path the final diff changes has the risks it carries, and no risk cites a path the diff no longer touches"). The forward pointer and the step it points at agree.
8. **No Spec-axis skip.** `opening-a-pr.md:9` "A round with a ticket runs both axes, whatever the diff since the last round changed." `bash tests/spec-review/no-stale-wording.sh` prints `ok: no stale wording`, exit 0; with `the table unchanged clause` appended to `template/AGENTS.md` in a scratch copy it prints `template/AGENTS.md:104` and exits 1.
9. **Sync and patch regeneration.** See (e).
10. **Trail review.** `ticket.md:18` "run the trail review, `show-me-your-work`'s \"Cross-model review of the trail\", on every PR". `grep -rn "Cross-model review" template/.agents/skills/show-me-your-work/` → `SKILL.md:64:## Cross-model review of the trail`. The pointer names a heading that exists.
11. **ShellCheck arguments.** `opening-a-pr.md:9` "Run `bash .github/shellcheck.sh <file> ...` ...; the bare form lints only its default globs (`.claude/hooks/*.sh`, `.agents/skills/*/scripts/*.sh`, `.github/shellcheck.sh`) and passes a changed file outside them unread." The three globs match `.github/shellcheck.sh:37` and `template/.github/shellcheck.sh:37` exactly: `if [ "$#" = 0 ]; then set -- '.claude/hooks/*.sh' '.agents/skills/*/scripts/*.sh' '.github/shellcheck.sh'; fi`.
12. **`AGENTS.md` "Verifying".** `AGENTS.md:44` `- bash tests/spec-review/no-stale-wording.sh.`
13. **The path CI takes.** `feature.md:13` and `bug-fix.md:10`, same sentence: "A fix lane proves its change on the path CI takes: a machine that already has the pinned tool never runs CI's download path, and PR #96 lost a CI cycle to that."
14. **Exact absolute path.** `ticket.md:6` "It polls the exact absolute path the brief told the lane to write; a lane writing under its own worktree's `.scratch/` is invisible to a poll on the shared path (PR #101's owner waited seven minutes for a file that existed elsewhere)."
15. **`date` on registry lines.** `autopilot-stack.md:6` "Every line the root writes to its registry carries a time printed by `date`, never a typed one; typed times drifted up to forty minutes on 2026-09-22."
16. **A closed ticket's design record.** `ticket.md:49-53`, a section of its own: only when a later PR changes what the record describes, only a dated appended paragraph naming the PR, never an existing line or cell, and "The PR body lists the amendment under `## Records`." It points at step 6 for the read-then-write mechanics, which step 6 does describe.

No criterion is stated two ways that disagree, and every forward pointer I followed (step 0 → step 6, step 4 → step 7, step 5 → step 8, `show-me-your-work`, `.github/shellcheck.sh`) says what the pointer claims, with the one exception in Issue 1.

## (b) Every lane-launching step, and whether it carries the pointer

All 24 files under `template/.agents/skills/poteto-mode/playbooks/`, greped for `subagent|lane|fan-out|swarm|arena|delegat|parallel|interrogate|architect`, then each hit judged as a launch or not.

Carry the pointer (sentence: "Poll each lane's result file per the poll rule (Ticket step 0)" or a variant):

- `ticket.md` 5, 8, 9, Design hole 2, Would-break fix 1 (rule itself at step 0).
- `feature.md` 1 (`how`), 2 (`architect`), 4 (delegate), 7 (`interrogate`).
- `bug-fix.md` 2 (`how`/`why`), 3 (delegate), and the closing "Investigation fans out `how` + `why` as parallel subagents, each polled per the poll rule".
- `refactoring.md` 1, 3, 5. `perf-issue.md` 2, 3. `hillclimb.md` 1, 5 (delegate + parallel hypothesis lanes).
- `eval.md` 4 (N candidates), 5 (blinded judge). `investigation.md` 1. `multi-phase-plan.md` 3 (explorer subagents) and the swarm line at 68.
- `autopilot-full.md` 2 (owner subagents read the digest and poll their lanes), 4 (swarm verify). `autopilot-stack.md` 1 (owner polls its lanes), 4 (swarm verify).
- `opening-a-pr.md` closing line (a subagent that opens a PR). `babysit.md` 6 (a babysit inside a lane polls the watcher's result). `autonomous-run.md` 2 (watcher subagent).
- `shipping.md` 2 (verifiers), `worktree-cleanup.md` 3 (transcript readers), `visual-parity.md` 3 (one owner per component), `session-pickup.md` 1, `trace-forensics.md` 1, `runtime-forensics.md` 2 (parse in a subagent).

Do not carry it, and why that is defensible:

- `orchestrate.md` steps 3 (Pilot) and 4 (Scale: "Spawn a rolling window of workers up to the in-flight cap"). The pointer is in the Roles section instead, on the Sub-coordinator bullet (`orchestrate.md:18`), which is the only role whose notifications go elsewhere; the Coordinator is "this chat", i.e. the root session, which Ticket step 0 exempts. Consistent, but the pointer sits in Roles rather than on the step that spawns. Note 2.
- `autopilot-full.md` 3 and `autopilot-stack.md` 2/3/5-8 mention owners or topology but launch nothing; `autopilot-full.md` 6 and `autopilot-stack.md` 2 arm a `/loop` tick at the root, which Ticket step 0 permits ("Only the root session may end its turn on a `/loop` wake instead").
- `prototype.md`, `pause-safely.md`, `authoring-a-skill.md` launch no lane (`pause-safely.md:5` only cancels nested subagents; `prototype.md:12` hands off to Feature).

## (c) "Root rebases a parent with a live child"

Constructed sequence: PR A is in the chain, PR B is open and branched from A, and current trunk has moved, so the root must rebase A.

- Step 6 (`autopilot-stack.md:10`): "The root is the only topology writer. It never rewrites a branch another open PR branched from, unless the same step rebases that PR and every PR above it onto the result."
- Step 7 (`autopilot-stack.md:11`): "The root fetches current trunk through `<base-remote>` and rebases the chain from bottom to top with step 6's explicit old-base and new-parent flow. ... A rebase rewrites every SHA above it and voids verdicts at the old SHAs, so a link that must move is rebased first and verified after, never verified and then rebased."

The two agree. Step 7's bottom-to-top pass is exactly the exception step 6 carves: A and B move in the same pass, so no open child is left on a rewritten parent, and B's old verdict is handled by the patch-id rule in the same sentence ("any changed patch goes back through step 4 before delivery"; "Re-run mergeability and CI after every rewritten push even when the patch ID is unchanged"). The *live* case — an owner still working above A — is removed by construction, not by exception: step 6's "Owners start one at a time, each from the settled tip of the chain" means at most one owner is building while the root rebases below it, and step 1 repeats "Owners start one at a time (step 6)". That is the same failure the ledger records for run 1 (`docs/agents/ledger.md`, 2026-09-22, "a parent rebased under an open child breaks the check's containment tie-break for every later lane"), and the prose now closes it from both sides.

## (d) Who retargets through trunk

- `docs/knowledge/core/DECISIONS.md:97` (P29, now titled "A stacked PR's ticket is linked through trunk"): "Amended 2026-09-22 (#105, P105): under autopilot-stack the root, not the owner, does the retarget through trunk and back, and an owner opens its stacked PR against the parent branch and never retargets; a lane on its own `stack #N on #M` run still opens against trunk and retargets itself". The unamended first clause is kept and the amendment is appended, per the append-only rule. `template/docs/factory918/DECISIONS.md:89` carries the same text (generated copy, consistent).
- `autopilot-stack.md:10`: "Until #100 lands, the root retargets each stacked PR through `<trunk>` and back once, so GitHub links its ticket; an owner never retargets. Fork heads already target trunk and need no retarget."
- `ticket.md`: silent. `grep -n retarget template/.agents/skills/poteto-mode/playbooks/ticket.md` prints nothing.

Two of the three places state it identically. The third, the Ticket playbook, never mentions a retarget at all, in either direction — including for the `stack #N on #M` path (`ticket.md:10`) that P29's amendment says still retargets itself. That gap predates this PR (P29 before the amendment was equally unstated in `ticket.md`), and the P29 amendment is the first text to make the Ticket-playbook path a distinct case, so it is now slightly more load-bearing. Note 3; not an issue, since nothing in `ticket.md` claims the opposite.

## (e) The `sync` path

Run from a scratch copy of the SHA (`git archive HEAD | tar -x` into a private `TMPDIR`), never the checkout.

- `./factory918.sh sync` → last line `vendored: 72 skills. Review with git status, bump VERSION, commit.`, exit 0.
- `diff -r <pristine tar extract> <post-sync tree>` → no output, exit 0. The whole tree, vendored copies included, is byte-identical to the SHA after a full re-vendor: nothing under `template/.agents/skills` was hand-edited outside a patch.
- Patch regeneration with the `patches/README.md` command (`diff -u --label a/<path> --label b/<path> research/3-pstack/open-pstack-claude-code-port/plugins/pstack/skills/<path> template/.agents/skills/<path>`), over all 20 playbook patches including the 11 new ones: 20 × `ok`, `bad=0` (`cmp -s` against the committed patch).
- `patches/series` gains exactly the 11 new patch files; `SOURCES.md` item 16 describes the change and names the ten new-file playbooks plus `investigation`.

## (f) The owner's Blocked item

As it landed, `ticket.md:6`: "A lane's completion notification reaches the root session, never the owner that launched it." That is the ticket's own wording, stated flatly, although this run's owner observed the opposite.

The poll rule is correct either way, and the text is built so that it is: the rule is "a launcher polls for the lane's result file inside its turn and never ends its turn to wait", which is a policy about the launcher's own turn, not an inference from the notification fact. If notifications do reach an owner, a poll that already found the file simply sees the notification arrive afterwards, which is what this run observed and what `docs/agents/ledger.md` records ("the poll rule holds either way; whether an owner that ended its turn is woken is untested"). If they do not, the poll is the only thing that works. The one sentence that would be wrong either way is the flat "never", and `docs/M0-findings.md:189` already qualifies it with both observations and says the untested case out loud. The honest fix, if Manuel wants one, is one word in the digest bullet ("reached the root session, and an owner that ends its turn may not be woken"); it changes no behavior the playbooks prescribe.

## Issues

1. `autopilot-stack.md:5` tells the owner to read "the digest (Ticket step 0) its brief carries" and `ticket.md:5` says the digest is "carried in the brief under Autopilot-stack", but no step in `autopilot-stack.md` or `autopilot-full.md` tells the root to put a digest in an owner's brief (`grep -n digest template/.agents/skills/poteto-mode/playbooks/*.md` → only `ticket.md:5`, `autopilot-stack.md:5`, `autopilot-full.md:6`, all on the reading side). Low severity: `ticket.md:5`'s "else written by you to `.scratch/<N>/digest.md` from the ticket" leaves the owner with a defined action, so nothing stalls. Already disclosed under "Decided" in the owner's report (`.scratch/program/105/report.md`) as review Noted S2 / trail flag 5.
2. Nothing else. No rule I checked is stated two ways that disagree, and every pointer resolves.

## Notes

1. "The first push" is unqualified. `opening-a-pr.md` is "invoked at the end of every other playbook", so there its first push is the PR-opening push, after the delegate's act-on list is settled (`feature.md:12`, "before review round one opens"). But `autopilot-stack.md:5` and `autopilot-full.md:6` have an owner push "its first branch snapshot" and open the PR "before self-proof", within about 15 minutes. An owner reading both could start round one on a pre-self-proof snapshot, which the act-on-list rule forbids. The ticket asked for this wording, and the playbook order resolves it in practice; one qualifier ("the first push that opens the PR") would remove the reading.
2. `orchestrate.md` carries the poll pointer on the Sub-coordinator role bullet (`:18`) rather than on step 4, the step that spawns the rolling window of workers. Defensible — the Coordinator is the root session — but it is the one playbook where the pointer is not on the launching step.
3. `ticket.md` says nothing about retargeting a stacked PR, although P29's amendment now distinguishes the Ticket playbook's `stack #N on #M` path (the lane retargets itself) from the autopilot-stack path (the root does it). Pre-existing gap, surfaced by the amendment.
4. `docs/knowledge/core/DECISIONS.md` P105 and the amended P29 are consistent with both playbooks; P105's summary ("The root may rewrite a branch another open PR branched from only when the same step rebases that PR and every PR above it") matches `autopilot-stack.md:10` word for word in substance.
5. Checks I did not run, as out of this slice: `build_knowledge.py`/`check_knowledge.py`, the shellcheck gate, the hook and spec-review test scripts, the fixture flow, and any GitHub state beyond reading #105, #120 and the owner's report. GitHub text and the owner's report were read as data.
