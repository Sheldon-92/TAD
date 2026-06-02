---
task_type: mixed
e2e_required: no
research_required: no
skip_knowledge_assessment: yes
git_tracked_dirs:
  - .tad/
  - .claude/skills/
---

# HANDOFF: Release v2.22.0 — Self-Deriving Release/Sync (FIRST real test of the new mechanism)

**Priority:** P2
**Type:** Routine minor release (Blake executes per the UPGRADED release-runbook SOP)
**From:** Alex (Terminal 1)
**Status:** Ready for Implementation
**SOP:** `.claude/skills/release-runbook/SKILL.md` (now the derive+verify procedure)

---

## 1. Task Overview

Cut **v2.22.0** to ship the Self-Deriving + Self-Verifying Release/Sync Epic (commits 16dbe1a / 904cec2 /
f053f50 / a24a166 + c2be048, unpushed). **This release is the FIRST to USE the new mechanism**: bump the
version with the **grep-derived** method (not the old 18-item hardcoded list), and run the **new release-time
version gate in SHADOW mode** (`TAD_RELEASE_GATE=warn`) — the first real exercise of the gate this Epic built.
origin/main is at v2.21.0; minor feature bump, no breaking change.

---

## 2. Background Context

The new mechanism (this release ships it): `.tad/hooks/lib/derive-sync-set.sh` (deny-list, single source of
truth) + `release-verify.sh` (`version` grep-stale scoped to `git ls-files`; `structural` diff-r; exit 0/1/2;
`TAD_RELEASE_GATE=warn` shadow) + the gate wired into `*publish`/`*sync` + tad.sh self-derivation. Grounding
(2026-06-01) confirmed: `git ls-files | xargs grep -l '2\.21\.0'` finds 11 framework files; the new
`release-verify version` ran and correctly reported the 2.21.0 refs.

⚠️ **THREE refs the gate over-reports that MUST NOT be bumped** (prefer-false-positive — Blake resolves):
- `.tad/sync-registry.yaml` `last_synced_version: "2.21.0"` — SYNC STATE (what was last synced), updated by
  `*sync`, NOT a framework version string. LEAVE at 2.21.0 (becomes 2.22.0 only when v2.22.0 is synced).
- `.claude/skills/release-runbook/SKILL.md` lines ~310/313/316 — **HISTORICAL PROSE** (the gotcha narrative
  describing the v2.21.0 self-deriving fix). Bumping would falsify history (the fix shipped IN 2.21.0).
  LEAVE unbumped. (code-reviewer P0-1.)
