# patches/

The edits Factory918 makes to vendored skills, as unified diffs against the upstream pins in `SOURCES.md`. `series` lists them in apply order. Paths inside each patch are relative to `.agents/skills`, so from that directory `git apply ../../patches/<file>` applies one.

`factory918 sync` rebuilds the vendored set this way: copy the pinned upstream skills, drop `no-comments`, copy Pocock's `code-review` to `spec-review`, add our `poteto-mode/playbooks/ticket.md`, then apply `series`. The result matches `template/.agents/skills` byte-for-byte; verified 2026-09-16 against open-pstack v1.3.0 and mattpocock/skills 6654f6b.

Regenerate a patch after editing a vendored file:

    diff -u --label a/<path> --label b/<path> research/<upstream>/<path> template/.agents/skills/<path> > patches/<source>/<path>.patch

The session mandate (`template/.claude/hooks/session-mandate.md`) and `ticket.md` are ours, not patches.
