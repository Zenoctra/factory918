# #89 mechanics: patches, `sync`, the knowledge base, the `knowledge` skill

Explored in the worktree `/Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918/.claude/worktrees/owner-89` (branch `feat/design-artifact-on-ticket`, equal to main). All paths below are repo-relative to that worktree root unless written absolute. Read-only: I did not run `./factory918.sh sync` (it rewrites `template/`); everything about it below is read from the code plus a byte-for-byte re-derivation of all 17 patches.

---

## Components Found

### 1. The patch mechanism

- **`patches/README.md`** (11 lines). Three facts: patch paths are relative to `.agents/skills`; `series` gives apply order; the regeneration command is

  ```
  diff -u --label a/<path> --label b/<path> research/<upstream>/<path> template/.agents/skills/<path> > patches/<source>/<path>.patch
  ```

  Line 5 states the invariant: copy pins → drop `no-comments` → copy Pocock's `code-review` to `spec-review` → add our `poteto-mode/playbooks/ticket.md` → apply `series` reproduces `template/.agents/skills` byte-for-byte (verified 2026-09-16 against open-pstack v1.3.0 and mattpocock/skills 6654f6b). Line 11: the session mandate and `ticket.md` are ours, not patches.
- **`patches/series`** (17 lines, one patch path per line, no comments, no blanks in practice). Order: `pstack/poteto-mode/SKILL.md.patch`, the playbooks, `pstack/babysit/SKILL.md.patch` (line 5, interleaved among the playbooks — order is creation order, not grouping), `references/codex-tools.md.patch`, `scripts/runner/model-matrix.test.ts.patch`, `interrogate`, `setup-pstack`, `unslop`, then `mattpocock/spec-review.SKILL.md.patch` last.
- **17 `.patch` files** under `patches/`, exactly matching the 17 `series` lines (no orphans, no missing).
- **`SOURCES.md`**: the upstream pin table (3 rows) plus a numbered list of 13 patch *descriptions* under the heading "## Patches (unified diffs in `patches/`, applied in the order `patches/series` lists; the list below says what each one does)". The numbers are **concepts, not files** — concept 1 (the `pstack:` namespace sweep) spans many patch files, and the list is physically out of order (1,2,3,4,5,6,7,8,11,10,9,12,13). Concept **13** (`SOURCES.md:25`) is exactly the four playbook patches #89 touches: "`playbooks/feature.md` step 2, `playbooks/bug-fix.md` step 3, `playbooks/refactoring.md` step 3 and `playbooks/perf-issue.md` step 3: the `architect` skip clause gains one sentence, that a cross-cutting diff (the Ticket playbook, step 5) never skips it."

### 2. `factory918.sh`

423 lines, `set -euo pipefail`. Dispatch is the `case` at lines 411–423. Relevant subcommands: `cmd_install` (72–90), `cmd_apply` (107–169), `cmd_doctor` (236–…), `cmd_sync` (375–400), and `knowledge)` at line 421 which is just `python3 tools/build_knowledge.py`.

### 3. The knowledge build

- **`tools/build_knowledge.py`** (183 lines): `CORE_DOCS` (37–43), `SOURCES` (44–55), `split_h2` (59), `split_long` (74), `strip_header` (90), `write_chunk` (104), `build_core` (124), `build_generated` (140), `write_index` (166), `__main__` (178–183).
- **`tools/check_knowledge.py`** (25 lines): three assertions — INDEX lists every file with its true line count, no file over 240 lines, every mini-TOC `- L<n>: <name>` points at a heading line whose text equals `<name>`.

### 4. The `knowledge` skill

`template/.agents/skills/knowledge/SKILL.md` (26 lines, only file in the dir). Line 13 defines `$KB`; lines 17–22 are the six-step procedure.

### 5. CI

`.github/workflows/factory-ci.yml` (82 lines), two jobs: `factory` (repository checks) and `fixture` (day-0 flow on a fresh `vp create` monorepo).

---

