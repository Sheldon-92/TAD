---
task_type: mixed
e2e_required: no
research_required: no
skip_knowledge_assessment: no
git_tracked_dirs:
  - .claude/skills/tad-help
  - .claude/skills/release-runbook
  - .claude/skills/alex
  - .claude/skills/blake
  - .tad/codex
---

# HANDOFF: Release Hygiene + Conventions (Debt Bundle 1/2)

**From:** Alex | **To:** Blake | **Date:** 2026-05-31
**Priority:** P2 (debt cleanup — no in-flight feature blocked)
**Type:** Standard TAD (mixed: doc strings + shell config + protocol-contract doc)

## 1. Executive Summary

Five accumulated release-hygiene + convention debts from the v2.19.0/v2.19.1 cycle, all low-risk, batched into one handoff:

1. **doc-drift**: 5 files still show `2.19.0` in **current-version display strings** (source is `2.19.1`). Bump current-display only — **preserve historical references** (README version-history table, CHANGELOG, codex `Generated:` date stamps).
2. **version-scheme**: `tad.sh TARGET_VERSION="2.19"` (2-part) while `version.txt`/`config.yaml` are `2.19.1` (3-part) → downstream `version.txt` gets stamped `2.19` ≠ source. **Decision (human, 2026-05-31): unify to 3-part** — `TARGET_VERSION="2.19.1"`.
3. **runbook gap**: release-runbook Phase 2 version table covers codex header-comment (rows 15/16) but NOT the codex **greeting lines** (855/632). Add rows so future releases bump them.
4. **tad.sh `*)` default arm**: flag `case` (lines 30-33) silently ignores unknown flags. Add a default arm (code-reviewer P2, non-blocking).
5. **express slug convention**: `layer2-audit.sh is_express_slug()` already detects express via word-boundary slug match — but nothing TELLS Alex/Blake to put `express` in the slug, so a `*express` bugfix named `bugfix-foo` + `task_type=code` triggers a false Tier-1 (≥2 reviewer) WARN. **Decision (human): adopt naming convention** — express handoff slug MUST contain `express`. Document in alex + blake SKILL (no audit code change — detection already correct).

## 3. Requirements

- R1: Source-of-truth version (`2.19.1`) reflected in all CURRENT-version display strings.
- R2: `tad.sh` stamps downstream `version.txt` identically to source (`2.19.1`).
- R3: Historical version references are NOT altered (version-history table, CHANGELOG entries, `Generated:` provenance dates).
- R4: release-runbook documents the codex greeting lines so they are not missed next release.
- R5: `tad.sh` rejects unknown flags with a clear message + non-zero exit.
- R6: express-slug naming convention documented in both agent SKILLs.

## 4. Technical Design

### 4.1 Version-string bumps (current-display ONLY)
Per release-runbook Phase 2 table, bump the CURRENT-version occurrences. Leave historical ones.

### 4.2 version-scheme (decision: 3-part)
`tad.sh:18` `TARGET_VERSION="2.19"` → `TARGET_VERSION="2.19.1"`.

