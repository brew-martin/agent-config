# Change log

Chronological record of changes to this pool.

## 2026-11-19 - browser tests before a browser

The Browsers section in `AGENTS.md` opens with checking a change through the project's
own browser tests when it has them: add or update a test that shows the change, then run
the suite. A browser is for what a test can't show, or when the user asks. Agents had
been clicking through pages by hand to check their work, which left nothing behind and
went wrong in a different way for each agent; PM Bible's suite (signed in once, its own
database, Argos screenshots in CI) is the first project this applies to.

## 2026-11-18 - AGENTS.md points GitHub comments at leaving-pr-comments, recasts council

`AGENTS.md` gains a GitHub comments section telling agents to load `leaving-pr-comments`
before posting to GitHub. The skill fires from its description, but a comment posted
straight through `gh` or the API could skip it; the line makes the load explicit.

Council members are now Claude Opus 5.5, the newest GPT Sol (Copilot has 6.2, Cursor
5.6) and Muse Wonder (Cursor only; T3's Muse Code provider is disabled). Gemini Carbon is
the red team: it returns only concrete failure cases, each reproduced by Opus 5.5 before
it is acted on, since Gemini models hallucinate. It runs non-blocking and is left out of
the bar for ending the council. A hidden-jester role was tried first and dropped, since
an identical brief only bought a fourth review whose verdict was then ignored.

## 2026-11-18 - one browser section, recordings on request, Lighthouse via chrome-devtools

`AGENTS.md` merges Shared agent Chrome and the browser half of T3 Code tools into one
Browsers section. The built-in browser stays the default. Recording a finished UI change
is now offered in one line instead of done every time, which had clashed with T3's own
rule against opening its browser unasked. Scripts are told `chromium.launch()` is off
limits. Sign-ins are stated to stay in the browser they were made in, so a chrome-devtools
fallback step on a signed-in site asks for a login there too.

`agent-chrome mcp` opens `about:blank` when the shared Chrome has no page, since
chrome-devtools-mcp stumbles on a pageless browser and Chrome starts windowless.

Lighthouse audits now go through chrome-devtools' `lighthouse_audit`; the README's CLI
instructions and bootstrap's lighthouse check are gone.

Backup: `~/ai-config-backups/browser-routing-20261118-102138`.

## 2026-11-15 - added the shared agent Chrome and a browser fallback rule

Added `bin/agent-chrome` and `launchd/com.martinsherwood.agent-chrome.plist`: one
long-running Chrome on port 9222 with its own profile (`~/.cache/agent-chrome/profile`,
cloned from the old chrome-devtools profile). chrome-devtools in `~/.claude.json` and
`~/.cursor/mcp.json` now runs `agent-chrome mcp`, which attaches to it with a pinned
`chrome-devtools-mcp@1.13.0` and `--workspace` folders, so screenshots can be saved to
session scratch folders. Before, each session launched its own Chrome on one shared
profile, so concurrent sessions collided, and throwaway Playwright scripts opened a
logged-out Chrome for Testing every time.

`AGENTS.md` gains a Shared agent Chrome section (scripts attach over CDP), a fallback
rule (a failing built-in browser call gets one retry, then chrome-devtools for that step
only), and a 1440×900 viewport before recordings. Prompted by a thread that moved to
chrome-devtools for good after the built-in browser's screenshot timed out twice.

Backup: `~/ai-config-backups/shared-agent-chrome-20261115-221625`.

## 2026-11-12 - removed the Playwright MCP server, narrowed chrome-devtools

Removed the `Playwright` server from `~/.claude.json` and `~/.cursor/mcp.json`, and the
`--headless` flag from chrome-devtools in `~/.claude.json`. Agents were opening Playwright
windows that took focus and asked for logins instead of using T3's built-in browser.
chrome-devtools covers the media emulation Playwright offered, apart from print media.

The `AGENTS.md` browser rule now lists exactly what chrome-devtools is for (traces, heap
snapshots, throttling, media and mobile emulation, network inspection); everything else
goes to the built-in browser. Lighthouse runs from its CLI.

Backup: `~/ai-config-backups/remove-playwright-mcp-20261112-101726`.

## 2026-11-05 - removed four skills, added Lighthouse CLI guidance

Removed `improve-react`, `deslop`, `animation-vocabulary` and `accessibility` from the
pool and tool links. The pool now has 44 skills. Kept `apple-design` and
`better-accessibility`; the latter is the default accessibility skill.

Dropped the obsolete `improve-react` and `deslop` exceptions from `check.sh`. Installed
the standalone Lighthouse CLI for automated page audits, documented HTML/JSON report
commands in the README, and added an optional-tool warning to bootstrap.

Backup: `~/ai-config-backups/remove-four-skills-20261105-224102`.

## 2026-11-05 - dropped the Cursor user rule

`sync.sh` no longer flattens `AGENTS.md` into `cursor-user-rule.txt`, and the file is gone.
Cursor's global User Rules are no longer managed from this pool.

## 2026-11-05 - added animate, choreograph, remove-animations, animation-performance and mobile-native

From emilkowalski/skills, installed with the CLI. All five fire on their own; none goes
in the AGENTS.md table.

- `animate` builds new motion, choosing in order whether to animate, the tool, the
  properties, curve and duration, interruption and exit. The pool had review, audit and
  opportunity skills for motion, but nothing that writes it.
- `choreograph` coordinates several elements that move together: staggers, entrances,
  view swaps, multi-step flows.
- `remove-animations` only takes motion away. It is the opposite of
  `find-animation-opportunities`.
- `animation-performance` covers frame budget, composite-only properties, CSS vs WAAPI vs
  rAF, and `will-change`.
- `mobile-native` applies CSS and meta-tag fixes that make a web app feel installed on a
  phone. It overlaps `good-css` and `modern-web-guidance` on `(hover: hover)` and `dvh`.

Not taken from that repo: `animate-expo` (React Native), `write-swift` and `ask-sonner`.

## 2026-11-05 - removed handoff

T3 Code now does handoffs itself. Nothing in the pool referenced the skill, and session
logs show it was only loaded while maintaining the pool, never in real work.

## 2026-11-05 - added council, file-pr, babysit-pr and leaving-pr-comments

From t3dotgg/tstack.

`council` fires when the user says "council". It runs one review delegate on each of three
providers, in parallel through `delegate_task`, and repeats until all three are satisfied,
scoring each round out of 10. AGENTS.md names the members: Claude Opus, GPT Sol, and
Gemini through Copilot (or Cursor). Gemini CLI is disabled in T3 Code and Antigravity
offers only Gemini Flash, so neither is used for it. Unlike `/second-opinion` (one model, run by hand, through cursor-agent), council can
start itself and loops.

`file-pr` writes a PR description that opens with the problem and ends with a
model/harness line. `babysit-pr` waits with T3's `watch_pull_request`, or with its
`scripts/pr-wait` (Python, calls only `gh`) everywhere else, and fixes real CI and
review-bot findings. Both use `leaving-pr-comments`, which marks every comment an agent
posts with a 🤖 note.

Not taken: `full-send`/`full-stop` and the `sol-loop` they need, which overlap council and
`/second-opinion`; also `takeover` and `modernize`.

Also dropped the stale `better-ui` ALLOW entry from check.sh, since better-ui is installed.

## 2026-10-20 - added modern-web-guidance, chrome-extensions and good-css

`modern-web-guidance` (GoogleChrome/modern-web-guidance) is a search over Chrome's guides
to platform features: dialogs, popovers, anchor positioning, view transitions, forms and
autofill, passkeys, Trusted Types, scheduling and fetch priority, and others. It fetches
guides with `npx modern-web-guidance search|retrieve` at run time, so it needs network
access, and it ends each answer that used it with a `### Modern Web Guidance` section.

`chrome-extensions` comes from the same repo. It covers Manifest V3 extensions and
publishing to the Chrome Web Store, and only fires on extension work.

`good-css` (vojtaholik/good-css) is a fixed set of CSS techniques that hold for any
authoring system: logical properties, `oklch()`, `clamp()` scales, hover behind
`(hover: hover)`, `overflow: clip`, and others. It hands motion decisions to Emil's skills.

Both fire on their own across nearly all frontend work. Neither replaces a pool skill.
Their overlap is in rules, not in jobs: the `better-*` skills, `accessibility` and
`emil-design-eng` already agree with them on focus, reduced motion, logical properties
and hover. Two tensions to keep in mind:

- good-css says to write colors in `oklch()`. `better-colors` says to keep a codebase's
  existing notation. In a hex codebase, follow `better-colors` unless a migration is in
  scope.
- modern-web-guidance prefers native platform features over dependencies. `pick-ui-library`
  recommends libraries for OTP inputs, drag and drop, sliders and similar. Check the
  native guide first, and use the library where the native feature falls short.

## 2026-10-06 - added update.sh, tested bootstrap, fixed check.sh's edit detection

`update.sh` wraps `npx skills update`: backup first, then a report of added, removed and
changed skills, with old and new descriptions and any `disable-model-invocation` change,
then `sync.sh`. Updates no longer land unseen.

Ran `bootstrap.sh` end to end in a throwaway `HOME` cloned from the repo. It rebuilt all 36
skills, linked them into Claude Code, Cursor (without `blast-radius`) and Codex, and left
git clean, so the generated manifest and Cursor rule match what is committed.

That run showed `check.sh` reporting six freshly installed skills as edited locally. The
lockfile's `skillFolderHash` is the upstream folder hash, which covers files the CLI does
not install, so it cannot be compared with the disk. `check.sh` now keeps its own record of
each installed tree in `.skill-hashes` (gitignored) and compares against that.

Tested in the same throwaway `HOME`: fresh install passes, a planted edit is caught, an
update reports a description and flag change, and a no-op update removes its backup.

## 2026-10-05 - added check.sh, cursor-user-rule.txt is now generated

`check.sh` catches the drift the audit found by hand: names of skills, commands and agents
that do not exist, an `AGENTS.md` table out of step with the manual-only skills, and
vendored skills edited locally or missing from the lockfile. It runs at the end of every
`sync.sh`. Unresolved references inside vendored skills are warnings; known ones are
accepted in its `ALLOW` list. Tested against a copy of the pool with nine planted faults;
it reported all nine.

It found one thing still open: `deslop`'s "consolidate duplicates with truffler" step has
never worked here, because `truffler` is not installed in any project. Accepted in `ALLOW`.

`sync.sh` now generates `cursor-user-rule.txt` from `AGENTS.md`, so it can no longer drift.
It says when the file changed and needs re-pasting into Cursor.

## 2026-10-05 - README and bootstrap brought up to date

- The Cursor paste step in the README's "New machine" section and in `bootstrap.sh` now
  names `cursor-user-rule.txt`, not `AGENTS.md`, matching the rest of the README.
- The sub-agent example names `comment-sweep`; `no-comments` is long gone.
- "Things that are not ours" drops the stale Cursor built-in counts and adds the pstack
  plugin and `~/.claude/skills/synced/`.
- The install-by-hand list matches what `bootstrap.sh` checks: `pnpm` removed.
- Updating warns that `npx skills check -g` applies updates.

Deleted `CONTEXT.md`. It was a glossary for `/clearer` only, and `clearer.md` already
defines each of its terms.

## 2026-10-05 - accessibility back to upstream, jev-a11y dropped

Removed the local pointer to `/jev-a11y` from `accessibility`, added 2026-09-22. jev-a11y
was experimental and its skill was no longer linked into the pool, so the line pointed at a
command that did not exist. `accessibility` now matches its upstream tree hash, leaving
no edited vendored skills. Local skills remain `blast-radius` and `comment-sweep`.

Backup: `~/ai-config-backups/edit-20261005-110339`.

## 2026-10-05 - blast-radius no longer linked into Cursor

pstack now ships its own `blast-radius`, the skill ours was adapted from, so Cursor had two
skills with the same name. `sync.sh` gained an `EXCLUDE` list and skips our
`blast-radius` for Cursor, removing the existing link. Cursor uses pstack's version (with
`why`, `arena` and `unslop`); Claude Code and Codex keep ours.

