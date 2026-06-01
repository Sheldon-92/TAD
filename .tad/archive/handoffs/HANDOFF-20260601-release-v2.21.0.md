---
task_type: mixed
e2e_required: no
research_required: no
skip_knowledge_assessment: yes
git_tracked_dirs:
  - .tad/
  - .claude/skills/
---

# HANDOFF: Release v2.21.0 — Codex-Edition Parity

**Priority:** P2
**Type:** Routine minor release (Blake executes per release-runbook SOP)
**From:** Alex (Terminal 1)
**Status:** Ready for Implementation
**SOP:** `.claude/skills/release-runbook/SKILL.md` — Phases 2–3 + Phase 4 pre-publish checks (Blake);
Phase 4 push+tag = Alex (the `*publish` Alex-executes exception). Phases 5–7 (sync) = later `*sync`.

---

## 1. Task Overview

Cut the **v2.21.0** release for the Codex-Edition Parity work (committed locally on main, unpushed:
1b74dec / 4881bc1 / e09d443 + Gate-4 docs). origin/main is at v2.20.0; this is a minor feature bump
(new standing Codex parity gate, no breaking change). Blake does Phase 2 (version bump) + Phase 3
(CHANGELOG) per the runbook, runs the Phase 4 pre-publish checks (including the NEW Codex parity gate
this release introduces — a live dogfood), and reports back. Alex then does the push + tag.

---

## 2. Background Context

The Codex-Edition Parity Epic (3 phases, all Gate-4 accepted, archived) added: a `*publish` detect-only
parity gate (step3b) + `regen-codex-editions.sh` + regenerated Codex editions + layer2-audit fix. This
is the first release that SHIPS that mechanism. ⚠️ Pre-existing bug to fix: `tad.sh` `TARGET_VERSION`
is stale at **2.19.1** (missed in the v2.20.0 release) while everything else is 2.20.0 — bump it to
2.21.0 with the rest (it is NOT in the runbook's 18-item list — that's the gap that let it go stale).

---

## 3. Requirements