## Flow

### A. How a vendored skill is changed and kept changed

1. **Edit the file under `template/.agents/skills/<skill>/...` directly.** That is the live product; nothing regenerates it except `sync`.
2. **Regenerate the patch** with the `patches/README.md` command, diffing the `research/` pin against the edited `template/` file, with `--label a/<path>`/`--label b/<path>` where `<path>` is relative to `.agents/skills`. The labels are what make the output apply as a `-p1` patch; without them `diff -u` emits real paths and timestamps.
3. **Add the patch path to `patches/series`** (only matters for ordering when two patches touch one file).
4. **Describe it in `SOURCES.md`** as a numbered item in the Patches list.
5. **`./factory918.sh sync`** re-derives `template/.agents/skills` from the pins + `series`; `git status` must come back clean.

**Verified**: all 17 checked-in patches regenerate byte-identically with the documented command. I ran, for every `pstack/` entry of `series`, `diff -u --label a/$rel --label b/$rel research/3-pstack/open-pstack-claude-code-port/plugins/pstack/skills/$rel template/.agents/skills/$rel` and compared to the checked-in patch: **16/16 OK**. Same for the Pocock one (see below): **OK**.

### B. `cmd_sync` (factory918.sh:375–400), step by step

```
377  skills="$TEMPLATE/.agents/skills"
378  pstack="$F918_DIR/research/3-pstack/open-pstack-claude-code-port/plugins/pstack"
379  matt="$F918_DIR/research/1-matt-pocock/skills-repo/skills"
380  ours="factory918 factory-start knowledge mode-plan mode-build factory-doctor factory-retro"
381  keep_files="poteto-mode/playbooks/ticket.md poteto-mode/scripts/overlap.sh
              spec-review/scripts/review-brief.sh spec-review/scripts/review-comment.sh"
382  tmp=$(mktemp -d)
383  stash each keep_file into $tmp/keep/
384  for each research pstack skill dir (except no-comments): rm -rf $skills/$n; cp -R "$d" "$skills/$n"
385-386 for the 13 named Pocock skills: src=$(find "$matt" -maxdepth 2 -type d -name "$n" | head -1);
         rm -rf; cp -R
387  rm -rf "$skills/spec-review"; cp -R "$matt/engineering/code-review" "$skills/spec-review"
388  restore keep_files
389  rm -rf template/.claude/agents; cp "$pstack"/agents/*.md there; rm comment-sicko.md
391-395 while read p from patches/series:
           git -C "$skills" apply --check "$F918_DIR/patches/$p"  → if ok, apply, echo "applied  $p"
           else echo "FAILED   $p (upstream moved; rewrite the patch)"; failed=1   # loop continues
397  for each of $ours: require $skills/$n/SKILL.md to exist, else "missing our skill", failed=1
398  echo "vendored: N skills. Review with git status, bump VERSION, commit."
399  return $failed
```

Key mechanics:

- **Copy is recursive.** `cp -R "$d" "$skills/$n"` after `rm -rf`, with `$d` ending in `/` from the glob `"$pstack"/skills/*/`. Subdirectories come along: `architect/references/{design-red-flags,rationale-template,runner-prompt}.md` are present in `template/` and identical to the pin.
- **Patch application is `git apply` run with `-C "$skills"`**, so patch paths resolve relative to `template/.agents/skills` (git apply takes paths relative to cwd, then strips one leading component for the `a/`/`b/` prefix). `--check` first, then apply.
- **Failure is non-fatal per patch but fatal overall**: the loop keeps going, prints `FAILED <path>`, and `cmd_sync` returns non-zero at the end.
- **`sync` never touches the network and never bumps VERSION.** The comment at 372–374 says so explicitly: "Vendoring never touches the network: update the pins in `research/` first. Our own skills and playbooks stay; VERSION is bumped by hand in the commit that lands this." `VERSION` currently reads `0.3.0`.
- **"Clean" is decided by CI, not by sync.** `sync` only prints "Review with git status". The actual verification is `.github/workflows/factory-ci.yml:32-33`:
  ```yaml
  - name: Vendored skills equal the pins plus the patches
    run: ./factory918.sh sync > /dev/null && git diff --exit-code && test -z "$(git status --porcelain template)"
  ```
  So: sync must exit 0, the tracked tree must be unchanged, and `template/` must have no untracked files either.

