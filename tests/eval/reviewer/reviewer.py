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
        A step is prepared once its prerequisites are collected complete with a report that parses;
        a prerequisite whose report fails to parse stops its chain (`stopped <run dir>: <failure>`).
        A contaminated run, or one whose lane died with the harness's own line last (a
        `no-response` dropout, as on an API error), is moved aside and prepared again, until its
        third such attempt gives it up: `next` prints `given up` for it and prepares neither it nor
        the steps that need it. A model with a usage-limit receipt is paused: `next` prints one
        `paused` line for it and prepares nothing for it until `--resume` names it, which prepares
        its limited runs again first. Collects nothing.
    python3 tests/eval/reviewer/reviewer.py collect [--recheck]
        Collect every finished run; list what is in flight, unlaunched or stuck. Safe to repeat.
        A run is contaminated when a tool result in its transcript holds a line that only commits
        after its head, or its ticket and PR as GitHub holds them now, hold and that it was not given
        (its tree, brief and diff, and the round's frozen ticket and grounding, which each export
        holds beside the brief and the prompt names), or when it used a tool whose results cannot
        be dated (Agent, WebFetch, WebSearch), or when it read the session's shared scratchpad or
        another run's export at a path it had not written (`cross-run read`). The GitHub text is fetched once with gh and cached; the receipt also
        records the first contaminated tool call, each report item's earliest sighting of what it
        quotes, and the calls that named a path outside the export. --recheck first judges every
        collected run again from its transcript: one that turns contaminated is set aside by `next`,
        and a set-aside one that is clean now comes back complete when its report is still there.
        A run served the wrong model or effort is refused after every other run is collected. A
        transcript whose last assistant line is stamped `end_turn` is finished; one whose last
        assistant line holds only text and is not stamped `end_turn` (a harness line included) is
        finished once it has sat untouched for REVIEWER_SETTLE_SECONDS.
    python3 tests/eval/reviewer/reviewer.py table
        Rescore every collected report; write scores.tsv and table.md, one table per model.

A launch line is {"run", "agent", "description", "prompt"}: pass `agent` (subagent_type, and model
where it is given), `description` and `prompt` to the Agent tool in the background, then poll
`collect`.

Environment, each with a default: REVIEWER_FIXTURES (this directory), REVIEWER_OUT
(<repository>/.scratch/eval/reviewer-138; a receipt or run.json another measurement wrote there is
refused), REVIEWER_WORK (${TMPDIR:-/tmp}/review-work),
REVIEWER_TRANSCRIPTS (~/.claude/projects/<main checkout path, every character outside A-Za-z0-9
as ->), REVIEWER_REPO (the repository holding the reviewed heads), REVIEWER_AGENTS (<main
checkout>/.claude/agents, where the installed agent definitions must match agents/),
REVIEWER_SETTLE_SECONDS (120; how long a transcript whose last assistant line is text only and not
stamped `end_turn` must sit untouched before it counts as finished).
"""
from __future__ import annotations

import argparse
import hashlib
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
from dataclasses import asdict, dataclass, replace
from datetime import datetime
from pathlib import Path, PurePosixPath
from typing import AbstractSet, Iterable, Literal, Mapping

Axis = Literal["standards", "spec"]
AXES: tuple[Axis, ...] = ("standards", "spec")
BANNED = ("eval", "test", "judge", "score", "benchmark", "candidate", "rubric", "experiment",
          "compare", "arena")
HARD_HEADINGS = ("Would break", "Fails open")
GITHUB_REPO = "Zenoctra/factory918"
FETCH_KEEP_REFS = "git fetch origin 'refs/keep/103/*:refs/keep/103/*'"
EFFORT = "high"
COUNT_LINE = re.compile(r"hard findings: ([0-9]+)")
ITEM_LINE = re.compile(r"(\d+)\. ")
FENCE_LINE = re.compile(r"\s*(`{3,}|~{3,})")
USAGE_LIMIT = "usage-limit"
NO_RESPONSE = "no-response"  # a lane whose last line is the harness's own, as on an API error
VERSION = 2  # of receipt.json and run.json; #103 wrote version 1
GIVE_UP = 3  # contaminated or unanswered attempts after which a run is prepared no more
USAGE_LIMIT_LINE = re.compile(r"hit your (?:\w+ )?limit", re.I)  # "usage limit" and "session limit" both occur
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
    ticket: str | None = None
    pr: str | None = None


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
    # Tool calls that named a path outside the export: a record, not a verdict.
    outside: tuple[str, ...] = ()
    # The first tool call whose result contaminated the run, as {"call": ordinal, "timestamp": ...}.
    first_contaminated: Mapping[str, object] | None = None
    # Per report item, the earliest tool call whose result already held every line the item quotes.
    sightings: tuple[Mapping[str, object], ...] = ()


Failure = Literal["no-report", "no-count-line", "count-exceeds-items", "no-hard-headings"]


@dataclass(frozen=True)
class Item:
    n: int
    hard: bool
    text: str
    raw: str
    quoted: tuple[str, ...] = ()


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


class Foreign(Refusal):
    """A run directory written by another measurement, such as #103's."""


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
        keys: dict[str, str] = {}
        recipe = rdir / "inputs" / "recipe"
        for line in recipe.read_text().splitlines() if recipe.is_file() else ():
            key, _, value = line.partition("=")
            keys[key.strip()] = value.strip()
        for i, line in enumerate(rfile.read_text().splitlines(), 1):
            key, sep, value = line.partition("=")
            if line.strip() and not sep:
                raise bad(rfile, i, f"not key=value: {line}")
            keys[key.strip()] = value.strip()
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
            briefs[BriefId(rdir.name, axis)] = Brief(BriefId(rdir.name, axis), head, review, relpath,
                                                     keys.get("ticket"), keys.get("pr"))

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
    # An item's number, whether it is hard, all its lines, its lines outside fenced blocks, and the
    # lines it quotes inside them.
    current: tuple[int, bool, list[str], list[str], list[str]] | None = None
    fence: str | None = None

    def close() -> None:
        if current:
            items.append(Item(current[0], current[1], normalize(" ".join(current[2])),
                              " ".join(" ".join(current[3]).split()), tuple(current[4])))

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
            current = (int(m.group(1)), heading in HARD_HEADINGS, [line[m.end():]], [line[m.end():]], [])
        elif current and not count:
            current[2].append(line)
            if not fenced:
                current[3].append(line)
            elif not marker:
                current[4].append(line)
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


