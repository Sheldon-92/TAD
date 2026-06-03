# Idea: Search-as-Code 启发：薄协议 + 厚工具演进方向

**ID:** IDEA-20260602-sac-thin-protocol-thick-tools
**Date:** 2026-06-02
**Status:** promoted
**Scope:** large

---

## Summary & Problem

Perplexity SaC 论文验证了 TAD 已有原则（file-as-truth, agent-controlled retrieval），并指出演进方向：(1) 随模型变强，将判断规则从 SKILL.md 文本下沉到更强的 CLI 工具原语（"薄协议 + 厚工具"）；(2) 研究管道从固定 Phase 0-5 协议驱动改为 Alex 动态生成 Python 脚本编排 NotebookLM CLI 并行调用。当前 TAD SKILL.md ~50K+ tokens，SaC 的 Agent Skill <2000 tokens——随着模型智能提升，最优平衡点在移动。

## Open Questions

- 工具层何时成熟到能承接下沉的判断逻辑？（当前 CLI 还在补基础功能）
- NotebookLM CLI 何时支持并行/async？（当前是瓶颈）
- Pack rebuild 过程是否自然消化这个方向？（每次 rebuild 都在问"哪些规则下沉"）
- SKILL.md 精简的安全阈值是什么？（v2.7 质量链失效前车之鉴——constraint rules 不能删）
- "代码即编排"用于研究管道时，如何保证可审计性？（当前每步 evidence 持久化 vs 脚本 intermediate state）

## Notes

- 来源：Perplexity Research "Rethinking Search as Code Generation" (2026-06-02)
  https://research.perplexity.ai/articles/rethinking-search-as-code-generation
- SaC 核心未开源（闭源 SDK + Agent API），但架构论文可借鉴
- 文章关键数据：WANDR benchmark 2.5x 领先，CVE case study token 降 85%
- Filesystem > REPL state 结论直接验证 TAD YOLO protocol "file as source of truth"
- 与 TAD 路线图对齐："depth-first: freeze 20 packs → rebuild as SKILL.md one by one"——rebuild 时自然评估"薄协议 vs 厚协议"
- Notebook 参考：tad-evolution-research (37cfefa5) 已有 agent framework landscape 研究

## Counterpoint: Garry Tan "540K Lines I Didn't Need" (2026-06-02)

**Source:** https://x.com/garrytan/article/2061454423034110372

Garry Tan (YC CEO) 用 Claude/Codex 写了 540K 行 Rails (Garry's List)，事后认为大部分是"给 AI 建的富士康工厂"——过度控制的测试/验证/重试代码。提出替代方案：Markdown-as-program + skill pack + tokenmaxxing。

### 和 TAD 的关系

**表面一致**：TAD 的 SKILL.md 体系天然就是 markdown-as-program，24 个 Capability Pack 就是 skill pack，YOLO protocol 的 file-as-truth 和 GStack 同构。

**核心分歧**：Garry 的控制对象是模型的**执行输出**（代码对不对），TAD 的 gate 控制的是模型的**元判断**（该不该跳步骤）。前者模型已经够强，后者还没到。

### 判断：现阶段不适用

1. **反馈循环长度不同** — Garry 的场景 bug 当天暴露，TAD 的质量 drift 几周后才发现。即时反馈可以放权，延迟反馈需要 guardrail。
2. **TAD 有事故记录** — AR-001~005 每条背后都是 agent 被信任然后辜负信任的真实事件。v2.7 质量链失效：删了 570 行"看起来不需要"的约束，导致几个月 drift。
3. **执行 vs 元判断的成熟度差距** — 模型写代码/做分析很强，但"该不该做、做多深、能不能走捷径"这类元判断是当前模型最不可靠的地方。
4. **结论**：TAD 的厚协议 ≠ Foxconn 工厂。等模型元判断能力成熟后自然会变薄，但今天不是那天。

---

**Status Values**: captured → evaluated → promoted → archived
**Promoted To**: (filled by *idea promote)
