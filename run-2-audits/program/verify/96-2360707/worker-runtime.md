verdict: PASS+NOTES

Slice: live runtime floor, PR #96 (ticket #88) at `2360707f9bf56e4216f81ec652f20d4682ba24c4`.
Every claim below was run, not read. Setup: `git fetch origin feat/shellcheck main`, `git checkout --detach 2360707...`;
`git rev-parse HEAD` printed `2360707f9bf56e4216f81ec652f20d4682ba24c4`. Private `TMPDIR=/tmp/v96-tmpdir`
throughout; the worktree ends with `git status --porcelain` empty. Machine: Darwin arm64, `shellcheck`
0.11.0 at `/opt/homebrew/bin/shellcheck`, `vp v0.3.1`.

## (a) The gate with the factory CI's arguments

- `TMPDIR=/tmp/v96-tmpdir bash .github/shellcheck.sh factory918.sh template/.github/shellcheck.sh 'template/.claude/hooks/*.sh' 'template/.agents/skills/*/scripts/*.sh' 'tests/*/*.sh'`
  -> `ShellCheck 0.11.0, files checked: 20`, exit **0**. Matches `AGENTS.md:38` ("ShellCheck at the pin over 20 files") and `.github/workflows/factory-ci.yml:19` character for character.
- `TMPDIR=/tmp/v96-tmpdir bash tests/shellcheck/gate.sh` -> `ok 17 assertions`, exit **0** (the new CI step at `factory-ci.yml:21`).
- `.github/shellcheck.sh` is a git symlink (mode `120000`, `git ls-files -s` -> `2e84727`) to `../template/.github/shellcheck.sh`, so the one file is what ran.

## (b) The download path, the cache, and a bad cached tarball

`shellcheck` hidden behind a shim first on PATH that prints `version: 0.9.0`, so the pinned-download branch runs.

- **Cold cache, downloads:** cache dir emptied, gate run -> `ShellCheck 0.11.0, files checked: 1`, exit **0**.
  Checksum of what it fetched: `shasum -a 256 /tmp/v96-tmpdir/shellcheck-0.11.0/sc.tar.xz` ->
  `56affdd8de5527894dca6dc3d7e0a99a873b0f004d7aabc30ae407d3f48b0a79`, identical to `sha_darwin_aarch64` at `template/.github/shellcheck.sh:19`.
  Extracted binary: `/tmp/v96-tmpdir/shellcheck-0.11.0/shellcheck-v0.11.0/shellcheck --version` -> `version: 0.11.0`.
- **Cache reuse:** second run -> `files checked: 1`, exit **0**; tarball mtime unchanged (`1790094395` before and after), so nothing was re-fetched. The sha is recomputed on that run (the `verify` line has no cache-hit branch), which the corruption cases below prove.
- **Truncated cached tarball** (`printf 'truncated' > sc.tar.xz`, 9 bytes): run -> stderr `sha256sum: WARNING: 1 computed checksum did NOT match`, exit **1**. `ls` afterwards shows `sc.tar.xz` **gone**. Next run -> re-downloaded (new mtime `1790094426`), checksum back to the pin, `files checked: 1`, exit **0**. Commit 2360707's claim holds.
- **Valid tarball, wrong checksum, not truncated:** built a real `.tar.xz` containing a fake `shellcheck-v0.11.0/shellcheck` that echoes `EVIL-BINARY-RAN` (sha `d3b91c1c...`), planted it as the cache, removed the extracted directory first. Run -> `sha256sum: WARNING: 1 computed checksum did NOT match`, exit **1**; afterwards the cache directory is **empty** -- the bad tarball was removed and **nothing was extracted**, so the fake binary never ran. The checksum, not `tar`, is the guard.

## (c) Refusals and a real finding

