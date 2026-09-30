## What to build

PR #136 (ticket #108) makes `review-brief.sh` refuse a review while a ticket's writer flag has no disposition. It reads the flags under a `### Writer flags <date>` heading in the ticket body. When the list can't be read, the check passes silently. The #108 owner found one way this happens: an unclosed fence above the heading turns the list into fenced text, and the check prints nothing and passes. That is one of many shapes (a mangled heading, the list pasted inside a quote, formatting nobody has thought of), and chasing each shape is not the fix.

> agent (the root, 2026-09-23): "if the ticket body contains a `### Writer flags` heading anywhere, and the parser read zero flags from it, refuse and say so. That covers the fence and every other way the list can go unread, and it doesn't care which one it was. It stays silent on tickets that have no list."

> Manuel (2026-09-23): "go ahead"

Files: `template/.agents/skills/spec-review/scripts/review-brief.sh`, `tests/spec-review/review-brief.sh`.

## Acceptance criteria

- [ ] A ticket body that holds a writer flags heading line (table D's legend) anywhere, inside a fence or a quote or not, under which the check reads no flag is refused: exit 1, a message naming each such heading and saying no flags could be read, and no review state written.
- [ ] A ticket body with no writer flags heading line (table D's legend) briefs exactly as it does at #136's head, byte for byte.
- [ ] A ticket whose every writer flags heading line has a readable list behaves as at #136's head.
- [ ] No fence-specific or shape-specific parsing is added. The guard is the count rule above.

## Blocked by

PR #136 (it introduces the flag check). This stacks on the run-2 chain.


## Testing decisions

Posted by the agent 2026-09-23

### Legend

- Every row is a ticket body passed with `--ticket 7` on a diff that is not cross-cutting, the f column of #108's tables. The flag check runs as at #140's head first; the new guard runs only when that check printed nothing.
- **Heading line**: a line that, after any leading spaces and `>` quote markers, is one or more `#`, optional spaces, then `writer flags`, `writer-flags`, `writer flag` or `writer-flag` in any case, followed by the end of the line or a character that is not a letter. Matched on the raw body, with no fence or quote parsing.
- **Read**: the number of flag lines #136's parser reads from the body (every item record it prints, disposed or not).
- **B**: exit 0, both briefs and the review state written, byte for byte as at #140's head. **RF[x]**: #136's refusal, unchanged. **RZ[h]**: the new refusal: exit 1, no `.claude/state/review/`, no `.scratch/review/<id>/`, and stderr exactly `review-brief: ticket #7 has a writer flags heading and no flag could be read from its body; flags are read only under an unfenced, unquoted line that is exactly `### Writer flags <YYYY-MM-DD>`, one flag per line with its disposition; the headings found:` followed by each heading line `h`, indented two spaces, in text order.

### Table D: the guard

| # | The body | Heading lines | Read | Outcome |
|---|---|---|---|---|
| D1 | `### Writer flags 2026-09-23` with two settled flags (#108 A8) | 1 | 2 | B |
| D2 | `### Writer flags 2026-09-23` and nothing under it | 1 | 0 | RZ |
| D3 | #108 C6/f: a closed fence holding `### Writer flags 2026-09-23` and `1. bare` | 1 | 0 | RZ (was B) |
| D4 | an unclosed fence above `### Writer flags 2026-09-23` and a settled flag | 1 | 0 | RZ |
| D5 | inside a quote: `> ### Writer flags 2026-09-23`, `>`, `> 1. a accepted: ok` | 1 | 0 | RZ |
| D6 | hyphenated: `### Writer-flags 2026-09-23` and a settled flag | 1 | 0 | RZ |
| D7 | singular: `### Writer flag 2026-09-23` and a settled flag | 1 | 0 | RZ |
| D8 | a near-miss #136 already refuses: `### writer flags 2026-09-23` (#108 C4/f) | 1 | 0 | RF[`nm`], unchanged |
| D9 | no heading line: #108 C7/f's prose naming `Writer flags` inline | 0 | 0 | B, byte for byte |
| D10 | D1's list, then a second heading `### Writer-flags 2026-09-24` with a bare line | 2 | 2 | B |

### Contract

- The guard is a count: heading lines present and zero read refuses; anything else passes to what #140's head does. It names no fence, quote or other shape.
- It runs after #136's flag refusal, so every body #136 refuses keeps its exact stderr (#108 table B and C, f column).
- D3 changes #108's cell C6/f from B to RZ, because criterion 1 of this ticket refuses a heading inside a fence. It is the only cell of #90's, #93's, #106's, #107's, #108's tables or #137's criteria whose outcome changes.
- Accepted hole: D10. One readable list lets a second, unread list pass, since the rule counts the body, not each heading.

### Test list

`tests/spec-review/review-brief.sh`, in its own commit before the script: one assertion per row of table D, each named `(D<k>)`; C6/f's assertion moves to RZ. D9 asserts B with empty stderr; the byte-for-byte comparison with #140's script on the no-heading bodies (D9 and the fake's fixed body) is a verification run named in the PR, since #140's commit need not survive in the history the suite runs on. Every other assertion is unchanged.


Amended 2026-09-23 by the agent in #142 (review round 1, criterion 1): a heading written as a list item, `- ### Writer flags 2026-09-23` or `1. ### Writer flags 2026-09-23`, renders as a heading and was neither counted nor read. The Heading line now also allows list markers (`-`, `*`, `+`, or digits then `.` or `)`) among the leading spaces and `>` markers before the `#`. New row D11: `- ### Writer flags 2026-09-23` followed by an indented `1. bare`; heading lines 1, read 0, RZ. No other cell moves.


Amended 2026-09-23 by the agent in #142 (review round 2, criteria 1 and 2): a fenced shell comment `# writer flags are parsed here` in a body with no list was refused, against criterion 2, and a heading decorated between the hashes and the words (`### **Writer flags** 2026-09-23`, two spaces, a non-breaking space) was neither counted nor read. The Heading line now takes two or more `#` (a level-one `# Writer flags` is already refused by the P108 near-miss check), and any run of characters that are not letters may sit between the `#` run and `writer` and between `writer` and `flag`. New rows: D12, a fenced `# writer flags are parsed here` and no list; heading lines 0, read 0, B. D13, `### **Writer flags** 2026-09-23` and a settled flag; heading lines 1, read 0, RZ. D14, `### Writer  flags 2026-09-23` (two spaces) and a settled flag; heading lines 1, read 0, RZ. No other cell moves.


Amended 2026-09-23 by the agent in #142 (review round 3, criterion 1): a possessive or plural heading, `### Writer's flags 2026-09-23` or `### Writers flags 2026-09-23`, was neither counted nor read. The Heading line is now two or more `#` whose text, in any case, holds `writer` and later on the line `flag`, after any spaces, `>` quote markers and list markers. New rows: D15, `### Writer's flags 2026-09-23` over `1. bare`; heading lines 1, read 0, RZ. D16, `### Writers flags 2026-09-23` over a settled flag; heading lines 1, read 0, RZ. No other cell moves.

Amended 2026-09-23 by the agent in #142 (the root's verification of 30bdcae, criteria 1 to 3): the count is per heading line, not per body. A ticket gets a second `### Writer flags <date>` list whenever a second writer runs, and a hidden second list passed while the first list's flags made the body's count non-zero (D10, the hole #139 was filed against). Each read flag belongs to the nearest heading line above it, and every heading line needs at least one; the refusal names each heading line that has none. D10 moves from B to RZ naming `### Writer-flags 2026-09-24`. New rows: D17, two readable lists; B. D18, a fenced first list then a readable second; RZ naming the first heading only. Criteria reworded to match the legend. Old criterion 1: "contains the text `### Writer flags` anywhere, inside a fence or a quote or not, and from which the check reads zero flags is refused"; new: "holds a writer flags heading line (table D's legend) anywhere, inside a fence or a quote or not, under which the check reads no flag is refused", and the message names each such heading. Old criterion 2: "with no `### Writer flags` text"; new: "with no writer flags heading line (table D's legend)", since the legend counts lines such as `### Writer-flags` and ignores inline mentions. Old criterion 3: "a readable list"; new: "whose every writer flags heading line has a readable list".
