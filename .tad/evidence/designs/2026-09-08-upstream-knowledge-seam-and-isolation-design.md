# Architectural Design Note: TAD Upstream Knowledge Seam & Isolation

**Date**: 2026-09-08  
**Author**: Alex (Solution Lead, Terminal 1)  
**Mode**: `*discuss` / Architectural Research  
**Status**: Proposal & Design Recommendations (`NEEDS_HUMAN`)  
**Context**: Upstream knowledge boundary audit across 5 repositories (TAD, 买卖, menu-tales, agent-workshop, grok-cloud)

---

## 1. Ground Truth Audit & Problem Statement

### 1.1 Verified Empirical Facts (2026-09-08)
1. **Identical Brain-Index Header**: Five downstream repositories share the byte-identical `.tad/brain-index.md` header:
   ```markdown
   # TAD Brain Index
   Generated: 2026-09-02 14:23
   ```
2. **"Fake Richness" in Project Knowledge**:
   - In `买卖` vs `TAD`: `.tad/project-knowledge/` paired identical sha256 hashes on ~26 of 41 files.
   - 10/10 capability skills and numerous framework incidents from May/June 2026 (e.g. YOLO Epic reviews, Homebrew PATH hook collisions, 160KB `ac-verification.md` patterns) were present verbatim in business application repositories.
   - Downstream agents read hundreds of kilobytes of TAD internal framework debugging notes, treating them as project-specific institutional knowledge while genuine business domain knowledge is near-zero.
3. **The `tad.sh` Mechanism Leak**:
   - `tad.sh` and `.tad/hooks/lib/derive-sync-set.sh` declare `TAD_ZERO_TOUCH` for `.tad/project-knowledge/`.
   - However, `derive_framework_top_files()` in `tad.sh` only excludes `TAD_TOP_DENY="sync-registry.yaml"`. Because `.tad/brain-index.md` is a top-level regular file in `.tad/`, it was auto-classified as a syncable framework file and copied indiscriminately to downstream projects on every install and update.
   - Furthermore, legacy install/sync routines or manual repository bootstraps copied upstream `.tad/project-knowledge` contents into downstream repositories.
4. **The `brain-index-gen.sh` Pipefail Defect**:
   - `brain-index-gen.sh` has a known `set -euo pipefail` flaw (noted in `NEXT.md`): `grep -m1 '^task_type:' "$file"` exits with rc=1 when an older handoff lacks `task_type:`, immediately terminating the entire generation loop. As a result, even if invoked, it crashes after 11 items.
   - No protocol step (`acceptance-protocol.md`, `distillation-loop-protocol.md`, or hooks) actually triggers `brain-index-gen.sh`.

---

## 2. Architectural Design

```
+--------------------------------------------------------------------------------+
|                             TAD FRAMEWORK (UPSTREAM)                           |
|  .tad/                                                                         |
|    ├── brain-index.md ---------[ EXCLUDED FROM SYNC: TOP_DENY ]--------------+  |
|    ├── project-knowledge/ -----[ ZERO_TOUCH: Only README installed ]-----+   |  |
|    └── skills/ ----------------[ Framework Skills Manifest ]--------+    |   |  |
+----------------------------------------------------------------------|----|---|--+
                                                                       |    |   |
                                       tad.sh install / update         |    |   |
                                                                       v    v   v
+----------------------------------------------------------------------------------+
|                            DOWNSTREAM BUSINESS REPO                              |
|                                                                                  |
|  .tad/                                                                           |
|    ├── brain-index.md <======== GENERATED LOCALLY VIA TRIGGERS                   |
|    │                            (Post-distill, tad doctor, on-demand)            |
|    │                                                                             |
|    ├── project-knowledge/ <==== STRICT BUSINESS-OWNED ISOLATION                  |
|    │    ├── README.md (Distillation guide)                                       |
|    │    └── [Business entries distilled from actual tasks]                       |
|    │                                                                             |
|    └── archive/quarantine-pk/ <= QUARANTINED UPSTREAM SAME-HASH POLLUTION        |
|                                                                                  |
|  Skills Separation:                                                              |
|    ├── .claude/skills/<framework-packs>/  (Managed by tad.sh)                    |
|    └── .claude/skills/local/<project>/     (Protected, zero-sync)                 |
+----------------------------------------------------------------------------------+
```

---

## 3. Component Details & Recommendations

### 3.1 Brain-Index Lifecycle & Refresh Triggers

