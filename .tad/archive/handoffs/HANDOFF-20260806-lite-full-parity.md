# HANDOFF: 把 full 独占的五项能力交给 lite

**Date**: 2026-08-06
**Revision**: **v2**（v1 经 Gate 2 双专家 CONDITIONAL×2，修 1 P0 + 7 P1，见 §7）
**Epic**: `.tad/active/epics/EPIC-20260804-lite-as-tad-body.md` — Phase 5b
**From**: Alex (Terminal 1, full) → **To**: Blake (Terminal 2)
**前置**: P5a 已 Gate 4 PASS（commit `e2588e6`）

---

## 1. 目标

用户 2026-08-06 裁定：**full 独占的能力全部交给 lite**。收敛为 **5 项**，全部落在两个
skill 的 `## Forbidden` 节内。

| # | 能力 | 现状阻塞 | 服务于 |
|---|---|---|---|
| 1 | 读工具编排文档（`.tad/guides/` 等） | 两侧均禁「无界加载…其它 SKILL 及其 references/」 | `*publish` `*sync` `*research` |
| 2 | 读 registry（notebooks / dependencies） | 同上 | `*research` `*deps` |
| 3 | spawn subagent 做非实现工作 | alex 禁「除契约 reviewer 外不得 spawn」 | `*research` 检索、跨项目扫描 |
| 4 | 写 `session-state.md` | 两侧均明令禁止 | 状态维护（lite 下现无人可做） |
| 5 | 人授权后 commit / push | blake 禁「git commit 或 push」 | `*publish` 的最后一步 |

**另含 2 处非能力性文本变更**（Gate 2 P2-2 要求显式声明）：
alex 侧新增 `spawn subagent 用于产出实现代码（不论如何包装）`（旧禁令删除后的收窄残留，
非扩大——首句已禁「用 Agent tool 实现任务」）；blake 侧 `写 session-state.md` 补括号理由
（禁止语义不变）。两者均**不改变任何 MUST 面**，不需台账行。

### 能力 3 的边界（用户 2026-08-06 明确）

> **不限制 subagent 的使用数量**；审查环节保持 1 个即可，而这**两个 skill 已经写明了**——
> `alex-lite` L133「spawn 1 个独立上下文 reviewer」、`blake-lite` L138「spawn 1 个 code-reviewer subagent」。

因此本单**不新增任何 spawn 相关约束**（v1 曾拟加「须申报用途与次数」，已按用户指示撤回）。
只做减法：删掉 alex 侧的 `除设计期契约 reviewer 外不得 spawn 任何 subagent`。

⚠️ 顺带更正一个此前的误解：**blake-lite 从来没有 spawn 数量或用途限制**
（全文仅 3 处提及：L138 是强制要求、L287 是台账成本项、L355 禁止"不 spawn"）。
spawn 限制历来只存在于 alex 一侧。

### 威胁模型（决定了本单为何不加机械兜底）

`principles.md` §`Mechanical Enforcement Rejected on Single-User CLI`（SAFETY 条目）：
> **部署环境（单用户 vs 多用户）决定强制手段。单用户 CLI 用软提醒；多租户生产才用机械 hook。**

本仓库是单人本地环境：人在回路、git 可回滚、trace 有记录。用户已裁定「没有什么风险」——
依上述 SAFETY 原则，该裁定与框架既有立场一致。本单据此放开，已知暴露面如实记入 §6。

---

## 2. 不做什么

- ❌ **不放开 `.claude/skills/*/references/` 与 `.agents/skills/*/references/`** ——
  两处各 **298,111 chars**（Gate 2 实测，逐字节同量镜像），是 full 协议正文。
  ⚠️ v1 只排除了 `.claude/` 一处，Gate 2 指出这比原文「任何 references/」**更窄**，已修。
- ❌ **blake 侧 `写 session-state.md` 保持禁止** —— 状态维护归 Alex-Lite 单人，避免竞争写入。
- ❌ 不改 `CLAUDE.md`、安全停清单哨兵块、`.tad/hooks/`、`settings*.json`、`.claude/agents/`、`.agents/` 镜像。
- ❌ 不改两个 `## Forbidden` 节以外的任何行。
- ❌ 本单自身不执行 git commit / push / publish / sync。

