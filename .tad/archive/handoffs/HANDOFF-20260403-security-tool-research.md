---
task_type: research
e2e_required: no
research_required: yes
---

# Handoff: Security Domain Pack — Phase 0 Tool Research

**From:** Alex (Agent A - Solution Lead)
**To:** Blake (Agent B - Execution Master)
**Date:** 2026-04-03
**Project:** TAD Framework
**Task ID:** TASK-20260403-014
**Handoff Version:** 3.1.0
**Epic:** EPIC-20260403-security-domain-pack-chain.md (Phase 0/4)

---

## 🔴 Gate 2: Design Completeness

**执行时间**: 2026-04-03

### Gate 2 检查结��

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Architecture Complete | ✅ | 5-domain research structure defined |
| Components Specified | ✅ | Per-domain research template with 5 dimensions |
| Functions Verified | ✅ | N/A (research task, no code functions) |
| Data Flow Mapped | ✅ | Research → tool-evaluation-matrix → capability-recommendations |

**Gate 2 结果**: ✅ PASS

**Alex确认**: 我已验证所有设计要素，Blake可以独立根据本文档完成实现。

---

## 📋 Handoff Checklist (Blake必读)

- [ ] 阅读了所有章节
- [ ] **阅读了「📚 Project Knowledge」章节中的历史经验**
- [ ] 所有"强制问题回答（MQ）"都有证据
- [ ] 理解了真正意图（不只是字面需求）
- [ ] 每个Phase的交付物和证据要求都清楚
- [ ] 确认可以独立使用本文档完成实现

---

## 1. Task Overview

### 1.1 What We're Building
Research files for 5 security domains: supply-chain-security, code-security, ai-security, compliance, security-monitoring. Each research file evaluates CLI tools, GitHub best-practice repos, and OWASP/CWE frameworks to inform Domain Pack capability design.

### 1.2 Why We're Building It
**业务价值**：为 5 个安全 Domain Pack 建立可靠的研究基础，避免重蹈 HW Pack 跳过研究导致质量不足的教训
**用户受益**：基于研究的 Pack 能产出真正有用的安全审计结果，不是浅层 checklist
**成功的样子**：当研究文件能回答"这个安全领域该用什么工具、遵循什么框架、怎么设计 capability workflow"时，就成功了

### 1.3 Intent Statement

**真正要解决的问题**：为后续 Phase 1-3 的 YAML Pack 编写提供可靠的知识基础。

**不是要做的（避免误���）**：
- ❌ 不是�� Domain Pack YAML（那是 Phase 1-3 的事）
- ❌ 不是安装或测试工具（研究工具能力，不验证安装）
- ❌ 不是写安全教程（研究服务于 Pack 设计，不是独立文档）

---

## 📚 Project Knowledge（Blake 必读）

### 步骤 1：识别相关类别
- [x] architecture - Domain Pack 设计模式
- [x] security - 现有安全基础设施

### 步骤 2：历史经验摘录

| 文件 | 相关记录数 | 关键提醒 |
|------|-----------|----------|
| architecture.md | 3 条 | Domain Pack Step Model (A/B/Mixed), Research > Quality Criteria Text, Tool Freshness |

**⚠️ Blake 必须注意的历史教训**：

1. **Domain Pack Research: Workflow Steps > Quality Criteria Text** (architecture.md, 2026-04-03)
   - 问题：第一轮研究只加了 quality_criteria 文本，质量不足
   - 解决方案：每个 pack 至少 1 个新 workflow step，优先 step with tool_ref > step without tool > anti_pattern > quality_criteria text

2. **Domain Pack Must Declare Tool Availability Boundaries** (architecture.md, 2026-04-02)
   - 问题：mobile-testing 命名广泛但只覆盖 iOS，造成误导
   - 解决方案：研究时标注每个工具的平台/生态覆盖范围，Pack 描述声明工具边界

3. **Tool Freshness Problem** (feedback memory)
   - 问题：Claude 不认识新工具，只列名字没用
   - 解决方案：研究文件必须包含 install 命令、CLI usage pattern、output format 示例

---

