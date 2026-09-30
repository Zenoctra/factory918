# Standards report

## Would break

## Fails open

## Standards breaches

## Fix alongside

1. **The Ticket playbook redefines a shape it says it is quoting.** Step 5 sends the lane to `blast-radius` "in that skill's hand-back shape", then adds a shape that skill does not produce: `blast-radius/SKILL.md:43` hands back `- **Risks.**` as a bullet, and the new sentence demands `## ` headings with `## Risks`. A lane that follows the named skill is refused at Opening a PR, after the work. The refusal is loud and corrective, so this is a judgement call, not a hard finding; the fix is to change the hand-back shape in `blast-radius/SKILL.md` (through a patch, AGENTS.md rule 3) or to stop citing that skill's shape here.

```
-...in that skill's hand-back shape (what it does; ...; risks; cleared; before you merge), with a risk for every session kind
+...in that skill's hand-back shape (what it does; ...; risks; cleared; before you merge), each part under a `## ` heading and one numbered risk per line under `## Risks`, with a risk for every session kind
```

2. **SKILL.md reads as source-restricted where the script is not.** The prose binds a level to a source ("exactly `## Risks` in a file or `### Risks` in a PR body"), while the check accepts either line from either source, which test 2A pins on purpose ("the source restricts no level") and `DECISIONS.md` P26 states correctly. The script's header comment repeats the narrower reading. Nothing breaks, but a reader of `SKILL.md` or of the header expects a refusal the script never issues.

```
+      $0 == "## Risks" || $0 == "### Risks" { found = 1; exit }
```

Checked and clear: the patch text matches the template byte for byte for both edited vendored files (`spec-review.SKILL.md.patch`, `opening-a-pr.md.patch`); `ticket.md` and `review-brief.sh` are `sync`'s `keep_files`, so direct edits are right; the refusal message is identical in the script, in `SKILL.md` and in the test; `DECISIONS.md` is 95 lines and both the generated header and `INDEX.md` say 95; the new awk reuses `$fenced`, so the Risks scan and the report scan share one fence rule; the refusal runs before `.claude/state/review` is written; the file-wide `# shellcheck disable=SC2016` already carries its reason.

hard findings: 0
