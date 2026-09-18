---
name: spec-review
description: "Review the changes since a fixed point (commit, branch, tag, or merge-base) along two axes: Standards (does the code follow this repo's documented coding standards?) and Spec (does the code match what the originating issue/spec asked for?). Runs both reviews in parallel sub-agents and reports them side by side. Use when the user wants to review a branch, a PR, work-in-progress changes, or asks to \"review since X\"."
---

Two-axis review of the diff between `HEAD` and a fixed point the user supplies:

- **Standards**: does the code conform to this repo's documented coding standards?
- **Spec**: does the code faithfully implement the originating issue / spec?

Both axes run as **parallel sub-agents** so they don't pollute each other's context, then this skill aggregates their findings.

The issue tracker should have been provided to you. If `docs/agents/issue-tracker.md` is missing, tell the user to run `/setup-matt-pocock-skills`.

## Process

### 1. Pin the fixed point

Whatever the user said is the fixed point (a commit SHA, branch name, tag, `main`, `HEAD~5`, etc.). If they didn't specify one, ask for it.

Run `scripts/review-brief.sh <fixed-point>` (the script beside this skill; add `--ticket N` when the commits do not name the ticket, `--standards FILE ...` to review against files other than `CODING_STANDARDS.md`). It runs the diff once, `git diff <fixed-point>...HEAD` (three-dot, so the comparison is against the merge-base), plus `--stat` for the changed-file list with per-file line counts, and the list of commits via `git log <fixed-point>..HEAD --oneline`, and writes the three to `.scratch/review/<id>/` as `diff`, `stat` and `log`. It also writes the review state under `.claude/state/review/`: `fixed-point`, `files` (the changed paths, one per line) and `dir`. While that state exists the delegation hook blocks your reads of the changed files, and step 6 clears it. Do not read the diff yourself: the reviewers get it in their briefs, and you get their reports.

The script confirms the fixed point resolves and the diff is non-empty, and exits 1 with a message otherwise. A bad ref or empty diff fails here, not inside two parallel sub-agents.

One PR gets at most three rounds, and a round is over when its comment is posted. The script counts the branch's PR comments that carry a line `act-on items:` (`gh pr view --json comments`; no PR, or no `gh`, is round 1), writes the count plus one to `<dir>/round`, prints `round: N of 3`, and exits 1 before writing any state when three rounds were run: what remains under Act on then becomes tickets (step 5), not a fourth round. `--round N` sets the round directly and `--previous FILE` supplies the latest review comment from a file, for a branch whose PR is elsewhere.

A sweep over units already on `main`, named by paths and commits, is the same skill with the same state, not a second mode: `scripts/review-brief.sh --paths P... --commits SHA...` writes the word `paths` as the fixed point and `git show <commits> -- <paths>` as the diff.

### 2. Identify the spec source

Look for the originating spec, in this order:

1. Issue references in the commit messages (`#123`, `Closes #45`, GitLab `!67`, etc.), fetched via the workflow in `docs/agents/issue-tracker.md`.
2. A path the user passed as an argument.
3. A spec file under `docs/`, `specs/`, or `.scratch/` matching the branch name or feature.
4. If nothing is found, the **Spec** sub-agent skips and the report says, in these words, "no spec: Standards axis only". Never use the PR description, a commit message, or your own account of the change as the spec: those are the author's words, and the Spec axis exists to check the work against the human's. A spec arrives only as a ticket, a path the user passed, or a spec file.

With a ticket, the script fetches its body and the comments posted by the ticket's author (`gh issue view N --json author,comments`, the login that opened the ticket), and pastes both into the Spec brief; comments by anyone else, and the PR's own comments, are never spec.

### 3. Identify the standards sources

Anything in the repo that documents how code should be written, such as `CODING_STANDARDS.md` or `CONTRIBUTING.md`.

On top of whatever the repo documents, the Standards axis always carries the **smell baseline** below: a fixed set of Fowler code smells (_Refactoring_, ch.3) that applies even when a repo documents nothing. Two rules bind it:

- **The repo overrides.** A documented repo standard always wins; where it endorses something the baseline would flag, suppress the smell.
- **Always a judgement call.** Each smell is a labelled heuristic ("possible Feature Envy"), never a hard violation. Like any standard here, skip anything tooling already enforces.

Each smell reads *what it is* → *how to fix*; match it against the diff:

