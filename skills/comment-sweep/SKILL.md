---
name: comment-sweep
description: Batched comment cleanup across a codebase or a directory, using the Comment Sicko agent. Surveys comment volume, proposes reviewable batches, and commits each one separately. Only runs when explicitly invoked.
argument-hint: "[path ...] | --diff   (no args = survey whole repo)"
disable-model-invocation: true
---

# Comment sweep

Comment cleanup at codebase scale, split into batches a human can actually review.

Requires the `Comment Sicko` agent. If `subagent_type: "Comment Sicko"` is unavailable,
stop and say so rather than improvising a substitute.

## Two modes

**Single pass.** If the scope is one directory under ~150 files, an explicit file list, or
the current diff, skip straight to section 4 and run it once. No survey, no batch plan, no
branch, no confirmation round. Say which mode you picked in one line, then get on with it.

**Sweep.** Anything larger, or no argument at all, runs the full survey and batch plan
below. This is the only safe way to handle thousands of comment lines, because the review
in step 4.2 is the part only a human can do and it does not scale past a few hundred files.

`/comment-sweep --diff` forces single pass on the working tree against the base branch.

## 1. Survey before proposing anything

**With no arguments, survey the whole repo.** Any paths the user passes are the scope
instead; skip discovery and survey only those.

Discover the source roots rather than assuming a layout:

- Read the agent instructions (`AGENTS.md`, `CLAUDE.md`) for a stated project structure.
- Otherwise take the top-level directories tracked by git, minus anything ignored:
  `git ls-files | grep / | cut -d/ -f1 | sort -u`
  (the `grep /` keeps directories only; without it you get top-level files too). Drop `docs`, `public`, `assets`, `scripts`,
  generated output and vendored code.
- In a monorepo, go one level deeper (`packages/*`, `apps/*`) so batches stay small.

Detect languages from the extensions actually present, and match comment syntax to them -
`//` and `/* */` for JS/TS/Swift/Java, `#` for Python/Ruby/shell, `<!-- -->` for markup.
Do not assume TypeScript.

Then, per directory, count comment lines and files. Something like, with the globs adapted:

    grep -rhoE '^\s*(//|/\*|\*)' "$d" --include='*.ts' --include='*.tsx' | wc -l
    find "$d" \( -name '*.ts' -o -name '*.tsx' \) | wc -l

Exclude generated files - anything gitignored, plus `*.gen.*`, `*.generated.*`, snapshots
and lockfiles. Deleting comments from generated code is churn that regenerates.

Also count suppressions (`@ts-ignore`, `@ts-expect-error`, `eslint-disable`). If there are
only a handful, say so - that half of the job is already done and should not be oversold.

## 2. Propose a batch plan, then stop

Show the survey as a table and propose batches. Rules:

- **Smallest first.** The first batch is a pilot: it calibrates how aggressive Sicko is on
  this codebase while the blast radius is small.
- **No batch over ~150 files or ~2,500 comment lines.** Split larger directories by
  subdirectory until they fit.
- **Order by risk, ascending.** Leave auth, payments, security and migrations until last.
- Never propose the whole codebase as one batch, however tempting.

State the total, the batch count, and that each batch is a separate commit. Wait for the
user to confirm or edit the plan. Do not start work off the back of the survey alone.

## 3. Set up

Confirm the working tree is clean; refuse to start if it is not. Create a branch
(`chore/comment-sweep` unless told otherwise). Identify the repo's check command from
`package.json` or the agent instructions - `pnpm ok`, `pnpm check`, `npm test`, whatever it
uses. If there isn't one, say so; the user is then reviewing without a safety net.

## 4. Per batch (single pass: just this section, once)

1. Spawn `Task` with `subagent_type: "Comment Sicko"`. Give it the batch scope and tell it
   to review every file in scope, not just changed files. Do not restate its rules.
2. Audit its report. Default to its judgement. Reject only: edits to application code
   rather than comments, anything outside the batch scope, and deletions whose stated
   reason is factually wrong. A comment survives ONLY with proof it documents something
   that cannot be changed - a library bug, an external API quirk, a legal or licence
   requirement. "It explains the code" is not proof. Where genuinely unsure, delete.
3. Apply the accepted deletions.
4. **Comments only by default.** Do not fix workarounds, change application code, or
   encode constraints as types or lint rules during a sweep - that makes the diff
   unreviewable. Collect those as open work and report them at the end. Only do them
   in-batch if the user explicitly asked for it.
5. Run the check command. If it fails, stop the sweep and report - do not continue into
   the next batch on a red tree.
6. Commit this batch alone: `chore(comments): sweep <scope>` with the deletion count in
   the body.
7. Report one line: scope, comments deleted, comments kept and why, check status.

Then move to the next batch. Between batches, ask whether to continue if the last batch
produced anything surprising.

## 5. Final report

- Total deleted, per batch
- Every comment kept, with the proof that saved it
- Workarounds found but not fixed, as a follow-up list
- Constraint comments that are still just prose, with the lint rule or type that would
  enforce each
- Suppressions reviewed and their verdicts
