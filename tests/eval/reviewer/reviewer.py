#!/usr/bin/env python3
"""Re-run a frozen reviewer brief against one model N times and score the reports (ticket #103).

    python3 tests/eval/reviewer/reviewer.py check [--list]
        Validate the fixture set; calibrate every label against the historical report where one
        survives. --list prints the brief ids.
    python3 tests/eval/reviewer/reviewer.py run <descriptor> <round>/<axis> <N>
        Ensure runs 1..N exist. A Codex model is dispatched through pstack-runner and scored here.
        A Claude model prints one JSON launch line per run for the session to pass to Agent.
        A withheld model gets a dropout receipt.
    python3 tests/eval/reviewer/reviewer.py collect
        Collect every finished Claude run; list what is in flight, unlaunched or stuck. Safe to
        repeat.
    python3 tests/eval/reviewer/reviewer.py table
        Rescore every collected report from the raw files; write scores.tsv and table.md.

A launch line is {"run", "agent", "description", "prompt"}: pass `agent` (subagent_type, and model
for Sonnet), `description` and `prompt` to the Agent tool in the background, then poll `collect`.

Environment, each with a default: REVIEWER_FIXTURES (this directory), REVIEWER_OUT
(<repository>/.scratch/eval/reviewer), REVIEWER_WORK (${TMPDIR:-/tmp}/review-work),
REVIEWER_TRANSCRIPTS (~/.claude/projects/<main checkout path, every character outside A-Za-z0-9
as ->), REVIEWER_RUNNER (the vendored pstack-runner), REVIEWER_REPO (the repository holding the
reviewed heads), REVIEWER_TIMEOUT (seconds for pstack-runner; unset means none).
"""
from __future__ import annotations

import argparse
import json
import os
import re
import secrets
import shutil
import statistics
import subprocess
import sys
from dataclasses import asdict, dataclass
from datetime import datetime
from pathlib import Path, PurePosixPath
from typing import Iterable, Literal, Mapping

Axis = Literal["standards", "spec"]
AXES: tuple[Axis, ...] = ("standards", "spec")
BANNED = ("eval", "test", "judge", "score", "benchmark", "candidate", "rubric", "experiment",
          "compare", "arena")
HARD_HEADINGS = ("Would break", "Fails open")
EFFORT: Mapping[Axis, str] = {"standards": "medium", "spec": "high"}
COUNT_LINE = re.compile(r"hard findings: ([0-9]+)")
ITEM_LINE = re.compile(r"(\d+)\. ")


@dataclass(frozen=True, order=True)
class BriefId:
    round: str
    axis: Axis

    def __str__(self) -> str:
        return f"{self.round}/{self.axis}"

    @staticmethod
    def parse(s: str) -> BriefId | None:
        round_, _, axis = s.partition("/")
        return BriefId(round_, axis) if round_ and axis in AXES else None


@dataclass(frozen=True)
class Brief:
    id: BriefId
    head: str
    files: Path
    report_relpath: PurePosixPath


@dataclass(frozen=True)
class Label:
    brief: BriefId
    id: str
    kind: Literal["fixed", "hole"]
    anchors: tuple[re.Pattern[str], ...]

    def matches(self, text: str) -> bool:
        return all(a.search(text) for a in self.anchors)


@dataclass(frozen=True)
class Fixtures:
    briefs: Mapping[BriefId, Brief]
    labels: Mapping[BriefId, tuple[Label, ...]]


@dataclass(frozen=True)
class Native:
    agent: Mapping[str, str]
    expect: re.Pattern[str]


@dataclass(frozen=True)
class External:
    slug: str


@dataclass(frozen=True)
class Withheld:
    reason: str


Route = Native | External | Withheld

MODELS: Mapping[str, Route] = {
    "claude:sonnet": Native({"subagent_type": "general-purpose", "model": "sonnet"}, re.compile(r"^claude-sonnet-")),
    "claude:opus-5": Native({"subagent_type": "tier-lower"}, re.compile(r"^claude-opus-5$")),
    "claude:opus-5.5": Native({"subagent_type": "tier-upper"}, re.compile(r"^claude-opus-5-5$")),
    "claude:fable-5.1": Withheld("operator rule 2026-09-22, Fable is not launched"),
    "codex:gpt-6-astra": External("gpt-6-astra"),
    "codex:gpt-6-terra": External("gpt-6-terra"),
    "codex:gpt-6-sol": External("gpt-6-sol"),
}


@dataclass(frozen=True)
class RunId:
    descriptor: str
    brief: BriefId
    k: int

    def dir(self, out: Path) -> Path:
        return out / "runs" / self.descriptor.replace(":", "-") / self.brief.round / self.brief.axis / str(self.k)

    def to_json(self) -> dict:
        return {"descriptor": self.descriptor, "round": self.brief.round, "axis": self.brief.axis, "k": self.k}

    @staticmethod
    def from_json(j: dict) -> RunId:
        return RunId(j["descriptor"], BriefId(j["round"], j["axis"]), j["k"])


