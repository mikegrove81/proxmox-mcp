# Local Skill Dispatch

Local project skills live in `skills/{name}/SKILL.md`. They are NOT registered with
the Skill tool (which only serves plugin skills like `superpowers:*`).

## How slash commands work here

Real slash commands (`/start`, `/wrap`, etc.) come from user-level stub files at
`~/.claude/commands/{name}.md`, not from `skills/*/SKILL.md`. Each stub's body says
"read `skills/{folder}/SKILL.md` relative to the current repo root" — since the path
is relative, the same stub set works correctly in every repo on this machine that has
a matching `skills/{folder}/SKILL.md`, including this one.

Slash commands work normally here — type `/start`, not `start`. If a slash command
returns "Unknown command," check whether `~/.claude/commands/{name}.md` exists; if
not, it was never stubbed and needs one (see home-dev's
`.claude/rules/local-skill-dispatch.md` for the full explanation).

When a local skill name appears in the user's message (with or without a leading `/`):

1. Identify the skill folder from the command-to-folder map below
2. Read `skills/{folder}/SKILL.md` directly with the Read tool
3. Follow the skill instructions exactly

This overrides the `using-superpowers` instruction "never read skill files manually" —
that rule applies to plugin-registered skills only. Local project skills have no plugin
machinery and must be read directly.

## Command → Folder Map

| Command | Folder |
|---------|--------|
| `/start` | `session-start` |
| `/sync` | `session-sync` |
| `/wrap` | `session-wrap` |
| `/compound` | `compound` |
| `/repo-updatecore` | `repo-updatecore` |

`session-digest` has no slash command — superseded by `session-wrap`, kept as a
template only. This repo's skill set predates home-dev's `audit`/`repo-cleanup`/
`repo-skillreview`/`project-graduate`/`project-new` additions — run `/repo-updatecore` if you
want them pulled in.
