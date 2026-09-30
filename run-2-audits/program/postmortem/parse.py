#!/usr/bin/env python3
"""Post-mortem of the 2026-09-22 autopilot-stack run.

Reads the root session JSONL, every subagent JSONL beside it, the owner
decision trails and the program registry, and writes seven markdown tables
next to this script. Standard library only.

Run:  python3 parse.py
"""

from __future__ import annotations

import collections
import datetime as dt
import glob

import json
import os
import re
import sys

# --------------------------------------------------------------------------
# Inputs
# --------------------------------------------------------------------------

HOME = os.path.expanduser("~")
REPO = "/Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918"
SESSION = "b4a8ae9c-88b9-4178-b518-8ac2ff6f1af5"
PROJECT_DIR = os.path.join(
    HOME, ".claude/projects/-Users-manuel-Desktop-Work-Under-The-Sun-Collective-Core-918-factory918"
)
ROOT_LOG = os.path.join(PROJECT_DIR, SESSION + ".jsonl")
SUBAGENT_DIR = os.path.join(PROJECT_DIR, SESSION, "subagents")
PROGRAM_DIR = os.path.join(REPO, ".scratch/program")
REGISTRY = os.path.join(REPO, ".claude/state/todo-program.md")
OUT = os.path.dirname(os.path.abspath(__file__))

TICKETS = ["88", "89", "90", "91", "93"]
CDT = dt.timezone(dt.timedelta(hours=-5))  # America/Chicago on 2026-09-22


def parse_ts(s: str) -> dt.datetime:
    return dt.datetime.fromisoformat(s.replace("Z", "+00:00"))


def cdt(t: dt.datetime | None) -> str:
    return "" if t is None else t.astimezone(CDT).strftime("%H:%M:%S")


def cdt_full(t: dt.datetime | None) -> str:
    return "" if t is None else t.astimezone(CDT).strftime("%m-%d %H:%M:%S")


def mins(seconds: float) -> str:
    return f"{seconds / 60:.1f}"


def hm(seconds: float) -> str:
    seconds = int(seconds)
    return f"{seconds // 3600}h{(seconds % 3600) // 60:02d}m"


def n(x: int) -> str:
    return f"{x:,}"


def cell(s: str, width: int = 90) -> str:
    """Make an arbitrary string safe for a markdown table cell."""
    s = re.sub(r"\s+", " ", str(s)).strip()
    s = s.replace("|", "\\|")
    return s[:width]


# --------------------------------------------------------------------------
# Role guessing
# --------------------------------------------------------------------------

ROLE_RULES = [
    ("owner", r"\bown ticket\b|\bowner lane\b"),
    ("other", r"post-mortem|records lane|blast-radius|delegate ledger"),
    ("verifier", r"\bverif|\bre-verify\b|\baudit\b"),
    ("fix", r"\bfix lane\b|\bfix writer\b|\bfix\b.*\bround|round-\d.*\bfix"),
    ("writer", r"\bwriter\b|\bimplement\b"),
    ("reviewer", r"review|judge|\bjudg"),
    ("arena runner", r"\brunner\b|\barena\b"),
    ("explainer", r"explainer|synthesiz"),
    ("explorer", r"explorer|^how[: ]|\bhow lane\b|\bhow:"),
]


def with_model(description: str, model: str) -> str:
    """Append the model unless the lane's own description already names it."""
    d = cell(description, 60)
    return d if model and model.lower() in d.lower() else f"{d} ({model})"


def ticket_of(description: str) -> str:
    m = re.search(r"#(\d+)", description or "")
    return m.group(1) if m else "?"


def guess_role(description: str) -> str:
    d = (description or "").lower()
    for role, pattern in ROLE_RULES:
        if re.search(pattern, d):
            return role
    return "other"


# --------------------------------------------------------------------------
# Agent model
# --------------------------------------------------------------------------


class Agent:
    def __init__(self, agent_id: str, meta: dict, path: str | None):
        self.id = agent_id
        self.meta = meta
        self.path = path
        self.description = meta.get("description", "")
        self.model = meta.get("model", "")
        self.parent = meta.get("parentAgentId") or ("" if agent_id == "root" else "root")
        self.depth = meta.get("spawnDepth", 0)
        self.role = "root" if agent_id == "root" else guess_role(self.description)
        self.tool_use_id = meta.get("toolUseId")
        self.background = meta.get("requestShape") == "background"

        self.first: dt.datetime | None = None
        self.last: dt.datetime | None = None
        self.turns = 0            # distinct assistant message ids
        self.tool_calls = 0
        self.tokens = collections.Counter()
        self.messages: list[dict] = []   # collapsed message events, in order
        self.tool_uses: dict[str, dict] = {}   # tool_use_id -> {name, input, ts}
        self.tool_results: dict[str, dt.datetime] = {}
        self.children: list[str] = []
        self.launched_at: dt.datetime | None = None   # from the parent's Agent call
        self.launch_tool_use: str | None = None

    @property
    def wall(self) -> float:
        if self.first is None or self.last is None:
            return 0.0
        return (self.last - self.first).total_seconds()

    @property
    def input_total(self) -> int:
        return self.tokens["input"] + self.tokens["cache_read"] + self.tokens["cache_create"]

    @property
    def cache_share(self) -> float:
        tot = self.input_total
        return 0.0 if tot == 0 else 100.0 * self.tokens["cache_read"] / tot


def load_agents() -> dict[str, Agent]:
    agents: dict[str, Agent] = {"root": Agent("root", {"description": "root session (orchestrator)", "model": "opus"}, ROOT_LOG)}
    for meta_path in sorted(glob.glob(os.path.join(SUBAGENT_DIR, "agent-*.meta.json"))):
        agent_id = os.path.basename(meta_path)[len("agent-"):-len(".meta.json")]
        log = os.path.join(SUBAGENT_DIR, f"agent-{agent_id}.jsonl")
        agents[agent_id] = Agent(agent_id, json.load(open(meta_path)), log if os.path.exists(log) else None)
    return agents


