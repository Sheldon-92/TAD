# HANDOFF: Codex 知识入口 + hook 信封归一化 + PreCompact 接线 (v3)

**Date**: 2026-08-03 | **From**: Alex | **To**: Blake（full 通道）
**Type**: standard（多组件，spike ×3）
**Series**: codex-universalization step 2/3（step 1 = 止血单 ✅ 已归档；step 3 = 词汇通用化单）
**Gate 2**: ✅ PASS（R1 双专家 6 P0 + 17 P1 + R2 增量 N1-N10 全处置，双专家均确认无需再轮；全记录见 Audit Trail）

## 1. 目标（为什么现在做——R1 修正后的问题陈述）

止血单让 Codex 侧"接线活了"；本单解决"活着但脑子是空的"。实测现状（R1 核正）：
1. **知识层零入口**：CLAUDE.md §7 用 `@import`（Claude-only 机械语法）加载知识文件
   （8 个声明中仅 3 个存在：principles 23.6KB + patterns/_index 2.2KB +
   frontend-design 3.6KB ≈ 29KB 有效负载）；§7.5 memory 层、§1 handoff 规则、
   §4 隔离、§4.5 恢复——AGENTS.md 均无等价物。
2. **Codex 侧 hook 实际接线与信封现实**（逐 hook 核对，.codex/hooks.json +
   hooks-platform-mapping.md）：
   - **真正触发**的 4 条：`startup-health.sh` + `notebook-dormant-sync.sh`
     （SessionStart，二者都解析 Claude 专属 `.source` 字段——post-compact 提醒分支
     在 Codex 上永不触发）、`post-write-sync.sh`（apply_patch）、
     `askuser-capture.sh`（事件可能永不发生，accepted_limitation）；
   - **未接线**的 2 条：`pre-gate-check.sh`/`pre-accept-check.sh`（Codex 无 Skill
     matcher，映射表明确 Omitted）——文档教用户手动跑，但实测手动路径**静默假绿**：
     `TOOL_NAME != "Skill"` 短路 + gate 号只从 `.tool_input.args` 读（`$1` 无效），
     `bash pre-gate-check.sh 3 </dev/null` → `{}` exit 0。
3. **Layer-0 post-compact 恢复有两半**：(a) PreCompact 写快照（Claude-only 接线）；
   (b) SessionStart(source==compact) 注入提醒（脚本存在但 `.source` 是 Claude 字段）。
   两半在 Codex 上都缺席；弱模型最先丢的 Layer-1 自检恰好是 Codex 上唯一防线，
   而它也未写进 AGENTS.md。
4. **止血单递延项**：detect-platform 信号表；镜像可执行 `.claude/` 路径
   （known-broken 清单，R1 扩充后见 §3.5）；brain-index-gen.sh 硬编码
   `SKILLS_DIR=.claude/skills`。

## 2. 不做什么

- Reviewer 档位/Model 捕获词汇、full 通道 reviewer model 自报条款 → step 3
- Workflow 编排移植、Route Contract 减重 → 独立议题
- `.tad/memory/` Codex 桥接：不做（共享记忆契约已定其为 Claude 原生捕获层）
- MEMORY.md gitignore 状态不动（隐私设计）
- ask_user_question 的 Codex 等价物不硬造；**台账 `ask_user_question_hook` 行维持
  `accepted_limitation`，禁止因 fixture 证据翻成 verified**（fixture 只证明"若触发
  不空转"，不证明"会触发"）
- blake L1843（skillify 产物写 `.claude/workflows/`）：合法不改——workflow.js
  是 Claude-only 能力，归 Workflow 移植议题（L1841 skill 创建路径已移入 §3.5
  条目 7——R2/N8：skill 是双树工件，不适用此豁免）
- `.tad/evidence/designs/extracts/` 缺失导致的 extract-diff 契约失效（两平台皆死，
  见 §3.5 honest note）：修复 fixture 属独立 follow-up，本单只做路径平台中立化

## 3. 设计

### 3.1 AGENTS.md 知识入口节

新增两节（位置：Role Switching 之后、Lite/Standard/Full Routing 之前——文件整体
每会话被 Codex 摄入，此为显著性排序）：

**A. `## Knowledge Ingress (read on activation)`**
- **无条件核心**（每次角色激活必读，逐字列路径）：
  `.tad/project-knowledge/principles.md`、`.tad/project-knowledge/patterns/_index.md`；
- **按需扩展**：patterns/_index 命中任务关键词 → 读对应 pattern 文件（≤3，同 lite
  预检纪律）；域知识文件（`frontend-design.md` 现存；`testing/ux/performance/
  api-integration/mobile-platform.md` 为 CLAUDE.md §7 声明但**当前不存在**的槽位）
  写成条件句："存在则按任务域选读"——AGENTS.md 文本不得把不存在的文件写成必读；
