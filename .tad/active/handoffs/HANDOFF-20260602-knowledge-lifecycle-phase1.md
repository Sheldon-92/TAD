---
task_type: code
e2e_required: no
research_required: no
git_tracked_dirs: [".claude/skills/alex", ".tad/project-knowledge"]
skip_knowledge_assessment: no
gate4_delta: []
---

# Handoff Document for Agent B (Blake)
## TAD v3.1 - Evidence-Based Development

**From:** Alex (Agent A - Solution Lead)
**To:** Blake (Agent B - Execution Master)
**Date:** 2026-06-02
**Project:** TAD Framework
**Task ID:** TASK-20260602-003
**Handoff Version:** 3.1.0
**Epic:** EPIC-20260602-knowledge-layering.md (Phase 1/3)
**Supersedes:** N/A

---

## 🔴 Gate 2: Design Completeness (Alex必填)

**执行时间**: 2026-06-02

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Architecture Complete | ✅ | Sense engine in STEP 3.5 + three-layer schema + classification spreadsheet |
| Components Specified | ✅ | 3 files to modify, 5 to create, all paths confirmed |
| Functions Verified | ✅ | grep entry counts verified: 116 entries across 4 files |
| Data Flow Mapped | ✅ | Alex session start → STEP 3.5 Sense → health report → AskUserQuestion → action or skip |

**Gate 2 结果**: ✅ PASS

---

## 1. Task Overview

**Title:** Knowledge Lifecycle System — Phase 1: Sense Engine + Three-Layer Schema

**Summary:** Add knowledge health sensing to Alex's session startup (STEP 3.5) and define the three-layer directory schema (principles / patterns / incidents) that all subsequent phases build on. Also produce a classification spreadsheet mapping all 116 existing entries to their target layer for human review.

**Business Value:** After this lands, Alex 在任何 TAD 项目启动时能自动检测知识系统是否需要整理 — 不再等人类记得跑 `*dream`。这是 TAD 第四子系统（Knowledge Lifecycle）的感知层，和 Gate 系统、Ralph Loop、Trace+Optimize 平级。

**Epic Context:** This is Phase 1 of a 3-phase Epic building TAD's Knowledge Lifecycle System. P1 builds Sense + Schema. P2 will build Organize + migrate TAD's own entries. P3 will build Maintain (Gate 4 auto-classify + *dream graduation).

---

## 2. Requirements

### Functional Requirements

**FR1: STEP 3.5 Knowledge Health Sensing**
Alex's activation STEP 3.5 (document health check) gains a new sub-section that runs AFTER the existing zombie handoff detection. It scans `.tad/project-knowledge/` and reports:
- Total entry count across all knowledge files (`grep -c '^### '`)
- Whether the three-layer structure exists (has `patterns/` directory?)
- Stale entries count (existing stale-knowledge-check.sh integration, advisory)
- Health verdict: OK / NEEDS_ORGANIZE / NEEDS_CLEANUP

When verdict is NEEDS_ORGANIZE (flat structure detected OR >50 entries in a single file), Alex uses AskUserQuestion to propose action.

**FR2: Three-Layer Directory Schema**
Create the target directory structure with empty templates:
```
.tad/project-knowledge/
├── principles.md              # Layer 1: ≤15 permanent methodology rules
├── patterns/                  # Layer 2: themed reusable patterns
│   └── _index.md              # title + 1-line summary per pattern file
├── incidents/                 # Layer 3: dated one-time evidence
│   └── _index.md              # title + date + linked pattern
└── README.md                  # Classification rules + lifecycle docs
```

**FR3: README Lifecycle Documentation**
The updated README.md documents the complete Knowledge Lifecycle System:
- Three-layer model (definitions + examples for each layer)
- Classification criteria (prediction-error heuristic: "would a senior TAD user already know this?")
- 5 lifecycle rules: classify at write / graduate at ≥2 incidents / expire at 90 days / protect L1 via Epic / load per-layer
- Loading strategy per layer (L1 always, L2 index-match, L3 blame-on-demand)
- Graduation threshold: ≥2 incidents with shared pattern → L2 candidate