# --------------------------------------------------------------------------
# Reading the transcripts
# --------------------------------------------------------------------------

AGENT_ID_RE = re.compile(r"agentId: ([0-9a-f]{17})")


def result_text(block: dict) -> str:
    c = block.get("content")
    if isinstance(c, str):
        return c
    if isinstance(c, list):
        return " ".join(x.get("text", "") for x in c if isinstance(x, dict))
    return ""


def scan(agent: Agent, launch_map: dict[str, str]) -> None:
    """Stream one transcript into the agent record.

    An assistant turn is written as several JSONL lines that share one
    message id (one per content block) and repeat the same usage object, so
    usage is counted once per message id and the line with the largest
    output_tokens wins.
    """
    if not agent.path or not os.path.exists(agent.path):
        return

    by_msg: dict[str, dict] = {}
    order: list[tuple[dt.datetime, str, dict]] = []

    with open(agent.path, errors="replace") as fh:
        for line in fh:
            line = line.strip()
            if not line:
                continue
            try:
                d = json.loads(line)
            except json.JSONDecodeError:
                continue
            kind = d.get("type")
            if kind not in ("assistant", "user"):
                continue
            ts_raw = d.get("timestamp")
            if not ts_raw:
                continue
            ts = parse_ts(ts_raw)
            if agent.first is None or ts < agent.first:
                agent.first = ts
            if agent.last is None or ts > agent.last:
                agent.last = ts

            msg = d.get("message") or {}
            content = msg.get("content")
            blocks = content if isinstance(content, list) else [{"type": "text", "text": content or ""}]

            if kind == "assistant":
                mid = msg.get("id") or d.get("uuid")
                rec = by_msg.get(mid)
                if rec is None:
                    rec = {"kind": "assistant", "id": mid, "start": ts, "end": ts,
                           "usage": msg.get("usage") or {}, "blocks": [], "tools": []}
                    by_msg[mid] = rec
                    order.append((ts, "assistant", rec))
                rec["end"] = max(rec["end"], ts)
                u = msg.get("usage") or {}
                if u.get("output_tokens", 0) >= (rec["usage"].get("output_tokens", 0)):
                    rec["usage"] = u
                wire = d.get("wireToolInputs") or {}
                for b in blocks:
                    if not isinstance(b, dict):
                        continue
                    rec["blocks"].append(b.get("type"))
                    if b.get("type") == "tool_use":
                        inp = b.get("input")
                        if not inp and b.get("id") in wire:
                            inp = wire[b["id"]]
                        entry = {"name": b.get("name", "?"), "input": inp or {}, "ts": ts}
                        agent.tool_uses[b.get("id", "")] = entry
                        rec["tools"].append(b.get("id", ""))
                        agent.tool_calls += 1
            else:
                is_result = any(isinstance(b, dict) and b.get("type") == "tool_result" for b in blocks)
                rec = {"kind": "user", "start": ts, "end": ts, "is_result": is_result,
                       "result_ids": [b.get("tool_use_id") for b in blocks
                                      if isinstance(b, dict) and b.get("type") == "tool_result"]}
                order.append((ts, "user", rec))
                for b in blocks:
                    if isinstance(b, dict) and b.get("type") == "tool_result":
                        tid = b.get("tool_use_id")
                        if tid:
                            agent.tool_results[tid] = ts
                        text = result_text(b)
                        m = AGENT_ID_RE.search(text)
                        if m and tid:
                            launch_map[m.group(1)] = tid

    for rec in by_msg.values():
        u = rec["usage"]
        agent.tokens["input"] += u.get("input_tokens", 0)
        agent.tokens["output"] += u.get("output_tokens", 0)
        agent.tokens["cache_read"] += u.get("cache_read_input_tokens", 0)
        agent.tokens["cache_create"] += u.get("cache_creation_input_tokens", 0)
    agent.turns = len(by_msg)
    order.sort(key=lambda x: x[0])
    agent.messages = [rec for _, _, rec in order]


# --------------------------------------------------------------------------
# Gap classification
# --------------------------------------------------------------------------

MODEL_LATENCY = "model latency"
TOOL_TIME = "tool time"
CHILDREN = "waiting on children"
TURN_ENDED = "turn ended"


def bash_label(inp: dict) -> str:
    cmd = inp.get("command", "") if isinstance(inp, dict) else ""
    return re.sub(r"\s+", " ", cmd).strip()[:80]


def classify_gaps(agent: Agent, agents: dict[str, Agent]) -> list[dict]:
    """One row per gap between consecutive messages of this agent."""
    kid_spans = []
    for cid in agent.children:
        kid = agents[cid]
        start = kid.launched_at or kid.first
        if start and kid.last:
            kid_spans.append((start, kid.last, cid))

    gaps = []
    for prev, nxt in zip(agent.messages, agent.messages[1:]):
        seconds = (nxt["start"] - prev["end"]).total_seconds()
        if seconds <= 0:
            continue
        overlap = 0.0
        who = []
        for s, e, cid in kid_spans:
            lo, hi = max(s, prev["end"]), min(e, nxt["start"])
            if (hi - lo).total_seconds() > 0:
                overlap = max(overlap, (hi - lo).total_seconds())
                who.append(cid)

        if prev["kind"] == "assistant" and prev["tools"] and nxt["kind"] == "user" and nxt.get("is_result"):
            tid = nxt["result_ids"][0] if nxt["result_ids"] else prev["tools"][0]
            tu = agent.tool_uses.get(tid or "", {})
            name = tu.get("name", "?")
            if name == "Agent":
                kind = CHILDREN
                label = "Agent: " + cell(tu.get("input", {}).get("description", ""), 60)
            else:
                kind = TOOL_TIME
                label = name + (": " + bash_label(tu.get("input", {})) if name == "Bash" else "")
        elif nxt["kind"] == "assistant":
            kind, label = MODEL_LATENCY, "think/respond before the next message"
        elif overlap >= 0.5 * seconds and who:
            kind, label = CHILDREN, f"{len(set(who))} child lane(s) running"
        else:
            kind, label = TURN_ENDED, "turn ended; resumed later"

        gaps.append({"start": prev["end"], "end": nxt["start"], "seconds": seconds,
                     "kind": kind, "label": label, "who": sorted(set(who))})
    return gaps


