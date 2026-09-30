## Would break

## Fails open

1. **A glob argument with a space in it is split, and a half that matches wins silently.** `$g` is expanded unquoted, so the argument is word-split before pathname expansion. `bash .github/shellcheck.sh 'my scripts/*.sh'` becomes the two words `my` and `scripts/*.sh`; if `scripts/*.sh` matches anything, `matched=1`, the refusal never fires, and the gate reports `files checked: N` and exits 0 over a set that is not the one the caller named. If neither half matches, the refusal names the whole glob, which does not say what went wrong.

Documented step: `template/.github/shellcheck.sh:6` — "`bash .github/shellcheck.sh '<glob>' ...     exactly these; quote a glob, this script expands it`", and `CODING_STANDARDS.md`, Bash: "Quote every path. Paths here contain spaces."
Result: a quoted glob whose directory part holds a space checks a different file set, or is refused with a message that names a pattern the script never tried.

```sh
for g in "$@"; do
  matched=0
  for f in $g; do if [ -f "$f" ]; then files+=("$f"); matched=1; fi; done
```

## Standards breaches

## Fix alongside

2. **The blast radius's cleared bullet is stale after `01e5386`.** The brief clears the fixture step with "with the hooks deleted, 6 (`.github/shellcheck.sh` always matches itself)". With the hooks deleted, `.claude/hooks/*.sh` now matches nothing and the zero-argument form exits 1 before ShellCheck runs; it cannot print 6. The behaviour is loud and is the commit's stated intent, so this is the grounding line, not the code.

```
+  if [ "$matched" = 0 ]; then
+    echo "shellcheck.sh: no file matched $g; the gate checked nothing" >&2
+    exit 1
```

3. **The cached binary is trusted on its path alone.** `[ ! -x "$bin" ]` skips both the download and the sha, so anything already at `${TMPDIR:-/tmp}/shellcheck-0.11.0/shellcheck-v0.11.0/shellcheck` runs as the pin. The version is in the path, so staleness cannot happen; only a writable shared `/tmp` can. Cheap fix: verify the extracted binary's `--version` before the `exec`.

```sh
  if [ ! -x "$bin" ]; then
    mkdir -p "$dir"
    curl -fsSL -o "$dir/sc.tar.xz" ...
```

hard findings: 1