### C. The renamed directory (`code-review` → `spec-review`)

`patches/mattpocock/spec-review.SKILL.md.patch` (139 lines) has headers

```
--- a/spec-review/SKILL.md
+++ b/spec-review/SKILL.md
```

i.e. **both labels use the destination path**, because `sync` does the rename (line 387) *before* the patch loop (391) and the patch is last in `series`. Its first hunk rewrites the frontmatter `name: code-review` → `name: spec-review`; a later hunk rewrites the first heading. Regeneration therefore diffs the *upstream source* path against the *renamed destination* path, which is exactly what I ran and what reproduces it byte-for-byte:

```
diff -u --label a/spec-review/SKILL.md --label b/spec-review/SKILL.md \
  research/1-matt-pocock/skills-repo/skills/engineering/code-review/SKILL.md \
  template/.agents/skills/spec-review/SKILL.md
```

The patch file's *name* is flat and dotted (`mattpocock/spec-review.SKILL.md.patch`), unlike the pstack patches which mirror the directory tree (`pstack/poteto-mode/playbooks/feature.md.patch`). The name is not load-bearing — `series` carries the path and `sync` reads `patches/$p`.

### D. Current state of the two skills #89 touches

| skill | template path | upstream path | patched today? |
|---|---|---|---|
| `architect` | `template/.agents/skills/architect/` (`SKILL.md` 84 lines + `references/design-red-flags.md` 33, `rationale-template.md` 35, `runner-prompt.md` 20) | `research/3-pstack/open-pstack-claude-code-port/plugins/pstack/skills/architect/` | **No.** `diff -r` between the two returns exit 0 — byte-identical, all four files. No entry in `series`, no mention in `SOURCES.md`. |
| `to-spec` | `template/.agents/skills/to-spec/` (`SKILL.md`, `agents/openai.yaml`) | `research/1-matt-pocock/skills-repo/skills/engineering/to-spec/` | **No.** `diff -r` exit 0. |

So (a) and (c) are both **brand-new patches**, each the first for its skill; (b) is four edits to existing patches that today carry exactly one hunk each (`feature.md.patch`, `bug-fix.md.patch`, `perf-issue.md.patch`, `refactoring.md.patch` are 11 lines apiece) and are described together as `SOURCES.md` concept 13.

For `to-spec`, `sync` finds the source with `find "$matt" -maxdepth 2 -type d -name to-spec` → `research/1-matt-pocock/skills-repo/skills/engineering/to-spec` (depth 2 under `skills/`). No rename, so a `to-spec` patch's labels would be `a/to-spec/SKILL.md` / `b/to-spec/SKILL.md`.

### E. How the knowledge base is built

`build_knowledge.py` runs three phases from `__main__` (178–183): `build_core(rows)`, `build_generated(rows)`, `write_index(rows)`.

**`build_core` (124–137).** For each `(rel, title, when)` in `CORE_DOCS`:
- the file must exist under `docs/knowledge/core/`, else `sys.exit("missing hand-maintained core document: …")` (129);
- `strip_header` (90) removes any previously generated header block (the `<!-- lines: -->` line, blank, `## Contents` line, the `- L…` entries, blank);
- body must be ≤ `MAX_LINES` = 220 lines, else `sys.exit("… is over 220 lines; split it or raise MAX_LINES")` (131–132);
- `write_chunk` rewrites the file **in place** with a fresh header + mini-TOC;
- a row is appended to `index_rows`;
- **unless the file is named `CONVERSATION-DIGEST.md`**, the stripped body is written to `template/docs/factory918/<name>` (135–137). That is the only gate on the slim copy: a filename comparison, not a list.

