# TAD × Claude Code 原生能力 — 事实性重叠矩阵 (2026-07-12)

> **锚点问题**: 截至 2026-07,Claude Code / Claude 生态的原生能力全貌是什么?TAD 各机制与这些能力的事实性关系(重复/冲突/互补/无关)及实际行为差异是什么?
> **纪律**: 本文档只做事实描述与证据指向,**不做退役/改造/保留裁决**(用户明确要求裁决另起一步,防止结论污染证据收集)。
> **证据基**: 23 源 NotebookLM notebook (b07a6598) + 5 条 seed ask 链(1130 行 findings)+ 基线报告 + 第一方 harness 内省(2026-07-12 live Fable 5 session)+ TAD 机制清单(112 行,tad-mechanism-inventory.md)。
> **关系词定义**:
> - **重复 DUPLICATE**: 原生能力做的事与 TAD 机制实质相同(即使实现路径不同)
> - **冲突 CONFLICT**: 两套指令同时生效时会把模型往不同方向拉(用户感知的"双腿走路")
> - **互补 COMPLEMENTARY**: 原生提供 TAD 所建立其上的底座,或 TAD 覆盖原生文档明确不做的部分
> - **无关 UNRELATED**: 无原生对应物

---

## 0. 结构性发现(先读这个)

### 0.1 指令注入层级差 = "双腿打架"的机械成因
- 原生 auto-memory 指令注入在 **system prompt 层**(每个会话、任何命令之前、无条件存在)。
- TAD knowledge 指令在 **skill 层**(仅当 /alex /blake 被调用后加载)+ CLAUDE.md 路由层。
- 同一个"记录经验"时刻,两套指令同时在场;system 层指令始终在前且被框架标注为默认行为 → 模型倾向写 memory 而非 knowledge。**这是用户观察到的现象的直接机械解释**(内省文档 §2 + 清单 cross-cutting §a)。

### 0.2 原生功能演进速度(churn 事实)
2026-01→07 半年内(S2 链,版本号见 ask-findings):Agent Teams(v2.1.32 research preview → v2.1.178 **breaking change**,TeamCreate/TeamDelete 工具被移除改为自动 session-derived teams)、Dynamic Workflows(v2.1.154,关键词 v2.1.160 从 `workflow` 改名 `ultracode`)、/ultrareview(v2.1.111 → v2.1.178 并入 `/code-review ultra`)、Advisor(v2.1.117 experimental)、Agent Hooks(v2.1.50 experimental)、Skill stacking(v2.1.199)。**半年内 3 个改名/合并/破坏性变更** — 任何绑定原生 API 表面的机制都承受此变更速率。

### 0.3 官方 best-practices 已文档化的工作流模式(与 TAD 核心同构)
S4 链证实官方文档现在直接推荐:
1. **Spec-first interview**: 用 AskUserQuestion 让 Claude 访谈用户逼出边界情况 → spec 落盘 → **开全新 session 零上下文执行** ≈ TAD 苏格拉底提问 + handoff + 终端隔离。
2. **Writer/Reviewer 双会话**: Session A 实现,Session B 全新无偏上下文审查 ≈ Alex/Blake 隔离的审查半边。
3. **对抗性辩论 agent team**: 队员持竞争性假设互相证伪 ≈ TAD 对抗审查/tournament。
4. **独立 subagent diff review**: 只看 diff+AC、不看对话历史的新鲜上下文审查 ≈ Gate 3 独立审查原则(evidence-not-claims)。

### 0.4 原生明确不做的(S5 链文档化空白)
- **无生产级跨会话知识蒸馏/整理系统**: 去重靠 prompt 规则("Update, don't duplicate"),归档靠 MEMORY.md 逼近 200 行/25KB 时的提醒,清理靠人工 /memory 编辑或 `claude project purge`。无自动老化/权重衰减/跨会话合并。
- 无跨角色(写者≠蒸馏者)知识锻造概念。
- Hooks 不能绕过 interactive permission prompt(AskUserQuestion 类工具);SessionEnd 默认超时仅 1.5s。

