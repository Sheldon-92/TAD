---
task_type: mixed
e2e_required: yes
research_required: no
git_tracked_dirs: [".claude/skills/blake", ".agents/skills/blake", ".tad/hooks", ".tad/skill-library"]
skip_knowledge_assessment: no
gate4_delta: []
---

# Handoff Document for Agent B (Blake)
## TAD v3.1 - Evidence-Based Development

**From:** Alex (Agent A - Solution Lead)
**To:** Blake (Agent B - Execution Master)
**Date:** 2026-06-10
**Project:** TAD Framework
**Task ID:** TASK-20260610-004
**Handoff Version:** 3.1.0
**Epic:** EPIC-20260610-self-evolution-pruning.md (Phase 2/3)

---

## Gate 2: Design Completeness

**Execution**: 2026-06-10

| Check | Status | Notes |
|-------|--------|-------|
| Architecture Complete | ✅ | T1 ceremony + carve-out + harvest scanner + structural-gate fix, grounded against live files |
| Components Specified | ✅ | 5 creations, 6 modifications (incl. release-verify FR7 + template FR8), exact old→new for the SAFETY line |
| Functions Verified | ✅ | blake SKILL L1839-1883 read; OLD forbidden line byte-verified; release-verify L163 risk confirmed by expert |
| Data Flow Mapped | ✅ | SCAND lifecycle: draft → (ceremony) → accepted+tier{T1:materialized_at / T2:reference_at} → harvest visibility |
| Expert Review (min 2) | ✅ | code-reviewer + config-manager; 2 P0 + 5 P1 found, ALL integrated (§9.2) |
| P0 Issues Resolved | ✅ | 0 outstanding |

**Gate 2 Result**: ✅ PASS

---

## 1. Task Overview

### 1.1 What We're Building
The T1 local-formalization ceremony (Blake-side): skillify candidates stop dying as paper. After the KA 4-gate pass, Blake asks the human IN-SESSION; on approval Blake materializes the skill (artifact file, not a status edit) and the completion report carries an artifact-existence AC. Plus: a master-side read-only harvest scanner over all registered projects, and a real dogfood routing Colin's 3 stuck SCANDs through the T1/T2 taxonomy.

### 1.2 Why
Phase 1 evidence: Colin's 3 SCANDs were marked `accepted` with ZERO artifacts — "accepted" was a status edit with no executor. The 2026-06-10 human decision: T1 ceremony = Blake + in-session human confirmation (no separate Alex session required).

### 1.3 Intent Statement

**The real problem**: capture works (pain-driven, high quality), but no step in any protocol CREATES the skill file. The pipeline ends at a frontmatter field.

**This is NOT**:
- Alex SKILL surgery or *harvest command wiring (Phase 3 — now UNBLOCKED, parity verified 0)
- Auto-acceptance (human in-session confirmation is the gate; unattended materialization stays forbidden)
- T3 pack promotion (colab-drive-deploy has single-project evidence — stays T2 until a 2nd project corroborates, per the ≥2-project Domain Pack decision rule)

---

## Project Knowledge (Blake must read)

| File | Relevant entries | Key reminder |
|------|-----------------|--------------|
| principles.md | "Rewiring a Gate's Prose Can Trip a grep -c SAFETY Count" | When amending the forbidden line, RETAIN the constraint citation verbatim in the new text; verify with line-set discipline, not just counts |
| principles.md | "Judgment-Only Skill Files: Constraint Rules Are NOT Mechanical" (⚠️ SAFETY) | You are EDITING a forbidden_implementations entry — list the exact contract change (old line → new line) in the completion report (AR-002 obligation) |
| patterns/handoff-design.md | Embed Into Existing Flows | T1 ceremony extends skillify_evaluation in place — do NOT create a new command or top-level section |
| incidents 2026-06 | alex-role-decay-direct-execution | Cross-project writes (Colin) are sanctioned HERE by handoff + in-session human approval — both must actually happen, in that order |

---

## 2. Background Context (grounded 2026-06-10)

