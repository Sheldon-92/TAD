---
task_type: mixed
e2e_required: no
research_required: no
skip_knowledge_assessment: no
git_tracked_dirs: []
gate4_delta: []
---

# Handoff: Domain Pack Freeze — Cleanup & Migration

**From:** Alex (Agent A - Solution Lead)
**To:** Blake (Agent B - Execution Master)
**Date:** 2026-05-20
**Project:** TAD
**Task ID:** TASK-20260520-002
**Handoff Version:** 3.1.0

---

## 🔴 Gate 2: Design Completeness

**执行时间**: 2026-05-20

### Gate 2 检查结果

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Architecture Complete | ✅ | Archive 12 YAML + delete 6 router files + dynamic SKILL.md guard in startup-health.sh |
| Components Specified | ✅ | 6 FR with precise file lists, 13 Alex SKILL.md refs identified, sync script cleanup scoped |
| Functions Verified | ✅ | startup-health.sh scanning (line 49-89), settings.json UserPromptSubmit (line 68-78), sync-v2.8.4.sh router test (line 224-283) |
| Data Flow Mapped | ✅ | SessionStart: YAML scan (filtered by SKILL.md guard) → context injection. Router path fully removed. |

**Gate 2 结果**: ✅ PASS

**Expert Review**: 2 experts (code-reviewer + backend-architect), 6 P0 + 4 P1 all resolved. See §9.2 Audit Trail.

**Alex确认**: 我已验证所有设计要素，Blake可以独立根据本文档完成实现。

---

## 📋 Handoff Checklist (Blake必读)

- [ ] 阅读了所有章节
- [ ] 阅读了「📚 Project Knowledge」章节中的历史经验
- [ ] 理解了真正意图（不只是字面需求）
- [ ] 确认可以独立使用本文档完成实现

---

## 1. Task Overview

### 1.1 What We're Building
清理 Domain Pack 遗留系统。13 个 Capability Pack (SKILL.md) 已替代 Domain Pack (YAML)，但旧系统仍在运行导致双重加载、token 浪费、信号冲突。

核心操作：
1. **归档 12 个被替代的 YAML** → `.tad/archive/domains/`
2. **保留 9 个无替代的 YAML**（8 hw/mobile + supply-chain-security），但从 SessionStart 热加载中排除已有 SKILL.md 替代的 pack
3. **删除 keyword router** — userprompt-domain-router.sh + keywords.yaml + settings.json UserPromptSubmit
4. **更新引用路径** — Alex/Blake SKILL.md 从引用 Domain Pack YAML 改为引用 Capability Pack SKILL.md

### 1.2 Why We're Building It
**数据支撑**：跨 15 个项目分析显示，Domain Pack events 在下游项目使用率为 0%（menu-snap 0/360, 合规ai 0/60, Next Guest 0/121）。只有 TAD 母项目和 toy 有使用记录（开发时自产 trace）。21 个 YAML 通过 SessionStart 全部注入每个 session 的 context，其中 10 个与 Capability Pack SKILL.md 重复——纯 token 浪费。

**用户受益**：SessionStart context 更精简（-10 个冗余 pack 描述），无 keyword router 误触发，Alex/Blake 引用最新的 SKILL.md 规则（研究驱动，质量更高）。

### 1.3 Intent Statement
**真正要解决的问题**：消除 Domain Pack → Capability Pack 迁移的遗留债务。

**不是要做的**：
- ❌ 不升级 hw/mobile pack 为 SKILL.md（保留供未来按需升级）
- ❌ 不改变 Capability Pack 的加载机制（SessionStart + step4_5 已经工作正常）
- ❌ 不修改 `*sync` 的执行逻辑

---

## 📚 Project Knowledge（Blake 必读）

### ⚠️ Blake 必须注意的历史教训

1. **Feature Deprecation Cleanup Pattern — 2026-02-17** (architecture.md)
   - 关键：Use function names not line numbers. Grep-driven completeness. AC MUST include grep verification.
   - 与本任务关系：删除 keyword router 后必须 grep 确认无残留引用

2. **Domain Pack Keyword Curation — 2026-04-07** (architecture.md)
   - 关键：Strict uniqueness + threshold 1 = 100% accuracy
   - 与本任务关系：删除 keywords.yaml 时这套规则一起废弃

