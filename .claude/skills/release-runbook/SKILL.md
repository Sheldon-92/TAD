---
name: release-runbook
description: Release + sync runbook for TAD framework. Read BEFORE starting *publish or *sync. Contains the full pre-flight checklist, version-bump file list, sync strategy matrix, known gotchas (jq flags, tad.sh bugs, deprecation mechanics), and post-flight verification. Prevents the recurring errors from past releases.
---

# TAD Release + Sync Runbook

**Purpose**: When you're about to release a new TAD version and sync it to downstream projects, **read this file first**. It captures every gotcha we've hit across past releases.

**When to use**: Before any `*publish`, `*sync`, or manual release work. Alex should `Read .claude/skills/release-runbook/SKILL.md` at the start of any release task.

---

## 📋 The 7 Phases of a TAD Release

Follow in order. **Do not skip phases.** Each phase has a gate — if the check fails, stop and fix before continuing.

```
Phase 1: Pre-flight      (verify state clean, decide version)
Phase 2: Version Bump    (update ALL version references atomically)
Phase 3: CHANGELOG       (document what changed)
Phase 4: Publish         (commit → push → tag → push tag)
Phase 5: Sync Script     (build per-project sync operations)
Phase 6: Execute Sync    (run against all registered projects)
Phase 7: Verify          (post-flight check each project actually works)
```

---

## Phase 1 — Pre-flight

### ⚠️ Guard 0: TAD-main-only check (runs BEFORE anything else)

`*publish` and `*sync` only make sense in the TAD source repo. Running them in a downstream project (menu-snap, ArtForge, etc.) is dangerous:
- `*publish` would push to the wrong git origin
- `*sync` would treat the downstream project as the source and overwrite OTHER projects with its files

**Check before any phase**:
```bash
ORIGIN=$(git config --get remote.origin.url 2>/dev/null || echo "none")
echo "$ORIGIN" | grep -q "Sheldon-92/TAD" || {
  echo "❌ This is not the TAD source repo. Refusing to run publish/sync."
  exit 1
}
```

This guard is also enforced in `alex/SKILL.md` `publish_protocol.prerequisite.tad_main_guard` and `sync_protocol.prerequisite.tad_main_guard` — Alex will refuse to proceed in downstream projects.

### Checklist (all must pass before continuing)

- [ ] TAD-main guard passed (see above)
- [ ] `git status --short` is clean (or only intentional changes)
- [ ] `git log origin/main..HEAD` shows the commits you intend to release
- [ ] Current version identified: `cat .tad/version.txt`
- [ ] New version decided (patch/minor/major per semver)
- [ ] `.tad/sync-registry.yaml` exists and lists all downstream projects
- [ ] `.tad/deprecation.yaml` is valid YAML (try `yq . .tad/deprecation.yaml`)
- [ ] Pack registry drift-check run (advisory): `bash .tad/hooks/lib/pack-registry-driftcheck.sh` — exit 1 = registry/pack desync to review (run `bash .tad/scripts/scan-packs.sh` to regenerate), NOT a release blocker.
- [ ] **If this release touches `tad.sh` or `derive-sync-set.sh`:** installer deny-list drift-check passes: `bash tad.sh --verify-denylist` (exit 0 = in sync; exit 1 = DRIFT → fix BOTH copies before tagging). HARD BLOCK.

### Decide the version bump

- **Patch (Z+1)**: bug fix, docs, infra tweaks. No user-facing behavior change
- **Minor (Y+1, Z=0)**: new feature, backward-compatible
- **Major (X+1, Y=0, Z=0)**: breaking change

When in doubt, ask the user.

---

## Phase 2 — Version Bump (CRITICAL)

⚠️ **Version number is duplicated in 6 places**. Miss any one = stale release. This is the #1 source of release bugs.

### Derive + Verify (authoritative — self-deriving, replaces the hardcoded table)

> The hardcoded 18-item table below went stale repeatedly (config.yaml stuck at 2.8.0). The
> AUTHORITATIVE procedure is **grep-derivation + a zero-stale verification gate**, not a hand-typed list.

```bash
OLD="$(cat .tad/version.txt | tr -d '[:space:]')"   # or the prior released version
NEW="X.Y.Z"

# 1. ENUMERATE every ref to bump (derived, not from a list):
grep -rlF "$OLD" . --exclude-dir=.git

# 2. Bump all of them to $NEW.

# 3. VERIFY zero non-historical stragglers (the gate — must print PASS / exit 0):
bash .tad/hooks/lib/release-verify.sh version "$PWD" "$NEW" "$OLD"
```

