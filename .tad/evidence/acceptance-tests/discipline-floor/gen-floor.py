#!/usr/bin/env python3
# Generate .tad/discipline-floor.md from Blake's judgments + frozen Step 0 inputs.
import subprocess, re, os
import subprocess as _sp
R = _sp.run(["git","rev-parse","--show-toplevel"],capture_output=True,text=True).stdout.strip()
assert R, "must run inside the TAD git repo"
EV = f"{R}/.tad/evidence/acceptance-tests/discipline-floor"
K30 = f"{R}/.tad/archive/handoffs/HANDOFF-20260816-discipline-floor.keys30.tsv"
WIDE = open(f"{EV}/wide-markers.txt", encoding="utf-8").read().rstrip("\n")
marker_re = re.compile(r"(?:" + WIDE + r")")

def run(cmd):
    return subprocess.run(cmd, shell=True, capture_output=True, text=True, encoding="utf-8").stdout

verdicts = [l.rstrip("\n").split("\t") for l in open(f"{EV}/verdicts.tsv", encoding="utf-8")]
keys = {}
for l in open(K30, encoding="utf-8"):
    n, k = l.rstrip("\n").split("\t")
    keys[n] = k
assert set(keys) == {v[0] for v in verdicts}

# (name) -> (循环?, 载体, 锚点, 触发串, Layer, 定档依据, 不可降级, 解除待判)
M = {
"需求澄清":("否",".tad/config-workflow.yaml","description: \"写 handoff 之前必须用 AskUserQuestion 工具进行苏格拉底式提问\"","必须执行需求澄清：description: \"写 handoff 之前必须用 AskUserQuestion 工具进行苏格拉底式提问\"","0","既有判定","否","-"),
"需求闸":("否",".claude/skills/gate/SKILL.md","## Gate 1: Requirements Clarity (Alex) - Optional Quick Check","必须复核需求闸：## Gate 1: Requirements Clarity (Alex) - Optional Quick Check","0","既有判定","否","-"),
"重量裁定":("否",".claude/skills/alex/SKILL.md","# ⚠️ MANDATORY: Adaptive Complexity Assessment (First Contact)","# ⚠️ MANDATORY: Adaptive Complexity Assessment (First Contact)","1","既有判定","否","-"),
"专家审查（多视角）":("否",".claude/skills/gate/SKILL.md","- [ ] Expert review complete (min 2)","Gate 2 必须执行：- [ ] Expert review complete (min 2)","1","既有判定","否","-"),
"门禁":("否",".claude/skills/gate/SKILL.md","规则 1: Alex 创建 handoff → 必须先执行 Gate 2","规则 1: Alex 创建 handoff → 必须先执行 Gate 2","0","既有判定","否","-"),
"启动扫描":("否",".claude/skills/alex/SKILL.md","激活时必须跑健康/依赖/研究/僵尸四类扫描","启动扫描必须执行：激活时必须跑健康/依赖/研究/僵尸四类扫描（健康检查 / 依赖演进 / 研究图景 / 僵尸 handoff）","0","既有判定","否","常驻既定，无解除待判需求"),
"知识评估":("是",".claude/skills/gate/SKILL.md","# ⚠️ KNOWLEDGE ASSESSMENT (BLOCKING - Part of Gate 4)","# ⚠️ KNOWLEDGE ASSESSMENT (BLOCKING - Part of Gate 4)","0","待判默认","否","需要「蒸馏循环停跑」的可机械检测信号（如 Gate 3/4 的 KA 检查缺失时显式告警）方能判定非循环，否则触发事件只在本体内部知晓"),
"跨模型审查":("无法判定",".claude/skills/blake/SKILL.md","cross_model_invocation:","跨模型审查必须按需：cross_model_invocation:","0","待判默认","否","需要定义跨模型审查的具体触发场景（当前触发条件字段为空，无法判定循环性）"),
"配对测试":("否",".tad/config-workflow.yaml","pair_testing:","配对测试必须执行：pair_testing:","1","循环触发实测","否","触发事件（真机/真外部系统任务出现）由任务声明自知，需 P2b 后实测其出现频率以校准 Layer"),
"角色分离":("否","AGENTS.md","- Alex does not write implementation code, Blake does not independently redesign","角色分离必须：- Alex does not write implementation code, Blake does not independently redesign","0","既有判定","否","-"),
"Execution Mandate":("无法判定",".claude/skills/blake-lite/SKILL.md","### Execution Mandate 准入（⚠️ BLOCKING）","### Execution Mandate 准入（⚠️ BLOCKING）","0","待判默认","否","需要 lite 单实际运行的 mandate 违约案例记录以定义触发条件（当前为空，无法判定循环性）"),
"约束准入":("是",".claude/skills/blake-lite/SKILL.md","## 约束准入（新增约束前必须定价）","## 约束准入（新增约束前必须定价）","0","待判默认","否","需要台账超期扫描的机械告警（而非人工自查）方能判定非循环，「流程重量失控」目前只在本体内部可见"),
"AC可执行性检查":("否",".claude/skills/gate/SKILL.md","step2: \"对每一行，实际执行其 Verification Method（grep/命令/脚本）\"","AC 可执行性必须实跑：step2: \"对每一行，实际执行其 Verification Method（grep/命令/脚本）\"","0","既有判定","否","-"),
"Friction反跳过":("否",".claude/skills/blake/SKILL.md","# Missing dependency, auth, approval, reviewer, or setup friction is NEVER a skip reason.","# Missing dependency, auth, approval, reviewer, or setup friction is NEVER a skip reason.","0","既有判定","否","-"),
"Ralph Loop自检":("否",".claude/skills/blake/SKILL.md","## 🔄 Ralph Loop (TAD v2.42.0)","## 🔄 Ralph Loop (TAD v2.42.0) 自检必须执行","1","既有判定","否","-"),
"研究先行":("否",".tad/config-cognitive.yaml","research_first:","研究先行必须执行：research_first:","1","循环触发实测","否","触发事件（技术选型/架构决策出现且未先搜索）由设计流程自知，需实测设计阶段搜索步骤的真实执行率"),
"技术决策透明":("否",".tad/config-cognitive.yaml","decision_transparency:","重要技术决策必须透明：decision_transparency:","1","循环触发实测","否","触发事件（重要技术决策出现）自知，需实测决策记录的实际留存率"),
"平台绑定交互决策":("否",".claude/skills/alex/SKILL.md","平台绑定交互决策（cross-harness binding）：本文件及其 references 中所有","平台绑定交互决策必须执行（无 AskUserQuestion 的 harness 激活时自知）：平台绑定交互决策（cross-harness binding）：本文件及其 references 中所有","1","循环触发实测","否","harness 类型激活时自知（alex:335 已有内联指针），需跨 harness 实测其遵守率"),
"六个强制问题":("否",".tad/config-quality.yaml","mandatory_questions:","六个强制问题必须执行：mandatory_questions:","1","循环触发实测","否","MQ 触发由设计情境（历史代码/函数存在性/数据流等）自知，需实测 MQ 回答的证据完整率"),
"subagents强制调用":("否",".tad/config-quality.yaml","subagents_enforcement:","subagent 强制调用必须执行：subagents_enforcement:","1","循环触发实测","否","must_call 场景命中由任务结构自知，需实测子代理调用日志的完整性"),
"产物证据链":("否",".claude/skills/blake/SKILL.md","step3c: \"Git commit + evidence ls-check (Phase 3 anchor B-01) + Slug Contract (layer2-audit 2026-04-15)","产物证据链必须执行：step3c: \"Git commit + evidence ls-check (Phase 3 anchor B-01) + Slug Contract (layer2-audit 2026-04-15)","1","循环触发实测","否","Gate 3/4 证据检查与完成报告书写自知，需实测证据缺失时的拦截率"),
"激活知识预读":("否","AGENTS.md","- Every role activation reads `.tad/project-knowledge/principles.md` and","激活知识预读必须执行：- Every role activation reads `.tad/project-knowledge/principles.md` and","1","循环触发实测","否","角色激活事件自知，需实测激活时知识预读的遵守率"),
"压缩后自检恢复":("否","AGENTS.md","### Post-compact recovery","压缩后自检恢复必须执行：### Post-compact recovery","1","循环触发实测","否","压缩事件由 harness 触发、agent 自检时自知，需实测压缩后恢复率"),
"记忆权威分层":("否","AGENTS.md","- `.tad/memory/` is Claude's native capture layer; Codex roles read it but never","记忆权威分层必须执行：- `.tad/memory/` is Claude's native capture layer; Codex roles read it but never","1","循环触发实测","否","跨平台记忆读取时自知，需实测 Codex 侧记忆读取行为"),
"检查点证据验证":("否",".tad/config-quality.yaml","mandatory_checkpoint: \"每个Phase完成时Blake必须提供证据，Human必须审查\"","mandatory_checkpoint: \"每个Phase完成时Blake必须提供证据，Human必须审查\"","1","循环触发实测","否","MQ/Phase 报告检查点自知，需实测无证据断言的频率"),
"渐进式分阶段验证":("否",".tad/config-quality.yaml","progressive_validation:","渐进式分阶段验证必须执行：progressive_validation:","1","循环触发实测","否","大任务规模在启动时预判自知，需实测长任务检查点缺失率"),
"版本发布管理":("否",".tad/config-execution.yaml","release_management:","版本发布管理必须执行：release_management:","1","循环触发实测","是","版本发布/API 变更事件自知，需实测发布清单执行率；不可降级（发布回归代价不可逆）"),
"失败学习闭环":("否",".tad/config-execution.yaml","failure_learning_loop:","失败学习闭环必须执行：failure_learning_loop:","1","循环触发实测","否","Human 纠正/测试失败/Bug 报告事件自知，需实测失败条目转化率"),
"强制激活协议":("否",".claude/skills/blake/SKILL.md","## ⚠️ MANDATORY 4-STEP ACTIVATION PROTOCOL ⚠️","## ⚠️ MANDATORY 4-STEP ACTIVATION PROTOCOL ⚠️","1","循环触发实测","否","角色激活事件自知（SKILL 顶部即协议本身），需实测激活步骤遵守率"),
"致命操作强制人审":("否",".tad/config-quality.yaml","description: \"Risk filter for operations that could cause irreversible damage\"","致命操作必须人审：description: \"Risk filter for operations that could cause irreversible damage\"","1","循环触发实测","否","致命操作命中时 agent 自知（risk 卡片），需实测人审放行率"),
}
assert set(M) == {v[0] for v in verdicts}, "judgment set mismatch"

