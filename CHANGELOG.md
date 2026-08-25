# Change log

Chronological record of changes to this pool.

## Migration 2026-08-25

Backup of everything touched: `/Users/martinsherwood/ai-config-backups/cursor-20260825-092448`

**Moved into the pool (nothing deleted):**
- 21 design/workflow commands from `~/.cursor/commands/` — adapt, animate, audit, bolder,
  clarify, colorize, council, critique, delight, deslop, extract, harden, normalize, onboard,
  optimize, polish, quieter, refactor-code, simplify, teach-impeccable,
  you-might-not-need-an-effect. These were Cursor-only and are now available in Claude Code too.
  NOTE: they are **not** on skills.sh — that CLI distributes skills, not commands. The backup
  above is the only other copy.

**Removed (true duplicates, byte-identical, now single-sourced):**
- `~/.claude/commands/rams.md` — identical copy of the Cursor one
- `~/.claude/commands/web-interface-guidelines.md` — identical copy of the Cursor one

**Relinked:**
- `second-opinion.md` — still authored in `~/Documents/Projects/skills/commands/`
  (brewdigital/skills repo). Pool holds a symlink to it, tools link to the pool.

**Lockfiles consolidated:**
- `~/skills-lock.json` tracked 8 emilkowalski skills. It was not a second global manifest —
  it was an accidental *project* lockfile created by running `npx skills add` from $HOME.
  Its 8 entries were merged into `~/.agents/.skill-lock.json` (now 18) and the file was
  retired to `~/.agents/skills-lock.project.json.retired`.
- Merged entries carry source/sourceType/sourceUrl/skillPath/installedAt. The v1 `computedHash`
  was **not** carried across (different schema); the CLI recomputes on next `skills update`.

**Also fixed:** Codex had zero user skills. All 18 are now linked into `~/.codex/skills/`,
which also fixes Codex when driven through T3 Code.

**Left alone:** `~/.cursor/skills-cursor/` (Cursor-managed), `~/.cursor/skills/` and
`~/.claude/skills/` (already correct), opencode and gemini (no skills configured).

## Removal 2026-08-25 (second pass)

Backup: `/Users/martinsherwood/ai-config-backups/removal-20260825-094703`

**Commands removed (21):**
- Impeccable pack (17, from pbakaus/impeccable): adapt, animate, audit, bolder, clarify,
  colorize, critique, delight, extract, harden, normalize, onboard, optimize, polish,
  quieter, simplify, teach-impeccable. Removed as unusable — they reference an
  "Anti-Patterns" section that does not exist in the installed anthropics/skills
  `frontend-design`, which is a different skill from Impeccable's own.
- council, you-might-not-need-an-effect, refactor-code (unattributed)
- deslop — to be replaced by poteto pstack `unslop`

**Skill removed (1):** brainstorming (obra/superpowers). Removed via `npx skills remove`;
that command deletes the folder and symlinks but leaves the lockfile entry, so the entry
was deleted by hand.

**Side effect:** the Impeccable `simplify` command was shadowing Claude Code's built-in
`/simplify`. The built-in is now reachable again.

Pool after this pass: 17 skills, 3 commands.

**Also removed:** `rams` command (unattributed Dieter Rams design review).
Impeccable's `simplify` was already removed above — it had been shadowing Claude Code's
built-in `/simplify`, which is now reachable again. No skills were removed in this pass;
the emilkowalski design/animation set was reviewed and deliberately kept.

Pool now: 17 skills, 2 commands.

## Install 2026-08-25

Vendored by hand (not via the skills CLI) — lockfile entries carry `vendoredByHand: true`,
and pstack entries carry the pinned commit they were taken from.

**Repairs** — mattpocock primitives that `grill-me` and `improve-codebase-architecture`
were calling but that were never installed:
- `grilling`          <- mattpocock/skills, skills/productivity/grilling
- `codebase-design`   <- mattpocock/skills, skills/engineering/codebase-design
- `domain-modeling`   <- mattpocock/skills, skills/engineering/domain-modeling

All four previously dangling `Skill tool with "..."` references now resolve.

**deslop replacement** — pstack, pinned at 60c641e4fad674784b30abcf9f8915dea39df38d:
- `unslop`      prose slop (AI writing tells). Model-invoked, "must always apply".
- `no-comments` code comment cleanup, the closer match to what /deslop did.
                Manual-only (`disable-model-invocation: true`).
                Requires the `Comment Sicko` agent -> `~/.agents/agents/comment-sicko.md`.

Agents layer links into Claude Code and Cursor only. Codex 0.148 has no global agents dir;
mattpocock skills ship their own `agents/openai.yaml` for Codex instead.

Pool now: 22 skills, 2 commands, 1 agent.

## deslop replacement 2026-08-25

`deslop` <- millionco/react-doctor (`.agents/skills/deslop`), installed via the skills CLI so
it is properly tracked. Same repo `improve-react` comes from (aidenybai/react-doctor was
renamed to millionco/react-doctor).

Replaces the unattributed Cursor-only `/deslop` that was removed earlier. Broader scope:
removes obvious-code comments, pass-through wrappers, single-use indirection, dead branches,
unused exports and leftover scaffolding. Model-invoked (no disable-model-invocation), and its
description carries real trigger phrases: "deslop", "clean up code", "simplify code".

Optional companion it references: `find-similar-functions` (truffler) from the same repo,
for collapsing near-duplicate functions. Not installed.

Pool now: 23 skills, 2 commands, 1 agent.

## find-similar-functions + bun 2026-08-25

`find-similar-functions` (truffler) <- millionco/react-doctor. The dedupe companion `deslop`
references. Auto-firing.

