#!/usr/bin/env python3
# Generate disposition-60.md from Blake's block judgments + frozen Step 0 inputs.
# Columns: path TAB start TAB blockname TAB 归宿 TAB 理由码 TAB 一句话 TAB hits TAB subkeys
import subprocess, re, sys
R = "/path/to/TAD"
EV = f"{R}/.tad/evidence/acceptance-tests/discipline-enumeration"
WIDE = open(f"{EV}/wide-markers.txt", encoding="utf-8").read().rstrip("\n")
marker_re = re.compile(r"(?:" + WIDE + r")")

def run(cmd):
    return subprocess.run(cmd, shell=True, capture_output=True, text=True, encoding="utf-8").stdout

blocks = [l.rstrip("\n").split("\t") for l in open(f"{EV}/blocks.txt", encoding="utf-8")]
ranges = [l.rstrip("\n").split("\t") for l in open(f"{EV}/ranges.txt", encoding="utf-8")]
hitsmap = {(l.split("\t")[0], l.split("\t")[1]): l.rstrip("\n").split("\t")[2] for l in open(f"{EV}/hits.tsv", encoding="utf-8")}
subkeys = {}
for l in open(f"{EV}/subkeys.tsv", encoding="utf-8"):
    f, s, k = l.rstrip("\n").split("\t")
    subkeys.setdefault((f, s), []).append(k)

