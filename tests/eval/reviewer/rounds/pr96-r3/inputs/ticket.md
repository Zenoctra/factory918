## Problem

Observed (agent): three of the ten hard findings across the three review rounds on PR #87 were shell mechanics a linter reports (a failing command inside a process substitution, an unquoted command substitution, stderr discarded). Nothing in the factory's checks or the template's CI runs `shellcheck`, so each one cost a review round and a fresh writer lane to fix. On PR #92, where the writer ran `shellcheck` before every report, that class produced zero findings in three rounds. The tool was not on Manuel's machine until it was installed by hand on 2026-09-21 (0.11.0, Homebrew), so a project machine will lack it too.

## Decision

> user: ShellCheck sounds like a good ticket for sure. It sounds like something that agents could pretty universally benefit from, so it should probably be in this factory project scope but also it should be present in pretty much every project that inits factory in it too. So it should be a universally designed feature

> user: itd be nice if something like that could get caught before CI checks that kick us back at a brand new writer and 200k tokens on context window to fix some random syntax error like that.

> agent: On catching it before CI without a new writer, the cheap place is the writer lane's verification list, run before it reports. That costs no tokens and keeps decision 5, the formatter-only commit hook, intact.

## Acceptance criteria

- [ ] `shellcheck` runs in the factory's CI over `factory918.sh`, `template/.claude/hooks/*.sh`, every `scripts/*.sh` under `template/.agents/skills/` and `tests/*/*.sh`, pinned to an exact version (a release download or a pinned action, not whatever the runner image carries), and passes at the merge commit.
- [ ] The template's CI runs `shellcheck` over a project's `.claude/hooks/*.sh` and `.agents/skills/*/scripts/*.sh`, pinned the same way, and the fixture flow passes it.
- [ ] The Opening a PR playbook (through its patch) names `shellcheck` on every changed shell file before the PR opens, so a lane runs it before CI does.
- [ ] `factory918 doctor` has a `shellcheck` line, its fix `brew install shellcheck` (or the platform's equivalent), and the check is `NOTE`, not `FAIL`, on a machine without it.
- [ ] A `# shellcheck disable=` directive is allowed only with its reason on the same line; the existing one in `template/.agents/skills/poteto-mode/scripts/overlap.sh` is the model. CI does not enforce the reason; the Standards axis does, and `CODING_STANDARDS.md`'s Bash section says so.
- [ ] `AGENTS.md` Verifying lists the command, and a dated line in `docs/M0-findings.md` records the version verified.

## Run under

Until #89, #90, #91 and #93 merge, the lane that runs this ticket follows their rules by hand; following them is part of the ticket. The worked example of every artifact named here is ticket #42 (its `## Testing decisions` section) and PR #92 (its description and its three review comments); read both first. The rules: (1) `how` and `blast-radius` as the Ticket playbook says. (2) When the change has state (a file it reads or writes, exit codes, rounds, or more than one actor) the architect step writes a scenario table before any code: situations down the side, the shape of the input across the top, and in every cell what is printed, the exit code and what the caller does; a cell for an input outside the intended path reads "refused with the tool's own message" and costs no code, and such a cell is cut only after the refusal was run and seen. When the change is code with no state that crosses a function boundary, the architect step posts the usage and signature sketch (the caller's usage first, then types and signatures) on the ticket under `## Design` instead; a prose change has no artifact beyond its acceptance criteria. The table is appended to this ticket's body under `## Testing decisions`, first line "Posted by the agent <date>"; the human edits it if it is wrong, and a stop before implementation is asked for only with the phrase "/architect with checkpoint". (3) The test is written from the table before the implementation, one assertion per cell, and the commit order shows it. (4) A writer that cannot implement a cell as written stops and reports the cell; it never fills it. (5) In review, a finding is a design hole when its fix changes the artifact the work was built against rather than the code that implements it: a table cell or a term its cells use, a signature or a usage in the sketch, or an acceptance criterion (the ticket's intent, its What to build or Decision quotes, outranks any one criterion, so a criterion that must change goes back to architect, which re-derives it from the intent and amends the ticket with a dated line); a design hole is not fixed on the PR but returns to architect, scoped to that cell, and the review count restarts (on this PR with a comment that says "restart" and why); a refusal added under an existing could-not-run clause is not a hole. (6) The Spec reviewer's walk has one line per risk in the blast-radius grounding. (7) A round that fixed a Would-break item is followed by another round even past three, reviewing only the fix (the previous reviewed commit as the fixed point), up to five; at five with Would-break items still found, stop, write a report for the human, mark the PR unfinished and wait. (8) `shellcheck` on every changed shell file before the PR opens. This ticket has no state of its own, so rule 2 yields no table; rules 6 to 8 still apply to its review.

## Blocked by

- #42 (PR #92 carries the script this ticket's disable rule is modeled on)



## Design

Posted by the agent 2026-09-22. The change has one script, `template/.github/shellcheck.sh`, that both CIs and a lane call; its usage and signature are the design artifact. The rest of the ticket is CI text, a doctor line and prose, which have no artifact beyond the acceptance criteria.

Usage, the caller's view:

```
bash .github/shellcheck.sh                        this project's shell files: .claude/hooks/*.sh, .agents/skills/*/scripts/*.sh, .github/shellcheck.sh
bash .github/shellcheck.sh '<glob>' ...           exactly these; quote a glob, the script expands it
bash .github/shellcheck.sh .claude/hooks/mode.sh  a lane before the PR opens, on every shell file the diff changes
```

In the factory, `.github/shellcheck.sh` is a link to `template/.github/shellcheck.sh` (the nesting rule, P7), and CI runs `bash .github/shellcheck.sh factory918.sh template/.github/shellcheck.sh 'template/.claude/hooks/*.sh' 'template/.agents/skills/*/scripts/*.sh' 'tests/*/*.sh'`. The fixture job runs the zero-argument form inside `/tmp/fx`, which is the template CI's step character for character.

Signature: `shellcheck.sh [glob...]`. Runs ShellCheck 0.11.0 with `--external-sources` at the default severity and no `--shell` over the files the globs match. Uses the `shellcheck` on PATH when its version is the pin; otherwise downloads the pinned release for Linux x86_64 or macOS arm64 into `${TMPDIR:-/tmp}/shellcheck-0.11.0` once, checks its sha256, and runs that. Writes nothing inside the repository.

| Situation | Prints | Exit | The caller |
|---|---|---|---|
| Every file clean | `ShellCheck 0.11.0, files checked: N` | 0 | proceeds |
| A finding | the count line, then ShellCheck's own report | 1 | fixes it, or adds `# shellcheck disable=SCnnnn # <reason>` on the line above |
| A glob matches no file | `shellcheck.sh: no file matched <globs>; the gate checked nothing` on stderr | 1 | fixes the glob; a gate that checked nothing is not a pass |
| Local ShellCheck absent or off-pin, platform pinned | downloads once, then one of the rows above | as that row | nothing; the doctor's NOTE says how to install one |
| Local ShellCheck absent, platform not pinned | `shellcheck.sh: ShellCheck 0.11.0 is not pinned for <os>.<arch>; install it by hand` on stderr | 1 | installs it; `factory918 doctor` names the command |
| Checksum mismatch | refused with `sha256sum`'s own message | 1 | reports it; the pin or the download is wrong |

`tests/shellcheck/gate.sh` asserts the first three rows, the platform row (a fake `uname` on PATH with ShellCheck hidden) and that a `#!/bin/sh` file keeps its POSIX checks. The download row is proven by the fixture job on `ubuntu-latest`, whose image carries an off-pin ShellCheck; the checksum row is the tool's own refusal and is not simulated.

