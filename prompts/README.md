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

Comment cleanup used to live here as a snippet. It is now the `comment-sweep` skill, which
covers both a single pass and a batched sweep, so the snippet was redundant.

## Trialling a skill without installing it

    npx skills use cursor/plugins@no-comments

That prints the real SKILL.md wrapped in instructions. It works for any skill in any
indexed repo, and is a good way to trial one before adding it to the pool.