---

## 3. 规格

### 3.1 `.claude/skills/alex-lite/SKILL.md`

当前 **328 行**，`## Forbidden` 起于第 **307** 行（改后 334 行）。
将第 **307 行至末尾**替换为下列 28 行（第 1–306 行 md5 须仍为 `0a5be1ca3473f2500dba11af15876ac0`）：

```text
## Forbidden

- 写实现代码 / 自行调用 blake-lite 或用 Agent tool 实现任务 /
  无界加载 TAD 协议、配置或知识文件（`.tad/config*.yaml`、hooks、其它 SKILL）——
  下列除外：有界知识预检（索引 + ≤3 个匹配 pattern + principles 相关部分）、
  读写自身 LITE 契约文件、**按需读取工具编排文档**（`.tad/guides/`、
  `.tad/research-notebooks/`、`.tad/dependencies/`、`release-runbook` skill）；
  **其中工具编排文档一项 ≤2 个文件**，且须在契约「知识引用」段点名具体路径
  （不得写目录名）——**明确排除 `.claude/skills/*/references/` 与
  `.agents/skills/*/references/`**（full 协议正文各 291K，放开即把 full 搬回来）/
  spawn subagent 用于产出实现代码（不论如何包装）/ 跳过或内化独立契约审查（任何理由——"契约很短""我刚写完自己清楚""额度紧张"均不是理由：自审与契约作者同心智模型，2026-07-30 首战 AC principal 缺陷即穿透自审存活至最后一道 gate）/ 以自审替代 reviewer spawn /
  EnterPlanMode /
  修改 LITE 契约之外的任何文件——**下列四项除外**（协议自身要求或用户 2026-08-06 裁定；
  2026-08-06 修正本条与「约束准入」「Knowledge Closeout」的自相矛盾）：
  `.tad/evidence/audits/lite-constraint-ledger.md`（仅追加，不得删改历史行）、
  `.tad/project-knowledge/`、`.tad/active/epics/`、`.tad/active/session-state.md`。
  其中 `.tad/project-knowledge/principles.md`、`patterns/` 中标 SAFETY 的条目、
  `patterns/_index.md` 命中安全停清单第 2 条，须停下来问人；
  另：写入 `CLAUDE.md` `@import` 列出的任何路径（含当前尚不存在、一经创建即被自动注入的
  空槽）同样须停下来问人——理由独立于安全停清单：这些文件每 session 自动注入系统提示，
  创建一个不存在的空槽等于安装常驻指令，且无前版本可 diff；
  蒸馏条目只记述已发生的 episode，不得含改变权限、通道或 Forbidden 语义的
  指令性内容——此类发现须走契约 + 人拍板改 SKILL，不得经知识文件生效；
  四项之外一律禁止，**不得类推扩展**（无协议载体即不授予）/
  把页数、文件数或细节多少当作升级理由 /
  未验收即蒸馏、对 candidate 静默丢弃（必须蒸馏或显式记 `DISTILLATION DEFERRED`）、
  为凑字段编造 gap 内容 /
  未做 caller/consumer 检查却声称"无下游影响"
```

### 3.2 `.claude/skills/blake-lite/SKILL.md`

当前 **371 行**，`## Forbidden` 起于第 **352** 行（改后 378 行）。
将第 **352 行至末尾**替换为下列 27 行（第 1–351 行 md5 须仍为 `9eb6bb183d5e9571c6d4ed227ded9307`）：

