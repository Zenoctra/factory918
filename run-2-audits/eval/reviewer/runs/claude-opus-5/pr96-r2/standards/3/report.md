## Would break

## Fails open

## Standards breaches

## Fix alongside

1. **A cached binary is reused with no version or checksum check.** Once `$dir/shellcheck-v$version/shellcheck` exists, the download, the sha line and any version probe are all skipped; `bin` is never re-verified after the PATH check fails. The version-scoped directory makes a stale pin unlikely, so the exposure is a writable `/tmp` on a shared machine, which is the author's risk 1. A `"$bin" --version | grep -qx "version: $version"` after the `if` block would cost one process and close it.

```sh
  if [ ! -x "$bin" ]; then
    mkdir -p "$dir"
    curl -fsSL -o "$dir/sc.tar.xz" "https://github.com/koalaman/shellcheck/releases/download/v$version/shellcheck-v$version.$plat.tar.xz"
```

2. **`PASS  shellcheck 0.9.0` is printed for a version that is not the pin.** Every other version check in `cmd_doctor` compares against its pin (`chk "vp matches the ADR pin"`). This one reports whatever is on PATH as a pass, so a person reading the table cannot tell the pinned toolchain from a divergent one. Harmless for the gate, which downloads the pin regardless; misleading in the report the doctor exists to print.

```sh
  local scv; scv="$(shellcheck --version 2>/dev/null | sed -n 's/^version: //p' || true)"
  if [ -n "$scv" ]; then echo "PASS  shellcheck $scv"
```

3. **The vendored skill scripts now inside the gate's set cannot be fixed in place.** `template/.agents/skills/*/scripts/*.sh` widens the set from two skills to all of them, which pulls in `show-me-your-work`'s scripts. They are clean today, but they sit outside `cmd_sync`'s `keep_files`, so the next `sync` that brings a finding with it turns factory CI red and AGENTS.md ("Vendored skills") allows only a patch in `patches/` as the fix. Worth a line in `SOURCES.md` or the patch series now rather than at the failure.

```
- `bash .github/shellcheck.sh factory918.sh template/.github/shellcheck.sh 'template/.claude/hooks/*.sh' 'template/.agents/skills/*/scripts/*.sh' 'tests/*/*.sh'`
```

4. **`dirs=("$skills"/*/)` counts one when nothing matches.** Without `nullglob` the unmatched pattern survives as a literal, so an empty skills directory would print `vendored: 1 skills` where `ls -d | wc -l` printed `0` with an error. Unreachable while `sync` succeeds, since the copies precede the count; the smell is a count that cannot be zero.

```sh
  local -a dirs; dirs=("$skills"/*/)
  echo "vendored: ${#dirs[@]} skills. Review with git status, bump VERSION, commit."
```

hard findings: 0
