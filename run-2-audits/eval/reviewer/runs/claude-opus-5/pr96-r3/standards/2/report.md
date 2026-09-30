## Would break

## Fails open

## Standards breaches

1. **The gate is never tested through the path a user types.** `CODING_STANDARDS.md`, Bash: "Test a command the way a user types it: absolute paths, from another directory, through the installed symlink." Every documented invocation names `.github/shellcheck.sh` — a symlink in the factory (`AGENTS.md:38`, the playbook's `**PRs.**` sentence), a copied file in a project (`template/AGENTS.md`, Verifying). Test 5 places that copy and then runs the template's original instead, so the copy is only counted as one of the four files; no assertion executes either the symlink or the project's copy. `run()` hard-codes `$script`:

```sh
run() { set +e; got="$(bash "$script" "$@" 2>"$tmp/err")"; code=$?; set -e; err="$(cat "$tmp/err")"; }
...
cp "$script" project/.github/shellcheck.sh
...
cd project
check "5 the zero-argument form from a project's root" 0 "ShellCheck 0.11.0, files checked: 4"
```

Behavior is unchanged: `factory-ci.yml:19` and the fixture step do run `bash .github/shellcheck.sh`, so the form is covered by CI, not by the test that claims to cover the rows of the design table. Fix: `cd project && bash .github/shellcheck.sh`, and one run through the factory's root symlink.

## Fix alongside

2. **The doctor's shellcheck line passes any version, not the pin.** Mysterious Name / misleading signal. `P25` and the gate both turn on one exact version, and the doctor already has the pattern for this two lines up (`chk "vp matches the ADR pin"`). Here any ShellCheck prints PASS:

```sh
local scv; scv="$(shellcheck --version 2>/dev/null | sed -n 's/^version: //p' || true)"
if [ -n "$scv" ]; then echo "PASS  shellcheck $scv"
```

A person reading `PASS  shellcheck 0.9.0` has no way to know the gate will ignore that binary and download 0.11.0. The printed version is the only tell. A NOTE when `$scv` is not the pin would say it.

3. **The skill count changes meaning on an empty glob.** `sync`'s report moved from `ls -d | wc -l` to an array:

```sh
local -a dirs; dirs=("$skills"/*/)
echo "vendored: ${#dirs[@]} skills. Review with git status, bump VERSION, commit."
```

With no match and `nullglob` off, `dirs` holds the literal glob and the line reports `1`. Unreachable today — the loops above have just copied every skill — so it is worth a `shopt -s nullglob` only if a would-break fix touches `cmd_sync`.

hard findings: 0