# --------------------------------------------------------------------------
# Reads
# --------------------------------------------------------------------------

WORKTREE_RE = re.compile(r".*/\.claude/worktrees/[^/]+/")
REPO_RE = re.compile(re.escape(REPO) + "/?")
# A path argument is either a quoted string (the repository lives under a path
# with spaces, so quoting is the common case) or a bare token.
ARG = r"(?:\"([^\"]+)\"|'([^']+)'|([A-Za-z0-9_./\-@$~]+))"

READ_PATTERNS = [
    ("cat", re.compile(r"\bcat\s+(?:-\w+\s+)*" + ARG)),
    ("sed -n", re.compile(r"\bsed\s+-n\s+\S+\s+" + ARG)),
    ("head", re.compile(r"\bhead\s+(?:-\w+\s*\d*\s+)*" + ARG)),
    ("git show", re.compile(r"\bgit\s+show\s+" + ARG)),
    ("gh issue", re.compile(r"\bgh\s+issue\s+view\s+(\d+)()()")),
    ("gh pr", re.compile(r"\bgh\s+pr\s+view\s+(\d+)()()")),
]


def normalise(path: str) -> str:
    path = path.strip("\"'")
    path = WORKTREE_RE.sub("", path)
    path = REPO_RE.sub("", path)
    path = re.sub(r"^/private/tmp/claude-\d+/[^ ]*?/", "<scratchpad>/", path)
    path = re.sub(r"^" + re.escape(HOME), "~", path)
    # `.claude/skills` in this repository is a symlink to the template's skills,
    # so both spellings name the same file and are folded together.
    path = re.sub(r"^\.claude/skills/", "template/.agents/skills/", path)
    return path


def resources_from(tool_name: str, inp: dict) -> list[str]:
    out = []
    if tool_name == "Read":
        p = inp.get("file_path")
        if p:
            out.append(normalise(p))
    elif tool_name == "Bash":
        cmd = inp.get("command", "")
        if not isinstance(cmd, str):
            return out
        for kind, rx in READ_PATTERNS:
            for m in rx.finditer(cmd):
                token = m.group(1) or m.group(2) or m.group(3)
                if not token:
                    continue
                if kind == "gh issue":
                    out.append(f"issue #{token}")
                elif kind == "gh pr":
                    out.append(f"PR #{token}")
                elif kind == "git show":
                    token = token.split(":")[-1]
                    if "/" in token or token.endswith(".md"):
                        out.append("git show " + normalise(token))
                else:
                    if token.startswith("-") or token in ("EOF", "<<"):
                        continue
                    if "/" not in token and "." not in token:
                        continue
                    out.append(normalise(token))
    return out


# --------------------------------------------------------------------------
# Decision trails and registry
# --------------------------------------------------------------------------


def load_trails() -> dict[str, dict]:
    trails = {}
    for t in TICKETS:
        path = os.path.join(PROGRAM_DIR, t, "decisions.tsv")
        if not os.path.exists(path):
            trails[t] = {"header": [], "rows": [], "has_phase": False, "notes": ["file missing"]}
            continue
        rows, notes = [], []
        with open(path, errors="replace") as fh:
            header = fh.readline().rstrip("\n").split("\t")
            has_phase = len(header) > 1 and header[1] == "phase"
            for raw in fh:
                raw = raw.rstrip("\n")
                if not raw.strip():
                    continue
                cols = raw.split("\t")
                ts = None
                try:
                    ts = parse_ts(cols[0])
                except Exception:
                    notes.append(f"unparseable timestamp {cols[0]!r}")
                rows.append({"ts": ts, "raw_ts": cols[0],
                             "phase": cols[1] if has_phase and len(cols) > 1 else "",
                             "what": cols[2] if has_phase and len(cols) > 2 else (cols[1] if len(cols) > 1 else ""),
                             "result": cols[-1] if len(cols) > 3 else ""})
        prev = None
        for r in rows:
            if r["ts"] and prev and r["ts"] < prev:
                notes.append(f"out of order at {r['raw_ts']}")
            if r["ts"]:
                prev = r["ts"]
        trails[t] = {"header": header, "rows": rows, "has_phase": has_phase, "notes": notes}
    return trails


def registry_lines() -> list[str]:
    if not os.path.exists(REGISTRY):
        return []
    return open(REGISTRY, errors="replace").read().splitlines()


# --------------------------------------------------------------------------
# Build
# --------------------------------------------------------------------------


def main() -> None:
    agents = load_agents()
    launch_map: dict[str, str] = {}   # child agent id -> Agent tool_use id in the parent

    for i, a in enumerate(agents.values(), 1):
        print(f"[{i}/{len(agents)}] {a.id}", file=sys.stderr)
        scan(a, launch_map)

    # Link children, and date each launch from the parent's Agent tool_use.
    for a in agents.values():
        if a.id == "root":
            continue
        parent = agents.get(a.parent)
        if parent is None:
            a.parent = "root"
            parent = agents["root"]
        parent.children.append(a.id)
        tuid = a.tool_use_id or launch_map.get(a.id)
        a.launch_tool_use = tuid
        if tuid and tuid in parent.tool_uses:
            a.launched_at = parent.tool_uses[tuid]["ts"]

    live = [a for a in agents.values() if a.messages]
    run_start = min(a.first for a in live)
    run_end = max(a.last for a in live)

    gaps_by_agent = {a.id: classify_gaps(a, agents) for a in live}

    write_agents(agents, live)
    write_tree(agents, live)
    write_timeline(agents, live, load_trails())
    write_waits(agents, live, gaps_by_agent)
    write_reads(agents, live)
    write_tools(agents, live)
    write_summary(agents, live, gaps_by_agent, run_start, run_end)
    print("done", file=sys.stderr)


