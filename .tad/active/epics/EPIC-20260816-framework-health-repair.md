# Epic: 框架健康修复（数据安全 + 发行瘦身）

**Epic ID**: EPIC-20260816-framework-health-repair
**Created**: 2026-08-16
**Owner**: Alex
**依据**: `.tad/active/designs/AUDIT-20260816-framework-health.md`（36 条发现，F-01 ~ F-34 + S-01 ~ S-04）

---

## Objective

修复 TAD 安装器中会**不可逆删除用户数据**的三个 P0 缺陷及其相邻缺陷，清除已失效的治理机制与死代码，并把发行体积从 30.19 MB 降到 6 MB 量级 —— 使框架重新具备安全对外交付的条件。

**本 Epic 不包含**：恢复对 14 个下游项目的同步（Phase 5，需本 Epic 全部完成后另立）、激活成本削减（Phase 6）、结果度量体系设计（Phase 7）。这三项已在审计报告 §10 记录，**不在本 Epic 范围内**。

---

## Success Criteria

- [ ] **SC1** 沙箱中执行完整安装流程后，用户预置的 `.codex/`、`.gemini/`、`AGENTS.md`、`GEMINI.md`、`CLAUDE.md` **全部逐字节保留**（`diff -r` 为空）
- [ ] **SC2** `grep -c 'deny_ref' .claude/skills/alex/SKILL.md` == `0`，且 `gate4_delta` / `step1d_ac_dryrun` / `step0_graph` 三条禁令在 SKILL **正文**中各出现 ≥ 1 次
- [ ] **SC3**（**2026-08-16 修订**）发行包不再携带维护者的调试记录：
  - **主判据**：`git ls-files '.tad/evidence/*' | wc -l` == `0` **且** `git ls-files '.tad/archive/*' | wc -l` == `0`
  - **辅助度量**：`git archive --format=tar HEAD | gzip -9 | wc -c` 相对审计基线 `31,659,251` 降幅 ≥ **70%**（实测移出后 7.99 MB = **降 74%**）
  - ⚠️ **原判据「< 8 MB」已废弃**：那是审计时拍的圆整数，非从需求推出。实测移出 evidence+archive 后为 7,99 MB，**余量仅 5,874 字节**，而本 Epic 自身产出的单张工单 gzip 后即 10,134 字节 —— **该阈值会因本单自己要求产出的证据文件而 FAIL**。
  - **教训**：验收阈值必须从需求推导，不能取「看起来整齐」的数。一个会被自己的交付物撞破的阈值，度量的是巧合而非目标。
- [ ] **SC4** `tad.sh` 中 `rm -rf` 的调用点全部位于 `guarded_remove` 内或有等价前置断言 —— 用可复跑的检查命令钉死
- [ ] **SC5** 安装器可在 `mktemp -d` 沙箱中以本地源完整执行（不依赖网络），且该能力有 AC 覆盖

---

## Phase Map

> **2026-08-16 拆分**：原 Phase 1 两次 Gate 2 FAIL（4 名 reviewer，15 个唯一 P0），根因是把「纯删除」与「退休声明层」捆在一起。已拆为 1a / 1b。

| # | Phase | Status | Handoff | Key Deliverable |
|---|-------|--------|---------|-----------------|
| 1a | 纯删除 | ✅ **DONE**（`01c4bf22`） | `HANDOFF-20260816-phase1a-pure-deletion.md` | 删 playground 两侧 + 两个空头绑定 + evidence 去重 182 文件 |
| 1a-2 | ROADMAP 悬空链接 | ✅ **DONE**（`b6956606`） | `HANDOFF-20260816-phase1a2-roadmap-link.md` | 修 `ROADMAP.md:38` 的悬空 markdown 链接 |
| 1b | 退休 frontmatter 约束块 | ⬚ 单子就绪，**待人裁定 `enforcement` 二选一** | `HANDOFF-20260816-phase1b-retire-frontmatter.md` | 写 4 条孤儿 + 处理标量 + 改 16 处悬空引用 |
| 2 | 安装器数据安全 | 📋 **出单+两轮审查完成**（`0e14a15b`）；Gate 2 **FAIL**，阻塞为两项人裁定 | `HANDOFF-20260816-phase2-installer-data-safety.md` | 三个 P0 + 本地源可测试性 + 修正把缺陷当规格的验收测试 |
| 3 | 遗留脚本与计数安全 | ✅ **DONE**（`01c4bf22`） | `HANDOFF-20260816-phase3-legacy-script-and-count.md` | 删 `eval`+`rm -rf` 脚本、镜像删除加守卫、修 Layer-0 计数 |
| 4 | 发行瘦身 | ✅ **DONE**（`659f4161`） | `HANDOFF-20260816-phase4-distribution-slimming.md` | evidence/archive 移出 main、`.npmignore`、tarball 降至 8 MB 以下 |

