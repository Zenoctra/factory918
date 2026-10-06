"""Shared machinery for the quick tests: boxes, the safe Claude Code runner,
the ~/.claude guard, transcript reading and the blind judge.

Python 3 standard library only. Every model call goes through the standalone
Claude Code CLI on Manuel's subscription (#153 decision 4), never the API.
"""

from __future__ import annotations

import concurrent.futures as cf
import datetime as dt
import glob
import hashlib
import json
import os
import random
import re
import shutil
import subprocess
import sys
import time
from dataclasses import dataclass, field
from pathlib import Path

KIT = Path(__file__).resolve().parent.parent
HOME = Path.home()

# --------------------------------------------------------------------------
# Locations
# --------------------------------------------------------------------------


def main_checkout() -> Path:
    """Manuel's main checkout: the repository whose .git the kit's worktree shares."""
    if os.environ.get("QT_MAIN"):
        return Path(os.environ["QT_MAIN"]).resolve()
    common = subprocess.run(
        ["git", "-C", str(KIT), "rev-parse", "--path-format=absolute", "--git-common-dir"],
        capture_output=True, text=True, check=True,
    ).stdout.strip()
    return Path(common).parent.resolve()


def slug(path: str | Path) -> str:
    return re.sub(r"[^A-Za-z0-9]", "-", str(path))


def projects_dir() -> Path:
    """Where Claude Code keeps this repository's transcripts."""
    return HOME / ".claude" / "projects" / slug(main_checkout())


def scratch_tree() -> Path:
    """Where Claude Code keeps this repository's session scratchpads (and the kit's worktree)."""
    uid = os.getuid()
    return Path(f"/private/tmp/claude-{uid}") / slug(main_checkout())


# Boxes live outside every protected tree, under a neutral name (the Eval
# playbook's blinding rule: no "test", "eval", "judge" ... in what a candidate sees).
BOX_ROOT = Path(os.environ.get("QT_BOX_ROOT", "/private/tmp/wsbox"))


def find_cli() -> str:
    """The standalone Claude Code CLI bundled with the desktop app, newest first."""
    if os.environ.get("QT_CLAUDE"):
        return os.environ["QT_CLAUDE"]
    pattern = str(HOME / "Library/Application Support/Claude/claude-code/*/*/claude.app/Contents/MacOS/claude")
    found = sorted(glob.glob(pattern), key=lambda p: [int(x) for x in re.findall(r"\d+", p.split("claude-code/")[1].split("/")[0])])
    if not found:
        sys.exit("no bundled Claude Code CLI found; set QT_CLAUDE")
    return found[-1]


# --------------------------------------------------------------------------
# Boxes: a disposable directory holding a repo at one commit and a scratchpad
# --------------------------------------------------------------------------


@dataclass
class Box:
    root: Path

    @property
    def repo(self) -> Path:
        return self.root / "factory918"

    @property
    def scratch(self) -> Path:
        return self.root / "scratchpad"

    @property
    def private(self) -> Path:
        """Per-box tool state the model never needs to see: tmp, gh and git config."""
        return self.root / ".box"


def new_box_path(tag: str) -> Path:
    stamp = dt.datetime.now().strftime("%Y%m%d-%H%M%S")
    return BOX_ROOT / f"{tag}-{stamp}-{random.randrange(16**4):04x}"


def make_box(root: Path, commit: str | None, branch: str | None = None) -> Box:
    """Create a box whose repo holds only the history up to `commit`.

    The repo is a fresh `git init` that fetches one commit from the main
    checkout, so it has no remote, no later branches and no shared object
    store: nothing done in it reaches the main checkout or GitHub.
    """
    box = Box(root)
    for d in (box.scratch, box.private / "tmp", box.private / "gh"):
        d.mkdir(parents=True, exist_ok=True)
    (box.private / "gitconfig").write_text(
        "[user]\n\tname = Manuel\n\temail = manuel@localhost\n[init]\n\tdefaultBranch = main\n"
        "[advice]\n\tdetachedHead = false\n"
    )
    if commit is None:
        return box
    main = main_checkout()
    full = subprocess.run(["git", "-C", str(main), "rev-parse", "--verify", f"{commit}^{{commit}}"],
                          capture_output=True, text=True, check=True).stdout.strip()
    env = git_env(box)
    subprocess.run(["git", "init", "-q", str(box.repo)], check=True, env=env)
    subprocess.run(["git", "-C", str(box.repo), "fetch", "-q", "--no-tags", str(main), full], check=True, env=env)
    if branch:
        subprocess.run(["git", "-C", str(box.repo), "checkout", "-q", "-B", branch, full], check=True, env=env)
    else:
        subprocess.run(["git", "-C", str(box.repo), "checkout", "-q", "--detach", full], check=True, env=env)
    return box