## 2026-10-04 - removed find-similar-functions

Removed `find-similar-functions` (`millionco/react-doctor`). It came from that repo's own
`.agents/skills/` folder and was written for working on `truffler` itself; elsewhere it
needs `truffler` installed in the target project, which none were. Never run in Claude
Code. Dropped the `bun` prerequisite check from `bootstrap.sh` and the README, since this
skill was its only reason.

Backup: `~/ai-config-backups/removal-20261004-233916`.

## 2026-10-04 - removed web-interface-guidelines and performance

Deleted the `/web-interface-guidelines` command. It was a 2026-01-20 snapshot with no
update path, never run in Claude Code, and it could fire on its own against
`better-interface`, which now covers the same ground with `better-accessibility`.

Removed `performance` (`addyosmani/web-quality-skills`). Never run in Claude Code, and its
rendering path, image, font and caching sections overlap `core-web-vitals`, which stays.

Usage was counted from Claude Code and Codex history only; Cursor use was not measured.

Backup: `~/ai-config-backups/removal-20261004-232107`.

## 2026-10-04 - removed rams

Deleted the `/rams` command. `bootstrap.sh` no longer fetches it from rams.ai, so its
commands step is gone and `curl` is no longer a prerequisite. Accessibility review is
covered by `accessibility` and `better-accessibility`; visual review by the `better-*`
skills and `/web-interface-guidelines`.