3. **`.router.log` 5-Tuple as Load-Bearing Hook Output Contract — 2026-04-27** (architecture.md)
   - 关键：hook side-output 被下游消费时，格式变更是 breaking change
   - 与本任务关系：检查是否有任何脚本消费 userprompt-domain-router.sh 的输出

---

## 3. Requirements

### 3.1 Functional Requirements

- **FR1 (Archive 12 YAML)**: Move to `.tad/archive/domains/`:
  - 10 overlapping: ai-agent-architecture, ai-evaluation, ai-prompt-engineering, ai-tool-integration, code-security, web-backend, web-deployment, web-frontend, web-testing, web-ui-design
  - 1 superseded: product-definition (replaced by product-thinking Capability Pack)
  - 1 deprecated: tools-registry (meta file, no longer used)
  - Create `.tad/archive/domains/` if not exists

- **FR2 (Keep 9 YAML)**: Leave in `.tad/domains/`:
  - hw-circuit-design, hw-enclosure, hw-firmware, hw-testing
  - mobile-development, mobile-release, mobile-testing, mobile-ui-design
  - supply-chain-security

- **FR3 (Delete keyword router ecosystem)**: Remove entire router system (CR-P0-1/2, ARCH-P0-2/3 fix):
  - Delete `.tad/hooks/userprompt-domain-router.sh` (main router)
  - Delete `.tad/hooks/keywords.yaml` (keyword database)
  - Delete `.tad/hooks/keywords.yaml.draft` (draft file)
  - Delete `.tad/hooks/generate-keywords.sh` (keyword generator)
  - Delete `.tad/hooks/.router.log` (router log)
  - Delete `.tad/hooks/run-phase2b-tests.sh` (router test suite)
  - Clean `.tad/scripts/sync-v2.8.4.sh`: remove router smoke test (lines 224-239, 265-283) — replace with skip comment
  - Remove the `UserPromptSubmit` section from `.claude/settings.json`
  - Keep evidence files in `.tad/evidence/acceptance-tests/` (historical, not active code)
  - Before deleting: grep full codebase for `.router.log`, `userprompt-domain-router`, `keywords.yaml`, `generate-keywords` to confirm no OTHER consumers exist

- **FR4 (Modify startup-health.sh)**: Change Domain Pack scanning logic (lines 49-89) to skip YAML files that have a Capability Pack SKILL.md equivalent:
  - Check: does `.claude/skills/{base}/SKILL.md` exist?
  - If yes → skip this YAML (Capability Pack handles it)
  - If no → keep in context (hw/mobile/supply-chain still need YAML injection)
  - This way, 9 remaining YAML packs get injected, 0 duplicates

- **FR5 (Update deprecation.yaml)**: Add entries for downstream *sync cleanup:
  - `.tad/hooks/userprompt-domain-router.sh` → delete
  - `.tad/hooks/keywords.yaml` → delete
  - 12 archived YAML files → delete from `.tad/domains/` on downstream projects
  - Version: current TAD version + 1 patch (e.g., if current is 2.16.0, add as 2.17.0)

- **FR6 (Update Alex SKILL.md references — 13 occurrences)**: Alex SKILL.md has 13 references to `.tad/domains/`. Blake SKILL.md has 0 (already clean). For each Alex reference:
  - If it references a pack name that has a Capability Pack (10 overlapping): change path to `.claude/skills/{name}/SKILL.md`
  - If it references hw/mobile/supply-chain (no SKILL.md): keep `.tad/domains/{name}.yaml`
  - If it's a generic pattern like `.tad/domains/{pack-name}.yaml`: add conditional logic (try SKILL.md first, fall back to YAML)
  - Key sections: `domain_pack_awareness`, `step1_5`, `step1a`, `research_priority_rule`, `step1_5b` dedup annotation
  - ⚠️ Name mismatch: `product-definition` YAML was renamed to `product-thinking` Capability Pack. The startup-health.sh guard `[ -f ".claude/skills/${base}/SKILL.md" ]` will NOT match for this name. Since product-definition.yaml is archived (FR1), runtime is safe — but document this limitation in §10.

