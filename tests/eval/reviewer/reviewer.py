#!/usr/bin/env python3
"""Run the reviewer measurement of ticket #138: three arms of three passes on six briefs, per model.

A run is (model, brief, step). Pass 1 is shared; arm I repeats the brief unchanged, arm S lists the
earlier passes' hard items as settled, arm M runs on the head with the fix patches of the
ground-truth bugs the earlier passes found folded in. STEPS holds each step's arm, pass and
prerequisites.

On a fresh clone, first fetch the reviewed heads; they are not on any branch:

    git fetch origin 'refs/keep/103/*:refs/keep/103/*'

`bash tests/eval/reviewer/rebuild.sh <round>` rebuilds a round's briefs from its inputs/ and
compares them byte for byte with review/; `bash tests/eval/reviewer/fixes.sh` rebuilds every fix
patch from its commits the same way.

    python3 tests/eval/reviewer/reviewer.py check
        Validate the rounds, the fix patches, the truth file and the agent definitions, and prove
        that every set of patches a masked pass can need applies to its head and briefs.
    python3 tests/eval/reviewer/reviewer.py next <descriptor>... [--resume <descriptor>]... [--limit N]
        Print up to N (8) launch lines and prepare what it prints: first the prepared runs no
        transcript names yet, then new runs, pass 1 across every brief before pass 2 before pass 3.
        A step is prepared once its prerequisites are collected complete; a contaminated run is
        moved aside and prepared again, until its third contamination gives it up: `next` prints
        `given up` for it and prepares neither it nor the steps that need it. A model with a usage-limit receipt is paused: `next`
        prints one `paused` line for it and prepares nothing for it until `--resume` names it,
        which prepares its limited runs again first. Collects nothing.
    python3 tests/eval/reviewer/reviewer.py collect
        Collect every finished run; list what is in flight, unlaunched or stuck. Safe to repeat.
    python3 tests/eval/reviewer/reviewer.py table
        Rescore every collected report; write scores.tsv and table.md, one table per model.

A launch line is {"run", "agent", "description", "prompt"}: pass `agent` (subagent_type, and model
where it is given), `description` and `prompt` to the Agent tool in the background, then poll
`collect`.

Environment, each with a default: REVIEWER_FIXTURES (this directory), REVIEWER_OUT
(<repository>/.scratch/eval/reviewer), REVIEWER_WORK (${TMPDIR:-/tmp}/review-work),
REVIEWER_TRANSCRIPTS (~/.claude/projects/<main checkout path, every character outside A-Za-z0-9
as ->), REVIEWER_REPO (the repository holding the reviewed heads), REVIEWER_AGENTS (<main
checkout>/.claude/agents, where the installed agent definitions must match agents/),
REVIEWER_SETTLE_SECONDS (120; how long a transcript whose last line carries no stop reason must sit
untouched before it counts as finished).
"""
from __future__ import annotations

import argparse
import itertools
import json
import os
import re
import secrets
import shutil
import subprocess
import sys
import tempfile
import time
from dataclasses import asdict, dataclass
from datetime import datetime
from pathlib import Path, PurePosixPath
from typing import Iterable, Literal, Mapping

Axis = Literal["standards", "spec"]
AXES: tuple[Axis, ...] = ("standards", "spec")
BANNED = ("eval", "test", "judge", "score", "benchmark", "candidate", "rubric", "experiment",
          "compare", "arena")
HARD_HEADINGS = ("Would break", "Fails open")
FETCH_KEEP_REFS = "git fetch origin 'refs/keep/103/*:refs/keep/103/*'"
EFFORT = "high"
COUNT_LINE = re.compile(r"hard findings: ([0-9]+)")
ITEM_LINE = re.compile(r"(\d+)\. ")
FENCE_LINE = re.compile(r"\s*(`{3,}|~{3,})")
USAGE_LIMIT = "usage-limit"
GIVE_UP = 3  # contaminated attempts after which a run is prepared no more
USAGE_LIMIT_LINE = re.compile(r"hit your usage limit", re.I)
# review-brief.sh at e710e99 prints this heading and paragraph, word for word, above the settled items.
SETTLED_HEADING = "## Settled in earlier rounds"
SETTLED_RULE = ("These findings were raised in an earlier round and settled by the decision each one cites. "
                "Do not raise them again. Nothing in this section says what you should find or confirm.")
# The heading review-brief.sh prints right after the settled section, per axis.
AFTER_SETTLED: Mapping[Axis, re.Pattern[str]] = {"standards": re.compile(r"## Standards$"),
                                                  "spec": re.compile(r"## The ticket \(#\d+\)$")}


@dataclass(frozen=True, order=True)
class BriefId:
    round: str
    axis: Axis

    def __str__(self) -> str:
        return f"{self.round}/{self.axis}"


@dataclass(frozen=True)
class Brief:
    id: BriefId
    head: str
    files: Path
    report_relpath: PurePosixPath


@dataclass(frozen=True)
class Bug:
    """One real bug in a round's head, from either axis; its `fix` patches remove it for the masked arm."""
    round: str
    id: str
    anchors: tuple[re.Pattern[str], ...]
    fix: tuple[str, ...]
    title: str

    def matches(self, text: str) -> bool:
        return all(a.search(text) for a in self.anchors)


@dataclass(frozen=True)
class Fixtures:
    briefs: Mapping[BriefId, Brief]
    truth: Mapping[str, tuple[Bug, ...]]


@dataclass(frozen=True)
class Native:
    agent: Mapping[str, str]
    expect: re.Pattern[str]


