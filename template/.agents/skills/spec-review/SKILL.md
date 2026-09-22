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

Run `scripts/review-brief.sh <fixed-point>` (the script beside this skill; add `--ticket N` when the commits do not name the ticket, `--standards FILE ...` to review against files other than `CODING_STANDARDS.md`, `--blast-radius FILE` for a cross-cutting diff whose grounding is not yet in a PR body). It runs the diff once, `git diff <fixed-point>...HEAD` (three-dot, so the comparison is against the merge-base), plus `--stat` for the changed-file list with per-file line counts, and the list of commits via `git log <fixed-point>..HEAD --oneline`, and writes the three to `.scratch/review/<id>/` as `diff`, `stat` and `log`. It also writes the review state under `.claude/state/review/`: `fixed-point`, `files` (the changed paths, one per line) and `dir`. While that state exists the delegation hook blocks your reads of the changed files, and step 6 clears it. Do not read the diff yourself: the reviewers get it in their briefs, and you get their reports.

The script confirms the fixed point resolves and the diff is non-empty, and exits 1 with a message otherwise. A bad ref or empty diff fails here, not inside two parallel sub-agents.

One PR gets at most three rounds, and a round is over when its comment is posted. The script reads the branch's PR comments that carry a line `act-on items:` (`gh pr view --json comments`); the round is one more than the highest `round: N of 3` line among them (a comment without one is round 1), so a comment rebuilt in the same round does not advance it. A comment carrying a line that is exactly `restart` (step 6: a design hole returned to architect) ends the history: the round and the settled items are read from the comments after the last such comment, the script says so with a line `restart:`, so the redesign's first review is round 1 with nothing carried, and the fourth-round refusal counts only what follows it. It writes the round to `<dir>/round`, prints `round: N of 3`, and exits 1 before writing any state when three rounds were run: what remains under Act on is then fixed on this PR and marked `fixed: <sha>` (step 5), not reviewed in a fourth round. Only comments by the PR's author, the account the orchestrator posts under, are read; a comment by anyone else neither counts a round nor reaches the briefs. No PR is round 1 with nothing carried; any other `gh` failure is printed and treated the same way, so the run goes on and you see why. `--round N` sets the round directly and `--previous FILE` supplies the earlier review comments from a file instead of `gh`, for a branch whose PR is elsewhere.

A cross-cutting diff, one whose changed paths include a `.claude/hooks/` file, a `.claude/settings.json` or a file of the `factory918` skill (`.agents/skills/factory918/`), at any depth, is briefed only with its blast-radius grounding (the Ticket playbook, step 5): the script takes it from `--blast-radius FILE` when given, else from the `## Blast Radius` section of the branch's PR body (`gh pr view --json body`), and exits 1 before writing any state when neither holds one: "cross-cutting diff (<the matching paths>) without a blast-radius grounding; run the blast-radius skill, put the result in the PR body's Blast Radius section or pass --blast-radius FILE". For a diff that is not cross-cutting, `--blast-radius` is ignored, and the script says so on stderr.

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
- `## Blast radius`, for a cross-cutting diff (step 1), placed before the diff: the author's grounding verbatim, under exactly this paragraph: "The sessions and skills this change reaches, as the author grounded them before the review. Check the diff against each one; the grounding is the author's claim, not evidence." Absent for any other diff.
- The diff itself, when it's under about 500 lines. Over that, the brief hands the path `<dir>/diff`, so a reviewer reads one file and runs nothing.
- `## Settled in earlier rounds`, from round two on: the Noted and Dismissed items that carry a `cites:` field (step 5) from every earlier round's comment, verbatim, in comment order and each line once, under exactly this paragraph: "These findings were raised in an earlier round and settled by the decision each one cites. Do not raise them again. Nothing in this section says what you should find or confirm." An item without a citation is dropped (the script prints how many it carried and dropped), and when nothing carries the section is absent. The section tells a reviewer what is closed, never what to find: a brief that named an expected result would be leading the witness.
- `## Report`, last. The definition, word for word as the script writes it: "A hard finding is one of two things: the documented path gives a wrong or silent result, or an input outside it proceeds silently (fails open). An input outside the documented path that is refused with a message saying how to correct it is not a finding; it is the design. Zero items is the expected result for a clean change." Then the five sentences of Manuel's that the definition follows, attributed, as the script writes them:
  - Manuel: "there are an infinite amount of unhappy paths and only 1 happy one"
  - Manuel: "AT MOST hardening to fail fast and loud if we move outside of that"
  - Manuel: "we notice the variable is unexpected and flag that without having to diagnose every reason the variable might be wrong for the user"
  - Manuel: "An edge case outside the intended path being unsupported is not a flag."
  - Manuel: "Primary focus must be the happy path, then unhappy paths that error in a way the user can correct."

  Then the axis's headings and item form (below), then the step rule, word for word: "Every item under `## Would break` or `## Fails open` carries a line `Documented step:` quoting the ticket line or the `file:line` of the documentation the user follows, and a line `Result:` saying what happens instead; an item without its `Documented step:` line is sent back." Then the spec rule, word for word: "The same item carries a line `spec:` naming the artifact it rests on: `table <row>/<column>` for a cell of the ticket's scenario table, `design <signature>` for a signature or usage in its `## Design` sketch, or `criterion <k>` for its k-th acceptance checkbox; an item without a `spec:` line in one of those three forms is sent back." Then the report path and the count rule, word for word: "End the report with exactly one line `hard findings: N`, where N is the number of items under `## Would break` and `## Fails open` and nothing else."