### ✅ Epic 自动部分已全部交付（4 次提交，2026-08-16）

| commit | 内容 | Gate 2 | Gate 3 | Gate 4 |
|---|---|---|---|---|
| `01c4bf22` | Phase 1a + Phase 3 | ✅ | ✅ 双份 | ✅ |
| `b6956606` | Phase 1a-2 | ✅ | ✅ 5/5 | ✅ |
| `659f4161` | Phase 4 | ✅ | ✅ 13/13 | ✅ |
| `0e14a15b` | Phase 2 出单 + 两轮审查 + 9 处 P0 回改 + 4 条知识蒸馏 | ❌ FAIL（人裁定阻塞） | — | — |

**Gate 4 业务验收**：回到审计原始发现逐条复算，**F-16 / F-15 / F-19 / F-09 / F-10 / F-11 / F-12 / F-18 / F-20 全部闭环**，无一靠削弱验收标准达成。

### ✅ 已交付明细（commit `01c4bf22`，2026-08-16）

```
210 files changed, 4340 insertions(+), 131241 deletions(-)
```

| 消除的风险 | 证据 |
|---|---|
| `eval` 驱动的 `rm -rf`，路径来自含空格/CJK 的注册表 | `sync-v2.8.4.sh` 已删除（实测零活引用） |
| `rsync --delete` 无非空守卫 → 源空即清空 `.agents/skills` | 守卫在 `release-verify.sh:683`，三场景实测正确 |
| 压缩恢复安全网对含空格文件名多计数（2 文件报 3） | `list_dir` 改为先按行计数；端到端在真实仓库验证输出 `(7)` 正确 |
| 废弃两月的 skill 仍在发布并在 description 推销 | 两侧目录已删；系统技能目录已自动更新 |
| 两个无消费者的空头配置绑定 | 已删，`tad-gate` 原位留可追溯注释 |
| 182 个逐字节重复的证据文件 | 换成从 `git show` 生成的可回溯清单（溯源抽样 5/5） |

**Gate 3 由 4 名独立 subagent 分工验证**（每次合并任务过大都会卡死 → 拆小，本 Epic 内三次奏效）。

### 📌 历史阻塞记录：reviewer 机制曾不可用（已解除）

**6 次 subagent 调用连续失败且无消息**（`727f3ab1`、`2c922a5c`、`a5b767eb`、`8baaf359`，及两次最小探针）。最小探针仅执行一条 `grep -c`、不写文件，同样失败 → **能力不可用，非 prompt 规模问题**。

按 `tad_friction_protocol`：状态 **BLOCKED**，`status_enum` 明文 **"Self-review is NEVER equivalent"** → 规则 1（min 2 独立专家审查）不得豁免，Gate 2 不得 PASS。

**解除条件**：(1) subagent 恢复；(2) 人类显式批准降级 → `DEGRADED_WITH_APPROVAL`；(3) 人类自任 reviewer → `EQUIVALENT_SUBSTITUTE`。

### ✅ 阻塞期间已完成的、无需 reviewer 的工作

**承载者地图** `.tad/active/designs/CARRIER-MAP-alex-constraints.md` —— 1b 的前置产物，四轮迭代（前三轮判据均有缺陷，记录在图内 §1）。

结论：**4 个真孤儿**（`deny.hook_scripts`、`deny.tool_blocking`、`skillify.create_directly`、`skillify.call_from:blake` —— 后两条是 CLAUDE.md §4 核心不变式，全仓无第二处承载）+ 1 个半孤儿（`enforcement` 标量）+ **16 处悬空引用（6 文件，前身单遗漏了 `SKILL.md:703`）**。

该图使 1b 的工作量从「搬 11 个 key」收窄为「写 4 条孤儿 + 1 个标量 + 改 16 处引用」，且证明 19/24 条 deny_extra 已有承载、位置优于 frontmatter。

### Phase Dependencies

```
Phase 1 ──► Phase 2 ──► Phase 4
   │                       ▲
   └──► Phase 3 ───────────┘
```

- **Phase 1** 无前置，先行以建立动量并降低后续改动的噪音
- **Phase 2** 依赖 Phase 1（清扫后 SKILL/配置面干净，改动可归因）
- **Phase 3** 只依赖 Phase 1，可与 Phase 2 并行排期，但**不同时 Active**
- **Phase 4** 依赖 Phase 1（F-19 去重先做）与 Phase 2（确认无运行时读取 evidence）

⚠️ **同时只能 1 个 Active phase。**

### Derived Status
- **Status**: In Progress（Phase 1 = 🔄）
- **Progress**: 0 / 4

---

## ⚠️ Epic 级硬约束

