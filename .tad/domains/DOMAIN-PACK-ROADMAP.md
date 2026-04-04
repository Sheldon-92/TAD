# Domain Pack Roadmap

> 目标：覆盖软件开发 + 移动端 + AI Agent + 硬件的完整链路。
> 基于用户实际项目需求排序。

---

## 全景进度

```
Web 链路:       想法 → 定义 → 设计 → 前端 → 后端 → 测试 → 部署
                 ✅     ✅     ✅     ✅     ✅     ✅     ✅

Mobile 链路:    想法 → 定义 → 设计 → 开发 → 测试 → 发布
                 ✅     ✅     ✅     ✅     ✅     ✅

AI/Agent 链路:  架构 → Prompt → 工具 → 评估
                 ✅      ✅      ✅     ✅

Hardware 链路:  概念 → 电路 → 固件 → 外壳 → 测试
                 ✅     ✅     ✅     ✅     ✅
                (复用)  (研究✅, E2E待跑)
```

---

## Phase 1: Web 全链路 ✅

| # | Pack | 状态 | 压力测试 | 行数 |
|---|------|------|---------|------|
| 1 | product-definition | ✅ | ✅ 深度迭代 | 407 |
| 2 | web-ui-design | ✅ | ✅ SaaS PM 7/7 | 744 |
| 3 | web-frontend | ✅ | ✅ SaaS PM 7/7 | 744 |
| 4 | web-backend | ✅ | ✅ SaaS Billing 7/7 | 756 |
| 5 | web-testing | ✅ | 🔲 | 669 |
| 6 | web-deployment | ✅ | 🔲 | 764 |

---

## Phase 2: Mobile 链路 ✅

| # | Pack | 状态 | 行数 |
|---|------|------|------|
| 7 | mobile-ui-design | ✅ | 710 |
| 8 | mobile-development | ✅ | 572 |
| 9 | mobile-testing | ✅ | 564 |
| 10 | mobile-release | ✅ | 607 |

---

## Phase 3: AI/Agent 链路 ✅

| # | Pack | 状态 | 行数 | 特殊 |
|---|------|------|------|------|
| 11 | ai-agent-architecture | ✅ | 1207 | 9 caps（含 self_improvement_design） |
| 12 | ai-prompt-engineering | ✅ | 720 | promptfoo 集成 |
| 13 | ai-tool-integration | ✅ | 708 | Claude Code Tool.ts 参考 |
| 14 | ai-evaluation | ✅ | 831 | 4D Protocol 扩展 |

---

## Phase 4: Hardware 链路 ⚠️ E2E 待跑

| # | Pack | 状态 | 行数 | 研究 | E2E |
|---|------|------|------|------|-----|
| 15 | hw-circuit-design | ✅ 结构+研究 | 917 | ✅ | 🔲 |
| 16 | hw-firmware | ✅ 结构+研究 | 1150 | ✅ | 🔲 |
| 17 | hw-enclosure | ✅ 结构+研究 | 880 | ✅ 补完 | 🔲 |
| 18 | hw-testing | ✅ 结构+研究 | 1088 | ✅ 补完 | 🔲 |

**历史**：hw-enclosure 和 hw-testing 最初跳过 Phase 1 研究，已通过 HANDOFF-20260403-hw-research-supplement 补完（4 pack 全部 +4 steps +2 tools）。E2E 压力测试尚未执行。

---

## Phase 5: 安全链路 🔲（Epic 级）

**驱动力**：供应链投毒频发（litellm 1.82.7/1.82.8 事件）、AI 时代开源工具大量使用、合规AI 项目需求。

```
安全链路:  依赖审计 → 代码安全 → AI 安全 → 合规 → 监控
              ✅         ✅        🔲      🔲     🔲
```

| # | Pack | 状态 | 行数 | 做什么 | 关键场景 |
|---|------|------|------|--------|---------|
| 20 | **supply-chain-security** | ✅ | 639 | 依赖审计、行为分析、来源验证、lock 文件、typosquat | npm/pip/cargo 依赖安全 |
| 21 | **code-security** | ✅ | 873 | SAST+DAST、Secret 检测、IaC lint、漏洞分诊 | Web/API 代码安全 |
| 22 | **ai-security** | Prompt injection、数据泄露、模型滥用、输出安全 | LLM 应用安全 |
| 23 | **compliance** | GDPR、SOC2、HIPAA、App Store 合规、隐私政策 | 企业/产品合规 |
| 24 | **security-monitoring** | 漏洞扫描、依赖更新监控、安全告警 | 持续安全 |

**你的真实经验**：2026-03-24 litellm 投毒事件，你安装的 1.82.6 刚好躲过。这种经验应该内化到 supply-chain-security pack 里。

---

## Phase 6: CLI 工具开发 🔲

| # | Pack | 状态 |
|---|------|------|
| 19 | cli-tool-development | 🔲 按需 |

---

## Phase 7: 按需扩展

| Pack | 触发条件 | 对应项目 |
|------|---------|---------|
| content-creation | Sober Creator 做内容时 | Sober Creator |
| data-engineering | 需要数据管线时 | 通用 |
| game-development | 概念验证成熟时 | 个人兴趣 |
| desktop-app | 需要桌面应用时 | 暂无需求 |

---

## 全部 Pack 状态汇总

| # | Pack | 阶段 | 状态 | 行数 | 工具数 |
|---|------|------|------|------|--------|
| 1 | product-definition | Web | ✅ | 407 | 通用 |
| 2 | web-ui-design | Web | ✅ | 744 | +4 |
| 3 | web-frontend | Web | ✅ | 744 | +8 |
| 4 | web-backend | Web | ✅ | 756 | +4 |
| 5 | web-testing | Web | ✅ | 669 | +5 |
| 6 | web-deployment | Web | ✅ | 764 | +4 |
| 7 | mobile-ui-design | Mobile | ✅ | 710 | +0 |
| 8 | mobile-development | Mobile | ✅ | 572 | +4 |
| 9 | mobile-testing | Mobile | ✅ | 564 | +0 |
| 10 | mobile-release | Mobile | ✅ | 607 | +3 |
| 11 | ai-agent-architecture | AI | ✅ | 1207 | +0 |
| 12 | ai-prompt-engineering | AI | ✅ | 720 | +2 |
| 13 | ai-tool-integration | AI | ✅ | 708 | +0 |
| 14 | ai-evaluation | AI | ✅ | 831 | +0 |
| 15 | hw-circuit-design | HW | ✅ 研究完成, E2E 待跑 | 917 | +4 |
| 16 | hw-firmware | HW | ✅ 研究完成, E2E 待跑 | 1150 | +0 |
| 17 | hw-enclosure | HW | ✅ 研究完成, E2E 待跑 | 880 | +0 |
| 18 | hw-testing | HW | ✅ 研究完成, E2E 待跑 | 1088 | +0 |
| 19 | cli-tool-development | CLI | 🔲 | — | — |
| 20 | supply-chain-security | Security | ✅ | 639 | +12 |
| 21 | code-security | Security | ✅ | 873 | +12 |
| 22 | ai-security | Security | 🔲 | — | — |
| 23 | compliance | Security | 🔲 | — | — |
| 24 | security-monitoring | Security | 🔲 | — | — |
| — | tools-registry | 共享 | 持续更新 | 1911 | 78 |

**总计**: 20 个 pack 完成（4 个 E2E 补跑中），4 个待做（1 CLI + 3 Security）

---

*Last updated: 2026-04-04*