- **专项路由**：跨库知识检索 → 先读 `.tad/brain-index.md`；
  **编辑 `.tad/hooks/**` 任何 shell 文件前 → 必读
  `.tad/project-knowledge/patterns/shell-portability.md`**（R1：Claude 侧有
  `.claude/rules/shell-portability.md` 自动注入，Codex 无 rules 机制——路由到
  源头 pattern 而非摘录）；
- **Rationale 注释（R1 重写——原措辞含事实错误）**：真实不对称是**加载机制**
  （Claude @import = harness 机械保证、不可跳过；AGENTS.md = prompt-level 指令，
  随模型强度衰减）而非广度（Claude 有效负载 29KB ≈ 本节核心 26KB）。故核心清单
  必须短而祈使。**维护注记**：CLAUDE.md §7 新增知识文件时必须同步本节索引
  （两清单间无机械 verifier，靠此注记 + 后续 release 检查，follow-up 已记）；
- 红线：只指路不复制——不得把任何 project-knowledge 条目**正文**抄进 AGENTS.md。

**B. `## Critical Rules (platform-equivalent of CLAUDE.md §1/§4/§4.5/§7.5)`**：
- Handoff 读取规则：读 `HANDOFF-*` → 必须 Blake 角色 + Gate 3/4；豁免
  `/tad-maintain` CHECK/SYNC；**方向互斥**：full 角色一律忽略 `LITE-*`，
  `blake-lite` 只接受 `LITE-*`（R1：不得弱化为"LITE 走 lite 通道"一句）；
- 会话隔离：Alex 不写实现代码、Blake 不独立设计；角色切换由人触发；
- Post-compact 恢复（含 **Layer-1 自检**，R1：Codex 无 compact 提醒注入时这是
  唯一检测层）：**每次回复前自问——Blake：我知道当前 handoff 完整路径吗？
  Alex：我知道当前模式与在办 handoff 吗？答案为 NO/不确定 → 立即读
  `.tad/active/session-state.md` + 最新 `.tad/active/precompact/snapshot-*.md`，
  重新激活角色再继续**；
- Memory 层：`.tad/memory/` = Claude 原生捕获层，Codex 角色只读、永不权威；
  共享知识权威 = `.tad/project-knowledge/`（与 lite 共享记忆契约语义逐字一致）。

### 3.2 Hook stdin 信封归一化（Spike C 先决；消费者清单 R1 重排）

1. **Spike C（信封 shape）**：scratch `CODEX_HOME` + 受信 scratch 仓 +
   **workspace-write 沙箱**（read-only 下 apply_patch 永不触发——R1），探针 hook
   捕获 **stdin + `env` + `"$@"` argv 三通道**、**按事件分文件落盘**（单文件 `>`
   会被后续事件覆盖——R1）。目标事件：SessionStart（含是否存在 compact/source
   判别字段——§3.3 半边 (b) 的地基）与 PostToolUse(apply_patch)。
   无 stdin 投递 → 照实记录实际传参形态，归一化层按实测设计。
2. 新建 `.tad/hooks/lib/hook-envelope.sh`（**自含**：自带 TTY 守卫 + stdin 读取 +
   jq/grep 降级分支，不依赖 common.sh——precompact 的自含 fail-open 设计要求
   低依赖；common.sh 的 `read_stdin_json`/`get_json_field` 保留给非 hook 调用方，
   6 个 hook 消费者迁移到本层。此为对 Never-Hand-Write 的显式取舍：自含性优先，
   rationale 落 lib 头注释）。暴露归一化变量：`HOOK_EVENT`、`HOOK_SOURCE`（R1 新增
   ——`.source` 是全仓最关键的 Codex 相关信封字段）、`HOOK_TOOL_NAME`、
   `HOOK_FILE_PATH`、`HOOK_SKILL`、`HOOK_SKILL_ARGS`、`HOOK_SESSION_ID`、
   `HOOK_CWD`（R1 新增——askuser slug 派生需要）。
   **空信封守卫**（R2 精确化）：条件 = TTY（`[ -t 0 ]`）**或**空输入（`</dev/null`
   的手动路径不是 TTY）→ 空信封默认分支，绝不 `cat` 阻塞。
   **HOOK_SOURCE 语义（R2/N1）**：平台无等价判别字段时 `HOOK_SOURCE` 必须为**空**，
   禁止合成值——两个 SessionStart 消费者依赖各自的 fail-open/positive 语义（见 3.3'）。
   **共存契约（R2/N9）**：`post-write-sync.sh` 等仍需 common.sh 的
   `record_trace`/`output_response`；lib 头注释钉死 sourcing 顺序，且两 lib 不得
   互相覆写 `HAS_JQ`/`STDIN_JSON` 语义（AC3 断言）。