## 2. Background Context

### 2.1 Previous Work
- Alex 已完成初步工具生态研究（见本 handoff §4 的工具种子列表）
- 已有 security-audit SKILL.md（P0-P3 checklist）和 security-review-format.md 输出模板
- web-deployment pack 已有 security_hardening capability（不重复）
- 全局 CLAUDE.md 有包安装安全原则（litellm 事件经验）

### 2.2 Current State
- 18 个 Domain Pack 已完成（Web 6 + Mobile 4 + AI 4 + HW 4）
- tools-registry.yaml 有 54 个工具，暂无安全专用工具
- 安全领域无 Domain Pack YAML

### 2.3 Dependencies
- WebSearch 工具可用（搜索 GitHub repos）
- 不需要安装任何工具（纯研究）

---

## 3. Requirements

### 3.1 Functional Requirements
- FR1: 5 个研究文件，每个 ≥150 行
- FR2: 每个研究文件覆盖 5 个维度（工具评估、框架对齐、最佳实践、能力设计建议、反模式）
- FR3: 汇总 tool-evaluation-matrix.md（所有工具的对比表）
- FR4: 每个领域识别 3-5 个 capability 候选，含推荐 workflow steps
- FR5: 标注工具的生态覆盖（npm/pip/cargo/go/multi）

### 3.2 Non-Functional Requirements
- NFR1: 研究基于真实 WebSearch 数据，禁止编造工具特性或 star 数
- NFR2: 每个工具的 CLI 用法必须包含实际命令示例
- NFR3: 研究文件格式统一（见 §4 模板）

---

## 4. Technical Design

### 4.1 Research Methodology

每个领域按以下 5 维度研究：

```
维度 1: Tool Landscape（工具全景）
  - 搜索 GitHub: "{domain} CLI tool" / "{domain} scanner open source"
  - 评估: 活跃度(最近 commit)、star 数、安装方式、免费/付费
  - 输出: 工具对比表

维度 2: Framework Alignment（框架对齐）
  - OWASP Top 10 (2021) / OWASP LLM Top 10 / CWE / ASVS 4.0.3 (L1-L3 chapters V1-V14) / NIST SSDF
  - 额外框架: MITRE ATT&CK (for monitoring), MITRE ATLAS (for AI security), OWASP SAMM (for compliance), SANS CWE Top 25
  - 映射: 哪个工具覆盖哪些框架条目（按 ASVS chapter 级别，不仅是 Top 10 类别）
  - 现有 security-audit SKILL.md 已映射 ASVS L1/L2/L3 — 新研究必须建立在此基础上
  - 输出: 覆盖矩阵

维度 3: Best Practices（最佳实践）
  - 搜索 GitHub: "{domain} best practices" / "{domain} checklist"
  - 提取: 可操作的检查步骤（不是理论）
  - 输出: 最佳实践清单

维度 4: Capability Design Recommendations（能力设计）
  - 基于维度 1-3，推荐 3-5 个 capability
  - 每个 capability: name, steps (Type A or B), tool_ref, quality_criteria
  - 标注哪些是 Type A (文档/分析) vs Type B (工具执行)

维度 5: Anti-Patterns & Pitfalls（反模式）
  - 常见安全审计错误
  - 工具误用模式
  - 输出: anti_patterns 列表
```

### 4.2 Tool Seed List (from Alex's research)

Alex 已完成初步工具扫描，以下是每个领域的种子工具列表。Blake 研究时以此为起点，可以增删：

**Supply Chain Security:**
| Tool | Install | Primary Use |
|------|---------|-------------|
| osv-scanner | brew/go | Multi-ecosystem vuln scanner (Google) |
| pip-audit | pip | Python dependency audit (PyPA) |
| cargo-audit | cargo | Rust dependency audit (RustSec) |
| socket CLI | npm | Behavioral analysis of packages (network calls, fs writes, eval) |
| OSSF Scorecard | brew | Project health scoring (OpenSSF) |
| syft | brew | SBOM generation (Anchore) |
| npm audit | built-in | Node.js dependency audit |
| lockfile-lint | npm | Lock file integrity verification |
| cargo-vet | cargo | Supply chain audits (Mozilla) |
| cosign (sigstore) | brew | Package signing / provenance verification |
| typosquat | pip | Typosquatting package name detection |
| dep-scan | pip | OWASP SCA multi-ecosystem scanner |

