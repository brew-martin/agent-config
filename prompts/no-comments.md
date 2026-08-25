Clean the comments out of {argument name="scope" default="the diff against main, including the working tree"}.

Step 1 — Spawn a Task with subagent_type "Comment Sicko". Pass it the scope. Do not
restate its rules; it has its own. It returns a report of what it wants deleted.

Step 2 — Audit its report before applying anything. I wrote or accepted these comments,
so default to its judgement, not mine. Reject only:
- edits to application code rather than comments
- anything outside the scope above
- deletions whose stated reason is factually wrong
A comment survives ONLY with proof it documents something we cannot change — a library
bug, an external API quirk, a legal or licence requirement. "It's explaining the code" is
not proof; if the code needs explaining, the code is the problem. Where you are unsure,
delete. Also sweep any `@ts-ignore`, `@ts-expect-error` or `eslint-disable` in scope:
each is either load-bearing with a named reason, or it goes.

Step 3 — Where a comment was apologising for a workaround, fix the workaround rather than
just deleting its excuse. Smallest root-cause fix that stays inside the scope. If the real
fix is out of scope, make the smallest in-scope change and list the rest as open work.
Never swap a comment for a defensive guard.

Step 4 — For constraint comments (`do not remove`, `do not change wording`, `talk to X
first`): propose the cheapest way to encode that constraint as a type, a test, or a lint
rule, then delete the comment. Ask me before applying any of these. If I decline, delete
the comment anyway and note the constraint as unenforced.

Finally — report: how many comments deleted, anything you restored and why, root-cause
fixes made, encodings proposed or applied, constraints now unenforced, and open work.

{cursor}
