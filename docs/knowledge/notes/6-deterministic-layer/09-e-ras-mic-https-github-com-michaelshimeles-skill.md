<!-- lines: 63 | source: notes/6-deterministic-layer.md | part 9/10 | title: Research note: deterministic layer (verbatim config) — E. Ras Mic — `https://github.com/michaelshimeles/skills/blob/513f8a2/` -->

## Contents (line numbers are for the Read tool's offset)
- L10: E. Ras Mic — `https://github.com/michaelshimeles/skills/blob/513f8a2/`
- L14: E.1 `evidence-driven-testing`
- L39: E.2 `greploop` and `before-and-after`
- L49: E.3 `AGENTS.md` slots
- L55: E.4 `new-feature`: scope check and shared resources

## E. Ras Mic — `https://github.com/michaelshimeles/skills/blob/513f8a2/`

Last commit: `513f8a2 2026-09-03 Merge pull request #8 … feat/add-unslop-skill`. Skills: `before-and-after`, `code-structure`, `evidence-driven-testing`, `greploop`, `greploop-apps`, `new-feature`, `unslop`, plus `AGENTS.md` and `tests/test_evidence.py`.

### E.1 `evidence-driven-testing`

`evidence-driven-testing/SKILL.md` (293 lines, `metadata.version: "1.2"`). Prerequisites (frontmatter `compatibility`, verbatim): "Screen-recording path requires a GUI environment the agent can drive — built-in computer use, or the cua-driver CLI (trycua/cua) when the harness has no computer-use tools — plus an authenticated browser session for the app under test. The bundled recorder (scripts/evidence.py) runs on Linux (X11 via x11grab, Wayland via wf-recorder), macOS (avfoundation, needs Screen Recording permission) and Windows (gdigrab) and needs Python 3 plus ffmpeg + ffprobe built with libx264 and the ass filter. The headless path requires only a running app and a scriptable browser (e.g. Playwright via npx). Posting evidence requires gh (GitHub CLI) or equivalent." `agent-browser` appears only as the env var `AGENT_BROWSER_ARGS="--no-sandbox"` for containers where Chrome fails with "No usable sandbox".

Recorded path (sections 1-5): 1 Prepare the screen ("Note the exact revision under test: `git rev-parse HEAD`"); 2 Start recording — `python3 $EVIDENCE start --output .artifacts/<task-name> --title "…" --commit "$(git rev-parse HEAD)" --branch "$(git branch --show-current)" --environment "…"`, then a `setup` annotation; 3 Test via computer use, annotating `test_start` and `assertion` as you go; 4 `python3 $EVIDENCE stop "$SESSION"` ("burns the annotations into `evidence.mp4`, probes the result, and writes `report.md` and `manifest.json`… It prints `"verified": true` on success"), then "extract a frame at each assertion timestamp (`ffmpeg -ss <t> -i evidence.mp4 -frames:v 1 frame.png`) and check the state and the label are visible"; 5 Post the evidence.

Annotation format, verbatim commands:
```
python3 $EVIDENCE annotate "$SESSION" --type setup \
  --message "Logged in, navigating to connectors page"
python3 $EVIDENCE annotate "$SESSION" --type test_start \
  --message "It should execute the tool directly when permission is 'always'"
python3 $EVIDENCE annotate "$SESSION" --type assertion --result passed \
  --message "Tool ran without a permission prompt"
```
`scripts/evidence.py` enforces: `ANNOTATION_TYPES = ("setup", "test_start", "assertion")`, `ASSERTION_RESULTS = ("passed", "failed", "untested")`, "annotation message must be 80 characters or fewer", "--result is required for assertion annotations", "annotations can only be added while recording". The docstring: "The raw capture is written as MPEG-TS so that a hard stop — SIGKILL, TerminateProcess, a crashed recorder — still leaves a playable, probe-able file… Stopping the recorder never signals a bare, reusable PID."

Headless path file naming, verbatim: "number captures in test order with the assertion in the name — `01-precondition-signed-in.png`, `02-it-saves-on-blur-passed.png` — and keep an `assertions.md` in the artifacts folder listing each `test_start` / `assertion` with its result (`passed` / `failed` / `untested` + reason)." Playwright is run as `npx --yes --package=playwright node record.mjs`. Artifacts go to `.artifacts/<task-name>/` ("gitignore it — evidence gets uploaded, never committed").

Failure before fix, verbatim: "**Bug fixes**: reproduce and capture the failure **before** writing the fix — that capture is the "before" half of a before/after pair." Guardrail: "When verifying a fix, show or reference the old failure alongside the new success."

PR attachment step, verbatim: "Post the video + summary as a PR comment (embed in the PR description if it's your PR). `gh pr comment` cannot attach a local video — upload `evidence.mp4` through the PR's comment box in an authenticated browser, or upload it to a host and link it (for example the `before-and-after` upload adapters). Reopen the comment and confirm the video plays before claiming it is posted."

