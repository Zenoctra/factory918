#!/usr/bin/env bash
# spec-review step 1. Runs the diff once, writes the review state the delegation hook reads, and
# assembles the two reviewer briefs, so the orchestrator hands each lane a file and reads no code.
#   review-brief.sh <fixed-point> [--ticket N] [--standards FILE ...] [--previous FILE] [--round N] [--blast-radius FILE]
#   review-brief.sh --paths P... --commits SHA... [--ticket N] [--standards FILE ...] [--blast-radius FILE]
# The second form is the sweep over units already on main: the fixed point is the word "paths"
# and the diff is git show <commits> -- <paths>. Rerunning overwrites the previous state.
# The PR comments that end a review carry a line `act-on items:` under `round: N of 3`; the round
# is the highest N plus one (a comment without the line is round 1), so a comment rebuilt in the
# same round does not advance it, and a fourth round is refused. From every such comment, in order,
# the judgment's Noted and Dismissed items that cite a decision are carried into both briefs as
# settled, each line once; --previous FILE supplies the comments instead of gh, and --round N the
# round, for tests and a branch whose PR is elsewhere.
# A cross-cutting diff (one that touches a hooks directory, a settings.json or the factory918
# skill) is briefed only with its blast-radius grounding: --blast-radius FILE, else the PR body's
# `## Blast Radius` section; without one the script refuses before writing any state.
# shellcheck disable=SC2016 # every single-quoted string here is a jq program or a Markdown template; the backticks and $ are literal
set -euo pipefail
usage() {
  echo "usage: review-brief.sh <fixed-point> [--ticket N] [--standards FILE ...] [--previous FILE] [--round N] [--blast-radius FILE]" >&2
  echo "       review-brief.sh --paths P... --commits SHA... [--ticket N] [--standards FILE ...] [--blast-radius FILE]" >&2
  exit 1
}
skill="$(cd "$(dirname "$0")/.." && pwd -P)"
root="$(git rev-parse --show-toplevel)"
cd "$root"
fixed="" ticket="" list="" previous="" round="" blast=""
paths=() commits=() standards=()
while [ $# -gt 0 ]; do
  case "$1" in
    --ticket) ticket="${2:-}"; [ -n "$ticket" ] || usage; list=""; shift ;;
    --previous) previous="${2:-}"; [ -f "$previous" ] || usage; list=""; shift ;;
    --round) round="${2:-}"; [ "$round" -gt 0 ] 2>/dev/null || usage; list=""; shift ;;
    --blast-radius) blast="${2:-}"; [ -f "$blast" ] || usage; list=""; shift ;;
    --standards) list=standards ;;
    --paths) list=paths ;;
    --commits) list=commits ;;
    -*) usage ;;
    *) case "$list" in
         standards) standards+=("$1") ;;
         paths) paths+=("$1") ;;
         commits) commits+=("$1") ;;
         *) [ -z "$fixed" ] || usage; fixed="$1" ;;
       esac ;;
  esac
  shift
