# Global agent instructions

## Skills that must be asked for

These cannot start themselves. At the moments below, name the skill in one line and carry
on; the user decides whether to run it.

| Moment | Skill |
|---|---|
| A change could break code outside its diff: a migration, a removal, a wide refactor, or a small diff you don't fully trust | `blast-radius` |
| The user lays out a plan or design and wants it built | `grill-with-docs` |
| The user says they're stopping with work unfinished, or the context is nearly full | `handoff` |
| Files or a diff are thick with redundant comments or lint suppressions | `comment-sweep` |
| The user asks where code should live, or a change keeps hitting shallow modules or logic scattered across files | `improve-codebase-architecture` |
| About to add a frontend dependency, or to hand-roll something a library covers, such as charts, OTP inputs, toasts, or drag and drop | `pick-ui-library` |
| The user is unsure what a piece of UI should look like | `prototype` |
| Animation or motion code is written or up for review | `review-animations` |
| A change that alters UI is finished or up for review | `interface-review` |
| The user shares a URL or screenshot and asks how it was built | `explain-interface` |

## File references

Write file links as full paths from the repo root (`src/features/auth/LoginForm.tsx:42`)
or as absolute paths. Viewers resolve links against the workspace root, so the path has
to be complete from there.
