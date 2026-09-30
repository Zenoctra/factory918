#!/bin/bash
# settle.sh <max-minutes> [descriptor N]  waits until no Claude run is in flight (or the time is up), then prints pending.sh
S=/private/tmp/claude-501/-Users-manuel-Desktop-Work-Under-The-Sun-Collective-Core-918-factory918/48857ffb-f0e5-4af1-9b36-ecddce7fb416/scratchpad
end=$(( $(date +%s) + $1 * 60 )); shift
while [ "$(date +%s)" -lt "$end" ]; do
  bash "$S/rv.sh" collect | grep -Eq "in flight 0 " && break
  sleep 30
done
bash "$S/pending.sh" "$@"
