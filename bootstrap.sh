#!/usr/bin/env bash
# Rebuild this agent-config pool on a fresh machine.
#
#   git clone <this repo> ~/.agents && ~/.agents/bootstrap.sh
#
# Idempotent: safe to re-run on an existing machine to repair drift.
set -uo pipefail

POOL="$HOME/.agents"
SKILLS_CLI="skills@1.5.23"
fail=0

say() { printf '\n\033[1m%s\033[0m\n' "$1"; }
ok()  { printf '  ✓ %s\n' "$1"; }
no()  { printf '  ✗ %s\n' "$1"; fail=1; }

say "1. Prerequisites"
for c in git node npx; do
  command -v "$c" >/dev/null && ok "$c" || no "$c is required"
done
[ "$fail" = "1" ] && { echo; echo "Install the missing tools and re-run."; exit 1; }

# Optional, but skills here depend on them.
command -v gh   >/dev/null && ok "gh" || echo "  ! gh missing - GitHub-based workflows will not run"
command -v cursor-agent >/dev/null && ok "cursor-agent (needed by /second-opinion)" \
  || echo "  ! cursor-agent missing - /second-opinion will not run"

say "2. Skills"
# Installed through the CLI, one --skill per run: comma lists are silently ignored.
# This is what gives each skill a skillFolderHash, without which `skills update`
# skips it and reports a misleading "Private or deleted repo".
n=0
while IFS=$'\t' read -r name source; do
  case "$name" in ''|'#'*) continue ;; esac
  [ -d "$POOL/skills/$name" ] && { ok "$name (present)"; n=$((n+1)); continue; }
  # </dev/null is load-bearing: the CLI reads stdin and would otherwise swallow
  # the rest of the manifest that this while-loop is reading from.
  if npx --yes "$SKILLS_CLI" add "$source" --skill "$name" -g -y </dev/null >/dev/null 2>&1 \
     && [ -d "$POOL/skills/$name" ]; then
    ok "$name  <- $source"; n=$((n+1))
  else
    no "$name  <- $source"
  fi
done < "$POOL/skills.manifest"
echo "  $n skill(s) present"
# Remove skills the manifest has dropped, or every machine keeps them after a pull.
# Only a skill an earlier manifest commit listed counts as dropped: one added through
# the CLI here and not yet synced into the manifest was never listed, so it stays.
# Skipped while skills.manifest has local edits, since then it is not the shared list.
if [ -f "$POOL/.skill-lock.json" ] && git -C "$POOL" diff --quiet -- skills.manifest; then
  backup=""
  for name in $(python3 - "$POOL" <<'PYEOF'
import json, os, sys
pool = sys.argv[1]
lock = json.load(open(os.path.join(pool, ".skill-lock.json")))["skills"]
listed = {l.split("\t")[0] for l in open(os.path.join(pool, "skills.manifest"))
          if l.strip() and not l.startswith("#")}
print("\n".join(sorted(set(lock) - listed)))
PYEOF
  ); do
    if [ -z "$(git -C "$POOL" log -1 --format=%h -G "^$name"$'\t' -- skills.manifest)" ]; then
      echo "  ! $name is installed but not in skills.manifest - run sync.sh and commit the manifest"
      continue
    fi
    if [ -z "$backup" ]; then
      backup="$HOME/ai-config-backups/bootstrap-$(date +%Y%m%d-%H%M%S)"
      mkdir -p "$backup" && cp "$POOL/.skill-lock.json" "$backup/"
    fi
    [ -e "$POOL/skills/$name" ] && cp -RL "$POOL/skills/$name" "$backup/"
    if npx --yes "$SKILLS_CLI" remove "$name" -g -y </dev/null >/dev/null 2>&1 \
       && [ ! -e "$POOL/skills/$name" ]; then
      ok "$name removed (dropped from the manifest; backup in $backup)"
    else
      no "$name could not be removed (dropped from the manifest)"
    fi
  done
fi
# Skills installed by their own CLI (see CLI_MANAGED in check.sh).
if command -v stitch >/dev/null; then
  stitch agent-skills add --user </dev/null >/dev/null 2>&1 && ok "stitch  <- stitch agent-skills add --user" \
    || no "stitch  <- stitch agent-skills add --user"
else
  echo "  ! stitch CLI missing (npm i -g @google/stitch) - /stitch skill not installed"
fi

say "3. Global instructions"
mkdir -p "$HOME/.claude" "$HOME/.codex"
printf '<!-- Canonical instructions live in ~/.agents/AGENTS.md. Edit that file, not this one. -->\n\n@~/.agents/AGENTS.md\n' > "$HOME/.claude/CLAUDE.md"
ok "~/.claude/CLAUDE.md (import stub - Claude Code does not read AGENTS.md natively)"
ln -sfn "$POOL/AGENTS.md" "$HOME/.codex/AGENTS.md"
ok "~/.codex/AGENTS.md -> pool"

say "4. Link everything into the tools"
"$POOL/sync.sh" || fail=1

say "Done"
echo "  Verify:  npx $SKILLS_CLI list"
echo "  Update:  ~/.agents/update.sh   (skills only; commands are manual)"
[ "$fail" = "1" ] && exit 1 || exit 0
