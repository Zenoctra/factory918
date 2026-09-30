This PR was verified by agents that did not write it, as the second link of the stack for tickets #88, #89, #90, #91 and #93, above PR #94. Every gate passes at head 2360707, the gate script was exercised live on both its paths, and the diff was audited against the ticket; nothing blocks, and the owner has been asked to correct two stale passages in this body.

## Verifier verdict

Verified head: `2360707f9bf56e4216f81ec652f20d4682ba24c4`, patch base `ab47eb9` (main). Position in the stack: second, above PR #94; the root will rebase this branch onto #94's verified tip and retarget the base, and re-run CI there.

| slice | verdict |
|---|---|
| gates re-run (the Verifying list at the SHA including the new gate and `tests/shellcheck/gate.sh`, knowledge build, sync, the patch, both CI workflows' new steps mirrored, six CI runs checked, the symlink) | PASS |
| live runtime floor (PATH path, download path with the pinned checksum, cache reuse, truncated and wrong-checksum tarballs, unmatched-glob refusal, a path with a space, SC2086 failing, the doctor both ways, an applied project's zero-argument run and its CI step) | PASS+NOTES |
| receipts-and-diff audit (six criteria met, 57 resolved findings sampled as behavior-preserving, three review comments and their rounds, closing reference #88 only, hook files identical with comments stripped, no forbidden edits) | PASS+NOTES |

Corrections asked of the owner, body only, no code: the Risks section still says a cached binary is reused without a checksum and that an unmatched glob is dropped silently, both the opposite of what runs at this head; the blast-radius grounding still says `ok 10 assertions` where the head prints 17, and the Scope case list omits 3b, 8, 8b and 9.

Off the path, filed as tickets rather than fixed here: two gate runs sharing one `TMPDIR` on an off-pin machine fail each other loudly because the binary is extracted on every run; the checksum failure speaks only in `sha256sum`'s voice with nothing naming the gate or saying the tarball was removed.

Notes carried, no action asked: round 3's fixed point was `ab47eb9` rather than the round-2 head, which over-covers; the doctor prints `PASS` with whatever version it finds; two vendored scripts are now linted but not in `keep_files`; the `For a person:` label is not enforced by the comment tool. The full reports are in the root session's scratch, not in the repository.

Claude Fable 5.1 on Claude Code