done
if [ ${#paths[@]} -gt 0 ]; then
  [ ${#commits[@]} -gt 0 ] && [ -z "$fixed" ] || usage
  for c in "${commits[@]}"; do
    git rev-parse --verify -q "$c^{commit}" >/dev/null || { echo "review-brief: $c does not resolve to a commit" >&2; exit 1; }
  done
  fixed=paths
  id="sweep-$(git rev-parse --short "${commits[0]}")"
else
  [ -n "$fixed" ] || usage
  git rev-parse --verify -q "$fixed^{commit}" >/dev/null || { echo "review-brief: $fixed does not resolve to a commit" >&2; exit 1; }
  id="$(printf '%s' "$fixed" | tr -c 'A-Za-z0-9._-' '_')"
fi
# The smell baseline is SKILL.md step 3's bullets, each with its fix arrow; a resync that moves
# them must fail here, before any state is written, not leave a brief with no baseline.
smells="$(sed -n '/^### 3\./,/^### 4\./p' "$skill/SKILL.md" | grep '^- \*\*.*→' || true)"
if [ -z "$smells" ]; then
  echo "review-brief: no smell baseline found in $skill/SKILL.md (no line matching '^- **...→' between '### 3.' and '### 4.'); nothing written" >&2
  exit 1
fi
# The spec is the ticket body: --ticket, or the one #N the commit messages name, oldest first.
# Never the author's own words (SKILL.md step 2). Two numbers is a question for the caller.
if [ "$fixed" = paths ]; then
  messages="$(git log --format=%B --no-walk --reverse "${commits[@]}")"
else
  messages="$(git log --reverse "$fixed..HEAD" --format=%B)"
fi
numbers="$(printf '%s\n' "$messages" | grep -oE '#[0-9]+' | awk '!seen[$0]++' | tr '\n' ' ' || true)"
if [ -z "$ticket" ]; then
  case "$numbers" in
    "") ;;
    *" "*" "*) echo "review-brief: the commits name more than one ticket (${numbers% }); pass --ticket N to choose; nothing written" >&2; exit 1 ;;
    *) ticket="${numbers%% *}"; ticket="${ticket#\#}" ;;
  esac
fi
# The earlier review comments come from the branch's PR: the comments by the PR's author (the
# account the orchestrator posts under) that carry a line `act-on items:`. A comment by anyone
# else is a stranger's text and neither counts a round nor reaches the briefs, whatever it holds.
# gh prints each body followed by a line holding only the record separator (US-ASCII 30), which
# is how the parse below tells one comment from the next. gh's "no pull requests found" is round 1
# with nothing carried and says nothing; any other failure is printed, since the round gate and
# the carry rest on it, and the run goes on the same way.
rs="$(printf '\036')"
bodies=""
if [ -n "$previous" ]; then
  bodies="$(cat "$previous")"
else
  ended='.author.login as $a | [.comments[] | select(.author.login == $a and (.body | test("(^|\n)act-on items:")))] | .[] | .body, "\u001e"'
  out="$(mktemp)"
  status=0
  err="$(gh pr view --json author,comments -q "$ended" 2>&1 >"$out")" || status=$?
  if [ "$status" -eq 0 ]; then
    bodies="$(cat "$out")"
  else
    case "$err" in
      *"no pull requests found"*) ;;
      *) echo "review-brief: gh could not read the PR's review comments ($(printf '%s' "$err" | tr '\n' ' ')); round 1 unless --round says otherwise, nothing carried" >&2 ;;
    esac
  fi
  rm -f "$out"
fi
# Each line loses its CR and trailing spaces or tabs first, so a comment posted from the web UI
# parses like one posted by gh and the `cites:` anchor below holds; the separator line ends a
# comment and resets the parse. The fence rule is the one review-comment.sh parses the reports
# with, copied from there word for word (tests/spec-review/review-brief.sh holds the two copies
# together): a fence opens on a line starting with three or more backticks or tildes and closes
# only on a line of the same character, at least as long, followed by nothing but spaces or tabs
# (no info string), so a hunk that quotes a fence stays inside its block; a heading's name is the
# text after `## ` less trailing whitespace.
split='
  { sub(/\r$/, ""); sub(/[ \t]+$/, "") }
  $0 == sep { fence = ""; h = ""; j = 0; if (r > top) top = r; r = 1; next }
'
fenced='
  /^(```|~~~)/ { match($0, /^(`+|~+)/); m = substr($0, 1, RLENGTH); rest = substr($0, RLENGTH + 1)
    if (fence == "") { fence = m; next }
    if (substr(m, 1, 1) == substr(fence, 1, 1) && length(m) >= length(fence) && rest ~ /^[ \t\r]*$/) { fence = ""; next } }
  fence != "" { next }
  /^## / { h = substr($0, 4); sub(/[ \t\r]+$/, "", h) }
'
# The round is one more than the highest `round: N of 3` line any comment carries, the last such
# line in a comment being its own (a quoted hunk may hold one earlier); a comment without the line
# is from before the line existed and is round 1. A comment rebuilt in the same round repeats its
# N, so it advances nothing.
top=0
if [ -n "$bodies" ]; then
  top="$(printf '%s\n' "$bodies" | awk -v sep="$rs" "$split$fenced"'
    BEGIN { r = 1 }
    /^round: [0-9]+ of 3$/ { r = substr($0, 8) + 0 }
    END { if (r > top) top = r; print top }
  ')"
