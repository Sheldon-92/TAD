---
task_type: yaml
e2e_required: no
research_required: yes  # Phase 0 research complete — Blake reads existing files, no new research
---

# Handoff: Security Domain Pack — Phase 1 Core Packs (supply-chain + code-security)

**From:** Alex (Agent A - Solution Lead)
**To:** Blake (Agent B - Execution Master)
**Date:** 2026-04-04
**Project:** TAD Framework
**Task ID:** TASK-20260404-015
**Handoff Version:** 3.1.0
**Epic:** EPIC-20260403-security-domain-pack-chain.md (Phase 1/4)

---

## 🔴 Gate 2: Design Completeness

**执行时间**: 2026-04-04

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Architecture Complete | ✅ | 2 YAML packs + tools-registry updates fully specified |
| Components Specified | ✅ | 10 capabilities (5 per pack) with steps, tool_ref, quality_criteria from Phase 0 research |
| Functions Verified | ✅ | N/A (YAML config, no code functions) |
| Data Flow Mapped | ✅ | Research files → YAML Pack → tools-registry updates |

**Gate 2 结果**: ✅ PASS

**Alex确认**: 我已验证所有设计要素，Blake可以独立根据本文档完成实现。

---

## 📋 Handoff Checklist (Blake必读)

- [ ] 阅读了所有章节
- [ ] **阅读了「📚 Project Knowledge」章节中的历史经验**
- [ ] 理解了真正意图（不只是字面需求）
- [ ] 确认可以独立使用本文档完成实现

---

## 1. Task Overview

### 1.1 What We're Building
2 Domain Pack YAML files (supply-chain-security.yaml + code-security.yaml) and tools-registry.yaml updates, based on Phase 0 research.

### 1.2 Why We're Building It
**业务价值**：TAD 安全链路的基础层——依赖安全和代码安全是所有项目的必需品
**成功的样子**：当用户的项目触发安全审计时，TAD 能通过 Domain Pack 提供结构化的审计工作流，而不是通用 checklist

### 1.3 Intent Statement

**真正要解决的问题**：将 Phase 0 的研究成果转化为可执行的 YAML Pack 配置。

**不是要做的**：
- ❌ 不是重新研究工具（Phase 0 已完成）
- ❌ 不是写安全工具代码（Pack 是配置，不是实现）
- ❌ 不是修改 TAD 核心流程（集成是 Phase 3 的事）

---

## 📚 Project Knowledge（Blake 必读）

### 步骤 1：识别相关类别
- [x] architecture - Domain Pack 设计模式

### 步骤 2：历史经验摘录

| 文件 | 相关记录数 | 关键提醒 |
|------|-----------|----------|
| architecture.md | 4 条 | Step Model A/B/Mixed, Research>QC Text, Tool Freshness, Tool Boundaries |

**⚠️ Blake 必须注意的历史教训**：

1. **Domain Pack Step Model: Type A/B/Mixed** (architecture.md)
   - 每个 capability 独立分类为 A(文档) / B(工具执行)
   - supply-chain: 全部 Type B（工具执行）
   - code-security: 4个 Type B + 1个 Type A (vulnerability_triage)

2. **Tool Freshness Problem** (feedback memory)
   - YAML 中每个 tool_ref 必须在 tools-registry.yaml 中有完整条目
   - 条目包含：install 命令、CLI usage pattern、output format 示例

3. **Hook Shell Portability** (architecture.md)
   - 不用写 hook，但 YAML 中的命令示例避免 macOS 不兼容的语法

---

## 2. Background Context

### 2.1 Previous Work — Phase 0 Research Files (⚠️ MUST READ)

Blake 必须在开始 YAML 编写前完整阅读以下文件：

```
READ THESE FIRST:
1. .tad/spike-v3/domain-pack-tools/security-supply-chain-research.md (346 lines)
2. .tad/spike-v3/domain-pack-tools/security-code-security-research.md (408 lines)
3. .tad/spike-v3/domain-pack-tools/security-tool-evaluation-matrix.md (189 lines)
```

