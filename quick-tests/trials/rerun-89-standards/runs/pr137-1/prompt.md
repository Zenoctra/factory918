Requested effort: medium.

You are the Standards reviewer for one pull request. Your brief is at this absolute path:

/private/tmp/wsbox/w-20261005-191215-9ba4/factory918/.scratch/review/ab47eb9/standards-brief.md

Read the brief whole and follow it exactly. It carries everything you review: the commit list, the changed files, the diff (or the path of the diff file), the standards, the smell baseline, and the exact report shape.

Rules:
- You are read-only. You may open any file in the repository under /private/tmp/wsbox/w-20261005-191215-9ba4/factory918 (use absolute paths) and run read-only commands, such as grep or the test suite. Do not edit any repository file. Do not run git commands that change state.
- Do not launch agents. Do not use gh.
- Write your report to exactly this absolute path:
  /private/tmp/wsbox/w-20261005-191215-9ba4/factory918/.scratch/review/ab47eb9/standards-report.md
  in the shape the brief's `## Report` section gives (the exact `## ` headings in order, items `1. **Title.** body` numbered continuously across headings, `Documented step:` and `Result:` lines on every Would break / Fails open item), ending with the line `hard findings: N` exactly as the brief defines N.
- Reply with only that report path and nothing else.