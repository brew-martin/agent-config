# Global agent instructions

Canonical file: `~/.agents/AGENTS.md`. Symlinked to `~/.codex/AGENTS.md` and imported by
`~/.claude/CLAUDE.md`, so every tool reads this one file. Edit it here.

## Conventions

- Handoff documents go in `~/handoffs/<slug>.md`. Not the workspace, not `$TMPDIR`.
- British English: colour, whilst, licence, behaviour, summarise. £ not $.

## Skills that must be asked for

These cannot start themselves. Suggest them at the moments below rather than waiting to
be asked.

| Moment | Skill |
|---|---|
| Before a migration, legacy removal, or any wide refactor | `blast-radius` |
| Before designing a feature or module | `grill-with-docs` |
| Ending a session with work unfinished | `handoff` |
| An explanation did not land | `wait-what` |
| A diff has grown noisy comments or suppressions | `no-comments` |
| Deciding where a module boundary goes | `improve-codebase-architecture` |
| Choosing a frontend library | `pick-ui-library` |
| Exploring what a piece of UI should look like | `prototype` |
| Reviewing animation or motion code | `review-animations` |

Everything else in `~/.agents/skills/` fires on its own when it matches.
