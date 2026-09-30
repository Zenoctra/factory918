# Standards review report

## Would break

None.

## Fails open

None.

## Standards breaches

None.

## Fix alongside

1. **Duplicated Code: the same `rm -rf "${skills:?}/$n"; cp -R ... "$skills/$n"` shape appears twice in `cmd_sync`.** The SC2115 fix (`${skills:?}`) was applied identically to both copy loops in `factory918.sh`, which already shared the remove-then-copy shape before this change. A shared `vendor_skill() { rm -rf "${skills:?}/$1"; cp -R "$2" "$skills/$1"; }` called from both loops would carry the guard in one place instead of two.

```
-  for d in "$pstack"/skills/*/; do n="$(basename "$d")"; [ "$n" = no-comments ] && continue; rm -rf "$skills/$n"; cp -R "$d" "$skills/$n"; done
+  for d in "$pstack"/skills/*/; do n="$(basename "$d")"; [ "$n" = no-comments ] && continue; rm -rf "${skills:?}/$n"; cp -R "$d" "$skills/$n"; done
   for n in grilling grill-me grill-with-docs domain-modeling to-spec to-tickets wayfinder research prototype setup-matt-pocock-skills writing-for-agents wizard wait-what; do
-    src="$(find "$matt" -maxdepth 2 -type d -name "$n" | head -1)"; rm -rf "$skills/$n"; cp -R "$src" "$skills/$n"; done
+    src="$(find "$matt" -maxdepth 2 -type d -name "$n" | head -1)"; rm -rf "${skills:?}/$n"; cp -R "$src" "$skills/$n"; done
```

This is fixed only when a would-break fix already touches this code; it does not count toward `hard findings`.

hard findings: 0