**`write_chunk` (104–120)** is the header/TOC shape everything depends on:
```
<!-- lines: N | source: <rel> | part i/n | title: <title> -->
<blank>
## Contents (line numbers are for the Read tool's offset)
- L<abs>: <heading text>        ← one per line starting "## " or "### " in the body
<blank>
<body>
```
`n_hdr = 3 + len(toc_entries) + 1`; a body line at 0-based index `i` is reported as `L(i + n_hdr + 1)`. `N` is `n_hdr + len(body lines)`.

**`build_generated` (140–163).** `shutil.rmtree` on `spec/`, `pages/`, `notes/` (core/ is never touched), then for each `SOURCES` entry the loader's text is chunked: whole file if ≤220 lines, else `split_h2` then `split_long` (≤220, preferring `### ` boundaries past the halfway mark). One piece → `docs/knowledge/<rel>`; many pieces → `docs/knowledge/<stem>/NN-<slug>.md` where the slug is the H2 title lowercased, non-alphanumerics collapsed to `-`, truncated to 48 chars.

**`write_index` (166–175)** regenerates `docs/knowledge/INDEX.md` wholesale: a fixed 4-line preamble (which names `core/CONVERSATION-DIGEST.md` by hand, line 169), a markdown table `| file | what | lines | read when |`, one row per `index_rows` entry in build order (core first, then `SOURCES` order), and a trailing sentence with the file count. Today: **118 files** (`docs/knowledge/INDEX.md:127`).

**`CORE_DOCS` controls**, per entry: (1) that the file must exist; (2) the INDEX row's title and "read when" column; (3) the INDEX ordering; (4) the `title:` in the header comment; (5) whether the doc is slim-copied (indirectly — everything in the list except the `CONVERSATION-DIGEST.md` filename).

Current core docs and sizes: `PHILOSOPHY.md` 64, `MANUAL.md` 174, `DECISIONS.md` 92, `GLOSSARY.md` 69, `CONVERSATION-DIGEST.md` 53 (with headers). Slim copies: `PHILOSOPHY.md` 54, `MANUAL.md` 155, `DECISIONS.md` 84, `GLOSSARY.md` 65.

### F. What `/knowledge <question>` actually reads

`template/.agents/skills/knowledge/SKILL.md:13`:

> `$FACTORY918_HOME/docs/knowledge` if that variable is set; else `~/.factory918/docs/knowledge`; else this project's `docs/factory918` (slim: philosophy, manual, decisions and glossary only, with no header or mini-TOC, so take line numbers from grep and `wc -l`). Call it `$KB`.

Step 2 (line 18) is the search: `rg -n -i "<two or three terms>" $KB --glob '*.md' | head -40`. Step 1 reads `$KB/INDEX.md` whole first. Step 3 reads the first 30 lines of a candidate (the mini-TOC). Step 4 reads a range.

So a query reaches a page iff **(i)** the page is under `$KB` as a `.md` file and **(ii)** the literal terms appear in it (case-insensitive substring; `rg` default is a regex, plain words work), and, for the agent to pick it from step 1, **(iii)** it has an INDEX row whose "what"/"read when" text makes it look relevant.

**In the factory repo.** `.claude/skills` is a symlink to `../template/.agents/skills` and `.claude/hooks` to `../template/.claude/hooks` (confirmed by `ls -la .claude/`), so the factory runs the template's own `knowledge` skill. `FACTORY918_HOME` is unset on this machine; `~/.factory918` is a symlink to the **main clone** `/Users/manuel/Desktop/Work/Under The Sun Collective/Core_918/factory918`. So `$KB = <main clone>/docs/knowledge` — the full 118-file corpus. **Caveat: from a git worktree under `.claude/worktrees/`, `$KB` still resolves to the main clone**, so a page added on a branch is not visible to `/knowledge` until the branch is checked out in the main clone (or `FACTORY918_HOME` is pointed at the worktree).

