What #137 meant a Standards reviewer to understand from this brief (from the commit message of c3d0b93 and the #137 ticket's aim, "stop the review briefs from leading the witness"):

- Task: review the diff of the listed commits against the repository's documented standards and the smell baseline, and report what breaches them.
- Done: a report at `.scratch/review/ab47eb9/standards-report.md` in the given heading shape, every item numbered, Would break and Fails open items carrying `Documented step:` and `Result:` lines, ending with `hard findings: N`; the reply is only the path.
- May change: write that one report file. The reviewer may open any file in the repository and run read-only commands such as grep or the test suite, to check a finding. The report has no length cap, and no number of findings is expected in advance; every real finding is reported.
- Must not: edit repository files, or run commands that change state.
