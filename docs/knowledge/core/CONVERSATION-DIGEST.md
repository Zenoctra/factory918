<!-- lines: 53 | source: core/CONVERSATION-DIGEST.md | part 1/1 | title: How Factory918 was arrived at -->

## Contents (line numbers are for the Read tool's offset)
- L17: The starting ask (Sept 4)
- L21: What the research found (Sept 4–5)
- L27: The vocabulary turn
- L31: The layering insight and the BMAD test
- L35: The deterministic layer
- L41: Manuel's design (Sept 9)
- L47: The decisions (Sept 9)
- L51: Things to remember that are easy to lose

# How Factory918 was arrived at

A narrative of the research and decisions that produced this system, written for an agent that was not there. The literal transcript of the conversation is not exportable; every artifact it produced is in `sources/`, and this digest records the turns of reasoning, including the corrections. Dates are 2026.

## The starting ask (Sept 4)

Manuel, learning software development and agentic coding at the same time after roughly a year of using coding agents as his primary way of writing code, wanted to become opinionated about agent skills by studying four people: Matt Pocock (the most documented system), Theo of t3.gg (the most professional in-use experience, but no published skills), Ras Mic (a few ideas), and Lauren Tan's pstack (on the list because Theo praised it). He assumed Matt's system would be his foundation. He asked for each person's system, how their skills fit their production workflow, and a deeper reconstruction of Theo.

## What the research found (Sept 4–5)

Four parallel deep-dives read every skill file from the four sources and the videos and articles around them. Findings that changed the framing: pstack was not a curiosity but the largest and most internally consistent system (a router, 23 playbooks, 24 action skills, 21 principles), and Theo, after trying Matt's skills and pstack back to back on Aug 19, said he was "much more philosophically aligned with what Potato is cooking"; Theo publishes more than "nothing" (T3 Code's `AGENTS.md`, four verification skills, six lint rules, review-bot configs, a triage playbook) and his six private skills are described on video; Matt's is the only system designed for strangers to adopt, deliberately one-human-one-session; Ras Mic's contribution is small and concrete, and his most interesting move was abandoning the autonomous loop he built. All four converge on: short always-loaded files, rules pushed into tooling, proof over claims, and "don't copy wholesale."

The reference page **Four Skill Systems** recorded all of this with six axes per developer, a skill catalog each, ten decisions a personal workflow must answer, and a starter on Matt's foundation.

## The vocabulary turn

Manuel did not know what a pull request, ticket or issue was, or whether the four were using different words for the same things. The answer: the nouns are identical (issue = ticket, PR = merge request); the workflows differ in which artifact is primary. Matt is ticket-first; the other three are PR-first. The question to add was "what is the unit of work that gets a fresh context and a review?" This is where the observation was made that for agents a ticket is a context-management device as much as a project-management one.

## The layering insight and the BMAD test

Manuel observed that the four layer rather than fight: Matt owns the beginning of a session, pstack owns everything after, Ras Mic contributes a verification protocol. He was corrected on Theo: Theo's skills are about communication and ops, but his system is the layer underneath everyone's prompts (lint, CI, hooks, verification infrastructure, the failure ledger). Manuel then raised BMAD, an earlier framework that had failed him through hallucination and summarisation loss, and asked whether Matt's planning was the same philosophy. An evidence hunt (**Pocock Planning Evidence**) found real specs and ticket sets that agents built and merged within hours, and also counted failures: 75% rework on a 26-ticket stack from unfalsifiable criteria, a spec that orphaned an invariant, 1.5M tokens for 14 tickets, and Matt's own `CONTEXT.md` growing five-fold with his own issue filed against it. Structural verdict: one human-sourced summarisation hop instead of four model-to-model hops; the human is the safeguard by design; drift is reduced, not removed. The falsifiability pass in the Ticket playbook exists because of this.

## The deterministic layer

Manuel said lint, CI and verification were his weakest area and asked for Theo's system in full, with the others' equivalents. The page **The Deterministic Layer** gave the ladder of rungs, a from-zero glossary, Theo's gates in order, a comparison table, the three verification approaches (Theo's hand-written `test-t3-app`, pstack's generator, Ras Mic's evidence recorder) as one stack, objective tests for security, architecture, smells and elegance, hooks precisely (git hooks, harness hooks, webhooks; sticky mode replaced by a `UserPromptSubmit` hook), a scaffold epic, the port comparison, and Boris Cherny's five steps of adoption, whose 1-to-2 requirement ("build self-verification loop, enable auto mode, automate code review") is this layer.

Corrections made here: "`any` is the enemy" is TypeScript's `any`, not "ALL"; T3 Code never migrated from Bun to Vite+ (it runs pnpm and Vite+ on Node 24); `create-verification-skill` never calls itself expensive; Theo's "babysit" predates pstack's playbook and neither copied the other; the three pstack ports differ mainly in the invocation flag, and `disable-model-invocation: true` blocks the Skill tool in Claude Code entirely.

## Manuel's design (Sept 9)

He rejected Matt as the foundation: Matt for planning through `/to-tickets`, then pstack for everything after, Theo plus pstack for the deterministic layer, Ras Mic for the evidence convention, one-off skills from anyone (`wizard`, `unslop`). He asked whether pstack builds the CI stack by itself (it does not; it generates verification skills, tests, and lint rules on recurrence, and assumes the scaffold exists), how much of Theo's CI is universal (about half, by shape), for a loadable factory template with graceful updates, and for the contradictions between the vendored skills to be found and resolved.

The first spec, **The Factory** (v1), answered with a layout, a skill manifest, a contradictions table, config drafts, a CLI design with a three-way merge, milestones, and open decisions. Manuel's critique of v1, all accepted: the Ticket playbook is a wrapper (kept, one file); mobile and Python must be solved now, not later; the spec assumed the implementing model had the conversation's context; the agent file is Theo-shaped because Theo is the only one with an opinionated always-loaded file, but the voice must be Manuel's; nothing said what to do the moment `init` finishes; there was no roof over the two routers and no philosophy or manual; the writing skills should be loaded before anything is written for other models.

## The decisions (Sept 9)

Comments stay. Thin hook. Never block on the human, with the irreversible exception. Tickets auto-open PRs. Private repos, monorepo per product. Expo/React Native for mobile (T3 Code Mobile runs Expo SDK 57 with Vitest, tsc and oxlint under Vite+, so the layer carries unchanged). A Python profile on `uv`, `ruff`, `pyright`, `pytest`. `ast-grep` for cross-language rules. Opus 5 default, Sonnet 5 for mechanical delegates, Fable 5.1 reserved. Knowledge base in the factory repo with slim copies in projects. Name: Factory918. Version 2 of the spec adds the roof (`/factory918`), the Day-0 interview (`/factory-start`), the knowledge base and `/knowledge`, the profiles, the cost table, and reorders the build so the writing skills come first.

## Things to remember that are easy to lose

The falsifiability pass is not decoration; it is the direct answer to the largest counted failure in Matt's system. The formatter-only hook is a choice, not an oversight. Comments stay because Manuel said so, against pstack. The models table is where cost lives. The human merges. And the value of every vendored file is the reasoning behind it, which is why `PHILOSOPHY.md` comes before any of them.
