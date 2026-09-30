# Standards report

## Would break

None.

## Fails open

None.

## Standards breaches

None.

## Fix alongside

1. **Duplicated Code: the PASS/NOTE shape in `cmd_doctor` is now written twice.** The new ShellCheck check copies the models-sheet check's if/echo-PASS/note shape verbatim instead of sharing it.

```
if [ -f "$HOME/.claude/pstack-models.md" ]; then echo "PASS  models sheet"; else note "models sheet" "factory918 install writes ~/.claude/pstack-models.md"; fi
local scv; scv="$(shellcheck --version 2>/dev/null | sed -n 's/^version: //p' || true)"
if [ -n "$scv" ]; then echo "PASS  shellcheck $scv"
else note "shellcheck" "brew install shellcheck (apt install shellcheck, dnf install ShellCheck, winget install koalaman.shellcheck); .github/shellcheck.sh downloads the pinned build without it, so this is a NOTE"; fi
```

Both blocks probe an optional prerequisite and print `PASS <label>` or call `note <label> <fix>`; a third such check would make the pattern worth a small helper (e.g. `chk_present <label> <value-cmd> <fix>`). Not a would-break: `chk`'s own contract (boolean command, third-arg fix) does not fit a check that also wants to print a captured value, so the duplication is a shape choice, not a bug. Fixed only if a would-break fix already touches this code.

hard findings: 0
