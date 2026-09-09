<!-- lines: 158 | source: pages/four-skill-systems.md | part 7/9 | title: Four Skill Systems (reference page) — The decisions you'll make -->

## Contents (line numbers are for the Read tool's offset)
- L16: The decisions you'll make
- L20: 1. Where does planning live, and how heavy is it?
- L34: 2. Who gets to invoke a skill?
- L48: 3. How much goes in the always-loaded file?
- L62: 4. How do you understand a codebase you did not write?
- L76: 5. What counts as done?
- L90: 6. One session or many? Serial or parallel?
- L104: 7. Which model, and how many vendors?
- L118: 8. How does work get merged?
- L132: 9. What do you refuse to let the agent do?
- L146: 10. When do you write a skill, and how?

## The decisions you'll make

You said you wanted to become opinionated through research rather than commit early. These are the ten questions a personal workflow has to answer, and none of the four answers them the same way. Each block gives every developer's answer, then a note on what the choice costs for someone learning software development at the same time. The point is not to pick the majority answer; it is to notice that these are choices, and that the people you respect chose differently for reasons tied to their situation.

### 1. Where does planning live, and how heavy is it?

Everyone plans. The question is whether the plan is a conversation, a document, a ticket graph, or code.

**Matt**A relentless interview first, always. On multi-session work the interview becomes a spec (a "decision record," throwaway once shipped) and tracer-bullet tickets on the issue tracker. Plan mode off during grilling.

**Theo**A two-sentence spoken prompt; the agent writes the plan; he approves it in a plan card and gives a stop point. Design decisions as HTML mocks he picks by letter. Plans are never committed to the repo.

**pstack**"i don't believe in planning. the best spec is code." Design happens by naming the data shape and running two competing implementations; a written plan exists only as its own playbook ("The plan is the deliverable. Do not implement.").

**Ras Mic**Describe features and their tests, not the product; use Plan Mode and `AskUserQuestion`. For real products he keeps heavy artifacts (a 28-task plan, ADRs, a threat model).

**Note**While you are still learning what good code looks like, Matt's interview is doing double duty: it aligns the agent and it teaches you the decisions a feature contains. That is worth the question volume for now. Theo's two-sentence style depends on already knowing what you want; Lauren's depends on being able to judge the diffs the arena produces. Grow toward those.

### 2. Who gets to invoke a skill?

Whether the agent may reach for a skill on its own, or only you.

**Matt**Two classes on one axis. Orchestrating skills are user-invoked (`disable-model-invocation: true`); reusable disciplines are model-invoked with trigger phrasing in the description. A user-invoked skill may call model-invoked ones, never another user-invoked one.

**Theo**Very few skills; descriptions are keyword-only because they cost context whether or not they fire; skills named in `AGENTS.md` or typed as `$skill`. Agreed with Matt's call: "which I think is a very good call."

**pstack**44 of 45 skills disable model invocation; only the router is invoked, and it routes by name. "Rules only apply through explicit routing." One skill auto-loads by file path (`.ts`).

**Ras Mic**A one-page `AGENTS.md` names which skill fires at each beat; he rewrote unslop to auto-trigger on any human-facing text.

**Note**Three of four converge: predictability beats cleverness, so make orchestration explicit and let only small disciplines auto-fire. When you write your first skill, decide which class it is before you write the description.

### 3. How much goes in the always-loaded file?

`CLAUDE.md` / `AGENTS.md` is read every turn. What earns a place there?

**Matt**Setup writes a short `## Agent skills` block pointing at `docs/agents/`; your preferences go there as plain instructions ("Config is death"). Vocabulary lives in `CONTEXT.md`, decisions in ADRs. His beta retro skill says the file should be "used incredibly sparingly, usually only for navigation pointers to other files."

**Theo**A 156-line letter: values, a glossary of who "you/we/user" are, the three ways to hurt yourself, the repo's one recurring defect as a checklist, how to verify, the PR contract. Everything else lives in docs, lint, CI or skills. "Less context is best as long as it has the context it needs."

**pstack**Almost nothing: a rules file mapping roles to models. Principles live in skills and are read at task start by the router.

