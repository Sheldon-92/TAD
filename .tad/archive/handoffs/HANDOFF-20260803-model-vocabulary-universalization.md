---
handoff_id: HANDOFF-20260803-model-vocabulary-universalization
date: 2026-08-03
from: alex
to: blake
task_type: mixed
priority: P1
epic: none (step 3 of 3, Codex Universalization 三单计划)
version: v3
---

# HANDOFF: Model-Vocabulary Universalization（词汇通用化单，三单收官）

## 1. Goal & Why

**Goal**: 把 TAD 框架协议文本中最后一层 Anthropic/Claude-Code 专属词汇改为
harness/model 通用形式，使同一份 SKILL 在 Claude Code（Anthropic 或 DeepSeek 中转）、
Codex（GPT 系）及未来 harness 上语义完整、可执行、可审计。

**Why now**: 三单计划前两单已修好接线（stopbleed）与知识入口（knowledge-ingress）。
剩余耦合全部在词汇层，其中一类是**事实错误**（内联注释指向不存在的 Codex 工具名
`ask_user_question`，与台账 `ask_user_question_hook` 行 accepted_limitation 结论矛盾）。

**Grounding（Alex 扫描 + Gate 2 两轮双专家实证，2026-08-03；本节所有命令输出
均为 Alex 亲跑复核）**:
- `Codex: ask_user_question` 坏注释 5 处：`alex/SKILL.md:325`、
  `alex/references/{bug,idea,learn}-path-protocol.md`、`blake/SKILL.md:191`。
- 强档定义 "opus / fable 级" 硬编码：alex-lite L227-228、blake-lite L240-241（+镜像 ×2）。
- Model 捕获只有 Claude 分支：blake-lite L316/L330-341、alex-lite L70-74。
- full 通道专家模板**三份副本**：
  (a) `blake/SKILL.md:1385` `expert_prompt_template:`（嵌套 mapping，`rule: |` 下
      10 空格缩进，`NOT ALLOWED:` L1404 收尾）；
  (b) `alex/references/handoff-creation-protocol.md:752` `expert_prompt_template: |`
      （flat 字面标量，4 空格缩进，`NOT ALLOWED:` L784，其后 `OUTPUT FORMAT:` L788；
      L794-797 紧邻 `minimum_experts: 2` 与 2 条 violations SAFETY 行）
      —— alex/SKILL.md 本体无此块（L493 仅 reason 字符串提及）；
  (c) `.claude/workflows/handoff-review.workflow.js` L218-241 JS 字符串副本。
      **R2 实证：该副本是语义移植而非逐字副本**（缺 EXPLICIT BLAST-RADIUS CHECKS
      与 OPTIONAL TOOLS 两节、多一条 review-only bullet、个别措辞改写），
      其 "expert_prompt_template verbatim (INV-4)" 注记今天就不实；
      其 REVIEW_SCHEMA/AUDIT_ROW_SCHEMA 均无 model 字段。
- AskUserQuestion 治理集活推导（`git grep -l 'AskUserQuestion' --
  '.claude/skills/*/SKILL.md'`，Alex 亲跑 = **11 个文件**，LC_ALL=C 排序）：
  agent-computer-interface、alex-lite、alex、blake、playground、research-github、
  research-notebook、save-skill、tad-maintain、tad-test-brief、tad。
  **Alex 裁决（Gate 2 R2 双专家一致建议）**：`agent-computer-interface` 虽为能力包，
  其 L76 "Must use AskUserQuestion before proceeding" 是**权限升级的人工确认硬门**
  （L1 Playwright → L5 Computer Use 类跨层升级），正是绑定条款要保护的 SAFETY 类
  ——**纳入治理集**。alex-lite 的 2 处（L148 频次上限、L336 禁令）非调用点，
  但条款仍加（覆盖其 references）。playground 已 DEPRECATED，条款照加
  （无害，Completion 注明 dead-weight）。blake-lite 0 hits 不在集合内。