MODELS: Mapping[str, Native] = {
    "claude:opus-5": Native({"subagent_type": "review-lower-high"}, re.compile(r"^claude-opus-5$")),
    "claude:opus-5.5": Native({"subagent_type": "review-upper-high"}, re.compile(r"^claude-opus-5-5$")),
    "claude:fable-5.1": Native({"subagent_type": "review-fable-high", "model": "fable"},
                               re.compile(r"^claude-fable-5-1$")),
}
AGENT_FILES = ("review-lower-high.md", "review-upper-high.md", "review-fable-high.md")

Arm = Literal["I", "S", "M"]
ARMS: tuple[Arm, ...] = ("I", "S", "M")
Step = Literal["1", "I2", "I3", "S2", "S3", "M2", "M3"]


@dataclass(frozen=True)
class StepSpec:
    arm: Arm | None
    pass_: int
    needs: tuple[Step, ...]


STEPS: Mapping[Step, StepSpec] = {
    "1": StepSpec(None, 1, ()),
    "I2": StepSpec("I", 2, ("1",)),
    "I3": StepSpec("I", 3, ("1", "I2")),
    "S2": StepSpec("S", 2, ("1",)),
    "S3": StepSpec("S", 3, ("1", "S2")),
    "M2": StepSpec("M", 2, ("1",)),
    "M3": StepSpec("M", 3, ("1", "M2")),
}


def chain(arm: Arm) -> tuple[Step, ...]:
    return ("1", *(s for s, spec in STEPS.items() if spec.arm == arm))


@dataclass(frozen=True)
class RunId:
    descriptor: str
    brief: BriefId
    step: Step

    def dir(self, out: Path) -> Path:
        return out / "runs" / self.descriptor.replace(":", "-") / self.brief.round / self.brief.axis / self.step

    def at(self, step: Step) -> RunId:
        return RunId(self.descriptor, self.brief, step)

    def to_json(self) -> dict:
        return {"descriptor": self.descriptor, "round": self.brief.round, "axis": self.brief.axis, "step": self.step}

    @staticmethod
    def from_json(j: dict) -> RunId:
        return RunId(j["descriptor"], BriefId(j["round"], j["axis"]), j["step"])


@dataclass(frozen=True)
class Prepared:
    run: RunId
    nonce: str
    checkout: Path
    prompt: str
    settled: tuple[str, ...] = ()
    applied: tuple[str, ...] = ()
    masked: tuple[str, ...] = ()
    tree: str | None = None


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
    effort: str | None
    tokens: Tokens | None
    wall_ms: int | None
    source: Path


Failure = Literal["no-report", "no-count-line", "count-exceeds-items", "no-hard-headings"]


@dataclass(frozen=True)
class Item:
    n: int
    hard: bool
    text: str
    raw: str


@dataclass(frozen=True)
class Score:
    run: RunId
    failure: Failure | None
    hits: frozenset[str]
    demoted: frozenset[str]
    other: int
    items: tuple[Item, ...] = ()


class Refusal(Exception):
    """Printed as `reviewer: <msg>` on stderr, exit 1."""


class Conflict(Refusal):
    """A set of patches that does not apply to its round's head."""


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

    tfile = root / "truth"
    if not tfile.is_file():
        raise bad(tfile, 0, "missing")
    names = {b.round for b in briefs}
    truth: dict[str, list[Bug]] = {r: [] for r in sorted(names, key=natural)}
    for i, line in enumerate(tfile.read_text().splitlines(), 1):
        if not line.strip() or line.startswith("#"):
            continue
        cols = line.split("\t")
        if len(cols) != 7:
            raise bad(tfile, i, f"{len(cols)} columns, want 7: round, id, anchors, fix, where, sources, title")
        round_, bid, anchors_s, fix_s, where, sources, title = cols
        if round_ not in names:
            raise bad(tfile, i, f"unknown round {round_}")
        if not re.fullmatch(r"G[1-9][0-9]*", bid):
            raise bad(tfile, i, f"id {bid} is not G<n>")
        if any(b.id == bid for b in truth[round_]):
            raise bad(tfile, i, f"{round_} {bid} appears twice")
        parts = anchors_s.split(" && ")
        if len(parts) < 2:
            raise bad(tfile, i, "fewer than two anchors")
        compiled = []
        for p in parts:
            try:
                compiled.append(re.compile(p))
            except re.error as e:
                raise bad(tfile, i, f"anchor {p!r}: {e}") from None
        fix = () if fix_s == "-" else tuple(fix_s.split(","))
        if not all(re.fullmatch(r"[A-Za-z0-9._-]+\.patch", f) for f in fix):
            raise bad(tfile, i, f"fix {fix_s!r} is not - or comma-separated patch names")
        for f in fix:
            if not (rounds / round_ / "fixes" / f).is_file():
                raise bad(tfile, i, f"fix {f} is not in rounds/{round_}/fixes/")
        for name, value in (("where", where), ("sources", sources), ("title", title)):
            if not value.strip():
                raise bad(tfile, i, f"{name} is empty")
        truth[round_].append(Bug(round_, bid, tuple(compiled), fix, title))
    return Fixtures(briefs, {r: tuple(v) for r, v in truth.items()})


def normalize(text: str) -> str:
    return re.sub(r"\s+", " ", re.sub(r"[`*]", "", text.lower())).strip()


