<!-- lines: 40 | source: pages/deterministic-layer.md | part 8/12 | title: The Deterministic Layer (reference page) — Hooks, precisely -->

## Contents (line numbers are for the Read tool's offset)
- L8: Hooks, precisely
- L12: How Claude Code hooks work
- L38: Sticky mode, and why a hook stands in for it

## Hooks, precisely

Three unrelated things share the word. A **git hook** is a script git runs at a moment in its own workflow (pre-commit, pre-push); a non-zero exit aborts the operation. Theo's is one line, `vp staged`, which formats the staged files; Matt's skill installs a Husky one that formats, typechecks and tests. A **webhook** is GitHub calling a URL when something happens; ignore it for now. A **harness hook** is what you were asking about: a script Claude Code itself runs at one of its lifecycle events. Your guess was close but reversed. The agent does not choose to run a hook; the harness runs it whether the agent likes it or not, which is the point. That is what makes hooks part of this layer and not part of the prompt. primary

### How Claude Code hooks work

Configured in `.claude/settings.json` (project, shareable), `~/.claude/settings.json` (personal), a plugin's `hooks/hooks.json`, or a skill's frontmatter (registered when the skill is invoked and kept "for the rest of the session"). Each entry names an event, an optional matcher, and a handler. The official reference currently lists over thirty events; the ones you will use are `SessionStart` (a session begins or resumes), `UserPromptSubmit` (before Claude processes your prompt), `PreToolUse` (before a tool call; can block it), `PostToolUse` (after a tool call succeeds), `Stop` (when Claude finishes responding; can prevent it from stopping), and `WorktreeCreate`. A command hook receives JSON on stdin (`session_id`, `cwd`, `hook_event_name`, and for tool events `tool_name` and `tool_input`) and communicates back through its exit code and stdout. Exit 0 means proceed; for `SessionStart` and `UserPromptSubmit`, whatever the hook prints becomes context Claude can see. Exit 2 blocks, on the events that can block, "regardless of JSON content," and the stderr text becomes the message Claude sees. A hook can also print a JSON object with `hookSpecificOutput.permissionDecision: "deny"` and a reason. primary

The three hooks in your sources, read against that:

* **Matt's git guardrail** is a `PreToolUse` hook with `"matcher": "Bash"`. The script reads `.tool_input.command` with `jq`, greps it against a list (`git push`, `git reset --hard`, `git clean -f`, `git branch -D`, `git checkout .`, `git restore .`), and on a match prints "BLOCKED: '$COMMAND' matches dangerous pattern... The user has prevented you from doing this." to stderr and exits 2. The agent sees the message; the command never runs.
* **The pstack ports' mandate** is a `SessionStart` hook with `"matcher": "startup|clear|compact"` whose script does nothing but `cat` a markdown file. Because it is SessionStart and exits 0, the file's text is injected as context at the start of every session, after every `/clear`, and after every compaction. The text begins "`<EXTREMELY_IMPORTANT>` You have pstack. Before responding to any non-trivial engineering task... invoke the `pstack:poteto-mode` skill with the Skill tool and follow it."
* **A formatter hook**, the canonical example in the docs: `PostToolUse` with `"matcher": "Write|Edit"`, a script that reads `.tool_input.file_path` and runs `prettier --write` on it. This is a harness-side version of Theo's git hook: the file is formatted the moment the agent writes it, not at commit.

```
// .claude/settings.json  (project scope; commit it)
{
  "hooks": {
    "PreToolUse": [
      { "matcher": "Bash",
        "hooks": [ { "type": "command", "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/block-dangerous-git.sh" } ] }
    ],
    "PostToolUse": [
      { "matcher": "Write|Edit",
        "hooks": [ { "type": "command", "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/format.sh", "timeout": 30 } ] }
    ]
  }
}
```

### Sticky mode, and why a hook stands in for it

Cursor skills can carry `mode: true` plus a `reminder:` line in their frontmatter. A sticky skill, once invoked, re-applies on every later turn in that chat, and the reminder is what gets re-injected ("New task? Playbook match or rigor needed -> apply /poteto-mode. Casual turn or user opts out -> don't."). Only poteto-mode is sticky upstream. Claude Code has no sticky mode; a skill's content is attached to the conversation once when invoked and re-attached after compaction, but nothing re-asserts it turn by turn. The ports approximate stickiness with the SessionStart hook above: the mandate arrives at session start (and after clear and compact), tells the model to invoke the router for any non-trivial task, and the router then persists as ordinary skill content. That is what "Claude not having sticky mode is fixed by hooks" means. It is not identical (a Cursor reminder fires every turn; the hook fires at three moments), which is why both ports document how to delete `hooks/hooks.json` from the installed copy if you would rather invoke the router by hand. primary
