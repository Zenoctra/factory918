#!/usr/bin/env python3
"""How far the judge agrees with Manuel (#153 decision 8: he labels about 20
items once, so the judge's agreement with him is known before it is trusted).

    judge-agreement.py sheet RESULT_DIR [RESULT_DIR ...] [--n 20] [--out sheet.md]
    judge-agreement.py score sheet.md

`sheet` samples items from the judged-items.jsonl files the tools write and
makes a Markdown sheet with each item's question, its material and an empty
answer line; the judge's own answers go to a separate key file next to it, so
the person labelling does not see them. `score` reads the filled sheet and the
key, and prints the agreement, Cohen's kappa and every disagreement.
"""

from __future__ import annotations

import argparse
import json
import random
import re
import sys
from collections import Counter
from pathlib import Path


def cmd_sheet(a):
    items = []
    for d in a.dirs:
        for f in Path(d).rglob("judged-items.jsonl"):
            for line in f.read_text().splitlines():
                if line.strip():
                    it = json.loads(line)
                    it["source"] = str(f)
                    items.append(it)
    if not items:
        sys.exit("no judged-items.jsonl under the given directories")
    rng = random.Random(a.seed)
    pick = rng.sample(items, min(a.n, len(items)))
    out = Path(a.out)
    L = ["# Labels for the judge check", "",
         "For each item, read the material and write your answer after `Answer:` (one of the choices). "
         "Leave an item blank to skip it. The judge's answers are in the key file beside this one: "
         "do not open it until you are done.", ""]
    key = {}
    for k, it in enumerate(pick, 1):
        L += [f"## Item {k}", "", f"Question: {it['question']}", "", "Material:", "", "```", it["material"].strip(), "```", "",
              f"Choices: {', '.join(it['choices'])}", "", "Answer: ", ""]
        key[str(k)] = {"judge": it["judge"], "item": it["item"], "source": it["source"], "choices": it["choices"]}
    out.write_text("\n".join(L))
    out.with_suffix(".key.json").write_text(json.dumps(key, indent=2))
    print(f"sheet: {out}\nkey:   {out.with_suffix('.key.json')} ({len(pick)} items of {len(items)})")


def cmd_score(a):
    sheet = Path(a.sheet)
    key = json.loads(sheet.with_suffix(".key.json").read_text())
    answers = {}
    for m in re.finditer(r"^## Item (\d+)\n.*?^Answer:[ \t]*(\S*)", sheet.read_text(), re.S | re.M):
        if m.group(2):
            answers[m.group(1)] = m.group(2).strip()
    pairs = [(answers[k], v["judge"]) for k, v in key.items() if k in answers]
    if not pairs:
        sys.exit("no answers filled in yet")
    agree = sum(1 for h, j in pairs if h == j)
    n = len(pairs)
    po = agree / n
    ch, cj = Counter(h for h, _ in pairs), Counter(j for _, j in pairs)
    pe = sum(ch[c] * cj[c] for c in set(ch) | set(cj)) / (n * n)
    kappa = (po - pe) / (1 - pe) if pe < 1 else 1.0
    print(f"labelled: {n}; agreement: {agree}/{n} = {po:.0%}; Cohen's kappa: {kappa:.2f}")
    for k, v in key.items():
        if k in answers and answers[k] != v["judge"]:
            print(f"  item {k}: person {answers[k]}, judge {v['judge']}  ({v['item']}, {v['source']})")


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = ap.add_subparsers(dest="cmd", required=True)
    s = sub.add_parser("sheet")
    s.add_argument("dirs", nargs="+")
    s.add_argument("--n", type=int, default=20)
    s.add_argument("--seed", type=int, default=0)
    s.add_argument("--out", default="labels.md")
    c = sub.add_parser("score")
    c.add_argument("sheet")
    a = ap.parse_args()
    {"sheet": cmd_sheet, "score": cmd_score}[a.cmd](a)


if __name__ == "__main__":
    main()