def copy_box(seed: Box, root: Path) -> Box:
    shutil.copytree(seed.root, root, symlinks=True)
    return Box(root)


def git_env(box: Box) -> dict:
    env = dict(os.environ)
    env.update(GIT_CONFIG_GLOBAL=str(box.private / "gitconfig"), GIT_CONFIG_NOSYSTEM="1")
    return env


# --------------------------------------------------------------------------
# The safe runner
# --------------------------------------------------------------------------

READ_TOOLS = ["Read", "Grep", "Glob"]
# The tool surface of a working lane. WebFetch and WebSearch are left out:
# a box has no network, and the past is not on the web.
WORK_TOOLS = ["Read", "Grep", "Glob", "Edit", "Write", "NotebookEdit", "Bash", "Skill", "Agent",
              "TodoWrite", "ToolSearch"]


def safe_env(box: Box) -> dict:
    """A clean environment: nothing inherited from the session that launched the kit.

    GitHub is unreachable twice over: gh has no credentials (an empty
    GH_CONFIG_DIR, no token variables) and the sandbox allows no network.
    Git sees no global or system config, so no credential helper either.
    """
    env = {
        "HOME": str(HOME),
        "USER": os.environ.get("USER", "manuel"),
        "LOGNAME": os.environ.get("USER", "manuel"),
        "PATH": "/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin",
        "LANG": "en_US.UTF-8",
        "TERM": "dumb",
        "SHELL": "/bin/zsh",
        "TMPDIR": str(box.private / "tmp"),
        "GH_CONFIG_DIR": str(box.private / "gh"),
        "GIT_CONFIG_GLOBAL": str(box.private / "gitconfig"),
        "GIT_CONFIG_NOSYSTEM": "1",
        # No reads from or writes to Manuel's auto-memory.
        "CLAUDE_CODE_DISABLE_AUTO_MEMORY": "1",
    }
    return env


def settings_for(box: Box, mode: str) -> dict:
    """Permission and sandbox settings, passed with --settings.

    mode "read": Read, Grep and Glob only. mode "work": a lane's usual tools,
    with Bash inside the OS sandbox and file edits allowed only inside the box.
    Everything not allowed is denied (dontAsk), nothing prompts.
    """
    main = str(main_checkout())
    protected_reads = [main, str(projects_dir()), str(scratch_tree())]
    protected_writes = protected_reads + [str(HOME / ".claude")]
    deny = ["WebFetch", "WebSearch"]
    deny += [f"Read(/{p}/**)" for p in protected_reads]
    deny += [f"Edit(/{p}/**)" for p in protected_writes]
    allow = list(READ_TOOLS)
    if mode == "work":
        allow += [f"Edit(/{box.root}/**)", "Bash", "Skill", "Agent", "TodoWrite", "ToolSearch"]
    return {
        "permissions": {"defaultMode": "dontAsk", "allow": allow, "deny": deny},
        "sandbox": {
            "enabled": True,
            "failIfUnavailable": True,
            "autoAllowBashIfSandboxed": True,
            "allowUnsandboxedCommands": False,
            "network": {"allowedDomains": []},
            "filesystem": {
                "allowWrite": [str(box.root)],
                "denyWrite": protected_writes,
                "denyRead": protected_reads,
            },
        },
    }


@dataclass
class RunResult:
    out_dir: Path
    ok: bool
    final: str
    structured: object | None
    cost_usd: float
    duration_s: float
    num_turns: int
    tool_calls: list = field(default_factory=list)
    denied: list = field(default_factory=list)
    init: dict = field(default_factory=dict)
    error: str = ""


