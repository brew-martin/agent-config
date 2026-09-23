---
description: Review the current branch with Jev, verify each finding against the code, and report what is real
argument-hint: [--fix] [--staged | --pr <ref>] [any jev-review flag] (defaults to the whole branch)
allowed-tools: Bash(jev-review:*), Bash(git diff:*), Bash(git status:*), Bash(git log:*), Bash(git rev-parse:*), Read, Grep, Edit
disable-model-invocation: true
---

# Jev Review

Run `jev-review` over this branch, then do the one thing the CLI cannot: check each finding against the whole file before repeating it.

Jev sees the diff plus 8 lines of context, or 3 in `--pr` mode. You can read the file. That gap is the reason this command exists — "`user` may be null" is often wrong because the guard sits thirty lines up, outside the diff.

## Arguments

Raw arguments: `$ARGUMENTS`

- `--fix` is yours, not the CLI's. Strip it before running. It means: after reporting, apply fixes for every **confirmed** high and medium finding.
- Everything else passes through verbatim. Common ones: `--staged`, `--pr <ref>`, `--base <ref>`, `--threshold <p>`, `--verbose`, `--post`.
- No arguments: the whole branch — commits since the merge base, plus staged, unstaged and untracked files.

## Steps

1. **Run it.** Always `--format json`, plus whatever survived parsing:

   ```bash
   jev-review --format json <passthrough-args>; echo "exit=$?"
   ```

   **Exit 1 means findings were reported, not that the command failed.** Only exit 2 is an error. If it exits 2, report the message and stop: a missing `TYPESAFE_API_KEY` or an unauthenticated `gh` are setup problems, not review results, and retrying will not fix either.

   The JSON gives you `verdict` (`clean` | `minor` | `needs_attention` | `blocking`), `findings[]`, and `possible[]` — findings below the reporting threshold, shown only with `--verbose`. Each finding carries `path`, `line` (or `startLine`–`line` when Jev could not pin one line), `severity`, `title`, `message`, `check`, and `probability`.

   If `verdict` is `clean` and `findings` is empty, say so in one line and stop. Do not go looking for problems Jev did not find — a clean run is a result.

2. **Verify before you repeat any of it.** For each finding, read the file around the line with enough context to actually settle the question, then judge:

   - **Confirmed** — the problem is real in the full file.
   - **Wrong** — the wider file disproves it. Say what disproves it, in one clause: the null check above, the caller that already awaits, the value that cannot reach here.
   - **Unclear** — needs knowledge you do not have. Leave it standing and say what would settle it.

   Verify every high and medium finding. Spot-check the lows. `probability` is a pointer to look at, not evidence — a 0.94 finding contradicted by the file is still wrong, and you should say so plainly rather than hedging toward Jev.

3. **Report.** One line naming the scope reviewed and the verdict, then findings ranked most-severe first, each with `file:line`, its severity, and its **Confirmed / Wrong / Unclear** mark. Say how many you checked, so a long list is not mistaken for a long list of real problems. Close with a one-line verdict: is anything here worth fixing before this ships?

4. **Fix, only with `--fix`** (or if the user asks after seeing the report). Fix confirmed high and medium findings. Leave the wrong ones alone and do not "fix" something to quiet a finding you just disproved. Then re-run once to confirm the findings cleared. Stop after that second run whatever it says — report what is left rather than looping.

## Constraints

- Report the review; that is the job. No fixes without `--fix` or an explicit ask.
- One `jev-review` invocation per run, or two with `--fix`.
- Never post to GitHub unless `--post` was passed.
- Jev is a judgment model, not a linter or a test suite. A clean review is not a guarantee the change is correct.
- This sends the diff to TypeSafe's API. Skip it for code that must not leave the machine.