# --------------------------------------------------------------------------
# Tables
# --------------------------------------------------------------------------


def owner_attempts(owners: list) -> dict[str, str]:
    """Label an owner lane when its ticket was owned more than once."""
    by_ticket = collections.defaultdict(list)
    for o in owners:
        by_ticket[ticket_of(o.description)].append(o)
    labels = {}
    for group in by_ticket.values():
        group.sort(key=lambda a: a.first)
        for i, o in enumerate(group):
            labels[o.id] = "" if len(group) == 1 else (" — first attempt" if i == 0 else f" — attempt {i + 1}")
    return labels


def subtree(agents: dict[str, Agent], root_id: str) -> list[str]:
    out, stack = [], [root_id]
    while stack:
        cur = stack.pop()
        out.append(cur)
        stack.extend(agents[cur].children)
    return out


GUIDE_SOURCE = (
    "Source: the root session JSONL and the 103 subagent JSONL files beside it "
    "(`~/.claude/projects/-Users-manuel-.../b4a8ae9c-.../subagents/`), regenerated by `parse.py` in this "
    "directory. Times are CDT (UTC-5)."
)


def write_agents(agents, live):
    rows = sorted(live, key=lambda a: (a.first or dt.datetime.max.replace(tzinfo=dt.timezone.utc)))
    lines = [
        "# agents.md: one row per agent",
        "",
        "Every lane in the run, one row each, oldest first. The root session is the first row; everything below it",
        "is a subagent with its own transcript file. `parent` is the lane that launched it, so an owner's children",
        "carry the owner's id. `role` is guessed from the description text, not recorded anywhere in the logs, so",
        "treat it as a label for grouping rather than ground truth. `wall` is first message to last message inside",
        "that lane's own transcript: for a background lane it is real work time, but for the root it spans the",
        "whole run including every idle stretch. `turns` counts distinct assistant messages (the harness writes one",
        "JSONL line per content block, all sharing a message id and repeating the same usage object, so usage is",
        "counted once per message id). `cache %` is cache reads as a share of all input tokens; a lane that reads",
        "the same brief and the same files over and over shows a high number here, which is cheap, while a low",
        "number means the lane kept pushing new material into a cold context, which is not. The logs record the",
        "model family (`opus`, `fable`) but never the requested effort, so effort is absent from every table here.",
        "",
        GUIDE_SOURCE,
        "",
        "| agent | description | model | parent | role | first | last | wall (min) | turns | tools | input | output | cache read | cache create | cache % |",
        "|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|",
    ]
    for a in rows:
        lines.append(
            f"| `{a.id}` | {cell(a.description, 60)} | {a.model} | `{a.parent or '-'}` | {a.role} | "
            f"{cdt(a.first)} | {cdt(a.last)} | {mins(a.wall)} | {a.turns} | {a.tool_calls} | "
            f"{n(a.tokens['input'])} | {n(a.tokens['output'])} | {n(a.tokens['cache_read'])} | "
            f"{n(a.tokens['cache_create'])} | {a.cache_share:.1f}% |"
        )
    tot = collections.Counter()
    for a in live:
        tot.update(a.tokens)
    lines += [
        f"| **total ({len(live)} agents)** | | | | | {cdt(min(a.first for a in live))} | "
        f"{cdt(max(a.last for a in live))} | {mins(sum(a.wall for a in live))} | "
        f"{sum(a.turns for a in live)} | {sum(a.tool_calls for a in live)} | {n(tot['input'])} | "
        f"{n(tot['output'])} | {n(tot['cache_read'])} | {n(tot['cache_create'])} | "
        f"{100.0 * tot['cache_read'] / max(1, tot['input'] + tot['cache_read'] + tot['cache_create']):.1f}% |",
        "",
        "## By role",
        "",
        "| role | agents | wall (min) | turns | tools | input | output | cache read | cache create |",
        "|---|---|---|---|---|---|---|---|---|",
    ]
    byrole = collections.defaultdict(list)
    for a in live:
        byrole[a.role].append(a)
    for role, group in sorted(byrole.items(), key=lambda kv: -sum(x.tokens["output"] for x in kv[1])):
        t = collections.Counter()
        for a in group:
            t.update(a.tokens)
        lines.append(
            f"| {role} | {len(group)} | {mins(sum(a.wall for a in group))} | {sum(a.turns for a in group)} | "
            f"{sum(a.tool_calls for a in group)} | {n(t['input'])} | {n(t['output'])} | "
            f"{n(t['cache_read'])} | {n(t['cache_create'])} |"
        )
    write("agents.md", lines)


