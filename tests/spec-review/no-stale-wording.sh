#!/usr/bin/env bash
# Greps template/ and docs/knowledge/core/ for the wording #81 retired, the `## Latent` heading and
# the definition sentence that began "A hard finding is wrong behavior in normal use", so a rename
# that leaves the old words behind fails here. Prints each hit as file:line and exits 1 on any;
# prints `ok: no stale wording` otherwise.
set -euo pipefail
cd "$(dirname "$0")/../.."
hits="$(grep -rnF -e '## Latent' -e 'A hard finding is wrong behavior in normal use' template docs/knowledge/core | cut -d: -f1,2 || true)"
if [ -n "$hits" ]; then
  printf '%s\n' "$hits"
  exit 1
fi
echo "ok: no stale wording"