def parse_report(text: str | None) -> list[Item] | Failure:
    if text is None:
        return "no-report"
    counts: list[re.Match[str]] = []
    hard_heading = False
    items: list[Item] = []
    heading = None
    current: tuple[int, bool, list[str]] | None = None
    fence: str | None = None

    def close() -> None:
        if current:
            items.append(Item(current[0], current[1], normalize(" ".join(current[2])),
                              " ".join(s.strip() for s in current[2] if s.strip())))

    for line in text.splitlines():
        # A reviewer quotes numbered criteria and headings inside fences; they are not findings.
        marker = FENCE_LINE.match(line)
        fenced = fence is not None or marker is not None
        if marker:
            if fence is None:
                fence = marker.group(1)[:3]
            elif marker.group(1).startswith(fence):
                fence = None
        count = COUNT_LINE.fullmatch(line.rstrip())
        if count and not fenced:
            counts.append(count)
        if not fenced and line.startswith("## "):
            close()
            current, heading = None, line[3:].strip()
            hard_heading = hard_heading or heading in HARD_HEADINGS
            continue
        m = ITEM_LINE.match(line)
        # `## Walk` lines are numbered steps, not findings.
        if m and not fenced and heading != "Walk":
            close()
            current = (int(m.group(1)), heading in HARD_HEADINGS, [line[m.end():]])
        elif current and not count:
            current[2].append(line)
    close()
    if not counts:
        return "no-count-line"
    if not hard_heading:
        return "no-hard-headings"
    if int(counts[-1].group(1)) > sum(1 for i in items if i.hard):
        return "count-exceeds-items"
    return items


def claims(hard: list[Item], bugs: tuple[Bug, ...]) -> dict[int, int]:
    """Bug index -> hard item index, one to one, most anchors first, then item order, then bug order."""
    pairs = sorted((-len(bug.anchors), ii, bi)
                   for ii, item in enumerate(hard) for bi, bug in enumerate(bugs) if bug.matches(item.text))
    by_bug: dict[int, int] = {}
    for _, ii, bi in pairs:
        if bi not in by_bug and ii not in by_bug.values():
            by_bug[bi] = ii
    return by_bug


def score(run: RunId, parsed: list[Item] | Failure, bugs: tuple[Bug, ...]) -> Score:
    if isinstance(parsed, str):
        return Score(run, parsed, frozenset(), frozenset(), 0)
    hard = [i for i in parsed if i.hard]
    claimed = claims(hard, bugs)
    hits = frozenset(bugs[bi].id for bi in claimed)
    other = sum(1 for ii, item in enumerate(hard)
                if ii not in claimed.values() and not any(bug.matches(item.text) for bug in bugs))
    demoted = frozenset(bug.id for bug in bugs
                        if bug.id not in hits and any(bug.matches(i.text) for i in parsed if not i.hard))
    return Score(run, None, hits, demoted, other, tuple(parsed))


def fixes_for(found: Iterable[str], bugs: tuple[Bug, ...]) -> tuple[tuple[str, ...], tuple[str, ...]]:
    """The found bugs' patches in truth-row order, each once, and every bug whose patches are all among them."""
    ids = set(found)
    applied = tuple(dict.fromkeys(c for b in bugs if b.id in ids for c in b.fix))
    masked = tuple(b.id for b in bugs if b.fix and set(b.fix) <= set(applied))
    return applied, masked


def arising(bugs: tuple[Bug, ...]) -> list[tuple[str, ...]]:
    """Every non-empty set of patches a masked pass can apply, each once."""
    fixable = [b for b in bugs if b.fix]
    seen: dict[frozenset[str], tuple[str, ...]] = {}
    for n in range(1, len(fixable) + 1):
        for subset in itertools.combinations(fixable, n):
            applied, _ = fixes_for((b.id for b in subset), bugs)
            seen.setdefault(frozenset(applied), applied)
    return list(seen.values())


def settle(brief: str, axis: Axis, lines: list[str]) -> str:
    """The brief with `lines` under the settled heading, where review-brief.sh prints that section."""
    if not lines:
        return brief
    rows = brief.split("\n")
    fence: str | None = None
    for i, line in enumerate(rows):
        marker = FENCE_LINE.match(line)
        if marker:
            if fence is None:
                fence = marker.group(1)[:3]
            elif marker.group(1).startswith(fence) and not line.strip()[len(marker.group(1)):].strip():
                fence = None
            continue
        if fence is None and AFTER_SETTLED[axis].match(line):
            block = [SETTLED_HEADING, "", SETTLED_RULE, "", *lines, ""]
            return "\n".join(rows[:i] + block + rows[i:])
    raise Refusal(f"the {axis} brief has no line matching {AFTER_SETTLED[axis].pattern} outside a fence; "
                  f"the settled section has nowhere to go")


def stamp(s: str) -> datetime:
    return datetime.fromisoformat(s.replace("Z", "+00:00"))


def assistant_text(line: dict) -> str:
    content = (line.get("message") or {}).get("content")
    blocks = content if isinstance(content, list) else [{"type": "text", "text": content or ""}]
    return " ".join(str(c.get("text", "")) for c in blocks if isinstance(c, dict) and c.get("type") == "text")


def usage_limited_transcript(lines: list[dict]) -> bool:
    return any(USAGE_LIMIT_LINE.search(assistant_text(line) + " " + str(line.get("error") or ""))
               for line in lines if line.get("type") == "assistant")