3. 消费者改造（R1 重排后 6 个）：
   - `startup-health.sh`、`notebook-dormant-sync.sh`（**新入清单**——Codex 每次
     SessionStart 真实触发，现解析 Claude 专属 `.source`）：迁移到 `HOOK_SOURCE`。
     **⚠️ 极性相反（R2/N1）**：startup-health 是 positive 过滤（`= "compact"` 才动作）；
     notebook-dormant-sync 是 **fail-open negative 过滤**（`.source` 缺失 → 照常运行，
     Codex 上今天是靠字段缺失碰巧能跑）——归一化后必须保持各自语义：判别字段缺失时
     `HOOK_SOURCE` 为空 → notebook-dormant-sync 照常执行、startup-health 提醒分支
     不触发。post-compact 提醒分支在 Codex 判别字段存在时照常工作（AC10a），
     不存在时 honest 映射记录；notebook-dormant-sync 的 Codex 侧行为保持由
     AC10b 覆盖；
   - `post-write-sync.sh`：迁移到 `HOOK_FILE_PATH` 等；
   - `askuser-capture.sh`：只迁移扁平字段（`HOOK_CWD`/`HOOK_SESSION_ID`/事件名）；
     questions/answers 提取是刻意的单遍 jq（性能契约 BA-P0-1），**保留本地**
     （R1：不适用"删除裸解析"）；
   - `pre-gate-check.sh`、`pre-accept-check.sh`：接入归一化层 **并新增手动调用
     模式**（R1 P0-2 处置采选项 a）：无信封（TTY/空输入）时 gate 号取 `$1`、
     跳过 `TOOL_NAME` 短路、执行真实检查、BLOCK 时非零退出——消灭"手动跑 →
     `{}` exit 0 假绿"路径；**裸调用（无参 + 无 stdin）→ 输出 usage 行 + 非零退出，
     不得落入空 gate 号分支**（R2 回填）；hooks-platform-mapping.md 的手动指引同步更新。
4. **jq 缺失降级保真**（R1）：现有两种降级**不同**且都保留——common.sh 消费路径
   = naive grep 提取器；askuser-capture = stderr WARN + 跳过不写。fixture 必须
   含 jq-absent 轴（AC3）。
5. **Claude 零回归硬约束**：改为"归一化滤波后可观测行为逐项一致"（AC4，R1 重写；
   原"逐字节等价"不可达已删）。

### 3.3 PreCompact Layer-0 快照 Codex 接线（Spike D 先决，R1 三分结局）

1. **Spike D**：实测 codex 0.146 compaction hook 事件。先探廉价触发路径
   （codex 有无 `/compact` 类手动触发）；只能靠填满上下文触发 → 成本/可行性
   写进 spike 报告。
2. **三分结局（R1 P0：证据类别 ↔ 接线决策 ↔ 台账状态强制联动）**：
   - (a) **实测触发证据**（探针文件在真实 compaction 时写出）→ 接线
     （`.codex/hooks.json` + tad.sh heredoc 锁步，复用止血单 heredoc-cmp 模式）+
     台账 `context_compaction` 记 `verified`（真实测过 fire）；
   - (b) **仅 parse + doc 证据** → **默认不接线**；若接线则台账必须记
     `verified_partial` + `regression_required: yes` + hooks-platform-mapping
     显式标注"wiring untested-fire"——禁止以 doc 证据挂 verified（本系列起点
     就是这个失败类，且现台账该行恰是 docs-only 标 verified 的活例）；
   - (c) **不支持** → honest 映射记录，不接线。
   三分支均为合法 PASS。
3. snapshot 脚本适配：字段缺失沿用**既有 `(unavailable: reason)` 惯例**
   （如 `(unavailable: codex-envelope-no-trigger)`）——不引入 `trigger=unknown`
   第二哨兵（R1）；L9-10/L150 的 8 行模板与行数契约不变；`hook-envelope.sh` 的
   source 必须存在性守卫，每字段 fallback 保持。

### 3.4 detect-platform.sh 信号表（Spike E 先决；优先级 R1 反转）

1. **Spike E**：实测 Claude Code Bash 信号（候选 `CLAUDECODE=1`，reviewer 已在
   自身环境证实）与 codex exec 信号（候选 `CODEX_SANDBOX*`）；**必测嵌套场景**：
   Claude 会话内 spawn `codex exec` 时 env 继承/清洗情况（tournament 路径 +
   用户 7-30 冒烟即此形态）。