1. **Phase 2 通过 Gate 4 之前，禁止执行 `*sync`、禁止发布、禁止建议任何人运行安装命令。** 否则等于把 F-01/F-03 的删除缺陷推送到 13 个真实存活的下游项目。
2. **禁止纸面验收。** 每个 Phase 的 AC 必须是可复跑命令，且必须演示**改前红 / 改后绿**。Phase 2 的负控测试若无法端到端执行，先交付 F-33（本地源模式）。
3. **不得误伤审计报告 §6 列出的已验证正确设计**（zero-touch 推导、`migration-engine.sh` 闸口、hook 失败开放、`verify_install_complete`、空格安全实践等）。
4. 每个 Phase 出 handoff 前，**Alex 必须先完成苏格拉底提问**（规则 0，BLOCKING），本 Epic 不豁免。

---

## Phase Details

### Phase 1: 零风险缺陷清扫

**Status:** 🔄 Active
**Execution:** pending handoff
**覆盖发现:** F-04, F-15, F-16, F-19

#### Scope
纯删除与一致性修正，**不改变任何运行时行为逻辑**：移除从未生效的 frontmatter 治理块并把其中 3 条裸禁令搬进 SKILL 正文；把三个角色的模块加载清单与 `config.yaml` 绑定对齐；从技能发现字符串中移除已废弃的 `*playground` 并退役其 skill 文件；删除 `stable5-pre`/`stable5-post` 中一侧的逐字节重复证据并代之以 SHA-256 清单。

**不在范围**：任何 `tad.sh` 改动、任何 hook 逻辑改动、Blake/Gate SKILL 的协议外移（属「激活成本」工作包）、**F-35（Alex 该如何使用 `decision_transparency`）—— 那是设计问题，会破坏本 Phase 的零风险属性，已移入待 `*discuss` 清单**。

#### 风险重估（2026-08-16，人裁定「不拆，合并执行 + 分段验证」）

Phase 1 原标「风险：零」**不准确**，已更正。本 Phase 含两类性质不同的改动：

| 类别 | 动作 | 真实风险 |
|---|---|---|
| **1a 纯删除** | 删 frontmatter 治理块、`description` 去 `*playground`、删 playground skill、evidence 去重 | **零** —— 无消费者，已实测 |
| **1b 首次激活** | 3 条禁令写入正文、三个角色补 `config-cognitive` | **非零** —— 这些约束**从未送达过模型**，首次生效的行为影响无人观测过 |

**人裁定：不拆 Phase，合并执行**，但 handoff 必须把两类改动的验证分开写，**Gate 3 分段判定**（1a 与 1b 各自独立给出 PASS/FAIL，不得合并成一个结论）。若 1b 出现异常而 1a 干净，判定必须能区分二者。

#### 已裁定的五项（2026-08-16，人已批准；第 2/5 条经 Gate 2 专家审查后修订）

1. **playground 退役方式**：从源码删除 `.claude/skills/playground/` 与 `.agents/skills/playground/`，**但不写入 `deprecation.yaml`**。
   理由：`.tad/active/` 属 zero-touch，`Next Guest` 的 53 个 playground 产物永不会被同步触及；而写入 `deprecation.yaml` 会主动删除下游 skill 目录 —— **F-01 的病根正是 deprecation 删得过狠，此时不应再向其中添加条目**。下游残留一份失效副本，无害。

2. **F-15 修复方向 —— 仅保留 Gate 一侧；Alex/Blake 一侧移出本 Phase**（**2026-08-16 二次修订，Gate 2 专家审查后**）：

   | 角色 | 方向 | 依据 |
   |---|---|---|
   | **Gate** | **删除 `config.yaml:109` 的 `tad-gate` 绑定**，旁注指向 `gate/SKILL.md:227` | Gate 已把 Cognitive Firewall 内容**内联**（`gate:219` Risk Translation Pillar 3、`:706` Decision Compliance Pillar 1），绑定是多余声明。删除即零风险 |
   | **Alex / Blake** | ⛔ **移出本 Phase，另立工作包**（见审计 F-36） | 见下 |

   ⚠️ **本条经历两次推翻，两次都是证据不足**：
   - 初稿写「三个角色一律补齐」→ 未区分「有活指针」与「仅有声明」，过度一般化
   - 二稿写「Blake 有活指针该补 / Alex 无引用 / Gate 无引用该删」→ **「Alex 无引用」是错的**。Alex 有活指针 `alex:1145`（MANDATORY 块）→ `references/research-decision-protocol.md:9` → `config: ".tad/config-cognitive.yaml"`。原判断只 grep 了字面量，未沿 reference 下钻一层。
   - 三稿（当前）：Alex 与 Blake 证据等级**相同**，但**都不在本 Phase 做** —— 理由见第 5 条。