- **Mysterious Name**: a function, variable, or type whose name doesn't reveal what it does or holds. → rename it; if no honest name comes, the design's murky.
- **Duplicated Code**: the same logic shape appears in more than one hunk or file in the change. → extract the shared shape, call it from both.
- **Feature Envy**: a method that reaches into another object's data more than its own. → move the method onto the data it envies.
- **Data Clumps**: the same few fields or params keep travelling together (a type wanting to be born). → bundle them into one type, pass that.
- **Primitive Obsession**: a primitive or string standing in for a domain concept that deserves its own type. → give the concept its own small type.
- **Repeated Switches**: the same `switch`/`if`-cascade on the same type recurs across the change. → replace with polymorphism, or one map both sites share.
- **Shotgun Surgery**: one logical change forces scattered edits across many files in the diff. → gather what changes together into one module.
- **Divergent Change**: one file or module is edited for several unrelated reasons. → split so each module changes for one reason.
- **Speculative Generality**: abstraction, parameters, or hooks added for needs the spec doesn't have. → delete it; inline back until a real need shows.
- **Message Chains**: long `a.b().c().d()` navigation the caller shouldn't depend on. → hide the walk behind one method on the first object.
- **Middle Man**: a class or function that mostly just delegates onward. → cut it, call the real target direct.
- **Refused Bequest**: a subclass or implementer that ignores or overrides most of what it inherits. → drop the inheritance, use composition.

### 4. Spawn both sub-agents in parallel

The briefs are the two files step 1 wrote, `<dir>/standards-brief.md` and `<dir>/spec-brief.md` (the script printed both paths). They carry content, not commands: the material from step 1 is computed once and the same text goes into both. Each sub-agent's prompt is its brief's path and the instruction to read it whole and follow it. Each reviewer writes its report to `<dir>/standards-report.md` or `<dir>/spec-report.md`, ending with the line `hard findings: N`, and replies with only that path; step 6 reads the files, not the replies.

**Both briefs** carry:

- The commit list (the `git log <fixed-point>..HEAD --oneline` output).
- The changed-file list with per-file line counts (the `--stat` output).
- The diff itself, when it's under about 500 lines. Over that, the brief hands the path `<dir>/diff`, so a reviewer reads one file and runs nothing.
- `## Settled in earlier rounds`, from round two on: the previous round's Noted and Dismissed items that carry a `cites:` field (step 5), verbatim, under exactly this paragraph: "These findings were raised in an earlier round and settled by the decision each one cites. Do not raise them again. Nothing in this section says what you should find or confirm." An item without a citation is dropped (the script prints how many it carried and dropped), and when nothing carries the section is absent. The section tells a reviewer what is closed, never what to find: a brief that named an expected result would be leading the witness.

**The Standards brief** adds:

- The standards files named by `--standards` (default `CODING_STANDARDS.md`), pasted whole, so pass only the files that apply to the changed files. **Plus the smell baseline from step 3** pasted in full (the sub-agent has no other access to it).
- The report shape. The definition first, word for word as the script writes it: "A hard finding is wrong behavior in normal use: a command, hook, script or documented flow does something other than what the ticket or its own documentation says it does, on the path a user takes." Then exactly these `## ` headings, in this order, each holding numbered items or nothing: `## Would break` (a breach of a documented standard that produces wrong behavior in normal use), `## Standards breaches` (documented-standard breaches that do not change behavior), `## Fix alongside` (baseline smells and other judgement calls; they are fixed only when a would-break fix already touches that code; they never count). Each item opens with `1. **Title.** body`, cites the standard and quotes the hunk in a fenced block, numbered continuously across the headings. A documented repo standard overrides the baseline; skip anything tooling enforces; read nothing beyond the brief but the code around a hunk; under 400 words. The last line is `hard findings: N`, where N is the number of items under `## Would break` and nothing else.

**The Spec brief** adds:

