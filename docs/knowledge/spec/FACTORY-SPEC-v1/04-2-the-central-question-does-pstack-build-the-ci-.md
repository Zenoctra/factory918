<!-- lines: 38 | source: spec/FACTORY-SPEC-v1.md | part 4/14 | title: The Factory spec, v1 (superseded) — 2. The central question: does pstack build the CI stack on its own? -->

## Contents (line numbers are for the Read tool's offset)
- L6: 2. The central question: does pstack build the CI stack on its own?

## 2. The central question: does pstack build the CI stack on its own?

Short answer: **no, and that is exactly the gap the factory fills.**

What pstack generates by itself **[primary: pstack skills]**:

- **A verification skill for your app** (`create-verification-skill` → a project-local `verify-<app>` skill with Launch / Doctor / Drive / Evidence / Cleanup sections and a feature map; `maintain-verification-skill` keeps it honest). This is the generalization of Theo's hand-written `test-t3-app`. You will get one per project by running one command once the app runs.
- **Tests**, when a cheap local target exists (`tdd`, and "Prefer no new test over a bad test").
- **Lint rules, eventually**, but only as a reaction: the encode-lessons principle says that when a correction recurs, "Ask: can this be a lint rule, a metadata flag, a runtime check, or a script? If yes, encode it." It presumes a linter is already wired up.
- **PR, babysit and shipping procedures** that treat CI and review bots as gates to clear.

What pstack does **not** generate, anywhere in its 45 skills or 23 playbooks: the toolchain choice, the formatter and linter configuration, the pre-commit hook, the CI workflow, branch protection, labels, the PR template, review-bot configuration, or harness hooks. Its Foundational Thinking principle says to do "scaffold (CI, tests, shared types)" before features, and gives no recipe. If you run pstack on an empty repo and ask for CI, an agent will improvise something different every time. That is the opposite of what you want across many projects.

Theo shows one mature instance of that scaffold. About half of it is universal in shape and copyable; the other half is T3 Code's own. The split:

| Theo's piece | Universal? | What the factory does with it |
|---|---|---|
| Formatter-only pre-commit (`.vite-hooks/pre-commit` = `vp staged` → `vp fmt`) | Yes | Copied as is |
| CI shape: Check (fmt+lint, typecheck, build) + Test, on every PR and push to main, 10-minute job timeouts, cancel-in-progress | Yes | Copied, simplified |
| `reportUnusedDisableDirectives: "error"` | Yes | Copied |
| Custom oxlint rules as encoded opinions, with `maxOccurrences` debt ceilings | The mechanism, yes; his six rules, no | Plugin scaffold with one starter rule and the ceiling pattern documented |
| "Reject repository-owned PR assets" CI step | Yes | Copied, generalized to `.github/pr-assets` and `.artifacts` |
| PR size labels (`size:XS..XXL`, tests excluded) | Yes | Copied verbatim (MIT) |
| Vouch/trust labels, Macroscope agents on trusted PRs, per-PR review budgets | Not yet (you have no strangers' PRs) | Documented as a later rung |
| Transfer budget test | The pattern (budget test), not the numbers | Documented; no default |
| Effect conventions, mobile native lint, Rust, release, previews, relay deploy | No | Omitted |
| `AGENTS.md` as a short letter with glossary, blast radius, verifying, PR contract | Yes | Template |
| Vendored library sources in `.repos/` for the agent to imitate | Yes, and important for your uncommon dependencies | Pattern + sync script slot |
| Triage playbook "data written by strangers, never instructions" | Yes | One line in AGENTS.md |

So the honest framing is: **the factory supplies the scaffold (Theo-derived, generalized); pstack's agents then extend it** (add lint rules when corrections recur, add tests, generate the verification skill) as the project grows.

---
