# Standards report

## Would break

## Fails open

## Standards breaches

1. **The gate's own test never runs the command through the installed symlink.** CODING_STANDARDS.md, Bash: "Test a command the way a user types it: absolute paths, from another directory, through the installed symlink." `tests/shellcheck/gate.sh` hardcodes the template path and never calls the repository-root `.github/shellcheck.sh` symlink that `AGENTS.md`, `factory-ci.yml` and the playbook all tell a person or a lane to type. Test 5 even `cd`s into a fixture project and copies the script there, but `run()` still invokes the template path, so the copy sits unused and the symlink entry point is never exercised by this test.

```sh
here="$(cd "$(dirname "$0")/../.." && pwd -P)"
script="$here/template/.github/shellcheck.sh"
...
run() { set +e; got="$(bash "$script" "$@" 2>"$tmp/err")"; code=$?; set -e; err="$(cat "$tmp/err")"; }
```

## Fix alongside

2. **Duplicated Code.** The same `SC2086` disable comment, near word-for-word, is pasted three times in `template/.claude/hooks/delegation.sh` instead of being said once where the pattern is explained (e.g. at the top of the file, since the whole file relies on `set -f`).

```sh
  # shellcheck disable=SC2086 # set -f is on (line 7), so this splits words without globbing, which is the intent
  set -- $args
...
  # shellcheck disable=SC2086 # set -f is on (line 7), so this splits words without globbing, which is the intent
  set -- $words
...
    # shellcheck disable=SC2086 # set -f is on (line 7), so the tokenised segment splits into words without globbing
    while IFS= read -r seg; do scan_segment $seg; done <<< "$(printf '%s\n' "$command" | tokens)" ;;
```

hard findings: 0
