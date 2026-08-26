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
the current diff, skip straight to section 4 and run it once. No batch plan, no branch. Do
still count the comment lines in scope: the kill-rate gate in step 4.6 applies here exactly
as it does in a sweep, and it needs the denominator. Say which mode you picked in one line,
then get on with it.

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

    grep -rhoE '^[[:space:]]*(//|/\*|\*)' "$d" --include='*.ts' --include='*.tsx' | wc -l
    find "$d" \( -name '*.ts' -o -name '*.tsx' \) | wc -l

Use `[[:space:]]`, not `\s`. `git grep -E` does not understand `\s` and silently reports
roughly a sixteenth of the real count, which makes a batch look small enough to skip.

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
2. Audit its report. The keep list lives in `~/.agents/agents/comment-sicko.md` and
   nowhere else - read it if you do not already have it, and keep no second copy here. A
   divergent copy silently overrules the agent.

   Accept its confident kills. Decide every kill it branded `UNSURE` yourself, and keep
   the ones a clause plausibly covers: Sicko deletes on doubt precisely so this step can
   rescue, and this is the only thing between a sweep and a scorched-earth diff. Reject
   outright three things - edits to application code rather than comments, anything
   outside the batch scope, and deletions whose stated reason is factually wrong.

   Check reasons in both directions. A comment that argues for its own survival is making
   a claim, and a suppression's excuse is the only thing between its rule and the bug that
   rule catches - read every surviving suppression against what its rule actually fires on.
   A false excuse for keeping is exactly as wrong as a false reason for deleting, and it is
   the one the sweep is built to miss.
3. Apply the accepted deletions.
4. **Comments only by default.** Do not fix workarounds, change application code, or
   encode constraints as types or lint rules during a sweep - that makes the diff
   unreviewable. Collect those as open work and report them at the end. Only do them
   in-batch if the user explicitly asked for it.
5. Run the check command. If it fails, stop the sweep and report - do not continue into
   the next batch on a red tree.
6. Work out the kill rate: comments deleted as a percentage of the batch's comment lines.
   Above 60%, show the user before committing. This is what the pilot batch was for - the
   rate they accept there becomes the expected rate, and a later batch far above it is a
   reason to stop rather than to press on.
7. Commit this batch alone: `chore(comments): sweep <scope>` with the deletion count in
   the body.
8. Report one line: scope, comments deleted, kill rate, comments kept and why, check
   status.

Then move to the next batch. Between batches, ask whether to continue if the last batch
produced anything surprising.

## 5. Final report

- Total deleted and the kill rate, per batch
- Every comment kept, with the clause that saved it
- Every `UNSURE` kill rescued at audit, so the next sweep can be tuned
- Workarounds found but not fixed, as a follow-up list
- Constraint comments that are still just prose, with the lint rule or type that would
  enforce each
- Suppressions reviewed and their verdicts