Other quoted lines: "Every action in the video is the test being performed live; the recording has no value as evidence unless it shows that interactive session."; "**Never** present `--source test` (the synthetic pattern generator) as UI evidence."; "The timestamp records when you asserted, not whether it was true — look at the screen before choosing `passed`."; "Evidence complements the repo's checks (typecheck/build/tests); it never replaces them."; "Confirm the server you're probing is running *your* code (right port, right process)… `lsof -i :<port>`". `write_report` in `evidence.py` emits `## Tested artifact` (commit, branch, environment, recorder), `## Result` (Passed/Failed/Untested counts), `## Timeline`, `## Caveats` (default "- None recorded. Add manual caveats before publishing if needed."; SKILL.md: "Fill in the Caveats section of `report.md`; never leave the placeholder.").

### E.2 `greploop` and `before-and-after`

`greploop/SKILL.md` (vendored from greptileai/skills, `metadata.author: greptileai`, `allowed-tools: Bash(gh:*) Bash(glab:*) Bash(git:*) Bash(p4:*)`). The loop (section 2): A trigger review (`git push`, then `gh pr comment <PR_NUMBER> --body "@greptile review"` unless the Greptile check is already `PENDING`/`IN_PROGRESS`; poll `gh api "repos/{owner}/{repo}/commits/$HEAD_SHA/check-runs"` up to `MAX_ATTEMPTS=60` × `POLL_INTERVAL_SECONDS=10`, "If polling times out, stop the greploop workflow and report the timeout."); B fetch results from the PR body, issue comments (use most recent `updated_at`, "including the 'Prompt to fix all with AI' section"), and reviews from `greptile-apps[bot]`; parse "**Confidence score**: a pattern like `3/5` or `5/5`"; C exit conditions; D fix ("If informational or a false positive, note it but still resolve the thread."); E resolve threads via GraphQL `resolveReviewThread`; F commit `"address greptile review feedback (greploop iteration N)"` and push.

Threshold, verbatim: "Stop the loop if **any** of these are true: Confidence score is **5/5** AND there are **zero unresolved comments**; `--max-iterations` reached (report current state)". `--max-iterations N` "(optional, default **10**): cap on review-fix-push cycles before the loop stops and reports the current state. Raise it for large PRs… lower it to bound cost."

"Unresolved comments" means, per section B: inline review comments from `gh api repos/{owner}/{repo}/pulls/<PR_NUMBER>/comments` (GitHub), `DiffNote` discussions with `"resolved": false` (GitLab), or Swarm comments "not marked as resolved/addressed" (Perforce), plus "actionable items from the latest Greptile general PR comment… even if the inline comment endpoint returns zero unresolved comments." Section E's GraphQL query reads `reviewThreads { nodes { id isResolved … } }`.

`before-and-after/SKILL.md` (vendored from vercel-labs, package `@vercel/before-and-after`). Execution order: "1. Pre-flight — `which before-and-after || npm install -g @vercel/before-and-after` 2. Protection check — if `.vercel.app` URL: `curl -s -o /dev/null -w "%{http_code}" "<url>"` (401/403 = protected) 3. Capture — `before-and-after "<before-url>" "<after-url>"` 4. Upload — `./scripts/upload-and-copy.sh <before.png> <after.png> --markdown` 5. PR integration — optionally `gh pr edit` to append markdown". Flags table: `--mobile` (375x812), `--tablet` (768x1024), `--size <WxH>`, `--full`, `--selector`, `--output` (default `~/Downloads`), `--markdown` ("Upload images & output markdown table"), `--upload-url` (default `0x0.st`). PR body append: `gh pr edit <number> --body "<existing-body>\n\n## Before and After\n<generated-markdown>"`. Rules: "Assume current state is **After**"; ask for the before URL if only one is given; "DO NOT: Switch git branches, stash changes, start dev servers".

### E.3 `AGENTS.md` slots

`AGENTS.md` step 2 of "Completing a task", verbatim: "Run the repo's checks *(repo-specific: list the exact commands here)*." Section "Repo-specific sections to add", verbatim: "When dropping this file into a project, append what agents need to execute the beats there: commands & checks, hard invariants (security and architecture rules), an environment quick reference, local test infrastructure (stubs, fixtures), and anything that can't be tested locally."

The four beats: "1. **Isolate — `/new-feature`.**… 2. **Build — `/code-structure`.**… 3. **Prove — `/evidence-driven-testing`.** Verify with the repo's checks plus runtime evidence. Capture the **before** state while reproducing the issue — prior to fixing it, when it is cheapest — and the **after** once the change works. 4. **Ship — `/before-and-after`, then `/greploop`.**… until Greptile reports **5/5 with zero unresolved comments**." Multi-agent rules include "Never force-push to `main` — and never plain `--force` anywhere; only `--force-with-lease`, only on your own task branch." and "Do not merge the PR unless explicitly instructed."

### E.4 `new-feature`: scope check and shared resources

`new-feature/SKILL.md` step 2, verbatim: "**Scope check**: run `gh pr list` and skim the open PRs' changed files (`gh pr diff <n> --name-only`). If your task needs files another open PR is editing, **stop and ask for direction** instead of proceeding. Also check for uncommitted work in the checkout — another agent may be mid-task."

Shared-resources warning, verbatim: "Worktrees do **not** isolate shared resources: dev-server ports, shared databases, and dependency lockfiles are global. Confirm a port answers *your* process (`lsof -i :<port>`) before trusting what it serves, and resolve lockfile conflicts by regenerating, never by hand-merging."

Harness note: "**Claude Code**: the harness creates and manages worktrees itself (under `.claude/worktrees/<name>`). **Skip steps 3–4 below**".

---