**⚠️ litellm-class attack coverage**: The litellm 1.82.7/1.82.8 poisoning (2026-03-24) was a trusted-package-hijack — malicious code injected into a version update of a legitimate popular package. CVE scanners miss this. Research MUST explicitly evaluate: (1) which tools detect behavioral changes between versions, (2) provenance verification (was the publisher the expected author?), (3) lock file hash integrity checking.

**Code Security:**
| Tool | Install | Primary Use |
|------|---------|-------------|
| semgrep | pip/brew | Multi-language SAST (2000+ free rules, YAML-based) |
| gitleaks | brew | Secret detection in git repos |
| trufflehog | brew | Deep secret scanning (history + verification) |
| bearer CLI | brew | OWASP-aligned data flow analysis |
| bandit | pip | Python-specific SAST |
| detect-secrets | pip | Pre-commit secret baseline (Yelp) |
| ZAP (OWASP) | brew/docker | DAST — dynamic application security testing (25k+ stars) |
| nikto | brew/perl | Web server DAST scanner |
| codeql | gh extension | GitHub-native SAST with query language (free for public repos) |
| hadolint | brew | Dockerfile security linting |

**Note**: Code-security covers both SAST (static, semgrep/bandit) AND DAST (dynamic, ZAP/nikto). IaC security linting (hadolint, kube-linter) also belongs here — "find the vulnerability." Compliance pack owns "prove you meet the policy."

**AI Security:**
| Tool | Install | Primary Use |
|------|---------|-------------|
| garak | pip | LLM red-teaming (50+ probes, NVIDIA) |
| promptfoo | npm | Eval + red-teaming (`promptfoo redteam`) |
| PyRIT | pip | Systematic prompt injection testing (Microsoft) |
| NeMo Guardrails | pip | Runtime guardrails framework (NVIDIA) |
| LLM Guard | pip | Input/output guardrails (Protect AI) |

**⚠️ AI Security coverage**: Do NOT claim "~70%" of OWASP LLM Top 10 covered. Instead, produce an explicit gap matrix mapping each LLM01-LLM10 item to tool coverage. Known gaps include LLM03 (Training Data Poisoning), LLM05 (Supply Chain — cross-ref supply-chain pack), LLM10 (Model Theft). Be honest about what CLI tools cannot address.

**Compliance:**
| Tool | Install | Primary Use |
|------|---------|-------------|
| OPA (rego) | brew | Policy-as-code engine (CNCF) |
| conftest | brew | Config file policy testing (OPA-based) |
| checkov | pip | IaC compliance scanning (1000+ policies, CIS/SOC2/HIPAA) |
| fides | pip | Privacy engineering / GDPR data mapping |
| InSpec | gem | Compliance-as-code (SOC2 evidence) |
| prowler | pip | Cloud security + compliance (CIS/HIPAA/PCI/SOC2/GDPR, 9k+ stars) |
| kube-bench | brew/go | CIS Kubernetes benchmark |
| docker-bench-security | docker | CIS Docker benchmark |

**Note**: Compliance pack owns "prove you meet the policy." For cloud-heavy projects, prowler is the multi-framework CLI leader. Note that compliance requirements vary by cloud provider — research should flag where cloud-provider variants are needed (distinct from language-ecosystem variants).

**Security Monitoring:**
| Tool | Install | Primary Use |
|------|---------|-------------|
| trivy | brew | Swiss-army scanner (containers, fs, IaC, SBOM) |
| grype | brew | Fast vulnerability scanner (Anchore) |
| renovate | npm | Dependency update automation |
| nuclei | brew | HTTP-based vuln scanning (9000+ templates) |
| cdxgen | npm | Multi-ecosystem SBOM generation |

### 4.3 Domain Boundary Clarification

