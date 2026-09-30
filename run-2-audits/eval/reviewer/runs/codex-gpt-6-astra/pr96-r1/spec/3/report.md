## Walk

1. **Factory CI.** The symlink gate replaces syntax checks over the required globs.
   ```text
   `shellcheck` runs in the factory's CI
   ```
2. **Project CI.** Template and fixture invoke the default file set.
   ```text
   The template's CI runs `shellcheck`
   ```
3. **Writer.** The patched playbook requires checking changed shell files.
   ```text
   before the PR opens
   ```
4. **Doctor.** Missing ShellCheck produces NOTE and installation commands.
   ```text
   `NOTE`, not `FAIL`
   ```
5. **Suppressions.** Directives gain reasons; standards assign review responsibility.
   ```text
   its reason on the same line
   ```
6. **Documentation.** AGENTS lists verification; findings records version and date.
   ```text
   records the version verified
   ```
7. **Cache risk.** Executability bypasses download verification.
   ```text
   checks its sha256
   ```
8. **Test risk.** PATH narrowing still exposes system ShellCheck; an installed pin defeats the simulated absence.
   ```text
   ShellCheck hidden
   ```
9. **Glob risk.** Only an empty aggregate triggers refusal.
   ```text
   A glob matches no file
   ```
10. **Environment risk.** Unsupported platforms and download failures exit loudly.
    ```text
    Local ShellCheck absent, platform not pinned
    ```
11. **Update risk.** The diff adds a template step; conflicting project workflows retain existing merge handling.
    ```text
    The template's CI runs `shellcheck`
    ```

## Would break

1. **Quoted filenames split.** `template/.github/shellcheck.sh:38` word-splits `$g` before glob expansion.
   Documented step: Design usage:
   ```text
   exactly these; quote a glob, the script expands it
   ```
   Result: Passing `'scripts/my hook.sh'` splits the existing filename into two nonexistent paths and refuses it; alongside a clean file, it silently skips it. Preserve whitespace within each argument.

## Fails open

2. **Unverified cache executes.** `template/.github/shellcheck.sh:26` trusts any executable at the cache path.
   Documented step: Design signature:
   ```text
   checks its sha256, and runs that
   ```
   Result: A replacement executable returning zero passes every file while the gate announces ShellCheck 0.11.0. Validate cached content before execution.

3. **Missing glob silently ignored.** `template/.github/shellcheck.sh:38-40` checks only the aggregate.
   Documented step: Design table:
   ```text
   A glob matches no file
   ```
   Result: `clean.sh 'nope/*.sh'` passes instead of refusing the unmatched glob. Validate each explicit argument's matches.

## Not asked for

hard findings: 3
