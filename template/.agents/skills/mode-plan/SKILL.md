---
name: mode-plan
description: Switch this repo's agent phase to planning (Matt Pocock's skills; no production code). The phase hook prints the state every turn.
disable-model-invocation: true
allowed-tools: Bash(mkdir *) Bash(echo *)
---
Run `mkdir -p .claude/state && echo planning > .claude/state/mode`, then say: "Phase is planning. Use /wayfinder, /grill-with-docs, /to-spec, /to-tickets."