# (file, start) -> (归宿, 理由码, 一句话核心)
J = {
(".claude/skills/gate/SKILL.md","2"):("非纪律","R5","name: gate；frontmatter 元数据，仅命令名"),
(".claude/skills/gate/SKILL.md","3"):("非纪律","R5","description: Execute TAD Quality Gate. Gate 1 (pre-design)；frontmatter 描述，hits=0"),
(".claude/skills/gate/SKILL.md","9"):("非纪律","R3","## 🎯 自动触发条件；何时主动调用 skill 的描述性触发清单"),
(".claude/skills/gate/SKILL.md","13"):("已有:门禁","","### 必须执行 Gate 的时机；四个 Gate 的强制时机枚举（设计前/建 handoff 前/提交前/交付前）"),
(".claude/skills/gate/SKILL.md","19"):("已有:门禁","","### ⚠️ 强制规则；规则 1-4：Alex 创建 handoff 必须先执行 Gate 2、Blake 实现必须先执行 Gate 3、集成必须先执行 Gate 4、不通过阻塞下一步必须修复"),
(".claude/skills/gate/SKILL.md","27"):("非纪律","R3","→ 必须先调用 /gate 2；激活场景操作示例（场景 1/2 的调用路径），核心强制已由门禁块承载"),
(".claude/skills/gate/SKILL.md","46"):("非纪律","R3","## Gate Detection and Execution；检测与执行流程描述（可用 Gate 列表）"),
(".claude/skills/gate/SKILL.md","63"):("非纪律","R1","Output: Quick summary, no formal evidence required；Gate 1 为 Optional Quick Check，能力非强制"),
(".claude/skills/gate/SKILL.md","78"):("已有:门禁","","## Gate 2: Design Completeness (Alex) - **MANDATORY** 🔴；设计完整性 6 项强制检查，When: Before creating handoff (BLOCKING)"),
(".claude/skills/gate/SKILL.md","103"):("已有:门禁","","## Gate 3: Implementation Quality (Blake) - **MANDATORY** 🔴；实现质量验证：Completion Report 前置、§9.1 逐行执行、空 §9.1 拦截、git commit 验证、知识评估 BLOCKING——其子键 if_exists、violations 等 9 项（含 friction 检查与 gate3_addition 输出）是门禁的实现子项，未独立成条"),
(".claude/skills/gate/SKILL.md","413"):("已有:专家审查（多视角）","","# ⚠️ judge ≠ producer (BLOCKING) — contract §C；rubric 评审协议：独立 judge 强制 spawn、file-paths-only、verdict shape 守护、反自证六禁令——其子键 hard_rule、forbidden、judge_prompt_constraint 等 17 项是审查协议实现子项，未独立成条"),
(".claude/skills/gate/SKILL.md","575"):("已有:门禁","","## Gate 4: Integration Verification (Blake + Alex) - **MANDATORY** 🔴；业务验收：Gate 3 前置、结构性 subagent 角色强制、feedback 检查、知识评估 BLOCKING——其子键 optional_advisory_checker、escape_valve、gate4_addition 等 7 项是验收实现子项，未独立成条"),
(".claude/skills/gate/SKILL.md","780"):("已有:专家审查（多视角）","","## ⚠️ Gate 4 Subagent Requirement (CRITICAL)；Alex 必须调用 subagents 实际验收，不可仅做纸面验收——专家审查的 Gate 4 实例（含 knowledge_assessment 子段）"),
(".claude/skills/gate/SKILL.md","913"):("已有:门禁","","# ⚠️ RUBRIC-LANE PREREQUISITE (BLOCKING)；rubric 通道 Gate 4 前置：rubric-eval 证据须含 machine-readable 行 verdict: PASS"),
(".claude/skills/gate/SKILL.md","947"):("非纪律","R3","⚠️ [Criterion]: Warning - [Concern]；交互执行菜单格式（0-9 选项）"),
(".claude/skills/gate/SKILL.md","974"):("已有:门禁","","⚠️ GATE VIOLATION DETECTED ⚠️；违规处理：Required: Must execute gate before proceeding，Violation_Recovery 停止→纠正→重做"),
("AGENTS.md","16"):("非纪律","R3","files (`AGENTS.md`, skill files) only route and load the role — they never duplicate durable project knowledge；角色激活机制与触发词表"),
("AGENTS.md","36"):("新增:激活知识预读（非候选新增）","","## Knowledge Ingress (read on activation)；零标记但仍属纪律·理由：每次角色激活必须先读 principles.md 与 patterns/_index.md，属激活强制读取纪律，15 个既有纪律名未覆盖"),
("AGENTS.md","55"):("非纪律","R3","## Critical Rules (platform-equivalent of CLAUDE.md §1/§4/§4.5/§7.5)；关键规则聚合标题（子块分别归宿）"),
("AGENTS.md","57"):("已有:角色分离","","### Handoff and routing；零标记但仍属纪律·理由：读取 HANDOFF-* 必须由 Blake 承担且须过 Gate 3/4，是角色分离的读取侧禁令，无宽词标记但确属强制"),
("AGENTS.md","62"):("已有:角色分离","","### Role separation；零标记但仍属纪律·理由：Alex 不写实现、Blake 不独立重设计、角色切换人触发——角色分离纪律的核心声明，无宽词标记"),
("AGENTS.md","67"):("新增:压缩后自检恢复（非候选新增）","","### Post-compact recovery；零标记但仍属纪律·理由：每次回复前须自检是否掌握当前 handoff/模式，不确定则重读 session-state 与快照再激活——压缩后恢复纪律"),
("AGENTS.md","74"):("新增:记忆权威分层（非候选新增）","","- `memory/` is Claude's native capture layer; Codex roles read it but never treat it as authoritative；记忆权威分层：.tad/memory/ 仅捕获层非权威，共享知识权威是 project-knowledge/"),
("AGENTS.md","79"):("新增:平台绑定交互决策","","### Interaction decisions；零标记但仍属纪律·理由：AskUserQuestion 交互决策契约（跨 harness 绑定、编号选项、决策点枚举）在 AGENTS.md 的镜像声明，与 alex SKILL 平台绑定条款同条纪律"),
("AGENTS.md","94"):("非纪律","R3","## Default Behavior (no role specified)；无角色时的默认助手行为（读 NEXT.md、列 handoff、提示角色）"),
("AGENTS.md","105"):("非纪律","R3","## Capability Packs (Domain Expertise)；能力包触发机制描述（关键词匹配时先读 SKILL.md）"),
("AGENTS.md","131"):("非纪律","R4","## Codex-Specific Notes；Codex 平台特有注意事项（hooks 配置、平台覆盖变量）"),
(".tad/config-workflow.yaml","7"):("非纪律","R3","# Smoke alarm only: produces reports + suggestions, never auto-modifies files；文档管理系统配置（manifest/命名/生命周期参数）"),
(".tad/config-workflow.yaml","177"):("非纪律","R3","zombie_window_days: 60；drift_check 漂移检查配置（zombie 窗口、ghost 前缀清单）"),
(".tad/config-workflow.yaml","200"):("非纪律","R3","tad_maintain:；文档维护命令配置（check/sync/full 模式）"),
(".tad/config-workflow.yaml","223"):("已有:配对测试","","pair_testing:；零标记但仍属纪律·理由：4D 协议配对测试配置（sessions/brief/report/issue 路由）即配对测试纪律的实现参数，无宽词标记"),
(".tad/config-workflow.yaml","269"):("非纪律","R5","migration: \"Use Feedback Collector (handoff §8.5 feedback_required: true)\"；已废弃命令的迁移说明（DEPRECATED 元数据）"),
(".tad/config-workflow.yaml","332"):("已有:需求澄清","","format: \"必须获得明确确认\"；需求挖掘配置：强制多轮确认（3-5 轮）、浅层响应强制重新进入流程"),
(".tad/config-workflow.yaml","458"):("已有:需求澄清","","description: \"写 handoff 之前必须用 AskUserQuestion 工具进行苏格拉底式提问\"；苏格拉底提问协议（blocking: true，不提问直接写 handoff = VIOLATION，Gate 2 检查 Inquiry Summary）——其子键 goals、complexity_detection 等 2 项是实现子项，未独立成条"),
(".tad/config-workflow.yaml","606"):("非纪律","R3","# ⚠️ Intentionally empty signal_words — Alex MUST NOT auto-detect *express；意图路由配置（7 模式表与优先级，express 显式触发）——其子键 modes、express、description 等 3 项是路由配置子项，非独立纪律"),
(".tad/config-workflow.yaml","710"):("非纪律","R3","user_confirmation: required；场景工作流模板（new_project/bug_fix 的 agent 工作流与强制 subagent 清单）"),
(".tad/config-workflow.yaml","777"):("非纪律","R3","research_notebook:；研究笔记本生命周期阈值与回退链配置"),
(".tad/config-workflow.yaml","801"):("非纪律","R3","feedback_collector:；反馈收集器配置（artifact_types/dimensions/JSON schema 引用）"),
(".tad/config-quality.yaml","7"):("新增:subagents强制调用","","warning: \"⚠️ VIOLATION: {violation_message}\"；强制调用规则：agent_a/agent_b 各场景 must_call 清单与违规处理（自动检测、阻止继续执行直到调用）"),
(".tad/config-quality.yaml","57"):("非纪律","R5","gate_checklist_source: \".tad/gates/gate-canonical-checklist.md\"；canonical 清单 SSOT 指针（元数据）"),
(".tad/config-quality.yaml","59"):("已有:门禁","","violation_action: \"禁止提交给Agent B\"；质量门控配置：gate1-4 检查项、Ralph Loop/专家证据、两条 knowledge_assessment blocking、git_commit_verification——其子键 gate3_v2_implementation_integration、knowledge_assessment、gate_responsibility_matrix 等 12 项是门控实现子项，未独立成条"),
(".tad/config-quality.yaml","309"):("新增:检查点证据验证（非候选新增）","","required_evidence_types:；所有关键检查点须提供可验证证据（search_result/code_location 等 6 型，mandatory_for 绑定 MQ 与 Phase 报告）"),
(".tad/config-quality.yaml","393"):("新增:六个强制问题","","blocking: true；强制回答问题系统：MQ1-6 从历史失败提炼、触发即须回答并附证据，Alex 必须在 handoff 包含'强制问题回答'章节，证据缺失阻止提交——其子键 enabled、questions、evidence_format 等 6 项是实现子项，未独立成条"),
(".tad/config-quality.yaml","571"):("新增:渐进式分阶段验证（非候选新增）","","mandatory_checkpoint: \"每个Phase完成时Blake必须提供证据，Human必须审查\"；渐进式验证：Phase 化交付、每阶段证据与 Human 检查点；区间含 subagent_enforcement_v13 强制段"),
(".tad/config-quality.yaml","690"):("新增:产物证据链","","# MANDATORY: Subagent 必须输出，Gate 检查文件存在；subagent 输出模板与证据路径（gate_3/gate_4 模板 + 审查证据文件存在性 blocking）——其子键 storage、mandatory、evidence_path、enforcement 等 9 项是证据链实现子项，未独立成条"),
(".tad/config-execution.yaml","7"):("已有:Ralph Loop自检","","config_file: \".tad/ralph-config/loop-config.yaml\"；零标记但仍属纪律·理由：Ralph Loop 配置引用（Layer 1 自检、Layer 2 专家审查、熔断、状态持久化）即该纪律的配置载体，无宽词标记"),
(".tad/config-execution.yaml","23"):("非纪律","R1","autoresearch:；可选的 Layer 0.5 优化模式（仅 handoff 含 optimization_target 时激活）"),
(".tad/config-execution.yaml","52"):("新增:版本发布管理（非候选新增）","","gates_required: [\"gate3\", \"gate4\"]；版本发布管理：release_checklist 4 项 blocking、API NEVER 删除/修改字段、发布分工与 forbidden 清单——其子键 agent_responsibilities、release_checklist、pre_release 等 6 项是实现子项，未独立成条"),
(".tad/config-execution.yaml","212"):("非纪律","R3","learning_mechanisms:；学习机制描述（四维度、机制清单、指标）"),
(".tad/config-execution.yaml","336"):("新增:失败学习闭环（非候选新增）","","required_evidence: \"[证据类型]\"；失败学习闭环：Human 纠正/测试失败 → Failure Learning Entry → 提案 → Human 审核 → 自动更新配置"),
(".tad/config-cognitive.yaml","7"):("新增:技术决策透明","","decision_transparency:；零标记但仍属纪律·理由：每个重要技术决策必须可见、经研究、由人拍板（decision_triggers 分类与 presentation 格式），无宽词标记但为独立纪律"),
(".tad/config-cognitive.yaml","120"):("新增:研究先行","","blocking: true；研究先行协议：设计前必做 landscape 搜索（min_queries 3）、至少 2 候选对比、无证据链接 = VIOLATION——其子键 description、violations 等 2 项是实现子项，未独立成条"),
(".tad/config-cognitive.yaml","181"):("新增:致命操作强制人审（非候选新增）","","⚠️ RISK DETECTED: {operation_description}；致命操作防护：数据丢失/泄露/财务/服务崩溃四类 forced_review、safety_net 路径模式、handoff_awareness 放行"),
(".tad/config-cognitive.yaml","278"):("非纪律","R5","integration:；集成点索引（alex/blake/gate 流程插入位置）"),
(".tad/config-agents.yaml","7"):("新增:强制激活协议（非候选新增）","","activation_protocol:；零标记但仍属纪律·理由：强制 4 步激活流程（身份加载/确认、配置加载、能力展示），跳过任何步骤即警告并重新激活"),
(".tad/config-agents.yaml","36"):("已有:角色分离","","# Terminal 隔离规则 (v1.8.0 新增) ⚠️ CRITICAL；核心三角模型：terminal 隔离 BLOCKING（人类唯一信息桥梁）、Alex/Blake 强制职责与禁止行为清单——其子键 terminal_isolation、violation、detection 等 8 项是角色分离实现子项，未独立成条"),
(".tad/config-agents.yaml","158"):("已有:需求闸","","required_sections:；交互协议与 Human 角色：handoff 必需 7 段落、用户交互 1-9 格式、human_role_v13 参与点（gate2 证据审查、phase checkpoints）——其子键 violation_alerts、format 等 5 项是实现子项，未独立成条"),
(".tad/config-agents.yaml","291"):("非纪律","R1","rule: \"Agent Teams MUST NOT cross terminal boundaries\"；Agent Teams 实验性配置（experimental: true，其隔离禁令已由角色分离覆盖）"),
(".tad/config-platform.yaml","7"):("已有:角色分离","","description: \"MCP tools enhance TAD agents but are NOT required for core functionality\"；MCP 工具配置：本体推荐模式非强制，但 forbidden_mcp_tools（Alex 禁用 Blake 域工具）与 pre_flight HALT 是角色分离/就绪检查的实例——其子键 agent_a_tools、enforcement、violation_format 等 3 项是实现子项，未独立成条"),
(".tad/config-platform.yaml","231"):("非纪律","R1","important_notes:；MCP 非必需声明（ENHANCEMENTS not REQUIREMENTS、失败不阻止进度）"),
}

