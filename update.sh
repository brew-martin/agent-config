#!/usr/bin/env bash
# Update vendored skills and show what changed, so an update is never silent.
#
#   ~/.agents/update.sh              # every skill
#   ~/.agents/update.sh <name> ...   # only these
#
# Backs up skills/ and the lockfile first, runs the CLI update, reports added, removed
# and changed skills (calling out description and disable-model-invocation changes,
# since those decide when a skill fires), then runs sync.sh, which runs check.sh.
set -euo pipefail

POOL="$HOME/.agents"
SKILLS_CLI="skills@1.5.23"
backup="$HOME/ai-config-backups/update-$(date +%Y%m%d-%H%M%S)"

mkdir -p "$backup"
cp -R "$POOL/skills" "$backup/skills"
cp "$POOL/.skill-lock.json" "$backup/.skill-lock.json"

echo "== update =="
# </dev/null: the CLI reads stdin and would otherwise wait on it.
npx --yes "$SKILLS_CLI" update "$@" -g -y </dev/null >/dev/null

# Skills installed by their own CLI (see CLI_MANAGED in check.sh).
stitch_before=$(find "$POOL/skills/stitch" -type f -exec shasum {} + 2>/dev/null | sort | shasum || true)
if command -v stitch >/dev/null && [ -d "$POOL/skills/stitch" ]; then
  stitch agent-skills update </dev/null >/dev/null 2>&1 || echo "  ! stitch agent-skills update failed"
fi
stitch_after=$(find "$POOL/skills/stitch" -type f -exec shasum {} + 2>/dev/null | sort | shasum || true)

echo "== changes =="
[ "$stitch_before" != "$stitch_after" ] && echo "  ~ stitch (via stitch agent-skills update)"
if python3 - "$POOL" "$backup" <<'PYEOF'
import json, os, re, sys
pool, backup = sys.argv[1], sys.argv[2]
old = json.load(open(os.path.join(backup, ".skill-lock.json")))["skills"]
new = json.load(open(os.path.join(pool, ".skill-lock.json")))["skills"]

def field(root, skill, key):
    path = os.path.join(root, "skills", skill, "SKILL.md")
    if not os.path.isfile(path):
        return None
    m = re.match(r"---\n(.*?)\n---", open(path).read(), re.S)
    fm = m.group(1) if m else ""
    m = re.search(rf"^{key}:\s*(.*?)(?=^\S[^\n]*:|\Z)", fm, re.M | re.S)
    return re.sub(r"\s+", " ", m.group(1)).strip().strip("\"'") if m else None

changed = False
for s in sorted(set(new) - set(old)):
    print(f"  + {s}"); changed = True
for s in sorted(set(old) - set(new)):
    print(f"  - {s}"); changed = True
for s in sorted(set(old) & set(new)):
    if old[s].get("skillFolderHash") == new[s].get("skillFolderHash"):
        continue
    changed = True
    print(f"  ~ {s}")
    a, b = field(backup, s, "disable-model-invocation"), field(pool, s, "disable-model-invocation")
    if (a == "true") != (b == "true"):
        state = lambda v: "manual-only" if v == "true" else "fires on its own"
        print(f"      ! now {state(b)} (was {state(a)}) - update the AGENTS.md table")
    a, b = field(backup, s, "description"), field(pool, s, "description")
    if a != b:
        print(f"      description was: {a}")
        print(f"      description now: {b}")
sys.exit(0 if changed else 1)
PYEOF
then
  echo "  backup: $backup"
  echo "  undo everything: rm -rf $POOL/skills && cp -R $backup/skills $POOL/skills" \
       "&& cp $backup/.skill-lock.json $POOL/ && $POOL/sync.sh"
else
  echo "  nothing changed"
  rm -rf "$backup"
fi

"$POOL/sync.sh"
