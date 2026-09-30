## Would break

## Fails open

## Standards breaches

1. **P27 and its records are a second concern in the #91 PR.** `AGENTS.md`, "Pull requests": "one concern per PR". The stacked-PR retarget workaround (P27, the M0-findings line and the first ledger line) is about `overlap.sh`'s coverage and ticket #100, not the Spec walk's risk lines. Recording a verified fact and a surprise is required, but a new Provisional decision about how owner lanes open stacked PRs is a separate choice that the #91 review has to judge alongside the walk change.

```
+| P27 | A stacked PR is opened against trunk, then retargeted | An owner lane whose PR stacks on another opens it with `--base main` and retargets it to the parent branch with `gh pr edit --base` in the next command, ...
```

## Fix alongside

2. **Duplicated Code: `refused_risks` beside the inline 9A refusal block.** The new helper runs the script, compares exit 1 and the exact `ticket:`/`round:`/refusal output, and checks that no state and no briefs exist. The 9A block directly below repeats that same shape inline for the missing-grounding refusal. Making the refusal line a parameter lets 9A use the helper too.

```
+refused_risks() {
+  local label="$1" where="$2"; shift 2
+  rm -rf .scratch .claude/state
+  set +e
+  out="$(bash "$skill/scripts/review-brief.sh" HEAD~1 "$@" 2>&1)"
```
```
 rm -rf .scratch .claude/state
 set +e
 out="$(bash "$skill/scripts/review-brief.sh" HEAD~1 2>&1)"
```

hard findings: 0
