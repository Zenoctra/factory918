## Walk

1. Criterion 1: `review-brief.sh` defines `risk_rule` with the Contract's sentence word for word. It appends the sentence to the Spec brief's `## Walk` bullet on the same line only when `grounding` is non-empty. The Standards brief never gets it. Tests 1A, 2A, 3A, 7A and 8A pin `${spec_bullets[0]} $risk_rule` in the Spec brief. Tests 1A and 3A check that the Standards brief lacks it.
2. Criterion 2: the check runs inside the cross-cutting block, after the empty-grounding refusal and before `.claude/state` is written. It strips CR and trailing blanks and uses the shared `fenced` rules to skip fenced lines. It passes on the first line that is exactly `## Risks` or `### Risks`. Otherwise it removes `$dir` and prints the Contract's refusal, naming the file or "the PR body's Blast Radius section", with exit 1. `refused_risks` pins 4A, 5A and 6A exactly, including that no state and no briefs were written. 9A and 9B keep their earlier assertions. Test 10 exercises line 40's `[ -f "$blast" ] || usage`.
3. Criterion 3: `review-comment.sh` is unchanged. A new fixture adds risk lines 4 and 5 after walk line 3 and gets the same counts and the same comment.
4. Criterion 4: the Opening a PR bullet and its patch hunk say the `## ` headings are demoted to `###` and why. They also say where `review-brief.sh` finds the risks.
5. `SKILL.md` step 1 names both heading forms and quotes the refusal, which matches the script's message. Step 4 carries the risk sentence word for word, and the patch mirrors both steps.
6. Ticket playbook step 5 asks for `## ` part headings and numbered risks under `## Risks`. It says the file is pasted "with its `## ` headings demoted to `###`".
7. SOURCES.md items 3 and 6 each gain the sentence the Contract asks for.
8. The CI fixture's `blast.md` now carries `## Risks` with a numbered risk. It greps the risk sentence in the Spec brief and checks the Standards brief does not have it.

## Would break

## Fails open

## Not asked for

1. **P27 and its ledger and M0-findings lines set a PR-opening rule outside the walk.** The ticket's "Run under" rules and the Contract are only about the Spec walk and the Risks heading. P27 tells every owner lane to open a stacked PR against `main` and then retarget it, a workaround in the `overlap.sh` area that is ticket #100's concern. It ships to projects through `template/docs/factory918/DECISIONS.md`.
```
The Spec reviewer's walk has one line per risk in the blast-radius grounding.
```

hard findings: 0
