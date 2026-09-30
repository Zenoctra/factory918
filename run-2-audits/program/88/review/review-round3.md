Round three, the last, found no hard item on either axis: the two fixes from round two hold (the Spec walk records risks 1 and 3 of the blast radius as closed by their commits), and the four remaining notes are the blast-radius grounding now being stale on those two risks, which gets a dated addendum in the PR body, the file-level SC2016 directive raised again and left as the standard's own file-scope case, the doctor reporting whatever ShellCheck the machine has, which is the NOTE the ticket asked for, and one misread commit title. Nothing changed in the design posted on the ticket in any round, and one records-only commit follows this comment.

## Standards

## Would break

## Fails open

## Standards breaches

1. **The blast-radius grounding no longer describes the code it grounds.** `CODING_STANDARDS.md`, Markdown: "A count or a version in prose is true at the commit that lands it." Risk 1 of the PR body cites a cache test at `template/.github/shellcheck.sh:26` that skips the sha; commits `a64c7e6` and `1362b48` replaced it, and the shipped gate verifies the tarball on every run. The Cleared line "with the hooks deleted, 6" is falsified by `01e5386`: an unmatched glob is now refused, so that case exits 1, not 6. Both are the evidence the next round's reviewers are handed.

```sh
  [ -f "$tarball" ] || curl -fsSL -o "$tarball" "https://github.com/koalaman/shellcheck/releases/download/v$version/shellcheck-v$version.$plat.tar.xz"
  if command -v sha256sum >/dev/null; then echo "$sha  $tarball" | sha256sum -c - >/dev/null
```

## Fix alongside

2. **Speculative Generality: a file-wide SC2016 on a 362-line production script.** The new rule asks for "the narrowest scope that covers the intent, above the one statement or at the top of a file whose whole job produces the pattern". `review-brief.sh` emits Markdown and jq, but not only; the sibling `review-comment.sh` got statement-scoped directives instead. A future genuine `'...$var...'` in a non-template string goes unreported.

```sh
# shellcheck disable=SC2016 # every single-quoted string here is a jq program or a Markdown template; the backticks and $ are literal
set -euo pipefail
```

3. **The doctor passes any ShellCheck, not the pin.** `factory918.sh` prints `PASS  shellcheck 0.9.0` for a version the gate then ignores and re-downloads. Harmless, since the gate carries the pin, but the line reads as "this machine matches" when it does not. Compare the pinned string the gate itself greps, `version: $version`.

```sh
  if [ -n "$scv" ]; then echo "PASS  shellcheck $scv"
```

4. **A commit title names the wrong stream.** `1362b48`, "Keep the checksum tool's OK line off the gate's stderr": `>/dev/null` at `template/.github/shellcheck.sh:31-32` redirects stdout, which is where `-: OK` lands and the stream `tests/shellcheck/gate.sh` compares exactly. The failure warning stays on stderr, which is why test 9 still sees `did NOT match`.

```sh
  if command -v sha256sum >/dev/null; then echo "$sha  $tarball" | sha256sum -c - >/dev/null
  else echo "$sha  $tarball" | shasum -a 256 -c - >/dev/null; fi
```

hard findings: 0

## Spec

## Walk

