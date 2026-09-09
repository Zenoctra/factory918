<!-- lines: 34 | source: notes/1-matt-pocock.md | part 3/10 | title: Research note: Matt Pocock — Philosophy (with verbatim quotes + citations) -->

## Contents (line numbers are for the Read tool's offset)
- L6: Philosophy (with verbatim quotes + citations)

## Philosophy (with verbatim quotes + citations)

**The one-line thesis.** "My agent skills that I use every day to do real engineering - not vibe coding." ([README.md](research/1-matt-pocock/skills-repo/README.md))

**Against process-owning frameworks.** "Developing real applications is hard. Approaches like GSD, BMAD, and Spec-Kit try to help by owning the process. But while doing so, they take away your control and make bugs in the process hard to resolve. These skills are designed to be small, easy to adapt, and composable. They work with any model. They're based on decades of engineering experience. Hack around with them. Make them your own." ([README.md](research/1-matt-pocock/skills-repo/README.md))

**Agents as memoryless humans.** "Treat them like humans. Humans with weird constraints, sure—humans with no memory who are cloned and go right to work. But humans nonetheless." ([5 Agent Skills I Use Every Day, aihero.dev, updated 2026-03-16](https://www.aihero.dev/5-agent-skills-i-use-every-day)) And: "If you have a garbage code base, the AI will produce garbage within that code base." (same source)

**Four failure modes the skills exist to fix** ([README.md](research/1-matt-pocock/skills-repo/README.md), "Why These Skills Exist"):
1. *"The Agent Didn't Do What I Want"* — "The most common failure mode in software development is misalignment... There is a communication gap between you and the agent. The fix for this is a **grilling session** - getting the agent to ask you detailed questions about what you're building." Quoting Thomas & Hunt: "No-one knows exactly what they want".
2. *"The Agent Is Way Too Verbose"* — "Agents are usually dropped into a project and asked to figure out the jargon as they go. So they use 20 words where 1 will do. The fix for this is a shared language." He calls the resulting `CONTEXT.md` glossary "the single coolest technique in this repo. Try it, and see." His before/after: "**BEFORE**: 'There's a problem when a lesson inside a section of a course is made "real" (i.e. given a spot in the file system)'" vs "**AFTER**: 'There's a problem with the materialization cascade'".
3. *"The Code Doesn't Work"* — "Without feedback on how the code it produces actually runs, the agent will be flying blind... You need the usual tranche of feedback loops: static types, browser access, and automated tests. For automated tests, a red-green-refactor loop is critical."
4. *"We Built A Ball Of Mud"* — "Because agents can radically speed up coding, they also accelerate software entropy. Codebases get more complex at an unprecedented rate. The Fix for this is a radical new approach to AI-powered development: caring about the design of the code." Quoting Ousterhout: "The best modules are deep."

**Summary line:** "Software engineering fundamentals matter more than ever. These skills are my best effort at condensing these fundamentals into repeatable practices, to help you ship the best apps of your career." ([README.md](research/1-matt-pocock/skills-repo/README.md))

**The hub's framing** ([aihero.dev/skills](https://www.aihero.dev/skills)): "An agent is only as good as the process you give it. Left to guess, it writes plausible code that quietly rots the codebase." and "A skill encodes one good habit (grilling a plan, writing a spec, reviewing a diff), so the agent runs it the same way every time."

**Smart zone / dumb zone.** "Early in a session the agent is in a 'smart zone' — sharp, focused, recall is good. As the session grows it drifts into a 'dumb zone'... On frontier models, the dumb zone commonly begins around 125K-150K tokens — though this is debated." ... "Plan around the smart zone, not the window." ([AI Coding Dictionary: smart zone](https://www.aihero.dev/ai-coding-dictionary/smart-zone); the concept is credited to Dex Horthy in his AIE workshop, per [videohighlight summary](https://videohighlight.com/v/-QFHIoCo-Ko), secondhand.) Note the number has moved: the May 2026 "9 things" article says ~120k; the router now says ~150k ([CHANGELOG 1.2.0](research/1-matt-pocock/skills-repo/CHANGELOG.md): "the smart zone figure is updated from ~120k to ~150k tokens").

**Facts vs decisions.** "Finding _facts_ is your job, never the user's... The _decisions_ are the user's: put each to them and wait." ([grilling/SKILL.md](research/1-matt-pocock/skills-repo/skills/productivity/grilling/SKILL.md))

**Writing for agents.** "Skills don't have to be long to be impactful. You just need to choose the right words." ([5 Agent Skills](https://www.aihero.dev/5-agent-skills-i-use-every-day)) His preference for user-invoked skills, from the AI Engineer "skill hell" talk (secondhand transcription): "Every model-invoked skill has a cost in unpredictability: the model may choose not to follow the context pointer" and "I much prefer removing that level of unpredictability" ([biggo summary of AI Engineer podcast, 2026-06-29](https://finance.biggo.com/news/e88eeef727a29496)).

**Against "specs to code".** In the "Software Fundamentals Matter More Than Ever" talk he "critiques the 'specs to code' movement, noting personal attempts 'resulted in increasingly poor quality code,' and dismisses the notion that 'code is cheap'" ([videohighlight summary](https://videohighlight.com/v/v4F1gFy-hqg), secondhand).

**"Config is death."** The setup docs page records the standing answer to requests for per-user preference config: "skills stay opinionated: *'Config is death.'* Preferences belong in your `CLAUDE.md` as plain instructions, which every skill already reads." ([docs/engineering/setup-matt-pocock-skills.md](research/1-matt-pocock/skills-repo/docs/engineering/setup-matt-pocock-skills.md))

---