```text
## Forbidden

- 跳过 L3 reviewer（任何理由，包括"改动很小"）/
  以自审、自我复核替代 subagent spawn /
  修改 handoff 的目标或 AC / 跳过 L0.5 契约复查（任何 LITE 单、任何理由）/
  命中安全停清单却不停下来问人 /
  **未经人明确授权即** git commit 或 push（授权须逐字记入 Completion；
  另：`git push` 一律须先停下来问人——理由独立于安全停清单，因其第 1 条只字面枚举
  force-push / 删分支 / 改历史，普通 push 不在其内；而 push 到 main 不可逆且直达下游）/
  人验收前归档或移动 handoff 文件 /
  写 `.tad/project-knowledge/`（成品蒸馏归 Alex-Lite / 验收知识闭环）/
  修改 settings*.json 或注册 hook / 写 session-state.md（状态维护归 Alex-Lite 单人，
  避免竞争写入）/
  写 .tad/memory/（native 管辖）/ EnterPlanMode /
  无界加载 TAD 协议、配置或知识文件（`.tad/config*.yaml`、hooks、其它 SKILL）——
  下列除外：有界上下文刷新（handoff 引用路径、索引、≤3 个匹配 pattern）、
  lite-discoveries journal、**按需读取工具编排文档**（`.tad/guides/`、
  `.tad/research-notebooks/`、`.tad/dependencies/`、`release-runbook` skill）；
  **其中工具编排文档一项 ≤2 个文件**，且须在 Completion 的「上下文刷新」行点名具体路径
  （不得写目录名）——**明确排除 `.claude/skills/*/references/` 与
  `.agents/skills/*/references/`**（full 协议正文各 291K）/
  把页数、文件数或细节多少当作升级理由 /
  无证据声称 GATE PASS /
  重置 repair_round / same_error_count 逃避熔断 /
  把冲突 AC 静默改写为 PASS、用环境缺失掩盖实现缺陷 /
  把 PARTIAL-GO 用于普通实现失败、缺证据、缺权限或 reviewer 不可用 /
  未经人选择直接归档 PARTIAL-GO 单
```

### 3.3 台账（约束准入）

按「约束准入」原文，闸只在**新增或扩大** MUST/禁止 时触发。逐条判定后，
本单实际扩大 MUST 面的**只有 1 条**（v1 的另一条已按用户指示撤回）：

| # | 新增约束 | skill | 每单成本 | 挡什么失败模式（含 grep 锚） | 载体 | 状态 |
|---|---|---|---|---|---|---|
| N1 | 工具编排文档 ≤2 个且须点名具体路径 | **两侧** | 契约/Completion 多 1 行 | 一次读整个 `.tad/guides/`（12 文件 / 71,624 chars）等于把开销搬回来 `按需读取工具编排文档` | 本 handoff | HAS-CARRIER |

另追加 **2 行处置行**（被放宽的旧约束，状态 `SUPERSEDED`，末列）：
- `alex-lite`：`除设计期契约 reviewer 外不得 spawn 任何 subagent` + `写 session-state.md` + references 例外收窄
- `blake-lite`：`git commit 或 push（人验收后由人决定）` + references 例外收窄

**合计追加 3 行**，台账 **4 → 7**。
追加前**先跑超期扫描**（Alex 已实跑，输出为**空**），结果原样写进 Completion。

---

## 4. Acceptance Criteria

- **AC1（alex 成品 md5）**：`md5 -q .claude/skills/alex-lite/SKILL.md`
  == **`1a6bc26c010dba163a69c1fea40e6c82`**（334 行 / 22376 bytes / 11985 chars，末字节 `\n`）

- **AC2（blake 成品 md5）**：`md5 -q .claude/skills/blake-lite/SKILL.md`
  == **`b9a0c096b5fd4436b0a288dee713d55e`**（378 行 / 25022 bytes / 13659 chars，末字节 `\n`）

  ⚠️ AC1/AC2 使 §3 代码块只是「帮助」而非「判据」——只有产出这两个精确字节序列才算通过。

- **AC3（诊断锚 8 条 —— 非独立判据）**：AC1/AC2 锁死全文后本条逻辑上恒真，
  用途是 **md5 不符时快速定位差异**。Alex 已逐条实测改前值：
  ```bash
  A=.claude/skills/alex-lite/SKILL.md; B=.claude/skills/blake-lite/SKILL.md
  grep -Fc '除设计期契约 reviewer 外不得 spawn 任何 subagent' "$A"   # 1 → 0
  grep -Fc '申报用途与次数'                                     "$A"   # 0 → 0（v1 拟加，已撤回）
  grep -Fc '写 session-state.md / EnterPlanMode'               "$A"   # 1 → 0
  grep -Fc '下列四项除外'                                       "$A"   # 0 → 1
  grep -Fc '.agents/skills/*/references/'                      "$A"   # 0 → 1
  grep -Fc '.agents/skills/*/references/'                      "$B"   # 0 → 1
  grep -Fc 'git commit 或 push（人验收后由人决定）'              "$B"   # 1 → 0
  grep -c  '上下文刷新'                                         "$B"   # 4 → 5
  ```