| Pack | Core Question | Owns | Does NOT Own |
|------|--------------|------|-------------|
| supply-chain-security | "Should I trust this dependency?" | Pre-install analysis: behavioral, provenance, typosquat, lock file integrity | Post-install CVE monitoring (→ monitoring) |
| code-security | "Does my code have vulnerabilities?" | SAST + DAST + secrets + IaC linting | Policy compliance proof (→ compliance) |
| ai-security | "Is my LLM app safe?" | Prompt injection, output safety, red-teaming | Model training security (out of CLI scope) |
| compliance | "Can I prove I meet the policy?" | Policy-as-code, audit evidence, privacy | Finding vulnerabilities (→ code-security) |
| security-monitoring | "Are my existing deps still safe?" | Post-install CVE scanning, SBOM inventory, update automation, runtime detection | Pre-install trust decisions (→ supply-chain) |

### 4.4 Output File Structure

**Naming note**: Prior research files used `{area}-tool-research.md` + `{area}-skills-best-practices.md` (two files per domain). This handoff intentionally merges into one file per domain using a 5-dimension template that covers both tool evaluation and best practices. This reduces file count from 10 to 5 while maintaining depth via the structured template.

```
.tad/spike-v3/domain-pack-tools/
├── security-supply-chain-research.md    (≥150 lines)
├── security-code-security-research.md   (≥150 lines)
├── security-ai-security-research.md     (≥150 lines)
├── security-compliance-research.md      (≥150 lines)
├── security-monitoring-research.md      (≥150 lines)
└── security-tool-evaluation-matrix.md   (cross-domain comparison)
```

### 4.4 Research File Template

Each research file should follow this structure:

```markdown
# {Domain} — Security Domain Pack Research

## 1. Tool Landscape

| Tool | Stars | Last Commit | Install | Free | CI/CD | Ecosystems |
|------|-------|-------------|---------|------|-------|------------|
| osv-scanner | 6.2k | 2026-03 | brew install osv-scanner | Yes | Yes | multi |
| tool-x | unverified | unverified | pip install tool-x | Yes | No | Python |

(If WebSearch returns no data for a field, write "unverified" in that cell. Never guess or estimate.)

### CLI Usage Examples
(for each recommended tool, show actual command + expected output format)

## Search Log

| # | Query | Results Used | Date |
|---|-------|-------------|------|
| 1 | "{tool} github stars 2026" | {url1}, {url2} | {date} |
| 2 | "{domain} best practices github" | {url} | {date} |

(Every WebSearch query must be logged here. Tool stats without a Search Log entry = unverified.)

## 2. Framework Alignment

Map tools to ASVS chapters (V1-V14), not just OWASP Top 10 categories:

| Framework | Item | Tool Coverage | Gap |
|-----------|------|--------------|-----|
| OWASP Top 10 | A01:2021 Broken Access | semgrep rule X | — |
| ASVS 4.0.3 | V2 Authentication | {tool} | {gap or covered} |
| NIST SSDF | PO.1 | {tool} | {gap or covered} |
| ... | ... | ... | ... |

## 3. Best Practices (from GitHub repos)

### Source: {repo_name} ({url})
- Practice 1: ...
- Practice 2: ...

## 4. Capability Design Recommendations

### Capability: dependency_audit (EXAMPLE — show this level of detail)
- Type: B (tool execution)
- Steps:
  1. detect_ecosystem: Scan project for package manager files (package.json, requirements.txt, Cargo.toml, go.mod)
  2. run_scanner: Execute ecosystem-appropriate scanner (osv-scanner / pip-audit / cargo-audit)
  3. analyze_severity: Filter by CRITICAL/HIGH, check if fix version exists
  4. generate_report: Produce structured audit report with remediation paths
- tool_ref: [osv_scanner, pip_audit, cargo_audit]
- quality_criteria: ["all HIGH/CRITICAL CVEs have remediation path", "SBOM generated"]

### Capability: {name}
- Type: A (document) / B (tool execution)
- Steps: (at least 3 steps, each with action description — see example above)
- tool_ref: [tool1, tool2]
- quality_criteria: [...]

## 5. Anti-Patterns & Pitfalls
- Anti-pattern 1: ...
- Anti-pattern 2: ...
```

