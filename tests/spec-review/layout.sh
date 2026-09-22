# Sourced by the spec-review tests. layout <project|factory> <dir>: the spec-review skill copied
# into a new git repository at <dir>, laid out the way that repository holds it, and committed.
# A project (what `factory918 apply` leaves) has `.agents/skills/spec-review/`, `.claude/hooks/`
# with an executable hook, and `.claude/skills -> ../.agents/skills`. The factory has the same
# under `template/`, with `.claude/skills` and `.claude/hooks` linking there. Sets `skill`, the
# copy of the skill to run, and `hooks`, the hooks directory a cross-cutting commit touches.
# shellcheck shell=bash disable=SC2034 # sourced by the two spec-review tests, so it has no shebang; hooks and skill are read by the sourcing test
source_skill="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd -P)/template/.agents/skills/spec-review"
layout() {
  local base link
  case "$1" in
    project) base="$2"; hooks=.claude/hooks; link=../.agents/skills ;;
    factory) base="$2/template"; hooks=template/.claude/hooks; link=../template/.agents/skills ;;
  esac
  mkdir -p "$base/.agents/skills" "$base/.claude/hooks" "$2/.claude"
  cp -R "$source_skill" "$base/.agents/skills/spec-review"
  printf '#!/bin/sh\nexit 0\n' > "$base/.claude/hooks/noop.sh"
  chmod +x "$base/.claude/hooks/noop.sh"
  ln -s "$link" "$2/.claude/skills"
  [ "$1" = project ] || ln -s ../template/.claude/hooks "$2/.claude/hooks"
  skill="$base/.agents/skills/spec-review"
  git -C "$2" init -q
  git -C "$2" config user.email test@factory918.invalid
  git -C "$2" config user.name test
  git -C "$2" add -A
  git -C "$2" commit -qm "the layout"
}
