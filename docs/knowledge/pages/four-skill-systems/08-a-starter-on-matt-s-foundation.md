<!-- lines: 79 | source: pages/four-skill-systems.md | part 8/9 | title: Four Skill Systems (reference page) — A starter on Matt's foundation -->

## Contents (line numbers are for the Read tool's offset)
- L12: A starter on Matt's foundation
- L18: Week 0: set up
- L33: The loop for every change
- L54: Weeks 2 to 8: earn your own rules
- L69: Deferred on purpose
- L73: Cost, plainly
- L77: How you will know it is yours

## A starter on Matt's foundation

This is one defensible way to combine the four for someone in your position: Matt's spine because it is the only one designed to be learned from, with the smallest possible borrowings from the other three where his set is deliberately silent (verification evidence, brownfield understanding, the instruction-file shape). It is a proposal, in the sense Theo means when he says the value is the reasoning and not the text. Each borrowing is tagged with where it comes from so you can trace the reasoning back to the section above and disagree with it.

Two constraints shaped it. You are learning software development at the same time, so anything that hides decisions from you (arenas, overnight loops, "never block on the human") is deferred, not rejected. And you are on Claude Code, so pstack arrives only through a port and only for its standalone understanding skills.

### Week 0: set up

1. #### Install Matt's plugin and run setup once per repo Matt

   `claude plugins install mattpocock-skills`, then /setup-matt-pocock-skills. Choose **local markdown** as the tracker for now; it is first-class, needs no `gh`, and keeps tickets as files you can read. Switch to GitHub Issues when you start using PRs.
2. #### Write a short CLAUDE.md as a letter Theo Matt

   Under 40 lines. Who you are and what you value in three sentences; a glossary line pointing at `CONTEXT.md`; the two or three ways an agent can hurt itself on your machine; how to verify (which commands, and "do not run repo-wide checks unless I ask"); "Questions are read only"; "When grilling, ask one question at a time" if the rounds overwhelm you. Nothing about formatting (use a formatter) and nothing that is really a lint rule.
3. #### Add the understanding skills through a pstack port pstack

   `/plugin marketplace add ericlitman/open-pstack`, `/plugin install pstack@open-pstack`, then /pstack:setup-pstack with every non-Claude role set to `inherit-parent`. Delete the installed `hooks/hooks.json` so the router does not auto-fire; you want /pstack:teach, /pstack:how, /pstack:why, /pstack:blast-radius, /pstack:unslop and /pstack:bro by hand, not the 23 playbooks.
4. #### Optional guardrails Matt

   `npx skills@latest add mattpocock/skills --skill=git-guardrails-claude-code` installs a hook that blocks `git push`, `reset --hard`, `clean -f` and `branch -D`. Remove the push block later when you want agents to open PRs.

### The loop for every change

1. #### Understand before you touch anything you did not write pstack

   /pstack:teach the subsystem, or /pstack:how for a working model and /pstack:why when a strange design needs a reason. Put the terms you learn into `CONTEXT.md` in your own words; an agent-authored glossary you do not understand is "worse than none."
2. #### Grill, in one unbroken window, plan mode off Matt

   /grill-with-docs. Answer the decisions; let the agent find the facts. When you do not understand a question, /wait-what, or hand off to /teach and come back. Confirm the shared understanding before it builds.
3. #### Small change: implement right there. Large: spec, tickets, clear Matt

   /implement in the same window for anything that fits one session. Otherwise /to-spec, confirm the test seams, /to-tickets, approve the breakdown, `/clear`, then /implement <ticket> one at a time in fresh sessions. Close each ticket yourself.
4. #### Prove it, don't accept a claim Ras Mic Theo

   Matt's /tdd covers logic. For anything visible, require the headless evidence protocol: numbered screenshots named after assertions plus an `assertions.md`, and for bugs the failure captured before the fix. Ask for the smallest proof, not the full suite. Before a scary small diff, /pstack:blast-radius.
5. #### Review in a fresh session Matt

   /implement runs /code-review at the end, but "Same context reviewing itself isn't review": for anything that matters, open a new session and run /code-review against the spec and your standards there.
6. #### Commit; add the PR contract when you start using PRs Theo

   Matt's flow commits to the current branch and stops. When you move to branches and PRs, adopt Theo's contract verbatim: never open a PR unless asked, a plain-language conventional title, a body that states the problem then the fix and ends with the model and harness, one concern per PR, and /pstack:unslop over anything a human will read.

### Weeks 2 to 8: earn your own rules

1. #### Keep a failure ledger Theo

   A single file. Every time the agent surprised you, one line: date, model, what it did, what you wanted. After two weeks, run Theo's prompt: "look through my history... to see what the most common mistakes are." Promote an entry to a `CLAUDE.md` line only when it has recurred.
2. #### Ask whether each rule could be a lint or a script instead pstack Theo

   "The instruction IS the symptom." A formatter beats a formatting rule; a lint rule beats "always use X"; a CI check beats "remember to run the tests." Matt's setup-pre-commit and beta setup-ts-deep-modules do two of these for you.
3. #### Write your first skill after a successful run Ras Mic Matt

   Do a recurring workflow once with the agent, then have it write the `SKILL.md` from that context, then edit it with writing-for-agents (short, positive phrasing, a keyword description, decide user- or model-invoked up front). Patch it each time it fails.
4. #### Run the upkeep skills on a cadence Matt

   /improve-codebase-architecture every few days once the codebase has a vocabulary; /diagnosing-bugs when something breaks; /wayfinder only when a piece of work is bigger than a session and you can say what the destination is.

### Deferred on purpose

Parallel sessions and worktrees (until one task at a time feels slow, then one worktree per task, never two sessions in one checkout). Overnight loops and autopilots (Ras Mic built the popular one and walked away from it within a month). Arenas and four-model review panels (Theo's word: "token burners"; useful once you can judge which of three implementations is better). /no-comments (you will want the comments for a while). Memory (Theo turned his off after an audit; leave it off until you have something to audit). The full recorded-video evidence path (the headless screenshots do most of the work).

### Cost, plainly

Matt's own docs say a single /implement ticket over 100k tokens is normal and that "Forty-six questions across four rounds is an ordinary session." pstack's understanding skills spawn several read-only subagents per call. Budget for that, and match the model to the step: your best model for grilling, design and review; a cheaper one for mechanical work. Every one of the four now pays for direct subscriptions rather than API keys.

### How you will know it is yours

When your `CLAUDE.md` contains a rule none of theirs does, derived from something your agent actually did to you. Theo's test for a copied setup is blunt ("It's cringe and bad"); Matt's is gentler ("Hack around with them. Make them your own"); Lauren's is structural ("poteto-mode is my style. you may not want exactly that"). All three describe the same finish line.
