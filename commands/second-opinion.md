---
description: Get a second-opinion code review from another model via the Cursor Agent CLI, and optionally have that model fix what it found
argument-hint: [--model <alias>] [--fix [n,m]] [file-or-dir ...] (defaults to Grok 4.7 High Fast on the working diff)
allowed-tools: Bash(cursor-agent:*), Bash(git diff:*), Bash(git status:*), Bash(git ls-files:*), Bash(git rev-parse:*), Bash(git add:*), Bash(git write-tree:*), Bash(jq:*), Bash(mktemp:*), Bash(rm -f /tmp/second-opinion-*), Read, Grep
disable-model-invocation: true
---

# Second Opinion Review

Ask a different model to review code via the Cursor Agent CLI, then relay its findings. With `--fix`, send that model back to fix them, then check its work.

## Arguments

Raw arguments: `$ARGUMENTS`

Parse them yourself — everything is optional:

- `--model <x>`, `--model=<x>`, or `-m <x>` anywhere in the arguments selects the model. Strip the flag and its value; whatever remains is the scope.
- `--fix` switches to fix mode (see **Fix** below). It may be followed by a comma-separated list of finding numbers — `--fix 1,3` or `--fix=1,3`. Only consume the next token if it is that list, so a path after `--fix` stays a path.
- Everything after a literal `--` is a path, never a flag.
- If the user writes just `--models` (or `--list-models`), run `cursor-agent --list-models`, show the list, and stop. No review.
- Everything left over is files or directories to review.

### Model aliases

Resolve `<x>` against this table. It is a shorthand table, not a whitelist — an unrecognised value is passed to `--model` verbatim, so any model id the CLI accepts works. If `cursor-agent` rejects it, report the error and suggest `/second-opinion --models`.

| Alias | Model id |
|---|---|
| *(none)* | `grok-4.7-high-fast` — the default |
| `grok` | `grok-4.7-high-fast` |
| `sol` | `gpt-5.6-sol-high` |
| `terra` | `gpt-5.6-terra-high` |
| `kimi` | `kimi-k3-high` |

Append `-fast` to most ids for a faster, pricier variant (e.g. `gpt-5.6-sol-high-fast`).

`cursor-agent --list-models` prints a shorter list than the CLI actually accepts; the error message from a bad `--model` prints the full set.

If the chosen model is a Claude one, say so in the report — it is a same-family opinion, not a cross-model one.

## The cursor-agent session

The review runs in Cursor's default agent mode, not `--mode ask`, so that `--fix` can `--resume` the same chat and the model fixes its own findings with its reasoning still in context. A chat started with `--mode ask` stays read-only when resumed, and `--mode` has no write option to switch it back.

That means the review is read-only by instruction only. Commands on the user's Cursor allowlist (`~/.cursor/cli-config.json`) run without prompting, and that list can include `git commit`, `git checkout` or `rm`; anything else is rejected. So every `cursor-agent` run is bracketed by a snapshot:

```bash
IDX=$(mktemp -u /tmp/second-opinion-XXXXXX.idx)
cp "$(git rev-parse --git-path index)" "$IDX" 2>/dev/null
GIT_INDEX_FILE="$IDX" git add -A && GIT_INDEX_FILE="$IDX" git write-tree
rm -f "$IDX"
git rev-parse -q --verify HEAD
```

The first line printed is a tree of the whole working copy, untracked files included; the second is HEAD (empty in a repo with no commits). The user's real index is untouched. Shell variables do not survive between commands, so note both values yourself.

Outside a git work tree there is no snapshot: review with `--mode ask` instead, and refuse `--fix`.

Every run uses `--print --output-format json --trust`. `cursor-agent` exits 0 even when it rejects the model, and that error is plain text, not JSON: if the output starts with `Cannot use this model:`, report it and stop — do not retry with a different model on the user's behalf. Otherwise read `.result` and `.session_id` with `jq`.

## Review

1. **Resolve the scope.** If paths remain after parsing, review those and skip to step 2.

   Otherwise review the working diff. `git diff HEAD` misses untracked files, so add them explicitly:

   ```bash
   DIFF=$(mktemp /tmp/second-opinion-XXXXXX.diff)
   git diff HEAD > "$DIFF"
   git ls-files --others --exclude-standard | while IFS= read -r f; do
     git diff --no-index -- /dev/null "$f" >> "$DIFF" || true
   done
   wc -c < "$DIFF"
   ```

   If that comes back empty, fall back to the last commit — but only if there is one to compare against, since `HEAD~1` fails outright in a single-commit repo:

   ```bash
   git rev-parse --verify -q HEAD~1 >/dev/null && git diff HEAD~1 HEAD > "$DIFF"; wc -c < "$DIFF"
   ```

   Say which of the three you used. If the file is still empty, there is nothing to review — say so and stop without calling `cursor-agent`.

2. **Snapshot**, as above.

