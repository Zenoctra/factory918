## Would break

## Fails open

## Standards breaches

## Fix alongside

1. **The refusal helper writes the caller's globals.** `refused_risks` declares `label` and `where` `local` but assigns `out` and `code` at global scope, the same two names the surrounding test reuses for its own assertions. Nothing reads a stale value today, so this is only a latent trap for the next assertion added after a `refused_risks` call. Smell: mysterious scope / duplicated code.

```sh
refused_risks() {
  local label="$1" where="$2"; shift 2
  rm -rf .scratch .claude/state
  set +e
  out="$(bash "$skill/scripts/review-brief.sh" HEAD~1 "$@" 2>&1)"
  code=$?
```

2. **Three new cases assert the bullet but not the run.** 2A, 7A and 8A redirect stdout only, so a warning or a partial failure on stderr passes unseen, unlike 1A, which asserts `err.txt` is empty. The cases they mirror all pin stderr.

```sh
bash "$skill/scripts/review-brief.sh" HEAD~1 --blast-radius blast-risks-demoted.md > out.txt
has "$spec" "${spec_bullets[0]} $risk_rule" "Spec: a file with ### Risks continues the Walk bullet (2A)"
```

3. **`risk_rule` is pinned in four places.** The literal lives in `review-brief.sh`, `tests/spec-review/review-brief.sh`, `template/.agents/skills/spec-review/SKILL.md` and the `patches/mattpocock` patch. Duplicated Code by the baseline, but it is the deliberate shape here: the test holds script and skill together (P23, and the comment says so), and the patch is the vendoring mechanism. Noted, not to fix.

hard findings: 0
