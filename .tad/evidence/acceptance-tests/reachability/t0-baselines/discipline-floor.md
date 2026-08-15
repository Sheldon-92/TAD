# 地板表 —— 30 条纪律的载体该常驻还是按需（P2b 产物）

## 主表（30 条）
纪律	既有判定	通道	触发条件	循环?	载体路径	锚点串	触发串	Layer	定档依据	不可降级	解除待判需要什么
需求澄清	地板	both	-	否	.tad/config-workflow.yaml	description: "写 handoff 之前必须用 AskUserQuestion 工具进行苏格拉底式提问"	必须执行需求澄清：description: "写 handoff 之前必须用 AskUserQuestion 工具进行苏格拉底式提问"	0	既有判定	否	常驻既定，无解除待判需求
需求闸	地板	full	-	否	.claude/skills/gate/SKILL.md	## Gate 1: Requirements Clarity (Alex) - Optional Quick Check	必须复核需求闸：## Gate 1: Requirements Clarity (Alex) - Optional Quick Check	0	既有判定	否	常驻既定，无解除待判需求
重量裁定	可缩放	both	-	否	.claude/skills/alex/SKILL.md	# ⚠️ MANDATORY: Adaptive Complexity Assessment (First Contact)	# ⚠️ MANDATORY: Adaptive Complexity Assessment (First Contact)	1	既有判定	否	按需定档既定，无解除待判需求
专家审查（多视角）	可缩放	both	-	否	.claude/skills/gate/SKILL.md	- [ ] Expert review complete (min 2)	Gate 2 必须执行：- [ ] Expert review complete (min 2)	1	既有判定	否	按需定档既定，无解除待判需求
门禁	地板	both	-	否	.claude/skills/gate/SKILL.md	规则 1: Alex 创建 handoff → 必须先执行 Gate 2	规则 1: Alex 创建 handoff → 必须先执行 Gate 2	0	既有判定	否	常驻既定，无解除待判需求
启动扫描	地板	full	-	否	.claude/skills/alex/SKILL.md	只跑命令读其输出，禁止整读这三处	启动扫描必须执行：只跑命令读其输出，禁止整读这三处（NEXT.md / PROJECT_CONTEXT.md / active handoffs）	0	既有判定	否	常驻既定，无解除待判需求
知识评估	待判	both	蒸馏循环停跑导致教训流失且无记录	是	.claude/skills/gate/SKILL.md	# ⚠️ KNOWLEDGE ASSESSMENT (BLOCKING - Part of Gate 4)	# ⚠️ KNOWLEDGE ASSESSMENT (BLOCKING - Part of Gate 4)	0	待判默认	否	需要「蒸馏循环停跑」的可机械检测信号（如 Gate 3/4 的 KA 检查缺失时显式告警）方能判定非循环，否则触发事件只在本体内部知晓
跨模型审查	待判	full	-	无法判定	.claude/skills/blake/SKILL.md	cross_model_invocation:	跨模型审查必须按需：cross_model_invocation:	0	待判默认	否	需要定义跨模型审查的具体触发场景（当前触发条件字段为空，无法判定循环性）
配对测试	待判	full	真机/真外部系统任务出现	否	.tad/config-workflow.yaml	pair_testing:	配对测试必须执行：pair_testing:	1	循环触发实测	否	触发事件（真机/真外部系统任务出现）由任务声明自知，需 P2b 后实测其出现频率以校准 Layer
角色分离	地板	both	-	否	AGENTS.md	- Alex does not write implementation code, Blake does not independently redesign	角色分离必须：- Alex does not write implementation code, Blake does not independently redesign	0	既有判定	否	常驻既定，无解除待判需求
Execution Mandate	待判	lite	-	无法判定	.claude/skills/blake-lite/SKILL.md	### Execution Mandate 准入（⚠️ BLOCKING）	### Execution Mandate 准入（⚠️ BLOCKING）	0	待判默认	否	需要 lite 单实际运行的 mandate 违约案例记录以定义触发条件（当前为空，无法判定循环性）
约束准入	待判	lite	约束无限膨胀致流程重量失控（累积、难以回缩）	是	.claude/skills/blake-lite/SKILL.md	## 约束准入（新增约束前必须定价）	## 约束准入（新增约束前必须定价）	0	待判默认	否	需要台账超期扫描的机械告警（而非人工自查）方能判定非循环，「流程重量失控」目前只在本体内部可见
AC可执行性检查	地板	both	-	否	.claude/skills/gate/SKILL.md	step2: "对每一行，实际执行其 Verification Method（grep/命令/脚本）"	AC 可执行性必须实跑：step2: "对每一行，实际执行其 Verification Method（grep/命令/脚本）"	0	既有判定	否	常驻既定，无解除待判需求
Friction反跳过	地板	both	-	否	.claude/skills/blake/SKILL.md	# Missing dependency, auth, approval, reviewer, or setup friction is NEVER a skip reason.	# Missing dependency, auth, approval, reviewer, or setup friction is NEVER a skip reason.	0	既有判定	否	常驻既定，无解除待判需求
Ralph Loop自检	可缩放	both	-	否	.claude/skills/blake/SKILL.md	## 🔄 Ralph Loop (TAD v2.41.0)	## 🔄 Ralph Loop (TAD v2.41.0) 自检必须执行	1	既有判定	否	按需定档既定，无解除待判需求
研究先行	待判	full	技术选型/架构决策出现且未先搜索	否	.tad/config-cognitive.yaml	research_first:	研究先行必须执行：research_first:	1	循环触发实测	否	触发事件（技术选型/架构决策出现且未先搜索）由设计流程自知，需实测设计阶段搜索步骤的真实执行率
技术决策透明	待判	both	重要技术决策出现	否	.tad/config-cognitive.yaml	decision_transparency:	重要技术决策必须透明：decision_transparency:	1	循环触发实测	否	触发事件（重要技术决策出现）自知，需实测决策记录的实际留存率
平台绑定交互决策	待判	both	无 AskUserQuestion 工具的 harness 出现	否	.claude/skills/alex/SKILL.md	平台绑定交互决策（cross-harness binding）：本文件及其 references 中所有	平台绑定交互决策必须执行（无 AskUserQuestion 的 harness 激活时自知）：平台绑定交互决策（cross-harness binding）：本文件及其 references 中所有	1	循环触发实测	否	harness 类型激活时自知（alex:335 已有内联指针），需跨 harness 实测其遵守率
六个强制问题	待判	full	MQ 触发条件命中（历史代码/函数存在性/数据流等）	否	.tad/config-quality.yaml	mandatory_questions:	六个强制问题必须执行：mandatory_questions:	1	循环触发实测	否	MQ 触发由设计情境（历史代码/函数存在性/数据流等）自知，需实测 MQ 回答的证据完整率
subagents强制调用	待判	full	场景命中 must_call 清单（需求分析/架构/审查/测试）	否	.tad/config-quality.yaml	subagents_enforcement:	subagent 强制调用必须执行：subagents_enforcement:	1	循环触发实测	否	must_call 场景命中由任务结构自知，需实测子代理调用日志的完整性
产物证据链	待判	both	Gate 3/4 证据检查与完成报告书写	否	.claude/skills/blake/SKILL.md	step3c: "Git commit + evidence ls-check (Phase 3 anchor B-01) + Slug Contract (layer2-audit 2026-04-15)	产物证据链必须执行：step3c: "Git commit + evidence ls-check (Phase 3 anchor B-01) + Slug Contract (layer2-audit 2026-04-15)	1	循环触发实测	否	Gate 3/4 证据检查与完成报告书写自知，需实测证据缺失时的拦截率
激活知识预读	待判	both	角色激活时	否	AGENTS.md	- Every role activation reads `.tad/project-knowledge/principles.md` and	激活知识预读必须执行：- Every role activation reads `.tad/project-knowledge/principles.md` and	1	循环触发实测	否	角色激活事件自知，需实测激活时知识预读的遵守率
压缩后自检恢复	待判	both	上下文压缩后	否	AGENTS.md	### Post-compact recovery	压缩后自检恢复必须执行：### Post-compact recovery	1	循环触发实测	否	压缩事件由 harness 触发、agent 自检时自知，需实测压缩后恢复率
记忆权威分层	待判	both	跨平台记忆读取时	否	AGENTS.md	- `.tad/memory/` is Claude's native capture layer; Codex roles read it but never	记忆权威分层必须执行：- `.tad/memory/` is Claude's native capture layer; Codex roles read it but never	1	循环触发实测	否	跨平台记忆读取时自知，需实测 Codex 侧记忆读取行为
检查点证据验证	待判	both	关键检查点（MQ/Phase 完成报告）	否	.tad/config-quality.yaml	mandatory_checkpoint: "每个Phase完成时Blake必须提供证据，Human必须审查"	mandatory_checkpoint: "每个Phase完成时Blake必须提供证据，Human必须审查"	1	循环触发实测	否	MQ/Phase 报告检查点自知，需实测无证据断言的频率
渐进式分阶段验证	待判	full	大任务 Phase 化交付	否	.tad/config-quality.yaml	progressive_validation:	渐进式分阶段验证必须执行：progressive_validation:	1	循环触发实测	否	大任务规模在启动时预判自知，需实测长任务检查点缺失率
版本发布管理	待判	full	版本发布/API 变更	否	.tad/config-execution.yaml	release_management:	版本发布管理必须执行：release_management:	1	循环触发实测	是	版本发布/API 变更事件自知，需实测发布清单执行率；不可降级（发布回归代价不可逆）
失败学习闭环	待判	both	Human 纠正/测试失败/Bug 报告	否	.tad/config-execution.yaml	failure_learning_loop:	失败学习闭环必须执行：failure_learning_loop:	1	循环触发实测	否	Human 纠正/测试失败/Bug 报告事件自知，需实测失败条目转化率
强制激活协议	待判	both	角色激活时	否	.claude/skills/blake/SKILL.md	## ⚠️ MANDATORY 4-STEP ACTIVATION PROTOCOL ⚠️	## ⚠️ MANDATORY 4-STEP ACTIVATION PROTOCOL ⚠️	1	循环触发实测	否	角色激活事件自知（SKILL 顶部即协议本身），需实测激活步骤遵守率
致命操作强制人审	待判	both	致命操作命中（数据丢失/泄露/财务/服务崩溃）	否	.tad/config-cognitive.yaml	description: "Risk filter for operations that could cause irreversible damage"	致命操作必须人审：description: "Risk filter for operations that could cause irreversible damage"	1	循环触发实测	否	致命操作命中时 agent 自知（risk 卡片），需实测人审放行率