@dataclass(frozen=True)
class Prepared:
    run: RunId
    nonce: str
    checkout: Path
    prompt: str


@dataclass(frozen=True)
class Tokens:
    input: int
    cache_read: int
    cache_write: int
    output: int


Status = Literal["complete", "dropout", "contaminated"]


@dataclass(frozen=True)
class Receipt:
    run: RunId
    status: Status
    detail: str
    reported_model: str | None
    model_verified: bool
    effort: str | None
    tokens: Tokens | None
    wall_ms: int | None
    source: Path


Failure = Literal["no-report", "no-count-line", "count-exceeds-items", "no-hard-headings",
                  "timed-out", "child-failed", "malformed-output"]
RUNNER_FAILURES: tuple[Failure, ...] = ("timed-out", "child-failed", "malformed-output")


@dataclass(frozen=True)
class Item:
    n: int
    hard: bool
    text: str


@dataclass(frozen=True)
class Score:
    run: RunId
    failure: Failure | None
    hits: frozenset[str]
    demoted: frozenset[str]
    unlabeled: int
    labels: int


class Refusal(Exception):
    """Printed as `reviewer: <msg>` on stderr, exit 1."""


def natural(name: str) -> list:
    return [int(t) if t.isdigit() else t for t in re.split(r"(\d+)", name)]


def load_fixtures(root: Path) -> Fixtures:
    def bad(path: Path, line: int, what: str) -> Refusal:
        return Refusal(f"fixtures: {path.relative_to(root)}:{line}: {what}")

    rounds = root / "rounds"
    if not rounds.is_dir():
        raise bad(rounds, 0, "missing")
    briefs: dict[BriefId, Brief] = {}
    for rdir in sorted((d for d in rounds.iterdir() if d.is_dir()), key=lambda d: natural(d.name)):
        rfile = rdir / "round"
        if not rfile.is_file():
            raise bad(rfile, 0, "missing")
        head = None
        for i, line in enumerate(rfile.read_text().splitlines(), 1):
            key, sep, value = line.partition("=")
            if line.strip() and not sep:
                raise bad(rfile, i, f"not key=value: {line}")
            if key.strip() == "head":
                head = value.strip()
                if not re.fullmatch(r"[0-9a-f]{40}", head):
                    raise bad(rfile, i, f"head is not 40 hex: {head}")
        if head is None:
            raise bad(rfile, 0, "no head")
        review = rdir / "review"
        for axis in AXES:
            bfile = review / f"{axis}-brief.md"
            if not bfile.is_file():
                raise bad(bfile, 0, "missing")
            text = bfile.read_text()
            m = re.search(r"^Write your report to `([^`]+)`", text, re.M)
            if not m:
                raise bad(bfile, 0, "no `Write your report to` line")
            relpath = PurePosixPath(m.group(1))
            review_dir = str(relpath.parent)
            for i, line in enumerate(text.splitlines(), 1):
                for name in re.findall(re.escape(review_dir) + r"/([A-Za-z0-9._-]+)", line):
                    name = name.rstrip(".")
                    if not name.endswith("-report.md") and not (review / name).is_file():
                        raise bad(bfile, i, f"names {review_dir}/{name}, which review/ lacks")
            briefs[BriefId(rdir.name, axis)] = Brief(BriefId(rdir.name, axis), head, review, relpath)

    lfile = root / "labels"
    if not lfile.is_file():
        raise bad(lfile, 0, "missing")
    labels: dict[BriefId, list[Label]] = {b: [] for b in briefs}
    for i, line in enumerate(lfile.read_text().splitlines(), 1):
        if not line.strip() or line.startswith("#"):
            continue
        cols = line.split("\t")
        if len(cols) != 5:
            raise bad(lfile, i, f"{len(cols)} columns, want 5: brief, id, kind, anchors, title")
        brief_s, lid, kind, anchors_s, _title = cols
        bid = BriefId.parse(brief_s)
        if bid not in briefs:
            raise bad(lfile, i, f"unknown brief {brief_s}")
        if not re.fullmatch(r"[SP][1-9][0-9]*", lid):
            raise bad(lfile, i, f"id {lid} is not S<n> or P<n>")
        if kind not in ("fixed", "hole"):
            raise bad(lfile, i, f"kind {kind} is not fixed or hole")
        if any(label.id == lid for label in labels[bid]):
            raise bad(lfile, i, f"{brief_s} {lid} is labeled twice")
        parts = anchors_s.split(" && ")
        if len(parts) < 2:
            raise bad(lfile, i, "fewer than two anchors")
        compiled = []
        for p in parts:
            try:
                compiled.append(re.compile(p))
            except re.error as e:
                raise bad(lfile, i, f"anchor {p!r}: {e}") from None
        labels[bid].append(Label(bid, lid, kind, tuple(compiled)))
    return Fixtures(briefs, {b: tuple(v) for b, v in labels.items()})


