## Would break

## Fails open

## Standards breaches

## Fix alongside

1. **A bad cached tarball blocks every later run, and the error no longer names the file.** CODING_STANDARDS.md, Bash: "A failure a gate depends on is printed before anything continues." The failure is printed, so this is not a hard breach. The problem is that 1362b48 sends the checksum tool's stdout to `/dev/null`. That stdout line, `<path>/sc.tar.xz: FAILED`, was the only one that named the file. What remains on stderr is `WARNING: 1 computed checksum did NOT match`, which says nothing about what to delete. `[ -f "$tarball" ] ||` never downloads again, and test 9 asserts that. So an interrupted `curl -o`, which leaves a partial file, makes the gate fail on every run until someone finds `${TMPDIR:-/tmp}/shellcheck-0.11.0` without help. The blast radius's "the next run retries" holds only for a partial extract, not for a partial download. Fix: on a mismatch, print one line that names the path and says "delete it and rerun".

```sh
+  [ -f "$tarball" ] || curl -fsSL -o "$tarball" "https://github.com/..."
+  if command -v sha256sum >/dev/null; then echo "$sha  $tarball" | sha256sum -c - >/dev/null
+  else echo "$sha  $tarball" | shasum -a 256 -c - >/dev/null; fi
```

2. **The doctor passes any ShellCheck version, not the pin.** Judgement call against P2 ("Pin every tool CI runs to an exact version"). The `vp` check a few lines above compares against its pin. This line prints `PASS  shellcheck 0.10.0` for a version the gate will not use.

```sh
+  local scv; scv="$(shellcheck --version 2>/dev/null | sed -n 's/^version: //p' || true)"
+  if [ -n "$scv" ]; then echo "PASS  shellcheck $scv"
```

3. **Duplicated Code, and the reason cites a line number.** The same reason appears three times in `delegation.sh`, and each copy points at "line 7". A header edit makes all three wrong. Pointing at `set -fuo pipefail` instead would stay true.

```sh
+  # shellcheck disable=SC2086 # set -f is on (line 7), so this splits words without globbing, which is the intent
```

hard findings: 0
