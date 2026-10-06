"""Build the scoring universe from the library: one item per message, its split,
and the session as the hook would have read it there.

    python3 moment-detector/scoring/prepare.py [--library DIR/library.jsonl]

Writes, under the main checkout's .scratch/moment-detector/scoring/ (they hold
Manuel's words or point at them, so they are never committed):

- items.jsonl: one row per message the scoring set counts once (re-sent copies
  folded, unclear rows kept and flagged), with its label fields, its session
  group, its split, and whether the hook would call a model on it.
- sessions.jsonl: per item, the prompt and the session (`md.read_session`) at
  that message, which a variant cuts with `md.make_case`.

The split is a rule, not a list: a session group goes to `test` when the salted
hash of its key falls under TEST_SHARE. A group is the sessions joined by
re-sent messages (a fork or a rewind repeats context across session files).
Any message that joins later, such as an unclear one Manuel rules on, lands in
its session's split, so nothing crosses over. SALT was the first salt, counting
from 0, whose test split held 27 to 33% of the clean items, of the corrections,
of the quiet corrections, of the near misses and of the unclear items; no
prediction was looked at. The test ids' hash is checked against FROZEN_SHA so
the split cannot drift silently.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import re
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE.parent / "hook"))
sys.path.insert(0, str(HERE.parent / "moments"))
import md  # noqa: E402
from label import DEFAULT_DIR  # noqa: E402
from library import scoring_rows  # noqa: E402

OUT = DEFAULT_DIR.parent / "scoring"
PROJECTS = Path.home() / ".claude" / "projects"
TEST_SHARE = 0.30
SALT = 310
FROZEN_SHA = "714e488f27c7"


def groups(rows: list[dict]) -> dict[str, str]:
    """Session id -> group key (the smallest session id joined to it by re-sent messages)."""
    parent: dict[str, str] = {}

    def find(s: str) -> str:
        parent.setdefault(s, s)
        while parent[s] != s:
            parent[s] = parent[parent[s]]
            s = parent[s]
        return s

    by_id = {r["id"]: r for r in rows}
    for r in rows:
        find(r["session_id"])
        if r["resend_of"] in by_id:
            a, b = find(r["session_id"]), find(by_id[r["resend_of"]]["session_id"])
            parent[max(a, b)] = min(a, b)
    return {s: find(s) for s in parent}


def split_of(group: str, salt: int) -> str:
    h = int(hashlib.sha256(f"{salt}:{group}".encode()).hexdigest()[:8], 16) / 0xFFFFFFFF
    return "test" if h < TEST_SHARE else "dev"


def balanced(items: list[dict], salt: int) -> bool:
    strata = {
        "clean": lambda i: not i["unclear"],
        "corrections": lambda i: not i["unclear"] and i["correction"],
        "quiet": lambda i: not i["unclear"] and i["correction"] and i["surface"] == "quiet",
        "near misses": lambda i: not i["unclear"] and not i["correction"] and i["near_miss"],
        "unclear": lambda i: i["unclear"],
    }
    for keep in strata.values():
        sub = [i for i in items if keep(i)]
        share = sum(split_of(i["group"], salt) == "test" for i in sub) / len(sub)
        if not 0.27 <= share <= 0.33:
            return False
    return True


def test_sha(items: list[dict]) -> str:
    ids = sorted(i["id"] for i in items if i["split"] == "test")
    return hashlib.sha256("\n".join(ids).encode()).hexdigest()[:12]


def hook_gate(m: dict, delivery: str, prompt: str, session: dict) -> str | None:
    """Why the hook would not call a model on this message, as `md.cmd_hook` decides it."""
    if delivery == "ask_answer":
        return "an answer to AskUserQuestion is a tool result; UserPromptSubmit does not fire"
    if m.get("skip_first_message") and not session["previous_user"]:
        return "first message of the session"
    return next((f"prompt matches {p!r}" for p in m.get("skip_prompt_patterns", []) if re.search(p, prompt)), None)


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__.split("\n\n")[0])
    ap.add_argument("--library", type=Path, default=DEFAULT_DIR / "library.jsonl")
    ap.add_argument("--find-salt", action="store_true", help="print the first balanced salt and stop")
    args = ap.parse_args()

    rows = [json.loads(line) for line in open(args.library)]
    group = groups(rows)
    keep = ("id", "session_id", "project", "uuid", "delivery", "starts_session", "correction", "unclear",
            "surface", "near_miss", "kind", "hard_case", "ruled_by_manuel", "second_correction")
    items = [{k: r[k] for k in keep} | {"group": group[r["session_id"]]}
             for r in scoring_rows(rows, include_unclear=True)]
    if args.find_salt:
        print(next(s for s in range(10_000) if balanced(items, s)))
        return
    for i in items:
        i["split"] = split_of(i["group"], SALT)
    if test_sha(items) != FROZEN_SHA:
        sys.exit(f"the test split's ids hash to {test_sha(items)}, not the frozen {FROZEN_SHA}; "
                 "the library or the rule changed. A ruled unclear message keeps its session's split, "
                 "so only a new session or a changed group moves it: look before re-freezing.")

    m = md.load_moment("correction")
    OUT.mkdir(parents=True, exist_ok=True)
    with open(OUT / "items.jsonl", "w") as fi, open(OUT / "sessions.jsonl", "w") as fs:
        for i in items:
            transcript = PROJECTS / i["project"] / f"{i['session_id']}.jsonl"
            prompt, session = md.session_at(str(transcript), i["uuid"])
            i["skip"] = hook_gate(m, i["delivery"], prompt, session)
            fi.write(json.dumps(i) + "\n")
            fs.write(json.dumps({"id": i["id"], "prompt": prompt, "session": session}, ensure_ascii=False) + "\n")

    clean = [i for i in items if not i["unclear"]]
    for name in ("dev", "test"):
        sub = [i for i in clean if i["split"] == name]
        pos = [i for i in sub if i["correction"]]
        print(f"{name}: {len(sub)} clean items in {len({i['group'] for i in sub})} session groups; "
              f"corrections {len(pos)} (quiet {sum(i['surface'] == 'quiet' for i in pos)}); "
              f"others {len(sub) - len(pos)} (near misses {sum(i['near_miss'] for i in sub if not i['correction'])}); "
              f"skipped by the hook {sum(bool(i['skip']) for i in sub)}; "
              f"unclear held out {sum(i['unclear'] and i['split'] == name for i in items)}")
    print(f"test ids sha {test_sha(items)}")


if __name__ == "__main__":
    main()