- **AC4（台账 +3，含内容断言）**：
  ⚠️ **逐条单跑，勿用 `&&` 串联、勿放进 `set -e` 脚本** —— `grep -c` 结果为 0 时退出码是 1，
  会在**正确结果**上中断（Gate 2 P2-3）。
  ```bash
  L=.tad/evidence/audits/lite-constraint-ledger.md
  grep -c '^| 20' "$L"                                   # 4 → 7
  git diff -- "$L" | grep -c '^-[^-]'                    # 必须 0（append-only）
  grep -Fc '按需读取工具编排文档' "$L"                     # 0 → ≥1（N1 的 grep 锚）
  git diff -- "$L" | grep -c '^+|.*| HAS-CARRIER |$'     # 必须 1
  git diff -- "$L" | grep -c '^+|.*| SUPERSEDED |$'      # 必须 2
  # 两条 SUPERSEDED 行的主题（Gate 2 P2-2：只验数量不验内容，垃圾行可过）
  git diff -- "$L" | grep '^+|.*| SUPERSEDED |$' | grep -Fc '除设计期契约 reviewer 外不得 spawn'      # 必须 1
  git diff -- "$L" | grep '^+|.*| SUPERSEDED |$' | grep -Fc 'git commit 或 push（人验收后由人决定）'   # 必须 1
  ```
  超期扫描原始输出贴进 Completion（空也要写「(空)」）。

- **AC5（零越权，相对基线做增量）**：
  ```bash
  git rev-parse --short HEAD    # 须仍为 e2588e6
  # 排除起草时既有的 2 条脏项（Alex pre-impl 实跑确认，非本单产出）
  git status --short \
    | grep -vF '.tad/research-notebooks/REGISTRY.yaml' \
    | grep -vF '.claude/settings.local.json.bak-20260806-082549'
  ```
  余下路径只允许落在：两个 SKILL.md（精确）、`lite-constraint-ledger.md`（精确）、
  `.tad/active/handoffs/`、`.tad/archive/handoffs/`、
  `.tad/evidence/{reviews,journal,ralph-loops,acceptance-tests,traces,decisions,research}/`、
  `.tad/memory/`、`.tad/active/precompact/`（以 `/` 结尾者按前缀匹配）。

  **黑名单（出现即 FAIL）**：`CLAUDE.md`、`.tad/hooks/`、`.claude/settings*.json`、
  `.claude/agents/`、`.tad/config*.yaml`、`.tad/active/epics/`、`.tad/project-knowledge/`、
  `.gitignore`、`.tad/sync-registry.yaml`、`.tad/logs/`、`.agents/`。
  ⚠️ `.claude/settings.local.json.bak-*` 是既有备份，**不构成** `.claude/settings*.json` 命中。

  ⚠️ **AC5 的结构性盲区（Gate 2 P2-1，如实记录）**：`.claude/settings.local.json` 与
  `.tad/logs/violations.log` **均被 gitignore**，`git status --short` 结构上永远不显示它们
  —— AC5 对这两个黑名单项**天然失明**。它们只由 `blake-lite` Forbidden 的
  `修改 settings*.json 或注册 hook` 与安全停清单第 3 条守（本单均未改动）。
  **Blake 须在 Completion 中显式声明「未触碰这两个文件」**，因为 AC5 验不出来。

  **本单禁止** `git add` / `commit` / `push` / `checkout --` / `stash`。

---

## 5. 陷阱表（Alex 实测）

