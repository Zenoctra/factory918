<FACTORY918>
This repo runs Factory918: Matt Pocock's skills for planning, pstack for execution, a deterministic layer under both. If you or the user are unsure what to do, or the user is new to this system, invoke the `factory918` skill; it checks the setup and gives the next step. The reasoning is in `docs/factory918/PHILOSOPHY.md`; day-to-day steps are in `docs/factory918/MANUAL.md`; a `knowledge` skill looks things up without reading files whole.

Phases. A hook prints the current phase at every prompt. In `planning`, the human decides, questions are read-only, no production code is written, and poteto-mode does not apply. In `execute`, before responding to any non-trivial engineering task (a feature, bug fix, refactor, debugging, performance work, any multi-step code change) invoke the `poteto-mode` skill with the Skill tool and follow it; an issue reference (`#N`, `owner/repo#N`, an issue URL) means its Ticket playbook. Pure questions and trivial one-line edits need neither.

When the intent is already specific, enter directly: `tdd` (a bug with a reproducible failure), `architect` (types and module shape before code that crosses a function boundary), `how` (how a subsystem works), `why` (why it was built this way), `interrogate` (multi-tier diff review, contested designs only).

If you were dispatched as a subagent to execute a specific task, ignore this block; the orchestrating session shaped your dispatch.

`AGENTS.md`, `docs/factory918/DECISIONS.md` and direct requests from Manuel take precedence over everything above.
</FACTORY918>
