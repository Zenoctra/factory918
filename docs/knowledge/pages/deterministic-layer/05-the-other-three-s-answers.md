<!-- lines: 33 | source: pages/deterministic-layer.md | part 5/12 | title: The Deterministic Layer (reference page) — The other three's answers -->

## Contents (line numbers are for the Read tool's offset)
- L7: The other three's answers
- L27: Verdicts, where you asked for them

## The other three's answers

You said you prefer pstack for implementation and want to know where the others already do something equivalent or better. The table is the map; the notes after it are the verdicts. One structural fact first: pstack ships no tooling at all. Its determinism is prose that tells the agent to build the tooling (the ladder, "Prove It Works," a generator for verification skills) and to treat CI and bots as gates it must clear. Theo ships the tooling. Matt ships three skills that install tooling (pre-commit, git guardrails, dependency-cruiser) and disciplines for the rest. Ras Mic ships an evidence recorder and a review loop. primary

| Gate | Theo | pstack | Matt | Ras Mic |
| --- | --- | --- | --- | --- |
| Format | `vp fmt` on staged files at commit; `vp check` in CI | `/deslop` on the diff before commit, `/unslop` on prose (prose hygiene, not a formatter) | Prettier via lint-staged in `.husky/pre-commit` | `/unslop` on human-facing text |
| Lint | oxlint + six custom rules, unused-disable = error, debt ceilings | The ladder: "a lint or banned API that fails CI" is rung 2; no config shipped | Retro category "Automated checks"; review skips "anything tooling already enforces" | none (evidence "complements the repo's checks") |
| Typecheck | `vpr typecheck` in CI | typescript-best-practices auto-loads on `.ts`: no `any`, no `as`, exhaustiveness | `npm run typecheck` in pre-commit | none |
| Unit tests | Vitest per package; server sharded, serial | tdd: failing test first, "Prefer no new test over a bad test" | tdd: seams, red before green, three anti-patterns | Ralph loop refused to proceed on failing tests or lint |
| App-driving verification | test-t3-app / test-t3-mobile, hand-written for one app | create-verification-skill generates a per-repo `verify-<app>` skill; maintain-verification-skill keeps it honest | none; the diagnosing-bugs ladder lists curl, CLI, Playwright | evidence-driven-testing: computer use or Playwright, recorded |
| Evidence | before/after images, video, uploaded never committed; CI enforces | proof standards per surface (ARIA snapshot + screenshot; stdout/stderr/exit; second read) | "show the invocation and its output, redacted" | `evidence.mp4` with burned-in assertions, or `01-...-passed.png` + `assertions.md`; before/after table |
| Commit hook | formatter only | none | format + typecheck + tests | none |
| Harness hook | none in repo | none upstream (Cursor sticky mode instead); ports add a `SessionStart` mandate | `PreToolUse` hook that blocks destructive git with exit 2 | none |
| CI | seven jobs on every PR; sixteen workflows in total | Babysit classifies CI failures; "One retry only"; stale-base check with `git merge-base` | `lint:boundaries` folded into the umbrella check command | greploop polls the Greptile check-run |
| Review bot | Macroscope agents on trusted PRs, budgeted, "All clear" | Bugbot triage: fix / dismiss / ask, "Ask by default" for security, data, auth, billing, migrations; /interrogate multi-model | /code-review: two fresh subagents, twelve smells | Greptile until 5/5 and zero unresolved comments |
| Security | fork-safe workflows; "data written by strangers" | rubric "Security" lens: "Only flag security issues you can actually trace through the code" | git guardrails block push, reset --hard, clean, branch -D | "Never record a screen showing secrets"; `--force-with-lease` only |
| Architecture | banned imports, namespace rule, Effect conventions agent | /architect red flags; /how critique rubric | dependency-cruiser rules; deletion test; architecture survey | service-layer rule |
| PR contract | title, problem then fix, model + harness, media, one concern; babysit | Why / Scope / Tradeoffs / Blast Radius / Verification; never draft; Babysit never merges; Shipping's independent verdict | ADR when hard-to-reverse, surprising, a real trade-off | what changed, how tested "(every claim backed by evidence)", before/after, risks |

### Verdicts, where you asked for them

**Where pstack already does it, and better.** Review triage: pstack's Bugbot rubric (fix / dismiss / ask, with "Ask by default" for anything touching security, privacy, auth, billing, data, migrations, and "Historical data showed humans sometimes dismiss security/data-flow comments") is more careful than Theo's one-line babysit rule and more careful than Ras Mic's loop, which resolves every thread. Verification procedure: create-verification-skill is the generalization of Theo's hand-written test-t3-app; it is what you would run to produce one for your app. Shipping: nobody else has the independent-verdict rule.

**Where pstack is silent and someone else fills the gap.** The actual tooling. pstack tells the agent to encode lessons as lint but ships no lint; Theo's oxlint plugin and Matt's setup-ts-deep-modules show what the encoded rules look like. Commit hooks: Matt's setup-pre-commit is the only skill that installs one. Harness guardrails: Matt's git-guardrails-claude-code is the only one. Test discipline for beginners: Matt's tdd (seams, the three anti-patterns, the mocking rule) is more teachable than pstack's, which assumes you already know what a cheap local test target is. Evidence format: Ras Mic's numbered-screenshot convention is a concrete answer to pstack's "state what to capture and where it goes."

**Where they contradict.** Commit hook thickness (Theo thin, Matt thick). Comments (pstack deletes them; Matt's smells treat comments as neutral; Theo says "Comments describe how a thing is used, and move when the code moves"). Whether tests run locally (Theo: targeted only; Matt: full suite at the end of every ticket). Pick per situation, not per person.