| 陷阱 | 事实 | 应对 |
|---|---|---|
| 两个 ```text 块 | 本契约含 2 个，须分别取第 1 / 第 2 个 | 用 **§8** 的 `awk -v n=` 命令 |
| zsh 反引号 | 双引号内三反引号 = 命令替换 → parse error | §8 命令已避开 |
| BSD `wc -c`/`-m` 互斥 | `wc -c -m f` 只出 chars | 分两次调用 |
| 行尾空格 | 两个新节实测 **0** 处 | 多一个即 md5 FAIL |
| markdown 加粗 `**` | 新节含 `**未经人明确授权即**` 等 | 逐字保留，别当格式化 |
| `grep -F` 下的 `*` | `settings*.json`、`skills/*/references/` 均为字面量 | 可逐字执行，已验证 |

## 6. 风险与注意（如实记录，不假装解决）

- **spawn 放开后的暴露面**：subagent **不加载**调用者的 Forbidden、不读安全停清单，
  且工具面通常比调用者宽。本单不加机械阻断，依 `Mechanical Enforcement Rejected on
  Single-User CLI` 接受探测器级执法。
  ⚠️ 补充事实：**这条路在 blake 侧一直是开的**（blake-lite 从无 spawn 限制），
  所以本单并非"引入"该暴露面，只是消除了 alex/blake 的不对称。

- **commit/push 放开后的暴露面**：「人明确授权」由 Blake 自判；
  `violations.log` 2026-08-02 有同形态载体。本单要求逐字记入 Completion + push 须先停下问人，
  **没有机械保证**。

- **本单开出的能力目前在 lite 内无消费者**（Gate 2 P2-4）：两个 lite SKILL 中
  `*publish` / `*sync` / `*research` / `*deps` **零命中**——这些命令只存在于 full 侧。
  故在 P5c（把命令流程带进 lite）落地前，本单是**纯暴露面、零已实现收益**。
  这是刻意的顺序（先解权限锁、再搬流程），但须如实记录。

- **同文件内的表述并置（Gate 2 config-manager P2-1，如实记录）**：`alex-lite` 的
  `## Lite Progress` 节有一句「边界：**不写完整 session-state.md**」（约 L188）。
  逐句读其主语是 **Blake-Lite** 的进度机制，与本单给 Alex 的写权限**不构成逻辑冲突**；
  该行本单一字未改（§2 承诺不动 Forbidden 节以外任何行）。
  但需承认：**这个并置的显著性是本单造成的**——本单之前 alex-lite 对 `session-state.md`
  是全面禁止，不存在「一边说能写、一边说边界是不写」同时出现在一个文件里的情形。
  **如有误读，以 Forbidden 新文本为准。** 该行的措辞澄清留作后续单独处理。

- **本单不改框架侧 `settings.json`** —— 其 `permissions` 三项全空，即 TAD 从未为下游设过底线。
  独立议题（Epic P5.5）。

- **caller/consumer**：两个 SKILL.md 的消费方 = Claude Code skill 加载器 + `.agents/skills/` 镜像。
  ⚠️ **本单只改 `.claude/`，未同步 `.agents/`**，两平台将不一致（P5a 已有同样缺口）。
  **必须在 Completion 显式记录**，作为 P5c 输入。不得声称「无下游影响」。

- **自指**：本单同时修改 alex-lite 与 **blake-lite 自己**。SKILL 在调用时注入，
  会话中途改文件不改变已加载指令。**但执行期间若发生压缩，不得重跑 `/blake-lite`** → 停下报人。
  AC5 的 `HEAD == e2588e6` 是机械兜底。

## 7. v1 → v2 修订记录（Gate 2 双专家）

| Reviewer | verdict | 计数 |
|---|---|---|
| code-reviewer | **CONDITIONAL** | P0=1, P1=3, P2=5 |
| config-manager（协议一致性位） | **CONDITIONAL** | P1=4, P2=3 |

两位均**独立重算并确认** v1 的两个 md5、行/字节/字符数、AC3 十二条改前值、超期扫描为空、
HEAD 为 `e2588e6`、台账定价口径成立、无原约束意外丢失。v2 修的 8 条：

1. **P0 · AC5 在 t=0 即 FAIL**：两条既有脏项不在白名单，其中
   `.claude/settings.local.json.bak-20260806-082549` 还形似黑名单 `.claude/settings*.json`
   （**那是 Alex 本 session 自己造的备份**）→ AC5 改为相对基线做增量 + 补白名单 2 项 + 显式豁免该备份。
2. **P1 · `明确排除` 漏 `.agents/skills/*/references/`**：实测两处各 298,111 chars 逐字节同量镜像。
   旧文本「任何 references/」是全覆盖，v1 的路径特定 glob **反而把防线做窄了** → 两侧均补上。
3. **P1 · blake 侧「Completion 的 Evidence 段」不存在**：Completion 模板（L223–236）无此段。
   既有惯例是 L0.75 的「上下文刷新」行（L84 明文）→ 改为「上下文刷新」行。
4. **P1 · 「末项 ≤2 个文件」指代歧义**：可读成 `release-runbook` skill，那样 `.tad/guides/`
   12 个文件不受任何上限——正是 N1 声称要挡的失败模式 → 改为「其中工具编排文档一项」。
5. **P1 · push「属安全停清单第 1 条」断言不成立**（第 1 条只字面枚举 force-push/删分支/改历史）
   → 删除断言，改为**独立于清单**的自证表述。
6. **P1 · `@import` 回指夸大**：8 个路径中仅 2 个字面落在停清单第 2 条内
   → 拆为两句：字面命中的仍引清单，其余改为**独立理由**（每 session 自动注入 + 空槽无前版本可 diff）。
7. **P1 · AC4 散文无验证**：「须含 grep 锚」「2+2 状态」全无命令 → 补 3 条可执行断言。
8. **P2 · §5 引用不存在的「§9」**（契约只到 §8）→ 已改；
   **P2 · 两处未声明的文本变更** → §1 已补说明；
   **P2 · AC3 无独立判别力** → 改称「诊断锚」并注明用途。

**同时按用户 2026-08-06 指示撤回 v1 的一条新增约束**：`spawn subagent 未在 LITE 契约中申报
用途与次数`。用户裁定不限制 subagent 使用，审查环节的「1 个」两个 skill 已写明。
台账因此从 4 行减为 3 行（N1 由 2 条减为 1 条）。

## 8. Message to Blake

改 2 个文件、各 1 节。§3 给了完整新文本，**照抄别发挥**。

**取文本**（本契约有两个 ```text 块，按序号取）：
```bash
H=.tad/active/handoffs/HANDOFF-20260806-lite-full-parity.md
awk -v n=1 '/^```text$/{c++; if(c==n){f=1;next}} f&&/^```$/{exit} f' "$H"   # alex 侧 28 行
awk -v n=2 '/^```text$/{c++; if(c==n){f=1;next}} f&&/^```$/{exit} f' "$H"   # blake 侧 27 行
```

