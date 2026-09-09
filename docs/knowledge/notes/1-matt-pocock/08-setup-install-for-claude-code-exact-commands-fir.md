<!-- lines: 30 | source: notes/1-matt-pocock.md | part 8/10 | title: Research note: Matt Pocock — Setup & install for Claude Code (exact commands, first-run steps) -->

## Contents (line numbers are for the Read tool's offset)
- L6: Setup & install for Claude Code (exact commands, first-run steps)

## Setup & install for Claude Code (exact commands, first-run steps)

1. **Install the plugin (recommended for a beginner: read-only, auto-updating).**
   ```bash
   claude plugins install mattpocock-skills
   ```
   or, inside a session:
   ```
   /plugin install mattpocock-skills
   ```
   "It's in Claude Code's official marketplace, so there's nothing to add first, and updates arrive automatically." ([README.md](research/1-matt-pocock/skills-repo/README.md)) If the in-session install reports `Run /reload-plugins to activate.`, run `/reload-plugins` ([Claude Code docs](https://code.claude.com/docs/en/discover-plugins)). The documented example form in Claude's docs is `/plugin install <name>@claude-plugins-official`. Do **not** also run the skills.sh installer ("installing both leaves you with every skill twice").

   *Alternative (editable copies, also the only way to get beta skills):* `npx skills@latest add mattpocock/skills` (choose skills; "make sure `setup-matt-pocock-skills` is one of them"), later `npx skills update`. One beta skill: `npx skills@latest add mattpocock/skills --skill=implement-spec`.

2. **Prerequisites to have on the machine:** Node.js (for `npx skills`, only if using skills.sh); `gh` CLI authenticated if the repo uses GitHub Issues (`glab` for GitLab); nothing for local-markdown tracking. Create the triage labels yourself on a fresh GitHub repo (`gh label create needs-triage` etc.) because setup only writes the *mapping* ([docs page](research/1-matt-pocock/skills-repo/docs/engineering/setup-matt-pocock-skills.md)).

3. **Run once per repo:** `/setup-matt-pocock-skills`. It will "Ask you which issue tracker you want to use (GitHub, Linear, or local files); Ask you what labels you apply to tickets when you triage them; Ask you where you want to save any docs we create" ([README.md](research/1-matt-pocock/skills-repo/README.md)). For a solo beginner with no remote, "Local markdown" is fully supported. Confirm the draft it shows, then check that `docs/agents/issue-tracker.md`, `docs/agents/domain.md` and an `## Agent skills` block in `CLAUDE.md` exist.

4. **First real run.** In a fresh session, with a rough idea, type `/grill-with-docs` (not plan mode). Answer the rounds. Stay in the same window. If small, `/implement`; if multi-session, `/to-spec`, then `/to-tickets`, then `/clear`, then `/implement <ticket ref>` per ticket (pass full refs like `owner/repo#2` or the `.scratch/.../issues/01-*.md` path). Close tickets yourself afterwards. If unsure at any point, `/ask-matt`.

5. **Optional global `CLAUDE.md` lines people use:** "When grilling, ask one question at a time." (supported opt-out); an instruction not to implement without permission (for weaker models); a line saying browser/e2e tests are written after behaviour works (tdd docs).

6. **Skill naming under the plugin:** Claude Code namespaces plugin skills (`/mattpocock-skills:grill-with-docs`); unqualified `/grill-with-docs` also resolves in practice, which is why the built-in `/code-review` gets shadowed ([docs/engineering/code-review.md](research/1-matt-pocock/skills-repo/docs/engineering/code-review.md)). If a user-invoked skill is reported "not installed" on the Claude desktop/web surfaces, that is issue #693 — type it anyway or use the terminal CLI.

---
