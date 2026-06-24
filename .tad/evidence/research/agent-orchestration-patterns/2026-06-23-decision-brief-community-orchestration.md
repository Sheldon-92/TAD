## 决策简报: Agent Orchestration Patterns in the Wild (AI Tinkerers #32)

**决策问题**: 关于 AI agent skill orchestration 和编排框架（SPEAR/Gryter/Inhabited-design/Maestro），社区有哪些主流方案，各自的编排思路、架构选择和局限是什么？

**研究日期**: 2026-06-23
**降级说明**: NotebookLM API RPC 错误，降级为 WebSearch + 直接素材分析
**来源**: AI Tinkerers Issue #32 (2026-06-22) + SPEAR 文章 (edge.ceo) + 4 个 WebSearch 调查

---

### 关键发现

**四种编排范式同时出现：**

| 范式 | 代表 | 核心机制 | TAD 对标 |
|------|------|---------|---------|
| **Gate-Loop** | SPEAR | Scope→Plan→Execute→Assess→Resolve，MECE rubric 驱动迭代 | TAD 四门 + Ralph Loop |
| **Skill-File Orchestration** | Gryter | 12 个 .md skill + scoped subagents + CLAUDE.md | TAD SKILL.md + subagent shortcuts |
| **Adversarial Iteration** | Inhabited-design | ICP 锚定 + inspiration bank + adversarial critique loop | TAD anti-rationalization + Feedback Collector |
| **MCP Composition** | Maestro | 独立 package 通过 MCP 组合，Fast MCP 包装 REST | TAD 目前不走这条路（skill-based，非 MCP-based） |

### 证据

- **SPEAR vs TAD**: SPEAR 的 Assess 阶段用 MECE rubric（二元 pass/fail），TAD 的 Gate 系统也是 pass/fail 但分 4 个检查点而非单一 rubric。SPEAR 的内循环（Plan→Execute→Assess）本质上和 TAD 的 Ralph Loop（Layer 1 self → Layer 2 expert）解决同一问题：防止 one-shot 交付。区别：SPEAR 是单代理自循环，TAD 是双代理跨终端。SPEAR 声称 500k+ 行近生产代码来自 24/7 循环，2-3 秒/轮开销。

- **Gryter vs TAD**: 最接近 TAD 的社区实现。12 skill files + CLAUDE.md = TAD 的 SKILL.md + config.yaml 的简化版。关键差异：Gryter 是单代理（Claude Code 自身编排），TAD 是双代理分离（Alex 设计 / Blake 执行）。Gryter 证明了一点：skill file 编排已经是社区验证的模式，不是 TAD 独创。

- **Inhabited-design vs TAD**: adversarial critique 防 "generic slop" = TAD 的 anti-rationalization registry + expert review 的理念。但 Inhabited-design 更聚焦（只做 UI design），用 ICP（理想客户画像）锚定设计方向，这个"先定义给谁用再设计"的思路 TAD 的 Feedback Collector 没有。

- **Maestro vs TAD**: MCP 作为组合层是完全不同的架构选择。TAD 通过 skill file + subagent 编排，Maestro 通过 MCP server 组合独立包。Maestro 的优势是热插拔（加阿拉伯语不需要重新部署），TAD 的优势是深度集成（skill file 可以编码复杂约束规则，MCP 工具做不到）。

### 对 TAD 的启发

1. **TAD 不孤独** — Skill file 编排（Gryter）、gate-loop 迭代（SPEAR）、adversarial 自检（Inhabited-design）都在社区独立出现。TAD 的方向被验证了，但 TAD 的双代理分离是独特的。

2. **MECE Rubric 可借鉴** — SPEAR 的 MECE rubric 比 TAD 当前的 Gate checklist 更结构化。TAD 的 Gate 项目之间可能有重叠（not mutually exclusive），可以考虑 MECE 化。

3. **ICP 锚定设计** — Inhabited-design 的 "为具体用户设计" 思路值得吸收到 Feedback Collector 或 *design 流程中。

4. **MCP 是互补路径** — 不是替代。TAD 的 skill file 编码判断规则（when to do X），MCP 提供工具能力（how to do X）。Maestro 验证了 MCP 组合的可行性。

### 未知风险

- **缺乏代码验证**: 4 个项目中没有一个开源了代码。所有技术描述来自 meetup demo 和一篇文章，没有可审查的实现。
- **SPEAR 的 500k+ 行**: 声称来自 24/7 循环，但没有质量评估——行数不等于质量。
- **可复制性未知**: 这些模式在其原作者手里有效，但没有第二方独立复现的证据。

### Claim 验证

| Claim | 来源 | 验证 |
|-------|------|------|
| SPEAR 产出 500k+ 行代码 | SPEAR 文章 | ⚠️ 待验证（自述，无独立确认） |
| MECE 源自 David Marr 三层分析 | SPEAR 文章 | ⚠️ MECE 来自 McKinsey，David Marr 的三层分析是计算认知科学框架——两者是独立概念，文章将它们关联但理由不清晰 |
| Gryter 12 skill files 实现团队级产出 | Newsletter | ⚠️ 待验证（meetup demo 描述，无量化） |

---

**原始素材**: raw-source-2026-06-23.md (同目录)
