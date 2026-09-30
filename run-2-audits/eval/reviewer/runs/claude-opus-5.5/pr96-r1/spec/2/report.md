## Walk

1. Factory CI replaces `bash -n` with `bash .github/shellcheck.sh` over the ticket's five globs, plus the gate and its test (`factory-ci.yml:19-22`). The pin is 0.11.0 with two sha256 values (`shellcheck.sh:13-15`).
2. Template CI runs the zero-argument form first in `check` (`ci.yml:17-18`). The fixture job runs the same form in `/tmp/fx` after `apply`.
3. The playbook sentence is in the patch and in the generated `opening-a-pr.md`. It says to run the gate on every changed shell file before the PR opens.
4. Doctor: prints PASS with the local version, or a NOTE with the `brew install shellcheck` fix. Nothing in it is FAIL (`factory918.sh:274-276`).
5. Directives: every existing one now carries a same-line reason. Both CODING_STANDARDS files state the rule. Root `AGENTS.md` Verifying lists the command. `M0-findings.md` has a dated ShellCheck section.
6. Risk 1: a cached binary skips the sha check. A planted file in a shared `/tmp` has to be put there on purpose. The documented path is not affected.
7. Risk 2: test 6 depends on the runner image. It fails loudly, the day a 0.11.0 lands in `/usr/bin`.
8. Risk 3: an unmatched glob among matched globs is dropped silently. See [P1].
9. Risk 4: offline, curl fails loudly. An unpinned platform is refused with the install-by-hand message.
10. Risk 5: a `ci.yml` merge conflict on `update` lands in `.factory-merge`. `update`'s existing conflict path reports it.

## Would break

## Fails open

1. **A glob or file that matches nothing is dropped when another one matches.** `shellcheck.sh:34-38` refuses only when the total is zero. A lane passes its changed files, and one of them is misspelled, deleted, or a path with a space. `for f in $g` splits that path into words and each word fails `-f`. The gate still prints `files checked: N` and exits 0. The file never goes through ShellCheck, and only the count shows it. The same drop applies to the factory CI globs if `tests/` or `scripts/` is renamed. The script's header comment narrows the design's row to "match no file at all". The fix is in code: refuse per glob, as the table cell says. This is not a design hole.

```
| A glob matches no file | `shellcheck.sh: no file matched <globs>; the gate checked nothing` on stderr | 1 | fixes the glob; a gate that checked nothing is not a pass |
```

Documented step: ticket #88 `## Design`, usage line "bash .github/shellcheck.sh .claude/hooks/mode.sh  a lane before the PR opens, on every shell file the diff changes", and the table row quoted above.
Result: exit 0, and the unmatched argument is not linted and not reported.

## Not asked for

2. **Ledger line about a lost lane.** `docs/agents/ledger.md`: a process surprise from running this ticket, not part of the change.

```
2026-09-22 | Claude Fable 5.1 | as the #88 owner lane, ended its turn to wait on a background lane
```

3. **Template `AGENTS.md` Verifying line.** The criteria name only the factory's `AGENTS.md`. The template line is reasonable, but it is extra.

```
- [ ] `AGENTS.md` Verifying lists the command
```

hard findings: 1