- 其他活耦合：`alex/references/acceptance-protocol.md:123`（"Spawn fresh Sonnet
  judge"）、`.tad/config-agents.yaml:326`（`teammate_model: "sonnet"       #
  Teammates use Sonnet`）、`.tad/eval/judge/README.md:5`（"(model: sonnet)"，
  R2 新发现，同类耦合）。
- Codex 侧实测（R1+R2 reviewer，codex-cli 0.146.0 本机）：顶层
  `model = "gpt-5.6-sol"`、`model_reasoning_effort = "medium"`；route 不走 env——
  非默认 endpoint 在 `[model_providers.<id>]` 表 `base_url`，由顶层
  `model_provider = "<id>"` 选择；`[agents] default_subagent_model` +
  `~/.codex/agents/*.toml` per-agent 文件是 sub-agent（reviewer）模型/推理档指定处
  （实测 terra-reviewer.toml = `high`，恰为审查 agent）；推理档阶梯
  `minimal < low < medium < high`；`OPENAI_API_BASE` 是 openai-python 遗产变量，
  非 codex-cli 键。

## 2. Scope（Files to Modify）

| # | File | 改动 |
|---|------|------|
| 1 | `.claude/skills/alex-lite/SKILL.md` | §A 档位表 + §B3 逐字替换 + §C 条款 |
| 2 | `.claude/skills/blake-lite/SKILL.md` | §A 档位表 + §B1/B2 逐字替换 |
| 3 | `.claude/skills/alex/SKILL.md` | §C 条款 + L325 注释修正 |
| 4 | `.claude/skills/blake/SKILL.md` | §C 条款 + §D(a) 自报 + L191 注释修正 |
| 5 | `.claude/skills/alex/references/handoff-creation-protocol.md` | §D(b) 自报（`OUTPUT FORMAT:` 前，4 空格缩进） |
| 6 | `.claude/skills/alex/references/{bug,idea,learn}-path-protocol.md` | 注释修正 ×3 |
| 7 | `.claude/skills/{tad-maintain,research-notebook,research-github,playground,tad,tad-test-brief,save-skill,agent-computer-interface}/SKILL.md` | §C 条款 ×8 |
| 8 | `.claude/workflows/handoff-review.workflow.js` | §D(c) 自报行 + INV-4 注记改"semantic port" |
| 9 | `.claude/skills/alex/references/acceptance-protocol.md` | §E L123 档位化 + 校准警示 |
| 10 | `.tad/config-agents.yaml` | §E L326 注释替换（值不动） |
| 11 | `.tad/eval/judge/README.md` | §E L5 档位化标注（同 L123 语义） |
| 12 | `.tad/portable-rules.md` | 仅 L27 末列单元格内追加指针 |
| 13 | `AGENTS.md` | Critical Rules 新增 `### Interaction decisions` 小节 |
| 14 | `.tad/runtime-compat/codex.md` | `ask_user_question_hook` 行 notes 增补（status 不变） |
| 15 | `.agents/skills/**` 镜像 | 仅经 `release-verify.sh parity --fix`，Completion 附 --fix 原始输出 |
| 16 | `.tad/evidence/acceptance-tests/model-vocab-universalization/` | AC 脚本 + baseline.md（pre-edit SHA + 11 元素治理集） |

## 3. Design

### §A Reviewer 档位 → 能力档位表（lite ×2，byte-symmetric）

替换两个 lite SKILL 各自的强档定义两行。现文本（两文件相同，逐字）：
```
- 强档定义：opus / fable 级（经 Agent tool `model` 参数显式指定）；
  haiku / 小型 flash 类不构成强档
```
新文本（两文件相同）：
```
- 强档定义：按能力档位判定，不按 SKU——强档 = 所在 provider 的旗舰推理档
  （示例：Anthropic opus/fable 级；OpenAI gpt-5 高推理档；DeepSeek v4-pro 级）；
  小型/经济档不构成强档（示例：haiku、gpt-*-mini、v4-flash 类）。
  示例名随版本演进，判定标准是档位而非具体 SKU。
  推理档参数化的 SKU（阶梯 minimal < low < medium < high）：强档要求旗舰 SKU 且
  推理档 ≥ high；档位判定不确定 → 按非强档保守处理，走三选一。
  指定方式：经当前 harness 的 sub-agent 显式 model 指定
  （Claude Code = Agent tool `model` 参数；Codex = `[agents]`
   `default_subagent_model` 及 per-agent `agents/*.toml` 配置）；
  route=unknown 按 alias-mapped 保守处理（走三选一），
  不得按 native 分支自行 spawn 强档 reviewer。
```
保留不动：判定"生产关键"条款、三选一 (a)(b)(c)、REVIEWER-TIER-DEGRADED 逐字格式、
"Reviewer 行必须记录 reviewer 自报的 model 身份"条款。

### §B Model 行捕获纪律加 harness 分支（lite ×2）

**B1 blake-lite 格式行**（L316 逐字现文本）：
```
  **Model**: harness={claude-code|codex} | model={运行时自报模型 ID} | route={ANTHROPIC_BASE_URL 的 host，未设置则 native}
```
新文本：
```
  **Model**: harness={claude-code|codex|other} | model={运行时自报模型 ID} | route={当前 harness 的 base-URL host，未设置则 native；无法判定则 unknown}
```

**B2 blake-lite 捕获纪律第 1 条**（L330-335 以 "1. route 与 model 机械捕获" 起始的
整条）替换为：
```
1. route 与 model 按 harness 分支捕获（机械命令 + 一处 section 归属人工核对；
   env 无输出/文件或键缺失 = native 直连，fail-soft，不得因缺失报错）：
   - claude-code 分支（现行不变）：
     `env | grep -E '^ANTHROPIC_(BASE_URL|MODEL|SMALL_FAST_MODEL)='`；
     `jq -r '.model // "unset"' ~/.claude/settings.json 2>/dev/null`；
     `jq -r '.model // "unset"' .claude/settings.json 2>/dev/null`。
   - codex 分支：CFG="${CODEX_HOME:-$HOME/.codex}"；
     `env | grep -E '^OPENAI_BASE_URL='`（只记变量名与 host，不落 key）；
     `grep -E '^(model|model_provider|model_reasoning_effort)[[:space:]]*=' "$CFG/config.toml" 2>/dev/null`；
     `grep -nE '^[[:space:]]*base_url[[:space:]]*=' "$CFG/config.toml" 2>/dev/null`；
     `grep -rE '^(model|model_reasoning_effort)[[:space:]]*=' "$CFG/agents/"*.toml 2>/dev/null`
     （reviewer 实际档位在 per-agent 文件，可覆盖 default_subagent_*）。
     route = 顶层 `model_provider = "<id>"` 所选 `[model_providers.<id>]` 表的
     base_url host；无 model_provider/base_url 且无 OPENAI_BASE_URL → native。
     表内匹配需人工核对 section 归属（[agents]/[projects] 表内同名键不作数）。
   - other/未知 harness 分支：model 自报 + route=unknown 显式标注，不得伪造；
     unknown 在档位规则中按 alias-mapped 保守处理。
   会话内 /model 运行时覆盖优先级最高，用户切过必须逐字记录。
```
第 2 条（alias-mapped 冲突）与第 3 条（跨 compaction 逐个列出）保留不动。

**B3 alex-lite 对应段**（L70-74 逐字现文本）：
```
   model 值格式与 Blake 侧一致：harness={claude-code|codex} | model={运行时自报 ID} |
   route={ANTHROPIC_BASE_URL 的 host，未设置则 native}；机械捕获：
   `env | grep -E '^ANTHROPIC_(BASE_URL|MODEL|SMALL_FAST_MODEL)='` +
   `jq -r '.model // "unset"' ~/.claude/settings.json .claude/settings.json 2>/dev/null`；
   聚合中转只解 route 不解底层模型，标 `(alias-mapped)`，不得当 ground truth）
```
新文本：
```
   model 值格式与 Blake 侧一致：harness={claude-code|codex|other} | model={运行时自报 ID} |
   route={当前 harness 的 base-URL host，未设置则 native；无法判定则 unknown}；
   捕获按 harness 分支（同 blake-lite Model 行捕获纪律：claude-code 用
   ANTHROPIC_* env + settings 两层 jq；codex 用 OPENAI_BASE_URL env +
   ${CODEX_HOME:-$HOME/.codex}/config.toml 的
   model/model_provider/model_reasoning_effort/base_url + agents/*.toml
   per-agent 覆盖；other → route=unknown）；
   聚合中转只解 route 不解底层模型，标 `(alias-mapped)`，不得当 ground truth；
   route=unknown 在档位规则中按 alias-mapped 保守处理）
```

### §C AskUserQuestion → 平台绑定交互决策（一次定义 per SKILL 本体，不改调用点）

**治理集 = §1 活推导的 11 个文件（含 agent-computer-interface，裁决见 §1）**，
逐字预注册进 baseline.md。推导命令即 SSOT；落地时推导集与 baseline 不一致
（新文件出现/文件消失）→ 停，报 Alex（§6 分支 2）。

**条款文本（11 个 SKILL 本体各加一次，置于激活协议/正文早段，各文件相同）**：
```
平台绑定交互决策（cross-harness binding）：本文件及其 references 中所有
AskUserQuestion 调用是「交互决策契约」而非具体工具——当前 harness 有该工具
（Claude Code）→ 直接调用；无该工具（Codex 等）→ 以编号纯文本列出全部选项
（1. … / 2. … / 3. …）并**停止等待用户输入**，用户以编号或自由文本作答；
禁止代答、禁止把选项折叠成默认值继续执行。SAFETY 门控的调用点（人工审批 /
归档确认 / 权限升级确认类）无论何种 harness 都必须获得真人作答后才能继续。
非交互执行模式（如 codex exec）→ 视为无人可答，按 blocked 停止并上报，
不得自选默认值；已按 YOLO/预授权模式运行且该决策点有书面预授权记录 →
按其协议处理，不适用本条 blocked 分支。
```

**内联注释修正**（5 处，见 §1）：
`<!-- Claude Code: AskUserQuestion / Codex: ask_user_question -->` →
`<!-- Claude Code: AskUserQuestion / Codex: numbered-options text（见平台绑定交互决策条款） -->`。
范围限 `.claude/skills` 与 `.agents/skills` 活树；`.tad/archive/` 与
`.tad/evidence/` 历史件不改写。

**portable-rules.md L27**：在该表行**末列单元格内、闭合 `|` 之前**追加
`（运行时权威见各角色 SKILL「平台绑定交互决策」条款）`（保持 markdown 表结构完整）。

**AGENTS.md**：Critical Rules 内新增独立小节（匹配既有 4 个 `###` 英文小节结构，
置于 `---` 结束线前）：
```
### Interaction decisions
All `AskUserQuestion` references in TAD skills are interaction-decision
contracts, not a literal tool: on harnesses without it, list numbered options
as plain text and STOP for the user's typed answer. SAFETY-gated decision
points (approvals, archive confirmations, permission escalations) always
require a real human answer (see 平台绑定交互决策 clause in each role SKILL).
```

**台账**：`ask_user_question_hook` 行 status 逐字保持 `accepted_limitation`，
notes 增补 `runtime binding: numbered-options text fallback per role-SKILL
平台绑定交互决策条款 (2026-08-03)`；last_verified 仅在真实重验时才改。

### §D full 通道 reviewer model 自报（三副本，各按其缩进契约）

新增行统一语义：reviewer 报告首行自报
`Model: harness={claude-code|codex|other} | model={运行时自报 ID} | route={host|native|unknown}`，
捕获按 §B 三分支（条款内联写三分支命令要点，**不得**以"同 lite"指代——
full 通道 reviewer 不加载 lite skill）。

- **(a) blake/SKILL.md L1385 块**：`rule: |` 体内、`NOT ALLOWED:` 前插入
  `REQUIRED OUTPUT (first line of every reviewer report):` 小节（10 空格缩进）。
  缺此行的 reviewer 报告在 Layer 2 证据中视为 provenance-incomplete，
  Completion 补记原因——不阻塞已有 verdict。
- **(b) handoff-creation-protocol.md**：`OUTPUT FORMAT:`（L788）前插入同语义小节
  （4 空格缩进）。缺行处理措辞用 Gate 2 侧："缺此行的专家审查记录在 Gate 2 证据中
  视为 provenance-incomplete，handoff Audit Trail 补记原因"。
- **(c) handoff-review.workflow.js**：JS 模板字符串加
  `'REQUIRED OUTPUT (first line of every reviewer report):\n'` 同语义段；
  **自报载体 = 落盘的 `review-<expert>.md` 首行**（evidence_path 所指文件）——
  REVIEW_SCHEMA/AUDIT_ROW_SCHEMA 本轮不动（见 §4 Non-Goals + follow-up）。
  同时把 L218 附近 "expert_prompt_template verbatim (INV-4)" 注记改为
  "semantic port of expert_prompt_template (narrow-scope parity; INV-4)"
  ——R2 实证该副本从来不是逐字（缺 2 节 + 多 1 bullet），注记须与事实一致。
- 定位约束：三处均不触碰相邻 `forbidden_implementations` / `anti_rationalization` /
  `hard_requirement_distinct_reviewers` / `violations:` / `minimum_experts` 任何一行
  （AC5c/AC5e 机械核验）。

### §E 杂项活耦合

- **acceptance-protocol.md L123**：`Spawn fresh Sonnet judge subagent` →
  `Spawn fresh mid-tier judge subagent（judge 校准基线为 Anthropic Sonnet，
  2026-07-02；非 Anthropic harness 用同档模型并在报告标注 uncalibrated-judge，
  分数仅 advisory）`（同行 paths-only/NEVER provide golden set 等原有约束逐字保留）。
- **config-agents.yaml L326**：整行替换为（值不动，注释替换）：
  `    teammate_model: "sonnet"       # Claude-Code 值；其他 harness 取同档（capability-tier: mid）`
- **eval/judge/README.md L5**：`(model: sonnet)` →
  `(model: sonnet — 校准绑定档位；非 Anthropic harness 用同档并标 uncalibrated-judge)`。

## 4. Non-Goals（明确不做）

- 不重写 references/ 与 SKILL 正文中的 AskUserQuestion 调用点（条款覆盖）。
- 不改 lite 哨兵 ESCALATION-LIST 区块（md5 ×4 不变）。
- 不动 portable-rules.md 除 L27 外任何行。
- 不做认证 re-probe（Spike C/D/E）——独立 follow-up 单。
- 不给 full 通道加 reviewer 强档规则（只加自报可审计性）。
- 不改能力包教学内容中的模型名（agent-computer-interface 因 SAFETY 硬门裁决入集，
  是唯一例外）；不改 `.tad/config.yaml:322`、`express-path-protocol.md:22` 等
  历史 rationale prose。
- 不改 `.tad/routing-contract.yaml`（model 字段格式无耦合，R1 已核）。
- **不动 handoff-review.workflow.js 的 REVIEW_SCHEMA / AUDIT_ROW_SCHEMA**——
  Audit Trail 表本轮保持 model-blind，自报以 review-<expert>.md 首行为载体；
  schema 加 model 字段登记为 follow-up（防 scope 扩散）。

## 5. AC（executable；全部 grep/awk/jq/comm 基线工具 + `grep -F` 固定串，禁止 rg；
`comm` 输入一律 `LC_ALL=C sort`；AC 脚本内 `grep -rl` 无匹配 exit 1，
在 `set -e`/pipefail 下须 `|| true` 防成功态自杀；脚本置于
`.tad/evidence/acceptance-tests/model-vocab-universalization/`；
所有递归 grep 显式以 `.claude/skills .agents/skills` 为根——冻结 fixture
`.tad/evidence/acceptance-tests/codex-wiring-stopbleed/ac9-codex-only/` 含 5 处
历史锚，禁止纳入统计，此为排除理由书面记录）

- AC1（档位表 ×4 树）: 4 个 lite SKILL 各
  `grep -cF '按能力档位判定，不按 SKU'` =1、`grep -cF '强档定义：opus / fable 级'` =0、
  `grep -cF 'route=unknown 按 alias-mapped'` ≥1、`grep -cF '按非强档保守处理'` =1、
  `grep -cF 'minimal < low < medium < high'` =1。
- AC2（Model 捕获 ×4 树）: 4 个 lite SKILL 各同时满足（合取，不是择一）：
  `grep -cF 'CODEX_HOME'` ≥1 ∧ `grep -cF 'config.toml'` ≥1 ∧
  `grep -cF 'route=unknown'` ≥1 ∧ `grep -cF 'model_reasoning_effort'` ≥1 ∧
  `grep -cF 'OPENAI_BASE_URL'` ≥1 ∧ `grep -cF 'ANTHROPIC_BASE_URL 的 host'` =0。
- AC3（交互条款）:
  (a) 活推导 `git grep -l 'AskUserQuestion' -- '.claude/skills/*/SKILL.md'` 输出与
  baseline.md 预注册 11 元素集 set-equality（`LC_ALL=C sort` + `comm -3` 空），
  且集内每文件 `grep -cF '平台绑定交互决策'` ≥1（.claude 树；.agents 树经 AC6
  parity 覆盖）；
  (b) `{ grep -rl 'Codex: ask_user_question' .claude/skills .agents/skills || true; } | wc -l` =0；
  (c) AGENTS.md `grep -cF '### Interaction decisions'` =1 ∧
  `grep -cF '平台绑定交互决策'` ≥1；
  (d) portable-rules.md line-set diff 差集恰为 L27 旧/新各一行，且新行
  `grep -cF '条款） |'` =1——指针在末列单元格内、闭合 `|` 之前（表结构完整）。