**FR4: Classification Spreadsheet**
A complete inventory of ALL 116 entries across architecture.md (93), code-quality.md (15), security.md (7), frontend-design.md (1), each classified as:
- **L1 (Principle)**: Permanent methodology rule, transcends any single codebase
- **L2 (Pattern)**: Reusable pattern learned from experience, may become stale
- **L3 (Incident)**: One-time evidence supporting an L1/L2 entry
- **DISCARD**: Outdated, superseded, or duplicate (cite what supersedes it)

### Non-Functional Requirements

**NFR1: Sense is Non-Blocking**
Knowledge health check never blocks Alex activation. If scanning fails or takes >2 seconds, skip silently.

**NFR2: Schema is Forward-Compatible**
Empty directories and templates must not break any existing TAD workflow. `*dream`, `stale-knowledge-check.sh`, `knowledge-blame.sh` must continue to work with the old flat structure alongside the new directories.

---

## 3. Technical Design

### Sense Engine Architecture

```
Alex STEP 3.5 (existing: document health + zombie detection)
  ↓ (AFTER zombie detection, new sub-section)
Knowledge Health Scan:
  1. Count entries: grep -c '^### ' .tad/project-knowledge/*.md (exclude README)
  2. Check structure: test -d .tad/project-knowledge/patterns
  3. Check concentration: any single file >50 entries?
  4. Compute verdict:
     - has patterns/ AND no file >50 entries → OK
     - no patterns/ dir → NEEDS_ORGANIZE ("flat structure, suggest *knowledge-organize")
     - any file >50 entries → NEEDS_CLEANUP ("knowledge file bloated, suggest *dream")
  5. Output:
     - OK → "📚 Knowledge: {total} entries, layered structure ✅"
     - NEEDS_ORGANIZE → "📚 Knowledge: {total} entries in flat structure. 建议运行 *knowledge-organize 分层整理。"
       + AskUserQuestion: "要现在整理吗？" → "整理" / "稍后"
     - NEEDS_CLEANUP → "📚 Knowledge: {file} has {N} entries (>50). 建议运行 *dream 整合。"
```

### Classification Criteria (Prediction-Error Heuristic)

For each entry, apply this decision tree:
```
Q1: Does this rule transcend any specific codebase?
    (Would it apply to a TAD project in ANY language/domain?)
  → YES → L1 PRINCIPLE (e.g., "Express handoff MUST NOT skip expert review")
  → NO → Q2

Q2: Is this a reusable pattern that could recur in future work?
    (Not tied to a single handoff, but to a class of problems?)
  → YES → L2 PATTERN (e.g., "Deny-list beats allow-list for sync sets")
  → NO → Q3

Q3: Is this evidence of a specific event that supports an L1/L2 entry?
  → YES → L3 INCIDENT (e.g., "2026-05-30 dream-scanner Pass C lost value fields")
  → NO → DISCARD (cite what supersedes or why it's no longer relevant)
```

### L2 Pattern Theme Groups (preliminary — human may adjust)

Based on scanning the 116 entries, likely theme groups:
- `shell-portability.md` — BSD grep, sed, awk, LC_ALL=C, path handling
- `ac-verification.md` — grep -c bugs, dry-run rules, §9.1 patterns
- `gate-design.md` — gate responsibility, honest_partial, verification integrity
- `pack-architecture.md` — capability pack build rules, anti-slop, collision detection
- `handoff-design.md` — AC conflict matrix, scope estimation, express rules
- `hook-contracts.md` — hook output contracts, .router.log, shell portability in hooks
- `research-methodology.md` — NotebookLM patterns, source quality, dynamic protocols
- `memory-and-learning.md` — trace emission, dream scanner, knowledge lifecycle

---

## 4. Decision Summary

| # | Decision | Options | Chosen | Rationale |
|---|----------|---------|--------|-----------|
| 1 | Sense trigger threshold | >30 / >50 / >100 entries | >50 per file | 50 balances sensitivity vs noise. architecture.md at 93 would trigger; code-quality at 15 would not |
| 2 | Verdict categories | 2 (OK/bad) / 3 (OK/organize/cleanup) | 3 categories | Distinguish "needs layering" from "needs consolidation" — different actions |
| 3 | STEP 3.5 placement | Before zombie / after zombie / separate step | After zombie detection | Zombie is fast (file scan); knowledge scan is slower (grep counts). Keep zombie first. |

