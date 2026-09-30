## Would break

## Fails open

## Standards breaches

## Fix alongside

1. **Duplicated Code: the same `set -f` disable comment, three times.** `template/.claude/hooks/delegation.sh` carries the same `# shellcheck disable=SC2086` reasoning at three call sites (`scan_sed`, `scan_segment`, the `Bash` case), two of them word-for-word identical.
```
+  # shellcheck disable=SC2086 # set -f is on (line 7), so this splits words without globbing, which is the intent
   set -- $args
```
```
+  # shellcheck disable=SC2086 # set -f is on (line 7), so this splits words without globbing, which is the intent
   set -- $words
```
```
+    # shellcheck disable=SC2086 # set -f is on (line 7), so the tokenised segment splits into words without globbing
     while IFS= read -r seg; do scan_segment $seg; done <<< "$(printf '%s\n' "$command" | tokens)" ;;
```
Each directive is individually correct and on the narrowest scope, so this is not a breach of the directive rule itself; it is only the repeated shape worth collapsing into one comment above the three, or a short helper, if this file is touched again.

2. **Primitive Obsession, edge case: the new skill-count line trusts a bash glob that can return its own unexpanded pattern.** `dirs=("$skills"/*/)` relies on the shell's default (non-`nullglob`) behavior; if `$skills` ever held no subdirectories, `dirs` would hold one element (the literal glob string) and `${#dirs[@]}` would silently report 1 instead of 0.
```
+  local -a dirs; dirs=("$skills"/*/)
+  echo "vendored: ${#dirs[@]} skills. Review with git status, bump VERSION, commit."
```
This never happens on the documented path — `cmd_sync` populates `$skills` from `pstack`, `matt`, and `keep_files` earlier in the same function — so it is not a flag under "an edge case outside the intended path is not a flag," but it is worth a `shopt -s nullglob` guard the next time this function is edited.

hard findings: 0