**The Standards brief** adds:

- The standards files named by `--standards` (default `CODING_STANDARDS.md`), pasted whole, so pass only the files that apply to the changed files. **Plus the smell baseline from step 3** pasted in full (the sub-agent has no other access to it).
- The report's headings, exactly these `## ` headings, in this order, each holding numbered items or nothing, word for word as the script writes them:
  - `## Would break`: a breach of a documented standard that makes the documented path give a wrong or silent result. Cite the standard (file + the rule) and quote the hunk.
  - `## Fails open`: a breach of a documented standard that lets an input outside the documented path proceed silently. Cite the standard (file + the rule) and quote the hunk.
  - `## Standards breaches`: documented-standard breaches that do not change behavior. Cite the standard and quote the hunk.
  - `## Fix alongside`: baseline smells and other judgement calls. Name the smell and quote the hunk. They are fixed only when a would-break fix already touches that code; they never count.

  Each item opens with `1. **Title.** body`, with the quoted hunk in a fenced block under it, numbered continuously across the headings. A documented repo standard overrides the baseline; skip anything tooling enforces; read nothing beyond the brief but the code around a hunk; under 400 words.

**The Spec brief** adds:

- The ticket body pasted in (What to build and Acceptance criteria, verbatim), then the ticket author's comments under `## Comments by the ticket's author (#N)`, each under `### <YYYY-MM-DD>` (absent when there are none), and the relevant section of the parent spec when there is one. Not a `gh` command or an issue number: the sub-agent fetches nothing.
- The report's headings, exactly these `## ` headings, in this order, each holding numbered items or nothing, word for word as the script writes them:
  - `## Walk`: one numbered line per documented step of the path the change touches (the ticket's criteria and the documentation the diff changes), each saying what the code does at that step. A walk, not findings: its lines are numbered 1..K on their own and count nothing. For a cross-cutting diff the bullet continues on the same line, word for word: "The diff is cross-cutting: after the lines per documented step, one numbered line per risk under the Risks heading of the `## Blast radius` section above, in its order and numbered on from the last step, each naming the risk and saying what the diff does at that risk; a risk line is a walk line and counts nothing."
  - `## Would break`: a requirement missing, partial, or implemented so that the documented path gives a wrong or silent result.
  - `## Fails open`: an input outside the documented path that proceeds silently instead of being refused with a message saying how to correct it.
  - `## Not asked for`: behaviour in the diff the ticket did not ask for.

  Each item opens with `1. **Title.** body` and quotes the spec line it rests on in a fenced block (a criterion can carry `## ` or `1. ` lines, and only fenced text is exempt from the report shape), numbered continuously across the headings from `## Would break` on; the walk's lines are numbered 1..K on their own and are not items; read nothing beyond the brief but the code around a hunk; under 400 words.

If the spec is missing, the script writes no Spec brief; skip the Spec sub-agent, and step 6 says so in the final report.

The Standards sub-agent runs through the configured `standards reviewer` descriptor (`~/.claude/pstack-models.md`, default `claude:opus@medium`), resolved per [`provider-dispatch.md`](../poteto-mode/references/provider-dispatch.md), in `read-only` mode; a native lane is the matching `pstack-<family>-<effort>` subagent. The Spec sub-agent runs through the configured `spec reviewer` descriptor (default `claude:opus@high`), resolved the same way, read-only: the reviewer's context matters more than its model, since the brief carries everything it reads and the orchestrator judges what it finds in step 5. A sheet without a row uses that row's default. Without a models sheet, both run on the parent's subagent primitive at the parent's model.

### 5. Judge

Read the two reports and the ticket, never the code under review (the delegation hook enforces this while the review state exists), and write `<dir>/judgment.md`, following [`lead-judgment.md`](../interrogate/references/lead-judgment.md): a reviewer with nothing critical inflates nits, so a report that is all nits means the code is probably fine; more than five Act on items means you are not filtering; the Dismissed list is shown so the human can overrule you.

Five `## ` headings, in this order, each holding numbered items or nothing:

- `## Act on`: the documented path gives a wrong or silent result, or an input outside it proceeds silently (fails open), or a breach worth fixing on this PR. Counted.
- `## Ask`: a finding in the ask-by-default categories of [`bugbot-triage.md`](../poteto-mode/references/bugbot-triage.md): security, privacy, auth, billing, data, migrations, concurrency, cross-system. You never dismiss one of these; it waits for the human. Counted.
- `## Consider`: a legitimate point you are not sure outweighs the cost of addressing it now.
- `## Noted`: valid but not actionable here.
- `## Dismissed`: wrong, nitpicky or missing context, and why.

Each item is `1. [S2] **Title.** reason`: `[S2]` is the Standards report's second item and `[P1]` the Spec report's first, counted across every heading of that report in document order, the Spec report's `## Walk` lines being steps and not items; the reason is one line. Number the judgment's items the same way, 1..N continuously across the five headings; step 6 refuses a numbering that restarts under a heading. Every numbered item in both reports appears exactly once in the judgment; step 6 refuses a judgment that misses, repeats or invents a reference.

A `## Fix alongside` item from the Standards report goes under Act on when an Act on item's fix touches the same code, otherwise under Noted.

An Ask item waits for the human. When the human answers, move it to the bucket the answer settles, with the answer as the one-line reason, renumber the items so the written numbers run 1..N in document order again, and rerun `scripts/review-comment.sh <dir>` on the same reports; that is the same round, not a new one.

A finding is a design hole when its fix changes the artifact the work was built against rather than the code that implements it. Three artifacts, and every ticket has at least one: the scenario table under `## Testing decisions` (a cell's expected outcome, a new row or column, or the contract's meaning of a term the cells use, such as what counts as in flight, a named path, a covering go); the usage and signature sketch under `## Design` (a signature, a type, or how a caller uses it); the acceptance criteria (what a criterion asks for). The ticket's intent, its What to build or Decision quotes, outranks any one criterion: a criterion that must change is a hole, and architect re-derives it from the intent. A refusal added under an existing could-not-run clause is not a hole. Detection is sharpest for a table and softest for a criterion; test for all three. Every counted report item names what it rests on in its `spec:` line (step 4): the finding is a hole when its fix changes that thing, and an implementation bug when the artifact stands and the code fails it.

Four trailing fields, each with one grammar:

- `cites: <decision>` on a Noted or Dismissed item names the decision it rests on, one of `user: "<quoted words>" on #N` (a `user:` blockquote in the ticket body), `DECISIONS.md <row id>` (`P17`, `19`), `#N comment <YYYY-MM-DD>` (a ticket comment by the ticket's author) or `#N <reference>` (a cell, signature or criterion of the ticket in the `spec:` grammar: `#N table <row>/<column>`, `#N design <signature>`, `#N criterion <k>`). Nothing else counts. Only a cited item carries into every later round's briefs as settled; an uncited Noted or Dismissed item is a normal one and the next round's reviewer may raise it again. An item you cannot cite is not settled, however sure you are.
- `ticket: #N` on an Act on item means the finding was filed as its own ticket because it is outside this PR's scope, in any round, and step 6 does not count it.
- `fixed: <sha>` on an Act on item names the commit on this PR that fixed it, and step 6 does not count it either. At round three the Act on items are fixed on this PR by a fix lane; then you mark each `fixed: <sha>`, renumber, and rerun `scripts/review-comment.sh <dir>`. Those fixes are not reviewed again: Manuel's rule is that after three passes the rest is found the hard way. An Ask item is never fixed or filed away; it waits for the human.
- `hole: <reference>` on an Act on item says the finding's fix changes the artifact, not the code: it repeats the judged report item's `spec:` line word for word (`table <row>/<column>`, `design <signature>` or `criterion <k>`); step 6 leaves it out of the count and prints the line `restart`. A hole is never fixed on this PR: the Ticket playbook's Design hole section returns the work to `architect` scoped to that reference, and the redesign is reviewed from round one.

### 6. Aggregate

Run `scripts/review-comment.sh`. It prints the two reports under `## Standards` and `## Spec` (or `no spec: Standards axis only`), the judgment under `## Judgment`, all verbatim, a one-line summary, the line `restart` on its own when any Act on item carries `hole:`, the line `round: N of 3` from `<dir>/round` (1 when the file is missing), and the final line `act-on items: N`, where N is the number of items under `## Act on` without a `fixed:`, `ticket:` or `hole:` field plus the number under `## Ask`; then it clears `.claude/state/review/`. Zero is written as `act-on items: 0`. Babysit reads this line, so it is always present and always last.

It exits 1, printing why and clearing nothing, when a report is missing or has no `hard findings:` line (wait for the reviewer; do not write the report yourself); when a report's `hard findings: N` is larger than its `## Would break` and `## Fails open` item count (ask the reviewer to re-sort); when a `## Would break` or `## Fails open` item has no `Documented step:` line (ask the reviewer for the step and the result); when a `## Would break` or `## Fails open` item has no `spec:` line in one of the three forms (ask the reviewer for it); when a `hole:` field sits under a heading other than Act on, fits no form, or is not, word for word, the `spec:` value of the report item it judges (a wrong reference, or an item that carries no `spec:` line); when a report's or the judgment's `## ` headings are not the shape above; when a report's or the judgment's items are not numbered 1..N continuously across its headings, in document order; when `judgment.md` is missing; when the judgment's item count differs from the reports'; when a `[S<n>]` or `[P<n>]` reference is missing, repeated or points at no item; or when `<dir>/round` holds no number (rerun `review-brief.sh`). An off-shape report goes back to its reviewer with the refusal text; a new round is not started for it.

With the review dir as its argument, `scripts/review-comment.sh .scratch/review/<id>`, it reruns on the same reports after the state is gone: an Ask item the human answered, or a report sent back and rewritten. Same round; the `round:` line comes from the dir.

Do **not** merge or rerank findings across the two reports, because the two axes are deliberately separate (see _Why two axes_), and do not pick a single winner across axes: that's the reranking the separation exists to prevent. The judgment is a third section, not a rewrite of either report.

You write only what goes above the script's output: the two plain sentences for a person. Nothing else in the comment is yours. They end with a signature, the model and harness: `Claude Fable 5.1 on Claude Code` when the comment is posted without the human's approval, and `Claude Fable 5.1 on Claude Code, approved by <name>` when the human approved it before posting; only an approved comment posted from the author's account counts as the author's words.

## Why two axes

A change can pass one axis and fail the other:

- Code that follows every standard but implements the wrong thing → **Standards pass, Spec fail.**
- Code that does exactly what the issue asked but breaks the project's conventions → **Spec pass, Standards fail.**

Reporting them separately stops one axis from masking the other.