5. **FR5（给 Alex/Blake 补 `config-cognitive`）移出 Phase 1，另立工作包**（人已裁定 2026-08-16）：

   它**不是一致性修正**，而是激活两条治理纪律：
   - `.tad/config-cognitive.yaml` 除 `decision_transparency` 外还含 `research_first`：`blocking: true`、`min_queries: 3`、`tools: [WebSearch, WebFetch]`，违规条款含「设计自定义方案而未先搜索 = VIOLATION」
   - 这与 `CLAUDE.md §2`「研究工具排除：不要 spawn generic Agent 做 web search，用 `*research` 统一入口」**直接冲突**，也与本单 frontmatter 的 `research_required: no` 冲突
   - `.tad/discipline-floor.md:20-21` 将「研究先行」与「技术决策透明」**均标为「待判」**，解除条件是**循环触发实测**。在清扫单里加载它 = 未经实测即转正，**绕过治理**

   **先决条件是实测，不是写代码。** 归入审计 §10.2 的「Cognitive Firewall 激活」工作包。

3. **1b 的回退判据**（人已批准）：
   > 新约束导致 agent 在**本应继续的场景下停下来问人**，或**拒绝执行 handoff 明确授权的动作** —— **出现 1 次即回退 1b，保留 1a**。

   该判据须写入 handoff 的 §10 禁止事项与 Gate 3 分段判定条款。

4. **`deny_ref` 不做 git 考古**：`migration.provenance.old_line` 已验证可正确解析至 `697c616e` 的 `forbidden_implementations` 原文，且其内容与现存 `deny_extra` 同源、无净增信息。因此**直接删除 `deny_ref` 与 `migration:` 块**，以 `deny_extra` + 原文为准写入正文明文祈使句。

#### Input
- 审计报告 F-04（含 8 条 override 在正文的存在性逐条核对表）、F-15、F-16、F-19
- `.claude/skills/alex/SKILL.md`（1,789 行）、`.tad/config.yaml:100-101`
- `.tad/evidence/acceptance-tests/release-runbook-capability-migration/`（182 对逐字节相同文件）

#### Output
- `alex/SKILL.md` frontmatter 治理块移除；`gate4_delta` / `step1d_ac_dryrun` / `step0_graph` 三条禁令首次进入正文并真正生效
- STEP 3 模块清单与 `config.yaml` 绑定一致（二选一，需人裁定以哪边为准）
- `*playground` 从 `description:` 移除；`.claude/skills/playground/` 退役
- 证据去重，仓库减少约 18.62 MB

#### Acceptance Criteria（全部已在设计期空跑，附改前实测值）

- [ ] **AC1.1** `grep -c 'deny_ref' .claude/skills/alex/SKILL.md` → `0`，且 `grep -c 'source_baseline' → 0`（`migration:` 块整体移除）｜ 改前实测 **9 / 1**（红）
- [ ] **AC1.2** 三条禁令在正文（frontmatter 闭合之后）各出现 ≥1：
      `sed -n '/^---$/,$p' .claude/skills/alex/SKILL.md | tail -n +2 | grep -c 'gate4_delta'` → `≥1` ｜ 改前 **0**（红）
      同法 `step1d_ac_dryrun` → 改前 **0**（红）；`step0_graph` → 改前 **0**（红）
- [ ] **AC1.2b（形式约束）** 上述三条在正文中以**明文祈使句**表达（含 `MUST NOT`），**不得**以 `deny_extra:` 风格的压缩 YAML 搬运。
      量化：正文 `MUST NOT` 计数相对基线**净增 ≥ 8**。
      基线实测 = **12**（`sed -n '/^---$/,$p' … | tail -n +2 | grep -c 'MUST NOT'`）。
      下界依据：祖先 `697c616e` 三个 `forbidden_implementations` 块窗口内实测 `MUST NOT` 为 **3 / 7 / 5**（合计 15，窗口法可能含相邻块，故取保守下界 8 而非 15）。**Blake 在实现时须逐条核对，不得凑数。**
- [ ] **AC1.2c（无净损验证）** 逐条比对：`deny:`、`cross_model:`、全部 `deny_extra` 的每一项语义在正文中都有对应表述。**核对基准是 `697c616e` 的 `forbidden_implementations` 原文**（`migration.provenance.old_line` 指向，已验证可解析），不是 `deny_ref`（已验证指向无关内容）
- [ ] **AC1.3** `sed -n '3p' .claude/skills/alex/SKILL.md | grep -c 'playground'` → `0` ｜ 改前 **1**（红）
- [ ] **AC1.4** `ls .claude/skills/playground/SKILL.md 2>/dev/null | wc -l` → `0` ｜ 改前 **1**（红）
- [ ] **AC1.5c（反向修）** `config.yaml` 中 `command_module_binding.tad-gate` 条目已删除，且原位置留有说明 gate 采用按需读取的注释（指向 `gate/SKILL.md:227`）｜ 改前：绑定声明 `[config-quality, config-cognitive]` 而 gate 无任何加载步骤（红）
- [ ] **AC1.5c-neg（负控）** `gate/SKILL.md` **未**新增急切加载步骤 —— `grep -cE 'Load required modules|Load config modules' .claude/skills/gate/SKILL.md` 仍为 `0`。**本 AC 防的是"顺手统一形式"的过度修复**
- [ ] **AC1.6** `git ls-files '.tad/evidence/acceptance-tests/release-runbook-capability-migration/*' -z | xargs -0 wc -c | awk '/total$/{s+=$1}END{print s}'` 减少 ≥ `18,000,000` 字节
- [ ] **AC1.7** **负控**：`.claude`/`.agents` 双平台 SKILL 仍逐字节一致 —— `cmp .claude/skills/alex/SKILL.md .agents/skills/alex/SKILL.md` 退出码 `0`
- [ ] **AC1.8** **负控**：`bash .tad/hooks/lib/release-verify.sh platform-skills` 通过（确认退役 playground 未破坏对称性校验）

