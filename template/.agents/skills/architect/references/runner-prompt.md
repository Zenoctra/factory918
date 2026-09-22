# Architect runner prompt

The orchestrator passes this file through to every parallel candidate runner during Phase B and fills in the variable inputs around it: the task, the Phase A grounding artifacts, the isolated working directory, and the path to write outputs. The working directory is a git worktree when available, otherwise a per-runner subdirectory under the sketch dir; what matters is independence between candidates.

You are producing one candidate design in architect's parallel exploration. Read the **architect** skill in full first; that's the workflow you're inside. Output a candidate design package. Its first deliverable depends on what the design has.

- With state (a file it reads or writes, exit codes, rounds, or more than one actor): a scenario table, then the contract derived from it, then the test list. Situations go down the side (the states the world can be in: no record, a stale ref, a failing tool, a body with no token), the shape of the input across the top (none, one, siblings, one containing the other, the caller's own), and every cell says what is printed, the exit code and what the caller does next. A legend defines the cell vocabulary once. The contract defines every term the cells use. The test list has one assertion per cell, in the order the cells are written, each naming the fixture state it needs. A cell for an input outside the intended path reads "refused with the tool's own message" and costs no code. Cut such a cell only after the refusal was run and seen; an assumption about a tool's failure mode is a claim until then.
- Without state, crossing a function boundary: the usage and signature sketch, the caller's usage first, then the types and signatures (the discipline below).

Then the type sketch, function signatures, module map, and prose rationale shaped per [`rationale-template.md`](rationale-template.md). The orchestrator appends the synthesized first deliverable to the ticket before implementation, a table under `## Testing decisions`, a sketch under `## Design` (the Ticket playbook, step 6); the writer, the reviewer and the human read it there.

Apply the following discipline. The orchestrator compares candidates on these axes to pick a base.

- Caller's usage first. Write the README-style usage and two or three real call sites before the types, then derive the type sketch from them. The usage is the spec; the two must agree, so reconcile the sketch to the usage, not the reverse.
- Data structures first. Get the core types right and the code becomes obvious. Trace each dominant access pattern through the proposed structure; if the answer is "we'll add a map / index / cache later," the structure is wrong.
- Interface depth. Compare the capability hidden behind the public surface relative to the size of that surface. Prefer a simple interface that pulls complexity into the callee, even when the implementation becomes less simple. Do not put transport or wire types on the public surface; parse into domain types behind the interface.
- Shared state: if two actors might both write, ask "what happens?" If the answer isn't "nothing," default to per-actor state with a merge at the read boundary, per the **separate-before-serializing-shared-state** principle skill.
- Make boundaries visible. `not implemented` errors for bodies, `// TODO` pseudocode for tricky logic, doc comments stating intent and invariants. A reader should trace data from input to output by reading types and signatures alone.
- Encode invariants in types: hard-to-misuse types > runtime checks > prose comments, per the **encode-lessons-in-structure** principle skill.
- Validate at boundaries, trust types inside, per the **boundary-discipline** principle skill. Business logic as pure functions; the shell stays thin.
- Single source of truth per invariant. Derive instead of sync.
- Idempotent state transitions where applicable, per the **make-operations-idempotent** principle skill. Ask what happens if the operation runs twice or crashes halfway.
- Short call chains. If tracing the flow needs more than three files, flatten the hierarchy, per the **laziness-protocol** and **minimize-reader-load** principle skills.

You are one of several runners, each on a different model. Produce the best design your model can make; don't hedge against the others. Differences between candidates are the signal used to pick a base and graft. Converging on a safe-looking middle defeats the exploration.
