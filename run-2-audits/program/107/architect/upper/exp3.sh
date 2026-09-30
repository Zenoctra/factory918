#!/usr/bin/env bash
# Submodule, a path holding a newline, a statement over the unit, long Markdown lines, a flat 1300-line function.
set -euo pipefail
here=/tmp/p107.uRK0bc
r="$here/repo3"; rm -rf "$r" "$here/sub"; mkdir "$r" "$here/sub"; cd "$here/sub"
git init -q; git config user.email t@t.invalid; git config user.name t; echo s > s; git add s; git commit -qm s
cd "$r"
git init -q; git config user.email t@t.invalid; git config user.name t
python3 - <<'PY'
pad = "q" * 70
sh = ["#!/usr/bin/env bash", "flat() {"] + [f'  echo "flat {i} {pad}"' for i in range(1, 1301)] + ["}"]
sh += ["cat <<'DOC'"] + [f"doc {i} {pad}" for i in range(1, 200)] + ["DOC", "echo end"]
open("flat.sh", "w").write("\n".join(sh) + "\n")
md = ["# Long lines", ""] + [f"| row {i} | " + "w" * 900 + " |" for i in range(1, 40)] + [""]
open("long.md", "w").write("\n".join(md) + "\n")
PY
printf 'x\n' > "$(printf 'odd\nname')"
git add -A; git commit -qm base; base="$(git rev-parse HEAD)"
git -c protocol.file.allow=always submodule add -q "$here/sub" sub
python3 - <<'PY'
s = open("flat.sh").read().replace('"flat 700 ', '"FLAT 700 ').replace("doc 100 ", "DOC 100 ")
open("flat.sh", "w").write(s)
m = open("long.md").read().replace("| row 20 |", "| ROW 20 |")
open("long.md", "w").write(m)
PY
printf 'y\n' > "$(printf 'odd\nname')"
git add -A; git commit -qm change
"$here/pack.sh" "$base" | awk '/^### /{print; getline; getline; print "   first text line: " substr($0,1,0)} ' | head -40
"$here/pack.sh" "$base" | awk '/^```/{c++} /^### /{h=$0} END{}' ; "$here/pack.sh" "$base" 2>&1 >/dev/null
"$here/pack.sh" "$base" 2>/dev/null | awk '/^### flat.sh/{p=1} p' | sed -n '1,4p;$p' | cut -c1-60
