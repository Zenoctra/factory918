#!/usr/bin/env bash
# The Factory918 CLI. Subcommands: install | init | apply [--profile name] [--name n] | doctor | update | sync | sync-repos | labels | knowledge
# Implemented per docs/FACTORY-SPEC-v2.md §8; verified against the tool versions in docs/M0-findings.md.
set -euo pipefail
# Resolve the script's real location: ~/.local/bin/factory918 is a symlink into the clone.
self="${BASH_SOURCE[0]}"
while [ -L "$self" ]; do target="$(readlink "$self")"; case "$target" in /*) self="$target" ;; *) self="$(dirname "$self")/$target" ;; esac; done
F918_DIR="$(cd "$(dirname "$self")" && pwd -P)"
TEMPLATE="$F918_DIR/template"
VERSION="$(cat "$F918_DIR/VERSION" 2>/dev/null || echo 0.1.0)"

usage() { sed -n '2,3p' "$0"; exit 1; }
need() { command -v "$1" >/dev/null || { echo "missing: $1" >&2; exit 1; }; }

sha() { if command -v sha256sum >/dev/null; then sha256sum "$1"; else shasum -a 256 "$1"; fi | cut -d' ' -f1; }

approve_ast_grep() {
  [ -f "$1" ] || return 0
  python3 - "$1" <<'EOF'
import re, sys, pathlib
p = pathlib.Path(sys.argv[1]); t = p.read_text()
if re.search(r'^\s+"?@ast-grep/cli"?:\s*true\s*$', t, re.M):
    sys.exit(0)
line = '  "@ast-grep/cli": true'
if "allowBuilds:" in t:
    t = re.sub(r'^\s+"?@ast-grep/cli"?:.*$', line, t, count=1, flags=re.M)
    if line not in t:
        t = t.replace("allowBuilds:", "allowBuilds:\n" + line, 1)
else:
    t = t.rstrip("\n") + "\nallowBuilds:\n" + line + "\n"
p.write_text(t)
EOF
}

FACTORY_OWNED="AGENTS.md CLAUDE.md vite.config.ts .vite-hooks/pre-commit"

# Python package at python/<name>: pyproject, a package, a smoke test, the CI job, a lockfile,
# and *.py in the commit hook. A profile is additive like apply: nothing that exists is replaced.
apply_python() {
  local dir="$1" name="$2" pkg="$1/python/$2" P="$F918_DIR/profiles/python"
  need uv
  mkdir -p "$pkg/src/$name" "$pkg/tests" "$dir/.github/workflows"
  [ -s "$pkg/pyproject.toml" ] || sed "s/<name>/$name/g" "$P/pyproject.toml" > "$pkg/pyproject.toml"
  [ -s "$pkg/src/$name/__init__.py" ] || printf '"""%s."""\n' "$name" > "$pkg/src/$name/__init__.py"
  [ -s "$pkg/tests/test_smoke.py" ] || printf 'import %s\n\n\ndef test_imports() -> None:\n    assert %s.__doc__\n' "$name" "$name" > "$pkg/tests/test_smoke.py"
  [ -s "$dir/.github/workflows/python.yml" ] || sed "s/<name>/$name/g" "$P/python.yml" > "$dir/.github/workflows/python.yml"
  [ -s "$pkg/uv.lock" ] || (cd "$pkg" && uv lock -q)
  # Same thin hook for Python: the formatter only, on commit.
  if [ -f "$dir/vite.config.ts" ] && ! grep -q '"\*\.py"' "$dir/vite.config.ts"; then
    python3 - "$dir/vite.config.ts" "$name" <<'EOF'
import pathlib, re, sys
p = pathlib.Path(sys.argv[1]); t = p.read_text()
task = f'"*.py": "uv run --project python/{sys.argv[2]} ruff format",'
t = re.sub(r'(\n(\s*)"\*": "vp fmt[^\n]*\n)', lambda m: m.group(1) + m.group(2) + task + "\n", t, count=1)
p.write_text(t)
EOF
  fi
}

# Expo app files and the native-fingerprint signal. The app itself is one command the
# human or the agent runs, printed at the end, because it downloads an Expo SDK.
apply_react_native() {
  local dir="$1" P="$F918_DIR/profiles/react-native"
  mkdir -p "$dir/apps/mobile" "$dir/.github/workflows"
  [ -s "$dir/apps/mobile/eas.json" ] || cp "$P/eas.json.example" "$dir/apps/mobile/eas.json"
  [ -s "$dir/.github/workflows/mobile-fingerprint-check.yml" ] || cp "$P/mobile-fingerprint-check.yml" "$dir/.github/workflows/mobile-fingerprint-check.yml"
  [ -s "$dir/apps/mobile/package.json" ] || echo "Next: (cd $dir && npx create-expo-app@latest apps/mobile --template blank-typescript), then vp install."
}

# Per machine, once: ~/.factory918 points at this clone (the knowledge skill's fallback and
# $FACTORY918_HOME's default), and ~/.local/bin/factory918 puts the CLI on PATH.
cmd_install() {
  local home="$HOME/.factory918" bin="$HOME/.local/bin"
  for tool in git jq python3; do command -v "$tool" >/dev/null || echo "missing: $tool (install it with your package manager; the CLI needs git, jq and python3)"; done
  if [ -e "$home" ] && [ "$(cd "$home" && pwd -P)" != "$(cd "$F918_DIR" && pwd -P)" ]; then
    echo "$home already points elsewhere: $(readlink "$home" || echo "$home"). Move it aside or set FACTORY918_HOME." >&2; exit 1
  fi
  [ -e "$home" ] || ln -s "$F918_DIR" "$home"
  mkdir -p "$bin"; ln -sf "$F918_DIR/factory918.sh" "$bin/factory918"
  echo "installed: $home -> $F918_DIR"
  echo "installed: $bin/factory918"
  case ":$PATH:" in *":$bin:"*) ;; *) echo "add to your shell rc: export PATH=\"\$HOME/.local/bin:\$PATH\"" ;; esac
  # The one user-level write the factory makes (spec §5.5): pstack's role sheet, from machine/.
  if [ ! -f "$HOME/.claude/pstack-models.md" ]; then
    mkdir -p "$HOME/.claude"; cp "$F918_DIR/machine/pstack-models.md" "$HOME/.claude/pstack-models.md"; echo "installed: ~/.claude/pstack-models.md"
  fi
  grep -qx '@~/.claude/pstack-models.md' "$HOME/.claude/CLAUDE.md" 2>/dev/null || { printf '@~/.claude/pstack-models.md\n' >> "$HOME/.claude/CLAUDE.md"; echo "installed: include line in ~/.claude/CLAUDE.md"; }
  command -v vp >/dev/null || echo "next: install Vite+ with  curl -fsSL https://vite.plus -o /tmp/vp.sh && VP_VERSION=0.3.1 VP_NODE_MANAGER=yes bash /tmp/vp.sh"
  command -v gh >/dev/null && gh auth status >/dev/null 2>&1 || echo "next: gh auth login"
}

cmd_apply() {
  local dir="${1:-.}"; need jq; need python3
  shift || true
  local profile="" scaffold="" name=""
  while [ $# -gt 0 ]; do case "$1" in
    --profile) profile="$2"; shift 2 ;;
    --name) name="$2"; shift 2 ;;
    --scaffold) scaffold=1; shift ;;
    *) shift ;;
  esac; done
  mkdir -p "$dir/.factory918"
  local manifest="$dir/.factory918/manifest.json"
  [ -f "$manifest" ] || echo '{"version":"'"$VERSION"'","files":{},"profiles":[]}' > "$manifest"
  printf '{"factory":"%s"}\n' "$(cd "$F918_DIR" && pwd -P)" > "$dir/.factory918/local.json"   # git-ignored; the clone that applied
  if [ -n "$profile" ]; then
    case "$profile" in
      python) apply_python "$dir" "${name:-$(basename "$(cd "$dir" && pwd)")}" ;;
      react-native) apply_react_native "$dir" ;;
      *) echo "unknown profile: $profile (python | react-native)" >&2; exit 1 ;;
    esac
    tmp="$(mktemp)"; jq --arg p "$profile" '.profiles = ((.profiles // []) + [$p] | unique)' "$manifest" > "$tmp" && mv "$tmp" "$manifest"
  fi
  # Copy every managed file that does not exist locally; record its hash. Never overwrite an existing file here.
  (cd "$TEMPLATE" && find . -type f ! -name '.gitkeep' -print0) | while IFS= read -r -d '' rel; do
    rel="${rel#./}"
    case "$rel" in package.scripts.json|.gitignore.factory) continue ;; esac
    owned=""
    [ -n "$scaffold" ] && case " $FACTORY_OWNED " in *" $rel "*) owned=1 ;; esac
    if [ ! -e "$dir/$rel" ] || [ -n "$owned" ]; then
      mkdir -p "$dir/$(dirname "$rel")"; cp -p "$TEMPLATE/$rel" "$dir/$rel"
    fi
    h="$(sha "$TEMPLATE/$rel")"
    tmp="$(mktemp)"; jq --arg k "$rel" --arg v "$h" '.files[$k]={"template":$v}' "$manifest" > "$tmp" && mv "$tmp" "$manifest"
  done
  # Symlink .claude/skills -> ../.agents/skills (T3 Code's pattern).
  mkdir -p "$dir/.claude"; [ -e "$dir/.claude/skills" ] || ln -s ../.agents/skills "$dir/.claude/skills"
  # Append gitignore entries once.
  grep -q '^\.artifacts/' "$dir/.gitignore" 2>/dev/null || cat "$TEMPLATE/.gitignore.factory" >> "$dir/.gitignore"
  # Merge scripts, engines and devDependencies; the project's own values win.
  if [ -f "$dir/package.json" ]; then
    tmp="$(mktemp)"
    jq -s '.[0] as $t | .[1]
           | .scripts = (($t.scripts // {}) + (.scripts // {}))
           | .engines = (($t.engines // {}) + (.engines // {}))
           | .devDependencies = (($t.devDependencies // {}) + (.devDependencies // {}))' \
      "$TEMPLATE/package.scripts.json" "$dir/package.json" > "$tmp" && mv "$tmp" "$dir/package.json"
  fi
  chmod +x "$dir"/.claude/hooks/*.sh "$dir/.vite-hooks/pre-commit" 2>/dev/null || true
  # pnpm gates the native binary @ast-grep/cli builds; approve it once so nobody is
  # asked at install time. In a workspace the key lives in pnpm-workspace.yaml.
  approve_ast_grep "$dir/pnpm-workspace.yaml"
  # Install first: the lint plugin and the rule engine are devDependencies, and the
  # gates report missing tooling as failure. Then format, because vp check stops at
  # the first stage and an unformatted file would hide every lint and type error.
  (cd "$dir" && vp install >/dev/null 2>&1) || true
  (cd "$dir" && vp fmt >/dev/null 2>&1) || true
  cmd_doctor "$dir" || true
}

cmd_init() {
  local dir="$1"; shift; local template="vite:monorepo" github=1
  while [ $# -gt 0 ]; do case "$1" in --no-github) github=""; shift ;; vite:*) template="$1"; shift ;; *) shift ;; esac; done
  need vp; [ -z "$github" ] || need gh
  vp create "$template" --directory "$dir" --no-interactive --git --hooks --no-agent
  git -C "$dir" branch -M main   # vp create uses the machine default; CI, the guard and protection assume main
  cmd_apply "$dir" --scaffold
  if [ -n "$github" ]; then
    (cd "$dir" && gh repo create --source=. --private --push) || echo "skipped gh repo create"
    cmd_labels "$dir"
  fi
  echo "Next: open Claude Code in $dir and run /factory-start. Human-only steps such as secrets: /wizard writes the script."
}

# Each FAIL line carries its fix, so an agent reading the table can guide a person who has
# never seen this system. PASS needs nothing; NOTE is optional.
cmd_doctor() {
  local dir="${1:-.}"; local fail=0
  chk() { if eval "$2" >/dev/null 2>&1; then echo "PASS  $1"; else echo "FAIL  $1"; echo "      fix: $3"; fail=1; fi; }
  cd "$dir"
  if [ ! -f .factory918/manifest.json ]; then
    echo "FAIL  this directory is not a Factory918 project"
    echo "      fix: factory918 init <new-dir> to create one, or factory918 apply here to add Factory918 to an existing repo"
    return 1
  fi
  chk "factory files reachable"       "[ -d \"$TEMPLATE\" ] && [ -d \"$F918_DIR/profiles\" ]" "the factory918 command does not resolve to a clone (template/ missing beside it); run ./factory918.sh install from the clone"
  chk "factory918 installed"          "command -v factory918 && [ -d \"\${FACTORY918_HOME:-\$HOME/.factory918}/docs/knowledge\" ]" "in the factory918 clone run ./factory918.sh install, add ~/.local/bin to PATH, open a new terminal"
  chk "one factory on this machine"   "[ ! -e \"\$HOME/.factory918\" ] || [ \"\$(cd \"\$HOME/.factory918\" && pwd -P)\" = \"\$(cd \"\$(dirname \"\$(readlink \"\$(command -v factory918)\")\")\" && pwd -P)\" ]" "~/.factory918 and ~/.local/bin/factory918 point at different clones; run ./factory918.sh install from the one you want"
  chk "vp matches the ADR pin"        "[ \"\$(vp --version | head -1 | sed 's/^vp v//')\" = \"\$(sed -n 's/.*vite-plus \\([0-9][0-9.]*\\).*/\\1/p' docs/adr/0001-toolchain.md | head -1)\" ]" "docs/adr/0001-toolchain.md pins a different vite-plus than vp --version reports; update the ADR or run the Vite+ installer with VP_VERSION=<pin>"
  chk "vp on PATH"                    "command -v vp" "curl -fsSL https://vite.plus -o /tmp/vp.sh && VP_VERSION=0.3.1 VP_NODE_MANAGER=yes bash /tmp/vp.sh, then open a new terminal"
  chk "vp env doctor"                 "vp env doctor" "run vp env doctor and follow its output"
  chk "hooks installed"               "vp hooks status | grep -qi 'hooksPath'" "vp hooks enable (no .git means this is not a repository yet: git init first)"
  chk ".claude/skills symlink"        "[ \"\$(readlink .claude/skills)\" = ../.agents/skills ]" "rm -rf .claude/skills && ln -s ../.agents/skills .claude/skills"
  chk "every skill has a name"        "! grep -L '^name:' .agents/skills/*/SKILL.md | grep ." "factory918 update restores the vendored skills; a skill you wrote needs a name: line in its frontmatter"
  chk "no duplicate skill names"      "[ -z \"\$(grep -h '^name:' .agents/skills/*/SKILL.md | sort | uniq -d)\" ]" "rename or remove one of the two skills that share a name (grep -h ^name: .agents/skills/*/SKILL.md | sort | uniq -d)"
  chk "gh authenticated"              "gh auth status" "gh auth login (install gh first: brew, apt, dnf or winget)"
  chk "labels present"                "gh label list --limit 200 | grep -q ready-for-agent" "factory918 labels (needs a GitHub remote; factory918 init creates one, or gh repo create --private --source=. --push)"
  chk "ci workflow present"           "[ -f .github/workflows/ci.yml ]" "factory918 update restores it"
  chk "settings.json parses"          "jq . .claude/settings.json" "fix the JSON in .claude/settings.json, or factory918 update to restore the template copy"
  chk "hooks executable"              "[ -x .claude/hooks/mode.sh ] && [ -x .claude/hooks/block-dangerous-git.sh ]" "chmod +x .claude/hooks/*.sh"
  chk "state dir ignored"             "git check-ignore -q .claude/state/mode" "append the lines from the factory clone's template/.gitignore.factory to .gitignore"
  chk "vp check (format, lint, types)" "vp check" "vp fmt, then vp check, and fix what it reports; it stops at the first failing stage"
  chk "tests"                         "vp test run" "vp test run and read the failing test"
  [ -f "$HOME/.claude/pstack-models.md" ] && echo "PASS  models sheet" || echo "NOTE  models sheet"; echo "      fix: factory918 install writes ~/.claude/pstack-models.md"
  chk "AGENTS.md is Factory918's"     "grep -q 'factory918' AGENTS.md" "factory918 apply --scaffold replaces the AGENTS.md that vp create wrote"
  chk "slots filled (/factory-start)" "! grep -q '<[A-Za-z].*slot\|<Project name>\|<One paragraph' AGENTS.md" "open Claude Code here and run /factory-start, the Day-0 interview; it fills every <slot>"
  chk "slim knowledge present"        "[ -f docs/factory918/PHILOSOPHY.md ] && [ -f docs/factory918/MANUAL.md ]" "factory918 update restores docs/factory918/"
  chk "glue skills resolve"           "[ -f .agents/skills/factory918/SKILL.md ] && [ -f .agents/skills/factory-start/SKILL.md ] && [ -f .agents/skills/knowledge/SKILL.md ]" "factory918 update restores the factory918, factory-start and knowledge skills"
  chk "ledger exists"                 "[ -f docs/agents/ledger.md ]" "factory918 update restores docs/agents/ledger.md"
  chk "ast-grep rules test"           "pnpm sg:test" "vp install (the rule engine is a devDependency), then pnpm sg:test; a rule without a snapshot needs ast-grep test --update-all"
  [ "$fail" = 0 ] && echo "all clear" || echo "start with the first FAIL"
  return $fail
}

