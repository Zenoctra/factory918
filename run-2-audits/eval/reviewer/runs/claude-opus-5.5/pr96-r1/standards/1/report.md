## Would break

## Fails open

1. **An argument that matches no file is dropped without a word when another argument matches.** `CODING_STANDARDS.md`, Bash: "A failure a gate depends on is printed before anything continues", and "Quote every path. Paths here contain spaces." The gate refuses only when *every* argument matches nothing. When one argument matches nothing, the gate still exits 0 and prints no message. That argument can be a mistyped path, a deleted or renamed file, a glob whose directory was renamed, or a quoted path that `$g` splits at a space. The count on stdout is the only sign. The header says a glob that matches nothing is "a failure, not a pass". The loop does not do that for each argument.
   Documented step: `template/.agents/skills/poteto-mode/playbooks/opening-a-pr.md:9`, "Run `bash .github/shellcheck.sh` on every shell file the diff changes before the PR opens"; `AGENTS.md:38`, the five-argument factory command.
   Result: `bash .github/shellcheck.sh 'template/.claude/hooks/*.sh' 'nope/*.sh'` prints `files checked: 5` and exits 0. A changed file named `"a b.sh"` next to another file is split into `a` and `b.sh`, and both are dropped. After a rename, the factory's 20-file set gets smaller and CI stays green. Fix: in the loop, record each argument that expands to no regular file, and exit 1 with its name.
   ```sh
   for g in "$@"; do
     for f in $g; do if [ -f "$f" ]; then files+=("$f"); fi; done
   done
   if [ "${#files[@]}" = 0 ]; then
   ```

## Standards breaches

## Fix alongside

2. **The doctor passes any ShellCheck version, but the gate treats only the pin as present.** The `vp` line next to it compares the version with the ADR pin, and DECISIONS P2 pins every tool CI runs. The new line prints `PASS  shellcheck 0.9.0` for the version `apt install shellcheck` installs. The fix text recommends that install, and the gate then ignores it and downloads 0.11.0 anyway. The fix: compare `$scv` with the version in `.github/shellcheck.sh`, or print NOTE when they differ.
   ```sh
   local scv; scv="$(shellcheck --version 2>/dev/null | sed -n 's/^version: //p' || true)"
   if [ -n "$scv" ]; then echo "PASS  shellcheck $scv"
   ```

3. **The cached binary is reused without its checksum.** The sha is checked only on download. After that, any executable at the cache path runs as the gate. This is the Blast radius section's Risk 1. No documented standard covers it, so it is listed here. Checking a sha of the extracted binary, or extracting into a fresh `mktemp -d`, would close it.
   ```sh
   if [ ! -x "$bin" ]; then
   ```

hard findings: 1
