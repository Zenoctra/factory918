## Walk

1. Factory CI: `factory-ci.yml:19` runs the gate over the 20 named files in place of `bash -n`, pinned to 0.11.0 by version check or a sha-checked release download; `:21` runs the gate's test.
2. Template CI: `ci.yml` runs `bash .github/shellcheck.sh` first in `check`; the fixture job runs the same zero-argument form in `/tmp/fx`.
3. Playbook: the `**PRs.**` paragraph, carried by the patch, tells the lane to run the gate on every changed shell file before the PR opens.
4. Doctor: prints `PASS shellcheck <version>` for any installed version, otherwise NOTE with `brew install shellcheck` and the apt, dnf and winget equivalents.
5. Directives: each `disable=` now has a same-line reason. Both CODING_STANDARDS files state the rule; the factory's line does not add that CI cannot check it, but its header already names the Standards axis as the reader.
6. AGENTS.md Verifying lists the command; M0-findings has the dated 0.11.0 line with both checksums.
7. Risk 1 (cached binary, no checksum): confirmed at `shellcheck.sh:26`. It needs someone to tamper with the cache, which is outside the path. Not a finding.
8. Risk 2 (test 6 and `/usr/bin`): test fragility on a future runner image. No user path.
9. Risk 4 (offline or unpinned platform): refused loudly with curl's message or the gate's own. That is the design.
10. Risk 5 (`update` conflict on `ci.yml`): the conflict goes to `ci.yml.factory-merge`, which is loud. Outside the path.
11. Risk 3 (a partly unmatched glob list): see [P1].

## Would break

## Fails open

1. **One glob that matches nothing is dropped silently when another glob matches.**
```
| A glob matches no file | `shellcheck.sh: no file matched <globs>; the gate checked nothing` on stderr | 1 | fixes the glob; a gate that checked nothing is not a pass |
```
Documented step: ticket #88 `## Design`, the row "A glob matches no file".
Result: `shellcheck.sh:34-38` drops any pattern with no match and refuses only when the total is zero. `bash .github/shellcheck.sh 'template/.claude/hooks/*.sh' 'nope/*.sh'` prints `files checked: 5` and exits 0 (the grounding's own probe). If `tests/` is renamed, the factory CI set shrinks with no message. The same happens to a lane that passes a mistyped or deleted path together with real ones, or a path that contains a space, because `for f in $g` splits it. The table row covers one glob, and the script comment narrows it to "no file at all". The fix is to refuse each glob that matched nothing, which fits the row as written, so it is not a design hole.

## Not asked for

hard findings: 1
