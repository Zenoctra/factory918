#!/usr/bin/env python3
"""The moment detector's machinery: a Claude Code hook that asks a separate
model one narrow question about the session, delivers a suggestion the main
model may decline, and logs every check.

  md.py hook                       Claude Code command hook; reads the hook input on stdin.
  md.py check  MOMENT [--set k=v]  One check over a case (JSON on stdin), as the hook would run it.
  md.py case   TRANSCRIPT PROMPT_UUID [--moment M]
                                   The case the hook would have built at a past user turn.
  md.py uptake TRANSCRIPT [--log LOG]
                                   Each delivered suggestion and what the main model did with it.

A moment is a directory under moments/ (or $MD_MOMENTS): moment.json plus the
question, suggestion and optional examples files it names. Every moment whose
`event` matches the hook event is checked, in parallel. Python 3 standard
library only.
"""

from __future__ import annotations

import concurrent.futures as cf
import datetime as dt
import glob
import hashlib
import json
import os
import re
import secrets
import shutil
import subprocess
import sys
import tempfile
import time
from pathlib import Path

HERE = Path(__file__).resolve().parent
MOMENTS = Path(os.environ.get("MD_MOMENTS", HERE / "moments"))
# Set on the detector's own model call. A hook that sees it exits at once, so a
# call that somehow loads project hooks cannot recurse.
INNER = "MOMENT_DETECTOR_INNER"


# --------------------------------------------------------------------------
# Moments: configuration
# --------------------------------------------------------------------------


def load_moment(name: str, overrides: list[str] = ()) -> dict:
    """moment.json with `--set key=value` overrides applied (dotted keys, JSON values)."""
    d = MOMENTS / name
    m = json.loads((d / "moment.json").read_text())
    for o in overrides:
        key, _, raw = o.partition("=")
        try:
            val = json.loads(raw)
        except json.JSONDecodeError:
            val = raw
        node = m
        *path, last = key.split(".")
        for p in path:
            node = node.setdefault(p, {})
        node[last] = val
    m["name"] = name
    m["dir"] = str(d)
    return m


def moment_file(m: dict, key: str) -> str | None:
    rel = m.get(key)
    if not rel:
        return None
    p = Path(rel) if Path(rel).is_absolute() else Path(m["dir"]) / rel
    return p.read_text()


def moments_for(event: str) -> list[dict]:
    names = sorted(p.parent.name for p in MOMENTS.glob("*/moment.json"))
    return [m for m in (load_moment(n) for n in names) if m.get("event") == event and m.get("enabled", True)]


# --------------------------------------------------------------------------
# Reading the session: what the main model did and said before the new message
# --------------------------------------------------------------------------


def _text_of(content) -> str:
    if isinstance(content, str):
        return content
    return "\n".join(b.get("text", "") for b in content or [] if b.get("type") == "text")


def _is_human_prompt(rec: dict) -> bool:
    """A message the user typed, not a tool result, a task notification or a meta record."""
    if rec.get("type") != "user" or rec.get("isMeta"):
        return False
    origin = (rec.get("origin") or {}).get("kind")
    if origin and origin != "human":
        return False
    content = (rec.get("message") or {}).get("content")
    if isinstance(content, list) and any(b.get("type") == "tool_result" for b in content):
        return False
    text = _text_of(content).strip()
    return bool(text) and not text.startswith("<task-notification>")


def _queued_prompt(rec: dict) -> str | None:
    """A message typed while the model was working. It reaches the model mid-turn as
    a queued_command attachment, not a user record, and UserPromptSubmit still fires
    for it (verified on 2.1.288)."""
    att = rec.get("attachment") or {}
    if rec.get("type") == "attachment" and att.get("type") == "queued_command" and att.get("commandMode") == "prompt":
        return _text_of(att.get("prompt"))
    return None


def _action(block: dict) -> str:
    inp = block.get("input") or {}
    keys = ("file_path", "path", "command", "pattern", "description", "skill", "url", "query")
    shown = {k: inp[k] for k in keys if k in inp}
    return f"{block.get('name')} {json.dumps(shown, ensure_ascii=False)[:300]}"