cmd_labels() {
  local dir="${1:-.}"; need gh; need jq
  jq -c '.[]' "$TEMPLATE/.github/labels.json" | while read -r l; do
    gh label create "$(jq -r .name <<<"$l")" --color "$(jq -r .color <<<"$l")" --description "$(jq -r .description <<<"$l")" --force -R "$(cd "$dir" && gh repo view --json nameWithOwner -q .nameWithOwner)"
  done
}

# Three-way merge per docs/FACTORY-SPEC-v2.md §8.2. For each managed path: O is the template
# file at the version the project recorded (a git tag in this repo), N the template now, L the
# project's file. Conflicts land beside the file as <file>.factory-merge; L is left alone.
cmd_update() {
  local dir="${1:-.}"; need jq; need git
  local manifest="$dir/.factory918/manifest.json"
  [ -f "$manifest" ] || { echo "no $manifest: run factory918 apply first" >&2; exit 1; }
  need python3
  local recorded; recorded="$(jq -r '.factory // ""' "$dir/.factory918/local.json" 2>/dev/null)"
  if [ -n "$recorded" ] && [ "$recorded" != "$(cd "$F918_DIR" && pwd -P)" ]; then
    echo "warning: this project was applied from $recorded; updating from $(cd "$F918_DIR" && pwd -P). Merge bases come from this clone's tags." >&2
  fi
  python3 - "$F918_DIR" "$TEMPLATE" "$dir" "$manifest" "$VERSION" <<'EOF'
import hashlib, json, pathlib, subprocess, sys
f918, template, project, manifest_path, new_version = sys.argv[1:6]
template, project = pathlib.Path(template), pathlib.Path(project)
manifest = json.loads(pathlib.Path(manifest_path).read_text())
old_version, files = manifest["version"], manifest["files"]
sha = lambda b: hashlib.sha256(b).hexdigest()

def old_template(rel):
    r = subprocess.run(["git", "-C", f918, "show", f"v{old_version}:template/{rel}"], capture_output=True)
    return r.stdout if r.returncode == 0 else None

skip = {"package.scripts.json", ".gitignore.factory"}
new = {p.relative_to(template).as_posix(): p for p in template.rglob("*") if p.is_file() and p.name != ".gitkeep"}
report = {"added": [], "updated": [], "kept": [], "merged": [], "conflicts": [], "deleted": [], "unchanged": []}
for rel in sorted(set(new) | set(files)):
    if rel in skip:
        continue
    entry, N, L = files.get(rel), new.get(rel), project / rel
    n_bytes = N.read_bytes() if N else None
    if entry is None:                                  # new in the template
        if L.exists() and L.read_bytes() != n_bytes:
            (project / (rel + ".factory-merge")).write_bytes(n_bytes); report["conflicts"].append(rel)
        else:
            L.parent.mkdir(parents=True, exist_ok=True); L.write_bytes(n_bytes); report["added"].append(rel)
        files[rel] = {"template": sha(n_bytes), "state": "added"}
        continue
    if entry.get("state") == "deleted":
        continue
    if not L.exists():                                 # deleted locally on purpose; never re-add
        entry["state"] = "deleted"; report["deleted"].append(rel); continue
    if N is None:                                      # gone from the template; the project keeps it
        report["kept"].append(rel); continue
    l_bytes, recorded = L.read_bytes(), entry["template"]
    if sha(n_bytes) == recorded:
        report["unchanged"].append(rel); continue
    if sha(l_bytes) == recorded:                       # untouched locally: take the new template
        L.write_bytes(n_bytes); entry["template"] = sha(n_bytes); report["updated"].append(rel); continue
    O = old_template(rel)                              # both changed: merge on the recorded base
    if O is None or sha(O) != recorded:
        (project / (rel + ".factory-merge")).write_bytes(n_bytes); report["conflicts"].append(rel + " (no base at v" + old_version + ")")
        entry["template"] = sha(n_bytes); continue
    base = project / (rel + ".factory-base"); base.write_bytes(O)
    r = subprocess.run(["git", "merge-file", "-p", "-L", "project", "-L", f"template v{old_version}", "-L", f"template v{new_version}", str(L), str(base), str(N)], capture_output=True)
    base.unlink()
    if r.returncode == 0:
        L.write_bytes(r.stdout); report["merged"].append(rel)
    else:
        (project / (rel + ".factory-merge")).write_bytes(r.stdout); report["conflicts"].append(rel)
    entry["template"] = sha(n_bytes)
manifest["version"] = new_version
pathlib.Path(manifest_path).write_text(json.dumps(manifest, indent=2) + "\n")
for k in ("added", "updated", "merged", "kept", "deleted", "conflicts"):
    for rel in report[k]:
        print(f"{k:9s} {rel}")
print(f"template {old_version} -> {new_version}: {len(report['unchanged'])} unchanged. "
      f"{len(report['conflicts'])} to resolve by hand (*.factory-merge)." if report["conflicts"] else
      f"template {old_version} -> {new_version}: {len(report['unchanged'])} unchanged.")
EOF
  cmd_doctor "$dir" || true
}

