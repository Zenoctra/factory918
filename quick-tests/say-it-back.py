#!/usr/bin/env python3
"""Say it back: fresh readers read a brief and state the task, what done means
and what they may change. Did they all read it the same way, and the way the
writer meant? (#153 decision 3.)

    say-it-back.py --brief before=old.md --brief after=new.md [--intent intent.md]
                   [--readers 5] [--at COMMIT] [--tools read|none] [--out DIR]
    say-it-back.py --from-agent AGENT_ID --at COMMIT [...]

Each reader is a fresh Claude Code session that gets the brief as its first
message, exactly as a lane would, plus an instruction not to do the task but to
say back how it reads it. Readers may open files in a read-only box (a copy of
the repository at --at); they cannot run or change anything. One blind judge
then groups the readings field by field and, when --intent is given, checks
each reading against what the writer meant.
"""

from __future__ import annotations

import argparse
import json
import random
import sys
from collections import Counter, defaultdict
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent / "lib"))
import qtlib as q  # noqa: E402

FIELDS = ["task", "done", "may_change", "must_not"]

SAY_BACK = """\
The user message is a task someone is about to hand you. Do not carry it out. Right now your only job is to say back how you read it, so its writer can see whether it says what they meant.

{tools_line}

Answer in your own words; do not copy sentences from the message.
- task: what you are being asked to do, in one to three sentences.
- done: what must be true when you are finished, and what you hand back and where.
- may_change: what you are allowed to create, edit, run or post.
- must_not: what you must not read, touch or do.
- unsettled: each choice the message leaves to you that you would have to make yourself to finish, one per entry. Empty if none.
- questions: what you would ask the writer before starting, if you could, one per entry. Empty if nothing.
"""

TOOLS_LINE = {
    "read": "You may open files and search the repository to understand the task. Change nothing and run nothing.",
    "none": "You cannot open any file. Read only the message.",
}

READER_SCHEMA = {
    "type": "object",
    "properties": {
        "task": {"type": "string"},
        "done": {"type": "string"},
        "may_change": {"type": "string"},
        "must_not": {"type": "string"},
        "unsettled": {"type": "array", "items": {"type": "string"}},
        "questions": {"type": "array", "items": {"type": "string"}},
    },
    "required": ["task", "done", "may_change", "must_not", "unsettled", "questions"],
}

JUDGE_SCHEMA = {
    "type": "object",
    "properties": {
        "fields": {
            "type": "object",
            "properties": {f: {"type": "array", "items": {
                "type": "object",
                "properties": {"reading": {"type": "string"}, "members": {"type": "array", "items": {"type": "string"}}},
                "required": ["reading", "members"]}} for f in FIELDS},
            "required": FIELDS,
        },
        "unsettled": {"type": "array", "items": {
            "type": "object",
            "properties": {"choice": {"type": "string"}, "members": {"type": "array", "items": {"type": "string"}}},
            "required": ["choice", "members"]}},
        "intent": {"type": "array", "items": {
            "type": "object",
            "properties": {"id": {"type": "string"},
                           **{f: {"type": "string", "enum": ["match", "partial", "miss"]} for f in FIELDS},
                           "note": {"type": "string"}},
            "required": ["id", *FIELDS, "note"]}},
    },
    "required": ["fields", "unsettled", "intent"],
}

JUDGE_PROMPT = """\
Several readers each read a task description and said back, in their own words, how they understood it. Their readings are below, each under an id. Some readers may have read different versions of the description; you are not told which.

For each of the four fields (task, done, may_change, must_not), sort the readers into groups that understood that field the same way. Two readings belong together when acting on either would lead to the same work and the same limits; wording does not matter, a difference in what would be done or allowed does. Give each group a one-sentence statement of that reading. Every id appears in exactly one group per field.

Then list the distinct "unsettled" choices the readers raised, merging ones that are the same choice, with the ids of the readers who raised each.

{intent_block}

READINGS

{readings}
"""

INTENT_BLOCK = """\
Finally, the writer's own statement of what they meant is below. For each reader and each field, say "match" if the reading would lead to the work and limits the writer meant, "partial" if it gets some of it or adds something the writer did not mean, "miss" if it would lead somewhere else. Add one short note per reader naming the most important difference, or "none".

WHAT THE WRITER MEANT

{intent}
"""

NO_INTENT = 'No statement of the writer\'s intent was given: return "intent" as an empty list.'