def write_tree(agents, live):
    liveset = {a.id for a in live}

    def sub_tokens(aid):
        tot = collections.Counter()
        wall = 0.0
        for cid in subtree(agents, aid):
            if cid in liveset:
                tot.update(agents[cid].tokens)
                wall += agents[cid].wall
        return tot, wall

    lines = [
        "# tree.md: who launched whom",
        "",
        "The launch tree. Root is the orchestrating session; the five owner lanes sit under it, each owner's",
        "own lanes sit under the owner, and a handful of grandchildren sit under those (a spec-review lane that",
        "spawned its own standards and spec readers). Indentation is spawn depth. `subtree` columns add the node",
        "to everything below it, so an owner's subtree row is the real price of that ticket; `own` is the node",
        "alone. Wall clock sums are additive across lanes that ran in parallel, so the subtree minutes are",
        "agent-minutes, not elapsed minutes. Parent links come from each lane's `meta.json` (`parentAgentId`);",
        "for a depth-1 lane that field is absent and the parent is the root by construction.",
        "",
        GUIDE_SOURCE,
        "",
        "| lane | role | model | own wall (min) | own out tok | subtree agents | subtree wall (min) | subtree out tok | subtree total tok |",
        "|---|---|---|---|---|---|---|---|---|",
    ]

    def emit(aid, depth):
        a = agents[aid]
        if aid not in liveset:
            return
        st, wall = sub_tokens(aid)
        kids = [c for c in subtree(agents, aid) if c in liveset]
        total = st["input"] + st["output"] + st["cache_read"] + st["cache_create"]
        pad = "&nbsp;" * (depth * 4)
        label = "root session" if aid == "root" else cell(a.description, 52)
        lines.append(
            f"| {pad}{'↳ ' if depth else ''}`{aid[:9]}` {label} | {a.role} | {a.model} | {mins(a.wall)} | "
            f"{n(a.tokens['output'])} | {len(kids)} | {mins(wall)} | {n(st['output'])} | {n(total)} |"
        )
        for c in sorted(a.children, key=lambda c: agents[c].first or dt.datetime.max.replace(tzinfo=dt.timezone.utc)):
            emit(c, depth + 1)

    emit("root", 0)

    owners = [a for a in live if a.role == "owner"]
    ranked = []
    for o in owners:
        st, wall = sub_tokens(o.id)
        total = st["input"] + st["output"] + st["cache_read"] + st["cache_create"]
        ranked.append((total, st, wall, o))
    ranked.sort(reverse=True, key=lambda x: x[0])

    attempts = owner_attempts(owners)
    lines += ["", "## Owner subtrees, most expensive first", "",
              "Ticket #93 has two owner rows because its first owner was killed by the 13:15 rate limit and a",
              "fresh one was launched at 14:20; both subtrees were paid for.", "",
              "| owner | ticket | lanes | subtree wall (min) | output tok | total tok |", "|---|---|---|---|---|---|"]
    for total, st, wall, o in ranked:
        kids = [c for c in subtree(agents, o.id) if c in liveset]
        lines.append(f"| {cell(o.description, 44)}{attempts[o.id]} | #{ticket_of(o.description)} | {len(kids)} | "
                     f"{mins(wall)} | {n(st['output'])} | {n(total)} |")
    if ranked:
        top = ranked[0]
        lines += ["", f"The most expensive subtree is **{cell(top[3].description, 60)}** at {n(top[0])} total tokens "
                      f"across {len([c for c in subtree(agents, top[3].id) if c in liveset])} lanes "
                      f"({mins(top[2])} agent-minutes). Why: its lane count, not its per-lane size. "
                      "Every review round in this run costs a fresh reviewer lane and a fresh fix lane, each of which "
                      "re-reads the ticket, the playbooks and the diff from a cold context, so a ticket that needed "
                      "three rounds, a restart, or an arena pays the cold-start cost that many times over."]
    write("tree.md", lines)


def write_timeline(agents, live, trails):
    lines = [
        "# timeline.md: what happened when",
        "",
        "One block per owner: first the phases the owner itself recorded in `decisions.tsv`, then every lane it",
        "launched, with start, end and minutes. A phase row's end is the next phase's start, so a phase covers",
        "the wall time between two recorded decisions, not the effort inside it. Lane rows come from the",
        "transcripts and are exact. Two caveats on the trails: `#88`, `#89` and `#90` use the columns the brief",
        "describes (`ts, phase, decision, why, evidence, result`), but `#91` and `#93` use `ts, what, why,",
        "evidence, result` with no phase column at all, so their phase cells are blank and the decision text",
        "stands in. Timestamps are checked against the lane's own transcript and any that fall outside the lane's",
        "run are flagged row by row: `#88`, `#89` and `#90` are clean, `#91` drifts ahead of itself after midday,",
        "and `#93` is the worst case. There is one `decisions.tsv` per ticket, not one per owner, so the #93 trail",
        "is written twice below, once under the owner that the 13:15 rate limit killed and once under the owner",
        "that replaced it; both blocks show the same rows and each flags the ones that belong to the other. The",
        "root block at the end merges the registry's own timeline with the root transcript's Agent launches.",
        "",
        GUIDE_SOURCE,
        "",
    ]

    owners = sorted([a for a in live if a.role == "owner"], key=lambda a: a.first)
    attempts = owner_attempts(owners)
    for o in owners:
        ticket = ticket_of(o.description)
        tr = trails.get(ticket, {"rows": [], "notes": ["no trail"], "has_phase": False})
        lines += [f"## Owner {cell(o.description, 60)} (`{o.id}`), ticket #{ticket}{attempts[o.id]}", "",
                  f"Lane wall clock {cdt(o.first)} to {cdt(o.last)} ({mins(o.wall)} min).", ""]
        rows = tr["rows"]
        slack = dt.timedelta(minutes=5)
        for r in rows:
            r["outside"] = bool(r["ts"]) and not (o.first - slack <= r["ts"] <= o.last + slack)
        n_outside = sum(1 for r in rows if r["outside"])
        notes = list(tr["notes"])
        if n_outside:
            notes.append(f"{n_outside} of {len(rows)} rows carry a timestamp outside the lane's own run "
                         f"({cdt(o.first)} to {cdt(o.last)}), so the trail clock is not the run clock")
        if notes:
            lines += ["Trail problems: " + "; ".join(dict.fromkeys(notes)) + ".", ""]
        if not tr["has_phase"]:
            lines += ["This trail has no `phase` column; the decision text is shown instead.", ""]
        lines += ["| phase / decision | start (trail clock) | end | minutes |", "|---|---|---|---|"]
        for i, r in enumerate(rows):
            nxt = rows[i + 1]["ts"] if i + 1 < len(rows) else None
            end = nxt if (nxt and r["ts"] and nxt >= r["ts"]) else None
            dur = mins((end - r["ts"]).total_seconds()) if (end and r["ts"]) else "n/a"
            label = r["phase"] or cell(r["what"], 70)
            start = cdt_full(r["ts"]) if r["ts"] else r["raw_ts"]
            if r["outside"]:
                start += " (outside the run)"
            lines.append(f"| {label} | {start} | {cdt_full(end)} | {dur} |")
        lines += ["", "| lane launched | start | end | minutes |", "|---|---|---|---|"]
        for cid in sorted(o.children, key=lambda c: agents[c].launched_at or agents[c].first or o.first):
            c = agents[cid]
            if not c.messages:
                continue
            start = c.launched_at or c.first
            lines.append(f"| {with_model(c.description, c.model)} | {cdt(start)} | {cdt(c.last)} | "
                         f"{mins((c.last - start).total_seconds())} |")
        lines.append("")

    root = agents["root"]
    lines += ["## Root session", "",
              "The root's own timeline. Launch rows are `Agent` tool calls in the root transcript; the registry",
              "rows below repeat what `.claude/state/todo-program.md` recorded by hand, including the rate-limit",
              "pause from 13:15 to 13:50 CDT that killed four lanes and forced the serial restart at 13:55.", "",
              "| root launch | start | end | minutes |", "|---|---|---|---|"]
    for cid in sorted(root.children, key=lambda c: agents[c].launched_at or agents[c].first):
        c = agents[cid]
        if not c.messages:
            continue
        start = c.launched_at or c.first
        lines.append(f"| {with_model(c.description, c.model)} | {cdt(start)} | {cdt(c.last)} | "
                     f"{mins((c.last - start).total_seconds())} |")

    lines += ["", "### From the registry (hand-written, CDT as recorded)", ""]
    for raw in registry_lines():
        stripped = raw.strip()
        if stripped.startswith(("|", "#")) or not stripped:
            continue
        if not re.match(r"^(- |\d+\. )", stripped):
            continue
        if re.search(r"\d{1,2}:\d{2}|launched|verdict|rebased|Fan out|Restart|posted|chained", stripped):
            lines.append("- " + cell(re.sub(r"^(?:- )?(?:\[[ x]\] )?", "", stripped), 300))
    write("timeline.md", lines)