`release-verify.sh version` greps the repo (minus `.git` minus the zero-touch dirs it reads from
`derive-sync-set.sh --zero-touch` — NOT a second hardcoded list) and reports any stale `$OLD` ref as
`file:line`. **Version Exclusion Contract**: a `$OLD` hit is ignored ONLY IF it is BOTH (a) in a file whose
basename ∈ `{README.md, INSTALLATION_GUIDE.md, CHANGELOG.md}` AND (b) the line is a markdown history-table
ROW (`^[[:space:]]*\|.*v?[0-9]+\.[0-9]+\.[0-9]+.*\|`). A `$OLD` in any other file, or in a non-table/prose
line of those three files, is ALWAYS reported (this is exactly the `tad.sh` / `config.yaml` live-assignment
class that historically went stale). Exit 0 = clean, exit 1 = stale (named), exit 2 = usage (fail-CLOSED).

### Full list of files containing version references

> ⚠️ **DERIVED — illustrative only / non-authoritative.** Authoritative source:
> `grep -rlF "$OLD"` enumeration + `release-verify.sh version` (above). Do NOT hand-maintain this table —
> it is a snapshot for orientation only and WILL drift as the doc structure evolves (which is the disease
> this Phase exists to kill). The gate, not this list, is the guarantee.

| # | File | What to look for |
|---|------|------------------|
| 1 | `.tad/version.txt` | Replace entire content |
| 2 | `.tad/config.yaml` line 1 | `# TAD Configuration vX.Y.Z - <tag>` |
| 3 | `.tad/config.yaml` line 3 | `version: X.Y.Z` |
| 4 | `.tad/config.yaml` line 5 | `last_updated: YYYY-MM-DD` |
| 5 | `README.md` header | `**Version X.Y.Z - <tag>**` |
| 6 | `README.md` tree comment | `# vX.Y.Z configuration` |
| 7 | `README.md` version history | `\| **vX.Y.Z** \| <new entry> \|` |
| 8 | `README.md` footer | `Welcome to TAD vX.Y.Z - <tag>` |
| 9 | `INSTALLATION_GUIDE.md` header | `**Version X.Y.Z - <tag>**` |
| 10 | `INSTALLATION_GUIDE.md` structure section | `### .tad文件夹结构 (vX.Y.Z)` |
| 11 | `INSTALLATION_GUIDE.md` upgrade instructions | `从任何旧版本升级到 vX.Y.Z` |
| 12 | `INSTALLATION_GUIDE.md` summary | `TAD vX.Y.Z 核心特性：` |
| 13 | `.claude/skills/tad-help/SKILL.md` template | `Version: vX.Y.Z` |
| 14 | `.claude/skills/tad-help/SKILL.md` highlights | `## TAD vX.Y.Z Highlights` |

### Quick grep to find stragglers

After bumping, run this to confirm no stale refs:

```bash
grep -rnE "v?[0-9]+\.[0-9]+\.[0-9]+" \
  .tad/version.txt .tad/config.yaml README.md INSTALLATION_GUIDE.md \
  .claude/skills/tad-help/SKILL.md \
  2>/dev/null \
  | grep -vE "^[^:]*:[0-9]+:# " \
  | grep -v "/2.8.1\|/2.8.0\|/2.7.0\|/2.6.0\|/2.5.0\|/2.4.0\|/2.3.0\|/2.2\|/2.1\|/2.0\|/1.8"
```

The remaining hits should **all** be the new version.

### Known past bug

`.tad/config.yaml` stayed at `2.8.0` across the 2.8.1 release because it wasn't in anyone's checklist. This is why the list above is exhaustive — **do not trust memory, grep every file**.

---

## Phase 3 — CHANGELOG

### Required format

```markdown
## [X.Y.Z] - YYYY-MM-DD

### New Features (if any)
- ...

### Bug Fixes (if any)
- ...

### Breaking Changes (if major)
- ...

### Documentation
- ...
```

### Gotchas

- **Retroactive entries are OK**: if a past release was missing a CHANGELOG entry (like 2.8.1), add it now above the prior version entry. Honest audit trail > pristine history.
- **Mention known bugs being fixed**: if this release fixes a bug introduced earlier, link back: "Fixes issue in 2.8.1 where ..."
- **Keep it user-facing**: commit hashes go in git log, not CHANGELOG. CHANGELOG describes behavior changes.

