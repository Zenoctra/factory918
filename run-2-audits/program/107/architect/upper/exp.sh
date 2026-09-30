#!/usr/bin/env bash
# Builds a throwaway repo with every adversarial shape and prints the pack for each round kind.
set -euo pipefail
here=/tmp/p107.uRK0bc
r="$here/repo"; rm -rf "$r"; mkdir "$r"; cd "$r"
git init -q; git config user.email t@t.invalid; git config user.name t
python3 - <<'PY'
import os
pad = "x" * 60
sh = ["#!/usr/bin/env bash", "# the header comment", "set -eu"]
for i in range(1, 61):
    sh += [f"# f{i} does a thing", f"f{i}() {{", f"  local x={i}", f'  echo "{pad}"', "}"]
sh += ["# the top-level block", 'if [ -n "${x:-}" ]; then', "  echo top", "  echo top2", "fi"]
sh += ["one() { echo one; }", "two() { echo two; }"]
sh += ["cat <<EOF", "start", "}", "middle", "EOF", "echo after-heredoc"]
sh += ["suite() {", "fx=1", "# assert a", 'printed out "line one', "line two", 'line three" "label"', "has x y", "}"]
sh += ["huge() {"]
for i in range(1, 181):
    sh += [f"  if [ {i} ]; then", f'    echo "huge {i} {pad}"', "  fi"]
sh += ["}"]
open("big.sh", "w").write("\n".join(sh) + "\n")
md = ["---", "name: x", "---", "", "intro line", ""]
for i in range(1, 40):
    md += [f"## Section {i}", "", f"Body {i} " + pad * 4, ""]
md += ["## Fenced", "", "````md", "## not a heading", "```", "still inside", "````", "", "after fence", ""]
md += ["## Huge section", ""] + [f"- item {i} {pad}" for i in range(1, 200)] + ["", "## Tail", "", "tail line", ""]
open("big.md", "w").write("\n".join(md) + "\n")
open("crlf.md", "w", newline="").write("\r\n".join(md) + "\r\n")
open("small.sh", "w").write("#!/bin/sh\necho small\necho two\n")
open("nonl.txt", "w").write("a\nb\nno newline")
open("fences.md", "w").write("# F\n\n```sh\necho\n```\n\n````\n```\n````\ninline ``x`` and `````\n")
open("old name.sh", "w").write("# old name\n" + "\n".join(sh) + "\n")
open("pure.sh", "w").write("# pure\n" + "\n".join(sh) + "\n")
open("mode.sh", "w").write("# mode\n" + "\n".join(sh) + "\n")
open("gone.sh", "w").write("echo gone\n")
os.makedirs("gen", exist_ok=True)
open("gen/out.txt", "w").write("generated\n")
open(".gitattributes", "w").write("gen/** linguist-generated\n")
open("bin.png", "wb").write(bytes(range(256)))
py = ["import os", ""]
for i in range(1, 80):
    py += [f"def f{i}(x):", f"    if x:", f"        return {i}  # {pad}{pad}", f"    return 0", ""]
open("code.py", "w").write("\n".join(py) + "\n")
open("mini.js", "w").write("var a=1;" * 9000 + "\n")
PY
ln -s small.sh link
git add -A; git commit -qm base
base="$(git rev-parse HEAD)"
python3 - <<'PY'
import re
s = open("big.sh").read()
s = s.replace('  local x=10\n', '  local x=100\n')
s = s.replace('  echo top2\n', '  echo top-two\n')
s = s.replace('one() { echo one; }', 'one() { echo ONE; }')
s = s.replace('middle\n', 'MIDDLE\n')
s = s.replace('line two\n', 'line 2\n')
s = s.replace('"huge 90 ', '"HUGE 90 ')
s = re.sub(r'# f30 does a thing\nf30\(\) \{\n.*?\n.*?\n\}\n', '', s)
open("big.sh", "w").write(s)
m = open("big.md").read()
m = m.replace("Body 7 ", "BODY 7 ").replace("still inside", "STILL inside").replace("- item 100 ", "- ITEM 100 ")
open("big.md", "w").write(m)
c = open("crlf.md", newline="").read(); open("crlf.md", "w", newline="").write(c.replace("Body 7 ", "BODY 7 "))
open("small.sh", "a").write("echo three\n")
open("nonl.txt", "w").write("a\nB\nno newline")
open("fences.md", "a").write("more\n")
t = open("old name.sh").read().replace('  local x=20\n', '  local x=200\n')
open("old name.sh", "w").write(t)
py = open("code.py").read().replace("return 40  #", "return 400  #")
open("code.py", "w").write(py)
open("mini.js", "w").write("var b=1;" * 9000 + "\n")
open("gen/out.txt", "w").write("regenerated\n")
open("bin.png", "wb").write(bytes(range(255, -1, -1)))
open("added small.sh", "w").write("echo added\n")
open("added-big.sh", "w").write(open("big.sh").read())
PY
git mv "old name.sh" "new name.sh"; git mv pure.sh pure-renamed.sh; chmod +x mode.sh; git rm -q gone.sh
rm link; ln -s nonl.txt link
git add -A; git commit -qm change
c1="$(git rev-parse HEAD)"
echo "===== WHOLE-DIFF ROUND (base...HEAD)"
"$here/pack.sh" "$base"
# fix-only round: one fix commit on top, touching big.sh only
python3 -c "
s=open('big.sh').read().replace('  local x=50\n','  local x=500\n'); open('big.sh','w').write(s)"
git commit -qam fix
echo "===== FIX-ONLY ROUND (c1...HEAD)"
"$here/pack.sh" "$c1"
echo "===== SWEEP (--sweep c1 -- big.sh small.sh gone.sh bin.png big.md)"
"$here/pack.sh" --sweep "$c1" -- big.sh small.sh gone.sh bin.png big.md