def normalize(text: str) -> str:
    return re.sub(r"\s+", " ", re.sub(r"[`*]", "", text.lower())).strip()


def parse_report(text: str | None) -> list[Item] | Failure:
    if text is None:
        return "no-report"
    lines = text.splitlines()
    counts = [m for line in lines if (m := COUNT_LINE.fullmatch(line.rstrip()))]
    if not counts:
        return "no-count-line"
    if not any(line.startswith("## ") and line[3:].strip() in HARD_HEADINGS for line in lines):
        return "no-hard-headings"
    items: list[Item] = []
    heading = None
    current: tuple[int, bool, list[str]] | None = None

    def close() -> None:
        if current:
            items.append(Item(current[0], current[1], normalize(" ".join(current[2]))))

    for line in lines:
        if line.startswith("## "):
            close()
            current, heading = None, line[3:].strip()
            continue
        m = ITEM_LINE.match(line)
        # `## Walk` lines are numbered steps, not findings.
        if m and heading != "Walk":
            close()
            current = (int(m.group(1)), heading in HARD_HEADINGS, [line[m.end():]])
        elif current and not COUNT_LINE.fullmatch(line.rstrip()):
            current[2].append(line)
    close()
    if int(counts[-1].group(1)) > sum(1 for i in items if i.hard):
        return "count-exceeds-items"
    return items


def claims(hard: list[Item], labels: tuple[Label, ...]) -> dict[int, int]:
    """Label index -> hard item index, one to one, most anchors first, then item order, then label order."""
    pairs = sorted((-len(label.anchors), ii, li)
                   for ii, item in enumerate(hard) for li, label in enumerate(labels) if label.matches(item.text))
    by_label: dict[int, int] = {}
    for _, ii, li in pairs:
        if li not in by_label and ii not in by_label.values():
            by_label[li] = ii
    return by_label


def score(run: RunId, parsed: list[Item] | Failure, labels: tuple[Label, ...]) -> Score:
    if isinstance(parsed, str):
        return Score(run, parsed, frozenset(), frozenset(), 0, len(labels))
    hard = [i for i in parsed if i.hard]
    claimed = claims(hard, labels)
    hits = frozenset(labels[li].id for li in claimed)
    unlabeled = sum(1 for ii, item in enumerate(hard)
                    if ii not in claimed.values() and not any(label.matches(item.text) for label in labels))
    demoted = frozenset(label.id for label in labels
                        if label.id not in hits and any(label.matches(i.text) for i in parsed if not i.hard))
    return Score(run, None, hits, demoted, unlabeled, len(labels))


def calibrate(parsed: list[Item] | Failure, labels: tuple[Label, ...]) -> list[tuple[Label, str | None]]:
    if isinstance(parsed, str):
        return [(label, f"the historical report is a context failure: {parsed}") for label in labels]
    hard = [i for i in parsed if i.hard]
    claimed = claims(hard, labels)
    result = []
    for li, label in enumerate(labels):
        want = int(label.id[1:])
        got = hard[claimed[li]].n if li in claimed else None
        matched = [i.n for i in parsed if label.matches(i.text)]
        ok = got == want and matched == [want]
        result.append((label, None if ok else f"claimed by item {got}, matched by items {matched}; want item {want} alone"))
    return result


def stamp(s: str) -> datetime:
    return datetime.fromisoformat(s.replace("Z", "+00:00"))