- blake SKILL `skillify_evaluation`: lines 1839-1883. Current flow ends at step 3/4 (write SCAND, note in completion report). Constraint to amend at ~L1879: `"MUST NOT create .claude/skills/{slug}/SKILL.md from Blake — Blake writes candidates, Alex/human creates skills"`
- Phase 1 landed: SCAND template defaults `status: draft` (discoverer must not set accepted); `.tad/skill-library/` exists with empty `_index.md`; deny-listed (14 entries)
- Colin SCANDs (at `/Users/sheldonzhao/Downloads/Colin声音项目/.tad/active/skillify-candidates/`): SCAND-20260603-colab-drive-deploy (legacy status: accepted, target ml-training), SCAND-20260606-eval-page-generator, SCAND-20260607-smart-interval — all with zero artifacts
- Skills parity currently 0 (`diff -qr .claude/skills .agents/skills`)
- sync-registry.yaml: 14 projects (paths listed there — harvest scanner derives from it, never hardcodes)

---

## 3. Requirements

- FR1: skillify_evaluation gains step 5 (T1 ceremony): after 4-gate pass + Step-5 type routing → AskUserQuestion in-session: materialize (T1) / keep draft / discard. On materialize: create artifact, update SCAND (`status: accepted`, `tier: T1`, `materialized_at: {path}`), add artifact-existence AC row to completion report.
- FR2: Forbidden line amended with narrow carve-out (see §4.2 exact text). Unattended/auto materialization remains forbidden.
- FR3: `.tad/hooks/lib/harvest-scan.sh` — read-only scan of registered projects' skillify-candidates; table output (project, slug, type, status, tier, age_days); cross-project slug-collision section (T3 graduation signal). Derives project list from sync-registry.yaml.
- FR4: Dogfood with real routing (requires user in-session):
  - smart-interval → **T1**: materialize into Colin (`.claude/skills/smart-interval/SKILL.md` built from the SCAND's pattern content)
  - eval-page-generator → **T2**: `.tad/skill-library/colin--eval-page-generator.md` (+ note: superseded-in-spirit by Feedback Collector — kept as origin reference)
  - colab-drive-deploy → **T2**: `.tad/skill-library/colin--colab-drive-deploy.md` (+ note: T3 candidate for ml-training pack WHEN a 2nd project corroborates)
  - `_index.md` updated with both T2 entries
- FR4b: SCAND frontmatter contract per tier (expert review CR-P1-2/CM-P2 — Blake must not guess):
  - T1: `status: accepted`, `tier: T1`, `materialized_at: {project-local skill path}`
  - T2: `status: accepted`, `tier: T2`, `reference_at: {.tad/skill-library/... path}` (NO materialized_at — there is no local artifact)
  - draft/rejected: no tier
- FR5: blake/SKILL.md mirrored to `.agents/skills/blake/SKILL.md`; parity diff back to 0.
- FR6: Sync-safety: expert review ALREADY CONFIRMED the risk (config-manager, 2026-06-10): `release-verify.sh` L163 flat `diff -rq` on `.claude/skills` counts target-side extras ("Only in target") as fails → on minor+ release the structural gate would HARD BLOCK any project holding a local skill. tad.sh copy itself never deletes extras (cp -r per-dir, no target-side rm) — survival is safe, the GATE is the problem. Blake documents this analysis (citations above + own verification) in sync-safety-analysis.md.
- FR7 (NEW — resolves FR6's finding BEFORE the FR4 dogfood creates the blocking state): amend `release-verify.sh` structural mode: for the `.claude/skills` comparison, lines matching `^Only in {TARGET}` are reported as `INFO local-skill:` and do NOT increment fails; missing-in-target and differing files still fail. Rationale: the structural gate exists to catch INCOMPLETE copies (omissions); target-side extras are the T1 local-skill model working as designed — counting them as failures is the allow-list disease ("target must equal source exactly") on the verify side. Do this while TAD_RELEASE_GATE=warn is still on (NEXT.md follow-up (a) context — gate not yet hard-blocking).
- FR8: skillify-candidate-template.md gains `tier: ~  # T1 | T2 | T3 — set ONLY during the T1 ceremony or harvest routing, NEVER by the discoverer` (expert review CM-P1-B).

NFR: no hooks, no settings.json changes, no Alex/Gate SKILL edits, harvest scanner strictly read-only (no mutation of any downstream project except the sanctioned Colin dogfood writes in FR4). FR7 ordering constraint: release-verify amendment lands BEFORE the Colin materialization (AC ordering enforces).

---

## 4. Technical Design

### 4.1 T1 ceremony (insert as skillify_evaluation step 5, after existing step 4)
```yaml
5. T1 materialization ceremony (2026-06-10 decision — in-session human confirmation):
   trigger: "Steps 1-2b produced a SCAND with 4/4 gates AND the human is present in-session"
   a. AskUserQuestion: "Pattern {slug} passed 4/4 gates. Materialize now?"
      options: "Materialize as project skill (T1)" / "Keep as draft candidate" / "Discard"
   b. On Materialize:
      - type judgment → create .claude/skills/{slug}/SKILL.md from the SCAND's
        Proposed Skill Outline (project-local; NOT TAD-master unless working in TAD repo)
      - type orchestration → create .claude/workflows/{slug}.workflow.js skeleton
      - Update SCAND frontmatter: status: accepted, tier: T1, materialized_at: {path}
      - Completion report MUST add row: "Skill materialized: {path}" with
        verification `test -f {path}` — acceptance = action with artifact AC
   c. On Keep draft: SCAND stays status: draft (visible to master *harvest)
   d. On Discard: status: rejected (audit trail)
   e. If human NOT present (autonomous/YOLO session): skip ceremony, SCAND stays
      draft — unattended materialization is FORBIDDEN
```

### 4.2 Forbidden-line amendment (exact old → new; retain constraint citation)
OLD: `- "MUST NOT create .claude/skills/{slug}/SKILL.md from Blake — Blake writes candidates, Alex/human creates skills"`
NEW: `- "MUST NOT create .claude/skills/{slug}/SKILL.md from Blake UNATTENDED — the T1 in-session ceremony (2026-06-10 decision) is the ONLY sanctioned path: human explicitly approves via AskUserQuestion in the same session, SCAND records tier+materialized_at, completion report carries an artifact-existence AC. MUST NOT treat handoff pre-approval as satisfying the AskUserQuestion requirement — the in-session interactive question is mandatory even when a handoff pre-routes the outcome. Outside that ceremony, Blake writes candidates only; auto/unattended materialization stays forbidden"`

### 4.3 harvest-scan.sh (read-only; ~80-120 lines)
- Parse sync-registry.yaml project paths (awk/grep, no yq dependency)
- For each: list `.tad/active/skillify-candidates/SCAND-*.md`, extract frontmatter (name/type/status/tier), compute age from filename date
- Output: per-project table + `COLLISIONS:` section (same slug in ≥2 projects → T3 graduation signal) + summary counts
- Strictly read-only: script contains NO mv/cp/rm/mkdir targeting project paths
- Exit 0 always (reporting tool, not a gate)

### 4.4 Dogfood sequencing
0. FR7 release-verify amendment FIRST (must land before any Colin write — see NFR ordering constraint)
1. Run harvest-scan.sh → confirm it surfaces Colin's 3 candidates (scanner tolerates missing frontmatter fields: absent tier/status → display "-"; age from FILENAME date, not frontmatter `created:`/`date:` which are inconsistent across the 3)
2. Human routes in-session — ⚠️ the AskUserQuestion at execution time is MANDATORY; this handoff's §FR4 pre-routing does NOT satisfy ceremony step a (it only tells Blake what to propose as defaults)
3. Execute FR4 writes; Colin SCANDs updated per FR4b frontmatter contract
4. smart-interval SKILL.md content: derive from SCAND's algorithm section; keep ≤150 lines; frontmatter name/description per Claude Code skill conventions

---

## 5. Mandatory Questions
MQ1-MQ5: N/A (protocol text + read-only scanner + sanctioned file creation). MQ6: research basis = idea file + Phase 1 evidence; no external research.

---

## 6. Implementation Steps (estimated 60-90 min)
1. blake SKILL edit (§4.1 + §4.2) — then mirror to .agents, verify parity 0
2. harvest-scan.sh (§4.3) + smoke run against live registry
3. Dogfood (§4.4) — REQUIRES USER PRESENT for the in-session confirmations
4. Sync-safety analysis (FR6) → write to evidence dir
5. Run §9.1 ACs; Layer 2 review (code-reviewer + spec-compliance; use KNOWN_REVIEWERS names)
6. Completion report incl. AR-002 contract-change listing (old line → new line)

## 7. File Structure
Create: `.tad/hooks/lib/harvest-scan.sh`, `.tad/skill-library/colin--eval-page-generator.md`, `.tad/skill-library/colin--colab-drive-deploy.md`, `{Colin}/.claude/skills/smart-interval/SKILL.md`, `.tad/evidence/reviews/blake/sep-phase2/sync-safety-analysis.md`
Modify: `.claude/skills/blake/SKILL.md` + `.agents/skills/blake/SKILL.md` (mirror), `.tad/skill-library/_index.md`, Colin's 3 SCAND frontmatters, `.tad/hooks/lib/release-verify.sh` (FR7 — Only-in-target tolerance for .claude/skills), `.tad/templates/skillify-candidate-template.md` (FR8 — tier field)
Grounded against: blake SKILL L1839-1883 (read 2026-06-10), sync-registry.yaml (14 projects), Colin SCANDs (listed §2), parity diff 0 (verified 2026-06-10)

## 8. Testing Requirements

### 8.4 Friction Preflight
| Friction Point | Required Step | Expected Fix Path | Allowed Substitute | Gate Impact |
|----------------|---------------|-------------------|--------------------|-------------|
| User must be in-session for T1 confirmations | FR4 dogfood | User is driving this epic — schedule dogfood while present | NONE — unattended materialization forbidden | FR4 ACs blocked without user |
| Colin project path is outside TAD repo (~/Downloads) | FR4 write access | Path exists per sync-registry; plain file create | N/A | AC7 blocked if path moved |

### 8.5 Feedback Collection
```yaml
feedback_required: false
```

---

## 9.1 Spec Compliance Checklist — PRIMARY VERIFICATION SOURCE

| # | Acceptance Criterion | Verification Method | Expected |
|---|---------------------|--------------------|----------|
| AC1 | T1 ceremony in blake SKILL body | `grep -c "T1 materialization ceremony" .claude/skills/blake/SKILL.md` | 1 |
| AC2 | Carve-out retains constraint citation | `grep -c "MUST NOT create .claude/skills" .claude/skills/blake/SKILL.md` | 1 |
| AC3 | Unattended still forbidden | `grep -cE "UNATTENDED|unattended materialization" .claude/skills/blake/SKILL.md` | ≥2 |
| AC4 | harvest-scan exists + executable | `test -x .tad/hooks/lib/harvest-scan.sh && echo OK` | OK |
| AC5 | harvest-scan is read-only (word-bounded command tokens, not substrings) | `bash -c "grep -cE '(^\|[;&\|]\|[[:space:]])(mv\|cp\|rm\|rmdir\|mkdir\|tee\|sed -i)[[:space:]]' .tad/hooks/lib/harvest-scan.sh \|\| true"` | 0 |
| AC5b | no redirection writes into project paths | Blake manual inspection + statement in completion report: "no >, >> targeting registry project paths" | stated |
| AC6 | harvest-scan finds Colin candidates | `bash .tad/hooks/lib/harvest-scan.sh \| grep -c "Colin声音项目"` | ≥1 |
| AC7 | smart-interval materialized in Colin | `test -f "/Users/sheldonzhao/Downloads/Colin声音项目/.claude/skills/smart-interval/SKILL.md" && echo EXISTS` | EXISTS |
| AC8 | 2 T2 references in skill-library | `ls .tad/skill-library/colin--*.md \| wc -l \| tr -d ' '` | 2 |
| AC9 | _index updated (entry lines, anchored) | `grep -c "^- .*colin--" .tad/skill-library/_index.md` | 2 |
| AC10a | exactly the T1 SCAND has materialized_at | `grep -l "materialized_at:" "/Users/sheldonzhao/Downloads/Colin声音项目/.tad/active/skillify-candidates/"SCAND-*.md \| wc -l \| tr -d ' '` | 1 |
| AC10b | all 3 SCANDs carry tier | `grep -l "^tier: T" "/Users/sheldonzhao/Downloads/Colin声音项目/.tad/active/skillify-candidates/"SCAND-*.md \| wc -l \| tr -d ' '` | 3 |
| AC10c | both T2 SCANDs carry reference_at | `grep -l "reference_at:" "/Users/sheldonzhao/Downloads/Colin声音项目/.tad/active/skillify-candidates/"SCAND-*.md \| wc -l \| tr -d ' '` | 2 |
| AC11 | Parity restored | `diff -qr .claude/skills .agents/skills \| wc -l \| tr -d ' '` | 0 |
| AC12 | Sync-safety analysis exists | `test -f .tad/evidence/reviews/blake/sep-phase2/sync-safety-analysis.md && echo EXISTS` | EXISTS |
| AC13 | No settings/hooks registration | `git diff --name-only HEAD -- .claude/settings.json \| wc -l \| tr -d ' '` | 0 |
| AC14 | No Alex/Gate SKILL edits | `git diff --name-only HEAD -- .claude/skills/alex .claude/skills/gate \| wc -l \| tr -d ' '` | 0 |
| AC15 | release-verify tolerates local skills (FR7) | `grep -cE "Only in.*local-skill\|local-skill.*Only in" .tad/hooks/lib/release-verify.sh` | ≥1 |
| AC15b | FR7 behavior: target-extra ≠ fail | fixture: temp target with extra skill dir → structural run → exit 0 + INFO line (paste output in completion) | INFO, no fail |
| AC16 | template gains tier field (FR8) | `grep -c "^tier:" .tad/templates/skillify-candidate-template.md` | 1 |

---

## 9.2 Expert Review Status

**Review date**: 2026-06-10 | **Experts**: code-reviewer + config-manager (parallel) | **Initial verdict**: both NOT READY

| ID | Severity | Finding | Resolution |
|----|----------|---------|------------|
| CR-P0-1 | P0 | AC5 `rm \|cp ` substrings false-positive on perform/transform/confirm — fails correct read-only scripts | AC5 rewritten with word-bounded command-position pattern; AC5b adds redirection inspection |
| CM-P0 | P0 | release-verify.sh L163 flat diff counts target-extra skills as fails → Colin local skill would HARD BLOCK future syncs (gate currently warn-mode) | FR7 added: structural mode treats `Only in {target}` under .claude/skills as INFO not fail; MUST land before Colin write (§4.4 step 0); AC15/AC15b verify incl. fixture run |
| CM-P1-A | P1 | Carve-out left rationalization vector: "handoff pre-approved → skip AskUserQuestion" | NEW forbidden text adds explicit "MUST NOT treat handoff pre-approval as satisfying AskUserQuestion"; §4.4 step 2 reworded |
| CM-P1-B | P1 | template lacks tier field — future discoverers produce tier-less SCANDs, breaking harvest tier column | FR8 + AC16: template gains `tier: ~` (ceremony-set only) |
| CR-P1-2/CM-P2 | P1 | T2 frontmatter contract undefined; AC10=3 wrong for T1/T2 split | FR4b contract defined (T1 materialized_at / T2 reference_at); AC10 split into 10a=1/10b=3/10c=2 |
| CR-P1-1 | P1 | AC5 deny-set missed rmdir/tee/sed -i/redirections | Pattern widened + AC5b |
| CR-P2 | P2 | AC9 unanchored; SCAND frontmatter date-key inconsistency | AC9 anchored `^- .*colin--`; §4.4 step 1 notes filename-date + missing-field tolerance |

**Premise checks (both experts)**: §4.2 OLD line byte-exact at blake SKILL L1879 ✅; Colin SCAND inventory accurate ✅; smart-interval content sufficient for ≤150-line skill ✅; parity currently 0 ✅; AC1/AC2/AC3 post-impl counts verified non-colliding ✅.

**P0 outstanding**: 0 | **Final**: READY

---

## 10. Important Notes
- **AR-002 obligation**: the forbidden-line edit is a contract change — completion report must show old → new verbatim
- **Colin writes are the ONLY sanctioned cross-project mutations** in this handoff; harvest-scan must stay read-only everywhere
- **T3 explicitly deferred**: colab-drive-deploy → ml-training pack promotion requires a 2nd project hitting the same pattern (harvest collision report is the detector)
- Sub-agents: code-reviewer (required), spec-compliance-reviewer; config-manager optional for FR6

## 11. Decision Rationale
| Decision | Alternatives | Why |
|----------|--------------|-----|
| Amend forbidden line w/ carve-out | delete it / new parallel rule | DR-20260531 precedent: narrow sanctioned path + citation retained; grep anchors survive |
| Dogfood routes all 3 Colin SCANDs | synthetic fixture only | Real candidates, real taxonomy exercise, real artifact ACs — epic success criterion demands it |
| eval-page-generator → T2 not T1 | materialize in Colin | Its value already shipped as Feedback Collector; reference preserves origin without duplicate skill |
| harvest derives from sync-registry | hardcode 14 paths | Deny-list lesson: hardcoded lists go stale |

---

**Handoff Created By**: Alex (Agent A)
**Date**: 2026-06-10
**Version**: 3.1.0
