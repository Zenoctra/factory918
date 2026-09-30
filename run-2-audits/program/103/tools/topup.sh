#!/bin/bash
# topup.sh: for every contaminated Claude run, prepare one more k for that model and brief
S=/private/tmp/claude-501/-Users-manuel-Desktop-Work-Under-The-Sun-Collective-Core-918-factory918/48857ffb-f0e5-4af1-9b36-ecddce7fb416/scratchpad
cd "/Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.scratch/eval/reviewer/runs" || exit 1
python3 - <<'EOF' > "$S/topup.list"
import collections, glob, json
need = collections.Counter()
have = collections.Counter()
for f in glob.glob('claude-*/*/*/*/receipt.json'):
    d = json.load(open(f))
    r = d['run']
    key = (r['descriptor'], f"{r['round']}/{r['axis']}")
    have[key] += 1
    if d['status'] == 'contaminated':
        need[key] += 1
for key, n in sorted(need.items()):
    print(key[0], key[1], have[key] + 1)
EOF
while read -r model brief n; do
  bash "$S/rv.sh" run "$model" "$brief" "$n" > /dev/null
done < "$S/topup.list"
cat "$S/topup.list"