# A line under FLOOR characters (after stripping) is too common to date. On the #103 corpus every
# floor from 1 to 56 separates the ten runs that read later code from the 223 that did not; the
# tightest case is one 57-character line, lost at 60. 12 keeps a wide margin under that while leaving
# out short tool output (an exit code, a count, a shell keyword) that no corpus run happened to hit.
# One hit is enough: that tightest case has exactly one.
FLOOR = 12
# Lines that date nothing: no letter or digit, a fence marker, a Markdown heading of one word.
GENERIC_LINE = re.compile(r"^[^A-Za-z0-9]*$|^(`{3,}|~{3,})\S*$|^#+\s*\S+$")
# What tools put before a file's line: Read's `12→` or `12<tab>`, cat -n's `12<tab>`, grep -n's
# `12:` or `12-`, and grep's `path:12:` or `path-12-` over several files.
TOOL_PREFIXES = (re.compile(r"^\s*\d+(?:→|\t|:|-)"), re.compile(r"^.*?[:-]\d+[:-]"))
# Tools whose results the content check cannot see or date; every other tool, Bash and Skill
# included, is judged by what its results hold.
UNDATED_TOOLS: Mapping[str, str] = {
    "Agent": "its reads land in another transcript",
    "Task": "its reads land in another transcript",
    "WebFetch": "it returns live network state git does not hold",
    "WebSearch": "it returns live network state git does not hold",
}


def dated(line: str) -> str | None:
    """The line as the check compares it, or None when it is too short or too generic to date."""
    s = line.strip()
    return None if len(s) < FLOOR or GENERIC_LINE.match(s) else s


def readings(line: str) -> set[str]:
    """The line as returned and with each tool prefix stripped, each kept only if it dates."""
    forms = {line}
    for prefix in TOOL_PREFIXES:
        if m := prefix.match(line):
            forms.add(line[m.end():])
    return {d for f in forms if (d := dated(f))}


def text_lines(texts: Iterable[str]) -> set[str]:
    return {d for t in texts for line in t.splitlines() if (d := dated(line))}


@dataclass(frozen=True)
class Leak:
    line: str
    commit: str
    tool: str
    call: int
    timestamp: str | None


@dataclass(frozen=True)
class Result:
    call: int
    name: str
    args: dict
    body: str
    timestamp: str | None


def tool_results(lines: list[dict]) -> list[Result]:
    """Every tool_result in the transcript, with the tool call that asked for it and its ordinal."""
    uses: dict[str, tuple[int, str, dict]] = {}
    out = []
    for line in lines:
        content = (line.get("message") or {}).get("content")
        for c in content if isinstance(content, list) else ():
            if not isinstance(c, dict):
                continue
            if c.get("type") == "tool_use":
                uses[c.get("id")] = (len(uses) + 1, c.get("name") or "?", c.get("input") or {})
            elif c.get("type") == "tool_result":
                body = c.get("content")
                if isinstance(body, list):
                    body = "\n".join(str(b.get("text", "")) for b in body if isinstance(b, dict))
                call, name, args = uses.get(c.get("tool_use_id"), (0, "?", {}))
                out.append(Result(call, name, args, body if isinstance(body, str) else "", line.get("timestamp")))
    return out


def tool_uses(lines: list[dict]) -> list[tuple[int, str, dict, str | None]]:
    """(ordinal, name, input, timestamp) of every tool call, in transcript order."""
    out = []
    for line in lines:
        content = (line.get("message") or {}).get("content")
        for c in content if isinstance(content, list) else ():
            if isinstance(c, dict) and c.get("type") == "tool_use":
                out.append((len(out) + 1, c.get("name") or "?", c.get("input") or {}, line.get("timestamp")))
    return out


