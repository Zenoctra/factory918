# Falsifiability pass for #91 (Ticket step 4), at base 52ccd8e (PR #99's head)

1. "For a cross-cutting diff, the Spec brief's `## Walk` rule requires, after the lines per documented step, one numbered line per risk under the grounding's Risks heading, each saying what the diff does at that risk."
   Fails today: `bash template/.agents/skills/spec-review/scripts/review-brief.sh HEAD~1 --blast-radius blast.md` on a hooks-touching commit writes a Spec brief whose Walk bullet ends at "count nothing." and says nothing about risks (`grep -c 'per risk' .scratch/review/HEAD_1/spec-brief.md` prints 0).
2. "`review-brief.sh` finds the Risks heading in both forms ...; it writes the rule only when a grounding is present, and `tests/spec-review/review-brief.sh` asserts both forms and the absent case."
   Fails today: the script has no Risks lookup (`grep -n Risks review-brief.sh` prints nothing); the test has no assertion naming a Risks heading.
3. "`review-comment.sh` still counts walk lines as steps, not items."
   Passes at HEAD already: `items()` skips `h == "Walk"`. Kept as a regression check (no code); noted for the human per the playbook: a criterion that already passes is a guard on the change, not work.
4. "The Opening a PR playbook's Blast Radius bullet (through its patch) says the inner headings are demoted to `###` when the file is pasted."
   Fails today: `grep -c '###' template/.agents/skills/poteto-mode/playbooks/opening-a-pr.md` on the Blast Radius bullet prints 0; the bullet says "verbatim".

One concern: how the Spec reviewer's walk is briefed for a cross-cutting diff, and how the grounding is pasted so the brief can find it. One PR.
