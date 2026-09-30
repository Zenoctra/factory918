# Standards report

The change is prose plus one test fixture; the script's behavior is untouched (only its header comment moved). I checked the documented claim against the code that implements it.

## Would break

None.

## Fails open

None.

## Standards breaches

None. The core source (`docs/knowledge/core/SCENARIO-TABLE.md`) and its generated copy (`template/docs/factory918/SCENARIO-TABLE.md`) carry the same sentence, and the two `docs/agents/issue-tracker.md` copies match, so the generated-and-vendored rule in `CODING_STANDARDS.md` ("Markdown") holds.

## Fix alongside

None.

Checked, not filed: the sentence the three documents now add ("the skip ends at the next `## ` heading") is what the code does. `template/.agents/skills/poteto-mode/scripts/overlap.sh:49` turns the skip on and off only on a line matching `/^## /`, which a `### Contract` line does not match, so a `###` part stays inside the skipped section.

```
outside="$(printf '%s\n' "$body" | awk '/^## /{skip=($0 ~ /^## (Diff|Testing decisions|Design)[[:space:]]*$/)} !skip')"
```

The new fixture proves it rather than asserting it: the `### Contract` part quotes `src/x/y.txt`, which PR 2 touches in the same fixture (test 18 prints `#2 feat-b: src/x/y.txt`), so a skip that ended at the `###` heading would make test 17 exit 1 instead of 0.

hard findings: 0
