## Would break

## Fails open

1. **A glob that matches a path with a space drops the file and the gate still passes.** `CODING_STANDARDS.md`, Bash: "Quote every path. Paths here contain spaces." The glob argument is expanded unquoted, so each matched path is re-split on IFS; `tests/a b/x.sh` becomes `tests/a` and `b/x.sh`, neither passes `[ -f "$f" ]`, and both are dropped with no word. The same loop also drops an unmatched glob among matched ones, so a renamed directory shrinks the set silently. The `files checked:` count is the only tell, and nothing compares it to a wanted number.

Documented step: `AGENTS.md`, Verifying: "`bash .github/shellcheck.sh factory918.sh template/.github/shellcheck.sh 'template/.claude/hooks/*.sh' 'template/.agents/skills/*/scripts/*.sh' 'tests/*/*.sh'`, ShellCheck at the pin over 20 files."

Result: the shell files under such a path are never linted, the gate prints a lower count and exits 0, and CI is green on files no one checked. ShellCheck cannot catch this: SC2086 does not fire on `for f in $g`, which is why the gate's own run is clean.

```sh
files=()
for g in "$@"; do
  for f in $g; do if [ -f "$f" ]; then files+=("$f"); fi; done
done
```

The fix stays inside the loop: count what each glob contributed and refuse a glob that contributed nothing, and read the matches with `IFS= ` set or through a `read -d ''` loop so a space in a path survives. The gate's test already builds its fixture under `with space`, so the case is one row away.

## Standards breaches

## Fix alongside

2. **The cached download is reused without its checksum.** `template/.github/shellcheck.sh:26`: once `${TMPDIR:-/tmp}/shellcheck-0.11.0/.../shellcheck` exists, `[ ! -x "$bin" ]` skips both the download and the `sha256sum -c`, so the pin is verified once and trusted forever. On a fresh runner this cannot bite; on a shared box with a world-writable `/tmp` it silently runs whatever is there. Moving the sha check out of the `if` costs one hash per run.

```sh
  if [ ! -x "$bin" ]; then
    mkdir -p "$dir"
    curl -fsSL -o "$dir/sc.tar.xz" "https://github.com/koalaman/shellcheck/releases/download/v$version/shellcheck-v$version.$plat.tar.xz"
```

hard findings: 1