def receipt_from_transcript(run: RunId, lines: list[dict], expect: re.Pattern[str], checkout: Path,
                            source: Path) -> Receipt:
    assistant = [line for line in lines if line.get("type") == "assistant"]
    models = sorted({m for line in assistant
                     if (m := (line.get("message") or {}).get("model")) and m != "<synthetic>"})
    wrong = [m for m in models if not expect.search(m)]
    if wrong or not models:
        raise Refusal(f"{run.descriptor} {run.brief} run {run.k} was served {', '.join(wrong) or 'no model'}; "
                      f"{run.descriptor} pins {expect.pattern}; the agent definition drifted: fix it, "
                      f"remove the run directory, rerun")
    usage: dict[str, dict] = {}
    for i, line in enumerate(assistant):
        u = (line.get("message") or {}).get("usage")
        if u:
            usage[line.get("requestId") or f"line {i}"] = u
    tokens = Tokens(*(sum(u.get(k) or 0 for u in usage.values())
                      for k in ("input_tokens", "cache_read_input_tokens", "cache_creation_input_tokens", "output_tokens")))
    stamps = [stamp(line["timestamp"]) for line in lines if line.get("timestamp")]
    wall_ms = int((stamps[-1] - stamps[0]).total_seconds() * 1000) if stamps else None
    effort = next((line["effort"] for line in lines if line.get("effort")), None)

    root = os.path.normpath(str(checkout))

    def inside(p: str) -> bool:
        p = os.path.normpath(p)
        return os.path.isabs(p) and (p == root or p.startswith(root + os.sep))

    reaches = []
    for line in assistant:
        content = (line.get("message") or {}).get("content")
        for c in content if isinstance(content, list) else ():
            if not isinstance(c, dict) or c.get("type") != "tool_use":
                continue
            name, args = c.get("name"), c.get("input") or {}
            if name in ("Read", "Write", "Edit") and not inside(args.get("file_path", "")):
                reaches.append(f"{name} {args.get('file_path', '')}")
            elif name in ("Grep", "Glob") and not args.get("path"):
                reaches.append(f"{name} with no path")
            elif name in ("Grep", "Glob") and not inside(args["path"]):
                reaches.append(f"{name} {args['path']}")
            elif name == "Bash" and root not in args.get("command", ""):
                reaches.append(f"Bash {args.get('command', '')[:120]}")
    status: Status = "contaminated" if reaches else "complete"
    return Receipt(run, status, "; ".join(reaches) or "complete", models[-1], True, effort, tokens, wall_ms, source)


def receipt_from_runner(run: RunId, pstack: dict, source: Path) -> Receipt:
    """A runner failure stays a complete receipt whose detail names it; `run_failure` reads it back."""
    status = pstack.get("status")
    u = pstack.get("usage")
    tokens = None
    if u:
        cached = u.get("cachedInputTokens") or 0
        tokens = Tokens((u.get("inputTokens") or 0) - cached, cached, u.get("cacheCreationInputTokens") or 0,
                        u.get("outputTokens") or 0)
    ran = status == "complete" or status in RUNNER_FAILURES
    return Receipt(run, "complete" if ran else "dropout", status if ran else f"{status}: {pstack.get('error')}",
                   pstack.get("reportedModel"), bool(pstack.get("modelVerified")), pstack.get("effort"),
                   tokens, pstack.get("elapsedMs"), source)


def run_failure(receipt: Receipt) -> Failure | None:
    return receipt.detail if receipt.detail in RUNNER_FAILURES else None


def noise(scores: Iterable[Score], axis: Axis) -> Mapping[str, tuple[float, float, float, float]]:
    """Descriptor -> (recall, min_k, max_k, sd) over its replicate recalls; descriptors with no labels are left out."""
    by: dict[str, list[Score]] = {}
    for s in scores:
        if s.run.brief.axis == axis:
            by.setdefault(s.run.descriptor, []).append(s)
    bands = {}
    for d, ss in by.items():
        total = sum(s.labels for s in ss)
        if not total:
            continue
        reps: dict[int, tuple[int, int]] = {}
        for s in ss:
            h, n = reps.get(s.run.k, (0, 0))
            reps[s.run.k] = (h + len(s.hits), n + s.labels)
        rr = [h / n for h, n in reps.values() if n]
        bands[d] = (sum(len(s.hits) for s in ss) / total, min(rr), max(rr), statistics.pstdev(rr))
    return bands


def within(bands: Mapping[str, tuple[float, float, float, float]]) -> frozenset[str]:
    if not bands:
        return frozenset()
    floor = bands[max(bands, key=lambda d: bands[d][0])][1]
    return frozenset(d for d, band in bands.items() if band[0] >= floor)


COLUMNS = ("model", "axis", "runs", "context failures", "recall", "min_k", "max_k", "sd", "within noise",
           "demoted", "unlabeled/brief", "out tokens", "in tokens", "cache read", "cache write", "wall s",
           "contaminated")


def order(descriptor: str) -> tuple:
    names = list(MODELS)
    return (names.index(descriptor) if descriptor in names else len(names), descriptor)