3. **Run the reviewer.**

   ```bash
   cursor-agent --print --output-format json --trust \
     --model <resolved-model-id> \
     "<prompt>"
   ```

   The prompt should:
   - Say this is a review only: do not edit files, and do not run commands that change anything.
   - Name the exact paths to review — files, directories, or the temp diff path.
   - Say what to prioritise, in order: correctness bugs, then security and data loss, then structural problems that will bite later. Not style, not naming, not nits.
   - Ask for findings ranked most-severe first, each one line: `severity — category: claim (file:line)`.
   - Say "Only high-conviction findings — report as many or as few as there genuinely are. A diff with one real problem should return one finding, not ten. List every high-conviction finding; do not pad the list to look thorough. No preamble, no summary, no restating the code. If nothing is wrong, say NO ISSUES."

   Allow up to 7 minutes; high and xhigh effort are slow. Do not stream partial output.

   Delete the temp diff once the reviewer has finished: `rm -f "$DIFF"`.

4. **Check it changed nothing.** Snapshot again. If the tree or HEAD differs, lead the report with that: show `git diff --stat <before> <after>` and the undo commands from **Fix** step 5. Do not undo anything yourself.

5. **Spot-check before relaying.** The reviewer has no context on this project and will produce plausible-but-wrong claims. Verify the 2–3 most concrete/severe findings against the real files with Grep or Read. Cheap checks only — do not re-review the whole scope yourself.

6. **Report.**
   - Open with one line naming the reviewer model id, the scope reviewed, and the `session_id` (so a later `--fix` can resume it).
   - Findings numbered and ranked most-severe first, each with its `file:line`.
   - Mark each verified one **Confirmed**, each contradicted one **Wrong** (with the one-line reason), and leave the rest as unverified reviewer claims.
   - Never present an unverified claim as fact.
   - Relay every finding, not just the verified ones. Say how many you spot-checked, so a long list is not read as a long list of confirmed problems.
   - Close with a one-line verdict: is anything here worth acting on before this ships. If something is, mention `/second-opinion --fix`.

## Fix

`--fix` sends a model back to fix findings from the most recent `/second-opinion` report in this conversation. If there is no such report, run **Review** first, then continue here.

1. **Pick the findings.**
   - `--fix` alone: every finding you can confirm. Verify the unverified ones first, with the same cheap checks as Review step 5. Skip **Wrong** ones and say which.
   - `--fix 1,3`: exactly those numbers, whatever their status. The user has overruled you; if you marked one **Wrong**, pass your reason along to the fixer, but still send it.
   - Nothing left to fix: say so and stop.

2. **Pick the session.** By default the fixer is the model that ran the review; `--resume <session_id>` that chat. If `-m` names a different model, or the session id is gone, start a new chat with that model instead and give it the findings in full.

3. **Snapshot**, as above.

4. **Run the fixer.**

   ```bash
   cursor-agent --print --output-format json --trust \
     --model <model-id> \
     [--resume <session_id>] \
     "<prompt>"
   ```

   Never `--force`. The prompt should:
   - List each finding to fix: its number, the claim, its `file:line`, and anything your verification found (the real cause, the right line, a reason you think it is wrong).
   - Say: fix only these; make the smallest change that fixes each; no refactors, renames, reformatting or unrelated fixes.
   - Say: do not commit, stage, stash, check out, reset or restore anything, and do not delete files unless a fix requires it.
   - Say: if a finding turns out to be wrong or cannot be fixed safely, skip it and say why.
   - Ask it to end with one line per finding: `N — fixed | skipped: what changed or why (file:line)`.

   Fixes can run longer than the Bash timeout, so run it in the background and wait for it to finish.

5. **Check the fix.** Snapshot again, then:

   ```bash
   git diff --name-status <before-tree> <after-tree>
   git diff <before-tree> <after-tree>
   ```

   Also compare HEAD with the value from step 3.

   Read the diff against the findings. For each finding: did the change fix it, fix it in part, or not touch it? Flag every hunk that does not belong to a listed finding. Do not trust the fixer's own summary over the diff.

   If the project has an obvious fast check that covers the touched files (a typecheck, a targeted test), run it. Otherwise say that none was run.

   Undo commands for the report. Restore files the fixer modified or deleted (`M` and `D` above), and remove files it added (`A`):

   ```bash
   git restore --source=<before-tree> --worktree -- <modified-or-deleted files>
   rm -- <added files>
   ```

6. **Report.**
   - Open with one line naming the fixer model id and whether it resumed the review chat.
   - HEAD changed? Lead with that.
   - Each finding, by number: **Fixed**, **Partly fixed**, **Not fixed** or **Skipped by fixer**, with `file:line` and one line on what changed.
   - Changes outside the listed findings, if any.
   - Whether a check ran, and its result.
   - The undo commands.
   - Close with a one-line verdict: keep, keep with changes, or undo.

## Constraints

- You never edit the code under review. In Review, relay; in Fix, the other model edits and you check. If its fix is wrong, report that rather than patching it, unless asked.
- One `cursor-agent` invocation per phase: one to review, one to fix.
- Never commit, and never undo anything yourself. Give the user the undo commands.
- Note that Cursor's CLI sends code to Cursor's API; skip this command for code that must not leave the machine.