def read_session(transcript: str | None, before_uuid: str | None = None) -> dict:
    """The previous user message, and the main model's text and tool calls since it.

    In a live UserPromptSubmit hook the new message is not yet in the transcript
    (verified on 2.1.288), so the whole file is "before". For a past turn, pass
    the uuid of the user record and reading stops there. Thinking is never read.
    """
    out = {"previous_user": "", "last_reply": "", "actions": [], "found": before_uuid is None}
    if not transcript or not os.path.exists(transcript):
        return out
    reply, actions = [], []
    for line in open(transcript, encoding="utf-8"):
        try:
            rec = json.loads(line)
        except json.JSONDecodeError:
            continue
        if before_uuid and rec.get("uuid") == before_uuid:
            out["found"] = True
            break
        queued = _queued_prompt(rec)
        if _is_human_prompt(rec) or queued is not None:
            out["previous_user"] = queued if queued is not None else _text_of(rec["message"]["content"])
            reply, actions = [], []
        elif rec.get("type") == "assistant" and not rec.get("isSidechain"):
            for b in (rec.get("message") or {}).get("content") or []:
                if b.get("type") == "text" and b.get("text", "").strip():
                    reply.append(b["text"])
                elif b.get("type") == "tool_use":
                    actions.append(_action(b))
    out["last_reply"] = "\n\n".join(reply)
    out["actions"] = actions
    return out


def make_case(prompt: str, session: dict, slice_cfg: dict) -> dict:
    """The slice the detector reads, cut to the moment's configuration."""
    def tail(s: str, n: int) -> str:
        return s if len(s) <= n else "[...]" + s[-n:]
    case = {"prompt": tail(prompt, slice_cfg.get("prompt_chars", 4000))}
    if slice_cfg.get("previous_user"):
        case["previous_user"] = tail(session.get("previous_user", ""), slice_cfg.get("previous_user_chars", 2000))
    if slice_cfg.get("last_reply"):
        case["last_reply"] = tail(session.get("last_reply", ""), slice_cfg.get("last_reply_chars", 4000))
    if slice_cfg.get("actions"):
        case["actions"] = session.get("actions", [])[-slice_cfg.get("max_actions", 20):]
    return case


# --------------------------------------------------------------------------
# Asking the detector's model
# --------------------------------------------------------------------------

SECTIONS = [
    ("previous_user", "previous_user_message"),
    ("last_reply", "agent_last_reply"),
    ("actions", "agent_actions_since_previous_message"),
    ("prompt", "new_user_message"),
]


def render_question(m: dict, case: dict) -> str:
    parts = [moment_file(m, "question").strip()]
    examples = moment_file(m, "examples")
    if examples:
        parts.append("<labelled_examples>\n" + examples.strip() + "\n</labelled_examples>")
    for key, tag in SECTIONS:
        if key in case:
            val = case[key]
            body = "\n".join(val) if isinstance(val, list) else val
            parts.append(f"<{tag}>\n{body or '(none)'}\n</{tag}>")
    parts.append(m["answer_format"].strip())
    return "\n\n".join(parts)


def find_cli() -> str:
    if os.environ.get("MD_CLAUDE"):
        return os.environ["MD_CLAUDE"]
    pattern = str(Path.home() / "Library/Application Support/Claude/claude-code/*/*/claude.app/Contents/MacOS/claude")
    found = sorted(glob.glob(pattern), key=lambda p: [int(x) for x in re.findall(r"\d+", p.split("claude-code/")[1].split("/")[0])])
    if found:
        return found[-1]
    on_path = shutil.which("claude")
    if on_path:
        return on_path
    raise RuntimeError("no Claude Code CLI found; set MD_CLAUDE")