# The tools whose reach receipt_from_transcript can judge, then the ones that read no file and no
# network; any other tool call is contamination.
CHECKED_TOOLS = ("Read", "Write", "Edit", "Grep", "Glob", "Bash", "TodoWrite", "ToolSearch")
COMMAND_WORDS = ("gh", "git", "curl", "wget")
PREFIX_WORDS = ("env", "sudo", "command", "exec", "time", "nohup", "xargs", "builtin")
TRUSTED_BINS = ("/usr/", "/bin/", "/opt/homebrew/")
SEGMENT_SPLIT = re.compile(r"&&|\|\||;|\||\$\(|`|\n|\(")
PATH_TOKEN = re.compile(r"(?:^|(?<=[\s'\"=:(<>]))([/~][^\s'\"`;|&()<>]*)")


def bash_reaches(command: str, root: str) -> list[str]:
    """Why a reviewer's Bash command leaves the export, or nothing when it stays inside."""
    why = []
    if root not in command:
        why.append("does not name the export")
    words = []
    for seg in SEGMENT_SPLIT.split(command):
        toks = [t for t in seg.strip().split() if t]
        while toks and (re.fullmatch(r"[A-Za-z_][A-Za-z0-9_]*=\S*", toks[0]) or toks[0] in PREFIX_WORDS):
            toks.pop(0)
        if toks:
            words.append(toks[0].strip("'\""))
    for w in words:
        if os.path.basename(w) in COMMAND_WORDS:
            why.append(f"runs {os.path.basename(w)}")
    if re.search(r"(^|[\s/'\"=])\.\.(/|[\s'\"]|$)", command):
        why.append("has a .. path component")
    inside = re.compile(re.escape(root) + r"(?=$|[/\s'\"`;|&()<>])[^\s'\"`;|&()<>]*")
    rest = inside.sub(" ", command)
    for m in PATH_TOKEN.finditer(rest):
        p = m.group(1)
        if p == "/dev/null" or (p.startswith(TRUSTED_BINS) and p in words):
            continue
        # A slash that opens no real top-level directory is a pattern, as in awk '/^## /'.
        if p.startswith("/") and not (p.split("/")[1] and os.path.exists("/" + p.split("/")[1])):
            continue
        why.append(f"names {p}")
    return why


def receipt_from_transcript(run: RunId, lines: list[dict], expect: re.Pattern[str], checkout: Path,
                            transcripts: Path, source: Path) -> Receipt:
    assistant = [line for line in lines if line.get("type") == "assistant"]
    stamps = [stamp(line["timestamp"]) for line in lines if line.get("timestamp")]
    wall_ms = int((stamps[-1] - stamps[0]).total_seconds() * 1000) if stamps else None
    if usage_limited_transcript(lines):
        return Receipt(run, "dropout", f"{USAGE_LIMIT}: the transcript says the account hit its usage limit",
                       None, None, None, wall_ms, source)
    served = [line for line in assistant if (line.get("message") or {}).get("model") not in (None, "<synthetic>")]
    models = sorted({line["message"]["model"] for line in served})
    wrong = [m for m in models if not expect.search(m)]
    if wrong or not models:
        raise Refusal(f"{run.descriptor} {run.brief} step {run.step} was served {', '.join(wrong) or 'no model'}; "
                      f"{run.descriptor} pins {expect.pattern}; the agent definition drifted: fix it, "
                      f"remove the run directory, run next again")
    efforts = sorted({str(line.get("effort")) for line in served})
    if efforts != [EFFORT]:
        raise Refusal(f"{run.descriptor} {run.brief} step {run.step} ran at effort {', '.join(efforts)}; "
                      f"every run is at effort {EFFORT}; set `effort: {EFFORT}` in the agent definition, "
                      f"remove the run directory, run next again")
    usage: dict[str, dict] = {}
    for i, line in enumerate(assistant):
        u = (line.get("message") or {}).get("usage")
        if u:
            usage[line.get("requestId") or f"line {i}"] = u
    tokens = Tokens(*(sum(u.get(k) or 0 for u in usage.values())
                      for k in ("input_tokens", "cache_read_input_tokens", "cache_creation_input_tokens", "output_tokens")))

    root = os.path.normpath(str(checkout))
    troot = os.path.normpath(str(transcripts))

    def inside(p: str) -> bool:
        p = os.path.normpath(p)
        return os.path.isabs(p) and (p == root or p.startswith(root + os.sep))

    def overflow(p: str) -> bool:
        p = os.path.normpath(p)
        if not p.startswith(troot + os.sep):
            return False
        # The harness persists a large tool result of the reviewer's own and hands back its path.
        parts = p[len(troot) + 1:].split(os.sep)
        return len(parts) > 2 and parts[1] == "tool-results"

    reaches = []
    for line in assistant:
        content = (line.get("message") or {}).get("content")
        for c in content if isinstance(content, list) else ():
            if not isinstance(c, dict) or c.get("type") != "tool_use":
                continue
            name, args = c.get("name"), c.get("input") or {}
            if name == "Read" and overflow(args.get("file_path", "")):
                continue
            if name in ("Read", "Write", "Edit") and not inside(args.get("file_path", "")):
                reaches.append(f"{name} {args.get('file_path', '')}")
            elif name in ("Grep", "Glob") and not args.get("path"):
                reaches.append(f"{name} with no path")
            elif name in ("Grep", "Glob") and not inside(args["path"]):
                reaches.append(f"{name} {args['path']}")
            elif name == "Bash" and (why := bash_reaches(args.get("command", ""), root)):
                reaches.append(f"Bash ({', '.join(why)}) {args.get('command', '')[:120]}")
            elif name not in CHECKED_TOOLS:
                reaches.append(f"{name} (unchecked tool)")
    status: Status = "contaminated" if reaches else "complete"
    return Receipt(run, status, "; ".join(reaches) or "complete", models[-1], efforts[0], tokens, wall_ms, source)


