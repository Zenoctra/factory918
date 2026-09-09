<!-- lines: 23 | source: spec/FACTORY-SPEC-v2.md | part 10/17 | title: The Factory spec, v2 — 6. Contradictions between the vendored skills, and how the factory resolves them -->

## Contents (line numbers are for the Read tool's offset)
- L6: 6. Contradictions between the vendored skills, and how the factory resolves them

## 6. Contradictions between the vendored skills, and how the factory resolves them

| Conflict | Files | Resolution | Where it lives |
|---|---|---|---|
| Spec-first (Matt) vs "the best spec is code" (pstack) | to-spec, to-tickets vs poteto-mode, figure-it-out | Phase separation. Planning skills own everything before a ticket exists; pstack owns everything after. pstack's Multi-phase plan playbook and figure-it-out are not used for planning. | mode hook; AGENTS.md "Phases" |
| Auto-PR at the end of every playbook (pstack) vs "Never make a PR unless the developer explicitly asks" (Theo) | opening-a-pr.md vs AGENTS.md | A ticket is the explicit ask. Ticket-driven work ends in a PR that closes the ticket; conversation-driven work ends in a commit on a branch unless asked to file. | AGENTS.md "Pull requests" |
| Never block on the human (pstack) vs decisions are the human's (Matt) | principle-never-block-on-the-human vs grilling | Decisions were made in planning and live in the spec/ticket. In execution, anything the ticket settles is not re-asked; anything it does not settle is prototyped and presented unless irreversible. | Ticket playbook step 3 |
| Repo-wide checks forbidden locally (Theo) vs full suite at the end (Matt) vs "nearby validation" (pstack) | AGENTS.md | Targeted checks locally; CI runs everything; exception: if the whole suite runs under 30 seconds, run it all. | AGENTS.md "Verifying" |
| Thin commit hook (Theo) vs thick (Matt) | .vite-hooks/pre-commit vs setup-pre-commit | Thin (formatter only) plus format-on-write in the harness, because agent-authored repos produce many commits and CI is the single full gate. **[decide]** if you want thick early. | vite.config.ts `staged`, settings.json |
| Comments are a smell and get deleted (pstack) vs "Comments describe how a thing is used" (Theo) | no-comments, comment-sicko vs AGENTS.md Taste | **Resolved by Manuel: comments stay.** `no-comments` and the Comment Sicko agent are not vendored; Opening a PR no longer runs it; `AGENTS.md` Taste says so in his words. The other Fowler smells still apply at review. | DECISIONS.md #4; opening-a-pr.md patch; AGENTS.md |
| `disable-model-invocation: true` on Matt's user-invoked skills vs port-stripped pstack skills | frontmatter | Correct as is: planning skills should never fire on their own; pstack's must be reachable by the router. No change. | — |
| Two `tdd`s, two `teach`s | Matt vs pstack | pstack's only; Matt's "pre-agreed seams" survive as the spec's Testing Decisions section, which the Ticket playbook hands to `tdd`. | Ticket playbook step 5 |
| Two code reviews (Matt two-axis vs pstack interrogate) plus Claude's built-in | spec-review, interrogate, /code-review | A ladder, not a choice: spec-review always (Spec axis is the only check against the ticket), interrogate when contested, built-in `/code-review` as the zero-config fallback, external bots when present. | review-ladder.md |
| pstack's `/deslop`, `control-ui`, `/loop` | port substitutions | Already substituted by open-pstack (bundled deslop; Claude's `verify`, `run`, `loop`). No change. | — |
| Model slugs in playbook text (Grok, Sol) | feature.md, poteto-mode | Overridden by the models sheet; text left alone so `factory918 sync` stays clean. | ~/.claude/pstack-models.md |
| Matt's `to-tickets` needs labels that setup does not create | docs/engineering/triage.md ("Create the five state labels and two category labels yourself") | `factory918 labels` creates them with `gh label create --force`; `labels.yml` keeps them in sync. | factory918.sh, .github/labels.json |

---