fi
[ -n "$round" ] || round=$((top + 1))
if [ "$round" -gt 3 ]; then
  echo "review-brief: three rounds were run on this PR; the remaining Act on items are fixed here and marked \`fixed: <sha>\`, not reviewed in a fourth round" >&2
  exit 1
fi
[ -z "$ticket" ] || echo "ticket: #$ticket"
echo "round: $round of 3"
# What carries: from every comment, in order, the judgment's Noted and Dismissed items whose
# trailing field names a decision in one of the three shapes, each distinct line once, so a
# decision from round one still reaches round three and a rebuilt comment repeats nothing. An
# item without a citation is dropped, since a reason alone can steer a reviewer. The quoted hunks
# are fenced text and never items.
cites='cites: (user: "[^"]+" on #[0-9]+|DECISIONS\.md [A-Z]?[0-9]+|#[0-9]+ comment [0-9]{4}-[0-9]{2}-[0-9]{2})$'
settled=""
if [ -n "$bodies" ]; then
  judged="$(printf '%s\n' "$bodies" | awk -v sep="$rs" "$split$fenced"'
    /^## / { if (h == "Judgment") j = 1; next }
    j && (h == "Noted" || h == "Dismissed") && /^[0-9]+\. / && !seen[$0]++
  ')"
  settled="$(printf '%s\n' "$judged" | grep -E -- "$cites" || true)"
  carried="$(printf '%s' "$settled" | grep -c . || true)"
  echo "settled: carried $carried, dropped $(( $(printf '%s' "$judged" | grep -c . || true) - carried )) without a citation"
fi
dir=".scratch/review/$id"
rm -rf "$dir"
mkdir -p "$dir"
if [ "$fixed" = paths ]; then
  git show --format='commit %h %s' "${commits[@]}" -- "${paths[@]}" > "$dir/diff"
  git show --stat --format='%h %s' "${commits[@]}" -- "${paths[@]}" > "$dir/stat"
  git log --oneline --no-walk "${commits[@]}" > "$dir/log"
  git show --name-only --format= "${commits[@]}" -- "${paths[@]}" | sed '/^$/d' | sort -u > "$dir/files"
else
  git diff "$fixed...HEAD" > "$dir/diff"
  git diff "$fixed...HEAD" --stat > "$dir/stat"
  git log "$fixed..HEAD" --oneline > "$dir/log"
  git diff "$fixed...HEAD" --name-only > "$dir/files"
fi
if [ ! -s "$dir/diff" ]; then
  rm -rf "$dir"
  echo "review-brief: the diff is empty; nothing to review since $fixed" >&2
  exit 1
