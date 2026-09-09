#!/usr/bin/env bash
# DRAFT skeleton of the Factory918 CLI. Subcommands: init | apply [--profile name] | doctor | update | sync | sync-repos | labels | knowledge
# Implemented per docs/FACTORY-SPEC-v2.md §8. Marked TODO where the implementing model must write the logic.
set -euo pipefail
F918_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE="$F918_DIR/template"
VERSION="$(cat "$F918_DIR/VERSION" 2>/dev/null || echo 0.1.0)"

usage() { sed -n '2,3p' "$0"; exit 1; }
need() { command -v "$1" >/dev/null || { echo "missing: $1" >&2; exit 1; }; }

sha() { sha256sum "$1" | cut -d' ' -f1; }

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

cmd_apply() {
  local dir="${1:-.}"; need jq
  shift || true
  local profile="" scaffold=""
  while [ $# -gt 0 ]; do case "$1" in
    --profile) profile="$2"; shift 2 ;;
    --scaffold) scaffold=1; shift ;;
    *) shift ;;
  esac; done
  if [ -n "$profile" ]; then
    [ -d "$F918_DIR/profiles/$profile" ] || { echo "unknown profile: $profile" >&2; exit 1; }
    echo "TODO: copy $F918_DIR/profiles/$profile files into $dir (python.yml -> .github/workflows/, pyproject.toml -> python/<name>/, fingerprint workflow -> .github/workflows/, eas.json.example -> apps/mobile/eas.json) and record the profile in .factory918/manifest.json"
  fi
  mkdir -p "$dir/.factory918"
  local manifest="$dir/.factory918/manifest.json"
  [ -f "$manifest" ] || echo '{"version":"'"$VERSION"'","files":{}}' > "$manifest"
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
  local dir="$1"; shift; local template="${1:-vite:application}"
  need vp; need gh
  vp create "$template" --directory "$dir" --no-interactive --git --hooks --no-agent
  cmd_apply "$dir" --scaffold
  (cd "$dir" && gh repo create --source=. --private --push) || echo "skipped gh repo create"
  cmd_labels "$dir"
  echo "Human-only steps: branch protection on main (require Check + Test), secrets. Generate a wizard with /wizard."
}

cmd_doctor() {
  local dir="${1:-.}"; local fail=0
  chk() { if eval "$2" >/dev/null 2>&1; then echo "PASS  $1"; else echo "FAIL  $1"; fail=1; fi; }
  cd "$dir"
  chk "vp on PATH"                    "command -v vp"
  chk "hooks installed"               "vp hooks status | grep -qi 'hooksPath'"
  chk ".claude/skills symlink"        "[ \"\$(readlink .claude/skills)\" = ../.agents/skills ]"
  chk "every skill has a name"        "! grep -L '^name:' .agents/skills/*/SKILL.md | grep ."
  chk "no duplicate skill names"      "[ -z \"\$(grep -h '^name:' .agents/skills/*/SKILL.md | sort | uniq -d)\" ]"
  chk "gh authenticated"              "gh auth status"
  chk "labels present"                "gh label list --limit 200 | grep -q ready-for-agent"
  chk "ci workflow present"           "[ -f .github/workflows/ci.yml ]"
  chk "settings.json parses"          "jq . .claude/settings.json"
  chk "hooks executable"              "[ -x .claude/hooks/mode.sh ] && [ -x .claude/hooks/block-dangerous-git.sh ]"
  chk "state dir ignored"             "git check-ignore -q .claude/state/mode"
  chk "vp check (format, lint, types)" "vp check"
  chk "tests"                         "vp test run"
  chk "models sheet"                  "[ -f \"\$HOME/.claude/pstack-models.md\" ]"
  chk "AGENTS.md is Factory918's"     "grep -q 'factory918' AGENTS.md"
  chk "slots filled (/factory-start)" "! grep -q '<[A-Za-z].*slot\|<Project name>\|<One paragraph' AGENTS.md"
  chk "slim knowledge present"        "[ -f docs/factory918/PHILOSOPHY.md ] && [ -f docs/factory918/MANUAL.md ]"
  chk "glue skills resolve"           "[ -f .agents/skills/factory918/SKILL.md ] && [ -f .agents/skills/factory-start/SKILL.md ] && [ -f .agents/skills/knowledge/SKILL.md ]"
  chk "ledger exists"                 "[ -f docs/agents/ledger.md ]"
  chk "ast-grep rules test"           "pnpm sg:test"
  return $fail
}

cmd_labels() {
  local dir="${1:-.}"; need gh; need jq
  jq -c '.[]' "$TEMPLATE/.github/labels.json" | while read -r l; do
    gh label create "$(jq -r .name <<<"$l")" --color "$(jq -r .color <<<"$l")" --description "$(jq -r .description <<<"$l")" --force -R "$(cd "$dir" && gh repo view --json nameWithOwner -q .nameWithOwner)"
  done
}

cmd_update() {
  # Three-way merge per docs/FACTORY-SPEC-v2.md §8.2. TODO: implement with `git merge-file -p L O N`.
  # Needs: the project's recorded template version (manifest), the template at that version (git tag in this repo), the new template.
  echo "TODO: factory918 update (see docs/FACTORY-SPEC-v2.md §8.2)"; exit 2
}

cmd_sync() {
  # Re-vendor upstream skills from SOURCES.md pins, re-apply patches/, bump VERSION. TODO.
  echo "TODO: factory918 sync (see docs/FACTORY-SPEC-v2.md §8.1 and SOURCES.md)"; exit 2
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
