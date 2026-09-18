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

Run the diff once: `git diff <fixed-point>...HEAD` (three-dot, so the comparison is against the merge-base), plus `git diff <fixed-point>...HEAD --stat` for the changed-file list with per-file line counts, and the list of commits via `git log <fixed-point>..HEAD --oneline`. Keep all three outputs; step 4 pastes them into both briefs.

Before going further, confirm the fixed point resolves (`git rev-parse <fixed-point>`) and the diff is non-empty. A bad ref or empty diff should fail here, not inside two parallel sub-agents.

### 2. Identify the spec source

Look for the originating spec, in this order:

1. Issue references in the commit messages (`#123`, `Closes #45`, GitLab `!67`, etc.), fetched via the workflow in `docs/agents/issue-tracker.md`.
2. A path the user passed as an argument.
3. A spec file under `docs/`, `specs/`, or `.scratch/` matching the branch name or feature.
4. If nothing is found, the **Spec** sub-agent skips and the report says, in these words, "no spec: Standards axis only". Never use the PR description, a commit message, or your own account of the change as the spec: those are the author's words, and the Spec axis exists to check the work against the human's. A spec arrives only as a ticket, a path the user passed, or a spec file.

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

A reviewer that gets a diff command and two file names runs the diff and reads both files whole, and that discovery is most of what it costs. So the briefs carry content, not commands: the material from step 1 is computed once and the same text goes into both.

**Both prompts** include, pasted in:

- The commit list (the `git log <fixed-point>..HEAD --oneline` output).
- The changed-file list with per-file line counts (the `--stat` output).
- The diff itself, when it's under about 500 lines. Over that, write it to `.scratch/review/<fixed-point>.diff` and hand the path, so a reviewer reads one file and runs nothing.

**Standards sub-agent prompt** adds:

- The sections of the standards sources from step 3 that apply to the changed files, pasted in (the shell section for `.sh` changes, the "Pull requests" section for a PR-body rule), not the file names; a whole file only when it's under about 80 lines. **Plus the smell baseline from step 3** pasted in full (the sub-agent has no other access to it).
- The brief: "Report, per file/hunk where relevant, (a) every place the diff violates a documented standard: cite the standard (file + the rule); and (b) any baseline smell you spot: name it and quote the hunk. Distinguish hard violations from judgement calls: documented-standard breaches can be hard, but baseline smells are always judgement calls, and a documented repo standard overrides the baseline. Skip anything tooling enforces. Read nothing beyond this brief unless a finding needs the code around a hunk, and then read that one function or section, not the file. Under 400 words."

**Spec sub-agent prompt** adds:

- The ticket body pasted in (What to build and Acceptance criteria, verbatim), and the relevant section of the parent spec when there is one. Not a `gh` command or an issue number: the sub-agent fetches nothing.
- The brief: "Report: (a) requirements the spec asked for that are missing or partial; (b) behaviour in the diff that wasn't asked for (scope creep); (c) requirements that look implemented but where the implementation looks wrong. Quote the spec line for each finding. Read nothing beyond this brief unless a finding needs the code around a hunk, and then read that one function or section, not the file. Under 400 words."

If the spec is missing, skip the Spec sub-agent and note this in the final report.

The Standards sub-agent runs through the configured `standards reviewer` descriptor (`~/.claude/pstack-models.md`, default `claude:opus@medium`), resolved per [`provider-dispatch.md`](../poteto-mode/references/provider-dispatch.md), in `read-only` mode; a native lane is the matching `pstack-<family>-<effort>` subagent. The Spec sub-agent runs on the writer's lane, the `feature, refactoring` descriptor, because judging whether the work matches the ask is the senior's call. A sheet without the `standards reviewer` row uses that default. Without a models sheet, both run on the parent's subagent primitive at the parent's model.

### 5. Aggregate

Present the two reports under `## Standards` and `## Spec` headings, verbatim or lightly cleaned. Do **not** merge or rerank findings, because the two axes are deliberately separate (see _Why two axes_).

End with a one-line summary: total findings per axis, and the worst issue _within each axis_ (if any). Don't pick a single winner across axes: that's the reranking the separation exists to prevent.

The report's final line is exactly `act-on items: N`. N counts the hard findings on both axes: on Standards, documented-standard breaches (baseline smells and judgement calls don't count); on Spec, requirements missing or partial, implementations that look wrong, and behaviour that wasn't asked for. Zero is written as `act-on items: 0`. Babysit reads this line, so it is always present and always last.

## Why two axes

A change can pass one axis and fail the other:

- Code that follows every standard but implements the wrong thing → **Standards pass, Spec fail.**
- Code that does exactly what the issue asked but breaks the project's conventions → **Spec pass, Standards fail.**

Reporting them separately stops one axis from masking the other.