def render_table(scores: list[Score], receipts: list[Receipt]) -> str:
    def mean(xs: list[float], places: int) -> str:
        return f"{sum(xs) / len(xs):.{places}f}" if xs else "n/a"

    def cells(row: Iterable[str]) -> str:
        return "| " + " | ".join(row) + " |"

    by_run = {r.run: r for r in receipts}
    keys = {(s.run.descriptor, s.run.brief.axis) for s in scores}
    keys |= {(r.run.descriptor, r.run.brief.axis) for r in receipts if r.status == "contaminated"}
    bands = {axis: noise(scores, axis) for axis in AXES}
    near = {axis: within(bands[axis]) for axis in AXES}
    rows = [cells(COLUMNS), cells("---" for _ in COLUMNS)]
    for d, axis in sorted(keys, key=lambda k: (order(k[0]), AXES.index(k[1]))):
        ss = [s for s in scores if s.run.descriptor == d and s.run.brief.axis == axis]
        clean = [s for s in ss if s.failure is None]
        tok = [by_run[s.run].tokens for s in ss if s.run in by_run and by_run[s.run].tokens]
        walls = [by_run[s.run].wall_ms / 1000 for s in ss if s.run in by_run and by_run[s.run].wall_ms is not None]
        hits, labels = sum(len(s.hits) for s in ss), sum(s.labels for s in ss)
        band = bands[axis].get(d)
        rows.append(cells([
            d, axis, str(len(ss)), str(sum(1 for s in ss if s.failure)),
            f"{hits}/{labels} ({hits / labels:.2f})" if labels else "n/a",
            *([f"{band[1]:.2f}", f"{band[2]:.2f}", f"{band[3]:.2f}", "yes" if d in near[axis] else "no"]
              if band else ["n/a"] * 4),
            str(sum(len(s.demoted) for s in ss)),
            mean([s.unlabeled for s in clean], 2),
            mean([t.output for t in tok], 0), mean([t.input for t in tok], 0),
            mean([t.cache_read for t in tok], 0), mean([t.cache_write for t in tok], 0),
            mean(walls, 1),
            str(sum(1 for r in receipts if r.status == "contaminated" and r.run.descriptor == d and r.run.brief.axis == axis)),
        ]))
    dropped = []
    for d in sorted({r.run.descriptor for r in receipts}, key=order):
        mine = [r for r in receipts if r.run.descriptor == d]
        if all(r.status == "dropout" for r in mine):
            dropped.append(cells([d, f"dropout {mine[0].detail.split(':', 1)[0]}", str(mine[0].source)]))
    if dropped:
        rows += ["", cells(["model", "result", "receipt"]), cells(["---"] * 3), *dropped]
    return "\n".join(rows) + "\n"


# Everything below touches git, the filesystem or subprocesses.

@dataclass(frozen=True)
class Env:
    fixtures: Path
    out: Path
    work: Path
    transcripts: Path
    runner: Path
    repo: Path
    timeout: str | None


def git(cwd: Path, *args: str) -> str:
    return subprocess.run(["git", "-C", str(cwd), *args], capture_output=True, text=True, check=True).stdout.strip()


def load_env() -> Env:
    here = Path(__file__).resolve().parent
    top = Path(git(here, "rev-parse", "--show-toplevel"))
    transcripts = os.environ.get("REVIEWER_TRANSCRIPTS")
    if not transcripts:
        main = Path(git(top, "rev-parse", "--path-format=absolute", "--git-common-dir")).parent
        transcripts = str(Path.home() / ".claude" / "projects" / re.sub(r"[^A-Za-z0-9]", "-", str(main)))
    return Env(
        fixtures=Path(os.environ.get("REVIEWER_FIXTURES") or here),
        out=Path(os.environ.get("REVIEWER_OUT") or top / ".scratch" / "eval" / "reviewer"),
        work=Path(os.environ.get("REVIEWER_WORK") or Path(os.environ.get("TMPDIR") or "/tmp") / "review-work"),
        transcripts=Path(transcripts),
        runner=Path(os.environ.get("REVIEWER_RUNNER")
                    or top / "template/.agents/skills/poteto-mode/scripts/runner/pstack-runner"),
        repo=Path(os.environ.get("REVIEWER_REPO") or top),
        timeout=os.environ.get("REVIEWER_TIMEOUT") or None,
    )


def write_json(path: Path, value: dict) -> None:
    path.write_text(json.dumps(value, indent=2) + "\n")


def read_jsonl(path: Path) -> list[dict]:
    lines = []
    for raw in path.read_text().splitlines():
        try:
            lines.append(json.loads(raw))
        except json.JSONDecodeError:
            continue  # a transcript still being written can end mid-line
    return lines


def receipt_json(r: Receipt) -> dict:
    return {"version": 1, "run": r.run.to_json(), "route": type(MODELS[r.run.descriptor]).__name__.lower(),
            "status": r.status, "detail": r.detail, "reported_model": r.reported_model,
            "model_verified": r.model_verified, "effort": r.effort,
            "tokens": asdict(r.tokens) if r.tokens else None, "wall_ms": r.wall_ms, "source": str(r.source)}


def receipt_at(d: Path) -> Receipt | None:
    path = d / "receipt.json"
    if not path.is_file():
        return None
    j = json.loads(path.read_text())
    return Receipt(RunId.from_json(j["run"]), j["status"], j["detail"], j["reported_model"], j["model_verified"],
                   j["effort"], Tokens(**j["tokens"]) if j["tokens"] else None, j["wall_ms"], Path(j["source"]))