assert len(J) == 60, f"judgments {len(J)} != 60"
rows = []
for f, s, name in blocks:
    key = (f, s)
    assert key in J, f"missing judgment for {f}:{s}"
    dest, reason, core = J[key]
    sk = subkeys.get(key, [])
    sklist = ",".join(dict.fromkeys(sk)) if sk else "-"
    if sk:
        # hand-written explanation must mention 子键 + at least one of this block's subkeys
        if "子键" not in core or not any(k in core for k in sk):
            raise SystemExit(f"row for {f}:{s}: core must explain its {len(sk)} subkeys (mention 子键 + a subkey name)")
    sentence = core
    hits = hitsmap.get(key, "?")
    rows.append([f, s, name, dest, reason, sentence, hits, sklist])

# self-check: fragment presence + hits>=1 fragment line hits wide markers (same logic as verify)
for i, r in enumerate(rows):
    f, s, e = ranges[i]
    text = run(f'sed -n "{s},{e}p" "{R}/{f}"')
    sent = r[5]
    frag = None
    for k in range(len(sent)):
        j = k
        while j < len(sent) and sent[k:j+1] in text:
            j += 1
        if len(sent[k:j].encode("utf-8")) >= 12:
            frag = sent[k:j]
            break
    if frag is None and not (max((len(ln) for ln in text.split("\n")), default=0) < 12 and "name: gate" in sent):
        raise SystemExit(f"row {i+1}: no fragment in range: {f}:{s}")
    if int(r[6]) >= 1 and frag is not None:
        hitline = any(marker_re.search(ln) and frag in ln for ln in text.split("\n"))
        if not hitline:
            raise SystemExit(f"row {i+1}: hits>=1 but fragment line not on marker line: {f}:{s}")

out = "\n".join("\t".join(r) for r in rows) + "\n"
OUT = f"{R}/.tad/evidence/designs/discipline-inventory/disposition-60.md"
open(OUT, "w", encoding="utf-8").write(out)
print(f"wrote {OUT} ({len(rows)} rows)")
