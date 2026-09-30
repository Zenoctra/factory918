## Would break

## Fails open

1. **A wrong cached executable passes as the pinned ShellCheck.** `CODING_STANDARDS.md`, Bash, says a failure a gate depends on must be printed before it continues. The gate checks the cached path only for its executable bit. With ShellCheck absent from `PATH`, an executable at that path that does no linting is run without a version or checksum check. I put such an executable under a fresh `TMPDIR`, passed a file containing SC2086, and got exit 0 with `ShellCheck 0.11.0, files checked: 1` and `FAKE CACHE RAN`.

   ```bash
   bin="$dir/shellcheck-v$version/shellcheck"
   if [ ! -x "$bin" ]; then
     mkdir -p "$dir"
     curl -fsSL -o "$dir/sc.tar.xz" "https://github.com/koalaman/shellcheck/releases/download/v$version/shellcheck-v$version.$plat.tar.xz"
     if command -v sha256sum >/dev/null; then echo "$sha  $dir/sc.tar.xz" | sha256sum -c -
     else echo "$sha  $dir/sc.tar.xz" | shasum -a 256 -c -; fi
     tar -xJf "$dir/sc.tar.xz" -C "$dir"
   fi
   ```

   Documented step: Ticket `## Design`, "Local ShellCheck absent or off-pin, platform pinned" says the gate "downloads once, then one of the rows above"; the signature says it runs ShellCheck 0.11.0.
   Result: An unverified cached executable can silently report success for a file with a finding, so the gate neither downloads the pinned release nor refuses the invalid cache.
   spec: table Local ShellCheck absent or off-pin, platform pinned/Exit

## Standards breaches

## Fix alongside

hard findings: 1
