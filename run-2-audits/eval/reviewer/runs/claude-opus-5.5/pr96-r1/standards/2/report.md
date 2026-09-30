## Would break

## Fails open

1. **An argument that matches no file is dropped silently when another one matches.** `CODING_STANDARDS.md`, Bash: "A failure a gate depends on is printed before anything continues." The gate refuses only when *every* argument is empty. A mistyped path, a renamed directory, or a deleted file a lane passes next to real ones is filtered out by `[ -f "$f" ]`. The gate then passes on the rest, and the count is the only sign.
Documented step: `template/.agents/skills/poteto-mode/playbooks/opening-a-pr.md:9` "Run `bash .github/shellcheck.sh` on every shell file the diff changes before the PR opens"; `AGENTS.md:38`, the five-glob command.
Result: `bash .github/shellcheck.sh 'template/.claude/hooks/*.sh' 'nope/*.sh'` prints `files checked: 5` and exits 0 (the brief's Risk 3). A lane that mistypes a changed file's path gets a pass for a file that was never checked. The fix is to refuse each argument that expands to nothing and name it.

```sh
+for g in "$@"; do
+  for f in $g; do if [ -f "$f" ]; then files+=("$f"); fi; done
+done
+if [ "${#files[@]}" = 0 ]; then
```

## Standards breaches

## Fix alongside

2. **The cached binary is trusted without its checksum.** This is a judgement call against P25, which says the gate "holds ... both release checksums". The sha is checked only on the run that downloads. After that, any executable at the cache path in a shared `TMPDIR` runs as the gate, and its version is never checked (the brief's Risk 1).

```sh
+  if [ ! -x "$bin" ]; then
+    mkdir -p "$dir"
```

3. **Test 6 depends on the host, not on the fixture.** The test narrows PATH to `/usr/bin:/bin` and assumes the pin is not installed there. A runner image that ships ShellCheck 0.11.0 turns the test red with no code fault (the brief's Risk 2). A fake `shellcheck` in `$fx/bin` that prints another version would make the test independent of the host.

```sh
+PATH="$fx/bin:/usr/bin:/bin" run clean.sh
+same "6 an unpinned platform without ShellCheck is refused" 1 "$code"
```

4. **The doctor reports PASS for any ShellCheck version.** A Mysterious Name, in a mild form: `PASS  shellcheck 0.9.0` reads as though the gate is satisfied, but the gate ignores that build and downloads the pin. A NOTE when the version is not the pin would match what the gate actually does.

```sh
+  if [ -n "$scv" ]; then echo "PASS  shellcheck $scv"
```

hard findings: 1
