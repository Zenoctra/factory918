## Would break

## Fails open

1. **A named file the gate cannot find is dropped without a word when any other file matches.** `CODING_STANDARDS.md`, Bash: "Quote every path. Paths here contain spaces." and "A failure a gate depends on is printed before anything continues." `$g` is expanded unquoted so that it globs, which also splits it on whitespace, and every word that is not a file is filtered out by `[ -f ]` with no message. The refusal fires only when *all* arguments match nothing. So a changed file whose path holds a space (`'my dir/x.sh'` becomes `my` and `dir/x.sh`, neither a file) or a mistyped or renamed path passed next to one real file is skipped, and the gate exits 0 on what is left. The `files checked: N` count is the only sign. Flagging it is enough: refuse any argument that matches no file, and name it.

```sh
for g in "$@"; do
  for f in $g; do if [ -f "$f" ]; then files+=("$f"); fi; done
done
if [ "${#files[@]}" = 0 ]; then
```

Documented step: `template/.agents/skills/poteto-mode/playbooks/opening-a-pr.md:9`, "Run `bash .github/shellcheck.sh` on every shell file the diff changes before the PR opens"; `template/.github/shellcheck.sh:6`, "exactly these".
Result: a changed file named in the list, if its path has a space or no longer exists, goes unchecked, and the gate prints a lower count and exits 0.

## Standards breaches

## Fix alongside

2. **Duplicated Code: the same directive reason appears three times.** The SC2086 directive in `delegation.sh` sits three times with nearly the same text and a line reference ("line 7"), which goes stale on the first edit above it. Keep the file's shape and write the reason once: "`set -f` is on at the top".

```sh
  # shellcheck disable=SC2086 # set -f is on (line 7), so this splits words without globbing, which is the intent
```

3. **Mysterious scope: the doctor passes any ShellCheck version.** `PASS  shellcheck $scv` prints for a build that is not the pin, and the gate then ignores that build and downloads the pin anyway. Nothing breaks, but PASS suggests the local binary is the one the gate uses.

```sh
  if [ -n "$scv" ]; then echo "PASS  shellcheck $scv"
```

hard findings: 1
