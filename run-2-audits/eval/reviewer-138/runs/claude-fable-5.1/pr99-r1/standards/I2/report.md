## Would break

## Fails open

## Standards breaches

## Fix alongside

1. **`hole:` is matched anywhere on the line, unlike its siblings.** Duplicated Code with a divergent twin: `fixed_here` and `ticketed` are `$`-anchored to a value, and the contract says `hole: $ref$` is anchored the same way, but `holed()` greps the bare word. Run at this commit, a Noted reason `not a hole: the table stands` or a Dismissed reason `the loophole: none` is refused as "carries a 'hole:' field under '## Noted'", and an Act on reason `a design hole: see the cell` as "fits no form". Loud, so nothing counts, but the message names a field the writer never wrote. Fix: require a trailing field (`[[:space:]]hole: ` at least) and keep the fits-no-form check on that.

```sh
holed() { items "$dir/judgment.md" "$1" | grep -vE "$ending" | grep 'hole:' || true; }
```

2. **A `design` spec line keeps its trailing blanks, so a word-for-word mark cannot match it.** `specs()` takes `substr($0, 7)` under `design [^[:space:]].*$`; `spec: design foo bar ` (one trailing space) refuses `hole: design foo bar` with "rests on 'design foo bar '", and the invisible difference is the whole message. `review-brief.sh`'s `split` strips CR and trailing blanks from every comment line; the report parse strips them only from headings. Fix: strip them in `specs()` and `stepless()`, not in the shared `fenced` fragment the twin test pins.

```sh
item && (at == "Would break" || at == "Fails open") && v == "" && $0 ~ want { v = substr($0, 7) }
```

3. **The slice awk repeats the separator normalisation `split` already does.** Duplicated Code, forced by `split`'s `next`; a rule before `$split` counting separators into `at[NR]` would leave the END loop reading arrays. Correct as written and pinned by the tests.

```sh
t = raw[i]; sub(/\r$/, "", t); sub(/[ \t]+$/, "", t); at[i] = c; if (t == sep) c++; else if (hit[i]) last = c
```

Clean: ShellCheck 0.11.0 over the four changed shell files (the new `SC2016` directive is live and carries its reason); the three `tests/spec-review/` suites pass; `./factory918.sh sync` re-applies the three patches and leaves the tree clean; `build_knowledge.py` and `check_knowledge.py` pass; every `|| true` guards a `grep` miss; no root copy of `review-ladder.md` exists to drift; the counts in prose (four fields, three forms, four shapes) are true at this commit.

hard findings: 0