- **Glob matching nothing, beside one that matches:** `bash .github/shellcheck.sh 'tests/*/*.sh' 'no-such-dir/*.sh'` -> stderr `shellcheck.sh: no file matched no-such-dir/*.sh; the gate checked nothing`, exit **1**. Round 1's fails-open is closed: the matching glob does not rescue the run.
- **No word-splitting on spaces (round 2's Would-break):** `bash .github/shellcheck.sh 'does not exist.sh'` -> `no file matched does not exist.sh`, exit **1** -- one name, not three.
- **A spaced directory is really checked:** created `/tmp/v96 space dir/bad one.sh` with `echo $x`; `bash .github/shellcheck.sh '/tmp/v96 space dir/*.sh'` -> `files checked: 1`, then `In /tmp/v96 space dir/bad one.sh line 3: echo $x  ^-- SC2086 (info)`, exit **1**. Both halves in one run: the space survives, and a real SC2086 fails the gate at the default severity.
- **`#!/bin/sh` keeps its POSIX checks** (no `--shell`): a `sh` file with `foo=(a b)` -> `SC3030 (warning)` and `SC3054 (warning)`, exit **1**.
- **Explicit changed-file arguments** (the form the playbook asks a lane for): `bash .github/shellcheck.sh factory918.sh tests/shellcheck/gate.sh template/.claude/hooks/delegation.sh` -> `files checked: 3`, exit **0**.

## (d) `factory918.sh doctor`, both ways

Run against the fixture project of (e), since `doctor` needs `.factory918/manifest.json`.

- **Tool on PATH:** `./factory918.sh doctor /tmp/fx-verify-96` -> `PASS  shellcheck 0.11.0`. Exit **1**, from two fixture-only FAILs (`labels present` -- no GitHub remote; `slots filled (/factory-start)`). The same `PASS  shellcheck 0.11.0` line also appeared at the end of `./factory918.sh apply`.
- **Tool genuinely absent from PATH** (a symlink farm over every PATH directory with `shellcheck` left out; `command -v shellcheck` -> NONE):
  `NOTE  shellcheck` / `fix: brew install shellcheck (apt install shellcheck, dnf install ShellCheck, winget install koalaman.shellcheck); .github/shellcheck.sh downloads the pinned build without it, so this is a NOTE`. Exit **1**.
- **Exit code unaffected by the NOTE, isolated:** the farm run also lost two unrelated checks to the narrowed PATH, so I re-ran with the PATH otherwise untouched and only `shellcheck --version` answering nothing (exactly what the doctor sees when the tool is missing). Result: the identical FAIL set to the baseline (`labels present`, `slots filled`), the `NOTE  shellcheck` line, `DOCTOR_EXIT=1` -- the same exit code as the on-PATH run. The NOTE adds no failure.

## (e) A project

- `vp create vite:monorepo --directory fx-verify-96 --no-interactive --git --hooks --no-agent` -> exit 0; initial commit `b9ee1bc`.
- `./factory918.sh apply /tmp/fx-verify-96 --scaffold --profile python --name demo` -> exit 0.
- **The project's CI step** (`bash .github/shellcheck.sh`, no arguments, from the project root) -> `ShellCheck 0.11.0, files checked: 11`, exit **0**.
- `/tmp/fx-verify-96/.github/shellcheck.sh` is byte-identical to `template/.github/shellcheck.sh` (`diff` clean), and `cp -p` kept it runnable.
- `/tmp/fx-verify-96/.github/workflows/ci.yml:17-18` carries the step: `- name: ShellCheck` / `run: bash .github/shellcheck.sh`, first in `check`, right after `actions/checkout@v4`.
- **Planted finding fails the project gate:** appended `unquoted=$1` / `echo $unquoted` to `/tmp/fx-verify-96/.claude/hooks/mode.sh` (fixture only) -> `files checked: 11`, `In .claude/hooks/mode.sh line 38: echo $unquoted ^-------^ SC2086 (info)`, exit **1**. Restored the hook; gate back to exit **0**.
- `/tmp/fx-verify-96` removed.

## (f) The playbook sentence at the SHA

`template/.agents/skills/poteto-mode/playbooks/opening-a-pr.md:9`, inside the `**PRs.**` paragraph:

> Run `bash .github/shellcheck.sh` on every shell file the diff changes before the PR opens; it is the gate CI runs, so the finding lands in this lane instead of a review round.

**An agent can follow it.** The command exists in a project at that exact path, takes explicit paths as arguments, and I ran that form (`files checked: 3`, exit 0). It names when (before the PR opens), what (every shell file the diff changes) and why (the finding lands in the lane). The one thing it leaves implicit is that the changed files go on the command line -- the sentence shows the zero-argument form while asking for a per-file run; the script's own usage header covers it, but a lane that types the line verbatim gets the default set instead. See Notes 1.

## Issues

(none that block)

## Notes

1. The playbook line shows `bash .github/shellcheck.sh` while asking for "every shell file the diff changes". Typed verbatim it runs the zero-argument default set, which is three globs, not the diff. Evidence: I put a finding in `/tmp/fx-verify-96/scripts/release.sh` (a location outside the default globs at `template/.github/shellcheck.sh:37`); the bare run reported `files checked: 11`, exit **0** -- the finding was invisible. Naming it explicitly caught it: `bash .github/shellcheck.sh 'scripts/*.sh'` -> `SC2086`, exit **1**. The default set is exactly what ticket #88's second acceptance criterion asks for, so this is scope, not a miss; the cost is that a project's shell files outside `.claude/hooks/` and `.agents/skills/*/scripts/` are never gated by the project's own CI step, which is also bare.
2. **Two gate runs sharing one `TMPDIR` fail each other, on the download path.** A consequence of 2360707: the script now extracts the 61 MB binary on **every** run, not only after a download. Cold cache, three concurrent runs, shared `TMPDIR`: run 3 exit **0**, runs 1 and 2 `Killed: 9`, exit **137** (macOS kills a process whose executing binary is rewritten under it). Warm cache, same three: run 1 exit **0**, runs 2 and 3 exit **1** with `shellcheck-v0.11.0/shellcheck: Can't create ...: File exists` / `tar: Error exit delayed from previous errors`. It needs an off-pin machine (a machine with the pin never enters this branch) plus two lanes at once; CI is safe, each job having its own runner. The failure is loud, not silent -- a spurious red carrying a `tar` message rather than a lint finding -- so it costs a confused lane, not a missed finding. Worth a ticket (extract into a per-process directory and rename into place, or skip the extract when the cached binary already answers `version: 0.11.0`), not a block. It is also why this slice used a private `TMPDIR`.
3. The checksum failure speaks only in `sha256sum`'s voice: `sha256sum: WARNING: 1 computed checksum did NOT match`, with no `shellcheck.sh:` prefix, no path, and no word that the tarball was deleted and the next run will re-fetch. Compare the unmatched-glob refusal, which names itself and what it refused. A lane reading CI output sees a checksum warning with nothing tying it to the gate.
4. The doctor reports whatever version it finds under `PASS`: with a shim answering `version: 0.9.0` on PATH, the line was `PASS  shellcheck 0.9.0`. The version is printed, so a reader can see it is off the pin, and the gate downloads the pin regardless -- but the line reads as a pass for a tool that is not the pinned one. Ticket #88's fourth criterion asks only for the line and the NOTE, so this is within scope.
5. The PR body's **Risks** section is stale against this SHA on two of five items, and contradicts the body's own **Scope** section. Risk 1 ("a cached binary is reused with no checksum", citing `[ ! -x "$bin" ]`) is closed -- that guard is gone and the sha is verified every run, as the (b) evidence shows; a later PR comment says so, but the body was not updated. Risk 3 ("an unmatched glob among matched ones is dropped without a word ... `files checked: 5`, exit 0") is contradicted by the live run in (c): the gate refuses and exits 1. A reviewer reading the body as the map of the change is told the opposite of what runs.
6. `sha256sum` (coreutils) exists on this machine, so the `verify` function took its first branch; the `shasum -a 256` fallback was exercised only by my own out-of-band checksums, never by the gate. On a stock macOS machine without coreutils the fallback is the branch that runs. Not covered live here.
