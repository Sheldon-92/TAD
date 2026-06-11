---
task_type: mixed
e2e_required: no
research_required: no
git_tracked_dirs: [".tad/hooks", ".tad/templates"]
skip_knowledge_assessment: no
gate4_delta: []
---

# Handoff Document for Agent B (Blake)
## TAD v3.1 - Evidence-Based Development

**From:** Alex (Agent A - Solution Lead)
**To:** Blake (Agent B - Execution Master)
**Date:** 2026-06-10
**Project:** TAD Framework
**Task ID:** TASK-20260610-003
**Handoff Version:** 3.1.0
**Epic:** EPIC-20260610-self-evolution-pruning.md (Phase 1/3)

---

## Gate 2: Design Completeness

**Execution**: 2026-06-10

| Check | Status | Notes |
|-------|--------|-------|
| Architecture Complete | ✅ | Retirement scope + T2 shelf + dual deny-list, grounded against live files |
| Components Specified | ✅ | 2 deletions, 3 modifications, 2 creations, 2 archival move-sets |
| Functions Verified | ✅ | --verify-denylist / --zero-touch / --dirs flags verified live; trace-digest consumer located |
| Data Flow Mapped | ✅ | Sync exclusion path (the load-bearing direction) asserted by AC11 |
| Expert Review (min 2) | ✅ | code-reviewer + config-manager; 2 P0 + 5 P1 found, ALL integrated (§9.2) |
| P0 Issues Resolved | ✅ | 0 outstanding |

**Gate 2 Result**: ✅ PASS

---

## Handoff Checklist (Blake must read)

- [ ] Read all sections, especially §10.1 collision constraints
- [ ] Read "Project Knowledge" section
- [ ] Can independently complete implementation using this document

---

## 1. Task Overview

### 1.1 What We're Building
Phase 1 of retiring TAD's near-zero-yield self-evolution loops: delete the dream mining scripts, archive the negative-result artifacts (8 PROPOSALs, 6+4 dream candidates, dream-state), create the T2 reference shelf `.tad/skill-library/` with dual deny-list registration, and harden the SCAND template against discoverer self-acceptance.

### 1.2 Why
Measured yield (2026-06-10): dream 10 candidates → 1 accepted; optimize/evolve 8 PROPOSALs → 0 accepted; skillify auto-detection → 0 in master. Human decision: full retirement (incl. manual *dream). This phase does everything that is file-disjoint from the in-flight Feedback Collector epic.

### 1.3 Intent Statement

**The real problem**: The automated loops mine traces (mechanical events) for value signals that only exist in human experience, generating plausible noise and taxing the human as a filter.

**This is NOT**:
- SKILL.md surgery (Phase 3 — alex/gate SKILL are in-flight elsewhere)
- The T1 materialization flow (Phase 2 — blake SKILL)
- Trace emission removal (trace-step/writer/rotate are KEPT as forensics)
- Hook registration of any kind (explicitly forbidden for skillify enforcement)

---

## Project Knowledge (Blake must read)

| File | Relevant entries | Key reminder |
|------|-----------------|--------------|
| principles.md | "Deny-List Beats Allow-List…" + "Deny-List Must Be Applied at EVERY Copy Granularity" (both ⚠️ SAFETY) | Deny-list edits MUST land in BOTH derive-sync-set.sh AND tad.sh inlined copy; the EXCLUSION assertion is the load-bearing AC |
| principles.md | "Mechanical Enforcement Rejected on Single-User CLI" (⚠️ SAFETY) | SCAND hardening is template-text only — NO hooks |
| patterns/shell-portability.md | macOS/BSD | `mv` cross-dir on same volume; no GNU-only flags |

**Blake must note:**
1. **Dual deny-list edit**: tad.sh L164-196 contains an INLINED copy of the deny lists (cannot source the lib at install time). Edit BOTH or `--verify-denylist` fails at release.
2. **Do NOT touch** `.claude/skills/`, `.agents/skills/`, `.claude/settings.json` — collision + scope guard (AC13).

---

## 2. Background Context

### 2.1 Current State (grounded 2026-06-10, corrected per expert review)
- `dream-scanner.sh`, `dream-validator.sh` exist in `.tad/hooks/lib/`; NOT registered in settings.json; only consumer is `alex/references/dream-protocol.md` (retired path, dies in Phase 3)
- `trace-digest.sh` is live-wired into *accept step4d via **`.claude/skills/alex/references/acceptance-protocol.md` L110-156 (+ .agents mirror)** — i.e. its consumer is the installed alex SKILL, which AC13 forbids touching — **must survive Phase 1**
- `.tad/active/dream-candidates/`: 6 CAND files (all status: rejected); separately `.tad/active/dream-state.yaml` (total_accepted: 0, total_rejected: 6)
- `.tad/archive/dream-candidates/`: 4 files already there
- `.tad/evidence/proposals/`: 8 PROPOSAL-*.yaml at top level **PLUS `framework/` subdir containing 3 more PROPOSALs** (11 PROPOSAL files total)
- `.tad/templates/skillify-candidate-template.md` L3 frontmatter: `status: pending  # pending | accepted | rejected`
- `derive-sync-set.sh --zero-touch` currently: active archive decisions evidence github-registry pair-testing project-knowledge research-notebooks skillify-candidates

