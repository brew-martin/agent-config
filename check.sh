#!/usr/bin/env bash
# Check the pool for drift that sync.sh cannot repair. Read-only, apart from keeping
# .skill-hashes, its record of each vendored skill as installed (machine-local, gitignored).
#
#   1. References: skill, command and agent names cited in pool files must exist.
#   2. AGENTS.md table: must list exactly the manual-only skills.
#   3. Vendored skills: lockfile, disk and git agree, and nothing is edited locally.
#
# Exit 1 on errors. Warnings (unresolved references inside vendored skills) do not fail,
# because upstream text cannot be edited here; accept them in ALLOW below.
set -euo pipefail

python3 - "${POOL:-$HOME/.agents}" <<'PYEOF'
import glob, json, os, re, shutil, subprocess, sys, tempfile

pool = sys.argv[1]
os.chdir(pool)

# Unresolved references that are known and accepted, as (skill dir, name): reason.
# "*" matches any skill dir. An entry that stops matching is reported as stale.
ALLOW = {
    ("writing-for-agents", "model-invoked"): "a term, not a skill",
    ("writing-for-agents", "user-invoked"): "a term, not a skill",
}

errors, warnings = [], []
git = lambda *a: subprocess.run(["git", *a], capture_output=True, text=True, check=True).stdout

skills = {d for d in os.listdir("skills") if os.path.isdir(f"skills/{d}")}
commands = {f[:-3] for f in os.listdir("commands") if f.endswith(".md")}
agents = {re.search(r"^name:\s*(.+)$", open(f).read(), re.M).group(1).strip()
          for f in glob.glob("agents/*.md")}
local_skills = {p.split("/")[1] for p in git("ls-files", "skills").split()}

def frontmatter(path):
    if not os.path.isfile(path):
        return ""
    m = re.match(r"---\n(.*?)\n---", open(path).read(), re.S)
    return m.group(1) if m else ""

for s in sorted(skills):
    if not os.path.isfile(f"skills/{s}/SKILL.md"):
        errors.append(f"skills/{s}: no SKILL.md, so no tool can load it")

manual = {s for s in skills
          if re.search(r"^disable-model-invocation:\s*true\s*$", frontmatter(f"skills/{s}/SKILL.md"), re.M)}

# 1. References -------------------------------------------------------------------------
ANY = [
    re.compile(r"(?:`|\*\*)([a-z][a-z0-9-]+)(?:`|\*\*) skill\b"),
    re.compile(r"\b(?:belongs?|lands?|routes?) (?:to|in) `([a-z][a-z0-9-]+)`"),
    re.compile(r'Skill tool[^\n]*?"([a-z][a-z0-9-]+)"(?:[^\n]*?"([a-z][a-z0-9-]+)")?'),
]
SLASH = re.compile(r"`/([a-z][a-z0-9-]+)(?:`| [^`\n]*`)")   # only checked in our own files
AGENT = re.compile(r'subagent_type: "([^"]+)"')

used_allow = set()
def scan(path, owner, ours):
    text = open(path).read()
    found = set()
    for p in ANY + ([SLASH] if ours else []):
        for m in p.finditer(text):
            found.update(("skill", g) for g in m.groups() if g)
    found.update(("agent", m.group(1)) for m in AGENT.finditer(text))
    for kind, name in sorted(found):
        if (name in agents) if kind == "agent" else (name in skills or name in commands):
            continue
        key = next((k for k in [(owner, name), ("*", name)] if k in ALLOW), None)
        if key and not ours:
            used_allow.add(key)
            continue
        msg = f"{path}: {kind} `{name}` does not exist in the pool"
        (errors if ours else warnings).append(msg)

for s in sorted(skills):
    for f in sorted(glob.glob(f"skills/{s}/**/*.md", recursive=True)):
        scan(f, s, s in local_skills)
for f in sorted(glob.glob("agents/*.md") + glob.glob("commands/*.md")) + ["AGENTS.md"]:
    scan(f, f, True)
for key in sorted(set(ALLOW) - used_allow):
    warnings.append(f"check.sh: ALLOW entry {key} no longer matches anything - remove it")

# 2. AGENTS.md table ----------------------------------------------------------------------
table = set(re.findall(r"^\|[^|\n]*\|\s*`([a-z0-9-]+)`\s*\|\s*$", open("AGENTS.md").read(), re.M))
for s in sorted(table - skills):
    errors.append(f"AGENTS.md: table lists `{s}`, which is not installed")
for s in sorted((table & skills) - manual):
    errors.append(f"AGENTS.md: table lists `{s}`, which fires on its own - drop the row")
for s in sorted(manual - table):
    errors.append(f"AGENTS.md: `{s}` is manual-only but not in the table, so nothing suggests it")

# 3. Vendored skills ----------------------------------------------------------------------
lock = json.load(open(".skill-lock.json"))["skills"] if os.path.exists(".skill-lock.json") else {}
for s in sorted(skills - set(lock) - local_skills):
    kind = "a symlink" if os.path.islink(f"skills/{s}") else "a directory"
    errors.append(f"skills/{s}: {kind} with no lockfile entry and not committed - "
                  "install it through the CLI or commit it as a local skill")
for s in sorted(set(lock) - skills):
    errors.append(f".skill-lock.json: `{s}` is locked but missing from skills/")
for s in sorted(set(lock) & local_skills):
    errors.append(f"skills/{s}: committed as local but also in the lockfile - pick one")

vendored = sorted((set(lock) & skills) - local_skills)
RECORD = ".skill-hashes"
recorded = json.load(open(RECORD)) if os.path.exists(RECORD) else {}
record = dict(recorded)
tmp = tempfile.mkdtemp()
try:
    subprocess.run(["git", "init", "-q", tmp], check=True)
    for s in vendored:
        shutil.copytree(f"skills/{s}", f"{tmp}/{s}", symlinks=True,
                        ignore=shutil.ignore_patterns(".DS_Store"))
    subprocess.run(["git", "-C", tmp, "add", "-A", "."], check=True)
    root = git("-C", tmp, "write-tree").strip()
    for s in vendored:
        want = lock[s].get("skillFolderHash")
        if not want:
            errors.append(f".skill-lock.json: `{s}` has no skillFolderHash - reinstall through the CLI")
            continue
        # skillFolderHash is the upstream folder's hash, which covers files the CLI does not
        # install, so it cannot be compared with what is on disk. Compare against our own
        # record of the installed tree instead, re-taken whenever the CLI changes the lock.
        tree = git("-C", tmp, "rev-parse", f"{root}:{s}").strip()
        seen = record.get(s)
        if seen is None or seen["lock"] != want:
            record[s] = {"lock": want, "tree": tree}
        elif seen["tree"] != tree:
            errors.append(f"skills/{s}: edited locally - the next update overwrites it; "
                          "fork it as a local skill or reinstall")
finally:
    shutil.rmtree(tmp)
record = {s: record[s] for s in vendored if s in record}
if record != recorded:
    json.dump(record, open(RECORD, "w"), indent=1, sort_keys=True)

# Report ----------------------------------------------------------------------------------
print("== check ==")
for w in warnings: print(f"  warn  {w}")
for e in errors:   print(f"  ERROR {e}")
if not errors and not warnings:
    print(f"  ok - {len(skills)} skills, {len(commands)} commands, {len(agents)} agents")
sys.exit(1 if errors else 0)
PYEOF