- AC4（自报三副本）: blake/SKILL.md、handoff-creation-protocol.md、
  handoff-review.workflow.js（前两者含镜像）各 `grep -cF 'Model: harness='` ≥1 ∧
  `grep -cF 'REQUIRED OUTPUT'` ≥1；段界分别验证：blake 侧 awk
  `expert_prompt_template:`→`NOT ALLOWED:` 段内含新增行；alex 侧 awk
  `expert_prompt_template: |`→`OUTPUT FORMAT:` 段内含新增行；workflow 侧
  `grep -cF 'semantic port of expert_prompt_template'` =1（INV-4 注记已改）。
- AC5（SAFETY 不变量）:
  (a) 复用 `.tad/evidence/acceptance-tests/lite-review-hardening/AC-05-sentinel-preservation.sh`
  → exit 0（md5 `4c55bcb6563f24dc78449fb19ff76067` ×4）；
  (b) 内容级逐块 diff：blake/SKILL.md 与 handoff-creation-protocol.md 两文件，
  awk 抽取每个 `forbidden_implementations:` / `anti_rationalization` 标题至缩进
  回落处的块内容（含全部条目行），pre/post 各 `LC_ALL=C sort` 后 `comm -3` = 空
  （tad-maintain 无此类块，对其做此检查是空对空，不列入——其守护是 (d)）；
  (c) blake/SKILL.md `hard_requirement_distinct_reviewers` 块 pre/post byte-diff 相等；
  (d) tad-maintain/SKILL.md `grep -Fq 'Criterion C and D MUST NOT auto-archive'`
  存活（`-Fq` 片段匹配，非 `-x` 整行）；
  (e) handoff-creation-protocol.md 三行全文存活（`grep -Fq` 逐条）：
  `minimum_experts: 2`、
  `- "不经过专家审查直接发送 handoff 给 Blake = VIOLATION"`、
  `- "忽略专家发现的 P0 问题不修复 = VIOLATION"`。