def write_waits(agents, live, gaps_by_agent):
    lines = [
        "# waits.md: where the time went",
        "",
        "For each lane, the ten longest gaps between consecutive messages, and the per-lane totals by class.",
        "Read the class sums first, at the bottom; the per-lane detail explains them. The four classes:",
        "**model latency** is the lane thinking and writing after a tool result came back; **tool time** is a tool",
        "running (for Bash the first 80 characters of the command are shown, which is usually enough to see a test",
        "suite or a `gh` call); **waiting on children** is a gap that a child lane's run spans, either a foreground",
        "`Agent` call or an idle stretch while background lanes worked; **turn ended** is a lane that stopped",
        "talking and was resumed later by a message from its parent, which is dead time nobody was using.",
        "",
        "The classification is derived, not recorded. A gap is tool time when the message before it issued a tool",
        "call and the message after it is that tool's result; model latency when the message after it is the lane",
        "speaking; waiting on children when the tool was `Agent`, or when a child lane's run covers at least half",
        "the gap; turn ended for everything else, which is a lane that fell silent and was later resumed. The logs",
        "carry no queue, throttle or scheduling field, so the 13:15-13:50 CDT rate limit is not labelled as such",
        "anywhere: it appears as a cluster of `turn ended` gaps starting around 13:11 in the lanes it killed, and",
        "those gaps are the single largest waits in the run.",
        "",
        GUIDE_SOURCE,
        "",
    ]

    order = sorted(live, key=lambda a: -sum(g["seconds"] for g in gaps_by_agent[a.id]))
    totals = collections.Counter()
    for a in order:
        gaps = gaps_by_agent[a.id]
        if not gaps:
            continue
        per = collections.Counter()
        for g in gaps:
            per[g["kind"]] += g["seconds"]
            totals[g["kind"]] += g["seconds"]
        lines += [f"## `{a.id}` {cell(a.description, 60)} ({a.role}, {a.model})", "",
                  "Class sums: " + ", ".join(f"{k} {mins(v)} min" for k, v in per.most_common()) + ".", "",
                  "| start | minutes | class | what |", "|---|---|---|---|"]
        for g in sorted(gaps, key=lambda g: -g["seconds"])[:10]:
            lines.append(f"| {cdt(g['start'])} | {mins(g['seconds'])} | {g['kind']} | {cell(g['label'], 90)} |")
        lines.append("")

    lines += ["## Overall", "", "| class | minutes | hours | share |", "|---|---|---|---|"]
    grand = sum(totals.values()) or 1
    for k, v in totals.most_common():
        lines.append(f"| {k} | {mins(v)} | {hm(v)} | {100.0 * v / grand:.1f}% |")
    lines.append(f"| **all gaps** | {mins(grand)} | {hm(grand)} | 100% |")
    lines += ["", "These minutes are agent-minutes summed over lanes that largely ran in parallel, so they exceed",
              "the run's elapsed time; the ratio between the classes is the point, not the absolute figure."]
    write("waits.md", lines)


