verdict: PASS+NOTES

For a person: I ran the new reading pack live against its own PR and against a scratch repository built to break it — odd file names, renames, heredocs, CRLF, binaries, symlinks, submodules, byte-cutoff edges — and it held up: every case produced the header the design calls for, the packs are byte-identical across runs and locales, they stay under the 65536-byte budget, and a git failure inside the pack refuses the brief with the review state untouched. The one thing worth a decision is that the pack reads and prints whole secret-looking files (`.env`, a `.pem`) when they appear in the diff, which widens what a reviewer lane sees well past what the diff used to show.

Setup, at the SHA:
- `git checkout --detach f58308b5eae3f6617cf3a5200e7679e5737a5702` → `HEAD` is `f58308b5eae3f6617cf3a5200e7679e5737a5702`; `git merge-base --is-ancestor 0edf8c8952e7563ec862e460f71becde4506bd96 HEAD` → exit 0. Own worktree `/Users/manuel/.../factory918/.claude/worktrees/agent-aacce6d6f3eb29f15`; all scratch under `/tmp/rtv126/`.

(a) The real brief over the chain itself
- `bash template/.agents/skills/spec-review/scripts/reading-pack.sh 0edf8c8` → exit 0, 58332 bytes of section, 56983 bytes of carried text (budget 65536). 17 entries, in production (path) order, one closing line.
- Headers, verbatim: `### AGENTS.md, whole, 58 lines`; `### SOURCES.md, lines 18-18 of 29`; `### docs/knowledge/INDEX.md, lines 1-29 of 128`; `### docs/knowledge/core/DECISIONS.md, lines 1-1 of 105`; `### docs/knowledge/core/DECISIONS.md, lines 104-105 of 105`; `### factory918.sh, lines 379-405 of 428`; `### patches/mattpocock/spec-review.SKILL.md.patch, lines 25-81 of 146`; `### template/.agents/skills/spec-review/SKILL.md, lines 69-94 of 162`; `### template/.agents/skills/spec-review/scripts/reading-pack.sh, added, 211 lines; the diff carries it whole: no text`; `### template/.agents/skills/spec-review/scripts/review-brief.sh, lines 5-61 of 563`; `... lines 307-364 of 563`; `... lines 421-470 of 563`; `... lines 472-483 of 563`; `### template/docs/factory918/DECISIONS.md, lines 96-97 of 97`; `### tests/spec-review/review-brief.sh, lines 1-44 of 1770`; `... lines 84-152 of 1770`; then `Not carried, over the pack's 65536 bytes: tests/spec-review/review-brief.sh lines 1456-1770. Read these at HEAD from the repository.`
- Boundaries read as a reviewer: `review-brief.sh` 421-470 is the comment-led block at 421-423 merged with the whole `common()` function 424-470; 472-483 is `report_rules()` start to its closing `}`. Sensible cuts. The new script itself is the one entry a reviewer of *this* PR most wants and it is header-only, because at 8.4 KB it is an added file over the whole-file cutoff — correct per the design (the diff carries it), but see note 3.

