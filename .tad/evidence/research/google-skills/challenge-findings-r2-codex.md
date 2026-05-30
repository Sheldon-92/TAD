INSUFFICIENT

## 维度评估
### 1. 证据充分性
多个结论仍是 WEAK_EVIDENCE。虽然声称查询 50 个来源，但正文缺少可核验的 URL、commit hash、文件行号、原文摘录，导致“来源数量”不能转化为证据质量。

WEAK_EVIDENCE:
- “内部 CI 存在”：Copybara 只能证明内部同步源存在，不能证明有 schema validator 或 CI 质量门。
- “脚本作为 headless API 是 defensible architecture”：这是架构解释，不是经验证据。缺少 Google 官方设计说明或维护者声明。
- “5 个模式解决的问题 / 不采用的风险”：多数是推断，没有事故案例、失败率、对照实验或使用数据。
- “MCP-neutral”：只基于文案提到 Claude/Codex 不足以证明实际兼容性，缺少安装与运行验证。
- “Developer Knowledge MCP Server fallback”：列出引用位置不等于证明它实际可用、稳定、覆盖充分。

### 2. 角度完整性
至少缺失这些关键视角：
- 实际可执行性视角：这些 skills 在 Codex、Claude Code、Gemini CLI 中是否真的能跑通？有没有端到端执行验证？
- 用户安全视角：prompt 层确认是否真的能阻止误删？面对不同 agent、不同上下文压缩、不同工具权限时是否失效？
- 维护演化视角：这些模式是最新标准、历史残留，还是不同团队随意写法？缺少时间线和 commit intent。
- 竞品/替代方案视角：没有对比 Anthropic skills、OpenAI skills、社区 MCP skill registry 的结构差异。
- TAD 适配视角仍未完成，Q8 被推迟，但这是“是否借鉴”的核心问题。

### 3. 假设可靠性
隐含假设很多，且支撑不足：
- 假设 public repo 能代表 Google 内部真实标准。证据不足；Copybara 反而说明 public repo 可能是过滤后的投影。
- 假设出现频率低的模式仍值得作为“top replicable patterns”。但 4/24、3/24、2/24 的覆盖率很弱，可能只是局部团队习惯。
- 假设 prompt-only safety 足够可靠。没有 agent 行为测试或 bypass 测试。
- 假设没有 public CI 就意味着缺少机械 schema enforcement。后续又承认可能有 internal CI，原结论需要降级。
- 假设 “NO dry-run / no confirmation in scripts” 是缺陷。若脚本被设计为低层 API，这未必是缺陷；真正缺陷只在治理层缺失时成立。

### 4. 因果推理
研究大量把“看起来合理”写成“解决了问题”：
- “Phase 0 初始化解决 death loops”：缺少前后对比或失败案例，只能说它可能降低环境漂移风险。
- “SDK bans 防止 deprecated code”：机制合理，但没有证明 agent 服从率提升。
- “STOP/Yield 防止 hallucination”：缺少实际 agent 测试，尤其缺少压缩上下文、多轮对话、工具调用竞态下的验证。
- “不采用会导致灾难性 infra loss”：风险存在，但严重程度和概率没有量化。
- “Developer Knowledge MCP fallback 防止 base weights 幻觉”：只有机制假设，没有检索质量、召回率、过期文档处理证据。

### 5. 决策支撑力
如果要决定是否投入资源借鉴这些发现，仍缺少：
- TAD 当前痛点与 Google patterns 的一一映射。
- 每个模式的实施成本、维护成本、失败模式和验收标准。
- 最小试点方案：先借哪 1-2 个、在哪些 workflows 测试、如何衡量效果。
- 安全验证：typed confirmation、STOP/Yield、脚本 destructive ops 的红队测试。
- 兼容性验证：在 Codex fallback 环境下是否可执行，而不是只看 Google/Gemini 文案。
- 证据包：文件路径、行号、commit hash、原文引用、覆盖统计脚本。

## 需要补充研究的问题（仅 INSUFFICIENT 时填写）
- Q1: Copybara 是否真的对应内部 schema/CI 质量门？搜索方向：commit metadata、public workflow absence、维护者说明、Google internal docs references。
- Q2: 这些 safety prompt 在真实 agent 执行中是否有效？搜索方向：构造 destructive-command 测试、跨 Codex/Claude/Gemini 对比、记录绕过率。
- Q3: 哪些 Google patterns 与 TAD Gates/Ralph Loop 有直接适配价值？搜索方向：建立 TAD↔Google matrix，按风险降低和实施成本排序。
- Q4: 低覆盖模式是否是推荐标准还是局部例外？搜索方向：按 commit 时间、目录 owner、skill family 分组分析。