---

## 5. 强制问题回答（Evidence Required）

### MQ1: 历史代码搜索
- [x] 是 — 用户提到"已有 security-audit SKILL.md"
- **找到了**: `.tad/skills/security-audit/SKILL.md` (P0-P3 checklist)
- **找到了**: `.tad/templates/output-formats/security-review-format.md`
- **找到了**: web-deployment.yaml 的 security_hardening capability
- **决定**: ✅ 新 Pack 深化这些内容，不替代

### MQ2: 函数存在性验证
- [x] N/A — 纯研究任务，无代码函数

### MQ3-MQ5: 数据流 / 视觉层级 / 状态同步
- [x] N/A — 纯研究任务

---

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

### 7.1 Files to Create
```
.tad/spike-v3/domain-pack-tools/security-supply-chain-research.md
.tad/spike-v3/domain-pack-tools/security-code-security-research.md
.tad/spike-v3/domain-pack-tools/security-ai-security-research.md
.tad/spike-v3/domain-pack-tools/security-compliance-research.md
.tad/spike-v3/domain-pack-tools/security-monitoring-research.md
.tad/spike-v3/domain-pack-tools/security-tool-evaluation-matrix.md
```

### 7.2 Files to Modify
```
(none — Phase 0 is pure research, no existing file modifications)
```

---

## 8. Testing Requirements

### 8.1 Research Quality Check
- Each research file follows the template in §4.4
- Each tool has install command + CLI usage example
- Each capability recommendation has Type (A/B) + steps + tool_ref

### 8.2 Completeness Check
- All 5 domains covered
- Cross-domain matrix complete
- No domain has fewer than 3 capability recommendations

---

## 9. Acceptance Criteria

- [ ] AC1: 5 research files created, each ≥150 lines
- [ ] AC2: Each file covers all 5 dimensions (tool landscape, framework alignment, best practices, capability design, anti-patterns)
- [ ] AC3: security-tool-evaluation-matrix.md created with cross-domain comparison
- [ ] AC4: Each domain has 3-5 capability recommendations with step design (≥3 steps each) + tool_ref
- [ ] AC5: Each file has a Search Log table documenting every WebSearch query. All tool stats cite a Search Log entry or are marked "unverified"
- [ ] AC6: CLI usage examples are real (from tool docs, not invented)
- [ ] AC7: Ecosystem coverage labeled for each tool (npm/pip/cargo/go/multi)
- [ ] AC8: Anti-patterns section populated for each domain (≥3 per domain)
- [ ] AC9: Framework mapping includes ASVS chapters (V1-V14), not just OWASP Top 10 categories
- [ ] AC10: AI security file includes explicit OWASP LLM Top 10 gap matrix (LLM01-LLM10 vs tool coverage)

## 9.1 Spec Compliance Checklist

| # | Acceptance Criterion | Verification Method | Expected Evidence |
|---|---------------------|--------------------|--------------------|
| 1 | 5 research files ≥150 lines | `wc -l` on each file | Each shows ≥150 |
| 2 | 5 dimensions + Search Log | grep for "## 1. Tool" "## 2. Framework" "## 3. Best" "## 4. Capability" "## 5. Anti" "## Search Log" | All 6 headers present per file |
| 3 | Matrix file exists | file check | security-tool-evaluation-matrix.md exists |
| 4 | 3-5 capabilities per domain | grep "### Capability:" | 3-5 matches per file |
| 5 | tool_ref in capabilities | grep "tool_ref:" | ≥1 per capability |
| 6 | Search Log populated | grep "Search Log" + check table has rows | ≥5 queries per file |
| 7 | Ecosystem labels | grep "Ecosystems" in matrix | Column present with values |
| 8 | Anti-patterns ≥3 per domain | count items in section 5 | ≥3 per file |
| 9 | ASVS mapping | grep "ASVS" in each file | Present in Framework Alignment |
| 10 | LLM gap matrix | grep "LLM0" in ai-security file | LLM01-LLM10 all listed |

