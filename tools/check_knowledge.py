#!/usr/bin/env python3
"""Check docs/knowledge/: INDEX.md lists every file with its true line count, no chunk exceeds
240 lines, and every mini-TOC entry names the heading on the line it points to. Exit 1 on any miss."""
import pathlib, re, sys

kb = pathlib.Path(__file__).resolve().parent.parent / "docs" / "knowledge"
index = (kb / "INDEX.md").read_text()
rows = {f: int(n) for f, n in re.findall(r"^\| `([^`]+)` \| .*? \| (\d+) \| ", index, re.M)}
files = sorted(p.relative_to(kb).as_posix() for p in kb.rglob("*.md") if p.name != "INDEX.md")
problems = []
for f in files:
    lines = (kb / f).read_text().split("\n")
    count = sum(1 for _ in open(kb / f))
    if f not in rows: problems.append(f"{f}: not in INDEX.md")
    elif rows[f] != count: problems.append(f"{f}: INDEX says {rows[f]} lines, file has {count}")
    if count > 240: problems.append(f"{f}: {count} lines, over the 240 cap")
    for m in re.finditer(r"^- L(\d+): (.+)$", "\n".join(lines[:60]), re.M):
        n, name = int(m.group(1)), m.group(2).strip()
        target = lines[n - 1] if n - 1 < len(lines) else ""
        if not (target.startswith("#") and target.lstrip("# ").strip() == name):
            problems.append(f"{f}: TOC says L{n} is '{name}', line {n} is '{target[:40]}'")
for f in rows:
    if f not in files: problems.append(f"INDEX.md lists {f}, which does not exist")
print("\n".join(problems) if problems else f"knowledge ok: {len(files)} files")
sys.exit(1 if problems else 0)
