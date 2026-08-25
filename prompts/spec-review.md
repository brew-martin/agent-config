Review my changes against what was actually asked for. Not a bug hunt — /code-review covers that.

1. Diff: `git diff {argument name="base" default="main"}...HEAD` (three-dot, against the
   merge-base). Also read `git log {argument name="base"}..HEAD --oneline`.
2. Find the spec: issue refs in the commit messages (#123, Closes #45), else a plan or
   spec under docs/, plans/, or specs/ matching the branch. If there's genuinely none,
   say so and stop — don't invent one.
3. Report three lists, quoting the spec line for each finding:
   - MISSING — the spec asked for it, the diff doesn't do it
   - EXTRA — the diff does it, the spec never asked (scope creep)
   - WRONG — the diff does it, but not the way the spec described

Cite file:line for each. If a list is empty say so. Be specific over exhaustive; if the
spec is ambiguous on a point, say it's ambiguous rather than guessing which reading is right.

{cursor}