def prepared_at(d: Path) -> Prepared | None:
    path = d / "run.json"
    if not path.is_file():
        return None
    j = json.loads(path.read_text())
    return Prepared(RunId.from_json(j["run"]), j["nonce"], Path(j["checkout"]), j["prompt"])


def state(d: Path) -> Literal["absent", "prepared", "collected", "broken"]:
    if not d.exists():
        return "absent"
    if (d / "receipt.json").is_file():
        return "collected"
    return "prepared" if (d / "run.json").is_file() else "broken"


def plan(run: RunId, brief: Brief, work: Path) -> Prepared:
    nonce = secrets.token_hex(6)
    checkout = work / nonce / "factory918"
    prompt = (f"Read `{checkout}/{brief.report_relpath.parent}/{run.brief.axis}-brief.md` whole and follow it. "
              f"You are working in `{checkout}`; every relative path in the brief is relative to it.")
    seen = [w for w in BANNED if w in prompt.lower()]
    if seen:
        raise Refusal(f"the reviewer's prompt would carry {seen[0]!r} ({checkout}); set REVIEWER_WORK to a path without it")
    return Prepared(run, nonce, checkout, prompt)


def materialize(p: Prepared, brief: Brief, env: Env) -> None:
    d = p.run.dir(env.out)
    d.parent.mkdir(parents=True, exist_ok=True)
    try:
        d.mkdir()
    except FileExistsError:
        raise Refusal(f"{d} appeared while this run started: another run holds it") from None
    p.checkout.mkdir(parents=True)
    with subprocess.Popen(["git", "-C", str(env.repo), "archive", brief.head], stdout=subprocess.PIPE) as archive:
        subprocess.run(["tar", "-x", "-C", str(p.checkout)], stdin=archive.stdout, check=True)
    if archive.returncode:
        raise Refusal(f"git archive {brief.head} failed; remove {d} and rerun")
    target = p.checkout / brief.report_relpath.parent
    target.mkdir(parents=True, exist_ok=True)
    other = next(a for a in AXES if a != brief.id.axis)
    for f in sorted(brief.files.iterdir()):
        if f.is_file() and f.name != f"{other}-brief.md" and not f.name.endswith(".historical.md"):
            shutil.copyfile(f, target / f.name)
    (d / "prompt.txt").write_text(p.prompt)
    write_json(d / "run.json", {"run": p.run.to_json(), "nonce": p.nonce, "checkout": str(p.checkout), "prompt": p.prompt})


def launch_line(p: Prepared, brief: Brief, out: Path) -> str:
    route = MODELS[p.run.descriptor]
    assert isinstance(route, Native)
    return json.dumps({"run": str(p.run.dir(out)), "agent": dict(route.agent),
                       "description": f"Review {brief.head[:7]} {p.run.brief.axis}", "prompt": p.prompt})


def dispatch(p: Prepared, route: External, env: Env) -> dict:
    d = p.run.dir(env.out)
    argv = [str(env.runner), "--parent", "claude", "--provider", "codex", "--model", route.slug,
            "--effort", EFFORT[p.run.brief.axis], "--mode", "isolated-write", "--prompt", str(d / "prompt.txt"),
            "--cwd", str(p.checkout), "--output", str(d / "runner-output.md"),
            "--receipt", str(d / "runner-receipt.json")]
    if env.timeout:
        argv += ["--timeout", env.timeout]
    proc = subprocess.run(argv, capture_output=True, text=True)
    path = d / "runner-receipt.json"
    if not path.is_file():
        raise Refusal(f"pstack-runner exited {proc.returncode} with no receipt for {d}: "
                      f"{proc.stderr.strip()[-300:]}; remove {d} and rerun")
    return json.loads(path.read_text())


def rescore(receipt: Receipt, fx: Fixtures, out: Path) -> Score:
    if receipt.run.brief not in fx.briefs:
        raise Refusal(f"{receipt.run.dir(out)} names brief {receipt.run.brief}, which the fixture set lacks")
    report = receipt.run.dir(out) / "report.md"
    parsed = run_failure(receipt) or parse_report(report.read_text() if report.is_file() else None)
    return score(receipt.run, parsed, fx.labels[receipt.run.brief])


def collect_one(p: Prepared, receipt: Receipt, brief: Brief, fx: Fixtures, out: Path) -> str:
    d = p.run.dir(out)
    report = p.checkout / brief.report_relpath
    if receipt.status != "dropout" and not run_failure(receipt) and report.is_file():
        shutil.copyfile(report, d / "report.md")
    write_json(d / "receipt.json", receipt_json(receipt))
    shutil.rmtree(p.checkout.parent, ignore_errors=True)
    if receipt.status == "dropout":
        return f"dropout {d} {receipt.detail}"
    if receipt.status == "contaminated":
        return f"contaminated {d}: {receipt.detail}"
    s = rescore(receipt, fx, out)
    if s.failure:
        return f"{d} context-failure {s.failure}"
    t = receipt.tokens
    wall = f"{receipt.wall_ms / 1000:.0f}s" if receipt.wall_ms is not None else "n/a"
    return (f"{d} recall {len(s.hits)}/{s.labels} unlabeled {s.unlabeled} demoted {len(s.demoted)} "
            f"tokens in/out {t.input if t else 'n/a'}/{t.output if t else 'n/a'} wall {wall}")