fi
# A cross-cutting path reaches every session and skill, so its diff alone cannot show the review
# what it breaks: the brief also carries the author's blast-radius grounding (the blast-radius
# skill's hand-back), from --blast-radius FILE or the PR body's `## Blast Radius` section, and is
# refused without one. This is the one place the predicate lives; the Ticket playbook says it in
# words. The leading `*` covers a project's own `.claude/hooks/` and the factory's `template/` copy.
crossing=""
while read -r p; do
  case "$p" in
    *.claude/hooks/*|*.claude/settings.json|*.agents/skills/factory918/*) crossing="$crossing $p" ;;
  esac
done < "$dir/files"
grounding=""
if [ -n "$crossing" ]; then
  if [ -n "$blast" ]; then
    grounding="$(cat "$blast")"
  else
    grounding="$(gh pr view --json body -q .body 2>/dev/null | awk '{ sub(/\r$/, "") }
      p && (fence != "" || !/^## /)'"$fenced"'
      /^## / { p = (h == "Blast Radius") }' || true)"
  fi
  grounding="$(printf '%s\n' "$grounding" | sed '/./,$!d')"
  if ! printf '%s' "$grounding" | grep -q '[^[:space:]]'; then
    rm -rf "$dir"
    echo "review-brief: cross-cutting diff (${crossing# }) without a blast-radius grounding; run the blast-radius skill, put the result in the PR body's Blast Radius section or pass --blast-radius FILE" >&2
    exit 1
  fi
elif [ -n "$blast" ]; then
  echo "review-brief: the diff is not cross-cutting; $blast is not pasted" >&2
fi
state=.claude/state/review
rm -rf "$state"
mkdir -p "$state"
echo "$fixed" > "$state/fixed-point"
cp "$dir/files" "$state/files"
echo "$dir" > "$state/dir"
echo "$fixed" > "$dir/fixed-point"
echo "$round" > "$dir/round"

# The spec is the ticket body plus the comments its author posted, each under its date. Comments by
# anyone else, and the PR's own comments, are never spec.
spec="" comments=""
if [ -n "$ticket" ]; then
  err="$(gh issue view "$ticket" --json body -q .body 2>&1 >"$dir/ticket.md" || true)"
  spec="$(cat "$dir/ticket.md")"
  [ -n "$spec" ] || echo "review-brief: gh could not fetch #$ticket ($(printf '%s' "$err" | tr '\n' ' ')); no spec" >&2
  by_author='.author.login as $a | .comments[] | select(.author.login == $a) | "### \(.createdAt[:10])\n\n\(.body)\n"'
  [ -z "$spec" ] || comments="$(gh issue view "$ticket" --json author,comments -q "$by_author" 2>/dev/null || true)"
fi
if [ ${#standards[@]} -eq 0 ] && [ -f CODING_STANDARDS.md ]; then standards=(CODING_STANDARDS.md); fi
# The definition both reports rest on, Manuel's words it follows, the step rule and the count rule;
# SKILL.md step 4 carries each word for word (tests/spec-review/review-brief.sh holds them together).
definition="A hard finding is one of two things: the documented path gives a wrong or silent result, or an input outside it proceeds silently (fails open). An input outside the documented path that is refused with a message saying how to correct it is not a finding; it is the design. Zero items is the expected result for a clean change."
quotes=(
  '- Manuel: "there are an infinite amount of unhappy paths and only 1 happy one"'
  '- Manuel: "AT MOST hardening to fail fast and loud if we move outside of that"'
  '- Manuel: "we notice the variable is unexpected and flag that without having to diagnose every reason the variable might be wrong for the user"'
  '- Manuel: "An edge case outside the intended path being unsupported is not a flag."'
  '- Manuel: "Primary focus must be the happy path, then unhappy paths that error in a way the user can correct."'
)
step_rule='Every item under `## Would break` or `## Fails open` carries a line `Documented step:` quoting the ticket line or the `file:line` of the documentation the user follows, and a line `Result:` saying what happens instead; an item without its `Documented step:` line is sent back.'
# The blast-radius paragraph; SKILL.md step 4 carries it word for word (the same test holds them together).
blast_rule="The sessions and skills this change reaches, as the author grounded them before the review. Check the diff against each one; the grounding is the author's claim, not evidence."
count_rule='End the report with exactly one line `hard findings: N`, where N is the number of items under `## Would break` and `## Fails open` and nothing else.'
common() {
  echo "Read nothing beyond this brief unless a finding needs the code around a hunk, and then read that one function or section, not the file. Run nothing."
  echo
  echo "## Commits"
  echo
  cat "$dir/log"
  echo
  echo "## Changed files"
  echo
  cat "$dir/stat"
  echo
  if [ -n "$grounding" ]; then
    echo "## Blast radius"
    echo
    echo "$blast_rule"
    echo
    printf '%s\n' "$grounding"
    echo
  fi
  echo "## Diff"
  echo
  if [ "$(wc -l < "$dir/diff")" -lt 500 ]; then
    echo '```diff'
    cat "$dir/diff"
    echo '```'
  else
    echo "The diff is $(wc -l < "$dir/diff" | tr -d ' ') lines; read it from \`$dir/diff\`."
  fi
  echo
  if [ -n "$settled" ]; then
    echo "## Settled in earlier rounds"
    echo
    echo "These findings were raised in an earlier round and settled by the decision each one cites. Do not raise them again. Nothing in this section says what you should find or confirm."
    echo
    printf '%s\n' "$settled"
    echo
  fi
}
# The opening of each brief's Report section: the definition, Manuel's words, the shape sentence.
report_rules() {
  echo "## Report"
  echo
  echo "$definition"
  echo
  printf '%s\n' "${quotes[@]}"
  echo
  echo "Write the report as Markdown with exactly these \`## \` headings, in this order, each holding numbered items or nothing:"
  echo
}
{
  echo "# Standards review brief"
  echo
  common
  echo "## Standards"
  echo
  if [ ${#standards[@]} -gt 0 ]; then
    for f in "${standards[@]}"; do
      echo "### $f"
      echo
      cat "$f"
      echo
    done
  else
    echo "This repository documents no coding standards; the smell baseline below is the whole standard."
    echo
  fi
  echo "## Smell baseline"
  echo
  echo "Each smell reads *what it is* -> *how to fix*; match it against the diff. A documented repo standard overrides the baseline; every smell is a judgement call, never a hard violation."
  echo
  printf '%s\n' "$smells"
  echo
  report_rules
  echo '- `## Would break`: a breach of a documented standard that makes the documented path give a wrong or silent result. Cite the standard (file + the rule) and quote the hunk.'
  echo '- `## Fails open`: a breach of a documented standard that lets an input outside the documented path proceed silently. Cite the standard (file + the rule) and quote the hunk.'
  echo '- `## Standards breaches`: documented-standard breaches that do not change behavior. Cite the standard and quote the hunk.'
  echo '- `## Fix alongside`: baseline smells and other judgement calls. Name the smell and quote the hunk. They are fixed only when a would-break fix already touches that code; they never count.'
  echo
  echo 'Each item opens with a line of the form `1. **Title.** body`, with the quoted hunk in a fenced block under it; number the items continuously across the headings, so the judgment can name your third item as [S3]. A documented repo standard overrides the baseline. Skip anything tooling enforces. Read nothing beyond this brief unless a finding needs the code around a hunk, and then read that one function or section, not the file. Under 400 words.'
  echo
  echo "$step_rule"
  echo
  echo "Write your report to \`$dir/standards-report.md\` and reply with only that path."
  echo "$count_rule"
} > "$dir/standards-brief.md"
if [ -n "$spec" ]; then
  {
    echo "# Spec review brief"
    echo
    common
    echo "## The ticket (#$ticket)"
    echo
    printf '%s\n' "$spec"
    echo
    if [ -n "$comments" ]; then
      echo "## Comments by the ticket's author (#$ticket)"
      echo
      printf '%s\n' "$comments"
      echo
    fi
    report_rules
    echo '- `## Walk`: one numbered line per documented step of the path the change touches (the ticket'"'"'s criteria and the documentation the diff changes), each saying what the code does at that step. A walk, not findings: its lines are numbered 1..K on their own and count nothing.'
    echo '- `## Would break`: a requirement missing, partial, or implemented so that the documented path gives a wrong or silent result.'
    echo '- `## Fails open`: an input outside the documented path that proceeds silently instead of being refused with a message saying how to correct it.'
    echo '- `## Not asked for`: behaviour in the diff the ticket did not ask for.'
    echo
    echo 'Each item opens with a line of the form `1. **Title.** body` and quotes the spec line it rests on in a fenced block (a criterion can carry `## ` or `1. ` lines, and only fenced text is exempt from the report shape); number the items continuously across the headings from `## Would break` on, so the judgment can name your third item as [P3]. Read nothing beyond this brief unless a finding needs the code around a hunk, and then read that one function or section, not the file. Under 400 words.'
    echo
    echo "$step_rule"
    echo
    echo "Write your report to \`$dir/spec-report.md\` and reply with only that path."
    echo "$count_rule"
  } > "$dir/spec-brief.md"
  echo "$dir/standards-brief.md"
  echo "$dir/spec-brief.md"
else
  echo "$dir/standards-brief.md"
  echo "no spec: Standards axis only"
fi