Required a real dependency: the `truffler` CLI ships `bin: src/cli.ts` with a
`#!/usr/bin/env bun` shebang, so npx alone cannot run it despite the package declaring
node >=22.12 support. Installed bun 1.4.0 via `brew install oven-sh/bun/bun`
(/opt/homebrew, 63MB, separate from the nvm node setup).

Verified working: `npx @rayhanadev/truffler "format" app --kind function,method`
returns scored matches against a real repo. No project-level install needed; npx is enough
now that bun exists.

Side benefit: bun is also what pstack's `babysit` playbook (scripts/watch-pr) needs, which
the skills audit had flagged as dead-on-arrival.

Pool now: 24 skills, 2 commands, 1 agent.

## Updating skills 2026-08-25

    npx skills update -g -y          # all global skills
    npx skills update <name> -g -y   # one

All 24 are now CLI-updatable. Earlier, 13 were not: the 5 vendored by hand and the 8
emilkowalski entries merged from the old project lockfile. Both groups were missing
`skillFolderHash`, which the updater verifies against, so it skipped them and reported
"Private or deleted repo" - a misleading message. Both repos are public; subdirectory
skill paths (pstack/skills/*, skills/productivity/*) are fully supported.

Fixed by reinstalling all 13 through the CLI so it wrote correct entries:
    npx skills add cursor/plugins --skill unslop -g -y
    npx skills add mattpocock/skills --skill grilling -g -y
    npx skills add emilkowalski/skills --skill prototype -g -y     # etc, one --skill per run
Comma-separated lists are NOT supported by --skill; loop one at a time.

No entries now carry `vendoredByHand`. Note reinstalling takes current main, so the pstack
pin (60c641e4) no longer applies, and any local edits to a SKILL.md are overwritten on update.

Upstream changes picked up in this pass: improve-codebase-architecture (em-dash revision),
accessibility, core-web-vitals, performance.

## Additions 2026-08-25 (post-audit round)

From the pstack / mattpocock audit, installed via CLI so all are updatable:
- `grill-with-docs` (mp, manual) - grilling + domain-modeling in one call. Writes CONTEXT.md
  terms and ADRs inline as decisions land. Better than grill-me inside a repo.
- `handoff` (mp, manual) - compacts a session into a portable handoff doc.
  TODO: repoint output from $TMPDIR to docs/plans/.
- `writing-for-agents` (mp, auto) - reference for any doc an agent reads. Fires when
  editing skills, AGENTS.md or CLAUDE.md.
- `blast-radius` (pstack, manual) - what a diff breaks outside the diff, with a 5-rung
  evidence ladder. For legacy-removal PRs.
- `wait-what` (mp, manual) - re-pitch a message that didn't land. Adds the missing premise
  rather than just de-jargoning; uses CONTEXT.md vocabulary. Chosen over pstack's `bro`,
  which only restates more simply.

Pool now: 29 skills, 2 commands, 1 agent.

## Instruction files 2026-08-25

Researched rather than assumed. Findings:
- Cursor reads AGENTS.md natively, IDE and CLI, alongside .cursor/rules.
- Codex reads AGENTS.md natively.
- Claude Code does NOT read AGENTS.md as of Aug 2026. It reads CLAUDE.md. The documented
  workaround is the `@` import. The "reads it as a fallback" claim circulating online is wrong.
- Cursor's global rules live in Settings > Rules > User (app config), not a file, so they
  cannot be symlinked into this pool.

Set up:
- `~/.agents/AGENTS.md` created as the global instruction file. Seeded with the handoff
  path convention (`~/handoffs/`, dir created) and British English.
- `~/.claude/CLAUDE.md` - import stub `@~/.agents/AGENTS.md`. Was briefly a symlink;
  swapped to the stub since that is the documented method and allows Claude-only additions.
- `~/.codex/AGENTS.md` - symlink to the pool file. Previously existed but was 0 bytes.

Repos converted to AGENTS.md-canonical with a `@AGENTS.md` stub, matching the pattern
already used in scriptrunner-dot-js. LEFT UNCOMMITTED for review:
- videos (584 lines), colour-picker (450), design-dev-figma-plugin (167),
  accessibility-tool (127)

Before this, 1,328 lines of instructions in those four repos were readable by Claude Code
only. Codex and Cursor started blind in them.

scriptrunner-dot-js deliberately untouched - already converted, and owner is handling it.
budget and test have AGENTS.md but no CLAUDE.md stub; flapper has a hybrid (CLAUDE.md adds
repo-running specifics on top of AGENTS.md). Neither addressed.

Docs restructured: README.md is now a reference for the setup; this file holds the history.

## rams + Codex commands 2026-08-25

`rams` re-added (123 lines, newer than the 104-line copy removed earlier).

Did NOT use the `curl -fsSL https://rams.ai/install | bash` installer. The script is
well written, but it creates a competing canonical at `~/.rams/rams.md` and writes
straight into tool dirs, bypassing this pool. It also uses plain copies for Cursor,
Codex and Antigravity, which drift until the installer is re-run, and would install to
OpenCode and Antigravity which are unused. Took the source file into the pool instead.

Correction to an earlier note: Codex DOES support custom slash commands, via
`~/.codex/prompts/`. The earlier claim that it "supports skills only" came from a
`strings` grep of the binary that only surfaced `.codex/config` and `.codex/skills`.
The rams installer targets `~/.codex/prompts/` and cites openai/codex#3637 for symlinked
prompts not being loaded.

`sync.sh` gained a COPY_TARGETS mode for exactly this. Verified: idempotent on re-run,
removes stale copies via a `.pool-managed` manifest, and leaves hand-added prompts alone.

All 3 commands now reach Codex. Pool: 29 skills, 3 commands, 1 agent.
