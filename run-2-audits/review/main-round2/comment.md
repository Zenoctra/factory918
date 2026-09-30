Round two found no would-break defect in the code, but the parser that checks report shape trusts its input in three ways a real review will trip: nested or tilde fences, restarted numbering, and a rerun dir spelled absolutely. Reviewed commit a0b809a; seven items to act on, all in one script plus one brief sentence and one decisions line.

## Standards

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

## Spec

## Would break

1. **The Spec brief never tells the reviewer to fence its quotes, and the script counts unfenced text.** The criterion is "Both briefs define a hard finding as wrong behavior in normal use and require each one as a numbered item under a `## Would break` heading", and `review-comment.sh` enforces that shape with awk that only skips fenced regions: `headings()` takes any line starting `## ` and `items()` any line starting with a digit, a dot and a space. The Standards brief says "with the quoted hunk in a fenced block under it"; the Spec brief only says "quotes the spec line it rests on". A ticket whose acceptance criteria are Markdown — this ticket's are, including literal `## ` headings and numbered criteria — leads the Spec reviewer to paste a line that either fails the shape check outright or is silently counted as an extra item, which then fails the reference check with a message about a judgment that is correct. This report had to avoid line-initial headings and numerals to pass.

2. **A quoted hunk that contains a fence unbalances the fence toggle.** Same awk: `/^```/ { fence = !fence }`. Sixteen of the eighteen changed files here are Markdown, and the briefs, SKILL.md and the patch all carry fenced examples. A reviewer quoting such a hunk inside a fenced block leaves `fence` inverted for the rest of the file, so real headings are skipped and the report is refused for a shape it has.

## Latent

3. **Under-counting is accepted.** The criterion says exit 1 when the count "exceeds" the Would-break items; the script uses `-le`, so a report saying 0 with three Would-break items passes.

4. **Trailing space after a heading name breaks the match**, since `headings()` compares the raw substring.

5. **Four of the seven criteria are untouched** — blast-radius grounding, carry-forward, the author's ticket comments, the round cap and the ledger line. The ticket allows this ("likely a stack of PRs, one concern each"), but the round cap edits the same output block this PR rewrites.

6. **The `opus` preset is not cheaper than the writer's lane**, both `claude:opus@high`; the criterion says "so its finder can run cheaper than the writer's lane", and models.md was softened to "no dearer".

## Not asked for

7. **An `Ask` bucket counted into `act-on items`, and a rerun-by-directory mode.** The criterion names four buckets and no rerun path. Both follow from the ask-by-default rule, but a pending question now blocks babysit's merge-ready gate.

hard findings: 2

## Judgment

## Act on

1. [S1] **The rerun dir is matched as a string.** An absolute or `./` spelling prints the comment and leaves the state behind, so the hook keeps blocking; normalize the argument to a root-relative path before comparing, and test the absolute spelling.
2. [S3] **References resolve by position, not by the number written.** A report that restarts numbering under each heading passes the set check while every `[S<n>]` names a different finding; refuse a report whose written numbers do not run 1..N in document order.
3. [S4] **A fence inside a fence inverts the toggle.** Same defect as [P2]; one fix in the shared awk.
4. [S5] **P17 is a gap in the Provisional table.** One line saying P17 was promoted to decision 19; the orchestrator owns that file and commits it here.
5. [P1] **The Spec brief does not ask for fenced quotes.** The Standards brief does; say the same in the Spec brief, since a quoted criterion carries `## ` and `1. ` lines.
6. [P2] **Fence handling is a bare toggle.** Track the opening fence (backticks or tildes, and its length) and close only on a fence at least as long of the same character, which is the CommonMark rule; the round-2 Standards report itself uses `~~~` fences the current awk does not see.
7. [P4] **A trailing space after a heading breaks the match.** Trim trailing whitespace in the shared parser; rides with the fence fix.

## Ask

## Consider

1. [P6] **In the opus preset the spec reviewer is not cheaper than the writer.** `claude:opus@medium` would make it so; Manuel's stated reason for the row is context over model, so the choice is his and the doc now says "no dearer".

## Noted

1. [S2] **The report shape is written in six places.** The test pins the definition and the headings the script enforces; a rename is rare and the test fails loudly.
2. [P3] **Under-counting passes.** The count line no longer feeds the count; refusing a smaller number would enshrine a line that is now only a cross-check.
3. [P5] **Four criteria are not in this diff.** PRs B and C carry them; the round cap edits the same output block and B is already rebased on this PR.

## Dismissed

1. [P7] **Ask counted and a rerun path were not asked for.** Round 1 settled this: an unanswered security or data question must hold readiness, and the rerun is what lets the human's answer close it without paying for two new reviewer lanes.

Standards: 0 would break of 5; Spec: 2 would break of 7; judged: act on 7, ask 0, consider 1, noted 3, dismissed 1; fixed point main.
act-on items: 7
