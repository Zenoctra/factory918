## Walk

1. **Factory CI.** The symlink invokes the pinned gate over the required patterns, replacing syntax checks.
   ```text
   pinned to an exact version
   ```
2. **Project CI.** Template and fixture invoke the same defaults.
   ```text
   pinned the same way
   ```
3. **Before opening.** Patch and playbook require changed-file checks.
   ```text
   shellcheck on every changed shell file
   ```
4. **Doctor.** Absence prints NOTE and installation commands.
   ```text
   NOTE, not FAIL
   ```
5. **Suppressions.** Standards require reasons; added directives supply them.
   ```text
   reason on the same line
   ```
6. **Documentation.** AGENTS lists commands; findings records 0.11.0 and verification limits.
   ```text
   records the version verified
   ```
7. **Cache risk.** Executability alone bypasses verification.
   ```text
   A cached binary is reused with no checksum.
   ```
8. **Test risk.** Narrowed PATH retains system installations.
   ```text
   assumes no 0.11.0 lives in /usr/bin or /bin
   ```
9. **Pattern risk.** Only an entirely empty aggregate fails.
   ```text
   An unmatched glob among matched ones is dropped without a word
   ```
10. **Platform risk.** Unsupported platforms explicitly refuse; offline downloads fail visibly.
    ```text
    Local ShellCheck absent, platform not pinned
    ```
11. **Update risk.** Workflow conflicts retain the original; this diff adds no doctor check for the step.
    ```text
    A project that edited its ci.yml near the top gets no gate.
    ```

## Would break

1. **Requested files disappear.** `shellcheck.sh:38` discards unmatched arguments; word splitting also loses quoted filenames containing spaces.
   ```text
   A glob matches no file
   ```
   Documented step: Design requires exit 1 for this situation.
   Result: A clean matched file plus `nope/*.sh` returns 0, checking only the former.

2. **Supported installation breaks the test.** `tests/shellcheck/gate.sh:75` retains `/usr/bin:/bin`.
   ```text
   ShellCheck hidden
   ```
   Documented step: Design's platform test hides ShellCheck.
   Result: With 0.11.0 installed there, the gate correctly passes; the test demands refusal and fails CI.

## Fails open

3. **Unverified executable passes.** `shellcheck.sh:26` trusts any executable at the predictable cache path.
   ```text
   Runs ShellCheck 0.11.0
   ```
   Documented step: Design's pinned execution guarantee.
   Result: A substituted success-only script runs without checksum or version validation while the gate announces 0.11.0.

## Not asked for

hard findings: 3