#### Files Likely Affected
- `.claude/skills/alex/SKILL.md`（MODIFY）+ `.agents/skills/alex/SKILL.md`（MODIFY，须同步）
- `.claude/skills/playground/`、`.agents/skills/playground/`（DELETE）
- `.tad/config.yaml` **或** SKILL STEP 3（MODIFY，二选一）
- `.tad/evidence/acceptance-tests/release-runbook-capability-migration/stable5-pre/**`（DELETE）+ SHA-256 清单（CREATE）
- `.tad/deprecation.yaml`（可能 MODIFY：playground 退役登记）

#### Dependencies
None（可立即执行）

#### Notes
- ✅ **两项裁定已完成**（见上「已裁定的两项」），Phase 1 无剩余待决项，可直接进入苏格拉底提问 → 出 handoff。
- **下游 playground 使用实况**（2026-08-16 实测 12 个存活项目）：`Next Guest` 有 **53 个产物 + 4 个 handoff 提及**（真实使用过）；`menu-snap` 1 产物 + 1 提及；其余 10 个各 1 个占位产物、handoff 零提及。**这些产物位于 zero-touch 的 `.tad/active/playground/`，本 Phase 不触及。**
- **激活成本净变化（三稿修订）**：FR5 移出后，本 Phase 对激活成本是**净减** —— 删 frontmatter 4,229 B，无新增模块。正文回填的祈使句会加回一部分，净额由 AC 实测，不预设。
- F-19 去重后，该验收单的原始主张（"pre == post 证明零副作用"）由 SHA-256 清单承载，**证据力不降低** —— 但清单必须由现有文件真实生成，不得手写。
- 本 Phase 全部为删除/一致性操作，**预期 Gate 3 无回归**；若出现回归，说明有未被识别的隐式依赖，应停下重新设计。
- ⚠️ **AC1.5c 是反向修（删绑定），不是补加载。** 若 Blake 在实现中产生「三个角色应当形式统一」的冲动，AC1.5c-neg 就是拦它的。**形式统一不是目标，证据一致才是** —— Blake 有活指针所以补，Gate 没有所以删。
- ⚠️ **回退判据已由「不可观测」改为「机械可测」**（Gate 2 专家审查裁定原判据不可执行）：改用「正文停顿条件计数不得增加」——`AskUserQuestion|STOP|BLOCKING` 在 alex 正文的基线实测为 **26**，改后必须 `≤26`。理由：原判据描述的是未来 session 的行为，Gate 3 阶段无对应产物、无反事实基线，且「本应继续却停了」不可由检视区分。

---

### Phase 2: 安装器数据安全

**Status:** ⬚ Planned
**Execution:** pending
**覆盖发现:** F-01, F-02, F-03, F-05, F-06, F-07, F-08, F-33, F-34

#### Scope
消除安装器中所有会不可逆删除用户数据的路径：把 `apply_deprecations` 的删除收进 `guarded_remove` 闸口并给版本闸门加上界；install 分支改走 `merge_claude_md`；备份文件改用时间戳命名；回滚覆盖其声称的范围；tarball 改解压到临时目录。**同时交付本地源可测试性（F-33）与修正把破坏行为当规格的验收测试（F-34）** —— 二者是本 Phase 全部 AC 的前置。

**不在范围**：`sync-v2.8.4.sh`（Phase 3）、`release-verify.sh --fix` 镜像删除（Phase 3）。

#### Input
- Phase 1 产出（清扫后的干净基线）
- 审计报告 F-01（含闸门实测与沙箱复现）、F-02（双路径对照）、F-03、F-33、F-34
- 已验证正确的 `migration-engine.sh` 闸口（`validate_path` → `check_containment` → `check_zero_touch` → 备份断言 → `guarded_remove`）—— **复用，不重写**