# 副表: (项, 载体, 锚点, 触发串)
SUB = [
("身份与角色分离载体","AGENTS.md","## Role Switching","## Role Switching Use $alex / $blake (full TAD — **the default**) 必须"),
("意图路由",".tad/config-workflow.yaml","# ⚠️ Intentionally empty signal_words — Alex MUST NOT auto-detect *express","# ⚠️ Intentionally empty signal_words — Alex MUST NOT auto-detect *express"),
("复杂度判定",".claude/skills/alex/SKILL.md","adaptive_complexity_protocol:","adaptive_complexity_protocol: 必须先做复杂度判定 ⚠️"),
("压缩恢复锚点","AGENTS.md","read `.tad/active/session-state.md` and the newest","压缩恢复必须：read `.tad/active/session-state.md` and the newest"),
("反合理化登记",".claude/skills/alex/SKILL.md","<!-- anti_rationalization_registry:BEGIN -->","<!-- anti_rationalization_registry:BEGIN --> 反合理化必须登记"),
("Forbidden 清单本体",".claude/skills/alex/SKILL.md","# Forbidden actions (will trigger VIOLATION)","# Forbidden actions (will trigger VIOLATION) 必须遵守"),
]

# ── self-check anchors/triggers ──
errs = []
def in_carrier(anchor, carrier):
    try:
        return anchor in open(f"{R}/{carrier}", encoding="utf-8").read()
    except FileNotFoundError:
        return False
