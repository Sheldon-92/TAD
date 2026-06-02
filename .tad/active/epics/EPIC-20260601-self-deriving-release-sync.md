# Epic: Self-Deriving + Self-Verifying Release/Sync

**Epic ID**: EPIC-20260601-self-deriving-release-sync
**Created**: 2026-06-01
**Owner**: Alex
**Decision Record**: DR-20260601-self-deriving-release-sync.md

---

## Objective
Kill the recurring "publish/sync silently misses files" disease by replacing TAD's hardcoded release
lists (14-dir allow-list, 18-item version-string list, per-file checklist) with **structure-derived rules**
(deny-list sync, grep-derived version bump) + **structure-agnostic verification gates** (`diff -r`
source==target, `grep` zero-stale) that HARD-BLOCK a release on any mismatch. The rules don't drift when
the doc structure evolves; the gate catches any omission regardless. Encoded as a `release-runbook` SKILL
upgrade (not a capability pack).

## Success Criteria
- [ ] Sync set is **deny-list derived** (everything under `.tad/` except zero-touch + sync-registry) — a new framework dir (e.g. a future `.tad/foo/`) is auto-included with no list edit
- [ ] Version bump is **grep-derived** (`grep -rl <old>` → bump → `grep` confirms zero stale) — a new version-ref location is auto-covered
- [ ] **Structure-agnostic verification GATE** blocks minor+ release/sync on mismatch (`diff -r` not empty / stale version found); advisory on patch; NOT a settings.json hook
- [ ] Each release **generates a fresh one-time script** from current structure; **verification primitives are a stable lib** in `.tad/hooks/lib/`
- [ ] `release-runbook` SKILL upgraded; old hardcoded tables **demoted to non-authoritative**
- [ ] **Anti-theater dogfood**: inject a synthetic new dir + new version-ref into source → deny-list auto-includes it, grep auto-covers it, gate would BLOCK if omitted (proves structure-resilience)
- [ ] `tad.sh` installer self-derives + post-install diff self-check (P2)

---

## Phase Map

| # | Phase | Status | Handoff | Key Deliverable |
|---|-------|--------|---------|-----------------|
| 1 | Core: derive-rules + verification lib + runbook upgrade + release gate | ✅ Done | HANDOFF-20260601-self-deriving-release-sync-phase1.md | Stable verification lib + deny-list sync + grep version bump + upgraded runbook + release-time gate in `*publish`/`*sync` |
| 2 | tad.sh installer self-derivation + post-install self-check | ✅ Done | COMPLETION-20260601-self-deriving-release-sync-phase2.md | tad.sh derives copy-set (inlined deny-list) + version-from-source + post-install self-check + `--verify-denylist` drift check (commit f053f50) |

### Phase Dependencies
Sequential. P1 builds the stable verification lib + derive-rules; P2 reuses the same lib/primitives in the
installer code path. P2 isolated (tad.sh is a separate code path — its own risk).

### Derived Status
- **Status**: Done (2/2 ✅)
- **Progress**: 2 / 2

---

## Phase Details

### Phase 1: Core — Derive-Rules + Verification Lib + Runbook Upgrade + Release Gate

**Status:** ⬚ Planned
**Execution:** pending

#### Scope
Build the stable, structure-agnostic verification primitives (`.tad/hooks/lib/`); convert the sync from a
14-dir allow-list to a deny-list (everything under `.tad/` except zero-touch + sync-registry); convert the
version bump from an 18-item list to grep-derivation; upgrade the `release-runbook` SKILL to the derive+verify
procedure (old tables demoted to non-authoritative); wire the verification as a release-time HARD-BLOCK gate
into `*publish` and `*sync`. NOT in scope: the tad.sh installer (P2).

