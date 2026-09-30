## Would break

## Fails open

## Standards breaches

## Fix alongside

1. **An unclosed fence above the Writer flags list hides it, and only that site has no second guard.** `disposed` reports an unclosed fence only when it opened while `on` was true (`opened = on ? $0 : ""`), and `$fenced` swallows every later line. For the risks site that is harmless: an unclosed fence above `## Risks` makes the heading unfindable, and the check just above refuses with the "no Risks heading outside fenced text" message. The flags site has no such heading check, so a ticket body with one stray fence anywhere above `### Writer flags <YYYY-MM-DD>` makes the opener itself fenced, the list unread, and the run pass with nothing printed. Judgement call, not a documented-standard breach: P108 scopes the fence refusal to "a fence opened in a list", and an unbalanced fence is an authoring error GitHub renders as a code block. The cheapest close is reporting `fence` whenever a fence is still open at EOF in `flags` mode.

```awk
  /^(```|~~~)/ && fence == "" { opened = on ? $0 : "" }
  ...
  END { if (fence != "" && opened != "") print "fence" US US opened }
```

2. **Duplicated Code: the two refusal blocks.** The risks refusal and the flags refusal are the same four moves in the same order (`rm -rf "$dir"`, a one-sentence header naming the site, `printf '%s\n' "$bad" >&2`, `exit 1`), differing only in the sentence. A third site would copy it again. Worth collapsing into one `refuse_undisposed <header>` helper only if a would-break fix already touches this region; both messages are pinned word for word by `tests/spec-review/review-brief.sh` (`rr8`, `rf8`), so the collapse must keep the exact strings.

```sh
  bad="$(printf '%s\n' "$grounding" | undisposed risks)"
  if [ -n "$bad" ]; then
    rm -rf "$dir"
    echo "review-brief: the blast-radius grounding ($where) has risk lines without a disposition; ..." >&2
    printf '%s\n' "$bad" >&2
    exit 1
  fi
```

hard findings: 0