---

## Phase 4 — Publish (Git Operations)

### Sequence (atomic — do not skip steps)

```bash
# 1. Stage all version bump + CHANGELOG changes
git add .tad/version.txt .tad/config.yaml README.md INSTALLATION_GUIDE.md \
        CHANGELOG.md .claude/skills/tad-help/SKILL.md \
        # + any other Phase 2 files touched

# 2. Verify staged matches intent
git diff --cached --stat

# 3. Commit with conventional message
git commit -m "chore: release vX.Y.Z — <one line summary>"

# 4. Push main
git push origin main

# 5. Create annotated tag (NOT lightweight)
git tag -a vX.Y.Z -m "vX.Y.Z — <description>"

# 6. Push tag (often forgotten!)
git push origin vX.Y.Z
```

### Gotchas

- **Tag push is a SEPARATE step** — `git push origin main` does NOT push tags. Always follow with `git push origin vX.Y.Z`.
- **Annotated tags only** (`-a`) — lightweight tags don't show up in GitHub release lists.
- **Never force-push main** — if you need to amend, commit on top.
- **Double-push safety**: if `git push origin main` fails due to remote ahead, `git pull --rebase` first, never `git pull` (creates merge commits).

---

## Phase 5 — Sync Script (Build the Per-Project Operation)

### Derive + Verify (authoritative — self-deriving sync set + structural gate)

> The framework-dir list below went stale repeatedly (`codex` frozen a month). The AUTHORITATIVE sync
> set is **DERIVED** from the live `.tad/` tree minus a single hand-maintained DENY_LIST, then **VERIFIED**
> structurally. A new framework dir is auto-included with ZERO list edits (bias-to-sync); an omitted dir
> HARD-BLOCKS the release.

```bash
# 1. DERIVE the SYNC dir set (single source of truth = derive-sync-set.sh DENY_LIST):
bash .tad/hooks/lib/derive-sync-set.sh --dirs        # one basename per line (consumed format)
bash .tad/hooks/lib/derive-sync-set.sh --report      # the 3-category audit view (REPORT each run)

# 2. GENERATE the per-release one-shot script FROM the derived set (not a hand-typed list).
#    Write it under .tad/evidence/releases/ (zero-touch ⇒ NOT itself synced; keeps scripts/ framework-clean):
#      .tad/evidence/releases/sync-vX.Y.Z.sh   ← cp -R each derived dir + capability-packs/pack-registry.yaml

# 3. After the verbatim cp -R copy into each target, VERIFY structurally (the omission-catcher):
bash .tad/hooks/lib/release-verify.sh structural "$TAD_SRC" "$target"   # exit 0 = no omission; exit 1 = named drift
```

**Special cases (handled by `derive-sync-set.sh`, READ — never re-hardcode):**
- `capability-packs/` → sync/diff ONLY `pack-registry.yaml` (the registry index), never the pack tree.
  Exposed once via `derive-sync-set.sh --registry-only`; `release-verify.sh structural` + the generator READ it.
- The version-scope zero-touch exclusion comes from `derive-sync-set.sh --zero-touch` (same DENY_LIST source).
- Per-release one-shot scripts → `.tad/evidence/releases/`, NOT `scripts/`.

**Three-gate composition (publish-side intra-repo consistency — no source-consistency hole):** At `*publish`
there is NO target tree to diff, so `structural` is **sync-only by design**. Publish-side source-consistency
= **step3b (codex parity, `release-verify.sh parity [--fix]`)** + **step3c (version zero-stale, `release-verify.sh version`)** + **scan-packs
registry regen** — these cover the cross-vendor / version / registry-vs-tree axes respectively. `structural`
(source-vs-target byte-identity) runs sync-only, AFTER the verbatim `cp -R`. There is NO publish-time
source-consistency hole.

**First-real-release cutover note (`TAD_RELEASE_GATE=warn`):** This gate has minor+ HARD-BLOCK authority but
has never run against a real installed downstream. For the FIRST real minor+ `*publish`/`*sync` after this
change, run with `TAD_RELEASE_GATE=warn` (downgrades block→warn: report the verdict + named paths, but
proceed), compare the gate's verdict against a manual check, then **UNSET it** (flip back to hard-block) for
all subsequent releases. This is ship-the-detector-in-shadow-mode-before-it-gates.

### The mixed strategy (codified from past experience)

