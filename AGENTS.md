# Global agent instructions

## Skills that must be asked for

These cannot start themselves. At the moments below, name the skill in one line and carry
on; the user decides whether to run it.

| Moment | Skill |
|---|---|
| A change could break code outside its diff: a migration, a removal, or a wide refactor | `blast-radius` |
| The user lays out a plan or design and wants it built | `grill-with-docs` |
| Files or a diff are thick with redundant comments or lint suppressions | `comment-sweep` |
| The user asks where code should live, or a change keeps hitting shallow modules or logic scattered across files | `improve-codebase-architecture` |
| About to add a frontend dependency, or to hand-roll something a library covers, such as charts, OTP inputs, toasts, or drag and drop | `pick-ui-library` |
| The user is unsure what a piece of UI should look like | `prototype` |
| Animation or motion code is written or up for review | `review-animations` |
| A change that alters UI is finished or up for review | `interface-review` |
| The user shares a URL or screenshot and asks how it was built | `explain-interface` |

## Council members

When `council` runs, seat the newest flagship from each of these providers: Claude Opus,
GPT Sol (through Copilot or Cursor) and Gemini Pro or Argon (through Copilot, else Cursor).
Antigravity offers only Gemini Flash, so do not seat Gemini through it.

## File references

Write file links as full paths from the workspace root (`src/features/auth/LoginForm.tsx:42`)
or as absolute paths, because viewers resolve links from there.

## Shared agent Chrome

chrome-devtools and every browser script share one long-running Chrome at
`http://127.0.0.1:9222` (`agent-chrome` in the README), whose profile keeps sign-ins.
Scripts attach with Playwright's `chromium.connectOverCDP('http://127.0.0.1:9222')` and
close only the pages they opened. When a site there needs a login, ask the user to sign in
in that window. A project's own Playwright test suite runs with its own config.

## T3 Code tools

When the `t3-code` MCP tools are available:

- Do all browser work in the built-in browser: `preview_open`, then `preview_snapshot` to
  read the page, `preview_evaluate` for anything page JavaScript can read. chrome-devtools
  covers only what the built-in browser lacks: performance traces, heap snapshots, CPU or
  network throttling, media-feature emulation (reduced motion, contrast, forced colors),
  mobile emulation (touch, pixel ratio, user agent) and network inspection. Lighthouse
  audits run from the CLI in the README.
- chrome-devtools is also the fallback for one step. When a built-in browser call fails,
  retry it once (after `preview_wait_for`, or a snapshot without the image); if it fails
  again, do that step in chrome-devtools, say so, and return to the built-in browser for
  the next step.
- When a site needs a login, ask the user to sign in in the built-in browser; the Default
  profile keeps the session. Passwords are entered by the user only.
- When a change that alters UI is finished, set the viewport to 1440×900 with
  `preview_resize`, record it working with `preview_recording_start` /
  `preview_recording_stop` and embed the video in your reply.
