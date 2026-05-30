INSUFFICIENT

## 维度评估
### 1. 证据充分性
大量结论只有仓库内单一文件或少数同源文件支撑，独立性不足。

- WEAK_EVIDENCE: “无机械 CI/schema validator”。需要证明完整 CI、GitHub Actions、pre-commit、测试脚本、发布流程都没有，而不是只引用 CONTRIBUTING、generate-skill、validate_env.py。
- WEAK_EVIDENCE: “ADC exclusively”。只分析了部分 Python 脚本，不能外推到全仓库所有认证路径。
- WEAK_EVIDENCE: “无 dry-run flags anywhere”。这是全称断言，必须有全仓库 argparse/CLI 参数扫描证据。
- WEAK_EVIDENCE: “MCP-neutral with Gemini-first orientation”。引用几个 skill 的安装说明不足以证明整体中立性，需要统计所有技能中 Gemini/Claude/Codex/MCP 的覆盖比例。
- WEAK_EVIDENCE: “Top 5 replicable patterns”。这些是研究者归纳，不是被用户效果、事故率、采纳率或维护成本验证过的模式。

最大问题：报告说 queried 50 sources，但没有 source list、采样规则、每个 claim 对应来源编号、反例搜索结果。证据不可审计。

### 2. 角度完整性
至少缺失以下视角：

- 使用者视角：这些 skills 在真实 agent 工作流中是否有效？是否降低错误率、节省时间、减少破坏性操作？
- 维护者视角：这些模式的维护成本、文档漂移风险、版本兼容负担是什么？
- 失败案例视角：有没有 skills 明确失败、过时、误导 agent、引用不存在工具或 API？
- 对照组视角：Google repo 的模式相比 Anthropic/OpenAI/community skills 是否真的更优？
- 安全威胁模型视角：只看脚本确认和 secrets 不够，缺少权限边界、最小权限、审计日志、供应链依赖、MCP server trust boundary。

### 3. 假设可靠性
隐含假设很多，且支撑不足：

- 假设“公开 repo 代表真实内部质量标准”。证据不足，CONTRIBUTING 反而说明有 internal Agent Skills Program 文档，公开仓库可能只是投影。
- 假设“SKILL.md-only 是 canonical”。generate-skill.md 说 references/scripts/assets optional，只能证明允许，不证明推荐或质量等价。
- 假设“agent-level confirmation 足以替代 script-level guard”。报告把它列为 critical finding，但后续 pattern 又建议采用 prompt-only safety，内部张力没有解决。
- 假设“无 depends_on 字段意味着依赖非结构化”。可能存在外部 registry、manifest、README、package metadata 或安装器层面的依赖，未排除。
- 假设“Phase 0 初始化能防 death loops”。这是合理直觉，但没有日志、实验或案例证明。

### 4. 因果推理
存在把相关性或设计意图当成效果的地方：

- “Tier R/M/D 解决 agents eager to please”。最多说明它试图约束 agent，不能证明真的减少误操作。
- “Phase 0 prevents dependency hallucination”。没有对照实验，不能从 checklist 存在推出防止效果。
- “STOP/Yield prevents hallucination of missing parameters”。缺少机制验证：agent 是否遵守？在哪些模型、工具、上下文长度下有效？
- “SDK deprecation bans forcefully overwrite pretrained preferences”。这是机制猜测，不是证据结论。
- “Developer Knowledge MCP fallback prevents base-weight hallucination”。没有检索质量、召回率、失败模式或引用强制机制，不能证明防幻觉。

### 5. 决策支撑力
如果要决定是否投入资源借鉴这些模式，缺少关键信息：

- 采用成本：每个模式需要多少工程时间、维护者时间、infra 成本。
- 效果指标：错误率下降、任务成功率、破坏性操作拦截率、平均完成时间。
- 风险排序：哪些模式是高收益低风险，哪些只是文档美化。
- 适配 TAD 的约束：TAD 的 Gates/Ralph Loop 与 Google patterns 是否冲突或重复。
- 反例与失败条件：哪些 Google patterns 不适合 TAD，为什么。
- 样本覆盖率：总 skills 数、分析比例、脚本总数、MCP server 总数、遗漏范围。

## 需要补充研究的问题（仅 INSUFFICIENT 时填写）
- Q1: 全仓库级证据矩阵是什么？搜索方向：列出所有 SKILL.md、scripts、CI 文件、manifest/registry 文件，并为每个核心 claim 建立 claim → source → independent corroboration 表。
- Q2: 这些 safety patterns 是否真实有效？搜索方向：找 issue、PR、commit、事故修复、用户反馈，或设计一个小型对照测试比较有无 R/M/D、STOP、Phase 0 的 agent 行为。
- Q3: Google patterns 与 TAD Gates/Ralph Loop 的兼容性如何？搜索方向：逐项映射 Google pattern 到 TAD Gate 1-4，标出重复、冲突、缺口和迁移成本。