> ⚠️ **DERIVED — illustrative only / non-authoritative.** The framework-dir rows below are a SNAPSHOT.
> Authoritative source: `derive-sync-set.sh --dirs` (live-derived from `.tad/` minus DENY_LIST) +
> `release-verify.sh structural`. Do NOT hand-maintain this table — a hardcoded dir list is precisely the
> stale-list disease (codex was frozen for a month). The gate, not this table, is the guarantee.

For each downstream project, apply these operations in order. **Do not deviate — each category has a reason.**

| Operation | Files / Paths | Reason |
|-----------|---------------|--------|
| **Incremental copy** (new files) | `.tad/hooks/*.sh`, `.tad/hooks/*.yaml` | New files added this release |
| **Full refresh** (overwrite whole dir) | `.tad/agents/`, `.tad/data/`, `.tad/domains/`, `.tad/gates/`, `.tad/guides/`, `.tad/hooks/`, `.tad/ralph-config/`, `.tad/references/`, `.tad/schemas/`, `.tad/skills/`, `.tad/sub-agents/`, `.tad/tasks/`, `.tad/templates/`, `.tad/workflows/` | Framework dirs — always replace from source |
| **Full refresh** (`.claude/`) | `.claude/skills/*` | Skill files always replaced |
| **JSON merge** | `.claude/settings.json` | Must preserve project-specific hooks (PreToolUse/PostToolUse/SessionStart custom). Only add/update TAD-owned hooks (UserPromptSubmit, etc.) |
| **Strict delete** | Files listed in `.tad/deprecation.yaml` for versions ≤ current | Retroactive cleanup of renamed/removed files |
| **Conditional update** | `CLAUDE.md` (per `claude_md_strategy` in sync-registry) | `overwrite` = replace whole file; `merge` = replace content above `<!-- TAD:PROJECT-CONTENT-BELOW -->` marker, preserve below |
| **Top-level config files** | `.tad/*.yaml`, `.tad/*.md`, `.tad/*.txt` | Simple copy |
| **Update target version** | `.tad/version.txt` in each project | Last step |

### Zero-touch list (NEVER copy / overwrite these)

- `.tad/project-knowledge/` — project-specific accumulated knowledge
- `.tad/active/` — in-flight work (handoffs, epics, ideas)
- `.tad/archive/` — historical record
- `.tad/evidence/` — task execution evidence
- `.tad/pair-testing/` — session reports
- `.tad/decisions/` — project decision records
- Any `.claude/commands/*.md` NOT listed in deprecation.yaml — user-custom commands
- Any `.claude/settings.json` hook entries that are not TAD-owned events

### Critical gotcha: `jq --argfile` is REMOVED in jq 1.7+

**Never use `jq --argfile`**. It will silently fail on modern macOS. Use one of:

```bash
# Option A: --argjson (load via command substitution)
SRC_HOOK=$(jq -c '.hooks.UserPromptSubmit' "$SOURCE_SETTINGS")
jq --argjson h "$SRC_HOOK" '.hooks.UserPromptSubmit = $h' "$TARGET_SETTINGS"

# Option B: --slurpfile (load from file as array)
jq --slurpfile src "$SOURCE_SETTINGS" \
  '.hooks.UserPromptSubmit = $src[0].hooks.UserPromptSubmit' "$TARGET_SETTINGS"
```

**Quick version check before writing any jq script**: `jq --version`. If ≥ 1.6, assume `--argfile` is gone.

### Critical gotcha: tad.sh historically missed deprecations

Pre-2.8.2, `tad.sh::copy_framework_files()` **did not read `.tad/deprecation.yaml`**. The 2.8.1 release added deprecation entries but the script never processed them, so downstream projects kept 18 obsolete command files for weeks.

**2.8.2 fix**: `tad.sh` now has `apply_deprecations()`. But:
- The fix only applies during `tad.sh`-based install (new machines, curl-pipe install)
- When manually sync'ing from Alex (as Phase 6 below), **the sync script must also apply deprecations explicitly**
- Do not trust that "the framework handles it" — always include the delete loop in your sync script

### Critical gotcha: tad.sh historically missed directories — FIXED in 2.21.0+ (self-deriving)

Pre-2.8.2 `copy_framework_files()` had a hardcoded 14-dir allow-list missing `hooks/` and `domains/`.
By 2.21.0 it had silently drifted to omit `codex cross-model context tests scripts capability-packs` — the
same omission disease as the sync allow-list.

