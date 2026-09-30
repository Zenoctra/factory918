# Standards review

## Would break

## Fails open

## Standards breaches

## Fix alongside

1. **Silent miscount if `cmd_sync`'s skills directory were ever empty.** `factory918.sh` replaced an `ls -d ... | wc -l` count with a bare array glob and no `nullglob`. On the documented path `$skills` always holds many freshly copied directories by this point, so the case never fires; flagged only because a future edit that runs this line before the copy loops would get "vendored: 1 skills" instead of "vendored: 0 skills," silently wrong. Not a Would-break/Fails-open item because it is unreachable on the path this diff documents.

```bash
-  echo "vendored: $(ls -d "$skills"/*/ | wc -l | tr -d ' ') skills. Review with git status, bump VERSION, commit."
+  local -a dirs; dirs=("$skills"/*/)
+  echo "vendored: ${#dirs[@]} skills. Review with git status, bump VERSION, commit."
```

hard findings: 0