def leaks(lines: list[dict], future: Mapping[str, str], given: AbstractSet[str]) -> list[Leak]:
    """Every result line that only a later commit or live GitHub text holds, and the run was not given."""
    found = []
    for r in tool_results(lines):
        for raw in r.body.splitlines():
            forms = readings(raw)
            if forms & given:
                continue
            if hit := next((f for f in sorted(forms, key=len, reverse=True) if f in future), None):
                found.append(Leak(hit, future[hit], f"{r.name} {json.dumps(r.args)[:80]}", r.call, r.timestamp))
    return found


@dataclass(frozen=True)
class Verdict:
    detail: str | None
    first: Mapping[str, object] | None


# The session scratchpad the harness names to every lane, and the words of a Bash command that write.
SCRATCHPAD = re.compile(r"(?:/private)?/tmp/claude-\d+/[^/\s'\"]+/[^/\s'\"]+/scratchpad(?=/|$|[\s'\"`;|&()<>])")
PATH_TAIL = r"[^\s'\"`;|&()<>]*"
WRITES = re.compile(r">|\b(?:tee|mkdir|cp|mv|touch|ln|rsync|unzip|tar|git init|git clone)\b")
ASSIGNMENT = re.compile(r"\b([A-Za-z_]\w*)=(\"[^\"]*\"|'[^']*'|[^\s;&|]+)")


def expand(command: str) -> str:
    """The command with the values its own `NAME=value` assignments give substituted for $NAME and ${NAME}."""
    for _ in range(3):
        for name, value in ASSIGNMENT.findall(command):
            command = re.sub(r"\$\{?" + name + r"\b\}?", lambda _, v=value.strip("\"'"): v, command)
    return command


def cross_run_reads(lines: list[dict], export: Path) -> list[tuple[int, str, str, str | None]]:
    """Tool calls that read the shared scratchpad or another run's export at a path this run did not write.

    A plain path match: a path under the session scratchpad, or under REVIEWER_WORK/<another nonce>, is
    this run's own once a Write or Edit named it or a Bash command that writes (a redirect, tee, mkdir,
    cp and the like) named it, and everything under it is too. The bare scratchpad or work directory
    names no file and is skipped. `$NAME` set in the same command is expanded first.
    """
    work, nonce = str(export.parent.parent).removeprefix("/private"), export.parent.name
    other_run = re.compile(r"(?:/private)?" + re.escape(work) + r"/(?!" + re.escape(nonce) + r"(?:/|$|[\s'\"`;|&()<>]))[^/\s'\"]+")

    def shared(text: str) -> list[str]:
        found = []
        for pattern in (SCRATCHPAD, other_run):
            for m in re.finditer(pattern.pattern + PATH_TAIL, text):
                path = m.group(0).removeprefix("/private").rstrip("/")
                if not re.fullmatch(SCRATCHPAD.pattern.removeprefix("(?:/private)?"), path) and path != work:
                    found.append(path)
        return found

    owned: set[str] = set()
    reads = []
    for call, name, args, ts in tool_uses(lines):
        if name in ("Write", "Edit", "NotebookEdit"):
            owned.update(shared(args.get("file_path", "")))
            continue
        if name in ("Read", "Grep", "Glob"):
            paths = shared(" ".join(str(args.get(k, "")) for k in ("file_path", "path", "pattern")))
        elif name == "Bash":
            command = expand(args.get("command", ""))
            paths = shared(command)
            if WRITES.search(command):
                owned.update(paths)
                continue
        else:
            continue
        for path in dict.fromkeys(paths):
            if not any(path == o or path.startswith(o + "/") for o in owned):
                reads.append((call, name, path, ts))
    return reads


def contamination(lines: list[dict], future: Mapping[str, str], given: AbstractSet[str], export: Path) -> Verdict:
    """Why the run's transcript shows it saw what its reviewed commit could not, and where it first did."""
    undated = [(call, name, ts) for call, name, _, ts in tool_uses(lines) if name in UNDATED_TOOLS]
    crossed = cross_run_reads(lines, export)
    found = leaks(lines, future, given)
    said = sorted({f"{name} ({UNDATED_TOOLS[name]})" for _, name, _ in undated})
    said += [f"cross-run read at call {call}: {name} {path}" for call, name, path, _ in crossed[:3]]
    said += [f"{k.tool} returned a line first added by {k.commit[:7] if HEX.fullmatch(k.commit) else k.commit}: "
             f"{k.line[:100]}" for k in found[:3]]
    if len(found) > 3:
        said.append(f"and {len(found) - 3} more such lines")
    firsts = [(call, ts) for call, _, ts in undated] + [(call, ts) for call, _, _, ts in crossed]
    firsts += [(k.call, k.timestamp) for k in found]
    first = min(firsts, key=lambda f: f[0]) if firsts else None
    return Verdict("; ".join(said) or None, {"call": first[0], "timestamp": first[1]} if first else None)


HEX = re.compile(r"[0-9a-f]{40}")
CD_TARGET = re.compile(r"(?:^|[;&|(]\s*)cd\s+(\"[^\"]+\"|'[^']+'|\S+)")