def write_reads(agents, live):
    per_resource_agents = collections.defaultdict(set)
    per_resource_count = collections.Counter()
    for a in live:
        for tu in a.tool_uses.values():
            for res in resources_from(tu["name"], tu["input"]):
                per_resource_agents[res].add(a.id)
                per_resource_count[res] += 1

    ranked = sorted(per_resource_agents.items(), key=lambda kv: (-len(kv[1]), -per_resource_count[kv[0]]))

    lines = [
        "# reads.md: what every lane rediscovers",
        "",
        "Every file or resource opened by more than one lane, counted two ways: how many distinct lanes touched",
        "it, and how many times in total. Sources are the `Read` tool's `file_path` and Bash commands containing",
        "`cat`, `sed -n`, `head`, `git show`, `gh issue view N` or `gh pr view N`. Paths are normalised: the",
        "`.claude/worktrees/<lane>/` prefix and the repository root are stripped, so the same file read from",
        "thirty different worktrees collapses to one row. What this table shows is the re-reading tax: a lane",
        "starts cold, so the ticket body, the playbook and the standards get read again by every lane that needs",
        "them, and the count of distinct lanes is roughly the number of times the run paid for that file. Two",
        "limits: a `grep` or `rg` that printed a file's contents is not counted (only the six forms above are),",
        "and a Bash command that reads several files in one pipeline is counted once per file it names.",
        "",
        GUIDE_SOURCE,
        "",
        "| resource | distinct agents | total reads |",
        "|---|---|---|",
    ]
    for res, who in ranked[:60]:
        lines.append(f"| `{cell(res, 100)}` | {len(who)} | {per_resource_count[res]} |")

    lines += ["", "## The shared documents", "",
              "The specific things the run was built around: the ticket bodies, the merged PR the program",
              "started from, the repository's agent contract, the poteto-mode playbooks and the skill files.", "",
              "| resource | distinct agents | total reads |", "|---|---|---|"]

    def matches(res):
        if re.match(r"^(issue|PR) #(42|8[89]|9[0-3])$", res):
            return True
        if "AGENTS.md" in res or res.endswith("SKILL.md") or "/playbooks/" in res:
            return True
        return False

    special = [(r, w) for r, w in ranked if matches(r)]
    for res, who in special[:60]:
        lines.append(f"| `{cell(res, 100)}` | {len(who)} | {per_resource_count[res]} |")
    if not special:
        lines.append("| (nothing matched) | | |")
    write("reads.md", lines)


def write_tools(agents, live):
    per_role = collections.defaultdict(collections.Counter)
    durations = collections.defaultdict(list)
    for a in live:
        for tid, tu in a.tool_uses.items():
            per_role[tu["name"]][a.role] += 1
            end = a.tool_results.get(tid)
            if end:
                d = (end - tu["ts"]).total_seconds()
                if 0 <= d < 7200:
                    durations[tu["name"]].append(d)

    roles = sorted({a.role for a in live})
    lines = [
        "# tools.md: tool calls by role, and how long each tool took",
        "",
        "Which tools each kind of lane reached for, and the mean and median wall time of a call. Tool time is the",
        "gap between the assistant message carrying the `tool_use` block and the user message carrying its",
        "`tool_result`, so it includes any time the harness spent asking for permission or queueing, not just the",
        "command. `Agent` is an outlier by construction: a foreground `Agent` call's duration is the child lane's",
        "entire run, and a background one returns in a second, so its mean mixes the two and means little. Calls",
        "whose result never arrived (the lane was killed mid-call, which happened at the 13:15 rate limit) have no",
        "duration and are counted in the call totals but not in the timings.",
        "",
        GUIDE_SOURCE,
        "",
        "| tool | " + " | ".join(roles) + " | total | mean s | median s | max s |",
        "|---|" + "---|" * (len(roles) + 4),
    ]
    for tool, counter in sorted(per_role.items(), key=lambda kv: -sum(kv[1].values())):
        ds = sorted(durations.get(tool, []))
        mean = f"{sum(ds) / len(ds):.1f}" if ds else "n/a"
        med = f"{ds[len(ds) // 2]:.1f}" if ds else "n/a"
        mx = f"{ds[-1]:.1f}" if ds else "n/a"
        lines.append(f"| {tool} | " + " | ".join(str(counter.get(r, 0)) for r in roles) +
                     f" | {sum(counter.values())} | {mean} | {med} | {mx} |")
    write("tools.md", lines)