- AC6（回归护栏，只证明未破坏、不证明工作量）: `release-verify.sh parity .` PASS；
  `skill-body-verify.sh` PASS；`runtime-freshness-verify.sh .` 21/21 PASS 0 BLOCK exit 0。
- AC7（台账）: codex.md `ask_user_question_hook` 行按 `-F'|'` 取 status 字段逐字
  `accepted_limitation`；notes 字段 `grep -cF 'numbered-options'` ≥1；
  last_verified 变更 ⇔ Completion 含当日真实重验证据。
- AC8（注册行集）: Blake 开工前把 pre-edit worktree 入 baseline commit、SHA 记入
  baseline.md（immutable-baseline 纪律）；line-set diff 限 §2 文件集两向执行，
  FORWARD-missing/REVERSE-added 逐行归因注册编辑，未注册差异 =0。
- AC9（codex 键名再证）: Blake 本机 `codex --version` + §B2 四条捕获命令复跑留
  原始输出；键名与 §B 不符 → 以实测为准修正并在 Completion 标注映射（§6 分支 1）。
- AC10（§E 三处）:
  (a) acceptance-protocol.md `grep -cF 'Spawn fresh Sonnet judge'` =0 ∧
  `grep -cF 'uncalibrated-judge'` =1 ∧ `grep -Fq 'NEVER provide golden set'` 存活；
  (b) config-agents.yaml `grep -cF 'teammate_model: "sonnet"'` =1（值未动）∧
  `grep -cF 'capability-tier: mid'` =1 ∧ `grep -cF '# Teammates use Sonnet'` =0；
  (c) eval/judge/README.md `grep -cF 'uncalibrated-judge'` =1。