**In an applied project.** `cmd_apply` (131–141) copies every file under `template/` that does not already exist in the project, including `docs/factory918/{PHILOSOPHY,MANUAL,DECISIONS,GLOSSARY}.md`, and records each file's sha in `.factory918/manifest.json`. `cmd_install` (72–90) writes only two things to the user's home: the `~/.factory918` symlink (+ `~/.local/bin/factory918`) and `~/.claude/pstack-models.md` with its include line in `~/.claude/CLAUDE.md`. Nothing else of `docs/knowledge/` reaches a project.

Consequence: on a machine that ran `factory918 install`, a project session resolves `$KB` to `~/.factory918/docs/knowledge` and sees the **full** corpus. On a machine without the symlink (a fresh clone of the project, CI, a collaborator), `$KB` falls back to `docs/factory918/`, which holds **only the four slim core docs**. `factory918 doctor` has both checks: line 248 `chk "factory918 installed" "command -v factory918 && [ -d \"${FACTORY918_HOME:-$HOME/.factory918}/docs/knowledge\" ]"`, line 275 `chk "slim knowledge present" "[ -f docs/factory918/PHILOSOPHY.md ] && [ -f docs/factory918/MANUAL.md ]"`.

### G. CI, end to end (`.github/workflows/factory-ci.yml`)

Job `factory` (lines 12–33):
1. `Shell syntax` (19): `bash -n factory918.sh` and `bash -n` on `template/.claude/hooks/*.sh`, `template/.agents/skills/spec-review/scripts/*.sh`, `template/.agents/skills/poteto-mode/scripts/*.sh`, `tests/*/*.sh`. **There is no `shellcheck` step anywhere in this workflow** (the only repo hits for "shellcheck" are two `# shellcheck disable=` directives and a mention in the vendored `wizard` skill). `AGENTS.md` "Verifying" likewise lists `bash -n`, not shellcheck.
2. `bash tests/hooks/delegation.sh` (21)
3. `bash tests/spec-review/review-comment.sh` (23)
4. `bash tests/spec-review/review-brief.sh` (25)
5. `bash tests/poteto-mode/overlap.sh` (27)
6. `bash tests/spec-review/no-stale-wording.sh` (29) — greps `template` and `docs/knowledge/core` for `## Latent` and `A hard finding is wrong behavior in normal use`, fails on any hit.
7. `python3 tools/check_knowledge.py && python3 tools/build_knowledge.py && git diff --exit-code` (31)
8. `./factory918.sh sync > /dev/null && git diff --exit-code && test -z "$(git status --porcelain template)"` (33)

Job `fixture` (34–82): `vp create` a monorepo, `./factory918.sh apply /tmp/fx --scaffold --profile python --name demo`, run `review-brief.sh` against the apply diff with a fake `gh`, then `vp check && vp test run && pnpm sg:test && pnpm sg`, the Python profile's steps, and two negative rule checks.

---

## Files Read

- `/Users/manuel/…/owner-89/patches/README.md` (whole, 11 lines)
- `/Users/manuel/…/owner-89/patches/series` (whole, 17 lines)
- `/Users/manuel/…/owner-89/SOURCES.md` (whole, 25 lines)
- `/Users/manuel/…/owner-89/factory918.sh` — lines 1–40, 72–195, 295–423 (of 423)
- `/Users/manuel/…/owner-89/tools/build_knowledge.py` (whole, 183 lines)
- `/Users/manuel/…/owner-89/tools/check_knowledge.py` (whole, 25 lines)
- `/Users/manuel/…/owner-89/template/.agents/skills/knowledge/SKILL.md` (whole, 26 lines)
- `/Users/manuel/…/owner-89/.github/workflows/factory-ci.yml` (whole, 82 lines)
- `/Users/manuel/…/owner-89/README.md` (whole, 55 lines)
- `/Users/manuel/…/owner-89/tests/spec-review/no-stale-wording.sh` (whole, 13 lines)
- `/Users/manuel/…/owner-89/patches/pstack/poteto-mode/playbooks/feature.md.patch` (whole, 11 lines)
- `/Users/manuel/…/owner-89/patches/mattpocock/spec-review.SKILL.md.patch` (first 40 of 139 lines)
- `/Users/manuel/…/owner-89/template/.agents/skills/architect/SKILL.md` (first 30 of 84)
- `/Users/manuel/…/owner-89/docs/knowledge/INDEX.md` (head + grep)
- `/Users/manuel/…/owner-89/docs/knowledge/core/*.md` (headers only)
- `/Users/manuel/…/owner-89/.claude/settings.json`, `.gitignore`, `AGENTS.md:9`, `template/AGENTS.md:5,31`
- greps across `docs/M0-findings.md`, `docs/FACTORY-SPEC-v2.md`, `template/.agents/skills/**`, `tools/bootstrap/build_template.py:837,865-866`

