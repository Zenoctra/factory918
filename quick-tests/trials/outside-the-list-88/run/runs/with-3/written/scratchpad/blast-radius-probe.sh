#!/usr/bin/env bash
# Blast-radius probe for feat/shellcheck (ab47eb9..69bd412). Run from the factory root.
# 1. the delegation hook is the same program once comment lines are stripped
# 2. a planted cache under TMPDIR is executed by the gate without a checksum
# 3. the gate offline, without the pin on PATH, dies on a bare curl line
set -uo pipefail
root="$(git rev-parse --show-toplevel)"; cd "$root"
t="$(mktemp -d "${TMPDIR:-/tmp}/br.XXXXXX")"; trap 'rm -rf "$t"' EXIT
git show ab47eb9:template/.claude/hooks/delegation.sh | grep -vE '^[[:space:]]*#' > "$t/old"
git show 69bd412:template/.claude/hooks/delegation.sh | grep -vE '^[[:space:]]*#' > "$t/new"
diff "$t/old" "$t/new" && echo "1 hook identical after stripping comments ($(wc -l < "$t/new" | tr -d ' ') lines)"
mkdir -p "$t/cache/shellcheck-0.11.0/shellcheck-v0.11.0" "$t/nosc"
printf '#!/bin/sh\necho "PLANTED FILE RAN: $*"\n' > "$t/cache/shellcheck-0.11.0/shellcheck-v0.11.0/shellcheck"
chmod +x "$t/cache/shellcheck-0.11.0/shellcheck-v0.11.0/shellcheck"
printf '#!/usr/bin/env bash\necho ok\n' > "$t/clean.sh"
echo "2 planted cache:"; (cd "$t" && TMPDIR="$t/cache" PATH="$t/nosc:/usr/bin:/bin" bash "$root/template/.github/shellcheck.sh" clean.sh; echo "   exit=$?")
echo "3 offline, no pin on PATH (expect curl: (22) or (6) and a nonzero exit):"
(cd "$t" && TMPDIR="$t/empty" PATH="$t/nosc:/usr/bin:/bin" bash "$root/template/.github/shellcheck.sh" clean.sh; echo "   exit=$?")
