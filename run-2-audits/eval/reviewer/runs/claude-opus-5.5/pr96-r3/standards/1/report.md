## Would break

## Fails open

## Standards breaches

## Fix alongside

1. **A bad cached tarball blocks every later run, and the refusal does not say how to clear it.** A download cut off mid-stream leaves a partial `sc.tar.xz` behind. Because of `[ -f "$tarball" ] ||`, the next run skips the download, the checksum fails, and every run after that fails the same way. The only message is `sha256sum`'s `did NOT match` warning; nothing tells the user to delete `$dir`. It fails loudly, not silently, so it is not a hard finding. The brief's cleared line "A half download leaves no binary, so the next run retries" is inaccurate: the next run does not download again, and test 9 asserts that it does not. The fix is one line: on a checksum mismatch, print `remove "$dir" and rerun` to stderr, or delete the tarball before exiting.

```bash
+  [ -f "$tarball" ] || curl -fsSL -o "$tarball" "https://github.com/koalaman/shellcheck/releases/download/v$version/shellcheck-v$version.$plat.tar.xz"
+  if command -v sha256sum >/dev/null; then echo "$sha  $tarball" | sha256sum -c - >/dev/null
+  else echo "$sha  $tarball" | shasum -a 256 -c - >/dev/null; fi
```

2. **A directive reason cites a line number that will drift.** The three SC2086 reasons in `delegation.sh` say `set -f is on (line 7)`. The next edit above line 7 makes the reason false, and the directive standard exists to keep each reason true. Name the statement instead, for example `set -f is on (the set -fuo pipefail at the top)`.

```bash
+  # shellcheck disable=SC2086 # set -f is on (line 7), so this splits words without globbing, which is the intent
```

3. **The test's platform case does not match the gate's.** The gate accepts both `Darwin.arm64` and `Darwin.aarch64`. Test 9 accepts only `Darwin.arm64`, so on a Mac that reports `aarch64` it skips a case the gate handles. The two case patterns are duplicated and can drift; `Darwin.aarch64` should be added to the test.

```bash
+  Linux.x86_64|Darwin.arm64)
```

hard findings: 0