def first_user_text(path: Path) -> str:
    for line in read_jsonl(path):
        if line.get("type") == "user":
            content = (line.get("message") or {}).get("content")
            if isinstance(content, list):
                return " ".join(c.get("text", "") for c in content if isinstance(c, dict))
            return content or ""
    return ""


def locate(prepared: Mapping[RunId, Prepared], root: Path, out: Path) -> Mapping[RunId, Path | None]:
    if not root.is_dir():
        raise Refusal(f"no transcripts at {root}; set REVIEWER_TRANSCRIPTS")
    found: dict[RunId, list[Path]] = {run: [] for run in prepared}
    for path in sorted(root.glob("*/subagents/agent-*.jsonl")):
        text = first_user_text(path)
        for run, p in prepared.items():
            if p.nonce in text:
                found[run].append(path)
    for run, paths in found.items():
        if len(paths) > 1:
            d = run.dir(out)
            raise Refusal(f"{d} has {len(paths)} transcripts {' '.join(map(str, paths))}: "
                          f"one prompt was launched twice; remove {d} and rerun")
    return {run: paths[0] if paths else None for run, paths in found.items()}


def finished(lines: list[dict]) -> bool:
    last = next((line for line in reversed(lines) if line.get("type") == "assistant"), None)
    return bool(last) and (last.get("message") or {}).get("stop_reason") == "end_turn"


def cmd_check(fx: Fixtures, list_only: bool) -> int:
    if list_only:
        print("\n".join(str(b) for b in fx.briefs))
        return 0
    bad = 0
    for bid, labels in fx.labels.items():
        if not labels:
            continue
        hist = fx.briefs[bid].files / f"{bid.axis}-report.historical.md"
        if not hist.is_file():
            for label in labels:
                print(f"unchecked {bid} {label.id}: no historical report")
            continue
        for label, problem in calibrate(parse_report(hist.read_text()), labels):
            print(f"ok {bid} {label.id}" if problem is None else f"mismatch {bid} {label.id}: {problem}")
            bad += problem is not None
    if bad:
        raise Refusal(f"{bad} label(s) do not calibrate against their historical report")
    return 0


def cmd_run(fx: Fixtures, env: Env, descriptor: str, bid: BriefId, n: int) -> int:
    route, brief, out = MODELS[descriptor], fx.briefs[bid], env.out
    runs = [RunId(descriptor, bid, k) for k in range(1, n + 1)]
    if isinstance(route, Withheld):
        d = runs[0].dir(out)
        if state(d) == "collected":
            print(f"dropout {d}")
            return 0
        d.mkdir(parents=True, exist_ok=True)
        r = Receipt(runs[0], "dropout", f"withheld: {route.reason}", None, False, None, None, None, d / "receipt.json")
        write_json(d / "receipt.json", receipt_json(r))
        print(f"dropout {d} {r.detail}")
        return 0
    if subprocess.run(["git", "-C", str(env.repo), "cat-file", "-e", f"{brief.head}^{{commit}}"],
                      capture_output=True).returncode:
        raise Refusal(f"round {bid.round} head {brief.head} is not in this repository's objects; "
                      f"the fixture pins it as refs/keep/103/{brief.head[:7]}")
    states = {run: state(run.dir(out)) for run in runs}
    for run, st in states.items():
        if st == "broken":
            raise Refusal(f"{run.dir(out)} has no run.json: it was left half-prepared; remove it and rerun")
        if st == "prepared" and isinstance(route, External):
            d = run.dir(out)
            raise Refusal(f"{d} was prepared and has no receipt: a runner holds it or crashed; "
                          f"if none is running, remove {d} and rerun")
    prepared = {run: prepared_at(run.dir(out)) for run, st in states.items() if st == "prepared"}
    transcripts = locate(prepared, env.transcripts, out) if prepared else {}
    plans = {run: plan(run, brief, env.work) for run, st in states.items() if st == "absent"}

    for run, st in states.items():
        d = run.dir(out)
        if st == "collected":
            if receipt_at(d).status == "dropout":
                print(f"dropout {d}")
                return 0
            print(f"collected {d}")
        elif isinstance(route, External):
            p = plans[run]
            materialize(p, brief, env)
            receipt = receipt_from_runner(run, dispatch(p, route, env), d / "runner-receipt.json")
            print(collect_one(p, receipt, brief, fx, out))
            if receipt.status == "dropout":
                return 0
        elif st == "absent":
            materialize(plans[run], brief, env)
            print(launch_line(plans[run], brief, out))
        elif transcripts[run] is None:
            print(launch_line(prepared[run], brief, out))
        elif finished(read_jsonl(transcripts[run])):
            print(f"finished {d}; collect it")
    return 0


