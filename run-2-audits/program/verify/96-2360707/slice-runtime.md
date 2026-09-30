# Slice: live runtime floor

Exercise the gate and the doctor live, not by reading. With a private `TMPDIR` (`export TMPDIR=$(mktemp -d)`):
(a) `bash .github/shellcheck.sh` from the factory root with the arguments the factory CI passes: record
    the `ShellCheck 0.11.0, files checked: N` line and exit 0.
(b) The download path: with `shellcheck` hidden from PATH (a PATH without its directory, or a shim directory
    earlier on PATH holding a `shellcheck` that prints another version), run the gate; it must download the
    pinned release, verify the sha256, and pass. Record the checksum line and the extracted binary's version.
    Then the cache: run again and show it reuses the cache and still verifies. Then corrupt the cached
    tarball (truncate it) and run again: the PR's last commit 2360707 claims a tarball that fails its checksum
    is removed and the run recovers; show what happens, exit code and message, and whether the next run
    recovers. Then a cached tarball with a wrong checksum that is not truncated.
(c) Refusals: an argument that names no file (a glob that matches nothing) must be refused with a message
    naming it, not skipped silently (round 1's fails-open); an argument containing a space must not be
    word-split (round 2's Would-break): create a directory with a space and a shell file with a finding
    inside, pass the glob quoted, show the finding is reported. A file with a real SC2086 must fail the gate
    (exit 1) at default severity; show it.
(d) `factory918.sh doctor`'s shellcheck line both ways: with the tool on PATH (`PASS  shellcheck 0.11.0`) and
    hidden (`NOTE  shellcheck` with a fix line naming an installer), and that the doctor's exit code is not
    changed by the NOTE.
(e) A project: `cd /tmp && vp create vite:monorepo --directory fx-verify-96 --no-interactive --git --hooks --no-agent`,
    then from your worktree `./factory918.sh apply /tmp/fx-verify-96 --scaffold --profile python --name demo`;
    inside the project run `bash .github/shellcheck.sh` with no arguments (the project's CI step) and record
    `files checked: N`; check the project's `.github/workflows/ci.yml` has the ShellCheck step; introduce a
    finding into one of the project's hooks (in the fixture only) and show the gate fails. Remove
    `/tmp/fx-verify-96` when done.
(f) `template/.agents/skills/poteto-mode/playbooks/opening-a-pr.md` at the SHA: quote the sentence that
    names `shellcheck` before the PR opens and say whether an agent can follow it.
Report file: `/Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.scratch/program/verify/96-2360707/worker-runtime.md`.