#### Output
- `tad.sh` 中不再存在绕过 `guarded_remove` 的删除路径
- `deprecation.yaml` 区分「TAD 自有文件」与「用户/第三方拥有路径」两类语义
- `tad.sh --source <dir>`（或等价 env）本地源模式，安装器可离线沙箱执行
- `upgrade-acceptance.sh` Check 3 判定方向修正：对用户拥有路径断言**存在且未改动**
- 可复跑的沙箱负控测试脚本，纳入 `.tad/tests/`

#### Acceptance Criteria

- [ ] **AC2.1（F-33 前置）** 安装器可在 `mktemp -d` 沙箱中以本地源完整执行，全程无网络访问，退出码 `0`
- [ ] **AC2.2（F-01/F-03 主控，负控测试）** 沙箱项目预置 `.codex/config.toml`、`.codex/prompts/mine.md`、`.gemini/settings.json`、自有 `AGENTS.md`、自有 `GEMINI.md`、自有 `CLAUDE.md`；执行安装后 `diff -r` 预置快照 → **无差异**
      ｜ 改前实测：审计沙箱中除 `.tad/version.txt` 外**全部消失**（红）
- [ ] **AC2.3** 上述测试对 `--platform claude-code` / `codex` / `both` **三种平台各跑一次**，全部通过（F-01 的丢失面随平台不同）
- [ ] **AC2.4（F-03）** 沙箱预置含自定义内容的 `CLAUDE.md`（无 TAD marker）→ 安装后用户内容仍在，且存在带时间戳的备份
- [~] **AC2.5（F-02/SC4）** `tad.sh` 内所有 `rm -rf` 调用点均在 `guarded_remove` 内或有前置非空+containment 断言 —— 用一条可复跑的检查命令表达并纳入 `release-verify.sh`
      ｜ **部分达成 2026-08-17（commit `65bb0840`，Gate 3 PASS）**：
      `apply_deprecations` 的删除点已接入 `do_backup` + `guarded_remove`（containment + zero-touch
      两重 + 遍历/自引用谓词 + 被拒副本回滚）；该函数体内裸 `rm -rf` 计数 **1 → 0**。
      Layer 2 双专家 PASS（code-reviewer 4 轮 + 独立复验 2 轮，含真实安装路径与符号链接对抗）。
      **剩余未做（不在本单范围）**：① tad.sh 另有 4 处 `rm -rf` 未评估 ——
      `:1396`（rollback_on_failure）、`:1711`/`:1998`（TAD_SRC 清理）、`:1871`（.tad-migrate-backup），
      它们删的是安装器自有产物而非用户路径，需各自判定是否需要断言；
      ② **「纳入 `release-verify.sh`」的可复跑检查命令尚未编写**。
- [ ] **AC2.6（F-01 版本闸门）** 构造 `current_version` 为高版本的沙箱，断言 `2.3.0` 块**不再触发**（上界生效）
- [ ] **AC2.7（F-34）** `upgrade-acceptance.sh` 在「用户 `.codex/` 存在」的目标上判定为 **PASS**（方向修正）｜ 改前：判 `stale dir` → FAIL（红）
- [ ] **AC2.8（F-06）** 人为触发 ERR 后，回滚结果与其打印的声明一致；或声明改为如实描述其覆盖范围
- [ ] **AC2.9（F-05）** 沙箱预置用户自有 `CLAUDE.md.bak` → 安装后该文件仍在且内容未变
- [ ] **AC2.10（F-07）** 沙箱预置用户自有 `TAD-main/` 目录 → 安装后该目录仍在且内容未变
- [ ] **AC2.11（F-08）** migrate 分支连续执行两次，`_archived/` 中同名文件不被静默覆盖
- [ ] **AC2.12 负控** `bash .tad/hooks/lib/derive-sync-set.sh --dirs` 与 `--zero-touch` 交集仍为 `∅`；`bash tad.sh --verify-denylist` 仍通过

#### Files Likely Affected
- `tad.sh`（MODIFY：`apply_deprecations`、install 分支 `:1623`、`merge_claude_md` 备份命名、`rollback_on_failure`、tarball 解压、migrate `_archived` 守卫、新增 `--source`）
- `.tad/deprecation.yaml`（MODIFY：语义分类）
- `.tad/tests/upgrade-acceptance.sh`（MODIFY：Check 3 方向）
- `.tad/tests/`（CREATE：沙箱负控测试脚本）
- `.tad/hooks/lib/release-verify.sh`（MODIFY：新增 rm 闸口检查）

#### Dependencies
Phase 1