1. Criterion 1: `factory-ci.yml:19` runs the gate over `factory918.sh`, the gate itself, `'template/.claude/hooks/*.sh'`, `'template/.agents/skills/*/scripts/*.sh'`, `'tests/*/*.sh'` — a superset of the `bash -n` set it replaces, single-quoted so the script expands them.
2. The pin: `shellcheck.sh:19-20` takes PATH's ShellCheck only when `--version` is exactly `version: 0.11.0`, else downloads the pinned release and refuses an unpinned platform (`:21-25`). Never the image's own.
3. `factory-ci.yml:21` runs `tests/shellcheck/gate.sh`, one assertion per row of the ticket's `## Design` table plus the argument and mode-bit rows.
4. Criterion 2: `template/.github/workflows/ci.yml:17-18` runs the zero-argument form, whose defaults (`:36`) are the two globs the criterion names plus the gate. `cmd_apply` copies it with `cp -p` (`factory918.sh:137`); `factory-ci.yml:54-56` runs it inside `/tmp/fx`.
5. Criterion 3: the `**PRs.**` paragraph, in the patch (`opening-a-pr.md.patch:8`) and the vendored copy, tells the lane to run the gate on every shell file the diff changes, before the PR.
6. Criterion 4: `factory918.sh:274-276` prints `PASS  shellcheck <v>` or a `note` naming brew, apt, dnf and winget. NOTE, not FAIL, and above `slots filled`.
7. Criterion 5: `CODING_STANDARDS.md:15` requires the reason as a second comment on the same line; `overlap.sh:49` is the model and now carries one, as do the eight new directives.
8. Criterion 6: `AGENTS.md:38` lists the command verbatim; `M0-findings.md:170-172` dates it 2026-09-22 with both checksums.
9. Other documentation the diff changes — P25 and its generated twins, `template/AGENTS.md:63`, `template/CODING_STANDARDS.md:37`, `SOURCES.md:15`, `ledger.md:25` — each states what the code does.
10. Risk 1, a cached binary reused unchecked: closed here. `shellcheck.sh:30-33` verifies the sha every run, not only on download, and `tar -xJf` re-extracts over the cached binary. The `[ ! -x "$bin" ]` guard the risk cites is gone.
11. Risk 2, `gate.sh:75` assuming no 0.11.0 in `/usr/bin`: still live. Cost is a red factory CI with an exact `FAIL 6` line; nothing silent, no product path touched.
12. Risk 3, an unmatched glob dropped beside matched ones: closed. `shellcheck.sh:39-46` tracks `matched` per argument and exits 1 on the first miss; `gate.sh:70-71` asserts it.
13. Risk 4, an offline lane: refused loudly — curl's message under `-fsS`, or the platform line at `:24` telling the lane to install by hand.
14. Risk 5, a conflicting project `ci.yml`: `cmd_update` writes `ci.yml.factory-merge` and prints `conflicts .github/workflows/ci.yml`, so the missing step is reported. No criterion asks the doctor to check it.

## Would break

## Fails open

## Not asked for

hard findings: 0

## Judgment

## Act on

## Ask

## Consider

## Noted

1. [S1] **The blast-radius grounding no longer describes the code it grounds.** Valid: risk 1 and risk 3 were closed by `a64c7e6` with `1362b48` and by `01e5386`, and the "with the hooks deleted, 6" line is false since `01e5386`. The grounding is the author's dated claim before the review, and the brief says so to every reviewer; the PR body's section gets a dated addendum naming the closing commits under those two risks and that Cleared line, so a later reader is not handed the stale evidence. No code changes.
2. [S2] **A file-wide SC2016 on `review-brief.sh`.** Valid and raised twice; the file's sixteen occurrences are all jq programs and Markdown templates, and the standard's own words ("at the top of a file whose whole job produces the pattern") cover it, while its sibling's single occurrence takes the statement scope. Left as is.
3. [S3] **The doctor passes any ShellCheck, not the pin.** Valid; the line reports what is on the machine, and the gate, not the doctor, holds the pin and downloads it when the machine's copy differs, which is why the ticket asked for a NOTE and not a FAIL. Left as is.

## Dismissed

4. [S4] **A commit title names the wrong stream.** The title is about the effect, not the redirect: before `1362b48` the tool's `OK` line reached the gate's stderr through the `>&2` that `a64c7e6` added, and the commit takes it off stderr by discarding the tool's stdout, which its body says in those words.

Standards: 0 would break, 0 fail open, of 4; Spec: 0 would break, 0 fail open, of 0; judged: act on 0 (0 fixed, 0 with a ticket), ask 0, consider 0, noted 3, dismissed 1; fixed point ab47eb9.
round: 3 of 3
act-on items: 0

Claude Fable 5.1 on Claude Code