# Rebuild template/.agents/skills from the pinned copies under research/ and re-apply
# patches/series. Vendoring never touches the network: update the pins in research/ first.
# Our own skills and playbooks stay; VERSION is bumped by hand in the commit that lands this.
cmd_sync() {
  need git
  local skills="$TEMPLATE/.agents/skills"
  local pstack="$F918_DIR/research/3-pstack/open-pstack-claude-code-port/plugins/pstack"
  local matt="$F918_DIR/research/1-matt-pocock/skills-repo/skills"
  local ours="factory918 factory-start knowledge mode-plan mode-build factory-doctor"
  local keep_files="poteto-mode/playbooks/ticket.md"
  local tmp; tmp="$(mktemp -d)"
  for k in $keep_files; do mkdir -p "$tmp/keep/$(dirname "$k")"; cp "$skills/$k" "$tmp/keep/$k"; done
  for d in "$pstack"/skills/*/; do n="$(basename "$d")"; [ "$n" = no-comments ] && continue; rm -rf "$skills/$n"; cp -R "$d" "$skills/$n"; done
  for n in grilling grill-me grill-with-docs domain-modeling to-spec to-tickets wayfinder research prototype setup-matt-pocock-skills writing-for-agents wizard wait-what; do
    src="$(find "$matt" -maxdepth 2 -type d -name "$n" | head -1)"; rm -rf "$skills/$n"; cp -R "$src" "$skills/$n"; done
  rm -rf "$skills/spec-review"; cp -R "$matt/engineering/code-review" "$skills/spec-review"
  for k in $keep_files; do cp "$tmp/keep/$k" "$skills/$k"; done
  rm -rf "$TEMPLATE/.claude/agents"; mkdir -p "$TEMPLATE/.claude/agents"; cp "$pstack"/agents/*.md "$TEMPLATE/.claude/agents/"; rm -f "$TEMPLATE/.claude/agents/comment-sicko.md"
  local failed=0
  while read -r p; do
    [ -n "$p" ] || continue
    if git -C "$skills" apply --check "$F918_DIR/patches/$p" 2>/dev/null; then git -C "$skills" apply "$F918_DIR/patches/$p"; echo "applied  $p"
    else echo "FAILED   $p (upstream moved; rewrite the patch)"; failed=1; fi
  done < "$F918_DIR/patches/series"
  rm -rf "$tmp"
  for n in $ours; do [ -f "$skills/$n/SKILL.md" ] || { echo "missing our skill: $n" >&2; failed=1; }; done
  echo "vendored: $(ls -d "$skills"/*/ | wc -l | tr -d ' ') skills. Review with git status, bump VERSION, commit."
  return $failed
}