**验收两条 md5**：
- `alex-lite` → `1a6bc26c010dba163a69c1fea40e6c82`
- `blake-lite` → `b9a0c096b5fd4436b0a288dee713d55e`

另追加台账 3 行（1 HAS-CARRIER + 2 SUPERSEDED），追加前先跑超期扫描。

⚠️ 执行期间若压缩，**不要重跑 `/blake-lite`**，停下报人。

---

## Lite Progress

- Phase=admission | repair_round=0/3 | same_error_count=0/2 | verdict=RUNNING | Evidence=.tad/evidence/acceptance-tests/lite-full-parity/ac-results.md | Next Action=实现 §3 两节替换
- 通道裁定（逐字记录）：用户原话「请在 Terminal 2 输入 /blake-lite。」（2026-08-06 任务消息）；文件名 HANDOFF-* 非 LITE-*.md 白名单 + 缺 ## Contract Review 段 → 按 L0.5 escape hatch 放行：人明确指示 + handoff §6 自指 blake-lite 为执行方 + §7 Gate 2 双专家两轮审查（v2 修 1 P0+7 P1）+ Epic 约束 #4（P3 起走 lite）+ P5a 同形态先例
- 安全停清单：三项均未命中（改 SKILL.md 非不可逆/非 SAFETY 面/非注册面；暴露面 §1/§6 已声明）
- 基线实测：HEAD=e2588e6；alex head-306 md5=0a5be1ca…（§3.1 一致）；blake head-351 md5=9eb6bb18…（§3.2 一致）；台账 4 行；脏项 2 豁免（REGISTRY.yaml + settings.local.json.bak-20260806-082549）其余全在白名单
- Phase=implement | repair_round=0/3 | same_error_count=0/2 | verdict=RUNNING | Evidence=.tad/evidence/acceptance-tests/lite-full-parity/ac-results.md | Next Action=L3 独立审查
- 实现方式：§8 awk 抽取块1(28行)/块2(27行) → head-306/head-351 拼接至 /tmp → 临时文件 md5 双命中后才 mv 落地（未破坏源文件）；台账 +3 行（1 HAS-CARRIER + 2 SUPERSEDED，超期扫描输出空）
- Phase=ac | repair_round=0/3 | same_error_count=0/2 | verdict=RUNNING | Evidence=.tad/evidence/acceptance-tests/lite-full-parity/ac-results.md | Next Action=L3 独立审查
- AC1-AC5 全部首跑 PASS（md5 双命中 + 行数/bytes/chars/末字节 5 项 ×2 + AC3 8 锚 + AC4 7 断言 + AC5 HEAD/白名单/黑名单）；0 repair loop
- Phase=review | repair_round=0/3 | same_error_count=0/2 | verdict=RUNNING | Evidence=.tad/evidence/reviews/blake/lite-full-parity/code-reviewer.md | Next Action=L3.5 Technical Gate → L4 Completion
- L3 reviewer: PASS | model=deepseek-v4-flash | P0=0 P1=0 P2=4（2 项为 Completion 落地义务：.agents/ 未同步声明 + 超期扫描「(空)」粘贴）；AC1-AC5 全量重跑全绿；§3 文本块与成品 diff 空；前缀 md5 与 HEAD 双一致

