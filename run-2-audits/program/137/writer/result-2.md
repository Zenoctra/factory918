# Writer result 2, ticket #137

Head `a1254df7a726e1989abeafb9715af7dcaaddd938` on `wt/137-writer`, pushed; `origin/wt/137-writer` is the same commit.

Commit `a1254df` "Say in SOURCES.md that each review brief lets the reviewer open any file and run read-only commands". It changes one clause in SOURCES.md item 6: "each brief says to read nothing beyond it" is now "each brief says the reviewer may open any file and run read-only commands". The rest of the item is unchanged.

- `./factory918.sh sync`, then `git status --porcelain`: empty.
- `python3 tools/check_knowledge.py`: `knowledge ok: 119 files`.