## 6. Friction / Degradation（预注册分支）

1. codex CLI 或 config.toml 本机不可得 → AC9 降级为官方文档引用（URL + retrieval
   date），命令 fail-soft 原样落地，标 DEGRADED_WITH_APPROVAL
   （授权来源 = 本节 + Gate 4 人批）。
2. §C 活推导集与 baseline.md 预注册 11 元素集不一致（新文件/文件消失）→
   停，报 Alex 裁决；不得自行增删治理集。
3. 任何 AC 与 SAFETY 不变量冲突 → 停，回 Alex；不得自行改 AC。
4. workflow JS 副本中 `'NOT ALLOWED:'` 或 `'OUTPUT FORMAT:'` 字符串字面量不存在
   → 停，报 Alex（真实漂移信号；已知的语义移植差异——缺 2 节、多 1 bullet、
   措辞改写——为合法现状，见 §1，不触发本分支）。

## 7. Constraints

- 镜像纪律：只编辑 `.claude` 侧；`.agents` 仅经 `release-verify.sh parity --fix`
  单向同步；Completion 附 --fix 原始输出。`.claude/workflows/` 无镜像
  （已核 `.agents/workflows` 不存在），单侧编辑。
- SAFETY 邻区纪律（2026-05-31 L1）：line-set diff 为 ground truth；改写引用约束的
  prose 保留约束名逐字引文；`grep -Fxq` 只用于引用了**完整行**的锚
  （片段锚一律 `grep -Fq`）。
