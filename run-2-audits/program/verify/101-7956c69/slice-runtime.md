# Slice: live runtime floor
Exercise `review-brief.sh` at the SHA on real diffs, using `tests/spec-review/fake-gh.sh`'s technique for a fake `gh`
where a PR body is needed (read the test harness first). Build a scratch git repository (or use `git worktree`-free
clones under your TMPDIR) with a cross-cutting diff (touch a file under `.claude/hooks/`) and:
(a) a grounding file with `## Risks` passed via `--blast-radius FILE`: the Spec brief's `## Walk` rule must carry,
    after the per-step lines, the sentence requiring one numbered line per risk; quote the emitted bullet; the
    Standards brief must not carry it.
(b) the same grounding with `### Risks` (demoted, as a pasted PR body has it), in a file and in a fake PR body (with
    CRLF too): same result.
(c) a grounding with no Risks heading, and one where Risks appears only inside a fenced block: refused, exit 1, no
    state written under `.claude/state/review/`, message says what to correct.
(d) a non-cross-cutting diff: no sentence, and `--blast-radius` ignored with the stderr note.
(e) `review-comment.sh` on a Spec report whose `## Walk` continues with two risk lines: the walk lines are steps, not
    items; the comment's numbering and `act-on items:` line unchanged versus a walk without them.
(f) Quote the changed prose in `template/.agents/skills/spec-review/SKILL.md` and the Opening a PR playbook's Blast
    Radius bullet (`template/.agents/skills/poteto-mode/playbooks/opening-a-pr.md`), and say whether an agent can
    follow each; a contradiction with the Ticket playbook step 5 is an issue.
Report: `/Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.scratch/program/verify/101-7956c69/worker-runtime.md`.