def parse_args():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--brief", action="append", default=[], metavar="NAME=FILE",
                    help="a brief variant; repeat to compare variants")
    ap.add_argument("--from-agent", help="take the brief from a past subagent's first message (agent id or path)")
    ap.add_argument("--intent", help="file stating what the writer meant: task, done, may change, must not")
    ap.add_argument("--readers", type=int, default=5, help="readers per variant (default 5)")
    ap.add_argument("--at", help="commit the readers' repository is at (default: origin/main)")
    ap.add_argument("--tools", choices=["read", "none"], default="read")
    ap.add_argument("--model", default="claude-opus-5-5")
    ap.add_argument("--effort", default="medium")
    ap.add_argument("--judge-model", default="claude-opus-5-5")
    ap.add_argument("--judge-effort", default="high")
    ap.add_argument("--system-prompt-file", default=str(q.KIT / "lib" / "lane-system-prompt.txt"),
                    help="the lane's system prompt the reader runs under (default: a general-purpose lane's)")
    ap.add_argument("--parallel", type=int, default=5)
    ap.add_argument("--seed", type=int, default=None, help="seed for the blind ids (default: random, recorded)")
    ap.add_argument("--out", help="output directory (default: quick-tests/trials/say-it-back-<stamp>)")
    return ap.parse_args()


def main():
    a = parse_args()
    out = Path(a.out) if a.out else q.KIT / "trials" / f"say-it-back-{q.now_stamp()}"
    out.mkdir(parents=True, exist_ok=True)
    commit = a.at or "origin/main"
    box = q.make_box(q.new_box_path("r"), commit)
    mapping = q.default_mapping(box)

    variants: dict[str, str] = {}
    for spec in a.brief:
        name, _, path = spec.partition("=")
        variants[name] = Path(path).read_text()
    if a.from_agent:
        t = q.find_agent_transcript(a.from_agent)
        rows = q.load_rows(t)
        variants.setdefault("original", q.first_user_text(rows))
        mapping += q.scratchpad_mapping(variants["original"], box)
    if not variants:
        sys.exit("give at least one --brief NAME=FILE or --from-agent")
    variants = {k: q.remap(v, mapping) for k, v in variants.items()}
    for k, v in variants.items():
        (out / f"brief.{k}.md").write_text(v)

    system_prompt = Path(a.system_prompt_file).read_text()
    append = SAY_BACK.format(tools_line=TOOLS_LINE[a.tools])
    tools = q.READ_TOOLS if a.tools == "read" else []

    before = q.safety_preamble()
    jobs, keys = [], []
    for name, text in variants.items():
        for i in range(1, a.readers + 1):
            rdir = out / "readers" / f"{name}-{i}"
            keys.append((name, i, rdir))
            jobs.append(lambda text=text, rdir=rdir: q.run_claude(
                box, text, rdir, mode="read", tools=tools, model=a.model, effort=a.effort,
                system_prompt=system_prompt, append_system_prompt=append, json_schema=READER_SCHEMA,
                hooks=False))
    print(f"{len(jobs)} readers ({len(variants)} variant(s) x {a.readers}), box {box.root}", flush=True)
    results = q.run_many(jobs, a.parallel)
    problems = q.safety_verdict(before, out)
    q.shutil.rmtree(box.root, ignore_errors=True)

    readings = []
    for (name, i, rdir), r in zip(keys, results):
        if r.structured:
            readings.append({"variant": name, "reader": i, "dir": str(rdir.relative_to(out)), **r.structured,
                             "cost_usd": r.cost_usd, "duration_s": r.duration_s,
                             "files_opened": [c["input"].get("file_path") or c["input"].get("pattern")
                                              for c in r.tool_calls]})
        else:
            print(f"reader {name}-{i} gave no reading: {r.error}", flush=True)
    q.write_json(out / "readings.json", readings)

    # One blind judge over every reading of every variant.
    seed = a.seed if a.seed is not None else random.randrange(10**6)
    ids = q.blind_ids(len(readings), seed)
    for rd, bid in zip(readings, ids):
        rd["blind_id"] = bid
    q.write_json(out / "blind-key.json", {"seed": seed, "ids": {rd["blind_id"]: f'{rd["variant"]}-{rd["reader"]}' for rd in readings}})
    blocks = []
    for rd in sorted(readings, key=lambda r: r["blind_id"]):
        blocks.append(f"[{rd['blind_id']}]\n" + "\n".join(
            f"{f}: {rd[f]}" for f in FIELDS) + "\nunsettled: " + json.dumps(rd["unsettled"], ensure_ascii=False))
    intent = Path(a.intent).read_text() if a.intent else None
    prompt = JUDGE_PROMPT.format(
        intent_block=INTENT_BLOCK.format(intent=intent) if intent else NO_INTENT,
        readings="\n\n".join(blocks))
    verdict = q.judge(prompt, JUDGE_SCHEMA, out / "judge", model=a.judge_model, effort=a.judge_effort)
    q.write_json(out / "judge.json", verdict)

    write_report(out, a, variants, readings, verdict, intent, problems)
    write_judged_items(out, readings, verdict, intent)
    print(f"report: {out / 'report.md'}")
    if problems:
        print("SAFETY PROBLEMS:\n" + "\n".join(problems))
        sys.exit(1)