### 0.5 直接可用的原生调节旋钮(S1 链)
- `autoMemoryEnabled: false` / `CLAUDE_CODE_DISABLE_AUTO_MEMORY=1` / `/memory` 交互开关 / `--bare`:**关闭** auto-memory。
- `autoMemoryDirectory`(settings,绝对路径或 ~/,project 级需 workspace trust):**重定向** memory 写入位置。
- `disable-model-invocation: true`(skill frontmatter):skill 对模型完全隐藏,零上下文成本,仅 /name 手动调用。
- subagent `memory` 字段:给 subagent 配持久目录跨会话积累知识;subagent `skills` 字段全量预载。

---

## 1. 重叠矩阵(按 TAD 类别)

### A. Knowledge & Memory

| TAD 机制 | 原生对应物 | 关系 | 行为差异证据 |
|---|---|---|---|
| Project Knowledge L1/L2/L3(principles/patterns/incidents) | auto-memory(MEMORY.md 索引 + topic files)+ CLAUDE.md @import + `.claude/rules/`(路径作用域规则文件) | **冲突 + 部分重复** | 存储位:`.tad/project-knowledge/`(repo 内、可 git、可 sync)vs `~/.claude/projects/<slug>/memory/`(repo 外、用户本地、不随 repo 走)。触发:TAD 靠 gate KA 强制;native 靠模型自发。粒度:TAD typed schema(failure_mode 必填)vs native typed frontmatter(user/feedback/project/reference)。**两者都会在"总结经验"时刻抢写** |
| Blake journal(原始日记) | auto-memory 写入时机(修正/偏好/任务完成时) | **部分重复** | journal 是 per-handoff 追加型原始记录、明确禁止提炼;memory 是即时提炼型单条事实 — 时机重叠、哲学相反(curse-of-knowledge 原则) |
| Distillation loop(陌生人蒸馏,Alex 读 Blake journal) | 无 | **无关(TAD 独有)** | S5 链证实原生无跨会话 curation 系统、无跨角色蒸馏概念;native memory 是 single-writer |
| knowledge-maintain(hash 去重/4-way reconcile/usage retire) | MEMORY.md 200 行逼近时的重组提醒(prompt 级) | **互补** | TAD 是结构化协议+脚本;native 是 nudge。功能目标同(防知识库腐化),深度不同 |
| TAD Brain / brain-index 搜索 | Explore agent + Grep + codebase-memory MCP | **部分重复** | brain-index 加了策展的类别地图;native 是通用检索 |
| Knowledge Assessment(Gate 3/4 BLOCKING) | 无(memory 写入无 gate 概念) | **无关(TAD 独有)** | native 写 memory 无强制检查点 |
| Subagent 持久知识(TAD 无直接对应,靠 project-knowledge 共享) | **subagent `memory` 字段**(per-subagent 持久目录,跨会话) | **新原生能力,TAD 侧无对应** | 2026 新增;TAD 的知识是全局共享的,native 提供 per-agent 私有积累 |

### B. Session & State

| TAD 机制 | 原生对应物 | 关系 | 行为差异证据 |
|---|---|---|---|
| session-state.md + post-compact recovery(CLAUDE.md §4.5) | 自动 compaction + **root CLAUDE.md 压缩后自动重注入** + MEMORY.md 启动重读 + --resume/--continue | **重复(大部分)** | S1/S3 链:root CLAUDE.md 现在原生 survive compaction;skills 压缩后按 25K 预算重挂;native 明确告知模型"无需提前收尾"。TAD 独有部分:Current Position/mode/handoff-path 的语义级恢复锚 |
| NEXT.md(跨会话任务清单) | TaskCreate/TaskList(harness 任务系统)+ auto-memory project 型记忆 | **部分重复** | NEXT.md 跨会话、进 git;native task list 会话级+通知集成 |
| Ralph state yaml(机器可恢复执行状态) | Workflow resumeFromRunId(journal 缓存前缀) | **部分重复** | 同为断点续跑;粒度不同(Ralph=层级重试计数;Workflow=agent 调用缓存) |
| Zombie handoff 检测 | 无 | 无关 | — |

### C. Quality Gates

