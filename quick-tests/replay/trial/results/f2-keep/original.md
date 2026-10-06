# Original moment 9f50624c-7112-4524-9171-38dc8c99957d (2026-09-30T19:45:37.441Z)

## Text

The background search has finished. Four of its findings bear on the questions above:

- **Q3: the factory already gives five different answers, and they conflict.**
  - [AGENTS.md:26](AGENTS.md:26) says to say so loudly and get a sign-off first.
  - [template/AGENTS.md:16](template/AGENTS.md:16) says to follow the file, then say why your instinct differed.
  - poteto-mode allows a visible `skip: <reason>`, except for delegation, where [feature.md:12](template/.agents/skills/poteto-mode/playbooks/feature.md:12) forbids it.
  - Where the spec is silent, the agent makes the call and records a Provisional decision you can overrule.
  - Writer flags must end `accepted: <reason>`.

  No text says how a subagent gets a sign-off, and no audit ever looked at these mechanisms themselves. So whatever you pick for Q3 replaces all five.

- **Q1/Q4: some rules about the route have worked.** The mandatory trail review caught the owner's errors three times out of three ([ticket.md:26](template/.agents/skills/poteto-mode/playbooks/ticket.md:26)). The delegation rule was broken while the agent knew it, and only a hook made it hold ([ledger.md:16](docs/agents/ledger.md:16)). You set both, with evidence behind them. That supports making ownership part of the test for "binding", so I'm keeping my recommendation.

- **Q2: reasons are uneven.** Some rules carry theirs, such as the one at [ticket.md:10](template/.agents/skills/poteto-mode/playbooks/ticket.md:10). Others don't: "never an arena", "Read no brief and no diff", and the 150-line reading cap in `knowledge`. The research for the map's research ticket landed on its branch. It found that detailed route guidance helps on simple tasks and for novices, and it separates two things: the writer holding back what it volunteers, and the writer limiting what the reader may go looking for. That fits (b): pass on route knowledge, with its reason, and never as a wall.

- **The run-2 constraints audit had a blind spot.** It sorted limits into five classes that follow the old "protect the world / shape the search" line, and it put "report format" on the safe side. Its own addendum admits that one report-format rule, the `spec:` citation gate, made a reviewer file nothing on a PR that had four real bugs. So "what done means" can hide a cap too. I'll put that to you as a test case in round two, once Q1 is settled.

Round one stands as asked. I'll wait for your answers.

## Tool calls in the same response
