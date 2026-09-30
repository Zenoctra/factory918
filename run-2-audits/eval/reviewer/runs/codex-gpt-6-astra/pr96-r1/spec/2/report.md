## Walk

1. **Factory CI.** The symlink invokes the shared pin over the required globs, replacing syntax checks.
   ```text
   pinned to an exact version
   ```
2. **Project CI.** Template and fixture invoke the same zero-argument gate.
   ```text
   The template's CI runs `shellcheck`
   ```
3. **Writer.** The playbook and its patch require checking changed shell files.
   ```text
   before the PR opens
   ```
4. **Doctor.** Missing ShellCheck produces NOTE with installation commands.
   ```text
   `NOTE`, not `FAIL`
   ```
5. **Suppressions.** Standards require same-line reasons; changed directives supply them.
   ```text
   its reason on the same line
   ```
6. **Verification documentation.** AGENTS lists the gate; findings records the dated pin.
   ```text
   records the version verified
   ```
7. **Cache risk.** An executable cache bypasses verification.
   ```text
   checks its sha256
   ```
8. **Test risk.** Restricting PATH leaves system ShellCheck visible; an installed pin defeats the simulated absence.
   ```text
   with ShellCheck hidden
   ```
9. **Glob risk.** Only an entirely empty aggregate is refused.
   ```text
   A glob matches no file
   ```
10. **Offline/platform risk.** Download failures abort; unsupported platforms receive installation guidance.
    ```text
    install it by hand
    ```
11. **Update risk.** The grounding reports merge conflicts preserve the old workflow; this diff adds no conflict resolution.
    ```text
    A project that edited its `ci.yml` near the top gets no gate.
    ```

## Would break

1. **Quoted filenames split.** `shellcheck.sh:38` word-splits each argument before globbing.
   ```text
   exactly these; quote a glob, the script expands it
   ```
   Documented step: Design's explicit-file invocation.
   Result: `clean.sh 'dir with space/bad.sh'` silently omits the second existing file and can pass.

## Fails open

2. **Partial misses pass.** The empty-array guard does not validate each glob.
   ```text
   A glob matches no file
   ```
   Documented step: Design's unmatched-glob refusal row.
   Result: `clean.sh 'nope/*.sh'` succeeds when clean.sh passes.

3. **Unverified cached executable runs.** Lines 26–32 validate only fresh downloads.
   ```text
   checks its sha256, and runs that
   ```
   Documented step: Design's pinned-download signature.
   Result: A substituted executable in the shared cache runs unchecked; the grounding demonstrates a false pass.

## Not asked for

hard findings: 3
