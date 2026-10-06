"""Pull every message Manuel wrote out of his main-session transcripts, with
the context a reader needs to tell whether it corrects the agent.

    python3 moment-detector/moments/extract.py [--projects GLOB] [--until ISO-TIME] [--out DIR]

Writes DIR/moments.jsonl (default: the main checkout's
.scratch/moment-detector/moments/), one moment per line, sorted by time.
Rerunning rewrites the file from the transcripts; ids are stable.

A transcript is a tree of records linked by parentUuid. Manuel's words arrive
four ways: a user record with origin.kind == "human" (a prompt, possibly a
slash command with arguments), a queued_command attachment with a human
origin (typed while the agent was mid-turn), and an AskUserQuestion answer
(a tool result). Everything else that arrives as a user record (tool results,
task notifications, hook output, peer messages, compaction summaries) is not
his and is shown only as context.
"""

from __future__ import annotations

import argparse
import glob
import json
import re
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[2] / "quick-tests" / "lib"))
import qtlib  # noqa: E402

PROJECTS = qtlib.HOME / ".claude" / "projects"
DEFAULT_OUT = qtlib.main_checkout() / ".scratch" / "moment-detector" / "moments"

REPLY_HEAD, REPLY_TAIL = 6000, 3000
STEP_TEXT = 500
MAX_STEPS = 60
PREV_MAX = 2000
AFTER_MAX = 2000
PASTE_MAX = 3000

PASTE = re.compile(r"<pasted_content[^>]*>(.*?)</pasted_content>", re.S)
COMMAND = re.compile(r"<command-name>(.*?)</command-name>.*?<command-args>(.*?)</command-args>", re.S)
NOT_HIS = ("<bash-input>", "<local-command", "<system-reminder>")
# Commands whose arguments are settings or a machine-written tick, not words to the agent.
NOT_WORDS = {"/model", "/auto-mode-setup", "/loop"}


def clip(text: str, head: int, tail: int = 0) -> str:
    if len(text) <= head + tail:
        return text
    return text[:head] + f"\n[... {len(text) - head - tail} characters cut ...]\n" + (text[-tail:] if tail else "")


def text_of(content) -> str:
    if isinstance(content, str):
        return content
    return "\n".join(b.get("text", "") for b in content or [] if isinstance(b, dict) and b.get("type") == "text")


def manuel_words(rec: dict) -> dict | None:
    """The words Manuel wrote in this record, or None if the record is not his."""
    if rec.get("type") == "attachment":
        a = rec.get("attachment") or {}
        if a.get("type") == "queued_command" and (a.get("origin") or {}).get("kind") == "human":
            p = a.get("prompt")
            return split_paste(p if isinstance(p, str) else text_of(p), "queued")
        return None
    if rec.get("type") != "user" or rec.get("isMeta"):
        return None
    content = (rec.get("message") or {}).get("content")
    if "toolUseResult" in rec:
        for b in content if isinstance(content, list) else []:
            if b.get("type") == "tool_result":
                t = text_of(b.get("content"))
                if t.startswith("The user answered") or t.startswith("User has answered"):
                    return {"delivery": "ask_answer", "text": t, "pasted": []}
        return None
    t = text_of(content)
    kind = (rec.get("origin") or {}).get("kind")
    if kind != "human" and not (kind is None and t.lstrip().startswith(("<command-name>", "<command-message>"))):
        return None
    has_image = isinstance(content, list) and any(b.get("type") == "image" for b in content if isinstance(b, dict))
    if t.lstrip().startswith(NOT_HIS):
        return None
    m = COMMAND.search(t)
    if m:
        args = m.group(2).strip()
        if not args or m.group(1).strip() in NOT_WORDS:
            return None
        d = split_paste(args, "command")
        d["command"] = m.group(1).strip()
        return d
    d = split_paste(t, "prompt")
    if has_image:
        d["images"] = True
    return d if d["text"].strip() or d["pasted"] else None


def split_paste(t: str, delivery: str) -> dict:
    pasted = [clip(p.strip(), PASTE_MAX) for p in PASTE.findall(t)]
    own = PASTE.sub("[pasted content]", t).strip()
    return {"delivery": delivery, "text": own, "pasted": pasted}