def run_claude(box: Box, prompt: str, out_dir: Path, *, mode: str = "work", cwd: Path | None = None,
               system_prompt: str | None = None, append_system_prompt: str | None = None,
               model: str = "claude-opus-5-5", effort: str = "high", json_schema: dict | None = None,
               tools: list | None = None, timeout_s: int = 3600, hooks: bool = True) -> RunResult:
    """One non-interactive Claude Code session in `box`, recorded under `out_dir`.

    Writes: prompt.md, settings.json, command.txt, stream.jsonl (every event),
    stderr.txt and result.json (the summary). The session is never persisted
    to ~/.claude/projects (--no-session-persistence).
    """
    out_dir.mkdir(parents=True, exist_ok=True)
    cwd = cwd or (box.repo if box.repo.exists() else box.scratch)
    settings = settings_for(box, mode)
    if not hooks:
        settings["disableAllHooks"] = True
    settings_path = box.private / f"settings-{out_dir.name}.json"
    settings_path.write_text(json.dumps(settings, indent=2))
    (out_dir / "settings.json").write_text(json.dumps(settings, indent=2))
    (out_dir / "prompt.md").write_text(prompt)
    if tools is None:
        tools = READ_TOOLS if mode == "read" else WORK_TOOLS
    cmd = [find_cli(), "-p", "--no-session-persistence", "--output-format", "stream-json", "--verbose",
           "--setting-sources", "project", "--settings", str(settings_path), "--strict-mcp-config",
           "--model", model, "--effort", effort, "--tools", ",".join(tools)]
    if system_prompt is not None:
        cmd += ["--system-prompt", system_prompt]
        (out_dir / "system-prompt.txt").write_text(system_prompt)
    if append_system_prompt:
        cmd += ["--append-system-prompt", append_system_prompt]
        (out_dir / "append-system-prompt.txt").write_text(append_system_prompt)
    if json_schema is not None:
        cmd += ["--json-schema", json.dumps(json_schema)]
    (out_dir / "command.txt").write_text(" ".join(json.dumps(c) if " " in c or "\n" in c else c for c in cmd[:-1] if c != system_prompt and c != append_system_prompt) + f"\n(cwd: {cwd})\n")
    t0 = time.time()
    with open(out_dir / "stream.jsonl", "w") as so, open(out_dir / "stderr.txt", "w") as se:
        try:
            proc = subprocess.run(cmd, input=prompt, stdout=so, stderr=se, text=True, cwd=str(cwd),
                                  env=safe_env(box), timeout=timeout_s)
            rc = proc.returncode
        except subprocess.TimeoutExpired:
            rc = -9
    res = parse_stream(out_dir / "stream.jsonl", out_dir)
    res.duration_s = round(time.time() - t0, 1)
    if rc != 0 and not res.error:
        res.error = f"exit {rc}: " + (out_dir / "stderr.txt").read_text()[-500:]
        res.ok = False
    (out_dir / "result.json").write_text(json.dumps({
        "ok": res.ok, "error": res.error, "final": res.final, "structured": res.structured,
        "cost_usd": res.cost_usd, "duration_s": res.duration_s, "num_turns": res.num_turns,
        "model": model, "effort": effort, "mode": mode, "cwd": str(cwd),
        "tool_calls": len(res.tool_calls), "denied": res.denied,
    }, indent=2))
    (out_dir / "final.md").write_text(res.final or "")
    return res


def parse_stream(path: Path, out_dir: Path) -> RunResult:
    res = RunResult(out_dir=out_dir, ok=False, final="", structured=None, cost_usd=0.0, duration_s=0.0, num_turns=0)
    uses = {}
    for line in path.read_text().splitlines():
        try:
            ev = json.loads(line)
        except json.JSONDecodeError:
            continue
        t = ev.get("type")
        if t == "system" and ev.get("subtype") == "init":
            res.init = ev
        elif t == "assistant":
            for b in (ev.get("message") or {}).get("content") or []:
                if b.get("type") == "tool_use":
                    uses[b["id"]] = b
        elif t == "user":
            content = (ev.get("message") or {}).get("content")
            if isinstance(content, list):
                for b in content:
                    if b.get("type") == "tool_result":
                        u = uses.get(b.get("tool_use_id"), {})
                        text = flatten(b.get("content"))
                        res.tool_calls.append({"name": u.get("name"), "input": u.get("input"),
                                               "is_error": bool(b.get("is_error")), "result": text[:4000]})
        elif t == "result":
            res.final = ev.get("result") or ""
            res.structured = ev.get("structured_output")
            res.cost_usd = ev.get("total_cost_usd") or 0.0
            res.num_turns = ev.get("num_turns") or 0
            res.ok = not ev.get("is_error") and ev.get("subtype") == "success"
            if not res.ok:
                res.error = str(ev.get("subtype")) + ": " + str(ev.get("errors") or ev.get("result") or "")[:500]
            res.denied = [{"tool": d.get("tool_name"), "input": d.get("tool_input")} for d in ev.get("permission_denials") or []]
    return res


