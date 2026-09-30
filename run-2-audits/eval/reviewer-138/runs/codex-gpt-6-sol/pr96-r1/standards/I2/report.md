## Would break

1. **A quoted path containing a space cannot be linted.** `CODING_STANDARDS.md`, Bash, says to quote every path because paths here contain spaces, and to test a command with the absolute paths a user types. The gate splits each quoted argument again at spaces. From a project root, `bash .github/shellcheck.sh 'with space/clean.sh'` reports that no file matched and exits 1 even when that file exists. The per-file check required before a PR therefore cannot check such a changed shell file.

Documented step: `ticket.md`, `## Design`: `bash .github/shellcheck.sh .claude/hooks/mode.sh` is the lane's per-file invocation, and `'<glob>' ...` names exactly the supplied files.

Result: An existing shell file whose path contains a space is rejected with `no file matched ...; the gate checked nothing`.

spec: design shellcheck.sh [glob...]

```bash
files=()
for g in "$@"; do
  for f in $g; do if [ -f "$f" ]; then files+=("$f"); fi; done
done
```

## Fails open

2. **An unmatched argument is ignored when another argument matches.** `CODING_STANDARDS.md`, Bash, requires a gate dependency's failure to be printed before work continues. The ticket's `A glob matches no file` row requires exit 1 and a message so the caller fixes the glob. The gate checks only whether the combined file list is empty. I ran it with `clean.sh 'missing*.sh'`; it printed `files checked: 1` and exited 0, leaving the missing selection undisclosed.

Documented step: `ticket.md`, `## Design`: `A glob matches no file` prints `shellcheck.sh: no file matched <globs>; the gate checked nothing` on stderr and exits 1.

Result: With one matching argument alongside the missing glob, the gate reports success without mentioning the missing files.

spec: table A glob matches no file/Exit

```bash
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

hard findings: 2