def cmd_collect(fx: Fixtures, env: Env) -> int:
    out = env.out
    collected, stuck = 0, []
    native: dict[RunId, Prepared] = {}
    for d in sorted((d for d in out.glob("runs/*/*/*/*") if d.is_dir()), key=lambda d: natural(str(d))):
        st = state(d)
        p = prepared_at(d) if st == "prepared" else None
        if st == "collected":
            collected += 1
        elif p and isinstance(MODELS.get(p.run.descriptor), Native) and p.run.brief in fx.briefs:
            native[p.run] = p
        else:
            stuck.append(d)
    transcripts = locate(native, env.transcripts, out) if native else {}
    done: list[tuple[Prepared, Receipt]] = []
    unlaunched: list[Prepared] = []
    in_flight = 0
    for run, p in native.items():
        path = transcripts[run]
        if path is None:
            unlaunched.append(p)
            continue
        lines = read_jsonl(path)
        if not finished(lines):
            in_flight += 1
            continue
        route = MODELS[run.descriptor]
        assert isinstance(route, Native)
        done.append((p, receipt_from_transcript(run, lines, route.expect, p.checkout, path)))
    for p, receipt in done:
        print(collect_one(p, receipt, fx.briefs[p.run.brief], fx, out))
        collected += 1
    for p in unlaunched:
        print(f"unlaunched {launch_line(p, fx.briefs[p.run.brief], out)}")
    for d in stuck:
        print(f"stuck {d}")
    print(f"collected {collected} · in flight {in_flight} · unlaunched {len(unlaunched)} · stuck {len(stuck)}")
    return 0


def cmd_table(fx: Fixtures, env: Env) -> int:
    out = env.out
    receipts = [receipt_at(p.parent) for p in sorted(out.glob("runs/*/*/*/*/receipt.json"), key=lambda p: natural(str(p)))]
    if not receipts:
        raise Refusal(f"no collected runs under {out}")
    by_run = {r.run: r for r in receipts}
    scores = [rescore(r, fx, out) for r in receipts if r.status == "complete"]
    rows = ["\t".join(("descriptor", "brief", "k", "failure", "hits", "labels", "hit_ids", "demoted", "unlabeled",
                       "input_tokens", "cache_read", "cache_write", "output_tokens", "wall_ms"))]
    for s in scores:
        r = by_run[s.run]
        t = asdict(r.tokens) if r.tokens else dict.fromkeys(("input", "cache_read", "cache_write", "output"), "")
        rows.append("\t".join(map(str, (
            s.run.descriptor, s.run.brief, s.run.k, s.failure or "", len(s.hits), s.labels,
            ",".join(sorted(s.hits)), ",".join(sorted(s.demoted)), s.unlabeled,
            t["input"], t["cache_read"], t["cache_write"], t["output"], "" if r.wall_ms is None else r.wall_ms))))
    (out / "scores.tsv").write_text("\n".join(rows) + "\n")
    table = render_table(scores, receipts)
    (out / "table.md").write_text(table)
    print(table, end="")
    return 0


def at_least_one(s: str) -> int:
    n = int(s)
    if n < 1:
        raise argparse.ArgumentTypeError("must be at least 1")
    return n


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(prog="reviewer.py", description=__doc__,
                                     formatter_class=argparse.RawDescriptionHelpFormatter)
    verbs = parser.add_subparsers(dest="verb", required=True)
    check = verbs.add_parser("check")
    check.add_argument("--list", action="store_true")
    run = verbs.add_parser("run")
    run.add_argument("descriptor", choices=list(MODELS))
    run.add_argument("brief")
    run.add_argument("N", type=at_least_one)
    verbs.add_parser("collect")
    verbs.add_parser("table")
    args = parser.parse_args(argv)
    try:
        env = load_env()
        fx = load_fixtures(env.fixtures)
        if args.verb == "check":
            return cmd_check(fx, args.list)
        if args.verb == "collect":
            return cmd_collect(fx, env)
        if args.verb == "table":
            return cmd_table(fx, env)
        bid = BriefId.parse(args.brief)
        if bid not in fx.briefs:
            run.error(f"argument brief: invalid choice: {args.brief!r} (choose from {', '.join(map(str, fx.briefs))})")
        return cmd_run(fx, env, args.descriptor, bid, args.N)
    except Refusal as e:
        print(f"reviewer: {e}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    sys.exit(main())