2. 决策表（输出契约 `workflow|codex|none` 不变；**stdout 纯净**：任何分支 stdout
   恰为三词之一，提示只走 stderr）：

   | 优先级 | 条件 | 输出 |
   |---|---|---|
   | 1 | `TAD_PLATFORM` env 显式设置 | 其值透传 |
   | 2 | **Codex harness 信号命中**（最内层 harness 胜出——Claude 内 spawn codex 会继承 `CLAUDECODE=1`，反向嵌套不存在） | `codex` |
   | 3 | Claude harness 信号命中 且 `.claude/workflows/*.workflow.js` 存在 | `workflow` |
   | 4 | Claude harness 信号命中 且无 workflows | `none` |
   | 5 | 无任何信号：保守回退现行为（workflows 存在→`workflow`，codex CLI 在 PATH→`codex`，否则 `none`），stderr 提示 `TAD_PLATFORM` | 同现行为 |

3. 消费者语义（R1 弱化为可兑现表述）：`workflow` ⇒ "Claude harness 在场且
   workflows 已安装"（Workflow tool 对 sub-agent 不可调的既有限制不变，
   design-protocol.md:140 消费处加一行 invocability caveat）。
4. `TAD_PLATFORM` escape hatch 写进 AGENTS.md Codex-Specific Notes。
5. **假设留痕（R2/N10）**：detect-platform.sh 内注释记录"Codex-first 仅在不存在
   codex→claude 反向嵌套时有效；cross-model-invocation.md 现仅记载 Claude→codex
   单向"——未来出现反向路径时读者被绊住而非静默经表 2 误路由。

### 3.5 镜像可执行路径平台中立化（清单 R1 扩充；行号以内容锚重定位）

**逐处清单（且仅此清单；行号为当前实测，实现时以内容锚 grep 重定位——止血单的
注记行已使行号 +1，禁止按旧号预登记）**：
1. alex `SKILL.md` ~L1853：AR-registry awk 自提取命令（锚：`anti_rationalization`
   提取命令行）；
2. blake `SKILL.md` ~L2091：honest_partial awk 自提取（锚：`honest_partial_protocol:BEGIN`）；
3. blake `SKILL.md` ~L560/L564：skill 可用性扫描 `.claude/skills/`；
4. blake `SKILL.md` ~L539：knowledge-blame 扫描 scope 内 `.claude/skills/*/SKILL.md`；
5. alex `SKILL.md` L1579-1583：`optional_technical_review` 三个
   `skill_path: ".claude/skills/…"`；L1595：`[调用 Read tool 读取
   .claude/skills/code-review/SKILL.md]` 显式读指令（R1：与 36 处 reference
   同病类）；
6. `# Source: .claude/skills/{alex,blake}/SKILL.md` 头：**实测规模 = 19 个文件 /
   两树共 38 行**（alex references 17 + blake references 2，×2 树——R2/N4 纠正
   v1 的"4+ 处"低估）；两树同步改（R1 P0：头在两树字节相同，单侧改必撞 parity
   FIX-REFUSED；修改落 `.claude` 侧 → `parity --fix` 镜像）→ 平台中立写法
   `# Source: skills/{role}/SKILL.md (platform tree)`。
7. blake ~L1841 skillify 创建路径 `.claude/skills/{slug}/SKILL.md`（R2/N8：从 §2
   合法分类移入——skill 是双树工件，与 workflow.js 不同）：改为"创建于权威源树
   （`.claude/skills/` 存在则用之，否则 `.agents/skills/`），双树共存时创建后
   `parity --fix` 镜像"。L1843（workflow.js）维持合法分类不改。

修法**按条目类别**（R2/N6——禁止 Blake 现场发明机制）：
- 条目 1-3（shell 命令）：可运行双路径形式
  `for f in .claude/skills/<role>/SKILL.md .agents/skills/<role>/SKILL.md; do [ -f "$f" ] && { …; break; }; done`；
- 条目 4-5 的 YAML 标量（`skill_path:` ×3、L539 scope 值）：值改为树中立形式
  `skills/<name>/SKILL.md` + 紧邻 `#` 注释行"resolve under .claude/skills/ or
  .agents/skills/ per platform"；
- 条目 5 的 prose 读指令（L1595）：改写为"读取 code-review skill
  （`.claude/skills/` 或 `.agents/skills/` 下）"；
- 条目 6（注释头）与条目 7（创建路径）：如上逐条指定。
两树保持字节一致。
**Honest note（R1）**：条目 1/2 所引用的 extract-diff 契约本已两平台皆死
（`.tad/evidence/designs/extracts/` 不存在）——本单只修路径半边，fixture 修复
另记 follow-up；AC7 的运行验证上限 = "非空 + 含已知锚行"（无 md5 参照物）。

### 3.6 brain-index-gen.sh 平台兜底

`SKILLS_DIR`：`.claude/skills` 存在则用之，否则 `.agents/skills`；两者皆无 →
输出显式 `## Skills` 节 + `(no skills tree found)` 标记（现行为是整节省略——R1
纠正描述）。注意脚本 `TAD_ROOT` 由脚本自身位置推导且直接覆写 git-tracked 的
`.tad/brain-index.md`（AC8 必须在 scratch 副本运行并断言仓内文件未被改动）。

