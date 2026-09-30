## Would break

## Fails open

1. **The zero-argument gate passes over 6 of the factory's 20 files.** `template/.github/shellcheck.sh:35` defaults to a project's layout. At the factory root those globs resolve through `.claude/hooks`, a symlink into `template/`, so the run finds the five hooks and the gate itself, matches nothing for `.agents/skills/*/scripts/*.sh` (the factory has no `.agents/` at its root) and exits 0. The refusal at `:39-42` fires only when *every* argument matches nothing, so one glob matching nothing beside one that matches is silent. The same silence covers a glob that goes stale: the five globs in `AGENTS.md:38` and `.github/workflows/factory-ci.yml:19` are the only record of the factory's set, and a layout move shrinks that set with CI still green. Cheapest hardening is to refuse when any one argument matches no file and name it: at the factory root that refusal points at `.agents/skills/*/scripts/*.sh` and sends the lane to the `AGENTS.md:38` command. It would also refuse a project whose hooks were all deleted (the 6-file case the fixture grounding names), which is the judgement to make.
Documented step: `template/.agents/skills/poteto-mode/playbooks/opening-a-pr.md:9`, "Run `bash .github/shellcheck.sh` on every shell file the diff changes before the PR opens; it is the gate CI runs" — the playbook this repository runs on itself (`AGENTS.md`, "The nesting rule"); `template/.github/shellcheck.sh:5` documents the zero-argument form as "this project's shell files" and `template/AGENTS.md:63` as "which is what CI runs". The standard breached is `CODING_STANDARDS.md:13`, "Test a command the way a user types it: absolute paths, from another directory, through the installed symlink".
Result: at the factory root `bash .github/shellcheck.sh` prints `ShellCheck 0.11.0, files checked: 6` and exits 0. A lane that runs the gate through the new root symlink the way the playbook writes it gets a green pass over the five hooks and the gate script, while the fourteen other files CI checks — `factory918.sh`, the five scripts under `template/.agents/skills/*/scripts/`, the eight under `tests/` — are never read.
spec: table zero-argument form/expected result (the `## Design` row `tests/shellcheck/gate.sh:5-6` names "the zero-argument form from a project's root" and asserts a project's count; no row covers the same command at the factory root).

```sh
# template/.github/shellcheck.sh:35-43
if [ "$#" = 0 ]; then set -- '.claude/hooks/*.sh' '.agents/skills/*/scripts/*.sh' '.github/shellcheck.sh'; fi
files=()
for g in "$@"; do
  for f in $g; do if [ -f "$f" ]; then files+=("$f"); fi; done
done
if [ "${#files[@]}" = 0 ]; then
  echo "shellcheck.sh: no file matched $*; the gate checked nothing" >&2
  exit 1
fi
```

```
$ bash .github/shellcheck.sh                 # at the factory root
ShellCheck 0.11.0, files checked: 6
EXIT=0
$ bash .github/shellcheck.sh factory918.sh template/.github/shellcheck.sh \
    'template/.claude/hooks/*.sh' 'template/.agents/skills/*/scripts/*.sh' 'tests/*/*.sh'
ShellCheck 0.11.0, files checked: 20
EXIT=0
```

## Standards breaches

## Fix alongside

2. **Duplicated Code: the pin is a literal in three of the test's expected strings.** `template/.github/shellcheck.sh:13` holds `version=0.11.0`, and `tests/shellcheck/gate.sh` re-types the number into three expectations. A bump edits four lines in two files; the test fails loudly if one is missed, so nothing is silent, but the test could read the pin out of the script it runs (`sed -n 's/^version=//p' "$script"`) and then only the gate carries it.

```sh
# tests/shellcheck/gate.sh:66, 73, 77
check "1 a clean file" 0 "ShellCheck 0.11.0, files checked: 1" clean.sh
check "5 the zero-argument form from a project's root" 0 "ShellCheck 0.11.0, files checked: 4"
same "6 the refusal names the pair" "shellcheck.sh: ShellCheck 0.11.0 is not pinned for Plan9.mips; install it by hand" "$err"
```

3. **The cache path is trusted without the checksum, and two lanes share it.** `[ ! -x "$bin" ]` guards the download, so whatever already sits at `${TMPDIR:-/tmp}/shellcheck-0.11.0/shellcheck-v0.11.0/shellcheck` is exec'd with the sha never computed, and two lanes running the gate at once on a machine without the pin write and extract the same two paths. Both cases end loudly on this machine (a truncated binary does not exec), and CI runs the steps in sequence, so nothing is silent; the usual form is to download and extract into a per-run temporary directory and `mv` the result into place, which makes the step idempotent under a crash and under a second lane.

```sh
# template/.github/shellcheck.sh:24-32
  dir="${TMPDIR:-/tmp}/shellcheck-$version"
  bin="$dir/shellcheck-v$version/shellcheck"
  if [ ! -x "$bin" ]; then
    mkdir -p "$dir"
    curl -fsSL -o "$dir/sc.tar.xz" "https://github.com/koalaman/shellcheck/releases/download/v$version/shellcheck-v$version.$plat.tar.xz"
    if command -v sha256sum >/dev/null; then echo "$sha  $dir/sc.tar.xz" | sha256sum -c -
    else echo "$sha  $dir/sc.tar.xz" | shasum -a 256 -c -; fi
    tar -xJf "$dir/sc.tar.xz" -C "$dir"
  fi
```

hard findings: 1