for name in verdicts:
    n = name[0]
    cyc, carrier, anchor, trig, layer, basis, undeg, rel = M[n]
    key = keys[n]
    if not os.path.exists(f"{R}/{carrier}"): errs.append(f"{n}: carrier missing")
    if not in_carrier(anchor, carrier): errs.append(f"{n}: anchor not in carrier")
    if len(anchor.encode()) < 12: errs.append(f"{n}: anchor <12B")
    if not re.search(key, anchor, re.I): errs.append(f"{n}: anchor no key match ({key})")
    if trig.find(anchor) < 0: errs.append(f"{n}: trigger no anchor")
    if not marker_re.search(trig): errs.append(f"{n}: trigger no wide marker")
    if len(trig.encode()) < 12: errs.append(f"{n}: trigger <12B")
for item, carrier, anchor, trig in SUB:
    if not in_carrier(anchor, carrier): errs.append(f"SUB {item}: anchor not in carrier")
    if len(anchor.encode()) < 12: errs.append(f"SUB {item}: anchor <12B")
    if trig.find(anchor) < 0: errs.append(f"SUB {item}: trigger no anchor")
    if not marker_re.search(trig): errs.append(f"SUB {item}: trigger no wide marker")
if errs:
    raise SystemExit("\n".join(errs[:12]))

# ── build document ──
def fbytes(s): return len(s.encode("utf-8"))
lines = []
lines.append("# 地板表 —— 30 条纪律的载体该常驻还是按需（P2b 产物）")
lines.append("")
lines.append("## 主表（30 条）")
lines.append("纪律\t既有判定\t通道\t触发条件\t循环?\t载体路径\t锚点串\t触发串\tLayer\t定档依据\t不可降级\t解除待判需要什么")
for v in verdicts:
    n = v[0]
    cyc, carrier, anchor, trig, layer, basis, undeg, rel = M[n]
    rel2 = rel
    if rel2 == "-" and v[1] == "地板": rel2 = "常驻既定，无解除待判需求"
    if rel2 == "-" and v[1] == "可缩放": rel2 = "按需定档既定，无解除待判需求"
    lines.append("\t".join([n, v[1], v[2], v[3], cyc, carrier, anchor, trig, layer, basis, undeg, rel2]))
