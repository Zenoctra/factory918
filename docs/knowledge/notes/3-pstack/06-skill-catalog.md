<!-- lines: 62 | source: notes/3-pstack.md | part 6/11 | title: Research note: pstack — Skill catalog -->

## Contents (line numbers are for the Read tool's offset)
- L6: Skill catalog

## Skill catalog

Format: **name** | kind | trigger | what it does | chains to | verbatim | notes. All paths under `skills/<name>/SKILL.md`.

**poteto-mode** | router / sticky mode | `/poteto-mode`, "poteto", any non-trivial task; auto-reapplies across turns | Reads principles, matches a playbook, copies steps verbatim into a todo list, delegates by model role, writes an unslopped reply | every other skill | "Start every multi-step task with a todolist whose first item is to read the Principles section below in full." / "A step you choose not to do stays in the list with a one-line `skip: <reason>`; skipping silently is not allowed." | Frontmatter `mode: true`, `icon: crown`, `color: yellow`. Bundles `playbooks/`, `references/bugbot-triage.md`, and `scripts/`.

**how** | action (understanding) | "how does X work", walkthroughs, placement/ownership questions | Explain mode (2–4 explorers + explainer) or Critique mode (explain, then one critic per panel model) | why, interrogate-style lead judgment | "Enough to build a working mental model, not annotated source code." / "If the architecture is sound, say so. An empty critique is a valid outcome." (critic prompt) | Explorer default grok, explainer fable, critics = the four-model panel.

**why** | action (understanding) | "why does X work this way", regressions, postmortems, thresholds | Code anchor via git/gh, one investigator per available MCP category, synthesizer with confidence tiers | how (companion), recall, blast-radius | "Prefer 'appears to' over 'because'." / "Confident storytelling ... A bullet with no citation goes in 'inferred' or 'hypotheses,' not 'what we found.'" | Investigators run in agent mode because "readonly ... strips MCP access". Seven source playbooks in `references/sources/`.

**teach** | action (understanding) | "teach me this", "help me really understand X" | Runs how + why, blends into one plain explanation built diagram by diagram | how, why, unslop | "Listing functions and constants is reference, not teaching." / "Three small growing diagrams beat one crowded diagram." | Uses an image-generation tool for spatial ideas (Cursor-side capability).

**recall** | action (context) | "catch me up", "where did I leave off" | Mines your own transcripts in parallel subagents plus the shared record via why's investigators; returns Capsule/Threads/Problems/Next move | why, session-pickup playbook, automate-me | "A transcript or a stale ticket is history, not current truth" | Transcript path is Cursor-specific.

**blast-radius** | verification | "what could this break", small diffs you don't trust | Finds the one safety fact and proves it by running code | why (step 2), arena for wide changes, unslop | "A blast-radius writeup that sounds right is worthless." / "Any safety fact you can't get to step 4, say so out loud." | Five-rung evidence ladder.

**architect** | action (design) | `/architect`, boundary-crossing code | Ground → Sketch (arena) → Agree (opt-in) → Implement → Scrap | how, why, arena, interrogate | "Design it twice. Require at least two structurally distinct candidates before synthesis" / "Default: proceed directly to implementation with the synthesized design. No human checkpoint." | References: design-red-flags, rationale-template, runner-prompt.

**arena** | action (parallelism) | `/arena`, bakeoffs | N candidates → cross-judge → pick base → graft → verify | architect, eval playbook, blast-radius | "When N candidates converge on the same shape, that is a strong agreement signal ... When N candidates wildly diverge, Phase A was under-specified." | Candidates each get a worktree; "The arena does not earn you a pass."

**swarm** | action (parallelism) | `/swarm`, coverage, races, gauntlets | Frame → fan out cloud workers → aggregate → one report (`PASS`/`ISSUES`/`BLOCKED`) | autopilots, shipping, maintain-verification-skill | "Do not paste raw worker dumps." | Upstream spawns `environment: "cloud"`; ports use local background agents.

**interrogate** | verification (review) | "adversarial review", "tear this apart", contested designs | One reviewer per panel model, same rubric + code-quality lens; lead sorts Act on / Consider / Noted / Dismissed | how (critique shares the framework), opening-a-pr | "The adversarial signal comes from model diversity, not assigned personas." / "Do NOT auto-apply changes." | Rubric includes idempotency and "Instructions where structure would be better".