def write_report(out, a, variants, readings, verdict, intent, problems):
    by_id = {rd["blind_id"]: rd for rd in readings}
    names = list(variants)
    L = [f"# Say it back: {', '.join(names)}", ""]
    L += [f"Readers per variant: {a.readers}. Reader model: {a.model} at {a.effort}; tools: {a.tools}. "
          f"Judge: {a.judge_model} at {a.judge_effort}, blind to variants. Repository at `{a.at or 'origin/main'}`.", ""]
    total = sum(rd["cost_usd"] for rd in readings)
    L += [f"Reader cost in API-rate terms: ${total:.2f} (usage on the subscription, not a bill). "
          f"Safety check: {'no problems' if not problems else 'PROBLEMS: ' + '; '.join(problems)}.", ""]

    L += ["## Agreement", "",
          "For each field, how many different readings the judge found per variant, and the share of readers in the largest group. One reading at 100% means every reader understood that field the same way.", ""]
    L += ["| Field | " + " | ".join(names) + " |", "|---|" + "---|" * len(names)]
    for f in FIELDS:
        cells = []
        for n in names:
            groups = Counter()
            for gi, g in enumerate(verdict["fields"][f]):
                for m in g["members"]:
                    if m in by_id and by_id[m]["variant"] == n:
                        groups[gi] += 1
            count = sum(groups.values())
            cells.append(f"{len(groups)} reading(s), largest {100 * max(groups.values()) // count}%" if count else "-")
        L.append(f"| {f} | " + " | ".join(cells) + " |")
    L.append("")

    if intent:
        L += ["## Against what the writer meant", "",
              "Share of readers whose reading the judge marked match / partial / miss.", ""]
        L += ["| Field | " + " | ".join(names) + " |", "|---|" + "---|" * len(names)]
        im = {x["id"]: x for x in verdict.get("intent", [])}
        for f in FIELDS:
            cells = []
            for n in names:
                c = Counter(im[rd["blind_id"]][f] for rd in readings if rd["variant"] == n and rd["blind_id"] in im)
                k = sum(c.values()) or 1
                cells.append(" / ".join(f"{100 * c[x] // k}%" for x in ("match", "partial", "miss")))
            L.append(f"| {f} | " + " | ".join(cells) + " |")
        L.append("")
        L += ["Notes per reader:", ""]
        for rd in sorted(readings, key=lambda r: (r["variant"], r["reader"])):
            x = im.get(rd["blind_id"])
            if x:
                L.append(f"- {rd['variant']}-{rd['reader']}: {x['note']}")
        L.append("")

    L += ["## The readings, grouped", ""]
    for f in FIELDS:
        L += [f"### {f}", ""]
        for g in verdict["fields"][f]:
            per = Counter(by_id[m]["variant"] for m in g["members"] if m in by_id)
            L.append(f"- {g['reading']} ({', '.join(f'{n}: {per[n]}' for n in names)})")
        L.append("")

    L += ["## Choices the readers said the brief leaves open", ""]
    for u in verdict["unsettled"]:
        per = Counter(by_id[m]["variant"] for m in u["members"] if m in by_id)
        L.append(f"- {u['choice']} ({', '.join(f'{n}: {per[n]}' for n in names)})")
    L.append("")

    L += ["## Questions the readers would ask", ""]
    for rd in sorted(readings, key=lambda r: (r["variant"], r["reader"])):
        for qq in rd["questions"]:
            L.append(f"- {rd['variant']}-{rd['reader']}: {qq}")
    L.append("")
    L += ["## Files", "",
          "- `brief.<variant>.md`: each brief as the readers got it (paths remapped into the box).",
          "- `readers/<variant>-<n>/`: each reader's prompt, settings, full event stream and structured reading.",
          "- `readings.json`, `judge.json`, `blind-key.json`: the readings, the judge's raw verdict, and which blind id was which reader.",
          "- `judged-items.jsonl`: the judge's calls, one per line, for `judge-agreement.py`.", ""]
    (out / "report.md").write_text("\n".join(L))


def write_judged_items(out, readings, verdict, intent):
    """Each intent call (reader x field) is one item a person can label to check the judge."""
    if not intent:
        return
    im = {x["id"]: x for x in verdict.get("intent", [])}
    with open(out / "judged-items.jsonl", "w") as fh:
        for rd in readings:
            x = im.get(rd["blind_id"])
            if not x:
                continue
            for f in FIELDS:
                fh.write(json.dumps({
                    "item": f"{rd['blind_id']}:{f}",
                    "question": f"Does this reading of '{f}' lead to the work and limits the writer meant? match / partial / miss",
                    "material": f"WHAT THE WRITER MEANT:\n{intent}\n\nTHE READING ({f}):\n{rd[f]}",
                    "choices": ["match", "partial", "miss"],
                    "judge": x[f],
                }, ensure_ascii=False) + "\n")


if __name__ == "__main__":
    main()