Backup: `~/ai-config-backups/removal-20261004-231033`.

## 2026-10-04 - removed migrate-radix-to-base

Removed `migrate-radix-to-base` (`shadcn/ui`), added on 2026-10-02. `shadcn` stays.

Backup: `~/ai-config-backups/removal-20261004-230548`.

## 2026-10-04 - blast-radius works outside Cursor, dropped the handoffs rule

`blast-radius` no longer depends on pstack's `how`, `why` and `arena`, which exist only in
Cursor. The history step now names the git and `gh` commands directly, and the multi-model
step spawns sub-agents instead of an arena. Also dropped "Solid versus React", left over
from the source it was adapted from.

Removed the `~/handoffs/` convention from `AGENTS.md`, `cursor-user-rule.txt`, the README
and `bootstrap.sh`. It contradicted the `handoff` skill, which saves to the OS temp
directory. Existing files in `~/handoffs/` were left in place.

## 2026-10-04 - added better-accessibility

Installed `better-accessibility` from `jakubkrehel/skills` via the CLI. It was left out on
2026-08-26 for competing with addyosmani's `accessibility` on the same triggers. Today's
update cut its description to one generic line, while `accessibility` keeps its explicit
trigger phrases. Direct a11y requests should still reach `accessibility`, and
`better-accessibility` mostly runs as the owner that `better-interface` and
`interface-review` route to. Those reviews no longer report accessibility as
`Not reviewed`; UI polish still is, since `better-ui` stays out.

