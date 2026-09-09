<!-- lines: 61 | source: notes/6-deterministic-layer.md | part 7/10 | title: Research note: deterministic layer (verbatim config) — D. Matt Pocock — `research/1-matt-pocock/skills-repo/` -->

## Contents (line numbers are for the Read tool's offset)
- L10: D. Matt Pocock — `research/1-matt-pocock/skills-repo/`
- L14: D.1 `tdd`: seams, anti-patterns, mocking
- L31: D.2 `codebase-design`: vocabulary and the deletion test
- L44: D.3 `code-review`: two axes, standards sources, smell baseline, word cap
- L52: D.4 ADR format and a real ADR

## D. Matt Pocock — `research/1-matt-pocock/skills-repo/`

Last commit: `6654f6b 2026-08-24 feat: add 'Information access' category to retrospective skill`.

### D.1 `tdd`: seams, anti-patterns, mocking

`skills/engineering/tdd/SKILL.md`. Seam definition, verbatim: "A **seam** is the public boundary you test at: the interface where you observe behavior without reaching inside. Tests live at seams, never against internals."

Pre-agreed seams, verbatim: "**Test only at pre-agreed seams.** Before writing any test, write down the seams under test and confirm them with the user. No test is written at an unconfirmed seam. You can't test everything, so agreeing the seams up front is how testing effort lands on the critical paths and complex logic instead of every edge case." Then: "Ask: "What's the public interface, and which seams should we test?""

Anti-patterns (three):
- "**Implementation-coupled**: mocks internal collaborators, tests private methods, or verifies through a side channel (querying the database instead of using the interface). The tell: the test breaks when you refactor but behavior hasn't changed."
- "**Tautological**: the assertion recomputes the expected value the way the code does (`expect(add(a, b)).toBe(a + b)`, a snapshot derived by hand the same way, a constant asserted equal to itself), so it passes by construction and can never disagree with the code. Expected values must come from an independent source of truth: a known-good literal, a worked example, the spec."
- "**Horizontal slicing**: writing all tests first, then all implementation… Work in **vertical slices** instead: one test → one implementation → repeat, each test a **tracer bullet**".

Rules of the loop: "Red before green."; "One slice at a time."; "Refactoring is not part of the loop. It belongs to the review stage (see the `code-review` skill)".

`tests.md` shows the tautological pair: BAD `const expected = items.reduce((sum, i) => sum + i.price, 0); expect(calculateTotal(items)).toBe(expected);` vs GOOD `expect(calculateTotal([{ price: 10 }, { price: 5 }])).toBe(15);`, and the side-channel pair (querying `db.query("SELECT * FROM users …")` vs `getUser(user.id)`).

`mocking.md` rule, verbatim: "Mock at **system boundaries** only: External APIs (payment, email, etc.); Databases (sometimes - prefer test DB); Time/randomness; File system (sometimes). Don't mock: Your own classes/modules; Internal collaborators; Anything you control." Design guidance: "Use dependency injection" and "Prefer SDK-style interfaces over generic fetchers".

### D.2 `codebase-design`: vocabulary and the deletion test

`skills/engineering/codebase-design/SKILL.md` glossary, verbatim definitions:
- "**Module**: anything with an interface and an implementation. Deliberately scale-agnostic: a function, class, package, or tier-spanning slice. _Avoid_: unit, component, service."
- "**Interface**: everything a caller must know to use the module correctly: the type signature, but also invariants, ordering constraints, error modes, required configuration, and performance characteristics. _Avoid_: API, signature (too narrow, they refer only to the type-level surface)."
- "**Seam** _(Michael Feathers)_: a place where you can alter behaviour without editing in that place; the *location* at which a module's interface lives. Where to put the seam is its own design decision, distinct from what goes behind it. _Avoid_: boundary (overloaded with DDD's bounded context)."
- "**Adapter**: a concrete thing that satisfies an interface at a seam. Describes *role* (what slot it fills), not substance (what's inside)."
- Also **Depth** ("leverage at the interface"), **Leverage**, **Locality**.

Principles, verbatim: "**The deletion test.** Imagine deleting the module. If complexity vanishes, it was a pass-through. If complexity reappears across N callers, it was earning its keep." and "**One adapter means a hypothetical seam. Two adapters means a real one.** Don't introduce a seam unless something actually varies across it." and "**The interface is the test surface.** Callers and tests cross the same seam. If you want to test *past* the interface, the module is probably the wrong shape."

`DEEPENING.md` four dependency categories: "1. In-process" (pure computation; "Always deepenable… No adapter needed."), "2. Local-substitutable" ("PGLite for Postgres, in-memory filesystem… The seam is internal; no port at the module's external interface."), "3. Remote but owned (Ports & Adapters)" ("Define a **port** (interface) at the seam… Tests use an in-memory adapter. Production uses an HTTP/gRPC/queue adapter."), "4. True external (Mock)" ("Third-party services (Stripe, Twilio, etc.)… tests provide a mock adapter."). Testing strategy: "replace, don't layer" — "Old unit tests on shallow modules become waste once tests at the deepened module's interface exist; delete them."

### D.3 `code-review`: two axes, standards sources, smell baseline, word cap

`skills/engineering/code-review/SKILL.md`. Two axes: "**Standards**: does the code conform to this repo's documented coding standards? **Spec**: does the code faithfully implement the originating issue / spec?" "Both axes run as **parallel sub-agents** so they don't pollute each other's context". Standards sources: "Anything in the repo that documents how code should be written, such as `CODING_STANDARDS.md` or `CONTRIBUTING.md`." Binding rules: "**The repo overrides.** A documented repo standard always wins" and "**Always a judgement call.** Each smell is a labelled heuristic ("possible Feature Envy"), never a hard violation. Like any standard here, skip anything tooling already enforces."

The twelve Fowler smells (names verbatim, in order): **Mysterious Name**, **Duplicated Code**, **Feature Envy**, **Data Clumps**, **Primitive Obsession**, **Repeated Switches**, **Shotgun Surgery**, **Divergent Change**, **Speculative Generality**, **Message Chains**, **Middle Man**, **Refused Bequest**. Each reads "what it is → how to fix", e.g. "**Speculative Generality**: abstraction, parameters, or hooks added for needs the spec doesn't have. → delete it; inline back until a real need shows."

Sub-agent word cap: both briefs end "Under 400 words." Aggregation: "Do **not** merge or rerank findings, because the two axes are deliberately separate."

### D.4 ADR format and a real ADR

`skills/engineering/domain-modeling/ADR-FORMAT.md`, verbatim core:

```
# ADR Format

ADRs live in `docs/adr/` and use sequential numbering: `0001-slug.md`, `0002-slug.md`, etc.

Create the `docs/adr/` directory lazily: only when the first ADR is needed.
