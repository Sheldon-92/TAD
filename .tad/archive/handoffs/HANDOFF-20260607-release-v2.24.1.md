---
task_type: mixed
e2e_required: no
research_required: no
git_tracked_dirs: []
skip_knowledge_assessment: yes
gate4_delta: []
---

# Handoff: Release v2.24.1 (npx installer) — Routine Patch Release SOP

**From:** Alex · **To:** Blake · **Date:** 2026-06-07 · **Priority:** P2
**Type:** Routine patch release (release_duties → Blake executes per SOP). NOT a design task — no Socratic/expert-review ceremony. **MUST follow `.claude/skills/release-runbook/SKILL.md` 7 phases.**

## Version
`2.24.0` → `2.24.1` (patch, user-decided). npx cross-platform installer (already in commit 18a7e80) is the headline change.

## ⚠️ Pre-flight already done by Alex
- ✅ tad_main_guard: origin = Sheldon-92/TAD
- ✅ `bash tad.sh --verify-denylist` = exit 0 (13 entries in sync) — required because this release ships tad.sh changes
- ✅ Version enumeration: `grep -rlF "2.24.0"` (see §Files below)

## Phase 2 — Version Bump (2.24.0 → 2.24.1)
Authoritative = `grep -rlF "2.24.0"` + `release-verify.sh version`. Files to bump (exclude .tad/active|archive|evidence|backup + historical-table rows):
- `.tad/version.txt` (whole content)
- `.tad/config.yaml` (line 1 comment, line 3 `version:`, line 5 `last_updated: 2026-06-07`)
- `README.md` (header version + tree comment + footer; ADD a `v2.24.1` history-table row, do NOT rewrite old rows)
- `INSTALLATION_GUIDE.md` (header + structure section + upgrade + summary)
- `.claude/skills/tad-help/SKILL.md` (template `Version:` + highlights)
- `tad.sh` (TARGET_VERSION literal if present)
- `package.json` (already 2.24.0 → 2.24.1)
- `.tad/codex/codex-alex-skill.md` (line 3 header `TAD vX.Y.Z` + greeting line — ⚠️ grep the STRING `I'm Alex, your Solution Lead (TAD v`, NOT a line number; actual ~line 1244, runbook's "855" is stale)
- `.tad/codex/codex-blake-skill.md` (line 3 header + greeting — grep `I'm Blake, your Execution Master (TAD v`; actual ~line 766, runbook's "632" is stale)
- `.tad/sync-registry.yaml` (14× `last_synced_version: "2.24.0"`) is updated in **Phase 7** (last_synced), NOT here — see AC1 timing.
- ⚠️ **`.tad/codex/.regen-debug-*`** (temp files) — do NOT touch.
- ⚠️ **`.tad/spike-v3/domain-pack-tools/security-code-security-research.md` lines 15 & 189**: the `v2.24.0` there is **CodeQL the tool's version** (foreign-version collision, NOT TAD's). DO NOT edit (editing would falsify CodeQL's real version). It is a SANCTIONED AC1 survivor (see AC1).

**Gate (sanctioned-survivors model, not blind exit 0)**: `bash .tad/hooks/lib/release-verify.sh version "$PWD" "2.24.1" "2.24.0"` — interpret per AC1, not as raw exit 0.

## Phase 3 — CHANGELOG (Alex-authored content — insert above prior entry)
```markdown
## [2.24.1] - 2026-06-07

### New Features
- **npx cross-platform installer** (`bin/tad-install.mjs`): `npx github:Sheldon-92/TAD` offers interactive platform selection (Claude Code / Codex CLI) + capability-pack selection with one-line descriptions. Codex users get a slimmed install (excludes the 86K Claude-edition alex/blake SKILLs + hooks via deny-delta) → significantly lower context/quota footprint.
- **`tad.sh --platform <claude-code|codex>` + `--packs <list>`**: config-driven platform routing via `.tad/platform-codes.yaml` (deny-delta model, not allow-list). Backward compatible — no flag defaults to claude-code.

### Documentation
- README + INSTALLATION_GUIDE: added npx installation method (platform + pack selection).

### Notes
- Distribution: `npx github:Sheldon-92/TAD#v2.24.1` (pin recommended).
- Codex adapter validated end-to-end (13 capabilities) — see `.tad/evidence/codex-validation/`.
```

## Phase 2.5 — Documentation (Alex-drafted npx section — Blake places it)
In `README.md` after the existing `curl -sSL ... | bash` block (~line 120), and mirror into `INSTALLATION_GUIDE.md`:
```markdown
### Option B: npx (interactive — choose platform + packs)

\`\`\`bash
npx github:Sheldon-92/TAD
\`\`\`

Interactively pick your platform (**Claude Code** or **Codex CLI**) and which capability
packs to install — each shown with a one-line description. Codex users get a slimmed
install (excludes the large Claude-edition SKILLs + hooks) for a much lighter context
footprint.

Non-interactive:
\`\`\`bash
npx github:Sheldon-92/TAD --platform codex --packs web-frontend,web-backend
\`\`\`
```
Keep the existing curl method as "Option A" (default, Claude Code).

## Phase 4 — Publish (Alex does push/tag AFTER Blake commits — see Blake message)
Blake: stage + commit only. Do NOT push/tag (Alex's *publish step does that).
Commit msg: `chore: release v2.24.1 — npx cross-platform installer + docs`

## Phases 5-7 — Sync (Alex *sync after publish)
Blake: not in scope. Alex runs *sync to 14 registered projects + Phase 7 verify.

## Patch-release gate relaxation (per runbook)
- Codex parity gate: **advisory WARN** (patch), not hard-block. Still run `codex-parity-check.sh` both editions; report drift but proceed.
- Codex adapter smoke test: advisory (patch). Run launcher `--dry-run` both, report.

## Acceptance Criteria
- **AC1 (sanctioned-survivors model — NOT blind exit 0)**: After Phase 2 bump, run `release-verify.sh version "$PWD" "2.24.1" "2.24.0"`. The remaining flagged `2.24.0` refs MUST be EXACTLY the documented sanctioned set, nothing else:
  - `.tad/sync-registry.yaml` ×14 (`last_synced_version`) — bumped in **Phase 7**, so flagged pre-sync, MUST be 0 after Phase 7 sync.
  - `.tad/spike-v3/...security-code-security-research.md` lines 15,189 — CodeQL foreign-version (NOT TAD), permanent sanctioned survivor.
  - `NEXT.md:5` — reword to include a historical marker (e.g. `**v2.24.0 RELEASED — sync follow-ups**`) so the gate excludes it; after reword MUST be 0.
  Blake MUST enumerate every flagged ref and confirm each ∈ this sanctioned set (= no accidental omission). **FINAL check post-Phase-7**: only the 2 spike-v3 CodeQL lines remain. Any OTHER `2.24.0` survivor = real stale ref = FAIL.
- **AC2**: CHANGELOG has `## [2.24.1]` entry with the npx feature.
- **AC3**: README + INSTALLATION_GUIDE both contain the `npx github:Sheldon-92/TAD` method.
- **AC4**: `cat .tad/version.txt` = `2.24.1`; `node -e "console.log(require('./package.json').version)"` = `2.24.1`.
- **AC5**: codex editions line-3 header = `TAD v2.24.1`.
- **AC6**: `git status` clean after commit (nothing staged-but-uncommitted); commit message conventional.
- **AC7**: codex-parity-check.sh run on both editions, result reported (drift WARN OK for patch).

## Expert Review Audit Trail
| Reviewer | Issue | Resolution | Status |
|----------|-------|------------|--------|
| code-reviewer | P0-1: spike-v3 `v2.24.0` = CodeQL foreign version, gate flags but must NOT edit | §Phase2 + AC1 sanctioned survivor (do not edit) | Resolved |
| code-reviewer | P0-2: sync-registry 14× flagged at commit stage (Phase 7 bumps it) → AC1 unsatisfiable | AC1 redefined: sanctioned-survivors model, final check post-Phase-7 | Resolved |
| code-reviewer | P1-1: codex greeting line nums stale (855/632 → 1244/766) | §Phase2: grep STRING not line number | Resolved |
| code-reviewer | P1-2: NEXT.md:5 flagged (checklist not historical marker) | AC1: reword line 5 with RELEASED marker | Resolved |
| code-reviewer | P2-1: patch vs minor (new feature = minor) | User-decided patch; confirmed no HARD gate skipped | Noted |

## Notes
- This is a SOP execution. The runbook is authoritative; this handoff front-loads Alex's content (version, changelog, npx docs) + file list + AC1 sanctioned-survivors model (post code-reviewer).
- skip_knowledge_assessment: yes (routine release).
- ⚠️ code-reviewer ran the actual gate (35 stale refs current) — AC1's sanctioned set is empirically grounded, not assumed.
