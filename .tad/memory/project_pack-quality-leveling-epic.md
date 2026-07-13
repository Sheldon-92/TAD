---
name: project_pack-quality-leveling-epic
description: 2026-06-13 Epic ✅ COMPLETE+ARCHIVED：24 包双层尺质量拉齐，6/6 phase，YOLO via Workflow 无 Codex，21 包升级+固化进 capability-upgrade
metadata: 
  node_type: memory
  type: project
  originSessionId: 171b1263-2f86-44fb-89c9-ed31cb384805
---

EPIC-20260613-capability-pack-quality-leveling：把全部 **24 个**能力包拉齐到统一高质量线。

**双层尺**：(A) 元设计/结构层——对标最好的开源 skill 库(Anthropic 官方 skills 等)的组织方式；(B) 领域内容层——对标内部 3 个最成熟包(web-ui-design / web-frontend / web-backend)的领域深度。

**每包 DoD**：判别式行为评估(pack-eval-runner.sh，negative control 必须 FAIL) + 元设计 checklist + **所在批次**的跨模型 Codex 对抗审查(按批跑，非每包单跑)FIX-FIRST 全 resolved。

**批次**：~4 批 × 6（允许不均匀，不硬钉），弱→强，成员由 Phase 1 基线决定。

**6 phases**：Phase 1 定尺+基线 / Phase 2-5 逐批升级 / Phase 6 全量验证+把元设计 checklist 固化进 capability-upgrade SKILL。

**Phase 1 状态**(2026-06-13)：✅ **Gate 4 ACCEPTED**(commit f2addac)。产物 = `.tad/evidence/pack-quality/QUALITY-BAR.md` + `BASELINE-AUDIT.md` + NotebookLM `capability-pack-meta-design`。Alex 独立重算验收:AC2=24、两层 negative control 真 FAIL(Layer A 劣质结构 0/10、Layer B 浅薄 specN=0→1/5)、Layer 2 ×3 PASS。handoff 已归档。

**批次回填(弱→强,不均匀 7/5/5/4,3 gold 排除)**：Batch 1=ml-training\*/data-engineering/ai-podcast-production\*/agent-memory/agent-orchestration/knowledge-graph/ai-tool-integration(\*=2 个无 fixture 包,补 fixture 是该批交付物);Batch 2=llm-observability/product-thinking/code-security/synthetic-data/web-testing;Batch 3=ai-agent-architecture/ai-evaluation/ai-guardrails/ai-voice-production/ai-prompt-engineering;Batch 4=rag-retrieval/web-deployment/academic-research/video-creation。gold(web-backend/frontend/ui-design)不进升级批。

**关键发现(Blake KA → pack-evaluation.md)**：结构-gold ≠ 深度-gold(web-ui-design 深度 5/5 但 body 1202 行结构 gap);specN 单维误排 gold(web-backend specN 仅 27,深在 operationalized criteria);reference-only 扫描低估 deep-skill 包(product-thinking 2492 行在 skills/+adapters/);双侧 negative control 是反 theater 关键。

**✅ COMPLETE 2026-06-13**（commits f2addac→c4f1ccc，~200 agents，172 文件/+7664）：6/6 phase 全完成,21 包升级,3 gold 参照,QUALITY-BAR 固化进 capability-upgrade Gate 2,.agents Codex 镜像 parity PASS(release-verify.sh parity --fix),Epic 已归档。

**方法论沉淀(可复用)**：
- YOLO Epic via Workflow:Conductor(Alex)每批一个 pipeline workflow(Plan→Upgrade→Eval→Review),完成回调判 gate+commit。参数化失败(args 在 scriptPath 模式不注入)→硬编码每批+edit-between-batches。
- **No-Codex 对抗审查**:Workflow 3-lens(correctness/fact-api/anti-slop)+ fact-api 强制 WebSearch 核对一手文档,替代 Codex 跨模型。**验证有效**——抓到同模型会漏的事实错(捏造 API、引错论文)。代价:同模型盲区→靠"查一手源"补,Phase 6 人审兜底。
- **规则教训**:"≥2-refute→fix" 太松(单 lens 抓到的 P0 被放过:product-thinking fixture 教错判断)→改 "any-refute→validate-then-fix"(fix agent 先验证再修,误报跳过+记录)。findings 必须落盘(否则少数意见丢失,Batch 1 踩过)。
- session limit 中断 → resumeFromRunId 无损续跑(缓存成功 agent,重跑失败的)。
- `release-verify.sh parity --fix` = .claude→.agents 镜像同步的正确工具(claude-newer 自动 rsync),勿手写 copy。

**Dogfood 验收(2026-06-13,出厂前最后一关)**:21 包盲评 A/B(judge 不知哪个用包,逐条 WebSearch 核对)= **18 加包赢 / 1 平 / 2 输**。质量是真的——靠正确具体度+更新工具+generalist 想不到的技术赢,不是话多。**但 dogfood 抓出 5 个 eval+batch审查全漏的材料级真错**(已修+镜像):ai-podcast 双母带 prescription 错(播客发单文件)、web-testing 捏造 n=550 + 不存在的 @axe-core/playwright 4.12.x、ai-guardrails OWASP LLM08→LLM01、code-security 废弃 semgrep-action→`semgrep ci`、knowledge-graph 60.92% 引错 arXiv ID(数字真,citation 错)。

**头号方法论收获**:**判别 eval(WITH vs CONTROL marker)+ 同模型 batch 审查可以全绿,包却仍出厂一个材料级错误声称。只有"盲评 dogfood + 强制一手核对"抓得到。** → dogfood-with-factcheck 应作为新包出厂前最后一关,加进 capability-upgrade。两个输的包(video-creation 零错但没赢过 generalist、knowledge-graph)= 21 个里最弱,"包"形式对这俩领域可能加值有限。Workflow 脚本: `.tad/evidence/yolo/capability-pack-quality-leveling/{batch-upgrade,dogfood-all}.workflow.js`。

Related: [[project_capability-packs]] [[feedback_research-methodology]] [[project_yolo-audit-findings]]。

**头号风险**：validation theater——rubric 必须**两层都判别**(arch review P0-1 抓出 Layer B 原本只有单端 gold-standard 锚点，已加 0/2/5 操作化锚点 + Layer B negative control)。无 fixture 的那 1 个包自动进 Batch 1 + 标 LOW 置信(P0-2)。

对齐 OBJECTIVES O2/KR1 + surplus-plan 2026-06-13 第 5 名。相关 memory：[[project_capability-packs]] [[feedback_pick-generative-directions]]。另：独立的"纯 skills 包给朋友"方向见 [[IDEA-20260613-tad-opt-in-mode-posture 文件内 Notes]]（未启动）。