1. Bump ALL version references 2.20.0 → **2.21.0** (the runbook's 18-item list) + **tad.sh TARGET_VERSION
   (2.19.1 → 2.21.0)** as a 19th item.
2. Add the CHANGELOG **[2.21.0]** entry (content drafted in §5 — use it).
3. Run the Phase 4 pre-publish checks per runbook INCLUDING the new Codex parity gate (step3b) — confirm
   it PASSES (editions are at parity from P2; this is the intended dogfood).
4. Commit the bump+CHANGELOG atomically. Report back — Alex does the push + tag.

**NOT in scope:** the push/tag (Alex). The `*sync` to 14 projects (separate, after the tag).

---

## 6. Implementation Steps

### Step 1 — Version bump (Phase 2, atomic — runbook 18 items + tad.sh)
Update ALL of these 2.20.0 → 2.21.0 (tad.sh: 2.19.1 → 2.21.0). Tag word for this release: `Codex-Edition Parity`.
1. `.tad/version.txt` (whole content) · 2-4. `.tad/config.yaml` L1 comment / L3 `version:` / L5 `last_updated: 2026-06-01`
5-8. `README.md` header / tree comment / version-history row / footer · 9-12. `INSTALLATION_GUIDE.md` header / structure / upgrade / summary
13-14. `.claude/skills/tad-help/SKILL.md` template `Version:` / `## TAD vX.Y.Z Highlights`
15-16. `.tad/codex/codex-blake-skill.md` / `codex-alex-skill.md` line-3 header comments (`<!-- ... TAD v2.21.0 -->`)
17-18. greeting lines — ⚠️ the runbook's L855/L632 are STALE (actual L1084/L715, will drift again). Do NOT
  trust line numbers: `grep -n 'TAD v2.20.0 — Codex Edition'` each file to locate, then bump to `v2.21.0`.
**19. `tad.sh` `TARGET_VERSION="2.19.1"` → `"2.21.0"`** (the stale straggler — also grep tad.sh for any other 2.19/2.20 refs)

### Step 2 — Straggler grep (Phase 2 verify)
Run the runbook's straggler grep over the listed files; confirm the only remaining version hits are 2.21.0.
Also: `grep -rnE 'TARGET_VERSION|2\.20\.0|2\.19\.1' tad.sh` → must show only 2.21.0.

### Step 3 — CHANGELOG (Phase 3)
Insert the §5 [2.21.0] block at the top of CHANGELOG.md (above [2.20.0]).

### Step 4 — Phase 4 pre-publish checks (run, do NOT push)
Per runbook Phase 4 pre-publish: version-consistency, the existing Codex Adapter smoke test, AND the NEW
Codex parity gate (the step3b detect-only gate this release adds):
```
bash .tad/hooks/lib/codex-parity-check.sh .claude/skills/alex/SKILL.md .tad/codex/codex-alex-skill.md; echo $?   # expect 0
bash .tad/hooks/lib/codex-parity-check.sh .claude/skills/blake/SKILL.md .tad/codex/codex-blake-skill.md; echo $?  # expect 0
```
⚠️ The codex editions just got version-string-bumped (items 15-18) — re-run the parity check AFTER the bump
to confirm the bump didn't break parity (a header/greeting line change must not drop a must-cover owner).

### Step 5 — Atomic commit + report
`git add` the bumped files + CHANGELOG; commit `chore: release v2.21.0 — Codex-Edition Parity`.
Report back to Alex with the commit hash + the parity-gate exit codes. **Do NOT push/tag** — Alex does that.

---

## 5. CHANGELOG [2.21.0] content (drafted by Alex — use verbatim)

```markdown
## [2.21.0] - 2026-06-01

### Added
- **Codex-Edition Parity Mechanism** — TAD's Codex-CLI editions (Alex+Blake) now stay in sync with the
  Claude source on every release, automatically.
  - `*publish` runs a **detect-only** parity gate (`codex-parity-check.sh`) on both Codex editions:
    per-must-cover-owner-body SAFETY-constraint presence (compensation-resistant), fail-CLOSED. Drift on a
    minor+ release is a **HARD BLOCK**; advisory on patch. The gate is READ-ONLY — it never modifies editions.
  - `regen-codex-editions.sh` — a separate, human-invoked, atomic regeneration command (regen both via
    `codex exec` → parity-check → batch-replace only if both pass → human reviews `git diff` + commits).
    Keeps unreviewed LLM-generated content out of tagged releases.
  - Codex editions regenerated to current parity (they had drifted, frozen at 2026-05-04 — the deliverable
    track, research-engine, and pack-collision wiring were missing).
- `.tad/hooks/lib/codex-parity-check.sh` + `parity-criterion.md` (graduated to a stable path).

### Fixed
- `layer2-audit.sh` now recognizes the `spec-compliance` reviewer name (recurring false "1 reviewer" WARN).
- `tad.sh` `TARGET_VERSION` was stale at 2.19.1 (missed in the v2.20.0 release) — now bumped with the rest.

### Decision Records
- DR-20260601: Codex-Edition Parity Architecture (automated regeneration + decoupled release gate).
```

---

## 9. Acceptance Criteria

- [ ] AC1: All 19 version refs at 2.21.0 — straggler grep over the listed files (incl. tad.sh) shows only 2.21.0; no 2.20.0/2.19.1 remain
- [ ] AC2: CHANGELOG.md top entry is `## [2.21.0] - 2026-06-01` with the §5 content
- [ ] AC3: Codex parity gate PASSES post-bump — both `codex-parity-check.sh` runs exit 0 (re-run AFTER the version-string bump)
- [ ] AC4: existing Codex Adapter smoke test still passes (`codex-tad-alex.sh --dry-run` / blake exit 0)
- [ ] AC5: atomic commit `chore: release v2.21.0` made; hash + parity exit codes reported; NOT pushed (Alex pushes)

### 9.1 Spec Compliance Checklist

| AC | Command (RUNNABLE) | Expected | Verified (step1d) |
|----|--------------------|----------|-------------------|
| AC1 | `grep -rhoE 'v?2\.(19|20|21)\.[0-9]+' .tad/version.txt .tad/config.yaml tad.sh README.md INSTALLATION_GUIDE.md .claude/skills/tad-help/SKILL.md .tad/codex/codex-alex-skill.md .tad/codex/codex-blake-skill.md \| sort -u` | only `2.21.0` (+ maybe `v2.21.0`) | post-impl; pre-impl shows 2.20.0 + 2.19.1 (the drift). ⚠️ ALL 8 runbook-listed files, not just 3 (CR P1-1) — a stale 2.20.0 in README/INSTALL/tad-help/codex must also fail AC1 |
| AC3 | `bash .tad/hooks/lib/codex-parity-check.sh .claude/skills/alex/SKILL.md .tad/codex/codex-alex-skill.md; echo $?` | `0` | pre-impl: live editions currently PASS (P2) — must re-confirm post-bump |
| AC5 | `git log --oneline -1` | `chore: release v2.21.0 …` | post-impl |

**AC Dry-Run Log** (Alex step1d, 2026-06-01):
- AC1: ✅ pre-impl baseline — version.txt/config.yaml = 2.20.0, tad.sh = 2.19.1 (the two-version drift this fixes).
- AC3: ✅ pre-impl — both codex editions currently parity-PASS (P2 Gate-4 verified). Re-run post-bump is the real check.

### 9.2 Expert Review Status

Reviewed by **code-reviewer** (routine mechanical release against the vetted release-runbook SOP — no
natural 2nd design-domain reviewer for a version bump; ≥1-expert per the *express-tier precedent for
mechanical work). Verdict: CONDITIONAL PASS, 0 P0, 2 P1 (both fixed). Raw:
`.tad/evidence/reviews/alex/release-v2.21.0/code-reviewer.md`.

| Reviewer | Issue | Resolution | Status |
|----------|-------|-----------|--------|
| code-reviewer | P1-1: AC1 grep only covered 3/7 version files → stale 2.20.0 elsewhere would pass | §9.1 AC1 widened to all 8 runbook files | Resolved |
| code-reviewer | P1-2: items 17-18 used runbook's stale line numbers (L855/L632; actual L1084/L715) | §6 Step 1 → grep-by-content anchor, line numbers distrusted | Resolved |
| code-reviewer | (confirmed) 19-item list complete; parity-after-bump sound; CHANGELOG no overclaim; tad.sh bump safe (installer version, not a pin); AC1 ERE valid | — | Verified |

---

## 10. Important Notes

- **10.1 The version bump touches the codex editions (items 15-18) — re-run the parity gate AFTER bumping**
  (AC3). A header/greeting string change is in the comment/greeting region, not a must-cover owner body, so it
  should stay parity — but confirm, don't assume.
- **10.2 Do NOT push or tag** — that's Alex's `*publish` Phase 4 step. Blake stops at the atomic commit + report.
- **10.3 tad.sh straggler** — it's NOT in the runbook's 18-item list; that's exactly why it went stale. Bump it
  AND consider noting (in the completion) that the runbook list should add tad.sh as item 19 permanently
  (a follow-up, not this release's job).
- **10.4 skip_knowledge_assessment: yes** — routine mechanical release; no new knowledge expected. Blake may
  override-unskip if the bump surfaces something (e.g. the tad.sh straggler warrants a runbook-list fix note).

## 11. Decision Summary

| # | Decision | Chosen | Rationale |
|---|----------|--------|-----------|
| 1 | Version | **2.21.0** (minor) | New feature (Codex parity gate), no breaking change. origin at 2.20.0. User 2026-06-01. |
| 2 | Who bumps | **Blake (SOP)** | Routine minor release; Alex doesn't edit version strings (release_duties.delegation). |
| 3 | tad.sh 2.19.1 | **fix to 2.21.0 now** | Pre-existing straggler from v2.20.0; fold into this bump. |

## Required Evidence Manifest

```yaml
completion: .tad/active/handoffs/COMPLETION-20260601-release-v2.21.0.md
gate_verdicts:
  - COMPLETION frontmatter gate3_verdict marker
artifacts:
  - bumped version files (19 refs) + CHANGELOG.md
  - parity-gate exit codes (post-bump) pasted in COMPLETION
```
