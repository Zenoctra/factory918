## Would break

## Fails open

## Standards breaches

## Fix alongside

1. **The Ticket playbook now asks for a shape the skill it cites does not produce.** Step 5 says to write the result "in that skill's hand-back shape" and then adds a different shape on top of it: `## ` headings and numbered lines. `template/.agents/skills/blast-radius/SKILL.md:43` hands back bullets (`- **Risks.** Only the real ones. ...`), which is what the old text meant and what the test's `blast.md` fixture still is. An author who reads the blast-radius skill, as step 5 tells them to, writes a file `review-brief.sh` refuses; the refusal names the correction, so the path is recoverable, but the two documents now disagree in writing. Worth one clause in step 5 saying the headings are a reshaping of the skill's bullets, not its own shape.

   ```
   after `how`, run `blast-radius` over it and write the result to `.scratch/<ticket>/blast-radius.md` in that skill's hand-back shape (what it does; the one fact it is safe because of and how far it was proven; risks; cleared; before you merge), each part under a `## ` heading and one numbered risk per line under `## Risks`
   ```

2. **Two refusals in one branch, the same four lines twice.** `review-brief.sh`'s grounding check now has a second `rm -rf "$dir"` / message / `exit 1` block directly under the first. Mild Duplicated Code: the pair is short enough to leave, but if a third grounding rule lands, the cleanup wants to be one function.

   ```sh
   if ! printf '%s\n' "$grounding" | awk '{ sub(/\r$/, ""); sub(/[ \t]+$/, "") }'"$fenced"'
       $0 == "## Risks" || $0 == "### Risks" { found = 1; exit }
       END { exit !found }'; then
     rm -rf "$dir"
   ```

Checked and clean: the awk risk check quotes `$grounding` and `$fenced`, strips `\r` and trailing blanks, reuses the file's one fence rule, and gives the same answer under BSD and GNU awk (`exit` in a main rule runs `END`, whose `exit !found` decides); both new refusals run before `.claude/state/review` exists, matching the existing missing-grounding refusal; the `# shellcheck disable=SC2016` at the top of each changed script still carries its reason on the same line; `risk_rule` is pinned word for word in the script, `SKILL.md`, the patch and the test, so the four cannot drift; `docs/knowledge/INDEX.md`'s `95` matches `wc -l docs/knowledge/core/DECISIONS.md`; the tool fact went to `docs/M0-findings.md` with its date, the surprises to `docs/agents/ledger.md`, and P26 and P27 to `DECISIONS.md` under Provisional.

hard findings: 0
