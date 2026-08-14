研究先行	采纳:研究先行	.tad/config-cognitive.yaml:120	属实	research_first:	设计前必做 landscape 搜索（min_queries 3）与无证据链接 = VIOLATION，独立强制纪律；语料块 120 已归新增:研究先行
技术决策透明	采纳:技术决策透明	.tad/config-cognitive.yaml:6	属实	Pillar 1: Technical Decision Tran	重要技术决策必须可见、经研究、由人拍板（decision_triggers 三档分类），语料块 7 已归新增:技术决策透明
平台绑定交互决策	采纳:平台绑定交互决策	.claude/skills/alex/SKILL.md:149	属实	平台绑定交互决策	跨 harness 交互决策契约（AskUserQuestion 非工具、SAFETY 门控须真人作答、blocked 分支），AGENTS.md:79 镜像块已归同名新增
六个强制问题	采纳:六个强制问题	.tad/config-quality.yaml:393	属实	mandatory_questions:	MQ1-6 从历史失败提炼、触发即须回答并附证据且 blocking，语料块 393 已归同名新增
subagents强制调用	采纳:subagents强制调用	.tad/config-quality.yaml:7	属实	subagents_enforcement:	agent_a/agent_b 各场景 must_call 清单与违规阻止执行机制，语料块 7 已归同名新增
产物证据链	采纳:产物证据链	.claude/skills/blake/SKILL.md:1606	属实	Git commit + evidence ls-check	step3c 证据检查与 step3d Provenance 表构成产物证据纪律；语料侧宿主块 = config-quality:690 template_triggers（subagent 输出模板与证据路径强制）
结构性subagent强制	驳回	.claude/skills/gate/SKILL.md:624	属实	Structural_Subagent_Conditionality:	已由「专家审查（多视角）」覆盖：security/performance/code reviewer 按 task_type 强制本就是该纪律在 Gate 4 的实例化——块 575 归已有:门禁、块 780 归已有:专家审查（多视角），另立一条会造成重复登记
规格逐行实跑	驳回	.claude/skills/gate/SKILL.md:159	属实	SPEC COMPLIANCE VERIFICATION	已由「门禁」覆盖：§9.1 逐行执行 Verification Method 是 Gate 3 验证协议的核心组成部分，块 103 已归已有:门禁，非独立纪律
熔断与升级	驳回	.claude/skills/blake/SKILL.md:995	属实	circuit_breaker:	已由「Ralph Loop自检」覆盖：consecutive_same_error>=3 → escalate_to_human 是该纪律的熔断机制，语料侧块 46 已归同名，不另立条
GlobalSkillExclusion	驳回	.claude/skills/alex/SKILL.md:490	属实	GLOBAL SKILL EXCLUSION	源在 alex SKILL（137 块具名延期、语料外），60 块语料无宿主块可挂新增；纪律内容留待 P2b 复活条件（已扫语料再现未登记强制纪律）触发时登记