def call_model(m: dict, question: str) -> dict:
    """One fresh `claude -p` call on the subscription.

    --safe-mode turns off hooks, CLAUDE.md, skills, plugins and MCP while keeping
    OAuth (verified on 2.1.288; --bare also skips hooks but refuses OAuth).
    No tools, no session file, a minimal system prompt. `thinking_tokens` is the
    CLI's MAX_THINKING_TOKENS: 0 turns Haiku 4.5's thinking off and a budget turns
    it on; Sonnet 5.5 thinks whatever it is set to, and `effort` is its lever.
    Every check's prompt is new, so a cache write (twice the input price, as
    the CLI writes it) is never read back: `prompt_caching` is off unless set.
    """
    cmd = [find_cli(), "-p", "--safe-mode", "--no-session-persistence", "--strict-mcp-config",
           "--output-format", "json", "--model", m["model"], "--tools", "",
           "--system-prompt", m["system_prompt"]]
    if m.get("effort"):
        cmd += ["--effort", m["effort"]]
    env = dict(os.environ, MAX_THINKING_TOKENS=str(m.get("thinking_tokens", 0)),
               **({} if m.get("prompt_caching") else {"DISABLE_PROMPT_CACHING": "1"}),
               CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC="1", **{INNER: "1"})
    t0 = time.monotonic()
    proc = subprocess.run(cmd, input=question, capture_output=True, text=True, env=env,
                          cwd=tempfile.gettempdir(), timeout=m.get("timeout_s", 20))
    wall_ms = round((time.monotonic() - t0) * 1000)
    try:
        res = json.loads(proc.stdout)
    except json.JSONDecodeError:
        raise RuntimeError(f"exit {proc.returncode}: {(proc.stderr or proc.stdout)[-400:]}")
    if res.get("is_error"):
        raise RuntimeError(str(res.get("result"))[:400])
    u = res.get("usage") or {}
    return {
        "text": res.get("result") or "",
        "model_id": next(iter(res.get("modelUsage") or {}), m["model"]),
        "wall_ms": wall_ms,
        "api_ms": res.get("duration_api_ms"),
        "tokens": {"input": u.get("input_tokens", 0), "cache_read": u.get("cache_read_input_tokens", 0),
                   "cache_write": u.get("cache_creation_input_tokens", 0), "output": u.get("output_tokens", 0)},
        "cost_usd": res.get("total_cost_usd"),
    }


def parse_verdict(text: str, threshold: float | None = None, score_range: tuple[float, float] = (1, 10)) -> dict:
    """The first JSON object in the reply; fences and stray prose are tolerated.

    With a `threshold`, the reply carries a graded `score` inside `score_range`
    and the moment is `score >= threshold`; without one, it carries a boolean
    `moment`. A score outside the range is an invalid answer, not a strong one.
    """
    start = text.find("{")
    if start < 0:
        raise ValueError("no JSON object in reply")
    obj, _ = json.JSONDecoder().raw_decode(text[start:])
    out = {"cue": str(obj.get("cue") or ""), "confidence": str(obj.get("confidence") or "")}
    if threshold is None:
        if not isinstance(obj.get("moment"), bool):
            raise ValueError("reply has no boolean `moment`")
        return {"moment": obj["moment"], **out}
    score = obj.get("score")
    if isinstance(score, bool) or not isinstance(score, (int, float)):
        raise ValueError("reply has no numeric `score`")
    if not score_range[0] <= score <= score_range[1]:
        raise ValueError(f"score {score} is outside {list(score_range)}")
    return {"moment": score >= threshold, "score": score, **out}


# --------------------------------------------------------------------------
# One check, the suggestion, the log
# --------------------------------------------------------------------------


def _sha(s: str | None) -> str | None:
    return hashlib.sha256(s.encode()).hexdigest()[:12] if s else None


def suggestion_text(m: dict, check_id: str, verdict: dict, model_id: str) -> str:
    return moment_file(m, "suggestion").strip().format(
        id=check_id, cue=verdict["cue"].replace('"', "'"), confidence=verdict["confidence"] or "unstated",
        score=verdict.get("score", "unstated"), model=model_id)


def check(m: dict, case: dict, ctx: dict) -> dict:
    """Run one moment over one case. Never raises: an error is logged and nothing is delivered."""
    check_id = "md-" + secrets.token_hex(3)
    rec = {
        "id": check_id, "ts": dt.datetime.now().astimezone().isoformat(timespec="milliseconds"),
        "moment": m["name"], **ctx,
        "config": {"model": m["model"], "effort": m.get("effort"), "thinking_tokens": m.get("thinking_tokens", 0),
                   "prompt_caching": bool(m.get("prompt_caching")),
                   "threshold": m.get("threshold"), "slice": m.get("slice"),
                   "system_sha": _sha(m["system_prompt"]), "answer_format_sha": _sha(m["answer_format"]),
                   "question_sha": _sha(moment_file(m, "question")),
                   "examples": m.get("examples"), "examples_sha": _sha(moment_file(m, "examples")),
                   "suggestion_sha": _sha(moment_file(m, "suggestion"))},
        "case": case, "verdict": None, "deliver": m.get("deliver", True), "delivered": False, "suggestion": None,
        "error": None,
    }
    t0 = time.monotonic()
    try:
        call = call_model(m, render_question(m, case))
        rec.update(model_id=call["model_id"], raw=call["text"], tokens=call["tokens"], cost_usd=call["cost_usd"],
                   latency_ms={"model_wall": call["wall_ms"], "api": call["api_ms"]})
        rec["verdict"] = parse_verdict(call["text"], m.get("threshold"), tuple(m.get("score_range", (1, 10))))
        if rec["verdict"]["moment"]:
            rec["suggestion"] = suggestion_text(m, check_id, rec["verdict"], call["model_id"])
            # `deliver: false` is shadow mode: the check runs and is logged in full, and the
            # main model gets nothing (the control arm of a paired run).
            rec["delivered"] = m.get("deliver", True)
    except Exception as e:  # the hook must never break the user's turn
        rec["error"] = f"{type(e).__name__}: {e}"
    rec.setdefault("latency_ms", {})["check"] = round((time.monotonic() - t0) * 1000)
    return rec