#### A. Ban Copying Upstream Index
- Update `derive-sync-set.sh` and inlined `tad.sh`:
  ```bash
  TOP_DENY="sync-registry.yaml
  brain-index.md"
  ```
- In `tad.sh`:
  - `install`: Do not copy `.tad/brain-index.md`. Run local `brain-index-gen.sh` at the end of installation if `.tad/hooks/lib/brain-index-gen.sh` is available, or let it generate on first use.
  - `update` / `migrate`: Never touch target's `.tad/brain-index.md`.

#### B. Defect Fix for `brain-index-gen.sh`
- Replace fragile pipelines with fail-safe constructs:
  ```bash
  # Before (crashes under set -eo pipefail when pattern not found):
  task_type=$(grep -m1 '^task_type:' "$file" 2>/dev/null | sed 's/task_type: *//;s/ *#.*//' | tr -d '[:space:]')
  
  # After (safe):
  task_type=$({ grep -m1 '^task_type:' "$file" 2>/dev/null || true; } | sed 's/task_type: *//;s/ *#.*//' | tr -d '[:space:]')
  task_type="${task_type:-unknown}"
  ```
- Apply this pattern across all `grep` invocations in `brain-index-gen.sh` (§5, §6, §7).

#### C. Refresh Trigger Architecture
We define three non-blocking refresh triggers:
1. **Trigger 1: Post-Distill / Post-Accept (Primary Automated Refresh)**:
   - In `distillation-loop-protocol.md` Step 6 (Finalize) and `acceptance-protocol.md` Step 4f/Step 7:
     If a new playbook entry is committed to `.tad/project-knowledge/`, execute:
     `bash .tad/hooks/lib/brain-index-gen.sh >/dev/null 2>&1 || true`
   - This keeps the local semantic search index fresh whenever institutional memory actually changes.
2. **Trigger 2: Health & Maintenance Checks (`tad doctor` & `/tad-maintain`)**:
   - In `./tad doctor` or `/tad-maintain` (CHECK mode):
     - Check if `brain-index.md` exists.
     - Check if `brain-index.md` is older than the newest file in `.tad/project-knowledge/`.
     - In `/tad-maintain` (SYNC mode): auto-regenerate `brain-index.md`.
3. **Trigger 3: On-Demand Manual Refresh**:
   - `bash .tad/hooks/lib/brain-index-gen.sh` remains available as a standalone CLI command.

---

### 3.2 Shell/Install Isolation: Framework vs Business Project Knowledge

#### A. Initial State for New Projects
- When `tad.sh install` runs on a fresh project:
  - Create directory structure: `.tad/project-knowledge/`, `.tad/project-knowledge/patterns/`, `.tad/project-knowledge/incidents/`.
  - Install **ONLY** `.tad/project-knowledge/README.md`.
  - Do NOT copy `principles.md`, `patterns/*.md`, or `incidents/**`.
  - Update `README.md` to explain:
    1. Project knowledge is forged through the distillation loop, not pre-seeded with framework internals.
    2. Framework methodology rules are located in `CLAUDE.md` and the installed skill files.

#### B. Provenance Tagging (When Framework Knowledge is Explicitly Imported)
- If downstream agents need access to specific architectural patterns, they should either:
  1. Access them via framework skills (e.g. `.claude/skills/alex/`, `.claude/skills/gate/`).
  2. If copied into project knowledge, carry a mandatory frontmatter tag:
     ```yaml
     ---
     provenance: tad-framework@v2.44.3
     upstream_path: .tad/project-knowledge/principles.md
     read_only: true
     ---
     ```

#### C. Quarantine / Migration Plan for Existing Polluted Business Repos
For repositories like `买卖`, `menu-tales`, `agent-workshop`, `grok-cloud`:
1. **Quarantine Tool**: Provide `.tad/hooks/lib/quarantine-framework-pk.sh` (executable via `tad.sh --quarantine-pk`).
2. **Mechanism**:
   - Read an upstream reference manifest (or compute against upstream TAD commit hashes for the known 26 files from 2026-05/06 incidents and framework-specific patterns).
   - For each file in target `.tad/project-knowledge/`:
     - If `sha256(target_file) == sha256(upstream_file)`:
       - Move file to `.tad/archive/quarantine-framework-pk-20260908/<relative_path>`.
       - Record action in `.tad/archive/quarantine-framework-pk-20260908/MANIFEST.md`.
     - If the file has been modified locally (sha256 mismatch):
       - Do NOT move. Retain in `.tad/project-knowledge/`.
       - Log informational warning: `User-modified knowledge preserved: <path>`.