**2.21.0 fix (Epic self-deriving-release-sync P2):** `tad.sh::copy_framework_files()` now **DERIVES** the
copy-set from a deny-list — `{ ls -d .tad/*/ } − DENY_LIST` — exactly mirroring
`.tad/hooks/lib/derive-sync-set.sh`. A new framework dir auto-copies with **zero list edits**. Three new pieces:

1. **Inlined deny-list** (`TAD_DENY_LIST` in tad.sh). tad.sh runs via `curl | bash` on a fresh machine where
   `.tad/hooks/lib/` does NOT exist yet, so it CANNOT `source` the lib — the DENY_LIST is **embedded verbatim**.
2. **`TARGET_VERSION` from source** (`derive_target_version`) — read from the downloaded `.tad/version.txt`
   at install time, not the hand-edited literal (kills the 2.19.1-class straggler). Literal kept as fallback.
3. **Post-install self-check** (`verify_install_complete`) — after copy, asserts every derived framework dir
   exists + is non-empty in the target; **fails the install** (non-zero → rollback trap) on any omission.

> ⚠️ **DERIVED — illustrative only / non-authoritative.** The list below is a stale snapshot, NOT the source
> of truth. Run `bash .tad/hooks/lib/derive-sync-set.sh --dirs` for the live framework set. Do NOT hand-maintain.

```
agents data domains gates guides hooks ralph-config references schemas skills sub-agents tasks templates workflows
```

#### Release-time drift check (MANDATORY before publishing tad.sh changes)

