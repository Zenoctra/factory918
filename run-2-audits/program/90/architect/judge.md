# Cross-judge verdict: arena for ticket #90's design

Two candidates, read whole against the frame and the grounding. Candidate A is the base. It scores higher on the two criteria that decide whether the thing works at all — the restart derivation and the grammar — and its diff is the smaller one. Candidate B is the better-shaped document: its Table B keeps the two axes the ticket's rule 2 asks for, its prose-edit table names vendoring per file, and three of its choices (the babysit placement, the Ticket playbook's `### Design hole` section, the `restart:` line in the brief) are better answers than A's and should be grafted.

## Scores

| Rubric | A | B |
|---|---|---|
| 1. Coverage | 3 | 3 |
| 2. Cell completeness | 3 | 2 |
| 3. Derivation, idempotence, unambiguous restart | 3 | 2 |
| 4. One grammar per field, as a regex | 3 | 2 |
| 5. Babysit safety | 2 | 3 |
| 6. Smallest diff | 3 | 2 |
| **Total** | **17** | **14** |

### 1. Coverage — A 3, B 3

- **A 3.** Every criterion lands somewhere nameable: criterion 1 in the `SKILL.md` step 5 paragraph and the `review-ladder.md` rung-1 sentence; criterion 2 in `spec_rule` plus Table B rows 11–12; criterion 3 in rows B4–B9; criterion 4 in the Ticket step 8 sentence and Table A rows 5–8; criterion 5 in the `cites` regex and rows A14–A17; criterion 6 in the per-row test list; criterion 7 in the babysit sentence. Nothing reads a round above 3 or writes a `## Walk` line.
- **B 3.** Same coverage, and made checkable by the explicit **Criteria map** paragraph ("Criterion 1 → the rung-1 sentence and `SKILL.md` step 5 …"), plus Table B row 6, which reserves `## Walk` lines to #91 by name. No score above 3 exists, but this is the better presentation of the same coverage.

### 2. Cell completeness — A 3, B 2

- **A 3.** Every cell in both tables reads prints / exit / caller, and each refusal is quoted in full: rows B6, B7, B8, B9 and B11 each carry the whole `review-comment: …` message, and B12 says in words that it reuses B11's message because that message names the three forms.
- **B 2.** The cells are as complete and the Table B matrix (report item down the side, mark across the top) is the shape the ticket's rule 2 asks for — but **row 5 contradicts itself**. Row 5 column A admits a non-counted item that carries a `spec:` line ("unchanged from today / 0"); row 5 column D then claims that item's `hole:` is refused with "`but [S3] rests on ''`". Under B's own transitive rule the mark equals that `spec:` value, so the run is accepted and a hole is marked on an item that was never counted. The frame lists "`spec:` on an item that is not counted" as an input, so this is the exact cell the axis was built for. The empty-string message (`rests on ''`) is also not a message that says how to correct it, which the ladder's rung-1 sentence requires of a refusal.

### 3. Derivation without new state, idempotence, restart unambiguous — A 3, B 2

- **A 3.** One rule with no exceptions ("the history is what follows the last restart"), implemented as one awk that slices `bodies` between the fetch and both derivations, so neither the round awk (`:133-137`) nor the judged awk (`:154-157`) changes. I traced it: the raw-capture rule runs before `split`'s `next`, so the cut lands on the separator that closes the restart comment; `END { if (pending) cut = NR }` covers a `--previous` body with no trailing separator; the emptied `bodies` then gives `top=0` → `round: 1 of 3`, and `if [ -n "$bodies" ]` at `:154` suppresses the `settled:` line, exactly as row A5 and row A6 claim. Reruns read the same comments and print the same lines.
- **B 2.** The stated rule is as unambiguous ("the round is one more than the highest `round: N of 3` … among the comments that follow the last comment carrying a `restart` line"), but the awk written for it is wrong on the `gh` path, which is the only path that carries multi-comment histories. With `$0 == sep { if (rst) { top = 0; … } … r = 1; rst = 0; next }` and `END { if (rst) top = 0; else if (r > top) top = r; print top }`: after the restart comment's separator, `top=0`, `r=1`, `rst=0`; `gh` emits a separator after every body, so `END` re-raises `top` to 1 and the script prints `round: 2 of 3`. That contradicts B's own sentence "a restart comment posted last gives round 1" and rows 5, 6 and 8, and it fails criterion 4. It is a one-line fix, but the contract as written is wrong at its centre. The reset is also spread over `split`, two `END` blocks and a rewritten buffering `judged` awk, where A touches neither derivation.