---

## 3. Requirements

### 3.1 Functional
- FR1: dream mining scripts deleted; trace emission untouched
- FR2: Negative-result artifacts archived with a NEGATIVE-RESULT.md summary (preserve the data that justified retirement)
- FR3: `.tad/skill-library/` exists (README.md explaining T2 tier + _index.md), zero-touch in BOTH deny-list copies
- FR4: SCAND template defaults `status: draft` with explicit "discoverer MUST NOT set accepted" constraint

### 3.2 Non-Functional
- NFR1: Zero changes under `.claude/` and `.agents/` (verifiable via git status)
- NFR2: No new hook registrations
- NFR3: All moves preserve file content (count + spot-check)

---

## 4. Technical Design

### 4.1 Deletions
```
rm .tad/hooks/lib/dream-scanner.sh
rm .tad/hooks/lib/dream-validator.sh
```
Interim behavior: *dream invoked between Phase 1 and Phase 3 fails fast on missing script — intended (command is retired by human decision; fail-fast beats silent half-function).

### 4.2 Archival
```
mkdir -p .tad/archive/proposals
# Move proposals INCLUDING the framework/ subdir, preserved as-is (do NOT flatten):
mv .tad/evidence/proposals/PROPOSAL-*.yaml .tad/archive/proposals/
mv .tad/evidence/proposals/framework .tad/archive/proposals/framework
rm -rf .tad/evidence/proposals          # source dir itself must be GONE (AC8)
mv .tad/active/dream-candidates/CAND-*.md .tad/archive/dream-candidates/
mv .tad/active/dream-state.yaml .tad/archive/dream-candidates/dream-state.final.yaml
rmdir .tad/active/dream-candidates
```
For git-tracked files use `git mv` equivalents; for untracked, plain `mv`. After moves, `git status` will show the tracked relocations — expected, committed at the end.
Write `.tad/archive/proposals/NEGATIVE-RESULT.md`: 5-10 lines stating the measured yield (numbers from §1.2), date, and pointer to IDEA-20260610-self-evolution-pruning-skillify-last-mile.md. This is evidence FOR the retirement decision — do not editorialize beyond the numbers.

### 4.3 T2 Shelf
```
.tad/skill-library/
├── README.md    # T2 tier definition: harvested references from downstream projects;
│                # NEVER distributed (zero-touch deny-listed); promotion to packs requires
│                # ≥2-project evidence (Domain Pack decision rule)
└── _index.md    # Format: - [name](project--slug.md) — source project, date, one-line hook
```

### 4.4 Dual deny-list registration — DO THIS BEFORE §4.3 mkdir (no window where the new dir is in the sync set)
- `derive-sync-set.sh`: append `skill-library` to the ZERO_TOUCH block (source order irrelevant — output is sort-piped at emit)
- `tad.sh`: append `skill-library` to the inlined `TAD_ZERO_TOUCH` (L~193 region) — BOTH files or `--verify-denylist` fails
- Verify FROM REPO ROOT: `bash tad.sh --verify-denylist` exits 0; `derive-sync-set.sh --dirs` does NOT contain skill-library; `--zero-touch` DOES

### 4.5 Template hardening
`.tad/templates/skillify-candidate-template.md` L3: change `status: pending  # pending | accepted | rejected` → `status: draft  # draft | accepted | rejected` (pending retired together with the old flow), plus comment line:
`# CONSTRAINT: discoverer MUST NOT set status beyond draft. accepted is set ONLY during the in-session human confirmation (T1 ceremony, Phase 2) — see triple_question_draft_rule.`
Known interim effect (accepted): new SCANDs created as `draft` are invisible to alex STEP 3.57's `status: pending` grep — that step is retired in Phase 3 and replaced by the T1 flow in Phase 2.

---

## 5. Mandatory Questions
### MQ1-MQ5: Not applicable (file ops + template text; no data flow, no UI)
### MQ6: Research — covered by the measurement session (2026-06-10, idea file); no external research needed.

---

## 6. Implementation Steps (estimated 30-40 min)

