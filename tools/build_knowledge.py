#!/usr/bin/env python3
"""Builds docs/knowledge/ for Factory918. Run from anywhere: python3 tools/build_knowledge.py

Sources, all inside this repository:

  docs/knowledge/core/*.md                 HAND-MAINTAINED. Edit these files directly. This script only
                                           refreshes the header line and the mini-TOC of each one in place,
                                           then copies PHILOSOPHY, MANUAL, DECISIONS and GLOSSARY (headers
                                           stripped) into template/docs/factory918/ for projects.
  docs/FACTORY-SPEC-v2.md                  -> docs/knowledge/spec/FACTORY-SPEC-v2/   (chunked by H2)
  research/superseded/FACTORY-SPEC-v1.md   -> docs/knowledge/spec/FACTORY-SPEC-v1/
  research/pages/*.md                      -> docs/knowledge/pages/
  research/notes/*.md                      -> docs/knowledge/notes/ and pages/pocock-planning-evidence.md

Everything under docs/knowledge/ except core/ is GENERATED. Never edit it; change the source and re-run.

Every output file is at most MAX_LINES lines and starts with
  <!-- lines: N | source: <logical name> | part i/n | title: ... -->
followed by a `## Contents` mini-TOC whose line numbers are for the Read tool's `offset`. INDEX.md lists
every file with its line count and when to read it. The `knowledge` skill depends on this shape.
"""
import re, shutil, sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "docs/knowledge"
CORE = OUT / "core"
RESEARCH = ROOT / "research"
MAX_LINES = 220


def rd(p: Path) -> str:
    return p.read_text()


# (output name, title, loader, when to read). core/ entries are handled in place, see build_core().
CORE_DOCS = [
    ("core/PHILOSOPHY.md", "Factory918: philosophy", "First. Whenever the spec is silent."),
    ("core/MANUAL.md", "Factory918: the manual", "How to run the loop; what the human does at each point."),
    ("core/DECISIONS.md", "Factory918: decisions", "Before overriding any vendored skill; these win."),
    ("core/GLOSSARY.md", "Factory918: glossary", "A term in AGENTS.md, a playbook or a ticket is unclear."),
    ("core/SCENARIO-TABLE.md", "Factory918: the scenario table", "Designing or reviewing anything with state: a file, exit codes, more than one actor."),
    ("core/CONVERSATION-DIGEST.md", "How Factory918 was arrived at", "Why something was chosen, historically; the corrections."),
]
SOURCES = [
    ("spec/FACTORY-SPEC-v2.md", "The Factory spec, v2", lambda: rd(ROOT / "docs/FACTORY-SPEC-v2.md"), "Building or updating the factory itself."),
    ("spec/FACTORY-SPEC-v1.md", "The Factory spec, v1 (superseded)", lambda: rd(RESEARCH / "superseded/FACTORY-SPEC-v1.md"), "Only to see what changed between drafts."),
    ("pages/four-skill-systems.md", "Four Skill Systems (reference page)", lambda: rd(RESEARCH / "pages/four-skill-systems.md"), "What Matt, Theo, pstack or Ras Mic do and why; the ten decisions."),
    ("pages/deterministic-layer.md", "The Deterministic Layer (reference page)", lambda: rd(RESEARCH / "pages/deterministic-layer.md"), "Lint, CI, hooks, review bots, verification; Theo's gates in order."),
    ("pages/pocock-planning-evidence.md", "Pocock Planning Evidence (brief)", lambda: rd(RESEARCH / "notes/5-matt-planning-evidence.md"), "Whether Matt's planning works in practice; real specs, tickets, failures."),
    ("notes/1-matt-pocock.md", "Research note: Matt Pocock", lambda: rd(RESEARCH / "notes/1-matt-pocock.md"), "Any Matt skill in depth."),
    ("notes/2-theo.md", "Research note: Theo", lambda: rd(RESEARCH / "notes/2-theo.md"), "Theo's AGENTS.md, skills, workflow, opinions."),
    ("notes/3-pstack.md", "Research note: pstack", lambda: rd(RESEARCH / "notes/3-pstack.md"), "Any pstack skill, playbook or principle in depth; the ports."),
    ("notes/4-ras-mic.md", "Research note: Ras Mic", lambda: rd(RESEARCH / "notes/4-ras-mic.md"), "Evidence-driven testing; loops."),
    ("notes/6-deterministic-layer.md", "Research note: deterministic layer (verbatim config)", lambda: rd(RESEARCH / "notes/6-deterministic-layer.md"), "Exact CI YAML, lint rules, hook scripts from the four sources."),
]


# ---- chunking -------------------------------------------------------------
def split_h2(text: str):
    lines = text.splitlines()
    parts, cur, title = [], [], None
    for ln in lines:
        if ln.startswith("## "):
            if cur:
                parts.append((title, cur))
            cur, title = [ln], ln[3:].strip()
        else:
            cur.append(ln)
    if cur:
        parts.append((title, cur))
    return parts


