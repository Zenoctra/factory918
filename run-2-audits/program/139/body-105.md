## What to build

Split from #104 (2026-09-22) at Manuel's request; the exchange that decided it is quoted there and repeated here in part.

> user: "I AM saying that certain steps are consistently slowing us down, and I suspect the models we are using are smart enough that this shouldnt me necessary."

> agent: "Reviews wait for CI to be green. The review needs the diff, not the checkmark. Run round one the moment the branch is pushed and let CI finish alongside. [...] CI waits are polling, not CI. CI takes 40 seconds; owners paid six minutes per cycle with sleep loops. A run watch or a Monitor on the run gets the real number."

> agent: "blast radius runs after the writer, but it reasons from the design and the table, [...] so it can run beside the writer"

> agent: "Changes I would make before a second stack run, ranked by minutes saved: a one-page digest in every brief covering the reading list and the three GitHub rules; owners invoke the skill first; delegate reports are act-on lists, not attachments; the root never rewrites a branch with a live child and rebases before verifying; start each owner from the settled tip, serially, since parallel owners only bought waiting; [...] and cap reports at one page."

> user: "Also the whole dont run spec review if the table hasnt changed is dumb and I dont want it."

> user: "I agree with your choices here."

Facts the lane starts from. This ticket is prose only: the playbooks under `template/.agents/skills/poteto-mode/playbooks/` (through their patches in `patches/`), `docs/M0-findings.md`, and one test that greps for retired wording. The three harness and GitHub facts the run paid for: a child lane's completion notification reaches the root session, never the owner that launched it; GitHub links `Closes #N` only on a PR whose base is the default branch and reads a `closes` word beside any ticket number as closing that ticket; Actions creates no `pull_request` run for a PR that conflicts with its base. The measurements are in `.scratch/program/postmortem/` in the main checkout (untracked). The script-side changes this prose refers to are #106, #107 and #108; this ticket does not wait for them and names them where the prose points at a script.

## Acceptance criteria

- [ ] The Ticket playbook opens with a digest step read before step 1: the required reading in one page (the ticket's worked example, the review rounds it points at, the playbooks that apply), the three harness and GitHub facts above, and that `gh issue edit --body-file` replaces a body; `grep -c "replaces the body" template/.agents/skills/poteto-mode/playbooks/ticket.md` is at least 1.
- [ ] The autopilot-stack playbook's step 1 says an owner's first action is invoking the poteto-mode skill and reading the digest, and its steps 6 and 7 say the root never rewrites a branch another open PR branched from, a rebased link is re-verified only after the rebase, owners start one at a time from the settled tip of the chain, the root does the one retarget through trunk that links a stacked PR's ticket until #100 lands, and the STACK-READY report is one page with fixed headings.
- [ ] The Feature, Bug fix, Refactoring and Perf issue playbooks say a delegate's report is an act-on list: every blast-radius risk and every writer flag is fixed, or recorded as accepted with a reason on the ticket, before the first review round opens (the refusal that enforces it is #108).
- [ ] Every playbook step that launches a lane says the launcher polls for the lane's result file inside its turn and never ends its turn to wait; the notification fact is a dated line in `docs/M0-findings.md`.
- [ ] The Opening a PR and Ticket playbooks say round one starts at the first push and CI runs alongside; a green CI is required before merge-ready and STACK-READY, not before round one.
- [ ] The Babysit and Ticket playbooks name `gh run watch` (or the harness's Monitor on the run) for a CI wait and forbid sleep loops; `grep -rn "sleep 60" template/.agents/skills/poteto-mode/playbooks/` prints nothing.
- [ ] Ticket step 5 runs blast radius from the design and the table beside the writer, not after it, and says the PR body's Blast Radius section is checked against the final diff at step 8.
- [ ] No playbook and no skill skips the Spec axis in any round; `tests/spec-review/no-stale-wording.sh` fails on the phrase "table unchanged" under `template/`.
- [ ] `./factory918.sh sync` leaves `git status` clean and every changed patch reproduces with the `patches/README.md` command.
- [ ] The Ticket playbook says the trail review (the show-me-your-work cross-model read of the decision trail) runs on every PR before it is reported ready; three of five lanes ran it on 2026-09-22 and all three found something the owner had wrong.
- [ ] The Opening a PR playbook's ShellCheck line names the changed shell files as arguments; the bare form lints only the default globs, and the playbook says so.
- [ ] `AGENTS.md` "Verifying" lists `bash tests/spec-review/no-stale-wording.sh`.
- [ ] The Bug fix and Feature playbooks say a fix lane proves its change on the path CI takes (a lane whose machine already has the pinned tool never runs the download path; PR #96 lost a CI cycle to that).
- [ ] The poll rule names the exact absolute path the lane was told to write, since a lane writing under its own worktree's scratch is invisible to a poll on the shared path (PR #101's owner waited seven minutes for a file that existed elsewhere).
- [ ] The autopilot-stack playbook says the root's registry lines carry `date` output, never a typed time; the root's hand-written times drifted up to forty minutes on 2026-09-22.
- [ ] The Ticket playbook says when an agent may touch a closed ticket's approved design record: only when a later PR changes what the record describes, only by appending a dated, attributed paragraph that names the PR, never by editing an existing line or cell, and the PR body lists the amendment under Records (Manuel approved this policy 2026-09-22 on the condition that it is safe and changes nothing that was already done).

## Blocked by

None.