Because the DENY_LIST now exists in **two places** (the lib + tad.sh's inlined copy), they can silently drift.
A release-time guard asserts they stay identical — run from the TAD repo root:

```bash
bash tad.sh --verify-denylist     # exit 0 == in sync; exit 1 == DRIFT (names both sides); fail the release
```

This is a **repo-only** check (it reads `.tad/hooks/lib/derive-sync-set.sh`), NOT run at install time on a
fresh machine. Add it to the Phase 1 pre-flight whenever a release touches `tad.sh` or `derive-sync-set.sh`.
If you edit DENY_LIST in either file, edit **both** or this check FAILS.

---

## Phase 6 — Execute Sync

### Reference implementation (the one from 2.8.2 release, known working)

Full working script is in the 2.8.2 release notes. Key features to preserve in future versions:

1. **Reads project list from `.tad/sync-registry.yaml`** — not hardcoded
2. **Per-project backup** before settings.json merge
3. **`jq --argjson`** (not `--argfile`) for hook merge
4. **Deprecation cleanup from `.tad/deprecation.yaml`** — do not inline the file list; read dynamically
5. **Continue-on-error** — one broken project doesn't abort the rest (use `set -u` not `set -e`)
6. **Summary output** — count success/fail, list any warnings

### What to watch for during execution

- **`merge` strategy CLAUDE.md projects without marker**: projects using `claude_md_strategy: "merge"` but lacking `<!-- TAD:PROJECT-CONTENT-BELOW -->` marker will have CLAUDE.md left untouched. This is a warning, not an error. Report to user at end.
- **Project-specific `.claude/commands/*.md`**: these are user's custom commands (e.g., Sober Creator has `chief.md`, `produce.md`). Do not touch files not in `deprecation.yaml`.
- **Project-specific `.claude/settings.json` hooks**: if user has custom PreToolUse / PostToolUse hooks, preserve them. Only merge in TAD-owned event types.

### Common failure modes

| Symptom | Cause | Fix |
|---------|-------|-----|
| Silent "jq merge failed" on every project | `--argfile` in jq 1.7+ | Use `--argjson` |
| Hook not firing after sync | `.claude/settings.json` missing the new hook | Check `jq '.hooks \| keys' .claude/settings.json` |
| Deprecated commands still present | Sync script forgot the delete loop | Add explicit `rm -f` for each file in deprecation.yaml |
| Version mismatch after sync | `.tad/version.txt` not updated in target | Add final `echo "$NEW_VERSION" > target/.tad/version.txt` step |
| Wrong TAD commands in downstream | Sync didn't delete old files + didn't copy new skills | Both issues — run full Phase 5 strategy, don't shortcut |

---

## Phase 7 — Verify (MANDATORY — do not skip)

### Per-project verification checklist

For each project in the registry, verify:

```bash
# 1. Version matches source
[ "$(cat "$project/.tad/version.txt" | tr -d '[:space:]')" = "$NEW_VERSION" ]

# 2. New hooks present and executable
[ -x "$project/.tad/hooks/userprompt-domain-router.sh" ]

# 3. Keywords database exists with expected pack count
[ "$(yq '.packs | length' "$project/.tad/hooks/keywords.yaml")" = "20" ]

# 4. UserPromptSubmit hook in settings.json
[ "$(jq -r '.hooks.UserPromptSubmit[0].hooks[0].type' "$project/.claude/settings.json")" = "command" ]

# 5. No deprecated files
for dep_file in $(yq ".deprecations.\"$NEW_VERSION\".files[]" .tad/deprecation.yaml); do
  [ ! -e "$project/$dep_file" ] || FAIL
done

# 6. Live smoke test — hook actually works
# passive mode (2.8.4): hook does NOT emit stdout context. Smoke target is the .router.log line written by the keyword scoring path.
echo '{"prompt":"做一个 React button 组件","session_id":"","transcript_path":"","cwd":"","permission_mode":"","hook_event_name":"UserPromptSubmit"}' \
  | bash "$project/.tad/hooks/userprompt-domain-router.sh" >/dev/null
tail -1 "$project/.tad/hooks/.router.log" 2>/dev/null | grep -q "web-frontend"
```

### Summary table format (print to user)

```
PROJECT                VERSION    CMDS         HOOK       KEYWORDS   SMOKE
-----------------------------------------------------------------------------
menu-snap              2.8.2      0 TAD        ✅          ✅          ✅
...
```

Anything not green → **do not close the release**. Investigate and re-sync.

### Final step: update sync-registry.yaml

```bash
# Bulk update last_synced_version + date
sed -i '' \
  -e 's/last_synced_version: "X.Y.W"/last_synced_version: "X.Y.Z"/g' \
  -e "s/last_synced_date: \".*\"/last_synced_date: \"$(date +%Y-%m-%d)\"/g" \
  .tad/sync-registry.yaml

git add .tad/sync-registry.yaml
git commit -m "chore: sync vX.Y.Z to all N registered projects"
git push origin main
```

---

## 🛡️ Top 10 Gotchas (read before every release)

1. **Version bump touches ~14 strings across 6 files** — use the exhaustive list in Phase 2, do not rely on memory
2. **`jq --argfile` is removed in jq 1.7+** — use `--argjson` or `--slurpfile`
3. **`git push origin main` does NOT push tags** — follow with `git push origin vX.Y.Z`
4. **Deprecation cleanup must be explicit in sync script** — do not assume tad.sh handles it (it didn't pre-2.8.2, and even post-fix, Alex's manual sync bypasses tad.sh)
5. **Zero-touch directories are sacred**: `project-knowledge`, `active`, `archive`, `evidence`, `pair-testing`, `decisions`, project-custom commands, project-custom settings hooks
6. **`merge` CLAUDE.md without marker = silent no-op** — warn user at end of sync
7. **Post-flight verify is not optional** — if you skip Phase 7, you cannot claim the release is done (we shipped a "complete" release once with an uncommitted Epic phase edit — the user caught it)
8. **Always check `git status` after commit** — if something is still dirty, you missed staging a file
9. **`.tad/config.yaml` has 3 version mentions** (comment line + `version:` field + `last_updated:`) — all 3 must match
10. **Never run `tad.sh` on the TAD source repo itself** — it's designed for downstream targets, and self-application may delete source files via deprecation cleanup

---

## 🧭 When to use this runbook

### MUST use

- Any time you run `*publish` or `*sync`
- When bumping version for any reason
- When fixing a release-gone-wrong (e.g., downstream projects missing files)
- After adding new Domain Packs, new hooks, or new framework files that need distribution

### Nice to use

- Before creating a deprecation.yaml entry (verify you understand when it takes effect)
- When adding a new downstream project to the registry
- When a user reports "feature X doesn't work in project Y" (likely a sync gap)

---

## 📜 Revision history

- **2026-04-08**: Initial version. Captured from 2.8.2 release retrospective. Covers 7 phases, 10 gotchas, the exhaustive version-bump file list, and reference sync implementation from the known-working 2.8.2 sync script.

## Related

- `.tad/sync-registry.yaml` — project list for sync
- `.tad/deprecation.yaml` — file cleanup registry
- `.claude/skills/alex/SKILL.md` — `*publish` and `*sync` protocol definitions
- `tad.sh` — curl-pipe installer (also handles install-time sync and deprecation)
- `CHANGELOG.md` — user-facing change history
