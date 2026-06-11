---
task_type: mixed
e2e_required: no
research_required: no
git_tracked_dirs: [".claude/skills", ".agents/skills", ".tad/hooks", ".tad/templates"]
skip_knowledge_assessment: no
gate4_delta: []
---

# Handoff Document for Agent B (Blake)
## TAD v3.1 - Evidence-Based Development

**From:** Alex (Agent A - Solution Lead)
**To:** Blake (Agent B - Execution Master)
**Date:** 2026-06-10
**Project:** TAD Framework
**Task ID:** TASK-20260610-005
**Handoff Version:** 3.1.0
**Epic:** EPIC-20260610-self-evolution-pruning.md (Phase 3/3 — FINAL)

---

## Gate 2: Design Completeness

**Execution**: 2026-06-10

| Check | Status | Notes |
|-------|--------|-------|
| Architecture Complete | ✅ | Full retirement surface mapped (incl. workflow file + prose mentions experts found); harvest protocol consistent with Phase 2 contracts |
| Components Specified | ✅ | 9 modify + 5 delete, every anchor line-verified against live files |
| Functions Verified | ✅ | AC9 anchor byte-verified (L686); AC10 fixture absence discovered + AC redesigned; blake survivor engine L1838-1922 mapped |
| Data Flow Mapped | ✅ | SCAND lifecycle + harvest T2 master-side-only routing (no downstream writes) |
| Expert Review (min 2) | ✅ | code-reviewer + refactor-specialist; 5 P0 + 5 P1 found, ALL integrated (§9.2) |
| P0 Issues Resolved | ✅ | 0 outstanding |

**Gate 2 Result**: ✅ PASS

---

## 1. Task Overview

