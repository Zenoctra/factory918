# Standards review, PR #129 (#111)

## Would break

## Fails open

## Standards breaches

1. **The test never types a path the way the reviewer will.** `CODING_STANDARDS.md`, Bash: "Test a command the way a user types it: absolute paths, from another directory, through the installed symlink." The test `cd`s into a fixture root with a space, then passes only relative paths, so the space never reaches an argument and no absolute path is ever exercised. The documented caller types absolute transcript paths under `~/.claude/projects/...`, and a project checkout's path can contain a space. The header comment claims coverage the assertions do not give.

```
fx="$tmp/with space"
cd "$fx"
script=.claude/skills/show-me-your-work/scripts/check-trail.sh
...
check "6 own" 0 "$(ok_own 3)" "" t/clean.tsv "$own"
```

The script itself quotes `$trail`, `"$@"` and `"$(dirname "$0")"`, so this is a test-coverage gap, not a behavior change.

## Fix alongside

2. **Duplicated Code: the header refusal line is written twice.** The same literal and `bad = 1` appear in the `NR == 1` rule and again in `END` for the empty file. One awk function, or a single guard covering both, would keep the two in step if the wording ever changes.

```
NR == 1 { if ($0 != header) { print "line 1: header is not the template's"; bad = 1 }; next }
...
END {
  if (NR == 0) { print "line 1: header is not the template's"; bad = 1 }
```

3. **The skill documents three exit codes of four.** The new paragraph in `template/.agents/skills/show-me-your-work/SKILL.md` covers exit 0, 1 and 2 but not 64, which is what the reviewer gets for the easy mistake of passing the trail alone. The script's own header comment lists all four; the skill is the copy the reviewer reads.

```
The script prints one `ok` line and exits 0, or exits 1 with one line per offending row: ... Exit 2 means the check did not run: fix the path and rerun, or write `trail clock not checked: <message>` under Attention.
```

hard findings: 0
