# Slice: live runtime floor, and try to break the new inside rule
With a fake `gh` (read `tests/spec-review/fake-gh.sh` and the two test harnesses first) and a scratch repository with
commits to review, at the SHA:
(a) The audit's reproduction from `../125-caecbc4/worker-audit.md` section 7 (a plain quote at untouched `old.sh:40`
    sharing `exit 0`, and one sharing `else`): no `fix only after` line now; show caecbc4 printed one.
(b) Adversarial: try at least eight shapes to make an item in untouched code read inside: a quoted `+` line whose text
    also occurs in an untouched file; a quote of a fix line plus a `path:N` outside the ranges; a `path:N` inside the
    ranges but a quote from elsewhere; a Documented step pointing outside; two paths; no path and a unique fix line (the
    owner's accepted case: say whether a real bug in untouched code could be reported that way); CRLF; a removed line;
    a fenced block with a language tag; a hunk with headers. For each, what the script prints and whether it is safe.
(c) The fail-safe direction: an item truly inside the fix (unique fix-added line, path in range) reads inside, and round
    three is fix-only with the fixed point at round two's reviewed commit and `## The fix under review` present.
(d) Rounds one and two byte for byte as at 01a1e5f; rounds four and five after a Would-break fix as #102 made them;
    a wrong fixed point refused with #102's message.
(e) `next round owed:` at rounds one and two exactly when an item is marked `fixed:`; babysit's sentence in both copies.
(f) `fix-lines` and `fix-ranges` computed by the brief: what happens when the reviewed sha does not resolve, is not an
    ancestor, or a file was renamed or deleted by the fix. Safe direction only.
Report: `/Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.scratch/program/verify/125-0edf8c8/worker-runtime.md`.
