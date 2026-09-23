## Would break

## Fails open

1. **One argument that matches nothing is dropped, and the gate still passes.** The gate's own header makes an unmatched glob a failure; the code enforces that only when *every* argument misses. One glob out of five that names nothing (a renamed directory, a typo, or a path with a space, which splits on the unquoted `$g` and matches no file) is skipped without a word, and the run exits 0 over a smaller set. `files checked: N` is the only tell, and nothing in CI or the playbook asserts N. Standard: `CODING_STANDARDS.md`, Bash, "Quote every path. Paths here contain spaces"; and the file's own rule at `template/.github/shellcheck.sh:10-11`, "Globs that match no file at all leave the gate checking nothing, which is a failure, not a pass."

Documented step: `AGENTS.md:38`, "`bash .github/shellcheck.sh factory918.sh ... 'tests/*/*.sh'`, ShellCheck at the pin over 20 files"; `template/.agents/skills/poteto-mode/playbooks/opening-a-pr.md:9`, "Run `bash .github/shellcheck.sh` on every shell file the diff changes before the PR opens".
Result: after a rename, the factory's CI step checks 15 files and stays green; a lane that names a changed file the gate cannot see reports the gate as passed on a file nobody linted.

```sh
for g in "$@"; do
  for f in $g; do if [ -f "$f" ]; then files+=("$f"); fi; done
done
if [ "${#files[@]}" = 0 ]; then
```

## Standards breaches

## Fix alongside

2. **Duplicated Code: the factory's five globs live in two files.** `.github/workflows/factory-ci.yml:20` and `AGENTS.md:38` carry the same list; the gate holds a zero-argument default for a project but not for the factory, so the two copies drift apart on the next rename. A factory default inside the gate would leave one copy.

```yaml
run: bash .github/shellcheck.sh factory918.sh template/.github/shellcheck.sh 'template/.claude/hooks/*.sh' 'template/.agents/skills/*/scripts/*.sh' 'tests/*/*.sh'
```

3. **`tests/shellcheck/gate.sh` lands mode 100644.** Every other test script is 100755, and test 7 asserts the mode bit on the gate it tests. CI invokes it through `bash`, so nothing breaks today.

hard findings: 1
