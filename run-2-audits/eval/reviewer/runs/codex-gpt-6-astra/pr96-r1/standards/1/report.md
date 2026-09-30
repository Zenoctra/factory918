## Would break

1. **Quoted paths containing spaces are split again.** `CODING_STANDARDS.md`, Bash: “Quote every path. Paths here contain spaces.” The unquoted `$g` splits each caller-supplied argument before glob expansion. Preserve literal file arguments and expand patterns without whitespace splitting.

Documented step: `template/.github/shellcheck.sh:6`, “bash .github/shellcheck.sh '<glob>' ... exactly these; quote a glob, this script expands it”.
Result: Passing `'scripts/with space.sh' clean.sh` skips the existing spaced path and can pass after checking only `clean.sh`. The test's spaced working directory does not exercise spaces inside an argument.

```sh
for g in "$@"; do
  for f in $g; do if [ -f "$f" ]; then files+=("$f"); fi; done
done
```

## Fails open

2. **An explicit unmatched argument disappears silently.** `CODING_STANDARDS.md`, Bash: “A failure a gate depends on is printed before anything continues.” The aggregate empty-set check allows a typo or stale explicit path to reduce coverage without reporting the omission. Refuse unmatched explicit arguments; optional default globs can retain their separate policy.

Documented step: `template/.github/shellcheck.sh:6`, “exactly these; quote a glob, this script expands it”.
Result: `bash .github/shellcheck.sh 'template/.claude/hooks/*.sh' 'nope/*.sh'` checks only the hooks and can exit 0, without naming the unmatched argument.

```sh
  for f in $g; do if [ -f "$f" ]; then files+=("$f"); fi; done
done
if [ "${#files[@]}" = 0 ]; then
  echo "shellcheck.sh: no file matched $*; the gate checked nothing" >&2
  exit 1
fi
```

## Standards breaches

## Fix alongside

hard findings: 2