#### Notes / 风险
- 🔴 **本 Phase 风险最高** —— 改的是删除路径。任何一次改动都必须先有失败的负控测试，再改代码（先红后绿），**不接受"改完再补测试"**。
- ⚠️ **F-34 与 F-01 必须同批修**：只修 F-01 不修 F-34，验收测试会把修好的正确行为判成 FAIL；只修 F-34 不修 F-01，等于删掉唯一的告警。
- ⚠️ `deprecation.yaml` 的语义分类需要人裁定：`.claude/commands/*.md`、`.tad/domains/*.yaml` 这类**确实是 TAD 自有**、该删；`AGENTS.md`、`.codex/`、`.gemini/` 是用户/第三方拥有、不该删。边界存疑一律按「用户拥有」处理。
- Phase 2 完成并过 Gate 4 之后，Epic 级硬约束 1 解除。

---

### Phase 3: 遗留脚本与计数安全

**Status:** ⬚ Planned
**Execution:** pending
**覆盖发现:** F-09, F-10, F-11, F-12

#### Scope
清除 `sync-v2.8.4.sh` 中 `eval` 驱动的 `rm -rf`、死守卫与过期 allow-list（建议直接删除该脚本）；为 `release-verify.sh --fix` 的 `rsync --delete` 镜像加非空断言与豁免面复核；修正 PreCompact 快照对含空格文件名的计数错误。

**不在范围**：`tad.sh` 的任何改动（Phase 2 已覆盖）。

#### Input
- Phase 1 产出
- 审计报告 F-09（`eval` 位置、`ZERO_TOUCH_RE` 零引用实测）、F-10（参数解析实测）、F-11、F-12（计数实测）

#### Output
- `sync-v2.8.4.sh` 删除或移入归档且失去可执行性
- `release-verify.sh --fix` 的镜像删除有非空断言
- `precompact-session-snapshot.sh` 的 `list_dir` 改用 NUL/换行分隔并按行计数

#### Acceptance Criteria

- [ ] **AC3.1（F-09）** 仓库内 `grep -rn 'eval "$@"' .tad/scripts/` → 无结果；若保留脚本则 `ZERO_TOUCH_RE` 必须被实际引用（`grep -c` ≥ 2）
- [ ] **AC3.2（F-10）** 若保留脚本：`set -- --dry-run --project menu-snap` 后 `ONLY_PROJECT` == `menu-snap` ｜ 改前实测 `'--project'`（红）
- [ ] **AC3.3（F-12）** 沙箱含 2 个文件（其一名含空格）→ `list_dir` 输出 count == `2` ｜ 改前实测 **3**（红）
- [ ] **AC3.4（F-12 负控）** 含 CJK 文件名与含空格文件名混合场景，count 与 `find -type f | wc -l` 一致
- [ ] **AC3.5（F-11）** `release-verify.sh --fix` 在 `CLAUDE_SKILLS` 为空目录时**拒绝执行** `--delete` 镜像并报错退出
- [ ] **AC3.6 负控** `bash .tad/hooks/pre-accept-check.sh` 与 `pre-gate-check.sh` 仍返回合法 JSON 且 exit 0（未破坏 hook 失败开放）

#### Files Likely Affected
- `.tad/scripts/sync-v2.8.4.sh`（DELETE 或 MODIFY）
- `.tad/hooks/lib/release-verify.sh`（MODIFY）
- `.tad/hooks/precompact-session-snapshot.sh`（MODIFY）

#### Dependencies
Phase 1（Phase 2 非前置，但**不得与 Phase 2 同时 Active**）

#### Notes
- F-09/F-10 的**首选方案是直接删除** `sync-v2.8.4.sh` —— 它仅被 evidence 文档引用，却握有 4 个真实项目的绝对路径。保留并修复是次选，成本更高、收益更低。
- F-12 改的是 Layer-0 压缩恢复安全网，**改动本身必须有负控**：错误的实现要能被 AC3.3/AC3.4 抓住。

---

### Phase 4: 发行瘦身

**Status:** ⬚ Planned
**Execution:** pending
**覆盖发现:** F-18, F-20

#### Scope
将 `.tad/evidence/` 与 `.tad/archive/` 移出 `main` 分支工作树（保留于 orphan 分支以维持可追溯），并修正 npm 打包面。**不做 git 历史重写。**

**不在范围**：`git filter-repo` 或任何改写 869 个 commit 的操作 —— 收益只及 `git clone`，而文档主推路径是 `curl`，代价是废掉所有已有 clone 与 fork。

#### Input
- Phase 1 的 F-19 去重产出（先减 18.62 MB）
- Phase 2 的确认：运行时无任何东西读取已提交 evidence
- 审计报告 F-18（打包体积实测）、F-20（npm 路径推断）

#### Output
- `main` 工作树不再包含 evidence/archive；orphan 分支 `maintainer-evidence` 保留全量
- `.npmignore` 或收窄的 `package.json` `files`
- tarball 从 30.19 MB 降至 6 MB 量级

#### Acceptance Criteria

