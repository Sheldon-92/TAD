---
name: knowledge-recording-redesign
description: "Epic COMPLETE 2026-06-22: TAD knowledge recording redesigned — Capture/Distill/Maintain 三时刻模型, typed schema (failure_mode REQUIRED), gap-driven cross-bridge distillation loop, rule-driven maintenance. 110 entries migrated, e2e loop validated live."
metadata: 
  node_type: memory
  type: project
  originSessionId: 9ce91d2f-6619-41c7-be9d-b9a782469bf4
---

✅ Epic COMPLETE (2026-06-22, 4/4 phases, single session):

**What changed**: TAD knowledge recording从"干活者在任务结尾直写成品"改为三时刻模型:
1. **Capture**: Blake Gate 3 KA只写raw journal到evidence/journal/(便宜,无schema约束)
2. **Distill**: Alex Gate 4 KA跑缺口驱动提炼回环(陌生人读journal→填typed entry→填不出的字段=问题→人类桥→Blake答→定稿)
3. **Maintain**: 规则驱动(hash去重+lexical和解ADD/UPDATE/DELETE/NOOP+人gate删改+soft lint+usage-utility退役信号)

**Why**: 知识诅咒——做完事的人看不见自己省略了什么,写出来是session日记不是可复用手册。Terminal隔离让Alex天然是陌生人。

**Key artifacts**:
- L1 principle: "Knowledge Is Forged at Distill, Not Captured"(principles.md #15, SAFETY)
- Schema: `.tad/templates/playbook-entry-schema.md`(6字段,failure_mode REQUIRED)
- Writing rules: `.tad/templates/knowledge-writing-rules.md`(变量化测试+5规则)
- Distill protocol: `.claude/skills/alex/references/distillation-loop-protocol.md`(7步)
- Maintain protocol: `.claude/skills/alex/references/knowledge-maintain-protocol.md`(6步)
- Lint: `.tad/hooks/lib/knowledge-lint.sh`(soft, exit 0 always)
- Research: `.tad/evidence/research/agent-knowledge-systems/2026-06-22-findings.md`(Mem0/Letta/AWM/Anthropic Skills源码级)

**Validation**: 110 entries migrated (0 UNRESOLVABLE). E2E loop live: failure_mode gap detected→Blake answered "fabrication > omission"→entry finalized. Schema universally applicable to L2 patterns.

**Not done**: 判断型知识(架构为什么这么选)的delta是判断差不是动作差——Phase 2 follow-up Epic. 下游14项目pull-based via *publish.
