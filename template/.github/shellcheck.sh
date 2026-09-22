#!/usr/bin/env bash
# The shell gate, in this project and in the factory that wrote it. Runs ShellCheck at the pinned
# version over the files the globs name. When this machine does not have that version it downloads
# the release tarball once, verifies its sha256 on every run, and runs the binary it extracts from
# it, so the run a lane makes before a PR and the run CI makes are one run.
#   bash .github/shellcheck.sh                  this project's shell files
#   bash .github/shellcheck.sh '<glob>' ...     exactly these; quote a glob, this script expands it
# Run it from the repository root: --external-sources resolves a sourced file against the working
# directory. The severity is the default, because SC2086, the unquoted expansion, is info level and
# a --severity floor would pass the class this gate exists for. No --shell: each file is read in the
# dialect of its own shebang, so a `#!/bin/sh` file keeps its bashism checks. A glob that matches
# no file is refused before ShellCheck runs, even beside globs that match, because a gate that
# checks fewer files than it names is a failure, not a pass.
set -euo pipefail
version=0.11.0
sha_linux_x86_64=8c3be12b05d5c177a04c29e3c78ce89ac86f1595681cab149b65b97c4e227198
sha_darwin_aarch64=56affdd8de5527894dca6dc3d7e0a99a873b0f004d7aabc30ae407d3f48b0a79

bin=shellcheck
if ! "$bin" --version 2>/dev/null | grep -qx "version: $version"; then
  case "$(uname -s).$(uname -m)" in
    Linux.x86_64)                 plat=linux.x86_64;   sha="$sha_linux_x86_64" ;;
    Darwin.arm64|Darwin.aarch64)  plat=darwin.aarch64; sha="$sha_darwin_aarch64" ;;
    *) echo "shellcheck.sh: ShellCheck $version is not pinned for $(uname -s).$(uname -m); install it by hand" >&2; exit 1 ;;
  esac
  dir="${TMPDIR:-/tmp}/shellcheck-$version"
  tarball="$dir/sc.tar.xz"
  bin="$dir/shellcheck-v$version/shellcheck"
  mkdir -p "$dir"
  [ -f "$tarball" ] || curl -fsSL -o "$tarball" "https://github.com/koalaman/shellcheck/releases/download/v$version/shellcheck-v$version.$plat.tar.xz"
  if command -v sha256sum >/dev/null; then echo "$sha  $tarball" | sha256sum -c - >&2
  else echo "$sha  $tarball" | shasum -a 256 -c - >&2; fi
  tar -xJf "$tarball" -C "$dir"
fi

if [ "$#" = 0 ]; then set -- '.claude/hooks/*.sh' '.agents/skills/*/scripts/*.sh' '.github/shellcheck.sh'; fi
files=()
IFS=  # an argument is one path or one glob, never split on the spaces in it
for g in "$@"; do
  matched=0
  for f in $g; do if [ -f "$f" ]; then files+=("$f"); matched=1; fi; done
  if [ "$matched" = 0 ]; then
    echo "shellcheck.sh: no file matched $g; the gate checked nothing" >&2
    exit 1
  fi
done
echo "ShellCheck $version, files checked: ${#files[@]}"
exec "$bin" --external-sources "${files[@]}"
