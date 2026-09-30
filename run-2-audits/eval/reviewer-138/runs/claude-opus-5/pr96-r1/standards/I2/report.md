## Would break

## Fails open

1. **One glob that matches nothing is dropped when another matches.** The emptiness check covers the union of the arguments, not each one. Run at HEAD, the factory's own CI command with the hooks glob stale (as a rename would leave it) prints `files checked: 15` and exits 0, the five hooks unchecked and CI green. The unquoted `$g` also word-splits, so an argument whose path holds a space is dropped the same way once a second argument matches, which the standard "Quote every path. Paths here contain spaces." speaks to. A per-argument refusal has to keep a project's three default globs all matching.
Documented step: ticket #88 `## Design`, "A glob matches no file | `shellcheck.sh: no file matched <globs>; the gate checked nothing` on stderr | 1 | fixes the glob; a gate that checked nothing is not a pass".
Result: only an all-empty set is refused; one empty glob among several prints a lower count and exits 0.
spec: table "A glob matches no file"/Exit

```sh
for g in "$@"; do
  for f in $g; do if [ -f "$f" ]; then files+=("$f"); fi; done
done
if [ "${#files[@]}" = 0 ]; then
```

## Standards breaches

2. **The symlink every caller types is asserted nowhere.** CODING_STANDARDS.md, Bash: "Test a command the way a user types it: absolute paths, from another directory, through the installed symlink." `tests/shellcheck/gate.sh` runs only the absolute source path; the new root `.github/shellcheck.sh` link is the form `AGENTS.md`, the playbook and both workflows type, and only CI exercises it. `tests/poteto-mode/overlap.sh` does honour the rule ("from the third call on the script runs by the relative path the playbooks name"). Behavior cannot differ here: the script reads neither `$0` nor `BASH_SOURCE`.

```sh
run() { set +e; got="$(bash "$script" "$@" 2>"$tmp/err")"; code=$?; set -e; err="$(cat "$tmp/err")"; }
```

3. **Two directive reasons call awk programs jq or Markdown.** The new rule asks for the reason and the narrowest scope that covers the intent. `review-brief.sh:17` is file-level over 362 lines on the claim "every single-quoted string here is a jq program or a Markdown template", but lines 125, 133 and 154 are awk programs (`!seen[$0]++`, `substr($0, 4)`), so the claim, and with it the file-level scope, is not the case. `review-comment.sh:40` calls the same awk fragment "the fenced block is Markdown emitted verbatim".

```sh
# shellcheck disable=SC2016 # every single-quoted string here is a jq program or a Markdown template; the backticks and $ are literal
```

## Fix alongside

4. **The 20 in `docs/M0-findings.md` cannot be re-derived from its own sentence.** 18 and 20 are both true at HEAD, but two files joined the ticket's set, `tests/shellcheck/gate.sh` and the gate script itself; the sentence names one, so a reader adds to 19.

hard findings: 1
