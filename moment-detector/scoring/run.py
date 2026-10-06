"""Run detector variants over a split of the scoring universe, through the hook's own code.

    python3 moment-detector/scoring/run.py VARIANT [VARIANT ...] --split dev [--reps 1] [--jobs 8] [--retry-errors] [--ids FILE]
    python3 moment-detector/scoring/run.py --list

A variant is a named set of `--set` overrides in variants.json, applied in order:
`base`, the variant's slice, its answer format, then its own `set`. A variant
with `examples_cv` gets labelled examples drawn from dev messages in other
session groups than the one being checked (cross-validation by group; on the
test split, from all of dev); they hold Manuel's words, so they are written
under .scratch and never committed. For each
clean item in the split, the run cuts the session with `md.make_case` and runs
`md.check`, the function the hook calls; an item the hook would skip is
recorded as skipped, with no call. Records go to
.scratch/moment-detector/scoring/runs/VARIANT.jsonl (they hold Manuel's words).
A rerun does only the (item, rep) pairs that are missing, so an interrupted
run resumes; `--retry-errors` also reruns failed checks (a timeout or an
off-scale answer), replacing them in the score. The test split runs only with --final.
"""

from __future__ import annotations

import argparse
import concurrent.futures as cf
import hashlib
import json
import random
import sys
import threading
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE.parent / "hook"))
import md  # noqa: E402
from prepare import OUT  # noqa: E402
from label import DEFAULT_DIR  # noqa: E402

RUNS = OUT / "runs"


def load_variants() -> dict:
    return json.loads((HERE / "variants.json").read_text())


def overrides(name: str, spec: dict | None = None) -> list[str]:
    spec = spec or load_variants()
    v = spec["variants"][name]
    fmt = spec["formats"][v["format"]]
    return [*spec["base"], *spec["slices"][v["slice"]],
            f"threshold={json.dumps(fmt['threshold'])}", f"answer_format={fmt['answer_format']}", *v["set"]]


def load_jsonl(path: Path) -> list[dict]:
    return [json.loads(line) for line in open(path)] if path.exists() else []


ONLY: set[str] | None = None  # --ids: run only these items (the ones whose label changed, say)


def items_in(split: str) -> list[dict]:
    return [i for i in load_jsonl(OUT / "items.jsonl")
            if i["split"] == split and not i["unclear"] and (ONLY is None or i["id"] in ONLY)]


def fold_of(group: str, folds: int) -> int:
    return int(hashlib.sha256(group.encode()).hexdigest()[:8], 16) % folds


def render_example(n: int, item: dict, session: dict, label: dict, fmt: str) -> str:
    def tail(s: str, k: int) -> str:
        return s if len(s) <= k else "[...]" + s[-k:]
    if fmt == "bool":
        answer = {"moment": item["correction"], "cue": label["evidence"] if item["correction"] else "",
                  "confidence": "high"}
    else:
        answer = {"score": 9 if item["correction"] else 2, "cue": label["evidence"] if item["correction"] else ""}
    return (f"Example {n}.\n<agent_last_reply>\n{tail(session['session']['last_reply'], 600) or '(none)'}\n</agent_last_reply>\n"
            f"<new_user_message>\n{tail(session['prompt'], 800)}\n</new_user_message>\n"
            f"Answer: {json.dumps(answer, ensure_ascii=False)}")


