<!-- lines: 31 | source: pages/four-skill-systems.md | part 1/9 | title: Four Skill Systems (reference page) — Read me first -->

## Contents (line numbers are for the Read tool's offset)
- L9: Read me first
- L13: How to use this document
- L17: Five things the research changed about the framing you gave me
- L25: Who references whom

## Read me first

You asked for two things: each developer's system and how their skills plug into it, and a deeper reconstruction of Theo, who does not publish his skills as references. Both are here. The four skill sets were read in full from their repositories (Matt's 37 skill files, pstack's 45, the four public skills in Theo's T3 Code repo, Ras Mic's seven), and the videos, articles and talks around them were read through transcripts and summaries where the originals could not be fetched. Every claim below carries an evidence grade, and every section links to the file or page it came from, so you can check anything before you adopt it.

### How to use this document

Read the Matt Pocock section fully, since you plan to build on it. Read the Theo section next, because his material is the counterweight: he uses very few skills and puts his rules into lint, CI and a short letter-style `AGENTS.md` instead. Skim pstack and Ras Mic for the specific pieces called out as beginner-friendly. Then go to [the decisions](#decisions), which is the part written for you rather than about them: ten questions your own workflow must answer, with each developer's answer side by side. [The starter](#starter) at the end is one defensible way to combine them; treat it as a proposal to argue with, not a prescription.

### Five things the research changed about the framing you gave me

1. **pstack is not a curiosity that only earns a spot because Theo praised it.** It is the largest and most internally consistent of the four systems (a router, 23 playbooks, 24 action skills, 21 named principles), and Theo's actual verdict on 2026-08-19, after trying Matt's set and hers back to back, was "I am much more philosophically aligned with what Potato is cooking." The catch for you is that it is a Cursor plugin; running it in Claude Code means a community port. secondary
2. **Theo publishes more than "nothing."** His team's real `AGENTS.md`, four verification skills, six custom lint rules, AI review-agent configs and a triage playbook are all public in the T3 Code repository, and his six private skills are described in enough detail on video to reconstruct their purpose and rules. What he refuses to give you is a template, and his reason is worth taking seriously: "the value of this isn't the exact things I instructed. It is the way I thought of it." primary secondary
3. **Matt's system is the only one designed to be adopted by strangers.** Every promoted skill has a docs page with a "common questions" section built from real user reports, the set ships as an official Claude Code plugin, and the CHANGELOG explains every rename. That is why it is a sound foundation. It is also deliberately not parallel and not autonomous: one human, one session, one ticket at a time. primary
4. **Ras Mic's contribution is small and concrete, as you suspected.** Three skills of his own (worktree isolation, a two-layer code structure rule, evidence-driven testing), four vendored from Vercel, Greptile and pstack, and a one-page `AGENTS.md` that names four beats. His most interesting idea is biographical: he built the 3k-star Ralphy autonomous loop in January 2026, abandoned it within a month, and by June was calling wide-open loops "a slop machine." primary secondary
5. **They converge on more than you would expect.** All four keep the always-loaded instruction file short and push procedure into on-demand skills. Three of the four (Theo, Lauren, Ras Mic) push rules below prompts entirely, into formatters, lint rules and CI. All four demand proof over claims. All four say, in their own words, do not copy wholesale.

### Who references whom

These four are not independent samples. Theo reviewed Matt's repo and pstack in one video and credits Lauren Tan for the "hierarchy of interventions" idea (architecture beats lint beats prose). Ras Mic vendors pstack's unslop into his own set and rewrote its trigger so it fires automatically. Matt's skills cite the same engineering canon Lauren's principles do (Ousterhout's deep modules, Fowler's smells, Evans's ubiquitous language). When you see the same idea in three places below, that is partly convergence and partly cross-pollination.

What could not be verified

X posts, YouTube pages and digg.com write-ups were not fetchable from the research environment. Video content is therefore graded secondary and comes from auto-transcripts (Theo's Matt/pstack review) and summary sites (BigGo Finance, daily.dev, podcast show notes). Where two summaries disagreed, the disagreement is noted. Repo content is graded primary and was read directly from clones taken on the dates in the header.