## 副表（Layer 0 里的非纪律常驻项）
项	载体	锚点串	触发串
身份与角色分离载体	AGENTS.md	## Role Switching	## Role Switching Use $alex / $blake (full TAD — **the default**) 必须
意图路由	.tad/config-workflow.yaml	# ⚠️ Intentionally empty signal_words — Alex MUST NOT auto-detect *express	# ⚠️ Intentionally empty signal_words — Alex MUST NOT auto-detect *express
复杂度判定	.claude/skills/alex/SKILL.md	adaptive_complexity_protocol:	adaptive_complexity_protocol: 必须先做复杂度判定 ⚠️
压缩恢复锚点	AGENTS.md	read `.tad/active/session-state.md` and the newest	压缩恢复必须：read `.tad/active/session-state.md` and the newest
反合理化登记	.claude/skills/alex/SKILL.md	<!-- anti_rationalization_registry:BEGIN -->	<!-- anti_rationalization_registry:BEGIN --> 反合理化必须登记
Forbidden 清单本体	.claude/skills/alex/SKILL.md	# Forbidden actions (will trigger VIOLATION)	# Forbidden actions (will trigger VIOLATION) 必须遵守

## Layer 0 实测
full 激活 Layer0: 行数 9 触发串合计 756 bytes
lite 激活 Layer0: 行数 8 触发串合计 632 bytes
共有(both)      : 行数 6 触发串合计 535 bytes
副表            : 行数 6 触发串合计 415 bytes
触发串所在载体文件当前整读合计: 404993 bytes   ← P7 前的真实下界

