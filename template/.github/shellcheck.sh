#!/usr/bin/env bash
# The shell gate, in this project and in the factory that wrote it. Runs ShellCheck at the pinned
# version over the files the globs name, downloading that version when this machine does not have
# it, so the run a lane makes before a PR and the run CI makes are one run.
#   bash .github/shellcheck.sh                  this project's shell files
#   bash .github/shellcheck.sh '<glob>' ...     exactly these; quote a glob, this script expands it
# Run it from the repository root: --external-sources resolves a sourced file against the working
# directory. The severity is the default, because SC2086, the unquoted expansion, is info level and
# a --severity floor would pass the class this gate exists for. No --shell: each file is read in the
# dialect of its own shebang, so a `#!/bin/sh` file keeps its bashism checks. Globs that match no
# file at all leave the gate checking nothing, which is a failure, not a pass.
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
  bin="$dir/shellcheck-v$version/shellcheck"
  if [ ! -x "$bin" ]; then
    mkdir -p "$dir"
    curl -fsSL -o "$dir/sc.tar.xz" "https://github.com/koalaman/shellcheck/releases/download/v$version/shellcheck-v$version.$plat.tar.xz"
    if command -v sha256sum >/dev/null; then echo "$sha  $dir/sc.tar.xz" | sha256sum -c -
    else echo "$sha  $dir/sc.tar.xz" | shasum -a 256 -c -; fi
    tar -xJf "$dir/sc.tar.xz" -C "$dir"
  fi
fi

if [ "$#" = 0 ]; then set -- '.claude/hooks/*.sh' '.agents/skills/*/scripts/*.sh' '.github/shellcheck.sh'; fi
files=()
for g in "$@"; do
  for f in $g; do if [ -f "$f" ]; then files+=("$f"); fi; done
done
if [ "${#files[@]}" = 0 ]; then
  echo "shellcheck.sh: no file matched $*; the gate checked nothing" >&2
  exit 1
fi
echo "ShellCheck $version, files checked: ${#files[@]}"
exec "$bin" --external-sources "${files[@]}"
