## Would break

## Standards breaches

1. **The rerun form's dir is matched as a string, and no test types it the way a user would.** `CODING_STANDARDS.md`, Bash: "Test a command the way a user types it: absolute paths, from another directory, through the installed symlink." The script `cd`s to the repo root, then compares the argument to the state file byte for byte, so the same directory spelled absolutely (or as `./.scratch/review/x`) prints the comment but leaves `.claude/state/review` behind, keeping the delegation hook blocking the reviewed files. `tests/spec-review/review-comment.sh` only ever passes the root-relative spelling.

~~~sh
dir="${1%/}"
[ -d "$dir" ] || fail "$dir is not a directory; pass the .scratch/review/<id> review-brief.sh wrote"
...
if [ -f "$state/dir" ] && [ "$(cat "$state/dir")" = "$dir" ]; then rm -rf "$state"; fi
~~~

## Fix alongside

2. **Shotgun Surgery: the report shape is written out in six places.** Renaming one heading means editing `review-brief.sh`, `review-comment.sh`, `SKILL.md`, the patch, `DECISIONS.md` and both tests; `tests/spec-review/review-brief.sh` pins only the definition sentence and a few fragments, not the heading list the script enforces.

~~~sh
report "$dir/standards-report.md" "Would break" "Standards breaches" "Fix alongside"
~~~

3. **`[S<n>]` is resolved by position, not by the number the reviewer wrote.** `items` counts in document order, so a report that restarts numbering under each heading still passes the set check while every judgment reference silently names a different finding. Nothing checks the printed numbers run 1..N.

~~~sh
h != "" && /^[0-9]+\. / && (want == "" || h == want)
~~~

4. **Fence toggling desyncs on a hunk that contains a fence.** Reviews of this repo quote markdown, and the brief asks for the hunk in a fenced block; one nested triple-backtick line inverts `fence` and the shape check then refuses the whole review with a heading list that looks nothing like the file.

~~~sh
headings() { awk '/^```/ { fence = !fence; next } fence { next } /^## / { print substr($0, 4) }' "$1"; }
~~~

5. **P17 is missing.** `DECISIONS.md` goes P16 → P18 → P19; a reader will hunt for the gap.

hard findings: 0
