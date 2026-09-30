## Would break

## Fails open

## Standards breaches

1. **New review cases bypass the installed entry point.** `CODING_STANDARDS.md`, Bash: “Test a command the way a user types it: absolute paths, from another directory, through the installed symlink.” The new restart cases invoke the copied skill directly after the suite changes into the fixture repository. They do not exercise either script through `.claude/skills` or from another directory.

```sh
pr me me:previous.md me:previous-2.md me:restart-3.md
bash "$skill/scripts/review-brief.sh" HEAD~1 --ticket 7 > out.txt
```

## Fix alongside

hard findings: 0
