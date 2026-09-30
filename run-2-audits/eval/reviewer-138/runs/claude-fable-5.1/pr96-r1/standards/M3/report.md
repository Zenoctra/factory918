## Would break

## Fails open

## Standards breaches

## Fix alongside

1. **A stale tarball is never retried.** Judgement call, Idempotent operations (`template/CODING_STANDARDS.md`, "what happens if the previous run crashed halfway?"). `curl -o` writes what it received when a transfer is cut, and `set -e` ends the run at that line; the next run sees the file, skips the download, fails the checksum, and so does every run after it until someone deletes `${TMPDIR:-/tmp}/shellcheck-0.11.0/sc.tar.xz` by hand. The failure is loud and the tool's message names the file, so this is not a hard finding, but the blast-radius sentence "A half download leaves no binary, so the next run retries" is true of the binary and false of the tarball. Reproduced: a fresh `TMPDIR` holding an 8-byte `sc.tar.xz`, ShellCheck hidden from PATH, two runs in a row both print `sc.tar.xz: FAILED` / `shasum: WARNING: 1 computed checksum did NOT match` and exit 1, and the file is still there after the second. Two lanes running the gate at once on a machine without the pin race on the same path the same way. One fix covers both: download to `"$tarball.$$"` and `mv` it over `$tarball` after the checksum passes, or `rm -f "$tarball"` when the check fails, so a bad file is never the cached one.

```sh
  [ -f "$tarball" ] || curl -fsSL -o "$tarball" "https://github.com/koalaman/shellcheck/releases/download/v$version/shellcheck-v$version.$plat.tar.xz"
  if command -v sha256sum >/dev/null; then echo "$sha  $tarball" | sha256sum -c - >&2
  else echo "$sha  $tarball" | shasum -a 256 -c - >&2; fi
```

2. **The doctor's PASS does not compare the pin.** Judgement call. The line prints `PASS  shellcheck <version>` for any ShellCheck on PATH, so a machine with 0.10.0 reads PASS while the gate will ignore that binary and download 0.11.0 on every project. The ticket asks only for NOTE without one, and the gate is correct either way, so nothing is wrong; the line would say more with the pin beside it, `PASS  shellcheck 0.10.0 (the gate pins 0.11.0 and downloads it)`, or a NOTE when the version is off the pin. The pin would then live in two files, which P25 argues against; a `grep` of `^version=` from `.github/shellcheck.sh` keeps it in one.

```sh
  local scv; scv="$(shellcheck --version 2>/dev/null | sed -n 's/^version: //p' || true)"
  if [ -n "$scv" ]; then echo "PASS  shellcheck $scv"
  else note "shellcheck" "brew install shellcheck (apt install shellcheck, dnf install ShellCheck, winget install koalaman.shellcheck); .github/shellcheck.sh downloads the pinned build without it, so this is a NOTE"; fi
```

hard findings: 0