def outside_calls(lines: list[dict], export: Path) -> tuple[str, ...]:
    """Tool calls that named a path outside the export: a file tool's path, a Bash `cd` target or absolute argument."""
    root = str(export).rstrip("/")

    def out(path: str) -> bool:
        return path.startswith(("/", "~")) and path != "/dev/null" and not (path == root or path.startswith(root + "/"))

    record = []
    for call, name, args, _ in tool_uses(lines):
        if name in ("Read", "Edit", "Write"):
            paths = [args.get("file_path", "")]
        elif name in ("Grep", "Glob"):
            paths = [args.get("path") or ""]
        elif name == "Bash":
            command = args.get("command", "")
            paths = [m.group(1).strip("\"'") for m in CD_TARGET.finditer(command)]
            paths += [w.strip("\"'") for w in command.split() if w.strip("\"'").startswith("/")]
        else:
            continue
        record += [f"{call} {name} {p}" for p in dict.fromkeys(paths) if out(p)]
    return tuple(record)


def sightings(items: list[Item], lines: list[dict]) -> tuple[Mapping[str, object], ...]:
    """Per report item, the earliest tool call whose result already held every line the item quotes, or None."""
    results = [(r.call, {f for raw in r.body.splitlines() for f in readings(raw)}) for r in tool_results(lines)]
    out = []
    for item in items:
        quoted = {d for line in item.quoted if (d := dated(line))}
        call = next((c for c, seen in results if quoted and quoted <= seen), None)
        out.append({"n": item.n, "hard": item.hard, "call": call})
    return tuple(out)


def receipt_from_transcript(run: RunId, lines: list[dict], expect: re.Pattern[str], source: Path,
                            future: Mapping[str, str], given: AbstractSet[str], export: Path) -> Receipt:
    assistant = [line for line in lines if line.get("type") == "assistant"]
    stamps = [stamp(line["timestamp"]) for line in lines if line.get("timestamp")]
    wall_ms = int((stamps[-1] - stamps[0]).total_seconds() * 1000) if stamps else None
    if usage_limited_transcript(lines):
        return Receipt(run, "dropout", f"{USAGE_LIMIT}: the transcript says the account hit its usage limit",
                       None, None, None, wall_ms, source)
    served = [line for line in assistant if (line.get("message") or {}).get("model") not in (None, "<synthetic>")]
    # Drift is refused before a dying lane is retried: a drifted definition retried stays drifted.
    models = sorted({line["message"]["model"] for line in served})
    wrong = [m for m in models if not expect.search(m)]
    if wrong:
        raise Refusal(f"{run.descriptor} {run.brief} step {run.step} was served {', '.join(wrong)}; "
                      f"{run.descriptor} pins {expect.pattern}; the agent definition drifted: fix it, "
                      f"remove the run directory, run next again")
    efforts = sorted({str(line.get("effort")) for line in served})
    if served and efforts != [EFFORT]:
        raise Refusal(f"{run.descriptor} {run.brief} step {run.step} ran at effort {', '.join(efforts)}; "
                      f"every run is at effort {EFFORT}; set `effort: {EFFORT}` in the agent definition, "
                      f"remove the run directory, run next again")
    # A lane whose last word is the harness's, not a model's, died: before its first answer or after.
    if not served or (assistant[-1].get("message") or {}).get("model") == "<synthetic>":
        said = " ".join(assistant_text(line) for line in assistant
                        if (line.get("message") or {}).get("model") == "<synthetic>").strip()
        return Receipt(run, "dropout", f"{NO_RESPONSE}: {said[:120]}", None, None, None, wall_ms, source)
    usage: dict[str, dict] = {}
    for i, line in enumerate(assistant):
        u = (line.get("message") or {}).get("usage")
        if u:
            usage[line.get("requestId") or f"line {i}"] = u
    tokens = Tokens(*(sum(u.get(k) or 0 for u in usage.values())
                      for k in ("input_tokens", "cache_read_input_tokens", "cache_creation_input_tokens", "output_tokens")))

    verdict = contamination(lines, future, given, export)
    status: Status = "contaminated" if verdict.detail else "complete"
    return Receipt(run, status, verdict.detail or "complete", models[-1], efforts[0], tokens, wall_ms, source,
                   outside_calls(lines, export), verdict.first)


def usage_limited(receipt: Receipt) -> bool:
    return receipt.status == "dropout" and receipt.detail.startswith(USAGE_LIMIT)


def no_response(receipt: Receipt) -> bool:
    return receipt.status == "dropout" and receipt.detail.startswith(NO_RESPONSE)


def failed(receipt: Receipt) -> bool:
    """An attempt that counts toward giving the run up."""
    return receipt.status == "contaminated" or no_response(receipt)


def redo(receipt: Receipt) -> bool:
    """A run whose result says nothing about the model: moved aside and prepared again."""
    return failed(receipt) or usage_limited(receipt)


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
    no_response: int


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
                            sum(1 for r in mine if usage_limited(r)),
                            sum(1 for r in mine if no_response(r))))
    return rows


COLUMNS = ("arm", "pass", "chains", "new truth bugs", "cumulative", "demoted", "other hard items",
           "context failures", "out tokens", "cache read", "wall s", "contaminated", "usage limit",
           "no response")


