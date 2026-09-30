# Spec review report

## Walk

1. Factory CI runs `bash .github/shellcheck.sh` over the factory's 20 files in place of `bash -n` (`.github/workflows/factory-ci.yml:19`); at `ab47eb9` this prints `files checked: 20`, exit 0.
2. A project's `ci.yml` runs the gate first in `check` (`template/.github/workflows/ci.yml:17-18`); the fixture's zero-argument form over the template's files gives `files checked: 11`, exit 0.
3. The Opening a PR playbook, through its patch, names `shellcheck` on every changed shell file before the PR opens (`opening-a-pr.md.patch:8`).
4. `factory918 doctor` prints a `shellcheck` line above `slots filled` (`factory918.sh:274-276`), PASS when the pin is present, NOTE (not FAIL) when it is absent.
5. A `# shellcheck disable=` directive is modeled on `template/.agents/skills/poteto-mode/scripts/overlap.sh`, reason on the same line; `CODING_STANDARDS.md`'s Bash section states the rule, unenforced by CI, enforced by the Standards axis in review.
6. `AGENTS.md` Verifying lists the command; `docs/M0-findings.md` carries a dated line recording ShellCheck 0.11.0 as verified.
7. The script resolves each glob argument (or the default three) and checks the matched files; the design table (`spec-brief:165`) documents that a glob matching no file is refused with `shellcheck.sh: no file matched <globs>; the gate checked nothing`, exit 1.
8. Local ShellCheck is used when its version is the pin; otherwise the pinned release is downloaded once into `${TMPDIR:-/tmp}/shellcheck-0.11.0`, its sha256 is checked, and that binary runs; a cached binary already at that path is reused without re-checking.

## Would break

1. **The unmatched-glob refusal does not hold beside a glob that matches.** The commit named for this exact behavior (`01e5386`, "Refuse a glob that matches nothing even beside globs that match") does not produce the refusal when a matching glob is present alongside the empty one, per the reproduction already run: `bash .github/shellcheck.sh 'template/.claude/hooks/*.sh' 'nope/*.sh'` prints `files checked: 5`, exit 0, no message, at `template/.github/shellcheck.sh:38`.

```
| A glob matches no file | `shellcheck.sh: no file matched <globs>; the gate checked nothing` on stderr | 1 | fixes the glob; a gate that checked nothing is not a pass |
```

Documented step: `template/.github/shellcheck.sh:38` design row, "A glob matches no file" (spec-brief line 165), which the commit `01e5386` title claims to implement even beside globs that match.
Result: the empty glob is silently dropped from the checked set instead of refusing; `files checked: N` only names the shrunk count as the tell, so a renamed or moved directory (e.g. `tests/` or `scripts/`) shrinks the factory's checked set without any exit-1 refusal.

## Fails open

## Not asked for

hard findings: 1