## 2026-10-04 - replaced break with break-ui, removed grill-me

Replaced jakubkrehel's `break` with Emil Kowalski's `break-ui` from `emilkowalski/skills`,
installed via the CLI. `break` was manual-only; `break-ui` fires on its own, so it left the
`AGENTS.md` table and the Cursor user rule.

Removed `grill-me`. It was a one-line alias for `grilling`, which already fires on any
"grill" phrase.

Ran `npx skills check -g`, which in CLI 1.5.23 applies updates rather than only listing
them. 20 skills updated. Invocation flags were unchanged. `domain-modeling` now writes
`GLOSSARY.md` instead of `CONTEXT.md`.

Backup: `~/ai-config-backups/removal-20261004-223822`.

Comment Sicko no longer calls pstack's `how` and `why` skills, which exist only in Cursor.
It checks a comment's justification itself: callers and the pinned dependency for how,
`git blame` and the originating commit or PR for why.

## 2026-10-02 - added shadcn and migrate-radix-to-base

Installed both skills from `shadcn/ui` via the CLI, so they have lockfile entries and stay
updatable. `shadcn` covers working in shadcn/ui projects (components, registries,
presets); `migrate-radix-to-base` moves components from Radix UI to Base UI. Both fire on
their own.

## 2026-09-30 - replaced pooled unslop with clearer

Removed the managed `unslop` skill from the shared pool. Cursor's Poteto plugin keeps its
own independently managed copy. Added `/clearer`, a manual command that has the active
model rewrite its previous answer and check factual fidelity.

Converted `blast-radius` to a committed local skill and replaced its `unslop` dependency
with an inline clarity rule.

## 2026-09-30 - removed design-taste-frontend

Removed `design-taste-frontend`; `frontend-design` remains the frontend design skill.

## 2026-09-30 - removed wait-what

Removed `wait-what` from the managed skill set, provider links and global reminders.

## 2026-09-27 — added design-taste-frontend