def flatten(content) -> str:
    if content is None:
        return ""
    if isinstance(content, str):
        return content
    parts = []
    for b in content:
        if isinstance(b, dict):
            t = b.get("text") if b.get("text") is not None else b.get("content")
            parts.append(t if isinstance(t, str) else json.dumps(b)[:200])
        else:
            parts.append(str(b))
    return "\n".join(parts)


def run_many(jobs: list, parallel: int = 4) -> list:
    """Run (callable) jobs in parallel threads; each job starts one CLI process."""
    with cf.ThreadPoolExecutor(max_workers=max(1, parallel)) as ex:
        futs = [ex.submit(j) for j in jobs]
        return [f.result() for f in futs]


# --------------------------------------------------------------------------
# The guard: prove nothing reached Manuel's settings, memory or transcripts
# --------------------------------------------------------------------------


def _guarded_files() -> list[Path]:
    c = HOME / ".claude"
    files = [c / "settings.json", c / "settings.local.json", c / "CLAUDE.md", HOME / ".claude.json"]
    files += [Path(p) for p in glob.glob(str(c / "*.md"))]
    for sub in ("skills", "agents", "commands", "hooks", "plugins/installed_plugins.json"):
        p = c / sub
        if p.is_file():
            files.append(p)
        elif p.is_dir():
            files += [Path(x) for x in glob.glob(str(p / "**"), recursive=True) if Path(x).is_file()]
    files += [Path(x) for x in glob.glob(str(c / "projects" / "*" / "memory" / "**"), recursive=True) if Path(x).is_file()]
    return sorted(set(files))


def guard_snapshot() -> dict:
    """Hashes of Manuel's settings and memory files, and the set of transcript files."""
    snap = {"files": {}, "transcripts": sorted(glob.glob(str(HOME / ".claude" / "projects" / "*" / "*.jsonl")))}
    for p in _guarded_files():
        if p == HOME / ".claude.json":
            # The CLI rewrites its own state file on every start (counters, caches).
            # Only its permission-relevant keys are compared.
            try:
                j = json.loads(p.read_text())
                keep = {k: j.get(k) for k in ("projects",) if k in j}
                proj = keep.get("projects") or {}
                keep["projects"] = {k: {kk: v.get(kk) for kk in ("allowedTools", "mcpServers", "hasTrustDialogAccepted")}
                                    for k, v in proj.items() if isinstance(v, dict)}
                snap["files"][str(p)] = hashlib.sha256(json.dumps(keep, sort_keys=True).encode()).hexdigest()
            except Exception:
                pass
            continue
        try:
            snap["files"][str(p)] = hashlib.sha256(p.read_bytes()).hexdigest()
        except OSError:
            pass
    return snap


def guard_check(before: dict) -> list[str]:
    after = guard_snapshot()
    problems = []
    for p, h in after["files"].items():
        if p not in before["files"]:
            problems.append(f"new file: {p}")
        elif before["files"][p] != h:
            problems.append(f"changed: {p}")
    for p in before["files"]:
        if p not in after["files"]:
            problems.append(f"removed: {p}")
    new_tx = sorted(set(after["transcripts"]) - set(before["transcripts"]))
    # Transcripts written by other live sessions are not ours; only box-cwd ones would be.
    for t in new_tx:
        if slug(BOX_ROOT) in t:
            problems.append(f"new transcript from a box: {t}")
    return problems


def box_projects_dirs() -> list[Path]:
    """Claude Code state dirs the CLI made for cwds in boxes that no longer exist
    (tool-result spill files). A live box's dir is kept: another batch may be using it."""
    live = [slug(p) for p in BOX_ROOT.iterdir()] if BOX_ROOT.exists() else []
    dirs = [Path(p) for p in glob.glob(str(HOME / ".claude" / "projects" / (slug(BOX_ROOT) + "-*")))]
    return [d for d in dirs if not any(d.name.startswith(l) for l in live)]