def usage_limited(receipt: Receipt) -> bool:
    return receipt.status == "dropout" and receipt.detail.startswith(USAGE_LIMIT)


def redo(receipt: Receipt) -> bool:
    """A run whose result says nothing about the model: moved aside and prepared again."""
    return receipt.status == "contaminated" or usage_limited(receipt)


@dataclass(frozen=True)
class Row:
    """One arm and pass of one model's table; means are per chain."""
    arm: Arm
    pass_: int
    chains: int
    new: float | None
    cumulative: float | None
    demoted: float | None
    other: float | None
    failures: int
    output: float | None
    cache_read: float | None
    wall_s: float | None
    contaminated: int
    usage_limit: int


def mean(xs: list[float]) -> float | None:
    return sum(xs) / len(xs) if xs else None


def rows_for(descriptor: str, scores: Mapping[RunId, Score], receipts: Mapping[RunId, Receipt],
             masked: Mapping[RunId, frozenset[str]], dropped: list[Receipt]) -> list[Row]:
    briefs = sorted({r.brief for r in scores if r.descriptor == descriptor})
    rows = []
    for arm in ARMS:
        steps = chain(arm)
        for p, step in enumerate(steps, 1):
            new, cum, dem, oth, out, cache, wall = [], [], [], [], [], [], []
            failures = 0
            for b in briefs:
                runs = [RunId(descriptor, b, s) for s in steps[:p]]
                if not all(r in scores for r in runs):
                    continue
                s = scores[runs[-1]]
                gone = masked.get(runs[-1], frozenset())
                earlier = frozenset().union(*(scores[r].hits for r in runs[:-1]))
                found = s.hits - gone - earlier
                new.append(len(found))
                cum.append(len(earlier | found))
                dem.append(len(s.demoted - gone - earlier))
                oth.append(s.other)
                failures += s.failure is not None
                rc = receipts[runs[-1]]
                if rc.tokens:
                    out.append(rc.tokens.output)
                    cache.append(rc.tokens.cache_read)
                if rc.wall_ms is not None:
                    wall.append(rc.wall_ms / 1000)
            mine = [r for r in dropped if r.run.descriptor == descriptor and r.run.step == step]
            rows.append(Row(arm, p, len(new), mean(new), mean(cum), mean(dem), mean(oth), failures,
                            mean(out), mean(cache), mean(wall),
                            sum(1 for r in mine if r.status == "contaminated"),
                            sum(1 for r in mine if r.status == "dropout")))
    return rows


COLUMNS = ("arm", "pass", "chains", "new truth bugs", "cumulative", "demoted", "other hard items",
           "context failures", "out tokens", "cache read", "wall s", "contaminated", "usage limit")


def render_table(descriptor: str, rows: list[Row]) -> str:
    def f(x: float | None, places: int) -> str:
        return "n/a" if x is None else f"{x:.{places}f}"

    def cells(row: Iterable[str]) -> str:
        return "| " + " | ".join(row) + " |"

    lines = [f"## {descriptor}", "", "Means per chain; a masked pass leaves out the bugs its tree has fixed.", "",
             cells(COLUMNS), cells("---" for _ in COLUMNS)]
    for r in rows:
        lines.append(cells([r.arm, str(r.pass_), str(r.chains), f(r.new, 2), f(r.cumulative, 2), f(r.demoted, 2),
                            f(r.other, 2), str(r.failures), f(r.output, 0), f(r.cache_read, 0), f(r.wall_s, 1),
                            str(r.contaminated), str(r.usage_limit)]))
    return "\n".join(lines) + "\n"


# Everything below touches git, the filesystem or subprocesses.

@dataclass(frozen=True)
class Env:
    fixtures: Path
    out: Path
    work: Path
    transcripts: Path
    repo: Path
    agents: Path
    settle: float


def git(cwd: Path, *args: str) -> str:
    return subprocess.run(["git", "-C", str(cwd), *args], capture_output=True, text=True, check=True).stdout.strip()