def split_long(lines, limit):
    """Split a section into pieces of at most `limit` lines, preferring H3 boundaries."""
    if len(lines) <= limit:
        return [lines]
    out, cur = [], []
    for ln in lines:
        if ln.startswith("### ") and len(cur) >= limit * 0.5:
            out.append(cur); cur = []
        cur.append(ln)
        if len(cur) >= limit:
            out.append(cur); cur = []
    if cur:
        out.append(cur)
    return out


def strip_header(text: str) -> str:
    """Remove a previously generated header block (comment line, blank, ## Contents, TOC lines, blank)."""
    lines = text.splitlines()
    if not lines or not lines[0].startswith("<!-- lines:"):
        return text
    i = 0
    while i < len(lines) and not lines[i].startswith("## Contents"):
        i += 1
    i += 1
    while i < len(lines) and lines[i].strip() != "":
        i += 1
    return "\n".join(lines[i + 1:]) + "\n"


def write_chunk(path: Path, lines, source, part, total, title):
    body = "\n".join(lines).rstrip() + "\n"
    toc_entries = []
    for i, ln in enumerate(body.splitlines()):
        if ln.startswith("## ") or ln.startswith("### "):
            toc_entries.append((ln.lstrip("# ").strip(), i))
    header = [f"<!-- lines: {{LINES}} | source: {source} | part {part}/{total} | title: {title} -->", "",
              "## Contents (line numbers are for the Read tool's offset)"]
    n_hdr = len(header) + len(toc_entries) + 1
    for name, i in toc_entries:
        header.append(f"- L{i + n_hdr + 1}: {name}")
    header.append("")
    total_lines = n_hdr + len(body.splitlines())
    header[0] = header[0].replace("{LINES}", str(total_lines))
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text("\n".join(header) + "\n" + body)
    return total_lines


# ---- build ----------------------------------------------------------------
def build_core(index_rows):
    slim = ROOT / "template/docs/factory918"
    for rel, title, when in CORE_DOCS:
        p = OUT / rel
        if not p.exists():
            sys.exit(f"missing hand-maintained core document: {p}")
        body = strip_header(p.read_text())
        if len(body.splitlines()) > MAX_LINES:
            sys.exit(f"{p} is over {MAX_LINES} lines; split it or raise MAX_LINES")
        n = write_chunk(p, body.splitlines(), rel, 1, 1, title)
        index_rows.append((rel, title, n, when))
        if p.name != "CONVERSATION-DIGEST.md":
            slim.mkdir(parents=True, exist_ok=True)
            (slim / p.name).write_text(body)


def build_generated(index_rows):
    for d in ["spec", "pages", "notes"]:          # generated trees are rebuilt from scratch; core/ is never touched
        shutil.rmtree(OUT / d, ignore_errors=True)
    for rel, title, loader, when in SOURCES:
        text = loader()
        if len(text.splitlines()) <= MAX_LINES:
            sections = [(None, text.splitlines())]
        else:
            sections = split_h2(text)
        pieces = []
        for sec_title, sec_lines in sections:
            for piece in split_long(sec_lines, MAX_LINES):
                pieces.append((sec_title or "(preamble)", piece))
        total = len(pieces)
        stem = Path(rel).with_suffix("")
        if total == 1:
            n = write_chunk(OUT / rel, pieces[0][1], rel, 1, 1, title)
            index_rows.append((rel, title, n, when))
        else:
            for k, (sec_title, piece) in enumerate(pieces, 1):
                slug = re.sub(r"[^a-z0-9]+", "-", sec_title.lower()).strip("-")[:48] or "part"
                p = OUT / stem / f"{k:02d}-{slug}.md"
                n = write_chunk(p, piece, rel, k, total, f"{title} — {sec_title}")
                index_rows.append((str(p.relative_to(OUT)), f"{title} — {sec_title}", n, when))


def write_index(index_rows):
    idx = ["# Factory918 knowledge base: index", "",
           "Read this file first; then grep; then read one section by range. Never read a file over 200 lines without `offset`/`limit`.",
           "The literal transcript of the conversation that produced this system is not available; `core/CONVERSATION-DIGEST.md` is the substitute.", "",
           "| file | what | lines | read when |", "|---|---|---|---|"]
    for rel, title, n, when in index_rows:
        idx.append(f"| `{rel}` | {title} | {n} | {when} |")
    idx.append("")
    idx.append(f"{len(index_rows)} files. `core/` is hand-maintained; everything else here is generated. Regenerate with `python3 tools/build_knowledge.py` after editing a core document, the spec, or anything under `research/`.")
    (OUT / "INDEX.md").write_text("\n".join(idx) + "\n")


if __name__ == "__main__":
    rows = []
    build_core(rows)
    build_generated(rows)
    write_index(rows)
    print("knowledge files:", len(rows), "→", OUT.relative_to(ROOT))
