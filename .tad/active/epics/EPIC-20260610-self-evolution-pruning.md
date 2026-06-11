# Epic: Self-Evolution Pruning + Skill Formalization Pipeline

**Epic ID**: EPIC-20260610-self-evolution-pruning
**Created**: 2026-06-10
**Owner**: Alex
**Origin**: IDEA-20260610-self-evolution-pruning-skillify-last-mile (promoted 2026-06-10)

---

## Objective
Retire the near-zero-yield automated self-evolution loops (*dream incl. manual, *evolve, *optimize, dream-scanner, trace mining) and replace the broken skillify last mile with a working three-tier formalization pipeline: T1 project-local skills (default, Blake+human in-session), T2 master reference shelf (.tad/skill-library/, never distributed), T3 promotion to distributable packs (≥2-project evidence bar, reusing the Domain Pack decision rule).

Measured basis (2026-06-10): dream 10 candidates → 1 accepted; optimize/evolve 8 PROPOSALs → 0 accepted; Colin 3 SCANDs marked accepted with ZERO artifacts materialized. Every effective TAD upgrade to date was human-pain-driven.

## Success Criteria
- [ ] Noise generators fully retired: commands, protocol references, lib scripts, Alex startup review taxes (STEP 3.56/3.57) all gone; trace EMISSION preserved (forensics only)
- [ ] T1 loop demonstrated once on a real candidate (one of Colin's 3 stuck SCANDs materialized end-to-end with artifact AC)
- [ ] T2 shelf exists (.tad/skill-library/, deny-listed in BOTH derive-sync-set.sh and tad.sh) with ≥1 harvested reference
- [ ] Negative-result evidence archived (PROPOSALs, dream candidates, yield measurements) — the data that justified retirement is itself preserved

## Human Decisions (2026-06-10, binding)
- *dream: FULL retirement (manual version too)
- T1 ceremony: Blake + in-session human confirmation (draft-then-confirm satisfied; no separate Alex session required)
- T2 location: `.tad/skill-library/` (new dir, zero-touch deny-listed)
- Collision handling: phase to avoid in-flight Feedback Collector Phase 2 files (alex/SKILL.md, alex/references/acceptance-protocol.md, gate/SKILL.md)

---

## Phase Map

| # | Phase | Status | Handoff | Key Deliverable |
|---|-------|--------|---------|-----------------|
| 1 | Disjoint Retirement + T2 Shelf | ✅ Done | HANDOFF-20260610-sep-phase1.md (archived) | Scripts retired, artifacts archived, skill-library created + deny-listed, SCAND template hardened |
| 2 | T1 Local Formalization (Blake-side) | ⬚ Planned | — | blake SKILL skillify_evaluation → confirm-and-materialize flow + artifact AC + harvest scan lib |
| 3 | Alex/Gate SKILL Surgery + *harvest | ⬚ Blocked | — | Remove *dream/*evolve/*optimize/*skillify commands+protocols+STEPs 3.56/3.57, add *harvest, mirror .agents |

### Phase Dependencies
- Phase 1: independent (touches ONLY .tad/hooks/lib, .tad/templates, .tad/skill-library, tad.sh, archive moves — zero .claude/skills files)
- Phase 2: independent of in-flight work (blake/SKILL.md is NOT in the Feedback Collector Phase 2 file set; mirror to .agents/skills/blake required)
- Phase 3: **BLOCKED until** EPIC-20260610-feedback-collector Phase 2 (and any Phase 3 SKILL edits) land AND `diff -qr .claude/skills .agents/skills` exits 0

### Derived Status
- **Status**: In Progress | **Progress**: 0/3

---

## Phase Details

### Phase 1: Disjoint Retirement + T2 Shelf

**Status:** ✅ Done
**Completed:** 2026-06-10, Handoff: HANDOFF-20260610-sep-phase1.md, Commits: 89b20b0 (+ archival pre-landed in f84c8fb)

#### Scope
Everything retirement-related that does NOT touch any SKILL.md: delete mining scripts, archive negative-result artifacts, create the T2 shelf with dual deny-list registration, harden the SCAND template. NOT in scope: any .claude/skills or .agents/skills edit, settings.json changes (none needed — verified: dream-scanner/validator/trace-digest have no settings.json registrations), hook registrations (forbidden for skillify per blake SKILL constraint).

#### Acceptance Criteria
See HANDOFF-20260610-sep-phase1.md §9.1

#### Files Likely Affected
- `.tad/hooks/lib/dream-scanner.sh` (DELETE — sole consumer is retired *dream path; interim invocation fails fast by design)
- `.tad/hooks/lib/dream-validator.sh` (DELETE — same)
- ⚠️ `.tad/hooks/lib/trace-digest.sh` NOT deleted in Phase 1 — live-wired into *accept step4d via alex/references/acceptance-protocol.md, which is IN-FLIGHT in the Feedback Collector epic. Deletion moved to Phase 3.
- `.tad/active/dream-candidates/` → `.tad/archive/dream-candidates/` (MOVE), `.tad/active/dream-state.yaml` (DELETE after archiving)
- `.tad/evidence/proposals/` → `.tad/archive/proposals/` (MOVE + NEGATIVE-RESULT.md)
- `.tad/skill-library/` (CREATE: README.md + _index.md)
- `.tad/hooks/lib/derive-sync-set.sh` (MODIFY: add skill-library to ZERO_TOUCH)
- `tad.sh` (MODIFY: add skill-library to inlined TAD_ZERO_TOUCH — drift rule requires BOTH)
- `.tad/templates/skillify-candidate-template.md` (MODIFY: default status: draft + discoverer-must-not-accept constraint)

### Phase 2: T1 Local Formalization (Blake-side)

**Status:** ⬚ Planned

#### Scope
Rewrite blake SKILL `skillify_evaluation` (line ~1822) from "write SCAND and stop" to draft → in-session human confirm → materialize (create project-local `.claude/skills/{slug}/SKILL.md` or augment named target) → artifact-existence AC in completion report. Add harvest scan lib script (read-only, master-side, reports candidates + cross-project slug collisions for T3 graduation signal). Verify sync safety: project-local skills survive *sync (local slugs not in master set must not be deleted/flagged). Dogfood: materialize one Colin SCAND end-to-end.
Mirror blake/SKILL.md to .agents/skills/blake/SKILL.md (parity).

### Phase 3: Alex/Gate SKILL Surgery + *harvest

**Status:** ⬚ Blocked (on Feedback Collector epic SKILL edits landing + parity zero)

#### Scope
Alex SKILL: remove commands dream/evolve/optimize/skillify (L571-574 region), STEP 3.56 + 3.57 activation steps, dream/evolve/optimize/skillify protocol sections + their references/ files; update knowledge-health NEEDS_CLEANUP message (currently suggests *dream); add *harvest command + protocol (wraps Phase 2 lib). Gate SKILL: KA triple-question Q2/Q3 wording updated to point at T1 flow. Config-workflow.yaml + CLAUDE.md cross-references cleaned. Full .agents mirror + `diff -qr` zero. Frontmatter constraints (alex SKILL L106/L145 skillify entries) updated.
ALSO (moved from Phase 1): delete `.tad/hooks/lib/trace-digest.sh` + remove its step4d advisory wiring from acceptance-protocol.md / accept-command.md / cancel-protocol.md (these references are in-flight or co-located with in-flight files until the Feedback Collector epic lands).

---

## Context for Next Phase
{Alex updates after each *accept}

### Completed Work Summary
- Phase 1 (2026-06-10, Gate 4 PASS 16/16 AC, commit 89b20b0): dream-scanner/validator deleted; 11 PROPOSALs + 6 CANDs + dream-state archived with NEGATIVE-RESULT.md; `.tad/skill-library/` created + dual deny-list (14 entries, --verify-denylist PASS); SCAND template `status: draft` + discoverer-must-not-accept constraint. Rider: layer2-audit.sh KNOWN_REVIEWERS += code-review/config-manager/config-manager-review (fixes recurrence of 2026-05-27 reviewer-name-drift incident).

### Decisions Made So Far
- Gate 4 was PARTIAL once: Blake's completion existed only as chat message → returned for COMPLETION file (precedent: completion claims need a file carrier; consistent with "acceptance = action with artifact AC")
- f84c8fb commit message mislabeled (says Feedback Collector parity, also contains sep-phase1 archival) — content verified, hygiene note only

### Known Issues / Carry-forward
- Stale references degrade gracefully until Phase 3: alex STEP 3.56 (silent skip), surplus SKILL evidence/proposals source (0 results), dream-protocol.md (fail-fast on deleted scripts)
- Phase 3 must also: delete trace-digest.sh + its step4d wiring (acceptance-protocol.md / accept-command.md / cancel-protocol.md)
- Phase 3 gate precondition: verify `diff -qr .claude/skills .agents/skills` exits 0 (Feedback Collector epic landed; f84c8fb was its parity sync)

### Next Phase Scope
Phase 2: T1 Local Formalization (Blake-side) — blake SKILL skillify_evaluation → confirm-and-materialize flow + artifact AC; harvest scan lib; sync-safety verification; dogfood on one Colin SCAND

---

## Notes
- Evidence basis: .tad/active/ideas/IDEA-20260610-self-evolution-pruning-skillify-last-mile.md (full yield data + four-breakpoint diagnosis + destination taxonomy)
- Colin's 3 stuck SCANDs are the Phase 2 dogfood corpus: colab-drive-deploy, eval-page-generator, smart-interval
- Constraint inherited from blake SKILL: "MUST NOT register hooks for skillify enforcement" — all enforcement is template + SKILL text, not hooks
- Deny-list edits are SAFETY-adjacent (principles.md 2026-06-01 entries) — expert review must verify dual-file consistency + --verify-denylist PASS