def log_path(cwd: str | None) -> Path:
    if os.environ.get("MD_LOG"):
        return Path(os.environ["MD_LOG"])
    root = os.environ.get("CLAUDE_PROJECT_DIR") or cwd or os.getcwd()
    return Path(root) / ".scratch" / "moment-detector" / "checks.jsonl"


def append_log(path: Path, rec: dict) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with open(path, "a", encoding="utf-8") as f:
        f.write(json.dumps(rec, ensure_ascii=False) + "\n")


# --------------------------------------------------------------------------
# Commands
# --------------------------------------------------------------------------


def cmd_hook() -> int:
    if os.environ.get(INNER):
        return 0
    t0 = time.monotonic()
    data = json.load(sys.stdin)
    event = data.get("hook_event_name", "")
    prompt = data.get("prompt") or ""
    moments = moments_for(event)
    if not moments:
        return 0
    # MD_TRANSCRIPT replaces the hook input's transcript. A forked session (replay's
    # --fork-session, a rewind) writes its transcript only when its first message is
    # recorded, after this hook, so its first check would otherwise read nothing.
    transcript = os.environ.get("MD_TRANSCRIPT") or data.get("transcript_path")
    ctx = {"event": event, "session_id": data.get("session_id"), "prompt_id": data.get("prompt_id"),
           "prompt_sha": _sha(prompt),
           "transcript_path": data.get("transcript_path"), "transcript_read": transcript, "cwd": data.get("cwd")}
    session = read_session(transcript)
    log = log_path(data.get("cwd"))

    def one(m: dict) -> dict:
        skip = next((f"prompt matches {p!r}" for p in m.get("skip_prompt_patterns", []) if re.search(p, prompt)), None)
        if m.get("skip_first_message") and not session["previous_user"]:
            skip = ("first message of the session" if transcript and os.path.exists(transcript)
                    else "no transcript to read (a forked session's first message?)")
        if skip:
            return {"id": None, "ts": dt.datetime.now().astimezone().isoformat(timespec="milliseconds"),
                    "moment": m["name"], **ctx, "skipped": skip, "delivered": False}
        return check(m, make_case(prompt, session, m.get("slice", {})), ctx)

    with cf.ThreadPoolExecutor(max_workers=len(moments)) as pool:
        recs = list(pool.map(one, moments))
    hook_ms = round((time.monotonic() - t0) * 1000)
    for r in recs:
        r.setdefault("latency_ms", {})["hook"] = hook_ms
        append_log(log, r)
    context = "\n\n".join(r["suggestion"] for r in recs if r.get("delivered"))
    if context:
        print(json.dumps({"hookSpecificOutput": {"hookEventName": event, "additionalContext": context}}))
    return 0


def cmd_check(args: list[str]) -> int:
    """For the scoring step: the case on stdin, the verdict record on stdout (and in $MD_LOG if set)."""
    m = load_moment(args[0], _flag_values(args[1:], "--set"))
    case = json.load(sys.stdin)
    rec = check(m, case, {"event": "offline"})
    if os.environ.get("MD_LOG"):
        append_log(Path(os.environ["MD_LOG"]), rec)
    print(json.dumps(rec, ensure_ascii=False, indent=2))
    return 0