### 2.2 Reference: Existing Domain Pack Structure

Use these as structural reference (NOT content reference):
- `.tad/domains/web-backend.yaml` (756 lines — good example of Type B capabilities)
- `.tad/domains/ai-evaluation.yaml` (831 lines — good example of cross-cutting pack)
- `.tad/domains/tools-registry.yaml` (1542 lines — where new tools go)

### 2.3 Existing Security Infrastructure (DO NOT duplicate)
- `.tad/skills/security-audit/SKILL.md` — P0-P3 checklist (existing, keep separate)
- `web-deployment.yaml` → security_hardening capability (overlap boundary: deployment-time hardening stays there, code-time scanning belongs in new packs)

---

## 3. Requirements

### 3.1 Functional Requirements
- FR1: supply-chain-security.yaml with 5 capabilities from Phase 0 research
- FR2: code-security.yaml with 5 capabilities from Phase 0 research
- FR3: tools-registry.yaml updated with all new tools (est. ~20 tools from supply-chain + code-security domains)
- FR4: Each capability has ≥4 workflow steps with tool_ref
- FR5: Each pack has description, scope declaration, review persona + checklist
- FR6: Cross-domain design: tool_ref adapts to ecosystem (npm/pip/cargo/go) via conditional steps or alternative tools

### 3.2 Non-Functional Requirements
- NFR1: YAML syntax valid (no parse errors)
- NFR2: All tool_ref names match tools-registry.yaml entries
- NFR3: Pack descriptions declare platform/tool scope boundaries

---

## 4. Technical Design

### 4.1 YAML Pack Structure (follow existing pattern)

```yaml
# Domain Pack: {domain-name}
domain: "{domain-name}"        # NOT "name:" — must match existing packs
version: "1.0.0"
description: |
  {description}
  Scope: {what this pack covers and does NOT cover}
requires_registry: ">=1"       # signals tools-registry dependency
output_dir: ".tad/active/research/{project}/"

# ⚠️ Pipeline gating — MANDATORY for security packs
severity_policy:
  block_pipeline: ["CRITICAL", "HIGH"]
  warn_only: ["MEDIUM", "LOW"]
  accept_risk_requires: "documented justification in triage report"
  grace_period: "existing findings get 2-sprint remediation window"

capabilities:
  {capability_name}:
    description: "{what it does}"
    type: "B"  # A (document) or B (tool execution)
    steps:
      - id: "{step_id}"
        action: |
          {detailed action description with CLI commands}
        tool_ref: {tool_name}
        output_file: "{expected output path}"
        quality: "{per-step quality check}"  # optional per-step quality
    quality_criteria:
      - "{criterion 1}"
      - "{criterion 2}"
    anti_patterns:
      - "{what NOT to do}"

review:
  persona: "Security Engineer"
  checklist:
    - "{review item 1}"
    - "{review item 2}"

gates:
  gate2_design:
    checklist:
      - "{security-specific design check}"
  gate4_acceptance:
    checklist:
      - "{security-specific acceptance check}"

output_structure:
  description: "Expected output directory tree"
  tree: |
    {project}/
    ├── audit-report.md
    ├── scan-results/
    └── triage-plan.md
```

**⚠️ Structural note**: Follow existing pack format exactly. Read `web-backend.yaml` for field ordering reference. The `tools-registry.yaml` entry format uses nested structure (`recommended.name`, `recommended.install`, `recommended.usage`, etc.) — NOT flat fields. Read the registry file before adding entries.

### 4.2 supply-chain-security Capabilities (from research)

