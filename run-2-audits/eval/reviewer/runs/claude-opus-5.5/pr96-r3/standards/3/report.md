## Would break

## Fails open

## Standards breaches

## Fix alongside

1. **A cached partial tarball is refused on every later run, and the refusal does not say how to fix it.** `curl -fsSL -o` leaves a partial file behind when the connection drops, and `[ -f "$tarball" ] ||` then skips the download for good. Each later run fails with only the checksum tool's `did NOT match` on stderr. It fails loudly, so it does not fail open. The message never names the file to delete, and the blast radius's "the next run retries" is not what the code does. Fix: name `$tarball` in a refusal of the gate's own, or download to a temp name and `mv` the file into place only after its sha passes.

```bash
+  [ -f "$tarball" ] || curl -fsSL -o "$tarball" "https://github.com/koalaman/shellcheck/releases/download/v$version/shellcheck-v$version.$plat.tar.xz"
+  if command -v sha256sum >/dev/null; then echo "$sha  $tarball" | sha256sum -c - >/dev/null
+  else echo "$sha  $tarball" | shasum -a 256 -c - >/dev/null; fi
```

2. **Mysterious Name: the doctor prints PASS for any ShellCheck version.** A machine on 0.10.0 reads `PASS  shellcheck 0.10.0`, although the gate ignores that binary and downloads the pin. Compare the version with the pin, or print the line as a NOTE when they differ.

```bash
+  if [ -n "$scv" ]; then echo "PASS  shellcheck $scv"
```

3. **A line number inside a directive's reason will drift.** Three directives cite "line 7" for `set -f`. Any edit above line 7 of `delegation.sh` makes the reason point at the wrong line. "the `set -f` at the top" stays true.

```bash
+  # shellcheck disable=SC2086 # set -f is on (line 7), so this splits words without globbing, which is the intent
```

4. **Test 9's platform case does not match the gate's.** The gate accepts `Darwin.aarch64`, but the test runs case 9 only for `Darwin.arm64` and skips it on the other name.

```bash
+  Linux.x86_64|Darwin.arm64)
```

hard findings: 0