- [ ] **AC4.1** `git archive --format=tar HEAD | gzip -9 | wc -c` < `8,388,608`（8 MB）｜ 改前实测 **31,659,251**（30.19 MB，红）
- [ ] **AC4.2** `git show maintainer-evidence:.tad/evidence/` 可正常读取（可追溯性未丢失）
- [ ] **AC4.3** `ls .npmignore` 存在 **或** `package.json` `files` 不再包含裸 `.tad/` ｜ 改前实测 `.npmignore` **不存在**（红）
- [ ] **AC4.4（F-20 补验）** 直接实测 npm 打包清单不含 `.tad/evidence/`（本次审计因本机 npm 缓存权限未能实测，**Phase 4 必须补上这一步**，不得沿用推断）
- [ ] **AC4.5 负控** 沙箱全新安装仍成功，`verify_install_complete` 通过 —— 证明移除 evidence 未破坏安装
- [ ] **AC4.6 负控** `bash .tad/hooks/lib/release-verify.sh` 全项通过

#### Files Likely Affected
- `.gitignore`（MODIFY）
- `package.json`（MODIFY）/ `.npmignore`（CREATE）
- `.tad/evidence/**`、`.tad/archive/**`（从 main 索引移除，orphan 分支保留）
- `.tad/brain-index.md`（可能 MODIFY：Evidence 表将为空，现已为 0 行）

#### Dependencies
Phase 1, Phase 2

#### Notes
- `tad.sh` 拉取的是 tarball（树快照，不含历史），因此**从 main 删除即刻生效，无需重写历史** —— 这是本 Phase 成本极低的根本原因。
- evidence 已在 `TAD_ZERO_TOUCH`（`tad.sh:226`），且 deny-list 是推导而非硬编码，**目录消失是 no-op，无需改安装器**。
- 已知可接受的副作用：维护者查旧证据需 `git worktree add` orphan 分支。

---

## Context for Next Phase

### Completed Work Summary
_（尚无 Phase 完成）_

### Decisions Made So Far
- **2026-08-16 / 通道**：本 Epic 走 full 通道（`/alex` `/blake` `/gate`），非 lite。理由：涉及框架自身 + 对外发布面，命中 CLAUDE.md §2.5 的人裁定类别，且含 P0 数据安全。
- **2026-08-16 / 范围**：只开 Phase 1-4（清理 + 数据安全 + 瘦身）。恢复交付、激活成本、结果度量三项边界清楚但依赖前置，留待本 Epic 完成后另立。
- **2026-08-16 / 排序**：零风险清扫先于 P0 修复。理由：先建立动量并降低后续改动的归因噪音；P0 虽最紧急但风险最高，宜在清扫后立即进行。

### Known Issues / Carry-forward
- ~~F-15 的方向未定~~ —— ✅ **已裁定 2026-08-16**：以 `config.yaml` 为准补齐 SKILL 正文（三个角色）
- ~~playground 下游依赖未确认~~ —— ✅ **已实测并裁定 2026-08-16**：源码删除、不进 `deprecation.yaml`
- **F-35 已从 Phase 1 剥离** —— Alex 对 `decision_transparency` 零引用是设计问题，留待与「结果度量」一并 `*discuss`，**不得在 Phase 1 顺手实现**
- **`deprecation.yaml` 的语义分类未定** —— Phase 2 handoff 前必须由人裁定，边界存疑按「用户拥有」处理
- **F-20 目前是 `[推断]`** —— Phase 4 的 AC4.4 必须补实测，不得沿用
- **S-02 的「129 个 handoff 无 completion」是粗匹配** —— 若日后立单需先精确重算
- 审计报告 §6 列出的已验证正确设计清单，是本 Epic 全程的**误伤红线**
- ⚠️ **一条方法教训（2026-08-16）**：Alex 在本 Epic 立项时曾把两个问题当作"需人裁定"抛给用户，实际其中一个是可查的事实（playground 下游使用），另一个是自己尚未查清的结论（`config-cognitive` 是否可有可无 —— 查完发现 Blake 有活指针，根本不是取舍题）。**能查的不该拿去问人；问之前先把功课做完。**

### Next Phase Scope
Phase 1：零风险缺陷清扫。**两项裁定已完成，无剩余待决项。** 下一步是 Alex 完成苏格拉底提问（规则 0，BLOCKING）后出 handoff 给 Blake。

---

## Notes

- 本 Epic 的全部依据来自 2026-08-16 的只读审计，报告见 `.tad/active/designs/AUDIT-20260816-framework-health.md`。所有 P0 声明均由 Alex 回到源码独立复核，F-04 为运行时实测。
- 审计过程中 Alex 自己更正过两处表述（evidence 分发机制、handoff 缺口统计方法），记录在报告 §9，**避免在 Epic 执行中重蹈**。
- 审计发现的 S-03（质量尺子完全自指）是本项目最深的结构问题，但**不属于本 Epic**。它决定的是「删完之后怎么知道有没有删对」，建议在 Phase 1-4 推进的同时以 `*discuss` 平行展开。
