## Would break

None.

## Fails open

1. **A renamed glob silently shrinks the checked set.** `CODING_STANDARDS.md`, Bash: "A failure a gate depends on is printed before anything continues." `template/.github/shellcheck.sh` counts files across every glob together and refuses only when the total is zero:

```
files=()
for g in "$@"; do
  for f in $g; do if [ -f "$f" ]; then files+=("$f"); fi; done
done
if [ "${#files[@]}" = 0 ]; then
  echo "shellcheck.sh: no file matched $*; the gate checked nothing" >&2
  exit 1
fi
```

One glob among several (e.g. `tests/*/*.sh` after `tests/` is renamed) can match nothing while the others still match, and the run proceeds silently: no message, exit 0, only a smaller `files checked: N` to notice.

Documented step: `CODING_STANDARDS.md`, Bash bullet, "A failure a gate depends on is printed before anything continues."
Result: the gate passes and reports a smaller-than-intended file count with no indication that a glob matched nothing.

## Standards breaches

None found beyond what CI already enforces.

## Fix alongside

2. **Duplicated Code.** The same replace-a-vendored-directory shape appears twice in `cmd_sync`'s two loops, both touched by this diff's `${skills:?}` fix:

```
for d in "$pstack"/skills/*/; do n="$(basename "$d")"; [ "$n" = no-comments ] && continue; rm -rf "${skills:?}/$n"; cp -R "$d" "$skills/$n"; done
for n in grilling grill-me grill-with-docs domain-modeling to-spec to-tickets wayfinder research prototype setup-matt-pocock-skills writing-for-agents wizard wait-what; do
  src="$(find "$matt" -maxdepth 2 -type d -name "$n" | head -1)"; rm -rf "${skills:?}/$n"; cp -R "$src" "$skills/$n"; done
```

3. **Primitive Obsession / Data Clumps.** `template/.github/shellcheck.sh` pins the ShellCheck release as two flat, platform-named scalars that always travel together with `version` and are selected by a parallel `case`:

```
sha_linux_x86_64=8c3be12b05d5c177a04c29e3c78ce89ac86f1595681cab149b65b97c4e227198
sha_darwin_aarch64=56affdd8de5527894dca6dc3d7e0a99a873b0f004d7aabc30ae407d3f48b0a79
...
    Linux.x86_64)                 plat=linux.x86_64;   sha="$sha_linux_x86_64" ;;
    Darwin.arm64|Darwin.aarch64)  plat=darwin.aarch64; sha="$sha_darwin_aarch64" ;;
```

A third platform means a third scalar plus a third case arm instead of one table row.

hard findings: 1
