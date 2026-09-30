# Standards report

## Would break

## Fails open

## Standards breaches

## Fix alongside

1. **Duplicated Code: two near-identical PASS/NOTE doctor checks.** The models-sheet check was rewritten from `&&`/`||` to `if`/`else`, and the new shellcheck check right after it repeats the same shape (test a condition, `echo "PASS ..."` or call `note` with a fix string). The two blocks could share one helper (e.g. a `soft_check "<label>" "<test>" "<fix>"` wrapping the pattern), matching how `chk` already centralizes the hard-check shape.

```bash
-  [ -f "$HOME/.claude/pstack-models.md" ] && echo "PASS  models sheet" || note "models sheet" "factory918 install writes ~/.claude/pstack-models.md"
+  if [ -f "$HOME/.claude/pstack-models.md" ]; then echo "PASS  models sheet"; else note "models sheet" "factory918 install writes ~/.claude/pstack-models.md"; fi
+  local scv; scv="$(shellcheck --version 2>/dev/null | sed -n 's/^version: //p' || true)"
+  if [ -n "$scv" ]; then echo "PASS  shellcheck $scv"
+  else note "shellcheck" "brew install shellcheck (apt install shellcheck, dnf install ShellCheck, winget install koalaman.shellcheck); .github/shellcheck.sh downloads the pinned build without it, so this is a NOTE"; fi
```

hard findings: 0
