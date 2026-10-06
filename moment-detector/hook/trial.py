#!/usr/bin/env python3
"""Prove the hook in a real Claude Code session inside a box.

  trial.py [--turns turns.json] [--model claude-opus-5-5] [--effort medium] [--out DIR]
           [--queue] [--set key=value ...]   (--set is applied to the correction moment's moment.json in the box)

Builds a box (quick-tests/lib/qtlib.py: no network for tools, writes only inside
the box, none of Manuel's settings), a tiny project in it with the hook installed
in its .claude/settings.json, and sends the turns as one multi-turn session
(stream-json input). Then it moves the session's transcript out of ~/.claude,
redacts the account identifiers, runs `md.py uptake` over it, and writes
summary.md beside the log. The transcript is persisted because the hook reads it.
"""

from __future__ import annotations

import json
import shutil
import subprocess
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE.parent.parent / "quick-tests" / "lib"))
import qtlib  # noqa: E402

sys.path.insert(0, str(HERE))
import md  # noqa: E402

GREET = '''def greet():
    return "Hello!"


if __name__ == "__main__":
    print(greet())
'''


def build_project(box: qtlib.Box, overrides: list[str]) -> Path:
    proj = box.root / "proj"
    proj.mkdir()
    (proj / "greet.py").write_text(GREET)
    env = qtlib.git_env(box)
    subprocess.run(["git", "init", "-q", str(proj)], check=True, env=env)
    subprocess.run(["git", "-C", str(proj), "add", "."], check=True, env=env)
    subprocess.run(["git", "-C", str(proj), "commit", "-qm", "Start"], check=True, env=env)
    hook_dir = proj / ".claude" / "md"
    hook_dir.mkdir(parents=True)
    shutil.copy(HERE / "md.py", hook_dir / "md.py")
    shutil.copytree(HERE / "moments", hook_dir / "moments")
    if overrides:
        m = md.load_moment("correction", overrides)
        for k in ("name", "dir"):
            m.pop(k)
        (hook_dir / "moments" / "correction" / "moment.json").write_text(json.dumps(m, indent=2) + "\n")
    settings = {"hooks": {"UserPromptSubmit": [{"hooks": [{
        "type": "command", "command": 'python3 "$CLAUDE_PROJECT_DIR/.claude/md/md.py" hook', "timeout": 60}]}]}}
    (proj / ".claude" / "settings.json").write_text(json.dumps(settings, indent=2) + "\n")
    return proj


def run_session(box: qtlib.Box, proj: Path, turns: list[dict], model: str, effort: str, out: Path,
                queue: bool) -> str:
    """Each turn is sent when the previous one has its result; with `queue`, all at once,
    as messages typed while the model works (they arrive mid-turn as queued commands)."""
    settings_path = box.private / "settings-trial.json"
    settings_path.write_text(json.dumps(qtlib.settings_for(box, "work"), indent=2))
    tools = ["Read", "Grep", "Glob", "Edit", "Write", "Bash"]
    cmd = [qtlib.find_cli(), "-p", "--input-format", "stream-json", "--output-format", "stream-json", "--verbose",
           "--setting-sources", "project", "--settings", str(settings_path), "--strict-mcp-config",
           "--model", model, "--effort", effort, "--tools", ",".join(tools)]
    msgs = [json.dumps({"type": "user", "message": {"role": "user", "content": t["text"]}}) + "\n" for t in turns]
    proc = subprocess.Popen(cmd, stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=open(out / "stderr.txt", "w"),
                            text=True, cwd=str(proj), env=qtlib.safe_env(box))
    if queue:
        proc.stdin.write("".join(msgs))
        msgs = []
    else:
        proc.stdin.write(msgs.pop(0))
    proc.stdin.flush()
    with open(out / "stream.jsonl", "w") as so:
        for line in proc.stdout:
            so.write(line)
            if '"type":"result"' in line:
                if not msgs:
                    break
                proc.stdin.write(msgs.pop(0))
                proc.stdin.flush()
        proc.stdin.close()
        for line in proc.stdout:
            so.write(line)
    proc.wait(timeout=60)
    for line in (out / "stream.jsonl").read_text().splitlines():
        ev = json.loads(line)
        if ev.get("type") == "system" and ev.get("subtype") == "init":
            return ev["session_id"]
    sys.exit("no init event in stream.jsonl; see stderr.txt")