def render_table(descriptor: str, rows: list[Row], excluded: int = 0) -> str:
    def f(x: float | None, places: int) -> str:
        return "n/a" if x is None else f"{x:.{places}f}"

    def cells(row: Iterable[str]) -> str:
        return "| " + " | ".join(row) + " |"

    lines = [f"## {descriptor}", "", "Means per chain; a masked pass leaves out the bugs its tree has fixed.",
             f"Contaminated runs excluded from recall: {excluded}.", "",
             cells(COLUMNS), cells("---" for _ in COLUMNS)]
    for r in rows:
        lines.append(cells([r.arm, str(r.pass_), str(r.chains), f(r.new, 2), f(r.cumulative, 2), f(r.demoted, 2),
                            f(r.other, 2), str(r.failures), f(r.output, 0), f(r.cache_read, 0), f(r.wall_s, 1),
                            str(r.contaminated), str(r.usage_limit), str(r.no_response)]))
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


def future_lines(repo: Path, head: str, cache: Path) -> Mapping[str, str]:
    """Every dated line a commit after the head added, with the first commit that added it.

    The commits are those the keep refs and origin/main reach and the head does not, committed after
    it. A PR rebased onto main after its review carries its later code on main, not above its head,
    so descent alone would miss it. Cached under `cache`, keyed by the head and the commits read.
    """
    tips = git(repo, "for-each-ref", "--format=%(objectname)", "refs/keep/103", "refs/remotes/origin/main").split()
    when = int(git(repo, "log", "-1", "--format=%ct", head))
    listed = git(repo, "log", "--reverse", "--topo-order", "--format=%H %ct", *tips, f"^{head}").splitlines() if tips else []
    commits = [c for c, ct in (entry.split() for entry in listed) if int(ct) > when]
    path = cache / f"future-{head}-{hashlib.sha1(' '.join(commits).encode()).hexdigest()[:16]}.json"
    if path.is_file():
        return json.loads(path.read_text())
    out: dict[str, str] = {}
    for c in commits:
        for line in git(repo, "show", "--format=", "--no-color", "--no-ext-diff", c).splitlines():
            if line.startswith("+") and not line.startswith("+++") and (d := dated(line[1:])) and d not in out:
                out[d] = c
    cache.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(out))
    return out


def live_lines(ticket: str | None, pr: str | None, frozen: Iterable[str], cache: Path) -> Mapping[str, str]:
    """The round's ticket and PR as GitHub holds them now, less the frozen copies the round was briefed from.

    What is left was written after the review, so a run that reads it read the future. The text is
    fetched once with gh and cached under `cache`; without the cache and without gh the check refuses.
    """
    wanted = ([(f"live #{ticket}", ["issue", "view", ticket])] if ticket else []) + \
             ([(f"live PR #{pr}", ["pr", "view", pr])] if pr else [])
    path = cache / f"github-{ticket}-{pr}.json"
    if path.is_file():
        texts = json.loads(path.read_text())
    else:
        texts = {}
        for label, args in wanted:
            argv = ["gh", *args, "--repo", GITHUB_REPO, "--json", "body,comments"]
            proc = subprocess.run(argv, capture_output=True, text=True)
            if proc.returncode:
                raise Refusal(f"the {label} text is not cached at {path} and `{' '.join(argv)}` failed "
                              f"({proc.stderr.strip()[-200:]}); run it where gh reaches GitHub, or copy that cache file here")
            j = json.loads(proc.stdout)
            texts[label] = [j.get("body") or "", *(c.get("body") or "" for c in j.get("comments") or [])]
        cache.mkdir(parents=True, exist_ok=True)
        path.write_text(json.dumps(texts))
    old = text_lines(frozen)
    return {d: label for label, bodies in texts.items() for d in text_lines(bodies) if d not in old}


def round_future(env: Env, brief: Brief) -> Mapping[str, str]:
    """Every line only the future holds for the brief's round: later commits, then live GitHub text."""
    cache = env.out / "cache"
    inputs = brief.files.parent / "inputs"
    frozen = [f.read_text() for f in (inputs / n for n in ("ticket.md", "previous.txt", "blast-radius.md")) if f.is_file()]
    return {**live_lines(brief.ticket, brief.pr, frozen, cache), **future_lines(env.repo, brief.head, cache)}


def tree_lines(repo: Path, commit: str, cache: Path) -> AbstractSet[str]:
    """The dated lines of every file in the commit's tree, cached under `cache` by the commit."""
    path = cache / f"tree-{commit}.json"
    if path.is_file():
        return frozenset(json.loads(path.read_text()))
    blobs = [entry.split()[2] for entry in git(repo, "ls-tree", "-r", commit).splitlines() if entry.split()[1] == "blob"]
    batch = subprocess.run(["git", "-C", str(repo), "cat-file", "--batch"], input="\n".join(blobs).encode(),
                           capture_output=True, check=True).stdout
    texts, i = [], 0
    while i < len(batch):
        header_end = batch.index(b"\n", i)
        size = int(batch[i:header_end].split()[2])
        texts.append(batch[header_end + 1:header_end + 1 + size].decode("utf-8", "replace"))
        i = header_end + 1 + size + 1
    return save_tree(cache, commit, text_lines(texts))


