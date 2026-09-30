#!/bin/bash
# sweep.sh <descriptor> <N> [axis]   runs every brief (optionally one axis) for a descriptor
RV=/private/tmp/claude-501/-Users-manuel-Desktop-Work-Under-The-Sun-Collective-Core-918-factory918/48857ffb-f0e5-4af1-9b36-ecddce7fb416/scratchpad/rv.sh
for b in $(bash "$RV" check --list); do
  case "$b" in */"${3:-}"*) ;; *) continue ;; esac
  bash "$RV" run "$1" "$b" "$2"
done