(b) Adversarial, scratch repo `/tmp/rtv126/adv2` (26 changed paths in one commit). Whole run: exit 0, empty stderr, nothing misleading, no break. Per case:
- space in the name → `### with space.sh, lines 10-143 of 325`, text correct.
- newline in the name → `### $'nl\nname.txt', a path holding a newline: no text`. No breakage of the `-z`-driven loop.
- leading dash (`-leading-dash.md`) → carried; `git ls-tree`/`check-attr`/`cat-file` all guarded by `--` and `:(literal)`.
- unicode (`ünïcode-файл.md`) → `whole, 3 lines`, correct bytes under forced `LC_ALL=C`.
- rename + edit → `### renamed-new.sh, renamed from renamed-old.sh, lines 23-25 of 325`, exactly the `gamma()` function.
- mode-only change → `### modeonly.sh, whole, 2 lines` (small, so carried); a large mode-only file gives `..., N lines, no line changed: no text` (test row 16W).
- CRLF → `### crlf.txt, lines 143-261 of 401`, 119 lines × 33 bytes ≤ 4096; the `\r` is kept inside the fence, harmless.
- no trailing newline → `### notrail.txt, whole, 2 lines`, awk supplies the final newline so the closing fence stays on its own line.
- nested functions + heredoc containing `}` → the indented `inner() {` is not matched as a function (the regex is `^`-anchored, no leading whitespace), and `beta()`'s end is taken as the heredoc's column-0 `}`. Both degrade to the comment-led/window rungs; nothing wrong is claimed. See note 2 for the one reading that can mislead.
- markdown with fenced `#` lines → `### -leading-dash.md, lines 5-14 of 321` correctly spans the whole `## Section one` past the fenced `# this is a fenced comment` and `## neither is this`, and the entry is wrapped in a 4-backtick fence because the text holds a 3-backtick run.
- 1 byte over the cutoff → `### cutoff8192.txt, whole, 1 line` vs `### cutoff8193.txt, lines 1-1 of 1`. Cutoff exact.
- single line longer than 4096 → `### longline.txt, lines 101-101 of 201` carries the 5001-byte line whole. `pack_unit` is a soft cap by design (`window()` always keeps at least line L); `pack_total` still binds — the test's row 24W shows a 70000-byte single line landing on the `Not carried` line instead.
- binary → `### bin.dat, binary: no text` (NUL byte) and `### utf16.txt, binary: no text` (UTF-16), both via `--numstat`.
- symlink out of the repo → `### link-out, a symbolic link to /etc/hosts: no text`. The target is named, never read.
- submodule → `/tmp/rtv126/adv3`, gitlink added by `git update-index --cacheinfo 160000,...`: `### mysub, a submodule: no text`, exit 0.
- `linguist-generated` → `### gen.md, generated (linguist-generated): no text`.
- empty at HEAD → `### empty.txt, empty at HEAD: no text`; deleted → `### gone.txt, deleted at HEAD: no text`; large added → `### added-large.sh, added, 325 lines; the diff carries it whole: no text`.
- empty diff (`reading-pack.sh HEAD`) → `## Reading pack` and a blank line, exit 0. Sweep form (`--paths a.txt --commits HEAD`) → the one-sentence no-pack section, exit 0.

(c) Safety — the one thing to decide
- `.env` added in the diff → `### .env, whole, 2 lines` followed by `API_KEY=sk-live-supersecret-000` / `DB_PASSWORD=hunter2` inside the fence. Exit 0, no warning.
- The widening, measured (`/tmp/rtv126/sec`): a 400-line `big.env` with one changed line. `git diff HEAD~1 -- big.env` → 13 lines, 6 of them secrets. The pack → `### big.env, lines 113-289 of 400`, 177 `sk-live-` lines. So the pack shows ~30× the secret material the diff showed. A modified `secrets.pem` of 3 lines is likewise carried whole.
- Audience: `.scratch/review/<id>/{standards,spec}-brief.md`; `.scratch/` is git-ignored (`.gitignore:8`) and the briefs are never posted — `review-comment.sh` builds the PR comment from the reviewers' reports, not from the brief. So this does not by itself publish a secret. It does put the file's whole text into two reviewer subagents' contexts, and a reviewer quoting a finding could carry it into a PR comment. It also sits against `template/AGENTS.md`, "The ways to hurt yourself" 2: "Never read, print, or edit `.env*`, credential files, or production data." The pack has no path-based exclusion — only symlink, submodule, binary, `linguist-generated`.

(d) Determinism
- Two runs of the chain pack: `cmp pack-chain.md p2.md` → identical.
- `LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8` run vs the default: `cmp` → identical. The script forces `export LC_ALL=C` at line 14, and `sort -n -k1,1 -k2,2` breaks size ties on the numeric entry index, so selection and order are locale-independent.
- Three repeated runs over `/tmp/rtv126/shb` (extensionless shebang files, where detection goes through `head | tr | grep -q` under `pipefail`) gave the same two headers each time; no SIGPIPE flake observed.

(e) Composition with #125
- Round one, live, same scratch repo, same fixtures, the skill at `0edf8c8` vs at `f58308b` (both extracted outside the repo so the diff is identical): `diff` on `standards-brief.md` and `spec-brief.md` shows **additions only** — the 33-line `## Reading pack` block after `## Diff`, and the two-line `pack_rule` sentence in `## Report`. No removed or changed line. stdout identical.
- Round two (`--previous` with a `round: 1 of 3` / `act-on items:` comment): stdout identical (`round: 2 of 3`, `settled: carried 2, dropped 1 without a citation`), `<dir>/round` = 2 in both, briefs again additions-only (`diff | grep -c '^<'` → 0).
- Fix-only round three: covered by the repo's own suite, rows 1F-21F of `tests/spec-review/review-brief.sh:1570-1650` — the fix-only pack carries `pk/t.sh` whole, `pk/big.sh` `f50()` and `pk/big.md` `## Section 20` only, and `none` asserts every other row's path is absent, including `f10()` and `## Section 7` from the round-one diff. So the pack covers the fix, not the whole diff. That matches the ticket: a fix-only round's fixed point is the commit the previous round reviewed, and the pack is built from `<fixed>...HEAD`.

