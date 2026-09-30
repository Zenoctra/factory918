#!/usr/bin/env bash
# The total's edges, a large Python file, and the real factory history.
set -euo pipefail
here=/tmp/p107.uRK0bc
r="$here/repo2"; rm -rf "$r"; mkdir "$r"; cd "$r"
git init -q; git config user.email t@t.invalid; git config user.name t
echo seed > seed; git add -A; git commit -qm base; base="$(git rev-parse HEAD)"
python3 - <<'PY'
for n in "abcd":
    open(f"{n}.txt", "w").write(("y" * 63 + "\n") * 256)   # 16384 bytes each
pad = "z" * 120
py = ["import os", ""]
for i in range(1, 120):
    py += [f"def f{i}(x):", f"    if x:", f"        return {i}  # {pad}", f"    return 0", ""]
open("code.py", "w").write("\n".join(py) + "\n")
PY
git add -A; git commit -qm four; mid="$(git rev-parse HEAD)"
echo "===== FOUR FILES OF 16384 BYTES (exactly the total)"
"$here/pack.sh" "$base" 2>&1 | grep '^### \|^Not carried\|pack-bytes'
echo e > e.txt
sed -i '' 's/return 60  #/return 600  #/' code.py
git add -A; git commit -qm five
echo "===== PLUS ONE BYTE-FILE (e.txt, 2 bytes) AND A CHANGE IN code.py"
"$here/pack.sh" "$base" 2>&1 | grep '^### \|^Not carried\|pack-bytes'
echo "===== code.py alone (fix-only from mid)"
"$here/pack.sh" "$mid" 2>&1
echo "===== REAL HISTORY"
c="$here/factory"; rm -rf "$c"
git clone -q --no-local "/Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918" "$c"
cd "$c"
for m in 86d156a b329d45 bd39a68 aed8fae c5ce8fd; do
  git checkout -q --detach "$m"
  "$here/pack.sh" "$m^1" > "$here/real-$m.md" 2> "$here/real-$m.err" || echo "FAILED $m"
  echo "== $m diff $(git diff "$m^1...$m" | wc -l) lines; pack $(cat "$here/real-$m.err"); entries $(grep -c '^### ' "$here/real-$m.md"); brief-lines $(wc -l < "$here/real-$m.md")"
  grep '^Not carried' "$here/real-$m.md" | cut -c1-300 || true
done
