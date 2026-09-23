## Would break

1. **The human's merge gate still reads only `act-on items: 0`.** Babysit, its playbook and the review ladder all gained the "a `restart` comment is not merge-ready whatever its count" clause. `docs/knowledge/core/MANUAL.md`, the loop the human follows at the merge, did not. A one-hole round prints `restart` and then `act-on items: 0`, which the diff's own test asserts, so every condition on that checklist passes while the design hole is open.
Documented step: `docs/knowledge/core/MANUAL.md:103`, "It is ready when: CI is green on the latest commit; `spec-review`'s last line on the latest commit reads `act-on items: 0`; ... If any of those is missing, say 'fix that and come back'."
Result: the agent answers "ready" and the human merges a PR mid-restart, the case criterion 4 exists to prevent.
spec: criterion 4

```
+act-on items: 0" "two holes print one restart line and both are left out"
```

## Fails open

## Standards breaches

2. **`DECISIONS.md` P20 is no longer true at this commit.** Its title is "Three review rounds at most" and its body says `review-brief.sh` "refuses a fourth round" and that "`act-on items: 0` with `round: 3 of 3` makes the PR review-ready". After this change a restart resets the count, so one PR can get three rounds, a restart, then three more, and a `round: 3 of 3` comment carrying `restart` is not review-ready. Standard: `CODING_STANDARDS.md`, Markdown, "A count or a version in prose is true at the commit that lands it."

```
+# exactly `restart` (a design hole returned to architect) ends the history: the round and the
+# settled items are read from the comments after the last such comment, and a `restart:` line says
```

3. **`DECISIONS.md` P21 still lists three `cites:` forms.** The diff adds a fourth, `#N <reference>`, to `review-brief.sh` and to `SKILL.md` step 5. P21 reads "Only a Noted or Dismissed judgment item ending in `cites: user: "..." on #N`, `cites: DECISIONS.md <row>` or `cites: #N comment <date>` is pasted into the next briefs". Same standard as [S2].

```
+cites='cites: (user: "[^"]+" on #[0-9]+|DECISIONS\.md [A-Z]?[0-9]+|#[0-9]+ comment [0-9]{4}-[0-9]{2}-[0-9]{2}|#[0-9]+ '"$ref"')$'
```

## Fix alongside

4. **The no-form refusal reprints a value that looks well formed.** `holed()` matches the substring `hole:`, but the form check wants `hole: ` and `value()` strips at most one space, so `hole:table 2/D` is refused with a message showing `'hole: table 2/D'`, which does fit a form. Say the space is missing.

```
+value() { local v="${1##*hole:}"; printf '%s' "${v# }"; }
```

hard findings: 1
