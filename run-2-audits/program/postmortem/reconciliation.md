# Reconciliation of every suggestion and carried note from the 2026-09-22 run against the filed tickets

Sources: the root's mid-mortem (13:50), the delivery reply (16:15), the post-mortem, the "line" reply, the
five verifier report sets under ../verify/, delegates.md. Written 2026-09-22 evening, before Manuel's go.

## Covered by an open ticket
- Owners invoke the skill and read a digest; poll, never wait; root never rewrites a live parent, rebases before
  verifying, serial owners, one-page report; review at first push; no sleep loops; blast radius beside the writer;
  Spec every round -> #105
- Delegate reports are act-on lists: prose #105, refusal #108
- Fix-only rounds from round two -> #106; reading pack -> #107; eco tier, one runner + judge, writer stays -> #109
- Reviewer model eval -> #103; stacked PR never links its ticket -> #100; SOURCES.md line 3 -> #95
- Concurrent gate runs fail loud (#97 closed) and the checksum refusal in the gate's voice -> #98
- Delegation hook binds only the root; eco decides -> #109
- gh issue edit --body-file replaces the body -> #105 digest

## Not covered: fold into an existing ticket (body edits)
- #105: the trail review runs on every PR (3 of 5 ran it; all 3 found something); Opening a PR's shellcheck line
  names the changed files, the bare form lints only the default globs; tests/spec-review/no-stale-wording.sh joins
  AGENTS.md Verifying; a fix lane proves on the path CI takes; the poll path is the exact absolute path the lane was
  told; the root's registry lines carry `date` output, never typed times.
- #106: a round-one or round-two judgment that marks any item `fixed:` is not review-ready, the next round is owed
  (PR #102's round one read as ready to babysit; the owner caught it by hand); P20's title "Three review rounds at
  most" retitled beside its amendment; ticket #93's table cells 13B, 5C, 5D get direct assertions (same test files).
- #100: when it lands, P29 (open against trunk, then retarget) is reconciled with the root-retarget practice.
- #98: the `shasum -a 256` fallback of the gate's verify step is exercised by a test (never ran on this machine).

## Not covered: new quick tickets, one concern each
- T1 The four playbooks' architect steps carry the posting rule (a Feature run outside the Ticket playbook never
  meets it) [#94 audit, criterion 3 residual]
- T2 factory918 doctor's slim check guards every slim document, not only PHILOSOPHY and MANUAL [#94 runtime]
- T3 factory918 doctor says NOTE, not PASS, when shellcheck on PATH is off the pin [#96 runtime]
- T4 sync's keep_files lists every shell file the CI gate lints (log.sh, worktree-audit.sh) [#96 audit]
- T5 DECISIONS.md Provisional rows keyed so parallel PRs never collide (P25/P26/P26/P26/P27 this run) [mid-mortem]
- T6 The comment tool enforces the `For a person:` label or AGENTS.md drops it (the two disagree) [#101, #102 audits]
- T7 show-me-your-work stamps trail rows with the clock, never a typed time (two trails invented timestamps) [post-mortem]
- T8 The round-five draft stop (P30) exercised on a real PR and recorded in M0-findings [delivery, #102 audit]
- T9 Eval the judge and trail-review models the way #103 evals reviewers (after #103) [post-mortem]
- T10 (optional) overlap.sh's section skip matches headings case-insensitively [#94 runtime, off the path]
- Policy question for Manuel, not a ticket until answered: may an agent amend a closed, approved design record
  (#42 was amended twice by #89's lane)? [#94 audit]

## Dropped as cosmetic or by design
- the risk sentence's "section above" wording; the undemoted-body case's older message; the P6 gap in DECISIONS.md;
  a `hole:` on a continuation line; Ticket step 8's pointer placement; factory918.sh:402's unreachable count;
  layout.sh as a sourced helper; SOURCES.md's numbering; gate.sh's synthetic count of 4 vs the real 11;
  8 of 11 commits never individually built on #94; VERSION not bumped (a release decision, not a defect).
- Operational, not tickets: worktree cleanup (41 on disk); start the last lane of a program with rate-limit headroom.

## Filed 2026-09-22 evening
- Body edits: #105 (+7 criteria incl. the amendment policy), #106 (Manuel's rule: fix-only only after a round whose hard findings were all in fixes; round one/two fixes not review-ready; P20 retitle; #93 cells), #100 (P29), #98 (shasum fallback)
- New: #110 T5 (priority:high, ready), #111 T7 (ready), #112 T9 (ready, blocked by #103), #113 T1, #114 T2, #115 T3, #116 T4, #117 T6, #118 T8 (needs-triage)
- Withdrawn: T10 case-insensitive heading (non-happy-path hardening)
