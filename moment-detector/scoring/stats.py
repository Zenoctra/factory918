"""Intervals and paired comparisons for a detector scored on a few hundred labels,
clustered by session group. Standard library only.

Messages from one session share a user, a task and a mood, so every interval
here treats the session group, not the message, as the unit that was sampled
(Miller 2024, "Adding Error Bars to Evals"). A rate's interval is Wilson's at
the effective sample size, the count divided by the design effect the clusters
cause; anything else (AUROC, precision, differences between variants) is a
percentile interval from resampling whole session groups.
"""

from __future__ import annotations

import math
import random
from collections import defaultdict
from typing import Callable, Sequence, TypeVar

Z = 1.96
B = 2000
T = TypeVar("T")


def wilson(x: float, n: float, z: float = Z) -> tuple[float, float]:
    if n <= 0:
        return (0.0, 1.0)
    p = x / n
    centre = (p + z * z / (2 * n)) / (1 + z * z / n)
    half = z * math.sqrt(p * (1 - p) / n + z * z / (4 * n * n)) / (1 + z * z / n)
    return (max(0.0, centre - half), min(1.0, centre + half))


def clustered_rate(hits: Sequence[tuple[str, bool]]) -> dict:
    """A proportion over (cluster, hit) pairs, with Wilson's interval at the effective n."""
    n = len(hits)
    if n == 0:
        return {"x": 0, "n": 0, "p": None, "lo": None, "hi": None, "deff": None}
    x = sum(h for _, h in hits)
    p = x / n
    by: dict[str, list[int]] = defaultdict(lambda: [0, 0])
    for c, h in hits:
        by[c][0] += h
        by[c][1] += 1
    k = len(by)
    deff = 1.0
    if 0 < p < 1 and k > 1:
        v = k / (k - 1) * sum((xc - p * nc) ** 2 for xc, nc in by.values()) / n ** 2
        deff = max(1.0, v / (p * (1 - p) / n))
    lo, hi = wilson(p * n / deff, n / deff)
    return {"x": x, "n": n, "p": p, "lo": lo, "hi": hi, "deff": deff}


def auroc(pos: Sequence[float], neg: Sequence[float]) -> float | None:
    """Mann-Whitney AUROC; a tie counts half."""
    if not pos or not neg:
        return None
    allv = sorted([(v, 1) for v in pos] + [(v, 0) for v in neg])
    rank_sum, i = 0.0, 0
    while i < len(allv):
        j = i
        while j < len(allv) and allv[j][0] == allv[i][0]:
            j += 1
        avg = (i + j + 1) / 2
        rank_sum += avg * sum(lbl for _, lbl in allv[i:j])
        i = j
    return (rank_sum - len(pos) * (len(pos) + 1) / 2) / (len(pos) * len(neg))


def cluster_bootstrap(rows: Sequence[T], cluster: Callable[[T], str], stat: Callable[[list[T]], float | None],
                      b: int = B, seed: int = 0) -> tuple[float | None, float | None]:
    """95% percentile interval of `stat` over resamples of whole clusters."""
    groups: dict[str, list[T]] = defaultdict(list)
    for r in rows:
        groups[cluster(r)].append(r)
    keys = sorted(groups)
    rng = random.Random(seed)
    vals = []
    for _ in range(b):
        sample = [r for k in rng.choices(keys, k=len(keys)) for r in groups[k]]
        v = stat(sample)
        if v is not None:
            vals.append(v)
    if not vals:
        return (None, None)
    vals.sort()
    return (vals[int(0.025 * len(vals))], vals[min(len(vals) - 1, int(0.975 * len(vals)))])


def ppv(tpr: float, fpr: float, base_rate: float) -> float | None:
    """Precision at a base rate other than the scoring set's."""
    hit = base_rate * tpr
    false = (1 - base_rate) * fpr
    return hit / (hit + false) if hit + false else None