| TAD 机制 | 原生对应物 | 关系 | 行为差异证据 |
|---|---|---|---|
| Gate 3 Layer 2 专家审查链(≥2 distinct reviewers) | `/code-review`(effort 分级,ultra=多 agent 云审查)+ `/security-review` + 官方 Writer/Reviewer & independent-diff-review 模式 | **重复(功能)+ 冲突(TAD 明文禁用原生版)** | TAD skill exclusion list 禁 /code-review 并自建同功能审查链 — 清单 cross-cutting §b12 已把这标为结构类。审查原则同构(fresh context、只看 diff+AC) |
| Gate 3/*accept 的 PreToolUse 强制 hooks(pre-gate-check.sh 12 项) | **Agent-verifier hooks**(v2.1.50: hook spawn 带 Read/Grep/Glob 的验证 subagent,50 turn 上限,返回 `{ok:false,reason}` 可把理由塞回主 agent 让它继续迭代) | **重复 + 演进差** | TAD 2026-04-15 因"fail-closed 无自恢复"拒绝了机械 enforcement(principles.md SAFETY);native agent hooks 恰好补了自恢复(reason 回注 + Stop hook 阻断带指导)。TAD 现存 hooks 是静态 bash 检查;native 新增了智能验证层 |
| /verify(跑起来看行为) | 同名原生 skill | **重复(功能域)** | TAD acceptance verification scripts(per-AC 可执行脚本)是自建版;native /verify 是通用版 |
| Rubric eval / trajectory judge | 无直接对应(agent hooks 可作载体) | 互补 | TAD 的 5 维评分与金标集是自建资产 |
| Socratic inquiry(Rule 0 BLOCKING) | **官方 spec-first interview 模式**(AskUserQuestion 访谈,best-practices 文档化)+ plan mode | **重复(模式)+ 冲突(EnterPlanMode 被 TAD 禁用)** | 官方版:访谈→spec 落盘→fresh session 执行。TAD 版:3-5 轮结构化+复杂度缩放+ICP/边界/AC 共定义。TAD 更结构化;官方已收编基本形 |
| 专家审查 min 2 + P0 阻断(Gate 2) | /code-review 可对 spec 前置?(文档只对 diff)| **部分无关** | 原生审查绑定 diff/PR;TAD Gate 2 审查的是设计文档(handoff)— 原生无 design-doc review 产品 |
| Pair testing 4D | claude-in-chrome 浏览器自动化 + /verify | 互补 | 人机配对测试协议无原生对应 |

### D. Handoff & 流程编排

| TAD 机制 | 原生对应物 | 关系 | 行为差异证据 |
|---|---|---|---|
| Handoff 文档(Blake 唯一信息源)+ 终端隔离 | 官方 spec-first(spec 落盘+fresh session)+ Agent Teams(独立 context 会话,lead 协调,共享任务列表,P2P 消息) | **重复(形态)** | Agent teams v2.1.178 后自动 session-derived;TAD 靠人肉桥接。官方 fresh-session 执行 = handoff 的"零上下文污染"原则。TAD 独有:handoff 的 11 节结构化契约(frontmatter 驱动分支/AC 矩阵/friction preflight) |
| 两agent模型(Alex 设计/Blake 实现,人是唯一桥) | Agent Teams + Writer/Reviewer 官方模式 | **重复(角色分离)+ 哲学差** | native 桥是自动的(lead agent 协调);TAD 桥是人(刻意的 human-in-the-loop 设计,AI/Human Judgment Domain Awareness 原则)。**分离本身已原生化,人桥是 TAD 的刻意选择而非能力缺口** |
| yolo-epic / surplus-execute / 10 个自定义 workflow | Workflow 工具(ultracode)本身 | **互补(层叠)** | TAD workflows 是原生 Workflow 工具的用户;不重复,是构建其上 |
| Epic 生命周期(3 active cap,phase 状态机) | 无(任务列表+teams 是弱对应) | 无关 | — |
| Blake worktree(*develop --worktree) | Agent `isolation:"worktree"` + EnterWorktree 工具 | **重复** | 同为 git worktree 隔离;TAD 版带 merge/PR/keep/discard 收尾菜单。TAD 已知 yolo-epic worktree false-FAIL 问题正是两层 worktree 语义没对齐的产物(session-state 系统教训) |
| Intent router / adaptive complexity | 无直接对应(plan mode 是最近似) | 大体无关 | — |

### E. Feedback & UX

| TAD 机制 | 原生对应物 | 关系 | 行为差异证据 |
|---|---|---|---|
| Feedback Collector(overlay HTML + 元素级 verdict/comment + JSON 导出 + read_feedback_protocol 闭环) | **AskUserQuestion preview 字段**(side-by-side 渲染 markdown 预览,选项对比)+ claude-in-chrome(浏览器内交互) | **部分重复** | preview 解决"选哪个方案"(≤4 选项、一次性);Feedback Collector 解决"对这个成品的 N 个元素逐个给意见"(元素级、结构化、可迭代 supersedes 链)。粒度不同,时刻不同(选择时 vs 交付后)。原生无"交付物元素级反馈"产品 |
| Plain-language 解释规则 | 原生沟通规范(system 级 "lead with outcome; 为离开又回来的队友写") | **部分重复** | 精神同源;TAD 版有 reader-value 测试三问 |

### F. Research

| TAD 机制 | 原生对应物 | 关系 | 行为差异证据 |
|---|---|---|---|
| *research 统一入口(Quick/Standard/Deep,NotebookLM 持久知识库) | /deep-research skill + WebSearch/WebFetch | **重复(功能域)+ 冲突(TAD 明文禁用原生版)** | CLAUDE.md 明确排除 /deep-research;理由是持久积累(notebook)vs 一次性报告。原生 deep-research 是多阶段 web 方法论、无持久库 |
| 对抗研究挑战(Codex/Gemini,DR-20260531 carve-out) | **Advisor 工具**(/advisor,v2.1.117:咨询第二模型做 second opinion,支持 opus/sonnet/fable/任意 model ID) | **部分重复(新)** | Advisor 是会话内、模型可选(含跨供应商 endpoint);TAD 版是 CLI 外呼 Codex/Gemini、有 NOT_via_alex_auto 约束与显示+可覆盖机制。功能目标同(防 tunnel vision) |
| research-github 周扫描 | CronCreate 云端定时 agents(/schedule)+ /loop | **互补(载体)** | TAD 的扫描逻辑可跑在原生 cron 载体上;目前 scan-log last_scan=null(routine 未跑) |
| Research decision protocol(DR 记录) | 无 | 无关 | — |

### G. Skill 捕获与 Capability Packs

| TAD 机制 | 原生对应物 | 关系 | 行为差异证据 |
|---|---|---|---|
| save-skill / save-workflow(对话→本地 skill) | **skill-creator plugin**(官方,评估+迭代自定义 skills)+ skill stacking(v2.1.199) | **重复(功能域)** | TAD 版刚建成(2026-07-12 merge!)——LLM-draft+确认+local-only 隔离;官方 plugin 覆盖创建+评估。细节对比未深挖(follow-up 候选) |
| Skillify T1/T2/T3 + *harvest(跨项目收割) | 无(plugin marketplace 是远亲) | 无关(TAD 独有) | ≥2-project 晋升逻辑无原生对应 |
| Capability Packs(24 packs) | **就是原生 skills**(SKILL.md/渐进加载/描述触发) | **互补(层叠)** | Packs 是原生 skill 系统的内容资产;TAD 附加的是 build/eval/registry/parity 机械。`disable-model-invocation`、subagent `skills` 预载等新旋钮 packs 尚未使用 |
| Pack awareness ≤2 + collision 检测 | Skill stacking(≤5 个 leading skills 同载) | **部分冲突** | TAD 上限 2(rule-soup 防护,principles.md);native 允许 5。两条规则同时在场时数字打架 |

### H. Release/Sync、Cross-Model、Anti-Rationalization、Hooks

| TAD 机制 | 原生对应物 | 关系 | 行为差异证据 |
|---|---|---|---|
| *publish/*sync/release-verify/deny-list | plugin/marketplace 生态(远亲) | 大体无关(TAD 独有) | 框架自分发机械无原生对应 |
| Codex adapter + AGENTS.md | AGENTS.md 是跨工具开放约定(agents.md);Codex CLI 原生读 | 互补 | — |
| NOT_via_alex_auto + anti-rationalization registry + friction protocol | 无(原生 permission 系统是机械近亲) | 无关(TAD 独有) | prompt 级自我审查模式无原生对应 |
| TAD hooks(SessionStart 健康注入/trace/pre-gate) | 原生 hook 系统(事件面 2026 扩展:compaction、permission、subagent、teammate 事件 + agent-verifier 类型) | **互补(层叠)+ 机会面** | TAD hooks 建于原生 hook 系统上;2026 新增事件(如 compaction 相关)TAD 尚未使用 |
| EnterPlanMode 禁令 / skill exclusion list | plan mode / deep-research / code-review 本体 | **显式冲突管理**(TAD 主动压制原生) | 清单 §12 标注的"结构性覆盖类":TAD 禁用 3 类原生能力并内部重实现 — 这是"双腿走路"感受的第二来源(第一来源是 §0.1 层级差) |

---

## 2. 冲突热区排序(按用户感知强度,事实描述)

1. **Memory vs Knowledge**(§0.1 + A 表):system 层 vs skill 层,唯一一个"每天都在打架"的;有原生 disable/redirect 旋钮存在。
2. **原生审查/研究/规划 被 TAD 明令禁用后内部重实现**(C/F 表 + 清单 §12):/code-review、/deep-research、EnterPlanMode。禁令文本每 session 注入,而原生能力每 session 存在 → 恒定张力。
3. **官方工作流模式与 TAD 核心流程同构**(§0.3):不是运行时冲突,而是"两套同构方法论并存"的认知负担来源。
4. **Skill 数量规则打架**(G 表):TAD max-2 packs vs native stacking ≤5。
5. **双层 worktree 语义**(D 表):已实际造成 3 次 false-FAIL(session-state 教训 #2)。

## 3. TAD 无原生对应物清单(事实,非"护城河"裁决)

蒸馏循环(陌生人锻造)/ Knowledge Assessment gates / handoff 11 节契约 + frontmatter 分支 / Epic 状态机 / design-doc 级专家审查(Gate 2)/ Skillify 跨项目晋升 + *harvest / release-sync 机械 / anti-rationalization registry / friction protocol / 元素级交付物反馈(Feedback Collector 的核心交互)/ pair-testing 4D / 决策记录 DR 体系。

## 4. 研究未覆盖 / 待验证(honest gaps)

- Codex CLI 侧 memory 现状只有 AGENTS.md 约定层证据,Codex 自身 memory 机制未深挖(Q9 未单独成链;openai/codex 源已入库可追问)。
- skill-creator plugin 与 save-skill/save-workflow 的逐项功能对比未做。
- Agent Teams 的 cost/协调上限具体数字在 S5 答案中较薄。
- `.claude/rules/` 的 path-scoping 细节已入库(S2b)但未与 TAD config 模块逐项对照。
- Phase 4c 对抗审查未执行(Codex auth 过期 + Gemini 无 key,双缺 auto-PASS)— 本矩阵未经第二模型挑战,置信度相应打折。
- 本研究的 web 源皆为官方文档/公告(Tier 1 为主),第三方实战经验(社区对这些新功能的翻车报告)未采样。

## 5. 证据文件索引

| 文件 | 内容 |
|---|---|
| harness-introspection-2026-07-12.md | 第一方内省(ground truth) |
| 2026-07-12-baseline-report.md | NotebookLM 基线报告 |
| 2026-07-12-ask-findings.md | 5 条 seed 链 + 追问(1130 行,含全部版本号引用) |
| tad-mechanism-inventory.md | TAD 112 机制清单 + 注入层级 + 内部重复簇 |
| challenge-log.md | Phase 0c/4c 对抗审查降级记录 |
| REGISTRY: claude-native-capabilities (b07a6598) | 23 源可持续追问 |
