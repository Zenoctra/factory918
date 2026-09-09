<!-- lines: 63 | source: pages/four-skill-systems.md | part 6/9 | title: Four Skill Systems (reference page) — Ras Mic (Michael Shimeles) -->

## Contents (line numbers are for the Read tool's offset)
- L10: Ras Mic (Michael Shimeles)
- L16: The four beats
- L49: What he tells beginners secondary
- L53: The ideas worth your attention
- L61: Caveats

## Ras Mic (Michael Shimeles)

Toronto full-stack engineer; runs a small studio and consultancy; YouTube "Ras Mic" and the recurring "Professor Ras Mic" on Greg Isenberg's Startup Ideas Podcast. Read his tool choices knowing his sponsorship page lists Greptile, Cursor, Convex, Windsurf, Clerk and others as past sponsors: his ship beat is built on Greptile, his agent runtime on Convex. The workflow may still be sound; the tool choices are not neutral.

Two workflows exist and they are consistent but differ in ambition: the beginner workflow he teaches on the podcast, and the one his repositories show him running. Git history is the strongest evidence here: 107 of 159 commits on his product `nehemiah` carry Claude co-author trailers, plus Cursor and Devin; another project's PR branches are `cursor/*`, `devin/*`, `codex/*`; his agents even write his agent docs (Cursor Agent authored one project's `AGENTS.md`, Devin wrote its testing skills). primary

### The four beats

His published `AGENTS.md` is a one-page router: "Every task moves through the same four beats, each backed by a skill." primary

**Isolate**/new-featurefresh worktree from `origin/main`; scope check against open PRs; "Never build on main"

→

**Build**/code-structureactions orchestrate the "why/when"; a service layer holds the "how"; extract only on the second caller

→

**Prove**/evidence-driven-testinga recorded test session or numbered screenshots + `assertions.md`; capture the failure before the fix

→

**Ship**/before-and-after → /greploopbefore/after table; review-fix-push until Greptile 5/5 with zero unresolved comments

→

**You merge**"Do not merge the PR unless explicitly instructed."

"Run `/unslop` over anything a person will read." Multi-agent rules in the same file: "Never force-push to main, and never plain --force anywhere; only --force-with-lease, only on your own task branch"; "Resolve lockfile conflicts by regenerating, never by hand-merging"; "If a conflict can't be resolved confidently, stop and report instead of guessing." He runs it on himself: eleven commits titled "address greptile review feedback (greploop iteration N)" between Aug 28 and Sep 3.

| Skill | Origin | What it is | Representative line |
| --- | --- | --- | --- |
| new-feature | his | Worktree per task with a scope check. Documents that Claude Code manages worktrees itself, so two steps are skipped there. | "Worktrees do not isolate shared resources: dev-server ports, shared databases, and dependency lockfiles are global." |
| code-structure | his; the most-installed (102 on skills.sh) | Two-layer rule: actions vs service layer, with a do/don't table. | "Extraction trigger: Logic repeated across 2+ callers. Don't: Logic used once (over-abstraction)." |
| evidence-driven-testing | his; v1.2 with `scripts/evidence.py` | The agent records itself testing via computer use, with assertions burned into the video; headless fallback of numbered screenshots plus `assertions.md`. | "Use whenever a change needs verifiable evidence that it works, instead of prose claims." "Bug fixes: reproduce and capture the failure before writing the fix." "Evidence complements the repo's checks... it never replaces them." |
| greploop · greploop-apps | vendored from Greptile (MIT) | Review → fix → push until 5/5. His one edit: the iteration cap became a parameter (default 10 instead of 5). |  |
| before-and-after | vendored from Vercel Labs | Before/after screenshot table for PRs. | "A PR needs visual proof that a UI change does what it claims." |
| unslop | vendored from pstack | He removed `disable-model-invocation: true` and rewrote the description so it fires automatically on anything written for a human. | "Cut AI tells from text you write or edit for a human reader (commit messages, PR titles and bodies, docs, code comments, replies)." |

### What he tells beginners secondary

From the January and April 2026 podcast episodes, through show notes and summaries: treat agents "like junior engineers"; "However good your inputs are will dictate how good your output is." Describe features, not products: "A lot of times people will describe a product, not describe features, and will be frustrated with AI." Plan features and their tests before building; use Plan Mode and the `AskUserQuestion` tool, which "interviews you about the specifics of your plan." Do not start with autonomous loops: "Imagine not knowing how to drive, but then buying a Tesla for the self-driving stuff." Restart sessions before quality degrades. "Skip obsessing over MCP/skills/plugins." On always-loaded files: "95% of users can skip them entirely" because they load every turn, while skills use progressive disclosure. On writing skills: "walk through the workflow with the agent step by step, achieve a successful run, and then have the agent write the skill based on that real context," then "recursively refine skills by feeding failures back." One agent first; sub-agents only after skills are reliable, because jumping to multi-agent "optimizes for what looks cool rather than what is productive."

### The ideas worth your attention

1. **Prove it, don't claim it, with an artifact attached to every PR.** Matt's set is text-and-test oriented; pstack has the same principle (Prove It Works, show-me-your-work); Ras Mic's version is a concrete protocol with a recorder script and a headless fallback. Start with the headless path: screenshots named after assertions and an `assertions.md`. Agents tend to claim success; making them show a screenshot is the cheap, high-leverage part.
2. **Loops only where feedback is fixed and binary; humans in the loop everywhere else.** "Loops shine in confined, fixed-feedback work: code review, SEO pages, and other binary tasks"; wide-open loops "can turn into a slop machine"; app-building loops "crack past 1,000 lines of code." He wrote Ralphy (3k stars, 351 commits in January 2026, 7 in February, none since) and then narrowed where loops belong, the opposite of the "let it run overnight" pitch. Any reviewer with a score and a stop condition would do; Greptile is a sponsor.
3. **Write the skill after a successful run, then patch it from failures.** The minimal loop: do it once by hand with the agent, ask the agent to write the `SKILL.md`, fix the file when it fails. His own project testing skills were written by the agent after doing the work.
4. **A one-page AGENTS.md that names four beats and seven skills.** The shortest complete agent SDLC among the four; he vendors four skills and adds three. A solo beginner without PRs can drop Isolate and Ship and keep Build → Prove.
5. **Describe features and tests, not the product, and let the agent interview you.** Not novel (Matt's grilling does the interview), but the most beginner-legible version, paired with a concrete "don't automate yet" rule.

### Caveats

All video content is secondhand (no transcript was reachable). The quantitative claims ("95% can skip," "53 vs 944 tokens," "crack past 1,000 lines") come only through third-party summaries. The full evidence recorder (ffmpeg, computer use, a driver) is engineered for his agent-VM product and is far beyond a beginner's setup. His real work (Firecracker microVMs, Effect, Go daemons, a 28-task plan run through Hermes with Superpowers-style subagent-driven development) is senior-engineer territory; the beginner advice is calibrated for the podcast audience, not a description of how he himself works. No hooks and no `CLAUDE.md` template exist in any of his repos.