### 3.2 Non-Functional Requirements
- **NFR1**: All file moves are `mv` (atomic). No file content modification on archived files.
- **NFR2**: settings.json must remain valid JSON after removing UserPromptSubmit section.
- **NFR3**: Downstream projects receive cleanup via *sync deprecation (not this handoff).

---

## 4. Technical Design

### 4.1 startup-health.sh Modification (lines 49-89)

After the existing `[ "$base" = "tools-registry" ] && continue` (line 56) and `DEPRECATED` check (line 58), add:

```bash
    # Skip YAML packs that have Capability Pack SKILL.md equivalents
    if [ -f ".claude/skills/${base}/SKILL.md" ]; then
      continue
    fi
```

This single 3-line addition handles the entire dedup. When the 12 archived YAMLs are moved out of `.tad/domains/`, they won't be scanned anyway. But this guard also future-proofs: if a new Capability Pack is created for hw-firmware, the YAML auto-stops loading.

### 4.2 settings.json — Remove UserPromptSubmit

Current (lines 68-78):
```json
    "UserPromptSubmit": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "bash .tad/hooks/userprompt-domain-router.sh"
          }
        ]
      }
    ]
```

Remove entire `"UserPromptSubmit": [...]` block. Ensure no trailing comma issues.

### 4.3 Alex SKILL.md Reference Updates

In `domain_pack_awareness` (in *discuss):
```yaml
      action: |
        # Priority order for pack loading:
        # 1. Capability Pack: .claude/skills/{name}/SKILL.md (preferred — research-driven rules)
        # 2. Domain Pack YAML: .tad/domains/{name}.yaml (fallback for hw/mobile/supply-chain only)
```

In `step1_5` (in *design) and Blake `step1_5a`:
Same priority logic — try SKILL.md first, fall back to YAML only if no SKILL.md exists.

---

## 6. Implementation Steps

### Step 1: Archive 12 YAML files
```bash
mkdir -p .tad/archive/domains
for f in ai-agent-architecture ai-evaluation ai-prompt-engineering ai-tool-integration \
         code-security web-backend web-deployment web-frontend web-testing web-ui-design \
         product-definition tools-registry; do
  mv ".tad/domains/${f}.yaml" ".tad/archive/domains/" 2>/dev/null
done
```

### Step 2: Delete keyword router
```bash
# Pre-check: any references?
grep -rn 'userprompt-domain-router\|keywords\.yaml' .tad/ .claude/ --include='*.sh' --include='*.json' --include='*.yaml' --include='*.md' | grep -v 'archive/' | grep -v 'HANDOFF-'
# If only settings.json and the files themselves → safe to delete
rm .tad/hooks/userprompt-domain-router.sh
rm .tad/hooks/keywords.yaml
```

### Step 3: Update settings.json
Remove UserPromptSubmit section. Verify JSON validity: `jq . .claude/settings.json`

### Step 4: Modify startup-health.sh
Add 3-line Capability Pack skip guard per §4.1.

### Step 5: Update Alex SKILL.md references
In *discuss `domain_pack_awareness` and *design `step1_5`: add priority comment (SKILL.md first, YAML fallback).

### Step 6: Update Blake SKILL.md references
In Blake `step1_5a`: same priority logic.

### Step 7: Update deprecation.yaml
Add entries for *sync downstream cleanup per FR5.

### Step 8: Verification
- `ls .tad/domains/` → exactly 9 YAML files (hw-* × 4, mobile-* × 4, supply-chain-security)
- `ls .tad/archive/domains/` → exactly 12 YAML files
- `jq . .claude/settings.json` → valid JSON, no UserPromptSubmit
- `grep -rn 'userprompt-domain-router' .tad/ .claude/ --include='*.sh' --include='*.json'` → 0 results (excluding archive)
- `grep -c 'claude/skills.*SKILL.md' .tad/hooks/startup-health.sh` → ≥1

### Grounded Against (Alex step1c):
- .tad/hooks/startup-health.sh lines 49-89 (Domain Pack scanning, read at 2026-05-20)
- .claude/settings.json lines 68-78 (UserPromptSubmit hook, read at 2026-05-20)
- .tad/hooks/userprompt-domain-router.sh header (read at 2026-05-20)
- .tad/domains/ directory listing (21 files, read at 2026-05-20)