lines.append("")
lines.append("## 副表（Layer 0 里的非纪律常驻项）")
lines.append("项\t载体\t锚点串\t触发串")
for r in SUB:
    lines.append("\t".join(r))
lines.append("")

# Layer-0 computation
main_rows = []
for v in verdicts:
    n = v[0]
    cyc, carrier, anchor, trig, layer, basis, undeg, rel = M[n]
    main_rows.append((n, v[1], v[2], v[3], cyc, carrier, anchor, trig, layer, basis, undeg, rel))
layer0 = [r for r in main_rows if r[8] == "0"]
full0 = [r for r in layer0 if r[2] in ("both", "full")]
lite0 = [r for r in layer0 if r[2] in ("both", "lite")]
both0 = [r for r in layer0 if r[2] == "both"]
def tbytes(rows, idx): return sum(fbytes(r[idx]) for r in rows)
carrier_files = {}
for r in main_rows: carrier_files.setdefault(r[5], 1)
for r in SUB: carrier_files.setdefault(r[1], 1)
carrier_total = sum(os.path.getsize(f"{R}/{f}") for f in carrier_files if os.path.exists(f"{R}/{f}"))

lines.append("## Layer 0 实测")
lines.append(f"full 激活 Layer0: 行数 {len(full0)} 触发串合计 {tbytes(full0, 7)} bytes")
lines.append(f"lite 激活 Layer0: 行数 {len(lite0)} 触发串合计 {tbytes(lite0, 7)} bytes")
lines.append(f"共有(both)      : 行数 {len(both0)} 触发串合计 {tbytes(both0, 7)} bytes")
lines.append(f"副表            : 行数 {len(SUB)} 触发串合计 {tbytes(SUB, 3)} bytes")
lines.append(f"触发串所在载体文件当前整读合计: {carrier_total} bytes   ← P7 前的真实下界")
lines.append("")
lines.append("> ⚠️ 口径警告：本数为触发串之和（bytes），SC1 的 107.7K 为单次 full 激活的整读量（tokens 口径），两者不可直接比较。且 lite 行不计入 SC1（lite 已冻结，默认路径不付）。")
lines.append("")
lines.append("## 清单缺口")
lines.append("**凭据/密钥**：30 条纪律中无对应纪律行（实测命中 0）——凭据处理规则散落在平台/工具层（如 `config-platform.yaml` 的 `always_confirm`、`mcp_tools` 安全段），未形成独立纪律，引用 `EPIC-20260813-alex-blake-lightening.md` 风险表 #R6。")
lines.append("**修改框架自身**：同样无对应纪律行（实测命中 0）——该约束只活在 `CLAUDE.md:50`（§2.5 的冻结条款）与 lite skill 的冻结段，30 条主表中无一行覆盖；不可降级组仅版本发布管理一条（AC10 点名），上述两类缺口需 P3/P4/P7 补入时另行登记。")
lines.append("")
lines.append("## 承接单")
lines.append("`expert-criteria.yaml`（`.tad/ralph-config/expert-criteria.yaml:185-188`）security-auditor 触发：`type: pattern_match` + `pattern: auth|token|password|credential|api.*key|encrypt|decrypt|session|cookie|sql|query|upload|file|exec|eval`——该 pattern 匹配内容不匹配路径，且全仓库无任何脚本解析它（`.tad/config-execution.yaml` 的 `criteria_file` 仅是指针引用，无 sh/py/js 消费方）。")
lines.append("Blake 当场实测（命令可复算，口径：分母 = `git ls-files` 全量文件数，分子 = 文件级命中）：")
lines.append("1. 路径口径：`git ls-files | grep -Ec 'auth|token|password|credential|api.*key|encrypt|decrypt|session|cookie|sql|query|upload|file|exec|eval'` → **504/6743 = 7.47%**")
lines.append("2. 内容口径：对 `git ls-files` 逐文件 `grep -lE` 同一 pattern → **4990/6743 = 74.0%**")
lines.append("两口径相差一个数量级：若按路径匹配触发，74% 内容命中安全模式的改动会被漏触发（示例：`.agents/skills/_archived/api-design.md` 内容含 auth/token 但路径不命中）；且该文件无解析脚本，实际触发依赖 agent 自觉读 yaml。承接单：**`expert-criteria-wiring`**（把触发判定改为可执行脚本并按内容扫描，或显式声明降级为手工检查）。")
lines.append("")

out = "\n".join(lines)
open(f"{R}/.tad/discipline-floor.md", "w", encoding="utf-8").write(out)
print(f"wrote {R}/.tad/discipline-floor.md ({len(main_rows)} main rows, {len(SUB)} sub rows)")
print(f"Layer0: full {len(full0)} / lite {len(lite0)} / both {len(both0)}")
