---
name: factory-doctor
description: Check that this repo's Factory918 layer is intact (toolchain, hooks, skills, labels, CI config, gates). Use after applying or updating the factory, after /factory-start, or when something feels off.
allowed-tools: Bash(factory918 *)
---
Run `factory918 doctor` and report its table exactly as printed, then stop. Fix nothing unless asked.

If `factory918` is not on PATH, the factory clone is not installed on this machine. Report that and stop.