cmd_sync_repos() {
  local dir="${1:-.}"; need jq
  jq -c '.[]' "$dir/.repos/sources.json" | while read -r s; do
    name="$(jq -r .name <<<"$s")"; url="$(jq -r .url <<<"$s")"; ref="$(jq -r '.ref // "HEAD"' <<<"$s")"
    if [ -d "$dir/.repos/$name/.git" ]; then git -C "$dir/.repos/$name" fetch -q --depth 1 origin "$ref" && git -C "$dir/.repos/$name" checkout -q FETCH_HEAD
    else git clone -q --depth 1 --branch "$ref" "$url" "$dir/.repos/$name" 2>/dev/null || git clone -q --depth 1 "$url" "$dir/.repos/$name"; fi
  done
}

case "${1:-}" in
  install) cmd_install ;;
  init) shift; cmd_init "$@" ;;
  apply) shift; cmd_apply "$@" ;;
  doctor) shift; cmd_doctor "$@" ;;
  update) shift; cmd_update "$@" ;;
  sync) shift; cmd_sync "$@" ;;
  sync-repos) shift; cmd_sync_repos "$@" ;;
  labels) shift; cmd_labels "$@" ;;
  knowledge) python3 "$F918_DIR/tools/build_knowledge.py" ;;
  *) usage ;;
esac
