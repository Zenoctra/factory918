<!-- lines: 46 | source: pages/deterministic-layer.md | part 2/12 | title: The Deterministic Layer (reference page) — The ladder: where a rule should live -->

## Contents (line numbers are for the Read tool's offset)
- L6: The ladder: where a rule should live

## The ladder: where a rule should live

Lauren's principle names the rungs in order of strength, with the reason for the order: "agents copy whatever the surrounding code already does and a weaker guard becomes the next template." Theo's repo and Matt's skills supply real examples for every rung. Read it top-down: when you catch yourself writing an instruction, start at rung 1 and stop at the first rung that can hold it. primary

1. **An unrepresentable state that cannot compile**

   Make the wrong thing impossible to express. A discriminated union instead of optional-field bags; a branded type for an ID so a user ID cannot be passed where an order ID goes; exhaustiveness checks so a new variant fails to compile until every switch handles it. This is pstack's Type System Discipline ("The type checker is a proof assistant") and the reason Theo bans `any`.

   pstack typescript-best-practices · Theo AGENTS.md "Taste"
2. **A lint rule or banned API that fails CI**

   A program that reads the code and rejects a pattern. Theo's six custom oxlint rules are the model: `no-global-process-runtime` ("Use HostProcessPlatform instead of process.platform"), `no-native-title-tooltip` ("Use Tooltip + TooltipTrigger + TooltipPopup"), `no-inline-schema-compile` (hoist compilers out of hot paths). Each one is an opinion that used to be a sentence in a prompt. Matt's dependency-cruiser config is an architecture lint: imports that cross a package boundary through anything but its entry points are errors, and "a config that doesn't fail on a violation is worthless."

   t3code oxlint-plugin-t3code/rules/\*.ts · mattpocock-skills setup-ts-deep-modules/dependency-cruiser.config.cjs
3. **A canonical helper**

   One function everyone calls, so the rule lives in the helper instead of in every caller's head. Theo's `StyledDiffCodeView` (enforced by a banned-import lint that says "Use StyledDiffCodeView so web diff surfaces share styling") is a helper with a rung-2 guard around it. Ras Mic's service layer is the same idea at module scale: "Extraction trigger: Logic repeated across 2+ callers."

   t3code vite.config.ts no-restricted-imports · michaelshimeles/skills code-structure
4. **A runtime check**

   Code that fails loudly when the rule is broken while running: a schema parse at a boundary, an assertion, a budget. Theo's transfer budget is the clearest example: a CI test replays one thread turn and asserts the bytes sent over the wire stay under caps that "leave roughly 30% headroom," so a PR that accidentally ships a 9 MB tool result again fails with "`<provider>: totalWireBytes was N, maximum 15500`."

   t3code apps/server/integration/TransferBudgetReport.integration.ts
5. **A test at a seam**

   Not on Lauren's list by name, but it is where all four put behavior rules. A test proves one observable behavior through a public boundary and fails when it changes. Matt: "Test only at pre-agreed seams." Theo: "Backend behavior changes ship with focused tests for that behavior." pstack: "Prefer no new test over a bad test."

   mattpocock-skills tdd/SKILL.md · t3code AGENTS.md "Verifying" · pstack tdd/SKILL.md
6. **A line in the always-loaded file**

   The first rung that depends on the model reading and obeying. Theo's blast-radius rules ("Never pkill -f") live here because a lint cannot see a shell command. Keep these to things no program can catch.

   t3code AGENTS.md "The three ways to hurt yourself"
7. **A skill**

   A long procedure loaded on demand. The weakest rung for a rule, and the right one for a procedure (how to launch and test the app, how to file a PR). This is why Theo's public skills are verification playbooks and not coding rules.

   t3code .agents/skills/test-t3-app · pstack create-verification-skill

Lauren's corollary closes the loop: "If the fix is structural, ONLY use the structural fix." And her routing rule tells you what to do with each correction you make to an agent: "One-off -> brain note. Recurring fix -> skill or lint rule. Systemic issue -> principle." Theo runs the same loop from the other end, mining his session history for the mistakes that recur and only then writing the rule. primary secondary
