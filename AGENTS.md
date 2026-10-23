# Global agent instructions

## Skills that must be asked for

These cannot start themselves. At the moments below, name the skill in one line and carry
on; the user decides whether to run it.

| Moment | Skill |
|---|---|
| A change could break code outside its diff: a migration, a removal, or a wide refactor | `blast-radius` |
| The user lays out a plan or design and wants it built | `grill-with-docs` |
| The user says they're stopping with work unfinished | `handoff` |
| Files or a diff are thick with redundant comments or lint suppressions | `comment-sweep` |
| The user asks where code should live, or a change keeps hitting shallow modules or logic scattered across files | `improve-codebase-architecture` |
| About to add a frontend dependency, or to hand-roll something a library covers, such as charts, OTP inputs, toasts, or drag and drop | `pick-ui-library` |
| The user is unsure what a piece of UI should look like | `prototype` |
| Animation or motion code is written or up for review | `review-animations` |
| A change that alters UI is finished or up for review | `interface-review` |
| The user shares a URL or screenshot and asks how it was built | `explain-interface` |

## File references

Write file links as full paths from the workspace root (`src/features/auth/LoginForm.tsx:42`)
or as absolute paths, because viewers resolve links from there.

## T3 Code tools

When the `t3-code` MCP tools are available:

- Do all browser work in the built-in browser: `preview_open`, then `preview_snapshot` to
  read the page. Playwright and chrome-devtools are for Lighthouse audits, performance
  traces and heap snapshots.
- When a site needs a login, ask the user to sign in in the built-in browser; the Default
  profile keeps the session. Passwords are entered by the user only.
- When a change that alters UI is finished, record it working with
  `preview_recording_start` / `preview_recording_stop` and embed the video in your reply.