**Ras Mic**"95% of users can skip them entirely"; his own template is one page: four beats, seven skills, git rules, and slots for "commands & checks, hard invariants... an environment quick reference."

**Note**All four agree it should be short. Theo's structure (values, glossary, blast radius, recurring defect, verification, PR contract) is the most transferable shape; Matt's `CONTEXT.md` is where the vocabulary goes so the main file stays small. Start under 40 lines and add a line only when you have seen the failure it prevents twice.

### 4. How do you understand a codebase you did not write?

Brownfield is most of real work, and the four differ most here.

**Matt**Build the glossary and ADRs by interview (/grill-with-docs help me document my repo), let domain-modeling cross-check what you say against the code, and run /improve-codebase-architecture as a survey. Honest limit: "a survey, not a rescue."

**Theo**Don't preload; let the model build context with tools, and use the instruction file to remove discovery calls. Keep internal docs in the present tense; vendor library sources so the agent imitates the real thing; snapshot real data for tests; memory off.

**pstack**Dedicated skills: /how (explorers plus explainer), /why (git history and MCP investigators with confidence tiers), /teach (diagram by diagram), /blast-radius. "/how first is cheaper than the second bug."

**Ras Mic**Project-scoped "how to test X" skills that record gotchas and failure modes; a scope check against open PRs; boundaries the agent must not touch.

**Note**This is where pstack earns its place in your set even if you never run its router: /teach and /how are the best tools here for someone who is also learning to read code. Pair them with Matt's glossary so what you learn is written down in words you chose.

### 5. What counts as done?

The agent will say it is finished. What do you require before you believe it?

**Matt**Red→green tests at seams you agreed in advance, typecheck and the full suite once, then a two-axis review (Standards, Spec) in fresh subagent contexts. "Same context reviewing itself isn't review."

**Theo**"Smallest proof that the change works": targeted tests and lint only, repo-wide checks forbidden locally ("CI owns the full suite"), one integrated pass in a real client on request, screenshots or video uploaded as PR evidence, then bots green.

**pstack**"Verify against the real artifact... not a proxy, self-report, or 'it compiles.'" A generated `verify-<app>` skill drives the app; /blast-radius for scary small diffs; an agent that did not write the code gives the shipping verdict.

**Ras Mic**Evidence attached to the PR: a recorded test session or numbered screenshots with `assertions.md`; the failure captured before the fix; a reviewer score of 5/5.

**Note**The strongest convergence in the whole study: proof, not claims. Matt's tests protect logic; Theo's and Ras Mic's screenshots protect UI; Lauren's independent verdict protects you from the author's blind spots. A beginner can adopt all three cheaply: tests at seams, a before/after screenshot for anything visible, and a review in a fresh session.

### 6. One session or many? Serial or parallel?

How much runs at once, and where the isolation comes from.

**Matt**One ticket per fresh context, cleared between; dispatch is manual; parallel /implement in one checkout is "worse than unsupported." Subagents for facts, research and review. Worktrees only in the beta.

**Theo**One thread = one task run to completion; many threads across machines, each in its own worktree; no subagents for ordinary work ("Match ceremony to task"). Terminal broke at 6+ agents, hence a GUI.

**pstack**Subagents by model role for everything; arenas, swarms, overnight loops, autopilots with one owner agent per PR. "Never block on the human." One writer per worktree is the concurrency rule.

**Ras Mic**Several harnesses in parallel on separate branches with him as the merge point; one agent first for beginners; loops only for binary tasks.

**Note**Start serial, one task per session, exactly as Matt's flow does. The moment you want two things at once, use a worktree per task (Theo, Ras Mic, Lauren all do), never two sessions in one checkout. Leave arenas, swarms and overnight loops until you can afford both the tokens and the review time they generate.

### 7. Which model, and how many vendors?

All four route work to models differently, and their answers changed monthly in 2026.

**Matt**"A dumb model won't give you good ideas": the smartest model for grilling. Skills are harness- and model-neutral by design; docs note where a skill over-fires on particular models.