def session_at(transcript: str, uuid: str) -> tuple[str, dict]:
    """The prompt of a past user record (a typed message or a queued one) and the
    session as the hook read it then."""
    for line in open(transcript, encoding="utf-8"):
        if uuid in line and json.loads(line).get("uuid") == uuid:
            rec = json.loads(line)
            queued = _queued_prompt(rec)
            prompt = queued if queued is not None else _text_of((rec.get("message") or {}).get("content"))
            return prompt, read_session(transcript, before_uuid=uuid)
    raise LookupError(f"no record {uuid} in {transcript}")


def cmd_case(args: list[str]) -> int:
    transcript, uuid = args[0], args[1]
    name = (_flag_values(args[2:], "--moment") or ["correction"])[0]
    m = load_moment(name, _flag_values(args[2:], "--set"))
    prompt, session = session_at(transcript, uuid)
    print(json.dumps(make_case(prompt, session, m.get("slice", {})), ensure_ascii=False, indent=2))
    return 0


MARK = re.compile(r"\((md-[0-9a-f]{6})(?:\s+declined:\s*([^)]*))?\)")


def uptake(transcript: str, log: str | None = None) -> list[dict]:
    """Each suggestion delivered in the transcript and the main model's turn after it.

    A suggestion is found by its id in a hook_additional_context attachment. The
    turn runs until the next human prompt record; a queued message (typed while
    the model worked) names the prompt but does not end the turn, since the model
    answers it and the messages beside it together. Outcome: `declined` (with the stated
    reason) when the turn holds "(md-xxxxxx declined: ...)", `taken` when it
    holds "(md-xxxxxx)", `no_trace` when it holds neither. What the model says is
    data for auditing, not evidence it used the suggestion; paired runs measure that.
    """
    logged = {}
    if log and os.path.exists(log):
        for line in open(log, encoding="utf-8"):
            r = json.loads(line)
            if r.get("id"):
                logged[r["id"]] = r
    rows, open_rows, current = [], [], {}
    for line in open(transcript, encoding="utf-8"):
        try:
            rec = json.loads(line)
        except json.JSONDecodeError:
            continue
        if _is_human_prompt(rec):
            current = {"prompt_uuid": rec.get("uuid"), "prompt_id": rec.get("promptId"),
                       "prompt": _text_of(rec["message"]["content"])}
            open_rows = []
            continue
        queued = _queued_prompt(rec)
        if queued is not None:
            current = {"prompt_uuid": None, "prompt_id": rec.get("promptId"), "prompt": queued, "queued": True}
            continue
        att = rec.get("attachment") or {}
        if rec.get("type") == "attachment" and att.get("type") == "hook_additional_context":
            for cid in sorted(set(re.findall(r"md-[0-9a-f]{6}", " ".join(att.get("content") or [])))):
                open_rows.append({"id": cid, **current, "text": [], "actions": []})
                rows.append(open_rows[-1])
            continue
        if rec.get("type") == "assistant" and not rec.get("isSidechain"):
            for b in (rec.get("message") or {}).get("content") or []:
                for row in open_rows:
                    if b.get("type") == "text":
                        row["text"].append(b.get("text", ""))
                    elif b.get("type") == "tool_use":
                        row["actions"].append(_action(b))
    out = []
    for r in rows:
        text = "\n\n".join(r.pop("text"))
        marks = [(cid, reason) for cid, reason in MARK.findall(text) if cid == r["id"]]
        declined = next((reason for _, reason in marks if reason), None)
        r["outcome"] = "declined" if declined is not None else ("taken" if marks else "no_trace")
        r["reason"] = declined.strip() if declined else None
        r["reply"] = text
        if r["id"] in logged:
            lg = logged[r["id"]]
            r["log"] = {k: lg.get(k) for k in ("moment", "model_id", "verdict", "latency_ms", "cost_usd")}
            r["prompt_matches_log"] = lg.get("prompt_sha") == _sha(r["prompt"])
        out.append(r)
    return out


def _flag_values(args: list[str], flag: str) -> list[str]:
    return [args[i + 1] for i, a in enumerate(args[:-1]) if a == flag]


def main(argv: list[str]) -> int:
    if not argv:
        sys.exit(__doc__)
    cmd, rest = argv[0], argv[1:]
    if cmd == "hook":
        return cmd_hook()
    if cmd == "check":
        return cmd_check(rest)
    if cmd == "case":
        return cmd_case(rest)
    if cmd == "uptake":
        log = (_flag_values(rest[1:], "--log") or [None])[0]
        print(json.dumps(uptake(rest[0], log), ensure_ascii=False, indent=2))
        return 0
    sys.exit(__doc__)


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