#### Input
- `.claude/skills/release-runbook/SKILL.md` (current — 7 phases, hardcoded 18-item + 14-dir tables)
- `.claude/skills/alex/SKILL.md` (`publish_protocol` + `sync_protocol`)
- `.tad/scripts/sync-v2.21.0.sh` (this session's per-release script — the brittle pattern to systematize)
- DR-20260601-self-deriving-release-sync.md

#### Output
- `.tad/hooks/lib/` stable verification primitives:
  - structural sync verify (`diff -r` source-vs-target over deny-list-derived paths → 0/1)
  - version-consistency verify (`grep` for any stale version across the repo → 0/1)
- deny-list sync derivation (used to generate the per-release `sync-vX.Y.Z.sh`)
- grep-derived version-bump procedure
- upgraded `release-runbook` SKILL (derive+verify; tables demoted)
- release-time verification gate wired into `*publish` (pre-tag) + `*sync` (post-copy), minor+ HARD BLOCK

#### Acceptance Criteria
- [ ] AC1: deny-list derivation lists exactly {all `.tad/` dirs} − {zero-touch + sync-registry} + the framework root files; dogfood — `.tad/codex/` is auto-included WITHOUT being named in any list
- [ ] AC2: grep-version-bump procedure: `grep -rl '<old>'` enumerates ALL refs (incl. tad.sh, codex editions, README), bump, `grep -rn '<old>'` (excluding historical-version-history lines) returns zero
- [ ] AC3: `diff -r` structural verify primitive: exit 0 when source==target over derived paths, exit 1 + names the missing path otherwise (stable, structure-agnostic)
- [ ] AC4: **Anti-theater structure-resilience dogfood**: create a synthetic `.tad/_synthtest/` dir + a synthetic version-ref in source → (a) deny-list derivation includes `_synthtest`, (b) grep-derivation finds the ref, (c) a sync that OMITS `_synthtest` → verify primitive exits 1 naming it. Clean up. All pasted.
- [ ] AC5: `release-runbook` SKILL upgraded — derive+verify procedure present; the 18-item + 14-dir tables marked non-authoritative ("DERIVED — illustrative only")
- [ ] AC6: release-time gate wired into `*publish` (before tag) + `*sync` (after copy) as minor+ HARD BLOCK / patch advisory; NOT in settings.json (`grep -c <gate> .claude/settings.json` = 0)
- [ ] AC7: re-deriving against THIS repo reproduces the v2.21.0 sync set exactly (incl. codex) — proves the derivation matches the hand-verified result

#### Files Likely Affected
- `.tad/hooks/lib/release-verify.sh` (CREATE — diff-r + grep-stale primitives)
- `.tad/hooks/lib/derive-sync-set.sh` (CREATE — deny-list derivation)
- `.claude/skills/release-runbook/SKILL.md` (MODIFY — derive+verify; demote tables)
- `.claude/skills/alex/SKILL.md` (MODIFY — `publish_protocol`/`sync_protocol` gate wiring)

#### Dependencies
None (entry phase).

---

### Phase 2: tad.sh Installer Self-Derivation + Post-Install Self-Check

**Status:** ⬚ Planned
**Execution:** pending

#### Scope
Apply the same derive+verify principle to the `tad.sh` installer (the curl-install path Codex friends use):
replace its hardcoded `copy_framework_files()` dir list with deny-list derivation; bump TARGET_VERSION via
the source version; add a post-install `diff`/presence self-check that the install is complete. Reuse P1's
verification primitives where the install context allows. NOT in scope: changing the install UX.

#### Input
- `tad.sh` (current — hardcoded copy_framework_files dir list + TARGET_VERSION)
- P1 verification primitives + deny-list derivation

#### Output
- `tad.sh` deriving its copy-set (deny-list) + TARGET_VERSION from source + a post-install completeness self-check

#### Acceptance Criteria
- [ ] AC1: `tad.sh copy_framework_files()` derives the dir set (deny-list), not a hardcoded list; a new framework dir is auto-copied
- [ ] AC2: TARGET_VERSION sourced from `.tad/version.txt` (or derived), not a hand-edited literal (fixes the 2.19.1-class straggler)
- [ ] AC3: post-install self-check verifies the installed tree is complete (presence/diff of derived paths) → warns/fails on omission
- [ ] AC4: dogfood — fresh install into a temp dir → self-check passes; inject an omission → self-check catches it
- [ ] AC5: existing install UX (flags, prompts) unchanged; `bash tad.sh --help` / dry path still works

#### Files Likely Affected
- `tad.sh` (MODIFY — derive copy-set + TARGET_VERSION + post-install self-check)

#### Dependencies
Phase 1 complete (verification primitives + deny-list derivation exist to reuse).

---

## Context for Next Phase

### After P1 (→ P2) — 2026-06-01 (YOLO, Gate 3+4 PASS)
P1 done (commits 16dbe1a + 904cec2). Stable libs `.tad/hooks/lib/derive-sync-set.sh` (deny-list, single
source of truth: DENY_LIST 12 = 8 zero-touch + 4 transient; `--dirs/--zero-touch/--registry-only/--report`)
+ `release-verify.sh` (`structural` diff-rq / `version` grep-stale scoped to `git ls-files`, exit 0/1/2,
`TAD_RELEASE_GATE=warn` shadow). Release gate wired into alex `publish_protocol` (step3c version) +
`sync_protocol` (d2 structural); NOT settings.json. Runbook tables demoted. Conductor-verified:
exclusion=0 (no downstream-clobber), codex auto-included, version noise 62→5.

**P2 inputs / carry-forwards:**
1. **tad.sh can't `source` the lib** (curl|bash on fresh machine, `.tad/hooks/lib/` not present yet) → P2
   EMBEDS the derivation inline. The lib header marks the embeddable block. **P2 MUST add a release-time
   drift check that tad.sh's inlined DENY_LIST == derive-sync-set.sh's** (arch P1-3) — else P2 re-introduces
   the stale-list disease at the installer.
2. **First real release MUST use `TAD_RELEASE_GATE=warn`** (shadow) before flipping to hard-block.
3. **(P2-tunable) version-scope over-reports ~5 NEXT.md historical lines** — refine the worklog exclusion
   (prefer-false-positive accepted for now).
