
# HANDOFF: security-tool-research

---
task_type: research
e2e_required: no
research_required: yes
---

---

## §9.1 Spec Compliance Checklist (excerpt)
## 9.1 Spec Compliance Checklist

---

## §6 Implementation Steps (head)
## 6. Implementation Steps

### Phase 1: Research 5 Domains (预计 2-3 小时)

#### 交付物
- [ ] security-supply-chain-research.md (≥150 lines)
- [ ] security-code-security-research.md (≥150 lines)
- [ ] security-ai-security-research.md (≥150 lines)
- [ ] security-compliance-research.md (≥150 lines)
- [ ] security-monitoring-research.md (≥150 lines)
- [ ] security-tool-evaluation-matrix.md

#### 实施步骤
1. 对每个领域，从 §4.2 种子列表出发
2. 用 WebSearch 搜索每个种子工具的最新状态（stars、last commit、version）
3. 搜索 "{domain} best practices github" 找额外的最佳实践仓库
4. 搜索 OWASP 对应框架的覆盖映射
5. 按 §4.4 模板写入研究文件
6. 每个领域推荐 3-5 个 capability（含 steps 设计）
7. 汇总所有工具到 security-tool-evaluation-matrix.md

#### ⚠️ 研究质量要求
- **禁止编造**: 工具 star 数、commit 日期必须来自 WebSearch 结果。如果搜不到，写 "未验证"
- **CLI 示例必须真实**: 命令格式从工具文档获取，不是猜测
- **每个 capability 至少 1 个 step with tool_ref**: 参考 architecture.md "Research > Quality Criteria Text" 教训
- **生态覆盖必须标注**: 每个工具覆盖哪些生态（npm/pip/cargo/go/multi）

#### Phase 1 完成证据（Blake必须提供）
- [ ] 6 个研究文件全部创建
- [ ] 每个文件 ≥150 行
- [ ] 每个领域有 3-5 个 capability 推荐
- [ ] 每个 capability 至少 1 个 step with tool_ref
- [ ] tool-evaluation-matrix 包含所有领域的工具对比

---

## 7. File Structure

---


# COMPLETION: security-tool-research

# Completion Report: Security Domain Pack — Phase 0 Tool Research

**Task ID**: TASK-20260403-014
**Handoff**: HANDOFF-20260403-security-tool-research.md
**Epic**: EPIC-20260403-security-domain-pack-chain.md (Phase 0/4)
**Date**: 2026-04-04
**Commit**: e2c325a

---

## Deliverables

| # | File | Lines | Status |
|---|------|-------|--------|
| 1 | security-supply-chain-research.md | 346 | Done |
| 2 | security-code-security-research.md | 410 | Done |
| 3 | security-ai-security-research.md | 336 | Done |
| 4 | security-compliance-research.md | 337 | Done |
| 5 | security-monitoring-research.md | 370 | Done |
| 6 | security-tool-evaluation-matrix.md | 189 | Done |

**Total**: 1,988 lines of structured research across 6 files.

---

## Key Findings

### Tools Researched: 40 unique tools across 5 domains

| Domain | Tool Count | Top Tools |
|--------|-----------|-----------|
| Supply Chain | 12 | osv-scanner, socket CLI, cosign, lockfile-lint |
| Code Security | 12 | semgrep, gitleaks, ZAP, trufflehog, hadolint |
| AI Security | 5 | promptfoo, garak, LLM Guard, NeMo Guardrails, PyRIT |
| Compliance | 8 | prowler, checkov, OPA/conftest, InSpec, kube-bench |
| Monitoring | 5+5 supporting | trivy, grype, renovate, nuclei, cdxgen |

### Critical Insights

1. **litellm-class attack gap**: Only socket CLI detects behavioral changes between package versions. All CVE-only scanners (osv-scanner, pip-audit, cargo-audit) are blind to zero-day supply chain poisoning.

2. **AI Security 3 hard gaps**: LLM03 (Supply Chain), LLM08 (Vector/Embedding), LLM10 (Unbounded Consumption) have ZERO CLI tool coverage. These require infrastructure-level solutions.

3. **Compliance CLI vs SaaS boundary**: CLI tools excel at technical proof (~60% of SOC2 controls). Organizational processes (auditor portal, vendor risk, HR compliance) require SaaS platforms (Drata/Vanta).

4. **Cross-domain overlap is intentional**: nuclei (DAST + network monitoring), checkov (IaC lint + compliance scan), syft (pre-install SBOM + post-install inventory) serve different purposes per domain.

### Capabilities Designed: 25 total (5 per domain)

All with Type A/B classification, ≥4 steps each, and tool_ref. Ready for Phase 1 YAML conversion.

---

## Quality Evidence

| Check | Result |
|-------|--------|
| Layer 1 (file checks) | PASS — all 6 files exist, ≥150 lines, template compliant |
| Layer 2 Group 0 (spec-compliance) | PASS — 10/10 ACs satisfied |
| Layer 2 Group 1 (code-reviewer) | PASS — 4 P0 fixed, 8 P1 noted for Phase 1 |
| Gate 3 Knowledge Assessment | 4 new discoveries recorded |

### P1 Items for Phase 1

- Checkov/nuclei domain boundary clarification in YAML
- Dependabot mention in monitoring domain
- Llama Guard and Privado in tool tables
- docker-bench star count verification
- comply (StrongDM) in tool table

---

## Deviations from Plan

None. All ACs met as specified in handoff.

---

## Next Steps (Phase 1)

Phase 1 of the Epic: Build 2 core Domain Pack YAMLs (supply-chain-security + code-security) using these research files as input. Requires new Alex handoff.

---

