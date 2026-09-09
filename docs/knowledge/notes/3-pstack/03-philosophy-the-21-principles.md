<!-- lines: 64 | source: notes/3-pstack.md | part 3/11 | title: Research note: pstack — Philosophy: the 21 principles -->

## Contents (line numbers are for the Read tool's offset)
- L6: Philosophy: the 21 principles

## Philosophy: the 21 principles

Each principle is its own skill folder (`skills/principle-*/SKILL.md`), grouped by the poteto-mode index into core / architecture / verification / delegation / meta (`skills/poteto-mode/SKILL.md`, lines 37–75). The one-liner below is the verbatim `description:` from each SKILL.md frontmatter, then one paragraph on what it means in practice.

**Core**

1. **Laziness Protocol** — "Apply when refactoring, evaluating diff size, or tempted to add abstractions, layers, or signal threading. Bias toward deletion and the smallest change that solves the problem." The body's prime directive: "If a human developer would find the code exhausting to maintain, it is a bad solution. Be lazy. Stay simple." It is the anti-over-engineering rule: prefer deletion, flat call hierarchy (flatten anything that takes more than three files to trace), minimize the diff.

2. **Foundational Thinking** — "Apply before writing logic: choosing core types and data structures, sequencing scaffold-vs-feature work, asking what concurrent actors share. Get the data structures right so downstream code becomes obvious." Data structures first; scaffold (CI, tests, shared types) before features; "Subtraction comes before scaffolding".

3. **Redesign from First Principles** — "Apply when integrating a new requirement into an existing design. Redesign as if the requirement had been a foundational assumption from day one, instead of bolting it on." Ask "if we were writing this from scratch with this new requirement, what would we build?" then deliver incrementally.

4. **Subtract Before You Add** — "Apply when sequencing an addition, refactor, or rewrite. Remove dead weight, redundant validators, and stub references first, then build on the simpler base." "Cut before you polish"; no speculative validators or guards.

5. **Minimize Reader Load** — "Apply when reviewing or shaping code that's hard to trace. Count layers between question and answer, and hidden state in the reader's head; collapse one-caller wrappers and shrink mutable scope." The test: "Can a new reader answer 'where does X come from?' and 'what can change X?' in under 30 seconds?"

6. **Outcome-Oriented Execution** — "Apply during planned rewrites and migrations with explicit phase boundaries. Converge on the target architecture; don't preserve smooth intermediate states with throwaway compatibility code." Planned, scoped breakage mid-migration is fine; full verification at the end is mandatory.

7. **Experience First** — "Apply when product, UX, or feature-scope tradeoffs come up. Choose user delight over implementation convenience; ship fewer polished features over more rough ones." Notably it widens "user" to "the colleague who imports it" and "the engineer who maintains the code next".

8. **Exhaust the Design Space** — "Apply when facing a novel UI interaction or architectural decision with no precedent in the codebase. Build 2-3 competing prototypes and compare side by side before committing." "Design it twice is this rule by another name. A second flavor of the first shape does not count." This is what `/arena` and `/architect` mechanize.

9. **Build the Lever** — "Apply to any non-trivial work, not just bulk work: edits, migrations, analyses, checks. Build the tool that does it or proves it (codemod, script, generator, or a skill your subagents follow) instead of working by hand. The tool is the artifact a reviewer can rerun." Hard rule: "Applying this principle produces a file. If you cited it and there is no codemod, script, generator, or delegate skill in the diff, you didn't apply it." (added 2026-05-26)

**Architecture**

10. **Model the Domain** — "Apply when writing stateful logic, or when code branches a lot or repeats a shape assumption across files. Encode the domain in a structure instead of scattered conditionals." State machine over scattered booleans, table/registry over branching, reducer over ad hoc mutation. "The tell that you skipped this is a new feature that grows an existing if/else chain by one more branch". (added 2026-07-11)

11. **Boundary Discipline** — "Apply when wiring validation, error handling, or framework adapters. Concentrate guards at system boundaries (CLI, config, network, external APIs); trust internal types and keep business logic in pure functions." "Is this data crossing a system boundary right now? If not, validation is redundant."

12. **Type System Discipline** — "Apply when designing types, reviewing a function signature, or writing code in any statically-typed language. Make illegal states unrepresentable, brand semantic primitives, parse external data at boundaries, refuse to lie to the compiler, exhaust variants, derive from authoritative schemas." "The type checker is a proof assistant." Includes the nuance "Strengthen a type only where partiality appears" (don't over-precise types).

13. **Make Operations Idempotent** — "Apply when designing commands, lifecycle steps, or processing loops that run amid crashes, restarts, and retries. Converge to the same end state regardless of partial prior runs." The test: "What happens if this runs twice? What happens if the previous run crashed halfway?"

14. **Migrate Callers Then Delete Legacy APIs** — "Apply when introducing a new internal API while old callers still exist. Migrate callers and delete the old API in the same wave instead of preserving compatibility layers." Scoped to internal APIs with no external consumers.

15. **Separate Before Serializing Shared State** — "Apply when concurrent actors might write to the same file, branch, key, or state object. Eliminate the sharing first; serialize structurally only when one shared writer is a real invariant." "Instructions and conventions are not concurrency control." This is why every parallel skill insists on one worktree per worker.

**Verification**

16. **Prove It Works** — "Apply after completing a task, before declaring done. Verify against the real artifact (run the feature, read the actual value, inspect the diff), not a proxy, self-report, or 'it compiles.'" "Delegation: trust artifacts, not self-reports." and "Script the check when you can."

17. **Fix Root Causes** — "Apply when debugging. Trace each symptom to its root cause and fix it there; reproduce first, ask why until you reach it, resist nil-check guards that silence crashes." Adds "Restart bugs: suspect state before code" and "If a workaround needs a paragraph-long comment to justify it, the code is wrong".

18. **Sequence Work into Verifiable Units** — "Apply to multi-step work (sweeps, migrations, runs of similar edits) and to how you stack commits and PRs. Break work into small units that each end in a verifiable state, check each before the next, and order delivery so the sequence proves itself to a reviewer." Canonical shape: failing test commit first, fix on top ("watch it go red, then green"). (added 2026-06-06)

**Delegation**

19. **Guard the Context Window** — "Apply when context is filling up: large outputs, long files, repeated reads, fan-out planning. Route bulk to subagents; keep summaries in the main thread, not raw payloads." "The context window is finite and non-renewable within a session."

20. **Never Block on the Human** — "Apply when tempted to ask 'should I do X?' on reversible work. Proceed, present the result, let the human course-correct after the fact; reserve confirmation for irreversible actions." "Code is cheap. Waiting is expensive." Boundaries: force-push, deleting production data, sending external messages still require confirmation; "Product direction comes from the human; execution should not block."

**Meta**

21. **Encode Lessons in Structure** — "Apply when you catch yourself writing the same instruction a second time, or notice a recurring correction. Encode the rule as a lint, metadata flag, runtime check, or script instead of more text." "The instruction IS the symptom." Pick the strongest rung: unrepresentable state > lint/banned API > canonical helper > runtime check.

How they are enforced: poteto-mode's first non-negotiable is "Start every multi-step task with a todolist whose first item is to read the Principles section below in full ... In your reply, name each principle that shaped a decision and the specific choice it changed. A citation with no decision behind it means you skipped its leaf skill" (`skills/poteto-mode/SKILL.md`, line 15). The guide adds that you steer with the names: "You don't invoke principles. You use their names to steer." (`docs/guide/08-principles.md`).

---