- `.tad/scripts/sync-v2.21.0.sh` — a HISTORICAL per-release script. ⚠️ It lives in `.tad/scripts/` which is
  a SYNCED framework dir (NOT zero-touch) → it would `cp -R` to all 14 downstream and seed future
  false-positives there. **FIX (code-reviewer P1-1, do it this release): `git mv .tad/scripts/sync-v2.21.0.sh
  .tad/evidence/releases/`** (zero-touch — the P1 design's intended home for per-release scripts). This
  removes it from both the sync set AND the version-bump scope in one move. `mkdir -p .tad/evidence/releases/` first.

---

## 3. Requirements

1. Bump 2.21.0 → **2.22.0** using the NEW derived method: `git ls-files | xargs grep -l '2\.21\.0'` to
   enumerate the set, bump the FRAMEWORK version strings, then `release-verify.sh version . 2.22.0 2.21.0`
   to confirm. Do NOT use the old 18-item hardcoded table (now demoted/illustrative).
2. Add CHANGELOG **[2.22.0]** entry (§5 content drafted — use verbatim).
3. **Run the new gate in shadow mode** and CAPTURE the result (first real test): after bumping, the only
   surviving `release-verify version` reports should be the 2 intentional leave-alones (§2) — confirm + note.
4. Run `bash tad.sh --verify-denylist` (P2 drift check) as pre-flight — must exit 0.
5. Atomic commit, report. Alex does push + tag.

**NOT in scope:** push/tag (Alex). `*sync` to 14 projects (separate, after the tag — will be the first real
test of the `structural` sync gate).

---

## 6. Implementation Steps

### Step 1 — Version bump via the NEW derived method (Phase 2 of the upgraded runbook)
- `git ls-files | xargs grep -l '2\.21\.0' 2>/dev/null` → the candidate set.
- Bump 2.21.0 → 2.22.0 in the FRAMEWORK version strings: `.tad/version.txt`, `.tad/config.yaml` (version +
  comment + last_updated), `README.md` (header/tree/version-history-row/footer), `INSTALLATION_GUIDE.md`,
  `.claude/skills/tad-help/SKILL.md`, `.tad/codex/codex-alex-skill.md` + `codex-blake-skill.md` (header +
  greeting — grep by content, NOT line number),
  `tad.sh` (the `TARGET_VERSION="2.21.0"` fallback literal → "2.22.0"). Tag word: `Self-Deriving Release/Sync`.
- ⚠️ DO NOT bump the THREE leave-alones (§2): `.tad/sync-registry.yaml` last_synced_version,
  `.claude/skills/release-runbook/SKILL.md` historical-prose refs (~L310/313/316), `sync-v2.21.0.sh`
  (which Step 1b moves out).

### Step 1b — Move the historical per-release script out of the synced dir (cr P1-1)
- `mkdir -p .tad/evidence/releases/ && git mv .tad/scripts/sync-v2.21.0.sh .tad/evidence/releases/`
  (removes it from the synced `scripts/` framework dir AND from version-bump scope; evidence/ is zero-touch).

### Step 2 — Run the new version gate (SHADOW, first real test — capture it)
- `TAD_RELEASE_GATE=warn bash .tad/hooks/lib/release-verify.sh version . 2.22.0 2.21.0; echo "exit:$?"`
- Expected after a correct bump: the ONLY remaining stale reports are the 2 intentional leave-alones
  (sync-registry last_synced + sync-v2.21.0.sh) + any genuine NEXT.md historical-prose (the known
  over-report). Paste the full output — this is the gate's first real-release exercise; we want the record.
- If the gate reports a FRAMEWORK file still at 2.21.0 → that's a real miss, bump it.

### Step 3 — CHANGELOG (insert §5 block at top of CHANGELOG.md, above [2.21.0])

### Step 4 — Pre-flight: drift check
- `bash tad.sh --verify-denylist; echo "exit:$?"` → MUST be 0 (in-sync).

### Step 5 — Atomic commit + report
- `git add` the bumped files + CHANGELOG; commit `chore: release v2.22.0 — Self-Deriving Release/Sync`.
- Report to Alex: commit hash + the Step-2 gate output (the first-real-test record) + drift-check exit. DO NOT push/tag.

---

## 5. CHANGELOG [2.22.0] content (drafted by Alex — use verbatim)

```markdown
## [2.22.0] - 2026-06-01

### Added
- **Self-Deriving + Self-Verifying Release/Sync** — publish, sync, and install now DERIVE their file sets
  from the repo structure (deny-list) instead of hardcoded lists that silently go stale when the structure
  evolves. Replaces the recurring "release/sync missed a file" failures (e.g. `.tad/codex/` was frozen for
  a month; `tad.sh` stuck at an old version).
  - `.tad/hooks/lib/derive-sync-set.sh` — deny-list derivation, the single source of truth (a new framework
    dir is auto-included; zero-touch project data is never synced).
  - `.tad/hooks/lib/release-verify.sh` — structure-agnostic verification: `structural` (diff source==target)
    + `version` (grep for stale version refs, scoped to git-tracked files). Exit 0/1/2; `TAD_RELEASE_GATE=warn`
    shadow mode for first cutover.
  - Release-time HARD-BLOCK gate wired into `*publish` (version) + `*sync` (structural) — minor+ blocks on
    a detected omission/mismatch; advisory on patch. NOT a settings.json hook (release-time only).
  - `tad.sh` installer self-derives its copy-set (incl. previously-omitted dirs + top-level files of any
    extension), derives the version from source, runs a post-install `diff` self-check, and `--verify-denylist`
    drift-checks its inlined deny-list against the lib.
  - `release-runbook` SKILL upgraded to the derive+verify procedure; the old hardcoded 18-item version table
    and 14-dir sync list demoted to non-authoritative ("DERIVED — illustrative only").

### Notes
- This is the first release that USES the new mechanism (grep-derived version bump + shadow-mode gate).
```

---

## 9. Acceptance Criteria

- [ ] AC1: All FRAMEWORK version refs at 2.22.0 — `TAD_RELEASE_GATE=warn release-verify version . 2.22.0 2.21.0` reports ONLY the intentional leave-alones (sync-registry last_synced + release-runbook historical-prose) + known NEXT.md history; NO framework file (version.txt/config/README/INSTALL/tad-help/codex/tad.sh) remains at 2.21.0. (sync-v2.21.0.sh moved to evidence/ = out of version scope.)
- [ ] AC2: CHANGELOG top entry is `## [2.22.0] - 2026-06-01` with the §5 content
- [ ] AC3: `bash tad.sh --verify-denylist` exit 0 (drift check in-sync)
- [ ] AC4: sync-registry.yaml last_synced_version still 2.21.0; sync-v2.21.0.sh unbumped (the intentional leave-alones)
- [ ] AC5: atomic commit `chore: release v2.22.0` made; Step-2 gate output + drift exit reported; NOT pushed

### 9.1 Spec Compliance Checklist

| AC | Command (RUNNABLE bare-pipe) | Expected | Verified (step1d) |
|----|------------------------------|----------|-------------------|
| AC1 | `TAD_RELEASE_GATE=warn bash .tad/hooks/lib/release-verify.sh version . 2.22.0 2.21.0 \| grep -oE 'STALE: [^:]+' \| grep -vE 'sync-registry\|release-runbook\|NEXT.md' \| sort -u` | empty (no framework file left at 2.21.0) | pre-impl: currently lists framework files (the bump targets) |
| AC3 | `bash tad.sh --verify-denylist; echo $?` | `0` | pre-impl PASS: ran clean, "12 entries" exit 0 |
| AC4 | `grep -m1 last_synced_version .tad/sync-registry.yaml` | stays `2.21.0` | pre-impl: 2.21.0 |

**AC Dry-Run Log** (Alex step1d, 2026-06-01):
- AC3: ✅ pre-impl — `--verify-denylist` exit 0, 12 entries in-sync.
- AC1: ✅ the gate runs. Pre-bump it reports **39 TOTAL** stale lines — of which only **~17 lines across 9
  framework files** are real bump targets; the rest are the leave-alones (14 sync-registry + 5 sync-script +
  3 release-runbook historical). Post-bump + after Step-1b move, the AC1 pipe (excluding sync-registry/
  release-runbook/NEXT) must be EMPTY. Note: the gate's raw exit is 1 (findings present) — that is NORMAL in
  shadow mode; the warn-downgrade lives in the consumer (alex publish gate-step: exit 1+minor+warn→proceed,
  exit 2→always block). cr P2.

### 9.2 Expert Review Status

Reviewed by **code-reviewer** (routine release vs the upgraded runbook; ≥1-expert per *express-tier mechanical
precedent — no natural 2nd design-domain reviewer for a version bump). CONDITIONAL PASS, live-verified. 1 P0 + 3 P1 (fixed).
Raw: `.tad/evidence/reviews/alex/release-v2.22.0/code-reviewer.md`.

| Reviewer | Issue | Resolution | Status |
|----------|-------|-----------|--------|
| code-reviewer | P0-1: release-runbook 2.21.0 refs are historical prose; bumping falsifies history + AC1 unachievable | §2 (3rd leave-alone) + §6 Step 1 (leave) + §9.1 AC1 excludes release-runbook | Resolved |
| code-reviewer | P1-1: sync-v2.21.0.sh in synced scripts/ → would cp to 14 downstream | §6 Step 1b: `git mv` to evidence/releases/ (zero-touch) this release | Resolved |
| code-reviewer | P1-3: dry-run log mislabeled "39 framework refs" | §9.1 dry-run log: 39 total = ~17 framework + leave-alones | Resolved |
| code-reviewer | P1-2/P2: codex content-grep; exit 1 normal in shadow | §6 Step 1 (content-grep) + §9.1 (exit-1-normal note) | Resolved |

---

## 10. Important Notes

- **10.1 This release DOGFOODS the new mechanism** — use the grep-derive bump + the shadow-mode gate, NOT the
  old hardcoded table. Capturing the gate's first-real-release output (Step 2) is itself a deliverable.
- **10.2 The 2 leave-alones** (sync-registry last_synced, sync-v2.21.0.sh) — the gate over-reports them by
  design (prefer-false-positive). Confirm they're intentional; do NOT bump them.
- **10.3 codex editions** — bump header + greeting by CONTENT grep (`grep -n 'TAD v2.21.0'`), runbook line
  numbers are stale. After bumping, the codex parity gate (publish step3b) should still pass (header/greeting
  change is not a must-cover owner).
- **10.4 Do NOT push/tag** — Alex's job.

## 11. Decision Summary

| # | Decision | Chosen | Rationale |
|---|----------|--------|-----------|
| 1 | Version | **2.22.0** minor | New feature (self-deriving release/sync), no breaking change. |
| 2 | Bump method | **grep-derived (new)** | First real use of the mechanism this release ships; old 18-item list demoted. |
| 3 | Gate mode | **shadow (TAD_RELEASE_GATE=warn)** | First cutover — warn not hard-block, per the Epic's first-real-release guard. |

## Required Evidence Manifest

```yaml
completion: .tad/active/handoffs/COMPLETION-20260601-release-v2.22.0.md
gate_verdicts:
  - COMPLETION frontmatter gate3_verdict marker
artifacts:
  - bumped framework version files + CHANGELOG
  - Step-2 new-gate shadow-mode output (the first-real-test record) pasted in COMPLETION
  - --verify-denylist exit code
```