| # | Capability | Type | Key Tools | Steps |
|---|-----------|------|-----------|-------|
| 1 | dependency_audit | B | osv-scanner, pip-audit, cargo-audit, syft | generate_sbom → detect_ecosystem → run_scanner → analyze_severity → generate_report |
| 2 | behavioral_analysis | B | socket CLI, dep-scan | select_packages → run_behavioral_scan → evaluate_risk_signals → generate_decision |
| 3 | provenance_verification | B | cosign, OSSF Scorecard, syft | check_signatures → verify_build_provenance → validate_publisher → score_trust |
| 4 | lockfile_integrity | B | lockfile-lint, npm audit | detect_lockfiles → validate_hashes → check_consistency → enforce_policy |
| 5 | typosquat_detection | B | typosquatting CLI, socket CLI | extract_dependencies → generate_variants → check_registries → cross_reference_sbom → alert_on_matches |

### 4.3 code-security Capabilities (from research)

| # | Capability | Type | Key Tools | Steps |
|---|-----------|------|-----------|-------|
| 1 | sast_scan | B | semgrep, bandit, codeql, bearer | detect_language → select_rules → execute_scan → map_to_cwe → prioritize_findings |
| 2 | dast_scan | B | ZAP, nuclei, nikto | configure_target → select_scan_type → execute_scan → correlate_with_sast → prioritize_exploitability |
| 3 | secret_detection | B | gitleaks, trufflehog, detect-secrets | select_detection_mode → configure_rules → execute_scan → verify_secrets → remediate_ordered |
| 4 | iac_security_lint | B | hadolint, checkov | detect_iac_files → select_linter → execute_lint → map_to_compliance → fail_or_warn |
| 5 | vulnerability_triage | A | (none — aggregation) | collect_reports → deduplicate → enrich_context → prioritize → generate_action_plan |

### 4.4 tools-registry.yaml Updates

Add these tools (organized by domain). Each entry must include:
- `name`, `category`, `install` (all platforms), `cli_usage` (actual command), `output_format`, `recommended` flag

**Supply Chain tools to add** (~12):
osv-scanner, pip-audit, cargo-audit, socket CLI, OSSF Scorecard, syft, lockfile-lint, cargo-vet, cosign, typosquatting CLI, dep-scan, npm audit

**Code Security tools to add** (~10):
semgrep, bandit, codeql, bearer CLI, ZAP, nikto, nuclei, gitleaks, trufflehog, detect-secrets, hadolint

**Note**: checkov already may need adding but is shared with compliance — add it now, compliance pack will reference it.

### 4.5 Domain Boundary Rules

| This Pack Owns | This Pack Does NOT Own |
|---------------|----------------------|
| supply-chain: pre-install trust analysis | post-install CVE monitoring (→ security-monitoring) |
| code-security: SAST + DAST + secrets + IaC lint | compliance proof (→ compliance) |
| code-security: vulnerability_triage (Type A) | runtime protection / RASP (out of CLI scope) |

---

## 5. 强制问题回答

### MQ1: 历史代码搜索
- [x] 是 — 需要参考现有 Domain Pack YAML 结构
- **参考**: web-backend.yaml, ai-evaluation.yaml（结构参考）
- **参考**: tools-registry.yaml（添加新工具条目）
- **决定**: ✅ 遵循现有 YAML 结构，新增安全 pack

### MQ2-MQ5: N/A — YAML 配置任务

---

## 6. Implementation Steps

### Phase 1: tools-registry.yaml Updates (预计 30 min)

#### 交付物
- [ ] tools-registry.yaml 更新，新增 ~22 个安全工具条目

#### 实施步骤
1. 读取 security-tool-evaluation-matrix.md 获取完整工具列表
2. 读取现有 tools-registry.yaml 了解条目格式
3. 为每个工具创建条目（install, cli_usage, output_format, recommended）
4. CLI usage 示例从研究文件中获取（不要编造）

### Phase 2: supply-chain-security.yaml (预计 1 小时)

#### 交付物
- [ ] .tad/domains/supply-chain-security.yaml

