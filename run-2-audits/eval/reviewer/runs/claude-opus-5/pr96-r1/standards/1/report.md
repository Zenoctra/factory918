## Would break

## Fails open

1. **A path with a space is dropped from the gate, not checked.** `CODING_STANDARDS.md`, Bash: "Quote every path. Paths here contain spaces." `$g` is unquoted so the shell word-splits before it globs; `.claude/hooks/my hook.sh` expands to two words, neither is a file, and both are discarded by the `[ -f "$f" ]` test. The file is never linted and the run still exits 0. `IFS=` around the loop keeps the globbing and drops the splitting.

Documented step: `template/AGENTS.md:63` — "Shell: `bash .github/shellcheck.sh` before a PR ... with no arguments it checks the project's hooks and skill scripts, which is what CI runs."
Result: a hook whose name contains a space is silently outside the set, in the lane's run and in CI.

```sh
files=()
for g in "$@"; do
  for f in $g; do if [ -f "$f" ]; then files+=("$f"); fi; done
done
```

2. **One glob matching nothing is dropped while the others carry the run.** The header of the same file states the rule the code half-keeps: "Globs that match no file at all leave the gate checking nothing, which is a failure, not a pass." The refusal fires only when *every* glob misses. Rename `tests/` and the factory command keeps exiting 0 over 15 files; the printed count is the only tell and nothing asserts it. Refusing a glob that matches no file would make the miss loud, which is the design the header claims.

Documented step: `AGENTS.md:38` — the five-glob command, "ShellCheck at the pin over 20 files."
Result: exit 0, a green gate, a shrunken set.

```sh
if [ "${#files[@]}" = 0 ]; then
  echo "shellcheck.sh: no file matched $*; the gate checked nothing" >&2
```

## Standards breaches

## Fix alongside

3. **Duplicated Code: the same disable reason, three times, naming a line number.** Three directives in `delegation.sh` carry the same sentence, each pointing at "line 7". The reason is right and the standard asks for it on the line; the line number goes stale on the next insertion above `set -fuo pipefail`. Naming the option rather than its address would survive.

```sh
# shellcheck disable=SC2086 # set -f is on (line 7), so this splits words without globbing, which is the intent
```

hard findings: 2
