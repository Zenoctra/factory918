"""Apply PR #137's wording changes (commit c3d0b93, "Stop the review briefs from
leading the witness") to a Standards brief that review-brief.sh wrote before it."""
import sys
s = open(sys.argv[1]).read()
edits = [
    ("Read nothing beyond this brief unless a finding needs the code around a hunk, and then read that one function or section, not the file. Run nothing.",
     "You may open any file in the repository and run read-only commands, such as grep or the test suite."),
    (" Zero items is the expected result for a clean change.", ""),
    ('- Manuel: "Primary focus must be the happy path, then unhappy paths that error in a way the user can correct."\n',
     '- Manuel: "Primary focus must be the happy path, then unhappy paths that error in a way the user can correct."\n\nAn edge case that proceeds silently fails open: file it under `## Fails open`.\n'),
    (" Skip anything tooling enforces. Read nothing beyond this brief unless a finding needs the code around a hunk, and then read that one function or section, not the file. Under 400 words.",
     " Skip anything tooling enforces."),
]
for old, new in edits:
    assert s.count(old) == 1, old[:60]
    s = s.replace(old, new)
open(sys.argv[2], "w").write(s)