---

## Boundaries

1. **`research/` is read-only.** `AGENTS.md` "The ways to hurt yourself" #2: "Never edit `docs/knowledge/spec/`, `pages/`, `notes/`, `template/docs/factory918/`, or anything under `research/`." But `build_knowledge.py`'s `SOURCES` sources every generated page from `research/pages/*.md` or `research/notes/*.md`. **So a new generated `pages/scenario-table.md` would require writing a new file under `research/pages/`, which the repository rule forbids.** Two ways out: (i) point the loader at a non-`research` path — `SOURCES` entries are `lambda: rd(<any Path>)`, nothing requires `RESEARCH`; (ii) make the page a sixth core document or a section of an existing one.
2. **`template/docs/factory918/` is generated** (`build_knowledge.py:125,137`) and listed in the same never-edit rule; it is also blocked for the orchestrator by the delegation hook in the execute phase (`tests/hooks/delegation.sh:68`).
3. **Orchestrator write-blocking.** `template/.claude/hooks/delegation.sh:48-57` — during the `execute` phase the orchestrator may only write `docs/agents/ledger.md`, `docs/adr/*`, `docs/knowledge/core/DECISIONS.md`, `docs/M0-findings.md` and the untracked dirs (`.claude/state/`, `.artifacts/`, `.scratch/`, `.plans/`). Note `docs/knowledge/core/DECISIONS.md` is the *only* core doc the orchestrator owns; `GLOSSARY.md`, `MANUAL.md`, `PHILOSOPHY.md` and any new core doc must be written by a lane.
4. **Size caps.** A core doc body must be ≤ 220 lines (`MAX_LINES`, hard `sys.exit`). Any produced file must be ≤ 240 lines (`check_knowledge.py:16`). `MANUAL.md` is already 174/220.
5. **`sync` never fetches and never bumps VERSION** — both are human steps. `SOURCES.md:3` still claims sync "will re-fetch these pins, re-apply the patches, and bump VERSION"; only the middle clause is true (see Non-obvious #3).
6. **Patch order in `series`** only constrains patches that touch the same file. `architect/SKILL.md` and `to-spec/SKILL.md` are each touched by nothing else, so their position is free; the existing file ordering is creation order, not alphabetical or grouped.
7. **`$KB` in a worktree** resolves to the main clone via `~/.factory918`, not to the worktree. A knowledge page added on a branch cannot be exercised with `/knowledge` from that branch's worktree without setting `FACTORY918_HOME`.

---

## Non-Obvious Things

1. **All 17 patches are exactly reproducible with the README command.** I verified every one programmatically (16 pstack + 1 mattpocock), byte-for-byte including the `--label` headers. The convention is real and enforced by CI step 8, not by a linter.
2. **The README's `git apply ../../patches/<file>` is off by one level for this repo.** From `template/.agents/skills`, `../../` is `template/`, and `template/patches` does not exist; the correct relative path here is `../../../patches`. The sentence reads as if written for a project layout (`<project>/.agents/skills`). `sync` itself uses an absolute `$F918_DIR/patches/$p`, so nothing breaks — only the hand instruction is wrong.
3. **`SOURCES.md:3` contradicts `factory918.sh:372-374`.** The former says sync "will re-fetch these pins … and bump VERSION"; the code's own comment says "Vendoring never touches the network" and "VERSION is bumped by hand in the commit that lands this". The code is the truth.
4. **`SOURCES.md`'s patch numbers are not patch files.** 13 numbered concepts vs 17 files; concept 1 alone spans the whole namespace sweep. A new patch for `architect` gets concept **14** (next free number) — or is folded into concept 13, which already names the four playbooks whose `architect` skip clause #89 also edits.
5. **`GLOSSARY.md` has an empty mini-TOC.** `write_chunk` only collects `## `/`### ` lines; `GLOSSARY.md` is one `# ` heading plus `**bold term.**` paragraphs, so its header is `## Contents (…)` followed immediately by a blank line. A glossary entry is findable only by `rg`, never by the TOC step of the skill. Relevant if "scenario table" is added as a glossary entry.
6. **The slim-copy gate is a hardcoded filename.** `build_knowledge.py:135` — `if p.name != "CONVERSATION-DIGEST.md"`. **A sixth core document is therefore automatically shipped to every project** (it lands in `template/docs/factory918/`, `apply` copies it, `update` three-way-merges it) with **zero code changes** unless it should be factory-only, in which case the condition must become a list/flag.
7. **What a sixth core document actually costs.** The script needs only one new `CORE_DOCS` tuple (`build_knowledge.py:37-43`). Everything else is prose that counts the docs:
   - `AGENTS.md:9` "are the five core documents"
   - `template/AGENTS.md:5` (names philosophy/manual/decisions) and `:31` (glossary)
   - `template/.agents/skills/knowledge/SKILL.md:9` "the four source systems, six research notes, three reference pages, the spec, the philosophy" and `:13` "slim: philosophy, manual, decisions and glossary only"
   - `template/.claude/hooks/session-mandate.md:2` (philosophy + manual)
   - `template/.agents/skills/factory918/SKILL.md:40,74`
   - `docs/FACTORY-SPEC-v2.md:186` "projects carry the four core documents" and `:238` item 10, which enumerates PHILOSOPHY/MANUAL/DECISIONS/GLOSSARY (the spec is read-only-by-convention, the M0-findings win where they disagree)
   - `README.md:38-39` layout block
   - `docs/knowledge/INDEX.md` — regenerated, no hand edit
   - `factory918.sh:275` doctor's `slim knowledge present` check tests only PHILOSOPHY + MANUAL, so a sixth doc needs no doctor change (but could get one)
   - `tools/bootstrap/build_template.py:865` hardcodes the four names — **frozen provenance, must not be edited** (`AGENTS.md`: "`tools/bootstrap/` is frozen provenance").
   None of these are machine-checked; nothing counts core docs at runtime.
8. **A page reachable in an applied project without `~/.factory918` must live in one of the four slim docs.** `pages/`, `notes/` and `spec/` never leave the factory repo. If `/knowledge scenario table` must work for a project agent on a bare machine, the content belongs in `GLOSSARY.md`, `MANUAL.md`, `DECISIONS.md`, `PHILOSOPHY.md`, or a new core doc (which, per #6, ships automatically). `CONVERSATION-DIGEST.md` would *not* ship.
9. **"Scenario table" already exists as a practice, undocumented as a term.** It appears three times: `docs/knowledge/core/DECISIONS.md:92` (P24, "the second run designed from a scenario table Manuel approved 2026-09-21 as the ticket's Testing decisions"), its slim copy `template/docs/factory918/DECISIONS.md:84`, `docs/agents/ledger.md:24` (the cut detached-HEAD cell), and `tests/poteto-mode/overlap.sh:6` ("the scenario table in the ticket's design"). So `rg -i "scenario table" $KB` already returns two hits today, both in DECISIONS — a new page must outrank them or be cross-referenced from there.
10. **`check_knowledge.py` only validates TOC entries inside the first 60 lines** (`"\n".join(lines[:60])`, line 17). A file with more than ~55 TOC entries has unverified entries past line 60.
11. **`build_generated` deletes and rebuilds `spec/`, `pages/`, `notes/` wholesale** (`shutil.rmtree`, line 142). Anything hand-placed there vanishes on the next run — which is why CI's `build_knowledge.py && git diff --exit-code` catches a hand-edited generated file.
12. **CI's sync check also rejects untracked files under `template/`** (`test -z "$(git status --porcelain template)"`), so a stray file added to a skill directory but not committed fails the build.
13. **`no-stale-wording.sh` greps `template` and `docs/knowledge/core`** for two retired phrases. New patch text that reintroduces `## Latent` or "A hard finding is wrong behavior in normal use" fails CI. Worth knowing when writing new `architect`/playbook prose about findings.
14. **`sync` restores `keep_files` *before* applying patches**, so a patch could in principle target one of our own kept files — none do today. `keep_files` is `poteto-mode/playbooks/ticket.md`, `poteto-mode/scripts/overlap.sh`, `spec-review/scripts/review-brief.sh`, `spec-review/scripts/review-comment.sh`.
15. **`architect` is referenced by name from six playbooks** — `feature.md:6`, `bug-fix.md:9`, `refactoring.md:9`, `perf-issue.md:16`, `investigation.md:12`, `prototype.md:12` — and by `ticket.md:9` ("Such a change never skips `architect`"). The four that carry the cross-cutting sentence are exactly the four patches in #89(b).
16. **`architect/SKILL.md` already points into `poteto-mode/references/`** (`provider-dispatch.md`, `codex-tools.md`) with relative links `../poteto-mode/references/…`. A patch adding a reference file to `architect/references/` is fine; a *new* file cannot be expressed as a patch to an existing file — a wholly new file under a vendored skill directory would have to be either a `keep_files` entry (like `ticket.md` and `overlap.sh`) or a patch that creates it (`diff -u /dev/null …`, which `git apply` accepts but which the README's command shape does not describe).
17. **`README.md:32` hardcodes "(72 skills)"** and `docs/M0-findings.md:53` justifies the number. Nothing in CI checks it.
18. **`docs/M0-findings.md:114,136` still say "eleven patches"** (there are 17). It is an append-only dated findings log, so this is expected drift, not a bug — but do not treat those lines as current.

---

## Open Questions

1. **I did not run `./factory918.sh sync`** (read-only mandate; it rewrites `template/`). The equivalent evidence I do have is stronger for the patch content (all 17 regenerate byte-identically) but does not exercise `git apply` ordering, the `keep_files` round-trip, or the `ours` presence check. CI step 8 is the authority.
2. **Whether the new "scenario table" page should be factory-only or ship to projects** is a design decision, not a mechanical one. The mechanics say: core doc → ships automatically (except a file literally named `CONVERSATION-DIGEST.md`); `pages/` → factory-only *and* requires a source file outside the never-edit set.
3. **Where a non-`research` source for a generated page should live** has no precedent — every `SOURCES` loader today reads `research/` or `docs/FACTORY-SPEC-v2.md`. `docs/FACTORY-SPEC-v2.md` is the one existing non-`research` loader (`build_knowledge.py:45`), which shows the pattern is allowed.
4. **Whether a new file inside a vendored skill directory (e.g. `architect/references/<new>.md`) is intended to be a `/dev/null` patch or a `keep_files` entry** is not settled by `patches/README.md` or `SOURCES.md`; both precedents exist for *our* files (`keep_files`) but no precedent exists for a create-file patch.
5. **The `feat/shellcheck` branch** (the main clone's current branch) is presumably adding a shellcheck step; this worktree's CI has none. If #89 lands after that branch, the verification list may grow.