- The ticket body pasted in (What to build and Acceptance criteria, verbatim), then the ticket author's comments under `## Comments by the ticket's author (#N)`, each under `### <YYYY-MM-DD>` (absent when there are none), and the relevant section of the parent spec when there is one. Not a `gh` command or an issue number: the sub-agent fetches nothing.
- The report shape. The same definition, then exactly these `## ` headings, in this order: `## Would break` (a requirement missing, partial, or implemented so that normal use does something other than the ticket says), `## Latent` (edge cases, visibility, policy, wording; anything a user would not hit in normal use), `## Not asked for` (behaviour in the diff the ticket did not ask for). Each item opens with `1. **Title.** body` and quotes the spec line it rests on in a fenced block (a criterion can carry `## ` or `1. ` lines, and only fenced text is exempt from the report shape), numbered continuously across the headings; read nothing beyond the brief but the code around a hunk; under 400 words. The last line is `hard findings: N`, the number of items under `## Would break` and nothing else.

If the spec is missing, the script writes no Spec brief; skip the Spec sub-agent, and step 6 says so in the final report.

The Standards sub-agent runs through the configured `standards reviewer` descriptor (`~/.claude/pstack-models.md`, default `claude:opus@medium`), resolved per [`provider-dispatch.md`](../poteto-mode/references/provider-dispatch.md), in `read-only` mode; a native lane is the matching `pstack-<family>-<effort>` subagent. The Spec sub-agent runs through the configured `spec reviewer` descriptor (default `claude:opus@high`), resolved the same way, read-only: the reviewer's context matters more than its model, since the brief carries everything it reads and the orchestrator judges what it finds in step 5. A sheet without a row uses that row's default. Without a models sheet, both run on the parent's subagent primitive at the parent's model.

### 5. Judge

Read the two reports and the ticket, never the code under review (the delegation hook enforces this while the review state exists), and write `<dir>/judgment.md`, following [`lead-judgment.md`](../interrogate/references/lead-judgment.md): a reviewer with nothing critical inflates nits, so a report that is all nits means the code is probably fine; more than five Act on items means you are not filtering; the Dismissed list is shown so the human can overrule you.

Five `## ` headings, in this order, each holding numbered items or nothing:

- `## Act on`: wrong behavior in normal use, or a breach worth fixing on this PR. Counted.
- `## Ask`: a finding in the ask-by-default categories of [`bugbot-triage.md`](../poteto-mode/references/bugbot-triage.md): security, privacy, auth, billing, data, migrations, concurrency, cross-system. You never dismiss one of these; it waits for the human. Counted.
- `## Consider`: a legitimate point you are not sure outweighs the cost of addressing it now.
- `## Noted`: valid but not actionable here.
- `## Dismissed`: wrong, nitpicky or missing context, and why.

Each item is `1. [S2] **Title.** reason`: `[S2]` is the Standards report's second item and `[P1]` the Spec report's first, counted across every heading of that report in document order; the reason is one line. Every numbered item in both reports appears exactly once in the judgment; step 6 refuses a judgment that misses, repeats or invents a reference.

A `## Fix alongside` item from the Standards report goes under Act on when an Act on item's fix touches the same code, otherwise under Noted.

An Ask item waits for the human. When the human answers, move it to the bucket the answer settles, with the answer as the one-line reason, and rerun `scripts/review-comment.sh <dir>` on the same reports; that is the same round, not a new one.

Two trailing fields, each with one grammar:

- `cites: <decision>` on a Noted or Dismissed item names the decision it rests on, one of `user: "<quoted words>" on #N` (a `user:` blockquote in the ticket body), `DECISIONS.md <row id>` (`P17`, `19`) or `#N comment <YYYY-MM-DD>` (a ticket comment by the ticket's author). Nothing else counts. Only a cited item carries into the next round's briefs as settled; an uncited Noted or Dismissed item is a normal one and the next round's reviewer may raise it again. An item you cannot cite is not settled, however sure you are.
- `ticket: #N` on an Act on item means the finding was filed as its own ticket, and step 6 does not count it. At round three, what remains under Act on is filed as tickets, one each, and marked so; an Ask item is never filed away, it waits for the human.

### 6. Aggregate

Run `scripts/review-comment.sh`. It prints the two reports under `## Standards` and `## Spec` (or `no spec: Standards axis only`), the judgment under `## Judgment`, all verbatim, a one-line summary, the line `round: N of 3` from `<dir>/round` (1 when the file is missing), and the final line `act-on items: N`, where N is the number of items under `## Act on` without a `ticket:` field plus the number under `## Ask`; then it clears `.claude/state/review/`. Zero is written as `act-on items: 0`. Babysit reads this line, so it is always present and always last.

It exits 1, printing why and clearing nothing, when a report is missing or has no `hard findings:` line (wait for the reviewer; do not write the report yourself); when a report's `hard findings: N` is larger than its `## Would break` item count (ask the reviewer to re-sort); when a report's or the judgment's `## ` headings are not the shape above; when `judgment.md` is missing; when the judgment's item count differs from the reports'; when a `[S<n>]` or `[P<n>]` reference is missing, repeated or points at no item; or when `<dir>/round` holds no number (rerun `review-brief.sh`). An off-shape report goes back to its reviewer with the refusal text; a new round is not started for it.

With the review dir as its argument, `scripts/review-comment.sh .scratch/review/<id>`, it reruns on the same reports after the state is gone: an Ask item the human answered, or a report sent back and rewritten. Same round; the `round:` line comes from the dir.

Do **not** merge or rerank findings across the two reports, because the two axes are deliberately separate (see _Why two axes_), and do not pick a single winner across axes: that's the reranking the separation exists to prevent. The judgment is a third section, not a rewrite of either report.

You write only what goes above the script's output: the two plain sentences for a person. Nothing else in the comment is yours.

## Why two axes

A change can pass one axis and fail the other:

- Code that follows every standard but implements the wrong thing → **Standards pass, Spec fail.**
- Code that does exactly what the issue asked but breaks the project's conventions → **Spec pass, Standards fail.**

Reporting them separately stops one axis from masking the other.