3. **Post-Quarantine Rebuild**:
   - Execute `brain-index-gen.sh` immediately to wipe stale framework pointers from `brain-index.md`.

---

### 3.3 Skill Separation: Framework Skills vs Project-Learned Skills

1. **Framework Skills**:
   - Located in `.claude/skills/<pack>/` and `.agents/skills/<pack>/`.
   - Listed in upstream `skills-config.yaml` / `pack-registry.yaml`.
   - Managed, updated, and verified by `tad.sh`.
2. **Project-Learned Skills**:
   - **Type A (Ad-hoc Conversational)**: Created by `*save-skill` into `.claude/skills/local/<name>/`.
     - Gitignored from framework tracking (`.gitignore` has `.claude/skills/local/` and `.agents/skills/local/`).
     - `tad.sh` copy loops must explicitly exclude `local/`.
   - **Type B (Engineered via `$capability-builder`)**:
     - Created into `.agents/skills/<name>/` and projected to `.claude/skills/<name>/`.
     - Must declare `ownership: project-owned` in `SKILL.md` frontmatter.
   - **Installer Guarantee**:
     - `copy_framework_files()` in `tad.sh` must check:
       ```bash
       [ "$skill_name" = "local" ] && continue
       if [ -f "$TARGET_SKILL_DIR/$skill_name/SKILL.md" ] && \
          grep -q 'ownership: *project-owned' "$TARGET_SKILL_DIR/$skill_name/SKILL.md"; then
           log_info "  → Preserving project-owned skill: $skill_name"
           continue
       fi
       ```

---

### 3.4 Distillation: Soft Evidence Path (Non-Gate-Hard)

**Strict Adherence to Principle**: "Knowledge is forged at distill, not captured. Do NOT make per-ticket journal a Gate PASS requirement."

- **Policy**:
  - Blake's journal capture remains voluntary; Gate 3 Q1 only asks whether discoveries exist.
  - Alex's Gate 4 acceptance is never blocked by whether knowledge distillation produced entries.
  - If a task yields no new generalized patterns (routine bug fix, config bump), distillation is legitimately skipped.
- **Evidence Logging**:
  - In completion reports and `.tad/evidence/reviews/`, log an advisory status block:
    ```yaml
    knowledge_distillation:
      attempted: true|false
      entries_distilled: 0
      brain_index_refreshed: false
      reason: "Routine maintenance task; variabilize test yielded no general pattern"
    ```
  - If entries were forged and added to `.tad/project-knowledge/`:
    ```yaml
    knowledge_distillation:
      attempted: true
      entries_distilled: 1
      entry_label: "external-api-retry-backoff"
      category: "api-integration.md"
      brain_index_refreshed: true
    ```
  - Gate 3 and Gate 4 verification scripts strictly assert that this evidence block is syntactically present or logged, but NEVER fail a gate because `entries_distilled == 0`.

---

## 4. Human Decision Points & Open Questions

Before Blake implements these changes in `tad.sh` and the core hooks, the human PM / architect should decide on:

1. **Handling of `principles.md` in Downstream Repositories**:
   - *Option A (Pure Isolation)*: Business repos start with 0 files in `.tad/project-knowledge/` except `README.md`. Agents rely purely on `CLAUDE.md` and SKILL files for TAD methodology principles.
   - *Option B (Shared Framework Core)*: Provide a read-only `.tad/project-knowledge/framework-principles.md` with explicit provenance tags, leaving all other categories completely empty for business capture.
   - *Recommendation*: **Option A**. TAD core rules are already comprehensively specified in `CLAUDE.md` §1-§6 and the agent roles (`alex`, `blake`, `gate`). Putting framework development principles into business `project-knowledge/` is the root cause of the "fake richness" confusion.

2. **Quarantine Automation**:
   - Should `tad.sh update` automatically run quarantine when updating an existing project to v2.45.0, or should it be an explicit opt-in command (`tad.sh --quarantine-pk`)?
   - *Recommendation*: Default to prompt/opt-in (`tad.sh --quarantine-pk`) to ensure human visibility before files are relocated.

3. **Status of Draft Handoff**:
   - Handoff stub generated as `NEEDS_HUMAN` awaiting PM confirmation of the above two decisions.