---

## 7. File Structure

### 7.1 Files to Modify
```
.claude/settings.json              # Remove UserPromptSubmit section
.tad/hooks/startup-health.sh       # Add Capability Pack skip guard (3 lines)
.claude/skills/alex/SKILL.md       # Update domain_pack_awareness + step1_5 references
.claude/skills/blake/SKILL.md      # Update step1_5a references
.tad/deprecation.yaml              # Add entries for downstream cleanup
```

### 7.2 Files to Delete
```
.tad/hooks/userprompt-domain-router.sh
.tad/hooks/keywords.yaml
.tad/hooks/keywords.yaml.draft
.tad/hooks/generate-keywords.sh
.tad/hooks/.router.log
.tad/hooks/run-phase2b-tests.sh
```

### 7.3 Files to Clean (not delete)
```
.tad/scripts/sync-v2.8.4.sh        # Remove router smoke test (lines 224-239, 265-283)
```

### 7.3 Files to Archive (mv to .tad/archive/domains/)
```
.tad/domains/ai-agent-architecture.yaml
.tad/domains/ai-evaluation.yaml
.tad/domains/ai-prompt-engineering.yaml
.tad/domains/ai-tool-integration.yaml
.tad/domains/code-security.yaml
.tad/domains/web-backend.yaml
.tad/domains/web-deployment.yaml
.tad/domains/web-frontend.yaml
.tad/domains/web-testing.yaml
.tad/domains/web-ui-design.yaml
.tad/domains/product-definition.yaml
.tad/domains/tools-registry.yaml
```

---

## 9. Acceptance Criteria

- [ ] AC1: `.tad/domains/` contains exactly 9 YAML files
- [ ] AC2: `.tad/archive/domains/` contains 12 archived YAML files
- [ ] AC3: All 6 router ecosystem files deleted (router, keywords, draft, generator, log, tests)
- [ ] AC4: `settings.json` has no `UserPromptSubmit` section and is valid JSON (`jq .` exits 0)
- [ ] AC5: `startup-health.sh` skips YAML packs that have `.claude/skills/{name}/SKILL.md`
- [ ] AC6: `grep -rn 'userprompt-domain-router\|\.router\.log\|keywords\.yaml' .tad/hooks/ .claude/ --include='*.sh' --include='*.json'` returns 0 results
- [ ] AC7: Alex SKILL.md `.tad/domains/` references updated: SKILL.md-first for overlapping packs, YAML kept for hw/mobile/supply-chain
- [ ] AC8: deprecation.yaml has entries for router ecosystem files + 12 YAML files
- [ ] AC9: No changes to Capability Pack SKILL.md files or pack-registry.yaml
- [ ] AC10: `sync-v2.8.4.sh` router smoke test removed (lines 224-283 replaced with skip comment)
- [ ] AC11: product-definition vs product-thinking name mismatch documented in §10

## 9.1 Spec Compliance Checklist

| # | Verification Type | Verification Method | Expected | Verified |
|---|-------------------|--------------------|---------:|----------|
| 1 | post-impl | `ls .tad/domains/*.yaml \| wc -l` | 9 | (post-impl) |
| 2 | post-impl | `ls .tad/archive/domains/*.yaml \| wc -l` | 12 | (post-impl) |
| 3 | post-impl | `jq . .claude/settings.json > /dev/null && echo valid` | valid | (post-impl) |
| 4 | post-impl | `grep -c 'UserPromptSubmit' .claude/settings.json` | 0 | (post-impl) |
| 5 | post-impl | `grep -c 'claude/skills.*SKILL.md' .tad/hooks/startup-health.sh` | ≥1 | (post-impl) |

---

## 10. Important Notes

### 10.1 Critical Warnings
- ⚠️ Before deleting keyword router: grep entire codebase. If any script consumes `.router.log` output, do NOT delete until that consumer is updated.
- ⚠️ settings.json trailing comma: JSON doesn't allow trailing commas. After removing UserPromptSubmit block, verify the preceding PostToolUse block's closing `]` doesn't have a trailing comma before the closing `}`.
- ⚠️ 9 remaining YAML files in `.tad/domains/` are STILL needed by startup-health.sh for hw/mobile/supply-chain injection. Do NOT archive them.
- ⚠️ **Name mismatch**: `product-definition` YAML → `product-thinking` Capability Pack. These have different slugs. The startup-health.sh guard `[ -f ".claude/skills/${base}/SKILL.md" ]` will NOT match for renamed packs. Safe because product-definition.yaml is archived (FR1), but if someone recreates a YAML with a name that doesn't match any SKILL.md dir, the guard won't catch it. This is a known limitation of slug-based matching.

