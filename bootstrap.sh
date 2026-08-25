#!/usr/bin/env bash
# Rebuild this agent-config pool on a fresh machine.
#
#   git clone <this repo> ~/.agents && ~/.agents/bootstrap.sh
#
# Idempotent: safe to re-run on an existing machine to repair drift.
set -uo pipefail

POOL="$HOME/.agents"
SKILLS_CLI="skills@1.5.23"
TEAM_REPO="git@github.com:brewdigital/skills.git"
TEAM_PATH="$HOME/Documents/Projects/skills"
fail=0

say() { printf '\n\033[1m%s\033[0m\n' "$1"; }
ok()  { printf '  ✓ %s\n' "$1"; }
no()  { printf '  ✗ %s\n' "$1"; fail=1; }

say "1. Prerequisites"
for c in git node npx curl; do
  command -v "$c" >/dev/null && ok "$c" || no "$c is required"
done
[ "$fail" = "1" ] && { echo; echo "Install the missing tools and re-run."; exit 1; }

# Optional, but skills here depend on them.
command -v bun  >/dev/null && ok "bun (needed by truffler / find-similar-functions)" \
  || echo "  ! bun missing - find-similar-functions will not run. brew install oven-sh/bun/bun"
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

say "3. Commands not stored in this repo"
# rams is fetched from source; skills.sh does not manage commands.
curl -fsSL https://rams.ai/rams.md -o "$POOL/commands/rams.md" \
  && ok "rams.md fetched from rams.ai" || no "could not fetch rams.md"
# second-opinion is authored in the team repo; keep that authoritative.
if [ ! -d "$TEAM_PATH" ]; then
  git clone -q "$TEAM_REPO" "$TEAM_PATH" 2>/dev/null \
    && ok "cloned $TEAM_REPO" || echo "  ! could not clone $TEAM_REPO (ssh key?)"
fi
if [ -f "$TEAM_PATH/commands/second-opinion.md" ]; then
  ln -sfn "$TEAM_PATH/commands/second-opinion.md" "$POOL/commands/second-opinion.md"
  ok "second-opinion.md -> team repo"
fi

say "4. Global instructions"
mkdir -p "$HOME/.claude" "$HOME/.codex" "$HOME/handoffs"
printf '<!-- Canonical instructions live in ~/.agents/AGENTS.md. Edit that file, not this one. -->\n\n@~/.agents/AGENTS.md\n' > "$HOME/.claude/CLAUDE.md"
ok "~/.claude/CLAUDE.md (import stub - Claude Code does not read AGENTS.md natively)"
ln -sfn "$POOL/AGENTS.md" "$HOME/.codex/AGENTS.md"
ok "~/.codex/AGENTS.md -> pool"
echo "  ! Cursor global rules are app config, not a file."
echo "    Paste ~/.agents/AGENTS.md into Customize > Rules > User Rules by hand."

say "5. Link everything into the tools"
"$POOL/sync.sh"

say "Done"
echo "  Verify:  npx $SKILLS_CLI list"
echo "  Update:  npx $SKILLS_CLI update -g -y   (skills only; commands are manual)"
[ "$fail" = "1" ] && exit 1 || exit 0