## 4. 文件清单

修改：`AGENTS.md`、`.tad/hooks/startup-health.sh`、`.tad/hooks/notebook-dormant-sync.sh`、
`.tad/hooks/post-write-sync.sh`、`.tad/hooks/pre-gate-check.sh`、
`.tad/hooks/pre-accept-check.sh`、`.tad/hooks/lib/askuser-capture.sh`、
`.tad/hooks/precompact-session-snapshot.sh`（仅 Spike D (a)/(b)-接线分支）、
`.codex/hooks.json` + `tad.sh`（锁步，仅接线分支）、
`.tad/hooks/lib/detect-platform.sh`、`.tad/hooks/lib/brain-index-gen.sh`、
`.claude/skills/alex/SKILL.md`、`.claude/skills/blake/SKILL.md`、
`.claude/skills/alex/references/*.md`、`.claude/skills/blake/references/*.md`
（Source 头）+ `.agents` 全部对应镜像（经 `parity --fix`）、
`.tad/guides/hooks-platform-mapping.md`（信封字段映射 + 手动模式指引更新）、
`.tad/runtime-compat/codex.md`（context_compaction 行按 Spike D 分支联动）、
`.tad/codex/README.md`（hooks 状态行 + 过期 freshness 行，R1）、
`alex/references/design-protocol.md`（L140 invocability caveat 一行）
新增：`.tad/hooks/lib/hook-envelope.sh`、
`.tad/evidence/acceptance-tests/codex-knowledge-ingress/`（AC 脚本 + Spike C/D/E
报告 + 信封 fixtures + AC4 基线与滤波器定义）

## 5. AC（证据落 `.tad/evidence/acceptance-tests/codex-knowledge-ingress/`）

- **AC1（知识入口结构）**：AGENTS.md 两节存在；**must-exist 子集**（principles.md、
  patterns/_index.md、brain-index.md、frontend-design.md、
  patterns/shell-portability.md）逐一存在断言；不存在文件只允许出现在条件句内
  （断言：非条件句行不含 5 个缺失文件名）；**反复制检查（R1 重设计 + R2/N5 CJK 适配）**：
  分词器显式定义——CJK 连续段：剥离空白/标点后 **≥24 个连续 CJK 字符**片段；
  ASCII 段：≥12 个空白分隔 token 片段；两类片段均不得出现在
  `.tad/project-knowledge/**/*.md`（递归，路径/URL 行除外）+ 两节合计 ≤80 行
  （原纯词数 shingle 在中文正文上空转——CJK 空白分词粒度陷阱，
  shell-portability 已有先例）；Critical Rules 四小节逐条独立 grep（含 Layer-1 自检句、
  /tad-maintain 豁免、方向互斥）。
- **AC2（Spike C 信封）**：spike 报告含分事件原文（stdin+env+argv 三通道）或
  "无 stdin"实测 + 实际形态；SessionStart 是否含 compact 判别字段有显式结论；
  字段映射表写入 hooks-platform-mapping.md。
- **AC3（归一化层 fixture）**：fixture 轴 = Claude shape ×4 事件 + Codex 实测
  shape + 空输入 + **jq-absent**（`env PATH=/usr/bin:/bin` 且 jq 屏蔽——断言
  common 路径 naive-grep 降级与 askuser WARN-跳过两种行为分别保真）；
  `hook-envelope.sh` 含 `[ -t 0 ]` 守卫（存在断言 + TTY 模拟不阻塞）；
  `bash -n` 全部改动 shell 文件。
- **AC4（Claude 零回归，SAFETY——R1 全重写）**：对拍协议：①每轮在**同 basename**
  的全新隔离 cwd + 冻结 `.tad/` fixture 树（含预置 COMPLETION/evidence 状态，
  隔离 live git/find 依赖）；②基线与改后在同一 `date +%F` 内完成；③**预登记
  归一化滤波器**（**仅** `ts`、`Hook Last Touched`、快照文件名——R2/N3：trace 幂等门
  产物**不入滤波器**：隔离 cwd 下 dedup 是确定性的、是被测行为不是噪声），
  对称应用于两侧后逐项一致（文件集合、滤波后内容、退出码）；③b **幂等子例**
  （R2/N3）：同一 fixture 同一隔离 cwd 连跑两次，基线侧与改后侧均断言第二次
  新增 trace 行数 = 0（`trace_already_emitted` 保真）；④fixture 矩阵每脚本
  ≥1 exit-0 路径 **且 pre-gate/pre-accept 各 ≥1 exit-2（BLOCK）路径**——
  "曾 BLOCK 现 0"是本单最高危回归类，必须有能触发它的 fixture。
