## Act on

## Ask

## Consider

## Noted

1. [S1] **The blast-radius grounding no longer describes the code it grounds.** Valid: risk 1 and risk 3 were closed by `a64c7e6` with `1362b48` and by `01e5386`, and the "with the hooks deleted, 6" line is false since `01e5386`. The grounding is the author's dated claim before the review, and the brief says so to every reviewer; the PR body's section gets a dated addendum naming the closing commits under those two risks and that Cleared line, so a later reader is not handed the stale evidence. No code changes.
2. [S2] **A file-wide SC2016 on `review-brief.sh`.** Valid and raised twice; the file's sixteen occurrences are all jq programs and Markdown templates, and the standard's own words ("at the top of a file whose whole job produces the pattern") cover it, while its sibling's single occurrence takes the statement scope. Left as is.
3. [S3] **The doctor passes any ShellCheck, not the pin.** Valid; the line reports what is on the machine, and the gate, not the doctor, holds the pin and downloads it when the machine's copy differs, which is why the ticket asked for a NOTE and not a FAIL. Left as is.

## Dismissed

4. [S4] **A commit title names the wrong stream.** The title is about the effect, not the redirect: before `1362b48` the tool's `OK` line reached the gate's stderr through the `>&2` that `a64c7e6` added, and the commit takes it off stderr by discarding the tool's stdout, which its body says in those words.