**Theo**A routing table revised monthly: in Aug 2026, GPT-5.6 Sol as default ("does exactly what you tell it"), Fable 5 for taste and hard problems ("a genius that has to be tamed"), the cheapest model for triage and titles, Opus 5 demoted. Weights tokens per task and vision. Several direct subscriptions.

**pstack**Roles get models, set once by /setup-pstack: fast mechanical code on Grok, judgment and prose on Fable 5.1, every review panel on four models from three vendors because "The adversarial signal comes from model diversity."

**Ras Mic**Claude Code primary, plus Cursor, Devin, Codex and Hermes as parallel harnesses; commit trailers show Opus 4.8 and Fable 5 doing most of his product work.

**Note**Ignore the specific slugs; they were out of date within weeks for all of them. Keep the methods: use your best model for anything that needs judgment (grilling, design, review), a cheap one for mechanical bulk, and note in your own ledger which model made which mistake.

### 8. How does work get merged?

Commits, branches, PRs, bots, and who presses the button.

**Matt**/implement commits to the current branch and stops; you close tickets and open PRs ("commit to a branch and open a PR" is a common override). Incoming issues and PRs go through /triage with an AI disclaimer on every comment.

**Theo**"Never make a PR unless the developer explicitly asks." One concern per PR; body ends with model and harness; evidence uploaded, never committed; the agent babysits until bots are green, verifying each bot finding against source; a human merges.

**pstack**Opening a PR at the end of every playbook (worktree, small ordered commits, Conventional Commits, Why/Scope/Tradeoffs/Blast Radius/Verification, never a draft); Babysit never merges; Shipping lands only the verified run.

**Ras Mic**PR from a task branch with evidence and a before/after table; /greploop to 5/5; "Do not merge the PR unless explicitly instructed"; `--force-with-lease` only.

**Note**All four keep the merge button human. If you are solo and not yet using PRs, Matt's commit-and-stop is enough; the day you add PRs, adopt Theo's contract (title, problem-then-fix body, attribution line, one concern) because it is the shortest and it produces a readable history for the person you will be in six months.

### 9. What do you refuse to let the agent do?

The prohibitions say more about a system than the permissions.

**Matt**Config knobs; question caps; file paths in tickets and briefs; horizontal slicing; mocking your own modules; tautological tests; `--abort` on conflicts; `/compact` as a reflex. Optional hook blocks `git push` and destructive git.

**Theo**Committing plans or scratch; repo-wide checks locally; opening browsers or computer use without permission; killing processes by pattern; touching the live database; treating "please stop" as a permission boundary; memory.

**pstack**Force-push, deploys, data deletion and customer messages without confirmation; explanatory comments; planning ceremony; em dashes; mocks of core business logic; letting a file cross 1k lines in a PR.

**Ras Mic**Building on main; plain `--force`; hand-merged lockfiles; merging; wide-open autonomous loops; always-loaded files for most users.

**Note**Notice that Theo's list is the only one derived from a logged failure audit rather than from principle. Write yours the same way: keep a file of the times the agent surprised you, and promote an entry to a rule only when it recurs.

### 10. When do you write a skill, and how?

Everyone says write your own. They disagree about when.

**Matt**A skill "encodes one good habit"; write against writing-for-agents (context pointers, leading words, prune no-ops, "Prompt the positive"); user-invoked by default; "Skills don't have to be long to be impactful."

**Theo**From the failure ledger: audit your sessions for recurring mistakes and codify the fix; 12–16 hours of work for six skills; keyword-only descriptions; three scopes across machines; "Don't just blindly install all the skills here."

**pstack**First ask if it should be a lint or a script instead ("The instruction IS the symptom"); /reflect proposes edits after hard tasks, applied only with approval; /automate-me drafts your own mode from transcripts.

**Ras Mic**Do the workflow once with the agent, get a successful run, have the agent write the skill from that context, then patch it every time it fails.

**Note**Ras Mic's sequence is the right first move for you, Matt's writing-for-agents is the right editor for the result, and Lauren's question ("could this be a lint rule?") is the right filter before either. Theo's ledger is what turns a one-off skill into a system.
