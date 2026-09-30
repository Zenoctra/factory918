# Standards report

## Would break

1. **A glob beside a matching one can still slip past the refusal it names.** The header promises a per-glob refusal, but the brief's repro (`'template/.claude/hooks/*.sh' 'nope/*.sh'`) reports `files checked: 5`, exit 0, instead of refusing.
Documented step: `template/.github/shellcheck.sh:11-13`, "A glob that matches no file is refused before ShellCheck runs, even beside globs that match, because a gate that checks fewer files than it names is a failure, not a pass." (the intent of commit `01e5386`).
Result: the gate silently checks fewer files than it was told to, on the documented path the comment says is handled.
```
+IFS=  # an argument is one path or one glob, never split on the spaces in it
+for g in "$@"; do
+  matched=0
+  for f in $g; do if [ -f "$f" ]; then files+=("$f"); matched=1; fi; done
+  if [ "$matched" = 0 ]; then
+    echo "shellcheck.sh: no file matched $g; the gate checked nothing" >&2
+    exit 1
+  fi
+done
```

## Fails open

2. **A tampered cached binary runs with no checksum.** CODING_STANDARDS.md: "A failure a gate depends on is printed before anything continues... never hide it." The header claims the sha is verified on every run; the brief's proof (swapping in a two-line script at the cached path, gate ran it, exit 0) shows the extracted binary itself is never re-checked once its directory exists.
Documented step: `template/.github/shellcheck.sh:2-4`, "it downloads the release tarball once, verifies its sha256 on every run, and runs the binary it extracts from it."
Result: a binary at `${TMPDIR:-/tmp}/shellcheck-0.11.0/shellcheck-v0.11.0/shellcheck` that was not produced by this run's own verified tarball is still executed, and the gate reports success.
```
+  [ -f "$tarball" ] || curl -fsSL -o "$tarball" "https://github.com/koalaman/shellcheck/releases/download/v$version/shellcheck-v$version.$plat.tar.xz"
+  if command -v sha256sum >/dev/null; then echo "$sha  $tarball" | sha256sum -c - >/dev/null
+  else echo "$sha  $tarball" | shasum -a 256 -c - >/dev/null; fi
+  tar -xJf "$tarball" -C "$dir"
```

## Standards breaches

## Fix alongside

3. **Mysterious Name: the doctor's PASS line names a version it never checked.** The check reports any installed ShellCheck as a pass, not the pinned one the gate itself enforces (`version=0.11.0` in `template/.github/shellcheck.sh:15`), so a stale system ShellCheck reads as PASS while the gate silently re-downloads the pin underneath it.
```
+  local scv; scv="$(shellcheck --version 2>/dev/null | sed -n 's/^version: //p' || true)"
+  if [ -n "$scv" ]; then echo "PASS  shellcheck $scv"
+  else note "shellcheck" "brew install shellcheck (apt install shellcheck, dnf install ShellCheck, winget install koalaman.shellcheck); .github/shellcheck.sh downloads the pinned build without it, so this is a NOTE"; fi
```

hard findings: 2
