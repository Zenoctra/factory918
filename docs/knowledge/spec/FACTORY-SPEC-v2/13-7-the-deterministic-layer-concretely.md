<!-- lines: 13 | source: spec/FACTORY-SPEC-v2.md | part 13/17 | title: The Factory spec, v2 — 7. The deterministic layer, concretely -->

## Contents (line numbers are for the Read tool's offset)
- L7: 7.11 Cross-language custom rules (`ast-grep`)
- L11: 7.12 Models and cost

### 7.11 Cross-language custom rules (`ast-grep`)

Theo's encoded opinions live in an oxlint plugin and therefore only reach TypeScript. For opinions that should hold in every language (no `console.log`/`print` in shipped code, banned patterns, structural rules), the factory uses `ast-grep`: YAML rules (`id`, `language`, `severity`, `message`, `rule.pattern`) under `ast-grep/rules/`, tests under `ast-grep/rule-tests/` run with `ast-grep test`, and `ast-grep scan` in the CI Check job. Two starter rules ship (`no-console-log-ts`, `no-print-py`) as the demonstration that one opinion becomes two one-file rules. Debt ceilings for ast-grep rules are a counting script, not a rule option. Verify the config keys, the `scan` exit code and the test harness at M0 **[draft]**.

### 7.12 Models and cost

Manuel is on the $200 Claude plan with access to Fable 5.1, Opus 5 and Sonnet 5; the limit is shared and Fable spends it fastest (one research conversation cost a tenth of a week). The role table `/setup-pstack` writes is therefore where cost control lives, and it is one file. Defaults (`template/docs/agents/models.md`): Opus 5 for the interactive session and for bug-fix/perf roles; Sonnet 5 for feature and refactoring delegates, explorers, investigators and swarm workers; Opus 5 for judgment and prose with Fable on request per ticket; panels Opus + Sonnet, Fable added only for `interrogate` on a contested design; `arena` off. In planning: grill on Opus, switch to Fable with `/model` for `/to-spec` and `/to-tickets`, switch back. The manual lists the skills in cost order (arena, swarm, interrogate, `how` critique mode, wayfinder's parallel research, `to-tickets` on a large spec) and the weekly check (if Fable is over a third of spend, move a role down).
