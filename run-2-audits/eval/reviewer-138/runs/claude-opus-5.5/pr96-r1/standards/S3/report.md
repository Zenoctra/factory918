## Would break

## Fails open

## Standards breaches

1. **Two directive reasons misdescribe the text they suppress.** `CODING_STANDARDS.md`, Bash: "A `# shellcheck disable=` directive carries its reason as a second comment on the same line". P25 also says that "CI cannot check that a reason exists, the Standards axis does". A reason that names the wrong thing does not meet that rule. In `review-comment.sh` the directive covers `fenced=`, an awk program that matches Markdown fence runs and emits nothing (it is spliced into `awk` at `:48` and `:50`). The reason calls it "Markdown emitted verbatim". In `review-brief.sh` the file-level reason says "every single-quoted string here is a jq program or a Markdown template", but the file also holds two awk programs, `split=` at `:116` and the same `fenced=` at `:120`. Both suppressions are correct (16 SC2016 sites in `review-brief.sh`, one in `review-comment.sh`). Only the reason text is wrong. Fix: "the string is an awk program; the backticks are fence characters it matches, not command substitution", and add "or awk" to the `review-brief.sh` reason.

```sh
# template/.agents/skills/spec-review/scripts/review-comment.sh:40-41
# shellcheck disable=SC2016 # the fenced block is Markdown emitted verbatim; the backticks are literal
fenced='
# template/.agents/skills/spec-review/scripts/review-brief.sh:17
# shellcheck disable=SC2016 # every single-quoted string here is a jq program or a Markdown template; the backticks and $ are literal
```

## Fix alongside

2. **The doctor says PASS for a ShellCheck that the gate will not use.** This is a judgement call about Mysterious Name/intent. The doctor passes any version (`PASS  shellcheck 0.9.0`). The gate trusts only 0.11.0 and otherwise downloads it, or on an unpinned platform (Linux aarch64, macOS x86_64) refuses with "install it by hand". On such a machine, the user who ran the doctor's own suggested `apt install shellcheck` sees PASS, and then the gate refuses. The `vp matches the ADR pin` line three rows up compares against the pin. This line could do the same, or print `NOTE  shellcheck 0.9.0 (the gate uses 0.11.0)`. The acceptance criterion (NOTE when absent) holds as written.

```sh
# factory918.sh:274-276
  local scv; scv="$(shellcheck --version 2>/dev/null | sed -n 's/^version: //p' || true)"
  if [ -n "$scv" ]; then echo "PASS  shellcheck $scv"
  else note "shellcheck" "brew install shellcheck (apt install shellcheck, dnf install ShellCheck, winget install koalaman.shellcheck); .github/shellcheck.sh downloads the pinned build without it, so this is a NOTE"; fi
```

3. **In the factory, the zero-argument form checks 6 of the 20 files and exits 0.** This is a judgement call about Information leakage (the default set knows only a project's layout). Through the root symlink, `bash .github/shellcheck.sh` at the factory root prints `ShellCheck 0.11.0, files checked: 6` (the five hooks plus the gate). The reason: `.agents/skills/*/scripts/*.sh` matches nothing there, and `factory918.sh` and `tests/` are not in the default set. `AGENTS.md:38` documents the full command, so the documented path is correct. The header's "this project's shell files" line is the one a factory lane reads when it opens the gate. One sentence in the header ("in the factory, pass the set `AGENTS.md` names") would close it.

```sh
# template/.github/shellcheck.sh:5, :35
#   bash .github/shellcheck.sh                  this project's shell files
if [ "$#" = 0 ]; then set -- '.claude/hooks/*.sh' '.agents/skills/*/scripts/*.sh' '.github/shellcheck.sh'; fi
```

4. **Case 6 of the gate test says ShellCheck is hidden, but on `ubuntu-latest` it is not.** This is a judgement call about test accuracy. `PATH="$fx/bin:/usr/bin:/bin"` hides Homebrew's `/opt/homebrew/bin/shellcheck`, but not the runner image's `/usr/bin/shellcheck`. The case passes in CI only because that copy is off-pin, as the ticket's design assumes for the download row. If the image moves to 0.11.0, case 6 fails loudly, so nothing passes silently. The header's "ShellCheck hidden" is still untrue where CI runs it. A fake `shellcheck` in `$fx/bin` that prints an off-pin version would make the case independent of the image.

```sh
# tests/shellcheck/gate.sh:7, :76
# build for is refused when no ShellCheck is on PATH (a fake uname on PATH, ShellCheck hidden).
PATH="$fx/bin:/usr/bin:/bin" run clean.sh
```

hard findings: 0