### 1.1 What We're Building
The final surgery: remove the retired commands (*dream/*evolve/*optimize/*skillify), their protocol sections, reference files, and Alex startup review taxes (STEP 3.56/3.57); delete trace-digest.sh and its step4d wiring; add the *harvest command; clean all stale cross-references; restore full dual-platform parity.

### 1.2 Why
Phases 1-2 retired the engines and built the replacement (T1 ceremony + harvest-scan.sh + skill-library). The retired commands' SKILL surfaces are still loaded into every Alex session — dead protocol text + two startup AskUserQuestion taxes pointing at directories that no longer exist.

### 1.3 Intent Statement
**This is NOT**: touching release-verify.sh or publish-protocol.md (IN-FLIGHT in codex-parity-step3b — hard off-limits); changing KA triple-question text in blake SKILL beyond the one STEP 3.57 pointer; removing trace EMISSION (trace-step/writer/rotate stay); adding any hook.

---

## Project Knowledge (Blake must read)

| File | Entry | Key reminder |
|------|-------|--------------|
| principles.md | "A Coverage Gate's Global-Count Floor Cannot Detect Must-Cover SAFETY Loss When Legit Stripping Also Lowers the Count" (⚠️ SAFETY) | This phase legitimately strips whole constraint blocks. Verification MUST be per-survivor anchors + line-set classification — never a global count floor |
| principles.md | "Rewiring a Gate's Prose Can Trip a grep -c SAFETY Count" (⚠️ SAFETY) | line-SET diff is ground truth; `grep -Fxq` for surviving anchors |
| patterns/gate-design.md | "Claims Need Carriers" (2026-06-10) | Your completion report's classification table (AC14) IS the carrier for the "no illegitimate constraint loss" claim |

---

## 2. Background Context — Anchor Map (grounded 2026-06-10, all line numbers from live files)

**alex/SKILL.md**: frontmatter skillify constraints L106 + L145; STEP 3.5 NEEDS_CLEANUP *dream message L251; L261 interacts_with mentions STEP 3.56; STEP 3.56 block ~L320-348; STEP 3.57 block ~L349-372 (STEP 3.8's "Runs AFTER" chain references 3.57); commands L571-574; skillify_command_protocol L1100-1107 (+ header comment ~L1095); cancel header comment L1112 "future *evolve"; optimize_protocol L1125-1129; evolve_protocol L1130-1134; dream_protocol L1391+; triple_question_draft_rule L1423 ("Alex STEP 3.57 ... or explicit *skillify accept"); on_start greeting + Quick Reference both list *dream.
**references/**: dream-protocol.md, evolve-protocol.md, optimize-protocol.md, skillify-command-protocol.md (DELETE, both platforms); acceptance-protocol.md step4d block L109-156 + L308 "STEP 3.57 or *skillify accept"; accept-command.md L50 "step4d (trace-digest)"; cancel-protocol.md L90 "Do NOT call trace-digest.sh".
**blake/SKILL.md**: ALL `STEP 3.57` mentions (≥2: the step-3 note ~L1870/L1885 region) → re-point. ⚠️ SURVIVORS that MUST NOT be touched: the whole `skillify_evaluation` engine (L1838-1922, it IS the Phase-2 replacement) including the L1897 SAFETY constraint `"MUST NOT auto-invoke *skillify without user explicit command (Alex side) — Blake's path is KA-only"` — its `*skillify` token legitimately survives (whitelist in AC13b).
**surplus/SKILL.md**: L61-62 No-mutation list (the ONLY enumeration in the SKILL) includes `dream-candidates/` + `.tad/evidence/proposals/`.
**surplus-scan.workflow.js** (`.claude/workflows/`, L41 + L43): hardcodes `dream-candidates/` + `evidence/proposals/` as live scan sources — MUST be cleaned or every future *surplus scans dead dirs (no .agents twin; workflows are Claude-only).
**Surviving-prose *evolve mentions to reword** (clean-sweep targets, files survive): cancel-protocol.md L118 ("future *evolve"), acceptance-protocol.md L335/L369/L373 (gate4_delta rationale "future *evolve queries") → reword to "future cross-project audits".
**AC10 fixture reality**: `.tad/evidence/designs/extracts/v2-section-4.1.1-anti-rationalization.yaml` does NOT exist on disk or in git (only an archived spike copy of unverified provenance). The SKILL header's extraction-contract note is stale — AC10 redefined as self-consistency (see §4.2), header staleness recorded as carry-forward.
**gate/SKILL.md + config-workflow.yaml + CLAUDE.md**: ZERO matching anchors (verified) — NOT in scope.
**In-flight collision**: codex-parity-step3b touches release-verify.sh + publish-protocol.md only. File-disjoint from this handoff. Full-tree parity diff may show their files mid-work.

---

## 3. Requirements

- FR1: Remove all retired surfaces from alex SKILL per Anchor Map; *optimizer (performance-optimizer shortcut) and all non-retired text SURVIVE.
- FR2: Add `harvest` command + `harvest_protocol` IN BODY (~30 lines, see §4.1). Trigger is explicit command only — NO startup scan (that's the tax we're removing).
- FR3: Delete trace-digest.sh + all step4d wiring (acceptance-protocol L109-156 block; accept-command L50 item; cancel-protocol L90 mention reworded to keep only layer2-audit).
- FR4: Update pointers: triple_question_draft_rule human_confirmation → "Blake T1 in-session ceremony (skillify_evaluation step 5) or master *harvest review"; acceptance-protocol L308 same; blake SKILL L1870 same.
- FR5: surplus SKILL L61-62 (the single No-mutation list): drop dream-candidates + evidence/proposals. PLUS surplus-scan.workflow.js L41+L43: remove the two retired source dirs from the live scan (expert P0 — SKILL edit alone leaves the workflow scanning dead dirs).
- FR5b: reword surviving-prose *evolve mentions per §2 list (cancel-protocol L118, acceptance-protocol L335/L369/L373 → "future cross-project audits").
- FR6: completion-report template: add one line under Evidence Checklist: "Every claim in this report must have an on-disk carrier file (claims-need-carriers — patterns/gate-design.md)".
- FR6b: skillify-candidate-template.md: add `materialized_at: ~` + `reference_at: ~` fields (Phase 2 FR4b contract fields exist in live Colin SCANDs but not in the template — set only during ceremony/harvest, never by discoverer).
- FR7: Mirror every touched/deleted file to .agents/skills; per-file `cmp` identity; full-tree `diff -qr` recorded as ADVISORY (codex-parity files may appear — list them, don't fail).
- FR8: SAFETY survivor verification + removed-line classification (see §4.2).

## 4. Technical Design

### 4.1 harvest_protocol (alex SKILL body)
```yaml
harvest_protocol:
  description: "Master-side review of skillify candidates across ALL projects (registry + this repo)"
  trigger: "*harvest (explicit command ONLY — no startup auto-scan)"
  steps:
    1_scan: "bash .tad/hooks/lib/harvest-scan.sh → display table + COLLISIONS section. ALSO list this repo's own .tad/active/skillify-candidates/ (scanner covers registry projects only)."
    2_route_per_candidate (AskUserQuestion each, human decides):
      - "T2 → copy pattern summary to .tad/skill-library/{project}--{slug}.md + _index entry. MASTER-SIDE FILES ONLY — the source project's SCAND frontmatter (tier: T2, reference_at — Phase 2 FR4b fields) is updated by THAT project's next session; *harvest output includes a per-project 'pending frontmatter updates' note"
      - "T1-remote → note: materialization happens in THAT project's next Blake session via the T1 ceremony — Alex does NOT write into downstream projects from here"
      - "skip → SCAND stays draft"
    3_collisions: "Same slug in ≥2 projects = T3 graduation signal → suggest pack-promotion *analyze (≥2-project Domain Pack rule). Suggestion only."
  forbidden_implementations:
    - "MUST NOT auto-run harvest at Alex startup (explicit command only — the startup review tax was retired 2026-06-10)"
    - "MUST NOT materialize T1 skills into downstream projects from master *harvest — T1 runs in-situ via Blake's ceremony"
    - "MUST NOT accept candidates without per-candidate human AskUserQuestion"
```

### 4.2 SAFETY verification design (the load-bearing part)
1. BEFORE editing: `cp .claude/skills/alex/SKILL.md /tmp/alex-before.md`
2. AFTER: bidirectional line-set diff (`comm` on sorted unique non-blank lines). Classify EVERY removed line containing `MUST|MANDATORY|VIOLATION|forbidden` into: (a) inside a retired section (3.56/3.57/commands/skillify_command/optimize/evolve/dream protocol blocks) → legit; (b) anything else → STOP, restore, report. Table goes in completion report (AC14 carrier).
3. Survivor anchors (ALL must pass): the `NOT_via_alex_auto: true` line (grep -Fxq, byte-exact at current L686 with 2-space indent); `<!-- anti_rationalization_registry:BEGIN -->` + END markers; AR-registry SELF-CONSISTENCY (the external fixture file does not exist — expert-verified): awk-extract per the SKILL-header recipe is non-empty AND contains all 5 ids `AR-001..AR-005`; `tad_friction_protocol:` present; `forbidden:` block (Alex forbidden actions) intact. Carry-forward (do NOT fix now): SKILL header's extraction-contract note references the missing fixture path — record in completion report for a future docs pass.

### 4.3 Sequencing
1. Baseline copies (alex SKILL + each reference to be edited)
2. alex SKILL body surgery (FR1, FR2, FR4-pointer in triple_question). Re-wire rule (expert-corrected): STEP 3.8 needs NO edit (it chains through 3.7 only). After deletions, run `grep -nE 'STEP 3\.5[67]' alex/SKILL.md` — every surviving hit (known: L261 STEP 3.5 interacts_with clause "or STEP 3.56 (dream candidates)"; any STEP 3.55 cross-mention) gets reworded to drop the dead step. L251 reword constraint: replacement text must contain ZERO `dream` substring (also sweep auto-dream/dreaming/dream-state residue — AC13a is case-insensitive).
3. References surgery (FR3, FR4, *evolve prose rewording per §2) + delete 4 protocol reference files
4. blake (all STEP 3.57 mentions; preserve skillify_evaluation engine + L1897 constraint) + surplus SKILL + surplus-scan.workflow.js L41/L43 + template edits (FR4/5/6 + reference_at/materialized_at fields)
5. Delete trace-digest.sh
6. Mirror all touched .claude/skills files to .agents (incl. deletions); workflows have no .agents twin
7. §4.2 verification + all ACs

## 5. Mandatory Questions
MQ1-5: N/A (protocol text surgery). MQ6: covered by epic evidence chain.

## 6. Implementation Steps (estimated 60-90 min)
Per §4.3. Layer 2: code-reviewer + spec-compliance (artifact FILES in evidence/reviews/blake/sep-phase3/ — claims need carriers).

## 7. File Structure
Modify: `.claude/skills/alex/SKILL.md`, `references/acceptance-protocol.md` (step4d removal + L308 pointer + *evolve prose), `references/accept-command.md`, `references/cancel-protocol.md` (L90 + L118), `.claude/skills/blake/SKILL.md` (all STEP 3.57 pointers; skillify_evaluation engine PRESERVED), `.claude/skills/surplus/SKILL.md`, `.claude/workflows/surplus-scan.workflow.js` (L41+L43; no .agents twin), `.tad/templates/completion-report.md`, `.tad/templates/skillify-candidate-template.md` (+ .agents mirrors of each skills file)
Delete: `references/{dream,evolve,optimize,skillify-command}-protocol.md` ×2 platforms; `.tad/hooks/lib/trace-digest.sh`
OFF-LIMITS: `release-verify.sh`, `references/publish-protocol.md` (in-flight elsewhere)

## 8. Testing Requirements

### 8.4 Friction Preflight
| Friction Point | Required Step | Expected Fix Path | Allowed Substitute | Gate Impact |
|---|---|---|---|---|
| None — local text surgery + 1 file deletion | — | — | — | — |

### 8.5 Feedback Collection
```yaml
feedback_required: false
```

## 9.1 Spec Compliance Checklist — PRIMARY VERIFICATION SOURCE

| # | Acceptance Criterion | Verification Method | Expected |
|---|---------------------|--------------------|----------|
| AC1 | retired commands gone | `grep -cE '^  (optimize|evolve|dream|skillify):' .claude/skills/alex/SKILL.md \|\| true` | 0 |
| AC2 | harvest command present | `grep -c '^  harvest:' .claude/skills/alex/SKILL.md` | 1 |
| AC3 | STEPs 3.56/3.57 gone | `bash -c "grep -cE 'STEP 3\.5[67]' .claude/skills/alex/SKILL.md \|\| true"` | 0 |
| AC4 | retired protocol sections gone | `bash -c "grep -cE '^(dream_protocol|evolve_protocol|optimize_protocol|skillify_command_protocol):' .claude/skills/alex/SKILL.md \|\| true"` | 0 |
| AC5 | 4 reference files deleted both platforms | `ls .claude/skills/alex/references/{dream,evolve,optimize,skillify-command}-protocol.md .agents/skills/alex/references/{dream,evolve,optimize,skillify-command}-protocol.md 2>/dev/null \| wc -l \| tr -d ' '` | 0 |
| AC6 | harvest_protocol in body not references | `grep -c '^harvest_protocol:' .claude/skills/alex/SKILL.md; ls .claude/skills/alex/references/harvest* 2>/dev/null \| wc -l \| tr -d ' '` | 1 then 0 |
| AC7 | trace-digest.sh deleted | `test -f .tad/hooks/lib/trace-digest.sh \|\| echo GONE` | GONE |
| AC7b | step4d wiring gone | `bash -c "grep -c 'step4d\|trace-digest' .claude/skills/alex/references/acceptance-protocol.md .claude/skills/alex/references/accept-command.md .claude/skills/alex/references/cancel-protocol.md \| awk -F: '{s+=\$2}END{print s}'"` | 0 |
| AC8 | trace EMISSION survives | `ls .tad/hooks/trace-step.sh .tad/hooks/lib/trace-writer.sh .tad/hooks/lib/trace-rotate.sh \| wc -l \| tr -d ' '` | 3 |
| AC9 | NOT_via_alex_auto anchor byte-exact | `grep -Fxq '  NOT_via_alex_auto: true  # Alex NEVER auto-invokes external CLI — suggest or delegate only' .claude/skills/alex/SKILL.md && echo OK` | OK |
| AC10 | AR-registry self-consistency (fixture file does not exist — redefined per expert review) | awk-extract per SKILL-header recipe → non-empty AND `grep -c 'id: "AR-00'` on extract output | extract >40 lines, count 5 |
| AC11 | friction protocol survives | `grep -c '^tad_friction_protocol:' .claude/skills/alex/SKILL.md` | 1 |
| AC12 | *optimizer shortcut survives | `grep -c '\*optimizer' .claude/skills/alex/SKILL.md` | ≥1 |
| AC13a | clean sweep — alex SKILL only | `bash -c "grep -ciE 'dream' .claude/skills/alex/SKILL.md \|\| true"` and `bash -c "grep -cE '\*evolve|\*skillify|STEP 3\.5[67]' .claude/skills/alex/SKILL.md \|\| true"` | 0 and 0 |
| AC13b | blake: dead tokens 0, survivor whitelisted (NOT count-to-zero — L1897 SAFETY constraint survives by design) | `bash -c "grep -cE '\*evolve|STEP 3\.57' .claude/skills/blake/SKILL.md \|\| true"` then `grep -nE '\*skillify' .claude/skills/blake/SKILL.md` | 0; exactly 1 line = the "MUST NOT auto-invoke *skillify" constraint |
| AC13c | surviving references *evolve prose reworded | `bash -c "grep -c '\*evolve' .claude/skills/alex/references/cancel-protocol.md .claude/skills/alex/references/acceptance-protocol.md \| awk -F: '{s+=\$2}END{print s}'"` | 0 |
| AC14 | removed-line classification table in completion report; zero non-retired constraint losses | manual table + statement (carrier) | table present, 0 illegit |
| AC15 | surplus SKILL sources cleaned | `bash -c "grep -c 'dream-candidates\|evidence/proposals' .claude/skills/surplus/SKILL.md \|\| true"` | 0 |
| AC15b | surplus WORKFLOW sources cleaned (live scan path) | `bash -c "grep -c 'dream-candidates\|evidence/proposals' .claude/workflows/surplus-scan.workflow.js \|\| true"` | 0 |
| AC16 | template carrier line | `grep -c 'claims-need-carriers' .tad/templates/completion-report.md` | 1 |
| AC16b | SCAND template gains Phase-2 contract fields | `grep -cE '^(materialized_at|reference_at):' .tad/templates/skillify-candidate-template.md` | 2 |
| AC17 | per-file parity for every touched file | `cmp` each .claude file vs .agents twin → all identical | all OK |
| AC17b | full-tree parity advisory | `diff -qr .claude/skills .agents/skills` → only codex-parity-step3b files (release-verify n/a, publish-protocol.md) may differ; paste output | recorded |
| AC18 | off-limits untouched | `git diff --name-only HEAD -- .tad/hooks/lib/release-verify.sh .claude/skills/alex/references/publish-protocol.md \| wc -l \| tr -d ' '` | 0 |

## 9.2 Expert Review Status

**Review date**: 2026-06-10 | **Experts**: code-reviewer + refactor-specialist (parallel) | **Initial verdict**: both NOT READY

| ID | Severity | Finding | Resolution |
|----|----------|---------|------------|
| CR-P0-A | P0 | AC13 global count-to-zero would force deleting blake L1897 surviving `*skillify` SAFETY constraint — the exact global-count-floor failure the cited principle warns about | AC13 split: 13a alex-only=0; 13b blake dead-tokens=0 + survivor WHITELIST (exactly the L1897 constraint); anchor map expanded with survivor warning |
| CR-P0-B | P0 | AC10 referenced fixture file that does not exist on disk or in git | AC10 redefined as self-consistency (extract non-empty + 5 AR ids); header staleness = recorded carry-forward |
| RS-P0-1 | P0 | surplus-scan.workflow.js L41/L43 hardcodes retired dirs — SKILL-only edit leaves live scans reading dead paths | FR5 extended + AC15b; §7 list updated (workflows have no .agents twin) |
| RS-P0-2/3 | P0 | Re-wire instruction targeted STEP 3.8 (which doesn't chain through 3.56/3.57) and under-specified L261 | §4.3 step 2 corrected: STEP 3.8 NO edit; post-deletion grep sweep of `STEP 3.5[67]` survivors named (L261 etc.) |
| RS-P1-1 | P1 | `reference_at` not in SCAND template (expert thought field was wrong; actually it IS the Phase 2 FR4b contract — live in 2 Colin SCANDs — template just lags) | FR6b + AC16b: template gains materialized_at + reference_at |
| RS-P1-2/3 | P1 | `*evolve` prose survives in cancel-protocol L118 + acceptance-protocol L335/369/373 (outside AC13's old scope) | FR5b reword to "future cross-project audits" + AC13c |
| RS-P1-4 | P1 | blake has ≥2 STEP 3.57 mentions, map named only one | Anchor map: ALL STEP 3.57 mentions in blake |
| RS-P2-1 | P2 | harvest T2 wrote into downstream SCAND — contradicted "pointer not action" | §4.1 T2 = master-side files only + pending-update note for source project |
| CR-P1 | P1 | L251 reword could reintroduce `dream` substring | §4.3 explicit zero-`dream` constraint on replacement text |
| CR-P2 | P2 | AC7b relies on pipe-swallow of grep exit | accepted (piped form is correct); noted |

**P0 outstanding**: 0 | **Final**: READY

## 10. Important Notes
- **The classification table (AC14) is the SAFETY centerpiece** — a missing table = Gate 4 PARTIAL by definition (claims need carriers)
- STEP 3.8/3.9 and STEP 3.55 SURVIVE — only 3.56/3.57 are removed; re-wire any interacts_with text that chains through them
- on_start greeting + Quick Reference + commands: remove *dream/*skillify mentions; add *harvest one-liner
- L251 NEEDS_CLEANUP message: reword to suggest manual consolidation (no *dream)

## 11. Decision Rationale
| Decision | Alternatives | Why |
|----------|--------------|-----|
| *harvest explicit-only, no startup scan | startup auto-scan like 3.57 | The startup tax IS the disease being cured; harvest value is on-demand |
| T1-remote = pointer not action | master writes into downstream | Role-decay incident + harvest stays read-only toward projects; T1 belongs in-situ |
| Gate SKILL untouched | epic originally listed it | Grounding found zero Q2/Q3/skillify anchors in gate SKILL — scope corrected |
| Full-tree parity = advisory | hard AC | codex-parity-step3b is legitimately mid-flight on 2 disjoint files |

---

**Handoff Created By**: Alex (Agent A)
**Date**: 2026-06-10
**Version**: 3.1.0
