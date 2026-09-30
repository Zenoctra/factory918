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
