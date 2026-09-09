---
name: mode-build
description: Switch this repo's agent phase to execute (poteto-mode; tickets become PRs). The phase hook prints the state every turn.
disable-model-invocation: true
allowed-tools: Bash(mkdir *) Bash(echo *)
---
Run `mkdir -p .claude/state && echo execute > .claude/state/mode`, then say: "Phase is execute. Give me a ticket (#N) or a task; /poteto-mode routes it."