- **AC4b（手动模式，R1 P0-2）**：冻结 fixture 树中无 COMPLETION 时
  `bash pre-gate-check.sh 3 </dev/null` → 非零退出 + 人类可读 BLOCK 说明
  （基线对照：修复前同命令 `{}` exit 0 假绿存证）；有合法 COMPLETION 时 → exit 0；
  裸调用 `bash pre-gate-check.sh </dev/null`（无参）与**非法参**
  （如 `pre-gate-check.sh 9`）→ usage/错误行 + 非零退出（R2 子例，两 fixture）。
- **AC5（Spike D 三分联动，R1 P0 重写）**：spike 报告落盘且**分支判定与证据类别
  逐项对应**：(a) 分支须含实测触发探针产物；(b) 分支若接线，断言台账该行 =
  `verified_partial` + `regression_required: yes` + mapping 文档含 untested-fire
  标注（**断言"doc 证据 + verified 状态"组合不存在**）；(c) 分支断言 honest 映射
  记录存在。**三分支的台账终态均须显式指定（R2/N7——否则 (b)-不接线/(c) 路径
  会保留现行 docs-only-verified 活例，正是本单点名的失败状态）**：
  (a) → `verified`（source=实测触发探针）；(b)-不接线 → `verified_partial`
  （source=Spike D parse+doc，current_behavior 注明 fire 未测）；(c) →
  `verified`（"0.146 无该事件"是对 surface 行为的真实测量，source=Spike D 探测）；
  任一分支都不得让该行停留在"docs-only source + verified"旧组合。接线分支追加：heredoc `cmp` 一致 + snapshot 在 Codex shape fixture
  下产出 8 行合法快照（`(unavailable: …)` 惯例，无 `trigger=unknown`）。
- **AC6（detect-platform，R1 补 oracle）**：实现读取的信号名集合与 Spike E 报告
  测得集合**set-equal**（断言脚本比对，杜绝自指）；表 1-5 每行 fixture 断言 +
  **每平台 ≥1 次非注入 in-situ 观测**（Claude 侧本会话实测、Codex 侧 spike 会话
  实测）；基线对照：修复前 Codex 信号 + 双平台仓 → `workflow` 误判复现、修复后 →
  `codex`；嵌套 fixture（两类信号并存）→ `codex`；全部 5 行 stdout 恰为
  `workflow|codex|none` 之一（无尾随内容）。
- **AC7（SKILL 修改约束，SAFETY）**：line-set diff：变化行 ⊆ §3.5 清单（实现时
  以内容锚重定位后预登记，含 references Source 头两树）；**前向完备性断言**
  （R2/N4——⊆ 单向约束抓不到修一半）：
  `grep -rc '^# Source: \.claude' .claude/skills .agents/skills` → **0**
  （基线 = 38 行/19 文件）；§3.5 条目 1-5、7 每条一个"新形式已在位"存在断言
  （逐条独立 grep 树中立形式锚文本）；**判别力完全由 line-set
  diff 承担**——哨兵脚本（lite 四文件 md5 ×4）仅作全局回归护栏，对本单改动文件
  无判别力（R1 显式声明，防"两道独立防线"错觉）；codex-only scratch 结构下按
  `.agents` 路径分支实际运行条目 1/2 的双路径提取命令 → 产出非空且含已知锚行。
- **AC8（brain-index 兜底，R1 重写）**：将脚本**复制到 scratch 树**运行（或 root
  override）：codex-only 结构 → `## Skills` 节非空来自 `.agents/skills`；双树皆无 →
  显式 `(no skills tree found)`；**断言仓内 git-tracked `.tad/brain-index.md`
  运行前后无改动**（`git diff --stat` 空）。
- **AC9（回归，基线以当前实测为准——R1 纠正）**：`release-verify.sh parity .`
  PASS（含止血单守卫）；`skill-body-verify.sh` PASS；runtime-freshness 当前基线 =
  **21 PASS/0 BLOCK exit 0**——改后断言：BLOCK 集合 ⊆ 本单预登记上报清单（默认空）
  且 0 个 BLOCK 来自 verified 行；`ask_user_question_hook` 行状态仍为
  `accepted_limitation`（未被翻绿）。注：`accepted_limitation` 不触发 BLOCK
  （verifier 只 BLOCK safety 面的 `unknown_current_behavior`），Spike D (b)/(c)
  分支的台账更新无需任何日期操作即可保持 exit 0——此路径合法，写明以消除
  改日期的诱因。
- **AC10a（post-compact 提醒半边，R1 P0-1）**：Codex SessionStart 信封含判别字段 →
  `startup-health.sh` 在 Codex shape fixture（source=compact 等价形态）下输出
  恢复提醒行（断言提醒文本）；无判别字段 → hooks-platform-mapping 记录
  "Codex 无 compact 判别，Layer-1 自检（AGENTS.md Critical Rules）为唯一检测层"
  （断言记录存在）。两分支均 PASS。