def check_main_untouched(before_status: str) -> list[str]:
    now = git_status_main()
    return [] if now == before_status else ["main checkout status changed:\n" + now]


def git_status_main() -> str:
    return subprocess.run(["git", "-C", str(main_checkout()), "status", "--porcelain=v1", "--branch"],
                          capture_output=True, text=True).stdout


# --------------------------------------------------------------------------
# Transcripts (read-only: every function here reads, none writes)
# --------------------------------------------------------------------------


def load_rows(path: Path) -> list[dict]:
    rows = []
    with open(path) as fh:
        for line in fh:
            line = line.strip()
            if line:
                try:
                    rows.append(json.loads(line))
                except json.JSONDecodeError:
                    pass
    return rows


def first_user_text(rows: list[dict]) -> str:
    for r in rows:
        if r.get("type") == "user":
            c = (r.get("message") or {}).get("content")
            return c if isinstance(c, str) else flatten(c)
    return ""


def final_text(rows: list[dict]) -> str:
    for r in reversed(rows):
        if r.get("type") == "assistant":
            c = (r.get("message") or {}).get("content") or []
            texts = [b.get("text", "") for b in c if isinstance(b, dict) and b.get("type") == "text"]
            if texts:
                return "\n".join(texts)
    return ""


def models_used(rows: list[dict]) -> list[str]:
    seen = []
    for r in rows:
        m = (r.get("message") or {}).get("model")
        if r.get("type") == "assistant" and m and not m.startswith("<") and m not in seen:
            seen.append(m)
    return seen


def snapshot_system_prompt(rows: list[dict]) -> str | None:
    for r in rows:
        a = r.get("attachment") or {}
        if a.get("type") == "prompt_snapshot" and a.get("systemPrompt"):
            parts = [p for p in a["systemPrompt"] if not p.startswith("<total_tokens>")]
            return "\n\n".join(parts)
    return None


def skill_listing(rows: list[dict]) -> str:
    for r in rows:
        a = r.get("attachment") or {}
        if a.get("type") == "skill_listing":
            return a.get("content") or flatten(r.get("rendered")) or json.dumps(a)[:4000]
    return ""


def tool_calls(rows: list[dict]) -> list[dict]:
    """Every tool call in order, with its result text."""
    uses, calls = {}, []
    for r in rows:
        c = (r.get("message") or {}).get("content")
        if r.get("type") == "assistant" and isinstance(c, list):
            for b in c:
                if b.get("type") == "tool_use":
                    uses[b["id"]] = b
                    calls.append({"id": b["id"], "name": b["name"], "input": b.get("input") or {}, "result": None,
                                  "is_error": False, "ts": r.get("timestamp")})
        if r.get("type") == "user" and isinstance(c, list):
            for b in c:
                if b.get("type") == "tool_result":
                    for call in calls:
                        if call["id"] == b.get("tool_use_id"):
                            call["result"] = flatten(b.get("content"))
                            call["is_error"] = bool(b.get("is_error"))
    return calls


_LINE_NO = re.compile(r"^\s*(\d+)\t(.*)$")


def read_result_lines(text: str) -> dict[int, str]:
    """Parse a Read tool result (cat -n style) into {line number: text}."""
    out = {}
    if not text or "<persisted-output>" in text[:40]:
        return out
    for line in text.split("\n"):
        m = _LINE_NO.match(line)
        if m:
            out[int(m.group(1))] = m.group(2)
    return out


def reconstruct_reads(calls: list[dict]) -> dict[str, str]:
    """Files the original read with the Read tool, rebuilt from its results.

    Only files whose lines were seen contiguously from line 1 to the end of
    the last read are returned; a file seen with gaps is left out.
    """
    lines: dict[str, dict[int, str]] = {}
    for c in calls:
        if c["name"] != "Read" or c["is_error"] or not c["result"]:
            continue
        p = c["input"].get("file_path")
        if not p:
            continue
        lines.setdefault(p, {}).update(read_result_lines(c["result"]))
    out = {}
    for p, ls in lines.items():
        if not ls:
            continue
        n = max(ls)
        if all(i in ls for i in range(1, n + 1)):
            out[p] = "\n".join(ls[i] for i in range(1, n + 1)) + "\n"
    return out