def collect(proj: Path, session_id: str, out: Path) -> Path:
    """Move the session's state dir out of ~/.claude/projects; keep a redacted transcript."""
    state = qtlib.HOME / ".claude" / "projects" / qtlib.slug(proj)
    src = state / f"{session_id}.jsonl"
    transcript = out / "transcript.jsonl"
    transcript.write_text(qtlib.redact(src.read_text()))
    shutil.rmtree(state)
    shutil.copy(proj / ".scratch" / "moment-detector" / "checks.jsonl", out / "checks.jsonl")
    return transcript


def summarize(turns: list[dict], checks: list[dict], up: list[dict], stream: Path) -> str:
    by_prompt = {c.get("prompt_sha"): c for c in checks}
    up_by_id = {u["id"]: u for u in up}
    results = [json.loads(l) for l in stream.read_text().splitlines() if '"type":"result"' in l]
    lines = ["| Turn | Expected | Verdict | Cue | Delivered | Model | Check ms | Hook ms | Tokens in/out | Cost $ | Uptake | Reason |",
             "|---|---|---|---|---|---|---|---|---|---|---|---|"]
    for i, t in enumerate(turns):
        c = by_prompt.get(md._sha(t["text"]), {"error": "no check logged"})
        v = c.get("verdict") or {}
        u = up_by_id.get(c.get("id"), {})
        tok = c.get("tokens") or {}
        lat = c.get("latency_ms") or {}
        lines.append(" | ".join([
            f"| {i + 1} {t['label']}", t["expect"], str(v.get("moment", c.get("error") or c.get("skipped"))),
            (v.get("cue") or "").replace("|", "/")[:60], str(c.get("delivered")), str(c.get("model_id")),
            str(lat.get("check")), str(lat.get("hook")),
            f"{tok.get('input', 0) + tok.get('cache_read', 0) + tok.get('cache_write', 0)}/{tok.get('output')}",
            str(c.get("cost_usd")), u.get("outcome", "-"), (u.get("reason") or "-").replace("|", "/") + " |"]))
    main_cost = sum(r.get("total_cost_usd") or 0 for r in results)
    lines.append("")
    lines.append(f"Main session: {len(results)} turns, ${main_cost:.4f} at API list price (the subscription's usage).")
    return "\n".join(lines) + "\n"


def main(argv: list[str]) -> int:
    opts = dict(zip(argv, argv[1:]))
    turns_path = Path(opts.get("--turns", HERE / "trial" / "turns.json"))
    model = opts.get("--model", "claude-opus-5-5")
    effort = opts.get("--effort", "medium")
    overrides = md._flag_values(argv, "--set")
    out = Path(opts.get("--out") or
               qtlib.main_checkout() / ".scratch" / "moment-detector" / "hook-trials" / qtlib.now_stamp())
    out.mkdir(parents=True, exist_ok=True)
    turns = json.loads(turns_path.read_text())
    before = qtlib.safety_preamble()
    box = qtlib.make_box(qtlib.new_box_path("mdh"), None)
    proj = build_project(box, overrides)
    session_id = run_session(box, proj, turns, model, effort, out, "--queue" in argv)
    transcript = collect(proj, session_id, out)
    checks = [json.loads(l) for l in (out / "checks.jsonl").read_text().splitlines()]
    up = md.uptake(str(transcript), str(out / "checks.jsonl"))
    qtlib.write_json(out / "uptake.json", up)
    (out / "summary.md").write_text(summarize(turns, checks, up, out / "stream.jsonl"))
    (out / "box.txt").write_text(f"{box.root}\nsession {session_id}\nmodel {model} {effort}\noverrides {overrides}\n")
    problems = qtlib.safety_verdict(before, out)
    print((out / "summary.md").read_text())
    print(f"out: {out}")
    if problems:
        print("SAFETY PROBLEMS:\n" + "\n".join(problems))
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