- **AC10b（Codex 侧行为保持，R2/N1）**：`notebook-dormant-sync.sh` 在
  Codex-measured SessionStart 信封 fixture 下（含"无判别字段"例）仍执行主体
  （fail-open 语义保真——断言其动作产物出现）；`HOOK_SOURCE` 在无等价字段时为空
  的断言（fixture 级）。

## 6. 风险与注意

- **三个 spike 均可能"不支持/无投递"**——honest 映射即 PASS；Spike D 尤其禁止
  doc 证据冒充实测（三分联动 AC5 机械把关）。
- **AC4 是最高风险约束**：滤波器本身预登记、两侧对称应用；若实现中发现新的
  非确定源 → 更新滤波器定义并在证据中记录 diff，不得静默放宽为"大致一致"。
- **手动模式（3.2.3）改变 pre-gate/pre-accept 的调用契约**：hook 信封路径行为
  不变（AC4 对拍覆盖），新增的是无信封分支；mapping 文档同步更新。
- **AGENTS.md 知识节是 prompt-level**：结构 AC 保证"指令在场"；遵从率验证递延
  Codex 真实使用（carry-to-first-real-use）。
- **升级清单命中**（SKILL/hooks/settings/tad.sh）：full 通道，Gate 3 照常。
- **发布语义**：与止血单同批推送（下游一次重装拿全）；决定权在人。

## 7. 知识引用

- `patterns/ac-verification.md` "Exit-0 ACs Are Unsatisfiable…" → AC5/AC9 分支
  联动设计；"Section-Scoped Checks…" → AC1/AC7 逐条断言；dry-run 纪律 → AC4
  滤波器预登记
- `patterns/release-sync.md` "Identity Early-Exits…" → AC9 含新守卫回归；
  §3.5 两树同步改 + parity --fix 单向权威
- `patterns/hook-contracts.md` — stdin 契约、`.source` 分支、hook 事件模式
- `patterns/shell-portability.md` — 本单 8+ shell 文件改动的硬约束（Codex 侧
  Blake 无 rules 注入，实现前必读——正是 §3.1 新路由条目的第一次自食）
- `principles.md` "Never Hand-Write…" → 归一化层集中于 lib；hook-envelope 自含
  取舍已显式记录 rationale
- `principles.md` "Judgment-Only Skill Files…" → §3.5 仅限枚举行
- `.tad/runtime-compat/codex.md`（0.146 重验版）— hooks verified /
  context_compaction docs-only / askuser accepted_limitation 地基
- lite 共享记忆契约 — Critical Rules memory 层语义逐字对齐

## 8. Audit Trail（Gate 2 专家审查）