#### 实施步骤
1. 读取 security-supply-chain-research.md 的 §4 Capability Design
2. 创建 YAML，遵循 §4.1 结构模板
3. 5 个 capabilities，每个 ≥4 steps with tool_ref
4. 添加 review persona + checklist
5. 添加 anti_patterns（从研究文件 §5 获取）
6. 添加 description 含 scope 声明

### Phase 3: code-security.yaml (预计 1 小时)

#### 交付物
- [ ] .tad/domains/code-security.yaml

#### 实施步骤
1. 读取 security-code-security-research.md 的 §4 Capability Design
2. 创建 YAML，遵循 §4.1 结构模板
3. 5 个 capabilities（4 Type B + 1 Type A）
4. 添加 SAST vs DAST coverage matrix 作为 reference section
5. 添加 review persona + checklist
6. 添加 anti_patterns

---

## 7. File Structure

### 7.1 Files to Create
```
.tad/domains/supply-chain-security.yaml
.tad/domains/code-security.yaml
```

### 7.2 Files to Modify
```
.tad/domains/tools-registry.yaml  # Add ~22 new tool entries
```

---

## 8. Testing Requirements

### 8.1 YAML Validity
- Both YAML files parse without errors
- All tool_ref names exist in tools-registry.yaml

### 8.2 Structural Completeness
- Each pack has: name, version, description, domain, capabilities, review
- Each capability has: description, type, steps (≥4), quality_criteria, anti_patterns
- Each step has: id, action, tool_ref (where applicable)

### 8.3 Content Quality
- Steps contain actual CLI commands (not placeholders)
- quality_criteria are measurable
- anti_patterns are actionable

---

## 9. Acceptance Criteria

- [ ] AC1: supply-chain-security.yaml created with 5 capabilities, ≥500 lines
- [ ] AC2: code-security.yaml created with 5 capabilities, ≥500 lines
- [ ] AC3: tools-registry.yaml updated with ≥20 new tool entries
- [ ] AC4: All tool_ref in YAML packs resolve to tools-registry entries
- [ ] AC5: Each capability has ≥4 steps with detailed action descriptions
- [ ] AC6: Each pack has review persona + checklist section
- [ ] AC7: YAML syntax valid (no parse errors on both files)
- [ ] AC8: Description includes scope boundary declaration
- [ ] AC9: anti_patterns section present in each capability (≥2 per capability)
- [ ] AC10: DOMAIN-PACK-ROADMAP.md Phase 5 table updated with new pack status + line counts

## 9.1 Spec Compliance Checklist

| # | Acceptance Criterion | Verification Method | Expected Evidence |
|---|---------------------|--------------------|--------------------|
| 1 | supply-chain YAML ≥500 lines | `wc -l` | ≥500 |
| 2 | code-security YAML ≥500 lines | `wc -l` | ≥500 |
| 3 | ≥20 new tools in registry | count new entries | ≥20 |
| 4 | tool_ref resolution | grep tool_ref names → check registry | All resolve |
| 5 | ≥4 steps per capability | count steps per capability | All ≥4 |
| 6 | Review section exists | grep "review:" | Present in both files |
| 7 | YAML parse | python/node YAML parse | No errors |
| 8 | Scope boundary in description | grep "Scope:" or boundary text | Present |
| 9 | Anti-patterns per capability | count anti_patterns entries | ≥2 per capability |
| 10 | Roadmap updated | read DOMAIN-PACK-ROADMAP.md | Phase 5 entries updated |

---

## 10. Important Notes

### 10.1 Critical Warnings
- ⚠️ DO NOT duplicate web-deployment.yaml's security_hardening capability
- ⚠️ CLI commands in steps must be real — copy from research files, don't invent
- ⚠️ tools-registry entries need install commands for BOTH macOS (brew) and Linux (apt/pip)

### 10.2 Secret Remediation — Correct Order (P0 fix from expert review)

