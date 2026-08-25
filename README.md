# ~/.agents - agent configuration, one source of truth

Skills, commands, sub-agents and global instructions live here **once** and are symlinked
into every tool. Edit here; every tool sees it immediately. No copying, no sync step.

    ~/.agents/
      AGENTS.md        global instructions  -> Claude Code, Codex
      skills/          29 skill dirs        -> Claude Code, Cursor, Codex
      commands/         3 command files     -> Claude Code, Cursor (symlink), Codex (copy)
      agents/           1 sub-agent         -> Claude Code, Cursor
      sync.sh          idempotent linker
      bootstrap.sh     rebuild on a new machine
      skills.manifest  name -> source, for bootstrap
      .skill-lock.json manifest for all skills
      CHANGELOG.md     history of changes

## Adding something

1. Put it in `~/.agents/{skills,commands,agents}/`
2. Run `~/.agents/sync.sh`

For skills, prefer the CLI instead - it writes a proper lockfile entry so the skill
stays updatable:

    npx skills add <owner>/<repo> --skill <name> -g -y
    ~/.agents/sync.sh

`--skill` takes ONE name per run. Comma-separated lists are silently ignored.

## Updating

    npx skills update -g -y          # all
    npx skills update <name> -g -y   # one

Every skill must have a `skillFolderHash` in `.skill-lock.json`. Without one the updater
skips it and reports "Private or deleted repo", which is misleading - the repo is usually
fine. Hand-written lockfile entries cause this. Fix by reinstalling through the CLI.

Updating overwrites local edits to a SKILL.md. To change a skill permanently, fork it
under a different name.

## Which tool reads what

| Layer     | Claude Code | Cursor | Codex |
|-----------|-------------|--------|-------|
| skills    | yes         | yes    | yes   |
| commands  | yes         | yes    | yes (copy) |
| agents    | yes         | yes    | no    |
| AGENTS.md | via import  | native | native|

Codex reads skills as symlinks, but does **not** load symlinked prompts
(openai/codex#3637), so `sync.sh` copies commands into `~/.codex/prompts/` instead and
refreshes them on every run. A `.pool-managed` manifest there records what the pool owns,
so stale files are removed while anything you added by hand is left alone.

Codex has no agents directory. mattpocock skills ship their own `agents/openai.yaml`
for Codex instead.

T3 Code is a front end, not a store. It drives the `claude`, `codex`, `cursor agent` and
`opencode` binaries, so it sees whatever the provider you picked that session sees.

## Instruction files: AGENTS.md is canonical

AGENTS.md is the open standard (Agentic AI Foundation / Linux Foundation), read natively by
Codex, Cursor, Copilot, Gemini CLI, Aider, Zed and others.

**Claude Code is the holdout.** As of August 2026 it reads `CLAUDE.md`, not `AGENTS.md`.
The documented workaround is the `@` import. So the pattern everywhere is:

- `AGENTS.md` holds the real content
- `CLAUDE.md` is a stub that imports it

Global:

    ~/.agents/AGENTS.md                          <- the real file, edit this
    ~/.claude/CLAUDE.md    stub: @~/.agents/AGENTS.md
    ~/.codex/AGENTS.md     symlink -> ~/.agents/AGENTS.md

Per repo:

    AGENTS.md    the real content
    CLAUDE.md    <!-- Canonical instructions live in AGENTS.md. Edit that file, not this one. -->
                 @AGENTS.md

An import stub is used rather than a symlink so Claude-specific lines can be added
alongside the shared ones if ever needed.

**Cursor's global rules are not a file.** They live in Cursor Settings > Rules > User,
stored in app config, so they cannot be symlinked here. Either paste the contents of
`AGENTS.md` in there by hand, or rely on per-repo AGENTS.md, which the Cursor CLI reads
natively alongside `.cursor/rules`.

Use `.cursor/rules/*.mdc` only for things other tools cannot express, such as glob-scoped
auto-attach rules.

## Things that are not ours

- `~/.cursor/skills-cursor/` - Cursor's own built-ins. Auto-managed via
  `.sync-manifest.json`; 6 are `builtinSkillIds` and 3 are `managedSkillIds`, so Cursor
  recreates them if deleted. Leave alone.
- `~/.codex/skills/.system/` - OpenAI's bundled system skills.

## Commands are not tracked by skills.sh

The CLI manages skills only. Commands have no lockfile entry and are not covered by
`npx skills update`. Update them by re-fetching the source file into
`~/.agents/commands/` and running `sync.sh`. For example:

    curl -fsSL https://rams.ai/rams.md -o ~/.agents/commands/rams.md
    ~/.agents/sync.sh

## New machine

This directory is a git repo. Skills are NOT committed - they are vendored from upstream
and rebuilt from `skills.manifest`.

    git clone git@github.com:brew-martin/agent-config.git ~/.agents
    ~/.agents/bootstrap.sh

`bootstrap.sh` checks prerequisites, reinstalls every skill through the CLI (so each gets a
`skillFolderHash` and stays updatable), fetches `rams.md` from source, clones the team repo
and relinks `second-opinion`, writes the global instruction files, and runs `sync.sh`.
Idempotent - re-run any time to repair drift.

After bootstrap, one manual step remains: paste `AGENTS.md` into
Cursor Settings > Rules > User.

Regenerate the manifest after adding or removing skills:

    python3 -c "import json,os;j=json.load(open(os.path.expanduser('~/.agents/.skill-lock.json')))['skills'];open(os.path.expanduser('~/.agents/skills.manifest'),'w').write('# name\tsource\n'+''.join(f'{k}\t{j[k][\"source\"]}\n' for k in sorted(j)))"

Not reproduced by bootstrap, install by hand: bun (`brew install oven-sh/bun/bun`),
gh, cursor-agent, node, pnpm. bootstrap reports which are missing.

Per-repo `AGENTS.md` files live in their own repos and travel with git.

## Backups

`~/ai-config-backups/` - snapshots taken before each removal or bulk change.