**R1 双专家（独立上下文并行，2026-08-03）：**
- 专家 A（code-reviewer lens，自报 claude-opus-5[1m]）：verdict **CONDITIONAL**，
  P0×5：①消费者清单与 Codex 现实相反（startup-health/notebook-dormant-sync 真触发
  且解析 .source 却缺席；pre-gate/pre-accept 未接线；HOOK_SOURCE 缺失；Layer-0
  半边 (b) 整体漏掉）→ §1.2 重写 + §3.2.3 重排 + AC10；②手动 pre-gate 路径静默
  假绿（TOOL_NAME 短路 + $1 无效，实测 `{}` exit 0）→ 手动调用模式 + AC4b；
  ③AC4 不可执行（trace 幂等门、ts/cwd 泄漏、live git 状态三类非确定源实证 +
  无 exit-2 fixture）→ AC4 全重写（同 basename 隔离 cwd/冻结 fixture 树/预登记
  滤波器/同日/exit-2 矩阵，删"逐字节等价"）；④§4 漏 .claude 侧 references（Source
  头两树字节相同，单侧改必撞 parity）→ 两树同步 + parity --fix；⑤AC1 断言 5 个
  不存在文件存在（8 个 @import 仅 3 个在盘）→ must-exist 子集 + 条件句约束。
  P1×11 全部采纳：行号 +1（内容锚重定位）、§3.5 扩充（skill_path×3 + L1595 读指令 +
  L539；L1841/1843 分类为合法）、哨兵条款判别力显式归零、≥12 词 shingle 反复制
  检查（递归 patterns/**）+80 行帽、asymmetry rationale 重写（机械 vs prompt +
  实测清单 + 维护注记）、.claude/rules 缺口 → shell-portability 路由条目、
  `(unavailable:)` 惯例不引入第二哨兵、HOOK_CWD + askuser 单遍 jq 保留、jq-absent
  fixture 轴（两种降级分别保真）、AC8 scratch 副本 + 仓内文件不动断言、AC6
  spike-set-equal oracle + stdout 纯净 + 消费语义弱化。P2×4 采纳：extract 契约
  已死 honest note + follow-up、AC9 基线纠正（21/0/0）+ accepted_limitation
  不 BLOCK 说明、precompact 自含性（envelope 自含 + 存在性守卫）、common.sh
  取舍显式记录。
- 专家 B（平台/harness lens，自报 claude-fable-5）：verdict **CONDITIONAL**，
  P0×1：Spike D "支持"分支允许 doc 证据接线且 AC5 无实测触发要求（= 本系列起点的
  verified-while-broken 失败类，台账该行现为活例）→ 三分结局 + 证据类别↔台账状态
  机械联动（AC5 重写）。P1×6 全部采纳：TTY 守卫、探针三通道分事件 +
  workspace-write、**信号优先级反转（最内层 harness 胜出，Codex 先于 Claude——
  嵌套实证：codex exec 继承 CLAUDECODE=1）** + 嵌套 spike 项、Source 头两树（同
  A-④）、清单扩充（同 A）、Layer-1 自检入 Critical Rules（Codex 唯一检测层）。
  P2×4 采纳：/tad-maintain 豁免 + 方向互斥收紧、.tad/codex/README.md 入清单、
  双路径可运行形式、（背书项：ingress 不对称设计 + 位置 + 8 文件实存 3 的实测）。
  另：AGENTS.md 尺寸实测 6.8KB→约 9KB 可接受；CLAUDECODE=1 in-situ 证实；
  detect-platform 唯一消费者 design-protocol.md:140 证实。
- **v2 状态**：6 P0 + 17 P1 + 8 P2 全部处置如上。专家 A 要求对修订后的
  §3.2/§3.3/AC4 做增量复核（非纸面放行）。

**R2 增量复核（同两位专家，2026-08-03）：**
- 专家 B：R1 全部 findings 确认忠实处置（多处"超出处方"：判别字段探测、AC5
  不存在断言、AC10 双分支）；对专家 A 折入项交叉核验无冲突；AC1 must-exist
  子集逐一在盘证实。新缺陷仅 1 个 P2（pre-gate 裸调用未定义）。
  **verdict: PASS (incremental)**。
- 专家 A：R1 全部 5 P0 + 11 P1 + 4 P2 确认实质处置（含对专家 B 信号反转的
  独立背书：cross-model-invocation.md 仅记载 Claude→codex 单向，反向嵌套今日
  不存在）。新发现 N1-N5（P1 级，clears 后预授权 PASS）+ N6-N10（P2）：
  N1 notebook-dormant-sync 的 `.source` 过滤与 startup-health **极性相反**
  （fail-open，Codex 上靠字段缺失碰巧能跑）——归一化可能在目标平台制造回归且无
  覆盖 AC；N2 无参/非法参裸调用仍假绿；N3 滤波器收编 trace 幂等门产物 =
  销毁隔离 cwd 恢复的判别力（dedup 是被测行为）；N4 AC7 仅 ⊆ 单向、抓不到
  38 行 Source 头只修 2 行的"修一半"；N5 ≥12 词 shingle 在 CJK 正文空转。
  **verdict: CONDITIONAL，N1-N5 处置即预授权 PASS，无需第三轮**。
- **v3 处置（终版）**：N1 → §3.2.2 HOOK_SOURCE 空值语义 + §3.2.3 极性警示 +
  AC10a/AC10b 拆分（notebook fail-open 保真 fixture）；N2 → 裸调用/非法参
  usage + 非零退出（§3.2.3 + AC4b 两 fixture，与专家 B P2-NEW 同源合并）；
  N3 → 滤波器仅 ts/Hook Last Touched/快照文件名 + AC4③b 幂等子例（连跑两次
  第二次 0 新增 trace 行）；N4 → AC7 前向完备性断言（`^# Source: \.claude`
  基线 38 → 0 + 条目逐条"新形式在位"断言）+ §3.5.6 规模纠正（19 文件/38 行）；
  N5 → CJK 分词器显式定义（≥24 连续 CJK 字符 / ≥12 ASCII token）；
  N6 → §3.5 修法按条目类别逐一指定（shell 双路径 / YAML 树中立值 + 注释 /
  prose 改写 / 注释头 / 创建路径）；N7 → AC5 三分支台账终态逐一指定（禁止
  停留 docs-only-verified 旧组合）；N8 → L1841 移入 §3.5 条目 7（skill 是
  双树工件），L1843 维持豁免；N9 → 空-或-TTY 守卫措辞 + 双 lib 共存契约
  （sourcing 顺序 + HAS_JQ/STDIN_JSON 不互相覆写，AC3 断言）；N10 →
  detect-platform 反向嵌套假设留痕注释。
- **Gate 2 终态：PASS**（专家 B 增量 PASS + 专家 A 预授权条件 N1-N5 已逐字
  兑现，双方均声明无需再轮）。