def write_summary(agents, live, gaps_by_agent, run_start, run_end):
    tot = collections.Counter()
    for a in live:
        tot.update(a.tokens)
    grand = tot["input"] + tot["output"] + tot["cache_read"] + tot["cache_create"]
    elapsed = (run_end - run_start).total_seconds()
    agent_wall = sum(a.wall for a in live)

    byrole = collections.defaultdict(collections.Counter)
    role_wall = collections.Counter()
    role_count = collections.Counter()
    for a in live:
        byrole[a.role].update(a.tokens)
        role_wall[a.role] += a.wall
        role_count[a.role] += 1

    liveset = {a.id for a in live}
    owners = [a for a in live if a.role == "owner"]
    pr_by_ticket = {"88": "PR #96", "89": "PR #94", "90": "PR #99", "91": "PR #101", "93": "PR #102"}

    lines = [
        "# summary.md: the run in numbers",
        "",
        "One session, five tickets, five stacked pull requests, 2026-09-22. The root session orchestrated; five",
        "owner lanes each ran a ticket end to end in its own git worktree; each owner launched its own explorers,",
        "architect or arena runners, a writer, reviewers and fix lanes; the root launched independent verifier",
        "lanes against each finished PR. Everything below is counted from the transcripts by `parse.py` in this",
        "directory. Read `waits.md` next: it is where the time actually went.",
        "",
        GUIDE_SOURCE,
        "",
        "## Totals",
        "",
        "| measure | value |",
        "|---|---|",
        f"| run, first message to last | {cdt_full(run_start)} to {cdt_full(run_end)} CDT ({hm(elapsed)}) |",
        f"| agents with a transcript | {len(live)} (root + {len(live) - 1} subagents) |",
        f"| summed agent wall clock | {hm(agent_wall)} ({agent_wall / max(elapsed, 1):.1f}x elapsed, so that much ran in parallel) |",
        f"| assistant turns | {n(sum(a.turns for a in live))} |",
        f"| tool calls | {n(sum(a.tool_calls for a in live))} |",
        f"| tokens, all kinds | {n(grand)} |",
        f"| fresh input tokens | {n(tot['input'])} |",
        f"| output tokens | {n(tot['output'])} |",
        f"| cache reads | {n(tot['cache_read'])} ({100.0 * tot['cache_read'] / max(1, grand):.1f}% of all tokens) |",
        f"| cache creates | {n(tot['cache_create'])} |",
        "",
        "## Tokens by role",
        "",
        "| role | lanes | wall (min) | output | cache create | cache read | all tokens |",
        "|---|---|---|---|---|---|---|",
    ]
    for role, t in sorted(byrole.items(), key=lambda kv: -(kv[1]["output"] + kv[1]["cache_create"] + kv[1]["cache_read"])):
        allt = t["input"] + t["output"] + t["cache_read"] + t["cache_create"]
        lines.append(f"| {role} | {role_count[role]} | {mins(role_wall[role])} | {n(t['output'])} | "
                     f"{n(t['cache_create'])} | {n(t['cache_read'])} | {n(allt)} |")

    lines += ["", "## Tokens per pull request", "",
              "Each owner's subtree: the owner lane plus every lane it launched. The root's own cost and the",
              "verifier lanes it ran are listed separately because they are not chargeable to one ticket.", "",
              "Ticket #93 is charged twice: its first owner was killed by the 13:15 rate limit and a fresh owner",
              "was launched at 14:20, so the run paid for both subtrees and shipped one PR.", "",
              "| PR | ticket | owner subtree lanes | wall (min) | all tokens |", "|---|---|---|---|---|"]
    charged = set()
    attempts = owner_attempts(owners)
    for o in sorted(owners, key=lambda a: a.first):
        ticket = ticket_of(o.description)
        ids = [c for c in subtree(agents, o.id) if c in liveset]
        charged.update(ids)
        t = collections.Counter()
        w = 0.0
        for cid in ids:
            t.update(agents[cid].tokens)
            w += agents[cid].wall
        allt = t["input"] + t["output"] + t["cache_read"] + t["cache_create"]
        lines.append(f"| {pr_by_ticket.get(ticket, '?')} | #{ticket}{attempts[o.id]} | {len(ids)} | "
                     f"{mins(w)} | {n(allt)} |")

    rest = [a for a in live if a.id not in charged]
    t = collections.Counter()
    for a in rest:
        t.update(a.tokens)
    allt = t["input"] + t["output"] + t["cache_read"] + t["cache_create"]
    lines.append(f"| (root, verifiers, post-mortem) | - | {len(rest)} | "
                 f"{mins(sum(a.wall for a in rest))} | {n(allt)} |")

    lines += ["", "## The five biggest single costs", "",
              "One lane each, ranked by total tokens.", "",
              "| lane | all tokens | what it was |", "|---|---|---|"]
    costly = sorted(live, key=lambda a: -(a.tokens["input"] + a.tokens["output"] + a.tokens["cache_read"] + a.tokens["cache_create"]))[:5]
    for a in costly:
        allt = a.tokens["input"] + a.tokens["output"] + a.tokens["cache_read"] + a.tokens["cache_create"]
        kids = len([c for c in agents[a.id].children if c in liveset])
        sentence = (f"{cell(a.description, 60)}: {'an' if a.role[0] in 'aeiou' else 'a'} {a.role} lane on {a.model} that ran {mins(a.wall)} min over "
                    f"{a.turns} turns and {a.tool_calls} tool calls, launched {kids} lanes of its own, and spent "
                    f"{a.cache_share:.0f}% of its input on cache reads of a context it kept re-sending.")
        lines.append(f"| `{a.id[:9]}` | {n(allt)} | {sentence} |")

    all_gaps = []
    for a in live:
        for g in gaps_by_agent[a.id]:
            all_gaps.append((g, a))
    all_gaps.sort(key=lambda x: -x[0]["seconds"])
    lines += ["", "## The five biggest single waits", "",
              "One gap each, ranked by length. A gap is the silence between two consecutive messages in one lane.", "",
              "| lane | start | minutes | class | what it was |", "|---|---|---|---|---|"]
    for g, a in all_gaps[:5]:
        if g["kind"] == CHILDREN and g["who"]:
            what = ("the lane had nothing to do while " +
                    ", ".join(cell(agents[c].description, 40) for c in g["who"][:3]) + " ran.")
        elif g["kind"] == TURN_ENDED and dt.time(12, 55) <= g["start"].astimezone(CDT).time() <= dt.time(13, 20):
            what = (f"the 13:15 rate limit: the lane went silent at {cdt(g['start'])} and was only resumed at "
                    f"{cdt(g['end'])}, after the serial restart.")
        elif g["kind"] == TURN_ENDED:
            what = f"the lane ended its turn and sat idle until its parent messaged it at {cdt(g['end'])}."
        elif g["kind"] == TOOL_TIME:
            what = f"one tool call took this long: {cell(g['label'], 70)}."
        else:
            what = "the model was thinking and writing, with no tool running and no child lane out."
        lines.append(f"| `{a.id[:9]}` {cell(a.description, 34)} | {cdt(g['start'])} | "
                     f"{mins(g['seconds'])} | {g['kind']} | {what} |")

    lines += ["", "## What the logs do not hold", "",
              "- Requested effort per call. The models sheet asks for `@high`, `@medium`, `@xhigh`; the transcripts",
              "  record only the model family, so no table here can show effort.",
              "- Cost in currency. Only token counts are recorded.",
              "- The post-mortem itself. The two lanes writing this report share the run's session, so they appear in",
              "  every table and their own numbers were still growing when the tables were written.",
              "- A queue or rate-limit field. The 13:15-13:50 CDT pause is visible only as a long silence, and shows",
              "  up in `waits.md` as `turn ended` gaps that open around 13:01-13:11 and close at 14:01.",
              "- Owner trails `#91` and `#93` have no `phase` column and several placeholder or out-of-order",
              "  timestamps; `timeline.md` names each one under its block.",
              "",
              "## The other tables",
              "",
              "`agents.md` one row per lane. `tree.md` the launch tree and per-owner subtree cost. `timeline.md`",
              "phases and launches per owner plus the root's timeline. `waits.md` the time breakdown.",
              "`reads.md` what every lane re-reads. `tools.md` tool counts and durations."]
    write("summary.md", lines)


def write(name, lines):
    path = os.path.join(OUT, name)
    with open(path, "w") as fh:
        fh.write("\n".join(lines).rstrip() + "\n")
    print("wrote", path, file=sys.stderr)


if __name__ == "__main__":
    main()
