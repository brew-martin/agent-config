# Global agent instructions

Canonical file: `~/.agents/AGENTS.md`. Symlinked to `~/.codex/AGENTS.md` and imported by
`~/.claude/CLAUDE.md`, so those tools read this one file. Edit it here.

Cursor is the exception: its global rules are app config, not a file. `sync.sh` flattens
this file into `cursor-user-rule.txt`, which is pasted by hand into Cursor's Customize
panel > Rules > User Rules. Re-paste it when `sync.sh` says it changed.

## Skills that must be asked for

These cannot start themselves. Suggest them at the moments below rather than waiting to
be asked.

| Moment | Skill |
|---|---|
| Before a migration, legacy removal, or any wide refactor | `blast-radius` |
| Before designing a feature or module | `grill-with-docs` |
| Ending a session with work unfinished | `handoff` |
| A diff has grown noisy comments or suppressions | `comment-sweep` |
| Deciding where a module boundary goes | `improve-codebase-architecture` |
| Choosing a frontend library | `pick-ui-library` |
| Exploring what a piece of UI should look like | `prototype` |
| Reviewing animation or motion code | `review-animations` |
| Reviewing a change's interface quality rather than its correctness | `interface-review` |
| Asking how an interface you can see was built | `explain-interface` |

Everything else in `~/.agents/skills/` fires on its own when it matches.