---

## 5. Architecture & Data Flow

See §3 for Sense Engine flow. Data flow: Alex activates → STEP 3.5 runs zombie check (existing) → knowledge health scan (new) → verdict + optional AskUserQuestion → continue to STEP 3.6.

---

## 6. Files to Modify / Create

| # | File | Action | Description |
|---|------|--------|-------------|
| 1 | `.claude/skills/alex/SKILL.md` | MODIFY | Add knowledge health scan sub-section to STEP 3.5 |
| 2 | `.tad/project-knowledge/principles.md` | CREATE | Empty template with L1 section headers |
| 3 | `.tad/project-knowledge/patterns/_index.md` | CREATE | Template for pattern index |
| 4 | `.tad/project-knowledge/incidents/_index.md` | CREATE | Template for incident index |
| 5 | `.tad/project-knowledge/README.md` | MODIFY | Add 3-layer model + classification criteria + 5 lifecycle rules + loading strategy |
| 6 | `.tad/evidence/knowledge-migration/classification-spreadsheet.md` | CREATE | 116 entries classified into L1/L2/L3/DISCARD |

**Grounded Against** (Alex step1c read):
- `.claude/skills/alex/SKILL.md` lines 75-93 (STEP 3.5 current health check logic)
- `.tad/project-knowledge/README.md` head 50 (current structure)
- `.tad/project-knowledge/architecture.md` (93 entries, grep verified)
- `.tad/project-knowledge/code-quality.md` (15 entries, grep verified)

---

## 7. Implementation Steps

### Task 1: Create directory structure

```bash
mkdir -p .tad/project-knowledge/patterns
mkdir -p .tad/project-knowledge/incidents
```

### Task 2: Create `principles.md` template

Empty L1 template — NO entries yet (P2 populates). Just the section headers:
```markdown
# TAD Methodology Principles (Layer 1)

> Permanent rules that define how TAD works. Transcend any specific codebase.
> Modification requires an Epic-level TAD flow — these are the "-ology."
> Entry count cap: ≤15 (if more needed, some entries are likely L2 patterns, not L1 principles).

---

## Principles

(Populated in Phase 2 after human classification review)
```

### Task 3: Create `patterns/_index.md` template

```markdown
# Knowledge Patterns Index (Layer 2)

> One-line summary per pattern file. Blake's 1_5_context_refresh matches task keywords
> against this index, then loads only the matched pattern files.
> Format: `- [title](filename.md) — one-line hook (max 120 chars)`

---

(Populated in Phase 2 after human classification review)
```

### Task 4: Create `incidents/_index.md` template

```markdown
# Knowledge Incidents Index (Layer 3)

> One-time evidence entries supporting L1 principles or L2 patterns.
> Never pre-loaded into agent context. Queried on-demand via knowledge-blame.sh.
> Auto-archived after 90 days when linked L2 pattern is stable.
> Format: `- [title](YYYY-MM/filename.md) — date, linked pattern/principle`

---

(Populated in Phase 2 after human classification review)
```

### Task 5: Update README.md