def load_env() -> Env:
    here = Path(__file__).resolve().parent
    top = Path(git(here, "rev-parse", "--show-toplevel"))
    main = Path(git(top, "rev-parse", "--path-format=absolute", "--git-common-dir")).parent
    transcripts = os.environ.get("REVIEWER_TRANSCRIPTS") or str(
        Path.home() / ".claude" / "projects" / re.sub(r"[^A-Za-z0-9]", "-", str(main)))
    return Env(
        fixtures=Path(os.environ.get("REVIEWER_FIXTURES") or here),
        out=Path(os.environ.get("REVIEWER_OUT") or top / ".scratch" / "eval" / "reviewer"),
        work=Path(os.environ.get("REVIEWER_WORK") or Path(os.environ.get("TMPDIR") or "/tmp") / "review-work"),
        transcripts=Path(transcripts),
        repo=Path(os.environ.get("REVIEWER_REPO") or top),
        agents=Path(os.environ.get("REVIEWER_AGENTS") or main / ".claude" / "agents"),
        settle=float(os.environ.get("REVIEWER_SETTLE_SECONDS") or 120),
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
    return {"version": 2, "run": r.run.to_json(), "status": r.status, "detail": r.detail,
            "reported_model": r.reported_model, "effort": r.effort,
            "tokens": asdict(r.tokens) if r.tokens else None, "wall_ms": r.wall_ms, "source": str(r.source)}


def receipt_at(d: Path) -> Receipt | None:
    path = d / "receipt.json"
    if not path.is_file():
        return None
    j = json.loads(path.read_text())
    return Receipt(RunId.from_json(j["run"]), j["status"], j["detail"], j["reported_model"], j["effort"],
                   Tokens(**j["tokens"]) if j["tokens"] else None, j["wall_ms"], Path(j["source"]))


def prepared_at(d: Path) -> Prepared | None:
    path = d / "run.json"
    if not path.is_file():
        return None
    j = json.loads(path.read_text())
    return Prepared(RunId.from_json(j["run"]), j["nonce"], Path(j["checkout"]), j["prompt"],
                    tuple(j.get("settled", ())), tuple(j.get("applied", ())), tuple(j.get("masked", ())), j.get("tree"))


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


def rebuild(env: Env, round_: str, *args: str) -> subprocess.CompletedProcess:
    return subprocess.run(["bash", str(Path(__file__).resolve().parent / "rebuild.sh"), round_, *args],
                          capture_output=True, text=True,
                          env={**os.environ, "REBUILD_FIXTURES": str(env.fixtures), "REBUILD_REPO": str(env.repo)})


def export_masked(env: Env, round_: str, dest: Path, patches: tuple[str, ...]) -> str:
    proc = rebuild(env, round_, "--export", str(dest), *patches)
    if proc.returncode == 3:
        raise Conflict(f"round {round_}: the patches {' '.join(patches)} do not apply to its head "
                       f"({proc.stderr.strip()}); the truth file's fix column needs the owner")
    if proc.returncode:
        raise Refusal(f"rebuild.sh {round_} --export failed ({proc.returncode}): {proc.stderr.strip()[-400:]}")
    return proc.stdout.strip().splitlines()[-1]


def report_of(run: RunId, out: Path) -> str | None:
    report = run.dir(out) / "report.md"
    return report.read_text() if report.is_file() else None


def rescore(run: RunId, fx: Fixtures, out: Path) -> Score:
    if run.brief not in fx.briefs:
        raise Refusal(f"{run.dir(out)} names brief {run.brief}, which the fixture set lacks")
    return score(run, parse_report(report_of(run, out)), fx.truth[run.brief.round])


def materialize(p: Prepared, brief: Brief, fx: Fixtures, env: Env) -> Prepared:
    """Build the run's export and write run.json; the masked arm's tree comes from rebuild.sh."""
    run, out = p.run, env.out
    spec = STEPS[run.step]
    d = run.dir(out)
    d.parent.mkdir(parents=True, exist_ok=True)
    try:
        d.mkdir()
    except FileExistsError:
        raise Refusal(f"{d} appeared while this run started: another run holds it") from None
    p.checkout.mkdir(parents=True)
    target = p.checkout / brief.report_relpath.parent
    other = next(a for a in AXES if a != brief.id.axis)
    earlier = [rescore(run.at(s), fx, out) for s in spec.needs]
    applied: tuple[str, ...] = ()
    masked: tuple[str, ...] = ()
    tree = brief.head
    if spec.arm == "M":
        applied, masked = fixes_for(frozenset().union(*(s.hits for s in earlier)), fx.truth[run.brief.round])
    if applied:
        tree = export_masked(env, run.brief.round, p.checkout, applied)
        (target / f"{other}-brief.md").unlink()
    else:
        with subprocess.Popen(["git", "-C", str(env.repo), "archive", brief.head], stdout=subprocess.PIPE) as archive:
            subprocess.run(["tar", "-x", "-C", str(p.checkout)], stdin=archive.stdout, check=True)
        if archive.returncode:
            raise Refusal(f"git archive {brief.head} failed; remove {d} and run next again")
        target.mkdir(parents=True, exist_ok=True)
        for name in ("diff", f"{run.brief.axis}-brief.md"):
            shutil.copyfile(brief.files / name, target / name)
    settled: tuple[str, ...] = ()
    if spec.arm == "S":
        settled = tuple(f"- {i.raw}" for s in earlier for i in s.items if i.hard)
        bfile = target / f"{run.brief.axis}-brief.md"
        bfile.write_text(settle(bfile.read_text(), run.brief.axis, list(settled)))
    done = Prepared(run, p.nonce, p.checkout, p.prompt, settled, applied, masked, tree)
    (d / "prompt.txt").write_text(p.prompt)
    write_json(d / "run.json", {"run": run.to_json(), "nonce": p.nonce, "checkout": str(p.checkout),
                                "prompt": p.prompt, "tree": tree, "settled": list(settled),
                                "applied": list(applied), "masked": list(masked),
                                "plain_head": not applied})
    return done


def launch_line(p: Prepared, brief: Brief, out: Path) -> str:
    route = MODELS[p.run.descriptor]
    return json.dumps({"run": str(p.run.dir(out)), "agent": dict(route.agent),
                       "description": f"Review {brief.head[:7]} {p.run.brief.axis}", "prompt": p.prompt})


def collect_one(p: Prepared, receipt: Receipt, brief: Brief, fx: Fixtures, out: Path) -> str:
    d = p.run.dir(out)
    report = p.checkout / brief.report_relpath
    if receipt.status != "dropout" and report.is_file():
        shutil.copyfile(report, d / "report.md")
    write_json(d / "receipt.json", receipt_json(receipt))
    shutil.rmtree(p.checkout.parent, ignore_errors=True)
    if receipt.status == "dropout":
        return f"dropout {d} {receipt.detail}"
    if receipt.status == "contaminated":
        return f"contaminated {d}: {receipt.detail}"
    s = rescore(p.run, fx, out)
    if s.failure:
        return f"{d} context-failure {s.failure}"
    t = receipt.tokens
    wall = f"{receipt.wall_ms / 1000:.0f}s" if receipt.wall_ms is not None else "n/a"
    return (f"{d} truth {','.join(sorted(s.hits)) or '-'} other {s.other} demoted {len(s.demoted)} "
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
                          f"one prompt was launched twice; remove {d} and run next again")
    return {run: paths[0] if paths else None for run, paths in found.items()}


def finished(lines: list[dict], path: Path, settle_s: float) -> bool:
    last = next((line for line in reversed(lines) if line.get("type") == "assistant"), None)
    if not last:
        return False
    message = last.get("message") or {}
    if message.get("stop_reason") == "end_turn" or usage_limited_transcript([last]):
        return True
    # A run can end on a text-only line the harness never stamped with a stop reason, so read a
    # transcript that has stopped growing as done.
    content = message.get("content")
    blocks = content if isinstance(content, list) else []
    if not blocks or any(not isinstance(c, dict) or c.get("type") != "text" for c in blocks):
        return False
    return time.time() - path.stat().st_mtime >= settle_s


def run_dirs(out: Path) -> list[Path]:
    return sorted((d for d in out.glob("runs/*/*/*/*") if d.is_dir()), key=lambda d: natural(str(d)))


def contaminations(run: RunId, out: Path) -> int:
    """The contaminated attempts of a run: those set aside under dropped/ and the one in its directory."""
    rel = run.dir(out).relative_to(out / "runs")
    kept = [receipt_at(p) for p in (out / "dropped" / rel).glob("*") if (p / "receipt.json").is_file()]
    here = receipt_at(run.dir(out))
    return sum(1 for r in [*kept, here] if r and r.status == "contaminated")


def set_aside(d: Path, out: Path) -> None:
    """Keep a contaminated or usage-limit receipt for the table and free the run for a new attempt."""
    rel = d.relative_to(out / "runs")
    n = 1
    while (out / "dropped" / rel / str(n)).exists():
        n += 1
    dest = out / "dropped" / rel / str(n)
    dest.parent.mkdir(parents=True, exist_ok=True)
    shutil.move(str(d), str(dest))


def cmd_check(fx: Fixtures, env: Env) -> int:
    fixture_agents = env.fixtures / "agents"
    for name in AGENT_FILES:
        mine, theirs = fixture_agents / name, env.agents / name
        if not mine.is_file():
            raise Refusal(f"fixtures: agents/{name}: missing")
        if not theirs.is_file():
            raise Refusal(f"{theirs} is missing; copy {mine} there so the Agent tool can launch it")
        if mine.read_bytes() != theirs.read_bytes():
            raise Refusal(f"{theirs} differs from {mine}; copy the fixture's copy over it, byte for byte")
        print(f"ok agent {name}")
    for b in fx.briefs.values():
        if subprocess.run(["git", "-C", str(env.repo), "cat-file", "-e", f"{b.head}^{{commit}}"],
                          capture_output=True).returncode:
            raise Refusal(f"round {b.id.round}: {b.head} is not in this repository's objects; fetch with: {FETCH_KEEP_REFS}")
    proc = subprocess.run(["bash", str(Path(__file__).resolve().parent / "fixes.sh")], capture_output=True, text=True,
                          env={**os.environ, "REBUILD_FIXTURES": str(env.fixtures), "REBUILD_REPO": str(env.repo)})
    if proc.returncode:
        raise Refusal(f"fixes.sh: {proc.stderr.strip()}; rebuild the patches with fixes.sh --write and read the diff")
    print(f"ok patches: {len(proc.stdout.splitlines())} rebuild identical from their commits")
    conflicts: list[str] = []
    for round_, bugs in fx.truth.items():
        print(f"ok truth {round_}: {len(bugs)} bugs, {sum(1 for b in bugs if b.fix)} with a fix")
        for patches in arising(bugs):
            with tempfile.TemporaryDirectory() as tmp:
                try:
                    export_masked(env, round_, Path(tmp) / "x", patches)
                except Conflict as e:
                    conflicts.append(str(e))
                    print(f"conflict {round_}: {' '.join(patches)}")
                    continue
            print(f"ok masked {round_}: {' '.join(patches)}")
    if conflicts:
        raise Refusal(f"{len(conflicts)} set(s) of patches do not apply: " + "; ".join(conflicts))
    return 0


def cmd_next(fx: Fixtures, env: Env, descriptors: list[str], limit: int, resume: list[str]) -> int:
    out = env.out
    missing = sorted({b.head for b in fx.briefs.values()
                      if subprocess.run(["git", "-C", str(env.repo), "cat-file", "-e", f"{b.head}^{{commit}}"],
                                        capture_output=True).returncode})
    if missing:
        raise Refusal(f"{' '.join(missing)} not in this repository's objects; fetch with: {FETCH_KEEP_REFS}")
    runs = [RunId(desc, b, step) for desc in descriptors for b in fx.briefs for step in STEPS]
    states: dict[RunId, str] = {}
    held: dict[str, float] = {}
    resumed: set[RunId] = set()
    given_up: list[Path] = []
    for run in runs:
        d = run.dir(out)
        st = state(d)
        if st == "broken":
            raise Refusal(f"{d} has no run.json: it was left half-prepared; remove it and run next again")
        receipt = receipt_at(d) if st == "collected" else None
        if receipt and usage_limited(receipt) and run.descriptor not in resume:
            held[run.descriptor] = max(held.get(run.descriptor, 0.0), (d / "receipt.json").stat().st_mtime)
        elif receipt and receipt.status == "contaminated" and contaminations(run, out) >= GIVE_UP:
            given_up.append(d)
        elif receipt and redo(receipt):
            set_aside(d, out)
            st = "absent"
            if usage_limited(receipt):
                resumed.add(run)
        states[run] = st
    # The account's quota ran out for a held model: nothing more launches for it until the reset.
    states = {run: st for run, st in states.items() if run.descriptor not in held}
    complete = {run for run, st in states.items() if st == "collected" and receipt_at(run.dir(out)).status == "complete"}
    prepared = {run: prepared_at(run.dir(out)) for run, st in states.items() if st == "prepared"}
    transcripts = locate(prepared, env.transcripts, out) if prepared else {}
    lines = [launch_line(p, fx.briefs[run.brief], out) for run, p in prepared.items() if transcripts[run] is None]
    ready = sorted((run for run, st in states.items()
                    if st == "absent" and all(run.at(s) in complete for s in STEPS[run.step].needs)),
                   key=lambda r: (r not in resumed, STEPS[r.step].pass_, descriptors.index(r.descriptor),
                                  natural(r.brief.round), AXES.index(r.brief.axis), list(STEPS).index(r.step)))
    for run in ready:
        if len(lines) >= limit:
            break
        brief = fx.briefs[run.brief]
        p = materialize(plan(run, brief, env.work), brief, fx, env)
        lines.append(launch_line(p, brief, out))
    for d in given_up:
        print(f"given up {d}: contaminated {GIVE_UP} times")
    for desc, at in held.items():
        print(f"paused {desc}: usage limit at {datetime.fromtimestamp(at).isoformat(timespec='minutes')}; "
              f"after the reset run: python3 tests/eval/reviewer/reviewer.py next --resume {desc}")
    if lines:
        print("\n".join(lines[:limit]))
    return 0


def cmd_collect(fx: Fixtures, env: Env) -> int:
    out = env.out
    collected, stuck = 0, []
    native: dict[RunId, Prepared] = {}
    for d in run_dirs(out):
        st = state(d)
        p = prepared_at(d) if st == "prepared" else None
        if st == "collected":
            collected += 1
        elif p and p.run.descriptor in MODELS and p.run.brief in fx.briefs:
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
        if not finished(lines, path, env.settle):
            in_flight += 1
            continue
        done.append((p, receipt_from_transcript(run, lines, MODELS[run.descriptor].expect, p.checkout,
                                                env.transcripts, path)))
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
    receipts = [receipt_at(d) for d in run_dirs(out) if (d / "receipt.json").is_file()]
    dropped = [receipt_at(p.parent) for p in sorted(out.glob("dropped/*/*/*/*/*/receipt.json"), key=lambda p: natural(str(p)))]
    dropped += [r for r in receipts if redo(r)]
    if not receipts and not dropped:
        raise Refusal(f"no collected runs under {out}")
    complete = {r.run: r for r in receipts if r.status == "complete"}
    scores = {run: rescore(run, fx, out) for run in complete}
    masked = {run: frozenset(prepared_at(run.dir(out)).masked) for run in complete}
    rows = ["\t".join(("descriptor", "brief", "step", "failure", "hit_ids", "masked", "demoted", "other",
                       "input_tokens", "cache_read", "cache_write", "output_tokens", "wall_ms"))]
    for run, s in sorted(scores.items(), key=lambda kv: (kv[0].descriptor, kv[0].brief, list(STEPS).index(kv[0].step))):
        r = complete[run]
        t = asdict(r.tokens) if r.tokens else dict.fromkeys(("input", "cache_read", "cache_write", "output"), "")
        rows.append("\t".join(map(str, (
            run.descriptor, run.brief, run.step, s.failure or "", ",".join(sorted(s.hits)),
            ",".join(sorted(masked[run])), ",".join(sorted(s.demoted)), s.other,
            t["input"], t["cache_read"], t["cache_write"], t["output"], "" if r.wall_ms is None else r.wall_ms))))
    (out / "scores.tsv").write_text("\n".join(rows) + "\n")
    names = [d for d in MODELS if any(r.run.descriptor == d for r in [*receipts, *dropped])]
    table = "\n".join(render_table(d, rows_for(d, scores, complete, masked, dropped)) for d in names)
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
    verbs.add_parser("check")
    nxt = verbs.add_parser("next")
    nxt.add_argument("descriptors", nargs="*", choices=list(MODELS), metavar="descriptor")
    nxt.add_argument("--resume", action="append", choices=list(MODELS), default=[], metavar="descriptor")
    nxt.add_argument("--limit", type=at_least_one, default=8)
    verbs.add_parser("collect")
    verbs.add_parser("table")
    args = parser.parse_args(argv)
    if args.verb == "next" and not args.descriptors and not args.resume:
        nxt.error("name at least one descriptor or --resume descriptor")
    try:
        env = load_env()
        fx = load_fixtures(env.fixtures)
        if args.verb == "check":
            return cmd_check(fx, env)
        if args.verb == "collect":
            return cmd_collect(fx, env)
        if args.verb == "table":
            return cmd_table(fx, env)
        return cmd_next(fx, env, list(dict.fromkeys(args.descriptors + args.resume)), args.limit, args.resume)
    except Refusal as e:
        print(f"reviewer: {e}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    sys.exit(main())
