## Would break

1. **A quoted file path with spaces is split.** `CODING_STANDARDS.md`, Bash, requires quoted paths because paths here contain spaces, and requires testing commands as users type them. The inner loop splits an explicit argument at spaces before checking whether it is a file. I ran the gate on a valid quoted shell file under `.scratch/work/space case/clean file.sh`; it exited 1 and said nothing matched.

   Documented step: ticket `## Design`, usage `bash .github/shellcheck.sh '<glob>' ...` says the gate checks exactly the quoted arguments; `CODING_STANDARDS.md` says “Quote every path. Paths here contain spaces.”

   Result: a valid changed shell file whose name or directory contains a space cannot be checked through the documented invocation.

   spec: design `shellcheck.sh [glob...]`

   ```sh
   for g in "$@"; do
     for f in $g; do if [ -f "$f" ]; then files+=("$f"); fi; done
   done
   ```

## Fails open

2. **One missing glob is accepted when another matches.** `CODING_STANDARDS.md`, Bash, says a failure a gate depends on must be printed before anything continues. The gate checks only whether the combined file list is empty, so one absent group is silently skipped. `bash .github/shellcheck.sh template/.github/shellcheck.sh 'missing/*.sh'` exited 0 and printed `files checked: 1`.

   Documented step: ticket `## Design`, row “A glob matches no file” requires `shellcheck.sh: no file matched <globs>; the gate checked nothing` on stderr and exit 1.

   Result: a misspelled or missing hook or skill glob can leave part of the requested set unchecked while the gate reports success.

   spec: table A glob matches no file/Exit

   ```sh
   for g in "$@"; do
     for f in $g; do if [ -f "$f" ]; then files+=("$f"); fi; done
   done
   if [ "${#files[@]}" = 0 ]; then
     echo "shellcheck.sh: no file matched $*; the gate checked nothing" >&2
     exit 1
   fi
   ```

3. **An existing cache executable bypasses the pin.** `docs/knowledge/core/DECISIONS.md`, P2, requires an exact version for every CI tool, and P25 makes this gate the holder of that pin. Once the cache path contains any executable, the gate skips both the checksum and a version check. With an off-pin `shellcheck` on PATH and an executable at the cache path that printed `CACHED_UNPINNED_EXECUTED`, the gate ran that executable and exited 0 while announcing `ShellCheck 0.11.0`.

   Documented step: ticket `## Design`, signature says the gate uses the PATH binary only when its version matches the pin; otherwise it downloads the pinned release, checks its sha256, and runs that.

   Result: a stale or replaced cache binary can report a passing gate without running ShellCheck 0.11.0.

   spec: design `shellcheck.sh [glob...]`

   ```sh
   bin="$dir/shellcheck-v$version/shellcheck"
   if [ ! -x "$bin" ]; then
     mkdir -p "$dir"
     curl -fsSL -o "$dir/sc.tar.xz" "https://github.com/koalaman/shellcheck/releases/download/v$version/shellcheck-v$version.$plat.tar.xz"
     if command -v sha256sum >/dev/null; then echo "$sha  $dir/sc.tar.xz" | sha256sum -c -
     else echo "$sha  $dir/sc.tar.xz" | shasum -a 256 -c -; fi
     tar -xJf "$dir/sc.tar.xz" -C "$dir"
   fi
   ```

## Standards breaches

## Fix alongside

hard findings: 3