def examples_file(name: str, cv: dict, fmt: str, pool: list[dict], sessions: dict, tag: str) -> str:
    """A balanced, shuffled set of examples from `pool`: half corrections (a third of them quiet),
    half not (two thirds near misses)."""
    lib = {r["id"]: r for r in load_jsonl(DEFAULT_DIR / "library.jsonl")}
    rng = random.Random(f"{cv.get('seed', 0)}:{tag}")
    half = cv["per_fold"] // 2
    pos = [i for i in pool if i["correction"]]
    neg = [i for i in pool if not i["correction"]]
    quiet = [i for i in pos if i["surface"] == "quiet"]
    near = [i for i in neg if i["near_miss"]]
    pick_q = rng.sample(quiet, min(len(quiet), half // 3))
    pick_p = pick_q + rng.sample([i for i in pos if i not in pick_q], half - len(pick_q))
    pick_nm = rng.sample(near, min(len(near), 2 * half // 3))
    pick_n = pick_nm + rng.sample([i for i in neg if i not in pick_nm], half - len(pick_nm))
    chosen = pick_p + pick_n
    rng.shuffle(chosen)
    text = "\n\n".join(render_example(k + 1, i, sessions[i["id"]], lib[i["id"]], fmt) for k, i in enumerate(chosen))
    path = OUT / "examples" / f"{name}-{tag}.md"
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text("These are earlier messages from the same user, labelled.\n\n" + text + "\n")
    return str(path)


def moments_for_items(name: str, split: str, sessions: dict) -> dict[str, dict]:
    """The configured moment each item is checked with: one for all, or one per fold under examples_cv."""
    spec = load_variants()
    v = spec["variants"][name]
    m = md.load_moment("correction", overrides(name, spec))
    cv = v.get("examples_cv")
    items = items_in(split)
    if not cv:
        return {i["id"]: m for i in items}
    dev = [i for i in items_in("dev") if not i["skip"]]
    if split == "test":
        mt = dict(m, examples=examples_file(name, cv, v["format"], dev, sessions, "all-dev"))
        return {i["id"]: mt for i in items}
    per_fold = {f: dict(m, examples=examples_file(name, cv, v["format"],
                                                  [i for i in dev if fold_of(i["group"], cv["folds"]) != f],
                                                  sessions, f"fold{f}"))
                for f in range(cv["folds"])}
    return {i["id"]: per_fold[fold_of(i["group"], cv["folds"])] for i in items}


def run(name: str, split: str, reps: int, jobs: int, retry_errors: bool) -> None:
    sessions = {s["id"]: s for s in load_jsonl(OUT / "sessions.jsonl")}
    by_item = moments_for_items(name, split, sessions)
    path = RUNS / f"{name}.jsonl"
    done = {(r["item"], r["rep"]) for r in load_jsonl(path) if not (retry_errors and r.get("error"))}
    todo = [(i, rep) for rep in range(reps) for i in items_in(split) if (i["id"], rep) not in done]
    print(f"{name}: {len(todo)} checks to run on {split}", flush=True)
    lock = threading.Lock()
    path.parent.mkdir(parents=True, exist_ok=True)

    def one(job: tuple[dict, int]) -> None:
        item, rep = job
        m = by_item[item["id"]]
        if item["skip"]:
            rec = {"id": None, "moment": "correction", "skipped": item["skip"], "delivered": False}
        else:
            s = sessions[item["id"]]
            rec = md.check(m, md.make_case(s["prompt"], s["session"], m.get("slice", {})), {"event": "offline"})
        rec.update(item=item["id"], rep=rep, split=split, variant=name)
        with lock, open(path, "a", encoding="utf-8") as f:
            f.write(json.dumps(rec, ensure_ascii=False) + "\n")

    with cf.ThreadPoolExecutor(max_workers=jobs) as pool:
        for n, _ in enumerate(pool.map(one, todo), 1):
            if n % 50 == 0:
                print(f"  {name}: {n}/{len(todo)}", flush=True)


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__.split("\n\n")[0])
    ap.add_argument("variants", nargs="*")
    ap.add_argument("--split", choices=["dev", "test"], default="dev")
    ap.add_argument("--final", action="store_true", help="allow the frozen test split")
    ap.add_argument("--reps", type=int, default=1)
    ap.add_argument("--jobs", type=int, default=8)
    ap.add_argument("--retry-errors", action="store_true")
    ap.add_argument("--ids", type=Path, help="a file of item ids, one per line: run only these")
    ap.add_argument("--list", action="store_true")
    args = ap.parse_args()
    global ONLY
    ONLY = set(args.ids.read_text().split()) if args.ids else None
    spec = load_variants()
    if args.list:
        for name, v in spec["variants"].items():
            print(f"{name:12} stage {v['stage']}  {v['about']}")
        return
    if args.split == "test" and not args.final:
        sys.exit("the test split is frozen until the final stage; pass --final for the finalists only")
    unknown = [v for v in args.variants if v not in spec["variants"]]
    if unknown:
        sys.exit(f"unknown variants: {unknown}")
    for name in args.variants:
        run(name, args.split, args.reps, args.jobs, args.retry_errors)


if __name__ == "__main__":
    main()
