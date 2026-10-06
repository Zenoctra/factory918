### What it does

Adds `template/.github/shellcheck.sh`, a gate that runs ShellCheck 0.11.0 with `--external-sources` over named globs and downloads the pinned build when PATH has no copy at the pin. The factory reaches it through the symlink `.github/shellcheck.sh`; CI runs it over 20 files in place of `bash -n` (`.github/workflows/factory-ci.yml:18-21`), the template CI runs the zero-argument form first (`template/.github/workflows/ci.yml:17-18`), the fixture job runs it inside the applied project (`factory-ci.yml:56`). Five findings are fixed; the rest get same-line-reasoned directives, three in `template/.claude/hooks/delegation.sh`. The doctor gains a PASS-or-NOTE line (`factory918.sh:274-276`). The playbook, both `AGENTS.md`, both `CODING_STANDARDS.md`, M0 and P25 carry the prose. Not spelled out by the diff: the gate `exec`s whatever executable sits under `${TMPDIR:-/tmp}/shellcheck-0.11.0`.

### The one fact it's safe because of

Nothing a session runs changed behaviour. The hook gained only comment lines and the CLI's three edits are equivalent rewrites. Rung 4.

```
$ diff old.sh new.sh      # delegation.sh at ab47eb9 and 69bd412, comment lines stripped
identical: 191 non-comment lines
$ bash tests/hooks/delegation.sh
ok 55 assertions
$ ./factory918.sh sync | tail -1; git status --porcelain
vendored: 72 skills. Review with git status, bump VERSION, commit.
$ old count: 72    new count: 72
$ factory918 doctor <scratch project>          # then with HOME and PATH stripped
PASS  models sheet          NOTE  models sheet   (same text as ab47eb9)
PASS  shellcheck 0.11.0     NOTE  shellcheck
```

`${skills:?}` cannot fire: `factory918.sh:381` sets it from `TEMPLATE`, which line 9 sets to `"$F918_DIR/template"`. The gate over the factory set printed `files checked: 20`, exit 0. `gate.sh` ok 10, review-brief ok 334, review-comment ok 82, overlap ok 56; the knowledge build and check are clean.

### Risks

1. A cached binary is trusted forever. `template/.github/shellcheck.sh:26` skips the checksum when `$dir/shellcheck-v0.11.0/shellcheck` is executable, so anything that can write `/tmp` plants what line 45 `exec`s. I planted a shell script there and ran with PATH stripped. Output: `PLANTED BINARY RAN with: --external-sources factory918.sh`, exit 0. Unlikely on a runner, real on a shared dev box, bad when it lands. The fix is a checksum of the binary before `exec`.

2. A sandboxed lane with no network and no pin cannot run the gate the playbook now orders (`opening-a-pr.md:9`). Line 28 `curl` fails loud, here `curl: (22) ... 403`, exit 22, nothing cached. The doctor NOTE at `factory918.sh:276` says the missing tool "blocks nothing", which is false in that sandbox. Likely for writer lanes; the cost is a lane that cannot verify and must say so.

3. `gate.sh` test 6 assumes no ShellCheck 0.11.0 under `/usr/bin` (`tests/shellcheck/gate.sh:75` hardcodes `PATH="$fx/bin:/usr/bin:/bin"`). With the fake `uname` first and a real 0.11.0 behind it the gate printed `files checked: 1`, exit 0; the `uname` case at line 19 is never reached. An `apt` or runner image shipping 0.11.0 fails the test, not the gate.

4. An existing project with an edited `ci.yml` gets the gate script (`factory918.sh:334-338`) but maybe not the CI step. With the real `git merge-file` call from line 357, an edit far from the checkout line merged clean; an edit right after `actions/checkout@v4` conflicted and lands as `ci.yml.factory-merge` (line 362), which no doctor line notices. Medium likelihood, low cost.

5. Any `uname` pair other than `Linux.x86_64` and `Darwin.arm64` exits 1 at line 22 (test 6 proves it); an ARM or Intel macOS runner fails CI with a clear message.

### Cleared

- Hook on every PreToolUse: no non-comment change, no hook calls `shellcheck`. `delegation.sh:7` is `set -fuo pipefail`, so the `set -f` reasons at lines 165, 186, 209 hold.
- Review in progress: `review-brief.sh:189` matches `template/.claude/hooks/delegation.sh`, so this PR is refused without a Blast Radius section (line 204). The hook's read of `.claude/state/review` (line 27) is unchanged.
- `factory-start` and `factory-doctor`: the new line sits above `slots filled` and is only PASS or NOTE, which `factory-start/SKILL.md:14` accepts; `factory-doctor/SKILL.md:6` reprints the table. `apply` and `update` end in `cmd_doctor || true` (`factory918.sh:168, 373`).
- `cmd_apply` copies with `cp -p` (line 137); the copy kept mode 755.
- Symlink: mode `120000`, outside `template/`, and `sync` left `git status` empty with it intact.
- `bash -n` removal: a file missing its `fi` gets `bash -n` exit 2, ShellCheck SC1072 exit 1, the gate exit 1.
- A project that deleted its hooks: the zero-argument form checked 1 file (the gate itself) and passed.
- `source-path=SCRIPTDIR` (`tests/spec-review/review-brief.sh:21`, `review-comment.sh:11`): `shellcheck -x` by absolute path from another directory is clean; the ab47eb9 copies give 2 SC1091 and 4 SC2154.
- `sha256sum` versus `shasum`, `tar -xJf`: both tools and a bsdtar with liblzma are on this Mac. The `ubuntu-latest` side was unreachable (network denied), so the download path stays at rung 2, as `docs/M0-findings.md:172` admits.
- `show-me-your-work/scripts/log.sh`, newly linted: `shellcheck -x` exit 0, untouched.
- `wizard/template.sh` is not under `scripts/`, so no gate lints it; `wizard/SKILL.md:41` still says `bash -n`. Out of scope.
- Spec-review's scripts: the file-level directive at `review-brief.sh:17` hides any future real SC2016 there; both suites pass.
- Knowledge: `template/docs/factory918/DECISIONS.md:85` regenerates from P25; build and check clean. Profiles add no `.sh`.

### Before you merge

```
d=${TMPDIR:-/tmp}/shellcheck-0.11.0/shellcheck-v0.11.0; mkdir -p "$d"
printf '#!/bin/sh\necho PLANTED\n' > "$d/shellcheck"; chmod +x "$d/shellcheck"
PATH=/usr/bin:/bin bash .github/shellcheck.sh factory918.sh   # prints PLANTED: the cache is trusted
rm -rf "${TMPDIR:-/tmp}/shellcheck-0.11.0"
PATH=/usr/bin:/bin bash .github/shellcheck.sh factory918.sh   # the download path, on a networked machine
bash tests/shellcheck/gate.sh && bash tests/hooks/delegation.sh
```

Watch the fixture job's "The shell gate a project runs" step on the first CI run; only there are the download, the checksum and `tar -xJf` exercised.