**setup-pstack** | config | `/setup-pstack` | Detects models, writes `~/.cursor/rules/pstack-models.mdc`, offers a verification skill | create-verification-skill | "A rule pointing at a model the user cannot use breaks every delegation that reads it." | Only skill without `disable-model-invocation`.

**tdd** | verification | explicit TDD request, or a cheap local test path | Failing test first, then fix, then rerun | bug-fix playbook | "Prefer no new test over a bad test." | Reports "the failing-before test ... and the failure it produced".

**bro** | prose | `/bro` | Restates the last message plainly | none | "Stop using jargon and speak coherently." | One paragraph long; handy for a beginner.

**unslop** | prose | any prose surface; "Must always apply" | Removes 31 AI-tell patterns and "adds soul" | everything that writes text | "Em dashes are an AI tell, and reaching for parentheses instead just trades one tell for another." | Theo's favorite (see below).

**no-comments** | verification (cleanup) | before review | Spawns Comment Sicko, fixes accepted flags at the root cause, offers to encode claimed constraints as types/tests/lints | comment-sicko agent, architect, how, why | "Authoring agents defend comments. Defer to Comment Sicko's fresh perspective." | Two rejected reports = the skill fails loudly.

**figure-it-out** | router (bespoke) | no playbook fits; large migrations; "trust it when i'm back" | Frame (falsifiable done predicate) → design phases → hypothesis loop → audit trail → verify | architect, arena, show-me-your-work | "Bias toward more rigor. The cost of building the wrong thing dwarfs the cost of being careful." | Verdicts are VERIFIED / NOT VERIFIED / INCONCLUSIVE.

**show-me-your-work** | verification (audit) | unattended or multi-phase work | Append-only TSV decision log + transcript audit + cross-model reviewer | figure-it-out, autonomous-run, hillclimb, orchestrate | "Fix the log, not the story." / "Self-review is not a substitute" | Helper `scripts/log.sh` escapes spreadsheet formula characters.

**automate-me** | meta | "automate me", "update my -mode skill" | Mines recent transcripts, asks structured questions, drafts `<handle>-mode` via `create-skill`, unslops, opens a PR | create-skill (Cursor), unslop, poteto-mode | "Don't overfit to one conversation." | Output routes through pstack underneath.

**make-bot-ui** | action (integration) | a page whose buttons wake a Grok Bot over a webhook | Creates a webhook routine, hosts a local server on `0.0.0.0`, optionally exposes it on Tailscale | none | "Do not put the sender key in the browser, in chat, or in this skill." | Cursor/Grok-Bot specific; ports skip it.

**reflect** | meta | "/reflect" after a hard task | Judgment/Tooling/Divergent reviewers → synthesizer → Accepted/Rejected/Backlog → user approval → skill edits | create-skill, encode-lessons-in-structure | "Skill changes affect every future agent in the org; do not auto-apply." | Reviewer prompts treat transcripts as untrusted (prompt-injection aware).

**technical-writing** | prose | docs, RFCs, readmes, PR descriptions, commit messages | Diátaxis mode → Google style → STE → Global English, with a review checklist | unslop | "Cut every word that does no work." / "Use periods, not semicolons. Replace an em dash with a new sentence." | Sources fetched 2026-07-18 per the file.

**typescript-best-practices** | principle grounding (auto by path) | any `.ts`/`.tsx` file | 16-row rule table grounding type-system-discipline | principle-type-system-discipline, boundary-discipline | "Every `as` is a runtime crash waiting. Cast only after validation." | `references/patterns.md` has examples.

**create-verification-skill** | verification (generator) | no scripted way to prove app behavior | Interviews the repo, writes `.cursor/skills/verify-<app>/` + feature map, proves it once | maintain-verification-skill, swarm | "Interview the repo, not the user" / "A generated skill that was never executed is a draft, not a deliverable." | Worked example in `references/feature-map-example/`.

**maintain-verification-skill** | verification (upkeep) | feature map drift | Index hygiene → source wave → reconcile → live pass → triage → ship one PR or stop | create-verification-skill | "Never edit product code during a run" | Outcomes: clean / changed / blocked.

**principle-*** (21) | principle leaves | cited by poteto-mode index; steerable by name | one rule each | see Philosophy section | (verbatim one-liners above) | All `disable-model-invocation: true`; the ports mark them `user-invocable: false`.

**Subagents** (`agents/`): **poteto-agent** ("Reads the poteto-mode skill's SKILL.md in full before any work"), **Comment Sicko** (read-only comment reviewer; "I do not touch the code.").

---
