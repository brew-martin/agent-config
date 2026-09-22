---
description: Get a second-opinion code review from another model via the Cursor Agent CLI
argument-hint: [--model <alias>] [file-or-dir ...] (defaults to Cursor Grok 4.6 Extra High on the working diff)
allowed-tools: Bash(cursor-agent:*), Bash(git diff:*), Bash(git status:*), Bash(git ls-files:*), Bash(git rev-parse:*), Bash(mktemp:*), Bash(rm -f /tmp/second-opinion-*), Read, Grep
disable-model-invocation: true
---

# Second Opinion Review

Ask a different model to review code via the Cursor Agent CLI, then relay its findings.

## Arguments

Raw arguments: `$ARGUMENTS`

Parse them yourself — everything is optional:

- `--model <x>`, `--model=<x>`, or `-m <x>` anywhere in the arguments selects the reviewer. Strip the flag and its value; whatever remains is the scope.
- Everything after a literal `--` is a path, never a flag.
- If the user writes just `--models` (or `--list-models`), run `cursor-agent --list-models`, show the list, and stop. No review.
- Everything left over is files or directories to review.

### Model aliases

Resolve `<x>` against this table. It is a shorthand table, not a whitelist — an unrecognised value is passed to `--model` verbatim, so any model id the CLI accepts works. If `cursor-agent` rejects it, report the error and suggest `/second-opinion --models`.

| Alias | Model id |
|---|---|
| *(none)* | `cursor-grok-4.7-high` — the default |
| `grok` | `cursor-grok-4.7-high` |
| `sol` | `gpt-5.6-sol-high` |
| `terra` | `gpt-5.6-terra-high` |
| `kimi` | `kimi-k3-high` |

Append `-fast` to most ids for a faster, pricier variant (e.g. `gpt-5.6-sol-high-fast`).

`cursor-agent --list-models` prints a shorter list than the CLI actually accepts; the error message from a bad `--model` prints the full set.

If the chosen model is a Claude one, say so in the report — it is a same-family opinion, not a cross-model one.

## Steps

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

2. **Run the reviewer.** Read-only mode (`--mode ask`) so it cannot edit anything:

   ```bash
   cursor-agent --print --output-format text --trust \
     --model <resolved-model-id> \
     --mode ask \
     "<prompt>"
   ```

   The prompt should:
   - Name the exact paths to review — files, directories, or the temp diff path.
   - Say what to prioritise, in order: correctness bugs, then security and data loss, then structural problems that will bite later. Not style, not naming, not nits.
   - Ask for findings ranked most-severe first, each one line: `severity — category: claim (file:line)`.
   - Say "Only high-conviction findings — report as many or as few as there genuinely are. A diff with one real problem should return one finding, not ten. List every high-conviction finding; do not pad the list to look thorough. No preamble, no summary, no restating the code. If nothing is wrong, say NO ISSUES."

   Allow up to 7 minutes; high and xhigh effort are slow. Do not stream partial output.

   `cursor-agent` exits 0 even when it rejects the model, so check the output: if it starts with `Cannot use this model:`, that is an error, not a review. Report it and stop — do not retry with a different model on the user's behalf.

   Delete the temp diff once the reviewer has finished: `rm -f "$DIFF"`.

3. **Spot-check before relaying.** The reviewer has no context on this project and will produce plausible-but-wrong claims. Verify the 2–3 most concrete/severe findings against the real files with Grep or Read. Cheap checks only — do not re-review the whole scope yourself.

4. **Report.**
   - Open with one line naming the reviewer model id and the scope reviewed.
   - Findings ranked most-severe first, each with its `file:line`.
   - Mark each verified one **Confirmed**, each contradicted one **Wrong** (with the one-line reason), and leave the rest as unverified reviewer claims.
   - Never present an unverified claim as fact.
   - Relay every finding, not just the verified ones. Say how many you spot-checked, so a long list is not read as a long list of confirmed problems.
   - Close with a one-line verdict: is anything here worth acting on before this ships?

## Constraints

- Do not fix anything unless asked. Relay the review; that is the whole job.
- One `cursor-agent` invocation per run.
- Note that Cursor's CLI sends code to Cursor's API; skip this command for code that must not leave the machine.