⚠️ The research file's `remediate_and_rotate` step has a DANGEROUS ordering. In the YAML pack, the `remediate_ordered` step for secret_detection MUST follow this sequence:
1. **Immediately rotate the compromised credential** (assume it is already exfiltrated)
2. Remove from code and add pattern to `.gitignore` / `.gitleaks.toml` allowlist
3. If secret was committed to git history: purge with `git filter-repo` or BFG Repo-Cleaner
4. Update secret storage (vault/env/CI secrets)
5. Add pre-commit hook to prevent recurrence

DO NOT write "rotate, add to .gitignore, update vault" as equivalent actions. Rotation is always Step 1.

### 10.3 SBOM as Foundation (P0 fix from expert review)

The `dependency_audit` capability MUST include `generate_sbom` as its first step (before scanning). SBOM is the foundation artifact consumed by typosquat_detection's `cross_reference_sbom` and monitoring pack's inventory. Use syft for SBOM generation. Without this step, the pack assumes an SBOM already exists (which for most projects it does not).

### 10.4 Known Constraints
- Some tools have "unverified" star counts in research — keep as-is in registry
- checkov appears in both code-security (iac_security_lint) and future compliance pack — add once, reference from both
- lockfile_integrity ecosystem coverage is partial: full for npm/yarn, no equivalent for pip/go — document as known limitation in YAML

### 10.3 Sub-Agent使用建议
- [ ] **code-reviewer** — after completing each YAML file
- [ ] **parallel execution** — tools-registry, supply-chain, code-security can be written sequentially (registry first, then packs reference it)

---

## 11. Decision Rationale

### Cross-Domain Ecosystem Handling

In YAML steps, handle ecosystem detection via conditional action text:
```yaml
- id: detect_ecosystem
  action: |
    Scan project root for package manager files:
    - package.json / package-lock.json → npm ecosystem
    - requirements.txt / Pipfile / pyproject.toml → pip ecosystem
    - Cargo.toml / Cargo.lock → cargo ecosystem
    - go.mod / go.sum → go ecosystem
    Select appropriate scanner based on detected ecosystem.
  tool_ref: null  # Detection logic, no specific tool
```

This approach keeps one Pack covering all ecosystems without YAML duplication.

---

---

## Expert Review Status

| Expert | Assessment | P0 Fixed | Notes |
|--------|-----------|----------|-------|
| code-reviewer | CONDITIONAL PASS → PASS | 3/3 | Template fields, domain: key, research_required, registry format note |
| security-auditor | CONDITIONAL PASS → PASS | 3/3 | SBOM step, severity_policy, secret remediation order |

### P0 Issues Resolved
1. ~~`research_required: no` ambiguous~~ → Changed to `yes` with clarifying comment
2. ~~YAML template missing fields~~ → Added `domain:`, `requires_registry`, `output_dir`, `gates`, `output_structure`, `severity_policy`
3. ~~`name:` vs `domain:`~~ → Fixed to `domain:` matching existing packs
4. ~~SBOM generation unowned~~ → Added `generate_sbom` as step 0 in dependency_audit
5. ~~No severity_policy~~ → Added `severity_policy` section to template with pipeline gating thresholds
6. ~~Secret remediation order dangerous~~ → Added §10.2 with correct ordered sequence + renamed step

### Key P1 Items Addressed Inline
- Registry entry format mismatch → Added structural note in §4.1
- lockfile_integrity coverage gap → Added to §10.4 known constraints
- Tool count → Enumerated list is authoritative (24 tools)

### P1/P2 Items Deferred (non-blocking)
- P1: DAST auth workflow detail (Blake can add during YAML authoring from research)
- P1: vulnerability_triage input contract (SARIF normalization — v1.1)
- P1: ecosystem_coverage field per capability (v1.1)
- P2: SARIF standard output, pre-commit/CI context tags, K8s manifest coverage

---

**Handoff Created By**: Alex (Agent A)
**Date**: 2026-04-04
**Version**: 3.1.0
**Expert Review**: 2 experts (code-reviewer + security-auditor), all P0 resolved