def reconstruct_writes(calls: list[dict]) -> dict[str, str]:
    """Files the original wrote with Write and Edit, replayed in order.

    An Edit on a file this replay never saw written is skipped (its base is unknown).
    """
    files: dict[str, str] = {}
    for c in calls:
        i = c["input"]
        if c["is_error"]:
            continue
        if c["name"] == "Write" and "file_path" in i:
            files[i["file_path"]] = i.get("content", "")
        elif c["name"] == "Edit" and i.get("file_path") in files:
            s = files[i["file_path"]]
            old, new = i.get("old_string", ""), i.get("new_string", "")
            files[i["file_path"]] = s.replace(old, new) if i.get("replace_all") else s.replace(old, new, 1)
    return files


def paths_written(calls: list[dict]) -> set[str]:
    """Absolute paths the original wrote: Write/Edit targets and shell redirections."""
    out = set()
    for c in calls:
        i = c["input"]
        if c["name"] in ("Write", "Edit", "NotebookEdit") and i.get("file_path"):
            out.add(i["file_path"])
        if c["name"] == "Bash":
            cmd = i.get("command", "")
            for m in re.finditer(r"(?:>>?|\btee(?:\s+-a)?)\s*(?:\"([^\"]+)\"|'([^']+)'|(/[^\s;|&<>]+))", cmd):
                p = m.group(1) or m.group(2) or m.group(3)
                if p and p.startswith("/") and not p.startswith("/dev/"):
                    out.add(p)
    return out


def heredoc_writes(calls: list[dict]) -> dict[str, str]:
    """Files the original wrote with `cat > PATH <<'X'` heredocs, last write wins."""
    out = {}
    pat = re.compile(r"cat\s*>\s*(?:\"([^\"]+)\"|'([^']+)'|(\S+))\s*<<-?\s*['\"]?(\w+)['\"]?\n(.*?)\n\4\s*$", re.S | re.M)
    for c in calls:
        if c["name"] == "Bash" and not c["is_error"]:
            for m in pat.finditer(c["input"].get("command", "")):
                p = m.group(1) or m.group(2) or m.group(3)
                if p.startswith("/"):
                    out[p] = m.group(5) + "\n"
    return out


def abs_paths_in(text: str) -> set[str]:
    """Absolute paths mentioned in text (quoted or backticked forms included; spaces allowed inside quotes)."""
    found = set()
    for m in re.finditer(r"[`\"'](/(?:Users|private|tmp|var)/[^`\"'\n]+)[`\"']", text):
        found.add(m.group(1).rstrip("/.,:;"))
    for m in re.finditer(r"(?<![\w`\"'])(/(?:private|tmp|var)/[^\s`\"'<>)]+)", text):
        found.add(m.group(1).rstrip("/.,:;"))
    # A path alone on its line, spaces allowed, as briefs often set one out.
    for m in re.finditer(r"^\s*(/(?:Users|private|tmp|var)/[^\n`\"']+?)\s*$", text, re.M):
        found.add(m.group(1).rstrip("/.,:;"))
    return found


def find_agent_transcript(agent: str) -> Path:
    """Resolve an agent id, a file name or a path to a subagent transcript."""
    p = Path(agent).expanduser()
    if p.exists():
        return p
    aid = agent.removeprefix("agent-").removesuffix(".jsonl")
    hits = glob.glob(str(projects_dir() / "*" / "subagents" / "**" / f"agent-{aid}.jsonl"), recursive=True)
    if not hits:
        sys.exit(f"no transcript for agent {agent} under {projects_dir()}")
    return Path(hits[0])


def agent_meta(path: Path) -> dict:
    m = path.with_name(path.name[:-len(".jsonl")] + ".meta.json")
    return json.loads(m.read_text()) if m.exists() else {}