Installed `design-taste-frontend` from `Leonxlnx/taste-skill` via the CLI, so it has a
lockfile entry and stays updatable. It targets landing pages, portfolios and redesigns
(not dashboards or product UI), and fires on its own.

README skill count corrected to 40; it had missed `security-audit`.

## 2026-09-25 — second-opinion can fix what it found

`/second-opinion --fix` sends the reviewing model back to fix its findings, then Claude
checks the diff. `--fix` alone fixes every finding Claude can confirm; `--fix 1,3` fixes
those numbers. `-m` picks a different fixer.

The review no longer runs with `--mode ask`. A chat started in ask mode stays read-only
when resumed, and `--mode` has no write option, so the fixer could not resume it. The
review now runs in agent mode and is read-only by prompt only. Claude snapshots the
working copy (untracked files included) and HEAD before and after each `cursor-agent`
run, and reports anything the model changed with undo commands. This matters because the
Cursor allowlist in `~/.cursor/cli-config.json` lets `git commit`, `git checkout` and `rm`
run without `--force`.

Copied to the team repo (`~/Documents/Projects/skills/commands/`) on 2026-09-26.

## 2026-09-23 — removed prompts/, added security-audit

Deleted `prompts/` (`spec-review.md` and its README). It was never used. The Raycast
snippet copies live in Raycast and have to be deleted there.

Installed `security-audit` from `cloudflare/security-audit-skill` via the CLI. It is the
only dedicated security skill; `improve` and `improve-react` cover security as one audit
category among several, and the built-in `/security-review` only checks the current diff.

## 2026-09-18 — added typesafe-ai

Installed `typesafe-ai` from `typesafe-ai/skills` via the CLI, so it has a lockfile entry
and stays updatable. It covers building features on TypeSafe's typed-judgment models, and
fires on its own.

## 2026-09-14 — second-opinion is now a local copy

`commands/second-opinion.md` was a symlink into the team repo (`brewdigital/skills`), so
every local edit landed in the team's version. It is now a real file committed here, copied
from the team repo as it stood. `bootstrap.sh` no longer clones the team repo or relinks the
command. Changes meant for the team now have to be ported to that repo by hand.

## 2026-09-06 — added Karen

