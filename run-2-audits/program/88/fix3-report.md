# Fix 3 for PR #96 (ticket #88): the checksum tool's OK line on stderr

The checksum tool's stdout now goes to /dev/null in both branches of `template/.github/shellcheck.sh`, and gate.sh case 9 expects the tools' `did NOT match` WARNING on stderr instead of the `FAILED` line, which is on stdout. One commit on `wt/88-fix3`, worktree clean, nothing pushed.

- Worktree: `/Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.claude/worktrees/agent-a8412d7baeb0403e5`
- Base: `a64c7e6c000d63c1a21352cbea18b768b6de7fd5` (fetched from `origin/feat/shellcheck`; the worktree started on `ab47eb9`)
- Commit: `1362b48fa2d50ab1d5989f4126d4ba729ff227ea` on `wt/88-fix3`
- Header comment of shellcheck.sh left as is: "verifies its sha256 on every run" is still true.

```
$ git diff --stat a64c7e6..HEAD
 template/.github/shellcheck.sh | 4 ++--
 tests/shellcheck/gate.sh       | 2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)
```

## What the tools do (checked on this machine)

Both `sha256sum -c -` and `shasum -a 256 -c -` print `<file>: OK` or `<file>: FAILED` on stdout, and on a mismatch add `<tool>: WARNING: 1 computed checksum did NOT match` on stderr and exit 1. So sending stdout to /dev/null keeps every OK line off the gate's streams while a mismatch still surfaces the tool's own message and stops the gate under `set -e`.

## Reproduction of the CI failure (pre-fix script from a64c7e6, download path, valid cache)

```
$ PATH=/usr/bin:/bin TMPDIR=".../scratchpad/fix3 tmp" bash old-gate.sh 'nope/*.sh'
exit 1
stdout: []
stderr: [/private/tmp/claude-501/-Users-manuel-Desktop-Work-Under-The-Sun-Collective-Core-918-factory918/b4a8ae9c-88b9-4178-b518-8ac2ff6f1af5/scratchpad/fix3 tmp/shellcheck-0.11.0/sc.tar.xz: OK
shellcheck.sh: no file matched nope/*.sh; the gate checked nothing]
stderr lines: 2
```

## Proof 1: the gate test

```
$ bash tests/shellcheck/gate.sh
ok 17 assertions
exit 0
```

## Proof 2: the download path with a valid cache (the scenario CI hits)

`TMPDIR` is `/private/tmp/claude-501/-Users-manuel-Desktop-Work-Under-The-Sun-Collective-Core-918-factory918/b4a8ae9c-88b9-4178-b518-8ac2ff6f1af5/scratchpad/fix3 tmp` (with the space), holding `shellcheck-0.11.0/sc.tar.xz` copied from the scratchpad's `sc-mac.tar.xz` (sha256 `56affdd8...0a79`, the darwin aarch64 pin). Nothing fetched from the network. Run from the worktree root through `.github/shellcheck.sh`, which is the symlink to `template/.github/shellcheck.sh`.

```
$ PATH=/usr/bin:/bin TMPDIR="<fix3 tmp>" bash .github/shellcheck.sh 'nope/*.sh'
exit 1
stdout: []
stderr: [shellcheck.sh: no file matched nope/*.sh; the gate checked nothing]
stderr lines: 1

$ PATH=/usr/bin:/bin TMPDIR="<fix3 tmp>" bash .github/shellcheck.sh factory918.sh
exit 0
stdout: [ShellCheck 0.11.0, files checked: 1]
stderr: []
stderr lines: 0
extracted binary: -rwxr-xr-x@ 1 manuel  wheel  61551911 Aug  3  2025 <fix3 tmp>/shellcheck-0.11.0/shellcheck-v0.11.0/shellcheck
```

## Proof 3: a bogus cached tarball

`TMPDIR` is the sibling `.../scratchpad/fix3 bogus`, holding `shellcheck-0.11.0/sc.tar.xz` with the content `not a tarball`.

```
$ PATH=/usr/bin:/bin TMPDIR="<fix3 bogus>" bash .github/shellcheck.sh factory918.sh
exit 1
stdout: []
stderr: [shasum: WARNING: 1 computed checksum did NOT match]
stderr lines: 1
tarball after the run: [not a tarball]
```

(With `PATH=/usr/bin:/bin` this machine's `sha256sum` at `/sbin` is hidden, so the `shasum` branch ran. gate.sh's own case 9 runs under the same PATH. On the Linux runner the `sha256sum` branch runs and prints the same WARNING text with its own name in front.)

## The factory set and the delegation hook

```
$ bash .github/shellcheck.sh factory918.sh template/.github/shellcheck.sh 'template/.claude/hooks/*.sh' 'template/.agents/skills/*/scripts/*.sh' 'tests/*/*.sh'
ShellCheck 0.11.0, files checked: 20
exit 0

$ bash tests/hooks/delegation.sh
ok 55 assertions
exit 0
```

## The commit

```
Keep the checksum tool's OK line off the gate's stderr

The last commit sent the checksum tool's output to stderr so the gate's
stdout stayed its one count line. On a machine whose ShellCheck is
off-pin, which the CI runner's is, the gate takes the download path on
every run, and the tool's "sc.tar.xz: OK" line then landed on stderr
ahead of every refusal. gate.sh compares the refusal for a glob that
matches nothing against stderr exactly, so CI failed on case 3. This
machine has the pin on PATH, so the download path never ran here and
the case passed.

The tool's stdout now goes to /dev/null and its stderr is left alone.
On a mismatch both sha256sum and shasum print "WARNING: 1 computed
checksum did NOT match" on stderr and exit 1, which stops the gate
under set -e, so a bad tarball is still refused with the tool's own
message. Case 9 expects that WARNING instead of the FAILED line, which
the tools print on stdout.

Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>
```
