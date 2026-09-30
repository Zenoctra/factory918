# Standards report

## Would break

## Fails open

1. **A glob that matches nothing among several is dropped without a word.** `CODING_STANDARDS.md`, "Bash": "A failure a gate depends on is printed before anything continues." `template/.github/shellcheck.sh` only refuses when every glob together yields zero files; one glob among several matching nothing shrinks the checked set with no message, exit 0.

Documented step: `template/.github/shellcheck.sh:9-13` documents only the all-empty case ("Globs that match no file at all leave the gate checking nothing, which is a failure, not a pass"); `.github/workflows/factory-ci.yml:20` passes five globs, any one of which can go empty on a rename.
Result: coverage silently shrinks; the only tell is the `files checked: N` count in the log, which nothing compares against an expected number.

```
files=()
for g in "$@"; do
  for f in $g; do if [ -f "$f" ]; then files+=("$f"); fi; done
done
if [ "${#files[@]}" = 0 ]; then
  echo "shellcheck.sh: no file matched $*; the gate checked nothing" >&2
  exit 1
fi
```

## Standards breaches

## Fix alongside

2. **Duplicated Code.** The same `# shellcheck disable=SC2086` justification is copied near-verbatim three times across `scan_sed`, `scan_segment`, and the `Bash)` case in `template/.claude/hooks/delegation.sh`, all pointing at the same `set -f` at line 7. A single top-of-file directive scoped to the file's known intent (word-splitting without globbing throughout) would say it once.

```
+  # shellcheck disable=SC2086 # set -f is on (line 7), so this splits words without globbing, which is the intent
   set -- $args
...
+  # shellcheck disable=SC2086 # set -f is on (line 7), so this splits words without globbing, which is the intent
   set -- $words
...
+    # shellcheck disable=SC2086 # set -f is on (line 7), so the tokenised segment splits into words without globbing
     while IFS= read -r seg; do scan_segment $seg; done <<< "$(printf '%s\n' "$command" | tokens)" ;;
```

hard findings: 1
