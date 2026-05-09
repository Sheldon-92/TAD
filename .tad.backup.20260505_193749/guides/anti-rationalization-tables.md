# Anti-Rationalization Tables

> Preemptive defense against common rationalizations for bypassing TAD rules.
> Inspired by Superpowers' pattern: "excuses you'll find + why they're wrong."

## How to Use

- **Agent**: If you're about to skip a rule and find yourself thinking one of these thoughts — STOP. The thought itself is evidence that the rule applies.
- **Human**: If an agent produces one of these excuses, point them to this table.

---

## Category 1: Socratic Inquiry Bypass

| # | Agent Excuse | Rebuttal |
|---|-------------|----------|
| S1 | "用户描述已经很详细，不需要再问了" | 即使描述详细，用户往往忽略边界条件和异常场景。提问目的不是获取信息，而是暴露盲点。 |
| S2 | "用户要求快速推进，对话式提问更高效" | AskUserQuestion 产生结构化记录，对话式答案在上下文压缩时丢失。工具使用是合规硬证据。 |
| S3 | "这明显是 small 任务，问用户只是浪费时间" | Alex 评估≠人类决策。人类可能知道看似简单需求背后有技术债务。跳过选择 = 剥夺控制权。 |
| S4 | "我已经问了足够多问题了，可以开始写了" | 苏格拉底提问的轮数由 adaptive_complexity_protocol 的用户选择决定，不由 Alex 自行判断"足够"。 |

---

## Category 2: Gate Bypass

| # | Agent Excuse | Rebuttal |
|---|-------------|----------|
| G1 | "代码写完且通过测试了，Completion Report 只是文书工作" | Report 不是文书——它迫使 Blake 显式对比 handoff 计划 vs 实际交付。没有 Report = 没有偏差检测。 |
| G2 | "已经跑过 npm test 全部通过，再调 subagent 是重复劳动" | Layer 1 的 npm test 只检查是否通过。test-runner subagent 额外检查覆盖率和测试质量。两者目的不同。 |
| G3 | "这只是 UI 调整，没有安全/性能风险" | 查 trigger_pattern 正则。不匹配的话 subagent 快速返回 PASS。调用开销远低于漏检风险。 |
| G4 | "仔细审查了 completion report，功能看起来完全符合" | "看起来符合"≠实际验证。必须调 subagent 执行代码审查并产生 evidence 文件。 |
| G5 | "常规 CRUD，没有新发现，Knowledge Assessment 是浪费" | 即使无新发现也必须显式写 "No"。跳过 = 表格不完整 = Gate 无效。 |

---

## Category 3: Terminal Isolation Bypass

| # | Agent Excuse | Rebuttal |
|---|-------------|----------|
| T1 | "只写个小示例帮用户理解设计意图" | handoff 中可包含伪代码和接口定义，但可编译代码属于 Blake 职责。用 `// pseudocode` 标注。 |
| T2 | "用户正忙，我先帮他把 blake 也启动了" | 终端隔离的意义：强制人类审查 handoff。自动传递 = 人类失去审查机会。 |
| T3 | "Blake 的修复很简单，只改一行，我帮他改了省得切 terminal" | 一行修改也需通过 Ralph Loop。Alex 改了就跳过了 Layer 1 + Layer 2。 |

---

## Inline Embed Reference

8 of the 12 entries are embedded inline at their point of temptation. 4 entries (S2, S4, G3, T1) are guide-only — they apply broadly rather than at a specific insertion point.

| ID | Embedded In | Location |
|----|------------|----------|
| S1 | tad-alex.md | socratic_inquiry_protocol.violations |
| S3 | tad-alex.md | adaptive_complexity_protocol.step1 |
| G1 | tad-blake.md | completion_protocol |
| G2 | tad-blake.md | 3_layer2_loop |
| G4 | tad-alex.md | gate4_v2_review |
| G5 | tad-alex.md | post_review_knowledge |
| T2 | CLAUDE.md | Section 4 Terminal Isolation forbidden |
| T3 | tad-alex.md | top-level forbidden actions |
