#!/bin/bash
# topup2.sh: one more k for each Claude model and brief with fewer than 3 complete runs
S=/private/tmp/claude-501/-Users-manuel-Desktop-Work-Under-The-Sun-Collective-Core-918-factory918/48857ffb-f0e5-4af1-9b36-ecddce7fb416/scratchpad
cd "/Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.scratch/eval/reviewer" || exit 1
python3 - <<'EOF' > "$S/topup2.list"
import collections, glob, json, os
complete = collections.Counter()
dirs = collections.Counter()
for f in glob.glob('runs/claude-*/*/*/*/run.json'):
    d = os.path.dirname(f)
    j = json.load(open(f))['run']
    key = (j['descriptor'], j['round'] + '/' + j['axis'])
    dirs[key] += 1
    rj = os.path.join(d, 'receipt.json')
    if os.path.exists(rj) and json.load(open(rj))['status'] == 'complete':
        complete[key] += 1
for key in sorted(dirs):
    if key[0] != 'claude:fable-5.1' and complete[key] < 3:
        print(key[0], key[1], dirs[key] + 3 - complete[key])
EOF
while read -r model brief n; do
  bash "$S/rv.sh" run "$model" "$brief" "$n" > /dev/null
done < "$S/topup2.list"
cat "$S/topup2.list"
bash "$S/pending.sh"