0. Baseline snapshot: `git status --porcelain .claude .agents > /tmp/sep1-baseline.txt` (for AC13 delta comparison)
1. Deletions per §4.1
2. Archival per §4.2 + NEGATIVE-RESULT.md
3. Dual deny-list edit per §4.4 + run verifier (BEFORE creating the dir)
4. Create skill-library per §4.3
5. Template hardening per §4.5
6. Run all §9.1 verification commands; paste outputs
7. Layer 2: code-reviewer on the diff (scope: deny-list dual-edit correctness, archival completeness)

---

## 7. File Structure

### 7.1 Create
```
.tad/skill-library/README.md
.tad/skill-library/_index.md
.tad/archive/proposals/  (+ NEGATIVE-RESULT.md)
```
### 7.2 Modify
```
.tad/hooks/lib/derive-sync-set.sh   # ZERO_TOUCH += skill-library
tad.sh                              # inlined TAD_ZERO_TOUCH += skill-library
.tad/templates/skillify-candidate-template.md
```
### 7.3 Delete / Move
```
.tad/hooks/lib/dream-scanner.sh, dream-validator.sh   (DELETE)
.tad/evidence/proposals/* → .tad/archive/proposals/
.tad/active/dream-candidates/* + dream-state.yaml → .tad/archive/dream-candidates/
```
### 7.4 Grounded Against
- `.tad/hooks/lib/derive-sync-set.sh` (--zero-touch output verified 2026-06-10)
- `tad.sh` L164-222 (inlined deny-list + drift-check comments, read 2026-06-10)
- settings.json hook registrations enumerated 2026-06-10 (no dream/digest entries)
- `.claude/skills/alex/references/acceptance-protocol.md` L110-156 (trace-digest live wiring — the reason it's NOT in scope)
- `.tad/evidence/proposals/` inventory incl. framework/ subdir (11 PROPOSALs total, verified by expert review 2026-06-10)
- `.tad/templates/skillify-candidate-template.md` L3 (`status: pending` enum, verified by expert review)

---

## 8. Testing Requirements

### 8.3 Edge Cases
- `.tad/archive/dream-candidates/` name collision with existing 4 files → filenames are timestamped, collision impossible; verify count = 4+6+1(state) = 11 after move
- git-tracked vs untracked moves: use `git mv` where tracked, plain `mv` otherwise; AC counts are filesystem-based either way

### 8.4 Friction Preflight

| Friction Point | Required Step | Expected Fix Path | Allowed Substitute | Gate Impact |
|----------------|---------------|-------------------|--------------------|-------------|
| None expected — bash + git only, all local | — | — | — | — |

### 8.5 Feedback Collection (Non-Code Artifacts)
```yaml
feedback_required: false
```
(Config/scripts change; no non-code artifact.)

---

## 9.1 Spec Compliance Checklist — PRIMARY VERIFICATION SOURCE

| # | Acceptance Criterion | Verification Method | Expected |
|---|---------------------|--------------------|----------|
| AC1 | dream-scanner deleted | `test -f .tad/hooks/lib/dream-scanner.sh \|\| echo GONE` | GONE |
| AC2 | dream-validator deleted | `test -f .tad/hooks/lib/dream-validator.sh \|\| echo GONE` | GONE |
| AC3 | trace-digest SURVIVES (guard) | `test -f .tad/hooks/lib/trace-digest.sh && echo ALIVE` | ALIVE |
| AC4 | trace emission intact | `ls .tad/hooks/trace-step.sh .tad/hooks/lib/trace-writer.sh .tad/hooks/lib/trace-rotate.sh \| wc -l` | 3 |
| AC5 | dream candidates archived | `find .tad/archive/dream-candidates -maxdepth 1 -type f \| wc -l \| tr -d ' '` | 11 |
| AC6 | active dream dir gone | `[ ! -e .tad/active/dream-candidates ] && [ ! -e .tad/active/dream-state.yaml ] && echo CLEAN` | CLEAN |
| AC7 | ALL 11 PROPOSALs archived (incl. framework/ nested) | `find .tad/archive/proposals -name 'PROPOSAL-*.yaml' \| wc -l \| tr -d ' '` | 11 |
| AC7b | NEGATIVE-RESULT.md exists | `test -f .tad/archive/proposals/NEGATIVE-RESULT.md && echo EXISTS` | EXISTS |
| AC8 | evidence/proposals gone (dir itself) | `test -e .tad/evidence/proposals \|\| echo CLEAN` | CLEAN |
| AC9 | skill-library created | `ls .tad/skill-library/README.md .tad/skill-library/_index.md \| wc -l \| tr -d ' '` | 2 |
| AC10 | lib deny-list updated | `bash .tad/hooks/lib/derive-sync-set.sh --zero-touch \| grep -cx skill-library` | 1 |
| AC11 | skill-library NOT in sync set (load-bearing EXCLUSION; `\|\| true` guards BSD grep exit-1 on count 0) | `bash .tad/hooks/lib/derive-sync-set.sh --dirs \| { grep -cx skill-library \|\| true; }` | 0 |
| AC12 | dual-copy drift check (run FROM REPO ROOT) | `bash tad.sh --verify-denylist; echo $?` | 0 |
| AC13 | no SKILL/settings touches (delta vs step-0 baseline) | `git status --porcelain .claude .agents \| diff - /tmp/sep1-baseline.txt && echo NODELTA` | NODELTA |
| AC14 | template default is draft + constraint present | `grep -c "status: draft" .tad/templates/skillify-candidate-template.md; grep -c "MUST NOT set status" .tad/templates/skillify-candidate-template.md` | ≥1 each |
| AC15 | old pending default removed | `bash -c 'grep -c "status: pending" .tad/templates/skillify-candidate-template.md \|\| true'` | 0 |

---

## 9.2 Expert Review Status

**Review date**: 2026-06-10 | **Experts**: code-reviewer + config-manager (parallel) | **Initial verdict**: both NOT READY

| ID | Severity | Finding | Resolution |
|----|----------|---------|------------|
| CR-P0-1 | P0 | proposals contains framework/ subdir (3 nested PROPOSALs); AC7 count wrong-by-construction; `mv *` leaves source dir → AC8 unfixable | §4.2 rewritten: explicit framework/ move + `rm -rf` source; AC7 → find-based count = 11; AC7b added |
| CM-P0 | P0 | AC11 `grep -cx` exits 1 on count=0 under BSD grep → breaks automated runners | AC11 wrapped `{ grep -cx … \|\| true; }` |
| CR-P1-1 | P1 | Grounding cited non-existent `.tad/.../acceptance-protocol.md` | §2.1/§7.4/§10.1 corrected to `.claude/skills/alex/references/acceptance-protocol.md` |
| CR-P1-2 | P1 | AC13 measured whole working tree, not Blake's delta | Step 0 baseline snapshot + AC13 diff-vs-baseline |
| CR-P1-4/5 | P1 | Template enum excludes draft; pending default could survive | §4.5 rewrites enum `draft \| accepted \| rejected`; AC15 added (pending count = 0) |
| CM-P1-1/2 | P1 | Stale runtime refs (alex STEP 3.56, surplus SKILL) unmentioned | §10.1b documents graceful degradation + Phase 3 fix |
| CM-P1-3 | P1 | §6 created dir before deny-listing it (exposure window) | Step order swapped; §4.4 header warns |
| P2s | P2 | "alphabetical" wording, `ls`-count fragility, POSIX test form | All applied (§4.4 wording, find/tr counts, AC6 `[ ! -e ]` form) |

**P0 outstanding**: 0 | **Final**: READY

---

## 10. Important Notes

### 10.1 Critical Warnings
- **trace-digest.sh is OFF-LIMITS** — consumer is the installed alex SKILL (`.claude/skills/alex/references/acceptance-protocol.md` L110-156, in-flight in the Feedback Collector epic); deletion is Phase 3
- **No .claude/ or .agents/ edits of any kind** — AC13 is a hard scope guard against collision with the in-flight epic
- **Deny-list edits are SAFETY-adjacent** — the EXCLUSION assertion (AC11) is the load-bearing check, not the inclusion

### 10.1b Known stale references created by this phase (ACCEPTED, fixed in Phase 3 — do NOT fix now)
- alex/SKILL.md STEP 3.56 reads `.tad/active/dream-candidates/` + `dream-state.yaml` → after archival the trigger silently evaluates to 0 candidates and skips (graceful; verified). Phase 3 removes the step.
- surplus/SKILL.md L61-62 backlog scan reads `.tad/evidence/proposals/` → silently returns 0 from that source after the move (read-only; graceful). Phase 3 updates the source list.
- alex/references/dream-protocol.md references the deleted scripts → *dream fails fast if invoked in the interim (intended; command is retired). Phase 3 deletes the protocol.

### 10.2 Sub-Agent Usage
- [ ] **code-reviewer** — after implementation, scope: dual deny-list consistency, archival completeness, template constraint wording

---

## 11. Decision Rationale

| Decision | Alternatives | Why |
|----------|--------------|-----|
| Full *dream retirement (incl. manual) | keep manual-only | Human decision 2026-06-10; 1/10 lifetime yield doesn't justify the maintained surface |
| trace-digest deferred to Phase 3 | delete now | Live-wired in *accept step4d via an IN-FLIGHT file; deleting breaks current acceptance flow |
| Template-text enforcement (no hook) | pre-gate lint hook | blake SKILL forbidden_implementations explicitly bans skillify hooks; 2026-04-15 principle |
| Interim *dream fail-fast accepted | tombstone scripts | Command is retired by decision; fail-fast on a retired path beats maintaining a stub |

---

**Handoff Created By**: Alex (Agent A)
**Date**: 2026-06-10
**Version**: 3.1.0