(f) A git failure inside the pack
- `/tmp/rtv126/breakgit.sh`: a good round first, then a PATH `git` that exits 128 on `check-attr` (used only by `reading-pack.sh`; `grep -c check-attr review-brief.sh` → 0). Result: exit 1; stderr `fatal: simulated git failure in check-attr` then `review-brief: the reading pack failed (above); nothing written`; stdout stopped after `round: 1 of 3`.
- `.claude/state/review` after: `diff -r` against the copy taken before the broken run → **STATE UNCHANGED** (`dir`, `files`, `fixed-point` byte-identical). `.scratch/review/<id>` is gone, removed by the `rm -rf "$dir"` at `review-brief.sh:352`, the same way every other refusal path (303, 329, 340) behaves.

Repo suites at the SHA
- `bash tests/spec-review/review-brief.sh` → exit 0, `ok 1294 assertions`. Its rows 1W-29F (`tests/spec-review/review-brief.sh:1496-1750`) independently cover most of slice (b) plus the two git-failure cases.

## Issues

None. Every documented path I exercised gave the documented result, and every input outside it was refused with a message or named with a reason.

## Notes

1. Secrets: `reading-pack.sh` has no path-based exclusion, so a committed `.env`, `*.pem` or credentials file in the diff is read and printed in full (≤8192 bytes) or in a 4096-byte window per change. Evidence above: 177 secret lines carried where the diff showed 6. This is a widening over `0edf8c8`, and it reads against `template/AGENTS.md` rule 2. Nothing in ticket #107 asked for an exclusion, so I do not call it a defect in the change — but it is the one thing a human should decide, and it is a clean separate ticket (a `:(exclude)` list, or the `linguist-generated` treatment applied to a secret-path glob).
2. `template/.agents/skills/spec-review/scripts/reading-pack.sh:86` ends a shell function at the first line matching `^}`, which a heredoc body's column-0 `}` satisfies. With a change *inside* such a heredoc the pack prints `### with space.sh, lines 12-15 of 325` holding `beta() {` / `cat <<'EOF'` / the heredoc line / `}` — which reads as a complete four-line function although `beta()` runs to line 21. The header's `lines 12-15 of 325` is truthful and the repo's own test asserts this cut (row 5W), so it is the agreed design; I note it only because it is the single reading in my battery where a reviewer could form a wrong belief from the fenced text alone.
3. `reading-pack.sh:85` anchors the function regex at `^`, so an indented (nested) function is never a unit. Combined with the comment-led fallback scanning to EOF when no later `#` line exists, a change inside a nested function in a comment-sparse file falls all the way to a byte window: `### with space.sh, lines 10-143 of 325`, 134 lines of which ~118 are filler. Within budget and not misleading, but the tightest rung is missed.
4. The script's header comment (line 9) says "Exits 1 ... when a git command fails"; with `set -e` it actually exits with git's own status — `reading-pack.sh nosuchrev` → exit 128. `review-brief.sh:351` tests `if ! bash ...`, so any non-zero works and nothing is broken; the comment is just imprecise.
5. Called with no argument the script dies on `line 22: $1: unbound variable` (exit 1) rather than a usage line. Only `review-brief.sh` calls it, and it always passes an argument.
6. A carried Markdown file puts its own `## ` headings into the brief inside a fence (e.g. `## Section one`, `## Use`). The briefs' structure survives because everything is fenced, and the suite's own `section()`/`around()` helpers track fences; worth remembering if anything downstream ever greps a brief for `^## `.
7. `pack_unit=4096` is a soft cap: `window()` always keeps at least the changed line, so a single line longer than 4096 bytes is carried whole (`### longline.txt, lines 101-101 of 201`, 5001 bytes). `pack_total` is the real bound and holds.
