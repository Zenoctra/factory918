<!-- lines: 61 | source: spec/FACTORY-SPEC-v2.md | part 9/17 | title: The Factory spec, v2 — 5. Skill manifest -->

## Contents (line numbers are for the Read tool's offset)
- L11: 5. Skill manifest
- L13: 5.1 From open-pstack (vendoring source for pstack) **[primary: open-pstack v1.3.0, synced to upstream 0.14.7]**
- L19: 5.2 From mattpocock/skills (planning only) **[primary: 6654f6b, v1.2.3]**
- L39: 5.3 Ours (to write, §7.5 and §7.4)
- L43: 5.4 Patches applied to vendored files (recorded in `SOURCES.md`, re-applied by `factory918 sync`)
- L54: 5.5 Collision audit (done)

## 5. Skill manifest

### 5.1 From open-pstack (vendoring source for pstack) **[primary: open-pstack v1.3.0, synced to upstream 0.14.7]**

Take `plugins/pstack/skills/*` except `make-bot-ui` (not in the port) and `no-comments` (excluded by decision 4: comments stay); `plugins/pstack/agents/*` except `comment-sicko.md`; and the hook text `plugins/pstack/hooks/session-start-context.md` as raw material for our own mandate (§7.4). Reasons to vendor from this port rather than upstream or pstack-claude: it has already stripped `disable-model-invocation: true` from action skills (Claude Code's docs: with that flag "Claude cannot invoke through the Skill tool" **[primary: code.claude.com/docs/en/skills]**), marked the 21 principles `user-invocable: false`, substituted Cursor's `Task`/`AskQuestion`/`/loop`/`control-ui` with Claude Code equivalents, kept `paths: ["**/*.ts", "**/*.tsx"]` on `typescript-best-practices`, and is five minor versions newer than pstack-claude. Codex support is first-class when you want it.

Model roles: `factory918 install` writes them once per machine, since the vendored `/setup-pstack` refuses to save without Codex and Grok lanes (decision P5); it writes `~/.claude/pstack-models.md` and adds `@~/.claude/pstack-models.md` to `~/.claude/CLAUDE.md` **[primary: open-pstack setup-pstack/SKILL.md]**. The defaults for Manuel's plan are in `template/docs/agents/models.md` (§7.12): Opus 5 default, Sonnet 5 for mechanical delegates and explorers, Fable 5.1 reserved, `arena` off. Decided (DECISIONS.md #13).

### 5.2 From mattpocock/skills (planning only) **[primary: 6654f6b, v1.2.3]**

| Skill | Invocation | Why it is in |
|---|---|---|
| `grilling` | model | the interview primitive |
| `grill-with-docs` | user | head of the planning flow; writes CONTEXT.md + ADRs |
| `grill-me` | user | grilling outside a repo (a system-level idea before the repo exists) |
| `domain-modeling` (+ CONTEXT-FORMAT.md, ADR-FORMAT.md) | model | glossary and ADR discipline; brownfield cross-check |
| `to-spec` | user | conversation → spec issue with `ready-for-agent` |
| `to-tickets` | user | spec → tracer-bullet tickets with `Blocked by` |
| `wayfinder` | user | fog-of-war maps for multi-session efforts |
| `research`, `prototype` | model | called by wayfinder; prototype also answers "ungrillable" questions |
| `setup-matt-pocock-skills` (+ templates) | user | kept so the docs it points to exist; the factory pre-writes them (§7.6) |
| `writing-for-agents` (+ SKILL-MECHANICS.md) | model | how you will write your own skills |
| `wizard` (+ template.sh) | model | bash wizards for human-only steps: repo secrets, branch protection, provider dashboards |
| `wait-what` | user | three lines; useful when grilling loses you |
| `code-review` → renamed **`spec-review`** | model | the only review that checks the diff against the originating ticket/spec; renamed to avoid shadowing Claude Code's built-in `/code-review` (docs: a same-named skill "overrides a bundled skill") |

Deliberately **not** vendored: `implement` (replaced by the Ticket playbook), `tdd` and `teach` (pstack has both; same names would collide), `diagnosing-bugs` (pstack's Bug fix playbook + Fix Root Causes cover it; its ten-rung feedback-loop ladder is kept as `docs/agents/feedback-loops.md`), `handoff` (tickets on GitHub are the handoff), `ask-matt` (routes a flow you do not run), `triage` and `improve-codebase-architecture` (add when you have outside contributors / a codebase old enough to survey; both install cleanly later), `resolving-merge-conflicts` (the port bundles `fix-merge-conflicts`).

### 5.3 Ours (to write, §7.5 and §7.4)

`factory918` (the roof: a situation → entry-point table; model-invocable with a narrow description so an unsure agent can consult it), `factory-start` (the Day-0 interview: calls Matt's `grilling` over the eight decisions the template cannot make, then writes the `AGENTS.md` slots, ADR 0001, `.repos/sources.json`, the review-ladder bot list and `ledger.md`; user-invoked), `knowledge` (the lookup procedure over `docs/knowledge/`: index, grep, mini-TOC, ranged Read, cite; model-invocable), `ticket` (a playbook file inside `poteto-mode/playbooks/` plus one routing line in the router), `mode-plan` / `mode-build` (two-line user-invoked skills that write `.claude/state/mode`), `factory-doctor` (runs the checks in §8.3 and reports), and the evidence conventions file. Drafts of all three glue skills are in `template/.agents/skills/`.

### 5.4 Patches applied to vendored files (recorded in `SOURCES.md`, re-applied by `factory918 sync`)

1. **Namespace.** open-pstack skill bodies reference the plugin namespace in three files (`pstack:models` ×6, `pstack:typescript-best-practices` ×1) **[primary: grep of open-pstack]**; the hook mandate references `pstack:poteto-mode`, `pstack:tdd`, `pstack:architect`, `pstack:how`, `pstack:why`, `pstack:arena`, `pstack:interrogate`. Vendored project skills are unprefixed. Patch: `s/pstack:\([a-z-]*\)/\1/g` across `.agents/skills/**/*.md` and the mandate.
2. **Router gets the Ticket playbook.** Append to the playbook list in `poteto-mode/SKILL.md`: `- **Ticket.** Work that starts from a tracker issue (\`#N\`, \`owner/repo#N\`, an issue URL): read it, check blockers, run the matching playbook, end in a PR that closes it. \`playbooks/ticket.md\`.` Add the routing rule: "Any issue reference in the request → Ticket, which then selects Feature, Bug fix, Refactoring or Perf issue by the ticket's content."
3. **Opening a PR → comments stay, review ladder added.** In `playbooks/opening-a-pr.md`, replace the sentence "Run `/no-comments` before review." with "Keep comments (DECISIONS.md #4); do not run `/no-comments`. After CI is green, run `spec-review` in a fresh context against the originating ticket (and its parent spec) and `CODING_STANDARDS.md`; fix Act-on items, record the rest in the PR body. The full ladder is `docs/agents/review-ladder.md`." Also replace the later "A subagent that opens a PR runs `interrogate`, `/deslop`, and `/no-comments`" with "... runs `interrogate` and `/deslop`". Keep "never as a draft."
4. **Babysit → bots optional.** Prepend to the bot-triage step: "If `docs/agents/review-ladder.md` lists no external bot, there are no bot comments to triage; proceed on CI." (This is the graceful fall-through.)
5. **`unslop` trigger (kept).** Replace its description with a trigger-focused one so it auto-fires on human-facing text: `Cut AI tells from any text written for a human reader: commit messages, PR titles and bodies, issue comments, docs, replies. Use whenever such text is about to be written or edited.` (Ras Mic did the same to his vendored copy; write our own sentence, his repo has no license.) Keep the body.
6. **`spec-review` rename.** Directory `code-review` → `spec-review`; first heading and `name:` updated; body unchanged (both axes stay: Standards reads `CODING_STANDARDS.md`, Spec reads the ticket/spec).
7. **Matt's setup pointers.** No change; the factory pre-writes `docs/agents/issue-tracker.md` and `docs/agents/domain.md` so the "run `/setup-matt-pocock-skills`" prompts are satisfied. Running it anyway is harmless.
8. **Provider dispatch text** in `poteto-mode/SKILL.md` and `feature.md` mentions Grok/Sol defaults; no patch. The models sheet from `/setup-pstack` overrides them.

### 5.5 Collision audit (done)

Across the vendored set there are no duplicate directory names: Matt's `tdd`/`teach` are excluded; `research`, `prototype`, `wizard`, `wait-what` have no pstack counterpart; `spec-review` avoids the built-in `/code-review`; pstack references Claude Code's built-in `loop`, `run` and `verify` skills by design **[primary: open-pstack docs/reference.md]**. Claude Code resolves same-named skills by level (enterprise > personal > project) and namespaces plugins, so a personal `~/.claude/skills/` copy of any of these would override the project copy **[primary: skills docs]**; the factory therefore installs nothing at user level except the models sheet.

---

9. **Session mandate.** Ours replaces the port's: it names the roof (`factory918`), the phases, the direct entries, and the precedence of `AGENTS.md` and `DECISIONS.md`. Draft in `template/.claude/hooks/session-mandate.md`.
10. **Paths in our own files.** In `AGENTS.md`, the mandate and the glue skills, `PHILOSOPHY.md` / `MANUAL.md` / `DECISIONS.md` / `GLOSSARY.md` resolve to `docs/factory918/` inside a project and to `docs/knowledge/core/` inside the factory repo. The `knowledge` skill's `$KB` fallback order is `$FACTORY918_HOME/docs/knowledge`, `~/.factory918/docs/knowledge`, then the project's `docs/factory918`.