## 9.2 Expert Review Status

### Audit Trail

| Reviewer | Issue | Resolution Section | Status |
|----------|-------|-------------------|--------|
| code-reviewer | P0-1: generate-keywords.sh + keywords.yaml.draft orphaned | §3.1 FR3 expanded to 6 files + sync script cleanup | Resolved |
| code-reviewer | P0-2: .router.log consumers (run-phase2b-tests.sh, sync-v2.8.4.sh) not addressed | §3.1 FR3: delete test suite, clean sync script. AC6+AC10 added | Resolved |
| code-reviewer | P0-3: product-definition vs product-thinking name mismatch | §10.1 documented as known limitation. FR1 archives it anyway → runtime safe. AC11 added | Resolved |
| backend-architect | P0-1: Same name mismatch (independently flagged) | Same resolution | Resolved |
| backend-architect | P0-2: Orphaned router ecosystem (independently flagged) | Same resolution as CR-P0-1/2 | Resolved |
| backend-architect | P0-3: sync-v2.8.4.sh live smoke test will fail | §3.1 FR3: remove smoke test from sync script. AC10 added | Resolved |
| code-reviewer | P1-4: settings.json edit boundary imprecise | §10.1 already warns about trailing comma; jq validation in AC4 | Resolved |
| code-reviewer | P1-5: No AC for Blake SKILL.md | Blake has 0 `.tad/domains/` refs — no update needed. Documented. | Resolved |
| backend-architect | P1-4: Alex SKILL.md has 13 refs, not 2 | §3.1 FR6 rewritten with 13-reference scope + key sections listed | Resolved |
| backend-architect | P1-5: No AC for residual domain ref cleanup | AC7 updated to verify SKILL.md-first pattern | Resolved |
| backend-architect | P2-6: DOMAIN-PACK-ROADMAP.md etc. not mentioned | Noted — can archive with YAML files if found | Deferred |

### Experts Selected

1. **code-reviewer** — file deletion completeness, grep coverage, settings.json validity
2. **backend-architect** — migration safety, downstream impact, cross-file reference scope

### Overall Assessment (post-integration)

- code-reviewer: NOT READY → PASS (3 P0, 2 P1 resolved)
- backend-architect: CONDITIONAL PASS → PASS (3 P0, 2 P1 resolved, 1 P2 deferred)

---

### 10.2 Sub-Agent 使用建议
- [ ] **code-reviewer** — settings.json validity, grep completeness, startup-health.sh logic

---

## 11. Decision Summary

| # | Decision | Options Considered | Chosen | Rationale |
|---|----------|-------------------|--------|-----------|
| 1 | Overlapping YAML | Delete vs Archive vs Keep | Archive | Reference value for future, not polluting runtime |
| 2 | HW/Mobile YAML | Archive vs Keep | Keep (9 files) | No SKILL.md replacement exists yet |
| 3 | Keyword router | Keep with cleanup vs Delete entirely | Delete entirely | 0% downstream usage, step4_5 replaces functionality |
| 4 | startup-health.sh | Hardcode skip list vs Dynamic SKILL.md check | Dynamic check | Future-proof: new Capability Packs auto-skip YAML |

---

**Required Evidence Manifest**:
```yaml
evidence:
  expert_reviews:
    - .tad/evidence/reviews/alex/domain-pack-freeze/code-reviewer.md
    - .tad/evidence/reviews/alex/domain-pack-freeze/backend-architect.md
  gate_verdicts:
    - Gate 2 in this document
  completion:
    - .tad/active/handoffs/COMPLETION-20260520-domain-pack-freeze.md
  blake_reviews:
    - .tad/evidence/reviews/blake/domain-pack-freeze/
```

---

**Handoff Created By**: Alex (Agent A)
**Date**: 2026-05-20
**Version**: 3.1.0
