# Coding standards

Read at review time by `spec-review` (Standards axis), not during implementation. Skip anything tooling already enforces.

## Types (from pstack's typescript-best-practices)

- Discriminated unions with a `kind` literal; no optional-field bags.
- Branded types for semantic primitives (`UserId`, `OrderId`); validate once at the boundary.
- Make illegal states unrepresentable (`[T, ...T[]]` for non-empty; `start` + `duration` instead of two dates that can cross).
- `unknown` for external data, then parse into a named domain type at the crossing. Schemas before hand-written guards.
- No `as` casts except after validation. Narrowing order: discriminant switch > `in` > `typeof`/`instanceof` > user-defined guard > `as`.
- Exhaustiveness: `const _exhaustive: never = x` in default arms.
- `satisfies` over `as`. Derive types (`Pick`, `Omit`, `ReturnType`, `typeof`) before writing a new interface.
- Real tests: don't mock what you can run. Mock only at system boundaries (external APIs, time, randomness, sometimes the DB and filesystem). Never your own modules.
- No `console.log` in shipped code; structured logging.

## Shape (from Theo's Taste and pstack's principles)

- Complexity at the adapter boundary; orchestration pure; UI dumb.
- Laziness Protocol: the smallest change that solves the problem; bias toward deletion; flatten anything that takes more than three files to trace.
- Reader load: a new reader answers "where does X come from?" and "what can change X?" in under 30 seconds.
- Model the domain: a state machine over scattered booleans; a table over branching; a typed model over repeated shape assumptions.
- Idempotent operations: "what happens if this runs twice? if the previous run crashed halfway?"
- Comments stay (decision 4). They describe use and non-obvious why, and move with the code. A comment justifying a workaround is a signal the code is wrong; fix the code, keep the note until it is.
- A PR must not push a file from under 1,000 lines to over 1,000 lines without a very strong reason.

## Smells (labelled heuristics, never hard violations; Fowler via Matt's code-review)

Mysterious Name · Duplicated Code · Feature Envy · Data Clumps · Primitive Obsession · Repeated Switches · Shotgun Surgery · Divergent Change · Speculative Generality (delete it; inline until a real need shows) · Message Chains · Middle Man · Refused Bequest.

## Design red flags (pstack's architect)

Shallow module (large interface, little hidden) · Information leakage (one decision known in several places) · Temporal decomposition (modules by execution order instead of knowledge) · Pass-through method (forwards the same arguments, hides nothing).

## Suppressions

Every new or broadened `oxlint-disable`, `@ts-ignore`, `@ts-expect-error` needs an adjacent comment explaining why. The directive itself is not an explanation. A stale directive fails lint. A `# shellcheck disable=` in a hook or a skill script puts its reason in a second comment on the same line, because the directive is itself a comment and an adjacent one would be ambiguous.
