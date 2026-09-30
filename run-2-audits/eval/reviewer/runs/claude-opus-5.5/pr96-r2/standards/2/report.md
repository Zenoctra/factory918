## Would break

1. **An absolute path to a file under a spaced directory is refused as "no file matched".** `CODING_STANDARDS.md`, Bash: "Quote every path. Paths here contain spaces." and "Test a command the way a user types it: absolute paths, from another directory". The gate expands each argument unquoted so a quoted glob works, which also word-splits a literal path. The factory clone itself lives under `.../Under The Sun Collective/...`, so `bash .github/shellcheck.sh "$PWD/factory918.sh"` splits into `.../Under`, `The`, `Sun`, `Collective/...`. None of the pieces is a file, so the gate exits 1 and says no file matched, although the file exists. A project file named `scripts/my tool.sh` gets the same result. The refusal is loud but gives the wrong reason, and nothing in it says how to correct the call. A fix that keeps glob support tests `[ -f "$g" ]` first and expands only when the argument is not a file.

Documented step: `template/AGENTS.md` Verifying: "Shell: `bash .github/shellcheck.sh` before a PR, on the files the diff changes"; `CODING_STANDARDS.md` Bash: "Test a command the way a user types it: absolute paths".
Result: exit 1, `shellcheck.sh: no file matched <path>; the gate checked nothing`, for a file that exists.

```sh
for g in "$@"; do
  matched=0
  for f in $g; do if [ -f "$f" ]; then files+=("$f"); matched=1; fi; done
```

## Fails open

## Standards breaches

## Fix alongside

2. **Duplicated Code: the factory's glob set is written out twice.** The 20-file set appears word for word in `factory-ci.yml` and in `AGENTS.md`, and a third time in the brief's merge check. When a directory is added or renamed, every copy has to be edited (Shotgun Surgery), and the "20 files" count in the prose goes stale too. A zero-argument default for the factory, or one file that lists the set, would hold it in one place.

```yaml
run: bash .github/shellcheck.sh factory918.sh template/.github/shellcheck.sh 'template/.claude/hooks/*.sh' 'template/.agents/skills/*/scripts/*.sh' 'tests/*/*.sh'
```

3. **The cached binary is trusted without its checksum.** This is a judgement call and matches the author's Risk 1. The sha is checked only on the run that downloads. After that, any executable at the cache path runs as the pin, with no `--version` check. Re-running the `grep -qx "version: $version"` test against the cached `$bin` would catch a replaced file cheaply.

```sh
  if [ ! -x "$bin" ]; then
```

hard findings: 1
