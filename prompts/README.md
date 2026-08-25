# Prompts

Paste-able prompts for jobs that do not justify an installed skill. Saved as Raycast
snippets; kept here so they survive a new machine and stay editable in one place.

Raycast placeholders used:
- `{argument name="x" default="y"}` - prompts for a value in the search bar. Same name
  used twice means it is entered once and filled in both places.
- `{cursor}` - where the cursor lands after expansion.

| File | Raycast keyword | What it is for |
|---|---|---|
| `spec-review.md` | `specreview` | Does the diff match what the issue or plan asked for? |
| `no-comments.md` | `nocomments` | Adversarial comment cleanup via the Comment Sicko agent |

## no-comments

Distilled from pstack's `no-comments` skill, which was installed and then removed as too
heavy to keep. The `Comment Sicko` agent it spawns IS still installed
(`~/.agents/agents/comment-sicko.md`) - the prompt will not work without it.

To run the full original skill instead, without installing it:

    npx skills use cursor/plugins@no-comments

That prints the real SKILL.md wrapped in instructions. It works for any skill in any
indexed repo, and is a good way to trial one before adding it to the pool.