---

## Completion (2026-08-06)

**Commit**: uncommitted（本单零 git 写操作；commit 归人决定）
**Model**: harness=claude-code | model=deepseek-v4-flash | route=api.deepseek.com (alias-mapped)

- 上下文刷新：已读 handoff 全文、lite-constraint-ledger.md 全文、session-state.md（hook 注入）、patterns/ac-verification（上一单已读）；关键约束：2 文件各 1 节（## Forbidden）、节外一字节不动（前缀 md5 锚定 0a5be1ca…/9eb6bb18…）、§3 文本块照抄别发挥、禁止任何 git 写操作、追加台账前必跑超期扫描；成功条件：AC1-AC5 全绿 + reviewer PASS + Technical Gate PASS
- 改动文件：
  - .claude/skills/alex-lite/SKILL.md（307 行至末尾整段替换，§3.1 28 行）
  - .claude/skills/blake-lite/SKILL.md（352 行至末尾整段替换，§3.2 27 行）
  - .tad/evidence/audits/lite-constraint-ledger.md（追加 3 行：1 HAS-CARRIER + 2 SUPERSEDED，4→7）
  - [清单外：白名单证据载体] .tad/evidence/acceptance-tests/lite-full-parity/ac-results.md（新建）
  - [清单外：白名单证据载体] .tad/evidence/reviews/blake/lite-full-parity/code-reviewer.md（新建）
  - [清单外：白名单证据载体] 本 handoff 自身（Lite Progress 6 边界 + Completion + Reflexion）
- AC 结果：AC1-AC5 全部 ✅ 首跑通过（0 repair loop），原始输出 → .tad/evidence/acceptance-tests/lite-full-parity/ac-results.md（reviewer 独立重跑逐字一致）
  - AC1 ✅ md5=1a6bc26c010dba163a69c1fea40e6c82 / 334 行 / 22376 B / 11985 chars / 末字节 \n
  - AC2 ✅ md5=b9a0c096b5fd4436b0a288dee713d55e / 378 行 / 25022 B / 13659 chars / 末字节 \n
  - AC3 ✅ 8 条诊断锚 0/0/0/1/1/1/0/5 全一致
  - AC4 ✅ 台账 7 行 / append-only 删行 0 / 锚 1 / HAS-CARRIER 1 / SUPERSEDED 2 / 两主题各 1
  - AC5 ✅ HEAD=e2588e6 / 白名单外 0 / 黑名单 0
  - 超期扫描原始输出：(空)（2026-08-06 追加前实跑，输出为空、exit 0）
  - AC5 结构性盲区显式声明：本单**未触碰** `.claude/settings.local.json`（mtime 08:25:49 早于本单）与 `.tad/logs/violations.log`（mtime 08-02 23:03，历史文件）；全部写操作仅限 3 个清单内文件 + 白名单证据载体