⚠️ **Rationale CORRECTED post-review (backend-architect P0-1):** the load-bearing consumer is NOT `*publish` (that's an advisory table using MAJOR.MINOR). It is **`tad.sh detect_state()` line ~303** which does **exact string equality** `[[ "$ver" == "$TARGET_VERSION" ]]`. The change is safe because it stays internally consistent: `tad.sh:537` stamps `version.txt` with `$TARGET_VERSION` (now `2.19.1`), and `detect_state()` compares against the same `2.19.1` → `"current"`. Today's drift (`version.txt`=2.19.1 vs `TARGET_VERSION`=2.19) is what this fixes.

**Co-dependent edits this surfaced:**
- `tad.sh:171` fallback `current_version="${TARGET_VERSION}.0"` would now yield malformed 4-segment `2.19.1.0` (fires only when no version.txt exists). Change to `current_version="${TARGET_VERSION}"` (TARGET_VERSION already carries the patch).
- **Pre-existing latent hazard (OUT OF SCOPE — record only):** `detect_state()` glob arms `2.1*`/`2.2*` (lines ~305-313) will misclassify a 3-part `2.19.x` as `"v2.0"` on the NEXT version bump (when line 303 exact-match fails). Not introduced by this change; record in NEXT.md as next-bump debt.

### 4.3 tad.sh default flag arm
In the arg-parse `case` (lines 30-33), add before `esac`:
```sh
    *) echo "tad.sh: unknown option '$arg' (use --help)" >&2; exit 1 ;;
```

### 4.4 express-slug convention (doc-only — NO audit code change)
`layer2-audit.sh is_express_slug()` already matches `express|*-express|*-express-*|express-*` (word-boundary, lines 47-51). The fix is to make agents NAME express handoffs accordingly. Add a convention rule to:
- `alex/SKILL.md` `express_path_protocol.scope_constraints` (a `slug_convention` sub-rule)
- `blake/SKILL.md` (mirror note where express handling is documented)

⚠️ **Contract change note**: this ADDS a naming convention to `express_path_protocol`. It does NOT alter any forbidden/AR-001/NOT_via_alex block. If implementing it requires touching a `forbidden_implementations` or `NOT_via_*` line → STOP, escalate to Alex.

## 6. Files to Modify

1. `tad.sh` — (a) line 18 `TARGET_VERSION="2.19"`→`"2.19.1"`; (b) line ~171 `current_version="${TARGET_VERSION}.0"`→`"${TARGET_VERSION}"` (avoid 4-segment); (c) add `*)` default arm in case (lines 30-33). Do NOT touch detect_state glob arms 305-313 (out of scope — record in NEXT.md).
2. `README.md` — current-display: line 3 header banner, line 134 tree comment, line 453 footer → `2.19.1`. **PRESERVE line 354** (version-history table `v2.19.0` row)
3. `INSTALLATION_GUIDE.md` — lines 3, 83, 237, 336 → `2.19.1` (all current/structural, no history)
4. `.claude/skills/tad-help/SKILL.md` — lines 17, 221 → `2.19.1`
5. `.tad/codex/codex-alex-skill.md` — line 3 header comment `TAD v2.19.0`→`v2.19.1` (**keep `Generated: 2026-05-04` date**), line 855 greeting → `2.19.1`
6. `.tad/codex/codex-blake-skill.md` — line 3 header comment (keep date), line 632 greeting → `2.19.1`
7. `.claude/skills/release-runbook/SKILL.md` — add 2 rows to Phase 2 version table (after row 16). Each row MUST cite the literal line number: row 17 = `codex-alex-skill.md` line 855 greeting `TAD vX.Y.Z`; row 18 = `codex-blake-skill.md` line 632 greeting `TAD vX.Y.Z` (AC5 greps for `855`/`632` tokens — write them verbatim).
8. `.claude/skills/alex/SKILL.md` — add `slug_convention` rule for express handoffs (slug MUST contain `express`). ⚠️ **INSERTION ANCHOR (code-reviewer P1-1):** insert it AFTER the `required_steps:` block (downstream of the `step2 expert review ... code-reviewer 必选` line ~2099), NOT inside `scope_constraints` — inserting into `scope_constraints` would push the AR-001-guarded "expert review + code-reviewer" phrase further from the header and trip this handoff's own STOP rule. Place near `when_appropriate`/`when_NOT_appropriate` or after `forbidden_implementations`.
9. `.claude/skills/blake/SKILL.md` — mirror express-slug convention note

**Grounded Against** (Alex step1c actual reads, 2026-05-31):
- `tad.sh` (lines 18, 26-33 read) — TARGET_VERSION + case arm confirmed
- `README.md`, `INSTALLATION_GUIDE.md`, `.claude/skills/tad-help/SKILL.md` (2.19.0 lines grepped)
- `.tad/codex/codex-alex-skill.md` (lines 3, 855), `codex-blake-skill.md` (lines 3, 632)
- `.claude/skills/release-runbook/SKILL.md` (lines 80-110 table read)
- `.claude/skills/alex/SKILL.md` (lines 2080-2110 express scope_constraints)
- `.tad/hooks/lib/layer2-audit.sh` (lines 40-51 is_express_slug — confirmed already correct)

## 9. Acceptance Criteria

- [ ] AC1: `grep -c 'TARGET_VERSION="2.19.1"' tad.sh` = 1; old 2-part gone.
- [ ] AC2: `tad.sh --bogusflag` exits non-zero and prints "unknown option".
- [ ] AC3: No `2.19.0` remains in current-display strings of README/INSTALL/tad-help/codex (only documented historical refs survive).
- [ ] AC4: README line 354 version-history `v2.19.0` row UNCHANGED; CHANGELOG `[2.19.0]` entry UNCHANGED; codex `Generated:` dates UNCHANGED.
- [ ] AC5: release-runbook Phase 2 table has ≥2 new rows referencing codex greeting lines.
- [ ] AC6: alex/SKILL `express_path_protocol` contains a slug-convention rule mentioning `express`; blake/SKILL has a mirror note.
- [ ] AC7: `bash -n tad.sh` passes (shell syntax).
- [ ] AC8: **detect_state behavior** (backend-architect P0-1) — with a 3-part `version.txt`=`2.19.1`, `detect_state()` returns `"current"` (NOT a grep of the assignment line — exercise the function in a throwaway dir).
- [ ] AC9: **AR-001 guarantee preserved** (backend-architect P2-2) — post-edit, `grep -n 'expert review' .claude/skills/alex/SKILL.md` still shows the express `step2 expert review ... code-reviewer` phrase, and the slug_convention rule did NOT displace it above its current position.

### 9.1 Spec Compliance Checklist (Verification)

| AC | Verification Method | Expected | Verified Output (Alex step1d) |
|----|--------------------|----------|-------------------------------|
| AC1 | `grep -c 'TARGET_VERSION="2.19.1"' tad.sh` | `1` | post-impl |
| AC2 | `bash tad.sh --bogusflag; echo $?` | non-zero + msg | post-impl |
| AC3 | `grep -rn '2\.19\.0' README.md INSTALLATION_GUIDE.md .claude/skills/tad-help/SKILL.md .tad/codex/codex-alex-skill.md .tad/codex/codex-blake-skill.md` | **EXACTLY 1 line: `README.md:354`** (version-history row — preserved). Codex line-3 versions ARE bumped per runbook rows 15/16 (only `Generated:` DATE preserved), so they no longer contain `2.19.0`. CHANGELOG deliberately not in scan list. Any other line = FAIL (missed current-display straggler, e.g. `tad-help:17` which co-locates `Version: 2.19.0` with `Generated:`) | post-impl |
| AC4 | `grep -c '2\.19\.0' CHANGELOG.md` unchanged; `grep -n 'v2.19.0.*Observational' README.md` still returns the history row (content-anchored, not line-positional) | preserved | pre-impl baseline: CHANGELOG has `[2.19.0]` line 14; README history row present |
| AC5 | `grep -cE '855\|632' .claude/skills/release-runbook/SKILL.md` (greeting-line rows cite literal line numbers) | `≥2` | post-impl |
| AC6 | `grep -ci "slug.*express\|express.*slug" .claude/skills/alex/SKILL.md` (slug_convention rule present) | `≥1` | post-impl |
| AC7 | `bash -n tad.sh; echo $?` | `0` | pre-impl baseline: `0` (current passes) |
| AC8 | In throwaway dir: `echo 2.19.1 > t/.tad/version.txt`, source/run detect_state → assert `STATE=="current"` | `current` | post-impl (NOT grep of assignment) |
| AC9 | `grep -n 'expert review' .claude/skills/alex/SKILL.md` shows express `step2` phrase intact post-edit | phrase present, not displaced upward | post-impl |

### AC Dry-Run Log (Alex step1d, 2026-05-31)
- AC4: ✅ pre-impl-verifiable — CHANGELOG `[2.19.0]` confirmed at line 14 (historical, must stay); README:354 is version-history table row. Baseline captured.
- AC7: ✅ pre-impl-verifiable — `bash -n tad.sh` currently exits 0; the `*)` arm addition is syntactically simple, re-verify post-impl.
- AC1/AC2/AC3/AC5/AC6: post-impl-verifiable (require Blake's edits); commands syntax-validated (anchored greps, no `-oc`+`sort -u|wc -l` trap per code-quality.md 2026-05-27).

## 10. Important Notes

- ⚠️ **NOT a blind sed replace.** `2.19.0`→`2.19.1` must skip: CHANGELOG `[2.19.0]` entry, README:354 version-history row, codex `Generated:` date stamps. These are HISTORICAL FACTS.
- ⚠️ **codex skill files are hand-maintained** (release-runbook rows 15/16 bump them; NOT auto-regenerated from source). Edit them directly.
- ⚠️ **express convention is doc-only** — `layer2-audit.sh` detection already works; do NOT touch audit logic.
- ⚠️ **Contract awareness**: editing alex/blake SKILL `express_path_protocol` is a small contract addition. If it forces a change to any `forbidden_implementations`/`NOT_via_*`/AR-001 line → STOP + escalate.
- These 9 files include downstream-synced files (tad.sh, README, INSTALL, codex, SKILLs) → after Gate 4, Alex should `*sync` to propagate (noted for Alex, not Blake).
- ⚠️ **NEXT.md is NOT in scope** (code-reviewer P1-2): its `2.19.0` occurrences (lines 21/22/38/40/42) are historical task-log entries — PRESERVE, do not bump, do not add to §6.
- ⚠️ **Recorded debts for NEXT.md (Alex, at Gate 4 — out of THIS handoff's scope):** (1) detect_state glob arms `2.1*`/`2.2*` (tad.sh ~305-313) will misclassify 3-part `2.19.x` as `v2.0` on the NEXT version bump — next-release-handoff must address. (2) The durable express-tier fix is a frontmatter `express: true` marker consumed by layer2-audit (backend-architect P2-1) — the slug convention is the cheap fix, not the final one; slug-as-proxy still false-WARNs any express handoff that forgets the naming rule.

## 11. Decision Summary

| # | Decision | Options | Chosen | Rationale |
|---|----------|---------|--------|-----------|
| 1 | Version scheme | (a) tad.sh→3-part (b) keep 2-part + document | **(a) 3-part `2.19.1`** | Human chose; downstream matches source exactly. ⚠️ Rationale CORRECTED post-review: the load-bearing consumer is `detect_state()` line 303 exact-equality (NOT `*publish` MAJOR.MINOR). Change is internally consistent (stamp + detect both `2.19.1`). Surfaced 2 co-dependent edits (line 171 fallback) + 1 recorded latent debt (glob arms) — see §4.2 |
| 2 | doc-drift scope | (a) bump current only, preserve history (b) replace all | **(a) preserve historical** | Human chose; history table + CHANGELOG + Generated dates are facts |
| 3 | express-slug fix | (a) naming convention (doc) (b) rewrite audit to read frontmatter | **(a) convention** | Human chose; audit detection already correct, lowest cost |
| 4 | express convention placement | (a) in Handoff 1 (b) separate handoff | **(a) Handoff 1** | Human chose; small contract add, same review pass |

## Audit Trail (Expert Review — code-reviewer + backend-architect)
| Reviewer | Issue | Resolution Section | Status |
|----------|-------|--------------------|--------|
| backend-architect | P0-1: version-scheme rationale cites wrong consumer (*publish vs detect_state line 303 exact-equality); needs behavior AC + line 171 fix | §4.2 corrected rationale + co-dependent edits; §6 item 1(b); AC8; §11 row 1 | Resolved |
| code-reviewer | P0-1: AC3 `Generated:` exclusion masks tad-help:17 straggler | §9.1 AC3 — exclusion removed; codex line-3 versions bumped so no masking needed | Resolved |
| code-reviewer | P0-2: AC3 expected outcome unverifiable ("only historical") | §9.1 AC3 → enumerated EXACTLY 1 line (README:354) | Resolved |
| code-reviewer | P1-1: §6-item-8 slug_convention into scope_constraints pushes AR-001 phrase → trips own STOP rule | §6 item 8 re-anchored downstream of required_steps; AC9 verifies preservation | Resolved |
| code-reviewer | P1-2: NEXT.md historical 2.19.0 ambiguous | §10 NEXT.md preserve note | Resolved |
| code-reviewer | P1-3: AC5 token coupling (grep needs literal 855/632 in rows) | §6 item 7 + §9.1 AC5 cite literal line numbers | Resolved |
| backend-architect | P1-1 (=P0-2 downgrade): tad.sh:171 `${TARGET_VERSION}.0` → 4-segment | §4.2 + §6 item 1(b) | Resolved |
| backend-architect | P1-2: detect_state glob arms latent hazard on next bump | §10 recorded debt + §4.2 (out of scope, NEXT.md) | Resolved (recorded) |
| backend-architect | P2-2: contract-file review should be mandatory not recommended | AC9 + Blake Instructions (mandatory) | Resolved |
| backend-architect | P2-1: durable express fix = frontmatter marker, not slug | §10 recorded debt | Resolved (recorded) |
| code-reviewer | P2-3: worktree copies of files | Confirmed throwaway, excluded from §6 | Resolved (no action) |

## 12. Project Knowledge (Blake 必读历史教训)
- **AC Verification Command Bug: grep -ocE | sort -u | wc -l** (code-quality.md 2026-05-27): never combine `grep -c` with `sort -u | wc -l`; AC3/AC5 use plain anchored greps.
- **Never Hand-Write What an Existing Tool Already Does** (architecture.md 2026-05-28): follow release-runbook's version-bump file list as the authority; don't re-derive from memory.
- **AC Self-Leak from Removal Rationale** (architecture.md 2026-04-27): AC3 grep for `2.19.0` could self-match this handoff's own text — run AC3 only against the listed target files, NOT the handoff.

## Required Evidence Manifest
```yaml
expert_reviews:
  - .tad/evidence/reviews/blake/release-hygiene-conventions/code-reviewer.md
  - .tad/evidence/reviews/blake/release-hygiene-conventions/<second-reviewer>.md
gate_verdicts:
  - COMPLETION frontmatter gate3_verdict (pass|fail|partial)
completion: .tad/active/handoffs/COMPLETION-20260531-release-hygiene-conventions.md
knowledge_updates: project-knowledge entry if any convention lesson surfaces
```

## Blake Instructions
- Standard TAD (not express). Socratic done (Alex). Run Layer 1 (`bash -n tad.sh`; grep ACs) + Layer 2 (≥2 experts: code-reviewer REQUIRED + 1 — recommend a second pass on contract/doc consistency since this edits 2 SKILL contract files).
- Implement → Gate 3 → write COMPLETION + gate3_verdict marker.
- AC3/AC4 are the trap: bump current-display, preserve history. Re-read §10 before editing README/CHANGELOG/codex.
- **AC8 is NOT a grep** — actually exercise `detect_state()` with a 3-part `version.txt` in a throwaway dir and assert `current`. tad.sh:171 fallback must also become `${TARGET_VERSION}` (no `.0`).
- **MANDATORY contract-file review (backend-architect P2-2):** the second Layer-2 reviewer MUST scrutinize the alex/blake SKILL edits and confirm AC9 (run `grep -n 'expert review' alex/SKILL.md` — express `step2` phrase still present, not displaced upward). Do NOT let the SKILL edit ride the "trivial doc bump" halo.
- If the express-slug convention edit forces touching a forbidden/NOT_via/AR-001 block → STOP, escalate to Alex. (Insert downstream of `required_steps` per §6 item 8 to avoid this.)