def save_tree(cache: Path, commit: str, lines: AbstractSet[str]) -> AbstractSet[str]:
    cache.mkdir(parents=True, exist_ok=True)
    (cache / f"tree-{commit}.json").write_text(json.dumps(sorted(lines)))
    return frozenset(lines)


def dir_lines(root: Path) -> set[str]:
    return text_lines(f.read_text(errors="replace") for f in root.rglob("*") if f.is_file())


def load_env() -> Env:
    here = Path(__file__).resolve().parent
    top = Path(git(here, "rev-parse", "--show-toplevel"))
    main = Path(git(top, "rev-parse", "--path-format=absolute", "--git-common-dir")).parent
    transcripts = os.environ.get("REVIEWER_TRANSCRIPTS") or str(
        Path.home() / ".claude" / "projects" / re.sub(r"[^A-Za-z0-9]", "-", str(main)))
    return Env(
        fixtures=Path(os.environ.get("REVIEWER_FIXTURES") or here),
        out=Path(os.environ.get("REVIEWER_OUT") or top / ".scratch" / "eval" / "reviewer-138"),
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
    return {"version": VERSION, "run": r.run.to_json(), "status": r.status, "detail": r.detail,
            "reported_model": r.reported_model, "effort": r.effort,
            "tokens": asdict(r.tokens) if r.tokens else None, "wall_ms": r.wall_ms, "source": str(r.source),
            "outside": list(r.outside), "first_contaminated": r.first_contaminated, "sightings": list(r.sightings)}


def ours(d: Path, j: dict, what: str) -> dict:
    """The file's contents when this measurement wrote it; a Foreign refusal otherwise."""
    if j.get("version") != VERSION or "step" not in (j.get("run") or {}):
        raise Foreign(f"{d}: a {what} from another measurement (version {j.get('version')}); "
                      f"set REVIEWER_OUT to a fresh directory or move it aside")
    return j


def receipt_at(d: Path) -> Receipt | None:
    path = d / "receipt.json"
    if not path.is_file():
        return None
    j = ours(d, json.loads(path.read_text()), "receipt")
    return Receipt(RunId.from_json(j["run"]), j["status"], j["detail"], j["reported_model"], j["effort"],
                   Tokens(**j["tokens"]) if j["tokens"] else None, j["wall_ms"], Path(j["source"]),
                   tuple(j.get("outside", ())), j.get("first_contaminated"), tuple(j.get("sightings", ())))


def prepared_at(d: Path) -> Prepared | None:
    path = d / "run.json"
    if not path.is_file():
        return None
    j = ours(d, json.loads(path.read_text()), "run.json")
    return Prepared(RunId.from_json(j["run"]), j["nonce"], Path(j["checkout"]), j["prompt"],
                    tuple(j.get("settled", ())), tuple(j.get("applied", ())), tuple(j.get("masked", ())), j.get("tree"))


def state(d: Path) -> Literal["absent", "prepared", "collected", "broken"]:
    if not d.exists():
        return "absent"
    if (d / "receipt.json").is_file():
        return "collected"
    return "prepared" if (d / "run.json").is_file() else "broken"


SCRATCH_DIR = ".scratch/work"


def frozen_inputs(brief: Brief) -> dict[str, Path]:
    """The round's frozen ticket, and its blast-radius grounding where it has one, by the name the export gives them."""
    inputs = brief.files.parent / "inputs"
    return {name: inputs / name for name in ("ticket.md", "blast-radius.md") if (inputs / name).is_file()}


def plan(run: RunId, brief: Brief, work: Path) -> Prepared:
    nonce = secrets.token_hex(6)
    checkout = work / nonce / "factory918"
    here = f"{checkout}/{brief.report_relpath.parent}"
    prompt = (f"Read `{here}/{run.brief.axis}-brief.md` whole and follow it. "
              f"You are working in `{checkout}`; every relative path in the brief is relative to it.")
    frozen = frozen_inputs(brief)
    if "ticket.md" in frozen:
        prompt += f" The ticket as it stood at this commit is `{here}/ticket.md`"
        prompt += f", and the PR's grounding is `{here}/blast-radius.md`." if "blast-radius.md" in frozen else "."
    # "test files" would put a BANNED word in the prompt.
    prompt += f" Your scratch folder for notes and any files you make is `{checkout}/{SCRATCH_DIR}/`."
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
        tag = "S" if run.brief.axis == "standards" else "P"
        hard = [i for s in earlier for i in s.items if i.hard]
        settled = tuple(f"{n}. [{tag}{i.n}] {i.raw}" for n, i in enumerate(hard, 1))
        bfile = target / f"{run.brief.axis}-brief.md"
        bfile.write_text(settle(bfile.read_text(), run.brief.axis, list(settled)))
    for name, source in frozen_inputs(brief).items():
        shutil.copyfile(source, target / name)
    (p.checkout / SCRATCH_DIR).mkdir(parents=True, exist_ok=True)
    # What the run was given, for the content check at collect and at every recheck.
    (d / "given").mkdir()
    for name in ("diff", f"{run.brief.axis}-brief.md", *frozen_inputs(brief)):
        shutil.copyfile(target / name, d / "given" / name)
    if applied:
        save_tree(env.out / "cache", tree, dir_lines(p.checkout))
    done = Prepared(run, p.nonce, p.checkout, p.prompt, settled, applied, masked, tree)
    (d / "prompt.txt").write_text(p.prompt)
    write_json(d / "run.json", {"version": VERSION, "run": run.to_json(), "nonce": p.nonce, "checkout": str(p.checkout),
                                "prompt": p.prompt, "tree": tree, "settled": list(settled),
                                "applied": list(applied), "masked": list(masked),
                                "plain_head": not applied})
    return done


def given_lines(p: Prepared, d: Path, fx: Fixtures, env: Env) -> AbstractSet[str]:
    """What the run was given: its tree (the head, or the folded masked commit), its review files and frozen inputs.

    A run prepared before `given/` was kept is rebuilt from the fixtures, a masked one through rebuild.sh.
    """
    brief, cache = fx.briefs[p.run.brief], env.out / "cache"
    tree = p.tree or brief.head
    if (cache / f"tree-{tree}.json").is_file() or not p.applied:
        lines = set(tree_lines(env.repo, tree, cache))
    else:
        with tempfile.TemporaryDirectory() as tmp:
            export_masked(env, p.run.brief.round, Path(tmp) / "x", p.applied)
            lines = set(save_tree(cache, tree, dir_lines(Path(tmp) / "x")))
    if (d / "given").is_dir():
        return lines | dir_lines(d / "given")
    brief_text = (brief.files / f"{p.run.brief.axis}-brief.md").read_text()
    return lines | text_lines([settle(brief_text, p.run.brief.axis, list(p.settled)), (brief.files / "diff").read_text(),
                               *(f.read_text() for f in frozen_inputs(brief).values())])


def launch_line(p: Prepared, brief: Brief, out: Path) -> str:
    route = MODELS[p.run.descriptor]
    return json.dumps({"run": str(p.run.dir(out)), "agent": dict(route.agent),
                       "description": f"Review {brief.head[:7]} {p.run.brief.axis}", "prompt": p.prompt})


def collect_one(p: Prepared, receipt: Receipt, brief: Brief, fx: Fixtures, out: Path) -> str:
    d = p.run.dir(out)
    report = p.checkout / brief.report_relpath
    if receipt.status != "dropout" and report.is_file():
        shutil.copyfile(report, d / "report.md")
    receipt = with_sightings(receipt, d)
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


def with_sightings(receipt: Receipt, d: Path) -> Receipt:
    parsed = parse_report((d / "report.md").read_text()) if (d / "report.md").is_file() else "no-report"
    if isinstance(parsed, str) or not receipt.source.is_file():
        return receipt
    return replace(receipt, sightings=sightings(parsed, read_jsonl(receipt.source)))


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
    if message.get("stop_reason") == "end_turn":
        return True
    # A run can end on a text-only line not stamped end_turn, the harness's own lines among them,
    # so read a transcript that has stopped growing as done.
    content = message.get("content")
    # A plain-string content is text, as assistant_text reads it.
    blocks = content if isinstance(content, list) else [{"type": "text"}] if isinstance(content, str) else []
    if not blocks or any(not isinstance(c, dict) or c.get("type") != "text" for c in blocks):
        return False
    return time.time() - path.stat().st_mtime >= settle_s


def run_dirs(out: Path) -> list[Path]:
    return sorted((d for d in out.glob("runs/*/*/*/*") if d.is_dir()), key=lambda d: natural(str(d)))


def failed_attempts(run: RunId, out: Path) -> list[Receipt]:
    """The failed attempts of a run: those set aside under dropped/ and the one in its directory."""
    rel = run.dir(out).relative_to(out / "runs")
    kept = [receipt_at(p) for p in (out / "dropped" / rel).glob("*") if (p / "receipt.json").is_file()]
    return [r for r in [*kept, receipt_at(run.dir(out))] if r and failed(r)]


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
    given_up: list[tuple[Path, str]] = []
    for run in runs:
        d = run.dir(out)
        st = state(d)
        if st == "broken":
            raise Refusal(f"{d} has no run.json: it was left half-prepared; remove it and run next again")
        receipt = receipt_at(d) if st == "collected" else None
        if receipt and usage_limited(receipt) and run.descriptor not in resume:
            held[run.descriptor] = max(held.get(run.descriptor, 0.0), (d / "receipt.json").stat().st_mtime)
        elif receipt and failed(receipt) and len(tries := failed_attempts(run, out)) >= GIVE_UP:
            given_up.append((d, "contaminated" if all(r.status == "contaminated" for r in tries) else "failed"))
        elif receipt and redo(receipt):
            set_aside(d, out)
            st = "absent"
            if usage_limited(receipt):
                resumed.add(run)
        states[run] = st
    # The account's quota ran out for a held model: nothing more launches for it until the reset.
    states = {run: st for run, st in states.items() if run.descriptor not in held}
    complete = {run for run, st in states.items() if st == "collected" and receipt_at(run.dir(out)).status == "complete"}
    # A prerequisite also needs a report that parses: S and M passes are built from its items.
    needed = {s for spec in STEPS.values() for s in spec.needs}
    stopped = {run: f for run in complete if run.step in needed and (f := rescore(run, fx, out).failure)}
    complete -= stopped.keys()
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
    for d, how in given_up:
        print(f"given up {d}: {how} {GIVE_UP} times")
    for run, failure in sorted(stopped.items(), key=lambda kv: str(kv[0].dir(out))):
        print(f"stopped {run.dir(out)}: {failure}")
    for desc, at in held.items():
        print(f"paused {desc}: usage limit at {datetime.fromtimestamp(at).isoformat(timespec='minutes')}; "
              f"after the reset run: python3 tests/eval/reviewer/reviewer.py next --resume {desc}")
    if lines:
        print("\n".join(lines[:limit]))
    return 0


def recheck(fx: Fixtures, env: Env) -> None:
    """Judge every collected complete or contaminated run again from its transcript; print each change."""
    out = env.out
    for d in [*run_dirs(out), *sorted(d for d in out.glob("dropped/*/*/*/*/*") if d.is_dir())]:
        receipt = receipt_at(d)
        if not receipt or receipt.status not in ("complete", "contaminated"):
            continue
        if not receipt.source.is_file():
            print(f"recheck {d}: its transcript {receipt.source} is gone; it stays {receipt.status}")
            continue
        p = prepared_at(d)
        lines = read_jsonl(receipt.source)
        verdict = contamination(lines, round_future(env, fx.briefs[p.run.brief]), given_lines(p, d, fx, env), p.checkout)
        detail = verdict.detail
        now: Status = "contaminated" if detail else "complete"
        aside = d.is_relative_to(out / "dropped")
        receipt = with_sightings(replace(receipt, outside=outside_calls(lines, p.checkout),
                                         first_contaminated=verdict.first), d)
        if now == receipt.status:
            write_json(d / "receipt.json", receipt_json(replace(receipt, detail=detail or "complete")))
            continue
        if now == "contaminated":
            write_json(d / "receipt.json", receipt_json(replace(receipt, status=now, detail=detail)))
            print(f"recheck {d}: complete -> contaminated: {detail}")
        elif not (d / "report.md").is_file():
            print(f"recheck {d}: clean now, but its report is gone; it stays {'set aside' if aside else 'contaminated'}")
        elif aside and p.run.dir(out).exists():
            print(f"recheck {d}: clean now, but {p.run.dir(out)} holds a later attempt; it stays set aside")
        else:
            home = p.run.dir(out)
            if aside:
                home.parent.mkdir(parents=True, exist_ok=True)
                shutil.move(str(d), str(home))
            write_json(home / "receipt.json", receipt_json(replace(receipt, status=now, detail="complete")))
            print(f"recheck {d}: contaminated -> complete" + (f", back at {home}" if aside else ""))


def cmd_collect(fx: Fixtures, env: Env, again: bool) -> int:
    out = env.out
    if again:
        recheck(fx, env)
    collected, stuck = 0, []
    native: dict[RunId, Prepared] = {}
    for d in run_dirs(out):
        st = state(d)
        try:
            p = prepared_at(d) if st == "prepared" else None
            receipt = receipt_at(d) if st == "collected" else None
        except Foreign:
            stuck.append(d)
            continue
        if receipt:
            collected += 1
        elif p and p.run.descriptor in MODELS and p.run.brief in fx.briefs:
            native[p.run] = p
        else:
            stuck.append(d)
    transcripts = locate(native, env.transcripts, out) if native else {}
    refused: list[Refusal] = []
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
        # One run's refusal must not leave the others uncollected: it is raised after the rest.
        try:
            receipt = receipt_from_transcript(run, lines, MODELS[run.descriptor].expect, path,
                                              round_future(env, fx.briefs[run.brief]),
                                              given_lines(p, p.run.dir(out), fx, env), p.checkout)
        except Refusal as e:
            refused.append(e)
            continue
        print(collect_one(p, receipt, fx.briefs[p.run.brief], fx, out))
        collected += 1
    for p in unlaunched:
        print(f"unlaunched {launch_line(p, fx.briefs[p.run.brief], out)}")
    for d in stuck:
        print(f"stuck {d}")
    print(f"collected {collected} · in flight {in_flight} · unlaunched {len(unlaunched)} · stuck {len(stuck)}")
    if refused:
        raise Refusal("; ".join(map(str, refused)))
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
    table = "\n".join(render_table(d, rows_for(d, scores, complete, masked, dropped),
                                    sum(1 for r in dropped if r.run.descriptor == d and r.status == "contaminated"))
                       for d in names)
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
    verbs.add_parser("collect").add_argument("--recheck", action="store_true")
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
            return cmd_collect(fx, env, args.recheck)
        if args.verb == "table":
            return cmd_table(fx, env)
        return cmd_next(fx, env, list(dict.fromkeys(args.descriptors + args.resume)), args.limit, args.resume)
    except Refusal as e:
        print(f"reviewer: {e}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    sys.exit(main())
