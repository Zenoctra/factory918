<!-- lines: 18 | source: pages/pocock-planning-evidence.md | part 2/17 | title: Pocock Planning Evidence (brief) — What the artifacts are supposed to look like (from the SKILL.md templates) -->

## Contents (line numbers are for the Read tool's offset)
- L6: What the artifacts are supposed to look like (from the SKILL.md templates)

## What the artifacts are supposed to look like (from the SKILL.md templates)

**Spec** (`skills/engineering/to-spec/SKILL.md`): one tracker issue, label `ready-for-agent`, sections `## Problem Statement`, `## Solution`, `## User Stories` ("A LONG, numbered list ... extremely extensive"), `## Implementation Decisions` ("Do NOT include specific file paths or code snippets. They may end up being outdated very quickly"), `## Testing Decisions`, `## Out of Scope`, `## Further Notes`. Written with "no interview, just synthesis of what you've already discussed." Step 2 sketches test seams and checks them with the user before writing.

**Tickets** (`to-tickets/SKILL.md`): "tracer-bullet vertical slices, each declaring the tickets that block it." Per-issue template: `## Parent`, `## What to build`, `## Acceptance criteria` (checkboxes), `## Blocked by`. "Each slice is sized to fit in a single fresh context window." Published blockers-first so edges can reference real ids; "Do NOT close or modify any parent issue." Local fallback: `.scratch/<feature>/issues/<NN>-<slug>.md`.

**CONTEXT.md** (`domain-modeling/CONTEXT-FORMAT.md`): a glossary. `**Term**:` one or two sentences, `_Avoid_:` synonyms. "Only include terms specific to this project's context ... Keep definitions tight. One or two sentences max. Define what it IS, not what it does."

**Wayfinder map** (`wayfinder/SKILL.md`): one issue labelled `wayfinder:map` with `## Destination`, `## Notes`, `## Decisions so far` ("the index: one line per closed ticket ... a decision lives in exactly one place, its ticket, so the map never restates it, only gists it and links"), `## Not yet specified` (fog), `## Out of scope`. Child issues labelled `wayfinder:research|prototype|grilling|task`, HITL or AFK. "Plan, don't do."

**implement** (docs): reads ticket/spec, drives `/tdd` at pre-agreed seams, runs `/code-review`, commits to the current branch. The docs page itself concedes: "`implement` has no completion step. It ends at the commit and never touches the work item."

The flow: `grill-with-docs → to-spec → to-tickets → implement → code-review`, with `wayfinder` as an on-ramp that "merges onto the chain at to-spec".