- Alex 不写实现码；人是唯一桥梁；commits 不推送（与 step 1+2 同批，用户决定）。
- Blake journal 原始材料落 `.tad/evidence/journal/`；蒸馏归 Alex Gate 4。

## 8. Audit Trail

- v1 drafted 2026-08-03 by Alex。
- **Gate 2 R1**（双专家并行，均自报 harness=claude-code / model=claude-opus-5[1m] /
  route=native）：code-reviewer FAIL（P0×2+P1×7+P2×9）；backend-architect
  CONDITIONAL（P0×2+P1×5+P2×7，含 codex-cli 0.146.0 本机实证）。合并独立 P0×3：
  ①alex 模板真身/三副本不同构 ②AC5b 标题级 diff 非判别 ③§C allow-list 谬误。
  → v2 全数处置。
- **Gate 2 R2 增量复核**（同两位 reviewer）：R1 全部 P0/P1 确认 RESOLVED
  （判别探针重跑：AC5b 现抓 24 行条目内容 vs v1 的 0；AC4 三副本段界均 1/1；
  §A 推理档规则实测命中 terra-reviewer=high）。新增发现全数吸收进 v3：
  - P0-A（两位重叠）：活推导实际含 `agent-computer-interface`（v1/v2 清单凑数）
    → Alex 裁决入集（其 L76 为权限升级 SAFETY 硬门），11 元素集逐字入 §1/§2/baseline；
  - N1：AC5d `-Fxq` 片段锚必假 FAIL → 改 `-Fq`，§7 明确 -x 只配完整行；
  - N2：tad-maintain 无 forbidden 块，AC5b 对其空对空 → 显式移出 AC5b，
    守护改由 AC5d 承担；
  - N4：§E 零 AC 覆盖 → 新增 AC10（三处）；
  - N5：§D(b) 最近邻 `minimum_experts`/`violations` 无守护 → 新增 AC5e 全行存活；
  - P1-B：§6 分支 4 触发条件今天即真（JS 是语义移植）→ 分支 4 重定义为真实漂移
    信号（字面量缺失），已知差异记为合法现状，INV-4 注记改 "semantic port"；
  - P1-C：workflow 自报无载体（schema 无 model 字段）→ 载体定为
    review-<expert>.md 首行，schema 不动列 Non-Goal + follow-up；
  - N3/P0-A 同源已并；N6 L27 单元格内追加；N7 AC2 改合取；N8 config-agents
    整行钉死；N9 L783→L784；P2-D 机械捕获措辞改"+ 一处人工核对"；P2-E 恢复
    OPENAI_BASE_URL env 探针；P2-F per-agent toml 捕获 + 阶梯内联；P2-G AGENTS.md
    独立 `### Interaction decisions` 小节；P2-H YOLO 预授权 carve-out 句；
    P2-I eval/judge/README.md L5 入 §2/§E/AC10c；P2-J AC3b `|| true`。
- v3 finalized 2026-08-03。两轮合计 P0×4 全 dispositioned，Gate 2 关闭条件：
  R2 双 verdict 均为 CONDITIONAL 且全部阻塞项已在 v3 落文（残余 P2 均已吸收）。
