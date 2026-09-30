# Standards report

## Would break

1. **The playbook's shellcheck line does not scope to the diff.** `template/.agents/skills/poteto-mode/playbooks/opening-a-pr.md:9` tells a lane to run the bare command on every changed shell file, but the command as written takes no file arguments, so it runs the gate's own fixed globs instead of the diff's files.

```
Run `bash .github/shellcheck.sh` on every shell file the diff changes before the PR opens; it is the gate CI runs, so the finding lands in this lane instead of a review round.
```

Documented step: `template/.agents/skills/poteto-mode/playbooks/opening-a-pr.md:9`
Result: the zero-argument form only checks `.claude/hooks/*.sh`, `.agents/skills/*/scripts/*.sh` and `.github/shellcheck.sh` (`template/.github/shellcheck.sh:39`). A changed shell file outside those three globs (a project's top-level script, a `scripts/*.sh` not under a skill) is never checked, while the lane believes it satisfied "every shell file the diff changes."

## Fails open

2. **A glob that matches nothing among several matched ones is silent.** `template/.github/shellcheck.sh` only refuses when the whole set is empty; a single glob's own zero match is dropped without a word, against the script's own stated invariant.

```
+if [ "${#files[@]}" = 0 ]; then
+  echo "shellcheck.sh: no file matched $*; the gate checked nothing" >&2
+  exit 1
+fi
```

Documented step: `template/.github/shellcheck.sh:11` — "Globs that match no file at all leave the gate checking nothing, which is a failure, not a pass," together with CODING_STANDARDS.md's "A failure a gate depends on is printed before anything continues."
Result: a rename of `tests/` or a skill's `scripts/` directory shrinks the checked set with exit 0 and no message; only a smaller "files checked: N" is the tell, and nothing reads that number.

## Standards breaches

3. **The ShellCheck counts have no regenerating command nearby.** `docs/M0-findings.md`'s new section states specific counts with no command to reproduce them, against the file's own Markdown rule.

```
At `ab47eb9` the 18 shell files the ticket names produced 57 findings at the default severity and 0 after five fixes and the directives; `tests/shellcheck/gate.sh` joins the set, so the factory's gate checks 20 files.
```

Standard: `CODING_STANDARDS.md`, Markdown — "A count or a version in prose is true at the commit that lands it, with the command that regenerates it nearby." Other entries in the same file follow this (e.g. "What a review costs" ends with "To re-measure: ..."); this entry does not.

## Fix alongside

(none)

hard findings: 2
