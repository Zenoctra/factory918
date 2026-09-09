# Bootstrap (frozen)

`build_template.py` is how `template/`, `profiles/` and the root files were first generated on 2026-09-09: it vendors the pinned skills from `research/`, applies the patches listed in `SOURCES.md`, and adds the hand-written files in `inputs/`. It is kept for provenance and as raw material for `factory918 sync`.

Since the first commit, `template/` and `profiles/` are edited directly and are the truth. Do not edit `inputs/`; those files were superseded by their copies in `template/` the moment the repo was committed. The script writes only to `_out/` (git-ignored):

    python3 tools/bootstrap/build_template.py
    diff -r tools/bootstrap/_out/template template      # shows every edit made since bootstrap