def parent_after(path: Path, meta: dict, turns: int = 10) -> tuple[str | None, str]:
    """What the launching agent did after this subagent finished.

    Finds the parent transcript holding the Agent call `meta["toolUseId"]`
    and returns the parent's assistant texts and tool calls stamped after the
    subagent's last message (a background lane's result arrives later than
    its launch returns), up to `turns` assistant messages.
    """
    tuid = meta.get("toolUseId")
    if not tuid:
        return None, ""
    own = load_rows(path)
    end = max((r["timestamp"] for r in own if r.get("timestamp")), default="")
    # Layout: <projects>/<session>.jsonl is the root; its subagents are under
    # <projects>/<session>/subagents/ (possibly nested). The parent is either.
    session = next(p for p in path.parents if p.parent.parent.name == "projects")
    candidates = [session.parent / (session.name + ".jsonl")]
    candidates += [Path(p) for p in glob.glob(str(session / "subagents" / "**" / "*.jsonl"), recursive=True)]
    for cand in candidates:
        if not cand.exists() or cand == path:
            continue
        rows = load_rows(cand)
        launched = any(r.get("type") == "assistant" and any(
            b.get("type") == "tool_use" and b.get("id") == tuid
            for b in ((r.get("message") or {}).get("content") or []) if isinstance(b, dict)) for r in rows)
        if not launched:
            continue
        out, n = [], 0
        for r in rows:
            if r.get("type") != "assistant" or (r.get("timestamp") or "") < end:
                continue
            for b in (r.get("message") or {}).get("content") or []:
                if b.get("type") == "text" and b.get("text", "").strip():
                    out.append(f"[{r.get('timestamp', '')[:19]}] says: {b['text'].strip()}")
                elif b.get("type") == "tool_use":
                    out.append(f"[{r.get('timestamp', '')[:19]}] {b['name']}: {json.dumps(b.get('input'))[:600]}")
            n += 1
            if n >= turns:
                break
        return str(cand), "\n\n".join(out)
    return None, ""


# --------------------------------------------------------------------------
# Path remapping
# --------------------------------------------------------------------------


def remap(text: str, mapping: list[tuple[str, str]]) -> str:
    for old, new in sorted(mapping, key=lambda kv: -len(kv[0])):
        text = text.replace(old, new)
    return text


def default_mapping(box: Box, extra_roots: list[str] = ()) -> list[tuple[str, str]]:
    """Old absolute roots to box paths: worktrees and the checkout to the box repo,
    session scratchpads to the box scratchpad."""
    main = str(main_checkout())
    mapping = [(main, str(box.repo))]
    for wt in glob.glob(os.path.join(main, ".claude", "worktrees", "*")):
        mapping.append((wt, str(box.repo)))
    for r in extra_roots:
        mapping.append((r, str(box.repo)))
    return mapping


def scratchpad_mapping(text: str, box: Box) -> list[tuple[str, str]]:
    out = []
    for m in set(re.findall(r"/private/tmp/claude-\d+/[^/\s`\"']+/[0-9a-f-]{36}/scratchpad", text)):
        out.append((m, str(box.scratch)))
        out.append((m.replace("/private/tmp/", "/tmp/", 1), str(box.scratch)))
    return out


# --------------------------------------------------------------------------
# The blind judge (#153 decision 8, the Eval playbook's single-pass rule)
# --------------------------------------------------------------------------


def blind_ids(n: int, seed: int) -> list[str]:
    rng = random.Random(seed)
    ids = [f"R{k:02d}" for k in range(1, n + 1)]
    rng.shuffle(ids)
    return ids


def judge(prompt: str, schema: dict, out_dir: Path, *, model: str = "claude-opus-5-5", effort: str = "high") -> dict:
    """One judge call: no tools, no repo, structured output.

    The judge runs in an empty box with tools disabled, so it can read only
    what the prompt carries.
    """
    box = make_box(new_box_path("j"), None)
    try:
        res = run_claude(box, prompt, out_dir, mode="read", tools=[], model=model, effort=effort,
                         json_schema=schema, cwd=box.scratch, hooks=False,
                         system_prompt="You assess written material carefully and answer in the requested structure.")
    finally:
        shutil.rmtree(box.root, ignore_errors=True)
    if res.structured is None:
        # Fall back to the last JSON object in the text.
        m = re.search(r"\{.*\}\s*$", res.final or "", re.S)
        if m:
            try:
                return json.loads(m.group(0))
            except json.JSONDecodeError:
                pass
        raise RuntimeError(f"judge returned no structured output; see {out_dir}")
    return res.structured


# --------------------------------------------------------------------------
# What a run left behind
# --------------------------------------------------------------------------

SKIP_DIRS = {".git", ".box", "node_modules", "__pycache__"}