> ⚠️ 口径警告：本数为触发串之和（bytes），SC1 的 107.7K 为单次 full 激活的整读量（tokens 口径），两者不可直接比较。且 lite 行不计入 SC1（lite 已冻结，默认路径不付）。

## 清单缺口
**凭据/密钥**：30 条纪律中无对应纪律行（实测命中 0）——凭据处理规则散落在平台/工具层（如 `config-platform.yaml` 的 `always_confirm`、`mcp_tools` 安全段），未形成独立纪律，引用 `EPIC-20260813-alex-blake-lightening.md` 风险表 #R6。
**修改框架自身**：同样无对应纪律行（实测命中 0）——该约束只活在 `CLAUDE.md:50`（§2.5 的冻结条款）与 lite skill 的冻结段，30 条主表中无一行覆盖；不可降级组仅版本发布管理一条（AC10 点名），上述两类缺口需 P3/P4/P7 补入时另行登记。

## 承接单
`expert-criteria.yaml`（`.tad/ralph-config/expert-criteria.yaml:185-188`）security-auditor 触发：`type: pattern_match` + `pattern: auth|token|password|credential|api.*key|encrypt|decrypt|session|cookie|sql|query|upload|file|exec|eval`——该 pattern 匹配内容不匹配路径，且全仓库无任何脚本解析它（`.tad/config-execution.yaml` 的 `criteria_file` 仅是指针引用，无 sh/py/js 消费方）。
Blake 当场实测（命令可复算，口径：分母 = `git ls-files` 全量文件数，分子 = 文件级命中）：
1. 路径口径：`git ls-files | grep -Ec 'auth|token|password|credential|api.*key|encrypt|decrypt|session|cookie|sql|query|upload|file|exec|eval'` → **504/6743 = 7.47%**
2. 内容口径：对 `git ls-files` 逐文件 `grep -lE` 同一 pattern → **4990/6743 = 74.0%**
两口径相差一个数量级：若按路径匹配触发，74% 内容命中安全模式的改动会被漏触发（示例：`.agents/skills/_archived/api-design.md` 内容含 auth/token 但路径不命中）；且该文件无解析脚本，实际触发依赖 agent 自觉读 yaml。承接单：**`expert-criteria-wiring`**（把触发判定改为可执行脚本并按内容扫描，或显式声明降级为手工检查）。