def tool_brief(block: dict) -> str:
    name = block.get("name", "?")
    inp = block.get("input") or {}
    for key in ("command", "description", "file_path", "pattern", "skill", "prompt", "query", "url", "questions"):
        if key in inp:
            v = inp[key]
            v = json.dumps(v, ensure_ascii=False) if not isinstance(v, str) else v
            limit = 1500 if name == "AskUserQuestion" else 200
            return f"{name}: {clip(v.replace(chr(10), ' '), limit)}"
    return f"{name}: {clip(json.dumps(inp, ensure_ascii=False), 200)}"


def step_of(rec: dict) -> list[str]:
    """What one non-Manuel record contributes to the 'since his last message' trail."""
    t = rec.get("type")
    content = (rec.get("message") or {}).get("content")
    if t == "assistant":
        out = []
        for b in content if isinstance(content, list) else []:
            if b.get("type") == "text" and b.get("text", "").strip():
                out.append("said: " + clip(b["text"].strip(), STEP_TEXT))
            elif b.get("type") == "tool_use":
                out.append("tool " + tool_brief(b))
        return out
    if t == "user":
        if text_of(content).startswith("[Request interrupted by user"):
            return ["Manuel interrupted the agent"]
        if isinstance(content, list):
            errs = [b for b in content if isinstance(b, dict) and b.get("type") == "tool_result" and b.get("is_error")]
            if rec.get("toolDenialKind") == "user-rejected":
                return ["Manuel rejected the tool call (no words)"]
            if errs:
                return ["tool error: " + clip(text_of(errs[0].get("content")), 150)]
            return []
        s = content if isinstance(content, str) else ""
        if s.startswith("[Request interrupted by user"):
            return ["Manuel interrupted the agent"]
        kind = (rec.get("origin") or {}).get("kind")
        if kind == "task-notification":
            m = re.search(r"<summary>(.*?)</summary>", s, re.S)
            return ["background task finished: " + clip((m.group(1) if m else s).strip(), 150)]
        if rec.get("isCompactSummary"):
            return ["(conversation compacted here)"]
    if t == "system" and rec.get("subtype") == "compact_boundary":
        return ["(conversation compacted here)"]
    return []


def assistant_text(rec: dict) -> str:
    content = (rec.get("message") or {}).get("content")
    return text_of(content).strip() if rec.get("type") == "assistant" else ""


def has_tool_use(rec: dict) -> bool:
    content = (rec.get("message") or {}).get("content")
    return rec.get("type") == "assistant" and isinstance(content, list) and any(
        b.get("type") == "tool_use" for b in content if isinstance(b, dict))


def ancestry(rec: dict, by_uuid: dict) -> list[dict]:
    """Records from the root (or a compaction break) to rec, oldest first, rec excluded."""
    chain, seen = [], set()
    cur = by_uuid.get(rec.get("parentUuid"))
    while cur is not None and cur["uuid"] not in seen:
        seen.add(cur["uuid"])
        chain.append(cur)
        cur = by_uuid.get(cur.get("parentUuid") or cur.get("logicalParentUuid"))
    chain.reverse()
    return chain


def last_reply(segment: list[dict], before: list[dict]) -> str:
    """The agent's last words to Manuel: the trailing run of text it wrote before his message,
    looking past his previous message if this stretch had none."""
    for recs in (segment, before):
        texts = []
        for r in reversed(recs):
            if manuel_words(r):
                break
            t = assistant_text(r)
            if t:
                texts.append(t)
            elif has_tool_use(r) and texts:
                break
        if texts:
            return clip("\n\n".join(reversed(texts)), REPLY_HEAD, REPLY_TAIL)
    return ""


