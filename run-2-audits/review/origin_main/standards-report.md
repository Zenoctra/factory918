# Standards report

## Would break

## Fails open

1. **The PR list is capped at 100 and the cap is never reported.** The script's contract, in its own header and in P24, is every open PR. `gh pr list --limit 100` stops at the hundredth by PR age, and nothing checks whether the list came back full. PRs past it are not listed, not fetched and not diffed, so a shared path in one of them is invisible; the run then takes the `[ -z "$lines" ]` branch and prints a base. Hardening is one test: ask past the cap and refuse loudly when the list is still full.

Documented step: `template/.agents/skills/poteto-mode/playbooks/ticket.md:5` step 1 — "It prints `go: <label or none>`, one line per open PR whose own commits ... touch a path the ticket names in backticks"; `docs/knowledge/core/DECISIONS.md` P24 — "every open PR's head is fetched fresh".

Result: with more than 100 open PRs, step 1 prints `go: none` and `base: origin/main` and exits 0 over a path an unlisted PR owns. The owner branches from `main`, and the check that exists to stop exactly that says nothing.

```
prs="$(gh pr list --state open --limit 100 --json number,headRefName,closingIssuesReferences \
```

## Standards breaches

2. **`|| true` covers the whole token pipeline, not only grep's no-match.** The `|| true` is there because `grep -oE` exits 1 when the body names no path, which is a real case. With `pipefail` it also swallows a failure of `awk`, `tr` or `sort`: `paths` comes back empty and the run prints `paths: none` and `base: origin/main`, exit 0. Let grep's 1 through and let the rest abort.

Standard: `CODING_STANDARDS.md`, Bash — "A failure a gate depends on is printed before anything continues. `|| true` may stop a failure from aborting the command ..., never hide it."

```
  paths="$(printf '%s\n' "$body" | awk '/^## /{skip=($0 ~ /^## Diff[[:space:]]*$/)} !skip' \
    | grep -oE '`[^`[:space:]]+`' | tr -d '`' | sort -u || true)"
```

## Fix alongside

3. **`--diff` trusts `git diff --name-only` to print raw paths.** With the default `core.quotePath`, a path with a non-ASCII or escaped character comes back C-quoted (`"docs/caf\303\251.md"`). Under `GIT_LITERAL_PATHSPECS=1` that token matches nothing, so step 8 records no `## Overlap` for it. `-z`, or `git -c core.quotePath=false`, removes the class.

```
  paths="$(git diff --name-only "$base...HEAD")"
  [ -n "$paths" ] || exit 0
  export GIT_LITERAL_PATHSPECS=1
```

4. **Duplicated Code.** `while IFS=$'\t' read -r num head closes ... done <<< "$prs"` appears three times, each with the same `[ -n "$num" ] || continue` guard. One parse feeding three uses would keep the record shape in one place.

hard findings: 1