---

## 10. Important Notes

### 10.1 Critical Warnings
- ⚠️ AI Security tools are immature — produce explicit LLM01-LLM10 gap matrix, do NOT estimate a % coverage number
- ⚠️ Compliance CLI tools are scarce — Drata/Vanta are SaaS-only, note this limitation
- ⚠️ Do NOT overlap with web-deployment.yaml's security_hardening capability

### 10.2 Known Constraints
- Research only — no tool installation, no YAML Pack creation
- WebSearch may have rate limits — prioritize highest-value searches
- Some tools may have changed since Alex's initial scan — verify current status

### 10.3 Sub-Agent使用建议
- [ ] **general-purpose (Explore)** — for deep WebSearch on each domain
- [ ] Parallel research agents recommended — 5 domains can be researched concurrently. If WebSearch rate limits hit, fall back to sequential. Prioritize supply-chain + code-security first (feed Phase 1)

---

## 11. Decision Rationale

### Cross-Domain Design: 通用 Pack + 生态变体

**选择的方案**: 一个 Pack 内用 tool_ref 适配不同生态

**考虑的替代方案**:

| 方案 | 优点 | 缺点 | 为什么没选 |
|------|------|------|-----------|
| 通用+生态变体（选中）| 一个 Pack 覆盖所有生态，维护成本低 | step 内需要条件分支 | ✅ 选中 |
| 分生态包 | 每个包更简洁 | Pack 数量爆炸（5×4=20），维护噩梦 | 维护成本过高 |
| 完全通用 | 最简单 | 无法针对生态给出具体命令 | 太浅，违背 Tool Freshness 原则 |

### Integration: 独立工具 + 流程集成

**选择的方案**: Pack 可独立运行 + 被 Gate/security-auditor 引用

**理由**: 安全审计既需要独立运行能力（用户主动发起审计），也需要被 TAD 流程自动引用（Gate 3 的 security-auditor 条件触发）。现有 security-audit SKILL.md 提供集成接口。

---

---

## Expert Review Status

| Expert | Assessment | P0 Fixed | P1 Addressed | Notes |
|--------|-----------|----------|-------------|-------|
| code-reviewer | CONDITIONAL PASS → PASS | 3/3 | 5/7 key items | Search Log, naming note, unverified handling, line min raised |
| security-auditor | CONDITIONAL PASS → PASS | 3/3 | 4/5 key items | DAST tools, provenance tools, ASVS mapping, LLM gap matrix |

### P0 Issues Resolved
1. ~~Naive grep fabrication check~~ → Replaced with Search Log requirement (proven HW pattern)
2. ~~Naming convention unexplained~~ → Added §4.4 naming note explaining intentional merge
3. ~~Unverified handling missing~~ → Added example row with "unverified" in template
4. ~~DAST missing from code-security~~ → Added ZAP, nikto, codeql, hadolint to seed list
5. ~~Supply chain lacks behavioral/provenance tools~~ → Added 5 tools + litellm-class attack note
6. ~~ASVS mapping too vague~~ → Added explicit ASVS V1-V14 chapter mapping to template + AC9

### Key P1 Items Addressed
- Supply-chain vs monitoring boundary defined (§4.3 Domain Boundary table)
- AI security ~70% claim replaced with "produce explicit gap matrix" (AC10)
- Capability example added to template (dependency_audit with 4 steps)
- Line minimum raised from 100 → 150
- Missing tools added: prowler, kube-bench, docker-bench, LLM Guard, dep-scan
- Rate limit fallback guidance added

### P1/P2 Items Deferred (non-blocking for Phase 0 research)
- P2: Container security pack consideration (future Phase 5+ decision)
- P2: RASP/runtime boundary statement (noted in monitoring domain boundary)
- P2: .NET/Java ecosystem coverage (Blake can discover during research)
- P2: Threat modeling tools (pytm, threagile — Blake can add if found)

---

**Handoff Created By**: Alex (Agent A)
**Date**: 2026-04-03
**Version**: 3.1.0
**Expert Review**: 2 experts (code-reviewer + security-auditor), all P0 resolved