def session_moments(path: Path) -> list[dict]:
    rows = qtlib.load_rows(path)
    by_uuid = {r["uuid"]: r for r in rows if r.get("uuid")}
    children: dict[str, list[dict]] = {}
    for r in rows:
        if r.get("parentUuid"):
            children.setdefault(r["parentUuid"], []).append(r)
    line_of = {r["uuid"]: i + 1 for i, r in enumerate(rows) if r.get("uuid")}
    out, seen_text, ordinal = [], set(), 0
    for r in rows:
        words = manuel_words(r) if r.get("uuid") else None
        if not words:
            continue
        key = words["text"][:400]
        if key in seen_text and words["delivery"] != "ask_answer":
            continue
        seen_text.add(key)
        ordinal += 1
        chain = ancestry(r, by_uuid)
        cut = max((i for i, c in enumerate(chain) if manuel_words(c)), default=-1)
        segment, before = chain[cut + 1:], chain[:cut + 1]
        prev = manuel_words(chain[cut]) if cut >= 0 else None
        steps = [s for c in segment for s in step_of(c)]
        if len(steps) > MAX_STEPS:
            steps = steps[:10] + [f"[... {len(steps) - MAX_STEPS} steps cut ...]"] + steps[-(MAX_STEPS - 10):]
        reply = last_reply(segment, before)
        after_text, next_words, cur = "", None, r
        while cur is not None:
            kids = children.get(cur["uuid"], [])
            cur = kids[-1] if kids else None
            if cur is None:
                break
            w = manuel_words(cur)
            if w:
                next_words = w
                break
            if not after_text:
                after_text = assistant_text(cur)
        out.append({
            "id": f"{r['sessionId'][:8]}-{r['uuid'][:8]}",
            "project": path.parent.name,
            "session_id": r["sessionId"],
            "uuid": r["uuid"],
            "line": line_of[r["uuid"]],
            "ordinal": ordinal,
            "timestamp": r.get("timestamp"),
            "delivery": words["delivery"],
            "command": words.get("command"),
            "images": bool(words.get("images")),
            "text": words["text"],
            "pasted": words["pasted"],
            "context": {
                "previous_message": clip(prev["text"], PREV_MAX) if prev else None,
                "last_reply": reply,
                "since_previous": steps,
                "interrupted": any(s.startswith("Manuel interrupted") or s.startswith("Manuel rejected") for s in steps[-3:]),
                "starts_session": cut < 0 and not any(assistant_text(c) for c in chain),
            },
            "after": {
                "agent_reply": clip(after_text, AFTER_MAX),
                "next_message": clip(next_words["text"], 600) if next_words else None,
            },
        })
    return out


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__.split("\n\n")[0])
    ap.add_argument("--projects", default="*", help="glob over ~/.claude/projects folder names")
    ap.add_argument("--out", type=Path, default=DEFAULT_OUT)
    ap.add_argument("--until", default="9999", help="keep messages with a timestamp before this ISO time")
    args = ap.parse_args()
    # A forked or resumed session's file repeats its parent's records under the same
    # uuids. Reading sessions oldest first keeps each message where it was first written.
    sessions = []
    for f in glob.glob(str(PROJECTS / args.projects / "*.jsonl")):
        ms = session_moments(Path(f))
        if ms:
            sessions.append(ms)
    sessions.sort(key=lambda ms: min(m["timestamp"] or "" for m in ms))
    moments, seen = [], set()
    for ms in sessions:
        for m in ms:
            keys = {m["uuid"]} | ({m["text"]} if len(m["text"]) > 80 else set())
            if keys & seen or (m["timestamp"] or "") >= args.until:
                continue
            seen |= keys
            moments.append(m)
    moments.sort(key=lambda m: (m["timestamp"] or "", m["id"]))
    # After a rewind he often sends a longer version of the same message, and a
    # forked session can carry it again under a new uuid. Both are kept; the later
    # one names the earlier so a scorer can count the pair once.
    first_by_start: dict[str, str] = {}
    for m in moments:
        start = m["text"][:150] if len(m["text"]) > 60 else None
        m["resend_of"] = first_by_start.get(start) if start else None
        if start and start not in first_by_start:
            first_by_start[start] = m["id"]
    args.out.mkdir(parents=True, exist_ok=True)
    with open(args.out / "moments.jsonl", "w") as fh:
        for m in moments:
            fh.write(json.dumps(m, ensure_ascii=False) + "\n")
    by = {}
    for m in moments:
        by[m["delivery"]] = by.get(m["delivery"], 0) + 1
    print(f"{len(moments)} moments from {len({m['session_id'] for m in moments})} sessions -> {args.out / 'moments.jsonl'}")
    print(" ".join(f"{k}={v}" for k, v in sorted(by.items())))


if __name__ == "__main__":
    main()
