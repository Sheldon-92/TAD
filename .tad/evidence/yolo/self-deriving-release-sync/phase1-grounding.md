# Phase 1 Grounding — Self-Deriving Release/Sync

**Conductor-written grounding (YOLO Y2). Source of truth for the design sub-agent (Y3).**

## The disease, quantified (2026-06-01)
The old sync used a hardcoded 14-dir allow-list: `agents data domains gates guides hooks ralph-config
references schemas skills sub-agents tasks templates workflows`. Scanning the ACTUAL `.tad/` tree shows
**33 dirs** — so the allow-list silently omitted ~12 dirs, not just `codex`. This is the root cause the
Epic kills.

## THREE-CATEGORY classification (Conductor decision — authoritative for P1 deny-list)

The naive "deny-list = everything except 6 zero-touch" is WRONG — it would push main-only/transient dirs
(github-registry, research-notebooks, spike-v3, working) to downstream. Correct model = THREE categories.

### A. zero-touch — project data, NEVER sync (preserve target's own)
`project-knowledge`, `active`, `archive`, `evidence`, `pair-testing`, `decisions`,
`github-registry` (user's awesome-list scan DECISIONS — project/main data), `research-notebooks`
(user's NotebookLM REGISTRY — project-specific), + top-level `sync-registry.yaml` (main-only).

### B. framework — SYNC (these were the silently-omitted ones)
`agents data domains gates guides hooks ralph-config references schemas skills sub-agents tasks templates
workflows` (the old 14) + **`codex`** (the caught omission) + **`cross-model`** (codex/gemini guides) +
**`context`** + **`tests`** + **`scripts`** (framework scripts: scan-collisions.sh, pack-eval-runner.sh —
BUT see special-case below) + **`capability-packs`** (pack sources — BUT see special-case).

### C. transient / main-only — do NOT sync (not project data, not framework-to-distribute)
`working` (scratch), `spike-v3` (a finished spike's 74 artifacts — main's research, shouldn't propagate),
`reports` (empty), `checklists` (empty).

### Special cases (the design MUST handle explicitly)
- **`scripts/`**: holds BOTH framework scripts (scan-collisions.sh, pack-eval-runner.sh) AND per-release
  one-shot scripts (sync-v2.21.0.sh — this session's). Decision: sync `scripts/` as framework, BUT the
  per-release one-shots are transient — the design should either (a) write per-release scripts to a
  transient location NOT in the synced set (preferred: `.tad/evidence/releases/` which is under evidence/ =
  zero-touch), or (b) a name-pattern skip. Preferred: **generate per-release scripts under
  `.tad/evidence/releases/` (zero-touch)**, keeping `scripts/` framework-clean.
- **`capability-packs/`**: the existing runbook says "registry index only — pack SOURCE dirs are NOT synced
  (packs install via `.claude/skills` install.sh)". Downstream menu-snap nonetheless has 299 files there
  (from a past install/sync). Decision: keep the existing rule — sync `capability-packs/pack-registry.yaml`
  ONLY, not the pack source dirs (packs reach downstream as installed `.claude/skills`). The deny-list must
  treat `capability-packs/` source dirs as skip-but-keep-registry. (This is the one dir where deny-list
  needs a sub-path rule.)

### Default for a FUTURE unclassified dir
Bias to the user's primary pain (framework dirs silently OMITTED): a new unclassified `.tad/` dir
**defaults to SYNC (framework)** — so the next `codex`-type dir is auto-included. The verification gate
MUST REPORT the synced dir set each run, so a newly-included dir is VISIBLE; if it turns out main-only, it
gets added to the explicit deny-list. (Default-to-sync fixes the omission disease; the report makes new
inclusions auditable.)

## Derivation rule (deny-list, structure-resilient)
```
SYNC_DIRS = { d in $(ls -d .tad/*/) } MINUS DENY_LIST
DENY_LIST = {project-knowledge, active, archive, evidence, pair-testing, decisions,
             github-registry, research-notebooks, working, spike-v3, reports, checklists}
plus sub-path rule: capability-packs → only pack-registry.yaml
plus top-level deny: sync-registry.yaml
```
A new framework dir (not in DENY_LIST) auto-joins SYNC_DIRS. No list edit needed.

## Version-bump derivation (kills the 18-item list + tad.sh straggler)
```
OLD=$(prev version); NEW=$(new version)
grep -rl "$OLD" <repo, excluding zero-touch + .git + CHANGELOG version-history + README version-history>
  → the FULL set of files to bump (auto-covers tad.sh, codex editions, any new ref)
bump each; then: grep -rn "$OLD" <same scope> excluding historical-version-history lines → MUST be empty
```
Historical-version refs (README/INSTALLATION version-history tables listing past versions) are the only
legit `$OLD` survivors — the grep-confirm must exclude those specific lines (anchor: lines in a
"version history" / "Changelog" table), not whole files.

## Verification primitives (stable lib — the "written-in-stone" structure-agnostic part)
- `release-verify.sh structural <src> <target>`: `diff -rq` over the DERIVED sync paths → exit 0 if
  identical, 1 + names missing/differing paths. Structure-agnostic (derives paths, doesn't hardcode).
- `release-verify.sh version <repo> <expected>`: grep for any non-historical stale version → exit 0/1.

## Anti-theater dogfood (AC4) — proves structure-resilience, NOT just today's structure
Inject synthetic `.tad/_synthtest/` (a fake new framework dir) + a synthetic `<OLD>` version ref into a
scratch file → confirm (a) derive-sync-set includes `_synthtest` with no list edit, (b) grep-version finds
the synthetic ref, (c) a sync that OMITS `_synthtest` → `release-verify.sh structural` exits 1 naming it.
Clean up `_synthtest` after.

## Key file locations (grounded 2026-06-01)
- `.claude/skills/release-runbook/SKILL.md`: Phase 1 L30, Phase 2 (version bump, 18-item table) L70,
  Phase 5 (sync mixed-strategy, 14-dir table) L183, Phase 7 (verify) L279.
- `.claude/skills/alex/SKILL.md`: `publish_protocol` L5155 (step3b parity gate L5234, Confirm&Execute L5254),
  `sync_protocol` L5278.
- `.tad/scripts/sync-v2.21.0.sh` (116 lines) — this session's brittle per-release script (the pattern to systematize).
- `.tad/hooks/lib/codex-parity-check.sh` — sibling pattern (per-owner derive + gate) to mirror for style.

## Scope guard
P1 builds the mechanism + dogfoods on SYNTHETIC dirs in the TAD repo ONLY. It does NOT run a downstream
sync (that happens at the next real release, where the new gate verifies). Blast radius = TAD repo.