- Reviewer: PASS | model=deepseek-v4-flash, P0=0, P1=0, P2=4 | 摘录：AC1-AC5 全部执行实证 PASS；§3 两节与成品 diff 为空逐字节一致；前缀 md5 与 HEAD 双一致（节外一字节不动成立）；零 git 写操作（git diff --cached 空）；gitignore 盲区经 git check-ignore 实证；`.tad/guides/` 12 文件 71624 chars 与 N1 定价吻合；release-runbook 无 references/ 目录，「≤2 文件」例外可实际使用（执行实证）
- Technical Gate: **GATE PASS**
  1. AC/evidence：8 条 AC 全部有原始输出与证据路径（自验 + reviewer 双份）✅
  2. reviewer verdict：PASS，P0=0 P1=0 ✅
  3. friction：无 BLOCKED（md5/grep/awk/git 全可用；zsh 陷阱按 §5 规避）✅
  4. scope/risk：改动限于 §3 清单 3 文件；caller/consumer 检查——消费方 = Claude Code skill 加载器 + `.agents/skills/` 镜像，后者**未同步**（见 follow-up，P5c 输入）✅
  5. Knowledge Assessment：journal captured → .tad/evidence/journal/lite-discoveries.md 追加 1 行 ✅
- Knowledge Assessment: journal captured（.tad/evidence/journal/lite-discoveries.md 2026-08-06 行）
- 意外发现：`.agents/` 镜像失同步实证——`.agents/skills/alex-lite/SKILL.md` md5=e3d67da7a5f5aaa5d6405b10bf70de09 ≠ `.claude` 侧 1a6bc26c…（reviewer 执行实证）
- follow-up：
  - **⚠️ `.agents/skills/` Codex 镜像未同步（P5a 已有同样缺口，本单刻意保持最小改动）**：两平台 alex-lite/blake-lite Forbidden 现不一致（alex 侧四项能力放开、blake 侧 commit 授权放开仅存在于 `.claude/`）。§6 要求显式记录 → **P5c 输入**（把命令流程带进 lite 时一并同步镜像）。不得声称「无下游影响」。
  - P2-1（执行实证）：§5 陷阱表建议补一行「.agents/ 镜像未同步 → P5c 同步」防遗忘 | owner=Alex-Lite
  - P2-2（执行实证）：超期扫描「(空)」粘贴已在 Completion 落地 ✅（本单完成）
  - P2-3（阅读推断）：blake 新文本 commit/push 双闸句法断句可读性——语义正确（push 双闸、commit 单闸+逐字记录），不改文本，维护时注意 | owner=Alex-Lite
  - P2-4（阅读推断）：§6 已披露的 alex-lite L188「边界：不写完整 session-state.md」措辞澄清（主语为 Blake-Lite，与 Alex 新写权限不冲突）留作后续单独处理 | owner=Alex-Lite
  - 本单 + 台账均未 commit（发布归人）；P5a 单亦未 commit（e2588e6 之后工作区改动归人处置）

## Reflexion

无修复。
- Phase=technical-gate | repair_round=0/3 | same_error_count=0/2 | verdict=GATE PASS | Evidence=.tad/evidence/acceptance-tests/lite-full-parity/ac-results.md + .tad/evidence/reviews/blake/lite-full-parity/code-reviewer.md | Next Action=人验收 → 归档
- Phase=human-gate | repair_round=0/3 | same_error_count=0/2 | verdict=GATE PASS | Evidence=同上 | Next Action=人验收（L5）→ 验收后 mv 到 .tad/archive/handoffs/