Added an adapted version of
[`darcyegb/ClaudeCodeAgents`' Karen agent](https://github.com/darcyegb/ClaudeCodeAgents/blob/master/karen.md)
for independent completion checks in Claude Code and Cursor.

The local version keeps the execution-first reality check and allows a clean pass. It drops
references to sibling agents that are not installed, adds explicit read-only and
non-destructive boundaries, narrows source inspection to explaining observed behavior, and
requires evidence-backed findings without a fixed report template. The upstream MIT notice
is recorded in `THIRD_PARTY_NOTICES.md`.

## 2026-08-26 — comment-sweep had the agent contract backwards

CodeRabbit reviewed the team-repo PR and raised six things. Four were real, and chasing one
of them turned up a bug it had not spotted.

**Step 4.3 said "apply the accepted deletions". Sicko has already applied them.** Upstream's
own `no-comments` skill says "inspect its report **and diff**" and "restore deletions only
with exact exceptions" - the agent edits in place and the caller puts back what it rescues.
Sicko's own text agrees: "I touch comments", "name touched files". The line reading the other
way, "I do not touch the code", is about the `MUST KILL` refactor it declines to perform, not
about comments. So the skill described an inverted workflow that every run so far has had to
improvise past. Step 4.2 now audits the report *and the diff*, 4.2's rescues *restore* rather
than *keep*, and 4.3 is explicit that the only edit at that point is putting comments back.

**The keep-list path was hardcoded.** It pointed at one tool's agents directory, so a Cursor
run would read a path that does not exist. It now names the file and lets the tool resolve it.
This also removes the only divergence between this copy and a shared one.

**The 60% kill-rate gate was not a gate.** "Show the user before committing" has no approval
step and no rejection path. It now stops, waits for explicit approval, and says what to do
when refused - restore, or `git checkout -- <scope>`, and stop the sweep.

**Single pass skipped all of section 3**, including the check command that step 4.5 then runs,
and any look at the tree state. It now takes both from section 3, with `--diff` exempt from
the clean-tree rule since sweeping uncommitted work is its purpose.

**Sicko gained an interpreter-directive clause.** `#!/usr/bin/env bash` starts with `#`, the
survey treats `#` as shell comment syntax, and nothing in the keep list protected it. Never hit
because every run so far has been TypeScript. Worded to exclude lint suppressions, which stay
meat.

**Not changed.** CodeRabbit wanted the agent's report to identify each deletion by file and
range; the diff already does that, and requiring both rebuilds the duplication that broke this
skill the first time. Its markdownlint fence-language note applied to the team repo's README
only. Its `SkillSpector` "unauthorized session persistence" warning is step 3 creating a git
branch.

**Untested.** The corrected contract has not been through a run. The three runs behind the
current tuning happened under the inverted wording.

## 2026-08-26 — comment-sweep shared with the team, survey block repaired

`comment-sweep` and `comment-sicko` copied into `brewdigital/skills` (PR #3) with the MIT
licence and credit for the original, and a README section on what was retuned and why. The
team copy points at `~/.claude/agents/comment-sicko.md` rather than `~/.agents/...`, since
they symlink from the repo clone. That one line is the only divergence; keep it that way.

The `[[:space:]]` warning added earlier today had been dropped *between* the two survey
commands, orphaning the `find` line outside its code block. Both commands are together
again with the note after them.

## 2026-08-26 — added 8 of jakubkrehel/skills, dropped `oklch-skill`

`jakubkrehel/skills` is eleven interface skills. Took eight, 37 skill dirs now.

**Auto-firing:** `better-interface` (orchestrator), `better-colors`, `better-layout`,
`better-typography`, `better-writing`.
**Manual only:** `interface-review`, `break`, `explain-interface` — all three carry
`disable-model-invocation: true`, so they are in the AGENTS.md pointer table.

**`better-colors` replaces `oklch-skill`.** Same author, superset: six reference files to
oklch's four, adding token naming, colour usage, palette structure and contrast, and still
oklch-native throughout. Keeping both would have put two overlapping skills on the same
triggers. `oklch-skill` was installed the same day and lasted about an hour.

**Left out, all three for collisions with what is already here:**

- `better-ui` — overlaps `emil-design-eng` and the three animation skills. Its
  `animations.md` is 205 lines and `surfaces.md` 219, so this is real duplication, not a
  different angle.
- `variant` — near-identical brief to `prototype`: both user-invoked, both build several
  genuinely different versions behind a picker.
- `better-accessibility` — overlaps `accessibility` (addyosmani). Different flavour, but
  they compete on the same triggers.

**Known consequence.** `better-interface` routes to six domain skills; two of them
(`better-accessibility`, `better-ui`) are not installed, so it will report those domains
`Not reviewed`. That is by design — the skill is explicitly forbidden from recreating a
missing owner's rules from memory — and it is the right failure mode. It means a
`better-interface` run covers four of six domains, and accessibility and motion still need
`accessibility` and `review-animations` run separately.

Install via the CLI, not the Claude Code plugin. The plugin namespaces everything as
`/interfaces:break` and installs outside this pool, so `bootstrap.sh` would not rebuild it.

## 2026-08-26 — added `oklch-skill`

`jakubkrehel/oklch-skill`, 30 skills now. OKLCH conversion, palette generation, contrast
checking, gamut handling, Tailwind v4 theming. Fires on its own; four reference files
behind a 90-line SKILL.md, so it costs nothing until a colour question shows up.

The installer reported `PromptScript does not support global skill installation` as a
failure. Ignorable — PromptScript is one of ~17 agent targets the CLI tries, and the pool
does not use it.

## 2026-08-26 — comment-sweep: the audit was overruling the agent

First real runs, against `accessibility-tool`, deleted 97% of `app/lib/client` and 95% of
`app/components/ui` — including a documented Chrome download race, a React hydration note,
and the ARIA live-region contract on `Alert`'s `role` prop. On an accessibility product.

**Cause: the keep list existed twice and the copies had drifted.** Sicko carries five keep
clauses; the skill's step 4.2 restated three, having lost *public API doc comments* and
*issue/RFC links*. So the audit's own criteria told it to delete what the agent had
correctly spared. Fixed by deleting the skill's copy and pointing at the agent definition —
syncing two lists only rebuilds the drift. The skill already said "Do not restate its rules"
one line earlier.

**Doubt is now visible.** Sicko still kills on doubt, but brands those kills `UNSURE` and
names the clause that nearly saved each. Previously "when unsure, delete" fired in both the
agent and the audit with nothing between them; now the first proposes and the second
decides.

**Kill-rate gate at 60%**, checked before the commit, so the pilot batch's calibration does
something. It is one-sided by design — it catches a sweep that deletes too much, not one
that has gone timid.

**Sicko gained a keep clause** for domain and regulatory facts the code cannot derive: a
spec clause, a standard's threshold, an externally-set rate. WCAG citations and measured
contrast ratios are the case that prompted it.

**Result, same scopes, same base:** `app/lib/client` 97% → 89% (21 → 81 lines kept, four
`UNSURE` rescues), `app/components/ui` 95% → 76% (65 → 290). Prop-level TSDoc contracts
survived; component docs restating the component's own name did not. The gate fired on both.

**Two follow-on fixes from the `ui` run.** The audit checked stated reasons in one direction
only: it rejected false reasons for *deleting* and said nothing about false reasons for
*keeping*. A `biome-ignore` on `RadioGroup.tsx` survived on the excuse "Base UI Radio.Root
is the control element", which `Switch.tsx`'s own surviving comment disproves in the same
PR — `<label>` does not name a `<button>`, so every option is unnamed. Reasons are now
checked both ways, and Sicko treats a suppression's excuse as a claim to test. Separately,
single-pass mode said "no confirmation round" while step 4.6 said stop above 60%; the gate
now explicitly survives single pass.

## 2026-08-26 — Cursor global rules, and a stale skill pointer

**`AGENTS.md` pointed at a skill that no longer exists.** The "diff has grown noisy
comments" row named `no-comments`, removed on 25 Aug when `comment-sweep` superseded it,
while `comment-sweep` itself — one of the five that cannot self-fire — was listed nowhere.
Row corrected. The other nine were checked against `skills/` and all resolve.

**Cursor's Rules UI moved.** `Settings > Rules > User` is gone; user rules now live in the
Customize panel, scope dropdown set to your own name, `+ New`. Still app config rather than
a file, so `bootstrap.sh` still cannot write them. Corrected in `AGENTS.md`, `README.md`
(×3, including an MCP reference to `Settings > MCP`) and `bootstrap.sh`. The August entry
below is left as written — it was true then.

**`cursor-user-rule.txt` added.** That input is a single-line style field, so the `AGENTS.md`
table does not survive a paste. The new file holds the same content flattened to one
paragraph. It is hand-maintained, not generated: edit `AGENTS.md` and it must be updated and
re-pasted, and nothing checks that. Now live in Cursor, which had zero user rules before.

**British English convention dropped** from both files, at the user's call while pasting.

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

## Portability 2026-08-25

`~/.agents` is now a git repo with `bootstrap.sh` + `skills.manifest`.

Skills are gitignored, not committed: they are upstream copies, and committing them would
duplicate upstream and churn on every `skills update`. `skills.manifest` (name -> source)
is enough to rebuild them through the CLI, which also gives each a `skillFolderHash` so
`skills update` keeps working. `.skill-lock.json` is gitignored as machine-local state.

`skills experimental_install` was evaluated and rejected: it restores from a project
`skills-lock.json`, not the global `.skill-lock.json`, so it cannot rebuild this pool.

Tested end to end against an isolated HOME (`/tmp/fakehome`), not just written. That caught
a real bug: `npx skills add` reads stdin, and inside `while read < manifest` it swallowed
the remaining lines, so only the first skill installed. Fixed with `</dev/null` on the npx
call. Retested: 4/4 skills, 3 commands, 1 agent, 3 codex prompt copies, 0 broken links,
idempotent on re-run.

Also confirmed the CLI exits 0 on success despite printing
"Failed to install 1 - PromptScript does not support global skill installation".
That line is noise from a tool we do not use; bootstrap checks the directory exists rather
than trusting the exit code.

Remote: git@github.com:brew-martin/agent-config.git (private, brew-martin).
Pushed after a secret scan over all tracked files - clean. Only identifiable content is
the home path and the brewdigital/skills clone URL, both acceptable in a private repo.
`skills/` and `.skill-lock.json` confirmed absent from the remote.
