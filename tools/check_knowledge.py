#!/usr/bin/env python3
"""Check docs/knowledge/: INDEX.md lists every file with its true line count, no chunk exceeds
240 lines, every mini-TOC entry names the heading on the line it points to, and every Provisional id
in core/DECISIONS.md is P<ticket> with an optional b-z sibling letter and used once. Exit 1 on any miss."""
import pathlib, re, sys

PROVISIONAL_ID = re.compile(r"P[0-9]+[b-z]?")


def provisional_problems(text):
    """The id cell of each row under `## Provisional` is the text between its first two pipes. The id
    comes from the ticket, so two lanes cannot pick the same one; this catches a pair the moment their
    branches meet, and an off-form id before that. Reading no row at all is a problem too, so a
    reshaped section cannot pass by being skipped."""
    ids, problems, section = {}, [], False
    for n, line in enumerate(text.split("\n"), 1):
        if line.startswith("## "):
            section = line.startswith("## Provisional")
        if not section or not line.startswith("|"):
            continue
        cell = line.split("|")[1].strip()
        if cell == "#" or (cell and not cell.strip("-: ")):
            continue
        if not PROVISIONAL_ID.fullmatch(cell):
            problems.append(f"DECISIONS.md line {n}: Provisional id '{cell}' is not P<ticket> with an optional b-z sibling letter")
        elif cell in ids:
            problems.append(f"DECISIONS.md line {n}: Provisional id {cell} is already on line {ids[cell]}; an id comes from its ticket (P<ticket>, then b, c, ... for a second row of the same ticket), so rename this row and its mentions")
        else:
            ids[cell] = n
    if not ids and not problems:
        problems.append("DECISIONS.md: no Provisional row was read; the '## Provisional' section is missing or its table changed shape")
    return problems


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
problems += provisional_problems((kb / "core" / "DECISIONS.md").read_text())
print("\n".join(problems) if problems else f"knowledge ok: {len(files)} files")
sys.exit(1 if problems else 0)
