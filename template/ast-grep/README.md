# ast-grep rules

One rule engine for opinions that hold in more than one language. TypeScript-only rules belong in `oxlint-plugin-project/`.

`pnpm sg` scans (CI runs it in the Check job); `pnpm sg:test` checks each rule against `rule-tests/`. Both read `sgconfig.yml` at the repo root, so they take no flags from anywhere in the project.

Add a rule only from a ledger entry that has recurred. Ceilings for old code are a ratchet script, not a rule option.

## Writing a rule

A rule is one file in `rules/`, a test beside it in `rule-tests/`, and a snapshot under `rule-tests/__snapshots__/`. Scope a rule to where it applies with `files:` and `ignores:` globs; both are matched against paths from the repo root.

Snapshots are part of the rule. `pnpm sg:test` fails on a rule whose snapshot is missing, so generate it with `ast-grep test --update-all` and commit the result alongside the rule. Read the generated snapshot before committing: it records the exact span the rule matched, which is where an over-broad pattern shows itself.

Invoke the CLI as `ast-grep`. Its short alias `sg` is a different program on macOS.