Add the following sections to `.tad/project-knowledge/README.md` (append, don't replace existing content):

```markdown
## Knowledge Lifecycle System (TAD v2.23+)

### Three-Layer Model

| Layer | Name | What It Contains | Loading Strategy | Lifecycle |
|-------|------|-----------------|-----------------|-----------|
| L1 | Principles | Permanent methodology rules (≤15). Transcend any codebase. | Always loaded via CLAUDE.md @import | Only modified via Epic-level TAD flow |
| L2 | Patterns | Reusable patterns learned from experience. May become stale. | On-demand: _index.md matched at session start, full file loaded when matched | Graduated from L3 when ≥2 incidents share a pattern. Stale-checked. |
| L3 | Incidents | One-time evidence. Supports L1/L2 entries. | Never pre-loaded. Queried via knowledge-blame.sh | Auto-archived after 90 days when linked L2 pattern is stable |

### Classification Criteria (Prediction-Error Heuristic)

When writing a new knowledge entry (Gate 4 KA), apply this decision tree:

1. **Does this rule transcend any specific codebase?** → YES → L1 Principle
2. **Is this a reusable pattern for a class of problems?** → YES → L2 Pattern
3. **Is this evidence of a specific event?** → YES → L3 Incident
4. **None of the above** → DISCARD or rephrase

Shortcut: "Would a senior TAD user already know this?" → YES = L3 or discard. NO = L2. "Does this fundamentally change how TAD works?" → YES = L1 candidate.

### 5 Lifecycle Rules

1. **Classify at write**: Gate 4 KA auto-classifies new entries (L1-candidate/L2/L3)
2. **Graduate at threshold**: *dream detects ≥2 L3 incidents with shared pattern → proposes L2 graduation
3. **Expire at 90 days**: L3 incidents >90 days + linked L2 stable (no new incident in 60 days) → auto-archive
4. **Protect L1**: principles.md modification requires Epic-level TAD flow (not just a handoff)
5. **Load per layer**: L1 always, L2 index-match, L3 blame-on-demand

### File Structure

    .tad/project-knowledge/
    ├── principles.md              # L1: always loaded (~3KB)
    ├── patterns/                  # L2: loaded on-demand
    │   ├── _index.md              # title + summary per file
    │   ├── shell-portability.md
    │   ├── gate-design.md
    │   └── ...
    ├── incidents/                  # L3: never pre-loaded
    │   ├── _index.md              # title + date + linked pattern
    │   └── 2026-MM/
    │       └── specific-event.md
    ├── architecture.md            # Legacy (migrated entries have pointers)
    ├── code-quality.md            # Legacy
    ├── security.md                # Legacy
    └── README.md                  # This file
```

### Task 6: Modify STEP 3.5 in Alex SKILL.md

Insert a new sub-section AFTER the zombie detection block (after line ~90 `This is READ-ONLY - do not modify any files.`) and BEFORE `suppress_if`:

```yaml
      # --- Knowledge Health Scan (Knowledge Lifecycle System Phase 1) ---
      11. Scan knowledge health:
          a. Count total entries: total=$(grep -rc '^### ' .tad/project-knowledge/*.md 2>/dev/null | grep -v README | awk -F: '{s+=$2}END{print s}')
          b. Check layered structure: has_layers=$(test -d .tad/project-knowledge/patterns && echo 1 || echo 0)
          c. Find max file: max_file=$(grep -rc '^### ' .tad/project-knowledge/*.md 2>/dev/null | grep -v README | sort -t: -k2 -rn | head -1)
             max_count=$(echo "$max_file" | cut -d: -f2)
             max_name=$(echo "$max_file" | cut -d: -f1 | xargs basename)
          d. Compute verdict:
             if has_layers == 1 AND max_count <= 50 → verdict=OK
             if has_layers == 0 → verdict=NEEDS_ORGANIZE
             if max_count > 50 → verdict=NEEDS_CLEANUP
      12. Output based on verdict:
          - OK → append to health summary: "📚 Knowledge: {total} entries, layered ✅"
          - NEEDS_ORGANIZE → "📚 Knowledge: {total} entries in flat structure — *knowledge-organize 可用后将自动提示分层整理 (Knowledge Lifecycle Epic Phase 2)"
            ⚠️ ARCH P0-3 + CR P1-1 fix: NO AskUserQuestion here — Phase 2 not built yet.
            Log-and-continue is more honest than a false choice. Continue to STEP 3.6.
          - NEEDS_CLEANUP → "📚 Knowledge: {max_name} has {max_count} entries (>50) — 建议运行 *dream 整合"
      13. This is READ-ONLY — do not modify any knowledge files.
```

Update the `suppress_if` line to include knowledge health:
```yaml
    suppress_if: "No issues found AND zombie_count == 0 AND knowledge_verdict == OK - show one-line: 'TAD Health: OK'"
```

Add `interacts_with` block (CR P0-2 — transition arrow audit):
```yaml
    interacts_with: |
      Knowledge health scan runs AFTER zombie detection (items 4-10) and BEFORE suppress_if evaluation.
      The knowledge scan's log output does NOT suppress STEP 3.55 (zombie cleanup) or STEP 3.56 (dream candidates).
      All three sub-scans (zombie + knowledge + pair test) are independent — each produces its own output line.
      knowledge_verdict is a JUDGMENT variable in Alex's conversation context (not a mechanical YAML key).
      After knowledge scan completes, execution continues to STEP 3.6 regardless of verdict.
```

Also update grep to exclude principles.md (CR P0-1 — new template file would be scanned by existing tools):
```yaml
      # Step 11a grep MUST exclude principles.md (empty template, not a content file yet):
      total=$(grep -c '^### ' .tad/project-knowledge/{architecture,code-quality,security,frontend-design}.md 2>/dev/null | awk -F: '{s+=$2}END{print s}')
      # ⚠️ Use explicit file list, NOT *.md glob — glob picks up principles.md (empty template) and future pattern/incident files
```

### Task 7: Create Classification Spreadsheet

Create `.tad/evidence/knowledge-migration/classification-spreadsheet.md`:

This is the critical P2 input. Blake must read EVERY `### Title - Date` entry across all 4 knowledge files and classify each one.

Format:
```markdown
# Knowledge Migration Classification Spreadsheet

> Phase 1 output. Human reviews and confirms before Phase 2 migration.
> Classification criteria: see .tad/project-knowledge/README.md

## Statistics
- Total entries: {count}
- L1 Principle candidates: {count}
- L2 Pattern candidates: {count}
- L3 Incident candidates: {count}
- DISCARD candidates: {count}

## Classification

### From: architecture.md ({N} entries)

| # | Entry Title | Date | Proposed Layer | Theme Group | Linked L1/L2 | Rationale | Human Confirmed |
|---|------------|------|---------------|-------------|-------------|-----------|----------------|
| 1 | Ralph Loop Two-Layer Architecture | 2026-01-26 | L2 | gate-design | — | Reusable architectural pattern, not a permanent principle | ☐ |
| 2 | Express Handoff is NOT Review-Exemption | 2026-04-14 | L1 | — | — | Permanent methodology rule (⚠️ SAFETY ENTRY) | ☐ |
| 3 | (example L3) 2026-05-30 dream-scanner Pass C lost values | 2026-05-30 | L3 | — | L2: pack-architecture "Parser must propagate value fields" | One-time event supporting an L2 pattern | ☐ |
| ... | ... | ... | ... | ... | ... | ... | ☐ |

⚠️ "Linked L1/L2" column (ARCH P1-1): REQUIRED for L3 entries — identifies which principle or pattern this incident supports. Write "—" for L1/L2/DISCARD entries. P2 needs this to build incidents/_index.md.

### From: code-quality.md ({N} entries)
(same table format)

### From: security.md ({N} entries)
(same table format)

### From: frontend-design.md ({N} entries)
(same table format)
```

⚠️ Classification rules for Blake:
- Entries with `⚠️ SAFETY ENTRY` → default L1 (human must individually confirm)
- Entries under `## Foundational` sections (e.g., "Two-Agent System", "Four-Gate Quality System") → default L1 (ARCH P1-3: these are inception-time methodology rules)
- Entries about specific shell commands (grep, sed, awk) → L2 shell-portability theme
- Entries about specific handoff/Epic events → L3 incident
- Entries that start with "Recurring failure" → L2 (it's a pattern, not a one-time event)
- When uncertain → default L2 (safer than L1, more durable than L3)

Concrete classification proxy (ARCH P1-4): "Where would this entry appear in TAD's public documentation?"
- A methodology rules page → L1
- A best-practice / patterns page → L2
- A changelog / postmortem → L3

Checkpoint rule (CR P2-2): After classifying every ~30 entries, output a running L1/L2/L3/DISCARD count. Verify L1 candidates remain ≤15. If over 15, re-evaluate — some entries are likely L2 patterns misclassified as L1.

⚠️ pack-architecture theme (ARCH P1-2): this group will be ~20+ entries. Pre-split into:
- `pack-build-rules.md` (how to build packs: provenance, anti-slop, research sourcing)
- `pack-evaluation.md` (how to evaluate packs: behavioral eval, collision detection, cross-model review)

---

## 8. 📚 Project Knowledge — ⚠️ Blake 必须注意的历史教训

| Entry | Source | Relevance |
|-------|--------|-----------|
| Judgment-Only Skill Files: Constraint Rules Are NOT Mechanical | architecture.md | STEP 3.5 knowledge scan is a SKILL-level judgment rule, not a hook. Must stay in SKILL.md. |
| Mechanical Enforcement Rejected on Single-User CLI | architecture.md | Sense engine is advisory (AskUserQuestion), never blocking. Matches smoke-alarm pattern. |
| Step Insertion Requires Predecessor Transition Arrow Audit | architecture.md | Inserting into STEP 3.5 — verify transition to STEP 3.55/3.6 is preserved |

---

## 9. Acceptance Criteria

### 9.1 Spec Compliance Checklist

| # | AC | Verification Method | Expected Evidence |
|---|-----|-------------------|-------------------|
| AC1 | patterns/ directory exists | `test -d .tad/project-knowledge/patterns && echo 1` | = 1 |
| AC2 | incidents/ directory exists | `test -d .tad/project-knowledge/incidents && echo 1` | = 1 |
| AC3 | principles.md template created | `test -f .tad/project-knowledge/principles.md && echo 1` | = 1 |
| AC4 | patterns/_index.md template created | `test -f .tad/project-knowledge/patterns/_index.md && echo 1` | = 1 |
| AC5 | incidents/_index.md template created | `test -f .tad/project-knowledge/incidents/_index.md && echo 1` | = 1 |
| AC6 | README documents 3-layer model | `grep -c 'Three-Layer Model' .tad/project-knowledge/README.md` | ≥ 1 |
| AC7 | README documents 5 lifecycle rules | `grep -c 'Lifecycle Rules' .tad/project-knowledge/README.md` | ≥ 1 |
| AC8 | README documents classification criteria | `grep -c 'Prediction-Error' .tad/project-knowledge/README.md` | ≥ 1 |
| AC9 | STEP 3.5 has knowledge health scan | `grep -c 'Knowledge Health Scan' .claude/skills/alex/SKILL.md` | ≥ 1 |
| AC10 | STEP 3.5 detects flat structure | `grep -c 'NEEDS_ORGANIZE' .claude/skills/alex/SKILL.md` | ≥ 1 |
| AC11 | STEP 3.5 detects bloated file | `grep -c 'NEEDS_CLEANUP' .claude/skills/alex/SKILL.md` | ≥ 1 |
| AC12 | Classification spreadsheet exists | `test -f .tad/evidence/knowledge-migration/classification-spreadsheet.md && echo 1` | = 1 |
| AC13 | Spreadsheet covers all entries | `grep -c '^| [0-9]' .tad/evidence/knowledge-migration/classification-spreadsheet.md` | ≥ 100 |
| AC14 | L1 candidates ≤ 15 | `grep -c '| L1 |' .tad/evidence/knowledge-migration/classification-spreadsheet.md` (after removing template example rows) | ≤ 15 |
| AC15 | knowledge-blame.sh unbroken | `bash .tad/hooks/lib/knowledge-blame.sh .tad/project-knowledge/architecture.md --line 10; echo $?` | exit 0 |
| AC15b | stale-knowledge-check.sh unbroken | `bash .tad/hooks/lib/stale-knowledge-check.sh 2>/dev/null; echo $?` | exit 0 or 1 (not 2/crash) |
| AC16 | Sense uses explicit file list not glob | `grep -c 'architecture,code-quality,security,frontend-design' .claude/skills/alex/SKILL.md` | ≥ 1 |

### 9.2 Expert Review Status

| Reviewer | Focus | P0 | P1 | P2 | Verdict |
|----------|-------|----|----|----|----|
| code-reviewer | Shell correctness, backward compat, transition arrows, ACs | 2 (all fixed) | 5 (4 fixed, 1 noted for P2) | 5 | CONDITIONAL PASS → fixed |
| backend-architect | Architecture, layer model, scope separation, classification | 3 (all fixed) | 4 (all fixed) | 3 | PASS with P0 fixes |

### 9.2.1 Audit Trail

| Reviewer | Issue | Resolution | Status |
|----------|-------|------------|--------|
| CR P0-1 | principles.md picked up by existing tool globs | Sense engine grep changed from `*.md` glob to explicit file list | Resolved |
| CR P0-2 | Missing interacts_with + transition arrows for STEP 3.5 insert | Added interacts_with block documenting non-suppression of STEP 3.55/3.56 | Resolved |
| ARCH P0-1 | AC15 doesn't verify stale-knowledge-check.sh | Added AC15b | Resolved |
| ARCH P0-2 | Epic >30 vs handoff >50 threshold inconsistency | Unified to >50 per file in both Epic and handoff | Resolved |
| ARCH P0-3 + CR P1-1 | NEEDS_ORGANIZE AskUser is a false choice (P2 not built) | Replaced with log-and-continue (no AskUserQuestion) | Resolved |
| ARCH P1-1 | Spreadsheet lacks "Linked L1/L2" column for L3 incidents | Added column + guidance | Resolved |
| ARCH P1-2 | pack-architecture theme will have 20+ entries | Pre-split into pack-build-rules + pack-evaluation | Resolved |
| ARCH P1-3 | Foundational section entries have no classification guidance | Added rule: Foundational → default L1 | Resolved |
| ARCH P1-4 | Prediction-error heuristic too abstract for batch classification | Added concrete proxy: "where in public docs?" | Resolved |
| CR P1-2 | AC13 not mechanically verifiable | Changed to `grep -c '^| [0-9]'` | Resolved |
| CR P1-3 | AC14 grep matches template example row | Added "after removing template example rows" note | Resolved |
| CR P1-5 | knowledge-blame.sh scope won't match patterns/*.md | Noted in §10.4 as known P2 forward-compat task | Deferred to P2 |
| CR P2-2 | 116 entries with no intermediate checkpoint | Added checkpoint rule: count every ~30 entries | Resolved |
| CR P2-3 | README new lifecycle rules overlap existing consolidation rules | Added §10.5 reconciliation note | Resolved |

---

## 10. Important Notes

### 10.1 This Phase Does NOT Move Entries
P1 creates the structure and classifies entries. P2 actually moves them. This separation lets the human review all 116 classifications BEFORE any entry is relocated.

### 10.2 Classification Is the Highest-Risk Activity
If an incident gets misclassified as L1 principle, it pollutes the methodology layer. Blake must default to L2 when uncertain (L2 is self-correcting — stale patterns get detected and cleaned; L1 entries are sticky).

### 10.3 Backward Compatibility
New empty directories + templates must not break `*dream`, `stale-knowledge-check.sh`, `knowledge-blame.sh`, or any existing @import in CLAUDE.md. The old flat files remain untouched in P1.

### 10.4 Forward Compatibility Note for Phase 2
knowledge-blame.sh's scope guard uses `.tad/project-knowledge/*` (one level). Files at `.tad/project-knowledge/patterns/shell-portability.md` will NOT match and be rejected. P2 must widen the scope guard to `.tad/project-knowledge/**` or add explicit patterns/ and incidents/ globs. This is a KNOWN P2 task, not a P1 bug.

### 10.5 Existing README Content
The current README.md has "Quantity Limits & Consolidation" rules that partially overlap with the new "5 Lifecycle Rules" (e.g., ">6 months old" consolidation trigger vs new 90-day expiration). Blake should reconcile: keep the old section as "Legacy rules" or merge into the new lifecycle section with a note about which supersedes which.

---

## 11. Required Evidence Manifest

```yaml
expert_reviews:
  - .tad/evidence/reviews/blake/knowledge-lifecycle-phase1/code-reviewer.md
  - .tad/evidence/reviews/blake/knowledge-lifecycle-phase1/backend-architect.md
gate_verdicts:
  - gate3_verdict in COMPLETION frontmatter
completion:
  - .tad/active/handoffs/COMPLETION-20260602-knowledge-lifecycle-phase1.md
knowledge_updates:
  - .tad/project-knowledge/architecture.md (if new pattern discovered)
```
