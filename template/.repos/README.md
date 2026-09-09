# Vendored reference sources

Read-only checkouts of dependencies the agent must imitate correctly (uncommon libraries, anything we lean on heavily), plus their agent guides (`LLMS.md`, `AGENTS.md`) where the project ships one. Listed in `.repos/sources.json`; populated by `factory sync-repos`; git-ignored except this file. `AGENTS.md` ("Where code lives") points at each one. Never edit or import from them.