def tree_hashes(root: Path) -> dict[str, str]:
    out = {}
    if not root.exists():
        return out
    for dirpath, dirnames, filenames in os.walk(root):
        dirnames[:] = [d for d in dirnames if d not in SKIP_DIRS]
        for f in filenames:
            p = Path(dirpath) / f
            if p.is_symlink() or not p.is_file():
                continue
            try:
                out[str(p.relative_to(root))] = hashlib.sha256(p.read_bytes()).hexdigest()
            except OSError:
                pass
    return out


def collect_outputs(box: Box, seed_hashes: dict[str, str], seed_head: str | None, out_dir: Path,
                    final: str, cap: int = 20000) -> str:
    """Copy every file the run created or changed into out_dir/written/ and write output.md.

    output.md is what a judge reads: the final message, then each changed
    file, then the commits the run made in the box repo.
    """
    now = tree_hashes(box.root)
    changed = sorted(p for p, h in now.items() if seed_hashes.get(p) != h)
    removed = sorted(p for p in seed_hashes if p not in now)
    wdir = out_dir / "written"
    for rel in changed:
        dst = wdir / rel
        dst.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(box.root / rel, dst)
    commits = ""
    if seed_head and (box.repo / ".git").exists():
        commits = subprocess.run(["git", "-C", str(box.repo), "log", "--stat", "--format=commit %h %s", f"{seed_head}..HEAD"],
                                 capture_output=True, text=True, env=git_env(box)).stdout
    parts = ["## Final message\n", final.strip() or "(empty)", ""]
    for rel in changed:
        p = box.root / rel
        try:
            text = p.read_text()
        except (UnicodeDecodeError, OSError):
            text = "(binary)"
        if len(text) > cap:
            text = text[:cap] + f"\n... ({len(text) - cap} more characters, see written/{rel})"
        parts += [f"## File written: {rel}\n", "```", text.rstrip(), "```", ""]
    if removed:
        parts += ["## Files removed\n", "\n".join(removed), ""]
    if commits.strip():
        parts += ["## Commits made\n", "```", commits.strip(), "```", ""]
    text = "\n".join(parts)
    (out_dir / "output.md").write_text(text)
    write_json(out_dir / "changed-files.json", {"changed": changed, "removed": removed})
    return text


def repo_head(box: Box) -> str | None:
    if not (box.repo / ".git").exists():
        return None
    return subprocess.run(["git", "-C", str(box.repo), "rev-parse", "HEAD"], capture_output=True, text=True,
                          env=git_env(box)).stdout.strip() or None


# --------------------------------------------------------------------------
# Small helpers
# --------------------------------------------------------------------------


def write_json(path: Path, obj) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(obj, indent=2, ensure_ascii=False) + "\n")


def now_stamp() -> str:
    return dt.datetime.now().strftime("%Y%m%d-%H%M%S")


def safety_preamble() -> tuple[dict, str]:
    """Take the guard snapshot and the main checkout's status before any run."""
    return guard_snapshot(), git_status_main()


def account_identifiers() -> list[str]:
    """The logged-in account's email and ids, which must never land in a pushed trial."""
    try:
        j = json.loads(subprocess.run([find_cli(), "auth", "status"], capture_output=True, text=True,
                                      timeout=60).stdout)
    except Exception:
        return []
    return [str(j[k]) for k in ("email", "orgId", "accountUuid") if j.get(k)]


def privacy_check(out_dir: Path) -> list[str]:
    """Names any file under out_dir that carries the account's email or ids (the repo is public)."""
    ids = account_identifiers()
    hits = []
    for p in out_dir.rglob("*"):
        if p.is_file():
            try:
                text = p.read_text(errors="ignore")
            except OSError:
                continue
            if any(i in text for i in ids):
                hits.append(f"account identifier in {p}")
    return hits


def safety_verdict(before: tuple[dict, str], out_dir: Path, name: str = "safety.json") -> list[str]:
    """After a batch: check the guard, the main checkout and the output's privacy,
    and clear the CLI's box state dirs."""
    snap, status = before
    problems = guard_check(snap) + check_main_untouched(status) + privacy_check(out_dir)
    leftovers = [str(p) for p in box_projects_dirs()]
    for p in box_projects_dirs():
        shutil.rmtree(p, ignore_errors=True)
    write_json(out_dir / name, {"problems": problems, "box_state_dirs_removed": leftovers,
                                          "checked_at": now_stamp()})
    return problems