### 4. One grammar per field, as a regex — A 3, B 2

- **A 3.** `ref='(table [^/ ]+/[^/ ]+|design [^ ].*|criterion [1-9][0-9]*)'` in both scripts, pinned equal by the test beside `fragment()`, and spelled out at all three use sites: `^spec: $ref$` for the report line, `hole: $ref$` `$`-anchored on the Act on line, and `#[0-9]+ '"$ref"'` as a fourth alternative inside the existing `cites` group. `criterion [1-9][0-9]*` rejects `criterion 0`, which A then names as a malformed input in rows A17 and B7.
- **B 2.** Same single `ref` and the same pin, and `[^[:space:]/]+` is the tighter character class (A's `[^/ ]+` admits a tab). But `criterion [0-9]+` accepts `criterion 0` while B's row A17 calls a k-less criterion malformed, so the grammar does not match the table; and the `hole:` field has no grammar check of its own — B enforces it "transitively" through the equality with `spec:`, which is what produces the row 5 hole above and a refusal message that quotes two strings instead of naming the three forms.

### 5. Babysit safety — A 2, B 3

- **A 2.** The danger is stated correctly (a restart comment can read `round: 3 of 3` and `act-on items: 0`, which is the exact sentence that makes a PR review-ready) and the sentence is added to both surfaces. But A adds it "appended to the paragraph" at `babysit.md:16` and "appended to the bullet" at `babysit/SKILL.md:40`, which rewrites the two lines the frame names ("leaving them byte-identical satisfies criterion 7"). A's own claim, "Everything before it is byte-identical, which is criterion 7", is a weaker guarantee than the one on offer.
- **B 3.** Same reasoning, and the sentence lands "as its own new paragraph after `babysit.md:16`" and "its own new bullet after `babysit/SKILL.md:40`, leaving those two lines untouched". B also says why the sentence is needed at all rather than only in rounds one and two: the missing-comment-on-the-latest-commit rule would catch a mid-restart PR only once the redesign landed.

### 6. Smallest diff — A 3, B 2

- **A 3.** "Files touched, with the reason" lists nine paths and says what each gets; the summary line is deliberately left alone, so none of the 18 exact-stdout `accept` cases per layout churn; `stepless()` becomes `lacking <file> <regex>` — the same awk with the literal regex parameterised — so a second scanner is added without a second copy of the fence rules; no new section in any playbook, `no-stale-wording.sh` untouched.
- **B 2.** The prose-edit table is better organised (it names the vendoring class per file), but the diff is larger for gains no criterion asks for: `, N a design hole` inside the summary parentheses churns every pinned `accept` string; a new printed `restart:` line in the brief; a new `### Design hole` section in `ticket.md`; a new entry in `no-stale-wording.sh`; and `stepless()` is *replaced* by `rests()`, which is left as `rests() { :; }   # TODO`, i.e. the one scanner the whole `spec:` and `hole:` contract rests on is unwritten.

## The base, and what to graft

**Base: candidate A.** Its restart derivation is the one that works, its grammar is the one that is checked where the frame asks it to be checked, and its diff is the one a reviewer can hold in mind. Graft these from B:

1. **The babysit placement** (B, "Babysit"): a new indented paragraph after `babysit.md:16` and a new bullet after `babysit/SKILL.md:40`, with B's sentence, so both `+` lines stay byte-identical. Replaces A's append-to-the-line edit.
2. **The `### Design hole` section in `ticket.md`** (B, its six numbered steps), parallel to `### Quick ticket`, carrying scope, `architect` Phase B with the artifact as grounding, two runners with the judge skipped on convergence, the dated amendment, tests rewritten from the amended artifact, review from round one, "only then step 9". Keep A's pointer *in step 8*, reworded to B's form: "A review comment carrying a `restart` line goes to **Design hole** below, not on to step 9." Criterion 4 has six moving parts; A's single sentence carries them all but as one 90-word sentence a lane has to parse under load.
3. **The `restart:` line in `review-brief.sh`'s output** (B, "One new printed line … between `ticket:` and `round:`"). It costs no pinned string — it prints only when a restart was seen — and without it A's design answers a much-reviewed PR with a bare `round: 1 of 3` and no `settled:` line, which reads as a bug. Keep A's suppression of the `settled:` line (below).
4. **The Criteria map paragraph** (B, "Criterion 1 → …"), verbatim in shape, so the finish condition is checkable from the package.
5. **Table B's two axes** (B's header row: report item down the side, `no mark` / `fixed:` / `ticket:` / `hole:` equal / `hole:` different / `hole:` malformed / `hole:` misplaced across the top). A's Table B is a flat list of situations; the ticket's rule 2 asks for inputs across the top. Fold A's rows 10, 14, 15, 16, 17 in as extra rows, and take B's **row 6** (`## Walk` lines are not items, #91 lands here and changes no cell).
6. **B's `--previous` risk** ("carries one comment body only unless the file holds literal RS bytes, so every restart test has to go through the fake `gh` path"), stated as a constraint on the whole test list rather than on one row.
7. **`[^[:space:]/]+` in `ref`** (B), keeping A's `criterion [1-9][0-9]*`.

Do **not** graft B's summary-line change (`, N a design hole`) unless the churn is wanted; see the disagreement below.

## Where the two disagree, and which answer is right

**Where `restart` prints.** No disagreement: both put it on its own line between the summary and `round: N of 3`, leaving `act-on items:` last. Right, and required — `SKILL.md:138`, `review-ladder.md:6`, `babysit.md:16` and `babysit/SKILL.md:40` all rest on the last line, and `review-comment.sh:157-158` prints those two lines last today.

*Sub-disagreement, the summary line.* A leaves `judged: act on N (x fixed, y with a ticket)` untouched; B makes it `(x fixed, y with a ticket, z a design hole)`. A is right on rubric 6 — the 18 exact-stdout cases per layout are pinned on that string — but B is right that A's comment then reads `act on 1 (0 fixed, 0 with a ticket)` above `act-on items: 0` with nothing in between to reconcile them. With graft 3 in place (a `restart` line in the comment and a `restart:` line in the brief) a reader has the answer, so A's choice stands; take B's four words only if the owner wants the count reconcilable from the summary alone, and pay the mechanical test churn knowingly.

*Sub-disagreement, the `settled:` line after a restart.* A prints none (its slice empties `bodies`, and `review-brief.sh:154` is guarded by `[ -n "$bodies" ]`); B prints `settled: carried 0, dropped 0 without a citation`. A is right: a restarted PR is defined as a PR whose history is what follows the restart, and a fresh PR prints no `settled:` line (row A1 and B's own row 1), so the two states should print alike.

**What a restart does to settled items.** Both drop everything raised before the last restart, and both say a decision worth keeping is cited again in the new round one. Right, and grounded: the carry is derived from the fetched comments only (`:154-157`), the citation forms exist precisely to re-settle an item (`SKILL.md:132`), and a citation to `#N table 2/D` points at the cell the restart is amending. A gets there by slicing the input; B by zeroing `n`, `seen` and `out` in the shared `split` action. A's is right — `split` is shared by both awks (it already carries `j = 0` for the judged awk, so B's approach is in keeping with the file's style, but it changes two derivations to achieve what one slice achieves without them).

**Whether `hole:` must equal the report item's `spec:`.** Both say yes. Right: the reviewer owns the anchor, the judgment sorts, and an off-shape report goes back to its reviewer, which is the existing route (`SKILL.md:140`, last sentence). The disagreement is in how it is enforced. A checks placement, grammar and equality separately, with three messages; B collapses grammar into equality, on the argument that the `spec:` value was already grammar-checked. **A is right**, for three reasons: B's collapse leaves the uncounted-item-with-a-`spec:`-line case accepted (its own row 5); B's malformed-`hole:` message quotes two strings where the reviewer needs the three forms; and rubric 4 asks for the `hole:` grammar as a regex the scripts use, which under B exists only in the counting grep.

**Where the Ticket playbook's return-to-architect text sits.** A puts it in step 8, after "Then run **Opening a PR**"; B puts a diverting sentence in step 9 and the procedure in a new `### Design hole` section. Checked against the grounding: `spec-review` is run from `opening-a-pr.md:9` ("After CI is green, run `spec-review` in a fresh context"), which is reached from `ticket.md:12` step 8; step 9 is babysit, and `babysit.md:16` only re-reads the posted comment. So the restart is discovered inside step 8, and A's placement is the grounded one — B's premise that the diversion happens on the way to babysit is true only of the second reading of the same comment. The right answer is both halves: A's placement for the pointer, B's section for the procedure (graft 2). Neither renumbers a step, which the frame forbids.

**Whether babysit prose changes.** Both change it, with the same substance, for the same reason (a hole marked in round three prints `round: 3 of 3` and `act-on items: 0`, which is the exact shape the existing sentence calls review-ready). B's placement is right: new paragraph and new bullet, `babysit.md:16` and `babysit/SKILL.md:40` byte-identical, which is the route the frame names for criterion 7.

## Cells that contradict a fact in the frame's "Facts from the grounding"

- **B, the round derivation.** The frame's `:133-137` fact ("`BEGIN { r = 1 }` so any fetched comment forces round 2 or more") is exactly what B's `END { … else if (r > top) top = r }` re-triggers after its reset, so rows 5, 6, 7 and 8 of Table A print a round one higher than they claim on the `gh` path. The only contradiction of contract-grade weight in either package.
- **B, Table B row 5.** Column A admits a non-counted item carrying a `spec:` line; columns D–F then claim a refusal that B's single equality check does not produce for that item. The frame lists "`spec:` on an item that is not counted" as an input, so the case is in scope.
- **A, the babysit edit.** Not a contradiction, but a declined fact: the frame says leaving `babysit.md:16` and `babysit/SKILL.md:40` byte-identical satisfies criterion 7, and A rewrites both lines instead. Fixed by graft 1.
- No other cell in either package conflicts with a stated fact. I re-read `review-brief.sh:94`, `:107-143`, `:151-160`, `:240-243`, `:310-356`, `review-comment.sh:40-100`, `:118-165`, `ticket.md`, `babysit.md:16`, `babysit/SKILL.md:40`, `review-ladder.md:6` and `SKILL.md:25,84,124-141`; every line number, anchor and quoted string both candidates lean on is accurate.

## Acceptance criteria neither candidate covers

- **Criterion 3, the `act-on items:` definition in `SKILL.md` step 6.** Line 138 reads "where N is the number of items under `## Act on` without a `fixed:` or `ticket:` field plus the number under `## Ask`". Both candidates change step 6 for the `restart` line and the new refusals, and both state elsewhere that a hole leaves the item out of the count (A's step 5 bullet, B's step 5 bullet), but neither names the edit that makes that sentence true. It is a patched `+` line, so it costs a patch hunk; add "`fixed:`, `ticket:` or `hole:`" to the implementation list.
- Nothing else. Criteria 1, 2, 4, 5, 6 and 7 each map to a cell or a named prose edit in both packages, and neither depends on #91 or #93.

Two smaller gaps worth carrying into implementation: `review-brief.sh`'s round-rule header comment (`:126-129` in the file, the paragraph above `top=0`) states the derivation in prose and must gain the restart clause — A says so, B does not; and B's `rests()` is a `TODO` stub, so if any of B's scanner reasoning is grafted it has to be written out first.
