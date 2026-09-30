#!/bin/bash
# pending.sh [descriptor N]   with args: prepares runs 1..N of every brief for the descriptor first.
# Prints the collect summary and each unlaunched run compactly: agent | description | brief path
S=/private/tmp/claude-501/-Users-manuel-Desktop-Work-Under-The-Sun-Collective-Core-918-factory918/48857ffb-f0e5-4af1-9b36-ecddce7fb416/scratchpad
[ -n "$1" ] && bash "$S/sweep.sh" "$1" "$2" > /dev/null
bash "$S/rv.sh" collect | python3 -c '
import json, sys
n = 0
for line in sys.stdin:
    if line.startswith("unlaunched "):
        d = json.loads(line[len("unlaunched "):])
        a = d["agent"]
        n += 1
        if n > 8: continue
        print(a["subagent_type"] + ("/" + a["model"] if "model" in a else ""), "|", d["description"], "|", d["prompt"].split("`")[1])
    elif line.startswith("collected "):
        print(line.strip(), "| unlaunched listed", min(n, 8), "of", n)
'
